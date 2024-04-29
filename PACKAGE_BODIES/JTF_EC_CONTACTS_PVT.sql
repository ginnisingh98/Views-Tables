--------------------------------------------------------
--  DDL for Package Body JTF_EC_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_CONTACTS_PVT" AS
/* $Header: jtfeccob.pls 115.14 2003/02/04 11:55:08 siyappan ship $ */
   PROCEDURE create_escalation_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_escalation_id               IN       NUMBER DEFAULT NULL,
      p_escalation_number           IN       VARCHAR2 DEFAULT NULL,
      p_contact_id                  IN       NUMBER,
      p_contact_type_code           IN       VARCHAR2 DEFAULT NULL,
      p_escalation_notify_flag      IN       VARCHAR2 DEFAULT NULL,
      p_escalation_requester_flag   IN       VARCHAR2 DEFAULT NULL,
      x_escalation_contact_id       OUT NOCOPY     NUMBER,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      p_attribute1              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category      	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   )
   IS
      l_api_version   CONSTANT NUMBER                                 := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_CONTACTS';
      l_rowid                  ROWID;
      l_task_id                jtf_tasks_b.task_id%TYPE;
      l_task_contact_id        jtf_task_contacts.task_contact_id%TYPE;
      x                        CHAR;
   BEGIN
      SAVEPOINT create_escalation_contacts_pub;
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

--bug 2252635
      if jtf_ec_util.Contact_Duplicated(p_contact_id,
                                          p_contact_type_code,
                                          p_escalation_id) = TRUE then

          fnd_message.set_name('JTF', 'JTF_API_ALL_DUPLICATE_VALUE');
          fnd_message.set_token('API_NAME', l_api_name);
          fnd_message.set_token('DUPLICATE_VAL_PARAM', 'Contact ID: ' || to_char(p_contact_id));
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
      end if;
--end

      jtf_task_contacts_pub.create_task_contacts (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_id => p_escalation_id,
         p_task_number => p_escalation_number,
         p_contact_id => p_contact_id,
         p_contact_type_code => p_contact_type_code,
         p_escalation_notify_flag => p_escalation_notify_flag,
         p_escalation_requester_flag => p_escalation_requester_flag,
         x_task_contact_id => x_escalation_contact_id,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count,
	 p_attribute1    =>     p_attribute1,
	 p_attribute2    =>     p_attribute2,
	 p_attribute3    =>     p_attribute3,
	 p_attribute4    =>     p_attribute4,
	 p_attribute5    =>     p_attribute5,
	 p_attribute6    =>     p_attribute6,
	 p_attribute7    =>     p_attribute7,
	 p_attribute8    =>     p_attribute8,
	 p_attribute9    =>     p_attribute9,
	 p_attribute10    =>    p_attribute10,
	 p_attribute11    =>    p_attribute11,
	 p_attribute12    =>    p_attribute12,
	 p_attribute13    =>    p_attribute13,
	 p_attribute14    =>     p_attribute14,
	 p_attribute15    =>     p_attribute15,
         p_attribute_category  => p_attribute_category
      );

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
         ROLLBACK TO create_escalation_contacts_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_escalation_contacts_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

   PROCEDURE update_escalation_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number       IN OUT NOCOPY  VARCHAR2,
      p_escalation_contact_id       IN       NUMBER DEFAULT NULL,
      p_contact_id                  IN       NUMBER,
      p_contact_type_code           IN       VARCHAR2 DEFAULT NULL,
      p_escalation_notify_flag      IN       VARCHAR2 DEFAULT NULL,
      p_escalation_requester_flag   IN       VARCHAR2 DEFAULT NULL,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      p_attribute1              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category      	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   )
   IS
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_api_name       CONSTANT VARCHAR2(30) := 'UPDATE_TASK_CONTACTS';
      l_object_version_number   NUMBER;
   BEGIN
      SAVEPOINT update_escalation_contacts_pub;
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
      l_object_version_number := p_object_version_number;
      jtf_task_contacts_pub.update_task_contacts (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_task_contact_id => p_escalation_contact_id,
         p_object_version_number => l_object_version_number,
         p_contact_id => p_contact_id,
         p_contact_type_code => p_contact_type_code,
         p_escalation_notify_flag => p_escalation_notify_flag,
         p_escalation_requester_flag => p_escalation_requester_flag,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count,
	 p_attribute1    =>     p_attribute1,
	 p_attribute2    =>     p_attribute2,
	 p_attribute3    =>     p_attribute3,
	 p_attribute4    =>     p_attribute4,
	 p_attribute5    =>     p_attribute5,
	 p_attribute6    =>     p_attribute6,
	 p_attribute7    =>     p_attribute7,
	 p_attribute8    =>     p_attribute8,
	 p_attribute9    =>     p_attribute9,
	 p_attribute10    =>    p_attribute10,
	 p_attribute11    =>    p_attribute11,
	 p_attribute12    =>    p_attribute12,
	 p_attribute13    =>    p_attribute13,
	 p_attribute14    =>     p_attribute14,
	 p_attribute15    =>     p_attribute15,
         p_attribute_category  => p_attribute_category
      );

     p_object_version_number := l_object_version_number;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_escalation_contacts_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_escalation_contacts_pub;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

   PROCEDURE delete_escalation_contacts (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN       NUMBER,
      p_escalation_contact_id   IN       NUMBER,
      x_return_status           OUT NOCOPY     VARCHAR2,
      x_msg_data                OUT NOCOPY     VARCHAR2,
      x_msg_count               OUT NOCOPY     NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_TASK_CONTACTS';
   BEGIN
      SAVEPOINT delete_escalation_contacts_pub;
      x_return_status := fnd_api.g_ret_sts_success;
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
      jtf_task_contacts_pub.delete_task_contacts (
         p_api_version => p_api_version,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_object_version_number => p_object_version_number,
         p_task_contact_id => p_escalation_contact_id,
         x_return_status => x_return_status,
         x_msg_data => x_msg_data,
         x_msg_count => x_msg_count
      );

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
         ROLLBACK TO delete_task_contacts_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_task_contacts_pvt;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;
END;

/
