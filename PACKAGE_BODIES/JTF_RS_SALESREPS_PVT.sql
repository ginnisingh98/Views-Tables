--------------------------------------------------------
--  DDL for Package Body JTF_RS_SALESREPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SALESREPS_PVT" AS
/* $Header: jtfrsvsb.pls 120.1 2005/06/07 23:03:26 baianand ship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_RS_SALESREPS_PVT';

/* Procedure to create salesreps */

 PROCEDURE Create_salesrep(
   P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                 IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS               IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_ORG_ID               IN   JTF_RS_SALESREPS.ORG_ID%TYPE,
   P_GL_ID_REV            IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT        IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC            IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID      IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER      IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE       IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE    IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_SALESREPS.ATTRIBUTE_CATEGORY%TYPE,
   P_ATTRIBUTE1           IN   JTF_RS_SALESREPS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN   JTF_RS_SALESREPS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN   JTF_RS_SALESREPS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN   JTF_RS_SALESREPS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN   JTF_RS_SALESREPS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN   JTF_RS_SALESREPS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN   JTF_RS_SALESREPS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN   JTF_RS_SALESREPS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN   JTF_RS_SALESREPS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN   JTF_RS_SALESREPS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN   JTF_RS_SALESREPS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN   JTF_RS_SALESREPS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN   JTF_RS_SALESREPS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN   JTF_RS_SALESREPS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN   JTF_RS_SALESREPS.ATTRIBUTE15%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_SALESREP_ID          OUT NOCOPY JTF_RS_SALESREPS.SALESREP_ID%TYPE
  )
 IS
   l_api_name        	       CONSTANT VARCHAR2(30) := 'CREATE_SALESREP';
   l_api_version 	       CONSTANT NUMBER   := 1.0;
   l_rowid                    		ROWID;
   l_resource_id			jtf_rs_salesreps.resource_id%type := p_resource_id;
   l_sales_credit_type_id	 	jtf_rs_salesreps.sales_credit_type_id%type := p_sales_credit_type_id;
   l_name                	    	jtf_rs_salesreps.name%type := p_name;
   l_status             		jtf_rs_salesreps.status%type := p_status;
   l_start_date_active      		jtf_rs_salesreps.start_date_active%type := p_start_date_active;
   l_end_date_active         		jtf_rs_salesreps.end_date_active%type := p_end_date_active;
   l_gl_id_rev               		jtf_rs_salesreps.gl_id_rev%type := p_gl_id_rev;
   l_gl_id_freight           		jtf_rs_salesreps.gl_id_freight%type := p_gl_id_freight;
   l_gl_id_rec               		jtf_rs_salesreps.gl_id_rec%type := p_gl_id_rec;
   l_set_of_books_id         		jtf_rs_salesreps.set_of_books_id%type := p_set_of_books_id;
   l_salesrep_number         		jtf_rs_salesreps.salesrep_number%type := p_salesrep_number;
   l_email_address           		jtf_rs_salesreps.email_address%type := p_email_address;
   l_wh_update_date          		jtf_rs_salesreps.wh_update_date%type := p_wh_update_date;
   l_sales_tax_geocode       		jtf_rs_salesreps.sales_tax_geocode%type := p_sales_tax_geocode;
   l_sales_tax_inside_city_limits      jtf_rs_salesreps.sales_tax_inside_city_limits%type := p_sales_tax_inside_city_limits;
   l_category				jtf_rs_resource_extns.category%type;
   l_person_id				jtf_rs_salesreps.person_id%type;
   l_salesrep_id         		jtf_rs_salesreps.salesrep_id%type;
   l_org_id         		        jtf_rs_salesreps.org_id%type := p_org_id;
   l_msg_data				VARCHAR2(2000);
   l_msg_count				NUMBER;
   l_check_char				VARCHAR2(1);
   l_check_dup_id                 	VARCHAR2(1);
   l_bind_data_id                 	NUMBER;

   CURSOR c_category(l_resource_id jtf_rs_resource_extns.resource_id%type) is
      SELECT category,source_id
      FROM   jtf_rs_resource_extns
      WHERE  resource_id = l_resource_id;

   CURSOR c_jtf_rs_salesreps(l_rowid IN ROWID) IS
      SELECT 'Y'
      FROM   jtf_rs_salesreps
      WHERE  rowid = l_rowid;

    CURSOR c_dup_salesrep_id (l_salesrep_id 	IN jtf_rs_salesreps.salesrep_id%type,
                              l_org_id 		IN jtf_rs_salesreps.org_id%type )
        IS
        SELECT 'X'
        FROM jtf_rs_salesreps
        WHERE salesrep_id = l_salesrep_id
        AND nvl(org_id,-99) = nvl(l_org_id,-99);

   CURSOR c_dup_resource(l_resource_id jtf_rs_resource_extns.resource_id%type,
                         l_org_id      jtf_rs_salesreps.org_id%type) IS
      SELECT 'Y'
      FROM   jtf_rs_salesreps
      WHERE  resource_id = l_resource_id
      AND    nvl(org_id,-99) = nvl(l_org_id,-99);

   resource_exists varchar2(1);

 BEGIN

