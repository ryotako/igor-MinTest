# igor-MinTest
A minimal library for unit testing

## Features
 - Only five public functions
    - eq_var
    - eq_str
    - eq_wave
    - eq_text
    - run_test
 - Jumpping to failed lines from the menu bar
 - Retrying tests from menu bar
 
## Example 
```
Function test()
  setup() // define and call setup function if you need it 

  eq_var(word_count("it is a test"), 4)
  eq_str(hello_world(), "Hello, world!")
  eq_wave(fibonacci(5), {1,1,2,3,5})
  eq_text(fizzbuzz(5), {"1","2","Fizz",4,"Buzz"})
  
  if(!eq_var(ultimate_question(),42)) // return value is 1 (pass) or 0 (fail) 
    Abort
  endif
  
  teardown() // define and call teardown function if you need it 
End
```
