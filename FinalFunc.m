load KAM_Output.mat
load KAM_RawData.mat

%% Take Inputs

if exist('KAM_RawData','var') == 0
    KAM_RawData = struct("Subject",""); % Define Structure to be replaced if it doesn't exist
end

waitfor(KAM_GUI);

if exist('active','var') == 0 % Give an error if you close out of the program
    if numel(KAM_RawData) ~= numel(KAM_RawData) || exist('KAM_Output','var') == 0
        KAM_RawData = KAM_RawData(1:numel(KAM_RawData)-1);
        if numel(KAM_RawData) == 0
        clear('KAM_RawData')
        end
    end
    return
end

numfilled = numel(KAM_RawData); 
if numfilled == 1 && KAM_RawData(1).Subject == ""
    numfilled = 0;
end

% Transfer data from app to workspace
KAM_RawData(numfilled+1).Subject = string(active.Subject);
KAM_RawData(numfilled+1).Count = active.Count;
KAM_RawData(numfilled+1).Path = string(active.Path);
KAM_RawData(numfilled+1).Filename = string(active.Filename);
KAM_RawData(numfilled+1).Trial1 = active.Trial1;
KAM_RawData(numfilled+1).Trial2 = active.Trial2;
KAM_RawData(numfilled+1).Trial3 = active.Trial3;
KAM_RawData(numfilled+1).Trial4 = active.Trial4;
KAM_RawData(numfilled+1).Trial5 = active.Trial5;

KAM_RawData(numfilled+1).Txt = {readtable(fullfile(KAM_RawData(numfilled+1).Path,KAM_RawData(numfilled+1).Filename))};

clear('active')
clear('numfilled')
if exist('KAM_Output','var') 
    KAM_Output = DataSeparator(KAM_RawData,KAM_Output); % Determine if new output needs to be made, or old one needs to be added to
else
    KAM_Output = DataSeparator(KAM_RawData);
end

function KAM_Output = DataSeparator(KAM_RawData,KAM_Output) % Formatted as function to automatically clear working variables
% Set index
whichNum = numel(KAM_RawData);

% Set File var
file = KAM_RawData(whichNum).Txt{1};

% Make Space
KAM_Output(whichNum) = struct("Subject","","Toe_In",{table()},"Toe_Out",table(),"Wider_Steps",table(),"Ipsilateral_Trunk_Lean",table(),"Medial_Knee_Thrust",table());

%% Setup for Indexing

% Get Values where one trial ends and another begins

checkSect = any(isnan(file.Time),2);
[idx,~] = find(checkSect == 1);

% Get total number of trials
NumTrials = ((numel(idx)-2)+3)/6;

% Validate Inputs
if KAM_RawData(whichNum).Count == "U"
    c = 1;
else
    c = 0;
end

% Parameter Feedback
if c == 1
    countfeedback = "counting up.";
elseif c == 0
    countfeedback = "counting down.";
end

ParamFeedback = ["Outputting from" KAM_RawData(whichNum).Filename "while" countfeedback];
disp(join(ParamFeedback))

% Convert Countdown to Countup
if c == 1
    file.TrialTime(:) = abs(file.TrialTime(:)-300);
end

%% Separate trials into different rows of a cell array
TrialsSeparated{1,1} = 1;
TrialsSeparated{1,2} = file(1:idx(1)-1,2:3);
for k = 2:NumTrials
    TrialsSeparated{k,1} = k;
    TrialsSeparated{k,2} = file(idx((k-1)*6)+1:idx((((k-1)*2)+1)*3)-3,2:3);
end

%% Extract trials into output tables
KAM_Output(whichNum).Subject = KAM_RawData(whichNum).Subject;
TI = 0;
TO = 0;
WS = 0;
ITL = 0;
MKT = 0;
cxl = {'N'};

