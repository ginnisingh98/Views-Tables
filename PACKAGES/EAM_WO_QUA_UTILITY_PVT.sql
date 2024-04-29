--------------------------------------------------------
--  DDL for Package EAM_WO_QUA_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_QUA_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWQUS.pls 120.1 2005/08/25 08:38:43 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWQUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_QUA_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

/*
* The procedure is getting called when user passes quality records
* during work order completion and operation completion
* The procedure does the actual data base operations depending on the record passed
*/

PROCEDURE Perform_Writes
(
	p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type,
	x_return_status           OUT NOCOPY  VARCHAR2,
	x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

/*
* The procedure is getting called when user passes quality records
* during work order completion and operation completion
* The procedure enters the data into quality table QA_RESULTS
*/

PROCEDURE insert_row
(
	  p_collection_id	   IN NUMBER
	, p_eam_wo_quality_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_eam_wo_quality_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_return_status          OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 );

END EAM_WO_QUA_UTILITY_PVT;

 

/
