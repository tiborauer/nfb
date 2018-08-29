function [scratch] = train_bp(trainpats,traintargs)

sanity_check(trainpats,traintargs);

args.nHidden = 5;
args.goal = 0.001;
args.Error_importance = 100; %
args.epochs = 1000;
args.min_grad = 1e-10;

args.alg = 'trainscg';
args.act_funct{1} = 'logsig';
args.act_funct{2} = 'logsig';
args.show = NaN;
args.showWindow = true;
args.performFcn = 'msereg'; % do not plot during running
args.processFcns = {};
args.divideFcn = '';
args.train_funct_name = 'train_bp';
args.test_funct_name = 'test_bp';

verstruct = ver('matlab');
args.version = str2num(verstruct.Version);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THINGS UP

scratch.nOut = size(traintargs,1);

% Backprop needs to know the range of its input patterns xxx
patsminmax(:,1)=min(trainpats')'; 
patsminmax(:,2)=max(trainpats')';
scratch.patsminmax = patsminmax;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** CREATING AND INITIALIZING THE NET ***

if ~args.nHidden
  if args.version < 7.5 
    scratch.net = newff(patsminmax,[scratch.nOut],args.act_funct);
  else
    scratch.net = newff(trainpats,traintargs,[],args.act_funct); 

    % Disable all the advanced (bad) functionality that was added
    scratch.net.inputs{1}.processFcns = args.processFcns;
    scratch.net.outputs{1}.processFcns = args.processFcns;
    scratch.net.divideFcn = args.divideFcn;
  end  

  % Get outputs from the output layer
  scratch.net.outputConnect = [1]; 
else
  if args.version < 7.5
    scratch.net = newff(patsminmax,[args.nHidden scratch.nOut],args.act_funct);

    % Get outputs from both the hidden and output layers
    scratch.net.outputConnect = [1 1];
  else
    scratch.net = newff(trainpats,traintargs,[args.nHidden],args.act_funct); 

    % Disable all the advanced (bad) functionality that was added
    scratch.net.inputs{1}.processFcns = args.processFcns;
    scratch.net.outputs{2}.processFcns = args.processFcns;
    scratch.net.divideFcn = args.divideFcn;    
  end  
end

scratch.net = init(scratch.net); % initializes it

% Setting the network's properties according to args
scratch.net.trainFcn = args.alg;
scratch.net.trainParam.goal = args.goal;
scratch.net.trainParam.min_grad = args.min_grad;
scratch.net.trainParam.epochs = args.epochs;
scratch.net.trainParam.show = args.show; 
scratch.net.trainParam.showWindow = args.showWindow;
scratch.net.performFcn = args.performFcn;
scratch.net.performParam.ratio = args.Error_importance/(args.Error_importance+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** RUNNING THE NET ***

[scratch.net, scratch.training_record, scratch.training_acts, scratch.training_error]= ...
    train(scratch.net,trainpats,traintargs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sanity_check(trainpats,traintargs)
if size(trainpats,2)==1
  error('Can''t classify a single timepoint');
end

if size(trainpats,2) ~= size(traintargs,2)
  error('Different number of training pats and targs timepoints');
end
end