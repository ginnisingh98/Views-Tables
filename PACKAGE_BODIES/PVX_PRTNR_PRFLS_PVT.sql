--------------------------------------------------------
--  DDL for Package Body PVX_PRTNR_PRFLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_PRTNR_PRFLS_PVT" AS
/* $Header: pvxvppfb.pls 115.19 2003/08/07 05:20:43 rdsharma ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='PVX_PRTNR_PRFLS_PVT';

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Prtnr_Prfls
--
-- PURPOSE
--    Create a new partner profile record
--
-- PARAMETERS
--    p_prtnr_prfls_rec: the new record to be inserted
--    x_partner_profile_id: return the partner_profile_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If partner_profile_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If partner_profile_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Prtnr_Prfls(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.g_false
  ,p_commit             IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level   IN  NUMBER   := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_prtnr_prfls_rec    IN  prtnr_prfls_rec_type
  ,x_partner_profile_id OUT NOCOPY NUMBER
  )
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_Prtnr_Prfls';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   l_prtnr_prfls_rec       prtnr_prfls_rec_type := p_prtnr_prfls_rec;

   l_object_version_number NUMBER := 1;

   l_uniqueness_check     VARCHAR2(10);
   l_status               VARCHAR2(1);


   -- Cursor to get the sequence for prtnr_prfls
   CURSOR c_prtnr_prfls_seq IS
   SELECT PV_partner_profiles_S.NEXTVAL
   FROM DUAL;

   -- Cursor to validate the uniqueness
   CURSOR c_count(cv_partner_profile_id IN NUMBER) IS
   SELECT  'ANYTHING'
   FROM  PV_partner_profiles
   WHERE partner_profile_id = cv_partner_profile_id;


BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_Prtnr_Prfls;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --dbms_output.put_line(l_full_name||': start');

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
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   --dbms_output.put_line(l_full_name||': validate');
   Validate_Prtnr_Prfls(
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_prtnr_prfls_rec  => l_prtnr_prfls_rec
   );


    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   --dbms_output.put_line(l_full_name||': back validate');

  -------------------------- insert --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': insert');
  END IF;


  IF l_prtnr_prfls_rec.partner_profile_id IS NULL THEN
    LOOP
      -- Get the identifier
      OPEN  c_prtnr_prfls_seq;
      FETCH c_prtnr_prfls_seq INTO l_prtnr_prfls_rec.partner_profile_id;
      CLOSE c_prtnr_prfls_seq;

      -- Check the uniqueness of the identifier
      OPEN  c_count(l_prtnr_prfls_rec.partner_profile_id);
      FETCH c_count INTO l_uniqueness_check;
        -- Exit when the identifier uniqueness is established
        EXIT WHEN c_count%ROWCOUNT = 0;
      CLOSE c_count;
   END LOOP;
  END IF;

  IF c_count%ISOPEN THEN
    CLOSE c_count;
  END IF;

  IF l_prtnr_prfls_rec.status IS NULL OR l_prtnr_prfls_rec.status = FND_API.G_MISS_CHAR THEN
    Determine_Partner_Status(l_prtnr_prfls_rec, l_status);
  ELSE
    l_status := l_prtnr_prfls_rec.status;
  END IF;

   --dbms_output.put_line(l_full_name||': start insert');
  INSERT INTO PV_partner_profiles (
       partner_profile_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,partner_id
      ,target_revenue_amt
      ,actual_revenue_amt
      ,target_revenue_pct
      ,actual_revenue_pct
      ,orig_system_reference
      ,orig_system_type
      ,capacity_size
      ,capacity_amount
      ,auto_match_allowed_flag
      ,purchase_method
      ,cm_id
      ,ph_support_rep
      --,security_group_id
      ,object_version_number
      ,lead_sharing_status
      ,lead_share_appr_flag
      ,partner_relationship_id
      ,partner_level
      ,preferred_vad_id
      ,partner_group_id
      ,partner_resource_id
      ,partner_group_number
      ,partner_resource_number
      ,sales_partner_flag
      ,indirectly_managed_flag
      ,channel_marketing_manager
      ,related_partner_id
      ,max_users
      ,partner_party_id
      ,status
      )
    VALUES (
       l_prtnr_prfls_rec.partner_profile_id
      ,SYSDATE                                -- LAST_UPDATE_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- LAST_UPDATED_BY
      ,SYSDATE                                -- CREATION_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- CREATED_BY
      ,NVL(FND_GLOBAL.conc_login_id,-1)       -- LAST_UPDATE_LOGIN
      ,l_prtnr_prfls_rec.partner_id
      ,l_prtnr_prfls_rec.target_revenue_amt
      ,l_prtnr_prfls_rec.actual_revenue_amt
      ,l_prtnr_prfls_rec.target_revenue_pct
      ,l_prtnr_prfls_rec.actual_revenue_pct
      ,l_prtnr_prfls_rec.orig_system_reference
      ,l_prtnr_prfls_rec.orig_system_type
      ,l_prtnr_prfls_rec.capacity_size
      ,l_prtnr_prfls_rec.capacity_amount
      ,l_prtnr_prfls_rec.auto_match_allowed_flag
      ,l_prtnr_prfls_rec.purchase_method
      ,l_prtnr_prfls_rec.cm_id
      ,l_prtnr_prfls_rec.ph_support_rep
      --,l_prtnr_prfls_rec.security_group_id
      ,l_object_version_number                -- object_version_number
      ,l_prtnr_prfls_rec.lead_sharing_status
      ,l_prtnr_prfls_rec.lead_share_appr_flag
      ,l_prtnr_prfls_rec.partner_relationship_id
      ,l_prtnr_prfls_rec.partner_level
      ,l_prtnr_prfls_rec.preferred_vad_id
      ,l_prtnr_prfls_rec.partner_group_id
      ,l_prtnr_prfls_rec.partner_resource_id
      ,l_prtnr_prfls_rec.partner_group_number
      ,l_prtnr_prfls_rec.partner_resource_number
      ,l_prtnr_prfls_rec.sales_partner_flag
      ,l_prtnr_prfls_rec.indirectly_managed_flag
      ,l_prtnr_prfls_rec.channel_marketing_manager
      ,l_prtnr_prfls_rec.related_partner_id
      ,l_prtnr_prfls_rec.max_users
      ,l_prtnr_prfls_rec.partner_party_id
      ,l_status
      );

  ------------------------- finish -------------------------------
  x_partner_profile_id := l_prtnr_prfls_rec.partner_profile_id;

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Create_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Create_Prtnr_Prfls;


---------------------------------------------------------------
-- PROCEDURE
--   Delete_Prtnr_Prfls
--
---------------------------------------------------------------
PROCEDURE Delete_Prtnr_Prfls(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.g_false
  ,p_commit             IN  VARCHAR2 := FND_API.g_false

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_partner_profile_id IN  NUMBER
  ,p_object_version     IN  NUMBER
  )
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Prtnr_Prflss';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_Prtnr_Prfls;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
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

   ------------------------ delete ------------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   DELETE FROM PV_PARTNER_PROFILES
     WHERE partner_profile_id = p_partner_profile_id
     AND   object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
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

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Prtnr_Prfls;
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

END Delete_Prtnr_Prfls;


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Prtnr_Prfls
--
--------------------------------------------------------------------
PROCEDURE Lock_Prtnr_Prfls(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_partner_profile_id IN  NUMBER
  ,p_object_version     IN  NUMBER
  )
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Prtnr_Prfls';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_partner_profile_id      NUMBER;

   CURSOR c_prtnr_prfls IS
   SELECT  partner_profile_id
     FROM  PV_PARTNER_PROFILES
     WHERE partner_profile_id = p_partner_profile_id
     AND   object_version_number = p_object_version
   FOR UPDATE OF partner_profile_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
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
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN  c_prtnr_prfls;
   FETCH c_prtnr_prfls INTO l_partner_profile_id;
   IF (c_prtnr_prfls%NOTFOUND) THEN
      CLOSE c_prtnr_prfls;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_prtnr_prfls;


   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('PV', 'PV_RESOURCE_LOCKED');
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

END Lock_Prtnr_Prfls;


---------------------------------------------------------------------
-- PROCEDURE
-- Update_Prtnr_Prfls
----------------------------------------------------------------------
PROCEDURE Update_Prtnr_Prfls(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_prtnr_prfls_rec   IN  prtnr_prfls_rec_type
  )
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_Prtnr_Prfls';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_prtnr_prfls_rec   prtnr_prfls_rec_type;
   l_return_status     VARCHAR2(1);
   l_mode              VARCHAR2(30) := 'UPDATE';

  -- Define the record for the related partner_id
  rel_prtnr_prfls_rec   prtnr_prfls_rec_type;

  l_status             VARCHAR2(1);
  l_old_status         VARCHAR2(1);

  -- Cursor to select old status value

  CURSOR c_prtnr_status IS
    SELECT NVL(status, 'A') partner_status
      FROM pv_partner_profiles
      WHERE partner_profile_id = p_prtnr_prfls_rec.partner_profile_id;

  -- Cursor : cur_related_record
  CURSOR cur_related_record (var_partner_id IN NUMBER) IS
  SELECT partner_id, partner_profile_id, object_version_number
  FROM pv_partner_profiles
  WHERE related_partner_id = var_partner_id;
    -- Cursor record
    currec_related_record cur_related_record%ROWTYPE;

  l_list                                  WF_PARAMETER_LIST_T;
  l_param                                 WF_PARAMETER_T;
  l_key                                   VARCHAR2(240);
  l_event_name                            VARCHAR2(240) := 'oracle.apps.pv.partner.Profile.updateStatus';

BEGIN
--dbms_output.put_line('entered Update');
   -------------------- initialize -------------------------
   SAVEPOINT Update_Prtnr_Prfls;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
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

--dbms_output.put_line('Before Validate');

   ----------------------- validate ----------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Prtnr_Prfls_Items(
  	     	p_prtnr_prfls_rec => p_prtnr_prfls_rec,
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
   Complete_Prtnr_Prfls_Rec(p_prtnr_prfls_rec, l_prtnr_prfls_rec);

--dbms_output.put_line('p_prtnr_prfls_rec.cm_id = '||TO_CHAR(p_prtnr_prfls_rec.cm_id));
--dbms_output.put_line('l_prtnr_prfls_rec.cm_id = '||TO_CHAR(l_prtnr_prfls_rec.cm_id));

--dbms_output.put_line('Got complete record ');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Prtnr_Prfls_Record(
  	 p_prtnr_prfls_rec => p_prtnr_prfls_rec,
         p_complete_rec    => l_prtnr_prfls_rec,
         p_mode            => l_mode,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   -------------------------- update --------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

--dbms_output.put_line('partner_profile_id = '||TO_CHAR(l_prtnr_prfls_rec.partner_profile_id));
--dbms_output.put_line('object_version_number = '||TO_CHAR(l_prtnr_prfls_rec.object_version_number));


   IF l_prtnr_prfls_rec.status IS NULL OR l_prtnr_prfls_rec.status = FND_API.G_MISS_CHAR THEN
     Determine_Partner_Status(l_prtnr_prfls_rec, l_status);
   ELSE
     l_status := l_prtnr_prfls_rec.status;
   END IF;

   OPEN c_prtnr_status;
   FETCH c_prtnr_status INTO l_old_status;
   CLOSE c_prtnr_status;

   IF l_old_status <> l_status THEN

     -- Raise Business Event
     --Get the item key
     l_key := PVX_EVENT_PKG.item_key( l_event_name );

     -- initialization of object variables
     l_list := WF_PARAMETER_LIST_T();

     -- Add Context values to the list
     pvx_event_pkg.AddParamEnvToList(l_list);

     l_param := WF_PARAMETER_T( NULL, NULL );

     -- fill the parameters list
     l_list.extend;
     l_param.SetName( 'PARTNER_ID' );
     l_param.SetValue( l_prtnr_prfls_rec.PARTNER_ID );
     l_list(l_list.last) := l_param;

     l_list.extend;
     l_param.SetName( 'OLD_PARTNER_STATUS' );
     l_param.SetValue( l_old_status );
     l_list(l_list.last) := l_param;

     l_list.extend;
     l_param.SetName( 'NEW_PARTNER_STATUS' );
     l_param.SetValue( l_status );
     l_list(l_list.last) := l_param;

     -- Raise Event
     PVX_EVENT_PKG.Raise_Event(
       p_event_name        => l_event_name,
       p_event_key         => l_key,
       p_parameters        => l_list );

     l_list.DELETE;

   END IF;

   UPDATE PV_PARTNER_PROFILES SET
       last_update_date           = SYSDATE
      ,last_updated_by            = NVL(FND_GLOBAL.user_id,-1)
      ,last_update_login          = NVL(FND_GLOBAL.conc_login_id,-1)
      ,PARTNER_ID                 = l_prtnr_prfls_rec.PARTNER_ID
      ,TARGET_REVENUE_AMT         = l_prtnr_prfls_rec.TARGET_REVENUE_AMT
      ,ACTUAL_REVENUE_AMT         = l_prtnr_prfls_rec.ACTUAL_REVENUE_AMT
      ,TARGET_REVENUE_PCT         = l_prtnr_prfls_rec.TARGET_REVENUE_PCT
      ,ACTUAL_REVENUE_PCT         = l_prtnr_prfls_rec.ACTUAL_REVENUE_PCT
      ,ORIG_SYSTEM_REFERENCE      = l_prtnr_prfls_rec.ORIG_SYSTEM_REFERENCE
      ,ORIG_SYSTEM_TYPE           = l_prtnr_prfls_rec.ORIG_SYSTEM_TYPE
      ,CAPACITY_SIZE              = l_prtnr_prfls_rec.CAPACITY_SIZE
      ,CAPACITY_AMOUNT            = l_prtnr_prfls_rec.CAPACITY_AMOUNT
      ,AUTO_MATCH_ALLOWED_FLAG    = l_prtnr_prfls_rec.AUTO_MATCH_ALLOWED_FLAG
      ,PURCHASE_METHOD            = l_prtnr_prfls_rec.PURCHASE_METHOD
      ,CM_ID                      = l_prtnr_prfls_rec.CM_ID
      ,PH_SUPPORT_REP             = l_prtnr_prfls_rec.PH_SUPPORT_REP
      --,security_group_id          = l_prtnr_prfls_rec.security_group_id
      ,object_version_number      = l_prtnr_prfls_rec.object_version_number + 1
      ,lead_sharing_status        = l_prtnr_prfls_rec.lead_sharing_status
      ,lead_share_appr_flag       = l_prtnr_prfls_rec.lead_share_appr_flag
      ,partner_relationship_id    = l_prtnr_prfls_rec.partner_relationship_id
      ,partner_level              = l_prtnr_prfls_rec.partner_level
      ,preferred_vad_id           = l_prtnr_prfls_rec.preferred_vad_id
      ,partner_group_id           = l_prtnr_prfls_rec.partner_group_id
      ,partner_resource_id        = l_prtnr_prfls_rec.partner_resource_id
      ,partner_group_number       = l_prtnr_prfls_rec.partner_group_number
      ,partner_resource_number    = l_prtnr_prfls_rec.partner_resource_number
      ,sales_partner_flag         = l_prtnr_prfls_rec.sales_partner_flag
      ,indirectly_managed_flag    = l_prtnr_prfls_rec.indirectly_managed_flag
      ,channel_marketing_manager  = l_prtnr_prfls_rec.channel_marketing_manager
      ,related_partner_id         = l_prtnr_prfls_rec.related_partner_id
      ,max_users                  = l_prtnr_prfls_rec.max_users
      ,partner_party_id           = l_prtnr_prfls_rec.partner_party_id
      ,status                     = l_status
   WHERE partner_profile_id    = l_prtnr_prfls_rec.partner_profile_id
   AND   object_version_number = l_prtnr_prfls_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- Call the PVX_PRTNR_PRFLS_PVT.Update_Prtnr_Prfls recursively
   -- if partner_id also happens to be a related_partner_id for some records

   -- Open the cursor cur_related_record
   OPEN cur_related_record(l_prtnr_prfls_rec.partner_id);
   FETCH cur_related_record INTO currec_related_record;
   CLOSE cur_related_record;

   IF (currec_related_record.partner_id IS NOT NULL) THEN

      --dbms_output.put_line('Related Record Exists');

      /*dbms_output.put_line('partner_id : '||TO_CHAR(l_prtnr_prfls_rec.partner_id)
                           ||' is the related_partner_id for the partner_id  = '
                           ||TO_CHAR(currec_related_record.partner_id)
                           ||' and the profile_id = '||TO_CHAR(currec_related_record.partner_profile_id));
      */
      -- Initialize the record with G_MISS values
      PVX_PRTNR_PRFLS_PVT.Init_Prtnr_Prfls_Rec(rel_prtnr_prfls_rec);
      --dbms_output.put_line('Initialized Record');

      -- Set the record for the related partner_id
      rel_prtnr_prfls_rec.partner_profile_id    := currec_related_record.partner_profile_id;
      rel_prtnr_prfls_rec.object_version_number := currec_related_record.object_version_number;
      rel_prtnr_prfls_rec.lead_share_appr_flag  := l_prtnr_prfls_rec.lead_share_appr_flag;
      rel_prtnr_prfls_rec.sales_partner_flag    := l_prtnr_prfls_rec.sales_partner_flag;

