--------------------------------------------------------
--  DDL for Package OZF_QUOTA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QUOTA_PUB" AUTHID CURRENT_USER AS
/* $Header: OZFPQUOS.pls 120.5 2006/05/24 09:51:16 asylvia noship $ */
/*#
* Use this API to create, update and delete quota and
* to create and update Product and Account Spreads.
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname Quota Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_QUOTA
*/

TYPE quota_rec_type IS RECORD
(quota_id               	NUMBER
,quota_number               	VARCHAR2(30)
,parent_quota_id                NUMBER
,short_name                	VARCHAR2(80)
,custom_setup_id           	NUMBER
,description               	VARCHAR2(4000)
,status_code			VARCHAR2(20) -- derived
,user_status_id            	NUMBER
,start_period_name         	VARCHAR2(15)
,end_period_name           	VARCHAR2(15)
,start_date_active		DATE -- derived
,end_date_active		DATE -- derived
,quota_amount           	NUMBER
,currency_code_tc          	VARCHAR2(15) -- derived
,owner                     	NUMBER
,threshold_id              	NUMBER
,product_spread_time_id		NUMBER
,created_from	                VARCHAR2(30) -- derived
,attribute_category		VARCHAR2(30)
,attribute1			VARCHAR2(150)
,attribute2			VARCHAR2(150)
,attribute3			VARCHAR2(150)
,attribute4			VARCHAR2(150)
,attribute5			VARCHAR2(150)
,attribute6			VARCHAR2(150)
,attribute7			VARCHAR2(150)
,attribute8			VARCHAR2(150)
,attribute9			VARCHAR2(150)
,attribute10			VARCHAR2(150)
,attribute11			VARCHAR2(150)
,attribute12			VARCHAR2(150)
,attribute13			VARCHAR2(150)
,attribute14			VARCHAR2(150)
,attribute15			VARCHAR2(150)
,org_id				NUMBER(32)
);

TYPE alloc_rec_type IS RECORD
(quota_id			VARCHAR2(30)
,quota_number			VARCHAR2(30)
,hierarchy_id           	NUMBER
,from_level               	NUMBER
,to_level	           	NUMBER
,start_node	         	NUMBER
,start_period_name           	VARCHAR2(15)
,end_period_name 		VARCHAR2(15)
,from_date			DATE
,to_date			DATE
,alloc_amount			NUMBER
,method_code			VARCHAR2(10)
,basis_year			NUMBER
,product_spread_time_id		NUMBER
);

TYPE quota_products_rec_type IS RECORD
(product_allocation_id		NUMBER
,allocation_for			VARCHAR2(30)
,allocation_for_id		NUMBER
,allocation_for_tbl_index	NUMBER
,quota_id			NUMBER
,item_type			VARCHAR2(30)
,item_id			NUMBER
,organization_id		NUMBER -- can be defaulted
,category_set_id		NUMBER
,selected_flag			VARCHAR2(1)
,target				NUMBER
,lysp_sales			NUMBER );

TYPE quota_products_tbl_type IS TABLE OF quota_products_rec_type
                                INDEX BY BINARY_INTEGER;

TYPE quota_accounts_rec_type IS RECORD
(account_allocation_id 		NUMBER
,allocation_for			VARCHAR2(30)
,allocation_for_id		NUMBER
--,cust_account_id		NUMBER
,ship_to_site_use_id			NUMBER
--,site_use_code			VARCHAR2(30)
-- ,location_id			NUMBER  -- must be derived
-- ,bill_to_site_use_id		NUMBER
-- ,bill_to_location_id		NUMBER
-- ,parent_party_id		NUMBER
-- ,rollup_party_id		NUMBER
,selected_flag			VARCHAR2(1)
,target				NUMBER
,lysp_sales			NUMBER
,parent_account_allocation_id 	NUMBER
);

TYPE quota_accounts_tbl_type IS TABLE OF quota_accounts_rec_type
                                INDEX BY BINARY_INTEGER;

TYPE target_spread_rec_type IS RECORD
(time_allocation_id		NUMBER
,allocation_for			VARCHAR2(30)
,allocation_for_id		NUMBER
,allocation_for_tbl_index	NUMBER
,time_id			NUMBER
,period_type_id			NUMBER
,target				NUMBER
,lysp_sales			NUMBER);

