--------------------------------------------------------
--  DDL for Package Body GME_PROCESS_PARAMETERS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_PROCESS_PARAMETERS_DBL" AS
/* $Header: GMEVGPPB.pls 120.3 2006/03/17 11:13:28 pxkumar noship $ */
   g_table_name     VARCHAR2 (80) DEFAULT 'GME_PROCESS_PARAMETERS';
   g_package_name   VARCHAR2 (32) DEFAULT 'GME_PROCESS_PARAMETERS_DBL';

   FUNCTION insert_row (
      p_process_parameters   IN              gme_process_parameters%ROWTYPE
     ,x_process_parameters   IN OUT NOCOPY   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      x_process_parameters := p_process_parameters;

      INSERT INTO gme_process_parameters
                  (process_param_id
                  ,batch_id
                  ,batchstep_id
                  ,batchstep_activity_id
                  ,batchstep_resource_id
                  ,resources
                  ,parameter_id
                  ,target_value
                  ,actual_value
                  ,minimum_value
                  ,maximum_value
                  ,parameter_uom
                  ,device_id
                  ,attribute_category
                  ,attribute1
                  ,attribute2
                  ,attribute3
                  ,attribute4
                  ,attribute5
                  ,attribute6
                  ,attribute7
                  ,attribute8
                  ,attribute9
                  ,attribute10
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,attribute16
                  ,attribute17
                  ,attribute18
                  ,attribute19
                  ,attribute20
                  ,attribute21
                  ,attribute22
                  ,attribute23
                  ,attribute24
                  ,attribute25
                  ,attribute26
                  ,attribute27
                  ,attribute28
                  ,attribute29
                  ,attribute30
                  ,creation_date, created_by
                  ,last_update_date, last_updated_by
                  ,last_update_login)
           VALUES (gme_process_parameters_id_s.NEXTVAL
                  ,x_process_parameters.batch_id
                  ,x_process_parameters.batchstep_id
                  ,x_process_parameters.batchstep_activity_id
                  ,x_process_parameters.batchstep_resource_id
                  ,x_process_parameters.resources
                  ,x_process_parameters.parameter_id
                  ,x_process_parameters.target_value
                  ,x_process_parameters.actual_value
                  ,x_process_parameters.minimum_value
                  ,x_process_parameters.maximum_value
                  ,x_process_parameters.parameter_uom
                  ,x_process_parameters.device_id
                  ,x_process_parameters.attribute_category
                  ,x_process_parameters.attribute1
                  ,x_process_parameters.attribute2
                  ,x_process_parameters.attribute3
                  ,x_process_parameters.attribute4
                  ,x_process_parameters.attribute5
                  ,x_process_parameters.attribute6
                  ,x_process_parameters.attribute7
                  ,x_process_parameters.attribute8
                  ,x_process_parameters.attribute9
                  ,x_process_parameters.attribute10
                  ,x_process_parameters.attribute11
                  ,x_process_parameters.attribute12
                  ,x_process_parameters.attribute13
                  ,x_process_parameters.attribute14
                  ,x_process_parameters.attribute15
                  ,x_process_parameters.attribute16
                  ,x_process_parameters.attribute17
                  ,x_process_parameters.attribute18
                  ,x_process_parameters.attribute19
                  ,x_process_parameters.attribute20
                  ,x_process_parameters.attribute21
                  ,x_process_parameters.attribute22
                  ,x_process_parameters.attribute23
                  ,x_process_parameters.attribute24
                  ,x_process_parameters.attribute25
                  ,x_process_parameters.attribute26
                  ,x_process_parameters.attribute27
                  ,x_process_parameters.attribute28
                  ,x_process_parameters.attribute29
                  ,x_process_parameters.attribute30
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_login_id)
        RETURNING process_param_id
             INTO x_process_parameters.process_param_id;

      IF SQL%FOUND THEN
         x_process_parameters.created_by := gme_common_pvt.g_user_ident;
         x_process_parameters.creation_date := gme_common_pvt.g_timestamp;
         x_process_parameters.last_updated_by := gme_common_pvt.g_user_ident;
         x_process_parameters.last_update_date := gme_common_pvt.g_timestamp;
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_package_name, 'insert_row');
         RETURN FALSE;
   END insert_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      fetch_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Fetch_Row will fetch a row in gme_process_parameters
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_process_parameters
 |
 |
 |
 |   PARAMETERS
 |     p_process_parameters IN  gme_process_parameters%ROWTYPE
 |     x_process_parameters OUT gme_process_parameters%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   23-AUG-02 Pawan Kumar Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_process_parameters   IN              gme_process_parameters%ROWTYPE
     ,x_process_parameters   IN OUT NOCOPY   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_process_parameters.process_param_id IS NOT NULL THEN
         SELECT process_param_id
               ,batch_id
               ,batchstep_id
               ,batchstep_activity_id
               ,batchstep_resource_id
               ,resources
               ,parameter_id
               ,target_value
               ,actual_value
               ,minimum_value
               ,maximum_value
               ,parameter_uom
               ,device_id
               ,attribute_category
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,attribute16
               ,attribute17
               ,attribute18
               ,attribute19
               ,attribute20
               ,attribute21
               ,attribute22
               ,attribute23
               ,attribute24
               ,attribute25
               ,attribute26
               ,attribute27
               ,attribute28
               ,attribute29
               ,attribute30
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login
           INTO x_process_parameters.process_param_id
               ,x_process_parameters.batch_id
               ,x_process_parameters.batchstep_id
               ,x_process_parameters.batchstep_activity_id
               ,x_process_parameters.batchstep_resource_id
               ,x_process_parameters.resources
               ,x_process_parameters.parameter_id
               ,x_process_parameters.target_value
               ,x_process_parameters.actual_value
               ,x_process_parameters.minimum_value
               ,x_process_parameters.maximum_value
               ,x_process_parameters.parameter_uom
               ,x_process_parameters.device_id
               ,x_process_parameters.attribute_category
               ,x_process_parameters.attribute1
               ,x_process_parameters.attribute2
               ,x_process_parameters.attribute3
               ,x_process_parameters.attribute4
               ,x_process_parameters.attribute5
               ,x_process_parameters.attribute6
               ,x_process_parameters.attribute7
               ,x_process_parameters.attribute8
               ,x_process_parameters.attribute9
               ,x_process_parameters.attribute10
               ,x_process_parameters.attribute11
               ,x_process_parameters.attribute12
               ,x_process_parameters.attribute13
               ,x_process_parameters.attribute14
               ,x_process_parameters.attribute15
               ,x_process_parameters.attribute16
               ,x_process_parameters.attribute17
               ,x_process_parameters.attribute18
               ,x_process_parameters.attribute19
               ,x_process_parameters.attribute20
               ,x_process_parameters.attribute21
               ,x_process_parameters.attribute22
               ,x_process_parameters.attribute23
               ,x_process_parameters.attribute24
               ,x_process_parameters.attribute25
               ,x_process_parameters.attribute26
               ,x_process_parameters.attribute27
               ,x_process_parameters.attribute28
               ,x_process_parameters.attribute29
               ,x_process_parameters.attribute30
               ,x_process_parameters.created_by
               ,x_process_parameters.creation_date
               ,x_process_parameters.last_updated_by
               ,x_process_parameters.last_update_date
               ,x_process_parameters.last_update_login
           FROM gme_process_parameters
          WHERE process_param_id = p_process_parameters.process_param_id;
      ELSIF     p_process_parameters.batchstep_resource_id IS NOT NULL
            AND p_process_parameters.parameter_id IS NOT NULL THEN
         SELECT process_param_id
               ,batch_id
               ,batchstep_id
               ,batchstep_activity_id
               ,batchstep_resource_id
               ,resources
               ,parameter_id
               ,target_value
               ,actual_value
               ,minimum_value
               ,maximum_value
               ,parameter_uom
               ,device_id
               ,attribute_category
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,attribute16
               ,attribute17
               ,attribute18
               ,attribute19
               ,attribute20
               ,attribute21
               ,attribute22
               ,attribute23
               ,attribute24
               ,attribute25
               ,attribute26
               ,attribute27
               ,attribute28
               ,attribute29
               ,attribute30
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login
           INTO x_process_parameters.process_param_id
               ,x_process_parameters.batch_id
               ,x_process_parameters.batchstep_id
               ,x_process_parameters.batchstep_activity_id
               ,x_process_parameters.batchstep_resource_id
               ,x_process_parameters.resources
               ,x_process_parameters.parameter_id
               ,x_process_parameters.target_value
               ,x_process_parameters.actual_value
               ,x_process_parameters.minimum_value
               ,x_process_parameters.maximum_value
               ,x_process_parameters.parameter_uom
               ,x_process_parameters.device_id
               ,x_process_parameters.attribute_category
               ,x_process_parameters.attribute1
               ,x_process_parameters.attribute2
               ,x_process_parameters.attribute3
               ,x_process_parameters.attribute4
               ,x_process_parameters.attribute5
               ,x_process_parameters.attribute6
               ,x_process_parameters.attribute7
               ,x_process_parameters.attribute8
               ,x_process_parameters.attribute9
               ,x_process_parameters.attribute10
               ,x_process_parameters.attribute11
               ,x_process_parameters.attribute12
               ,x_process_parameters.attribute13
               ,x_process_parameters.attribute14
               ,x_process_parameters.attribute15
               ,x_process_parameters.attribute16
               ,x_process_parameters.attribute17
               ,x_process_parameters.attribute18
               ,x_process_parameters.attribute19
               ,x_process_parameters.attribute20
               ,x_process_parameters.attribute21
               ,x_process_parameters.attribute22
               ,x_process_parameters.attribute23
               ,x_process_parameters.attribute24
               ,x_process_parameters.attribute25
               ,x_process_parameters.attribute26
               ,x_process_parameters.attribute27
               ,x_process_parameters.attribute28
               ,x_process_parameters.attribute29
               ,x_process_parameters.attribute30
               ,x_process_parameters.created_by
               ,x_process_parameters.creation_date
               ,x_process_parameters.last_updated_by
               ,x_process_parameters.last_update_date
               ,x_process_parameters.last_update_login
           FROM gme_process_parameters
          WHERE batchstep_resource_id =
                                    p_process_parameters.batchstep_resource_id
            AND parameter_id = p_process_parameters.parameter_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_package_name, 'fetch_row');
         RETURN FALSE;
   END fetch_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_Row will delete a row in gme_process_parameters
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_process_parameters
 |
 |
 |
 |   PARAMETERS
 |     p_process_parameters IN  gme_process_parameters%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   23-AUG-02 Pawan Kumar Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (
      p_process_parameters   IN   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_process_parameters.process_param_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_process_parameters
              WHERE process_param_id = p_process_parameters.process_param_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_process_parameters
               WHERE process_param_id = p_process_parameters.process_param_id;
      ELSIF     p_process_parameters.batchstep_resource_id IS NOT NULL
            AND p_process_parameters.parameter_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_process_parameters
              WHERE batchstep_resource_id =
                                    p_process_parameters.batchstep_resource_id
                AND parameter_id = p_process_parameters.parameter_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_process_parameters
               WHERE batchstep_resource_id =
                                    p_process_parameters.batchstep_resource_id
                 AND parameter_id = p_process_parameters.parameter_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'PROCESS PARAMETERS'
                                    ,'KEY'
                                    ,p_process_parameters.process_param_id);
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_package_name, 'delete_row');
         RETURN FALSE;
   END delete_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      update_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Update_Row will update a row in gme_process_parameters
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_process_parameters
 |
 |
 |
 |   PARAMETERS
 |     p_process_parameters IN  gme_process_parameters%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   23-AUG-02 Pawan Kumar Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (
      p_process_parameters   IN   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_process_parameters.process_param_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_process_parameters
              WHERE process_param_id = p_process_parameters.process_param_id
         FOR UPDATE NOWAIT;

         UPDATE gme_process_parameters
            SET batch_id = p_process_parameters.batch_id
               ,batchstep_id = p_process_parameters.batchstep_id
               ,batchstep_activity_id =
                                    p_process_parameters.batchstep_activity_id
               ,batchstep_resource_id =
                                    p_process_parameters.batchstep_resource_id
               ,resources = p_process_parameters.resources
               ,parameter_id = p_process_parameters.parameter_id
               ,target_value = p_process_parameters.target_value
               ,actual_value = p_process_parameters.actual_value
               ,minimum_value = p_process_parameters.minimum_value
               ,maximum_value = p_process_parameters.maximum_value
               ,parameter_uom = p_process_parameters.parameter_uom
               ,device_id = p_process_parameters.device_id
               ,attribute_category = p_process_parameters.attribute_category
               ,attribute1 = p_process_parameters.attribute1
               ,attribute2 = p_process_parameters.attribute2
               ,attribute3 = p_process_parameters.attribute3
               ,attribute4 = p_process_parameters.attribute4
               ,attribute5 = p_process_parameters.attribute5
               ,attribute6 = p_process_parameters.attribute6
               ,attribute7 = p_process_parameters.attribute7
               ,attribute8 = p_process_parameters.attribute8
               ,attribute9 = p_process_parameters.attribute9
               ,attribute10 = p_process_parameters.attribute10
               ,attribute11 = p_process_parameters.attribute11
               ,attribute12 = p_process_parameters.attribute12
               ,attribute13 = p_process_parameters.attribute13
               ,attribute14 = p_process_parameters.attribute14
               ,attribute15 = p_process_parameters.attribute15
               ,attribute16 = p_process_parameters.attribute16
               ,attribute17 = p_process_parameters.attribute17
               ,attribute18 = p_process_parameters.attribute18
               ,attribute19 = p_process_parameters.attribute19
               ,attribute20 = p_process_parameters.attribute20
               ,attribute21 = p_process_parameters.attribute21
               ,attribute22 = p_process_parameters.attribute22
               ,attribute23 = p_process_parameters.attribute23
               ,attribute24 = p_process_parameters.attribute24
               ,attribute25 = p_process_parameters.attribute25
               ,attribute26 = p_process_parameters.attribute26
               ,attribute27 = p_process_parameters.attribute27
               ,attribute28 = p_process_parameters.attribute28
               ,attribute29 = p_process_parameters.attribute29
               ,attribute30 = p_process_parameters.attribute30
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
          WHERE process_param_id = p_process_parameters.process_param_id
            AND last_update_date = p_process_parameters.last_update_date;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         IF l_dummy = 0 THEN
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
      WHEN NO_DATA_FOUND THEN
         IF l_dummy = 0 THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'PROCESS PARAMETERS'
                                    ,'KEY'
                                    ,p_process_parameters.process_param_id);
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_package_name, 'update_row');
         RETURN FALSE;
   END update_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      lock_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Lock_Row will lock a row in gme_process_parameters
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_process_parameters
 |
 |
 |
 |   PARAMETERS
 |     p_process_parameters IN  gme_process_parameters%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   23-AUG-02 Pawan Kumar Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION lock_row (p_process_parameters IN gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy   NUMBER;
   BEGIN
      IF p_process_parameters.process_param_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_process_parameters
              WHERE process_param_id = p_process_parameters.process_param_id
         FOR UPDATE NOWAIT;
      /*ELSE p_process_parameters.batchstep_resource_id IS NOT NULL
        AND   p_process_parameters.parameter_id IS NOT NULL
        THEN
          SELECT 1 INTO l_dummy FROM gme_process_parameters
          WHERE  batchstep_resource_id = p_process_parameters.batchstep_resource_id
          AND   parameter_id = p_process_parameters.parameter_id
          FOR UPDATE NOWAIT;   */
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'PROCESS PARAMETERS'
                                    ,'KEY'
                                    ,p_process_parameters.process_param_id);
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_package_name, 'lock_row');
         RETURN FALSE;
   END lock_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_all
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_all will delete all process parameters for a resource
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_process_parameters
 |
 |
 |
 |   PARAMETERS
 |     p_process_parameters IN  gme_process_parameters%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   23-AUG-02 Pawan Kumar Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_all (
      p_process_parameters   IN   gme_process_parameters%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_process_param_ids    gme_common_pvt.number_tab;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_process_parameters.batchstep_resource_id IS NOT NULL THEN
         SELECT     process_param_id
         BULK COLLECT INTO l_process_param_ids
               FROM gme_process_parameters
              WHERE process_param_id = p_process_parameters.process_param_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_process_parameters
               WHERE batchstep_resource_id =
                                    p_process_parameters.batchstep_resource_id;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN TRUE;
      END IF;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'PROCESS PARAMETERS'
                                    ,'KEY'
                                    ,p_process_parameters.process_param_id);
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_package_name, 'delete_all');
         RETURN FALSE;
   END delete_all;
END gme_process_parameters_dbl;

/
