%control bits - 2bit LOD
function bitsz1to0 = twobitLOD(input1, input2)
    bitsz1to0 = zeros(1,2);
    ctrl1 = set2to1mux(1, 0, input1);
    bitsz1to0(1) = input1;
    bitsz1to0(2) = and(input2, ctrl1);
    %fprintf('%d', bitsz1to0);
end
