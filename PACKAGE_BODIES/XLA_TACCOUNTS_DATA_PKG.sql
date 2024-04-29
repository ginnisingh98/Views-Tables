--------------------------------------------------------
--  DDL for Package Body XLA_TACCOUNTS_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TACCOUNTS_DATA_PKG" AS
/* $Header: xlatacct.pkb 120.4 2005/04/28 18:45:37 masada ship $ */

/*===========================================================================+
 -- Forward Declarations
 +===========================================================================*/

-- Used for debugging. Prints the line type for a given line type code.
FUNCTION getlinetype (p_typeid BINARY_INTEGER ,
                      p_tatb   VARCHAR2      DEFAULT 'ta') RETURN VARCHAR2;

FUNCTION getTotal( p_total_amount       IN      NUMBER
                  ,p_current_amount     IN      NUMBER
                 ) RETURN NUMBER;

FUNCTION getStatement (
         p_Application_id        IN      NUMBER
        ,p_Trx_Header_Table      IN      VARCHAR2
        ,p_Trx_Header_ID         IN      NUMBER
        ,p_Cost_Type_ID          IN      NUMBER
        ,p_Organize_By           IN      VARCHAR2       -- ACCOUNT | SEGMENT
        ,p_Segment1              IN      NUMBER
        ,p_Segment2              IN      NUMBER
        ,p_OverRidingWhereClause IN      VARCHAR2
        ,p_viewName              IN      VARCHAR2
        ,p_add_col_name_1        IN      VARCHAR2 DEFAULT NULL
        ,p_add_col_value_1       IN      VARCHAR2 DEFAULT NULL
        ,p_add_col_name_2        IN      VARCHAR2 DEFAULT NULL
        ,p_add_col_value_2       IN      VARCHAR2 DEFAULT NULL
         )
  RETURN VARCHAR2;


PROCEDURE getBalances(balanceDr           OUT NOCOPY NUMBER
                     ,balanceCr           OUT NOCOPY NUMBER
                     ,codeCombinationsID  IN NUMBER
                     ,periodName          IN VARCHAR2
                     ,accountType         IN VARCHAR2);

PROCEDURE  getAccountBalance( p_amount           IN NUMBER
                             ,p_trx_hdr_id       IN NUMBER
                             ,p_amount_dr        OUT NOCOPY NUMBER
                             ,p_amount_cr        OUT NOCOPY NUMBER
                             ,p_Ccid             IN NUMBER
                             ,p_account_type     IN VARCHAR2
                             );

PROCEDURE getNetBalance(p_AccountedDr  IN OUT NOCOPY NUMBER
                       ,p_AccountedCr  IN OUT NOCOPY NUMBER
                       ,p_AccountType  IN     VARCHAR2);


FUNCTION getReportingCurrency RETURN VARCHAR2;

FUNCTION secure( p_CCID  IN NUMBER
                ,p_TATB  IN VARCHAR2)
 RETURN BOOLEAN;


/*===========================================================================+
 -- Private Data types
 +===========================================================================*/

/*===========================================================================+
 -- Private Variables
 +===========================================================================*/
  prv_OrganizeBy                 VARCHAR2(8);
  prv_ChartOfAccountsID          NUMBER;
  prv_Segment1                   NUMBER;
  prv_Segment2                   NUMBER;
  prv_FlexDelimiter              VARCHAR2(30);
  prv_ApplicationId              NUMBER;
  prv_Trx_Hdr_id                 NUMBER;

  prv_SetOfBooksID               NUMBER;

  c_ta NUMBER;    -- Cursor for TAccounts
  c_tb Number;    -- Cursor for Trial Balance

  -- Global variables for T-Accounts

  -- Currency Totals
  g_totalEnteredCurDr   NUMBER := 0;
  g_totalEnteredCurCr   NUMBER := 0;
  g_totalAccountedCurDr NUMBER := 0;
  g_totalAccountedCurCr NUMBER := 0;
  g_totalReportingCurDr NUMBER := 0;
  g_totalReportingCurCr NUMBER := 0;

  -- Account Totals
  g_totalEntCcidDr       NUMBER := 0;
  g_totalEntCcidCr       NUMBER := 0;
  g_totalAcctCcidDr      NUMBER := 0;
  g_totalAcctCcidCr      NUMBER := 0;
  g_totalReportingCcidDr NUMBER := 0;
  g_totalReportingCcidCr NUMBER := 0;

  -- Report Totals
  g_totalNetAccountedDr NUMBER := 0;
  g_totalNetAccountedCr NUMBER := 0;
  g_totalNetReportingDr NUMBER := 0;
  g_totalNetReportingCr NUMBER := 0;

  g_openingBalanceDr    NUMBER := 0;
  g_openingBalanceCr    NUMBER := 0;
  g_closingBalanceDr    NUMBER := 0;
  g_closingBalanceCr    NUMBER := 0;

  g_currency_cnt        NUMBER := 0;
  g_currency_code       FND_CURRENCIES.currency_code%TYPE;
  g_account_type        GL_CODE_COMBINATIONS.account_type%TYPE;
  g_period_name         VARCHAR2(30);
  g_current_account     VARCHAR2(255);
  g_current_Ccid        NUMBER;
  g_accountingCurrency  FND_CURRENCIES.currency_code%TYPE;
  g_reportingCurrency   FND_CURRENCIES.currency_code%TYPE;

  g_firstRow                   BOOLEAN;
  g_validateflex               BOOLEAN;
  g_secure                     BOOLEAN;
  g_disp_segments              VARCHAR2(30);
  g_segment_values             VARCHAR2(1000);
  g_segments_desc              VARCHAR2(2000);
  g_current_segment_values     VARCHAR2(1000);
  g_current_segments_desc      VARCHAR2(2000);

  -- Global variables for Trial Balance
  -- Currency Totals
  g_tb_totalEnteredCurDr       NUMBER := 0;
  g_tb_totalEnteredCurCr       NUMBER := 0;
  g_tb_totalAccountedCurDr     NUMBER := 0;
  g_tb_totalAccountedCurCr     NUMBER := 0;
  g_tb_totalReportingCurDr     NUMBER := 0;
  g_tb_totalReportingCurCr     NUMBER := 0;

  -- Account Totals
  g_tb_totalEntCcidDr          NUMBER := 0;
  g_tb_totalEntCcidCr          NUMBER := 0;
  g_tb_totalAcctCcidDr         NUMBER := 0;
  g_tb_totalAcctCcidCr         NUMBER := 0;
  g_tb_totalReportingCcidDr    NUMBER := 0;
  g_tb_totalReportingCcidCr    NUMBER := 0;

  -- Report Totals
  g_tb_totalNetAccountedDr     NUMBER := 0;
  g_tb_totalNetAccountedCr     NUMBER := 0;
  g_tb_totalNetReportingDr     NUMBER := 0;
  g_tb_totalNetReportingCr     NUMBER := 0;

  g_tb_openingBalanceDr        NUMBER := 0;
  g_tb_openingBalanceCr        NUMBER := 0;
  g_tb_closingBalanceDr        NUMBER := 0;
  g_tb_closingBalanceCr        NUMBER := 0;

  g_tb_currency_cnt            NUMBER := 0;
  g_tb_currency_code           FND_CURRENCIES.currency_code%TYPE;
  g_tb_account_type            GL_CODE_COMBINATIONS.account_type%TYPE;
  g_tb_period_name             VARCHAR2(30);
  g_tb_current_account         VARCHAR2(255);
  g_tb_current_Ccid            NUMBER;

  g_tb_firstRow                BOOLEAN ;
  g_tb_validateflex            BOOLEAN;
  g_tb_secure                  BOOLEAN;
  g_tb_disp_segments           VARCHAR2(30);
  g_tb_segment_values          VARCHAR2(1000);
  g_tb_segments_desc           VARCHAR2(2000);
  g_tb_current_segment_values  VARCHAR2(1000);
  g_tb_current_segments_desc   VARCHAR2(2000);
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;

C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_TACCOUNTS_DATA_PKG';

g_debug_flag          VARCHAR2(1) := NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');

--l_log_module          VARCHAR2(240);
g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'XLA_TACCOUNTS_DATA_PKG.trace');
END trace;

/*===========================================================================+
 -- Procedure/functions
 +===========================================================================*/

FUNCTION xla_supported(p_application_id in NUMBER)
 RETURN NUMBER
is
l_log_module                VARCHAR2(240);
temp number;
cursor c_xla_subledgers is
  select application_id
    from xla_subledgers
   where application_id=p_application_id;
begin
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.xla_supported';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure xla_supported'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


  open c_xla_subledgers;
  fetch c_xla_subledgers into temp;
  if c_xla_subledgers%FOUND then
    temp:=1;
  else
    temp:=0;
  end if;
  close c_xla_subledgers;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'return value. = '||TO_CHAR(temp)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'END of function xla_supported'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

  return temp;

end xla_supported;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Init                                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  p_Application_Id        -- E.g 222 for Receivables      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-Sep-98  Dirk Stevens        Created                                |
 |     04-Aug-99  Mahesh Sabapthy       Added parameter cost_type_id to      |
 |                                      support Mfg. PAC transactions.       |
 +===========================================================================*/
   PROCEDURE TA_Init (
                      p_Application_ID        IN      NUMBER
                      ,p_Trx_Header_Table      IN      VARCHAR2
                      ,p_Trx_Header_ID         IN      NUMBER
                      ,p_Cost_Type_ID          IN      NUMBER
                      ,p_Chart_Of_Accounts_Id  IN      NUMBER
                      ,p_Set_Of_Books_ID       IN      NUMBER
                      ,p_Organize_By           IN      VARCHAR2
                      ,p_Segment1              IN      NUMBER
                      ,p_Segment2              IN      NUMBER
                      ,p_OverRidingWhereClause IN      VARCHAR2
                      ,p_viewName              IN      VARCHAR2
                      ,p_add_col_name_1        IN      VARCHAR2 DEFAULT NULL
                      ,p_add_col_value_1       IN      VARCHAR2 DEFAULT NULL
                      ,p_add_col_name_2        IN      VARCHAR2 DEFAULT NULL
                      ,p_add_col_value_2       IN      VARCHAR2 DEFAULT NULL
                      ) IS

rows                  INTEGER;
statement             VARCHAR2(32000);

l_ccid                NUMBER;
l_account             VARCHAR2(255);
l_segment1_value      VARCHAR2(255);
l_segment2_value      VARCHAR2(255);
l_segment3_value      VARCHAR2(255);
l_segment4_value      VARCHAR2(255);
l_ae_line_ref         VARCHAR2(1000);
l_ae_line_ref_int     VARCHAR2(1000);
l_entered_currency    VARCHAR2(15);
l_entered_dr          NUMBER;
l_entered_cr          NUMBER;
l_acctd_dr            NUMBER;
l_acctd_cr            NUMBER;
l_report_dr           NUMBER;
l_report_cr           NUMBER;
l_period_name         VARCHAR2(15);      -- Applicable only to GL
l_status              VARCHAR2(1);       -- Applicable only to GL
l_account_type        VARCHAR2(1);
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.TA_INIT';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure TA_INIT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


  /* Set all private globals */
  prv_OrganizeBy    := p_Organize_By;
  prv_ApplicationId := p_Application_Id;
  prv_Trx_Hdr_Id    := p_Trx_Header_Id;
  g_currency_cnt    := 0;
  g_firstRow        := Null;
  g_secure          := FALSE;

  -- Initialize totals

  -- Currency Totals
  g_totalEnteredCurDr     := null;
  g_totalEnteredCurCr     := null;
  g_totalAccountedCurDr   := null;
  g_totalAccountedCurCr   := null;
  g_totalReportingCurDr   := null;
  g_totalReportingCurCr   := null;

  -- Account Totals
  g_totalEntCcidDr         := null;
  g_totalEntCcidCr         := null;
  g_totalAcctCcidDr        := null;
  g_totalAcctCcidCr        := null;
  g_totalReportingCcidDr   := null;
  g_totalReportingCcidCr   := null;

  -- Report Totals
  g_totalNetAccountedDr   := 0;
  g_totalNetAccountedCr   := 0;
  g_totalNetReportingDr   := 0;
  g_totalNetReportingCr   := 0;


  g_currency_cnt          := 0;

  prv_ChartOfAccountsID := p_Chart_Of_Accounts_ID;
  prv_Segment1          := p_Segment1;
  prv_Segment2          := p_Segment2;

  prv_SetOfBooksID      := p_Set_Of_Books_ID;

  g_accountingCurrency := getAccountingCurrency(prv_SetOfBooksID);
  g_reportingCurrency  := getReportingCurrency;

  statement := getStatement(  p_Application_ID
                             ,p_Trx_Header_Table
                             ,p_Trx_Header_ID
                             ,p_Cost_Type_ID
                             ,p_Organize_by
                             ,p_Segment1
                             ,p_Segment2
                             ,p_OverRidingWhereClause
                             ,p_viewName
                             ,p_add_col_name_1
                             ,p_add_col_value_1
                             ,p_add_col_name_2
                             ,p_add_col_value_2
                             );
  c_ta := dbms_sql.open_cursor;
  dbms_sql.parse(c_ta, statement, dbms_sql.native);

  -- Generic bind
  dbms_sql.bind_variable(c_ta, 'appl_id', p_application_id);
  dbms_sql.bind_variable(c_ta, 'set_of_books_id', p_set_of_books_id);

  -- Transaction specific bind
  IF ( p_overRidingWhereClause IS NULL ) THEN
     IF ( p_add_col_name_1 IS NOT NULL ) THEN
            dbms_sql.bind_variable(c_ta, 'add_col_value_1', p_add_col_value_1);
     END IF;

     IF ( p_add_col_name_2 IS NOT NULL ) THEN
       dbms_sql.bind_variable(c_ta, 'add_col_value_2', p_add_col_value_2);
     END IF;

     IF ( p_trx_header_table IS NOT NULL ) THEN
            dbms_sql.bind_variable(c_ta, 'trx_header_table', p_trx_header_table);
     END IF;

     IF ( p_trx_header_id IS NOT NULL ) THEN
            dbms_sql.bind_variable(c_ta, 'trx_header_id', p_trx_header_id);
     END IF;

            -- Mfg. PAC transactions support
     IF ( p_Cost_Type_ID IS NOT NULL ) THEN
       dbms_sql.bind_variable(c_ta, 'cost_type_id', p_cost_type_id);
     END IF;

  END IF;

  -- Define columns
  dbms_sql.define_column( c_ta, 1, l_ccid );
  dbms_sql.define_column( c_ta, 2, l_segment1_value, 255 );
  dbms_sql.define_column( c_ta, 3, l_segment2_value, 255 );
  dbms_sql.define_column( c_ta, 4, l_segment3_value, 255 );
  dbms_sql.define_column( c_ta, 5, l_segment4_value, 255 );
  dbms_sql.define_column( c_ta, 6, l_ae_line_ref, 1000 );
  dbms_sql.define_column( c_ta, 7, l_ae_line_ref_int, 1000 );
  dbms_sql.define_column( c_ta, 8, l_entered_currency, 15 );
  dbms_sql.define_column( c_ta, 9, l_entered_dr );
  dbms_sql.define_column( c_ta, 10, l_entered_cr );
  dbms_sql.define_column( c_ta, 11, l_acctd_dr );
  dbms_sql.define_column( c_ta, 12, l_acctd_cr );
  dbms_sql.define_column( c_ta, 13, l_report_dr );
  dbms_sql.define_column( c_ta, 14, l_report_cr );
  dbms_sql.define_column( c_ta, 15, l_period_name, 15 );
  dbms_sql.define_column( c_ta, 16, l_status , 1 );
  dbms_sql.define_column( c_ta, 17, l_account_type , 1 );

  rows := dbms_sql.execute(c_ta);
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure TA_INIT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


