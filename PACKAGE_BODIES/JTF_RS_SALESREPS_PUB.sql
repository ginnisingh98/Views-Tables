--------------------------------------------------------
--  DDL for Package Body JTF_RS_SALESREPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SALESREPS_PUB" AS
/* $Header: jtfrspsb.pls 120.4 2005/10/17 17:18:37 nsinghai ship $ */

  /*****************************************************************************************
   This package body defines the procedures for managing Salesreps , like
   create and update Salesreps.
   Its main procedures are as following:
   Create Salesreps
   Update Salesreps
   This package valoidates the input parameters to these procedures and then
   to do business validations and to do actual inserts and updates into tables.
   ******************************************************************************************/

  /* Package Varianles  */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_SALESREPS_PUB';

  /* Procedure to create the Salesreps
	based on input values passed by calling routines. */

  PROCEDURE  create_salesrep
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                 IN   JTF_RS_SALESREPS.NAME%TYPE                DEFAULT NULL,
   P_STATUS               IN   JTF_RS_SALESREPS.STATUS%TYPE              DEFAULT NULL,
   P_START_DATE_ACTIVE    IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE   DEFAULT SYSDATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE     DEFAULT NULL,
   P_ORG_ID               IN   JTF_RS_SALESREPS.ORG_ID%TYPE              DEFAULT FND_API.G_MISS_NUM,
   P_GL_ID_REV            IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE           DEFAULT NULL,
   P_GL_ID_FREIGHT        IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE       DEFAULT NULL,
   P_GL_ID_REC            IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE           DEFAULT NULL,
   P_SET_OF_BOOKS_ID      IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE     DEFAULT NULL,
   P_SALESREP_NUMBER      IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE     DEFAULT NULL,
   P_EMAIL_ADDRESS        IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE       DEFAULT NULL,
   P_WH_UPDATE_DATE       IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE      DEFAULT NULL,
   P_SALES_TAX_GEOCODE    IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE   DEFAULT NULL,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE   DEFAULT NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_SALESREP_ID    	  OUT NOCOPY  JTF_RS_SALESREPS.SALESREP_ID%TYPE
  ) IS

    l_api_version              CONSTANT NUMBER := 1.0;
    l_api_name                 CONSTANT VARCHAR2(30) := 'CREATE_SALESREP';
    l_resource_id                       jtf_rs_salesreps.resource_id%type := p_resource_id;
    l_sales_credit_type_id              jtf_rs_salesreps.sales_credit_type_id%type := p_sales_credit_type_id;
    l_name                              jtf_rs_salesreps.name%type := p_name;
    l_status                            jtf_rs_salesreps.status%type := p_status;
    l_start_date_active                 jtf_rs_salesreps.start_date_active%type := p_start_date_active;
    l_end_date_active                   jtf_rs_salesreps.end_date_active%type := p_end_date_active;
    l_org_id                             jtf_rs_salesreps.org_id%type := p_org_id;
    l_gl_id_rev                         jtf_rs_salesreps.gl_id_rev%type := p_gl_id_rev;
    l_gl_id_freight                     jtf_rs_salesreps.gl_id_freight%type := p_gl_id_freight;
    l_gl_id_rec                         jtf_rs_salesreps.gl_id_rec%type := p_gl_id_rec;
    l_set_of_books_id                   jtf_rs_salesreps.set_of_books_id%type := p_set_of_books_id;
    l_salesrep_number                   jtf_rs_salesreps.salesrep_number%type := p_salesrep_number;
    l_email_address                     jtf_rs_salesreps.email_address%type := p_email_address;
    l_wh_update_date                    jtf_rs_salesreps.wh_update_date%type := p_wh_update_date;
    l_sales_tax_geocode                 jtf_rs_salesreps.sales_tax_geocode%type := p_sales_tax_geocode;
    l_sales_tax_inside_city_limits      jtf_rs_salesreps.sales_tax_inside_city_limits%type := p_sales_tax_inside_city_limits;
 -- added for NOCOPY
    l_resource_id_out                       jtf_rs_salesreps.resource_id%type;

  BEGIN

    SAVEPOINT create_salesreps_pub;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;


    /* Validate Resource */

    jtf_resource_utl.validate_resource_number(
       p_resource_id => l_resource_id,
       p_resource_number => NULL,
       x_return_status => x_return_status,
       x_resource_id => l_resource_id_out);
