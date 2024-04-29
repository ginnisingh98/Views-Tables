--------------------------------------------------------
--  DDL for Package EAM_WORKORDER_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDER_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWWFS.pls 120.0 2005/06/08 02:51:58 appldev noship $*/

/*Procedure called from Work Order Release Approval when the workflow is approved*/
PROCEDURE Update_Status_Approved( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2);


/*  Procedure called from Work Order Release Approval when the workflow is Rejected
*/
PROCEDURE Update_Status_Rejected( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2);


/*  Procedure called from Work Order Release Approval to find the next approver
*/
procedure Get_Next_Approver(itemtype  in varchar2,
      itemkey         in varchar2,
      actid           in number,
      funcmode        in varchar2,
      resultout       out NOCOPY varchar2);


 /*  Procedure called from Work Order Release Approval when an approver responds to a notification
*/
procedure Update_AME_With_Response(itemtype  in varchar2,
itemkey         in varchar2,
actid           in number,
funcmode        in varchar2,
resultout       out NOCOPY varchar2);


/*  Function called from subscription .This will in turn laucnh the workflow
*/
function Launch_Workflow
(p_subscription_guid in raw,
p_event in out NOCOPY wf_event_t) return varchar2;


/*  Procedure called from the public package 'EAM_WORKFLOW_DETAILS_PUB'
    This procedure will launch the seeded workflow when status is changed to Released
*/
PROCEDURE Is_Approval_Required_Released
(
p_old_wo_rec IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
p_new_wo_rec IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
   x_approval_required    OUT NOCOPY   BOOLEAN,
   x_workflow_name        OUT NOCOPY    VARCHAR2,
   x_workflow_process    OUT NOCOPY    VARCHAR2
);

END EAM_WORKORDER_WORKFLOW_PVT ;

 

/
