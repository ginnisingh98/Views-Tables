--------------------------------------------------------
--  DDL for Package Body JTF_RS_SRP_TERRITORIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SRP_TERRITORIES_PUB" AS
  /* $Header: jtfrspib.pls 120.0 2005/05/11 08:21:11 appldev ship $ */

  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing resource salesrep territories, like
   create, update and delete resource salesrep territories from other modules.
   Its main procedures are as following:
   Create Resource Salesrep Territories
   Update Resource Salesrep Territories
   Delete Resource Salesrep Territories
   Calls to these procedures will invoke procedures from jtf_rs_srp_territories_pvt
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_SRP_TERRITORIES_PUB';

  /* Procedure to create the resource salesrep territories
	based on input values passed by calling routines. */

  PROCEDURE  create_rs_srp_territories
  (P_API_VERSION          	IN   NUMBER,
   P_INIT_MSG_LIST        	IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               	IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SALESREP_ID		IN   JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
   P_TERRITORY_ID		IN   JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
   P_STATUS         		IN   JTF_RS_SRP_TERRITORIES.STATUS%TYPE 		DEFAULT NULL,
   P_WH_UPDATE_DATE      	IN   JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE 	DEFAULT NULL,
   P_START_DATE_ACTIVE    	IN   JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      	IN   JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE   	DEFAULT NULL,
   X_RETURN_STATUS        	OUT NOCOPY VARCHAR2,
   X_MSG_COUNT            	OUT NOCOPY NUMBER,
   X_MSG_DATA             	OUT NOCOPY VARCHAR2,
   X_SALESREP_TERRITORY_ID      OUT NOCOPY JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE
  ) IS

   l_api_version         	CONSTANT NUMBER := 1.0;
   l_api_name            	CONSTANT VARCHAR2(30) := 'CREATE_RS_SRP_TERRITORIES';
   l_salesrep_id		jtf_rs_srp_territories.salesrep_id%type  	:= p_salesrep_id;
   l_territory_id		jtf_rs_srp_territories.territory_id%type 	:= p_territory_id;
   l_status			jtf_rs_srp_territories.status%type		:= p_status;
   l_wh_update_date		jtf_rs_srp_territories.wh_update_date%type 	:= p_wh_update_date;
   l_start_date_active		jtf_rs_srp_territories.start_date_active%type 	:= p_start_date_active;
   l_end_date_active		jtf_rs_srp_territories.end_date_active%type   	:= p_end_date_active;
   l_salesrep_territory_id	jtf_rs_srp_territories.salesrep_territory_id%type;
   l_org_id                     number;


    CURSOR c_salesrep_id IS
    SELECT salesrep_id
    FROM   jtf_rs_salesreps
    WHERE  salesrep_id = l_salesrep_id;
    l_salesrep   		jtf_rs_srp_territories.salesrep_id%type  ;


BEGIN
    SAVEPOINT create_rs_srp_territories_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Create RS SRP Territories Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

   --Put in all the Validations here

   --Validate the Salesrep Id

    IF p_salesrep_id IS NULL THEN