END TA_Init;

PROCEDURE TB_Init  (
                    p_Application_ID         IN      NUMBER
                    ,p_Trx_Header_Table      IN      VARCHAR2
                    ,p_Trx_Header_ID         IN      NUMBER
                    ,p_Cost_Type_ID          IN      NUMBER
                    ,p_Chart_Of_Accounts_Id  IN      NUMBER
                    ,p_Set_Of_Books_ID       IN      NUMBER
                    ,p_Organize_By           IN      VARCHAR2
                    ,p_Segment1              IN      NUMBER
                    ,p_Segment2              IN      NUMBER
                    ,p_OverRidingWhereClause IN      VARCHAR2
                    ,p_viewName              IN      VARCHAR2
                    ,p_add_col_name_1        IN      VARCHAR2 DEFAULT NULL
                    ,p_add_col_value_1       IN      VARCHAR2 DEFAULT NULL
                    ,p_add_col_name_2        IN      VARCHAR2 DEFAULT NULL
                    ,p_add_col_value_2       IN      VARCHAR2 DEFAULT NULL
                    ) IS

  rows                  INTEGER;
  statement             VARCHAR2(32000);

  l_ccid                NUMBER;
  l_account             VARCHAR2(255);
  l_segment1_value      VARCHAR2(255);
  l_segment2_value      VARCHAR2(255);
  l_segment3_value      VARCHAR2(255);
  l_segment4_value      VARCHAR2(255);
  l_ae_line_ref         VARCHAR2(1000);
  l_ae_line_ref_int     VARCHAR2(1000);
  l_entered_currency    VARCHAR2(15);
  l_entered_dr          NUMBER;
  l_entered_cr          NUMBER;
  l_acctd_dr            NUMBER;
  l_acctd_cr            NUMBER;
  l_report_dr           NUMBER;
  l_report_cr           NUMBER;
  l_period_name         VARCHAR2(15);       -- Applicable only to GL
  l_status              VARCHAR2(1);       -- Applicable only to GL
  l_account_type        VARCHAR2(1);
l_log_module                VARCHAR2(240);


BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.TB_INIT';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure TB_INIT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;
  /* Set all private globals */
  prv_OrganizeBy    := p_Organize_By;
  prv_ApplicationId := p_Application_Id;
  prv_Trx_Hdr_Id    := p_Trx_Header_Id;
  g_tb_currency_cnt := 0;
  g_tb_firstrow     := NULL;
  g_tb_secure       := FALSE;


  -- Initialize Varibles
  g_tb_totalEnteredCurDr     := null;
  g_tb_totalEnteredCurCr     := null;
  g_tb_totalAccountedCurDr   := null;
  g_tb_totalAccountedCurCr   := null;
  g_tb_totalReportingCurDr   := null;
  g_tb_totalReportingCurCr   := null;

  -- Account Totals
  g_tb_totalEntCcidDr         := null;
  g_tb_totalEntCcidCr         := null;
  g_tb_totalAcctCcidDr        := null;
  g_tb_totalAcctCcidCr        := null;
  g_tb_totalReportingCcidDr   := null;
  g_tb_totalReportingCcidCr   := null;

  -- Report Totals
  g_tb_totalNetAccountedDr   := 0;
  g_tb_totalNetAccountedCr   := 0;
  g_tb_totalNetReportingDr   := 0;
  g_tb_totalNetReportingCr   := 0;

  g_tb_openingBalanceDr      := 0;
  g_tb_openingBalanceCr      := 0;
  g_tb_closingBalanceDr      := 0;
  g_tb_closingBalanceCr      := 0;

  g_tb_currency_cnt          := 0;



  prv_ChartOfAccountsID := p_Chart_Of_Accounts_ID;
  prv_Segment1 := p_Segment1;
  prv_Segment2 := p_Segment2;

  prv_SetOfBooksID := p_Set_Of_Books_ID;

  g_accountingCurrency := getAccountingCurrency(prv_SetOfBooksID);
  g_reportingcurrency  := getReportingCurrency;

  statement := getStatement(  p_Application_ID
                             ,p_Trx_Header_Table
                             ,p_Trx_Header_ID
                             ,p_Cost_Type_ID
                             ,p_Organize_by
                             ,p_Segment1
                             ,p_Segment2
                             ,p_OverRidingWhereClause
                             ,p_viewName
                             ,p_add_col_name_1
                             ,p_add_col_value_1
                             ,p_add_col_name_2
                             ,p_add_col_value_2
                             );
  c_tb := dbms_sql.open_cursor;
  dbms_sql.parse(c_tb, statement, dbms_sql.native);

  -- Generic bind
  dbms_sql.bind_variable(c_tb, 'appl_id', p_application_id);
  dbms_sql.bind_variable(c_tb, 'set_of_books_id', p_set_of_books_id);

  -- Transaction specific bind
  IF ( p_overRidingWhereClause IS NULL )
  THEN
     IF ( p_add_col_name_1 IS NOT NULL ) THEN
            dbms_sql.bind_variable(c_tb, 'add_col_value_1', p_add_col_value_1);
     END IF;

     IF ( p_add_col_name_2 IS NOT NULL ) THEN
       dbms_sql.bind_variable(c_tb, 'add_col_value_2', p_add_col_value_2);
     END IF;

     IF ( p_trx_header_table IS NOT NULL ) THEN
            dbms_sql.bind_variable(c_tb, 'trx_header_table', p_trx_header_table);
     END IF;

     IF ( p_trx_header_id IS NOT NULL ) THEN
            dbms_sql.bind_variable(c_tb, 'trx_header_id', p_trx_header_id);
     END IF;

            -- Mfg. PAC transactions support
     IF ( p_Cost_Type_ID IS NOT NULL ) THEN
       dbms_sql.bind_variable(c_tb, 'cost_type_id', p_cost_type_id);
     END IF;

  END IF;

  -- Define columns
  dbms_sql.define_column( c_tb, 1, l_ccid );
  dbms_sql.define_column( c_tb, 2, l_segment1_value, 255 );
  dbms_sql.define_column( c_tb, 3, l_segment2_value, 255 );
  dbms_sql.define_column( c_tb, 4, l_segment3_value, 255 );
  dbms_sql.define_column( c_tb, 5, l_segment4_value, 255 );
  dbms_sql.define_column( c_tb, 6, l_ae_line_ref, 1000 );
  dbms_sql.define_column( c_tb, 7, l_ae_line_ref_int, 1000 );
  dbms_sql.define_column( c_tb, 8, l_entered_currency, 15 );
  dbms_sql.define_column( c_tb, 9, l_entered_dr );
  dbms_sql.define_column( c_tb, 10, l_entered_cr );
  dbms_sql.define_column( c_tb, 11, l_acctd_dr );
  dbms_sql.define_column( c_tb, 12, l_acctd_cr );
  dbms_sql.define_column( c_tb, 13, l_report_dr );
  dbms_sql.define_column( c_tb, 14, l_report_cr );
  dbms_sql.define_column( c_tb, 15, l_period_name, 15 );
  dbms_sql.define_column( c_tb, 16, l_status , 1 );
  dbms_sql.define_column( c_tb, 17, l_account_type , 1 );

  rows := dbms_sql.execute(c_tb);
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'end of procedure TB_INIT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

