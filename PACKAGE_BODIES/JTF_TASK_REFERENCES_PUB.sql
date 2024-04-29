--------------------------------------------------------
--  DDL for Package Body JTF_TASK_REFERENCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_REFERENCES_PUB" AS
/* $Header: jtfptknb.pls 115.31 2002/12/04 01:45:33 cjang ship $ */
    g_pkg_name    VARCHAR2(30) := 'JTF_TASK_REFERENCES_PUB';

    PROCEDURE create_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_number             IN       VARCHAR2 DEFAULT NULL,
        p_object_type_code        IN       VARCHAR2 DEFAULT NULL,
        p_object_name             IN       VARCHAR2 ,
        p_object_id               IN       NUMBER ,
        p_object_details          IN       VARCHAR2 DEFAULT NULL,
        p_reference_code          IN       VARCHAR2 DEFAULT NULL,
        p_usage                   IN       VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_data                OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_task_reference_id       OUT NOCOPY NUMBER,
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
        l_api_version       CONSTANT NUMBER                                        := 1.0;
        l_api_name          CONSTANT VARCHAR2(30)                                  := 'CREATE_REFERENCES';
        l_id_column            jtf_objects_b.select_id%TYPE;
        l_name_column          jtf_objects_b.select_name%TYPE;
        l_from_clause          jtf_objects_b.from_table%TYPE;
        l_where_clause         jtf_objects_b.where_clause%TYPE;
        l_object_name          jtf_task_references_b.object_name%TYPE;
        l_object_id            jtf_task_references_b.object_id%TYPE;
        l_task_reference_id    NUMBER;
        l_rowid                ROWID;
        l_task_id              jtf_tasks_b.task_id%TYPE                      := p_task_id;
        l_task_number          jtf_tasks_b.task_number%TYPE                  := p_task_number;
        sql_stmt               VARCHAR2(4000);
        x                      CHAR;
        l_object_type_code     jtf_objects_b.object_code%TYPE := p_object_type_code;

        CURSOR c_references
        IS
            SELECT select_id,
                   select_name,
                   from_table,
                   where_clause
              FROM jtf_objects_vl
             WHERE object_code = l_object_type_code;

        CURSOR c_reference_codes
        IS
            SELECT 1
              FROM fnd_lookups
             WHERE lookup_type = 'JTF_TASK_REFERENCE_CODES'
               AND lookup_code = p_reference_code;

        references_rec         c_references%ROWTYPE;
    BEGIN

       savepoint create_references_Pub ;

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
----
---- Commenting to use the common code from jtf_task_utl.
---- Also, the validation was incorrect since it was validating the id from the name. rather than vide versa.
----
----

      -------
      -------   Validate source object details
      -------
      jtf_task_utl.validate_source_object (
         p_object_code => p_object_type_code,
         p_object_id => p_object_id ,
         p_object_name => p_object_name,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;



/*        jtf_task_utl.validate_object_type (
            p_object_code => l_object_type_code,
            p_object_type_name => NULL,
            x_return_status => x_return_status,
            x_object_code => l_object_type_code
        );


        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        IF l_object_type_code IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_OBJECT_CODE');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;



        OPEN c_references;

        FETCH c_references INTO l_id_column, l_name_column, l_from_clause, l_where_clause;





        IF c_references%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
            fnd_message.set_token('P_OBJECT_CODE',p_object_type_code);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

*/



  /*

  This part of code commented by GJASHNAN
  Made Object Name as a mandatory parameter.

        IF p_object_name IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_OBJECT_NAME');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

   */
/*        SELECT DECODE (l_where_clause, NULL, '  ', l_where_clause || ' AND ')
          INTO l_where_clause
          FROM dual;
        sql_stmt := ' SELECT ' ||
                    l_name_column ||
                    ' , ' ||
                    l_id_column ||
                    ' from ' ||
                    l_from_clause ||
                    '  where ' ||
                    l_where_clause ||
                    l_name_column ||
				' = ' ||
                    ''''||
                    p_object_name||
                    '''';

	   EXECUTE IMMEDIATE sql_stmt
            INTO l_object_name, l_object_id;

        IF p_object_id IS NOT NULL
        THEN
            IF l_object_id <> p_object_id
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_ID');
                fnd_message.set_token('P_OBJECT_ID', p_object_id );
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;
*/



        IF p_reference_code IS NOT NULL
        THEN
            OPEN c_reference_codes;
            FETCH c_reference_codes INTO x;

            IF c_reference_codes%NOTFOUND
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_REFER_CODE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

--  Parameter initialized to false to ignore error messages - Enh # 2102281
	jtf_task_utl.g_show_error_for_dup_reference := False;
        jtf_task_references_pvt.create_references (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_task_id => l_task_id,
            p_object_type_code => l_object_type_code,
            p_object_name => p_object_name,
            p_object_id => p_object_id,
            p_object_details => p_object_details,
            p_reference_code => p_reference_code,
            p_usage => p_usage,
            x_return_status => x_return_status,
            x_task_reference_id => x_task_reference_id,
            x_msg_count => x_msg_count ,
            x_msg_data => x_msg_data,
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

        if c_references%isopen then
             close c_references ;
        end if;


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);




    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN

         if c_references%isopen then
             close c_references ;
         end if;

            rollback to create_references_Pub ;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN NO_DATA_FOUND
        THEN

         if c_references%isopen then
             close c_references ;
         end if;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_NAME');
            fnd_message.set_token('P_OBJECT_TYPE_CODE',p_object_type_code );
            fnd_message.set_token('P_OBJECT_NAME', p_object_name );
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS
        THEN
         if c_references%isopen then
             close c_references ;
         end if;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
   PROCEDURE lock_references (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_reference_id   IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_data          OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER
   ) is
        l_api_version    CONSTANT NUMBER                                 := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                           := 'LOCK_REFERENCES';


        Resource_Locked exception ;

        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;

   begin
        SAVEPOINT lock_references_pub;

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

        jtf_task_references_pkg.lock_row(
            x_task_reference_id => p_task_reference_id ,
            x_object_version_number => p_object_version_number  );


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
       WHEN Resource_Locked then
            ROLLBACK TO lock_references_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'References');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO lock_references_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO lock_references_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
