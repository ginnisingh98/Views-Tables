--------------------------------------------------------
--  DDL for Package AP_WEB_OA_ACTIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_ACTIVE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwoaacs.pls 120.7.12010000.2 2009/06/01 07:23:16 dsadipir ship $ */

SUBTYPE language_code IS VARCHAR2(100);

FUNCTION GetApproverName (p_report_header_id IN NUMBER,
                          p_attribute_name IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GetApApprover RETURN VARCHAR2;

FUNCTION GetExpensesAdmin RETURN VARCHAR2;

FUNCTION GetWFLastNotificationActivity (p_report_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GetReportStatusCode(p_source IN VARCHAR2,
                         p_workflow_approved_flag IN VARCHAR2,
                         p_report_header_id IN NUMBER,
                         p_cache IN VARCHAR2 DEFAULT 'Y',
                         p_query_wf_activities IN VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2;

FUNCTION GetBothPayStatusCode(p_report_header_id IN NUMBER,
                              p_status_code IN VARCHAR2,
			      p_amt_due_ccard_company IN NUMBER,
			      p_amt_due_employee IN NUMBER) RETURN VARCHAR2;

FUNCTION GetReportStatus(p_source IN VARCHAR2,
                         p_workflow_approved_flag IN VARCHAR2,
                         p_report_header_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION GetCurrentApprover(p_source IN VARCHAR2,
                         p_workflow_approved_flag IN VARCHAR2,
                         p_report_header_id IN NUMBER,
                         p_status_code IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION GetIncludeNotification(p_category IN VARCHAR2,
                         p_trx_id IN NUMBER)
RETURN VARCHAR2;

-- Indicates the various constants possible for source
C_NonValidatedWebExpense CONSTANT VARCHAR2(22) := 'NonValidatedWebExpense';
C_WebExpense             CONSTANT VARCHAR2(10) := 'WebExpense';
C_XpenseXpress           CONSTANT VARCHAR2(12) := 'XpenseXpress';
C_SelfService            CONSTANT VARCHAR2(11) := 'SelfService';
C_CREDIT_CARD            CONSTANT VARCHAR2(11) := 'CREDIT CARD';
C_BOTH_PAY               CONSTANT VARCHAR2(11) := 'Both Pay';

-- Indicates the various values for workflow_approved_flag
C_WFSaved                CONSTANT VARCHAR2(1) := 'S';
C_WFRejected             CONSTANT VARCHAR2(1) := 'R';
C_WFReturned             CONSTANT VARCHAR2(1) := 'T';
C_WFManagerApproved      CONSTANT VARCHAR2(1) := 'M';
C_WFPayablesApproved     CONSTANT VARCHAR2(1) := 'P';
C_WFAutoApproved         CONSTANT VARCHAR2(1) := 'A';
C_WFMgrPayablesApproved  CONSTANT VARCHAR2(1) := 'Y';
C_WFNotApproved          CONSTANT VARCHAR2(1) := 'N';
--ER 1552747 - withdraw expense report
C_WFWithdrawn            CONSTANT VARCHAR2(1) := 'W';
C_WFInProgress           CONSTANT VARCHAR2(1) := 'I';

-- Indicates the various lookup values from lookup type EXPENSE REPORT STATUS
C_PENDMGR    CONSTANT VARCHAR2(7) := 'PENDMGR';    -- Pending Manager Approval
C_MGRAPPR    CONSTANT VARCHAR2(7) := 'MGRAPPR';    -- Pending Payables Approval
C_MGRPAYAPPR CONSTANT VARCHAR2(10) := 'MGRPAYAPPR'; -- Ready for Invoicing
C_RESOLUTN   CONSTANT VARCHAR2(8) := 'RESOLUTN';   -- Pending Your Resolution
C_EMPAPPR    CONSTANT VARCHAR2(7) := 'EMPAPPR';    -- Pending Employee Approval
C_ERROR      CONSTANT VARCHAR2(5) := 'ERROR';      -- Pending Error Correction
C_SAVED      CONSTANT VARCHAR2(5) := 'SAVED';      -- Saved
C_REJECTED   CONSTANT VARCHAR2(8) := 'REJECTED';   -- Rejected
C_RETURNED   CONSTANT VARCHAR2(8) := 'RETURNED';   -- Returned
C_INVOICED   CONSTANT VARCHAR2(8) := 'INVOICED';   -- Ready for Payment
--ER 1552747 - withdraw expense report
C_WITHDRAWN  CONSTANT VARCHAR2(9) := 'WITHDRAWN';  -- Withdrawn
C_INPROGRESS  CONSTANT VARCHAR2(10) := 'INPROGRESS'; -- Reports those Implictly Saved

-- Indicates constants used for workflow
-- Default item type
C_APEXP     CONSTANT VARCHAR2(5) := 'APEXP';

-- Workflow Item attribute names
C_APPROVER_DISPLAY_NAME CONSTANT VARCHAR2(21) := 'APPROVER_DISPLAY_NAME';
C_EMPLOYEE_DISPLAY_NAME CONSTANT VARCHAR2(21) := 'EMPLOYEE_DISPLAY_NAME';
C_PREPARER_DISPLAY_NAME CONSTANT VARCHAR2(21) := 'PREPARER_DISPLAY_NAME';

-- Workflow Activity Labels
C_REQUEST_EMPLOYEE_APPROVAL    CONSTANT VARCHAR2(30) := 'REQUEST_EMPLOYEE_APPROVAL';
C_INFORM_SYSADM_AP_VALID_FAIL  CONSTANT VARCHAR2(30) := 'INFORM_SYSADM_AP_VALID_FAIL';
C_INFORM_PREPARER_SHORTPAY     CONSTANT VARCHAR2(30) := 'INFORM_PREPARER_SHORTPAY';
C_INFORM_PREP_NO_MANAGER_RESP  CONSTANT VARCHAR2(30) := 'INFORM_PREP_NO_MANAGER_RESP';
C_INFORM_SYSADM_NO_APPROVER    CONSTANT VARCHAR2(30) := 'INFORM_SYSADM_NO_APPROVER';
C_INFORM_CUSTOM_VALIDATE_ERROR CONSTANT VARCHAR2(30) := 'INFORM_CUSTOM_VALIDATE_ERROR';
C_POLICY_SHORTPAY_NOTICE       CONSTANT VARCHAR2(30) := 'POLICY_SHORTPAY_NOTICE';
C_INFORM_NO_APPROVER	       CONSTANT VARCHAR2(30) := 'INFORM_NO_APPROVER';

-- Workflow Activity Status
C_NOTIFIED CONSTANT VARCHAR(10) := 'NOTIFIED';

-- Lookup types
C_EXPENSE_REPORT_APPROVER CONSTANT VARCHAR2(25) := 'EXPENSE REPORT APPROVER';
C_EXPENSE_REPORT_STATUS   CONSTANT VARCHAR2(25) := 'EXPENSE REPORT STATUS';

-- Lookup codes
C_AP       CONSTANT VARCHAR2(2) := 'AP';
C_EXPADMIN CONSTANT VARCHAR2(8) := 'EXPADMIN';

END AP_WEB_OA_ACTIVE_PKG;

/
