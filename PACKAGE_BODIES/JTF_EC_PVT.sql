--------------------------------------------------------
--  DDL for Package Body JTF_EC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EC_PVT" AS
/* $Header: jtfecmab.pls 115.24 2004/04/21 12:01:23 nselvam ship $ */
   g_user    CONSTANT VARCHAR2(30) := fnd_global.user_id;
   g_false   CONSTANT VARCHAR2(30) := fnd_api.g_false;
   g_true    CONSTANT VARCHAR2(30) := fnd_api.g_true;

   PROCEDURE create_escalation (
      p_api_version                IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_esc_id			   IN       NUMBER  DEFAULT NULL,
      p_escalation_name            IN       VARCHAR2,
      p_description                IN       VARCHAR2 DEFAULT NULL,
      p_escalation_status_name     IN       VARCHAR2 DEFAULT NULL,
      p_escalation_status_id       IN       NUMBER DEFAULT NULL,
      p_escalation_priority_name   IN       VARCHAR2 DEFAULT NULL,
      p_escalation_priority_id     IN       NUMBER DEFAULT NULL,
      p_open_date                  IN       DATE DEFAULT NULL,
      p_close_date                 IN       DATE DEFAULT NULL,
      p_escalation_owner_type_code IN       VARCHAR2 DEFAULT NULL,
      p_escalation_owner_id        IN       NUMBER DEFAULT NULL,
      p_owner_territory_id         IN       NUMBER DEFAULT NULL,
      p_assigned_by_name           IN       VARCHAR2 DEFAULT NULL,
      p_assigned_by_id             IN       NUMBER DEFAULT NULL,
      p_customer_number            IN       VARCHAR2 DEFAULT NULL,
      p_customer_id                IN       NUMBER DEFAULT NULL,
      p_cust_account_number        IN       VARCHAR2 DEFAULT NULL,
      p_cust_account_id            IN       NUMBER DEFAULT NULL,
      p_address_id                 IN       NUMBER DEFAULT NULL,
      p_address_number             IN       VARCHAR2 DEFAULT NULL,
      p_target_date                IN       DATE DEFAULT NULL,
      p_reason_code                IN       VARCHAR2 DEFAULT NULL,
      p_private_flag               IN       VARCHAR2 DEFAULT NULL,
      p_publish_flag               IN       VARCHAR2 DEFAULT NULL,
      p_workflow_process_id        IN       NUMBER DEFAULT NULL,
      p_escalation_level           IN       VARCHAR2 DEFAULT NULL,
      x_return_status              OUT NOCOPY     VARCHAR2,
      x_msg_count                  OUT NOCOPY     NUMBER,
      x_msg_data                   OUT NOCOPY     VARCHAR2,
      x_escalation_id              OUT NOCOPY     NUMBER,
      p_attribute1                 IN       VARCHAR2 DEFAULT null ,
      p_attribute2                 IN       VARCHAR2 DEFAULT null ,
      p_attribute3                 IN       VARCHAR2 DEFAULT null ,
      p_attribute4                 IN       VARCHAR2 DEFAULT null ,
      p_attribute5                 IN       VARCHAR2 DEFAULT null ,
      p_attribute6                 IN       VARCHAR2 DEFAULT null ,
      p_attribute7                 IN       VARCHAR2 DEFAULT null ,
      p_attribute8                 IN       VARCHAR2 DEFAULT null ,
      p_attribute9                 IN       VARCHAR2 DEFAULT null ,
      p_attribute10                IN       VARCHAR2 DEFAULT null ,
      p_attribute11                IN       VARCHAR2 DEFAULT null ,
      p_attribute12                IN       VARCHAR2 DEFAULT null ,
      p_attribute13                IN       VARCHAR2 DEFAULT null ,
      p_attribute14                IN       VARCHAR2 DEFAULT null ,
      p_attribute15                IN       VARCHAR2 DEFAULT null ,
      p_attribute_category         IN       VARCHAR2 DEFAULT null
   )
   AS
      l_api_version   CONSTANT NUMBER                       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)                 := 'CREATE_ESCALATION';
      l_escalation_id          jtf_tasks_b.task_id%TYPE;
      l_escalation_number      jtf_tasks_b.task_number%TYPE;
