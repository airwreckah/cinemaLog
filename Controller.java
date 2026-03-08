
package mainprogram;


public class Controller {
    
    private TrackerManager trackerManager;
    
    public Controller() {
        trackerManager = new TrackerManager();
    }
    
    public void addMovie(String name, String genre) {
        
        if(name == null || name.isEmpty()) {
            System.out.println("Invalid movie name.");
            return;
        }
        
        trackerManager.addMovie(name, genre);
    }
    
    public void deleteMovie(String name) {
        
        if (name == null || name.isEmpty()) {
            System.out.println("Invalid movie name.");
            return;
        }
        
        trackerManager.deleteMovie(name);
    }
    
    public void searchMovie(String name) {
        trackerManager.searchMovie(name);
    }
    
}
