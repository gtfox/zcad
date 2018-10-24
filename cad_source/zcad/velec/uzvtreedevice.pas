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
@author(Vladimir Bobrov)
}
{$mode objfpc}

unit uzvtreedevice;
{$INCLUDE def.inc}

interface
uses

{*uzcenitiesvariablesextender,sysutils,UGDBOpenArrayOfPV,uzbtypesbase,uzbtypes,
     uzeentity,varmandef,uzeentsubordinated,


  uzeconsts, //base constants
                      //описания базовых констант

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним

    uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

     gvector,garrayutils, // Подключение Generics и модуля для работы с ним

       //для работы графа
  ExtType,
  Pointerv,
  Graphs,
   *}
   sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, //uzcfblockinsert,
   uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия
  uzeentmtext,

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния
  uzeenttext,             //unit describes line entity
                       //модуль описывающий примитив текст

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,
  uzbgeomtypes,


  gvector,garrayutils, // Подключение Generics и модуля для работы с ним
  uzcstrconsts,
  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  uzegeometry,
  uzeentitiesmanager,

  uzcshared,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzcinterface,
  uzbtypesbase,uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzedrawingsimple,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzclog,                //log system
                      //<**система логирования
  uzcvariablesutils, // для работы с ртти

   gzctnrvectortypes,                  //itrec

  //для работы графа
  ExtType,
  Pointerv,
  Graphs,
  AttrType,
  AttrSet,
  //*

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations,

  uzvcom,
  uzvtmasterdev,
  uzvvisualgraph,
  uzvconsts,
  uzvtestdraw;


type
 TDummyComparer=class
 function Compare (Edge1, Edge2: Pointer): Integer;
 function CompareEdges (Edge1, Edge2: Pointer): Integer;
 end;
 TSortTreeLengthComparer=class
 function Compare (vertex1, vertex2: Pointer): Integer;
 end;

 //** Вектор графов деревьев
 //tvectorofGraph=specialize TVector<TGraph>;

    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.


  {** другая концепция отменина изз сложности подхода
//** Создания устройств к кто подключеным к вершине после
PTDeviceInfoSubGraph=^TDeviceInfoSubGraph;
      TDeviceInfoSubGraph=record
                         num:Integer;
                         tDevice:String;
      end;
      TListSubGraphDevice=specialize TVector<TDeviceInfoSubGraph>;

      //** Список вершин после данной вершины
      PTVertexAfterBefore=^TVertexAfterBefore;
      TVertexAfterBefore=record
                         numVertMainGrapgh:Integer;
                         numVertSubGrapgh:Integer;
      end;
      TListVertexAfter=specialize TVector<TVertexAfterBefore>;
      TListVertexBefore=specialize TVector<TVertexAfterBefore>;

      //** Создания списка вершин в графе для анализа структуры ситуации между группой устройств подключенных к одному входу головного устройства
      PTInfoVertexSubGraph=^TInfoVertexSubGraph;
      TInfoVertexSubGraph=class
                         afterDevice:TListSubGraphDevice;  //cписок устройств за вершиной (дальше от головного устройства)
                         vertexAfter:TListVertexAfter;     //вершины после данной вершины
                         vertexBefore:TListVertexBefore;   //Вершины перед данной вершины
                         beforeLength:double;              //длина линии от вершины до головного устройства
                         afterLength:double;               //общая длина всех длин после вершины (дальше от головного устройства)
                         afterPowerLine:double;            //мощность линии в данной точки после вершины
                         numVertexinMainGraph:integer;     //номер вершины в основном графе
                         nameGroup:string;                 //(нужно ли????)имя группы головного устройства

                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListVertexSubGraph=specialize TVector<TInfoVertexSubGraph>;
      **}


      ////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////
