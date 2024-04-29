--------------------------------------------------------
--  DDL for Package Body AMS_OBJECTATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_OBJECTATTRIBUTE_PVT" AS
/* $Header: amsvobab.pls 115.21 2001/12/17 16:15:20 pkm ship    $ */


g_pkg_name  CONSTANT VARCHAR2(30) := 'AMS_ObjectAttribute_PVT';


-----------------------------------------------------------------
-- PROCEDURE
--    create_attribute
-----------------------------------------------------------------
PROCEDURE create_attribute(
   x_object_type            IN VARCHAR2,
   x_object_id              IN NUMBER,
   x_custom_setup_id        IN NUMBER,
   x_display_sequence_no    IN NUMBER,
   x_object_attribute       IN VARCHAR2,
   x_attribute_defined_flag IN VARCHAR2,

   x_return_status          OUT VARCHAR2
)
IS

   CURSOR c_get_attr_seq IS
   SELECT AMS_OBJECT_ATTRIBUTES_S.NEXTVAL
     FROM DUAL;

   l_attribute_id  NUMBER;
   l_api_name      CONSTANT VARCHAR2(30) := 'create_attribute';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   open c_get_attr_seq;
   fetch c_get_attr_seq into l_attribute_id;
   close c_get_attr_seq;

   insert into ams_object_attributes(
       object_attribute_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       object_version_number,
       object_type,
       object_id,
       custom_setup_id,
       display_sequence_no,
       object_attribute,
       attribute_defined_flag
    )
    values(
      l_attribute_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number,
      x_object_type,
      x_object_id,
      x_custom_setup_id,
      x_display_sequence_no,
      x_object_attribute,
      x_attribute_defined_flag
   );

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END create_attribute;


