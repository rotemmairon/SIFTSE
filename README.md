# SIFTSE

This is a Matlab implementation for the semantic (HMM-based) component in a model for human scanpath estimation. The complete model is presented in the paper "Semantically-based human scanpath estimation with hmms" (Liu, Huiying, Dong Xu, Qingming Huang, Wen Li, Min Xu, and Stephen Lin, In ICCV 2013). The code has been tested on the datasets JUDD and NUSEF, using the Smith-Waterman sequence alignment algorithm. The results are somewhat different than those reported in the paper (see below). However, these differences may be explained by the following reasons:
 <ul>
  <li>In the original implementation, the observation vectors (Bags of Visual Words) are normalized to sum up to 1. In this implementation, these vectors are not normalized as we could not find any justification for this operation.</li>
  <li>Tea</li>
  <li>Milk</li>
</ul> 

- 
- 

<p align="center">
  <img src="../master/SIFTSE_Results.png" width="350" title="SIFTSE Results">
</p>
