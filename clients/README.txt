Often in mcollective, sequential execution is required.
So this is one way of doing it. It performs a broadcast discovery 
and then performs a custom request to each of the discovered nodes
