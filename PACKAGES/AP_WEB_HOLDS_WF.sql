--------------------------------------------------------
--  DDL for Package AP_WEB_HOLDS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_HOLDS_WF" AUTHID CURRENT_USER AS
/* $Header: apwholdss.pls 120.1 2005/10/02 20:15:38 albowicz noship $ */


------------------------
-- Item Types
------------------------
C_APWHOLDS      CONSTANT VARCHAR2(8) := 'APWHOLDS';

------------------------
-- Rules
------------------------
C_HOLD_RULE     CONSTANT ap_aud_rule_sets.rule_set_type%type := 'HOLD';

------------------------
-- Hold Codes
------------------------
C_HOLD_EACH_CODE        CONSTANT ap_aud_rule_sets.hold_code%type := 'UNTIL_RCT_RECEIVED';
C_HOLD_EACH             CONSTANT ap_aud_rule_sets.hold_code%type := 'EACH';
C_HOLD_ALL_CODE         CONSTANT ap_aud_rule_sets.hold_code%type := 'RECEIPTS_OVERDUE';
C_HOLD_ALL              CONSTANT ap_aud_rule_sets.hold_code%type := 'ALL';

------------------------
-- Both Pay Hold Codes
------------------------
C_HOLD_BP_NEVER              CONSTANT ap_aud_rule_sets.hold_rct_overdue_bp_cc_code%type := 'NEVER';
C_HOLD_BP_REQUIRED           CONSTANT ap_aud_rule_sets.hold_rct_overdue_bp_cc_code%type := 'RECEIPTS_REQUIRED';
C_HOLD_BP_ALWAYS             CONSTANT ap_aud_rule_sets.hold_rct_overdue_bp_cc_code%type := 'ALWAYS';

------------------------------------------------------------------------
FUNCTION IsHoldsRuleSetup(
                                 p_org_id                IN NUMBER,
                                 p_report_submitted_date IN DATE) RETURN VARCHAR2;
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsHoldsRuleSetup(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE RaiseHeldEvent(
                                 p_expense_report_id    IN NUMBER);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE RaiseReleasedEvent(
                                 p_expense_report_id    IN NUMBER);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE RaiseReleasedEvent(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE InitHeld(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE InitReleased(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE AnyHoldsPending(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE GetHoldsScenario(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE ReleaseHold(
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
PROCEDURE ExpenseHolds;
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE HoldEach;
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE HoldAll;
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE HoldBothPay;
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE ObsoleteHold;
------------------------------------------------------------------------

PROCEDURE ReadyForPayment(p_report_header_id IN NUMBER);

END AP_WEB_HOLDS_WF;

 

/
