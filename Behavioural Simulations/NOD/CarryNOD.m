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