CUDA_Matrix_Sum_Game
====================

4x4 matrix sum game


Goal = for a matrix of size 4x4 , with each location having the possible values of 0-6 (inclusive), what configurations result in the maximum number of 4 columns\rows\diagonals which sum to the value of 10?

Number of possible arrangements = 7^16 = 33,232,930,569,601.


__Running time for GTX 980 Windows 7__ =                 =__10.284 minutes__


Example output:

GPU timing= 617089

Optimal score = 10

board=

1 0 4 5
4 4 1 1
1 0 5 4
4 6 0 0

number of arrangement= 646027679200


NOTE: There is more than one 'optimal' configuration, so this code should always return a valid configuration for the global optimum, but not may not always return the exact same configuration if there is more than one. A filter can be implemented which caches the 'first'. Obviously it is possible to have all rows, columns and 4-element diagonals sum to 10, so the answer is '10'.

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-60172288-1', 'auto');
  ga('send', 'pageview');

</script>
