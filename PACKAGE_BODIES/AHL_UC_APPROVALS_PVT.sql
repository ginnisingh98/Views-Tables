--------------------------------------------------------
--  DDL for Package Body AHL_UC_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_APPROVALS_PVT" AS
/* $Header: AHLVUAPB.pls 120.2 2008/05/05 08:09:25 sathapli ship $ */

  G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_UC_APPROVALS_PVT';

  -- To check if AHL DEBUG is turned ON
  G_DEBUG  VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;

------------------------
-- Define  Procedures --
------------------------
--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : INITIATE_UC_APPROVALS
--  Type              : Private
--  Function          : This procedure is called to initiate the approval process for a Unit
--                      Configuration, once the user submits it for Approvals.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_UC_APPROVALS Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--
--  History:
--      06/02/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE INITIATE_UC_APPROVALS
 (
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN  NUMBER,
  p_object_version_number   IN  NUMBER,
  x_return_status           OUT NOCOPY      VARCHAR2,
  x_msg_count               OUT NOCOPY      NUMBER,
  x_msg_data                OUT NOCOPY      VARCHAR2
 )
 IS
--
--Fetch the node detail information
 CURSOR get_uc_header_det(c_uc_header_id in number,
              c_object_version_number in number)
 IS
    SELECT unit_config_header_id, name, object_version_number,
       unit_config_status_code, active_uc_status_code, parent_uc_header_id
    FROM ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id
        AND object_version_number = c_object_version_number;

--
   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'INITIATE_UC_APPROVALS';

 l_object                       VARCHAR2(30);
 l_approval_type                VARCHAR2(100):='CONCEPT';
 l_active                       VARCHAR2(50):= 'N';
 l_process_name                 VARCHAR2(50);
 l_item_type                    VARCHAR2(50);

 l_return_status                VARCHAR2(50);
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);

 l_activity_id                  NUMBER:=p_uc_header_id;
 l_object_version_number        NUMBER:=p_object_version_number;
 l_uc_header_rec                get_uc_header_det%ROWTYPE;

