--------------------------------------------------------
--  DDL for Package Body JTF_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_OBJECTS_PUB" AS
/* $Header: jtfptkob.pls 120.2 2005/08/10 20:43:51 akaran ship $ */
   g_pkg_name   VARCHAR2(30) := 'JTF_OBJECTS_PUB';

   TYPE OBJECT_PG_REC IS RECORD
   (
     OBJECT_CODE      VARCHAR2(30),
     APPLICATION_ID   NUMBER,
     PG_FUNCTION      FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE,
     PG_PARAMS        VARCHAR2(2000)
   );

   TYPE OBJECT_PG_TBL IS TABLE OF OBJECT_PG_REC INDEX BY BINARY_INTEGER;

   G_OBJECT_PG_TBL  OBJECT_PG_TBL;


   FUNCTION jtf_obj_select_stmt (
      select_id         IN   jtf_objects_b.select_id%TYPE DEFAULT NULL,
      select_name       IN   jtf_objects_b.select_name%TYPE DEFAULT NULL,
      select_details    IN   jtf_objects_b.select_details%TYPE DEFAULT NULL,
      from_table        IN   jtf_objects_b.from_table%TYPE DEFAULT NULL,
      where_clause      IN   jtf_objects_b.where_clause%TYPE DEFAULT NULL,
      p_inactive_clause IN   jtf_objects_b.inactive_clause%TYPE DEFAULT NULL,
      order_by_clause   IN   jtf_objects_b.order_by_clause%TYPE DEFAULT NULL
      )
      RETURN VARCHAR2
   IS
      l_select_id         jtf_objects_b.select_id%TYPE       := select_id;
      l_select_name       jtf_objects_b.select_name%TYPE     := select_name;
      l_select_details    jtf_objects_b.select_details%TYPE
               := select_details;
      l_from_table        jtf_objects_b.from_table%TYPE      := from_table;
      l_where_clause      jtf_objects_b.where_clause%TYPE    := where_clause;
      l_order_by_clause   jtf_objects_b.order_by_clause%TYPE
               := order_by_clause;
      --l_select_statement   VARCHAR2(6000);
      str                 VARCHAR2(6000);
      initialized         BOOLEAN                            := FALSE;
   BEGIN
      IF (l_from_table IS NULL)
      THEN
         RETURN NULL;
      END IF;

      IF l_select_id IS NULL
      THEN
         IF l_select_name IS NULL
         THEN
            IF l_select_details IS NULL
            THEN
               RETURN NULL;
            ELSE
               str := 'select ' || l_select_details;
            END IF;
         ELSE
            IF l_select_details IS NULL
            THEN
               str := 'select ' || l_select_name;
            ELSE
               str := 'select ' || l_select_name || ', ' || l_select_details;
            END IF;
         END IF;
      ELSE
         IF l_select_name IS NULL
         THEN
            IF l_select_details IS NULL
            THEN
               str := 'select ' || l_select_id;
            ELSE
               str := 'select ' || l_select_id || ', ' || l_select_details;
            END IF;
         ELSE
            IF l_select_details IS NULL
            THEN
               str := 'select ' || l_select_id || ', ' || l_select_name;
            ELSE
               str := 'select ' ||
                      l_select_id ||
                      ', ' ||
                      l_select_name ||
                      ', ' ||
                      l_select_details;
            END IF;
         END IF;
      END IF;

      str := str || ' from ' || l_from_table || ' ';

      IF l_where_clause IS NOT NULL
      THEN
         str := str || 'where ' || l_where_clause || ' ';
      END IF;

