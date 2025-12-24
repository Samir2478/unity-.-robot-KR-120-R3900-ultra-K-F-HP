
%% Pick up object (1st level)
clc;
clear all;
close all;
name = "Matlab";
Client = TCPInit('127.0.0.1',52002,name);

% gripping_point = 0.001752853;
gripping_point = 0.410;
 
L(1) = Revolute('d',0.444,'a',0.26,'alpha',pi/2);
L(2) = Revolute('d',0,'a',0.852,'alpha',0);
L(3) = Revolute('d',0,'a',0.07862926,'alpha',pi/2);
L(4) = Revolute('d',0.872653,'a',0,'alpha',-pi/2);
L(5) = Revolute('d',0,'a',0,'alpha',pi/2);
L(6) = Revolute('d',gripping_point,'a',0,'alpha',0);
robot = SerialLink(L);
joints = [0,pi/2,0,0,0,0];
 robot.plot(joints);
%
grab = 2; % activate EE (0 - release the object, 1 - grab, 2 - do nothing)
t = [0:0.1:2];

X1 = 1.4148; % - X
Y1 = -0.775; % - Z 
Z1 = 0.65; % - Y
%Z1 = 0.85; % - Y
%Z1 = 1.10; % - Y
T = transl(X1, Y1, Z1) * trotx(180, "deg");
qi1 = robot.ikine(T);
qf1 = [0,pi/2,0,0,-pi/2,0];
q = jtraj(qf1,qi1,t);
 robot.plot(q);

%
b = 1;
for a = 1 : length(q)
    func_data(Client, q,  b);
    b=b+1;     
end

% take object
grab = 1;
func_data(Client, q,  b-1);
func_grab(Client, grab)
pause(4.5);

% back to initial pos
b = 1;
q = jtraj(qi1,qf1,t);
% robot.plot(q);
for a = 1 : length(q)
    func_data(Client, q, b); 
    b=b+1;
end

% release object
grab = 0;
func_data(Client, q, b-1);
func_grab(Client, grab)

%Close Gracefully
fprintf(1,"Disconnected from server\n");