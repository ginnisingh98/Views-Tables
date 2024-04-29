--------------------------------------------------------
--  DDL for Package AMW_GEN_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_GEN_APPROVAL_PVT" AUTHID CURRENT_USER as
/* $Header: amwvgaps.pls 115.3 2003/06/30 22:17:48 kmuthusw noship $ */
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow for the Approval Process
--
--
-- IN
--  p_approval_for          IN   Approval for Object (i.e. CAMP/EVEH,...)
--  p_approval_for_id           IN   Approval for Objectid (i.e. CAMP_id,...)
--  p_object_version_number IN   Object Version Number
--  p_orig_stat_id          IN   Original User Status Id(e.g. id for 'NEW')
--  p_new_stat_id           IN   New User Status Id(e.g. id for 'AVAILABLE')
--  p_requestor_userid      IN   Userid
--  p_workflow_process       IN   WF Process Name (Default Null)
--  p_item_type             IN   WF Item type(Default Null)
-- OUT
--
-- Used By Activities
--
-- NOTES
-- HISTORY
--	06/30/2003	KARTHI MUTHUSWAMY	Changed p_workflowprocess to p_workflow_process
-- End of Comments
PROCEDURE StartProcess
           (p_object_type          IN   VARCHAR2,
            p_object_id            IN   NUMBER,
            p_approval_type          IN   VARCHAR2 DEFAULT NULL,
            p_object_version_number  IN   NUMBER,
            p_requestor_userid       IN   NUMBER,
            p_workflow_process        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
            p_gen_process_flag       IN   VARCHAR2   DEFAULT NULL,
            x_return_status out nocopy varchar2,
            x_msg_count out nocopy number,
            x_msg_data out nocopy varchar2
             );
PROCEDURE Set_object_Details(itemtype    IN  VARCHAR2,
                               itemkey     IN  VARCHAR2,
                               actid       IN  NUMBER,
                               funcmode    IN  VARCHAR2,
                              resultout   OUT NOCOPY VARCHAR2);
PROCEDURE Revert_Status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2);
PROCEDURE Set_Approver_Details( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       OUT NOCOPY varchar2 );
/*****************************************************************
-- Start of Comments
--
-- NAME
--   AbortProcess
--
-- PURPOSE
--   This Procedure will abort the process of Approvals
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
-- End of Comments
*****************************************************************/
PROCEDURE AbortProcess
                  (p_itemkey           IN  VARCHAR2
                  ,p_workflow_process   IN  VARCHAR2        DEFAULT NULL
                  ,p_itemtype          IN  VARCHAR2        DEFAULT NULL
                  );
PROCEDURE Get_Api_Name( p_rule_used_by       in  varchar2,
                        p_rule_used_by_type  in  varchar2,
                        p_rule_type          in  VARCHAR2,
                     p_appr_type          in  VARCHAR2,
                        x_pkg_name           OUT NOCOPY varchar2,
                        x_proc_name          OUT NOCOPY varchar2,
                     x_return_stat        OUT NOCOPY varchar2);
PROCEDURE Ntf_Approval(document_id   in      varchar2,
                       display_type  in      varchar2,
                       document      in OUT NOCOPY  varchar2,
                       document_type in OUT NOCOPY  varchar2);
PROCEDURE Ntf_Approval_reminder(document_id   in      varchar2,
                                display_type  in      varchar2,
                                document      in OUT NOCOPY  varchar2,
                                document_type in OUT NOCOPY  varchar2);
PROCEDURE Ntf_Forward_FYI( document_id   in      varchar2,
                           display_type  in      varchar2,
                           document      in OUT NOCOPY  varchar2,
                           document_type in OUT NOCOPY  varchar2);
PROCEDURE Ntf_Approved_FYI(document_id   in      varchar2,
                           display_type  in      varchar2,
                           document      in OUT NOCOPY  varchar2,
                           document_type in OUT NOCOPY  varchar2);
PROCEDURE Ntf_Rejected_FYI(document_id   in      varchar2,
                           display_type  in      varchar2,
                           document      in OUT NOCOPY  varchar2,
                           document_type in OUT NOCOPY  varchar2);
PROCEDURE Ntf_Requestor_Of_Error(document_id   in      varchar2,
                                 display_type  in      varchar2,
                                 document      in OUT NOCOPY  varchar2,
                                 document_type in OUT NOCOPY  varchar2);
PROCEDURE Update_Status(itemtype  IN  varchar2,
                        itemkey   IN  varchar2,
                        actid     in  number,
                        funcmode  in  varchar2,
                        resultout OUT NOCOPY varchar2);
PROCEDURE Reject_Update_Status(itemtype  IN  varchar2,
                               itemkey   IN  varchar2,
                               actid     in  number,
                               funcmode  in  varchar2,
                               resultout OUT NOCOPY varchar2);
PROCEDURE Approved_Update_Status(itemtype  IN  varchar2,
                                 itemkey   IN  varchar2,
                                 actid     in  number,
                                 funcmode  in  varchar2,
                                 resultout OUT NOCOPY varchar2    );
PROCEDURE Handle_Err
   (p_itemtype                 IN VARCHAR2    ,
    p_itemkey                  IN VARCHAR2    ,
    p_msg_count                IN NUMBER      , -- Number of error Messages
    p_msg_data                 IN VARCHAR2    ,
    p_attr_name                IN VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
   );
PROCEDURE Approval_Required(itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2);
END amw_gen_approval_pvt;

 

/