--dbms_output.put_line('rel_prtnr_prfls_rec.partner_profile_id = '||TO_CHAR(rel_prtnr_prfls_rec.partner_profile_id));
--dbms_output.put_line('rel_prtnr_prfls_rec.object_version_number = '||TO_CHAR(rel_prtnr_prfls_rec.object_version_number));
--dbms_output.put_line('rel_prtnr_prfls_rec.lead_share_appr_flag = '||rel_prtnr_prfls_rec.lead_share_appr_flag);
--dbms_output.put_line('rel_prtnr_prfls_rec.sales_partner_flag = '||rel_prtnr_prfls_rec.sales_partner_flag);

--dbms_output.put_line('Before updating the related_partner_id record');
      PVX_PRTNR_PRFLS_PVT.Update_Prtnr_Prfls(
       p_api_version       => p_api_version
      ,p_init_msg_list     => p_init_msg_list
      ,p_commit            => p_commit
      ,p_validation_level  => p_validation_level

      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_prtnr_prfls_rec   => rel_prtnr_prfls_rec
      );

/*
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_LOGD_RES_ID');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.logged_resource_id) );
        FND_MSG_PUB.add;
      END IF;
*/

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


--dbms_output.put_line('After updating the related_partner_id record');

   END IF;

   -------------------- finish --------------------------

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Prtnr_Prfls;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Prtnr_Prfls;
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