//      **************************СТАРАЯ ВЕРСИЯ

      {*******


       //** описания новых ребер которые проложены между вершинами при оценки ситуации с трассой от головного прибора до устройства
      PTInfoVertexSubGraph=^TInfoVertexSubGraph;
      TInfoVertexSubGraph=record
                         VIndex1:Integer; //номер 1-й вершниы по списку
                         VIndex2:Integer; //номер 2-й вершниы по списку
                         beforeLength:double;              //длина линии от вершины до головного устройства
                         length:double;                    //длина ребра
                         afterLength:double;               //общая длина всех длин после вершины (дальше от головного устройства)
                         afterPowerLine:double;            //мощность линии в данной точки после вершины
                         numBefore:Integer; //количество прохождений через данное ребро
                         numAfter:Integer; //количество прохождений через данное ребро при обратном движении :) вчем разница придыдущего незнаю

                         //numVertexinMainGraph:integer;     //номер вершины в основном графе
                         //nameGroup:string;                 //(нужно ли????)имя группы головного устройства

                         //public
                         //constructor Create;
                         //destructor Destroy;virtual;
      end;
      TListVertexSubGraph=specialize TVector<TInfoVertexSubGraph>;



       PTNumVertexMinWeight=^TNumVertexMinWeight;
       TNumVertexMinWeight=record
           num:Integer;
       end;

       TListNumVertexMinWeight=specialize TVector<TNumVertexMinWeight>;

      //** Создания устройств к кто подключается
     // PTDeviceInfo=^TDeviceInfo;
      TDeviceInfo=class
                         num:Integer;
                         tDevice:String;
                         listNumVertexMinWeight:TListNumVertexMinWeight;
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListSubDevice=specialize TVector<TDeviceInfo>;

      //Список точек прохождения трассы прокладки кабеля для визуализации и последующего анализа даного списка и автонумерации
      TListVertexWayOnlyVertex=specialize TVector<integer>;

      //создание списка распределительных коробок вершин главного графа
      TListVertexTerminalBox=specialize TVector<integer>;

      //** Создания групп у устройства к которому подключаются
      //PTHeadGroupInfo=^THeadGroupInfo;//с классами эта байда уже не нужна, т.к. класс сам по себе уже указатель
      THeadGroupInfo=class
                         listDevice:TListSubDevice;
                         //список движения пути по вершинам и сбор информации по подключенным устройствам
                         listVertexWayGroup:TListVertexSubGraph;
                         listVertexWayOnlyVertex:TListVertexWayOnlyVertex;
                         listVertexTerminalBox:TListVertexTerminalBox; // список распред коробки, в каких вершинах и сколько кабелей
                         name:String;
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListHeadGroup=specialize TVector<THeadGroupInfo>;

      //** Создания устройств к кому подключаются
      //PTHeadDeviceInfo=^THeadDeviceInfo;//с классами эта байда уже не нужна, т.к. класс сам по себе уже указатель
      THeadDeviceInfo=class
                         num:GDBInteger;
                         name:String;
                         shortName:String;
                         listGroup:TListHeadGroup; //список подчиненных устройств
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListHeadDevice=specialize TVector<THeadDeviceInfo>;


           ////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////
//      **************************НОВАЯ ВЕРСИЯ

////** Создания класса головного устройства
//TMasterDevice=class
//     lIndex:specialize TVector<integer>;
//     name:String;
//     shortName:String;
//     listGroup:TListGroup; //список подчиненных устройств
//     public
//     constructor Create;
//     destructor Destroy;virtual;
//end;
//TListHeadDevice=specialize TVector<THeadDeviceInfo>;



////////////////////////////////////////////////
////////////////////////////////////////////////

      //**список для кабельной прокладки
      PTInfoCableLaying=^TInfoCableLaying;
       TInfoCableLaying=record
           headName:string;
           GroupNum:string;
           typeSLine:string;

       end;
      TlistCableLaying=specialize TVector<TInfoCableLaying>;

             TListString=specialize TVector<string>;




             ********}

      ////********************************************
      ////** Создания списка ребер графа для графа анализа групп устройств
      //PTInfoEdgeSubGraph=^TInfoEdgeSubGraph;
      //TInfoEdgeSubGraph=record
      //                   VIndex1:GDBInteger; //номер 1-й вершниы по списку
      //                   VIndex2:GDBInteger; //номер 2-й вершниы по списку
      //                   VPoint1:GDBVertex;  //координаты 1й вершниы
      //                   VPoint2:GDBVertex;  //координаты 2й вершниы
      //                   edgeLength:GDBDouble; // длина ребра
      //end;
      //TListEdgeSubGraph=specialize TVector<TInfoEdgeSubGraph>;
      ////*********************************************
      ////** Создания списка устройств для графа анализа групп устройств
      //PTInfoVertexSubGraph=^TInfoVertexSubGraph;
      //TInfoVertexSubGraph=record
      //                   deviceEnt:PGDBObjDevice;
      //                   centerPoint:GDBVertex;
      //                   //lPoint:GDBVertex;
      //end;
      //TListVertexSubGraph=specialize TVector<TInfoVertexSubGraph>;
      //
      ////********************************************
      //// Граф требуется для анализа структуры ситуации между группой устройств подключенных к одному входу головного устройства
      //
      //PTSubGraphBuilder=^TSubGraphBuilder;
      //TSubGraphBuilder=class(TObject)
      //                   listEdge:TListEdgeSubGraph;
      //                   listVertex:TListVertexSubGraph;
      //                   public
      //                   constructor Create;
      //                   destructor Destroy;virtual;
      //end;
      //
      //



 //     function getGroupDeviceInGraph(ourGraph:TGraphBuilder;Epsilon:double; var listError:TListError):TListHeadDevice;
 // procedure getListOnlyVertexWayGroup(var ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder);
 //function testTempDrawPolyLineNeed(myVertex:TListVertexWayOnlyVertex;ourGraph:TGraphBuilder;color:Integer):TCommandResult;
 //function visualGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;color:Integer;numHead:integer;numGroup:integer;accuracy:double):TCommandResult;
 //function cablingGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;numHead:integer;numGroup:integer):TCommandResult;

 //procedure errorSearchAllParam(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
 //procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError);
 procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
 procedure errorList(allGraph:TListAllGraph;Epsilon:double;var listError:TListError;listSLname,listAllSLname:TGDBlistSLname);
 //procedure visualGraph(G: TGraph; var startPt:GDBVertex;height:double);
 //procedure metricNumeric(metric:boolean;dev:PGDBObjDevice);
 procedure visualMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean;heightText:double;numDevice:boolean);
 procedure visualGraphConnection(GGraph:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;graphFull,graphEasy:boolean;var fTreeVertex:GDBVertex;var eTreeVertex:GDBVertex);

 procedure cabelingMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
 function buildListAllConnectDevice(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;

implementation
var
  DummyComparer:TDummyComparer;
  SortTreeLengthComparer:TSortTreeLengthComparer;

  {***










constructor TDeviceInfo.Create;
begin
  listNumVertexMinWeight:=TListNumVertexMinWeight.Create;
end;
destructor TDeviceInfo.Destroy;
begin
  listNumVertexMinWeight.Destroy;
end;
//constructor TInfoVertexSubGraph.Create;
//begin
//  afterDevice:=TListSubGraphDevice.Create;
//  vertexAfter:=TListVertexAfter.Create;
//  vertexBefore:=TListVertexBefore.Create;
//end;
//destructor TInfoVertexSubGraph.Destroy;
//begin
//  afterDevice.Destroy;
//  vertexAfter.Destroy;
//  vertexBefore.Destroy;
//end;
constructor THeadGroupInfo.Create;
begin
  listDevice:=TListSubDevice.Create;
  listVertexWayGroup:=TListVertexSubGraph.Create;
  listVertexWayOnlyVertex:=TListVertexWayOnlyVertex.Create;
  listVertexTerminalBox:=TListVertexTerminalBox.Create;
end;
destructor THeadGroupInfo.Destroy;
begin
  listDevice.Destroy;
  listVertexWayGroup.Destroy;
  listVertexWayOnlyVertex.Destroy;
  listVertexTerminalBox.Destroy;
end;
constructor THeadDeviceInfo.Create;
begin
  listGroup:=TListHeadGroup.Create;
end;
destructor THeadDeviceInfo.Destroy;
begin
  listGroup.Destroy;
end;
//
////** Создание под графа который состоит только из устройств подключенных к одному входу головного устройства
//// для решения в последующем вопрос связанных с нумерацией и разных промежуточных вычислений вызваных расхождением трассы и.т.д
//function getSubGraphAnalizGroup(listVertex:TListDeviceLine;name:string):integer;
//var
//   i: Integer;
//   pvd:pvardesk; //для работы со свойствами устройств
//begin
//     result:=-1;
//     for i:=0 to listVertex.Size-1 do
//        begin
//           if listVertex[i].deviceEnt<>nil then
//           begin
//               pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
//               if pgdbstring(pvd^.data.Instance)^ = name then
//                  result:= i;
//           end;
//
//        end;
//     // ZCMsgCallBackInterface.TextMessage(IntToStr(result));
//end;
//




function VertexCenter(const Vertex1, Vertex2: GDBVertex): GDBVertex;
begin
  Result.X := (Vertex1.x + Vertex2.x)/2;
  Result.Y := (Vertex1.y + Vertex2.y)/2;
  Result.Z := (Vertex1.z + Vertex2.z)/2;
end;
//** Анализ полученного списка устройств движение трассы и построение на базе главного графа дерева,
//которое будет относится только к группе(шлейфу)

{***времено что лучше процедура или функция

function createTreeDeviceinGroup(ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder):TListVertexSubGraph;
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength:double;
   IsExchange, haveLimb:boolean;
   i,j,k,l,counterColor:integer;
begin
    result:=TListVertexSubGraph.Create;

    for i:= 0 to ourListGroup.listDevice.Size-1 do begin
       HistoryOutStr('длина группы :' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight.Size));
      for j:= 0 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
         HistoryOutStr(IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num));
      end;
      // строим только ребра графа, в качестве вершин будут выступать вершины главного графа.
      //делаем проход по всем вершинам от главного устройства до устр. и заплняем нужной информацией ребра
      //с начала проходка от головного до устр
       for j:= 1 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
          //HistoryOutStr('1' + IntToStr(result.Size));
          // limbTreeDeviceinGroup:=TInfoVertexSubGraph.Create;
           //beforeLength:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1]].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j]].centerPoint);
           //limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.beforeLength + beforeLength;
           if result.IsEmpty then //если список пуст
               begin
                  // limbTreeDeviceinGroup

                   limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                   limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                   limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                   limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                   limbTreeDeviceinGroup.numBefore:=1;
                   result.PushBack(limbTreeDeviceinGroup);
                   //limbTreeDeviceinGroup:=nil;
               end
             else
                 begin
                    haveLimb:=true;
                    for k:=0 to result.Size-1 do    //проверяем существует ли уже такое ребро
                       if (result[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) or (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                         if (result[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) or (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                             begin
                                  result.Mutable[k]^.numBefore:=result[k].numBefore+1;
                                  haveLimb:=false;
                             end;
                    if haveLimb then        // если такого ребра нет, то добавляем новое
                       begin
                           //limbTreeDeviceinGroup:=nil;
                           limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                           limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                           limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                           for k:=0 to result.Size-1 do    //проверяем существует ли уже такое ребро
                             if (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                               begin
                                  limbTreeDeviceinGroup.beforeLength:=result[k].beforeLength+limbTreeDeviceinGroup.length;
                               end
                               else
                               begin
                                  limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                               end;
                           limbTreeDeviceinGroup.numBefore:=1;
                           result.PushBack(limbTreeDeviceinGroup);
                           //limbTreeDeviceinGroup:=nil;
                       end;
             end;
        end;
      // HistoryOutStr('222' + IntToStr(result.Size));
       // теперь от каждого устр. до головного
       // нужно что бы около головного устройства можно было понять какой из путей самый длинный или какой самый загружанный датчиками
       for j:=ourListGroup.listDevice[i].listNumVertexMinWeight.Size-2 to 0 do begin
          for k:=0 to result.Size-1 do
             if (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) and (result[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                   begin
                       for l:=0 to result.Size-1 do
                           if (result[l].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                             begin
                                result.Mutable[k]^.afterLength:=result[l].afterLength+result[k].length;
                             end
                             else
                             begin
                                result.Mutable[k]^.afterLength:=result[k].length;
                             end;
                   end;
        end;
       HistoryOutStr('длина списка' + IntToStr(result.Size));
    end;

end;
  // repeat
  //  IsExchange := False;
  //  for j := 0 to listNumVertex.Size-2 do begin
  //    if uzegeometry.Vertexlength(listDevice[myNum].centerPoint,listDevice[listNumVertex[j].num].centerPoint) > uzegeometry.Vertexlength(listDevice[myNum].centerPoint,listDevice[listNumVertex[j+1].num].centerPoint) then begin
  //      tempNumVertex := listNumVertex[j];
  //      listNumVertex.Mutable[j]^ := listNumVertex[j+1];
  //      listNumVertex.Mutable[j+1]^ := tempNumVertex;
  //      IsExchange := True;
  //    end;
  //  end;
  //until not IsExchange;
  //
  ***}

  // Данный список будет содержать все вершины в которых прокладывается трассы для устройств в группе
// и уже основываясь на том, что будет в этом списке, можно будет получить все остальные данные
 procedure createTreeDeviceinGroup(var ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder);
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength,bAfterLength:double;
   bNumAfter,numEdgeNow,numEdgeBefore:integer;
   IsExchange, haveLimb, haveWay, lengthEqual:boolean;
   i,j,k,l,counterColor,goodWayCol:integer;
begin
    //ourListGroup.listVertexWayGroup;
    counterColor:=0;
    goodWayCol:=0;
    for i:= 0 to ourListGroup.listDevice.Size-1 do begin

      // строим только ребра графа, в качестве вершин будут выступать вершины главного графа.
      //делаем проход по всем вершинам от главного устройства до устр. и заплняем нужной информацией ребра
      //с начала проходка от головного до устр
      if ourListGroup.listDevice[i].listNumVertexMinWeight<>nil then begin
       goodWayCol:=goodWayCol+1;
       for j:= 1 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
           if ourListGroup.listVertexWayGroup.IsEmpty then //если список пуст
               begin
                   limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                   limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                   limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                   limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                   limbTreeDeviceinGroup.afterLength:=limbTreeDeviceinGroup.length;
                   limbTreeDeviceinGroup.numAfter:=0;
                   limbTreeDeviceinGroup.numBefore:=1;
                   ourListGroup.listVertexWayGroup.PushBack(limbTreeDeviceinGroup);
               end
             else
                 begin
                    haveLimb:=true;
                    for k:=0 to ourListGroup.listVertexWayGroup.Size-1 do    //проверяем существует ли уже такое ребро
                       if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                         if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                             begin
                                  ourListGroup.listVertexWayGroup.Mutable[k]^.numBefore:=ourListGroup.listVertexWayGroup[k].numBefore+1;
                                  haveLimb:=false;
                             end;
                    if haveLimb then        // если такого ребра нет, то добавляем новое
                       begin
                           limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                           limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                           limbTreeDeviceinGroup.numAfter:=0;
                           limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                           limbTreeDeviceinGroup.afterLength:=limbTreeDeviceinGroup.length;

                           //Ищем среди всех ребер ребро вершиной которого является наша первая точка,
                           //нужно для того что бы бефореленгф тянулся по всей глубине.
                           haveWay:=true;
                           for k:=0 to ourListGroup.listVertexWayGroup.Size-1 do
                             if (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                               begin
                                  haveWay:=false;
                               //    HistoryOutStr('way'+IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num)+ '----vertex = ' + IntToStr(ourListGroup.listVertexWayGroup[k].VIndex2) + '----search = ' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num));
                                  limbTreeDeviceinGroup.beforeLength:=ourListGroup.listVertexWayGroup[k].beforeLength+limbTreeDeviceinGroup.length;
                               end;
                           if haveWay then
                               begin
                               //    HistoryOutStr('way'+IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num)+ '----vertex = ' + IntToStr(ourListGroup.listVertexWayGroup[k].VIndex2) + '----search = ' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num));
                                  limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                               end;
                            //------------------
                           limbTreeDeviceinGroup.numBefore:=1;
                           ourListGroup.listVertexWayGroup.PushBack(limbTreeDeviceinGroup);
                       end;
             end;
        end;


       // теперь от каждого устр. до головного
       // нужно что бы около головного устройства можно было понять какой из путей самый длинный
       //или какой самый загружанный датчиками
       //HistoryOutStr('вставка текста0');
       bAfterLength:=0;
      // lengthEqual:=true;
       for j:=ourListGroup.listDevice[i].listNumVertexMinWeight.Size-2 downto 0 do
         begin
          //HistoryOutStr('позиция шага мин' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num));
          numEdgeNow:=-1;
          numEdgeBefore:=-1;
          for k:=0 to ourListGroup.listVertexWayGroup.Size-1 do
            begin
          //   HistoryOutStr('afterlength= ' + FloatToStr(ourListGroup.listVertexWayGroup[k].afterLength));


             //смотем длину ребра выбранного сейчас
             if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) then
                if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                        numEdgeNow:=k;

              //ищем предыдущее ребро перед тем которое выбранно сейчас
             if j<>ourListGroup.listDevice[i].listNumVertexMinWeight.Size-2 then
               if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+2].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+2].num) then
                 if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) then
                        numEdgeBefore:=k;
             //---------------

          end;

          if numEdgeNow>=0 then
            ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.numAfter:= ourListGroup.listVertexWayGroup[numEdgeNow].numAfter+1;
          if (numEdgeBefore>0) then
            begin
               if ourListGroup.listVertexWayGroup[numEdgeNow].length = ourListGroup.listVertexWayGroup[numEdgeNow].afterLength then begin
                  ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.afterLength:=ourListGroup.listVertexWayGroup[numEdgeBefore].afterLength + ourListGroup.listVertexWayGroup[numEdgeNow].length ;
                  bAfterLength:= ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.afterLength;
               end
               else
                  ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.afterLength:=bAfterLength + ourListGroup.listVertexWayGroup[numEdgeNow].afterLength;
            end;
        end;
       //HistoryOutStr('длина списка' + IntToStr(ourListGroup.listVertexWayGroup.Size));

    end;
      end;
      if goodWayCol=0 then
      begin
         ourListGroup.listVertexWayGroup:=nil;
      end;
end;

 procedure getListOnlyVertexWayGroup(var ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder);
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   listNumEdge:TListVertexWayOnlyVertex;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength,bAfterLength:double;
   bNumAfter,numEdgeNow,numEdgeBefore:integer;
   IsExchange, haveVertex, haveWay, lengthEqual:boolean;
   i,j,k,l,tempNumVertex,NumVertexSave:integer;
  // IsExchange:boolean;
begin


    //промежуточный список вершин
          listNumEdge:=TListVertexWayOnlyVertex.Create;

          NumVertexSave := ourListGroup.listVertexWayOnlyVertex[ourListGroup.listVertexWayOnlyVertex.size-1];  // номер первой вершины

          //поиск количество вершин куда двигается путь и их ид
          for i:= 0 to ourListGroup.listVertexWayGroup.Size-1 do
            begin
               if (ourListGroup.listVertexWayGroup[i].VIndex1 = NumVertexSave)  then
                 begin
                     listNumEdge.PushBack(i);
                 end;
            end;

          //создание списка распределительных коробок, мест, где кабель должен разделится
          haveVertex:=true;
          if (listNumEdge.Size > 1) then begin
            haveVertex:=false;
            for i:=0 to ourListGroup.listVertexTerminalBox.size-1 do
               if ourListGroup.listVertexTerminalBox[i] = NumVertexSave then
                 haveVertex:=true;
          end;
          if not haveVertex then
            ourListGroup.listVertexTerminalBox.PushBack(NumVertexSave);


        //сортировка среди полученых вершин у какого пути короче путь
        if listNumEdge.Size > 1 then
          repeat
            IsExchange := False;
            for i := 0 to listNumEdge.Size-2 do begin
              if ourListGroup.listVertexWayGroup[listNumEdge[i]].afterLength > ourListGroup.listVertexWayGroup[listNumEdge[i+1]].afterLength then begin
                tempNumVertex := listNumEdge[i];
                listNumEdge.Mutable[i]^ := listNumEdge[i+1];
                listNumEdge.Mutable[i+1]^ := tempNumVertex;
                IsExchange := True;
              end;
            end;
          until not IsExchange;

        //рекурсия отправляемся к следующейй точки у который путь короче
        if listNumEdge.Size > 0 then
          for i := 0 to listNumEdge.Size-1 do begin
              ourListGroup.listVertexWayOnlyVertex.PushBack(ourListGroup.listVertexWayGroup[listNumEdge[i]].VIndex2);
              getListOnlyVertexWayGroup(ourListGroup,ourGraph);
              ourListGroup.listVertexWayOnlyVertex.PushBack(NumVertexSave);
          end;
        listNumEdge.Destroy;

end;

 //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
function testTempDrawPolyLineNeed(myVertex:TListVertexWayOnlyVertex;ourGraph:TGraphBuilder;color:Integer):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    i:integer;
    //vertexObj:GDBvertex;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
     polyObj:=GDBObjPolyline.CreateInstance;
     zcSetEntPropFromCurrentDrawingProp(polyObj);
     polyObj^.Closed:=false;
     polyObj^.vp.Color:=color;
     polyObj^.vp.LineWeight:=LnWt050;
     polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
     for i:=0 to myVertex.Size-1 do
     begin
         polyObj^.VertexArrayInOCS.PushBackData(ourGraph.listVertex[myVertex[i]].centerPoint);
        // uzvcom.testTempDrawText(ourGraph.listVertex[myVertex[i]].centerPoint,IntToStr(i));
     end;

     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;


//Визуализация текста его p1-координата, mText-текст, color-цвет, размер
function visualDrawText(p1:GDBVertex;mText:GDBString;color:integer;heightText:double):TCommandResult;
var
    ptext:PGDBObjText;
begin
      ptext := GDBObjText.CreateInstance;
      zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
      ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
      ptext^.Local.P_insert:=p1;  // координата
      ptext^.Template:=mText;     // сам текст
      ptext^.vp.LineWeight:=LnWt100;
      ptext^.vp.Color:=color;
      ptext^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
      ptext^.textprop.size:=heightText;
      zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
      result:=cmd_ok;
end;

//Визуализация круга его p1-координата, rr-радиус, color-цвет
function visualDrawCircle(p1:GDBVertex;rr:GDBDouble;color:integer):TCommandResult;
var
    pcircle:PGDBObjCircle;
begin
    begin
      pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
      pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

      zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
      pcircle^.vp.LineWeight:=LnWt100;
      pcircle^.vp.Color:=color;
      pcircle^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
      zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;


//Визуализация построения шлейфов головных устройств с целью визуального изучения того как будут прокладываться кабельные линии
//дабы исключить возмоные программные ошибки
function visualGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;color:Integer;numHead:integer;numGroup:integer;accuracy:double):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    myTerminalBox:TListVertexTerminalBox;


begin
     vertexAnalized:= TListVertexWayOnlyVertex.Create;
     myVertex:=listHeadDevice[numHead].listGroup[numGroup].listVertexWayOnlyVertex;
     myTerminalBox:=listHeadDevice[numHead].listGroup[numGroup].listVertexTerminalBox;
     polyObj:=GDBObjPolyline.CreateInstance;
     zcSetEntPropFromCurrentDrawingProp(polyObj);
     polyObj^.Closed:=false;
     polyObj^.vp.Color:=color;
     polyObj^.vp.LineWeight:=LnWt050;
     polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');


     //визуализация коробок распределения
     if myTerminalBox <> nil then
     for i:= 0 to myTerminalBox.size-1 do
       visualDrawCircle(ourGraph.listVertex[myTerminalBox[i]].centerPoint,1,color);

     counter:=0;
     if myVertex <> nil then
     for i:=0 to myVertex.Size-1 do
     begin
         notVertex:=true;
         polyObj^.VertexArrayInOCS.PushBackData(ourGraph.listVertex[myVertex[i]].centerPoint); //для прорисовки полилинии

         // проверка есть ли данная вершина среди пронумерованых вершин
         for j:= 0 to vertexAnalized.size-1 do begin
           if myVertex[i] =  vertexAnalized[j] then
              notVertex:=false;
         end;

         // если в данной вершине есть устройство и оно не стояк и оно не пронумеровано
         if (ourGraph.listVertex[myVertex[i]].deviceEnt<>nil) and (ourGraph.listVertex[myVertex[i]].break<>true) and notVertex then
           for j:= 0 to listHeadDevice[numHead].listGroup[numGroup].listDevice.size-1 do    // ищем среди устройств то которое является данной вершиной
              if myVertex[i]= listHeadDevice[numHead].listGroup[numGroup].listDevice[j].num then begin
                inc(counter);
                mtext:=listHeadDevice[numHead].name + '-' + listHeadDevice[numHead].listGroup[numGroup].name + '-' + IntToStr(counter);
                //HistoryOutStr(' text = ' + mtext);
                visualDrawCircle(ourGraph.listVertex[myVertex[i]].centerPoint,7*accuracy,color);
                visualDrawText(ourGraph.listVertex[myVertex[i]].centerPoint,mtext,color,4*accuracy);
                vertexAnalized.PushBack(myVertex[i]);
              end;
     end;
     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;

//создание кабеля по маршруту и добавления кабелю определенных свойств
function buildCableGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;numHead:integer;numGroup:integer;numSegment:integer;wayVertex:TListVertexWayOnlyVertex):TCommandResult;
var
    //polyObj:PGDBObjPolyLine;
    polyObj:PGDBObjCable;
    i,j,counter:integer;
    mtext:string;
    notVertex,bCable:boolean;
    pvd,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    myTerminalBox:TListVertexTerminalBox;
    //listTraversedVert:TListVertexTerminalBox;
        psu:ptunit;
        pvarext:PTVariablesExtender;
begin

     polyObj := AllocEnt(GDBCableID);
     polyObj^.init(nil,nil,0);
     zcSetEntPropFromCurrentDrawingProp(polyObj);

     for i:=0 to wayVertex.Size-1 do
     begin
         polyObj^.VertexArrayInOCS.PushBackData(ourGraph.listVertex[wayVertex[i]].centerPoint); //для прорисовки полилинии
     end;

     //**добавление кабельных свойств
      pvarext:=polyObj^.GetExtension(typeof(TVariablesExtender)); //подклчаемся к инспектору
      if pvarext<>nil then
      begin
        psu:=units.findunit(SupportPath,@InterfaceTranslate,'cable'); //
        if psu<>nil then
          pvarext^.entityunit.copyfrom(psu);
      end;
      zcSetEntPropFromCurrentDrawingProp(polyObj);
      //***//

      pvd:=FindVariableInEnt(polyObj,'NMO_Suffix');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].listGroup[numGroup].name ;
          end;

        pvd:=FindVariableInEnt(polyObj,'GC_HDShortName');
        if pvd<>nil then
           begin
              pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].shortName;
           end;


       pvd:=FindVariableInEnt(polyObj,'GC_HeadDevice');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].name ;
          end;

       pvd:=FindVariableInEnt(polyObj,'CABLE_AutoGen');
              if pvd<>nil then
                 begin
                    pgdbboolean(pvd^.data.Instance)^:=true;
                 end;

       pvd:=FindVariableInEnt(polyObj,'GC_HDGroup');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].listGroup[numGroup].name ;
          end;


      pvd:=FindVariableInEnt(polyObj,'NMO_BaseName');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].name + '-';
          end;
       pvd:=FindVariableInEnt(polyObj,'CABLE_Segment');
       if pvd<>nil then
          begin
             pgdbinteger(pvd^.data.Instance)^:=numSegment;
          end;


     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;
//прокладка кабелей, от устройства до устройства с учетом распределительных коробок
// с сегментированием кабелей и доп фишками
function cablingGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;numHead:integer;numGroup:integer):TCommandResult;
var
    //polyObj:PGDBObjPolyLine;
    polyObj:PGDBObjCable;
    i,j,counter:integer;
    mtext:string;
    notVertex,bCable,breakCable:boolean;
    pvd,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    myVertex,vertexAnalized,wayCableLine:TListVertexWayOnlyVertex;
    myTerminalBox:TListVertexTerminalBox;
    //listTraversedVert:TListVertexTerminalBox;
        psu:ptunit;
        pvarext:PTVariablesExtender;
