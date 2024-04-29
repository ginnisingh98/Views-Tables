--------------------------------------------------------
--  DDL for Package POS_WCAPPROVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_WCAPPROVE_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVWCAS.pls 120.6.12010000.2 2009/05/20 12:21:06 vchiranj ship $ */
--
-- Purpose: APIs called from the receiving processor to approve WCR document.
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- pparthas    02/15/05 Created Package
--
--

/*
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POS_WCAPPROVE_PVT';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSVWCAS.pls';
*/

PROCEDURE Start_WF_Process ( p_itemtype   IN              VARCHAR2,
                             p_itemkey    IN OUT NOCOPY   VARCHAR2,
                             p_workflow_process IN        VARCHAR2,
                             p_work_confirmation_id IN    NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2);



-- Remove_reminder_notif
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
-- Update the old notifications to closed status for this document.
procedure Close_old_notif
(
p_itemtype        in varchar2,
p_itemkey         in varchar2,
p_actid           in number,
p_funcmode        in varchar2,
x_resultout       out NOCOPY varchar2 );

procedure Set_Startup_Values(   p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2    );

procedure update_workflow_info( p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2);

procedure Get_WC_Attributes( p_itemtype        in varchar2,
                             p_itemkey         in varchar2,
                             p_actid           in number,
                             p_funcmode        in varchar2,
                             x_resultout       out NOCOPY varchar2);


procedure Ins_actionhist_submit(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2);

procedure Get_Next_Approver(p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

procedure Insert_Action_History(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2);


procedure Approve_shipment_lines(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2);

procedure Reject_shipment_lines(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2);

procedure Approve_OR_Reject(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2);

procedure Update_Approval_List_Response
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);


procedure Update_Action_History_Approve
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

procedure Update_Action_History_Reject
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

procedure Update_Action_History
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_action_code     in  varchar2);

PROCEDURE UpdateActionHistory(p_more_info_id           IN NUMBER,
                              p_original_recipient_id  IN NUMBER,
                              p_responder_id           IN NUMBER,
			      p_last_approver          IN BOOLEAN,
                              p_action_code            IN VARCHAR2,
                              p_comments               IN VARCHAR2,
                              p_shipment_header_id     IN NUMBER);


PROCEDURE get_user_name(p_orig_system IN Varchar2,
			p_employee_id IN number,
                        x_username OUT NOCOPY varchar2,
                        x_user_display_name OUT NOCOPY varchar2);

PROCEDURE UpdatePOActionHistory (p_object_id            IN NUMBER,
                                 p_object_type_code     IN VARCHAR2,
                                 p_employee_id      IN NUMBER,
                                 p_action_code          IN VARCHAR2,
                                 p_note                 IN VARCHAR2,
                                 p_user_id              IN NUMBER,
                                 p_login_id             IN NUMBER);

PROCEDURE InsertPOActionHistory (p_object_id                    IN  NUMBER,
                                  p_object_type_code           IN  VARCHAR2,
                                   p_object_sub_type_code       IN  VARCHAR2,
                                   p_sequence_num               IN  NUMBER,
                                   p_action_code                IN  VARCHAR2,
                                   p_action_date                IN  DATE,
                                   p_employee_id                IN  NUMBER,
                                   p_approval_path_id           IN  NUMBER,
                                   p_note                       IN  VARCHAR2,
                                   p_object_revision_num        IN  NUMBER,
                                   p_offline_code               IN  VARCHAR2,
                                   p_request_id                 IN  NUMBER,
                                   p_program_application_id     IN  NUMBER,
                                   p_program_id                 IN  NUMBER,
                                   p_program_date               IN  DATE,
                                   p_user_id                    IN  NUMBER,
                                   p_login_id                   IN  NUMBER);

procedure reject_doc
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) ;

procedure Approve_doc
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) ;

procedure update_approval_status
                           (p_shipment_header_id    in number,
                            p_note         in varchar2,
                            p_approval_status in varchar2,
			    p_level           in varchar2,
                            x_resultout       out NOCOPY varchar2);

procedure insert_into_rti
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

procedure Launch_RTP_Immediate
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

PROCEDURE get_multiorg_context(p_document_id number,
                               x_orgid IN OUT NOCOPY number);


procedure post_approval_notif
                           (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2);

/* Bug 8479430.
   Added the procedure POWC_SELECTOR to set the user context properly before
   launching the concurrent request */
PROCEDURE POWC_SELECTOR ( p_itemtype   IN VARCHAR2,
                          p_itemkey    IN VARCHAR2,
                          p_actid      IN NUMBER,
                          p_funcmode   IN VARCHAR2,
                          p_x_result   IN OUT NOCOPY VARCHAR2);

FUNCTION Get_Approver_Name(p_approver_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_PoHeaderId(p_shipment_header_id IN NUMBER)
RETURN NUMBER;

   PROCEDURE GenReceiptNum(
        p_shipment_header_id IN number,
        x_receipt_num IN OUT nocopy Varchar2);


FUNCTION GET_PAY_ITEM_PROGRESS (p_wc_id       IN NUMBER,
                                p_wc_stage    IN VARCHAR2)
RETURN NUMBER;

FUNCTION GET_AWARD_NUM (p_wc_id       IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_DELIVER_TO_LOCATION (p_wc_id       IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_ORDERED_AMOUNT (p_wc_id       IN NUMBER)
RETURN NUMBER;

FUNCTION GET_ORDERED_QUANTITY (p_wc_id       IN NUMBER)
RETURN NUMBER;

FUNCTION GET_PROJECT_NAME (p_wc_id       IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_TASK_NAME (p_wc_id       IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_CHARGE_ACCOUNT (p_wc_id       IN NUMBER)
RETURN VARCHAR2;

FUNCTION GET_EXPENDITURE_ORG (p_wc_id       IN NUMBER)
RETURN VARCHAR2;

END POS_WCAPPROVE_PVT;

/
