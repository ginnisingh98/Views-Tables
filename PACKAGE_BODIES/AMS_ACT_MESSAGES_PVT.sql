--------------------------------------------------------
--  DDL for Package Body AMS_ACT_MESSAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_MESSAGES_PVT" AS
/* $Header: amsvacmb.pls 115.10 2002/11/15 21:01:42 abhola ship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'AMS_Act_Messages_PVT';

-- forward declaration of validate messages
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE validate_act_messages
(
  p_act_msg_id                 IN      NUMBER,
  p_message_id               IN      NUMBER,
  p_msg_used_by	     IN      VARCHAR2,
  p_msg_used_by_id       IN      NUMBER,
  p_object_version            IN      NUMBER,

  x_return_status         OUT NOCOPY     VARCHAR2
);


  /****************************************************************************/
-- Procedure
--   create_act_messages

-- History
--   10/28/1999     nrengasw      created
------------------------------------------------------------------------------
PROCEDURE create_act_messages
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_message_id               IN      NUMBER,
  p_message_used_by   IN      VARCHAR2,
  p_msg_used_by_id       IN      NUMBER,
  x_act_msg_id            OUT NOCOPY     NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_act_messages';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_actm_count     NUMBER;

   CURSOR c_actm_seq IS
   SELECT ams_act_messages_s.NEXTVAL
     FROM DUAL;

   BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_act_messages;

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

   AMS_Utility_PVT.debug_message(l_full_name ||': Check campaign rules');
   END IF;
/*if ams_campaignrules_pvt.check_camp_attribute = FND_API.g_true
then */

-- get sequence
open c_actm_seq;
fetch c_actm_seq into x_act_msg_id;
close  c_actm_seq;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': Check validation');

   END IF;
-- validate act messages
 validate_act_messages
(
  x_act_msg_id,
  p_message_id ,
  p_message_used_by,
  p_msg_used_by_id,
  1,
  x_return_status
);
  IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
  ELSIF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
  END IF;

insert into ams_act_messages
(act_message_id,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by,
   last_update_login,
   object_version_number,
   message_id,
   message_used_by,
   message_used_by_id
)
values
(x_act_msg_id,
 SYSDATE,
 FND_GLOBAL.user_id,
 SYSDATE,
 FND_GLOBAL.user_id,
 FND_GLOBAL.conc_login_id,
 1,  -- object_version_number
  p_message_id,
  p_message_used_by ,
  p_msg_used_by_id
  );
/*
else
-- message that cannot be associated with this type of campaign.
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('AMS', 'AMS_ACTM_INVALID_USED_BY');
         FND_MSG_PUB.Add;
  END IF;
end if; */
/* --commented by musman 03/29/01
-- added by julou on 03/08/2000
   -- indicate offer has been defined for the campaign
   AMS_ObjectAttribute_PVT.modify_object_attribute(
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_object_type        => p_message_used_by,
      p_object_id          => p_msg_used_by_id,
      p_attr               => 'MESG',
      p_attr_defined_flag  => 'Y'
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
-- end of part added

*/

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
      ROLLBACK TO create_act_messages;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_act_messages;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_act_messages;
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

END create_act_messages;


  /****************************************************************************/
-- Procedure
--   update_act_messages

