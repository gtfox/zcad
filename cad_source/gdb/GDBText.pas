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

unit GDBText;
{$INCLUDE def.inc}

interface
uses
strproc,UGDBSHXFont,UGDBPoint3DArray,UGDBLayerArray,gdbasetypes,GDBAbstractText,gdbEntity,UGDBOutbound2DIArray,UGDBOpenArrayOfByte,varman,varmandef,
gl,
GDBase,UGDBDescriptor,gdbobjectsconstdef,oglwindowdef,geometry,dxflow,strmy,math,memman,log,GDBSubordinated,UGDBTextStyleArray;
type
{Export+}
PGDBObjText=^GDBObjText;
GDBObjText=object(GDBObjAbstractText)
                 Content:GDBAnsiString;
                 Template:GDBAnsiString;(*saved_to_shd*)
                 TXTStyleIndex:TArrayIndex;(*saved_to_shd*)
                 CoordMin,CoordMax:GDBvertex;
                 obj_height,obj_width,obj_y:GDBDouble;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBString;p:GDBvertex;s,o,w,a:GDBDouble;j:GDBByte);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure CalcGabarit;virtual;
                 procedure getoutbound;virtual;
                 procedure Format;virtual;
                 procedure createpoint;virtual;
                 procedure CreateSymbol(_symbol:GDBInteger;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;pfont:pgdbfont;ln:GDBInteger);
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 destructor done;virtual;

                 function getsnap(var osp:os_record; var pdata:GDBPointer):GDBBoolean;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                 function IsHaveObjXData:GDBBoolean;virtual;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTUnit):GDBBoolean;virtual;
           end;
{Export-}
implementation
uses io,shared;
function acadvjustify(j: GDBByte): GDBByte;
var
  t: GDBByte;
begin
  t := 3 - ((j - 1) div 3);
  if t = 1 then
    result := 0
  else
    result := t;
end;
function GDBObjText.IsHaveObjXData:GDBBoolean;
begin
     if template<>content then
                              result:=true
                          else
                              result:=false;
end;
function GDBObjText.GetObjTypeName;
begin
     result:=ObjN_GDBObjText;
end;
constructor GDBObjText.initnul;
begin
  inherited initnul(owner);
  vp.ID := GDBtextID;
  GDBPointer(content) := nil;
  GDBPointer(template) := nil;
  textprop.size := 1;
  textprop.oblique := 12;
  textprop.wfactor := 0.65;
  textprop.angle := 0;
  textprop.justify := 1;
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{08E35ED5-B4A7-4210-A3C9-0645E8F27ABA}',{$ENDIF}100);
  //Vertex2D_in_DCS_Array.init({$IFDEF DEBUGBUILD}'{116E3B21-8230-44E8-B7A5-9CEED4B886D2}',{$ENDIF}100);
  PProjoutbound:=nil;
end;
constructor GDBObjText.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDBtextID;
  GDBPointer(content) := nil;
  GDBPointer(template) := nil;
  content := c;
  Local.p_insert := p;
  textprop.size := s;
  textprop.oblique := o;
  textprop.wfactor := w;
  textprop.angle := a;
  textprop.justify := j;
  Vertex3D_in_WCS_Array.init({$IFDEF DEBUGBUILD}'{8776360E-8115-4773-917D-83ED1843FF9C}',{$ENDIF}100);
  //Vertex2D_in_DCS_Array.init({$IFDEF DEBUGBUILD}'{EDC6D76B-DDFF-41A0-ACCC-48804795A3F5}',{$ENDIF}100);
  PProjoutbound:=nil;
  //format;
end;
procedure GDBObjText.format;
var
      TCP:TCodePage;
begin
  TCP:=CodePage;
