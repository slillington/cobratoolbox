
function [parsed_updated,mainText_new, final_list] = colourNode(parsed,fname_out,list_Rxn,list_Met,list_Colour_Met)

% Change the colours of metabolite nodes

%INPUTs
%
% fname            An XML file to be modified to include annotations
% fanme_out        The name of the output XML file
% parsed           A parsed model structure generated by 'parseCD' function
%
% list_Rxn       A list of reaction IDs that need to be highilighted by
%                changing the colour attributes of the reaciton links in
%                the CellDesigner model. The first column stores a list of
%                reaction IDs whose reaction links need to be highlighted,
%                whereas the second column stores a list of Html Colours.
%
%OPTIONAL INPUTS
%
% list_Met           The list of metabolite IDs to be highlighed
% list_Colour_Met    Colour Hex Codes for Metabolite IDs in 'list_Met'.
%
%
%OPTIONAL OUTPUT
%
% parsed_updated     An updated parsed model structure.
% mainText_new       The lines of the new XML file.
% final_list         A list of the metabolite nodes whose colour attributes
%                    are modified.
%
%
%
%EXAMPLE
% [var]=colourNode('fatty_acid_synthesis_Miriam__rxns_test.xml','fatty_acid_synthesis_Miriam__rxns_test_colour.xml',parsed_fatty_acid,list_nodes)
%

%%
        defRxnColour='FFCDE2BD'; % remove the prefix "#"
        defMetColour='ffe7a45d'; 
%%    


if strcmp(list_Met,'false')
    metMode=0;
else
    metMode=1;
    if nargin<5
        list_Colour_Met(1:size(list_Met,1),1:size(list_Met,2))=strrep({defMetColour},'#',''); % the default colour is red
    end
    
end

if (nargin<4||isempty(list_Met))&&(metMode~=0)
    list_Met={'no[c]',[];'h[c]','adp[c]'}
    list_Colour_Met(1:size(list_Met,1),1:size(list_Met,2))={defMetColour}
end


if nargin<2 || isempty(fname_out)
    
    [fname_out, fpath]=uiputfile('*.xml','CellDesigner SBML Source File');
    if(fname_out==0)
        return;
    end
    f_out=fopen([fpath,fname_out],'w');
else
    f_out=fopen(fname_out,'w');
end

% if nargin<1 || isempty(fname)
%     [fname, fpath]=uigetfile('*.xml','CellDesigner SBML Source File');
%     if(fname==0)
%         return;
%     end
%     f_id=fopen([fpath,fname],'r');
% else
%     f_id=fopen(fname,'r');
%
% end



