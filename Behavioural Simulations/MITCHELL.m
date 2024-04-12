% This file defines the Mitchell Multiplication Approximation Method
% Uses leading one detector architecture

% Define the range of x and y values
x_range = 0:255;
y_range = 0:255;

% Initialize arrays to store results
errors = zeros(length(x_range), length(y_range));
final_values = zeros(length(x_range), length(y_range));
product_values = zeros(length(x_range), length(y_range));
mre_values = zeros(length(x_range), length(y_range));
ae_values = zeros(length(x_range), length(y_range));

% Calculate final values, product values, and errors
for i = 1:length(x_range)
    for j = 1:length(y_range)
        x = x_range(i);
        y = y_range(j);

        % Calculate final value
        final = mitchell(x,y);

        % Calculate the product of x and y
        product_xy = x * y;

        % Calculate the error
        error = final - product_xy;
        if product_xy == 0
            mre = 0;
        else
            mre = error / product_xy;
        end


        % Store values in arrays
        errors(i, j) = error;
        final_values(i, j) = final;
        product_values(i, j) = product_xy;
        mre_values(i, j) = mre;
        ae_values(i,j) = error;

    end
end

% determines MRE error metric
overall_mre = mean(mre_values(:));
disp(['Overall Mean Relative Error (MRE): ' num2str(overall_mre)]);
overall_ae = mean(ae_values(:));
disp(['Overall Average Error (AE): ' num2str(overall_ae)]);

% Calculate mean absolute error (MAE)
mae = mean(abs(ae_values(:)));        
% Calculate mean product value (MPV)
mpv = max(final_values(:));         
% Calculate Normalized Mean Error (NME)        
nme = mae / mpv;
     
disp(['Mean Absolute Error (MAE): ' num2str(mae)]);
disp(['Mean Product Value (MPV): ' num2str(mpv)]);
disp(['Normalized Mean Error (NME): ' num2str(nme)]);

% Plot the 3D graph
figure;
surf(x_range, y_range, errors);
xlabel('x');
ylabel('y');
zlabel('Error');
title('Error Between Final Value and Product of x and y');
colorbar; % Display color bar for error values


% Uncomment to test the 8bit leading one detector
% for i=1:1:255
%     fprintf("%d: ", i);
%     fprintf(dec2bin(i,8));
%     fprintf(">>>")
%     fprintf(dec2bin(EightbitLOD(i),8));
%     fprintf("\n");
% end


% x = 40;
% y = 139;
% final = mitchell(x,y);
% fprintf("%d\n", x*y);
% fprintf("%d", final);
% error = final - x*y;


% mitchell method with barrel shifter calculated manually
function final = mitchell(x,y)
    input1 = dec2bin(x, 8);
    input2 = dec2bin(y, 8);

    input1_lod = dec2bin(EightbitLOD(bin2dec(input1)), 8);
    input2_lod = dec2bin(EightbitLOD(bin2dec(input2)), 8);
    input_peout1 = PriorityEncoder8(input1_lod);
    input_peout2 = PriorityEncoder8(input2_lod);
    
    res1 = x - bin2dec(input1_lod); % gets the mantissa
    res2 = y - bin2dec(input2_lod); 

    %disp(dec2bin(res1, 7));
    pp1 = res1 * 2^(7-bin2dec(input_peout1));
    %fprintf("mantissa 1: ");
    %disp(dec2bin(pp1, 7));
    pp2 = res2 * 2^(7-bin2dec(input_peout2));
    %fprintf("mantissa 2: ");
    %disp(dec2bin(pp2, 7));
   
    mank = pp1 + pp2;
    if mank > 128
        code_sum = bin2dec(input_peout2) + bin2dec(input_peout1) + 1;
        mank = mank - 128;
    else
        code_sum = bin2dec(input_peout2) + bin2dec(input_peout1);
    end
    %disp(mank);
    %fprintf("code sum %d\n", code_sum);


    mank_shifted = mank * 2^(code_sum-7);
    % newpp1 = pp1 * 2^(bin2dec(input_peout1)+bin2dec(input_peout2)-7);
    % newpp2 = pp2 * 2^(bin2dec(input_peout1)+bin2dec(input_peout2)-7);
    % disp(dec2bin(newpp1, 8));
    % disp(dec2bin(newpp2, 8));

    shifted16 = Decoder16(code_sum);
    %finalbin = dec2bin(shifted16+mank_shifted, 16);
    %disp(finalbin);
    temp_pp = shifted16+mank_shifted;

    if x * y == 0
        final = 0;
    else
        final = temp_pp;
    end

