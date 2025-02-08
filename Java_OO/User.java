import java.util.HashSet;
import java.util.Set;

public class User {
    private final int userId;
    private final Set<Integer> likedMovies;
    private final Set<Integer> dislikedMovies;

    public User(int userId) {
        this.userId = userId;
        this.likedMovies = new HashSet<>();
        this.dislikedMovies = new HashSet<>();
    }

    public int getUserId() { return userId; }
    public Set<Integer> getLikedMovies() { return likedMovies; }
    public Set<Integer> getDislikedMovies() { return dislikedMovies; }
    public void addLikedMovie(int movieId) { likedMovies.add(movieId); }
    public void addDislikedMovie(int movieId) { dislikedMovies.add(movieId); }
    public boolean hasRated(int movieId) { 
        return likedMovies.contains(movieId) || dislikedMovies.contains(movieId); 
    }
}