-----------------------------------------------------------------
-- PROCEDURE
--    create_object_attributes
-----------------------------------------------------------------
PROCEDURE create_object_attributes(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_object_type       IN  VARCHAR2,
   p_object_id         IN  NUMBER,
   p_setup_id          IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_object_attributes';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_get_custom_attributes IS
   SELECT display_sequence_no, object_attribute
     FROM ams_custom_setup_attr
    WHERE custom_setup_id = p_setup_id
      AND attr_available_flag = 'Y';

   CURSOR c_get_object_attr_count IS
   SELECT count(object_attribute)
     FROM ams_custom_setup_attr
    WHERE custom_setup_id = p_setup_id;

   l_return_status  VARCHAR2(1);
   l_attr_count     NUMBER;
   l_seq_no         NUMBER;
   l_obj_attr       VARCHAR2(10);

BEGIN

   -- initialize
   SAVEPOINT create_object_attributes;
   AMS_Utility_PVT.debug_message(l_full_name||': start');

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


   AMS_Utility_PVT.debug_message(l_full_name ||': checking setup id');

   -- check arc object
   --   Following code is modified by ptendulk on 30-Jan-2001 to add attributes to schedules.
   --   IF p_object_type NOT IN ('CAMP','DELV','EVEH','EVEO','FUND','MESG','OFFR','CLAM','PROD','PRIC') THEN
   --   end of code Modified by ptendulk
   IF p_object_type NOT IN ('CAMP','DELV','EVEH','EVEO','FUND','MESG','OFFR','CLAM','PROD','PRIC','CSCH') THEN
      AMS_Utility_PVT.error_message('AMS_SCG_BAD_ARC_OBJECT');
      RAISE FND_API.g_exc_error;
   END IF;

   -- check if the setup type is valid and  if there are any attributes
   open c_get_object_attr_count;
   fetch c_get_object_attr_count into l_attr_count;
   close c_get_object_attr_count;

   if l_attr_count = 0 then
      -- raise an error -- setup type / attributes does not exist
      AMS_Utility_PVT.error_message('AMS_OBA_BAD_SETUP_TYPE');
      RAISE FND_API.g_exc_error;
   end if;


   AMS_Utility_PVT.debug_message(l_full_name ||': get attributes');

   open c_get_custom_attributes;
   loop
      fetch c_get_custom_attributes into l_seq_no, l_obj_attr;
      exit when c_get_custom_attributes%notfound;

      AMS_Utility_PVT.debug_message(l_full_name ||': '||l_obj_attr);

      --insert attribute row;
      create_attribute(
         x_object_type            => p_object_type,
         x_object_id              => p_object_id,
         x_custom_setup_id        => p_setup_id,
         x_display_sequence_no    => l_seq_no,
         x_object_attribute       => l_obj_attr,
         x_attribute_defined_flag => 'N',

         x_return_status    =>  l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         close c_get_custom_attributes;
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         close c_get_custom_attributes;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   end loop;
   close c_get_custom_attributes;

   AMS_Utility_PVT.debug_message(l_full_name ||': insert general attribute');

   create_attribute(
      x_object_type            => p_object_type,
      x_object_id              => p_object_id,
      x_custom_setup_id        => p_setup_id,
      x_display_sequence_no    => 0,
      x_object_attribute       => 'DETL' ,
      x_attribute_defined_flag => 'Y',
      x_return_status    =>  l_return_status
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   AMS_Utility_PVT.debug_message(l_full_name ||': End');

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_object_attributes;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_object_attributes;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_object_attributes;
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

END create_object_attributes;


-----------------------------------------------------------------
-- PROCEDURE
--    process_object_attribute
-----------------------------------------------------------------
PROCEDURE modify_object_attribute(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_object_type                    IN  VARCHAR2,
   p_object_id                        IN   NUMBER,
   p_attr               IN  VARCHAR2,
   p_attr_defined_flag     IN VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'modify_object_attribute';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_get_object_attribute IS
   SELECT attribute_defined_flag
     FROM ams_object_attributes
    WHERE object_type = p_object_type
      AND object_id = p_object_id
      AND object_attribute = p_attr;

   l_return_status  VARCHAR2(1);
   l_attr_flag      VARCHAR2(1);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT modify_object_attribute;

   AMS_Utility_PVT.debug_message(l_full_name||': start');

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

   -- check arc object
   --   Following code is modified by ptendulk on 30-Jan-2001 to add attributes to schedules.
   --IF p_object_type NOT IN ('CAMP','DELV','EVEH','EVEO','FUND','MESG','OFFR','CLAM','PROD','PRIC') THEN
   IF p_object_type NOT IN ('CAMP','DELV','EVEH','EVEO','FUND','MESG','OFFR','CLAM','PROD','PRIC','CSCH') THEN
   --   End of code modified by ptendulk on 30-Jan-2001 to add attributes to schedules.
      AMS_Utility_PVT.error_message('AMS_SCG_BAD_ARC_OBJECT');
      RAISE FND_API.g_exc_error;
   END IF;

   IF p_attr_defined_flag  NOT IN ( 'Y', 'N') THEN
      AMS_Utility_PVT.error_message('AMS_OBA_BAD_ATTR_FLAG');
      RAISE FND_API.g_exc_error;
   END IF;

   open c_get_object_attribute;
   fetch  c_get_object_attribute into l_attr_flag;
   if c_get_object_attribute%notfound then
      close c_get_object_attribute;
      AMS_Utility_PVT.error_message('AMS_OBA_BAD_SETUP_ATTR');
      RAISE FND_API.g_exc_error;
   else
      AMS_Utility_PVT.debug_message(l_full_name ||': updating object attribute');
      close c_get_object_attribute;
      UPDATE ams_object_attributes
         SET attribute_defined_flag = p_attr_defined_flag,
             object_version_number = object_version_number + 1
       WHERE object_type = p_object_type
         AND object_id = p_object_id
         AND object_attribute = p_attr;
   end if;


   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   AMS_Utility_PVT.debug_message(l_full_name ||': End');

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO modify_object_attribute;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO modify_object_attribute;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO modify_object_attribute;
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

END modify_object_attribute;


-----------------------------------------------------------------------
-- FUNCTION
--    check_object_attribute
-- HISTORY
--    05/08/2000  holiu  Created.
-----------------------------------------------------------------------
FUNCTION check_object_attribute(
   p_obj_type    IN  VARCHAR2,
   p_obj_id      IN  NUMBER,
   p_attribute   IN  VARCHAR2
)
RETURN VARCHAR2  --FND_API.g_true/g_false
IS

   l_dummy  NUMBER;

   CURSOR c_object_attr IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS (
          SELECT 1
            FROM ams_object_attributes
           WHERE object_type = p_obj_type
             AND object_id = p_obj_id
             AND object_attribute = p_attribute);

BEGIN

   OPEN c_object_attr;
   FETCH c_object_attr INTO l_dummy;
   CLOSE c_object_attr;

   IF l_dummy IS NULL THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_object_attribute;


END AMS_ObjectAttribute_PVT;

/
