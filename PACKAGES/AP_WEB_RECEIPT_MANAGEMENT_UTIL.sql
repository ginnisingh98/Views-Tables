--------------------------------------------------------
--  DDL for Package AP_WEB_RECEIPT_MANAGEMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_RECEIPT_MANAGEMENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: apwrmuts.pls 120.2.12010000.2 2010/04/18 12:43:14 rveliche ship $ */
/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


 C_EVENT_WAIVE_RECEIPTS        CONSTANT VARCHAR2(100) := 'WAIVE_RECEIPTS';
 C_EVENT_WAIVE_COMPLETE        CONSTANT VARCHAR2(100) := 'WAIVE_COMPLETE';
 C_EVENT_RECEIVE_RECEIPTS      CONSTANT VARCHAR2(100) := 'RECEIVE_RECEIPTS';
 C_EVENT_RECEIPTS_NOT_RECEIVED CONSTANT VARCHAR2(100) := 'RECEIPTS_NOT_RECEIVED';
 C_EVENT_RECEIPTS_IN_TRANSIT   CONSTANT VARCHAR2(100) := 'RECEIPTS_IN_TRANSIT';
 C_EVENT_REQUEST_INFO          CONSTANT VARCHAR2(100) := 'REQUEST_INFO';
 C_EVENT_REJECT                CONSTANT VARCHAR2(100) := 'REJECT';
 C_EVENT_MR_SHORTPAY           CONSTANT VARCHAR2(100) := 'RECEIPT_MISSING_SHORTPAY';
 C_EVENT_MIR_SHORTPAY           CONSTANT VARCHAR2(100) := 'RECEIPT_MISSING_IMG_SHORTPAY';
 C_EVENT_MBR_SHORTPAY           CONSTANT VARCHAR2(100) := 'RECEIPT_MISSING_BOTH_SHORTPAY';
 C_EVENT_PV_SHORTPAY           CONSTANT VARCHAR2(100) := 'POLICY_VIOLATION_SHORTPAY';
 C_EVENT_SHORTPAY              CONSTANT VARCHAR2(100) := 'SHORTPAY';
 C_EVENT_RELEASE_HOLD          CONSTANT VARCHAR2(100) := 'RELEASE_HOLD';
 C_EVENT_COMPLETE_AUDIT        CONSTANT VARCHAR2(100) := 'COMPLETE_AUDIT';
 C_EVENT_NONE                  CONSTANT VARCHAR2(100) := 'NONE';


 C_STATUS_IN_TRANSIT   CONSTANT VARCHAR2(30) := 'IN_TRANSIT';
 C_STATUS_MISSING      CONSTANT VARCHAR2(30) := 'MISSING';
 C_STATUS_NOT_REQUIRED CONSTANT VARCHAR2(30) := 'NOT_REQUIRED';
 C_STATUS_OVERDUE      CONSTANT VARCHAR2(30) := 'OVERDUE';
 C_STATUS_RESOLUTN     CONSTANT VARCHAR2(30) := 'RESOLUTN';
 C_STATUS_RECEIVED     CONSTANT VARCHAR2(30) := 'RECEIVED';
 C_STATUS_REQUIRED     CONSTANT VARCHAR2(30) := 'REQUIRED';
 C_STATUS_WAIVED       CONSTANT VARCHAR2(30) := 'WAIVED';


/*========================================================================
 | PUBLIC FUNCTION get_receipt_status
 |
 | DESCRIPTION
 |   This function returns the receipt status for a expense report. If no
 |   event is passed in as parameter, then the status deducted from the
 |   current status and values on line columns. If an event is passed in
 |   then it is also taken into consideration when deducting the receipt
 |   status.
 |
 |   Note if this logic is called from BC4J, then the changes on the page
 |   need to be posted in order for this function to be able to see them.
 |   To do that, call this function from the OAViewObjectImpl.beforeCommit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and workflow logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Receipt status as VARCHAR2.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |  p_event           IN event taken on the report one of the following:
 |                         C_EVENT_WAIVE_RECEIPTS
 |                         C_EVENT_WAIVE_COMPLETE
 |                         C_EVENT_RECEIVE_RECEIPTS
 |                         C_EVENT_RECEIPTS_NOT_RECEIVED
 |                         C_EVENT_RECEIPTS_IN_TRANSIT
 |                         C_EVENT_MR_SHORTPAY
 |                         C_EVENT_PV_SHORTPAY
 |                         C_EVENT_SHORTPAY
 |                         C_EVENT_NONE
 |                         C_EVENT_REJECT
 |                         C_EVENT_REQUEST_INFO
 |                         C_EVENT_RELEASE_HOLD
 |                         C_EVENT_COMPLETE_AUDIT
 |                        The value is defaulted to C_EVENT_NONE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Aug-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_receipt_status(p_report_header_id IN NUMBER,
                            p_event           IN VARCHAR2 DEFAULT C_EVENT_NONE) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE handle_event
 |
 | DESCRIPTION
 |   This procedure handles a receipt management related event.
 |
 |   Note if this logic is called from BC4J, then the changes on the page
 |   need to be posted in order for this function to be able to see them.
 |   To do that, call this function from the OAViewObjectImpl.beforeCommit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and workflow logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Receipt status as VARCHAR2.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |  p_event           IN event taken on the report one of the following:
 |                         C_EVENT_WAIVE_RECEIPTS
 |                         C_EVENT_WAIVE_COMPLETE
 |                         C_EVENT_RECEIVE_RECEIPTS
 |                         C_EVENT_RECEIPTS_NOT_RECEIVED
 |                         C_EVENT_MR_SHORTPAY
 |                         C_EVENT_PV_SHORTPAY
 |                         C_EVENT_SHORTPAY
 |                         C_EVENT_REJECT
 |                         C_EVENT_REQUEST_INFO
 |                         C_EVENT_RELEASE_HOLD
 |                         C_EVENT_COMPLETE_AUDIT
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Aug-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE handle_event(p_report_header_id IN NUMBER,
                       p_event           IN VARCHAR2);

/*========================================================================
 | PUBLIC FUNCTION is_shortpaid_report
 |
 | DESCRIPTION
 |   This function detects whether a report is a shortpaid report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and workflow logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y or N depending whether the report is shortpaid of the particualr type.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |  p_shortpay_type    IN type of the shortpay:
 |                         AP_WEB_RECEIPTS_WF.C_NO_RECEIPTS_SHORTPAY_PROCESS
 |                         AP_WEB_RECEIPTS_WF.C_POLICY_VIOLATION_PROCESS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 31-Dec-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_shortpaid_report(p_report_header_id IN NUMBER,
                             p_shortpay_type    IN VARCHAR2) RETURN VARCHAR2;

END AP_WEB_RECEIPT_MANAGEMENT_UTIL;

/
