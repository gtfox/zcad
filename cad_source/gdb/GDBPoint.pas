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

unit GDBPoint;
{$INCLUDE def.inc}

interface
uses UGDBOpenArrayOfPObjects,UGDBLayerArray,gdbasetypes,UGDBSelectedObjArray,GDBSubordinated,GDB3d,gdbEntity,sysutils,UGDBOpenArrayOfByte,varman,varmandef,
gl,
GDBase,UGDBDescriptor,gdbobjectsconstdef,oglwindowdef,geometry{,dxflow},memman,OGLSpecFunc;
type
{Export+}
PGDBObjPoint=^GDBObjPoint;
GDBObjPoint=object(GDBObj3d)
                 P_insertInOCS:GDBvertex;(*'Coordinates OCS'*)(*saved_to_shd*)
                 P_insertInWCS:GDBvertex;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;
                 procedure Format;virtual;

                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                 procedure RenderFeedback;virtual;
                 function getsnap(var osp:os_record; var pdata:GDBPointer):GDBBoolean;virtual;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure rtsave(refp:GDBPointer);virtual;
                 function GetObjTypeName:GDBString;virtual;
                 procedure getoutbound;virtual;

                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
           end;
{Export-}

implementation
uses
    log;
procedure GDBObjPoint.TransformAt;
begin
  P_insertInOCS:=geometry.VectorTransform3D(PGDBObjPoint(p)^.P_insertInOCS,t_matrix^);
  //format;
end;
procedure GDBObjPoint.getoutbound;
begin
     vp.BoundingBox.LBN:=P_insertInWCS;
     vp.BoundingBox.RTF:=P_insertInWCS;
     vp.BoundingBox.LBN.x:=vp.BoundingBox.LBN.x-0.1;
     vp.BoundingBox.LBN.y:=vp.BoundingBox.LBN.y-0.1;
     vp.BoundingBox.LBN.z:=vp.BoundingBox.LBN.z-0.1;
     vp.BoundingBox.RTF.x:=vp.BoundingBox.RTF.x+0.1;
     vp.BoundingBox.RTF.y:=vp.BoundingBox.RTF.y+0.1;
     vp.BoundingBox.RTF.z:=vp.BoundingBox.RTF.z+0.1;
end;
procedure GDBObjPoint.format;
begin
  P_insertInWCS:=VectorTransform3D(P_insertInOCS,{CurrentCS}bp.ListPos.owner^.GetMatrix^);
  calcbb;
end;
function GDBObjPoint.GetObjTypeName;
begin
     result:=ObjN_GDBObjPoint;
end;
constructor GDBObjPoint.init;
begin
  inherited init(own,layeraddres, lw);
  vp.ID := GDBPointID;
  P_insertInOCS := p;
end;
constructor GDBObjPoint.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  vp.ID := GDBPointID;
  P_insertInOCS := NulVertex;
end;

procedure GDBObjPoint.LoadFromDXF;
var s, layername: GDBString;
  byt, code: GDBInteger;
begin
  //inherited init(nil,0, 10);
  vp.ID := GDBPointID;
  P_insertInOCS:=NulVertex;
  s := f.readgdbstring;
  val(s, byt, code);
  while byt <> 0 do
  begin
    case byt of
      8:
        begin
          layername := f.readgdbstring;
          vp.Layer := gdb.GetCurrentDWG.LayerTable.getaddres(layername);
              //layername:=GDBPointer(s);
        end;
      10:
        begin
          s := f.readgdbstring;
          val(s, P_insertInOCS.x, code);
        end;
      20:
        begin
          s := f.readgdbstring;
          val(s, P_insertInOCS.y, code);
        end;
      30:
        begin
          s := f.readgdbstring;
          val(s, P_insertInOCS.z, code);
        end;
      370:
        begin
          s := f.readgdbstring;
          vp.lineweight := strtoint(s);
        end;
    else
      s := f.readgdbstring;
    end;
    s := f.readgdbstring;
    val(s, byt, code);
  end;

end;

procedure GDBObjPoint.DrawGeometry;
begin
  {myglbegin(GL_points);
  glVertex3dV(@P_insertInWCS);
  myglend;}
  oglsm.myglbegin(GL_LINES);
  glVertex3d(P_insertInWCS.x-0.5,P_insertInWCS.y-0.5,P_insertInWCS.z);
  glVertex3d(P_insertInWCS.x+0.5,P_insertInWCS.y+0.5,P_insertInWCS.z);
  glVertex3d(P_insertInWCS.x-0.5,P_insertInWCS.y+0.5,P_insertInWCS.z);
  glVertex3d(P_insertInWCS.x+0.5,P_insertInWCS.y-0.5,P_insertInWCS.z);
  oglsm.myglend;
  inherited;
end;
function GDBObjPoint.CalcInFrustum;
var i:GDBInteger;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i][0] * P_insertInWCS.x + frustum[i][1] * P_insertInWCS.y + frustum[i][2] * P_insertInWCS.z + frustum[i][3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
procedure GDBObjPoint.RenderFeedback;
begin
  gdb.GetCurrentDWG^.myGluProject2(P_insertInWCS,ProjPoint);
end;
function GDBObjPoint.getsnap;
//var t,d,e:GDBDouble;
 //   tv,n,v:gdbvertex;
begin
     if onlygetsnapcount=1 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (sysvar.dwg.DWG_OSMode^ and osm_point)<>0
            then
            begin
            osp.worldcoord:=P_insertInWCS;
            osp.dispcoord:=projpoint;
            osp.ostype:=os_point;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
function GDBObjPoint.onmouse;
var {t,xx,yy,}d1:GDBDouble;
    i:integer;
begin
      for i:=0 to 5 do
      begin
      d1:=MF[i][0] * P_insertInWCS.x + MF[i][1] * P_insertInWCS.y + MF[i][2] * P_insertInWCS.z + MF[i][3];
      if d1<0 then
                 begin
                      result:=false;
                      exit;
                 end;
      end;
      result:=true;
end;
function GDBObjPoint.CalcTrueInFrustum;
var {t,xx,yy,}d1:GDBDouble;
    i:integer;
begin
      for i:=0 to 5 do
      begin
      d1:=frustum[i][0] * P_insertInWCS.x + frustum[i][1] * P_insertInWCS.y + frustum[i][2] * P_insertInWCS.z + frustum[i][3];
      if d1<0 then
                 begin
                      result:=IREmpty;
                      exit;
                 end;
      end;
      result:=IRFully;
end;
procedure GDBObjPoint.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_point:begin
          pdesc.worldcoord:=P_insertInOCS;
          pdesc.dispcoord.x:=round(ProjPoint.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjPoint.y);
                             end;
                    end;
end;
procedure GDBObjPoint.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{92DDADAD-909D-4938-A1F9-3BD78FBB2B70}',{$ENDIF}1);
          pdesc.selected:=false;
          pdesc.pointtype:=os_point;
          pdesc.worldcoord:=P_insertInOCS;
          pdesc.dispcoord.x:=round(ProjPoint.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjPoint.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;
procedure GDBObjPoint.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
          case rtmod.point.pointtype of
               os_point:begin
                             P_insertInOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
          end;
end;
function GDBObjPoint.Clone;
var tvo: PGDBObjPoint;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{1C6F0445-7339-449A-BDEB-7D38A46FD910}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjPoint));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, P_insertInOCS);
  result := tvo;
end;
procedure GDBObjPoint.rtsave;
begin
  pgdbobjpoint(refp)^.P_insertInOCS := P_insertInOCS;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBPoint.initialization');{$ENDIF}
end.
