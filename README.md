# igor-MinTest
A minimal unit testing library for Igor Pro

## Features
 - Only four public functions
    - eq_var
    - eq_str
    - eq_wave
    - eq_text
 - Run tests from the menu bar
 - Jump to failed lines from the menu bar
 
## Example 
```
Function test()
  setup() // define and call setup function if you need it 

  eq_var(word_count("it is a test"), 4)
  eq_str(hello_world(), "Hello, world!")
  eq_wave(fibonacci(5), {1,1,2,3,5})
  eq_text(fizzbuzz(5), {"1","2","Fizz","4","Buzz"})
  
  teardown() // define and call teardown function if you need it 
End
```
