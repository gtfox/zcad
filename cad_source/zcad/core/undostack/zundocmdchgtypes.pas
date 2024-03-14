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
{$MODE OBJFPC}{$H+}
{$ModeSwitch advancedrecords}
{$INCLUDE zengineconfig.inc}
unit zUndoCmdChgTypes;
interface
uses
  zeundostack,zebaseundocommands,uzeentity,varmandef,
  uzcEnitiesVariablesExtender,gzUndoCmdChgData2,uzedrawingdef,
  uzestyleslayers;

type
  TEmpty=record
  end;
  TSharedEmpty=specialize GSharedData<TEmpty>;
  TAfterChangeDoNothing=class;
  TAfterChangeEmpty=specialize GAfterChangeData<TEmpty,TSharedEmpty,TAfterChangeDoNothing>;

  TSharedPEntityData=specialize GSharedData<PGDBObjEntity>;
  TAfterEntChangeDo=class;
  TAfterChangePDrawing=specialize GAfterChangeData<PTDrawingDef,TSharedPEntityData,TAfterEntChangeDo>;
  TAfterEntChangeDo=class
    class procedure AfterDo(SD:TSharedPEntityData;ADD:TAfterChangePDrawing);
  end;



  TAfterChangeDoNothing=class
    class procedure AfterDo(SD:TSharedEmpty;ADD:TAfterChangeEmpty);
  end;

implementation

class procedure TAfterEntChangeDo.AfterDo(SD:TSharedPEntityData;ADD:TAfterChangePDrawing);
begin
  SD.Data^.YouChanged(ADD.Data^);
end;

class procedure TAfterChangeDoNothing.AfterDo(SD:TSharedEmpty;ADD:TAfterChangeEmpty);
begin
end;

end.