--
BEGIN
    SAVEPOINT  INITIATE_UC_APPROVALS;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
        AHL_DEBUG_PUB.debug( 'Enter Initiate UC Approvals');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Begin Processing
   --1)Validate uc_header_id is valid
   IF (p_uc_header_id IS NULL OR p_uc_header_id = FND_API.G_MISS_NUM) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
      FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --2) Fetch the uc header details
   OPEN  get_uc_header_det(p_uc_header_id, p_object_version_number);
   FETCH get_uc_header_det into l_uc_header_rec;
   IF (get_uc_header_det%NOTFOUND) THEN
       fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
       fnd_message.set_token('UC_HEADER_ID', p_uc_header_id, false);
       FND_MSG_PUB.add;
       CLOSE get_uc_header_det;
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_uc_header_det;

   --3) Make sure parent header id is null
   IF (l_uc_header_rec.parent_uc_header_id is not null) THEN
         fnd_message.set_name('AHL','AHL_UC_APRV_SUBUNIT');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
   END IF;


   --4) If status is draft or approval rejected
   IF (l_uc_header_rec.unit_config_status_code = 'DRAFT' OR
       l_uc_header_rec.unit_config_status_code = 'APPROVAL_REJECTED') THEN

    l_object := 'UC';

        -- Get the work Flow Process name
        ahl_utility_pvt.get_wf_process_name(
           p_object       =>l_object,
           x_active       =>l_active,
           x_process_name =>l_process_name,
           x_item_type    =>l_item_type,
           x_return_status=>l_return_status,
           x_msg_count    =>l_msg_count,
           x_msg_data     =>l_msg_data);

        IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug(' l_process_name:' || l_process_name);
            AHL_DEBUG_PUB.debug(' l_active:' || l_active);
        END IF;

    --If the approvals WF is turned on
        IF  (l_active='Y' AND l_process_name IS NOT NULL) THEN

             --Approval process started for unit_config_status_code
             UPDATE  ahl_unit_config_headers
               SET unit_config_status_code='APPROVAL_PENDING',
               object_version_number=object_version_number+1
               WHERE unit_config_header_id=p_uc_header_id
               And object_version_number=p_object_version_number;

             IF sql%rowcount=0 THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                    FND_MSG_PUB.ADD;
             ELSE

                ahl_generic_aprv_pvt.START_WF_PROCESS(
                                   P_OBJECT                =>l_object,
                                   P_ACTIVITY_ID           =>l_activity_id,
                                   P_APPROVAL_TYPE         =>l_approval_type,
                                   P_OBJECT_VERSION_NUMBER =>p_object_version_number+1,
                                   P_ORIG_STATUS_CODE      =>'DRAFT',
                                   P_NEW_STATUS_CODE       =>'APPROVED',
                                   P_REJECT_STATUS_CODE    =>'APPROVAL_REJECTED',
                           P_REQUESTER_USERID      => fnd_global.user_id,
                                   P_NOTES_FROM_REQUESTER  =>null,
                                   P_WORKFLOWPROCESS       =>l_process_name,
                                   P_ITEM_TYPE             =>l_item_type);

               END IF;   --end sql%rowcount
          ELSE

         --Not active, push through to complete
             --Approval process started for unit_config_status_code
             UPDATE  ahl_unit_config_headers
               SET unit_config_status_code='APPROVAL_PENDING',
               object_version_number=object_version_number+1
               WHERE unit_config_header_id=p_uc_header_id
               And object_version_number=p_object_version_number;

             IF sql%rowcount=0 THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
         ELSE
               -- Call the Complete UC Approval API
               AHL_UC_APPROVALS_PVT.COMPLETE_UC_APPROVAL
               (
                 p_api_version               =>1.0,
                 p_init_msg_list             =>FND_API.G_TRUE,
                 p_commit                    =>FND_API.G_FALSE,
                 p_validation_level          =>NULL,
                 p_approval_status           =>'APPROVED',
                 p_uc_header_id              =>l_activity_id,
                 p_object_version_number     =>l_object_version_number+1,
                 x_return_status             =>x_return_status,
                 x_msg_count                 =>x_msg_count ,
                 x_msg_data                  =>x_msg_data);

            END IF; --sql%COUNT

      END IF;

      --5) Now for the alternative WF process
      ELSIF ((l_uc_header_rec.unit_config_status_code = 'COMPLETE' OR
              l_uc_header_rec.unit_config_status_code = 'INCOMPLETE') AND
             (l_uc_header_rec.active_uc_status_code = 'UNAPPROVED' OR
              l_uc_header_rec.active_uc_status_code is null) )THEN

        --Active status code WF
    l_object := 'UC_ACTST';

        -- Get the work Flow Process name
        ahl_utility_pvt.get_wf_process_name(
           p_object       =>l_object,
           x_active       =>l_active,
           x_process_name =>l_process_name,
           x_item_type    =>l_item_type,
           x_return_status=>l_return_status,
           x_msg_count    =>l_msg_count,
           x_msg_data     =>l_msg_data);

        IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug(' l_process_name:' || l_process_name);
            AHL_DEBUG_PUB.debug(' l_active:' || l_active);
        END IF;

    --If the approvals WF is turned on
        IF  (l_active='Y' AND l_process_name IS NOT NULL) THEN

            --Approval process started for active_uc_status_code
            UPDATE  ahl_unit_config_headers
                SET active_uc_status_code='APPROVAL_PENDING',
                object_version_number=object_version_number+1
                WHERE unit_config_header_id=p_uc_header_id
                And object_version_number=p_object_version_number;

                IF sql%rowcount=0 THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                    FND_MSG_PUB.ADD;
                ELSE
                    ahl_generic_aprv_pvt.START_WF_PROCESS(
                                   P_OBJECT                =>l_object,
                                   P_ACTIVITY_ID           =>l_activity_id,
                                   P_APPROVAL_TYPE         =>l_approval_type,
                                   P_OBJECT_VERSION_NUMBER =>p_object_version_number+1,
                                   P_ORIG_STATUS_CODE      =>'UNAPPROVED',
                                   P_NEW_STATUS_CODE       =>'APPROVED',
                                   P_REJECT_STATUS_CODE    =>'UNAPPROVED',
                                   P_REQUESTER_USERID      =>fnd_global.user_id,
                                   P_NOTES_FROM_REQUESTER  =>null,
                                   P_WORKFLOWPROCESS       =>l_process_name,
                                   P_ITEM_TYPE             =>l_item_type);
                 END IF; --sql%count;

        ELSE --not active, push through to complete


            --Approval process started for active_uc_status_code
            UPDATE  ahl_unit_config_headers
                SET active_uc_status_code='APPROVAL_PENDING',
                object_version_number=object_version_number+1
                WHERE unit_config_header_id=p_uc_header_id
                And object_version_number=p_object_version_number;

                IF sql%rowcount=0 THEN
                    FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                    FND_MSG_PUB.ADD;
                ELSE

               --Call the complete UC Approvals API
               AHL_UC_APPROVALS_PVT.COMPLETE_UC_APPROVAL
                         (
                            p_api_version               =>1.0,
                            p_init_msg_list             =>FND_API.G_TRUE,
                            p_commit                    =>FND_API.G_FALSE,
                            p_validation_level          =>NULL,
                            p_uc_header_id              =>l_activity_id,
                            p_object_version_number     =>p_object_version_number+1,
                            p_approval_status           =>'APPROVED',
                            x_return_status             =>x_return_status,
                            x_msg_count                 =>x_msg_count,
                            x_msg_data                  =>x_msg_data
                        );

               END IF; --sql%COUNT
          END IF; --end  active_status

   ELSE
    --Not the right status to submit for approvals.
         fnd_message.set_name('AHL','AHL_UC_APRV_IN_PROGRESS');
         fnd_message.set_token('NAME', l_uc_header_rec.name, false);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;

   END IF;


    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count > 0 THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INITIATE_UC_APPROVALS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INITIATE_UC_APPROVALS;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO INITIATE_UC_APPROVALS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END INITIATE_UC_APPROVALS;

