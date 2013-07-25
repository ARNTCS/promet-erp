{*******************************************************************************
Dieser Sourcecode darf nicht ohne gültige Geheimhaltungsvereinbarung benutzt werden
und ohne gültigen Vertriebspartnervertrag weitergegeben werden.
You have no permission to use this Source without valid NDA
and copy it without valid distribution partner agreement
Christian Ulrich
info@cu-tec.de
Created 01.06.2006
*******************************************************************************}
unit uZeosDBDM;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, db, uBaseDBInterface,ZConnection, ZSqlMonitor, ZSqlMetadata,
  ZAbstractRODataset, ZDataset, uBaseDbClasses, LClProc, ZSequence, ZAbstractConnection,
  uModifiedDS;
type

  { TZeosDBDM }
  TUnprotectedDataSet = class(TDataSet);
  TZeosDBDM = class(TBaseDBModule)
    procedure MonitorTrace(Sender: TObject; Event: TZLoggingEvent;
      var LogTrace: Boolean);
  private
    FMainConnection : TZConnection;
    LimitAfterSelect : Boolean;
    LimitSTMT : string;
    FDBTyp : string;
    FProperties : string;
    Monitor : TZSQLMonitor;
    function GetConnection: TComponent;override;
    function DBExists : Boolean;
  protected
    Sequence : TZSequence;
    function GetSyncOffset: Integer;override;
    procedure SetSyncOffset(const AValue: Integer);override;
  public
    constructor Create(AOwner : TComponent);override;
    destructor Destroy;override;
    function SetProperties(aProp : string;Connection : TComponent = nil) : Boolean;override;
    function CreateDBFromProperties(aProp: string): Boolean; override;
    function IsSQLDB : Boolean;override;
    function GetNewDataSet(aTable : TBaseDbDataSet;aConnection : TComponent = nil;MasterData : TDataSet = nil;aTables : string = '') : TDataSet;override;
    function GetNewDataSet(aSQL : string;aConnection : TComponent = nil;MasterData : TDataSet = nil;aOrigtable : TBaseDBDataSet = nil) : TDataSet;override;
    function Ping(aConnection : TComponent) : Boolean;override;
    function DateToFilter(aValue : TDateTime) : string;override;
    function DateTimeToFilter(aValue : TDateTime) : string;override;
    function GetUniID(aConnection : TComponent = nil;Generator : string = 'GEN_SQL_ID';AutoInc : Boolean = True) : Variant;override;
    procedure StreamToBlobField(Stream : TStream;DataSet : TDataSet;Fieldname : string);override;
    procedure BlobFieldToStream(DataSet : TDataSet;Fieldname : string;Stream : TStream);override;
    function GetErrorNum(e: EDatabaseError): Integer; override;
    procedure DeleteExpiredSessions;override;
    function GetNewConnection: TComponent;override;
    procedure Disconnect(aConnection : TComponent);override;
    function StartTransaction(aConnection : TComponent;ForceTransaction : Boolean = False): Boolean;override;
    function CommitTransaction(aConnection : TComponent): Boolean;override;
    function RollbackTransaction(aConnection : TComponent): Boolean;override;
    function TableExists(aTableName : string;aConnection : TComponent = nil;AllowLowercase: Boolean = False) : Boolean;override;
    function TriggerExists(aTriggerName: string; aConnection: TComponent=nil;
       AllowLowercase: Boolean=False): Boolean; override;
    function CreateTrigger(aTriggerName: string; aTableName: string;
      aUpdateOn: string; aSQL: string;aField : string = ''; aConnection: TComponent=nil): Boolean;
      override;
    function DropTable(aTableName : string) : Boolean;override;
    function FieldToSQL(aName : string;aType : TFieldType;aSize : Integer;aRequired : Boolean) : string;
    function GetColumns(TableName : string) : TStrings;override;
  end;

  { TZeosDBDataSet }

  TZeosDBDataSet = class(TZQuery,IBaseDBFilter,IBaseManageDB,IBaseSubDatasets,IBaseModifiedDS)
  private
    FSubDataSets : Tlist;
    FFields : string;
    FFilter,FBaseFilter : string;
    FLimit : Integer;
    FMDS: TDataSource;
    FSortDirection : TSortDirection;
    FSortFields : string;
    FTableNames : string;
    FDefaultTableName : string;
    FManagedFieldDefs : TFieldDefs;
    FManagedIndexDefs : TIndexDefs;
    FOrigTable : TBaseDBDataSet;
    FUsePermissions : Boolean;
    FTableCaption : string;
    FDistinct : Boolean;
    DoCheck: Boolean;
    FUpStdFields : Boolean;
    FUpChangedBy : Boolean;
    FBaseSortFields : string;
    FBaseSorting : string;
    FBaseSortDirection : TSortDirection;
    FUseBaseSorting : Boolean;
    FUseIntegrity : Boolean;
    FSQL : string;
    function BuildSQL : string;
    function IndexExists(IndexName : string) : Boolean;
    procedure WaitForLostConnection;
  protected
    //Internal DataSet Methods that needs to be changed
    procedure InternalOpen; override;
    procedure InternalRefresh; override;
    procedure DoAfterInsert; override;
    procedure DoBeforePost; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforeEdit; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    procedure DoBeforeDelete; override;
    procedure DoAfterDelete; override;
    procedure DoAfterScroll; override;
    procedure DoBeforeCancel; override;
    //IBaseDBFilter
    function GetFields: string;
    function GetBaseFilter: string;
    function GetLimit: Integer;
    function GetSortDirection: TSortDirection;
    function GetSortFields: string;
    function GetLocalSortFields : string;
    function GetBaseSortFields: string;
    function GetSortLocal: Boolean;
    procedure SetFields(const AValue: string);
    function GetFilter: string;
    procedure SetFilter(const AValue: string);
    procedure SetBaseFilter(const AValue: string);
    function GetSQL: string;
    procedure SetSQL(const AValue: string);
    procedure Setlimit(const AValue: Integer);
    procedure SetSortDirection(const AValue: TSortDirection);
    procedure SetSortFields(const AValue: string);
    procedure SetLocalSortFields(const AValue : string);
    procedure SetBaseSortFields(const AValue: string);
    procedure SetSortLocal(const AValue: Boolean);
    function GetFilterTables: string;
    procedure SetFilterTables(const AValue: string);
    function GetUsePermissions: Boolean;
    procedure SetUsePermisions(const AValue: Boolean);
    function GetDistinct: Boolean;
    procedure SetDistinct(const AValue: Boolean);
    function GetBaseSorting: string;
    procedure SetBaseSorting(AValue: string);
    function GetBaseSortDirection: TSortDirection;
    procedure SetBaseSortDirection(AValue: TSortDirection);
    function GetUseBaseSorting: Boolean;
    procedure SetUseBaseSorting(AValue: Boolean);
    //IBaseManageDB
    function GetManagedFieldDefs: TFieldDefs;
    function GetManagedIndexDefs: TIndexDefs;
    function GetTableName: string;
    procedure SetTableName(const AValue: string);
    function CreateTable : Boolean;
    function CheckTable : Boolean;
    function AlterTable : Boolean;
    function GetConnection: TComponent;
    function GetTableCaption: string;
    procedure SetTableCaption(const AValue: string);
    function GetUpStdFields: Boolean;
    procedure SetUpStdFields(AValue: Boolean);
    function GetUpChangedBy: Boolean;
    procedure SetUpChangedBy(AValue: Boolean);
    function GetUseIntegrity: Boolean;
    procedure SetUseIntegrity(AValue: Boolean);
    //IBaseSubDataSets
    function GetSubDataSet(aName : string): TBaseDBDataset;
    procedure RegisterSubDataSet(aDataSet : TBaseDBDataset);
    function GetCount : Integer;
    function GetSubDataSetIdx(aIdx : Integer): TBaseDBDataset;
    //IBaseModifiedDS
    function IsChanged: Boolean;
  public
    constructor Create(AOwner : TComponent);override;
    destructor Destroy;override;
    property MasterDataSource : TDataSource read FMDS write FMDS;
    property DefaultTableName : string read FDefaultTableName;
  end;
implementation
uses ZDbcIntfs,uBaseApplication,uEncrypt;
resourcestring
  strUnknownDbType                = 'Unbekannter Datenbanktyp';
  strDatabaseConnectionLost       = 'Die Datenbankverbindung wurde verlohren !';
function TZeosDBDataSet.BuildSQL : string;
function BuildJoins : string;
var
  aDS : string;
  tmp: String;
begin
  if not (pos(',',FTableNames) > 0) then
    begin
      Result := FTableNames;
      if Result = '' then
        Result := FDefaultTableName;
      Result := TBaseDBModule(Owner).QuoteField(Result);
      exit;
    end;
  tmp := FTableNames+',';
  Result := copy(FTableNames,0,pos(',',FTableNames)-1);
  aDS := Result;
  tmp := copy(tmp,pos(',',tmp)+1,length(tmp));
  while pos(',',tmp) > 0 do
    begin
      Result := Result+ ' inner join '+TBaseDBModule(Owner).QuoteField(copy(tmp,0,pos(',',tmp)-1))+' on '+TBaseDBModule(Owner).QuoteField(copy(tmp,0,pos(',',tmp)-1))+'.REF_ID='+aDS+'.SQL_ID';
      aDS := TBaseDBModule(Owner).QuoteField(copy(tmp,0,pos(',',tmp)-1));
      tmp := copy(tmp,pos(',',tmp)+1,length(tmp));
    end;
