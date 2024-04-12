function output = set2to1mux(D_0, D_1, select_line)
    if(select_line==0)
        output = D_0;
    else
        output = D_1;
    end
end