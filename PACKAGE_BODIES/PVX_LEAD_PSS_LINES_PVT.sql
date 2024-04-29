--------------------------------------------------------
--  DDL for Package Body PVX_LEAD_PSS_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_LEAD_PSS_LINES_PVT" AS
/* $Header: pvxvpssb.pls 115.11 2002/12/11 10:58:54 anubhavk ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='PVX_lead_pss_lines_PVT';

---------------------------------------------------------------------
-- PROCEDURE
--    Create_lead_pss_line
--
-- PURPOSE
--    Create a new lead pss lines record
--
-- PARAMETERS
--    p_lead_pss_lines_rec: the new record to be inserted
--    x_lead_pss_line_id: return the lead_pss_line_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If lead_pss_line_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If lead_pss_line_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_lines_rec  IN  lead_pss_lines_rec_type
  ,x_lead_pss_line_id  OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_Lead_pss_line';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   l_lead_pss_lines_rec     lead_pss_lines_rec_type := p_lead_pss_lines_rec;

   l_object_version_number NUMBER := 1;

   l_uniqueness_check     VARCHAR2(10);


   -- Cursor to get the sequence for enty_attr_value
   CURSOR c_lead_pss_lines_seq IS
   SELECT PV_LEAD_PSS_LINES_S.NEXTVAL
     FROM DUAL;

   -- Cursor to validate the uniqueness
   CURSOR c_count(cv_lead_pss_line_id IN NUMBER) IS
   SELECT  'X'
     FROM  pv_lead_pss_lines
     WHERE  lead_pss_line_id  = cv_lead_pss_line_id;


BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_lead_pss_line;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
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





   Validate_lead_pss_line(
      p_api_version_number      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_lead_pss_lines_rec  => l_lead_pss_lines_rec
   );



   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


  -------------------------- insert --------------------------
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;



  IF l_lead_pss_lines_rec.lead_pss_line_id IS NULL THEN
    LOOP
      -- Get the identifier
      OPEN  c_lead_pss_lines_seq;
      FETCH c_lead_pss_lines_seq INTO l_lead_pss_lines_rec.lead_pss_line_id;
      CLOSE c_lead_pss_lines_seq;

      -- Check the uniqueness of the identifier
      OPEN  c_count(l_lead_pss_lines_rec.lead_pss_line_id);
      FETCH c_count INTO l_uniqueness_check;
        -- Exit when the identifier uniqueness is established
        EXIT WHEN c_count%ROWCOUNT = 0;
      CLOSE c_count;
   END LOOP;
  END IF;


  INSERT INTO PV_LEAD_PSS_LINES (
       lead_pss_line_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attr_code_id
      ,lead_id
      ,uom_code
      ,quantity
      ,amount
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,object_name
      ,object_version_number
      ,partner_id
      ,object_id
       )
    VALUES (
      l_lead_pss_lines_rec.lead_pss_line_id
      ,SYSDATE                                -- LAST_UPDATE_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- LAST_UPDATED_BY
      ,SYSDATE                                -- CREATION_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- CREATED_BY
      ,NVL(FND_GLOBAL.conc_login_id,-1)       -- LAST_UPDATE_LOGIN
     , l_lead_pss_lines_rec.request_id
      ,l_lead_pss_lines_rec.program_application_id
      ,l_lead_pss_lines_rec.program_id
      ,l_lead_pss_lines_rec.program_update_date
      ,l_lead_pss_lines_rec.attr_code_id
      ,l_lead_pss_lines_rec.lead_id
      ,l_lead_pss_lines_rec.uom_code
      ,l_lead_pss_lines_rec.quantity
      ,l_lead_pss_lines_rec.amount
      ,l_lead_pss_lines_rec.attribute_category
      ,l_lead_pss_lines_rec.attribute1
      ,l_lead_pss_lines_rec.attribute2
      ,l_lead_pss_lines_rec.attribute3
      ,l_lead_pss_lines_rec.attribute4
      ,l_lead_pss_lines_rec.attribute5
      ,l_lead_pss_lines_rec.attribute6
      ,l_lead_pss_lines_rec.attribute7
      ,l_lead_pss_lines_rec.attribute8
      ,l_lead_pss_lines_rec.attribute9
      ,l_lead_pss_lines_rec.attribute10
      ,l_lead_pss_lines_rec.attribute11
      ,l_lead_pss_lines_rec.attribute12
      ,l_lead_pss_lines_rec.attribute13
      ,l_lead_pss_lines_rec.attribute14
      ,l_lead_pss_lines_rec.attribute15
      ,l_lead_pss_lines_rec.object_name
      ,l_object_version_number                -- object_version_number
      ,l_lead_pss_lines_rec.partner_id
      ,l_lead_pss_lines_rec.object_id
      );

  ------------------------- finish -------------------------------
  x_lead_pss_line_id := l_lead_pss_lines_rec.lead_pss_line_id;

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
      ROLLBACK TO Create_lead_pss_line;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_lead_pss_line;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Create_lead_pss_line;
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

END Create_lead_pss_line;


---------------------------------------------------------------
-- PROCEDURE
--   Delete_lead_pss_line
--
---------------------------------------------------------------
PROCEDURE Delete_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_line_id    IN  NUMBER
  ,p_object_version      IN  NUMBER

)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_lead_pss_line';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_lead_pss_line;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;



   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
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


   DELETE FROM PV_LEAD_PSS_LINES
     WHERE lead_pss_line_id  = p_lead_pss_line_id
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
      ROLLBACK TO Delete_lead_pss_line;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_lead_pss_line;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_lead_pss_line;
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

END Delete_lead_pss_line;


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_lead_pss_line
--
--------------------------------------------------------------------
PROCEDURE Lock_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_line_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_lead_pss_line';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_lead_pss_line_id      NUMBER;

   CURSOR c_lead_pss_line IS
   SELECT  lead_pss_line_id
     FROM  pv_lead_pss_lines
     WHERE lead_pss_line_id  = p_lead_pss_line_id
     AND   object_version_number = p_object_version
   FOR UPDATE OF lead_pss_line_id  NOWAIT;

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
         p_api_version_number,
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


   OPEN  c_lead_pss_line;
   FETCH c_lead_pss_line INTO l_lead_pss_line_id;
   IF (c_lead_pss_line%NOTFOUND) THEN
      CLOSE c_lead_pss_line;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lead_pss_line;


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

END Lock_lead_pss_line;


---------------------------------------------------------------------
-- PROCEDURE
-- Update_lead_pss_line
----------------------------------------------------------------------
PROCEDURE Update_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_lead_pss_lines_rec     IN  lead_pss_lines_rec_type

)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_lead_pss_line';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_lead_pss_lines_rec  lead_pss_lines_rec_type;
   l_return_status   VARCHAR2(1);
   l_mode            VARCHAR2(30) := 'UPDATE';


BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_lead_pss_line;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
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
      Check_lead_pss_line_Items(
  	 p_lead_pss_lines_rec  => p_lead_pss_lines_rec,
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
   Complete_lead_pss_line_rec(p_lead_pss_lines_rec, l_lead_pss_lines_rec);



   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

      Check_lead_pss_line_Record(
  	 p_lead_pss_lines_rec => p_lead_pss_lines_rec,
         p_complete_rec    => l_lead_pss_lines_rec,
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



   UPDATE PV_LEAD_PSS_LINES  SET
      last_update_date           = SYSDATE
     ,last_updated_by            = NVL(FND_GLOBAL.user_id,-1)
     ,last_update_login          = NVL(FND_GLOBAL.conc_login_id,-1)
     ,request_id                 =  l_lead_pss_lines_rec.request_id
     ,program_application_id     =  l_lead_pss_lines_rec.program_application_id
     ,program_id                 =  l_lead_pss_lines_rec.program_id
     ,program_update_date        =  l_lead_pss_lines_rec.program_update_date
     ,attr_code_id               =  l_lead_pss_lines_rec.attr_code_id
     ,lead_id                    =  l_lead_pss_lines_rec.lead_id
     ,uom_code                   =  l_lead_pss_lines_rec.uom_code
     ,quantity                   =  l_lead_pss_lines_rec.quantity
     ,amount                     =  l_lead_pss_lines_rec.amount
     ,attribute_category         = l_lead_pss_lines_rec.attribute_category
     ,attrIbute1                 = l_lead_pss_lines_rec.attribute1
     ,attribute2                 = l_lead_pss_lines_rec.attribute2
     ,attribute3                 = l_lead_pss_lines_rec.attribute3
     ,attribute4                 = l_lead_pss_lines_rec.attribute4
     ,attribute5                 = l_lead_pss_lines_rec.attribute5
     ,attribute6                 = l_lead_pss_lines_rec.attribute6
     ,attribute7                 = l_lead_pss_lines_rec.attribute7
     ,attribute8                 = l_lead_pss_lines_rec.attribute8
     ,attribute9                 = l_lead_pss_lines_rec.attribute9
     ,attribute10                = l_lead_pss_lines_rec.attribute10
     ,attribute11                = l_lead_pss_lines_rec.attribute11
     ,attribute12                = l_lead_pss_lines_rec.attribute12
     ,attribute13                = l_lead_pss_lines_rec.attribute13
     ,attribute14                = l_lead_pss_lines_rec.attribute14
     ,attribute15                = l_lead_pss_lines_rec.attribute15
     ,object_name                = l_lead_pss_lines_rec.object_name
     ,object_version_number      = l_lead_pss_lines_rec.object_version_number + 1
     ,partner_id                 = l_lead_pss_lines_rec.partner_id
     ,object_id                  = l_lead_pss_lines_rec.object_id
   WHERE lead_pss_line_id = l_lead_pss_lines_rec.lead_pss_line_id
   AND   object_version_number = l_lead_pss_lines_rec.object_version_number;


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
      ROLLBACK TO Update_lead_pss_line;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_lead_pss_line;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_lead_pss_line;
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

END Update_lead_pss_line;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_lead_pss_line
--
--------------------------------------------------------------------
PROCEDURE Validate_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_lines_rec   IN  lead_pss_lines_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_lead_pss_line';
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
         p_api_version_number,
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




   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Lead_pss_line_Items(
         p_lead_pss_lines_rec => p_lead_pss_lines_rec,
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




   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_lead_pss_line_Record(
         p_lead_pss_lines_rec => p_lead_pss_lines_rec,
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

END Validate_lead_pss_line;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Req_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Req_Items(
   p_lead_pss_lines_rec   IN  lead_pss_lines_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ------------------------ entity --------------------------
   IF p_lead_pss_lines_rec.object_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_OBJECT_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ attribute id -------------------------------
   ELSIF p_lead_pss_lines_rec.attr_code_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_ATTR_CODE_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ Object_name -------------------------------
  ELSIF p_lead_pss_lines_rec.object_name IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_NO_OBJECT_NAME');
       FND_MSG_PUB.add;
    END IF;

    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
 END IF;

END Check_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Uk_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Uk_Items(
   p_lead_pss_lines_rec IN  lead_pss_lines_rec_type
  ,p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- when lead_pss_line_id is passed in, we need to
   -- check if this is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_lead_pss_lines_rec.lead_pss_line_id IS NOT NULL
   THEN
      IF PVX_Utility_PVT.check_uniqueness(
		    'PV_lead_pss_lines',
		    'lead_pss_line_id = ' || p_lead_pss_lines_rec.lead_pss_line_id
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
            FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_ID');
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
   p_lead_pss_lines_rec IN  lead_pss_lines_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- lead_id ------------------------
   IF (p_lead_pss_lines_rec.lead_id <> FND_API.g_miss_num and p_lead_pss_lines_rec.object_name = 'OPPORTUNITY') THEN
      IF PVX_Utility_PVT.check_fk_exists(
            'as_leads_all',    -- Parent schema object having the primary key
            'lead_id',     -- Column name in the parent object that maps to the fk value
            p_lead_pss_lines_rec.object_id,       -- Value of fk to be validated against the parent object's pk column
           PVX_utility_PVT.g_number              -- datatype of fk
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_LEAD_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   else IF (p_lead_pss_lines_rec.lead_id <> FND_API.g_miss_num and p_lead_pss_lines_rec.object_name = 'LEAD') then

      IF PVX_Utility_PVT.check_fk_exists(
            'as_sales_leads',    -- Parent schema object having the primary key
            'sales_lead_id',     -- Column name in the parent object that maps to the fk value
            p_lead_pss_lines_rec.object_id,       -- Value of fk to be validated against the parent object's pk column
           PVX_utility_PVT.g_number              -- datatype of fk
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_SALES_LEAD_ID');
            FND_MSG_PUB.add;
         END IF;
          x_return_status := FND_API.g_ret_sts_error;
         RETURN;

   END IF;
  END IF;
END IF;

   ----------------------- attr_code_id ------------------------
   IF p_lead_pss_lines_rec.attr_code_id <> FND_API.g_miss_num  THEN
      IF PVX_Utility_PVT.check_fk_exists(
            'pv_attribute_codes_vl',    -- Parent schema object having the primary key
            'attr_code_id',     -- Column name in the parent object that maps to the fk value
            p_lead_pss_lines_rec.attr_code_id,       -- Value of fk to be validated against the parent object's pk column
           PVX_utility_PVT.g_number              -- datatype of fk
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_ATTRIBUTE_CODE_ID');
            FND_MSG_PUB.add;
         END IF;
       x_return_status := FND_API.g_ret_sts_error;
         RETURN;

   end if;
end if;

END Check_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Lookup_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Lookup_Items(
   p_lead_pss_lines_rec IN  lead_pss_lines_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN


 x_return_status := FND_API.g_ret_sts_success;



   ----------------------- object_name lookup  ------------------------
   IF p_lead_pss_lines_rec.object_name <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'pv_lookups',      -- Look up Table Name
            'PV_OBJECT_NAME',    -- Lookup Type
            p_lead_pss_lines_rec.object_name       -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_OBJECT_NAME_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

   end if;
end if;

   -- check other lookup codes

END Check_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Flag_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Flag_Items(
   p_lead_pss_lines_rec IN  lead_pss_lines_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


END Check_Flag_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_lead_pss_line_items
--
---------------------------------------------------------------------
PROCEDURE Check_lead_pss_line_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_lead_pss_lines_rec IN lead_pss_lines_rec_type
)
IS
BEGIN

   Check_Req_Items(
      p_lead_pss_lines_rec => p_lead_pss_lines_rec
     ,x_return_status   => x_return_status
   );


   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



   Check_Uk_Items(
      p_lead_pss_lines_rec => p_lead_pss_lines_rec
     ,p_validation_mode => p_validation_mode
     ,x_return_status   => x_return_status
   );




   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



   Check_Fk_Items(
      p_lead_pss_lines_rec => p_lead_pss_lines_rec
     ,x_return_status   => x_return_status
   );



   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



   Check_Lookup_Items(
      p_lead_pss_lines_rec => p_lead_pss_lines_rec
     ,x_return_status   => x_return_status
   );




   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;




   Check_Flag_Items(
      p_lead_pss_lines_rec => p_lead_pss_lines_rec
     ,x_return_status   => x_return_status
   );




   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_lead_pss_line_Items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_lead_pss_line_Record
--
---------------------------------------------------------------------
PROCEDURE Check_lead_pss_line_Record(
   p_lead_pss_lines_rec IN lead_pss_lines_rec_type
  ,p_complete_rec     IN  lead_pss_lines_rec_type := NULL
  ,p_mode             IN  VARCHAR2 := 'INSERT'
  ,x_return_status    OUT NOCOPY VARCHAR2
)
IS


BEGIN

   x_return_status := FND_API.g_ret_sts_success;



   -- do other record level checkings

END Check_lead_pss_line_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_lead_pss_line_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_lead_pss_line_Rec(
   x_lead_pss_lines_rec    OUT NOCOPY lead_pss_lines_rec_type
)
IS
BEGIN

x_lead_pss_lines_rec.lead_pss_line_id           := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.last_update_date           := FND_API.G_MISS_DATE;
x_lead_pss_lines_rec.last_updated_by            := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.creation_date              := FND_API.G_MISS_DATE;
x_lead_pss_lines_rec.created_by	                := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.last_update_login          := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.object_version_number      := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.request_id                 := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.program_application_id     := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.program_id                 := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.program_update_date        := FND_API.G_MISS_DATE;
x_lead_pss_lines_rec.attr_code_id               := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.lead_id                    := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.uom_code                   := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.quantity                   := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.amount                     := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.attribute_category         := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute1                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute2                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute3                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute4                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute5                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute6                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute7                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute8                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute9                 := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute10                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute11                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute12                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute13                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute14                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.attribute15                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.object_name                := FND_API.G_MISS_CHAR;
x_lead_pss_lines_rec.object_id                  := FND_API.G_MISS_NUM;
x_lead_pss_lines_rec.partner_id                 := FND_API.G_MISS_NUM;
END Init_lead_pss_line_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_lead_pss_line_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_lead_pss_line_Rec(
   p_lead_pss_lines_rec   IN  lead_pss_lines_rec_type
  ,x_complete_rec        OUT NOCOPY  lead_pss_lines_rec_type
)
IS

   CURSOR c_lead_pss_line IS
   SELECT *
     FROM  PV_lead_pss_lines
     WHERE lead_pss_line_id = p_lead_pss_lines_rec.lead_pss_line_id;

   l_lead_pss_lines_rec   c_Lead_pss_line%ROWTYPE;

BEGIN

   x_complete_rec := p_lead_pss_lines_rec;

   OPEN c_lead_pss_line;
   FETCH c_lead_pss_line INTO l_lead_pss_lines_rec;
   IF c_lead_pss_line%NOTFOUND THEN
      CLOSE c_lead_pss_line;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lead_pss_line;

IF p_lead_pss_lines_rec.uom_code          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.uom_code        := l_lead_pss_lines_rec.uom_code;
END IF;

IF p_lead_pss_lines_rec.lead_id          = FND_API.G_MISS_NUM THEN
   x_complete_rec.lead_id        := l_lead_pss_lines_rec.lead_id;
END IF;

IF p_lead_pss_lines_rec.amount         = FND_API.G_MISS_NUM  THEN
   x_complete_rec.amount        := l_lead_pss_lines_rec.amount;
END IF;

IF p_lead_pss_lines_rec.object_name          = FND_API.G_MISS_CHAR THEN
   x_complete_rec.object_name        := l_lead_pss_lines_rec.object_name;
END IF;

IF p_lead_pss_lines_rec.attr_code_id          = FND_API.G_MISS_NUM THEN
   x_complete_rec.attr_code_id        := l_lead_pss_lines_rec.attr_code_id;
END IF;

IF p_lead_pss_lines_rec.quantity          = FND_API.G_MISS_NUM THEN
   x_complete_rec.quantity        := l_lead_pss_lines_rec.quantity;
END IF;
IF p_lead_pss_lines_rec.object_version_number          = FND_API.G_MISS_NUM THEN
   x_complete_rec.object_version_number        := l_lead_pss_lines_rec.object_version_number;
END IF;
IF p_lead_pss_lines_rec.attribute_category               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute_category                     := l_lead_pss_lines_rec.attribute_category;
END IF;

IF p_lead_pss_lines_rec.attribute1               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute1                     := l_lead_pss_lines_rec.attribute1;
END IF;

IF p_lead_pss_lines_rec.attribute2               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute2                     := l_lead_pss_lines_rec.attribute2;
END IF;

IF p_lead_pss_lines_rec.attribute3               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute3                     := l_lead_pss_lines_rec.attribute3;
END IF;

IF p_lead_pss_lines_rec.attribute4               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute4                     := l_lead_pss_lines_rec.attribute4;
END IF;

IF p_lead_pss_lines_rec.attribute5               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute5                     := l_lead_pss_lines_rec.attribute5;
END IF;

IF p_lead_pss_lines_rec.attribute6               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute6                     := l_lead_pss_lines_rec.attribute6;
END IF;

IF p_lead_pss_lines_rec.attribute7               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute7                     := l_lead_pss_lines_rec.attribute7;
END IF;

IF p_lead_pss_lines_rec.attribute8               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute8                     := l_lead_pss_lines_rec.attribute8;
END IF;

IF p_lead_pss_lines_rec.attribute9               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute9                     := l_lead_pss_lines_rec.attribute9;
END IF;

IF p_lead_pss_lines_rec.attribute10               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute10                     := l_lead_pss_lines_rec.attribute10;
END IF;

IF p_lead_pss_lines_rec.attribute11               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute11                     := l_lead_pss_lines_rec.attribute11;
END IF;

IF p_lead_pss_lines_rec.attribute12               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute12                     := l_lead_pss_lines_rec.attribute12;
END IF;

IF p_lead_pss_lines_rec.attribute13               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute13                     := l_lead_pss_lines_rec.attribute13;
END IF;

IF p_lead_pss_lines_rec.attribute14               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute14                     := l_lead_pss_lines_rec.attribute14;
END IF;

IF p_lead_pss_lines_rec.attribute15               = FND_API.G_MISS_CHAR THEN
   x_complete_rec.attribute15                     := l_lead_pss_lines_rec.attribute15;
END IF;

IF p_lead_pss_lines_rec.request_id               = FND_API.G_MISS_NUM THEN
   x_complete_rec.request_id                     := l_lead_pss_lines_rec.request_id;
END IF;

IF p_lead_pss_lines_rec.program_id              = FND_API.G_MISS_NUM THEN
   x_complete_rec.program_id                     := l_lead_pss_lines_rec.program_id;
END IF;

IF p_lead_pss_lines_rec.program_application_id               = FND_API.G_MISS_NUM THEN
   x_complete_rec.program_application_id                     := l_lead_pss_lines_rec.program_application_id;
END IF;

IF p_lead_pss_lines_rec.program_update_date               = FND_API.G_MISS_DATE THEN
   x_complete_rec.program_update_date                     := l_lead_pss_lines_rec.program_update_date;
END IF;

IF p_lead_pss_lines_rec.partner_id                         = FND_API.G_MISS_NUM THEN
   x_complete_rec.partner_id                     := l_lead_pss_lines_rec.partner_id;
END IF;

IF p_lead_pss_lines_rec.object_id               = FND_API.G_MISS_NUM THEN
   x_complete_rec.object_id                     := l_lead_pss_lines_rec.object_id;
END IF;

end complete_lead_pss_line_rec;

END PVX_lead_pss_lines_PVT;

/