-- added for NOCOPY
    l_resource_id := l_resource_id_out;


    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;


    /* Validate Sales Credit type Id */

    jtf_resource_utl.validate_sales_credit_type(
       p_sales_credit_type_id => l_sales_credit_type_id,
       x_return_status => x_return_status
       );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /*  Validate start date */
/*
    IF l_start_date_active IS NULL THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;
*/

    /*
      Validate Salesrep dates
      Created by Nishant on 17-Oct-2005 to fix bug 4354269. It will validate both
	  start date and end date against resource start date and end date.
    */
    jtf_resource_utl.validate_salesrep_dates
       (P_ID              => l_resource_id,
        P_ORG_ID		  => l_org_id,
        P_SRP_START_DATE  => l_start_date_active,
        P_SRP_END_DATE    => l_end_date_active,
        P_CR_UPD_MODE     => 'C',
        X_RETURN_STATUS   => x_return_status);

     IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	   RAISE FND_API.G_EXC_ERROR;
	 END IF;

    /* Check the Global Variable for SalesrepID, and call the appropriate Private API */

--   dbms_output.put_line ('Before setting the global flag in create_resource');

      IF G_SRP_ID_PUB_FLAG = 'Y' THEN

--   dbms_output.put_line ('After setting the global flag in create_resource');


         /* Calling Private API to insert salesrep */

         jtf_rs_salesreps_pvt.create_salesrep(
	    P_API_VERSION          =>   1,
	    P_INIT_MSG_LIST        =>   fnd_api.g_false,
	    P_COMMIT               =>   fnd_api.g_false,
	    P_RESOURCE_ID          =>   l_resource_id,
	    P_SALES_CREDIT_TYPE_ID =>   l_sales_credit_type_id,
	    P_NAME                 =>   l_name,
	    P_STATUS               =>   l_status,
	    P_START_DATE_ACTIVE    =>   l_start_date_active,
	    P_END_DATE_ACTIVE      =>   l_end_date_active,
            P_ORG_ID               =>   l_org_id,
	    P_GL_ID_REV            =>   l_gl_id_rev,
	    P_GL_ID_FREIGHT        =>   l_gl_id_freight,
	    P_GL_ID_REC            =>   l_gl_id_rec,
	    P_SET_OF_BOOKS_ID      =>   l_set_of_books_id,
	    P_SALESREP_NUMBER      =>   l_salesrep_number,
	    P_EMAIL_ADDRESS        =>   l_email_address,
	    P_WH_UPDATE_DATE       =>   l_wh_update_date,
	    P_SALES_TAX_GEOCODE    =>   l_sales_tax_geocode,
	    P_SALES_TAX_INSIDE_CITY_LIMITS   =>   l_sales_tax_inside_city_limits,
	    X_RETURN_STATUS        =>  x_return_status,
	    X_MSG_COUNT            =>  x_msg_count,
	    X_MSG_DATA             =>  x_msg_data,
	    X_SALESREP_ID          =>  x_salesrep_id
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
         END IF;

      ELSE

         /* Call the private procedure for Migration. */
         jtf_rs_salesreps_pvt.create_salesrep_migrate(
            P_API_VERSION          =>   1,
            P_INIT_MSG_LIST        =>   fnd_api.g_false,
            P_COMMIT               =>   fnd_api.g_false,
            P_RESOURCE_ID          =>   l_resource_id,
            P_SALES_CREDIT_TYPE_ID =>   l_sales_credit_type_id,
            P_NAME                 =>   l_name,
            P_STATUS               =>   l_status,
            P_START_DATE_ACTIVE    =>   l_start_date_active,
            P_END_DATE_ACTIVE      =>   l_end_date_active,
            P_GL_ID_REV            =>   l_gl_id_rev,
            P_GL_ID_FREIGHT        =>   l_gl_id_freight,
            P_GL_ID_REC            =>   l_gl_id_rec,
            P_SET_OF_BOOKS_ID      =>   l_set_of_books_id,
            P_SALESREP_NUMBER      =>   l_salesrep_number,
            P_EMAIL_ADDRESS        =>   l_email_address,
            P_WH_UPDATE_DATE       =>   l_wh_update_date,
            P_SALES_TAX_GEOCODE    =>   l_sales_tax_geocode,
            P_SALES_TAX_INSIDE_CITY_LIMITS   =>   l_sales_tax_inside_city_limits,
            P_SALESREP_ID	   =>  G_SALESREP_ID,
            P_ORG_ID		   =>  G_ORG_ID,
            P_ATTRIBUTE1           =>  G_ATTRIBUTE1,
            P_ATTRIBUTE2           =>  G_ATTRIBUTE2,
            P_ATTRIBUTE3           =>  G_ATTRIBUTE3,
            P_ATTRIBUTE4           =>  G_ATTRIBUTE4,
            P_ATTRIBUTE5           =>  G_ATTRIBUTE5,
            P_ATTRIBUTE6           =>  G_ATTRIBUTE6,
            P_ATTRIBUTE7           =>  G_ATTRIBUTE7,
            P_ATTRIBUTE8           =>  G_ATTRIBUTE8,
            P_ATTRIBUTE9           =>  G_ATTRIBUTE9,
            P_ATTRIBUTE10          =>  G_ATTRIBUTE10,
            P_ATTRIBUTE11          =>  G_ATTRIBUTE11,
            P_ATTRIBUTE12          =>  G_ATTRIBUTE12,
            P_ATTRIBUTE13          =>  G_ATTRIBUTE13,
            P_ATTRIBUTE14          =>  G_ATTRIBUTE14,
            P_ATTRIBUTE15          =>  G_ATTRIBUTE15,
            P_ATTRIBUTE_CATEGORY   =>  G_ATTRIBUTE_CATEGORY,
            X_RETURN_STATUS        =>  x_return_status,
            X_MSG_COUNT            =>  x_msg_count,
            X_MSG_DATA             =>  x_msg_data,
            X_SALESREP_ID          =>  x_salesrep_id
         );
         IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	   IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      ROLLBACK TO create_salesreps_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_salesreps_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_salesreps_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END create_salesrep;


  PROCEDURE  create_salesrep_migrate
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                 IN   JTF_RS_SALESREPS.NAME%TYPE                DEFAULT NULL,
   P_STATUS               IN   JTF_RS_SALESREPS.STATUS%TYPE              DEFAULT NULL,
   P_START_DATE_ACTIVE    IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE   DEFAULT SYSDATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE     DEFAULT NULL,
   P_GL_ID_REV            IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE           DEFAULT NULL,
   P_GL_ID_FREIGHT        IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE       DEFAULT NULL,
   P_GL_ID_REC            IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE           DEFAULT NULL,
   P_SET_OF_BOOKS_ID      IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE     DEFAULT NULL,
   P_SALESREP_NUMBER      IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE     DEFAULT NULL,
   P_EMAIL_ADDRESS        IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE       DEFAULT NULL,
   P_WH_UPDATE_DATE       IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE      DEFAULT NULL,
   P_SALES_TAX_GEOCODE    IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE   DEFAULT NULL,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE   DEFAULT NULL,
   P_SALESREP_ID	  IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_ORG_ID		  IN   JTF_RS_SALESREPS.ORG_ID%TYPE,
   P_ATTRIBUTE_CATEGORY   IN   JTF_RS_SALESREPS.ATTRIBUTE_CATEGORY%TYPE  DEFAULT NULL,
   P_ATTRIBUTE1           IN   JTF_RS_SALESREPS.ATTRIBUTE1%TYPE          DEFAULT NULL,
   P_ATTRIBUTE2           IN   JTF_RS_SALESREPS.ATTRIBUTE2%TYPE          DEFAULT NULL,
   P_ATTRIBUTE3           IN   JTF_RS_SALESREPS.ATTRIBUTE3%TYPE          DEFAULT NULL,
   P_ATTRIBUTE4           IN   JTF_RS_SALESREPS.ATTRIBUTE4%TYPE          DEFAULT NULL,
   P_ATTRIBUTE5           IN   JTF_RS_SALESREPS.ATTRIBUTE5%TYPE          DEFAULT NULL,
   P_ATTRIBUTE6           IN   JTF_RS_SALESREPS.ATTRIBUTE6%TYPE          DEFAULT NULL,
   P_ATTRIBUTE7           IN   JTF_RS_SALESREPS.ATTRIBUTE7%TYPE          DEFAULT NULL,
   P_ATTRIBUTE8           IN   JTF_RS_SALESREPS.ATTRIBUTE8%TYPE          DEFAULT NULL,
   P_ATTRIBUTE9           IN   JTF_RS_SALESREPS.ATTRIBUTE9%TYPE          DEFAULT NULL,
   P_ATTRIBUTE10          IN   JTF_RS_SALESREPS.ATTRIBUTE10%TYPE         DEFAULT NULL,
   P_ATTRIBUTE11          IN   JTF_RS_SALESREPS.ATTRIBUTE11%TYPE         DEFAULT NULL,
   P_ATTRIBUTE12          IN   JTF_RS_SALESREPS.ATTRIBUTE12%TYPE         DEFAULT NULL,
   P_ATTRIBUTE13          IN   JTF_RS_SALESREPS.ATTRIBUTE13%TYPE         DEFAULT NULL,
   P_ATTRIBUTE14          IN   JTF_RS_SALESREPS.ATTRIBUTE14%TYPE         DEFAULT NULL,
   P_ATTRIBUTE15          IN   JTF_RS_SALESREPS.ATTRIBUTE15%TYPE         DEFAULT NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_SALESREP_ID          OUT NOCOPY  JTF_RS_SALESREPS.SALESREP_ID%TYPE
  ) IS

    BEGIN

