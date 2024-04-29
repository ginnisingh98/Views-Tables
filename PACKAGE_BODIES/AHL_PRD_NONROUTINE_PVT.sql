--------------------------------------------------------
--  DDL for Package Body AHL_PRD_NONROUTINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_NONROUTINE_PVT" AS
/* $Header: AHLVPNRB.pls 120.10.12010000.10 2010/03/23 10:25:36 manesing ship $ */

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'AHL_PRD_NONROUTINE_PVT';
  G_DEBUG              VARCHAR2(1)  := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');
-----------------------------------
--   Declare Local Procedures    --
-----------------------------------

-- Convert value to id
  PROCEDURE Convert_val_to_id(
    p_x_sr_task_rec  IN OUT  NOCOPY    AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
    x_return_status  OUT     NOCOPY    VARCHAR2
  );

-- Default and validate the parameters
  PROCEDURE Default_and_validate_param(
    p_x_sr_task_rec  IN OUT  NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
    p_module_type    IN VARCHAR2,
    x_return_status  OUT     NOCOPY    VARCHAR2
  );

-- Create Service Request
  PROCEDURE Create_sr(
    p_x_sr_task_rec  IN OUT  NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
    x_return_status  OUT     NOCOPY    VARCHAR2
  );

-- MR NR ER -- start
PROCEDURE  Process_Mr(
      p_x_task_tbl      IN OUT NOCOPY sr_task_tbl_type,
      p_mr_assoc_tbl    IN OUT NOCOPY MR_Association_tbl_type,
      p_module_type     IN            VARCHAR2,
      x_return_status   OUT NOCOPY    VARCHAR2,
      x_msg_count       OUT NOCOPY    NUMBER,
      x_msg_data        OUT NOCOPY    VARCHAR2
);

PROCEDURE  Copy_Mr_Details(
   p_mr_assoc_tbl            IN OUT NOCOPY MR_Association_tbl_type,
   p_x_sr_mr_association_tbl IN OUT NOCOPY AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type,
   p_sr_table_index             IN NUMBER
);
-- MR NR ER -- end

-- Create VWP Task
  PROCEDURE Create_task(
    p_x_task_tbl     IN OUT  NOCOPY ahl_prd_nonroutine_pvt.sr_task_tbl_type,
    x_return_status  OUT     NOCOPY    VARCHAR2
  );

-- Update Service Request
  PROCEDURE Update_sr(
    p_x_sr_task_rec  IN OUT  NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
    x_return_status  OUT     NOCOPY    VARCHAR2
  );

-- Get Message Token
  PROCEDURE get_msg_token(
    p_wo_id            IN          Number,
    p_instance_id      IN          Number,
    x_wo_name          OUT NOCOPY  VARCHAR2,
    x_instance_number  OUT NOCOPY  VARCHAR2
  );

-- Get Note and note detail from Message.
  Procedure get_note_value(p_sr_task_rec IN         AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
                         x_note          OUT NOCOPY VARCHAR2,
                         x_note_detail   OUT NOCOPY VARCHAR2
  );
-- procedure to write the input parameters to log
  Procedure write_to_log(p_sr_tasK_tbl IN ahl_prd_nonroutine_pvt.sr_task_tbl_type
  );
-- procedure to write the SR API input parameters to log
Procedure write_sr_to_log
(
  p_service_request_rec   IN CS_SERVICEREQUEST_PUB.service_request_rec_type,
  p_notes_table           IN CS_SERVICEREQUEST_PUB.notes_table,
  p_contacts_table        IN CS_SERVICEREQUEST_PUB.contacts_table
);

-- Define global variables here.
-- SR status id for status PLANNED
G_SR_PLANNED_STATUS_ID    CONSTANT NUMBER := 52;

-- SR status id for status OPEN
G_SR_OPEN_STATUS_ID    CONSTANT NUMBER := 1;

--------------------------------------
-- End Local Procedures Declaration --
--------------------------------------

--------------------------------------------------------------------
--  Procedure name    : Process_nonroutine_job
--  Type              : Private
--  Function          : To Create or Update Service request based on
--                      operation_type and to create vwp task for
--                      a nonroutine job.
--  Parameters        :
--
--  Standard IN  Parameters :
--      p_api_version               IN     NUMBER     Required
--      p_init_msg_list             IN     VARCHAR2   Default  FND_API.G_FALSE
--      p_commit                    IN     VARCHAR2   Default  FND_API.G_FALSE
--      p_validation_level          IN     NUMBER     Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   IN     VARCHAR2   Default  FND_API.G_TRUE
--      p_module_type               IN     VARCHAR2   Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status             OUT    VARCHAR2   Required
--      x_msg_count                 OUT    NUMBER     Required
--      x_msg_data                  OUT    VARCHAR2   Required
--
--  Process_nonroutine_job Parameters:
--      p_x_sr_task_tbl             IN OUT  Sr_task_tbl_type  Required
--        The table of records for creation / updation of Service
--        request and creation of vwp task.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Process_nonroutine_job (
  p_api_version          IN            NUMBER,
  p_init_msg_list        IN            VARCHAR2  := Fnd_Api.g_false,
  p_commit               IN            VARCHAR2  := Fnd_Api.g_false,
  p_validation_level     IN            NUMBER    := Fnd_Api.g_valid_level_full,
  p_module_type          IN            VARCHAR2  := 'JSP',
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_x_sr_task_tbl        IN OUT NOCOPY ahl_prd_nonroutine_pvt.sr_task_tbl_type,
  p_x_mr_asso_tbl        IN OUT NOCOPY AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type
)
IS
  l_api_name          CONSTANT  VARCHAR2(30)    := 'PROCESS_NONROUTINE_JOB';
  l_api_version       CONSTANT  NUMBER          := 1.0;
  l_return_status               VARCHAR2(3);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_sr_task_rec                 ahl_prd_nonroutine_pvt.sr_task_rec_type;
  l_err_msg_count               NUMBER;
  l_convert_validate_status     VARCHAR2(3);
  l_sr_status_id  NUMBER;
  -- Removing this cursor as status_code is obsoleted as per the update from SR Team and we should use
  -- incident_status_id directly. - Balaji
  /*
  -- Begin Changes Vasu For SR Integration
  CURSOR cs_sr_status IS
    SELECT incident_status_id FROM
    cs_incident_statuses
    WHERE status_code = 'PLANNED'
    AND incident_subtype = 'INC'
    AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
    AND trunc(nvl(end_date_active,sysdate));

  -- End Changes Vasu for SR Integration
  */
-- NR MR ER - start
CURSOR c_get_sr_details(p_incident_id NUMBER)
IS
SELECT object_version_number
FROM CS_INCIDENTS
WHERE incident_id = p_incident_id;
-- NR MR ER - end

-- FP for ER 5716489 -- start
-- Cursor to fetch the workorder details .
CURSOR c_does_wo_exist (p_incident_id NUMBER)
IS
  SELECT
  wo.workorder_id,
  wo.status_code
  FROM
  ahl_visit_tasks_b vtsk,
  ahl_workorders wo,
  ahl_unit_effectivities_b ue
  WHERE
  ue.cs_incident_id = p_incident_id
  AND ue.unit_effectivity_id = vtsk.unit_effectivity_id
  AND vtsk.visit_task_id = wo.visit_task_id
  AND upper(vtsk.task_type_code) = 'SUMMARY';

  l_does_wo_exist             c_does_wo_exist%ROWTYPE;
-- FP for ER 5716489 -- end

BEGIN

-- Standard start of API savepoint
  SAVEPOINT AHL_PROCESS_NONROUTINE_JOB_PVT;

-- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

-- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Enable Debug.
  IF (G_DEBUG = 'Y') THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

-- Add debug mesg.
  IF (G_DEBUG = 'Y') THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || l_api_name);
  END IF;

