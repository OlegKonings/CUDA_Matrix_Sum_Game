CUDA_Matrix_Sum_Game
====================

4x4 matrix sum game, or "Magic Square" problem implemented in CUDA. 

Goal = for a matrix of size 4x4 , with each location having the possible values of 0-6 (inclusive), what configurations result in the maximum number of 4 columns\rows\diagonals which sum to the value of 10?

Number of possible arrangements = 7^16 = __33,232,930,569,601__

__GPU approach:__ Generate every distinct 33+ trillion possible game board arrangement, evaluate, cache the 'best' and return that answer plus a board arrangement reposible for that answer.
(there may be more than one configuration which achieves the objective)

Compile as 5.2 with --use_fast_math and max_register=32

Full running time for single 1.1 Ghz GTX Titan X Windows 7                  = __181.9 seconds__


Example output:

GPU timing= 197945 ms

Optimal score = 10

board=

1  0  4  5

4  4  1  1

1  0  5  4

4  6  0  0

number = 646027679200


NOTE: There is more than one 'optimal' configuration, so this code should always return a valid configuration for the global optimum, but not may not always return the exact same configuration if there is more than one. A filter can be implemented which caches the 'first'. Obviously it is possible to have all rows, columns and 4-element diagonals sum to 10, so the answer is '10'.

Stay tuned for 2 GTX 980 GPU solution which breaks the 3 minute mark!

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-60172288-1', 'auto');
  ga('send', 'pageview');

</script>

see the dual-gpu version here:

https://sites.google.com/site/gamingrigvsquantumcomputer/
