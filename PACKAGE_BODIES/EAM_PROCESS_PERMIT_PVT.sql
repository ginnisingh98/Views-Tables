--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_PERMIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_PERMIT_PVT" AS
/* $Header: EAMVWPTB.pls 120.0.12010000.7 2010/05/21 20:12:48 mashah noship $ */
/***************************************************************************
--
--  Copyright (c) 2009 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME: EAMVWPTB.pls
--
--  DESCRIPTION: Body of package EAM_PROCESS_PERMIT_PVT
--
--  NOTES
--
--  HISTORY
--
--  25-JAN-2009   Madhuri Shah     Initial Creation
***************************************************************************/

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'EAM_PROCESS_PERMIT_PVT';
G_FILE_NAME      CONSTANT VARCHAR2(12) := 'EAMVWPTB.pls';
G_DEBUG_FILENAME CONSTANT VARCHAR2(50) := 'EAM_SAFETY_DEBUG.log';


/*********************************************************
* Procedure :     Validate_Transaction_Type
 * Purpose :      This procedure will check if the transaction type is valid
                  for a particular entity.
*********************************************************/

PROCEDURE VALIDATE_TRANSACTION_TYPE
         (
               p_validation_level     IN  		   NUMBER
               , p_entity             IN  		   VARCHAR2
               , x_return_status      OUT NOCOPY VARCHAR2
               , x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )IS

          l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
          l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
          l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ;
          l_other_message         VARCHAR2(2000);
          l_err_text              VARCHAR2(2000);


BEGIN

  IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Inside EAM_PROCESS_PERMIT_PVT.VALIDATE_TRANSACTION_TYPE'); end if;

   IF (p_entity = 'WORK PERMIT') THEN
          IF (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_CREATE)
          OR (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_UPDATE) then
              x_return_status := FND_API.G_RET_STS_SUCCESS;

          ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
    ELSE
          IF (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_CREATE)
          OR (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_UPDATE)
          OR (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_DELETE)then

             x_return_status := FND_API.G_RET_STS_SUCCESS;

          ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

    END IF;

END VALIDATE_TRANSACTION_TYPE;



FUNCTION IS_WORKFLOW_ENABLED
                     (p_maint_obj_source        IN   NUMBER,
                      p_organization_id         IN    NUMBER
                     ) RETURN VARCHAR2
                     IS
                     l_workflow_enabled      VARCHAR2(1);
BEGIN

     BEGIN
              SELECT enable_workflow
	            INTO   l_workflow_enabled
	            FROM EAM_ENABLE_WORKFLOW
	            WHERE MAINTENANCE_OBJECT_SOURCE =p_maint_obj_source;
     EXCEPTION
          WHEN NO_DATA_FOUND   THEN
	      l_workflow_enabled    :=         'N';
     END;

  --IF EAM workorder,check if workflow is enabled for this organization or not
  IF(l_workflow_enabled ='Y'   AND   p_maint_obj_source=1) THEN
       BEGIN
               SELECT eam_wo_workflow_enabled
	             INTO l_workflow_enabled
	             FROM WIP_EAM_PARAMETERS
	            WHERE organization_id =p_organization_id;
       EXCEPTION
               WHEN NO_DATA_FOUND THEN
		       l_workflow_enabled := 'N';
       END;


     RETURN l_workflow_enabled;

  END IF;  --check for workflow enabled at org level

    RETURN l_workflow_enabled;

END IS_WORKFLOW_ENABLED;

/************************************************************
* Procedure :     PROCESS_WORK_PERMIT
* Purpose :       This  will process create/update/delete on work permit
************************************************************/

PROCEDURE   PROCESS_WORK_PERMIT
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2
         , p_work_permit_header_rec  IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
         , p_permit_wo_association_tbl  IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
         , x_work_permit_header_rec  OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2
         , p_output_dir              IN  VARCHAR2
         , p_debug_filename          IN  VARCHAR2
         , p_debug_file_mode         IN  VARCHAR2
         )IS

         l_api_name                   CONSTANT VARCHAR2(30) := G_PKG_NAME;
         l_validation_level           NUMBER :=p_work_permit_header_rec.transaction_type;

         l_return_status         VARCHAR2(1);
         l_msg_count             NUMBER;
         l_msg_data              VARCHAR2(240);
         l_permit_wo_association_tbl EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type;
         l_permit_id              NUMBER;

         /* Error Handling Variables */
          l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
          l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
          l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ;
          l_other_message         VARCHAR2(2000);
          l_err_text              VARCHAR2(2000);
          l_error_level           NUMBER :=EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL;
          l_entity_index          NUMBER :=1;