--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : COMPLETE_UC_APPROVAL
--  Type              : Private
--  Function          : This procedure is called internally to complete the Approval Process.
--
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_UC_APPROVALS Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--      p_approval_status               IN      VARCHAR2                    Required
--         The approval status of the Unit Configuration after the approval process
--
--  History:
--      06/02/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------
PROCEDURE COMPLETE_UC_APPROVAL(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN  NUMBER,
  p_object_version_number   IN  NUMBER,
  p_approval_status         IN  VARCHAR2,
  x_return_status           OUT NOCOPY      VARCHAR2,
  x_msg_count               OUT NOCOPY      NUMBER,
  x_msg_data                OUT NOCOPY      VARCHAR2

 )
IS

   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'COMPLETE_UC_APPROVAL';

CURSOR get_uc_header_det(c_uc_header_id in number)
 IS
    SELECT unit_config_header_id, name, object_version_number, unit_config_status_code, active_uc_status_code
    FROM ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id;

 l_uc_header_rec                get_uc_header_det%ROWTYPE;
 l_status                       VARCHAR2(30);
 l_evaluation_status            VARCHAR2(1);

 l_return_status                VARCHAR2(50);
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);

 -- SATHAPLI::Bug 7018042, 05-May-2008
 l_uc_status                    VARCHAR2(30);

