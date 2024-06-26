# Approximate Nearest One Detector
This is a Dean's Research Award project that I worked on in the 2024 Winter semester under the supervision of Dr. Jie Han. I won the Student's Choice for Outstanding Research award at the Dean's Research Symposium on April 11, 2024.

## Overview
Approximate computing is an area of computer engineering that deals with the optimization of hardware while achieving accurate results. My research dealt with an area of approximate computing called logarithmic multiplication. This involves breaking down the multiplication operation into a series of instructions that a computer can understand. A product of two n-bit numbers can be computed using the additive and bit shifting properties of binary arithmetic.

The textbook model of the logarithmic multiplier is the [Mitchell Multiplier](https://ieeexplore.ieee.org/document/5219391) (MITCHEL) model which utilizes the leading one bit and a [barrel shifter](https://en.wikipedia.org/wiki/Barrel_shifter) to compute an approximate product. The downsides of this is that approximate product is alway less than equal to the actual product and thus results in a one-sided error distribution.

One of the more recent models of the logarithmic multipliers proposed by one of Dr. Han's students, Mohammad Saeed Ansari, solves this accuracy issue by using a double-sided error distribution. This [Improved Logarithmic Multiplier](https://ieeexplore.ieee.org/abstract/document/9086744) (ILM) model uses a nearest one rather than a leading one to determine the final product, which allows the product to achieve a higher mean accuracy.

My work deals specifically with designing a nearest one detector (NOD) that can achieve similar results within the context of the improved logarithmic detector. I designed both an exact nearest one detector (as a stepping stone) and an approximate nearest one detector using MATLAB for the behavioural simulations and Verilog for the register transfer level designs. I was inspired by [this article](http://www.ece.ualberta.ca/~jhan8/publications/1570528628.pdf) (also by Ansari!) about approximating the leading bits with pre-set bits. I decided noticed how in many leading one detector designs, bits were processed simultaneously in 4-bit groups. This led me to use similar concepts in developing my designs for the nearest one detector (Carry NOD, Base NOD).

## Results
I simulated the error metrics for all three designs (MITCHELL, ILM with exact, ILM with approximate) in MATLAB and Erjing Luo (Master's student with Dr. Han) helped me synthesize my Verilog designs using Synopsys Design Compiler. In conclusion, the approximate designs had a worse power-delay product (21.7%) than the exact designs, but yielded a lower area (18.7%). Both ILMs were significantly more accurate (exact 27.9%, approx 19.2%) than the textbook MITCHEL model. Check out the full results in my research poster ```DRA_zhren_ApproxNOD.pdf```.

## Acknowledgements
I would like to acknowledge Dr. Jie Han for supervising my project. I would also like to acknowledge Erjing Luo for helping me synthesize my designs. I would also like to thank RatkoFri and their repository [MulApprox](https://github.com/RatkoFri/MulApprox), which I used as a basis to code my Verilog designs for the MITCHEL and ILM models.

Note: An acknowledgement of RatkoFri's MulApprox repository was omitted from the original research poster. Added May 29, 2024 to ```DRA_zhren_ApproxNOD_updated.pdf```.