END TB_Init;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    getStatement                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Get the SQL statement to execute based on the parameters passed.        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-Sep-98  Dirk Stevens        Created                                |
 |     04-Aug-99  Mahesh Sabapthy       Added parameter cost_type_id to      |
 |                                      support Mfg. PAC transactions.       |
 +===========================================================================*/
   FUNCTION getStatement (
                          p_Application_id         IN      NUMBER
                          ,p_Trx_Header_Table      IN      VARCHAR2
                          ,p_Trx_Header_ID         IN      NUMBER
                          ,p_Cost_Type_ID          IN      NUMBER
                          ,p_Organize_By           IN      VARCHAR2       -- ACCOUNT | SEGMENT
                          ,p_Segment1              IN      NUMBER
                          ,p_Segment2              IN      NUMBER
                          ,p_OverRidingWhereClause IN      VARCHAR2
                          ,p_viewName              IN      VARCHAR2
                          ,p_add_col_name_1        IN      VARCHAR2 DEFAULT NULL
                          ,p_add_col_value_1       IN      VARCHAR2 DEFAULT NULL
                          ,p_add_col_name_2        IN      VARCHAR2 DEFAULT NULL
                          ,p_add_col_value_2       IN      VARCHAR2 DEFAULT NULL
                          ) RETURN VARCHAR2 IS

  l_select_clause       VARCHAR2(2000);
  l_ordered_account     VARCHAR2(2000);
  l_from_clause         VARCHAR2(2000);
  l_where_clause        VARCHAR2(32000);
  l_group_by_clause     VARCHAR2(2000);
  l_order_by_clause     VARCHAR2(2000);
  l_statement           VARCHAR2(32000);

  l_flex_appl_id        CONSTANT NUMBER := 101;
  l_id_flex_code        CONSTANT VARCHAR2(10) := 'GL#';
  l_flex_delimiter      VARCHAR2(10);
  l_segment1_column     VARCHAR2(30);
  l_segment2_column     VARCHAR2(30);
  l_segment3_column     VARCHAR2(30);
  l_segment4_column     VARCHAR2(30);
  l_seg_name            VARCHAR2(30);
  l_prompt              VARCHAR2(50);
  l_value_set_name      VARCHAR2(50);
  l_dummy_flex_ret_value     BOOLEAN;
  l_parentseg_num       NUMBER;
  l_parentseg_column    VARCHAR2(30);

  l_segmentinfo        xla_flex_util.t_segmentinfo;
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.getStatement';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of function getStatement'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

   -- Build Select clause
   IF p_organize_by = 'ACCOUNT' THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'By Account'
            ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
      END IF;

      -- Get description for all segments
       g_disp_segments := 'ALL';

       IF ( p_Application_id <> 101 ) THEN

          l_select_clause := 'SELECT
                             AEL_V.CODE_COMBINATION_ID          CC_ID
                            ,TO_CHAR(AEL_V.CODE_COMBINATION_ID) SEGMENT1_VALUE
                            ,TO_CHAR(NULL)                      SEGMENT2_VALUE
                            ,TO_CHAR(NULL)                      SEGMENT3_VALUE
                            ,TO_CHAR(NULL)                      SEGMENT4_VALUE
                            ,AEL_V.AE_LINE_REFERENCE            AE_LINE_REF
                            ,AEL_V.AE_LINE_REFERENCE_INTERNAL   AE_LINE_REF_INT
                            ,AEL_V.CURRENCY_CODE                CURRENCY_CODE
                            ,AEL_V.ENTERED_DR                   ENTERED_DR
                            ,AEL_V.ENTERED_CR                   ENTERED_CR
                            ,AEL_V.ACCOUNTED_DR                 ACCOUNTED_DR
                            ,AEL_V.ACCOUNTED_CR                 ACCOUNTED_CR
                            ,TO_NUMBER(NULL)                    REPORT_DR
                            ,TO_NUMBER(NULL)                    REPORT_CR
                            ,TO_CHAR(NULL)                      PERIOD_NAME
                            ,TO_CHAR(NULL)                      STATUS
                            ,GLCC.ACCOUNT_TYPE                  ACCOUNT_TYPE ';
     ELSE

            l_select_clause := 'SELECT
                             AEL_V.CODE_COMBINATION_ID          CC_ID
                            ,TO_CHAR(AEL_V.CODE_COMBINATION_ID) SEGMENT1_VALUE
                            ,TO_CHAR(NULL)                      SEGMENT2_VALUE
                            ,TO_CHAR(NULL)                      SEGMENT3_VALUE
                            ,TO_CHAR(NULL)                      SEGMENT4_VALUE
                            ,AEL_V.AE_LINE_REFERENCE            AE_LINE_REF
                            ,AEL_V.AE_LINE_REFERENCE_INTERNAL   AE_LINE_REF_INT
                            ,AEL_V.CURRENCY_CODE                CURRENCY_CODE
                            ,AEL_V.ENTERED_DR                   ENTERED_DR
                            ,AEL_V.ENTERED_CR                   ENTERED_CR
                            ,AEL_V.ACCOUNTED_DR                 ACCOUNTED_DR
                            ,AEL_V.ACCOUNTED_CR                 ACCOUNTED_CR
                            ,TO_NUMBER(NULL)                    REPORT_DR
                            ,TO_NUMBER(NULL)                    REPORT_CR
                            ,AEL_V.PERIOD_NAME                  PERIOD_NAME
                            ,AEL_V.STATUS                       STATUS
                            ,GLCC.ACCOUNT_TYPE                  ACCOUNT_TYPE ';
     END IF;

  ELSE

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
            (p_msg      => 'By Segment'
            ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
     END IF;
     -- Get Segment Delimiter
     prv_FlexDelimiter := FND_FLEX_APIS.GET_SEGMENT_DELIMITER(
                                     l_flex_appl_id
                                    ,l_id_flex_code
                                    ,prv_ChartOfAccountsID );

     -- Get parent segment for first segment
     xla_flex_util.get_parent_segment(l_flex_appl_id,
                                      l_id_flex_code,
                                      prv_chartofaccountsid,
                                      p_segment1,
                                      l_parentseg_num,
                                      l_parentseg_column
                                      );

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
            (p_msg      => 'l_parentseg_num  ' || l_parentseg_num
            ,p_level    => C_LEVEL_STATEMENT
         ,p_module   =>l_log_module);
     END IF;
--     xla_util.debug('l_parentseg_num  ' || l_parentseg_num);
     IF l_parentseg_num IS NOT NULL THEN
       l_dummy_flex_ret_value := FND_FLEX_APIS.GET_SEGMENT_INFO(
                                      l_flex_appl_id
                                     ,l_id_flex_code
                                     ,prv_ChartOfAccountsID
                                     ,l_parentseg_num
                                     ,l_segment1_column
                                     ,l_seg_name
                                     ,l_prompt
                                     ,l_value_set_name);
       END IF;

       -- Call API to get flexfield info
       IF ( NOT XLA_FLEX_UTIL.getSegmentInfo(prv_chartofaccountsid,
                                        l_segmentinfo))  THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

       IF p_segment1 = l_parentseg_num THEN
         g_disp_segments := l_segmentInfo(l_parentseg_num).segment_ordernum;
       ELSE
         g_disp_segments := l_segmentInfo(l_parentseg_num).segment_ordernum || '\0' ||
                            l_segmentInfo(p_segment1).segment_ordernum;
       END IF;


       l_dummy_flex_ret_value := FND_FLEX_APIS.GET_SEGMENT_INFO(
                                              l_flex_appl_id
                                             ,l_id_flex_code
                                             ,prv_ChartOfAccountsID
                                             ,p_segment1
                                             ,l_segment2_column
                                             ,l_seg_name
                                             ,l_prompt
                                             ,l_value_set_name);

       xla_flex_util.get_parent_segment(l_flex_appl_id,
                                    l_id_flex_code,
                                    prv_chartofaccountsid,
                                    p_segment2,
                                    l_parentseg_num,
                                    l_parentseg_column
                                    );
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
            (p_msg      =>'p_segment2 ' || p_segment2
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
       END IF;
--       xla_util.debug('p_segment2 ' || p_segment2);
       IF l_parentseg_num IS NOT NULL THEN
         l_dummy_flex_ret_value := FND_FLEX_APIS.GET_SEGMENT_INFO(
                                     l_flex_appl_id
                                    ,l_id_flex_code
                                    ,prv_ChartOfAccountsID
                                    ,l_parentseg_num
                                    ,l_segment3_column
                                    ,l_seg_name
                                    ,l_prompt
                                    ,l_value_set_name);
       END IF;

       l_dummy_flex_ret_value := FND_FLEX_APIS.GET_SEGMENT_INFO(
                                   l_flex_appl_id
                                  ,l_id_flex_code
                                  ,prv_ChartOfAccountsID
                                  ,p_segment2
                                  ,l_segment4_column
                                  ,l_seg_name
                                  ,l_prompt
                                  ,l_value_set_name);

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
            (p_msg      =>'segments ' ||  l_segment1_column || l_segment2_column || l_segment3_column || l_segment4_column
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   =>l_log_module);
       END IF;
--       xla_util.debug('segments ' ||  l_segment1_column || l_segment2_column || l_segment3_column || l_segment4_column);

       IF p_segment2 = l_parentseg_num THEN
         IF l_segment3_column NOT IN (l_segment1_column, l_segment2_column) THEN
            g_disp_segments := g_disp_segments || '\0'||
                                l_segmentInfo(l_parentseg_num).segment_ordernum;
         END IF;
       ELSE
         IF l_segment4_column not in (l_segment1_column, l_segment2_column,l_segment3_column) THEN
            g_disp_segments := g_disp_segments || '\0'||
                                l_segmentInfo(l_parentseg_num).segment_ordernum
                     || '\0' || l_segmentInfo(p_segment2).segment_ordernum;
         END IF;
       END IF;

       -- Build Select Clause
       IF ( p_application_id <> 101 ) THEN
         l_select_clause := 'SELECT
                             AEL_V.CODE_COMBINATION_ID                CC_ID
                            ,GLCC.'||l_segment1_column||'             SEGMENT1_VALUE
                            ,GLCC.'||l_segment2_column||'             SEGMENT2_VALUE
                            ,GLCC.'||l_segment3_column||'             SEGMENT3_VALUE
                            ,GLCC.'||l_segment4_column||'             SEGMENT4_VALUE
                            ,AEL_V.AE_LINE_REFERENCE                  AE_LINE_REF
                            ,AEL_V.AE_LINE_REFERENCE_INTERNAL         AE_LINE_REF_INT
                            ,AEL_V.CURRENCY_CODE                      CURRENCY_CODE
                            ,AEL_V.ENTERED_DR                         ENTERED_DR
                            ,AEL_V.ENTERED_CR                         ENTERED_CR
                            ,AEL_V.ACCOUNTED_DR                       ACCOUNTED_DR
                            ,AEL_V.ACCOUNTED_CR                       ACCOUNTED_CR
                            ,TO_NUMBER(NULL)                          REPORT_DR
                            ,TO_NUMBER(NULL)                          REPORT_CR
                            ,TO_CHAR(NULL)                            PERIOD_NAME
                            ,TO_CHAR(NULL)                            STATUS
                            ,GLCC.ACCOUNT_TYPE                        ACCOUNT_TYPE ';
        ELSE
         l_select_clause := 'SELECT
                                AEL_V.CODE_COMBINATION_ID             CC_ID
                               ,GLCC.'||l_segment1_column||'          SEGMENT1_VALUE
                               ,GLCC.'||l_segment2_column||'          SEGMENT2_VALUE
                               ,GLCC.'||l_segment3_column||'          SEGMENT3_VALUE
                               ,GLCC.'||l_segment4_column||'          SEGMENT4_VALUE
                               ,AEL_V.AE_LINE_REFERENCE               AE_LINE_REF
                               ,AEL_V.AE_LINE_REFERENCE_INTERNAL      AE_LINE_REF_INT
                               ,AEL_V.CURRENCY_CODE                   CURRENCY_CODE
                               ,AEL_V.ENTERED_DR                      ENTERED_DR
                               ,AEL_V.ENTERED_CR                      ENTERED_CR
                               ,AEL_V.ACCOUNTED_DR                    ACCOUNTED_DR
                               ,AEL_V.ACCOUNTED_CR                    ACCOUNTED_CR
                               ,TO_NUMBER(NULL)                       REPORT_DR
                               ,TO_NUMBER(NULL)                       REPORT_CR
                               ,AEL_V.PERIOD_NAME                     PERIOD_NAME
                               ,AEL_V.STATUS                          STATUS
                               ,GLCC.ACCOUNT_TYPE                     ACCOUNT_TYPE ';
        END IF;

   END IF;              -- Organize By ACCOUNT?

  -- Build From clause
   IF (p_Application_Id <> 101 )
     THEN
      l_from_clause := 'FROM GL_CODE_COMBINATIONS GLCC,'||p_viewName||' AEL_V';
    ELSIF ( p_Application_Id = 101 ) THEN
      l_from_clause := 'FROM GL_CODE_COMBINATIONS GLCC, XLA_GL_JE_AEL_V AEL_V';
   END IF;

  -- Build Where clause

  IF ( p_OverRidingWhereClause IS NOT NULL ) THEN

  -- Bugfix 969109: The where clause should filter by SOB id.
     l_where_clause := p_OverRidingWhereClause
              ||' AND GLCC.CODE_COMBINATION_ID = AEL_V.CODE_COMBINATION_ID'
              ||' AND AEL_V.APPLICATION_ID = :appl_id '
              ||' AND AEL_V.SET_OF_BOOKS_ID = :set_of_books_id ';

  ELSE
  -- Build standard where clause
     l_where_clause := 'WHERE GLCC.CODE_COMBINATION_ID = '
                ||' AEL_V.CODE_COMBINATION_ID '
                ||' AND AEL_V.APPLICATION_ID = :appl_id '
                ||' AND AEL_V.SET_OF_BOOKS_ID = :set_of_books_id ';

     IF ( p_add_col_name_1 IS NOT NULL ) THEN
        l_where_clause := l_where_clause||' AND '
                          ||p_add_col_name_1||' = :add_col_value_1 ';
     END IF;

     IF ( p_add_col_name_2 IS NOT NULL ) THEN
       l_where_clause := l_where_clause||' AND '||p_add_col_name_2||
                     ' = :add_col_value_2 ';
     END IF;

     IF ( p_trx_header_table IS NOT NULL ) THEN
        l_where_clause := l_where_clause||
                   ' AND AEL_V.TRX_HDR_TABLE = :trx_header_table ';
     END IF;

     IF ( p_trx_header_id IS NOT NULL ) THEN
        l_where_clause := l_where_clause||
                   ' AND AEL_V.TRX_HDR_ID = :trx_header_id ';
     END IF;

         -- Mfg. PAC transactions support
     IF ( p_Cost_Type_ID IS NOT NULL ) THEN
       l_where_clause := l_where_clause||
                   ' AND AEL_V.COST_TYPE_ID = :cost_type_id';
     END IF;
  END IF;

  /*****
   * Build Order By clause:
   * a) If organized by ACCOUNT
   *          - Bal Segment, Nat Acct segment, Curr, Line Ref Internal
   * b) If organized by SEGMENT
   *          - Segment1, Segment2, Segment3, Segment4, Curr, Line Ref Int, CCID
   *****/

  IF ( p_organize_by = 'ACCOUNT' ) THEN
     l_ordered_account :=
          XLA_FLEX_UTIL.get_ordered_account(prv_ChartOfAccountsID, 'GLCC');
     l_order_by_clause := 'ORDER BY '||l_ordered_account||',8,7 ';
  ELSE
     l_order_by_clause := 'ORDER BY 2,3,4,5,8,7,1 ';
  END IF;

  l_statement := l_select_clause ||' '||l_from_clause||' '||
                 l_where_clause  ||' '||l_group_by_clause||' '||
                 l_order_by_clause;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of function getStatement'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value is:'|| l_statement
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

  RETURN l_statement;

END getStatement;


FUNCTION getReportingCurrency RETURN VARCHAR2 IS
BEGIN
 RETURN 'USD';
END;


FUNCTION getAccountingCurrency( pSetOfBooksID IN NUMBER)
 RETURN VARCHAR2
IS

 CURSOR c_currencyCode(pSetOfBooksID NUMBER)
 IS
 SELECT CURRENCY_CODE
 FROM   GL_LEDGERS
 WHERE  ledger_id= pSetOfBooksID;

 currencyCodeRecord       c_currencyCode%ROWTYPE;

 returnValue VARCHAR2(50);
l_log_module                VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.getAccountingCurrency';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
          (p_msg      => 'BEGIN of function getAccountingCurrency'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
     trace
          (p_msg      => 'p_ledger_id= '  ||TO_CHAR(pSetOfBooksID)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;

   OPEN c_currencyCode(pSetOfBooksID);
   FETCH c_currencyCode INTO currencyCodeRecord;
   returnValue := currencyCodeRecord.CURRENCY_CODE;
   CLOSE c_currencyCode;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'END of function getAccountingCurrency'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'return value is:'||to_char(returnValue)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   RETURN returnValue;

END;

FUNCTION getReportingCurrency( pSetOfBooksID IN NUMBER)
  RETURN VARCHAR2 IS
BEGIN
   RETURN getAccountingCurrency(pSetOfBooksID);
END;

FUNCTION getChartOfAccountsID( pSetOfBooksID IN NUMBER)
  RETURN NUMBER IS

     CURSOR c_chartOfAccountsID(pSetOfBooksID NUMBER) IS
          SELECT CHART_OF_ACCOUNTS_ID
          FROM   GL_LEDGERS
          WHERE  ledger_id= pSetOfBooksID;

 chartOfAccountsIDRecord       c_chartOfAccountsID%ROWTYPE;

 returnValue NUMBER;
l_log_module                VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.getChartOfAccountsID';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
          (p_msg      => 'BEGIN of function getChartOfAccountsID'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
     trace
          (p_msg      => 'p_ledger_id= '  ||TO_CHAR(pSetOfBooksID)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;

   OPEN  c_chartOfAccountsID(pSetOfBooksID);
   FETCH c_chartOfAccountsID INTO chartOfAccountsIDRecord;
         returnValue := chartOfAccountsIDRecord.CHART_OF_ACCOUNTS_ID;
   CLOSE c_chartOfAccountsID;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of function getChartOfAccountsID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
    trace
         (p_msg      => 'return value is:'||to_char(returnValue)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

 RETURN returnValue;

END;

FUNCTION secure(p_CCID  IN NUMBER
               ,p_TATB IN VARCHAR2 ) RETURN BOOLEAN IS
i                      BINARY_INTEGER := 1;
l_secure_flag          VARCHAR2(1);
returnValue            BOOLEAN := FALSE;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.secure';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
          (p_msg      => 'BEGIN of function secure'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
     trace
          (p_msg      => 'ccid= '  ||TO_CHAR(p_CCID)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
     trace
          (p_msg      => 'p_TATB= '  ||p_TATB
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;

   IF ( FND_FLEX_KEYVAL.VALIDATE_CCID(
                                      APPL_SHORT_NAME   => 'SQLGL'
                                      ,KEY_FLEX_CODE    => 'GL#'
                                      ,STRUCTURE_NUMBER => prv_ChartOfAccountsID
                                      ,COMBINATION_ID   => p_CCID
                                      ,DISPLAYABLE      => g_disp_segments
                                      ,SECURITY         =>'CHECK')) THEN

      IF FND_FLEX_KEYVAL.IS_SECURED THEN
         l_secure_flag := 'Y';
       ELSE
         l_secure_flag := 'N';
      END IF;

      IF p_TATB = 'TA' THEN
         g_current_segment_values := FND_FLEX_KEYVAL.CONCATENATED_VALUES;
         g_current_segments_desc  := FND_FLEX_KEYVAL.CONCATENATED_DESCRIPTIONS;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
              (p_msg      =>'g_ta_segment_values '|| p_ccid || ' ' || g_current_segment_values || l_secure_flag
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   =>l_log_module);
         END IF;
--         xla_util.debug('g_ta_segment_values '|| p_ccid || ' ' || g_current_segment_values || l_secure_flag);
      ELSE
         g_tb_current_segment_values := FND_FLEX_KEYVAL.CONCATENATED_VALUES;
         g_tb_current_segments_desc  := FND_FLEX_KEYVAL.CONCATENATED_DESCRIPTIONS;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
              (p_msg      =>'g_segment_values '|| p_ccid || ' ' || g_tb_current_segment_values || l_secure_flag
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   =>l_log_module);
         END IF;
--         xla_util.debug('g_segment_values '|| p_ccid || ' ' || g_tb_current_segment_values || l_secure_flag);
      END IF;
   END IF;       -- Flex valid?

   IF ( l_secure_flag = 'Y' ) THEN
      returnValue := TRUE;
    ELSE
      returnValue := FALSE;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'END of function secure'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
     trace
         (p_msg      => 'return value is:'||l_secure_flag
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   RETURN returnValue;

END secure;


PROCEDURE getBalances(balanceDr          OUT NOCOPY NUMBER
                     ,balanceCr          OUT NOCOPY NUMBER
                     ,codeCombinationsID IN NUMBER
                     ,periodName         IN VARCHAR2
                     ,accountType        IN VARCHAR2 )
IS

  -- Account Balance for accounting currency, period
  CURSOR BALANCES_C( p_CODE_COMBINATION_ID  NUMBER
                    ,p_PERIOD_NAME          VARCHAR2 )
  IS
  SELECT ( nvl(BA.begin_balance_dr,0) -
          nvl(BA.begin_balance_cr,0) ) +
         ( nvl(BA.period_net_dr,0) -
          nvl(BA.period_net_cr,0) ) FUNCTIONAL_YEAR_TO_DATE
    FROM GL_BALANCES                                    BA
   WHERE BA.CODE_COMBINATION_ID = p_CODE_COMBINATION_ID
     AND BA.ledger_id = prv_SetOfBooksID -- updated by weshen
     AND BA.PERIOD_NAME         = p_PERIOD_NAME
     AND BA.ACTUAL_FLAG         = 'A'
     AND BA.CURRENCY_CODE       = g_AccountingCurrency;

l_balances_c   BALANCES_C%ROWTYPE;
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.getBalances';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure getBalances'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'codeCombinationsId= '  ||TO_CHAR(codeCombinationsID)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'period name = '  || periodName
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'account type= '  ||accountType
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

  OPEN BALANCES_C( codeCombinationsID
                         ,periodName );
  FETCH BALANCES_C INTO l_balances_c;
  IF ( BALANCES_C%FOUND )
  THEN

     IF l_balances_c.functional_year_to_date > 0 THEN
       balanceDr := l_balances_c.functional_year_to_date;
     ELSIF l_balances_c.functional_year_to_date < 0 THEN
       balanceCr := -1*l_balances_c.functional_year_to_date;
     ELSE
       IF accountType IN ('A','E') THEN
          balanceDr := 0 ;
        ELSE
          balanceCr := 0 ;
       END IF;
     END IF;

/*
     balanceDr := l_balances_c.functional_year_to_date;
     balanceCr := 0;
  ELSE
     balanceDr := 0;
     balanceCr := 0;
*/

  END IF;

  CLOSE BALANCES_C;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of Procedure getBalances'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;

END getBalances;

PROCEDURE ta_fetch_rows ( p_rows             IN         NUMBER DEFAULT 50
                         ,p_TALineDataArray  OUT NOCOPY T_TALineDataArray
                         ,p_eof              OUT NOCOPY        BOOLEAN ) IS
  l_ccid                NUMBER;
  l_account             VARCHAR2(255);
  l_segment1_value      VARCHAR2(255);
  l_segment2_value      VARCHAR2(255);
  l_segment3_value      VARCHAR2(255);
  l_segment4_value      VARCHAR2(255);
  l_ae_line_ref         VARCHAR2(1000);
  l_ae_line_ref_int     VARCHAR2(1000);
  l_entered_currency    VARCHAR2(15);
  l_entered_dr          NUMBER;
  l_entered_cr          NUMBER;
  l_acctd_dr            NUMBER;
  l_acctd_cr            NUMBER;
  l_report_dr           NUMBER;
  l_report_cr           NUMBER;
  l_balance_dr          NUMBER;        -- Applicable only to GL
  l_balance_cr          NUMBER;        -- Applicable only to GL
  l_period_name         VARCHAR2(15);       -- Applicable only to GL
  l_status              VARCHAR2(1);       -- Applicable only to GL
  l_account_type        VARCHAR2(1);

  l_rowCnt              BINARY_INTEGER := 0;
  l_balance             NUMBER := 0;

  TA_ACCOUNT                    CONSTANT        BINARY_INTEGER := 0;
  TA_ACCOUNT_DESC               CONSTANT        BINARY_INTEGER := 1;
  TA_ALL_CURR                   CONSTANT        BINARY_INTEGER := 2;
  TA_BALANCE_BEFORE             CONSTANT        BINARY_INTEGER := 3;
  TA_CURRENCY_TOTAL_MC          CONSTANT        BINARY_INTEGER := 4;
  TA_ACCOUNT_TOTAL_SC           CONSTANT        BINARY_INTEGER := 5;
  TA_ACCOUNT_TOTAL_MC           CONSTANT        BINARY_INTEGER := 6;
  TA_ACTIVITY                   CONSTANT        BINARY_INTEGER := 7;
  TA_BALANCE_AFTER              CONSTANT        BINARY_INTEGER := 8;
  TA_TOT_ACT_FOR_ALL_ACCOUNTS   CONSTANT        BINARY_INTEGER := 9;
  TA_CURR_HEADER_MC             CONSTANT        BINARY_INTEGER := 10;
  TA_CURR_HEADER_BLANK_MC       CONSTANT        BINARY_INTEGER := 11;
  TA_DUMMY                      CONSTANT        BINARY_INTEGER := 100;
  TA_EOF                        CONSTANT        BINARY_INTEGER := -1;

  l_TALineDataArray    T_TALineDataArray;
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.ta_fetch_rows';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure ta_fetch_rows'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;


--xla_msg('inside ta_fetch');
  p_eof := FALSE;

  -- Fetch Data and populate tables
  -- Exit if rowCnt > rows_requested or End_of_fetch.
  LOOP
    EXIT WHEN l_rowCnt > p_rows;
     IF ( dbms_sql.fetch_rows(c_ta) > 0 )  THEN

       dbms_sql.column_value( c_ta, 1, l_ccid );
       dbms_sql.column_value( c_ta, 2, l_segment1_value );
       dbms_sql.column_value( c_ta, 3, l_segment2_value );
       dbms_sql.column_value( c_ta, 4, l_segment3_value );
       dbms_sql.column_value( c_ta, 5, l_segment4_value );
       dbms_sql.column_value( c_ta, 6, l_ae_line_ref );
       dbms_sql.column_value( c_ta, 7, l_ae_line_ref_int );
       dbms_sql.column_value( c_ta, 8, l_entered_currency );
       dbms_sql.column_value( c_ta, 9, l_entered_dr );
       dbms_sql.column_value( c_ta, 10, l_entered_cr );
       dbms_sql.column_value( c_ta, 11, l_acctd_dr );
       dbms_sql.column_value( c_ta, 12, l_acctd_cr );
       dbms_sql.column_value( c_ta, 13, l_report_dr );
       dbms_sql.column_value( c_ta, 14, l_report_cr );
       dbms_sql.column_value( c_ta, 15, l_period_name );
       dbms_sql.column_value( c_ta, 16, l_status );
       dbms_sql.column_value( c_ta, 17, l_account_type );

       l_account := l_segment1_value||l_segment2_value||l_segment3_value||l_segment4_value;

       IF g_firstRow is null  THEN
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace
              (p_msg      =>'first row'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   =>l_log_module);
          END IF;
          --g_validateflex := TRUE;
           g_secure := secure(l_ccid,'TA');

          -- Set firstRow to TRUE when hit the first valid account.
          IF (NOT g_secure) then
             g_current_account := l_account;
             g_currency_code   := l_entered_currency;
             g_current_Ccid    := l_Ccid;
             g_account_type    := l_account_type;
             g_period_name     := l_period_name;
             g_firstrow := TRUE;
          END IF;
          g_segment_values := g_current_segment_values;
          g_segments_desc  := g_current_segments_desc;
        ELSE
          g_firstRow := FALSE;
          IF l_ccid = g_current_ccid THEN
              g_validateflex := FALSE;
          ELSE
             g_validateflex := TRUE;
          END IF;
       END IF;

       IF (g_validateflex) and (NOT g_firstrow) THEN
           g_secure := secure(l_ccid,'TA');
          g_segment_values := g_current_segment_values;
          g_segments_desc  := g_current_segments_desc;
       END IF;

       IF (NOT g_secure ) THEN
          IF g_firstRow THEN
             -- Add a row for Account
             l_rowCnt := l_rowCnt +1;
             l_TALineDataArray(l_rowCnt).lineType := TA_ACCOUNT;
             l_TALineDataArray(l_rowCnt).Account  := g_segment_values;
             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                 (p_msg      =>g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).Account
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
             END IF;
--             xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
--                          l_TALineDataArray(l_rowCnt).Account );

              -- Add a row to populate Account Description
              l_rowCnt := l_rowCnt +1;
              l_TALineDataArray(l_rowCnt).lineType := TA_ACCOUNT_DESC;
              l_TALineDataArray(l_rowCnt).AccountDesc  := g_segments_desc;
              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                 (p_msg      =>g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||l_TALineDataArray(l_rowCnt).AccountDesc
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
              END IF;
--              xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
--                           l_TALineDataArray(l_rowCnt).AccountDesc );

              -- Add a row for currency header
              l_rowCnt := l_rowCnt +1;
              l_TALineDataArray(l_rowCnt).lineType          := TA_ALL_CURR;
              l_TALineDataArray(l_rowCnt).enteredCurrency   := l_entered_currency;
              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                 (p_msg      =>g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).enteredCurrency
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
              END IF;

              -- Get an opening balance.
              IF (prv_OrganizeBy = 'ACCOUNT') AND
               (prv_ApplicationId = 101)  THEN

                -- Calcualte opening balance
                getBalances( g_openingBalanceDr
                            ,g_openingBalanceCr
                            ,l_Ccid
                            ,l_period_name
                             ,l_account_type );

                -- If the entry is posted then calculate opening balance.
                IF l_status = 'P' THEN
                   l_balance := nvl(g_openingBalanceDr,0) - nvl(g_openingBalanceCr,0);
                   getAccountBalance(l_balance
                                   ,prv_Trx_Hdr_Id
                                   ,g_openingBalanceDr
                                   ,g_openingBalanceCr
                                   ,l_Ccid
                                   ,l_account_type);
                END IF;

                -- Insert a row for an opening balance. Balances are displayed
                -- for accounted amounts only.

                l_rowCnt := l_rowCnt +1;
                l_TALineDataArray(l_rowCnt).lineType          := TA_BALANCE_BEFORE;
                l_TALineDataArray(l_rowCnt).Ccid              := l_ccid;
                l_TALineDataArray(l_rowCnt).Account           := l_Account;
                l_TALineDataArray(l_rowCnt).enteredCurrency   := l_entered_currency;
                l_TALineDataArray(l_rowCnt).accountedAmountDr := g_openingBalanceDr;
                l_TALineDataArray(l_rowCnt).accountedAmountCr := g_openingBalanceCr;


                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                   (p_msg      =>g_current_account
                          || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                          || '       |'
                          || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountCr
                   ,p_level    => C_LEVEL_STATEMENT
                   ,p_module   =>l_log_module);
                END IF;
/*
                xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                             l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                             l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
              END IF;
          END IF;

          IF (g_currency_code = l_entered_currency) AND
             (g_current_account = l_Account) THEN
              -- Populate PLSQL table.
              l_rowCnt := l_rowCnt +1;
              l_TALineDataArray(l_rowCnt).lineType          := TA_ACTIVITY;
              l_TALineDataArray(l_rowCnt).Ccid              := l_ccid;
              l_TALineDataArray(l_rowCnt).enteredCurrency   := l_entered_currency;
              l_TALineDataArray(l_rowCnt).lineReference     := l_ae_line_ref;
              l_TALineDataArray(l_rowCnt).enteredAmountDr   := l_entered_dr;
              l_TALineDataArray(l_rowCnt).enteredAmountCr   := l_entered_cr;
              l_TALineDataArray(l_rowCnt).accountedAmountDr := l_acctd_dr;
              l_TALineDataArray(l_rowCnt).accountedAmountCr := l_acctd_cr;
              l_TALineDataArray(l_rowCnt).reportedAmountDr  := l_report_dr;
              l_TALineDataArray(l_rowCnt).reportedAmountCr  := l_report_cr;

              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                   (p_msg      =>g_current_account
                          || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                          || '       |'
                          || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountCr
                   ,p_level    => C_LEVEL_STATEMENT
                   ,p_module   =>l_log_module);
              END IF;
/*
              xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                           l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                           l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

              -- Currency Totals
              g_totalEnteredCurDr   := getTotal(g_totalEnteredCurDr,   l_entered_dr);
              g_totalEnteredCurCr   := getTotal(g_totalEnteredCurCr,   l_entered_cr);
              g_totalAccountedCurDr := getTotal(g_totalAccountedCurDr, l_acctd_dr);
              g_totalAccountedCurCr := getTotal(g_totalAccountedCurCr, l_acctd_cr);
              g_totalReportingCurDr := getTotal(g_totalReportingCurDr, l_report_dr);
              g_totalReportingCurCr := getTotal(g_totalReportingCurCr, l_report_cr);

              -- Account Totals
              g_totalEntCcidDr       :=  getTotal(g_totalEntCcidDr,       l_entered_dr);
              g_totalEntCcidCr       :=  getTotal(g_totalEntCcidCr,       l_entered_cr);
              g_totalAcctCcidDr      :=  getTotal(g_totalAcctCcidDr,      l_acctd_dr);
              g_totalAcctCcidCr      :=  getTotal(g_totalAcctCcidCr,      l_acctd_cr);
              g_totalReportingCcidDr :=  getTotal(g_totalReportingCcidDr, l_report_dr);
              g_totalReportingCcidCr :=  getTotal(g_totalReportingCcidCr, l_report_cr);
           ELSE

             -- If the currency is different
             IF g_currency_code <> l_entered_currency THEN
                IF g_current_account = l_Account THEN
                   g_currency_cnt := g_currency_cnt + 1;

                   -- Update totals for an account
                   g_totalAcctCcidDr      :=  getTotal(g_totalAcctCcidDr,      l_acctd_dr);
                   g_totalAcctCcidCr      :=  getTotal(g_totalAcctCcidCr,      l_acctd_cr);
                   g_totalReportingCcidDr :=  getTotal(g_totalReportingCcidDr, l_report_dr);
                   g_totalReportingCcidCr :=  getTotal(g_totalReportingCcidCr, l_report_cr);

                   l_rowCnt := l_rowCnt + 1;
                   l_TALineDataArray(l_rowCnt).lineType          :=  TA_CURRENCY_TOTAL_MC;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
                   l_TALineDataArray(l_rowCnt).enteredAmountDr   := g_totalEnteredCurDr;
                   l_TALineDataArray(l_rowCnt).enteredAmountCr   := g_totalEnteredCurCr;
                   l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalAccountedCurDr;
                   l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalAccountedCurCr;
                   l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalReportingCurDr;
                   l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalReportingCurCr;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                        (p_msg      =>g_current_account
                            || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                            || '       |'
                            || l_TALineDataArray(l_rowCnt).enteredCurrency
                            || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountCr
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                                l_TALineDataArray(l_rowCnt).enteredCurrency ||
                                l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                                l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

                   l_rowCnt := l_rowCnt + 1;
                   l_TALineDataArray(l_rowCnt).lineType          :=  TA_CURR_HEADER_BLANK_MC;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                        (p_msg      => g_current_account
                            || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                            || '       |'
                            || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountCr
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                                l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                                l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

                   l_rowCnt := l_rowCnt + 1;
                   l_TALineDataArray(l_rowCnt).lineType          :=  TA_CURR_HEADER_MC;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   :=  l_entered_currency;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                        (p_msg      => g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).enteredCurrency
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                   END IF;

/*
                   xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                                l_TALineDataArray(l_rowCnt).enteredCurrency );
*/

                END IF;
              END IF; -- g_currency_code <> l_entered_currency

              -- If the Account Changes
              IF g_current_account <> l_Account THEN
                 -- Net Activity Entered Currency
                 getNetBalance(g_totalEntCcidDr
                              ,g_totalEntCcidCr
                              ,g_account_type);

                -- Net Activity Accounting Currency
                getNetBalance(g_totalAcctCcidDr
                             ,g_totalAcctCcidCr
                             ,g_account_type);

                IF g_currency_cnt > 0 THEN  -- Multi Currency

                   -- Populate currency totals
                   l_rowCnt := l_rowCnt + 1;
                   l_TALineDataArray(l_rowCnt).lineType          :=  TA_CURRENCY_TOTAL_MC;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
                   l_TALineDataArray(l_rowCnt).enteredAmountDr   := g_totalEnteredCurDr;
                   l_TALineDataArray(l_rowCnt).enteredAmountCr   := g_totalEnteredCurCr;
                   l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalAccountedCurDr;
                   l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalAccountedCurCr;
                   l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalReportingCurDr;
                   l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalReportingCurCr;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                        (p_msg      => g_current_account
                             || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                             || '       |'
                             || l_TALineDataArray(l_rowCnt).enteredCurrency
                             || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                             || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                             || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                             || l_TALineDataArray(l_rowCnt).accountedAmountCr
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                                l_TALineDataArray(l_rowCnt).enteredCurrency ||
                                l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                                l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

                   -- Populate  Account Totals

                   l_rowCnt := l_rowCnt + 1;
                   l_TALineDataArray(l_rowCnt).lineType          := TA_ACCOUNT_TOTAL_MC;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
                   l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalAcctCcidDr;
                   l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalAcctCcidCr;
                   l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalReportingCcidDr;
                   l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalReportingCcidCr;


                ELSE
                   l_rowCnt := l_rowCnt + 1;
                   l_TALineDataArray(l_rowCnt).lineType          := TA_ACCOUNT_TOTAL_SC;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
                   l_TALineDataArray(l_rowCnt).enteredAmountDr   := g_totalEntCcidDr;
                   l_TALineDataArray(l_rowCnt).enteredAmountCr   := g_totalEntCcidCr;
                   l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalAcctCcidDr;
                   l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalAcctCcidCr;
                   l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalReportingCcidDr;
                   l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalReportingCcidCr;
                END IF; -- g_currency_cnt > 0

                -- Report Totals
                g_totalNetAccountedDr :=  g_totalNetAccountedDr + nvl(g_totalAcctCcidDr,0);
                g_totalNetAccountedCr :=  g_totalNetAccountedCr + nvl(g_totalAcctCcidCr,0);
                g_totalNetReportingDr :=  g_totalNetReportingDr + nvl(g_totalReportingCcidDr,0);
                g_totalNetReportingCr :=  g_totalNetReportingCr + nvl(g_totalReportingCcidCr,0);

                -- Reset currency counter
                g_currency_cnt := 0;

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                        (p_msg      => g_current_account
                             || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                             || '       |'
                             || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                             || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                             || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                             || l_TALineDataArray(l_rowCnt).accountedAmountCr
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                END IF;
/*
                xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                             l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                             l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);*/

                -- Add closing balance row for an Account
                IF (prv_OrganizeBy = 'ACCOUNT') AND
                   (prv_ApplicationID = 101)  THEN

                   g_closingBalanceDr :=  nvl(g_openingBalanceDr,0) + nvl(g_totalAcctCcidDr,0);
                   g_closingBalanceCr :=  nvl(g_openingBalanceCr,0) + nvl(g_totalAcctCcidCr,0);

                   getNetBalance(g_closingBalanceDr,
                                 g_closingBalanceCr,
                                 g_Account_Type);

                   l_rowCnt := l_rowCnt +1;
                   l_TALineDataArray(l_rowCnt).lineType          := TA_BALANCE_AFTER;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
                   l_TALineDataArray(l_rowCnt).accountedAmountDr := g_closingBalanceDr;
                   l_TALineDataArray(l_rowCnt).accountedAmountCr := g_closingBalanceCr;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                        (p_msg      => g_current_account
                            || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                            || '       |'
                            || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountCr
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                                l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                                l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
                END IF;

                -- Insert Dummy Line
                l_rowCnt := l_rowCnt +1;
                l_TALineDataArray(l_rowCnt).lineType          := TA_DUMMY;

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                        (p_msg      => g_current_account
                             || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                             || '       |'
                             || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                             || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                             || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                             || l_TALineDataArray(l_rowCnt).accountedAmountCr
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                END IF;
/*
                xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                             l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                             l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

                -- Reset Account totals
                g_totalEntCcidDr       :=  l_entered_dr;
                g_totalEntCcidCr       :=  l_entered_cr;
                g_totalAcctCcidDr      :=  l_acctd_dr;
                g_totalAcctCcidCr      :=  l_acctd_cr;
                g_totalReportingCcidDr :=  l_report_dr;
                g_totalReportingCcidCr :=  l_report_cr;

                -- Add a row for an Account
                l_rowCnt := l_rowCnt +1;
                l_TALineDataArray(l_rowCnt).lineType := TA_ACCOUNT;
                l_TALineDataArray(l_rowCnt).Account  := g_segment_values;

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                        (p_msg      => g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).Account
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                END IF;
/*
                xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                             l_TALineDataArray(l_rowCnt).Account );
*/

                -- Add a row to populate Account Description
                l_rowCnt := l_rowCnt +1;
                l_TALineDataArray(l_rowCnt).lineType    := TA_ACCOUNT_DESC;
                l_TALineDataArray(l_rowCnt).AccountDesc := g_segments_desc;

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                        (p_msg      => g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).AccountDesc
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                END IF;
/*
                xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                             l_TALineDataArray(l_rowCnt).AccountDesc );
*/
                -- Add a row for currency header
                l_rowCnt := l_rowCnt +1;
                l_TALineDataArray(l_rowCnt).lineType          := TA_ALL_CURR;
                l_TALineDataArray(l_rowCnt).enteredCurrency   := l_entered_currency;

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                        (p_msg      => g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).enteredCurrency
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                END IF;
/*
                xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                             l_TALineDataArray(l_rowCnt).enteredCurrency );
*/

                -- Add a row for opening balance.
                IF (prv_OrganizeBy = 'ACCOUNT') AND
                   (prv_ApplicationId = 101)  THEN
                   getBalances( g_openingBalanceDr
                              ,g_openingBalanceCr
                              ,l_Ccid
                              ,l_period_name
                              ,l_account_type);

                   -- If the entry is posted then adjust opening balance.
                   IF l_status = 'P' THEN
                      l_balance := nvl(g_openingBalanceDr,0) - nvl(g_openingBalanceCr,0);
                      getAccountBalance(l_balance
                                       ,prv_Trx_Hdr_Id
                                       ,g_openingBalanceDr
                                       ,g_openingBalanceCr
                                       ,l_Ccid
                                       ,l_account_type);
                   END IF;

                   -- Insert a row for an opening balance. Balances are displayed
                   -- for accounted amounts only.

                   l_rowCnt := l_rowCnt +1;
                   l_TALineDataArray(l_rowCnt).lineType          := TA_BALANCE_BEFORE;
                   l_TALineDataArray(l_rowCnt).enteredCurrency   := l_entered_currency;
                   l_TALineDataArray(l_rowCnt).accountedAmountDr := g_openingBalanceDr;
                   l_TALineDataArray(l_rowCnt).accountedAmountCr := g_openingBalanceCr;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                        (p_msg      => g_current_account
                            || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                            || '       |'
                            || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountCr
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                                l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                                l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
                END IF;
              END IF;    --  g_current_account <> l_Account
              l_rowCnt := l_rowCnt + 1;
              l_TALineDataArray(l_rowCnt).lineType          := TA_ACTIVITY;
              l_TALineDataArray(l_rowCnt).enteredCurrency   := l_entered_currency;
              l_TALineDataArray(l_rowCnt).lineReference     := l_ae_line_ref;
              l_TALineDataArray(l_rowCnt).enteredAmountDr   := l_entered_dr;
              l_TALineDataArray(l_rowCnt).enteredAmountCr   := l_entered_cr;
              l_TALineDataArray(l_rowCnt).accountedAmountDr := l_acctd_dr;
              l_TALineDataArray(l_rowCnt).accountedAmountCr := l_acctd_cr;
              l_TALineDataArray(l_rowCnt).reportedAmountDr  := l_report_dr;
              l_TALineDataArray(l_rowCnt).reportedAmountCr  := l_report_cr;

              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                      (p_msg      => g_current_account
                            || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                            || '       |'
                            || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                            || l_TALineDataArray(l_rowCnt).accountedAmountCr
                      ,p_level    => C_LEVEL_STATEMENT
                      ,p_module   =>l_log_module);
              END IF;
/*
              xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                           l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                           l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
           END IF;

           g_current_account := l_Account;
           g_current_Ccid    := l_Ccid;
           g_currency_code   := l_entered_currency;

           -- Reset Currency totals
           g_totalEnteredCurDr   := l_entered_dr;
           g_totalEnteredCurCr   := l_entered_cr;
           g_totalAccountedCurDr := l_acctd_dr;
           g_totalAccountedCurCr := l_acctd_cr;
           g_totalReportingCurDr := l_report_dr;
           g_totalReportingCurCr := l_report_cr;
/*
           -- Report Totals
           g_totalNetAccountedDr :=  g_totalNetAccountedDr + nvl(l_acctd_dr,0);
           g_totalNetAccountedCr :=  g_totalNetAccountedCr + nvl(l_acctd_cr,0);
           g_totalNetReportingDr :=  g_totalNetReportingDr + nvl(l_report_dr,0);
           g_totalNetReportingCr :=  g_totalNetReportingCr + nvl(l_report_cr,0);
*/
       END IF; -- Not secured

      ELSE -- No more rows
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_msg      => 'no more rows'
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
       END IF;
       IF (dbms_sql.IS_OPEN(c_ta)) THEN
          dbms_sql.close_cursor(c_ta);
       END IF;
       p_eof := TRUE;

       getNetBalance(g_totalEntCcidDr
                    ,g_totalEntCcidCr
                    ,g_account_type);

       getNetBalance(g_totalAcctCcidDr
                    ,g_totalAcctCcidCr
                    ,g_account_type);

        --IF (l_RowCnt > 0 )  THEN

          -- Multi Currency
          IF g_currency_cnt > 0 THEN

             -- Populate  Account Totals
             l_rowCnt := l_rowCnt + 1;
             l_TALineDataArray(l_rowCnt).lineType          := TA_ACCOUNT_TOTAL_MC;
             l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
             l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalAcctCcidDr;
             l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalAcctCcidCr;
             l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalReportingCcidDr;
             l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalReportingCcidCr;

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                     (p_msg      => g_current_account
                         || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                         || '       |'
                         || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                         || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                         || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                         || l_TALineDataArray(l_rowCnt).accountedAmountCr
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   =>l_log_module);
             END IF;
/*
             xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                          l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                          l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
           ELSE
             l_rowCnt := l_rowCnt + 1;
             l_TALineDataArray(l_rowCnt).lineType          := TA_ACCOUNT_TOTAL_SC;
             l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
             l_TALineDataArray(l_rowCnt).enteredAmountDr   := g_totalEntCcidDr;
             l_TALineDataArray(l_rowCnt).enteredAmountCr   := g_totalEntCcidCr;
             l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalAcctCcidDr;
             l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalAcctCcidCr;
             l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalReportingCcidDr;
             l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalReportingCcidCr;

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                     (p_msg      => g_current_account
                          || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                          || '       |'
                          || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountCr
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   =>l_log_module);
             END IF;
/*
             xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                          l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                          l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
          END IF;

          -- Report Totals
          g_totalNetAccountedDr :=  g_totalNetAccountedDr + nvl(g_totalAcctCcidDr,0);
          g_totalNetAccountedCr :=  g_totalNetAccountedCr + nvl(g_totalAcctCcidCr,0);
          g_totalNetReportingDr :=  g_totalNetReportingDr + nvl(g_totalReportingCcidDr,0);
          g_totalNetReportingCr :=  g_totalNetReportingCr + nvl(g_totalReportingCcidCr,0);

          -- Add closing balance row for an account.
          IF (prv_OrganizeBy = 'ACCOUNT') AND
             (prv_ApplicationID = 101)  THEN

             g_closingBalanceDr :=  Nvl(g_openingbalancedr,0) + Nvl(g_totalAcctCcidDr,0);
             g_closingBalanceCr :=  Nvl(g_openingBalanceCr,0) + Nvl(g_totalAcctCcidCr,0);

             getNetBalance(g_closingBalanceDr,
                           g_closingBalanceCr,
                           g_Account_Type);

             l_rowCnt := l_rowCnt +1;
             l_TALineDataArray(l_rowCnt).lineType          := TA_BALANCE_AFTER;
             l_TALineDataArray(l_rowCnt).enteredCurrency   := g_currency_code;
             l_TALineDataArray(l_rowCnt).accountedAmountDr := g_closingBalanceDr;
             l_TALineDataArray(l_rowCnt).accountedAmountCr := g_closingBalanceCr;
             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                     (p_msg      => g_current_account
                          || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                          || '       |'
                          || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                          || l_TALineDataArray(l_rowCnt).accountedAmountCr
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   =>l_log_module);
             END IF;
/*
             xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                          l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                          l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
          END IF;

          -- Populate Report Totals
          l_rowCnt := l_rowCnt + 1;
          l_TALineDataArray(l_rowCnt).lineType          := TA_DUMMY;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                  (p_msg      => g_current_account
                         || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                         || '       |'
                         || l_TALineDataArray(l_rowCnt).enteredAmountDr || '|'
                         || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                         || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                         || l_TALineDataArray(l_rowCnt).accountedAmountCr
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
          END IF;
/*
          xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                       l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

          getNetBalance(g_closingBalanceDr,
                      g_closingBalanceCr,
                      g_Account_Type);

          l_rowCnt := l_rowCnt + 1;
          l_TALineDataArray(l_rowCnt).lineType          := TA_TOT_ACT_FOR_ALL_ACCOUNTS;
          l_TALineDataArray(l_rowCnt).accountedAmountDr := g_totalNetAccountedDr;
          l_TALineDataArray(l_rowCnt).accountedAmountCr := g_totalNetAccountedCr;
          l_TALineDataArray(l_rowCnt).reportedAmountDr  := g_totalNetReportingDr;
          l_TALineDataArray(l_rowCnt).reportedAmountCr  := g_totalNetReportingCr;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                  (p_msg      => g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
          END IF;
/*
          xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                       l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/

        -- Populate End Of File row.
       l_rowCnt := l_rowCnt +1;
       l_TALineDataArray(l_rowCnt).lineType  := TA_EOF;

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_msg      => g_current_account
                     || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta')
                     || '       |' || l_TALineDataArray(l_rowCnt).enteredAmountDr
                     || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|'
                     || l_TALineDataArray(l_rowCnt).accountedAmountDr || '|'
                     || l_TALineDataArray(l_rowCnt).accountedAmountCr
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
       END IF;
/*
       xla_util.debug(g_current_account || getlinetype(l_TALineDataArray(l_rowCnt).LineType,'ta') || '       |' ||
                     l_TALineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TALineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                     l_TALineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TALineDataArray(l_rowCnt).accountedAmountCr);
*/
       --END IF; -- Rowcnt > 0
       EXIT;
     END IF;
  END LOOP;              -- fetch_rows

  p_TALinedataarray := l_talinedataarray;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of Procedure ta_fetch_rows'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
  END IF;


END ta_fetch_rows;

PROCEDURE tb_fetch_rows ( p_rows             IN  NUMBER DEFAULT 50
                       ,p_TbLineDataArray OUT NOCOPY t_TBLineDataArray
                       ,p_eof             OUT NOCOPY BOOLEAN
                       ) IS
  l_ccid              NUMBER;
  l_account           VARCHAR2(255);
  l_segment1_value    VARCHAR2(255);
  l_segment2_value    VARCHAR2(255);
  l_segment3_value    VARCHAR2(255);
  l_segment4_value    VARCHAR2(255);
  l_ae_line_ref       VARCHAR2(1000);
  l_ae_line_ref_int   VARCHAR2(1000);
  l_entered_currency  VARCHAR2(15);
  l_entered_dr        NUMBER;
  l_entered_cr        NUMBER;
  l_acctd_dr          NUMBER;
  l_acctd_cr          NUMBER;
  l_report_dr         NUMBER;
  l_report_cr         NUMBER;
  l_period_name       VARCHAR2(15);       -- Applicable only to GL
  l_status            VARCHAR2(1);       -- Applicable only to GL
  l_account_type      VARCHAR2(1);


  l_rowCnt              NUMBER := 0;
  l_balance             NUMBER := 0;

  TB_LINE                CONSTANT        BINARY_INTEGER := 0;
  TB_LINE_MC             CONSTANT        BINARY_INTEGER := 1;
  TB_TOTAL_ACTIVITY_DRCR CONSTANT        BINARY_INTEGER := 2;
  TB_TOTAL_ACT_DR        CONSTANT        BINARY_INTEGER := 3;
  TB_TOTAL_ACT_CR        CONSTANT        BINARY_INTEGER := 4;
  TB_LINE_TOTAL_MC       CONSTANT        BINARY_INTEGER := 5;
  TB_DUMMY               CONSTANT        BINARY_INTEGER := 100;
  TB_EOF                 CONSTANT        BINARY_INTEGER := -1;

  l_TBLineDataArray     T_TBLineDataArray;
  l_temp NUMBER;
l_log_module                VARCHAR2(240);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.tb_fetch_rows';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure tb_fetch_rows'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

  p_eof := FALSE;

  -- Fetch Data and populate tables.
  -- Exit if rowCnt > rows_requested or End_of_fetch.
  LOOP
    EXIT WHEN l_rowCnt > p_rows;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
             (p_msg      => 'aaaa: one run of LOOP'
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   =>l_log_module);
       trace
             (p_msg      => 'l_rowCnt is:'||to_char(l_rowCnt)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   =>l_log_module);
       l_temp:=1;
       LOOP
         EXIT WHEN l_temp>l_rowCnt;
           trace
               (p_msg      => 'row No is:'||to_char(l_temp)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'lineType:'||getlinetype(l_TBLineDataArray(l_temp).LineType, 'tb')
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'enteredCurrency:'||l_TBLineDataArray(l_temp).enteredCurrency
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'account:'||l_TBLineDataArray(l_temp).account||l_TBLineDataArray(l_temp).accountdesc
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'accountedamountDr:'||l_TBLineDataArray(l_temp).accountedAmountDr
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'accountedamountCr:'||l_TBLineDataArray(l_temp).accountedAmountCr
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'accountedamountNet:'||l_TBLineDataArray(l_temp).accountedAmountNet
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           l_temp:=l_temp+1;
       end loop;
     END IF;
     IF ( dbms_sql.fetch_rows(c_tb) > 0 )  THEN
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
             (p_msg      => 'dbms_sql.fetch_rows(c_tb) > 0'
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   =>l_log_module);
       END IF;

       dbms_sql.column_value( c_tb, 1, l_ccid );
       dbms_sql.column_value( c_tb, 2, l_segment1_value );
       dbms_sql.column_value( c_tb, 3, l_segment2_value );
       dbms_sql.column_value( c_tb, 4, l_segment3_value );
       dbms_sql.column_value( c_tb, 5, l_segment4_value );
       dbms_sql.column_value( c_tb, 6, l_ae_line_ref );
       dbms_sql.column_value( c_tb, 7, l_ae_line_ref_int );
       dbms_sql.column_value( c_tb, 8, l_entered_currency );
       dbms_sql.column_value( c_tb, 9, l_entered_dr );
       dbms_sql.column_value( c_tb, 10, l_entered_cr );
       dbms_sql.column_value( c_tb, 11, l_acctd_dr );
       dbms_sql.column_value( c_tb, 12, l_acctd_cr );
       dbms_sql.column_value( c_tb, 13, l_report_dr );
       dbms_sql.column_value( c_tb, 14, l_report_cr );
       dbms_sql.column_value( c_tb, 15, l_period_name );
       dbms_sql.column_value( c_tb, 16, l_status );
       dbms_sql.column_value( c_tb, 17, l_account_type );

       l_account := l_segment1_value||l_segment2_value||l_segment3_value||l_segment4_value;

        IF g_tb_firstRow is null  THEN
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                  (p_msg      => 'first row'
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
          END IF;
          --g_tb_firstrow := TRUE;
          g_tb_validateflex := TRUE;
           g_tb_secure := secure(l_ccid,'TB');

          IF (NOT g_tb_secure) THEN
             g_tb_current_account := l_account;
             g_tb_currency_code   := l_entered_currency;
             g_tb_current_Ccid    := l_Ccid;
             g_tb_account_type    := l_account_type;
             g_tb_period_name     := l_period_name;
             g_tb_firstRow := TRUE;
             g_tb_segment_values := g_tb_current_segment_values;
             g_tb_segments_desc  := g_tb_current_segments_desc;
          END IF;
        ELSE
          g_tb_firstRow := FALSE;
          IF l_ccid = g_tb_current_ccid THEN
             g_tb_validateflex := FALSE;
          ELSE
             g_tb_validateflex := TRUE;
          END IF;
       END IF;

       IF (g_tb_validateflex) and (NOT g_tb_firstrow) THEN
          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                  (p_msg      =>'calling secure ' || l_ccid
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
          END IF;

           g_tb_secure := secure(l_ccid,'TB');
       END IF;

       IF (NOT g_tb_secure ) THEN

           IF (g_tb_currency_code = l_entered_currency) AND
              (g_tb_current_account = l_Account) THEN

              IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                    (p_msg      => ' (g_tb_currency_code = l_entered_currency) AND (g_tb_current_account = l_Account) THEN'
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   =>l_log_module);
              END IF;
              -- Update Totals
              g_tb_totalEnteredCurDr   := getTotal(g_tb_totalEnteredCurDr   ,l_entered_dr);
              g_tb_totalEnteredCurCr   := getTotal(g_tb_totalEnteredCurCr   ,l_entered_cr);
              g_tb_totalAccountedCurDr := getTotal(g_tb_totalAccountedCurDr ,l_acctd_dr);
              g_tb_totalAccountedCurCr := getTotal(g_tb_totalAccountedCurCr ,l_acctd_cr);
              g_tb_totalReportingCurDr := getTotal(g_tb_totalReportingCurDr ,l_report_dr);
              g_tb_totalReportingCurCr := getTotal(g_tb_totalReportingCurCr ,l_report_cr);

              g_tb_totalEntCcidDr       :=  getTotal(g_tb_totalEntCcidDr       ,l_entered_dr);
              g_tb_totalEntCcidCr       :=  getTotal(g_tb_totalEntCcidCr       ,l_entered_cr);
              g_tb_totalAcctCcidDr      :=  getTotal(g_tb_totalAcctCcidDr      ,l_acctd_dr);
              g_tb_totalAcctCcidCr      :=  getTotal(g_tb_totalAcctCcidCr      ,l_acctd_cr);
              g_tb_totalReportingCcidDr :=  getTotal(g_tb_totalReportingCcidDr ,l_report_dr);
              g_tb_totalReportingCcidCr :=  getTotal(g_tb_totalReportingCcidCr ,l_report_cr);

           ELSE
               IF g_tb_currency_code <> l_entered_currency THEN
                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                    trace
                        (p_msg      => 'g_tb_currency_code <> l_entered_currency'
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                  END IF;
                  IF g_tb_current_account = l_Account THEN
                    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                      trace
                        (p_msg      => ' g_tb_current_account = l_Account'
                        ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                    END IF;

                   -- Update account totals
                   g_tb_totalAcctCcidDr      :=  getTotal(g_tb_totalAcctCcidDr      ,l_acctd_dr);
                   g_tb_totalAcctCcidCr      :=  getTotal(g_tb_totalAcctCcidCr      ,l_acctd_cr);
                   g_tb_totalReportingCcidDr :=  getTotal(g_tb_totalReportingCcidDr ,l_report_dr);
                   g_tb_totalReportingCcidCr :=  getTotal(g_tb_totalReportingCcidCr ,l_report_cr);

                     g_tb_currency_cnt := g_tb_currency_cnt + 1;

                   IF g_tb_currency_cnt  = 1 THEN
                     -- print multi currency totals
                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                       trace
                         (p_msg      => ' g_tb_currency_cnt  = 1'
                         ,p_level    => C_LEVEL_STATEMENT
                        ,p_module   =>l_log_module);
                     END IF;

                     l_rowCnt := l_rowCnt + 1;
                     l_TBLineDataArray(l_rowCnt).lineType          :=  TB_LINE_MC;
                     l_TBLineDataArray(l_rowCnt).Ccid              := g_tb_current_ccid;
                     l_TBLineDataArray(l_rowCnt).Account           := g_tb_segment_values;
                     l_TBLineDataArray(l_rowCnt).AccountDesc       := g_tb_segments_desc;
                     l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
                     l_TBLineDataArray(l_rowCnt).enteredAmountDr   := g_tb_totalEnteredCurDr;
                     l_TBLineDataArray(l_rowCnt).enteredAmountCr   := g_tb_totalEnteredCurCr;
                     l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAccountedCurDr;
                     l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAccountedCurCr;
                     l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCurDr;
                     l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCurCr;
                     l_TBLineDataArray(l_rowCnt).enteredAmountNet  := nvl(g_tb_totalEnteredCurDr,0) - nvl(g_tb_totalEnteredCurCr,0);
                     l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAccountedCurDr,0) - nvl(g_tb_totalAccountedCurCr,0);
                     l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCurDr,0) - nvl(g_tb_totalReportingCurCr,0);
                    ELSE
                    --ELSIF g_tb_currency_cnt > 1 THEN
                     -- Do not send account info if it's the second currency total line
                     -- for same account

                     l_rowCnt := l_rowCnt + 1;
                     l_TBLineDataArray(l_rowCnt).lineType          :=  TB_LINE_MC;
                     l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
                     l_TBLineDataArray(l_rowCnt).enteredAmountDr   := g_tb_totalEnteredCurDr;
                     l_TBLineDataArray(l_rowCnt).enteredAmountCr   := g_tb_totalEnteredCurCr;
                     l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAccountedCurDr;
                     l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAccountedCurCr;
                     l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCurDr;
                     l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCurCr;
                     l_TBLineDataArray(l_rowCnt).enteredAmountNet  := nvl(g_tb_totalEnteredCurDr,0) - nvl(g_tb_totalEnteredCurCr,0);
                     l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAccountedCurDr,0) - nvl(g_tb_totalAccountedCurCr,0);
                     l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCurDr,0) - nvl(g_tb_totalReportingCurCr,0);
                   END IF;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                  (p_msg      =>'aa:'||g_tb_current_account
                          || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb')
                          || '       |'
                          || l_TBLineDataArray(l_rowCnt).enteredCurrency
                          || l_TBLineDataArray(l_rowcnt).account
                          || l_TBLineDataArray(l_rowcnt).accountdesc
                          || l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|'
                          || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|'
                          || l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|'
                          || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|'
                          || l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'
                          || l_TBLineDataArray(l_rowCnt).accountedAmountNet
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
          END IF;
/*
                  xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                               l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                               l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                               l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                               l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                               l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'|| l_TBLineDataArray(l_rowCnt).accountedAmountNet);
*/
                END IF;
              END IF;

              IF g_tb_current_account <> l_Account THEN
                -- Get an opening balance.
                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                         (p_msg      => 'ee:g_tb_current_account <> l_Account'
                         ,p_level    => C_LEVEL_STATEMENT
                         ,p_module   =>l_log_module);
                END IF;
                IF (prv_OrganizeBy = 'ACCOUNT') AND
                  (prv_ApplicationId = 101)  THEN
                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                            (p_msg      => 'ef:prv_OrganizeBy =ACCOUNT and prv_ApplicationId = 101'
                            ,p_level    => C_LEVEL_STATEMENT
                            ,p_module   =>l_log_module);
                   END IF;
                   getBalances( g_tb_openingBalanceDr
                              ,g_tb_openingBalanceCr
                              ,g_tb_current_ccid
                              ,g_tb_period_name
                              ,g_tb_account_type );

                   -- If the entry is posted then calculate opening balance.
                   IF l_status = 'P' THEN
                     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                       trace
                            (p_msg      => 'eg:l_status is P'
                            ,p_level    => C_LEVEL_STATEMENT
                            ,p_module   =>l_log_module);
                     END IF;
                     l_balance := nvl(g_tb_openingBalanceDr,0) - nvl(g_tb_openingBalanceCr,0);
                     getAccountBalance( l_balance
                                      ,prv_Trx_Hdr_Id
                                      ,g_tb_openingBalanceDr
                                      ,g_tb_openingBalanceCr
                                      ,g_tb_current_Ccid
                                      ,g_tb_account_type);
                   END IF;

                   -- Calculate closing Balance
                   g_tb_closingBalanceDr := nvl(g_tb_openingBalanceDr,0) + nvl(g_tb_totalAcctCcidDr,0);
                   g_tb_closingBalanceCr := nvl(g_tb_openingBalanceCr,0) + nvl(g_tb_totalAcctCcidCr,0);

                   getNetBalance(g_tb_closingBalanceDr,
                                 g_tb_closingBalanceCr,
                                 g_tb_account_type );
                END IF;

                  IF g_tb_currency_cnt > 0 THEN

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                            (p_msg      => 'eh:g_tb_currency_cnt > 0'
                            ,p_level    => C_LEVEL_STATEMENT
                            ,p_module   =>l_log_module);
                   END IF;
                   l_rowCnt := l_rowCnt + 1;
                   l_TBLineDataArray(l_rowCnt).lineType          :=  TB_LINE_MC;
                   l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
                   l_TBLineDataArray(l_rowCnt).enteredAmountDr   := g_tb_totalEnteredCurDr;
                   l_TBLineDataArray(l_rowCnt).enteredAmountCr   := g_tb_totalEnteredCurCr;
                   l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAccountedCurDr;
                   l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAccountedCurCr;
                   l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCurDr;
                   l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCurCr;
                   l_TBLineDataArray(l_rowCnt).enteredAmountNet  := nvl(g_tb_totalEnteredCurDr,0) - nvl(g_tb_totalEnteredCurCr,0);
                   l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAccountedCurDr,0) - nvl(g_tb_totalAccountedCurCr,0);
                   l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCurDr,0) - nvl(g_tb_totalReportingCurCr,0);

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      =>'ab:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                               l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                               l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                               l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                               l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                               l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'|| l_TBLineDataArray(l_rowCnt).accountedAmountNet
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                               l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                               l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                               l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                               l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                               l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'|| l_TBLineDataArray(l_rowCnt).accountedAmountNet);
*/
                   l_rowCnt := l_rowCnt + 1;
                   l_TBLineDataArray(l_rowCnt).lineType          := TB_LINE_TOTAL_MC;
                   l_TBLineDataArray(l_rowCnt).Ccid              := g_tb_current_ccid;
                   l_TBLineDataArray(l_rowCnt).Account           := g_tb_segment_values;
                   l_TBLineDataArray(l_rowCnt).AccountDesc       := g_tb_segments_desc;
                   l_TBLineDataArray(l_rowCnt).balancebeforeDr   := g_tb_openingBalanceDr;
                   l_TBLineDataArray(l_rowCnt).balancebeforeCr   := g_tb_openingBalanceCr;
                   l_TBLineDataArray(l_rowCnt).balancebeforeNet  := nvl(g_tb_openingBalanceDr,0) - nvl(g_tb_openingBalanceCr,0) ;
                   l_TBLineDataArray(l_rowCnt).balanceAfterDr    := g_tb_closingBalanceDr;
                   l_TBLineDataArray(l_rowCnt).balanceAfterCr    := g_tb_closingBalanceCr;
                   l_TBLineDataArray(l_rowCnt).balanceAfterNet   := nvl(g_tb_closingBalanceDr,0) - nvl(g_tb_closingBalanceCr,0);
                   l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
                   l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAcctCcidDr;
                   l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAcctCcidCr;
                   l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCcidDr;
                   l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCcidCr;
                   l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAcctCcidDr,0) - nvl(g_tb_totalAcctCcidCr,0);
                   l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCcidDr,0) - nvl(g_tb_totalReportingCcidCr,0);

                   getNetBalance(g_tb_totalAcctCcidDr,
                                 g_tb_totalAcctCcidCr,
                                 g_tb_account_type);

                   getNetBalance(g_tb_totalReportingCcidDr,
                                 g_tb_totalReportingCcidCr,
                                 g_tb_account_type);

                   -- Report Totals
                   g_tb_totalNetAccountedDr :=  g_tb_totalNetAccountedDr + nvl(g_tb_totalAcctCcidDr,0);
                   g_tb_totalNetAccountedCr :=  g_tb_totalNetAccountedCr + nvl(g_tb_totalAcctCcidCr,0);
                   g_tb_totalNetReportingDr :=  g_tb_totalNetReportingDr + nvl(g_tb_totalReportingCcidDr,0);
                   g_tb_totalNetReportingCr :=  g_tb_totalNetReportingCr + nvl(g_tb_totalReportingCcidCr,0);
                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      => 'dd:totalnetaccounteddr'||g_tb_totalNetAccountedDr|| '*g_tb_totalNetAccountedCr:'||g_tb_totalNetAccountedCr
                           ,p_level    => C_LEVEL_STATEMENT
                            ,p_module   =>l_log_module);
                   END IF;

                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      => 'ac:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                             l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                             l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc || '|' ||
                             l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' ||
                             l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountNet
                           ,p_level    => C_LEVEL_STATEMENT);
                   END IF;
/*
                   xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                             l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                             l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc || '|' ||
                             l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' ||
                             l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountNet);
*/
                ELSE
                   l_rowCnt := l_rowCnt + 1;
                   l_TBLineDataArray(l_rowCnt).lineType          := TB_LINE;
                   l_TBLineDataArray(l_rowCnt).Ccid              := g_tb_current_ccid;
                   l_TBLineDataArray(l_rowCnt).Account           := g_tb_segment_values;
                   l_TBLineDataArray(l_rowCnt).AccountDesc       := g_tb_segments_desc;
                   l_TBLineDataArray(l_rowCnt).balancebeforeDr   := g_tb_openingBalanceDr;
                   l_TBLineDataArray(l_rowCnt).balancebeforeCr   := g_tb_openingBalanceCr;
                   l_TBLineDataArray(l_rowCnt).balancebeforeNet  := nvl(g_tb_openingBalanceDr,0) - nvl(g_tb_openingBalanceCr,0) ;
                   l_TBLineDataArray(l_rowCnt).balanceAfterDr    := g_tb_closingBalanceDr;
                   l_TBLineDataArray(l_rowCnt).balanceAfterCr    := g_tb_closingBalanceCr;
                   l_TBLineDataArray(l_rowCnt).balanceAfterNet   := nvl(g_tb_closingBalanceDr,0) - nvl(g_tb_closingBalanceCr,0);
                   l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
                   l_TBLineDataArray(l_rowCnt).enteredAmountDr   := g_tb_totalEntCcidDr;
                   l_TBLineDataArray(l_rowCnt).enteredAmountCr   := g_tb_totalEntCcidCr;
                   l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAcctCcidDr;
                   l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAcctCcidCr;
                   l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCcidDr;
                   l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCcidCr;
                   l_TBLineDataArray(l_rowCnt).enteredAmountNet  := nvl(g_tb_totalEntCcidDr,0) - nvl(g_tb_totalEntCcidCr,0);
                   l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAcctCcidDr,0) - nvl(g_tb_totalAcctCcidCr,0);
                   l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCcidDr,0) - nvl(g_tb_totalReportingCcidCr,0);
                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      => 'ad:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                             l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                             l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                             l_TBLineDataArray(l_rowCnt).balancebeforeDr|| l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' ||
                             l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' ||
                             l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'||
                             l_TBLineDataArray(l_rowCnt).accountedAmountNet
                           ,p_level    => C_LEVEL_STATEMENT
                            ,p_module   =>l_log_module);
                   END IF;
/*
                   xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                             l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                             l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                             l_TBLineDataArray(l_rowCnt).balancebeforeDr|| l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' ||
                             l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' ||
                             l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'||
                             l_TBLineDataArray(l_rowCnt).accountedAmountNet);
*/

                   getNetBalance(g_tb_totalAcctCcidDr,
                                 g_tb_totalAcctCcidCr,
                                 g_tb_account_type);

                   getNetBalance(g_tb_totalReportingCcidDr,
                                 g_tb_totalReportingCcidCr,
                                 g_tb_account_type);

                   -- Report Totals
                   g_tb_totalNetAccountedDr :=  g_tb_totalNetAccountedDr + nvl(g_tb_totalAcctCcidDr,0);
                   g_tb_totalNetAccountedCr :=  g_tb_totalNetAccountedCr + nvl(g_tb_totalAcctCcidCr,0);
                   g_tb_totalNetReportingDr :=  g_tb_totalNetReportingDr + nvl(g_tb_totalReportingCcidDr,0);
                   g_tb_totalNetReportingCr :=  g_tb_totalNetReportingCr + nvl(g_tb_totalReportingCcidCr,0);
                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      => 'dd:totalnetaccounteddr'||g_tb_totalNetAccountedDr|| '*g_tb_totalNetAccountedCr:'||g_tb_totalNetAccountedCr
                           ,p_level    => C_LEVEL_STATEMENT
                            ,p_module   =>l_log_module);
                   END IF;

                END IF;

                g_tb_segment_values := g_tb_current_segment_values;
                g_tb_segments_desc  := g_tb_current_segments_desc;


                g_tb_totalEntCcidDr       :=  l_entered_dr;
                g_tb_totalEntCcidCr       :=  l_entered_cr;
                g_tb_totalAcctCcidDr      :=  l_acctd_dr;
                g_tb_totalAcctCcidCr      :=  l_acctd_cr;
                g_tb_totalReportingCcidDr :=  l_report_dr;
                g_tb_totalReportingCcidCr :=  l_report_cr;

                g_tb_currency_code := l_entered_currency;
                g_tb_currency_cnt  := 0;

              END IF;
           END IF;

           g_tb_current_ccid    := l_ccid;
            g_tb_current_account := l_account;
           g_tb_currency_code   := l_entered_currency;
           g_tb_period_name     := l_period_name;
           g_tb_account_type    := l_account_type;

           -- Currency totals
           g_tb_totalEnteredCurDr   := l_entered_dr;
           g_tb_totalEnteredCurCr   := l_entered_cr;
           g_tb_totalAccountedCurDr := l_acctd_dr;
           g_tb_totalAccountedCurCr := l_acctd_cr;
           g_tb_totalReportingCurDr := l_report_dr;
           g_tb_totalReportingCurCr := l_report_cr;
/*
           -- Report Totals
           g_tb_totalNetAccountedDr :=  g_tb_totalNetAccountedDr + nvl(l_acctd_dr,0);
           g_tb_totalNetAccountedCr :=  g_tb_totalNetAccountedCr + nvl(l_acctd_cr,0);
           g_tb_totalNetReportingDr :=  g_tb_totalNetReportingDr + nvl(l_report_dr,0);
           g_tb_totalNetReportingCr :=  g_tb_totalNetReportingCr + nvl(l_report_cr,0);
*/
       END IF; -- not secured

      ELSE -- No more rows
       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
           (p_msg      => 'no more rows'
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   =>l_log_module);
       END IF;

       IF dbms_sql.IS_OPEN(c_tb) THEN
          dbms_sql.close_cursor(c_tb);
       END IF;
       p_eof := TRUE;

       --IF (NOT g_tb_secure) THEN
          -- Print summary line

          IF (prv_OrganizeBy = 'ACCOUNT') AND
            (prv_ApplicationId = 101)  THEN
             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      => 'da:'
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   =>l_log_module);
             END IF;
             getBalances( g_tb_openingBalanceDr
                        ,g_tb_openingBalanceCr
                        ,g_tb_current_ccid
                        ,g_tb_period_name
                        ,g_tb_account_type );

             -- If the entry is posted then calculate opening balance.
             IF l_status = 'P' THEN
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                 trace
                    (p_msg      => 'db:'
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   =>l_log_module);
               END IF;
               l_balance := nvl(g_tb_openingBalanceDr,0) - nvl(g_tb_openingBalanceCr,0);
               getAccountBalance(l_balance
                               ,prv_Trx_Hdr_Id
                               ,g_tb_openingBalanceDr
                               ,g_tb_openingBalanceCr
                               ,g_tb_current_Ccid
                               ,g_tb_account_type);
             END IF;

             -- Calculate closing Balance
             g_tb_closingBalanceDr := nvl(g_tb_openingBalanceDr,0) + nvl(g_tb_totalAcctCcidDr,0);
             g_tb_closingBalanceCr := nvl(g_tb_openingBalanceCr,0) + nvl(g_tb_totalAcctCcidCr,0);

             getNetBalance(g_tb_closingBalanceDr,
                         g_tb_closingBalanceCr,
                         g_tb_account_type );
          END IF;

          IF g_tb_currency_cnt > 0 THEN
             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                    (p_msg      => 'dc:'
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   =>l_log_module);
             END IF;
             l_rowCnt := l_rowCnt + 1;
             l_TBLineDataArray(l_rowCnt).lineType          :=  TB_LINE_MC;
             l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
             l_TBLineDataArray(l_rowCnt).enteredAmountDr   := g_tb_totalEnteredCurDr;
             l_TBLineDataArray(l_rowCnt).enteredAmountCr   := g_tb_totalEnteredCurCr;
             l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAccountedCurDr;
             l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAccountedCurCr;
             l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCurDr;
             l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCurCr;
             l_TBLineDataArray(l_rowCnt).enteredAmountNet  := nvl(g_tb_totalEnteredCurDr,0) - nvl(g_tb_totalEnteredCurCr,0);
             l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAccountedCurDr,0) - nvl(g_tb_totalAccountedCurCr,0);
             l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCurDr,0) - nvl(g_tb_totalReportingCurCr,0);

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 (p_msg      => 'ae:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                          l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                          l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                          l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                          l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                          l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'|| l_TBLineDataArray(l_rowCnt).accountedAmountNet
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
             END IF;
/*
             xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                          l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                          l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                          l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                          l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                          l_TBLineDataArray(l_rowCnt).enteredAmountNet || '|'|| l_TBLineDataArray(l_rowCnt).accountedAmountNet);
*/


             l_rowCnt := l_rowCnt + 1;
             l_TBLineDataArray(l_rowCnt).lineType          := TB_LINE_TOTAL_MC;
             l_TBLineDataArray(l_rowCnt).Account           := g_tb_segment_values;
             l_TBLineDataArray(l_rowCnt).AccountDesc       := g_tb_segments_desc;
             l_TBLineDataArray(l_rowCnt).balancebeforeDr   := g_tb_openingBalanceDr;
             l_TBLineDataArray(l_rowCnt).balancebeforeCr   := g_tb_openingBalanceCr;
             l_TBLineDataArray(l_rowCnt).balancebeforeNet  := Nvl(g_tb_openingBalanceDr,0) - Nvl(g_tb_openingBalanceCr,0) ;
             l_TBLineDataArray(l_rowCnt).balanceAfterDr    := g_tb_closingBalanceDr;
             l_TBLineDataArray(l_rowCnt).balanceAfterCr    := g_tb_closingBalanceCr;
             l_TBLineDataArray(l_rowCnt).balanceAfterNet   := Nvl(g_tb_closingBalanceDr,0) - Nvl(g_tb_closingBalanceCr,0);
             l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
             l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAcctCcidDr;
             l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAcctCcidCr;
             l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCcidDr;
             l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCcidCr;
             l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAcctCcidDr,0) - nvl(g_tb_totalAcctCcidCr,0);
             l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCcidDr,0) - nvl(g_tb_totalReportingCcidCr,0);
             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 (p_msg      => 'af:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                          l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                          l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc || '|' ||
                          l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                          l_TBLineDataArray(l_rowCnt).accountedAmountNet
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
             END IF;
/*
             xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                          l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                          l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc || '|' ||
                          l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr || '|' ||
                          l_TBLineDataArray(l_rowCnt).accountedAmountNet);
*/
             getNetBalance(g_tb_totalAcctCcidDr,
                         g_tb_totalAcctCcidCr,
                         g_tb_account_type);

             getNetBalance(g_tb_totalReportingCcidDr,
                         g_tb_totalReportingCcidCr,
                         g_tb_account_type);

             -- Report Totals
             g_tb_totalNetAccountedDr :=  g_tb_totalNetAccountedDr + nvl(g_tb_totalAcctCcidDr,0);
             g_tb_totalNetAccountedCr :=  g_tb_totalNetAccountedCr + nvl(g_tb_totalAcctCcidCr,0);
             g_tb_totalNetReportingDr :=  g_tb_totalNetReportingDr + nvl(g_tb_totalReportingCcidDr,0);
             g_tb_totalNetReportingCr :=  g_tb_totalNetReportingCr + nvl(g_tb_totalReportingCcidCr,0);
                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      => 'dd:totalnetaccounteddr'||g_tb_totalNetAccountedDr|| '*g_tb_totalNetAccountedCr:'||g_tb_totalNetAccountedCr
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   =>l_log_module);
                   END IF;

          ELSE
             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                    (p_msg      => 'dd:'
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   =>l_log_module);
             END IF;
             l_rowCnt := l_rowCnt + 1;
             l_TBLineDataArray(l_rowCnt).lineType          := TB_LINE;
             l_TBLineDataArray(l_rowCnt).Account           := g_tb_segment_values;
             l_TBLineDataArray(l_rowCnt).AccountDesc       := g_tb_segments_Desc;
             l_TBLineDataArray(l_rowCnt).balancebeforeDr   := g_tb_openingBalanceDr;
             l_TBLineDataArray(l_rowCnt).balancebeforeCr   := g_tb_openingBalanceCr;
             l_TBLineDataArray(l_rowCnt).balancebeforeNet  := nvl(g_tb_openingBalanceDr,0) - nvl(g_tb_openingBalanceCr,0) ;
             l_TBLineDataArray(l_rowCnt).balanceAfterDr    := g_tb_closingBalanceDr;
             l_TBLineDataArray(l_rowCnt).balanceAfterCr    := g_tb_closingBalanceCr;
             l_TBLineDataArray(l_rowCnt).balanceAfterNet   := nvl(g_tb_closingBalanceDr,0) - nvl(g_tb_closingBalanceCr,0);
             l_TBLineDataArray(l_rowCnt).enteredCurrency   := g_tb_currency_code;
             l_TBLineDataArray(l_rowCnt).enteredAmountDr   := g_tb_totalEntCcidDr;
             l_TBLineDataArray(l_rowCnt).enteredAmountCr   := g_tb_totalEntCcidCr;
             l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalAcctCcidDr;
             l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalAcctCcidCr;
             l_TBLineDataArray(l_rowCnt).reportedAmountDr  := g_tb_totalReportingCcidDr;
             l_TBLineDataArray(l_rowCnt).reportedAmountCr  := g_tb_totalReportingCcidCr;
             l_TBLineDataArray(l_rowCnt).enteredAmountNet  := nvl(g_tb_totalEntCcidDr,0) - nvl(g_tb_totalEntCcidCr,0);
             l_TBLineDataArray(l_rowCnt).accountedAmountNet  := nvl(g_tb_totalAcctCcidDr,0) - nvl(g_tb_totalAcctCcidCr,0);
             l_TBLineDataArray(l_rowCnt).reportingAmountNet  := nvl(g_tb_totalReportingCcidDr,0) - nvl(g_tb_totalReportingCcidCr,0);

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 (p_msg      => 'ag:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                        l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                       l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                       l_TBLineDataArray(l_rowCnt).balancebeforeDr || l_TBLineDataArray(l_rowCnt).balancebeforeCr ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
             END IF;
/*
             xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                        l_TBLineDataArray(l_rowCnt).enteredCurrency ||
                       l_TBLineDataArray(l_rowcnt).account || l_TBLineDataArray(l_rowcnt).accountdesc ||
                       l_TBLineDataArray(l_rowCnt).balancebeforeDr || l_TBLineDataArray(l_rowCnt).balancebeforeCr ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr);
*/
             getNetBalance(g_tb_totalAcctCcidDr,
                         g_tb_totalAcctCcidCr,
                         g_tb_account_type);

             getNetBalance(g_tb_totalReportingCcidDr,
                         g_tb_totalReportingCcidCr,
                         g_tb_account_type);

             -- Report Totals
             g_tb_totalNetAccountedDr :=  g_tb_totalNetAccountedDr + nvl(g_tb_totalAcctCcidDr,0);
             g_tb_totalNetAccountedCr :=  g_tb_totalNetAccountedCr + nvl(g_tb_totalAcctCcidCr,0);
             g_tb_totalNetReportingDr :=  g_tb_totalNetReportingDr + nvl(g_tb_totalReportingCcidDr,0);
             g_tb_totalNetReportingCr :=  g_tb_totalNetReportingCr + nvl(g_tb_totalReportingCcidCr,0);
                   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                           (p_msg      => 'dd:totalnetaccounteddr'||g_tb_totalNetAccountedDr|| '*g_tb_totalNetAccountedCr:'||g_tb_totalNetAccountedCr
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   =>l_log_module);
                   END IF;
          END IF;


          -- Populate Report Totals
          l_rowCnt := l_rowCnt + 1;
          l_TBLineDataArray(l_rowCnt).lineType          := TB_DUMMY;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                 (p_msg      => 'ah:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
          END IF;
/*
          xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr);
*/
          l_rowCnt := l_rowCnt + 1;
          l_TBLineDataArray(l_rowCnt).lineType          := TB_TOTAL_ACTIVITY_DRCR;
          l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalNetAccountedDr;
          l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalNetAccountedCr;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                 (p_msg      => 'ai:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
          END IF;
/*
          xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr);
*/

          l_rowCnt := l_rowCnt + 1;
          l_TBLineDataArray(l_rowCnt).lineType          := TB_TOTAL_ACT_DR;
          l_TBLineDataArray(l_rowCnt).accountedAmountDr := g_tb_totalNetAccountedDr;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                 (p_msg      => 'aj:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
          END IF;

/*
          xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr);
*/
          l_rowCnt := l_rowCnt + 1;
          l_TBLineDataArray(l_rowCnt).lineType          := TB_TOTAL_ACT_CR;
          l_TBLineDataArray(l_rowCnt).accountedAmountCr := g_tb_totalNetAccountedCr;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                 (p_msg      => 'ak:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
          END IF;

/*
          xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr);
*/
          -- Populate End Of File row.
          l_rowCnt := l_rowCnt +1;
          l_TBLineDataArray(l_rowCnt).lineType  := TB_EOF;

          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                 (p_msg      => 'al:'||g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   =>l_log_module);
          END IF;
/*
          xla_util.debug(g_tb_current_account || getlinetype(l_TBLineDataArray(l_rowCnt).LineType,'tb') || '       |' ||
                       l_TBLineDataArray(l_rowCnt).enteredAmountDr || '|' || l_TBLineDataArray(l_rowCnt).enteredAmountCr || '|' ||
                       l_TBLineDataArray(l_rowCnt).accountedAmountDr || '|' || l_TBLineDataArray(l_rowCnt).accountedAmountCr);
*/
       --END IF;
       EXIT;
     END IF;
  END LOOP;              -- fetch_rows

  -- Assign values to an out NOCOPY parameter
  p_TBLineDataArray := l_TBLineDataArray;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of Procedure tb_fetch_rows'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
       l_temp:=1;
       LOOP
         EXIT WHEN l_temp>l_rowCnt;
           trace
               (p_msg      => 'row No is:'||to_char(l_temp)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'lineType:'||getlinetype(l_TBLineDataArray(l_temp).LineType, 'tb')
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'enteredCurrency:'||l_TBLineDataArray(l_temp).enteredCurrency
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'account:'||l_TBLineDataArray(l_temp).account||l_TBLineDataArray(l_temp).accountdesc
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'accountedamountDr:'||l_TBLineDataArray(l_temp).accountedAmountDr
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'accountedamountCr:'||l_TBLineDataArray(l_temp).accountedAmountCr
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           trace
               (p_msg      => 'accountedamountNet:'||l_TBLineDataArray(l_temp).accountedAmountNet
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   =>l_log_module);
           l_temp:=l_temp+1;
       end loop;
  END IF;

END tb_fetch_rows;
/*
  Calculate Account Balance
*/
PROCEDURE  getAccountBalance( p_amount       IN  NUMBER
                          ,p_trx_hdr_id   IN  NUMBER
                          ,p_amount_dr    OUT NOCOPY NUMBER
                          ,p_amount_cr    OUT NOCOPY NUMBER
                          ,p_Ccid         IN  NUMBER
                          ,p_account_type IN  VARCHAR2
                           )IS
l_amount    Number := 0;
l_log_module                VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.getAccountBalance';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure getAccountBalance'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_amount is:'||to_char(p_amount)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_trx_hdr_id is:'||to_char(p_trx_hdr_id)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_ccid is:'||to_char(p_Ccid)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_account type is:'||p_account_type
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

   --xla_util.debug('p_trx_hdr_id ' || p_trx_hdr_id);
   --xla_util.debug('p_Ccid ' || p_Ccid);

   SELECT   SUM(Nvl(accounted_Dr,0))- SUM(Nvl(Accounted_Cr,0))
     INTO   l_amount
     FROM   gl_je_lines
    WHERE   je_header_id        = p_trx_hdr_id
      AND   code_combination_id = p_Ccid;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
           (p_msg      => 'l_amount ' || l_amount
           ,p_level    => C_LEVEL_STATEMENT
          ,p_module   =>l_log_module);
   END IF;

   l_amount := nvl(p_amount,0) - l_amount;

   IF l_amount > 0 THEN
      p_amount_dr := l_amount;
   ELSIF l_amount < 0 THEN
      p_amount_cr := -1*l_amount;
   ELSE
      IF p_account_type in ('A','E') THEN
        p_amount_dr := 0;
       ELSE
-- Is it a bug? both are p_amount_dr--wei
        p_amount_dr  := 0;
      END IF;
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of Procedure getNetBalance'
         ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
      trace
         (p_msg      => 'out var:p_amount_dr:'||to_char(p_amount_dr)
         ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
      trace
         (p_msg      => 'out var:p_amount_cr:'||to_char(p_amount_cr)
         ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;


EXCEPTION
  WHEN OTHERS THEN
     p_amount_Dr := 0;
     p_amount_Cr := 0;

END getAccountBalance;

PROCEDURE getNetBalance( p_AccountedDr  IN OUT NOCOPY NUMBER
                        ,p_AccountedCr  IN OUT NOCOPY NUMBER
                        ,p_AccountType  IN     VARCHAR2) IS
l_balance      NUMBER;
l_amount       NUMBER;
l_amount_dr    NUMBER;
l_amount_cr    NUMBER;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.getNetBalance';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure getNetBalance'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_accounteddr is:'||to_char(p_AccountedDr)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_accountedcr is:'||to_char(p_AccountedCr)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_account type is:'|| p_AccountType
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

/*
   xla_util.debug('p_AccountedDr = ' || p_AccountedDr);
   xla_util.debug('p_AccountedCr = ' || p_AccountedCr);
*/

   l_amount_dr  := nvl(p_accountedDr,0);
   l_amount_cr  := nvl(p_accountedCr,0);

   p_accountedDr := nvl(p_accountedDr,0);
   p_accountedCr := nvl(p_accountedCr,0);

   IF p_accountedDr < 0 Then
      p_accountedDr := -1*p_accountedDr;
   END IF;

   IF P_accountedCr < 0 Then
      p_accountedCr := -1*p_accountedCr;
   END IF;


   IF (p_AccountedDr > p_accountedCr) THEN
      p_AccountedDr := l_amount_dr - l_amount_cr;
      p_accountedCr := NULL;
    ELSIF (p_AccountedCr > p_accountedDr) THEN
      p_AccountedCr := l_amount_cr - l_amount_dr;
      p_accountedDr := NULL;
    ELSE
      IF p_accountType IN ('A','E') THEN
        p_AccountedDr := 0 ;
        p_AccountedCr := NULL ;
      ELSE
        p_AccountedDr := NULL ;
        p_AccountedCr := 0 ;
      END IF;
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of Procedure getNetBalance'
         ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
      trace
         (p_msg      => 'out var:p_AccountedDr:'||to_char(p_AccountedDr)
         ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
      trace
         (p_msg      => 'out var:p_AccountedCr:'||to_char(p_AccountedCr)
         ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
   END IF;

END getNetBalance;

/* Close TA cursor */
PROCEDURE ta_close IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.ta_close';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure ta_close'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

   IF dbms_sql.IS_OPEN(c_ta) THEN
      dbms_sql.close_cursor(c_ta);
   END IF;
END ta_close;

/* Close TB cursor */
PROCEDURE tb_close IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.tb_close';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of procedure tb_close'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

   IF dbms_sql.IS_OPEN(c_tb) THEN
      dbms_sql.close_cursor(c_tb);
   END IF;
END tb_close;

/* Returns the total */
FUNCTION getTotal( p_total_amount       IN      NUMBER
                  ,p_current_amount     IN      NUMBER
                 ) RETURN NUMBER IS
l_total_amount Number;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.getTotal';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of function getTotal'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_total_amount is:'||to_char(p_total_amount)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_current_amount is:'||to_char(p_current_amount)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

   IF p_current_amount IS NOT NULL THEN
      l_total_amount := Nvl(p_total_amount,0) + p_current_amount;
   ELSE
      l_total_amount := p_total_amount;
   END IF;
   RETURN l_total_amount;
END getTotal;

-- Used for debugging purpose only.
FUNCTION getLineType ( p_TypeId binary_integer,
                       p_tatb   varchar2 default 'ta' ) RETURN VARCHAR2 IS
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.getLineType';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => 'BEGIN of function getLineType'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_typeid is:'||to_char(p_TypeId)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
    trace
          (p_msg      => 'p_tatb is:'||p_tatb
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   =>l_log_module);
  END IF;

   IF p_tatb = 'ta' THEN
      IF p_typeid = 0 THEN
        RETURN('TA_ACCOUNT');
       ELSIF p_typeid = 1 THEN
        RETURN ('TA_ACCOUNT_DESC');
       ELSIF p_typeid = 2 THEN
        RETURN ('TA_ALL_CURR');
       ELSIF p_typeid = 3 THEN
        RETURN ('TA_BALANCE_BEFORE');
       ELSIF p_typeid = 4 THEN
        RETURN('TA_CURRENCY_TOTAL_MC');
       ELSIF p_typeid = 5 THEN
        RETURN('TA_ACCOUNT_TOTAL_SC');
       ELSIF p_typeid = 6 THEN
        RETURN('TA_ACCOUNT_TOTAL_MC');
       ELSIF p_typeid = 7 THEN
        RETURN('TA_ACTIVITY');
       ELSIF p_typeid = 8 THEN
        RETURN('TA_BALANCE_AFTER');
       ELSIF p_typeid = 9 THEN
        RETURN('TA_TOT_ACT_FOR_ALL_ACCOUNTS');
       ELSIF p_typeid = 10 THEN
        RETURN('TA_CURR_HEADER_MC');
       ELSIF p_typeid = 11 THEN
        RETURN('TA_CURR_HEADER_BLANK_MC');
       ELSIF p_typeid = -1 THEN
        RETURN('TA_EOF');
       ELSIF p_typeid = 100 THEN
        RETURN('TA_DUMMY');
       ELSE
        RETURN('Invalid linetype = '|| p_typeid);
      END IF;
    ELSE
      IF p_typeid = 0 THEN
        RETURN('TB_LINE');
       ELSIF p_typeid = 1 THEN
        RETURN('TB_LINE_MC');
       ELSIF p_typeid = 2 THEN
        RETURN('TB_TOTAL_ACTIVITY_DRCR');
       ELSIF p_typeid = 3 THEN
        RETURN('TB_TOTAL_ACT_DR');
       ELSIF p_typeid = 4 THEN
        RETURN('TB_TOTAL_ACT_CR');
       ELSIF p_typeid = 5 THEN
        RETURN('TB_LINE_TOTAL_MC');
       ELSIF p_typeid = 100 THEN
        RETURN('TB_DUMMY');
       ELSIF p_typeid = -1 THEN
        RETURN('TB_EOF');
       ELSE
        RETURN('Invalid linetype = '|| p_typeid);
      END IF;
   END IF;
END getLineType;

--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END XLA_TACCOUNTS_DATA_PKG;

/
