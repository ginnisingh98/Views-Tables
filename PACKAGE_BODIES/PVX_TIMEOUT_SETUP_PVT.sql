--------------------------------------------------------
--  DDL for Package Body PVX_TIMEOUT_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_TIMEOUT_SETUP_PVT" AS
/* $Header: pvxvtmob.pls 115.14 2002/12/11 11:12:53 anubhavk ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='PVX_timeout_setup_PVT';

---------------------------------------------------------------------
-- PROCEDURE
--    Create_timeout_setup
--
-- PURPOSE
--    Create a new timeout entry record
--
-- PARAMETERS
--    p_timeout_setup_rec: the new record to be inserted
--    x_timeout_setup_id: return the timeout_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If timeout_id is not passed in, generate a unique one from
--       the sequence.
--    3. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_timeout_setup_rec IN  timeout_setup_rec_type
  ,x_timeout_setup_id  OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_timeout_setup';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   l_timeout_setup_rec     timeout_setup_rec_type := p_timeout_setup_rec;

   l_object_version_number NUMBER := 1;

   l_uniqueness_check     VARCHAR2(10);

   -- Cursor to get the sequence for enty_attr_value
   CURSOR c_timout_setup_seq IS
   SELECT PV_COUNTRY_TIMEOUTS_S.NEXTVAL
     FROM DUAL;

   -- Cursor to validate the uniqueness
   CURSOR c_count(cv_timeout_setup_id IN NUMBER) IS
   SELECT  'ANYTHING'
     FROM  PV_COUNTRY_TIMEOUTS
     WHERE timeout_id = cv_timeout_setup_id;


BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_timeout_setup;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;



   --DBMS_output.put_line(l_full_name||': start');

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



   --DBMS_output.put_line(l_full_name||': validate');
   Validate_timeout_setup(
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_timeout_setup_rec  => l_timeout_setup_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   --DBMS_output.put_line(l_full_name||': back validate');

   -------------------------- insert --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;



  IF l_timeout_setup_rec.timeout_id IS NULL THEN
    LOOP
      -- Get the identifier
      OPEN  c_timout_setup_seq;
      FETCH c_timout_setup_seq INTO l_timeout_setup_rec.timeout_id;
      CLOSE c_timout_setup_seq;

      -- Check the uniqueness of the identifier
      OPEN  c_count(l_timeout_setup_rec.timeout_id);
      FETCH c_count INTO l_uniqueness_check;
        -- Exit when the identifier uniqueness is established
        EXIT WHEN c_count%ROWCOUNT = 0;
      CLOSE c_count;
   END LOOP;
  END IF;


   --DBMS_output.put_line(l_full_name||': start insert');
  INSERT INTO PV_COUNTRY_TIMEOUTS (
       timeout_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,timeout_period
      ,timeout_type
      ,country_code
      ,object_version_number
       )
    VALUES (
      l_timeout_setup_rec.timeout_id
      ,SYSDATE                                -- LAST_UPDATE_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- LAST_UPDATED_BY
      ,SYSDATE                                -- CREATION_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- CREATED_BY
      ,NVL(FND_GLOBAL.conc_login_id,-1)       -- LAST_UPDATE_LOGIN
      ,l_timeout_setup_rec.timeout_period
      ,l_timeout_setup_rec.timeout_type
      ,l_timeout_setup_rec.country_code
      ,l_object_version_number                -- object_version_number
      );


  ------------------------- finish -------------------------------
  x_timeout_setup_id := l_timeout_setup_rec.timeout_id;

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
      ROLLBACK TO Create_timeout_setup;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_timeout_setup;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN OTHERS THEN
      ROLLBACK TO Create_timeout_setup;
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

END Create_timeout_setup;


---------------------------------------------------------------
-- PROCEDURE
--   Delete_timeout_setup
--
---------------------------------------------------------------
PROCEDURE Delete_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_timeout_id        IN  NUMBER
  ,p_object_version    IN  NUMBER

)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_timeout_setup';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_timeout_setup;

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



   DELETE FROM PV_country_timeouts
   WHERE timeout_id = p_timeout_id
   AND   object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
		THEN
         FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
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
      ROLLBACK TO Delete_timeout_setup;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_timeout_setup;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_timeout_setup;
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

END Delete_timeout_setup;


---------------------------------------------------------------------
-- PROCEDURE
-- Update_timeout_setup
----------------------------------------------------------------------
PROCEDURE Update_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_timeout_setup_rec IN  timeout_setup_rec_type
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_timeout_setup';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_timeout_setup_rec   timeout_setup_rec_type;
   l_return_status   VARCHAR2(1);
   l_mode            VARCHAR2(30) := 'UPDATE';


BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_timeout_setup;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;



   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

--   dbms_output.put_line('Start 2' || to_char(l_api_version) || 'p_api ; ' ||  p_api_version || 'l_api " ' || p_api_version || 'pkg :' ||  g_pkg_name);

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
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_timeout_items(
  	     p_timeout_setup_rec => p_timeout_setup_rec,
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
   Complete_timeout_rec(p_timeout_setup_rec, l_timeout_setup_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_timeout_rec(
  	     p_timeout_setup_rec => p_timeout_setup_rec,
         p_complete_rec    => l_timeout_setup_rec,
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


   UPDATE PV_COUNTRY_TIMEOUTS
   SET
       last_update_date           = SYSDATE
      ,last_updated_by            = NVL(FND_GLOBAL.user_id,-1)
      ,last_update_login          = NVL(FND_GLOBAL.conc_login_id,-1)
      ,timeout_period             = l_timeout_setup_rec.timeout_period
      ,timeout_type               = l_timeout_setup_rec.timeout_type
      ,country_code               = l_timeout_setup_rec.country_code
      ,object_version_number      = l_timeout_setup_rec.object_version_number + 1
   WHERE timeout_id = l_timeout_setup_rec.timeout_id
   AND   object_version_number = l_timeout_setup_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
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
      ROLLBACK TO Update_timeout_setup;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_timeout_setup;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_timeout_setup;
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

END Update_timeout_setup;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_timeout_rec
--
---------------------------------------------------------------------
PROCEDURE Check_timeout_rec(
   p_timeout_setup_rec IN timeout_setup_rec_type
  ,p_complete_rec      IN  timeout_setup_rec_type := NULL
  ,p_mode              IN  VARCHAR2 := 'INSERT'
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
    BEGIN
        x_return_status := FND_API.g_ret_sts_success;
   -- do other record level checkings

END Check_timeout_rec;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_timeout_setup
--
--------------------------------------------------------------------
PROCEDURE Validate_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_timeout_setup_rec IN  timeout_setup_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_enty_attr_value';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

   l_uniqueness_check     VARCHAR2(10);
   -- check for uniqueness
   CURSOR c_unique_timeout IS
   SELECT  'ANYTHING'
   FROM  PV_COUNTRY_TIMEOUTS
   WHERE country_code = p_timeout_setup_rec.country_code
   AND   timeout_type = p_timeout_setup_rec.timeout_type;


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


   --DBMS_output.put_line(l_full_name||': start item validate');
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_timeout_items(
         p_timeout_setup_rec => p_timeout_setup_rec,
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



   --DBMS_output.put_line(l_full_name||': start record validate');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_timeout_rec(
         p_timeout_setup_rec => p_timeout_setup_rec,
         p_complete_rec      => NULL,
         x_return_status     => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   --------------- check for unique row -----------------

   -- Cursor to validate the uniqueness
   OPEN c_unique_timeout;
   FETCH c_unique_timeout INTO l_uniqueness_check;
   -- RAISE EXCEPTION when the identifier uniqueness is established
   IF (c_unique_timeout%ROWCOUNT = 0) THEN
    return;
   ELSE
    FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_RECORD');
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_unexpected_error;
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

END Validate_timeout_setup;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Req_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Req_Items(
   p_timeout_setup_rec   IN  timeout_setup_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ entity --------------------------
   IF p_timeout_setup_rec.timeout_period IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_ENTITY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Req_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_timeout_items
--
---------------------------------------------------------------------
PROCEDURE Check_timeout_items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_timeout_setup_rec IN timeout_setup_rec_type
)
IS
BEGIN

   --DBMS_output.put_line(': start req items validate');
   Check_Req_Items(
      p_timeout_setup_rec => p_timeout_setup_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_timeout_items;

---------------------------------------------------------------------
-- PROCEDURE
--    Init_attr_value_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_timeout_Rec(
   x_timeout_setup_rec    OUT NOCOPY timeout_setup_rec_type
)
IS
BEGIN

x_timeout_setup_rec.timeout_id           := FND_API.G_MISS_NUM;
x_timeout_setup_rec.last_update_date           := FND_API.G_MISS_DATE;
x_timeout_setup_rec.last_updated_by            := FND_API.G_MISS_NUM;
x_timeout_setup_rec.creation_date              := FND_API.G_MISS_DATE;
x_timeout_setup_rec.created_by	               := FND_API.G_MISS_NUM;
x_timeout_setup_rec.last_update_login          := FND_API.G_MISS_NUM;
x_timeout_setup_rec.object_version_number      := FND_API.G_MISS_NUM;
x_timeout_setup_rec.timeout_period             := FND_API.G_MISS_NUM;
x_timeout_setup_rec.timeout_type               := FND_API.G_MISS_CHAR;
x_timeout_setup_rec.country_code               := FND_API.G_MISS_CHAR;

END Init_timeout_Rec;

-------------------------------------------------------------------
-- PROCEDURE
--    Lock_timeout_setup
--
--------------------------------------------------------------------
PROCEDURE Lock_timeout_setup(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,p_timeout_id        IN  NUMBER
   ,p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_timeout_setup';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_timeout_id      NUMBER;

   CURSOR c_timeout_setup IS
   SELECT  timeout_id
     FROM  PV_COUNTRY_TIMEOUTS
     WHERE timeout_id = p_timeout_id
     AND   object_version_number = p_object_version
   FOR UPDATE OF timeout_id NOWAIT;

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


   OPEN  c_timeout_setup;
   FETCH c_timeout_setup INTO l_timeout_id;
   IF (c_timeout_setup%NOTFOUND) THEN
      CLOSE c_timeout_setup;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_timeout_setup;


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

END Lock_timeout_setup;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_timeout_setup_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_timeout_Rec(
   p_timeout_setup_rec   IN  timeout_setup_rec_type
  ,x_complete_rec        OUT NOCOPY timeout_setup_rec_type
)
IS

   CURSOR c_timeout_setup IS
   SELECT *
     FROM  PV_COUNTRY_TIMEOUTS
     WHERE timeout_id = p_timeout_setup_rec.timeout_id;

   l_timeout_setup_rec   c_timeout_setup%ROWTYPE;

BEGIN

   x_complete_rec := p_timeout_setup_rec;

   OPEN c_timeout_setup;
   FETCH c_timeout_setup INTO l_timeout_setup_rec;
   IF c_timeout_setup%NOTFOUND THEN
      CLOSE c_timeout_setup;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_timeout_setup;

   --dbms_output.put_line('Start 2' || to_char(p_timeout_setup_rec.timeout_period) || 'TYPE ; ' ||  p_timeout_setup_rec.timeout_type || 'CNTRY " ' || p_timeout_setup_rec.country_code || 'pkg :' ));


IF p_timeout_setup_rec.timeout_period   = FND_API.G_MISS_NUM THEN
   x_complete_rec.timeout_period       := l_timeout_setup_rec.timeout_period;
END IF;

IF p_timeout_setup_rec.timeout_type    = FND_API.G_MISS_CHAR THEN
   x_complete_rec.timeout_type        := l_timeout_setup_rec.timeout_type;
END IF;

IF p_timeout_setup_rec.country_code     = FND_API.G_MISS_CHAR  THEN
   x_complete_rec.country_code         := l_timeout_setup_rec.country_code;
END IF;


IF p_timeout_setup_rec.object_version_number          = FND_API.G_MISS_NUM THEN
   x_complete_rec.object_version_number        := l_timeout_setup_rec.object_version_number;
END IF;

END Complete_timeout_Rec;

END PVX_timeout_setup_PVT;


/