--  dbms_output.put_line ('Inside the Create Salesrep PVT API');

    SAVEPOINT create_salesrep_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

    /*  Standard call to check for call compatibility. */
    IF NOT fnd_api.Compatible_api_call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_Boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'CREATE_SALESREP',
         'B',
         'C')
    THEN
      jtf_rs_salesreps_cuhk.create_salesrep_pre(
	 p_resource_id                  => l_resource_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;


      END IF;
    END IF;

    /* Pre Call to the Vertical Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'CREATE_SALESREP',
         'B',
         'V')
    THEN

      jtf_rs_salesreps_vuhk.create_salesrep_pre(
	 p_resource_id                  => l_resource_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;


      END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'CREATE_SALESREP',
         'B',
         'I')
    THEN

      jtf_rs_salesreps_iuhk.create_salesrep_pre(
	 p_resource_id                  => l_resource_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;


      END IF;
    END IF;


    /*  Starting API body */

    jtf_resource_utl.validate_input_dates(
		 l_start_date_active
		,l_end_date_active
		,x_return_status);

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

    OPEN    c_category(l_resource_id);
    FETCH   c_category INTO l_category,l_person_id;
    IF c_category%NOTFOUND THEN
    	CLOSE c_category;
        fnd_message.set_name('JTF','JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID',l_resource_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_category;

--    select to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' '
--    ,null,substrb(userenv('CLIENT_INFO'),1,10)))
--    into   l_org_id
--    from dual;

--    dbms_output.put_line('Org id before validation : '||  l_org_id);
    l_org_id := MO_GLOBAL.get_valid_org(p_org_id);
    IF l_org_id is NULL THEN
--       dbms_output.put_line('Org id is Null');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
--    dbms_output.put_line('Org id is : '||l_org_id);

    IF MO_UTILS.Get_Multi_Org_Flag = 'Y' and l_org_id is NULL THEN
        fnd_message.set_name('JTF','JTF_RS_ORG_CONTEXT_NOT_SET');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;

   -- l_org_id := fnd_profile.value('ORG_ID');

/**    IF (l_category = 'OTHER') OR (l_category = 'TBH') OR (l_category = 'EMPLOYEE') OR (l_category = 'PARTY') OR (l_category = 'PARTNER') OR (l_category = 'SUPPLIER_CONTACT') THEN **/
       jtf_resource_utl.validate_salesrep_number(l_salesrep_number,
                                                 l_org_id,
						 x_return_status);
       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
       END IF;
--    END IF;

    OPEN  c_dup_resource(l_resource_id, l_org_id);
    FETCH c_dup_resource into resource_exists;
    IF c_dup_resource%FOUND THEN
        CLOSE c_dup_resource;
        fnd_message.set_name('JTF','JTF_RS_DUP_RES_SALESPERSON');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_dup_resource;

   /* This portion of the code was modified to accomodate the calls to Migration API */
   /* Check if the Global Variable Flag for Salesrep ID is Y or N */