BEGIN

    SAVEPOINT  COMPLETE_UC_APPROVAL;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug( 'Enter Complete UC Approvals');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin Processing
    --1) Validate uc_header_id
    IF (p_uc_header_id IS NULL OR p_uc_header_id = FND_API.G_MISS_NUM) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
     FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   --2) Validate uc_header_id
    OPEN  get_uc_header_det(p_uc_header_id);
    FETCH get_uc_header_det into l_uc_header_rec;
    IF (get_uc_header_det%NOTFOUND) THEN
        fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
    fnd_message.set_token('UC_HEADER_ID', p_uc_header_id, false);
        FND_MSG_PUB.add;
        CLOSE get_uc_header_det;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_uc_header_det;


  IF ( l_uc_header_rec.unit_config_status_code ='APPROVAL_PENDING' ) THEN

     IF( p_approval_status='APPROVED' ) THEN

       IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> approval_status=APPROVED');
       END IF;

        --call the completeness check API
        AHL_UC_VALIDATION_PUB.check_completeness(
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_TRUE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
        p_unit_header_id                => p_uc_header_id,
        x_evaluation_status             => l_evaluation_status,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

        IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('SQLERRM' || SQLERRM );
                AHL_DEBUG_PUB.debug('l_return_status' || l_return_status);
                AHL_DEBUG_PUB.debug('l_msg_count' || l_msg_count);
                AHL_DEBUG_PUB.debug('l_msg_data' || l_msg_data);
                AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval-->After Completeness Check API call');
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
             AHL_DEBUG_PUB.debug('FAiled Check Completeness API');
             x_msg_count := l_msg_count;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;

        IF ( l_evaluation_status = 'T' ) THEN
            l_status := 'COMPLETE';
        ELSE
            l_status := 'INCOMPLETE';
        END IF;

        --update table and write to history table
        UPDATE ahl_unit_config_headers
        SET unit_config_status_code=l_status,
            active_uc_status_code='APPROVED',
            object_version_number=object_version_number+1
        WHERE unit_config_header_id=p_uc_header_id;

    AHL_UTIL_UC_PKG.COPY_UC_HEADER_TO_HISTORY(p_uc_header_id, x_return_status);

     ELSE

         l_status := 'APPROVAL_REJECTED';
         --update table
         UPDATE ahl_unit_config_headers
         SET unit_config_status_code=l_status,
             object_version_number=object_version_number+1
         WHERE unit_config_header_id=p_uc_header_id;

     END IF; --p_approval_status

  ELSIF ( l_uc_header_rec.active_uc_status_code ='APPROVAL_PENDING' ) THEN

     IF( p_approval_status='APPROVED' ) THEN
        l_status:='APPROVED';
     ELSE
        l_status:='UNAPPROVED';
     END IF; --p_approval_status

     -- SATHAPLI::Bug 7018042, 05-May-2008, Fix start
     -- The UC is in status 'Complete' or 'Incomplete'. Check for the completeness and update the status accordingly.
     AHL_UC_VALIDATION_PUB.check_completeness(
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_TRUE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
        p_unit_header_id                => p_uc_header_id,
        x_evaluation_status             => l_evaluation_status,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
     );

     -- Set the UC status in l_uc_status based on the above API call
     IF ( l_evaluation_status = 'T' ) THEN
         l_uc_status := 'COMPLETE';
     ELSE
         l_uc_status := 'INCOMPLETE';
     END IF;

     --update the active_uc_status_code column and copy to history
     -- Update the unit_config_status_code column as well.
     UPDATE ahl_unit_config_headers
     SET active_uc_status_code=l_status
        ,unit_config_status_code = l_uc_status
     WHERE unit_config_header_id=p_uc_header_id;
     -- SATHAPLI::Bug 7018042, 05-May-2008, Fix end

     AHL_UTIL_UC_PKG.COPY_UC_HEADER_TO_HISTORY(p_uc_header_id, x_return_status);

   END IF; --uc_status_codes

   --End Processing

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0 THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO COMPLETE_UC_APPROVAL;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;


 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO COMPLETE_UC_APPROVAL;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO COMPLETE_UC_APPROVAL;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END COMPLETE_UC_APPROVAL;



--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : INITIATE_QUARANTINE
--  Type              : Private
--  Function          : This procedure is called to initiate the approval process for a Unit
--                      Configuration Quarantine, once the user submits it for Approvals.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_QUARANTINE Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--
--  History:
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE INITIATE_QUARANTINE
 (
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_TRUE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN         NUMBER,
  p_object_version_number   IN         NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 )
 IS

--Fetch the node detail information
 CURSOR get_uc_header_det(c_uc_header_id in number,
              c_object_version_number in number)
 IS
     SELECT unit_config_header_id,
            name,
            object_version_number,
            unit_config_status_code,
            active_uc_status_code,
            parent_uc_header_id
       FROM ahl_unit_config_headers
      WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id
        AND object_version_number = c_object_version_number;

 l_api_version              CONSTANT NUMBER := 1.0;
 l_api_name                 CONSTANT VARCHAR2(30) := 'INITIATE_QUARANTINE';

 l_object                   VARCHAR2(30);
 l_approval_type            VARCHAR2(100):='CONCEPT';
 l_active                   VARCHAR2(50):= 'N';
 l_process_name             VARCHAR2(50);
 l_item_type                VARCHAR2(50);

 l_return_status            VARCHAR2(50);
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);

 l_activity_id              NUMBER:=p_uc_header_id;
 l_object_version_number    NUMBER:=p_object_version_number;
 l_uc_header_rec            get_uc_header_det%ROWTYPE;

