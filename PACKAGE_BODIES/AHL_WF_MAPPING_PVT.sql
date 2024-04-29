--------------------------------------------------------
--  DDL for Package Body AHL_WF_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_WF_MAPPING_PVT" AS
/* $Header: AHLVWFMB.pls 120.4 2006/08/23 09:40:48 sathapli noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AHL_Wf_Mapping_PVT
--
-- PROCEDURES
--    AHL_Wf_Mapping:
--       Check_Wf_Mapping_Req_Items
--       Check_Wf_Mapping_UK_Items
--       Check_Process_Name
--       Check_Default
--
-- NOTES
--
-- HISTORY
-- 20-Jan-2002    shbhanda      Created.
-----------------------------------------------------------
--
-- Global CONSTANTS
G_PKG_NAME       CONSTANT VARCHAR2(30) := 'AHL_Wf_Mapping_PVT';
G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
G_VALID_NAME     CONSTANT NUMBER:= 50;

--       Check_Wf_Mapping_Req_Items
PROCEDURE Check_Wf_Mapping_Req_Items (
   p_Wf_Mapping_rec    IN    Wf_Mapping_Rec_Type,
   x_return_status    OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Appl_Usg_Code(
	      p_wf_mapping_rec  IN  Wf_Mapping_Rec_Type,
	   x_return_status      OUT NOCOPY VARCHAR2
	);

--       Check_Wf_Mapping_UK_Items
PROCEDURE Check_Wf_Mapping_UK_Items (
   p_Wf_Mapping_rec    IN    Wf_Mapping_Rec_Type,
   p_validation_mode  IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status    OUT NOCOPY   VARCHAR2
);

--      Check_Process_Name when the value is not selected from LOV's
PROCEDURE Check_Process_Name(
   p_wf_mapping_rec     IN  wf_mapping_Rec_Type,
   x_item_type          OUT NOCOPY VARCHAR2,
   x_process_name       OUT NOCOPY VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2
);

--      Check_Default there can be only one
PROCEDURE Check_Default (
   p_wf_mapping_rec IN  wf_mapping_Rec_Type,
   p_complete_rec       IN  wf_mapping_Rec_Type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-----          Wf_Mapping           -----
--------------------------------------------------------------------

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Wf_Mapping
--
--------------------------------------------------------------------
PROCEDURE Process_Wf_Mapping (
   p_api_version          IN  NUMBER    := 1.0,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_x_Wf_Mapping_tbl     IN  OUT NOCOPY Wf_Mapping_tbl,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Process_Wf_Mapping';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_x_Wf_Mapping_tbl   Wf_Mapping_tbl := p_x_Wf_Mapping_tbl;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   p_object_version VARCHAR2(1) := 1;
   x_WF_Mapping_ID      NUMBER;

BEGIN
    --------------------- initialize -----------------------
   SAVEPOINT Process_Wf_Mapping;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
    END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Validate');
   END IF;

   IF (l_x_Wf_Mapping_tbl.COUNT > 0) THEN
        FOR i IN l_x_Wf_Mapping_tbl.FIRST..l_x_Wf_Mapping_tbl.LAST LOOP
          IF (l_x_Wf_Mapping_tbl(i).operation_flag = 'C' or l_x_Wf_Mapping_tbl(i).operation_flag = 'c') THEN
            -- For creation of AHL_WF_MAPPING
              Create_Wf_Mapping (
                p_api_version,
                p_init_msg_list,
                p_commit,
                p_validation_level,
                l_x_Wf_Mapping_tbl(i),
                x_return_status ,
                x_msg_count,
                x_msg_data,
                x_WF_Mapping_ID);

                p_x_Wf_Mapping_tbl(i).Wf_Mapping_Id := x_WF_Mapping_ID;

          END IF;
          IF (p_x_Wf_Mapping_tbl(i).operation_flag = 'U' or l_x_Wf_Mapping_tbl(i).operation_flag = 'u') THEN
            -- For updation of AHL_WF_MAPPING
              Update_Wf_Mapping (
                p_api_version ,
                p_init_msg_list,
                p_commit,
                p_validation_level,
                l_x_Wf_Mapping_tbl(i),
                x_return_status,
                x_msg_count,
                x_msg_data);
           END IF;
           IF (p_x_Wf_Mapping_tbl(i).operation_flag = 'D' or l_x_Wf_Mapping_tbl(i).operation_flag = 'd') THEN
            -- For deletion of AHL_WF_MAPPING
              Delete_wf_mapping (
                   p_api_version,
                   p_init_msg_list,
                   p_commit,
                   p_validation_level,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   p_x_Wf_Mapping_tbl(i).Wf_Mapping_Id,
                   p_object_version);
            END IF;
        END LOOP;
   END IF;

   IF l_return_status = Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
   ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

   --
   -- END of API body.
   --
   -- Standard check of p_commit.
   IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
    END IF;
-- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
  END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Process_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Process_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Process_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
         Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Process_Wf_Mapping;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Wf_Mapping
--
--------------------------------------------------------------------

PROCEDURE Create_Wf_Mapping (
   p_api_version          IN  NUMBER	:= 1.0,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Wf_Mapping_rec       IN  Wf_Mapping_Rec_Type,

   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_Wf_Mapping_ID        OUT NOCOPY NUMBER
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Wf_Mapping';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_Wf_Mapping_rec      Wf_Mapping_Rec_Type := p_Wf_Mapping_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   l_item_type          VARCHAR2(8);
   l_rowid              VARCHAR2(30);
   l_object_version_number NUMBER := 1;
   l_seed           varchar(1) := 'N';
   l_process_name   varchar2(30);

   CURSOR c_seq IS
      SELECT Ahl_Wf_Mapping_S.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   AHL_Wf_Mapping
                    WHERE  WF_Mapping_ID = x_id);

-- To retrieve item type for the entered process name not selected from LOV's
      /*cursor c_item_type Is
      select ITEM_TYPE
      from WF_RUNNABLE_PROCESSES_V
      where PROCESS_NAME = p_wf_mapping_rec.WF_PROCESS_NAME;
      */

							CURSOR c_appl_usg IS
	      SELECT LOOKUP_CODE
	      FROM FND_LOOKUPS
	      WHERE MEANING = l_Wf_Mapping_rec.APPLICATION_USG
	      AND LOOKUP_TYPE = 'AHL_APPLICATION_USAGE_CODE';


BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_Wf_Mapping;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
    END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call (
         L_API_VERSION,
         p_api_version,
         L_API_NAME,
         G_PKG_NAME
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;
   ----------------------- validate -----------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Validate');
   END IF;

  -- Check for default approval obeject in default workflow process
  --
  IF l_Wf_Mapping_rec.Approval_Object IS NULL THEN
      Check_Default (
         p_wf_mapping_rec      => p_wf_mapping_rec,
         p_complete_rec        => l_wf_mapping_rec,
         x_return_status       => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
  END IF;

   Validate_Wf_Mapping (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_commit             => p_commit,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_Wf_Mapping_rec     => l_Wf_Mapping_rec
   );

   IF l_return_status = Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
   ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

   --
   -- Check for the ID.
   --
   IF l_Wf_Mapping_rec.WF_Mapping_ID = fnd_api.g_miss_num OR l_Wf_Mapping_rec.WF_Mapping_ID is null THEN
   --IF l_Wf_Mapping_rec.WF_Mapping_ID is null THEN
      LOOP
         --
         -- If the ID is not passed into the API, then grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_Wf_Mapping_rec.WF_Mapping_ID;
         CLOSE c_seq;
         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_Wf_Mapping_rec.WF_Mapping_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         --
         -- If the value for the ID already exists, then l_dummy would be populated
         -- with '1', otherwise, it receives NULL.
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

  -- Check whether procees name entered is valid not selected from LOV's
  --
  IF l_Wf_Mapping_rec.Wf_display_Name IS NOT NULL THEN --and l_Wf_Mapping_rec.Item_type IS NULL THEN
      Check_Process_Name (
         p_wf_mapping_rec      => p_wf_mapping_rec,
         x_item_type           => l_item_type,
	 x_process_name        => l_process_name,
         x_return_status       => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      ELSE
       --if process name is valid then grab value of item type from c_item_type cursor
       --
         /*OPEN c_item_type;
         FETCH c_item_type INTO l_Wf_Mapping_rec.Item_type;
         CLOSE c_item_type;*/
	 l_Wf_Mapping_rec.Item_type := l_item_type;
	 l_wf_mapping_rec.wf_process_name := UPPER(l_process_name);
      END IF;
  END IF;

/*IF p_validation_level >= G_VALID_NAME THEN
 Check_Appl_Usg_Code (p_wf_mapping_rec  => p_wf_mapping_rec,
	           x_return_status       => l_return_status
	         );

   IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
           RAISE Fnd_Api.g_exc_unexpected_error;
   ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
           RAISE Fnd_Api.g_exc_error;
   ELSE
           OPEN  c_appl_usg;
           FETCH c_appl_usg INTO l_Wf_Mapping_rec.Application_Usg_Code;
          IF c_appl_usg%NOTFOUND THEN
         	IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
	     		 Fnd_Message.set_name ('AHL', 'AHL_APPR_APPUSG_INVALID');
	       		 Fnd_Msg_Pub.ADD;
	        END IF;
		RAISE Fnd_Api.g_exc_unexpected_error;
	   END IF;
    END IF;
END IF;
*/
   -------------------------- insert --------------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Insert');
    END IF;

   -- Invoke the table handler to create a record
   --
   -- l_process_name := UPPER(l_Wf_Mapping_rec.WF_PROCESS_NAME) ;
   Ahl_Wf_Mapping_Pkg.insert_row (
     X_ROWID                 => l_rowid,
     X_WF_Mapping_ID         => l_Wf_Mapping_rec.WF_Mapping_ID,
     X_OBJECT_VERSION_NUMBER => 1,
     X_CREATION_DATE         => SYSDATE,
     X_CREATED_BY            => Fnd_Global.USER_ID,
     X_LAST_UPDATE_DATE      => SYSDATE,
     X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
     X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
     X_ACTIVE_FLAG           => l_Wf_Mapping_rec.ACTIVE_FLAG,
     X_WF_PROCESS_NAME       => l_wf_mapping_rec.wf_process_name,
     X_APPROVAL_OBJECT       => l_Wf_Mapping_rec.APPROVAL_OBJECT,
     X_ITEM_TYPE             => l_Wf_Mapping_rec.ITEM_TYPE,
     X_APPLICATION_USG_CODE  => l_Wf_Mapping_rec.APPLICATION_USG_CODE
      );

   ------------------------- finish -------------------------------

     -- set OUT value
        x_WF_Mapping_ID := l_Wf_Mapping_rec.WF_Mapping_ID;
        --
        -- END of API body.
        --
        -- Standard check of p_commit.
   IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
   IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
    END IF;
-- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
         Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_Wf_Mapping;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Wf_Mapping
--
--------------------------------------------------------------------
PROCEDURE Update_Wf_Mapping (
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Wf_Mapping_rec     IN  Wf_Mapping_Rec_Type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_Wf_Mapping';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_Wf_Mapping_rec      Wf_Mapping_Rec_Type := p_Wf_Mapping_rec;
   l_dummy              NUMBER;
   l_return_status      VARCHAR2(1);
   l_process_name       VARCHAR2(30);
   l_item_type          VARCHAR2(8);

   -- To retrieve item type for the entered process name not selected from LOV's
      cursor c_item_type Is
      select ITEM_TYPE
      from WF_RUNNABLE_PROCESSES_V
      where PROCESS_NAME = p_wf_mapping_rec.WF_PROCESS_NAME;

      CURSOR c_appl_usg IS
      SELECT LOOKUP_CODE
      FROM FND_LOOKUPS
      WHERE MEANING = l_Wf_Mapping_rec.APPLICATION_USG
      AND LOOKUP_TYPE = 'AHL_APPLICATION_USAGE_CODE';


BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Wf_Mapping;
  -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
    END IF;
   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;
   ----------------------- validate ----------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Validate');
    END IF;

   --Check for default approval obeject in default workflow process
   --
  IF l_Wf_Mapping_rec.Approval_Object IS NULL THEN
      Check_Default (
         p_wf_mapping_rec      => p_wf_mapping_rec,
         p_complete_rec        => l_wf_mapping_rec,
         x_return_status       => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
  END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_Wf_Mapping_Rec (p_Wf_Mapping_rec, l_Wf_Mapping_rec);

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Wf_Mapping_Items (
         p_Wf_Mapping_rec     => p_Wf_Mapping_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_update,
         x_return_status      => l_return_status

      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

  -- Check whether procees name entered is valid not selected from LOV's
  --
  IF l_Wf_Mapping_rec.Wf_display_Name IS NOT NULL THEN --and l_Wf_Mapping_rec.Item_type IS NULL THEN
      Check_Process_Name (
         p_wf_mapping_rec      => p_wf_mapping_rec,
         x_item_type           => l_item_type,
	 x_process_name        => l_process_name,
         x_return_status       => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      ELSE
       --if process name is valid then grab value of item type from c_item_type cursor
       --
        /* OPEN c_item_type;
         FETCH c_item_type INTO l_Wf_Mapping_rec.Item_type;
         CLOSE c_item_type;
	 */
	 l_Wf_Mapping_rec.Item_type := l_item_type;
	 l_Wf_Mapping_rec.wf_process_name := UPPER(l_process_name);
      END IF;
  END IF;
/*IF p_validation_level >= G_VALID_NAME THEN
	        Check_Appl_Usg_Code (
	           p_wf_mapping_rec  => p_wf_mapping_rec,
	           x_return_status       => l_return_status
	         );
	         IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
	            RAISE Fnd_Api.g_exc_unexpected_error;
	         ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
	            RAISE Fnd_Api.g_exc_error;
	         ELSE
	            OPEN  c_appl_usg;
	            FETCH c_appl_usg INTO l_Wf_Mapping_rec.Application_Usg_Code;
		          IF c_appl_usg%NOTFOUND THEN
		 									IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
			       		 Fnd_Message.set_name ('AHL', 'AHL_APPR_APPUSG_INVALID');
			       		 Fnd_Msg_Pub.ADD;
	           END IF;
												RAISE Fnd_Api.g_exc_unexpected_error;
	           END IF;
					     END IF;
	  END IF;
*/
  -------------------------- update --------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Update');
    END IF;

   --l_process_name := UPPER(l_Wf_Mapping_rec.WF_PROCESS_NAME);
  Ahl_Wf_Mapping_Pkg. UPDATE_ROW (
     X_WF_Mapping_ID         => l_Wf_Mapping_rec.WF_Mapping_ID,
     X_OBJECT_VERSION_NUMBER => l_Wf_Mapping_rec.OBJECT_VERSION_NUMBER + 1,
     X_LAST_UPDATE_DATE      => SYSDATE,
     X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
     X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
     X_ACTIVE_FLAG           => l_Wf_Mapping_rec.ACTIVE_FLAG,
     X_WF_PROCESS_NAME       => l_process_name,
     X_APPROVAL_OBJECT       => l_Wf_Mapping_rec.APPROVAL_OBJECT,
     X_ITEM_TYPE             => l_Wf_Mapping_rec.item_type,
X_APPLICATION_USG_CODE  => l_Wf_Mapping_rec.APPLICATION_USG_CODE
   );

   -------------------- finish --------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;
   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
    END IF;
-- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Wf_Mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
                THEN
         Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Wf_Mapping;

--------------------------------------------------------------------
-- PROCEDURE
-- Check_Process_Name
-- Check process name if present in WF_RUNNABLE_PROCESSES_V view or
-- raise an error message
--------------------------------------------------------------------

PROCEDURE Check_Process_Name(
   p_wf_mapping_rec     IN  wf_mapping_Rec_Type,
   x_item_type          OUT NOCOPY VARCHAR2,
   x_process_name       OUT NOCOPY VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
    l_count   number;
    cursor cur_process_name Is
    -- SATHAPLI::Bug# 4919061 fix::SQL Id 14401778
    /*
    select item_type, process_name from WF_RUNNABLE_PROCESSES_V
    where UPPER(display_name) = UPPER(p_wf_mapping_rec.wf_display_name);
    */
    SELECT /* PARALLEL (B) +*/
           B.ITEM_TYPE item_type,
           B.NAME process_name
    FROM   WF_ACTIVITIES B,
           WF_ACTIVITIES_TL T
    WHERE  B.ITEM_TYPE     = T.ITEM_TYPE
    AND    B.NAME          = T.NAME
    AND    B.VERSION       = T.VERSION
    AND    T.LANGUAGE      = USERENV('LANG')
    AND    B.RUNNABLE_FLAG = 'Y'
    AND    B.TYPE          = 'PROCESS'
    AND    SYSDATE BETWEEN B.BEGIN_DATE AND NVL(B.END_DATE, SYSDATE)
    -- SATHAPLI::Bug# 5359954 fix
    /*
    AND    UPPER(T.DISPLAY_NAME) = UPPER(p_wf_mapping_rec.wf_display_name);
    */
    AND    UPPER(T.NAME) = UPPER(p_wf_mapping_rec.wf_process_name);

    cursor cur_process_name_type is
    select item_type, process_name from wf_runnable_processes_v
    -- SATHAPLI::Bug# 5359954 fix
    /*
    where UPPER(display_name) = UPPER(p_wf_mapping_rec.wf_display_name)
    */
    where item_type = p_wf_mapping_rec.item_type
    and UPPER(process_name) = UPPER( p_wf_mapping_rec.wf_process_name) ;

    cur_process_name_rec cur_process_name%rowtype;

BEGIN
      IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug('inside check_process_name LANG = '||USERENV('LANG')||
	                      ' p_wf_mapping_rec.wf_display_name = '||p_wf_mapping_rec.wf_display_name||
			      ' p_wf_mapping_rec.item_type = '||p_wf_mapping_rec.item_type||
			      ' p_wf_mapping_rec.wf_process_name = '||p_wf_mapping_rec.wf_process_name);
      END IF;

      OPEN cur_process_name_type;
      FETCH cur_process_name_type into cur_process_name_rec;
      IF cur_process_name_type%NOTFOUND THEN
       	Open cur_process_name;
	LOOP
	  EXIT WHEN cur_process_name%NOTFOUND;
      	  Fetch cur_process_name into cur_process_name_rec;
      	END LOOP;
        IF cur_process_name%ROWCOUNT = 0 THEN
	          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
		Fnd_Message.set_name ('AHL', 'AHL_WF_NOT_PROCESS');
		  Fnd_Msg_Pub.ADD;
        	  END IF;
		  x_return_status := Fnd_Api.g_ret_sts_error;
		  RETURN;
	ELSIF cur_process_name%ROWCOUNT > 1 THEN
	          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
		  Fnd_Message.set_name ('AHL', 'AHL_WF_PROCESS_USELOV');
		  Fnd_Msg_Pub.ADD;
        	  END IF;
		  x_return_status := Fnd_Api.g_ret_sts_error;
	 	  RETURN;
	END IF;
      close cur_process_name;
      END IF;
      close cur_process_name_type;
      x_item_type := cur_process_name_rec.item_type;
      x_process_name := cur_process_name_rec.process_name;

END Check_Process_Name;

--------------------------------------------------------------------
-- PROCEDURE
-- Check_Default
-- Check is Default workflow process is more than one, when approval object is null
--
--------------------------------------------------------------------

PROCEDURE Check_Default(
   p_wf_mapping_rec IN  wf_mapping_Rec_Type,
   p_complete_rec   IN  wf_mapping_Rec_Type := NULL,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
    l_count   number;
    l_wf_id   number;
    l_application_usg_code VARCHAR2(30);
    cursor check_object(c_appl_usg_code IN VARCHAR2) Is
    select 1 from AHL_WF_MAPPING
    where APPROVAL_OBJECT is NULL
				AND APPLICATION_USG_CODE = c_appl_usg_code;

    CURSOR Cur_object (c_appl_usg_code IN VARCHAR2) IS
    select wf_mapping_id from AHL_WF_MAPPING where APPROVAL_OBJECT is NULL
				AND  APPLICATION_USG_CODE = c_appl_usg_code;

			/*	CURSOR appl_usg_code (c_appl_usg IN VARCHAR2) IS
				select lookup_code from fnd_lookup_values_vl
				where lookup_type like 'AHL_APPLICATION_USAGE_CODE'
				and meaning like c_appl_usg;*/
BEGIN
			/*open appl_usg_code(p_wf_mapping_rec.application_usg);
			fetch appl_usg_code into l_application_usg_code;
			close appl_usg_code;*/

   l_application_usg_code := p_wf_mapping_rec.application_usg_code;

   Open Cur_object(nvl(l_application_usg_code, 'AHL'));
   Fetch Cur_object into l_wf_id;
   Close Cur_object;
   IF l_wf_id <> p_wf_mapping_rec.wf_mapping_id THEN
      Open check_object(nvl(l_application_usg_code, 'AHL'));
      Fetch check_object into l_count;
      IF check_object%found THEN
          Close check_object ;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
		  Fnd_Message.set_name ('AHL', 'AHL_WF_DEFAULT_NOT_TWO');
		  Fnd_Msg_Pub.ADD;
          END IF;
		  x_return_status := Fnd_Api.g_ret_sts_error;
	  RETURN;
      ELSE
          Close check_object ;
      END IF;
   END IF;

END Check_Default;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_wf_mapping
--
--------------------------------------------------------------------

PROCEDURE Delete_wf_mapping (
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_wf_mapping_id     IN  NUMBER,
   p_object_version    IN  NUMBER
)

IS
   CURSOR c_wf_mapping IS
      SELECT   *
      FROM     Ahl_wf_mapping
      WHERE    wf_mapping_id = p_wf_mapping_id;
   --
   -- This is the only exception for using %ROWTYPE.
   -- We are selecting from the VL view, which may
   -- have some denormalized columns as compared to
   -- the base tables.
   l_wf_mapping_rec    c_wf_mapping%ROWTYPE;
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_wf_mapping';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_Api_name;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_wf_mapping;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
    END IF;
   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;

   ------------------------ delete ------------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Delete');
   END IF;

   OPEN c_wf_mapping;
   FETCH c_wf_mapping INTO l_wf_mapping_rec;
   IF c_wf_mapping%NOTFOUND THEN
      CLOSE c_wf_mapping;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_wf_mapping;
   -- Delete TL data

   DELETE FROM Ahl_wf_mapping
    WHERE  wf_mapping_id = p_wf_mapping_id;
     IF (SQL%NOTFOUND) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error)
		THEN
         Fnd_Message.set_name ('AHL', 'AHL_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
     END IF;

   -------------------- finish --------------------------
   IF Fnd_Api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;
   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
   END IF;
-- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_wf_mapping;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_wf_mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_wf_mapping;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
		THEN
         Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Delete_wf_mapping;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Wf_Mapping
--
--------------------------------------------------------------------
PROCEDURE Validate_Wf_Mapping (
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_Wf_Mapping_rec   IN  Wf_Mapping_Rec_Type
)

IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_Wf_Mapping';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
    END IF;
   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   IF NOT Fnd_Api.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
  x_return_status := Fnd_Api.g_ret_sts_success;
   ---------------------- validate ------------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Check items');
    END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Wf_Mapping_Items (
         p_Wf_Mapping_rec     => p_Wf_Mapping_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_create,
         x_return_status      => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Check record');
    END IF;

   -------------------- finish --------------------------
   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
    END IF;
-- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
                THEN
         Fnd_Msg_Pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Wf_Mapping;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Wf_Mapping_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Wf_Mapping_Items (

   p_Wf_Mapping_rec       IN  Wf_Mapping_Rec_Type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_Wf_Mapping_Req_Items (
      p_Wf_Mapping_rec  => p_Wf_Mapping_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   --
   -- Validate uniqueness.
   Check_Wf_Mapping_UK_Items (
      p_Wf_Mapping_rec      => p_Wf_Mapping_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Wf_Mapping_Items;

PROCEDURE Check_Appl_Usg_Code(
      p_wf_mapping_rec  IN  Wf_Mapping_Rec_Type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
    l_count   NUMBER;
    CURSOR chk_appl_usg_code IS
    SELECT 1 FROM FND_LOOKUPS
    WHERE meaning =   p_wf_mapping_rec.Application_Usg
    AND LOOKUP_TYPE = 'AHL_APPLICATION_USAGE_CODE';
 BEGIN
      OPEN chk_appl_usg_code ;
      FETCH chk_appl_usg_code INTO l_count;
      IF chk_appl_usg_code%NOTFOUND THEN
          CLOSE chk_appl_usg_code;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
		  Fnd_Message.set_name ('AHL', 'AHL_APPR_APPUSG_INVALID');
		  Fnd_Msg_Pub.ADD;
          END IF;
	         x_return_status := Fnd_Api.g_ret_sts_error;
	         RETURN;
      ELSE
          CLOSE chk_appl_usg_code;
      END IF;
END Check_Appl_Usg_Code;

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Wf_Mapping_Rec
--
---------------------------------------------------------------------
/*PROCEDURE Init_Wf_Mapping_Rec (
   x_Wf_Mapping_rec         OUT NOCOPY  Wf_Mapping_Rec_Type
)
IS
BEGIN
   x_Wf_Mapping_rec.object_version_number    := Fnd_Api.g_miss_num;
   x_Wf_Mapping_rec.active_flag        := Fnd_Api.g_miss_char;
   x_Wf_Mapping_rec.wf_process_name    := Fnd_Api.g_miss_char;
   x_Wf_Mapping_rec.approval_object    := Fnd_Api.g_miss_char;
   x_Wf_Mapping_rec.item_type          := Fnd_Api.g_miss_char;

END Init_Wf_Mapping_Rec;
*/
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Wf_Mapping_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_Wf_Mapping_Rec (
   p_Wf_Mapping_rec      IN  Wf_Mapping_Rec_Type,
   x_complete_rec        OUT NOCOPY Wf_Mapping_Rec_Type
)
IS
   CURSOR c_Wf_Mapping IS
      SELECT   *
      FROM     AHL_Wf_Mapping
      WHERE    WF_Mapping_ID = p_Wf_Mapping_rec.WF_Mapping_ID;
   --
   -- This is the only exception for using %ROWTYPE.
   --

   l_Wf_Mapping_rec    c_Wf_Mapping%ROWTYPE;
BEGIN
   x_complete_rec := p_Wf_Mapping_rec;
   OPEN c_Wf_Mapping;
   FETCH c_Wf_Mapping INTO l_Wf_Mapping_rec;
   IF c_Wf_Mapping%NOTFOUND THEN
      CLOSE c_Wf_Mapping;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AHL', 'AHL_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_Wf_Mapping;

   --
   -- OBJECT VERSION NUMBER
   IF p_Wf_Mapping_rec.object_version_number = Fnd_Api.g_miss_num THEN
      x_complete_rec.object_version_number := l_Wf_Mapping_rec.object_version_number;
   END IF;
   --
   -- ACTIVE FLAG
   IF p_Wf_Mapping_rec.active_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.active_flag := l_Wf_Mapping_rec.active_flag;
   END IF;
   --
   -- WF_PROCESS_NAME
   IF p_Wf_Mapping_rec.wf_process_name = Fnd_Api.g_miss_char THEN
      x_complete_rec.wf_process_name := l_Wf_Mapping_rec.wf_process_name;
   END IF;

   -- APPROVAL OBJECT
   IF p_Wf_Mapping_rec.approval_object = Fnd_Api.g_miss_char THEN
      x_complete_rec.approval_object := l_Wf_Mapping_rec.approval_object;
   END IF;
   --
   -- ITEM TYPE
   IF p_Wf_Mapping_rec.item_type = Fnd_Api.g_miss_char THEN
      x_complete_rec.item_type := l_Wf_Mapping_rec.item_type;
   END IF;

END Complete_Wf_Mapping_Rec;


--       Check_Wf_Mapping_Req_Items
PROCEDURE Check_Wf_Mapping_Req_Items (
   p_Wf_Mapping_rec  IN    Wf_Mapping_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   -- FOR PROCESS NAME IF ACTIVE_FLAG IS 'YES' THEN CANNOT BE NULL
  IF UPPER(p_Wf_Mapping_rec.ACTIVE_FLAG) = 'Y' THEN
     IF p_Wf_Mapping_rec.WF_DISPLAY_NAME IS NULL THEN
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_WF_PROCESS_NAME_MISSING');
         Fnd_Msg_Pub.ADD;
       END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
    END IF;
 END IF;
	IF p_Wf_Mapping_rec.APPLICATION_USG_CODE IS NULL THEN
			 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_APPR_APPUSG_ISNULL');
         Fnd_Msg_Pub.ADD;
    END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
 END IF;

END Check_Wf_Mapping_Req_Items;


--       Check_Wf_Mapping_UK_Items
PROCEDURE Check_Wf_Mapping_UK_Items (
   p_Wf_Mapping_rec       IN    Wf_Mapping_Rec_Type,
   p_validation_mode IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
   --l_application_usg_code VARCHAR2(30);
   /* CURSOR c_appl_usg IS
    SELECT LOOKUP_CODE
    FROM FND_LOOKUPS
    WHERE MEANING = p_Wf_Mapping_rec.application_usg
    AND LOOKUP_TYPE = 'AHL_APPLICATION_USAGE_CODE';*/
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   -- MEDIA_ID
   -- For Create_Wf_Mapping, when ID is passed in, we need to
   -- check if this ID is unique.
   IF p_validation_mode = Jtf_Plsql_Api.g_create
      AND p_Wf_Mapping_rec.WF_Mapping_ID IS NOT NULL
   THEN
      IF Ahl_Utility_Pvt.check_uniqueness(
               'AHL_Wf_Mapping',
               'WF_Mapping_ID = ' || p_Wf_Mapping_rec.WF_Mapping_ID
                        ) = Fnd_Api.g_false
                THEN
         IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name ('AHL', 'AHL_WF_MAPPING_DUP_ID');
            Fnd_Msg_Pub.ADD;
         END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

			-- Reema:
   -- Retrieve the application usage code
   -- from fnd_lookups
   /*OPEN c_appl_usg;
   FETCH c_appl_usg INTO l_application_usg_code;
   IF c_appl_usg%NOTFOUND THEN
     l_application_usg_code := NULL;
   END IF;
   CLOSE c_appl_usg;*/

   -- check if APPROVAL OBJECT is UNIQUE
   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
      l_valid_flag := Ahl_Utility_Pvt.check_uniqueness (
         'AHL_Wf_Mapping',
         'APPROVAL_OBJECT = ''' || p_Wf_Mapping_rec.approval_object ||
									''' AND APPLICATION_USG_CODE = ''' || p_Wf_Mapping_rec.application_usg_code || '''');
   ELSE
      l_valid_flag := Ahl_Utility_Pvt.check_uniqueness (
         'AHL_Wf_Mapping',
         'APPROVAL_OBJECT = ''' || p_Wf_Mapping_rec.approval_object ||
									''' AND APPLICATION_USG_CODE = ''' || p_Wf_Mapping_rec.application_usg_code ||
           ''' AND WF_Mapping_ID <> ' || p_Wf_Mapping_rec.WF_Mapping_ID );
   END IF;
   IF l_valid_flag = Fnd_Api.g_false THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_WF_OBJECT_NOT_UNIQUE');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
END Check_Wf_Mapping_UK_Items;

END Ahl_Wf_Mapping_Pvt;

/
