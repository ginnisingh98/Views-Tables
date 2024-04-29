--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_OWNER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_OWNER" AS
/* $Header: asxvslnb.pls 115.7 2003/11/15 00:49:50 solin ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AS_SALES_LEAD_OWNER';

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Uk_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Uk_Items(
   p_Lead_Owner_rec IN  Lead_Owner_rec_type
  ,p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


END Check_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fk_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Fk_Items(
   p_Lead_Owner_rec IN  Lead_Owner_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS

  l_cm_exsits    VARCHAR2(10);

  -- Cursor to validate the uniqueness
   CURSOR c_cm_exsist(cv_cm_resource_id IN NUMBER) IS
   SELECT  'ANYTHING'
     FROM  jtf_rs_resource_extns
     WHERE resource_id = cv_cm_resource_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- attribute_id ------------------------
   IF p_Lead_Owner_rec.CM_resource_id <> FND_API.g_miss_num THEN

      -- Check the uniqueness of the identifier
      OPEN  c_cm_exsist(p_Lead_Owner_rec.CM_RESOURCE_ID);
      FETCH c_cm_exsist INTO l_cm_exsits;
        -- Exit when the identifier uniqueness is established
        IF c_cm_exsist%ROWCOUNT = 0 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('PV', 'PV_BAD_CMM_RESOURCE_ID');
                FND_MESSAGE.SET_TOKEN('ID', to_char(p_Lead_Owner_rec.CM_resource_id) );
                FND_MSG_PUB.add;
            END IF;
            CLOSE c_cm_exsist;

/*
       IF AS_Utility_PVT.check_fk_exists(
            'jtf_rs_resource_extns',    -- Parent schema object having the primary key
            'resource_id',     -- Column name in the parent object that maps to the fk value
             p_Lead_Owner_rec.CM_resource_id,       -- Value of fk to be validated against the parent object's pk column
           AS_Utility_PVT.g_number              -- datatype of fk
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_BAD_CMM_RESOURCE_ID');
            FND_MESSAGE.SET_TOKEN('ID', to_char(p_Lead_Owner_rec.CM_resource_id) );
            FND_MSG_PUB.add;
         END IF;
*/
             x_return_status := FND_API.g_ret_sts_error;
               RETURN;
        END IF;
    END IF;

   -- check other fk items