BEGIN
    SAVEPOINT  INITIATE_QUARANTINE_SP;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.enable_debug;
       AHL_DEBUG_PUB.debug( 'Enter Initiate UC-ACL Quarantine Approvals');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin Processing
    -- Validate uc_header_id is valid
    IF (p_uc_header_id IS NULL OR p_uc_header_id = FND_API.G_MISS_NUM) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
        FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Fetch the uc header details
    OPEN  get_uc_header_det(p_uc_header_id, p_object_version_number);
     FETCH get_uc_header_det into l_uc_header_rec;
     IF (get_uc_header_det%NOTFOUND) THEN
         fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
         fnd_message.set_token('UC_HEADER_ID', p_uc_header_id, false);
         FND_MSG_PUB.add;
         CLOSE get_uc_header_det;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
    CLOSE get_uc_header_det;

   -- Make sure parent header id is null
    IF (l_uc_header_rec.parent_uc_header_id is not null) THEN
       fnd_message.set_name('AHL','AHL_UC_APRV_SUBUNIT');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'l_uc_header_rec.active_uc_status_code : '||l_uc_header_rec.active_uc_status_code);
       AHL_DEBUG_PUB.debug( 'l_uc_header_rec.active_uc_status_code : '||l_uc_header_rec.unit_config_status_code);
    END IF;

   -- Workflow process to be started only if status is APPROVED.
    IF ((l_uc_header_rec.active_uc_status_code = 'APPROVED') AND
       (l_uc_header_rec.unit_config_status_code IN ('COMPLETE','INCOMPLETE'))) THEN

        l_object := 'UC_ACL';

        -- Get the work Flow Process name
        ahl_utility_pvt.get_wf_process_name(
           p_object       =>l_object,
           x_active       =>l_active,
           x_process_name =>l_process_name,
           x_item_type    =>l_item_type,
           x_return_status=>l_return_status,
           x_msg_count    =>l_msg_count,
           x_msg_data     =>l_msg_data);

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.debug(' l_process_name:' || l_process_name);
           AHL_DEBUG_PUB.debug(' l_active:' || l_active);
        END IF;

        -- Check if the approvals WF is turned on
        IF  (l_active='Y' AND l_process_name IS NOT NULL) THEN

             --Approval process started for unit_config_status_code
             UPDATE ahl_unit_config_headers
                SET active_uc_status_code='APPROVAL_PENDING',
                    unit_config_status_code='QUARANTINE',
                    object_version_number=object_version_number+1
              WHERE unit_config_header_id=p_uc_header_id
                AND object_version_number=p_object_version_number;

             IF sql%rowcount=0 THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                -- To be verified if Error is supposed to be raised here or not.
             ELSE

                ahl_generic_aprv_pvt.START_WF_PROCESS(P_OBJECT                => l_object,
                                                      P_ACTIVITY_ID           => l_activity_id,
                                                      P_APPROVAL_TYPE         => l_approval_type,
                                                      P_OBJECT_VERSION_NUMBER => p_object_version_number+1,
                                                      P_ORIG_STATUS_CODE      => 'APPROVED',
                                                      P_NEW_STATUS_CODE       => 'APPROVED',
                                                      P_REJECT_STATUS_CODE    => 'APPROVAL_REJECTED',
                                                      P_REQUESTER_USERID      => fnd_global.user_id,
                                                      P_NOTES_FROM_REQUESTER  => null,
                                                      P_WORKFLOWPROCESS       => l_process_name,
                                                      P_ITEM_TYPE             => l_item_type);

             END IF;   --end sql%rowcount

        ELSE -- Workflow process is not active, push through to complete

             --Approval process started for unit_config_status_code
             UPDATE ahl_unit_config_headers
                SET active_uc_status_code = 'APPROVAL_PENDING',
                    unit_config_status_code='QUARANTINE',
                    object_version_number=object_version_number+1
              WHERE unit_config_header_id=p_uc_header_id
                And object_version_number=p_object_version_number;

             IF sql%rowcount=0 THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                -- To be verified if Error is supposed to be raised here or not.
             ELSE
               -- Call the Complete UC Approval API
               AHL_UC_APPROVALS_PVT.COMPLETE_QUARANTINE_APPROVAL(p_api_version               =>1.0,
                                                                 p_init_msg_list             =>FND_API.G_TRUE,
                                                                 p_commit                    =>FND_API.G_FALSE,
                                                                 p_validation_level          =>NULL,
                                                                 p_approval_status           =>'APPROVED',
                                                                 p_uc_header_id              =>l_activity_id,
                                                                 p_object_version_number     =>l_object_version_number+1,
                                                                 x_return_status             =>x_return_status,
                                                                 x_msg_count                 =>x_msg_count ,
                                                                 x_msg_data                  =>x_msg_data);
             END IF; --sql%COUNT
        END IF; -- Active Workflow Check
    ELSE --Not the right status to submit for approvals.
        fnd_message.set_name('AHL','AHL_UC_APRV_IN_PROGRESS');
        fnd_message.set_token('UNIT_NAME', l_uc_header_rec.name, false);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF; -- Active Status Check.

    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count > 0 THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INITIATE_QUARANTINE_SP;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INITIATE_QUARANTINE_SP;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO INITIATE_QUARANTINE_SP;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END INITIATE_QUARANTINE;


