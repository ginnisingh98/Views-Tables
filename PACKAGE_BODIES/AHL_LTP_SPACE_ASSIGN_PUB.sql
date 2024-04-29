--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SPACE_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SPACE_ASSIGN_PUB" AS
/* $Header: AHLPSANB.pls 115.10 2003/09/09 06:05:33 rroy noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_SPACE_ASSIGN_PUB';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-- PACKAGE
--    AHL_LTP_SPACE_ASSIGN_PUB
--
-- PURPOSE
--    This package is a Public API for managing Space Assignment information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SPACE_ASSIGNMENT:
--    Process_Space_Assignment (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 17-Apr-2002    ssurapan      Created.
--
-- PROCEDURE
--    Assign_Sch_Visit_Spaces
--
-- PURPOSE
--    Process Assigning Visit To Spaces and schedule a visit
--
-- PARAMETERS
--    p_x_space_assignment_tbl: the table representing space_assignment_tbl
--    p_x_schedule_visit_rec    Record representing  visit info
--
-- NOTES
--
PROCEDURE Assign_Sch_Visit_Spaces (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_space_assignment_tbl  IN  OUT NOCOPY Space_Assignment_Tbl,
   p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  )
 IS
 --
 l_api_name        CONSTANT VARCHAR2(30) := 'ASSIGN_SCH_VISIT_SPACES';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Assign_Sch_Visit_Spaces;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'enter ahl_ltp_space_assign_pub.Assign Sch Visit Spaces','+SPANT+');
   END IF;
   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
    IF p_x_space_assignment_tbl.COUNT > 0 THEN
	  FOR i IN p_x_space_assignment_tbl.FIRST..p_x_space_assignment_tbl.LAST
	  LOOP
        --
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'Schedule flag:'||p_x_schedule_visit_rec.schedule_flag);
   END IF;
		--
	    IF p_x_space_assignment_tbl(i).operation_flag = 'C' THEN
         Ahl_Ltp_Space_Assign_Pvt.CREATE_SPACE_ASSIGNMENT
           (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_x_space_assign_rec      => p_x_space_assignment_tbl(i),
            p_reschedule_flag         => p_x_schedule_visit_rec.schedule_flag,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );
    	-- To Update space assignment
        ELSIF p_x_space_assignment_tbl(i).operation_flag = 'U' THEN
         Ahl_Ltp_Space_Assign_Pvt.UPDATE_SPACE_ASSIGNMENT
           (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_module_type             => p_module_type,
            p_space_assign_rec        => p_x_space_assignment_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

	    -- To remove space assignment
	    ELSIF p_x_space_assignment_tbl(i).operation_flag = 'D' THEN
         Ahl_Ltp_Space_Assign_Pvt.DELETE_SPACE_ASSIGNMENT
           (
            p_api_version             => l_api_version,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_space_assign_rec        => p_x_space_assignment_tbl(i),
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );
        END IF;
		--
	  END LOOP;
	  --
      --Standard check to count messages
       l_msg_count := Fnd_Msg_Pub.count_msg;

      IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      --
     END IF;
     --

     IF P_X_SCHEDULE_VISIT_REC.VISIT_ID IS NOT NULL THEN
       Ahl_Ltp_Space_Assign_Pvt.Schedule_Visit
                       (p_api_version          => l_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        p_commit               => p_commit,
                        p_validation_level     => p_validation_level,
                        p_module_type          => p_module_type,
                        p_x_schedule_visit_rec => p_x_schedule_visit_rec,
                        x_return_status        => l_return_status,
                        x_msg_count            => l_msg_count,
                        x_msg_data             => l_msg_data);
     END IF; -- Visit ID
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
   Ahl_Debug_Pub.debug( 'End of Public api Assign Sch Visit Spaces','+SPANT+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Assign_Sch_Visit_Spaces;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

       Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
       Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Assign Sch Visit Spaces','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
   END IF;
WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO Assign_Sch_Visit_Spaces;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Assign Sch Visit Spaces','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO Assign_Sch_Visit_Spaces;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_ASSIGN_PUB',
                            p_procedure_name  =>  'ASSIGN_SCH_VISIT_SPACES',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Assign Sch Visit Spaces','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
END Assign_Sch_Visit_Spaces;
--
-- PROCEDURE
--    Schedule_Visit
--
-- PURPOSE
--    Schedule_Visit
--
-- PARAMETERS
--    p_schedule_visit_rec   : Record Representing Schedule_Visit_Rec
--
-- NOTES
--
PROCEDURE Schedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)IS
 l_api_name        CONSTANT VARCHAR2(30) := 'SCHEDULE_VISIT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT schedule_visit;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'enter ahl_ltp_space_assign_pub.Schedule Visit','+SPANT+');
   END IF;
   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
   IF P_X_SCHEDULE_VISIT_REC.VISIT_ID IS NOT NULL THEN
          Ahl_Ltp_Space_Assign_Pvt.Schedule_Visit
                       (p_api_version          => l_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        p_commit               => p_commit,
                        p_validation_level     => p_validation_level,
                        p_module_type          => p_module_type,
                        p_x_schedule_visit_rec => p_x_schedule_visit_rec,
                        x_return_status        => l_return_status,
                        x_msg_count            => l_msg_count,
                        x_msg_data             => l_msg_data);
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
   Ahl_Debug_Pub.debug( 'End of Public api Schedule Visit','+SPANT+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO schedule_visit;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        Ahl_Debug_Pub.log_app_messages (
            x_msg_count, x_msg_data, 'ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Schedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO schedule_visit;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
         Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Schedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO schedule_visit;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SPACE_ASSIGN_PUB',
                            p_procedure_name  =>  'SCHEDULE_VISIT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Schedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
END Schedule_Visit;
--
-- PROCEDURE
--    Unschedule_Visit
--
-- PURPOSE
--    Unschedule_Visit
--
-- PARAMETERS
--    p_schedule_visit_rec   : Record Representing Schedule_Visit_Rec
--
-- NOTES
--
PROCEDURE Unschedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS

 l_api_name        CONSTANT VARCHAR2(30) := 'UNSCHEDULE_VISIT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT unschedule_visit;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'enter ahl_ltp_space_assign_pub.Unschedule Visit','+SPANT+');
   END IF;
   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
   IF P_X_SCHEDULE_VISIT_REC.VISIT_ID IS NOT NULL THEN
          Ahl_Ltp_Space_Assign_Pvt.Unschedule_Visit
                       (p_api_version          => l_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        p_commit               => p_commit,
                        p_validation_level     => p_validation_level,
                        p_module_type          => p_module_type,
                        p_x_schedule_visit_rec => p_x_schedule_visit_rec,
                        x_return_status        => l_return_status,
                        x_msg_count            => l_msg_count,
                        x_msg_data             => l_msg_data);
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
   Ahl_Debug_Pub.debug( 'End of Public api Unschedule Visit','+SPANT+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO unschedule_visit;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

       Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
       Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Unschedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
   END IF;
WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO unschedule_visit;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Unschedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO unschedule_visit;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SPACE_ASSIGN_PUB',
                            p_procedure_name  =>  'UNSCHEDULE_VISIT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        Ahl_Debug_Pub.debug( 'ahl_ltp_space_assign_pub.Unschedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
    END IF;
END Unschedule_Visit;
--
END AHL_LTP_SPACE_ASSIGN_PUB;

/
