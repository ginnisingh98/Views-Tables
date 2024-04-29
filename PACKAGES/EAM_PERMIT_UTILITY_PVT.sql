--------------------------------------------------------
--  DDL for Package EAM_PERMIT_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PERMIT_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWPUS.pls 120.0.12010000.1 2010/03/19 01:50:10 mashah noship $ */

/*********************************************************************
* Procedure     : QUERY_ROW
* Purpose       : Procedure will query the database record
                  and return with those records.
***********************************************************************/
PROCEDURE QUERY_ROW
        				( p_work_permit_id       IN  NUMBER
                  , p_organization_id         IN  NUMBER
                  , x_work_permit_header_rec OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_Return_status       OUT NOCOPY VARCHAR2
         				);


/********************************************************************
* Procedure     : INSERT_ROW
* Purpose       : Procedure will perfrom an insert into the table
*********************************************************************/
PROCEDURE INSERT_ROW
       				 (p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                , x_return_Status      OUT NOCOPY VARCHAR2
                );

/********************************************************************
* Procedure     : UPDATE_ROW
* Purpose       : Procedure will perform an update on the table
*********************************************************************/
PROCEDURE UPDATE_ROW
        				( p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                 , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                 , x_return_Status      OUT NOCOPY VARCHAR2
       				  );


/********************************************************************
* Procedure     : PERFORM_WRITES
* Purpose       : This is the only procedure that the user will have
                  access to when he/she needs to perform any kind of writes to the table.
*********************************************************************/

PROCEDURE PERFORM_WRITES
                ( p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                  , x_return_Status      OUT NOCOPY VARCHAR2
                );



/********************************************************************
* Procedure     : CHANGE_WORK_PERMIT_STATUS
* Purpose       : This procedure will be used to change status of a permit.
*********************************************************************/
PROCEDURE CHANGE_WORK_PERMIT_STATUS
                (    p_permit_id            IN  NUMBER
                  ,  p_organization_id      IN  NUMBER
                  ,  p_to_status_type       IN  NUMBER
                  ,  p_user_id              IN  NUMBER  := null
                  ,  p_responsibility_id    IN  NUMBER  := null
                  ,  p_transaction_type     IN  NUMBER
                  ,  x_return_status        OUT NOCOPY           VARCHAR2
                  ,  x_Mesg_Token_Tbl       OUT NOCOPY           EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                 );


/********************************************************************
* Procedure     : INSERT_PERMIT_HISTORY_ROW
* Purpose       : This procedure will be used to write permit history to EAM_SAFETY_HISTORY table
*********************************************************************/
PROCEDURE INSERT_PERMIT_HISTORY_ROW
                (   p_object_id           IN NUMBER
                  , p_object_name         IN VARCHAR2
                  , p_object_type         IN NUMBER :=3
                  , p_event               IN VARCHAR2
                  , p_status              IN VARCHAR2
                  , p_details             IN VARCHAR2
                  , p_user_id             IN NUMBER
                  , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                  , x_return_Status       OUT NOCOPY VARCHAR2
                );


END EAM_PERMIT_UTILITY_PVT;


/
