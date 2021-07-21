unit sqlcmdcli.Datasource;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Phys.MSSQLDef, FireDAC.Stan.Intf,
  FireDAC.Phys, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.ConsoleUI.Wait, Data.DB,
  FireDAC.Comp.Client;

type
  TDataModule1 = class(TDataModule)
    FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