--Created for BES enh 2660883
   l_esc_rec_type       jtf_ec_pvt.Esc_Rec_type;
   BEGIN

      SAVEPOINT create_escalation_pvt;

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

      IF p_escalation_name IS NULL
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_NAME');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_tasks_pub.create_task (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_task_id => p_esc_id,
         p_task_name => p_escalation_name,
         p_task_type_id => jtf_ec_pub.g_escalation_type_id,
         p_description => p_description,
         p_task_status_name => p_escalation_status_name,
         p_task_status_id => p_escalation_status_id,
         p_task_priority_name => p_escalation_priority_name,
         p_task_priority_id => p_escalation_priority_id,
         p_actual_start_date => p_open_date,
         p_actual_end_date => p_close_date,
--         p_owner_type_code => jtf_ec_pub.g_escalation_owner_type_code,
         p_owner_type_code => p_escalation_owner_type_code,
         p_owner_id => p_escalation_owner_id,
         p_owner_territory_id => p_owner_territory_id,
/*         p_assigned_by_name => p_assigned_by_name ,
         p_assigned_by_id => p_assigned_by_id ,*/
         p_customer_number => p_customer_number,
         p_customer_id => p_customer_id,
         p_cust_account_number => p_cust_account_number,
         p_cust_account_id => p_cust_account_id,
         p_address_id => p_address_id,
         p_address_number => p_address_number,
         p_planned_end_date => p_target_date,
         p_scheduled_end_date => p_target_date,
         p_timezone_id => NULL,
         p_timezone_name => NULL,
         p_source_object_type_code => NULL,
         p_source_object_id => NULL,
         p_source_object_name => NULL,
         p_duration => NULL,
         p_duration_uom => NULL,
         p_planned_effort => NULL,
         p_planned_effort_uom => NULL,
         p_actual_effort => NULL,
         p_actual_effort_uom => NULL,
         p_percentage_complete => NULL,
         p_reason_code => p_reason_code,
         p_private_flag => p_private_flag,
         p_publish_flag => p_publish_flag,
         p_restrict_closure_flag => NULL,
         p_multi_booked_flag => NULL,
         p_milestone_flag => NULL,
         p_holiday_flag => NULL,
         p_billable_flag => NULL,
         p_bound_mode_code => NULL,
         p_soft_bound_flag => NULL,
         p_workflow_process_id => p_workflow_process_id,
         p_notification_flag => NULL,
         p_notification_period => NULL,
         p_notification_period_uom => NULL,
         p_parent_task_number => NULL,
         p_parent_task_id => NULL,
         p_alarm_start => NULL,
         p_alarm_start_uom => NULL,
         p_alarm_on => NULL,
         p_alarm_count => NULL,
         p_alarm_interval => NULL,
         p_alarm_interval_uom => NULL,
         p_palm_flag => NULL,
         p_wince_flag => NULL,
         p_laptop_flag => NULL,
         p_device1_flag => NULL,
         p_device2_flag => NULL,
         p_device3_flag => NULL,
         p_costs => NULL,
         p_currency_code => NULL,
         p_escalation_level => p_escalation_level,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_task_id => l_escalation_id,
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

      x_escalation_id := l_escalation_id;

      BEGIN
         SELECT task_number
           INTO l_escalation_number
           FROM jtf_tasks_vl
          WHERE task_id = l_escalation_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      UPDATE jtf_tasks_b
         SET source_object_type_code = jtf_ec_pub.g_escalation_code,
             source_object_id = l_escalation_id,
             source_object_name = l_escalation_number
       WHERE task_id = l_escalation_id;

      -------
      -------
      -------
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

--Created for BES enh 2660883
    begin

        l_esc_rec_type.escalation_id          := l_escalation_id;
        l_esc_rec_type.escalation_level       := p_escalation_level;

       jtf_esc_wf_events_pvt.publish_create_esc
              (p_esc_rec              => l_esc_rec_type);

    EXCEPTION when others then
       null;
    END;
