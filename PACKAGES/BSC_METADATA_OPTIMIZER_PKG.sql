--------------------------------------------------------
--  DDL for Package BSC_METADATA_OPTIMIZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_METADATA_OPTIMIZER_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMOPTS.pls 120.9.12000000.3 2007/08/03 11:23:16 ankgoel ship $ */
newline varchar2(10):='
';

optimizer_exception EXCEPTION;


g_bsc_apps_initialized boolean:=false;
g_log boolean := false;
g_out boolean := false;

g_debug boolean := false;

g_log_level number := FND_LOG.LEVEL_ERROR;

g_session_id NUMBER := userenv('SESSIONID');

g_num_partitions number:=0;
g_partition_clause varchar2(1000);

-- Table name prefixes
g_kpi_tmp_table_pfx       constant VARCHAR2(30) := 'BSC_TMP_KPI_DATA_';
g_dbmeasure_tmp_table_pfx constant VARCHAR2(30) := 'BSC_TMP_DBMSR_';
g_period_circ_check_pfx   constant VARCHAR2(30):= 'BSC_TMP_PER_CHK_';
g_filtered_indics_pfx     constant VARCHAR2(30):= 'BSC_TMP_FILTERS_';
-- Last tables for BSC_MO_HELPER_PKG.CreateLastTables
g_db_tables_last_pfx      constant VARCHAR2(30):='BSC_TBL_LAST_';
g_db_tables_rels_last_pfx constant VARCHAR2(30):='BSC_TBLRELS_LAST_';
g_kpi_data_last_pfx       constant VARCHAR2(30):='BSC_KPI_DATA_LAST_';
g_db_tables_cols_last_pfx constant VARCHAR2(30):='BSC_DB_TBLCOLS_LAST_';

--Table Names appended with Prefixes
g_kpi_tmp_table VARCHAR2(30) := g_kpi_tmp_table_pfx||g_session_id;

--g_dbmeasure_tmp_table VARCHAR2(30) := g_dbmeasure_tmp_table_pfx||g_session_id;
g_dbmeasure_tmp_table varchar2(4000) :=
'--db measure temp table replacement sql
 ( select distinct indicator, dim_set_id, sysm.measure_id, sysm.measure_col
  from BSC_DB_DATASET_DIM_SETS_V ds,
       (SELECT DATASET_ID, MEASURE_ID1 MEASURE_ID, SOURCE
          FROM BSC_SYS_DATASETS_B
         UNION ALL
        SELECT DATASET_ID, MEASURE_ID2 MEASURE_ID, SOURCE
          FROM BSC_SYS_DATASETS_B
         WHERE MEASURE_ID2 IS NOT NULL ) sds,
       bsc_sys_measures sysm
 where ds.dataset_id=sds.dataset_id
   and sds.measure_id = sysm.measure_id)';

g_period_circ_check VARCHAR2(30):= g_period_circ_check_pfx||g_session_id;
g_filtered_indics VARCHAR2(30):= g_filtered_indics_pfx||g_session_id;

-- Last tables for BSC_MO_HELPER_PKG.CreateLastTables
g_db_tables_last VARCHAR2(30) := g_db_tables_last_pfx||g_session_id;
g_db_table_rels_last VARCHAR2(30) := g_db_tables_rels_last_pfx||g_session_id;
g_kpi_data_last VARCHAR2(30):= g_kpi_data_last_pfx||g_session_id;
g_db_tables_cols_last VARCHAR2(30):= g_db_tables_cols_last_pfx||g_session_id;

g_retcode NUMBER :=0;
g_errbuf  VARCHAR2(4000) := null;
g_processID NUMBER := 0;
g_dropAppsTables DBMS_SQL.VARCHAR2_TABLE;
VERSION VARCHAR2(10) := '5.3';

