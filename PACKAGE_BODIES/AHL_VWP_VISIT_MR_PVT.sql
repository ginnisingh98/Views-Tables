--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISIT_MR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISIT_MR_PVT" AS
/* $Header: AHLVVMRB.pls 120.0 2005/05/26 00:09:34 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--    Ahl_VWP_Visit_MR_Pvt
--
-- PROCEDURES
--
-- NOTES
--
-- HISTORY
-- 06-MAY-2003    SHBHANDA      Created.
-- 21-AUGUST-2003        Calling procedure was added with due logic
--                       By Rajanath Tadikonda
--
-----------------------------------------------------------------
-- Global CONSTANTS
G_PKG_NAME              CONSTANT VARCHAR2(30):= 'AHL_VWP_VISIT_MR_PVT';
G_DEBUG                          VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;
-----------------------------------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Visit_MRs
--
---------------------------------------------------------------------
PROCEDURE Process_Visit_MRs (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_Visit_MR_Tbl         IN  Visit_MR_Tbl_Type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   -- Added be amagrawa beased on review comments
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   -- Modified be amagrawa beased on review comments
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Process_Visit_MRs';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Process_Visit_MRs;
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF  p_Visit_MR_Tbl.COUNT=0
   THEN
           RETURN;
   ELSIF  p_Visit_MR_Tbl.COUNT>0
   THEN

   FOR i in  p_Visit_MR_Tbl.first.. p_Visit_MR_Tbl.last
   LOOP
   AHL_VWP_TASKS_PVT.Delete_Task (
      p_api_version       => p_api_version,
      p_init_msg_list     => Fnd_Api.g_false,
      p_commit            => Fnd_Api.g_false,
      p_validation_level  =>Fnd_Api.g_valid_level_full,
      p_module_type       => p_module_type,
      p_Visit_Task_Id     =>p_Visit_MR_Tbl(i).visit_task_id,
      x_return_status     =>x_return_status,
      x_msg_count         =>x_msg_count,
      x_msg_data          =>x_msg_data);
      -- Added be amagrawa beased on review comments
        IF l_return_status <> 'S' THEN
              RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
   END LOOP;
   END IF;



 ---------------------------End of Body-------------------------------------
  --
  -- END of API body.

-- Added be amagrawa beased on review comments
--Standard check to count messages
	l_msg_count := Fnd_Msg_Pub.count_msg;

    IF l_msg_count > 0 THEN
       X_msg_count := l_msg_count;
       X_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

  --
  -- Standard check of p_commit.
   IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

  IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
   END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Process_Visit_MRs;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Process_Visit_MRs;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Process_Visit_MRs;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
END Process_Visit_MRs;

END AHL_VWP_VISIT_MR_PVT;

/
