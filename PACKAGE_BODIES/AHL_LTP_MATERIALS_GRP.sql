--------------------------------------------------------
--  DDL for Package Body AHL_LTP_MATERIALS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_MATERIALS_GRP" AS
/* $Header: AHLGMTLB.pls 120.0.12010000.3 2010/02/25 10:07:57 skpathak noship $ */
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;



----------------------------------------
-- Start of Comments --
--  Procedure name    : Update_mtl_resv_dates
--  Type              : Public
--  Function          : Update material requirement date and serial
--                      reservation dates with WO scheduled start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Update_mtl_resv_dates Parameters:
--      p_wip_entity_id                 IN      NUMBER       Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_mtl_resv_dates
(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT  NOCOPY   VARCHAR2,
   x_msg_count             OUT  NOCOPY   NUMBER,
   x_msg_data              OUT  NOCOPY   VARCHAR2,
   p_wip_entity_id         IN            NUMBER
)
IS
   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)      := 'Update_mtl_resv_dates';
   l_api_version   CONSTANT      NUMBER            := 1.0;
   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(2000);
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
   i                             NUMBER;
   l_scheduled_material_id       NUMBER;
   l_requested_date              DATE;

-- To get all the scheduled_material_ids for the given wip_entity_id
-- for which requested date is not equal to WO scheduled start date
CURSOR get_scheduled_material_id (c_wip_entity_id  IN NUMBER,
                                  c_requested_date IN DATE) IS
  SELECT asmt.scheduled_material_id
   FROM ahl_workorders awo, ahl_schedule_materials asmt
   WHERE awo.visit_task_id = asmt.visit_task_id
    AND awo.wip_entity_id= c_wip_entity_id
    AND asmt.requested_date <> trunc(c_requested_date)
    AND asmt.status <> 'DELETED';

-- To fetch the Workorder schedule start date for the given wip entity id
CURSOR get_scheduled_start_date (c_wip_entity_id  IN NUMBER) IS
  SELECT scheduled_start_date
   FROM wip_discrete_jobs
   WHERE wip_entity_id= c_wip_entity_id;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT Update_mtl_resv_dates_grp;

   -- Initialize return status to success before any code logic/validation
   x_return_status   := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- Log API entry point
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
      (
         fnd_log.level_procedure,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
         'At the start of PL SQL procedure p_wip_entity_id = ' || p_wip_entity_id
      );
   END IF;
   -- Get the scheduled start date for the given wip_entity_id into l_requested_date
   OPEN get_scheduled_start_date (p_wip_entity_id);
   FETCH get_scheduled_start_date INTO l_requested_date;
   CLOSE get_scheduled_start_date;

   -- IF the schedule start date corresponding the input wip entity id fetched above is null
   -- then the wip entity id passed to this procedure is invalid
   IF l_requested_date IS NULL THEN
      Fnd_Message.SET_NAME('AHL','AHL_LTP_WIP_ENTITY_ID_INVLD');
      Fnd_Msg_Pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN get_scheduled_material_id(p_wip_entity_id, l_requested_date);
    i:=1;
    -- Loop for all the scheduled material ids for the given wip_entity_id
    -- for which material requested date is not equal to WO scheduled start date
    -- since if these are equal then dates are already synchronized, so no need to update the dates
    LOOP
      FETCH get_scheduled_material_id INTO l_scheduled_material_id;
      EXIT WHEN get_scheduled_material_id%NOTFOUND;

        IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string
            (
             fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
             'Inside the loop i= ' || i || ', scheduled_material_id = ' || l_scheduled_material_id
            );
        END IF;

        -- This API updates all the reservation dates, if l_requested_date
        -- and requested_date in AHL_SCHEDULE_MATERIALS table are different
        AHL_RSV_RESERVATIONS_PVT.Update_Reservation(
           p_api_version           => 1.0,
           p_init_msg_list         => FND_API.G_FALSE,
           p_commit                => FND_API.G_FALSE,
           p_module_type           => NULL,
           x_return_status         => l_return_status,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data,
           p_scheduled_material_id => l_scheduled_material_id,
           p_requested_date        => l_requested_date);

           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string
                 (
                  fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                  'Returned success from AHL_RSV_RESERVATIONS_PVT.Update_Reservation'
                 );
             END IF;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSE
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        -- Now update AHL_SCHEDULE_MATERIALS table with requested_date as l_requested_date
        UPDATE AHL_SCHEDULE_MATERIALS
        SET requested_date    = trunc(l_requested_date),
        last_update_date      = sysdate,
        last_updated_by       = fnd_global.user_id,
        last_update_login     = fnd_global.login_id
        WHERE  scheduled_material_id  = l_scheduled_material_id;

      i := i + 1;
    END LOOP;
    IF (l_log_statement >= l_log_current_level)THEN
     fnd_log.string
         (
          fnd_log.level_statement, 'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'After end of the loop, total number of iteration to modify date = ' || (i-1)
         );
    END IF;
   CLOSE get_scheduled_material_id;

   -- End logging
   IF (l_log_procedure >= l_log_current_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;

   -- Check Error Message stack.
   x_msg_count := FND_MSG_PUB.count_msg;
   IF x_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

      -- Commit if p_commit = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_commit)
   THEN
      COMMIT WORK;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'Committed'
         );
      END IF;
   END IF;


   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.count_and_get
   (
           p_count         => x_msg_count,
           p_data          => x_msg_data,
           p_encoded       => FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Update_mtl_resv_dates_grp;
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.count_and_get
           (
                   p_count         => x_msg_count,
                   p_data          => x_msg_data,
                   p_encoded       => FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Update_mtl_resv_dates_grp;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.count_and_get
           (
                   p_count         => x_msg_count,
                   p_data          => x_msg_data,
                   p_encoded       => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
           ROLLBACK TO Update_mtl_resv_dates_grp;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                   FND_MSG_PUB.add_exc_msg
                   (
                           p_pkg_name              => G_PKG_NAME,
                           p_procedure_name        => 'Update_mtl_resv_dates',
                           p_error_text            => SUBSTR(SQLERRM,1,240)
                    );
           END IF;
           FND_MSG_PUB.count_and_get
           (
                   p_count         => x_msg_count,
                   p_data          => x_msg_data,
                   p_encoded       => FND_API.G_FALSE
           );
END Update_mtl_resv_dates;


END AHL_LTP_MATERIALS_GRP;

/
