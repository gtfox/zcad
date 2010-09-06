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

unit mainwindow;
{$INCLUDE def.inc}

interface
uses
  strproc,log,
  umytreenode,menus,Classes, SysUtils, FileUtil,{ LResources,} Forms, stdctrls, ExtCtrls, ComCtrls,Toolwin, Controls, {Graphics, Dialogs,}
  gdbasetypes,SysInfo, oglwindow, io,
  gdbase, languade,geometry,
  varmandef, varman, GDBManager, {odbase, odbasedef, iodxf,} UGDBOpenArrayOfByte, plugins,
  {math, }UGDBDescriptor,cmdline,
  {gdbobjectsconstdef,}UGDBLayerArray,{deveditor,}
  {ZEditsWithProcedure,}{zforms,}{ZButtonsWithCommand,}{ZComboBoxsWithProc,}{ZButtonsWithVariable,}{zmenus,}
  {GDBCommandsBase,}{ GDBCommandsDraw,GDBCommandsElectrical,}
  commandline,{zmainforms,}memman,UGDBNamedObjectsArray,
  {ZGUIArrays,}{ZBasicVisible,}{ZEditsWithVariable,}{ZTabControlsGeneric,}shared,{ZPanelsWithSplit,}{ZGUIsCT,}{ZstaticsText,}{UZProcessBar,}strmy{,strutils},{ZPanelsGeneric,}
graphics;

type
  TMainFormN = class(TFreedForm)
                    ToolBarU,ToolBarR:TToolBar;
                    ToolBarD: TToolBar;
                    //ObjInsp,
                    MainPanel{,MainPanelU}:TPanel;
                    //MainPanelD:TCLine;
                    SplitterV,SplitterH: TSplitter;

                    PageControl:TmyPageControl;

                    mm:TMenu;

                    SystemTimer: TTimer;

                    procedure AfterConstruction; override;

                    procedure draw;

                    procedure loadpanels(pf:GDBString);
                    procedure loadmenu(var f:GDBOpenArrayOfByte;var pm:TMenu;var line:GDBString);
                    procedure loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);

                    procedure ChangedDWGTabCtrl(Sender: TObject);

                    procedure StartLongProcess(total:integer);
                    procedure ProcessLongProcess(current:integer);
                    procedure EndLongProcess;
                    procedure Say(word:gdbstring);


                    public
                    rt:GDBInteger;
                    //hToolTip: HWND;

                    //procedure KeyPress(var Key: char);override;
                    procedure myKeyPress(Sender: TObject; var Key: Word; Shift: TShiftState);

                    procedure ChangeCLayer(Sender:Tobject);
                    procedure ChangeCLineW(Sender:Tobject);

                    procedure idle(Sender: TObject; var Done: Boolean);virtual;
                    procedure ReloadLayer(plt:PGDBNamedObjectsArray);

                    procedure GeneralTick(Sender: TObject);//(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;

               end;
function getoglwndparam: GDBPointer; export;
procedure clearotrack;
procedure clearcp;
{procedure startup;
procedure finalize;}
const
     menutoken='MAINMENUITEM';
     submenutoken='MENUITEM';
     TOOLTIPS_CLASS = 'tooltips_class32';
     statusbarheight=20;
     statusbarclientheight=18;
var
  MainFormN: TMainFormN;
  //MainForm: TMainForm;
  uGeneralTimer:cardinal;
  GeneralTime:GDBInteger;
  LayerBox:TComboBox;
  LineWBox:TComboBox;
  LPTime:Tdatetime;
  oldlongprocess:integer;
implementation

uses Objinsp{,optionswnd, Tedit_form, MTedit_form};

procedure TMainFormN.draw;
begin
     update;
end;

procedure TMainFormN.AfterConstruction;
var
  i:integer;
begin
     inherited;

     WindowState:=wsMaximized;
     onkeydown:=mykeypress;
     KeyPreview:=true;


     ToolBarD:={TStatusBar}TToolBar.Create(self);
     ToolBarD.Height:=18;
     ToolBarD.ButtonHeight:=16;
     ToolBarD.ShowCaptions:=true;
     ToolBarD.Align:=alBottom;

     ProcessBar:=TProgressBar.create(ToolBarD);//.initxywh('?',@Pdownpanel,0,0,400,statusbarclientheight,false);
     ProcessBar.Hide;
     ProcessBar.DoubleBuffered:=true;
     ProcessBar.Align:=alLeft;
     ProcessBar.Width:=400;
     ProcessBar.min:=0;
     ProcessBar.max:=0;
     ProcessBar.step:=10000;
     ProcessBar.position:=0;
     ProcessBar.Smooth:=true;
     ProcessBar.Parent:=ToolBarD;

     HintText:=TLabel.Create(ToolBarD);
     HintText.Align:=alLeft;
     HintText.AutoSize:=false;
     HintText.Width:=400;
     HintText.Layout:=tlCenter;
     HintText.Alignment:=taCenter;
     HintText.Parent:=ToolBarD;

     ToolBarD.Parent:=self;


     ToolBarU:=TToolBar.Create(self);
     ToolBarU.Align:=alTop;
     ToolBarU.ShowCaptions:=true;
     ToolBarU.Parent:=self;

