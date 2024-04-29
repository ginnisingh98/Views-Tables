--------------------------------------------------------
--  DDL for Package BSC_MO_INDICATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_INDICATOR_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMOIDS.pls 120.0 2005/05/31 18:56:05 appldev noship $ */
Function GetStrCombinationsMN(combo IN dbms_sql.varchar2_table)
 return dbms_sql.varchar2_table ;

TYPE CurTyp IS REF CURSOR;

--Function GetSourceDimensionSet(Indic IN NUMBER, DimSet IN NUMBER) RETURN VARCHAR2;
--Function GetColConfigForIndic(Indic IN NUMBER) return DBMS_SQL.NUMBER_TABLE ;

PROCEDURE IndicatorTables ;
Function keyFieldExists(
    colCamposLlaves IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
    keyName IN VARCHAR2) return Boolean ;
Function dataFieldExists(colMeasures IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField, measure IN VARCHAR2)  RETURN BOOLEAN ;
Function dataFieldExistsForSource(colMeasures IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField,
  measure IN VARCHAR2,
  p_source IN VARCHAR2
  ) RETURN BOOLEAN ;

Function IndexRelation1N(tablename IN VARCHAR2, masterTableName IN VARCHAR2 ) RETURN NUMBER ;
Function GetKeyOrigin(keyNamesOri IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField, keyName IN VARCHAR2) return VARCHAR2;
Function GetConfigurationsForIndic(Indic IN NUMBER) return DBMS_SQL.NUMBER_TABLE ;
Function GetLevelCollection(Indic IN NUMBER, Configuration IN NUMBER) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels ;
Function GetFreeDivZeroExpression(expression IN VARCHAR2) RETURN VARCHAR2 ;
Function IsIndicatorPnL(Ind IN Integer, pUseGIndics boolean) return Boolean ;
Function GetDataFields(Indic IN NUMBER, Configuration IN NUMBER, WithInternalColumns IN Boolean)
 RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField ;

Function IsIndicatorBalanceOrPnL(Ind IN Integer, pUseGIndics boolean )  return Boolean;


Function GetProjectionTableName(TableName IN VARCHAR2) RETURN VARCHAR2 ;

Function GetColConfigForIndic(Indic IN NUMBER) return DBMS_SQL.NUMBER_TABLE ;

END BSC_MO_INDICATOR_PKG;

 

/