--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : INITIATE_DEACTIVATE_QUARANTINE
--  Type              : Private
--  Function          : This procedure is called to initiate the approval process for a Unit
--                      Configuration deactivate Quarantine, once the user submits it for Approvals.
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  INITIATE_DEACTIVATE_QUARANTINE Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--
--  History:
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE INITIATE_DEACTIVATE_QUARANTINE
 (
  p_api_version             IN         NUMBER,
  p_init_msg_list           IN         VARCHAR2 := FND_API.G_TRUE,
  p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN         NUMBER,
  p_object_version_number   IN         NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
 )
 IS

--Fetch the node detail information
 CURSOR get_uc_header_det(c_uc_header_id in number,
              c_object_version_number in number)
 IS
     SELECT unit_config_header_id,
            name,
            object_version_number,
            unit_config_status_code,
            active_uc_status_code,
            parent_uc_header_id
       FROM ahl_unit_config_headers
      WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id
        AND object_version_number = c_object_version_number;

 l_api_version              CONSTANT NUMBER := 1.0;
 l_api_name                 CONSTANT VARCHAR2(30) := 'INITIATE_DEACTIVATE_QUARANTINE';

 l_object                   VARCHAR2(30);
 l_approval_type            VARCHAR2(100):='CONCEPT';
 l_active                   VARCHAR2(50):= 'N';
 l_process_name             VARCHAR2(50);
 l_item_type                VARCHAR2(50);

 l_return_status            VARCHAR2(50);
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);

 l_activity_id              NUMBER:=p_uc_header_id;
 l_object_version_number    NUMBER:=p_object_version_number;
 l_uc_header_rec            get_uc_header_det%ROWTYPE;

