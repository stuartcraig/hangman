/*-------------------------------------------------------------------hangman.ado

Stuart Craig
Last updated 20150122
*/

version 8.0

/*
------------------------------------------------------ 

The main game control

------------------------------------------------------ 
*/
	cap prog drop hangman
	prog define hangman
	
		// Print instructions
		di as text "+-------------------------------------------------------------+"
		di as text "+ Welcome to Hangman! Win by guessing the correct letters. "
		di as text "+ All letters are lower case and you can only guess 1 letter"
		di as text `"+ at a time. Quit at any point by typing "quit""'
		di as text "+ "
		di as text "+ Press enter to continue"
		di as text "+-------------------------------------------------------------+", _request(anything)
	
				
		// Play until you don't want to anymore
		loc again "y"
		while "`again'"=="y" {
			hangman_gameplay
			global again 0
			while !inlist("${again}","y","n") {
				di as result "play again: y/n?", _request(again)
			}
			loc again = "${again}"
		}
		
	end

/*
------------------------------------------------------ 

Drawing the game board

------------------------------------------------------ 
*/
	cap prog drop hangman_draw
	prog define hangman_draw
		args penalty
		
		if `penalty'==0 {	
			di as result "	_____________"
			di as result "	|           |"
			di as result "	|         "
			di as result "	|         "
			di as result "	|         "
			di as result "	|"
			di as result "	|__________________"
		}
		if `penalty'==1 {
			di as result "	_____________"
			di as result "	|           |"
			di as result "	|           O"
			di as result "	|         "
			di as result "	|         "
			di as result "	|"
			di as result "	|__________________"
		}
		if `penalty'==2 {
			di as result "	_____________"
			di as result "	|           |"
			di as result "	|           O"
			di as result "	|           |"
			di as result "	|          "
			di as result "	|"
			di as result "	|__________________"
		}
		if `penalty'==3 {
			di as result "	_____________"
			di as result "	|           |"
			di as result "	|           O"
			di as result "	|          /|"
			di as result "	|          "
			di as result "	|"
			di as result "	|__________________"
		}
		if `penalty'==4 {
			di as result "	_____________"
			di as result "	|           |"
			di as result "	|           O"
			di as result "	|          /|\"
			di as result "	|          "
			di as result "	|"
			di as result "	|__________________"
		}
		if `penalty'==5 {
			di as result "	_____________"
			di as result "	|           |"
			di as result "	|           O"
			di as result "	|          /|\"
			di as result "	|          / "
			di as result "	|"
			di as result "	|__________________"
		}
		if `penalty'==6 {	
			di as error "	_____________"
			di as error "	|           |"
			di as error "	|           O"
			di as error "	|          /|\"
			di as error "	|          / \"
			di as error "	|"
			di as error "	|__________________"
		}
	end

/*
------------------------------------------------------ 

The actual game loop

------------------------------------------------------ 
*/
	cap prog drop hangman_gameplay
	prog define hangman_gameplay
		
		// Pick a word from the bank
		qui {
		preserve // can't use input because it requires an "end" statement
				 // and I don't want to require an external dataset
			clear
			qui gen w=""
			#d ;
			foreach t in		
					regression
					linear
					intercept
					coefficient
					consistency
					bias
					efficient
					efficiency
					estimator
					estimate
					estimation
					significance
					hypothesis
					confidence
					interval
					set
					unbiased
					likelihood
					frequentist
					identification
					selection
					model
					inference
					causality
					endogeneity
					exogenous
					endogenous
					test
					variance
					probit
					logistic
					quantile
					power
					truncated
					censored
					collinearity
					confounding
					heterogeneity
					simultaneity
					unobserved
					sample
					censored
					truncated
					normal
					error
					bivariate
					binomial
					alpha
					beta
					gamma
					delta
					episolon
					sigma
					distribution
					histogram
					matrix
					 {;
				set obs `=_N+1';
				qui replace w = "`t'" if _n==_N;
			};
			#d cr
			
			
			cap drop u
			gen u=runiform()
			sort u
			qui levelsof w if _n==1, local(l)
			di `l'
		restore
		}
	
		loc word `l'
		loc N = length("`word'")
		loc penalty=0 // starting at 0
		
		loc guesses ""
		
		loc round=0
		while 0==0 {
			loc ++round
			
		// Create visual gameplay
			loc penalty=length("`wrong'")/2
			hangman_draw `penalty'
			// Draw the blanks/unlocked letters
			di "" 
			di ""
			loc unlocked=0
			forval n = 1/`N' {
				loc switch=0
				foreach guess of local guesses {
					if substr("`word'",`n',1)=="`guess'" {
						di "	`guess'", _c
						loc unlocked=`unlocked'+1 // count up how many have been unlocked
						loc switch=1
						continue
					}
				}
				if `switch'==0 di "	_", _c
			}
			di ""
			di ""
			di "Incorrect guesses:"
			di "`wrong'"
			di ""
			di ""
			// How are we doing? Are we at the end?
			if length("`wrong'")/2==6 {
				di "The correct word is `word'"
				di in red "================================================="
				di in red "			GAME OVER"
				di in red "================================================="	
				qui exit
			}
			if `unlocked'==`N' {
				di in red "================================================="
				di in red "		CONGRATULATIONS! YOU WIN!!"
				di in red "================================================="
				qui exit
	
			}
			if "`again'"=="n" qui exit			
			
	// UPDATING	
			
		// Take a guess
			di "+----------------------------------------------------+"
			di "+ Round `round'"
			di "+----------------------------------------------------+"
			di "Take a guess", _request(guess)
			loc guess "${guess}"
			if "`guess'"=="quit" exit
			if "`guess'"!=lower("`guess'") {
				di in red "Oops! All guesses must be lower case"
				di as result ""
				di ""
				continue
			}
			if length("`guess'")!=1 {
				di in red "Oops! All guesses must be exatly 1 letter!"
				di as result ""
				di ""
				continue
			}
			loc letter_switch=0
			foreach l in `c(alpha)' {
				if "`guess'"=="`l'" loc letter_switch=1
			}
			if `letter_switch'==0 {
				di in red "Oops! All guesses must be letters, a-z"
				di as result ""
				di ""
				continue
			}
			
		// Have you already guessed that?
			loc repeat =0
			foreach n of local guesses {
				if "`guess'"=="`n'" loc repeat=1
			}
			if `repeat'==1 {
				di in red "Oops!! You aready guessed that!"
				di as txt ""
				continue
			}
			else {
				loc guesses "`guesses' `guess'" // if not we add it to the list
			}
				
		// Is the current guess wrong?
			loc correct=0
			forvalues n=1/`N' {
				if "`guess'"==substr("`word'",`n',1) loc correct=1
			}
			if `correct'==0 loc wrong "`wrong' `guess'"
		
		}
	end




exit