BEGIN

   SAVEPOINT PROCESS_PERMIT;

  IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Inside EAM_PROCESS_PERMIT_PVT.PROCESS_WORK_PERMIT'); end if;

 -- 1) Work_Permit for processing of Work Permit header record

 IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling WORK_PERMIT from  PROCESS_WORK_PERMIT'); end if;

          WORK_PERMIT
         (
           p_validation_level        => l_validation_level
          , p_work_permit_id          => p_work_permit_header_rec.permit_id
          , p_organization_id	        => p_work_permit_header_rec.organization_id
          , p_work_permit_header_rec  => p_work_permit_header_rec
          , x_work_permit_header_rec  => x_work_permit_header_rec
          , x_mesg_token_tbl          => l_out_Mesg_Token_Tbl
          , x_return_status           => l_return_status
         );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => l_out_Mesg_Token_Tbl
                 , p_error_level        => l_error_level
                 , p_entity_index       => l_entity_index
                );
             raise fnd_api.g_exc_unexpected_error;
        END IF;

  IF p_permit_wo_association_tbl.COUNT > 0 THEN
      IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling PERMIT_WORK_ORDER_ASSOCIATION from  PROCESS_WORK_PERMIT'); end if;
         l_permit_id :=x_work_permit_header_rec.permit_id;
         PERMIT_WORK_ORDER_ASSOCIATION
        (
           p_validation_level           => l_validation_level
         , p_organization_id	           => p_work_permit_header_rec.organization_id
         , p_permit_wo_association_tbl  => p_permit_wo_association_tbl
         , p_work_permit_id             => l_permit_id
         , x_permit_wo_association_tbl  => l_permit_wo_association_tbl
         , x_mesg_token_tbl             => l_out_Mesg_Token_Tbl
         , x_return_status              => l_return_status
       );

  END IF;


   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => l_out_Mesg_Token_Tbl
                 , p_error_level        => l_error_level
                 , p_entity_index       => l_entity_index
                );
                raise fnd_api.g_exc_unexpected_error;
        END IF;

      x_return_status :=l_return_status;

      IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
      END IF;


EXCEPTION

  WHEN fnd_api.g_exc_unexpected_error THEN
             ROLLBACK TO PROCESS_PERMIT;
            x_return_status       := FND_API.G_RET_STS_ERROR;
            x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

  WHEN OTHERS THEN
       ROLLBACK TO PROCESS_PERMIT;
       x_return_status       := FND_API.G_RET_STS_ERROR;


END PROCESS_WORK_PERMIT;



/************************************************************
* Procedure :     WORK_PERMIT
* Purpose :       This  will process  work permit header
************************************************************/
PROCEDURE  WORK_PERMIT
 (
         p_validation_level            IN  		        NUMBER
        , p_work_permit_id             IN             NUMBER :=NULL
        , p_organization_id	           IN             NUMBER :=NULL
        , p_work_permit_header_rec     IN             EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
        , x_work_permit_header_rec     OUT NOCOPY     EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
        , x_mesg_token_tbl             OUT NOCOPY     EAM_ERROR_MESSAGE_PVT.MESG_TOKEN_TBL_TYPE
        , x_return_status              OUT NOCOPY 	  VARCHAR2
        )IS

        CURSOR C IS SELECT EAM_WORK_PERMIT_S.NEXTVAL FROM SYS.DUAL;

        l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_return_status  VARCHAR2(1);

        l_permit_id NUMBER := p_work_permit_header_rec.PERMIT_ID;
        l_workflow_enabled VARCHAR2(1);

        l_work_permit_header_rec EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type :=p_work_permit_header_rec;
        l_old_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
        l_out_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;


        l_maintenance_object_source NUMBER :=1;  -- To check if work flow is enabled
        l_status_pending_event        VARCHAR2(100)       := 'oracle.apps.eam.permit.status.change.pending';
        l_approval_required BOOLEAN := FALSE;      --set the flag to 'false' initially
        l_pending_workflow_name              VARCHAR2(100);
        l_pending_workflow_process           VARCHAR2(200) ;
        l_new_system_status             NUMBER;

        l_permit_write_error           EXCEPTION;
        l_permit_transaction_error     EXCEPTION;
        l_permit_existence_error       EXCEPTION;
        l_permit_required_error        EXCEPTION;
        l_permit_attributes_error      EXCEPTION;
        l_err_status_change            EXCEPTION;