end;

var
  aFilter: String;
  aRefField: String;
  tmp: String;
  SResult: String;
  PJ: String = '';
  PW: String = '';

  procedure BuildSResult;
  begin
    SResult := '';
    if pos(',',TZeosDBDM(Owner).QuoteField(FSortFields)) = 0 then
      begin
        sResult += TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField(FSortFields);
        if FSortDirection = sdAscending then
          sResult += ' ASC'
        else if FSortDirection = sdDescending then
          sResult += ' DESC'
        else
          begin
            if FBaseSortDirection = sdAscending then
              sResult += ' ASC'
            else if FBaseSortDirection = sdDescending then
              sResult += ' DESC'
          end;
      end
    else
      begin
        tmp := FSortFields;
        while pos(',',tmp) > 0 do
          begin
            sResult += TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField(copy(tmp,0,pos(',',tmp)-1));
            tmp := copy(tmp,pos(',',tmp)+1,length(tmp));
            if FSortDirection = sdAscending then
              sResult += ' ASC'
            else
              sResult += ' DESC';
            if trim(tmp) > '' then
              sResult+=',';
          end;
        if tmp <> '' then
          begin
            sResult += TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField(tmp);
            if FSortDirection = sdAscending then
              sResult += ' ASC'
            else
              sResult += ' DESC';
          end;
      end;
  end;

begin
  if FSQL <> '' then
    begin
      BuildSResult;
      if (FManagedFieldDefs.IndexOf('AUTO_ID') = -1) and (TZeosDBDM(Owner).UsersFilter <> '') and FUsePermissions then
        begin
          PJ := ' LEFT JOIN '+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+' ON ('+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('REF_ID_ID')+'='+TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField('SQL_ID')+')';
          PW := ' AND ('+aFilter+') AND (('+TZeosDBDM(Owner).UsersFilter+') OR '+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('USER')+' is NULL)';
        end
      else if (FManagedFieldDefs.IndexOf('AUTO_ID') = -1) and FUsePermissions then
        begin
          PJ := ' LEFT JOIN '+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+' ON ('+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('REF_ID_ID')+'='+TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField('SQL_ID')+')';
          PW := ' AND ('+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('USER')+' is NULL)'
        end;
      PW := StringReplace(PW,'AND ()','',[rfReplaceAll]);
      Result := StringReplace(StringReplace(StringReplace(FSQL,'@PERMISSIONJOIN@',PJ,[]),'@PERMISSIONWHERE@',PW,[]),'@DEFAULTORDER@',SResult,[]);
    end
  else if Assigned(FOrigTable) then
    begin
      Result := 'SELECT ';
      if TZeosDBDM(Owner).LimitAfterSelect and ((FLimit > 0)) then
        Result += Format(TZeosDBDM(Owner).LimitSTMT,[FLimit])+' ';
      if FFields = '' then
        Result += '* '
      else
        Result += FFields+' ';
      aFilter := FFilter;
      if (FBaseFilter <> '') and (aFilter <> '') then
        aFilter := '('+fBaseFilter+') and ('+aFilter+')'
      else if (FBaseFilter <> '') then
        aFilter := '('+fBaseFilter+')';
      if Assigned(DataSource) then
        begin
          with Self as IBaseManageDb do
            begin
              if ManagedFieldDefs.IndexOf('AUTO_ID') > -1 then
                aRefField := 'AUTO_ID'
              else
                aRefField := 'SQL_ID';
            end;
          if aFilter <> '' then
            aFilter := '('+aFilter+') and ('+TZeosDBDM(Owner).QuoteField('REF_ID')+'=:'+TZeosDBDM(Owner).QuoteField(aRefField)+')'
          else
            aFilter := TZeosDBDM(Owner).QuoteField('REF_ID')+'=:'+TZeosDBDM(Owner).QuoteField(aRefField);
        end;
      if (FManagedFieldDefs.IndexOf('AUTO_ID') = -1) and (TZeosDBDM(Owner).UsersFilter <> '') and FUsePermissions then
        Result += 'FROM '+BuildJoins+' LEFT JOIN '+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+' ON ('+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('REF_ID_ID')+'='+TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField('SQL_ID')+') WHERE ('+aFilter+') AND (('+TZeosDBDM(Owner).UsersFilter+') OR '+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('USER')+' is NULL)'
      else if (FManagedFieldDefs.IndexOf('AUTO_ID') = -1) and FUsePermissions then
        Result += 'FROM '+BuildJoins+' LEFT JOIN '+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+' ON ('+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('REF_ID_ID')+'='+TZeosDBDM(Owner).QuoteField(FDefaultTableName)+'.'+TZeosDBDM(Owner).QuoteField('SQL_ID')+') WHERE ('+aFilter+') AND ('+TZeosDBDM(Owner).QuoteField('PERMISSIONS')+'.'+TZeosDBDM(Owner).QuoteField('USER')+' is NULL)'
      else
        Result += 'FROM '+BuildJoins+' WHERE ('+aFilter+')';
      Result := StringReplace(Result,' WHERE () AND ','WHERE ',[]);
      Result := StringReplace(Result,' WHERE ()','',[]);
      if (FSortFields <> '') and ((FSortDirection <> sdIgnored) or (FBaseSortDirection <> sdIgnored)) then
        begin
          BuildSResult;
          if FUseBaseSorting then
            Result += ' ORDER BY '+Format(FBaseSorting,[sResult])
          else
            Result += ' ORDER BY '+sResult;
        end;
      if (FLimit > 0) and (not TZeosDBDM(Owner).LimitAfterSelect) then
        Result += ' '+Format(TZeosDBDM(Owner).LimitSTMT,[FLimit]);
    end
  else
    Result := SQL.text;
end;
function TZeosDBDataSet.IndexExists(IndexName: string): Boolean;
var
  Metadata: TZSQLMetadata;
  CustomQuery: TZQuery;
begin
  CustomQuery := TZQuery.Create(nil);
  CustomQuery.Connection := Connection;
  if (copy(TZConnection(TBaseDBModule(Owner).MainConnection).Protocol,0,8) = 'firebird')
  or (copy(TZConnection(TBaseDBModule(Owner).MainConnection).Protocol,0,9) = 'interbase') then
    begin
      CustomQuery.SQL.Text := 'select rdb$index_name from rdb$indices where rdb$index_name='+TZeosDBDM(Owner).QuoteValue(indexname);
      CustomQuery.Open;
      Result := CustomQuery.RecordCount > 0;
      CustomQuery.Close;
    end
  else if (copy(TZConnection(TBaseDBModule(Owner).MainConnection).Protocol,0,6) = 'sqlite') then
    begin
      CustomQuery.SQL.Text := 'select name from SQLITE_MASTER where "TYPE"=''index'' and NAME='+TZeosDBDM(Owner).QuoteValue(indexname);
      CustomQuery.Open;
      Result := CustomQuery.RecordCount > 0;
      CustomQuery.Close;
    end
  else if (copy(TZConnection(TBaseDBModule(Owner).MainConnection).Protocol,0,5) = 'mssql') then
    begin
      CustomQuery.SQL.Text := 'select name from dbo.sysindexes where NAME='+TZeosDBDM(Owner).QuoteValue(indexname);
      CustomQuery.Open;
      Result := CustomQuery.RecordCount > 0;
      CustomQuery.Close;
    end
  else if (copy(TZConnection(TBaseDBModule(Owner).MainConnection).Protocol,0,8) = 'postgres') then
    begin
      CustomQuery.SQL.Text := 'select * from pg_class where relname='+TZeosDBDM(Owner).QuoteValue(indexname);
      CustomQuery.Open;
      Result := CustomQuery.RecordCount > 0;
      CustomQuery.Close;
    end
  else
    begin
      Metadata := TZSQLMetaData.Create(TZConnection(TBaseDBModule(Owner).MainConnection));
      MetaData.Connection := Connection;
      MetaData.MetadataType:=mdIndexInfo;
      Metadata.Catalog:=TZConnection(TBaseDBModule(Owner).MainConnection).Catalog;
      MetaData.Filter:='INDEX_NAME='+TZeosDBDM(Owner).QuoteValue(indexname);
      MetaData.Filtered:=True;
      MetaData.Active:=True;
      Result := MetaData.RecordCount > 0;
      MetaData.Free;
    end;
  CustomQuery.Free;
end;

procedure TZeosDBDataSet.WaitForLostConnection;
var
  aConnThere: Boolean;
begin
  if not TZeosDBDM(Owner).Ping(Connection) then
    begin
      if Assigned(TZeosDBDM(Owner).OnConnectionLost) then
        TZeosDBDM(Owner).OnConnectionLost(TZeosDBDM(Owner));
      aConnThere := False;
      while not aConnThere do
        begin
          if GetCurrentThreadID=MainThreadID then
            begin
              if Assigned(TZeosDBDM(Owner).OnDisconnectKeepAlive) then
                TZeosDBDM(Owner).OnDisconnectKeepAlive(TZeosDBDM(Owner));
            end;
          try
            if TZeosDBDM(Owner).Ping(Connection) then aConnThere := True
            else sleep(200);
          except
            sleep(200);
          end;
        end;
      if Assigned(TZeosDBDM(Owner).OnConnect) then
        TZeosDBDM(Owner).OnConnect(TZeosDBDM(Owner));
    end;