-- History
--   10/28/1999     nrengasw      created
------------------------------------------------------------------------------
PROCEDURE update_act_messages
(
  p_api_version           IN      NUMBER,
  p_init_msg_list         IN      VARCHAR2 := FND_API.g_false,
  p_commit                IN      VARCHAR2 := FND_API.g_false,
  p_validation_level      IN      NUMBER   := FND_API.g_valid_level_full,

  x_return_status         OUT NOCOPY     VARCHAR2,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2,

  p_act_msg_id                 IN      NUMBER,
  p_message_id               IN      NUMBER,
  p_msg_used_by	     IN      VARCHAR2,
  p_msg_used_by_id       IN      NUMBER,
  p_object_version            IN      NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_act_messages';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT update_act_messages;

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

-- validate act messages
  validate_act_messages
(
  p_act_msg_id              ,
  p_message_id         ,
  p_msg_used_by	,
  p_msg_used_by_id ,
  p_object_version,

  x_return_status
);

  IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
 END IF;

UPDATE ams_act_messages  SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = p_object_version + 1,
      message_id = p_message_id,
      message_used_by = p_msg_used_by,
      message_used_by_id = p_msg_used_by_id
 WHERE act_message_id =  p_act_msg_id
  AND object_version_number = p_object_version;

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
      ROLLBACK TO update_act_messages;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_act_messages;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_act_messages;
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

  END update_act_messages;

/****************************************************************************/
-- Procedure
--   delete_act_messages

-- History
--   10/28/1999     nrengasw      created
----------------------------------------------------------------------------------------------
PROCEDURE delete_act_messages
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,
  p_commit           IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_msg_id       IN      NUMBER,
  p_object_version   IN      NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_act_messages';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_used_by_id             NUMBER;
   l_used_by                VARCHAR2(30);
   l_dummy                  NUMBER;

   CURSOR c_used_by IS
   SELECT message_used_by_id, message_used_by
     FROM ams_act_messages
    WHERE act_message_id = p_act_msg_id;

   CURSOR c_msg IS
   SELECT 1
     FROM ams_act_messages
   WHERE message_used_by_id = l_used_by_id
     AND message_used_by = l_used_by;

   BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_act_messages;

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

   OPEN c_used_by;
   FETCH c_used_by INTO l_used_by_id, l_used_by;
   CLOSE c_used_by;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

-- validate act messages
-- check for available object attributes

DELETE FROM ams_act_messages
WHERE  ACT_MESSAGE_ID = p_act_msg_id
AND         OBJECT_VERSION_NUMBER = p_object_version;
/* commented by musman on 03/29/01
-- added by julou on 03/07/2000
   -- indicate if there is any other offers for this campaign
   OPEN c_msg;
   FETCH c_msg INTO l_dummy;
   CLOSE c_msg;

   IF l_dummy IS NULL THEN
      AMS_ObjectAttribute_PVT.modify_object_attribute(
         p_api_version        => l_api_version,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,

         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,

         p_object_type        => l_used_by,
         p_object_id          => l_used_by_id,
         p_attr               => 'MESG',
         p_attr_defined_flag  => 'N'
      );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
-- end of part added
*/

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
      ROLLBACK TO delete_act_messages;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_act_messages;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_act_messages;
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

  END delete_act_messages;


/****************************************************************************/
-- Procedure
--   lock_act_messages

-- History
--   10/28/1999     nrengasw      created
----------------------------------------------------------------------------------------------

PROCEDURE lock_act_messages
(
  p_api_version      IN      NUMBER,
  p_init_msg_list    IN      VARCHAR2 := FND_API.g_false,

  x_return_status    OUT NOCOPY     VARCHAR2,
  x_msg_count        OUT NOCOPY     NUMBER,
  x_msg_data         OUT NOCOPY     VARCHAR2,

  p_act_msg_id       IN      NUMBER,
  p_object_version   IN      NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'lock_act_messages';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_act_msg_id     NUMBER;

   CURSOR c_actm_lck IS
   SELECT act_message_id
     FROM ams_act_messages
    WHERE act_message_id  = p_act_msg_id
      AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

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

  OPEN c_actm_lck;
   FETCH c_actm_lck INTO l_act_msg_id;
   IF (c_actm_lck%NOTFOUND) THEN
      CLOSE c_actm_lck;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_actm_lck;

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

END lock_act_messages;

/****************************************************************************/
-- Procedure
--   validate_act_messages

-- History
--   01/04/2000     nrengasw      created
----------------------------------------------------------------------------------------------
PROCEDURE validate_act_messages
(
  p_act_msg_id                 IN      NUMBER,
  p_message_id               IN      NUMBER,
  p_msg_used_by	     IN      VARCHAR2,
  p_msg_used_by_id       IN      NUMBER,
  p_object_version            IN      NUMBER,

  x_return_status         OUT NOCOPY     VARCHAR2
)
IS

l_table_name                  VARCHAR2(30);
l_pk_name                     VARCHAR2(30);
l_pk_value                    VARCHAR2(30);
l_pk_data_type                VARCHAR2(30);
l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
l_return_status   VARCHAR2(1);
l_dummy_char    VARCHAR2(1);
l_obj_type             VARCHAR2(100);

cursor c_chk_message is
   select 'x'
   from    AMS_MESSAGES_B
   where message_id = p_message_id;

cursor c_get_objtype_name is
    select meaning
    from    ams_lookups
    where  lookup_type = 'AMS_SYS_ARC_QUALIFIER'
    and      lookup_code = p_msg_used_by;

 cursor c_chk_actmsg is
   select  'x'
   from     ams_act_messages
   where  message_used_by =  p_msg_used_by
   and      message_used_by_id   = p_msg_used_by_id
   and      message_id = p_message_id;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

     IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_Utility_PVT.debug_message('checking the message');

     END IF;
     open c_chk_message;
     fetch c_chk_message into l_dummy_char;
     if c_chk_message%notfound
     then
              close c_chk_message;
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name ('AMS', 'AMS_MESSAGE_NOT_FOUND');
		FND_MSG_PUB.Add;
	     END IF;
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     return;
    end if;
    close c_chk_message;

  open c_get_objtype_name;
  fetch c_get_objtype_name into l_obj_type;
  close c_get_objtype_name;

/*** Commneted by ABHOLA
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('validating foreign keys');
    END IF;
 -- Get table_name and pk_name for the ARC qualifier.
      AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => p_msg_used_by,
         x_return_status                => x_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );

      l_pk_value                 := p_msg_used_by_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;

    IF AMS_Utility_PVT.Check_FK_Exists (
           p_table_name                   => l_table_name
          ,p_pk_name                      => l_pk_name
          ,p_pk_value                     => l_pk_value
          ,p_pk_data_type                 => l_pk_data_type
          ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name ('AMS', 'AMS_ACTM_INVALID_USED_BY');
		FND_MESSAGE.Set_token('OBJTYPE', l_obj_type, FALSE);
		FND_MSG_PUB.Add;
	     END IF;
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     return;
   END IF;
********************/
   /********* commented by musman on 03/29/2001
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('Checking message availability, if it is a campaign');
       END IF;

     if p_msg_used_by = 'CAMP'
     then
         if ams_campaignrules_pvt.check_camp_attribute(
						p_msg_used_by_id, 'MESG' ) = FND_API.G_FALSE
        then
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name ('AMS', 'AMS_MESSAGE_NOT_AVAILABLE');
	      FND_MSG_PUB.Add;
	   END IF;
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   return;
	end if;
     end if;

     */

       IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('Checking message uniqueness');

       END IF;
       open c_chk_actmsg;
       fetch c_chk_actmsg into l_dummy_char;
       if c_chk_actmsg%found
       then
              close c_chk_actmsg;
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name ('AMS', 'AMS_MESSAGE_NOT_UNIQUE');
		FND_MSG_PUB.Add;
	     END IF;
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     return;
       end if;
       close c_chk_actmsg;


       IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message('End of validation');


       END IF;

 END  validate_act_messages;

END AMS_ACT_MESSAGES_PVT;

/