gIndent varchar2(512):='';
gSpacing varchar2(10) := '     ';
gAppsSchema varchar2(100);
gBSCSchema  varchar2(100);
gApplsysSchema VARCHAR2(100);
gUserId number := 0;
gGAA_RUN_MODE NUMBER := 0;


-- AW
IMPL_TYPE constant VARCHAR2(20):= 'IMPLEMENTATION_TYPE';

/* LANGUAGES */
gInstalled_Languages DBMS_SQL.VARCHAR2_TABLE;
gNumInstalled_Languages NUMBER := 0;
gNLSLang VARCHAR2(30);
gLangCode VARCHAR2(30);

/* RESERVED FUNCTIONS */
gReservedFunctions DBMS_SQL.VARCHAR2_TABLE;
gNumReservedFunctions NUMBER := 0;

/* RESERVED OPERATORS */
gReservedOperators DBMS_SQL.VARCHAR2_TABLE;
gNumReservedOperators NUMBER := 0;


/* RESERVED WORDS */
gArrReservedWords DBMS_SQL.VARCHAR2_TABLE;
gNumArrReservedWords NUMBER := 0;

gSYSTEM_STAGE varchar2(270);
gStorageClause varchar2(2000);
--gTablespaceClauseTbl  varchar2(1000);
--gTablespaceClauseIdx  varchar2(1000);

gInputTableTbsName varchar2(1000);
gInputIndexTbsName varchar2(1000);
gBaseTableTbsName varchar2(1000);
gBaseIndexTbsName varchar2(1000);
gSummaryTableTbsName varchar2(1000);
gSummaryIndexTbsName varchar2(1000);
gOtherTableTbsName varchar2(1000);
gOtherIndexTbsName varchar2(1000);

gThereIsStructureChange boolean;

TYPE CurTyp IS REF CURSOR;

TYPE clsParent IS RECORD (
      name                      VARCHAR2(100),
      relationColumn		VARCHAR2(100));
TYPE tab_clsParent IS TABLE OF clsParent INDEX BY BINARY_INTEGER;

TYPE clsMasterTable IS RECORD (
	name                    VARCHAR2(100),
	keyName			VARCHAR2(100),
	userTable		BOOLEAN,
	EDW_FLAG		NUMBER,
	inputTable		VARCHAR2(100),
	parent_name			VARCHAR2(32000), -- comma separated
    parent_rel_col      VARCHAR2(32000), -- comma separated
	auxillaryFields		VARCHAR2(32000) -- comma separated --tab_clsAuxillaryField
    ,UserKeySize NUMBER
    ,DispKeySize NUMBER
    --BIS DIMENSIONS: Use of Bis dimensions with BSC measures
    --We need to load BIS dimensions in the collection. This new property is to
    --have the source of the dimension: BSC or PMF
    ,Source VARCHAR2(10)
 );


TYPE tab_clsMasterTable IS TABLE OF clsMasterTable INDEX BY BINARY_INTEGER;

TYPE clsRelationMN IS RECORD (
	TableA VARCHAR2(100), --Name of the dimension table A of the relation
	keyNameA VARCHAR2(100), --Name of the key field for dimension table A
	TableB VARCHAR2(100),  --Name of the dimension table B of the relation
	keyNameB VARCHAR2(100),   --Name of the key field for dimension table B
	TableRel VARCHAR2(100), --Name of the relatin table
	InputTable VARCHAR2(100) --Name of the input table
);

TYPE tab_clsrelationMN is table of clsRelationMN INDEX BY BINARY_INTEGER;

gMasterTable tab_clsMasterTable;
gRelationsMN tab_clsrelationMN;

TYPE clsIndicator is RECORD (
    Code 		NUMBER,
    Name 		BSC_KPIS_VL.NAME%TYPE,
    IndicatorType 	NUMBER,
    ConfigType 	NUMBER,
    periodicity 	NUMBER,
    OptimizationMode NUMBER,
    Action_Flag 	NUMBER,
    Share_Flag 	NUMBER,
    Source_Indicator NUMBER,
    EDW_Flag 	NUMBER,
	Impl_Type NUMBER /* 1= Summary Tables or MVs, 2=AWs*/);