CodePage:=CP_win;
     if template='' then
                      template:=content;
  content:=textformat(template,@self);
       CodePage:=TCP;
  if content='' then content:=str_empty;
  lod:=0;
  P_drawInOCS:=NulVertex;
  CalcGabarit;
  if textprop.justify = 0 then textprop.justify := 1;
  case textprop.justify of
    1:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        P_drawInOCS.x := 0;
      end;
    2:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    3:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
    4:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size / 2;
        P_drawInOCS.x := 0;
      end;

    5:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size / 2;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    6:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size / 2;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
    7:
      begin
        P_drawInOCS.y := P_drawInOCS.y;
        P_drawInOCS.x := 0;
      end;
    8:
      begin
        P_drawInOCS.y := P_drawInOCS.y;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    9:
      begin
        P_drawInOCS.y := P_drawInOCS.y;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
    10:
      begin
        P_drawInOCS.y := P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x := 0;
      end;
    11:
      begin
        P_drawInOCS.y := P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    12:
      begin
        P_drawInOCS.y := P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
  end;
    if content='' then content:=str_empty;
    calcobjmatrix;
    //getoutbound;
    createpoint;
    calcbb;

    //P_InsertInWCS:=VectorTransform3D(local.P_insert,vp.owner^.GetMatrix^);
end;
procedure GDBObjText.CalcGabarit;
var
  i: GDBInteger;
  psyminfo:PGDBsymdolinfo;
begin
  obj_height:=1;
  obj_width:=0;
  obj_y:=0;
  for i:=1 to length(content) do
  begin
    psyminfo:=pgdbfont(pbasefont)^.GetOrCreateSymbolInfo(ach2uch(GDBByte(content[i])));
    obj_width:=obj_width+{pgdbfont(pbasefont).symbo linfo[GDBByte(content[i])]}psyminfo.dx;
    if {pgdbfont(pbasefont).symbo linfo[GDBByte(content[i])]}psyminfo.dy>obj_height then obj_height:={pgdbfont(pbasefont).symbo linfo[GDBByte(content[i])]}psyminfo.dy;
    if {pgdbfont(pbasefont).symbo linfo[GDBByte(content[i])]}psyminfo._dy<obj_y then obj_y:={pgdbfont(pbasefont).symbo linfo[GDBByte(content[i])]}psyminfo._dy;
  end;
  obj_width:=obj_width-1/3;
end;
function GDBObjText.Clone;
var tvo: PGDBObjtext;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{4098811D-F8A9-4562-8803-38AAEA1A0D64}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjText));
  tvo^.initnul(nil);
  tvo^.bp.ListPos.Owner:=own;
  tvo^.vp:=vp;
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.content:=content;
  tvo^.template:=template;
  //tvo^.Format;
  result := tvo;
end;

procedure GDBObjText.rtedit;
begin
  if mode = os_textinsert then
  begin
    Local.p_insert := VertexAdd(pgdbobjtext(refp)^.Local.p_insert, dist);
    calcobjmatrix;
    format;
  end
end;
destructor GDBObjText.done;
begin
  content:='';
  template:='';
  Vertex3D_in_WCS_Array.Done;
  //Vertex2D_in_DCS_Array.Done;
  inherited done;
end;
procedure GDBObjText.getoutbound;
var
//  v:GDBvertex4D;
    t,b,l,r,n,f:GDBDouble;
    i:integer;

