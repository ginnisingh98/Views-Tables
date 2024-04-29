--------------------------------------------------------
--  DDL for Package EAM_WORKPERMIT_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKPERMIT_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWPWS.pls 120.0.12010000.1 2010/03/19 01:38:49 mashah noship $ */

/***************************************************************************
--
--  Copyright (c) 2009 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME: EAMVWPWS.pls
--
--  DESCRIPTION: Spec of package EAM_WORKPERMIT_WORKFLOW_PVT
--
--  NOTES
--
--  HISTORY
--
--  18-FEB-2010   Madhuri Shah     Initial Creation
***************************************************************************/

/********************************************************************
* Procedure     : Launch_Workflow
* Purpose       : Function called from subscription .This will in turn launch the workflow
*********************************************************************/
function Launch_Workflow
                  ( p_subscription_guid in raw
                  , p_event in out NOCOPY wf_event_t
                  ) return varchar2;



 /********************************************************************
* Procedure     : Update_Status_Approved
* Purpose       : Procedure called from Work Permit Release Approval when the workflow is approved
*********************************************************************/
PROCEDURE Update_Status_Approved
                  ( itemtype  in varchar2
                    , itemkey   in varchar2
                    , actid     in number
                    , funcmode  in varchar2
                    , resultout out NOCOPY varchar2
                  );



/********************************************************************
* Procedure     : Update_Status_Rejected
* Purpose       : Procedure called from Work Permit Release Approval when the workflow is Rejected
*********************************************************************/
PROCEDURE Update_Status_Rejected
                      ( itemtype  in varchar2
                      ,	itemkey   in varchar2
                      , actid     in number
                      , funcmode  in varchar2
                      , resultout out NOCOPY varchar2
                      );



/********************************************************************
* Procedure     : Get_Next_Approver
* Purpose       : Procedure called from Work Permit Release Approval to
                  find the next approver
*********************************************************************/
procedure Get_Next_Approver
                        ( itemtype          in varchar2
                         , itemkey         in varchar2
                         , actid           in number
                         , funcmode        in varchar2
                         , resultout       out NOCOPY varchar2
                        ) ;



/********************************************************************
* Procedure     : Update_AME_With_Response
* Purpose       : Procedure called from Permit Release Approval when an approver
                  responds to a notification
*********************************************************************/
procedure  Update_AME_With_Response
                          (itemtype         in varchar2
                          , itemkey         in varchar2
                          , actid           in number
                          , funcmode        in varchar2
                          , resultout       out NOCOPY varchar2);



/********************************************************************
* Procedure     : Is_Approval_Required_Released
* Purpose       : This procedure will check if the approval is required for
                  the work permit release
*********************************************************************/
PROCEDURE Is_Approval_Required_Released
                        (  p_old_wp_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                          , p_new_wp_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                          , x_approval_required    OUT NOCOPY   BOOLEAN
                          , x_workflow_name        OUT NOCOPY    VARCHAR2
                          , x_workflow_process    OUT NOCOPY    VARCHAR2
                        );


END EAM_WORKPERMIT_WORKFLOW_PVT;



/