BEGIN
    SAVEPOINT  INITIATE_QUARANTINE_SP;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.enable_debug;
       AHL_DEBUG_PUB.debug( 'Enter Initiate UC-ACL Deactivate Quarantine Approvals');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin Processing
    -- Validate uc_header_id is valid
    IF (p_uc_header_id IS NULL OR p_uc_header_id = FND_API.G_MISS_NUM) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
        FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Fetch the uc header details
    OPEN  get_uc_header_det(p_uc_header_id, p_object_version_number);
     FETCH get_uc_header_det into l_uc_header_rec;
     IF (get_uc_header_det%NOTFOUND) THEN
         fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
         fnd_message.set_token('UC_HEADER_ID', p_uc_header_id, false);
         FND_MSG_PUB.add;
         CLOSE get_uc_header_det;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
    CLOSE get_uc_header_det;

   -- Make sure parent header id is null
    IF (l_uc_header_rec.parent_uc_header_id is not null) THEN
       fnd_message.set_name('AHL','AHL_UC_APRV_SUBUNIT');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Workflow process to be started only if status is APPROVED.
    IF ((l_uc_header_rec.active_uc_status_code = 'APPROVED') AND
        (l_uc_header_rec.unit_config_status_code = 'QUARANTINE')) THEN

        l_object := 'UC_ACL';

        -- Get the work Flow Process name
        ahl_utility_pvt.get_wf_process_name(
           p_object       =>l_object,
           x_active       =>l_active,
           x_process_name =>l_process_name,
           x_item_type    =>l_item_type,
           x_return_status=>l_return_status,
           x_msg_count    =>l_msg_count,
           x_msg_data     =>l_msg_data);

        IF G_DEBUG = 'Y' THEN
           AHL_DEBUG_PUB.debug(' l_process_name:' || l_process_name);
           AHL_DEBUG_PUB.debug(' l_active:' || l_active);
        END IF;

        -- Check if the approvals WF is turned on
        IF  (l_active='Y' AND l_process_name IS NOT NULL) THEN

             --Approval process started for unit_config_status_code
             UPDATE ahl_unit_config_headers
                SET active_uc_status_code='APPROVAL_PENDING',
                    unit_config_status_code='DEACTIVATE_QUARANTINE',
                    object_version_number=object_version_number+1
              WHERE unit_config_header_id=p_uc_header_id
                AND object_version_number=p_object_version_number;

             IF sql%rowcount=0 THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                -- To be verified if Error is supposed to be raised here or not.
             ELSE

                ahl_generic_aprv_pvt.START_WF_PROCESS(P_OBJECT                => l_object,
                                                      P_ACTIVITY_ID           => l_activity_id,
                                                      P_APPROVAL_TYPE         => l_approval_type,
                                                      P_OBJECT_VERSION_NUMBER => p_object_version_number+1,
                                                      P_ORIG_STATUS_CODE      => 'APPROVED',
                                                      P_NEW_STATUS_CODE       => 'APPROVED',
                                                      P_REJECT_STATUS_CODE    => 'APPROVAL_REJECTED',
                                                      P_REQUESTER_USERID      => fnd_global.user_id,
                                                      P_NOTES_FROM_REQUESTER  => null,
                                                      P_WORKFLOWPROCESS       => l_process_name,
                                                      P_ITEM_TYPE             => l_item_type);

               END IF;   --end sql%rowcount

        ELSE -- Workflow process is not active, push through to complete

             --Approval process started for unit_config_status_code
             UPDATE ahl_unit_config_headers
                SET active_uc_status_code = 'APPROVAL_PENDING',
                    unit_config_status_code='DEACTIVATE_QUARANTINE',
                    object_version_number=object_version_number+1
              WHERE unit_config_header_id=p_uc_header_id
                And object_version_number=p_object_version_number;

             IF sql%rowcount=0 THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                -- To be verified if Error is supposed to be raised here or not.
             ELSE
               -- Call the Complete UC Approval API
               AHL_UC_APPROVALS_PVT.COMPLETE_QUARANTINE_APPROVAL(p_api_version               =>1.0,
                                                                 p_init_msg_list             =>FND_API.G_TRUE,
                                                                 p_commit                    =>FND_API.G_FALSE,
                                                                 p_validation_level          =>NULL,
                                                                 p_approval_status           =>'APPROVED',
                                                                 p_uc_header_id              =>l_activity_id,
                                                                 p_object_version_number     =>l_object_version_number+1,
                                                                 x_return_status             =>x_return_status,
                                                                 x_msg_count                 =>x_msg_count ,
                                                                 x_msg_data                  =>x_msg_data);
             END IF; --sql%COUNT
        END IF; -- Active Workflow Check
    ELSE --Not the right status to submit for approvals.
        fnd_message.set_name('AHL','AHL_UC_APRV_IN_PROGRESS');
        fnd_message.set_token('UNIT_NAME', l_uc_header_rec.name, false);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF; -- Active Status Check.

    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count > 0 THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INITIATE_QUARANTINE_SP;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INITIATE_QUARANTINE_SP;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO INITIATE_QUARANTINE_SP;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END INITIATE_DEACTIVATE_QUARANTINE;

--------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : COMPLETE_QUARANTINE_APPROVAL
--  Type              : Private
--  Function          : This procedure is called internally to complete the Approval Process.
--
--  Pre-reqs          :
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  COMPLETE_QUARANTINE_APPROVAL Parameters :
--      p_uc_header_id                  IN      NUMBER                      Required
--         The header identifier of the Unit Configuration.
--      p_object_version_number         IN      NUMBER                      Required
--         The object version number of the Unit Configuration.
--      p_approval_status               IN      VARCHAR2                    Required
--         The approval status of the Unit Configuration after the approval process
--
--  History:
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------
PROCEDURE COMPLETE_QUARANTINE_APPROVAL(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_uc_header_id            IN  NUMBER,
  p_object_version_number   IN  NUMBER,
  p_approval_status         IN  VARCHAR2,
  x_return_status           OUT NOCOPY      VARCHAR2,
  x_msg_count               OUT NOCOPY      NUMBER,
  x_msg_data                OUT NOCOPY      VARCHAR2
 )
IS

   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'COMPLETE_QUARANTINE_APPROVAL';