end;

function TZeosDBDataSet.CreateTable : Boolean;
var
  aSQL: String;
  i: Integer;
  bConnection: TZAbstractConnection = nil;
//  bConnection: TZConnection = nil;
  GeneralQuery: TZQuery;
  RestartTransaction: Boolean = False;
begin
  Result := False;
  with TBaseDBModule(Owner) do
    begin
      if Assigned(FOrigTable) and (FFields = '') then
        begin
          if FFields = '' then
            DoCheck := True;
          bConnection := Connection;
          if not TableExists(Self.FDefaultTableName,Connection) then
            begin
              Tables.Clear;
              Result := True;
              aSQL := 'CREATE TABLE '+QuoteField(Uppercase(Self.FDefaultTableName))+' ('+lineending;
              if FManagedFieldDefs.IndexOf('AUTO_ID') = -1 then
                aSQL += TZeosDBDM(Self.Owner).FieldToSQL('SQL_ID',ftLargeInt,0,True)+' PRIMARY KEY,'+lineending
              else
                begin
                  aSQL += TZeosDBDM(Self.Owner).FieldToSQL('AUTO_ID',ftLargeInt,0,True)+' PRIMARY KEY,'+lineending;
                end;
              if Assigned(MasterSource) then
                begin
                  aSQL += TZeosDBDM(Self.Owner).FieldToSQL('REF_ID',ftLargeInt,0,True);
                  if FUseIntegrity then
                    begin
                      with MasterSource.DataSet as IBaseManageDB do
                        begin
                          if ManagedFieldDefs.IndexOf('AUTO_ID') = -1 then
                            aSQL += ' REFERENCES '+QuoteField(TZeosDBDataSet(MasterSource.DataSet).DefaultTableName)+'('+QuoteField('SQL_ID')+') ON DELETE CASCADE'
                          else
                            aSQL += ' REFERENCES '+QuoteField(TZeosDBDataSet(MasterSource.DataSet).DefaultTableName)+'('+QuoteField('AUTO_ID')+') ON DELETE CASCADE';
                        end;
                      if (copy(TZConnection(TBaseDBModule(Self.Owner).MainConnection).Protocol,0,6) = 'sqlite') then
                        aSQL += ' DEFERRABLE INITIALLY DEFERRED';
                    end;
                  aSQL+=','+lineending;
                end;
              for i := 0 to FManagedFieldDefs.Count-1 do
                if FManagedFieldDefs[i].Name <> 'AUTO_ID' then
                  aSQL += TZeosDBDM(Self.Owner).FieldToSQL(FManagedFieldDefs[i].Name,FManagedFieldDefs[i].DataType,FManagedFieldDefs[i].Size,FManagedFieldDefs[i].Required)+','+lineending;
              aSQL += TZeosDBDM(Self.Owner).FieldToSQL('TIMESTAMPD',ftDateTime,0,True)+');';
              try
                try
                  GeneralQuery := TZQuery.Create(Self);
                  GeneralQuery.Connection := bConnection;
                  GeneralQuery.SQL.Text := aSQL;
                  GeneralQuery.ExecSQL;
                  if bConnection.InTransaction then
                    begin
                      TZeosDBDM(Self.Owner).CommitTransaction(bConnection);
                      TZeosDBDM(Self.Owner).StartTransaction(bConnection);
                    end;
                except
                end;
              finally
                GeneralQuery.Destroy;
              end;
            end;
        end;
    end;
  Close;
end;
function TZeosDBDataSet.CheckTable: Boolean;
var
  i: Integer;
begin
  Result := False;
  with TBaseDBModule(Owner) do
    begin
      if DoCheck or (FFields = '') then
        if ShouldCheckTable(Self.FDefaultTableName) then
          begin
            for i := 0 to FManagedFieldDefs.Count-1 do
              if (FieldDefs.IndexOf(FManagedFieldDefs[i].Name) = -1) and (FManagedFieldDefs[i].Name <> 'AUTO_ID') then
                begin
                  Result := True;
                end;
            if Assigned(FManagedIndexDefs) then
              for i := 0 to FManagedIndexDefs.Count-1 do                                           //Primary key
                if (not IndexExists(Uppercase(Self.DefaultTableName+'_'+FManagedIndexDefs.Items[i].Name))) and (FManagedIndexDefs.Items[i].Name <>'SQL_ID') then
                  begin
                    Result := True;
                  end;
          end;
    end;
end;
function TZeosDBDataSet.AlterTable: Boolean;
var
  i: Integer;
  aSQL: String;
  GeneralQuery: TZQuery;
  Changed: Boolean;
  aConnection : TZAbstractConnection;
//  aConnection : TZConnection;
begin
  Result := False;
  with TBaseDBModule(Owner) do
    begin
      for i := 0 to FManagedFieldDefs.Count-1 do
        if (FieldDefs.IndexOf(FManagedFieldDefs[i].Name) = -1) and (FManagedFieldDefs[i].Name <> 'AUTO_ID') then
          begin
            aSQL := 'ALTER TABLE '+QuoteField(FDefaultTableName)+' ADD '+TZeosDBDM(Self.Owner).FieldToSQL(FManagedFieldDefs[i].Name,FManagedFieldDefs[i].DataType,FManagedFieldDefs[i].Size,False)+';';
            aConnection := Connection;
            GeneralQuery := TZQuery.Create(Self);
            GeneralQuery.Connection := aConnection;
            GeneralQuery.SQL.Text := aSQL;
            GeneralQuery.ExecSQL;
            GeneralQuery.Free;
            Changed := True;
          end;
      aSQL := '';
      if Assigned(FManagedIndexDefs) then
        for i := 0 to FManagedIndexDefs.Count-1 do                                           //Primary key
          if (not IndexExists(Uppercase(Self.DefaultTableName+'_'+FManagedIndexDefs.Items[i].Name))) and (FManagedIndexDefs.Items[i].Name <>'SQL_ID') then
            begin
              aSQL := aSQL+'CREATE ';
              if ixUnique in FManagedIndexDefs.Items[i].Options then
                aSQL := aSQL+'UNIQUE ';
              aSQL := aSQL+'INDEX '+QuoteField(Uppercase(Self.DefaultTableName+'_'+FManagedIndexDefs.Items[i].Name))+' ON '+QuoteField(Self.DefaultTableName)+' ('+QuoteField(StringReplace(FManagedIndexDefs.Items[i].Fields,';',QuoteField(','),[rfReplaceAll]))+');'+lineending;
              if aSQL <> '' then
                begin
                  try
                    GeneralQuery := TZQuery.Create(Self);
                    GeneralQuery.Connection := Connection;
                    GeneralQuery.SQL.Text := aSQL;
                    GeneralQuery.ExecSQL;
                  finally
                    GeneralQuery.Free;
                    aSQL := '';
                  end;
                end;
            end;
    end;
end;
procedure TZeosDBDataSet.InternalOpen;
var
  a: Integer;
begin
  if TZeosDBDM(Owner).IgnoreOpenRequests then exit;
  try
    inherited InternalOpen;
  except
    InternalClose;
    if TZeosDBDM(Owner).Ping(Connection) then
      inherited InternalOpen
    else
      begin
        WaitForLostConnection;
        inherited InternalOpen;
      end;
  end;
  if Assigned(FOrigTable) then
    begin
      FOrigTable.SetDisplayLabels(Self);
      if FOrigTable.UpdateFloatFields then
        begin
          DisableControls;
          for a := 0 to Fields.Count -1 do
            begin
              if Fields[a] is TFloatField then
                begin
                  if Fields[a].Name = 'WEIGHT' then
                    begin
                      TFloatField(Fields[a]).DisplayFormat := '#,##0.000##';
                      TFloatField(Fields[a]).EditFormat := '0.000##';
                      TFloatField(Fields[a]).Precision:=5;
                    end
                  else
                    begin
                      TFloatField(Fields[a]).DisplayFormat := '#,##0.00##';
                      TFloatField(Fields[a]).EditFormat := '0.00##';
                      TFloatField(Fields[a]).Precision:=5;
                    end;
                end;
              if Fields[a] is TDateTimeField then
                TDateTimeField(Fields[a]).DisplayFormat := ShortDateFormat+' '+ShortTimeFormat;
            end;
          EnableControls;
        end;
    end;
end;

procedure TZeosDBDataSet.InternalRefresh;
begin
  if TZeosDBDM(Owner).IgnoreOpenRequests then exit;
  try
    inherited InternalRefresh;
  except
    InternalClose;
    if TZeosDBDM(Owner).Ping(Connection) then
      InternalOpen
    else
      begin
        WaitForLostConnection;
        InternalOpen;
      end;
  end;
end;

procedure TZeosDBDataSet.DoAfterInsert;
begin
  inherited DoAfterInsert;
  if Assigned(FOrigTable) then
    begin
      FOrigTable.DisableChanges;
      FOrigTable.FillDefaults(Self);
      FOrigTable.EnableChanges;
    end;
