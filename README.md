# ApproxNOD: Approximate Nearest One Detector
ApproxNOD is an 8-bit approximate nearest detector designed for the Improved Logarithmic Multiplier (ILM) model. This project explores the tradeoffs of using approximate logic to reduce hardware area while maintaining multiplication accuracy compared with the conventional Mitchell multiplier model.

This is a Dean's Research Award project that I worked on in the 2024 Winter semester under the supervision of Dr. Jie Han. I won the Student's Choice for Outstanding Research award at the Dean's Research Symposium on April 11, 2024.

## Overview
Approximate computing is a hardware design approach that trades small, controlled errors for hardware improvements in metrics such as power, delay, and area. This project focuses on logarithmic multiplication, which uses leading-bit detection, addition, and bit shifting to calculate the product of two binary numbers.

The textbook model of the logarithmic multiplier is the [Mitchell Multiplier](https://ieeexplore.ieee.org/document/5219391) (MITCHEL) model, which utilizes the leading one bit and a [barrel shifter](https://en.wikipedia.org/wiki/Barrel_shifter) to compute an approximate product. However, this approach yields a one-sided error distribution, as the approximate product is always less than or equal to the actual product.

One of the more recent models of the logarithmic multipliers proposed by Mohammad Saeed Ansari solves this accuracy issue by using a double-sided error distribution. This [Improved Logarithmic Multiplier](https://ieeexplore.ieee.org/abstract/document/9086744) (ILM) model uses a nearest one rather than a leading one to determine the final product, which allows the product to achieve a higher mean accuracy.

This project implements and evaluates nearest-one detector architectures for the ILM model. Each design was simulated in MATLAB for error analysis and implemented in Verilog RTL for synthesis. The project repository includes the following:
- An exact nearest-one detector used as a reference design
- Approximate nearest-one detector architectures

The approximate NOD designs were inspired by previous work on approximating leading-bit detection using preset bits. A key concept was to process bits in 4-bit groups simultaneously, similar to many leading one-detector designs.

## Repository Structure

```text
ApproxNOD/
├── Behavioural Simulations/         # MATLAB error analysis
├── Verilog/                         # RTL implementations
├── Logic Diagrams/                  # Architecture and logic diagrams
├── Documentation/                   # Progress report and supporting documentation
├── DRA_zhren_ApproxNOD.pdf          # Research poster
├── DRA_zhren_ApproxNOD_updated.pdf  # Updated Research poster
├── README.md
└── LICENSE
```

## Results
I simulated the error metrics for all three designs (MITCHELL, ILM with exact, ILM with approximate) in MATLAB, and Erjing Luo (a Master's student with Dr. Han) helped me synthesize my Verilog designs using Synopsys Design Compiler. In conclusion, the approximate designs had a worse power-delay product (21.7%) than the exact designs, but yielded a lower area (18.7%). Both ILMs were significantly more accurate (exact: 27.9%; approx.: 19.2%) than the textbook MITCHEL model.

Check out the full results in my research poster:
- ```DRA_zhren_ApproxNOD.pdf```.

## Tools Used
- MATLAB for behavioural modelling and error analysis
- Verilog for RTL implementation
- Synopsys Design Compiler for synthesis

## Acknowledgements
I would like to acknowledge Dr. Jie Han for supervising my project. I would also like to acknowledge Erjing Luo for helping me synthesize my designs. I would also like to thank RatkoFri and their repository [MulApprox](https://github.com/RatkoFri/MulApprox), which I used as a basis to code my Verilog designs for the MITCHEL and ILM models.

Note: An acknowledgement of RatkoFri's MulApprox repository was omitted from the original research poster. Added May 29, 2024, to ```DRA_zhren_ApproxNOD_updated.pdf```.
