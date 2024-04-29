--------------------------------------------------------
--  DDL for Package EAM_OP_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OP_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVOPVS.pls 120.1 2007/12/13 05:58:11 rnandyal ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOPVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_OP_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

    PROCEDURE Check_Existence
        (  p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_old_eam_op_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

    PROCEDURE Check_Attributes
        (  p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , p_old_eam_op_rec     IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

    PROCEDURE Check_Required
        (  p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

    -- This procedure will check that after operation updatates,the depdendency in the operation depdendency network is valid
    -- If the depdencdency fails then ,it throws an error

    PROCEDURE Check_Operation_Netwrok_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
	x_pri_operation_no              OUT NOCOPY  NUMBER,
	x_next_operation_no             OUT NOCOPY  NUMBER
        );

	FUNCTION IS_WO_DEPT_CHANGE_ALLOWED(X_WIP_ENTITY_ID NUMBER) RETURN VARCHAR2;
	FUNCTION IS_OP_DEPT_CHANGE_ALLOWED(P_WIP_ENTITY_ID NUMBER,   P_OP_SEQ_NUM NUMBER) RETURN VARCHAR2;
	FUNCTION VALIDATE_DEPT_RES_INSTANCE(P_DEPT_ID NUMBER , P_INST_ID NUMBER, P_RES_ID NUMBER) RETURN VARCHAR2 ;
	 FUNCTION VALIDATE_DEPT_RES(P_DEPT_ID NUMBER , P_RES_CODE VARCHAR2) RETURN VARCHAR2 ;


END EAM_OP_VALIDATE_PVT;



/
