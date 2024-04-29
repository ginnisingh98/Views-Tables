--------------------------------------------------------
--  DDL for Package Body JTF_TASK_PHONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_PHONES_PKG" AS
/* $Header: jtftkphb.pls 115.20 2002/12/04 21:49:07 cjang ship $ */
   PROCEDURE insert_row (
      x_rowid                IN OUT NOCOPY   VARCHAR2,
      x_task_phone_id        IN       NUMBER,
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
      x_attribute4           IN       VARCHAR2,
      x_attribute3           IN       VARCHAR2,
      x_task_contact_id      IN       NUMBER,
      x_attribute1           IN       VARCHAR2,
      x_attribute2           IN       VARCHAR2,
      x_phone_id             IN       NUMBER,
      x_creation_date        IN       DATE,
      x_created_by           IN       NUMBER,
      x_last_update_date     IN       DATE,
      x_last_updated_by      IN       NUMBER,
      x_last_update_login    IN       NUMBER,
      x_owner_table_name     IN       VARCHAR2 DEFAULT 'JTF_TASK_CONTACTS',
      x_primary_flag         IN       VARCHAR2 DEFAULT NULL
   )
   IS
      CURSOR c
      IS
         SELECT ROWID
           FROM jtf_task_phones
          WHERE task_phone_id = x_task_phone_id;
   BEGIN
      INSERT INTO jtf_task_phones (
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
                     last_update_date,
                     created_by,
                     creation_date,
                     last_updated_by,
                     attribute4,
                     task_phone_id,
                     attribute3,
                     last_update_login,
                     task_contact_id,
                     phone_id,
                     attribute1,
                     attribute2,
                     object_version_number,
                     owner_table_name,
                     primary_flag
                  )
           VALUES (
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
              x_last_update_date,
              x_created_by,
              x_creation_date,
              x_last_updated_by,
              x_attribute4,
              x_task_phone_id,
              x_attribute3,
              x_last_update_login,
              x_task_contact_id,
              x_phone_id,
              x_attribute1,
              x_attribute2,
              1,
              x_owner_table_name,
              x_primary_flag
           );
      OPEN c;
      FETCH c INTO  x_rowid;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;
   END insert_row;

   PROCEDURE lock_row (
      x_task_phone_id           IN   NUMBER,
      x_object_version_number   IN   NUMBER
   )
   IS
      CURSOR c1
      IS
         SELECT object_version_number
           FROM jtf_task_phones
          WHERE task_phone_id = x_task_phone_id
            FOR UPDATE OF task_phone_id NOWAIT;

      tlinfo   c1%ROWTYPE;
   BEGIN
      OPEN c1;
      FETCH c1 INTO tlinfo;

      IF (c1%NOTFOUND)
      THEN
         CLOSE c1;
         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;

      CLOSE c1;

      IF (tlinfo.object_version_number = x_object_version_number)
      THEN
         NULL;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END lock_row;

   PROCEDURE update_row (
      x_task_phone_id           IN   NUMBER,
      x_object_version_number   IN   NUMBER,
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
      x_attribute4              IN   VARCHAR2,
      x_attribute3              IN   VARCHAR2,
      x_task_contact_id         IN   NUMBER,
      x_attribute1              IN   VARCHAR2,
      x_attribute2              IN   VARCHAR2,
      x_phone_id                IN   NUMBER,
      x_last_update_date        IN   DATE,
      x_last_updated_by         IN   NUMBER,
      x_last_update_login       IN   NUMBER,
      x_owner_table_name        IN   VARCHAR2 DEFAULT 'JTF_TASK_CONTACTS',
      x_primary_flag            IN   VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   )
   IS
   BEGIN
      UPDATE jtf_task_phones
         SET object_version_number = x_object_version_number,
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
             attribute4 = x_attribute4,
             attribute3 = x_attribute3,
             task_contact_id = x_task_contact_id,
             attribute1 = x_attribute1,
             attribute2 = x_attribute2,
             phone_id = x_phone_id,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             owner_table_name = x_owner_table_name,
             primary_flag = x_primary_flag
       WHERE task_phone_id = x_task_phone_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END update_row;

   PROCEDURE delete_row (x_task_phone_id IN NUMBER)
   IS
   BEGIN
      DELETE
        FROM jtf_task_phones
       WHERE task_phone_id = x_task_phone_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END delete_row;
END jtf_task_phones_pkg;

/