end;
procedure TZeosDBDataSet.DoBeforePost;
begin
  inherited DoBeforePost;
  if (FieldDefs.IndexOf('AUTO_ID') = -1) and (FieldDefs.IndexOf('SQL_ID') > -1) and  FieldByName('SQL_ID').IsNull then
    FieldByName('SQL_ID').AsVariant:=TBaseDBModule(Self.Owner).GetUniID(Connection)
  else if (FieldDefs.IndexOf('SQL_ID') = -1) and (FieldDefs.IndexOf('AUTO_ID') > -1) and FieldByName('AUTO_ID').IsNull and (copy(TZConnection(TBaseDBModule(Self.Owner).MainConnection).Protocol,0,6) <> 'sqlite') then
    FieldByName('AUTO_ID').AsVariant:=TBaseDBModule(Self.Owner).GetUniID(Connection,'GEN_AUTO_ID');
  if FUpStdFields and Assigned(FOrigTable) and (FOrigTable.Changed) then
    begin
      if (FieldDefs.IndexOf('TIMESTAMPD') > -1) then
        FieldByName('TIMESTAMPD').AsDateTime:=Now();
      with BaseApplication as IBaseDBInterface do
        if Data.Users.DataSet.Active then
          begin
            if (FieldDefs.IndexOf('CREATEDBY') > -1) and (FieldByName('CREATEDBY').IsNull) then
              FieldByName('CREATEDBY').AsString:=Data.Users.FieldByName('IDCODE').AsString;
            if FUpChangedBy and (FieldDefs.IndexOf('CHANGEDBY') > -1) then
              FieldByName('CHANGEDBY').AsString:=Data.Users.FieldByName('IDCODE').AsString;
          end;
    end;
  if Assigned(DataSource) and (FieldDefs.IndexOf('REF_ID')>-1) and  Assigned(FieldByName('REF_ID')) and FieldbyName('REF_ID').IsNull then
    begin
      if DataSource.DataSet.FieldDefs.IndexOf('AUTO_ID') > -1 then
        FieldbyName('REF_ID').AsVariant:=DataSource.DataSet.FieldByName('AUTO_ID').AsVariant
      else
        FieldbyName('REF_ID').AsVariant:=DataSource.DataSet.FieldByName('SQL_ID').AsVariant;
    end;
end;
procedure TZeosDBDataSet.DoBeforeInsert;
begin
  if Assigned(DataSource) then
    begin
      if (DataSource.State <> dsInsert) and (DataSource.DataSet.RecordCount = 0) then
        begin
          DataSource.DataSet.Append;
        end;
      if (DataSource.DataSet.State = dsInsert) then
        begin
          DataSource.DataSet.Post;
          DataSource.DataSet.Edit;
        end;
    end;
  inherited DoBeforeInsert;
end;

procedure TZeosDBDataSet.DoBeforeEdit;
begin
  inherited DoBeforeEdit;
end;

procedure TZeosDBDataSet.DoBeforeDelete;
begin
  inherited DoBeforeDelete;
  try
    if Assigned(FOrigTable.OnRemove) then FOrigTable.OnRemove(FOrigTable);
    if GetUpStdFields = True then
      TZeosDBDM(Owner).DeleteItem(FOrigTable);
  except
  end;
end;
procedure TZeosDBDataSet.DoAfterDelete;
begin
  inherited DoAfterDelete;
  if Assigned(FOrigTable) then
    FOrigTable.Change;
end;
procedure TZeosDBDataSet.DoAfterScroll;
begin
  inherited DoAfterScroll;
  if Assigned(ForigTable) then
    FOrigTable.UnChange;
end;

procedure TZeosDBDataSet.DoBeforeCancel;
begin
  inherited DoBeforeCancel;
  if State = dsInsert then
    begin
      if Assigned(FOrigTable.OnRemove) then FOrigTable.OnRemove(FOrigTable);
    end;
end;

function TZeosDBDataSet.GetFields: string;
begin
  Result := FFields;
end;
function TZeosDBDataSet.GetFilter: string;
begin
  Result := FFilter;
end;
function TZeosDBDataSet.GetBaseFilter: string;
begin
  Result := FBaseFilter;
end;
function TZeosDBDataSet.GetLimit: Integer;
begin
  Result := FLimit;
end;
function TZeosDBDataSet.GetSortDirection: TSortDirection;
begin
  Result := FSortDirection;
end;
function TZeosDBDataSet.GetSortFields: string;
begin
  Result := FSortFields;
end;

function TZeosDBDataSet.GetLocalSortFields: string;
begin
  Result := SortedFields;
end;

function TZeosDBDataSet.GetBaseSortFields: string;
begin
  Result := FBaseSortFields;
end;
function TZeosDBDataSet.GetSortLocal: Boolean;
begin
  Result := SortType <> stIgnored;
end;
procedure TZeosDBDataSet.SetFields(const AValue: string);
begin
  FFields := AValue;
  Close;
  SQL.text := BuildSQL;
end;
procedure TZeosDBDataSet.SetFilter(const AValue: string);
begin
  if TZeosDBDM(Owner).CheckForInjection(AValue) then exit;
  FFilter := AValue;
  FSQL := '';
  Close;
  SQL.text := BuildSQL;
end;
procedure TZeosDBDataSet.SetBaseFilter(const AValue: string);
begin
  FBaseFilter := AValue;
  Close;
  SQL.text := BuildSQL;
end;
function TZeosDBDataSet.GetSQL: string;
begin
  Result := FSQL;
end;
procedure TZeosDBDataSet.SetSQL(const AValue: string);
begin
  FSQL := AValue;
  Close;
  SQL.text := BuildSQL;
end;
procedure TZeosDBDataSet.Setlimit(const AValue: Integer);
begin
  FLimit := AValue;
  Close;
  SQL.text := BuildSQL;
end;
procedure TZeosDBDataSet.SetSortDirection(const AValue: TSortDirection);
begin
  FSortDirection := AValue;
  if not GetSortLocal then
    begin
      Close;
      SQL.text := BuildSQL;
    end;
end;
procedure TZeosDBDataSet.SetSortFields(const AValue: string);
begin
  FSortFields := AValue;
end;

procedure TZeosDBDataSet.SetLocalSortFields(const AValue: string);
begin
  SortedFields:=AValue;
end;

procedure TZeosDBDataSet.SetBaseSortFields(const AValue: string);
begin
  FBaseSortFields := AValue;
end;
procedure TZeosDBDataSet.SetSortLocal(const AValue: Boolean);
begin
  if AValue then
    begin
      if FSortDirection = sdAscending then
        SortType := stAscending
      else if FSortDirection = sdDescending then
        SortType := stDescending
      else
        SortType := stIgnored;
    end
  else
    SortType := stIgnored;
end;
function TZeosDBDataSet.GetFilterTables: string;
begin
  Result := FTableNames;
end;
procedure TZeosDBDataSet.SetFilterTables(const AValue: string);
begin
  if AValue = FTableNames then exit;
  FTableNames := AValue;
  Close;
  SQL.text := BuildSQL;
end;
function TZeosDBDataSet.GetUsePermissions: Boolean;
begin
  Result := FUsePermissions;
end;
procedure TZeosDBDataSet.SetUsePermisions(const AValue: Boolean);
begin
  if AValue = FUsePermissions then exit;
  FUsePermissions := AValue;
  Close;
  SQL.text := BuildSQL;
end;
function TZeosDBDataSet.GetDistinct: Boolean;
begin
  Result := FDistinct;
end;
procedure TZeosDBDataSet.SetDistinct(const AValue: Boolean);
begin
  if AValue = FDistinct then exit;
  FDistinct := AValue;
  Close;
  SQL.text := BuildSQL;
end;
function TZeosDBDataSet.GetBaseSorting: string;
begin
  Result := FBaseSorting;
end;
procedure TZeosDBDataSet.SetBaseSorting(AValue: string);
begin
  FBaseSorting := AValue;
end;

function TZeosDBDataSet.GetBaseSortDirection: TSortDirection;
begin
  Result := FBaseSortDirection;
end;
procedure TZeosDBDataSet.SetBaseSortDirection(AValue: TSortDirection);
begin
  FBaseSortDirection := AValue;
end;
function TZeosDBDataSet.GetUseBaseSorting: Boolean;
begin
  Result := FUseBaseSorting;
end;
procedure TZeosDBDataSet.SetUseBaseSorting(AValue: Boolean);
begin
  FUseBaseSorting := AValue;
  SQL.text := BuildSQL;
end;
function TZeosDBDataSet.GetManagedFieldDefs: TFieldDefs;
begin
  Result := FManagedFieldDefs;
end;
function TZeosDBDataSet.GetManagedIndexDefs: TIndexDefs;
begin
  Result := FManagedIndexDefs;
end;
function TZeosDBDataSet.GetTableName: string;
begin
  Result := FDefaultTableName;
end;
procedure TZeosDBDataSet.SetTableName(const AValue: string);
begin
  FDefaultTableName := AValue;
end;
function TZeosDBDataSet.GetConnection: TComponent;
begin
  Result := Connection;
