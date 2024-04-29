--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_VALUES_PVT" AS
   /* $Header: jtfrsvcb.pls 120.2 2005/08/29 20:08:22 baianand ship $ */

   /*****************************************************************************************
    This is a private API that caller will invoke.
    It provides procedures for managing resource values,
    like create, update delete and query resource values.
    Its main procedures are as following:
    Create Resource Values
    Update Resource Values
    Delete Resource Values
    Delete All Resource Values
    Get Resource Values
    Get Resource Param List
    Calls to these procedures will invoke table handlers
    to do actual inserts, updates, deletes and queries from the tables.
    ******************************************************************************************/

   /* Package variables. */
   G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_RESOURCE_VALUES_PVT';

   /* Procedure to Create Resource Values based on the
     input values provided by the calling routines */

   PROCEDURE CREATE_RS_RESOURCE_VALUES(
      P_Api_Version	      	IN   	NUMBER,
      P_Init_Msg_List          	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_resource_id           	IN   	NUMBER,
      p_resource_param_id	IN   	NUMBER,
      p_value                  	IN   	VARCHAR2,
      P_value_type            	IN	VARCHAR2,
      P_ATTRIBUTE1              IN      VARCHAR2,
      P_ATTRIBUTE2              IN      VARCHAR2,
      P_ATTRIBUTE3              IN      VARCHAR2,
      P_ATTRIBUTE4              IN      VARCHAR2,
      P_ATTRIBUTE5              IN      VARCHAR2,
      P_ATTRIBUTE6              IN      VARCHAR2,
      P_ATTRIBUTE7              IN      VARCHAR2,
      P_ATTRIBUTE8              IN      VARCHAR2,
      P_ATTRIBUTE9              IN      VARCHAR2,
      P_ATTRIBUTE10             IN      VARCHAR2,
      P_ATTRIBUTE11             IN      VARCHAR2,
      P_ATTRIBUTE12             IN      VARCHAR2,
      P_ATTRIBUTE13             IN      VARCHAR2,
      P_ATTRIBUTE14             IN      VARCHAR2,
      P_ATTRIBUTE15             IN      VARCHAR2,
      P_ATTRIBUTE_CATEGORY      IN      VARCHAR2,
      X_Return_Status         	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count             	OUT NOCOPY 	NUMBER,
      X_Msg_Data              	OUT NOCOPY 	VARCHAR2,
      X_resource_param_value_id	OUT NOCOPY 	NUMBER
   )IS
      l_rowid			ROWID;
      l_api_version		CONSTANT NUMBER 			:= 1.0;
      l_api_name            	CONSTANT VARCHAR2(30) 			:= 'CREATE_RS_RESOURCE_VALUES';
      l_resource_id		NUMBER					:= P_RESOURCE_ID;
      l_resource_param_id	NUMBER					:= P_RESOURCE_PARAM_ID;
      l_value			VARCHAR2(255) 				:= P_VALUE;
      l_value_type		VARCHAR2(30) 				:= P_VALUE_TYPE;
      L_ATTRIBUTE1		JTF_RS_RESOURCE_VALUES.ATTRIBUTE1%TYPE  := p_attribute1;
      L_ATTRIBUTE2              JTF_RS_RESOURCE_VALUES.ATTRIBUTE2%TYPE  := p_attribute2;
      L_ATTRIBUTE3              JTF_RS_RESOURCE_VALUES.ATTRIBUTE3%TYPE  := p_attribute3;
      L_ATTRIBUTE4              JTF_RS_RESOURCE_VALUES.ATTRIBUTE4%TYPE  := p_attribute4;
      L_ATTRIBUTE5              JTF_RS_RESOURCE_VALUES.ATTRIBUTE5%TYPE  := p_attribute5;
      L_ATTRIBUTE6             	JTF_RS_RESOURCE_VALUES.ATTRIBUTE6%TYPE  := p_attribute6;
      L_ATTRIBUTE7              JTF_RS_RESOURCE_VALUES.ATTRIBUTE7%TYPE  := p_attribute7;
      L_ATTRIBUTE8              JTF_RS_RESOURCE_VALUES.ATTRIBUTE8%TYPE  := p_attribute8;
      L_ATTRIBUTE9              JTF_RS_RESOURCE_VALUES.ATTRIBUTE9%TYPE  := p_attribute9;
      L_ATTRIBUTE10             JTF_RS_RESOURCE_VALUES.ATTRIBUTE10%TYPE := p_attribute10;
      L_ATTRIBUTE11             JTF_RS_RESOURCE_VALUES.ATTRIBUTE11%TYPE := p_attribute11;
      L_ATTRIBUTE12             JTF_RS_RESOURCE_VALUES.ATTRIBUTE12%TYPE := p_attribute12;
      L_ATTRIBUTE13             JTF_RS_RESOURCE_VALUES.ATTRIBUTE13%TYPE := p_attribute13;
      L_ATTRIBUTE14             JTF_RS_RESOURCE_VALUES.ATTRIBUTE14%TYPE := p_attribute14;
      L_ATTRIBUTE15             JTF_RS_RESOURCE_VALUES.ATTRIBUTE15%TYPE := p_attribute15;
      L_ATTRIBUTE_CATEGORY      JTF_RS_RESOURCE_VALUES.ATTRIBUTE_CATEGORY%TYPE  := p_attribute_category;

