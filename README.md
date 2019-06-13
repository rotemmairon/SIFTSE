# SIFTSE

This repo contains a Matlab implementation for the semantic (HMM-based) component in a model for human scanpath estimation. The complete model is presented in the paper "Semantically-based human scanpath estimation with hmms" (Liu, Huiying, Dong Xu, Qingming Huang, Wen Li, Min Xu, and Stephen Lin, In ICCV 2013). The code has been tested on the datasets JUDD and NUSEF, using the Smith-Waterman sequence alignment algorithm. The results are somewhat different than those reported in the paper (see below). However, these differences may be explained by the following reasons:
 <ul>
  <li>In the original implementation, the observation vectors (Bags of Visual Words) are normalized to sum up to 1. In this implementation, these vectors are not normalized as we could not find any justification for this operation.</li>
  <li>The two datasets NUSEF-face and NUSEF-portrait, on which the implementation has been tested (see below), were manually extracted from the NUSEF dataset according to the description of what should be their content (For more details, see Ramanathan, Subramanian et al. “An Eye Fixation Database for Saliency Detection in Images.” ECCV 2010).
</ul>

The HMM has been tested with the following set of meta-parameters: codebook size = 10, 7 hidden states, and a scanpath length of 20. These parameters were also selected in the original paper following a parameter search. Below is a comparison between the performance of the HMM component of the two models (yellow bars).

<p align="center">
  <img src="../master/SIFTSE_Results.png" width="350" title="SIFTSE Results">
</p>

For questions, remarks or more details, please contact: rotem.mairon@gmail.com.
