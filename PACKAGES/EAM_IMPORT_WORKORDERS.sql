--------------------------------------------------------
--  DDL for Package EAM_IMPORT_WORKORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_IMPORT_WORKORDERS" AUTHID CURRENT_USER AS
/* $Header: EAMIMPWS.pls 120.2 2007/12/20 12:35:06 srkotika noship $ */

   /*********************************************************
    Wrapper procedure on top of WO API.This is used to update valid imported workorders and its related entities
    ************************************************/

   PROCEDURE import_workorders
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
      x_wip_entity_id              OUT NOCOPY       NUMBER,
      x_return_status		OUT NOCOPY	VARCHAR2,
      x_msg_count			OUT NOCOPY	NUMBER
    );

   END eam_import_workorders;

/
