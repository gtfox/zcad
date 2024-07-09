{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$IFDEF FPC}
  {$CODEPAGE UTF8}
  {$MODE DELPHI}
{$ENDIF}
unit uzcCommand_Find;
{$INCLUDE zengineconfig.inc}

interface
uses
  CsvDocument,
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrVectorTypes,
  uzeparserenttypefilter,uzeparserentpropfilter,uzeentitiestypefilter,
  uzelongprocesssupport,uzeparser,uzcoimultiproperties,uzedimensionaltypes,
  uzcoimultipropertiesutil,varmandef,uzcvariablesutils,Masks,uzcregother,
  uzeparsercmdprompt,uzcinterface,uzcdialogsfiles,uzegeometrytypes,
  uzgldrawcontext,uzcEnitiesVariablesExtender,UGDBOpenArrayOfPV,UGDBSelectedObjArray,
  uzeconsts,uzcstrconsts,LazUTF8,LazUTF16;

const
  CMDNFind='Find';
  CMDNFindFindParams='FindParams';

procedure ShowFindCommandParams;

implementation

resourcestring
  RSFCPOptions='Options';
    RSFCPOptionsCaseSensitive='Case sensitive';
    RSFCPOptionsWholeWords='Whole words';
  RSFCPArea='Area';
    RSFCPAreaInSelection='In selection';
    RSFCPAreaInTextContent='In text content=';
    RSFCPAreaInTextTemplate='In text template';
    RSFCPAreaInVariables='In variables';
    RSFCPAreaVariables='Variables';
  RSFCPAction='Action';
    RSFCPActionSelectResult='Select result';


