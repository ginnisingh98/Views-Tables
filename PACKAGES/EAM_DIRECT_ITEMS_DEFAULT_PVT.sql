--------------------------------------------------------
--  DDL for Package EAM_DIRECT_ITEMS_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DIRECT_ITEMS_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVDIDS.pls 115.1 2003/09/25 05:51:15 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDIDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_DIRECT_ITEMS_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  15-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/


        PROCEDURE Attribute_Defaulting
        (  p_eam_direct_items_rec              IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_eam_direct_items_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         );

        PROCEDURE Populate_Null_Columns
        (  p_eam_direct_items_rec         IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , p_old_eam_direct_items_rec     IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_eam_direct_items_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
        );


        PROCEDURE GetDI_In_Op1
        (   p_eam_direct_items_tbl     IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
          , p_organization_id         IN  NUMBER
          , p_wip_entity_id           IN  NUMBER
          , x_eam_direct_items_tbl      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        );


		PROCEDURE Change_OpSeqNum1
	    (   p_eam_direct_items_rec     IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
	      , p_operation_seq_num   IN   NUMBER
	      , p_department_id          IN NUMBER
              , x_eam_direct_items_rec      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
        );


        -- get direct_item_sequence_id
        FUNCTION get_di_seq_id
        RETURN NUMBER;


END EAM_DIRECT_ITEMS_DEFAULT_PVT;

 

/
