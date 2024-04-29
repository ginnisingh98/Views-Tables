--------------------------------------------------------
--  DDL for Package EAM_METERREADING_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METERREADING_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVMTVS.pls 120.1.12010000.1 2008/07/24 11:50:50 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMTVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_METERREADING_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

TYPE counter_id_tbl_type is TABLE OF number INDEX BY BINARY_INTEGER;

PROCEDURE CHECK_REQUIRED (
	  p_eam_meter_reading_rec      IN EAM_PROCESS_WO_PUB.eam_meter_reading_rec_type
	, x_return_status              OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl             OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE MANDATORY_ENTERED (
	     p_wip_entity_id 		IN NUMBER
	   , p_instance_id		IN VARCHAR2
	   , p_eam_meter_reading_tbl  IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	   , p_work_order_cmpl_date   IN DATE
           , x_return_status            OUT NOCOPY  VARCHAR2
           , x_man_reading_enter        OUT NOCOPY BOOLEAN
);

END EAM_METERREADING_VALIDATE_PVT;

/
