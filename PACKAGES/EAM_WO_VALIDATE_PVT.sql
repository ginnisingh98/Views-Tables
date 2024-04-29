--------------------------------------------------------
--  DDL for Package EAM_WO_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWOVS.pls 115.3 2004/06/23 00:53:16 anjgupta ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

    PROCEDURE Check_Existence
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_old_eam_wo_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

    PROCEDURE Check_Attributes_b4_Defaulting
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
        ,  x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status      OUT NOCOPY VARCHAR2
        );

    PROCEDURE Check_Attributes
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_old_eam_wo_rec     IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

    PROCEDURE Check_Required
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );


END EAM_WO_VALIDATE_PVT;

 

/
