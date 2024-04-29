--------------------------------------------------------
--  DDL for Package Body JTF_TASK_PHONES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_PHONES_PUB" AS
/* $Header: jtfptkpb.pls 115.26 2002/12/04 21:04:09 cjang ship $ */
   g_pkg_name   VARCHAR2(30) := 'JTF_TASK_PHONES_PUB';

   PROCEDURE do_unmark_primary_flag_create (
      p_task_contact_id    IN   NUMBER,
      p_phone_id           IN   NUMBER,
      p_owner_table_name   IN   VARCHAR2
   );

   PROCEDURE do_unmark_primary_flag_update (
      p_task_phone_id   IN   NUMBER,
      p_phone_id        IN   NUMBER,
      l_contact_id      IN   NUMBER
   );

    ---------------------------------------
    -- For fixing a bug 2644132
    FUNCTION is_this_first_phone(p_task_contact_id IN NUMBER
                                ,p_owner_table_name IN VARCHAR2)
    RETURN BOOLEAN
    IS
        CURSOR c_task_phone (b_task_contact_id NUMBER, b_owner_table_name VARCHAR2) IS
        SELECT '1'
          FROM jtf_task_phones
         WHERE task_contact_id = b_task_contact_id
           AND owner_table_name = b_owner_table_name;

        l_dummy VARCHAR2(1);
        l_this_is_first BOOLEAN;
    BEGIN
        OPEN c_task_phone(p_task_contact_id, p_owner_table_name);
        FETCH c_task_phone INTO l_dummy;

        IF c_task_phone%NOTFOUND
        THEN
            l_this_is_first := TRUE;
        ELSE
            l_this_is_first := FALSE;
        END IF;
        CLOSE c_task_phone;

        RETURN l_this_is_first;

    END is_this_first_phone;
    ---------------------------------------

   PROCEDURE create_task_phones (
      p_api_version          IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2,
      p_commit               IN       VARCHAR2,
      p_task_contact_id      IN       NUMBER,
      p_phone_id             IN       NUMBER,
      x_task_phone_id        OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      p_attribute1           IN       VARCHAR2,
      p_attribute2           IN       VARCHAR2,
      p_attribute3           IN       VARCHAR2,
      p_attribute4           IN       VARCHAR2,
      p_attribute5           IN       VARCHAR2,
      p_attribute6           IN       VARCHAR2,
      p_attribute7           IN       VARCHAR2,
      p_attribute8           IN       VARCHAR2,
      p_attribute9           IN       VARCHAR2,
      p_attribute10          IN       VARCHAR2,
      p_attribute11          IN       VARCHAR2,
      p_attribute12          IN       VARCHAR2,
      p_attribute13          IN       VARCHAR2,
      p_attribute14          IN       VARCHAR2,
      p_attribute15          IN       VARCHAR2,
      p_attribute_category   IN       VARCHAR2,
      p_owner_table_name     IN       VARCHAR2,
      p_primary_flag         IN       VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER                             := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_PHONES';
      l_rowid                  ROWID;
      l_task_id                jtf_tasks_b.task_id%TYPE;
      l_contact_id             jtf_task_contacts.contact_id%TYPE;
      l_task_phone_id          jtf_task_phones.task_phone_id%TYPE;
      x                        CHAR;

      l_primary_flag VARCHAR2(1) := p_primary_flag; -- For fixing a bug 2644132

      CURSOR c_jtf_task_phones (l_rowid IN ROWID)
      IS
         SELECT 1
           FROM jtf_task_phones
          WHERE ROWID = l_rowid;
   BEGIN
      SAVEPOINT create_task_phones_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      jtf_task_utl.validate_phones_table (
         p_owner_table_name => p_owner_table_name,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_missing_phone_id (
         p_task_phone_id => p_phone_id,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_missing_contact_id (
         p_task_contact_id => p_task_contact_id,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_contact_point (
         p_contact_id => p_task_contact_id,
         p_phone_id => p_phone_id,
         x_return_status => x_return_status,
         p_owner_table_name => p_owner_table_name
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
         p_flag_name => jtf_task_utl.get_translated_lookup (
                           'JTF_TASK_TRANSLATED_MESSAGES',
                           'PRIMARY_FLAG'
                        ),
         p_flag_value => p_primary_flag,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      SELECT jtf_task_phones_s.nextval
        INTO l_task_phone_id
        FROM dual;

--Unmark the previous contact points with primary flag = 'Y'.
      IF p_primary_flag = jtf_task_utl.g_yes
      THEN
         do_unmark_primary_flag_create (
            p_task_contact_id,
            p_phone_id,
            p_owner_table_name
         );
      END IF;

      -------------------------------------------
      -- For fixing a bug 2644132
      IF is_this_first_phone(p_task_contact_id, p_owner_table_name)
      THEN
         l_primary_flag := jtf_task_utl.g_yes;
      END IF;
      -------------------------------------------

      jtf_task_phones_pkg.insert_row (
         x_rowid => l_rowid,
         x_task_phone_id => l_task_phone_id,
         x_task_contact_id => p_task_contact_id,
         x_attribute1 => p_attribute1,
         x_attribute2 => p_attribute2,
         x_attribute3 => p_attribute3,
         x_attribute4 => p_attribute4,
         x_attribute5 => p_attribute5,
         x_attribute6 => p_attribute6,
         x_attribute7 => p_attribute7,
         x_attribute8 => p_attribute8,
         x_attribute9 => p_attribute9,
         x_attribute10 => p_attribute10,
         x_attribute11 => p_attribute11,
         x_attribute12 => p_attribute12,
         x_attribute13 => p_attribute13,
         x_attribute14 => p_attribute14,
         x_attribute15 => p_attribute15,
         x_attribute_category => p_attribute_category,
         x_phone_id => p_phone_id,
         x_creation_date => SYSDATE,
         x_created_by => jtf_task_utl.created_by,
         x_last_update_date => SYSDATE,
         x_last_updated_by => jtf_task_utl.updated_by,
         x_last_update_login => jtf_task_utl.login_id,
         x_owner_table_name => p_owner_table_name,
         x_primary_flag => l_primary_flag -- For fixing a bug 2644132
      );
      OPEN c_jtf_task_phones (l_rowid);
      FETCH c_jtf_task_phones INTO x;

      IF c_jtf_task_phones%NOTFOUND
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_CREATING_PHONE');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         x_task_phone_id := l_task_phone_id;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_task_phones_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_task_phones_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE lock_task_phones (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2,
      p_commit                  IN       VARCHAR2,
      p_task_phone_id           IN       NUMBER,
      p_object_version_number   IN       NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'LOCK_TASK_PHONES';
      resource_locked          EXCEPTION;
      PRAGMA EXCEPTION_INIT (resource_locked, -54);
   BEGIN
      SAVEPOINT lock_task_phones_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      jtf_task_phones_pkg.lock_row (
         x_task_phone_id => p_task_phone_id,
         x_object_version_number => p_object_version_number
      );
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN resource_locked
      THEN
         ROLLBACK TO lock_task_phones_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
         fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO lock_task_phones_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO lock_task_phones_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE update_task_phones (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2,
      p_commit                  IN       VARCHAR2,
      p_object_version_number   IN OUT NOCOPY   NUMBER,
      p_task_phone_id           IN       NUMBER,
      p_phone_id                IN       NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      p_attribute1              IN       VARCHAR2,
      p_attribute2              IN       VARCHAR2,
      p_attribute3              IN       VARCHAR2,
      p_attribute4              IN       VARCHAR2,
      p_attribute5              IN       VARCHAR2,
      p_attribute6              IN       VARCHAR2,
      p_attribute7              IN       VARCHAR2,
      p_attribute8              IN       VARCHAR2,
      p_attribute9              IN       VARCHAR2,
      p_attribute10             IN       VARCHAR2,
      p_attribute11             IN       VARCHAR2,
      p_attribute12             IN       VARCHAR2,
      p_attribute13             IN       VARCHAR2,
      p_attribute14             IN       VARCHAR2,
      p_attribute15             IN       VARCHAR2,
      p_attribute_category      IN       VARCHAR2,
      p_primary_flag            IN       VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER                                 := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'UPDATE_TASK_PHONES';
      l_rowid                  ROWID;
      l_task_contact_id        jtf_task_contacts.task_contact_id%TYPE;
      l_contact_id             jtf_task_contacts.contact_id%TYPE;
      x                        CHAR;

      CURSOR c_task_phones
      IS
         SELECT DECODE (
                   p_attribute1,
                   fnd_api.g_miss_char, attribute1,
                   p_attribute1
                ) attribute1,
                DECODE (
                   p_attribute2,
                   fnd_api.g_miss_char, attribute2,
                   p_attribute2
                ) attribute2,
                DECODE (
                   p_attribute3,
                   fnd_api.g_miss_char, attribute3,
                   p_attribute3
                ) attribute3,
                DECODE (
                   p_attribute4,
                   fnd_api.g_miss_char, attribute4,
                   p_attribute4
                ) attribute4,
                DECODE (
                   p_attribute5,
                   fnd_api.g_miss_char, attribute5,
                   p_attribute5
                ) attribute5,
                DECODE (
                   p_attribute6,
                   fnd_api.g_miss_char, attribute6,
                   p_attribute6
                ) attribute6,
                DECODE (
                   p_attribute7,
                   fnd_api.g_miss_char, attribute7,
                   p_attribute7
                ) attribute7,
                DECODE (
                   p_attribute8,
                   fnd_api.g_miss_char, attribute8,
                   p_attribute8
                ) attribute8,
                DECODE (
                   p_attribute9,
                   fnd_api.g_miss_char, attribute9,
                   p_attribute9
                ) attribute9,
                DECODE (
                   p_attribute10,
                   fnd_api.g_miss_char, attribute10,
                   p_attribute10
                ) attribute10,
                DECODE (
                   p_attribute11,
                   fnd_api.g_miss_char, attribute11,
                   p_attribute11
                ) attribute11,
                DECODE (
                   p_attribute12,
                   fnd_api.g_miss_char, attribute12,
                   p_attribute12
                ) attribute12,
                DECODE (
                   p_attribute13,
                   fnd_api.g_miss_char, attribute13,
                   p_attribute13
                ) attribute13,
                DECODE (
                   p_attribute14,
                   fnd_api.g_miss_char, attribute14,
                   p_attribute14
                ) attribute14,
                DECODE (
                   p_attribute15,
                   fnd_api.g_miss_char, attribute15,
                   p_attribute15
                ) attribute15,
                DECODE (
                   p_attribute_category,
                   fnd_api.g_miss_char, attribute_category,
                   p_attribute_category
                ) attribute_category,
                DECODE (
                   p_primary_flag,
                   fnd_api.g_miss_char, primary_flag,
                   p_primary_flag
                ) primary_flag,
                owner_table_name
           FROM jtf_task_phones
          WHERE task_phone_id = p_task_phone_id;

      task_phones              c_task_phones%ROWTYPE;
      l_owner_table_name       VARCHAR2(30);
   BEGIN
      SAVEPOINT update_task_phones_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF p_task_phone_id IS NULL
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_PHONE_ID');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      BEGIN
         --- Added the nvl clause for backward compatibility
         SELECT task_contact_id,
                NVL (owner_table_name, 'JTF_TASK_CONTACTS')
           INTO l_task_contact_id,
                l_owner_table_name
           FROM jtf_task_phones
          WHERE task_phone_id = p_task_phone_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PHONE');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF l_owner_table_name = 'JTF_TASK_CONTACTS'
      THEN
         BEGIN
            SELECT contact_id
              INTO l_contact_id
              FROM jtf_task_contacts
             WHERE task_contact_id = l_task_contact_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CONTACT');
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               RAISE fnd_api.g_exc_unexpected_error;
         END;
      ELSE
         BEGIN
            SELECT customer_id
              INTO l_contact_id
              FROM jtf_tasks_b
             WHERE task_id = l_task_contact_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PHONE');
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               RAISE fnd_api.g_exc_unexpected_error;
         END;
      END IF;

      IF p_phone_id IS NULL
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_PHONE');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_task_phones;
      FETCH c_task_phones INTO task_phones;
      jtf_task_utl.validate_contact_point (
         p_contact_id => l_task_contact_id,
         p_phone_id => p_phone_id,
         x_return_status => x_return_status,
         p_owner_table_name => task_phones.owner_table_name
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      BEGIN
         SELECT 1
           INTO x
           FROM jtf_task_phones
          WHERE task_phone_id = p_task_phone_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PHONE');
            fnd_message.set_token ('P_TASK_PHONE_ID', p_task_phone_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      jtf_task_phones_pub.lock_task_phones (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_phone_id => p_task_phone_id,
         p_object_version_number => p_object_version_number,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
         p_flag_name => jtf_task_utl.get_translated_lookup (
                           'JTF_TASK_TRANSLATED_MESSAGES',
                           'PRIMARY_FLAG'
                        ),
         p_flag_value => task_phones.primary_flag,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

--Unmark the previous contact points with primary flag = 'Y'.
      IF p_primary_flag = jtf_task_utl.g_yes
      THEN
         do_unmark_primary_flag_update (
            p_task_phone_id,
            p_phone_id,
            l_contact_id
         );
      END IF;

      jtf_task_phones_pkg.update_row (
         x_task_phone_id => p_task_phone_id,
         x_task_contact_id => l_task_contact_id,
         x_object_version_number => p_object_version_number + 1,
         x_attribute1 => task_phones.attribute1,
         x_attribute2 => task_phones.attribute2,
         x_attribute3 => task_phones.attribute3,
         x_attribute4 => task_phones.attribute4,
         x_attribute5 => task_phones.attribute5,
         x_attribute6 => task_phones.attribute6,
         x_attribute7 => task_phones.attribute7,
         x_attribute8 => task_phones.attribute8,
         x_attribute9 => task_phones.attribute9,
         x_attribute10 => task_phones.attribute10,
         x_attribute11 => task_phones.attribute11,
         x_attribute12 => task_phones.attribute12,
         x_attribute13 => task_phones.attribute13,
         x_attribute14 => task_phones.attribute14,
         x_attribute15 => task_phones.attribute15,
         x_attribute_category => task_phones.attribute_category,
         x_phone_id => p_phone_id,
         x_last_update_date => SYSDATE,
         x_last_updated_by => jtf_task_utl.updated_by,
         x_last_update_login => jtf_task_utl.login_id,
         x_owner_table_name => task_phones.owner_table_name,
         x_primary_flag => task_phones.primary_flag
      );
      -- Increase ovn when all the process is successfully completed
      -- bug 2667735
      p_object_version_number := p_object_version_number + 1;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_task_phones_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_task_phones_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE delete_task_phones (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2,
      p_commit                  IN       VARCHAR2,
      p_object_version_number   IN       NUMBER,
      p_task_phone_id           IN       NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TASK_PHONES';
      x                        CHAR;

      CURSOR c_jtf_task_phones
      IS
         SELECT 1
           FROM jtf_task_phones
          WHERE task_phone_id = p_task_phone_id;
   BEGIN
      SAVEPOINT delete_task_phones_pub;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      jtf_task_phones_pub.lock_task_phones (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_phone_id => p_task_phone_id,
         p_object_version_number => p_object_version_number,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_phones_pkg.delete_row (x_task_phone_id => p_task_phone_id);
      OPEN c_jtf_task_phones;
      FETCH c_jtf_task_phones INTO x;

      IF c_jtf_task_phones%FOUND
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_DELETING_PHONES');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_task_phones_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_task_phones_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE do_unmark_primary_flag_create (
      p_task_contact_id    IN   NUMBER,
      p_phone_id           IN   NUMBER,
      p_owner_table_name   IN   VARCHAR2
   )
   IS
   BEGIN
   -- select contact points of the same type and unmark the primary flag
      IF p_owner_table_name = 'JTF_TASK_CONTACTS'
      THEN
         UPDATE jtf_task_phones
            SET primary_flag = 'N'
          WHERE task_contact_id = p_task_contact_id
            AND phone_id IN
                   ( SELECT contact_point_id
                       FROM hz_contact_points
                      WHERE contact_point_type =
                               (SELECT contact_point_type
                                  FROM hz_contact_points
                                 WHERE contact_point_id = p_phone_id
                                   AND owner_table_id =
                                          (SELECT contact_id
                                             FROM jtf_task_contacts
                                            WHERE task_contact_id =
                                                     p_task_contact_id))
                        AND owner_table_id =
                               (SELECT contact_id
                                  FROM jtf_task_contacts
                                 WHERE task_contact_id = p_task_contact_id))
            AND primary_flag = 'Y';
      ELSE
      -- select contact points of the same type and unmark the primary flag
         UPDATE jtf_task_phones
            SET primary_flag = 'N'
          WHERE task_contact_id = p_task_contact_id
            AND phone_id IN
                   ( SELECT contact_point_id
                       FROM hz_contact_points
                      WHERE contact_point_type =
                               (SELECT contact_point_type
                                  FROM hz_contact_points
                                 WHERE contact_point_id =
                                          p_phone_id
                                   AND owner_table_id =
                                          (SELECT customer_id
                                             FROM jtf_tasks_b
                                            WHERE task_id =
                                                     p_task_contact_id))
                        AND owner_table_id =
                               (SELECT customer_id
                                  FROM jtf_tasks_b
                                 WHERE task_id =
                                          p_task_contact_id))
            AND primary_flag = 'Y';
      END IF;
   END;

   PROCEDURE do_unmark_primary_flag_update (
      p_task_phone_id   IN   NUMBER,
      --p_task_contact_id    IN      NUMBER,
      p_phone_id        IN   NUMBER,
      --p_owner_table_name     IN    VARCHAR2,
      l_contact_id      IN   NUMBER
   )
   IS
   BEGIN
      UPDATE jtf_task_phones
         SET primary_flag = 'N'
       WHERE task_contact_id = (SELECT task_contact_id
                                  FROM jtf_task_phones
                                 WHERE task_phone_id = p_task_phone_id)
         AND phone_id IN
                ( SELECT contact_point_id
                    FROM hz_contact_points
                   WHERE contact_point_type =
                            (SELECT contact_point_type
                               FROM hz_contact_points
                              WHERE contact_point_id = p_phone_id
                                AND owner_table_id = l_contact_id
                         )
                     AND owner_table_id = l_contact_id
             )
         AND primary_flag = 'Y';
   END;
END;

/
