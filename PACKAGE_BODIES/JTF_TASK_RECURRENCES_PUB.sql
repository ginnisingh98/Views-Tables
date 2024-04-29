--------------------------------------------------------
--  DDL for Package Body JTF_TASK_RECURRENCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_RECURRENCES_PUB" AS
/* $Header: jtfptkub.pls 115.25 2002/12/06 02:00:23 sachoudh ship $ */
    PROCEDURE create_task_recurrence (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_number             IN       VARCHAR2 DEFAULT NULL,
        p_occurs_which            IN       INTEGER DEFAULT NULL,
        p_template_flag           IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_day_of_week             IN       INTEGER DEFAULT NULL,
        p_date_of_month           IN       INTEGER DEFAULT NULL,
        p_occurs_month            IN       INTEGER DEFAULT NULL,
        p_occurs_uom              IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every            IN       INTEGER DEFAULT NULL,
        p_occurs_number           IN       INTEGER DEFAULT NULL,
        p_start_date_active       IN       DATE DEFAULT NULL,
        p_end_date_active         IN       DATE DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_recurrence_rule_id      OUT NOCOPY      NUMBER,
        x_task_rec                OUT NOCOPY      jtf_task_recurrences_pub.task_details_rec,
        x_reccurences_generated   OUT NOCOPY      INTEGER,
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
        p_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char
        )
    IS
        l_api_version    CONSTANT NUMBER                                       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                                 := 'CREATE_TASK_RECURRENCE';
        l_task_id                 jtf_tasks_b.task_id%TYPE;
        l_recurrence_rule_id      jtf_task_recur_rules.recurrence_rule_id%TYPE;
        l_output_dates_tbl        jtf_task_recurrences_pub.output_dates_rec;
        l_template_flag           CHAR                                         := p_template_flag;
        l_output_dates_counter    NUMBER;
        l_rowid                   ROWID;
        x                         CHAR;

        CURSOR c_jtf_task_recurrences (
            l_rowid                   IN       ROWID
        )
        IS
            SELECT 1
              FROM jtf_task_recur_rules
             WHERE ROWID = l_rowid;
    BEGIN
        SAVEPOINT create_task_recurrence_pub;
        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;



        IF jtf_task_utl.to_boolean (l_template_flag)
        THEN
            jtf_task_utl.validate_task_template (
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



        ELSE
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
        END IF;

        IF l_task_id IS NULL
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


        jtf_task_recurrences_pvt.create_task_recurrence (
            p_api_version => 1.0,
            p_init_msg_list => 'F',
            p_commit => 'F',
            p_task_id => p_task_id,
            p_occurs_which => p_occurs_which,
            p_day_of_week => p_day_of_week,
            p_date_of_month => p_date_of_month,
            p_occurs_month => p_occurs_month,
            p_occurs_uom => p_occurs_uom,
            p_occurs_every => p_occurs_every,
            p_occurs_number => p_occurs_number,
            p_start_date_active => p_start_date_active,
            p_end_date_active => p_end_date_active,
            p_template_flag   =>        p_template_flag ,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_recurrence_rule_id => x_recurrence_rule_id,
            x_task_rec => x_task_rec,
            x_output_dates_counter => x_reccurences_generated,
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
            p_sunday => p_sunday,
            p_monday   =>  p_monday,
            p_tuesday  =>   p_tuesday,
            p_wednesday  =>  p_wednesday,
            p_thursday   =>  p_thursday,
            p_friday     =>  p_friday,
            p_saturday   =>  p_saturday
            );

        IF (x_return_status = fnd_api.g_ret_sts_error)
        THEN
            RAISE fnd_api.g_exc_error;
        ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
        THEN
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
            ROLLBACK TO create_task_recurrence_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN


            ROLLBACK TO create_task_recurrence_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

    PROCEDURE update_task_recurrence (
        p_api_version            IN       NUMBER,
        p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                IN       NUMBER,
        p_recurrence_rule_id     IN       NUMBER,
        p_occurs_which           IN       INTEGER DEFAULT NULL,
        p_day_of_week            IN       INTEGER DEFAULT NULL,
        p_date_of_month          IN       INTEGER DEFAULT NULL,
        p_occurs_month           IN       INTEGER DEFAULT NULL,
        p_occurs_uom             IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every           IN       INTEGER DEFAULT NULL,
        p_occurs_number          IN       INTEGER DEFAULT NULL,
        p_start_date_active      IN       DATE DEFAULT NULL,
        p_end_date_active        IN       DATE DEFAULT NULL,
        p_template_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_attribute1             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute2             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute3             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute4             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute5             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute6             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute7             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute8             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute9             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute10            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute11            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute12            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute13            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute14            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute15            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute_category     IN       VARCHAR2 DEFAULT NULL ,
        p_sunday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday              IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        x_new_recurrence_rule_id OUT NOCOPY      NUMBER,
        x_return_status          OUT NOCOPY      VARCHAR2,
        x_msg_count              OUT NOCOPY      NUMBER,
        x_msg_data               OUT NOCOPY      VARCHAR2
    )
    IS
    BEGIN
        SAVEPOINT update_task_recurrence_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        jtf_task_recurrences_pvt.update_task_recurrence (
            p_api_version            => 1.0,
            p_init_msg_list          => fnd_api.g_false,
            p_commit                 => fnd_api.g_false,
            p_task_id                => p_task_id,
            p_recurrence_rule_id     => p_recurrence_rule_id,
            p_occurs_which           => p_occurs_which,
            p_day_of_week            => p_day_of_week,
            p_date_of_month          => p_date_of_month,
            p_occurs_month           => p_occurs_month,
            p_occurs_uom             => p_occurs_uom,
            p_occurs_every           => p_occurs_every,
            p_occurs_number          => p_occurs_number,
            p_start_date_active      => p_start_date_active,
            p_end_date_active        => p_end_date_active,
            p_template_flag          => p_template_flag,
            p_attribute1             => p_attribute1,
            p_attribute2             => p_attribute2,
            p_attribute3             => p_attribute3,
            p_attribute4             => p_attribute4,
            p_attribute5             => p_attribute5,
            p_attribute6             => p_attribute6,
            p_attribute7             => p_attribute7,
            p_attribute8             => p_attribute8,
            p_attribute9             => p_attribute9,
            p_attribute10            => p_attribute10,
            p_attribute11            => p_attribute11,
            p_attribute12            => p_attribute12,
            p_attribute13            => p_attribute13,
            p_attribute14            => p_attribute14,
            p_attribute15            => p_attribute15,
            p_attribute_category     => p_attribute_category,
            p_sunday                 => p_sunday,
            p_monday                 => p_monday,
            p_tuesday                => p_tuesday,
            p_wednesday              => p_wednesday,
            p_thursday               => p_thursday,
            p_friday                 => p_friday,
            p_saturday               => p_saturday,
            x_new_recurrence_rule_id => x_new_recurrence_rule_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data
        );

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_task_recurrence_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO update_task_recurrence_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END update_task_recurrence;

END;

/
