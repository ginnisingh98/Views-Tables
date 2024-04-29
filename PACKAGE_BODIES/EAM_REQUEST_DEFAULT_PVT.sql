--------------------------------------------------------
--  DDL for Package Body EAM_REQUEST_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REQUEST_DEFAULT_PVT" AS
/* $Header: EAMVRQDB.pls 120.1 2005/12/15 04:00:57 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRQDB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_REQUEST_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

 PROCEDURE Attribute_Defaulting
(     p_eam_request_rec               IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
    , x_eam_request_rec               OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_rec_type
    , x_return_status                 OUT NOCOPY  VARCHAR2
)
  IS
     l_eam_request_rec                  EAM_PROCESS_WO_PUB.eam_request_rec_type;
  BEGIN

     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request/Service Request processing Attribute Defaulting'); END IF;

	  x_eam_request_rec := p_eam_request_rec;
	  x_return_status   := FND_API.G_RET_STS_SUCCESS;

	  IF p_eam_request_rec.organization_code IS NOT NULL AND
		(p_eam_request_rec.organization_id IS NULL OR p_eam_request_rec.organization_id = FND_API.G_MISS_NUM) THEN

		SELECT organization_id
		  INTO x_eam_request_rec.organization_id
		  FROM MTL_PARAMETERS mp
                 WHERE mp.organization_code = p_eam_request_rec.organization_code;

	  END IF;

	  IF p_eam_request_rec.wip_entity_name IS NOT NULL AND
	     (p_eam_request_rec.wip_entity_id IS NULL OR p_eam_request_rec.wip_entity_id = FND_API.G_MISS_NUM) THEN

		SELECT wip_entity_id into x_eam_request_rec.wip_entity_id
		  FROM WIP_ENTITIES we
		 WHERE we.organization_id = x_eam_request_rec.organization_id
		   AND we.wip_entity_name = p_eam_request_rec.wip_entity_name;
	 END IF;

	 IF p_eam_request_rec.request_number IS NOT NULL AND
	     (p_eam_request_rec.request_id IS NULL OR p_eam_request_rec.request_id = FND_API.G_MISS_NUM) THEN

	     IF p_eam_request_rec.request_type = 1 THEN
			x_eam_request_rec.request_id := p_eam_request_rec.request_number;
	     ELSE
			SELECT incident_id
			  INTO x_eam_request_rec.request_id
			  FROM cs_incidents_all_b
			 WHERE incident_number = p_eam_request_rec.request_number;
	     END IF;
         END IF;

	 IF  p_eam_request_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE AND p_eam_request_rec.request_type = 2 THEN
		SELECT EAM_WO_SERVICE_ASSOCIATION_S.NEXTVAL
		  INTO x_eam_request_rec.service_assoc_id
		  FROM dual;
	 END IF;

  END Attribute_Defaulting;


END EAM_REQUEST_DEFAULT_PVT;

/
