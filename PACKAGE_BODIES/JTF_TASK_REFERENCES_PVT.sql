--------------------------------------------------------
--  DDL for Package Body JTF_TASK_REFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_REFERENCES_PVT" AS
/* $Header: jtfvtknb.pls 120.1 2005/07/02 01:46:00 appldev ship $ */
g_pkg_name      constant varchar2(30) := 'JTF_TASK_REFERENCES_PVT';

    PROCEDURE create_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_object_type_code        IN       VARCHAR2 DEFAULT NULL,
        p_object_name             IN       VARCHAR2 DEFAULT NULL,
        p_object_id               IN       NUMBER DEFAULT NULL,
        p_object_details          IN       VARCHAR2 DEFAULT NULL,
        p_reference_code          IN       VARCHAR2 DEFAULT NULL,
        p_usage                   IN       VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_task_reference_id       OUT NOCOPY      NUMBER,
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
        l_api_version CONSTANT NUMBER                                        := 1.0;
        l_task_reference_id    jtf_task_references_b.task_reference_id%TYPE;
        l_rowid                ROWID;
        l_api_name             VARCHAR2(30)                                  := 'CREATE_REFERENCES';

        CURSOR c_jtf_task_references (
            l_rowid                   IN       ROWID
        )
        IS
            SELECT 1
              FROM jtf_task_references_b
             WHERE ROWID = l_rowid;

        x                      CHAR;

    BEGIN

        savepoint create_references_pvt ;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

