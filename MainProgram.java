
package mainprogram;


public class MainProgram {

    
    public static void main(String[] args) {
        
        Controller controller = new Controller();
        
        controller.addMovie("The Matrix", "Sci-Fi Action");
        controller.addMovie("Fight Club", "Psychological Thriller");
        
        controller.searchMovie("The Matrix");
        
        controller.deleteMovie("Fight Club");
    }
    
}
