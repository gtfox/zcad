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
unit uzcExtdrSmartTextEnt;

interface

uses
  sysutils,
  math,uzegeometry,
  uzctnrVectorBytes,
  uzedrawingdef,uzgldrawcontext,
  uzeffdxfsupport,
  uzeentdevice,uzeentsubordinated,uzeentity,uzeentabstracttext,uzeenttext,
  uzeblockdef,uzeentmtext,uzeentwithlocalcs,uzeentblockinsert,
  uzeentityextender,uzeBaseExtender,uzbtypes,uzegeometrytypes;
const
  SmartTextEntExtenderName='extdrSmartTextEnt';
  ExtensionLineOffsetDef=0;
  ExtensionLeaderStartLengthDef=10;
  ExtensionHeightDef=0;
  //добавить это расширение к примитиву можно командой
  //extdrAdd(extdrSmartTextEnt)
type
  TSmartTextEntExtender=class(TBaseEntityExtender)
    //private
    public
      FExtensionLine:Boolean;
      FBaseLine:Boolean;
      FExtensionLineOffset:Double;
      FLeaderStartLength:Double;
      //FSaveHeight:Double;
      FHeightOverride:Double;
    private
      function isDefault:boolean;
      function getOwnerInsertPoint(pEntity:Pointer):GDBVertex;
      function getOwnerScale(pEntity:Pointer):Double;
      function getTextInsertPoint(pEntity:Pointer):GDBVertex;
      function geExtensionLinetStartPoint(pEntity:Pointer):GDBVertex;
    public
      class function getExtenderName:string;override;
      constructor Create(pEntity:Pointer);override;
      procedure Assign(Source:TBaseExtender);override;
      procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
      procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
      procedure SaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
      procedure PostLoad(var context:TIODXFLoadContext);override;
      procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;

      class function EntIOLoadExtensionLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadBaseLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadExtensionLineOffset(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadExtensionLeaderStartLength(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadTextHeigth(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
      class function EntIOLoadSmartTextEntExtenderDefault(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;


      property ExtensionLine:Boolean read FExtensionLine write FExtensionLine default true;
      property BaseLine:Boolean read FBaseLine write FBaseLine default true;
  end;

implementation

function TSmartTextEntExtender.isDefault:boolean;
begin
  result:=(FExtensionLine and FBaseLine)and(IsDoubleEqual(FExtensionLineOffset,ExtensionLineOffsetDef))
        and(IsDoubleEqual(FLeaderStartLength,ExtensionLeaderStartLengthDef))
        and(IsDoubleEqual(FHeightOverride,ExtensionHeightDef));
end;

procedure TSmartTextEntExtender.Assign(Source:TBaseExtender);
begin
  FExtensionLine:=TSmartTextEntExtender(Source).FExtensionLine;
  FBaseLine:=TSmartTextEntExtender(Source).FBaseLine;
  FExtensionLineOffset:=TSmartTextEntExtender(Source).FExtensionLineOffset;
  FLeaderStartLength:=TSmartTextEntExtender(Source).FLeaderStartLength;
  FHeightOverride:=TSmartTextEntExtender(Source).FHeightOverride;
end;

constructor TSmartTextEntExtender.Create(pEntity:Pointer);
begin
  FExtensionLine:=true;
  FBaseLine:=true;
  FExtensionLineOffset:=ExtensionLineOffsetDef;
  FLeaderStartLength:=ExtensionLeaderStartLengthDef;
  FHeightOverride:=ExtensionHeightDef;
end;

function TSmartTextEntExtender.getOwnerInsertPoint(pEntity:Pointer):GDBVertex;
begin
  result:=PGDBObjWithLocalCS(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.P_insert_in_WCS;
end;

function TSmartTextEntExtender.getOwnerScale(pEntity:Pointer):Double;
begin
  result:=PGDBObjBlockInsert(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.scale.y;
end;

function TSmartTextEntExtender.getTextInsertPoint(pEntity:Pointer):GDBVertex;
begin
  result:=PGDBObjText(pEntity).P_insert_in_WCS;
end;

function TSmartTextEntExtender.geExtensionLinetStartPoint(pEntity:Pointer):GDBVertex;
var
  p1,p2:GDBvertex;
  scl:double;
begin
  p1:=getOwnerInsertPoint(pEntity);
  p2:=getTextInsertPoint(pEntity);
  scl:=FExtensionLineOffset*abs(getOwnerScale(pEntity));
  if FExtensionLineOffset>0 then
    result:=p1+(p2-p1).NormalizeVertex*scl
  else begin
    result:=p2-p1;
    if abs(result.x)>abs(result.y)then begin
      result.y:=-result.y*(scl/abs(result.x));
      result.x:=-result.x*(scl/abs(result.x));
    end else begin
      result.x:=-result.x*(scl/abs(result.y));
      result.y:=-result.y*(scl/abs(result.y));
    end;
    result:=p1+result;
  end;
end;

procedure TSmartTextEntExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  dx:Double;
begin
  //if FHeightOverride>0 then
  //  PGDBObjMText(pEntity).textprop.size:=FSaveHeight;
  if (typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText))then
    if PGDBObjText(pEntity)^.bp.ListPos.Owner<>nil then
      if typeof(PGDBObjText(pEntity)^.bp.ListPos.Owner^)=TypeOf(GDBObjDevice) then begin
        if Vertexlength(getOwnerInsertPoint(pEntity),getTextInsertPoint(pEntity))>FLeaderStartLength then begin
          if FExtensionLine then
            PGDBObjText(pEntity).Representation.DrawLineWithLT(DC,geExtensionLinetStartPoint(pEntity),getTextInsertPoint(pEntity),PGDBObjEntity(pEntity)^.vp);
          if FBaseLine then begin
            dx:=PGDBObjText(pEntity).obj_width*PGDBObjMText(pEntity).textprop.size*PGDBObjMText(pEntity).textprop.wfactor*getOwnerScale(pEntity);
            if PGDBObjMText(pEntity).textprop.justify in [jsbr,jsmr,jstr] then
              dx:=-dx;
            PGDBObjText(pEntity).Representation.DrawLineWithLT(DC,getTextInsertPoint(pEntity),
                                                               VertexAdd(getTextInsertPoint(pEntity),CreateVertex(dx,0,0)),PGDBObjEntity(pEntity)^.vp);
          end;
        end;
  end;
end;
procedure TSmartTextEntExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  jtt2: array[-1..1,-1..1] of TTextJustify = ((jsbl, jsbc, jsbr),(jsml, jsmc, jsmr),(jstl, jstc, jstr));
  jtt: array[-1..1,-1..1] of TTextJustify = ((jsbl, jsbl, jsbr),(jsbl, jsbl, jsbr),(jsbl, jsbl, jsbr));
begin
  if typeof(PGDBObjEntity(pEntity)^)=TypeOf(GDBObjText) then begin
    if Vertexlength(getOwnerInsertPoint(pEntity),getTextInsertPoint(pEntity))>10 then
      PGDBObjMText(pEntity).textprop.justify:=jtt[-sign(PGDBObjText(pEntity).Local.P_insert.y),-sign(PGDBObjText(pEntity).Local.P_insert.x)]
    else
      PGDBObjMText(pEntity).textprop.justify:=jtt2[-sign(PGDBObjText(pEntity).Local.P_insert.y),-sign(PGDBObjText(pEntity).Local.P_insert.x)]
  end;
  if FHeightOverride>0 then begin
    //FSaveHeight:=PGDBObjMText(pEntity).textprop.size;
    PGDBObjMText(pEntity).textprop.size:=FHeightOverride/PGDBObjBlockInsert(PGDBObjText(pEntity)^.bp.ListPos.Owner)^.scale.y;
  end;
end;

class function TSmartTextEntExtender.getExtenderName:string;
begin
  result:=SmartTextEntExtenderName;
end;

procedure TSmartTextEntExtender.SaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
  if isDefault then
    dxfStringout(outhandle,1000,'SmartTextEntExtenderDefault=TRUE')
  else
    begin
      if not FExtensionLine then
        dxfStringout(outhandle,1000,'STEExtensionLine=FALSE');
      if not FBaseLine then
        dxfStringout(outhandle,1000,'STEBaseLineLine=FALSE');
      if not IsDoubleEqual(FExtensionLineOffset,ExtensionLineOffsetDef)then
        dxfStringout(outhandle,1000,'STEExtensionLineOffset='+FloatToStr(FExtensionLineOffset));
      if not IsDoubleEqual(FLeaderStartLength,ExtensionLeaderStartLengthDef)then
        dxfStringout(outhandle,1000,'STELeaderStartLength='+FloatToStr(FLeaderStartLength));
      if not IsDoubleEqual(FHeightOverride,ExtensionHeightDef)then
        dxfStringout(outhandle,1000,'STEHeightOverride='+FloatToStr(FHeightOverride));
    end;
end;

function AddSmartTextEntExtenderToEntity(PEnt:PGDBObjEntity):TSmartTextEntExtender;
begin
  result:=TSmartTextEntExtender.Create(PEnt);
  PEnt^.AddExtension(result);
end;


class function TSmartTextEntExtender.EntIOLoadExtensionLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FExtensionLine:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadBaseLine(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FBaseLine:=false;
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadExtensionLineOffset(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FExtensionLineOffset:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadExtensionLeaderStartLength(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FLeaderStartLength:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadTextHeigth(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  STEExtdr.FHeightOverride:=StrToFloat(_Value);
  result:=true;
end;

class function TSmartTextEntExtender.EntIOLoadSmartTextEntExtenderDefault(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  STEExtdr:TSmartTextEntExtender;
begin
  STEExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TSmartTextEntExtender>;
  if STEExtdr=nil then
    STEExtdr:=AddSmartTextEntExtenderToEntity(PEnt);
  result:=true;
end;

procedure TSmartTextEntExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;


procedure TSmartTextEntExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

initialization
  EntityExtenders.RegisterKey(uppercase(SmartTextEntExtenderName),TSmartTextEntExtender);

  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEExtensionLine',TSmartTextEntExtender.EntIOLoadExtensionLine);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEBaseLineLine',TSmartTextEntExtender.EntIOLoadBaseLine);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEExtensionLineOffset',TSmartTextEntExtender.EntIOLoadExtensionLineOffset);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STELeaderStartLength',TSmartTextEntExtender.EntIOLoadExtensionLeaderStartLength);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('STEHeightOverride',TSmartTextEntExtender.EntIOLoadTextHeigth);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('SmartTextEntExtenderDefault',TSmartTextEntExtender.EntIOLoadSmartTextEntExtenderDefault);
finalization
end.
