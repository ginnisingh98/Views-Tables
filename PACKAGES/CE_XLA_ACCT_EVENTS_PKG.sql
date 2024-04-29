--------------------------------------------------------
--  DDL for Package CE_XLA_ACCT_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_XLA_ACCT_EVENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cexlaevs.pls 120.7 2005/08/30 20:51:10 bhchung noship $ */


/*========================================================================
 | PUBLIC FUNCTION Create_Events
 |
 | DESCRIPTION
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE Create_Event (X_trx_id		NUMBER,
		        X_event_type_code	VARCHAR2,
		        X_gl_date		DATE DEFAULT NULL);


PROCEDURE log(p_msg varchar2);

PROCEDURE postaccounting
   (p_application_id     NUMBER
   ,p_ledger_id          NUMBER
   ,p_process_category   VARCHAR2
   ,p_end_date           DATE
   ,p_accounting_mode    VARCHAR2
   ,p_valuation_method   VARCHAR2
   ,p_security_id_int_1  NUMBER
   ,p_security_id_int_2  NUMBER
   ,p_security_id_int_3  NUMBER
   ,p_security_id_char_1 VARCHAR2
   ,p_security_id_char_2 VARCHAR2
   ,p_security_id_char_3 VARCHAR2
   ,p_report_request_id  NUMBER    );

PROCEDURE preaccounting
   (p_application_id     NUMBER
   ,p_ledger_id          NUMBER
   ,p_process_category   VARCHAR2
   ,p_end_date           DATE
   ,p_accounting_mode    VARCHAR2
   ,p_valuation_method   VARCHAR2
   ,p_security_id_int_1  NUMBER
   ,p_security_id_int_2  NUMBER
   ,p_security_id_int_3  NUMBER
   ,p_security_id_char_1 VARCHAR2
   ,p_security_id_char_2 VARCHAR
   ,p_security_id_char_3 VARCHAR2
   ,p_report_request_id  NUMBER                    );

PROCEDURE extract
   (p_application_id     NUMBER
   ,p_accounting_mode    VARCHAR2                     );

PROCEDURE postprocessing
   (p_application_id     NUMBER
   ,p_accounting_mode    VARCHAR2                     );

FUNCTION ce_policy
   (obj_schema VARCHAR2
   ,obj_name VARCHAR2) RETURN VARCHAR2;

END CE_XLA_ACCT_EVENTS_PKG;

 

/
