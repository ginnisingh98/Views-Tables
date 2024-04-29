--------------------------------------------------------
--  DDL for Package EAM_WO_QUA_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_QUA_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWQVS.pls 120.1 2005/08/25 08:39:27 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWQVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_QUA_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

/*
* The procedure checks if all the required parameters are passed or not in the Quality Record
* The procedure is getting called when user passes quality records
* during work order completion and operation completion
*/

 PROCEDURE Check_Required
 (
	p_eam_wo_quality_rec    IN  EAM_PROCESS_WO_PUB.eam_wo_quality_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  );


END EAM_WO_QUA_VALIDATE_PVT;

 

/
