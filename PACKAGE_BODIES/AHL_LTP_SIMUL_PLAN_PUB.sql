--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SIMUL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SIMUL_PLAN_PUB" AS
/* $Header: AHLPSPNB.pls 115.7 2003/09/09 06:05:47 rroy noship $ */
--

G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_SIMUL_PLAN_PUB';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-----------------------------------------------------------
-- PACKAGE
--    AHL_LTP_SIMUL_PLAN_PUB
--
-- PURPOSE
--    This package is a Public API for managing Simulation plan information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SIMULATION_PLANS_VL:
--    Process_Simulation_plan (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 17-Apr-2002    ssurapan      Created.

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Simulation_Plan
--
-- PURPOSE
--    Process Simulation Plan
--
-- PARAMETERS
--    p_x_simulation_plan_tbl: the table representing simulation_plan_tbl
--
-- NOTES
--------------------------------------------------------------------

PROCEDURE Process_Simulation_plan (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := FND_API.g_false,
   p_commit                  IN     VARCHAR2  := FND_API.g_false,
   p_validation_level        IN     NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',
   p_x_simulation_plan_tbl   IN OUT NOCOPY Simulation_Plan_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
 )
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_SIMULATION_PLAN';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT process_simulation_plan;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pub.Process Simulation Plan','+SMPLN+');
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
   IF p_x_simulation_plan_tbl.COUNT > 0
   THEN
     FOR i IN p_x_simulation_plan_tbl.FIRST..p_x_simulation_plan_tbl.LAST
     LOOP
       IF p_x_simulation_plan_tbl(i).operation_flag = 'C' THEN
         AHL_LTP_SIMUL_PLAN_PVT.CREATE_SIMULATION_PLAN
           (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_x_simulation_plan_rec   => p_x_simulation_plan_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

          ELSIF p_x_simulation_plan_tbl(i).operation_flag = 'U' THEN

         AHL_LTP_SIMUL_PLAN_PVT.UPDATE_SIMULATION_PLAN
           (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_simulation_plan_rec     => p_x_simulation_plan_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

       ELSIF p_x_simulation_plan_tbl(i).operation_flag = 'D' THEN
         AHL_LTP_SIMUL_PLAN_PVT.DELETE_SIMULATION_PLAN
           (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_simulation_plan_rec     => p_x_simulation_plan_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );
         END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

      END LOOP;
   END IF;

   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Process Simulation plan','+SMPLN+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Process Simulation plan','+SMPLN+');
    END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_simulation_plan;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Process Simulation plan','+SMPLN+');
      END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO process_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PUB',
                            p_procedure_name  =>  'PROCESS_SIMULATION_PLAN',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Process Simulation Plan','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

END Process_Simulation_Plan;



--------------------------------------------------------------------
-- PROCEDURE
--    Process_Simulation_Visit
--
-- PURPOSE
--    Process Simulation Visit
--
-- PARAMETERS
--    p_x_simulation_visit_tbl      : Table Representing Simulation_Visit_Tbl
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Process_Simulation_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_simulation_visit_tbl    IN   OUT NOCOPY Simulation_Visit_Tbl,
   x_return_status                 OUT NOCOPY     VARCHAR2,
   x_msg_count                     OUT NOCOPY     NUMBER,
   x_msg_data                      OUT NOCOPY     VARCHAR2
)

IS

 l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_SIMULATION_VISIT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_visit_id                 NUMBER;
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT process_simulation_visit;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pub.Process Visits to Plan','+SMPLN+');
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
  IF p_simulation_visit_tbl.COUNT > 0
     THEN
        FOR i IN p_simulation_visit_tbl.FIRST..p_simulation_visit_tbl.LAST
        LOOP
           IF p_simulation_visit_tbl(i).operation_flag = 'X' THEN

   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'visit_id'||p_simulation_visit_tbl(i).visit_id);
       AHL_DEBUG_PUB.debug( 'plan_id'||p_simulation_visit_tbl(i).plan_id);
    END IF;

      AHL_LTP_SIMUL_PLAN_PVT.Copy_Visits_To_Plan (
                 p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 p_commit          => p_commit,
                 p_validation_level => p_validation_level,
                 p_module_type      => p_module_type,
                 p_visit_id         => p_simulation_visit_tbl(i).visit_id,
                 p_visit_number     => p_simulation_visit_tbl(i).primary_visit_number,
                 p_plan_id          => p_simulation_visit_tbl(i).plan_id,
                 p_v_ovn            => p_simulation_visit_tbl(i).visit_ovn,
                 p_p_ovn            => p_simulation_visit_tbl(i).plan_ovn,
                 x_visit_id         => l_visit_id,
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data);
       --Assign returned value
       p_simulation_visit_tbl(i).visit_id := l_visit_id;
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'pvisit_id'||p_simulation_visit_tbl(i).visit_id);
       AHL_DEBUG_PUB.debug( 'plan_id'||p_simulation_visit_tbl(i).plan_id);
       AHL_DEBUG_PUB.debug( 'flag'||p_simulation_visit_tbl(i).operation_flag);
    END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