TYPE tab_clsIndicator is TABLE OF clsIndicator INDEX BY BINARY_INTEGER;
gIndicators tab_clsIndicator;

TYPE clsNumber IS RECORD (
      value                     NUMBER);

TYPE tab_clsNumber is TABLE OF clsNumber INDEX BY BINARY_INTEGER;

TYPE clsPeriodicity IS RECORD (
	Code	NUMBER,
	EDW_Flag NUMBER,
	Yearly_Flag NUMBER,
	CalendarID NUMBER,
	PeriodicityType NUMBER,
	PeriodicityOrigin VARCHAR2(32000));-- comma separated

TYPE tab_clsPeriodicity is TABLE OF clsPeriodicity INDEX BY BINARY_INTEGER;
gPeriodicities tab_clsPeriodicity;

TYPE clsIndicPeriodicity IS RECORD (
    Code NUMBER,
    TargetLevel NUMBER);

TYPE Tab_clsIndicPeriodicity IS TABLE OF clsIndicPeriodicity INDEX BY BINARY_INTEGER;


TYPE clsCalendar IS RECORD (
    Code	NUMBER,
    EDW_Flag NUMBER,
    Name	VARCHAR2(300),
    CurrFiscalYear NUMBER,
    RangeYrMod NUMBER,
    NumOfYears NUMBER,
    PreviousYears NUMBER
    --BIS DIMENSIONS: BIS TIME dimensions are imported in BSC Calendars.
    --This new property is to'have the source of the calendar: BSC or PMF
    ,Source VARCHAR2(10)
    );

TYPE tab_clsCalendar is TABLE OF clsCalendar INDEX BY BINARY_INTEGER;

gCalendars tab_clsCalendar;


PROCEDURE initMVFlags;
PROCEDURE initReservedFunctions;
PROCEDURE run_metadata_optimizer(
    Errbuf         OUT NOCOPY  Varchar2,
    Retcode        OUT NOCOPY  Varchar2,
    p_runMode     IN NUMBER, -- 0 ALL, 1 INCREMENTAL, 2 SELECTED , (9 obsolete)
    p_processID		IN NUMBER);


PROCEDURE Documentation(
		Errbuf         out NOCOPY  Varchar2,
        Retcode        out NOCOPY  Varchar2);

garrOldIndicators dbms_sql.number_table;
gnumOldIndicators NUMBER := 0;

Type clsOldBTables IS RECORD(
    Name varchar2(100),
    periodicity NUMBER,
    InputTable varchar2(100),
    Fields VARCHAR2(32000),-- comma separated
    numFields 	NUMBER,
    Indicators  VARCHAR2(32000),-- comma separated
    NumIndicators NUMBER);

TYPE tab_clsOldBTables is TABLE OF clsOldBTables INDEX BY BINARY_INTEGER;

gBackedUpBTables DBMS_SQL.VARCHAR2_TABLE;
garrOldBTables tab_clsOldBTables; --array that contains the bases tables of the system before process
gnumOldBTables NUMBER  := 0;

garrIndics dbms_sql.number_table; --array with the indicators the process will apply on.
gnumIndics NUMBER  := 0;

garrIndics4 dbms_sql.number_table;  --array with the indicators with non-structural changes
gnumIndics4 number := 0;

garrTables dbms_sql.varchar2_table;  --array with the tables of the database that will be re-created.
gnumTables number := 0;

EDW_MATERIALIZED_VIEW_EXT constant VARCHAR2(10):= '_MV_V';
EDW_UNION_VIEW_EXT constant VARCHAR2(10) := '_V';

