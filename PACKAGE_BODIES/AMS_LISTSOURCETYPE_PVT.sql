--------------------------------------------------------
--  DDL for Package Body AMS_LISTSOURCETYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTSOURCETYPE_PVT" AS
/* $Header: amsvlstb.pls 115.25 2004/03/17 18:10:56 usingh ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_ListSourceType_PVT
--
-- PROCEDURES
--    Listed are the procedures not declared in the package
--    specs:
--       Check_ListSrcType_Req_Items
--       Check_ListSrcType_UK_Items
--       Check_ListSrcType_FK_Items
--       Check_ListSrcType_Lookup_Items
--       Check_ListSrcType_Flag_Items
--
-- HISTORY
-- 28-Jan-2000 choang      Created.
-- 31-Jan-2000 choang      Enabled cascade delete in delete API.
--                         Fixed update (complete proc used g_miss_num
--                         instead of g_miss_char for checking against
--                         char fields) and create (UK validation
--                         passed in code with enclosing quotes).
-- 06-May-2002 choang      added generate_source_fields for analytics
--                         data sources.
-- 06-Jun-2002 choang      Exclude DATE fields in generate_source_fields
-- 03-Sep-2002 nyostos     Added check that ANALYTICS data sources are
--                         not used by models before deleting them.
-- 27-Jan-2003 nyostos     Modified generate_source_fields so that it adds the
--                         primary key in the Data Source Fields table when
--                         creating ANALYTICS data sources.
-- 24-Mar-2003 choang      bug 2866418 - added UK validation for list source
--                         type and source type code.
------------------------------------------------------------

PROCEDURE Check_ListSrcType_Req_Items (
   p_listsrctype_rec    IN    ListSourceType_Rec_Type,
   x_return_status      OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_ListSrcType_UK_Items (
   p_listsrctype_rec    IN    ListSourceType_Rec_Type,
   p_validation_mode    IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_ListSrcType_FK_Items (
   p_listsrctype_rec IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_ListSrcType_Lookup_Items (
   p_listsrctype_rec IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_ListSrcType_Flag_Items (
   p_listsrctype_rec IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE generate_source_fields (
   p_listsrctype_rec    IN    ListSourceType_Rec_Type,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
);


--------------------------------------------------------------------
-- PROCEDURE
--    Create_ListSourceType
--
-- PURPOSE
--    Create a list source type entry.
--
-- PARAMETERS
--    p_listsrctype_rec: the record representing AMS_LIST_SRC_TYPES.
--    x_list_source_type_id: the list_source_type_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If list_source_type_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If list_source_type_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   x_list_source_type_id     OUT NOCOPY NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Create_ListSourceType';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   L_DATA_SOURCE_ANALYTICS CONSTANT VARCHAR2(30) := 'ANALYTICS';

   l_return_status   VARCHAR2(1);
   l_listsrctype_rec     ListSourceType_Rec_Type  := p_listsrctype_rec;
   l_dummy           NUMBER;     -- Capture the exit condition for ID existence loop.

   CURSOR c_seq IS
      SELECT ams_list_src_types_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (x_id IN NUMBER) IS
      SELECT 1
      FROM   ams_list_src_types
      WHERE list_source_type_id  = x_id;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Create_ListSourceType;

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   IF FND_API.to_boolean (p_init_msg_list) THEN
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
   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');

   Validate_ListSourceType (
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_listsrctype_rec    => l_listsrctype_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --
   -- Check for the ID.
   --
   IF l_listsrctype_rec.list_source_type_id IS NULL THEN
      LOOP
         l_dummy := NULL;

         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_listsrctype_rec.list_source_type_id;
         CLOSE c_seq;

         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_listsrctype_rec.list_source_type_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         --
         -- If the value for the ID already exists, then
         -- l_dummy would be populated with '1', otherwise,
         -- it receives NULL.
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   -------------------------- insert --------------------------
   AMS_Utility_PVT.debug_message (l_full_name || ': Insert');

   INSERT INTO ams_list_src_types (
      list_source_type_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      list_source_type,
      source_type_code,
      source_object_name,
      master_source_type_flag,
      source_object_pk_field,
      enabled_flag,
      view_application_id,
      java_class_name,
      import_type,
      arc_act_src_used_by,
      source_category
   )
   VALUES (
      l_listsrctype_rec.list_source_type_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,    -- object_version_number
      l_listsrctype_rec.list_source_type,
      l_listsrctype_rec.source_type_code,
      l_listsrctype_rec.source_object_name,
      l_listsrctype_rec.master_source_type_flag,
      l_listsrctype_rec.source_object_pk_field,
      -- analytics data sources cannot be enabled when created
      -- they need to have defined targets
      DECODE (l_listsrctype_rec.list_source_type, L_DATA_SOURCE_ANALYTICS, 'N', l_listsrctype_rec.enabled_flag),
      l_listsrctype_rec.view_application_id,
      l_listsrctype_rec.java_class_name,
      l_listsrctype_rec.import_type,
      l_listsrctype_rec.arc_act_src_used_by,
      l_listsrctype_rec.source_category
   );

  insert into AMS_LIST_SRC_TYPES_TL (
    LANGUAGE,
    SOURCE_LANG,
    LIST_SOURCE_NAME,
    DESCRIPTION,
    LIST_SOURCE_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l.language_code,
    userenv('LANG'),
    l_listsrctype_rec.LIST_SOURCE_NAME,
    l_listsrctype_rec.DESCRIPTION,
    l_listsrctype_rec.LIST_SOURCE_TYPE_ID,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from AMS_LIST_SRC_TYPES_TL T
    where T.LIST_SOURCE_TYPE_ID = l_listsrctype_rec.LIST_SOURCE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

   IF l_listsrctype_rec.list_source_type = L_DATA_SOURCE_ANALYTICS THEN
      generate_source_fields (
         p_listsrctype_rec    => l_listsrctype_rec,
         p_validation_level   => p_validation_level,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   ------------------------- finish -------------------------------
   --
   -- Set the out variable.
   x_list_source_type_id := l_listsrctype_rec.list_source_type_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message (l_full_name || ': End');

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_ListSourceType;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_ListSourceType;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_ListSourceType;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_ListSourceType;


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ListSourceType
--
-- PURPOSE
--    Delete a list source type entry.
--
-- PARAMETERS
--    p_list_source_type_id: the list_source_type_id
--    p_object_version: the object_version_number
--
-- ISSUES
--    Currently, we are not allowing people to delete list source type
--    entries.  We may add some business rules for deletion though.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_list_source_type_id IN NUMBER,
   p_object_version      IN NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Delete_ListSourceType';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   cursor c_delete_sources  is
   select 'x'
   from ams_list_src_types a
   WHERE a.list_source_type_id = p_list_source_type_id
   and exists (select 'x'
               from ams_list_headers_all  b
               where b.list_source_type = a.source_type_code) ;
  l_x char(1);


  L_DATA_SOURCE_ANALYTICS CONSTANT VARCHAR2(30) := 'ANALYTICS';
  l_no_of_models        NUMBER;
  l_list_source_type    VARCHAR2(30);
  l_target_id           NUMBER;

  -- Cursor to get the type of the data source
  CURSOR c_get_ds_type (l_id IN NUMBER) IS
  SELECT list_source_type
    FROM ams_list_src_types t
   WHERE t.list_source_type_id = l_id;

  -- Cursor to check if ANALYTICS data source is used in any models
  CURSOR c_analytics_ds_used (l_id IN NUMBER) IS
  SELECT count(*)
    FROM AMS_DM_MODELS_VL m, AMS_DM_TARGETS_VL t
   WHERE m.TARGET_ID = t.TARGET_ID
     AND t.data_source_id = l_id;

  -- Cursor to get the target_ids associated with this data source
  CURSOR c_get_ds_targets (l_id IN NUMBER) IS
  SELECT target_id
    FROM ams_dm_targets_vl t
   WHERE t.data_source_id = l_id;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Delete_ListSourceType;

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ delete ------------------------
   --added vb 06/18/2001
   --do not allow delete of seeded data source

   open c_delete_sources  ;
   loop
       fetch c_delete_sources  into l_x;
       exit when  c_delete_sources%notfound;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
          FND_MESSAGE.set_name ('AMS', 'AMS_API_CANNOT_DELETE');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
   end loop ;
   close c_delete_sources  ;
   IF (p_list_source_type_id <= 10000) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_CANNOT_DELETE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- nyostos - added 09/03/2002
   -- Do not allow delete of Analytics Data Source if used by any model
   -- First get the type of the Data Source
   OPEN c_get_ds_type(p_list_source_type_id);
   FETCH c_get_ds_type INTO l_list_source_type;
   CLOSE c_get_ds_type;

   IF l_list_source_type IS NOT NULL AND l_list_source_type = L_DATA_SOURCE_ANALYTICS THEN
      OPEN c_analytics_ds_used(p_list_source_type_id);
      FETCH c_analytics_ds_used INTO l_no_of_models;
      CLOSE c_analytics_ds_used;
      IF l_no_of_models > 0 THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_DM_DATASOURCE_USED');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -------------------- finish --------------------------

   DELETE FROM ams_list_src_types
   WHERE list_source_type_id = p_list_source_type_id
   AND   object_version_number = p_object_version
   ;

   DELETE FROM ams_list_src_types_tl
   WHERE list_source_type_id = p_list_source_type_id
   ;


   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- choang - 31-Jan-2000
   -- Add cascade delete funtionality.
   ------------- Delete Child Records --------------------
   -- AMS_LIST_SRC_FIELDS --
   DELETE FROM ams_list_src_fields
   WHERE list_source_type_id = p_list_source_type_id;

   -- AMS_LIST_SRC_TYPE_ASSOCS --
   DELETE FROM ams_list_src_type_assocs
   WHERE master_source_type_id = p_list_source_type_id;

   -------------------- finish --------------------------


   -- nyostos - added 09/03/2002
   -- Also delete all targets defined for this data source.
   LOOP
      l_target_id := NULL;

      OPEN c_get_ds_targets(p_list_source_type_id);
      FETCH c_get_ds_targets INTO l_target_id;
      CLOSE c_get_ds_targets;

      EXIT WHEN l_target_id IS NULL;

      DELETE FROM ams_dm_targets_b
      WHERE target_id = l_target_id;

      DELETE FROM ams_dm_targets_tl
      WHERE target_id = l_target_id;
   END LOOP;

   -------------------- finish --------------------------


   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message(l_full_name || ': End');

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Delete_ListSourceType;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_ListSourceType;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_ListSourceType;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Delete_ListSourceType;


--------------------------------------------------------------------
-- PROCEDURE
--    Lock_ListSourceType
--
-- PURPOSE
--    Lock a list source type entry.
--
-- PARAMETERS
--    p_list_source_type_id: the list_source_type_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_list_source_type_id   IN  NUMBER,
   p_object_version     IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_ListSourceType';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_dummy        NUMBER;     -- Used by the lock cursor.

   --
   -- NOTE: Not necessary to distinguish between a record
   -- which does not exist and one which has been updated
   -- by another user.  To get that distinction, remove
   -- the object_version condition from the SQL statement
   -- and perform comparison in the body and raise the
   -- exception there.
   CURSOR c_lock_req IS
      SELECT object_version_number
      FROM   ams_list_src_types
      WHERE  list_source_type_id = p_list_source_type_id
      AND    object_version_number = p_object_version
      FOR UPDATE NOWAIT;
BEGIN
   --------------------- initialize -----------------------
   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ lock -------------------------
   OPEN c_lock_req;
   FETCH c_lock_req INTO l_dummy;
   IF c_lock_req%NOTFOUND THEN
      CLOSE c_lock_req;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_lock_req;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message (l_full_name || ': End');

EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RESOURCE_LOCKED');
         FND_MSG_PUB.add;
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Lock_ListSourceType;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_ListSourceType
--
-- PURPOSE
--    Update a list source type entry.
--
-- PARAMETERS
--    p_listsrctype_rec: the record representing AMS_LIST_SRC_TYPES.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_listsrctype_rec    IN  ListSourceType_Rec_Type
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_ListSourceType';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_listsrctype_rec ListSourceType_Rec_Type := p_listsrctype_rec;
   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_ListSourceType;

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   IF FND_API.to_boolean (p_init_msg_list) THEN
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

   --added vb 06/28/2001
   --do not allow update of seeded data source

/*
   IF (l_listsrctype_rec.list_source_type_id <= 10000) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_CANNOT_UPDATE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
*/

   ----------------------- validate ----------------------
   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');

   -- replace g_miss_char/num/date with current column values
   Complete_ListSourceType_Rec (p_listsrctype_rec, l_listsrctype_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_ListSourceType_Items (
         p_listsrctype_rec    => l_listsrctype_rec,
         p_validation_mode    => JTF_PLSQL_API.g_update,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_ListSourceType_Record (
         p_listsrctype_rec => p_listsrctype_rec,
         p_complete_rec    => l_listsrctype_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------------- update --------------------
   UPDATE ams_list_src_types
   SET
      last_update_date        = SYSDATE,
      last_updated_by         = FND_GLOBAL.user_id,
      last_update_login       = FND_GLOBAL.conc_login_id,
      object_version_number   = object_version_number + 1,
      list_source_type        = l_listsrctype_rec.list_source_type,
      source_type_code        = l_listsrctype_rec.source_type_code,
      source_object_name      = l_listsrctype_rec.source_object_name,
      master_source_type_flag = l_listsrctype_rec.master_source_type_flag,
      source_object_pk_field  = l_listsrctype_rec.source_object_pk_field,
      enabled_flag            = l_listsrctype_rec.enabled_flag,
      view_application_id     = l_listsrctype_rec.view_application_id,
      java_class_name         = l_listsrctype_rec.java_class_name,
      import_type             = l_listsrctype_rec.import_type,
      arc_act_src_used_by     = l_listsrctype_rec.arc_act_src_used_by,
      source_category         = l_listsrctype_rec.source_category
   WHERE list_source_type_id = l_listsrctype_rec.list_source_type_id
   AND   object_version_number = l_listsrctype_rec.object_version_number
   ;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

  update AMS_LIST_SRC_TYPES_TL set
    LIST_SOURCE_NAME = l_listsrctype_rec.LIST_SOURCE_NAME,
    DESCRIPTION = l_listsrctype_rec.DESCRIPTION,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_BY = FND_GLOBAL.user_id,
    LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
    SOURCE_LANG = userenv('LANG')
  where list_source_type_id = l_listsrctype_rec.list_source_type_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND)THEN
     ------------------------------------------------------------------
     -- Error, check the msg level and added an error message to the --
     -- API message list.                                            --
     ------------------------------------------------------------------
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.set_name('AMS', 'API_UNEXP_ERROR_IN_PROCESSING');
        FND_MESSAGE.Set_Token('ROW', 'AMS_ListSourceType_PVT.Upd_AMS_LIST_SRC_TYPES_TL', TRUE);
        FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message (l_full_name || ': End');

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_ListSourceType;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_ListSourceType;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_ListSourceType;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_ListSourceType;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListSourceType
--
-- PURPOSE
--    Validate a list source type entry.
--
-- PARAMETERS
--    p_listsrctype_rec: the record representing AMS_LIST_SRC_TYPES.
--
-- NOTES
--    1. p_listsrctype_rec should be the complete list source type record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_listsrctype_rec    IN  ListSourceType_Rec_Type
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_ListSourceType';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   AMS_Utility_PVT.debug_message (l_full_name || ': Start');

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   AMS_Utility_PVT.debug_message (l_full_name || ': Check items');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_ListSourceType_Items (
         p_listsrctype_rec    => p_listsrctype_rec,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   AMS_Utility_PVT.debug_message (l_full_name || ': Check record');

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_ListSourceType_Record (
         p_listsrctype_rec => p_listsrctype_rec,
         p_complete_rec    => NULL,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AMS_Utility_PVT.debug_message (l_full_name || ': End');

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_ListSourceType;

PROCEDURE check_lstsrctype_business(
    p_listsrctype_rec IN ListSourceType_Rec_Type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
  l_import_type VARCHAR2(30);
  CURSOR c_import_type(code IN VARCHAR2) IS SELECT lookup_code FROM ams_lookups
    WHERE lookup_type = 'AMS_IMPORT_TYPE' and enabled_flag='Y'
    AND lookup_code = code;

  cursor c_viewname(code in varchar2) is
     SELECT length(nvl(TRANSLATE(code,
     '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_',
     ' '), 0))
     FROM DUAL;
  l_cnt NUMBER := 1;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

   -- choang - 07-may-2002
   -- import type not relevant for analytics
   -- gjoby 29 - MAY -02  check only for import
   IF p_listsrctype_rec.list_source_type = 'IMPORT' THEN
      OPEN c_import_type(p_listsrctype_rec.import_type);
      FETCH c_import_type into l_import_type;
      IF (c_import_type%NOTFOUND) THEN
         CLOSE c_import_type;
         FND_MESSAGE.SET_NAME('AMS', 'AMS_INVALID_IMPORT_TYPE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE c_import_type;
   END IF;

   -- View creation is based on source_type_code which
   -- contains characters, numbers, and understore characters
   OPEN c_viewname(p_listsrctype_rec.source_type_code);
   FETCH c_viewname into l_cnt;
   IF l_cnt > 1 THEN
      FND_MESSAGE.SET_NAME('AMS', 'AMS_INVALID_SOURCE_TYPE_CODE');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   CLOSE c_viewname;

END check_lstsrctype_business;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_ListSourceType_Items (
   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_ListSrcType_Req_Items (
      p_listsrctype_rec => p_listsrctype_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --
   -- Validate uniqueness.
   Check_ListSrcType_UK_Items (
      p_listsrctype_rec    => p_listsrctype_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ListSrcType_FK_Items(
      p_listsrctype_rec => p_listsrctype_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ListSrcType_Lookup_Items (
      p_listsrctype_rec    => p_listsrctype_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ListSrcType_Flag_Items(
      p_listsrctype_rec => p_listsrctype_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_lstsrctype_business');
   check_lstsrctype_business(
      p_listsrctype_rec => p_listsrctype_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   AMS_UTILITY_PVT.debug_message('Private API: ' || 'after check_lstsrctype_business');

END Check_ListSourceType_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSourceType_Record (
   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   p_complete_rec       IN  ListSourceType_Rec_Type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_reference (p_list_source_type_id IN NUMBER) IS
      SELECT list_source_type
           , source_type_code
           , source_object_name
           , master_source_type_flag
           , source_object_pk_field
           , enabled_flag
           , description
           , view_application_id
           , list_source_name
           , java_class_name
           , arc_act_src_used_by
           , source_category
           , import_type
      FROM   AMS_LIST_SRC_TYPES_VL
      WHERE  list_source_type_id = p_list_source_type_id
      ;
   l_reference_rec      c_reference%ROWTYPE;

   CURSOR c_target_exists (p_list_source_type_id IN NUMBER) IS
      SELECT 1
      FROM   ams_dm_targets_b
      WHERE  data_source_id = p_list_source_type_id
      AND    active_flag = 'Y'
      ;

   l_target_indicator   NUMBER;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- only perform these validations when an UPDATE
   -- API call is made.
   IF p_complete_rec.list_source_type_id IS NOT NULL THEN
      OPEN c_reference (p_listsrctype_rec.list_source_type_id);
      FETCH c_reference INTO l_reference_rec;
      CLOSE c_reference;

      -- choang - 07-may-2002
      -- analytics data sources must have active targets
      -- defined for them before they can be made active.
      IF l_reference_rec.list_source_type = 'ANALYTICS' THEN
         IF l_reference_rec.enabled_flag = 'N' AND p_listsrctype_rec.enabled_flag = 'Y' THEN
            OPEN c_target_exists (p_listsrctype_rec.list_source_type_id);
            FETCH c_target_exists INTO l_target_indicator;
            CLOSE c_target_exists;

            IF l_target_indicator IS NULL OR l_target_indicator <> 1 THEN
               AMS_Utility_PVT.error_message ('AMS_DM_NO_TARGETS');
               x_return_status := FND_API.g_ret_sts_error;
            END IF;
         END IF;
      END IF;  -- if analytics data source
   END IF;
END Check_ListSourceType_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ListSourceType_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_ListSourceType_Rec (
   x_listsrctype_rec         OUT NOCOPY  ListSourceType_Rec_Type
)
IS
BEGIN
   x_listsrctype_rec.list_source_type_id := FND_API.g_miss_num;
   x_listsrctype_rec.last_update_date := FND_API.g_miss_date;
   x_listsrctype_rec.last_updated_by := FND_API.g_miss_num;
   x_listsrctype_rec.creation_date := FND_API.g_miss_date;
   x_listsrctype_rec.created_by := FND_API.g_miss_num;
   x_listsrctype_rec.last_update_login := FND_API.g_miss_num;
   x_listsrctype_rec.object_version_number := FND_API.g_miss_num;
   x_listsrctype_rec.list_source_type := FND_API.g_miss_char;
   x_listsrctype_rec.list_source_name := FND_API.g_miss_char;
   x_listsrctype_rec.source_type_code := FND_API.g_miss_char;
   x_listsrctype_rec.source_object_name := FND_API.g_miss_char;
   x_listsrctype_rec.master_source_type_flag := FND_API.g_miss_char;
   x_listsrctype_rec.source_object_pk_field := FND_API.g_miss_char;
   x_listsrctype_rec.enabled_flag := FND_API.g_miss_char;
   x_listsrctype_rec.description := FND_API.g_miss_char;
   x_listsrctype_rec.view_application_id := FND_API.g_miss_num;
END Init_ListSourceType_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_ListSourceType_Rec
--
-- PURPOSE
--    For Update_ListSourceType, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_listdr_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_ListSourceType_Rec (
   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   x_complete_rec       OUT NOCOPY ListSourceType_Rec_Type
)
IS
   CURSOR c_fields IS
      SELECT *
      FROM   ams_list_src_types_vl
      WHERE  list_source_type_id = p_listsrctype_rec.list_source_type_id
      ;
   l_listsrctype_rec    c_fields%ROWTYPE;
BEGIN
   x_complete_rec := p_listsrctype_rec;

   OPEN c_fields;
   FETCH c_fields INTO l_listsrctype_rec;
   IF c_fields%NOTFOUND THEN
      CLOSE c_fields;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_fields;


   -- LIST_SOURCE_TYPE
   IF p_listsrctype_rec.list_source_type = FND_API.g_miss_char THEN
      x_complete_rec.list_source_type := l_listsrctype_rec.list_source_type;
   END IF;

   -- LIST_SOURCE_NAME
   IF p_listsrctype_rec.list_source_name = FND_API.g_miss_char THEN
      x_complete_rec.list_source_name := l_listsrctype_rec.list_source_name;
   END IF;


   -- SOURCE_TYPE_CODE
   IF p_listsrctype_rec.source_type_code = FND_API.g_miss_char THEN
      x_complete_rec.source_type_code := l_listsrctype_rec.source_type_code;
   END IF;

   -- SOURCE_OBJECT_NAME
   IF p_listsrctype_rec.source_object_name = FND_API.g_miss_char THEN
      x_complete_rec.source_object_name := l_listsrctype_rec.source_object_name;
   END IF;

   -- MASTER_SOURCE_TYPE_FLAG
   IF p_listsrctype_rec.master_source_type_flag = FND_API.g_miss_char THEN
      x_complete_rec.master_source_type_flag := l_listsrctype_rec.master_source_type_flag;
   END IF;

   -- SOURCE_OBJECT_PK_FIELD
   IF p_listsrctype_rec.source_object_pk_field = FND_API.g_miss_char THEN
      x_complete_rec.source_object_pk_field := l_listsrctype_rec.source_object_pk_field;
   END IF;

   -- ENABLED_FLAG
   IF p_listsrctype_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_listsrctype_rec.enabled_flag;
   END IF;

   -- DESCRIPTION
   IF p_listsrctype_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_listsrctype_rec.description;
   END IF;


   -- VIEW APPLICATION ID
   IF p_listsrctype_rec.view_application_id = FND_API.g_miss_num THEN
      x_complete_rec.view_application_id := l_listsrctype_rec.view_application_id;
   END IF;

END Complete_ListSourceType_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSrcType_Req_Items (
   p_listsrctype_rec     IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;


   -- list_source_type
   IF p_listsrctype_rec.list_source_type IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_LISTSRC_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

      -- list_source_name
   IF p_listsrctype_rec.list_source_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_LISTSRC_NAME');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


   -- source_type_code
   IF p_listsrctype_rec.source_type_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_SRCTYPE_CODE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- source_object_name
   IF p_listsrctype_rec.source_object_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_SRCOBJ_NAME');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_ListSrcType_Req_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSrcType_UK_Items (
   p_listsrctype_rec     IN    ListSourceType_Rec_Type,
   p_validation_mode IN    VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
   l_list_src_types_table     CONSTANT VARCHAR2(30) := 'ams_list_src_types';
   l_valid_flag      VARCHAR2(1);
   l_where_clause    VARCHAR2(4000);

   CURSOR c_name_create (p_name IN VARCHAR2) IS
      SELECT 1
      FROM   ams_list_src_types_vl
      WHERE  list_source_name = p_name;

   CURSOR c_name_update (p_name IN VARCHAR2, p_id IN NUMBER) IS
      SELECT 'Y'
      FROM   ams_list_src_types_vl
      WHERE  list_source_name = p_name
      AND    list_source_type_id <> p_id;

BEGIN
   l_where_clause := 'list_source_type = ''' || p_listsrctype_rec.list_source_type || ''' ' ||
                     'AND source_type_code = ''' || p_listsrctype_rec.source_type_code || '''';
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      -- Validate that the list_source_name is unique.
      OPEN c_name_create (p_listsrctype_rec.list_source_name);
      FETCH c_name_create INTO l_valid_flag;
      CLOSE c_name_create;
      IF l_valid_flag IS NOT NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_DUPE_LISTSRC_NAME');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         l_valid_flag := NULL;
      END IF;

      -- list_source_type and source_type_code
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         p_table_name   => l_list_src_types_table,
         p_where_clause => l_where_clause
      );
      IF l_valid_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_DUPE_LISTSRC_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         l_valid_flag := NULL;
      END IF;
   ELSE  -- update operations have to exclude the current record (by ID)
      -- Validate that the list_source_name is unique.
      OPEN c_name_update (p_listsrctype_rec.list_source_name, p_listsrctype_rec.list_source_type_id);
      FETCH c_name_update INTO l_valid_flag;
      CLOSE c_name_update;
      IF l_valid_flag IS NOT NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_DUPE_LISTSRC_NAME');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         l_valid_flag := NULL;
      END IF;

      -- list_source_type and source_type_code
      l_valid_flag := AMS_Utility_PVT.check_uniqueness (
         p_table_name   => l_list_src_types_table,
         p_where_clause => l_where_clause || ' AND list_source_type_id <> ' || p_listsrctype_rec.list_source_type_id
      );
      IF l_valid_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_DUPE_LISTSRC_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         l_valid_flag := NULL;
      END IF;
   END IF;
END Check_ListSrcType_UK_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSrcType_FK_Items (
   p_listsrctype_rec     IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
----------------------------------------------------
-- NOTE:
-- Do we need to add checking for the column pk
-- field?  How about the table field?
----------------------------------------------------
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END Check_ListSrcType_FK_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSrcType_Lookup_Items (
   p_listsrctype_rec     IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --------------------- view application_id ------------------------
   IF p_listsrctype_rec.view_application_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_listsrctype_rec.view_application_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_LIST_BAD_APPLICATION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_ListSrcType_Lookup_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSrcType_Flag_Items
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSrcType_Flag_Items (
   p_listsrctype_rec     IN    ListSourceType_Rec_Type,
   x_return_status   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- master_source_type_flag
   IF p_listsrctype_rec.master_source_type_flag <> FND_API.g_miss_char AND p_listsrctype_rec.master_source_type_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_listsrctype_rec.master_source_type_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_LIST_BAD_MASTERSRC_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- enabled_flag
   IF p_listsrctype_rec.enabled_flag <> FND_API.g_miss_char AND p_listsrctype_rec.enabled_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_listsrctype_rec.enabled_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_LIST_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END Check_ListSrcType_Flag_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    generate_source_fields
--
-- PURPOSE
--    Generate the fields associated to the data source using the
--    column name to derive the source column meaning.
--
-- NOTE
--    Called by the data source create API for analytics type
--    data sources.
--
--    DISTINCT added because Apps views are created multiple times
--    in MRC environments.  ODM only supports mining on numeric
--    fields; character fields can be converted to numbers, but dates
--    cannot - INCLUDE only NUMBER and VARCHAR2 fields.
--
--    ENABLED_FLAG is used by list generation to determine
--    if a field is to be used for populating AMS_LIST_ENTRIES.
--    Analytics uses the ANALYTICS_FLAG to determine if the
--    field is to be used for data mining.
--
--    FIELD_TABLE_NAME and FIELD_COLUMN name are not populated
--    by default.  The fields are required when enabling
--    (ENABLED_FLAG = Y) the analytics data source field for
--    list generation.
--
-- PARAMETERS
--    p_listsrctype_rec: the data source record
--    p_validation_level: the API validation level
--    x_return_status: standard return status out param
---------------------------------------------------------------------
PROCEDURE generate_source_fields (
   p_listsrctype_rec    IN    ListSourceType_Rec_Type,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
)
IS
   L_DEFAULT_NUM_BUCKETS      CONSTANT NUMBER := 10;

--   CURSOR c_source (p_source_name IN VARCHAR2, p_pk IN VARCHAR2) IS
--      SELECT DISTINCT column_name, data_type
--      FROM   sys.all_tab_columns
--      WHERE  table_name = p_source_name
--      AND    column_name <> p_pk
--      AND    data_type IN ('NUMBER', 'VARCHAR2')
--      ;

   -- Modified by nyostos on Jan 27, 2003 to remove condition that field is not the primary key
   CURSOR c_source (p_source_name IN VARCHAR2) IS
      SELECT DISTINCT column_name, data_type
      FROM   sys.all_tab_columns
      WHERE  table_name = p_source_name
      AND    data_type IN ('NUMBER', 'VARCHAR2')
      ;

   l_field_rec             AMS_List_Src_Field_PVT.list_src_field_rec_type;
   l_list_source_field_id  NUMBER;
BEGIN
   SAVEPOINT generate_source_fields;

   x_return_status := FND_API.g_ret_sts_success;

   l_field_rec.list_source_type_id := p_listsrctype_rec.list_source_type_id;
   l_field_rec.de_list_source_type_code := p_listsrctype_rec.source_type_code;
   l_field_rec.enabled_flag := 'N'; -- list gen flag
   l_field_rec.analytics_flag := 'Y';
   l_field_rec.auto_binning_flag := 'Y';
   l_field_rec.no_of_buckets := L_DEFAULT_NUM_BUCKETS;

   -- Modified by nyostos on Jan 27, 2003 to remove condition that field is not the primary key
--   FOR l_source_rec IN c_source (p_listsrctype_rec.source_object_name, p_listsrctype_rec.source_object_pk_field) LOOP
   FOR l_source_rec IN c_source (p_listsrctype_rec.source_object_name) LOOP
      l_field_rec.source_column_name := l_source_rec.column_name;
      -- convert underscores (_) to spaces and make initial caps.
      -- Example: COLUMN_NAME becomes "Column Name"
      l_field_rec.source_column_meaning := INITCAP (REPLACE (l_source_rec.column_name, '_', ' '));
      l_field_rec.field_data_type := l_source_rec.data_type;

      AMS_List_Src_Field_PVT.Create_List_Src_Field (
         p_api_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         p_commit                => FND_API.G_FALSE,
         p_validation_level      => p_validation_level,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_list_src_field_rec    => l_field_rec,
         x_list_source_field_id  => l_list_source_field_id
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO generate_source_fields;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
     );
END generate_source_fields;


END AMS_ListSourceType_PVT;

/
