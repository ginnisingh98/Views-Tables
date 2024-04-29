--------------------------------------------------------
--  DDL for Package EAM_CREATEUPDATE_WO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CREATEUPDATE_WO_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVCUWS.pls 120.2.12010000.2 2010/03/19 12:47:34 vboddapa ship $ */


/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVCUWS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_CREATEUPDATE_WO_PVT
--
--  NOTES
--
--  HISTORY
***************************************************************************/

/*******************************
Procedure to create a workorder from
another workorder.This procedure calls workorder API to copy the workorder
*******************************/
PROCEDURE  COPY_WORKORDER
  (
           p_init_msg_list                 IN VARCHAR2
         , p_commit                        IN VARCHAR2
         , p_wip_entity_id              IN NUMBER
         , p_organization_id         IN NUMBER
         , x_return_status                 OUT NOCOPY  VARCHAR2
	 , x_wip_entity_name           OUT NOCOPY  VARCHAR2
	 ,x_wip_entity_id                    OUT NOCOPY NUMBER
  );

/*********************************************************
Wrapper procedure on top of WO API.This is used to create/update workorder and its related entities
************************************************/
PROCEDURE CREATE_UPDATE_WO
(
      p_commit                      IN    VARCHAR2      := FND_API.G_FALSE,
      p_eam_wo_tbl		IN			EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
      p_eam_wo_relations_tbl     IN            EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
      p_eam_op_tbl               IN                    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
      p_eam_res_tbl              IN                   EAM_PROCESS_WO_PUB.eam_res_tbl_type,
      p_eam_res_inst_tbl     IN			EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type,
      p_eam_res_usage_tbl      IN              EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_eam_mat_req_tbl         IN                EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type,
      p_eam_direct_items_tbl    IN             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type,
      p_eam_request_tbl           IN              EAM_PROCESS_WO_PUB.eam_request_tbl_type,
      p_eam_wo_comp_tbl		 IN		EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type,
      p_eam_meter_reading_tbl   IN		EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type,
      p_eam_counter_prop_tbl    IN	 EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type,
      p_eam_wo_comp_rebuild_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type,
      p_eam_wo_comp_mr_read_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type,
      p_prev_activity_id              IN                NUMBER,
      p_failure_id          IN NUMBER			:= null,
      p_failure_date        IN DATE				:= null,
      p_failure_entry_id    IN NUMBER		 := null,
      p_failure_code        IN VARCHAR2		 := null,
      p_cause_code          IN VARCHAR2		 := null,
      p_resolution_code     IN VARCHAR2		 := null,
      p_failure_comments    IN VARCHAR2		:= null,
      p_failure_code_required     IN VARCHAR2 DEFAULT NULL,
      x_wip_entity_id              OUT NOCOPY       NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count			OUT NOCOPY	NUMBER
);

/*********************************************************
Wrapper procedure on top of WO API.Overloaded procedure of CREATE_UPDATE_WO for safety
This is used to create/update workorder and its related entities
************************************************/
PROCEDURE CREATE_UPDATE_WO
(
      p_commit                      IN    VARCHAR2      := FND_API.G_FALSE,
      p_eam_wo_tbl		IN			EAM_PROCESS_WO_PUB.eam_wo_tbl_type,
      p_eam_wo_relations_tbl     IN            EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type,
      p_eam_op_tbl               IN                    EAM_PROCESS_WO_PUB.eam_op_tbl_type,
      p_eam_res_tbl              IN                   EAM_PROCESS_WO_PUB.eam_res_tbl_type,
      p_eam_res_inst_tbl     IN			EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type,
      p_eam_res_usage_tbl      IN              EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_eam_mat_req_tbl         IN                EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type,
      p_eam_direct_items_tbl    IN             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type,
      p_eam_request_tbl           IN              EAM_PROCESS_WO_PUB.eam_request_tbl_type,
      p_eam_wo_comp_tbl		 IN		EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type,
      p_eam_meter_reading_tbl   IN		EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type,
      p_eam_counter_prop_tbl    IN	 EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type,
      p_eam_wo_comp_rebuild_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type,
      p_eam_wo_comp_mr_read_tbl	 IN	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type,
      p_eam_permit_tbl               IN  EAM_PROCESS_PERMIT_PUB.eam_wp_tbl_type, -- new param for safety permit
      p_eam_permit_wo_assoc_tbl IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type, -- new param for safety permit
      p_prev_activity_id              IN                NUMBER,
      p_failure_id          IN NUMBER			:= null,
      p_failure_date        IN DATE				:= null,
      p_failure_entry_id    IN NUMBER		 := null,
      p_failure_code        IN VARCHAR2		 := null,
      p_cause_code          IN VARCHAR2		 := null,
      p_resolution_code     IN VARCHAR2		 := null,
      p_failure_comments    IN VARCHAR2		:= null,
      p_failure_code_required     IN VARCHAR2 DEFAULT NULL,
      x_wip_entity_id              OUT NOCOPY       NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count			OUT NOCOPY	NUMBER
);

/********************************************************
Procedure to find the required,assigned and unassigned hours at workorder level
*********************************************************/
PROCEDURE ASSIGNED_HOURS
(
      p_wip_entity_id    IN NUMBER,
      x_required_hours   OUT NOCOPY NUMBER,
      x_assigned_hours   OUT NOCOPY NUMBER,
      x_unassigned_hours OUT NOCOPY NUMBER
);

END EAM_CREATEUPDATE_WO_PVT;

/
