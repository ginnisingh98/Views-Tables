--------------------------------------------------------
--  DDL for Package EAM_DIRECT_ITEMS_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DIRECT_ITEMS_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVDIVS.pls 115.0 2003/09/19 10:35:30 baroy noship $ */
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
--      Spec of package EAM_DIRECT_ITEMS_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  15-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/

    PROCEDURE Check_Existence
        (  p_eam_direct_items_rec         IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_old_eam_direct_items_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

    PROCEDURE Check_Attributes
        (  p_eam_direct_items_rec         IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , p_old_eam_direct_items_rec     IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

    PROCEDURE Check_Required
        (  p_eam_direct_items_rec         IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         );

END EAM_DIRECT_ITEMS_VALIDATE_PVT;

 

/