-- 2102281
    if not (jtf_task_utl.check_duplicate_reference(p_task_id, p_object_id, p_object_type_code))
    then
       if (jtf_task_utl.g_show_error_for_dup_reference)
       then
          fnd_message.set_name('JTF','JTF_TASK_DUPLICATE_REF');
      fnd_message.set_token('P_OBJECT_NAME',p_object_name);
      fnd_message.set_token('P_OBJECT_TYPE',p_object_type_code);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
     else
        jtf_task_utl.g_show_error_for_dup_reference := True;
      return;
       end if;
    end if;



        SELECT jtf_task_references_s.nextval
        INTO l_task_reference_id
        FROM dual;

        /* Made a call to the function jtf_task_utl.check_truncation, since it was inserting Party Name
        which was greater than 80 characters */
        jtf_task_references_pkg.insert_row (
            x_rowid => l_rowid,
            x_task_reference_id => l_task_reference_id,
            x_task_id => p_task_id,
            x_object_type_code => p_object_type_code,
            x_object_name => jtf_task_utl.check_truncation(p_object_name),
            x_object_id => p_object_id,
            x_object_details => NVL(p_object_details, -- For fixing bug 2896532
                                    jtf_task_utl_ext.get_object_details(
                                       p_object_type_code
                                      ,p_object_id)),
            x_reference_code => p_reference_code,
            x_usage => p_usage,
            x_creation_date => SYSDATE,
            x_created_by => jtf_task_utl.created_by,
            x_last_update_date => SYSDATE,
            x_last_updated_by => jtf_task_utl.updated_by,
            x_last_update_login => jtf_task_utl.login_id,
            x_attribute1 => p_attribute1 ,
            x_attribute2 => p_attribute2 ,
            x_attribute3 => p_attribute3 ,
            x_attribute4 => p_attribute4 ,
            x_attribute5 => p_attribute5 ,
            x_attribute6 => p_attribute6 ,
            x_attribute7 => p_attribute7 ,
            x_attribute8 => p_attribute8 ,
            x_attribute9 => p_attribute9 ,
            x_attribute10 => p_attribute10 ,
            x_attribute11 => p_attribute11 ,
            x_attribute12 => p_attribute12 ,
            x_attribute13 => p_attribute13 ,
            x_attribute14 => p_attribute14 ,
            x_attribute15 => p_attribute15,
            x_attribute_category => p_attribute_category
        );

        OPEN c_jtf_task_references (l_rowid);
        FETCH c_jtf_task_references INTO x;

        IF c_jtf_task_references%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_ERROR_CREATING_REFER');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            x_task_reference_id := l_task_reference_id;
        END IF;


        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO create_references_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO create_references_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

        PROCEDURE update_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   in OUT NOCOPY   number,
        p_task_reference_id       IN       NUMBER,
        p_object_type_code        IN       VARCHAR2 DEFAULT NULL,
        p_object_name             IN       VARCHAR2 DEFAULT NULL,
        p_object_id               IN       NUMBER DEFAULT NULL,
        p_object_details          IN       VARCHAR2 DEFAULT NULL,
        p_reference_code          IN       VARCHAR2 DEFAULT NULL,
        p_usage                   IN       VARCHAR2 DEFAULT NULL,
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
        l_api_name             VARCHAR2(30)                                  := 'UPDATE_REFERENCES';
        l_api_version  CONSTANT NUMBER                                        := 1.0;
        l_task_id              jtf_tasks_b.task_id%TYPE;
        l_object_type_code     jtf_objects_b.object_code%TYPE;
        l_task_reference_id    jtf_task_references_b.task_reference_id%TYPE  := p_task_reference_id;
        l_reference_code       jtf_task_references_b.reference_code%TYPE;
        l_usage                jtf_task_references_tl.usage%TYPE;
        l_object_name          jtf_task_references_b.object_name%TYPE;
        l_object_id            jtf_task_references_b.object_id%TYPE;
        l_object_details       jtf_task_references_b.object_details%TYPE;

        CURSOR c_task_reference
        IS
            SELECT task_id,
                   DECODE (p_task_reference_id, fnd_api.g_miss_num, task_reference_id, p_task_reference_id) task_reference_id,
                   DECODE (p_object_type_code, fnd_api.g_miss_char, object_type_code, p_object_type_code) object_type_code,
                   DECODE (p_object_name, fnd_api.g_miss_char, object_name, p_object_name) object_name,
                   DECODE (p_object_id, fnd_api.g_miss_num, object_id, p_object_id) object_id,
                   DECODE (p_object_details, fnd_api.g_miss_char, object_details, p_object_details) object_details,
                   DECODE (p_reference_code, fnd_api.g_miss_char, reference_code, p_reference_code) reference_code,
                   DECODE (p_usage, fnd_api.g_miss_char, usage, p_usage) usage,
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
              FROM jtf_task_references_vl
             WHERE task_reference_id = l_task_reference_id;

        task_references        c_task_reference%ROWTYPE;
    BEGIN

        savepoint update_task_reference_pvt ;

        x_return_status := fnd_api.g_ret_sts_success;


        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;



        IF l_task_reference_id IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISS_REFER');

            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        OPEN c_task_reference;
        FETCH c_task_reference INTO task_references;

        IF c_task_reference%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_REFER');
            fnd_message.set_token('P_TASK_REFERENCE_ID',p_task_reference_id);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_task_id := task_references.task_id;
        l_reference_code := task_references.reference_code;
        l_object_type_code := task_references.object_type_code;
        l_object_id := task_references.object_id;

        /* Made a call to the function jtf_task_utl.check_truncation, since it was inserting Party Name
        which was greater than 80 characters */

        l_object_name := jtf_task_utl.check_truncation(task_references.object_name);
        l_object_details := task_references.object_details;
        l_reference_code := task_references.reference_code;
        l_usage := task_references.usage;