end

% decoder
function data_o = Decoder16(code_i)
    % Calculate the value for data_o using left shift operation
    data_o = bitshift(1, code_i);
end

% leading one detector
function bitsoffour = fourbitLOD(input1)
    bitValue = zeros(1,4);
    bitsoffour = zeros(1,4);
    for k=1:1:4
        bitValue(k) = input1(k);
    end

    ctrl1 = set2to1mux(1, 0, bitValue(1));
    ctrl2 = set2to1mux(ctrl1, 0, bitValue(2));
    ctrl3 = set2to1mux(ctrl2, 0, bitValue(3));
    
    bitsoffour(1) = bitValue(1);
    bitsoffour(2) = and(bitValue(2), ctrl1);
    bitsoffour(3) = and(bitValue(3), ctrl2);
    bitsoffour(4) = and(bitValue(4), ctrl3);
end

%eightbitLOD
function decimalLOD = EightbitLOD(binaryNumber)
    bitlod = zeros(1,8);
    bitValue = zeros(1,8);
    for k=8:-1:1
        bitValue(9-k) = bitget(binaryNumber,k);
    end
    upperHalf = bitValue(1:4);
    lowerHalf = bitValue(5:8);
    upperLOD = fourbitLOD(upperHalf);
    lowerLOD = fourbitLOD(lowerHalf);
    bit7to4OR = or(or(bitValue(1),bitValue(2)),or(bitValue(3),bitValue(4)));
    bit3to0OR = or(or(bitValue(5),bitValue(6)),or(bitValue(7),bitValue(8)));
    
    outputvar = twobitLOD(bit7to4OR, bit3to0OR);
    bitlod(1:4) = set2to1mux(0000, upperLOD, outputvar(1));
    bitlod(5:8) = set2to1mux(0000, lowerLOD, outputvar(2));
    decimalLOD = bin2dec(num2str(bitlod));
end

%control bits - 2bit LOD
function bitsz1to0 = twobitLOD(input1, input2)
    bitsz1to0 = zeros(1,2);
    ctrl1 = set2to1mux(1, 0, input1);
    bitsz1to0(1) = input1;
    bitsz1to0(2) = and(input2, ctrl1);
    %fprintf('%d', bitsz1to0);
end

%2 choice mux
function output = set2to1mux(D_0, D_1, select_line)
    if(select_line==0)
        output = D_0;
    else
        output = D_1;
    end
end

%priority encoder
function peoutput = PriorityEncoder8(inputx)
    bitValue = zeros(1,8); 
    for k=1:1:8
        bitValue(k) = str2double(inputx(k));
    end
    e_output = zeros(1, 3);

    OR0 = or(bitValue(1), bitValue(3)); % 3
    OR1 = or(bitValue(1), bitValue(2)); % 1 2
    OR2 = or(bitValue(3), bitValue(4)); % 1
    OR3 = or(bitValue(5), bitValue(6)); % 2
    OR4 = or(bitValue(5), bitValue(7)); % 3
    e_output(1) = or(OR1, OR2);
    e_output(2) = or(OR1, OR3);
    e_output(3) = or(OR0, OR4);
    peoutput = dec2bin(bin2dec(num2str(e_output)), 3);
end