-- Added for Bug# 2557586
      IF p_inactive_clause IS NOT NULL
      THEN
         IF l_where_clause IS NOT NULL
         THEN
             str := str || ' and ' || p_inactive_clause;
         ELSE
             str := str || ' where ' || p_inactive_clause;
         END IF;
      END IF;

      IF l_order_by_clause IS NOT NULL
      THEN
         str := str || 'order by ' || l_order_by_clause;
      END IF;
   END jtf_obj_select_stmt;

   PROCEDURE check_syntax (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_select_id         IN       jtf_objects_b.select_id%TYPE DEFAULT NULL,
      p_select_name       IN       jtf_objects_b.select_name%TYPE DEFAULT NULL,
      p_select_details    IN       jtf_objects_b.select_details%TYPE
            DEFAULT NULL,
      p_from_table        IN       jtf_objects_b.from_table%TYPE DEFAULT NULL,
      p_where_clause      IN       jtf_objects_b.where_clause%TYPE
            DEFAULT NULL,
      p_inactive_clause   IN       jtf_objects_b.inactive_clause%TYPE DEFAULT NULL, -- Added for Bug# 2557586
      p_order_by_clause   IN       jtf_objects_b.order_by_clause%TYPE
            DEFAULT NULL,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_sql_statement     OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name               VARCHAR2(240)
               := 'CHECK_SYNTAX';
      l_api_version            NUMBER                             := 1.0;
      l_select_id              jtf_objects_b.select_id%TYPE
               := p_select_id;
      l_select_name            jtf_objects_b.select_name%TYPE
               := p_select_name;
      l_select_details         jtf_objects_b.select_details%TYPE
               := p_select_details;
      l_from_table             jtf_objects_b.from_table%TYPE
               := p_from_table;
      l_where_clause           jtf_objects_b.where_clause%TYPE
               := p_where_clause;
      l_order_by_clause        jtf_objects_b.order_by_clause%TYPE
               := p_order_by_clause;
      --x_sql_statement       VARCHAR2(6000);
      str                      VARCHAR2(6000);
      l_select_columns         NUMBER                             := 0;
      l_dummy_select_id        VARCHAR2(2000);
      l_dummy_select_name      VARCHAR2(2000);
      l_dummy_select_details   VARCHAR2(2000);
      initialized              BOOLEAN                            := FALSE;
   BEGIN
      SAVEPOINT check_syntax;
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

      IF l_from_table IS NULL
      THEN
         RETURN;
      END IF;

      IF l_select_id IS NOT NULL
      THEN
         x_sql_statement := ' select ' || l_select_id;
         initialized := TRUE;
         l_select_columns := l_select_columns + 1;
      END IF;

      IF l_select_name IS NOT NULL
      THEN
         IF initialized = TRUE
         THEN
            x_sql_statement := x_sql_statement || ', ' || l_select_name;
            initialized := TRUE;
            l_select_columns := l_select_columns + 1;
         ELSE
            x_sql_statement := ' select ' || l_select_name;
         END IF;
      END IF;

      IF l_select_details IS NOT NULL
      THEN
         IF initialized = TRUE
         THEN
            x_sql_statement := x_sql_statement || ', ' || l_select_details;
            initialized := TRUE;
            l_select_columns := l_select_columns + 1;
         ELSE
            x_sql_statement := ' select ' || l_select_details;
         END IF;
      END IF;

      IF initialized = FALSE
      THEN
         x_sql_statement := ' select 1 ';
      END IF;

      IF l_from_table IS NULL
      THEN
         RETURN;
      ELSE
         x_sql_statement := x_sql_statement || ' from ' || l_from_table;
      END IF;

      IF l_where_clause IS NOT NULL
      THEN
         x_sql_statement := x_sql_statement || ' where ' || l_where_clause;
      END IF;

-- Added for Bug# 2557586
      IF p_inactive_clause IS NOT NULL
      THEN
         IF l_where_clause IS NOT NULL
         THEN
             x_sql_statement := x_sql_statement || ' and ' || p_inactive_clause;
         ELSE
             x_sql_statement := x_sql_statement || ' where ' || p_inactive_clause;
         END IF;
      END IF;

      IF l_order_by_clause IS NOT NULL
      THEN
         x_sql_statement :=
            x_sql_statement || ' order by ' || l_order_by_clause;
      END IF;

      BEGIN
         IF l_select_columns = 1
         THEN
            EXECUTE IMMEDIATE x_sql_statement
               INTO l_dummy_select_id;
         END IF;

         IF l_select_columns = 2
         THEN
            EXECUTE IMMEDIATE x_sql_statement
               INTO l_dummy_select_id, l_dummy_select_name;
         END IF;

         IF l_select_columns = 3
         THEN
            EXECUTE IMMEDIATE x_sql_statement
               INTO l_dummy_select_id, l_dummy_select_name, l_dummy_select_details;
         END IF;

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT WORK;
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      EXCEPTION
         WHEN TOO_MANY_ROWS
         THEN
            NULL;
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            ROLLBACK TO check_syntax;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_OBJECTS_SYNTAX_ERROR');
            fnd_message.set_token ('P_MESSAGE_TEXT', SQLERRM);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (
               p_count => x_msg_count,
               p_data => x_msg_data
            );
      END;
   END;

   PROCEDURE initialize_cache
   IS

   BEGIN
     G_OBJECT_PG_TBL.DELETE;
   END initialize_cache;


   PROCEDURE get_drilldown_page (
      p_input_rec         IN PG_INPUT_REC,
      x_pg_function       OUT NOCOPY VARCHAR2,
      x_pg_parameters     OUT NOCOPY VARCHAR2
   ) IS

     CURSOR C_OBJ_PAGE
     (
       b_object_code         VARCHAR2,
       b_default_object_code VARCHAR2,
       b_application_id      NUMBER
     ) IS
     SELECT 1 AS OBJ_ROW_TYPE
          , JOPD.PG_REGION_PATH
          , JOPP.DEST_PARAM
          , JOPP.SOURCE_PARAM
     FROM   JTF_OBJECTS_B JOB
          , JTF_OBJECT_PG_DTLS JOPD
          , JTF_OBJECT_PG_PARAMS JOPP
     WHERE  JOB.OBJECT_CODE     = b_object_code
     AND    JOPD.OBJECT_CODE    = JOB.OBJECT_CODE
     AND    JOPD.APPLICATION_ID = b_application_id
     AND    JOPD.PAGE_TYPE      = 'OA_PAGE'
     AND    JOPP.OBJECT_DTLS_ID = JOPD.OBJECT_DTLS_ID
     UNION ALL
     SELECT 2 AS OBJ_ROW_TYPE
          , JOPD.PG_REGION_PATH
          , JOPP.DEST_PARAM
          , JOPP.SOURCE_PARAM
     FROM   JTF_OBJECTS_B JOB
          , JTF_OBJECT_PG_DTLS JOPD
          , JTF_OBJECT_PG_PARAMS JOPP
     WHERE  JOB.OBJECT_CODE     = b_default_object_code
     AND    JOPD.OBJECT_CODE    = JOB.OBJECT_CODE
     AND    JOPD.APPLICATION_ID = JOB.APPLICATION_ID
     AND    JOPD.PAGE_TYPE      = 'OA_PAGE'
     AND    JOPP.OBJECT_DTLS_ID = JOPD.OBJECT_DTLS_ID;

     i                     BINARY_INTEGER;
     l_object_code         VARCHAR2(30);
     l_default_object_code VARCHAR2(30);
     l_use_default         BOOLEAN;

   BEGIN

     x_pg_function   := NULL;
     x_pg_parameters := NULL;
     IF ((p_input_rec.ENTITY IS NULL) OR (p_input_rec.OBJECT_CODE IS NULL))
     THEN
       RETURN;
     END IF;

     l_object_code         := p_input_rec.OBJECT_CODE;
     l_default_object_code := p_input_rec.ENTITY;
     -- For the following two cases the object code could be other than the default
     -- ones, so reset the object code.
     IF (p_input_rec.ENTITY = 'TASK')
     THEN
       l_object_code         := 'TASK';
       l_default_object_code := 'TASK';
     ELSIF (p_input_rec.ENTITY = 'APPOINTMENT')
     THEN
       l_object_code         := 'APPOINTMENT';
       l_default_object_code := 'APPOINTMENT';
     END IF;

     IF (G_OBJECT_PG_TBL.COUNT > 0)
     THEN
       FOR i IN G_OBJECT_PG_TBL.FIRST..G_OBJECT_PG_TBL.LAST
       LOOP
         IF ((l_object_code = G_OBJECT_PG_TBL(i).OBJECT_CODE) AND
           (FND_GLOBAL.RESP_APPL_ID = G_OBJECT_PG_TBL(i).APPLICATION_ID))
         THEN
           x_pg_function   := G_OBJECT_PG_TBL(i).PG_FUNCTION;
           x_pg_parameters := G_OBJECT_PG_TBL(i).PG_PARAMS;
           RETURN;
         END IF;
       END LOOP;
     END IF;

     -- Nothing so far, so fetch and load
     i                                 := G_OBJECT_PG_TBL.COUNT + 1;
     G_OBJECT_PG_TBL(i).OBJECT_CODE    := l_object_code;
     G_OBJECT_PG_TBL(i).APPLICATION_ID := FND_GLOBAL.RESP_APPL_ID;
     G_OBJECT_PG_TBL(i).PG_FUNCTION    := NULL;
     G_OBJECT_PG_TBL(i).PG_PARAMS      := NULL;

     l_use_default := TRUE;

     FOR ref_obj_pg IN C_OBJ_PAGE (l_object_code,l_default_object_code,G_OBJECT_PG_TBL(i).APPLICATION_ID)
     LOOP
       IF (l_use_default AND (ref_obj_pg.OBJ_ROW_TYPE = 1))
       THEN
         l_use_default := FALSE;
       END IF;
       IF ((NOT l_use_default) AND (ref_obj_pg.OBJ_ROW_TYPE = 2))
       THEN
         EXIT;
       END IF;
       G_OBJECT_PG_TBL(i).PG_FUNCTION    := ref_obj_pg.PG_REGION_PATH;
       IF (G_OBJECT_PG_TBL(i).PG_PARAMS IS NOT NULL)
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '&' || ref_obj_pg.DEST_PARAM;
       ELSE
         G_OBJECT_PG_TBL(i).PG_PARAMS := ref_obj_pg.DEST_PARAM;
       END IF;
       -- now set the value of the parameter
       IF ((ref_obj_pg.SOURCE_PARAM = 'TaskId') AND (p_input_rec.TASK_ID IS NOT NULL))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || p_input_rec.TASK_ID;
       ELSIF ((ref_obj_pg.SOURCE_PARAM = 'SourceObjectId') AND (p_input_rec.SOURCE_OBJECT_ID IS NOT NULL))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || p_input_rec.SOURCE_OBJECT_ID;
       ELSIF ((ref_obj_pg.SOURCE_PARAM = 'TaskAssignmentId') AND (p_input_rec.TASK_ASSIGNMENT_ID IS NOT NULL))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || p_input_rec.TASK_ASSIGNMENT_ID;
       ELSIF ((ref_obj_pg.SOURCE_PARAM = 'CalItemId') AND (p_input_rec.CAL_ITEM_ID IS NOT NULL))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || p_input_rec.CAL_ITEM_ID;
       ELSIF ((ref_obj_pg.SOURCE_PARAM = 'ScheduleId') AND (p_input_rec.SCHEDULE_ID IS NOT NULL))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || p_input_rec.SCHEDULE_ID;
       ELSIF ((ref_obj_pg.SOURCE_PARAM = 'HRCalEventId') AND (p_input_rec.HR_CAL_EVENT_ID IS NOT NULL))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || p_input_rec.HR_CAL_EVENT_ID;
       ELSIF ((SUBSTR(ref_obj_pg.SOURCE_PARAM,1,1) = '''') AND (SUBSTR(ref_obj_pg.SOURCE_PARAM,LENGTH(ref_obj_pg.SOURCE_PARAM),1) = ''''))
       THEN
         G_OBJECT_PG_TBL(i).PG_PARAMS := G_OBJECT_PG_TBL(i).PG_PARAMS || '=' || SUBSTR(ref_obj_pg.SOURCE_PARAM,2,LENGTH(ref_obj_pg.SOURCE_PARAM)-2);
       END IF;
     END LOOP;

     x_pg_function   := G_OBJECT_PG_TBL(i).PG_FUNCTION;
     x_pg_parameters := G_OBJECT_PG_TBL(i).PG_PARAMS;

   END get_drilldown_page;

END jtf_objects_pub;

/