end;
function TZeosDBDataSet.GetTableCaption: string;
begin
  Result := FTableCaption;
end;
procedure TZeosDBDataSet.SetTableCaption(const AValue: string);
begin
  FTableCaption := AValue;
end;
function TZeosDBDataSet.GetUpStdFields: Boolean;
begin
  Result := FUpStdFields;
end;

procedure TZeosDBDataSet.SetUpStdFields(AValue: Boolean);
begin
  FUpStdFields := AValue;
end;

function TZeosDBDataSet.GetUpChangedBy: Boolean;
begin
  Result := FUpChangedBy;
end;

procedure TZeosDBDataSet.SetUpChangedBy(AValue: Boolean);
begin
  FUpChangedBy:=AValue;
end;

function TZeosDBDataSet.GetUseIntegrity: Boolean;
begin
  Result := FUseIntegrity;
end;
procedure TZeosDBDataSet.SetUseIntegrity(AValue: Boolean);
begin
  FUseIntegrity:=AValue;
end;
procedure TZeosDBDataSet.SetFieldData(Field: TField; Buffer: Pointer);
begin
  inherited;
  if Assigned(FOrigTable) then
    FOrigTable.Change;
end;
function TZeosDBDataSet.GetSubDataSet(aName: string): TBaseDBDataset;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FSubDataSets.Count-1 do
    with TBaseDBDataSet(FSubDataSets[i]) as IBaseManageDB do
      if TableName = aName then
        Result := TBaseDBDataSet(FSubDataSets[i]);
end;
procedure TZeosDBDataSet.RegisterSubDataSet(aDataSet: TBaseDBDataset);
begin
  FSubDataSets.Add(aDataSet);
end;
function TZeosDBDataSet.GetCount: Integer;
begin
  Result := FSubDataSets.Count;
end;
function TZeosDBDataSet.GetSubDataSetIdx(aIdx: Integer): TBaseDBDataset;
begin
  Result := nil;
  if aIdx < FSubDataSets.Count then
    Result := TBaseDbDataSet(FSubDataSets[aIdx]);
end;
function TZeosDBDataSet.IsChanged: Boolean;
begin
  Result := Modified;
  if Assigned(FOrigTable) then
    Result := ForigTable.Changed;
end;
constructor TZeosDBDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoCheck := False;
  fBaseSorting := '%s';
  FUseBaseSorting:=False;
  FBaseSortDirection:=sdIgnored;
  FManagedFieldDefs := TFieldDefs.Create(Self);
  FManagedIndexDefs := TIndexDefs.Create(Self);
  FSubDataSets := TList.Create;
  FUsePermissions := False;
  Options:= [doCalcDefaults, doAlwaysDetailResync, doDontSortOnPost, doPreferPrepared, doPreferPreparedResolver];
  FOrigTable := nil;
  SortType := stIgnored;
  FUpStdFields := True;
  FUpChangedBy := True;
end;
destructor TZeosDBDataSet.Destroy;
begin
  //TODO: Free Subdatasets ??
  FManagedFieldDefs.Free;
  FManagedIndexDefs.Free;
  FSubDataSets.Free;
  try
    inherited Destroy;
  except
  end;
end;
procedure TZeosDBDM.MonitorTrace(Sender: TObject; Event: TZLoggingEvent;
  var LogTrace: Boolean);
begin
//  FLastStmt := Event.AsString;
  if Assigned(BaseApplication) then
    with BaseApplication as IBaseApplication do
      Debug(Event.AsString);
end;
function TZeosDBDM.GetConnection: TComponent;
begin
  Result := TComponent(FMainConnection);
end;
function TZeosDBDM.DBExists: Boolean;
begin
  Result := TableExists('USERS') and TableExists('GEN_SQL_ID') and TableExists('GEN_AUTO_ID');
end;
function TZeosDBDM.GetSyncOffset: Integer;
var
  Statement: IZStatement;
  ResultSet: IZResultSet;
  bConnection: TComponent;
begin
  if Assigned(Sequence) then
    begin
      bConnection := MainConnection;
      Sequence.Connection := TZConnection(bConnection);
      Result := Sequence.GetCurrentValue shr 56;
      Sequence.Connection := nil;
    end
  else
    begin
      Statement := TZConnection(MainConnection).DbcConnection.CreateStatement;
      ResultSet := Statement.ExecuteQuery('SELECT "ID" FROM "GEN_SQL_ID"');
      if ResultSet.Next then
        Result := ResultSet.GetLong(1) shr 56
      else Result := 0;
      ResultSet.Close;
      Statement.Close;
    end;
end;
procedure TZeosDBDM.SetSyncOffset(const AValue: Integer);
var
  Statement: IZStatement;
  aVal: Int64;
begin
  aVal := AValue;
  aVal := aVal shl 56;
  if Assigned(Sequence) then
    begin
      raise Exception.Create('Not implemented !!!');
    end
  else
    begin
      Statement := TZConnection(MainConnection).DbcConnection.CreateStatement;
      Statement.Execute('update "GEN_SQL_ID" set "ID"='+IntToStr(aVal));
      Statement.Close;
    end;
end;
constructor TZeosDBDM.Create(AOwner: TComponent);
begin
  FDataSetClass := TZeosDBDataSet;
  FMainConnection := TZConnection.Create(AOwner);
  Monitor := TZSQLMonitor.Create(FMainConnection);
  Monitor.Active:=True;
  Monitor.OnTrace:=@MonitorTrace;
  Sequence := nil;
  inherited Create(AOwner);
end;
destructor TZeosDBDM.Destroy;
begin
  if FMainconnection.Connected then
    FMainConnection.Disconnect;
  if Assigned(Sequence) then
    begin
      Sequence.Connection := nil;
      FreeAndNil(Sequence);
    end;
  Monitor.Free;
  FMainConnection.Free;
  try
    inherited Destroy;
  except
  end;
end;
function TZeosDBDM.SetProperties(aProp: string;Connection : TComponent = nil): Boolean;
var
  tmp: String;
  FConnection : TZConnection;
begin
  inherited;
  if Assigned(BaseApplication) then
    with BaseApplication as IBaseDBInterface do
      LastError := '';
  FProperties := aProp;
  FConnection := TZConnection(Connection);
  if not Assigned(FConnection) then
    begin
      FConnection := FMainConnection;
      if FConnection.Connected then
        FConnection.Disconnect;
    end;
  Result := True;
  tmp := aProp;
  try
    if FConnection.Connected then
      FConnection.Disconnect;
    FConnection.Port:=0;
    FConnection.Properties.Clear;
    FConnection.Properties.Add('timeout=2');
    FConnection.Protocol:='';
    FConnection.User:='';
    FConnection.Password:='';
    FConnection.HostName:='';
    FConnection.Database:='';
    FConnection.Properties.Clear;
    FConnection.Protocol:=copy(tmp,0,pos(';',tmp)-1);
    Assert(FConnection.Protocol<>'',strUnknownDbType);
    tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
    FConnection.HostName := copy(tmp,0,pos(';',tmp)-1);
    if pos(':',FConnection.HostName) > 0 then
      begin
        FConnection.Port:=StrToInt(copy(FConnection.HostName,pos(':',FConnection.HostName)+1,length(FConnection.HostName)));
        FConnection.HostName:=copy(FConnection.HostName,0,pos(':',FConnection.HostName)-1);
      end
    else if pos('/',FConnection.HostName) > 0 then
      begin
        FConnection.Port:=StrToInt(copy(FConnection.HostName,pos('/',FConnection.HostName)+1,length(FConnection.HostName)));
        FConnection.HostName:=copy(FConnection.HostName,0,pos('/',FConnection.HostName)-1);
      end;
    tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
    FConnection.Database:=copy(tmp,0,pos(';',tmp)-1);
    tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
    FConnection.User := copy(tmp,0,pos(';',tmp)-1);
    tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
    if copy(tmp,0,1) = 'x' then
      FConnection.Password := Decrypt(copy(tmp,2,length(tmp)),99998)
    else
      FConnection.Password := tmp;
    if (copy(FConnection.Protocol,0,6) = 'sqlite')
    or (copy(FConnection.Protocol,0,8) = 'postgres')
    then
      begin
        FConnection.TransactIsolationLevel:=tiNone;
        if (copy(FConnection.Protocol,0,6) = 'sqlite') then
          if not FileExists(FConnection.Database) then
            raise Exception.Create('Databasefile dosend exists');
      end
    else if (copy(FConnection.Protocol,0,5) = 'mssql') then
      FConnection.TransactIsolationLevel:=tiReadUnCommitted
    else if (copy(FConnection.Protocol,0,8) = 'firebird')
    or (copy(FConnection.Protocol,0,9) = 'interbase')
    then
      begin
        FConnection.TransactIsolationLevel:=tiReadCommitted;
      end;
    FConnection.Connected:=True;
    LimitAfterSelect := False;
    LimitSTMT := 'LIMIT %d';
    FDBTyp := FConnection.Protocol;
    if FConnection.Protocol = 'sqlite-3' then
      begin
