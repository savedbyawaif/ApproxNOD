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