ColorG Constant NUMBER := 8421504;     --Dark Gray
DTNumber Constant VARCHAR2(10) := 'NUMBER';
DTVarchar2 Constant VARCHAR2(10) := 'VARCHAR2';
DTDate Constant VARCHAR2(10) := 'DATE';
ORA_DATA_PRECISION_BYTE Constant NUMBER := 3;
ORA_DATA_PRECISION_INTEGER  Constant NUMBER := 5;
ORA_DATA_PRECISION_LONG Constant NUMBER := 11;
ORA_DATA_PRECISION_DOUBLE Constant NUMBER := 38;
ORA_DATA_DEC_DOUBLE  Constant NUMBER := 4;

C_PFORMULASOURCE CONSTANT VARCHAR2(20) := 'pFormulaSource';
C_PAVGL CONSTANT VARCHAR2(10) := 'pAvgL';
C_PAVGLTOTAL VARCHAR2(20) := 'pAvgLTotal';
C_PAVGLCOUNTER VARCHAR2(20) := 'pAvgLCounter';


TYPE clsMeasureLOV IS RECORD (
    fieldName VARCHAR2(4000), --field name
    description VARCHAR2(255), --Description
    groupCode NUMBER,  --Grouping code
    prjMethod NUMBER, --projection method of the field
                             --0: No Forecast
                             --1: Moving Averge
                             --2: Plan-Based (not used any more)
                             --3: Plan-Based
                             --4: Custom
    measureType NUMBER, --balance or statistical
                            --1: Statistic
                            --2: Balance
    -- BSC Autogen
    source VARCHAR2(30) -- BSC or PMF
);

TYPE tab_clsMeasureLOV is TABLE OF clsMeasureLOV INDEX BY BINARY_INTEGER;
gLOV tab_clsMeasureLOV;

TYPE clsLevels IS RECORD (
    keyName VARCHAR2(100), --Name of the key field
    dimTable VARCHAR2(100), --Name of the dimension table associated with this Level
    Num       NUMBER,  --Index of the Level inside the indicator
    Name      varchar2(100), --Name of the Level
    TargetLevel NUMBER, --1- Apply target, 0- Do not apply target
    Parents1N  VARCHAR2(32000),-- comma separated List of parents 1n (objects class clsCadena)
    ParentsMN  VARCHAR2(32000)-- comma separated List of parents mn (objects class clsCadena)
    );

TYPE tab_clsLevels IS TABLE OF clsLevels INDEX BY BINARY_INTEGER;

TYPE tabrec_clsLevels IS RECORD(
    group_id NUMBER,
    keyName VARCHAR2(100), --Name of the key field
    dimTable VARCHAR2(100), --Name of the dimension table associated with this Level
    Num       NUMBER,  --Index of the Level inside the indicator
    Name      varchar2(100), --Name of the Level
    TargetLevel NUMBER, --1- Apply target, 0- Do not apply target
    Parents1N  VARCHAR2(32000),-- comma separated List of parents 1n (objects class clsCadena)
    ParentsMN  VARCHAR2(32000)-- comma separated List of parents mn (objects class clsCadena)
    );

TYPE tab_tab_clsLevels IS TABLE OF tabrec_clsLevels INDEX BY BINARY_INTEGER;

TYPE clsLevelCombinations IS RECORD(
   Levels VARCHAR2(32000),-- comma separated
   LevelConfig VARCHAR2(1000));

TYPE tab_clsLevelCombinations IS TABLE OF clsLevelCombinations INDEX BY BINARY_INTEGER;

TYPE tabrec_clsLevelCombinations IS RECORD(
    group_id NUMBER,
	Levels VARCHAR2(32000),-- comma separated
    LevelConfig VARCHAR2(1000)
   );

TYPE tab_tab_clsLevelCombinations IS TABLE OF tabrec_clsLevelCombinations INDEX BY BINARY_INTEGER;