{     LayerBox:=TComboBox.Create(ToolBarU);
     LayerBox.ReadOnly:=true;
     LayerBox.Width:=200;
     LayerBox.Height:=500;
     LayerBox.AutoSize:=true;
     LayerBox.Parent:=ToolBarU;
     layerbox.OnChange:=ChangeCLayer;

LineWBox:=TComboBox.Create(ToolBarU);
LineWBox.onChange:=ChangeCLineW;
LineWbox.Clear;
LineWbox.readonly:=true;
LineWbox.items.Add(sys2interf('Обычный'));
LineWbox.items.Add(sys2interf('По блоку'));
LineWbox.items.Add(sys2interf('По слою'));
for i := 0 to 20 do
begin
s:=floattostr(i / 10) + ' мм';
     LineWbox.items.Add(sys2interf(s));
end;
LineWbox.items.Add(sys2interf('Разный'));
LineWbox.Parent:=ToolBarU;
}

     ToolBarR:=TToolBar.Create(self);
     ToolBarR.Align:=alRight;
     ToolBarR.Width:=ToolBarU.Height;
     ToolBarR.EdgeBorders:=[ebRight];
     ToolBarR.ShowCaptions:=true;
     ToolBarR.Parent:=self;

     MainPanel:=TPanel.create(self);
     MainPanel.Align:=alClient;
     MainPanel.BorderStyle:=bsNone;
     MainPanel.BorderWidth:=0;
     MainPanel.BevelOuter:=bvnone;


       CLine:=TCLine.create(MainPanel);
       CLine.Parent:=MainPanel;
       CLine.Align:=alClient;

       PageControl:=TmyPageControl.Create(MainPanel);
       PageControl.Constraints.MinHeight:=32;
       PageControl.Parent:=MainPanel;
       PageControl.Align:=alTop;
       PageControl.OnPageChanged:=ChangedDWGTabCtrl;
       PageControl.Height:=800;
       //if PageControl.Height>sysinfo.sysparam.screeny;
       //PageControl.BorderStyle:=BSsingle;
       PageControl.BorderWidth:=0;
       //tobject(PageControl):=mainpanel;
       //PageControl.BevelOuter:=bvnone;

       SplitterH:=TSplitter.Create(MainPanel);
       SplitterH.Parent:=MainPanel;
       SplitterH.Align:=alTop;
       SplitterH.top:=800;

     SplitterV:=TSplitter.Create(self);
     SplitterV.Align:=alLeft;

     MainPanel.Parent:=self;

     GDBObjInsp:=TGDBObjInsp.create(self);
     GDBObjInsp.Align:=alLeft;
     GDBobjinsp.createpda;
     GDBobjinsp.setptr(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar);
     GDBobjinsp.SetCurrentObjDefault;
     //GDBobjinsp.ReturnToDefault;
     GDBObjInsp.Parent:=self;

     SplitterV.left:=GDBobjinsp.Width;
     SplitterV.Parent:=self;


     //Menu:=TMainMenu.create(self);
     //Menu.Items.Add(TmyMenuItem.create(Menu,'Добавить в базу данных чертежа','DBaseAdd'));


     loadpanels(sysparam.programpath+'menu/mainmenu.mn');
     //Menu:=TMainMenu(mm);

     //self.caption:=sys2interf('Временно это окно является главным окном программы. Соответственно его закрытие повлечет за собой закрытие программы)). Приносим извинения за неудобства))');




     //self.Menu:=TMainMenu(menu);

   (*  hToolTip := CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil,
         {TTS_ALWAYSTIP=}$01,
         integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
         integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
         MainFormN.handle, 0, hInstance, nil );
   *)
     application.OnIdle:=self.idle;
     SystemTimer:=TTimer.Create(self);
     SystemTimer.Interval:=1000;
     SystemTimer.Enabled:=true;
     SystemTimer.OnTimer:=self.generaltick;
end;
procedure SetImage(ppanel:TToolBar;b:TToolButton;img:string;autosize:boolean);
var
    bmp:TBitmap;
begin
     if length(img)>1 then
     begin
          if img[1]<>'#' then
                              begin
                              img:=sysparam.programpath+'menu/BMP/'+img;
                              bmp:=TBitmap.create;
                              bmp.LoadFromFile(img);
                              bmp.Transparent:=true;
                              if not assigned(ppanel.Images) then
                                                                 ppanel.Images:=TImageList.Create(ppanel);
                              b.ImageIndex:=
                              ppanel.Images.Add(bmp,nil);
                              freeandnil(bmp);
                              //-----------b^.SetImageFromFile(img)
                              end
                          else
                              begin
                              b.caption:=sys2interf(system.copy(img,2,length(img)-1));
                              if autosize then
                               if length(img)>3 then
                                                    b.Font.size:=11-length(img);
                              end;
     end;
                              b.Height:=ppanel.ButtonHeight;
                              b.Width:=ppanel.ButtonWidth;
end;
procedure AddToBar(ppanel:TToolBar;b:TControl);
begin
     if ppanel.ClientHeight<ppanel.ClientWidth then
                                                   begin
                                                        //b.Left:=100;
                                                        //b.align:=alLeft
                                                   end
                                               else
                                                   begin
                                                        //b.top:=100;
                                                        //b.align:=alTop;
                                                   end;
    b.Parent:=ppanel;
end;

procedure TMainFormN.loadpanels(pf:GDBString);
var
    f:GDBOpenArrayOfByte;
    line,ts,{bn,}bc{,bh}:GDBString;
    buttonpos:GDBInteger;
    ppanel:TToolBar;
    b:TToolButton;
    i:longint;
    y,xx,yy,w,code:GDBInteger;
    bmp:TBitmap;
