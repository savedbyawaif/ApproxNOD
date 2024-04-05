fprintf('\nStart of Program\n');

x = 0:255;
x_values = zeros(size(x));
NOD_values = zeros(size(x));
ANOD_values = zeros(size(x));

for i=1:1:255
    fprintf("%d: ", i);
    fprintf(dec2bin(i,8));
    fprintf(">>>")
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

% %logarithmic plot
% for i=1:1:256
%     NOD_values(i) = log2(NOD(i-1));
%     ANOD_values(i) = log2(ApproxNOD(i-1));
%     x_values(i) = i-1;
%     fprintf("\n");
% end
% plot(x_values, NOD_values, 'o-');
% hold on;
% plot(x_values, ANOD_values, 's-');
% 
% xlabel('x values');
% ylabel('NOD values');
% title('log values');
% grid on;

%Exact
function decimalNOD = NOD(binaryNumber)
    bitnod = zeros(1,9);
    bitValue = zeros(1,8);
    for k=8:-1:1
        bitValue(9-k) = bitget(binaryNumber,k);
    end
    bit7to4OR = or(or(bitValue(1),bitValue(2)),or(bitValue(3),bitValue(4)));
    bit3to2AND = and(bitValue(5), bitValue(6));
    bit7to4ip = or(bit3to2AND, bit7to4OR);
    bit3to0OR = or(or(bitValue(5),bitValue(6)),or(bitValue(7),bitValue(8)));

    outputvar = twobitLOD(bit7to4ip, bit3to0OR);
    bitnod(1:5) = set2to1mux(00000, CarryNOD(binaryNumber), outputvar(1));
    bitnod(6:9) = set2to1mux(0000, BaseNOD(binaryNumber), outputvar(2));
    decimalNOD = bin2dec(num2str(bitnod));
end

function decimalANOD = ApproxNOD(binaryNumber)
    bitanod = zeros(1,9);
    bitValue = zeros(1,8); %change
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
    bitanod(1:5) = set2to1mux(00000, CarryNOD(binaryNumber), bit7to4ip);
    bitanod(6:9) = set2to1mux(bits4zero, 0000, bit7to4ip);
    decimalANOD = bin2dec(num2str(bitanod));
end