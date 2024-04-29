--------------------------------------------------------
--  DDL for Package BSC_MO_HELPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_HELPER_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMOHPS.pls 120.9.12000000.2 2007/04/24 05:32:27 amitgupt ship $ */

g_stack dbms_sql.varchar2_table;
g_stack_index number :=0;
g_stack_length number :=0;


TYPE CurTyp IS REF CURSOR;
FUNCTION getSourceTable(p_table IN VARCHAR2) return VARCHAR2 ;
FUNCTION getPeriodicityForTable(p_table_name IN VARCHAR2) return NUMBER;
PROCEDURE checkError(apiName IN VARCHAR2);
PROCEDURE InitTablespaceNames ;
FUNCTION getTablespaceClauseTbl RETURN VARCHAR2 ;
FUNCTION getTablespaceClauseIdx RETURN VARCHAR2 ;
FUNCTION getStorageClause RETURN VARCHAR2 ;

PROCEDURE MarkIndicsForNonStrucChanges;
--Procedure MarkIndicsAndTables;
Function GetFieldExpression(FieldExpresion IN OUT NOCOPY dbms_sql.varchar2_table, Expresion IN VARCHAR2)
return NUMBER;
FUNCTION get_time RETURN VARCHAR2;

PROCEDURE addStack(pStack IN OUT NOCOPY VARCHAR2, pMsg IN VARCHAR2);
PROCEDURE InitializePeriodicities;
PROCEDURE InitializeCalendars;
procEDURE InitArrReservedWords;
PROCEDURE InitializeMasterTables ;

PROCEDURE DropTable(p_table_name in VARCHAR2) ;
PROCEDURE DropView(p_view_name in VARCHAR2) ;
PROCEDURE Do_DDL(
	x_statement IN VARCHAR2,
        x_statement_type IN INTEGER := 0,
        x_object_name IN VARCHAR2
	) ;

FUNCTION getAppsSchema return VARCHAR2;
FUNCTION getBSCSchema return VARCHAR2;
FUNCTION getApplsysSchema return VARCHAR2;

PROCEDURE CreateCopyTable(TableName IN VARCHAR2, CopyTableName IN VARCHAR2, TbsName IN VARCHAR2, p_where_clause IN VARCHAR2 default null);
PROCEDURE CreateCopyIndexes(TableName IN VARCHAR2, CopyTableName IN VARCHAR2, TbsName IN VARCHAR2 DEFAULT NULL);

PROCEDURE CreateLastTables;

PROCEDURE InitInfoOldSystem;


Function searchStringExists(arrStr dbms_sql.varchar2_table, Num number, str varchar2) return boolean;
PROCEDURE deletePreviousRunTables;
Function DBObjectExists(ObjectName IN VARCHAR2)return boolean ;

Procedure CheckAllIndicsHaveSystem;
Procedure CheckAllSharedIndicsSync;
PROCEDURE CheckAllEDWIndicsFullyMapped;
Procedure InitIndicators;


FUNCTION IsNumber (str IN VARCHAR2) RETURN BOOLEAN ;

Function FindIndexVARCHAR2(arrStr IN dbms_sql.varchar2_table, str IN VARCHAR2) return NUMBER;
Function FindIndex(arrNum IN dbms_sql.NUMBER_TABLE, num IN NUMBER) RETURN NUMBER;
Function FindIndex(arrstr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,  findThis in varchar2) return NUMBER ;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMasterTable, findThis in varchar2) return NUMBER;
Function FindKeyIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMasterTable, keyName in varchar2) return NUMBER;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsTable, findThis in varchar2) return NUMBER;

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable, findThis in varchar2) return NUMBER;

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator, findThis in number) return NUMBER ;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField, findThis in VARCHAR2, p_source IN VARCHAR2, p_impl_type IN NUMBER ) return NUMBER ;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisaggField, findThis in NUMBER) return NUMBER ;
--BSC Autogen
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMeasureLOV, findThis in VARCHAR2, p_source IN VARCHAR2, pIgnoreCase In Boolean default false) return NUMBER ;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsPeriodicity, findThis in NUMBER) return NUMBER ;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsCalendar, findThis in NUMBER) return NUMBER ;
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels,  findThis in varchar2) return NUMBER ;