begin
     vertexAnalized:= TListVertexWayOnlyVertex.Create;
     wayCableLine:= TListVertexWayOnlyVertex.Create;
     myVertex:=listHeadDevice[numHead].listGroup[numGroup].listVertexWayOnlyVertex;
     myTerminalBox:=listHeadDevice[numHead].listGroup[numGroup].listVertexTerminalBox;

     counter:=0;
     bCable:=false;   //прокладка кабеля не ведется
     notVertex:=true;
     for i:=0 to myVertex.Size-1 do
     begin
         notVertex:=true;
        // visualDrawText(ourGraph.listVertex[myVertex[i]].centerPoint,inttostr(i),counterColor);
         //была ли уже прокладка кабеля в этой вершине сравнивается спиок пройденых вершин и данная вершина
         for j:= 0 to vertexAnalized.size-1 do
         begin
           if myVertex[i] = vertexAnalized[j] then
                notVertex:=false
         end;

         if (notVertex) then
           begin
             if bCable=false then
               begin
                 bCable:=true;
                 if (i<>0) then
                   if (ourGraph.listVertex[myVertex[i-1]].break<>true) then  //  проерка является ли предыдущая вершина разрывом
                      wayCableLine.PushBack(myVertex[i-1]);
               end;
               vertexAnalized.PushBack(myVertex[i]);
               wayCableLine.PushBack(myVertex[i]);
             //  bCable:=true;
           end;
        // HistoryOutStr(' nummber vertex = ' + inttostr(i));
         //проверка на стояки что бы правильно разорвать трассу в местах стояка
         if i<myVertex.Size-1 then
           if (ourGraph.listVertex[myVertex[i]].break=true) and (ourGraph.listVertex[myVertex[i+1]].break=true) then
             begin
            // HistoryOutStr(' [myVertex[i]].break = ' + BoolToStr(ourGraph.listVertex[myVertex[i]].break)+' [myVertex[i+1]].break = ' + BoolToStr(ourGraph.listVertex[myVertex[i+1]].break));
               if (ourGraph.listVertex[myVertex[i]].breakName=ourGraph.listVertex[myVertex[i+1]].breakName) then
               begin
              // HistoryOutStr(' [myVertex[i]].breakName = ' + ourGraph.listVertex[myVertex[i]].breakName+' [myVertex[i+1]].breakName = ' + ourGraph.listVertex[myVertex[i+1]].breakName);

                 notVertex:=false;
                 //bCable:=true;
               end;
             end;

         if (notVertex=false) and bCable then
           begin
             //  visualDrawCircle(ourGraph.listVertex[myVertex[i]].centerPoint,5,4);
               buildCableGroupLine(listHeadDevice,ourGraph,numHead,numGroup,counter,wayCableLine);
               wayCableLine.clear;
               counter:=counter+1;
               bCable:=false;
           end;
     end;
     result:=cmd_ok;
end;

 //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
function autoNumberEquip(lVertex:TListVertexWayOnlyVertex;ourGraph:TGraphBuilder;color:Integer):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    i:integer;
    //vertexObj:GDBvertex;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
     //polyObj:=GDBObjPolyline.CreateInstance;
     //zcSetEntPropFromCurrentDrawingProp(polyObj);
     //polyObj^.Closed:=false;
     //polyObj^.vp.Color:=color;
     //polyObj^.vp.LineWeight:=LnWt050;
     ////ourGraph.listVertex[listVertex[i]].centerPoint;
     for i:=0 to lVertex.Size-1 do
     begin
      if ourGraph.listVertex[lVertex[i]].deviceEnt<>nil then
         begin

         end;
     end;

     //zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;

function NumPsIzvAndDlina_com(operands:TCommandOperands):TCommandResult;
  begin

  end;


//рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
procedure metricNumeric(metric:boolean;dev:PGDBObjDevice);
var
    pvd:pvardesk;
    name:string;
begin

    name:='';
    if metric then begin
     pvd:=FindVariableInEnt(dev,'NMO_BaseName');
     if pvd<>nil then
       name:=pgdbstring(pvd^.data.Instance)^;
     end;

     pvd:=FindVariableInEnt(dev,'GC_InGroup_Metric');
       if pvd<>nil then
        begin
           pgdbstring(pvd^.data.Instance)^:=name ;
        end;
end;


//** Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
function listHeadDevConnect(nowDev:PGDBObjDevice;var listCableLaying:TlistCableLaying;nameSL:string):boolean;
var
   pvd:pvardesk; //для работы со свойствами устройств

   polyObj:PGDBObjPolyLine;
   i,counter1,counter2,counter3:integer;
   tempName,nameParam:gdbstring;
   infoLay:TInfoCableLaying;
   listStr1,listStr2,listStr3:TListString;

begin
     listStr1:=TListString.Create;
     listStr2:=TListString.Create;
     listStr3:=TListString.Create;

     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_HeadDeviceName');
     if pvd<>nil then
        BEGIN
     tempName:=pgdbstring(pvd^.data.Instance)^;
     repeat
           GetPartOfPath(nameParam,tempName,';');
           listStr1.PushBack(nameParam);
          // HistoryOutStr(' code2 = ' + nameParam);
     until tempName='';

     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_NGHeadDevice');
               if pvd<>nil then
        BEGIN
     tempName:=pgdbstring(pvd^.data.Instance)^;
     repeat
           GetPartOfPath(nameParam,tempName,';');
           listStr2.PushBack(nameParam);
     until tempName='';

     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_SLTypeagen');
          if pvd<>nil then
        BEGIN
     tempName:=pgdbstring(pvd^.data.Instance)^;
     repeat
           GetPartOfPath(nameParam,tempName,';');
           listStr3.PushBack(nameParam);
     until tempName='';

     for i:=0 to listStr1.size-1 do
         begin
         infoLay.headName:=listStr1[i];
         infoLay.GroupNum:=listStr2[i];
         infoLay.typeSLine:=listStr3[i];
        // HistoryOutStr(' codeeeeee = ' + infoLay.headName);
         if infoLay.typeSLine = nameSL then
            listCableLaying.PushBack(infoLay);
         end;
        end;
        end;

     end;
     if listCableLaying.size > 0 then
        result:=true
        else
        result:=false;
end;