TYPE clsKeyField IS RECORD(
    tableName       VARCHAR2(100),
	keyName VARCHAR2(100),
	origin 	VARCHAR2(100),
	needsCode0 boolean,
	calculateCode0 boolean,
	FilterViewName varchar2(100),
    --BSC-MV Note: need this property to store the index of the dimension whitin the kpi
    dimIndex NUMBER);

TYPE tab_clsKeyField IS TABLE OF clsKeyField  INDEX BY BINARY_INTEGER;

TYPE clsDataField IS RECORD (
    tableName            VARCHAR2(100),
    fieldName		 VARCHAR2(4000),
    aggFunction		 VARCHAR2(100),
    Origin		 VARCHAR2(4000),
    AvgLFlag		 VARCHAR2(100),
    AvgLTotalColumn	 VARCHAR2(100),
    AvgLCounterColumn 	 VARCHAR2(100),
    InternalColumnType	 NUMBER,
    InternalColumnSource VARCHAR2(4000),
    -- BSC Autogen
    Source VARCHAR2(30),
    -- Column added to production table
    changeType VARCHAR2(30),
    measureGroup NUMBER
	);

TYPE tab_clsDataField IS TABLE OF clsDataField INDEX BY BINARY_INTEGER;


TYPE clsBasicTable IS RECORD (
   Name 		VARCHAR2(100),
   keys 		tab_clsKeyField,
   Data 		tab_clsDataField,
   LevelConfig		VARCHAR2(100),
   originTable		VARCHAR2(1000));

TYPE tab_clsBasicTable IS TABLE OF clsBasicTable INDEX BY BINARY_INTEGER;

TYPE tab_string IS RECORD
(value VARCHAR2(32000) );-- comma separated

TYPE tab_tab_String IS TABLE OF tab_string INDEX BY BINARY_INTEGER;

TYPE number_table IS RECORD(
	value DBMS_SQL.number_table);

--TYPE TwoDNumberTable IS TABLE OF number_table INDEX BY BINARY_INTEGER;

TYPE clsOriginTable IS RECORD(
	Name 	VARCHAR2(1000));
TYPE tab_clsOriginTable IS TABLE OF clsOriginTable INDEX BY BINARY_INTEGER;


TYPE clsTable IS RECORD(
	Name 		VARCHAR2(1000), --Name of the table
	Type		NUMBER,  	--Type 0: Input table 1: System table (base, temporal or summary)
	Periodicity	NUMBER,  	--periodicity
	originTable	 VARCHAR2(32000), -- comma sep list of tables where it is originated from (Hard Relation).
	originTable1 VARCHAR2(32000), -- comma sep list of tables where it is originated from (Soft Relation).
	Indicator 	    NUMBER, 	--Indicator code using directly this table
	Configuration 	NUMBER, 	--Configuration of the indicator using directly this table
	EDW_Flag 	    NUMBER,  	--If the table belong to a EDW Kpi. 1=YES, 0=NO
	IsTargetTable 	Boolean, 	-- true -The table is only for targets
	HasTargets 	   Boolean, 	-- true -The table has targets
                             		-- This property is used when the indicator has target at different levels
                             		-- This property is used only within indicator tables
	UsedForTargets Boolean, 	-- true -The table contains targets and is really used for the indicator.
                                 -- This property is used when the indicator has target at different levels
                                 -- This property is used only within indicator tables
    Keys tab_clsKeyField,
    Data tab_clsDataField,
	--BSC-MV Note: This property is used for Documentation only
    dbObjectType VARCHAR2(100),
    MVName VARCHAR2(100),
    --BSC-MV Note: This properties are used only when there is sum level change
    --             (from NULL to NOTNULL) and for tables used for indicators
    --             in production
    upgradeFlag NUMBER,
    currentPeriod NUMBER,
    --BSC-MV Note: This property is to store the name of the projection table
    projectionTable VARCHAR2(100),
    -- existing production table used for optimization... should not be dropped or recreated
    isProductionTable boolean,
    -- existing production table altered for adding deleting measures, enh 4350262
    isProductionTableAltered boolean,
    Impl_Type NUMBER /* 1= Summary Tables or MVs, 2=AWs*/,
    -- Column added to production table
    changeType VARCHAR2(30),
    -- measure group for this table
    MeasureGroup NUMBER);