const
  WordBreakChars = [#0..#31,'.', ',', ';', ':', '"', '''', '!', '?', '[', ']',
               '(', ')', '{', '}', '^', '-', '=', '+', '*', '/', '\', '|', ' '];

type
  //** Тип данных для отображения в инспекторе опций
  TCompareOptions=record
    CaseSensitive:boolean;
    WholeWords:boolean;
  end;
  TSearhArea=record
    InSelection:boolean;
    InTextContent:boolean;
    InTextTemplate:boolean;
    InVariables:boolean;
    Variables:string;
  end;
  TSelectResult=(SR_Select,SR_AddToSelection,SR_Nohhing);
  TFindAction=record
    SelectResult:TSelectResult;
  end;
  TFindCommandParam=record
    Options:TCompareOptions;
    Area:TSearhArea;
    Action:TFindAction;
  end;

var
  FindCommandParam:TFindCommandParam; //**<  Переменная содержащая опции команды

function GetFindCommandParam:PUserTypeDescriptor;
begin
  result:=SysUnit^.TypeName2PTD('TFindCommandParam');
  if result=nil then begin
    result:=SysUnit^.RegisterType(TypeInfo(FindCommandParam));
    SysUnit^.SetTypeDesk(TypeInfo(FindCommandParam),[RSFCPOptions,RSFCPArea,RSFCPAction],[FNProgram]);
    SysUnit^.SetTypeDesk(TypeInfo(TCompareOptions),[RSFCPOptionsCaseSensitive,RSFCPOptionsWholeWords],[FNProgram]);
    SysUnit^.SetTypeDesk(TypeInfo(TSearhArea),[RSFCPAreaInSelection,RSFCPAreaInTextContent,RSFCPAreaInTextTemplate,RSFCPAreaInVariables,RSFCPAreaVariables],[FNProgram]);
    SysUnit^.SetTypeDesk(TypeInfo(TFindAction),[RSFCPActionSelectResult],[FNProgram]);
  end;
end;

procedure ShowFindCommandParams;
begin
  zcShowCommandParams(GetFindCommandParam,@FindCommandParam);
end;

function FindCommandParam_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  ShowFindCommandParams;
  result:=cmd_ok;
end;

function CheckStr(FindIn,Text:TDXFEntsInternalStringType):boolean;
var
  i:integer;
begin
  if not FindCommandParam.Options.CaseSensitive then
    FindIn:=UnicodeUpperCase(FindIn);
  i:=pos(Text,FindIn);
  result:=i>0;
  if result and FindCommandParam.Options.WholeWords then begin
    if i>1 then
      result:=(ord(FindIn[i-1])<256)and(FindIn[i-1] in WordBreakChars);
    if result then
      if i+length(text)<=length(FindIn) then
        result:=(ord(FindIn[i+length(text)])<256)and(FindIn[i+length(text)] in WordBreakChars);
  end;
end;

procedure FindInArray(const text:string; constref arr:GDBObjOpenArrayOfPV;var Finded:GDBObjOpenArrayOfPV);
var pv:pGDBObjEntity;
    ir:itrec;
    pvt:TObjID;
    utext:TDXFEntsInternalStringType;
    isNeedToAdd:Boolean;
begin
  utext:=Text;
  pv:=arr.beginiterate(ir);
  if pv<>nil then
  repeat
    pvt:=pv.GetObjType;
    isNeedToAdd:=False;
    if (pvt=GDBMTextID)or(pvt=GDBTextID) then begin
      if FindCommandParam.Area.InTextContent then
        isNeedToAdd:=CheckStr(PGDBObjText(pv)^.Content,utext);
      if not isNeedToAdd then
        if FindCommandParam.Area.InTextTemplate then
          isNeedToAdd:=CheckStr(PGDBObjText(pv)^.Template,utext);
    end;
    if isNeedToAdd then
      Finded.PushBackData(pv);
    pv:=arr.iterate(ir);
  until pv=nil;
end;


procedure FindInSelection(const text:string; PSelArr:PGDBSelectedObjArray; var Finded:GDBObjOpenArrayOfPV);
var
  Selection:GDBObjOpenArrayOfPV;
  ir:itrec;
  psd:pselectedobjdesc;
begin
  Selection.init(PSelArr^.Count);
  psd:=PSelArr^.beginiterate(ir);
  if psd<>nil then repeat
    Selection.PushBackData(psd.objaddr);
    psd:=PSelArr^.iterate(ir);
  until psd=nil;
  FindInArray(text,Selection,Finded);
  Selection.Clear;
  Selection.Done;
end;

function Find_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  Finded:GDBObjOpenArrayOfPV;
  PSelArr:PGDBSelectedObjArray;
  ir:itrec;
  pv:pGDBObjEntity;
  text:string;
begin
  if operands<>''then begin
    if not FindCommandParam.Options.CaseSensitive then
      text:=UTF8UpperString(operands)
    else
      text:=operands;
    Finded.init(100);
    PSelArr:=@drawings.GetCurrentDWG.SelObjArray;
    if (FindCommandParam.Area.InSelection)and(PSelArr^.Count>0) then
      FindInSelection(text,PSelArr,Finded)
    else
      FindInArray(text,drawings.GetCurrentDWG.GetCurrentROOT.ObjArray,Finded);
    ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesFounded,[Finded.Count]),TMWOHistoryOut);

    if FindCommandParam.Action.SelectResult<>SR_Nohhing then begin
      if FindCommandParam.Action.SelectResult=SR_Select then begin
        drawings.GetCurrentDWG.SelObjArray.Free;
        drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
      end;
      pv:=Finded.beginiterate(ir);
      if pv<>nil then
      repeat
        pv^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);
        pv:=Finded.iterate(ir);
      until pv=nil;
    end;

    Finded.Clear;
    Finded.Done;
  end else
    zcShowCommandParams(GetFindCommandParam,@FindCommandParam);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  FindCommandParam.Options.CaseSensitive:=False;
  FindCommandParam.Options.WholeWords:=False;
  FindCommandParam.Area.InSelection:=True;
  FindCommandParam.Area.InTextContent:=True;
  FindCommandParam.Area.InTextTemplate:=false;
  FindCommandParam.Area.InVariables:=false;
  FindCommandParam.Area.Variables:='NMO_Name';
  FindCommandParam.Action.SelectResult:=SR_Select;

  CreateZCADCommand(@FindCommandParam_com,'FindParams',0,0);
  CreateZCADCommand(@Find_com,CMDNFind,CADWG,0);
  CreateZCADCommand(@Find_com,'FindNext',CADWG,0);
  CreateZCADCommand(@Find_com,'FindPrev',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
