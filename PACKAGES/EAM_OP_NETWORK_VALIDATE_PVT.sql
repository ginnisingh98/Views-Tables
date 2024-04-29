--------------------------------------------------------
--  DDL for Package EAM_OP_NETWORK_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OP_NETWORK_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVONVS.pls 115.1 2002/11/25 00:06:12 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVONVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_OP_NETWORK_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

    PROCEDURE Check_Existence
        (  p_eam_op_network_rec         IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_old_eam_op_network_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_Mesg_Token_Tbl             OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status              OUT NOCOPY VARCHAR2
         );

    PROCEDURE Check_Attributes
        (  p_eam_op_network_rec         IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , p_old_eam_op_network_rec     IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_return_status              OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl             OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

    PROCEDURE Check_Required
        (  p_eam_op_network_rec         IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_return_status              OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl             OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );


END EAM_OP_NETWORK_VALIDATE_PVT;

 

/
