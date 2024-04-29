--------------------------------------------------------
--  DDL for Package EAM_SAFETY_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SAFETY_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVSAUS.pls 120.0.12010000.1 2010/03/19 01:13:47 mashah noship $ */

/*********************************************************************
* Procedure     : QUERY_SAFFETY_ASSOCIATION_ROWS
* Purpose       : Procedure will query the database record
                  and return with those records.
 ***********************************************************************/

PROCEDURE QUERY_SAFFETY_ASSOCIATION_ROWS
        		( p_source_id           IN  NUMBER
        		 , p_organization_id    IN  NUMBER
             , p_association_type   IN NUMBER
             , x_safety_association_rec OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
       		   , x_return_status       OUT NOCOPY VARCHAR2
         		 );



/********************************************************************
* Procedure     : INSERT_ SAFFETY_ASSOCIATION _ROW
* Purpose       : Procedure will perfrom an insert into the table
*********************************************************************/

PROCEDURE INSERT_SAFFETY_ASSOCIATION_ROW
       		 ( p_safety_association_rec IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
            , p_association_type        IN NUMBER
            , x_mesg_token_Tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
            , x_return_Status           OUT NOCOPY VARCHAR2
        		 );




/********************************************************************
* Procedure     : UPDATE_ SAFFETY_ASSOCIATION _ROW
* Purpose       : Procedure will perform an update on the table
*********************************************************************/

PROCEDURE UPDATE_SAFFETY_ASSOCIATION_ROW
        		( p_safety_association_rec IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
              , p_association_type      IN NUMBER
              , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
              , x_return_Status         OUT NOCOPY VARCHAR2
       		   );




/********************************************************************
* Procedure     : DELETE SAFFETY_ASSOCIATION _ROW
* Purpose       : This will perform delete on the table
*********************************************************************/

PROCEDURE DELETE_SAFFETY_ASSOCIATION_ROW
        		( p_safety_association_rec IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
              , p_association_type      IN NUMBER
              , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
              , x_return_Status         OUT NOCOPY VARCHAR2
       		);




/********************************************************************
* Procedure     : WRITE  SAFFETY_ASSOCIATION _ROW
* Purpose       : This is the only procedure that the user will have
                  access to when he/she needs to perform any kind of writes to the table.
*********************************************************************/

PROCEDURE WRITE_SAFFETY_ASSOCIATION_ROW
           ( p_safety_association_rec IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
            , p_association_type      IN NUMBER
            , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
            , x_return_Status          OUT NOCOPY VARCHAR2
            );

END EAM_SAFETY_UTILITY_PVT;


/
