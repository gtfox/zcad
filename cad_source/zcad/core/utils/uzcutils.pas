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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

{**Модуль утилит зкада}
unit uzcutils;
{$INCLUDE zcadconfig.inc}


interface
uses uzeutils,LCLProc,zcmultiobjectcreateundocommand,uzepalette,
     uzeentityfactory,uzgldrawcontext,uzcdrawing,uzestyleslinetypes,uzcsysvars,
     uzestyleslayers,sysutils,uzbtypesbase,uzbtypes,uzcdrawings,varmandef,
     uzeconsts,UGDBVisibleOpenArray,uzeentgenericsubentry,uzeentity,
     uzegeometrytypes,uzeentblockinsert,uzcinterface,gzctnrvectortypes;

  {**Добавление в чертеж примитива с обвязкой undo
    @param(PEnt Указатель на добавляемый примитив)
    @param(Drawing Чертеж куда будет добавлен примитив)}
  procedure zcAddEntToDrawingWithUndo(const PEnt:PGDBObjEntity;var Drawing:TZCADDrawing);

  {**Добавление в текущий чертеж примитива с обвязкой undo
    @param(PEnt Указатель на добавляемый примитив)}
  procedure zcAddEntToCurrentDrawingWithUndo(const PEnt:PGDBObjEntity);

  procedure zcAddEntToCurrentDrawingConstructRoot(const PEnt: PGDBObjEntity);

  procedure zcClearCurrentDrawingConstructRoot;
  procedure zcFreeEntsInCurrentDrawingConstructRoot;

  {**Получение "описателя" выбраных примитивов в текущем "корне" текущего чертежа
    @return(Указатель на первый выбранный примитив и общее количество выбраных примитивов)}
  function zcGetSelEntsDeskInCurrentRoot:TSelEntsDesk;

  {**Выставление свойств для примитива в соответствии с настройками текущего чертежа
  процедуры устанавливающие свойства должны быть заранее зарегистрированные с помощью
  zeRegisterEntPropSetter
    @param(PEnt Указатель на примитив)}
  procedure zcSetEntPropFromCurrentDrawingProp(const PEnt: PGDBObjEntity);

  {**Помещение в стек undo маркера начала команды. Используется для группировки
     операций отмены. Допускаются вложеные команды. Количество маркеров начала и
     конца должно совпадать
    @param(CommandName Имя команды. Будет показано в окне истории при отмене\повторе)
    @param(PushStone Поместить в стек ундо "камень". Ундо не сможет пройти через него пока не завершена текущая команда)}
  procedure zcStartUndoCommand(CommandName:GDBString;PushStone:boolean=false);

  {**Помещение в стек undo маркера конца команды. Используется для группировки
     операций отмены. Допускаются вложеные команды. Количество маркеров начала и
     конца должно совпадать}
  procedure zcEndUndoCommand;

  {**Добавление в стек undo маркера начала команды при необходимости
    @param(UndoStartMarkerPlaced Флаг установки маркера: false - маркер еще не поставлен, ставим маркер, поднимаем флаг. true - ничего не делаем)
    @param(CommandName Имя команды. Будет показано в окне истории при отмене\повторе)
    @param(PushStone Поместить в стек ундо "камень". Ундо не сможет пройти через него пока не завершена текущая команда)}
  procedure zcPlaceUndoStartMarkerIfNeed(var UndoStartMarkerPlaced:boolean;const CommandName:GDBString;PushStone:boolean=false);

  {**Добавление в стек undo маркера конца команды при необходимости
    @param(UndoStartMarkerPlaced Флаг установки маркера начала: true - маркер начала поставлен, ставим маркер конца, сбрасываем флаг. false - ничего не делаем)}
  procedure zcPlaceUndoEndMarkerIfNeed(var UndoStartMarkerPlaced:boolean);

  {**Показать параметры команды. Пока только в инспекторе объектов, потом может
     добавлю возможность показа и редактирования параметров в командной строке
    @param(PDataTypeDesk Указатель на описание структуры параметров (обычно то что возвращает SysUnit^.TypeName2PTD))
    @param(PInstance Указатель на параметры)}
  procedure zcShowCommandParams(const PDataTypeDesk:PUserTypeDescriptor;const PInstance:Pointer);

  {**Завершить показ параметров команды, вернуть содержиммое инспектора к умолчательному состоянию}
  procedure zcHideCommandParams();

  {**Перерисовать окно текущего чертежа}
  procedure zcRedrawCurrentDrawing();

  {**Выбрать примитив}
  procedure zcSelectEntity(pp:PGDBObjEntity);