//pm:DMatrix4D;
//    tv:GDBvertex;
//    tpv:GDBPolyVertex2D;
//    ptpv:PGDBPolyVertex3D;
begin

                    (*ptpv:=Vertex3D_in_WCS_Array.parray;
                      l:=ptpv^.coord.x;
                      r:=ptpv^.coord.x;
                      t:=ptpv^.coord.y;
                      b:=ptpv^.coord.y;
                      n:=ptpv^.coord.z;
                      f:=ptpv^.coord.z;
                    pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
                    for i:=0 to Vertex3D_in_WCS_Array.count-1 do
                    begin
                           if ptpv^.coord.x<l then
                                                 l:=ptpv^.coord.x;
                          if ptpv^.coord.x>r then
                                                 r:=ptpv^.coord.x;
                          if ptpv^.coord.y<b then
                                                 b:=ptpv^.coord.y;
                          if ptpv^.coord.y>t then
                                                 t:=ptpv^.coord.y;
                          if ptpv^.coord.z<n then
                                                 n:=ptpv^.coord.z;
                          if ptpv^.coord.z>f then
                                                 f:=ptpv^.coord.z;
                         inc(ptpv);
                    end;

                    {outbound[0]:=geometry.CreateVertex(l,t,n);
                    outbound[1]:=geometry.CreateVertex(r,t,n);
                    outbound[2]:=geometry.CreateVertex(r,b,n);
                    outbound[3]:=geometry.CreateVertex(l,b,n);}*)


  (*
  v.x:=0;
  v.y:=obj_y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=pgdbvertex(@v)^;
  v.x:=0;
  v.y:={obj_y}+obj_height;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=pgdbvertex(@v)^;
  v.x:=obj_width;
  v.y:={obj_y}+obj_height;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=pgdbvertex(@v)^;
  v.x:=obj_width;
  v.y:=obj_y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=pgdbvertex(@v)^;

  *)
  l:=outbound[0].x;
  r:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do
  begin
  if outbound[i].x<l then
                         l:=outbound[i].x;
  if outbound[i].x>r then
                         r:=outbound[i].x;
  if outbound[i].y<b then
                         b:=outbound[i].y;
  if outbound[i].y>t then
                         t:=outbound[i].y;
  if outbound[i].z<n then
                         n:=outbound[i].z;
  if outbound[i].z>f then
                         f:=outbound[i].z;
  end;


  vp.BoundingBox.LBN:=CreateVertex(l,B,n);
  vp.BoundingBox.RTF:=CreateVertex(r,T,f);


  if PProjoutbound=nil then
  begin
       GDBGetMem({$IFDEF DEBUGBUILD}'{4C06C975-C569-4020-8DA7-27CD949B9298}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{AB29B448-057C-4018-BC57-E8C67A3765AF}',{$ENDIF}4);
  end;
end;
procedure GDBObjText.CreateSymbol(_symbol:GDBInteger;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;pfont:pgdbfont;ln:GDBInteger);
var
  psymbol: GDBPointer;
  i, j, k: GDBInteger;
  len: GDBWord;
  //matr,m1: DMatrix4D;
  v:GDBvertex4D;
  pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;

  plp,plp2:pgdbvertex;
  lp,tv:gdbvertex;
  pl:GDBPoint3DArray;
  ispl:gdbboolean;
  ir:itrec;
  psyminfo:PGDBsymdolinfo;
  deb:GDBsymdolinfo;
