--------------------------------------------------------
--  DDL for Package JL_BR_AR_REMIT_COLL_OCCUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_REMIT_COLL_OCCUR" AUTHID CURRENT_USER AS
/*$Header: jlbrrats.pls 120.4.12010000.1 2008/07/31 04:22:34 appldev ship $*/

PROCEDURE remit_collection (
	P_BORDERO_ID 	IN	NUMBER,
	P_USER_ID 	IN	NUMBER,
        P_PROC_STATUS   IN OUT NOCOPY  NUMBER);

PROCEDURE remit_occurrence (
	P_BORDERO_ID 	IN	NUMBER,
        P_PROC_STATUS   IN OUT NOCOPY  NUMBER);

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_acct_line_type_name                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This function is required to be called in occurrence view, where it     |
 |   passes the meaning of the lookup code which is passed as the parameter, |
 |   to the view column ACCT_LINE_TYPE_NAME which is required to be shown    |
 |   in SLA forms to name the account line.                                  |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |   none                                                                    |
 |                                                                           |
 | ARGUMENTS                                                     	     |
 |   account line type                                                       |
 |                                                                           |
 | USAGE NOTES:                                                              |
 |   Begin                                                                   |
 |     x := JL_BR_AR_REMIT_COLL_OCCUR.get_acct_line_type_name;               |
 |   End;                                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-APR-00  Santosh Vaze      	Created                              |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_acct_line_type_name (code  VARCHAR2) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES( get_acct_line_type_name, WNDS );


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_trx_class_name                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This function is required to be called in bank transfer view, where it  |
 |   passes the meaning of the lookup code to the view column TRX_CLASS_NAME |
 |   which is required to be shown in SLA forms to name the transaction class|
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |   none                                                                    |
 |                                                                           |
 | ARGUMENTS                                                     	     |
 |   transaction class code                                                  |
 |                                                                           |
 | USAGE NOTES:                                                              |
 |   Begin                                                                   |
 |     x := JL_BR_AR_REMIT_COLL_OCCUR.get_trx_class_name;                    |
 |   End;                                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-APR-00  Santosh Vaze      	Created                              |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_trx_class_name (trx_class  VARCHAR2) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES( get_trx_class_name, WNDS);

END JL_BR_AR_REMIT_COLL_OCCUR;

/