--------------------------------------------------------------------------------
-- Clear id's if the module type is 'JSP'.
-- Call value to id conversion and default_and_validate_param procedure.
-- If defaulting is successfully then call create service request
-- and create task api if operation_type  is 'CREATE'  else
-- call update service request if operation_type is 'UPDATE'
--------------------------------------------------------------------------------
  IF ( p_x_sr_task_tbl.COUNT > 0) THEN

    -- Call write to log procedure to log the input parameter
    -- values for debug
    IF (G_DEBUG = 'Y') THEN
      write_to_log(p_sr_tasK_tbl => p_x_sr_task_tbl);
      AHL_DEBUG_PUB.debug('INPUT - module_type :'||p_module_type);
    END IF;


    l_convert_validate_status := FND_API.G_RET_STS_SUCCESS;

    FOR i IN p_x_sr_task_tbl.FIRST..p_x_sr_task_tbl.LAST LOOP

    -- Add the logic

      l_sr_task_rec := p_x_sr_task_tbl(i);

      IF upper(p_module_type) = 'JSP' THEN

        IF upper(l_sr_task_rec.operation_type) = 'CREATE' THEN

          l_sr_task_rec.type_id         := FND_API.G_MISS_NUM;
          l_sr_task_rec.severity_id     := FND_API.G_MISS_NUM;
          l_sr_task_rec.urgency_id      := FND_API.G_MISS_NUM;
          --problem code lov is modified to return problem_code instead of meaning
          --for bug #4729005. Hence no need to convert value to id.
          --l_sr_task_rec.problem_code    := FND_API.G_MISS_CHAR;
          -- NR MR ER -- start
          --l_sr_task_rec.resolution_code := FND_API.G_MISS_CHAR;
          -- NR MR ER -- end
          l_sr_task_rec.visit_id        := FND_API.G_MISS_NUM;
          l_sr_task_rec.instance_id     := FND_API.G_MISS_NUM;

        ELSIF upper(l_sr_task_rec.operation_type) = 'UPDATE' THEN

          l_sr_task_rec.urgency_id      := FND_API.G_MISS_NUM;
          --problem code lov is modified to return problem_code instead of meaning
          --for bug #4729005. Hence no need to convert value to id.
          --l_sr_task_rec.problem_code    := FND_API.G_MISS_CHAR;
          -- NR MR ER -- start
          --l_sr_task_rec.resolution_code := FND_API.G_MISS_CHAR;
          -- NR MR ER -- end
        END IF;

      END IF;

      IF (G_DEBUG = 'Y') THEN
        AHL_DEBUG_PUB.debug('PROC : Calling Convert_val_to_id procedure');
      END IF;

      -- Call value to id conversion
      Convert_val_to_id( p_x_sr_task_rec => l_sr_task_rec,
                         x_return_status => l_return_status);

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_convert_validate_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF (G_DEBUG = 'Y') THEN
        AHL_DEBUG_PUB.debug('PROC : Calling Default_and_validate_param procedure');
      END IF;

      -- Call the Default and validate param procedure
      Default_and_validate_param( p_x_sr_task_rec => l_sr_task_rec,
                                  p_module_type => p_module_type,
                                  x_return_status => l_return_status);

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_convert_validate_status := FND_API.G_RET_STS_ERROR;
      END IF;

      p_x_sr_task_tbl(i) := l_sr_task_rec;

    END LOOP;

    -- Check For Errors.
    IF( l_convert_validate_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR i IN p_x_sr_task_tbl.FIRST..p_x_sr_task_tbl.LAST LOOP

      l_sr_task_rec := p_x_sr_task_tbl(i);

      IF ( upper(l_sr_task_rec.operation_type) = 'CREATE') THEN

        IF (G_DEBUG = 'Y') THEN
          AHL_DEBUG_PUB.debug('PROC : Calling the Create SR procedure');
        END IF;

        -- Call Create Service Request procedure

        Create_sr( p_x_sr_task_rec => l_sr_task_rec,
                   x_return_status => l_return_status);


        IF ( upper(l_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSIF ( upper(l_sr_task_rec.operation_type) = 'UPDATE' ) THEN

        IF (G_DEBUG = 'Y') THEN
          AHL_DEBUG_PUB.debug('PROC : Calling the Update SR procedure');
        END IF;

        -- Call Update Service Request procedure
        -- MR NR ER -- start
        IF p_module_type IS NULL OR p_module_type <> 'SR_OA' THEN
              Update_sr( p_x_sr_task_rec => l_sr_task_rec,
                           x_return_status => l_return_status);

              IF ( upper(l_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

                  -- JKJain, Bug 8540538 start

              END IF; -- MR NR ER -- end

              -- FP for ER 5716489 -- start
              --- If the mode is update , then check if the NR has a corresponding workorder created or not
              -- and set the flags accordingly .

              --1. Query if the NR has a workorder created !

              OPEN c_does_wo_exist(l_sr_task_rec.Incident_id);
              FETCH c_does_wo_exist INTO l_does_wo_exist;
              CLOSE c_does_wo_exist;

              --2. Check if a workorder exists for the NR
              IF ( l_does_wo_exist.workorder_id  IS NOT NULL ) THEN

                        -- Set the p_x_task_tbl(i).WO_Create_flag to Y
                        l_sr_task_rec.WO_Create_flag := 'Y';

                        --Check the Status of the workorder and set the p_x_sr_task_tbl(i).WO_Release_flag
                        IF ( l_does_wo_exist.status_code = '3') THEN
                            l_sr_task_rec.WO_Release_flag := 'Y';
                        ELSE
                            l_sr_task_rec.WO_Release_flag := 'N';
                        END IF;
              ELSE
                        -- If the workorder Id is null, ie; a work order does nt exist for the NR
                        -- Set the he p_x_task_tbl(i).WO_Create_flag to N
                        l_sr_task_rec.WO_Create_flag := 'N';
              END IF;
               -- FP for ER 5716489 -- end
         -- JKJain, Bug 8540538 end
      END IF;

      p_x_sr_task_tbl(i) := l_sr_task_rec;

    END LOOP;

    -- initialize stack if any warning messages from CS APIs exist.
    IF (FND_MSG_PUB.count_msg > 0) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- NR MR ER -- start
    /*
    IF (G_DEBUG = 'Y') THEN
          AHL_DEBUG_PUB.debug('PROC : Calling the Create Task procedure');
    END IF;

    -- call  Create VWP Task Api

    Create_task( p_x_task_tbl    => p_x_sr_task_tbl,
                 x_return_status => l_return_status);

    l_msg_count := FND_MSG_PUB.count_msg;

    IF ( upper(l_return_status) <> FND_API.G_RET_STS_SUCCESS or l_msg_count>0) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */
    -- NR MR ER - End

    -- NR MR ER - start
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(
          fnd_log.level_statement,
          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
          'p_x_mr_asso_tbl.COUNT ->'||p_x_mr_asso_tbl.COUNT
      );
    END IF;

    IF (
          upper(l_sr_task_rec.operation_type) = 'CREATE'
          OR
          (
            upper(l_sr_task_rec.operation_type) = 'UPDATE'
            AND
            p_x_mr_asso_tbl.COUNT > 0
          )
       )
    THEN
            Process_Mr(
              p_x_task_tbl      =>      p_x_sr_task_tbl,
              p_mr_assoc_tbl    =>      p_x_mr_asso_tbl,
              p_module_type     =>      p_module_type,
              x_return_status   =>      x_return_status,
              x_msg_count       =>      x_msg_count,
              x_msg_data        =>      x_msg_data
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(
                    fnd_log.level_statement,
                    'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                    'After calling Process_Mr...Return status->'||x_return_status
                );
            END IF;

            IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Bug # 8267142 (FP for KAL Bug # 7667326) -- start
            IF ( p_x_sr_task_tbl.COUNT > 0) THEN

                FOR l_sr_count IN p_x_sr_task_tbl.FIRST..p_x_sr_task_tbl.LAST LOOP

                   OPEN c_get_sr_details(p_x_sr_task_tbl(l_sr_count).Incident_id);
                   FETCH c_get_sr_details  INTO p_x_sr_task_tbl(l_sr_count).Incident_object_version_number;
                   CLOSE c_get_sr_details;

                END LOOP;

            END IF;
            -- Bug # 8267142 (FP for KAL Bug # 7667326) -- end
     END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(
          fnd_log.level_statement,
          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
          'After Process_Mr API'
      );
    END IF;
    -- NR MR ER - end

    --   Modified by VSUNDARA For SR Integration
    ---  Change the SR STATUS as Planned
    -- Removing the code as status_code is obsoleted as per the update from SR Team and we should use
    -- incident_status_id directly. - Balaji
   /*
   OPEN cs_sr_status;
   FETCH cs_sr_status INTO l_sr_status_id;
   IF ( cs_sr_status%NOTFOUND) THEN
       FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_STATUS_ERROR');
       Fnd_Msg_Pub.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   */

   l_sr_status_id := G_SR_PLANNED_STATUS_ID;

   FOR i IN p_x_sr_task_tbl.FIRST..p_x_sr_task_tbl.LAST LOOP

      l_sr_task_rec := p_x_sr_task_tbl(i);

      IF ( upper(l_sr_task_rec.operation_type) = 'CREATE') THEN

        -- FP for ER 5716489 -- start
        -- Do not call the update SR Api in cases where a non-routine is created without workorder .
        IF (nvl(upper(l_sr_task_rec.WO_Create_flag),'Y') = 'Y')
        THEN

              l_sr_task_rec.Status_id := l_sr_status_id;
              -- NR MR ER -- start
              --l_sr_task_rec.incident_object_version_number := 1 ;
              OPEN c_get_sr_details(l_sr_task_rec.Incident_id);
              FETCH c_get_sr_details INTO l_sr_task_rec.incident_object_version_number;
              CLOSE c_get_sr_details;

              -- NR MR ER -- end
              IF (G_DEBUG = 'Y') THEN
                 AHL_DEBUG_PUB.debug('PROC : Calling the Update SR procedure');
              END IF;
                -- Call Update Service Request procedure
              Update_sr( p_x_sr_task_rec => l_sr_task_rec,
                       x_return_status => l_return_status);

              IF ( upper(l_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
            RAISE FND_API.G_EXC_ERROR;
              END IF;

         END IF;
         -- FP for ER 5716489 -- end

             IF(( l_sr_task_rec.object_id  IS NOT NULL AND l_sr_task_rec.object_id <> FND_API.G_MISS_NUM )
                   AND (l_sr_task_rec.object_type = 'AHL_PRD_DISP')) THEN

                   AHL_PRD_DISP_UTIL_PVT.Create_SR_Disp_Link (

                     p_api_version           => 1.0,
                     p_init_msg_list         => FND_API.G_TRUE,
                     p_commit                => FND_API.G_FALSE,
                     p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status         => x_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
                     p_service_request_id    => l_sr_task_rec.incident_id,
                     p_disposition_id        => l_sr_task_rec.object_id,
                     x_link_id               => l_sr_task_rec.link_id
                   );

          IF ( upper(l_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
               RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF ;
        END IF;

    END LOOP;




    --  END Changes




  END IF;

  -- initialize stack if any warning messages from CS APIs exist.
  IF (FND_MSG_PUB.count_msg > 0) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  IF (G_DEBUG = 'Y') THEN
    AHL_DEBUG_PUB.debug('END - Successfully completion of '||G_PKG_NAME||'.'||l_api_name||' API ');
  END IF;

  -- Count and Get messages
  FND_MSG_PUB.count_and_get
  ( p_encoded   => fnd_api.g_false,
    p_count     => x_msg_count,
    p_data      => x_msg_data
  );

  -- Disable debug (if enabled)
  IF (G_DEBUG = 'Y') THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to AHL_PROCESS_NONROUTINE_JOB_PVT;
    FND_MSG_PUB.count_and_get( p_count   => x_msg_count,
                               p_data    => x_msg_data,
                               p_encoded => fnd_api.g_false);

    -- Disable debug
    IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to AHL_PROCESS_NONROUTINE_JOB_PVT;
    FND_MSG_PUB.count_and_get( p_count   => x_msg_count,
                               p_data    => x_msg_data,
                               p_encoded => fnd_api.g_false);

    -- Disable debug
    IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to AHL_PROCESS_NONROUTINE_JOB_PVT;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Nonroutine_Job',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count   => x_msg_count,
                               p_data    => x_msg_data,
                               p_encoded => fnd_api.g_false);

    -- Disable debug
    IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END Process_nonroutine_job;

--------------------------------------------
-- Local Procedure Definitions follow     --
--------------------------------------------
--------------------------------------------
-- Convert value to id                    --
--------------------------------------------

----------------------------------------------
-- Convert_val_to_id procedure will convert
-- values to id's only if the id's are null
----------------------------------------------
PROCEDURE Convert_val_to_id(
  p_x_sr_task_rec  IN OUT NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
  x_return_status  OUT NOCOPY    VARCHAR2
) IS

  l_customer_id      NUMBER;
  l_customer_name    VARCHAR2(360);
  l_contact_id       NUMBER;
  l_contact_name     VARCHAR2(360);

  CURSOR sr_problem_code (p_meaning IN VARCHAR2) IS
    SELECT lookup_code FROM fnd_lookup_values_vl
    WHERE lookup_type = 'REQUEST_PROBLEM_CODE'
    AND  enabled_flag = 'Y'
    AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
    AND trunc(nvl(end_date_active,sysdate))
    AND upper(meaning) = upper(p_meaning);

  CURSOR sr_resolution_code (p_meaning IN VARCHAR2) IS
    SELECT lookup_code FROM fnd_lookup_values_vl
    WHERE lookup_type = 'REQUEST_RESOLUTION_CODE'
    AND  enabled_flag = 'Y'
    AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
    AND trunc(nvl(end_date_active,sysdate))
    AND upper(meaning) = upper(p_meaning);

  CURSOR sr_customer_product(p_instance_number IN VARCHAR2) IS
    SELECT instance_id FROM csi_item_instances
    WHERE instance_number = p_instance_number;

  CURSOR ahl_visit(p_visit_number IN NUMBER) IS
    SELECT visit_id FROM ahl_visits_b
    WHERE visit_number = p_visit_number;
-- Begin Changes by VSUNDARA
-- TO validate the Instance Owner
   CURSOR ahl_instance_owner(p_instance_number IN VARCHAR2) IS
     SELECT OWNER_PARTY_ID
     FROM csi_item_instances
     WHERE instance_number = p_instance_number;
-- END Changes

  -- added to fix bug# 8265902
  CURSOR get_status_id (p_status_name IN VARCHAR2) IS
     SELECT incident_status_id
     FROM cs_incident_statuses_vl
     WHERE incident_subtype = 'INC'
       AND UPPER(name) = UPPER(p_status_name)
       AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
       AND TRUNC(NVL(end_date_active, SYSDATE))
       AND rownum<2;

  l_status_id NUMBER;

BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( upper(p_x_sr_task_rec.operation_type) = 'CREATE' ) THEN

    -- added to fix bug# 8265902
    IF ((p_x_sr_task_rec.status_id is null or p_x_sr_task_rec.status_id = FND_API.G_MISS_NUM) and
        (p_x_sr_task_rec.status_name is not null AND p_x_sr_task_rec.status_name <> FND_API.G_MISS_CHAR)) THEN
           OPEN get_status_id(p_x_sr_task_rec.status_name);
           FETCH get_status_id INTO l_status_id;
           IF (get_status_id%FOUND) THEN
             p_x_sr_task_rec.status_id := l_status_id;
           END IF;
           CLOSE get_status_id;
    END IF;

-- Derive the Customer id, if its null.
-- If customer id is not null derive the customer name and id
-- and check the customer name against the input value, if <>
-- return error msg. If only customer name is passed then
-- derive the customer id and name.

    IF( p_x_sr_task_rec.customer_id is not null and
        p_x_sr_task_rec.customer_id <> FND_API.G_MISS_NUM
        and (p_x_sr_task_rec.customer_name is not null and
             p_x_sr_task_rec.customer_name <> FND_API.G_MISS_CHAR)) THEN
       BEGIN
          Select party_name
          into
            l_customer_name
          from hz_parties
          where party_id
                = p_x_sr_task_rec.customer_id;

          IF (l_customer_name <> nvl(p_x_sr_task_rec.customer_name,l_customer_name) and
              (p_x_sr_task_rec.customer_name <> FND_API.G_MISS_CHAR) ) THEN
            Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_NAME_MISMATCH');
            Fnd_Message.SET_TOKEN('CUST_NAME',p_x_sr_task_rec.customer_name);
            Fnd_Message.SET_TOKEN('CUST_ID',p_x_sr_task_rec.customer_id);
            Fnd_Msg_Pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_ID_INVALID');
          Fnd_Message.SET_TOKEN('CUST_ID',p_x_sr_task_rec.customer_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_ID_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CUST_ID',p_x_sr_task_rec.customer_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;


    ELSIF ( (p_x_sr_task_rec.customer_id is null or
             p_x_sr_task_rec.customer_id = FND_API.G_MISS_NUM)
             and (p_x_sr_task_rec.customer_name is not null and
                  p_x_sr_task_rec.customer_name <> FND_API.G_MISS_CHAR)) THEN

        BEGIN
          Select party_id
          into
             l_customer_id
          from hz_parties
          where party_name = p_x_sr_task_rec.customer_name;
          p_x_sr_task_rec.customer_id     := l_customer_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_NAME_INVALID');
          Fnd_Message.SET_TOKEN('CUST_NAME',p_x_sr_task_rec.customer_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_NAME_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CUST_NAME',p_x_sr_task_rec.customer_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
    -- NR MR ER - start
    -- Balaji added following elseif clause to explicitly pass null to
    -- SR API so that appropriate error msg is thrown.
    -- Part of ER # 5550702
    ELSIF  p_x_sr_task_rec.customer_name is null THEN

          p_x_sr_task_rec.customer_id      := NULL;

    END IF;
    -- NR MR ER - end



-- Derive the Contact id, if its null and contact type in
-- 'RELATIONSHIP' or 'PERSON'.
-- If contact id is not null derive the contact name and id
-- and check the contact name against the input value, if <>
-- return error msg. If only contact name is passed then
-- derive the contact id and name.

    IF (upper(p_x_sr_task_rec.contact_type) in ('PARTY_RELATIONSHIP','PERSON')) THEN

      IF( p_x_sr_task_rec.contact_id is not null and
          p_x_sr_task_rec.contact_id <> FND_API.G_MISS_NUM
          and ( p_x_sr_task_rec.contact_name is not null and
                p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR )) THEN
        BEGIN
          Select party_name
          into
            l_contact_name
          from hz_parties
          where party_id
                = p_x_sr_task_rec.contact_id;


        IF(l_contact_name <> nvl(p_x_sr_task_rec.contact_name,l_contact_name) and
           (p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR) )THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_MISMATCH');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_INVALID');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;


      ELSIF ( (p_x_sr_task_rec.contact_id is null or
               p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM)
             and ( p_x_sr_task_rec.contact_name is not null and
                   p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR )) THEN

        BEGIN
          Select party_id
          into
             l_contact_id
          from hz_parties
          where party_name = p_x_sr_task_rec.contact_name;

          p_x_sr_task_rec.contact_id      := l_contact_id;


        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_INVALID');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
    -- NR MR ER -- start
    -- Balaji added following elseif clause to explicitly pass null to
    -- SR API so that appropriate error msg is thrown.
    -- Part of MR NR ER
      ELSIF  p_x_sr_task_rec.contact_name is null THEN

          p_x_sr_task_rec.contact_id      := NULL;

      END IF;
    -- NR MR ER -- end

    END IF;

-- Derive the Contact id, if its null and contact type
-- 'EMPLOYEE'.
-- If contact id is not null derive the contact name and id
-- and check the contact name against the input value, if <>
-- return error msg. If only contact name is passed then
-- derive the contact id and name.

    IF (upper(p_x_sr_task_rec.contact_type) = 'EMPLOYEE') THEN

      IF( p_x_sr_task_rec.contact_id is not null and
          p_x_sr_task_rec.contact_id <> FND_API.G_MISS_NUM
          and ( p_x_sr_task_rec.contact_name is not null and
                p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR )) THEN
        BEGIN
          Select full_name
          into
            l_contact_name
          from per_people_f
          where person_id
                = p_x_sr_task_rec.contact_id
          and trunc(sysdate) between trunc(nvl(effective_start_date,sysdate))
          and trunc(nvl(effective_end_date,sysdate));


        IF(l_contact_name <> nvl(p_x_sr_task_rec.contact_name,l_contact_name) and
           (p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR) ) THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_MISMATCH');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_INVALID');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;


      ELSIF ( (p_x_sr_task_rec.contact_id is null or
               p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM)
             and ( p_x_sr_task_rec.contact_name is not null and
                   p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR )) THEN

        BEGIN
          Select person_id
          into
             l_contact_id
          from per_people_f
          where full_name = p_x_sr_task_rec.contact_name
          and trunc(sysdate) between trunc(nvl(effective_start_date,sysdate))
          and trunc(nvl(effective_end_date,sysdate));

          p_x_sr_task_rec.contact_id      := l_contact_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_INVALID');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
       -- NR MR ER -- start
    -- Balaji added following elseif clause to explicitly pass null to
    -- SR API so that appropriate error msg is thrown.
    -- Part of NR MR ER.
      ELSIF  p_x_sr_task_rec.contact_name is null THEN

          p_x_sr_task_rec.contact_id      := NULL;

      END IF;
      -- NR MR ER -- end
    END IF;


    -- Derive the visit id from visit number
    IF ((p_x_sr_task_rec.visit_id is null or
        p_x_sr_task_rec.visit_id = FND_API.G_MISS_NUM) and
        p_x_sr_task_rec.visit_number is not null) THEN

      OPEN ahl_visit(p_x_sr_task_rec.visit_number);
      FETCH ahl_visit INTO p_x_sr_task_rec.visit_id;
      CLOSE ahl_visit;

    END IF;


    -- Derive the instance id from instance number
    IF ((p_x_sr_task_rec.instance_id is null or
         p_x_sr_task_rec.instance_id = FND_API.G_MISS_NUM) and
         p_x_sr_task_rec.instance_number is not null ) THEN

      OPEN sr_customer_product(p_x_sr_task_rec.instance_number);
      FETCH sr_customer_product INTO p_x_sr_task_rec.instance_id;
      CLOSE sr_customer_product;

    END IF;


    -- Derive the problem code from problem meaning
    IF ((p_x_sr_task_rec.problem_code is null or
         p_x_sr_task_rec.problem_code = FND_API.G_MISS_CHAR) and
         p_x_sr_task_rec.problem_meaning is not null ) THEN

      OPEN sr_problem_code(p_x_sr_task_rec.problem_meaning);
      FETCH sr_problem_code INTO p_x_sr_task_rec.problem_code;
      CLOSE sr_problem_code;

      -- NR MR ER - start
      -- Balaji added following check to throw appropriate
      -- error message if invalid problem code is entered.
      -- SR API doesnt throw any error if the problem code is invalid neither
      -- it updates invalid value. Hence throwing error explicitly
      -- Part of NR MR ER.
      IF p_x_sr_task_rec.problem_code IS NULL THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_PROBLEM_CODE_INVALID');
          Fnd_Message.SET_TOKEN('CODE',p_x_sr_task_rec.problem_meaning);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      -- NR MR ER - end

    END IF;


    -- Derive the resolution code from resolution meaning.
    IF ((p_x_sr_task_rec.resolution_code is null or
         p_x_sr_task_rec.resolution_code = FND_API.G_MISS_CHAR) and
         p_x_sr_task_rec.resolution_meaning is not null ) THEN

      OPEN sr_resolution_code(p_x_sr_task_rec.resolution_meaning);
      FETCH sr_resolution_code INTO p_x_sr_task_rec.resolution_code;
      CLOSE sr_resolution_code;

      -- NR MR ER -- start
      -- Balaji added following check to throw appropriate
      -- error message if invalid resolution code is entered.
      -- SR API doesnt throw any error if the resolution code is invalid neither
      -- it updates invalid value. Hence throwing error explicitly
      -- Part of NR MR ER
      IF p_x_sr_task_rec.resolution_code IS NULL THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_RESL_CODE_INV');
          Fnd_Message.SET_TOKEN('CODE',p_x_sr_task_rec.resolution_meaning);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      -- NR MR ER -- end

    END IF;



  ELSIF ( upper(p_x_sr_task_rec.operation_type) = 'UPDATE') THEN


-- Derive the Contact id, if its null and contact type in
-- 'RELATIONSHIP' or 'PERSON'.
-- If contact id is not null derive the contact name and id
-- and check the contact name against the input value, if <>
-- return error msg. If only contact name is passed then
-- derive the contact id and name.

    IF (upper(p_x_sr_task_rec.contact_type) in ('PARTY_RELATIONSHIP','PERSON')) THEN

      IF( p_x_sr_task_rec.contact_id is not null and
          p_x_sr_task_rec.contact_id <> FND_API.G_MISS_NUM
          and ( p_x_sr_task_rec.contact_name is not null and
                p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR )) THEN
        BEGIN
          Select  party_name
          into
            l_contact_name
          from hz_parties
          where party_id
                = p_x_sr_task_rec.contact_id;

        IF(l_contact_name <> nvl(p_x_sr_task_rec.contact_name,l_contact_name) and
           (p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR) )THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_MISMATCH');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_INVALID');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;


      ELSIF ( (p_x_sr_task_rec.contact_id is null or
               p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM)
             and ( p_x_sr_task_rec.contact_name is not null and
                   p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR )) THEN

        BEGIN
          Select party_id
          into
             l_contact_id
          from hz_parties
          where party_name = p_x_sr_task_rec.contact_name;

          p_x_sr_task_rec.contact_id      := l_contact_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_INVALID');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
      -- NR MR ER -- start
      -- Balaji added following elseif clause to explicitly pass null to
      -- SR API so that appropriate error msg is thrown.
      -- Part of NR MR ER.
      ELSIF  p_x_sr_task_rec.contact_name is null THEN

          p_x_sr_task_rec.contact_id      := NULL;

      END IF;
      -- NR MR ER -- end

    END IF;


-- Derive the Contact id, if its null and contact type
-- 'EMPLOYEE'.
-- If contact id is not null derive the contact name and id
-- and check the contact name against the input value, if <>
-- return error msg. If only contact name is passed then
-- derive the contact id and name.

    IF (upper(p_x_sr_task_rec.contact_type) = 'EMPLOYEE') THEN

      IF( p_x_sr_task_rec.contact_id is not null and
          p_x_sr_task_rec.contact_id <> FND_API.G_MISS_NUM
         and ( p_x_sr_task_rec.contact_name is not null and
               p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR)) THEN
        BEGIN
          Select  full_name
          into
            l_contact_name
          from per_people_f
          where person_id
                = p_x_sr_task_rec.contact_id
          and trunc(sysdate) between trunc(nvl(effective_start_date,sysdate))
          and trunc(nvl(effective_end_date,sysdate));

        IF(l_contact_name <> nvl(p_x_sr_task_rec.contact_name,l_contact_name) and
           (p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR) )THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_MISMATCH');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_INVALID');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_ID_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_ID',p_x_sr_task_rec.contact_id);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;


      ELSIF ( (p_x_sr_task_rec.contact_id is null or
               p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM)
             and ( p_x_sr_task_rec.contact_name is not null and
                   p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR)) THEN

        BEGIN
          Select person_id
          into
             l_contact_id
          from per_people_f
          where full_name = p_x_sr_task_rec.contact_name
          and trunc(sysdate) between trunc(nvl(effective_start_date,sysdate))
          and trunc(nvl(effective_end_date,sysdate));

          p_x_sr_task_rec.contact_id      := l_contact_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_INVALID');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN TOO_MANY_ROWS THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_NAME_NOT_UNIQUE');
          Fnd_Message.SET_TOKEN('CONT_NAME',p_x_sr_task_rec.contact_name);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END;
      -- NR MR ER -- start
      -- Balaji added following elseif clause to explicitly pass null to
      -- SR API so that appropriate error msg is thrown.
      -- Part of NR MR ER.
      ELSIF  p_x_sr_task_rec.contact_name is null THEN

          p_x_sr_task_rec.contact_id      := NULL;

      END IF;
      -- NR MR ER -- end

    END IF;


    -- Derive the problem code from problem meaning.
    IF ((p_x_sr_task_rec.problem_code is null or
         p_x_sr_task_rec.problem_code = FND_API.G_MISS_CHAR) and
         p_x_sr_task_rec.problem_meaning is not null ) THEN

      OPEN sr_problem_code(p_x_sr_task_rec.problem_meaning);
      FETCH sr_problem_code INTO p_x_sr_task_rec.problem_code;
      CLOSE sr_problem_code;

      -- NR MR ER -- start
      -- Balaji added following check to throw appropriate
      -- error message if invalid problem code is entered.
      -- SR API doesnt throw any error if the problem code is invalid neither
      -- it updates invalid value. Hence throwing error explicitly
      -- Part of NR MR ER.
      IF p_x_sr_task_rec.problem_code IS NULL THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_PROBLEM_CODE_INVALID');
          Fnd_Message.SET_TOKEN('CODE',p_x_sr_task_rec.problem_meaning);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      -- NR MR ER -- end

    END IF;

    -- Derive the resolution code from resolution meaning.
    IF ((p_x_sr_task_rec.resolution_code is null or
         p_x_sr_task_rec.resolution_code = FND_API.G_MISS_CHAR) and
         p_x_sr_task_rec.resolution_meaning is not null ) THEN

      OPEN sr_resolution_code(p_x_sr_task_rec.resolution_meaning);
      FETCH sr_resolution_code INTO p_x_sr_task_rec.resolution_code;
      CLOSE sr_resolution_code;

      -- NR MR ER -- start
      -- Balaji added following check to throw appropriate
      -- error message if invalid resolution code is entered.
      -- SR API doesnt throw any error if the resolution code is invalid neither
      -- it updates invalid value. Hence throwing error explicitly
      -- Part of NR MR ER
      IF p_x_sr_task_rec.resolution_code IS NULL THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_RESL_CODE_INV');
          Fnd_Message.SET_TOKEN('CODE',p_x_sr_task_rec.resolution_meaning);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      -- NR MR ER -- end

    END IF;

    -- NR MR ER -- start
    -- Balaji added the code for OGMA ER (Adding MRs to Non-Routine)
    -- Begin
    -- Derive the visit id from visit number
    IF ((p_x_sr_task_rec.visit_id is null or
        p_x_sr_task_rec.visit_id = FND_API.G_MISS_NUM) and
        p_x_sr_task_rec.visit_number is not null) THEN

      OPEN ahl_visit(p_x_sr_task_rec.visit_number);
      FETCH ahl_visit INTO p_x_sr_task_rec.visit_id;
      CLOSE ahl_visit;

    END IF;
    -- NR MR ER -- end

  END IF;

END Convert_val_to_id;


--------------------------------------------
-- Default and validate the parameters
--------------------------------------------

------------------------------------------------------------
-- Default_and_validate_param procedure checks if
-- required id's/values are passed, If not will derive
-- from profile. If the profile values are null then
-- it will either default the values or return an
-- error message and status.
------------------------------------------------------------
PROCEDURE Default_and_validate_param(
  p_x_sr_task_rec  IN OUT NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
  p_module_type    IN VARCHAR2,
  x_return_status  OUT NOCOPY    VARCHAR2
) IS

  l_incident_status_id   NUMBER;
  l_employee_id          NUMBER;
  dummy                  VARCHAR2(3);
  l_wo_name              VARCHAR2(80);
  l_instance_num         VARCHAR2(30);
  l_quantity             NUMBER; --amsriniv. ER 6014567
  l_owner_id             NUMBER;
  l_return_status        VARCHAR2(1);
  l_dummy                VARCHAR2(1); --amsriniv. ER 6014567

  -- Removing cursor cs_sr_status as status_code is obsoleted as per the update from SR Team
  -- and we should use incident_status_id directly. - Balaji
  /*
  CURSOR cs_sr_status IS
    SELECT incident_status_id FROM
    cs_incident_statuses
    WHERE status_code = 'OPEN'
    AND incident_subtype = 'INC'
    AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
    AND trunc(nvl(end_date_active,sysdate));
  */

  CURSOR cs_sr_severity_validate(p_severity_id IN NUMBER) IS
    SELECT csv.incident_severity_id
    FROM cs_incident_severities_vl csv,
    mfg_lookups mfl
    WHERE csv.incident_severity_id = p_severity_id
    AND mfl.lookup_type = 'WIP_EAM_ACTIVITY_PRIORITY'
    AND trunc(sysdate) between trunc(nvl(csv.start_date_active,sysdate))
    AND trunc(nvl(csv.end_date_active,sysdate));

  CURSOR default_contact IS
    SELECT employee_id
    FROM fnd_user
    WHERE user_id = fnd_global.user_id;

  CURSOR default_customer_type IS
    SELECT party_type
    FROM hz_parties
    WHERE party_id = fnd_profile.value('AHL_PRD_SR_CUSTOMER_NAME');

-- Changes made by  by VSUNDARA For SR Integration
   CURSOR  default_party_id(p_item_instance_number IN NUMBER) IS
    SELECT OWNER_PARTY_ID
    FROM csi_item_instances
    WHERE instance_id = p_item_instance_number;

  CURSOR owner_customer_type(p_cust_id IN NUMBER) IS
    SELECT party_type
    FROM hz_parties
    WHERE party_id = p_cust_id;


-- End Changes

--amsriniv ER 6014567 Begin
CURSOR check_inst_nonserial(c_instance_id IN NUMBER, c_workorder_id IN NUMBER) IS
    SELECT 'X'
    FROM mtl_system_items_b mtl, csi_item_instances csi
    WHERE csi.instance_id = c_instance_id
    AND csi.inventory_item_id = mtl.inventory_item_id
    AND mtl.organization_id = (SELECT organization_id from wip_discrete_jobs wdj, ahl_workorders awo where wdj.wip_entity_id = awo.wip_entity_id and awo.workorder_id = c_workorder_id)
    AND mtl.serial_number_control_code = 1;

CURSOR validate_quantity(c_instance_id IN NUMBER, c_wo_id IN NUMBER) IS
    SELECT csi.quantity
    FROM    CSI_ITEM_INSTANCES csi,
            ahl_workorders wo
    WHERE   csi.instance_id = c_instance_id
        AND csi.wip_job_id  = WO.WIP_ENTITY_ID
        AND wo.workorder_id = c_wo_id
        AND csi.location_type_code = 'WIP'
        AND not exists (select 'x' from csi_ii_relationships
                        where subject_id = csi.instance_id
                        AND RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
                        AND TRUNC(NVL(ACTIVE_START_DATE, SYSDATE)) <= TRUNC(SYSDATE)
                        AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1))  > TRUNC(SYSDATE));
--amsriniv ER 6014567 End

BEGIN

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (upper(p_x_sr_task_rec.operation_type) = 'CREATE') THEN


    -- Check if instance id is not null. If instance id
    -- is null then return error message.
    IF (p_x_sr_task_rec.instance_id is null or p_x_sr_task_rec.instance_id = FND_API.G_MISS_NUM) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_INSTANCE_VALUE_REQ');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- If originating work order id is null then
    -- return an error message.
    IF (p_x_sr_task_rec.originating_wo_id is null or p_x_sr_task_rec.originating_wo_id = FND_API.G_MISS_NUM) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_TASK_ORG_WOID_REQ');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- bachandr added following validation for Bug # 6447467 (Base ER # 5571440)
    -- Bug # 6447467 -- start
    -- Check if resolution_meaning is not null. If resolution_meaning
    -- is null then return error message.

    IF ( nvl(fnd_profile.value('AHL_SR_RESL_CODE_COMP'), 'N') = 'Y') THEN

            IF ( p_x_sr_task_rec.resolution_meaning IS NULL OR
                 p_x_sr_task_rec.resolution_meaning = FND_API.G_MISS_CHAR) THEN

               Fnd_Message.SET_NAME('AHL','AHL_PRD_RESL_CODE_REQ');
               Fnd_Msg_Pub.ADD;
               RAISE FND_API.G_EXC_ERROR;

            END IF;
    END IF;
    -- Bug # 6447467 -- End

    -- Get message tokens
    --
    get_msg_token ( p_wo_id           => p_x_sr_task_rec.originating_wo_id,
                    p_instance_id     => p_x_sr_task_rec.instance_id,
                    x_wo_name         => l_wo_name,
                    x_instance_number => l_instance_num);


    -- rroy
    -- ACL Changes
    l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_x_sr_task_rec.originating_wo_id,
                                                       p_ue_id => NULL,
                                                       p_visit_id => NULL,
                                                       p_item_instance_id => NULL);
    IF l_return_status = FND_API.G_TRUE THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_CRT_SR_UNTLCKD');
        FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- rroy
    -- ACL Changes

    -- If type id is null then derive it
    -- from profile. If profile value is null then
    -- return an error message

    IF ((p_x_sr_task_rec.type_id is null or p_x_sr_task_rec.type_id = FND_API.G_MISS_NUM)and
        (p_x_sr_task_rec.type_name is null or p_x_sr_task_rec.type_name = FND_API.G_MISS_CHAR)) THEN
      IF (fnd_profile.value('AHL_PRD_SR_TYPE') is not null) THEN
          p_x_sr_task_rec.type_id := fnd_profile.value('AHL_PRD_SR_TYPE');
          p_x_sr_task_rec.type_name := fnd_profile.value('AHL_PRD_SR_TYPE');
      ELSE
        Fnd_Message.SET_NAME('AHL','AHL_PRD_SR_TYPE_REQ');
        Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
        Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
        Fnd_Msg_Pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;


    -- If status is null then derive it from profile.
    -- If profile value is null then default it to OPEN.
    IF ((p_x_sr_task_rec.status_id is null or p_x_sr_task_rec.status_id = FND_API.G_MISS_NUM)and
        (p_x_sr_task_rec.status_name is null or p_x_sr_task_rec.status_name = FND_API.G_MISS_CHAR)) THEN

      IF (fnd_profile.value('AHL_PRD_SR_STATUS') is not null) THEN
        p_x_sr_task_rec.status_id := fnd_profile.value('AHL_PRD_SR_STATUS');
      ELSE
        -- Removing cursor cs_sr_status as status_code is obsoleted as per the update from SR Team
        -- and we should use incident_status_id directly. - Balaji.
        /*
        OPEN cs_sr_status;
        IF( cs_sr_status%NOTFOUND) THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_SR_STATUS_DEFAULT_ERR');
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          FETCH cs_sr_status INTO p_x_sr_task_rec.status_id;
        END IF;

        CLOSE cs_sr_status;
        */
        p_x_sr_task_rec.status_id := G_SR_OPEN_STATUS_ID;
      END IF;
    END IF;


    -- If severity is null then derive it from profile.
    -- If profile value is null then return an error message.
    IF ((p_x_sr_task_rec.severity_id is null or p_x_sr_task_rec.severity_id = FND_API.G_MISS_NUM)and
        (p_x_sr_task_rec.severity_name is null or p_x_sr_task_rec.severity_name = FND_API.G_MISS_CHAR)) THEN

      IF (fnd_profile.value('AHL_PRD_SR_SEVERITY') is not null) THEN
        p_x_sr_task_rec.severity_id := fnd_profile.value('AHL_PRD_SR_SEVERITY');

    -- Validate the severity value
        OPEN cs_sr_severity_validate(p_x_sr_task_rec.severity_id);

        IF ( cs_sr_severity_validate%NOTFOUND) THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_SR_SEVERITY_INVALID');
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        CLOSE cs_sr_severity_validate;
      ELSE
        Fnd_Message.SET_NAME('AHL','AHL_PRD_SR_SEVERITY_REQ');
        Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
        Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
        Fnd_Msg_Pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

    -- Default incident date to sysdate if
    -- request date is null
    IF (p_x_sr_task_rec.request_date is null or
        p_x_sr_task_rec.request_date = FND_API.G_MISS_DATE) THEN

      p_x_sr_task_rec.request_date := sysdate;

      -- modified to default based on workorder scheduled start date to fix bug# 7697685 .
      IF ((nvl(UPPER(p_x_sr_task_rec.WO_Create_flag),'Y') = 'Y') AND
          (p_x_sr_task_rec.workorder_start_time IS NOT NULL AND
           p_x_sr_task_rec.workorder_start_time <> FND_API.G_MISS_DATE) AND
           p_x_sr_task_rec.workorder_start_time < sysdate ) THEN
              p_x_sr_task_rec.request_date := p_x_sr_task_rec.workorder_start_time;
      END IF;

    END IF;


    -- If summary is null then return an
    -- error message.
    IF (p_x_sr_task_rec.summary is null or p_x_sr_task_rec.summary = FND_API.G_MISS_CHAR) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_SUMMARY_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


    -- If duration is null then derive it from profile.
    -- If profile value is null then default it to 1.
    IF (p_x_sr_task_rec.duration is null or p_x_sr_task_rec.duration = FND_API.G_MISS_NUM) THEN

      IF ( fnd_profile.value('AHL_PRD_TASK_EST_DURATION')  is not null) THEN
         p_x_sr_task_rec.duration := fnd_profile.value('AHL_PRD_TASK_EST_DURATION');
      ELSE
        p_x_sr_task_rec.duration := 1;
      END IF;
    END IF;

   -- Changes made by VSUNDARA For SR Integration
     IF (p_x_sr_task_rec.customer_id  IS NULL or p_x_sr_task_rec.customer_id = FND_API.G_MISS_NUM ) THEN
        OPEN default_party_id(p_x_sr_task_rec.instance_id);
        FETCH default_party_id INTO p_x_sr_task_rec.customer_id ;
       --Just to Check
         Select party_name
         into
         p_x_sr_task_rec.customer_name
          from hz_parties
          where party_id = p_x_sr_task_rec.customer_id;
       IF ( default_party_id%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_CUST_ERROR');
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',null);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
       OPEN owner_customer_type(p_x_sr_task_rec.customer_id);
       FETCH owner_customer_type INTO p_x_sr_task_rec.customer_type;
        IF ( owner_customer_type%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_CUST_ERROR'); -- Customer Type is Invalid
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        CLOSE owner_customer_type;
        -- Defalut contact is Same
        OPEN default_contact;
        FETCH default_contact INTO p_x_sr_task_rec.contact_id;
        IF ( default_contact%NOTFOUND ) THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_CONT_ERROR');
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          p_x_sr_task_rec.contact_type := 'EMPLOYEE';
        END IF;

        CLOSE default_contact;

    ELSE
      --- Validation of the Customer ID with Owner of the Instance
        OPEN default_party_id(p_x_sr_task_rec.instance_id);
        FETCH default_party_id INTO l_owner_id ;
        IF(  l_owner_id <> nvl(p_x_sr_task_rec.customer_id,l_owner_id) and
           (p_x_sr_task_rec.contact_name <> FND_API.G_MISS_CHAR) )THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRD_INVALID_OWNER'); -- New Error Message Should be added
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

  --- End Changes

    -- If Customer id and Contact id is null then
    -- Derive the Customer info from Profile and
    -- Contact info from fnd_user.user_id
    IF ((p_x_sr_task_rec.customer_id  IS NULL or p_x_sr_task_rec.customer_id = FND_API.G_MISS_NUM ) and
        (p_x_sr_task_rec.contact_id   IS NULL or p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM)) THEN
      IF ( fnd_profile.value('AHL_PRD_SR_CUSTOMER_NAME') is not null ) THEN

        OPEN default_customer_type;
        FETCH default_customer_type INTO p_x_sr_task_rec.customer_type;

        IF ( default_customer_type%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_CUST_ERROR');
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          p_x_sr_task_rec.customer_id := fnd_profile.value('AHL_PRD_SR_CUSTOMER_NAME');
        END IF;

        CLOSE default_customer_type;

        OPEN default_contact;
        FETCH default_contact INTO p_x_sr_task_rec.contact_id;
        IF ( default_contact%NOTFOUND ) THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_CONT_ERROR');
          Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
          Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
          p_x_sr_task_rec.contact_type := 'EMPLOYEE';
        END IF;

        CLOSE default_contact;

      ELSE

        Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_PROFILE_REQ');
        Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
        Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
        Fnd_Msg_Pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

    END IF;


    -- If Customer id is not null but Customer type is
    -- null then return an error message.
    IF (p_x_sr_task_rec.customer_id is not null and
        (p_x_sr_task_rec.customer_type is null or p_x_sr_task_rec.customer_type = FND_API.G_MISS_CHAR)) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_CUST_TYPE_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


    -- If Contact id is not null but Contact type is
    -- null then return an error message.
    IF (p_x_sr_task_rec.contact_id is not null and
        (p_x_sr_task_rec.contact_type is null or p_x_sr_task_rec.contact_type = FND_API.G_MISS_CHAR)) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_TYPE_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


    -- If Customer value is not null but Contact
    -- is null then return an error message.
    IF (p_x_sr_task_rec.customer_id is not null and
        (p_x_sr_task_rec.contact_id is null or p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM)) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_CONTACT_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    -- If Contact is not null but Customer is null then
    -- return an error message.
    ELSIF((p_x_sr_task_rec.customer_id is null or p_x_sr_task_rec.customer_id = FND_API.G_MISS_NUM) and
          p_x_sr_task_rec.contact_id is not null ) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_CUSTOMER_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


    -- If visit id is null then return an error
    -- message.
    IF (p_x_sr_task_rec.visit_id is null or p_x_sr_task_rec.visit_id = FND_API.G_MISS_NUM) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_VISIT_VALUE_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
--amsriniv. Issue 105. Begin ER 6014567
     IF (p_x_sr_task_rec.instance_quantity IS NOT NULL AND p_x_sr_task_rec.instance_quantity <= 0) THEN
         Fnd_Message.SET_NAME('AHL','AHL_POSITIVE_TSK_QTY');
         Fnd_Msg_Pub.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

    IF (upper(p_x_sr_task_rec.WO_Create_flag) = 'N') THEN
        OPEN check_inst_nonserial(p_x_sr_task_rec.Instance_id, p_x_sr_task_rec.originating_wo_id);
        FETCH check_inst_nonserial INTO l_dummy;
        IF (check_inst_nonserial%FOUND) THEN
          Fnd_Message.SET_NAME('AHL','AHL_NO_CREATE_WO_NONSER');
          Fnd_Message.SET_TOKEN('FIELD',l_instance_num);
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE check_inst_nonserial;
    END IF;

    IF (nvl(upper(p_x_sr_task_rec.move_qty_to_nr_workorder),'N') = 'Y') THEN
        IF (upper(p_x_sr_task_rec.WO_Create_flag) = 'Y' and upper(p_x_sr_task_rec.WO_Release_flag) = 'Y') THEN
            OPEN validate_quantity(p_x_sr_task_rec.Instance_id , p_x_sr_task_rec.originating_wo_id);
            FETCH validate_quantity INTO l_quantity;
            IF (validate_quantity%NOTFOUND) THEN
                Fnd_Message.SET_NAME('AHL','AHL_INST_NOT_ISSUED');
                Fnd_Message.SET_TOKEN('INS_NUM',l_instance_num);
                Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
                Fnd_Msg_Pub.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF (l_quantity < p_x_sr_task_rec.instance_quantity) THEN
                Fnd_Message.SET_NAME('AHL','AHL_INST_NOT_AVAIL');
                Fnd_Message.SET_TOKEN('INS_NAME',l_instance_num);
                Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
                Fnd_Message.SET_TOKEN('QUANT_USER',TO_CHAR(p_x_sr_task_rec.instance_quantity));
                Fnd_Message.SET_TOKEN('QUANT_AVAIL',TO_CHAR(l_quantity));
                Fnd_Msg_Pub.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        ELSE
            Fnd_Message.SET_NAME('AHL','AHL_NR_WO_NOT_RELEASED');
            Fnd_Msg_Pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
--amsriniv. Issue 105. End ER 6014567

  ELSIF(upper(p_x_sr_task_rec.operation_type) = 'UPDATE') THEN


    -- bachandr added following validation for Bug # 6447467 (Base ER # 5571440)
    -- Bug # 6447467 -- start
    -- Check if resolution_meaning is not null. If resolution_meaning
    -- is null then return error message.

    IF ( nvl(fnd_profile.value('AHL_SR_RESL_CODE_COMP'), 'N') = 'Y') THEN

          IF ( p_x_sr_task_rec.resolution_meaning IS NULL OR
               p_x_sr_task_rec.resolution_meaning = FND_API.G_MISS_CHAR) THEN

                 Fnd_Message.SET_NAME('AHL','AHL_PRD_RESL_CODE_REQ');
                 Fnd_Msg_Pub.ADD;
                 RAISE FND_API.G_EXC_ERROR;

           END IF;
    END IF;
    -- Bug # 6447467 -- end

    -- Get message tokens
    --
    get_msg_token ( p_wo_id           => p_x_sr_task_rec.originating_wo_id,
                    p_instance_id     => p_x_sr_task_rec.instance_id,
                    x_wo_name         => l_wo_name,
                    x_instance_number => l_instance_num);

    -- rroy
    -- ACL Changes
    l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_x_sr_task_rec.originating_wo_id,
                                                       p_ue_id => NULL,
                                                       p_visit_id => NULL,
                                                       p_item_instance_id => NULL);
    IF l_return_status = FND_API.G_TRUE THEN
       FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_UPD_SR_UNTLCKD');
       FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- rroy
    -- ACL Changes

    IF p_module_type IS NULL OR p_module_type <> 'SR_OA' THEN

            -- If contact id is null then return an
            -- error message.
            IF (p_x_sr_task_rec.contact_id is null or p_x_sr_task_rec.contact_id = FND_API.G_MISS_NUM) THEN

              Fnd_Message.SET_NAME('AHL','AHL_PRD_CONTACT_REQ');
              Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
              Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
              Fnd_Msg_Pub.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

            END IF;


            -- If Contact type is null then return an error
            -- message.
            IF (p_x_sr_task_rec.contact_id is not null and
                (p_x_sr_task_rec.contact_type is null or p_x_sr_task_rec.contact_type = FND_API.G_MISS_CHAR)) THEN

              Fnd_Message.SET_NAME('AHL','AHL_PRD_CONT_TYPE_REQ');
              Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
              Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
              Fnd_Msg_Pub.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

            END IF;


            -- If status is null then return an
            -- error message.
            IF ((p_x_sr_task_rec.status_id is null or p_x_sr_task_rec.status_id = FND_API.G_MISS_NUM)and
                (p_x_sr_task_rec.status_name is null or p_x_sr_task_rec.status_name = FND_API.G_MISS_CHAR)) THEN

              Fnd_Message.SET_NAME('AHL','AHL_PRD_SR_STATUS_REQ');
              Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
              Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
              Fnd_Msg_Pub.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;

            END IF;

    END IF;

    -- If object version number is null then
    -- return an error message.
    IF (p_x_sr_task_rec.incident_object_version_number is null or
        p_x_sr_task_rec.incident_object_version_number = FND_API.G_MISS_NUM) THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_SR_OBJ_VER_ID_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    -- If Incident number and incident id is null then
    -- return an error message.
    IF (p_x_sr_task_rec.incident_number is null or
        p_x_sr_task_rec.incident_number = FND_API.G_MISS_CHAR) and
       (p_x_sr_task_rec.incident_id is null or
        p_x_sr_task_rec.incident_id = FND_API.G_MISS_NUM)THEN

      Fnd_Message.SET_NAME('AHL','AHL_PRD_INCIDENT_VALUE_REQ');
      Fnd_Message.SET_TOKEN('WO_NAME',l_wo_name);
      Fnd_Message.SET_TOKEN('INSTANCE_NUM',l_instance_num);
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  IF (p_x_sr_task_rec.source_program_code is null or
        p_x_sr_task_rec.source_program_code = FND_API.G_MISS_CHAR) then
        p_x_sr_task_rec.source_program_code := 'AHL_ROUTINE';
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END Default_and_validate_param;


--------------------------------------------
-- Create Service Request
--------------------------------------------

----------------------------------------------
-- Create_sr procedure assigns the values to
-- service request record and calls the
-- Create service request public api.
----------------------------------------------

PROCEDURE Create_sr(
  p_x_sr_task_rec  IN OUT NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
  x_return_status  OUT NOCOPY    VARCHAR2
)IS

  l_service_request_rec   CS_SERVICEREQUEST_PUB.service_request_rec_type;
  l_notes_table           CS_ServiceRequest_PUB.notes_table;
  l_contacts_table        CS_ServiceRequest_PUB.contacts_table;
  l_contact_primary_flag  CONSTANT VARCHAR2(1) := 'Y';
  l_auto_assign           CONSTANT VARCHAR2(1) := 'N';

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_inventory_item_id     NUMBER;
  l_serial_number         VARCHAR2(30);
  l_inv_master_org_id     NUMBER;
  l_note                  VARCHAR2(2000);
  l_note_detail           VARCHAR2(2000);

  l_individual_owner      NUMBER;
  l_group_owner           NUMBER;
  l_individual_type       VARCHAR2(30);
  L_API_NAME  CONSTANT    VARCHAR2(30)  := 'CREATE_SR';

--  Begin Changes by VSUNDARA for SR Integration
  CURSOR default_item_org_id(p_workorder_id IN NUMBER) IS
  SELECT A.inventory_item_id,
         A.item_organization_id
  FROM   AHL_VISIT_TASKS_B A,
         AHL_WORKORDERS B
  WHERE  A.visit_task_id = B.visit_task_id
  AND    B.workorder_id = p_workorder_id;

 CURSOR default_incident_type_id is
      SELECT INCIDENT_TYPE_ID,NAME
      FROM cs_incident_types_vl
      where INCIDENT_SUBTYPE = 'INC'
      AND CMRO_FLAG = 'Y'
      -- Check added by balaji for bug # 4146503.
      -- always has to pick up the SR type id from AHL default SR Type profile.
      AND incident_type_id=fnd_profile.value('AHL_PRD_SR_TYPE')
     AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
     AND trunc(nvl(end_date_active,sysdate));
-- END Changes

 -- added to fix bug# 8265902
 CURSOR get_inc_type_id (p_name IN VARCHAR2) IS
   SELECT INCIDENT_TYPE_ID
   FROM cs_incident_types_vl
   where INCIDENT_SUBTYPE = 'INC'
     AND CMRO_FLAG = 'Y'
     AND NAME = p_name
     AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
     AND trunc(nvl(end_date_active,sysdate));

 l_default_sr_flag BOOLEAN;

BEGIN

  -- Initialize the SR record.
  CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

  get_note_value(p_sr_task_rec => p_x_sr_task_rec,
                 x_note        => l_note,
                 x_note_detail => l_note_detail);

  -- Assign the SR rec values
  l_service_request_rec.request_date          := p_x_sr_task_rec.request_date;
  l_service_request_rec.status_id             := p_x_sr_task_rec.status_id;
  l_service_request_rec.status_name           := p_x_sr_task_rec.status_name;
  l_service_request_rec.severity_id           := p_x_sr_task_rec.severity_id;
  l_service_request_rec.severity_name         := p_x_sr_task_rec.severity_name;
  l_service_request_rec.urgency_id            := p_x_sr_task_rec.urgency_id;
  l_service_request_rec.urgency_name          := p_x_sr_task_rec.urgency_name;
  l_service_request_rec.summary               := p_x_sr_task_rec.summary;
  l_service_request_rec.caller_type           := p_x_sr_task_rec.customer_type;
  l_service_request_rec.customer_id           := p_x_sr_task_rec.customer_id;
  l_service_request_rec.problem_code          := p_x_sr_task_rec.problem_code;
  l_service_request_rec.resolution_code       := p_x_sr_task_rec.resolution_code;
  l_service_request_rec.creation_program_code := p_x_sr_task_rec.source_program_code;

  -- MANESING::DFF Project, 16-Feb-2010, assigned attributes to local record for Creating Service Request
  l_service_request_rec.request_context       := p_x_sr_task_rec.attribute_category;
  l_service_request_rec.request_attribute_1   := p_x_sr_task_rec.attribute1;
  l_service_request_rec.request_attribute_2   := p_x_sr_task_rec.attribute2;
  l_service_request_rec.request_attribute_3   := p_x_sr_task_rec.attribute3;
  l_service_request_rec.request_attribute_4   := p_x_sr_task_rec.attribute4;
  l_service_request_rec.request_attribute_5   := p_x_sr_task_rec.attribute5;
  l_service_request_rec.request_attribute_6   := p_x_sr_task_rec.attribute6;
  l_service_request_rec.request_attribute_7   := p_x_sr_task_rec.attribute7;
  l_service_request_rec.request_attribute_8   := p_x_sr_task_rec.attribute8;
  l_service_request_rec.request_attribute_9   := p_x_sr_task_rec.attribute9;
  l_service_request_rec.request_attribute_10  := p_x_sr_task_rec.attribute10;
  l_service_request_rec.request_attribute_11  := p_x_sr_task_rec.attribute11;
  l_service_request_rec.request_attribute_12  := p_x_sr_task_rec.attribute12;
  l_service_request_rec.request_attribute_13  := p_x_sr_task_rec.attribute13;
  l_service_request_rec.request_attribute_14  := p_x_sr_task_rec.attribute14;
  l_service_request_rec.request_attribute_15  := p_x_sr_task_rec.attribute15;

  -- bug# 5450359. Default incident date.
  l_service_request_rec.incident_occurred_date := l_service_request_rec.request_date;

  l_service_request_rec.customer_product_id    := p_x_sr_task_rec.instance_id;
  open default_item_org_id(p_x_sr_task_rec.Originating_wo_id);
  Fetch default_item_org_id  INTO l_service_request_rec.inventory_item_id,l_service_request_rec.inventory_org_id;
  IF (default_item_org_id%NOTFOUND  ) THEN
        FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_ORG_ERROR');
        Fnd_Msg_Pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE default_item_org_id;

  -- By default set to true. If type_name is valid, then reset flag to FALSE
  l_default_sr_flag := TRUE;

  -- if type_name is not null, validate it(fix for bug# 8265902)
  IF (p_x_sr_task_rec.type_name IS NOT NULL AND p_x_sr_task_rec.type_name <> FND_API.G_MISS_CHAR) THEN
    OPEN get_inc_type_id(p_x_sr_task_rec.type_name);
    FETCH get_inc_type_id INTO l_service_request_rec.type_id;
    IF (get_inc_type_id%FOUND) THEN
      l_service_request_rec.type_name := p_x_sr_task_rec.type_name;
      l_default_sr_flag := FALSE;
      IF (G_DEBUG = 'Y') THEN
        AHL_DEBUG_PUB.debug('Input SR type:ID:' || l_service_request_rec.type_name || ':' || l_service_request_rec.type_id );
      END IF;
    END IF;
    CLOSE get_inc_type_id;
  END IF;

  IF (l_default_sr_flag) THEN
    -- default
    open default_incident_type_id;
    Fetch default_incident_type_id  INTO  l_service_request_rec.type_id,l_service_request_rec.type_name;

    IF ( default_incident_type_id%NOTFOUND) THEN
        FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_INCIDENT_ERROR');
        Fnd_Msg_Pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF (G_DEBUG = 'Y') THEN
      AHL_DEBUG_PUB.debug('Defaulting SR type:ID:' || l_service_request_rec.type_name || ':' || l_service_request_rec.type_id );
    END IF;

    CLOSE default_incident_type_id;
  END IF;

  --- End Changes by VSUNDARA for SR Integration
  -- Contacts
  l_contacts_table(1).party_id                := p_x_sr_task_rec.contact_id;
  l_contacts_table(1).contact_type            := p_x_sr_task_rec.contact_type;
  l_contacts_table(1).primary_flag            := l_contact_primary_flag;

  -- Notes
  /*
  l_notes_table(1).note                       := l_note;
  l_notes_table(1).note_detail                := l_note_detail;
  l_notes_table(1).note_type                  := 'CS_PROBLEM';
  l_notes_table(1).note_context_type_01       := 'SR';

  -- Call write to log procedure to log the input parameter
  -- values for debug

  IF (G_DEBUG = 'Y') THEN
    AHL_DEBUG_PUB.debug('Inputs for CS_SERVICEREQUEST_PUB.Create_ServiceRequest:');
    write_sr_to_log(
      p_service_request_rec => l_service_request_rec,
      p_notes_table => l_notes_table,
      p_contacts_table => l_contacts_table
    );
  END IF;
*/
  -- Call to Service Request API

  CS_SERVICEREQUEST_PUB.Create_ServiceRequest(
    p_api_version           => 3.0,
    p_init_msg_list         => FND_API.G_TRUE,
    p_commit                => FND_API.G_FALSE,
    x_return_status         => x_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_resp_appl_id          => NULL,
    p_resp_id               => NULL,
    p_user_id               => fnd_global.user_id,
    p_login_id              => fnd_global.conc_login_id,
    p_org_id                => NULL,
    p_request_id            => NULL,
    p_request_number        => NULL,
    p_service_request_rec   => l_service_request_rec,
    p_notes                 => l_notes_table,
    p_contacts              => l_contacts_table,
    p_auto_assign           => l_auto_assign,
    x_request_id            => p_x_sr_task_rec.incident_id,
    x_request_number        => p_x_sr_task_rec.incident_number,
    x_interaction_id        => p_x_sr_task_rec.interaction_id,
    x_workflow_process_id   => p_x_sr_task_rec.workflow_process_id,
    x_individual_owner      => l_individual_owner,
    x_group_owner           => l_individual_owner,
    x_individual_type       => l_individual_type
  );

   IF ( upper(x_return_status) <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

---Changes by VSUNDARA FOR TRANSIT CHECK

    -- Tamal [MEL/CDL PRD Integration] Begins here...
    -- After creating the SR on the instance, need to populate unit_config_id for the newly created UE
    update ahl_unit_effectivities_b
    set unit_config_header_id = AHL_UTIL_UC_PKG.get_uc_header_id(p_x_sr_task_rec.instance_id)
    where unit_effectivity_id in
    (
        select unit_effectivity_id
        from ahl_unit_effectivities_b
        where object_type = 'SR' and cs_incident_id = p_x_sr_task_rec.incident_id
    );
    -- Tamal [MEL/CDL PRD Integration] Ends here...

   -- MR NR ER -- start

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(
      fnd_log.level_statement,
      'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
      'Before Updating Unit Effectivity with Originating WO detail..'
      );
      fnd_log.string(
      fnd_log.level_statement,
      'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
      'p_x_sr_task_rec.Originating_wo_id->'||p_x_sr_task_rec.Originating_wo_id||' , '
      ||'p_x_sr_task_rec.incident_id->'||p_x_sr_task_rec.incident_id
      );
   END IF;

   -- update ump table with originating wo id in AHL_UNIT_EFFECTIVITIES_B.ORIGINATING_WO_ID
   IF
     (
      p_x_sr_task_rec.incident_id IS NOT NULL
      AND
      p_x_sr_task_rec.Originating_wo_id IS NOT NULL
     )
   THEN

     BEGIN

      UPDATE AHL_UNIT_EFFECTIVITIES_B
      SET ORIGINATING_WO_ID = p_x_sr_task_rec.Originating_wo_id
      WHERE CS_INCIDENT_ID = p_x_sr_task_rec.incident_id;

     EXCEPTION

      WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_ORIGINWO_UPD_FAILED');
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

     END;

   END IF;

   -- MR NR ER -- end

END Create_sr;

-- MR NR ER -- start
-----------------------------------------------------------------------------------
-- Balaji added this piece of code for OGMA ER # 6459697(Adding MRs to Non-Routine)
-- This local procedure processes all MRs associated to a SR. Essentially does following
-- 1. Creates and associates UE hierarchy for the MRs added to SR.
-- 2. Creates Task hierarchy required in VWP
-- 3. Releases the new tasks added in VWP to production.
-----------------------------------------------------------------------------------
PROCEDURE  Process_Mr(
      p_x_task_tbl      IN OUT NOCOPY sr_task_tbl_type,
      p_mr_assoc_tbl    IN OUT NOCOPY MR_Association_tbl_type,
      p_module_type     IN            VARCHAR2,
      x_return_status   OUT NOCOPY    VARCHAR2,
      x_msg_count       OUT NOCOPY    NUMBER,
      x_msg_data        OUT NOCOPY    VARCHAR2
)
IS

-- declare all cursors here
--*************************

--1. cursor for getting visit task id corresponding originating workorder
cursor c_visit_task_csr(c_Nonroutine_wo_id IN NUMBER) IS
                    SELECT
                      WO.visit_task_id
                    FROM
                      AHL_WORKORDERS WO
                    WHERE
                      WO.workorder_id = c_Nonroutine_wo_id;

-- Added by jaramana on Oct 15
CURSOR c_NR_wo_details(p_unit_effectivity_id IN NUMBER)
IS
SELECT
 awo.workorder_id
FROM
 ahl_workorders awo,
 ahl_visit_tasks_b vtsk
WHERE
 awo.visit_task_id = vtsk.visit_task_id
 AND awo.master_workorder_flag = 'Y'
 AND vtsk.task_type_code = 'SUMMARY'
 AND vtsk.mr_id is NULL
 AND vtsk.unit_effectivity_id = p_unit_effectivity_id;

-- 3. cursor for retrieving unit effectivity id corresponding to the SR created.
CURSOR c_get_ue_id(p_incident_id NUMBER)
IS
  Select  unit_effectivity_id
  from AHL_UNIT_EFFECTIVITIES_B
  where cs_incident_id  = p_incident_id;

CURSOR c_get_sr_details(p_incident_id NUMBER)
IS
SELECT object_version_number
FROM CS_INCIDENTS
WHERE incident_id = p_incident_id;

--amsriniv ER 6014567 Begin
--5. cursor for retrieving the non master workorder id which is passed as to_workorder_id when calling move_intance_location
CURSOR get_nonmaster_wo_id(p_nr_wo_id IN NUMBER)
IS
    SELECT  workorder_id
    FROM    ahl_workorders
    WHERE   MASTER_WORKORDER_FLAG = 'N'
        AND wip_entity_id in
            (SELECT rel.child_object_id
            FROM    wip_sched_relationships rel START
            WITH REL.parent_object_id               = (SELECT wip_entity_id FROM ahl_workorders WHERE workorder_id = p_nr_wo_id)
                    CONNECT BY REL.parent_object_id = PRIOR REL.child_object_id
                AND REL.parent_object_type_id       = PRIOR REL.child_object_type_id
                AND REL.relationship_type           = 1
            )
    ORDER BY workorder_id;
--amsriniv ER 6014567 End

--declare all local variables here
--**********************************
l_tasks_tbl                    AHL_VWP_PROJ_PROD_PVT.Task_Tbl_Type;
l_visit_task_id                NUMBER;
l_create_task_tbl              AHL_VWP_RULES_PVT.Task_Tbl_Type;
l_x_sr_mr_association_tbl      AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type;
l_move_item_ins_tbl            AHL_PRD_PARTS_CHANGE_PVT.move_item_instance_tbl_type;--amsriniv ER 6014567
l_ins_cntr                     NUMBER := 0;--amsriniv ER 6014567
i                              NUMBER;
l_count                        NUMBER;
l_unit_effectivity_id          NUMBER;
l_tsk_count                    NUMBER := 1;
l_nmo_wo_id                    NUMBER; --amsriniv ER 6014567
l_api_name                     VARCHAR2(200) := 'PROCESS_MR';
l_workorder_id                 NUMBER;
-- SKPATHAK :: Bug 8343599 :: 04-AUG-2009
l_recalculate_vwp_dates        VARCHAR2(1) := 'Y';


BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || l_api_name || '.begin', 'Entering Procedure');
    END IF;


    FOR i in p_x_task_tbl.FIRST .. p_x_task_tbl.LAST
    LOOP

         IF  p_mr_assoc_tbl.COUNT > 0 AND (p_module_type IS NULL OR p_module_type <> 'SR_OA')
         THEN

                   copy_mr_details(
                        p_mr_assoc_tbl,
                        l_x_sr_mr_association_tbl,
                        i
                   );

                  OPEN c_get_sr_details(p_x_task_tbl(i).Incident_id);
                  FETCH c_get_sr_details INTO p_x_task_tbl(i).Incident_object_version_number;
                  CLOSE c_get_sr_details;

                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                      fnd_log.string(
                          fnd_log.level_statement,
                          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                          'Before calling AHL_UMP_SR_PVT.Process_SR_MR_Associations...'
                      );
                      fnd_log.string(
                          fnd_log.level_statement,
                          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                          'p_x_task_tbl(i).Incident_id ->'||p_x_task_tbl(i).Incident_id
                      );
                      fnd_log.string(
                          fnd_log.level_statement,
                          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                          'p_x_task_tbl(i).Incident_object_version_number'||p_x_task_tbl(i).Incident_object_version_number
                      );
                      fnd_log.string(
                          fnd_log.level_statement,
                          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                          'p_x_task_tbl(i).Incident_number'||p_x_task_tbl(i).Incident_number
                      );
                  END IF;

                  -- 1. Create Unit Effectivity hierarchy for the SR - MR hieararchy.
                  AHL_UMP_SR_PVT.Process_SR_MR_Associations(
                            p_api_version             => 1.0,
                            p_init_msg_list           => FND_API.G_TRUE,-- verify the value to be passed here
                            p_commit                  => FND_API.G_FALSE,
                            p_validation_level        => Fnd_Api.G_VALID_LEVEL_FULL,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_user_id                 => fnd_global.user_id,
                            p_login_id                => fnd_global.login_id,
                            p_request_id              => p_x_task_tbl(i).Incident_id,
                            p_object_version_number   => p_x_task_tbl(i).Incident_object_version_number,
                            p_request_number          => p_x_task_tbl(i).Incident_number,
                            p_x_sr_mr_association_tbl => l_x_sr_mr_association_tbl
                          );

                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                      fnd_log.string(
                          fnd_log.level_statement,
                          'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                          'After calling AHL_UMP_SR_PVT.Process_SR_MR_Associations...Return status->'||x_return_status
                      );
                  END IF;

                  IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                          RAISE FND_API.G_EXC_ERROR;
                  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

         END IF;
         -- 2. Call VWP API to create task Hiearchy.

     --FP for ER 5716489 -- start
     -- Call the VWP API to create task hierarchy only when the create Workorder
     -- flag is selected . If it is not checked ie:N, then do not create the tasks and WOs

     IF (nvl(UPPER(p_x_task_tbl(i).WO_Create_flag),'Y') = 'Y')
     THEN

         -- retrieve unit effectivity id corresponding to the SR
         OPEN  c_get_ue_id(p_x_task_tbl(i).incident_id);
         FETCH c_get_ue_id into l_unit_effectivity_id ;
         IF c_get_ue_id%NotFound
         THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_SR');
               FND_MESSAGE.SET_TOKEN('WO_ID',p_x_task_tbl(i).originating_wo_id);
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_get_ue_id;

         OPEN c_visit_task_csr(p_x_task_tbl(i).Originating_wo_id);
         FETCH c_visit_task_csr INTO l_visit_task_id;
         CLOSE c_visit_task_csr;

         l_create_task_tbl(l_tsk_count).originating_task_id := l_visit_task_id;

         l_create_task_tbl(l_tsk_count).visit_id            := p_x_task_tbl(i).visit_id;
         l_create_task_tbl(l_tsk_count).service_request_id  := p_x_task_tbl(i).incident_id;
         l_create_task_tbl(l_tsk_count).unit_effectivity_id := l_unit_effectivity_id;
         l_create_task_tbl(l_tsk_count).task_type_code      := 'PLANNED';
     l_create_task_tbl(l_tsk_count).operation_flag      := 'C';
     l_create_task_tbl(l_tsk_count).quantity     := p_x_task_tbl(i).instance_quantity; --amsriniv. Issue 105 ER 6014567

         -- FP Bug # 7720088 (Mexicana Bug # 7697685) -- start
         IF p_x_task_tbl(i).workorder_start_time IS NOT NULL
         THEN
                l_create_task_tbl(l_tsk_count).task_start_date      := p_x_task_tbl(i).workorder_start_time;
         END IF;
         -- FP Bug # 7720088 (Mexicana Bug # 7697685) -- end

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'Before calling AHL_VWP_TASKS_PVT.CREATE_PUP_TASKS...'
             );
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'p_x_task_tbl(i).visit_id->'||p_x_task_tbl(i).visit_id
             );
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'p_x_task_tbl(i).incident_id->'||p_x_task_tbl(i).incident_id
             );
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'l_unit_effectivity_id->'||l_unit_effectivity_id
             );
             -- FP Bug # 7720088 (Mexicana Bug # 7697685) -- start
             fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'p_x_task_tbl(i).workorder_start_time->'||p_x_task_tbl(i).workorder_start_time
             );
             -- FP Bug # 7720088 (Mexicana Bug # 7697685) -- end
         END IF;

         AHL_VWP_TASKS_PVT.CREATE_PUP_TASKS(
                p_api_version           => 1.0,
                p_init_msg_list         => Fnd_Api.G_TRUE,
                p_module_type           => 'SR',
                p_x_task_tbl            => l_create_task_tbl,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
         );

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'After calling AHL_VWP_TASKS_PVT.CREATE_PUP_TASKS...Return status->'||x_return_status
             );
         END IF;

         IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  RAISE FND_API.G_EXC_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- 3. Call VWP API to push tasks into production.

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'Before calling AHL_VWP_PROJ_PROD_PVT.Release_MR...'
             );
         END IF;
         -- FP for ER 5716489 -- start
         -- SKPATHAK :: Bug 8343599 :: 04-AUG-2009
          IF p_x_task_tbl(i).workorder_start_time IS NOT NULL THEN
           -- User has entered a start date for the non-routine.
           -- Need to honor this date
           l_recalculate_vwp_dates := 'N';
          END IF;

         IF ( nvl(UPPER(p_x_task_tbl(i).WO_Release_flag), 'Y') = 'Y' )
         THEN

                 AHL_VWP_PROJ_PROD_PVT.Release_MR(
                    p_api_version         =>    1.0,
                    p_init_msg_list       =>    Fnd_Api.G_FALSE,
                    p_commit              =>    Fnd_Api.G_FALSE,
                    p_validation_level    =>    Fnd_Api.G_VALID_LEVEL_FULL,
                    p_module_type         =>    'SR',
                    p_visit_id            =>    p_x_task_tbl(i).visit_id,
                    p_unit_effectivity_id =>    l_unit_effectivity_id,
                    p_release_flag        =>    'Y',
                    -- SKPATHAK :: Bug 8343599 :: 04-AUG-2009
                    p_recalculate_dates   =>    l_recalculate_vwp_dates,
                    x_workorder_id        =>    l_workorder_id,
                    x_return_status       =>    x_return_status,
                    x_msg_count           =>    x_msg_count,
                    x_msg_data            =>    x_msg_data
                 );

         ELSE
                 AHL_VWP_PROJ_PROD_PVT.Release_MR(
                    p_api_version         =>    1.0,
                    p_init_msg_list       =>    Fnd_Api.G_FALSE,
                    p_commit              =>    Fnd_Api.G_FALSE,
                    p_validation_level    =>    Fnd_Api.G_VALID_LEVEL_FULL,
                    p_module_type         =>    'SR',
                    p_visit_id            =>    p_x_task_tbl(i).visit_id,
                    p_unit_effectivity_id =>    l_unit_effectivity_id,
                    p_release_flag        =>    'N',
                    -- SKPATHAK :: Bug 8343599 :: 04-AUG-2009
                    p_recalculate_dates   =>    l_recalculate_vwp_dates,
                    x_workorder_id        =>    l_workorder_id,
                    x_return_status       =>    x_return_status,
                    x_msg_count           =>    x_msg_count,
                    x_msg_data            =>    x_msg_data
                 );

         END IF;
         --FP for ER 5716489 -- end

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'After calling AHL_VWP_PROJ_PROD_PVT.Release_MR...Return status ->'||x_return_status
             );
         END IF;

         IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  RAISE FND_API.G_EXC_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Added by jaramana on Oct 15
         IF ( upper(p_x_task_tbl(i).operation_type) = 'CREATE') THEN
              OPEN c_NR_wo_details(l_unit_effectivity_id);
              FETCH c_NR_wo_details INTO p_x_task_tbl(i).Nonroutine_wo_id;
              CLOSE c_NR_wo_details;
         END IF;