if isfield(parsed.r_info,'XMLtext');
    for n=1:length({parsed.r_info.XMLtext(:).str}')
        MainTxt(n,1)=cellstr(parsed.r_info.XMLtext(n).str);
    end
    
    
else
    errordlg('The XMLtext doesn''t exit in the parsed model structure');
end



r_info=parsed.r_info;

list_nodes=list_Rxn;


% There are three different IDs for each reaction



[ID_row,ID_Column]=size(r_info.ID);

for m=1:ID_row;
    for n=1:ID_Column;
        r=iscellstr(r_info.ID(m,n));
        if ~r;
            %results(or,1)=m;
            %results(or,2)=n;
            r_info.ID(m,n)={'unknown'};
            disp(r_info.ID{m,n});
        end;
    end;
end


h = showprogress(0,'progressing')

num=[];




% num_1=find(ismember(r_info.ID(:,3),list_nodes(:,1)))
% % num_2=find(ismember(r_info.ID(:,2),list_nodes(:,1)))
% % num_3=find(ismember(r_info.ID(:,3),list_nodes(:,1)))
% %
% % [biggest,ind]=max([length(num_1),length(num_2),length(num_3)])
% %
% % switch ind
% %     case 1
% %         num=num_1;
% %     case 2
% %         num=num_2;
% %     case 3
% %         num=num_3;
% % end
% num=num_1;

for i=1:length(list_nodes);
    
    %  waitbar(((i/length(list_nodes))*1/4)/4,h);
    
    %if ~isempty(list_nodes{i,2})
    re=find(~cellfun('isempty',strfind(r_info.ID(:,3),list_nodes{i,1})))
    if isempty(re)
        re=find(~cellfun('isempty',strfind(r_info.ID(:,2),list_nodes{i,1})))
        if isempty(re)
            re=find(~cellfun('isempty',strfind(r_info.ID(:,1),list_nodes{i,1})))
            
            if isempty(re)
                errordlg('The provided reaction cannot be found in the parsed model structure');
            else
                num(i)=re(1);
            end
        else
            num(i)=re(1);
        end
    else
        num(i)=re(1);  % obtain the number of reaction whose corresponding nodes on the layout will be highlighted.
    end
    % end
    
end



% if the provided reaction IDs cannot be found in the third column of the
% reaction list, then the following codes search the column 2 intead for reaction IDs.


% if isempty(num)
%     for i=1:length(list_nodes);
%         num(i)=find(~cellfun('isempty',strfind(r_info.ID(:,2),list_nodes{i,1})))
%     end
% end

% wiP=size(r_info.baseReactant,2)
% he=length(num);
% baseR=cell(he,wiR);
% baseP=cell(he,wiP);

baseC_R={};
baseC_P={};


total_length=length(num);
progress=zeros(10,1);
for ii=1:10;
    
    progress(ii,1)=ii*floor(total_length/10)
    
end

    
        

for i=1:length(num)  % "num" contains number of reaction nodes
    if ismember(i, progress)~=0||i==total_length;
        showprogress((i/total_length*2/4)/4,h);
    end
    
    
    baseR.(list_nodes{i})=r_info.baseReactant(num(i),:)
    
    % add other reactants
    len_r_st=length(baseR.(list_nodes{i}))
    len_r_ed=length(r_info.reactant(num(i),:))
    baseR.(list_nodes{i})(len_r_st+1:len_r_st+len_r_ed)=r_info.reactant(num(i),:);
    
    % include all the baseProducts
    baseP.(list_nodes{i})=r_info.baseProduct(num(i),:)
    
    % add other products.
    len_r_st=length(baseP.(list_nodes{i}))
    len_r_ed=length(r_info.product(num(i),:))
    baseP.(list_nodes{i})(len_r_st+1:len_r_st+len_r_ed)=r_info.product(num(i),:);
    
    %% by default
    if size(list_nodes,2)<2||isempty(list_nodes{i,2});
        

        list_nodes(i,2)={defRxnColour}; % a default color is set.
    end
    
    
    %% highlight reactions
    
    
    for c=1:size(baseR.(list_nodes{i}),2);
        if ~isempty(baseR.(list_nodes{i}){c})
            baseC_R.(list_nodes{i})(c)=list_nodes(i,2)
            
%            baseC_R.(list_nodes{i})(c)=strrep(list_nodes(i,2),'#',''); % remove the '#' sign from the hex codes.
%             if length(list_nodes{i,2})<8;
%                 
%                 list_nodes{i,2}=['FF',list_nodes{i,2}];  % add the compatibility with six-digit code
%             end
        end
    end
    
    
    for c=1:size(baseP.(list_nodes{i}),2);
        if ~isempty(baseP.(list_nodes{i}){c})
            
            
            baseC_P.(list_nodes{i})(c)=list_nodes(i,2)
%            baseC_P.(list_nodes{i})(c)=strrep(list_nodes(i,2),'#',''); % remove the '#' sign from the hex codes.
%             if length(list_nodes{i,2})<8;
%                 
%                 list_nodes{i,2}=['FF',list_nodes{i,2}];  % add the compatibility with six-digit code
%             end
        end
    end
    
    if metMode~=0;  % check if the mets are needed to be highlighted
        numMet=size(list_Met,1)
        
        if i<=numMet  % the number of lines of metaoblites may be less than that of reactions
            for t=1:size(list_Met(i,:),2) % number of metabolites
                if ~isempty(list_Met{i,t})
                    met(i,t)=retrieveMet(parsed,list_Met(i,t))
                    list_M_species(i,2*t-1)={met(i,t).speciesAlliens}
                    
                end
            end
            
        end
    end
    
    
    for r=2:2:length(baseR.(list_nodes{i}))
        
        list_R(i,r/2)=baseR.(list_nodes{i})(r);
    end
    for d=1:2:length(baseR.(list_nodes{i}))-1
        list_R_M(i,(d+1)/2)=baseR.(list_nodes{i})(d)
    end
    
    for r=2:2:length(baseP.(list_nodes{i}))
        
        list_P(i,r/2)=baseP.(list_nodes{i})(r);
    end
    
    
    for d=1:2:length(baseP.(list_nodes{i}))-1
        list_P_M(i,(d+1)/2)=baseP.(list_nodes{i})(d)
    end
    
    
    
    for r=2:2:length(baseC_R.(list_nodes{i}))
        list_C_R(i,r/2)=baseC_R.(list_nodes{i})(r); % each reaction has the same color
    end
    
    for r=2:2:length(baseC_P.(list_nodes{i}))
        list_C_P(i,r/2)=baseC_P.(list_nodes{i})(r); % each reaction has the same color
    end
    
    
end



% extract list of pairs of metabolite identifies

% each pair contains a metabolite ID and a alias

%
% for i=1:length(num)
%
%
%
%
%
% end


% numOfLine=0;
% MainTxt={};

% while ~feof(f_id);
%
%     numOfLine=numOfLine+1;
%     rem=fgets(f_id);
%     %     try
%     MainTxt(numOfLine,1)=cellstr(rem);
%
%     %     catch
%     %         disp(rem);
%     %     end
%
% end


toFD=[];
toFD.str=[];

% celldesigner nodes


toFD(1).str='<celldesigner:speciesAlias';   % starting line

listID={'id','species'};

toFD(2).str='<celldesigner:paint';  % ending line
toFD(3).str='</celldesigner:speciesAlias>';

% toFD(3).str='</celldesigner:listOfSpeciesAliases>';

listColour={'color','scheme'}


sectionKey(1).str='<celldesigner:listOfSpeciesAliases>';

sectionKey(2).str='</celldesigner:listOfSpeciesAliases>';




% sectionKey(1).str='<celldesigner:extension>';
% sectionKey(2).str='</celldesigner:extension>';


new=0;

secKey=0;


a=0;
final_list={};
found=0;



showprogress(3/4,h);

for t=1:length(MainTxt);
    
    
    
    new=new+1;
    
    MainTxt_new(new,1)=MainTxt(t);
    
    section_1=strfind(MainTxt(t),sectionKey(1).str);
    section_2=strfind(MainTxt(t),sectionKey(2).str);
    
    
    if (~isempty(section_1{1,1}))
        secKey=1;
        fprintf('found the metKeyword: %s',MainTxt{t});
    elseif (~isempty(section_2{1,1}))
        secKey=0;
        fprintf('Cannot found the metKeyword:  %s',MainTxt{t});
    end
    
    
    result=strfind(MainTxt(t),toFD(1).str)
    
    if ~isempty(result{1,1})&&(secKey==1)
        
        
        [st,ed]=position(MainTxt{t},listID{1})  % retrieve 'ID' from the line
        
        str=MainTxt{t}
        
        if found==0;
            for m=1:size(list_R,1);
                
                for n=1:size(list_R,2);
                    
                    if strcmp(list_R(m,n),str(st:ed))
                        
%                         if m==9
%                             disp('good')
%                         end
%                         
                        if metMode~=0&&m<=numMet;
                            
                            for dd=1:length(list_Met(m,:)) % list_Met contains one ID for each metabolite, rather than a pair (two IDs) for each metabolite.
                                 
                                if strcmp(list_R_M(m,n),list_M_species(m,dd*2-1)); %% Highlighting metabolites
                                    
                                    a=a+1;
                                    final_list(a,1)={str(st:ed)};
                                    
%                                     list_Colour_Met{m,dd}=colourCode(list_Colour_Met{m,dd})
                                    
                                    new_colour=list_Colour_Met(m,dd)
                                    % new_colour=list_C_R(m,n)
                                    %                     if strcmp({str(st:end)},'sa6');
                                    %                         error('found');
                                    %                     end
                                    found=1;
                                    break
                                    
                                else
                                    a=a+1;
                                    final_list(a,1)={str(st:ed)};
                                    new_colour=list_C_R(m,n)
                                    found=1;
                                    
                                end
                            end
                            
                        else
                            
                            a=a+1;
                            final_list(a,1)={str(st:ed)};
                            new_colour=list_C_R(m,n)
                            found=1;
                            
                            
                        end
                        
                        
                    end
                end
            end
            
            %          if found==0
            
            for p=1:size(list_P,1);
                
                for q=1:size(list_P,2);
                    
                    %                     if p==31&&q==1;
                    %                         disp('good');
                    %                     end
                    
%                     if strcmp(str(st:ed),'sa148');
%                         disp('good');
%                     end
                    if strcmp(list_P(p,q),str(st:ed))
                        
                        
                        
                        if metMode~=0&&p<=numMet
                            for ddP=1:length(list_Met(p,:))
                                
                                if strcmp(list_P_M(p,q),list_M_species(p,ddP*2-1)); %% Highlighting metabolites
                                    %                                     if strcmp(list_P_M(p,q),'s5962')
                                    %
                                    %                                         disp('found');
                                    %                                     end
                                    a=a+1;
                                    final_list(a,2)={str(st:ed)};
%                                     list_Colour_Met{m,ddP}=colourCode(list_Colour_Met{p,ddP})
                                    new_colour=list_Colour_Met(p,ddP)
                                    %new_colour=list_C_P(p,q)
                                    
                                    found=1;
                                    
                                    % disp(list_M_species(p,dd))
                                    break
                                else
                                    
                                    a=a+1;
                                    final_list(a,2)={str(st:ed)};
                                    new_colour=list_C_P(p,q)
                                    
                                    found=1;
                                end
                            end
                        else
                            
                            a=a+1;
                            final_list(a,2)={str(st:ed)};
                            new_colour=list_C_P(p,q)
                            
                            found=1;
                            
                            
                        end
                    end
                end
            end
            
            
        end
        
        %find(cellfun('isempty',strcmp(str,MainTxt(t)(st:ed),)))
        
    end
    
    
    res=strfind(MainTxt(t),toFD(2).str)
    
    if ~isempty(res{1,1})&&(secKey==1)&&found==1;
        
        %for c=1:length(listColour);
        if strcmp(listColour(1),'color')
            [st,ed]=position(MainTxt_new{new},listColour{1})
            str_colour=MainTxt_new{new};
            
%             if strcmp(str_colour(st:ed),str_colour)
            new_colour=colourCode(char(new_colour))
% try 
            str_colour(st:ed)=new_colour;
% catch
%     disp('good');
% end

            MainTxt_new{new}=str_colour;
%             end
            
            
        end
        %end
        
    end
    
    
    res_end=strfind(MainTxt(t),toFD(3).str);
    if ~isempty(res_end{1,1})
        found=0;
        %break;
        
    end
    
end

showprogress(3.5/4,h);

%% old version of the "write" funciton

% for d=1:length(MainTxt_new);
%
%     fprintf(f_out,'%s\n',char(MainTxt_new(d)));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fclose(f_out);
mainText_new=MainTxt_new;

for d=1:length(MainTxt_new)
    parsed.r_info.XMLtext(d).str=MainTxt_new(d,1)
end
parsed_updated=parsed;


writeCD(parsed_updated,fname_out)

showprogress(4/4,h);

close(h)

end


function [p_st,p_ed]=position(str_long,str_ID)
%% name='metaid';

ind_pos=strfind(str_long,str_ID);

l=length(str_ID)+2;
try
    p_st=ind_pos(1)+l
catch
    error('cannot find the Keyword in the the line')
end

end_rem=strfind(str_long(p_st:end),'"');

p_ed=end_rem(1)+p_st-2;


end

function [new_code]=colourCode(code)

code=strrep(code,'#',''); % remove the '#' sign from the hex codes.
if length(code)<8;
    
    code=['FF',code];  % add the compatibility with six-digit code
end
new_code=code;
end

