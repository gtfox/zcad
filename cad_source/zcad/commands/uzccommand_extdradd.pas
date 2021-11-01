{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$mode delphi}
unit uzccommand_extdradd;

{$INCLUDE def.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrvectortypes,uzcdrawings,uzcdrawing,uzcstrconsts,uzeentityextender,
  uzcinterface,uzcutils,gzctnrstl,gutil;

function extdrAdd_com(operands:TCommandOperands):TCommandResult;

implementation

function extdrAdd_com(operands:TCommandOperands):TCommandResult;
var
  extdr:TMetaEntityExtender;
  pv:pGDBObjEntity;
  ir:itrec;
  i:integer;
  count:integer;
begin
  try
    if EntityExtenders.tryGetValue(uppercase(operands),extdr) then begin
      count:=0;
      pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if pv^.Selected then
          if pv^.GetExtension(extdr)=nil then begin
            pv^.AddExtension(extdr.Create(pv));
            inc(count);
          end;
        pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
    end else
      ZCMsgCallBackInterface.TextMessage(format('Extender "%s" not found',[operands]),TMWOHistoryOut);
  finally
    result:=cmd_ok;
  end;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@extdrAdd_com,'extdrAdd',CADWG or CASelEnts,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