const bsize=24;
begin
  f.InitFromFile(pf);
  while f.notEOF do
  begin
    line := f.readstring(' ',#$D#$A);
    if (line <> '') and (line[1] <> ';') then
    begin
      if uppercase(line) = 'PANEL' then
      begin
           line := f.readstring(' ','');
           ts:=line;
           line := f.readstring(',','');
           line := f.readstring(',','');
           y:=strtoint(line);
           line := f.readstring(',','');
           xx:=strtoint(line);
           line := f.readstring(';','');
           yy:=strtoint(line);
           if uppercase(ts)='RIGHTPANEL'
           then
               begin
                    ppanel:=ToolBarR
               end
           else
               if uppercase(ts)='UPPANEL' then
               begin
                    ppanel:=ToolBarU;
               end
           else
               if uppercase(ts)='DOWNPANEL' then
               begin
                    ppanel:=ToolBarD;
               end;

           buttonpos:=0;
           while line<>'{' do
                             line := f.readstring(#$A,#$D);
           line := f.readstring(#$A' ',#$D);
           while line<>'}' do
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     if uppercase(line)='BUTTON' then
                     begin
                          bc := f.readstring(',','');
                          line := f.readstring(#$A,#$D);
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b:=TmyCommandToolButton.Create(ppanel);
                          TmyCommandToolButton(b).FCommand:=bc;
                          if ts<>''then
                          begin
                          b.hint:=sys2interf(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(ppanel,b,line,true);
                          //b.AutoSize:=false;
                          buttonpos:=buttonpos+bsize;
                          {b.Parent:=ppanel;
                          if ppanel.ClientHeight<ppanel.ClientWidth then
                                                                        b.align:=alLeft
                                                                    else
                                                                        b.align:=alTop;}
                          AddToBar(ppanel,b);
                     end;
                     if uppercase(line)='VARIABLE' then
                     begin
                          bc := f.readstring(',','');
                          line := f.readstring(#$A,#$D);
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b:=TmyVariableToolButton.Create(ppanel);
                          b.Style:=tbsCheck;
                          TmyVariableToolButton(b).AssignToVar(bc);
                          if ts<>''then
                          begin
                          b.hint:=sys2interf(ts);
                          b.ShowHint:=true;
                          end;
                          SetImage(ppanel,b,line,false);
                          b.AutoSize:=true;

                          {b.Parent:=ppanel;
                          if ppanel.ClientHeight<ppanel.ClientWidth then
                                                                        b.align:=alLeft
                                                                    else
                                                                        b.align:=alTop;}
                          AddToBar(ppanel,b);

                     end;
                     if uppercase(line)='LAYERCOMBOBOX' then
                     begin
                          bc := f.readstring(',','');
                          ts := f.readstring(#$A,#$D);
                          val(bc,w,code);
                          if assigned(LayerBox) then
                                                    shared.ShowError('Повторное создание LAYERCOMBOBOX! полноценно будет работать только одна копия');
                          LayerBox:=TComboBox.Create(ppanel);
                          if code=0 then
                                        LayerBox.Width:=w;
                          if ts<>''then
                          begin
                               LayerBox.hint:=sys2interf(ts);
                               LayerBox.ShowHint:=true;
                          end;
                          LayerBox.OnChange:=ChangeCLayer;
                          LayerBox.ReadOnly:=true;
                          LayerBox.AutoSize:=false;
                          //LayerBox.Align:=alleft;
                          //LayerBox.Height:=ppanel.ClientHeight;
                          {LayerBox.Parent:=ppanel;
                          if ppanel.ClientHeight<ppanel.ClientWidth then
                                                                        LayerBox.align:=alLeft
                                                                    else
                                                                        LayerBox.align:=alTop;}
                          AddToBar(ppanel,LayerBox);
                     end;
                     if uppercase(line)='LINEWCOMBOBOX' then
                     begin
                          bc := f.readstring(',','');
                          ts := f.readstring(#$A,#$D);
                          val(bc,w,code);
                          if assigned(LineWBox) then
                                                    shared.ShowError('Повторное создание LAYERCOMBOBOX! полноценно будет работать только одна копия');
                          LineWBox:=TComboBox.Create(ppanel);
                          if code=0 then
                                        LineWBox.Width:=w;
                          if ts<>''then
                          begin
                               LineWBox.hint:=sys2interf(ts);
                               LineWBox.ShowHint:=true;
                          end;
                          LineWbox.Clear;
                          LineWbox.readonly:=true;
                          LineWbox.items.Add(sys2interf('Обычный'));
                          LineWbox.items.Add(sys2interf('По блоку'));
                          LineWbox.items.Add(sys2interf('По слою'));
                          for i := 0 to 20 do
                          begin
                          s:=floattostr(i / 10) + ' мм';
                               LineWbox.items.Add(sys2interf(s));
                          end;
                          LineWbox.items.Add(sys2interf('Разный'));
                          LineWbox.OnChange:=ChangeCLineW;
                          LineWbox.AutoSize:=false;

                          {LineWbox.Parent:=ppanel;
                          if ppanel.ClientHeight<ppanel.ClientWidth then
                                                                        LineWbox.align:=alLeft
                                                                    else
                                                                        LineWbox.align:=alTop;}
                           AddToBar(ppanel,LineWBox);
                     end;
                     if uppercase(line)='SEPARATOR' then
                                         begin
                                         buttonpos:=buttonpos+3;
                                         TToolButton(b):=TToolButton.Create(ppanel);
                                         b.Style:=
                                         //tbsSeparator;
                                         tbsDivider;
                                         //b.a

                                         {b.Parent:=ppanel;
                          if ppanel.ClientHeight<ppanel.ClientWidth then
                                                                        b.align:=alLeft
                                                                    else
                                                                        b.align:=alTop;}
                                          AddToBar(ppanel,b);
                                         end;
                     //application.ProcessMessages;
                end;
                line := f.readstring(#$A' ',#$D);
           end;
           //ppanel^.setxywh(ppanel.wndx,ppanel.wndy,ppanel.wndw,buttonpos+bsize);
           //ppanel^.Show;

      end
      else if uppercase(line) = menutoken then
      begin
           //mm:=menu;
           loadmenu(f,mm,line);
      end
    end;
  end;
  //--------------------------------SetMenu(MainForm.handle,pmenu.handle);
  //f.close;
  f.done;
end;
procedure TMainFormN.loadmenu(var f:GDBOpenArrayOfByte;var pm:TMenu;var line:GDBString);
var
    pmenuitem:TmyMenuItem;
    ppopupmenu:TMenuItem;
begin
           if not assigned(pm) then
                                   pm:=TMainMenu.Create(self);


           line := f.readstring(';','');
           line:=sys2interf(line);


           ppopupmenu:=TMenuItem.Create(pm);
           ppopupmenu.Caption:=line;
           pm.items.Add(ppopupmenu);

           loadsubmenu(f,ppopupmenu,line);

end;
procedure TMainFormN.loadsubmenu(var f:GDBOpenArrayOfByte;var pm:TMenuItem;var line:GDBString);
var
    pmenuitem:TmyMenuItem;
    ppopupmenu,submenu:TMenuItem;
    line2:GDBString;
begin
           while line<>'{' do
                             begin
                             line := f.readstring(#$A,#$D);
                             line:=readspace(line);
                             end;
           line := f.readstring(#$A' ',#$D);
           while line<>'}' do
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     if uppercase(line)='COMMAND' then
                                                      begin
                                                           line2 := f.readstring(',','');
                                                           //GDBGetMem({$IFDEF DEBUGBUILD}'{19CBFAC7-4671-4F40-A34F-3F69CE37DA65}',{$ENDIF}GDBPointer(pmenuitem),sizeof(zmenuitem));
                                                           //pmenuitem.init(line);
                                                           //pmenuitem.addto(ppopupmenu);
                                                           line := f.readstring(',','');
                                                           //pmenuitem.command:=line;
                                                           pmenuitem:=TmyMenuItem.Create(ppopupmenu,line2,line);
                                                           ppopupmenu.Add(pmenuitem);
                                                           line := f.readstring(',','');
                                                           line := f.readstring(#$A' ',#$D);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else     if uppercase(line)='SEPARATOR' then
                                                      begin
                                                           ppopupmenu.AddSeparator;
                                                           (*line2 := f.readstring(',','');
                                                           //GDBGetMem({$IFDEF DEBUGBUILD}'{19CBFAC7-4671-4F40-A34F-3F69CE37DA65}',{$ENDIF}GDBPointer(pmenuitem),sizeof(zmenuitem));
                                                           //pmenuitem.init(line);
                                                           //pmenuitem.addto(ppopupmenu);
                                                           line := f.readstring(',','');
                                                           //pmenuitem.command:=line;
                                                           pmenuitem:=TmyMenuItem.Create(ppopupmenu,line2,line);
                                                           ppopupmenu.Add(pmenuitem);*)
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line) = submenutoken then
                                                      begin

                                                           line := f.readstring(';','');
                                                           submenu:=TMenuItem.Create(ppopupmenu);
                                                           submenu.Caption:=sys2interf(line);
                                                           ppopupmenu.{items.}Add(submenu);

                                                           loadsubmenu(f,{ppopupmenu}submenu,line);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                end;
           end;
           //ppopupmenu.addto(pm);
end;
procedure  TMainFormN.ChangedDWGTabCtrl(Sender: TObject);
var
   ogl:TOGlwnd;
begin
     OGL:=TOGLwnd(FindControlByType(TPageControl(sender).ActivePage,TOGLwnd));
     if assigned(OGL) then
                          OGL.GDBActivate;
end;

{destructor TMainForm.done;
begin
     pmenu^.done;
     pdownpanel.done;
     prightpanel.done;
     inherited;
     GDBFreeMem(pointer(pmenu));
end;}

procedure TMainFormN.myKeyPress{(var Key: char)}(Sender: TObject; var Key: Word; Shift: TShiftState);
//procedure TMainForm.Pre_Char;
var
   ccg,tempkey:char;
begin
     //shared.HistoryOutStr(inttostr(key));
     if (ActiveControl)<>cmdedit then
     if (ActiveControl is tedit)
     or (ActiveControl is tmemo)   then
                                       exit;
     tempkey:=chr(key);

     if assigned(gdb.GetCurrentDWG) then
     if assigned(gdb.GetCurrentDWG.OGLwindow1)then
                    gdb.GetCurrentDWG.OGLwindow1.KeyPress(tempkey);
     if tempkey<>#00 then
     begin
     tempkey:=chr(key);
     if cmdedit.text='' then
     begin
     if (commandmanager.pcommandrunning=nil)and(not(chr(key) in ['a'..'Z']))and({ord}(Key)>31) then
     begin
          ccg:=UPPERCASE(chr(key))[1];
          key:=00;
          case  ccg of
                      'C':commandmanager.executecommand('Copy');
                      'M':commandmanager.executecommand('Move');
                      'L':commandmanager.executecommand('Line');
                      else
                          key:=ord(tempkey);
          end;
     end
else if (Key=86)and(shift=[ssctrl]) then
                   begin
                        commandmanager.executecommand('PasteClip');
                        key:=00;
                   end
     end;
     end;
end;
{procedure TMainForm.close;
begin
     destroywindow(self.handle);
     commandmanager.executecommand('Quit');
end;}
procedure TMainFormN.idle;
var
   pdwg:PTDrawing;
begin
     done:=true;
     pdwg:=gdb.GetCurrentDWG;
     if pdwg<>nil then
     begin
          if pdwg.OGLwindow1.Fastmmx>=0 then
          begin
               //pdwg.OGLwindow1._onMouseMove(nil,pdwg.OGLwindow1.Fastmmshift,pdwg.OGLwindow1.Fastmmx,pdwg.OGLwindow1.Fastmmy);
               //pdwg.OGLwindow1.Fastmmx:=-1;
          end
          else
              if  pdwg.pcamera.DRAWNOTEND then
                                              begin
                                              pdwg.OGLwindow1.finishdraw;
                                              done:=false;
                                              end;
     end;
     //SysVar.debug.memi2:=memman.i2;
     if (SysVar.SAVE.SAVE_Auto_Current_Interval^<1)and(commandmanager.pcommandrunning=nil) then
     if (gdb.GetCurrentDWG)<>nil then
     if (gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount=0) then
     begin
          commandmanager.executecommandsilent('QSave(QS)');
          SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     end;
     date:=sysutils.date;
  {if  (rt<>SysVar.SYS.SYS_RunTime^) and OGLwindow1.param.zoommode then
                        begin
                             OGLwindow1.param.zoommode:=false;
                             begin
                                  OGLwindow1.param.scrollmode:=false;
                                  gdb.GetCurrentDWG.ObjRoot.ObjArray.renderfeedbac;
                                  OGLwindow1.paint;
                             end;

                        end;}
     if rt<>SysVar.SYS.SYS_RunTime^ then
                                        GDBobjinsp.updateinsp;
     rt:=SysVar.SYS.SYS_RunTime^;
     if historychanged then
                           begin
                                historychanged:=false;
                                HistoryLine.SelStart:=utflen{HistoryLine.GetTextLen};
                                HistoryLine.SelLength:=2;
                           end;
end;
procedure  TMainFormN.ChangeCLineW(Sender:Tobject);
var tcl:GDBInteger;
begin
  if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0
  then
  begin
  if LineWBox.ItemIndex = linewbox.Items.Count-1 then
                                                     begin
                                                          if SysVar.dwg.DWG_CLinew^<0 then linewbox.ItemIndex:=(SysVar.dwg.DWG_CLinew^+3)
                                                                              else linewbox.ItemIndex:=(SysVar.dwg.DWG_CLinew^ div 10+3);
                                                     end
                                                 else
                                                     begin
                                                          SysVar.dwg.DWG_CLinew^ := linewbox.ItemIndex;
                                                          SysVar.dwg.DWG_CLinew^:=SysVar.dwg.DWG_CLinew^-3;
                                                          if SysVar.dwg.DWG_CLinew^>0 then SysVar.dwg.DWG_CLinew^:=SysVar.dwg.DWG_CLinew^*10;
                                                     end;
  end
  else
  begin
       if linewbox.ItemIndex = linewbox.Items.Count-1
           then
           begin
                gdb.GetCurrentDWG.OGLwindow1.setvisualprop;
           end
           else
           begin
                tcl:=SysVar.dwg.DWG_CLinew^;
                SysVar.dwg.DWG_CLinew^:=linewbox.ItemIndex;
                SysVar.dwg.DWG_CLinew^:=SysVar.dwg.DWG_CLinew^-3;
                if SysVar.dwg.DWG_CLinew^>0 then SysVar.dwg.DWG_CLinew^:=SysVar.dwg.DWG_CLinew^*10;
                commandmanager.ExecuteCommand('SelObjChangeLWToCurrent');
                SysVar.dwg.DWG_CLinew^:=tcl;
                gdb.GetCurrentDWG.OGLwindow1.setvisualprop;
           end;
  end;
end;
procedure TMainFormN.ChangeCLayer(Sender:Tobject);
var tcl:GDBInteger;
begin
  if gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0
  then
  begin
  if {layerbox.ItemIndex = layerbox.ItemsCount-1}
      layerbox.ItemIndex = layerbox.Items.Count-1 then {layerbox.ItemIndex := SysVar.dwg.DWG_CLayer^}
                                                        layerbox.ItemIndex := SysVar.dwg.DWG_CLayer^
                                                 else
                                                     begin
                                                          SysVar.dwg.DWG_CLayer^ := layerbox.ItemIndex;
                                                          GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBLayerProp'),gdb.GetCurrentDWG.LayerTable.GetCurrentLayer);
                                                     end;
  end
  else
  begin
       if layerbox.ItemIndex = {layerbox.ItemsCount-1}layerbox.Items.Count-1
           then
           begin
                gdb.GetCurrentDWG.OGLwindow1.setvisualprop;
           end
           else
           begin
                tcl:=SysVar.dwg.DWG_CLayer^;
                SysVar.dwg.DWG_CLayer^:=layerbox.ItemIndex;
                commandmanager.ExecuteCommand('SelObjChangeLayerToCurrent');
                SysVar.dwg.DWG_CLayer^:=tcl;
                gdb.GetCurrentDWG.OGLwindow1.setvisualprop;
           end;
  end;
end;
(*
procedure TMainForm.loadmenu;
var //p:^tform;
    //line:GDBString;
    //buttonpos:GDBInteger;
    //pvd:pvardesk;
    //ppanel:pzform;
    //b:PZButtonWithCommand;
    //t:pzlistbox;
    //i:longint;
    //x,y,xx,yy:GDBInteger;
    pmenuitem:pzmenuitem;
    //mi:TMenuItemInfo;
    //o:GDBInteger;
    ppopupmenu:pzpopupmenu;
begin
           line := f.readstring(';','');
           GDBGetMem({$IFDEF DEBUGBUILD}'{7A89C3DC-00FB-49E9-B938-030C79A09A37}',{$ENDIF}GDBPointer(ppopupmenu),sizeof(zpopupmenu));
           //new(ppopupmenu);
           ppopupmenu.init(line);

           while line<>'{' do
                             begin
                             line := f.readstring(#$A,#$D);
                             line:=readspace(line);
                             end;
           line := f.readstring(#$A' ',#$D);
           while line<>'}' do
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     if uppercase(line)='COMMAND' then
                                                      begin
                                                           line := f.readstring(',','');
                                                           GDBGetMem({$IFDEF DEBUGBUILD}'{19CBFAC7-4671-4F40-A34F-3F69CE37DA65}',{$ENDIF}GDBPointer(pmenuitem),sizeof(zmenuitem));
                                                           //new(pmenuitem);
                                                           pmenuitem.init(line);
                                                           pmenuitem.addto(ppopupmenu);
                                                           line := f.readstring(',','');
                                                           pmenuitem.command:=line;
                                                           line := f.readstring(',','');
                                                           line := f.readstring(#$A' ',#$D);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                else if uppercase(line) = submenutoken then
                                                      begin
                                                           loadmenu(f,{ppopupmenu,}{pm}pzmenu(ppopupmenu),line);
                                                           line := f.readstring(#$A' ',#$D);
                                                           line:=readspace(line);
                                                      end
                end;
           end;
           ppopupmenu.addto(pm);
end;
*)
(*
procedure TMainForm.loadpanels;
var
    f:GDBOpenArrayOfByte;
    line,ts,{bn,}bc{,bh}:GDBString;
    buttonpos:GDBInteger;
    ppanel:pzform;
    b:PZButtonWithCommand;
    i:longint;
    y,xx,yy:GDBInteger;
const bsize=24;
begin
  f.InitFromFile(pf);
  while f.notEOF do
  begin
    line := f.readstring(' ',#$D#$A);
    if (line <> '') and (line[1] <> ';') then
    begin
      if uppercase(line) = 'PANEL' then
      begin
           //new(ppanel);
           line := f.readstring(' ','');
           ts:=line;
           line := f.readstring(',','');
           //x:=strtoint(line);
           line := f.readstring(',','');
           y:=strtoint(line);
           line := f.readstring(',','');
           xx:=strtoint(line);
           line := f.readstring(';','');
           yy:=strtoint(line);
           if uppercase(ts)<>'RIGHTPANEL'
           then
               begin
                    GDBGetMem({$IFDEF DEBUGBUILD}'{16D035CF-7563-4785-96E7-74B992F7DE8F}',{$ENDIF}pointer(ppanel),sizeof(zform));
                    ppanel^.initxywh('ZForm.'+ts,@mainwindow.MainForm,{x}clientwidth-bsize-5,y,xx,yy,true);
               end
           else
               begin
                    ppanel:=pointer(@PRightPanel);
               end;
           buttonpos:=0;
           while line<>'{' do
                             line := f.readstring(#$A,#$D);
           line := f.readstring(#$A' ',#$D);
           while line<>'}' do
           begin
                if (line <> '') and (line[1] <> ';') then
                begin
                     if uppercase(line)='BUTTON' then
                     begin
                          GDBGetMem({$IFDEF DEBUGBUILD}'{3712C8F6-B4AB-4184-96DA-6F4E100BD7EC}',{$ENDIF}pointer(b),sizeof(ZButtonWithCommand));
                          bc := f.readstring(',','');
                          {b^.initxywh('ZButton.'+bc,bc,ppanel,0,buttonpos,bsize,bsize);
                          b^.command:=bc;}
                          line := f.readstring(#$A,#$D);
                          ts:='???';
                          i:=pos(',',line);
                          if i>0 then
                                     begin
                                          ts:=system.copy(line,i+1,length(line)-i);
                                          line:=system.copy(line,1,i-1);
                                     end;
                          b^.initxywh('ZButton.'+bc,ts,ppanel,0,buttonpos,bsize,bsize,true);
                          b^.command:=bc;
                          b^.hint:=ts;
                          if length(line)>1 then
                          begin
                               if line[1]<>'#' then
                                                   begin
                                                   line:=sysparam.programpath+'menu\BMP\'+line;
                                                   b^.SetImageFromFile(line)
                                                   end
                                               else
                                                   b^.settext(system.copy(line,2,length(line)-1));
                          if bc='SetObjInsp(CURRENT)' then
                                     begin
                                          bc:=bc;
                                     end;
                          end;
                          buttonpos:=buttonpos+bsize;
                     end;
                     if uppercase(line)='SPACE' then buttonpos:=buttonpos+3;
                end;
                line := f.readstring(#$A' ',#$D);
           end;
           ppanel^.setxywh(ppanel.wndx,ppanel.wndy,ppanel.wndw,buttonpos+bsize);
           ppanel^.Show;

      end
      else if uppercase(line) = menutoken then
      begin
           loadmenu(f,{ppopupmenu,}pmenu,line);
      end
    end;
  end;
  SetMenu(MainForm.handle,pmenu.handle);
  //f.close;
  f.done;
end;
*)
procedure TMainFormN.GeneralTick(Sender: TObject);//(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;
begin
     if sysvar.SYS.SYS_RunTime<>nil then
     begin
          inc(sysvar.SYS.SYS_RunTime^);
          if SysVar.SAVE.SAVE_Auto_On^ then
                                           dec(sysvar.SAVE.SAVE_Auto_Current_Interval^);
          //sendmessageA(mainwindow.MainForm.handle,wm_user,0,0);
     end;
end;
procedure TMainFormN.StartLongProcess(total:integer);
begin
     LPTime:=now;

     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
  ProcessBar.max:=total;
  ProcessBar.min:=0;
  ProcessBar.position:=0;
  HintText.Hide;
  ProcessBar.Show;
  oldlongprocess:=0;
     end;
end;
procedure TMainFormN.ProcessLongProcess(current:integer);
var
    pos:integer;
begin
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
          pos:=round(clientwidth*(current/ProcessBar.max));
          if pos>oldlongprocess then
          begin
               ProcessBar.position:=current;
               oldlongprocess:=pos+20;
               ProcessBar.repaint;
               //application.ProcessMessages;
          end;
     end;
end;
procedure TMainFormN.Say(word:gdbstring);
begin
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin

          HintText.caption:=word;
          HintText.repaint;
          //application.ProcessMessages;
     end;
end;
procedure TMainFormN.EndLongProcess;
var
   Time:Tdatetime;
   ts:GDBSTRING;
begin
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
          ProcessBar.Hide;
          HintText.Show;
          ProcessBar.min:=0;
          ProcessBar.max:=0;
          ProcessBar.position:=0;
     end;
    application.ProcessMessages;
    time:=(now-LPTime)*10e4;
    str(time:3:2,ts);
    say(sys2interf('Выполнено за  '+ts+'сек'));
end;
(*
procedure TMainForm.beforeinit;
var
  //initf, registercommands: Initfunc;
  i: longint;
  //pv: PluginVersionInfo;
  //pq:pzform;
  td:PZButtonWithVariable;
  tbc:PZButtonWithCommand;
  //tdd:PZeditWithVariable;
  //tddd:PZTabControlGeneric;
  ps,mainps{,p1}:PZPanelWithSplit;
  s:GDBString;
  //iconname:GDBString;
begin

  {hToolTip := CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil,
      $01,
      integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
      integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
      MainForm.handle, 0, hInstance, nil );}


  GDBGetMem({$IFDEF DEBUGBUILD}'{4017A111-CA16-4465-9D91-4F7ABEC069C9}',{$ENDIF}GDBPointer(tbc),sizeof(ZButtonWithCommand));
  tbc^.initxywh('mainSAVE','Сохранить как...',@MainForm,0,0,24,24,true);
  tbc^.command:='SaveAs';
  tbc^.SetImageFromFile(sysparam.programpath+'menu\BMP\Save.BMP');
  tbc^.hint:='Сохранить как...';

  GDBGetMem({$IFDEF DEBUGBUILD}'{D04952EE-5A29-4DC7-9A64-E18EB998203C}',{$ENDIF}GDBPointer(tbc),sizeof(ZButtonWithCommand));
  tbc^.initxywh('mainLOAD','Загрузить...',@MainForm,24,0,24,24,true);
  tbc^.command:='Load';
  tbc^.SetImageFromFile(sysparam.programpath+'menu\BMP\Load.BMP');
  tbc^.hint:='Загрузить...';

  //LayerBox.initxywh('LayerBox',@MainForm,48,00,202,600,false);
  //LayerBox.onChange:=@ChangeCLayer;
  //LayerBox.ClearText;
  //ReloadLayer(@gdb.GetCurrentDWG.LayerTable);

{  LineWBox.initxywh('LineWBox',@MainForm,250,00,80,600,false);
  LineWBox.onChange:=@ChangeCLineW;
  LineWbox.ClearText;
  LineWbox.AddLine('Обычный');
  LineWbox.AddLine('По блоку');
  LineWbox.AddLine('По слою');
  //MainForm.Show;
  for i := 0 to 20 do
  begin
  s:=floattostr(i / 10) + ' мм';
       LineWbox.AddLine(GDBPointer(s));
  end;
  LineWbox.AddLine('Разный');
}


  //Tedform:=TTedform.create(Application);
  //MTedform:=TMTedform.create(Application);
  //programlog.logout('loadpanels done');
//new(p1);
{------------------}//GDBGetMem({$IFDEF DEBUGBUILD}'{E3AD9BED-C483-4645-80C9-FDEFA6A27FD5}',{$ENDIF}pointer(p1),sizeof(ZPanelWithSplit));
{------------------}//p1.initxywh('p1',@mainform,0,25,sysinfo.sysparam.screenx,sysinfo.sysparam.screeny-25-80,hor,sysinfo.sysparam.screeny-25-80-40);
{------------------}//p1^.align:=al_client;
GDBGetMem({$IFDEF DEBUGBUILD}'{8D26A55E-7388-4BDB-A9A1-B925CB0993CF}',{$ENDIF}pointer(pinterf),sizeof(ZPanelWithSplit));
pinterf.initxywh('pinterf',@mainform,0,25,
                           sysinfo.sysparam.screenx,sysinfo.sysparam.screeny-25-80,true,wert,sysinfo.sysparam.screeny-25-80-40);
 //GDBGetMem({$IFDEF DEBUGBUILD}'{26E9AFE5-9612-4A1A-8D06-FB1173AE9236}',{$ENDIF}pointer(prightpanel),sizeof(ZPanelGeneric));
 //GDBGetMem({$IFDEF DEBUGBUILD}'{BFD6676A-F5CB-4D76-BCE8-B08292300178}',{$ENDIF}pointer(PDownPanel),sizeof(ZPanelGeneric));

 pdownpanel.initxywh('ZForm.Down',@mainwindow.MainForm,{x}0,0,26,26,false);
 pdownpanel.setstyle(WS_Border,0);
 prightpanel.initxywh('ZForm.Right',@mainwindow.MainForm,{x}0,0,26,26,false);
 prightpanel.setstyle(WS_Border,0);
 prightpanel.align:=al_client or al_fixwsize;
 //pinterf.Set_part(1,mainps);
 pinterf.Set_part(2,@prightpanel);
 prightpanel.Show;
 pinterf^.Show;
 pdownpanel.Show;
//p1.align:=al_client;
//new(mainps);
GDBGetMem({$IFDEF DEBUGBUILD}'{C0C040B7-2C0A-40BC-9F51-933D5255E2BF}',{$ENDIF}pointer(mainps),sizeof(ZPanelWithSplit));
mainps.initxywh('mainps',pinterf^.p1,0,25,sysinfo.sysparam.screenx,sysinfo.sysparam.screeny-30,true,wert,200);
mainps^.align:=al_client;
//new(ps);
GDBGetMem({$IFDEF DEBUGBUILD}'{3F9AAC32-F7D0-4B07-A529-FC8060F6734C}',{$ENDIF}pointer(ps),sizeof(ZPanelWithSplit));
ps.initxywh('ps',mainps^.p2,0,25,mainps^.p1.clientwidth,mainps^.p1.clientheight,true,hor,{600}mainps^.p2.clientheight-100);
//mainps.Set_part(2,ps);
ps^.align:=al_client;

   //@mainwindow.MainForm

  //gdb.GetCurrentDWG.OGLwindow1.initxywh('oglwnd',@mainwindow.MainForm,200,72,768,596,false);

  //gdb.GetCurrentDWG.OGLwindow1.initxywh('oglwnd',ps^.p1,200,72,768,596);
  //gdb.GetCurrentDWG.oglwindow1.align:=al_client;

  PageControl.initxywh('DWGPages',@mainwindow.MainForm,0,0,clientwidth,clientheight,false);;
  PageControl.align:=al_client;
  //PageControl.PCNotify:=ChangeMainTabCtrl;
  ps^.Set_part(1,@PageControl);


  if gdb.GetCurrentDWG<>nil then
  begin

  ps^.Set_part(1,@gdb.GetCurrentDWG.OGLwindow1);

  gdb.GetCurrentDWG.OGLwindow1.initogl;

  //gdb.GetCurrentDWG.OGLwindow1.phinttext :=@hinttext;
  gdb.GetCurrentDWG.OGLwindow1.setvisualprop;
  end;
  //gdb.objroot.calcvisible;

  pcommandline := @Cline.CmdEdit;
  //playercombo := @LayerBox;
  //plwcombo := @linewbox;

mainps^.Show;
ps^.Show;


{----------------}//p1^.Show;
  //new(pqwe);
  //HintText.initxywh('А где мышь?',@Pdownpanel,0,0,400,statusbarclientheight,false);
  //HintText.setstyle(WS_BORDER,0);

  {GDBGetMem(pq,sizeof(zform));
  pq^.init('oglwnd',0);}

  {GDBGetMem(pqwe,sizeof(zedit));
  pqwe^.initxywh('oglwnd',zforms.w,10,10,675,20);}


  //programlog.logout('OGLwindow created');

  //LineWbox.DropDownCount:=100;
  //sendmessageA(LineWbox.handle,CB_setDROPPEDWIDTH ,400,0);

  //OGLwindow1.init;
  //programlog.logout('OGLwindow inited');
  GDBGetMem({$IFDEF DEBUGBUILD}'{9A78FA9C-C7B1-473E-9681-15DBFF9213F9}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  //new(td);
  //i:=0;
  td^.initxywh('Сетка','??Сетка',@Pdownpanel,400,0,50,statusbarclientheight,true);
  //td^.SetImageFromFile(sysparam.programpath+'menu\BMP\1.BMP');
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_DrawGrid');
  GDBGetMem({$IFDEF DEBUGBUILD}'{2C132A7B-BFC1-4BA8-AF27-9F7DF19F69F7}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  //new(td);
  td^.initxywh('SUB-выделение','Отдельный выбор частей динамических объектов',@Pdownpanel,450,0,90,statusbarclientheight,true);
  //td^.SetImageFromFile(sysparam.programpath+'menu\BMP\sub.BMP');
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_EditInSubEntry');

  GDBGetMem({$IFDEF DEBUGBUILD}'{41A94B0E-2E39-4215-810A-B4E25460E3EB}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  //new(td);
  td^.initxywh('Вес','Вес линий',@Pdownpanel,540,0,30,statusbarclientheight,true);
  //td^.SetImageFromFile(sysparam.programpath+'menu\BMP\lwt.BMP');
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_DrawMode');

  GDBGetMem({$IFDEF DEBUGBUILD}'{A63267BF-9A14-4D15-A6F0-B79187C7F98E}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  //new(td);
  td^.initxywh('Привязки','Привязка к характерным точкам объектов',@Pdownpanel,570,0,60,statusbarclientheight,true);
  //td^.SetImageFromFile(sysparam.programpath+'menu\BMP\osnap.BMP');
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_OSMode');

  GDBGetMem({$IFDEF DEBUGBUILD}'{F0452D72-3E62-465B-8DCD-269E3D2E1D32}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  //new(td);
  td^.initxywh('Полярность','Полярное слежение',@Pdownpanel,630,0,70,statusbarclientheight,true);
  //td^.SetImageFromFile(sysparam.programpath+'menu\BMP\polar.BMP');
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_PolarMode');


  GDBGetMem({$IFDEF DEBUGBUILD}'{93F56D49-47DB-45F2-AD9D-FDD0BAF1099D}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  td^.initxywh('HG','Вспомогательная графика (подключения, направления и т.п.)',@Pdownpanel,700,0,30,statusbarclientheight,true);
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_HelpGeometryDraw');






  GDBGetMem({$IFDEF DEBUGBUILD}'{4F1A4A50-5EBE-4F35-95A5-AF32970C80E9}',{$ENDIF}GDBPointer(td),sizeof(ZButtonWithVariable));
  td^.initxywh('SG','Системная графика  (габариты, связи и т.п.)',@Pdownpanel,730,0,30,statusbarclientheight,true);
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('DWG_SystmGeometryDraw');



//  GDBGetMem({$IFDEF DEBUGBUILD}'{3C39B205-9392-4A05-B053-B274B203E5CD}',{$ENDIF}GDBPointer(tbc),sizeof(ZButtonWithCommand));
//  tbc^.initxywh('FIX',@MainForm,498,0,24,24);
//  tbc^.command:='SetObjInsp(CURRENT)';
//  tbc^.hint:='Фиксировать выделенный объект в инспекторе';


  //tbc^.assigntoboolvar('DWG_SystmGeometryDraw');

// GDBGetMem({$IFDEF DEBUGBUILD}'{3712C8F6-B4AB-4184-96DA-6F4E100BD7EC}',{$ENDIF}pointer(b),sizeof(ZButtonWithCommand));
//  line := f.readworld(',','');
 // b^.initxywh('ZButton.'+line,ppanel,0,buttonpos,bsize,bsize);

  {new(tdd);
  tdd.initxywh('test',@MainForm,505,0,100,24);
  tdd.AssignToVariable('ossize');}

  {new(tddd);
  tddd.initxywh('',mainform.handle,605,0,400,400);
  tddd.addpage('хуй');
  tddd.addpage('бля');
  tddd.addpage('нахуй');
  tddd.addpage('ёбть');
  tddd.selpage(1);
  new(td);
  td^.initxywh('Привязка',tddd.getpagehandle(3),100,100,55,24);
  td^.onclickproc:=redrawoglwnd;
  td^.assigntoboolvar('osmode');}

  //if OGLwindow1.param.projtype = Projparalel then
  //  if sysvar.PMenuProjType<>nil then PMenuItem(sysvar.PMenuProjType^)^.caption := 'Перспективная проекция';
  //if OGLwindow1.param.projtype = projperspective then
  //  if sysvar.PMenuProjType<>nil then PMenuItem(sysvar.PMenuProjType^)^.caption := 'Паралельная проекция';


{  cline.initxywh('Команда',@mainwindow.MainForm,0,708-42,1024,118,false);
  cline.align:=al_client;
  ps^.Set_part(2,@cline);
  if SysVar.VIEW.VIEW_CommandLineVisible^ then
  begin
       cline.Height:=40;
       Cline.Show;
  end;
  sysvar.sys.SYS_IsHistoryLineCreated^:=true;}

  {GDBobjinsp.initxywh('GDBobjinsp',@mainwindow.MainForm,0,72,200,596,false);// := TGDBobjinsp.create(Application);
  GDBobjinsp.createpda;

  mainps^.Set_part(1,@GDBobjinsp);
  GDBobjinsp.show;
  GDBobjinsp.setptr(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar);
  GDBobjinsp.SetCurrentObjDefault;}

  if gdb.GetCurrentDWG<>nil then
  begin
       //gdb.GetCurrentDWG.OGLwindow1.SetObjInsp;
       gdb.GetCurrentDWG.OGLwindow1.SetFocus;
  end;
  //LayerBox.Items:=layernamelist;

  SystemParametersInfo(SPI_SETBEEP,0,nil,0); //выключить
  //SysTemparametersInfo(SPI_SETBEEP,1,nil,0); //включить
  //layerbox.FloatingDockSiteClass
  GeneralTime:=0;
  uGeneralTimer := timeSetEvent(1000, 500, @GeneralTick, 0, 1);
  //Application.OnIdle:= idle;
  {form1 := Tform1.create(Application);
  Form1.setdevice(@testdevice);
  //form1.create(Application);
  Form1.showmodal;}



  //winmanager.WndCreateEx(100,100,100,100);
  //winmanager.WndSetOnMouseMove(@TMainForm.mm);
  //winmanager.WndShowmodal;
  if gdb.GetCurrentDWG<>nil then
  begin
  gdb.GetCurrentDWG.OGLwindow1.CalcOptimalMatrix;

  gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum);
  gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum);

  gdb.GetCurrentDWG.OGLwindow1.param.firstdraw := true;
  gdb.GetCurrentDWG.OGLwindow1.show;
  end;

   GDBGetMem({$IFDEF DEBUGBUILD}'{06B65959-6B6D-4EF5-9E2F-30B5FAD66350}',{$ENDIF}GDBPointer(pmenu),sizeof(zmenu));
   pmenu.init;
  //loadpanels(sysparam.programpath+'menu\mainmenu.mn');
end;
*)
procedure TMainFormN.ReloadLayer;
var
  //i: GDBInteger;
  ir:itrec;
  plp:PGDBLayerProp;
  s:ansistring{[ls]};
  //ss:ansistring;
begin

  {layerbox.ClearText;}
  layerbox.Items.Clear;
  plp:=plt^.beginiterate(ir);
  if plp<>nil then
  repeat
       s:=plp^.GetFullName;
       layerbox.Items.Add(Sys2Interf(s));
       plp:=plt^.iterate(ir);
  until plp=nil;
  layerbox.Items.Add(Sys2Interf('_Разный_'));
  layerbox.ItemIndex:=(SysVar.dwg.DWG_CLayer^);
end;
{procedure TMainForm.keypress(Sender: TObject; var Key: GDBWord;
  Shift: TShiftState);
var code: GDBInteger;
  len: GDBDouble;
  temp: gdbvertex;
begin
  if key = 13 then begin
    if length(cline.CmdEdit.text) > 0 then
    begin
      val(cline.CmdEdit.text, len, code);
      if code = 0 then
      begin
        if OGLwindow1.param.polarlinetrace = 1 then
        begin
  //        temp.x := OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].worldcoord.x + len * OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arrayworldaxis.vertexarray[OGLwindow1.param.axisnum].x * sign(OGLwindow1.p
aram.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arraydispaxis.arr[OGLwindow1.param.axisnum].tmouse);
  //        temp.y := OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].worldcoord.y - len * OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arrayworldaxis.vertexarray[OGLwindow1.param.axisnum].y * sign(OGLwindow1.p
aram.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arraydispaxis.arr[OGLwindow1.param.axisnum].tmouse);
  //        temp.z := OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].worldcoord.z + len * OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arrayworldaxis.vertexarray[OGLwindow1.param.axisnum].z * sign(OGLwindow1.p
aram.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arraydispaxis.arr[OGLwindow1.param.axisnum].tmouse);
  //        if commandmanager.pcommandrunning <> nil then
  //        begin
  //          commandmanager.pcommandrunning^.MouseMoveCallback(temp, OGLwindow1.param.md.mouse, 1);
  //        end;
  //      end;
      end
      else if cline.CmdEdit.text[1] = '$' then evaluate(system.copy(cline.CmdEdit.text, 2, length(cline.CmdEdit.text) - 1),systemvariable)
      else commandmanager.executecommand(GDBPointer(cline.CmdEdit.text));
    end else commandmanager.executelastcommad;
    cline.CmdEdit.text := '';
    OGLwindow1.param.firstdraw := TRUE;
    OGLwindow1.loadmatrix;
    OGLwindow1.paint;
  end;
end;}

function getoglwndparam: GDBPointer; export;
begin
  result := addr(gdb.GetCurrentDWG.OGLwindow1.param);
end;
(*procedure TMainForm.keypressed(Sender: TObject; var Key: ansiChar);
var code: GDBInteger;
  len: GDBDouble;
  //temp: gdbvertex;
begin
  if ord(key) = 13 then begin
    if length(cline.CmdEdit.text) > 0 then
    begin
      val(cline.CmdEdit.text, len, code);
      if code = 0 then
      begin
        if gdb.GetCurrentDWG.OGLwindow1.param.polarlinetrace = 1 then
        begin
          {temp.x := OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].worldcoord.x + len * OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arrayworldaxis.vertexarray[OGLwindow1.param.axisnum].x * sign(OGLwindow1.pa
ram.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arraydispaxis.arr[OGLwindow1.param.axisnum].tmouse);
          temp.y := OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].worldcoord.y - len * OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arrayworldaxis.vertexarray[OGLwindow1.param.axisnum].y * sign(OGLwindow1.par
am.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arraydispaxis.arr[OGLwindow1.param.axisnum].tmouse);
          temp.z := OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].worldcoord.z + len * OGLwindow1.param.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arrayworldaxis.vertexarray[OGLwindow1.param.axisnum].z * sign(OGLwindow1.par
am.ontrackarray.otrackarray[OGLwindow1.param.pointnum].arraydispaxis.arr[OGLwindow1.param.axisnum].tmouse);
          if commandmanager.pcommandrunning <> nil then
          begin
            commandmanager.pcommandrunning^.MouseMoveCallback(temp, OGLwindow1.param.md.mouse, 1);
          end;}
        end;
      end
      else if cline.CmdEdit.text[1] = '$' then evaluate(system.copy(cline.CmdEdit.text, 2, length(cline.CmdEdit.text) - 1),sysunit)
      else commandmanager.executecommand(GDBPointer(cline.CmdEdit.text));
    end else commandmanager.executelastcommad;
    cline.CmdEdit.text := '';
    gdb.GetCurrentDWG.OGLwindow1.param.firstdraw := TRUE;
    gdb.GetCurrentDWG.OGLwindow1.CalcOptimalMatrix;
    gdb.GetCurrentDWG.OGLwindow1.paint;
  end;

end;*)
procedure clearotrack;
begin
     gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.current:=0;
     gdb.GetCurrentDWG.OGLwindow1.param.ontrackarray.total:=0;
end;
procedure clearcp;
begin
     gdb.GetCurrentDWG.SelObjArray.clearallobjects;
     //gdb.SelObjArray.clear;
end;
{procedure startup;
begin
     OSModeEditor.initnul;
end;
procedure finalize;
begin
     //mainform.done;
     //GDBFreeMem(gdb.GetCurrentDWG.OGLwindow1.param.pglscreen);
     //OSModeEditor.Done;
end;}
begin
  {$IFDEF DEBUGINITSECTION}LogOut('mainwindow.initialization');{$ENDIF}
end.