BEGIN

SAVEPOINT WORK_PERMIT;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Inside EAM_PROCESS_PERMIT_PVT.WORK_PERMIT'); end if;

 IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling VALIDATE_TRANSACTION_TYPE'); end if;

        EAM_PROCESS_PERMIT_PVT.VALIDATE_TRANSACTION_TYPE
        (    p_validation_level       => p_validation_level
           , p_entity                 => 'WORK PERMIT'
           , x_mesg_token_Tbl         => l_Mesg_Token_Tbl
           , x_return_Status          => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
             RAISE l_permit_transaction_error;
        END IF;

       IF (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_CREATE) THEN
           IF (l_permit_id IS NULL) OR (l_permit_id = FND_API.G_MISS_NUM) THEN
                  OPEN C;
                  FETCH C INTO l_permit_id;
                  CLOSE C;
                  l_work_permit_header_rec.permit_id :=l_permit_id;
          END IF;
      END IF;

 IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling Check_Existence'); end if;

        EAM_PERMIT_VALIDATE_PVT.Check_Existence
        (  p_work_permit_header_rec   => l_work_permit_header_rec
           , x_work_permit_header_rec  => l_old_work_permit_header_rec
           , x_mesg_token_Tbl          => l_Mesg_Token_Tbl
           , x_return_Status           => l_return_status
        );


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
             RAISE l_permit_existence_error;
        END IF;


 IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling Populate_NULL_Columns'); end if;
   IF (p_validation_level = EAM_PROCESS_WO_PVT.G_OPR_UPDATE) THEN

        EAM_PERMIT_DEFAULT_PVT.Populate_NULL_Columns
        (  p_eam_wp_rec           => l_work_permit_header_rec
           , p_old_eam_wp_rec      => l_old_work_permit_header_rec
           , x_eam_wp_rec          => l_out_work_permit_header_rec
        );

        l_work_permit_header_rec := l_out_work_permit_header_rec;


   END IF;

 IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling Check_required'); end if;


        EAM_PERMIT_VALIDATE_PVT.CHECK_REQUIRED
        (  p_work_permit_header_rec   => l_work_permit_header_rec
          , x_mesg_token_Tbl          => l_Mesg_Token_Tbl
          , x_return_Status           => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
             RAISE l_permit_required_error;
        END IF;


 IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling Check_attributes'); end if;


        EAM_PERMIT_VALIDATE_PVT.CHECK_ATTRIBUTES
        (  p_work_permit_header_rec        => l_work_permit_header_rec
           , p_old_work_permit_header_rec  => l_old_work_permit_header_rec
           , x_mesg_token_Tbl              => l_Mesg_Token_Tbl
           , x_return_Status               => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
             RAISE l_permit_attributes_error;
        END IF;

--Check if work flow is enabled and work permit requires an approval, set the pending flag to ?Y? in the work permit record.
     l_workflow_enabled := Is_Workflow_Enabled(l_maintenance_object_source, p_organization_id);

	IF(l_workflow_enabled = 'Y') THEN        --if workflow is enabled
      IF((l_work_permit_header_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE )  --created
		    OR (l_work_permit_header_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE  --workorder updated
			     AND NVL(l_old_work_permit_header_rec.pending_flag,'N') = 'N'   --old status is not pending
			     --and old status is not same as new status
		            AND (l_old_work_permit_header_rec.status_type <>l_work_permit_header_rec.status_type)
			     )
		    ) THEN

             IF(WF_EVENT.TEST(l_status_pending_event) <> 'NONE') THEN

              IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Calling Wkflow required check API...') ; END IF;


							 EAM_WORKPERMIT_WORKFLOW_PVT.Is_Approval_Required_Released
                                (p_old_wp_rec         =>  l_old_work_permit_header_rec,
															   p_new_wp_rec         =>  l_work_permit_header_rec,
															   x_approval_required  =>  l_approval_required,
															   x_workflow_name      =>   l_pending_workflow_name,
															   x_workflow_process   =>   l_pending_workflow_process
															   );

						IF(l_approval_required) THEN
							    l_work_permit_header_rec.pending_flag:='Y';   --if approval required set the pending flag and system status to previous status
							    l_new_system_status :=    l_work_permit_header_rec.status_type;
							    l_work_permit_header_rec.status_type := NVL(l_old_work_permit_header_rec.status_type,17);

						END IF;
			   END IF; --end of check for status event enabled

		 END IF;


	END IF;  --end of check for workflow enabled

  -- Put permit completion details if status is changed to complete

    IF (l_work_permit_header_rec.status_type in (wip_constants.comp_chrg,wip_constants.comp_nochrg)) THEN

       IF (l_old_work_permit_header_rec.status_type = wip_constants.draft) THEN
          RAISE l_err_status_change;
       ELSE
          l_work_permit_header_rec.COMPLETION_DATE := NVL(l_work_permit_header_rec.COMPLETION_DATE,sysdate);
       END IF;
    END IF;


   IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling Perform_Writes'); end if;

        EAM_PERMIT_UTILITY_PVT.PERFORM_WRITES
        (  p_work_permit_header_rec => l_work_permit_header_rec
           , x_mesg_token_Tbl         => l_Mesg_Token_Tbl
           , x_return_Status          => l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
            RAISE l_permit_write_error;
        END IF;

        x_work_permit_header_rec :=l_work_permit_header_rec;

     IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Created Permit with permit id: '||p_work_permit_header_rec.permit_id); end if;

    --If work permit is approved and no workflow then call the procedure CHANGE_WORK_PERMIT_STATUS
  IF(l_workflow_enabled = 'N')
         OR (l_work_permit_header_rec.APPROVED_BY IS NOT NULL)
         OR (l_work_permit_header_rec.APPROVED_BY <> FND_API.G_MISS_NUM) THEN

         IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling CHANGE_WORK_PERMIT_STATUS') ; END IF ;

			      EAM_PERMIT_UTILITY_PVT.CHANGE_WORK_PERMIT_STATUS
                                  (  p_permit_id              => l_work_permit_header_rec.permit_id
                                  ,  p_organization_id        => l_work_permit_header_rec.organization_id
                                  ,  p_to_status_type         => l_work_permit_header_rec.status_type
                                  ,  p_user_id                => l_work_permit_header_rec.user_id
                                  ,  p_responsibility_id      => l_work_permit_header_rec.responsibility_id
                                  ,  p_transaction_type       => l_work_permit_header_rec.transaction_type
                                  ,  x_return_status          => l_return_status
                                  ,  x_Mesg_Token_Tbl         => l_mesg_token_tbl
                                  );

     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Status Change WO completed with status ' || l_return_status) ; END IF ;
				IF NVL(l_return_status, 'S') <> 'S' THEN
				       l_return_status := FND_API.G_RET_STS_ERROR;
				       RAISE l_err_status_change;

				END IF;

  END IF;

 --IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling INSERT_PERMIT_HISTORY_ROW'); end if;
 --Call the procedure  EAM_PERMIT_UTILITY_PVT.INSERT_PERMIT_HISTORY_ROW to insert the  event  details in the EAM_SAFETY_HISTORY table

 --If workflow is enabled and workflow approval is required call the procedure RAISE_WORKFLOW_EVENTS.

  IF(l_workflow_enabled = 'Y')
    AND (l_approval_required) THEN
              IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling the Raise_Workflow_Events procedure ...') ; END IF ;
                  Raise_Workflow_Events
                                      ( p_api_version   =>   1.0,
                                        p_validation_level => p_validation_level,
                                        p_eam_wp_rec => l_work_permit_header_rec,
                                        p_old_eam_wp_rec  => l_old_work_permit_header_rec,
                                        p_approval_required   =>  l_approval_required,
                                        p_new_system_status     =>    l_new_system_status,
                                        p_workflow_name    =>   l_pending_workflow_name,
                                        p_workflow_process   =>   l_pending_workflow_process,
                                        x_return_status => l_return_status,
                                        x_mesg_token_tbl => l_mesg_token_tbl
                                        );

                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Raise_Workflow_Events procedure completed with status '||l_return_status) ; END IF ;

    END IF;

        x_return_status :=l_return_status;


EXCEPTION

        WHEN l_permit_write_error then
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_WRITE_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
        ROLLBACK TO WORK_PERMIT;

 WHEN l_permit_transaction_error then
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_TRANSACTION_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
        ROLLBACK TO WORK_PERMIT;

 WHEN l_permit_existence_error then
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_EXISTENCE_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
        ROLLBACK TO WORK_PERMIT;
 WHEN l_permit_required_error then
         l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_REQUIRED_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
        ROLLBACK TO WORK_PERMIT;
 WHEN l_permit_attributes_error then
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_ATTRIBUTE_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );

        l_mesg_token_tbl      := l_out_mesg_token_tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
         ROLLBACK TO WORK_PERMIT;
WHEN l_err_status_change then
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_STATUS_CNG_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
         ROLLBACK TO WORK_PERMIT;

  WHEN OTHERS THEN
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;
        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_UNEXPECTED_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
        ROLLBACK TO WORK_PERMIT;


END WORK_PERMIT;

/************************************************************
* Procedure:     PERMIT_WORK_ORDER_ASSOCIATION
* Purpose :       This  will process permit work order association
************************************************************/

PROCEDURE   PERMIT_WORK_ORDER_ASSOCIATION
          (   p_validation_level                    IN  		NUMBER
              , p_organization_id	                  IN	    NUMBER
              , p_permit_wo_association_tbl         IN     EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
              , p_work_permit_id                    IN  		NUMBER
              , x_permit_wo_association_tbl         OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
              , x_mesg_token_tbl                    OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.MESG_TOKEN_TBL_TYPE
              , x_return_status                     OUT NOCOPY 	VARCHAR2
          )IS
          CURSOR C IS SELECT EAM_SAFETY_ASSOCIATIONS_S.NEXTVAL FROM SYS.DUAL;
          l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
          l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
          l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
          l_return_status  VARCHAR2(1);
          l_safety_assoc_rec EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type;
          l_permit_status NUMBER;
          l_wo_status NUMBER;
          l_safety_assoc_id NUMBER;

          l_wp_association_error     EXCEPTION;



BEGIN

   SAVEPOINT PERMIT_WORK_ORDER_ASSOCIATION;
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Inside EAM_PROCESS_PERMIT_PVT.PERMIT_WORK_ORDER_ASSOCIATION'); end if;


/*For each record in the table
?	Check if the parent work permit, work order exists. */

IF p_permit_wo_association_tbl.COUNT > 0 THEN
   FOR i in p_permit_wo_association_tbl.FIRST..p_permit_wo_association_tbl.LAST LOOP

   /* --  status_type
    IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating status_type . . . '); END IF;

    begin

                select status_type
                into l_wo_status
                from wip_discrete_jobs
                where wip_entity_id = p_permit_wo_association_tbl(i).TARGET_REF_ID
                and organization_id =p_organization_id;

                select status_type
                into l_permit_status
                from  EAM_WORK_PERMITS
                where permit_id =p_work_permit_id
                and organization_id =p_organization_id;


                if (p_permit_wo_association_tbl(i).transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE and
                   (l_wo_status not in (wip_constants.released, wip_constants.draft) or
                    l_permit_status not in (wip_constants.released, wip_constants.draft))) then

                   raise fnd_api.g_exc_unexpected_error;

                elsif (p_permit_wo_association_tbl(i).transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE and
                    (l_wo_status not in (wip_constants.released, wip_constants.draft) or
                    l_permit_status not in (wip_constants.released, wip_constants.draft))) then

                   raise fnd_api.g_exc_unexpected_error;

                end if;

                l_return_status := FND_API.G_RET_STS_SUCCESS;



               IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN */
               l_safety_assoc_rec := p_permit_wo_association_tbl(i);
               if l_safety_assoc_rec.source_id is null then
                  l_safety_assoc_rec.source_id :=  p_work_permit_id;
               end if;
               EAM_PROCESS_PERMIT_PVT.VALIDATE_TRANSACTION_TYPE
                (    p_validation_level       => l_safety_assoc_rec.TRANSACTION_TYPE
                    , p_entity                 => 'ASSOCIATION'
                    , x_mesg_token_Tbl         => l_Mesg_Token_Tbl
                    , x_return_Status          => l_return_status
                );
                   IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling Perform_Writes'); end if;
                IF l_safety_assoc_rec.TRANSACTION_TYPE = EAM_PROCESS_WO_PVT.G_OPR_CREATE THEN
                  OPEN C;
                  FETCH C INTO l_safety_assoc_id;
                  CLOSE C;
                  l_safety_assoc_rec.SAFETY_ASSOCIATION_ID :=l_safety_assoc_id;
                END IF;
 -- Note: put i instead of 1.
                   EAM_SAFETY_UTILITY_PVT.WRITE_SAFFETY_ASSOCIATION_ROW
                   (  p_safety_association_rec   => l_safety_assoc_rec
                    , p_association_type        =>p_permit_wo_association_tbl(1).association_type
                    , x_mesg_token_Tbl         => l_Mesg_Token_Tbl
                    , x_return_Status          => l_return_status
                  );
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                    RAISE l_wp_association_error;
                  END IF;
             --  END IF;

  /*  exception

          when fnd_api.g_exc_unexpected_error then
           ROLLBACK TO PERMIT_WORK_ORDER_ASSOCIATION;
          --l_token_tbl(1).token_name  := 'Status type';
          --l_token_tbl(1).token_value :=  p_eam_wo_rec.status_type;

          l_out_mesg_token_tbl  := l_mesg_token_tbl;
          EAM_ERROR_MESSAGE_PVT.Add_Error_Token
          (  p_message_name  => 'EAM_PERMIT_WO_STATUS_TYPE'
           , p_token_tbl     => l_token_tbl
           , p_mesg_token_tbl     => l_mesg_token_tbl
           , x_mesg_token_tbl     => l_out_mesg_token_tbl
          );
         l_mesg_token_tbl      := l_out_mesg_token_tbl;

         x_return_status := FND_API.G_RET_STS_ERROR;
         x_mesg_token_tbl := l_mesg_token_tbl ;
         return;
        WHEN l_wp_association_error then
         ROLLBACK TO PERMIT_WORK_ORDER_ASSOCIATION;
        -- l_token_tbl(1).token_name  := 'Object Type';
        --  l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_type;

         l_out_mesg_token_tbl  := l_mesg_token_tbl;
         EAM_ERROR_MESSAGE_PVT.Add_Error_Token
          (  p_message_name  => 'EAM_PERMIT_ASSO_ERROR'
          , p_token_tbl     => l_token_tbl
          , p_mesg_token_tbl     => l_mesg_token_tbl
          , x_mesg_token_tbl     => l_out_mesg_token_tbl
          );
         l_mesg_token_tbl      := l_out_mesg_token_tbl;

         x_return_status := FND_API.G_RET_STS_ERROR;
         x_mesg_token_tbl := l_mesg_token_tbl ;

        return;
        when no_data_found then
         ROLLBACK TO PERMIT_WORK_ORDER_ASSOCIATION;
        -- l_token_tbl(1).token_name  := 'Organization Id';
        -- l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PERMIT_WO_NOT_EXIST'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
       l_mesg_token_tbl      := l_out_mesg_token_tbl;

       x_return_status := FND_API.G_RET_STS_ERROR;
       x_mesg_token_tbl := l_mesg_token_tbl ;
       return;

    end;*/
    END LOOP;
END IF;

x_return_status := l_return_status;

EXCEPTION


      WHEN OTHERS THEN
           /* l_token_tbl(1).token_name  := 'WORKORDER';
            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_POPULATE_REL_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;*/
            ROLLBACK TO PERMIT_WORK_ORDER_ASSOCIATION;
            x_return_status := FND_API.G_RET_STS_ERROR;

END PERMIT_WORK_ORDER_ASSOCIATION;


/********************************************************************
  * Procedure: Raise_Workflow_Events
  * Purpose: This procedure raises the workflow events for work permit release
*********************************************************************/


  PROCEDURE RAISE_WORKFLOW_EVENTS
                              ( p_api_version             IN  NUMBER
                              , p_validation_level        IN  NUMBER
                              , p_eam_wp_rec              IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                              , p_old_eam_wp_rec          IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                              , p_approval_required       IN    BOOLEAN
                              , p_new_system_status       IN    NUMBER
                              , p_workflow_name           IN    VARCHAR2
                              , p_workflow_process        IN   VARCHAR2
                              , x_mesg_token_tbl          IN OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                              , x_return_status           IN OUT NOCOPY VARCHAR2
                              ) IS

                              l_status_pending_event VARCHAR2(240);
                              l_event_name VARCHAR2(240);
                              l_parameter_list   wf_parameter_list_t;
                              l_event_key VARCHAR2(200);
                              l_wf_event_seq NUMBER;
                              l_return_status    VARCHAR2(1);
                              l_err_text      VARCHAR2(2000);
                              l_msg_count     NUMBER;
BEGIN


               l_status_pending_event := 'oracle.apps.eam.permit.status.change.pending';


			--if status change needs approval
     IF( p_approval_required AND (WF_EVENT.TEST(l_status_pending_event) <> 'NONE')) THEN

										      SELECT EAM_SAFETYWORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_pending_event;

										     l_event_key := TO_CHAR(l_wf_event_seq);
										     INSERT INTO EAM_SAFETY_WORKFLOWS
										     (OBJECT_ID,TRANSACTION_ID,WORKFLOW_TYPE,LAST_UPDATE_DATE,LAST_UPDATED_BY,
										     CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)
										     VALUES
										     (p_eam_wp_rec.permit_id,l_wf_event_seq,3,SYSDATE,FND_GLOBAL.user_id,
										     SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id
										     );


										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Permit Released change event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'PERMIT_ID',
													    p_value => TO_CHAR(p_eam_wp_rec.permit_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'PERMIT_NAME',
													    p_value =>p_eam_wp_rec.permit_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(p_eam_wp_rec.organization_id),
													    p_parameterlist => l_parameter_list);
                       Wf_Event.AddParameterToList(p_name =>'NEW_PERMIT_STATUS',
												 	    p_value => TO_CHAR(p_eam_wp_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_eam_wp_rec.STATUS_TYPE),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_PERMIT_STATUS',
													    p_value => TO_CHAR(p_old_eam_wp_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_new_system_status),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(3),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_NAME',
													    p_value => p_workflow_name,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_PROCESS',
													    p_value => p_workflow_process,
													    p_parameterlist => l_parameter_list);
										     Wf_Core.Context('Enterprise Asset Management...','Work Permit Released Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Permit Released Event','After raising event');

		END IF;  --end of check for status change pending event

 EXCEPTION
WHEN OTHERS THEN
		WF_CORE.CONTEXT('Enterprise Asset Management...',l_event_name,'Exception during event construction and raise: ' || SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;

END RAISE_WORKFLOW_EVENTS;


/**************************************************************************
* Procedure:     COPY_WORK_PERMIT
* Purpose:        Procedure to copy work permit record.
*                 This procedure will be called from the public API
***************************************************************************/

PROCEDURE COPY_WORK_PERMIT(
          p_bo_identifier              IN  VARCHAR2 := 'EAM'
         , p_api_version_number        IN  NUMBER   := 1.0
         , p_init_msg_list             IN  BOOLEAN  := FALSE
         , p_commit                    IN  VARCHAR2
         , p_debug                     IN  VARCHAR2
         , p_output_dir                IN  VARCHAR2
         , p_debug_filename            IN  VARCHAR2
         , p_debug_file_mode           IN  VARCHAR2
         , p_org_id                    IN  NUMBER
         , px_permit_id                IN  OUT NOCOPY   NUMBER
         , x_return_status             OUT NOCOPY VARCHAR2
         , x_msg_count                 OUT NOCOPY NUMBER

)IS
          CURSOR C IS SELECT EAM_PERMIT_NAME_S.NEXTVAL FROM SYS.DUAL;
         l_api_name                   CONSTANT VARCHAR2(30) := G_PKG_NAME;
         l_validation_level           NUMBER := EAM_PROCESS_WO_PVT.G_OPR_CREATE;

         l_return_status         VARCHAR2(1);
         l_msg_count             NUMBER;
         l_permit_id             NUMBER:=px_permit_id;
         l_org_id                NUMBER :=p_org_id;
        -- l_permit_name_char           VARCHAR2(240);
         l_permit_name             NUMBER;

         l_work_permit_header_rec EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
         l_out_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;

         /* Error Handling Variables */
          l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ;
          l_error_level           NUMBER :=EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL;
          l_entity_index          NUMBER :=1;

BEGIN

   SAVEPOINT COPY_PERMIT;
   IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Start of copy permit '); end if;
        EAM_PERMIT_UTILITY_PVT.QUERY_ROW
        (  p_work_permit_id   => l_permit_id
           , p_organization_id  => l_org_id
           , x_work_permit_header_rec  => l_work_permit_header_rec
           , x_return_Status           => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
             RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        /*Get the next permit name sequence*/
        OPEN C;
                  FETCH C INTO l_permit_name;
        CLOSE C;

        l_work_permit_header_rec.permit_id :=null;
        l_work_permit_header_rec.permit_name :=to_char(l_permit_name);
        l_work_permit_header_rec.transaction_type :=EAM_PROCESS_WO_PVT.G_OPR_CREATE;
        l_work_permit_header_rec.pending_flag := null;
        l_work_permit_header_rec.completion_date := null;
        l_work_permit_header_rec.approved_by := null;

        IF l_work_permit_header_rec.VALID_FROM < SYSDATE THEN
          l_work_permit_header_rec.VALID_FROM :=SYSDATE;
        END IF;

        IF l_work_permit_header_rec.VALID_TO < SYSDATE THEN
          l_work_permit_header_rec.VALID_TO :=NULL;
        END IF;

      --  IF (l_work_permit_header_rec.STATUS_TYPE =  wip_constants.comp_chrg) THEN
          l_work_permit_header_rec.STATUS_TYPE :=wip_constants.draft;
          l_work_permit_header_rec.USER_DEFINED_STATUS_ID :=wip_constants.draft;
     --   END IF;


  IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling WORK_PERMIT from  PROCESS_WORK_PERMIT'); end if;
          WORK_PERMIT
         (
           p_validation_level        => l_validation_level
          , p_work_permit_id          => l_permit_id
          , p_organization_id	        => l_org_id
          , p_work_permit_header_rec  => l_work_permit_header_rec
          , x_work_permit_header_rec  => l_out_work_permit_header_rec
          , x_mesg_token_tbl          => l_out_Mesg_Token_Tbl
          , x_return_status           => l_return_status
         );

        x_return_status :=l_return_status;

        IF(x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	   		     px_permit_id :=l_out_work_permit_header_rec.permit_id;
			       IF(p_commit = FND_API.G_TRUE) THEN
                        		    COMMIT;
			       END IF;
        END IF;


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => l_out_Mesg_Token_Tbl
                 , p_error_level        => l_error_level
                 , p_entity_index       => l_entity_index
                );
                raise fnd_api.g_exc_unexpected_error;
        END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO COPY_PERMIT;
            x_return_status       := FND_API.G_RET_STS_ERROR;
            x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;
  WHEN OTHERS THEN
       ROLLBACK TO COPY_PERMIT;
       x_return_status       := FND_API.G_RET_STS_ERROR;

END COPY_WORK_PERMIT;

END EAM_PROCESS_PERMIT_PVT;


/
