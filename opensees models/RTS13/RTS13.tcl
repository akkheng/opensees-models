wipe                               # clear memory of all past model definitions
model BasicBuilder -ndm 3 -ndf 6; # Define the model builder ndm=#dimension, ndf=#dofs# define UNITS ----------------------------------------------------------------------------
set NT 1.0; # define basic units -- output units
set mm 1.0; # define basic units -- output units
set sec 1.0; # define basic units -- output units
set kN [expr 1000.0*$NT];
set MPa [expr 1.0*$NT/pow($mm,2)];
set LunitTXT "mm"; # define basic-unit text  for output
set FunitTXT "kN"; # define basic-unit text for output
set TunitTXT "sec"; # define basic-unit text for output
set m [expr 1000.0*$mm]; # m
set mm2 [expr $mm*$mm]; # mm^2
set mm4 [expr $mm*$mm*$mm*$mm]; # mm^4
set cm [expr 100.0*$mm];
set PI [expr 2*asin(1.0)]; # define constants
set Ubig 1.e10; # a really large number
set Usmall [expr 1/$Ubig]; # a really small number
puts "define UNITS Completed"
# define GEOMETRY -------------------------------------------------------------
# define pier section geometry
set DCol [expr 830.*$mm]; # Column Diameter
set RCol [expr $DCol/2.]; # Column Radius
set ACol [expr $PI*pow($RCol,2)]; # cross-sectional area
set IzCol [expr 1./64.*$PI*pow($DCol,4)]; # Column moment of inertia
# define steel section geometry
set coverCol [expr 30.*$mm]; # Column cover width
set Rcore [expr ($RCol-$coverCol)]; # Column inner radius of column section
set numBarsCol 28; # number of longitudinal-reinforcement bars in column. (symmetric top & bot)
set diameter 25
set tdiameter 22
set radius 12.5
set Dbar [expr $diameter.*$mm]; # Diameter of bar
set tDbar [expr $tdiameter.*$mm];
set Rbar [expr $radius*$mm];
set Abar [expr $PI*pow($Dbar,2)/4.0]; # area of individual bar
set tAbar [expr $PI*pow($tDbar,2)/4.0]; # area of Reduce individual bar
set CAbar [expr $numBarsCol*$Abar]; # all area of longitudinal-reinforcement bars
set CtAbar [expr $numBarsCol*$tAbar]; #all area
set gdiameter 6
set dgbar [expr $gdiameter.*$mm]
set rsteel [expr ($RCol-$coverCol-$Rbar)]
set shen [expr 70.*$mm]
set wa [expr ($rsteel-$shen)]
puts "define GEOMETRY Completed"
node 1 0 0 0;
node 2 0 0 0;
node 3 0 122 0;
node 4 0 322 0;
node 5 0 522 0;
node 6 0 644 0;
node 7 0 750 0;
node 8 0 900 0;
node 9 0 1050 0;
node 10 0 1200 0;
node 11 0 1400 0;
node 12 0 1600 0;
node 13 0 1800 0;
node 14 0 2000 0;
node 15 0 2340 0;
fix 1 1 1 1 1 1 1; 
equalDOF 1 2 1 3 5;
set ColTransfTag 1; # associate a tag to column transformation
set ColTransfType PDelta;
geomTransf $ColTransfType $ColTransfTag 0 0 -1;
# Define ELEMENTS & SECTIONS ----------------------------------------------------
set ColSecTag 1; # assign a tag number to the column section
set FRPR25 2; # assign a tag number to the FRP-confined column
set FRPR21 3; # assign a tag number to the FRP-confined column
set ConR25 4;
set ConR21 5;
set FRPconcrete 6;
set tFRPreinf 7;
set huayi 8;
set lian 9
puts "NODE Completed"
# MATERIAL parameters -----------------------------------------------------------
set IDsteel 1;
set IDFRPreinf 2; # materila ID tag -- FRP confined concrete
set IDssteel 3; # materila ID tag --steel plate
set Steelplate 4;
set IDConreinf 5;
set IDsteel2 10
set su 11
set IDZeroSteel 12
set FRPc 13
set FRPc2 14
set IDFRPreinf3 16
# steel-----------
set Fy [expr 397.*$MPa]; # STEEL yield stress
set Es [expr 203000.*$MPa]; # modulus of steel
set Bs 0.02; # strain-hardening ratio
set tFy [expr 455.*$MPa];
set tEs [expr 203000.*$MPa];
set tBs 0.01;
puts 22222
uniaxialMaterial Concrete02 $su -31 -0.002 -8 -0.004 0.4 3 3150;
uniaxialMaterial Concrete04 $IDConreinf -33 -0.003 -0.0122 27000 3 0.00015 0.1;
uniaxialMaterial FRPConfinedConcrete02 $FRPc -33 31500 -0.002 -JacketC 0.501 240000 0.019 415 3 1500 1;
uniaxialMaterial FRPConfinedConcrete02 $FRPc2 -22 30700 -0.002 -JacketC 0.501 240000 0.019 415 3 1500 1;
uniaxialMaterial Concrete01 $IDFRPreinf3 -33 -0.5 -26 -2.5;
uniaxialMaterial Bond_SP01 $IDZeroSteel  397 0.8 549 32 0.5 0.5;
uniaxialMaterial Steel02 $IDsteel $Fy $Es $Bs 12 0.925 0.15; # build reinforcement material
uniaxialMaterial Steel02 $IDsteel2 $tFy $tEs $tBs 12 0.925 0.15;
puts "MATERIAL parameters"
# FIBER SECTION properties ---------------------------------------
# symmetric section
# RC section:
set nfFRPcoreC 28;
set nfFRPcoreR 60;
set ZeroColSecTag 324
#--------------------------------------------------------
section Fiber $lian -GJ [expr 1.7E10] {
patch circ $FRPc $nfFRPcoreC $nfFRPcoreR 0. 0. 0. $wa 0. 360.;
patch circ $FRPc2 $nfFRPcoreC $nfFRPcoreR 0. 0. $wa $RCol 0. 360.;
layer circ $IDsteel $numBarsCol $Abar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
}
section Fiber $FRPR21 -GJ [expr 1.7E10] {
patch circ $FRPc $nfFRPcoreC $nfFRPcoreR 0. 0. 0. $wa 0. 360.;
patch circ $FRPc2 $nfFRPcoreC $nfFRPcoreR 0. 0. $wa $RCol 0. 360.;
layer circ $IDsteel2 $numBarsCol $tAbar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
}
section Fiber $huayi -GJ [expr 1.7E10] {
patch circ $IDFRPreinf3 $nfFRPcoreC $nfFRPcoreR 0. 0. 0. $RCol 0. 360.;
layer circ $IDZeroSteel $numBarsCol $Abar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
}
section Fiber $FRPR25 -GJ [expr 1.7E10] {
patch circ $FRPc $nfFRPcoreC $nfFRPcoreR 0. 0. 0 $RCol 0. 360.;
layer circ $IDsteel $numBarsCol $Abar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
}
section Fiber $ConR25 -GJ [expr 1.7E10] {
patch circ $IDConreinf $nfFRPcoreC $nfFRPcoreR 0. 0. 0. $Rcore 0. 360.;
patch circ $su $nfFRPcoreC $nfFRPcoreR 0. 0. $Rcore $RCol 0. 360.;
layer circ $IDsteel $numBarsCol $Abar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
}
set numIntgrPts 4; # number of integration points for force-based element
element zeroLengthSection 1 1 2 $huayi -orient  0 1 0 1 0 0;
element dispBeamColumn 2 2 3 $numIntgrPts $lian $ColTransfTag;
element dispBeamColumn 3 3 4 $numIntgrPts $FRPR21 $ColTransfTag;
element dispBeamColumn 4 4 5 $numIntgrPts $FRPR21 $ColTransfTag;
element dispBeamColumn 5 5 6 $numIntgrPts $lian $ColTransfTag;
element dispBeamColumn 6 6 7 $numIntgrPts $FRPR25 $ColTransfTag;
element dispBeamColumn 7 7 8 $numIntgrPts $FRPR25 $ColTransfTag;
element dispBeamColumn 8 8 9 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 9 9 10 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 10 10 11 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 11 11 12 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 12 12 13 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 13 13 14 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 14 14 15 $numIntgrPts $ConR25 $ColTransfTag;
# Define RECORDERS -------------------------------------------------------------
recorder Node -file nodetop-disp.txt -time -node 15 -dof 1 disp
recorder Node -file nodebase-force.txt -time -node 2 -dof 1 reaction
# define GRAVITY -------------------------------------------------------------
pattern Plain 1 Linear {
load 15 0 -1064000 0 0 0 0
};
set Tol 1.0e-8;
constraints Transformation;
numberer Plain; 
system BandGeneral; 
test NormDispIncr $Tol 6 0; 
algorithm Newton; 
set NstepGravity 10;
set DGravity [expr 1./$NstepGravity]; 
integrator LoadControl $DGravity;
analysis Static;
analyze $NstepGravity;
# ---------------- maintain constant gravity loads and reset time to zero
loadConst -time 0.0
puts "Model Built Completed"
puts "pushover"
## Load Case = PUSH
pattern Plain 2 Linear {
load 15 1 0 0 0 0 0
}
puts "analysis"
constraints Transformation 
numberer RCM
system BandGeneral
test NormDispIncr 1.0e-6 200
algorithm KrylovNewton
analysis Static
integrator	DisplacementControl	15	1	-0.0583
analyze	200
integrator	DisplacementControl	15	1	0.1733
analyze	200
integrator	DisplacementControl	15	1	-0.2683
analyze	200
integrator	DisplacementControl	15	1	0.2416
analyze	200
integrator	DisplacementControl	15	1	-0.24
analyze	200
integrator	DisplacementControl	15	1	0.295
analyze	200
integrator	DisplacementControl	15	1	-0.265
analyze	200
integrator	DisplacementControl	15	1	0.245
analyze	200
integrator	DisplacementControl	15	1	-0.2583
analyze	200
integrator	DisplacementControl	15	1	0.2217
analyze	200
integrator	DisplacementControl	15	1	-0.1784
analyze	200
integrator	DisplacementControl	15	1	0.1434
analyze	200
integrator	DisplacementControl	15	1	-0.1217
analyze	200
integrator	DisplacementControl	15	1	0.12
analyze	200
integrator	DisplacementControl	15	1	-0.1117
analyze	200
integrator	DisplacementControl	15	1	0.1267
analyze	200
integrator	DisplacementControl	15	1	-0.095
analyze	200
integrator	DisplacementControl	15	1	0.03
analyze	200
integrator	DisplacementControl	15	1	-0.1283
analyze	200
integrator	DisplacementControl	15	1	0.3616
analyze	200
integrator	DisplacementControl	15	1	-0.4816
analyze	200
integrator	DisplacementControl	15	1	0.4283
analyze	200
integrator	DisplacementControl	15	1	-0.5433
analyze	200
integrator	DisplacementControl	15	1	0.53
analyze	200
integrator	DisplacementControl	15	1	-0.5184
analyze	200
integrator	DisplacementControl	15	1	0.6584
analyze	200
integrator	DisplacementControl	15	1	-0.5934
analyze	200
integrator	DisplacementControl	15	1	0.4817
analyze	200
integrator	DisplacementControl	15	1	-0.4233
analyze	200
integrator	DisplacementControl	15	1	0.375
analyze	200
integrator	DisplacementControl	15	1	-0.315
analyze	200
integrator	DisplacementControl	15	1	0.3133
analyze	200
integrator	DisplacementControl	15	1	-0.1767
analyze	200
integrator	DisplacementControl	15	1	0.0317
analyze	200


puts "Bravo!"