function getGroupDeviceInGraph(ourGraph:TGraphBuilder;Epsilon:double; var listError:TListError):TListHeadDevice;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
      //Epsilon:double;
      deviceInfo: TDeviceInfo;
      listSubDevice:TListSubDevice;  // список подчиненных устройств входит в список головных устройств

      listHeadGroup:TListHeadGroup;
      HeadGroupInfo:THeadGroupInfo;
      headDeviceInfo:THeadDeviceInfo;
      listHeadDevice:TListHeadDevice;

      listCableLaying:TlistCableLaying; //список кабельной прокладки

      drawing:PTSimpleDrawing; //для работы с чертежом
      pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
      //ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
      numHead,numHeadGroup,numHeadDev : integer;
      shortNameHead, headDevName, groupName:string;
      counter,counter2,counterColor:integer; //счетчики
    i,j,k,l,m,numnum: Integer;
    T: Float;
    pCenter,gg:GDBVertex;
    ttt:TInfoVertexSubGraph;


    //ourGraph:TGraphBuilder;
    pvd:pvardesk; //для работы со свойствами устройств

    GListVert:GListVertexPoint;

    //временое номера минимального пути от головного устройства до девайса
    tempListNumVertexMinWeight:TListNumVertexMinWeight;
    tempNumVertexMinWeight:TNumVertexMinWeight;


  begin

    listSubDevice := TListSubDevice.Create;
    listHeadGroup :=  TListHeadGroup.Create;
    listHeadDevice := TListHeadDevice.Create;
    listCableLaying := TlistCableLaying.Create;

    //Epsilon:=0.2;
    counter:=0;


    //G:=TGraph.Create;
    //G.Features:=[Tree];
    //EdgePath:=TClassList.Create;
    //VertexPath:=TClassList.Create;
    //G.AddVertices(ourGraph.listVertex.Size);
    //for i:=0 to ourGraph.listEdge.Size-1 do
    //begin
    //      G.AddEdge(G.Vertices[ourGraph.listEdge[i].VIndex1],G.Vertices[ourGraph.listEdge[i].VIndex2]);
    //end;
    //G.Root:=G.Vertices[2];
    //G.CorrectTree;
    //G.TreeTraversal(G.Root, VertexPath);
    //
    ////G.SetTempToSubtreeSize(G.Root);
    //
    //gg:=uzegeometry.CreateVertex(0,0,0) ;
    //visualGraph(G,G.Root.index,gg,1);
    //

        // Подключение созданного граффа к библиотеке Аграф

    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for i:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[i].VIndex1, ourGraph.listEdge[i].VIndex2]);
      G.Edges[i].Weight:=ourGraph.listEdge[i].edgeLength;
    end;


    //обращаемся к функции за графом
    //ourGraph:=uzvcom.graphBulderFunc(Epsilon,'ПС');

    counter:=0;
    counter2:=0;
    //смотрим все вершины
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
             if listHeadDevConnect(ourGraph.listVertex[i].deviceEnt,listCableLaying,ourGraph.nameSuperLine) then
             begin
               inc(counter);
               for m:=0 to listCableLaying.size-1 do begin
                 //HistoryOutStr(' chto idet = ' + listCableLaying[m].headName + '***'+ listCableLaying[m].GroupNum+ '***'+ listCableLaying[m].typeSLine);

                 // Проверяем есть ли у устройсва хозяин
                 // pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HeadDevice');
                 //headDevName:=pgdbstring(pvd^.data.Instance)^;
                 headDevName:=listCableLaying[m].headName;
                 numHeadDev:=getNumHeadDevice(ourGraph.listVertex,headDevName,G,i); // если минус значит нету хозяина

                 if numHeadDev >= 0 then
                   begin

                   //**Проверяем существует ли хоть одно главное устройство,
                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
                    numHead := -1;

                    for j:=0 to listHeadDevice.Size-1 do    //проверяем существует ли уже такое же головное устройство
                       if listHeadDevice[j].name = headDevName then begin
                             numHead := j ;
                             //uzvtestdraw.testTempDrawPLCross(ourGraph.listVertex[i].centerPoint,12*epsilon,2);
                       end;
                    if numHead < 0 then        // если в списки устройства есть. Но нашего устройства нет, то добавляем его
                       begin
                             shortNameHead:='nil' ;
                             pvd:=FindVariableInEnt(ourGraph.listVertex[numHeadDev].deviceEnt,'NMO_Suffix');
                             if pvd<>nil then
                                begin
                                   shortNameHead:=pgdbstring(pvd^.data.Instance)^;
                                end;
                             headDeviceInfo:=THeadDeviceInfo.Create;
                             headDeviceInfo.name:=headDevName;
                             headDeviceInfo.num:=numHeadDev;
                             headDeviceInfo.shortName:=shortNameHead;
                             //headDeviceInfo.listGroup:=nil;
                             listHeadDevice.PushBack(headDeviceInfo);
                             numHead:=listHeadDevice.Size-1;
                             headDeviceInfo:=nil;    //насколько я понимаю, после его добавления listHeadDevice
                                                     //никаких действий с ним делать уже ненадо, поэтому обнулим
                                                     //чтоб при попытке доступа был вылет, и ошибку можно было легко локализовать
                       end;
                   //**работа по поиску и заполнению групп к головному устройству
                   //pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HDGroup');
                   //if pvd<>nil then
                   //   begin
                       groupName:=listCableLaying[m].GroupNum;
                       numHeadGroup:=-1;

                       for j:=0 to listHeadDevice[numHead].listGroup.Size-1 do       // ищем среди существующих групп нашу
                          if listHeadDevice[numHead].listGroup[j].name = groupName then
                             numHeadGroup:=j;
                       if  numHeadGroup<0 then                    //если нет то сощздаем новую группу в существующий список групп
                         begin
                           HeadGroupInfo:=THeadGroupInfo.Create;
                           HeadGroupInfo.name:=groupName;
                          // HeadGroupInfo.listDevice:=nil;
                           //HeadGroupInfo.listVertexTerminalBox:=nil;
                           //HeadGroupInfo.listVertexWayGroup:=nil;
                           //HeadGroupInfo.listVertexWayOnlyVertex:=nil;
                           listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                           numHeadGroup:=listHeadDevice[numHead].listGroup.Size-1;
                           HeadGroupInfo:=nil;
                         end;
                       //end;
                       // Знаем номер головного устройства, номер группы, добавлем к группе новое устройство
                       //pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
                       //if pvd<>nil then
                       //  begin
                         deviceInfo:=TdeviceInfo.Create;
                         deviceInfo.num:=i;
                         //deviceInfo.listNumVertexMinWeight:=nil;
                         deviceInfo.tDevice:=ourGraph.listVertex[i].deviceEnt^.Name;
                         listHeadDevice.Mutable[numHead]^.listGroup.Mutable[numHeadGroup]^.listDevice.PushBack(deviceInfo);
                         //end;
                 end;

               //until headDevName='';

               end;
               listCableLaying.Clear;

             end
             else
              begin
                 //ZCMsgCallBackInterface.TextMessage('У устр!!!ойства нет хозяина = ' + ourGraph.listVertex[i].deviceEnt^.Name,TMWOHistoryOut);
 ///****////                uzvtestdraw.testTempDrawPLCross(ourGraph.listVertex[i].centerPoint,12*epsilon,6);
              end;
        end;
      end;

    // ОЦЕНКА СИТУАЦИИ С ГОЛОВНЫМИ УСТРОЙСТВАМИ ИХ ГРУППАМИ И ПОДЧИНЕННЫМИ УСТРОЙТСВАМИ
     //for i:=0 to listHeadDevice.Size-1 do
     // begin
     //    HistoryOutStr(listHeadDevice[i].name + ' = '+ IntToStr(listHeadDevice[i].num));
     //    for j:=0 to listHeadDevice[i].listGroup.Size -1 do
     //       begin
     //         HistoryOutStr(' Group = ' + listHeadDevice[i].listGroup[j].name);
     //         for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
     //           begin
     //             HistoryOutStr(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].num) + '_type' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
     //             //uzvcom.testTempDrawText(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].centerPoint,'ljlkj');
     //             //HistoryOutStr(' cord = ' + FloatToStr(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].centerPoint.x));
     //
     //           end;
     //       end;
     // end;




    // Заполнение в списка у подчиненных устройств минимальная длина в графе, для последующего анализа
    // и прокладки группового кабеля, его длины, как то так
      for i:=0 to listHeadDevice.Size-1 do
      begin
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
              for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
                begin
                  //работа с библиотекой Аграф
                  EdgePath:=TClassList.Create;     //Создаем реберный путь
                  VertexPath:=TClassList.Create;   //Создаем вершиный путь

                  //нужно получить снова номер головного устройства, по имени устройства
                  //оять перебор :( и это еще один костыль
                  //numnum:=getNumHeadDevice(ourGraph.listVertex,listHeadDevice[i].name,G,listHeadDevice[i].listGroup[j].listDevice[k].num);
                  //if numnum >=0 then begin
                  //
                  //// Получение ребер минимального пути в графи из одной точки в другую
                  //T:=G.FindMinWeightPath(G[numnum], G[listHeadDevice[i].listGroup[j].listDevice[k].num], EdgePath);
                  //
                  //// Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                  //G.EdgePathToVertexPath(G[numnum], EdgePath, VertexPath);


                  // Получение ребер минимального пути в графи из одной точки в другую
                  T:=G.FindMinWeightPath(G[listHeadDevice[i].num], G[listHeadDevice[i].listGroup[j].listDevice[k].num], EdgePath);
                  // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                  G.EdgePathToVertexPath(G[listHeadDevice[i].num], EdgePath, VertexPath);

                  //На основе полученых результатов библиотекой Аграф
                  //в носим ополнения в список подключеных устройств, а именно
                  //у каждого устройства прописываем минимальный путь из вершин до головного устройства
                  if VertexPath.Count > 1 then
                    for m:=0 to VertexPath.Count - 1 do  begin
                      tempNumVertexMinWeight.num:=TVertex(VertexPath[m]).Index;
                      listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight.PushBack(tempNumVertexMinWeight);
                    end
                    else begin
                      listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight:=nil;

                      //ZCMsgCallBackInterface.TextMessage(' Нет пути от устройства к головному устройству = ' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice,TMWOHistoryOut);
    /////////////                  //uzvtestdraw.testTempDrawPLCross(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].centerPoint,12*epsilon,4);
                    end;
                    //end;
                    //for tempNumVertexMinWeight in  listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight do
                    //    begin
                    //      //ZCMsgCallBackInterface.TextMessage(' - ' + inttostr(tempNumVertexMinWeight.num));
                    //      ZCMsgCallBackInterface.TextMessage(' - ' + inttostr(tempNumVertexMinWeight.num),TMWOHistoryOut);
                    //    end;
                    //Анализ результата
                    //ZCMsgCallBackInterface.TextMessage(' Путь подключения = ' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                    //for m:=0 to listHeadDevice[i].listGroup[j].listDevice[k].listNumVertexMinWeight.Size - 1 do  begin
                    //   ZCMsgCallBackInterface.TextMessage(' вершина = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].listNumVertexMinWeight[m].num));
                    //end;
                  EdgePath.Free;
                  VertexPath.Free;
                 end;

              //** Анализ полученного списка и на базе него заполнение списка групп (список списком погоняет)
              // Данный список будет содержать все вершины в которых прокладывается трассы для устройств в группе
              // и уже основываясь на том, что будет в этом списке, можно будет получить все остальные данные

              createTreeDeviceinGroup(listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^,ourGraph);

              //ZCMsgCallBackInterface.TextMessage(' +++ ',TMWOHistoryOut);
              //for ttt in  listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listVertexWayGroup do
              //    begin
              //      //ZCMsgCallBackInterface.TextMessage(' - ' + inttostr(tempNumVertexMinWeight.num));
              //      ZCMsgCallBackInterface.TextMessage(' + ' + inttostr(ttt.VIndex1),TMWOHistoryOut);
              //    end;

              ////для наладки работы кода
               //for k:=0 to listHeadDevice[i].listGroup[j].listVertexWayGroup.Size-1 do begin
               //     pCenter:=VertexCenter(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listVertexWayGroup[k].VIndex1].centerPoint,ourGraph.listVertex[listHeadDevice[i].listGroup[j].listVertexWayGroup[k].VIndex2].centerPoint);
               //     uzvcom.testTempDrawText(pCenter,FloatToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].beforeLength));
               //     uzvcom.testTempDrawText(pCenter,FloatToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].afterLength));
               //     uzvcom.testTempDrawText(pCenter,FloatToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].numAfter));
               //     uzvcom.testTempDrawText(pCenter,IntToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].numBefore));
               //end;

           //   ZCMsgCallBackInterface.TextMessage('длина списка графа после создания' + IntToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup.Size));
            end;
      end;

      // Автонумерация исходя из наиболее короткого маршрута ветки устройств,
      // т.е. кабель выходя из головного устройства идет по пути и на разветвлении пойдет сначала в
      // ту сторону общая длина которой короче другой и так проделывается для каждого шлейфа
      // вершина головное устройства всегдо будет первым в списке listVertexWayGroup


     //counterColor:=1;
      for i:=0 to listHeadDevice.Size-1 do
      begin
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
               if listHeadDevice[i].listGroup[j].listVertexWayGroup<> nil then
                 if listHeadDevice[i].listGroup[j].listVertexWayGroup.Size>0 then
                   begin
                   listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listVertexWayOnlyVertex.PushBack(listHeadDevice[i].listGroup[j].listVertexWayGroup[0].VIndex1);
                   getListOnlyVertexWayGroup(listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^,ourGraph);
                   end
                 else
                   begin

                   end;
                 //if counterColor=4 then
                 //     counterColor:=1
                 // else
                 //testTempDrawPolyLineNeed(listHeadDevice[i].listGroup[j].listVertexWayOnlyVertex,ourGraph,2);
                 //inc(counterColor);

                 //for k:=0 to listHeadDevice[i].listGroup[j].listVertexWayOnlyVertex.size-1 do
                 //  begin
                 //
                 //      ZCMsgCallBackInterface.TextMessage('точка' + IntToStr(listHeadDevice[i].listGroup[j].listVertexWayOnlyVertex[k]));
                 //  end;
            end;
      end;

      result:=listHeadDevice;
      //////////////////////////////////////////////////////////////////////////////////////////////////////////



      {*

     GListVert:=GListVertexPoint.Create;
      counterColor:=0;
      for i:=0 to listHeadDevice.Size-1 do
      begin
         ZCMsgCallBackInterface.TextMessage(listHeadDevice[i].name + ' = '+ IntToStr(listHeadDevice[i].num));
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
              ZCMsgCallBackInterface.TextMessage(' Group = ' + listHeadDevice[i].listGroup[j].name);
              for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
                begin
                  if counterColor=7 then
                      counterColor:=1
                  else
                      inc(counterColor);
                  EdgePath:=TClassList.Create;
                  VertexPath:=TClassList.Create;
                  ZCMsgCallBackInterface.TextMessage(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].num) + '_type' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                  T:=G.FindMinWeightPath(G[listHeadDevice[i].num], G[listHeadDevice[i].listGroup[j].listDevice[k].num], EdgePath);
                  ZCMsgCallBackInterface.TextMessage('Minimal Length: '+ FloatToStr(T));
                  G.EdgePathToVertexPath(G[listHeadDevice[i].num], EdgePath, VertexPath);

                  //  ZCMsgCallBackInterface.TextMessage('Vertices: ');
                  GListVert.PushBack(ourGraph.listVertex[listHeadDevice[i].num].centerPoint);
                  for m:=0 to VertexPath.Count - 1 do  begin
                      GListVert.PushBack(ourGraph.listVertex[TVertex(VertexPath[m]).Index].centerPoint);
                  end;
                  uzvcom.testTempDrawPolyLine(GListVert,counterColor);

                  GListVert.Clear;

                  EdgePath.Free;
                  VertexPath.Free;
                end;
            end;
      end;
      ZCMsgCallBackInterface.TextMessage('dfsdfsdfsdfsdfsdfsdsdf: ');
         *}


      {
      T:=G.FindMinWeightPath(G[0], G[6], EdgePath);

      {if T <> 11 then begin
           ZCMsgCallBackInterface.TextMessage('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;  }
      ZCMsgCallBackInterface.TextMessage('Minimal Length: '+ FloatToStr(T));
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      ZCMsgCallBackInterface.TextMessage('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;   }
      //G.Destroy;
      //EdgePath.Free;
      //VertexPath.Free;
//
//       ZCMsgCallBackInterface.TextMessage('dfsdfsdfsdfsdfsdfsdsdf: ');
//
//    for i:=0 to ourGraph.listVertex.Size-1 do
//      begin
//         uzvcom.testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
//      end;
//
//    for i:=0 to ourGraph.listEdge.Size-1 do
//      begin
//         uzvcom.testTempDrawLine(ourGraph.listEdge[i].VPoint1,ourGraph.listEdge[i].VPoint2);
//      end;
//
//      ZCMsgCallBackInterface.TextMessage('В полученном грhfjhfjhfафе вершин = ' + IntToStr(ourGraph.listVertex.Size));
//      ZCMsgCallBackInterface.TextMessage('В полученном графе ребер = ' + IntToStr(ourGraph.listEdge.Size));




      {*
    ZCMsgCallBackInterface.TextMessage('*** Min Weight Path ***');
  //  writeln('*** Min Weight Path ***');
    G:=TGraph.Create;
    G.Features:=[Weighted];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
      G.AddVertices(7);
      G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4,
        5, 6]);
      G.Edges[0].Weight:=5;
      G.Edges[1].Weight:=7;
      G.Edges[2].Weight:=2;
      G.Edges[3].Weight:=12;
      G.Edges[4].Weight:=2;
      G.Edges[5].Weight:=3;
      G.Edges[6].Weight:=2;
      G.Edges[7].Weight:=1;
      G.Edges[8].Weight:=2;
      G.Edges[9].Weight:=4;
      T:=G.FindMinWeightPath(G[0], G[6], EdgePath);

      if T <> 11 then begin
           ZCMsgCallBackInterface.TextMessage('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;
      ZCMsgCallBackInterface.TextMessage('Minimal Length: ');
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      ZCMsgCallBackInterface.TextMessage('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;
      G.Free;
      EdgePath.Free;
      VertexPath.Free;  *}

  end;
    






****************}










//** Поиск номера по имени устройства из списка из списка устройства
    function getNumHeadDevice(listVertex:TListDeviceLine;name:string;G: TGraph;numDev:integer):integer;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
       T: Float;
       EdgePath, VertexPath: TClassList;
    begin
         result:=-1;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      //result:=-1;

                      //работа с библиотекой Аграф
                      EdgePath:=TClassList.Create;     //Создаем реберный путь
                      VertexPath:=TClassList.Create;   //Создаем вершиный путь

                      // Получение ребер минимального пути в графи из одной точки в другую
                      T:=G.FindMinWeightPath(G[i], G[numDev], EdgePath);
                      // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                      G.EdgePathToVertexPath(G[i], EdgePath, VertexPath);

                      if VertexPath.Count > 1 then
                        result:= i;

                      EdgePath.Free;
                      VertexPath.Free;
                   end;
               end;

            end;
         // HistoryOutStr(IntToStr(result));
    end;





function getListMasterDev(listVertexEdge:TGraphBuilder;globalGraph: TGraph):TVectorOfMasterDevice;
  type
      //**список для кабельной прокладки
      PTCableLaying=^TCableLaying;
       TCableLaying=record
           headName:string;
           GroupNum:string;
           typeSLine:string;

      end;
      TVertexofCableLaying=specialize TVector<TCableLaying>;

      TVertexofString=specialize TVector<string>;
  var
  /////////////////////////

  listCableLaying:TVertexofCableLaying; //список кабельной прокладки

  masterDevInfo:TMasterDevice;
  groupInfo:TMasterDevice.TGroupInfo;
  infoSubDev:TMasterDevice.TGroupInfo.TInfoSubDev;
  //deviceInfo:TMasterDevice.TGroupInfo.TDeviceInfo;
  i,j,k,m,counter,tnum: Integer;
  numHead,numHeadGroup,numHeadDev : integer;

  isHeadnum:boolean;
  shortNameHead, headDevName, groupName:string;
  pvd:pvardesk; //для работы со свойствами устройств

    //** Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
    function listCollectConnect(nowDev:PGDBObjDevice;var listCableLaying:TVertexofCableLaying;nameSL:string):boolean;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       polyObj:PGDBObjPolyLine;
       i,counter1,counter2,counter3:integer;
       tempName,nameParam:gdbstring;
       infoLay:TCableLaying;
       listStr1,listStr2,listStr3:TVertexofString;

    begin
         listStr1:=TVertexofString.Create;
         listStr2:=TVertexofString.Create;
         listStr3:=TVertexofString.Create;

         pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_HeadDeviceName');
         if pvd<>nil then
            BEGIN
         tempName:=pgdbstring(pvd^.data.Instance)^;
         repeat
               GetPartOfPath(nameParam,tempName,';');
               listStr1.PushBack(nameParam);
              // HistoryOutStr(' code2 = ' + nameParam);
         until tempName='';

         pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_NGHeadDevice');
                   if pvd<>nil then
            BEGIN
         tempName:=pgdbstring(pvd^.data.Instance)^;
         repeat
               GetPartOfPath(nameParam,tempName,';');
               listStr2.PushBack(nameParam);
         until tempName='';

         pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_SLTypeagen');
              if pvd<>nil then
            BEGIN
         tempName:=pgdbstring(pvd^.data.Instance)^;
         repeat
               GetPartOfPath(nameParam,tempName,';');
               listStr3.PushBack(nameParam);
         until tempName='';

         for i:=0 to listStr1.size-1 do
             begin
             infoLay.headName:=listStr1[i];
             infoLay.GroupNum:=listStr2[i];
             infoLay.typeSLine:=listStr3[i];
             if infoLay.typeSLine = nameSL then
                listCableLaying.PushBack(infoLay);
             end;
            end;
            end;

         end;
         if listCableLaying.size > 0 then
            result:=true
            else
            result:=false;
    end;


  begin
    result:=TVectorOfMasterDevice.Create;
    listCableLaying := TVertexofCableLaying.Create;

    //counter:=0;

    //на базе listVertexEdge заполняем список головных устройств и все что в них входит
    for i:=0 to listVertexEdge.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (listVertexEdge.listVertex[i].deviceEnt<>nil) and (listVertexEdge.listVertex[i].break<>true) then
         begin
             //Получаем список сколько у устройства хозяев
             if listCollectConnect(listVertexEdge.listVertex[i].deviceEnt,listCableLaying,listVertexEdge.nameSuperLine) then
             begin
               //inc(counter);
               for m:=0 to listCableLaying.size-1 do begin

                 headDevName:=listCableLaying[m].headName;
                 //Поиск хозяина внутри графа полученного из listVertexEdge и возврат номера устройства
                 numHeadDev:=getNumHeadDevice(listVertexEdge.listVertex,headDevName,globalGraph,i); // если минус значит нету хозяина

                 if numHeadDev >= 0 then
                   begin
                   //**Проверяем существует ли хоть одно главное устройство с таким именем,
                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
                    numHead := -1;
                    for j:=0 to result.Size-1 do    //проверяем существует ли уже такое же головное устройство
                       if result[j].name = headDevName then begin
                             numHead := j;

                             //ZCMsgCallBackInterface.TextMessage('NAMENUMmaster = '+inttostr(numHead) + 'namemaster = ' + headDevName + ' = ' + result[j].name,TMWOHistoryOut);
                             isHeadnum:=true;
                             //устройства иногда могут использоватся на разных планах и иметь подчиненных
                             //при обработке всех планов одно и тоже устройство может иметь несколько номеров в глобальном графе
                             for tnum in result[j].LIndex do  begin
                                 //ZCMsgCallBackInterface.TextMessage('tnum = '+inttostr(tnum) + 'numHeadDev = ' + headDevName + ' = ' + inttostr(numHeadDev),TMWOHistoryOut);
                                 if tnum = numHeadDev then
                                    isHeadnum:=false;
                                 end;
                             if isHeadnum then
                               result.mutable[j]^.LIndex.PushBack(numHeadDev);
                       end;

                    if numHead < 0 then        // если в списки устройства есть. Но нашего устройства нет, то добавляем его
                       begin
                             masterDevInfo:=TMasterDevice.Create;
                             masterDevInfo.name:=headDevName;
                             masterDevInfo.LIndex.PushBack(numHeadDev);
                             masterDevInfo.shortName:='nil';
                             pvd:=FindVariableInEnt(listVertexEdge.listVertex[numHeadDev].deviceEnt,'NMO_Suffix');
                             if pvd<>nil then
                                   masterDevInfo.shortName:=pgdbstring(pvd^.data.Instance)^;
                             result.PushBack(masterDevInfo);
                             numHead:=result.Size-1;
                             masterDevInfo:=nil;
                       end;

                   //**работа по поиску и заполнению групп к головному устройству
                       groupName:=listCableLaying[m].GroupNum;
                       numHeadGroup:=-1;
                       for j:=0 to result[numHead].LGroup.Size-1 do       // ищем среди существующих групп нашу
                          if result[numHead].LGroup[j].name = groupName then
                             numHeadGroup:=j;
                       if  numHeadGroup<0 then                    //если нет то создаем новую группу в существующий список групп
                         begin
                           groupInfo:=TMasterDevice.TGroupInfo.Create;
                           groupInfo.name:=groupName;
                           infoSubDev.indexMaster:=numHeadDev;
                           infoSubDev.indexSub:=i;
                           infoSubDev.isVertexAdded:=false;
                            //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);

                           groupInfo.LNumSubDevice.PushBack(infoSubDev);
                           //HeadGroupInfo.listVertexTerminalBox:=nil;
                           //HeadGroupInfo.listVertexWayGroup:=nil;
                           //HeadGroupInfo.listVertexWayOnlyVertex:=nil;
                           result.Mutable[numHead]^.LGroup.PushBack(groupInfo);
                           numHeadGroup:=result[numHead].LGroup.Size-1;
                           groupInfo:=nil;
                         end
                       else
                       begin
                           infoSubDev.indexMaster:=numHeadDev;
                           infoSubDev.indexSub:=i;
                           //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);
                           infoSubDev.isVertexAdded:=false;
                           result.mutable[numHead]^.LGroup.mutable[numHeadGroup]^.LNumSubDevice.PushBack(infoSubDev);
                       end;
                   end;

               end;
               listCableLaying.Clear;
            end;
          end;
        end;
  end;

function TSortTreeLengthComparer.Compare (vertex1, vertex2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   result:=0;
   e1:=TAttrSet(vertex1);
   e2:=TAttrSet(vertex2);

       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat64[vGLengthFromEnd]) + ' сравниваем ' + floattostr(e2.AsFloat64[vGLengthFromEnd]),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32[vGLength]) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32
   if e1.AsFloat64[vGLengthFromEnd] <> e2.AsFloat64[vGLengthFromEnd] then
     if e1.AsFloat64[vGLengthFromEnd] > e2.AsFloat64[vGLengthFromEnd] then
        result:=1
     else
        result:=-1;

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
end;


//** Создание деревьев устройств
  procedure getEasyTreeDevice(var listMasterDevice:TVectorOfMasterDevice);
  var
     i,j,k,l:integer;
     VertexPath: TClassList;
     VPath: TClassList;
     infoGTree:TGraph;
     tempVertexGraph:TVertex;
     edgeLen:float;
     edgeWay:string;
     nextvert:boolean;

     // получения вершины в графе на основе вершины из другого графа
     function getLocalVert(gTree:TGraph;vt:tvertex):tVertex;
     var
       i:integer;
     begin
       result:=nil;
        for i:=0 to gTree.VertexCount-1 do
          if gTree.Vertices[i].AsInt32[vGGIndex] = vt.AsInt32[vGGIndex] then
             result:=gTree.Vertices[i];
     end;

  begin
      for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                infoGTree:=TGraph.Create;
                infoGTree.Features:=[Tree];
                infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);
                infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
                infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
                infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);
                infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                //** создаем граф в котором будут только устройства и ответвления
                tempVertexGraph:=nil;

                infoGTree.AddVertex;
                infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=tvertex(VPath[0]).AsInt32[vGGIndex];
                infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tvertex(VPath[0]).AsString[vGInfoVertex];
                infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=tvertex(VPath[0]).AsBool[vGIsDevice];
                tempVertexGraph:=infoGTree.Vertices[infoGTree.VertexCount-1];
                edgeLen:=0;
                edgeWay:='';
                nextvert:=false;
                for l:= 1 to VPath.Count - 1 do
                 begin
                   //**организция изменения родительской вершины tempVertexGraph если обход графа начался после ответвления
                     if nextvert then
                     begin
                        nextvert:=false;
                        tempVertexGraph:=getLocalVert(infoGTree,tvertex(VPath[l]).Parent);
                     end;
                     if (tvertex(VPath[l]).ChildCount < 1) then
                       begin
                         nextvert:=true;
                       end;
                    ///

                   if (tvertex(VPath[l]).ChildCount > 1) or tvertex(VPath[l]).AsBool[vGIsDevice] then begin
                      infoGTree.AddVertex;
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=tvertex(VPath[l]).AsInt32[vGGIndex];
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=tvertex(VPath[l]).AsBool[vGIsDevice];
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tvertex(VPath[l]).AsString[vGInfoVertex];
                      edgeLen+=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];

                      edgeLen:=RoundTo(edgeLen,-1);
                      infoGTree.AddEdge(tempVertexGraph,infoGTree.Vertices[infoGTree.VertexCount-1]);
                      infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=edgeLen;
                      infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='way: '+ edgeWay + '\P L=' + floattostr(edgeLen)+'m';

                      edgeLen:=0;
                      edgeWay:='';
                      tempVertexGraph:=infoGTree.Vertices[infoGTree.VertexCount-1];
                   end
                   else
                   begin
                     edgeWay+='-';
                     edgeWay+=inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]);
                     //edgeWay+='-';

                     edgeLen+=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];
                     edgeLen:=RoundTo(edgeLen,-1);
                   end;

                   //if
                  //    //listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(VPath[l]);
                  //ZCMsgCallBackInterface.TextMessage(' vertex = ' + inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]),TMWOHistoryOut);
                  //ZCMsgCallBackInterface.TextMessage(' vertex childercount = ' + inttostr(tvertex(VPath[l]).ChildCount),TMWOHistoryOut);
                  //ZCMsgCallBackInterface.TextMessage(' edge length = ' + floattostr(listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength]),TMWOHistoryOut);

                  //ZCMsgCallBackInterface.TextMessage(' vertex = ' + inttostr(listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[tvertex(VPath[l]).Index].AsInt32[vGGIndex]),TMWOHistoryOut);
                  //if listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[Tvertex(VertexPath[l]).Index].ChildCount<1 then

                 end;

                //for l:= 0 to infoGTree.VertexCount - 1 do
                // begin
                //    ZCMsgCallBackInterface.TextMessage('вершинffffff - ' + inttostr(infoGTree.Vertices[l].Index),TMWOHistoryOut);
                // end;
                //for l:= 0 to infoGTree.EdgeCount - 1 do
                // begin
                //    ZCMsgCallBackInterface.TextMessage('реброооffffff - ' + inttostr(infoGTree.edges[l].V1.Index)+'---'+inttostr(infoGTree.edges[l].V2.Index),TMWOHistoryOut);
                // end;
                //ZCMsgCallBackInterface.TextMessage('col vertex = ' + inttostr(listMasterDevice[i].LGroup[j].LTreeDev[k].VertexCount),TMWOHistoryOut);
                //ZCMsgCallBackInterface.TextMessage(inttostr(listMasterDevice[i].LGroup[j].LTreeDev[k].Root.Index),TMWOHistoryOut);
               //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);

              // ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              infoGTree.CorrectTree;

              listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LEasyTreeDev.PushBack(infoGTree);
              infoGTree:=nil;
              tempVertexGraph:=nil;
               end;
            end;

      end;
  end;

