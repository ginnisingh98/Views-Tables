--------------------------------------------------------
--  DDL for Package Body EAM_REQUEST_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REQUEST_UTILITY_PVT" AS
/* $Header: EAMVRQUB.pls 120.0 2005/06/08 02:50:25 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRQUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_REQUEST_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/
PROCEDURE INSERT_ROW
(  p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
   , x_return_status           OUT NOCOPY  VARCHAR2
   , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 )
IS
BEGIN

	IF p_eam_request_rec.request_type = 1 THEN
	  UPDATE WIP_EAM_WORK_REQUESTS
	     SET
		 wip_entity_id            = p_eam_request_rec.wip_entity_id,
		 work_request_status_id   = 4,
		 last_update_date         = sysdate,
		 last_updated_by          = FND_GLOBAL.user_id,
		 last_update_login        = fnd_global.login_id
	   WHERE work_request_id	  = p_eam_request_rec.request_id
	     AND organization_id	  = p_eam_request_rec.organization_id;

	END IF;

	IF p_eam_request_rec.request_type = 2 THEN

		INSERT INTO EAM_WO_SERVICE_ASSOCIATION
		    (   wo_service_entity_assoc_id,
    			maintenance_organization_id,
		     	wip_entity_id,
     			service_request_id,
     			creation_date,
     			created_by,
     			last_update_login,
     			program_id,
     			attribute1,
     			attribute2,
     			attribute3,
     			attribute4,
     			attribute5,
     			attribute6,
     			attribute7,
     			attribute8,
     			attribute9,
     			attribute10,
     			attribute11,
     			attribute12,
     			attribute13,
     			attribute14,
     			attribute15,
     			attribute_category,
     			last_updated_by,
     			last_update_date,
			enable_flag)		-- Fix for 3773450
     		VALUES
     		    (   p_eam_request_rec.SERVICE_ASSOC_ID,
     			p_eam_request_rec.organization_id,
     			p_eam_request_rec.wip_entity_id,
     			p_eam_request_rec.request_id,
     			sysdate,
     			FND_GLOBAL.USER_ID,
     			FND_GLOBAL.LOGIN_ID,
     			null,--fnd_global.conc_program_id,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			null,
     			fnd_global.user_id,
     			sysdate,
			'Y');		-- Fix for 3773450
	END IF;

 END INSERT_ROW;

 PROCEDURE DELETE_ROW
  (  p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
     , x_return_status         OUT NOCOPY  VARCHAR2
     , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  )
  IS
  BEGIN

	IF p_eam_request_rec.request_type = 1 THEN

		UPDATE 	WIP_EAM_WORK_REQUESTS
		SET 	wip_entity_id		=	null,
			work_request_status_id  = 	3,
			last_update_date	=	sysdate,
			last_updated_by		= 	FND_GLOBAL.user_id
	      WHERE 	work_request_id		=	p_eam_request_rec.request_id
	        AND 	organization_id		=	p_eam_request_rec.organization_id;
	END IF;

	IF p_eam_request_rec.request_type = 2 THEN

	       UPDATE EAM_WO_SERVICE_ASSOCIATION			-- Fix for 3773450
		  SET enable_flag = 'N',
		      last_update_date		  = sysdate,
		      last_updated_by		  = FND_GLOBAL.user_id,
		      last_update_login		  = FND_GLOBAL.login_id
		WHERE service_request_id	  = p_eam_request_rec.request_id
		  AND wip_entity_id		  = p_eam_request_rec.wip_entity_id
		  AND maintenance_organization_id = p_eam_request_rec.organization_id
		  AND (enable_flag IS NULL or enable_flag = 'Y');

	END IF;


  END DELETE_ROW;


END EAM_REQUEST_UTILITY_PVT;

/
