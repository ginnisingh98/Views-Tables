--------------------------------------------------------
--  DDL for Package AP_TRIAL_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TRIAL_BALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: aptrbals.pls 120.1 2004/10/29 19:05:56 pjena noship $ */

TYPE transfer_run_id IS TABLE OF
                     xla_gl_transfer_batches_all.gl_transfer_run_id%TYPE
                     INDEX BY BINARY_INTEGER;

FUNCTION Process_Trial_Balance (
                 p_accounting_date          IN  DATE,
                 p_from_date                IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_alb            IN  VARCHAR2,
                 p_org_where_ael            IN  VARCHAR2,
                 p_org_where_asp            IN  VARCHAR2,
                 p_neg_bal_only             IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN;

FUNCTION Insert_AP_Trial_Bal (
                 p_accounting_date          IN  DATE,
                 p_from_date                IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_alb            IN  VARCHAR2,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN;

FUNCTION Insert_AP_Trial_Bal (
                 p_accounting_date          IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_alb            IN  VARCHAR2,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN;

FUNCTION Insert_Future_Dated (
                 p_accounting_date          IN  DATE,
                 p_from_date                IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN;

FUNCTION Insert_Future_Dated (
                 p_accounting_date          IN  DATE,
                 p_request_id               IN  NUMBER,
                 p_reporting_entity_id      IN  NUMBER,
                 p_org_where_ael            IN  VARCHAR2,
                 p_debug_switch             IN  VARCHAR2)
                 RETURN BOOLEAN;

FUNCTION Process_Neg_Bal (
                 p_request_id               IN  NUMBER)
                 RETURN BOOLEAN;


FUNCTION Use_Future_Dated (
             p_org_where_asp            IN  VARCHAR2,
             p_debug_switch             IN  VARCHAR2)
             RETURN BOOLEAN;

FUNCTION Insert_AP_Liability_Balance (
                 p_request_id               IN  NUMBER,
                 p_user_id                  IN  NUMBER,
                 p_resp_appl_id             IN  NUMBER,
                 p_login_id                 IN  NUMBER,
                 p_program_id               IN  NUMBER,
                 p_program_appl_id          IN  NUMBER)
                 RETURN BOOLEAN;

FUNCTION Update_Trial_Balance_Flag (
                 p_gl_transfer_run_id       IN  NUMBER)
                 RETURN BOOLEAN;

FUNCTION Is_Reporting_Books (
                p_set_of_books_id           IN NUMBER)
                RETURN BOOLEAN;

FUNCTION Get_Base_Currency_Code (
                p_set_of_books_id           IN NUMBER)
                RETURN VARCHAR2;

FUNCTION Get_Invoice_Amount (
                p_set_of_books_id           IN NUMBER,
                p_invoice_id                IN NUMBER,
                p_invoice_amount            IN NUMBER,
                p_exchange_rate             IN NUMBER)
                RETURN NUMBER;


END AP_TRIAL_BALANCE_PKG;

 

/