//  //** Добавляет пункт к ребрам графа длина с начала (от головного устройства)
//  procedure addItemLengthFromBegin(var listMasterDevice:TVectorOfMasterDevice);
//  var
//     i,j,k,l:integer;
//
//     VPath: TClassList;
//
//     edgeLength,edgeLengthParent:float;
//
//
//  begin
//      for i:=0 to listMasterDevice.Size-1 do
//      begin
//         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
//            begin
//              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
//
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.CreateEdgeAttr('lengthfrombegin', AttrFloat32);
//
//                //**получаем обход графа
//                VPath:=TClassList.Create;
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа
//
//
//                for l:= 1 to VPath.Count - 1 do
//                 begin
//
//                     if tvertex(VPath[l]).Parent.Parent = nil then
//                       edgeLengthParent:=0
//                     else
//                       edgeLengthParent:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]).Parent,tvertex(VPath[l]).Parent.Parent).AsFloat32['lengthfrombegin'];
//
//                       edgeLength:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat32[vGLength];
//                       listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat32['lengthfrombegin']:=edgeLength+edgeLengthParent;
////
////                       listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsString[vGInfoEdge]:='ddd = '+floattostr(listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat32['lengthfrombegin']);
//                 end;
//               end;
//            end;
//
//      end;
//  end;

procedure visualGraphConnection(GGraph:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;graphFull,graphEasy:boolean;var fTreeVertex:GDBVertex;var eTreeVertex:GDBVertex);
var
    globalGraph: TGraph;
    //sumWeightPath: Float;
    easyListMasterDevice:TVectorOfMasterDevice;

    i,j,k: Integer;
    //l,m,tnum: Integer;
    //counter,counter2,counterColor:integer; //счетчики

    //listAllTree:tvectorofGraph;
    inVertex:GDBVertex;

  begin
    //визуализация номеров точек на плане для совмещения их с деревом
    if graphFull or graphEasy then
       visualPtNameSL(GGraph,0.8);
    //Построение полного дерева
    if graphFull then begin
         for i:=0 to listMasterDevice.Size-1 do
         begin
           for j:=0 to listMasterDevice[i].LGroup.Size -1 do
              begin
                for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                  visualGraph(GGraph,listMasterDevice[i].LGroup[j].LTreeDev[k],fTreeVertex,1);
                  end;
              end;

         end;
    end;
    //Построение полного урезанного дерева, места поворотов кабелей не показаны
    if graphEasy then begin
      getEasyTreeDevice(listMasterDevice);

         for i:=0 to listMasterDevice.Size-1 do
         begin
           for j:=0 to listMasterDevice[i].LGroup.Size -1 do
              begin
                for k:=0 to listMasterDevice[i].LGroup[j].LEasyTreeDev.Size -1 do begin
                  visualGraph(GGraph,listMasterDevice[i].LGroup[j].LEasyTreeDev[k],eTreeVertex,1);
                  end;
              end;
            end;

    end;



  end;


  //Визуализация построения шлейфов головных устройств с целью визуального изучения того как будут прокладываться кабельные линии
//дабы исключить возмоные программные ошибки
procedure visualMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean;heightText:double;numDevice:boolean);
type
       counterGroupDevice=record
           name:string;
           counter:Integer;
       end;

       TCounterGroupDevice=specialize TVector<counterGroupDevice>;
       TVectorofInteger=specialize TVector<integer>;
var
  globalGraph: TGraph;
  i,j,k,l:integer;

     VPath: TClassList;

     edgeLength,edgeLengthParent:float;


    polyObj:PGDBObjPolyLine;
    //i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    //myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    //myTerminalBox:TListVertexTerminalBox;


    colorNum,numberGDev:integer;
    listCounterGroupDevice:TCounterGroupDevice;
    listInteger:TVectorofInteger;
    needParent:boolean;
    nowDevCounter:counterGroupDevice;

//    добавляем в список новое устройство из метрики и получаем устройство
    function addGetCounterGroupDevice(num:integer):counterGroupDevice ;
    var
    i,counter:integer;
    name:string;
    pvd:pvardesk; //для работы со свойствами устройств
    //devCounter:counterGroupDevice;
    begin
      name:='';
      if isMetricNumeric then
        begin
         pvd:=FindVariableInEnt(listVertexEdge.listVertex[num].deviceEnt,'NMO_BaseName');
         if pvd <> nil then
            name:=pgdbstring(pvd^.data.Instance)^
        end;
     if listCounterGroupDevice.size = 0 then
       begin
          result.name:=name;
          result.counter:=1;
          listCounterGroupDevice.PushBack(result);
       end
     else
       begin
         counter:=-1;
         for i:=0 to listCounterGroupDevice.size-1 do
             if listCounterGroupDevice[i].name = name then
               counter:=i;
         if counter<0 then
           begin
              result.name:=name;
              result.counter:=1;
              listCounterGroupDevice.PushBack(result);
           end
         else
           begin
           inc(listCounterGroupDevice.mutable[counter]^.counter);
           result.name:=listCounterGroupDevice[counter].name;
           result.counter:=listCounterGroupDevice[counter].counter;
         end;
       end;
    end;

    //Визуализация текста его p1-координата, mText-текст, color-цвет, размер
    function visualDrawText(p1:GDBVertex;mText:GDBString;color:integer;heightText:double):TCommandResult;
    var
        ptext:PGDBObjText;
    begin
          ptext := GDBObjText.CreateInstance;
          zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
          ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
          ptext^.Local.P_insert:=p1;  // координата
          ptext^.Template:=mText;     // сам текст
          ptext^.vp.LineWeight:=LnWt100;
          ptext^.vp.Color:=color;
          ptext^.vp.Layer:=uzvtestdraw.getTestLayer(vTempLayerName);
          ptext^.textprop.size:=heightText;
          zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
          result:=cmd_ok;
    end;

    //Визуализация круга его p1-координата, rr-радиус, color-цвет
    function visualDrawCircle(p1:GDBVertex;rr:GDBDouble;color:integer):TCommandResult;
    var
        pcircle:PGDBObjCircle;
    begin
        begin
          pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
          pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

          zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
          pcircle^.vp.LineWeight:=LnWt100;
          pcircle^.vp.Color:=color;
          pcircle^.vp.Layer:=uzvtestdraw.getTestLayer(vTempLayerName);
          zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
        end;
        result:=cmd_ok;
    end;
    function visualDrawPolyLine(listInteger:TVectorofInteger;color:Integer):TCommandResult;
    var
        polyObj:PGDBObjPolyLine;
        i:integer;
    begin
         polyObj:=GDBObjPolyline.CreateInstance;
         zcSetEntPropFromCurrentDrawingProp(polyObj);
         polyObj^.Closed:=false;
         polyObj^.vp.Color:=color;
         polyObj^.vp.LineWeight:=LnWt200;
         polyObj^.vp.Layer:=getTestLayer(vTempLayerName);

         for i:=0 to listInteger.size-1 do
          begin
            polyObj^.VertexArrayInOCS.PushBackData(listVertexEdge.listVertex[listInteger[i]].centerPoint);
          end;

         zcAddEntToCurrentDrawingWithUndo(polyObj);
         result:=cmd_ok;
    end;

begin

    //heightText:=2.5;

      //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;

    colorNum:=1;
     for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
         begin
              if colorNum=6 then
                 colorNum:=1;

              listCounterGroupDevice:=TCounterGroupDevice.Create;

              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
               begin

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                listInteger:=TVectorofInteger.Create;

                needParent:=false;
                for l:= 0 to VPath.Count - 1 do
                 begin

                  if (l <> 0) and tvertex(VPath[l]).AsBool[vGIsDevice] then
                    begin
                       numberGDev:=tvertex(VPath[l]).AsInt32[vGGIndex];
                       if not listVertexEdge.listVertex[numberGDev].break then begin
                         nowDevCounter:= addGetCounterGroupDevice(numberGDev);
                         if numDevice then
                            visualDrawText(listVertexEdge.listVertex[numberGDev].centerPoint,listMasterDevice[i].name+'-'+listMasterDevice[i].LGroup[j].name+'-'+nowDevCounter.name+'-'+inttostr(nowDevCounter.counter),colorNum,heightText);
                         visualDrawCircle(listVertexEdge.listVertex[numberGDev].centerPoint,5,colorNum);
                       end;
                    end;

                   if needParent then  begin
                     listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);
                   end;

                   listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);

                   if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or tvertex(VPath[l]).AsBool[vGIsDevice] then
                     begin
                        visualDrawPolyLine(listInteger,colorNum);
                        listInteger:=TVectorofInteger.Create;

                        needParent:=true;
                        //ZCMsgCallBackInterface.TextMessage('numvertex'+inttostr(tvertex(VPath[l]).AsInt32[vGGIndex])+'  Количство дтей - ' + inttostr(tvertex(VPath[l]).ChildCount),TMWOHistoryOut);
                     end;

                  end;
               end;
              inc(colorNum);
         end;
end;




procedure cabelingMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
type
       counterGroupDevice=record
           name:string;
           counter:Integer;
       end;

       TCounterGroupDevice=specialize TVector<counterGroupDevice>;
       TVectorofInteger=specialize TVector<integer>;
