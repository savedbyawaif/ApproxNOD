fprintf('\nStart of Program\n');

x = 0:255;
x_values = zeros(size(x));
NOD_values = zeros(size(x));
ANOD_values = zeros(size(x));

for i=1:1:256
    %fprintf("%d: ", i);
    %fprintf(dec2bin(i,8));
    %fprintf(">>>")
    NOD_values(i) = NOD(i-1);
    ANOD_values(i) = ApproxNOD(i-1);
    x_values(i) = i-1;
    fprintf("\n");
end

plot(x_values, NOD_values, 'o-');
hold on;
plot(x_values, ANOD_values, 's-');

xlabel('x values');
ylabel('NOD values');
title('NOD Values vs. Actual Numbers');
grid on;

%Exact
function decimalNOD = NOD(binaryNumber)
    bitnod = zeros(1,8);
    bitValue = zeros(1,8);
    for k=8:-1:1
        bitValue(9-k) = bitget(binaryNumber,k);
    end
    bit7to4OR = or(or(bitValue(1),bitValue(2)),or(bitValue(3),bitValue(4)));
    bit3to2AND = and(bitValue(5), bitValue(6));
    bit7to4ip = or(bit3to2AND, bit7to4OR);
    bit3to0OR = or(or(bitValue(5),bitValue(6)),or(bitValue(7),bitValue(8)));

    outputvar = twobitLOD(bit7to4ip, bit3to0OR);
    bitnod(1:4) = set2to1mux(0000, CarryNOD(binaryNumber), outputvar(1));
    bitnod(5:8) = set2to1mux(0000, BaseNOD(binaryNumber), outputvar(2));
   % fprintf("%d%d%d%d%d%d%d%d", bitnod(1), bitnod(2), bitnod(3), bitnod(4), bitnod(5), bitnod(6), bitnod(7), bitnod(8));
    binaryString = num2str(bitnod);
    decimalNOD = bin2dec(binaryString);
end

function decimalANOD = ApproxNOD(binaryNumber)
    bitanod = zeros(1,8);
    bitValue = zeros(1,8);
    bits4zero = zeros(1,4);
    bits4zero(1) = 0;
    bits4zero(2) = 1;
    bits4zero(3) = 0;
    bits4zero(4) = 0;
    for k=8:-1:1
        bitValue(9-k) = bitget(binaryNumber,k);
    end
    bit7to4OR = or(or(bitValue(1),bitValue(2)),or(bitValue(3),bitValue(4)));
    bit3to2AND = and(bitValue(5), bitValue(6));
    bit7to4ip = or(bit3to2AND, bit7to4OR);
    bitanod(1:4) = set2to1mux(0000, CarryNOD(binaryNumber), bit7to4ip);
    bitanod(5:8) = set2to1mux(bits4zero, 0000, bit7to4ip);
    %fprintf("%d%d%d%d%d%d%d%d", bitanod(1), bitanod(2), bitanod(3), bitanod(4), bitanod(5), bitanod(6), bitanod(7), bitanod(8));
    binaryString = num2str(bitanod);
    decimalANOD = bin2dec(binaryString);
end

%top 4 bits
function bits7to4 = CarryNOD(input1)
    bitValue = zeros(1,6); 
    bits7to4 = zeros(1,4);
    for k=8:-1:3
        bitValue(9-k) = bitget(input1,k);
    end
    combbit1 = or(bitValue(1), and(bitValue(2),bitValue(3)));
    combbit2 = or(bitValue(2), and(bitValue(3),bitValue(4)));
    combbit3 = or(bitValue(3), and(bitValue(4),bitValue(5))); 
    combbit4 = or(bitValue(4), and(bitValue(5),bitValue(6)));

    ctrl1 = set2to1mux(1, 0, combbit1);
    ctrl2 = set2to1mux(ctrl1, 0, combbit2);
    ctrl3 = set2to1mux(ctrl2, 0, combbit3);

    bits7to4(1) = combbit1;
    bits7to4(2) = and(combbit2, ctrl1);
    bits7to4(3) = and(combbit3, ctrl2);
    bits7to4(4) = and(combbit4, ctrl3);

    %fprintf('Bits 7 to 4: ');
    %fprintf('%d', bitValue);
    %fprintf('\n');
    %fprintf('%d', bits7to4);
    %fprintf('\n');
end

%bottom 4 bits
function bits3to0 = BaseNOD(input1)
    %fprintf('Bits 3 to 0: '); 
    bitValue = zeros(1,4);
    bits3to0 = zeros(1,4);
    for k=4:-1:1
        bitValue(5-k) = bitget(input1,k);
    end

    combbit1 = or(bitValue(1), and(bitValue(2),bitValue(3)));
    combbit2 = or(bitValue(2), and(bitValue(3),bitValue(4)));
    
    ctrl1 = set2to1mux(1, 0, combbit1);
    ctrl2 = set2to1mux(ctrl1, 0, combbit2);
    ctrl3 = set2to1mux(ctrl2, 0, bitValue(3));

    bits3to0(1) = combbit1;
    bits3to0(2) = and(combbit2, ctrl1);
    bits3to0(3) = and(bitValue(3), ctrl2);
    bits3to0(4) = and(bitValue(4), ctrl3);

    %fprintf('%d', bitValue);
    %fprintf('\n');
    %fprintf('%d', bits7to4);
    %fprintf('\n');
end

%control bits - 2bit LOD
function bitsz1to0 = twobitLOD(input1, input2)
    bitsz1to0 = zeros(1,2);
    ctrl1 = set2to1mux(1, 0, input1);
    bitsz1to0(1) = input1;
    bitsz1to0(2) = and(input2, ctrl1);
    %fprintf('%d', bitsz1to0);
end

%mux 2to1
function output = set2to1mux(D_0, D_1, select_line)
    if(select_line==0)
        output = D_0;
    else
        output = D_1;
    end
end