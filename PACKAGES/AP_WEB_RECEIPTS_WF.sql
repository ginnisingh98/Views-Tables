--------------------------------------------------------
--  DDL for Package AP_WEB_RECEIPTS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_RECEIPTS_WF" AUTHID CURRENT_USER AS
/* $Header: apwrecpts.pls 120.3.12010000.2 2010/04/18 12:44:21 rveliche ship $ */

------------------------
-- Item Types
------------------------
C_APWRECPT      CONSTANT VARCHAR2(8) := 'APWRECPT';
C_APEXP         CONSTANT VARCHAR2(8) := 'APEXP';

------------------------
-- Shortpay Processes
------------------------
C_NO_RECEIPTS_SHORTPAY_PROCESS          CONSTANT VARCHAR2(30) := 'NO_RECEIPTS_SHORTPAY_PROCESS'; -- missing
C_POLICY_VIOLATION_PROCESS              CONSTANT VARCHAR2(30) := 'POLICY_VIOLATION_PROCESS'; -- policy

------------------------
-- Shortpay Notifs
------------------------
C_INFORM_PREPARER_SHORTPAY              CONSTANT VARCHAR2(30) := 'INFORM_PREPARER_SHORTPAY'; -- missing
C_POLICY_SHORTPAY_NOTICE                CONSTANT VARCHAR2(30) := 'POLICY_SHORTPAY_NOTICE'; -- policy

------------------------
-- Shortpay Notifs Results
------------------------
C_AP_WILL_SUBMIT                        CONSTANT VARCHAR2(30) := 'AP_WILL_SUBMIT'; -- missing
C_AP_PROVIDE_MISSING_INFO               CONSTANT VARCHAR2(30) := 'AP_PROVIDE MISSING_INFO'; -- policy

------------------------
-- Rules
------------------------
C_NOTIFY_RULE   CONSTANT ap_aud_rule_sets.rule_set_type%type := 'NOTIFY';

C_RECEIPT_RULE	CONSTANT ap_aud_rule_sets.rule_set_type%type := 'RECEIPT';

------------------------
-- Expense Report Sources
------------------------
C_SELF_SERVICE_SOURCE   CONSTANT ap_expense_report_headers.source%type := 'SelfService';
C_BOTHPAY               CONSTANT ap_expense_report_headers.source%type := 'Both Pay';

------------------------
-- Expense Report Statuses
------------------------
C_INVOICED              CONSTANT ap_expense_report_headers.expense_status_code%type := 'INVOICED';
C_PENDING_HOLDS         CONSTANT ap_expense_report_headers.expense_status_code%type := 'PEND_HOLDS_CLEARANCE';
C_PAYMENT_HELD          CONSTANT ap_expense_report_headers.expense_status_code%type := 'HOLD_PENDING_RECEIPTS';

------------------------
-- Lookup: RECEIPTS STATUS
------------------------
C_NOT_REQUIRED          CONSTANT VARCHAR2(30) := 'NOT_REQUIRED';
C_REQUIRED              CONSTANT VARCHAR2(30) := 'REQUIRED';
C_RECEIVED              CONSTANT VARCHAR2(30) := 'RECEIVED';
C_RECEIVED_RESUBMITTED  CONSTANT VARCHAR2(30) := 'RECEIVED_RESUBMITTED';
C_MISSING               CONSTANT VARCHAR2(30) := 'MISSING';
C_WAIVED                CONSTANT VARCHAR2(30) := 'WAIVED';
C_OVERDUE               CONSTANT VARCHAR2(30) := 'OVERDUE';
C_IN_TRANSIT            CONSTANT VARCHAR2(30) := 'IN_TRANSIT';
C_RESOLUTN              CONSTANT VARCHAR2(30) := 'RESOLUTN';

------------------------
-- Lookup: OIE_NOTIFY_RCT_RECEIVED
------------------------
C_NEVER                 CONSTANT VARCHAR2(30) := 'NEVER';
C_RECEIPTS_OVERDUE      CONSTANT VARCHAR2(30) := 'RECEIPTS_OVERDUE';
C_RECEIPTS_RECEIVED     CONSTANT VARCHAR2(30) := 'RECEIPTS_RECEIVED';


------------------------------------------------------------------------
FUNCTION IsNotifRuleSetup(      p_org_id                      IN NUMBER,
                                p_report_submitted_date       IN DATE) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsNotifRuleSetup(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE RaiseOverdueEvent(
                                 p_expense_report_id    IN NUMBER);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE RaiseMissingEvent(
                                 p_expense_report_id    IN NUMBER);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE RaiseReceivedEvent(
                                 p_expense_report_id    IN NUMBER);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE RaiseAbortedEvent(
                                 p_expense_report_id    IN NUMBER);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE RaiseAbortedEvent(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE InitOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE InitMissing(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckOverdueExists(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckMissingExists(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE AbortOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE AbortMissing(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE AbortProcess(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_event_key    IN VARCHAR2);
------------------------------------------------------------------------


------------------------------------------------------------------------
PROCEDURE InitReceived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE InitAborted(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION GetReceiptsStatus(
                                 p_report_header_id    IN NUMBER) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE GetReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE SetReceiptsStatus(
                                 p_report_header_id    IN NUMBER,
                                 p_receipts_status     IN VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetDaysOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetDaysOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckMissingDeclRequired(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckNotifyReceived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsReceivedWaived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsMissingShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsPolicyShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CompleteMissingShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CompletePolicyShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE StoreNote(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CallbackFunction(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE TrackOverdue(
                                errbuf out nocopy varchar2,
                                retcode out nocopy number,
                                p_org_id in number) ;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckReceiptType(      p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION GetImageReceiptsStatus(
                                 p_report_header_id    IN NUMBER) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetImageReceiptsStatus(
                                 p_report_header_id    IN NUMBER,
                                 p_receipts_status     IN VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckNotifyImageReceived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetImageReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE GetImageReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetImageOverdueDays(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE SetImageOverdueDays(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE UpdateOriginalInTransit(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE RaiseMissingEvent(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE AcceptMissingReceiptDecl(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE InitOriginalRecptTrack(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE Check_Both_Required(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CheckRecvdRecptType(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

END AP_WEB_RECEIPTS_WF;

/