/*
      ELSIF p_simulation_visit_tbl(i).operation_flag = 'D' THEN
        AHL_LTP_SIMUL_PLAN_PVT.Remove_Visits_FR_Plan (
                   p_api_version     => p_api_version,
                   p_init_msg_list   => p_init_msg_list,
                   p_commit          => p_commit,
                   p_validation_level => p_validation_level,
                   p_module_type      => p_module_type,
                   p_visit_id         => p_simulation_visit_tbl(i).visit_id,
                   p_plan_id          => p_simulation_visit_tbl(i).plan_id,
                   p_v_ovn            => p_simulation_visit_tbl(i).visit_ovn,
                   x_return_status    => l_return_status,
                   x_msg_count        => l_msg_count,
                   x_msg_data         => l_msg_data);
       --
 */
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'Pvisit_id'||p_simulation_visit_tbl(i).primary_visit_id);
       AHL_DEBUG_PUB.debug( 'plan_id'||p_simulation_visit_tbl(i).plan_id);
    END IF;


      ELSIF p_simulation_visit_tbl(i).operation_flag = 'C' THEN
         AHL_LTP_SIMUL_PLAN_PVT.Copy_Visits_To_Plan (
                 p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 p_commit          => p_commit,
                 p_validation_level => p_validation_level,
                 p_module_type      => p_module_type,
                 p_visit_id         => p_simulation_visit_tbl(i).primary_visit_id,
                 p_visit_number     => p_simulation_visit_tbl(i).primary_visit_number,
                 p_plan_id          => p_simulation_visit_tbl(i).plan_id,
                 p_v_ovn            => p_simulation_visit_tbl(i).visit_ovn,
                 p_p_ovn            => p_simulation_visit_tbl(i).plan_ovn,
                 x_visit_id         => l_visit_id,
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data);
   END IF;

   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'pvisit_id'||p_simulation_visit_tbl(i).visit_id);
       AHL_DEBUG_PUB.debug( 'plan_id'||p_simulation_visit_tbl(i).plan_id);
       AHL_DEBUG_PUB.debug( 'flag'||p_simulation_visit_tbl(i).operation_flag);
    END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

      IF p_simulation_visit_tbl(i).operation_flag = 'D' THEN
        AHL_LTP_SIMUL_PLAN_PVT.Remove_Visits_FR_Plan (
                   p_api_version     => p_api_version,
                   p_init_msg_list   => p_init_msg_list,
                   p_commit          => p_commit,
                   p_validation_level => p_validation_level,
                   p_module_type      => p_module_type,
                   p_visit_id         => p_simulation_visit_tbl(i).visit_id,
                   p_plan_id          => p_simulation_visit_tbl(i).plan_id,
                   p_v_ovn            => p_simulation_visit_tbl(i).visit_ovn,
                   x_return_status    => l_return_status,
                   x_msg_count        => l_msg_count,
                   x_msg_data         => l_msg_data);
       END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   END LOOP;
 END IF;
   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Process Simulation Visit','+SMPLN+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_simulation_visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Process Simulation Visit','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_simulation_visit;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Process Simulation Visit','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO process_simulation_visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PUB',
                            p_procedure_name  =>  'PROCESS_SIMULATION_VISIT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Process Simulation visit','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 END Process_Simulation_Visit;



