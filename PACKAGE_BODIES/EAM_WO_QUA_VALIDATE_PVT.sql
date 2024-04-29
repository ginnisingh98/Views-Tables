--------------------------------------------------------
--  DDL for Package Body EAM_WO_QUA_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_QUA_VALIDATE_PVT" AS
/* $Header: EAMVWQVB.pls 120.1 2006/06/17 02:28:35 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWQVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_QUA_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

 PROCEDURE Check_Required
 (
	p_eam_wo_quality_rec    IN  EAM_PROCESS_WO_PUB.eam_wo_quality_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  )IS
      l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
      l_status_type	      number;
  BEGIN


        x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion Quality Records processing Check Required'); END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check plan_id'); END IF;
	IF p_eam_wo_quality_rec.plan_id IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_wo_quality_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_PLANID_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check element_id'); END IF;
	IF p_eam_wo_quality_rec.element_id IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_wo_quality_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_ELEMENT_ID_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check element_value'); END IF;
	IF p_eam_wo_quality_rec.element_value IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_wo_quality_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_ELEMENT_VALUE_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check operation_seq_number'); END IF;
	IF p_eam_wo_quality_rec.transaction_number = 33 and p_eam_wo_quality_rec.operation_seq_number IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_wo_quality_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_OPERATION_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Completed Check_Required'); END IF;
  END Check_Required;

END EAM_WO_QUA_VALIDATE_PVT;

/