for z = 1:NumTrials
    PickATrial = join(["Trial" z],'');
    if KAM_RawData(whichNum).(PickATrial) == "Toe In"
        if TI == 1 && cxl{1} ~= 'Y'
            cxl = inputdlg('\fontsize{13} You have entered Toe In for multiple different trials. Would you like to cancel? Please type Y for yes and N for no.','Warning',[1,50],"Y",struct("Resize",'off',"WindowStyle",'modal',"Interpreter",'tex'));
        end
        KAM_Output(whichNum).Toe_In = TrialsSeparated{z,2};
        TI = 1;
    elseif KAM_RawData(whichNum).(PickATrial) == "Toe Out"
        if TO == 1 && cxl{1} ~= 'Y'
            cxl = inputdlg('\fontsize{13} You have entered Toe Out for multiple different trials. Would you like to cancel? Please type Y for yes and N for no.','Warning',[1,50],"Y",struct("Resize",'off',"WindowStyle",'modal',"Interpreter",'tex'));
        end
        KAM_Output(whichNum).Toe_Out = TrialsSeparated{z,2};
        TO = 1;
    elseif KAM_RawData(whichNum).(PickATrial) == "Wider Steps"
        if WS == 1 && cxl{1} ~= 'Y'
            cxl = inputdlg('\fontsize{13} You have entered Wider Steps for multiple different trials. Would you like to cancel? Please type Y for yes and N for no.','Warning',[1,50],"Y",struct("Resize",'off',"WindowStyle",'modal',"Interpreter",'tex'));
        end
        KAM_Output(whichNum).Wider_Steps = TrialsSeparated{z,2};
        WS = 1;
    elseif KAM_RawData(whichNum).(PickATrial) == "Ipsilateral Trunk Lean"
        if ITL == 1 && cxl{1} ~= 'Y'
            cxl = inputdlg('\fontsize{13} You have entered Ipsilateral Trunk Lean for two multiple trials. Would you like to cancel? Please type Y for yes and N for no.','Warning',[1,50],"Y",struct("Resize",'off',"WindowStyle",'modal',"Interpreter",'tex'));
        end
        KAM_Output(whichNum).Ipsilateral_Trunk_Lean = TrialsSeparated{z,2};
        ITL = 1;
    elseif KAM_RawData(whichNum).(PickATrial) == "Medial Knee Thrust"
        if MKT == 1 && cxl{1} ~= 'Y'
            cxl = inputdlg('\fontsize{13} You have entered Medial Knee Thrust for multiple different trials. Would you like to cancel? Please type Y for yes and N for no.','Warning',[1,50],"Y",struct("Resize",'off',"WindowStyle",'modal',"Interpreter",'tex'));
        end
        KAM_Output(whichNum).Medial_Knee_Thrust = TrialsSeparated{z,2};
        MKT = 1;
    end

    switch cxl{1} % Validate cancel input
    case 'y'
        cxl{1} = 'Y';
    case 'n'
        cxl{1} = 'N';
    case 'yes' 
        cxl{1} = 'Y';
    case 'Yes'
        cxl{1} = 'Y';
    case 'no'
        cxl{1} = 'N';
    case 'No'
        cxl{1} = 'N';
    case 'Y'
        %Fine
    case 'N'
        %Fine
    otherwise
        warning("FinalFunc:BadCancel","Unknown input detected, cancelling.")
        cxl{1} = 'Y';
        
    end
end

% Cancel last output
if cxl{1} == 'Y'
    KAM_Output = KAM_Output(1:numel(KAM_Output)-1);
end
end

% Cancel last input
if numel(KAM_Output) ~= numel(KAM_RawData)
    KAM_RawData = KAM_RawData(1:numel(KAM_RawData)-1);
end

% If cancelled first input/output, delete var instead of having 1x0 string
if numel(KAM_Output) == 0
    clear('KAM_Output')
    clear('KAM_RawData')
end

save KAM_Output.mat
save KAM_RawData.mat

return

%% If necessary, clear existing variables from memory (Run Section)

clear('KAM_Output') %#ok
clear('KAM_RawData')
save KAM_Output.mat
save KAM_RawData.mat


%% Template for Extraction of data from participant with specific subject ID

KAM_Output([KAM_Output.Subject] == "SXX").Field  % Replace 'field' with field to be extracted