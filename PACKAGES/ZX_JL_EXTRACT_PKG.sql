--------------------------------------------------------
--  DDL for Package ZX_JL_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_JL_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxriextrajlppvts.pls 120.2 2006/04/28 20:11:47 skorrapa ship $ */


--
-----------------------------------------
--Public Type Declarations
-----------------------------------------
--

--
-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--

-----------------------------------------
--Private Methods Declarations
-----------------------------------------

-----------------------------------------
--Public Methods Declarations
-----------------------------------------

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FILTER_JL_AP_TAX_LINES                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure filters tax lines on SUB ITF Table.                     |
 |    And insert tax lines into jl_tax_extr_jl_temp Table if necessary       |
 |                                                                           |
 |    Called from AR_TAX_EXTRACT.EXECUTE_SQL                                 |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  P_MUN_TAX_TYPE_FROM       IN   VARCHAR2  Optional         |
 |                 P_MUN_TAX_TYPE_TO         IN   VARCHAR2  Optional         |
 |                 P_PROV_TAX_TYPE_FROM      IN   VARCHAR2  Optional         |
 |                 P_PROV_TAX_TYPE_TO        IN   VARCHAR2  Optional         |
 |                 P_EXC_TAX_TYPE_FROM       IN   VARCHAR2  Optional         |
 |                 P_EXC_TAX_TYPE_TO         IN   VARCHAR2  Optional         |
 |                 P_NON_TAXAB_TAX_TYPE      IN   VARCHAR2  Optional         |
 |                 P_VAT_PERC_TAX_TYPE_FROM  IN   VARCHAR2  Optional         |
 |                 P_VAT_PERC_TAX_TYPE_TO    IN   VARCHAR2  Optional         |
 |                 P_VAT_TAX_TYPE            IN   VARCHAR2  Optional         |
 |                 P_EXCLUDING_TRX_LETTER    IN   VARCHAR2  Optional         |
 |                 P_TRANSACTION_LETTER_FROM IN   VARCHAR2  Optional         |
 |                 P_TRANSACTION_LETTER_TO   IN   VARCHAR2  Optional         |
 |                 P_REPORT_NAME             IN   VARCHAR2  Required         |
 |                 P_REQUEST_ID              IN   NUMBER    Required         |
 |                 P_EXTRACT_DECLARER_ID     IN   NUMBER    Required         |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |     17-Feb-04  Hidekoji          Modified parameters                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE FILTER_JL_AP_TAX_LINES;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FILTER_JL_AR_TAX_LINES                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure filters tax lines on SUB ITF Table.                     |
 |    and insert tax lines into ar_tax_extr_jl_temp Table if necessary.      |
 |                                                                           |
 |    Called from AR_TAX_EXTRACT.EXECUTE_SQL                                 |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :  P_MUN_TAX_CATEG_REGIME        IN   VARCHAR2 Optional      |
 |                 P_PROV_TAX_CATEG_REGIME       IN   VARCHAR2 Optional      |
 |                 P_EXC_TAX_CATEGORY            IN   VARCHAR2 Optional      |
 |                 P_VAT_ADDIT_TAX_CATEGORY      IN   VARCHAR2 Optional      |
 |                 P_VAT_NON_TAXAB_TAX_CATEG     IN   VARCHAR2 Optional      |
 |                 P_VAT_NOT_CATEG_TAX_CATEG     IN   VARCHAR2 Optional      |
 |                 P_VAT_PERC_TAX_CATEGORY       IN   VARCHAR2 Optional      |
 |                 P_VAT_TAX_CATEGORY            IN   VARCHAR2 Optional      |
 |                 P_INC_SELF_WD_TAX_CATEG       IN   VARCHAR2 Optional      |
 |                 P_REPORT_NAME                 IN   VARCHAR2 Required      |
 |                 P_REQUEST_ID                  IN   NUMBER   Required      |
 |                 P_EXTRACT_DECLARER_ID         IN   NUMBER   Required      |
 |                 P_GL_DATE_FROM                IN   DATE     Optional      |
 |                 P_GL_DATE_TO                  IN   DATE     Optional      |
 |                 P_TRX_LETTER_FROM             IN   VARCHAR2 Optional      |
 |                 P_TRX_LETTER_TO               IN   VARCHAR2 Optional      |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     07-Nov-03  Hidetaka Kojima   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE FILTER_JL_AR_TAX_LINES
   (P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
   );

/*==================================================================================+
 | PROCEDURE                                                                        |
 |   POPULATE_JL_AP                                                                 |
 |   Type       : Public                                                            |
 |   Pre-req    : None                                                              |
 |   Function   :                                                                   |
 |    This procedure calls the API to select the JL AP specific data from           |
 |    JL tables and returns fetched values                                          |
 |                                                                                  |
 |    Called from AR_TAX_POPULATE.POPULATE_INV                                      |
 |                                                                                  |
 |   Parameters :                                                                   |
 |   IN   :                                                                         |
 |   OUT:                                                                           |
 |                                                                                  |
 |   MODIFICATION HISTORY                                                           |
 |     27-Oct-03  Asako Takahashi   created                                         |
 |     17-Feb-04  Hidekoji          Modified the parameters                         |
 |     11-May-04  Hidekoji          Modified the parameters                         |
 |                                                                                  |
 +==================================================================================*/

PROCEDURE POPULATE_JL_AP(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

/*=====================================================================================+
 | PROCEDURE                                                                           |
 |   POPULATE_JL_AR                                                                    |
 |   Type       : Public                                                               |
 |   Pre-req    : None                                                                 |
 |   Function   :                                                                      |
 |    This procedure calls the API to select the JL AR specific data from              |
 |    JL tables and returns fetched values                                             |
 |                                                                                     |
 |    Called from ARP_TAX_EXTRACT.POPULATE_MISSING_COLUMNS.                            |
 |                                                                                     |
 |   Parameters :                                                                      |
 |   IN   :                                                                            |
 |    OUT:                                                                             |
 |                                                                                     |
 |   MODIFICATION HISTORY                                                              |
 |     27-Oct-03  Asako Takahashi   created                                            |
 |     17-Feb-04  Hidekoji          Modified the parameters                            |
 |     11-May-04  Hidekoji          Modified the parameters                            |
 |                                                                                     |
 +=====================================================================================*/

PROCEDURE POPULATE_JL_AR(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

END ZX_JL_EXTRACT_PKG;

 

/
