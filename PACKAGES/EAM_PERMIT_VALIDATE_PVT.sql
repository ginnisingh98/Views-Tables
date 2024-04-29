--------------------------------------------------------
--  DDL for Package EAM_PERMIT_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PERMIT_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWPVS.pls 120.0.12010000.2 2010/03/23 00:29:20 mashah noship $ */


/********************************************************************
* Procedure     : Check_Existence
* Purpose       : Procedure will query the old work permit record and return it in old record variables.
*********************************************************************/
PROCEDURE CHECK_EXISTENCE
        				( p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_work_permit_header_rec    OUT NOCOPY  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_mesg_token_Tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                  , x_return_Status           OUT NOCOPY VARCHAR2
       				);


/********************************************************************
* Procedure: Check_Attributes
* Purpose: Check_Attributes procedure will validate every Revised item attribute in its entirely.
*********************************************************************/
PROCEDURE CHECK_ATTRIBUTES
        				( p_work_permit_header_rec        IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , p_old_work_permit_header_rec  IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_mesg_token_Tbl            OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                  , x_return_Status               OUT NOCOPY VARCHAR2
       				);


/********************************************************************
* Procedure     : Check_Required
* Purpose       : Check_Required procedure will check the existence of mandatory attributes.
*********************************************************************/
PROCEDURE CHECK_REQUIRED
        				( p_work_permit_header_rec   IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                , x_mesg_token_Tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                , x_return_Status      OUT NOCOPY VARCHAR2
       			   );


END EAM_PERMIT_VALIDATE_PVT;


/
