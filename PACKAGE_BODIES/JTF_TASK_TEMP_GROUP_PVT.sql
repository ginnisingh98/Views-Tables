--------------------------------------------------------
--  DDL for Package Body JTF_TASK_TEMP_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_TEMP_GROUP_PVT" AS
/* $Header: jtfvtkgb.pls 115.23 2002/12/05 00:03:37 cjang ship $ */
   v_select   VARCHAR2(6000);
   v_tbl      jtf_task_temp_group_pub.task_temp_group_tbl;

   PROCEDURE create_task_template_group (
      p_commit                    IN       VARCHAR2,
      p_template_group_name       IN       VARCHAR2,
      p_source_object_type_code   IN       VARCHAR2,
      p_start_date_active         IN       DATE,
      p_end_date_active           IN       DATE,
      p_description               IN       VARCHAR2,
      p_attribute1                IN       VARCHAR2,
      p_attribute2                IN       VARCHAR2,
      p_attribute3                IN       VARCHAR2,
      p_attribute4                IN       VARCHAR2,
      p_attribute5                IN       VARCHAR2,
      p_attribute6                IN       VARCHAR2,
      p_attribute7                IN       VARCHAR2,
      p_attribute8                IN       VARCHAR2,
      p_attribute9                IN       VARCHAR2,
      p_attribute10               IN       VARCHAR2,
      p_attribute11               IN       VARCHAR2,
      p_attribute12               IN       VARCHAR2,
      p_attribute13               IN       VARCHAR2,
      p_attribute14               IN       VARCHAR2,
      p_attribute15               IN       VARCHAR2,
      p_attribute_category        IN       VARCHAR2,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      x_task_template_group_id    OUT NOCOPY      NUMBER,
      p_application_id            IN       NUMBER DEFAULT NULL
   )
   IS
      l_api_name                 VARCHAR2(30)
               := 'CREATE_TASK_TEMPLATE_GROUP';
      v_rowid                    VARCHAR2(24);
      v_task_template_group_id   jtf_task_temp_groups_b.task_template_group_id%TYPE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT create_template_group_pvt;
      SELECT jtf_task_temp_groups_s.nextval
        INTO v_task_template_group_id
        FROM dual;
      -- call table handler to insert into jtf_tasks_temp_groups
      jtf_task_temp_groups_pkg.insert_row (
         v_rowid,
         v_task_template_group_id,
         p_source_object_type_code,
         p_start_date_active,
         p_end_date_active,
         p_attribute1,
         p_attribute2,
         p_attribute3,
         p_attribute4,
         p_attribute5,
         p_attribute6,
         p_attribute7,
         p_attribute8,
         p_attribute9,
         p_attribute10,
         p_attribute11,
         p_attribute12,
         p_attribute13,
         p_attribute14,
         p_attribute15,
         p_attribute_category,
         p_template_group_name,
         p_description,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id,
         p_application_id
      );

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;

      x_task_template_group_id := v_task_template_group_id;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END create_task_template_group;

   PROCEDURE update_task_template_group (
      p_commit                    IN       VARCHAR2,
      p_task_template_group_id    IN       NUMBER,
      p_template_group_name       IN       VARCHAR2,
      p_source_object_type_code   IN       VARCHAR2,
      p_start_date_active         IN       DATE,
      p_end_date_active           IN       DATE,
      p_description               IN       VARCHAR2,
      p_attribute1                IN       VARCHAR2,
      p_attribute2                IN       VARCHAR2,
      p_attribute3                IN       VARCHAR2,
      p_attribute4                IN       VARCHAR2,
      p_attribute5                IN       VARCHAR2,
      p_attribute6                IN       VARCHAR2,
      p_attribute7                IN       VARCHAR2,
      p_attribute8                IN       VARCHAR2,
      p_attribute9                IN       VARCHAR2,
      p_attribute10               IN       VARCHAR2,
      p_attribute11               IN       VARCHAR2,
      p_attribute12               IN       VARCHAR2,
      p_attribute13               IN       VARCHAR2,
      p_attribute14               IN       VARCHAR2,
      p_attribute15               IN       VARCHAR2,
      p_attribute_category        IN       VARCHAR2,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      x_object_version_number     IN OUT NOCOPY   NUMBER,
      p_application_id            IN       NUMBER DEFAULT NULL
   )
   IS
      l_api_name   VARCHAR2(30) := 'UPDATE_TASK_TEMPLATE_GROUP';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT update_template_group_pvt;
      -- call locking table handler
      jtf_task_temp_groups_pkg.lock_row (
         p_task_template_group_id,
         x_object_version_number
      );
      -- call table handler to insert into jtf_tasks_temp_groups
      jtf_task_temp_groups_pkg.update_row (
         p_task_template_group_id,
         x_object_version_number + 1,
         p_source_object_type_code,
         p_start_date_active,
         p_end_date_active,
         p_attribute1,
         p_attribute2,
         p_attribute3,
         p_attribute4,
         p_attribute5,
         p_attribute6,
         p_attribute7,
         p_attribute8,
         p_attribute9,
         p_attribute10,
         p_attribute11,
         p_attribute12,
         p_attribute13,
         p_attribute14,
         p_attribute15,
         p_attribute_category,
         p_template_group_name,
         p_description,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id,
         p_application_id
      );

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;

      x_object_version_number := x_object_version_number + 1;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END update_task_template_group;

   PROCEDURE delete_task_template_group (
      p_commit                   IN       VARCHAR2,
      p_task_template_group_id   IN       NUMBER,
      x_return_status            OUT NOCOPY      VARCHAR2,
      x_msg_count                OUT NOCOPY      NUMBER,
      x_msg_data                 OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name   VARCHAR2(30) := 'DELETE_TASK_TEMPLATE_GROUP';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT delete_template_group_pvt;
      -- call table handler to insert into jtf_tasks_temp_groups
      jtf_task_temp_groups_pkg.delete_row (p_task_template_group_id);

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_template_group_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END delete_task_template_group;

   PROCEDURE dump_long_line (txt IN VARCHAR2, v_str IN VARCHAR2)
   IS
      LN   INTEGER := LENGTH (v_str);
      st   INTEGER := 1;
   BEGIN
      NULL;
   --loop

   --st := st + 72;
   --exit when (st >= ln);
   --end loop;

   END dump_long_line;

   PROCEDURE get_task_template_group (
      p_commit                    IN       VARCHAR2
            DEFAULT fnd_api.g_false,
      p_task_template_group_id    IN       NUMBER,
      p_template_group_name       IN       VARCHAR2,
      p_source_object_type_code   IN       VARCHAR2,
      p_start_date_active         IN       DATE,
      p_end_date_active           IN       DATE,
      p_sort_data                 IN       jtf_task_temp_group_pub.sort_data,
      p_query_or_next_code        IN       VARCHAR2
            DEFAULT 'Q',
      p_start_pointer             IN       NUMBER,
      p_rec_wanted                IN       NUMBER,
      p_show_all                  IN       VARCHAR2
            DEFAULT 'Y',
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      x_task_template_group       OUT NOCOPY      jtf_task_temp_group_pub.task_temp_group_tbl,
      x_total_retrieved           OUT NOCOPY      NUMBER,
      x_total_returned            OUT NOCOPY      NUMBER,
      p_application_id            IN       NUMBER
            DEFAULT NULL
   )
   IS
      -- declare variables
      l_api_name    VARCHAR2(30)
               := 'GET_TASK_TEMPLATE_GROUP';
      v_cursor_id   INTEGER;
      v_dummy       INTEGER;
      v_cnt         INTEGER;
      v_end         INTEGER;
      v_start       INTEGER;
      v_type        jtf_task_temp_group_pub.task_template_group_rec;

      PROCEDURE create_sql_statement
      IS
         v_index   INTEGER;
         v_first   INTEGER;
         v_comma   VARCHAR2(5);
         v_where   VARCHAR2(2000);
         v_and     CHAR(1)        := 'N';

         PROCEDURE add_to_sql (
            p_in      VARCHAR2,   --value in parameter
            p_bind    VARCHAR2,   --bind variable to use
            p_field   VARCHAR2   --field associated with parameter
         )
         IS
            v_str   VARCHAR2(10);
         BEGIN   -- add_to_sql
            IF (p_in IS NOT NULL)
            THEN
               IF (v_and = 'N')
               THEN
                  v_str := ' ';
                  v_and := 'Y';
               ELSE
                  v_str := ' and ';
               END IF;

               v_where := v_where || v_str || p_field || ' = :' || p_bind;
            END IF;
         END add_to_sql;
      BEGIN   --create_sql_statement
         v_select := 'select TASK_TEMPLATE_GROUP_ID,' ||
                     'TEMPLATE_GROUP_NAME,' ||
                     'SOURCE_OBJECT_TYPE_CODE,' ||
                     'START_DATE_ACTIVE,' ||
                     'END_DATE_ACTIVE,' ||
                     'DESCRIPTION,' ||
                     'ATTRIBUTE1,' ||
                     'ATTRIBUTE2,' ||
                     'ATTRIBUTE3,' ||
                     'ATTRIBUTE4,' ||
                     'ATTRIBUTE5,' ||
                     'ATTRIBUTE6,' ||
                     'ATTRIBUTE7,' ||
                     'ATTRIBUTE8,' ||
                     'ATTRIBUTE9,' ||
                     'ATTRIBUTE10,' ||
                     'ATTRIBUTE11,' ||
                     'ATTRIBUTE12,' ||
                     'ATTRIBUTE13,' ||
                     'ATTRIBUTE14,' ||
                     'ATTRIBUTE15,' ||
                     'ATTRIBUTE_CATEGORY,' ||
                     'object_version_number ,' ||
                     'APPLICATION_ID ' ||
                     'from jtf_task_temp_groups_vl ';
         add_to_sql (
            TO_CHAR (p_task_template_group_id),
            'b1',
            'task_template_group_id'
         );
         add_to_sql (p_template_group_name, 'b2', 'template_group_name');
         add_to_sql (
            p_source_object_type_code,
            'b3',
            'source_object_type_code'
         );
         add_to_sql (
            TO_CHAR (p_start_date_active, 'dd-mon-rrrr'),
            'b4',
            'start_date_active'
         );
         add_to_sql (
            TO_CHAR (p_end_date_active, 'dd-mon-rrrr'),
            'b5',
            'end_date_active'
         );
         add_to_sql (TO_CHAR (p_application_id), 'b6', 'application_id');

         IF (v_where IS NOT NULL)
         THEN
            v_select := v_select || ' where ' || v_where;
         END IF;

         IF (p_sort_data.COUNT > 0)
         THEN   --there is a sort preference
            v_select := v_select || ' order by ';
            v_index := p_sort_data.FIRST;
            v_first := v_index;

            LOOP
               IF (v_first = v_index)
               THEN
                  v_comma := ' ';
               ELSE
                  v_comma := ', ';
               END IF;

               v_select := v_select ||
                           v_comma ||
                           p_sort_data (v_index).field_name ||
                           ' ';

               -- ascending or descending order
               IF (p_sort_data (v_index).asc_dsc_flag = 'A')
               THEN
                  v_select := v_select || 'asc ';
               ELSIF (p_sort_data (v_index).asc_dsc_flag = 'D')
               THEN
                  v_select := v_select || 'desc ';
               END IF;

               EXIT WHEN v_index = p_sort_data.LAST;
               v_index := p_sort_data.NEXT (v_index);
            END LOOP;
         END IF;
      END create_sql_statement;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_task_template_group.DELETE;

      IF (p_query_or_next_code = 'Q')
      THEN
         v_tbl.DELETE;
         create_sql_statement;
         dump_long_line ('v_sel:', v_select);
         v_cursor_id := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (v_cursor_id, v_select, DBMS_SQL.v7);

         -- bind variables only if they added to the sql statement
         IF (p_task_template_group_id IS NOT NULL)
         THEN
            DBMS_SQL.bind_variable (
               v_cursor_id,
               ':b1',
               p_task_template_group_id
            );
         END IF;

         IF (p_template_group_name IS NOT NULL)
         THEN
            DBMS_SQL.bind_variable (v_cursor_id, ':b2', p_template_group_name);
         END IF;

         IF (p_source_object_type_code IS NOT NULL)
         THEN
            DBMS_SQL.bind_variable (
               v_cursor_id,
               ':b3',
               p_source_object_type_code
            );
         END IF;

         IF (p_start_date_active IS NOT NULL)
         THEN
            DBMS_SQL.bind_variable (v_cursor_id, ':b4', p_start_date_active);
         END IF;

         IF (p_end_date_active IS NOT NULL)
         THEN
            DBMS_SQL.bind_variable (v_cursor_id, ':b5', p_end_date_active);
         END IF;

         IF (p_application_id IS NOT NULL)
         THEN
            DBMS_SQL.bind_variable (v_cursor_id, ':b6', p_application_id);
         END IF;

         -- define the output columns
         DBMS_SQL.define_column (
            v_cursor_id,
            1,
            v_type.task_template_group_id
         );
         DBMS_SQL.define_column (
            v_cursor_id,
            2,
            v_type.template_group_name,
            80
         );
         DBMS_SQL.define_column (
            v_cursor_id,
            3,
            v_type.source_object_type_code,
            80
         );
         DBMS_SQL.define_column (v_cursor_id, 4, v_type.start_date_active);
         DBMS_SQL.define_column (v_cursor_id, 5, v_type.end_date_active);
         DBMS_SQL.define_column (v_cursor_id, 6, v_type.description, 4000);
         DBMS_SQL.define_column (v_cursor_id, 7, v_type.attribute1, 240);
         DBMS_SQL.define_column (v_cursor_id, 8, v_type.attribute2, 150);
         DBMS_SQL.define_column (v_cursor_id, 9, v_type.attribute3, 150);
         DBMS_SQL.define_column (v_cursor_id, 10, v_type.attribute4, 150);
         DBMS_SQL.define_column (v_cursor_id, 11, v_type.attribute5, 150);
         DBMS_SQL.define_column (v_cursor_id, 12, v_type.attribute6, 150);
         DBMS_SQL.define_column (v_cursor_id, 13, v_type.attribute7, 150);
         DBMS_SQL.define_column (v_cursor_id, 14, v_type.attribute8, 150);
         DBMS_SQL.define_column (v_cursor_id, 15, v_type.attribute9, 150);
         DBMS_SQL.define_column (v_cursor_id, 16, v_type.attribute10, 150);
         DBMS_SQL.define_column (v_cursor_id, 17, v_type.attribute11, 150);
         DBMS_SQL.define_column (v_cursor_id, 18, v_type.attribute12, 150);
         DBMS_SQL.define_column (v_cursor_id, 19, v_type.attribute13, 150);
         DBMS_SQL.define_column (v_cursor_id, 20, v_type.attribute14, 150);
         DBMS_SQL.define_column (v_cursor_id, 21, v_type.attribute15, 150);
         DBMS_SQL.define_column (
            v_cursor_id,
            22,
            v_type.attribute_category,
            30
         );
         DBMS_SQL.define_column (
            v_cursor_id,
            23,
            v_type.object_version_number
         );
         DBMS_SQL.define_column (v_cursor_id, 24, v_type.application_id);
         v_dummy := DBMS_SQL.execute (v_cursor_id);
         v_cnt := 0;

         LOOP
            EXIT WHEN (DBMS_SQL.fetch_rows (v_cursor_id) = 0);
            v_cnt := v_cnt + 1;
            -- retrieve the rows from the buffer
            DBMS_SQL.column_value (
               v_cursor_id,
               1,
               v_type.task_template_group_id
            );
            DBMS_SQL.column_value (v_cursor_id, 2, v_type.template_group_name);
            DBMS_SQL.column_value (
               v_cursor_id,
               3,
               v_type.source_object_type_code
            );
            DBMS_SQL.column_value (v_cursor_id, 4, v_type.start_date_active);
            DBMS_SQL.column_value (v_cursor_id, 5, v_type.end_date_active);
            DBMS_SQL.column_value (v_cursor_id, 6, v_type.description);
            DBMS_SQL.column_value (v_cursor_id, 7, v_type.attribute1);
            DBMS_SQL.column_value (v_cursor_id, 8, v_type.attribute2);
            DBMS_SQL.column_value (v_cursor_id, 9, v_type.attribute3);
            DBMS_SQL.column_value (v_cursor_id, 10, v_type.attribute4);
            DBMS_SQL.column_value (v_cursor_id, 11, v_type.attribute5);
            DBMS_SQL.column_value (v_cursor_id, 12, v_type.attribute6);
            DBMS_SQL.column_value (v_cursor_id, 13, v_type.attribute7);
            DBMS_SQL.column_value (v_cursor_id, 14, v_type.attribute8);
            DBMS_SQL.column_value (v_cursor_id, 15, v_type.attribute9);
            DBMS_SQL.column_value (v_cursor_id, 16, v_type.attribute10);
            DBMS_SQL.column_value (v_cursor_id, 17, v_type.attribute11);
            DBMS_SQL.column_value (v_cursor_id, 18, v_type.attribute12);
            DBMS_SQL.column_value (v_cursor_id, 19, v_type.attribute13);
            DBMS_SQL.column_value (v_cursor_id, 20, v_type.attribute14);
            DBMS_SQL.column_value (v_cursor_id, 21, v_type.attribute15);
            DBMS_SQL.column_value (v_cursor_id, 22, v_type.attribute_category);
            DBMS_SQL.column_value (
               v_cursor_id,
               23,
               v_type.object_version_number
            );
            DBMS_SQL.column_value (v_cursor_id, 24, v_type.application_id);
            --                     'v_type.task_template_group_id:'||
            --                     to_char(v_type.task_template_group_id));
            v_tbl (v_cnt) := v_type;
         END LOOP;

         DBMS_SQL.close_cursor (v_cursor_id);
      END IF;   --p_query_or_next_code;

      -- copy records to be returned back
      x_total_retrieved := v_tbl.COUNT;

      -- if table is empty do nothing
      IF (x_total_retrieved > 0)
      THEN
         IF (p_show_all = 'Y')
         THEN   -- return all the rows
            v_start := v_tbl.FIRST;
            v_end := v_tbl.LAST;
         ELSE
            v_start := p_start_pointer;
            v_end := p_start_pointer + p_rec_wanted - 1;

            IF (v_end > v_tbl.LAST)
            THEN
               v_end := v_tbl.LAST;
            END IF;
         END IF;

         FOR v_cnt IN v_start .. v_end
         LOOP
            x_task_template_group (v_cnt) := v_tbl (v_cnt);
         END LOOP;
      END IF;

      x_total_returned := x_task_template_group.COUNT;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END get_task_template_group;
END;

/