/*    PROCEDURE validate_source_object (
        p_object_type_code        IN       VARCHAR2,
        p_object_id               IN       NUMBER,
        p_object_name             IN       VARCHAR2,
        x_return_status           OUT NOCOPY      VARCHAR2
    )
    IS
        CURSOR c_references
        IS
            SELECT select_id,
                   select_name,
                   from_table,
                   where_clause
              FROM jtf_objects_vl
             WHERE object_code = p_object_type_code;




        l_id_column           jtf_objects_b.select_id%TYPE;
        l_name_column         jtf_objects_b.select_name%TYPE;
        l_from_clause         jtf_objects_b.from_table%TYPE;
        l_where_clause        jtf_objects_b.where_clause%TYPE;
        l_object_type_code    jtf_tasks_b.source_object_type_code%TYPE  := p_object_type_code;
        l_object_name         jtf_tasks_b.source_object_name%TYPE       := p_object_name;
        l_object_id           jtf_tasks_b.source_object_id%TYPE         := p_object_id;
        sql_stmt              VARCHAR2(2000);
    BEGIN



        x_return_status := fnd_api.g_ret_sts_success;
        OPEN c_references;
        FETCH c_references INTO l_id_column, l_name_column, l_from_clause, l_where_clause;


        IF c_references%NOTFOUND
        THEN

            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
            fnd_message.set_token('P_OBJECT_TYPE_CODE',p_object_type_code);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


        SELECT DECODE (l_where_clause, NULL, '  ', l_where_clause || ' AND ')
          INTO l_where_clause
          FROM dual;
        sql_stmt := ' SELECT ' ||
                    l_name_column ||
                    ' , ' ||
                    l_id_column ||
                    ' from ' ||
                    l_from_clause ||
                    '  where ' ||
                    l_where_clause ||
                    l_name_column ||
                    ' = ' ||
                    p_object_name;

        EXECUTE IMMEDIATE sql_stmt
            INTO l_object_name, l_object_id;

        IF p_object_id IS NOT NULL
        THEN
            IF p_object_id <> l_object_id
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_NAME');
                fnd_message.set_token('P_OBJECT_TYPE_CODE',p_object_type_code );
                fnd_message.set_token('P_OBJECT_NAME', p_object_name );
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
        WHEN NO_DATA_FOUND
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS
        THEN

            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;
   */

    PROCEDURE update_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN     OUT NOCOPY NUMBER ,
        p_task_reference_id       IN       NUMBER,
        p_object_type_code    IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_object_name         IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_object_id           IN       NUMBER DEFAULT  fnd_api.g_miss_num,
        p_object_details      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_reference_code      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_usage               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_data                OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
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
        l_api_version       CONSTANT NUMBER                                        := 1.0;
        l_api_name          CONSTANT VARCHAR2(30)                                  := 'UPDATE_REFERENCES';

        l_task_id              jtf_tasks_b.task_id%TYPE;
        l_object_type_code     jtf_objects_b.object_code%TYPE := p_object_type_code;
        l_task_reference_id    jtf_task_references_b.task_reference_id%TYPE  := p_task_reference_id;
        l_reference_code       jtf_task_references_b.reference_code%TYPE     := p_reference_code;
        l_usage                jtf_task_references_tl.usage%TYPE             := p_usage;
        l_object_name          jtf_task_references_b.object_name%TYPE;
        l_object_id            jtf_task_references_b.object_id%TYPE;

        CURSOR c_task_reference
        IS
            SELECT task_id,
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
             WHERE task_reference_id = p_task_reference_id;

        task_references        c_task_reference%ROWTYPE;
    BEGIN



        savepoint update_task_reference_pub ;

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
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_REFER');
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
/*        --------
        --------  Validate Object Type
        --------
        l_object_type_code := task_references.object_type_code;

       jtf_task_utl.validate_object_type (
                p_object_code => l_object_type_code,
                p_object_type_name => NULL,
                x_return_status => x_return_status,
                x_object_code => l_object_type_code
            );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;


        --------
        --------  Validate object details
        --------
        l_object_name := task_references.object_name;


        l_object_id := task_references.object_id;


        validate_source_object(
            p_object_type_code => l_object_type_code,
            p_object_name => l_object_name,
            p_object_id => l_object_id,
            x_return_status => x_return_status
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_REFER_DETAILS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
*/

      -------
      -------   Validate source object details
      -------


      jtf_task_utl.validate_source_object (
         p_object_code => task_references.object_type_code,
         p_object_id => task_references.object_id ,
         p_object_name => task_references.object_name,
         x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;




        --------
        --------  Validate Reference code
        --------
        l_reference_code := task_references.reference_code;

        IF (   l_reference_code IS NOT NULL
           AND l_reference_code <> task_references.reference_code)
        THEN
            jtf_task_utl.validate_reference_codes (p_reference_code => l_reference_code, x_return_status => x_return_status);

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        l_usage := task_references.usage;

        --- Call the private ;

--  Parameter initialized to false to ignore error messages - Enh # 2102281
	jtf_task_utl.g_show_error_for_dup_reference := False;
        jtf_task_references_pvt.update_references (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_task_reference_id => l_task_reference_id,
            p_object_type_code => task_references.object_type_code,
            p_object_name => task_references.object_name,
            p_object_id => task_references.object_id,
            p_object_details => p_object_details,
            p_reference_code => l_reference_code,
            p_usage => l_usage,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count ,
            x_msg_data => x_msg_data,
            p_attribute1 => task_references.attribute1 ,
            p_attribute2 => task_references.attribute2 ,
            p_attribute3 => task_references.attribute3 ,
            p_attribute4 => task_references.attribute4 ,
            p_attribute5 => task_references.attribute5 ,
            p_attribute6 => task_references.attribute6 ,
            p_attribute7 => task_references.attribute7 ,
            p_attribute8 => task_references.attribute8 ,
            p_attribute9 => task_references.attribute9 ,
            p_attribute10 => task_references.attribute10 ,
            p_attribute11 => task_references.attribute11 ,
            p_attribute12 => task_references.attribute12 ,
            p_attribute13 => task_references.attribute13 ,
            p_attribute14 => task_references.attribute14 ,
            p_attribute15 => task_references.attribute15 ,
            p_attribute_category => task_references.attribute_category
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

        if c_task_reference%isopen then
             close c_task_reference ;
        end if;


    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_task_reference_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        if c_task_reference%isopen then
             close c_task_reference ;
        end if;

        WHEN OTHERS
        THEN
            ROLLBACK TO update_task_reference_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        if c_task_reference%isopen then
             close c_task_reference ;
        end if;


    END;   ----- Update Task

-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------


    PROCEDURE delete_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN       NUMBER ,
        p_task_reference_id       IN       NUMBER ,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_data                OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER
    )
    IS
        l_api_version    CONSTANT NUMBER       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30) := 'DELETE_REFERENCES';
    BEGIN
        SAVEPOINT delete_task_reference_pub;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        jtf_task_references_pub.lock_references
        ( P_API_VERSION                 =>	1.0,
         P_INIT_MSG_LIST                =>	fnd_api.g_false ,
         P_COMMIT                       =>	fnd_api.g_false ,
         P_TASK_reference_ID            =>	p_task_reference_id ,
         P_OBJECT_VERSION_NUMBER        =>	p_object_version_number,
         X_RETURN_STATUS                =>	x_return_status ,
         X_MSG_DATA                     =>	x_msg_data ,
         X_MSG_COUNT                    =>	x_msg_count ) ;

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        jtf_task_references_pvt.delete_references (
            p_api_version => 1.0,
            p_init_msg_list => fnd_api.g_false,
            p_commit => fnd_api.g_false,
            p_object_version_number => p_object_version_number,
            p_task_reference_id => p_task_reference_id,
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
            ROLLBACK TO delete_task_reference_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO delete_task_reference_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;
END;

/