TYPE tab_clsTable IS TABLE OF clsTable INDEX BY BINARY_INTEGER;

gTables tab_clsTable;

gSequence NUMBER :=0;

TYPE clsDisAggField IS RECORD(
tablename VARCHAR2(100),
fieldName VARCHAR2(4000),
fieldType VARCHAR2(100),
Code NUMBER, --dissagregation code
Periodicity NUMBER, --periodicity
Origin NUMBER, --code of the origin dissagregation
Registered boolean, --True if the dissagregation was already registered
keys tab_clsKeyField,--List of keys
keyStart number, -- start point to global pl_sql table g_disaggKeys
keyNum number    -- # of keys
--From production table
,isProduction boolean
);

TYPE tab_clsDisAggField IS TABLE OF clsDisAggField INDEX BY BINARY_INTEGER;


TYPE clsUniqueField IS RECORD (
fieldName VARCHAR2(1000),
aggFunction VARCHAR2(400),
--List of different dissagregations  of the field (objects class clsDesagCampo)
key_combinations tab_clsDisaggField,
EDW_Flag NUMBER, --If the field belong to a EDW table. 1=YES, 0=NO
Impl_type NUMBER,
-- BSC Autogen
source VARCHAR2(30),
measureGroup NUMBER
);
TYPE tab_clsUniqueField IS TABLE OF clsUniqueField INDEX BY BINARY_INTEGER;


g_unique_measures tab_clsUniqueField ; --Unique list of fields.
g_unique_measures_tgt tab_clsUniqueField ;--Unique list of fields fro target tables only.
--gColUnicaCamposPreCalc
g_unique_measures_precalc tab_clsUniqueField ;--Unique list of fields for pre-calculated kpis.

--gTablasTempyBasicas
g_bt_tables tab_clsTable ; --Collection of temporal and base tables (Collection of clsTablas)
--gTablasTempyBasicasTargets
g_bt_tables_tgt tab_clsTable ; --Collection of temporal and base tables for targets (Collection of clsTablas)
--gTablasTempyBasicasPreCalc
g_bt_tables_precalc tab_clsTable ; --Collection of temporal and base tables for pre-calculated indicators (Collection of clsTablas)

gMaxT NUMBER;
gMaxB NUMBER;
gMaxI NUMBER;

TYPE clsDBColumn IS RECORD(
columnName VARCHAR2(100),
columnTYPE VARCHAR2(100),
columnLength NUMBER,
isKey BOOLEAN,
isTimeKey boolean);

TYPE tab_clsDBColumn IS TABLE OF clsDBColumn INDEX BY BINARY_INTEGER;



Type TNewITables IS RECORD(
    Name VARCHAR2(100),
    periodicity NUMBER,
    Fields VARCHAR2(32000), -- comma sep
    numFields NUMBER,
    Indicators VARCHAR2(32000), -- comma sep
    NumIndicators NUMBER);

TYPE tab_TNewITables IS TABLE OF TNewITables INDEX BY BINARY_INTEGER;

garrNewITables tab_TNewITables; --array that contains the input tables of new system
gnumNewITables NUMBER;

--Procedure writeLog(p_message IN VARCHAR2);
--Procedure writeOut(p_message IN VARCHAR2);

--Procedure writeDoc(p_message IN VARCHAR2);

g_dir VARCHAR2(300);
g_file utl_file.file_type;
g_fileOpened boolean := false;

g_filename VARCHAR2(200) := 'METADATA';

Function getUtlFileDir return VARCHAR2 ;