--amsriniv ER 6014567 Begin
             IF ((nvl(upper(p_x_task_tbl(i).WO_Release_flag), 'Y') = 'Y') AND (nvl(upper(p_x_task_tbl(i).move_qty_to_nr_workorder),'N') = 'Y') AND
             upper(p_x_task_tbl(i).operation_type) = 'CREATE' AND
             p_x_task_tbl(i).nonroutine_wo_id IS NOT NULL)
             THEN
                 OPEN  get_nonmaster_wo_id(p_x_task_tbl(i).nonroutine_wo_id);
                 FETCH get_nonmaster_wo_id into l_nmo_wo_id ;
                 IF get_nonmaster_wo_id%FOUND
                 THEN
                    l_move_item_ins_tbl(l_ins_cntr).instance_id := p_x_task_tbl(i).instance_id;
                    l_move_item_ins_tbl(l_ins_cntr).quantity := p_x_task_tbl(i).instance_quantity;
                    l_move_item_ins_tbl(l_ins_cntr).from_workorder_id := p_x_task_tbl(i).originating_wo_id;
                    l_move_item_ins_tbl(l_ins_cntr).to_workorder_id := l_nmo_wo_id;
                    l_ins_cntr := l_ins_cntr + 1;
                 END IF;
             END IF;