var
  globalGraph: TGraph;
  i,j,k,l,counterSegment:integer;

     VPath: TClassList;

     edgeLength,edgeLengthParent:float;


    polyObj:PGDBObjPolyLine;
    //i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    //myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    //myTerminalBox:TListVertexTerminalBox;

    heightText:double;
    colorNum,numberGDev:integer;
    listCounterGroupDevice:TCounterGroupDevice;
    listInteger:TVectorofInteger;
    needParent:boolean;
    nowDevCounter:counterGroupDevice;


    //Метрирование датчиков
    procedure metricNumeric(dev:PGDBObjDevice);
    var
        pvd:pvardesk;
        name:string;
    begin
        name:='';
        if isMetricNumeric then begin
         pvd:=FindVariableInEnt(dev,'NMO_BaseName');
         if pvd<>nil then
           name:=pgdbstring(pvd^.data.Instance)^;
         end;

         pvd:=FindVariableInEnt(dev,'GC_InGroup_Metric');
           if pvd<>nil then
               pgdbstring(pvd^.data.Instance)^:=name ;
    end;

    procedure drawCableLine(listInteger:TVectorofInteger;numLMaster,numLGroup,counterSegment:Integer);
    var
    cableLine:PGDBObjCable;
    i:integer;
    pvd:pvardesk; //для работы со свойствами устройств
    psu:ptunit;
    pvarext:PTVariablesExtender;

    begin
     cableLine := AllocEnt(GDBCableID);
     cableLine^.init(nil,nil,0);
     zcSetEntPropFromCurrentDrawingProp(cableLine);

     for i:=0 to listInteger.Size-1 do
         cableLine^.VertexArrayInOCS.PushBackData(listVertexEdge.listVertex[listInteger[i]].centerPoint);

     //**добавление кабельных свойств
      pvarext:=cableLine^.GetExtension(typeof(TVariablesExtender)); //подклчаемся к инспектору
      if pvarext<>nil then
      begin
        psu:=units.findunit(SupportPath,@InterfaceTranslate,'cable'); //
        if psu<>nil then
          pvarext^.entityunit.copyfrom(psu);
      end;
      zcSetEntPropFromCurrentDrawingProp(cableLine);
      //***//

      //** Имя мастера устройства
       pvd:=FindVariableInEnt(cableLine,'GC_HeadDevice');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].name;

       pvd:=FindVariableInEnt(cableLine,'GC_HDShortName');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].shortName;

      //** обавляем суффикс
      pvd:=FindVariableInEnt(cableLine,'NMO_Suffix');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;

       pvd:=FindVariableInEnt(cableLine,'CABLE_AutoGen');
              if pvd<>nil then
                    pgdbboolean(pvd^.data.Instance)^:=true;

       pvd:=FindVariableInEnt(cableLine,'GC_HDGroup');
       if pvd<>nil then
       pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;


      pvd:=FindVariableInEnt(cableLine,'NMO_BaseName');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].name + '-';

       pvd:=FindVariableInEnt(cableLine,'CABLE_Segment');
       if pvd<>nil then
          begin
             pgdbinteger(pvd^.data.Instance)^:=counterSegment;
          end;


     zcAddEntToCurrentDrawingWithUndo(cableLine);
     //result:=cmd_ok;
     end;

begin

      //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;



    //colorNum:=1;
     for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
         begin

          for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
            metricNumeric(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt);

           counterSegment:=0;
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
               begin
                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                listInteger:=TVectorofInteger.Create;

                needParent:=false;
                for l:= 0 to VPath.Count - 1 do
                 begin

                   if needParent then
                     listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);

                   listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);

                   if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or tvertex(VPath[l]).AsBool[vGIsDevice] then
                     begin
                        drawCableLine(listInteger,i,j,counterSegment);
                        listInteger:=TVectorofInteger.Create;
                        inc(counterSegment);
                        needParent:=true;
                     end;

                  end;
               end;
              //inc(colorNum);
         end;
end;

  //** Добавляет пункт к вершинам графа длина с Конца (от головного устройства)
  procedure addItemLengthFromEnd(var listMasterDevice:TVectorOfMasterDevice);
  var
     i,j,k,l:integer;

     VPath: TClassList;

     edgeLength,edgeLengthChilds:float;


     // получения вершины в графе на основе вершины из другого графа
     function getLengthChilds(gTree:TGraph;vt:tvertex):float;
     var
       i:integer;
     begin
       result:=0;
       for i:=0 to vt.ChildCount-1 do
         result+=vt.Childs[i].AsFloat64[vGLengthFromEnd];
     end;

  begin
      for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
               begin
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.CreateVertexAttr(vGLengthFromEnd, AttrFloat64);

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                for l:= VPath.Count - 1 downto 1 do
                 begin
                   edgeLengthChilds:=getLengthChilds(listMasterDevice[i].LGroup[j].LTreeDev[k],tvertex(VPath[l]));
                   edgeLength:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];
                   tvertex(VPath[l]).AsFloat64[vGLengthFromEnd]:=edgeLength+edgeLengthChilds;
                 end;
               end;
  end;




  //** Создание деревьев устройств
  procedure addTreeDevice(listVertexEdge:TGraphBuilder;globalGraph:TGraph;var listMasterDevice:TVectorOfMasterDevice);
  //type
    //tempuseVertex:Tvectorofinteger;
  var
     pvd:pvardesk; //для работы со свойствами устройств
     polyObj:PGDBObjPolyLine;
     i,j,k,m,n,counter1,counter2,counter3:integer;
     tIndex,tIndexLocal,tIndexGlobal:integer;
     EdgePath, VertexPath: TClassList;
     infoGTree:TGraph;
     //tempVertexGraph:TVertex;
     //tempName,nameParam:gdbstring;
     //infoLay:TCableLaying;
     //listStr1,listStr2,listStr3:TVertexofString;
     tempString:string;
     sumWeightPath,tempFloat: Float;
     tempLVertex:TvectorOfInteger;
     gg:GDBVertex;

     function isVertexAdded(tempLVertex:tvectorofinteger;index:integer):boolean;
     var
       i:integer;
     begin
       result:=true;
        for i:=0 to tempLVertex.Size-1 do begin
            //ZCMsgCallBackInterface.TextMessage('ищем - ' + inttostr(tempLVertex[i])+' наш - ' + inttostr(index),TMWOHistoryOut);
            if tempLVertex[i]=index then begin
             result:=false;
             //ZCMsgCallBackInterface.TextMessage('совпало: ' + inttostr(tempLVertex[i])+' = ' + inttostr(index),TMWOHistoryOut);
            end;
        end;
     end;


     function getLength(listVertexEdge:TGraphBuilder;pt1,pt2:integer):Float;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge[i].edgeLength;
     end;

     function getLocalIndex(gTree:TGraph;indexGlobal:integer):LongInt;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to gTree.VertexCount-1 do
          if gTree.Vertices[i].AsInt32[vGGIndex] = indexGlobal then
             result:=i;
     end;

    //** Есть ли соединение данного устройства с данным номером головного устройства
    //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
    function isHaveLineMaster(isMaster,isSub:integer):boolean;
    begin
      //ZCMsgCallBackInterface.TextMessage('isMaster : ' + inttostr(isMaster)+' - isSub -  ' + inttostr(isSub),TMWOHistoryOut);

        result:=true; // нет пути между головным устройством и подключаемым
        EdgePath:=TClassList.Create;     //Создаем реберный путь
        VertexPath:=TClassList.Create;   //Создаем вершиный путь
        //Получение ребер минимального пути в графе из одной точки в другую
        sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[isMaster], globalGraph[isSub], EdgePath);
        //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
        globalGraph.EdgePathToVertexPath(globalGraph[isMaster], EdgePath, VertexPath);

        //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
        if VertexPath.Count > 1 then
          result:=false;  //путь есть между головным устройством и подключаемым

    end;

  begin
    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for n:=0 to listMasterDevice[i].LIndex.Size -1 do
              begin

              //ZCMsgCallBackInterface.TextMessage('khfskldhfskdhflksdhflksdhflksdflkshd - ' + inttostr(n),TMWOHistoryOut);

              infoGTree:=TGraph.Create;
              infoGTree.Features:=[Tree];
              //infoGTree.Root;
              infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);
              infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
              infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);
              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);
              //ZCMsgCallBackInterface.TextMessage('yfx Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('yfx Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);


              tempLVertex:=tvectorofinteger.create;
                //listMasterDevice[i].LGroup[j].LNumSubDevice;
              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size-1 do
                begin

                  if isHaveLineMaster(listMasterDevice[i].LIndex[n],listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) then
                     continue;

                  EdgePath:=TClassList.Create;     //Создаем реберный путь
                  VertexPath:=TClassList.Create;   //Создаем вершиный путь
                  //Получение ребер минимального пути в графе из одной точки в другую
                  sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub], EdgePath);
                  //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
                  //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster)+' sub - ' + inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);

                  globalGraph.EdgePathToVertexPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], EdgePath, VertexPath);

                  tIndexLocal:=-1; //промежуточная вершина для создание ребер графа
                  tIndexGlobal:=-1; //промежуточная вершина для построения пути глобального графа

                  //ZCMsgCallBackInterface.TextMessage('количество - ' + inttostr(VertexPath.Count),TMWOHistoryOut);

                  //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
                  if infoGTree.VertexCount <= 0 then begin
                     infoGTree.AddVertex;
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;

                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);

                     infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                     tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);
                  end;

                  if VertexPath.Count > 1 then
                    for m:=VertexPath.Count - 1 downto 0 do begin
                      // Добавляет цифрц ы центре каждого устройства
                      // uzvtestdraw.testTempDrawText(listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].centerPoint,inttostr(TVertex(VertexPath[m]).Index));


                      //ZCMsgCallBackInterface.TextMessage('way - ' + inttostr(TVertex(VertexPath[m]).Index),TMWOHistoryOut);
                      if isVertexAdded(tempLVertex,TVertex(VertexPath[m]).Index) then
                        begin
                            //ZCMsgCallBackInterface.TextMessage('отработка кода ',TMWOHistoryOut);

                            infoGTree.AddVertex;
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=TVertex(VertexPath[m]).Index;

                            if listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt <> nil then
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='dev';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end
                          else
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='nul';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end;
                            //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                            tempLVertex.PushBack(TVertex(VertexPath[m]).Index);

                             if tIndexLocal < 0 then begin
                               tIndexLocal:=infoGTree.VertexCount-1;
                               tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end
                             else
                             begin
                              //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                              infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[infoGTree.VertexCount-1]);

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              //tempFloat:=1*RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //tempFloat:=20;
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgedddddlength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - - - ' + floattostr(tempFloat),TMWOHistoryOut);


                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]:=RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength])+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                              tIndexLocal:=infoGTree.VertexCount-1;
                              tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end;

                         end
                      else begin
                        if tIndexLocal >= 0 then
                           begin
                            tIndex:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index);
                            //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                            //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(tIndex),TMWOHistoryOut);
                            infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[tIndex]);

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                            tIndexLocal:=-1;
                            tIndexGlobal:=-1;
                        end;
                      end;
                    end;

                  EdgePath.Destroy;
                  VertexPath.Destroy;
                end;

              //ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              // Такая проверку нужна, тогда когда бывает что головное устройство на разных планах установлено
              // и может возникнуть ситуация когда на плане разные группы, что вызовит пустой граф
              //что бы не было проблем выполнена данная проверка
              if infoGTree.VertexCount > 0 then begin
              infoGTree.CorrectTree; //Делает дерево корректным, добавляет родителей детей
              listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.PushBack(infoGTree);
              end;

              infoGTree:=nil;
              tempLVertex.Destroy;
            end;
         end;
      end;
  end;

function buildListAllConnectDevice(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;
var

    //EdgePath, VertexPath: TClassList;

    //pvd:pvardesk; //для работы со свойствами устройств

    globalGraph: TGraph;
    //sumWeightPath: Float;
    listMasterDevice:TVectorOfMasterDevice;

    i,j,k: Integer;
    //l,m,tnum: Integer;
    //counter,counter2,counterColor:integer; //счетчики

    //listAllTree:tvectorofGraph;
    gg:GDBVertex;


    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then
                      result:= false;
               end;
    end;

  begin

    //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;

    //**получаем список подключенных устройств к головным устройствам
    listMasterDevice:=getListMasterDev(listVertexEdge,globalGraph);

    //for i:=0 to listMasterDevice.Size-1 do
    //  begin
    //     ZCMsgCallBackInterface.TextMessage('мастер = '+ listMasterDevice[i].name,TMWOHistoryOut);
    //     for j:=0 to listMasterDevice[i].LGroup.Size -1 do
    //        begin
    //          ZCMsgCallBackInterface.TextMessage('колво приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice.size),TMWOHistoryOut);
    //          for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
    //            ZCMsgCallBackInterface.TextMessage('приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);
    //        end;
    //  end;

    //**Переробатываем список устройств подключенный к группам и на основе него создание деревьев усройств
    addTreeDevice(listVertexEdge,globalGraph,listMasterDevice);

    //**Переробатываем большой граф в упрощенный,для удобной визуализации
    //addEasyTreeDevice(globalGraph,listMasterDevice);

    //**Добавляем к вершинам длины кабелей с конца, для правильной сортировки дерева по длине
    addItemLengthFromEnd(listMasterDevice);

    ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***',TMWOHistoryOut);

    //visualGraph(listMasterDevice[0].LGroup[0].LTreeDev[0],gg,1) ;
    //gg:=uzegeometry.CreateVertex(0,0,0);

    //visualAllTreesLMD(listMasterDevice,gg,1);

    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);

                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.SortTree(listMasterDevice[i].LGroup[j].LTreeDev[k].Root,@SortTreeLengthComparer.Compare);

                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
               end;
            end;

      end;

      result:=listMasterDevice;

  end;


//Процедура создания списка ошибок
procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
type
    TListString=specialize TVector<string>;
var
    EdgePath, VertexPath: TClassList;
    G: TGraph;
    headNum : integer;

    counter,counter2,counter3,counterColor:integer; //счетчики
    i,j,k: Integer;
    T: Float;

    headName,GroupNum,typeSLine,nameSL:string;

    listStr1,listStr2,listStr3:TListString;

    ///Получить список  параметров устройства для подключения
    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TListString;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       tempName,nameParam:gdbstring;
    begin
        result:=TListString.Create;
        pvd:=FindVariableInEnt(nowDev,nameType);
         if pvd<>nil then
            BEGIN
             tempName:=pgdbstring(pvd^.data.Instance)^;
             repeat
                   GetPartOfPath(nameParam,tempName,';');
                   result.PushBack(nameParam);
             until tempName='';
            end;

    end;
    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
    var
       pvd:pvardesk; //для работы со свойствами устройств
       //tempName,nameParam:gdbstring;
       errorInfo:TErrorInfo;
       //tempstring:string;
       isNotDev:boolean;
       i:integer;
    begin
       isNotDev:=true;
       for i:=0 to listError.Size-1 do
         begin
           if listError[i].device = nowDev then
             begin
              //tempstring := concat(errorInfo.text,textError);
               listError.Mutable[i]^.text := listError[i].text + textError;
               isNotDev:=false;
             end
         end;
       if isNotDev then
         begin
           //pvd:=FindVariableInEnt(nowDev,nameType);
           errorInfo.device := nowDev;
           errorInfo.name:=nowDev^.Name;
           errorInfo.text:=textError;
           listError.PushBack(errorInfo);
         end;
    end;

    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      result:= false;
                   end;
               end;

            end;
    end;

  begin

            // Подключение созданного граффа к библиотеке Аграф
    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for k:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
    end;

    //смотрим все вершины
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin
                  counter:=0;
                  for j:=0 to listStr1.size-1 do
                   begin
                     headName:=listStr1[j];      //имя хозяина
                     GroupNum:=listStr2[j];      //№ шлейфа
                     typeSLine:=listStr3[j];     //название трассы
                     for nameSL in listSLname do
                         if typeSLine = nameSL then
                           inc(counter);
                   end;
                  if listStr1.size<>counter then
                    addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не правильное имя типа трассы *суперлинии* ');

                  counter:=0;
                  for j:=0 to listStr1.size-1 do
                   begin
                     headName:=listStr1[j];      //имя хозяина
                     GroupNum:=listStr2[j];      //№ шлейфа
                     typeSLine:=listStr3[j];     //название трассы
                     //isHaveDevice
                     if isHaveDevice(ourGraph.listVertex,headName) then
                       addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Одно из имен головного устройства не правильное');
                   end;

                  for j:=0 to listStr1.size-1 do
                  begin
                   headName:=listStr1[j];      //имя хозяина
                   GroupNum:=listStr2[j];      //№ шлейфа
                   typeSLine:=listStr3[j];     //название трассы
                   //for nameSL in listSLname do
                   //  begin
                     if typeSLine = ourGraph.nameSuperLine then
                     begin
                      headNum:=getNumHeadDevice(ourGraph.listVertex,headName,G,i);
                      if headNum >= 0 then begin

                        //работа с библиотекой Аграф
                        EdgePath:=TClassList.Create;     //Создаем реберный путь
                        VertexPath:=TClassList.Create;   //Создаем вершиный путь

                        // Получение ребер минимального пути в графи из одной точки в другую
                        T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
                        // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                        G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);

                         if VertexPath.Count <= 1 then
                          addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');

                        EdgePath.Free;
                        VertexPath.Free;
                       end
                       else
                       begin
                            addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
                           //else
                           //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       end;
                     end;
                 end;

              end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');

        end;
      end;
  end;

