--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_VALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_VALUES_PUB" AS
  /* $Header: jtfrspcb.pls 120.0 2005/05/11 08:21:05 appldev ship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource salesrep territories, like
   create, update and delete resource salesrep territories from other modules.
   Its main procedures are as following:
   Create Resource Values
   Update Resource Values
   Delete Resource Values
   Delete All Resource Values
   Get Resource Values
   Get Resource Param List
   Calls to these procedures will invoke procedures from jtf_rs_resource_values_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

   --Package variables
      G_PKG_NAME         VARCHAR2(30) := 'JTF_RESOURCE_PARAMS_PUB';

   --Procedure to Create Resource Values based on the input values provided by the calling routines

   PROCEDURE CREATE_RS_RESOURCE_VALUES(
      P_Api_Version	         	IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
      P_resource_id                	IN   NUMBER,
      p_resource_param_id	   	IN   NUMBER,
      p_value                      	IN   VARCHAR2,
      P_value_type                 	IN   VARCHAR2	DEFAULT NULL,
      X_Return_Status              	OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY  NUMBER,
      X_Msg_Data                   	OUT NOCOPY  VARCHAR2,
      X_resource_param_value_id    	OUT NOCOPY  NUMBER
   )IS
     	l_api_version			CONSTANT NUMBER := 1.0;
	l_api_name            		CONSTANT VARCHAR2(30) := 'CREATE_RS_RESOURCE_VALUE';
      	l_resource_id             	NUMBER			:= p_resource_id;
      	l_resource_param_id           	NUMBER			:= p_resource_param_id;
      	l_value                       	VARCHAR2(255)		:= p_value;
      	l_value_type               	VARCHAR2(30)		:= p_value_type;
      	l_resource_param_value_id     	NUMBER;

      	l_resource_id_out             	NUMBER;

   BEGIN

    SAVEPOINT create_rs_resource_values_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Create Resources Values Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Put in all the Validations here

   --Validate the Resource Id
      jtf_resource_utl.validate_resource_number(
         p_resource_id 		=> l_resource_id,
         p_resource_number	=> null,
         x_return_status 	=> x_return_status,
         x_resource_id		=> l_resource_id_out
      );
-- added for NOCOPY
      l_resource_id := l_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Resource Id Validation

   --Validate the Resource Param Id
      jtf_resource_utl.validate_resource_param_id(
         p_resource_param_id 	=> l_resource_param_id,
         x_return_status 	=> x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Resource Param Id Validation

   --Call the Private API for create_rs_resource_values
      jtf_rs_resource_values_pvt.create_rs_resource_values(
         P_API_VERSION       		=> 1,
         P_INIT_MSG_LIST   		=> fnd_api.g_false,
         P_COMMIT          		=> fnd_api.g_false,
         P_resource_id			=> l_resource_id,
         p_resource_param_id        	=> l_resource_param_id,
         p_value                    	=> l_value,
         P_value_type               	=> l_value_type,
         X_RETURN_STATUS            	=> x_return_status,
         X_MSG_COUNT                	=> x_msg_count,
         X_MSG_DATA                 	=> x_msg_data,
         X_resource_param_value_id	=> l_resource_param_value_id
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to private procedure');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      x_resource_param_value_id := l_resource_param_value_id;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO create_rs_resource_values_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Values Pub ==============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO create_rs_resource_values_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END create_rs_resource_values;

   --Procedure to Update Resource Values based on the input values passed by the calling routines

   PROCEDURE UPDATE_RS_RESOURCE_VALUES(
      P_Api_Version	         	IN   	NUMBER,
      P_Init_Msg_List              	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id		IN   	NUMBER,
      p_resource_id			IN   	NUMBER,
      p_resource_param_id       	IN   	NUMBER,
      p_value      			IN   	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
      p_value_type          		IN   	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
      p_object_version_number		IN OUT NOCOPY JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status              	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY 	NUMBER,
      X_Msg_Data                   	OUT NOCOPY 	VARCHAR2
  )IS

        l_api_version            	CONSTANT NUMBER 	:= 1.0;
        l_api_name                      CONSTANT VARCHAR2(30) 	:= 'UPDATE_RS_RESOURCE_VALUES';
        l_resource_id                   NUMBER			:= p_resource_id;
        l_resource_param_id             NUMBER			:= p_resource_param_id;
        l_value                         VARCHAR2(255)		:= p_value;
        l_value_type                    VARCHAR2(30)		:= p_value_type;
        l_object_version_number         NUMBER			:= p_object_version_number;
        l_resource_param_value_id       NUMBER			:= p_resource_param_value_id;
        l_resource_id_out               NUMBER;

BEGIN

    SAVEPOINT update_rs_resource_values_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Update Resources Values Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

   --Put all Validations here

   --Validate the Resource Id
      jtf_resource_utl.validate_resource_number(
         p_resource_id 		=> l_resource_id,
         p_resource_number	=> null,
         x_return_status 	=> x_return_status,
         x_resource_id		=> l_resource_id_out
      );

     l_resource_id := l_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Resource Id Validation

   --Validate the Resource Param Id
      jtf_resource_utl.validate_resource_param_id(
         p_resource_param_id 	=> l_resource_param_id,
         x_return_status 	=> x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Resource Param Id Validation

   --Validate the Value Type
   IF l_value_type <> FND_API.G_MISS_CHAR THEN
      IF l_value_type IS NOT NULL THEN
         jtf_resource_utl.validate_rs_value_type(
	    p_resource_param_id	=> l_resource_param_id,
            p_value_type 	=> l_value_type,
            x_return_status 	=> x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;
   --End of Value Type Validation

   --Get Resource Param Value Id from the database
      SELECT resource_param_value_id
      INTO l_resource_param_value_id
      FROM jtf_rs_resource_values
      WHERE resource_id = l_resource_id
         AND resource_param_id = l_resource_param_id
         AND value_type = l_value_type;

   --Call the private procedure for update
      jtf_rs_resource_values_pvt.update_rs_resource_values(
         P_API_VERSION              => 1,
         P_INIT_MSG_LIST            => fnd_api.g_false,
         P_COMMIT                   => fnd_api.g_false,
     	 p_resource_param_value_id  => l_resource_param_value_id,
     	 p_value                    => l_value,
     	 p_object_version_number    => l_object_version_number,
     	 X_RETURN_STATUS            => x_return_status,
     	 X_MSG_COUNT                => x_msg_count,
     	 X_MSG_DATA                 => x_msg_data
      );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to private procedure');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO update_rs_resource_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Values Pub ============= ');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO update_rs_resource_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END update_rs_resource_values;

  /* Procedure to Delete Resource Values based on the
     input values provided by the calling routines */

  PROCEDURE DELETE_RS_RESOURCE_VALUES(
      P_Api_Version			IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id		IN   NUMBER,
      p_object_version_number   	IN   JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status              	OUT NOCOPY VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY NUMBER,
      X_Msg_Data                   	OUT NOCOPY VARCHAR2
  )IS

        l_api_version            	CONSTANT NUMBER := 1.0;
        l_api_name                      CONSTANT VARCHAR2(30) 	:= 'DELETE_RS_RESOURCE_VALUES';
     	l_resource_param_value_id   	NUMBER			:= p_resource_param_value_id;
        l_object_version_number		NUMBER			:= p_object_version_number;
