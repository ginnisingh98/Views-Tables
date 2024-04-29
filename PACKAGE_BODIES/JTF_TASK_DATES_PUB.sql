--------------------------------------------------------
--  DDL for Package Body JTF_TASK_DATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_DATES_PUB" AS
/* $Header: jtfptkdb.pls 115.20 2002/12/06 01:21:45 sachoudh ship $ */
    g_pkg_name    VARCHAR2(30) := 'CREATE_DATES_PUB';

    PROCEDURE create_task_dates (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_number             IN       VARCHAR2 DEFAULT NULL,
        p_task_id                 IN       VARCHAR2 DEFAULT NULL,
        p_date_type_id            IN       VARCHAR2 DEFAULT NULL,
        p_date_type_name          IN       VARCHAR2 DEFAULT NULL,
        p_date_value              IN       DATE,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_task_date_id            OUT NOCOPY      NUMBER,
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
        l_api_version    CONSTANT NUMBER                                  := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                            := 'CREATE_TASK_DATES';
        l_task_id                 jtf_tasks_b.task_id%TYPE                := p_task_id;
        l_task_number             jtf_tasks_b.task_number%TYPE            := p_task_number;
        l_date_type_id            jtf_task_date_types_b.date_type_id%TYPE := p_date_type_id;
        l_date_type_name          jtf_task_date_types_tl.date_type%TYPE   := p_date_type_name;
        l_task_date_id            jtf_task_dates.task_date_id%TYPE;
        l_rowid                   ROWID;

        CURSOR c_jtf_task_dates (
            l_rowid                   IN       ROWID
        )
        IS
            SELECT 1
              FROM jtf_task_dates
             WHERE ROWID = l_rowid;

        x                         CHAR;
    BEGIN
        SAVEPOINT create_task_dates_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

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
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        jtf_task_utl.validate_date_types (
            p_date_type_id => l_date_type_id,
            p_date_type => l_date_type_name,
            x_return_status => x_return_status,
            x_date_type_id => l_date_type_id
        );

        IF (x_return_status = fnd_api.g_ret_sts_unexp_error)
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DATE_TYPE_ID');
            fnd_message.set_token('P_DATE_TYPE_ID' , p_date_type_id );
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_date_type_id IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_DATE_TYPE_ID');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF p_date_value IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_DATES');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        jtf_task_dates_pvt.create_task_dates (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_task_id => l_task_id,
            p_date_type_id => l_date_type_id,
            p_date_value => p_date_value,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_task_date_id => x_task_date_id,
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

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO create_task_dates_pub ;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO create_task_dates_pub ;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

   PROCEDURE lock_task_dates (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_date_id      IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   ) is
        l_api_version    CONSTANT NUMBER                                 := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                           := 'LOCK_TASK_DATES';

        Resource_Locked exception ;

        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;

   begin
        SAVEPOINT lock_task_dates_pub;

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

        jtf_task_dates_pkg.lock_row(
            x_task_date_id => p_task_date_id ,
            x_object_version_number => p_object_version_number  );


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
       WHEN Resource_Locked then
            ROLLBACK TO lock_task_dates_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO lock_task_dates_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO lock_task_dates_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

    PROCEDURE update_task_dates (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN     OUT NOCOPY NUMBER ,
        p_task_date_id            IN       NUMBER,
        p_date_type_name          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_date_type_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_date_value              IN       DATE DEFAULT fnd_api.g_miss_date,
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
        l_api_version    CONSTANT NUMBER                                  := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                            := 'UPDATE_TASK_DATES';
        l_task_id                 jtf_tasks_b.task_id%TYPE                ;
        l_date_type_id            jtf_task_date_types_b.date_type_id%TYPE := p_date_type_id;
        l_date_type_name          jtf_task_date_types_tl.date_type%TYPE   := p_date_type_name;
        l_date_value              jtf_task_dates.date_value%TYPE          := p_date_value;
        l_task_date_id            jtf_task_dates.task_date_id%TYPE        := p_task_date_id;

        CURSOR c_update_task_dates
        IS
            SELECT task_id,
                   DECODE (p_date_type_id, fnd_api.g_miss_num, date_type_id, p_date_type_id) date_type_id,
                   DECODE (p_date_value, fnd_api.g_miss_date, date_value, p_date_value) date_value,
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
              FROM jtf_task_dates
             WHERE task_date_id = p_task_date_id;

        task_dates                c_update_task_dates%ROWTYPE;
    BEGIN

        SAVEPOINT update_task_dates_pub;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;


        x_return_status := fnd_api.g_ret_sts_success;

        OPEN c_update_task_dates;
        FETCH c_update_task_dates INTO task_dates;

        IF c_update_task_dates%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DATE');
            fnd_message.set_token('P_TASK_DATE_ID',P_TASK_DATE_ID);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        CLOSE c_update_task_dates;


        -------
        -------  Validate the Task Date type
        -------
        IF (  p_date_type_id <> fnd_api.g_miss_num
           OR p_date_type_name <> fnd_api.g_miss_char)
        THEN
            SELECT DECODE (p_date_type_id, fnd_api.g_miss_num, NULL, p_date_type_id)
              INTO l_date_type_id
              FROM dual;
            SELECT DECODE (p_date_type_name, fnd_api.g_miss_char, NULL, p_date_type_name)
              INTO l_date_type_name
              FROM dual;

            jtf_task_utl.validate_date_types (
                p_date_type_id => l_date_type_id,
                p_date_type => l_date_type_name,
                x_return_status => x_return_status,
                x_date_type_id => l_date_type_id
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_date_type_id IS NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_DATE_TYPE_ID');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        ELSE
            l_date_type_id := task_dates.date_type_id;
        END IF;


        -------
        -------  validate the date value
        -------
        l_date_value := task_dates.date_value;

        IF l_date_value IS NULL
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_DATES');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_task_id := task_dates.task_id ;


        jtf_task_dates_pub.lock_task_dates
        ( P_API_VERSION                 =>	1.0 ,
         P_INIT_MSG_LIST                =>	fnd_api.g_false ,
         P_COMMIT                       =>	fnd_api.g_false ,
         P_TASK_date_ID              =>	l_task_date_id ,
         P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
         X_RETURN_STATUS                =>	x_return_status ,
         X_MSG_DATA                     =>	x_msg_data ,
         X_MSG_COUNT                    =>	x_msg_count ) ;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        jtf_task_dates_pvt.update_task_dates (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number ,
            p_task_date_id => l_task_date_id,
            p_date_type_id => l_date_type_id,
            p_date_value => l_date_value,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_attribute1 => task_dates.attribute1 ,
            p_attribute2 => task_dates.attribute2 ,
            p_attribute3 => task_dates.attribute3 ,
            p_attribute4 => task_dates.attribute4 ,
            p_attribute5 => task_dates.attribute5 ,
            p_attribute6 => task_dates.attribute6 ,
            p_attribute7 => task_dates.attribute7 ,
            p_attribute8 => task_dates.attribute8 ,
            p_attribute9 => task_dates.attribute9 ,
            p_attribute10 => task_dates.attribute10 ,
            p_attribute11 => task_dates.attribute11 ,
            p_attribute12 => task_dates.attribute12 ,
            p_attribute13 => task_dates.attribute13 ,
            p_attribute14 => task_dates.attribute14 ,
            p_attribute15 => task_dates.attribute15 ,
            p_attribute_category => task_dates.attribute_category
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
            rollback to update_task_dates_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            rollback to update_task_dates_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

    PROCEDURE delete_task_dates (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN     NUMBER ,
        p_task_date_id            IN       NUMBER DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER
    )
    IS
        l_api_version    CONSTANT NUMBER       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30) := 'DELETE_TASK_date';
    BEGIN
        SAVEPOINT delete_task_date_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        jtf_task_dates_pub.lock_task_dates
        ( P_API_VERSION                 =>	1.0 ,
         P_INIT_MSG_LIST                =>	fnd_api.g_false ,
         P_COMMIT                       =>	fnd_api.g_false ,
         P_TASK_date_ID              =>	    p_task_date_id ,
         P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
         X_RETURN_STATUS                =>	x_return_status ,
         X_MSG_DATA                     =>	x_msg_data ,
         X_MSG_COUNT                    =>	x_msg_count ) ;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        jtf_task_dates_pvt.delete_task_dates (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_task_date_id => p_task_date_id,
            x_return_status => x_return_status,
            x_msg_data => x_msg_data,
            x_msg_count => x_msg_count
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
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
            ROLLBACK TO delete_task_date_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO delete_task_date_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;   -- Delete Task Dates
END;

/