--End BES enh 2660883

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_escalation_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO create_escalation_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_escalation_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

   PROCEDURE update_escalation (
      p_api_version                IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number      IN OUT NOCOPY  NUMBER,
      p_escalation_id              IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_escalation_number          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_name            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_description                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_status_name     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_status_id       IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_open_date                  IN       DATE DEFAULT fnd_api.g_miss_date,
      p_close_date                 IN       DATE DEFAULT fnd_api.g_miss_date,
      p_escalation_priority_name   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_priority_id     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_owner_id                   IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_escalation_owner_type_code IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_owner_territory_id         IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_assigned_by_name           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_assigned_by_id             IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_customer_number            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_customer_id                IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_cust_account_number        IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_cust_account_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_address_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_address_number             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_target_date                IN       DATE DEFAULT fnd_api.g_miss_date,
    /*  p_timezone_id                IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_timezone_name              IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,*/
      p_reason_code                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_private_flag               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_publish_flag               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_workflow_process_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_escalation_level           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      x_return_status              OUT NOCOPY     VARCHAR2,
      x_msg_count                  OUT NOCOPY     NUMBER,
      x_msg_data                   OUT NOCOPY     VARCHAR2,
      p_attribute1                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category         IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   )
   IS
      l_api_version       CONSTANT NUMBER                                      := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)
               := 'UPDATE_ESCALATION';
      l_escalation_id              jtf_tasks_b.task_id%TYPE := p_escalation_id ;
      l_escalation_number          jtf_tasks_b.task_number%TYPE := p_escalation_number ;
      l_description                jtf_tasks_tl.description%TYPE := p_description;
      l_escalation_name            jtf_tasks_tl.task_name%TYPE
               := p_escalation_name;
      l_escalation_status_name     jtf_task_statuses_tl.name%TYPE
               := p_escalation_status_name;
      l_escalation_status_id       jtf_task_statuses_b.task_status_id%TYPE
               := p_escalation_status_id;
      l_escalation_priority_name   jtf_task_priorities_tl.name%TYPE
               := p_escalation_priority_name;
      l_escalation_priority_id     jtf_task_priorities_b.task_priority_id%TYPE
               := p_escalation_priority_id;
      l_assigned_by_name           fnd_user.user_name%TYPE
               := p_assigned_by_name;
      l_assigned_by_id             NUMBER
               := p_assigned_by_id;
      l_customer_id                hz_parties.party_id%TYPE;
      l_customer_number            hz_parties.party_number%TYPE;
      l_cust_account_id            hz_cust_accounts.cust_account_id%TYPE;
      l_cust_account_number        hz_cust_accounts.account_number%TYPE;
      l_address_id                 hz_party_sites.party_site_id%TYPE;
      l_address_number             hz_party_sites.party_site_number%TYPE;
      l_owner_id                   jtf_tasks_b.owner_id%TYPE;
      l_reason_code                jtf_tasks_b.reason_code%TYPE;
      l_private_flag               jtf_tasks_b.private_flag%TYPE;
      l_publish_flag               jtf_tasks_b.publish_flag%TYPE;
      l_workflow_process_id        jtf_tasks_b.workflow_process_id%TYPE;
      l_owner_type_code            jtf_tasks_b.source_object_type_code%TYPE;

      CURSOR c_escalation_update (l_escalation_id IN NUMBER)
      IS
         SELECT DECODE (
                   p_escalation_id,
                   fnd_api.g_miss_num,
                   task_id,
                   p_escalation_id
                ) escalation_id,
                DECODE (
                   p_escalation_number,
                   fnd_api.g_miss_char,
                   task_number,
                   p_escalation_number
                ) escalation_number,
                DECODE (
                   p_escalation_name,
                   fnd_api.g_miss_char,
                   task_name,
                   p_escalation_name
                ) escalation_name,
                DECODE (
                   p_description,
                   fnd_api.g_miss_char,
                   description,
                   p_description
                ) description,
                DECODE (
                   p_escalation_status_id,
                   fnd_api.g_miss_num,
                   task_status_id,
                   p_escalation_status_id
                ) escalation_status_id,
                DECODE (
                   p_escalation_priority_id,
                   fnd_api.g_miss_num,
                   task_priority_id,
                   p_escalation_priority_id
                ) escalation_priority_id,
                DECODE (
                   p_owner_id,
                   fnd_api.g_miss_num,
                   owner_id,
                   p_owner_id
                ) owner_id,
                DECODE (
                   p_owner_territory_id,
                   fnd_api.g_miss_num,
                   owner_territory_id,
                   p_owner_territory_id
                ) owner_territory_id,
                DECODE (
                   p_assigned_by_id,
                   fnd_api.g_miss_num,
                   assigned_by_id,
                   p_assigned_by_id
                ) assigned_by_id,
                DECODE (
                   p_customer_id,
                   fnd_api.g_miss_num,
                   customer_id,
                   p_customer_id
                ) customer_id,
                DECODE (
                   p_cust_account_id,
                   fnd_api.g_miss_num,
                   cust_account_id,
                   p_cust_account_id
                ) cust_account_id,
                DECODE (
                   p_address_id,
                   fnd_api.g_miss_num,
                   address_id,
                   p_address_id
                ) address_id,
                DECODE (
                   p_target_date,
                   fnd_api.g_miss_date,
                   planned_end_date,
                   p_target_date
                ) target_date,
                DECODE (
                   p_reason_code,
                   fnd_api.g_miss_char,
                   reason_code,
                   p_reason_code
                ) reason_code,
                DECODE (
                   p_private_flag,
                   fnd_api.g_miss_char,
                   private_flag,
                   p_private_flag
                ) private_flag,
                DECODE (
                   p_publish_flag,
                   fnd_api.g_miss_char,
                   publish_flag,
                   p_publish_flag
                ) publish_flag,
                DECODE (
                   p_workflow_process_id,
                   fnd_api.g_miss_num,
                   workflow_process_id,
                   p_workflow_process_id
                ) workflow_process_id,
                DECODE (
                   p_escalation_level,
                   fnd_api.g_miss_char,
                   escalation_level,
                   p_escalation_level
                ) escalation_level,
                DECODE (
                   p_open_date,
                   fnd_api.g_miss_date,
                   actual_start_date,
                   p_open_date
                ) open_date,
                DECODE (
                   p_close_date,
                   fnd_api.g_miss_date,
                   actual_end_date,
                   p_close_date
                ) close_date
           FROM jtf_tasks_vl
          WHERE task_id =
                   l_escalation_id;

      escalation_rec               c_escalation_update%ROWTYPE;