BEGIN

    SAVEPOINT delete_rs_resource_values_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Delete Resources Values Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

 --Put all Validations here

 --Call the private procedure for delete

   jtf_rs_resource_values_pvt.delete_rs_resource_values(
     P_API_VERSION              => 1,
     P_INIT_MSG_LIST            => fnd_api.g_false,
     P_COMMIT                   => fnd_api.g_false,
     P_RESOURCE_PARAM_VALUE_ID  => l_resource_param_value_id,
     P_OBJECT_VERSION_NUMBER	=> l_object_version_number,
     X_RETURN_STATUS            => x_return_status,
     X_MSG_COUNT                => x_msg_count,
     X_MSG_DATA                 => x_msg_data
   );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to private procedure');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO delete_rs_resource_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Resource Values Pub ============= ');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO delete_rs_resource_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END delete_rs_resource_values;

  /* Procedure to Delete all Resource Values based on the
     Resource Id provided by the calling routines */

  PROCEDURE DELETE_ALL_RS_RESOURCE_VALUES(
      P_Api_Version	  		IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     	:= FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     	:= FND_API.G_FALSE,
      p_resource_id                	IN   NUMBER,
      X_Return_Status              	OUT NOCOPY VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY NUMBER,
      X_Msg_Data                   	OUT NOCOPY VARCHAR2
  )IS

        l_api_version            	CONSTANT NUMBER 	:= 1.0;
        l_api_name                      CONSTANT VARCHAR2(30) 	:= 'DELETE_ALL_RS_RESOURCE_VALUES';
        l_resource_id			NUMBER			:= p_resource_id;
        l_object_version_number		NUMBER;

  BEGIN

    SAVEPOINT delete_all_rs_values_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Delete All Resources Values Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

 --Put all Validations here

 --Call the private procedure for delete

   jtf_rs_resource_values_pvt.delete_all_rs_resource_values(
     P_API_VERSION              => 1,
     P_INIT_MSG_LIST            => fnd_api.g_false,
     P_COMMIT                   => fnd_api.g_false,
     P_RESOURCE_ID  		=> l_resource_id,
     X_RETURN_STATUS            => x_return_status,
     X_MSG_COUNT                => x_msg_count,
     X_MSG_DATA                 => x_msg_data
   );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to private procedure');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO delete_all_rs_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete All Resource Values Pub =============');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO delete_all_rs_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END delete_all_rs_resource_values;

  /* Procedure to Get Resource Values based on the
     input values passed by the calling routines */

  PROCEDURE GET_RS_RESOURCE_VALUES(
      P_Api_Version	         	IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     	:= FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     	:= FND_API.G_FALSE,
      P_resource_id                	IN   NUMBER,
      P_value_type                	IN   VARCHAR2		DEFAULT FND_API.G_MISS_CHAR,
      p_resource_param_id               IN   NUMBER,
      x_resource_param_value_id         OUT NOCOPY NUMBER,
      x_value                   	OUT NOCOPY VARCHAR2,
      X_Return_Status              	OUT NOCOPY VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY NUMBER,
      X_Msg_Data                   	OUT NOCOPY VARCHAR2
  )IS

        l_api_version            	CONSTANT NUMBER 	:= 1.0;
        l_api_name                      CONSTANT VARCHAR2(30) 	:= 'GET_RS_RESOURCE_VALUES';
      	l_resource_id                	NUMBER			:= p_resource_id;
      	l_value_type                  	VARCHAR2(30)		:= p_value_type;
      	l_resource_param_id          	NUMBER			:= p_resource_param_id;
      	l_resource_param_value_id  	NUMBER;
      	l_value                    	VARCHAR2(255);

      	l_resource_id_out              	NUMBER;