//        FConnection.ExecuteDirect('PRAGMA synchronous = NORMAL;');
//        FConnection.ExecuteDirect('PRAGMA cache_size = 5120;');
//        FConnection.ExecuteDirect('PRAGMA auto_vacuum = FULL;');
        FConnection.ExecuteDirect('PRAGMA recursive_triggers = ON;');
        FConnection.ExecuteDirect('PRAGMA foreign_keys = ON;');
        FConnection.ExecuteDirect('PRAGMA case_sensitive_like = ON;');
      end
    else if (copy(FConnection.Protocol,0,8) = 'firebird')
         or (copy(FConnection.Protocol,0,9) = 'interbase') then
      begin
        FDBTyp := 'firebird';
        LimitSTMT := 'ROWS 1 TO %d';
        if not Assigned(Sequence) then
          begin
            Sequence := TZSequence.Create(Owner);
          end;
      end
    else if FConnection.Protocol = 'mssql' then
      begin
        LimitAfterSelect := True;
        LimitSTMT := 'TOP %d';
      end;
  except on e : Exception do
    begin
      if Assigned(BaseApplication) then
        with BaseApplication as IBaseDBInterface do
          LastError := e.Message;
      Result := False;
    end;
  end;
  if Result then
    begin
      if not DBExists then //Create generators
        begin
          try
            if (copy(FConnection.Protocol,0,8) = 'firebird')
            or (copy(FConnection.Protocol,0,9) = 'interbase') then
              begin
                FConnection.ExecuteDirect('EXECUTE BLOCK AS BEGIN'+lineending
                                         +'if (not exists(select 1 from rdb$generators where rdb$generator_name = ''GEN_SQL_ID'')) then'+lineending
                                         +'execute statement ''CREATE SEQUENCE GEN_SQL_ID;'';'+lineending
                                         +'END;');
                FConnection.ExecuteDirect('EXECUTE BLOCK AS BEGIN'+lineending
                                         +'if (not exists(select 1 from rdb$generators where rdb$generator_name = ''GEN_AUTO_ID'')) then'+lineending
                                         +'execute statement ''CREATE SEQUENCE GEN_AUTO_ID;'';'+lineending
                                         +'END;');
              end
            else if copy(FConnection.Protocol,0,6) = 'sqlite' then
              begin
                FConnection.ExecuteDirect('CREATE TABLE IF NOT EXISTS "GEN_SQL_ID"("SQL_ID" BIGINT NOT NULL PRIMARY KEY,ID BIGINT);');
              end
            else
              begin
                if not TableExists('GEN_SQL_ID') then
                  FConnection.ExecuteDirect('CREATE TABLE "GEN_SQL_ID"("SQL_ID" BIGINT NOT NULL PRIMARY KEY,"ID" BIGINT);');
                if not TableExists('GEN_AUTO_ID') then
                  FConnection.ExecuteDirect('CREATE TABLE "GEN_AUTO_ID"("SQL_ID" BIGINT NOT NULL PRIMARY KEY,"ID" BIGINT);');
              end
          except on e : Exception do
            begin
              if Assigned(BaseApplication) then
                with BaseApplication as IBaseDBInterface do
                  LastError := e.Message;
              Result := False;
            end;
          end;
        end;
    end;
end;
function TZeosDBDM.CreateDBFromProperties(aProp: string): Boolean;
var
  FConnection: TZConnection;
  tmp: String;
  aPassword: String;
  aUser: String;
  aDatabase: String;
begin
  FConnection := TZConnection.Create(nil);
  if Assigned(BaseApplication) then
    with BaseApplication as IBaseDBInterface do
      LastError := '';
  tmp := aProp;
  FConnection.Protocol:=copy(tmp,0,pos(';',tmp)-1);
  Assert(FConnection.Protocol<>'',strUnknownDbType);
  tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
  FConnection.HostName := copy(tmp,0,pos(';',tmp)-1);
  if pos(':',FConnection.HostName) > 0 then
    begin
      FConnection.Port:=StrToInt(copy(FConnection.HostName,pos(':',FConnection.HostName)+1,length(FConnection.HostName)));
      FConnection.HostName:=copy(FConnection.HostName,0,pos(':',FConnection.HostName)-1);
    end
  else if pos('/',FConnection.HostName) > 0 then
    begin
      FConnection.Port:=StrToInt(copy(FConnection.HostName,pos('/',FConnection.HostName)+1,length(FConnection.HostName)));
      FConnection.HostName:=copy(FConnection.HostName,0,pos('/',FConnection.HostName)-1);
    end;
  tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
  aDatabase:=copy(tmp,0,pos(';',tmp)-1);
  tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
  aUser := copy(tmp,0,pos(';',tmp)-1);
  FConnection.User:=aUser;
  tmp := copy(tmp,pos(';',tmp)+1,length(tmp));
  FConnection.Database:=aDatabase;
  if copy(tmp,0,1) = 'x' then
    aPassword := Decrypt(copy(tmp,2,length(tmp)),99998)
  else
    aPassword := tmp;
  FConnection.Password:=aPassword;
  if (copy(FConnection.Protocol,0,8) = 'postgres')
  then
    begin
