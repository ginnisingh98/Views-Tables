--------------------------------------------------------
--  DDL for Package GCS_XML_DT_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_XML_DT_UTILITY_PKG" AUTHID CURRENT_USER AS
  /* $Header: gcsxmldtutils.pls 120.12 2007/05/04 12:07:41 sangarg noship $ */

  -- Declare parameter with same name as declared in data template
  -- So that XDO resolves parameter mapping to Data Template parameters
  -- and this package APIs can utilize values supplied by calling program
  pEntityId number;
  --fix#5087857
  pRunName   varchar2(240);
  pXmlFileId number;

  pLanguageCode            varchar2(20);
  pCalPeriodEndDateAttr    number;
  pCalPeriodEndDateVersion number;
  pEntityTypeAttr          number;
  pEntityTypeVersion       number;
  pEntityLedgerAttr        number;
  pEntityLedgerVersion     number;
  pEntitySrcsysAttr        number;
  pEntitySrcsysVersion     number;
  pLedgerCurrAttr          number;
  pLedgerCurrVersion       number;
  pLedgerVsComboAttr       number;
  pLedgerVsComboVersion    number;

  --start bug fix 5480573
  --Paramneter Values for Adjustment Writeback
  accountName               VARCHAR2(2500);
  pUserName                 VARCHAR2(100);
  pEntityEnabledFlagVersion NUMBER;
  pEntityEnabledFlagAttr    NUMBER;
  --end bug fix 5480573

  --start bug fix 5518000
  -- Parameter Values for Entries
  addWhereClause   VARCHAR2(200);
  addREWhereClause VARCHAR2(200);

  pSourceUI             VARCHAR2(20);
  pCalPeriodYearAttr    NUMBER;
  pCalPeriodYearVersion NUMBER;
  --end bug fix 5518000

  -- Literal values returned to data template
  entityIdListLiteral varchar2(10000);
  dsSelectLiteral     varchar2(10000);
  finElemsLiteral     varchar2(150);
  currencyLiteral     varchar2(150);
  currencyTypeLiteral varchar2(150);
  entityOrgsLiteral   varchar2(5000);

  --Literal Values for Data Sub Impacted Balances Posted Report
  FilterParamsLiteral VARCHAR2(5000) := ' ';
  LedgerLiteral       VARCHAR2(150);
  --Parameter Values for Data Sub Impacted Balances Posted Report
  pCalPeriodId   NUMBER;
  pCurrency      VARCHAR2(100);
  pEntityName    VARCHAR2(150);
  pCalPeriodName VARCHAR2(150);
  pDataTypeCode  VARCHAR2(150);
  pLoadId        NUMBER;
  pOrgId         NUMBER;
  pDataTypeName  VARCHAR2(150);
  pCurrName      VARCHAR2(150);

  -- Start of Bugfix: 5861665
  --Literal Values defined for Inter Company Matching Report
  -- for consolidation entities
  counterEntityIdLiteral VARCHAR2(150);
  ruleIdLiteral          VARCHAR2(150);
  suspenseExFlagLiteral  VARCHAR2(150);
  --Parameter Values defined for Inter Company Matching Report
  -- for consolidation entities
  pHierarchy       NUMBER;
  -- Bugfix: 6020393
  -- pHierarchyName   VARCHAR2(100);
  pEntity          NUMBER;
  -- Bugfix: 6006700 Variable pEntityName is already decleared above
  -- pEntityName   VARCHAR2(150);
  pCEntity         NUMBER;
  pPeriod          VARCHAR2(150);
  pCalName         VARCHAR2(150);
  pRule            VARCHAR2(150);
  -- Bugfix: 6020393
  -- pRuleName        VARCHAR2(150);
  pDataTemplate    VARCHAR2(150);
  -- Bugfix: 6008841 Variables removed from Data template
  -- pNoCase          VARCHAR2(150);
  -- pYesCase         VARCHAR2(150);
  pTransactionType VARCHAR2(2);
  pDrillDnEnabled  VARCHAR2(150);
  -- BugFix: 6004119
  -- pLanguageCode    VARCHAR2(150);
  pBalanceTypeCode VARCHAR2(150);
  -- End of Bugfix: 5861665

  --
  -- Function
  --   before_cmtb_report
  -- Purpose
  --   An API to handle consolidation Trial Balance Data Template Literals
  -- Arguments
  -- Notes
  --
  FUNCTION before_cmtb_report RETURN BOOLEAN;
  --
  -- Function
  --   before_dstb_report
  -- Purpose
  --   An API to handle Data Submission Trial Balance Data Template Literals
  -- Arguments
  -- Notes
  --
  FUNCTION before_dstb_report RETURN BOOLEAN;
  --
  -- Function
  --   before_femnonposted_report
  -- Purpose
  --   An API to handle Fem Non Reported Rows
  -- Arguments
  -- Notes
  --
  FUNCTION before_femnonposted_report RETURN BOOLEAN;

  --
  -- Function
  --   writeback_report
  -- Purpose
  --   An API to handle GL Writeback of Consolidation Entries
  -- Arguments
  -- Notes
  --
  FUNCTION writeback_report RETURN BOOLEAN;

  --
  -- Function
  --   before_entry_report
  -- Purpose
  --   Adds the additional where clasue to the query displaying the entry
  --   report data depending upon the LINE_TYPE_CODE column.
  -- Arguments
  -- Notes
  --   Added to fix bug 5518000.
  --
  FUNCTION before_entry_report RETURN BOOLEAN;

  --
  -- Function
  --   intercompany_report
  -- Purpose
  --   Returns where clause as per the variable values passed and
  --   are appended to the data template query
  -- Arguments
  -- Notes
  --   Added to fix bug 5861665.
  --
  FUNCTION intercompany_report RETURN BOOLEAN;

END GCS_XML_DT_UTILITY_PKG;

/