--amsriniv ER 6014567 End
     END IF;
     --FP for ER 5716489 -- end

   END LOOP;
--amsriniv ER 6014567 Begin
  IF (l_ins_cntr  > 0)
  THEN
    AHL_PRD_PARTS_CHANGE_PVT.move_instance_location(
        p_api_version               =>  1.0,
        p_init_msg_list             =>  Fnd_Api.G_FALSE,
        p_commit                    =>  Fnd_Api.G_FALSE,
        p_validation_level          =>  Fnd_Api.G_VALID_LEVEL_FULL,
        p_module_type               =>  NULL,
        p_default                   =>  FND_API.G_TRUE,
        p_move_item_instance_tbl    =>  l_move_item_ins_tbl,
        x_return_status             =>  x_return_status,
        x_msg_count                 =>  x_msg_count,
        x_msg_data                  =>  x_msg_data
     );
  END IF;
--amsriniv ER 6014567 End
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || l_api_name || '.end', 'Exiting Procedure');
   END IF;

END Process_Mr;
-- MR NR ER -- end

-- MR NR ER -- start
PROCEDURE  Copy_Mr_Details(
   p_mr_assoc_tbl            IN OUT NOCOPY MR_Association_tbl_type,
   p_x_sr_mr_association_tbl IN OUT NOCOPY AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type,
   p_sr_table_index             IN NUMBER
)
IS
-- declare all local variables here.
l_count NUMBER;
l_api_name                     VARCHAR2(200) := 'COPY_MR_DETAILS';

