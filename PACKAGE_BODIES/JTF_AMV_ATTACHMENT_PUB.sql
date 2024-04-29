--------------------------------------------------------
--  DDL for Package Body JTF_AMV_ATTACHMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AMV_ATTACHMENT_PUB" AS
/* $Header: jtfpattb.pls 115.11 2002/11/26 22:14:43 stopiwal ship $ */
--
-- PACKAGE
--    JTF_AMV_ATTACHMENT_PUB
--

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'JTF_AMV_ATTACHMENT_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'jtfpattb.pls';
--
g_number       CONSTANT NUMBER := 1;  -- data type is number
g_varchar2     CONSTANT NUMBER := 2;  -- data type is varchar2
--
G_USED_BY_ITEM      CONSTANT VARCHAR2(30) := 'ITEM';
G_MES_APPL_ID       CONSTANT NUMBER := 520;
G_ISTORE_APPL_ID    CONSTANT NUMBER := 671;
--
--------------------------------------------------------------------------
------------------------- Private Procedure ------------------------------
-- PROCEDURE
--    check_uniqueness
FUNCTION check_uniqueness(
   p_table_name    IN VARCHAR2,
   p_where_clause  IN VARCHAR2
) RETURN VARCHAR2 AS
l_sql      VARCHAR2(4000);
l_count    NUMBER;
BEGIN

   l_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
   l_sql := l_sql || ' WHERE ' || p_where_clause;

   EXECUTE IMMEDIATE l_sql INTO l_count;

   IF l_count = 0 THEN
      RETURN FND_API.g_true;
   ELSE
      RETURN FND_API.g_false;
   END IF;

END check_uniqueness;
--------------------------------------------------------------------------
FUNCTION check_fk_exists(
   p_table_name   IN VARCHAR2,
   p_pk_name      IN VARCHAR2,
   p_pk_value     IN VARCHAR2,
   p_pk_data_type IN NUMBER := g_number,
   p_additional_where_clause  IN VARCHAR2 := NULL
) RETURN VARCHAR2 AS
   l_sql   VARCHAR2(4000);
   l_count NUMBER;
BEGIN
   l_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
   l_sql := l_sql || ' WHERE ' || p_pk_name || ' = ';

   IF p_PK_data_type = g_varchar2 THEN
      l_sql := l_sql || '''' || p_pk_value || '''';
   ELSE
      l_sql := l_sql || p_pk_value;
   END IF;

   IF p_additional_where_clause IS NOT NULL THEN
      l_sql := l_sql || ' AND ' || p_additional_where_clause;
   END IF;

   EXECUTE IMMEDIATE l_sql INTO l_count;
   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;
END check_fk_exists;
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
) Return VARCHAR2 AS
   l_sql   VARCHAR2(2000);
   l_count NUMBER;
BEGIN
   l_sql := 'SELECT COUNT(*) FROM ' || p_lookup_table_name;
   l_sql := l_sql || ' WHERE lookup_type = ''' || p_lookup_type ||'''';
   l_sql := l_sql || ' AND lookup_code = ''' || p_lookup_code ||'''';
   l_sql := l_sql || ' AND enabled_flag = ''Y''';

   EXECUTE IMMEDIATE l_sql INTO l_count;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_lookup_exists;
---------------------------------------------------------------------
FUNCTION is_Y_or_N(

   p_value IN VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
   IF p_value = 'Y' or p_value = 'N' THEN
      RETURN FND_API.g_true;
   ELSE
      RETURN FND_API.g_false;
   END IF;
END is_Y_or_N;
--------------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_req_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_act_attachment_req_items
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   x_return_status       OUT NOCOPY  VARCHAR2
) AS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -------------------- put required items here ---------------------

   --IF p_act_attachment_rec.xxx IS NULL THEN
   --   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
   --      FND_MESSAGE.set_name('JTF', 'JTF_AMV_API_RECORD_NOT_FOUND');
   --      FND_MSG_PUB.add;
   --   END IF;

   --   x_return_status := FND_API.g_ret_sts_error;
   --   RETURN;
   --END IF;