--dbms_output.put_line ('Inside the create_salesrep_migrate pub body');

     JTF_RS_SALESREPS_PUB.G_SRP_ID_PUB_FLAG      := 'N';
     JTF_RS_SALESREPS_PUB.G_SALESREP_ID          := P_SALESREP_ID;
     JTF_RS_SALESREPS_PUB.G_ORG_ID		 := P_ORG_ID;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE1		 := P_ATTRIBUTE1;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE2           := P_ATTRIBUTE2;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE3           := P_ATTRIBUTE3;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE4           := P_ATTRIBUTE4;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE5           := P_ATTRIBUTE5;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE6           := P_ATTRIBUTE6;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE7           := P_ATTRIBUTE7;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE8           := P_ATTRIBUTE8;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE9           := P_ATTRIBUTE9;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE10          := P_ATTRIBUTE10;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE11          := P_ATTRIBUTE11;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE12          := P_ATTRIBUTE12;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE13          := P_ATTRIBUTE13;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE14          := P_ATTRIBUTE14;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE15          := P_ATTRIBUTE15;
     JTF_RS_SALESREPS_PUB.G_ATTRIBUTE_CATEGORY   := P_ATTRIBUTE_CATEGORY;

--dbms_output.put_line ('After assigning values to the Global variables');

     jtf_rs_salesreps_pub.create_salesrep (
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
   	P_SALES_TAX_INSIDE_CITY_LIMITS => P_SALES_TAX_INSIDE_CITY_LIMITS,
   	X_RETURN_STATUS        => X_RETURN_STATUS,
   	X_MSG_COUNT            => X_MSG_COUNT,
   	X_MSG_DATA             => X_MSG_DATA,
   	X_SALESREP_ID          => X_SALESREP_ID
     );

  END create_salesrep_migrate;

  /* Procedure to update the Salesreps
	based on input values passed by calling routines. */

  PROCEDURE  update_salesrep
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_SALESREP_ID    	  IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                 IN   JTF_RS_SALESREPS.NAME%TYPE                     DEFAULT  FND_API.G_MISS_CHAR,
   P_STATUS               IN   JTF_RS_SALESREPS.STATUS%TYPE                   DEFAULT  FND_API.G_MISS_CHAR,
   P_START_DATE_ACTIVE    IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE        DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE          DEFAULT  FND_API.G_MISS_DATE,
   P_GL_ID_REV            IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE                DEFAULT  FND_API.G_MISS_NUM,
   P_GL_ID_FREIGHT        IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE            DEFAULT  FND_API.G_MISS_NUM,
   P_GL_ID_REC            IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE                DEFAULT  FND_API.G_MISS_NUM,
   P_SET_OF_BOOKS_ID      IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE          DEFAULT  FND_API.G_MISS_NUM,
   P_SALESREP_NUMBER      IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE          DEFAULT  FND_API.G_MISS_CHAR,
   P_EMAIL_ADDRESS        IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE            DEFAULT  FND_API.G_MISS_CHAR,
   P_WH_UPDATE_DATE       IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE           DEFAULT  FND_API.G_MISS_DATE,
   P_SALES_TAX_GEOCODE    IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE        DEFAULT  FND_API.G_MISS_CHAR,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE   DEFAULT  FND_API.G_MISS_CHAR,
   P_ORG_ID	          IN   JTF_RS_SALESREPS.ORG_ID%TYPE,
   P_OBJECT_VERSION_NUMBER	IN  OUT NOCOPY  JTF_RS_SALESREPS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_SALESREP';
    l_salesrep_id                       jtf_rs_salesreps.salesrep_id%type := p_salesrep_id;
    l_sales_credit_type_id              jtf_rs_salesreps.sales_credit_type_id%type := p_sales_credit_type_id;
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


  BEGIN

    SAVEPOINT update_salesreps_pub;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;


    /* Validate Salesrep */

    jtf_resource_utl.validate_salesrep_id(
       p_salesrep_id => l_salesrep_id,
       p_org_id => l_org_id,
       x_return_status => x_return_status
       );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* Validate Sales Credit type Id */

    jtf_resource_utl.validate_sales_credit_type(
       p_sales_credit_type_id => l_sales_credit_type_id,
       x_return_status => x_return_status
       );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /*  Validate start date */