TYPE quota_prod_spread_tbl_type IS TABLE OF target_spread_rec_type
                                      INDEX BY BINARY_INTEGER;

TYPE account_spread_tbl_type IS TABLE OF target_spread_rec_type
                                INDEX BY BINARY_INTEGER;

TYPE account_products_tbl_type IS TABLE OF quota_products_rec_type
                                  INDEX BY BINARY_INTEGER;

TYPE acct_prod_spread_tbl_type IS TABLE OF target_spread_rec_type
                                  INDEX BY BINARY_INTEGER;

TYPE quota_markets_tbl_type IS TABLE OF OZF_FUNDS_PUB.mks_rec_type
                               INDEX BY BINARY_INTEGER;
-----------------------------
-- Create APIs
-----------------------------
/*#
* This procedure creates a new quota.
* @param p_api_version      Indicates the version of the API.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the level of the validation.
* @param x_return_status    Indicates the program status.
* @param x_msg_data         Returns messages by the program.
* @param x_msg_count        This is the number of messages the program returns.
* @param x_quota_id         This is the new quota ID.
* @param p_quota_rec              Quota Header information.
* @param p_quota_markets_tbl      Populate markets eligible for a quota .
* @param p_quota_products_tbl     Populate Products eligible for a quota .
* @param p_quota_prod_spread_tbl  Populate Time Spread for Quota Products.
* @param p_quota_accounts_tbl     Populate Accounts eligible for a Quota.
* @param p_account_spread_tbl	  Populate Time Spread for Quota Accounts.
* @param p_account_products_tbl   Populate Products eligible for each account in quota.
* @param p_acct_prod_spread_tbl   Populate Time Spread for each product associated to an account.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Quota
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Create_Quota(
   p_api_version		IN       	NUMBER
  ,p_init_msg_list     		IN       	VARCHAR2 := fnd_api.g_false
  ,p_commit            		IN       	VARCHAR2 := fnd_api.g_false
  ,p_validation_level  		IN       	NUMBER   := fnd_api.g_valid_level_full
  ,x_return_status     		OUT NOCOPY     VARCHAR2
  ,x_msg_count         		OUT NOCOPY     NUMBER
  ,x_msg_data          		OUT NOCOPY     VARCHAR2
  ,p_method            		IN             VARCHAR2 := 'MANUAL'
  ,p_quota_rec         		IN   		quota_rec_type
  ,p_quota_markets_tbl          IN              quota_markets_tbl_type
  ,p_quota_products_tbl		IN              quota_products_tbl_type
  ,p_quota_prod_spread_tbl	IN		quota_prod_spread_tbl_type
  ,p_quota_accounts_tbl		IN		quota_accounts_tbl_type
  ,p_account_spread_tbl		IN		account_spread_tbl_type
  ,p_account_products_tbl       IN              account_products_tbl_type
  ,p_acct_prod_spread_tbl	IN		acct_prod_spread_tbl_type
  ,p_alloc_rec			IN		alloc_rec_type
  ,x_quota_id          		OUT NOCOPY     NUMBER
  );

/*#
* This procedure adds a product to a quota or an account
* @param p_api_version      Indicates the API version.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the level of the validation.
* @param x_return_status    Indicates the program status.
* @param x_msg_data         Returns messages by the program.
* @param x_msg_count        Indicates the number of messages the program returned.
* @param p_allocation_for         Indicated whether the product is for a Quota or an Account.
* @param p_allocation_for_id      Quota or Account identifier .
* @param p_quota_products_tbl     Populate Products eligible for a quota or account .
* @param p_quota_prod_spread_tbl  Populate Time Spread for the Products.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Product Spread
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Create_Quota_Product_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_allocation_for        IN VARCHAR2
             ,p_allocation_for_id     IN NUMBER
             ,p_quota_products_tbl    IN quota_products_tbl_type
             ,p_quota_prod_spread_tbl IN quota_prod_spread_tbl_type ) ;

/*#
* This procedure adds a product to a quota or an account
* @param p_api_version      Indicates the API version.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the validation level.
* @param x_return_status    Indicates the program status.
* @param x_msg_data         Returns messages by the program.
* @param x_msg_count        Indicates the number of messages the program returned.
* @param p_quota_accounts_tbl     Populate Accounts eligible for a Quota.
* @param p_account_spread_tbl	  Populate Time Spread for Quota Accounts.
* @param p_account_products_tbl   Populate Products eligible for each account in quota.
* @param p_acct_prod_spread_tbl   Populate Time Spread for each product associated to an account.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Quota Account Spread
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Create_Quota_Account_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_fund_id             IN  NUMBER
             ,p_quota_accounts_tbl  IN quota_accounts_tbl_type
             ,p_account_spread_tbl  IN account_spread_tbl_type
             ,p_account_products_tbl IN account_products_tbl_type
             ,p_acct_prod_spread_tbl IN acct_prod_spread_tbl_type ) ;

---------------------------
-- Update APIs
---------------------------
/*#
* This procedure updates an existing quota.
* @param p_api_version      Indicates the API version.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the validation level.
* @param p_quota_rec        Identifies the record to be updated.
* @param x_return_status    Indicates the program status.
* @param x_msg_data         Returns messages by the program
* @param x_msg_count        Indicates the number of messages the program returned.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Quota
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Update_Quota(
   p_api_version 		IN       	NUMBER
  ,p_init_msg_list      	IN       	VARCHAR2 := fnd_api.g_false
  ,p_commit             	IN       	VARCHAR2 := fnd_api.g_false
  ,p_validation_level   	IN       	NUMBER   := fnd_api.g_valid_level_full
  ,x_return_status      	OUT NOCOPY      VARCHAR2
  ,x_msg_count          	OUT NOCOPY      NUMBER
  ,x_msg_data           	OUT NOCOPY      VARCHAR2
  ,p_quota_rec          	IN   		quota_rec_type );

/*#
* This procedure updates an existing products and product spread
* @param p_api_version      Indicates the version of the API.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the validation level.
* @param x_return_status    Indicates the program status.
* @param x_msg_data         Indicates the number of messages the program returned.
* @param x_msg_count        Change Update to Updates and add a period.
* @param p_quota_products_tbl     Change Update to Updates and add a period.
* @param p_quota_prod_spread_tbl  Update Time Spread for the Products.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Product Spread
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Update_Quota_Product_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_quota_products_tbl    IN quota_products_tbl_type
             ,p_quota_prod_spread_tbl IN quota_prod_spread_tbl_type ) ;

/*#
* This procedure updates an existing account and account spread
* @param p_api_version      Indicates the version of the API.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the validation level.
* @param x_return_status    Indicates the program status.
* @param x_msg_data         Returns messages by the program.
* @param x_msg_count        Indicates the number of messages the program returned.
* @param p_quota_accounts_tbl     Update accounts for a quota .
* @param p_account_spread_tbl     Updates Time Spreads for the Accounts.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Updates Account Spread
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Update_Quota_Account_Spread(
              p_api_version         IN   NUMBER
             ,p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false
             ,p_commit              IN   VARCHAR2 := fnd_api.g_false
             ,p_validation_level    IN   NUMBER   := fnd_api.g_valid_level_full
             ,x_return_status       OUT NOCOPY  VARCHAR2
             ,x_msg_count           OUT NOCOPY  NUMBER
             ,x_msg_data            OUT NOCOPY  VARCHAR2
             ,p_quota_accounts_tbl  IN quota_accounts_tbl_type
             ,p_account_spread_tbl  IN account_spread_tbl_type  );

-------------------------------
-- Delete APIs
-------------------------------
/*#
* This procedure deletes an exist quota.
* @param p_api_version   Indicates the version of the API.
* @param p_init_msg_list Indicates whether to initialize the message stack.
* @param p_commit        Indicates whether to commit within the program.
* @param p_quota_id      Indicates Quota identifier of the quota to be deleted.
* @param x_return_status Indicates the program status.
* @param x_msg_count     Indicates the number of messages the program returned.
* @param x_msg_data      Return message by the program.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Delete Quota
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE delete_quota(
   p_api_version 	IN       	NUMBER
  ,p_init_msg_list      IN       	VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       	VARCHAR2 := fnd_api.g_false
  ,p_quota_id           IN   		NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  );


END OZF_QUOTA_PUB;


 

/