END Update_Prtnr_Prfls;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Prtnr_Prfls
--
--------------------------------------------------------------------
PROCEDURE Validate_Prtnr_Prfls(
   p_api_version      IN  NUMBER
  ,p_init_msg_list    IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2

  ,p_prtnr_prfls_rec  IN  prtnr_prfls_rec_type
  )
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Prtnr_Prfls';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
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
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;
   --dbms_output.put_line(l_full_name||': start item validate');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Prtnr_Prfls_Items(
         p_prtnr_prfls_rec => p_prtnr_prfls_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   --dbms_output.put_line(l_full_name||': start record validate');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Prtnr_Prfls_Record(
         p_prtnr_prfls_rec => p_prtnr_prfls_rec,
         p_complete_rec      => NULL,
         x_return_status     => l_return_status
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

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
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

END Validate_Prtnr_Prfls;

---------------------------------------------------------------------
-- PROCEDURE
--    Determine_Partner_Status
--
---------------------------------------------------------------------
  PROCEDURE Determine_Partner_Status(
    p_prtnr_prfls_rec   IN  prtnr_prfls_rec_type
   ,x_partner_status   OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR c_relationship_status (p_party_id IN NUMBER, p_partner_party_id IN NUMBER) IS
      SELECT subject_id vendor_party_id,
             start_date,
             end_date,
             status
        FROM hz_relationships
        WHERE party_id = p_party_id
          AND object_id = p_partner_party_id;

    CURSOR c_party_status (p_party_id IN NUMBER) IS
      SELECT NVL(status, 'A') party_status
        FROM hz_parties
        WHERE party_id = p_party_id;

    CURSOR c_resource_status (p_resource_id IN NUMBER) IS
      SELECT start_date_active,
             end_date_active
        FROM jtf_rs_resource_extns
        WHERE resource_id = p_resource_id;

    l_vendor_party_id   NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_status            VARCHAR2(1);
    l_new_partner_status VARCHAR2(1);

  BEGIN

    l_new_partner_status := 'A';

    OPEN c_relationship_status ( p_prtnr_prfls_rec.partner_id, p_prtnr_prfls_rec.partner_party_id );
    FETCH c_relationship_status INTO l_vendor_party_id, l_start_date, l_end_date, l_status;
    IF c_relationship_status%FOUND THEN
      IF l_status = 'I' THEN
        l_new_partner_status := 'I';
      ELSE
        IF l_start_date > SYSDATE OR NVL(l_end_date, SYSDATE) < SYSDATE THEN
          l_new_partner_status := 'I';
        END IF;
      END IF;
    END IF;
    CLOSE c_relationship_status;

    IF l_new_partner_status <> 'I' THEN
      OPEN c_party_status (p_prtnr_prfls_rec.partner_party_id);
      FETCH c_party_status INTO l_status;
      IF c_party_status%FOUND THEN
        IF l_status = 'I' THEN
          l_new_partner_status := 'I';
        END IF;
      END IF;
      CLOSE c_party_status;
    END IF;

    IF l_new_partner_status <> 'I' THEN
      OPEN c_party_status (l_vendor_party_id);
      FETCH c_party_status INTO l_status;
      IF c_party_status%FOUND THEN
        IF l_status = 'I' THEN
          l_new_partner_status := 'I';
        END IF;
      END IF;
      CLOSE c_party_status;
    END IF;

    IF l_new_partner_status <> 'I' THEN
      OPEN c_resource_status (p_prtnr_prfls_rec.partner_resource_id);
      FETCH c_resource_status INTO l_start_date, l_end_date;
      IF c_resource_status%FOUND THEN
        IF l_start_date > SYSDATE OR NVL(l_end_date, SYSDATE) < SYSDATE THEN
          l_new_partner_status := 'I';
        END IF;
      END IF;
      CLOSE c_resource_status;
    END IF;

    x_partner_status := l_new_partner_status;

  END Determine_Partner_Status;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Req_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Req_Items(
   p_prtnr_prfls_rec   IN  prtnr_prfls_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ partner_id --------------------------
   IF p_prtnr_prfls_rec.partner_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_PARTNER_ID');
         FND_MESSAGE.set_token('ID',to_char(p_prtnr_prfls_rec.partner_id) );
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ cm_id -------------------------------
   /*ELSIF p_prtnr_prfls_rec.cm_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_CM_ID');
         FND_MESSAGE.set_token('ID',to_char(p_prtnr_prfls_rec.cm_id) );
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN; */
   END IF;

END Check_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Uk_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Uk_Items(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- when attr_val_id is passed in, we need to
   -- check if this is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_prtnr_prfls_rec.partner_profile_id IS NOT NULL
   THEN
      IF PVX_Utility_PVT.check_uniqueness(
		    'PV_PARTNER_PROFILES',
		    'partner_profile_id = ' || p_prtnr_prfls_rec.partner_profile_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
         FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_ID');
         FND_MESSAGE.set_token('ID',to_char(p_prtnr_prfls_rec.partner_profile_id) );
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other unique items

END Check_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fk_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Fk_Items(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- partner_id ------------------------
   IF p_prtnr_prfls_rec.partner_id <> FND_API.g_miss_num THEN
      IF PVX_Utility_PVT.check_fk_exists(
            'HZ_PARTIES',    -- Parent schema object having the primary key
            'PARTY_ID',     -- Column name in the parent object that maps to the fk value
            p_prtnr_prfls_rec.partner_id,     -- Value of fk to be validated against the parent object's pk column
           PVX_utility_PVT.g_number          -- datatype of fk
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_BAD_PARTNER_ID');
         FND_MESSAGE.set_token('ID',to_char(p_prtnr_prfls_rec.partner_id) );
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other fk items

END Check_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Lookup_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Lookup_Items(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   -- check other lookup codes

END Check_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Flag_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Flag_Items(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   ----------------------- lead_share_appr_flag ------------------------
   IF p_prtnr_prfls_rec.lead_share_appr_flag <> FND_API.g_miss_char
      AND p_prtnr_prfls_rec.lead_share_appr_flag IS NOT NULL
   THEN
      IF PVX_Utility_PVT.is_Y_or_N(p_prtnr_prfls_rec.lead_share_appr_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_INVALID_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other flags

END Check_Flag_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Prtnr_Prfls_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Prtnr_Prfls_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  )
IS
BEGIN

   --dbms_output.put_line(': start req items validate');
   Check_Req_Items(
      p_prtnr_prfls_rec => p_prtnr_prfls_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --dbms_output.put_line(': start uk record validate');
   Check_Uk_Items(
      p_prtnr_prfls_rec => p_prtnr_prfls_rec
     ,p_validation_mode => p_validation_mode
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --dbms_output.put_line(': start fk record validate');
   Check_Fk_Items(
      p_prtnr_prfls_rec => p_prtnr_prfls_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --dbms_output.put_line(': start lookup record validate');
   Check_Lookup_Items(
      p_prtnr_prfls_rec => p_prtnr_prfls_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --dbms_output.put_line(': start flag record validate');
   Check_Flag_Items(
      p_prtnr_prfls_rec => p_prtnr_prfls_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Prtnr_Prfls_Items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Prtnr_Prfls_Record
--
---------------------------------------------------------------------
PROCEDURE Check_Prtnr_Prfls_Record(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,p_complete_rec    IN  prtnr_prfls_rec_type := NULL
  ,p_mode            IN  VARCHAR2 := 'INSERT'
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   /* Raise an error if already NOT NULL value for CM_ID is being updated to null.
   */
   IF p_complete_rec.cm_id IS NOT NULL THEN
     IF p_prtnr_prfls_rec.cm_id IS NULL THEN
       --OR p_prtnr_prfls_rec.cm_id = FND_API.G_MISS_NUM
       FND_MESSAGE.Set_name('PV','PV_CM_ID_UPDATE_VIOLATION');
       FND_MESSAGE.Set_Token('ID', TO_CHAR(p_complete_rec.cm_id));
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
     END IF;
   END IF;

   -- do other record level checkings

END Check_Prtnr_Prfls_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Prtnr_Prfls_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_Prtnr_Prfls_Rec(
   x_prtnr_prfls_rec OUT NOCOPY  prtnr_prfls_rec_type
  )
IS
BEGIN
      x_prtnr_prfls_rec.PARTNER_PROFILE_ID        := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.LAST_UPDATE_DATE          := FND_API.G_MISS_DATE;
      x_prtnr_prfls_rec.LAST_UPDATED_BY           := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.CREATION_DATE             := FND_API.G_MISS_DATE;
      x_prtnr_prfls_rec.CREATED_BY                := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.LAST_UPDATE_LOGIN         := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.PARTNER_ID                := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.TARGET_REVENUE_AMT        := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.ACTUAL_REVENUE_AMT        := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.TARGET_REVENUE_PCT        := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.ACTUAL_REVENUE_PCT        := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.ORIG_SYSTEM_REFERENCE     := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.ORIG_SYSTEM_TYPE          := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.CAPACITY_SIZE             := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.CAPACITY_AMOUNT           := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.AUTO_MATCH_ALLOWED_FLAG   := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.PURCHASE_METHOD           := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.CM_ID                     := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.PH_SUPPORT_REP            := FND_API.G_MISS_NUM;
      --x_prtnr_prfls_rec.SECURITY_GROUP_ID         := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.OBJECT_VERSION_NUMBER     := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.LEAD_SHARING_STATUS       := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.LEAD_SHARE_APPR_FLAG      := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.PARTNER_RELATIONSHIP_ID   := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.PARTNER_LEVEL             := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.PREFERRED_VAD_ID          := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.partner_group_id          := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.partner_resource_id       := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.partner_group_number      := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.partner_resource_number   := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.sales_partner_flag        := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.indirectly_managed_flag   := FND_API.G_MISS_CHAR;
      x_prtnr_prfls_rec.channel_marketing_manager := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.related_partner_id        := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.max_users                 := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.partner_party_id	  := FND_API.G_MISS_NUM;
      x_prtnr_prfls_rec.status                    := FND_API.G_MISS_CHAR;

END Init_Prtnr_Prfls_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Prtnr_Prfls_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_Prtnr_Prfls_Rec(
   p_prtnr_prfls_rec IN  prtnr_prfls_rec_type
  ,x_complete_rec    OUT NOCOPY prtnr_prfls_rec_type
  )
IS

   CURSOR c_prtnr_prfls IS
   SELECT *
     FROM  PV_PARTNER_PROFILES
     WHERE partner_profile_id = p_prtnr_prfls_rec.partner_profile_id;

   l_prtnr_prfls_rec   c_prtnr_prfls%ROWTYPE;

BEGIN

   x_complete_rec := p_prtnr_prfls_rec;

   OPEN c_prtnr_prfls;
   FETCH c_prtnr_prfls INTO l_prtnr_prfls_rec;
   IF c_prtnr_prfls%NOTFOUND THEN
      CLOSE c_prtnr_prfls;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_prtnr_prfls;

IF p_prtnr_prfls_rec.partner_id          = FND_API.G_MISS_NUM THEN
   x_complete_rec.partner_id        := l_prtnr_prfls_rec.partner_id;
END IF;

IF p_prtnr_prfls_rec.target_revenue_amt          = FND_API.G_MISS_NUM THEN
   x_complete_rec.target_revenue_amt        := l_prtnr_prfls_rec.target_revenue_amt;
END IF;

IF p_prtnr_prfls_rec.actual_revenue_amt          = FND_API.G_MISS_NUM  THEN
   x_complete_rec.actual_revenue_amt        := l_prtnr_prfls_rec.actual_revenue_amt;
END IF;

IF p_prtnr_prfls_rec.target_revenue_pct          = FND_API.G_MISS_NUM THEN
   x_complete_rec.target_revenue_pct        := l_prtnr_prfls_rec.target_revenue_pct;
END IF;

IF p_prtnr_prfls_rec.actual_revenue_pct          = FND_API.G_MISS_NUM  THEN
   x_complete_rec.actual_revenue_pct        := l_prtnr_prfls_rec.actual_revenue_pct;
END IF;

IF p_prtnr_prfls_rec.orig_system_reference          = FND_API.G_MISS_CHAR  THEN
   x_complete_rec.orig_system_reference        := l_prtnr_prfls_rec.orig_system_reference;
END IF;

IF p_prtnr_prfls_rec.orig_system_type          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.orig_system_type        := l_prtnr_prfls_rec.orig_system_type;
END IF;

IF p_prtnr_prfls_rec.capacity_size          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.capacity_size        := l_prtnr_prfls_rec.capacity_size;
END IF;

IF p_prtnr_prfls_rec.capacity_amount          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.capacity_amount        := l_prtnr_prfls_rec.capacity_amount;
END IF;

IF p_prtnr_prfls_rec.auto_match_allowed_flag        = FND_API.G_MISS_CHAR THEN
   x_complete_rec.auto_match_allowed_flag        := l_prtnr_prfls_rec.auto_match_allowed_flag;
END IF;

IF p_prtnr_prfls_rec.purchase_method          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.purchase_method        := l_prtnr_prfls_rec.purchase_method;
END IF;

IF p_prtnr_prfls_rec.cm_id          = FND_API.G_MISS_NUM  THEN
   x_complete_rec.cm_id        := l_prtnr_prfls_rec.cm_id;
END IF;

IF p_prtnr_prfls_rec.ph_support_rep          = FND_API.G_MISS_NUM  THEN
   x_complete_rec.ph_support_rep        := l_prtnr_prfls_rec.ph_support_rep;
END IF;
/*
IF p_prtnr_prfls_rec.security_group_id          = FND_API.G_MISS_NUM THEN
   x_complete_rec.security_group_id      := l_prtnr_prfls_rec.security_group_id;
END IF;
*/
IF p_prtnr_prfls_rec.object_version_number          = FND_API.G_MISS_NUM THEN
   x_complete_rec.object_version_number        := l_prtnr_prfls_rec.object_version_number;
END IF;

IF p_prtnr_prfls_rec.lead_sharing_status          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.lead_sharing_status        := l_prtnr_prfls_rec.lead_sharing_status;
END IF;

IF p_prtnr_prfls_rec.lead_share_appr_flag          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.lead_share_appr_flag        := l_prtnr_prfls_rec.lead_share_appr_flag;
END IF;

IF p_prtnr_prfls_rec.partner_relationship_id   = FND_API.G_MISS_NUM THEN
   x_complete_rec.partner_relationship_id    := l_prtnr_prfls_rec.partner_relationship_id;
END IF;

IF p_prtnr_prfls_rec.partner_level   = FND_API.G_MISS_CHAR THEN
   x_complete_rec.partner_level    := l_prtnr_prfls_rec.partner_level;
END IF;

IF p_prtnr_prfls_rec.preferred_vad_id   = FND_API.G_MISS_NUM THEN
   x_complete_rec.preferred_vad_id    := l_prtnr_prfls_rec.preferred_vad_id;
END IF;

IF p_prtnr_prfls_rec.partner_group_id   = FND_API.G_MISS_NUM THEN
   x_complete_rec.partner_group_id    := l_prtnr_prfls_rec.partner_group_id;
END IF;

IF p_prtnr_prfls_rec.partner_resource_id   = FND_API.G_MISS_NUM THEN
   x_complete_rec.partner_resource_id    := l_prtnr_prfls_rec.partner_resource_id;
END IF;

IF p_prtnr_prfls_rec.partner_group_number   = FND_API.G_MISS_CHAR THEN
   x_complete_rec.partner_group_number    := l_prtnr_prfls_rec.partner_group_number;
END IF;

IF p_prtnr_prfls_rec.partner_resource_number   = FND_API.G_MISS_CHAR THEN
   x_complete_rec.partner_resource_number    := l_prtnr_prfls_rec.partner_resource_number;
END IF;

IF p_prtnr_prfls_rec.sales_partner_flag        = FND_API.G_MISS_CHAR THEN
   x_complete_rec.sales_partner_flag        := l_prtnr_prfls_rec.sales_partner_flag;
END IF;

IF p_prtnr_prfls_rec.indirectly_managed_flag   = FND_API.G_MISS_CHAR THEN
   x_complete_rec.indirectly_managed_flag   := l_prtnr_prfls_rec.indirectly_managed_flag;
END IF;

IF p_prtnr_prfls_rec.channel_marketing_manager = FND_API.G_MISS_NUM  THEN
   x_complete_rec.channel_marketing_manager := l_prtnr_prfls_rec.channel_marketing_manager;
END IF;

IF p_prtnr_prfls_rec.related_partner_id        = FND_API.G_MISS_NUM  THEN
   x_complete_rec.related_partner_id          := l_prtnr_prfls_rec.related_partner_id;
END IF;

IF p_prtnr_prfls_rec.max_users                 = FND_API.G_MISS_NUM  THEN
   x_complete_rec.max_users                   := l_prtnr_prfls_rec.max_users;
END IF;

IF p_prtnr_prfls_rec.partner_party_id          = FND_API.G_MISS_NUM  THEN
   x_complete_rec.partner_party_id            := l_prtnr_prfls_rec.partner_party_id;
END IF;


END Complete_Prtnr_Prfls_Rec;


END PVX_PRTNR_PRFLS_PVT;

/
