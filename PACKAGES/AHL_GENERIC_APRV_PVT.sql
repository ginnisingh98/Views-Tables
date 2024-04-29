--------------------------------------------------------
--  DDL for Package AHL_GENERIC_APRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_GENERIC_APRV_PVT" AUTHID CURRENT_USER as
/* $Header: AHLVGWFS.pls 115.3 2003/09/26 07:46:36 rroy noship $ */

Type ObjRecTyp is RECORD
   ( name                 VARCHAR2(240),
     operating_unit_id    NUMBER,
     object_type          VARCHAR2(30),
     priority             VARCHAR2(30),
     start_date           DATE,
     end_date             DATE,
     description          VARCHAR2(4000),
     owner_id             NUMBER,
     priority_desc        VARCHAR2(80),
     application_usg_code VARCHAR2(30)
     );
--======================================================================
-- PROCEDURE
--    Start_WF_Process
--
-- PURPOSE
--    Start Workflow Process
--
--======================================================================

PROCEDURE Start_WF_Process
           (p_object                 IN   VARCHAR2,
            p_activity_id            IN   NUMBER,
            p_approval_type          IN   VARCHAR2,
	    p_object_version_number  IN   NUMBER,
            p_orig_status_code       IN   VARCHAR2,
            p_new_status_code        IN   VARCHAR2,
            p_reject_status_code     IN   VARCHAR2,
            p_requester_userid       IN   NUMBER,
            p_notes_from_requester   IN   VARCHAR2,
            p_workflowprocess        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
            p_application_usg_code   IN   VARCHAR2   DEFAULT 'AHL'
           );
/*****************************************************************
-- Wrapper APIs
*****************************************************************/


PROCEDURE Set_Activity_Details(itemtype     IN  VARCHAR2,
                               itemkey      IN  VARCHAR2,
            		       actid    IN  NUMBER,
                               funcmode IN  VARCHAR2,
			       resultout   OUT NOCOPY VARCHAR2);

PROCEDURE Prepare_Doc( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in  number,
                       funcmode        in  varchar2,
                       resultout       out nocopy varchar2 );

PROCEDURE Set_Approver_Details( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       out nocopy varchar2 );

PROCEDURE Set_Further_Approval( itemtype        in  varchar2,
                                 itemkey         in  varchar2,
                                 actid           in  number,
                                 funcmode        in  varchar2,
                                 resultout       out nocopy varchar2 );


PROCEDURE Ntf_Approval(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Ntf_Error_Act(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Ntf_Approval_Reminder(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Ntf_Forward_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Ntf_Approved_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Ntf_Rejected_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Ntf_Final_Approval_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in out nocopy  varchar2,
                document_type			in out nocopy varchar2    );

PROCEDURE Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       out nocopy varchar2    );

PROCEDURE Revert_Status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       out nocopy varchar2    );


/*****************************************************************
-- Helper APIs
*****************************************************************/
PROCEDURE Rejected_Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       out nocopy varchar2    );

PROCEDURE Approved_Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       out nocopy varchar2    );

PROCEDURE Get_Approval_Details
  ( p_object               IN   VARCHAR2,
    p_approval_type        IN   VARCHAR2 DEFAULT  'CONCEPT',
    p_object_details       IN  ObjRecTyp,
    x_approval_rule_id     OUT NOCOPY  NUMBER,
    x_approver_seq         OUT NOCOPY  NUMBER,
    x_return_status        OUT NOCOPY  VARCHAR2);

PROCEDURE Get_Approver_Info
  ( p_rule_id              IN  NUMBER,
    p_current_seq          IN   NUMBER,
    x_approver_id          OUT NOCOPY  VARCHAR2,
    x_approver_type        OUT NOCOPY  VARCHAR2,
    x_object_approver_id   OUT NOCOPY  VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2);

PROCEDURE Get_Api_Name( p_api_used_by         in  varchar2,
                        p_object              in  varchar2,
                        p_activity_type       in  VARCHAR2,
     			p_approval_type       in  VARCHAR2,
                        x_pkg_name        out nocopy  varchar2,
                        x_proc_name       out nocopy varchar2,
		        x_return_status   out nocopy varchar2);
PROCEDURE Handle_Error
   (p_itemtype                 IN VARCHAR2    ,
    p_itemkey                  IN VARCHAR2    ,
    p_msg_count                IN NUMBER      , -- Number of error Messages
    p_msg_data                 IN VARCHAR2    ,
    p_attr_name                IN VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
   );
END ahl_generic_aprv_pvt;


 

/