--------------------------------------------------------------------
-- PROCEDURE
--    Toggle_Simulation_Delete
--
-- PURPOSE
--    Toggle Simulation Delete/Undelete
--
-- PARAMETERS
--    p_visit_id                    : Visit Id
--    p_visit_object_version_number : Visit Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Toggle_Simulation_Delete (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                      IN      NUMBER,
   p_visit_object_version_number   IN      NUMBER,
   x_return_status                 OUT NOCOPY     VARCHAR2,
   x_msg_count                     OUT NOCOPY     NUMBER,
   x_msg_data                      OUT NOCOPY     VARCHAR2
)
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'TOGGLE_SIMULATION_DELETE';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --

 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT toggle_simulation_delete;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pub.Toggle Simulation Delete','+SMPLN+');
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
   --Call Private APT
       AHL_LTP_SIMUL_PLAN_PVT.Toggle_Simulation_Delete (
               p_api_version  => p_api_version,
               p_init_msg_list => p_init_msg_list,
               p_commit        => p_commit,
               p_validation_level  => p_validation_level,
               p_module_type      => p_module_type,
               p_visit_id         => p_visit_id,
               p_visit_object_version_number  => p_visit_object_version_number,
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);


   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Toggle Simulation Delete','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Toggle Simulation Delete','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Toggle Simulation Delete','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PUB',
                            p_procedure_name  =>  'TOGGLE_SIMULATION_DELETE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Toggle Simulation Delete','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 END Toggle_Simulation_Delete;


--------------------------------------------------------------------
-- PROCEDURE
--    Set_Plan_As_Primary
--
-- PURPOSE
--    Set Plan As Primary
--
-- PARAMETERS
--    p_plan_id                     : Simulation Plan Id
--    p_object_version_number       : Plan Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Set_Plan_As_Primary (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_plan_id                 IN      NUMBER,
   p_object_version_number   IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS

 l_api_name        CONSTANT VARCHAR2(30) := 'SET_PLAN_AS_PRIMARY';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --

 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT set_plan_as_primary;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pub. Set Plan as Primary','+SMPLN+');
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
   --Call Private APT
       AHL_LTP_SIMUL_PLAN_PVT.Set_Plan_As_Primary (
               p_api_version            => p_api_version,
               p_init_msg_list          => p_init_msg_list,
               p_commit                 => p_commit,
               p_validation_level       => p_validation_level,
               p_module_type            => p_module_type,
               p_plan_id                => p_plan_id,
               p_object_version_number  => p_object_version_number,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data);


   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Set Plan as primary','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO set_plan_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Set plan as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO set_plan_as_primary;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Set Plan as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO set_plan_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PUB',
                            p_procedure_name  =>  'SET_PLAN_AS_PRIMARY',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Set plan as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 END Set_Plan_As_Primary;


--------------------------------------------------------------------
-- PROCEDURE
--    Set_Visit_As_Primary
--
-- PURPOSE
--    Set Visit As Primary
--
-- PARAMETERS
--    p_visit_id                    : Simulation Visit Id
--    p_object_version_number       : Visit Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Set_Visit_As_Primary (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   p_plan_id                 IN      NUMBER,
   p_object_version_number   IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS

 l_api_name        CONSTANT VARCHAR2(30) := 'SET_VISIT_AS_PRIMARY';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --

 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT set_visit_as_primary;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pub. Set Visit as Primary','+SMPLN+');
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
   --Call Private APT
       AHL_LTP_SIMUL_PLAN_PVT.Set_Visit_As_Primary (
               p_api_version            => p_api_version,
               p_init_msg_list          => p_init_msg_list,
               p_commit                 => p_commit,
               p_validation_level       => p_validation_level,
               p_module_type            => p_module_type,
               p_visit_id               => p_visit_id,
               p_plan_id                => p_plan_id,
               p_object_version_number  => p_object_version_number,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data);


   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Set Visit as primary','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO set_visit_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Set visit as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO set_visit_as_primary;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Set Visit as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO set_visit_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PUB',
                            p_procedure_name  =>  'SET_VISIT_AS_PRIMARY',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pub.Set visit as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
 END Set_Visit_As_Primary;
--
END AHL_LTP_SIMUL_PLAN_PUB;

/