//      FConnection.Properties.Add('CreateNewDatabase=CREATE DATABASE "'+aDatabase+'" WITH OWNER = "'+aUser+'" ENCODING = ''UTF8'' CONNECTION LIMIT = -1;');
      FConnection.Database:='postgres';
    end
    else if (copy(FConnection.Protocol,0,5) = 'mssql') then
      FConnection.Properties.Add('CreateNewDatabase=CREATE DATABASE "'+aDatabase+'"')
    else if (copy(FConnection.Protocol,0,8) = 'firebird')
    or (copy(FConnection.Protocol,0,9) = 'interbase')
    then
      begin
        if FConnection.HostName <> '' then
          FConnection.Properties.Add('CreateNewDatabase=CREATE DATABASE '''+FConnection.HostName+':'+aDatabase+''' USER '''+aUser+''' PASSWORD '''+aPassword+''' PAGE_SIZE = 4096 DEFAULT CHARACTER SET UTF8')
        else
          FConnection.Properties.Add('CreateNewDatabase=CREATE DATABASE '''+aDatabase+''' USER '''+aUser+''' PASSWORD '''+aPassword+''' PAGE_SIZE = 4096 DEFAULT CHARACTER SET UTF8');
      end;
  try
    FConnection.Connected:=True;
  except
    on e : Exception do
    if Assigned(BaseApplication) then
      with BaseApplication as IBaseDBInterface do
        begin
          LastError := e.Message;
          debugln(LastError);
        end;
  end;
  if (copy(FConnection.Protocol,0,8) = 'postgres')
  then
    begin
      Result := FConnection.ExecuteDirect('CREATE DATABASE "'+aDatabase+'" WITH OWNER = "'+aUser+'" ENCODING = ''UTF8'' CONNECTION LIMIT = -1;');
      FConnection.Disconnect;
      FConnection.Database:=aDatabase;
    end;
  FConnection.Connected:=True;
  Result := FConnection.Connected;
  FConnection.Free;
end;
function TZeosDBDM.IsSQLDB: Boolean;
begin
  Result:=True;
end;
function TZeosDBDM.GetNewDataSet(aTable: TBaseDbDataSet;aConnection: TComponent = nil; MasterData: TDataSet = nil;aTables : string = ''): TDataSet;
begin
  if IgnoreOpenrequests then exit;
  Result := FDataSetClass.Create(Self);
  if not Assigned(aConnection) then
    aConnection := MainConnection;
  with TZeosDBDataSet(Result) do
    begin
      Connection := TZConnection(aConnection);
      FTableNames := aTables;
      aTable.DefineFields(Result);
      aTable.DefineDefaultFields(Result,Assigned(Masterdata));
      FOrigTable := aTable;
      if Assigned(Masterdata) then
        begin
          if not Assigned(TZeosDBDataSet(MasterData).MasterDataSource) then
            begin
              TZeosDBDataSet(MasterData).MasterDataSource := TDataSource.Create(Self);
              TZeosDBDataSet(MasterData).MasterDataSource.DataSet := MasterData;
            end;
          DataSource := TZeosDBDataSet(MasterData).MasterDataSource;
          MasterSource := TZeosDBDataSet(MasterData).MasterDataSource;
          with Masterdata as IBaseSubDataSets do
            RegisterSubDataSet(aTable);
        end;
    end;
end;
function TZeosDBDM.GetNewDataSet(aSQL: string; aConnection: TComponent;
  MasterData : TDataSet = nil;aOrigtable : TBaseDBDataSet = nil): TDataSet;
begin
  Result := FDataSetClass.Create(Self);
  if not Assigned(aConnection) then
    aConnection := MainConnection;
  with TZeosDBDataSet(Result) do
    begin
      FOrigTable := aOrigtable;
      Connection := TZConnection(aConnection);
      SQL.Text := aSQL;
      if Assigned(Masterdata) then
        begin
          if not Assigned(TZeosDBDataSet(MasterData).MasterDataSource) then
            begin
              TZeosDBDataSet(MasterData).MasterDataSource := TDataSource.Create(Self);
              TZeosDBDataSet(MasterData).MasterDataSource.DataSet := MasterData;
            end;
          DataSource := TZeosDBDataSet(MasterData).MasterDataSource;
          MasterSource := TZeosDBDataSet(MasterData).MasterDataSource;
        end;
    end;
end;
function TZeosDBDM.Ping(aConnection: TComponent): Boolean;
var
  atime: Integer;
begin
  Result := True;
  try
    Result := TZConnection(aConnection).Ping;
  except
    Result := False;
  end;
end;
function TZeosDBDM.DateToFilter(aValue: TDateTime): string;
begin
  if FMainConnection.Protocol = 'mssql' then
    Result := QuoteValue(FormatDateTime('YYYYMMDD',aValue))
  else
    Result:=inherited DateToFilter(aValue);
end;
function TZeosDBDM.DateTimeToFilter(aValue: TDateTime): string;
begin
  if FMainConnection.Protocol = 'mssql' then
    Result := QuoteValue(FormatDateTime('YYYYMMDD HH:MM:SS.ZZZZ',aValue))
  else
    Result:=inherited DateTimeToFilter(aValue);
end;
function TZeosDBDM.GetUniID(aConnection : TComponent = nil;Generator : string = 'GEN_SQL_ID';AutoInc : Boolean = True): Variant;
var
  Statement: IZStatement;
  ResultSet: IZResultSet;
  bConnection: TComponent;
begin
  if Assigned(Sequence) then
    begin
      bConnection := MainConnection;
      if Assigned(aConnection) then
        bConnection := aConnection;
      Sequence.SequenceName:=Generator;
      Sequence.Connection := TZConnection(bConnection);
      Result := Sequence.GetNextValue;
      Sequence.Connection := nil;
    end
  else
    begin
      try
        if (copy(FMainConnection.Protocol,0,6) = 'sqlite') and (Assigned(aConnection)) then
          Statement := TZConnection(aConnection).DbcConnection.CreateStatement //we have global locking in sqlite so we must use the actual connection
        else
          Statement := TZConnection(MainConnection).DbcConnection.CreateStatement;
        if AutoInc then
          begin
            if LimitAfterSelect then
              Statement.Execute('update "'+Generator+'" set "ID"=(select '+Format(LimitSTMT,[1])+' "ID" from "'+Generator+'")+1;')
            else
              Statement.Execute('update "'+Generator+'" set "ID"=(select "ID" from "'+Generator+'" '+Format(LimitSTMT,[1])+')+1;');
          end;
        except
        end;
        try
          ResultSet := Statement.ExecuteQuery('SELECT "ID" FROM "'+Generator+'"');
          if ResultSet.Next then
            Result := ResultSet.GetLong(1)
          else
            begin
              Statement.Execute('insert into "'+GENERATOR+'" ("SQL_ID","ID") VALUES (1,1000);');
              Result := 1000;
            end;
          ResultSet.Close;
          Statement.Close;
        except
        end;
    end;
end;
procedure TZeosDBDM.StreamToBlobField(Stream: TStream; DataSet: TDataSet;
  Fieldname: string);
var
  Posted: Boolean;
  GeneralQuery: TZQuery;
begin
  if DataSet.Fielddefs.IndexOf(FieldName) = -1 then
    begin
      if DataSet.State = dsInsert then
        begin
          Posted := True;
          DataSet.Post;
        end;
      GeneralQuery := TZQuery.Create(Self);
      GeneralQuery.Connection := TZQuery(DataSet).Connection;
      GeneralQuery.SQL.Text := 'select * from '+QuoteField(TZeosDBDataSet(DataSet).DefaultTableName)+' where "SQL_ID"='+QuoteValue(DataSet.FieldByName('SQL_ID').AsString)+';';
      GeneralQuery.Open;
      GeneralQuery.Edit;
      TBlobField(GeneralQuery.FieldByName(Fieldname)).LoadFromStream(Stream);
      GeneralQuery.Post;
      GeneralQuery.Free;
      if Posted then DataSet.Edit;
    end
  else inherited;
end;
procedure TZeosDBDM.BlobFieldToStream(DataSet: TDataSet; Fieldname: string;
  Stream: TStream);
var
  GeneralQuery: TZQuery;
  aSQL : string;
begin
  if DataSet.Fielddefs.IndexOf(FieldName) = -1 then
    begin
      GeneralQuery := TZQuery.Create(Self);
      GeneralQuery.Connection := TZQuery(DataSet).Connection;
      aSql := 'select * from '+QuoteField(TZeosDBDataSet(DataSet).DefaultTableName)+' where "SQL_ID"='+QuoteValue(DataSet.FieldByName('SQL_ID').AsString)+';';
      GeneralQuery.SQL.Text := aSql;
      GeneralQuery.Open;
      TBlobField(GeneralQuery.FieldByName(Fieldname)).SaveToStream(Stream);
      GeneralQuery.Free;
    end
  else inherited;
end;

function TZeosDBDM.GetErrorNum(e: EDatabaseError): Integer;
begin
  Result:=inherited GetErrorNum(e);
  if e is EZDatabaseError then
    Result := EZDatabaseError(e).ErrorCode;
end;

procedure TZeosDBDM.DeleteExpiredSessions;
var
  GeneralQuery: TZQuery;
begin
  GeneralQuery := TZQuery.Create(Self);
  GeneralQuery.Connection := FMainConnection;
  GeneralQuery.SQL.Text := 'DELETE FROM '+QuoteField('ACTIVEUSERS')+' WHERE ('+QuoteField('EXPIRES')+' < '+Self.DateTimeToFilter(Now)+');';
  GeneralQuery.ExecSQL;
  GeneralQuery.Free;
end;
function TZeosDBDM.GetNewConnection: TComponent;
begin
  Result := TZConnection.Create(nil);
  with Result as TZConnection do
    begin
      Setproperties(FProperties,Result);
    end;
end;
procedure TZeosDBDM.Disconnect(aConnection: TComponent);
begin
  TZConnection(aConnection).Disconnect;
end;
function TZeosDBDM.StartTransaction(aConnection: TComponent;ForceTransaction : Boolean = False): Boolean;
begin
  TZConnection(aConnection).Tag := Integer(TZConnection(aConnection).TransactIsolationLevel);
  if ForceTransaction and (copy(TZConnection(aConnection).Protocol,0,6) = 'sqlite') then
    TZConnection(aConnection).TransactIsolationLevel:=tiReadCommitted
  else if (copy(TZConnection(aConnection).Protocol,0,8) = 'postgres') then
    TZConnection(aConnection).TransactIsolationLevel:=tiReadCommitted
  else if (copy(TZConnection(aConnection).Protocol,0,5) = 'mssql') then
    TZConnection(aConnection).TransactIsolationLevel:=tiReadUnCommitted;
  TZConnection(aConnection).StartTransaction;
end;
function TZeosDBDM.CommitTransaction(aConnection: TComponent): Boolean;
begin
  if not TZConnection(aConnection).AutoCommit then
    TZConnection(aConnection).Commit;
  if TZTransactIsolationLevel(TZConnection(aConnection).Tag) <> TZConnection(aConnection).TransactIsolationLevel then
    TZConnection(aConnection).TransactIsolationLevel := TZTransactIsolationLevel(TZConnection(aConnection).Tag);
end;
function TZeosDBDM.RollbackTransaction(aConnection: TComponent): Boolean;
begin
  if not TZConnection(aConnection).AutoCommit then
    TZConnection(aConnection).Rollback;
  if TZTransactIsolationLevel(TZConnection(aConnection).Tag) <> TZConnection(aConnection).TransactIsolationLevel then
    TZConnection(aConnection).TransactIsolationLevel := TZTransactIsolationLevel(TZConnection(aConnection).Tag);
end;
function TZeosDBDM.TableExists(aTableName: string;aConnection : TComponent = nil;AllowLowercase: Boolean = False): Boolean;
var
  aIndex: longint;
  i: Integer;
  tmp: String;
begin
  Result := False;
  try
    if Tables.Count = 0 then
      begin
        //Get uncached
        if not Assigned(aConnection) then
          begin
            FMainConnection.DbcConnection.GetMetadata.ClearCache;
            FMainConnection.GetTableNames('','',Tables);
            FMainConnection.GetTriggerNames('','',Triggers);
          end
        else
          begin
            TZConnection(aConnection).DbcConnection.GetMetadata.ClearCache;
            TZConnection(aConnection).GetTableNames('','',Tables);
            FMainConnection.GetTriggerNames('','',Triggers);
          end;
      end;
  except
  end;
  if Tables.IndexOf(aTableName) > 0 then
    begin
      Result := True;
      exit;
    end;
  for i := 0 to Tables.Count-1 do
    begin
      tmp := Tables[i];
      if (Uppercase(tmp) = aTableName)
      then
        begin
          Result := True;
          break;
        end;
    end;
end;
function TZeosDBDM.TriggerExists(aTriggerName: string; aConnection: TComponent;
  AllowLowercase: Boolean): Boolean;
var
  i: Integer;
  tmp: String;
  GeneralQuery: TZQuery;
begin
  if Triggers.Count= 0 then
    begin
      GeneralQuery := TZQuery.Create(Self);
      GeneralQuery.Connection:=TZConnection(MainConnection);
      if (copy(FMainConnection.Protocol,0,10) = 'postgresql') then
        begin
          GeneralQuery.SQL.Text:='select tgname from pg_trigger;';
          GeneralQuery.Open;
        end
      else if (copy(FMainConnection.Protocol,0,6) = 'sqlite') then
        begin
          GeneralQuery.SQL.Text:='select name from sqlite_master where type=''trigger'';';
          GeneralQuery.Open;
        end
      else if (FMainConnection.Protocol = 'mssql') then
        begin
          GeneralQuery.SQL.Text:='SELECT trigger_name = name FROM sysobjects WHERE type = ''TR''';
          GeneralQuery.Open;
        end;
      if GeneralQuery.Active then
        with GeneralQuery do
          begin
            First;
            while not EOF do
              begin
                Triggers.Add(Fields[0].AsString);
                Next;
              end;
          end;
      GeneralQuery.Destroy;
    end;
  Result := False;
  if Triggers.IndexOf(aTriggerName) > 0 then
    begin
      Result := True;
      exit;
    end;
  for i := 0 to Triggers.Count-1 do
    begin
      tmp := Triggers[i];
      if (Uppercase(tmp) = aTriggerName) then
        begin
          Result := True;
          break;
        end;
    end;
end;
function TZeosDBDM.CreateTrigger(aTriggerName: string; aTableName: string;
  aUpdateOn: string; aSQL: string;aField : string = ''; aConnection: TComponent = nil): Boolean;
var
  GeneralQuery: TZQuery;
begin
  if TriggerExists(aTableName+'_'+aTriggerName) then exit;
  GeneralQuery := TZQuery.Create(Self);
  GeneralQuery.Connection := TZConnection(MainConnection);
  if Assigned(aConnection) then GeneralQuery.Connection:=TZConnection(aConnection);
  if (copy(FMainConnection.Protocol,0,10) = 'postgresql') then
    begin
      if (aField <> '') and (aUpdateOn='UPDATE') then
        begin
          aSQL := 'IF $NEW$.'+QuoteField(aField)+'!=$OLD$.'+QuoteField(aField)+' THEN '+LineEnding+aSQL+' END IF;';
        end;
      GeneralQuery.SQL.Text :=
       'DROP TRIGGER IF EXISTS '+QuoteField(aTableName+'_'+aTriggerName)+' ON '+QuoteField(aTableName)+';'+LineEnding
      +'CREATE OR REPLACE FUNCTION '+aTableName+'_'+aTriggerName+'_TRIGGER() RETURNS TRIGGER AS $BASE$'+LineEnding
      +'BEGIN'+LineEnding
      +StringReplace(StringReplace(StringReplace(aSQL,'$NEW$','new',[rfReplaceAll]),'$OLD$','old',[rfReplaceAll]),'$UPDATED$','new',[rfReplaceAll])+LineEnding
      +'RETURN NEW;'+LineEnding
      +'END;'+LineEnding
      +'$BASE$ LANGUAGE plpgsql;'+LineEnding
      +'CREATE TRIGGER '+QuoteField(aTableName+'_'+aTriggerName)+' AFTER '+aUpdateOn+' ON '+QuoteField(aTableName)+' FOR EACH ROW EXECUTE PROCEDURE '+aTableName+'_'+aTriggerName+'_TRIGGER();'+LineEnding;
      DebugLn(GeneralQuery.SQL.Text);
      GeneralQuery.ExecSQL;
    end
  else if (FMainConnection.Protocol = 'mssql') then
    begin
      if (aField <> '') and (aUpdateOn='UPDATE') then
        begin
          aSQL := 'IF INSERTED.'+QuoteField(aField)+'!=DELETED.'+QuoteField(aField)+' THEN '+LineEnding+aSQL+' END IF;';
        end;
      GeneralQuery.SQL.Text :=
      'CREATE OR ALTER TRIGGER '+QuoteField(aTableName+'_'+aTriggerName)+' FOR '+QuoteField(aTableName)+' AFTER '+StringReplace(aUpdateOn,'or',',',[rfReplaceAll])
     +' AS'+LineEnding
     +'BEGIN'+LineEnding
     +StringReplace(StringReplace(StringReplace(aSQL,'$NEW$','INSERTED',[rfReplaceAll]),'$OLD$','DELETED',[rfReplaceAll]),'$UPDATED$','new',[rfReplaceAll])+LineEnding
     +'END;';
      DebugLn(GeneralQuery.SQL.Text);
      GeneralQuery.ExecSQL;
    end
{  else if (copy(FMainConnection.Protocol,0,6) = 'sqlite') then
    begin
      GeneralQuery.SQL.Text :=
      'CREATE TRIGGER IF NOT EXISTS '+QuoteField(aTableName+'_'+aTriggerName)+' AFTER '+StringReplace(aUpdateOn,'or',',',[rfReplaceAll]);
      if aField <> '' then
        GeneralQuery.SQL.Text := GeneralQuery.SQL.Text+' OF '+QuoteField(aField);
      GeneralQuery.SQL.Text := GeneralQuery.SQL.Text+' ON '+QuoteField(aTableName)+' FOR EACH ROW'+LineEnding
     +'BEGIN'+LineEnding
     +StringReplace(StringReplace(StringReplace(aSQL,'$NEW$','new',[rfReplaceAll]),'$OLD$','old',[rfReplaceAll]),'$UPDATED$','new',[rfReplaceAll])+LineEnding
     +'END'+LineEnding;
      DebugLn(GeneralQuery.SQL.Text);
      GeneralQuery.ExecSQL;
    end  }
  else
    Result:=inherited CreateTrigger(aTriggerName, aTableName, aUpdateOn, aSQL,aField, aConnection);
  GeneralQuery.Destroy;
end;
function TZeosDBDM.DropTable(aTableName: string): Boolean;
var
  GeneralQuery: TZQuery;
begin
  GeneralQuery := TZQuery.Create(Self);
  GeneralQuery.Connection := TZConnection(MainConnection);
  GeneralQuery.SQL.Text := 'drop table '+QuoteField(aTableName);
  GeneralQuery.ExecSQL;
  GeneralQuery.Destroy;
  Result := True;
  RemoveCheckTable(aTableName);
end;
function TZeosDBDM.FieldToSQL(aName: string; aType: TFieldType;aSize : Integer;
  aRequired: Boolean): string;
begin
  Result := QuoteField(aName);
  case aType of
  ftString:
    begin
      if (copy(FMainConnection.Protocol,0,8) = 'firebird')
      or (copy(FMainConnection.Protocol,0,9) = 'interbase')
      or (copy(FMainConnection.Protocol,0,10) = 'postgresql') then
        Result := Result+' VARCHAR('+IntToStr(aSize)+')'
      else
        Result := Result+' NVARCHAR('+IntToStr(aSize)+')';
    end;
  ftSmallint,
  ftInteger:Result := Result+' INTEGER';
  ftLargeInt:
    begin
      Result := Result+' BIGINT';
    end;
  ftAutoInc:
    begin
      if (FMainConnection.Protocol = 'mssql') then
        Result := Result+' INTEGER PRIMARY KEY IDENTITY'
      else if (copy(FMainConnection.Protocol,0,6) = 'sqlite') then
        Result := Result+' INTEGER PRIMARY KEY AUTOINCREMENT'
      else Result := Result+' INTEGER PRIMARY KEY';
    end;
  ftFloat:
    begin
      if (copy(FMainConnection.Protocol,0,8) = 'firebird')
      or (copy(FMainConnection.Protocol,0,9) = 'interbase') then
        Result := Result+' DOUBLE PRECISION'
      else
        Result := Result+' FLOAT';
    end;
  ftDate:
    begin
      if (FMainConnection.Protocol = 'mssql') then
        Result := Result+' DATETIME'
      else
        Result := Result+' DATE';
    end;
  ftDateTime:
    begin
      if (FMainConnection.Protocol = 'mssql')
      or (copy(FMainConnection.Protocol,0,6) = 'sqlite')
      then
        Result := Result+' DATETIME'
      else
        Result := Result+' TIMESTAMP'
    end;
  ftTime:
    begin
      if (FMainConnection.Protocol = 'mssql') then
        Result := Result+' DATETIME'
      else
        Result := Result+' TIME';
    end;
  ftBlob:
    begin
      if (FMainConnection.Protocol = 'mssql') then
        Result := Result+' IMAGE'
      else if (copy(FMainConnection.Protocol,0,10) = 'postgresql') then
        Result := Result+' BYTEA'
      else
        Result := Result+' BLOB';
    end;
  ftMemo:
    begin;
      if (copy(FMainConnection.Protocol,0,8) = 'firebird')
      or (copy(FMainConnection.Protocol,0,9) = 'interbase') then
        Result := Result+' BLOB SUB_TYPE 1'
      else
        Result := Result+' TEXT';
    end;
  end;
  if aRequired then
    Result := Result+' NOT NULL'
  else
    begin
      if (FMainConnection.Protocol = 'mssql') then
        Result := Result+' NULL'
    end;
end;
function TZeosDBDM.GetColumns(TableName: string): TStrings;
var
  Metadata: IZDatabaseMetadata;
begin
  Metadata := FMainConnection.DbcConnection.GetMetadata;
  Result := TStringList.Create;
  with Metadata.GetColumns(FMainConnection.Catalog,'',TableNAme,'') do
   try
     while Next do
       Result.Add(GetStringByName('COLUMN_NAME'));
   finally
     Close;
   end;
end;

end.
