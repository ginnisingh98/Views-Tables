--------------------------------------------------------
--  DDL for Package Body JTF_TASK_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_TEMPLATES_PUB" AS
/* $Header: jtfptkmb.pls 120.1 2005/07/02 00:59:31 appldev ship $ */
    g_pkg_name    CONSTANT VARCHAR2(30) := 'JTF_TASK_TEMPLATES_PUB';

     PROCEDURE create_task (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id                   IN       NUMBER DEFAULT NULL,
      p_task_group_id             IN       NUMBER DEFAULT NULL,
      p_task_group_name           IN       VARCHAR2 DEFAULT NULL,
      p_task_name                 IN       VARCHAR2,
      p_task_type_name            IN       VARCHAR2 DEFAULT NULL,
      p_task_type_id              IN       NUMBER DEFAULT NULL,
      p_description               IN       VARCHAR2 DEFAULT NULL,
      p_task_status_name          IN       VARCHAR2 DEFAULT NULL,
      p_task_status_id            IN       NUMBER DEFAULT NULL,
      p_task_priority_name        IN       VARCHAR2 DEFAULT NULL,
      p_task_priority_id          IN       NUMBER DEFAULT NULL,
      p_duration                  IN       NUMBER DEFAULT NULL,
      p_duration_uom              IN       VARCHAR2 DEFAULT NULL,
      p_planned_effort            IN       NUMBER DEFAULT NULL,
      p_planned_effort_uom        IN       VARCHAR2 DEFAULT NULL,
      p_private_flag              IN       VARCHAR2 DEFAULT NULL,
      p_publish_flag              IN       VARCHAR2 DEFAULT NULL,
      p_restrict_closure_flag     IN       VARCHAR2 DEFAULT NULL,
      p_multi_booked_flag         IN       VARCHAR2 DEFAULT NULL,
      p_milestone_flag            IN       VARCHAR2 DEFAULT NULL,
      p_holiday_flag              IN       VARCHAR2 DEFAULT NULL,
      p_billable_flag             IN       VARCHAR2 DEFAULT NULL,
      p_notification_flag         IN       VARCHAR2 DEFAULT NULL,
      p_notification_period       IN       NUMBER DEFAULT NULL,
      p_notification_period_uom   IN       VARCHAR2 DEFAULT NULL,
      p_alarm_start               IN       NUMBER DEFAULT NULL,
      p_alarm_start_uom           IN       VARCHAR2 DEFAULT NULL,
      p_alarm_on                  IN       VARCHAR2 DEFAULT NULL,
      p_alarm_count               IN       NUMBER DEFAULT NULL,
      p_alarm_interval            IN       NUMBER DEFAULT NULL,
      p_alarm_interval_uom        IN       VARCHAR2 DEFAULT NULL,
      p_task_depends_tbl          IN       task_depends_tbl
            DEFAULT g_miss_task_depends_tbl,
      p_task_rsrc_req_tbl         IN       task_rsrc_req_tbl
            DEFAULT g_miss_task_rsrc_req_tbl,
      p_task_recur_rec            IN       task_recur_rec
            DEFAULT g_miss_task_recur_rec,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      x_task_id                   OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null
   )
   IS
      l_api_version   CONSTANT NUMBER                              := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)
               := 'CREATE_TASK_TEMPLATES';


   BEGIN
      SAVEPOINT create_task_pub1;
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

      jtf_task_templates_pvt.create_task
      (
      p_api_version          => p_api_version,
      p_init_msg_list        => p_init_msg_list,
      p_commit               => p_commit,
      p_task_id              => p_task_id,
      p_task_name            => p_task_name,
      p_task_group_id        => p_task_group_id,
      p_task_type_id         => p_task_type_id,
      p_description          => p_description,
      p_task_status_id       => p_task_status_id,
      p_task_priority_id	 => p_task_priority_id,
      p_duration	    => p_duration,
	  p_duration_uom 	=> p_duration_uom,
      p_planned_effort	=> p_planned_effort,
	  p_planned_effort_uom	    => p_planned_effort_uom,
      p_private_flag 	=> p_private_flag,
	  p_publish_flag 	=> p_publish_flag,
      p_restrict_closure_flag    => p_restrict_closure_flag,
	  p_multi_booked_flag	    => p_multi_booked_flag,
      p_milestone_flag	=> p_milestone_flag,
	  p_holiday_flag 	=> p_holiday_flag,
	  p_billable_flag	=> p_billable_flag,
      p_notification_flag	    => p_notification_flag,
	  p_notification_period	    => p_notification_period,
	  p_notification_period_uom  => p_notification_period_uom,
      p_alarm_start		=> p_alarm_start,
	  p_alarm_start_uom	=> p_alarm_start_uom,
	  p_alarm_on	    => p_alarm_on,
	  p_alarm_count		=> p_alarm_count,
      p_alarm_interval	=> p_alarm_interval,
	  p_alarm_interval_uom	    => p_alarm_interval_uom,
      x_return_status	=> x_return_status,
	  x_msg_count		=> x_msg_count,
	  x_msg_data	    => x_msg_data,
	  x_task_id	        => x_task_id,
      p_attribute1		=> p_attribute1,
	  p_attribute2		=> p_attribute2,
	  p_attribute3		=> p_attribute3,
	  p_attribute4		=> p_attribute4,
	  p_attribute5		=> p_attribute5,
	  p_attribute6		=> p_attribute6,
	  p_attribute7		=> p_attribute7,
	  p_attribute8		=> p_attribute8,
	  p_attribute9		=> p_attribute9,
	  p_attribute10		=> p_attribute10,
	  p_attribute11		=> p_attribute11,
	  p_attribute12		=> p_attribute12,
	  p_attribute13		=> p_attribute13,
	  p_attribute14		=> p_attribute14,
	  p_attribute15		=> p_attribute15,
      p_attribute_category	=> p_attribute_category,
      p_task_confirmation_status => 'N'

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
         ROLLBACK TO create_task_pub1;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_task_pub1;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

    -- Overloading for Simplex
    PROCEDURE create_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_group_id           IN       NUMBER default null,
        p_task_group_name         IN       VARCHAR2 DEFAULT NULL,
        p_task_name               IN       VARCHAR2,
        p_task_type_name          IN       VARCHAR2 DEFAULT NULL,
        p_task_type_id            IN       NUMBER DEFAULT NULL,
        p_description             IN       VARCHAR2 DEFAULT NULL,
        p_task_status_name        IN       VARCHAR2 DEFAULT NULL,
        p_task_status_id          IN       NUMBER DEFAULT NULL,
        p_task_priority_name      IN       VARCHAR2 DEFAULT NULL,
        p_task_priority_id        IN       NUMBER DEFAULT NULL,
        p_duration                IN       NUMBER DEFAULT NULL,
        p_duration_uom            IN       VARCHAR2 DEFAULT NULL,
        p_planned_effort          IN       NUMBER DEFAULT NULL,
        p_planned_effort_uom      IN       VARCHAR2 DEFAULT NULL,
        p_private_flag            IN       VARCHAR2 DEFAULT NULL,
        p_publish_flag            IN       VARCHAR2 DEFAULT NULL,
        p_restrict_closure_flag   IN       VARCHAR2 DEFAULT NULL,
        p_multi_booked_flag       IN       VARCHAR2 DEFAULT NULL,
        p_milestone_flag          IN       VARCHAR2 DEFAULT NULL,
        p_holiday_flag            IN       VARCHAR2 DEFAULT NULL,
        p_billable_flag           IN       VARCHAR2 DEFAULT NULL,
        p_notification_flag       IN       VARCHAR2 DEFAULT NULL,
        p_notification_period     IN       NUMBER DEFAULT NULL,
        p_notification_period_uom IN       VARCHAR2 DEFAULT NULL,
        p_alarm_start             IN       NUMBER DEFAULT NULL,
        p_alarm_start_uom         IN       VARCHAR2 DEFAULT NULL,
        p_alarm_on                IN       VARCHAR2 DEFAULT NULL,
        p_alarm_count             IN       NUMBER DEFAULT NULL,
        p_alarm_interval          IN       NUMBER DEFAULT NULL,
        p_alarm_interval_uom      IN       VARCHAR2 DEFAULT NULL,
        p_task_depends_tbl        IN       task_depends_tbl DEFAULT g_miss_task_depends_tbl,
        p_task_rsrc_req_tbl       IN       task_rsrc_req_tbl DEFAULT g_miss_task_rsrc_req_tbl,
        p_task_recur_rec          IN       task_recur_rec DEFAULT g_miss_task_recur_rec,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_task_id                 OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null ,
        p_task_confirmation_status IN      VARCHAR2
    )
    IS
        l_api_version    CONSTANT NUMBER                                       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                                 := 'CREATE_TASK_TEMPLATES';
        l_task_id                 jtf_tasks_b.task_id%TYPE;
        l_task_number             jtf_tasks_b.task_number%TYPE;
        l_task_name               jtf_tasks_tl.task_name%TYPE                  := p_task_name;
        l_task_type_id            jtf_tasks_b.task_type_id%TYPE                := p_task_type_id;
        l_task_priority_id        jtf_tasks_b.task_priority_id%TYPE            := p_task_priority_id;
        l_task_status_id          jtf_tasks_b.task_status_id%TYPE              := p_task_status_id;
        l_dependency_id           jtf_task_depends.dependency_id%TYPE;
        l_recurrence_rule_id      jtf_task_recur_rules.recurrence_rule_id%TYPE;
        l_task_rec                jtf_task_recurrences_pub.task_details_rec;
        l_task_group_id           jtf_task_templates_b.task_group_id%TYPE;
        l_description             jtf_task_templates_tl.description%TYPE       := p_description;
        l_reccurence_generated    NUMBER;
        l_type                    VARCHAR2(10);
        current_record            INTEGER;
        x                         CHAR;
        l_task_confirmation_status jtf_task_templates_b.task_confirmation_status%TYPE;

        CURSOR c_task_templates
        IS
            SELECT 1
              FROM jtf_task_templates_b
             WHERE task_template_id = x_task_id;
    BEGIN
        SAVEPOINT create_task_pub;
        x_return_status := fnd_api.g_ret_sts_success;


        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -------
        -------   Validate Task Type
        -------
        jtf_task_utl.validate_task_type (
            p_task_type_id => p_task_type_id,
            p_task_type_name => p_task_type_name,
            x_return_status => x_return_status,
            x_task_type_id => l_task_type_id
        );

        IF l_task_type_id IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TYPE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Validate Task Status
        -------
        if l_task_type_id = '22' then
           l_type := 'ESCALATION';
        else
           l_type := 'TASK';
        end if;

        jtf_task_utl.validate_task_status (
            p_task_status_id => p_task_status_id,
            p_task_status_name => p_task_status_name,
            p_validation_type => l_type,
            x_return_status => x_return_status,
            x_task_status_id => l_task_status_id
        );

        IF l_task_status_id IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_STATUS');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


        -------
        -------   Validate Task Priority
        -------
        jtf_task_utl.validate_task_priority (
            p_task_priority_id => p_task_priority_id,
            p_task_priority_name => p_task_priority_name,
            x_return_status => x_return_status,
            x_task_priority_id => l_task_priority_id
        );


        -------
        -------   Validate Duration
        -------
        jtf_task_utl.validate_effort (
            p_tag => 'Duration',
            p_tag_uom => 'Duration UOM',
            x_return_status => x_return_status,
            p_effort => p_duration,
            p_effort_uom => p_duration_uom
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Validate Planned Effort
        -------
        jtf_task_utl.validate_effort (
        p_tag => 'Planned Effort',
        p_tag_uom => 'Planned Effort Unit of Measure',
        x_return_status => x_return_status,
        p_effort => p_planned_effort,
        p_effort_uom => p_planned_effort_uom);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the private flag
        -------
        jtf_task_utl.validate_flag (x_return_status => x_return_status, p_flag_name => 'Private Flag', p_flag_value => p_private_flag);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        -------
        -------   Call the publish flag
        -------
        jtf_task_utl.validate_flag (x_return_status => x_return_status, p_flag_name => 'Publish Flag', p_flag_value => p_publish_flag);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the Restrict closure  flag
        -------
        jtf_task_utl.validate_flag (
            p_api_name => l_api_name,
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            p_flag_name => 'Restrict Closure Flag',
            p_flag_value => p_restrict_closure_flag
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the Multi Booked flag
        -------
        jtf_task_utl.validate_flag (
            p_api_name => l_api_name,
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            p_flag_name => 'Multi Booked Flag',
            p_flag_value => p_multi_booked_flag
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the milestone flag
        -------
        jtf_task_utl.validate_flag (
            p_api_name => l_api_name,
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            p_flag_name => 'Milestone Flag',
            p_flag_value => p_milestone_flag
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the Holiday Flag
        -------
        jtf_task_utl.validate_flag (
            p_api_name => l_api_name,
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            p_flag_name => 'Holiday Flag',
            p_flag_value => p_holiday_flag
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the Billable Flag
        -------
        jtf_task_utl.validate_flag (x_return_status => x_return_status, p_flag_name => 'Billable Flag', p_flag_value => p_billable_flag);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------   Call the Validate Notification Parameters
        -------
        jtf_task_utl.validate_notification (
            p_notification_flag => p_notification_flag,
            p_notification_period => p_notification_period,
            p_notification_period_uom => p_notification_period_uom,
            x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


        -------
        -------   Call the Validate Task Template Group
        -------
        jtf_task_utl.validate_task_template_group (
                    p_task_template_group_id => p_task_group_id ,
                    p_task_template_group_name => p_task_group_name,
                    x_return_status => x_return_status ,
                    x_task_template_group_id => l_task_group_id );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        if l_task_group_id is null then
            fnd_message.set_name('JTF', 'JTF_TASK_MISSING_GROUP');
            fnd_msg_pub.add ;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        end if ;



        jtf_task_templates_pvt.create_task (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_task_id => l_task_id,
            p_task_name => l_task_name,
            p_task_group_id => l_task_group_id,
            p_task_type_id => l_task_type_id,
            p_description => l_description,
            p_task_status_id => l_task_status_id,
            p_task_priority_id => l_task_priority_id,
            p_duration => p_duration,
            p_duration_uom => p_duration_uom,
            p_planned_effort => p_planned_effort,
            p_planned_effort_uom => p_planned_effort_uom,
            p_private_flag => p_private_flag,
            p_publish_flag => p_publish_flag,
            p_restrict_closure_flag => p_restrict_closure_flag,
            p_multi_booked_flag => p_multi_booked_flag,
            p_milestone_flag => p_milestone_flag,
            p_holiday_flag => p_holiday_flag,
            p_billable_flag => p_billable_flag,
            p_notification_flag => p_notification_flag,
            p_notification_period => p_notification_period,
            p_notification_period_uom => p_notification_period_uom,
            p_alarm_start => p_alarm_start,
            p_alarm_start_uom => p_alarm_start_uom,
            p_alarm_on => p_alarm_on,
            p_alarm_count => p_alarm_count,
            p_alarm_interval => p_alarm_interval,
            p_alarm_interval_uom => p_alarm_interval_uom,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_task_id => x_task_id,
            p_attribute1 => p_attribute1 ,
            p_attribute2 => p_attribute2 ,
            p_attribute3 => p_attribute3 ,
            p_attribute4 => p_attribute4 ,
            p_attribute5 => p_attribute5 ,
            p_attribute6 => p_attribute6 ,
            p_attribute7 => p_attribute7 ,
            p_attribute8 => p_attribute8 ,
            p_attribute9 => p_attribute9 ,
            p_attribute10 => p_attribute10 ,
            p_attribute11 => p_attribute11 ,
            p_attribute12 => p_attribute12 ,
            p_attribute13 => p_attribute13 ,
            p_attribute14 => p_attribute14 ,
            p_attribute15 => p_attribute15,
            p_attribute_category => p_attribute_category,
            p_task_confirmation_status => l_task_confirmation_status
        );





        OPEN c_task_templates;
        FETCH c_task_templates INTO x;

        IF c_task_templates%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_ERROR_CREATING_TEMP');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -------
        -------
        -------   Create the dependencies
        -------
        -------

        IF p_task_depends_tbl.COUNT > 0
        THEN

            current_record := p_task_depends_tbl.FIRST;

            FOR i IN 1 .. p_task_depends_tbl.COUNT
            LOOP

                jtf_task_dependency_pub.create_task_dependency (
                    p_api_version => 1.0,
                    p_init_msg_list => fnd_api.g_false,
                    p_commit => fnd_api.g_false,
                    p_validation_level => fnd_api.g_valid_level_full,
                    p_task_id => x_task_id,
                    p_dependent_on_task_id => p_task_depends_tbl (current_record).dependent_on_task_id,
                    p_dependent_on_task_number => p_task_depends_tbl (current_record).dependent_on_task_number,
                    p_dependency_type_code => p_task_depends_tbl (current_record).dependency_type_code,
                    p_template_flag => jtf_task_utl.g_yes,
                    p_adjustment_time => p_task_depends_tbl (current_record).adjustment_time,
                    p_adjustment_time_uom => p_task_depends_tbl (current_record).adjustment_time_uom,
                    p_validated_flag => p_task_depends_tbl (current_record).validated_flag,
                    x_dependency_id => l_dependency_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data
                );


                IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                THEN
                    x_return_status := fnd_api.g_ret_sts_unexp_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                current_record := p_task_depends_tbl.NEXT (current_record);
            END LOOP;
        END IF;

        -------
        -------
        -------   Create recurrences
        -------
        ------- Creatinf Recurrence rule

        IF (  p_task_recur_rec.occurs_which IS NOT NULL
           OR p_task_recur_rec.day_of_week IS NOT NULL
           OR p_task_recur_rec.date_of_month IS NOT NULL
           OR p_task_recur_rec.occurs_month IS NOT NULL
           OR p_task_recur_rec.occurs_uom IS NOT NULL
           OR p_task_recur_rec.occurs_every IS NOT NULL
           OR p_task_recur_rec.occurs_number IS NOT NULL
           OR p_task_recur_rec.start_date_active IS NOT NULL
           OR p_task_recur_rec.end_date_active IS NOT NULL)
        THEN
            jtf_task_recurrences_pub.create_task_recurrence (
                p_api_version => 1.0,
                p_init_msg_list => fnd_api.g_false,
                p_commit => fnd_api.g_false,
                p_task_id => x_task_id,
                p_occurs_which => p_task_recur_rec.occurs_which,
                p_template_flag => jtf_task_utl.g_yes,
                p_day_of_week => p_task_recur_rec.day_of_week,
                p_date_of_month => p_task_recur_rec.date_of_month,
                p_occurs_month => p_task_recur_rec.occurs_month,
                p_occurs_uom => p_task_recur_rec.occurs_uom,
                p_occurs_every => p_task_recur_rec.occurs_every,
                p_occurs_number => p_task_recur_rec.occurs_number,
                p_start_date_active => p_task_recur_rec.start_date_active,
                p_end_date_active => p_task_recur_rec.end_date_active,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                x_recurrence_rule_id => l_recurrence_rule_id,
                x_task_rec => l_task_rec,
                x_reccurences_generated => l_reccurence_generated
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;



        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN


            ROLLBACK TO create_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN



            ROLLBACK TO create_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

   PROCEDURE lock_task (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id           IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   ) is
        l_api_version    CONSTANT NUMBER                                 := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                           := 'LOCK_TASK_TEMPLATES';


        Resource_Locked exception ;

        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;

   begin
        SAVEPOINT lock_task_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        x_return_status := fnd_api.g_ret_sts_success;

        jtf_task_templates_pkg.lock_row(
            x_task_template_id => p_task_id ,
            x_object_version_number => p_object_version_number  );


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
       WHEN Resource_Locked then
            ROLLBACK TO lock_task_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO lock_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO lock_task_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;



    PROCEDURE update_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN     OUT NOCOPY NUMBER ,
        p_task_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_number             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_group_id           IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_type_name          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_type_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_description             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_status_name        IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_status_id          IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_priority_name      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_priority_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_duration                IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_duration_uom            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_planned_effort          IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_planned_effort_uom      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_private_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_publish_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_restrict_closure_flag   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_multi_booked_flag       IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_milestone_flag          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_holiday_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_billable_flag           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_notification_flag       IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_notification_period     IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_notification_period_uom IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_start             IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_start_uom         IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_on                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_count             IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_interval          IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_interval_uom      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_task_confirmation_status IN      VARCHAR2
    ) is
        l_api_version       CONSTANT NUMBER                                      := 1.0;
        l_api_name          CONSTANT VARCHAR2(30)                                := 'UPDATE_TASK_TEMPLATE';
        l_task_id                    jtf_task_templates_b.task_template_id%TYPE                    := p_task_id;
        l_task_number                jtf_task_templates_b.task_number%TYPE                := p_task_number;
        l_task_name                  jtf_task_templates_tl.task_name%TYPE                 := p_task_name;
        l_task_type_name             jtf_task_types_tl.name%TYPE                 := p_task_type_name;
        l_task_type_id               jtf_task_types_b.task_type_id%TYPE          := p_task_type_id;
        l_task_status_name           jtf_task_statuses_tl.name%TYPE              := p_task_status_name;
        l_task_status_id             jtf_task_statuses_b.task_status_id%TYPE     := p_task_status_id;
        l_task_priority_name         jtf_task_priorities_tl.name%TYPE            := p_task_priority_name;
        l_task_priority_id           jtf_task_priorities_b.task_priority_id%TYPE := p_task_priority_id;
        l_duration                   jtf_task_templates_b.duration%TYPE;
        l_duration_uom               jtf_task_templates_b.duration_uom%TYPE;
        l_private_flag               jtf_task_templates_b.private_flag%TYPE;
        l_publish_flag               jtf_task_templates_b.publish_flag%TYPE;
        l_restrict_closure_flag      jtf_task_templates_b.restrict_closure_flag%TYPE;
        l_multi_booked_flag          jtf_task_templates_b.multi_booked_flag%TYPE;
        l_description                jtf_task_templates_tl.description%TYPE;
        l_planned_effort             jtf_task_templates_b.planned_effort%TYPE;
        l_planned_effort_uom         jtf_task_templates_b.planned_effort_uom%TYPE;
        l_milestone_flag             jtf_task_templates_b.milestone_flag%TYPE;
        l_holiday_flag               jtf_task_templates_b.holiday_flag%TYPE;
        l_notification_flag          jtf_task_templates_b.notification_flag%TYPE;
        l_notification_period        jtf_task_templates_b.notification_period%TYPE;
        l_notification_period_uom    jtf_task_templates_b.notification_period_uom%TYPE;
        l_billable_flag              jtf_task_templates_b.billable_flag%TYPE;
        l_alarm_start                jtf_task_templates_b.alarm_start%TYPE;
        l_alarm_start_uom            jtf_task_templates_b.alarm_start_uom%TYPE;
        l_alarm_on                   jtf_task_templates_b.alarm_on%TYPE;
        l_alarm_count                jtf_task_templates_b.alarm_count%TYPE;
        l_alarm_interval             jtf_task_templates_b.alarm_interval%TYPE;
        l_alarm_interval_uom         jtf_task_templates_b.alarm_interval_uom%TYPE;
        l_type                       varchar2(10);
        l_task_confirmation_status   jtf_task_templates_b.task_confirmation_status%TYPE;


        CURSOR c_task_update (
            l_task_id                 IN       NUMBER
        )
        IS
            SELECT DECODE (p_task_id, fnd_api.g_miss_num, task_template_id, p_task_id) task_id,
                   DECODE (p_task_number, fnd_api.g_miss_char, task_number, p_task_number) task_number,
                   DECODE (p_task_name, fnd_api.g_miss_char, task_name, p_task_name) task_name,
                   DECODE (p_task_type_id, fnd_api.g_miss_num, task_type_id, p_task_type_id) task_type_id,
                   DECODE (p_description, fnd_api.g_miss_char, description, p_description) description,
                   DECODE (p_task_status_id, fnd_api.g_miss_num, task_status_id, p_task_status_id) task_status_id,
                   DECODE (p_task_priority_id, fnd_api.g_miss_num, task_priority_id, p_task_priority_id) task_priority_id,
                   DECODE (p_duration, fnd_api.g_miss_num, duration, p_duration) duration,
                   DECODE (p_duration_uom, fnd_api.g_miss_char, duration_uom, p_duration_uom) duration_uom,
                   DECODE (p_planned_effort, fnd_api.g_miss_num, planned_effort, p_planned_effort) planned_effort,
                   DECODE (p_planned_effort_uom, fnd_api.g_miss_char, planned_effort_uom, p_planned_effort_uom) planned_effort_uom,
                   DECODE (p_private_flag, fnd_api.g_miss_char, private_flag, p_private_flag) private_flag,
                   DECODE (p_publish_flag, fnd_api.g_miss_char, publish_flag, p_publish_flag) publish_flag,
                   DECODE (p_restrict_closure_flag, fnd_api.g_miss_char, restrict_closure_flag, p_restrict_closure_flag) restrict_closure_flag,
                   DECODE (p_multi_booked_flag, fnd_api.g_miss_char, multi_booked_flag, p_multi_booked_flag) multi_booked_flag,
                   DECODE (p_milestone_flag, fnd_api.g_miss_char, milestone_flag, p_milestone_flag) milestone_flag,
                   DECODE (p_holiday_flag, fnd_api.g_miss_char, holiday_flag, p_holiday_flag) holiday_flag,
                   DECODE (p_billable_flag, fnd_api.g_miss_char, billable_flag, p_billable_flag) billable_flag,
                   DECODE (p_notification_flag, fnd_api.g_miss_char, notification_flag, p_notification_flag) notification_flag,
                   DECODE (p_notification_period, fnd_api.g_miss_num, notification_period, p_notification_period) notification_period,
                   DECODE (p_notification_period_uom, fnd_api.g_miss_char, notification_period_uom, p_notification_period_uom) notification_period_uom,
                   DECODE (p_alarm_start, fnd_api.g_miss_num, alarm_start, p_alarm_start) alarm_start,
                   DECODE (p_alarm_start_uom, fnd_api.g_miss_char, alarm_start_uom, p_alarm_start_uom) alarm_start_uom,
                   DECODE (p_alarm_on, fnd_api.g_miss_char, alarm_on, p_alarm_on) alarm_on,
                   DECODE (p_alarm_count, fnd_api.g_miss_num, alarm_count, p_alarm_count) alarm_count,
                   DECODE (p_alarm_interval, fnd_api.g_miss_num, alarm_interval, p_alarm_interval) alarm_interval,
                   DECODE (p_alarm_interval_uom, fnd_api.g_miss_char, alarm_interval_uom, p_alarm_interval_uom) alarm_interval_uom,
decode( p_attribute1 , fnd_api.g_miss_char , attribute1 , p_attribute1 )  attribute1  ,
decode( p_attribute2 , fnd_api.g_miss_char , attribute2 , p_attribute2 )  attribute2  ,
decode( p_attribute3 , fnd_api.g_miss_char , attribute3 , p_attribute3 )  attribute3  ,
decode( p_attribute4 , fnd_api.g_miss_char , attribute4 , p_attribute4 )  attribute4  ,
decode( p_attribute5 , fnd_api.g_miss_char , attribute5 , p_attribute5 )  attribute5  ,
decode( p_attribute6 , fnd_api.g_miss_char , attribute6 , p_attribute6 )  attribute6  ,
decode( p_attribute7 , fnd_api.g_miss_char , attribute7 , p_attribute7 )  attribute7  ,
decode( p_attribute8 , fnd_api.g_miss_char , attribute8 , p_attribute8 )  attribute8  ,
decode( p_attribute9 , fnd_api.g_miss_char , attribute9 , p_attribute9 )  attribute9  ,
decode( p_attribute10 , fnd_api.g_miss_char , attribute10 , p_attribute10 )  attribute10  ,
decode( p_attribute11 , fnd_api.g_miss_char , attribute11 , p_attribute11 )  attribute11  ,
decode( p_attribute12 , fnd_api.g_miss_char , attribute12 , p_attribute12 )  attribute12  ,
decode( p_attribute13 , fnd_api.g_miss_char , attribute13 , p_attribute13 )  attribute13  ,
decode( p_attribute14 , fnd_api.g_miss_char , attribute14 , p_attribute14 )  attribute14  ,
decode( p_attribute15 , fnd_api.g_miss_char , attribute15 , p_attribute15 )  attribute15 ,
decode( p_attribute_category,fnd_api.g_miss_char,attribute_category,p_attribute_category) attribute_category,
decode( p_task_confirmation_status,jtf_task_utl.g_miss_char,task_confirmation_status,p_task_confirmation_status)
task_confirmation_status
              FROM jtf_task_templates_vl
             WHERE task_template_id = l_task_id;

        task_rec                     c_task_update%ROWTYPE;

    BEGIN

        SAVEPOINT update_task_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;



        -----
        -----   Validate Tasks
        -----
        IF (   l_task_id = fnd_api.g_miss_num
           AND l_task_number = fnd_api.g_miss_char)
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            SELECT DECODE (l_task_id, fnd_api.g_miss_num, NULL, l_task_id)
              INTO l_task_id
              FROM dual;
            SELECT DECODE (l_task_number, fnd_api.g_miss_char, NULL, l_task_number)
              INTO l_task_number
              FROM dual;
            jtf_task_utl.validate_task_template (
                p_task_id => l_task_id,
                p_task_number => l_task_number,
                x_task_id => l_task_id,
                x_return_status => x_return_status
            );



            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_task_id IS NULL
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;



        -----
        -----     Task Name
        -----
        IF l_task_name IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP_NAME');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -----
        -----     Task Description
        -----
        OPEN c_task_update (l_task_id);
        FETCH c_task_update INTO task_rec;

        IF c_task_update%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;




        -----
        -----     Task Type
        -----
        IF (   l_task_type_name = fnd_api.g_miss_char
           AND l_task_type_id = fnd_api.g_miss_num)
        THEN
            l_task_type_id := task_rec.task_type_id;
        ELSIF (   l_task_type_name = fnd_api.g_miss_char
              AND l_task_type_id <> fnd_api.g_miss_num)
        THEN
            jtf_task_utl.validate_task_type (
                p_task_type_id => l_task_type_id,
                p_task_type_name => NULL,
                x_return_status => x_return_status,
                x_task_type_id => l_task_type_id
            );
        ELSIF (   l_task_type_name <> fnd_api.g_miss_char
              AND l_task_type_id = fnd_api.g_miss_num)
        THEN
            jtf_task_utl.validate_task_type (
                p_task_type_id => NULL,
                p_task_type_name => l_task_type_name,
                x_return_status => x_return_status,
                x_task_type_id => l_task_type_id
            );
        ELSE
            jtf_task_utl.validate_task_type (
                p_task_type_id => l_task_type_id,
                p_task_type_name => l_task_type_name,
                x_return_status => x_return_status,
                x_task_type_id => l_task_type_id
            );
        END IF;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_task_type_id IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TYPE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        -----
        -----   Task Status
        -----
        if l_task_type_id = '22' then
           l_type := 'ESCALATION';
        else
           l_type := 'TASK';
        end if;

        IF ( l_task_status_name = fnd_api.g_miss_char
           AND l_task_status_id = fnd_api.g_miss_num)
        THEN
            l_task_status_id := task_rec.task_status_id;
        ELSIF (   l_task_status_name = fnd_api.g_miss_char
              AND l_task_status_id <> fnd_api.g_miss_num)
        THEN
            jtf_task_utl.validate_task_status (
                p_task_status_id => l_task_status_id,
                p_task_status_name => NULL,
                p_validation_type => l_type,
                x_return_status => x_return_status,
                x_task_status_id => l_task_status_id
            );
        ELSIF (   l_task_status_name <> fnd_api.g_miss_char
              AND l_task_status_id = fnd_api.g_miss_num)
        THEN
            jtf_task_utl.validate_task_status (
                p_task_status_id => NULL,
                p_task_status_name => l_task_status_name,
                p_validation_type => l_type,
                x_return_status => x_return_status,
                x_task_status_id => l_task_status_id
            );
        ELSE
            jtf_task_utl.validate_task_status (
                p_task_status_id => l_task_status_id,
                p_task_status_name => l_task_status_name,
                p_validation_type => l_type,
                x_return_status => x_return_status,
                x_task_status_id => l_task_status_id
            );
        END IF;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_task_status_id IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_STATUS');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        --------
        --------  Task Priority
        --------
        IF (   l_task_priority_name = fnd_api.g_miss_char
           AND l_task_priority_id = fnd_api.g_miss_num)
        THEN
            l_task_priority_id := task_rec.task_priority_id;
        ELSIF (   l_task_priority_name = fnd_api.g_miss_char
              AND l_task_priority_id <> fnd_api.g_miss_num)
        THEN
            jtf_task_utl.validate_task_priority (
                p_task_priority_id => l_task_priority_id,
                p_task_priority_name => NULL,
                x_return_status => x_return_status,
                x_task_priority_id => l_task_priority_id
            );
        ELSIF (   l_task_priority_name <> fnd_api.g_miss_char
              AND l_task_priority_id = fnd_api.g_miss_num)
        THEN
            jtf_task_utl.validate_task_priority (
                p_task_priority_id => NULL,
                p_task_priority_name => l_task_priority_name,
                x_return_status => x_return_status,
                x_task_priority_id => l_task_priority_id
            );
        ELSE
            jtf_task_utl.validate_task_priority (
                p_task_priority_id => l_task_priority_id,
                p_task_priority_name => l_task_priority_name,
                x_return_status => x_return_status,
                x_task_priority_id => l_task_priority_id
            );
        END IF;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

     ----------
    ----------  Validate duration
    ----------
        IF (  p_duration <> fnd_api.g_miss_num
           OR p_duration_uom <> fnd_api.g_miss_char
           OR p_duration IS NULL
           OR p_duration_uom IS NULL)
        THEN
            IF    (p_duration <> fnd_api.g_miss_num)
               OR (p_duration IS NULL)
            THEN
                l_duration := p_duration;
            ELSE
                l_duration := task_rec.duration;
            END IF;

            IF    p_duration_uom <> fnd_api.g_miss_char
               OR (p_duration_uom IS NULL)
            THEN
                l_duration_uom := p_duration_uom;
            ELSE
                l_duration_uom := task_rec.duration_uom;
            END IF;

            jtf_task_utl.validate_effort (
                p_tag => 'Duration',
                p_tag_uom => 'Duration UOM',
                p_effort => l_duration,
                p_effort_uom => l_duration_uom,
                x_return_status => x_return_status
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

    ----------
    ----------  Validate planned_effort
    ----------

        l_planned_effort := task_rec.planned_effort;
        l_planned_effort_uom := task_rec.planned_effort_uom ;

        IF (  p_planned_effort <> fnd_api.g_miss_num
           OR p_planned_effort_uom <> fnd_api.g_miss_char
           OR p_planned_effort IS NULL
           OR p_planned_effort_uom IS NULL)
        THEN
/*            IF    (p_planned_effort <> fnd_api.g_miss_num)
               OR (p_planned_effort IS NULL)
            THEN
                l_planned_effort := p_planned_effort;
            ELSE
                l_planned_effort := task_rec.planned_effort;
            END IF;

            IF    p_planned_effort_uom <> fnd_api.g_miss_char
               OR (p_planned_effort_uom IS NULL)
            THEN
                l_planned_effort_uom := p_planned_effort_uom;
            ELSE
                l_planned_effort_uom := task_rec.planned_effort_uom;
            END IF;
*/


            jtf_task_utl.validate_effort (
                p_tag => 'Planned Effort',
                p_tag_uom => 'Planned Effort Unit of Measure',
                p_effort => l_planned_effort,
                p_effort_uom => l_planned_effort_uom,
                x_return_status => x_return_status
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        IF p_private_flag <> fnd_api.g_miss_char
        THEN
            jtf_task_utl.validate_flag (p_flag_name => 'Private Flag', p_flag_value => p_private_flag, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_private_flag := p_private_flag;
        ELSE
            l_private_flag := task_rec.private_flag;
        END IF;

        -------
        ------- Validate publish flag
        -------
        IF    p_publish_flag <> fnd_api.g_miss_char
           OR p_publish_flag IS NULL
        THEN
            jtf_task_utl.validate_flag (p_flag_name => 'Publish Flag', p_flag_value => p_publish_flag, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_publish_flag := p_publish_flag;
        ELSE
            l_publish_flag := task_rec.publish_flag;
        END IF;



        -------
        ------- Validate restrict closure flag
        -------
        IF    p_restrict_closure_flag <> fnd_api.g_miss_char
           OR p_restrict_closure_flag IS NULL
        THEN
            jtf_task_utl.validate_flag (
                p_flag_name => 'Restrict Closure Flag',
                p_flag_value => p_restrict_closure_flag,
                x_return_status => x_return_status
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_restrict_closure_flag := p_restrict_closure_flag;
        ELSE
            l_restrict_closure_flag := task_rec.restrict_closure_flag;
        END IF;

        -------
        ------- Validate multibooked flag
        -------
        IF    p_multi_booked_flag <> fnd_api.g_miss_char
           OR p_multi_booked_flag IS NULL
        THEN
            jtf_task_utl.validate_flag (p_flag_name => 'Multi Booked Flag', p_flag_value => p_multi_booked_flag, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_multi_booked_flag := p_multi_booked_flag;
        ELSE
            l_multi_booked_flag := task_rec.multi_booked_flag;
        END IF;

        -------
        ------- Validate milestone flag
        -------
        IF    p_milestone_flag <> fnd_api.g_miss_char
           OR p_milestone_flag IS NULL
        THEN
            jtf_task_utl.validate_flag (p_flag_name => 'Milestone Flag', p_flag_value => p_milestone_flag, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_milestone_flag := p_milestone_flag;
        ELSE
            l_milestone_flag := task_rec.milestone_flag;
        END IF;

        -------
        ------- Validate holiday flag
        -------

        IF    p_holiday_flag <> fnd_api.g_miss_char
           OR p_holiday_flag IS NULL
        THEN
            jtf_task_utl.validate_flag (p_flag_name => 'Holiday Flag', p_flag_value => p_holiday_flag, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_holiday_flag := p_holiday_flag;
        ELSE
            l_holiday_flag := task_rec.holiday_flag;
        END IF;

        -------
        ------- Validate billable flag
        -------

        IF p_billable_flag <> fnd_api.g_miss_char
        THEN
            jtf_task_utl.validate_flag (p_flag_name => 'Billable Flag', p_flag_value => p_billable_flag, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_billable_flag := p_billable_flag;
        ELSE
            l_billable_flag := task_rec.billable_flag;
        END IF;

    -----------
    -----------   Validate alarm
    -----------

        IF (  p_alarm_start <> fnd_api.g_miss_num
           OR p_alarm_start_uom <> fnd_api.g_miss_char
           OR p_alarm_on <> fnd_api.g_miss_char
           OR p_alarm_count <> fnd_api.g_miss_num
           OR p_alarm_interval <> fnd_api.g_miss_num
           OR p_alarm_interval_uom <> fnd_api.g_miss_char
           OR p_alarm_start IS NULL
           OR p_alarm_start_uom IS NULL
           OR p_alarm_on IS NULL
           OR p_alarm_count IS NULL
           OR p_alarm_interval IS NULL
           OR p_alarm_interval_uom IS NULL)
        THEN
            l_alarm_start := task_rec.alarm_start;
            l_alarm_start_uom := task_rec.alarm_start_uom;
            l_alarm_on := task_rec.alarm_on;
            l_alarm_interval := task_rec.alarm_interval;
            l_alarm_interval_uom := task_rec.alarm_interval_uom;
            l_alarm_count := task_rec.alarm_count;
            jtf_task_utl.validate_alarm (
                p_alarm_start => l_alarm_start,
                p_alarm_start_uom => l_alarm_start_uom,
                p_alarm_on => l_alarm_on,
                p_alarm_count => l_alarm_count,
                p_alarm_interval => l_alarm_interval,
                p_alarm_interval_uom => l_alarm_interval_uom,
                x_return_status => x_return_status
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

        ELSE
            l_alarm_start := task_rec.alarm_start;
            l_alarm_start_uom := task_rec.alarm_start_uom;
            l_alarm_on := task_rec.alarm_on;
            l_alarm_interval := task_rec.alarm_interval;
            l_alarm_interval_uom := task_rec.alarm_interval_uom;
            l_alarm_count := task_rec.alarm_count;
        END IF;



          -------
        ------- Validate Notification
        -------
        IF (  p_notification_period <> fnd_api.g_miss_num
           OR p_notification_period IS NULL
           OR p_notification_period_uom <> fnd_api.g_miss_char
           OR p_notification_period_uom IS NULL
           OR p_notification_flag <> fnd_api.g_miss_char
           OR p_notification_flag IS NULL)
        THEN
                   l_notification_flag := task_rec.notification_flag;
            l_notification_period := task_rec.notification_period;
            l_notification_period_uom := task_rec.notification_period_uom;
             jtf_task_utl.validate_notification (
                p_notification_flag => l_notification_flag,
                p_notification_period => l_notification_period,
                p_notification_period_uom => l_notification_period_uom,
                x_return_status => x_return_status
            );


            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;


        ELSE
            l_notification_flag := task_rec.notification_flag;
            l_notification_period := task_rec.notification_period;
            l_notification_period_uom := task_rec.notification_period_uom;
        END IF;


      jtf_task_templates_pvt.update_task (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_task_id => l_task_id,
            p_task_name => l_task_name,
            p_task_type_id => l_task_type_id,
            p_description => task_rec.description,
            p_task_status_id => l_task_status_id,
            p_task_priority_id => l_task_priority_id,
            p_duration => l_duration,
            p_duration_uom => l_duration_uom,
            p_planned_effort => l_planned_effort,
            p_planned_effort_uom => l_planned_effort_uom,
            p_private_flag => l_private_flag,
            p_publish_flag => l_publish_flag,
            p_restrict_closure_flag => l_restrict_closure_flag,
            p_multi_booked_flag => l_multi_booked_flag,
            p_milestone_flag => l_milestone_flag,
            p_holiday_flag => l_holiday_flag,
            p_billable_flag => l_billable_flag,
            p_notification_flag => l_notification_flag,
            p_notification_period => l_notification_period,
            p_notification_period_uom => l_notification_period_uom,
            p_alarm_start => l_alarm_start,
            p_alarm_start_uom => l_alarm_start_uom,
            p_alarm_on => l_alarm_on,
            p_alarm_count => l_alarm_count,
            p_alarm_interval => l_alarm_interval,
            p_alarm_interval_uom => l_alarm_interval_uom,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_attribute1 => task_rec.attribute1 ,
            p_attribute2 => task_rec.attribute2 ,
            p_attribute3 => task_rec.attribute3 ,
            p_attribute4 => task_rec.attribute4 ,
            p_attribute5 => task_rec.attribute5 ,
            p_attribute6 => task_rec.attribute6 ,
            p_attribute7 => task_rec.attribute7 ,
            p_attribute8 => task_rec.attribute8 ,
            p_attribute9 => task_rec.attribute9 ,
            p_attribute10 => task_rec.attribute10 ,
            p_attribute11 => task_rec.attribute11 ,
            p_attribute12 => task_rec.attribute12 ,
            p_attribute13 => task_rec.attribute13 ,
            p_attribute14 => task_rec.attribute14 ,
            p_attribute15 => task_rec.attribute15 ,
            p_attribute_category => task_rec.attribute_category,
            p_task_confirmation_status => task_rec.task_confirmation_status
        );
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK TO update_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
        WHEN OTHERS
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            ROLLBACK TO update_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
    END;

       PROCEDURE update_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN     OUT NOCOPY NUMBER ,
        p_task_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_number             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_group_id           IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_type_name          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_type_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_description             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_status_name        IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_status_id          IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_priority_name      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_task_priority_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_duration                IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_duration_uom            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_planned_effort          IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_planned_effort_uom      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_private_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_publish_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_restrict_closure_flag   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_multi_booked_flag       IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_milestone_flag          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_holiday_flag            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_billable_flag           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_notification_flag       IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_notification_period     IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_notification_period_uom IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_start             IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_start_uom         IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_on                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_alarm_count             IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_interval          IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_alarm_interval_uom      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   )
   IS
        l_api_version    CONSTANT NUMBER                       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                 := 'UPDATE_TASK';
   BEGIN
      SAVEPOINT update_task_pub1;
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

      jtf_task_templates_pub.update_task (
	    p_api_version		=> p_api_version,
	    p_init_msg_list		=>  p_init_msg_list,
	    p_commit			=>  p_commit,
	    p_object_version_number	=> p_object_version_number,
	    p_task_id			=> p_task_id,
	    p_task_number 		=> p_task_number,
        p_task_group_id		=> p_task_group_id,
        p_task_name 		=> p_task_name,
        p_task_type_name	=> p_task_type_name,
        p_task_type_id		=> p_task_type_id,
        p_description		=> p_description,
        p_task_status_name	=> p_task_status_name,
	    p_task_status_id		=> p_task_status_id,
        p_task_priority_name	=> p_task_priority_name,
	    p_task_priority_id		=> p_task_priority_id,
        p_duration			=> p_duration,
	    p_duration_uom		=> p_duration_uom,
	    p_planned_effort		=> p_planned_effort,
	    p_planned_effort_uom	=> p_planned_effort_uom,
        p_private_flag		=> p_private_flag,
	    p_publish_flag		=> p_publish_flag,
	    p_restrict_closure_flag	=> p_restrict_closure_flag,
        p_multi_booked_flag 	=> p_multi_booked_flag,
	    p_milestone_flag		=> p_milestone_flag,
	    p_holiday_flag		=> p_holiday_flag,
	    p_billable_flag		=> p_billable_flag,
	    p_notification_flag 	=> p_notification_flag,
	    p_notification_period	=> p_notification_period,
	    p_notification_period_uom	=> p_notification_period_uom,
	    p_alarm_start		=> p_alarm_start,
	    p_alarm_start_uom		=> p_alarm_start_uom,
	    p_alarm_on			=> p_alarm_on,
	    p_alarm_count		=> p_alarm_count,
       --p_alarm_fired_count 	=> p_alarm_fired_count,
	    p_alarm_interval		=> p_alarm_interval,
	    p_alarm_interval_uom	=> p_alarm_interval_uom,
        x_return_status		=> x_return_status,
	    x_msg_count 		=> x_msg_count,
	    x_msg_data			=> x_msg_data,
	    p_attribute1		=> p_attribute1,
	    p_attribute2		=> p_attribute2,
	    p_attribute3		=> p_attribute3,
	    p_attribute4		=> p_attribute4,
	    p_attribute5		=> p_attribute5,
	    p_attribute6		=> p_attribute6,
	    p_attribute7		=> p_attribute7,
	    p_attribute8		=> p_attribute8,
	    p_attribute9		=> p_attribute9,
	    p_attribute10		=> p_attribute10,
	    p_attribute11		=> p_attribute11,
	    p_attribute12		=> p_attribute12,
	    p_attribute13		=> p_attribute13,
	    p_attribute14		=> p_attribute14,
	    p_attribute15		=> p_attribute15,
	    p_attribute_category	=> p_attribute_category,
        p_task_confirmation_status => 'N'
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
         ROLLBACK TO update_task_pub1;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_task_pub1;
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END;

    PROCEDURE delete_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN     NUMBER ,

        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_number             IN       VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    )
    is
        l_api_version    CONSTANT NUMBER                       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                 := 'DELETE_TASK';
        l_task_id                 jtf_tasks_b.task_id%TYPE     := p_task_id;
        l_task_number             jtf_tasks_b.task_number%TYPE := p_task_number;
BEGIN

        SAVEPOINT delete_task_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        IF (   l_task_id IS NULL
           AND l_task_number IS NULL)
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            jtf_task_utl.validate_task_template (
                p_task_id => l_task_id,
                p_task_number => l_task_number,
                x_task_id => l_task_id,
                x_return_status => x_return_status
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        jtf_task_templates_pvt.delete_task (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_task_id => l_task_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO delete_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            ROLLBACK TO delete_task_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;


END;

/
