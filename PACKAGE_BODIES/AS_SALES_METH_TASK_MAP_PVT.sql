--------------------------------------------------------
--  DDL for Package Body AS_SALES_METH_TASK_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_METH_TASK_MAP_PVT" AS
/* $Header: asxsmtkb.pls 120.2 2005/12/14 01:42:38 sumahali noship $ */
 --Procedure to Create a Sales Methodology
Procedure  CREATE_SALES_METH_TASK_MAP
  (
 P_API_VERSION             	IN  NUMBER,
    P_INIT_MSG_LIST           	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_COMMIT                  	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_VALIDATE_LEVEL          	IN  VARCHAR2    DEFAULT fnd_api.g_valid_level_full,
    P_SALES_STAGE_ID  	    	IN  NUMBER,
    P_SALES_METHODOLOGY_ID    	IN  NUMBER ,
    P_SOURCE_OBJECT_ID        	IN  NUMBER ,
    P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2 ,
    P_SOURCE_OBJECT_NAME       IN  VARCHAR2 ,
    P_TASK_ID              	IN  NUMBER ,
    P_TASK_TEMPLATE_ID          IN  NUMBER ,
    P_TASK_TEMPLATE_GROUP_ID	IN  NUMBER,
    X_RETURN_STATUS            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_MSG_COUNT                OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_MSG_DATA                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )     IS
      l_api_name                 VARCHAR2(30) := 'CREATE_SALES_METH_TASK_MAP';
      l_task_id			 NUMBER		:= p_task_id;
      l_sales_methodology_id 	 NUMBER		:= p_sales_methodology_id;
      l_sales_stage_id		 NUMBER		:= p_sales_stage_id;
      l_source_object_id	 NUMBER		:= p_source_object_id;
      l_task_template_group_id	 NUMBER		:= p_task_template_group_id;
      l_task_template_id	 NUMBER		:= p_task_template_id;
      l_source_object_type_code  VARCHAR2(30)	:= p_source_object_type_code;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SAVEPOINT create_sales_meth_task_pvt;
      -- call table handler to insert into as_sales_methodology_b
         INSERT INTO AS_SALES_METH_TASK_MAP (	sales_stage_id,
         				     	sales_methodology_id,
         				     	object_id,
						object_type_code,
						task_id,
         				     	task_template_id,
         				     	task_template_group_id,
         				     	created_by,
         				     	creation_date,
         				     	last_updated_by,
         				     	last_update_date,
         				     	last_update_login) VALUES
         				     	(	l_sales_stage_id,
         				     		l_sales_methodology_id,
         				     		l_source_object_id,
							l_source_object_type_code,
							l_task_id,
         				     		l_task_template_id,
         				     		l_task_template_group_id,
							fnd_global.user_id,
         				     		SYSDATE,
         				     		fnd_global.user_id,
							SYSDATE,
         				     		fnd_global.login_id);
         		IF (fnd_api.to_boolean (p_commit))	THEN
			         COMMIT WORK;
      			END IF;
      			EXCEPTION
			      WHEN fnd_api.g_exc_error
			      THEN
			         ROLLBACK TO create_sales_meth_task_pvt;
			         x_return_status := fnd_api.g_ret_sts_error;
			         fnd_msg_pub.count_and_get (	p_count 	=> x_msg_count,
			            				p_data 		=> x_msg_data );
			      WHEN fnd_api.g_exc_unexpected_error
			      THEN
			         ROLLBACK TO create_sales_meth_task_pvt;
			         x_return_status := fnd_api.g_ret_sts_unexp_error;
			         fnd_msg_pub.count_and_get (	p_count 	=> x_msg_count,
			            				p_data 		=> x_msg_data	);
			      WHEN OTHERS
			      THEN
			         ROLLBACK TO create_sales_meth_task_pvt;
			         x_return_status := fnd_api.g_ret_sts_unexp_error;
			         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
			         THEN
			            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
			         END IF;
			         fnd_msg_pub.count_and_get (	p_count 	=> x_msg_count,
			            				p_data 		=> x_msg_data   );
   END CREATE_SALES_METH_TASK_MAP;
