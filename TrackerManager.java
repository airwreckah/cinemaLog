
package mainprogram;

import java.util.Scanner;

public class TrackerManager {
    
    private ArrayList<Media> movieList;
    
    public TrackerManager() {
        movieList = new ArrayList<>();
    }
    
    public void addMovie(String name, String genre) {
        
        Media movie = new Media(name, genre);
        movieList.add(movie);
        
        System.out.println(name + " added.");
    }
    
    public void deleteMovie(String name) {
        
        for(Media m : movieList) {
            if(m.getName().equalsIgnoreCase(name)) {
                movieList.remove(m);
                System.out.println(name + " removed.");
                return;
            }
        }
    }
    
}
