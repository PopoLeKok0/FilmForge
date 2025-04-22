:- dynamic user/3, movie/2.
% K - Minimum number of users who need to like a movie for recommendation
min_liked(10).
% R - Rating threshold to consider a movie as liked
liked_th(3.5).
% N - Number of recommendations to provide
number_of_rec(20).

% read_users(Filename): reads users and their ratings from a CSV file
% and stores them as user/3 facts
read_users(Filename) :-
    csv_read_file(Filename, Data), assert_users(Data).

% assert_users(List): recursively processes rows from the ratings file
% and creates user/3 facts for each user
assert_users([]).
assert_users([row(U,_,_,_) | Rows]) :- \+number(U),!, assert_users(Rows).
assert_users([row(U,M,Rating,_) | Rows]) :- number(U),\+user(U,_,_), liked_th(R), Rating>=R,!,assert(user(U,[M],[])), assert_users(Rows).
assert_users([row(U,M,Rating,_) | Rows]) :- number(U),\+user(U,_,_), liked_th(R), Rating<R,!,assert(user(U,[],[M])), assert_users(Rows).
assert_users([row(U,M,Rating,_) | Rows]) :- number(U), liked_th(R), Rating>=R, !, retract(user(U,Liked,NotLiked)), assert(user(U,[M|Liked],NotLiked)), assert_users(Rows).
assert_users([row(U,M,Rating,_) | Rows]) :- number(U), liked_th(R), Rating<R, !, retract(user(U,Liked,NotLiked)), assert(user(U,Liked,[M|NotLiked])), assert_users(Rows).

% read_movies(Filename): reads movie data from a CSV file
% and stores them as movie/2 facts
read_movies(Filename) :-
    csv_read_file(Filename, Rows), assert_movies(Rows).

% assert_movies(List): recursively processes rows from the movies file
% and creates movie/2 facts for each movie
assert_movies([]).
assert_movies([row(M,_,_) | Rows]) :- \+number(M),!, assert_movies(Rows).
assert_movies([row(M,Title,_) | Rows]) :- number(M),!, assert(movie(M,Title)), assert_movies(Rows).

% display_first_n(List, N): displays the first N elements of the list
% used to show top N recommendations
display_first_n(_, 0) :- !.
display_first_n([], _) :- !.
display_first_n([H|T], N) :-
    writeln(H), 
    N1 is N - 1,
    display_first_n(T, N1).

% similarity(User1, User2, Sim): calculates the similarity between two users
% using the Jaccard index
similarity(User1, User2, Sim) :-
    user(User1, Liked1, NotLiked1),
    user(User2, Liked2, NotLiked2),
    intersection(Liked1, Liked2, CommonLiked),
    intersection(NotLiked1, NotLiked2, CommonNotLiked),
    length(CommonLiked, NCommonLiked),
    length(CommonNotLiked, NCommonNotLiked),
    union(Liked1, Liked2, UnionLiked),
    union(NotLiked1, NotLiked2, UnionNotLiked),
    union(UnionLiked, UnionNotLiked, AllMovies),
    length(AllMovies, NAllMovies),
    Numerator is NCommonLiked + NCommonNotLiked,
    (NAllMovies > 0 ->
        Sim is Numerator / NAllMovies
    ;
        Sim is 0.0
    ).

% seen(User, Movie): determines if a user has seen a movie
seen(User, Movie) :-
    user(User, Liked, NotLiked),
    (member(Movie, Liked); member(Movie, NotLiked)).

% liked(Movie, Users, UserWhoLiked): extracts the users in the list who liked the movie
liked(Movie, Users, UserWhoLiked) :-
    findall(U, (member(U, Users), user(U, Liked, _), member(Movie, Liked)), UserWhoLiked).

% prob(User, Movie, Prob): calculates the probability that the user will like the movie
prob(User, Movie, Prob) :-
    % Check if the user has already seen the movie
    (seen(User, Movie) ->
        Prob = 0.0
    ;
        % Find all users who liked the movie
        findall(OtherUser, (user(OtherUser, Liked, _), OtherUser \= User, member(Movie, Liked)), UsersWhoLiked),
        length(UsersWhoLiked, NumLiked),
        min_liked(K),
        (NumLiked >= K ->
            % Calculate score based on similarities
            findall(Sim, (member(OtherUser, UsersWhoLiked), similarity(User, OtherUser, Sim)), Similarities),
            sum_list(Similarities, Score),
            (NumLiked > 0 ->
                Prob is Score / NumLiked
            ;
                Prob is 0.0
            )
        ;
            Prob is 0.0
        )
    ).

% prob_movies(User, Movies, Recs): generates (MovieTitle, Prob) pairs for all movies in the list
prob_movies(User, [], []).
prob_movies(User, [MovieId|Rest], [(Title, Prob)|RestRecs]) :-
    movie(MovieId, Title),
    prob(User, MovieId, Prob),
    prob_movies(User, Rest, RestRecs).

% recommendations(User): generates movie recommendations for a user
recommendations(User) :-
    setof(M, L^movie(M, L), Ms),  % generate list of all movies
    prob_movies(User, Ms, Rec),   % compute probabilities for all movies
    sort(2, @>=, Rec, Rec_Sorted), % sort by descending probabilities
    number_of_rec(N),
    display_first_n(Rec_Sorted, N). % display the result

% init: initializes the system by loading users and movies data
init :- read_users('ratings.csv'), read_movies('movies.csv').

% test(N): predefined test cases to verify the implementation
test(1):- similarity(33,88,S1), 291 is truncate(S1 * 10000),similarity(44,55,S2), 138 is truncate(S2 * 10000).
test(2):- prob(44,1080,P1), 122 is truncate(P1 * 10000), prob(44,1050,P2), 0 is truncate(P2).
test(3):- liked(1080, [28, 30, 32, 40, 45, 48, 49, 50], [28, 45, 50]).
test(4):- seen(32, 1080), \+seen(44, 1080).
test(5):- prob_movies(44,[1010, 1050, 1080, 2000],Rs), length(Rs,4), display(Rs).

% test_all: runs all test cases and reports results
test_all :- 
    forall(between(1, 5, N),
           (write('Running test '), write(N), write(': '),
            (test(N) -> writeln('Passed') ; writeln('Failed')))).

% generate_output: generates recommendations for users 44, 55, and 66
% and saves them to output.txt
generate_output :-
    tell('output.txt'),
    writeln('% Recommendations for user 44'),
    recommendations(44),
    nl,
    writeln('% Recommendations for user 55'),
    recommendations(55),
    nl,
    writeln('% Recommendations for user 66'),
    recommendations(66),
    told.
