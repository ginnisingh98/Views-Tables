--------------------------------------------------------
--  DDL for Package JTF_RS_SALESREPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SALESREPS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspss.pls 120.3 2005/07/19 18:56:53 repuri ship $ */
/*#
 * Salesperson create and update API
 * This API contains the procedures to insert and update Salesrep record.
 * @rep:scope public
 * @rep:product JTF
 * @rep:displayname Salespersons API
 * @rep:category BUSINESS_ENTITY JTF_RS_SALESREP
*/
  /*****************************************************************************************
   This is a public API that caller will invoke.
   It provides procedures for managing Salesreps, like
   create and update Salesreps from other modules.
   Its main procedures are as following:
   Create Salesreps
   Update Salesreps
   ******************************************************************************************/


  /* Procedure to create the Salesreps
	based on input values passed by calling routines. */
/*#
 * Create Salesreps API
 * This procedure allows the user to create a salesrep record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_sales_credit_type_id Sales Credit Identifier
 * @param p_name The sales person's name.
 * @param p_status The status of this salesperson.
 * @param p_start_date_active Date on which the salesperson becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active The effective end date for the salespersons. If no end date is provided, the salesperson is active indefinitely.
 * @param p_org_id Organization Identifier
 * @param p_gl_id_rev Accounting flexfield used for Revenue accounts
 * @param p_gl_id_freight Accounting flexfield used for Freight accounts
 * @param p_gl_id_rec Accounting flexfield used for Receivables accounts
 * @param p_set_of_books_id Set of books identifier, used by Oracle Accounts Receivables
 * @param p_salesrep_number Salesperson Number
 * @param p_email_address Email address of the salesperson
 * @param p_wh_update_date This date is sent to the data warehouse
 * @param p_sales_tax_geocode Sales tax code, it associates the salesperson with a unique tax jurisdiction
 * @param p_sales_tax_inside_city_limits Indicates that the tax jurisdiction for this address is within city limits
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_salesrep_id Out parameter for Salesrep Identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Salesreps API
*/
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
 );

  --Create Salesrep Migration API, used for one-time migration of salesrep data
  --The API includes SALESREP_ID, ORG_ID as its Input Parameters
