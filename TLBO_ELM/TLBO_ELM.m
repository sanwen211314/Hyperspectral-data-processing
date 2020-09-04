clear all
clc
%% ���ݶ���
load CARS.mat
shuju=CARS(:,:);

% ѡ��ѵ�����Ͳ��Լ�
train_shrimp = shuju(1:315,1:29);
test_shrimp =shuju(316:end,1:29);
% ��ǩ����
train_shrimp_labels = shuju(1:315,30);
test_shrimp_labels = shuju(316:end,30);

%% ���ݹ�һ��
[mtrain,ntrain] = size(train_shrimp);
[mtest,ntest] = size(test_shrimp);

dataset = [train_shrimp;test_shrimp];
[dataset_scale,ps] = mapminmax(dataset',0,1);%mapminmax���й�һ��������ԭ������Ҫת��֮����ת��
dataset_scale = dataset_scale';

train_shrimp = dataset_scale(1:mtrain,:);
test_shrimp = dataset_scale((mtrain+1):(mtrain+mtest),: );

%% Ѱ�Ų�������
L_min=0; 
L_max=1000;

nVar =1;%��������
VarSize = [1 nVar];%��������ѧϰ����

%% TLBO��������
MaxIt = 30;        % ��������
nPop = 20  ;           % �˿���

%% TLBO��ʼ��
for i=1:nPop
    pop(i,1) = round((L_max-L_min)*rand+L_min);    % ��ʼ��Ⱥ,��Ҫȡ����
    fitness(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(i,1)); %�õ���Ӧ��ֵ����pop(i,:)����Ŀ�꺯���еõ��Ľ����
    fitnessgbest=min(fitness);
end 

%% ��ѭ��
for it=1:MaxIt
    %����ƽ���ɼ����ҵ���ʦ
    pop_m=sum(pop)/nPop;
    [bestfitness,bestindex]=min(fitness);
    pop_t=pop(bestindex,:);
    
%     %�ҵ���ʦ
%     [teacher_fitness,teacher_index]=min(fitness);
%     teacher_position=pop(teacher_index,:);

    %���̡��׶�
    for i=1:nPop
        %TF = randi([1 2]);%��ѧ���ӣ���ȱ�ݣ�ֻ����ȫ���պͲ����գ��ⲽд�� TF = round��1 + rand(0,1);Ҳ��
        TF = unidrnd(2);
        %��ѧ������ʦ���룩
        pop_new(i,:)=pop(i,:)+rand(VarSize).*(pop_t - TF*pop_m);%rand(VarSize)����һ������0-1�����
        %Խ�紦��
        pop_new(i,pop_new(i,1)>L_max)=L_max;
        pop_new(i,pop_new(i,1)<L_min)=L_min;
        pop_new(i,:)=round(pop_new(i,:));
        fitness_new(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop_new(i,1));
        if fitness_new(i)<fitness(i)
            pop(i,:)=pop_new(i,:);
        end
    end   
    %��ѧ���׶�
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
            %Խ�紦��
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
    CARS_1(it)=fitnessgbest; %�洢���ŵ�ֵ
%     %���߲�������ѭ��Ҳ�����
%         for i=1:nPop
%          fitness(i)=fit_ELM(train_shrimp,train_shrimp_labels,test_shrimp,test_shrimp_labels,pop(i,1));
%             [bestfitness_1,bestindex_1]=min(fitness);
%             best_position=pop(bestindex_1,:);
%     end
%     CARS_1(it) = bestfitness_1;
% 
end
%% ��ͼ
pp=1:1:MaxIt;
pp=pp';
figure;
%plot(BestCost,'LineWidth',2);
%plot(BestCost,'b-o');
plot(pp,CARS_1,'--ms','LineWidth',2,'MarkerSize',10,'MarkerEdgeColor','g','MarkerFaceColor',[0.5,0.5,0.5])
xlabel('Iteration');
ylabel('Best fitness value');
legend('CARS')
