--------------------------------------------------------
--  DDL for Package Body JTF_STATE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_STATE_RULES_PKG" AS
/* $Header: jtftksrb.pls 115.16 2002/12/04 22:14:34 cjang ship $ */
   PROCEDURE insert_row (
      x_rowid                IN OUT NOCOPY  VARCHAR2,
      x_rule_id              IN       NUMBER,
      x_state_type           IN       VARCHAR2,
      x_attribute1           IN       VARCHAR2,
      x_attribute2           IN       VARCHAR2,
      x_attribute3           IN       VARCHAR2,
      x_attribute4           IN       VARCHAR2,
      x_attribute5           IN       VARCHAR2,
      x_attribute6           IN       VARCHAR2,
      x_attribute7           IN       VARCHAR2,
      x_attribute8           IN       VARCHAR2,
      x_attribute9           IN       VARCHAR2,
      x_attribute10          IN       VARCHAR2,
      x_attribute11          IN       VARCHAR2,
      x_attribute12          IN       VARCHAR2,
      x_attribute13          IN       VARCHAR2,
      x_attribute14          IN       VARCHAR2,
      x_attribute15          IN       VARCHAR2,
      x_attribute_category   IN       VARCHAR2,
      x_rule_name            IN       VARCHAR2,
      x_creation_date        IN       DATE,
      x_created_by           IN       NUMBER,
      x_last_update_date     IN       DATE,
      x_last_updated_by      IN       NUMBER,
      x_last_update_login    IN       NUMBER,
      x_application_id       IN       NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT ROWID
           FROM jtf_state_rules_b
          WHERE rule_id = x_rule_id;
   BEGIN
      INSERT INTO jtf_state_rules_b (
                     rule_id,
                     state_type,
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
                     attribute_category,
                     creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     object_version_number,
                     application_id
                  )
           VALUES (
              x_rule_id,
              x_state_type,
              x_attribute1,
              x_attribute2,
              x_attribute3,
              x_attribute4,
              x_attribute5,
              x_attribute6,
              x_attribute7,
              x_attribute8,
              x_attribute9,
              x_attribute10,
              x_attribute11,
              x_attribute12,
              x_attribute13,
              x_attribute14,
              x_attribute15,
              x_attribute_category,
              x_creation_date,
              x_created_by,
              x_last_update_date,
              x_last_updated_by,
              x_last_update_login,
              1,
              x_application_id
           );
      INSERT INTO jtf_state_rules_tl
                  (rule_id,
                   rule_name,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   language,
                   source_lang
                  )
         SELECT x_rule_id,
                x_rule_name,
                x_created_by,
                x_creation_date,
                x_last_updated_by,
                x_last_update_date,
                x_last_update_login,
                l.language_code,
                USERENV ('LANG')
           FROM fnd_languages l
          WHERE l.installed_flag IN ('I', 'B')
            AND NOT EXISTS (SELECT NULL
                              FROM jtf_state_rules_tl t
                             WHERE t.rule_id = x_rule_id
                               AND t.language = l.language_code);
      OPEN c;
      FETCH c INTO x_rowid;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;
   END insert_row;

   PROCEDURE lock_row (x_rule_id IN NUMBER, x_object_version_number IN NUMBER)
   IS
      CURSOR c
      IS
         SELECT object_version_number
           FROM jtf_state_rules_vl
          WHERE rule_id = x_rule_id
            FOR UPDATE OF rule_id NOWAIT;

      recinfo   c%ROWTYPE;
   BEGIN
      OPEN c;
      FETCH c INTO recinfo;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;
         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;

      CLOSE c;

      IF (recinfo.object_version_number = x_object_version_number)
      THEN
         NULL;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END lock_row;

   PROCEDURE update_row (
      x_rule_id                 IN   NUMBER,
      x_object_version_number   IN   NUMBER,
      x_state_type              IN   VARCHAR2,
      x_attribute1              IN   VARCHAR2,
      x_attribute2              IN   VARCHAR2,
      x_attribute3              IN   VARCHAR2,
      x_attribute4              IN   VARCHAR2,
      x_attribute5              IN   VARCHAR2,
      x_attribute6              IN   VARCHAR2,
      x_attribute7              IN   VARCHAR2,
      x_attribute8              IN   VARCHAR2,
      x_attribute9              IN   VARCHAR2,
      x_attribute10             IN   VARCHAR2,
      x_attribute11             IN   VARCHAR2,
      x_attribute12             IN   VARCHAR2,
      x_attribute13             IN   VARCHAR2,
      x_attribute14             IN   VARCHAR2,
      x_attribute15             IN   VARCHAR2,
      x_attribute_category      IN   VARCHAR2,
      x_rule_name               IN   VARCHAR2,
      x_last_update_date        IN   DATE,
      x_last_updated_by         IN   NUMBER,
      x_last_update_login       IN   NUMBER,
      x_application_id          IN   NUMBER
   )
   IS
   BEGIN
      UPDATE jtf_state_rules_b
         SET state_type = x_state_type,
             object_version_number = x_object_version_number + 1,
             attribute1 = x_attribute1,
             attribute2 = x_attribute2,
             attribute3 = x_attribute3,
             attribute4 = x_attribute4,
             attribute5 = x_attribute5,
             attribute6 = x_attribute6,
             attribute7 = x_attribute7,
             attribute8 = x_attribute8,
             attribute9 = x_attribute9,
             attribute10 = x_attribute10,
             attribute11 = x_attribute11,
             attribute12 = x_attribute12,
             attribute13 = x_attribute13,
             attribute14 = x_attribute14,
             attribute15 = x_attribute15,
             attribute_category = x_attribute_category,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             application_id = x_application_id
       WHERE rule_id = x_rule_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE jtf_state_rules_tl
         SET rule_name = x_rule_name,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             source_lang = USERENV ('LANG')
       WHERE rule_id = x_rule_id
         AND USERENV ('LANG') IN (language, source_lang);

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_row;

   PROCEDURE delete_row (x_rule_id IN NUMBER)
   IS
   BEGIN
      DELETE
        FROM jtf_state_rules_tl
       WHERE rule_id = x_rule_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      DELETE
        FROM jtf_state_rules_b
       WHERE rule_id = x_rule_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END delete_row;

   PROCEDURE add_language
   IS
   BEGIN
      DELETE
        FROM jtf_state_rules_tl t
       WHERE NOT EXISTS (SELECT NULL
                           FROM jtf_state_rules_b b
                          WHERE b.rule_id = t.rule_id);
      UPDATE jtf_state_rules_tl t
         SET (rule_name) = ( SELECT b.rule_name
                               FROM jtf_state_rules_tl b
                              WHERE b.rule_id = t.rule_id
                                AND b.language = t.source_lang)
       WHERE (t.rule_id, t.language) IN
                (SELECT subt.rule_id, subt.language
                   FROM jtf_state_rules_tl subb, jtf_state_rules_tl subt
                  WHERE subb.rule_id = subt.rule_id
                    AND subb.language = subt.source_lang
                    AND (subb.rule_name <> subt.rule_name));
      INSERT INTO jtf_state_rules_tl
                  (rule_id,
                   rule_name,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   language,
                   source_lang
                  )
         SELECT b.rule_id,
                b.rule_name,
                b.created_by,
                b.creation_date,
                b.last_updated_by,
                b.last_update_date,
                b.last_update_login,
                l.language_code,
                b.source_lang
           FROM jtf_state_rules_tl b, fnd_languages l
          WHERE l.installed_flag IN ('I', 'B')
            AND b.language = USERENV ('LANG')
            AND NOT EXISTS (SELECT NULL
                              FROM jtf_state_rules_tl t
                             WHERE t.rule_id = b.rule_id
                               AND t.language = l.language_code);
   END add_language;

   PROCEDURE translate_row (
      x_rule_id     IN   NUMBER,
      x_rule_name   IN   VARCHAR2,
      x_owner       IN   VARCHAR2
   )
   IS
      l_user_id   NUMBER := 0;
   BEGIN
      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;

      UPDATE jtf_state_rules_tl
         SET rule_name = NVL (x_rule_name, rule_name),
             last_update_date = SYSDATE,
             last_update_login = 0,
             source_lang = USERENV ('LANG'),
             last_updated_by = l_user_id
       WHERE rule_id = x_rule_id
         AND USERENV ('LANG') IN (language, source_lang);

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END translate_row;
END jtf_state_rules_pkg;

/
