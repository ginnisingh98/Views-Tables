--------------------------------------------------------
--  DDL for Package ZX_JA_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_JA_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxriextrajappvts.pls 120.1 2005/04/01 18:48:10 skorrapa noship $ */


--
-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--

-----------------------------------------
--Public Methods Declarations
-----------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FILTER_JA_AR_TAX_LINES                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure is called to filter the records of transaction tables   |
 |    by deleting all unnecessary rows in ZX_RE_TRX_DETAIL_T table           |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG                                             |
 |                                                                           |
 |   Parameters :                                                            |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/



PROCEDURE FILTER_JA_AR_TAX_LINES
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

/* Following parameters are removed since we now access global variables directly
(
P_REPORT_NAME            IN     varchar2,
P_REQUEST_ID             IN     number,
P_EXP_CERT_DATE_FROM     IN     date,
P_EXP_CERT_DATE_TO       IN     date,
P_EXP_METHOD             IN     varchar2,
P_TRX_SOURCE_ID          IN     number,
P_INCLUDE_REFERENCED_SOURCE IN  varchar2
);
*/


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FILTER_JA_AP_TAX_LINES                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure is called to filter the records of transaction tables   |
 |    by deleting all unnecessary rows in ZX_RE_TRX_DETAIL_T table           |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG                                             |
 |                                                                           |
 |   Parameters :                                                            |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE FILTER_JA_AP_TAX_LINES
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

/* Following parameters are removed since we now access global variables directly
(
P_REPORT_NAME            IN     varchar2,
P_REQUEST_ID             IN     number,
P_GUI_TYPE               IN     varchar2,
P_REPRINT                IN     varchar2,
-- P_APPLIED_TRX_NUMBER_LOW in     varchar2,
-- P_APPLIED_TRX_NUMBER_HIGH in    varchar2,
P_MRCSOBTYPE             in varchar2,
P_REPORTING_LEVEL        in varchar2,
P_REPORTING_CONTEXT      in number,
P_SET_OF_BOOKS_ID        in number
);
*/

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   POPULATE_JA_AP(AR)                                                      |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure calls the API to select the missing JA reports's        |
 |    specific data                                                          |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG                                             |
 |                                                                           |
 |   Parameters :                                                            |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE POPULATE_JA_AR
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

/* Following parameter is removed since we now access global variables directly
(P_REPORT_NAME in varchar2);
*/

PROCEDURE POPULATE_JA_AP
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

/* Following parameter is removed since we now access global variables directly
(P_REPORT_NAME in varchar2);
*/

END ZX_JA_EXTRACT_PKG;

 

/
