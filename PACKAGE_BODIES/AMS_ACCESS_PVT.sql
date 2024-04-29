--------------------------------------------------------
--  DDL for Package Body AMS_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACCESS_PVT" AS
/* $Header: amsvaccb.pls 120.0 2005/05/31 23:58:05 appldev noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_access_PVT';

--==================================================================
-- Following code is added by ptendulk on 18-Jul-2000
--==================================================================
   TYPE t_grp is TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

--==================================================================
-- End of code added by ptendulk on 18-Jul-2000
--==================================================================

--------------------------------------------------------------
-- PROCEDURE
--    create_access
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_access_rec        IN  access_rec_type,
   x_access_id         OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_access';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_access_rec       access_rec_type := p_access_rec;
   l_access_count     NUMBER;

   CURSOR c_access_seq IS
   SELECT ams_act_access_s.NEXTVAL
     FROM DUAL;

   CURSOR c_access_count(l_access_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_act_access
    WHERE activity_access_id = l_access_id;

   /* Following code is added by rrajesh on 09/12/01 */
   CURSOR c_access_camp_schedules(l_camp_id IN NUMBER) IS
   SELECT *
     FROM ams_campaign_schedules_vl
    WHERE campaign_id = l_camp_id;

    l_schedule_rec    c_access_camp_schedules%ROWTYPE;
   /* end change 09/12/01 */

/* added by sunkumar 03-12-2002 bug id.. 2216520							     */
/* check for the uniqueness of entries ams_act_access table if p_access_rec.arc_user_or_role_type = 'GROUP'  */
/* if the entry exists ams_act_access table then a message is popped up to run the concurrent program        */

CURSOR c_group_exists IS
  SELECT 1
  FROM DUAL
  WHERE NOT EXISTS(SELECT 1
		   FROM ams_act_access
		   WHERE ams_act_access.act_access_to_object_id = p_access_rec.act_access_to_object_id
		     AND ams_act_access.arc_act_access_to_object = p_access_rec.arc_act_access_to_object
		     AND ams_act_access.user_or_role_id = p_access_rec.user_or_role_id
		     AND ams_act_access.delete_flag='Y');