-- 2102281
/*
   Bug 3360228
   For update, calling jtf_task_utl_ext.check_dup_reference_for_update for
   checking duplicates instead of.
*/
    if not (jtf_task_utl_ext.check_dup_reference_for_update(l_task_reference_id, l_task_id, l_object_id, l_object_type_code))
    then
       if (jtf_task_utl.g_show_error_for_dup_reference)
       then
          fnd_message.set_name('JTF','JTF_TASK_DUPLICATE_REF');
      fnd_message.set_token('P_OBJECT_NAME',l_object_name);
      fnd_message.set_token('P_OBJECT_TYPE',l_object_type_code);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
     else
        jtf_task_utl.g_show_error_for_dup_reference := True;
      return;
       end if;
    end if;

        jtf_task_references_pub.lock_references
        ( P_API_VERSION                 =>  1.0,
         P_INIT_MSG_LIST                =>  fnd_api.g_false ,
         P_COMMIT                       =>  fnd_api.g_false ,
         P_TASK_reference_ID            =>  l_task_reference_id ,
         P_OBJECT_VERSION_NUMBER        =>  p_object_version_number,
         X_RETURN_STATUS                =>  x_return_status ,
         X_MSG_DATA                     =>  x_msg_data ,
         X_MSG_COUNT                    =>  x_msg_count ) ;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        p_object_version_number := p_object_version_number + 1 ;

        jtf_task_references_pkg.update_row (
            x_task_reference_id => l_task_reference_id,
            x_task_id => l_task_id,
            x_object_type_code => l_object_type_code,
            x_object_name => l_object_name,
            x_object_id => l_object_id,
            x_object_details => l_object_details,
            x_reference_code => l_reference_code,
            x_attribute1 => task_references.attribute1 ,
            x_attribute2 => task_references.attribute2 ,
            x_attribute3 => task_references.attribute3 ,
            x_attribute4 => task_references.attribute4 ,
            x_attribute5 => task_references.attribute5 ,
            x_attribute6 => task_references.attribute6 ,
            x_attribute7 => task_references.attribute7 ,
            x_attribute8 => task_references.attribute8 ,
            x_attribute9 => task_references.attribute9 ,
            x_attribute10 => task_references.attribute10 ,
            x_attribute11 => task_references.attribute11 ,
            x_attribute12 => task_references.attribute12 ,
            x_attribute13 => task_references.attribute13 ,
            x_attribute14 => task_references.attribute14 ,
            x_attribute15 => task_references.attribute15 ,
            x_attribute_category => task_references.attribute_category,
            x_usage => l_usage,
            x_last_update_date => SYSDATE,
            x_last_updated_by => jtf_task_utl.updated_by,
            x_last_update_login => jtf_task_utl.login_id,
            x_object_version_number => p_object_version_number
        );

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_task_reference_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO update_task_reference_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;


    PROCEDURE delete_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   in       number,
        p_task_reference_id       IN       NUMBER,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        p_from_task_api           IN               VARCHAR2 DEFAULT  'N'
    )
    IS
        l_api_version    CONSTANT NUMBER       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30) := 'DELETE_REFERENCES';


        CURSOR c_jtf_task_ref_delete
        IS
            SELECT task_id, object_id
              FROM jtf_task_references_b
              where task_reference_id = p_task_reference_id ;

      l_task_id jtf_task_references_b.task_id%type;
      l_object_id jtf_task_references_b.object_id%type;

    BEGIN

        SAVEPOINT delete_task_reference_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

-- 2102281

   OPEN c_jtf_task_ref_delete ;

    FETCH c_jtf_task_ref_delete INTO l_task_id, l_object_id;

     IF   (c_jtf_task_ref_delete%NOTFOUND) THEN
      fnd_message.set_name ('JTF', 'JTF_TASK_REFERENCE_NOT_FOUND');
       fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;


     CLOSE c_jtf_task_ref_delete ;

--By pass this check if the call is made from JTF_TASKS_PVT.DELETE_TASK
--JTF_TASKS_PVT calls this API with p_from_task_api ='Y'. Bug number 3995359

IF  (p_from_task_api ='N') THEN

    if not (jtf_task_utl.check_reference_delete(l_task_id, l_object_id))
    THEN
      if not (jtf_task_utl.g_show_error_for_dup_reference) then
        jtf_task_utl.g_show_error_for_dup_reference := True;
      end if;

   --The API returns the message JTF_TASK_ERROR_NO_REFERENCES when you try to
   --delete references which are created automically for the customer when the
   --task is created. Refer to bug 3875523.

      fnd_message.set_name ('JTF', 'JTF_TASK_ERROR_REF_DELETE');
        fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data =>x_msg_data);
           return;

    end if;


END IF;

         jtf_task_references_pkg.lock_row(
           X_TASK_REFERENCE_ID =>p_task_reference_id,
             X_OBJECT_VERSION_NUMBER =>p_object_version_number);

        jtf_task_references_pkg.delete_row (
          x_task_reference_id => p_task_reference_id);


     IF fnd_api.to_boolean (p_commit)
        THEN
         COMMIT WORK;
        END IF;


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION

        WHEN NO_DATA_FOUND
        THEN
         ROLLBACK TO delete_task_reference_pvt;
          fnd_message.set_name ('JTF', 'JTF_TASK_ERROR_DELETING_REFER');
	   fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO delete_task_reference_pvt;
            if (c_jtf_task_ref_delete%ISOPEN) THEN
             CLOSE c_jtf_task_ref_delete;
              END IF;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN OTHERS
        THEN
            ROLLBACK TO delete_task_reference_pvt;
             fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
              fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
               fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;
END;

/
