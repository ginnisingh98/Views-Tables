--------------------------------------------------------
--  DDL for Package EAM_METERREADING_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METERREADING_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVMTUS.pls 120.2 2006/06/07 13:30:55 yjhabak noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMTUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_METERREADING_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Perform_Writes
(
	p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_meter_reading_rec_type                                                       , x_return_status                 OUT NOCOPY  VARCHAR2
     ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE INSERT_ROW
(
	  p_eam_meter_reading_tbl  IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
   	 , p_eam_counter_prop_tbl  IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , x_eam_meter_reading_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_eam_counter_prop_tbl  OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE UPDATE_LAST_SERVICE_READING
(
	  p_eam_meter_reading_tbl  IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
   	 , x_eam_meter_reading_tbl OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);


PROCEDURE ENABLE_SOURCE_METER
(
	   p_eam_wo_comp_mr_read_tbl  IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
   	 , x_eam_wo_comp_mr_read_tbl  OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	 , x_return_status            OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl          OUT NOCOPY   EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

/* Bug # 5255459 : Added new parameter p_wip_entity_id */
PROCEDURE DISABLE_COUNTER_HIERARCHY
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , p_subinventory_id	       IN VARCHAR2
       , p_wip_entity_id               IN NUMBER := NULL
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_return_status               OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl              OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE UPDATE_ACTIVITY
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_return_status	       OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl              OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE UPDATE_GENEALOGY
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_return_status	       OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl	       OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE UPDATE_REBUILD_WORK_ORDER
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_return_status	       OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl	       OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

END EAM_METERREADING_UTILITY_PVT;

 

/