BEGIN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || l_api_name || '.begin', 'Entering Procedure');
        END IF;

        l_count := 0;

        FOR j IN p_mr_assoc_tbl.FIRST .. p_mr_assoc_tbl.LAST
        LOOP
          IF p_sr_table_index = p_mr_assoc_tbl(j).sr_tbl_index THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string(
                  fnd_log.level_statement,
                  'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME||':',
                  'p_sr_table_index->'||p_sr_table_index
              );
            END IF;

            l_count := l_count + 1;
            p_x_sr_mr_association_tbl(l_count).mr_header_id := p_mr_assoc_tbl(j).mr_header_id;
            p_x_sr_mr_association_tbl(l_count).mr_title := p_mr_assoc_tbl(j).mr_title;
            p_x_sr_mr_association_tbl(l_count).mr_version := p_mr_assoc_tbl(j).mr_version;
            p_x_sr_mr_association_tbl(l_count).relationship_code := 'PARENT';
            p_x_sr_mr_association_tbl(l_count).csi_instance_id := p_mr_assoc_tbl(j).csi_instance_id;
            p_x_sr_mr_association_tbl(l_count).csi_instance_number := p_mr_assoc_tbl(j).csi_instance_number;
            p_x_sr_mr_association_tbl(l_count).operation_flag := 'C';
          END IF;
        END LOOP;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || l_api_name || '.end', 'Exiting Procedure');
        END IF;

