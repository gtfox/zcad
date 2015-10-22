unit sysvar;
interface
uses System;
var
  INTF_ObjInsp_WhiteBackground:GDBBoolean;
  INTF_ObjInsp_ShowHeaders:GDBBoolean;
  INTF_ObjInsp_ShowSeparator:GDBBoolean;
  INTF_ObjInsp_OldStyleDraw:GDBBoolean;
  INTF_ObjInsp_ShowFastEditors:GDBBoolean;
  INTF_ObjInsp_ShowOnlyHotFastEditors:GDBBoolean;
  INTF_ObjInsp_RowHeight_OverriderEnable:GDBBoolean;
  INTF_ObjInsp_RowHeight_OverriderValue:GDBInteger;
  DWG_OSMode:GDBInteger;
  DWG_PolarMode:GDBBoolean;
  DWG_HelpGeometryDraw:GDBBoolean;
  DWG_EditInSubEntry:GDBBoolean;
  DWG_AdditionalGrips:GDBBoolean;
  DWG_SelectedObjToInsp:GDBBoolean;
  DWG_RotateTextInLT:GDBBoolean;
  DSGN_TraceAutoInc:GDBBoolean;
  DSGN_LeaderDefaultWidth:GDBDouble;
  DSGN_HelpScale:GDBDouble;
  DSGN_LCNet:TLayerControl;
  DSGN_LCCable:TLayerControl;
  DSGN_LCLeader:TLayerControl;
  DSGN_SelNew:GDBBoolean;
  DSGN_SelSameName:GDBBoolean;
  DSGN_OTrackTimerInterval:GDBInteger;
  INTF_ShowScrollBars:GDBBoolean;
  INTF_ShowDwgTabs:GDBBoolean;
  INTF_DwgTabsPosition:TAlign;
  INTF_ShowDwgTabCloseBurron:GDBBoolean;
  INTF_DefaultControlHeight:GDBInteger;
  INTF_ObjInsp_SpaceHeight:GDBInteger;
  INTF_ObjInsp_AlwaysUseMultiSelectWrapper:GDBBoolean;
  INTF_ObjInsp_ShowEmptySections:GDBBoolean;
  INTF_DefaultEditorFontHeight:GDBInteger;
  VIEW_CommandLineVisible:GDBBoolean;
  VIEW_HistoryLineVisible:GDBBoolean;
  VIEW_ObjInspVisible:GDBBoolean;
  StatusPanelVisible:GDBBoolean;
  DISP_SystmGeometryDraw:GDBBoolean;
  DISP_SystmGeometryColor:GDBInteger;
  DISP_ZoomFactor:GDBDouble;
  DISP_CursorSize:GDBInteger;
  DISP_CrosshairSize:GDBDouble;
  DISP_OSSize:GDBDouble;
  DISP_DrawZAxis:GDBBoolean;
  DISP_ColorAxis:GDBBoolean;
  DISP_GripSize:GDBInteger;
  DISP_UnSelectedGripColor:TGDBPaletteColor;
  DISP_SelectedGripColor:TGDBPaletteColor;
  DISP_HotGripColor:TGDBPaletteColor;
  DISP_BackGroundColor:TRGB;
  RD_UseStencil:GDBBoolean;
  RD_DrawInsidePaintMessage:TGDB3StateBool;
  RD_RemoveSystemCursorFromWorkArea:GDBBoolean;
  RD_PanObjectDegradation:GDBBoolean;
  RD_LineSmooth:GDBBoolean;
  RD_MaxLineWidth:GDBDouble;
  RD_MaxPointSize:GDBDouble;
  RD_Vendor:GDBString;
  RD_Renderer:GDBString;
  RD_Extensions:GDBString;
  RD_Version:GDBString;
  RD_GLUVersion:GDBString;
  RD_GLUExtensions:GDBString;
  RD_MaxWidth:GDBInteger;
  RD_Restore_Mode:TRestoreMode;
  RD_LastRenderTime:GDBInteger;
  RD_LastUpdateTime:GDBInteger;
  RD_MaxRenderTime:GDBInteger;
  RD_Light:GDBBoolean;
  RD_VSync:TGDB3StateBool;
  RD_ID_Enabled:GDBBoolean;
  RD_ID_MaxDegradationFactor:GDBDouble;
  RD_ID_PrefferedRenderTime:GDBInteger;
  RD_SpatialNodesDepth:GDBInteger;
  RD_SpatialNodeCount:GDBInteger;
  RD_MaxLTPatternsInEntity:GDBInteger;
  SAVE_Auto_Interval:GDBInteger;
  SAVE_Auto_Current_Interval:GDBInteger;
  SAVE_Auto_FileName:GDBString;
  SAVE_Auto_On:GDBBoolean;
  SYS_RunTime:GDBInteger;
  SYS_Version:GDBString;
  SYS_IsHistoryLineCreated:GDBBoolean;
  PATH_AlternateFont:GDBString;
  PATH_Device_Library:GDBString;
  PATH_Template_Path:GDBString;
  PATH_Template_File:GDBString;
  PATH_Program_Run:GDBString;
  PATH_Support_Path:GDBString;
  PATH_Fonts:GDBString;
  PATH_LayoutFile:GDBString;
  ShowHiddenFieldInObjInsp:GDBBoolean;
  testGDBBoolean:GDBBoolean;
  pi:GDBDouble;