--     dbms_output.put_line ('Before checkin the Global flag in PVT API');

      IF G_SRP_ID_PVT_FLAG = 'Y' THEN

        /* Get the next value of the Salesrep_id from the sequence. */

           LOOP
    	      SELECT  jtf_rs_salesreps_s.nextval
              INTO    l_salesrep_id
              FROM    dual;
              --dbms_output.put_line ('After Select - Salesrep ID ' || l_salesrep_id);

              OPEN c_dup_salesrep_id (l_salesrep_id, l_org_id);
              FETCH c_dup_salesrep_id INTO l_check_dup_id;
              EXIT WHEN c_dup_salesrep_id%NOTFOUND;
              CLOSE c_dup_salesrep_id;
           END LOOP;
           CLOSE c_dup_salesrep_id;

     ELSE
        l_salesrep_id           := JTF_RS_SALESREPS_PUB.G_SALESREP_ID;
        l_org_id 		:= JTF_RS_SALESREPS_PUB.G_ORG_ID;

      END IF;

    /* Calling table handler to insert salesrep */
    jtf_rs_salesreps_pkg.insert_row(
	 X_ROWID                        => l_rowid,
	 X_SALESREP_ID                  => l_salesrep_id,
	 X_RESOURCE_ID                  => l_resource_id,
	 X_SALES_CREDIT_TYPE_ID         => l_sales_credit_type_id,
	 X_NAME                         => l_name,
	 X_STATUS                       => l_status,
 	 X_START_DATE_ACTIVE            => l_start_date_active,
	 X_END_DATE_ACTIVE              => l_end_date_active,
         X_ORG_ID                       => l_org_id,
	 X_GL_ID_REV                    => l_gl_id_rev,
	 X_GL_ID_FREIGHT                => l_gl_id_freight,
	 X_GL_ID_REC                    => l_gl_id_rec,
	 X_SET_OF_BOOKS_ID              => l_set_of_books_id,
	 X_SALESREP_NUMBER              => l_salesrep_number,
	 X_EMAIL_ADDRESS                => l_email_address,
	 X_WH_UPDATE_DATE               => l_wh_update_date,
	 X_PERSON_ID                    => l_person_id,
	 X_SALES_TAX_GEOCODE            => l_sales_tax_geocode,
	 X_SALES_TAX_INSIDE_CITY_LIMITS => l_sales_tax_inside_city_limits,
	 X_ATTRIBUTE_CATEGORY           => p_attribute_category,
	 X_ATTRIBUTE2                   => p_attribute2,
	 X_ATTRIBUTE3                   => p_attribute3,
	 X_ATTRIBUTE4                   => p_attribute4,
	 X_ATTRIBUTE5                   => p_attribute5,
	 X_ATTRIBUTE6                   => p_attribute6,
	 X_ATTRIBUTE7                   => p_attribute7,
	 X_ATTRIBUTE8                   => p_attribute8,
	 X_ATTRIBUTE9                   => p_attribute9,
	 X_ATTRIBUTE10                  => p_attribute10,
	 X_ATTRIBUTE11                  => p_attribute11,
	 X_ATTRIBUTE12                  => p_attribute12,
	 X_ATTRIBUTE13                  => p_attribute13,
	 X_ATTRIBUTE14                  => p_attribute14,
	 X_ATTRIBUTE15                  => p_attribute15,
	 X_ATTRIBUTE1                   => p_attribute1,
	 X_CREATION_DATE                => SYSDATE,
	 X_CREATED_BY                   => jtf_resource_utl.created_by,
	 X_LAST_UPDATE_DATE             => SYSDATE,
	 X_LAST_UPDATED_BY              => jtf_resource_utl.updated_by,
	 X_LAST_UPDATE_LOGIN            => jtf_resource_utl.login_id
        );

    OPEN c_jtf_rs_salesreps(l_rowid);
    FETCH c_jtf_rs_salesreps INTO l_check_char;
    IF c_jtf_rs_salesreps%NOTFOUND THEN

        CLOSE c_jtf_rs_salesreps;

        fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

    ELSE
        x_salesrep_id := l_salesrep_id;
        CLOSE c_jtf_rs_salesreps;
    END IF;

    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'CREATE_SALESREP',
         'A',
         'C')
    THEN
      jtf_rs_salesreps_cuhk.create_salesrep_post(
	 p_salesrep_id                  => l_salesrep_id,
	 p_resource_id                  => l_resource_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;

    /* Post Call to the Vertical Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'CREATE_SALESREP',
         'A',
         'V')
    THEN
      jtf_rs_salesreps_vuhk.create_salesrep_post(
	 p_salesrep_id                  => l_salesrep_id,
	 p_resource_id                  => l_resource_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;

    /* Post Call to the Internal Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'CREATE_SALESREP',
         'A',
         'I')
    THEN
      jtf_rs_salesreps_iuhk.create_salesrep_post(
	 p_salesrep_id                  => l_salesrep_id,
	 p_resource_id                  => l_resource_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;


    /* Standard call for Message Generation */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_SALESREPS_PVT',
	 'CREATE_SALESREP',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_salesreps_cuhk.ok_to_generate_msg(
	       p_salesrep_id => l_salesrep_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'salesrep_id', l_salesrep_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_SRP',
		p_action_code => 'I',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;


        END IF;

      END IF;

    END IF;

    IF fnd_api.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    /* Standard call to get message count and if count is 1, get message info. */
    FND_MSG_PUB.Count_And_Get
	    (p_count    =>   x_msg_count,
     	     p_data     =>   x_msg_data
             );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_salesrep_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_salesrep_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_salesrep_pvt;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

End Create_salesrep;

PROCEDURE create_salesrep_migrate(
   P_API_VERSION                    IN   NUMBER,
   P_INIT_MSG_LIST                  IN   VARCHAR2,
   P_COMMIT                         IN   VARCHAR2,
   P_RESOURCE_ID                    IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID           IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                           IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS                         IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE              IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE                IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_GL_ID_REV                      IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT                  IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC                      IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID                IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER                IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS                  IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE                 IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE              IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   P_ATTRIBUTE_CATEGORY             IN   JTF_RS_SALESREPS.ATTRIBUTE_CATEGORY%TYPE,
   P_ATTRIBUTE1                     IN   JTF_RS_SALESREPS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2                     IN   JTF_RS_SALESREPS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3                     IN   JTF_RS_SALESREPS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4                     IN   JTF_RS_SALESREPS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5                     IN   JTF_RS_SALESREPS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6                     IN   JTF_RS_SALESREPS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7                     IN   JTF_RS_SALESREPS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8                     IN   JTF_RS_SALESREPS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9                     IN   JTF_RS_SALESREPS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10                    IN   JTF_RS_SALESREPS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11                    IN   JTF_RS_SALESREPS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12                    IN   JTF_RS_SALESREPS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13                    IN   JTF_RS_SALESREPS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14                    IN   JTF_RS_SALESREPS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15                    IN   JTF_RS_SALESREPS.ATTRIBUTE15%TYPE,
   P_SALESREP_ID                    IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_ORG_ID			    IN   JTF_RS_SALESREPS.ORG_ID%TYPE,
   X_RETURN_STATUS                  OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT                      OUT NOCOPY  NUMBER,
   X_MSG_DATA                       OUT NOCOPY  VARCHAR2,
   X_SALESREP_ID                    OUT NOCOPY JTF_RS_SALESREPS.SALESREP_ID%TYPE
  ) IS

  BEGIN

     G_SRP_ID_PVT_FLAG   := 'N';

     jtf_rs_salesreps_pvt.create_salesrep (
     	P_API_VERSION          => P_API_VERSION,
   	P_INIT_MSG_LIST        => P_INIT_MSG_LIST,
   	P_COMMIT               => P_COMMIT,
   	P_RESOURCE_ID          => P_RESOURCE_ID,
   	P_SALES_CREDIT_TYPE_ID => P_SALES_CREDIT_TYPE_ID,
   	P_NAME                 => P_NAME,
   	P_STATUS               => P_STATUS,
   	P_START_DATE_ACTIVE    => P_START_DATE_ACTIVE,
   	P_END_DATE_ACTIVE      => P_END_DATE_ACTIVE,
   	P_GL_ID_REV            => P_GL_ID_REV,
   	P_GL_ID_FREIGHT        => P_GL_ID_FREIGHT,
   	P_GL_ID_REC            => P_GL_ID_REC,
   	P_SET_OF_BOOKS_ID      => P_SET_OF_BOOKS_ID,
   	P_SALESREP_NUMBER      => P_SALESREP_NUMBER,
   	P_EMAIL_ADDRESS        => P_EMAIL_ADDRESS,
   	P_WH_UPDATE_DATE       => P_WH_UPDATE_DATE,
   	P_SALES_TAX_GEOCODE    => P_SALES_TAX_GEOCODE,
   	P_SALES_TAX_INSIDE_CITY_LIMITS   => P_SALES_TAX_INSIDE_CITY_LIMITS ,
   	P_ATTRIBUTE_CATEGORY   => P_ATTRIBUTE_CATEGORY ,
   	P_ATTRIBUTE1           => P_ATTRIBUTE1,
   	P_ATTRIBUTE2           => P_ATTRIBUTE2,
   	P_ATTRIBUTE3           => P_ATTRIBUTE3,
   	P_ATTRIBUTE4           => P_ATTRIBUTE4,
   	P_ATTRIBUTE5           => P_ATTRIBUTE5,
   	P_ATTRIBUTE6           => P_ATTRIBUTE6,
   	P_ATTRIBUTE7           => P_ATTRIBUTE7,
   	P_ATTRIBUTE8           => P_ATTRIBUTE8,
   	P_ATTRIBUTE9           => P_ATTRIBUTE9,
   	P_ATTRIBUTE10          => P_ATTRIBUTE10,
   	P_ATTRIBUTE11          => P_ATTRIBUTE11,
   	P_ATTRIBUTE12          => P_ATTRIBUTE12,
   	P_ATTRIBUTE13          => P_ATTRIBUTE13,
   	P_ATTRIBUTE14          => P_ATTRIBUTE14,
   	P_ATTRIBUTE15          => P_ATTRIBUTE15,
   	X_RETURN_STATUS        => X_RETURN_STATUS,
   	X_MSG_COUNT            => X_MSG_COUNT,
   	X_MSG_DATA             => X_MSG_DATA,
   	X_SALESREP_ID          => X_SALESREP_ID
     );

  END create_salesrep_migrate;


PROCEDURE Update_salesrep(
   P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_SALESREP_ID          IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                 IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS               IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_GL_ID_REV            IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT        IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC            IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID      IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER      IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE       IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE    IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   P_ORG_ID               IN   JTF_RS_SALESREPS.ORG_ID%TYPE,
   P_OBJECT_VERSION_NUMBER      IN  OUT NOCOPY  JTF_RS_SALESREPS.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE_CATEGORY   IN    JTF_RS_SALESREPS.ATTRIBUTE_CATEGORY%TYPE,
   P_ATTRIBUTE1           IN    JTF_RS_SALESREPS.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2           IN    JTF_RS_SALESREPS.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3           IN    JTF_RS_SALESREPS.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4           IN    JTF_RS_SALESREPS.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5           IN    JTF_RS_SALESREPS.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6           IN    JTF_RS_SALESREPS.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7           IN    JTF_RS_SALESREPS.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8           IN    JTF_RS_SALESREPS.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9           IN    JTF_RS_SALESREPS.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10          IN    JTF_RS_SALESREPS.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11          IN    JTF_RS_SALESREPS.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12          IN    JTF_RS_SALESREPS.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13          IN    JTF_RS_SALESREPS.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14          IN    JTF_RS_SALESREPS.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15          IN    JTF_RS_SALESREPS.ATTRIBUTE15%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY VARCHAR2
    )
 IS

    l_api_name                 CONSTANT VARCHAR2(30) := 'UPDATE_SALESREP';
    l_api_version              CONSTANT NUMBER   := 1.0;
    l_rowid                             ROWID;
    l_salesrep_id                       jtf_rs_salesreps.salesrep_id%type := p_salesrep_id;
    l_resource_id                       jtf_rs_salesreps.resource_id%type;
    l_sales_credit_type_id              jtf_rs_salesreps.sales_credit_type_id%type := p_sales_credit_type_id
;
    l_name                              jtf_rs_salesreps.name%type := p_name;
    l_status                            jtf_rs_salesreps.status%type := p_status;
    l_start_date_active                 jtf_rs_salesreps.start_date_active%type := p_start_date_active;
    l_end_date_active                   jtf_rs_salesreps.end_date_active%type := p_end_date_active;
    l_gl_id_rev                         jtf_rs_salesreps.gl_id_rev%type := p_gl_id_rev;
    l_gl_id_freight                     jtf_rs_salesreps.gl_id_freight%type := p_gl_id_freight;
    l_gl_id_rec                         jtf_rs_salesreps.gl_id_rec%type := p_gl_id_rec;
    l_set_of_books_id                   jtf_rs_salesreps.set_of_books_id%type := p_set_of_books_id;
    l_salesrep_number                   jtf_rs_salesreps.salesrep_number%type := p_salesrep_number;
    l_email_address                     jtf_rs_salesreps.email_address%type := p_email_address;
    l_wh_update_date                    jtf_rs_salesreps.wh_update_date%type := p_wh_update_date;
    l_sales_tax_geocode                 jtf_rs_salesreps.sales_tax_geocode%type := p_sales_tax_geocode;
    l_sales_tax_inside_city_limits      jtf_rs_salesreps.sales_tax_inside_city_limits%type := p_sales_tax_inside_city_limits;
    l_org_id                            jtf_rs_salesreps.org_id%type := p_org_id;
    l_object_version_number             jtf_rs_salesreps.object_version_number%type := p_object_version_number;
    c_val                  		varchar2(1);
    l_msg_data                          VARCHAR2(2000);
    x_var				varchar2(1);
    l_msg_count                         NUMBER;
    l_bind_data_id                      NUMBER;

    CURSOR c_salesrep_update(l_salesrep_id jtf_rs_salesreps.salesrep_id%type, l_org_id jtf_rs_salesreps.org_id%type) is
         SELECT salesrep_id,
 		resource_id,
 		DECODE(p_sales_credit_type_id,fnd_api.g_miss_num,sales_credit_type_id,p_sales_credit_type_id) sales_credit_type_id,
 		DECODE(p_name,fnd_api.g_miss_char,name,p_name) name,
 		DECODE(p_status,fnd_api.g_miss_char,status,p_status) status,
 		DECODE(p_start_date_active,fnd_api.g_miss_date,start_date_active,p_start_date_active) start_date_active,
 		DECODE(p_end_date_active,fnd_api.g_miss_date,end_date_active,p_end_date_active) end_date_active,
 		DECODE(p_gl_id_rev,fnd_api.g_miss_num,gl_id_rev,p_gl_id_rev) gl_id_rev,
 		DECODE(p_gl_id_freight,fnd_api.g_miss_num,gl_id_freight,p_gl_id_freight) gl_id_freight,
 		DECODE(p_gl_id_rec,fnd_api.g_miss_num,gl_id_rec,p_gl_id_rec) gl_id_rec,
 		DECODE(p_set_of_books_id,fnd_api.g_miss_num,set_of_books_id,p_set_of_books_id) set_of_books_id,
 		DECODE(p_salesrep_number,fnd_api.g_miss_char,salesrep_number,p_salesrep_number) salesrep_number,
 		DECODE(p_email_address,fnd_api.g_miss_char,email_address,p_email_address) email_address,
 		DECODE(p_wh_update_date,fnd_api.g_miss_date,wh_update_date,p_wh_update_date) wh_update_date,
 		person_id,
 		DECODE(p_sales_tax_geocode,fnd_api.g_miss_char,sales_tax_geocode,p_sales_tax_geocode) sales_tax_geocode,
 		DECODE(p_sales_tax_inside_city_limits,fnd_api.g_miss_char,sales_tax_inside_city_limits,p_sales_tax_inside_city_limits) sales_tax_inside_city_limits,
                org_id,
 		DECODE(p_object_version_number,fnd_api.g_miss_char,object_version_number,p_object_version_number) object_version_number,
 		DECODE(p_attribute_category,fnd_api.g_miss_char,attribute_category,p_attribute_category) attribute_category,
 		DECODE(p_attribute1,fnd_api.g_miss_char,attribute1,p_attribute1) attribute1,
 		DECODE(p_attribute2,fnd_api.g_miss_char,attribute2,p_attribute2) attribute2,
 		DECODE(p_attribute3,fnd_api.g_miss_char,attribute3,p_attribute3) attribute3,
 		DECODE(p_attribute4,fnd_api.g_miss_char,attribute4,p_attribute4) attribute4,
 		DECODE(p_attribute5,fnd_api.g_miss_char,attribute5,p_attribute5) attribute5,
 		DECODE(p_attribute6,fnd_api.g_miss_char,attribute6,p_attribute6) attribute6,
 		DECODE(p_attribute7,fnd_api.g_miss_char,attribute7,p_attribute7) attribute7,
 		DECODE(p_attribute8,fnd_api.g_miss_char,attribute8,p_attribute8) attribute8,
 		DECODE(p_attribute9,fnd_api.g_miss_char,attribute9,p_attribute9) attribute9,
 		DECODE(p_attribute10,fnd_api.g_miss_char,attribute10,p_attribute10) attribute10,
 		DECODE(p_attribute11,fnd_api.g_miss_char,attribute11,p_attribute11) attribute11,
 		DECODE(p_attribute12,fnd_api.g_miss_char,attribute12,p_attribute12) attribute12,
 		DECODE(p_attribute13,fnd_api.g_miss_char,attribute13,p_attribute13) attribute13,
 		DECODE(p_attribute14,fnd_api.g_miss_char,attribute14,p_attribute14) attribute14,
 		DECODE(p_attribute15,fnd_api.g_miss_char,attribute15,p_attribute15) attribute15
         FROM   jtf_rs_salesreps
         WHERE  salesrep_id = l_salesrep_id
         AND    nvl(org_id,-99) = nvl(l_org_id,-99);
     salesrep_rec	c_salesrep_update%ROWTYPE;

      CURSOR c_salesrep_number IS
      SELECT 'X'
      FROM   jtf_rs_salesreps
      WHERE  salesrep_number = l_salesrep_number
      AND nvl(org_id,-99) = nvl(l_org_id,-99)
      AND salesrep_id <> p_salesrep_id;


 BEGIN


    SAVEPOINT update_salesrep_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

    /*  Standard call to check for call compatibility. */
    IF NOT fnd_api.Compatible_api_call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_Boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;


--    dbms_output.put_line('Org id before validation : '||  l_org_id);
    l_org_id := MO_GLOBAL.get_valid_org(p_org_id);
    IF l_org_id is NULL THEN
--       dbms_output.put_line('Org id is Null');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
--    dbms_output.put_line('Org id is : '||l_org_id);

    /* Make the pre processing call to the user hooks */

    /* Pre Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'UPDATE_SALESREP',
         'B',
         'C')
    THEN
      jtf_rs_salesreps_cuhk.update_salesrep_pre(
	 p_salesrep_id                  => l_salesrep_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_CUST_USR_HOOK');
         fnd_msg_pub.add;
	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;

    /* Pre Call to the Vertical Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'UPDATE_SALESREP',
         'B',
         'V')
    THEN

      jtf_rs_salesreps_vuhk.update_salesrep_pre(
	 p_salesrep_id                  => l_salesrep_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_VERT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;


    /* Pre Call to the Internal Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'UPDATE_SALESREP',
         'B',
         'I')
    THEN

      jtf_rs_salesreps_iuhk.update_salesrep_pre(
	 p_salesrep_id                  => l_salesrep_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_PRE_INT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;


    /*  Starting API body */


    OPEN   c_salesrep_update(l_salesrep_id,l_org_id);
    FETCH  c_salesrep_update INTO salesrep_rec;

    IF c_salesrep_update%NOTFOUND THEN
	CLOSE c_salesrep_update;
        fnd_message.set_name('JTF','JTF_RS_INVALID_SALESREP_ID');
        fnd_message.set_token('P_SALESREP_ID',l_salesrep_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

    END IF;


   /*  Validating Dates */


    jtf_resource_utl.validate_input_dates(
                 l_start_date_active
                ,l_end_date_active
                ,x_return_status);
    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

   /* Record is being updated, check that salesrep number does not already exist, for any other salesrep Id */
    IF (l_salesrep_number IS NOT NULL) THEN
      OPEN c_salesrep_number;
      FETCH c_salesrep_number INTO c_val;
      IF (c_salesrep_number%FOUND) THEN
        fnd_message.set_name('JTF', 'JTF_RS_ERR_SALESREP_NUMBER');
        fnd_message.set_token('P_SALESREP_NUMBER', l_salesrep_number);
        fnd_msg_pub.add;
        CLOSE c_salesrep_number;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_salesrep_number;
    ELSE
      fnd_message.set_name('JTF', 'JTF_RS_SALESREP_NUMBER_NULL');
      fnd_msg_pub.add;
      CLOSE c_salesrep_number;
      RAISE fnd_api.g_exc_error;

   END IF;

   /* Locking the row before updating */
    BEGIN
	jtf_rs_salesreps_pkg.lock_row(
		x_salesrep_id => l_salesrep_id,
		x_org_id => l_org_id,
		x_object_version_number => l_object_version_number
                );
    EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;


    BEGIN

    /* Increment Object version number */

    l_object_version_number := l_object_version_number + 1;

    /* Invoke table handler to insert into JTF_RS__SALESREPS  */

    jtf_rs_salesreps_pkg.update_row(
	 X_SALESREP_ID                  => l_salesrep_id,
         X_RESOURCE_ID                  => salesrep_rec.resource_id,
         X_SALES_CREDIT_TYPE_ID         => salesrep_rec.sales_credit_type_id,
         X_NAME                         => salesrep_rec.name,
         X_STATUS                       => salesrep_rec.status,
         X_START_DATE_ACTIVE            => salesrep_rec.start_date_active,
         X_END_DATE_ACTIVE              => salesrep_rec.end_date_active,
         X_GL_ID_REV                    => salesrep_rec.gl_id_rev,
         X_GL_ID_FREIGHT                => salesrep_rec.gl_id_freight,
         X_GL_ID_REC                    => salesrep_rec.gl_id_rec,
         X_SET_OF_BOOKS_ID              => salesrep_rec.set_of_books_id,
         X_SALESREP_NUMBER              => salesrep_rec.salesrep_number,
         X_EMAIL_ADDRESS                => salesrep_rec.email_address,
         X_WH_UPDATE_DATE               => salesrep_rec.wh_update_date,
         X_PERSON_ID                    => salesrep_rec.person_id,
         X_SALES_TAX_GEOCODE            => salesrep_rec.sales_tax_geocode,
         X_SALES_TAX_INSIDE_CITY_LIMITS => salesrep_rec.sales_tax_inside_city_limits,
         X_ORG_ID                       => l_org_id,
         X_OBJECT_VERSION_NUMBER        => l_object_version_number,
         X_ATTRIBUTE_CATEGORY           => salesrep_rec.attribute_category,
         X_ATTRIBUTE2                   => salesrep_rec.attribute2,
         X_ATTRIBUTE3                   => salesrep_rec.attribute3,
         X_ATTRIBUTE4                   => salesrep_rec.attribute4,
         X_ATTRIBUTE5                   => salesrep_rec.attribute5,
         X_ATTRIBUTE6                   => salesrep_rec.attribute6,
         X_ATTRIBUTE7                   => salesrep_rec.attribute7,
         X_ATTRIBUTE8                   => salesrep_rec.attribute8,
         X_ATTRIBUTE9                   => salesrep_rec.attribute9,
         X_ATTRIBUTE10                  => salesrep_rec.attribute10,
         X_ATTRIBUTE11                  => salesrep_rec.attribute11,
         X_ATTRIBUTE12                  => salesrep_rec.attribute12,
         X_ATTRIBUTE13                  => salesrep_rec.attribute13,
         X_ATTRIBUTE14                  => salesrep_rec.attribute14,
         X_ATTRIBUTE15                  => salesrep_rec.attribute15,
         X_ATTRIBUTE1                   => salesrep_rec.attribute1,
         X_LAST_UPDATE_DATE             => SYSDATE,
         X_LAST_UPDATED_BY              => jtf_resource_utl.updated_by,
         X_LAST_UPDATE_LOGIN            => jtf_resource_utl.login_id
        );

    p_object_version_number := l_object_version_number;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
/*        dbms_output.put_line('Error in Table Haandler'); */
        CLOSE c_salesrep_update;

        fnd_message.set_name('JTF', 'JTF_RS_TABLE_HANDLER_ERROR');
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;

    END;

    CLOSE c_salesrep_update;

    /* Make the post processing call to the user hooks */

    /* Post Call to the Customer Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'UPDATE_SALESREP',
         'A',
         'C')
    THEN
      jtf_rs_salesreps_cuhk.update_salesrep_post(
	 p_salesrep_id                  => l_salesrep_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_CUST_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;

    /* Post Call to the Vertical Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'UPDATE_SALESREP',
         'A',
         'V')
    THEN
      jtf_rs_salesreps_vuhk.update_salesrep_post(
	 p_salesrep_id                  => l_salesrep_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_VERT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;

    /* Post Call to the Internal Type User Hook */

    IF jtf_usr_hks.ok_to_execute(
         'JTF_RS_SALESREPS_PVT',
         'UPDATE_SALESREP',
         'A',
         'I')
    THEN
      jtf_rs_salesreps_iuhk.update_salesrep_post(
	 p_salesrep_id                  => l_salesrep_id,
	 p_sales_credit_type_id         => l_sales_credit_type_id,
	 p_name                         => l_name,
	 p_status                       => l_status,
 	 p_start_date_active            => l_start_date_active,
	 p_end_date_active              => l_end_date_active,
	 p_gl_id_rev                    => l_gl_id_rev,
	 p_gl_id_freight                => l_gl_id_freight,
	 p_gl_id_rec                    => l_gl_id_rec,
	 p_set_of_books_id              => l_set_of_books_id,
	 p_salesrep_number              => l_salesrep_number,
	 p_email_address                => l_email_address,
	 p_wh_update_date               => l_wh_update_date,
	 p_sales_tax_geocode            => l_sales_tax_geocode,
	 p_sales_tax_inside_city_limits => l_sales_tax_inside_city_limits,
         x_return_status                => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN

         fnd_message.set_name('JTF', 'JTF_RS_ERR_POST_INT_USR_HOOK');
         fnd_msg_pub.add;

	 IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    END IF;

    /* Standard call for Message Generation */

    IF jtf_usr_hks.ok_to_execute(
	 'JTF_RS_SALESREPS_PVT',
	 'UPDATE_SALESREP',
	 'M',
	 'M')
    THEN

      IF (jtf_rs_salesreps_cuhk.ok_to_generate_msg(
	       p_salesrep_id => l_salesrep_id,
	       x_return_status => x_return_status) )
      THEN

        /* Get the bind data id for the Business Object Instance */

        l_bind_data_id := jtf_usr_hks.get_bind_data_id;


        /* Set bind values for the bind variables in the Business Object SQL */

        jtf_usr_hks.load_bind_data(l_bind_data_id, 'salesrep_id', l_salesrep_id, 'S', 'N');


        /* Call the message generation API */

        jtf_usr_hks.generate_message(
		p_prod_code => 'JTF',
		p_bus_obj_code => 'RS_SRP',
		p_action_code => 'D',
		p_bind_data_id => l_bind_data_id,
		x_return_code => x_return_status);


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN


	     fnd_message.set_name('JTF', 'JTF_RS_ERR_MESG_GENERATE_API');
	     fnd_msg_pub.add;

	     IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	     ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;


        END IF;

      END IF;

    END IF;

    IF fnd_api.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    /* Standard call to get message count and if count is 1, get message info. */
    FND_MSG_PUB.Count_And_Get
            (p_count    =>   x_msg_count,
             p_data     =>   x_msg_data
             );

    EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_salesrep_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_salesrep_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_salesrep_pvt;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

End update_salesrep;

End JTF_RS_SALESREPS_PVT;

/