END Copy_Mr_Details;
-- MR NR ER -- end

--------------------------------------------
-- Create VWP Task
--------------------------------------------
PROCEDURE Create_task(
  p_x_task_tbl     IN OUT  NOCOPY ahl_prd_nonroutine_pvt.sr_task_tbl_type,
  x_return_status  OUT NOCOPY    VARCHAR2
) IS

  l_create_job_task_tbl   AHL_VWP_PROJ_PROD_PVT.Task_tbl_type;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_org_task_id           NUMBER;
  l_request_type          VARCHAR2(60);
  l_visit_task_name       VARCHAR2(80);
  l_task_type_code        VARCHAR2(30) := 'UNASSOCIATED';
  l_operation_flag        VARCHAR2(3)  := 'C';
  l_unit_effectivity_id   NUMBER;
CURSOR GetRequestType(c_req_type_id NUMBER)
Is
        Select name
        FROM cs_incident_types_vl
        WHERE incident_type_id = c_req_type_id;
CURSOR GetOrgTaskDet(c_org_wo_id NUMBER)
Is
      Select visit_task_id
      from ahl_workorders
      where workorder_id = c_org_wo_id;

CURSOR getUnitEffectivity(p_incident_id NUMBER)
IS
  Select  unit_effectivity_id
  from AHL_UNIT_EFFECTIVITIES_B
  where cs_incident_id  = p_incident_id;

