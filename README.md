# FilmForge🎬: A Multi-Paradigm Movie Recommendation System

This repository explores the implementation of a movie recommendation system using four distinct programming paradigms: Concurrent (Go), Object-Oriented (Java), Logical (Prolog), and Functional (Scheme).

## Overview

The core goal of this project is to recommend movies to users based on rating data. Each directory contains a standalone implementation demonstrating how the recommendation logic can be approached using different programming styles and languages.

The project utilizes datasets commonly found in recommendation system examples, including:
*   `movies.csv`: Information about movies (ID, title, genres).
*   `ratings.csv`: User ratings for movies (UserID, MovieID, rating).
*   `tags.csv` and `links.csv` for additional metadata.

## Implementations

### 1. Go - Concurrent (`Go_Concurrent`)

*   **Paradigm:** Concurrent Programming
*   **Language:** Go 🐹
*   **Key Files:**
    *   `projectMovieRec.go`: Main Go program file containing the recommendation logic.
    *   `ratings.csv`, `movies.csv`: Data files used.
    *   `recommendations_user_*.txt`: Example output files.
*   **Description:** This implementation leverages Go's concurrency features (goroutines, channels) to potentially speed up the recommendation process, perhaps by processing users or movies in parallel.

### 2. Java - Object-Oriented (`Java_OOP`)

*   **Paradigm:** Object-Oriented Programming
*   **Language:** Java ☕
*   **Key Files:**
    *   `RecommendationEngine.java`: Core class for recommendation logic.
    *   `Movie.java`, `User.java`, `Recommendation.java`: Model classes representing entities.
    *   `ratings.csv`, `movies.csv`, `tags.csv`, `links.csv`: Data files used.
    *   `run.txt`: contains instructions or scripts for running.
    *   `Test_results.txt`, `rec44.txt`: Example output or test results.
*   **Description:** A classic OOP approach, encapsulating data and behavior within classes like `Movie`, `User`, and a central `RecommendationEngine`.

### 3. Prolog - Logical (`Prolog_Logical`)

*   **Paradigm:** Logical Programming
*   **Language:** Prolog 💡
*   **Key Files:**
    *   `projectMovie.pl`: Prolog source file containing facts and rules for recommendations.
    *   `run.txt`: contains instructions or queries for running.
    *   `output.txt`: Example output.
*   **Description:** This version uses Prolog's declarative nature. Recommendations are derived by defining facts (e.g., user ratings, movie genres) and rules (e.g., similarity metrics, recommendation criteria) and then querying the system.

### 4. Scheme - Functional (`Scheme_Functional`)

*   **Paradigm:** Functional Programming
*   **Language:** Scheme λ
*   **Key Files:**
    *   `projetMovie`: Scheme source file (assuming this is the main script).
    *   `output.txt`: Example output.
*   **Description:** This implementation emphasizes immutability, recursion, and higher-order functions to process the data and generate recommendations.

## Running the Implementations

Please refer to the specific subdirectories (`Go_Concurrent`, `Java_OOP`, `Prolog_Logical`, `Scheme_Functional`) for detailed instructions or scripts (`run.txt`) on how to compile and run each version. You will need the respective language compilers/interpreters installed (Go, JDK, Prolog interpreter, Scheme interpreter).

--- 
