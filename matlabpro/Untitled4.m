%% Pick and Place Robot - نسخة سريعة ⚡
clc; clear all; close all;

%% 1. الاتصال
name = "Matlab";
Client = TCPInit('127.0.0.1', 52002, name);
disp('Connected to Unity - FAST MODE ⚡');

%% 2. تعريف الروبوت
gripping_point = 0.410;

L(1) = Revolute('d', 0.444, 'a', 0.26, 'alpha', pi/2);
L(2) = Revolute('d', 0, 'a', 0.852, 'alpha', 0);
L(3) = Revolute('d', 0, 'a', 0.07862926, 'alpha', pi/2);
L(4) = Revolute('d', 0.872653, 'a', 0, 'alpha', -pi/2);
L(5) = Revolute('d', 0, 'a', 0, 'alpha', pi/2);
L(6) = Revolute('d', gripping_point, 'a', 0, 'alpha', 0);

robot = SerialLink(L);

%% 3. الوضعيات الثابتة
qf_home = [0, pi/2, 0, 0, -pi/2, 0];
t_fast = 0:0.05:1;  % !!! أسرع: 20 نقطة خلال 1 ثانية بدلاً من 2 !!!

%% 4. الذهاب للالتقاط - سريع
disp('=== STEP 1: To PICKUP (FAST) ===');
X_pick = 1.4148;
Y_pick = -0.775;
%Z_pick = 1.08; % - Y G
%Z_pick = 0.85; % - Y R
Z_pick = 0.60;  % B


T_pick = transl(X_pick, Y_pick, Z_pick) * trotx(180, 'deg');
qi_pick = robot.ikine(T_pick);

q1 = jtraj(qf_home, qi_pick, t_fast);
robot.plot(q1);

% أرسل بسرعة - تقليل التأخير
b = 1;
for a = 1:length(q1)
    func_data(Client, q1, b);
    b = b + 1;
    pause(0.05);  % !!! نصف التأخير: 0.05 بدلاً من 0.1 !!!
end

%% 5. الالتقاط - وقت أقل
disp('=== STEP 2: GRABBING (FAST) ===');
func_grab(Client, 1);
pause(1.5);  % !!! نصف الوقت: 1.5 بدلاً من 3.0 !!!

%% 6. اكتشاف اللون
disp('=== STEP 3: COLOR DETECTION ===');
color = color_check(Client);
if color == 1  % Red
    X_place = 1.20;
    Y_place = -0.3000;
    Z_place = 0.70;
    
elseif color == 2  % Green
    X_place = 1.20;
    Y_place = -0.01000;
    Z_place = 0.70;
    
else  % Blue
    X_place = 0.700;
    Y_place = -0.1846;
    Z_place = 0.90;
end

disp(['Target: X=', num2str(X_place), ' Y=', num2str(Y_place), ' Z=', num2str(Z_place)]);

%% 7. التحرك للتركيب - سريع
disp('=== STEP 4: To PLACE (FAST) ===');
T_place = transl(X_place, Y_place, Z_place) * trotx(180, 'deg');
qi_place = robot.ikine(T_place);

q2 = jtraj(qi_pick, qi_place, t_fast);
robot.plot(q2);

b = 1;
for a = 1:length(q2)
    func_data(Client, q2, b);
    b = b + 1;
    pause(0.05);  % !!! نصف التأخير !!!
end

%% 8. التحرير - وقت أقل
disp('=== STEP 5: RELEASING (FAST) ===');
func_grab(Client, 0);
pause(0.75);  % !!! نصف الوقت: 0.75 بدلاً من 1.5 !!!

%% 9. الرفع قبل العودة - سريع
disp('=== STEP 6: LIFTING UP (FAST) ===');
Z_lift = Z_place + 0.15;
T_lift = transl(X_place, Y_place, Z_lift) * trotx(180, 'deg');
qi_lift = robot.ikine(T_lift);

q_lift = jtraj(qi_place, qi_lift, t_fast);
robot.plot(q_lift);

b = 1;
for a = 1:length(q_lift)
    func_data(Client, q_lift, b);
    b = b + 1;
    pause(0.05);  % !!! نصف التأخير !!!
end

%% 10. العودة للمنزل - سريع
disp('=== STEP 7: RETURNING HOME (FAST) ===');
q3 = jtraj(qi_lift, qf_home, t_fast);
robot.plot(q3);

b = 1;
for a = 1:length(q3)
    func_data(Client, q3, b);
    b = b + 1;
    pause(0.05);  % !!! نصف التأخير !!!
end

disp('=== TASK COMPLETED - FAST MODE ⚡ ===');