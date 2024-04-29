--------------------------------------------------------
--  DDL for Package EAM_WORKFLOW_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKFLOW_DETAILS_PUB" AUTHID DEFINER AS
/* $Header: EAMPWFDS.pls 120.0 2005/06/08 02:54:57 appldev noship $*/


-- -----------------------------------------------------------------------------
--  				Public Globals
-- -----------------------------------------------------------------------------

G_FILE_NAME		CONSTANT  VARCHAR2(12)  :=  'EAMPWFDS.pls';

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
X_Workflow_Process OUT NOCOPY VARCHAR2);

END EAM_WORKFLOW_DETAILS_PUB;

 

/