--Created for BES enh 2660883
   l_esc_rec_type       jtf_ec_pvt.Esc_Rec_type;
   l_task_audit_id              jtf_task_audits_b.TASK_AUDIT_ID%TYPE;

   cursor auditid_cur IS
   select MAX(TASK_AUDIT_ID)
   from   JTF_TASK_AUDITS_B
   where  TASK_ID  = l_escalation_id;

   BEGIN

      SAVEPOINT update_escalation_pvt;

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


      -----
      -----   Validate Escalation
      -----
      IF (   l_escalation_id = fnd_api.g_miss_num
         AND l_escalation_number = fnd_api.g_miss_char)
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         SELECT DECODE (l_escalation_id, fnd_api.g_miss_num, NULL, l_escalation_id)
           INTO
                l_escalation_id
           FROM dual;
         SELECT DECODE (
                   l_escalation_number,
                   fnd_api.g_miss_char, NULL,
                   l_escalation_number
                )
           INTO
                l_escalation_number
           FROM dual;
         jtf_task_utl.validate_task (
            p_task_id => l_escalation_id,
            p_task_number => l_escalation_number,
            x_task_id => l_escalation_id,
            x_return_status => x_return_status
         );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF l_escalation_id IS NULL
         THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_NUMBER');
            fnd_message.set_token('P_TASK_NUMBER',l_escalation_number);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;


      -----
      -----     Escalation Name
      -----
      IF l_escalation_name IS NULL
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_NAME');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -----
      -----     Task Description
      -----
      l_description := escalation_rec.description;
      ----
      ----   Check escalation status.
      ----
      OPEN c_escalation_update (l_escalation_id);
      FETCH c_escalation_update INTO escalation_rec;

      IF c_escalation_update%NOTFOUND
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_ID');
         fnd_message.set_token('P_TASK_ID', to_char(l_escalation_id));
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_escalation_update;
      -----
      -----     Task Description
      -----
      l_description := escalation_rec.description;
      ----



     jtf_tasks_pub.update_task (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_object_version_number => p_object_version_number,
         p_task_id => l_escalation_id,
         p_task_name => l_escalation_name,
         p_task_type_id => 22,
         p_description => l_description,
         p_task_status_id => l_escalation_status_id,
         p_task_priority_id => p_escalation_priority_id,
         p_task_priority_name => p_escalation_priority_name,
--         p_owner_type_code => jtf_ec_pub.g_escalation_owner_type_code,
         p_owner_type_code => p_escalation_owner_type_code,
         p_owner_id => p_owner_id,
         p_owner_territory_id => p_owner_territory_id ,
         p_assigned_by_id => l_assigned_by_id,
         p_customer_number => p_customer_number,
         p_customer_id => p_customer_id,
         p_cust_account_id => p_cust_account_id,
         p_cust_account_number => p_cust_account_number,
         p_address_number => p_address_number,
         p_address_id => p_address_id,
         p_planned_start_date => null ,
         p_planned_end_date => p_target_date,
/*         p_scheduled_start_date => p_scheduled_start_date,
         p_scheduled_end_date => p_scheduled_end_date,*/
         p_actual_start_date => p_open_date,
         p_actual_end_date => p_close_date ,
---            p_timezone_id => l_timezone_id,
--            p_source_object_type_code => escalation_code,
--            p_source_object_id => l_source_object_id,
--            p_source_object_name => l_source_object_name,
--            p_duration => l_duration,
--            p_duration_uom => l_duration_uom,
/*            p_planned_effort => l_planned_effort,
            p_planned_effort_uom => l_planned_effort_uom,
            p_actual_effort => l_actual_effort,
            p_actual_effort_uom => l_actual_effort_uom,
            p_percentage_complete => l_percentage_complete,
*/
         p_reason_code => p_reason_code,
         p_private_flag => l_private_flag,
         p_publish_flag => l_publish_flag,
/*            p_restrict_closure_flag => l_restrict_closure_flag,
            p_multi_booked_flag => l_multi_booked_flag,
            p_milestone_flag => l_milestone_flag,
            p_holiday_flag => l_holiday_flag,
            p_billable_flag => l_billable_flag,
            p_bound_mode_code => l_bound_mode_code,
            p_soft_bound_flag => l_soft_bound_flag,
*/
         p_workflow_process_id => escalation_rec.workflow_process_id,
/*            p_notification_flag => l_notification_flag,
            p_notification_period => l_notification_period,
            p_notification_period_uom => l_notification_period_uom,
*/
/*         p_parent_task_id =>  l_parent_task_id  ,
            p_alarm_start => l_alarm_start,
            p_alarm_start_uom => l_alarm_start_uom,
            p_alarm_on => l_alarm_on,
            p_alarm_count => l_alarm_count,
            p_alarm_fired_count => l_alarm_fired_count,
            p_alarm_interval => l_alarm_interval,
            p_alarm_interval_uom => l_alarm_interval_uom,
            p_palm_flag => l_palm_flag,
            p_wince_flag => l_wince_flag,
            p_laptop_flag => l_laptop_flag,
            p_device1_flag => l_device1_flag,
            p_device2_flag => l_device2_flag,
            p_device3_flag => l_device3_flag,
            p_costs => l_costs,
            p_currency_code => l_currency_code,
*/
         p_escalation_level => p_escalation_level,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
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

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

--Created for BES enh 2660883
    begin

    	OPEN auditid_cur;
    	FETCH auditid_cur INTO l_task_audit_id;
    	CLOSE auditid_cur;

        l_esc_rec_type.escalation_id       := l_escalation_id;
        l_esc_rec_type.task_audit_id       := l_task_audit_id;

       jtf_esc_wf_events_pvt.publish_update_esc
              (p_esc_rec              => l_esc_rec_type);

    EXCEPTION when others then
       null;
    END;
--End BES enh 2660883

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_escalation_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO update_escalation_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         ROLLBACK TO update_escalation_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;
/*   PROCEDURE lock_escalation (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_escalation_id           IN       NUMBER,
      p_object_version_number   IN NUMBER,
      x_return_status     OUT      VARCHAR2,
      x_msg_data          OUT      VARCHAR2,
      x_msg_count         OUT      NUMBER
   );
*/

    PROCEDURE delete_escalation (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN       NUMBER ,
        p_escalation_id                 IN       NUMBER DEFAULT NULL,
        p_escalation_number             IN       VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_msg_count               OUT NOCOPY     NUMBER,
        x_msg_data                OUT NOCOPY     VARCHAR2
    ) is
        l_api_version    CONSTANT NUMBER                       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                 := 'DELETE_TASK';

        l_escalation_id     jtf_tasks_b.task_id%type  := p_escalation_id ;
        l_escalation_number jtf_tasks_b.task_number%type := p_escalation_number  ;
--Created for BES enh 2660883
   l_esc_rec_type       jtf_ec_pvt.Esc_Rec_type;

/*  Bug # 3568448 */
/*Commenting out the below cursor definition since call to jtf_tasks_pvt.delete_task deletes the reference records */
/*	 CURSOR c_delete_references
         IS
         SELECT task_reference_id,object_version_number
         FROM jtf_task_references_vl
         WHERE task_id = l_escalation_id; */

--  Added for Bug # 3568448
   l_esc_ref_rec       jtf_ec_references_pvt.Esc_Ref_rec;

   CURSOR c_ref_orig
   IS
     SELECT REFERENCE_CODE, OBJECT_TYPE_CODE, OBJECT_ID, TASK_ID
        FROM JTF_TASK_REFERENCES_B
        WHERE task_id = l_escalation_id;

      rec_ref_orig    c_ref_orig%ROWTYPE;

      Type Ref_Rec_Data is table of jtf_ec_references_pvt.Esc_Ref_rec index by Binary_integer;
      ref_recs Ref_Rec_Data;

      l_cnt number := 0;
      l_cnt1 number := 0;
-- End Add

    begin
        SAVEPOINT delete_escalation_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        IF (   l_escalation_id IS NULL
           AND l_escalation_number IS NULL)
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            jtf_task_utl.validate_task (
                p_task_id => l_escalation_id,
                p_task_number => l_escalation_number,
                x_task_id => l_escalation_id,
                x_return_status => x_return_status
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

--  Added for Bug # 3568448
/*--  This will fetch all the reference data that is required for triggering BES.
--  The code is added since, a call to jtf_tasks_pvt.delete_task will delete references and hence the
--  reference data will not be available after the call either to delete_escalation_reference or to
--  fire the Business Event.*/
for dr in c_ref_orig
loop
        ref_recs(l_cnt).task_reference_id          := l_escalation_id;
        ref_recs(l_cnt).object_type_code       := dr.object_type_code;
        ref_recs(l_cnt).reference_code       := dr.reference_code;
        ref_recs(l_cnt).object_id       := dr.object_id;
	ref_recs(l_cnt).task_id         := dr.task_id;
l_cnt := l_cnt + 1;
end loop;
-- End Add


	jtf_tasks_pvt.delete_task (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_task_id => l_escalation_id,
            p_delete_future_recurrences => fnd_api.g_false,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );

-- Code added to check x_return_status, since it was missing in the original code
	IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
-- End Add

--  Added for Bug # 3568448
--  The below code will trigger the Business event for every reference that is deleted when deleting
--  an Escalation

    Begin


     if l_cnt > 0 then
	while (l_cnt1 <= l_cnt)
	loop
        jtf_esc_wf_events_pvt.publish_delete_escRef
              (p_esc_ref_rec              => ref_recs(l_cnt1));
	l_cnt1 := l_cnt1 + 1;
	end loop;
     end if;

    EXCEPTION when others then
       null;

     End;

--  End Add


/*  Bug # 3568448 */
/*Commenting out the below code since call to jtf_tasks_pvt.delete_task deletes the reference records also
	-- delete references....

        ---------------------------
        FOR b IN c_delete_references
        LOOP
        jtf_ec_references_pvt.delete_references (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => b.object_version_number,
            p_escalation_reference_id => b.task_reference_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        END LOOP; */

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

--Created for BES enh 2660883
    begin

        l_esc_rec_type.escalation_id          := l_escalation_id;

       jtf_esc_wf_events_pvt.publish_delete_esc
              (p_esc_rec              => l_esc_rec_type);

    EXCEPTION when others then
       null;
    END;
--End BES enh 2660883


    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO delete_escalation_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add ;
            ROLLBACK TO delete_escalation_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

END;

/
