unit uzvmanemparams;
interface
uses
  uzctnrVectorStrings;
type
  PTuzvmanemComParams=^TuzvmanemComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель

  //TsettingVizCab=record
  //  sErrors:Boolean;
  //  vizNumMetric:Boolean;
  //  vizFullTreeCab:Boolean; //Визуализировать полное дерево
  //  //vizEasyTreeCab:Boolean; //визуализировать упрощенное дерево
  //end;

  TuzvmanemComParams=record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                        //регистрировать их будем паскалевским RTTI
                                        //не через экспорт исходников и парсинг файла с определениями типов
    NamesList:TEnumData;//это тип для отображения списков в инспекторе
    //nameSL:String;
    accuracy:Double;
    metricDev:Boolean;
    //settingVizCab:TsettingVizCab;

  end;
var
  uzvmanemComParams:TuzvmanemComParams;//определяем экземпляр параметров нашей команды
implementation
end.
