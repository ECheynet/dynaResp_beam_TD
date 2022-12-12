# dynaResp_beam_TD
The dynamic displacement response of a line-like structure to an uncorrelated Gaussian white noise input is computed in the time domain.

[![View Dynamic response of a line-like structure to a random load on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://se.mathworks.com/matlabcentral/fileexchange/66016-dynamic-response-of-a-line-like-structure-to-a-random-load)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3965470.svg)](https://doi.org/10.5281/zenodo.3965470)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)


[![Donation](https://camo.githubusercontent.com/a37ab2f2f19af23730565736fb8621eea275aad02f649c8f96959f78388edf45/68747470733a2f2f77617265686f7573652d63616d6f2e636d68312e707366686f737465642e6f72672f316339333962613132323739393662383762623033636630323963313438323165616239616439312f3638373437343730373333613266326636393664363732653733363836393635366336343733326536393666326636323631363436373635326634343666366536313734363532643432373537393235333233303664363532353332333036313235333233303633366636363636363536353264373936353663366336663737363737323635363536653265373337363637)](https://www.buymeacoffee.com/echeynet)

## Content

The submission contains:

- the function dynaResp_TD that computes the time history of the displacement response of a line-like structure to a given load.

- The function eigenModes.m used here to compute the mode shapes and eigenfrequency of a cantilever beam

- The file bridgeModalProperties.mat that loads the mode-shapes and eigenfrequency of a single span suspension bridge.

- 2 example files Example1.mlx and Example2.mlx

To keep the analysis as simple as possible, the structure has only one type of motion. No modal coupling is introduced and no added mass, stiffness or damping is included.

Any comments, suggestion or question is welcomed.

## Illustration

![Illustration](illustration.png){:height="75%" width="75%"}
