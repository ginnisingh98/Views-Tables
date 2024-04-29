--------------------------------------------------------
--  DDL for Package IA_WF_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IA_WF_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: IAWFREQS.pls 120.0 2005/06/03 23:59:23 appldev noship $   */

-- PROCEDURE Start_Process(p_request_id in number);
FUNCTION Start_Process(p_request_id in number) return NUMBER;

FUNCTION Abort_Process(p_request_id in number) return NUMBER;

PROCEDURE Get_Next_Approver
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Check_Approval_Type
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

/*
PROCEDURE Insert_Next_Approver
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);
*/

PROCEDURE Set_Role(p_role_name in varchar2);

/*
FUNCTION  Respond
         (p_request_id       in number
         ,p_result           in varchar2
         ,p_delegatee_id     in number
         ,p_comment          in varchar2) return NUMBER;
*/

/*
PROCEDURE Insert_Approval
         (p_request_id       in  number
         ,p_approver_id      in  number
         ,p_approval_status  in  varchar2
         ,p_approval_id      out nocopy number
         );
*/

/*
PROCEDURE Update_Approval_Status
         (p_approval_id      in number
         ,p_chain_phase      in varchar2
         ,p_approval_status  in varchar2
         );
*/

PROCEDURE Update_ApprovalStatus_To_Final
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Send_Response_Notification
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Process_Approved
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Process_Delegated
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Process_Rejected
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Process_Cancelled
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE SuperUser_Approval_Required
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Update_LineStatus_To_OnReview
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

PROCEDURE Update_LineStatus_To_Post
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2);

END IA_WF_REQUEST_PKG;

 

/