-- MV and Upgrade Changes
--BSC-MV Note: Profile to indicate if the system is with DBI architecture
g_BSC_MV Boolean;
g_Adv_Summarization_Level VARCHAR2(100);
g_Current_Adv_Sum_Level VARCHAR2(100);
g_Sum_Level_Change NUMBER; --0- No change
                                     --1- Upgrade to new architecture (from NULL to NOT NULL)
                                     --2- Just changing the sum level (Example: from 2 to 3)
garrTablesUpgrade DBMS_SQL.VARCHAR2_TABLE; --array with the T, base and input tables used by production indicators.
                                     --This array is used only when Sum level is changed from NULL to NOTNULL
gnumTablesUpgrade NUMBER;
garrTablesUpgradeT DBMS_SQL.VARCHAR2_TABLE;
gnumTablesUpgradeT NUMBER;

Type clsConfigKpiMV IS RECORD(
LevelComb VARCHAR2(1000), --Level combination ?110
MVName VARCHAR2(100), --MV name
DataSource VARCHAR2(100), --Data source; MV or SQL
SqlStmt VARCHAR2(4000));--SQL statement

TYPE tab_clsConfigKpiMV IS TABLE OF clsConfigKpiMV INDEX BY BINARY_INTEGER;


Type clsKPIDimSet IS RECORD(
kpi_number NUMBER,
dim_set_id NUMBER);

TYPE tab_clsKPIDimSet IS TABLE OF clsKPIDimSet INDEX BY BINARY_INTEGER;

--PROCEDURE RenameInputTable(pOld IN VARCHAR2, pNew IN VARCHAR2, pStatus OUT VARCHAR2, pMessage OUT VARCHAR2) ;


--API counters

ginsertKeys NUMBER:=0;
gupdateKeys NUMBER:=0;
ginsertData NUMBER:=0;
ginsertData1Row NUMBER:=0;
ggetAllKeyFields NUMBER:=0;
ggetOneKeyField NUMBER:=0;
ggetAllDataFields NUMBER:=0;
ggetOneDataField NUMBER:=0;
ggetDisaggs NUMBER:=0;
ggetDisaggKeys NUMBER:=0;
ginsertDisAggs NUMBER:=0;
ginsertOneDisAgg NUMBER:=0;
ginsertDisAggKeys NUMBER:=0;
ginsertOneDisAggKey NUMBER:=0;
gupdateOneDisAgg NUMBER:=0;
gupdateOneDisAggKey NUMBER:=0;

gconsolidateString NUMBER := 0;
gDropTable NUMBER := 0;
ggupdateKeys NUMBER := 0;

ginsertSingleKey NUMBER := 0;

gUIAPI boolean := false;
gThreadType VARCHAR2(10);

gTesting boolean := true;

gTables_counter number := 0;

--API timings
g_time_getOneDataField NUMBER := 0;
g_time_InsertData1Row NUMBER := 0;
g_time_updateKeys NUMBER := 0;
g_time_getOneKeyField NUMBER := 0;

g_time_getAllDataFields NUMBER := 0;
g_time_getAllKeyFields NUMBER  := 0;
g_time_insertKeys NUMBER := 0;
g_time_insertData NUMBER := 0;
g_time_getDisaggs NUMBER := 0;
g_time_getDisaggKeys NUMBER := 0;
g_time_insertDisAggs NUMBER := 0;
g_time_insertOneDisAgg NUMBER := 0;
g_time_insertDisAggKeys NUMBER := 0;
g_time_insertOneDisAggKey NUMBER := 0;
g_time_updateOneDisAgg NUMBER := 0;
g_time_updateOneDisAggKey NUMBER := 0;
--g_time_consolidateString NUMBER := 0;

--g_table

PROCEDURE logProgress(pStage IN VARCHAR2, pMessage IN VARCHAR2) ;

FUNCTION is_totally_shared_obj(p_objective IN NUMBER) RETURN BOOLEAN;

END BSC_METADATA_OPTIMIZER_PKG;

 

/
