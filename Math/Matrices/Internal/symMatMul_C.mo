within Modelica_LinearSystems2.Math.Matrices.Internal;
function symMatMul_C
  "Calculate the upper triangle of A*B*A'+a*C with B and C symmetric"

  extends Modelica.Icons.Function;
  import Modelica;
  import Modelica_LinearSystems2;
  import Modelica_LinearSystems2.Math.Matrices.LAPACK;

  input Real A[:,:];
  input Real B[size(A, 2),size(A, 2)];
  input Real C[size(A, 1),size(A, 1)];
  input Boolean add=true "true if a==1, false if a==0";
  output Real M[size(A, 1),size(A, 1)]=C;

protected
  Integer a1=size(A, 1);
  Integer a2=size(A, 2);
  Integer lda=max(1,a1);
  Integer ldb=max(1,a2);
  String addi=if add then "A" else "N";

 external "FORTRAN 77" c_symMatMul(A, B, M, addi, a1, a2, lda, ldb);
  annotation (Include="
#include<f2c.h>
#include <stdio.h>
extern  void dgemm_(char *, char *, integer *, integer *, integer *, doublereal *, doublereal *, integer *, doublereal *, integer *, doublereal *, doublereal *, integer *);
extern logical lsame_(char *, char *);
extern void dtrmm_(char *, char *, char *, char *, integer *, integer *, doublereal *, doublereal *, integer *, doublereal *, integer *);
extern int dlacpy_(char *, integer *, integer *, doublereal *, integer *, doublereal *, integer *);


int c_symMatMul_(doublereal *a, doublereal *b, doublereal *c, char *addi, integer *m, integer *n, integer *lda, integer *ldb)
{
   static logical addm;
   static doublereal alpha = 1.0;
   
   doublereal *butri;
   doublereal *cutri;
   doublereal *aa;
   doublereal beta;
         
   integer nn=*n;
   integer mm=*m;
   integer llda=*lda;
   integer lldb=*ldb;
   
   integer i,j;
//     FILE *fileptr;      
//     fileptr = fopen(\"test.txt\",\"w\"); 
    
   addm = lsame_(addi, \"A\");   
   if(addm)
     beta = 1.0;
   else
     beta = 0.0;
   

   
   butri = (doublereal *) malloc((nn*nn+1)*sizeof(doublereal));    
   cutri = (doublereal *) malloc((mm*mm+1)*sizeof(doublereal));    
   aa = (doublereal *) malloc((nn*mm+1)*sizeof(doublereal));    
   dlacpy_(\"U\", n, n, b, ldb, butri, ldb);
   dlacpy_(\"U\", m, m, c, lda, cutri, lda);
   dlacpy_(\"N\", m, n, a, lda, aa, lda);

//   for(i=0;i<nn*mm;i++)
//     aa[i] = 0.0;
   
   for(i=0;i<nn;i++)
     butri[i*nn+i] = b[i*nn+i]/2;
   if(addm)
   {
     for(i=0;i<mm;i++)
       cutri[i*mm+i] = c[i*mm+i]/2;  
     for(i=1;i<mm;i++)
       for(j=i;j<mm;j++)
         cutri[(i-1)*mm+j]=0.0;
   }
   
   
 
// fprintf(fileptr,\"aa = %f, %f, %f\\n %f, %f, %f\\n %f, %f, %f\\n\",aa[0],aa[3],aa[6],aa[1],aa[4],aa[7],aa[2],aa[5],aa[8]);
   
   dtrmm_(\"R\", \"U\", \"N\", \"N\", m, n, &alpha, butri, ldb, aa, lda);
//    fprintf(fileptr,\"aa = \");
//    for(i=0;i<mm;i++)
//    {
//      for(j=0;j<nn;j++)
//        fprintf(fileptr,\"%f \",aa[j*mm+i]);
//     fprintf(fileptr,\"\\n\");
//    }
//        fprintf(fileptr,\"\\n\");

// fprintf(fileptr,\"aa = %f, %f, %f\\n %f, %f, %f\\n %f, %f, %f\\n\",aa[0],aa[3],aa[6],aa[1],aa[4],aa[7],aa[2],aa[5],aa[8]);
   
   dgemm_(\"N\", \"T\", m, m, n, &alpha, aa, lda, a, lda, &beta, cutri, lda);
   
//    fprintf(fileptr,\"cc = \");
//    for(i=0;i<mm;i++)
//    {
//      for(j=0;j<mm;j++)
//        fprintf(fileptr,\"%f \",cutri[j*mm+i]);
//     fprintf(fileptr,\"\\n\");
//    }
   
  //    for i in 1:a1 loop
  //   for j in i:a1 loop
  //     M[i,j] := M[i,j]+M[j,i];
  //   end for;
  // end for;
  
  for(i=0;i<mm;i++)
    for(j=i;j<mm;j++)
      cutri[j*mm+i] = cutri[j*mm+i] + cutri[i*mm+j];
  dlacpy_(\"U\", m, m, cutri, lda, c, lda);
   
   free(aa);
   free(butri);
   free(cutri);
//   fclose(fileptr);
  return 0;
}", Library={"lapack"},
    Documentation(revisions="<html>
<ul>
<li><i>2010/05/31 </i>
       by Marcus Baur, DLR-RM</li>
</ul>
</html>"));

end symMatMul_C;
