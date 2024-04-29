--------------------------------------------------------
--  DDL for Package EAM_PROCESS_PERMIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_PERMIT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWPTS.pls 120.0.12010000.2 2010/05/19 12:25:29 vboddapa noship $ */
/***************************************************************************
--
--  Copyright (c) 2009 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME:  EAMVWPTS.pls
--
--  DESCRIPTION:  Spec of package EAM_PROCESS_PERMIT_PVT
--
--  NOTES
--
--  HISTORY
--
--  25-JAN-2009   Madhuri Shah     Initial Creation
***************************************************************************/

PROCEDURE VALIDATE_TRANSACTION_TYPE(
                 p_validation_level     IN  		   NUMBER
               , p_entity               IN  		   VARCHAR2
               , x_return_status      OUT NOCOPY VARCHAR2
               , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
              );

/************************************************************
* Procedure :     PROCESS_WORK_PERMIT
* Purpose :       This  will process create/update/delete on work permit
************************************************************/
PROCEDURE   PROCESS_WORK_PERMIT
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_work_permit_header_rec  IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
         , p_permit_wo_association_tbl  IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
         , x_work_permit_header_rec  OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_SAFETY_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );

/************************************************************
* Procedure :     WORK_PERMIT
* Purpose :       This  will process  work permit header
************************************************************/
PROCEDURE  WORK_PERMIT
 (
        p_validation_level           IN  		        NUMBER
      , p_work_permit_id             IN             NUMBER :=NULL
      , p_organization_id	           IN             NUMBER :=NULL
      , p_work_permit_header_rec     IN             EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
      , x_work_permit_header_rec     OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
      , x_mesg_token_tbl             OUT NOCOPY     EAM_ERROR_MESSAGE_PVT.MESG_TOKEN_TBL_TYPE
      , x_return_status              OUT NOCOPY 	  VARCHAR2
);

/************************************************************
* Procedure:     PERMIT_WORK_ORDER_ASSOCIATION
* Purpose :       This  will process permit work order association
************************************************************/
PROCEDURE  PERMIT_WORK_ORDER_ASSOCIATION
(     p_validation_level                  IN  		NUMBER
    , p_organization_id	                  IN	    NUMBER
    , p_permit_wo_association_tbl         IN     EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
    , p_work_permit_id                    IN  		NUMBER
    , x_permit_wo_association_tbl         OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
    , x_mesg_token_tbl                    OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.MESG_TOKEN_TBL_TYPE
    , x_return_status                     OUT NOCOPY 	VARCHAR2
);


/********************************************************************
  * Procedure: Raise_Workflow_Events
  * Purpose: This procedure raises the workflow events for work permit release
*********************************************************************/
  PROCEDURE RAISE_WORKFLOW_EVENTS
    (   p_api_version             IN  NUMBER
      , p_validation_level        IN  NUMBER
      , p_eam_wp_rec              IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
      , p_old_eam_wp_rec          IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
      , p_approval_required       IN    BOOLEAN
      , p_new_system_status       IN    NUMBER
      , p_workflow_name           IN    VARCHAR2
      , p_workflow_process        IN   VARCHAR2
      , x_mesg_token_tbl          IN OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
      , x_return_status           IN OUT NOCOPY VARCHAR2
       );

/**************************************************************************
* Procedure:     COPY_WORK_PERMIT
* Purpose:        Procedure to copy work permit record.
*                 This procedure will be called from the public API
***************************************************************************/

 PROCEDURE COPY_WORK_PERMIT(
          p_bo_identifier              IN  VARCHAR2 := 'EAM'
         , p_api_version_number        IN  NUMBER   := 1.0
         , p_init_msg_list             IN  BOOLEAN  := FALSE
         , p_commit                    IN  VARCHAR2 := 'N'
         , p_debug                     IN  VARCHAR2 := 'N'
         , p_output_dir                IN  VARCHAR2 := NULL
         , p_debug_filename            IN  VARCHAR2 := 'EAM_SAFETY_DEBUG.log'
         , p_debug_file_mode           IN  VARCHAR2 := 'w'
         , p_org_id                    IN  NUMBER
         , px_permit_id                IN  OUT NOCOPY   NUMBER
         , x_return_status             OUT NOCOPY VARCHAR2
         , x_msg_count                 OUT NOCOPY NUMBER

);

END EAM_PROCESS_PERMIT_PVT;


/