l_group_exists NUMBER;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_access;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   validate_access(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_access_rec         => l_access_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;


/* added by sunkumar 03-12-2002 bug id.. 2216520							     */
/* check for the uniqueness of entries ams_act_access table if p_access_rec.arc_user_or_role_type = 'GROUP'  */
/* if the entry exists in the ams_act_access table then a message is popped up to run the concurrent program */

OPEN c_group_exists;
FETCH c_group_exists INTO l_group_exists;
IF p_access_rec.arc_user_or_role_type = 'GROUP' AND c_group_exists%NOTFOUND THEN
       	FND_MESSAGE.set_name('AMS', 'AMS_RUN_ACCESS_REFRESH_PROGRAM');
	FND_MSG_PUB.add;
	RAISE FND_API.g_exc_error;
END IF;
CLOSE c_group_exists;
   IF l_access_rec.activity_access_id IS NULL THEN
   LOOP
		OPEN c_access_seq;
		FETCH c_access_seq INTO l_access_rec.activity_access_id;
		CLOSE c_access_seq;

      OPEN  c_access_count(l_access_rec.activity_access_id);
      FETCH c_access_count INTO l_access_count;
      CLOSE c_access_count;

      EXIT WHEN l_access_count = 0;
   END LOOP;
   END IF;

   INSERT INTO ams_act_access(
      activity_access_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      act_access_to_object_id,
      arc_act_access_to_object,
      user_or_role_id,
      arc_user_or_role_type,
      active_from_date,
      active_to_date,
      admin_flag,
	 approver_flag,
	 owner_flag,
	 delete_flag )
	VALUES(
      l_access_rec.activity_access_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_access_rec.act_access_to_object_id,
      l_access_rec.arc_act_access_to_object,
      l_access_rec.user_or_role_id,
      l_access_rec.arc_user_or_role_type,
      l_access_rec.active_from_date,
      l_access_rec.active_to_date,
      decode(l_access_rec.owner_flag,'Y','Y',nvl(l_access_rec.admin_flag,'N') ),
	 l_access_rec.approver_flag,
	 l_access_rec.owner_flag,
	 'N' );

   ------------------------- finish -------------------------------
   x_access_id := l_access_rec.activity_access_id;
IF l_access_rec.owner_flag = 'Y' THEN
   l_access_rec.admin_flag := 'Y';
END IF;
IF l_access_rec.arc_user_or_role_type = 'USER' THEN

   ams_access_denorm_pvt.insert_resource (
     p_resource_id     => l_access_rec.user_or_role_id,
     p_object_id       => l_access_rec.act_access_to_object_id,
     p_object_type     => l_access_rec.arc_act_access_to_object,
     p_edit_metrics    => l_access_rec.admin_flag,
     x_return_status   => l_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
	-- FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
   --	FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

END IF;
-- if (l_access_rec.arc_act_access_to_object <> 'FUND' ) then

 /*************  Modify Attribute ******************************/
/***
   AMS_ObjectAttribute_PVT.modify_object_attribute(
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_object_type        => l_access_rec.arc_act_access_to_object,
      p_object_id          => l_access_rec.act_access_to_object_id ,
      p_attr               => 'TEAM',
      p_attr_defined_flag  => 'Y'
   );
***/

-- end if;
  -- Added by rrajesh on 09/12/01. to add access to schedules.
    IF l_access_rec.arc_act_access_to_object = 'CAMP' THEN
      IF l_access_rec.act_access_to_object_id IS NOT NULL THEN
         OPEN c_access_camp_schedules(l_access_rec.act_access_to_object_id);
         LOOP
            LOOP
              OPEN c_access_seq;
              FETCH c_access_seq INTO l_access_rec.activity_access_id;
              CLOSE c_access_seq;

              OPEN  c_access_count(l_access_rec.activity_access_id);
              FETCH c_access_count INTO l_access_count;
              CLOSE c_access_count;

              EXIT WHEN l_access_count = 0;
           END LOOP;
           FETCH c_access_camp_schedules INTO l_schedule_rec;
           EXIT WHEN c_access_camp_schedules%NOTFOUND;

             INSERT INTO ams_act_access(
                         activity_access_id,
                         last_update_date,
                         last_updated_by,
                         creation_date,
                         created_by,
                         last_update_login,
                         object_version_number,
                         act_access_to_object_id,
                         arc_act_access_to_object,
                         user_or_role_id,
                         arc_user_or_role_type,
                         active_from_date,
                         active_to_date,
                         admin_flag,
                         approver_flag,
                         owner_flag,
                         delete_flag )
              SELECT
                         l_access_rec.activity_access_id,
                         SYSDATE,
                         FND_GLOBAL.user_id,
                         SYSDATE,
                         FND_GLOBAL.user_id,
                         FND_GLOBAL.conc_login_id,
                         1,  -- object_version_number
                         l_schedule_rec.schedule_id,
                         'CSCH',
                         l_access_rec.user_or_role_id,
                         l_access_rec.arc_user_or_role_type,
                         l_access_rec.active_from_date,
                         l_access_rec.active_to_date,
                         decode(l_access_rec.owner_flag,'Y','Y',nvl(l_access_rec.admin_flag,'N') ),
                         l_access_rec.approver_flag,
                         l_access_rec.owner_flag,
                        'N'
             FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 FROM AMS_ACT_ACCESS WHERE act_access_to_object_id = l_schedule_rec.schedule_id
                                                               and arc_act_access_to_object = 'CSCH'
                                                               and user_or_role_id = l_access_rec.user_or_role_id
                                                               and arc_user_or_role_type = 'USER');

     IF l_access_rec.arc_user_or_role_type = 'USER' THEN

           ams_access_denorm_pvt.insert_resource (
              p_resource_id     => l_access_rec.user_or_role_id,
              p_object_id       => l_schedule_rec.schedule_id,
              p_object_type     => 'CSCH',
              p_edit_metrics    => nvl(l_access_rec.admin_flag,'N'),
              x_return_status   => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data
             );

         IF l_return_status = FND_API.g_ret_sts_error THEN
            FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
            --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
            --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

END IF;

       END LOOP;
       CLOSE c_access_camp_schedules;
      END IF; -- obj_id
   END IF ;-- obj_type
  --  end change for schedule level access

   /*****************************************************************/
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
  -----------------------------------------------------------------

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_access;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_access;
---------------------------------------------------------------
-- PROCEDURE
--    delete_access
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------
PROCEDURE delete_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_access_id         IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_access';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR  c_getobj_type_id(l_access_id IN NUMBER)  IS
    SELECT arc_act_access_to_object,
           act_access_to_object_id,
           arc_user_or_role_type,
           user_or_role_id,
           admin_flag
      FROM ams_act_access
     WHERE activity_access_id = l_access_id;

   CURSOR  c_getobj_attr ( p_obj_id in NUMBER, p_obj_type IN VARCHAR2) IS
    SELECT 'x'
      FROM ams_act_access
     WHERE arc_act_access_to_object = p_obj_type
       AND act_access_to_object_id = p_obj_id;

   l_object_id   NUMBER;
   l_object_type VARCHAR2(100);
   l_role_id   NUMBER;
   l_role_type VARCHAR2(100);
   l_admin_flag VARCHAR2(1);
   l_dummy       VARCHAR2(1);

   l_return_status VARCHAr2(1);

   /* Following code is added by rrajesh on 09/12/01 */
   CURSOR c_access_camp_schedules(l_camp_id IN NUMBER) IS
   SELECT *
     FROM ams_campaign_schedules_vl
    WHERE campaign_id = l_camp_id;

/*   commented by skarumur, using c_getobj_type_id cursor
     CURSOR c_get_camp_id(l_activity_access_id IN NUMBER) IS
   SELECT act_access_to_object_id
      FROM ams_act_access
      WHERE activity_access_id = l_activity_access_id;

   CURSOR c_get_user_or_role_type(l_activity_access_id IN NUMBER) IS
   SELECT arc_user_or_role_type
      FROM ams_act_access
      WHERE activity_access_id = l_activity_access_id;

   CURSOR c_get_user_or_role_id(l_activity_access_id IN NUMBER) IS
   SELECT user_or_role_id
      FROM ams_act_access
      WHERE activity_access_id = l_activity_access_id;  */

   l_schedule_rec          c_access_camp_schedules%ROWTYPE;
   /* end change 09/12/01 */

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_access;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   -----  Get the object type and obj id for this access id ----

   OPEN c_getobj_type_id(p_access_id);
   FETCH  c_getobj_type_id into l_object_type, l_object_id,l_role_type,l_role_id,l_admin_flag;
   CLOSE  c_getobj_type_id;

   --------------------------------------------------------------

     x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

IF l_role_type = 'USER' THEN

   DELETE FROM ams_act_access
   WHERE activity_access_id = p_access_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;


   -- Added by rrajesh on 09/12/01  - for campaign schedules

   /*OPEN c_get_camp_id(p_access_id);
   FETCH c_get_camp_id INTO l_camp_id;
   CLOSE c_get_camp_id;

   OPEN c_get_user_or_role_type(p_access_id);
   FETCH c_get_user_or_role_type INTO l_user_or_role_type;
   CLOSE c_get_user_or_role_type;

   OPEN c_get_user_or_role_id(p_access_id);
   FETCH c_get_user_or_role_id INTO l_user_or_role_id;
   CLOSE c_get_user_or_role_type; */

   IF l_object_type = 'CAMP' THEN
      OPEN c_access_camp_schedules(l_object_id);
      LOOP
         FETCH c_access_camp_schedules INTO l_schedule_rec;
         EXIT WHEN c_access_camp_schedules%NOTFOUND ;
         DELETE FROM ams_act_access
          WHERE act_access_to_object_id = l_schedule_rec.schedule_id
            AND arc_act_access_to_object = 'CSCH'
            AND user_or_role_id = l_role_id
            AND arc_user_or_role_type = l_role_type;

        IF (SQL%NOTFOUND) THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
           THEN
              FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
              FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.g_exc_error;
        END IF;

    ams_access_denorm_pvt.delete_resource (
      p_resource_id     => l_role_id,
      p_object_id       => l_schedule_rec.schedule_id,
      p_object_type     => 'CSCH',
      p_edit_metrics    => l_admin_flag,
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
      --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
    -- FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
      END LOOP;
      CLOSE c_access_camp_schedules;
   END IF;
--   end change. for schedules. 09/12/01

    ams_access_denorm_pvt.delete_resource (
      p_resource_id     => l_role_id,
      p_object_id       => l_object_id,
      p_object_type     => l_object_type,
      p_edit_metrics    => l_admin_flag,
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
	 --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
	--FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

ELSIF l_role_type = 'GROUP' THEN

   UPDATE ams_act_access
   SET delete_flag = 'Y',
       last_update_date = sysdate,
       last_update_login = fnd_global.conc_login_id,
       last_updated_by  = fnd_global.user_id
   WHERE activity_access_id = p_access_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- Added by rrajesh on 09/12/01  - for campaign schedules

/*   OPEN c_get_camp_id(p_access_id);
   FETCH c_get_camp_id INTO l_camp_id;
   CLOSE c_get_camp_id;

   OPEN c_get_user_or_role_id(p_access_id);
   FETCH c_get_user_or_role_id INTO l_user_or_role_id;
   CLOSE c_get_user_or_role_id;

   OPEN c_get_user_or_role_type(p_access_id);
   FETCH c_get_user_or_role_type INTO l_user_or_role_type;
   CLOSE c_get_user_or_role_type; */

   IF l_object_type = 'CAMP' THEN
      OPEN c_access_camp_schedules(l_object_id);
      LOOP
         FETCH c_access_camp_schedules INTO l_schedule_rec;
         EXIT WHEN c_access_camp_schedules%NOTFOUND ;
         UPDATE ams_act_access
            SET delete_flag = 'Y',
                last_update_date = sysdate,
                last_update_login = fnd_global.conc_login_id,
                last_updated_by  = fnd_global.user_id
          WHERE act_access_to_object_id = l_schedule_rec.schedule_id
            AND arc_act_access_to_object = 'CSCH'
            AND user_or_role_id = l_role_id
            AND arc_user_or_role_type = l_role_type;

         IF (SQL%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      END LOOP;
      CLOSE c_access_camp_schedules;
   END IF;
   /* end change. for schedules. 09/12/01 */
END IF;

-- if (l_object_type <> 'FUND' ) then

/***
   -----          Modify Object Attribute ---------------

     OPEN c_getobj_attr( l_object_id, l_object_type);
     FETCH  c_getobj_attr into l_dummy;

     if (c_getobj_attr%NOTFOUND) then

             AMS_ObjectAttribute_PVT.modify_object_attribute(
                     p_api_version        => l_api_version,
                     p_init_msg_list      => FND_API.g_false,
                     p_commit             => FND_API.g_false,
                     p_validation_level   => FND_API.g_valid_level_full,
                     x_return_status      => l_return_status,
                     x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,

		      p_object_type        => l_object_type,
		      p_object_id          => l_object_id ,
		      p_attr               => 'TEAM',
		      p_attr_defined_flag  => 'N'
		   );
		   IF l_return_status = FND_API.g_ret_sts_error THEN
		      RAISE FND_API.g_exc_error;
		   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
		      RAISE FND_API.g_exc_unexpected_error;
		   END IF;

     end if;
--  end if;
***/
   ------------------------------------------------------


   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_access;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END delete_access;

-------------------------------------------------------------------
-- PROCEDURE
--    lock_access
--
-- HISTORY
--    10/12/99  abhola  Create.
--------------------------------------------------------------------
PROCEDURE lock_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_access_id         IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_access';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_access_id      NUMBER;

   CURSOR c_access_b IS
   SELECT activity_access_id
     FROM ams_act_access
    WHERE activity_access_id = p_access_id
      AND object_version_number = p_object_version
   FOR UPDATE OF activity_access_id NOWAIT;


BEGIN

   -------------------- initialize ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_access_b;
   FETCH c_access_b INTO l_access_id;
   IF (c_access_b%NOTFOUND) THEN
      CLOSE c_access_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_access_b;
   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
		END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

	WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END lock_access;


---------------------------------------------------------------------
-- PROCEDURE
--    update_access
--
-- HISTORY
--    10/12/99  abhola  Create.
----------------------------------------------------------------------
PROCEDURE update_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_access_rec          IN  access_rec_type
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_access';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_access_rec       access_rec_type := p_access_rec;
   l_return_status    VARCHAR2(1);

   /* Following code is added by rrajesh on 09/12/01 */

   CURSOR c_access_camp_schedules(l_camp_id IN NUMBER) IS
   SELECT *
     FROM ams_campaign_schedules_vl
    WHERE campaign_id = l_camp_id;

   CURSOR c_get_user_or_role_type(l_activity_access_id IN NUMBER) IS
   SELECT arc_user_or_role_type
      FROM ams_act_access
      WHERE activity_access_id = l_activity_access_id;

   CURSOR c_get_user_or_role_id(l_activity_access_id IN NUMBER) IS
   SELECT user_or_role_id
      FROM ams_act_access
      WHERE activity_access_id = l_activity_access_id;

   CURSOR c_get_key_id(p_sched_id IN NUMBER, p_user_or_role_type IN VARCHAR2, p_user_or_role_id NUMBER) IS
   SELECT activity_access_id
      FROM ams_act_access
      WHERE act_access_to_object_id = p_sched_id
               AND arc_act_access_to_object = 'CSCH'
               AND user_or_role_id = p_user_or_role_id
               AND arc_user_or_role_type = p_user_or_role_type;


   l_schedule_rec          c_access_camp_schedules%ROWTYPE;
   l_camp_id               NUMBER;
   l_user_or_role_type     VARCHAR2(30);
   l_user_or_role_id       NUMBER;
   l_key_id                NUMBER;
   /* end change 09/12/01 */

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_access;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_access_items(
         p_access_rec      => p_access_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   complete_access_rec(p_access_rec, l_access_rec);

   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   UPDATE ams_act_access SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_access_rec.object_version_number + 1,
      act_access_to_object_id = l_access_rec.act_access_to_object_id,
      arc_act_access_to_object = l_access_rec.arc_act_access_to_object,
      user_or_role_id = l_access_rec.user_or_role_id,
      arc_user_or_role_type = l_access_rec.arc_user_or_role_type,
      active_from_date = l_access_rec.active_from_date,
      active_to_date = l_access_rec.active_to_date,
      admin_flag  = l_access_rec.admin_flag,
	  approver_flag = l_access_rec.approver_flag
   WHERE activity_access_id = l_access_rec.activity_access_id
   AND object_version_number = l_access_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   /* Added by rrajesh on 09/12/01. to add access to schedules. */
   IF l_access_rec.arc_act_access_to_object = 'CAMP' THEN
      IF l_access_rec.act_access_to_object_id IS NOT NULL THEN
         OPEN c_access_camp_schedules(l_access_rec.act_access_to_object_id);
         LOOP
            FETCH c_access_camp_schedules INTO l_schedule_rec;
            EXIT WHEN c_access_camp_schedules%NOTFOUND ;

            OPEN c_get_key_id(l_schedule_rec.schedule_id, l_access_rec.arc_user_or_role_type, l_access_rec.user_or_role_id);
            FETCH c_get_key_id INTO l_key_id;
            CLOSE c_get_key_id;

                 UPDATE ams_act_access SET
                  last_update_date = SYSDATE,
                  last_updated_by = FND_GLOBAL.user_id,
                  last_update_login = FND_GLOBAL.conc_login_id,
                  object_version_number = object_version_number + 1,
                  act_access_to_object_id = l_schedule_rec.schedule_id,
                  arc_act_access_to_object = 'CSCH',
                  user_or_role_id = l_access_rec.user_or_role_id,
                  arc_user_or_role_type = l_access_rec.arc_user_or_role_type,
                  active_from_date = l_access_rec.active_from_date,
                  active_to_date = l_access_rec.active_to_date,
                  admin_flag  = l_access_rec.admin_flag,
                  approver_flag = l_access_rec.approver_flag
               WHERE activity_access_id = l_key_id;

             IF (SQL%NOTFOUND) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.g_exc_error;
             END IF;

         ams_access_denorm_pvt.update_resource (
              p_resource_id     => l_access_rec.user_or_role_id,
              p_object_id       => l_schedule_rec.schedule_id,
              p_object_type     => 'CSCH',
              p_edit_metrics    => l_access_rec.admin_flag,
              x_return_status   => l_return_status,
	      x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data
          );

       IF l_return_status = FND_API.g_ret_sts_error THEN
          FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
        --  FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_PROCESS_FAILED');
         -- FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

         END LOOP;
         CLOSE c_access_camp_schedules;
      END IF; -- obj_id
   END IF; -- obj_type
  /* end change for schedule level access */

IF l_access_rec.arc_user_or_role_type = 'USER' THEN
  IF l_access_rec.owner_flag <> 'Y' OR l_access_rec.owner_flag IS NULL THEN
  ams_access_denorm_pvt.update_resource (
      p_resource_id     => l_access_rec.user_or_role_id,
      p_object_id       => l_access_rec.act_access_to_object_id,
      p_object_type     => l_access_rec.arc_act_access_to_object,
      p_edit_metrics    => l_access_rec.admin_flag,
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
    FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
    --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_PROCESS_FAILED');
    --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_unexpected_error;
   END IF;

 ELSIF l_access_rec.owner_flag = 'Y' THEN

   ams_access_denorm_pvt.delete_resource (
      p_resource_id     => l_access_rec.user_or_role_id,
      p_object_id       => l_access_rec.act_access_to_object_id,
      p_object_type     => l_access_rec.arc_act_access_to_object,
      p_edit_metrics    => l_access_rec.admin_flag,
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
 --   FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
 --  FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ams_access_denorm_pvt.insert_resource (
      p_resource_id     => l_access_rec.user_or_role_id,
      p_object_id       => l_access_rec.act_access_to_object_id,
      p_object_type     => l_access_rec.arc_act_access_to_object,
      p_edit_metrics    => l_access_rec.admin_flag,
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
      --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
     --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
 END IF;
END IF;
   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_access;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END update_access;
---------------------------------------------------------------------
-- PROCEDURE
--    update_object_owner
--
-- HISTORY
--    02/12/2001  skarumur  Create.
----------------------------------------------------------------------
PROCEDURE update_object_owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN  VARCHAR2,
   p_object_id         IN  NUMBER,
   p_resource_id       IN  NUMBER,
   p_old_resource_id   IN  NUMBER
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_owner';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status    VARCHAR2(1);
-- added by julou 14-dec-2001 check for the existence of new owner
   l_access_id    NUMBER;
   l_obj_ver_no   NUMBER;

  CURSOR c_user_exists IS
  SELECT activity_access_id, object_version_number
    FROM ams_act_access
   WHERE act_access_to_object_id = p_object_id
     AND arc_act_access_to_object = p_object_type
     AND user_or_role_id = p_resource_id
     AND arc_user_or_role_type = 'USER';
BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_owner;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

-- added by julou 14-DEC-2001 check existence of new owner
   OPEN c_user_exists;
   FETCH c_user_exists INTO l_access_id, l_obj_ver_no;
   CLOSE c_user_exists;

   IF l_access_id IS NOT NULL THEN -- the user already in access list
      delete_access( --  remove it first to avoid unique constraint violation
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        p_validation_level  => p_validation_level,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_access_id         => l_access_id,
        p_object_version    => l_obj_ver_no
        );
-- end of code added by julou
   END IF; -- added by sveerave on 06-jun-2002
--    ELSE -- update owner to new resource
   UPDATE ams_act_access SET
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.user_id,
        last_update_login = FND_GLOBAL.conc_login_id,
        object_version_number = object_version_number + 1,
        act_access_to_object_id = p_object_id,
        arc_act_access_to_object = p_object_type,
        user_or_role_id = p_resource_id
   WHERE act_access_to_object_id = p_object_id
     AND arc_act_access_to_object = p_object_type
--   needs user_or_role_id to be specified Bug 3578905
--   child budgets have 2 owners. Parent Budget owner is also a owner
--   will result in unique constraint violation
     AND user_or_role_id = p_old_resource_id
     AND owner_flag = 'Y';

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;
--    END IF;

   ams_access_denorm_pvt.delete_resource (
      p_resource_id     => p_old_resource_id,
      p_object_id       => p_object_id,
      p_object_type     => p_object_type,
      p_edit_metrics    => 'Y',
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
	 --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_PROCESS_FAILED');
	--FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ams_access_denorm_pvt.insert_resource (
      p_resource_id     => p_resource_id,
      p_object_id       => p_object_id,
      p_object_type     => p_object_type,
      p_edit_metrics    => 'Y',
      x_return_status   => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      FND_MESSAGE.set_name('AMS', 'AMS_DENORM_PROCESS_FAILED');
	 --FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     FND_MESSAGE.set_name('AMS', 'AMS_INSERT_DENORM_FAILED');
	--FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_owner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_owner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_owner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END update_object_owner;
--------------------------------------------------------------------
-- PROCEDURE
--    validate_access
--
-- HISTORY
--    10/12/99  abhola  Create.
--------------------------------------------------------------------
PROCEDURE validate_access(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_access_rec          IN  access_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_access';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

 CURSOR c_check_dup (l_obj_id    IN NUMBER,
                     l_obj_type  IN VARCHAR2,
                     l_user_id   IN NUMBER,
                     l_user_type IN VARCHAR2)
  IS
  SELECT 'x'
    FROM ams_act_access
   WHERE act_access_to_object_id = l_obj_id
      AND arc_act_access_to_object = l_obj_type
      AND user_or_role_id = l_user_id
      AND arc_user_or_role_type = l_user_type
      AND delete_flag='N';

  l_local_x varchar2(2);

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start validate');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_access_items(
         p_access_rec        => p_access_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': check record');

   END IF;

   -- Check for Dupliacate Records -----

   OPEN c_check_dup( p_access_rec.act_access_to_object_id,
                     p_access_rec.arc_act_access_to_object,
                     p_access_rec.user_or_role_id,
                     p_access_rec.arc_user_or_role_type);

   FETCH c_check_dup into l_local_x;

    IF (c_check_dup%FOUND) THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
         IF (p_access_rec.arc_user_or_role_type = 'USER')
          THEN
           FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_DUP_USER');
          ELSE
           FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_DUP_GRP');
          END IF;
          FND_MSG_PUB.add;
       END IF;
      CLOSE c_check_dup;
      RAISE FND_API.g_exc_error;
  END IF;
   CLOSE c_check_dup;
   -------------------- finish --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END validate_access;

---------------------------------------------------------------------
-- FUNCTION
--    check_owner
--    check whether the input user is the owner of the activity.
-- HISTORY
--    7/13/00  abhola  Create.
--    7/26/00  holiu   Expose as needed in amscampv.jsp .
---------------------------------------------------------------------
FUNCTION check_owner(
   p_object_id         IN  NUMBER,
   p_object_type       IN  VARCHAR2,
   p_user_or_role_id   IN  NUMBER,
   p_user_or_role_type IN  VARCHAR2
)
RETURN VARCHAR2
IS
 CURSOR cur_is_owner  IS
 SELECT 'Y'
   FROM ams_act_access
  WHERE user_or_role_id = p_user_or_role_id
    AND arc_user_or_role_type = 'USER'
    AND arc_act_access_to_object = p_object_type
    AND act_access_to_object_id  = p_object_id
    AND owner_flag = 'Y';

    l_is_owner     VARCHAR2(1) := 'N';

BEGIN

  OPEN cur_is_owner;
  FETCH cur_is_owner INTO l_is_owner;
  CLOSE cur_is_owner;

  return l_is_owner;

END check_owner;

--=============================================================================================
-- NAME
--    Find_Groups
--
-- PURPOSE
--    This Procedure will Find the group the user belongs to .
--    It will also fing all the parent groups of the user' group.
--    It will return all the groups in pl sql table.
-- NOTES
--
-- HISTORY
-- 18-Jul-1999     ptendulk   Created
-- 03-Feb-2001     ptendulk   Modified cursor to get all groups , use the denorm table.
--                            Refer bug # 1626705
-- 02-12-2001      skarumur   This method is depricated.  Leaving to support prior releases
--=============================================================================================
PROCEDURE Find_Groups (p_user_type  IN   VARCHAR2,
                       p_user_id    IN   NUMBER,
                       x_grp_tab    OUT NOCOPY  t_grp)
IS
   --
   -- Cursor to Find all the group the user is in
   --
   CURSOR c_all_grp IS
   SELECT group_id
   FROM   jtf_rs_group_members
   WHERE  resource_id = p_user_id
   AND    delete_flag = 'N' ;

   --
   -- Find the all the parents of the group the user is in
   --
   -- Following code is commented by ptendulk on 03-Feb-2001
   -- Use the denorm table to get all parent groups.
   --   CURSOR c_parent_grp(c_grp_no NUMBER) IS
   --   SELECT related_group_id
   --   FROM   jtf_rs_grp_relations
   --   WHERE delete_flag = 'N'
   --   START WITH group_id = c_grp_no
   --   CONNECT BY PRIOR related_group_id = group_id
   --   AND delete_flag = 'N' ;
   -- End of  code is commented by ptendulk on 03-Feb-2001

   CURSOR c_parent_grp(c_grp_no NUMBER) IS
   SELECT parent_group_id
   FROM   jtf_rs_groups_denorm
   WHERE group_id = c_grp_no
   AND NVL(start_date_active,SYSDATE) = SYSDATE
   AND NVL(end_date_active,SYSDATE) = SYSDATE ;

   l_temp     NUMBER := 0 ;
   l_temp_grp NUMBER;

   l_grp_tab  t_grp ;
BEGIN

   IF p_user_type <> 'GROUP'  THEN

      FOR c_all_grp_rec IN  c_all_grp
      LOOP
          l_grp_tab(l_temp) := c_all_grp_rec.group_id ;
          l_temp := l_temp + 1 ;
          OPEN c_parent_grp(c_all_grp_rec.group_id);
          LOOP
             FETCH c_parent_grp INTO l_temp_grp ;
             EXIT WHEN c_parent_grp%NOTFOUND ;
             IF l_temp_grp IS NOT NULL THEN
                l_grp_tab(l_temp) := l_temp_grp ;
                l_temp := l_temp  + 1 ;
             END IF ;
          END LOOP;
          CLOSE c_parent_grp ;
          -- 09/13/00 holiu: remove the following line
          -- l_temp := l_temp + 1 ;
      END LOOP  ;

      x_grp_tab := l_grp_tab ;
   ELSE
      OPEN c_parent_grp(p_user_id);
      LOOP
         FETCH c_parent_grp INTO l_temp_grp ;
         EXIT WHEN c_parent_grp%NOTFOUND ;
         l_grp_tab(l_temp) := l_temp_grp ;
         l_temp := l_temp + 1 ;
      END LOOP;
      CLOSE c_parent_grp ;
   END IF;
   x_grp_tab := l_grp_tab ;

END ;

---------------------------------------------------------------------
-- FUNCTION
--    check_update_Access
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
FUNCTION check_update_access(
    p_object_id         IN  NUMBER,
    p_object_type       IN  VARCHAR2,
    p_user_or_role_id   IN  NUMBER,
    p_user_or_role_type IN  VARCHAR2
)
RETURN VARCHAR2
IS

   x_access           VARCHAR2(1) := 'N';
   x_return_full_priv VARCHAR2(1) := 'F';

   CURSOR cur_check_access IS
   SELECT decode(edit_metrics_yn,'Y','F','R')
   FROM   ams_act_access_denorm
   WHERE  resource_id = p_user_or_role_id
	AND  object_id = p_object_id
	AND  object_type = p_object_type;

BEGIN

   IF Check_Admin_Access(p_user_or_role_id) or p_object_type = 'OFFR' THEN
      RETURN x_return_full_priv ;
   END IF ;

   open cur_check_access;
   fetch cur_check_access into x_access;
   close cur_check_access;

   RETURN x_access;

END check_update_access;

FUNCTION get_source_code(
   p_object_type IN    VARCHAR2,
   p_object_id   IN    NUMBER
  )
RETURN VARCHAR2
IS
l_source_code varchar2(30);

CURSOR cur_get_source_code IS
SELECT source_code
  FROM ams_source_codes
 WHERE source_code_for_id = p_object_id
   AND arc_source_code_for = p_object_type;

BEGIN

   OPEN cur_get_source_code;
  FETCH cur_get_source_code INTO l_source_code;
  CLOSE cur_get_source_code;

  RETURN l_source_code;

END;


---------------------------------------------------------------------
-- PROCEDURE
--    check_view_Access
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
FUNCTION check_view_access(
    p_object_id         IN  NUMBER,
    p_object_type       IN  VARCHAR2,
    p_user_or_role_id   IN  NUMBER,
    p_user_or_role_type IN  VARCHAR2
)

RETURN VARCHAR2
IS

   x_access      VARCHAR2(1);

   cursor c_access_camp (
          c_act_access_to_object_id  IN ams_act_access.act_access_to_object_id%TYPE)
		 IS
		 SELECT private_flag
                   FROM ams_campaigns_all_b
                   --FROM ams_campaigns_vl
                   -- commented by ptendulk on 22-Jan-2001 Ref Bug #1607548
		  WHERE campaign_id   = c_act_access_to_object_id;

  cursor c_access_eveo (
         c_act_access_to_object_id  IN ams_act_access.act_access_to_object_id%TYPE)
		 IS
		 SELECT private_flag
                   -- commented by ptendulk on 22-Jan-2001 Ref Bug #1607548
		   --FROM ams_event_offers_vl
                   FROM ams_event_offers_all_b
		  WHERE event_offer_id = c_act_access_to_object_id;

    cursor c_access_eveh (
         c_act_access_to_object_id  IN ams_act_access.act_access_to_object_id%TYPE)
		 IS
		 SELECT private_flag
                   -- commented by ptendulk on 22-Jan-2001 Ref Bug #1607548
		   -- FROM ams_event_headers_vl
                   FROM ams_event_headers_all_b
		  WHERE event_header_id = c_act_access_to_object_id;

    cursor c_access_delv (
         c_act_access_to_object_id  IN ams_act_access.act_access_to_object_id%TYPE)
		 IS
		 SELECT private_flag
		   FROM ams_deliverables_vl
		  WHERE deliverable_id  = c_act_access_to_object_id;

    cursor c_access (
         c_act_access_to_object_id  IN ams_act_access.act_access_to_object_id%TYPE,
         c_arc_act_access_to_object IN ams_act_access.arc_act_access_to_object%TYPE,
	     c_user_or_role_id          IN ams_act_access.user_or_role_id%TYPE,
         c_arc_user_or_role_type    IN ams_act_access.arc_user_or_role_type%TYPE )
         IS
		 SELECT  admin_flag
		   FROM ams_act_access
		  WHERE act_access_to_object_id  = c_act_access_to_object_id
		    AND arc_act_access_to_object = c_arc_act_access_to_object
		    AND user_or_role_id          = c_user_or_role_id
		    AND arc_user_or_role_type    = c_arc_user_or_role_type;

   -- 07/16/00 holiu: check group access for user
   --=============================================================================
   -- Following code is commented by ptendulk on 18Jul2000
   --=============================================================================
--   CURSOR c_group_access IS
--   SELECT 1
--   FROM   DUAL
--   WHERE  EXISTS(
--          SELECT 1
--          FROM   ams_act_access A, jtf_rs_group_members_vl B
--          WHERE  A.arc_act_access_to_object = p_object_type
--          AND    A.act_access_to_object_id = p_object_id
--          AND    A.arc_user_or_role_type = 'GROUP'
--          AND    (A.active_from_date IS NULL OR A.active_from_date <= SYSDATE)
--          AND    (A.active_to_date IS NULL OR A.active_to_date >= SYSDATE)
--          AND    A.user_or_role_id = B.group_id
--          AND    B.delete_flag = 'N'
--          AND    B.resource_id = p_user_or_role_id);

   CURSOR c_group_access(c_grp_id NUMBER) IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
   SELECT 1
   FROM   ams_act_access
   WHERE  arc_act_access_to_object = p_object_type
   AND    act_access_to_object_id = p_object_id
   AND    arc_user_or_role_type = 'GROUP'
   AND    (active_from_date IS NULL OR active_from_date <= SYSDATE)
   AND    (active_to_date IS NULL OR active_to_date >= SYSDATE)
   AND    user_or_role_id = c_grp_id) ;

   l_private_flag varchar2(1);
   l_admin_flag   varchar2(1);
   l_is_owner     varchar2(1);
   l_dummy        NUMBER;
   l_grp_tab t_grp ;
BEGIN
   --===================================================================
   -- Following code is added by ptendulk on 01-Sep-2000
   -- Give the full permission for the admin user
   --===================================================================
   IF Check_Admin_Access(p_user_or_role_id) THEN
      RETURN 'Y' ;
   END IF ;

   ----------- check wheteher the input user is the owner -----


   l_is_owner := check_owner(p_object_id ,
					       p_object_type ,
						  p_user_or_role_id ,
						  p_user_or_role_type);

 if ( l_is_owner = 'Y') then
	    return l_is_owner;
 else

   x_access := 'N';

   if (p_object_type = 'CAMP') then
      open c_access_camp(p_object_id);
      fetch c_access_camp into l_private_flag;

      if (c_access_camp%NOTFOUND) then
         close c_access_camp;

         return x_access;
      end if;

	  close c_access_camp;

   elsif (p_object_type = 'EVEO' ) then
      open c_access_eveo(p_object_id);
      fetch c_access_eveo into l_private_flag;

      if (c_access_eveo%NOTFOUND) then
         close c_access_eveo;

         return x_access;
      end if;

	  close c_access_eveo;

   elsif (p_object_type = 'EVEH' ) then
      open c_access_eveh(p_object_id);
      fetch c_access_eveh into l_private_flag;

      if (c_access_eveh%NOTFOUND) then
         close c_access_eveh;

         return x_access;
      end if;

	  close c_access_eveh;

   elsif (p_object_type = 'DELV' ) then
      open c_access_delv(p_object_id);
      fetch c_access_delv into l_private_flag;

      if (c_access_delv%NOTFOUND) then
         close c_access_delv;

         return x_access;
      end if;

	  close c_access_delv;

   elsif (p_object_type = 'FUND' ) then

      l_private_flag := 'Y';

   end if;

   if (l_private_flag = 'N') then
       x_access := 'Y';
   else
         open c_access( p_object_id ,
		         p_object_type ,
			 p_user_or_role_id ,
			 p_user_or_role_type );

          fetch c_access into l_admin_flag;
          if (c_access%NOTFOUND) then
             x_access := 'N';
          else
             x_access := 'Y';
          end if;
	   close c_access;
   end if;

 end if;

   -- 07/16/00 holiu: check group access for user
   IF x_access = 'Y' OR p_user_or_role_type = 'GROUP' THEN
      RETURN x_access;
   ELSE

      Find_Groups (p_user_type  => 'USER',
                   p_user_id    => p_user_or_role_id ,
                   x_grp_tab    => l_grp_tab)  ;

      IF l_grp_tab.first IS NOT null THEN
         FOR i IN l_grp_tab.first..l_grp_tab.last
         LOOP

             OPEN c_group_access(l_grp_tab(i));
             FETCH c_group_access INTO l_dummy ;
             CLOSE c_group_access;
             IF l_dummy = 1 THEN
                RETURN 'Y';
             END IF;
         END LOOP;
      END IF;

      RETURN 'N' ;

   END IF;
END check_view_access;


---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_req_items
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_req_items(
   p_Access_rec       IN  Access_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

CURSOR c1(p_inp_user_id IN NUMBER,
		p_inp_user_type IN VARCHAR2,
		p_inp_obj_id  IN NUMBER,
		p_inp_obj_type IN VARCHAR2
		) is SELECT 'x'
			FROM ams_act_access
			WHERE user_or_role_id = p_inp_user_id
			  AND arc_user_or_role_type = p_inp_user_type
			  AND act_access_to_object_id = p_inp_obj_id
			  AND arc_act_access_to_object=  p_inp_obj_type
			  AND delete_flag = 'N' ;

  l_var1 VARCHAR2(3);
BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(' start req item');

   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ user_status_id --------------------------
   IF p_Access_rec.act_access_to_object_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_NO_OBJECT_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_Access_rec.arc_act_access_to_object IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_NO_OBJECT');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_Access_rec.user_or_role_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_NO_UR_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_Access_rec.arc_user_or_role_type IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_NO_UR_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(': check uniquness of record');

  END IF;

   IF p_Access_rec.user_or_role_id IS NOT NULL  AND p_access_rec.object_version_number IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
	    OPEN c1(  p_Access_rec.user_or_role_id
			  , p_Access_rec.arc_user_or_role_type
			  , p_Access_rec.act_access_to_object_id
			  , p_Access_rec.arc_act_access_to_object);
         FETCH c1 into l_var1;

      if (c1%FOUND) then
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
              FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_DUP_USER');
              FND_MSG_PUB.add;
         END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      end if;

      END IF;

   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(': check uniquness of record end ');
   END IF;

END check_Access_req_items;
---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_uk_items
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_uk_items(
   p_Access_rec        IN  Access_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_Access, when Access_id is passed in, we need to
   -- check if this Access_id is unique.
   --
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_Access_rec.activity_access_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
		      'ams_act_access',
				'activity_access_id = ' || p_Access_rec.activity_access_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_Access_uk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_fk_items
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_fk_items(
   p_Access_rec        IN  Access_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

 ------------------user or role id ---------------------------------------
  IF p_Access_rec.user_or_role_id <> FND_API.g_miss_num THEN

   if UPPER(p_Access_rec.arc_user_or_role_type) = 'USER' THEN

      IF AMS_Utility_PVT.check_fk_exists(
            'ams_jtf_rs_emp_v',
            'RESOURCE_ID',
            p_Access_rec.user_or_role_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_BAD_USER_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
    END IF;


   if UPPER(p_Access_rec.arc_user_or_role_type) = 'GROUP' THEN

      IF AMS_Utility_PVT.check_fk_exists(
            -- commented by ptendulk on 22-Jan-2001 Ref Bug #1607548
            --'JTF_RS_GROUPS_VL',
            'JTF_RS_GROUPS_B',
            'GROUP_ID',
            p_Access_rec.user_or_role_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_BAD_GROUP_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
    END IF;






 END IF;

END check_Access_fk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_lookup_items
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_lookup_items(
   p_Access_rec        IN  Access_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  ----------------------- access to object  ------------------------
  IF p_Access_rec.arc_act_access_to_object <> FND_API.g_miss_char THEN

/*
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_Access_rec.arc_act_access_to_object
         ) = FND_API.g_false
      THEN
*/
/*
    IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_Access_rec.arc_user_or_role_type,
            p_view_application_id => fnd_global.resp_appl_id
         ) = FND_API.g_false
    THEN
*/
-- Correcting the p_lookup_code value getting passed for bug# 2419540
-- Team concept is being used by mulitple applications. In some cases
-- we are relying that object exists in owning application, for e.g.
-- MDF in PV relies on assumption that Campaing is defined in AMS,
-- and in other cases, we assume that responsibility's application owns this
-- object, i.e. in case of programs, it should in in PV.
-- So, changing code to check in 530 if not found in appl_id. -- bug#2421583
    IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_Access_rec.arc_act_access_to_object,
            p_view_application_id => fnd_global.resp_appl_id
         ) = FND_API.g_false
    THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_Access_rec.arc_act_access_to_object,
            p_view_application_id => 530
         ) = FND_API.g_false
      THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
          FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_BAD_SYS_ARC');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
   END IF;
  END IF;

   ------------------user or role type ---------------------------------------
  IF p_Access_rec.arc_user_or_role_type <> FND_API.g_miss_char THEN
/*
      IF AMS_Utility_PVT.check_lookup_exists(
             p_lookup_type => 'AMS_ACCESS_TYPE',
            p_lookup_code => p_Access_rec.arc_user_or_role_type
         ) = FND_API.g_false
      THEN
*/
    -- User and Group lookups should exist only in AMS, and hence using 530
    IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_ACCESS_TYPE',
            p_lookup_code => p_Access_rec.arc_user_or_role_type,
            p_view_application_id => 530
         ) = FND_API.g_false
    THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
          FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_BAD_USER_TYPE');
          FND_MSG_PUB.add;
       END IF;

       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
    END IF;
  END IF;

END check_Access_lookup_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_flag_items
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_flag_items(
   p_Access_rec        IN  Access_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- admin_flag ------------------------
   IF p_Access_rec.admin_flag <> FND_API.g_miss_char
      AND p_Access_rec.admin_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_access_rec.admin_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_BAD_ADMIN_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other flags

END check_Access_flag_items;
---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_items
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_items(
   p_access_rec        IN  Access_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
-- cursor added by julou 29-nov-2001  ref. bug 2117645
/*
  CURSOR c_user_exist IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS(SELECT 1
                  FROM ams_act_access
                 WHERE act_access_to_object_id = p_access_rec.act_access_to_object_id
                   AND arc_act_access_to_object = p_access_rec.arc_act_access_to_object
                   AND user_or_role_id = p_access_rec.user_or_role_id
                   AND arc_user_or_role_type = p_access_rec.arc_user_or_role_type
                   AND activity_access_id <> p_access_rec.activity_access_id);

   l_user_exist NUMBER;
*/
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_Utility_PVT.debug_message(' req item check start');

END IF;
   check_Access_req_items(
      p_Access_rec       => p_Access_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_Utility_PVT.debug_message(' req item check success');

END IF;

/* added by sunkumar 03-12-2002 bug id.. 2216520							    */
/* check for the uniqueness of entries ams_act_access table if p_access_rec.arc_user_or_role_type='USER'    */
/* then only check for the unique constraint on the ams_act_access table                                    */

 IF p_access_rec.arc_user_or_role_type='USER' THEN
 BEGIN
 check_Access_uk_items(
      p_Access_rec        => p_Access_rec,
      p_validation_mode   => p_validation_mode,
      x_return_status     => x_return_status
   );


IF (AMS_DEBUG_HIGH_ON) THEN





AMS_Utility_PVT.debug_message(' UK check items success');


END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   END;
END IF;
   check_Access_fk_items(
      p_Access_rec       => p_Access_rec,
      x_return_status    => x_return_status
   );

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_Utility_PVT.debug_message('FK  check items success ');

END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_Access_lookup_items(
      p_Access_rec        => p_Access_rec,
      x_return_status     => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_Access_flag_items(
      p_Access_rec        => p_Access_rec,
      x_return_status   => x_return_status
   );

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_Utility_PVT.debug_message(' Flag  check items success ');

END IF;

IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
-- addee by julou 29-nov-2001 ref. bug 2117645
/*
  IF p_validation_mode = JTF_PLSQL_API.G_UPDATE THEN
    OPEN c_user_exist;
    FETCH c_user_exist INTO l_user_exist;
    CLOSE c_user_exist;

    IF l_user_exist = 1 THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_USER_EXIST');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
    END IF;
  END IF;
*/
END check_Access_items;
---------------------------------------------------------------------
-- PROCEDURE
--    check_Access_record
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE check_Access_record(
   p_Access_rec       IN  Access_rec_type,
   p_complete_rec     IN  Access_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_start_date  DATE;
   l_end_date    DATE;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_Access_rec.active_from_date <> FND_API.g_miss_date
      OR p_Access_rec.active_to_date <> FND_API.g_miss_date
   THEN
      IF p_Access_rec.active_from_date = FND_API.g_miss_date THEN
         l_start_date := p_complete_rec.active_from_date;
      ELSE
         l_start_date := p_Access_rec.active_from_date;
      END IF;

      IF p_Access_rec.active_to_date = FND_API.g_miss_date THEN
         l_end_date := p_complete_rec.active_to_date;
      ELSE
         l_end_date := p_Access_rec.active_to_date;
      END IF;

      IF l_start_date > l_end_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACCESS_INV_DATES');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   -- do other record level checkings

END check_Access_record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_Access_rec
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE init_Access_rec(
   x_Access_rec  OUT NOCOPY  Access_rec_type
)
IS
BEGIN

   x_Access_rec.activity_access_id := FND_API.g_miss_num;
   x_Access_rec.last_update_date := FND_API.g_miss_date;
   x_Access_rec.last_updated_by := FND_API.g_miss_num;
   x_Access_rec.creation_date := FND_API.g_miss_date;
   x_Access_rec.created_by := FND_API.g_miss_num;
   x_Access_rec.last_update_login := FND_API.g_miss_num;
   x_Access_rec.object_version_number := FND_API.g_miss_num;
   x_Access_rec.act_access_to_object_id := FND_API.g_miss_num;
   x_Access_rec.arc_act_access_to_object := FND_API.g_miss_char;
   x_Access_rec.user_or_role_id := FND_API.g_miss_num;
   x_Access_rec.arc_user_or_role_type := FND_API.g_miss_char;

   x_Access_rec.active_from_date := FND_API.g_miss_date;
   x_Access_rec.active_to_date := FND_API.g_miss_date;

   x_Access_rec.admin_flag := FND_API.g_miss_char;
   x_Access_rec.owner_flag := FND_API.g_miss_char;
   x_Access_rec.delete_flag := FND_API.g_miss_char;


END init_Access_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_Access_rec
--
-- HISTORY
--    10/12/99  abhola  Create.
---------------------------------------------------------------------
PROCEDURE complete_Access_rec(
   p_Access_rec      IN  Access_rec_type,
   x_complete_rec    OUT NOCOPY Access_rec_type
)
IS

   CURSOR c_Access IS
   SELECT *
     FROM ams_act_access
    WHERE activity_access_id = p_Access_rec.activity_access_id;

   l_Access_rec  c_Access%ROWTYPE;

BEGIN

   x_complete_rec := p_Access_rec;

   OPEN c_Access;
   FETCH c_Access INTO l_Access_rec;
   IF c_Access%NOTFOUND THEN
      CLOSE c_Access;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_access;


   IF p_Access_rec.act_access_to_object_id = FND_API.g_miss_num THEN
      x_complete_rec.act_access_to_object_id := l_Access_rec.act_access_to_object_id;
   END IF;

   IF p_Access_rec.arc_act_access_to_object = FND_API.g_miss_char THEN
      x_complete_rec.arc_act_access_to_object := l_Access_rec.arc_act_access_to_object;
   END IF;

   IF p_Access_rec.user_or_role_id = FND_API.g_miss_num THEN
      x_complete_rec.user_or_role_id := l_Access_rec.user_or_role_id;
   END IF;

   IF p_Access_rec.arc_user_or_role_type = FND_API.g_miss_char THEN
      x_complete_rec.arc_user_or_role_type := l_Access_rec.arc_user_or_role_type;
   END IF;

   IF p_Access_rec.active_from_date = FND_API.g_miss_date THEN
      x_complete_rec.active_from_date := l_Access_rec.active_from_date;
   END IF;

   IF p_Access_rec.active_to_date = FND_API.g_miss_date THEN
      x_complete_rec.active_to_date := l_Access_rec.active_to_date;
   END IF;

   IF p_Access_rec.admin_flag  = FND_API.g_miss_char THEN
      x_complete_rec.admin_flag  := l_Access_rec.admin_flag ;
   END IF;

   IF p_Access_rec.owner_flag  = FND_API.g_miss_char THEN
      x_complete_rec.owner_flag  := l_Access_rec.owner_flag ;
   END IF;

   IF p_Access_rec.delete_flag  = FND_API.g_miss_char THEN
      x_complete_rec.delete_flag  := l_Access_rec.delete_flag ;
   END IF;

END complete_Access_rec;

--=========================================================================
-- PROCEDURE
--   Check_Admin_access
-- PURPOSE
--   To give the Admin user full previledges for the security
-- PARAMETER
--   p_resource_id   ID of the person loggin in
--   output TRUE  if the resource has the admin previledges
--          FALSE if the resource doesn't have the admin previledges
-- HISTORY
--   09-Sep-2000   PTENDULK  Created
--   16-Sep-2000   PTENDULK  Added code to check if the profile option is null
--   20-Nov-2000   PTENDULK  Changed the where clause for delete flag. Bug#1503997
--=========================================================================
FUNCTION Check_Admin_Access(
   p_resource_id    IN NUMBER )
RETURN BOOLEAN
IS
   L_ADMIN_GROUP CONSTANT VARCHAR2(30) := 'AMS_ADMIN_GROUP';
   l_admin  NUMBER ;

   CURSOR c_members(p_group_id NUMBER) IS
   SELECT resource_id
   FROM   jtf_rs_group_members
   -- commented by ptendulk on 22-Jan-2001 Ref Bug #1607548
   --FROM jtf_rs_group_members_vl
   WHERE  group_id = p_group_id
   AND    resource_id = p_resource_id
   AND    delete_flag = 'N' ;

   l_access  BOOLEAN := FALSE ;
   l_res_id  NUMBER ;
BEGIN
   l_admin := FND_PROFILE.Value(L_ADMIN_GROUP);

   --============================================================
   -- Following code is added by ptendulk on Sep16 to check if
   -- the profile option is not defined.
   --============================================================
   IF l_admin IS NULL
   THEN
       RETURN FALSE;
   END IF;

   OPEN c_members(l_admin);
   FETCH c_members INTO l_res_id ;
   IF c_members%FOUND THEN
      CLOSE c_members;
      RETURN TRUE ;
   ELSE
      CLOSE c_members;
      RETURN FALSE ;
   END IF ;

END Check_Admin_access;

FUNCTION check_function_security( p_function_name IN VARCHAR2 ) RETURN NUMBER
IS
BEGIN

IF fnd_function.test(p_function_name) THEN
   return (1);
ELSE
   return(0);
END IF;

END;


END AMS_access_PVT;

/
