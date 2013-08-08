function moire_cpd = moire_starting_point(line_abL3)

C=max(size(line_abL3(:)));
alpha=0.05;
uppernum=floor(alpha*C);

B=sort(line_abL3, 'descend');
upper_B=B(1, 1:uppernum);
thm=mean(upper_B(:));

th=B(1,uppernum);
upper_data=zeros(1,C);

for k=1 : C
    if(line_abL3(1, k)>thm)
        upper_data(1,k)=line_abL3(1, k);
    end
end

te=0;
for k=1 : C
    if(upper_data(1, k)>thm)
        te=te+1;
    end
    if(upper_data(1, k)>thm && te==1)
        moire=k;
    end
end

moire_cpd=moire;