-- FND Logging Constants
l_debug_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_debug_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
l_debug_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
l_debug_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

BEGIN

  IF (l_debug_PROC >= l_debug_LEVEL) THEN
      fnd_log.string
               (l_debug_PROC,
                'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task.begin',
                'At the start of PLSQL procedure');
  END IF;

  FOR i IN p_x_task_tbl.FIRST..p_x_task_tbl.LAST LOOP
  IF ( upper(p_x_task_tbl(i).operation_type) = 'CREATE') THEN
    -- Initialize the Record type
    --
    l_request_type := null;
    l_org_task_id  := null;

    -- Derive the request type
    IF (p_x_task_tbl(i).type_name is null or
        p_x_task_tbl(i).type_name = FND_API.G_MISS_CHAR)
    THEN
            Open  GetRequestType(p_x_task_tbl(i).type_id);
            Fetch GetRequestType into l_request_type;
            Close GetRequestType;
    ELSE
            l_request_type := p_x_task_tbl(i).type_name;
    END IF;

    IF (l_debug_STMT >= l_debug_LEVEL) THEN
        fnd_log.string
             (l_debug_STMT,
              'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
              'After deriving request type:' || l_request_type);
    END IF;

    -- Derive the originating visit id

    Open  GetOrgTaskDet(p_x_task_tbl(i).originating_wo_id);
    Fetch GetOrgTaskDet into l_org_task_id;

    If GetOrgTaskDet%Found and GetOrgTaskDet%rowcount >1
    Then
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_TASK_ID_NOT_UNIQUE');
      FND_MESSAGE.SET_TOKEN('WO_ID',p_x_task_tbl(i).originating_wo_id);
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ElsIf GetOrgTaskDet%NotFound
    Then
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_WO_ID');
      FND_MESSAGE.SET_TOKEN('WO_ID',p_x_task_tbl(i).originating_wo_id);
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    End if;
    Close GetOrgTaskDet;

    IF (l_debug_STMT >= l_debug_LEVEL) THEN
        fnd_log.string
             (l_debug_STMT,
              'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
              'After deriving originating visit task id:' || l_org_task_id);

    END IF;

    -- If visit task name is null then default the values
    IF( p_x_task_tbl(i).visit_task_name is null or
        p_x_task_tbl(i).visit_task_name = FND_API.G_MISS_CHAR) THEN
      l_visit_task_name := substr(l_request_type,1,(78-length(p_x_task_tbl(i).incident_number)))||'-'
                           ||p_x_task_tbl(i).incident_number;

      p_x_task_tbl(i).visit_task_name := l_visit_task_name;

    ELSE
      l_visit_task_name := p_x_task_tbl(i).visit_task_name;
    END IF;

    IF (l_debug_STMT >= l_debug_LEVEL) THEN
        fnd_log.string
             (l_debug_STMT,
              'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
              'After defaulting task name');
    END IF;

    --- Begin Changes by VSUNDARA for SR INTEGRATION
    Open  getUnitEffectivity(p_x_task_tbl(i).incident_id);
    Fetch getUnitEffectivity into l_unit_effectivity_id ;
    IF getUnitEffectivity%NotFound
    Then
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_INVALID_SR'); -- New Message needed to be added
      FND_MESSAGE.SET_TOKEN('WO_ID',p_x_task_tbl(i).originating_wo_id);
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    End if;
    Close getUnitEffectivity;
    l_create_job_task_tbl(i).unit_effectivity_id  := l_unit_effectivity_id;
  --- END Changes by VSUNDARA for SR INTEGRATION

    IF (l_debug_STMT >= l_debug_LEVEL) THEN
        fnd_log.string
             (l_debug_STMT,
              'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
              'After deriving UE ID:' || l_unit_effectivity_id);
    END IF;

    -- Assign the Create Job Tasks values
    l_create_job_task_tbl(i).visit_id            := p_x_task_tbl(i).visit_id;
    l_create_job_task_tbl(i).visit_task_name     := l_visit_task_name;
    l_create_job_task_tbl(i).duration            := p_x_task_tbl(i).duration;
    l_create_job_task_tbl(i).instance_id         := p_x_task_tbl(i).instance_id;
    l_create_job_task_tbl(i).service_request_id  := p_x_task_tbl(i).incident_id;
    l_create_job_task_tbl(i).originating_task_id := l_org_task_id;
    l_create_job_task_tbl(i).task_type_code      := l_task_type_code;
    l_create_job_task_tbl(i).operation_flag      := l_operation_flag;


    IF (l_debug_STMT >= l_debug_LEVEL) THEN
        fnd_log.string
             (l_debug_STMT,
              'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
              'End loop for visit task name: ' || l_visit_task_name);
    END IF;

  END IF;
  END LOOP;

  IF l_create_job_task_tbl.count > 0 THEN

    IF (l_debug_STMT >= l_debug_LEVEL) THEN
        fnd_log.string
                 (l_debug_STMT,
                  'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
                  'Before calling AHL_VWP_PROJ_PROD_PVT.Create_job_tasks');
    END IF;

    AHL_VWP_PROJ_PROD_PVT.Create_job_tasks(
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.G_TRUE,
      p_commit            => FND_API.G_FALSE,
      p_validation_level  => Fnd_API.G_VALID_LEVEL_FULL,
      p_module_type       => NULL,
      p_x_task_tbl        => l_create_job_task_tbl,
      x_return_status     => x_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
    );

    -- AHL_VWP_PROJ_PROD_PVT.Create_job_tasks returns x_return_status as success
    -- even though visit validation fails. The validation errors are put in the
    -- error stack. In this case, the WO creation api will not be called and
    -- wo_id returned is null. Task is created.

    l_msg_count := FND_MSG_PUB.count_msg;

    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_msg_count > 0) THEN

       IF (l_debug_UEXP >= l_debug_LEVEL) THEN
           fnd_log.string
                 (l_debug_UEXP,
                  'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
                  'Error ' || x_return_status ||' returned from AHL_VWP_PROJ_PROD_PVT.Create_job_tasks');
       END IF;

       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  /*
  IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  */

  FOR i IN p_x_task_tbl.FIRST..p_x_task_tbl.LAST LOOP
    IF ( upper(p_x_task_tbl(i).operation_type) = 'CREATE') THEN

      IF (l_debug_STMT >= l_debug_LEVEL) THEN
          fnd_log.string
               (l_debug_STMT,
                'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
                'Now processing for WO: ' || l_create_job_task_tbl(i).workorder_id);
      END IF;

      p_x_task_tbl(i).visit_task_id     := l_create_job_task_tbl(i).visit_task_id;
      p_x_task_tbl(i).visit_task_number := l_create_job_task_tbl(i).visit_task_number;
      p_x_task_tbl(i).Nonroutine_wo_id  := l_create_job_task_tbl(i).workorder_id;

      -- R12: modified for bug# 5261150.
      IF (nvl(p_x_task_tbl(i).WO_Release_flag,'Y') = 'Y' AND
          l_create_job_task_tbl(i).workorder_id IS NOT NULL) THEN

        -- Fix for bug# 5261150.
        -- release workorder if user chooses to release wo.
        -- Default is to release wo.
        IF (l_debug_STMT >= l_debug_LEVEL) THEN
            fnd_log.string
                 (l_debug_STMT,
                  'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
                  'Before calling AHL_PRD_WORKORDER_PVT.Release_visit_jobs for WO: ' || l_create_job_task_tbl(i).workorder_id);
        END IF;

        AHL_PRD_WORKORDER_PVT.Release_visit_jobs
          (
            p_api_version            => 1.0,
            p_init_msg_list          => FND_API.G_TRUE,
            p_commit                 => FND_API.G_FALSE,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            p_default                => FND_API.G_FALSE,
            p_module_type            => NULL,
            x_return_status          => x_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            p_visit_id               => NULL,
            p_unit_effectivity_id    => NULL,
            p_workorder_id           => l_create_job_task_tbl(i).workorder_id
          );

        IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          IF (l_debug_UEXP >= l_debug_LEVEL) THEN
              fnd_log.string
                 (l_debug_UEXP,
                  'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task',
                  'Error ' || x_return_status ||' returned from AHL_PRD_WORKORDER_PVT.Release_visit_jobs');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- p_x_task_tbl(i).WO_Release_flag = 'Y'

    END IF;
  END LOOP;

  IF (l_debug_PROC >= l_debug_LEVEL) THEN
      fnd_log.string
               (l_debug_PROC,
                'ahl.plsql.AHL_PRD_NONROUTINE_PVT.Create_task.End',
                'At the end of PLSQL procedure');
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END Create_task;


