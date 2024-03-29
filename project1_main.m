function [] = project1_main()
% This is the driver of the project1 simulations
% Assumptions:
% Author: Karl Ludwig Fetzer

% hold on; % This command allows plots to be overlaid for various cases
close all; % This command closes all open figure windows
clear;     % This command removes all variables from the workspace
clc;       % This command removes all interactions from the command line

T = 0;  % N-m
I = 200; % kg-m^2
J = 100; % kg-m^2
K = (J-I)/I; % dimensionless

tstep = 0.1; % sec
tf    = 12;  % sec

% For b2 as axis of symmetry for axisymmetric body B:
I_tensor = [I 0 0; 
            0 J 0; 
            0 0 I];

%Initial conditions:
w0 = [1.0 1.5 -1.0]; % rad/s
E0 = [0 0 0 1];

H0 = dyadicRightDot(I_tensor,w0);

eig_mag = abs(w0(2) * K);

% options = odeset('RelTol',1e-4);

% This file handler uses an anonymous function so that the ode can handle extra
% parameters as inputs to ode45.  Discussion  of this function's necessity is found here:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/242818
% Implementation is found here:
% http://www.facstaff.bucknell.edu/maneval/help211/usingode45.pdf

fileHandle = @(time,V) project1_ODE(time,V,T,I,K);

[time,V] = ode45(fileHandle, [0:tstep:tf],[1.0 1.5 -1.0 0 0 0 1]);

% At time t, angular velocity (rad/s) is:
%time = 0:tstep:tf;
w(1,:) = sin(eig_mag.*time') + (1+(T/I)/eig_mag)*cos(eig_mag.*time') - (T/I)/eig_mag;
w(2,:) = w0(2);
w(3,:) = (1+(T/I)/eig_mag) * sin(eig_mag.*time') - cos(eig_mag.*time');

w_n    = V(:,1:3)'; % Numerical integration for angular velocity
quat_n = V(:,4:7)'; % Numerical integration for quaternion

for index = 1:length(time)
   C_NtoB(1:3,1:3,index) = quat2dcm(quat_n(:,index));
   [theta(1,index), theta(2,index), theta(3, index)] = dcm212precnut(C_NtoB(:,:,index));
   [thetaDot(1,index), thetaDot(2,index), thetaDot(3,index)] = dcm212precnutrate(theta(:,index),w_n(:,index));
end

project1_assessAccuracy(time,tstep,w_n,w,C_NtoB,theta,thetaDot, quat_n)
project1_output(time,tstep,w_n,w,C_NtoB,theta,thetaDot, quat_n(4,:))
project1_plotting(time,w_n,w,C_NtoB,theta,thetaDot,quat_n)

end