-------------------------------------------
-------------------------------------------
   Procedure  UPDATE_SALES_METH_TASK_MAP
     (
      P_API_VERSION             	IN  NUMBER,
    P_INIT_MSG_LIST           	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_COMMIT                  	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_VALIDATE_LEVEL          	IN  VARCHAR2    DEFAULT fnd_api.g_valid_level_full,
    P_SALES_STAGE_ID  	    	IN  NUMBER,
    P_SALES_METHODOLOGY_ID    	IN  NUMBER ,
    P_SOURCE_OBJECT_ID        	IN  NUMBER ,
    P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2 ,
    P_SOURCE_OBJECT_NAME       IN  VARCHAR2 ,
    P_TASK_ID              	IN  NUMBER ,
    P_TASK_TEMPLATE_ID          IN  NUMBER ,
    P_TASK_TEMPLATE_GROUP_ID	IN  NUMBER,
    X_RETURN_STATUS            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_MSG_COUNT                OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_MSG_DATA                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )     IS
         l_api_name                 	 VARCHAR2(30) := 'UPDATE_SALES_METH_TASK_MAP';
         l_task_id			 NUMBER		:= p_task_id;
         l_sales_methodology_id 	 NUMBER		:= p_sales_methodology_id;
         l_sales_stage_id		 NUMBER		:= p_sales_stage_id;
         l_source_object_id	 	 NUMBER		:= p_source_object_id;
         l_task_template_group_id	 NUMBER		:= p_task_template_group_id;
         l_task_template_id	 	 NUMBER		:= p_task_template_id;
 BEGIN
          x_return_status := fnd_api.g_ret_sts_success;
	       SAVEPOINT  update_sales_meth_task_pvt;
	       -- call table handler to insert into as_sales_methodology_b
	          UPDATE  AS_SALES_METH_TASK_MAP SET
	          				     	sales_methodology_id 	= 	l_sales_methodology_id,
	          				     	task_template_id	= 	l_task_template_id,
	          				     	last_updated_by		=	fnd_global.user_id,
	          				     	last_update_date	=	SYSDATE	,
	          				     	last_update_login	=	fnd_global.login_id
	          					WHERE 	object_id = l_source_object_id
	          					AND	sales_stage_id	= l_sales_stage_id
	          					AND	task_template_group_id = l_task_template_group_id ;
	        IF (SQL%NOTFOUND) THEN
		      RAISE no_data_found;
  		END IF;
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
   END UPDATE_SALES_METH_TASK_MAP;
-----------------------------------------------
-----------------------------------------------
    Procedure  DELETE_SALES_METH_TASK_MAP
        (	P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
  P_SOURCE_OBJECT_ID        	IN  NUMBER ,
  P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2 ,
     P_SOURCE_OBJECT_NAME       IN  VARCHAR2 ,
   P_SALES_STAGE_ID  	    	IN  NUMBER,
P_TASK_TEMPLATE_ID	IN  NUMBER,
P_TASK_TEMPLATE_GROUP_ID	IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY /* file.sql.39 change */ NUMBER,
 X_MSG_DATA                OUT NOCOPY /* file.sql.39 change */ VARCHAR2  )         IS
     		l_api_name                 	 VARCHAR2(30) := 'UPDATE_SALES_METH_TASK_MAP';
	   	--l_task_id			 NUMBER		:= p_task_id;
	        l_sales_methodology_id 	 	 NUMBER		:= p_sales_methodology_id;
	        l_sales_stage_id		 NUMBER		:= p_sales_stage_id;
	        l_source_object_id	 	 NUMBER		:= p_source_object_id;
	        l_task_template_group_id	 NUMBER		:= p_task_template_group_id;
         	l_task_template_id	 	 NUMBER		:= p_task_template_id;
         BEGIN
          	x_return_status := fnd_api.g_ret_sts_success;
	       SAVEPOINT  update_sales_meth_task_pvt;
          	DELETE  FROM AS_SALES_METH_TASK_MAP
		WHERE 	object_id = l_source_object_id
		AND	sales_stage_id	= l_sales_stage_id
	        AND	task_template_group_id = l_task_template_group_id ;
	        IF (SQL%NOTFOUND) THEN
			    RAISE no_data_found;
      		END IF;
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
   END DELETE_SALES_METH_TASK_MAP;
	end AS_SALES_METH_TASK_MAP_PVT;


/
