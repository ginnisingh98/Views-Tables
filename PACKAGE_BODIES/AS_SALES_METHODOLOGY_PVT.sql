--------------------------------------------------------
--  DDL for Package Body AS_SALES_METHODOLOGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_METHODOLOGY_PVT" AS
/* $Header: asxvsmob.pls 120.0 2005/06/02 17:22:56 appldev noship $ */
 --Procedure to Create a Sales Methodology

Procedure  CREATE_SALES_METHODOLOGY
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_SALES_METHODOLOGY_NAME  IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE DEFAULT NULL,
  P_AUTOCREATETASK_FLAG     IN  VARCHAR2 DEFAULT NULL,
  P_DESCRIPTION             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2 DEFAULT NULL,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_SALES_METHODOLOGY_ID    OUT NOCOPY NUMBER)
     IS
      l_api_name                 VARCHAR2(30) := 'CREATE_SALES_METHODOLOGY';
      v_rowid                    VARCHAR2(24);
      v_sales_methodology_id     as_sales_methodology_b.sales_methodology_id%TYPE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT create_sales_methodology_pvt;
      SELECT as_sales_methodology_s.nextval
        INTO v_sales_methodology_id
        FROM dual;
      -- call table handler to insert into as_sales_methodology_b
      as_sales_methodology_pkg.insert_row (
         v_rowid,
         v_sales_methodology_id,
         p_sales_methodology_name,
         p_start_date_active,
         p_end_date_active,
         p_autocreatetask_flag,
         p_description,
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
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id
      );

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;

      x_sales_methodology_id := v_sales_methodology_id;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO create_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END create_sales_methodology;


--Procedure to Upate Sales Methodology

Procedure  UPDATE_SALES_METHODOLOGY
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_SALES_METHODOLOGY_ID    IN  NUMBER,
  P_SALES_METHODOLOGY_NAME  IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE DEFAULT NULL,
  P_AUTOCREATETASK_FLAG     IN  VARCHAR2 DEFAULT NULL,
  P_DESCRIPTION             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2 DEFAULT NULL,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER
  )
   IS
      l_api_name   VARCHAR2(30) := 'UPDATE_SALES_METHODOLOGY';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT update_sales_methodology_pvt;
      -- call locking table handler
      as_sales_methodology_pkg.lock_row (
         p_sales_methodology_id,
         x_object_version_number
      );
      -- call table handler to update into as_sales_methodology
      as_sales_methodology_pkg.update_row (
         p_sales_methodology_id,
         x_object_version_number,
         p_sales_methodology_name,
         p_start_date_active,
         p_end_date_active,
         p_autocreatetask_flag,
         p_description,
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
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id
      );
      x_object_version_number := x_object_version_number + 1;

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO update_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END update_sales_methodology;


--Procedure to Delete Sales Methodology

Procedure  DELETE_SALES_METHODOLOGY
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2,
 X_OBJECT_VERSION_NUMBER   IN  NUMBER
 )
   IS
      l_api_name   VARCHAR2(30) := 'DELETE_SALES_METHODOLOGY';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT delete_sales_methodology_pvt;

      -- Delete the sales stage mapping for the sales methdology first
      DELETE FROM AS_SALES_METH_STAGE_MAP
      WHERE SALES_METHODOLOGY_ID = P_SALES_METHODOLOGY_ID;

      -- call table handler to insert into jtf_tasks_temp_groups
      as_sales_methodology_pkg.delete_row (p_sales_methodology_id);

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_sales_methodology_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END delete_sales_methodology;

   --Procedure to Add a Sales Stage - Template Group Map
Procedure ADD_SALES_METH_STAGE_MAP
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
 P_SALES_STAGE_ID		      IN  NUMBER,
 P_TASK_TEMPLATE_GROUP_ID  IN  NUMBER      default fnd_api.g_miss_num,
 P_MAX_WIN_PROBABILITY     IN  NUMBER,
 P_MIN_WIN_PROBABILITY     IN  NUMBER,
 P_SALES_SUPPLEMENT_TEMPLATE IN NUMBER,
 P_STAGE_SEQUENCE          IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2
 )
   IS
      CURSOR C IS SELECT ROWID FROM AS_SALES_METH_STAGE_MAP
      WHERE SALES_METHODOLOGY_ID = P_SALES_METHODOLOGY_ID
	        AND SALES_STAGE_ID = P_SALES_STAGE_ID;

      l_api_name   VARCHAR2(30) := 'ADD_SALES_STAGE_MAP';
	  l_rowid      VARCHAR2(30) := NULL;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT add_sales_stage_map_pvt;

      -- Try updating the AS_SALES_METH_MAP table.
      UPDATE as_sales_meth_stage_map SET
		task_template_group_id = p_task_template_group_id,
		max_win_probability = p_max_win_probability,
		min_win_probability = p_min_win_probability,
        template_id = p_sales_supplement_template,
		stage_sequence = p_stage_sequence,
        last_update_date = SYSDATE,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
	  WHERE
	    sales_methodology_id = p_sales_methodology_id
		AND
		sales_stage_id = p_sales_stage_id;

	  -- if the row was not found for update, insert it.
	  IF (SQL%NOTFOUND) THEN
        INSERT INTO as_sales_meth_stage_map (
		  sales_methodology_id,
		  sales_stage_id,
		  task_template_group_id,
		  max_win_probability,
		  min_win_probability,
          template_id,
		  stage_sequence,
		  created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login
		)
		VALUES (
		  p_sales_methodology_id,
		  p_sales_stage_id,
		  p_task_template_group_id,
		  p_max_win_probability,
		  p_min_win_probability,
          p_sales_supplement_template,
		  p_stage_sequence,
		  fnd_global.user_id,
		  SYSDATE,
		  fnd_global.user_id,
		  SYSDATE,
		  fnd_global.login_id
		);

		IF (SQL%NOTFOUND) THEN
		RAISE no_data_found;
		END IF;

      END IF;

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO add_sales_stage_map_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO add_sales_stage_map_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO add_sales_stage_map_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END add_sales_meth_stage_map;

--Procedure to Delete a Sales Stage - Template Group Map
Procedure DELETE_SALES_METH_STAGE_MAP
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
 P_SALES_STAGE_ID		   IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2
 )
   IS
      l_api_name   VARCHAR2(30) := 'DELETE_SALES_METH_STAGE_MAP';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT delete_sm_stage_map_pvt;

      -- Try updating the AS_SALES_METH_MAP table.
      DELETE FROM as_sales_meth_stage_map
	  WHERE
	    sales_methodology_id = p_sales_methodology_id
		AND
		sales_stage_id = p_sales_stage_id;

	  -- if the row was not found for delete, raise an exception.
	  IF (SQL%NOTFOUND) THEN
	    RAISE no_data_found;
      END IF;

      -- standard check of p_commit
      IF (fnd_api.to_boolean (p_commit))
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_sm_stage_map_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_sm_stage_map_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_sm_stage_map_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END delete_sales_meth_stage_map;

END AS_SALES_METHODOLOGY_PVT;

/
