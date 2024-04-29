--------------------------------------------------------
--  DDL for Package EAM_MAT_REQ_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MAT_REQ_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVMRVS.pls 120.0.12010000.1 2008/07/24 11:50:42 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMRVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_MAT_REQ_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

    PROCEDURE Check_Existence
        (  p_eam_mat_req_rec         IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_old_eam_mat_req_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

    PROCEDURE Check_Attributes
        (  p_eam_mat_req_rec         IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , p_old_eam_mat_req_rec     IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

    PROCEDURE Check_Required
        (  p_eam_mat_req_rec         IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

END EAM_MAT_REQ_VALIDATE_PVT;

/