--------------------------------------------
-- Update Service Request
--------------------------------------------

----------------------------------------------
-- Update_sr procedure assigns the values to
-- the service request record and calls the
-- update_servicerquest public api.
----------------------------------------------
PROCEDURE Update_sr(
  p_x_sr_task_rec  IN OUT NOCOPY AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
  x_return_status  OUT NOCOPY    VARCHAR2
) IS

  l_service_request_rec   CS_SERVICEREQUEST_PUB.service_request_rec_type;
  l_contacts_table        CS_ServiceRequest_PUB.contacts_table;
  l_notes_table           CS_ServiceRequest_PUB.notes_table;
  l_contact_primary_flag  CONSTANT VARCHAR2(1) := 'Y';

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

BEGIN

   -- Initialize the SR record.
   CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);


   -- Assign the SR rec values
   l_service_request_rec.status_id        := p_x_sr_task_rec.status_id;
   l_service_request_rec.status_name      := p_x_sr_task_rec.status_name;

   l_service_request_rec.urgency_id       := p_x_sr_task_rec.urgency_id;
   l_service_request_rec.urgency_name     := p_x_sr_task_rec.urgency_name;
   l_service_request_rec.problem_code     := p_x_sr_task_rec.problem_code;
   l_service_request_rec.resolution_code  := p_x_sr_task_rec.resolution_code;
   l_service_request_rec.last_update_program_code := p_x_sr_task_rec.source_program_code;

   /* R12(xbuild#1): Commenting out passing contacts table as CS API raises an error:
      API programming error ( CS_SRCONTACT_PKG.check_duplicates): This contact is
      a duplicate of a contact already associated with the service request. Each
      contact you associate must have a unique combination of party name and
      contact point.

   -- Contacts
   l_contacts_table(1).party_id           := p_x_sr_task_rec.contact_id;
   l_contacts_table(1).contact_type       := p_x_sr_task_rec.contact_type;
   l_contacts_table(1).primary_flag       := l_contact_primary_flag;
   */

   -- Call to Service Request API
   CS_SERVICEREQUEST_PUB.Update_ServiceRequest(
     p_api_version            => 3.0,
     p_init_msg_list          => FND_API.G_TRUE,
     p_commit                 => FND_API.G_FALSE,
     x_return_status          => x_return_status,
     x_msg_count              => l_msg_count,
     x_msg_data               => l_msg_data,
     p_request_id             => p_x_sr_task_rec.incident_id,
     --p_request_number         => p_x_sr_task_rec.incident_number,
     p_audit_comments         => Null,
     p_object_version_number  => p_x_sr_task_rec.incident_object_version_number,
     p_resp_appl_id           => NULL,
     p_resp_id                => NULL,
     p_last_updated_by        => NULL,
     p_last_update_login      => NULL,
     p_last_update_date       => NULL,
     p_service_request_rec    => l_service_request_rec,
     p_notes                  => l_notes_table,
     p_contacts               => l_contacts_table,
     p_called_by_workflow     => NULL,
     p_workflow_process_id    => NULL,
     x_workflow_process_id    => p_x_sr_task_rec.workflow_process_id,
     x_interaction_id         => p_x_sr_task_rec.interaction_id
   );

END Update_sr;

-----------------------------
-- Get Message Token
-----------------------------
Procedure get_msg_token(p_wo_id           in  number,
                        p_instance_id     in  number,
                        x_wo_name         out NOCOPY varchar2,
                        x_instance_number out NOCOPY varchar2)
IS
CURSOR GetWoName
    Is
    Select workorder_name
    from ahl_workorders
    where workorder_id = p_wo_id;
Cursor GetInstanceNumber
Is
    Select instance_number
    from csi_item_instances
    where instance_id = p_instance_id;
BEGIN
  Open  GetWoName;
  Fetch GetWoName into x_wo_name;
  Close GetWoName;

-- No exceptions were handled  in previous code.
-- Changed the big lengthy Begin------End; code for each sql to Cursor.
-- Too many (Invalid) exception handling got reduced.

  Open  GetInstanceNumber;
  Fetch GetInstanceNumber into  x_instance_number;
  Close GetInstanceNumber;

END get_msg_token;


-----------------------------------------
-- Get Note Information from the Message
-----------------------------------------
Procedure get_note_value(p_sr_task_rec IN  AHL_PRD_NONROUTINE_PVT.sr_task_rec_type,
                         x_note        OUT NOCOPY VARCHAR2,
                         x_note_detail OUT NOCOPY VARCHAR2)
IS
l_part_number      VARCHAR2(80);
l_serial_number    VARCHAR2(30);
l_wo_name          VARCHAR2(80);
l_instance_number  VARCHAR2(30);

CURSOR GetWoName
    Is
    Select workorder_name
    from ahl_workorders
    where workorder_id = p_sr_task_rec.originating_wo_id;

CURSOR GetInstanceDet
    Is
    Select ci.instance_number,
           ci.serial_number,
           msi.concatenated_segments
    from csi_item_instances ci,
         mtl_system_items_kfv msi
    where ci.instance_id = p_sr_task_rec.instance_id
    and   ci.inventory_item_id = msi.inventory_item_id
    and   ci.inv_master_organizatiOn_id = msi.organization_id;

BEGIN
  Open  GetWoName;
  Fetch GetWoName into l_wo_name;
  Close GetWoName;

  Open GetInstanceDet;
  Fetch GetInstanceDet into l_instance_number,l_serial_number,l_part_number;
  Close GetInstanceDet;

-- No exceptions were handled  in previous code.
-- Changed the big lengthy Begin------End; code for each sql to Cursor.
-- Too many (Invalid) exception handling got reduced.

  fnd_message.set_name('AHL','AHL_PRD_SR_NOTE');
  fnd_message.set_token('PART_NUMBER',l_part_number);
  fnd_message.set_token('SERIAL_NUMBER',l_serial_number);
  x_note := fnd_message.get;

  fnd_message.set_name('AHL','AHL_PRD_SR_NOTE_DETAIL');
  fnd_message.set_token('WO_NAME',l_wo_name);
  fnd_message.set_token('INSTANCE_NUMBER',l_instance_number);
  x_note_detail := fnd_message.get;

END get_note_value;

-----------------------------------
-- Write to Log
-- This procedure writes the input
-- values to a log file
-----------------------------------
Procedure write_to_log(p_sr_tasK_tbl IN ahl_prd_nonroutine_pvt.sr_task_tbl_type)
IS
BEGIN
    FOR i IN p_sr_task_tbl.FIRST..p_sr_task_tbl.LAST LOOP
    AHL_DEBUG_PUB.debug('INPUT - Type Id('||i||'):'||p_sr_task_tbl(i).type_id);
    AHL_DEBUG_PUB.debug('INPUT - Type Name('||i||'):'||p_sr_task_tbl(i).type_name);
    AHL_DEBUG_PUB.debug('INPUT - Status Id('||i||'):'||p_sr_task_tbl(i).status_id);
    AHL_DEBUG_PUB.debug('INPUT - Status Name('||i||'):'||p_sr_task_tbl(i).status_name);
    AHL_DEBUG_PUB.debug('INPUT - Severity Id('||i||'):'||p_sr_task_tbl(i).severity_id);
    AHL_DEBUG_PUB.debug('INPUT - Severity Name('||i||'):'||p_sr_task_tbl(i).severity_name);
    AHL_DEBUG_PUB.debug('INPUT - Urgency id('||i||'):'||p_sr_task_tbl(i).Urgency_id);
    AHL_DEBUG_PUB.debug('INPUT - Urgency name('||i||'):'||p_sr_task_tbl(i).Urgency_name);
    AHL_DEBUG_PUB.debug('INPUT - Customer type('||i||'):'||p_sr_task_tbl(i).Customer_type);
    AHL_DEBUG_PUB.debug('INPUT - Customer id('||i||'):'||p_sr_task_tbl(i).Customer_id);
    AHL_DEBUG_PUB.debug('INPUT - Customer name('||i||'):'||p_sr_task_tbl(i).Customer_name);
    AHL_DEBUG_PUB.debug('INPUT - Contact type('||i||'):'||p_sr_task_tbl(i).Contact_type);
    AHL_DEBUG_PUB.debug('INPUT - Contact Id('||i||'):'||p_sr_task_tbl(i).Contact_id);
    AHL_DEBUG_PUB.debug('INPUT - Contact name('||i||'):'||p_sr_task_tbl(i).Contact_name);
    AHL_DEBUG_PUB.debug('INPUT - Summary ('||i||'):'||p_sr_task_tbl(i).Summary);
    AHL_DEBUG_PUB.debug('INPUT - Instance Id('||i||'):'||p_sr_task_tbl(i).Instance_id);
    AHL_DEBUG_PUB.debug('INPUT - Instance number('||i||'):'||p_sr_task_tbl(i).Instance_number);
    AHL_DEBUG_PUB.debug('INPUT - Visit Id('||i||'):'||p_sr_task_tbl(i).visit_id);
    AHL_DEBUG_PUB.debug('INPUT - Visit number('||i||'):'||p_sr_task_tbl(i).visit_number);
    AHL_DEBUG_PUB.debug('INPUT - Originating wo id('||i||'):'||p_sr_task_tbl(i).originating_wo_id);
    AHL_DEBUG_PUB.debug('INPUT - Incident obj ver num('||i||'):'||p_sr_task_tbl(i).incident_object_version_number);
    AHL_DEBUG_PUB.debug('INPUT - Operation type('||i||'):'||p_sr_task_tbl(i).operation_type);
  END LOOP;

END write_to_log;

-----------------------------------
-- Write SR Rec to Log
-- This procedure writes the input
-- values of the SR API to a log file
-----------------------------------
Procedure write_sr_to_log
(
  p_service_request_rec   IN CS_SERVICEREQUEST_PUB.service_request_rec_type,
  p_notes_table           IN CS_SERVICEREQUEST_PUB.notes_table,
  p_contacts_table        IN CS_SERVICEREQUEST_PUB.contacts_table
)
IS
BEGIN
 AHL_DEBUG_PUB.debug('SR Rec:');
  AHL_DEBUG_PUB.debug('request_date:'||p_service_request_rec.request_date);
  AHL_DEBUG_PUB.debug('type_id:'||p_service_request_rec.type_id);
  AHL_DEBUG_PUB.debug('type_name:'||p_service_request_rec.type_name);
  AHL_DEBUG_PUB.debug('status_id:'||p_service_request_rec.status_id);
  AHL_DEBUG_PUB.debug('status_name:'||p_service_request_rec.status_name);
  AHL_DEBUG_PUB.debug('severity_id:'||p_service_request_rec.severity_id);
  AHL_DEBUG_PUB.debug('severity_name:'||p_service_request_rec.severity_name);
  AHL_DEBUG_PUB.debug('urgency_id:'||p_service_request_rec.urgency_id);
  AHL_DEBUG_PUB.debug('summary:'||p_service_request_rec.summary);
  AHL_DEBUG_PUB.debug('caller_type:'||p_service_request_rec.caller_type);
  AHL_DEBUG_PUB.debug('customer_id:'||p_service_request_rec.customer_id);
  AHL_DEBUG_PUB.debug('problem_code:'||p_service_request_rec.problem_code);
  AHL_DEBUG_PUB.debug('resolution_code:'||p_service_request_rec.resolution_code);
  AHL_DEBUG_PUB.debug('creation_program_code:'||p_service_request_rec.creation_program_code);
  AHL_DEBUG_PUB.debug('urgency_name:'||p_service_request_rec.urgency_name);

  -- Contacts
  AHL_DEBUG_PUB.debug('Contacts:');
  AHL_DEBUG_PUB.debug('party_id:'||p_contacts_table(1).party_id);
  AHL_DEBUG_PUB.debug('contact_type:'||p_contacts_table(1).contact_type);
  AHL_DEBUG_PUB.debug('primary_flag:'||p_contacts_table(1).primary_flag);

  -- Notes
  AHL_DEBUG_PUB.debug('Notes:');
  AHL_DEBUG_PUB.debug('note:'||p_notes_table(1).note);
  AHL_DEBUG_PUB.debug('note_detail:'||p_notes_table(1).note_detail);
  AHL_DEBUG_PUB.debug('note_type:'||p_notes_table(1).note_type);
  AHL_DEBUG_PUB.debug('note_context_type_01:'||p_notes_table(1).note_context_type_01);
END write_sr_to_log;


END AHL_PRD_NONROUTINE_PVT;

/