implementation
begin
  INTF_ObjInsp_WhiteBackground:=False;
  INTF_ObjInsp_ShowHeaders:=True;
  INTF_ObjInsp_ShowSeparator:=True;
  INTF_ObjInsp_OldStyleDraw:=False;
  INTF_ObjInsp_ShowFastEditors:=True;
  INTF_ObjInsp_ShowOnlyHotFastEditors:=True;
  INTF_ObjInsp_RowHeight_OverriderEnable:=False;
  INTF_ObjInsp_RowHeight_OverriderValue:=21;
  DWG_OSMode:=14311;
  DWG_PolarMode:=True;
  DWG_HelpGeometryDraw:=True;
  DWG_EditInSubEntry:=False;
  DWG_AdditionalGrips:=False;
  DWG_SelectedObjToInsp:=True;
  DWG_RotateTextInLT:=True;
  DSGN_TraceAutoInc:=False;
  DSGN_LeaderDefaultWidth:=10.0;
  DSGN_HelpScale:=1.0;
  DSGN_LCNet.Enabled:=True;
  DSGN_LCNet.LayerName:='DEFPOINTS';
  DSGN_LCCable.Enabled:=True;
  DSGN_LCCable.LayerName:='EL_KABLE';
  DSGN_LCLeader.Enabled:=True;
  DSGN_LCLeader.LayerName:='TEXT';
  DSGN_SelNew:=False;
  DSGN_SelSameName:=False;
  DSGN_OTrackTimerInterval:=500;
  INTF_ShowScrollBars:=True;
  INTF_ShowDwgTabs:=True;
  INTF_DwgTabsPosition:=TATop;
  INTF_ShowDwgTabCloseBurron:=True;
  INTF_DefaultControlHeight:=27;
  INTF_ObjInsp_SpaceHeight:=3;
  INTF_ObjInsp_AlwaysUseMultiSelectWrapper:=True;
  INTF_ObjInsp_ShowEmptySections:=False;
  INTF_DefaultEditorFontHeight:=0;
  VIEW_CommandLineVisible:=True;
  VIEW_HistoryLineVisible:=True;
  VIEW_ObjInspVisible:=True;
  StatusPanelVisible:=False;
  DISP_SystmGeometryDraw:=False;
  DISP_SystmGeometryColor:=250;
  DISP_ZoomFactor:=1.624;
  DISP_CursorSize:=6;
  DISP_CrosshairSize:=0.05;
  DISP_OSSize:=10.0;
  DISP_DrawZAxis:=False;
  DISP_ColorAxis:=False;
  DISP_GripSize:=10;
  DISP_UnSelectedGripColor:=150;
  DISP_SelectedGripColor:=12;
  DISP_HotGripColor:=11;
  RD_UseStencil:=True;
  RD_DrawInsidePaintMessage:=T3SB_Default;
  RD_RemoveSystemCursorFromWorkArea:=True;
  RD_PanObjectDegradation:=False;
  RD_LineSmooth:=False;
  RD_MaxLineWidth:=10.0;
  RD_MaxPointSize:=63.375;
  RD_Vendor:='NVIDIA Corporation';
  RD_Renderer:='GeForce GTX 460/PCIe/SSE2';
  RD_Extensions:='';
  RD_Version:='4.3.0';
  RD_GLUVersion:='1.3';
  RD_GLUExtensions:='GLU_EXT_nurbs_tessellator GLU_EXT_object_space_tess ';
  RD_MaxWidth:=10;
  RD_BackGroundColor.r:=0;
  RD_BackGroundColor.g:=0;
  RD_BackGroundColor.b:=0;
  RD_BackGroundColor.a:=255;
  RD_Restore_Mode:=WND_Texture;
  RD_LastRenderTime:=0;
  RD_LastUpdateTime:=0;
  RD_MaxRenderTime:=0;
  RD_Light:=False;
  RD_VSync:=T3SB_Fale;
  RD_ID_Enabled:=False;
  RD_ID_MaxDegradationFactor:=0.0;
  RD_ID_PrefferedRenderTime:=20;
  RD_SpatialNodesDepth:=16;
  RD_SpatialNodeCount:=-1;
  RD_MaxLTPatternsInEntity:=10000;
  SAVE_Auto_Interval:=300;
  SAVE_Auto_Current_Interval:=299;
  SAVE_Auto_FileName:='*autosave/autosave.dxf';
  SAVE_Auto_On:=True;
  SYS_RunTime:=40;
  SYS_Version:='0.9.8 Revision SVN:Unknown';
  SYS_IsHistoryLineCreated:=True;
  PATH_AlternateFont:='GEWIND.SHX';
  PATH_Device_Library:='*programdb|c:/zcad/userdb';
  PATH_Template_Path:='*template';
  PATH_Template_File:='default.dxf';
  PATH_Program_Run:='E:\zcad\cad\';
  PATH_Support_Path:='*rtl|*rtl/objdefunits|*rtl/objdefunits/include|*components|*blocks/el/general|*rtl/styles';
  PATH_Fonts:='*fonts/|C:/Program Files/AutoCAD 2010/Fonts/|C:/APPS/MY/acad/support/|C:\Program Files\Autodesk\AutoCAD 2012 - Russian\Fonts\|C:\Windows\Fonts\';
  PATH_LayoutFile:='E:\zcad\cad\components/defaultlayout.xml';
  ShowHiddenFieldInObjInsp:=False;
  testGDBBoolean:=False;
  pi:=3.14159265359;
end.