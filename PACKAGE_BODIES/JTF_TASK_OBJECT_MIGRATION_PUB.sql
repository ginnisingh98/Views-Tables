--------------------------------------------------------
--  DDL for Package Body JTF_TASK_OBJECT_MIGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_OBJECT_MIGRATION_PUB" AS
/* $Header: jtfptkjb.pls 115.0 2003/04/08 23:42:10 cjang noship $ */

    PROCEDURE update_object_name(p_object_code   IN         VARCHAR2
                                ,p_init_msg_list IN         VARCHAR2 DEFAULT fnd_api.g_false
                                ,p_commit        IN         VARCHAR2 DEFAULT fnd_api.g_false
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2)
    IS
        CURSOR c_object IS
        SELECT select_id, select_name, from_table, where_clause
         FROM jtf_objects_b
        WHERE object_code = p_object_code;

        l_id_column      jtf_objects_b.select_id%TYPE;
        l_name_column    jtf_objects_b.select_name%TYPE;
        l_from_clause    jtf_objects_b.from_table%TYPE;
        l_where_clause   jtf_objects_b.where_clause%TYPE;

        l_stmt VARCHAR2(1000);

    BEGIN
        SAVEPOINT update_object_name_pub;
        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        OPEN c_object;
        FETCH c_object
         INTO l_id_column
            , l_name_column
            , l_from_clause
            , l_where_clause;

        IF c_object%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_OBJECT_NOT_FOUND');
            fnd_message.set_token ('OBJECT_NAME', p_object_code);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_where_clause IS NOT NULL THEN
            l_where_clause := l_where_clause || ' AND ';
        ELSE
            l_where_clause := l_where_clause || ' ';
        END IF;

        l_stmt := 'UPDATE jtf_tasks_b '||
                  '   SET source_object_name = (SELECT SUBSTRB('||l_name_column||',1,80)'||
                                                ' FROM '||l_from_clause||
                                               ' WHERE '||l_where_clause||
                                                          l_id_column||' = source_object_id) '||
                  ' WHERE source_object_type_code = '''||p_object_code||''''||
                  '   AND NVL(deleted_flag,''N'') = ''N''';
        EXECUTE IMMEDIATE l_stmt;

        l_stmt := 'UPDATE jtf_task_references_b '||
                  '   SET object_name = (SELECT SUBSTRB('||l_name_column||',1,80)'||
                                         ' FROM '||l_from_clause||
                                        ' WHERE '||l_where_clause||
                                                   l_id_column||' = object_id) '||
                  ' WHERE object_type_code = '''||p_object_code||'''';
        EXECUTE IMMEDIATE l_stmt;

        IF fnd_api.to_boolean (p_commit)
        THEN
           COMMIT WORK;
        END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO update_object_name_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF c_object%ISOPEN
            THEN
                CLOSE c_object;
            END IF;
            fnd_msg_pub.count_and_get (
                p_count => x_msg_count
               ,p_data  => x_msg_data
            );
        WHEN OTHERS THEN
            ROLLBACK TO update_object_name_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF c_object%ISOPEN
            THEN
                CLOSE c_object;
            END IF;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (
                p_count => x_msg_count
               ,p_data  => x_msg_data
            );
    END update_object_name;

END JTF_TASK_OBJECT_MIGRATION_PUB;

/
