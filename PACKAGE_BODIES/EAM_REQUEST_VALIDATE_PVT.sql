--------------------------------------------------------
--  DDL for Package Body EAM_REQUEST_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REQUEST_VALIDATE_PVT" AS
/* $Header: EAMVRQVB.pls 120.2 2006/02/21 03:13:54 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRQVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_REQUEST_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

 PROCEDURE CHECK_REQUIRED
  (     p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
       , x_return_status           OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  )
  IS

            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
  BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request/Service Request processing Check Required'); END IF;

  	x_return_status := FND_API.G_RET_STS_SUCCESS;

	 IF p_eam_request_rec.organization_id IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
		    l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WRSR_ORG_REQUIRED'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
      	            return;
           END IF;

	   IF p_eam_request_rec.request_type IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
		    l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WRSR_REQTYPE_REQUIRED'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
      	            return;
           END IF;

	   IF p_eam_request_rec.request_id IS NULL AND p_eam_request_rec.request_number IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
		    l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WRSR_REQID_REQUIRED'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
      	            return;
           END IF;

  END CHECK_REQUIRED;

 PROCEDURE CHECK_ATTRIBUTES
 (      p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
        , x_return_status         OUT NOCOPY  VARCHAR2
        , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 )
  IS
	    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
	    g_dummy		    NUMBER;
  BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request/Service Request processing Check Attributes'); END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	  IF p_eam_request_rec.request_number IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
		    l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WRSR_REQNUM_REQUIRED'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
       	            return;
           END IF;

	   IF p_eam_request_rec.request_id IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
		    l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WRSR_REQID_REQUIRED'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
      	            return;
           END IF;

	--  organization_id

	  DECLARE
	    l_disable_date date;
	  BEGIN

	    SELECT 1
	      INTO g_dummy
	      FROM mtl_parameters mp
	     WHERE mp.organization_id = p_eam_request_rec.organization_id;

	    SELECT nvl(hou.date_to,sysdate+1)
	      INTO l_disable_date
	      FROM hr_organization_units hou
	      WHERE organization_id =  p_eam_request_rec.organization_id;

	    IF(l_disable_date < sysdate) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	    x_return_status := FND_API.G_RET_STS_SUCCESS;

	  EXCEPTION
	    WHEN OTHERS THEN

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
	      l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name		=> 'EAM_WRSR_INVALID_ORGID'
	       , p_token_tbl		=> l_token_tbl
	       , p_mesg_token_tbl       => l_mesg_token_tbl
	       , x_mesg_token_tbl       => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;
	      x_return_status	    := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl	    := l_mesg_token_tbl ;
	      RETURN;
	  END;


	--  organization_id (EAM enabled)

	  BEGIN

	    SELECT 1
	      INTO g_dummy
	      FROM wip_eam_parameters wep, mtl_parameters mp
	     WHERE wep.organization_id = mp.organization_id
	       AND mp.eam_enabled_flag = 'Y'
	       AND wep.organization_id = p_eam_request_rec.organization_id;

	       x_return_status := FND_API.G_RET_STS_SUCCESS;

	  EXCEPTION
	    WHEN OTHERS THEN

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
	      l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_WRSR_EAMINVALID_ORGID'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;
	      x_return_status       := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl      := l_mesg_token_tbl ;
	      return;

	  END;

	IF p_eam_request_rec.transaction_type = 1 AND p_eam_request_rec.request_type =1  THEN
	  begin
	     SELECT 1
	       INTO g_dummy
	       FROM WIP_DISCRETE_JOBS wdj
              WHERE wdj.STATUS_TYPE IN (WIP_CONSTANTS.DRAFT,WIP_CONSTANTS.UNRELEASED,WIP_CONSTANTS.RELEASED,
  	            WIP_CONSTANTS.HOLD,WIP_CONSTANTS.COMP_CHRG,WIP_CONSTANTS.COMP_NOCHRG)
  	        AND wdj.wip_entity_id = p_eam_request_rec.wip_entity_id ;

		 x_return_status := FND_API.G_RET_STS_SUCCESS;
	  exception
	  when others then

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
	      l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_WR_INVALID_WORKORDER'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;
	      x_return_status	    := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;
	  end;

	END IF;

	IF p_eam_request_rec.transaction_type = 1 AND p_eam_request_rec.request_type =2  THEN
	  begin
	     SELECT 1
	       INTO g_dummy
	       FROM WIP_DISCRETE_JOBS wdj
              WHERE wdj.STATUS_TYPE IN (WIP_CONSTANTS.DRAFT,WIP_CONSTANTS.UNRELEASED,WIP_CONSTANTS.RELEASED,
				       WIP_CONSTANTS.HOLD,WIP_CONSTANTS.COMP_CHRG,WIP_CONSTANTS.COMP_NOCHRG)
    	        AND wdj.wip_entity_id = p_eam_request_rec.wip_entity_id ;

	       x_return_status := FND_API.G_RET_STS_SUCCESS;

	  exception
	  when others then

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
	      l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_WO_NOT_ASSOC_WR'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;
	  end;
	END IF;

	 IF p_eam_request_rec.transaction_type = 1 AND p_eam_request_rec.request_type =1  THEN
	  begin
	     SELECT 1
	       INTO g_dummy
	       FROM WIP_EAM_WORK_REQUESTS wewr
              WHERE wewr.work_request_id = p_eam_request_rec.request_id
	        AND WORK_REQUEST_STATUS_ID = 3 ;

		 x_return_status := FND_API.G_RET_STS_SUCCESS;

	  exception
	  when others then

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
	      l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_WO_REQID_INVALID'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;
	  end;

	END IF;

	IF p_eam_request_rec.transaction_type = 1 AND p_eam_request_rec.request_type =2  THEN
	  begin
	     SELECT 1
	       INTO g_dummy
	       FROM CS_INCIDENTS_ALL_B ciab ,CS_INCIDENT_TYPES_B citb
              WHERE ciab.INCIDENT_STATUS_ID = 1
	        AND ciab.MAINT_ORGANIZATION_ID  = p_eam_request_rec.ORGANIZATION_ID
		AND ciab.INCIDENT_TYPE_ID = citb.INCIDENT_TYPE_ID
		AND nvl(citb.MAINTENANCE_FLAG,'N')   = 'Y'
		AND ciab.INCIDENT_ID = p_eam_request_rec.request_id;


		 x_return_status := FND_API.G_RET_STS_SUCCESS;

	  exception
	  when others then

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
	      l_token_tbl(1).token_value :=  p_eam_request_rec.wip_entity_id;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_SR_REQ_ID_NOT_OPEN'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;
	  end;
	END IF;

	IF p_eam_request_rec.transaction_type = 1 AND p_eam_request_rec.request_type =1  THEN
	BEGIN

		SELECT COUNT(wip_entity_id) INTO g_dummy
		  FROM WIP_EAM_WORK_REQUESTS
		 WHERE work_request_id	 = p_eam_request_rec.request_id
		   AND organization_id  = p_eam_request_rec.organization_id;

		   IF g_dummy > 0 THEN
		      l_token_tbl(1).token_name  := 'REQUEST_ID';
		      l_token_tbl(1).token_value :=  p_eam_request_rec.request_id;

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_WR_ALD_ASSO_WO'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      return;
		   END IF;

	END;
	END IF;

	IF p_eam_request_rec.transaction_type = 1 AND p_eam_request_rec.request_type =2  THEN
	BEGIN

		SELECT	COUNT(1)
	   	  INTO 	g_dummy
       	          FROM  EAM_WO_SERVICE_ASSOCIATION
        	 WHERE  maintenance_organization_id = p_eam_request_rec.organization_id
        	   AND 	wip_entity_id	  	    = p_eam_request_rec.wip_entity_id
	           AND  (enable_flag IS NULL OR enable_flag = 'Y');      -- Fix for 3773450


		   IF g_dummy > 0 THEN
		      l_token_tbl(1).token_name  := 'REQUEST_ID';
		      l_token_tbl(1).token_value :=  p_eam_request_rec.request_id;

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_SR_ALD_ASS_WO'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      return;
		   END IF;

	END;
	END IF;


  END CHECK_ATTRIBUTES;


END EAM_REQUEST_VALIDATE_PVT;

/