END Check_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Req_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Req_Items(
   p_Lead_Owner_rec   IN  Lead_Owner_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

/*
   ------------------------ entity --------------------------
   IF p_Lead_Owner_rec.entity IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_ENTITY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ attribute id -------------------------------
   ELSIF p_Lead_Owner_rec.attribute_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_ATTR_ID');
         FND_MESSAGE.SET_TOKEN('ID',to_char(p_Lead_Owner_rec.attribute_id) );
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;*/

END Check_Req_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Lookup_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Lookup_Items(
   p_Lead_Owner_rec IN  Lead_Owner_rec_type
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
   p_Lead_Owner_rec IN  Lead_Owner_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


END Check_Flag_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Lead_Owner_items
--
---------------------------------------------------------------------
PROCEDURE Check_Lead_Owner_items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_Lead_Owner_rec   IN  Lead_Owner_rec_type
)
IS
BEGIN

   --DBMS_output.put_line(': start req items validate');
   Check_Req_Items(
      p_Lead_Owner_rec   => p_Lead_Owner_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --DBMS_output.put_line(': start uk record validate');
   Check_Uk_Items(
      p_Lead_Owner_rec   => p_Lead_Owner_rec
     ,p_validation_mode => p_validation_mode
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --DBMS_output.put_line(': start fk record validate');
   Check_Fk_Items(
      p_Lead_Owner_rec   => p_Lead_Owner_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --DBMS_output.put_line(': start lookup record validate');
   Check_Lookup_Items(
      p_Lead_Owner_rec   => p_Lead_Owner_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --DBMS_output.put_line(': start flag record validate');
   Check_Flag_Items(
      p_Lead_Owner_rec   => p_Lead_Owner_rec
     ,x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Lead_Owner_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Lead_Owner_rec
--
---------------------------------------------------------------------
PROCEDURE Check_Lead_Owner_rec(
   p_Lead_Owner_rec    IN  Lead_Owner_rec_type
  ,p_complete_rec     IN  Lead_Owner_rec_type := NULL
  ,p_mode             IN  VARCHAR2 := 'INSERT'
  ,x_return_status    OUT NOCOPY VARCHAR2
)
IS


BEGIN

   x_return_status := FND_API.g_ret_sts_success;



   -- do other record level checkings

END Check_Lead_Owner_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Lead_Owner_Rec
--
---------------------------------------------------------------------
PROCEDURE Init_Lead_Owner_Rec(
   x_Lead_Owner_rec    OUT NOCOPY Lead_Owner_rec_type
)
IS
BEGIN

x_Lead_Owner_rec.Lead_Owner_id               := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.country	                   := FND_API.G_MISS_CHAR;
x_Lead_Owner_rec.from_postal_code	   := FND_API.G_MISS_CHAR;
x_Lead_Owner_rec.to_postal_code		   := FND_API.G_MISS_CHAR;
x_Lead_Owner_rec.CM_resource_id		   := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.last_update_date           := FND_API.G_MISS_DATE;
x_Lead_Owner_rec.last_updated_by            := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.creation_date              := FND_API.G_MISS_DATE;
x_Lead_Owner_rec.created_by                 := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.last_update_login          := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.object_version_number      := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.request_id                 := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.program_application_id     := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.program_id                 := FND_API.G_MISS_NUM;
x_Lead_Owner_rec.program_update_date        := FND_API.G_MISS_DATE;

END Init_Lead_Owner_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Lead_Owner_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_Lead_Owner_Rec(
   p_Lead_Owner_rec   IN  Lead_Owner_rec_type
  ,x_complete_rec    OUT NOCOPY Lead_Owner_rec_type
)
IS

   CURSOR c_Lead_Owner IS
   SELECT *
     FROM  AS_SALES_LEAD_OWNERS
     WHERE Lead_Owner_id = p_Lead_Owner_rec.Lead_Owner_id;

   l_Lead_Owner_rec   c_Lead_Owner%ROWTYPE;

BEGIN

   x_complete_rec := p_Lead_Owner_rec;

   OPEN c_Lead_Owner;
   FETCH c_Lead_Owner INTO l_Lead_Owner_rec;
   IF c_Lead_Owner%NOTFOUND THEN
      CLOSE c_Lead_Owner;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_Lead_Owner;

IF p_Lead_Owner_rec.request_id             = FND_API.G_MISS_NUM THEN
   x_complete_rec.request_id             := l_Lead_Owner_rec.request_id;
END IF;

IF p_Lead_Owner_rec.program_application_id = FND_API.G_MISS_NUM THEN
   x_complete_rec.program_application_id := l_Lead_Owner_rec.program_application_id;
END IF;

IF p_Lead_Owner_rec.program_id             = FND_API.G_MISS_NUM  THEN
   x_complete_rec.program_id             := l_Lead_Owner_rec.program_id;
END IF;

IF p_Lead_Owner_rec.program_update_date    = FND_API.G_MISS_DATE THEN
   x_complete_rec.program_update_date    := l_Lead_Owner_rec.program_update_date;
END IF;

IF p_Lead_Owner_rec.country            	  = FND_API.G_MISS_CHAR THEN
   x_complete_rec.country        	 := l_Lead_Owner_rec.country;
END IF;

IF p_Lead_Owner_rec.from_postal_code       = FND_API.G_MISS_CHAR THEN
   x_complete_rec.from_postal_code       := l_Lead_Owner_rec.from_postal_code;
END IF;

IF p_Lead_Owner_rec.referral_type         = FND_API.G_MISS_CHAR THEN
   x_complete_rec.referral_type         := l_Lead_Owner_rec.referral_type;
END IF;

IF p_Lead_Owner_rec.owner_flag       = FND_API.G_MISS_CHAR THEN
   x_complete_rec.owner_flag       := l_Lead_Owner_rec.owner_flag;
END IF;

IF p_Lead_Owner_rec.to_postal_code         = FND_API.G_MISS_CHAR THEN
   x_complete_rec.to_postal_code         := l_Lead_Owner_rec.to_postal_code;
END IF;

IF p_Lead_Owner_rec.object_version_number = FND_API.G_MISS_NUM THEN
   x_complete_rec.object_version_number := l_Lead_Owner_rec.object_version_number;
END IF;


END Complete_Lead_Owner_Rec;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Lead_Owner
--
--------------------------------------------------------------------
PROCEDURE Validate_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_Lead_Owner_rec   IN  Lead_Owner_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Lead_Owner';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': check items');
   --DBMS_output.put_line(l_full_name||': start item validate');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Lead_Owner_items(
         p_Lead_Owner_rec   => p_Lead_Owner_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': check record');
   --DBMS_output.put_line(l_full_name||': start record validate');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Lead_Owner_rec(
         p_Lead_Owner_rec     => p_Lead_Owner_rec,
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

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

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

END Validate_Lead_Owner;





---------------------------------------------------------------------
-- PROCEDURE
--    Create_Lead_Owner
--
-- PURPOSE
--    Create a new Lead Owner record
--
-- PARAMETERS
--    p_Lead_Owner_rec: the new record to be inserted
--    x_Lead_Owner_id: return the Lead_Owner_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Lead_Owner_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If Lead_Owner_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_Lead_Owner_rec IN  Lead_Owner_rec_type
  ,x_Lead_Owner_id  OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_Lead_Owner';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   l_Lead_Owner_rec         Lead_Owner_rec_type := p_Lead_Owner_rec;

   l_object_version_number NUMBER := 1;

   l_uniqueness_check     VARCHAR2(10);


   -- Cursor to get the sequence for Lead_Owner
   CURSOR c_Lead_Owner_seq IS
   SELECT AS_SALES_LEAD_OWNERS_S.NEXTVAL FROM DUAL;

   -- Cursor to validate the uniqueness
   CURSOR c_count(cv_Lead_Owner_id IN NUMBER) IS
   SELECT  'ANYTHING'
     FROM  AS_SALES_LEAD_OWNERS
     WHERE Lead_Owner_id = cv_Lead_Owner_id;


BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Create_Lead_Owner;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');


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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': validate');

   --DBMS_output.put_line(l_full_name||': validate');
   Validate_Lead_Owner(
      p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_Lead_Owner_rec    => l_Lead_Owner_rec
   );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   --DBMS_output.put_line(l_full_name||': back validate');

  -------------------------- insert --------------------------
  AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': insert');

  IF l_Lead_Owner_rec.Lead_Owner_id IS NULL THEN
    LOOP
      -- Get the identifier
      OPEN  c_Lead_Owner_seq;
      FETCH c_Lead_Owner_seq INTO l_Lead_Owner_rec.Lead_Owner_id;
      CLOSE c_Lead_Owner_seq;

      -- Check the uniqueness of the identifier
      OPEN  c_count(l_Lead_Owner_rec.Lead_Owner_id);
      FETCH c_count INTO l_uniqueness_check;
        -- Exit when the identifier uniqueness is established
        EXIT WHEN c_count%ROWCOUNT = 0;
      CLOSE c_count;
   END LOOP;
  END IF;

   IF (p_Lead_Owner_rec.country is null) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_COUNTRY_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   --DBMS_output.put_line(l_full_name||': start insert');
  INSERT INTO AS_SALES_LEAD_OWNERS (
       lead_Owner_id
      ,category
      ,country
      ,from_postal_code
      ,to_postal_code
      ,CM_resource_id
      ,referral_type
      ,owner_flag
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,object_version_number
       )
    VALUES (
       l_Lead_Owner_rec.Lead_Owner_id
      ,l_Lead_Owner_rec.category
      ,l_Lead_Owner_rec.country
      ,l_Lead_Owner_rec.from_postal_code
      ,l_Lead_Owner_rec.to_postal_code
      ,l_Lead_Owner_rec.CM_resource_id
      ,l_Lead_Owner_rec.referral_type
      ,l_Lead_Owner_rec.owner_flag
      ,SYSDATE                                -- LAST_UPDATE_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- LAST_UPDATED_BY
      ,SYSDATE                                -- CREATION_DATE
      ,NVL(FND_GLOBAL.user_id,-1)             -- CREATED_BY
      ,NVL(FND_GLOBAL.conc_login_id,-1)       -- LAST_UPDATE_LOGIN
      ,l_Lead_Owner_rec.request_id
      ,l_Lead_Owner_rec.program_application_id
      ,l_Lead_Owner_rec.program_id
      ,l_Lead_Owner_rec.program_update_date
      ,l_object_version_number                -- object_version_number
      );

  ------------------------- finish -------------------------------
  x_Lead_Owner_id := l_Lead_Owner_rec.Lead_Owner_id;

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

  AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Lead_Owner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Lead_Owner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Create_Lead_Owner;
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

END Create_Lead_Owner;


---------------------------------------------------------------
-- PROCEDURE
--   Delete_Lead_Owner
--
---------------------------------------------------------------
PROCEDURE Delete_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_Lead_Owner_id       IN  NUMBER
  ,p_object_version     IN  NUMBER

)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Lead_Owner';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Delete_Lead_Owner;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': delete');

   DELETE FROM AS_SALES_LEAD_OWNERS
     WHERE Lead_Owner_id = p_Lead_Owner_id
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

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_Lead_Owner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Lead_Owner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Lead_Owner;
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

END Delete_Lead_Owner;


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Lead_Owner
--    Not currently used.
--------------------------------------------------------------------
/*
PROCEDURE Lock_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_Lead_Owner_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Lead_Owner';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_Lead_Owner_id      NUMBER;

   CURSOR c_Lead_Owner IS
   SELECT  Lead_Owner_id
     FROM  AS_SALES_LEAD_OWNERS
     WHERE Lead_Owner_id = p_Lead_Owner_id
     AND   object_version_number = p_object_version
   FOR UPDATE OF Lead_Owner_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': lock');

   OPEN  c_Lead_Owner;
   FETCH c_Lead_Owner INTO l_Lead_Owner_id;
   IF (c_Lead_Owner%NOTFOUND) THEN
      CLOSE c_Lead_Owner;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_Lead_Owner;


   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

EXCEPTION

   WHEN AS_Utility_PVT.resource_locked THEN
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

END Lock_Lead_Owner;
*/

---------------------------------------------------------------------
-- PROCEDURE
-- Update_Lead_Owner
----------------------------------------------------------------------
PROCEDURE Update_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_Lead_Owner_rec     IN  Lead_Owner_rec_type

)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_Lead_Owner';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_Lead_Owner_rec   Lead_Owner_rec_type;
   l_return_status   VARCHAR2(1);
   l_mode            VARCHAR2(30) := 'UPDATE';


BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_Lead_Owner;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': validate');

   IF (p_Lead_Owner_rec.country is null) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_COUNTRY_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Lead_Owner_Items(
         p_Lead_Owner_Rec => p_Lead_Owner_rec,
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
   Complete_Lead_Owner_rec(p_Lead_Owner_rec, l_Lead_Owner_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Lead_Owner_rec(
  	 p_Lead_Owner_rec   => p_Lead_Owner_rec,
         p_complete_rec    => l_Lead_Owner_rec,
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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': update');

   UPDATE AS_SALES_LEAD_OWNERS SET
       category			  = l_Lead_Owner_rec.category
      ,country 			  = l_Lead_Owner_rec.country
      ,from_postal_code           = l_Lead_Owner_rec.from_postal_code
      ,to_postal_code             = l_Lead_Owner_rec.to_postal_code
      ,cm_resource_id             = l_Lead_Owner_rec.CM_resource_id
      ,referral_type              = l_Lead_Owner_rec.referral_type
      ,owner_flag                 = l_Lead_Owner_rec.owner_flag
      ,last_update_date           = SYSDATE
      ,last_updated_by            = NVL(FND_GLOBAL.user_id,-1)
      ,last_update_login          = NVL(FND_GLOBAL.conc_login_id,-1)
      ,request_id                 = l_Lead_Owner_rec.request_id
      ,program_application_id     = l_Lead_Owner_rec.program_application_id
      ,program_id                 = l_Lead_Owner_rec.program_id
      ,program_update_date        = l_Lead_Owner_rec.program_update_date
      ,object_version_number      = l_Lead_Owner_rec.object_version_number + 1
   WHERE Lead_Owner_id = l_Lead_Owner_rec.Lead_Owner_id
   AND   object_version_number = l_Lead_Owner_rec.object_version_number;

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

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Lead_Owner;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Lead_Owner;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Lead_Owner;
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

END Update_Lead_Owner;


---------------------------------------------------------------------
-- PROCEDURE
-- Get_Salesreps
----------------------------------------------------------------------
PROCEDURE Get_Salesreps(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,p_sales_lead_id     IN  NUMBER
  ,x_salesreps_tbl     OUT NOCOPY lead_owner_rec_tbl_type

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
)

IS

   l_api_version CONSTANT NUMBER := 2.0; -- As all the package and procedure are using ver 2
   l_api_name    CONSTANT VARCHAR2(30) := 'Get_Salesreps';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_lead_owner_rec lead_owner_rec_type;
   l_resource_id l_lead_owner_rec.cm_resource_id%type;
   l_owner_flag l_lead_owner_rec.owner_flag%type;

   l_sql_text_postal VARCHAR2(1000);
   l_sql_text_country VARCHAR2(1000);


CURSOR lc_lead_owners_postal(pc_lead_id NUMBER) IS
     SELECT aso.cm_resource_id, aso.owner_flag
     FROM AS_SALES_LEADS LEAD, HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, AS_SALES_LEAD_OWNERS ASO
     WHERE LEAD.SALES_LEAD_ID = pc_lead_id AND LEAD.ADDRESS_ID = PS.PARTY_SITE_ID(+)
     AND PS.LOCATION_ID = LOC.LOCATION_ID(+) AND ASO.COUNTRY = LOC.COUNTRY
     AND LOC.POSTAL_CODE BETWEEN ASO.FROM_POSTAL_CODE AND ASO.TO_POSTAL_CODE
     AND LEAD.REFERRAL_TYPE = ASO.REFERRAL_TYPE;

CURSOR lc_lead_owners_country(pc_lead_id NUMBER) IS
     SELECT aso.cm_resource_id, aso.owner_flag
     FROM AS_SALES_LEADS LEAD, HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, AS_SALES_LEAD_OWNERS ASO
     WHERE LEAD.SALES_LEAD_ID = pc_lead_id AND LEAD.ADDRESS_ID = PS.PARTY_SITE_ID(+)
     AND PS.LOCATION_ID = LOC.LOCATION_ID(+) AND ASO.COUNTRY = LOC.COUNTRY
--     AND LOC.POSTAL_CODE BETWEEN ASO.FROM_POSTAL_CODE AND ASO.TO_POSTAL_CODE);
     AND LEAD.REFERRAL_TYPE = ASO.REFERRAL_TYPE;


BEGIN

   -- Initialize the return table
   x_salesreps_tbl := lead_owner_rec_tbl_type();


   -------------------- initialize -------------------------
   SAVEPOINT Get_Salesreps;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': validate');

   IF (p_sales_lead_id is null) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_COUNTRY_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSE
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Sales lead id : ' || p_sales_lead_id);
            fnd_msg_pub.Add;
        END IF;

   END IF;

   open lc_lead_owners_postal(p_sales_lead_id);
   loop
      fetch lc_lead_owners_postal into l_resource_id, l_owner_flag;
      exit when lc_lead_owners_postal%notfound;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'Postal : salesforce_id : ' || l_resource_id || ' owner : ' || l_owner_flag);
        fnd_msg_pub.Add;
      END IF;

      x_salesreps_tbl.extend;
      x_salesreps_tbl(x_salesreps_tbl.last).cm_resource_id := l_resource_id;
      x_salesreps_tbl(x_salesreps_tbl.last).owner_flag := l_owner_flag;
    end loop;
    close lc_lead_owners_postal;

   -- check if the tablehas any data in it or not
   if (x_salesreps_tbl.count < 1) then

   open lc_lead_owners_country(p_sales_lead_id);
   loop
      fetch lc_lead_owners_country into l_resource_id, l_owner_flag;
      exit when lc_lead_owners_country%notfound;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'Country : salesforce_id : ' || l_resource_id || ' owner : ' || l_owner_flag);
        fnd_msg_pub.Add;
      END IF;

      x_salesreps_tbl.extend;
      x_salesreps_tbl(x_salesreps_tbl.last).cm_resource_id := l_resource_id;
      x_salesreps_tbl(x_salesreps_tbl.last).owner_flag := l_owner_flag;
    end loop;
    close lc_lead_owners_country;
   end if;
   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Get_Salesreps;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Get_Salesreps;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Get_Salesreps;
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