/*#
 * Create Salesreps Migration API
 * This procedure is used for one-time migration of salesrep data
 * The API includes salesrep_id and org_id as its Input Parameters
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_sales_credit_type_id Sales Credit Identifier
 * @param p_name The sales person's name.
 * @param p_status The status of this salesperson.
 * @param p_start_date_active Date on which the salesperson becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active The effective end date for the salespersons. If no end date is provided, the salesperson is active indefinitely.
 * @param p_gl_id_rev Accounting flexfield used for Revenue accounts
 * @param p_gl_id_freight Accounting flexfield used for Freight accounts
 * @param p_gl_id_rec Accounting flexfield used for Receivables accounts
 * @param p_set_of_books_id Set of books identifier, used by Oracle Accounts Receivables
 * @param p_salesrep_number Salesperson Number
 * @param p_email_address Email address of the salesperson
 * @param p_wh_update_date This date is sent to the data warehouse
 * @param p_sales_tax_geocode Sales tax code, it associates the salesperson with a unique tax jurisdiction
 * @param p_sales_tax_inside_city_limits Indicates that the tax jurisdiction for this address is within city limits
 * @param p_salesrep_id Salesperson Identifier
 * @param p_org_id Organization Identifier
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_salesrep_id Out parameter for Salesrep Identifier
 * @rep:scope internal
 * @rep:lifecycle obsolete
 * @rep:displayname Create Salesreps Migration API
*/
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
 );

  --Creating a Global Variable to be used for setting the flag,
  --when the create_salesrep_migrate gets called

    G_SRP_ID_PUB_FLAG           VARCHAR2(1)                                     := 'Y';
    G_SALESREP_ID               JTF_RS_SALESREPS.SALESREP_ID%TYPE          	:= NULL;
    G_ORG_ID			JTF_RS_SALESREPS.ORG_ID%TYPE			:= NULL;
    G_ATTRIBUTE1		JTF_RS_SALESREPS.ATTRIBUTE1%TYPE		:= NULL;
    G_ATTRIBUTE2                JTF_RS_SALESREPS.ATTRIBUTE2%TYPE                := NULL;
    G_ATTRIBUTE3                JTF_RS_SALESREPS.ATTRIBUTE3%TYPE                := NULL;
    G_ATTRIBUTE4                JTF_RS_SALESREPS.ATTRIBUTE4%TYPE                := NULL;
    G_ATTRIBUTE5                JTF_RS_SALESREPS.ATTRIBUTE5%TYPE                := NULL;
    G_ATTRIBUTE6                JTF_RS_SALESREPS.ATTRIBUTE6%TYPE                := NULL;
    G_ATTRIBUTE7                JTF_RS_SALESREPS.ATTRIBUTE7%TYPE                := NULL;
    G_ATTRIBUTE8                JTF_RS_SALESREPS.ATTRIBUTE8%TYPE                := NULL;
    G_ATTRIBUTE9                JTF_RS_SALESREPS.ATTRIBUTE9%TYPE                := NULL;
    G_ATTRIBUTE10               JTF_RS_SALESREPS.ATTRIBUTE10%TYPE               := NULL;
    G_ATTRIBUTE11               JTF_RS_SALESREPS.ATTRIBUTE11%TYPE               := NULL;
    G_ATTRIBUTE12               JTF_RS_SALESREPS.ATTRIBUTE12%TYPE               := NULL;
    G_ATTRIBUTE13               JTF_RS_SALESREPS.ATTRIBUTE13%TYPE               := NULL;
    G_ATTRIBUTE14               JTF_RS_SALESREPS.ATTRIBUTE14%TYPE               := NULL;
    G_ATTRIBUTE15               JTF_RS_SALESREPS.ATTRIBUTE15%TYPE               := NULL;
    G_ATTRIBUTE_CATEGORY        JTF_RS_SALESREPS.ATTRIBUTE_CATEGORY%TYPE        := NULL;

  /* Procedure to update the Salesreps
	based on input values passed by calling routines. */
/*#
 * Update Salesreps API
 * This procedure allows the user to update a salesrep record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_salesrep_id Salesperson Identifier
 * @param p_sales_credit_type_id Sales Credit Identifier
 * @param p_name The sales person's name.
 * @param p_status The status of this salesperson.
 * @param p_start_date_active Date on which the salesperson becomes active. This value can not be NULL, and the start date must be less than the end date.
 * @param p_end_date_active The effective end date for the salespersons. If no end date is provided, the salesperson is active indefinitely.
 * @param p_gl_id_rev Accounting flexfield used for Revenue accounts
 * @param p_gl_id_freight Accounting flexfield used for Freight accounts
 * @param p_gl_id_rec Accounting flexfield used for Receivables accounts
 * @param p_set_of_books_id Set of books identifier, used by Oracle Accounts Receivables
 * @param p_salesrep_number Salesperson Number
 * @param p_email_address Email address of the salesperson
 * @param p_wh_update_date This date is sent to the data warehouse
 * @param p_sales_tax_geocode Sales tax code, it associates the salesperson with a unique tax jurisdiction
 * @param p_sales_tax_inside_city_limits Indicates that the tax jurisdiction for this address is within city limits
 * @param p_org_id Organization Identifier
 * @param p_object_version_number The object version number of the salesrep derives from the jtf_rs_salesreps table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Salesreps API
*/
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
   P_ORG_ID                     IN  JTF_RS_SALESREPS.ORG_ID%TYPE,
   P_OBJECT_VERSION_NUMBER	IN  OUT NOCOPY  JTF_RS_SALESREPS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  );


END jtf_rs_salesreps_pub;

 

/
