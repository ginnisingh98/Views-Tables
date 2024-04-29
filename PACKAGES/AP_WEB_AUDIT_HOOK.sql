--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_HOOK" AUTHID CURRENT_USER AS
/* $Header: apwaudhs.pls 115.2 2002/11/14 22:59:09 kwidjaja noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE audit_expense_report
 |
 | DESCRIPTION
 |   This package contains customization hook used to extend / replace default
 |   logic for selecting expense reports for audit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_expense_report_id           IN  Expense report header Identifier
 |   p_audit_reason_code           OUT NOCOPY Audit reason code, when report is
 |                                     audited this code will be stored
 |                                     in table AP_AUD_AUDIT_REASONS.
 |                                     If Null is passed, no row will be created.
 |   p_audit_report                OUT NOCOPY TRUE if report needs to be audited, FALSE
 |                                     otherwise. Null is considered as FALSE.
 |   p_override_default_processing OUT NOCOPY TRUE if customization overrides default audit
 |                                     processing, FALSE otherwise.
 |                                     Null is considered as FALSE.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE audit_expense_report(p_expense_report_id           IN  NUMBER,
                               p_audit_reason_code           OUT NOCOPY VARCHAR2,
                               p_audit_report                OUT NOCOPY BOOLEAN,
                               p_override_default_processing OUT NOCOPY BOOLEAN);

END AP_WEB_AUDIT_HOOK;

 

/