END Get_Salesreps;


-- Added by Ajoy

---------------------------------------------------------------------
-- PROCEDURE
-- Get_Immatured_Lead_Owner
-- Search in AS_SALES_LEAD_OWNER table for the lead woner where
-- CATEGORY = 'IMMATURED'
----------------------------------------------------------------------
PROCEDURE Get_Immatured_Lead_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,p_sales_lead_id     IN  NUMBER
  ,x_salesforce_id     OUT NOCOPY NUMBER

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
)

IS

   l_api_version CONSTANT NUMBER := 2.0; -- As all the package and procedure are using ver 2
   l_api_name    CONSTANT VARCHAR2(30) := 'Get_Immatured_Lead_Owner';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_lead_owner_rec lead_owner_rec_type;
   l_resource_id    l_lead_owner_rec.cm_resource_id%type;
   l_owner_flag     l_lead_owner_rec.owner_flag%type;
   l_salesreps_tbl  lead_owner_rec_tbl_type;

   l_sql_text_postal VARCHAR2(1000);
   l_sql_text_country VARCHAR2(1000);


CURSOR lc_lead_owners_postal(pc_lead_id NUMBER) IS
     SELECT aso.cm_resource_id, aso.owner_flag
     FROM AS_SALES_LEADS LEAD, HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, AS_SALES_LEAD_OWNERS ASO
     WHERE LEAD.SALES_LEAD_ID = pc_lead_id AND LEAD.ADDRESS_ID = PS.PARTY_SITE_ID(+)
     AND PS.LOCATION_ID = LOC.LOCATION_ID(+) AND ASO.COUNTRY = LOC.COUNTRY
     AND LOC.POSTAL_CODE BETWEEN ASO.FROM_POSTAL_CODE AND ASO.TO_POSTAL_CODE
     AND ASO.CATEGORY = 'IMMATURED'
     AND ASO.OWNER_FLAG = 'Y';

