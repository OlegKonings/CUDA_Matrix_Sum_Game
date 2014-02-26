CUDA_Matrix_Sum_Game
====================

4x4 matrix sum game


Goal= for a matrix of size 4x4 , with each location having the possible values of 0-6 (inclusive), what configurations result in the maximum number of 4 columns\rows\diagonals which sum to the value of 10 ?

Number of possible arrangements = 7^16 = 33,232,930,569,601 .

__Running time for Tesla K20c Windows 7__ = 2648761 ms or __44.14 minutes__.

Example output:

GPU timing= 2648671

Optimal score = 10
 
board= 

1  0  4  5

4  4  1  1 

1  0  5  4 

4  6  0  0 

number of arrangement = 646027679200


NOTE: There is more than one 'optimal' configuration, so this code should always return a valid configuration for the global optimum, but not may not always return the exact same configuration if there is more than one. A filter can be implemented which caches the 'first'.

 <script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-43459430-1', 'github.com');
  ga('send', 'pageview');

</script>

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/fe79efa82fdf02de1c921831f26f39e3 "githalytics.com")](http://githalytics.com/OlegKonings/CUDA_Matrix_Sum_Game)