/*
    IF l_start_date_active IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;
*/

    /*
      Validate Salesrep dates
      Created by Nishant on 17-Oct-2005 to fix bug 4354269. It will validate both
	  start date and end date against resource start date and end date.
    */
    jtf_resource_utl.validate_salesrep_dates
       (P_ID              => l_salesrep_id,
        P_ORG_ID		  => l_org_id,
        P_SRP_START_DATE  => l_start_date_active,
        P_SRP_END_DATE    => l_end_date_active,
        P_CR_UPD_MODE     => 'U',
        X_RETURN_STATUS   => x_return_status);

     IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
	   RAISE FND_API.G_EXC_ERROR;
	 END IF;

    /* Calling Private API to insert salesrep */
    jtf_rs_salesreps_pvt.update_salesrep(
	P_API_VERSION          =>   1,
	P_INIT_MSG_LIST        =>   fnd_api.g_false,
	P_COMMIT               =>   fnd_api.g_false,
	P_SALESREP_ID          =>   l_salesrep_id,
	P_SALES_CREDIT_TYPE_ID =>   l_sales_credit_type_id,
	P_NAME                 =>   l_name,
	P_STATUS               =>   l_status,
	P_START_DATE_ACTIVE    =>   l_start_date_active,
	P_END_DATE_ACTIVE      =>   l_end_date_active,
	P_GL_ID_REV            =>   l_gl_id_rev,
	P_GL_ID_FREIGHT        =>   l_gl_id_freight,
	P_GL_ID_REC            =>   l_gl_id_rec,
	P_SET_OF_BOOKS_ID      =>   l_set_of_books_id,
	P_SALESREP_NUMBER      =>   l_salesrep_number,
	P_EMAIL_ADDRESS        =>   l_email_address,
	P_WH_UPDATE_DATE       =>   l_wh_update_date,
	P_SALES_TAX_GEOCODE    =>   l_sales_tax_geocode,
	P_SALES_TAX_INSIDE_CITY_LIMITS   =>   l_sales_tax_inside_city_limits,
	P_ORG_ID               =>  l_org_id,
	P_OBJECT_VERSION_NUMBER =>  l_object_version_number,
	X_RETURN_STATUS        =>  x_return_status,
	X_MSG_COUNT            =>  x_msg_count,
	X_MSG_DATA             =>  x_msg_data
       );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      ROLLBACK TO update_salesreps_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_salesreps_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_salesreps_pub;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END update_salesrep;


END JTF_RS_SALESREPS_PUB;

/
