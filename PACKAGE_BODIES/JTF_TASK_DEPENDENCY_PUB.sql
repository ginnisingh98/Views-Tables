--------------------------------------------------------
--  DDL for Package Body JTF_TASK_DEPENDENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_DEPENDENCY_PUB" AS
/* $Header: jtfptkeb.pls 120.1 2005/07/02 00:58:52 appldev ship $ */
    g_pkg_name    CONSTANT VARCHAR2(30) := 'JTF_TASK_DEPENDENCY_PUB';

    PROCEDURE create_task_dependency (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_validation_level        IN       VARCHAR2 DEFAULT fnd_api.g_valid_level_full,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_number             IN       VARCHAR2 DEFAULT NULL,
        p_dependent_on_task_id    IN       NUMBER DEFAULT NULL,
        p_dependent_on_task_number IN      VARCHAR2 DEFAULT NULL,
        p_dependency_type_code    IN       VARCHAR2,
        p_template_flag           IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
        p_adjustment_time         IN       NUMBER DEFAULT NULL,
        p_adjustment_time_uom     IN       VARCHAR2 DEFAULT NULL,
        p_validated_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
        x_dependency_id           OUT NOCOPY      NUMBER,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
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
        l_api_version        CONSTANT NUMBER                                     := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)                               := 'CREATE_TASK_DEPENDENCY';
        l_task_id                     jtf_tasks_b.task_id%TYPE                   := p_task_id;
        l_task_number                 jtf_tasks_b.task_id%TYPE                   := p_task_number;
        l_dependent_on_task_id        jtf_tasks_b.task_id%TYPE                   := p_dependent_on_task_id;
        l_dependent_on_task_number    jtf_tasks_b.task_id%TYPE                   := p_dependent_on_task_number;
        l_template_flag               jtf_task_depends.template_flag%TYPE        := p_template_flag;
        l_dependency_type_code        jtf_task_depends.dependency_type_code%TYPE := p_dependency_type_code;
        l_adjustment_time             jtf_task_depends.adjustment_time%TYPE      := p_adjustment_time;
        l_adjustment_time_uom         jtf_task_depends.adjustment_time_uom%TYPE  := p_adjustment_time_uom;
        x                             CHAR;
    BEGIN
        SAVEPOINT create_task_dependency_pub;
        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --- Validate if the template flag is in the following fnd_api.g_true , fnd_api.g_false , NULL
        jtf_task_utl.validate_flag (
            p_api_name => l_api_name,
            p_init_msg_list => fnd_api.g_false,
            x_return_status => x_return_status,
            p_flag_name => 'Template Flag',
            p_flag_value => l_template_flag
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        ---- The dependecy is between the tasks
        ---- if the template flag is null, it assumes the dependency is between the tasks.
        IF jtf_task_utl.to_boolean (l_template_flag)
        THEN
            jtf_task_utl.validate_task_template (
                x_return_status => x_return_status,
                p_task_id => l_task_id,
                p_task_number => l_task_number,
                x_task_id => l_task_id
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_task_id IS NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP');
                fnd_message.set_token ('P_TASK_TEMPLATE_ID', l_task_id);
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            jtf_task_utl.validate_task_template (
                x_return_status => x_return_status,
                p_task_id => l_dependent_on_task_id,
                p_task_number => l_dependent_on_task_number,
                x_task_id => l_dependent_on_task_id
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_dependent_on_task_id IS NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP');
                fnd_message.set_token ('P_TASK_TEMPLATE_ID', l_task_id);
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        ELSE
            jtf_task_utl.validate_task (
                x_return_status => x_return_status,
                p_task_id => l_task_id,
                p_task_number => l_task_number,
                x_task_id => l_task_id
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_task_id IS NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
                fnd_message.set_token ('P_TASK_TEMPLATE_ID', l_task_id);
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;


            jtf_task_utl.validate_task (
                x_return_status => x_return_status,
                p_task_id => l_dependent_on_task_id,
                p_task_number => l_dependent_on_task_number,
                x_task_id => l_dependent_on_task_id
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_dependent_on_task_id IS NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
                fnd_message.set_token ('P_TASK_TEMPLATE_ID', l_task_id);
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

        END IF;

        IF NOT jtf_task_utl.validate_dependency_code (l_dependency_type_code)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        jtf_task_utl.validate_effort (x_return_status => x_return_status, p_effort => l_adjustment_time, p_effort_uom => l_adjustment_time_uom);

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        jtf_task_dependency_pvt.create_task_dependency (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_task_id => l_task_id,
            p_dependent_on_task_id => l_dependent_on_task_id,
            p_dependency_type_code => l_dependency_type_code,
            p_template_flag => l_template_flag,
            p_adjustment_time => l_adjustment_time,
            p_adjustment_time_uom => l_adjustment_time_uom,
            p_validated_flag => p_validated_flag,
            x_dependency_id => x_dependency_id,
            x_return_status => x_return_status,
            x_msg_data => x_msg_data,
            x_msg_count => x_msg_count,
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
            p_attribute_category => p_attribute_category
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
            ROLLBACK TO create_task_dependency_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO create_task_dependency_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

/**********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************/
   PROCEDURE lock_task_dependency (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_dependency_id   IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   ) is
        l_api_version    CONSTANT NUMBER                                 := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                           := 'LOCK_TASK_DEPENDENCY';
        l_task_contact_id         jtf_task_contacts.task_contact_id%TYPE;

        Resource_Locked exception ;

        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;

   begin
        SAVEPOINT lock_task_depends_pub;

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

        jtf_task_depends_pkg.lock_row(
            x_dependency_id => p_dependency_id ,
            x_object_version_number => p_object_version_number  );


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
       WHEN Resource_Locked then
            ROLLBACK TO lock_task_depends_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO lock_task_depends_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO lock_task_depends_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;
/**********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************/
    PROCEDURE update_task_dependency (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   in  out nocopy  number ,
        p_dependency_id           IN       NUMBER,
        p_task_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_dependent_on_task_id    IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_dependent_on_task_number IN      VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_dependency_type_code    IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_adjustment_time         IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_adjustment_time_uom     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_validated_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
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
        l_api_version        CONSTANT NUMBER                                     := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)                               := 'UPDATE_TASK_DEPENDENCY';
        l_dependency_id               jtf_task_depends.dependency_id%TYPE        := p_dependency_id;
        l_task_id                     jtf_tasks_b.task_id%TYPE;
        l_dependent_on_task_id        jtf_tasks_b.task_id%TYPE                   := p_dependent_on_task_id;
        l_dependent_on_task_number    jtf_tasks_b.task_number%TYPE               := p_dependent_on_task_number;
        l_dependency_type_code        jtf_task_depends.dependency_type_code%TYPE := p_dependency_type_code;
        l_adjustment_time             jtf_task_depends.adjustment_time%TYPE      := p_adjustment_time;
        l_adjustment_time_uom         jtf_task_depends.adjustment_time_uom%TYPE  := p_adjustment_time_uom;
        l_template_flag               jtf_task_depends.template_flag%TYPE;
        x                             CHAR;

        CURSOR c_jtf_task_depends
        IS
            SELECT
                   DECODE (p_task_id, fnd_api.g_miss_num, task_id, p_task_id) task_id,
                   DECODE (p_dependent_on_task_id, fnd_api.g_miss_num, dependent_on_task_id, p_dependent_on_task_id) dependent_on_task_id,
                   DECODE (p_dependency_type_code, fnd_api.g_miss_char, dependency_type_code, p_dependency_type_code) dependency_type_code,
                   template_flag,
                   DECODE (p_adjustment_time, fnd_api.g_miss_num, adjustment_time, p_adjustment_time) adjustment_time,
                   DECODE (p_adjustment_time_uom, fnd_api.g_miss_char, adjustment_time_uom, p_adjustment_time_uom) adjustment_time_uom,
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
decode( p_attribute_category,fnd_api.g_miss_char,attribute_category,p_attribute_category) attribute_category
              FROM jtf_task_depends
             WHERE dependency_id = p_dependency_id;

        task_depends                  c_jtf_task_depends%ROWTYPE;
    BEGIN

        SAVEPOINT update_task_dependency_pub;
        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- check if the dependency is invalid or null.
        IF (l_dependency_id IS NULL)
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_DEPENDENCY_ID');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        OPEN c_jtf_task_depends;
        FETCH c_jtf_task_depends INTO task_depends;

        IF c_jtf_task_depends%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPENDS_ID');
            fnd_message.set_token ('P_DEPENDENCY_ID', p_dependency_id);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --- if template_flag is NOT input, then assign it the value from the table.
        l_template_flag := task_depends.template_flag;
        l_task_id := task_depends.task_id;

        --------------------
        --------------------
        IF NOT (   p_dependent_on_task_id = fnd_api.g_miss_num
               AND p_dependent_on_task_number = fnd_api.g_miss_char)
        THEN
            SELECT DECODE (p_dependent_on_task_id, fnd_api.g_miss_num, NULL, p_dependent_on_task_id)
              INTO l_dependent_on_task_id
              FROM dual;
            SELECT DECODE (p_dependent_on_task_number, fnd_api.g_miss_char, NULL, p_dependent_on_task_number)
              INTO l_dependent_on_task_number
              FROM dual;

            IF NOT (l_template_flag = fnd_api.g_true)
            THEN
                ---- Here the task id is assigned null, if the task id is NOT input,
                ---  because then task number could be input.

                --- This means task id is being updated.
                jtf_task_utl.validate_task (
                    x_return_status => x_return_status,
                    p_task_id => l_dependent_on_task_id,
                    p_task_number => l_dependent_on_task_number,
                    x_task_id => l_dependent_on_task_id
                );
            ELSE
                jtf_task_utl.validate_task_template (
                    x_return_status => x_return_status,
                    p_task_id => l_dependent_on_task_id,
                    p_task_number => l_dependent_on_task_number,
                    x_task_id => l_dependent_on_task_id
                );
            END IF;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_dependent_on_task_id IS NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        ELSE
            l_dependent_on_task_id := task_depends.dependent_on_task_id;
        END IF;

        -------------------
        -------------------
        IF l_dependency_type_code = fnd_api.g_miss_char
        THEN
            --- if the dependency type code is supplied then
            --- check if it exists
            l_dependency_type_code := task_depends.dependency_type_code;
        ELSE
            IF NOT jtf_task_utl.validate_dependency_code (l_dependency_type_code)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        jtf_task_dependency_pvt.update_task_dependency (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_dependency_id => p_dependency_id,
            p_task_id => l_task_id,
            p_dependent_on_task_id => l_dependent_on_task_id,
            p_dependency_type_code => l_dependency_type_code,
            p_adjustment_time => l_adjustment_time,
            p_adjustment_time_uom => l_adjustment_time_uom,
            p_validated_flag => p_validated_flag,
            x_return_status => x_return_status,
            x_msg_data => x_msg_data,
            x_msg_count => x_msg_count,
            p_attribute1 => task_depends.attribute1 ,
            p_attribute2 => task_depends.attribute2 ,
            p_attribute3 => task_depends.attribute3 ,
            p_attribute4 => task_depends.attribute4 ,
            p_attribute5 => task_depends.attribute5 ,
            p_attribute6 => task_depends.attribute6 ,
            p_attribute7 => task_depends.attribute7 ,
            p_attribute8 => task_depends.attribute8 ,
            p_attribute9 => task_depends.attribute9 ,
            p_attribute10 => task_depends.attribute10 ,
            p_attribute11 => task_depends.attribute11 ,
            p_attribute12 => task_depends.attribute12 ,
            p_attribute13 => task_depends.attribute13 ,
            p_attribute14 => task_depends.attribute14 ,
            p_attribute15 => task_depends.attribute15 ,
            p_attribute_category => task_depends.attribute_category
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

        IF c_jtf_task_depends%ISOPEN
        THEN
            CLOSE c_jtf_task_depends;
        END IF;

        fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_task_dependency_pub;

            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;

            ROLLBACK TO update_task_dependency_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

    PROCEDURE delete_task_dependency (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   in  number ,
        p_dependency_id           IN       NUMBER,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    )
    IS
        l_api_version    CONSTANT NUMBER                              := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                        := 'DELETE_TASK_DEPENDENCY';
        l_return_status           VARCHAR2(1)                         := fnd_api.g_ret_sts_success;
        l_msg_data                VARCHAR2(2000);
        l_msg_count               NUMBER;
        l_dependency_id           jtf_task_depends.dependency_id%TYPE := p_dependency_id;

        CURSOR c_jtf_task_depends
        IS
            SELECT 1
              FROM jtf_task_depends
             WHERE dependency_id = l_dependency_id;

        x                         CHAR;
    BEGIN

        SAVEPOINT delete_task_dependency_pub;
        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;



        ---- if the dependency is null, then it is an error
        IF (l_dependency_id IS NULL)
        THEN

            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_DEPENDS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        ---- if the dependency is NOT valid, then it is an error
        OPEN c_jtf_task_depends;
        FETCH c_jtf_task_depends INTO x;

        IF c_jtf_task_depends%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPENDS_ID');
            fnd_message.set_token('P_DEPENDENCY_ID',P_DEPENDENCY_ID);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            jtf_task_dependency_pvt.delete_task_dependency (
                p_api_version => l_api_version,
                p_init_msg_list => fnd_api.g_false,
                p_commit => fnd_api.g_false,
                p_object_version_number => p_object_version_number,
                p_dependency_id => l_dependency_id,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
            );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        END IF;

        IF c_jtf_task_depends%ISOPEN
        THEN
            CLOSE c_jtf_task_depends;
        END IF;

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_error
        THEN


            ROLLBACK TO delete_task_dependency_pub;

            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;

            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error
        THEN


            ROLLBACK TO delete_task_dependency_pub;

            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN

            ROLLBACK TO delete_task_dependency_pub;

            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;

            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;   -- Delete Task dependency
END;

/
