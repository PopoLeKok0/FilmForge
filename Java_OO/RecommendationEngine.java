import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class RecommendationEngine {
    private static final double R = 3.5;
    private static final int K = 10;
    private static final int N = 20;

    private final Map<Integer, Movie> movies;
    private final Map<Integer, User> users;

    public RecommendationEngine(String movieFile, String ratingFile) throws IOException {
        this.movies = new HashMap<>();
        this.users = new HashMap<>();
        loadMovies(movieFile);
        processRatings(ratingFile);
    }

    private void loadMovies(String filename) throws IOException {
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            br.readLine(); // Skip header
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)", -1);
                int id = Integer.parseInt(parts[0]);
                String title = parts[1].replace("\"", "");
                List<String> genres = Arrays.asList(parts[2].split("\\|"));
                movies.put(id, new Movie(id, title, genres));
            }
        }
    }

    private void processRatings(String filename) throws IOException {
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            br.readLine(); // Skip header
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                int userId = Integer.parseInt(parts[0]);
                int movieId = Integer.parseInt(parts[1]);
                double rating = Double.parseDouble(parts[2]);

                User user = users.computeIfAbsent(userId, User::new);
                Movie movie = movies.get(movieId);
                
                if (rating >= R) {
                    user.addLikedMovie(movieId);
                    movie.incrementLikedBy();
                } else {
                    user.addDislikedMovie(movieId);
                }
            }
        }
    }

    private double jaccardSimilarity(User u1, User u2) {
        Set<Integer> commonLiked = new HashSet<>(u1.getLikedMovies());
        commonLiked.retainAll(u2.getLikedMovies());
        
        Set<Integer> commonDisliked = new HashSet<>(u1.getDislikedMovies());
        commonDisliked.retainAll(u2.getDislikedMovies());
        
        Set<Integer> allRated = new HashSet<>();
        allRated.addAll(u1.getLikedMovies());
        allRated.addAll(u1.getDislikedMovies());
        allRated.addAll(u2.getLikedMovies());
        allRated.addAll(u2.getDislikedMovies());

        if (allRated.isEmpty()) return 0.0;
        return (double)(commonLiked.size() + commonDisliked.size()) / allRated.size();
    }

    public List<Recommendation> generateRecommendations(int targetUserId) {
        User target = users.get(targetUserId);
        if (target == null) return Collections.emptyList();

        return movies.values().parallelStream()
            .filter(movie -> !target.hasRated(movie.getId()))
            .filter(movie -> movie.getLikedByCount() >= K)
            .map(movie -> {
                double score = 0.0;
                int likerCount = 0;
                
                for (User user : users.values()) {
                    if (user.getUserId() == targetUserId) continue;
                    if (user.getLikedMovies().contains(movie.getId())) {
                        score += jaccardSimilarity(target, user);
                        likerCount++;
                    }
                }
                
                return likerCount > 0 
                    ? new Recommendation(movie, score / likerCount, likerCount)
                    : null;
            })
            .filter(Objects::nonNull)
            .sorted((a, b) -> Double.compare(b.getProbability(), a.getProbability()))
            .limit(N)
            .collect(Collectors.toList());
    }

    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: java RecommendationEngine <userID> <movies.csv> <ratings.csv>");
            System.exit(1);
        }

        try {
            int targetUserId = Integer.parseInt(args[0]);
            long startTime = System.nanoTime();

            RecommendationEngine engine = new RecommendationEngine(args[1], args[2]);
            List<Recommendation> recommendations = engine.generateRecommendations(targetUserId);
            
            long endTime = System.nanoTime();
            double executionTimeMs = (endTime - startTime) / 1_000_000.0;

            System.out.printf("Recommendations for user #  %d:%n", targetUserId);
            recommendations.forEach(rec -> System.out.printf(
                "%s at %.4f [%d]%n",
                rec.getMovie().getTitle(),
                rec.getProbability(),
                rec.getNUsers()
            ));

            System.out.printf("%nExecution time: %.3fms%n", executionTimeMs);
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