//Процедура создания списка ошибок
procedure errorList(allGraph:TListAllGraph;Epsilon:double;var listError:TListError;listSLname,listAllSLname:TGDBlistSLname);
type
    TListString=specialize TVector<string>;
var
    EdgePath, VertexPath: TClassList;
    G: TGraph;
    headNum : integer;

    counter,counter2,counter3,counterColor:integer; //счетчики
    i,j,k: Integer;
    T: Float;

    headName,GroupNum,typeSLine,nameSL:string;

    listStr1,listStr2,listStr3:TListString;

    ourGraph:TGraphBuilder;
    graphBuilderInfo:TListGraphBuilder;
    ///Получить список  параметров устройства для подключения
    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TListString;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       tempName,nameParam:gdbstring;
    begin
        result:=TListString.Create;
        pvd:=FindVariableInEnt(nowDev,nameType);
         if pvd<>nil then
            BEGIN
             tempName:=pgdbstring(pvd^.data.Instance)^;
             repeat
                   GetPartOfPath(nameParam,tempName,';');
                   result.PushBack(nameParam);
             until tempName='';
            end;

    end;
    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
    var
       pvd:pvardesk; //для работы со свойствами устройств
       //tempName,nameParam:gdbstring;
       errorInfo:TErrorInfo;
       //tempstring:string;
       isNotDev:boolean;
       i:integer;
    begin
       isNotDev:=true;
       for i:=0 to listError.Size-1 do
         begin
           if listError[i].device = nowDev then
             begin
              //tempstring := concat(errorInfo.text,textError);
               listError.Mutable[i]^.text := listError[i].text + textError;
               isNotDev:=false;
             end
         end;
       if isNotDev then
         begin
           //pvd:=FindVariableInEnt(nowDev,nameType);
           errorInfo.device := nowDev;
           errorInfo.name:=nowDev^.Name;
           errorInfo.text:=textError;
           listError.PushBack(errorInfo);
         end;
    end;

    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      result:= false;
                   end;
               end;

            end;
    end;
    function getNumHeadDev(listVertex:TListDeviceLine;name:string;G:TGraph;numDev:integer):integer;
       var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
       T: Float;
       EdgePath, VertexPath: TClassList;
    begin
         result:=-2;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      //result:=-1;

                      //работа с библиотекой Аграф
                      EdgePath:=TClassList.Create;     //Создаем реберный путь
                      VertexPath:=TClassList.Create;   //Создаем вершиный путь

                      // Получение ребер минимального пути в графи из одной точки в другую
                      T:=G.FindMinWeightPath(G[i], G[numDev], EdgePath);
                      // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                      G.EdgePathToVertexPath(G[i], EdgePath, VertexPath);

                      if VertexPath.Count > 1 then
                        result:= i;

                      EdgePath.Free;
                      VertexPath.Free;
                   end;
               end;

            end;
    end;

  begin
     //Проверяем параметры заполненость параметров во Всех устройствах//

     ourGraph:=allGraph[0].graph;
     for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin
                  counter:=0;
                  for j:=0 to listStr1.size-1 do
                   begin
                     headName:=listStr1[j];      //имя хозяина
                     GroupNum:=listStr2[j];      //№ шлейфа
                     typeSLine:=listStr3[j];     //название трассы
                     for nameSL in listAllSLname do
                         if typeSLine = nameSL then
                           inc(counter);
                   end;
                  if listStr1.size<>counter then
                    addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не правильное имя типа трассы *суперлинии* ');

                 end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');
        end;
      end;

    //** Проверяем подключены устройства к головному устройствам, возможность проложить трассу
    for graphBuilderInfo in allGraph do
     begin
        ourGraph:=graphBuilderInfo.graph;
        // Подключение созданного граффа к библиотеке Аграф
    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for k:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
    end;

    //смотрим все вершины
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin
                  for j:=0 to listStr1.size-1 do
                  begin
                   headName:=listStr1[j];      //имя хозяина
                   GroupNum:=listStr2[j];      //№ шлейфа
                   typeSLine:=listStr3[j];     //название трассы
                   //for nameSL in listSLname do
                   //  begin

                     if isHaveDevice(ourGraph.listVertex,headName) then begin
                       addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Одно из имен головного устройства не правильное');
                       continue;
                     end;


                     if typeSLine = ourGraph.nameSuperLine then
                     begin

                      headNum:=getNumHeadDev(ourGraph.listVertex,headName,G,i);
                      //ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***' + inttostr(headNum),TMWOHistoryOut);
                      //ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***' + inttostr(headNum),TMWOHistoryOut);

                      if headNum < 0 then begin
                         addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       // //работа с библиотекой Аграф
                       // EdgePath:=TClassList.Create;     //Создаем реберный путь
                       // VertexPath:=TClassList.Create;   //Создаем вершиный путь
                       //
                       // // Получение ребер минимального пути в графи из одной точки в другую
                       // T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
                       // // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                       // G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);
                       //
                       //  if VertexPath.Count <= 1 then
                       //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       //
                       // EdgePath.Free;
                       // VertexPath.Free;
                       end;
                       ////else
                       ////begin
                       ////     addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
                       ////    //else
                       ////    //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       ////end;
                     end;
                 end;

              end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');

        end;
      end;
     end;
  end;

{*******

procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError);
type
    //**список для кабельной прокладки
    PTCableLaying=^TCableLaying;
     TCableLaying=record
         headName:string;
         GroupNum:string;
         typeSLine:string;

    end;
    TVertexofCableLaying=specialize TVector<TCableLaying>;
    TVertexofString=specialize TVector<string>;
var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    T: Float;

    headNum : integer;

    //counter,counter2,counter3,counterColor:integer; //счетчики
    i,j,k: Integer;


    headName,GroupNum,typeSLine:string;

    listStr1,listStr2,listStr3:TVertexofString;

    ///Получить список  параметров устройства для подключения
    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TVertexofString;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       tempName,nameParam:gdbstring;
    begin
        result:=TVertexofString.Create;
        pvd:=FindVariableInEnt(nowDev,nameType);
         if pvd<>nil then
            BEGIN
             tempName:=pgdbstring(pvd^.data.Instance)^;
             repeat
                   GetPartOfPath(nameParam,tempName,';');
                   result.PushBack(nameParam);
             until tempName='';
            end;

    end;
    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
    var
       pvd:pvardesk; //для работы со свойствами устройств
       //tempName,nameParam:gdbstring;
       errorInfo:TErrorInfo;
       //tempstring:string;
       isNotDev:boolean;
       i:integer;
    begin
       isNotDev:=true;
       for i:=0 to listError.Size-1 do
         begin
           if listError[i].device = nowDev then
             begin
              //tempstring := concat(errorInfo.text,textError);
               listError.Mutable[i]^.text := listError[i].text + textError;
               isNotDev:=false;
             end
         end;
       if isNotDev then
         begin
           //pvd:=FindVariableInEnt(nowDev,nameType);
           errorInfo.device := nowDev;
           errorInfo.name:=nowDev^.Name;
           errorInfo.text:=textError;
           listError.PushBack(errorInfo);
         end;
    end;

    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      result:= false;
                   end;
               end;

            end;
    end;
  begin

       // Подключение созданного граффа к библиотеке Аграф
    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for k:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
    end;

    //смотрим все вершины
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin

                for j:=0 to listStr1.size-1 do
                 begin
                   headName:=listStr1[j];      //имя хозяина
                   GroupNum:=listStr2[j];      //№ шлейфа
                   typeSLine:=listStr3[j];     //название трассы
                     if typeSLine = ourGraph.nameSuperLine then
                     begin
                      headNum:=getNumHeadDevice(ourGraph.listVertex,headName,G,i);
                      if headNum >= 0 then begin

                        //работа с библиотекой Аграф
                        EdgePath:=TClassList.Create;     //Создаем реберный путь
                        VertexPath:=TClassList.Create;   //Создаем вершиный путь

                        // Получение ребер минимального пути в графи из одной точки в другую
                        T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
                        // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                        G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);

                         if VertexPath.Count <= 1 then
                          addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');

                        EdgePath.Free;
                        VertexPath.Free;
                       end
                       else
                       begin
                            addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
                       end;
                     end;
                 end;
              end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');
        end;
      end;
  end;
  ****}

  function TestgraphUses_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    I: Integer;
    T: Float;
  begin
    ZCMsgCallBackInterface.TextMessage('*** Min Weight Path ***',TMWOHistoryOut);
  //  writeln('*** Min Weight Path ***');
    G:=TGraph.Create;
    G.Features:=[Weighted];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
    try
      G.AddVertices(7);
      G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4,
        5, 6]);
      G.Edges[0].Weight:=5;
      G.Edges[1].Weight:=7;
      G.Edges[2].Weight:=2;
      G.Edges[3].Weight:=12;
      G.Edges[4].Weight:=2;
      G.Edges[5].Weight:=3;
      G.Edges[6].Weight:=2;
      G.Edges[7].Weight:=1;
      G.Edges[8].Weight:=2;
      G.Edges[9].Weight:=4;
      T:=G.FindMinWeightPath(G[0], G[6], EdgePath);

      if T <> 11 then begin
           ZCMsgCallBackInterface.TextMessage('*** Error! ***',TMWOHistoryOut);
       // write('Error!');
       // readln;
        Exit;
      end;
      ZCMsgCallBackInterface.TextMessage('Minimal Length: ',TMWOHistoryOut);
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      ZCMsgCallBackInterface.TextMessage('Vertices: ',TMWOHistoryOut);
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ',TMWOHistoryOut);
      //writeln;
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;
  function TestTREEUses_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    //I: Integer;
    //T: Float;
    procedure ShowPath(const CorrectPath: array of Integer);
      var
        I: Integer;
      begin
        for I:=0 to VertexPath.Count - 1 do
          if TVertex(VertexPath[I]).Index <> CorrectPath[I] then begin
            ZCMsgCallBackInterface.TextMessage('Error!' + inttostr(TVertex(VertexPath[I]).Index),TMWOHistoryOut);
            //write('Error!');
            //readln;
            //Exit;
          end;
        for I:=0 to VertexPath.Count - 1 do
         ZCMsgCallBackInterface.TextMessage(inttostr(TVertex(VertexPath[I]).Index) + ' ',TMWOHistoryOut);
          //write(TVertex(VertexPath[I]).Index, ' ');
        //writeln;
      end;
  begin

      ZCMsgCallBackInterface.TextMessage('*** tree Path ***',TMWOHistoryOut);
      G:=TGraph.Create;
      VertexPath:=TClassList.Create;
      try
        G.Features:=[Tree];
        G.CreateVertexAttr('t', AttrBool);
        G.Root:=G.AddVertex;
        With G.Root do begin
          With AddChild do begin
            With AddChild do begin
              AddChild.AsBool['t']:=True;
              AddChild;
            end;
            AddChild;
            AddChild.AddChild;
          end;
          AddChild;
        end;
              if G.IsTree then
         ZCMsgCallBackInterface.TextMessage('граф дерево',TMWOHistoryOut)
      else
         ZCMsgCallBackInterface.TextMessage('граф не дерево',TMWOHistoryOut);
        G.CorrectTree;

                    if G.IsTree then
         ZCMsgCallBackInterface.TextMessage('граф дерево',TMWOHistoryOut)
      else
         ZCMsgCallBackInterface.TextMessage('граф не дерево',TMWOHistoryOut) ;

        G.TreeTraversal(G.Root, VertexPath);
        ShowPath([0, 1, 3, 2, 4, 5, 6, 7, 8]);
        //G.ArrangeTree(G.Root, TAttrSet.CompareUser, TAttrSet.CompareUser);
        //G.SortTree(G.Root,@DummyComparer.Compare);
        G.TreeTraversal(G.Root, VertexPath);
        ShowPath([0, 8, 1, 5, 6, 7, 2, 4, 3]);


  ////  writeln('*** Min Weight Path ***');
  //  G:=TGraph.Create;
  //  G.Features:=[Tree];
  //  EdgePath:=TClassList.Create;
  //  VertexPath:=TClassList.Create;
  //  try
  //    G.AddVertices(10);
  //    G.AddEdges([0, 2,  0, 3,  0, 1, 1, 4,  2, 5,  2, 6,  5, 7,  5, 8,
  //      6, 9]);
  //    //G.Edges[0].Weight:=5;
  //    //G.Edges[1].Weight:=7;
  //    //G.Edges[2].Weight:=2;
  //    //G.Edges[3].Weight:=12;
  //    //G.Edges[4].Weight:=2;
  //    //G.Edges[5].Weight:=3;
  //    //G.Edges[6].Weight:=2;
  //    //G.Edges[7].Weight:=1;
  //    //G.Edges[8].Weight:=2;
  //    //G.Edges[9].Weight:=4;
  //    //T:=G.FindMinWeightPath(G[0], G[6], EdgePath);
  //
  //    //if T <> 11 then begin
  //    //     ZCMsgCallBackInterface.TextMessage('*** Error! ***',TMWOHistoryOut);
  //    // // write('Error!');
  //    // // readln;
  //    //  Exit;
  //    //end;
  //    //ZCMsgCallBackInterface.TextMessage('Minimal Length: 'G.,TMWOHistoryOut);
  //    //writeln('Minimal Length: ', T :4:2);
  //    //G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
  //    ZCMsgCallBackInterface.TextMessage('Vertices: ',TMWOHistoryOut);
  //    //write('Vertices: ');
  //    for I:=0 to VertexPath.Count - 1 do
  //      ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ',TMWOHistoryOut);
  //    //writeln;
    finally
      G.Free;
      //EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;


  {*******
  //Визуализация графа
procedure visualGraph(G: TGraph; var startPt:GDBVertex;height:double);
const
  size=5;
  indent=30;

type
    PTInfoVertex=^TInfoVertex;
    TInfoVertex=record
        num,kol,childs:Integer;
        poz:GDBVertex2D;
    end;

    TListVertex=specialize TVector<TInfoVertex>;
var
    //ptext:PGDBObjText;
    //indent,size:double;
    x,y,i,tParent:integer;
    listVertex:TListVertex;
    infoVertex:TInfoVertex;
    pt1,pt2,pt3,ptext:GDBVertex;
    VertexPath: TClassList;

      //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawVertex(pt:GDBVertex;color:integer);
      var
          polyObj:PGDBObjPolyLine;
      begin
           polyObj:=GDBObjPolyline.CreateInstance;
           zcSetEntPropFromCurrentDrawingProp(polyObj);
           polyObj^.Closed:=true;
           polyObj^.vp.Color:=color;
           polyObj^.vp.LineWeight:=LnWt050;
           //polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x-size)*height,(pt.y+size)*height,0));
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x+size)*height,(pt.y+size)*height,0));
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x+size)*height,(pt.y-size)*height,0));
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x-size)*height,(pt.y-size)*height,0));
           zcAddEntToCurrentDrawingWithUndo(polyObj);
           //result:=cmd_ok;
      end;

      //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawConnectLine(pt1,pt2:GDBVertex;color:integer);
      var
          polyObj:PGDBObjPolyLine;
      begin
           polyObj:=GDBObjPolyline.CreateInstance;
           zcSetEntPropFromCurrentDrawingProp(polyObj);
           polyObj^.Closed:=false;
           polyObj^.vp.Color:=color;
           polyObj^.vp.LineWeight:=LnWt050;
           //polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
           polyObj^.VertexArrayInOCS.PushBackData(pt1);
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt1.x,pt2.y,0));
           polyObj^.VertexArrayInOCS.PushBackData(pt2);
           zcAddEntToCurrentDrawingWithUndo(polyObj);
      end;
      //Визуализация текста
      procedure drawText(pt:GDBVertex;mText:GDBString;color:integer);
      var
          ptext:PGDBObjText;
      begin
          ptext := GDBObjText.CreateInstance;
          zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
          ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
          ptext^.Local.P_insert:=pt;  // координата
          ptext^.textprop.justify:=jsmc;
          ptext^.Template:=mText;     // сам текст
          ptext^.vp.LineWeight:=LnWt100;
          ptext^.vp.Color:=color;
          //ptext^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
          ptext^.textprop.size:=height*2.5;
          zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
          //result:=cmd_ok;
      end;

      ////
      //Визуализация многострочный текст
      procedure drawMText(pt:GDBVertex;mText:GDBString;color:integer;rotate:double);
      var
          pmtext:PGDBObjMText;
      begin
          pmtext := GDBObjMText.CreateInstance;
          zcSetEntPropFromCurrentDrawingProp(pmtext); //добавляем дефаултные свойства
          pmtext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют


          pmtext^.Local.P_insert:=pt;  // координата
          pmtext^.textprop.justify:=jsml;
          //ptext^.Template:=mText;     // сам текст
          pmtext^.Template:=mText;
          pmtext^.Content:=mText;
          pmtext^.vp.LineWeight:=LnWt100;
          pmtext^.linespacef:=1;
          //pmtext^.textprop.aaaangle:=rotate;
          rotate:=(rotate*pi)/180;
          pmtext^.Local.basis.ox.x:=cos(rotate);
          pmtext^.Local.basis.ox.y:=sin(rotate);

          //pmtext^.vp.LineTypeScale:=1;
          pmtext^.vp.Color:=color;
          ////ptext^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
          pmtext^.textprop.size:=height*2.5;
          zcAddEntToCurrentDrawingWithUndo(pmtext);   //добавляем в чертеж
          ////result:=cmd_ok;
      end;

      ////


      function howParent(ch:integer):integer;
      var
          c:integer;
      begin
          result:=-1;

          for c:=0 to listVertex.Size-1 do
                if ch = listVertex[c].num then
                   result:=c;
      end;


