--------------------------------------------------------
--  DDL for Package Body RG_XFER_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_XFER_COMPONENTS_PKG" as
/* $Header: rgixcmpb.pls 120.6 2006/03/06 22:08:02 vtreiger ship $ */


  /*** Variables ***/

  G_Error        NUMBER;
  G_Warning      NUMBER;

  G_SourceCOAId  NUMBER;
  G_TargetCOAId  NUMBER;
  G_LinkName     VARCHAR2(100);
  G_ApplId       NUMBER;

  /* Message Levels */
  G_ML_Minimal  NUMBER;
  G_ML_Normal   NUMBER;
  G_ML_Full     NUMBER;

  G_AxisSet      VARCHAR2(60);
  G_RowOrder     VARCHAR2(60);
  G_ContentSet   VARCHAR2(60);
  G_DisplayGroup VARCHAR2(60);
  G_DisplaySet   VARCHAR2(60);
  G_Report       VARCHAR2(60);
  G_ReportSet    VARCHAR2(60);
  G_AxisType     VARCHAR2(60);

  /* These tables contain the list of components copied for this particular
   * run. The list is required so that we can distinguish between the
   * components copied in this run, and the components that existed before
   * the run. The lists are checked by the copy_<component> routines.
   * For each list, there is a count (index). */
  ColumnSetList     RG_XFER_UTILS_PKG.ListType;
  ColumnSetCount    BINARY_INTEGER := 0;
  ContentSetList    RG_XFER_UTILS_PKG.ListType;
  ContentSetCount   BINARY_INTEGER := 0;
  DisplayGroupList  RG_XFER_UTILS_PKG.ListType;
  DisplayGroupCount BINARY_INTEGER := 0;
  DisplaySetList    RG_XFER_UTILS_PKG.ListType;
  DisplaySetCount   BINARY_INTEGER := 0;
  ReportList        RG_XFER_UTILS_PKG.ListType;
  ReportCount       BINARY_INTEGER := 0;
  ReportSetList     RG_XFER_UTILS_PKG.ListType;
  ReportSetCount    BINARY_INTEGER := 0;
  RowOrderList      RG_XFER_UTILS_PKG.ListType;
  RowOrderCount     BINARY_INTEGER := 0;
  RowSetList        RG_XFER_UTILS_PKG.ListType;
  RowSetCount       BINARY_INTEGER := 0;


  /* Strings to select from the source database and insert into the
   * target database. */

  AxisSetsString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_AXIS_SETS (' ||
    '  APPLICATION_ID, AXIS_SET_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY' ||
    ', LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, NAME, AXIS_SET_TYPE' ||
    ', SECURITY_FLAG, DISPLAY_IN_LIST_FLAG, PERIOD_SET_NAME, DESCRIPTION' ||
    ', COLUMN_SET_HEADER, ROW_SET_TITLE, SEGMENT_NAME, ID_FLEX_CODE' ||
    ', STRUCTURE_ID, CONTEXT   , ATTRIBUTE1 , ATTRIBUTE2 ' ||
    ', ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6 ' ||
    ', ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 , ATTRIBUTE10' ||
    ', ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14' ||
    ', ATTRIBUTE15, TAXONOMY_ID' ||
    ') SELECT' ||
    '  APPLICATION_ID, :id     , SYSDATE    , :user_id' ||
    ', :login_id  , SYSDATE    , :user_id   , NAME     , AXIS_SET_TYPE' ||
    ', ''N'', DISPLAY_IN_LIST_FLAG, PERIOD_SET_NAME, DESCRIPTION' ||
    ', null       , ROW_SET_TITLE, SEGMENT_NAME, ID_FLEX_CODE' ||
    ', :coa_id    , CONTEXT    , ATTRIBUTE1 , ATTRIBUTE2 ' ||
    ', ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6 ' ||
    ', ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 , ATTRIBUTE10' ||
    ', ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14' ||
    ', ATTRIBUTE15, :tax_id  ' ||
    'FROM RG_REPORT_AXIS_SETS@';

  ContentSetsString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_CONTENT_SETS (' ||
    '  APPLICATION_ID   , CONTENT_SET_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY' ||
    ', LAST_UPDATE_LOGIN, CREATION_DATE , CREATED_BY      , NAME        ' ||
    ', REPORT_RUN_TYPE  , ID_FLEX_CODE  , STRUCTURE_ID    , DESCRIPTION ' ||
    ', CONTEXT          , ATTRIBUTE1    , ATTRIBUTE2      , ATTRIBUTE3  ' ||
    ', ATTRIBUTE4       , ATTRIBUTE5    , ATTRIBUTE6      , ATTRIBUTE7  ' ||
    ', ATTRIBUTE8       , ATTRIBUTE9    , ATTRIBUTE10     , ATTRIBUTE11 ' ||
    ', ATTRIBUTE12      , ATTRIBUTE13   , ATTRIBUTE14     , ATTRIBUTE15 ' ||
    ', SECURITY_FLAG ) SELECT            ' ||
    '  APPLICATION_ID   , :id           , SYSDATE         , :user_id    ' ||
    ', :login_id        , SYSDATE       , :user_id        , NAME        ' ||
    ', REPORT_RUN_TYPE  , ID_FLEX_CODE  , :coa_id         , DESCRIPTION ' ||
    ', CONTEXT          , ATTRIBUTE1    , ATTRIBUTE2      , ATTRIBUTE3  ' ||
    ', ATTRIBUTE4       , ATTRIBUTE5    , ATTRIBUTE6      , ATTRIBUTE7  ' ||
    ', ATTRIBUTE8       , ATTRIBUTE9    , ATTRIBUTE10     , ATTRIBUTE11 ' ||
    ', ATTRIBUTE12      , ATTRIBUTE13   , ATTRIBUTE14     , ATTRIBUTE15 ' ||
    ', ''N''   FROM RG_REPORT_CONTENT_SETS@';

  DisplayGroupsString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_DISPLAY_GROUPS (' ||
    '  REPORT_DISPLAY_GROUP_ID, NAME    , CREATION_DATE    , CREATED_BY   ' ||
    ', LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, FROM_SEQUENCE' ||
    ', TO_SEQUENCE, DESCRIPTION, ROW_SET_ID , COLUMN_SET_ID' ||
    ', CONTEXT    , ATTRIBUTE1 , ATTRIBUTE2 , ATTRIBUTE3 ' ||
    ', ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6 , ATTRIBUTE7 ' ||
    ', ATTRIBUTE8 , ATTRIBUTE9 , ATTRIBUTE10, ATTRIBUTE11' ||
    ', ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15' ||
    ') SELECT' ||
    '  :id        , NAME       , SYSDATE    , :user_id     ' ||
    ', SYSDATE    , :user_id   , :login_id  , FROM_SEQUENCE' ||
    ', TO_SEQUENCE, DESCRIPTION, :row_set_id , :column_set_id' ||
    ', CONTEXT    , ATTRIBUTE1 , ATTRIBUTE2 , ATTRIBUTE3   ' ||
    ', ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6 , ATTRIBUTE7   ' ||
    ', ATTRIBUTE8 , ATTRIBUTE9 , ATTRIBUTE10, ATTRIBUTE11  ' ||
    ', ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15  ' ||
    'FROM RG_REPORT_DISPLAY_GROUPS@';

  DisplaysString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_DISPLAYS (' ||
    '  REPORT_DISPLAY_ID, REPORT_DISPLAY_SET_ID, SEQUENCE, CREATION_DATE ' ||
    ', CREATED_BY  , LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN' ||
    ', DISPLAY_FLAG, ROW_GROUP_ID, COLUMN_GROUP_ID, DESCRIPTION' ||
    ', CONTEXT     , ATTRIBUTE1  , ATTRIBUTE2     , ATTRIBUTE3 ' ||
    ', ATTRIBUTE4  , ATTRIBUTE5  , ATTRIBUTE6     , ATTRIBUTE7 ' ||
    ', ATTRIBUTE8  , ATTRIBUTE9  , ATTRIBUTE10    , ATTRIBUTE11' ||
    ', ATTRIBUTE12 , ATTRIBUTE13 , ATTRIBUTE14    , ATTRIBUTE15' ||
    ') SELECT' ||
    '  rg_report_displays_s.nextval, :id, SEQUENCE, SYSDATE     ' ||
    ', :user_id    , SYSDATE     , :user_id       , :login_id   ' ||
    ', DISPLAY_FLAG,:row_group_id,:column_group_id, DESCRIPTION ' ||
    ', CONTEXT     , ATTRIBUTE1  , ATTRIBUTE2     , ATTRIBUTE3  ' ||
    ', ATTRIBUTE4  , ATTRIBUTE5  , ATTRIBUTE6     , ATTRIBUTE7  ' ||
    ', ATTRIBUTE8  , ATTRIBUTE9  , ATTRIBUTE10    , ATTRIBUTE11 ' ||
    ', ATTRIBUTE12 , ATTRIBUTE13 , ATTRIBUTE14    , ATTRIBUTE15 ' ||
    'FROM RG_REPORT_DISPLAYS@';

  DisplaySetsString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_DISPLAY_SETS (' ||
    '  REPORT_DISPLAY_SET_ID, NAME  , CREATION_DATE, CREATED_BY' ||
    ', LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ROW_SET_ID'||
    ', COLUMN_SET_ID, DESCRIPTION, CONTEXT    , ATTRIBUTE1 ' ||
    ', ATTRIBUTE2   , ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 ' ||
    ', ATTRIBUTE6   , ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 ' ||
    ', ATTRIBUTE10  , ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13' ||
    ', ATTRIBUTE14  , ATTRIBUTE15'                           ||
    ') SELECT ' ||
    '  :id         , NAME, SYSDATE, :user_id' ||
    ', SYSDATE     , :user_id   , :login_id  , :row_set_id' ||
    ', :column_set_id, DESCRIPTION , CONTEXT , ATTRIBUTE1 ' ||
    ', ATTRIBUTE2  , ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 ' ||
    ', ATTRIBUTE6  , ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 ' ||
    ', ATTRIBUTE10 , ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13' ||
    ', ATTRIBUTE14 , ATTRIBUTE15 '                          ||
    'FROM RG_REPORT_DISPLAY_SETS@';

  ReportParametersString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_PARAMETERS (' ||
    '  PARAMETER_SET_ID, LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN' ||
    ', CREATION_DATE   , CREATED_BY      , PARAMETER_NUM , DATA_TYPE  ' ||
    ', PARAMETER_ID    , ENTERED_CURRENCY, CURRENCY_TYPE , LEDGER_CURRENCY' ||
    ', PERIOD_NUM      , FISCAL_YEAR_OFFSET ' ||
    ', CONTEXT         , ATTRIBUTE1      , ATTRIBUTE2    , ATTRIBUTE3 ' ||
    ', ATTRIBUTE4      , ATTRIBUTE5      , ATTRIBUTE6    , ATTRIBUTE7 ' ||
    ', ATTRIBUTE8      , ATTRIBUTE9      , ATTRIBUTE10   , ATTRIBUTE11' ||
    ', ATTRIBUTE12     , ATTRIBUTE13     , ATTRIBUTE14   , ATTRIBUTE15' ||
    ') SELECT' ||
    '  :id             , SYSDATE         , :user_id      , :login_id  ' ||
    ', SYSDATE         , :user_id        , PARAMETER_NUM , DATA_TYPE  ' ||
    ', :parameter_id   , ENTERED_CURRENCY, CURRENCY_TYPE , LEDGER_CURRENCY' ||
    ', PERIOD_NUM      , FISCAL_YEAR_OFFSET ' ||
    ', CONTEXT         , ATTRIBUTE1      , ATTRIBUTE2    , ATTRIBUTE3 ' ||
    ', ATTRIBUTE4      , ATTRIBUTE5      , ATTRIBUTE6    , ATTRIBUTE7 ' ||
    ', ATTRIBUTE8      , ATTRIBUTE9      , ATTRIBUTE10   , ATTRIBUTE11' ||
    ', ATTRIBUTE12     , ATTRIBUTE13     , ATTRIBUTE14   , ATTRIBUTE15 '||
    'FROM RG_REPORT_PARAMETERS@';

  ReportRequestsString VARCHAR2(3000) :=
    'INSERT INTO RG_REPORT_REQUESTS (' ||
    '  APPLICATION_ID, REPORT_REQUEST_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY' ||
    ', LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, REPORT_ID ' ||
    ', SEQUENCE, FORM_SUBMISSION_FLAG, CONCURRENT_REQUEST_ID, REPORT_SET_ID' ||
    ', CONTENT_SET_ID, ROW_ORDER_ID, EXCEPTIONS_FLAG, ROUNDING_OPTION      ' ||
    ', LEDGER_ID, ALC_LEDGER_CURRENCY, REPORT_DISPLAY_SET_ID, ID_FLEX_CODE ' ||
    ', STRUCTURE_ID, SEGMENT_OVERRIDE, OVERRIDE_ALC_LEDGER_CURRENCY ' ||
    ', PERIOD_NAME, UNIT_OF_MEASURE_ID, CONTEXT' ||
    ', ATTRIBUTE1 , ATTRIBUTE2 , ATTRIBUTE3 , ATTRIBUTE4 ' ||
    ', ATTRIBUTE5 , ATTRIBUTE6 , ATTRIBUTE7 , ATTRIBUTE8 ' ||
    ', ATTRIBUTE9 , ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12' ||
    ', ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, RUNTIME_OPTION_CONTEXT' ||
    ', ACCOUNTING_DATE, OUTPUT_OPTION' ||
    ') SELECT' ||
    '  APPLICATION_ID, rg_report_requests_s.nextval, SYSDATE    , :user_id' ||
    ', :login_id  , SYSDATE    , :user_id   , :report_id' ||
    ', SEQUENCE   , FORM_SUBMISSION_FLAG, null, :id' ||
    ', null       , null       , ''N''      , ''C''' ||
    ', null       , null       , null       , ID_FLEX_CODE ' ||
    ', :coa_id    , null       , null ' ||
    ', null       , null       , CONTEXT    ' ||
    ', ATTRIBUTE1 , ATTRIBUTE2 , ATTRIBUTE3 , ATTRIBUTE4 ' ||
    ', ATTRIBUTE5 , ATTRIBUTE6 , ATTRIBUTE7 , ATTRIBUTE8 ' ||
    ', ATTRIBUTE9 , ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12' ||
    ', ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, RUNTIME_OPTION_CONTEXT' ||
    ', null, NVL(OUTPUT_OPTION, ''R'') ' ||
    'FROM RG_REPORT_REQUESTS@';

  ReportsString VARCHAR2(3000) :=
    'INSERT INTO RG_REPORTS (' ||
    '  APPLICATION_ID   , REPORT_ID    , LAST_UPDATE_DATE, LAST_UPDATED_BY ' ||
    ', LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY , NAME, SECURITY_FLAG ' ||
    ', REPORT_TITLE, ROW_SET_ID, COLUMN_SET_ID, ROUNDING_OPTION ' ||
    ', OUTPUT_OPTION , CONTENT_SET_ID , ROW_ORDER_ID ' ||
    ', PARAMETER_SET_ID , UNIT_OF_MEASURE_ID, ID_FLEX_CODE , STRUCTURE_ID '||
    ', SEGMENT_OVERRIDE , OVERRIDE_ALC_LEDGER_CURRENCY , PERIOD_SET_NAME ' ||
    ', MINIMUM_DISPLAY_LEVEL, DESCRIPTION, CONTEXT       , ATTRIBUTE1 ' ||
    ', ATTRIBUTE2       , ATTRIBUTE3   , ATTRIBUTE4      , ATTRIBUTE5 ' ||
    ', ATTRIBUTE6       , ATTRIBUTE7   , ATTRIBUTE8      , ATTRIBUTE9 ' ||
    ', ATTRIBUTE10      , ATTRIBUTE11  , ATTRIBUTE12     , ATTRIBUTE13' ||
    ', ATTRIBUTE14      , ATTRIBUTE15  , REPORT_DISPLAY_SET_ID        ' ||
    ') SELECT' ||
    '  APPLICATION_ID   , :id          , SYSDATE         , :user_id' ||
    ', :login_id        , SYSDATE      , :user_id , NAME , ''N'' ' ||
    ', REPORT_TITLE     , :row_set_id  , :column_set_id  , ROUNDING_OPTION'||
    ', NVL(OUTPUT_OPTION,''R''), :content_set_id, :row_order_id ' ||
    ', :parameter_set_id, :currency_code , ID_FLEX_CODE  , :coa_id ' ||
    ', :segment_override, :override_alc_ledger_currency  , PERIOD_SET_NAME ' ||
    ', MINIMUM_DISPLAY_LEVEL, DESCRIPTION, CONTEXT       , ATTRIBUTE1 ' ||
    ', ATTRIBUTE2       , ATTRIBUTE3   , ATTRIBUTE4      , ATTRIBUTE5 ' ||
    ', ATTRIBUTE6       , ATTRIBUTE7   , ATTRIBUTE8      , ATTRIBUTE9 ' ||
    ', ATTRIBUTE10      , ATTRIBUTE11  , ATTRIBUTE12     , ATTRIBUTE13' ||
    ', ATTRIBUTE14      , ATTRIBUTE15  , :display_set_id ' ||
    'FROM RG_REPORTS@';

  ReportSetsString VARCHAR2(2000) :=
    'INSERT INTO RG_REPORT_SETS (' ||
    '  APPLICATION_ID, REPORT_SET_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY' ||
    ', LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, NAME, SECURITY_FLAG ' ||
    ', ID_FLEX_CODE,PERIOD_TYPE, PERIOD_NAME, STRUCTURE_ID' ||
    ', DESCRIPTION, CONTEXT    , ATTRIBUTE1 , ATTRIBUTE2  ' ||
    ', ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6  ' ||
    ', ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 , ATTRIBUTE10 ' ||
    ', ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14 ' ||
    ', ATTRIBUTE15, UNIT_OF_MEASURE_ID' ||
    ') SELECT' ||
    '  APPLICATION_ID, :id     , SYSDATE    , :user_id    ' ||
    ', :login_id  , SYSDATE    , :user_id   , NAME        , ''N'' ' ||
    ', ID_FLEX_CODE,PERIOD_TYPE, PERIOD_NAME, :coa_id     ' ||
    ', DESCRIPTION, CONTEXT    , ATTRIBUTE1 , ATTRIBUTE2  ' ||
    ', ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6  ' ||
    ', ATTRIBUTE7 , ATTRIBUTE8 , ATTRIBUTE9 , ATTRIBUTE10 ' ||
    ', ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14 ' ||
    ', ATTRIBUTE15, UNIT_OF_MEASURE_ID ' ||
    'FROM RG_REPORT_SETS@';

  RowOrdersString VARCHAR2(2000) :=
    'INSERT INTO RG_ROW_ORDERS (' ||
    '  APPLICATION_ID   , ROW_ORDER_ID , LAST_UPDATE_DATE, LAST_UPDATED_BY' ||
    ', LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY      , NAME        ' ||
    ', SECURITY_FLAG    , ROW_RANK_TYPE, ID_FLEX_CODE    , STRUCTURE_ID' ||
    ', DESCRIPTION      , COLUMN_NUMBER, COLUMN_NAME     , CONTEXT ' ||
    ', ATTRIBUTE1       , ATTRIBUTE2   , ATTRIBUTE3      , ATTRIBUTE4  ' ||
    ', ATTRIBUTE5       , ATTRIBUTE6   , ATTRIBUTE7      , ATTRIBUTE8  ' ||
    ', ATTRIBUTE9       , ATTRIBUTE10  , ATTRIBUTE11     , ATTRIBUTE12 ' ||
    ', ATTRIBUTE13      , ATTRIBUTE14  , ATTRIBUTE15 ' ||
    ') SELECT ' ||
    '  APPLICATION_ID   , :id          , SYSDATE         , :user_id    ' ||
    ', :login_id        , SYSDATE      , :user_id        , NAME        ' ||
    ', ''N''            , ROW_RANK_TYPE, ID_FLEX_CODE    , :coa_id     ' ||
    ', DESCRIPTION      , COLUMN_NUMBER, :column_name    , CONTEXT     ' ||
    ', ATTRIBUTE1       , ATTRIBUTE2   , ATTRIBUTE3      , ATTRIBUTE4  ' ||
    ', ATTRIBUTE5       , ATTRIBUTE6   , ATTRIBUTE7      , ATTRIBUTE8  ' ||
    ', ATTRIBUTE9       , ATTRIBUTE10  , ATTRIBUTE11     , ATTRIBUTE12 ' ||
    ', ATTRIBUTE13      , ATTRIBUTE14  , ATTRIBUTE15 ' ||
    'FROM RG_ROW_ORDERS@';

  RowSegmentSequencesString VARCHAR2(2000) :=
    'INSERT INTO RG_ROW_SEGMENT_SEQUENCES (' ||
    '  APPLICATION_ID  , ROW_ORDER_ID    , ROW_SEGMENT_SEQUENCE_ID' ||
    ', LAST_UPDATE_DATE, LAST_UPDATED_BY , LAST_UPDATE_LOGIN' ||
    ', CREATION_DATE   , CREATED_BY      , SEGMENT_SEQUENCE ' ||
    ', SEG_ORDER_TYPE  , SEG_DISPLAY_TYPE, STRUCTURE_ID     ' ||
    ', SEGMENT_NAME    , SEGMENT_WIDTH   , CONTEXT    , ATTRIBUTE1 ' ||
    ', ATTRIBUTE2      , ATTRIBUTE3      , ATTRIBUTE4 , ATTRIBUTE5 ' ||
    ', ATTRIBUTE6      , ATTRIBUTE7      , ATTRIBUTE8 , ATTRIBUTE9 ' ||
    ', ATTRIBUTE10     , ATTRIBUTE11     , ATTRIBUTE12, ATTRIBUTE13' ||
    ', ATTRIBUTE14     , ATTRIBUTE15     , APPLICATION_COLUMN_NAME ' ||
    ') SELECT' ||
    '  APPLICATION_ID  , :id           , rg_row_segment_sequences_s.nextval' ||
    ', sysdate         , :user_id        , :login_id' ||
    ', sysdate         , :user_id        , SEGMENT_SEQUENCE' ||
    ', SEG_ORDER_TYPE  , SEG_DISPLAY_TYPE, :coa_id  ' ||
    ', SEGMENT_NAME    , SEGMENT_WIDTH   , CONTEXT    , ATTRIBUTE1 ' ||
    ', ATTRIBUTE2      , ATTRIBUTE3      , ATTRIBUTE4 , ATTRIBUTE5 ' ||
    ', ATTRIBUTE6      , ATTRIBUTE7      , ATTRIBUTE8 , ATTRIBUTE9 ' ||
    ', ATTRIBUTE10     , ATTRIBUTE11     , ATTRIBUTE12, ATTRIBUTE13' ||
    ', ATTRIBUTE14     , ATTRIBUTE15     , APPLICATION_COLUMN_NAME ' ||
    'FROM RG_ROW_SEGMENT_SEQUENCES@';


/*** Prototypes for local routines ***/

PROCEDURE copy_single_component(
            ComponentType VARCHAR2,
            ComponentName VARCHAR2,
            CheckExistence BOOLEAN DEFAULT TRUE);

FUNCTION copy_axis_set(
           ComponentType VARCHAR2,
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

FUNCTION copy_content_set(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

FUNCTION copy_row_order(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

FUNCTION copy_display_set(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

FUNCTION copy_display_group(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

FUNCTION copy_report(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

FUNCTION copy_report_set(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER;

PROCEDURE copy_display_set_details(
            SourceDisplaySetId NUMBER,
            TargetDisplaySetId NUMBER);

PROCEDURE copy_report_set_details(
           SourceReportSetId NUMBER,
           TargetReportSetId NUMBER);

PROCEDURE transfer_taxonomy(
            parent_tax_alias IN VARCHAR2,
            parent_tax_id    IN NUMBER,
            parent_done_flag IN OUT NOCOPY NUMBER);

FUNCTION copy_report_details(ReportId NUMBER) RETURN NUMBER;



/* Name:  init
 * Desc:  Initialize some variables that are used in this package.
 *
 * Notes: This procedure is called by RG_XFER_UTILS_PKG.init
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE init(
            SourceCOAId NUMBER,
            TargetCOAId NUMBER,
            LinkName    VARCHAR2,
            ApplId      NUMBER) IS
BEGIN
  G_SourceCOAId := SourceCOAId;
  G_TargetCOAId := TargetCOAId;
  G_LinkName    := LinkName;
  G_ApplId      := ApplId;

  /* Iniitialize the PRIVATE package */
  RG_XFER_COMP_PRIVATE_PKG.init(SourceCOAId, TargetCOAId, LinkName, ApplId);
END init;


/* Name:  print_stats
 * Desc:  Print transfer statistics.
 *
 * History:
 *   03/05/96   S Rahman   Created.
 */
PROCEDURE print_stats IS
  TotalCount BINARY_INTEGER := 0;
BEGIN
  TotalCount := ColumnSetCount + ContentSetCount + DisplayGroupCount +
                DisplaySetCount + ReportCount + ReportSetCount +
                RowOrderCount + RowSetCount;
  RG_XFER_UTILS_PKG.display_message(
    MsgName     => 'RG_XFER_STATS_1',
    Token1      => 'ROW_SET_COUNT',
    Token1Val   => TO_CHAR(RowSetCount),
    Token1Xlate => FALSE,
    Token2      => 'COLUMN_SET_COUNT',
    Token2Val   => TO_CHAR(ColumnSetCount),
    Token2Xlate => FALSE,
    Token3      => 'CONTENT_SET_COUNT',
    Token3Val   => TO_CHAR(ContentSetCount),
    Token3Xlate => FALSE,
    Token4      => 'ROW_ORDER_COUNT',
    Token4Val   => TO_CHAR(RowOrderCount),
    Token4Xlate => FALSE
    );
  RG_XFER_UTILS_PKG.display_message(
    MsgName     => 'RG_XFER_STATS_2',
    Token1      => 'DISPLAY_GROUP_COUNT',
    Token1Val   => TO_CHAR(DisplayGroupCount),
    Token1Xlate => FALSE,
    Token2      => 'DISPLAY_SET_COUNT',
    Token2Val   => TO_CHAR(DisplaySetCount),
    Token2Xlate => FALSE,
    Token3      => 'REPORT_COUNT',
    Token3Val   => TO_CHAR(ReportCount),
    Token3Xlate => FALSE,
    Token4      => 'REPORT_SET_COUNT',
    Token4Val   => TO_CHAR(ReportSetCount),
    Token4Xlate => FALSE,
    Token5      => 'TOTAL_COUNT',
    Token5Val   => TO_CHAR(TotalCount),
    Token5Xlate => FALSE
    );
END print_stats;


/* Name:  copy_component
 * Desc:  Copies the specified component. If the component type is specified,
 *        then it copies that particulart component. If the component type
 *        is NULL, then it copies all FSG components.
 *
 *        This routine is essentially a wrapper around copy_single_component.
 *        copy_single_component does all the work.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE copy_component(
            ComponentType VARCHAR2,
            ComponentName VARCHAR2) IS
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_component',
    Token2    => 'PARAM1',
    Token2Val => ComponentType,
    Token3    => 'PARAM2',
    Token3Val => ComponentName);

  IF (ComponentType = 'RG_ALL') THEN
    /* Copy everything */
    copy_single_component('RG_ROW_SET'      , '');
    copy_single_component('RG_COLUMN_SET'   , '');
    copy_single_component('RG_ROW_ORDER'    , '');
    copy_single_component('RG_CONTENT_SET'  , '');
    copy_single_component('RG_DISPLAY_GROUP', '');
    copy_single_component('RG_DISPLAY_SET'  , '');
    copy_single_component('RG_REPORT'       , '');
    copy_single_component('RG_REPORT_SET'   , '');
  ELSE
    /* Copy a particular component. */
    copy_single_component(ComponentType, ComponentName);
  END IF;

  /* Print transfer statistics */
  print_stats;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_component');
END copy_component;


/* Name:  copy_single_component
 * Desc:  Copies the specified component. It checks the component type
 *        and calls the appropriate routine to copy the component. If
 *        a component name is specified, then it copies that particular
 *        component. If component name is NULL, then it copies all
 *        components of that particular component type. If a wildcard
 *        character (%) is specified in the component name, then copy
 *        the components that match the specified pattern.
 *
 * Notes: ComponentType MUST have a valid value.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE copy_single_component(
            ComponentType VARCHAR2,
            ComponentName VARCHAR2,
            CheckExistence BOOLEAN DEFAULT TRUE) IS
  Id           NUMBER;
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  TableName    VARCHAR2(50) := NULL;
  WhereClause  VARCHAR2(500) := NULL;
  CompName     VARCHAR2(30);
  SQLString    VARCHAR2(700) := 'SELECT name FROM ';
  ApplIdStr    VARCHAR2(10) := NULL;  /* Enables/disables index on appl_id */
  NameStr      VARCHAR2(100) := NULL; /* 'name like' part in where clause */
  DispNameStr  VARCHAR2(100) := NULL; /* 'name like' part for disp set/group */
  ErrorNum     NUMBER;
  ErrorMsg     VARCHAR2(512);
  AdjustedName VARCHAR2(60) := NULL;
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_single_component',
    Token2    => 'PARAM1',
    Token2Val => ComponentType,
    Token3    => 'PARAM2',
    Token3Val => ComponentName);

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Check for wildcard character (%) and set up strings */
  IF (ComponentName IS NOT NULL) THEN
    IF (INSTR(ComponentName, '%', 1) = 0) THEN
      /* No percent sign */
      ApplIdStr := '+0';    /* Disable index */
      NameStr := NULL;
      DispNameStr := NULL;
    ELSE
      /* There is a percent sign; wildcard query */
      ApplIdStr := NULL;    /* Enable index */
      NameStr := ' AND (name LIKE ''' || AdjustedName || ''')';
      DispNameStr := ' WHERE (name LIKE ''' || AdjustedName || ''')';
    END IF;
  END IF;

  IF ((ComponentName IS NOT NULL) AND (NameStr IS NULL)) THEN
    /* A simple component name has been specified. Copy it. */

    /* Set save point */
    SAVEPOINT new_component;

    /* Initialize id */
    Id := G_Error;

    /* Print starting to process message */
    RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
    RG_XFER_UTILS_PKG.display_message(
      MsgName     => 'RG_XFER_PROCESSING',
      Token1      => 'COMP_TYPE',
      Token1Val   => ComponentType,
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

    /* Call the appropriate routine to copy the component */
    IF (ComponentType = 'RG_ROW_SET') THEN
      Id := copy_axis_set(ComponentType, ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_COLUMN_SET') THEN
      Id := copy_axis_set(ComponentType, ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_CONTENT_SET') THEN
      Id := copy_content_set(ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_ROW_ORDER') THEN
      Id := copy_row_order(ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_DISPLAY_SET') THEN
      Id := copy_display_set(ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_DISPLAY_GROUP') THEN
      Id := copy_display_group(ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_REPORT') THEN
      Id := copy_report(ComponentName, CheckExistence);
    ELSIF (ComponentType = 'RG_REPORT_SET') THEN
      Id := copy_report_set(ComponentName, CheckExistence);
    ELSE
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => ComponentType);
    END IF;

    /* Commit or rollback depending on results from copy. */
    IF (Id = G_Error) THEN
      ROLLBACK;
      RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_ROLLBACK',
        Token1      => 'COMP_TYPE',
        Token1Val   => ComponentType,
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
    ELSIF (Id = G_Warning) THEN
      COMMIT;
      RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
      RG_XFER_UTILS_PKG.display_warning(
        MsgName     => 'RG_XFER_WARNING',
        Token1      => 'COMP_TYPE',
        Token1Val   => ComponentType,
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
    ELSE
      COMMIT;
      RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
      RG_XFER_UTILS_PKG.display_message(
        MsgName     => 'RG_XFER_COMMIT',
        Token1      => 'COMP_TYPE',
        Token1Val   => ComponentType,
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
    END IF;

  ELSE
    /* A wildcard character or string for all components has been specified.
     * Copy the specified components of ComponentType. Do this by querying the
     * specified names of ComponentType, e.g., all specified row set names.
     * Then copy each component individually by calling copy_single_component
     * recursively. */

    /* Set the table name to use in the query */
    IF (ComponentType = 'RG_ROW_SET') THEN
      TableName := 'RG_REPORT_AXIS_SETS';
      WhereClause := ' WHERE AXIS_SET_TYPE = ''R''' ||
                     ' AND   (STRUCTURE_ID IS NULL' ||
                         ' OR STRUCTURE_ID = ' ||TO_CHAR(G_SourceCOAId)||')'||
                     ' AND   (application_id' || ApplIdStr || '=' ||
                        TO_CHAR(G_ApplId) || ')' || NameStr;
    ELSIF (ComponentType = 'RG_COLUMN_SET') THEN
      TableName := 'RG_REPORT_AXIS_SETS';
      WhereClause := ' WHERE AXIS_SET_TYPE = ''C''' ||
                     ' AND   (STRUCTURE_ID IS NULL' ||
                         ' OR STRUCTURE_ID = ' ||TO_CHAR(G_SourceCOAId)||')'||
                     ' AND   ((application_id' || ApplIdStr || ' = 168)' ||
                     '     OR (application_id' || ApplIdStr || ' = ' ||
                        TO_CHAR(G_ApplId)||'))' || NameStr;
    ELSIF (ComponentType = 'RG_CONTENT_SET') THEN
      TableName := 'RG_REPORT_CONTENT_SETS';
      WhereClause := ' WHERE structure_id = ' || TO_CHAR(G_SourceCOAId) ||
                     ' AND   application_id' || ApplIdStr || ' = ' ||
                        TO_CHAR(G_ApplId) || NameStr;
    ELSIF (ComponentType = 'RG_ROW_ORDER') THEN
      TableName := 'RG_ROW_ORDERS';
      WhereClause := ' WHERE STRUCTURE_ID = ' || TO_CHAR(G_SourceCOAId) ||
                     ' AND   application_id' || ApplIdStr || ' = ' ||
                        TO_CHAR(G_ApplId) || NameStr;
    ELSIF (ComponentType = 'RG_DISPLAY_SET') THEN
      TableName := 'RG_REPORT_DISPLAY_SETS';
      WhereClause := DispNameStr;
    ELSIF (ComponentType = 'RG_DISPLAY_GROUP') THEN
      TableName := 'RG_REPORT_DISPLAY_GROUPS';
      WhereClause := DispNameStr;
    ELSIF (ComponentType = 'RG_REPORT') THEN
      TableName := 'RG_REPORTS';
      WhereClause := ' WHERE STRUCTURE_ID = ' || TO_CHAR(G_SourceCOAId) ||
                     ' AND   application_id' || ApplIdStr || ' = ' ||
                        TO_CHAR(G_ApplId) || NameStr;
    ELSIF (ComponentType = 'RG_REPORT_SET') THEN
      TableName := 'RG_REPORT_SETS';
      WhereClause := ' WHERE STRUCTURE_ID = ' || TO_CHAR(G_SourceCOAId) ||
                     ' AND   application_id' || ApplIdStr || ' = ' ||
                        TO_CHAR(G_ApplId) || NameStr;
    ELSE
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => ComponentType);
    END IF;

    IF (TableName IS NOT NULL) THEN
      /* Build the SQL stmt to get all name for the specified component */
      SQLString := SQLString || TableName || '@' || G_LinkName || WhereClause;
      RG_XFER_UTILS_PKG.display_string(SQLString);

      /* Execute the SQL stmt */
      CursorId := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
      DBMS_SQL.define_column(CursorId, 1, CompName, 30);
      ExecuteValue := DBMS_SQL.execute(CursorId);
      LOOP
        /* For each component, call the routine recursively to do the copy */
        IF (DBMS_SQL.fetch_rows(CursorId) > 0) THEN
          DBMS_SQL.column_value(CursorId, 1, CompName);
          /* Redundant check to ensure that the name is NOT NULL. If the
           * name is NULL for some reason, then the routine will try to
           * copy all components again, and will cause errors. */
          IF (CompName IS NOT NULL) THEN
            /* Call routine with CheckExistence set to FALSE since
             * we know that the name is valid in the source db. */
            copy_single_component(
              ComponentType,
              CompName,
              CheckExistence => FALSE);
          END IF;
        ELSE
          EXIT;
        END IF;
      END LOOP;

      /* Print messages if no matching rows found */
      IF (DBMS_SQL.last_row_count = 0) THEN
        RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_NO_MATCH_ROWS');
        RG_XFER_UTILS_PKG.display_message(MsgName => 'RG_XFER_BLANK');
      END IF;

      DBMS_SQL.close_cursor(CursorId);

    END IF;
  END IF;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_single_component');

EXCEPTION
  WHEN OTHERS THEN
    /* Display the exception if MsgLevel is at least Normal */
    ErrorNum := SQLCODE;
    ErrorMsg := SUBSTRB(SQLERRM, 1, 512);
    RG_XFER_UTILS_PKG.display_exception(ErrorNum, ErrorMsg);

    /* Rollback the changes and display error message */
    ROLLBACK;
    RG_XFER_UTILS_PKG.display_error(
      MsgName     => 'RG_XFER_ROLLBACK',
      Token1      => 'COMP_TYPE',
      Token1Val   => ComponentType,
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);
    RAISE;

END copy_single_component;


/* Name:  copy_axis_set
 * Desc:  Copies the specified axis set, i.e., row set, or column set.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 *   04/18/03   V Treiger  Modified
 */
FUNCTION copy_axis_set(
            ComponentType VARCHAR2,
            ComponentName VARCHAR2,
            CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId       NUMBER; /* Target component id */
  SourceId       NUMBER; /* Source component id */
  AxisSetType    VARCHAR2(1);
  SQLString      VARCHAR2(5000);
  CheckCOA       NUMBER;
  CheckTargetCOA NUMBER;
  AdjustedName   VARCHAR2(60);

  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  RefObjectName VARCHAR2(240);
  ValueString   VARCHAR2(240);
  TempValue     VARCHAR2(100);
  TaxTargetId   NUMBER; /* Taxonomy Target id */
  TaxSourceId   NUMBER; /* Taxonomy Source id */
  TaxAlias      VARCHAR2(240);
  AdjustedTaxAlias VARCHAR2(240);
  Tax_Done_Flag NUMBER;
  ErrorNum     NUMBER;
  ErrorMsg     VARCHAR2(512);

BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_axis_set',
    Token2    => 'PARAM1',
    Token2Val => ComponentType,
    Token3    => 'PARAM2',
    Token3Val => ComponentName);

  /* Store the name of the component being copied */
  IF (ComponentType = 'RG_ROW_SET') THEN
    G_AxisSet := ComponentName;
    AxisSetType := 'R';
  ELSE
    G_AxisSet := ComponentName;
    AxisSetType := 'C';
  END IF;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          ComponentType, ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => ComponentType,
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Ensure that the COA id of the component matches the source COA id */
  CheckCOA := RG_XFER_UTILS_PKG.check_coa_id(
                'RG_REPORT_AXIS_SETS',
                ComponentName,
                ' AND ((application_id = 168)' ||
                '   OR (application_id = ' || TO_CHAR(G_ApplId) || '))' ||
                ' AND axis_set_type = ''' || AxisSetType || '''');
  IF (CheckCOA = G_Error) THEN
    RG_XFER_UTILS_PKG.display_warning(
      MsgName     => 'RG_XFER_WRONG_COA',
      Token1      => 'COMP_TYPE',
      Token1Val   => ComponentType,
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARN',
      Token1    => 'ROUTINE',
      Token1Val => 'copy_axis_set');
    RETURN(G_Warning);
  END IF;

  /* Begin XBRL related changes */
  /* Check if TAXONOMY_ID is NULL in source db XBRL */
  TaxSourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORT_AXIS_SETS', 'TAXONOMY_ID', ComponentName,
                  ' AND ((application_id = 168)' ||
                      ' OR (application_id = ' || TO_CHAR(G_ApplId) || '))' ||
                  ' AND axis_set_type = ''' || AxisSetType || '''');

  /* IF TAXONOMY_ID is not NULL THEN */
  /* Check if a taxonomy of the same alias already exists in target db XBRL */
  /* ELSE deliver taxonomy of the same URL with all imported taxonomies
     to target db by a call to a recursive procedure transfer_taxonomy */

  IF (TaxSourceId IS NULL) THEN
    TaxAlias := '';
    TaxTargetId := NULL;
  ELSE
    RG_XFER_UTILS_PKG.copy_adjust_string(TempValue, ComponentName);
    ValueString := '''' || TempValue || '''';

    SQLString := 'SELECT ref_table.taxonomy_alias '||
               'FROM RG_REPORT_AXIS_SETS'||'@'||G_LinkName||' main_table,' ||
               ' RG_XBRL_TAXONOMIES' || '@'|| G_LinkName || ' ref_table ' ||
               'WHERE main_table.name' || '='|| ValueString ||
               ' AND main_table.taxonomy_id = ref_table.taxonomy_id';

    RG_XFER_UTILS_PKG.display_string(SQLString);
    CursorId := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
    DBMS_SQL.define_column(CursorId, 1, RefObjectName, 240);
    ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
    IF (ExecuteValue > 0) THEN
      DBMS_SQL.column_value(CursorId, 1, RefObjectName);
    ELSE
      RefObjectName := '';
    END IF;
    DBMS_SQL.close_cursor(CursorId);
    TaxAlias := RefObjectName;

    /* Check if a taxonomy with the same alias already exists in target db */
    RG_XFER_UTILS_PKG.copy_adjust_string(TempValue, TaxAlias);
    ValueString := '''' || TempValue || '''';

    SQLString := 'SELECT taxonomy_id ' ||
               'FROM   rg_xbrl_taxonomies ' ||
               'WHERE  taxonomy_alias = ' || ValueString;
    TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

    IF (TargetId = G_Error) THEN
      /* deliver taxonomy to target db */
      Tax_Done_Flag := 0;
      transfer_taxonomy(TaxAlias,TaxSourceId,Tax_Done_Flag);
    END IF;

    /* Check if a taxonomy with the same alias already exists in target db */
    RG_XFER_UTILS_PKG.copy_adjust_string(TempValue, TaxAlias);
    ValueString := '''' || TempValue || '''';

    SQLString := 'SELECT taxonomy_id ' ||
               'FROM   rg_xbrl_taxonomies ' ||
               'WHERE  taxonomy_alias = ' || ValueString;
    TaxTargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  END IF;
  /* End XBRL related changes */

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT axis_set_id ' ||
               'FROM   rg_report_axis_sets ' ||
               'WHERE  name = ''' || AdjustedName || '''' ||
               'AND    axis_set_type = ''' || AxisSetType || ''''||
               'AND    ((application_id = 168)' ||
               '  OR    (application_id = ' || TO_CHAR(G_ApplId) || '))';
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN

    /* Component doesn't exist in target db. Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_REPORT_AXIS_SETS_S');
    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORT_AXIS_SETS', 'AXIS_SET_ID', ComponentName,
                  ' AND ((application_id = 168)' ||
                      ' OR (application_id = ' || TO_CHAR(G_ApplId) || '))' ||
                  ' AND axis_set_type = ''' || AxisSetType || '''');
    SQLString := AxisSetsString || G_LinkName ||
                 ' WHERE axis_set_id = ' || TO_CHAR(SourceId);

    /* The structure_id in rg_report_axis_sets may or may not have a value.
     * Substitute the token accordingly. */
    IF (CheckCOA = RG_XFER_UTILS_PKG.G_NoCOA) THEN
      RG_XFER_UTILS_PKG.substitute_tokens(
        SQLString, Token1=> ':coa_id', Token1Val=> 'NULL');
    ELSE
      RG_XFER_UTILS_PKG.substitute_tokens(
        SQLString, Token1=> ':coa_id', Token1Val=> TO_CHAR(G_TargetCOAId));
    END IF;

    /* Begin XBRL token substitution for TaxTargetId.
     * Substitute the token accordingly. */
    IF (TaxTargetId IS NULL) THEN
      RG_XFER_UTILS_PKG.substitute_tokens(
        SQLString, Token1=> ':tax_id', Token1Val=> 'NULL');
    ELSE
      RG_XFER_UTILS_PKG.substitute_tokens(
        SQLString, Token1=> ':tax_id', Token1Val=> TO_CHAR(TaxTargetId));
    END IF;
    /* End XBRL token substitution for TaxTargetId. */

    RG_XFER_UTILS_PKG.insert_rows(SQLString, TargetId, UseCOAId => FALSE);

    IF (ComponentType = 'RG_COLUMN_SET') THEN
      RG_XFER_COMP_PRIVATE_PKG.copy_column_set_header(SourceId, TargetId);
    END IF;

    /* Copy axis set detail records */
    RG_XFER_COMP_PRIVATE_PKG.copy_axis_details(
      ComponentType, G_AxisSet, SourceId, TargetId);

    /* New component - insert into the list of components copied */
    IF (ComponentType = 'RG_ROW_SET') THEN
      RG_XFER_UTILS_PKG.insert_into_list(
        RowSetList, RowSetCount, ComponentName);
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_TRANSFERRED',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_ROW_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
    ELSE
      RG_XFER_UTILS_PKG.insert_into_list(
        ColumnSetList, ColumnSetCount, ComponentName);
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_TRANSFERRED',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_COLUMN_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
    END IF;

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (ComponentType = 'RG_ROW_SET') THEN
      IF (RG_XFER_UTILS_PKG.search_list(
            RowSetList, RowSetCount, ComponentName) = G_Error) THEN
        /* Component with same name existed before this run. */

        /* Check if it uses the correct chart of accounts id. */
        CheckTargetCOA :=
          RG_XFER_UTILS_PKG.check_target_coa_id(
            'RG_REPORT_AXIS_SETS',
            ComponentName,
            ' AND ((application_id = 168)' ||
            '   OR (application_id = ' || TO_CHAR(G_ApplId) || '))' ||
            ' AND axis_set_type = ''' || AxisSetType || '''');
        IF (CheckTargetCOA = G_Error) THEN
          RG_XFER_UTILS_PKG.display_warning(
            MsgName     => 'RG_XFER_TARGET_COA_MISMATCH',
            Token1      => 'COMP_TYPE',
            Token1Val   => ComponentType,
            Token1Xlate => TRUE,
            Token2      => 'COMP_NAME',
            Token2Val   => ComponentName,
            Token2Xlate => FALSE);
          RG_XFER_UTILS_PKG.display_log(
            MsgLevel  => G_ML_Full,
            MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARNING',
            Token1    => 'ROUTINE',
            Token1Val => 'copy_axis_set');
          RETURN(G_Warning);
        ELSE
          /* Show warning and use the existing id. */
          RG_XFER_UTILS_PKG.display_warning(
            MsgName     => 'RG_XFER_COMP_EXIST',
            Token1      => 'COMP_TYPE',
            Token1Val   => 'RG_ROW_SET',
            Token1Xlate => TRUE,
            Token2      => 'COMP_NAME',
            Token2Val   => ComponentName,
            Token2Xlate => FALSE);
        END IF;
      END IF;
    ELSE
      IF (RG_XFER_UTILS_PKG.search_list(
            ColumnSetList, ColumnSetCount, ComponentName) = G_Error) THEN
        /* Component with same name existed before this run. */

        /* Check if it uses the correct chart of accounts id. */
        CheckTargetCOA :=
          RG_XFER_UTILS_PKG.check_target_coa_id(
            'RG_REPORT_AXIS_SETS',
            ComponentName,
            ' AND ((application_id = 168)' ||
            '   OR (application_id = ' || TO_CHAR(G_ApplId) || '))' ||
            ' AND axis_set_type = ''' || AxisSetType || '''');
        IF (CheckTargetCOA = G_Error) THEN
          RG_XFER_UTILS_PKG.display_warning(
            MsgName     => 'RG_XFER_TARGET_COA_MISMATCH',
            Token1      => 'COMP_TYPE',
            Token1Val   => ComponentType,
            Token1Xlate => TRUE,
            Token2      => 'COMP_NAME',
            Token2Val   => ComponentName,
            Token2Xlate => FALSE);
          RG_XFER_UTILS_PKG.display_log(
            MsgLevel  => G_ML_Full,
            MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARNING',
            Token1    => 'ROUTINE',
            Token1Val => 'copy_axis_set');
          RETURN(G_Warning);
        ELSE
          /* Show warning and use the existing id. */
          RG_XFER_UTILS_PKG.display_warning(
            MsgName     => 'RG_XFER_COMP_EXIST',
            Token1      => 'COMP_TYPE',
            Token1Val   => 'RG_COLUMN_SET',
            Token1Xlate => TRUE,
            Token2      => 'COMP_NAME',
            Token2Val   => ComponentName,
            Token2Xlate => FALSE);
        END IF;
      END IF;
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_AxisSet := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_axis_set');

  /* Return the id to be used for this component */
  RETURN(TargetId);

    /* This exception is added under the Bug#3843014 */
EXCEPTION
   WHEN OTHERS THEN
    /* Display the exception if MsgLevel is at least Normal */
    ErrorNum := SQLCODE;
    ErrorMsg := SUBSTRB(SQLERRM, 1, 512);
    RG_XFER_UTILS_PKG.display_exception(ErrorNum, ErrorMsg);

    RG_XFER_UTILS_PKG.display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_EXIT_ROUTINE_ERROR',
        Token1    => 'ROUTINE',
        Token1Val => 'copy_axis_set');
    RETURN(G_Error);

END copy_axis_set;


/* Name:  copy_content_set
 * Desc:  Copies the specified content set. Return the id of the copied
 *        component. If the component already exists in the target db,
 *        then return the id for the existing component.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION copy_content_set(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId     NUMBER; /* Target component id */
  SourceId     NUMBER; /* Source component id */
  SQLString    VARCHAR2(2000);
  AdjustedName VARCHAR2(60);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_content_set',
    Token2    => 'PARAM1',
    Token2Val => ComponentName);

  /* Store the name of the component being copied */
  G_ContentSet := ComponentName;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          'RG_CONTENT_SET', ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_CONTENT_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Ensure that the COA id of the component matches the source COA id */
  IF (RG_XFER_UTILS_PKG.check_coa_id(
        'RG_REPORT_CONTENT_SETS', ComponentName) = G_Error) THEN
    RG_XFER_UTILS_PKG.display_warning(
      MsgName     => 'RG_XFER_WRONG_COA',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_CONTENT_SET',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARN',
      Token1    => 'ROUTINE',
      Token1Val => 'copy_content_set');
    RETURN(G_Warning);
  END IF;

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT content_set_id ' ||
               'FROM   rg_report_content_sets ' ||
               'WHERE  name = ''' || AdjustedName || '''' ||
               'AND    application_id = ' || TO_CHAR(G_ApplId);
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN
    /* Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_REPORT_CONTENT_SETS_S');
    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORT_CONTENT_SETS',
                  'CONTENT_SET_ID',
                  ComponentName,
                  ' AND application_id = ' || TO_CHAR(G_ApplId));
    RG_XFER_UTILS_PKG.insert_rows(
      ContentSetsString || G_LinkName ||
        ' WHERE content_set_id = ' || TO_CHAR(SourceId),
      TargetId, UseCOAId => TRUE);
    /* Copy the content set details */
    RG_XFER_COMP_PRIVATE_PKG.copy_content_set_details(
                                           G_ContentSet, SourceId, TargetId);

    /* New component - insert into the list of components copied */
    RG_XFER_UTILS_PKG.insert_into_list(
      ContentSetList, ContentSetCount, ComponentName);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel    => G_ML_Normal,
      MsgName     => 'RG_XFER_L_TRANSFERRED',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_CONTENT_SET',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (RG_XFER_UTILS_PKG.search_list(
          ContentSetList, ContentSetCount, ComponentName) = G_Error) THEN
      /* Component with same name existed before this run. */

      /* Check if it uses the correct chart of accounts id. */
      IF (RG_XFER_UTILS_PKG.check_target_coa_id(
            'RG_REPORT_CONTENT_SETS', ComponentName) = G_Error) THEN
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_TARGET_COA_MISMATCH',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_CONTENT_SET',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
        RG_XFER_UTILS_PKG.display_log(
          MsgLevel  => G_ML_Full,
          MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARNING',
          Token1    => 'ROUTINE',
          Token1Val => 'copy_content_set');
        RETURN(G_Warning);
      ELSE
        /* Show warning and use the existing id. */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_COMP_EXIST',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_CONTENT_SET',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
      END IF;
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_ContentSet := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_content_set');

  /* Return the id to be used for this component */
  RETURN(TargetId);
END copy_content_set;


/* Name:  copy_row_order
 * Desc:  Copies the specified row order. Return the id of the copied
 *        component. If the component already exists in the target db,
 *        then return the id for the existing component.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION copy_row_order(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId     NUMBER; /* Target component id */
  SourceId     NUMBER; /* Source component id */
  SQLString    VARCHAR2(3000);
  AdjustedName VARCHAR2(60);
  ColumnName   VARCHAR2(30);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_row_order',
    Token2    => 'PARAM1',
    Token2Val => ComponentName);

  /* Store the name of the component being copied */
  G_RowOrder := ComponentName;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          'RG_ROW_ORDER', ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_ROW_ORDER',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Ensure that the COA id of the component matches the source COA id */
  IF (RG_XFER_UTILS_PKG.check_coa_id(
        'RG_ROW_ORDERS', ComponentName) = G_Error) THEN
    RG_XFER_UTILS_PKG.display_warning(
      MsgName     => 'RG_XFER_WRONG_COA',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_ROW_ORDER',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARN',
      Token1    => 'ROUTINE',
      Token1Val => 'copy_row_order');
    RETURN(G_Warning);
  END IF;

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT row_order_id  ' ||
               'FROM   rg_row_orders ' ||
               'WHERE  name = ''' || AdjustedName || '''' ||
               'AND    application_id = ' || TO_CHAR(G_ApplId);
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN
    /* Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_ROW_ORDERS_S');
    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_ROW_ORDERS',
                  'ROW_ORDER_ID',
                  ComponentName,
                  ' AND application_id = ' || TO_CHAR(G_ApplId));

    /* Check the existence of the column name, if any */
    ColumnName := RG_XFER_UTILS_PKG.get_varchar2(
                      'SELECT column_name FROM rg_row_orders@'|| G_LinkName ||
                        ' WHERE row_order_id='||TO_CHAR(SourceId),
                      30);
    IF (ColumnName IS NOT NULL) THEN
      IF (NOT RG_XFER_UTILS_PKG.ro_column_exists(ColumnName)) THEN
        /* Warning: column not defined in target database */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_RO_COLUMN_NOT_EXIST',
          Token1      => 'COLUMN_NAME',
          Token1Val   => ColumnName,
          Token1Xlate => FALSE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
        ColumnName := 'NULL';
      ELSE
        /* select the column name */
        ColumnName := 'COLUMN_NAME';
      END IF;
    ELSE
      ColumnName := 'NULL';
    END IF;

    /* Substitute column_name token and insert row */
    SQLString := RowOrdersString || G_LinkName ||
                   ' WHERE row_order_id = ' || TO_CHAR(SourceId);
    RG_XFER_UTILS_PKG.substitute_tokens(
      SQLString,
      Token1=>    ':column_name',
      Token1Val=> ColumnName);
    RG_XFER_UTILS_PKG.insert_rows(SQLString, TargetId, UseCOAId=> TRUE);

    /* Insert detail rows */
    RG_XFER_UTILS_PKG.insert_rows(
      RowSegmentSequencesString || G_LinkName ||
        ' WHERE row_order_id = ' || TO_CHAR(SourceId),
      TargetId, UseCOAId => TRUE);

    /* New component - insert into the list of components copied */
    RG_XFER_UTILS_PKG.insert_into_list(
      RowOrderList, RowOrderCount, ComponentName);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel    => G_ML_Normal,
      MsgName     => 'RG_XFER_L_TRANSFERRED',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_ROW_ORDER',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (RG_XFER_UTILS_PKG.search_list(
          RowOrderList, RowOrderCount, ComponentName) = G_Error) THEN
      /* Component with same name existed before this run. */

      /* Check if it uses the correct chart of accounts id. */
      IF (RG_XFER_UTILS_PKG.check_target_coa_id(
            'RG_ROW_ORDERS', ComponentName) = G_Error) THEN
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_TARGET_COA_MISMATCH',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_ROW_ORDER',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
        RG_XFER_UTILS_PKG.display_log(
          MsgLevel  => G_ML_Full,
          MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARNING',
          Token1    => 'ROUTINE',
          Token1Val => 'copy_row_order');
        RETURN(G_Warning);
      ELSE
        /* Show warning and use the existing id. */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_COMP_EXIST',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_ROW_ORDER',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
      END IF;
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_RowOrder := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_row_order');

  /* Return the id to be used for this component */
  RETURN(TargetId);
END copy_row_order;


/* Name:  copy_display_set
 * Desc:  Copies the specified display set. Return the id of the copied
 *        component. If the component already exists in the target db,
 *        then return the id for the existing component.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION copy_display_set(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId        NUMBER; /* Target component id */
  SourceId        NUMBER; /* Source component id */
  SQLString       VARCHAR2(2000);
  RowSetName      VARCHAR2(30);
  RowSetId        NUMBER := G_Error;
  ColumnSetName   VARCHAR2(30);
  ColumnSetId     NUMBER := G_Error;
  AdjustedName    VARCHAR2(60);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_display_set',
    Token2    => 'PARAM1',
    Token2Val => ComponentName);

  /* Store the name of the component being copied */
  G_DisplaySet := ComponentName;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          'RG_DISPLAY_SET', ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_DISPLAY_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT report_display_set_id ' ||
               'FROM   rg_report_display_sets ' ||
               'WHERE  name = ''' || AdjustedName || '''';
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN
    /* Copy row set, if any */
    RowSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                    'RG_REPORT_DISPLAY_SETS', 'RG_REPORT_AXIS_SETS',
                    'NAME', ComponentName, 'ROW_SET_ID', 'AXIS_SET_ID');
    IF (RowSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_ROW_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => RowSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_DISPLAY_SET',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_DisplaySet,
        Token4Xlate => FALSE);
      RowSetId := copy_axis_set('RG_ROW_SET', RowSetName);
      IF ((RowSetId = G_Error) OR (RowSetId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_DISPLAY_SET',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_DisplaySet,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_ROW_SET',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    /* Copy column set, if any */
    ColumnSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                       'RG_REPORT_DISPLAY_SETS', 'RG_REPORT_AXIS_SETS',
                       'NAME', ComponentName, 'COLUMN_SET_ID', 'AXIS_SET_ID');
    IF (ColumnSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_COLUMN_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => ColumnSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_DISPLAY_SET',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_DisplaySet,
        Token4Xlate => FALSE);
      ColumnSetId := copy_axis_set('RG_COLUMN_SET', ColumnSetName);
      IF ((ColumnSetId = G_Error) OR (ColumnSetId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_DISPLAY_SET',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_DisplaySet,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_COLUMN_SET',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    /* Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_REPORT_DISPLAY_SETS_S');
    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORT_DISPLAY_SETS',
                  'REPORT_DISPLAY_SET_ID',
                  ComponentName);
    SQLString := DisplaySetsString || G_LinkName ||
                   ' WHERE report_display_set_id = ' || TO_CHAR(SourceId);
    RG_XFER_UTILS_PKG.substitute_tokens(
      SQLString,
      Token1=>    ':row_set_id',
      Token1Val=> RG_XFER_UTILS_PKG.token_from_id(RowSetId),
      Token2=>    ':column_set_id',
      Token2Val=> RG_XFER_UTILS_PKG.token_from_id(ColumnSetId));
    RG_XFER_UTILS_PKG.insert_rows(SQLString, TargetId, UseCOAId=> FALSE);

    /* Copy the display set detail records */
    copy_display_set_details(SourceId, TargetId);

    /* New component - insert into the list of components copied */
    RG_XFER_UTILS_PKG.insert_into_list(
      DisplaySetList, DisplaySetCount, ComponentName);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel    => G_ML_Normal,
      MsgName     => 'RG_XFER_L_TRANSFERRED',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_DISPLAY_SET',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (RG_XFER_UTILS_PKG.search_list(
          DisplaySetList, DisplaySetCount, ComponentName) = G_Error) THEN
      /* Component with same name existed before this run. Show warning and
       * and use the existing id. */
      RG_XFER_UTILS_PKG.display_warning(
        MsgName     => 'RG_XFER_COMP_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_DISPLAY_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_DisplaySet := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_display_set');

  /* Return the id to be used for this component */
  RETURN(TargetId);
END copy_display_set;


/* Name:  copy_display_set_details
 * Desc:  Copies the detail records for the specified display set.
 *        Get all the detail records for the display set from the source
 *        database and insert them into the target database. We need to
 *        process one detail record at a time to check for the existence
 *        of display groups. If a display group does not exist then copy
 *        the display group from the source database. If there is an error
 *        copying the display group, then omit the display group from the
 *        detail record.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE copy_display_set_details(
            SourceDisplaySetId NUMBER,
            TargetDisplaySetId NUMBER) IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  DisplayId    NUMBER;
  RowGroupId   NUMBER;
  SQLString    VARCHAR2(2000);
  ColumnGroupId    NUMBER;
  DisplayGroupName VARCHAR2(30);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_display_set_details',
    Token2    => 'PARAM1',
    Token2Val => TO_CHAR(SourceDisplaySetId),
    Token3    => 'PARAM2',
    Token3Val => TO_CHAR(TargetDisplaySetId));

  /* Get all the detail records for this display set. */
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId,
                 'SELECT report_display_id FROM rg_report_displays@' ||
                   G_LinkName || ' WHERE report_display_set_id =' ||
                   TO_CHAR(SourceDisplaySetId),
                 DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, DisplayId);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  LOOP
    /* Loop through each detail record, and copy it. */
    IF (DBMS_SQL.fetch_rows(CursorId) > 0) THEN
      DBMS_SQL.column_value(CursorId, 1, DisplayId);

      /* Copy row group, if any */
      DisplayGroupName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                            'RG_REPORT_DISPLAYS', 'RG_REPORT_DISPLAY_GROUPS',
                            'REPORT_DISPLAY_ID', TO_CHAR(DisplayId),
                            'ROW_GROUP_ID', 'REPORT_DISPLAY_GROUP_ID',
                            CharColumn => FALSE);
      IF (DisplayGroupName IS NOT NULL) THEN
        RG_XFER_UTILS_PKG.display_log(
          MsgLevel    => G_ML_Normal,
          MsgName     => 'RG_XFER_L_SUB_COMP_START',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_DISPLAY_GROUP',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => DisplayGroupName,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_DISPLAY_SET',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_DisplaySet,
          Token4Xlate => FALSE);
        RowGroupId := copy_display_group(DisplayGroupName);
        IF ((RowGroupId = G_Error) OR (RowGroupId = G_Warning)) THEN
          /* Error transferrring optional component */
          RG_XFER_UTILS_PKG.display_warning(
            MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
            Token1      => 'COMP_TYPE',
            Token1Val   => 'RG_DISPLAY_SET',
            Token1Xlate => TRUE,
            Token2      => 'COMP_NAME',
            Token2Val   => G_DisplaySet,
            Token2Xlate => FALSE,
            Token3      => 'SUB_COMP_TYPE',
            Token3Val   => 'RG_DISPLAY_GROUP',
            Token3Xlate => TRUE);
        END IF;
      ELSE
        RowGroupId := G_Error;
      END IF;

      /* Copy column group, if any */
      DisplayGroupName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                            'RG_REPORT_DISPLAYS', 'RG_REPORT_DISPLAY_GROUPS',
                            'REPORT_DISPLAY_ID', TO_CHAR(DisplayId),
                            'COLUMN_GROUP_ID', 'REPORT_DISPLAY_GROUP_ID',
                            CharColumn => FALSE);
      IF (DisplayGroupName IS NOT NULL) THEN
        RG_XFER_UTILS_PKG.display_log(
          MsgLevel    => G_ML_Normal,
          MsgName     => 'RG_XFER_L_SUB_COMP_START',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_DISPLAY_GROUP',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => DisplayGroupName,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_DISPLAY_SET',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_DisplaySet,
          Token4Xlate => FALSE);
        ColumnGroupId := copy_display_group(DisplayGroupName);
        IF ((ColumnGroupId = G_Error) OR (ColumnGroupId = G_Warning)) THEN
          /* Error transferrring optional component */
          RG_XFER_UTILS_PKG.display_warning(
            MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
            Token1      => 'COMP_TYPE',
            Token1Val   => 'RG_DISPLAY_SET',
            Token1Xlate => TRUE,
            Token2      => 'COMP_NAME',
            Token2Val   => G_DisplaySet,
            Token2Xlate => FALSE,
            Token3      => 'SUB_COMP_TYPE',
            Token3Val   => 'RG_DISPLAY_GROUP',
            Token3Xlate => TRUE);
        END IF;
      ELSE
        ColumnGroupId := G_Error;
      END IF;

      /* Insert the row */
      SQLString := DisplaysString || G_LinkName ||
                     ' WHERE report_display_id = ' || TO_CHAR(DisplayId);
      RG_XFER_UTILS_PKG.substitute_tokens(
        SQLString,
        Token1=>    ':row_group_id',
        Token1Val=> RG_XFER_UTILS_PKG.token_from_id(RowGroupId),
        Token2=>    ':column_group_id',
        Token2Val=> RG_XFER_UTILS_PKG.token_from_id(ColumnGroupId));
      RG_XFER_UTILS_PKG.insert_rows(
        SQLString, TargetDisplaySetId, UseCOAId=> FALSE);

    ELSE
      /* No more rows */
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.close_cursor(CursorId);

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_display_set_details');
END copy_display_set_details;


/* Name:  copy_display_group
 * Desc:  Copies the specified display group. Return the id of the copied
 *        component. If the component already exists in the target db,
 *        then return the id for the existing component.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION copy_display_group(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId        NUMBER; /* Target component id */
  SourceId        NUMBER; /* Source component id */
  SQLString       VARCHAR2(2000);
  RowSetName      VARCHAR2(30);
  RowSetId        NUMBER := G_Error;
  ColumnSetName   VARCHAR2(30);
  ColumnSetId     NUMBER := G_Error;
  AdjustedName    VARCHAR2(60);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_display_group',
    Token2    => 'PARAM1',
    Token2Val => ComponentName);

  /* Store the name of the component being copied */
  G_DisplayGroup := ComponentName;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          'RG_DISPLAY_GROUP', ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_DISPLAY_GROUP',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT report_display_group_id ' ||
               'FROM   rg_report_display_groups ' ||
               'WHERE  name = ''' || AdjustedName || '''';
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN
    /* Copy row set, if any */
    RowSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                    'RG_REPORT_DISPLAY_GROUPS', 'RG_REPORT_AXIS_SETS',
                    'NAME', ComponentName, 'ROW_SET_ID', 'AXIS_SET_ID');
    IF (RowSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_ROW_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => RowSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_DISPLAY_GROUP',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_DisplayGroup,
        Token4Xlate => FALSE);
      RowSetId := copy_axis_set('RG_ROW_SET', RowSetName);
      IF ((RowSetId = G_Error) OR (RowSetId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_DISPLAY_GROUP',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_DisplayGroup,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_ROW_SET',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    /* Copy column set, if any */
    ColumnSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                       'RG_REPORT_DISPLAY_GROUPS', 'RG_REPORT_AXIS_SETS',
                       'NAME', ComponentName, 'COLUMN_SET_ID', 'AXIS_SET_ID');
    IF (ColumnSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_COLUMN_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => ColumnSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_DISPLAY_GROUP',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_DisplayGroup,
        Token4Xlate => FALSE);
      ColumnSetId := copy_axis_set('RG_COLUMN_SET', ColumnSetName);
      IF ((ColumnSetId = G_Error) OR (ColumnSetId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_DISPLAY_GROUP',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_DisplayGroup,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_COLUMN_SET',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    /* Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_REPORT_DISPLAY_GROUPS_S');
    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORT_DISPLAY_GROUPS',
                  'REPORT_DISPLAY_GROUP_ID',
                  ComponentName);
    SQLString := DisplayGroupsString || G_LinkName ||
                 ' WHERE report_display_group_id = '||TO_CHAR(SourceId);
    RG_XFER_UTILS_PKG.substitute_tokens(
      SQLString,
      Token1=>    ':row_set_id',
      Token1Val=> RG_XFER_UTILS_PKG.token_from_id(RowSetId),
      Token2=>    ':column_set_id',
      Token2Val=> RG_XFER_UTILS_PKG.token_from_id(ColumnSetId));
    RG_XFER_UTILS_PKG.insert_rows(SQLString, TargetId, UseCOAId=> FALSE);

    /* New component - insert into the list of components copied */
    RG_XFER_UTILS_PKG.insert_into_list(
      DisplayGroupList, DisplayGroupCount, ComponentName);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel    => G_ML_Normal,
      MsgName     => 'RG_XFER_L_TRANSFERRED',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_DISPLAY_GROUP',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (RG_XFER_UTILS_PKG.search_list(
          DisplayGroupList, DisplayGroupCount, ComponentName) = G_Error) THEN
      /* Component with same name existed before this run. Show warning and
       * and use the existing id. */
      RG_XFER_UTILS_PKG.display_warning(
        MsgName     => 'RG_XFER_COMP_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_DISPLAY_GROUP',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_DisplayGroup := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_display_group');

  /* Return the id to be used for this component */
  RETURN(TargetId);
END copy_display_group;


/* Name:  copy_report
 * Desc:  Copies the specified report. Return the id of the copied
 *        component. If the component already exists in the target db,
 *        then return the id for the existing component.
 *
 *        Copy the sub-components of the report, as necessary. If there
 *        is an error copying the row or column set, then the report
 *        copying fails, since these components are required. If there
 *        is an error copying the content set, row order, or display set,
 *        or if the currency used does not exist in the target database,
 *        then omit the information from the report. This is okay since
 *        the information is not required.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 *   03/31/03   T Cheng    For each record, check if the specified
 *                         segment_override ledger exists. If it doesn't,
 *                         then omit ledger override information.
 */
FUNCTION copy_report(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId        NUMBER; /* Target component id */
  SourceId        NUMBER; /* Source component id */
  SQLString       VARCHAR2(3000);
  RowSetName      VARCHAR2(30);
  RowSetId        NUMBER := NULL;
  ColumnSetName   VARCHAR2(30);
  ColumnSetId     NUMBER := NULL;
  RowOrderName    VARCHAR2(30);
  RowOrderId      NUMBER := G_Error;
  ContentSetName  VARCHAR2(30);
  ContentSetId    NUMBER := G_Error;
  DisplaySetName  VARCHAR2(30);
  DisplaySetId    NUMBER := G_Error;
  ParameterSetId  NUMBER;
  CurrencyCode    VARCHAR2(15);
  AdjustedName    VARCHAR2(60);

  SegOverride     VARCHAR2(800);
  OverrideCurr    VARCHAR2(15);
  COADelimiter    VARCHAR2(1);
  FirstDelimiterPos NUMBER;
  LedgerId        NUMBER;
  LedgerName      VARCHAR2(30);
  ErrorNum     NUMBER;
  ErrorMsg     VARCHAR2(512);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report',
    Token2    => 'PARAM1',
    Token2Val => ComponentName);

  /* Store the name of the component being copied */
  G_Report := ComponentName;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          'RG_REPORT', ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Ensure that the COA id of the component matches the source COA id */
  IF (RG_XFER_UTILS_PKG.check_coa_id(
        'RG_REPORTS', ComponentName) = G_Error) THEN
    RG_XFER_UTILS_PKG.display_warning(
      MsgName     => 'RG_XFER_WRONG_COA',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_REPORT',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARN',
      Token1    => 'ROUTINE',
      Token1Val => 'copy_report');
    RETURN(G_Warning);
  END IF;

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT report_id ' ||
               'FROM   rg_reports ' ||
               'WHERE  name = ''' || AdjustedName || ''' ' ||
               'AND    application_id = ' || TO_CHAR(G_ApplId);
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN
    /* Copy row set */
    RowSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                    'RG_REPORTS', 'RG_REPORT_AXIS_SETS',
                    'NAME', ComponentName, 'ROW_SET_ID', 'AXIS_SET_ID');
    IF (RowSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_ROW_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => RowSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_REPORT',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_Report,
        Token4Xlate => FALSE);
      RowSetId := copy_axis_set('RG_ROW_SET', RowSetName);
    END IF;
    IF ((RowSetId = G_Error) OR (RowSetId = G_Warning)) THEN
      /* Error transferrring required component */
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_ABORT',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => G_Report,
        Token2Xlate => FALSE,
        Token3      => 'SUB_COMP_TYPE',
        Token3Val   => 'RG_ROW_SET',
        Token3Xlate => TRUE);
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_EXIT_ROUTINE_ERROR',
        Token1    => 'ROUTINE',
        Token1Val => 'copy_report');
      RETURN(G_Error);
    END IF;

    /* Copy column set, if any */
    ColumnSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                       'RG_REPORTS', 'RG_REPORT_AXIS_SETS',
                       'NAME', ComponentName, 'COLUMN_SET_ID', 'AXIS_SET_ID');
    IF (ColumnSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_COLUMN_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => ColumnSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_REPORT',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_Report,
        Token4Xlate => FALSE);
      ColumnSetId := copy_axis_set('RG_COLUMN_SET', ColumnSetName);
    END IF;
    IF ((ColumnSetId = G_Error) OR (ColumnSetId = G_Warning)) THEN
      /* Error transferrring required component */
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_ABORT',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => G_Report,
        Token2Xlate => FALSE,
        Token3      => 'SUB_COMP_TYPE',
        Token3Val   => 'RG_COLUMN_SET',
        Token3Xlate => TRUE);
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_EXIT_ROUTINE_ERROR',
        Token1    => 'ROUTINE',
        Token1Val => 'copy_report');
      RETURN(G_Error);
    END IF;

    /* Copy row order, if any */
    RowOrderName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                      'RG_REPORTS', 'RG_ROW_ORDERS', 'NAME', ComponentName,
                      'ROW_ORDER_ID', 'ROW_ORDER_ID');
    IF (RowOrderName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_ROW_ORDER',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => RowOrderName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_REPORT',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_Report,
        Token4Xlate => FALSE);
      RowOrderId := copy_row_order(RowOrderName);
      IF ((RowOrderId = G_Error) OR (RowOrderId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_REPORT',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_Report,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_ROW_ORDER',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    /* Copy content set, if any */
    ContentSetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                        'RG_REPORTS', 'RG_REPORT_CONTENT_SETS', 'NAME',
                        ComponentName, 'CONTENT_SET_ID', 'CONTENT_SET_ID');
    IF (ContentSetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_CONTENT_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => ContentSetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_REPORT',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_Report,
        Token4Xlate => FALSE);
      ContentSetId := copy_content_set(ContentSetName);
      IF ((ContentSetId = G_Error) OR (ContentSetId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_REPORT',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_Report,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_CONTENT_SET',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    /* Copy display set, if any */
    DisplaySetName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                        'RG_REPORTS', 'RG_REPORT_DISPLAY_SETS', 'NAME',
                        ComponentName, 'REPORT_DISPLAY_SET_ID',
                        'REPORT_DISPLAY_SET_ID');
    IF (DisplaySetName IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel    => G_ML_Normal,
        MsgName     => 'RG_XFER_L_SUB_COMP_START',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_DISPLAY_SET',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => DisplaySetName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_REPORT',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_Report,
        Token4Xlate => FALSE);
      DisplaySetId := copy_display_set(DisplaySetName);
      IF ((DisplaySetId = G_Error) OR (DisplaySetId = G_Warning)) THEN
        /* Error transferrring optional component */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_REPORT',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_Report,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_DISPLAY_SET',
          Token3Xlate => TRUE);
      END IF;
    END IF;

    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORTS',
                  'REPORT_ID',
                  ComponentName,
                  ' AND application_id = ' || TO_CHAR(G_ApplId));

    /* Check ledger id in segment_override */
    SegOverride := RG_XFER_UTILS_PKG.get_varchar2(
                     'SELECT segment_override FROM rg_reports@' ||
                      G_LinkName || ' WHERE report_id = ' ||
                      TO_CHAR(SourceId), 800);
    OverrideCurr := RG_XFER_UTILS_PKG.get_varchar2(
                     'SELECT override_alc_ledger_currency FROM rg_reports@' ||
                      G_LinkName || ' WHERE report_id = ' ||
                      TO_CHAR(SourceId), 15);

    COADelimiter := RG_XFER_UTILS_PKG.get_varchar2(
                     'SELECT concatenated_segment_delimiter' ||
                     ' FROM fnd_id_flex_structures@' ||
                      G_LinkName || ' f, rg_reports@' || G_LinkName || ' r' ||
                     ' WHERE f.application_id = r.application_id' ||
                     ' AND   f.id_flex_code = r.id_flex_code' ||
                     ' AND   f.id_flex_num = r.structure_id' ||
                     ' AND   report_id = ' || TO_CHAR(SourceId), 1);

    FirstDelimiterPos := INSTR(SegOverride, COADelimiter);
    LedgerId := TO_NUMBER(SUBSTR(SegOverride, 1, FirstDelimiterPos - 1));
    IF (LedgerId IS NOT NULL) THEN
      RG_XFER_UTILS_PKG.get_target_ldg_from_source_ldg(
                             LedgerId, LedgerName, OverrideCurr);
    END IF;

    IF (LedgerId = G_Error) THEN
      /* Error: ledger not present in target db */
      RG_XFER_UTILS_PKG.display_warning(
        MsgName     => 'RG_XFER_SUB_COMP_NOT_EXIST',
        Token1      => 'SUB_COMP_TYPE',
        Token1Val   => 'RG_XFER_LEDGERS',
        Token1Xlate => TRUE,
        Token2      => 'SUB_COMP_NAME',
        Token2Val   => LedgerName,
        Token2Xlate => FALSE,
        Token3      => 'COMP_TYPE',
        Token3Val   => 'RG_REPORT',
        Token3Xlate => TRUE,
        Token4      => 'COMP_NAME',
        Token4Val   => G_Report,
        Token4Xlate => FALSE);
      SegOverride := '''' || SUBSTR(SegOverride, FirstDelimiterPos) || '''';
    ELSE
      SegOverride := '''' || TO_CHAR(LedgerId) ||
                       SUBSTR(SegOverride, FirstDelimiterPos) || '''';
    END IF;

    /* Check currency */
    CurrencyCode := RG_XFER_UTILS_PKG.get_varchar2(
                      'SELECT unit_of_measure_id FROM rg_reports@'||
                        G_LinkName || ' WHERE report_id='||TO_CHAR(SourceId),
                      15);
    IF (CurrencyCode IS NOT NULL) THEN
      IF (NOT RG_XFER_UTILS_PKG.currency_exists(CurrencyCode)) THEN
        /* Warning: currency not defined in target database */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_NOT_EXIST',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_XFER_CURRENCY',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => CurrencyCode,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_REPORT',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_Report,
          Token4Xlate => FALSE);
        CurrencyCode := 'NULL';
      ELSE
        /* add the single quotes to the currency code */
        CurrencyCode := '''' || CurrencyCode || '''';
      END IF;
    ELSE
      CurrencyCode := 'NULL';
    END IF;

    ParameterSetId := copy_report_details(SourceId);
    IF ((ParameterSetId = G_Error) OR (ParameterSetId = G_Warning)) THEN
      /* Error transferrring optional component */
      RG_XFER_UTILS_PKG.display_warning(
        MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => G_Report,
        Token2Xlate => FALSE,
        Token3      => 'SUB_COMP_TYPE',
        Token3Val   => 'RG_XFER_PARAMETER_SET',
        Token3Xlate => TRUE);
    END IF;

    /* Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_REPORTS_S');
    SQLString := ReportsString || G_LinkName ||
                   ' WHERE report_id = ' ||TO_CHAR(SourceId);
    RG_XFER_UTILS_PKG.substitute_tokens(
      SQLString,
      Token1=>    ':row_set_id',
      Token1Val=> TO_CHAR(RowSetId),
      Token2=>    ':column_set_id',
      Token2Val=> TO_CHAR(ColumnSetId),
      Token3=>     ':content_set_id',
      Token3Val=> RG_XFER_UTILS_PKG.token_from_id(ContentSetId),
      Token4=>    ':row_order_id',
      Token4Val=> RG_XFER_UTILS_PKG.token_from_id(RowOrderId),
      Token5=>    ':parameter_set_id',
      Token5Val=> RG_XFER_UTILS_PKG.token_from_id(ParameterSetId),
      Token6=>    ':currency_code',
      Token6Val=> CurrencyCode,
      Token7=>    ':segment_override',
      Token7Val=> SegOverride,
      Token8=>    ':override_alc_ledger_currency',
      Token8Val=> OverrideCurr,
      Token9=>    ':display_set_id',
      Token9Val=> RG_XFER_UTILS_PKG.token_from_id(DisplaySetId)
      );

    RG_XFER_UTILS_PKG.insert_rows(SQLString, TargetId, UseCOAId=> TRUE);

    /* New component - insert into the list of components copied */
    RG_XFER_UTILS_PKG.insert_into_list(
      ReportList, ReportCount, ComponentName);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel    => G_ML_Normal,
      MsgName     => 'RG_XFER_L_TRANSFERRED',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_REPORT',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (RG_XFER_UTILS_PKG.search_list(
          ReportList, ReportCount, ComponentName) = G_Error) THEN
      /* Component with same name existed before this run. */

      /* Check if it uses the correct chart of accounts id. */
      IF (RG_XFER_UTILS_PKG.check_target_coa_id(
            'RG_REPORTS', ComponentName) = G_Error) THEN
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_TARGET_COA_MISMATCH',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_REPORT',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
        RG_XFER_UTILS_PKG.display_log(
          MsgLevel  => G_ML_Full,
          MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARNING',
          Token1    => 'ROUTINE',
          Token1Val => 'copy_report');
        RETURN(G_Warning);
      ELSE
        /* Show warning and use the existing id. */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_COMP_EXIST',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_REPORT',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => ComponentName,
          Token2Xlate => FALSE);
      END IF;
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_Report := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report');

  /* Return the id to be used for this component */
  RETURN(TargetId);

  /* This exception is added under the Bug#3843014 */
EXCEPTION
   WHEN OTHERS THEN
    /* Display the exception if MsgLevel is at least Normal */
    ErrorNum := SQLCODE;
    ErrorMsg := SUBSTRB(SQLERRM, 1, 512);
    RG_XFER_UTILS_PKG.display_exception(ErrorNum, ErrorMsg);

    /* Error transferrring required component */
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_ABORT',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => G_Report,
        Token2Xlate => FALSE,
        Token3      => 'SUB_COMP_TYPE',
        Token3Val   => 'RG_ROW_SET',
        Token3Xlate => TRUE);
      RG_XFER_UTILS_PKG.display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_EXIT_ROUTINE_ERROR',
        Token1    => 'ROUTINE',
        Token1Val => 'copy_report');
      RETURN(G_Error);
END copy_report;


/* Name:  copy_report_details
 * Desc:  Copies the parameters of the report and returns the new
 *        parameter set id. If a parameter doesn't exist in the target
 *        database, then that whole record is skipped.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION copy_report_details(ReportId NUMBER) RETURN NUMBER IS
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  DataType      VARCHAR2(1);
  SQLString     VARCHAR2(2000);
  ParameterId   NUMBER;
  ParameterNum  NUMBER;
  ParameterName VARCHAR2(100);
  EnteredCurrency VARCHAR2(15);
  LedgerCurrency  VARCHAR2(15);
  RowsFound     BOOLEAN := TRUE;
  TargetParameterSetId NUMBER;
  SourceParameterSetId NUMBER;
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report_details',
    Token2    => 'PARAM1',
    Token2Val => TO_CHAR(ReportId));

  /* Get a new parameter set id */
  TargetParameterSetId := RG_XFER_UTILS_PKG.get_new_id(
                            'RG_REPORT_PARAMETERS_S');

  /* Get all the parameters for the report */
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId,
                 'SELECT par.data_type, par.parameter_id, ' ||
                   'par.parameter_set_id, par.entered_currency, '||
                   'par.ledger_currency, ' ||
                   'par.parameter_num FROM rg_report_parameters@' ||
                   G_LinkName || ' par, rg_reports@' || G_LinkName ||
                   ' rp WHERE par.parameter_set_id = rp.parameter_set_id '||
                   'AND rp.report_id =' || TO_CHAR(ReportId),
                 DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, DataType, 1);
  DBMS_SQL.define_column(CursorId, 2, ParameterId);
  DBMS_SQL.define_column(CursorId, 3, SourceParameterSetId);
  DBMS_SQL.define_column(CursorId, 4, EnteredCurrency, 15);
  DBMS_SQL.define_column(CursorId, 5, LedgerCurrency, 15);
  DBMS_SQL.define_column(CursorId, 6, ParameterNum);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  LOOP
    /* For each record, check if the parameters exist in the target database.
     * If a parameter does not exist, then skip the record. */
    IF (DBMS_SQL.fetch_rows(CursorId) > 0) THEN
      DBMS_SQL.column_value(CursorId, 1, DataType);
      DBMS_SQL.column_value(CursorId, 2, ParameterId);
      DBMS_SQL.column_value(CursorId, 3, SourceParameterSetId);
      DBMS_SQL.column_value(CursorId, 4, EnteredCurrency);
      DBMS_SQL.column_value(CursorId, 5, LedgerCurrency);
      DBMS_SQL.column_value(CursorId, 6, ParameterNum);

      IF (DataType = 'B') THEN
        /* Check budget */
        RG_XFER_UTILS_PKG.get_target_id_from_source_id(
                         'GL_BUDGET_VERSIONS',
                         'BUDGET_NAME',
                         'BUDGET_VERSION_ID',
                         ParameterId,
                         ParameterName);
      ELSIF (DataType = 'E') THEN
        /* Check encumbrance type */
        RG_XFER_UTILS_PKG.get_target_id_from_source_id(
                         'GL_ENCUMBRANCE_TYPES',
                         'ENCUMBRANCE_TYPE',
                         'ENCUMBRANCE_TYPE_ID',
                         ParameterId,
                         ParameterName);
      ELSIF (DataType = 'C') THEN
        /* Don't need to check anything for the currency here. The check is
         * done in the next step. */
        NULL;
      ELSIF (DataType = 'I') THEN
        /* Nothing to check for constant period of interest parameters */
        NULL;
      ELSE
        RG_XFER_UTILS_PKG.display_warning('Invalid data_type value in ' ||
          'table rg_report_parameters!');
      END IF;

      IF ((DataType = 'B') AND
          (ParameterId = G_Error)) THEN
        /* Error: budget not present in target db */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_NOT_EXIST',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_XFER_BUDGET',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => ParameterName,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_REPORT',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_Report,
          Token4Xlate => FALSE);
      ELSIF ((DataType = 'E') AND
             (ParameterId = G_Error)) THEN
        /* Error: encumbrance type not present in target db */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_NOT_EXIST',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_XFER_ENCUMBRANCE_TYPE',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => ParameterName,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_REPORT',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_Report,
          Token4Xlate => FALSE);
      ELSIF ((DataType = 'C') AND (EnteredCurrency IS NOT NULL) AND
             (NOT RG_XFER_UTILS_PKG.currency_exists(EnteredCurrency))) THEN
        /* Error: entered currency code not present in target db */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_NOT_EXIST',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_XFER_CURRENCY',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => EnteredCurrency,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_REPORT',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_Report,
          Token4Xlate => FALSE);
      ELSIF ((DataType = 'C') AND (LedgerCurrency IS NOT NULL) AND
             (NOT RG_XFER_UTILS_PKG.currency_exists(LedgerCurrency))) THEN
        /* Error: ledger currency code not present in target db */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_NOT_EXIST',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_XFER_CURRENCY',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => LedgerCurrency,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_REPORT',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_Report,
          Token4Xlate => FALSE);
      ELSE
        /* Insert the row */
        SQLString := ReportParametersString || G_LinkName ||
                     ' WHERE parameter_set_id = ' ||
                         TO_CHAR(SourceParameterSetId) ||
                     ' AND data_type = ''' || DataType || '''' ||
                     ' AND parameter_num = ' || TO_CHAR(ParameterNum);
        RG_XFER_UTILS_PKG.substitute_tokens(
          SQLString,
          Token1=> ':parameter_id',
          Token1Val=> TO_CHAR(ParameterId));
        RG_XFER_UTILS_PKG.insert_rows(
          SQLString, TargetParameterSetId, UseCOAId=> FALSE);
      END IF;

    ELSE
      /* No more rows */
      RowsFound := FALSE;
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.close_cursor(CursorId);

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report_details');

  /* Return the parameter set id */
  RETURN(TargetParameterSetId);
END copy_report_details;


/* Name:  copy_report_set
 * Desc:  Copies the specified report set. Return the id of the copied
 *        component. If the component already exists in the target db,
 *        then return the id for the existing component.
 *
 * Notes: ComponentName MUST be NOT NULL.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION copy_report_set(
           ComponentName VARCHAR2,
           CheckExistence BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
  TargetId     NUMBER; /* Target component id */
  SourceId     NUMBER; /* Source component id */
  SQLString    VARCHAR2(2000);
  AdjustedName VARCHAR2(60);
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report_set',
    Token2    => 'PARAM1',
    Token2Val => ComponentName);

  /* Store the name of the component being copied */
  G_ReportSet := ComponentName;

  /* Account for single quotes */
  RG_XFER_UTILS_PKG.copy_adjust_string(AdjustedName, ComponentName);

  /* Ensure that the component exists in the source database */
  IF (CheckExistence) THEN
    IF (NOT RG_XFER_UTILS_PKG.source_component_exists(
          'RG_REPORT_SET', ComponentName)) THEN
      RG_XFER_UTILS_PKG.display_error(
        MsgName     => 'RG_XFER_COMP_NOT_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
      RETURN(G_Error);
    END IF;
  END IF;

  /* Ensure that the COA id of the component matches the source COA id */
  IF (RG_XFER_UTILS_PKG.check_coa_id(
        'RG_REPORT_SETS', ComponentName) = G_Error) THEN
    RG_XFER_UTILS_PKG.display_warning(
      MsgName     => 'RG_XFER_WRONG_COA',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_REPORT_SET',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_EXIT_ROUTINE_WARN',
      Token1    => 'ROUTINE',
      Token1Val => 'copy_report_set');
    RETURN(G_Warning);
  END IF;

  /* Check if a component of the same name already exists in target db */
  SQLString := 'SELECT report_set_id  ' ||
               'FROM   rg_report_sets ' ||
               'WHERE  name = ''' || AdjustedName || '''' ||
               'AND    application_id = ' || TO_CHAR(G_ApplId);
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId = G_Error) THEN
    /* Insert data into table */
    TargetId := RG_XFER_UTILS_PKG.get_new_id('RG_REPORT_SETS_S');
    SourceId := RG_XFER_UTILS_PKG.get_source_id(
                  'RG_REPORT_SETS',
                  'REPORT_SET_ID',
                  ComponentName,
                  ' AND application_id = ' || TO_CHAR(G_ApplId));
    RG_XFER_UTILS_PKG.insert_rows(
      ReportSetsString || G_LinkName ||
        ' WHERE report_set_id = ' || TO_CHAR(SourceId),
      TargetId, UseCOAId=> TRUE);

    copy_report_set_details(SourceId, TargetId);

    /* New component - insert into the list of components copied */
    RG_XFER_UTILS_PKG.insert_into_list(
      ReportSetList, ReportSetCount, ComponentName);
    RG_XFER_UTILS_PKG.display_log(
      MsgLevel    => G_ML_Normal,
      MsgName     => 'RG_XFER_L_TRANSFERRED',
      Token1      => 'COMP_TYPE',
      Token1Val   => 'RG_REPORT_SET',
      Token1Xlate => TRUE,
      Token2      => 'COMP_NAME',
      Token2Val   => ComponentName,
      Token2Xlate => FALSE);

  ELSE

    /* Component with same name already exists in target db. Check if
     * this component was copied by this run. */
    IF (RG_XFER_UTILS_PKG.search_list(
          ReportSetList, ReportSetCount, ComponentName) = G_Error) THEN
      /* Component with same name existed before this run. Show warning and
       * and use the existing id. */
      RG_XFER_UTILS_PKG.display_warning(
        MsgName     => 'RG_XFER_COMP_EXIST',
        Token1      => 'COMP_TYPE',
        Token1Val   => 'RG_REPORT_SET',
        Token1Xlate => TRUE,
        Token2      => 'COMP_NAME',
        Token2Val   => ComponentName,
        Token2Xlate => FALSE);
    END IF;

  END IF;

  /* Clear the name of the component being copied */
  G_ReportSet := NULL;

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report_set');

  /* Return the id to be used for this component */
  RETURN(TargetId);
END copy_report_set;


/* Name:  copy_report_set_details
 * Desc:  Copies the reports that are in the report set. Each report is
 *        copied to the target database, if it doesn't exist already. If
 *        there is an error copying a report, the record is skipped.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE copy_report_set_details(
            SourceReportSetId NUMBER,
            TargetReportSetId NUMBER) IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  ReportId     NUMBER := NULL;
  ReportName   VARCHAR2(30) := NULL;
  SQLString    VARCHAR2(3000);
  ReportRequestId NUMBER;
BEGIN
  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_ENTER_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report_set_details',
    Token2    => 'PARAM1',
    Token2Val => TO_CHAR(SourceReportSetId),
    Token3    => 'PARAM2',
    Token3Val => TO_CHAR(TargetReportSetId));

  /* Get all the reports for the report set */
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId,
                 'SELECT report_request_id FROM rg_report_requests@' ||
                   G_LinkName || ' WHERE report_set_id =' ||
                   TO_CHAR(SourceReportSetId),
                 DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, ReportRequestId);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  LOOP
    /* For each record, copy the report, if it is not there already.
     * If there is an error while copying the report, then skip the
     * record. */
    IF (DBMS_SQL.fetch_rows(CursorId) > 0) THEN
      DBMS_SQL.column_value(CursorId, 1, ReportRequestId);
      /* Copy report */
      ReportName := RG_XFER_UTILS_PKG.get_source_ref_object_name(
                      'RG_REPORT_REQUESTS', 'RG_REPORTS',
                      'REPORT_REQUEST_ID', TO_CHAR(ReportRequestId),
                      'REPORT_ID', 'REPORT_ID',
                      CharColumn => FALSE);

      IF (ReportName IS NOT NULL) THEN
        RG_XFER_UTILS_PKG.display_log(
          MsgLevel    => G_ML_Normal,
          MsgName     => 'RG_XFER_L_SUB_COMP_START',
          Token1      => 'SUB_COMP_TYPE',
          Token1Val   => 'RG_REPORT',
          Token1Xlate => TRUE,
          Token2      => 'SUB_COMP_NAME',
          Token2Val   => ReportName,
          Token2Xlate => FALSE,
          Token3      => 'COMP_TYPE',
          Token3Val   => 'RG_REPORT_SET',
          Token3Xlate => TRUE,
          Token4      => 'COMP_NAME',
          Token4Val   => G_ReportSet,
          Token4Xlate => FALSE);
        ReportId := copy_report(ReportName);
      END IF;

      IF ((ReportId = G_Error) OR (ReportId = G_Warning)) THEN
        /* Display warning message. */
        RG_XFER_UTILS_PKG.display_warning(
          MsgName     => 'RG_XFER_SUB_COMP_FAILURE',
          Token1      => 'COMP_TYPE',
          Token1Val   => 'RG_REPORT_SET',
          Token1Xlate => TRUE,
          Token2      => 'COMP_NAME',
          Token2Val   => G_ReportSet,
          Token2Xlate => FALSE,
          Token3      => 'SUB_COMP_TYPE',
          Token3Val   => 'RG_REPORT',
          Token3Xlate => TRUE);
      ELSE
        /* Insert the row */
        SQLString := ReportRequestsString || G_LinkName ||
                       ' WHERE report_request_id = '||TO_CHAR(ReportRequestId);
        RG_XFER_UTILS_PKG.substitute_tokens(
                              SQLString,
                              Token1=>    ':report_id',
                              Token1Val=> TO_CHAR(ReportId));
        RG_XFER_UTILS_PKG.insert_rows(
          SQLString, TargetReportSetId, UseCOAId=>TRUE);
      END IF;
    ELSE
      /* No more rows */
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.close_cursor(CursorId);

  RG_XFER_UTILS_PKG.display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXIT_ROUTINE',
    Token1    => 'ROUTINE',
    Token1Val => 'copy_report_set_details');
END copy_report_set_details;

/* Name:  transfer_taxonomy
 * Desc:  Copies the taxonomies that are used in the axis set. Each taxonomy is
 *        copied to the target database, if it doesn't exist already.
 *
 * History:
 *   04/08/03   V Treiger   Created.
 */
PROCEDURE transfer_taxonomy(
            parent_tax_alias IN VARCHAR2,
            parent_tax_id   IN NUMBER,
            parent_done_flag IN OUT NOCOPY NUMBER) IS

  TYPE alias_tabtype IS TABLE OF VARCHAR2(240)
    INDEX BY BINARY_INTEGER;
  TYPE id_tabtype IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  --
  cnt       INTEGER;
  child_cnt INTEGER;
  arr_cnt   INTEGER;
  --
  arr_child_tax_alias alias_tabtype;
  arr_child_tax_id id_tabtype;
  arr_child_done_flag id_tabtype;
  --
  cur_tax_alias VARCHAR2(240);
  cur_tax_id NUMBER;
  cur_done_flag NUMBER;
  l_child_tax_id NUMBER;
  --
  src_element_identifier VARCHAR2(240);
  src_element_name       VARCHAR2(240);
  src_element_type       VARCHAR2(240);
  src_element_group      VARCHAR2(240);
  src_element_descr      VARCHAR2(3000);
  src_element_label      VARCHAR2(240);
  src_parent_identifier  VARCHAR2(240);
  src_has_child_flag     VARCHAR2(1);
  src_has_parent_flag    VARCHAR2(1);
  src_hierarchy_level    NUMBER;
  cur_elem_id            NUMBER;
  --
  src_tax_id NUMBER;
  src_tax_alias VARCHAR2(240);
  dest_taxonomy_id NUMBER;
  TargetId  NUMBER;
  --
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  SQLString    VARCHAR2(3000);
  ValueString   VARCHAR2(240);
  TempValue     VARCHAR2(100);
  --
  l_user_id  NUMBER;
  l_login_id NUMBER;
  --
BEGIN
  --
  l_user_id  := FND_GLOBAL.User_Id;
  l_login_id := FND_GLOBAL.Login_Id;
  --
  /* Check if parent taxonomy of the same alias already exists in target db */
  RG_XFER_UTILS_PKG.copy_adjust_string(TempValue, parent_tax_alias);
  ValueString := '''' || TempValue || '''';

  SQLString := 'SELECT taxonomy_id ' ||
               'FROM   rg_xbrl_taxonomies ' ||
               'WHERE  taxonomy_alias = ' || ValueString;
  TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

  IF (TargetId <> G_Error) THEN
    /* parent taxonomy exists in target db */
    parent_done_flag := 1;
    RETURN;
  END IF;

  /* build all childs of the parent taxonomy */
  SQLString := 'SELECT DISTINCT tax.taxonomy_id,tax.taxonomy_alias '||
               'FROM RG_XBRL_TAXONOMIES'||'@'|| G_LinkName || ' tax,' ||
               ' RG_XBRL_ELEMENTS'||'@'|| G_LinkName || ' elm,' ||
               ' RG_XBRL_MAP_ELEMENTS'||'@'|| G_LinkName || ' map ' ||
               'WHERE map.element_id = elm.element_id AND ' ||
               ' elm.taxonomy_id = tax.taxonomy_id AND ' ||
               ' map.enabled_flag = ''Y'' AND ' ||
               ' map.taxonomy_id = '|| to_char(parent_tax_id) || ' AND ' ||
               ' tax.taxonomy_id <> ' || to_char(parent_tax_id);

  RG_XFER_UTILS_PKG.display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;

  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, src_tax_id);
  DBMS_SQL.define_column(CursorId, 2, src_tax_alias, 240);
  child_cnt := 0;
  ExecuteValue := DBMS_SQL.execute(CursorId);

  LOOP
    ExecuteValue := DBMS_SQL.fetch_rows(CursorId);
    IF (ExecuteValue > 0) THEN
      child_cnt := child_cnt + 1;
      DBMS_SQL.column_value(CursorId, 1, src_tax_id);
      DBMS_SQL.column_value(CursorId, 2, src_tax_alias);
      arr_child_tax_id(child_cnt) := src_tax_id;
      arr_child_tax_alias(child_cnt) := src_tax_alias;
      arr_child_done_flag(child_cnt) := 0;
    ELSE
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.close_cursor(CursorId);

  /* all childs are created */

  IF (child_cnt = 0) THEN

    dest_taxonomy_id := RG_XFER_UTILS_PKG.get_new_id('rg_xbrl_taxonomy_s');

    /* populate one row in rg_xbrl_taxonomies */

    SQLString :=
    'INSERT INTO RG_XBRL_TAXONOMIES (' ||
    ' TAXONOMY_ID, TAXONOMY_ALIAS, TAXONOMY_NAME,  ' ||
    ' TAXONOMY_DESCR, TAXONOMY_URL, TAXONOMY_IMPORT_FLAG, ' ||
    ' CREATION_DATE, CREATED_BY, ' ||
    ' LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN' ||
    ') SELECT ' || to_char(dest_taxonomy_id) || ',' ||
    ' taxonomy_alias, taxonomy_name, ' ||
    ' taxonomy_descr, taxonomy_url, taxonomy_import_flag, ' ||
    ' SYSDATE,' || to_char(l_user_id) || ', ' ||
    ' SYSDATE,' || to_char(l_user_id) || ', ' ||
    to_char(l_login_id) || ' ' ||
    'FROM RG_XBRL_TAXONOMIES@' || G_LinkName ||
    ' WHERE taxonomy_id = ' || to_char(parent_tax_id);

    RG_XFER_UTILS_PKG.display_string(SQLString);

    CursorId := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
    ExecuteValue := DBMS_SQL.execute(CursorId);
    DBMS_SQL.close_cursor(CursorId);

    /* populate multiple rows in rg_xbrl_elements */
    SQLString :=
    'SELECT ' ||
    ' element_identifier, ' ||
    ' element_name, element_type, element_group, ' ||
    ' element_descr, element_label, parent_identifier, ' ||
    ' has_child_flag, has_parent_flag, hierarchy_level ' ||
    'FROM RG_XBRL_ELEMENTS@' || G_LinkName ||
    ' WHERE taxonomy_id = ' || to_char(parent_tax_id);

    RG_XFER_UTILS_PKG.display_string(SQLString);

    CursorId := DBMS_SQL.open_cursor;

    DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);

    DBMS_SQL.define_column(CursorId, 1, src_element_identifier,240);
    DBMS_SQL.define_column(CursorId, 2, src_element_name, 240);
    DBMS_SQL.define_column(CursorId, 3, src_element_type,240);
    DBMS_SQL.define_column(CursorId, 4, src_element_group, 240);
    DBMS_SQL.define_column(CursorId, 5, src_element_descr,3000);
    DBMS_SQL.define_column(CursorId, 6, src_element_label, 240);
    DBMS_SQL.define_column(CursorId, 7, src_parent_identifier,240);
    DBMS_SQL.define_column(CursorId, 8, src_has_child_flag,1);
    DBMS_SQL.define_column(CursorId, 9, src_has_parent_flag,1);
    DBMS_SQL.define_column(CursorId, 10, src_hierarchy_level);

    ExecuteValue := DBMS_SQL.execute(CursorId);

    LOOP
      ExecuteValue := DBMS_SQL.fetch_rows(CursorId);
      IF (ExecuteValue > 0) THEN
        DBMS_SQL.column_value(CursorId, 1, src_element_identifier);
        DBMS_SQL.column_value(CursorId, 2, src_element_name);
        DBMS_SQL.column_value(CursorId, 3, src_element_type);
        DBMS_SQL.column_value(CursorId, 4, src_element_group);
        DBMS_SQL.column_value(CursorId, 5, src_element_descr);
        DBMS_SQL.column_value(CursorId, 6, src_element_label);
        DBMS_SQL.column_value(CursorId, 7, src_parent_identifier);
        DBMS_SQL.column_value(CursorId, 8, src_has_child_flag);
        DBMS_SQL.column_value(CursorId, 9, src_has_parent_flag);
        DBMS_SQL.column_value(CursorId, 10, src_hierarchy_level);
        --
        cur_elem_id := RG_XFER_UTILS_PKG.get_new_id('rg_xbrl_elements_s');
        --
        INSERT INTO RG_XBRL_ELEMENTS (
        TAXONOMY_ID, ELEMENT_ID, ELEMENT_IDENTIFIER,
        ELEMENT_NAME, ELEMENT_TYPE, ELEMENT_GROUP,
        ELEMENT_DESCR, ELEMENT_LABEL, PARENT_IDENTIFIER,
        PARENT_ID, HAS_CHILD_FLAG, HAS_PARENT_FLAG, HIERARCHY_LEVEL,
        CREATION_DATE, CREATED_BY,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
        VALUES (
        dest_taxonomy_id,cur_elem_id,src_element_identifier,
        src_element_name,src_element_type,src_element_group,
        src_element_descr,src_element_label,src_parent_identifier,
        NULL,src_has_child_flag,src_has_parent_flag,src_hierarchy_level,
        SYSDATE,l_user_id,SYSDATE,l_user_id,l_login_id);
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(CursorId);

    /* populate multiple rows in rg_xbrl_map_elements */

    SQLString :=
    'INSERT INTO RG_XBRL_MAP_ELEMENTS ('||
    ' TAXONOMY_ID, ELEMENT_ID, ENABLED_FLAG,' ||
    ' CREATION_DATE, CREATED_BY,' ||
    ' LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN' ||
    ') SELECT ' || to_char(dest_taxonomy_id) || ',' ||
    ' element_id, ''Y'',' ||
    ' SYSDATE,' || to_char(l_user_id) || ',' ||
    ' SYSDATE,' || to_char(l_user_id) || ',' || to_char(l_login_id) ||
    ' FROM RG_XBRL_ELEMENTS ' ||
    ' WHERE taxonomy_id = ' || to_char(dest_taxonomy_id);

    RG_XFER_UTILS_PKG.display_string(SQLString);

    CursorId := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
    ExecuteValue := DBMS_SQL.execute(CursorId);
    DBMS_SQL.close_cursor(CursorId);

    parent_done_flag := 1;
    RETURN;

  END IF;

  cnt := 1;
  WHILE cnt <= child_cnt
  LOOP
    cur_tax_id := arr_child_tax_id(cnt);
    cur_tax_alias := arr_child_tax_alias(cnt);
    cur_done_flag := 0;

    transfer_taxonomy(cur_tax_alias,cur_tax_id,cur_done_flag);

    --IF (cur_done_flag = 1) THEN
      /* Check if parent taxonomy of the same alias already exists in target db */

      RG_XFER_UTILS_PKG.copy_adjust_string(TempValue, parent_tax_alias);
      ValueString := '''' || TempValue || '''';

      SQLString := 'SELECT taxonomy_id ' ||
                   'FROM   rg_xbrl_taxonomies ' ||
                   'WHERE  taxonomy_alias = ' || ValueString;

      RG_XFER_UTILS_PKG.display_string(SQLString);

      TargetId := RG_XFER_UTILS_PKG.component_exists(SQLString);

      IF (TargetId = G_Error) THEN
        /* parent taxonomy does not exist in target db */

        dest_taxonomy_id := RG_XFER_UTILS_PKG.get_new_id('rg_xbrl_taxonomy_s');

        /* populate one row in rg_xbrl_taxonomies */

        SQLString :=
        'INSERT INTO RG_XBRL_TAXONOMIES (' ||
        ' TAXONOMY_ID, TAXONOMY_ALIAS, TAXONOMY_NAME,' ||
        ' TAXONOMY_DESCR, TAXONOMY_URL, TAXONOMY_IMPORT_FLAG,' ||
        ' CREATION_DATE, CREATED_BY,' ||
        ' LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN' ||
        ') SELECT ' || to_char(dest_taxonomy_id) || ',' ||
        ' taxonomy_alias, taxonomy_name,' ||
        ' taxonomy_descr, taxonomy_url, taxonomy_import_flag,' ||
        ' SYSDATE,' || TO_CHAR(l_user_id) || ',' ||
        ' SYSDATE,' || TO_CHAR(l_user_id) || ',' || TO_CHAR(l_login_id) ||
        ' FROM RG_XBRL_TAXONOMIES@' || G_LinkName ||
        ' WHERE taxonomy_id = ' || to_char(parent_tax_id);

        RG_XFER_UTILS_PKG.display_string(SQLString);

        CursorId := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
        ExecuteValue := DBMS_SQL.execute(CursorId);
        DBMS_SQL.close_cursor(CursorId);

        /* populate multiple rows in rg_xbrl_elements */

        SQLString :=
        'SELECT ' ||
        ' element_identifier, element_name, element_type, element_group,' ||
        ' element_descr, element_label, parent_identifier,' ||
        ' has_child_flag, has_parent_flag, hierarchy_level' ||
        ' FROM RG_XBRL_ELEMENTS@' || G_LinkName ||
        ' WHERE taxonomy_id = ' || to_char(parent_tax_id);

        RG_XFER_UTILS_PKG.display_string(SQLString);

        CursorId := DBMS_SQL.open_cursor;

        DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);

        DBMS_SQL.define_column(CursorId, 1, src_element_identifier,240);
        DBMS_SQL.define_column(CursorId, 2, src_element_name, 240);
        DBMS_SQL.define_column(CursorId, 3, src_element_type,240);
        DBMS_SQL.define_column(CursorId, 4, src_element_group, 240);
        DBMS_SQL.define_column(CursorId, 5, src_element_descr,3000);
        DBMS_SQL.define_column(CursorId, 6, src_element_label, 240);
        DBMS_SQL.define_column(CursorId, 7, src_parent_identifier,240);
        DBMS_SQL.define_column(CursorId, 8, src_has_child_flag,1);
        DBMS_SQL.define_column(CursorId, 9, src_has_parent_flag,1);
        DBMS_SQL.define_column(CursorId, 10, src_hierarchy_level);

        ExecuteValue := DBMS_SQL.execute(CursorId);

        LOOP
          ExecuteValue := DBMS_SQL.fetch_rows(CursorId);
          IF (ExecuteValue > 0) THEN
            DBMS_SQL.column_value(CursorId, 1, src_element_identifier);
            DBMS_SQL.column_value(CursorId, 2, src_element_name);
            DBMS_SQL.column_value(CursorId, 3, src_element_type);
            DBMS_SQL.column_value(CursorId, 4, src_element_group);
            DBMS_SQL.column_value(CursorId, 5, src_element_descr);
            DBMS_SQL.column_value(CursorId, 6, src_element_label);
            DBMS_SQL.column_value(CursorId, 7, src_parent_identifier);
            DBMS_SQL.column_value(CursorId, 8, src_has_child_flag);
            DBMS_SQL.column_value(CursorId, 9, src_has_parent_flag);
            DBMS_SQL.column_value(CursorId, 10, src_hierarchy_level);
            --
            cur_elem_id := RG_XFER_UTILS_PKG.get_new_id('rg_xbrl_elements_s');
            --
            INSERT INTO RG_XBRL_ELEMENTS (
            TAXONOMY_ID, ELEMENT_ID, ELEMENT_IDENTIFIER,
            ELEMENT_NAME, ELEMENT_TYPE, ELEMENT_GROUP,
            ELEMENT_DESCR, ELEMENT_LABEL, PARENT_IDENTIFIER,
            PARENT_ID, HAS_CHILD_FLAG, HAS_PARENT_FLAG, HIERARCHY_LEVEL,
            CREATION_DATE, CREATED_BY,
            LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
            VALUES (
            dest_taxonomy_id,cur_elem_id,src_element_identifier,
            src_element_name,src_element_type,src_element_group,
            src_element_descr,src_element_label,src_parent_identifier,
            NULL,src_has_child_flag,src_has_parent_flag,src_hierarchy_level,
            SYSDATE,l_user_id,SYSDATE,l_user_id,l_login_id);
          ELSE
            EXIT;
          END IF;
        END LOOP;

        DBMS_SQL.close_cursor(CursorId);

        /* populate multiple rows in rg_xbrl_map_elements  */

        SQLString :=
        'INSERT INTO RG_XBRL_MAP_ELEMENTS (' ||
        ' TAXONOMY_ID, ELEMENT_ID, ENABLED_FLAG,' ||
        ' CREATION_DATE, CREATED_BY,' ||
        ' LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN' ||
        ') SELECT ' || to_char(dest_taxonomy_id) || ',' ||
        ' element_id, ''Y'',' ||
        ' SYSDATE,' || TO_CHAR(l_user_id) || ',' ||
        ' SYSDATE,' || TO_CHAR(l_user_id) || ',' || TO_CHAR(l_login_id) ||
        ' FROM RG_XBRL_ELEMENTS ' ||
        ' WHERE taxonomy_id = ' || to_char(dest_taxonomy_id);

        RG_XFER_UTILS_PKG.display_string(SQLString);

        CursorId := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
        ExecuteValue := DBMS_SQL.execute(CursorId);
        DBMS_SQL.close_cursor(CursorId);

      END IF;

      /* update rg_xbrl_map_elements for the parent with a child */

      RG_XFER_UTILS_PKG.copy_adjust_string(TempValue, cur_tax_alias);
      ValueString := '''' || TempValue || '''';

      SQLString := 'SELECT taxonomy_id ' ||
                   'FROM   rg_xbrl_taxonomies ' ||
                   'WHERE  taxonomy_alias = ' || ValueString;

      l_child_tax_id := RG_XFER_UTILS_PKG.component_exists(SQLString);

      SQLString :=
      'INSERT INTO RG_XBRL_MAP_ELEMENTS (' ||
      ' TAXONOMY_ID, ELEMENT_ID, ENABLED_FLAG,' ||
      ' CREATION_DATE, CREATED_BY,' ||
      ' LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN' ||
      ') SELECT ' || to_char(dest_taxonomy_id) || ',' ||
      ' mel.element_id, mel.enabled_flag,' ||
      ' SYSDATE,' || TO_CHAR(l_user_id) || ',' ||
      ' SYSDATE,' || TO_CHAR(l_user_id) || ',' || TO_CHAR(l_login_id) ||
      ' FROM RG_XBRL_MAP_ELEMENTS mel' ||
      ' WHERE mel.taxonomy_id = ' || to_char(l_child_tax_id) || ' AND ' ||
      ' mel.element_id NOT IN ' ||
      '(SELECT map.element_id FROM RG_XBRL_MAP_ELEMENTS map ' ||
      'WHERE map.taxonomy_id = ' || to_char(dest_taxonomy_id) || ')';

      RG_XFER_UTILS_PKG.display_string(SQLString);

      CursorId := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
      ExecuteValue := DBMS_SQL.execute(CursorId);
      DBMS_SQL.close_cursor(CursorId);

    --ELSE
    --  parent_done_flag := 0;
    --  RETURN;
    --END IF;

    cnt := cnt + 1;

  END LOOP;

END transfer_taxonomy;

BEGIN
  /* Initialize variables on package access. */

  /* Error codes */
  G_Error := RG_XFER_UTILS_PKG.G_Error;
  G_Warning := RG_XFER_UTILS_PKG.G_Warning;

  /* The message levels */
  G_ML_Minimal := RG_XFER_UTILS_PKG.G_ML_Minimal;
  G_ML_Normal := RG_XFER_UTILS_PKG.G_ML_Normal;
  G_ML_Full := RG_XFER_UTILS_PKG.G_ML_Full;

END RG_XFER_COMPONENTS_PKG;

/
