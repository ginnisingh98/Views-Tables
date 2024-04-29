--------------------------------------------------------
--  DDL for Package Body AMS_ASSOCIATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ASSOCIATIONS_PVT" AS
/*$Header: amsvassb.pls 115.24 2002/12/02 20:30:43 dbiswas ship $*/

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Associations_PVT';

---------------------------------------------------------------------
-- PROCEDURE
--    check_association_dates
--
-- HISTORY
--  10/30/01     musman    created
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE check_association_dates(
   p_association_rec        IN  association_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------
-- PROCEDURE
--    create_association
--
-- HISTORY
--  11/10/99     sugupta    created
--  07/15/00     ptendulk   Before creating Object attributes
--                          check Master object is not campaign and
--                          using object is not events .
--  07/16/00     holiu      Rewrite the IF condition.
--  10/18/00     soagrawa   Removed check for DELV.lang = CSCH.lang
--                          (fixed bug# 2063150)
---------------------------------------------------------------------
PROCEDURE create_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_association_rec        IN  association_rec_type,
   x_object_association_id  OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_association';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_association_rec       association_rec_type := p_association_rec;
   l_association_count     NUMBER;
  ------
   l_user_id  NUMBER;
   l_res_id   NUMBER;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR c_association_seq IS
   SELECT ams_object_associations_s.NEXTVAL
     FROM DUAL;

   CURSOR c_association_count(association_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_object_associations
    WHERE object_association_id = association_id;

   CURSOR c_get_lang_code ( l_camp_sch_id IN NUMBER) IS
    SELECT language_code
     FROM  AMS_CAMPAIGN_SCHEDULES_B
    WHERE  schedule_id = l_camp_sch_id;

   CURSOR c_get_delv_details(l_delv_id IN NUMBER) IS
    SELECT actual_avail_from_date,actual_avail_to_date,language_code
    FROM ams_deliverables_all_b
    WHERE deliverable_id = l_delv_id;

   l_csch_lang_code VARCHAR2(30);
   l_delv_lang_code VARCHAR2(30);
   l_delv_to_date DATE;
   l_delv_from_date DATE;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_association;

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

   validate_association(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_association_rec         => l_association_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   l_user_id := FND_GLOBAL.User_Id;
   if l_user_id IS NOT NULL then
      open get_res_id(l_user_id);
      fetch get_res_id into l_res_id;
      close get_res_id;
   end if;

   IF l_association_rec.master_object_type <> 'CSCH' THEN
      if AMS_ACCESS_PVT.check_update_access(l_association_rec.MASTER_OBJECT_ID, l_association_rec.MASTER_OBJECT_TYPE, l_res_id, 'USER') = 'N'  then
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --resuing message
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      end if;
   END IF ;

   ------------------- Added by ABHOLA   ------------------

     OPEN c_get_delv_details(l_association_rec.USING_OBJECT_ID);
     FETCH c_get_delv_details INTO l_delv_from_date,l_delv_to_date, l_delv_lang_code;
     CLOSE c_get_delv_details;

   -- removed by soagrawa on 18-oct-2001
   -- bug# 2063150
   /* Check language code of schedule is same as of DELV  */
     /*
     if (l_association_rec.MASTER_OBJECT_TYPE = 'CSCH') then

       OPEN c_get_lang_code(l_association_rec.MASTER_OBJECT_ID);
       FETCH c_get_lang_code INTO l_csch_lang_code;
       CLOSE c_get_lang_code;

       if (l_csch_lang_code <> l_delv_lang_code) then
          if FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) then
        FND_MESSAGE.set_name('AMS', 'AMS_DELV_CSCH_LANGUAGE');
        FND_MSG_PUB.add;
          end if;
        RAISE FND_API.g_exc_error;
     end if;

   end if;*/

   -- end soagrawa 18-oct-2001, bug# 2063150

   /* qunatity neede by date should be between delb to and from date */

   if ((l_association_rec.QUANTITY_NEEDED_BY_DATE >  l_delv_to_date )
       OR
      (l_association_rec.QUANTITY_NEEDED_BY_DATE  <  l_delv_from_date )) then

      if FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) then
       FND_MESSAGE.set_name('AMS', 'AMS_DELV_INVALID_DATES');
         FND_MSG_PUB.add;
      end if;
        RAISE FND_API.g_exc_error;
   end if;

   check_association_dates(
      p_association_rec   => l_association_rec,
      x_return_status     => x_return_status
   );

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;




   ------------------------------------------------------
   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;

   IF l_association_rec.object_association_id IS NULL THEN
      LOOP
      OPEN c_association_seq;
      FETCH c_association_seq INTO l_association_rec.object_association_id;
      CLOSE c_association_seq;

          OPEN c_association_count(l_association_rec.object_association_id);
      FETCH c_association_count into l_association_count;
      CLOSE c_association_count;

      EXIT WHEN l_association_count = 0;
    END LOOP;
     END IF;

   INSERT INTO ams_object_associations(
    OBJECT_ASSOCIATION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    MASTER_OBJECT_TYPE,
    MASTER_OBJECT_ID,
    USING_OBJECT_TYPE,
    USING_OBJECT_ID,
    PRIMARY_FLAG,
    USAGE_TYPE,
    QUANTITY_NEEDED,
    QUANTITY_NEEDED_BY_DATE,
    COST_FROZEN_FLAG,
    PCT_OF_COST_TO_CHARGE_USED_BY,
    MAX_COST_TO_CHARGE_USED_BY,
    MAX_COST_CURRENCY_CODE,
    METRIC_CLASS,
   FULFILL_ON_TYPE_CODE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CONTENT_TYPE,
    SEQUENCE_NO
   ) VALUES(
    l_association_rec.OBJECT_ASSOCIATION_ID,
    sysdate,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,  -- object_version_number
    l_association_rec.MASTER_OBJECT_TYPE,
    l_association_rec.MASTER_OBJECT_ID,
    l_association_rec.USING_OBJECT_TYPE,
    l_association_rec.USING_OBJECT_ID,
    nvl(l_association_rec.PRIMARY_FLAG,'N'),
    l_association_rec.USAGE_TYPE,
    l_association_rec.QUANTITY_NEEDED,
    l_association_rec.QUANTITY_NEEDED_BY_DATE,
    nvl(l_association_rec.COST_FROZEN_FLAG,'N'),
    l_association_rec.PCT_OF_COST_TO_CHARGE_USED_BY,
    l_association_rec.MAX_COST_TO_CHARGE_USED_BY,
    l_association_rec.MAX_COST_CURRENCY_CODE,
    l_association_rec.METRIC_CLASS,
   l_association_rec.FULFILL_ON_TYPE_CODE,
    l_association_rec.ATTRIBUTE_CATEGORY,
    l_association_rec.ATTRIBUTE1,
    l_association_rec.ATTRIBUTE2,
    l_association_rec.ATTRIBUTE3,
    l_association_rec.ATTRIBUTE4,
    l_association_rec.ATTRIBUTE5,
    l_association_rec.ATTRIBUTE6,
    l_association_rec.ATTRIBUTE7,
    l_association_rec.ATTRIBUTE8,
    l_association_rec.ATTRIBUTE9,
    l_association_rec.ATTRIBUTE10,
    l_association_rec.ATTRIBUTE11,
    l_association_rec.ATTRIBUTE12,
    l_association_rec.ATTRIBUTE13,
    l_association_rec.ATTRIBUTE14,
    l_association_rec.ATTRIBUTE15,
    l_association_rec.content_type,
    l_association_rec.sequence_no
);
   ------------------------- finish -------------------------------
   x_object_association_id := l_association_rec.object_association_id;
-- added by sugupta on 07/11/2000
   -- indicate association has been defined for the MASTER_OBJECT_TYPE

-- =========================================================================
-- Following condition is added by ptendulk on 15-Jul-2000 as events created
-- for campaigns dont require object attributes
-- =========================================================================

  /******************

   IF l_association_rec.MASTER_OBJECT_TYPE <> 'CAMP'
      OR (l_association_rec.USING_OBJECT_TYPE <> 'EVEH'
         AND l_association_rec.USING_OBJECT_TYPE <> 'EVEO')
   THEN
       AMS_ObjectAttribute_PVT.modify_object_attribute(
             p_api_version        => l_api_version,
             p_init_msg_list      => FND_API.g_false,
             p_commit             => FND_API.g_false,
             p_validation_level   => FND_API.g_valid_level_full,

             x_return_status      => l_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,

             p_object_type        => l_association_rec.MASTER_OBJECT_TYPE,
             p_object_id          => l_association_rec.MASTER_OBJECT_ID,
             p_attr               => l_association_rec.USING_OBJECT_TYPE,
             p_attr_defined_flag  => 'Y'
          );

          IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;
   END IF ;
   *******************/

-- =========================================================================
-- End of Code modified by ptendulk on 15-Jul-2000
-- =========================================================================

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
      ROLLBACK TO create_association;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_association;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_association;
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

END create_association;
---------------------------------------------------------------
-- PROCEDURE
--    delete_association
--
-- HISTORY
--  11/10/99     sugupta    created
--  07/15/00     ptendulk   Before Deleting Object attributes
--                          check Master object is not campaign and
--                          using object is not events .
---------------------------------------------------------------
PROCEDURE delete_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_object_association_id         IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_association';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_c_obj_id     NUMBER := p_object_association_id;
   l_object_type     VARCHAR2(30);
   l_object_id        NUMBER;
   l_attr           VARCHAR2(30);
   l_dummy        VARCHAR2(100);
   l_master        VARCHAR2(30);
   l_master_id    NUMBER;
   ------
   l_user_id  NUMBER;
   l_res_id   NUMBER;

   cursor get_objattr_info(l_obj_id IN NUMBER) is
   select distinct a.using_object_type, a.master_object_type, a.master_object_id
     from ams_object_associations a, ams_object_associations b
   where  a.master_object_type = b.master_object_type
   and a.master_object_id = b.master_object_id
   and a.using_object_type = b.using_object_type
   and b.object_association_id = l_obj_id;

   cursor get_count(c_obj_type IN VARCHAR2, c_obj_id IN NUMBER, c_attr IN VARCHAR2) is
   select 'dummy'
     from ams_object_associations
   where  master_object_type = c_obj_type
   and master_object_id = c_obj_id
   and using_object_type = c_attr;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR get_master_info(l_obj_id IN NUMBER) IS
   SELECT master_object_type, master_object_id
   FROM ams_object_associations
   WHERE object_association_id = l_obj_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_association;

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
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   l_user_id := FND_GLOBAL.User_Id;
   if l_user_id IS NOT NULL then
      open get_res_id(l_user_id);
      fetch get_res_id into l_res_id;
      close get_res_id;
   end if;

   open get_master_info(p_object_association_id);
   fetch get_master_info into l_master, l_master_id;
   close get_master_info;

   IF l_master <> 'CSCH' THEN
      if AMS_ACCESS_PVT.check_update_access(l_master_id, l_master, l_res_id, 'USER') = 'N'  then
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --reusing message
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      end if;
   END IF ;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

     OPEN get_objattr_info(l_c_obj_id);
     FETCH  get_objattr_info into l_attr, l_object_type, l_object_id;
   close get_objattr_info;

   DELETE FROM ams_object_associations
   WHERE object_association_id = p_object_association_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -----          Modify Object Attribute ---------------

     OPEN get_count(l_object_type,l_object_id,l_attr);
     FETCH  get_count into l_dummy;

     IF (GET_COUNT%NOTFOUND) THEN

   -- need to make a call to update ams_objec_attributes that no information
   -- exist for this combination of master obj type and id and using object type
   -- and set attribute defined flag to N

        -- =========================================================================
        -- Following condition is added by ptendulk on 15-Jul-2000 as events created
        -- for campaigns dont require object attributes
        -- =========================================================================
     null;

     /**
   IF l_object_type <> 'CAMP' OR (l_attr <> 'EVEH' AND l_attr <> 'EVEO')
        THEN

           AMS_ObjectAttribute_PVT.modify_object_attribute(
                p_api_version        => l_api_version,
                p_init_msg_list      => FND_API.g_false,
                p_commit             => FND_API.g_false,
                p_validation_level   => FND_API.g_valid_level_full,

                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,

                p_object_type        => l_object_type,
                p_object_id          => l_object_id,
                p_attr               => l_attr,
                p_attr_defined_flag  => 'N'
             );
           IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
           ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
           END IF;
        END IF;
       **/
        -- =========================================================================
        -- End of code Modified by ptendulk on 15-Jul-2000
        -- =========================================================================

     END IF;

     CLOSE get_count;

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
      ROLLBACK TO delete_association;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_association;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_association;
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

END delete_association;

-------------------------------------------------------------------
-- PROCEDURE
--    lock_association
--
-- HISTORY
--  11/10/99     sugupta    created
--------------------------------------------------------------------
PROCEDURE lock_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_object_association_id         IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_association';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_object_association_id      NUMBER;

   CURSOR c_association_b IS
   SELECT object_association_id
     FROM ams_object_associations
    WHERE object_association_id = p_object_association_id
      AND object_version_number = p_object_version
   FOR UPDATE OF object_association_id NOWAIT;


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

   OPEN c_association_b;
   FETCH c_association_b INTO l_object_association_id;
   IF (c_association_b%NOTFOUND) THEN
      CLOSE c_association_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_association_b;
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

END lock_association;


---------------------------------------------------------------------
-- PROCEDURE
--    update_association
--
-- HISTORY
--  11/10/99     sugupta    created
----------------------------------------------------------------------
PROCEDURE update_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_association_rec   IN  association_rec_type
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_association';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_association_rec       association_rec_type;
   l_return_status    VARCHAR2(1);
   ------
   l_user_id  NUMBER;
   l_res_id   NUMBER;

  CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;
BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_association;

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

   -- replace g_miss_char/num/date with current column values
   complete_association_rec(p_association_rec, l_association_rec);

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_association_items(
         p_association_rec        => p_association_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_association_record(
         p_association_rec       => p_association_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   l_user_id := FND_GLOBAL.User_Id;
   if l_user_id IS NOT NULL then
      open get_res_id(l_user_id);
      fetch get_res_id into l_res_id;
      close get_res_id;
   end if;

   IF l_association_rec.master_object_type <> 'CSCH' THEN
      if AMS_ACCESS_PVT.check_update_access(l_association_rec.MASTER_OBJECT_ID, l_association_rec.MASTER_OBJECT_TYPE, l_res_id, 'USER') = 'N'  then
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      end if;
   END IF ;
   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   UPDATE ams_object_associations SET
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    object_version_number = l_association_rec.object_version_number + 1,
    MASTER_OBJECT_TYPE = l_association_rec.MASTER_OBJECT_TYPE,
    MASTER_OBJECT_ID = l_association_rec.MASTER_OBJECT_ID,
    USING_OBJECT_TYPE = l_association_rec.USING_OBJECT_TYPE,
    USING_OBJECT_ID = l_association_rec.USING_OBJECT_ID,
    PRIMARY_FLAG = l_association_rec.PRIMARY_FLAG,
    USAGE_TYPE = l_association_rec.USAGE_TYPE,
    QUANTITY_NEEDED = l_association_rec.QUANTITY_NEEDED,
    QUANTITY_NEEDED_BY_DATE = l_association_rec.QUANTITY_NEEDED_BY_DATE,
    COST_FROZEN_FLAG = l_association_rec.COST_FROZEN_FLAG,
    PCT_OF_COST_TO_CHARGE_USED_BY = l_association_rec.PCT_OF_COST_TO_CHARGE_USED_BY,
    MAX_COST_TO_CHARGE_USED_BY = l_association_rec.MAX_COST_TO_CHARGE_USED_BY,
    MAX_COST_CURRENCY_CODE = l_association_rec.MAX_COST_CURRENCY_CODE,
    METRIC_CLASS = l_association_rec.METRIC_CLASS,
   FULFILL_ON_TYPE_CODE = l_association_rec.FULFILL_ON_TYPE_CODE,
    ATTRIBUTE_CATEGORY = l_association_rec.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = l_association_rec.ATTRIBUTE1,
    ATTRIBUTE2 = l_association_rec.ATTRIBUTE2,
    ATTRIBUTE3 = l_association_rec.ATTRIBUTE3,
    ATTRIBUTE4 = l_association_rec.ATTRIBUTE4,
    ATTRIBUTE5 = l_association_rec.ATTRIBUTE5,
    ATTRIBUTE6 = l_association_rec.ATTRIBUTE6,
    ATTRIBUTE7 = l_association_rec.ATTRIBUTE7,
    ATTRIBUTE8 = l_association_rec.ATTRIBUTE8,
    ATTRIBUTE9 = l_association_rec.ATTRIBUTE9,
    ATTRIBUTE10 = l_association_rec.ATTRIBUTE10,
    ATTRIBUTE11 = l_association_rec.ATTRIBUTE11,
    ATTRIBUTE12 = l_association_rec.ATTRIBUTE12,
    ATTRIBUTE13 = l_association_rec.ATTRIBUTE13,
    ATTRIBUTE14 = l_association_rec.ATTRIBUTE14,
    ATTRIBUTE15 = l_association_rec.ATTRIBUTE15,
    content_type = l_association_rec.content_type,
    sequence_no = l_association_rec.sequence_no
   WHERE object_association_id = l_association_rec.object_association_id
   AND object_version_number = l_association_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
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
      ROLLBACK TO update_association;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_association;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_association;
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

END update_association;
--------------------------------------------------------------------
-- PROCEDURE
--    validate_association
--
-- HISTORY
--  11/10/99     sugupta    created
--------------------------------------------------------------------
PROCEDURE validate_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_association_rec          IN  association_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_association';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
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

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_association_items(
         p_association_rec        => p_association_rec,
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

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_association_record(
         p_association_rec       => p_association_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

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

END validate_association;
---------------------------------------------------------------------
-- PROCEDURE
--    check_association
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------

FUNCTION check_association(
   p_master_type       IN   VARCHAR2,
   p_master_id      IN   NUMBER,
   p_using_type       IN   VARCHAR2,
   p_using_id      IN   NUMBER
) RETURN VARCHAR2
IS

l_foreign_table      VARCHAR2(30);
l_foreign_table_id   VARCHAR2(30);

BEGIN

   IF p_master_type = 'EVEH'
   THEN l_foreign_table := 'AMS_EVENT_HEADERS_ALL_B';
      l_foreign_table_id := 'EVENT_HEADER_ID';
   ELSIF p_master_type = 'EVEO'
   THEN l_foreign_table := 'AMS_EVENT_OFFERS_ALL_B';
     l_foreign_table_id := 'EVENT_OFFER_ID';
   ELSIF p_master_type = 'EONE'
     THEN l_foreign_table := 'AMS_EVENT_OFFERS_ALL_B';
      l_foreign_table_id := 'EVENT_OFFER_ID';
   ELSIF p_master_type = 'CAMP'
     THEN l_foreign_table := 'AMS_CAMPAIGNS_ALL_B';
      l_foreign_table_id := 'CAMPAIGN_ID';
   ELSIF p_master_type = 'CSCH'
   THEN l_foreign_table := 'AMS_CAMPAIGN_SCHEDULES_B';
      l_foreign_table_id := 'SCHEDULE_ID';
   ELSE

     return FND_API.g_false;
   END IF;
-- call fk utility to check master....will call again later to check for using..

   IF AMS_Utility_PVT.check_fk_exists(
      l_foreign_table,
      l_foreign_table_id,
      p_master_id
      ) =  FND_API.g_false
   THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_MASTER_ID');
            FND_MSG_PUB.add;
         END IF;

       return FND_API.g_false;
   END IF;

   IF p_using_type = 'EVEH'
     THEN  l_foreign_table := 'AMS_EVENT_HEADERS_ALL_B';
      l_foreign_table_id := 'EVENT_HEADER_ID';
   ELSIF p_using_type = 'EVEO'
     THEN l_foreign_table := 'AMS_EVENT_OFFERS_ALL_B';
      l_foreign_table_id := 'EVENT_OFFER_ID';

   ELSIF p_using_type = 'EONE'
     THEN l_foreign_table := 'AMS_EVENT_OFFERS_ALL_B';
      l_foreign_table_id := 'EVENT_OFFER_ID';

     ELSIF p_using_type = 'CAMP'
     THEN l_foreign_table := 'AMS_CAMPAIGNS_ALL_B';
      l_foreign_table_id := 'CAMPAIGN_ID';
   ELSIF p_using_type = 'DELV'
   THEN l_foreign_table := 'AMS_DELIVERABLES_ALL_B';
      l_foreign_table_id := 'DELIVERABLE_ID';
   ELSE
      return FND_API.g_false;
   END IF;

     IF AMS_Utility_PVT.check_fk_exists(
          l_foreign_table,
          l_foreign_table_id,
          p_using_id
        ) =  FND_API.g_false
     THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_USING_ID');
            FND_MSG_PUB.add;
         END IF;

         return FND_API.g_false;
     END IF;
  return fnd_api.g_true;
END check_association;

---------------------------------------------------------------------
-- PROCEDURE
--    check_association_req_items
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------
PROCEDURE check_association_req_items(
   p_association_rec       IN  association_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ user_status_id --------------------------
   IF p_association_rec.master_object_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_OBJ_NO_MASTER_OBJ_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_association_rec.using_object_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_OBJ_NO_USING_OBJ_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_association_rec.using_object_type IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_OBJ_NO_USING_OBJ_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_association_rec.master_object_type IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_OBJ_NO_MASTER_OBJ_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_association_rec.primary_flag IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_OBJ_NO_PRIMARY_FLAG');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_association_req_items;
---------------------------------------------------------------------
-- PROCEDURE
--    check_association_uk_items
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------
PROCEDURE check_association_uk_items(
   p_association_rec        IN  association_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1) := 'N';

   l_using_id   NUMBER ;
   l_master_objid  NUMBER ;
   l_using_objType   VARCHAR2(10);
   l_master_objType  VARCHAR2(10);

   CURSOR c_check_obj (
      p_using_id       IN NUMBER
     ,p_using_objType  IN VARCHAR2
     ,p_masterobjId    IN NUMBER
     ,p_masterobjType  IN VARCHAR2)
   IS
   SELECT  DISTINCT 'Y'
   FROM ams_object_associations
   WHERE master_object_type = p_masterobjType
   AND  master_object_id = p_masterobjId
   AND using_object_type = p_using_objType
   AND using_object_id = p_using_id;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_associations, when association_id is passed in, we need to
   -- check if this association_id is unique.
   --
   IF p_validation_mode = JTF_PLSQL_API.g_create
   AND p_association_rec.object_association_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
            'ams_object_associations',
            'object_association_id = ' || p_association_rec.object_association_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create
   AND  p_association_rec.using_object_id <> FND_API.g_miss_num
   AND  p_association_rec.master_object_id <> FND_API.g_miss_num
   AND p_association_rec.using_object_type <> FND_API.g_miss_char
   AND  p_association_rec.master_object_type <> FND_API.g_miss_char
   THEN
      OPEN  c_check_obj(p_association_rec.using_object_id,p_association_rec.using_object_type,p_association_rec.master_object_id,p_association_rec.master_object_type);
      FETCH c_check_obj INTO l_valid_flag;
      CLOSE c_check_obj;

      IF l_valid_flag = 'Y' THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS','AMS_ACCESS_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END check_association_uk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_association_lookup_fk
--
-- HISTORY
--  11/10/99     sugupta    created
--  07/15/00     ptendulk   Added condition to check fulfill_on_type_code,
--                          max_cost_currency_code not null before doing
--                          fk check
---------------------------------------------------------------------
PROCEDURE check_association_lookup_fk(
   p_association_rec        IN  association_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

l_usage_type    VARCHAR2(30);
l_master_type  VARCHAR2(30);
l_using_type   VARCHAR2(30);
l_master_id    NUMBER;
l_using_id     NUMBER;
l_additional_where_clause     VARCHAR2(4000);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- association to object  ------------------------
   IF p_association_rec.usage_type <> FND_API.g_miss_char THEN
   l_usage_type := p_association_rec.usage_type;
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_OBJECT_USAGE_TYPE',
            p_lookup_code => p_association_rec.usage_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_USAGE_TYPE');
            FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;
      ELSE
        /* master and using object lookup and their association with
           usage type logic*/
      /* check for master object type lookup..*/

         IF p_association_rec.master_object_type <> FND_API.g_miss_char THEN
         IF AMS_Utility_PVT.check_lookup_exists(
             p_lookup_type => 'AMS_MASTER_OBJECT_TYPE',
             p_lookup_code => p_association_rec.master_object_type
             ) = FND_API.g_false
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_MASTER_TYPE');
                FND_MSG_PUB.add;
                x_return_status := FND_API.g_ret_sts_error;
                RETURN;
               END IF;
         END IF;
         END IF;

      -- check for using object type lookup..
       IF p_association_rec.using_object_type <> FND_API.g_miss_char THEN
          IF AMS_Utility_PVT.check_lookup_exists(
                p_lookup_type => 'AMS_USING_OBJECT_TYPE',
                p_lookup_code => p_association_rec.using_object_type
             ) = FND_API.g_false
          THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_USING_TYPE');
                FND_MSG_PUB.add;
                x_return_status := FND_API.g_ret_sts_error;
                RETURN;
               END IF;
          END IF;
         END IF; /* using obj type*/
   ----    check for fk id's....
       IF p_association_rec.master_object_id <>  FND_API.g_miss_num THEN
      l_master_id := p_association_rec.master_object_id;
       END IF;

       IF p_association_rec.using_object_id <>  FND_API.g_miss_num THEN
          l_using_id := p_association_rec.using_object_id;
         END IF;

   ---    check corersponsing fk id's for master and using types..
      IF (p_association_rec.master_object_type <> FND_API.g_miss_char
         AND p_association_rec.using_object_type <> FND_API.g_miss_char) THEN

         l_master_type := p_association_rec.master_object_type;
         l_using_type := p_association_rec.using_object_type;

         IF check_association(l_master_type,l_master_id, l_using_type, l_using_id) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
               FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_ASSOCIATION');
             FND_MSG_PUB.add;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
             END IF;
          END IF; /* check association */
      END IF; /* check id's if types not null*/
    END IF; /* usage type lookup exists */
   END IF; /* usage type lookup not fnd_api.g_miss_char */
   -------------------------max_cost_currency_code--------------------
      l_additional_where_clause  := ' enabled_flag '||''''||'Y'||'''';
  IF p_association_rec.max_cost_currency_code <> FND_API.g_miss_char
  AND p_association_rec.max_cost_currency_code IS NOT NULL THEN
      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                  => 'FND_CURRENCIES'
            ,p_pk_name                    => 'CURRENCY_CODE'
            ,p_pk_value                   => p_association_rec.max_cost_currency_code
            ,p_pk_data_type               => AMS_Utility_PVT.G_VARCHAR2
            ,p_additional_where_clause  => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_BAD_CURRENCY_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -------------------------fulfill_on_type_code--------------------
  /**
    IF p_association_rec.fulfill_on_type_code <> FND_API.g_miss_char
      AND p_association_rec.fulfill_on_type_code IS NOT NULL THEN
      IF AMS_Utility_PVT.check_lookup_exists(
             p_lookup_type => 'AMS_EVENT_FULFILL_ON',
            p_lookup_code => p_association_rec.fulfill_on_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_BAD_FULFILL');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   **/
END check_association_lookup_fk;

---------------------------------------------------------------------
-- PROCEDURE
--    check_association_flag_items
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------
PROCEDURE check_association_flag_items(
   p_association_rec        IN  association_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- primary_flag ------------------------
   IF p_association_rec.primary_flag <> FND_API.g_miss_char
      AND p_association_rec.primary_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_association_rec.primary_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_BAD_PRIMARY_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   ----------------------- cost_frozen_flag ------------------------
   IF p_association_rec.cost_frozen_flag <> FND_API.g_miss_char
      AND p_association_rec.cost_frozen_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_association_rec.cost_frozen_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_BAD_COST_FROZEN_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
    END IF;

END check_association_flag_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_association_dates
--
-- HISTORY
--  10/30/01     musman    created
---------------------------------------------------------------------
PROCEDURE check_association_dates(
   p_association_rec        IN  association_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

CURSOR c_eveh_end_Date(l_event_id IN NUMBER)
IS
SELECT active_to_date
FROM ams_event_headers_all_b
WHERE event_header_id = l_event_id;

CURSOR c_eveo_end_date(l_event_offer_id IN NUMBER)
IS
SELECT event_end_date
FROM ams_event_offers_all_b
WHERE event_offer_id = l_event_offer_id;

CURSOR c_camp_end_date(l_camp_id IN NUMBER)
IS
SELECT actual_exec_end_date
FROM ams_campaigns_all_b
WHERE campaign_id = l_camp_id;

CURSOR c_csch_end_date(l_camp_sche_id IN NUMBER)
IS
SELECT end_date_time
FROM ams_campaign_schedules_b
WHERE  schedule_id = l_camp_sche_id;

l_end_date date ;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   IF p_association_rec.using_object_type = 'DELV'
   THEN

       IF p_association_rec.master_object_type = 'CAMP'
       THEN
          OPEN c_camp_end_date(p_association_rec.master_object_id);
          FETCH  c_camp_end_date INTO l_end_date;
          CLOSE c_camp_end_date;
       ELSIF p_association_rec.master_object_type = 'EVEH'
       THEN
          OPEN c_eveh_end_date(p_association_rec.master_object_id);
          FETCH  c_eveh_end_date INTO l_end_date;
          CLOSE c_eveh_end_date;
       ELSIF p_association_rec.master_object_type = 'EVEO'
       THEN
          OPEN c_eveo_end_date(p_association_rec.master_object_id);
          FETCH  c_eveo_end_date INTO l_end_date;
          CLOSE c_eveo_end_date;
       ELSIF p_association_rec.master_object_type = 'EONE'
       THEN
          OPEN c_eveo_end_date(p_association_rec.master_object_id);
          FETCH  c_eveo_end_date INTO l_end_date;
          CLOSE c_eveo_end_date;
       ELSIF p_association_rec.master_object_type = 'CSCH'
       THEN
          OPEN c_csch_end_date(p_association_rec.master_object_id);
          FETCH  c_csch_end_date INTO l_end_date;
          CLOSE c_csch_end_date;
       ELSE
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
             FND_MESSAGE.set_name('AMS', 'AMS_OBJ_INVALID_MASTER_TYPE');
             FND_MSG_PUB.add;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
          END IF;
       END IF;

       IF p_association_rec.quantity_needed_by_date IS NOT NULL
       AND p_association_rec.quantity_needed_by_date <> FND_API.g_miss_date
       THEN
          IF p_association_rec.quantity_needed_by_date > l_end_date
          THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                FND_MESSAGE.set_name('AMS', 'AMS_MASTER_OBJ_INVALID_DATES');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
          END IF;
       END IF;

   END IF; --using_object_type is DELV

END check_association_dates;
---------------------------------------------------------------------
-- PROCEDURE
--    check_association_items
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------
PROCEDURE check_association_items(
   p_association_rec        IN  association_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_association_req_items(
      p_association_rec       => p_association_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_association_uk_items(
      p_association_rec        => p_association_rec,
      p_validation_mode   => p_validation_mode,
      x_return_status     => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_association_lookup_fk(
      p_association_rec       => p_association_rec,
      x_return_status    => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_association_flag_items(
      p_association_rec        => p_association_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END check_association_items;
---------------------------------------------------------------------
-- PROCEDURE
--    check_association_record
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------
PROCEDURE check_association_record(
   p_association_rec       IN  association_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- do other record level checkings

END check_association_record;

---------------------------------------------------------------------
-- PROCEDURE
--    complete_association_rec
--
-- HISTORY
--  11/10/99     sugupta    created
---------------------------------------------------------------------
PROCEDURE complete_association_rec(
   p_association_rec      IN  association_rec_type,
   x_complete_rec    OUT NOCOPY association_rec_type
)
IS

   CURSOR c_association IS
   SELECT *
     FROM ams_object_associations
    WHERE object_association_id = p_association_rec.object_association_id;

   l_association_rec  c_association%ROWTYPE;

BEGIN
   x_complete_rec := p_association_rec;

   OPEN c_association;
   FETCH c_association INTO l_association_rec;
   IF c_association%NOTFOUND THEN
      CLOSE c_association;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_association;

   IF p_association_rec.master_object_type = FND_API.g_miss_char THEN
      x_complete_rec.master_object_type := l_association_rec.master_object_type;
   END IF;

   IF p_association_rec.master_object_id = FND_API.g_miss_num THEN
      x_complete_rec.master_object_id := l_association_rec.master_object_id;
   END IF;

   IF p_association_rec.using_object_type = FND_API.g_miss_char THEN
      x_complete_rec.using_object_type := l_association_rec.using_object_type;
   END IF;

   IF p_association_rec.using_object_id = FND_API.g_miss_num THEN
      x_complete_rec.using_object_id := l_association_rec.using_object_id;
   END IF;

   IF p_association_rec.usage_type = FND_API.g_miss_char THEN
      x_complete_rec.usage_type := l_association_rec.usage_type;
   END IF;

   IF p_association_rec.quantity_needed = FND_API.g_miss_num THEN
      x_complete_rec.quantity_needed := l_association_rec.quantity_needed;
   END IF;

   IF p_association_rec.quantity_needed_by_date = FND_API.g_miss_date THEN
      x_complete_rec.quantity_needed_by_date := l_association_rec.quantity_needed_by_date;
   END IF;

   IF p_association_rec.primary_flag  = FND_API.g_miss_char THEN
      x_complete_rec.primary_flag  := l_association_rec.primary_flag ;
   END IF;

   IF p_association_rec.cost_frozen_flag  = FND_API.g_miss_char THEN
      x_complete_rec.cost_frozen_flag  := l_association_rec.cost_frozen_flag ;
   END IF;

   IF p_association_rec.pct_of_cost_to_charge_used_by  = FND_API.g_miss_num THEN
      x_complete_rec.pct_of_cost_to_charge_used_by  := l_association_rec.pct_of_cost_to_charge_used_by ;
   END IF;

   IF p_association_rec.max_cost_to_charge_used_by  = FND_API.g_miss_num THEN
      x_complete_rec.max_cost_to_charge_used_by  := l_association_rec.max_cost_to_charge_used_by ;
   END IF;

   IF p_association_rec.max_cost_currency_code  = FND_API.g_miss_char THEN
      x_complete_rec.max_cost_currency_code  := l_association_rec.max_cost_currency_code ;
   END IF;


   IF p_association_rec.metric_class  = FND_API.g_miss_char THEN
      x_complete_rec.metric_class  := l_association_rec.metric_class ;
   END IF;

   IF p_association_rec.content_type  = FND_API.g_miss_char THEN
      x_complete_rec.content_type  := l_association_rec.content_type ;
   END IF;

   IF p_association_rec.sequence_no  = FND_API.g_miss_num THEN
      x_complete_rec.sequence_no  := l_association_rec.sequence_no ;
   END IF;
END complete_association_rec;
---------------------------------------------------------------------
-- PROCEDURE
--    init_association_rec
--
-- HISTORY
--    11/23/1999  sugupta  Create.
---------------------------------------------------------------------
PROCEDURE init_association_rec(
   x_association_rec  OUT NOCOPY  association_rec_type
)
IS
BEGIN

   x_association_rec.OBJECT_ASSOCIATION_ID := FND_API.g_miss_num;
   x_association_rec.last_update_date := FND_API.g_miss_date;
   x_association_rec.last_updated_by := FND_API.g_miss_num;
   x_association_rec.creation_date := FND_API.g_miss_date;
   x_association_rec.created_by := FND_API.g_miss_num;
   x_association_rec.last_update_login := FND_API.g_miss_num;
   x_association_rec.object_version_number := FND_API.g_miss_num;
   x_association_rec.MASTER_OBJECT_TYPE := FND_API.g_miss_char;
   x_association_rec.MASTER_OBJECT_ID := FND_API.g_miss_num;
   x_association_rec.USING_OBJECT_TYPE := FND_API.g_miss_char;
   x_association_rec.USING_OBJECT_ID := FND_API.g_miss_num;
   x_association_rec.PRIMARY_FLAG := FND_API.g_miss_char;
   x_association_rec.USAGE_TYPE := FND_API.g_miss_char;
   x_association_rec.QUANTITY_NEEDED := FND_API.g_miss_num;
   x_association_rec.QUANTITY_NEEDED_BY_DATE := FND_API.g_miss_date;
   x_association_rec.COST_FROZEN_FLAG := FND_API.g_miss_char;
   x_association_rec.PCT_OF_COST_TO_CHARGE_USED_BY := FND_API.g_miss_num;
   x_association_rec.MAX_COST_TO_CHARGE_USED_BY := FND_API.g_miss_num;
   x_association_rec.MAX_COST_CURRENCY_CODE := FND_API.g_miss_char;
   x_association_rec.METRIC_CLASS := FND_API.g_miss_char;
   x_association_rec.FULFILL_ON_TYPE_CODE := FND_API.g_miss_char;
   x_association_rec.attribute1 := FND_API.g_miss_char;
   x_association_rec.attribute2 := FND_API.g_miss_char;
   x_association_rec.attribute3 := FND_API.g_miss_char;
   x_association_rec.attribute4 := FND_API.g_miss_char;
   x_association_rec.attribute5 := FND_API.g_miss_char;
   x_association_rec.attribute6 := FND_API.g_miss_char;
   x_association_rec.attribute7 := FND_API.g_miss_char;
   x_association_rec.attribute8 := FND_API.g_miss_char;
   x_association_rec.attribute9 := FND_API.g_miss_char;
   x_association_rec.attribute10 := FND_API.g_miss_char;
   x_association_rec.attribute11 := FND_API.g_miss_char;
   x_association_rec.attribute12 := FND_API.g_miss_char;
   x_association_rec.attribute13 := FND_API.g_miss_char;
   x_association_rec.attribute14 := FND_API.g_miss_char;
   x_association_rec.attribute15 := FND_API.g_miss_char;
   x_association_rec.content_type := FND_API.g_miss_char;
   x_association_rec.sequence_no := FND_API.g_miss_num;
END init_association_rec;

END AMS_Associations_PVT;

/
