--------------------------------------------------------
--  DDL for Package Body JTF_TASK_CONTACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_CONTACTS_PUB" AS
/* $Header: jtfptkcb.pls 120.3 2006/07/13 11:30:06 sbarat ship $ */
    PROCEDURE do_unmark_primary_flag_create(
        p_task_id       IN      NUMBER
    ) ;

    PROCEDURE do_unmark_primary_flag_update(
        p_task_contact_id     IN      NUMBER
    ) ;

    PROCEDURE do_delete_cascade(
                p_task_contact_id IN NUMBER
    ) ;

    ---------------------------------------
    -- For fixing a bug 2644132
    FUNCTION is_this_first_contact(p_task_id IN NUMBER)
    RETURN BOOLEAN
    IS
        CURSOR c_task_contact (b_task_id NUMBER) IS
        SELECT '1'
          FROM jtf_task_contacts
         WHERE task_id = b_task_id;

        l_dummy VARCHAR2(1);
        l_this_is_first BOOLEAN;
    BEGIN
        OPEN c_task_contact(p_task_id);
        FETCH c_task_contact INTO l_dummy;

        IF c_task_contact%NOTFOUND
        THEN
            l_this_is_first := TRUE;
        ELSE
            l_this_is_first := FALSE;
        END IF;

        CLOSE c_task_contact;

        RETURN l_this_is_first;

    END is_this_first_contact;
    ---------------------------------------

    PROCEDURE create_task_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2,
      p_commit                      IN       VARCHAR2,
      p_task_id                     IN       NUMBER,
      p_task_number                 IN       VARCHAR2,
      p_contact_id                  IN       NUMBER,
      p_contact_type_code           IN       VARCHAR2,
      p_escalation_notify_flag      IN       VARCHAR2,
      p_escalation_requester_flag   IN       VARCHAR2,
      x_task_contact_id             OUT NOCOPY     NUMBER,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      p_attribute1                  IN       VARCHAR2,
      p_attribute2                  IN       VARCHAR2,
      p_attribute3                  IN       VARCHAR2,
      p_attribute4                  IN       VARCHAR2,
      p_attribute5                  IN       VARCHAR2,
      p_attribute6                  IN       VARCHAR2,
      p_attribute7                  IN       VARCHAR2,
      p_attribute8                  IN       VARCHAR2,
      p_attribute9                  IN       VARCHAR2,
      p_attribute10                 IN       VARCHAR2,
      p_attribute11                 IN       VARCHAR2,
      p_attribute12                 IN       VARCHAR2,
      p_attribute13                 IN       VARCHAR2,
      p_attribute14                 IN       VARCHAR2,
      p_attribute15                 IN       VARCHAR2,
      p_attribute_category          IN       VARCHAR2,
      p_primary_flag                IN       VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER                                 := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_CONTACTS';
      l_rowid                  ROWID;
      l_task_id                jtf_tasks_b.task_id%TYPE;
      l_task_contact_id        jtf_task_contacts.task_contact_id%TYPE;
      x                        CHAR;
      l_person_id              NUMBER;

      l_primary_flag VARCHAR2(1) := p_primary_flag; -- For fixing a bug 2644132

      CURSOR c_jtf_task_contacts (l_rowid IN ROWID)
      IS
         SELECT 1
           FROM jtf_task_contacts
          WHERE ROWID = l_rowid;
   BEGIN
      SAVEPOINT create_task_contacts_pub;
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

      jtf_task_utl.validate_task (
         x_return_status => x_return_status,
         p_task_id => p_task_id,
         p_task_number => p_task_number,
         x_task_id => l_task_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      jtf_task_utl.validate_missing_task_id (
         p_task_id => p_task_id,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      jtf_task_utl.validate_missing_contact_id (
         p_task_contact_id => p_contact_id,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      IF NOT jtf_task_utl.validate_lookup (
                'JTF_TASK_CONTACT_TYPE',
                NVL (p_contact_type_code, 'CUST'),
                'Escalation Contact Point ( JTF_EC_CONTACT_TYPE)'
             )
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_contact (
         p_contact_id => p_contact_id,
         p_task_id => p_task_id,
         p_contact_type_code => NVL (p_contact_type_code, 'CUST'),
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
         p_flag_name => jtf_task_utl.get_translated_lookup (
                           'JTF_TASK_TRANSLATED_MESSAGES',
                           'NOTIFICATION_FLAG'
                        ),
         p_flag_value => p_escalation_notify_flag,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_flag (
         p_flag_name => jtf_task_utl.get_translated_lookup (
                           'JTF_TASK_TRANSLATED_MESSAGES',
                           'ESCALATION_REQUESTOR_FLAG'
                        ),
         p_flag_value => p_escalation_requester_flag,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Added this call for bug# 5140139
      jtf_task_utl.check_duplicate_contact (
                            p_contact_id        => p_contact_id,
                            p_task_id           => p_task_id,
                            p_contact_type_code => NVL (p_contact_type_code, 'CUST'),
                            p_task_contact_id   => NULL,
                            x_return_status     => x_return_status
                            );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      SELECT jtf_task_contacts_s.nextval
        INTO l_task_contact_id
        FROM dual;

--Unmark the previous task id with primary flag = 'Y'.
        IF p_primary_flag = jtf_task_utl.g_yes THEN
           do_unmark_primary_flag_create( l_task_id );
        END IF;

      -------------------------------------------
      -- For fixing a bug 2644132
      IF is_this_first_contact(p_task_id)
      THEN
         l_primary_flag := jtf_task_utl.g_yes;
      END IF;
      -------------------------------------------

      jtf_task_contacts_pkg.insert_row (
         x_rowid => l_rowid,
         x_task_contact_id => l_task_contact_id,
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
         x_contact_id => p_contact_id,
         x_attribute1 => p_attribute1,
         x_attribute2 => p_attribute2,
         x_attribute3 => p_attribute3,
         x_task_id => p_task_id,
         x_creation_date => SYSDATE,
         x_created_by => jtf_task_utl.created_by,
         x_last_update_date => SYSDATE,
         x_last_updated_by => jtf_task_utl.updated_by,
         x_last_update_login => jtf_task_utl.login_id,
         x_contact_type_code => p_contact_type_code,
         x_escalation_notify_flag => p_escalation_notify_flag,
         x_escalation_requester_flag => p_escalation_requester_flag,
         x_primary_flag => l_primary_flag -- For fixing a bug 2644132
      );
      OPEN c_jtf_task_contacts (l_rowid);
      FETCH c_jtf_task_contacts INTO x;

      IF c_jtf_task_contacts%NOTFOUND
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_CREATING_CONTACTS');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         x_task_contact_id := l_task_contact_id;
      END IF;

      -- ------------------------------------------------------------------------
      -- Create reference to contact, fix for enh #1845501
      -- ------------------------------------------------------------------------

      jtf_task_utl.create_party_reference (
         p_reference_from   => 'CONTACT',
         p_task_id      => p_task_id,
         p_party_type_code  => p_contact_type_code,
         p_party_id     => p_contact_id,
         x_msg_count        => x_msg_count,
         x_msg_data     => x_msg_data,
         x_return_status    => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
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
         ROLLBACK TO create_task_contacts_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_task_contacts_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE lock_task_contacts (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2,
      p_commit                  IN       VARCHAR2,
      p_task_contact_id         IN       NUMBER,
      p_object_version_number   IN       NUMBER,
      x_return_status           OUT NOCOPY     VARCHAR2,
      x_msg_data                OUT NOCOPY     VARCHAR2,
      x_msg_count               OUT NOCOPY     NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'LOCK_TASK_CONTACTS';
      resource_locked          EXCEPTION;
      PRAGMA EXCEPTION_INIT (resource_locked, -54);
   BEGIN
      SAVEPOINT lock_task_contacts_pub;
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
      jtf_task_contacts_pkg.lock_row (
      x_task_contact_id => p_task_contact_id,
      x_object_version_number => p_object_version_number);
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN resource_locked
      THEN

         ROLLBACK TO lock_task_contacts_pub;
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

         ROLLBACK TO lock_task_contacts_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO lock_task_contacts_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE update_task_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2,
      p_commit                      IN       VARCHAR2,
      p_object_version_number       IN OUT NOCOPY   NUMBER,
      p_task_contact_id             IN       NUMBER,
      p_contact_id                  IN       NUMBER,
      p_contact_type_code           IN       VARCHAR2,
      p_escalation_notify_flag      IN       VARCHAR2,
      p_escalation_requester_flag   IN       VARCHAR2,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      p_attribute1                  IN       VARCHAR2,
      p_attribute2                  IN       VARCHAR2,
      p_attribute3                  IN       VARCHAR2,
      p_attribute4                  IN       VARCHAR2,
      p_attribute5                  IN       VARCHAR2,
      p_attribute6                  IN       VARCHAR2,
      p_attribute7                  IN       VARCHAR2,
      p_attribute8                  IN       VARCHAR2,
      p_attribute9                  IN       VARCHAR2,
      p_attribute10                 IN       VARCHAR2,
      p_attribute11                 IN       VARCHAR2,
      p_attribute12                 IN       VARCHAR2,
      p_attribute13                 IN       VARCHAR2,
      p_attribute14                 IN       VARCHAR2,
      p_attribute15                 IN       VARCHAR2,
      p_attribute_category          IN       VARCHAR2,
      p_primary_flag                IN       VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER                                 := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'UPDATE_TASK_CONTACTS';
      l_task_contact_id        jtf_task_contacts.task_contact_id%TYPE;
      l_contact_id             jtf_task_contacts.contact_id%TYPE;
      l_task_id                jtf_tasks_b.task_id%TYPE;
      CURSOR c_task_contacts
      IS
         SELECT task_contact_id,
                task_id,
                DECODE (
                   p_contact_id,
                   fnd_api.g_miss_num, contact_id,
                   p_contact_id
                ) contact_id,
                DECODE (
                   p_contact_type_code,
                   fnd_api.g_miss_char, contact_type_code,
                   p_contact_type_code
                ) contact_type_code,
                DECODE (
                   p_escalation_notify_flag,
                   fnd_api.g_miss_char, escalation_notify_flag,
                   p_escalation_notify_flag
                ) escalation_notify_flag,
                DECODE (
                   p_escalation_requester_flag,
                   fnd_api.g_miss_char, escalation_requester_flag,
                   p_escalation_requester_flag
                ) escalation_requester_flag,
                DECODE (
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
                ) primary_flag
           FROM jtf_task_contacts
          WHERE task_contact_id = p_task_contact_id;

      task_contacts            c_task_contacts%ROWTYPE;
      x                        NUMBER;

      CURSOR con_con_orig (b_task_contact_id IN NUMBER)
      IS
         SELECT contact_id,
                contact_type_code
           FROM jtf_task_contacts
          WHERE task_contact_id = b_task_contact_id;

      l_orig_con_id jtf_task_contacts.contact_id%type;
      l_orig_type_code  jtf_task_contacts.contact_type_code%type;
   BEGIN
      SAVEPOINT update_task_contacts_pub;
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





      jtf_task_utl.validate_missing_contact_id (
         p_task_contact_id => p_contact_id,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;




      OPEN c_task_contacts;
      FETCH c_task_contacts INTO task_contacts;

      IF c_task_contacts%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CONTACTS');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      IF NOT jtf_task_utl.validate_lookup(
                'JTF_TASK_CONTACT_TYPE',
                NVL (task_contacts.contact_type_code, 'CUST'),
                'Escalation Contact Point( JTF_EC_CONTACT_TYPE)'
             )
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      BEGIN
         SELECT task_id
           INTO l_task_id
           FROM jtf_task_contacts
          WHERE task_contact_id = p_task_contact_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CONTACTS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
      END;


      jtf_task_utl.validate_contact (
         p_contact_id => task_contacts.contact_id,
         p_task_id => task_contacts.task_id,
         p_contact_type_code => task_contacts.contact_type_code,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      jtf_task_utl.validate_flag (
         p_flag_name => jtf_task_utl.get_translated_lookup (
                           'JTF_TASK_TRANSLATED_MESSAGES',
                           'NOTIFICATION_FLAG'
                        ),
         p_flag_value => task_contacts.escalation_notify_flag,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      jtf_task_utl.validate_flag (
         p_flag_name => jtf_task_utl.get_translated_lookup (
                           'JTF_TASK_TRANSLATED_MESSAGES',
                           'ESCALATION_REQUESTOR_FLAG'
                        ),
         p_flag_value => task_contacts.escalation_requester_flag,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Added this call for bug# 5140139
      jtf_task_utl.check_duplicate_contact(
                          p_contact_id        => task_contacts.contact_id,
                          p_task_id           => task_contacts.task_id,
                          p_contact_type_code => NVL (task_contacts.contact_type_code, 'CUST'),
                          p_task_contact_id   => p_task_contact_id,
                          x_return_status     => x_return_status
                          );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_contacts_pub.lock_task_contacts (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_contact_id => p_task_contact_id,
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


--unmark the previous task id with primary flag = 'Y'.
        IF p_primary_flag = jtf_task_utl.g_yes THEN
           do_unmark_primary_flag_update( P_task_contact_id );

        END IF;

      -- ------------------------------------------------------------------------
      -- Get the original contact_id and contact_type_code so we can update the
      -- reference details if necessary
      -- ------------------------------------------------------------------------

        OPEN con_con_orig (p_task_contact_id);
        FETCH con_con_orig INTO l_orig_con_id,
                                l_orig_type_code;

        IF con_con_orig%NOTFOUND
        THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;


      jtf_task_contacts_pkg.update_row (
         x_task_contact_id => p_task_contact_id,
         x_object_version_number => p_object_version_number + 1,
         x_attribute1 => task_contacts.attribute1,
         x_attribute2 => task_contacts.attribute2,
         x_attribute3 => task_contacts.attribute3,
         x_attribute4 => task_contacts.attribute4,
         x_attribute5 => task_contacts.attribute5,
         x_attribute6 => task_contacts.attribute6,
         x_attribute7 => task_contacts.attribute7,
         x_attribute8 => task_contacts.attribute8,
         x_attribute9 => task_contacts.attribute9,
         x_attribute10 => task_contacts.attribute10,
         x_attribute11 => task_contacts.attribute11,
         x_attribute12 => task_contacts.attribute12,
         x_attribute13 => task_contacts.attribute13,
         x_attribute14 => task_contacts.attribute14,
         x_attribute15 => task_contacts.attribute15,
         x_attribute_category => task_contacts.attribute_category,
         x_task_id => task_contacts.task_id,
         x_contact_id => task_contacts.contact_id,
         x_last_update_date => SYSDATE,
         x_last_updated_by => jtf_task_utl.updated_by,
         x_last_update_login => jtf_task_utl.login_id,
         x_contact_type_code => task_contacts.contact_type_code,
         x_escalation_notify_flag => task_contacts.escalation_notify_flag,
         x_escalation_requester_flag => task_contacts.escalation_requester_flag,
         x_primary_flag => task_contacts.primary_flag
      );

      l_contact_id := task_contacts.contact_id;
  -- ------------------------------------------------------------------------
  -- Update reference to contact if changed, fix enh #1845501
  -- ------------------------------------------------------------------------
      if (nvl(l_contact_id, 0) <> fnd_api.g_miss_num and
          nvl(l_contact_id, 0) <> nvl(l_orig_con_id, 0)) then
      -- delete the old one
         jtf_task_utl.delete_party_reference(
            p_reference_from    => 'CONTACT',
            p_task_id       => l_task_id,
            p_party_type_code   => l_orig_type_code,
            p_party_id      => l_orig_con_id,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            x_return_status     => x_return_status);

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         -- create a new one
         jtf_task_utl.create_party_reference(
            p_reference_from    => 'CONTACT',
            p_task_id       => l_task_id,
            p_party_type_code   => task_contacts.contact_type_code,
            p_party_id      => l_contact_id,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            x_return_status     => x_return_status);

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      end if;

      IF con_con_orig%ISOPEN
      THEN
         CLOSE con_con_orig;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      p_object_version_number := p_object_version_number + 1;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_task_contacts_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_task_contacts_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

   PROCEDURE delete_task_contacts (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2,
      p_commit                  IN       VARCHAR2,
      p_object_version_number   IN       NUMBER,
      p_task_contact_id         IN       NUMBER,
      x_return_status           OUT NOCOPY     VARCHAR2,
      x_msg_data                OUT NOCOPY     VARCHAR2,
      x_msg_count               OUT NOCOPY     NUMBER,
      p_delete_cascade          IN       VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER                   := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'DELETE_TASK_CONTACTS';
      l_task_id                jtf_tasks_b.task_id%TYPE;
      l_contact_id             jtf_task_contacts.contact_id%TYPE;
      l_contact_type_code      jtf_task_contacts.contact_type_code%TYPE;
      CURSOR con_con_orig (b_task_contact_id IN NUMBER)
      IS
         SELECT contact_id,
                contact_type_code
           FROM jtf_task_contacts
          WHERE task_contact_id = b_task_contact_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT delete_task_contacts_pvt;
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

      jtf_task_utl.validate_missing_contact_id (
         p_task_contact_id => p_task_contact_id,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      BEGIN
         SELECT task_id
           INTO l_task_id
           FROM jtf_task_contacts
          WHERE task_contact_id = p_task_contact_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CONTACTS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
      END;


      jtf_task_contacts_pub.lock_task_contacts (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_contact_id => p_task_contact_id,
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

      --Delete the associated contact points in JTF_TASK_PHONES
      IF p_delete_cascade = jtf_task_utl.g_yes THEN
         do_delete_cascade (
            p_task_contact_id => p_task_contact_id
         ) ;
      END IF;

      -- ------------------------------------------------------------------------
      -- Get the original contact_id so we can delete the reference details
      -- ------------------------------------------------------------------------

        OPEN con_con_orig (p_task_contact_id);
        FETCH con_con_orig INTO l_contact_id,
                                l_contact_type_code;

        IF con_con_orig%NOTFOUND
        THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      jtf_task_contacts_pkg.delete_row (
         x_task_contact_id => p_task_contact_id
      );

  -- ------------------------------------------------------------------------
  -- Delete reference to contact, fix enh #1845501
  -- ------------------------------------------------------------------------
            jtf_task_utl.delete_party_reference(
               p_reference_from     => 'CONTACT',
               p_task_id        => l_task_id,
               p_party_type_code    => l_contact_type_code,
               p_party_id       => l_contact_id,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               x_return_status      => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

      IF con_con_orig%ISOPEN
      THEN
         CLOSE con_con_orig;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_task_contacts_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_task_contacts_pvt;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;



   PROCEDURE do_unmark_primary_flag_create(
                  p_task_id  IN     NUMBER
   ) IS

   BEGIN
-- unmark previous primary flag
      UPDATE jtf_task_contacts
         SET primary_flag = 'N'
       WHERE task_id = p_task_id
         AND primary_flag = 'Y';

   END;

   PROCEDURE do_unmark_primary_flag_update(
                p_task_contact_id  IN      NUMBER

   ) IS

   BEGIN
   -- unmark previous primary flag
      UPDATE jtf_task_contacts
         SET primary_flag = 'N'
       WHERE task_id = (SELECT task_id FROM jtf_task_contacts
                              WHERE  task_contact_id = p_task_contact_id)
         AND primary_flag = 'Y';

   END;

   PROCEDURE do_delete_cascade(
                p_task_contact_id IN NUMBER
   ) IS

      l_task_phone_id jtf_task_phones.task_phone_id%TYPE;

      CURSOR c_phone_id(p_task_contact_id NUMBER)
      IS
         SELECT task_phone_id
         FROM jtf_task_phones
         WHERE task_contact_id = p_task_contact_id
         AND owner_table_name = 'JTF_TASK_CONTACTS';

   BEGIN
      OPEN c_phone_id(p_task_contact_id);
      LOOP
         FETCH c_phone_id INTO l_task_phone_id;
         EXIT WHEN c_phone_id%NOTFOUND;

         DELETE FROM jtf_task_phones
         WHERE task_phone_id = l_task_phone_id;
      END LOOP;
      CLOSE c_phone_id;
   END;

END;

/