--      dbms_output.put_line('Salesrep Id is null');
      fnd_message.set_name('JTF', 'JTF_RS_SALESREP_ID_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    END IF;
    IF p_salesrep_id IS NOT NULL THEN
      OPEN c_salesrep_id;
      FETCH c_salesrep_id INTO l_salesrep;
      IF c_salesrep_id%NOTFOUND THEN
--        dbms_output.put_line('Invalid Salesrep Id');
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SALESREP_ID');
        fnd_message.set_token('P_SALESREP_ID', p_salesrep_id);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;
      CLOSE c_salesrep_id;
    END IF;

/*      jtf_resource_utl.validate_salesrep_id(
         p_salesrep_id		=> l_salesrep_id,
         p_org_id               => l_org_id,
         x_return_status 	=> x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
   --End of Salesrep Id  Validation

   --Validate the Territory Id
      jtf_resource_utl.validate_territory_id(
         p_territory_id => l_territory_id,
         x_return_status => x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Territory Id  Validation

    --Call the Private API for create_rs_srp_territories

    jtf_rs_srp_territories_pvt.create_rs_srp_territories
    (P_API_VERSION 		=> 1,
     P_INIT_MSG_LIST 		=> fnd_api.g_false,
     P_COMMIT 			=> fnd_api.g_false,
     P_SALESREP_ID 		=> l_salesrep_id,
     P_TERRITORY_ID 		=> l_territory_id,
     P_STATUS                   => l_status,
     P_WH_UPDATE_DATE           => l_wh_update_date,
     P_START_DATE_ACTIVE	=> l_start_date_active,
     P_END_DATE_ACTIVE 		=> l_end_date_active,
     X_RETURN_STATUS 		=> x_return_status,
     X_MSG_COUNT 		=> x_msg_count,
     X_MSG_DATA 		=> x_msg_data,
     X_SALESREP_TERRITORY_ID	=> x_salesrep_territory_id
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
      ROLLBACK TO create_rs_srp_territories_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Salesrep Territories Pub ============= ');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO create_rs_srp_territories_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

END create_rs_srp_territories;

   --Procedure to update the resource salesrep territories based on input values passed by calling routines

  PROCEDURE  update_rs_srp_territories
  (P_API_VERSION          	IN   	NUMBER,
   P_INIT_MSG_LIST        	IN   	VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               	IN   	VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SALESREP_ID                IN   	JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
   P_TERRITORY_ID               IN   	JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
   P_STATUS                     IN   	JTF_RS_SRP_TERRITORIES.STATUS%TYPE		DEFAULT FND_API.G_MISS_CHAR,
   P_WH_UPDATE_DATE             IN   	JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE 	DEFAULT FND_API.G_MISS_DATE,
   P_START_DATE_ACTIVE          IN   	JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE 	DEFAULT FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE            IN   	JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE 	DEFAULT FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY  JTF_RS_SRP_TERRITORIES.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        	OUT NOCOPY 	VARCHAR2,
   X_MSG_COUNT            	OUT NOCOPY 	NUMBER,
   X_MSG_DATA             	OUT NOCOPY 	VARCHAR2
  ) IS

   l_api_version         	CONSTANT NUMBER := 1.0;
   l_api_name            	CONSTANT VARCHAR2(30) := 'CREATE_RS_SRP_TERRITORIES';
   l_salesrep_id                jtf_rs_srp_territories.salesrep_id%type		:= p_salesrep_id;
   l_territory_id               jtf_rs_srp_territories.territory_id%type	:= p_territory_id;
   l_status                     jtf_rs_srp_territories.status%type		:= p_status;
   l_wh_update_date             jtf_rs_srp_territories.wh_update_date%type	:= p_wh_update_date;
   l_start_date_active          jtf_rs_srp_territories.start_date_active%type	:= p_start_date_active;
   l_end_date_active            jtf_rs_srp_territories.end_date_active%type	:= p_end_date_active;
   l_attribute1                 jtf_rs_srp_territories.attribute1%type;
   l_attribute2			jtf_rs_srp_territories.attribute2%type;
   l_attribute3                 jtf_rs_srp_territories.attribute3%type;
   l_attribute4                 jtf_rs_srp_territories.attribute4%type;
   l_attribute5                 jtf_rs_srp_territories.attribute5%type;
   l_attribute6                 jtf_rs_srp_territories.attribute6%type;
   l_attribute7                 jtf_rs_srp_territories.attribute7%type;
   l_attribute8                 jtf_rs_srp_territories.attribute8%type;
   l_attribute9                 jtf_rs_srp_territories.attribute9%type;
   l_attribute10                jtf_rs_srp_territories.attribute10%type;
   l_attribute11                jtf_rs_srp_territories.attribute11%type;
   l_attribute12                jtf_rs_srp_territories.attribute12%type;
   l_attribute13                jtf_rs_srp_territories.attribute13%type;
   l_attribute14                jtf_rs_srp_territories.attribute14%type;
   l_attribute15                jtf_rs_srp_territories.attribute15%type;
   l_attribute_category         jtf_rs_srp_territories.attribute_category%type;
   l_salesrep_territory_id      jtf_rs_srp_territories.salesrep_territory_id%type;
   l_object_version_number	jtf_rs_srp_territories.object_version_number%type := p_object_version_number;
   l_org_id                     number;

    CURSOR c_salesrep_id IS
    SELECT salesrep_id
    FROM   jtf_rs_salesreps
    WHERE  salesrep_id = l_salesrep_id;
    l_salesrep   		jtf_rs_srp_territories.salesrep_id%type  ;

  BEGIN
    SAVEPOINT update_rs_srp_territories_pub;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Update Salesrep Territory Pub ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

  --Put all Validations here

   --Validate the Salesrep Id

    IF p_salesrep_id IS NULL THEN
--      dbms_output.put_line('Salesrep Id is null');
      fnd_message.set_name('JTF', 'JTF_RS_SALESREP_ID_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    END IF;
    IF p_salesrep_id IS NOT NULL THEN
      OPEN c_salesrep_id;
      FETCH c_salesrep_id INTO l_salesrep;
      IF c_salesrep_id%NOTFOUND THEN
--        dbms_output.put_line('Invalid Salesrep Id');
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SALESREP_ID');
        fnd_message.set_token('P_SALESREP_ID', p_salesrep_id);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;
      CLOSE c_salesrep_id;
    END IF;

/*      jtf_resource_utl.validate_salesrep_id(
         p_salesrep_id 		=> l_salesrep_id,
         x_return_status 	=> x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
   --End of Salesrep Id Validation

   --Validate the Territory Id
      jtf_resource_utl.validate_territory_id(
         p_territory_id 	=> l_territory_id,
         x_return_status 	=> x_return_status
      );
      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --End of Territory Id Validation

      SELECT salesrep_territory_id INTO l_salesrep_territory_id
      FROM jtf_rs_srp_territories
      WHERE salesrep_id = l_salesrep_id
         AND territory_id = l_territory_id;

  --Call the private procedure for update

    jtf_rs_srp_territories_pvt.update_rs_srp_territories
    (P_API_VERSION 		=> 1,
     P_INIT_MSG_LIST 		=> fnd_api.g_false,
     P_COMMIT 			=> fnd_api.g_false,
     P_SALESREP_TERRITORY_ID	=> l_salesrep_territory_id,
     P_STATUS                   => l_status,
     P_WH_UPDATE_DATE           => l_wh_update_date,
     P_START_DATE_ACTIVE 	=> l_start_date_active,
     P_END_DATE_ACTIVE 		=> l_end_date_active,
     P_OBJECT_VERSION_NUMBER	=> l_object_version_number,
     X_RETURN_STATUS 		=> x_return_status,
     X_MSG_COUNT 		=> x_msg_count,
     X_MSG_DATA 		=> x_msg_data
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       --dbms_output.put_line('Failed status from call to private procedure');
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    p_object_version_number := l_object_version_number;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line ('===========  Raised Unexpected Error  =============== ');
      ROLLBACK TO update_rs_srp_territories_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Salesrep Territories Pub ============= ');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO update_rs_srp_territories_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END update_rs_srp_territories;

END jtf_rs_srp_territories_pub;

/
