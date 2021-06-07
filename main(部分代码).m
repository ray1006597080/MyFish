%% 第三份文件，主程序，需要用到前面的两份生成的数据文件
clc
clear all
close all

%% 读取数据
% load EVdata.mat
% load data.mat

global EVLoad BLoad WTP EV
global EPrice
global EVnum

EVnum = 1000;%EV数量
EV0
data
load EVdata.mat
load data.mat
BLoad = Load(:,2)';
[EPrice,PriceT] = EPriceCAL(WTP(:,2));%考虑风电影响的电价
HighPriceTime = [];MediumPriceTime = [];LowPriceTime = [];

for i = 1 : length(PriceT)
    if PriceT(i) == 1
        HighPriceTime = [HighPriceTime,i];
    end
    if PriceT(i) == 2
        MediumPriceTime = [MediumPriceTime,i];
    end
    if PriceT(i) == 3
        LowPriceTime = [LowPriceTime,i];
    end
end
%% PSO参数设置
% Problem preparation 
problem.nVar = EVnum;
problem.ub = ones(1,EVnum)*30;% Upper boundary
problem.lb = EV(:,1)';% Lower boundary
problem.fobj = @fun;

% PSO parameters 
noP = 10;
maxIter = 1000;
visFlag = 0; % set this to 0 if you do not want visualization

RunNo  = 30; 
BestSolutions_PSO = zeros(1 , RunNo);


%% PSO优化
[GBEST , cgcurve] = PSO( noP , maxIter, problem , visFlag ) ;

% % % % [BestSol,BestCost] = pso(nVar,VarMin,VarMax,...
% % % %     MaxIt,nPop,w,wdamp,c1,c2,@fun);
%% 收敛图
figure
plot(cgcurve,'-r','Linewidth',1.5)

title('PSO收敛图');
xlabel('迭代次数');
ylabel('目标函数');



%% 优化结果展示---有序充电下的
disp('各电动汽车调度充电时间点：')
round(GBEST.X)

disp('最优电动汽车调度策略的目标函数')
GBEST.O

[~,deltaP,ChargeCost,PLD] = fun(GBEST.X);
disp('最优电动汽车调度策略的峰谷差')
deltaP

disp('最优电动汽车充电费用')
ChargeCost

%% 画图，得到电动汽车优化前后总的负荷曲线
plot(PLD(1,:),'-rs','linewidth',2);
title('优化电动汽车充电策略前后的总负荷');
xlabel('时间/h');
ylabel('功率需求/kW');
hold on 


PLD0 = BLoad + EVLoad;
plot(PLD0(1,:),'-gs','linewidth',2);
% title('优化电动汽车充电策略前后的总负荷');
% xlabel('时间/h');
% ylabel('功率需求/kW');
legend('优化后负荷曲线','优化前负荷曲线')

%% 数据展示
disp(['高电价时间段： ',num2str(HighPriceTime)])

disp(['平电价时间段： ',num2str(MediumPriceTime)])

disp(['低电价时间段： ',num2str(LowPriceTime)])

PLD5 = PLD;
save loaddata1000 PLD5