-- added to handle NOCOPY of JTF_RESOURCE_UTL package
      l_resource_id_out   	NUMBER;


      l_resource_param_value_id NUMBER;
      l_bind_data_id		NUMBER;
      l_check_char		VARCHAR2(1);

   CURSOR c_jtf_rs_resource_values( l_rowid   IN  ROWID ) IS
      SELECT 'Y'
      FROM jtf_rs_resource_values
      WHERE ROWID = l_rowid;

   CURSOR c_rs_values_dup IS
      SELECT 'Y'
      FROM jtf_rs_resource_values
      WHERE resource_param_id = l_resource_param_id
      AND resource_id = l_resource_id
      AND value_type = l_value_type;

   CURSOR c_get_type(c_resource_param_id number) IS
   select type
   from   jtf_rs_resource_params
   where  resource_param_id = c_resource_param_id;

   l_type    jtf_rs_resource_params.type%TYPE;
   l_value1  jtf_rs_resource_values.value%TYPE;

   BEGIN

     SAVEPOINT create_rs_resource_values_pvt;
     x_return_status := fnd_api.g_ret_sts_success;
     --DBMS_OUTPUT.put_line(' Started Create Resources Values Pvt ');

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Initializing the Internal User Hook Record parameter values

      jtf_rs_resource_values_pub.p_rs_value_user_hook.resource_id :=l_resource_id;
      jtf_rs_resource_values_pub.p_rs_value_user_hook.resource_param_id := l_resource_param_id;
      jtf_rs_resource_values_pub.p_rs_value_user_hook.value_type := l_value_type;
      jtf_rs_resource_values_pub.p_rs_value_user_hook.value := l_value;

    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'B',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.create_rs_resource_values_pre(
          P_RESOURCE_ID         => l_resource_id,
          P_RESOURCE_PARAM_ID	=> l_resource_param_id,
          P_VALUE              	=> l_value,
          P_VALUE_TYPE		=> l_value_type,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Pre Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'B',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.create_rs_resource_values_pre(
          P_RESOURCE_ID         => l_resource_id,
          P_RESOURCE_PARAM_ID   => l_resource_param_id,
          P_VALUE               => l_value,
          P_VALUE_TYPE          => l_value_type,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Pre Call to the Internal Type User Hook
       jtf_rs_resource_values_iuhk.create_rs_resource_values_pre(
          X_RETURN_STATUS       => x_return_status
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Put in all the Validations here

   --Validate the Resource Id
    jtf_resource_utl.validate_resource_number(
        p_resource_id      => l_resource_id,
        p_resource_number  => null,
        x_return_status    => x_return_status,
        x_resource_id      => l_resource_id_out
    );
-- added for NOCOPY
    l_resource_id  := l_resource_id_out ;

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

   --Validate Resource Value Type
   IF l_value_type IS NOT NULL THEN
      jtf_resource_utl.validate_rs_value_type(
         p_resource_param_id 	=> l_resource_param_id,
         p_value_type		=> l_value_type,
	 x_return_status 	=> x_return_status
      );
   END IF;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
   --End of Resource Value Type Validation

   --Validate Resource Value
      jtf_resource_utl.validate_resource_value(
         p_resource_param_id	=> l_resource_param_id,
         p_value            	=> l_value,
         x_return_status	=> x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Resource Value Validation

   --Validate for Duplicate Resource Param ID, Resource ID, Value Type Combination
      OPEN c_rs_values_dup;
      FETCH c_rs_values_dup INTO l_check_char;
      IF c_rs_values_dup%FOUND THEN
        fnd_message.set_name ('JTF', 'JTF_RS_MDW_DUP_VALUE');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
     CLOSE c_rs_values_dup;

     -- This is for bug fix # 3870910
     -- Password will be stored using fnd_vault API
     OPEN  c_get_type(l_resource_param_id);
     FETCH c_get_type INTO l_type;
     CLOSE c_get_type;

     IF l_type = 'PASSWORD' then
        l_value1 := NULL;
     ELSE
        l_value1 := p_value;
     END IF;

   --Get the next value of the Resource_Param_Value_Id from the sequence
      SELECT jtf_rs_resource_params_s.nextval
      INTO l_resource_param_value_id
      FROM dual;

    --Call the Table Handler to Insert Values
     jtf_rs_resource_values_pkg.insert_row(
 	X_ROWID				=> l_rowid,
 	X_RESOURCE_PARAM_VALUE_ID	=> l_resource_param_value_id,
 	X_RESOURCE_ID			=> l_resource_id,
 	X_RESOURCE_PARAM_ID		=> l_resource_param_id,
 	X_VALUE				=> l_value1,
 	X_VALUE_TYPE			=> l_value_type,
 	X_ATTRIBUTE2			=> l_attribute2,
 	X_ATTRIBUTE3			=> l_attribute3,
 	X_ATTRIBUTE4			=> l_attribute4,
 	X_ATTRIBUTE5			=> l_attribute5,
 	X_ATTRIBUTE6			=> l_attribute6,
 	X_ATTRIBUTE7			=> l_attribute7,
 	X_ATTRIBUTE8			=> l_attribute8,
 	X_ATTRIBUTE9			=> l_attribute9,
 	X_ATTRIBUTE10			=> l_attribute10,
 	X_ATTRIBUTE11			=> l_attribute11,
 	X_ATTRIBUTE12			=> l_attribute12,
 	X_ATTRIBUTE13			=> l_attribute13,
 	X_ATTRIBUTE14			=> l_attribute14,
 	X_ATTRIBUTE15			=> l_attribute15,
 	X_ATTRIBUTE_CATEGORY		=> l_attribute_category,
 	X_ATTRIBUTE1			=> l_attribute1,
 	X_CREATION_DATE			=> sysdate,
 	X_CREATED_BY			=> jtf_resource_utl.created_by,
 	X_LAST_UPDATE_DATE		=> sysdate,
 	X_LAST_UPDATED_BY		=> jtf_resource_utl.updated_by,
 	X_LAST_UPDATE_LOGIN		=> jtf_resource_utl.login_id
      );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to table handler');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    x_resource_param_value_id := l_resource_param_value_id;

     -- This is for bug fix # 3870910
     -- Password will be stored using fnd_vault API
    if (l_resource_param_value_id is NOT NULL and p_value is NOT NULL and l_type = 'PASSWORD') then
       fnd_vault.put(l_resource_param_value_id, 'JTF_RS_RESOURCE_VALUES', p_value);
    end if;

    --Make the post processing call to the user hooks

    --Post Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'A',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.create_rs_resource_values_post(
          P_RESOURCE_ID              => l_resource_id,
          P_RESOURCE_PARAM_ID        => l_resource_param_id,
          P_VALUE                    => l_value,
          P_VALUE_TYPE               => l_value_type,
          P_RESOURCE_PARAM_VALUE_ID  => l_resource_param_value_id,
          X_RETURN_STATUS            => x_return_status,
          X_MSG_COUNT                => x_msg_count,
          X_MSG_DATA                 => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Initializing the Internal User Hook Record parameter value

      jtf_rs_resource_values_pub.p_rs_value_user_hook.resource_param_value_id :=l_resource_param_value_id;

    --Post Call to the Vertical Type User Hook

        IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'A',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.create_rs_resource_values_post(
          P_RESOURCE_ID              => l_resource_id,
          P_RESOURCE_PARAM_ID        => l_resource_param_id,
          P_VALUE                    => l_value,
          P_VALUE_TYPE               => l_value_type,
          P_RESOURCE_PARAM_VALUE_ID  => l_resource_param_value_id,
          X_RETURN_STATUS            => x_return_status,
          X_MSG_COUNT                => x_msg_count,
          X_MSG_DATA                 => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Post Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.create_rs_resource_values_post(
          X_RETURN_STATUS            => x_return_status
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'CREATE_RS_RESOURCE_VALUES',
         'M',
         'M')
      THEN
         IF (jtf_rs_resource_values_cuhk.ok_to_generate_msg(
            p_resource_param_value_id  => l_resource_param_value_id,
            x_return_status            => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
            jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_param_value_id', l_resource_param_value_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code    => 'JTF',
               p_bus_obj_code => 'RS_RPV',
               p_action_code  => 'I',
               p_bind_data_id => l_bind_data_id,
               x_return_code  => x_return_status);
               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                  --dbms_output.put_line('Returned Error status from the Message Generation API');
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
         END IF;
      END IF;

    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO create_rs_resource_values_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Values Pvt==============');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO create_rs_resource_values_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END create_rs_resource_values;

   --Procedure to Update Resource Values based on the input values passed by the calling routines

   PROCEDURE UPDATE_RS_RESOURCE_VALUES(
      P_Api_Version	       	IN   	NUMBER,
      P_Init_Msg_List        	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit             	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id	IN   	NUMBER,
      p_value      		IN   	VARCHAR2,
      P_ATTRIBUTE1              IN      VARCHAR2,
      P_ATTRIBUTE2              IN      VARCHAR2,
      P_ATTRIBUTE3              IN      VARCHAR2,
      P_ATTRIBUTE4              IN      VARCHAR2,
      P_ATTRIBUTE5              IN      VARCHAR2,
      P_ATTRIBUTE6              IN      VARCHAR2,
      P_ATTRIBUTE7              IN      VARCHAR2,
      P_ATTRIBUTE8              IN      VARCHAR2,
      P_ATTRIBUTE9              IN      VARCHAR2,
      P_ATTRIBUTE10             IN      VARCHAR2,
      P_ATTRIBUTE11             IN      VARCHAR2,
      P_ATTRIBUTE12             IN      VARCHAR2,
      P_ATTRIBUTE13             IN      VARCHAR2,
      P_ATTRIBUTE14             IN      VARCHAR2,
      P_ATTRIBUTE15             IN      VARCHAR2,
      P_ATTRIBUTE_CATEGORY      IN      VARCHAR2,
      p_object_version_number	IN OUT NOCOPY  JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status        	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count             	OUT NOCOPY 	NUMBER,
      X_Msg_Data               	OUT NOCOPY 	VARCHAR2
   )IS
        l_api_version            	CONSTANT NUMBER 		:= 1.0;
        l_api_name                    	CONSTANT VARCHAR2(30) 		:= 'UPDATE_RS_RESOURCE_VALUES';
	L_RESOURCE_PARAM_VALUE_ID	NUMBER				:= p_resource_param_value_id;
	L_RESOURCE_PARAM_ID		NUMBER;
	L_RESOURCE_ID			NUMBER;
	L_VALUE_TYPE			VARCHAR2 (30);
        L_VALUE				VARCHAR2 (255)			:= p_value;
	L_OBJECT_VERSION_NUMBER		JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE := p_object_version_number;
        L_ATTRIBUTE1                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE1%TYPE	:= p_attribute1;
	L_ATTRIBUTE2			JTF_RS_RESOURCE_VALUES.ATTRIBUTE2%TYPE	:= p_attribute2;
	L_ATTRIBUTE3                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE3%TYPE	:= p_attribute3;
        L_ATTRIBUTE4                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE4%TYPE	:= p_attribute4;
        L_ATTRIBUTE5                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE5%TYPE	:= p_attribute5;
        L_ATTRIBUTE6                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE6%TYPE	:= p_attribute6;
        L_ATTRIBUTE7                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE7%TYPE	:= p_attribute7;
        L_ATTRIBUTE8                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE8%TYPE	:= p_attribute8;
        L_ATTRIBUTE9                    JTF_RS_RESOURCE_VALUES.ATTRIBUTE9%TYPE	:= p_attribute9;
        L_ATTRIBUTE10                   JTF_RS_RESOURCE_VALUES.ATTRIBUTE10%TYPE	:= p_attribute10;
        L_ATTRIBUTE11                   JTF_RS_RESOURCE_VALUES.ATTRIBUTE11%TYPE	:= p_attribute11;
        L_ATTRIBUTE12                   JTF_RS_RESOURCE_VALUES.ATTRIBUTE12%TYPE	:= p_attribute12;
        L_ATTRIBUTE13                   JTF_RS_RESOURCE_VALUES.ATTRIBUTE13%TYPE	:= p_attribute13;
        L_ATTRIBUTE14                   JTF_RS_RESOURCE_VALUES.ATTRIBUTE14%TYPE	:= p_attribute14;
        L_ATTRIBUTE15                   JTF_RS_RESOURCE_VALUES.ATTRIBUTE15%TYPE	:= p_attribute15;
        L_ATTRIBUTE_CATEGORY         	JTF_RS_RESOURCE_VALUES.ATTRIBUTE_CATEGORY%TYPE	:= p_attribute_category;
        L_BIND_DATA_ID			NUMBER;

	CURSOR c_resource_param_value_id( l_resource_param_value_id   IN  NUMBER ) IS
      	   SELECT resource_param_value_id
      	   FROM jtf_rs_resource_values
      	   WHERE resource_param_value_id = l_resource_param_value_id;

        CURSOR c_resource_param_value_update( l_resource_param_value_id IN NUMBER ) IS
           SELECT
              DECODE(p_value, fnd_api.g_miss_char, value, p_value) l_value,
              DECODE(p_attribute1,fnd_api.g_miss_char, attribute1, p_attribute1) l_attribute1,
              DECODE(p_attribute2,fnd_api.g_miss_char, attribute2, p_attribute2) l_attribute2,
              DECODE(p_attribute3,fnd_api.g_miss_char, attribute3, p_attribute3) l_attribute3,
              DECODE(p_attribute4,fnd_api.g_miss_char, attribute4, p_attribute4) l_attribute4,
              DECODE(p_attribute5,fnd_api.g_miss_char, attribute5, p_attribute5) l_attribute5,
              DECODE(p_attribute6,fnd_api.g_miss_char, attribute6, p_attribute6) l_attribute6,
              DECODE(p_attribute7,fnd_api.g_miss_char, attribute7, p_attribute7) l_attribute7,
              DECODE(p_attribute8,fnd_api.g_miss_char, attribute8, p_attribute8) l_attribute8,
              DECODE(p_attribute9,fnd_api.g_miss_char, attribute9, p_attribute9) l_attribute9,
              DECODE(p_attribute10,fnd_api.g_miss_char, attribute10, p_attribute10) l_attribute10,
              DECODE(p_attribute11,fnd_api.g_miss_char, attribute11, p_attribute11) l_attribute11,
              DECODE(p_attribute12,fnd_api.g_miss_char, attribute12, p_attribute12) l_attribute12,
              DECODE(p_attribute13,fnd_api.g_miss_char, attribute13, p_attribute13) l_attribute13,
              DECODE(p_attribute14,fnd_api.g_miss_char, attribute14, p_attribute14) l_attribute14,
              DECODE(p_attribute15,fnd_api.g_miss_char, attribute15, p_attribute15) l_attribute15,
              DECODE(p_attribute_category,fnd_api.g_miss_char, attribute1, p_attribute_category) l_attribute_category
           FROM jtf_rs_resource_values
           WHERE resource_param_value_id = l_resource_param_value_id;

      resource_param_value_rec      c_resource_param_value_update%ROWTYPE;

   CURSOR c_get_type(c_resource_param_id number) IS
   select type
   from   jtf_rs_resource_params
   where  resource_param_id = c_resource_param_id;

   l_type   jtf_rs_resource_params.type%TYPE;
   l_value1  jtf_rs_resource_values.value%TYPE;

   BEGIN

      SAVEPOINT update_rs_resource_values_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Update Resources Values Pvt ');

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Initializing the Internal User Hook Record parameter values

      jtf_rs_resource_values_pub.p_rs_value_user_hook.resource_param_value_id := l_resource_param_value_id;
      jtf_rs_resource_values_pub.p_rs_value_user_hook.value := l_value;


    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'B',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.update_rs_resource_values_pre(
          P_RESOURCE_PARAM_VALUE_ID	=> l_resource_param_value_id,
          P_VALUE               	=> l_value,
          X_RETURN_STATUS       	=> x_return_status,
          X_MSG_COUNT           	=> x_msg_count,
          X_MSG_DATA            	=> x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Pre Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'B',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.update_rs_resource_values_pre(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          P_VALUE                       => l_value,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Pre Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.update_rs_resource_values_pre(
          X_RETURN_STATUS               => x_return_status
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Put all Validations here

   --Validate Resource Param Value Id
      OPEN c_resource_param_value_id(l_resource_param_value_id);
      FETCH c_resource_param_value_id INTO l_resource_param_value_id;
      IF c_resource_param_value_id%NOTFOUND THEN
         --dbms_output.put_line('Resource Param Value Id not found');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_RS_PRM_VALUE_ID');
         fnd_message.set_token('P_RESOURCE_PARAM_VALUE_ID', l_resource_param_value_id);
         fnd_msg_pub.add;
      CLOSE c_resource_param_value_id;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Validate Resource Param Value for Update
      OPEN c_resource_param_value_update(l_resource_param_value_id);
      FETCH c_resource_param_value_update INTO resource_param_value_rec;
      IF c_resource_param_value_update%NOTFOUND THEN
         CLOSE c_resource_param_value_update;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_RS_PRM_VALUE_ID');
         fnd_message.set_token('P_RESOURCE_PARAM_VALUE_ID', l_resource_param_value_id);
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Get the Resource Param Id, Resource Id, Value Type from the database
      SELECT resource_param_id, resource_id, value_type
      INTO l_resource_param_id, l_resource_id, l_value_type
      FROM jtf_rs_resource_values
      WHERE resource_param_value_id = l_resource_param_value_id;

   --Validate Resource Value
      IF p_value <> FND_API.G_MISS_CHAR THEN
         jtf_resource_utl.validate_resource_value(
            p_resource_param_id	=> l_resource_param_id,
            p_value		=> resource_param_value_rec.l_value,
            x_return_status	=> x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   --End of Resource Value Validation

    --Lock the row in the table by calling the table handler
      jtf_rs_resource_values_pkg.lock_row(
         X_RESOURCE_PARAM_VALUE_ID   	=> l_resource_param_value_id,
         X_OBJECT_VERSION_NUMBER       	=> l_object_version_number
      );

   --Update the Object Version Number By Incrementing it
      l_object_version_number	:=	p_object_version_number +1;

     -- This is for bug fix # 3870910
     -- Password will be stored using fnd_vault API
     OPEN  c_get_type(l_resource_param_id);
     FETCH c_get_type INTO l_type;
     CLOSE c_get_type;

     IF l_type = 'PASSWORD' then
        l_value1 := NULL;
     ELSE
        l_value1 := resource_param_value_rec.l_value;
     END IF;

   --Call the Table Handler to Update Values
      jtf_rs_resource_values_pkg.update_row(
         X_RESOURCE_PARAM_VALUE_ID	=> l_resource_param_value_id,
	 X_RESOURCE_ID       		=> l_resource_id,
	 X_RESOURCE_PARAM_ID       	=> l_resource_param_id,
         X_VALUE                        => l_value1,
	 X_VALUE_TYPE			=> l_value_type,
	 X_OBJECT_VERSION_NUMBER 	=> l_object_version_number,
         X_ATTRIBUTE2                   => resource_param_value_rec.l_attribute2,
         X_ATTRIBUTE3                   => resource_param_value_rec.l_attribute3,
         X_ATTRIBUTE4                   => resource_param_value_rec.l_attribute4,
         X_ATTRIBUTE5                   => resource_param_value_rec.l_attribute5,
         X_ATTRIBUTE6                   => resource_param_value_rec.l_attribute6,
         X_ATTRIBUTE7                   => resource_param_value_rec.l_attribute7,
         X_ATTRIBUTE8                   => resource_param_value_rec.l_attribute8,
         X_ATTRIBUTE9                   => resource_param_value_rec.l_attribute9,
         X_ATTRIBUTE10                  => resource_param_value_rec.l_attribute10,
         X_ATTRIBUTE11                  => resource_param_value_rec.l_attribute11,
         X_ATTRIBUTE12                  => resource_param_value_rec.l_attribute12,
         X_ATTRIBUTE13                  => resource_param_value_rec.l_attribute13,
         X_ATTRIBUTE14                  => resource_param_value_rec.l_attribute14,
         X_ATTRIBUTE15                  => resource_param_value_rec.l_attribute15,
         X_ATTRIBUTE_CATEGORY           => resource_param_value_rec.l_attribute_category,
         X_ATTRIBUTE1                   => resource_param_value_rec.l_attribute1,
         X_LAST_UPDATE_DATE             => sysdate,
         X_LAST_UPDATED_BY              => jtf_resource_utl.updated_by,
         X_LAST_UPDATE_LOGIN            => jtf_resource_utl.login_id
      );
      p_object_version_number	:=	l_object_version_number;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to table handler');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     -- This is for bug fix # 3870910
     -- Password will be stored using fnd_vault API
    if (l_resource_param_value_id is NOT NULL and resource_param_value_rec.l_value is NOT NULL and l_type = 'PASSWORD') then
       fnd_vault.put(l_resource_param_value_id, 'JTF_RS_RESOURCE_VALUES', resource_param_value_rec.l_value);
    end if;

    --Make the post processing call to the user hooks

    --Post Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'A',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.update_rs_resource_values_post(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          P_VALUE                       => l_value,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Post Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'A',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.update_rs_resource_values_post(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          P_VALUE                       => l_value,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Post Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.update_rs_resource_values_post(
          X_RETURN_STATUS               => x_return_status
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'UPDATE_RS_RESOURCE_VALUES',
         'M',
         'M')
      THEN
         IF (jtf_rs_resource_values_cuhk.ok_to_generate_msg(
            p_resource_param_value_id  => l_resource_param_value_id,
            x_return_status            => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
            jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_param_value_id', p_resource_param_value_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code    => 'JTF',
               p_bus_obj_code => 'RS_RPV',
               p_action_code  => 'U',
               p_bind_data_id => l_bind_data_id,
               x_return_code  => x_return_status);
               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                  --dbms_output.put_line('Returned Error status from the Message Generation API');
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
         END IF;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO update_rs_resource_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Values Pvt============= ');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO update_rs_resource_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END update_rs_resource_values;

   --Procedure to Delete Resource Values based on the input values provided by the calling routines

   PROCEDURE DELETE_RS_RESOURCE_VALUES(
      P_Api_Version			IN   	NUMBER,
      P_Init_Msg_List              	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id		IN   	NUMBER,
      p_object_version_number   	IN	JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status              	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY 	NUMBER,
      X_Msg_Data                   	OUT NOCOPY 	VARCHAR2
   )IS
      l_api_version            		CONSTANT NUMBER 	:= 1.0;
      l_api_name                      	CONSTANT VARCHAR2(30) 	:= 'DELETE_RS_RESOURCE_VALUES';
      l_resource_param_value_id   	NUMBER			:= p_resource_param_value_id;
      m_resource_param_value_id         NUMBER;
      l_object_version_number		NUMBER			:= p_object_version_number;
      l_bind_data_id			NUMBER;

      CURSOR c_resource_param_value_id( l_resource_param_value_id   IN  NUMBER ) IS
         SELECT resource_param_value_id
         FROM jtf_rs_resource_values
         WHERE resource_param_value_id = l_resource_param_value_id;

   BEGIN
      SAVEPOINT delete_rs_resource_values_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Delete Resources Values Pvt ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Initializing the Internal User Hook Record parameter values

	jtf_rs_resource_values_pub.p_rs_value_user_hook.resource_param_value_id := l_resource_param_value_id;

    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'B',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.delete_rs_resource_values_pre(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Pre Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'B',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.delete_rs_resource_values_pre(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Pre Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.delete_rs_resource_values_pre(
          X_RETURN_STATUS               => x_return_status
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Put all Validations here

   --Validate Resource Param Value Id
      OPEN c_resource_param_value_id(l_resource_param_value_id);
      FETCH c_resource_param_value_id INTO m_resource_param_value_id;
      IF c_resource_param_value_id%NOTFOUND THEN
         --dbms_output.put_line('Resource Param Value Id not found');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_RS_PRM_VALUE_ID');
         fnd_message.set_token('P_RESOURCE_PARAM_VALUE_ID', l_resource_param_value_id);
         fnd_msg_pub.add;
      CLOSE c_resource_param_value_id;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


   --Lock the row in the table before delete, by calling the table handler. */
      jtf_rs_resource_values_pkg.lock_row(
         X_RESOURCE_PARAM_VALUE_ID 	=> l_resource_param_value_id,
         X_OBJECT_VERSION_NUMBER	=> l_object_version_number
      );

   --Call Table Handler to Delete the Record
      jtf_rs_resource_values_pkg.delete_row(
         X_RESOURCE_PARAM_VALUE_ID  	=> l_resource_param_value_id
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         --dbms_output.put_line('Failed status from call to table handler');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    --Make the post processing call to the user hooks

    --Post Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'A',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.delete_rs_resource_values_post(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

    --Post Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'A',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.delete_rs_resource_values_post(
          P_RESOURCE_PARAM_VALUE_ID     => l_resource_param_value_id,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

    --Post Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.delete_rs_resource_values_post(
          X_RETURN_STATUS               => x_return_status
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_RS_RESOURCE_VALUES',
         'M',
         'M')
      THEN
         IF (jtf_rs_resource_values_cuhk.ok_to_generate_msg(
            p_resource_param_value_id  => p_resource_param_value_id,
            x_return_status            => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
            jtf_usr_hks.load_bind_data(l_bind_data_id, 'resource_param_value_id', p_resource_param_value_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code    => 'JTF',
               p_bus_obj_code => 'RS_RPV',
               p_action_code  => 'D',
               p_bind_data_id => l_bind_data_id,
               x_return_code  => x_return_status);
               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                  --dbms_output.put_line('Returned Error status from the Message Generation API');
                  x_return_status := fnd_api.g_ret_sts_unexp_error;
                  fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
         END IF;
      END IF;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO delete_rs_resource_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Resource Values Pvt=============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO delete_rs_resource_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END delete_rs_resource_values;

   --Procedure to Delete all Resource Values based on the Resource Id provided by the calling routines

   PROCEDURE DELETE_ALL_RS_RESOURCE_VALUES(
      P_Api_Version	  		IN   	NUMBER,
      P_Init_Msg_List              	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_id                	IN   	NUMBER,
      X_Return_Status              	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY 	NUMBER,
      X_Msg_Data                   	OUT NOCOPY 	VARCHAR2
   )IS
      l_api_version            		CONSTANT NUMBER 	:= 1.0;
      l_api_name                      	CONSTANT VARCHAR2(30) 	:= 'DELETE_ALL_RS_RESOURCE_VALUES';
      l_resource_id			NUMBER			:= p_resource_id;
      l_resource_param_value_id		NUMBER;
      l_object_version_number		JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE;
      l_bind_data_id			NUMBER;
-- added to handle NOCOPY for JTF_RESOURCE_UTL package
      l_resource_id_out			NUMBER;

      CURSOR c_resource_param_value_id  (l_resource_id IN NUMBER ) IS
	 SELECT jrv.resource_param_value_id, jrv.object_version_number
	 FROM jtf_rs_resource_values jrv, jtf_rs_resource_params jrp
	 WHERE jrv.resource_param_id 	=  jrp.resource_param_id
	    AND jrp.application_id 	in ( 680, 172 )
	    AND jrv.resource_id 	=  l_resource_id;

   BEGIN
      SAVEPOINT delete_all_rs_values_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Delete All Resources Values Pvt ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Initializing the Internal User Hook Record parameter value

      jtf_rs_resource_values_pub.p_rs_value_user_hook.resource_id := l_resource_id;

    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_ALL_RS_RESOURCE_VALUES',
         'B',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.delete_all_rs_values_pre(
          P_RESOURCE_ID		=> l_resource_id,
          X_RETURN_STATUS	=> x_return_status,
          X_MSG_COUNT		=> x_msg_count,
          X_MSG_DATA		=> x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

    --Pre Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_ALL_RS_RESOURCE_VALUES',
         'B',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.delete_all_rs_values_pre(
          P_RESOURCE_ID         => l_resource_id,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

    --Pre Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.delete_all_rs_values_pre(
          X_RETURN_STATUS       => x_return_status
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Put all Validations here

   --Validate Resource Id that was passed to the Procedure
    jtf_resource_utl.validate_resource_number(
        p_resource_id      => l_resource_id,
        p_resource_number  => null,
        x_return_status    => x_return_status,
        x_resource_id      => l_resource_id_out
    );
-- added  for NOCOPY
    l_resource_id := l_resource_id_out;

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

   --Loop through the Cursor and Delete all the entries for the given Resource ID
      FOR i IN c_resource_param_value_id (l_resource_id) LOOP
         --Call to the Lock_Row Table Handlers to lock the record before deleting it
         BEGIN
            jtf_rs_resource_values_pkg.lock_row(
               X_RESOURCE_PARAM_VALUE_ID       => i.resource_param_value_id,
               X_OBJECT_VERSION_NUMBER         => i.object_version_number
            );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --dbms_output.put_line('Error in Table Handler');
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
         END;
         --Call Table Handler to Delete the Selected Records
         BEGIN
            jtf_rs_resource_values_pkg.delete_row(
               X_RESOURCE_PARAM_VALUE_ID       => i.resource_param_value_id
            );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --dbms_output.put_line('Error in Table Handler');
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
         END;
      END LOOP;

    --Make the post processing call to the user hooks

    --Post Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_ALL_RS_RESOURCE_VALUES',
         'A',
         'C')
    THEN
       jtf_rs_resource_values_cuhk.delete_all_rs_values_post(
          P_RESOURCE_ID         => l_resource_id,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

    --Post Call to the Vertical Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_RESOURCE_VALUES_PVT',
         'DELETE_ALL_RS_RESOURCE_VALUES',
         'A',
         'V')
    THEN
       jtf_rs_resource_values_vuhk.delete_all_rs_values_post(
          P_RESOURCE_ID         => l_resource_id,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;

    --Post Call to the Internal Type User Hook

       jtf_rs_resource_values_iuhk.delete_all_rs_values_post(
          X_RETURN_STATUS       => x_return_status
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
           fnd_msg_pub.add;
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
         ROLLBACK TO delete_all_rs_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete All Resource Values Pvt=============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO delete_all_rs_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END delete_all_rs_resource_values;

   --Procedure to Get Resource Values based on the input values passed by the calling routines

   PROCEDURE GET_RS_RESOURCE_VALUES(
      P_Api_Version	     	IN	NUMBER,
      P_Init_Msg_List         	IN   	VARCHAR2     	:= FND_API.G_FALSE,
      P_Commit                	IN   	VARCHAR2     	:= FND_API.G_FALSE,
      P_resource_id		IN   	NUMBER,
      P_value_type		IN   	VARCHAR2,
      p_resource_param_id	IN   	NUMBER,
      x_resource_param_value_id	OUT NOCOPY 	NUMBER,
      x_value                   OUT NOCOPY  	VARCHAR2,
      X_Return_Status        	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count            	OUT NOCOPY 	NUMBER,
      X_Msg_Data             	OUT NOCOPY 	VARCHAR2
   )IS
      l_api_version		CONSTANT NUMBER 	:= 1.0;
      l_api_name		CONSTANT VARCHAR2(30) 	:= 'GET_RS_RESOURCE_VALUES';
      l_resource_id		NUMBER			:= P_RESOURCE_ID;
      l_value_type		VARCHAR2(30)		:= P_VALUE_TYPE;
      l_resource_param_id	NUMBER			:= P_RESOURCE_PARAM_ID;
-- addded for NOCOPY
      l_resource_id_out		NUMBER;


      CURSOR c_rs_resource_values IS
	 SELECT resource_param_value_id, value
	 FROM jtf_rs_resource_values
	 WHERE resource_param_id = l_resource_param_id
            AND resource_id	 = l_resource_id
	    AND ( (value_type = l_value_type) OR (l_value_type is null) );

   BEGIN
      SAVEPOINT get_rs_resource_values_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Get Resources Values Pvt ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Put all Validations here

    --Initialize API return status to success
       x_return_status	:= FND_API.G_RET_STS_SUCCESS;

   --Validate the Resource Id
      jtf_resource_utl.validate_resource_number(
         p_resource_id          => l_resource_id,
         p_resource_number      => null,
         x_return_status        => x_return_status,
         x_resource_id          => l_resource_id_out
      );
-- added for NOCOPY
      l_resource_id  := l_resource_id_out;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Resource Id Validation

   --Validate the Resource Param Id
      jtf_resource_utl.validate_resource_param_id(
         p_resource_param_id    => l_resource_param_id,
         x_return_status        => x_return_status
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
            p_resource_param_id => l_resource_param_id,
            p_value_type        => l_value_type,
            x_return_status     => x_return_status
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;
   --End of Value Type Validation

       OPEN c_rs_resource_values;
       FETCH c_rs_resource_values into x_resource_param_value_id, x_value;
       IF c_rs_resource_values%NOTFOUND THEN
          CLOSE c_rs_resource_values;
          fnd_message.set_name('JTF', 'JTF_RS_INVALID_RS_PRM_ID');
          fnd_message.set_token('P_RESOURCE_PARAM_ID', p_resource_param_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO get_rs_resource_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Get Resource Values Pvt =============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO get_rs_resource_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END get_rs_resource_values;

   --Procedure to Get Resource Param List for the given Application Id and Param Type

   PROCEDURE GET_RS_RESOURCE_PARAM_LIST(
      P_Api_Version		IN   	NUMBER,
      P_Init_Msg_List       	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit             	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_APPLICATION_ID		IN   	NUMBER,
      X_Return_Status      	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count            	OUT NOCOPY 	NUMBER,
      X_Msg_Data            	OUT NOCOPY 	VARCHAR2,
      X_RS_PARAM_Table  	OUT NOCOPY 	JTF_RS_RESOURCE_VALUES_PUB.RS_PARAM_LIST_TBL_TYPE,
      X_No_Record            	OUT NOCOPY 	NUMBER
   )IS
      l_api_version            	CONSTANT NUMBER 	:= 1.0;
      l_api_name        	CONSTANT VARCHAR2(30) 	:= 'GET_RS_RESOURCE_PARAM_LIST';
      l_rs_param_rec	     	JTF_RS_RESOURCE_VALUES_PUB.RS_PARAM_LIST_REC_TYPE;
      l_tbl_counter		NUMBER 			:= 0;
      l_APPLICATION_ID       	NUMBER			:= P_APPLICATION_ID;

      CURSOR c_rs_resource_param_list IS
         SELECT jrspm.resource_param_id, fnl.meaning, jrspm.type, jrspm.domain_lookup_type
         FROM jtf_rs_resource_params jrspm, fnd_lookups fnl
	 WHERE jrspm.application_id 	= l_application_id
	    AND jrspm.name 		= fnl.lookup_code
	    AND fnl.lookup_type 	= 'IEM_AGENT_PARAMS';
   BEGIN
      SAVEPOINT get_rs_param_list_pvt;
      x_return_status 		:= fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Get Resources Param List Pvt ');
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   --Put all Validations here

   --Initialize message return status to success
      x_return_status		:= FND_API.G_RET_STS_SUCCESS;

      OPEN c_rs_resource_param_list;
      FETCH c_rs_resource_param_list into l_rs_param_rec;
      WHILE c_rs_resource_param_list%FOUND LOOP
         l_tbl_counter			:= l_tbl_counter+1;
	 x_rs_param_table(l_tbl_counter):= l_rs_param_rec;
         FETCH c_rs_resource_param_list into l_rs_param_rec;
      END LOOP;
      CLOSE c_rs_resource_param_list;
      x_no_record	:=l_tbl_counter;

      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
         ROLLBACK TO get_rs_param_list_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line (' ========================================== ');
         --DBMS_OUTPUT.put_line (' ===========  Raised Others in Get Resource Param List Pvt =============');
         --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
         ROLLBACK TO get_rs_param_list_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END get_rs_resource_param_list;

End JTF_RS_RESOURCE_VALUES_PVT;

/
