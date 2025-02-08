public class Recommendation {
    private final Movie movie;
    private final double probability;
    private final int nUsers;

    public Recommendation(Movie movie, double probability, int nUsers) {
        this.movie = movie;
        this.probability = probability;
        this.nUsers = nUsers;
    }

    public Movie getMovie() { return movie; }
    public double getProbability() { return probability; }
    public int getNUsers() { return nUsers; }
}