END check_act_attachment_req_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_uk_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_act_attachment_uk_items
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY  VARCHAR2
) AS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_act_attachment, when attachment_id is passed in, we
   -- need to check if this attachment_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create AND
      p_act_attachment_rec.attachment_id IS NOT NULL THEN
      IF check_uniqueness(
         'jtf_amv_attachments',
         'attachment_id = ' || p_act_attachment_rec.attachment_id
          ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('JTF', 'JTF_AMV_ACT_ATTACH_DUPL_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other unique items

END check_act_attachment_uk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_fk_items
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_act_attachment_fk_items
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   x_return_status       OUT NOCOPY  VARCHAR2
) AS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

/*
   ----------------------- status_code ------------------------
   IF p_act_attachment_rec.xxx <> FND_API.g_miss_num THEN
      IF check_fk_exists(
            'ams_statuses_vl',
            'status_code',
            'p_act_attachment_rec.xxx'
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('JTF', 'JTF_AMV_ACT_ATTACH_BAD_XXX');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
   -- check other fk items

END check_act_attachment_fk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_lk_items (lookup)
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_act_attachment_lk_items
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   x_return_status       OUT NOCOPY  VARCHAR2
) AS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- status_code ------------------------

   -- check other lookup codes

END check_act_attachment_lk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_fg_items (flag)
--
-- HISTORY
--    10/11/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_act_attachment_fg_items
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   x_return_status       OUT NOCOPY  VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- enabled_flag ------------------------
   IF p_act_attachment_rec.enabled_flag <> FND_API.g_miss_char
      AND p_act_attachment_rec.enabled_flag IS NOT NULL
   THEN
      IF is_Y_or_N(p_act_attachment_rec.enabled_flag) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('JTF', 'JTF_AMV_ACT_ATTACH_BAD_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- can_fulfill_electronic_flag ------------------------
   IF p_act_attachment_rec.can_fulfill_electronic_flag <> FND_API.g_miss_char
      AND p_act_attachment_rec.can_fulfill_electronic_flag IS NOT NULL
   THEN
      IF is_Y_or_N(p_act_attachment_rec.can_fulfill_electronic_flag)
          = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('JTF', 'JTF_AMV_BAD_CAN_FUL_ELEC');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END check_act_attachment_fg_items;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- PROCEDURE
--    create_act_attachment
--
-- HISTORY
--    10/09/99  khung  Create.
--    06/20/00  rmajumda Modified the Insert statment to accomodate
--                       new columns added display_text,alternate_text
--                       and attachment_sub_type
---------------------------------------------------------------------

PROCEDURE create_act_attachment
(
  p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.g_false,
  p_commit               IN   VARCHAR2 := FND_API.g_false,
  p_validation_level     IN   NUMBER   := FND_API.g_valid_level_full,

  x_return_status        OUT NOCOPY   VARCHAR2,
  x_msg_count            OUT NOCOPY   NUMBER,
  x_msg_data             OUT NOCOPY   VARCHAR2,

  p_act_attachment_rec   IN   act_attachment_rec_type,
  x_act_attachment_id    OUT NOCOPY   NUMBER
) AS

l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'create_act_attachment';
--
l_return_status          VARCHAR2(1);
l_act_attachment_rec     act_attachment_rec_type := p_act_attachment_rec;
l_act_attachment_count   NUMBER;

CURSOR c_act_attachment_seq IS
SELECT jtf_amv_attachments_s.NEXTVAL
FROM DUAL;

CURSOR c_act_attachment_count(act_attachment_id IN NUMBER) IS
SELECT COUNT(*)
FROM jtf_amv_attachments
WHERE attachment_id = act_attachment_id;
--
CURSOR c_get_deli_type_code(p_item_id IN NUMBER) IS
SELECT deliverable_type_code
FROM   jtf_amv_items_b
WHERE  item_id = p_item_id;
l_deli_type_code    VARCHAR2(40);
--
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT create_act_attachment;
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   IF NOT FND_API.compatible_api_call
   (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- validate -----------------------
   validate_act_attachment
   (
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.G_FALSE,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_act_attachment_rec => l_act_attachment_rec
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   -------------------------- insert --------------------------
   IF l_act_attachment_rec.attachment_id IS NULL THEN
      LOOP
         OPEN  c_act_attachment_seq;
         FETCH c_act_attachment_seq INTO l_act_attachment_rec.attachment_id;
         CLOSE c_act_attachment_seq;

         OPEN c_act_attachment_count(l_act_attachment_rec.attachment_id);
         FETCH c_act_attachment_count INTO l_act_attachment_count;
         CLOSE c_act_attachment_count;

         EXIT WHEN l_act_attachment_count = 0;
      END LOOP;
   END IF;
   IF (l_act_attachment_rec.attachment_used_by = G_USED_BY_ITEM) THEN
      OPEN  c_get_deli_type_code(l_act_attachment_rec.attachment_used_by_id);
      FETCH c_get_deli_type_code INTO l_deli_type_code;
      IF (c_get_deli_type_code%NOTFOUND) THEN
          CLOSE c_get_deli_type_code;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
              FND_MESSAGE.Set_Token('ID',
                 to_char(nvl(l_act_attachment_rec.attachment_used_by_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_get_deli_type_code;
   END IF;
   -- Istore specific stuff.
   IF (l_act_attachment_rec.application_id = G_ISTORE_APPL_ID) THEN
      IF l_act_attachment_rec.file_name is null THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_FILENAME_NULL');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
      END IF;
      IF (l_act_attachment_rec.attachment_used_by = G_USED_BY_ITEM AND
          l_act_attachment_rec.display_url is null AND
          l_deli_type_code = 'MEDIA') THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_DISPLAY_RUL_NULL');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   INSERT INTO jtf_amv_attachments
   (
      attachment_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      owner_user_id,
      attachment_used_by_id,
      attachment_used_by,
      version,
      enabled_flag,
      can_fulfill_electronic_flag,
      file_id,
      file_name,
      file_extension,
      document_id,
      keywords,
      display_width,
      display_height,
      display_location,
      link_to,
      link_URL,
      send_for_preview_flag,
      attachment_type,
      language_code,
      application_id,
      description,
      default_style_sheet,
      display_url,
      display_rule_id,
      display_program,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
	 display_text,
	 alternate_text,
         secured_flag,
	 attachment_sub_type
      )
	 VALUES (
      l_act_attachment_rec.attachment_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_act_attachment_rec.owner_user_id,
      l_act_attachment_rec.attachment_used_by_id,
      l_act_attachment_rec.attachment_used_by,
      l_act_attachment_rec.version,
      NVL(l_act_attachment_rec.enabled_flag, 'Y'),
      NVL(l_act_attachment_rec.can_fulfill_electronic_flag, 'N'),
      l_act_attachment_rec.file_id,
      l_act_attachment_rec.file_name,
      l_act_attachment_rec.file_extension,
      l_act_attachment_rec.document_id,
      l_act_attachment_rec.keywords,
      l_act_attachment_rec.display_width,
      l_act_attachment_rec.display_height,
      l_act_attachment_rec.display_location,
      l_act_attachment_rec.link_to,
      l_act_attachment_rec.link_URL,
      l_act_attachment_rec.send_for_preview_flag,
      l_act_attachment_rec.attachment_type,
      l_act_attachment_rec.language_code,
      l_act_attachment_rec.application_id,
      l_act_attachment_rec.description,
      l_act_attachment_rec.default_style_sheet,
      l_act_attachment_rec.display_url,
      l_act_attachment_rec.display_rule_id,
      l_act_attachment_rec.display_program,
      l_act_attachment_rec.attribute_category,
      l_act_attachment_rec.attribute1,
      l_act_attachment_rec.attribute2,
      l_act_attachment_rec.attribute3,
      l_act_attachment_rec.attribute4,
      l_act_attachment_rec.attribute5,
      l_act_attachment_rec.attribute6,
      l_act_attachment_rec.attribute7,
      l_act_attachment_rec.attribute8,
      l_act_attachment_rec.attribute9,
      l_act_attachment_rec.attribute10,
      l_act_attachment_rec.attribute11,
      l_act_attachment_rec.attribute12,
      l_act_attachment_rec.attribute13,
      l_act_attachment_rec.attribute14,
      l_act_attachment_rec.attribute15,
      l_act_attachment_rec.display_text,
      l_act_attachment_rec.alternate_text,
      l_act_attachment_rec.secured_flag,
      l_act_attachment_rec.attachment_sub_type
   );
   IF (l_act_attachment_rec.attachment_used_by = G_USED_BY_ITEM) THEN
       update jtf_amv_items_b
       set last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.conc_login_id
       where item_id = l_act_attachment_rec.attachment_used_by_id ;
   END IF;
   ------------------------- finish -------------------------------
   x_act_attachment_id := l_act_attachment_rec.attachment_id;
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   FND_MSG_PUB.count_and_get
   (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_act_attachment;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_act_attachment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO create_act_attachment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END create_act_attachment;

--------------------------------------------------------------------
-- PROCEDURE
--    delete_act_attachment
--
-- HISTORY
--    10/09/99  khung  Create.
--------------------------------------------------------------------
PROCEDURE delete_act_attachment
(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
  p_commit               IN  VARCHAR2 := FND_API.g_false,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  p_act_attachment_id    IN  NUMBER,
  p_object_version       IN  NUMBER
) AS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'delete_act_attachment';
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_act_attachment;
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
   DELETE FROM jtf_amv_attachments
   WHERE attachment_id = p_act_attachment_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_AMV_API_RECORD_NOT_FOUND');
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

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_act_attachment;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_act_attachment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_act_attachment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END delete_act_attachment;

---------------------------------------------------------------------
-- PROCEDURE
--    update_act_attachment
--
-- HISTORY
--    10/09/99  khung  Create.
--    06/20/00  rmajumda Modified the Update statement
----------------------------------------------------------------------

PROCEDURE update_act_attachment
(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
  p_commit               IN  VARCHAR2 := FND_API.g_false,
  p_validation_level     IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,

  p_act_attachment_rec   IN  act_attachment_rec_type
) AS
l_api_version CONSTANT NUMBER := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'update_act_attachment';
l_act_attachment_rec   act_attachment_rec_type;
l_return_status        VARCHAR2(1);
--
CURSOR c_get_deli_type_code(p_item_id IN NUMBER) IS
SELECT deliverable_type_code
FROM   jtf_amv_items_b
WHERE  item_id = p_item_id;
l_deli_type_code    VARCHAR2(40);
--
BEGIN
   -------------------- initialize -------------------------
   SAVEPOINT update_act_attachment;
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   IF NOT FND_API.compatible_api_call
   (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_act_attachment_items
      (
         p_act_attachment_rec => p_act_attachment_rec,
         p_validation_mode    => JTF_PLSQL_API.g_update,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   complete_act_attachment_rec(p_act_attachment_rec, l_act_attachment_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_act_attachment_record
      (
         p_act_attachment_rec => p_act_attachment_rec,
         p_complete_rec       => l_act_attachment_rec,
         x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
   IF (l_act_attachment_rec.attachment_used_by = G_USED_BY_ITEM) THEN
      OPEN  c_get_deli_type_code(l_act_attachment_rec.attachment_used_by_id);
      FETCH c_get_deli_type_code INTO l_deli_type_code;
      IF (c_get_deli_type_code%NOTFOUND) THEN
          CLOSE c_get_deli_type_code;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
              FND_MESSAGE.Set_Token('ID',
                 to_char(nvl(l_act_attachment_rec.attachment_used_by_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_get_deli_type_code;
   END IF;
   IF (l_act_attachment_rec.application_id = G_ISTORE_APPL_ID) THEN
      IF l_act_attachment_rec.file_name is null THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_FILENAME_NULL');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
      END IF;
      IF (l_act_attachment_rec.attachment_used_by = G_USED_BY_ITEM AND
          l_act_attachment_rec.display_url is null AND
          l_deli_type_code = 'MEDIA') THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_DISPLAY_RUL_NULL');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -------------------------- update --------------------
   UPDATE jtf_amv_attachments SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_act_attachment_rec.object_version_number + 1,
      owner_user_id = l_act_attachment_rec.owner_user_id,
      attachment_used_by_id = l_act_attachment_rec.attachment_used_by_id,
      attachment_used_by = l_act_attachment_rec.attachment_used_by,
      version = l_act_attachment_rec.version,
      enabled_flag = l_act_attachment_rec.enabled_flag,
      can_fulfill_electronic_flag =
          l_act_attachment_rec.can_fulfill_electronic_flag,
      file_id = l_act_attachment_rec.file_id,
      file_name = l_act_attachment_rec.file_name,
      file_extension = l_act_attachment_rec.file_extension,
      document_id = l_act_attachment_rec.document_id,
      keywords = l_act_attachment_rec.keywords,
      display_width = l_act_attachment_rec.display_width,
      display_height = l_act_attachment_rec.display_height,
      display_location = l_act_attachment_rec.display_location,
      link_to = l_act_attachment_rec.link_to,
      link_url = l_act_attachment_rec.link_url,
      send_for_preview_flag = l_act_attachment_rec.send_for_preview_flag,
      attachment_type = l_act_attachment_rec.attachment_type,
      language_code = l_act_attachment_rec.language_code,
      application_id = l_act_attachment_rec.application_id,
      description = l_act_attachment_rec.description,
      default_style_sheet = l_act_attachment_rec.default_style_sheet,
      display_rule_id = l_act_attachment_rec.display_rule_id,
      display_url = l_act_attachment_rec.display_url,
      display_program = l_act_attachment_rec.display_program,
      attribute_category = l_act_attachment_rec.attribute_category,
      attribute1  = l_act_attachment_rec.attribute1,
      attribute2  = l_act_attachment_rec.attribute2,
      attribute3  = l_act_attachment_rec.attribute3,
      attribute4  = l_act_attachment_rec.attribute4,
      attribute5  = l_act_attachment_rec.attribute5,
      attribute6  = l_act_attachment_rec.attribute6,
      attribute7  = l_act_attachment_rec.attribute7,
      attribute8  = l_act_attachment_rec.attribute8,
      attribute9  = l_act_attachment_rec.attribute9,
      attribute10 = l_act_attachment_rec.attribute10,
      attribute11 = l_act_attachment_rec.attribute11,
      attribute12 = l_act_attachment_rec.attribute12,
      attribute13 = l_act_attachment_rec.attribute13,
      attribute14 = l_act_attachment_rec.attribute14,
      attribute15 = l_act_attachment_rec.attribute15,
	 display_text = l_act_attachment_rec.display_text,
	 alternate_text = l_act_attachment_rec.alternate_text,
	 secured_flag = l_act_attachment_rec.secured_flag,
	 attachment_sub_type = l_act_attachment_rec.attachment_sub_type
   WHERE attachment_id = l_act_attachment_rec.attachment_id
   AND object_version_number = l_act_attachment_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'JTF_AMV_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF (l_act_attachment_rec.attachment_used_by = G_USED_BY_ITEM) THEN
       update jtf_amv_items_b
       set last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.conc_login_id
       where item_id = l_act_attachment_rec.attachment_used_by_id;
   END IF;
   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get
   (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_act_attachment;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_act_attachment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get
      (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_act_attachment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get
      (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END update_act_attachment;
-------------------------------------------------------------------
-- PROCEDURE
--    lock_act_attachment
--
-- HISTORY
--    10/09/99  khung  Create.
--------------------------------------------------------------------
PROCEDURE lock_act_attachment
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,

   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2,

   p_act_attachment_id   IN  NUMBER,
   p_object_version      IN  NUMBER
) AS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'lock_act_attachment';

l_act_attachment_id      NUMBER;

CURSOR c_act_attachment IS
SELECT attachment_id
  FROM jtf_amv_attachments
 WHERE attachment_id = p_act_attachment_id
   AND object_version_number = p_object_version
   FOR UPDATE OF attachment_id NOWAIT;

BEGIN
   -------------------- initialize ------------------------
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
   OPEN c_act_attachment;
   FETCH c_act_attachment INTO l_act_attachment_id;
   IF (c_act_attachment%NOTFOUND) THEN
      CLOSE c_act_attachment;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'JTF_AMV_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_attachment;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get
   (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END lock_act_attachment;
---------------------------------------------------------------------
-- PROCEDURE
--    validate_act_attachment
--
-- HISTORY
--    10/09/99  khung  Create.
----------------------------------------------------------------------
PROCEDURE validate_act_attachment
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
   p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2,

   p_act_attachment_rec  IN  act_attachment_rec_type
) AS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'validate_act_attachment';
l_return_status VARCHAR2(1);

BEGIN
  ----------------------- initialize --------------------
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
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_act_attachment_items
      (
         p_act_attachment_rec => p_act_attachment_rec,
         p_validation_mode    => JTF_PLSQL_API.g_create,
         x_return_status      => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_act_attachment_record
      (
         p_act_attachment_rec => p_act_attachment_rec,
         p_complete_rec     => NULL,
         x_return_status    => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get
   (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END validate_act_attachment;

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_items
--
-- HISTORY
--    10/09/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE check_act_attachment_items
(
   p_act_attachment_rec        IN        act_attachment_rec_type,
   p_validation_mode        IN        VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status        OUT NOCOPY         VARCHAR2
) AS
BEGIN

   check_act_attachment_req_items
   (
      p_act_attachment_rec => p_act_attachment_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_act_attachment_uk_items
   (
      p_act_attachment_rec => p_act_attachment_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_act_attachment_fk_items
   (
      p_act_attachment_rec => p_act_attachment_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_act_attachment_lk_items
   (
      p_act_attachment_rec => p_act_attachment_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_act_attachment_fg_items
   (
      p_act_attachment_rec => p_act_attachment_rec,
      x_return_status      => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END check_act_attachment_items;
---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_record
--
-- HISTORY
--    10/09/99  khung  Create.
---------------------------------------------------------------------

PROCEDURE check_act_attachment_record
(
   p_act_attachment_rec        IN        act_attachment_rec_type,
   p_complete_rec        IN        act_attachment_rec_type := NULL,
   x_return_status        OUT NOCOPY         VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- do other record level checkings

END check_act_attachment_record;

---------------------------------------------------------------------
-- PROCEDURE
--    miss_act_attachment_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
-- History
--      06/20/00       rmajumda  Assigning values to three more columns
--                               display_text,alternate_text and
--                               attachment_sub_type
---------------------------------------------------------------------

PROCEDURE miss_act_attachment_rec
(
   x_act_attachment_rec  OUT NOCOPY  act_attachment_rec_type
) AS

BEGIN
   x_act_attachment_rec.attachment_id         := FND_API.g_miss_num;
   x_act_attachment_rec.last_update_date      := FND_API.g_miss_date;
   x_act_attachment_rec.last_updated_by       := FND_API.g_miss_num;
   x_act_attachment_rec.creation_date         := FND_API.g_miss_date;
   x_act_attachment_rec.created_by            := FND_API.g_miss_num;
   x_act_attachment_rec.last_update_login     := FND_API.g_miss_num;
   x_act_attachment_rec.object_version_number := FND_API.g_miss_num;
   x_act_attachment_rec.owner_user_id         := FND_API.g_miss_num;
   x_act_attachment_rec.attachment_used_by_id := FND_API.g_miss_num;
   x_act_attachment_rec.attachment_used_by    := FND_API.g_miss_char;
   x_act_attachment_rec.version               := FND_API.g_miss_char;
   x_act_attachment_rec.enabled_flag          := FND_API.g_miss_char;
   x_act_attachment_rec.can_fulfill_electronic_flag := FND_API.g_miss_char;
   x_act_attachment_rec.file_id               := FND_API.g_miss_num;
   x_act_attachment_rec.file_name             := FND_API.g_miss_char;
   x_act_attachment_rec.file_extension        := FND_API.g_miss_char;
   x_act_attachment_rec.keywords              := FND_API.g_miss_char;
   x_act_attachment_rec.document_id           := FND_API.g_miss_num;
   x_act_attachment_rec.display_width         := FND_API.g_miss_num;
   x_act_attachment_rec.display_height        := FND_API.g_miss_num;
   x_act_attachment_rec.display_location      := FND_API.g_miss_char;
   x_act_attachment_rec.link_to               := FND_API.g_miss_char;
   x_act_attachment_rec.link_url              := FND_API.g_miss_char;
   x_act_attachment_rec.send_for_preview_flag := FND_API.g_miss_char;
   x_act_attachment_rec.attachment_type       := FND_API.g_miss_char;
   x_act_attachment_rec.language_code         := FND_API.g_miss_char;
   x_act_attachment_rec.application_id        := FND_API.g_miss_num;
   x_act_attachment_rec.description           := FND_API.g_miss_char;
   x_act_attachment_rec.default_style_sheet   := FND_API.g_miss_char;
   x_act_attachment_rec.display_url           := FND_API.g_miss_char;
   x_act_attachment_rec.display_rule_id       := FND_API.g_miss_num;
   x_act_attachment_rec.display_program       := FND_API.g_miss_char;

   x_act_attachment_rec.attribute_category    := FND_API.g_miss_char;
   x_act_attachment_rec.attribute1            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute2            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute3            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute4            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute5            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute6            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute7            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute8            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute9            := FND_API.g_miss_char;
   x_act_attachment_rec.attribute10           := FND_API.g_miss_char;
   x_act_attachment_rec.attribute11           := FND_API.g_miss_char;
   x_act_attachment_rec.attribute12           := FND_API.g_miss_char;
   x_act_attachment_rec.attribute13           := FND_API.g_miss_char;
   x_act_attachment_rec.attribute14           := FND_API.g_miss_char;
   x_act_attachment_rec.attribute15           := FND_API.g_miss_char;
   x_act_attachment_rec.display_text          := FND_API.g_miss_char;
   x_act_attachment_rec.alternate_text        := FND_API.g_miss_char;
   x_act_attachment_rec.secured_flag          := FND_API.g_miss_char;
   x_act_attachment_rec.attachment_sub_type   := FND_API.g_miss_char;
END miss_act_attachment_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_act_attachment_rec
--
-- HISTORY
--    10/09/99  khung  Create.
---------------------------------------------------------------------
PROCEDURE complete_act_attachment_rec
(
   p_act_attachment_rec  IN   act_attachment_rec_type,
   x_complete_rec        OUT NOCOPY   act_attachment_rec_type
) AS
CURSOR c_act_attachment IS
SELECT *
FROM jtf_amv_attachments
WHERE attachment_id = p_act_attachment_rec.attachment_id;

l_act_attachment_rec  c_act_attachment%ROWTYPE;

BEGIN

   x_complete_rec := p_act_attachment_rec;

   OPEN c_act_attachment;
   FETCH c_act_attachment INTO l_act_attachment_rec;
   IF c_act_attachment%NOTFOUND THEN
      CLOSE c_act_attachment;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_AMV_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_attachment;

   IF p_act_attachment_rec.attachment_id = FND_API.g_miss_num THEN
      x_complete_rec.attachment_id := l_act_attachment_rec.attachment_id;
   END IF;

   IF p_act_attachment_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_act_attachment_rec.owner_user_id;
   END IF;

   IF p_act_attachment_rec.attachment_used_by_id = FND_API.g_miss_num THEN
      x_complete_rec.attachment_used_by_id := l_act_attachment_rec.attachment_used_by_id;
   END IF;

   IF p_act_attachment_rec.attachment_used_by = FND_API.g_miss_char THEN
      x_complete_rec.attachment_used_by := l_act_attachment_rec.attachment_used_by;
   END IF;

   IF p_act_attachment_rec.version = FND_API.g_miss_char THEN
      x_complete_rec.version := l_act_attachment_rec.version;
   END IF;

   IF p_act_attachment_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_act_attachment_rec.enabled_flag;
   END IF;

   IF p_act_attachment_rec.can_fulfill_electronic_flag = FND_API.g_miss_char THEN
      x_complete_rec.can_fulfill_electronic_flag := l_act_attachment_rec.can_fulfill_electronic_flag;
   END IF;

   IF p_act_attachment_rec.file_id = FND_API.g_miss_num THEN
      x_complete_rec.file_id := l_act_attachment_rec.file_id;
   END IF;

   IF p_act_attachment_rec.file_name = FND_API.g_miss_char THEN
      x_complete_rec.file_name := l_act_attachment_rec.file_name;
   END IF;

   IF p_act_attachment_rec.file_extension = FND_API.g_miss_char THEN
      x_complete_rec.file_extension := l_act_attachment_rec.file_extension;
   END IF;

   IF p_act_attachment_rec.document_id = FND_API.g_miss_num THEN
      x_complete_rec.document_id := l_act_attachment_rec.document_id;
   END IF;

   IF p_act_attachment_rec.keywords = FND_API.g_miss_char THEN
      x_complete_rec.keywords := l_act_attachment_rec.keywords;
   END IF;

   IF p_act_attachment_rec.display_width = FND_API.g_miss_num THEN
      x_complete_rec.display_width := l_act_attachment_rec.display_width;
   END IF;

   IF p_act_attachment_rec.display_height = FND_API.g_miss_num THEN
      x_complete_rec.display_height := l_act_attachment_rec.display_height;
   END IF;

   IF p_act_attachment_rec.display_location = FND_API.g_miss_char THEN
      x_complete_rec.display_location := l_act_attachment_rec.display_location;
   END IF;

   IF p_act_attachment_rec.link_to = FND_API.g_miss_char THEN
      x_complete_rec.link_to := l_act_attachment_rec.link_to;
   END IF;

   IF p_act_attachment_rec.link_url = FND_API.g_miss_char THEN
      x_complete_rec.link_url := l_act_attachment_rec.link_url;
   END IF;

   IF p_act_attachment_rec.send_for_preview_flag = FND_API.g_miss_char THEN
      x_complete_rec.send_for_preview_flag := l_act_attachment_rec.send_for_preview_flag;
   END IF;

   IF p_act_attachment_rec.attachment_type = FND_API.g_miss_char THEN
      x_complete_rec.attachment_type := l_act_attachment_rec.attachment_type;
   END IF;

   IF p_act_attachment_rec.language_code = FND_API.g_miss_char THEN
      x_complete_rec.language_code := l_act_attachment_rec.language_code;
   END IF;

   IF p_act_attachment_rec.application_id = FND_API.g_miss_num THEN
      x_complete_rec.application_id := l_act_attachment_rec.application_id;
   END IF;

   IF p_act_attachment_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_act_attachment_rec.description;
   END IF;

   IF p_act_attachment_rec.default_style_sheet = FND_API.g_miss_char THEN
      x_complete_rec.default_style_sheet := l_act_attachment_rec.default_style_sheet;
   END IF;

   IF p_act_attachment_rec.display_url = FND_API.g_miss_char THEN
      x_complete_rec.display_url := l_act_attachment_rec.display_url;
   END IF;

   IF p_act_attachment_rec.display_rule_id = FND_API.g_miss_num THEN
      x_complete_rec.display_rule_id := l_act_attachment_rec.display_rule_id;
   END IF;

   IF p_act_attachment_rec.display_program = FND_API.g_miss_char THEN
      x_complete_rec.display_program := l_act_attachment_rec.display_program;
   END IF;

   IF p_act_attachment_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_act_attachment_rec.attribute_category;
   END IF;

   IF p_act_attachment_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_act_attachment_rec.attribute1;
   END IF;

   IF p_act_attachment_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_act_attachment_rec.attribute2;
   END IF;

   IF p_act_attachment_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_act_attachment_rec.attribute3;
   END IF;

   IF p_act_attachment_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_act_attachment_rec.attribute4;
   END IF;

   IF p_act_attachment_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_act_attachment_rec.attribute5;
   END IF;

   IF p_act_attachment_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_act_attachment_rec.attribute6;
   END IF;

   IF p_act_attachment_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_act_attachment_rec.attribute7;
   END IF;

   IF p_act_attachment_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_act_attachment_rec.attribute8;
   END IF;

   IF p_act_attachment_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_act_attachment_rec.attribute9;
   END IF;

   IF p_act_attachment_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_act_attachment_rec.attribute10;
   END IF;

   IF p_act_attachment_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_act_attachment_rec.attribute11;
   END IF;

   IF p_act_attachment_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_act_attachment_rec.attribute12;
   END IF;

   IF p_act_attachment_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_act_attachment_rec.attribute13;
   END IF;

   IF p_act_attachment_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_act_attachment_rec.attribute14;
   END IF;

   IF p_act_attachment_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_act_attachment_rec.attribute15;
   END IF;

   IF p_act_attachment_rec.display_text = FND_API.g_miss_char THEN
      x_complete_rec.display_text := l_act_attachment_rec.display_text;
   END IF;

   IF p_act_attachment_rec.alternate_text = FND_API.g_miss_char THEN
      x_complete_rec.alternate_text := l_act_attachment_rec.alternate_text;
   END IF;

   IF p_act_attachment_rec.secured_flag = FND_API.g_miss_char THEN
      x_complete_rec.secured_flag := l_act_attachment_rec.secured_flag;
   END IF;

   IF p_act_attachment_rec.attachment_sub_type = FND_API.g_miss_char THEN
      x_complete_rec.attachment_sub_type :=
				    l_act_attachment_rec.attachment_sub_type ;
   END IF;

END complete_act_attachment_rec;

END jtf_amv_attachment_pub;

/