begin
  if _symbol=100 then
                      _symbol:=_symbol;
  _symbol:=ach2uch(_symbol);
  if _symbol=32 then
                      _symbol:=_symbol;

  psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(integer(_symbol));
  deb:=psyminfo^;
  psymbol := PGDBfont(pfont)^.SHXdata.getelement({pgdbfont(pfont).symbo linfo[GDBByte(_symbol)]}psyminfo.addr);// GDBPointer(GDBPlatformint(pfont)+ pgdbfont(pfont).symbo linfo[GDBByte(_symbol)].addr);
  if {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size <> 0 then
    for j := 1 to {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size do
    begin
      case GDBByte(psymbol^) of
        2:
          begin
            inc(pGDBByte(psymbol), sizeof(GDBLineID));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=0;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;

            v:=VectorTransform(v,objmatrix);

            pv3.coord:=PGDBvertex(@v)^;

            tv:=pv3.coord;
            pv3.LineNumber:=ln;

            pv3.count:=0;
            Vertex3D_in_WCS_Array.add(@pv3);

            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=0;

            pv3.LineNumber:=ln;

            Vertex3D_in_WCS_Array.add(@pv3);


            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=0;
            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
          end;
        4:
          begin
            inc(pGDBByte(psymbol), sizeof(GDBPolylineID));
            len := GDBWord(psymbol^);
            inc(pGDBByte(psymbol), sizeof(GDBWord));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=len;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=len;

            tv:=pv3.coord;
            pv3.LineNumber:=ln;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            k := 1;
            while k < len do //for k:=1 to len-1 do
            begin
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;

            v:=VectorTransform(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=-1;

            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:={-1}k-len+1;

            pv3.LineNumber:=ln;
            tv:=pv3.coord;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            inc(k);
            end;
          end;
      end;
    end;
  end;

procedure GDBObjText.createpoint;
var
  psymbol: GDBPointer;
  i, j, k: GDBInteger;
  len: GDBWord;
  matr,m1: DMatrix4D;
  v:GDBvertex4D;
  pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;

  minx,miny,maxx,maxy:GDBDouble;

  plp,plp2:pgdbvertex;
  lp,tv:gdbvertex;
  pl:GDBPoint3DArray;
  ispl:gdbboolean;
  ir:itrec;  
  pfont:pgdbfont;
  ln:GDBInteger;
begin
  ln:=1;
  pfont:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getelement(TXTStyleIndex))^.pfont;

  ispl:=false;
  pl.init({$IFDEF DEBUGBUILD}'{AC324582-5E55-4290-8017-44B8C675198A}',{$ENDIF}10);
  Vertex3D_in_WCS_Array.clear;

  minx:=+infinity;
  miny:=+infinity;
  maxx:=-infinity;
  maxy:=-infinity;

  matr:=matrixmultiply(DrawMatrix,objmatrix);
  matr:=DrawMatrix;

  i := 1;
  while i <= length(content) do
  begin
    if content[i]=#1 then
    begin
         ispl:=not(ispl);
         if ispl then begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                        end
                   else begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                        end;
    end
    else
    begin
      CreateSymbol(ord(content[i]),matr,minx,miny,maxx,maxy,pfont,ln);

    end;
      //FillChar(m1, sizeof(DMatrix4D), 0);
      m1:=onematrix;
  {m1[0, 0] := 1;
  m1[1, 1] := 1;
  m1[2, 2] := 1;
  m1[3, 3] := 1;}
  m1[3, 0] := {pgdbfont(pbasefont).symbo linfo[GDBByte(content[i])]}pgdbfont(pbasefont).GetOrCreateSymbolInfo(ach2uch(GDBByte(content[i]))).dx;
  //m1[3, 1] := 0;
  matr:=MatrixMultiply(m1,matr);
  inc(i);
  end;
                       if ispl then

                     begin
                             lp:=pgdbvertex(@matr[3,0])^;
                             lp.y:=lp.y-0.2*textprop.size;
                             lp:=VectorTransform3d(lp,objmatrix);
                             pl.Add(@lp);
                     end;

  v.x:=minx;
  v.y:=maxy;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=pgdbvertex(@v)^;
  v.x:=maxx;
  v.y:=maxy;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=pgdbvertex(@v)^;
  v.x:=maxx;
  v.y:=miny;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=pgdbvertex(@v)^;
  v.x:=minx;
  v.y:=miny;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=pgdbvertex(@v)^;

  plp:=pl.beginiterate(ir);
  plp2:=pl.iterate(ir);
  if plp2<>nil then
  repeat

                             pv3.coord:=plp^;
                             pv3.count:=0;
                             Vertex3D_in_WCS_Array.add(@pv3);
                             pv3.coord:=plp2^;
                             pv3.count:=0;
                             Vertex3D_in_WCS_Array.add(@pv3);

        plp:=pl.iterate(ir);
        plp2:=pl.iterate(ir);
  until plp2=nil;

  Vertex3D_in_WCS_Array.Shrink;
  pl.done;
end;
function GDBObjText.getsnap;
begin
     if onlygetsnapcount=1 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (sysvar.dwg.DWG_OSMode^ and osm_inspoint)<>0
            then
            begin
            osp.worldcoord:=P_insert_in_WCS;
            osp.dispcoord:=ProjP_insert;
            osp.ostype:=os_textinsert;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
procedure GDBObjText.rtmodifyonepoint(const rtmod:TRTModifyData);
//var m:DMatrix4D;
begin
     //m:=bp.owner.getmatrix^;
     //MatrixInvert(m);
          case rtmod.point.pointtype of
               os_point:begin
                             Local.p_insert:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
          end;
end;
procedure GDBObjText.SaveToDXFObjXData;
begin
     if content<>template then
                              dxfGDBStringout(outhandle,1000,'_TMPL1='+template);
     inherited;
end;
function GDBObjText.ProcessFromDXFObjXData;
begin
     result:=inherited ProcessFromDXFObjXData(_Name,_Value,ptu);
     if not result then

     if _Name='_TMPL1' then
                           begin
                                template:=_value;
                                result:=true;
                           end;
end;
function z2dxftext(s:gdbstring):gdbstring;
var i:GDBInteger;
begin
     result:=s;
     repeat
          i:=pos(#1,result);
          if i>0 then
                     begin
                          result:=copy(result,1,i-1)+'%%U'+copy(result,i+1,length(result)-i);
                     end;
     until i<=0;
end;
procedure GDBObjText.SaveToDXF(var handle: longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);
var
  hv, vv: GDBByte;
  tv:gdbvertex;
begin
  vv := acadvjustify(textprop.justify);
  hv := (textprop.justify - 1) mod 3;
  SaveToDXFObjPrefix(handle,outhandle,'TEXT','AcDbText');
  tv:=Local.p_insert;
  tv.x:=tv.x+P_drawInOCS.x;
  tv.y:=tv.y+P_drawInOCS.y;
  tv.z:=tv.z+P_drawInOCS.z;
  if hv + vv = 0 then
  begin
    dxfvertexout(outhandle,10,Local.p_insert);
    dxfvertexout(outhandle,11,tv);
  end
  else
  begin
    dxfvertexout(outhandle,11,Local.p_insert);
    dxfvertexout(outhandle,10,tv);
  end;
  dxfGDBDoubleout(outhandle,40,textprop.size);
  dxfGDBDoubleout(outhandle,50,textprop.angle);
  dxfGDBDoubleout(outhandle,41,textprop.wfactor);
  dxfGDBDoubleout(outhandle,51,textprop.oblique);
  dxfGDBIntegerout(outhandle,72,hv);
  dxfGDBStringout(outhandle,7,'R2_5');

  SaveToDXFObjPostfix(outhandle);

  dxfGDBStringout(outhandle,1,z2dxftext(content));
  dxfGDBStringout(outhandle,100,'AcDbText');
  dxfGDBIntegerout(outhandle,73,vv);
end;
procedure GDBObjText.LoadFromDXF;
var s{, layername}: GDBString;
  byt{, code}: GDBInteger;
  doublepoint,angleload: GDBBoolean;
  vv, gv: GDBInteger;
  style:GDBString;
begin
  //initnul;
  vv := 0;
  gv := 0;
  byt:=readmystrtoint(f);
  angleload:=false;
  doublepoint:=false;
  style:='';
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu) then
       if not dxfvertexload(f,10,byt,Local.P_insert) then
          if dxfvertexload(f,11,byt,P_drawInOCS) then
                                                     doublepoint := true
else if not dxfGDBDoubleload(f,40,byt,textprop.size) then
     if not dxfGDBDoubleload(f,41,byt,textprop.wfactor) then
     if dxfGDBDoubleload(f,50,byt,textprop.angle) then
                                                      angleload := true
else if dxfGDBDoubleload(f,51,byt,textprop.oblique) then
                                                        textprop.oblique:=textprop.oblique
else if     dxfGDBStringload(f,7,byt,style)then
                                             begin
                                                  TXTStyleIndex :=gdb.GetCurrentDWG.TextStyleTable.FindStyle(Style);
                                                  if TXTStyleIndex=-1 then
                                                                      TXTStyleIndex:=0;
                                             end
else if not dxfGDBIntegerload(f,72,byt,gv)then
     if not dxfGDBIntegerload(f,73,byt,vv)then
     if not dxfGDBStringload(f,1,byt,content)then
                                               s := f.readgdbstring;
    byt:=readmystrtoint(f);
  end;
  OldVersTextReplace(Template);
  OldVersTextReplace(Content);
  textprop.justify := jt[vv, gv];
  if doublepoint then Local.p_Insert := P_drawInOCS;
  //assert(angleload, 'GDBText отсутствует dxf код 50 (угол поворота)');
  if angleload then
  begin
     if (abs (Local.oz.x) < 1/64) and (abs (Local.oz.y) < 1/64) then
                                                                    Local.ox:=CrossVertex(YWCS,Local.oz)
                                                                else
                                                                    Local.ox:=CrossVertex(ZWCS,Local.oz);
  local.OX:=VectorTransform3D(local.OX,geometry.CreateAffineRotationMatrix(Local.oz,-textprop.angle*pi/180));
  end;
  {if not angleload then
  begin
  Local.ox.x:=cos(self.textprop.angle*pi/180);
  Local.ox.y:=sin(self.textprop.angle*pi/180);
  Local.ox.z:=0;
  end;}
  //format;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBText.initialization');{$ENDIF}
end.