begin
      x:=0;
      y:=0;

      VertexPath:=TClassList.Create;
      listVertex:=TListVertex.Create;


      infoVertex.num:=G.Root.Index;
      infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
      infoVertex.kol:=0;
      infoVertex.childs:=G.Root.ChildCount;
      listVertex.PushBack(infoVertex);
      pt1:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0) ;
      drawVertex(pt1,3);
      //drawText(pt1,inttostr(G.Root.index),4);
      //ptext:=uzegeometry.CreateVertex(pt1.x,pt1.y + indent/10,0) ;
      //pt1.y+=indent/10;
      drawMText(pt1,G.Root.AsString[vGInfoVertex],4,0);

      G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
      for i:=1 to VertexPath.Count - 1 do begin
          tParent:=howParent(TVertex(VertexPath[i]).Parent.Index);
          if tParent>=0 then
          begin
            inc(listVertex.Mutable[tparent]^.kol);
            if listVertex[tparent].kol = 1 then
               infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1)
            else  begin
              inc(x);
              infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
            end;

            infoVertex.num:=TVertex(VertexPath[i]).Index;
            infoVertex.kol:=0;
            infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
            listVertex.PushBack(infoVertex);


          pt1:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
          drawVertex(pt1,3);
          //drawText(pt1,inttostr(listVertex.Back.num),4);

          drawMText(pt1,G.Vertices[listVertex.Back.num].AsString[vGInfoVertex],4,0);
          pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0) ;
          ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0) ;
          drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsString[vGInfoEdge],4,90);

          if listVertex[tparent].kol = 1 then begin
          pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
          pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
          pt2.z:=0;
          end
          else begin
          pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
          pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
          pt2.z:=0;
          end;
          pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
          pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
          pt1.z:=0;
          //pt2:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent,0) ;
          drawConnectLine(pt1,pt2,4);

          end;
       end;
      startPt.x:=(infoVertex.poz.x+1)*indent;
      startPt.y:=0;

end;

  function TestTREEUses_com2(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    i: Integer;
    gg:GDBVertex;
    //user:TCompareEvent;
  begin

      ZCMsgCallBackInterface.TextMessage('*** tree Path ***',TMWOHistoryOut);
    G:=TGraph.Create;
    G.Features:=[Tree];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
    try
      G.CreateVertexAttr('tt', AttrFloat32);
      G.CreateEdgeAttr(vGLength, AttrFloat32);

      //G.AddVertices(14);
      //G.Vertices[0].AsFloat32['tt']:=10;
      //G.Vertices[1].AsFloat32['tt']:=20;
      //G.Vertices[2].AsFloat32['tt']:=30;
      //G.Vertices[3].AsFloat32['tt']:=40;
      //G.Vertices[4].AsFloat32['tt']:=50;
      //G.Vertices[5].AsFloat32['tt']:=60;
      //G.Vertices[6].AsFloat32['tt']:=70;
      //G.Vertices[7].AsFloat32['tt']:=80;
      //G.Vertices[8].AsFloat32['tt']:=90;
      //G.Vertices[9].AsFloat32['tt']:=100;
      //G.Vertices[10].AsFloat32['tt']:=110;
      //G.Vertices[11].AsFloat32['tt']:=120;
      //G.Vertices[12].AsFloat32['tt']:=130;
      //G.Vertices[13].AsFloat32['tt']:=140;

      //G.AddEdgeI(2,1);
      //G.Edges[0].AsFloat32[vGLength]:=10;
      //G.AddEdgeI(2,3);
      //G.Edges[1].AsFloat32[vGLength]:=2;
      //G.AddEdgeI(2,4);
      //G.Edges[2].AsFloat32[vGLength]:=15;
      //G.AddEdgeI(4,11);
      //G.Edges[3].AsFloat32[vGLength]:=3;
      //G.AddEdgeI(4,12);
      //G.Edges[4].AsFloat32[vGLength]:=8;
      //{G.AddEdgeI(2,3);
      //G.Edges[5].AsFloat32[vGLength]:=2;}
      //G.AddEdgeI(3,0);
      //G.Edges[5].AsFloat32[vGLength]:=7;
      //G.AddEdgeI(1,6);
      //G.Edges[6].AsFloat32[vGLength]:=61;
      //G.AddEdgeI(1,5);
      //G.Edges[7].AsFloat32[vGLength]:=7;
      //G.AddEdgeI(5,7);
      //G.Edges[8].AsFloat32[vGLength]:=17;
      //G.AddEdgeI(7,8);
      //G.Edges[9].AsFloat32[vGLength]:=14;
      //G.AddEdgeI(7,9);
      //G.Edges[10].AsFloat32[vGLength]:=80;
      //G.AddEdgeI(2,13);
      //G.Edges[11].AsFloat32[vGLength]:=81;


      G.AddVertices(10);
      G.Vertices[0].AsFloat32['tt']:=0;
      G.Vertices[1].AsFloat32['tt']:=1;
      G.Vertices[2].AsFloat32['tt']:=2;
      G.Vertices[3].AsFloat32['tt']:=3;
      G.Vertices[4].AsFloat32['tt']:=4;
      G.Vertices[5].AsFloat32['tt']:=5;
      G.Vertices[6].AsFloat32['tt']:=6;
      G.Vertices[7].AsFloat32['tt']:=7;
      G.Vertices[8].AsFloat32['tt']:=8;
      G.Vertices[9].AsFloat32['tt']:=9;

      //G.Vertices[0].set:=0;
      //G.Vertices[1].AsFloat32['tt']:=1;
      //G.Vertices[2].AsFloat32['tt']:=2;
      //G.Vertices[3].AsFloat32['tt']:=3;
      //G.Vertices[4].AsFloat32['tt']:=4;
      //G.Vertices[5].AsFloat32['tt']:=5;
      //G.Vertices[6].AsFloat32['tt']:=6;
      //G.Vertices[7].AsFloat32['tt']:=7;
      //G.Vertices[8].AsFloat32['tt']:=8;
      //G.Vertices[9].AsFloat32['tt']:=9;
      //
      //G.Vertices[10].AsFloat32['tt']:=110;
      //G.Vertices[11].AsFloat32['tt']:=120;
      //G.Vertices[12].AsFloat32['tt']:=130;
      //G.Vertices[13].AsFloat32['tt']:=140;

      G.AddEdge(G.Vertices[2],G.Vertices[1]);
      G.Edges[0].AsFloat32[vGLength]:=10;
      G.AddEdge(G.Vertices[1],G.Vertices[0]);
      G.Edges[1].AsFloat32[vGLength]:=2;
      G.AddEdge(G.Vertices[1],G.Vertices[4]);
      G.Edges[2].AsFloat32[vGLength]:=15;
      G.AddEdge(G.Vertices[2],G.Vertices[3]);
      G.Edges[3].AsFloat32[vGLength]:=3;
      G.AddEdge(G.Vertices[1],G.Vertices[5]);
      G.Edges[4].AsFloat32[vGLength]:=22;
      G.AddEdge(G.Vertices[1],G.Vertices[6]);
      G.Edges[5].AsFloat32[vGLength]:=11;
      G.AddEdge(G.Vertices[0],G.Vertices[7]);
      G.Edges[6].AsFloat32[vGLength]:=17;
      G.AddEdge(G.Vertices[6],G.Vertices[8]);
      G.Edges[7].AsFloat32[vGLength]:=18;
      G.AddEdge(G.Vertices[6],G.Vertices[9]);
      G.Edges[8].AsFloat32[vGLength]:=1;
      //G.AddEdgeI(4,12);
      //G.Edges[4].AsFloat32[vGLength]:=8;
      //{G.AddEdgeI(2,3);
      //G.Edges[5].AsFloat32[vGLength]:=2;}
      //G.AddEdgeI(3,0);
      //G.Edges[5].AsFloat32[vGLength]:=7;
      //G.AddEdgeI(1,6);
      //G.Edges[6].AsFloat32[vGLength]:=61;
      //G.AddEdgeI(1,5);
      //G.Edges[7].AsFloat32[vGLength]:=7;
      //G.AddEdgeI(5,7);
      //G.Edges[8].AsFloat32[vGLength]:=17;
      //G.AddEdgeI(7,8);
      //G.Edges[9].AsFloat32[vGLength]:=14;
      //G.AddEdgeI(7,9);
      //G.Edges[10].AsFloat32[vGLength]:=80;
      //G.AddEdgeI(2,13);
      //G.Edges[11].AsFloat32[vGLength]:=81;


      G.Root:=G.Vertices[2];

      if G.IsTree then
         ZCMsgCallBackInterface.TextMessage('граф дерево',TMWOHistoryOut)
      else
         ZCMsgCallBackInterface.TextMessage('граф не дерево',TMWOHistoryOut) ;

      G.CorrectTree;

      //for i:=0 to G.VertexCount - 1 do
      //ZCMsgCallBackInterface.TextMessage('*кол потомков для ' + inttostr(i) + ' = ' + inttostr(G.Vertices[i].ChildCount),TMWOHistoryOut);

      {
      ZCMsgCallBackInterface.TextMessage('***',TMWOHistoryOut);

      G.TreeTraversal(G.Root, VertexPath);
      for i:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(inttostr(TVertex(VertexPath[i]).Index) + ' ',TMWOHistoryOut);
      }

      for i:=0 to VertexPath.Count - 1 do begin
        ZCMsgCallBackInterface.TextMessage(inttostr(TVertex(VertexPath[i]).Index) + '+',TMWOHistoryOut);
        //ZCMsgCallBackInterface.TextMessage('tt = ' + floattostr(TVertex(VertexPath[i]).AsFloat32['tt']) + ' ',TMWOHistoryOut);
        end;

      G.TreeTraversal(G.Root, VertexPath);
      gg:=uzegeometry.CreateVertex(0,0,0) ;
      visualGraph(G,gg,1);

      G.SortTree(G.Root,@DummyComparer.Compare);



      ZCMsgCallBackInterface.TextMessage('-кол верш lkz 2-q -' + inttostr(G.BFSFromVertex(G.Root) ),TMWOHistoryOut);

      G.TreeTraversal(G.Root, VertexPath);

      //gg:=uzegeometry.CreateVertex(0,-500,0) ;
      //visualGraph(G,G.Root.index,gg,1);
      //
      G.SetTempToSubtreeSize(G.Root);

      gg:=uzegeometry.CreateVertex(0,-300,0) ;
      visualGraph(G,gg,1);

      for i:=1 to VertexPath.Count - 1 do begin
        ZCMsgCallBackInterface.TextMessage(inttostr(TVertex(VertexPath[i]).Index) + '- батя ' + inttostr(TVertex(VertexPath[i]).Parent.Index),TMWOHistoryOut);

        ZCMsgCallBackInterface.TextMessage('-кол верш-' + inttostr(TVertex(VertexPath[i]).temp.AsPtrInt),TMWOHistoryOut);
        //ZCMsgCallBackInterface.TextMessage('tt = ' + floattostr(TVertex(VertexPath[i]).AsFloat32['tt']) + ' ',TMWOHistoryOut);
        end;
      //end;
      ZCMsgCallBackInterface.TextMessage('All good ',TMWOHistoryOut);
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;     ****}

function TDummyComparer.Compare (Edge1, Edge2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   result:=0;
   e1:=TAttrSet(Edge1);
   e2:=TAttrSet(Edge2);

   ZCMsgCallBackInterface.TextMessage('sssssssssssssss'+e1.ClassName,TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage('xxxxxxssssss'+e1.AsString[vGInfoEdge],TMWOHistoryOut);
       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['tt']) + ' сравниваем ' + floattostr(e2.AsFloat32['tt']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32[vGLength]) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32

   //if e1.ClassName; AsFloat32['lengthfrombegin'] <> nil then
   //  if e1.AsFloat32['lengthfrombegin'] > e2.AsFloat32['lengthfrombegin'] then
   //       result:=1
   //    else
   //       result:=-1;

   {if e1.AsFloat32['tt'] <> e2.AsFloat32['tt'] then
       if e1.AsFloat32['tt'] > e2.AsFloat32['tt'] then
          result:=1
       else
          result:=-1;}

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
end;
function TDummyComparer.CompareEdges (Edge1, Edge2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   ////result:=1;
   //e1:=TAttrSet(Edge1);
   //e2:=TAttrSet(Edge2);
   //
   ZCMsgCallBackInterface.TextMessage('hhhhhhhhhhhhhhhhhhhhhhhttttttttttttttttttttt,,,,hj',TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage('xxxxxxssssss'+e1.AsString[vGInfoEdge],TMWOHistoryOut);
       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['tt']) + ' сравниваем ' + floattostr(e2.AsFloat32['tt']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32[vGLength]) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32

   //if e1.ClassName; AsFloat32['lengthfrombegin'] <> nil then
   //  if e1.AsFloat32['lengthfrombegin'] > e2.AsFloat32['lengthfrombegin'] then
   //       result:=1
   //    else
   //       result:=-1;

   {if e1.AsFloat32['tt'] <> e2.AsFloat32['tt'] then
       if e1.AsFloat32['tt'] > e2.AsFloat32['tt'] then
          result:=1
       else
          result:=-1;}

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
end;


initialization
  //CreateCommandFastObjectPlugin(@NumPsIzvAndDlina_com,'test111',CADWG,0);
  //CreateCommandFastObjectPlugin(@TestTREEUses_com,'test222',CADWG,0);
  //CreateCommandFastObjectPlugin(@TestTREEUses_com2,'test333',CADWG,0);
  DummyComparer:=TDummyComparer.Create;
finalization
  DummyComparer.free;
end.

