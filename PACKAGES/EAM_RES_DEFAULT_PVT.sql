--------------------------------------------------------
--  DDL for Package EAM_RES_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_RES_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVRSDS.pls 115.1 2002/11/24 23:57:52 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRSDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_RES_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/


        PROCEDURE Attribute_Defaulting
        (  p_eam_res_rec         IN  EAM_PROCESS_WO_PUB.eam_res_rec_type
         , x_eam_res_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Populate_Null_Columns
        (  p_eam_res_rec         IN  EAM_PROCESS_WO_PUB.eam_res_rec_type
         , p_old_eam_res_rec     IN  EAM_PROCESS_WO_PUB.eam_res_rec_type
         , x_eam_res_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_rec_type
        );


END EAM_RES_DEFAULT_PVT;

 

/