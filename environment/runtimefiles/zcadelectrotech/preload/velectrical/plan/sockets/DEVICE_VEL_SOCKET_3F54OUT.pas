unit DEVICE_VEL_SOCKET_3F54OUT;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;
usescopy elreceivers;
usescopy vlocation;
usescopy vspecification;
usescopy vinfopersonaluse;

implementation

begin

BTY_TreeCoord:='PLAN_VEL_Розетки_Розетка ОП54 1Р 3х фазная';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='б/п';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]\P@@[Power] @@[LOCATION_height]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

realnamedev:='Розетка ОП54 1Р 3F';
Power:=0.06;
CosPHI:=0.8;
Voltage:=_AC_380V_50Hz;
Phase:=_ABC;

INFOPERSONALUSE_TextTemplate:='';

VSPECIFICATION_Position:='??';
VSPECIFICATION_Name:='Розетка ОП54 1Р ~380V';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Электроустановочные изделия низковольтные';
VSPECIFICATION_Belong:='';

SerialConnection:=1;

end.