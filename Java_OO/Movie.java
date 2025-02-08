import java.util.List;

public class Movie {
    private final int id;
    private final String title;
    private final List<String> genres;
    private int likedByCount;

    public Movie(int id, String title, List<String> genres) {
        this.id = id;
        this.title = title;
        this.genres = genres;
        this.likedByCount = 0;
    }

    public int getId() { return id; }
    public String getTitle() { return title; }
    public List<String> getGenres() { return genres; }
    public int getLikedByCount() { return likedByCount; }
    public void incrementLikedBy() { likedByCount++; }
}