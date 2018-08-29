function compilemex( )

sd = pwd;
cd(fileparts(mfilename('fullpath')));
cd ..

try 
    cd bin

    fprintf(1,'Compiling mexsvmlearn\n');
    mex -O  -DMATLAB_MEX -I../src ../src/mexsvmlearn.c ../src/global.c ../src/svm_learn.c ../src/svm_common.c ../src/svm_hideo.c ../src/mexcommon.c 

    fprintf(1,'Compiling mexsvmclassify\n');
    mex -O  -DMATLAB_MEX -I../src  ../src/mexsvmclassify.c ../src/global.c ../src/svm_learn.c ../src/svm_common.c ../src/svm_hideo.c ../src/mexcommon.c 

    fprintf(1,'Compiling mexsinglekernel\n');
    mex -O  -DMATLAB_MEX -I../src ../src/mexsinglekernel.c ../src/global.c ../src/svm_learn.c ../src/svm_common.c ../src/svm_hideo.c ../src/mexcommon.c 
 
    fprintf(1,'Compiling mexkernel\n');
    mex -O  -DMATLAB_MEX -I../src ../src/mexkernel.c ../src/global.c ../src/svm_learn.c ../src/svm_common.c ../src/svm_hideo.c ../src/mexcommon.c 
    
    cd(sd);
catch
    cd(sd); 
    fprintf(1,'compile failed\n');
end
