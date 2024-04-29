--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEP_CHARGE_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEP_CHARGE_DBL" AS
/* $Header: GMEVGSCB.pls 120.1 2005/06/03 13:46:38 appldev  $ */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_BATCH_STEP_CHARGES';
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'gme_batch_step_charges_dbl';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    insert_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   insert_Row will insert a row in  gme_batch_step_charges                |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step_charges_in IN gme_batch_step_charges%ROWTYPE             |
 |    x_batch_step_charges IN OUT NOCOPY gme_batch_step_charges%ROWTYPE     |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |    04-05-2004 Rishi Varma bug 3307549                  |
 |         Created                                  |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION insert_row (
      p_batch_step_charges_in   IN              gme_batch_step_charges%ROWTYPE
     ,x_batch_step_charges      IN OUT NOCOPY   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'INSERT_ROW';
   BEGIN
      x_batch_step_charges := p_batch_step_charges_in;

      INSERT INTO gme_batch_step_charges
                  (batch_id
                  ,batchstep_id
                  ,resources
                  ,charge_number
                  ,charge_quantity
                  ,activity_sequence_number
                  ,plan_start_date
                  ,plan_cmplt_date
                  ,last_update_date, creation_date
                  ,created_by, last_updated_by
                  ,last_update_login)
           VALUES (x_batch_step_charges.batch_id
                  ,x_batch_step_charges.batchstep_id
                  ,x_batch_step_charges.resources
                  ,x_batch_step_charges.charge_number
                  ,x_batch_step_charges.charge_quantity
                  ,x_batch_step_charges.activity_sequence_number
                  ,x_batch_step_charges.plan_start_date
                  ,x_batch_step_charges.plan_cmplt_date
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_login_id);

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END insert_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    fetch_row                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   fetch_Row will fetch a row in  gme_batch_step_charges                  |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   fetch_row will fetch a row in  gme_batch_step_charges                  |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step_charges_in IN gme_batch_step_charges%ROWTYPE             |
 |    x_batch_steps IN OUT NOCOPY gme_batch_step_charges%ROWTYPE            |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     04-05-2004  Rishi Varma   Bug 3307549                 |
 |        Created                                            |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_step_charges_in   IN              gme_batch_step_charges%ROWTYPE
     ,x_batch_step_charges      IN OUT NOCOPY   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'FETCH_ROW';
   BEGIN
      IF p_batch_step_charges_in.batchstep_id IS NOT NULL THEN
         SELECT batch_id
               ,batchstep_id
               ,resources
               ,activity_sequence_number
               ,charge_number
               ,charge_quantity
               ,plan_start_date
               ,plan_cmplt_date
               ,last_update_date
               ,creation_date
               ,created_by
               ,last_updated_by
               ,last_update_login
           INTO x_batch_step_charges.batch_id
               ,x_batch_step_charges.batchstep_id
               ,x_batch_step_charges.resources
               ,x_batch_step_charges.activity_sequence_number
               ,x_batch_step_charges.charge_number
               ,x_batch_step_charges.charge_quantity
               ,x_batch_step_charges.plan_start_date
               ,x_batch_step_charges.plan_cmplt_date
               ,x_batch_step_charges.last_update_date
               ,x_batch_step_charges.creation_date
               ,x_batch_step_charges.created_by
               ,x_batch_step_charges.last_updated_by
               ,x_batch_step_charges.last_update_login
           FROM gme_batch_step_charges
          WHERE batchstep_id = p_batch_step_charges_in.batchstep_id;
      ELSIF     p_batch_step_charges_in.batch_id IS NOT NULL
            AND p_batch_step_charges_in.batchstep_id IS NOT NULL THEN
         SELECT batch_id
               ,batchstep_id
               ,resources
               ,activity_sequence_number
               ,charge_number
               ,charge_quantity
               ,plan_start_date
               ,plan_cmplt_date
               ,last_update_date
               ,creation_date
               ,created_by
               ,last_updated_by
               ,last_update_login
           INTO x_batch_step_charges.batch_id
               ,x_batch_step_charges.batchstep_id
               ,x_batch_step_charges.resources
               ,x_batch_step_charges.activity_sequence_number
               ,x_batch_step_charges.charge_number
               ,x_batch_step_charges.charge_quantity
               ,x_batch_step_charges.plan_start_date
               ,x_batch_step_charges.plan_cmplt_date
               ,x_batch_step_charges.last_update_date
               ,x_batch_step_charges.creation_date
               ,x_batch_step_charges.created_by
               ,x_batch_step_charges.last_updated_by
               ,x_batch_step_charges.last_update_login
           FROM gme_batch_step_charges
          WHERE batch_id = p_batch_step_charges_in.batch_id
            AND batchstep_id = p_batch_step_charges_in.batchstep_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END fetch_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    update_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   update_Row will update a row in  gme_batch_step_charges                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   update_row will update a row in  gme_batch_step_charges                |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step_charges_in IN gme_batch_step_charges%ROWTYPE             |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     04-NAY-2004  Rishi Varma Bug 3307549                  |
 |         Created                             |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION update_row (
      p_batch_step_charges_in   IN   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN
   IS
      CURSOR cur_both_ids (v_batch_id NUMBER, v_batchstep_id NUMBER)
      IS
         SELECT     1
               FROM gme_batch_step_charges
              WHERE batch_id = v_batch_id AND batchstep_id = v_batchstep_id
         FOR UPDATE NOWAIT;

      CURSOR cur_step_id (v_batchstep_id NUMBER)
      IS
         SELECT     1
               FROM gme_batch_step_charges
              WHERE batchstep_id = v_batchstep_id
         FOR UPDATE NOWAIT;

      l_both_ids_rec         NUMBER        := 0;
      l_step_id_rec          NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'UPDATE_ROW';
   BEGIN
      IF p_batch_step_charges_in.batchstep_id IS NOT NULL THEN
         OPEN cur_step_id (p_batch_step_charges_in.batchstep_id);

         LOOP
            FETCH cur_step_id
             INTO l_step_id_rec;

            IF cur_step_id%NOTFOUND THEN
               CLOSE cur_step_id;

               EXIT;
            END IF;
         END LOOP;

         UPDATE gme_batch_step_charges
            SET batch_id = p_batch_step_charges_in.batch_id
               ,batchstep_id = p_batch_step_charges_in.batchstep_id
               ,resources = p_batch_step_charges_in.resources
               ,activity_sequence_number =
                              p_batch_step_charges_in.activity_sequence_number
               ,charge_number = p_batch_step_charges_in.charge_number
               ,charge_quantity = p_batch_step_charges_in.charge_quantity
               ,plan_start_date = p_batch_step_charges_in.plan_start_date
               ,plan_cmplt_date = p_batch_step_charges_in.plan_cmplt_date
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batchstep_id = p_batch_step_charges_in.batchstep_id
            AND last_update_date = p_batch_step_charges_in.last_update_date;
      ELSIF     p_batch_step_charges_in.batch_id IS NOT NULL
            AND p_batch_step_charges_in.batchstep_id IS NOT NULL THEN
         OPEN cur_both_ids (p_batch_step_charges_in.batch_id
                           ,p_batch_step_charges_in.batchstep_id);

         LOOP
            FETCH cur_both_ids
             INTO l_both_ids_rec;

            IF cur_both_ids%NOTFOUND THEN
               CLOSE cur_both_ids;

               EXIT;
            END IF;
         END LOOP;

         UPDATE gme_batch_step_charges
            SET batch_id = p_batch_step_charges_in.batch_id
               ,batchstep_id = p_batch_step_charges_in.batchstep_id
               ,resources = p_batch_step_charges_in.resources
               ,activity_sequence_number =
                              p_batch_step_charges_in.activity_sequence_number
               ,charge_number = p_batch_step_charges_in.charge_number
               ,charge_quantity = p_batch_step_charges_in.charge_quantity
               ,plan_start_date = p_batch_step_charges_in.plan_start_date
               ,plan_cmplt_date = p_batch_step_charges_in.plan_cmplt_date
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE batchstep_id = p_batch_step_charges_in.batchstep_id
            AND batch_id = p_batch_step_charges_in.batch_id
            AND last_update_date = p_batch_step_charges_in.last_update_date;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RAISE NO_DATA_FOUND;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (l_both_ids_rec = 0 AND l_step_id_rec = 0) THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message
                              ('GME_RECORD_LOCKED'
                              ,'TABLE_NAME'
                              ,g_table_name
                              ,'RECORD'
                              ,'Batchstep id'
                              ,'KEY'
                              ,TO_CHAR (p_batch_step_charges_in.batchstep_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END update_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    delete_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   delete_Row will delete a row in  gme_batch_step_charges                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   delete_row will delete a row in  gme_batch_step_charges                |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step_charges_in IN gme_batch_step_charges%ROWTYPE             |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     04-NAY-2004  Rishi Varma Bug 3307549                  |
 |         Created                             |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION delete_row (
      p_batch_step_charges_in   IN   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN
   IS
      CURSOR cur_both_ids (v_batch_id NUMBER, v_batchstep_id NUMBER)
      IS
         SELECT     1
               FROM gme_batch_step_charges
              WHERE batch_id = v_batch_id AND batchstep_id = v_batchstep_id
         FOR UPDATE NOWAIT;

      CURSOR cur_step_id (v_batchstep_id NUMBER)
      IS
         SELECT     1
               FROM gme_batch_step_charges
              WHERE batchstep_id = v_batchstep_id
         FOR UPDATE NOWAIT;

      CURSOR cur_batch_id (v_batch_id NUMBER)
      IS
         SELECT     1
               FROM gme_batch_step_charges
              WHERE batch_id = v_batch_id
         FOR UPDATE NOWAIT;

      l_both_ids_rec         NUMBER        := 0;
      l_step_id_rec          NUMBER        := 0;
      l_batch_id_rec         NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'DELETE_ROW';
   BEGIN
      IF NVL (g_debug, -1) = gme_debug.g_log_statement THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'dbl,batch,step ids are '
                             || p_batch_step_charges_in.batch_id
                             || p_batch_step_charges_in.batchstep_id);
      END IF;

      IF p_batch_step_charges_in.batchstep_id IS NOT NULL THEN
         IF NVL (g_debug, -1) = gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'dbl,batchstep id is '
                                || p_batch_step_charges_in.batchstep_id);
         END IF;

         OPEN cur_step_id (p_batch_step_charges_in.batchstep_id);

         LOOP
            FETCH cur_step_id
             INTO l_step_id_rec;

            IF cur_step_id%NOTFOUND THEN
               CLOSE cur_step_id;

               EXIT;
            END IF;
         END LOOP;

         DELETE FROM gme_batch_step_charges
               WHERE batchstep_id = p_batch_step_charges_in.batchstep_id;
      ELSIF     p_batch_step_charges_in.batch_id IS NOT NULL
            AND p_batch_step_charges_in.batchstep_id IS NOT NULL THEN
         IF NVL (g_debug, -1) = gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'in delete dbl,batch,step id is'
                                || p_batch_step_charges_in.batch_id
                               ,p_batch_step_charges_in.batchstep_id);
         END IF;

         OPEN cur_both_ids (p_batch_step_charges_in.batch_id
                           ,p_batch_step_charges_in.batchstep_id);

         LOOP
            FETCH cur_both_ids
             INTO l_both_ids_rec;

            IF cur_both_ids%NOTFOUND THEN
               CLOSE cur_both_ids;

               EXIT;
            END IF;
         END LOOP;

         DELETE FROM gme_batch_step_charges
               WHERE batch_id = p_batch_step_charges_in.batch_id
                 AND batchstep_id = p_batch_step_charges_in.batchstep_id;
      ELSIF     p_batch_step_charges_in.batch_id IS NOT NULL
            AND p_batch_step_charges_in.batchstep_id IS NULL THEN
         IF NVL (g_debug, -1) = gme_debug.g_log_statement THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || 'in delete dbl,batch_id is'
                                || p_batch_step_charges_in.batch_id);
         END IF;

         OPEN cur_batch_id (p_batch_step_charges_in.batch_id);

         LOOP
            FETCH cur_batch_id
             INTO l_batch_id_rec;

            IF cur_batch_id%NOTFOUND THEN
               CLOSE cur_batch_id;

               EXIT;
            END IF;
         END LOOP;

         DELETE FROM gme_batch_step_charges
               WHERE batch_id = p_batch_step_charges_in.batch_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         IF     (l_both_ids_rec = 0)
            AND (l_step_id_rec = 0)
            AND (l_batch_id_rec = 0) THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message
                              ('GME_RECORD_LOCKED'
                              ,'TABLE_NAME'
                              ,g_table_name
                              ,'RECORD'
                              ,'Batchstep'
                              ,'KEY'
                              ,TO_CHAR (p_batch_step_charges_in.batchstep_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END delete_row;
END;

/