CURSOR get_uc_header_det(c_uc_header_id in number)
 IS
    SELECT unit_config_header_id,
           name,
           object_version_number,
           unit_config_status_code,
           active_uc_status_code
    FROM ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id;

 l_uc_header_rec                get_uc_header_det%ROWTYPE;
 l_status                       VARCHAR2(30);
 l_evaluation_status            VARCHAR2(1);

 l_return_status                VARCHAR2(50);
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);


BEGIN
    SAVEPOINT  COMPLETE_Q_APPROVAL_SP;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug( 'Enter Complete UC Approvals');
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> check for Valid UC');
    END IF;

    -- Begin Processing
    --1) Validate if uc_header_id is passed.
    IF (p_uc_header_id IS NULL OR p_uc_header_id = FND_API.G_MISS_NUM) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
        FND_MESSAGE.set_token('PROCEDURE', G_PKG_NAME);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> UC is Valid 1 ');
    END IF;

   --2) Validate uc_header_id passed is valid
    OPEN  get_uc_header_det(p_uc_header_id);
        FETCH get_uc_header_det into l_uc_header_rec;
            IF (get_uc_header_det%NOTFOUND) THEN
                fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
                fnd_message.set_token('UC_HEADER_ID', p_uc_header_id, false);
                FND_MSG_PUB.add;
                CLOSE get_uc_header_det;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
    CLOSE get_uc_header_det;

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> UC is Valid 2 ');
    END IF;


    IF ((l_uc_header_rec.unit_config_status_code = 'QUARANTINE' AND p_approval_status='APPROVED') OR
        (l_uc_header_rec.unit_config_status_code = 'DEACTIVATE_QUARANTINE' AND p_approval_status='APPROVAL_REJECTED')) THEN

           l_status := 'QUARANTINE';

           IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> l_status 2 : '||l_status);
           END IF;


    ELSIF ((l_uc_header_rec.unit_config_status_code = 'QUARANTINE' AND p_approval_status = 'APPROVAL_REJECTED') OR
             (l_uc_header_rec.unit_config_status_code = 'DEACTIVATE_QUARANTINE' AND p_approval_status='APPROVED')) THEN

            IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> approval_status=APPROVED');
            END IF;

            --call the completeness check API
            AHL_UC_VALIDATION_PUB.check_completeness(
            p_api_version                   => 1.0,
            p_init_msg_list                 => FND_API.G_TRUE,
            p_commit                        => FND_API.G_FALSE,
            p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
            p_unit_header_id                => p_uc_header_id,
            x_evaluation_status             => l_evaluation_status,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data
            );

            IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('SQLERRM' || SQLERRM );
                    AHL_DEBUG_PUB.debug('l_return_status' || l_return_status);
                    AHL_DEBUG_PUB.debug('l_msg_count' || l_msg_count);
                    AHL_DEBUG_PUB.debug('l_msg_data' || l_msg_data);
                    AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval-->After Completeness Check API call');
            END IF;

            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
                 AHL_DEBUG_PUB.debug('Failed Check Completeness API');
                 x_msg_count := l_msg_count;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            END IF;

            IF ( l_evaluation_status = 'T' ) THEN
                l_status := 'COMPLETE';
            ELSE
                l_status := 'INCOMPLETE';
            END IF;

           IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> l_status 3 : '||l_status);
           END IF;
    END IF;

    --update table and write to history table
    BEGIN

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> Before Update');
        END IF;

        UPDATE ahl_unit_config_headers
        SET unit_config_status_code=l_status,
            active_uc_status_code='APPROVED',
            object_version_number=object_version_number+1
        WHERE unit_config_header_id=p_uc_header_id;

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> After Update');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.debug('Unexpected Error during Update');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> Before History');
    END IF;

    AHL_UTIL_UC_PKG.COPY_UC_HEADER_TO_HISTORY(p_uc_header_id, x_return_status);

    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'UC: AHL_UC_APPROVALS_PVT.complete_uc_approval--> After History');
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count > 0 THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO COMPLETE_Q_APPROVAL_SP;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;


 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO COMPLETE_Q_APPROVAL_SP;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO COMPLETE_Q_APPROVAL_SP;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  l_api_name,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
    END IF;

END COMPLETE_QUARANTINE_APPROVAL;

END AHL_UC_APPROVALS_PVT;

/
