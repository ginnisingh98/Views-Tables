--------------------------------------------------------
--  DDL for Package EAM_SCHED_BOTTOM_UP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SCHED_BOTTOM_UP_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVSBUS.pls 120.1.12010000.2 2008/10/17 07:55:09 smrsharm ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSBUS.pls
--
--  DESCRIPTION
--
--      Specification of package EAM_SCHED_BOTTOM_UP_PVT
--
--  NOTES
--
--  HISTORY
--
--  3/8/2005 Prashant Kathotia Initial Creation
***************************************************************************/

	procedure schedule_bottom_up_pvt (
			   p_api_version_number      IN  NUMBER
			 , p_commit                  IN  VARCHAR2
			 , p_wip_entity_id           IN  NUMBER
			 , p_org_id                  IN  NUMBER
			 , p_woru_modified           IN  VARCHAR2
			 , x_return_status           OUT NOCOPY VARCHAR2
			 , x_message_name	         OUT NOCOPY VARCHAR2
			 ) ;

  procedure update_resource_usage(
            p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_res_usage_tbl    IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	 , x_eam_res_tbl		OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
	 , x_eam_res_usage_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
	 , x_message_name	   OUT NOCOPY VARCHAR2
	) ;


END EAM_SCHED_BOTTOM_UP_PVT;

/
