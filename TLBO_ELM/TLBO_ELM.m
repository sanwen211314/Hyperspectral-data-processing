clear all
clc
%% 数据读入
load CARS.mat
shuju=CARS(:,:);

% 选定训练集和测试集
train_shrimp = shuju(1:315,1:29);
test_shrimp =shuju(316:end,1:29);
% 标签分离
train_shrimp_labels = shuju(1:315,30);
test_shrimp_labels = shuju(316:end,30);

%% 数据归一化
[mtrain,ntrain] = size(train_shrimp);
[mtest,ntest] = size(test_shrimp);

dataset = [train_shrimp;test_shrimp];
[dataset_scale,ps] = mapminmax(dataset',0,1);%mapminmax对列归一化，所以原数据需要转置之后再转置
dataset_scale = dataset_scale';

train_shrimp = dataset_scale(1:mtrain,:);
test_shrimp = dataset_scale((mtrain+1):(mtrain+mtest),: );

%% 寻优参数设置
L_min=0; 
L_max=1000;

nVar =1;%两个参数
VarSize = [1 nVar];%方便设置学习步长

%% TLBO参数设置
MaxIt = 30;        % 最大迭代数
nPop = 20  ;           % 人口数

%% TLBO初始化
for i=1:nPop
    pop(i,1) = round((L_max-L_min)*rand+L_min);    % 初始种群,但要取整数
    fitness(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(i,1)); %得到适应度值（把pop(i,:)代到目标函数中得到的结果）
    fitnessgbest=min(fitness);
end 

%% 主循环
for it=1:MaxIt
    %计算平均成绩并找到老师
    pop_m=sum(pop)/nPop;
    [bestfitness,bestindex]=min(fitness);
    pop_t=pop(bestindex,:);
    
%     %找到老师
%     [teacher_fitness,teacher_index]=min(fitness);
%     teacher_position=pop(teacher_index,:);

    %“教”阶段
    for i=1:nPop
        %TF = randi([1 2]);%教学因子，有缺陷，只有完全接收和不接收，这步写成 TF = round［1 + rand(0,1);也行
        TF = unidrnd(2);
        %教学（向老师看齐）
        pop_new(i,:)=pop(i,:)+rand(VarSize).*(pop_t - TF*pop_m);%rand(VarSize)生成一行两列0-1随机数
        %越界处理
        pop_new(i,pop_new(i,1)>L_max)=L_max;
        pop_new(i,pop_new(i,1)<L_min)=L_min;
        pop_new(i,:)=round(pop_new(i,:));
        fitness_new(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop_new(i,1));
        if fitness_new(i)<fitness(i)
            pop(i,:)=pop_new(i,:);
        end
    end   
    %“学”阶段
    for i=1:nPop
        A = 1:nPop;
        A(i)=[];
        j = A(randi(nPop-1));
        %Step = pop(i)-pop(j);
        fitness(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(i,1));
        fitness(j)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(j,1));
        if fitness(j) < fitness(i)
            %Step = -Step;
            %pop_new(i,:)= pop(i,:) + rand(VarSize).*Step;
            pop_new(i,:)= pop(i,:) + rand(VarSize).*(pop(j,:)-pop(i,:));
             else if fitness(j) > fitness(i)
             pop_new(i,:)= pop(i,:) + rand(VarSize).*(pop(i,:)-pop(j,:));
            %越界处理
            pop_new(i,pop_new(i,1)>L_max)=L_max;
            pop_new(i,pop_new(i,1)<L_min)=L_min;
            pop_new(i,:)=round(pop_new(i,:));
            fitness_new(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop_new(i,1));
        if fitness_new(i)<fitness(i)
            pop(i,:)=pop_new(i,:);
           
            end
        end
        end
    end
    

for i=1:nPop
        fitness(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(i,1));
        if fitness(i)<fitnessgbest
            gbest=pop(i,:);
            fitnessgbest=fitness(i);
        end
    end
    CARS_1(it)=fitnessgbest; %存储最优的值
%     %或者采用这种循环也能求得
%         for i=1:nPop
%          fitness(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(i,1));
%             [bestfitness_1,bestindex_1]=min(fitness);
%             best_position=pop(bestindex_1,:);
%     end
%     CARS_1(it) = bestfitness_1;
% 
end
%% 画图
pp=1:1:MaxIt;
pp=pp';
figure;
%plot(BestCost,'LineWidth',2);
%plot(BestCost,'b-o');
plot(pp,CARS_1,'--ms','LineWidth',2,'MarkerSize',10,'MarkerEdgeColor','g','MarkerFaceColor',[0.5,0.5,0.5])
xlabel('Iteration');
ylabel('Best fitness value');
legend('CARS')

