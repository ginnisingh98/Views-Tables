--------------------------------------------------------
--  DDL for Package BSC_DBGEN_STD_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DBGEN_STD_METADATA" AUTHID CURRENT_USER AS
/* $Header: BSCMETAS.pls 120.3 2005/10/13 13:41 arsantha noship $ */
newline varchar2(10):='
';
metadata_exception EXCEPTION;

BSC constant VARCHAR2(10) := 'BSC';
AK  constant VARCHAR2(10) := 'AK';
BSC_PROPERTY_NOT_FOUND constant varchar2(100) := 'BSC_PROPERTY_NOT_FOUND';

--projection method of the field
                             --0: No Forecast
                             --1: Moving Averge
                             --2: Plan-Based (not used any more)
                             --3: Plan-Based
                             --4: Custom
PROJECTION_ID          constant VARCHAR2(30) := 'PROJECTION_ID';
-- Target Level
--   0 - NO
--   1 -YES
TARGET_LEVEL           constant VARCHAR2(30) := 'TARGET_LEVEL';
PROTOTYPE_FLAG         constant VARCHAR2(30) := 'PROTOTYPE_FLAG';
CONFIG_TYPE            constant VARCHAR2(30) := 'CONFIG_TYPE';
PERIODICITY_ID         constant VARCHAR2(30) := 'PERIODICITY_ID';
OPTIMIZATION_MODE      constant VARCHAR2(30) := 'OPTIMIZATION_MODE';
SHARE_FLAG             constant VARCHAR2(30) := 'SHARE_FLAG';
SOURCE_INDICATOR       constant VARCHAR2(30) := 'SOURCE_INDICATOR';
AVGL_SINGLE_COLUMN     constant VARCHAR2(30) := 'AVGL_SINGLE_COLUMN';
AVGL_TOTAL_COLUMN      constant VARCHAR2(30) := 'AVGL_TOTAL_COLUMN';
AVGL_COUNTER_COLUMN    constant VARCHAR2(30) := 'AVGL_COUNTER_COLUMN';
AVGL_FLAG              constant VARCHAR2(30) := 'AVGL_FLAG';
INTERNAL_COLUMN_TYPE   constant VARCHAR2(30) := 'INTERNAL_COLUMN_TYPE';
INTERNAL_COLUMN_SOURCE constant VARCHAR2(30) := 'INTERNAL_COLUMN_SOURCE';
MISSING_LEVEL          constant VARCHAR2(30) := 'MISSING_LEVEL'; -- YES/No
SOURCE_FORMULA         constant VARCHAR2(30) := 'SOURCE_FORMULA';


VERSION VARCHAR2(10) := '5.3';


BSC_PARTITION          constant VARCHAR2(20) := 'PARTITIONS';
BSC_B_PRJ_TABLE        constant VARCHAR2(20) := 'B_PRJ_TABLE_NAME';
BSC_I_ROWID_TABLE      constant VARCHAR2(20) := 'I_ROWID_TABLE_NAME';
BSC_ASSIGNMENT         constant VARCHAR2(10) := '=';
BSC_PROPERTY_SEPARATOR constant VARCHAR2(10) := '***';

--BSC_BATCH_COLUMN_NAME constant VARCHAR2(20) := 'PARTITION_BUCKET_NUM';
BSC_BATCH_COLUMN_NAME constant VARCHAR2(20) := 'PARTITION_BUCKET_NUM';

TYPE CurTyp IS REF CURSOR;

TYPE clsAttribute IS RECORD (
      attribute_name   VARCHAR2(30),
      attribute_value  VARCHAR2(240));
TYPE tab_clsAttribute IS TABLE OF clsAttribute;

TYPE ClsProperties IS RECORD(
name      VARCHAR2(240),
Value     VARCHAR2(4000));
TYPE tab_ClsProperties  IS TABLE OF ClsProperties INDEX BY VARCHAR2(240);


TYPE ClsFact IS RECORD(
Fact_id NUMBER,-- bsc indicator equivalent
Fact_Name VARCHAR2(240),
Fact_Type VARCHAR2(30),
dimension_set DBMS_SQL.NUMBER_TABLE,
Application_short_name VARCHAR2(30),
properties tab_ClsProperties);
TYPE tab_clsFact IS TABLE OF clsFact INDEX BY PLS_INTEGER;