CURSOR lc_lead_owners_country(pc_lead_id NUMBER) IS
     SELECT aso.cm_resource_id, aso.owner_flag
     FROM AS_SALES_LEADS LEAD, HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, AS_SALES_LEAD_OWNERS ASO
     WHERE LEAD.SALES_LEAD_ID = pc_lead_id AND LEAD.ADDRESS_ID = PS.PARTY_SITE_ID(+)
     AND PS.LOCATION_ID = LOC.LOCATION_ID(+) AND ASO.COUNTRY = LOC.COUNTRY
--     AND LOC.POSTAL_CODE BETWEEN ASO.FROM_POSTAL_CODE AND ASO.TO_POSTAL_CODE);
     AND ASO.CATEGORY = 'IMMATURED'
     AND ASO.OWNER_FLAG = 'Y';

BEGIN

   -- Initialize the return table
   l_salesreps_tbl := lead_owner_rec_tbl_type();

   -------------------- initialize -------------------------
   SAVEPOINT Get_Salesreps;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

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
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': validate');

   IF (p_sales_lead_id is null) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_COUNTRY_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSE
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Sales lead id : ' || p_sales_lead_id);
            fnd_msg_pub.Add;
        END IF;

   END IF;

   open lc_lead_owners_postal(p_sales_lead_id);
   loop
      fetch lc_lead_owners_postal into l_resource_id, l_owner_flag;
      exit when lc_lead_owners_postal%notfound;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'Postal : salesforce_id : ' || l_resource_id || ' owner : ' || l_owner_flag);
        fnd_msg_pub.Add;
      END IF;

      l_salesreps_tbl.extend;
      l_salesreps_tbl(l_salesreps_tbl.last).cm_resource_id := l_resource_id;
      l_salesreps_tbl(l_salesreps_tbl.last).owner_flag := l_owner_flag;
    end loop;
    close lc_lead_owners_postal;

   -- check if the tablehas any data in it or not
   if (l_salesreps_tbl.count < 1) then

   open lc_lead_owners_country(p_sales_lead_id);
   loop
      fetch lc_lead_owners_country into l_resource_id, l_owner_flag;
      exit when lc_lead_owners_country%notfound;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'Country : salesforce_id : ' || l_resource_id || ' owner : ' || l_owner_flag);
        fnd_msg_pub.Add;
      END IF;

      l_salesreps_tbl.extend;
      l_salesreps_tbl(l_salesreps_tbl.last).cm_resource_id := l_resource_id;
      l_salesreps_tbl(l_salesreps_tbl.last).owner_flag := l_owner_flag;
    end loop;
    close lc_lead_owners_country;
   end if;

   IF (l_salesreps_tbl.count > 0) THEN
     x_salesforce_id := l_salesreps_tbl(1).cm_resource_id;
   ELSE
     AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Getting marketing owner from ptofile ');
     x_salesforce_id := fnd_profile.value('AS_DEFAULT_LEAD_MKTG_OWNER');
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

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Get_Salesreps;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Get_Salesreps;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Get_Salesreps;
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

END Get_Immatured_Lead_Owner;


END AS_SALES_LEAD_OWNER;

/
