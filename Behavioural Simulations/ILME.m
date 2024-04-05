% Define the range of x and y values
x_range = 0:255;
y_range = 0:255;

% Initialize arrays to store results
errors = zeros(length(x_range), length(y_range));
final_values = zeros(length(x_range), length(y_range));
product_values = zeros(length(x_range), length(y_range));
mre_values = zeros(length(x_range), length(y_range));

% Calculate final values, product values, and errors
for i = 1:length(x_range)
    for j = 1:length(y_range)
        x = x_range(i);
        y = y_range(j);

        % Calculate final value
        final = ILM(x,y);

        % Calculate the product of x and y
        product_xy = x * y;

        % Calculate the error
        error = final - product_xy;
        if product_xy == 0
            mre = 0;
        else
            mre = error / product_xy;
        end
        mre_values(i, j) = mre;

        % Store values in arrays
        errors(i, j) = error;
        final_values(i, j) = final;
        product_values(i, j) = product_xy;

    end
end

overall_mre = mean(mre_values(:));
disp(['Overall Mean Relative Error (MRE): ' num2str(overall_mre)]);

% Plot the 3D graph
figure;
surf(x_range, y_range, errors);
xlabel('x');
ylabel('y');
zlabel('Error');
title('Error Between Final Value and Product of x and y');
colorbar; % Display color bar for error values
% Define the grid for interpolation (increased resolution)



% uncomment to test for individual values
% x = 1;
% y = 2;
% final = aILM(x,y);
% fprintf("%d\n", x*y);
% fprintf("%d", final);
% error = final - x*y;

%Approximate improved logarithmic multiplier
function final = ILM(x,y)
    input1 = dec2bin(x, 8);
    input2 = dec2bin(y, 8);
   
    input_1nod = NOD(bin2dec(input1));
    
    input_peout1 = PriorityEncoder8(input_1nod);
    
    input_2nod = NOD(bin2dec(input2));
    
    input_peout2 = PriorityEncoder8(input_2nod);
    % Add an extra '0' bit at the front of input1 and input2
    input1_with_sign = ['0', input1]; % concatenate '0' to the beginning
    input2_with_sign = ['0', input2]; % concatenate '0' to the beginning

    % result1 = subtractor8(input1_with_sign, input_1nod);
    % result2 = subtractor8(input2_with_sign, input_2nod);

    % disp(input1_with_sign);
    % disp(input_1nod);
    res1 = bin2dec(input1_with_sign) - bin2dec(input_1nod);
    res2 = bin2dec(input2_with_sign) - bin2dec(input_2nod);

    code_sum = dec2bin(bin2dec(input_peout2) + bin2dec(input_peout1),4);
    shifted16 = Decoder16(bin2dec(code_sum));

    % input1_abs = dec2bin(bitxor(x, bin2dec(repmat(input1(1), 1, 8))), 8); %get absolute value
    % input2_abs = dec2bin(bitxor(y, bin2dec(repmat(input2(1), 1, 8))), 8); %get absolute value
    
    %pp1_decimal = bitshift(bin2dec(result1), bin2dec(input_peout2));
    %pp1_binary = dec2bin(pp1_decimal, 16);
    %pp2_decimal = bitshift(bin2dec(result2), bin2dec(input_peout1));
    %pp2_binary = dec2bin(pp2_decimal, 16);

    % Calculate temp_pp (assuming result1 and result2 are binary strings)
    pp1 = res1 * 2^(bin2dec(input_peout2));
    pp2 = res2 * 2^(bin2dec(input_peout1));
    
    %shifted16_with_bottom_bits = bitor(bitshift(shifted16, 4), bin2dec('1010'))

    temp_pp = shifted16 + pp1 + pp2;
    % disp(pp1);
    % disp(pp2);
    if x * y == 0
        final = 0;
    else
        final = temp_pp;
    end

    % fprintf("ip1 value: ");
    % disp(input1);
    % fprintf("NOD ip1 value: ");
    % disp(input_1nod);
    % fprintf("pe ip1 value: ");
    % disp(input_peout1);
    % fprintf("ip2 value: ");
    % disp(input2);
    % fprintf("NOD ip2 value: ");
    % disp(input_2nod);
    % fprintf("pe ip2 value: ");
    % disp(input_peout2);
    % fprintf("subtraction1: ");
    % disp(result1);
    % fprintf("subtraction2: ");
    % disp(result2);
    % disp(dec2bin(shifted16, 16));
    % disp(shifted16);