BEGIN
    SAVEPOINT get_rs_resource_values_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Get Resources Values Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

 --Put all Validations here

   /* Validate the Resource Id. */
    jtf_resource_utl.validate_resource_number(
        p_resource_id     => l_resource_id,
        p_resource_number => null,
        x_return_status   => x_return_status,
        x_resource_id     => l_resource_id_out
    );
-- added for NOCOPY
    l_resource_id := l_resource_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    /* End of Resource Id  Validation */

    /* Validate the Resource Param Id. */
    jtf_resource_utl.validate_resource_param_id(
        p_resource_param_id => l_resource_param_id,
        x_return_status => x_return_status
    );
    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    /* End of Resource Param Id  Validation */

 --Call the private procedure for get

    jtf_rs_resource_values_pvt.get_rs_resource_values
    (P_API_VERSION              => 1,
     P_INIT_MSG_LIST            => fnd_api.g_false,
     P_COMMIT                   => fnd_api.g_false,
     P_resource_id              => l_resource_id,
     P_value_type               => l_value_type,
     p_resource_param_id        => l_resource_param_id,
     x_resource_param_value_id  => x_resource_param_value_id,
     x_value                    => x_value,
     X_RETURN_STATUS            => x_return_status,
     X_MSG_COUNT                => x_msg_count,
     X_MSG_DATA                 => x_msg_data
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to private procedure');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO get_rs_resource_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Get Resource Values Pub =============');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO get_rs_resource_values_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END get_rs_resource_values;

   --Procedure to Get Resource Param List for the given Application Id and Param Type

  PROCEDURE GET_RS_RESOURCE_PARAM_LIST(
      P_Api_Version              	IN   NUMBER,
      P_Init_Msg_List                   IN   VARCHAR2     	:= FND_API.G_FALSE,
      P_Commit                          IN   VARCHAR2     	:= FND_API.G_FALSE,
      P_APPLICATION_ID                  IN   NUMBER,
      X_Return_Status                   OUT NOCOPY VARCHAR2,
      X_Msg_Count                       OUT NOCOPY NUMBER,
      X_Msg_Data                        OUT NOCOPY VARCHAR2,
      X_RS_PARAM_Table                  OUT NOCOPY RS_PARAM_LIST_TBL_TYPE,
      X_No_Record                       OUT NOCOPY Number
  ) IS

	l_api_version			CONSTANT NUMBER 	:= 1.0;
        l_api_name                      CONSTANT VARCHAR2(30) 	:= 'GET_RS_RESOURCE_PARAM_LIST';
        l_APPLICATION_ID             	NUMBER			:= p_application_id;

BEGIN
    SAVEPOINT get_rs_param_list_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Get Resources Param List Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

 --Put all Validations here

 --Call the private procedure for get

    jtf_rs_resource_values_pvt.get_rs_resource_param_list
    (P_API_VERSION              => 1,
     P_INIT_MSG_LIST            => fnd_api.g_false,
     P_COMMIT                   => fnd_api.g_false,
     P_APPLICATION_ID       	=> l_application_id,
     X_RETURN_STATUS            => x_return_status,
     X_MSG_COUNT                => x_msg_count,
     X_MSG_DATA                 => x_msg_data,
     X_RS_PARAM_TABLE		=> x_rs_param_table,
     X_NO_RECORD		=> x_no_record
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to private procedure');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO get_rs_param_list_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Get Resource Param List Pub =============');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO get_rs_param_list_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END get_rs_resource_param_list;

 End JTF_RS_RESOURCE_VALUES_PUB;

/
