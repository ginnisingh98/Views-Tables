--------------------------------------------------------
--  DDL for Package Body JTF_RS_SRP_TERRITORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SRP_TERRITORIES_PVT" AS
   /* $Header: jtfrsvib.pls 120.0 2005/05/11 08:23:02 appldev ship $ */

   /*****************************************************************************************
    This is a private API that caller will invoke.
    It provides procedures for managing resource salesrep territories, like
    create and update resource salesrep territories, from other modules.
    Its main procedures are as following:
    Create Resource Salesrep Territories
    Update Resource Salesrep Territories
    Calls to these procedures will invoke calls to table handlers (jtf_rs_srp_territories_pkg)
    which do the actual inserts, updates and deletes into tables.
    ******************************************************************************************/

   /* Package variables. */

   G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_SRP_TERRITORIES_PVT';

   /* Procedure to create the resource salesrep territories
	based on input values passed by calling routines. */

   PROCEDURE  create_rs_srp_territories
   (P_API_VERSION          	IN   NUMBER,
    P_INIT_MSG_LIST        	IN   VARCHAR2,
    P_COMMIT               	IN   VARCHAR2,
    P_SALESREP_ID		IN   JTF_RS_SRP_TERRITORIES.SALESREP_ID%TYPE,
    P_TERRITORY_ID		IN   JTF_RS_SRP_TERRITORIES.TERRITORY_ID%TYPE,
    P_STATUS         		IN   JTF_RS_SRP_TERRITORIES.STATUS%TYPE,
    P_WH_UPDATE_DATE      	IN   JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE,
    P_START_DATE_ACTIVE    	IN   JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
    P_END_DATE_ACTIVE      	IN   JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE,
    P_ATTRIBUTE2            	IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE2%TYPE,
    P_ATTRIBUTE3                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE3%TYPE,
    P_ATTRIBUTE4                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE4%TYPE,
    P_ATTRIBUTE5                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE5%TYPE,
    P_ATTRIBUTE6                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE6%TYPE,
    P_ATTRIBUTE7                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE7%TYPE,
    P_ATTRIBUTE8                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE8%TYPE,
    P_ATTRIBUTE9                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE9%TYPE,
    P_ATTRIBUTE1                IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE1%TYPE,
    P_ATTRIBUTE10               IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE10%TYPE,
    P_ATTRIBUTE11               IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE11%TYPE,
    P_ATTRIBUTE12               IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE12%TYPE,
    P_ATTRIBUTE13               IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE13%TYPE,
    P_ATTRIBUTE14               IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE14%TYPE,
    P_ATTRIBUTE15               IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE15%TYPE,
    P_ATTRIBUTE_CATEGORY        IN   JTF_RS_SRP_TERRITORIES.ATTRIBUTE_CATEGORY%TYPE,
    X_RETURN_STATUS        	OUT NOCOPY VARCHAR2,
    X_MSG_COUNT            	OUT NOCOPY NUMBER,
    X_MSG_DATA             	OUT NOCOPY VARCHAR2,
    X_SALESREP_TERRITORY_ID     OUT NOCOPY JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE
   )IS

   l_api_version         	CONSTANT NUMBER := 1.0;
   l_api_name            	CONSTANT VARCHAR2(30) := 'CREATE_RS_SRP_TERRITORIES';
   l_rowid                     	ROWID;
   l_salesrep_id                jtf_rs_srp_territories.salesrep_id%type 	:= p_salesrep_id;
   l_territory_id               jtf_rs_srp_territories.territory_id%type 	:= p_territory_id;
   l_start_date_active          jtf_rs_srp_territories.start_date_active%type 	:= p_start_date_active;
   l_end_date_active            jtf_rs_srp_territories.end_date_active%type   	:= p_end_date_active;
   l_wh_update_date		jtf_rs_srp_territories.wh_update_date%type	:= p_wh_update_date;
   l_status             	jtf_rs_srp_territories.status%type           	:= p_status;
   l_salesrep_territory_id      jtf_rs_srp_territories.salesrep_territory_id%type;
   l_attribute1                 jtf_rs_srp_territories.attribute1%type          := p_attribute1;
   l_attribute2                 jtf_rs_srp_territories.attribute2%type          := p_attribute2;
   l_attribute3                 jtf_rs_srp_territories.attribute3%type          := p_attribute3;
   l_attribute4                 jtf_rs_srp_territories.attribute4%type          := p_attribute4;
   l_attribute5                 jtf_rs_srp_territories.attribute5%type          := p_attribute5;
   l_attribute6                 jtf_rs_srp_territories.attribute6%type          := p_attribute6;
   l_attribute7                 jtf_rs_srp_territories.attribute7%type          := p_attribute7;
   l_attribute8                 jtf_rs_srp_territories.attribute8%type          := p_attribute8;
   l_attribute9                 jtf_rs_srp_territories.attribute9%type          := p_attribute9;
   l_attribute10                jtf_rs_srp_territories.attribute10%type         := p_attribute10;
   l_attribute11                jtf_rs_srp_territories.attribute11%type         := p_attribute11;
   l_attribute12                jtf_rs_srp_territories.attribute12%type         := p_attribute12;
   l_attribute13                jtf_rs_srp_territories.attribute13%type         := p_attribute13;
   l_attribute14                jtf_rs_srp_territories.attribute14%type         := p_attribute14;
   l_attribute15                jtf_rs_srp_territories.attribute15%type         := p_attribute15;
   l_attribute_category         jtf_rs_srp_territories.attribute_category%type  := p_attribute_category;
   l_msg_data      		VARCHAR2(2000);
   l_msg_count                	NUMBER;
   l_salesrep_start_date        DATE;
   l_salesrep_end_date          DATE;
   l_territory_start_date	DATE;
   l_territory_end_date    	DATE;
   l_check_count             	NUMBER;
   l_check_char              	VARCHAR2(1);
   l_bind_data_id		NUMBER;

   CURSOR c_jtf_rs_srp_territories( l_rowid   IN  ROWID ) IS
         SELECT 'Y'
         FROM jtf_rs_srp_territories
         WHERE ROWID = l_rowid;

   CURSOR c_salesrep_details( l_salesrep_id   IN  NUMBER ) IS
      SELECT start_date_active,
           end_date_active
      FROM jtf_rs_salesreps
      WHERE SALESREP_ID = l_salesrep_id;

   CURSOR c_territory_details( l_territory_id   IN  NUMBER ) IS
      SELECT start_date_active,
           end_date_active
      FROM ra_territories
      WHERE TERRITORY_ID = l_territory_id;

  BEGIN

    SAVEPOINT create_rs_srp_territories_pvt;
    x_return_status := fnd_api.g_ret_sts_success;
    --DBMS_OUTPUT.put_line(' Started Create Salesrep Territories Pvt ');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'B',
         'C')
    THEN
       jtf_rs_srp_territories_cuhk.create_rs_srp_territories_pre(
          P_SALESREP_ID		=> l_salesrep_id,
          P_TERRITORY_ID	=> l_territory_id,
          P_STATUS		=> l_status,
          P_WH_UPDATE_DATE	=> l_wh_update_date,
          P_START_DATE_ACTIVE	=> l_start_date_active,
          P_END_DATE_ACTIVE	=> l_end_date_active,
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
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'B',
         'V')
    THEN
       jtf_rs_srp_territories_vuhk.create_rs_srp_territories_pre(
          P_SALESREP_ID         => l_salesrep_id,
          P_TERRITORY_ID        => l_territory_id,
          P_STATUS              => l_status,
          P_WH_UPDATE_DATE      => l_wh_update_date,
          P_START_DATE_ACTIVE   => l_start_date_active,
          P_END_DATE_ACTIVE     => l_end_date_active,
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

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'B',
         'I')
    THEN
       jtf_rs_srp_territories_iuhk.create_rs_srp_territories_pre(
          P_SALESREP_ID         => l_salesrep_id,
          P_TERRITORY_ID        => l_territory_id,
          P_STATUS              => l_status,
          P_WH_UPDATE_DATE      => l_wh_update_date,
          P_START_DATE_ACTIVE   => l_start_date_active,
          P_END_DATE_ACTIVE     => l_end_date_active,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;


   --Validate if a Salesrep Territory Id already exists for the given Salesrep Id, Territory Id
      l_check_count := 0;

      SELECT count(*)
      INTO l_check_count
      FROM jtf_rs_srp_territories
      WHERE SALESREP_ID = l_salesrep_id
         AND TERRITORY_ID = l_territory_id;

      IF l_check_count > 0 THEN
         --dbms_output.put_line('Salesrep Territory Id already exists for the given Salesrep Id and Territory Id');
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name('JTF', 'JTF_RS_SRP_TERR_ID_EXISTS');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    --Date Validations
       JTF_RESOURCE_UTL.VALIDATE_INPUT_DATES(
	p_start_date_active	=> l_start_date_active,
        p_end_date_active	=> l_end_date_active,
        x_return_status       	=> x_return_status
       );
    	IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
       	   x_return_status := fnd_api.g_ret_sts_unexp_error;
           RAISE fnd_api.g_exc_unexpected_error;
    	END IF;
    --End of Date Validations

    --Get the Salesrep Details for the given Salesrep Id
       OPEN c_salesrep_details(l_salesrep_id);
       FETCH c_salesrep_details INTO l_salesrep_start_date, l_salesrep_end_date;
       IF c_salesrep_details%NOTFOUND THEN
          --dbms_output.put_line('Salesrep information not found');
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          fnd_message.set_name('JTF', 'JTF_RS_INVALID_SALESREP_ID');
          fnd_message.set_token('P_SALESREP_ID', l_salesrep_id);
          fnd_msg_pub.add;
       CLOSE c_salesrep_details;
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;

   --Validate that the Salesrep start date is less than the passed start date active
      IF l_start_date_active < l_salesrep_start_date THEN
         --dbms_output.put_line('Start date active cannot be less than Salesrep Start Date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_SRP_INVALID_START_DATE');
            fnd_message.set_token('P_SALESREP_START_DATE', l_salesrep_start_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Validate that the passed end date is not Null and less than Salesrep End Date
      IF l_salesrep_end_date is NOT NULL THEN
         IF l_end_date_active is NULL THEN
            --dbms_output.put_line ('End date active cannot be Null as Salesrep has an End date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_SRP_END_DATE_NULL');
            fnd_message.set_token('P_SALESREP_END_DATE', l_salesrep_end_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF p_end_date_active > l_salesrep_end_date THEN
            --dbms_output.put_line('End date active cannot be greater than Salesrep End Date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_SRP_INVALID_END_DATE');
            fnd_message.set_token('P_SALESREP_END_DATE', l_salesrep_end_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Get the Territory Details for the given Territory Id
      OPEN c_territory_details(p_territory_id);
      FETCH c_territory_details INTO l_territory_start_date, l_territory_end_date;
      IF c_territory_details%NOTFOUND THEN
         --dbms_output.put_line('Territory information not found');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_TERRITORY_ID');
         fnd_message.set_token('P_TERRITORY_ID', p_territory_id);
         fnd_msg_pub.add;
      CLOSE c_territory_details;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Validate that the Territory start date is less than the passed start date active
      IF p_start_date_active < l_territory_start_date THEN
         --dbms_output.put_line('Start date active cannot be less than Territory Start Date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_TER_INVALID_START_DATE');
            fnd_message.set_token('P_TERRITORY_START_DATE', l_territory_start_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

   --Validate that the passed end date is not Null and less than Territory End Date
      IF l_territory_end_date is NOT NULL THEN
         IF l_end_date_active is NULL THEN
            --dbms_output.put_line ('End date active cannot be Null as Territory has an End date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_TER_END_DATE_NULL');
            fnd_message.set_token('P_TERRITORY_END_DATE', l_territory_end_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_end_date_active > l_territory_end_date THEN
            --dbms_output.put_line('End date active cannot be greater than Territory End Date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_TER_INVALID_END_DATE');
            fnd_message.set_token('P_TERRITORY_END_DATE', l_territory_end_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Get the next value of the Salesrep_Territory_Id from the sequence
      SELECT jtf_rs_srp_territories_s.nextval
      INTO l_salesrep_territory_id
      FROM dual;

   --Insert the row into the table by calling the table handler
      jtf_rs_srp_territories_pkg.insert_row(
         X_ROWID 			=> l_rowid,
      	 X_SALESREP_TERRITORY_ID	=> l_salesrep_territory_id,
 	 X_SALESREP_ID			=> l_salesrep_id,
 	 X_TERRITORY_ID			=> l_territory_id,
 	 X_STATUS			=> l_status,
 	 X_START_DATE_ACTIVE		=> l_start_date_active,
 	 X_END_DATE_ACTIVE		=> l_end_date_active,
 	 X_WH_UPDATE_DATE		=> l_wh_update_date,
 	 X_ATTRIBUTE_CATEGORY		=> l_attribute_category,
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
 	 X_ATTRIBUTE1			=> l_attribute1,
 	 X_CREATION_DATE		=> sysdate,
 	 X_CREATED_BY			=> jtf_resource_utl.created_by,
 	 X_LAST_UPDATE_DATE		=> sysdate,
 	 X_LAST_UPDATED_BY		=> jtf_resource_utl.updated_by,
 	 X_LAST_UPDATE_LOGIN		=> jtf_resource_utl.login_id
      );

    --dbms_output.put_line('Inserted Row');
    OPEN c_jtf_rs_srp_territories(l_rowid);
    FETCH c_jtf_rs_srp_territories INTO l_check_char;
    IF c_jtf_rs_srp_territories%NOTFOUND THEN
       --dbms_output.put_line('Error in Table Handler');
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
       fnd_msg_pub.add;
    CLOSE c_jtf_rs_srp_territories;
       RAISE fnd_api.g_exc_unexpected_error;
    ELSE
       --dbms_output.put_line('Salesrep Territory Successfully Created');
       x_salesrep_territory_id := l_salesrep_territory_id;
    END IF;

   --Close the cursors
      CLOSE c_salesrep_details;
      CLOSE c_territory_details;
      CLOSE c_jtf_rs_srp_territories;

    --Make the post processing call to the user hooks

    --Post Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'A',
         'C')
    THEN
       jtf_rs_srp_territories_cuhk.create_rs_srp_territories_post(
          P_SALESREP_ID            => l_salesrep_id,
          P_TERRITORY_ID           => l_territory_id,
          P_STATUS                 => l_status,
          P_WH_UPDATE_DATE         => l_wh_update_date,
          P_START_DATE_ACTIVE      => l_start_date_active,
          P_END_DATE_ACTIVE        => l_end_date_active,
          P_SALESREP_TERRITORY_ID  => l_salesrep_territory_id,
          X_RETURN_STATUS          => x_return_status,
          X_MSG_COUNT              => x_msg_count,
          X_MSG_DATA               => x_msg_data
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
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'A',
         'V')
    THEN
       jtf_rs_srp_territories_vuhk.create_rs_srp_territories_post(
          P_SALESREP_ID            => l_salesrep_id,
          P_TERRITORY_ID           => l_territory_id,
          P_STATUS                 => l_status,
          P_WH_UPDATE_DATE         => l_wh_update_date,
          P_START_DATE_ACTIVE      => l_start_date_active,
          P_END_DATE_ACTIVE        => l_end_date_active,
          P_SALESREP_TERRITORY_ID  => l_salesrep_territory_id,
          X_RETURN_STATUS          => x_return_status,
          X_MSG_COUNT              => x_msg_count,
          X_MSG_DATA               => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --Post Call to the Internal Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'A',
         'I')
    THEN
       jtf_rs_srp_territories_iuhk.create_rs_srp_territories_post(
          P_SALESREP_ID         	=> l_salesrep_id,
          P_TERRITORY_ID        	=> l_territory_id,
          P_STATUS              	=> l_status,
          P_WH_UPDATE_DATE      	=> l_wh_update_date,
          P_START_DATE_ACTIVE   	=> l_start_date_active,
          P_END_DATE_ACTIVE     	=> l_end_date_active,
          P_SALESREP_TERRITORY_ID	=> l_salesrep_territory_id,
          X_RETURN_STATUS       	=> x_return_status,
          X_MSG_COUNT           	=> x_msg_count,
          X_MSG_DATA            	=> x_msg_data
       );
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'CREATE_RS_SRP_TERRITORIES',
         'M',
         'M')
      THEN
         IF (jtf_rs_srp_territories_cuhk.ok_to_generate_msg(
            p_salesrep_territory_id  => l_salesrep_territory_id,
            x_return_status          => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;

         /* Set bind values for the bind variables in the Business Object SQL */
            jtf_usr_hks.load_bind_data(l_bind_data_id, 'salesrep_territory_id', l_salesrep_territory_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code    => 'JTF',
               p_bus_obj_code => 'RS_SRT',
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
       ROLLBACK TO create_rs_srp_territories_pvt;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
       --DBMS_OUTPUT.put_line (' ========================================== ');
       --DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Group_member Pvt ============= ');
       --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
       ROLLBACK TO create_rs_srp_territories_pvt;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END create_rs_srp_territories;

   --Procedure to update the resource salesrep territories based on input values passed by calling routines

   PROCEDURE  update_rs_srp_territories(
      P_API_VERSION          	IN   	NUMBER,
      P_INIT_MSG_LIST        	IN   	VARCHAR2,
      P_COMMIT               	IN   	VARCHAR2,
      P_SALESREP_TERRITORY_ID	IN   	JTF_RS_SRP_TERRITORIES.SALESREP_TERRITORY_ID%TYPE,
      P_STATUS			IN   	JTF_RS_SRP_TERRITORIES.STATUS%TYPE,
      P_WH_UPDATE_DATE		IN   	JTF_RS_SRP_TERRITORIES.WH_UPDATE_DATE%TYPE,
      P_START_DATE_ACTIVE	IN   	JTF_RS_SRP_TERRITORIES.START_DATE_ACTIVE%TYPE,
      P_END_DATE_ACTIVE		IN	JTF_RS_SRP_TERRITORIES.END_DATE_ACTIVE%TYPE,
      P_OBJECT_VERSION_NUMBER	IN OUT NOCOPY 	JTF_RS_SRP_TERRITORIES.OBJECT_VERSION_NUMBER%TYPE,
      P_ATTRIBUTE2		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE2%TYPE,
      P_ATTRIBUTE3		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE3%TYPE,
      P_ATTRIBUTE4		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE4%TYPE,
      P_ATTRIBUTE5		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE5%TYPE,
      P_ATTRIBUTE6		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE6%TYPE,
      P_ATTRIBUTE7		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE7%TYPE,
      P_ATTRIBUTE8		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE8%TYPE,
      P_ATTRIBUTE9		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE9%TYPE,
      P_ATTRIBUTE1		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE1%TYPE,
      P_ATTRIBUTE10		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE10%TYPE,
      P_ATTRIBUTE11		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE11%TYPE,
      P_ATTRIBUTE12		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE12%TYPE,
      P_ATTRIBUTE13		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE13%TYPE,
      P_ATTRIBUTE14		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE14%TYPE,
      P_ATTRIBUTE15		IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE15%TYPE,
      P_ATTRIBUTE_CATEGORY	IN   	JTF_RS_SRP_TERRITORIES.ATTRIBUTE_CATEGORY%TYPE,
      X_RETURN_STATUS        	OUT NOCOPY 	VARCHAR2,
      X_MSG_COUNT            	OUT NOCOPY 	NUMBER,
      X_MSG_DATA             	OUT NOCOPY 	VARCHAR2
  )IS

   l_api_version         	CONSTANT NUMBER := 1.0;
   l_api_name            	CONSTANT VARCHAR2(30) := 'CREATE_RS_SRP_TERRITORIES';
   l_status			jtf_rs_srp_territories.status%type		:= p_status;
   l_wh_update_date		jtf_rs_srp_territories.wh_update_date%type	:= p_wh_update_date;
   l_salesrep_id		jtf_rs_srp_territories.salesrep_id%type;
   l_territory_id               jtf_rs_srp_territories.territory_id%type;
   l_start_date_active          jtf_rs_srp_territories.start_date_active%type	:= p_start_date_active;
   l_end_date_active            jtf_rs_srp_territories.end_date_active%type	:= p_end_date_active;
   l_salesrep_territory_id      jtf_rs_srp_territories.salesrep_territory_id%type := p_salesrep_territory_id;
   l_object_version_number	jtf_rs_srp_territories.object_version_number%type := p_object_version_number;
   l_attribute1                 jtf_rs_srp_territories.attribute1%type		:= p_attribute1;
   l_attribute2                 jtf_rs_srp_territories.attribute2%type		:= p_attribute2;
   l_attribute3                 jtf_rs_srp_territories.attribute3%type		:= p_attribute3;
   l_attribute4                 jtf_rs_srp_territories.attribute4%type		:= p_attribute4;
   l_attribute5                 jtf_rs_srp_territories.attribute5%type		:= p_attribute5;
   l_attribute6                 jtf_rs_srp_territories.attribute6%type		:= p_attribute6;
   l_attribute7                 jtf_rs_srp_territories.attribute7%type		:= p_attribute7;
   l_attribute8                 jtf_rs_srp_territories.attribute8%type		:= p_attribute8;
   l_attribute9                 jtf_rs_srp_territories.attribute9%type		:= p_attribute9;
   l_attribute10                jtf_rs_srp_territories.attribute10%type		:= p_attribute10;
   l_attribute11                jtf_rs_srp_territories.attribute11%type		:= p_attribute11;
   l_attribute12                jtf_rs_srp_territories.attribute12%type		:= p_attribute12;
   l_attribute13                jtf_rs_srp_territories.attribute13%type		:= p_attribute13;
   l_attribute14                jtf_rs_srp_territories.attribute14%type		:= p_attribute14;
   l_attribute15                jtf_rs_srp_territories.attribute15%type		:= p_attribute15;
   l_attribute_category         jtf_rs_srp_territories.attribute_category%type	:= p_attribute_category;
   l_msg_data                   VARCHAR2(2000);
   l_msg_count                  NUMBER;
   l_salesrep_start_date        DATE;
   l_salesrep_end_date          DATE;
   l_territory_start_date       DATE;
   l_territory_end_date         DATE;
   l_check_count                NUMBER;
   l_check_char                 VARCHAR2(1);
   l_bind_data_id               NUMBER;

   CURSOR c_salesrep_territory_id( l_salesrep_territory_id IN NUMBER) IS
      SELECT salesrep_id, territory_id
      FROM jtf_rs_srp_territories
      WHERE salesrep_territory_id = l_salesrep_territory_id;

   CURSOR c_salesrep_territory_update( l_salesrep_territory_id IN  NUMBER ) IS
      SELECT
         DECODE(p_start_date_active, fnd_api.g_miss_date, start_date_active, p_start_date_active) l_start_date_active,
         DECODE(p_end_date_active, fnd_api.g_miss_date, end_date_active, p_end_date_active) l_end_date_active,
         DECODE(p_status, fnd_api.g_miss_char, status, p_status) l_status,
         DECODE(p_wh_update_date, fnd_api.g_miss_date, wh_update_date, p_wh_update_date) l_wh_update_date,
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
      FROM jtf_rs_srp_territories
      WHERE salesrep_territory_id = l_salesrep_territory_id;

   salesrep_territory_rec      c_salesrep_territory_update%ROWTYPE;

   CURSOR c_salesrep_details( l_salesrep_territory_id IN NUMBER ) IS
      SELECT jrs.start_date_active,
             jrs.end_date_active
      FROM jtf_rs_salesreps jrs, jtf_rs_srp_territories jst
      WHERE jrs.salesrep_id = jst.salesrep_id
         AND jst.salesrep_territory_id = l_salesrep_territory_id;

   CURSOR c_territory_details( l_salesrep_territory_id IN NUMBER ) IS
      SELECT rt.start_date_active,
             rt.end_date_active
      FROM ra_territories rt, jtf_rs_srp_territories jst
      WHERE rt.territory_id = jst.territory_id
         AND jst.salesrep_territory_id = l_salesrep_territory_id;

   BEGIN
      SAVEPOINT update_rs_srp_territories_pvt;
      x_return_status := fnd_api.g_ret_sts_success;
      --DBMS_OUTPUT.put_line(' Started Update Salesrep Territories Pvt ');

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

    --Make the pre processing call to the user hooks

    --Pre Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'B',
         'C')
    THEN
       jtf_rs_srp_territories_cuhk.update_rs_srp_territories_pre(
          P_SALESREP_TERRITORY_ID    	=> l_salesrep_territory_id,
          P_STATUS              	=> l_status,
          P_WH_UPDATE_DATE      	=> l_wh_update_date,
          P_START_DATE_ACTIVE   	=> l_start_date_active,
          P_END_DATE_ACTIVE     	=> l_end_date_active,
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
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'B',
         'V')
    THEN
       jtf_rs_srp_territories_vuhk.update_rs_srp_territories_pre(
          P_SALESREP_TERRITORY_ID       => l_salesrep_territory_id,
          P_STATUS                      => l_status,
          P_WH_UPDATE_DATE              => l_wh_update_date,
          P_START_DATE_ACTIVE           => l_start_date_active,
          P_END_DATE_ACTIVE             => l_end_date_active,
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

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'B',
         'I')
    THEN
       jtf_rs_srp_territories_iuhk.update_rs_srp_territories_pre(
          P_SALESREP_TERRITORY_ID       => l_salesrep_territory_id,
          P_STATUS                      => l_status,
          P_WH_UPDATE_DATE              => l_wh_update_date,
          P_START_DATE_ACTIVE           => l_start_date_active,
          P_END_DATE_ACTIVE             => l_end_date_active,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;


   --Validate if the Salerep_Id, Territory_Id exist for the given Salesrep Territory Id. */
      OPEN c_salesrep_territory_id(l_salesrep_territory_id);
      FETCH c_salesrep_territory_id INTO l_salesrep_id, l_territory_id;
      IF c_salesrep_territory_id%NOTFOUND THEN
         --dbms_output.put_line('Salesrep Id, Territory Id do not exist for the given Salesrep Territory Id');
         CLOSE c_salesrep_territory_id;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_SRP_TERR_ID');
         fnd_message.set_token('P_SALESREP_TERRITORY_ID', l_salesrep_territory_id);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Validate Salerep Territory for Update
    OPEN c_salesrep_territory_update(l_salesrep_territory_id);
    FETCH c_salesrep_territory_update INTO salesrep_territory_rec;
    IF c_salesrep_territory_update%NOTFOUND THEN
       CLOSE c_salesrep_territory_update;
       fnd_message.set_name('JTF', 'JTF_RS_INVALID_SRP_TERR_ID');
       fnd_message.set_token('P_SALESREP_TERRITORY_ID', l_salesrep_territory_id);
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Date Validations
       IF (p_start_date_active <>FND_API.G_MISS_DATE OR p_end_date_active <> FND_API.G_MISS_DATE) THEN
          JTF_RESOURCE_UTL.VALIDATE_INPUT_DATES(
             p_start_date_active     => l_start_date_active,
             p_end_date_active       => l_end_date_active,
             x_return_status         => x_return_status
          );
          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
    --End of Date Validations

   --Get the salesrep details for the member record
      OPEN c_salesrep_details(l_salesrep_territory_id);
      FETCH c_salesrep_details INTO l_salesrep_start_date, l_salesrep_end_date;
      IF c_salesrep_details%NOTFOUND THEN
         --dbms_output.put_line('Salesrep information not found for the given Salesrep Territory Id');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_SRP_TERR_ID');
         fnd_message.set_token('P_SALESREP_TERRITORY_ID', l_salesrep_territory_id);
         fnd_msg_pub.add;
      CLOSE c_salesrep_details;
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

   --Validate that the Salesrep start date is less than the passed start date active
      IF p_start_date_active <>FND_API.G_MISS_DATE THEN
         IF l_start_date_active < l_salesrep_start_date THEN
            --dbms_output.put_line('Start date active cannot be less than Salesrep Start Date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_SRP_INVALID_START_DATE');
            fnd_message.set_token('P_SALESREP_START_DATE', l_salesrep_start_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate that the passed end date is not Null and less than Salesrep End Date
      IF p_end_date_active <>FND_API.G_MISS_DATE THEN
         IF l_salesrep_end_date is NOT NULL THEN
            IF l_end_date_active is NULL THEN
               --dbms_output.put_line ('End date active cannot be Null as Salesrep has an End date');
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name('JTF', 'JTF_RS_SRP_END_DATE_NULL');
               fnd_message.set_token('P_SALESREP_END_DATE', l_salesrep_end_date);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_end_date_active > l_salesrep_end_date THEN
               --dbms_output.put_line('End date active cannot be greater than Salesrep End Date');
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name('JTF', 'JTF_RS_SRP_INVALID_END_DATE');
               fnd_message.set_token('P_SALESREP_END_DATE', l_salesrep_end_date);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

   --Get the territory details for the member record
      OPEN c_territory_details(l_salesrep_territory_id);
      FETCH c_territory_details INTO l_territory_start_date, l_territory_end_date;
      IF c_territory_details%NOTFOUND THEN
         --dbms_output.put_line('Territory information not found');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_SRP_TERR_ID');
         fnd_message.set_token('P_SALESREP_TERRITORY_ID', l_salesrep_territory_id);
         fnd_msg_pub.add;
      CLOSE c_territory_details;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   --Validate that the Territory start date is less than the passed start date active
      IF p_start_date_active <>FND_API.G_MISS_DATE THEN
         IF l_start_date_active < l_territory_start_date THEN
            --dbms_output.put_line('Start date active cannot be less than Territory Start Date');
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('JTF', 'JTF_RS_SRP_INVALID_START_DATE');
            fnd_message.set_token('P_TERRITORY_START_DATE', l_territory_start_date);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

   --Validate that the passed end date is not Null and less than Territory End Date
      IF p_start_date_active <>FND_API.G_MISS_DATE THEN
         IF l_territory_end_date is NOT NULL THEN
            IF l_end_date_active is NULL THEN
               --dbms_output.put_line ('End date active cannot be Null as Territory has an End date');
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name('JTF', 'JTF_RS_SRP_END_DATE_NULL');
               fnd_message.set_token('P_TERRITORY_END_DATE', l_territory_end_date);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF p_end_date_active > l_territory_end_date THEN
               --dbms_output.put_line('End date active cannot be greater than Territory End Date');
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name('JTF', 'JTF_RS_SRP_INVALID_END_DATE');
               fnd_message.set_token('P_TERRITORY_END_DATE', l_territory_end_date);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

   --Lock the row in the table by calling the table handler
      jtf_rs_srp_territories_pkg.lock_row(
         X_SALESREP_TERRITORY_ID 	=> l_salesrep_territory_id,
         X_OBJECT_VERSION_NUMBER	=> l_object_version_number
      );

   --Update the Object Version Number by Incrementing It
     l_object_version_number	:= p_object_version_number+1;


    BEGIN
   --Update the row in the table by calling the table handler
      jtf_rs_srp_territories_pkg.update_row(
         X_SALESREP_TERRITORY_ID => p_salesrep_territory_id,
         X_SALESREP_ID           => l_salesrep_id,
         X_TERRITORY_ID          => l_territory_id,
         X_STATUS                => salesrep_territory_rec.l_status,
         X_START_DATE_ACTIVE     => salesrep_territory_rec.l_start_date_active,
         X_END_DATE_ACTIVE       => salesrep_territory_rec.l_end_date_active,
         X_WH_UPDATE_DATE        => salesrep_territory_rec.l_wh_update_date,
 	 X_OBJECT_VERSION_NUMBER => l_object_version_number,
         X_ATTRIBUTE_CATEGORY    => salesrep_territory_rec.l_attribute_category,
         X_ATTRIBUTE2            => salesrep_territory_rec.l_attribute2,
         X_ATTRIBUTE3            => salesrep_territory_rec.l_attribute3,
         X_ATTRIBUTE4            => salesrep_territory_rec.l_attribute4,
         X_ATTRIBUTE5            => salesrep_territory_rec.l_attribute5,
         X_ATTRIBUTE6            => salesrep_territory_rec.l_attribute6,
         X_ATTRIBUTE7            => salesrep_territory_rec.l_attribute7,
         X_ATTRIBUTE8            => salesrep_territory_rec.l_attribute8,
         X_ATTRIBUTE9            => salesrep_territory_rec.l_attribute9,
         X_ATTRIBUTE10           => salesrep_territory_rec.l_attribute10,
         X_ATTRIBUTE11           => salesrep_territory_rec.l_attribute11,
         X_ATTRIBUTE12           => salesrep_territory_rec.l_attribute12,
         X_ATTRIBUTE13           => salesrep_territory_rec.l_attribute13,
         X_ATTRIBUTE14           => salesrep_territory_rec.l_attribute14,
         X_ATTRIBUTE15           => salesrep_territory_rec.l_attribute15,
         X_ATTRIBUTE1            => salesrep_territory_rec.l_attribute1,
         X_LAST_UPDATE_DATE      => sysdate,
         X_LAST_UPDATED_BY       => jtf_resource_utl.updated_by,
         X_LAST_UPDATE_LOGIN     => jtf_resource_utl.login_id
      );

      p_object_version_number := l_object_version_number;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --dbms_output.put_line('Error in Table Handler');
         CLOSE c_salesrep_territory_update;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_unexpected_error;
      END;
      --dbms_output.put_line('Salesrep Territory Successfully Updated');

   --Close the cursors
     --CLOSE c_salesrep_territory_update;
     --CLOSE c_salesrep_details;
     --CLOSE c_salesrep_details;
     --CLOSE c_salesrep_territory_id;

    --Make the post processing call to the user hooks

    --Post Call to the Customer Type User Hook

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'A',
         'C')
    THEN
       jtf_rs_srp_territories_cuhk.update_rs_srp_territories_post(
          P_SALESREP_TERRITORY_ID       => l_salesrep_territory_id,
          P_STATUS                      => l_status,
          P_WH_UPDATE_DATE              => l_wh_update_date,
          P_START_DATE_ACTIVE           => l_start_date_active,
          P_END_DATE_ACTIVE             => l_end_date_active,
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
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'A',
         'V')
    THEN
       jtf_rs_srp_territories_vuhk.update_rs_srp_territories_post(
          P_SALESREP_TERRITORY_ID       => l_salesrep_territory_id,
          P_STATUS                      => l_status,
          P_WH_UPDATE_DATE              => l_wh_update_date,
          P_START_DATE_ACTIVE           => l_start_date_active,
          P_END_DATE_ACTIVE             => l_end_date_active,
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

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'A',
         'I')
    THEN
       jtf_rs_srp_territories_iuhk.update_rs_srp_territories_post(
          P_SALESREP_TERRITORY_ID       => l_salesrep_territory_id,
          P_STATUS                      => l_status,
          P_WH_UPDATE_DATE              => l_wh_update_date,
          P_START_DATE_ACTIVE           => l_start_date_active,
          P_END_DATE_ACTIVE             => l_end_date_active,
          X_RETURN_STATUS               => x_return_status,
          X_MSG_COUNT                   => x_msg_count,
          X_MSG_DATA                    => x_msg_data
       );

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
           fnd_msg_pub.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

   /* Standard call for Message Generation */

      IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SRP_TERRITORIES_PVT',
         'UPDATE_RS_SRP_TERRITORIES',
         'M',
         'M')
      THEN
         IF (jtf_rs_srp_territories_cuhk.ok_to_generate_msg(
            p_salesrep_territory_id  => l_salesrep_territory_id,
            x_return_status          => x_return_status) )
         THEN

         /* Get the bind data id for the Business Object Instance */
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
         /* Set bind values for the bind variables in the Business Object SQL */
            jtf_usr_hks.load_bind_data(l_bind_data_id, 'salesrep_territory_id', p_salesrep_territory_id, 'S', 'N');

         /* Call the message generation API */
            jtf_usr_hks.generate_message(
               p_prod_code    => 'JTF',
               p_bus_obj_code => 'RS_SRT',
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
      ROLLBACK TO update_rs_srp_territories_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line (' ========================================== ');
      --DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Salesrep Territories Pvt ============= ');
      --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);
      ROLLBACK TO update_rs_srp_territories_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END update_rs_srp_territories;

END jtf_rs_srp_territories_pvt;

/
