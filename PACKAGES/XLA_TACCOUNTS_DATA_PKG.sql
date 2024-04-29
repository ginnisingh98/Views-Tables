--------------------------------------------------------
--  DDL for Package XLA_TACCOUNTS_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TACCOUNTS_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatacct.pkh 120.1 2004/02/13 23:02:28 weshen noship $ */

  -- Record structure for TAccounts
  TYPE LineData IS RECORD 	(
        lineType			NUMBER
       ,Ccid			        NUMBER(15)
       ,Account    		        VARCHAR2(1000)
       ,AccountDesc		        VARCHAR2(2000)
       ,lineReference			VARCHAR2(1000)
       ,enteredCurrency			VARCHAR2(15)
       ,accountingCurrency		VARCHAR2(15)
       ,enteredAmountDr			NUMBER
       ,enteredAmountCr			NUMBER
       ,accountedAmountDr		NUMBER
       ,accountedAmountCr		NUMBER
       ,reportedAmountDr		NUMBER
       ,reportedAmountCr		NUMBER
				 );

  TYPE t_TAlineDataArray IS TABLE OF LineData INDEX BY BINARY_INTEGER;

  TA_lineDataArray  t_TAlineDataArray;

  -- Record structure for Trial Balance
  TYPE TB_LineData IS RECORD (
        lineType			NUMBER
       ,Ccid			        NUMBER(15)
       ,Account    		        VARCHAR2(1000)
       ,AccountDesc		        VARCHAR2(2000)
       ,enteredCurrency			VARCHAR2(15)
       ,balancebeforeDr			NUMBER
       ,balancebeforeCr			NUMBER
       ,balancebeforeNet		NUMBER
       ,balanceAfterDr			NUMBER
       ,balanceAfterCr			NUMBER
       ,balanceAfterNet			NUMBER
       ,enteredAmountDr			NUMBER
       ,enteredAmountCr			NUMBER
       ,accountedAmountDr		NUMBER
       ,accountedAmountCr		NUMBER
       ,reportedAmountDr		NUMBER
       ,reportedAmountCr		NUMBER
       ,enteredAmountNet		NUMBER
       ,accountedAmountNet		NUMBER
       ,reportingAmountNet		NUMBER
     );

  TYPE T_TBLineDataArray  IS TABLE OF TB_LineData INDEX BY BINARY_INTEGER;

   AccountingCurrency			VARCHAR2(15);
   ReportingCurrency			VARCHAR2(15);


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    init                                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Accounting Data for T Accounts API                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id        				     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-Sep-98  Dirk Stevens   	Created                              |
 |     04-Aug-99  Mahesh Sabapthy       Added parameter cost_type_id to      |
 |                                      support Mfg. PAC transactions.       |
 |     16-Sep-99  Dimple Shah           Added parameters-                    |
 |                                      add_col_name_1, add_col_value_1,     |
 |                                      add_col_name_2, add_col_value_2      |
 |                                                                           |
 +===========================================================================*/
PROCEDURE ta_init 	(
         p_Application_ID        IN      NUMBER
        ,p_Trx_Header_Table      IN      VARCHAR2
        ,p_Trx_Header_ID         IN      NUMBER
        ,p_Cost_Type_ID          IN      NUMBER
        ,p_Chart_Of_Accounts_ID  IN      NUMBER
        ,p_Set_Of_Books_ID       IN      NUMBER
        ,p_Organize_By           IN      VARCHAR2       -- ACCOUNT | SEGMENT
        ,p_Segment1            	 IN      NUMBER
        ,p_Segment2              IN      NUMBER
        ,p_OverRidingWhereClause IN      VARCHAR2
        ,p_viewName		 IN      VARCHAR2
        ,p_add_col_name_1	 IN      VARCHAR2  DEFAULT NULL
        ,p_add_col_value_1	 IN      VARCHAR2  DEFAULT NULL
        ,p_add_col_name_2	 IN      VARCHAR2  DEFAULT NULL
        ,p_add_col_value_2	 IN      VARCHAR2  DEFAULT NULL
	);

PROCEDURE tb_init 	(
         p_Application_ID        IN      NUMBER
        ,p_Trx_Header_Table      IN      VARCHAR2
        ,p_Trx_Header_ID         IN      NUMBER
        ,p_Cost_Type_ID          IN      NUMBER
        ,p_Chart_Of_Accounts_ID  IN      NUMBER
        ,p_Set_Of_Books_ID       IN      NUMBER
        ,p_Organize_By           IN      VARCHAR2       -- ACCOUNT | SEGMENT
        ,p_Segment1            	 IN      NUMBER
        ,p_Segment2              IN      NUMBER
        ,p_OverRidingWhereClause IN      VARCHAR2
        ,p_viewName		 IN      VARCHAR2
        ,p_add_col_name_1	 IN      VARCHAR2  DEFAULT NULL
        ,p_add_col_value_1	 IN      VARCHAR2  DEFAULT NULL
        ,p_add_col_name_2	 IN      VARCHAR2  DEFAULT NULL
        ,p_add_col_value_2	 IN      VARCHAR2  DEFAULT NULL
	);

PROCEDURE ta_fetch_rows ( p_rows             IN NUMBER DEFAULT 50
			 ,p_TALineDataArray OUT NOCOPY T_TALineDataArray
			 ,p_eof             OUT NOCOPY BOOLEAN );
PROCEDURE ta_close;

PROCEDURE tb_fetch_rows (  p_rows            IN NUMBER DEFAULT 50
			  ,p_TbLineDataArray OUT NOCOPY T_TBLineDataArray
			  ,p_eof OUT NOCOPY BOOLEAN );
PROCEDURE tb_close;

FUNCTION getAccountingCurrency(pSetOfBooksID IN NUMBER)
 RETURN VARCHAR2;

FUNCTION getReportingCurrency(pSetOfBooksID IN NUMBER)
 RETURN VARCHAR2;

FUNCTION getChartOfAccountsID(pSetOfBooksID IN NUMBER)
 RETURN NUMBER;

FUNCTION xla_supported(p_application_id in NUMBER)
 RETURN NUMBER;

END XLA_TACCOUNTS_DATA_PKG;

 

/
