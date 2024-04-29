--------------------------------------------------------
--  DDL for Package Body GMA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_MIGRATION" AS
/*$Header: GMAMIGB.pls 120.8 2006/11/21 19:46:20 txdaniel noship $*/
   FUNCTION gma_migration_start
   (  p_app_short_name IN VARCHAR2,
      p_mig_name IN VARCHAR2
   )
   RETURN NUMBER IS
   pragma AUTONOMOUS_TRANSACTION;

      v_mig_date DATE:= SYSDATE;
      l_pos   NUMBER := 0;
      v_run_id NUMBER;
      v_message_token  VARCHAR2(80) := 'GMA_MIGRATION_DB_ERROR';
      raise_gma_insert_message EXCEPTION;
   BEGIN

      IF p_mig_name IS NULL OR p_app_short_name IS NULL THEN
         v_message_token := 'GMA_MIGRATION_FAILED';
         RAISE raise_gma_insert_message;
      ELSE
         l_pos := 1;
         SELECT gma_mig_run_id_s.nextval INTO v_run_id
         FROM dual;
      END IF;

      IF v_run_id IS NULL THEN
         v_message_token := 'GMA_MIGRATION_FAILED';
         RAISE raise_gma_insert_message;
      ELSE
         l_pos := 2;
         INSERT INTO gma_migration_control
                  (application_short_name,
                   run_id,
                   mig_name,
                   mig_start_date
                  )
         VALUES   (p_app_short_name,
                   v_run_id,
                   p_mig_name,
                   v_mig_date
                  );

         l_pos := 3;
      END IF;
      COMMIT;

      RETURN v_run_id;

   EXCEPTION
      WHEN raise_gma_insert_message THEN
         gma_insert_message(
            p_run_id => v_run_id,
            p_table_name => 'gma_migration_log',
            p_DB_ERROR => SQLERRM,
            p_param1 => NULL,
            p_param2 => NULL,
            p_param3 => NULL,
            p_param4 => NULL,
            p_param5 => NULL,
            p_message_token => v_message_token,
            p_message_type => 'D',
           p_line_no => NULL,
           p_position => l_pos,
           p_base_message => ''
         );
        RAISE;
      WHEN OTHERS THEN
         gma_insert_message(
            p_run_id => v_run_id,
            p_table_name => 'gma_migration_log',
            p_DB_ERROR => SQLERRM,
            p_param1 => 'an error occurred while updating gma_migration_log',
            p_param2 => NULL,
            p_param3 => NULL,
            p_param4 => NULL,
            p_param5 => NULL,
            p_message_token => v_message_token,
            p_message_type => 'D',
           p_line_no => NULL,
           p_position => l_pos,
           p_base_message => ''
         );
        RAISE;
        COMMIT;
   END gma_migration_start;

   PROCEDURE gma_insert_message(
      p_run_id           IN   NUMBER,
      p_table_name       IN   VARCHAR2,
      p_DB_ERROR         IN   VARCHAR2,
      p_param1           IN   VARCHAR2,
      p_param2           IN   VARCHAR2,
      p_param3           IN   VARCHAR2,
      p_param4           IN   VARCHAR2,
      p_param5           IN   VARCHAR2,
      p_message_token    IN   VARCHAR2,
      p_message_type     IN   VARCHAR2,
      p_line_no          IN   NUMBER,
      p_position         IN   NUMBER,
      p_base_message     IN   VARCHAR2
      ) IS
   BEGIN
     GMA_COMMON_LOGGING.Gma_Migration_CentraL_Log(
                       P_Run_Id         => p_run_id,
                       P_log_level      => 5,
                       P_App_short_name => 'GMA',
                       P_Message_Token  => p_message_token,
                       P_context	=> NULL,
                       P_Table_Name     => p_table_name,
                       P_Param1         => p_param1,
                       P_Param2         => p_param2,
                       P_Param3         => p_param3,
                       P_Param4         => p_param4,
                       P_Param5         => p_param5,
                       P_Db_Error       => p_db_error);

   END gma_insert_message;

   PROCEDURE gma_migration_end(l_run_id IN NUMBER)
   IS
   pragma AUTONOMOUS_TRANSACTION;

      v_mig_end_date DATE:= SYSDATE;
      l_pos   NUMBER := 0;
      p_mig_name VARCHAR2(80) := NULL;
      v_message_token VARCHAR2(80) := 'GMA_MIGRATION_DB_ERROR';
      raise_gma_insert_message EXCEPTION;
   BEGIN

      IF l_run_id IS NULL THEN
         v_message_token := 'GMA_MIGRATION_FAIL';
         RAISE raise_gma_insert_message;

      ELSE
         p_mig_name := get_mig_name(l_run_id);
         l_pos := 1;

         IF p_mig_name IS NULL THEN
            p_mig_name := '';
            v_message_token := 'GMA_MIGRATION_FAIL';
            RAISE raise_gma_insert_message;
         END IF;

         UPDATE gma_migration_control
         SET mig_end_date = v_mig_end_date
         WHERE run_id = l_run_id;
      END IF;
      l_pos := 2;
      COMMIT;

   EXCEPTION
      WHEN raise_gma_insert_message THEN
         gma_insert_message(
            p_run_id => l_run_id,
            p_table_name => 'gma_migration_log',
            p_DB_ERROR => SQLERRM,
            p_param1 => 'an error occurred while updating gma_migration_log',
            p_param2 => NULL,
            p_param3 => NULL,
            p_param4 => NULL,
            p_param5 => NULL,
            p_message_token => v_message_token,
            p_message_type => 'D',
           p_line_no => NULL,
           p_position => l_pos,
           p_base_message => ''
         );
        RAISE;
      WHEN OTHERS THEN
         gma_insert_message(
            p_run_id => l_run_id,
            p_table_name => 'gma_migration_log',
            p_DB_ERROR => SQLERRM,
            p_param1 => NULL,
            p_param2 => NULL,
            p_param3 => NULL,
            p_param4 => NULL,
            p_param5 => NULL,
            p_message_token => v_message_token,
            p_message_type => 'D',
           p_line_no => NULL,
           p_position => l_pos,
           p_base_message => ''
         );
        RAISE;
        COMMIT;
   END gma_migration_end;

   FUNCTION get_mig_run_id(p_mig_name IN VARCHAR2) RETURN NUMBER IS
      v_run_id NUMBER;

      CURSOR c_get_mig_run_id IS
         SELECT run_id from gma_migration_control WHERE mig_name = p_mig_name
         AND mig_end_date is NULL
         ORDER BY run_id desc;

   BEGIN
      OPEN c_get_mig_run_id;
      FETCH c_get_mig_run_id into v_run_id;
      CLOSE c_get_mig_run_id;

      RETURN v_run_id;

   EXCEPTION
     WHEN OTHERS THEN
     RAISE;

   END get_mig_run_id;

   FUNCTION get_mig_name(p_run_id IN NUMBER) RETURN VARCHAR2 IS
      v_mig_name gma_migration_control.mig_name%TYPE;

   CURSOR c_get_mig_name IS
      SELECT mig_name from gma_migration_control WHERE run_id = p_run_id
      ORDER BY run_id desc;

   BEGIN
      OPEN c_get_mig_name;
      FETCH c_get_mig_name into v_mig_name;
      CLOSE c_get_mig_name;

      RETURN v_mig_name;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETURN NULL;
     WHEN OTHERS THEN
            gma_insert_message(
               p_run_id => p_run_id,
               p_table_name => 'gma_migration_log',
               p_DB_ERROR => SQLERRM,
               p_param1 => NULL,
               p_param2 => NULL,
               p_param3 => NULL,
               p_param4 => NULL,
               p_param5 => NULL,
               p_message_token => 'GMA_MIGRATION_DB_ERROR',
               p_message_type => 'D',
               p_line_no => NULL,
               p_position => NULL,
               p_base_message => ''
            );
     RAISE;

   END get_mig_name;

   FUNCTION get_gma_mig_messages (p_name IN VARCHAR2, p_rowid IN ROWID)
      RETURN VARCHAR2 IS

      v_err_message VARCHAR2(4000) ;
      v_table_name  VARCHAR2(4000) ;
      v_db_error    VARCHAR2(4000) ;
      v_param1      VARCHAR2(4000) ;
      v_param2      VARCHAR2(4000) ;
      v_param3      VARCHAR2(4000) ;
      v_param4      VARCHAR2(4000) ;
      v_param5      VARCHAR2(4000) ;


      CURSOR c1
      IS
         SELECT *
         FROM   gma_migration_log
         WHERE  message_token = p_name AND
                        rowid = p_rowid;
      l_rec c1%rowtype;
      MISSING_DATA EXCEPTION;
   BEGIN
      OPEN  c1;
      FETCH c1 INTO l_rec;
      IF c1%NOTFOUND THEN
        CLOSE c1;
        RAISE MISSING_DATA;
      END IF;
      CLOSE c1;

      IF p_name = 'GMD_UNEXPECTED_ERROR' THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', l_rec.db_error);
      ELSE
        FND_MESSAGE.set_name(NVL(l_rec.msg_app_short_name, 'GMA'), p_name);

        IF (l_rec.param1 IS not NULL)  THEN
          FND_MESSAGE.set_token(NVL(l_rec.token1, 'PARAM1'),l_rec.param1);
        ELSIF (p_name IN ('GMA_MIGRATION_TABLE_SUCCESS', 'GMA_MIGRATION_TABLE_SUCCESS_RW')) THEN
          FND_MESSAGE.set_token('TABLE_NAME', l_rec.table_name);
        END IF;

        IF (l_rec.param2 IS not NULL)  THEN
          FND_MESSAGE.set_token(NVL(l_rec.token2, 'PARAM2'),l_rec.param2);
        END IF;

        IF (l_rec.param3 IS not NULL)  THEN
          FND_MESSAGE.set_token(NVL(l_rec.token3, 'PARAM3'),l_rec.param3);
        END IF;

        IF (l_rec.param4 IS not NULL)  THEN
          FND_MESSAGE.set_token(NVL(l_rec.token4, 'PARAM4'),l_rec.param4);
        END IF;

        IF (l_rec.param5 IS not NULL)  THEN
          FND_MESSAGE.set_token(NVL(l_rec.token5, 'PARAM5'),l_rec.param5);
        END IF;

        IF (l_rec.param6 IS not NULL)  THEN
          FND_MESSAGE.set_token(NVL(l_rec.token6, 'PARAM6'),l_rec.param6);
        END IF;
      END IF;

      RETURN FND_MESSAGE.GET;

   EXCEPTION
     WHEN MISSING_DATA THEN
       RETURN (p_name);
     WHEN OTHERS THEN
       RETURN(p_name);
   END get_gma_mig_messages;

   PROCEDURE run IS
      l_pos   NUMBER := 0;
      v_run_id NUMBER;
      new_run_id NUMBER;
      v_mig_name gma_migration_control.mig_name%TYPE;
      v_mig_name2 VARCHAR2(80) := NULL;

   BEGIN
      l_pos := 1;
      v_mig_name := 'gma_mig_test';
      v_run_id := gma_migration_start(p_app_short_name => 'GMA', p_mig_name => v_mig_name);

      l_pos := 2;

      new_run_id := get_mig_run_id(p_mig_name => v_mig_name);

      v_mig_name2 := get_mig_name(v_run_id);

      l_pos := 3;

      gma_migration_end(l_run_id => v_run_id);

      l_pos := 4;

   EXCEPTION
      WHEN OTHERS THEN
         gma_insert_message(
            p_run_id => v_run_id,
            p_table_name => 'gma_migration_log',
            p_DB_ERROR => SQLERRM,
            p_param1 => NULL,
            p_param2 => NULL,
            p_param3 => NULL,
            p_param4 => NULL,
            p_param5 => NULL,
            p_message_token => 'GMA_MIGRATION_DB_ERROR',
            p_message_type => 'D',
            p_line_no => NULL,
            p_position => l_pos,
            p_base_message => ''
         );
        RAISE;
     COMMIT;
   END;


END;

/
