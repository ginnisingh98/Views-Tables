--------------------------------------------------------
--  DDL for Package Body AMS_LISTFIELD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTFIELD_PVT" AS
/* $Header: amsvlfdb.pls 115.1 2000/02/05 17:48:57 pkm ship    $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_ListField_PVT
--
-- PURPOSE
--    Private API for Oracle Marketing List Fields.
--
-- PROCEDURES
--       Check_ListField_Flag_Items
--
-- HISTORY
-- 25-Jan-2000 choang   Created.
--
------------------------------------------------------------

PROCEDURE Check_ListField_Flag_Items (
   p_listfield_rec   IN    List_Field_Rec_Type,
   x_return_status   OUT   VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_ListField
--
-- PURPOSE
--    Lock a list field entry.
--
-- PARAMETERS
--    p_listfield_id: the list_field_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_ListField (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_listfield_id      IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_ListField';
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
      FROM   ams_list_fields_b
      WHERE  list_field_id = p_listfield_id
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
END Lock_ListField;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_ListField
--
-- PURPOSE
--    Update a list field entry.
--
-- PARAMETERS
--    p_listfield_rec: the record representing AMS_LIST_FIELDS_VL.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_ListField (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_listfield_rec     IN  List_Field_Rec_Type
)
IS
   l_api_version  CONSTANT NUMBER := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Update_ListField';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_listfield_rec   List_Field_Rec_Type := p_listfield_rec;
   l_return_status   VARCHAR2(1);
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_ListField;

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

   ----------------------- validate ----------------------
   AMS_Utility_PVT.debug_message (l_full_name || ': Validate');

   -- replace g_miss_char/num/date with current column values
   Complete_ListField_Rec (p_listfield_rec, l_listfield_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_ListField_Items (
         p_listfield_rec      => p_listfield_rec,
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
      Check_ListField_Record (
         p_listfield_rec   => p_listfield_rec,
         p_complete_rec    => l_listfield_rec,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------------- update --------------------
   UPDATE ams_list_fields_b
   SET
      object_version_number   = object_version_number + 1,
      field_table_name        = l_listfield_rec.field_table_name,
      field_column_name       = l_listfield_rec.field_column_name,
      column_data_type        = l_listfield_rec.column_data_type,
      column_data_length      = l_listfield_rec.column_data_length,
      enabled_flag            = l_listfield_rec.enabled_flag,
      list_type_field_apply_on = l_listfield_rec.list_type_field_apply_on,
      last_update_date        = SYSDATE,
      last_updated_by         = FND_GLOBAL.user_id,
      last_update_login       = FND_GLOBAL.conc_login_id
   WHERE list_field_id        = l_listfield_rec.list_field_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   UPDATE ams_list_fields_tl
   SET
      description       = l_listfield_rec.description,
      last_update_date  = SYSDATE,
      last_updated_by   = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang       = USERENV('LANG')
   WHERE list_field_id = l_listfield_rec.list_field_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
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
      ROLLBACK TO Update_ListField;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_ListField;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_ListField;
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
END Update_ListField;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListField
--
-- PURPOSE
--    Validate a list field entry.
--
-- PARAMETERS
--    p_listfield_rec: the record representing AMS_LIST_FIELDS_VL.
--
-- NOTES
--    1. p_listfield_rec should be the complete list field record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_ListField (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_listfield_rec     IN  List_Field_Rec_Type
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_ListField';
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
      Check_ListField_Items (
         p_listfield_rec      => p_listfield_rec,
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
      Check_ListField_Record (
         p_listfield_rec   => p_listfield_rec,
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
END Validate_ListField;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListField_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_listfield_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_ListField_Items (
   p_listfield_rec      IN  List_Field_Rec_Type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT VARCHAR2
)
IS
BEGIN
   --
   -- Validate required items.
   Check_ListField_Flag_Items (
      p_listfield_rec   => p_listfield_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_ListField_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListField_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listfield_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListField_Record (
   p_listfield_rec    IN  List_Field_Rec_Type,
   p_complete_rec     IN  List_Field_Rec_Type := NULL,
   x_return_status    OUT VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END Check_ListField_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ListField_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_ListField_Rec (
   x_listfield_rec         OUT  List_Field_Rec_Type
)
IS
BEGIN
   x_listfield_rec.list_field_id := FND_API.g_miss_num;
   x_listfield_rec.last_update_date := FND_API.g_miss_date;
   x_listfield_rec.last_updated_by := FND_API.g_miss_num;
   x_listfield_rec.creation_date := FND_API.g_miss_date;
   x_listfield_rec.created_by := FND_API.g_miss_num;
   x_listfield_rec.last_update_login := FND_API.g_miss_num;
   x_listfield_rec.object_version_number := FND_API.g_miss_num;
   x_listfield_rec.field_table_name := FND_API.g_miss_char;
   x_listfield_rec.field_column_name := FND_API.g_miss_char;
   x_listfield_rec.column_data_type := FND_API.g_miss_char;
   x_listfield_rec.column_data_length := FND_API.g_miss_num;
   x_listfield_rec.enabled_flag := FND_API.g_miss_char;
   x_listfield_rec.list_type_field_apply_on := FND_API.g_miss_char;
   x_listfield_rec.description := FND_API.g_miss_char;
END Init_ListField_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_ListField_Rec
--
-- PURPOSE
--    For Update_ListField, some attributes may be passed in as
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
PROCEDURE Complete_ListField_Rec (
   p_listfield_rec      IN  List_Field_Rec_Type,
   x_complete_rec       OUT List_Field_Rec_Type
)
IS
   CURSOR c_field IS
      SELECT *
      FROM   ams_list_fields_b
      WHERE  list_field_id = p_listfield_rec.list_field_id
      ;
   l_listfield_rec      c_field%ROWTYPE;
BEGIN
   x_complete_rec := p_listfield_rec;

   --
   -- Fetch the values which are in the database.
   OPEN c_field;
   FETCH c_field INTO l_listfield_rec;
   IF c_field%NOTFOUND THEN
      CLOSE c_field;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_field;

   -- FIELD_TABLE_NAME
   IF p_listfield_rec.field_table_name = FND_API.g_miss_char THEN
      x_complete_rec.field_table_name := l_listfield_rec.field_table_name;
   END IF;

   -- FIELD_COLUMN_NAME
   IF p_listfield_rec.field_column_name = FND_API.g_miss_char THEN
      x_complete_rec.field_column_name := l_listfield_rec.field_column_name;
   END IF;

   -- COLUMN_DATA_TYPE
   IF p_listfield_rec.column_data_type = FND_API.g_miss_char THEN
      x_complete_rec.column_data_type := l_listfield_rec.column_data_type;
   END IF;

   -- COLUMN_DATA_LENGTH
   IF p_listfield_rec.column_data_length = FND_API.g_miss_num THEN
      x_complete_rec.column_data_length := l_listfield_rec.column_data_length;
   END IF;

   -- ENABLED_FLAG
   IF p_listfield_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_listfield_rec.enabled_flag;
   END IF;

   -- LIST_TYPE_FIELD_APPLY_ON
   IF p_listfield_rec.list_type_field_apply_on = FND_API.g_miss_char THEN
      x_complete_rec.list_type_field_apply_on := l_listfield_rec.list_type_field_apply_on;
   END IF;

-------------------------------------------
-- ISSUE:
-- As of 25-jan-2000, VL views are broken
-- because of language setting in dev
-- database.  Remove the leading comments
-- after language setting fixed.
   -- DESCRIPTION
--   IF p_listfield_rec.description = FND_API.g_miss_char THEN
--      x_complete_rec.description := l_listfield_rec.description;
--   END IF;

END Complete_ListField_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListField_Flag_Items
--
-- PURPOSE
--    Validate that the flags have proper values.  Proper values
--    for flags are 'Y' and 'N'.
--
-- HISTORY
-- 01-Nov-1999 choang      Created.
-- 16-Dec-1999 choang      Added check for DEDUPE_FLAG and PROCESS_IMMED_FLAG.
---------------------------------------------------------------------
PROCEDURE Check_ListField_Flag_Items (
   p_listfield_rec   IN    List_Field_Rec_Type,
   x_return_status   OUT   VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- ENABLED_FLAG
   IF p_listfield_rec.enabled_flag <> FND_API.g_miss_char AND p_listfield_rec.enabled_flag IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N (p_listfield_rec.enabled_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_LIST_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END Check_ListField_Flag_Items;


END AMS_ListField_PVT;

/