TYPE ClsLevel IS RECORD(
--Dimension_Name VARCHAR2(240),
Level_Name VARCHAR2(240),
Level_Type VARCHAR2(30),
Level_index NUMBER,
Level_id NUMBER,
Level_table_name VARCHAR2(240),
Level_PK VARCHAR2(240),
Level_PK_Datatype VARCHAR2(100),
LEVEL_FK VARCHAR2(240), -- for BSC
Parents1N DBMS_SQL.VARCHAR2_TABLE,
ParentsMN DBMS_SQL.VARCHAR2_TABLE,
properties tab_ClsProperties  );

TYPE tab_ClsLevel IS TABLE OF ClsLevel INDEX BY PLS_INTEGER;

TYPE ClsLevelRelationship IS RECORD(
child_level VARCHAR2(240),
child_level_fk   VARCHAR2(240),
Parent_Level VARCHAR2(240),
Parent_Level_pk VARCHAR2(240),
properties tab_ClsProperties);
TYPE tab_ClsLevelRelationship  IS TABLE OF ClsLevelRelationship INDEX BY PLS_INTEGER;

TYPE ClsHierarchy IS RECORD(
Hierarchy_Name VARCHAR2(240),
Levels tab_ClsLevel,
level_relationships tab_ClsLevelRelationship,
properties tab_ClsProperties);
TYPE tab_ClsHierarchy  IS TABLE OF ClsHierarchy INDEX BY PLS_INTEGER;

TYPE ClsForeignKey IS RECORD(
Fact_Name VARCHAR2(240),
Foreign_Key VARCHAR2(240),
Dimension_Name VARCHAR2(240),
Level_Name VARCHAR2(240),
Dimension_Set VARCHAR2(240),
properties tab_ClsProperties);
TYPE tab_ClsForeignKey  IS TABLE OF ClsForeignKey INDEX BY PLS_INTEGER;

TYPE ClsDimension IS RECORD(
Dimension_Name VARCHAR2(240),
Dimension_Type VARCHAR2(30),
Application_short_name VARCHAR2(30),
Hierarchies tab_clsHierarchy,
properties tab_ClsProperties);
TYPE tab_ClsDimension  IS TABLE OF ClsDimension INDEX BY PLS_INTEGER;



TYPE ClsMeasure IS RECORD(
--Fact_Name VARCHAR2(240),
Measure_ID NUMBER,
Measure_Name VARCHAR2(240),
Measure_Type VARCHAR2(240),
Measure_Group VARCHAR2(240),
measure_source VARCHAR2(30),
Description VARCHAR2(240),
datatype VARCHAR2(30),
aggregation_method VARCHAR2(1000),
Properties tab_ClsProperties);
TYPE tab_ClsMeasure IS TABLE OF ClsMeasure INDEX BY PLS_INTEGER;


TYPE ClsCalendar IS RECORD(
Calendar_id NUMBER,
Calendar_Name VARCHAR2(240),
properties tab_ClsProperties);
TYPE tab_ClsCalendar IS TABLE OF ClsCalendar INDEX BY PLS_INTEGER;


TYPE ClsPeriodicity IS RECORD(
Periodicity_id NUMBER,
Periodicity_Name VARCHAR2(240),
periodicity_type NUMBER,
Calendar_id NUMBER,
Parent_periods dbms_sql.varchar2_table,
properties tab_ClsProperties);
TYPE tab_ClsPeriodicity IS TABLE OF ClsPeriodicity INDEX BY PLS_INTEGER;

TYPE clsNUMBERV IS RECORD
(value number);
TYPE tab_clsNumberV IS TABLE OF clsNumberV INDEX BY VARCHAR2(100);


TYPE clsPartitionInfo IS RECORD
(partition_name VARCHAR2(100),
 partition_value VARCHAR2(4000),
 partition_position number);

TYPE tab_clsPartitionInfo IS TABLE OF clsPartitionInfo INDEX BY PLS_INTEGER;

TYPE clsTablePartition IS RECORD
(table_name VARCHAR2(100),
 partitioning_type VARCHAR2(100),
 partition_count NUMBER,
 partitioning_column VARCHAR2(100),
 partitioning_column_datatype VARCHAR2(100),
 partition_info tab_clsPartitionInfo);

TYPE clsColumnMaps IS RECORD
(column_name VARCHAR2(100),
 source_column_name VARCHAR2(100));

TYPE tab_clsColumnMaps IS TABLE OF clsColumnMaps INDEX BY PLS_INTEGER;

END BSC_DBGEN_STD_METADATA;

 

/