function GDBInsertBlock(own:PGDBObjGenericSubEntry;BlockName:GDBString;p_insert:GDBVertex;
                        scale:GDBVertex;rotate:Double;needundo:Boolean=false
                        ):PGDBObjBlockInsert;

function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: Double; s: pansichar):PGDBObjBlockInsert;
function zcGetRealSelEntsCount:integer;
implementation
function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: Double; s: pansichar):PGDBObjBlockInsert;
var
  pb:pgdbobjblockinsert;
  nam:gdbstring;
  DC:TDrawContext;
  CreateProc:TAllocAndInitAndSetGeomPropsFunc;
begin
  result:=nil;
  if pos(DevicePrefix, uppercase(s))=1  then
                                            begin
                                                nam:=copy(s,length(DevicePrefix)+1,length(s)-length(DevicePrefix));
                                                CreateProc:=_StandartDeviceCreateProcedure;
                                            end
                                        else
                                            begin
                                                 nam:=s;
                                                 CreateProc:=_StandartBlockInsertCreateProcedure;
                                            end;
  if assigned(CreateProc)then
                           begin
                               PGDBObjEntity(pb):=CreateProc(owner,[point.x,point.y,point.z,scale,angle,nam]);
                               zeSetEntityProp(pb,layeraddres,LTAddres,color,LW);
                               if ownerarray<>nil then
                                               ownerarray^.AddPEntity(pb^);
                           end
                       else
                           begin
                                pb:=nil;
                                debugln('{E}ENTF_CreateBlockInsert: BlockInsert entity not registred');
                                //programlog.LogOutStr('ENTF_CreateBlockInsert: BlockInsert entity not registred',lp_OldPos,LM_Error);
                           end;
  if pb=nil then exit;
  //setdefaultproperty(pb);
  pb.pattrib := nil;
  pb^.BuildGeometry(drawings.GetCurrentDWG^);
  pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
  DC:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pb^.formatEntity(drawings.GetCurrentDWG^,dc);
  owner.ObjArray.ObjTree.CorrectNodeBoundingBox(pb^);
  result:=pb;
end;
function zcGetRealSelEntsCount:integer;
var
  pobj: pGDBObjEntity;
  ir:itrec;
begin
  result:=0;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    inc(result);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
end;
procedure zcAddEntToDrawingWithUndo(const PEnt:PGDBObjEntity;var Drawing:TZCADDrawing);
var
    domethod,undomethod:tmethod;