end

% decoder 2^code_i
function data_o = Decoder16(code_i)
    % Calculate the value for data_o using left shift operation
    data_o = bitshift(1, code_i);
end

% % subtractor sub1 - sub2
% function subresult = subtractor8(sub1, sub2)
%     dec_sub1 = bin2dec(sub1);
%     dec_sub2 = bin2dec(sub2);
%     % Perform subtraction
%     dec_result = dec_sub1 - dec_sub2;
% 
%     % Convert result back to 8-bit binary string
%     subresult = dec2bin(dec_result, 9);
% end

% priority encoder
function peoutput = PriorityEncoder8(inputx)
    bitValue = zeros(1,9); 
    for k=1:1:9
        bitValue(k) = str2double(inputx(k));
    end
    e_output = zeros(1, 4);

    OR0 = or(bitValue(2), bitValue(4)); % 3
    OR1 = or(bitValue(2), bitValue(3)); % 1 2
    OR2 = or(bitValue(4), bitValue(5)); % 1
    OR3 = or(bitValue(6), bitValue(7)); % 2
    OR4 = or(bitValue(6), bitValue(8)); % 3
    e_output(1) = bitValue(1);
    e_output(2) = or(OR1, OR2);
    e_output(3) = or(OR1, OR3);
    e_output(4) = or(OR0, OR4);
    peoutput = dec2bin(bin2dec(num2str(e_output)), 4);
end

% exact NOD
function binaryNOD = NOD(binaryNumber)
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
    binaryNOD = dec2bin(bin2dec(num2str(bitnod)), 9);
end

% Base NOD
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

% Carry NOD
function bits8to4 = CarryNOD(input1)
    bitValue = zeros(1,6); 
    bits8to4 = zeros(1,5);
    for k=8:-1:3
        bitValue(9-k) = bitget(input1,k);
    end
    combbit1 = and(bitValue(1), bitValue(2));
    combbit2 = or(bitValue(1), and(bitValue(2),bitValue(3)));
    combbit3 = or(bitValue(2), and(bitValue(3),bitValue(4)));
    combbit4 = or(bitValue(3), and(bitValue(4),bitValue(5))); 
    combbit5 = or(bitValue(4), and(bitValue(5),bitValue(6)));

    ctrl0 = set2to1mux(1, 0, combbit1);
    ctrl1 = set2to1mux(ctrl0, 0, combbit2);
    ctrl2 = set2to1mux(ctrl1, 0, combbit3);
    ctrl3 = set2to1mux(ctrl2, 0, combbit4);

    bits8to4(1) = combbit1;
    bits8to4(2) = and(combbit2, ctrl0);
    bits8to4(3) = and(combbit3, ctrl1);
    bits8to4(4) = and(combbit4, ctrl2);
    bits8to4(5) = and(combbit5, ctrl3);
end

% 2to1 multiplexer
function output = set2to1mux(D_0, D_1, select_line)
    if(select_line==0)
        output = D_0;
    else
        output = D_1;
    end
end
    
%control bits - 2bit LOD
function bitsz1to0 = twobitLOD(input1, input2)
    bitsz1to0 = zeros(1,2);
    ctrl1 = set2to1mux(1, 0, input1);
    bitsz1to0(1) = input1;
    bitsz1to0(2) = and(input2, ctrl1);
    %fprintf('%d', bitsz1to0);
end