FUNCTION getInitColumn(p_column IN VARCHAR2) return VARCHAR2 ;
FUNCTION get_lookup_value(p_lookup_type IN VARCHAR2, p_lookup_code  IN VARCHAR2) return VARCHAR2;

Function TableExists(Table_Name IN VARCHAR2) return Boolean;
--Procedure CreateBackupBaseTables;
Procedure backup_b_table(p_table IN VARCHAR2);
--PROCEDURE InitReservedFunctions;
PROCEDURE InitLOV ;

FUNCTION decomposeString(p_string IN VARCHAR2, p_separator IN VARCHAR2, p_return_array OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE)
return NUMBER ;
FUNCTION decomposeStringtoNumber(p_string IN VARCHAR2, p_separator IN VARCHAR2) return DBMS_SQL.NUMBER_TABLE;
Function searchNumberExists(arrStr dbms_sql.number_table, Num number, l_findThis NUMBER)
return Boolean;

Function table_column_exists(p_table IN VARCHAR2, p_Column IN VARCHAR2) RETURN boolean;
PROCEDURE InitializeYear ;
PROCEDURE CleanDatabase;

PROCEDURE AddIndicator(collIndicadores IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator, p_Code NUMBER,
			p_Name varchar2, p_indicatorType NUMBER, p_configType NUMBER,
			p_per_inter NUMBER, p_optMode NUMBER, p_action_flag NUMBER,
			p_share_flag NUMBER, p_src_ind NUMBER, p_edw_flag NUMBER, p_impl_type NUMBER) ;
Function getKPIPropertyValue(Indic IN NUMBER, Variable IN VARCHAR2,
	def IN NUMBER) return NUMBER ;

PROCEDURE writeTmp(msg IN VARCHAR2, pSeverity IN NUMBER DEFAULT NULL, pForce IN boolean default false);
PROCEDURE UpdateFlags;

PROCEDURE SaveOptimizationMode;
--PROCEDURE addTable (pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable, proc IN VARCHAR2);
PROCEDURE addTable (pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable,
            pKeyFields IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
            pData       IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField,
        proc IN VARCHAR2);


FUNCTION boolean_decode (pVal IN BOOLEAN) RETURN VARCHAR2;



PROCEDURE write_this (pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsConfigKpiMV ,
pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false);
PROCEDURE write_this (pTable IN BSC_METADATA_OPTIMIZER_PKG.clsConfigKpiMV ,
pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false);

PROCEDURE write_this (pTable IN DBMS_SQL.VARCHAR2_TABLE,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this (pTable IN DBMS_SQL.NUMBER_TABLE,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.clsAuxillaryField,  ind IN NUMBER default null, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsAuxillaryField, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.clsParent,  ind IN NUMBER default null, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsParent, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT);
PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.clsMasterTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMasterTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsRelationMN,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsRelationMN,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsIndicator,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsPeriodicity ,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity ,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsCalendar,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsCalendar,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsOldBTables,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsOldBTables,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMeasureLOV,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsLevels,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevelCombinations,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDataField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsBasicTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_string,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_string,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.number_table,  ind IN NUMBER default null, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false);MBER DEFAULT FND_LOG.LEVEL_STATEMENT);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.TwoDNumberTable, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false);_STATEMENT);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.clsOriginTable,  ind IN NUMBER default null, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false);NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT);
--PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsOriginTable, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false);VEL_STATEMENT);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false,
  pIgonoreProduction IN boolean default false);
PROCEDURE write_this(
  pTableName IN VARCHAR2, pFieldName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDisAggField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pFieldName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisAggField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsUniqueField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDBColumn,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.TNewITables,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_TNewITables,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false);