begin
     SetObjCreateManipulator(domethod,undomethod);
     with PushMultiObjectCreateCommand(Drawing.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
     begin
          AddObject(PEnt);
          comit;
     end;
end;
procedure zcAddEntToCurrentDrawingWithUndo(const PEnt:PGDBObjEntity);
begin
     zcAddEntToDrawingWithUndo(PEnt,PTZCADDrawing(drawings.GetCurrentDWG)^);
end;
procedure zcStartUndoCommand(CommandName:GDBString;PushStone:boolean=false);
begin
     PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker(CommandName);
     if PushStone then
       PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStone;
end;
procedure zcAddEntToCurrentDrawingConstructRoot(const PEnt: PGDBObjEntity);
begin
  zeAddEntToRoot(PEnt,drawings.GetCurrentDWG^.ConstructObjRoot);
end;
procedure zcClearCurrentDrawingConstructRoot;
begin
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
end;
procedure zcFreeEntsInCurrentDrawingConstructRoot;
begin
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
end;
procedure zcEndUndoCommand;
begin
     PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
end;
procedure zcPlaceUndoStartMarkerIfNeed(var UndoStartMarkerPlaced:boolean;const CommandName:GDBString;PushStone:boolean=false);
begin
    if UndoStartMarkerPlaced then exit;
    zcStartUndoCommand(CommandName,PushStone);
    UndoStartMarkerPlaced:=true;
end;
procedure zcPlaceUndoEndMarkerIfNeed(var UndoStartMarkerPlaced:boolean);
begin
    if not UndoStartMarkerPlaced then exit;
    zcEndUndoCommand;
    UndoStartMarkerPlaced:=false;
end;
procedure zcShowCommandParams(const PDataTypeDesk:PUserTypeDescriptor;const PInstance:Pointer);
begin
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,
                        PDataTypeDesk,PInstance,
                        drawings.GetCurrentDWG);
end;
procedure zcHideCommandParams();
begin
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  {if assigned(ReturnToDefaultProc)then
      ReturnToDefaultProc;}
end;
procedure zcRedrawCurrentDrawing();
begin
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedrawContent);
end;
procedure zcSelectEntity(pp:PGDBObjEntity);
begin
  pp^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.Selector);
  drawings.CurrentDWG.wa.param.SelDesc.LastSelectedObject:=pp;
end;
function GDBInsertBlock(own:PGDBObjGenericSubEntry;//владелец
                        BlockName:GDBString;       //имя блока
                        p_insert:GDBVertex;        //точка вставки
                        scale:GDBVertex;           //масштаб
                        rotate:Double;          //поворот
                        needundo:Boolean=false  //завернуть в ундо
                        ):PGDBObjBlockInsert;
var
  tb:PGDBObjBlockInsert;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
begin
  result := Pointer(own.ObjArray.CreateObj(GDBBlockInsertID));
  result.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
  result^.Name:=BlockName;
  //result^.vp.ID:=GDBBlockInsertID;
  result^.Local.p_insert:=p_insert;
  result^.scale:=scale;
  result^.CalcObjMatrix;
  result^.setrot(rotate);
  result^.rotate:=rotate;
  tb:=pointer(result^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^));
  if tb<>nil then begin
                       tb^.bp:=result^.bp;
                       result^.done;
                       Freemem(pointer(result));
                       result:=pointer(tb);
  end;
  if needundo then
  begin
      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
      begin
           AddObject(result);
           comit;
      end;
  end
  else
     own.ObjArray.AddPEntity(result^);
  result^.CalcObjMatrix;
  result^.BuildGeometry(drawings.GetCurrentDWG^);
  result^.BuildVarGeometry(drawings.GetCurrentDWG^);
  DC:=drawings.GetCurrentDWG^.CreateDrawingRC;
  result^.FormatEntity(drawings.GetCurrentDWG^,dc);
  if needundo then
  begin
  drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(result^);
  result^.Visible:=0;
  result^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
  end;
end;
function zcGetSelEntsDeskInCurrentRoot:TSelEntsDesk;
begin
  result:=zeGetSelEntsDeskInRoot(drawings.GetCurrentROOT^);
end;
procedure zcSetEntPropFromCurrentDrawingProp(const PEnt: PGDBObjEntity);
begin
     zeSetEntPropFromDrawingProp(PEnt,drawings.GetCurrentDWG^)
end;

procedure setdefaultproperty(pvo:pgdbobjEntity);
begin
  pvo^.selected := false;
  pvo^.Visible:=drawings.GetCurrentDWG.pcamera.VISCOUNT;
  pvo^.vp.layer :=drawings.GetCurrentDWG.GetCurrentLayer;
  pvo^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
end;

begin
end.
