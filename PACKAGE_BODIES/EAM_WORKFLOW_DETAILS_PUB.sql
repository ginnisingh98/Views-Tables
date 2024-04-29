--------------------------------------------------------
--  DDL for Package Body EAM_WORKFLOW_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKFLOW_DETAILS_PUB" AS
/* $Header: EAMPWFDB.pls 120.0 2005/06/08 02:53:13 appldev noship $*/

-- -----------------------------------------------------------------------------
--  				Private Globals
-- -----------------------------------------------------------------------------
  g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_WORKFLOW_DETAILS_PUB';


/*   Customers can customise this procedure to launch workflow for any status change
*/
PROCEDURE Eam_Wf_Is_Approval_Required
( p_old_wo_rec                IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
p_new_wo_rec                IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
p_wip_entity_id                IN NUMBER,
p_new_system_status   IN  NUMBER,
p_new_wo_status           IN   NUMBER,
p_old_system_status     IN    NUMBER,
p_old_wo_status             IN    NUMBER,
X_Approval_Required OUT NOCOPY BOOLEAN,
X_Workflow_Name OUT NOCOPY VARCHAR2,
X_Workflow_Process OUT NOCOPY VARCHAR2)
IS
BEGIN
	         EAM_WORKORDER_WORKFLOW_PVT.IS_APPROVAL_REQUIRED_RELEASED
		     (
		         p_old_wo_rec            =>             p_old_wo_rec,
			 p_new_wo_rec          =>          p_new_wo_rec,
		          X_Approval_Required  =>   X_Approval_Required,
			  X_Workflow_Name      =>    X_Workflow_Name,
			  X_Workflow_Process      =>   X_Workflow_Process
		     );

      /*Customers can add custom code here*/

END Eam_Wf_Is_Approval_Required;

END EAM_WORKFLOW_DETAILS_PUB;

/
