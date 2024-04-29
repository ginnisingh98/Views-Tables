--------------------------------------------------------
--  DDL for Package Body JTF_TASK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_TYPES_PKG" AS
/* $Header: jtftktyb.pls 120.2.12010000.2 2012/02/22 14:09:15 srguntur ship $ */
   PROCEDURE insert_row (
      x_rowid                IN OUT NOCOPY   VARCHAR2,
      x_task_type_id         IN       NUMBER,
      x_start_date_active    IN       DATE,
      x_end_date_active      IN       DATE,
      x_seeded_flag          IN       VARCHAR2,
      x_workflow             IN       VARCHAR2,
      x_planned_effort       IN       NUMBER,
      x_planned_effort_uom   IN       VARCHAR2,
      x_schedule_flag        IN       VARCHAR2,
      x_notification_flag    IN       VARCHAR2,
      x_private_flag         IN       VARCHAR2,
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
      x_name                 IN       VARCHAR2,
      x_description          IN       VARCHAR2,
      x_creation_date        IN       DATE,
      x_created_by           IN       NUMBER,
      x_last_update_date     IN       DATE,
      x_last_updated_by      IN       NUMBER,
      x_last_update_login    IN       NUMBER,
      x_rule                 IN       VARCHAR2,
      x_workflow_type	     IN       VARCHAR2 	default  null,
      x_spares_allowed_flag  IN       VARCHAR2
   )
   IS
      CURSOR c
      IS
         SELECT ROWID
           FROM jtf_task_types_b
          WHERE task_type_id = x_task_type_id;
   BEGIN
      INSERT INTO jtf_task_types_b (
                     task_type_id,
                     object_version_number,
                     start_date_active,
                     end_date_active,
                     seeded_flag,
                     workflow,
                     planned_effort,
                     planned_effort_uom,
                     schedule_flag,
                     notification_flag,
                     private_flag,
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
                     rule,
                     workflow_type,
		     spares_allowed_flag
                  )
           VALUES (
              x_task_type_id,
              1,
              x_start_date_active,
              x_end_date_active,
              x_seeded_flag,
              x_workflow,
              x_planned_effort,
              x_planned_effort_uom,
              x_schedule_flag,
              x_notification_flag,
              x_private_flag,
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
              x_rule,
              x_workflow_type,
	      x_spares_allowed_flag
           );
      INSERT INTO jtf_task_types_tl
                  (task_type_id,
                   name,
                   description,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   language,
                   source_lang
                  )
         SELECT x_task_type_id,
                x_name,
                x_description,
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
                              FROM jtf_task_types_tl t
                             WHERE t.task_type_id = x_task_type_id
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

   PROCEDURE lock_row (
      x_task_type_id            IN   NUMBER,
      x_object_version_number   IN   NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT object_version_number
           FROM jtf_task_types_vl
          WHERE task_type_id = x_task_type_id
            AND object_version_number = x_object_version_number
            FOR UPDATE OF task_type_id NOWAIT;

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

      IF recinfo.object_version_number = x_object_version_number
      THEN
         NULL;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
         NULL;
      END IF;
   END lock_row;

   PROCEDURE update_row (
      x_task_type_id            IN   NUMBER,
      x_object_version_number   IN   NUMBER,
      x_start_date_active       IN   DATE,
      x_end_date_active         IN   DATE,
      x_seeded_flag             IN   VARCHAR2,
      x_workflow                IN   VARCHAR2,
      x_planned_effort          IN   NUMBER,
      x_planned_effort_uom      IN   VARCHAR2,
      x_schedule_flag           IN   VARCHAR2,
      x_notification_flag       IN   VARCHAR2,
      x_private_flag            IN   VARCHAR2,
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
      x_name                    IN   VARCHAR2,
      x_description             IN   VARCHAR2,
      x_last_update_date        IN   DATE,
      x_last_updated_by         IN   NUMBER,
      x_last_update_login       IN   NUMBER,
      x_rule                    IN   VARCHAR2,
      x_workflow_type	        IN   VARCHAR2 DEFAULT NULL,
      x_spares_allowed_flag     IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE jtf_task_types_b
         SET start_date_active = x_start_date_active,
             object_version_number = x_object_version_number + 1,
             end_date_active = x_end_date_active,
             seeded_flag = x_seeded_flag,
             workflow = x_workflow,
             planned_effort = x_planned_effort,
             planned_effort_uom = x_planned_effort_uom,
             schedule_flag = x_schedule_flag,
             notification_flag = x_notification_flag,
             private_flag = x_private_flag,
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
             rule = x_rule,
             workflow_type = x_workflow_type,
	     spares_allowed_flag = x_spares_allowed_flag
       WHERE task_type_id = x_task_type_id;

      --and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER ;
      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

     -- Added Index Hint on 30/05/2006 for bug# 5213367
      UPDATE /*+ INDEX(a JTF_TASK_TYPES_TL_U1) */ jtf_task_types_tl a
         SET a.name = x_name,
             a.description = x_description,
             a.last_update_date = x_last_update_date,
             a.last_updated_by = x_last_updated_by,
             a.last_update_login = x_last_update_login,
             a.source_lang = USERENV ('LANG')
       WHERE a.task_type_id = x_task_type_id
         AND USERENV ('LANG') IN (a.language, a.source_lang);

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_row;

   PROCEDURE delete_row (x_task_type_id IN NUMBER)
   IS
   BEGIN
      DELETE
        FROM jtf_task_types_tl
       WHERE task_type_id = x_task_type_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      DELETE
        FROM jtf_task_types_b
       WHERE task_type_id = x_task_type_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END delete_row;

   PROCEDURE add_language
   IS
   BEGIN

      /* Solving Perf. Bug 3723927*/
     /* The following delete and update statements are commented out */
     /* as a quick workaround to fix the time-consuming table handler issue */
     /*
      DELETE
        FROM jtf_task_types_tl t
       WHERE NOT EXISTS (SELECT NULL
                           FROM jtf_task_types_b b
                          WHERE b.task_type_id = t.task_type_id);
      UPDATE jtf_task_types_tl t
         SET (name, description) = ( SELECT b.name, b.description
                                       FROM jtf_task_types_tl b
                                      WHERE b.task_type_id = t.task_type_id
                                        AND b.language = t.source_lang)
       WHERE (t.task_type_id, t.language) IN
                (SELECT subt.task_type_id, subt.language
                   FROM jtf_task_types_tl subb, jtf_task_types_tl subt
                  WHERE subb.task_type_id = subt.task_type_id
                    AND subb.language = subt.source_lang
                    AND (  subb.name <> subt.name
                        OR subb.description <> subt.description
                        OR (   subb.description IS NULL
                           AND subt.description IS NOT NULL)
                        OR (   subb.description IS NOT NULL
                           AND subt.description IS NULL)));
      */

      INSERT INTO jtf_task_types_tl
                  (task_type_id,
                   name,
                   description,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   language,
                   source_lang
                  )
         SELECT /*+ INDEX(b JTF_TASK_TYPES_TL_U1) INDEX (l FND_LANGUAGES_N1) */  -- Added Index Hint on 30/05/2006 for bug# 5213367
                b.task_type_id,
                b.name,
                b.description,
                b.created_by,
                b.creation_date,
                b.last_updated_by,
                b.last_update_date,
                b.last_update_login,
                l.language_code,
                b.source_lang
           FROM jtf_task_types_tl b, fnd_languages l
          WHERE l.installed_flag IN ('I', 'B')
            AND b.language = USERENV ('LANG')
            AND NOT EXISTS (SELECT NULL
                              FROM jtf_task_types_tl t
                             WHERE t.task_type_id = b.task_type_id
                               AND t.language = l.language_code);
   END add_language;

   PROCEDURE translate_row (
      x_task_type_id   IN   VARCHAR2,
      x_name           IN   VARCHAR2,
      x_description    IN   VARCHAR2,
      x_owner in varchar2
   )
   IS
   l_user_id                 NUMBER := 0;
   BEGIN
      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;

      -- Added Index Hint on 30/05/2006 for bug# 5213367
      UPDATE /*+ INDEX(a JTF_TASK_TYPES_TL_U1) */ jtf_task_types_tl a
         SET a.name = NVL (x_name, a.name),
             a.description = NVL (x_description, a.description),
             a.last_update_date = SYSDATE,
             a.last_update_login = 0,
             a.source_lang = USERENV ('LANG'),
             a.last_updated_by  = l_user_id
       WHERE a.task_type_id = x_task_type_id
         AND USERENV ('LANG') IN (a.language, a.source_lang);

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END translate_row;

   PROCEDURE load_row (
      x_task_type_id         IN   NUMBER,
      x_start_date_active    IN   DATE,
      x_end_date_active      IN   DATE,
      x_seeded_flag          IN   VARCHAR2,
      x_workflow             IN   VARCHAR2,
      x_planned_effort       IN   NUMBER,
      x_planned_effort_uom   IN   VARCHAR2,
      x_schedule_flag        IN   VARCHAR2,
      x_notification_flag    IN   VARCHAR2,
      x_private_flag         IN   VARCHAR2,
      x_attribute1           IN   VARCHAR2,
      x_attribute2           IN   VARCHAR2,
      x_attribute3           IN   VARCHAR2,
      x_attribute4           IN   VARCHAR2,
      x_attribute5           IN   VARCHAR2,
      x_attribute6           IN   VARCHAR2,
      x_attribute7           IN   VARCHAR2,
      x_attribute8           IN   VARCHAR2,
      x_attribute9           IN   VARCHAR2,
      x_attribute10          IN   VARCHAR2,
      x_attribute11          IN   VARCHAR2,
      x_attribute12          IN   VARCHAR2,
      x_attribute13          IN   VARCHAR2,
      x_attribute14          IN   VARCHAR2,
      x_attribute15          IN   VARCHAR2,
      x_attribute_category   IN   VARCHAR2,
      x_name                 IN   VARCHAR2,
      x_description          IN   VARCHAR2,
      x_creation_date        IN   DATE,
      x_created_by           IN   NUMBER,
      x_last_update_date     IN   DATE,
      x_last_updated_by      IN   NUMBER,
      x_last_update_login    IN   NUMBER,
      x_rule                 IN   VARCHAR2,
      x_owner                IN   VARCHAR2,
      x_workflow_type	     IN   VARCHAR2,
      x_spares_allowed_flag  IN   VARCHAR2
   )
   AS
      l_user_id                 NUMBER := 0;
      l_task_type_id            NUMBER;
      l_rowid                   ROWID;
      l_object_version_number   NUMBER;
   BEGIN
      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;

      SELECT task_type_id, object_version_number
        INTO l_task_type_id, l_object_version_number
        FROM jtf_task_types_b
       WHERE task_type_id = x_task_type_id;




 UPDATE jtf_task_types_b
      SET start_date_active = x_start_date_active,
      object_version_number = l_object_version_number + 1,
      end_date_active = x_end_date_active,
      seeded_flag = x_seeded_flag,
      workflow = x_workflow,
      planned_effort = x_planned_effort,
      planned_effort_uom = x_planned_effort_uom,
      schedule_flag = x_schedule_flag,
      notification_flag = x_notification_flag,
      private_flag = x_private_flag,
      last_update_date = sysdate,
      last_updated_by = l_user_id,
      last_update_login = 0,
      rule = x_rule,
      workflow_type = x_workflow_type,
      spares_allowed_flag = x_spares_allowed_flag
      WHERE task_type_id = l_task_type_id;

      -- Added Index Hint on 30/05/2006 for bug# 5213367
      UPDATE /*+ INDEX(a JTF_TASK_TYPES_TL_U1) */ jtf_task_types_tl a
       SET a.name = x_name,
       a.description = x_description,
       a.last_update_date = sysdate,
       a.last_updated_by = l_user_id,
       a.last_update_login = 0,
       a.source_lang = USERENV ('LANG')
       WHERE a.task_type_id = l_task_type_id
       AND USERENV ('LANG') IN (a.language, a.source_lang);



    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         jtf_task_types_pkg.insert_row (
            x_rowid => l_rowid,
            x_rule => x_rule,
            x_task_type_id => x_task_type_id,
            x_start_date_active => x_start_date_active,
            x_end_date_active => x_end_date_active,
            x_seeded_flag => x_seeded_flag,
            x_workflow => x_workflow,
            x_planned_effort => x_planned_effort,
            x_planned_effort_uom => x_planned_effort_uom,
            x_schedule_flag => x_schedule_flag,
            x_notification_flag => x_notification_flag,
            x_private_flag => x_private_flag,
            x_attribute1 => x_attribute1,
            x_attribute2 => x_attribute2,
            x_attribute3 => x_attribute3,
            x_attribute4 => x_attribute4,
            x_attribute5 => x_attribute5,
            x_attribute6 => x_attribute6,
            x_attribute7 => x_attribute7,
            x_attribute8 => x_attribute8,
            x_attribute9 => x_attribute9,
            x_attribute10 => x_attribute10,
            x_attribute11 => x_attribute11,
            x_attribute12 => x_attribute12,
            x_attribute13 => x_attribute13,
            x_attribute14 => x_attribute14,
            x_attribute15 => x_attribute15,
            x_attribute_category => x_attribute_category,
            x_name => x_name,
            x_description => x_description,
            x_creation_date => SYSDATE,
            x_created_by => l_user_id,
            x_last_update_date => SYSDATE,
            x_last_updated_by => l_user_id,
            x_last_update_login => 0,
            x_workflow_type => x_workflow_type,
	    x_spares_allowed_flag => x_spares_allowed_flag
         );


   END;
END jtf_task_types_pkg;

/