FUNCTION new_clsUniqueField return BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
FUNCTION new_clsTable return BSC_METADATA_OPTIMIZER_PKG.clsTable;
FUNCTION new_clsDataField return BSC_METADATA_OPTIMIZER_PKG.clsDataField;
FUNCTION new_clsDisAggField return BSC_METADATA_OPTIMIZER_PKG.clsDisAggField;
FUNCTION new_clsKeyField return BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
FUNCTION new_clsOriginTable return BSC_METADATA_OPTIMIZER_PKG.clsOriginTable;
FUNCTION new_clsDBColumn return BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
FUNCTION new_clsMeasureLOV return BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV;
FUNCTION new_clsPeriodicity return BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity;
FUNCTION new_clsCalendar return BSC_METADATA_OPTIMIZER_PKG.clsCalendar;
FUNCTION new_clsMasterTable return BSC_METADATA_OPTIMIZER_PKG.clsMasterTable;
FUNCTION new_clsLevels return BSC_METADATA_OPTIMIZER_PKG.clsLevels;

FUNCTION new_tabrec_clsLevels return BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels;
FUNCTION new_clsBasicTable return BSC_METADATA_OPTIMIZER_PKG.clsBasicTable ;
FUNCTION new_clsLevelCombinations return BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations;
FUNCTION new_TNewITables return BSC_METADATA_OPTIMIZER_PKG.TNewITables;

/*FUNCTION new_ return BSC_METADATA_OPTIMIZER_PKG.;
FUNCTION new_ return ;*/


FUNCTION get_tab_clsLevels (Coll IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels, group_id IN NUMBER) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
FUNCTION get_tab_clsLevelCombinations (Coll IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations, group_id IN NUMBER) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations;

FUNCTION getGroupIds (levels IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels) RETURN DBMS_SQL.NUMBER_TABLE ;
FUNCTION getGroupIds (levels IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations) RETURN DBMS_SQL.NUMBER_TABLE;


/*PROCEDURE insertBasicTable( pTable BSC_METADATA_OPTIMIZER_PKG.clsBasicTable,
                            pKeys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
                            pData BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField);
*/

FUNCTION consolidateString (pTable IN DBMS_SQL.VARCHAR2_TABLE, pSeparator IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getDecomposedString(p_string IN VARCHAR2, p_separator IN VARCHAR2) RETURN
DBMS_SQL.VARCHAR2_TABLE ;

PROCEDURE add_tabrec_clsLevels(
    pInput IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
    pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels,
    l_group_id IN NUMBER) ;
PROCEDURE add_tabrec_clsLevelComb(
    pInput IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations,
    pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations,
    l_group_id IN NUMBER) ;


--PROCEDURE insertKeys(pTableName IN VARCHAR2, pKeyFields IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField);
--PROCEDURE updateKeys(pTableName IN VARCHAR2, pKeyFields IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField) ;
--PROCEDURE insertData(pTableName IN VARCHAR2, pData IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField);
--PROCEDURE insertData(pTableName IN VARCHAR2, pData IN BSC_METADATA_OPTIMIZER_PKG.clsDataField) ;

--FUNCTION getAllKeyFields(pTableName IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
--FUNCTION getOneKeyField(table_name IN VARCHAR2, key_name IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.clsKeyField;

--FUNCTION getAllDataFields(pTableName IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
--FUNCTION getOneDataField(table_name IN VARCHAR2, field_name IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.clsDataField;


/* new */
/*
PROCEDURE insertKeys_pls(pTableName IN VARCHAR2, pKeyFields IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField);
PROCEDURE updateKeys_pls(pTableName IN VARCHAR2, pKeyFields IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField) ;
PROCEDURE insertData_pls(pTableName IN VARCHAR2, pDataFields IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField);
PROCEDURE insertData_pls(pTableName IN VARCHAR2, pData IN BSC_METADATA_OPTIMIZER_PKG.clsDataField) ;
PROCEDURE insertSingleKey_pls(pTableName IN VARCHAR2, pKeyField IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField) ;

FUNCTION getAllKeyFields_pls(pTableName IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
FUNCTION getOneKeyField_pls(table_name IN VARCHAR2, key_name IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.clsKeyField;

FUNCTION getAllDataFields_pls(pTableName IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
FUNCTION getOneDataField_pls(table_name IN VARCHAR2, field_name IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.clsDataField;
*/


/* Field disaggs*/
--FUNCTION getDisaggs(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pFieldType IN NUMBER default 1) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisaggField;
--PROCEDURE insertDisAggs(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pDisAggs IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisAggField, pFieldType IN NUMBER default 1) ;
--PROCEDURE insertOneDisAgg(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pDisAgg IN BSC_METADATA_OPTIMIZER_PKG.clsDisAggField, pFieldType IN NUMBER default 1) ;
--PROCEDURE updateOneDisAgg(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pDisAgg IN BSC_METADATA_OPTIMIZER_PKG.clsDisAggField, pFieldType IN NUMBER default 1);

/* Field disagg keys*/
--FUNCTION getDisaggKeys(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pCode IN NUMBER, pFieldType IN NUMBER default 1) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
--PROCEDURE insertDisAggKeys(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pCode IN NUMBER, pKeyFields IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField, pFieldType IN NUMBER default 1) ;
--PROCEDURE insertOneDisAggKey(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pCode IN NUMBER, pKey IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField, pFieldType IN NUMBER default 1);
--PROCEDURE updateOneDisAggKey(pTableName IN VARCHAR2, pFieldName IN VARCHAR2, pCode IN NUMBER, pKey IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField, pFieldType IN NUMBER default 1);


PROCEDURE addTable (pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable, proc IN VARCHAR2) ;


PROCEDURE terminateWithError(pErrorShortName IN VARCHAR2, pAPI in varchar2 default null);
PROCEDURE terminateWithMsg(pMessage IN VARCHAR2, pAPI in varchar2 default null);


PROCEDURE WriteInfoMatrix(Indic IN NUMBER, Variable IN VARCHAR2, Valor IN NUMBER) ;

PROCEDURE writeKeysTest;

Function Get_New_Big_In_Cond_Varchar2( x_variable_id in number, x_column_name in varchar2) return VARCHAR2 ;
Function Get_New_Big_In_Cond_Number( x_variable_id IN NUMBER, x_column_name IN VARCHAR2) return VARCHAR2 ;
PROCEDURE Add_Value_Big_In_Cond_Varchar2(x_variable_id IN NUMBER, x_value IN VARCHAR2) ;
PROCEDURE Add_Value_Big_In_Cond_Number(x_variable_id IN NUMBER, x_value IN NUMBER);
PROCEDURE Add_Value_Bulk(x_variable_id IN NUMBER, x_value IN DBMS_SQL.VARCHAR2_TABLE) ;
PROCEDURE Add_Value_Bulk(x_variable_id IN NUMBER, x_value IN DBMS_SQL.NUMBER_TABLE);

PROCEDURE InsertRelatedTables(arrTables in dbms_Sql.varchar2_table, numTables in number) ;


PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisAggField,  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false) ;
PROCEDURE write_this(pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDisAggField,  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false) ;

FUNCTION find_objectives_for_table(p_table IN VARCHAR2) return BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet;
PROCEDURE CreateKPIDataTableTmp ;
PROCEDURE CreateDBMeasureByDimSetTmp ;
FUNCTION filters_exist(p_kpi_number IN NUMBER, p_dim_set_id IN NUMBER, p_column_name IN VARCHAR2, p_filter_view OUT NOCOPY VARCHAR2) return boolean;
PROCEDURE dump_stack;
PROCEDURE write_to_stack(msg IN VARCHAR2);

PROCEDURE drop_unused_columns(p_drop_tables_sql IN VARCHAR2);

PROCEDURE load_reporting_calendars ;
PROCEDURE implement_aws(p_objectives in dbms_Sql.varchar2_table) ;


FUNCTION validate_dimension_views return BOOLEAN;
FUNCTION generate_index_name(p_table_name IN VARCHAR2,
                      p_table_type IN VARCHAR2,p_index_type IN VARCHAR2) RETURN VARCHAR2;
END BSC_MO_HELPER_PKG;

 

/
