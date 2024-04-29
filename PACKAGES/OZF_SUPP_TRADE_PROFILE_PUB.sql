--------------------------------------------------------
--  DDL for Package OZF_SUPP_TRADE_PROFILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SUPP_TRADE_PROFILE_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfpstps.pls 120.0.12010000.7 2010/03/10 08:12:54 amlal noship $ */
/*#
* This package can be used to Create and Update Supplier Trade profile and related
* code conversion and price protection setup data
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname OZF_SUPP_TRADE_PROFILE Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_STP
*/

--   -------------------------------------------------------
--    Record name  supp_trade_profile_rec_type
--   -------------------------------------------------------


TYPE supp_trade_profile_rec_type IS RECORD
(
	supp_trade_profile_id                     NUMBER := FND_API.g_miss_num,
	object_version_number                     NUMBER := FND_API.g_miss_num,
	last_update_date                          DATE := FND_API.G_MISS_DATE,
	last_updated_by                           NUMBER := FND_API.g_miss_num,
	creation_date                             DATE := FND_API.G_MISS_DATE,
	created_by                                NUMBER := FND_API.g_miss_num,
	last_update_login                         NUMBER := FND_API.g_miss_num,
	request_id                                NUMBER := FND_API.g_miss_num,
	program_application_id                    NUMBER := FND_API.g_miss_num,
	program_update_date                       DATE := FND_API.G_MISS_DATE,
	program_id                                NUMBER := FND_API.g_miss_num,
	created_from                              VARCHAR2(30) := FND_API.g_miss_char,
	supplier_id                               NUMBER := FND_API.g_miss_num,
	supplier_site_id                          NUMBER := FND_API.g_miss_num,
	party_id                                  NUMBER := FND_API.g_miss_num,
	cust_account_id                           NUMBER := FND_API.g_miss_num,
	cust_acct_site_id                         NUMBER := FND_API.g_miss_num,
	site_use_id                               NUMBER := FND_API.g_miss_num,
	pre_approval_flag                         VARCHAR2(1) := FND_API.g_miss_char,
	approval_communication                    VARCHAR2(30) := FND_API.g_miss_char,
	gl_contra_liability_acct                  NUMBER := FND_API.g_miss_num,
	gl_cost_adjustment_acct                   NUMBER := FND_API.g_miss_num,
	default_days_covered                      NUMBER := FND_API.g_miss_num,
	create_claim_price_increase               VARCHAR2(1) := FND_API.g_miss_char,
	skip_approval_flag                        VARCHAR2(1) := FND_API.g_miss_char,
	skip_adjustment_flag                      VARCHAR2(1) := FND_API.g_miss_char,
	settlement_method_supplier_inc            VARCHAR2(30) := FND_API.g_miss_char,
	settlement_method_supplier_dec            VARCHAR2(30) := FND_API.g_miss_char,
	settlement_method_customer                VARCHAR2(30) := FND_API.g_miss_char,
	authorization_period                      NUMBER := FND_API.g_miss_num,
	grace_days                                NUMBER := FND_API.g_miss_num,
	allow_qty_increase                        VARCHAR2(1) := FND_API.g_miss_char,
	qty_increase_tolerance                    NUMBER := FND_API.g_miss_num,
	request_communication                     VARCHAR2(30) := FND_API.g_miss_char,
	claim_communication                       VARCHAR2(30) := FND_API.g_miss_char,
	claim_frequency                           NUMBER := FND_API.g_miss_num,
	claim_frequency_unit                      VARCHAR2(30) := FND_API.g_miss_char,
	claim_computation_basis                   NUMBER := FND_API.g_miss_num,
	attribute_category                        VARCHAR2(30) := FND_API.g_miss_char,
	attribute1                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute2                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute3                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute4                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute5                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute6                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute7                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute8                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute9                                VARCHAR2(150) := FND_API.g_miss_char,
	attribute10                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute11                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute12                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute13                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute14                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute15                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute16                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute17                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute18                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute19                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute20                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute21                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute22                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute23                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute24                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute25                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute26                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute27                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute28                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute29                               VARCHAR2(150) := FND_API.g_miss_char,
	attribute30                               VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute_category                    VARCHAR2(30) := FND_API.g_miss_char,
	dpp_attribute1                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute2                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute3                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute4                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute5                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute6                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute7                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute8                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute9                            VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute10                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute11                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute12                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute13                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute14                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute15                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute16                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute17                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute18                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute19                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute20                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute21                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute22                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute23                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute24                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute25                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute26                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute27                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute28                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute29                           VARCHAR2(150) := FND_API.g_miss_char,
	dpp_attribute30                           VARCHAR2(150) := FND_API.g_miss_char,
	org_id                                    NUMBER := FND_API.g_miss_num,
	security_group_id                         NUMBER := FND_API.g_miss_num,
	claim_currency_code                       VARCHAR2(15) := FND_API.g_miss_char,
	min_claim_amt                             NUMBER := FND_API.g_miss_num,
	min_claim_amt_line_lvl                    NUMBER := FND_API.g_miss_num,
	auto_debit                                VARCHAR2(1) := FND_API.g_miss_char,
	days_before_claiming_debit                NUMBER := FND_API.g_miss_num
);


--   -------------------------------------------------------
--    Record name  supp_code_conversion_rec_type
--   -------------------------------------------------------
TYPE supp_code_conversion_rec_type IS RECORD
(
   CODE_CONVERSION_ID     NUMBER := FND_API.g_miss_num,
   OBJECT_VERSION_NUMBER  NUMBER := FND_API.g_miss_num,
   LAST_UPDATE_DATE       DATE := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY        NUMBER := FND_API.g_miss_num,
   CREATION_DATE          DATE := FND_API.G_MISS_DATE,
   CREATED_BY             NUMBER := FND_API.g_miss_num,
   LAST_UPDATE_LOGIN      NUMBER := FND_API.g_miss_num,
   ORG_ID                 NUMBER := FND_API.g_miss_num,
   SUPP_TRADE_PROFILE_ID  NUMBER := FND_API.g_miss_num,
   CODE_CONVERSION_TYPE   VARCHAR2(30) := FND_API.g_miss_char,
   EXTERNAL_CODE          VARCHAR2(240) := FND_API.g_miss_char,
   INTERNAL_CODE          VARCHAR2(240) := FND_API.g_miss_char,
   DESCRIPTION            VARCHAR2(240) := FND_API.g_miss_char,
   START_DATE_ACTIVE      DATE := FND_API.G_MISS_DATE,
   END_DATE_ACTIVE        DATE := FND_API.G_MISS_DATE,
   ATTRIBUTE_CATEGORY     VARCHAR2(30) := FND_API.g_miss_char,
   ATTRIBUTE1             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE2             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE3             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE4             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE5             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE6             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE7             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE8             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE9             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE10            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE11            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE12            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE13            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE14            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE15            VARCHAR2(150) := FND_API.g_miss_char,
   SECURITY_GROUP_ID      NUMBER := FND_API.g_miss_num,
   CODE_CONVERSION_ACTION   VARCHAR2(1) --'C'/'U'/'D'
);

--   -------------------------------------------------------
--    Record name  code_conversion_tbl_type
--   -------------------------------------------------------
TYPE code_conversion_tbl_type IS TABLE OF supp_code_conversion_rec_type ;




--   -------------------------------------------------------
--    Record name  process_setup_rec_type
--   -------------------------------------------------------

TYPE process_setup_rec_type IS RECORD
(
   PROCESS_SETUP_ID        NUMBER := FND_API.g_miss_num,
   OBJECT_VERSION_NUMBER  NUMBER := FND_API.g_miss_num,
   LAST_UPDATE_DATE       DATE := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY        NUMBER := FND_API.g_miss_num,
   CREATION_DATE          DATE := FND_API.G_MISS_DATE,
   CREATED_BY             NUMBER := FND_API.g_miss_num,
   LAST_UPDATE_LOGIN      NUMBER := FND_API.g_miss_num,
   REQUEST_ID             NUMBER := FND_API.g_miss_num,
   PROGRAM_APPLICATION_ID  NUMBER := FND_API.g_miss_num,
   PROGRAM_UPDATE_DATE     DATE  ,
   PROGRAM_ID	           NUMBER := FND_API.g_miss_num,
   CREATED_FROM           VARCHAR2(30) := FND_API.g_miss_char,
   ORG_ID                 NUMBER := FND_API.g_miss_num,
   SUPP_TRADE_PROFILE_ID  NUMBER := FND_API.g_miss_num,
   PROCESS_CODE           VARCHAR2(60),
   ENABLED_FLAG           VARCHAR2(30) := 'N',
   AUTOMATIC_FLAG         VARCHAR2(1) := 'N',
   ATTRIBUTE_CATEGORY     VARCHAR2(30) := FND_API.g_miss_char,
   ATTRIBUTE1             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE2             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE3             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE4             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE5             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE6             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE7             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE8             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE9             VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE10            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE11            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE12            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE13            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE14            VARCHAR2(150) := FND_API.g_miss_char,
   ATTRIBUTE15            VARCHAR2(150) := FND_API.g_miss_char,
   SECURITY_GROUP_ID      NUMBER        := FND_API.g_miss_num
) ;

--   -------------------------------------------------------
--    Record name  process_setup_tbl_type
--   -------------------------------------------------------
TYPE process_setup_tbl_type IS TABLE OF process_setup_rec_type ;




---------------------------------------------------------------------
-- API Name
--     Create_Supp_Trade_Profile
--Type
--   Public
-- PURPOSE
--    This procedure creates Supplier trade profile, code conversion record and
--     price protection mapping
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure creates a new Ship and Debit Request.
* @param  p_api_version_number		-->  Version of the API.
* @param p_init_msg_list		-->  Whether to initialize the message stack.
* @param p_commit			--> Indicates whether to commit within the program.
* @param p_validation_level		--> Indicates the level of the validation.
* @param x_return_status		--> Indicates the status of the program.
* @param x_msg_count			--> Provides the number of the messages returned by the program.
* @param x_msg_data			--> Returns messages by the program.
* @param p_supp_trade_profile_rec       --> Contains details of the new trade profile to be created
* @param p_code_conversion_rec_tbl      --> Table structure contains the code conversion information for the new trade profile
* @param p_price_protection_set_tbl     --> Table structure contains the price protection information for the new trade profile
* @param x_supp_trade_profile_id        --> Returns the id of the created trade profile
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Supplier Trade Profile
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------



PROCEDURE Create_Supp_Trade_Profile(
	    p_api_version_number         IN		NUMBER,
	    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
	    p_commit                     IN		VARCHAR2     := FND_API.G_FALSE,
	    p_validation_level           IN		NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status              OUT NOCOPY	VARCHAR2,
	    x_msg_count                  OUT NOCOPY	NUMBER,
	    x_msg_data                   OUT NOCOPY	VARCHAR2,
	    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type ,
	    p_code_conversion_rec_tbl    IN		code_conversion_tbl_type,
	    p_price_protection_set_tbl   IN             process_setup_tbl_type,
	    x_supp_trade_profile_id      OUT NOCOPY	NUMBER,
	    X_created_process_tbl        OUT NOCOPY     OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
	    X_created_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type
	   );


---------------------------------------------------------------------
-- API Name
--     Update_Supp_Trade_Profile
--Type
--   Public
-- PURPOSE
--    This procedure updates Supplier trade profile and processes code conversion record
--    and price protection mapping
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure creates a new Ship and Debit Request.
* @param  p_api_version_number		-->  Version of the API.
* @param p_init_msg_list		-->  Whether to initialize the message stack.
* @param p_commit			--> Indicates whether to commit within the program.
* @param p_validation_level		--> Indicates the level of the validation.
* @param x_return_status		--> Indicates the status of the program.
* @param x_msg_count			--> Provides the number of the messages returned by the program.
* @param x_msg_data			--> Returns messages by the program.
* @param p_supp_trade_profile_rec       --> Contains details of the new trade profile to be updated
* @param p_code_conversion_rec_tbl      --> Table structure contains the code conversion information for the respective trade profile
* @param p_price_protection_set_tbl     --> Table structure contains the price protection information for the respective trade profile
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Supplier Trade Profile
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------

 PROCEDURE Update_Supp_Trade_Profile(
	    p_api_version_number         IN		NUMBER,
	    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
	    p_commit                     IN		VARCHAR2     := FND_API.G_FALSE,
	    p_validation_level           IN		NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status              OUT NOCOPY	VARCHAR2,
	    x_msg_count                  OUT NOCOPY	NUMBER,
	    x_msg_data                   OUT NOCOPY	VARCHAR2,
	    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type ,
	    p_code_conversion_rec_tbl    IN		code_conversion_tbl_type,
	    p_price_protection_set_tbl   IN             process_setup_tbl_type,
	    X_created_process_tbl        OUT NOCOPY     OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
            X_updated_process_tbl        OUT NOCOPY     OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
	    X_created_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type,
	    X_updated_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type,
	    X_deleted_codes_tbl          OUT NOCOPY     OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type
	   );


---------------------------------------------------------------------
-- API Name
--     Update_Supp_Trade_Profile
--Type
--   Public
-- PURPOSE
--    This procedure updates Supplier trade profile
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure creates a new Ship and Debit Request.
* @param  p_api_version_number		-->  Version of the API.
* @param p_init_msg_list		-->  Whether to initialize the message stack.
* @param p_commit			--> Indicates whether to commit within the program.
* @param p_validation_level		--> Indicates the level of the validation.
* @param x_return_status		--> Indicates the status of the program.
* @param x_msg_count			--> Provides the number of the messages returned by the program.
* @param x_msg_data			--> Returns messages by the program.
* @param p_supp_trade_profile_rec       --> Contains details of the new trade profile to be updated
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Supplier Trade Profile
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------

PROCEDURE Update_Supp_Trade_Profile(
	    p_api_version_number         IN		NUMBER,
	    p_init_msg_list              IN		VARCHAR2     := FND_API.G_FALSE,
	    p_commit                     IN		VARCHAR2     := FND_API.G_FALSE,
	    p_validation_level           IN		NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status              OUT NOCOPY	VARCHAR2,
	    x_msg_count                  OUT NOCOPY	NUMBER,
	    x_msg_data                   OUT NOCOPY	VARCHAR2,
	    p_supp_trade_profile_rec     IN		supp_trade_profile_rec_type
	   );


---------------------------------------------------------------------
-- API Name
--     Process_code_conversion
--Type
--   Public
-- PURPOSE
--    This procedure creates/updates/deletes the code conversion details
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure creates a new Ship and Debit Request.
* @param  p_api_version_number		-->  Version of the API.
* @param p_init_msg_list		-->  Whether to initialize the message stack.
* @param p_commit			--> Indicates whether to commit within the program.
* @param p_validation_level		--> Indicates the level of the validation.
* @param x_return_status		--> Indicates the status of the program.
* @param x_msg_count			--> Provides the number of the messages returned by the program.
* @param x_msg_data			--> Returns messages by the program.
* @param p_code_conversion_tbl          --> Table structure contains the code conversion information
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Supplier Trade Profile
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------
PROCEDURE Process_code_conversion(
	p_api_version_number         IN   	 NUMBER,
	p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
	P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
	p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	x_return_status              OUT NOCOPY  VARCHAR2,
	x_msg_count                  OUT NOCOPY  NUMBER,
	x_msg_data                   OUT NOCOPY  VARCHAR2,
	p_code_conversion_tbl        IN          code_conversion_tbl_type ,
	X_created_code_con_tbl       OUT NOCOPY  OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ,
	X_updated_code_con_tbl       OUT NOCOPY  OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type ,
	X_deleted_code_con_tbl       OUT NOCOPY  OZF_CODE_CONVERSION_PVT.supp_code_conversion_tbl_type);






---------------------------------------------------------------------
-- API Name
--     Process_price_protection
--Type
--   Public
-- PURPOSE
--    This procedure creates/updates the price protection details
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure creates a new Ship and Debit Request.
* @param  p_api_version_number		-->  Version of the API.
* @param p_init_msg_list		-->  Whether to initialize the message stack.
* @param p_commit			--> Indicates whether to commit within the program.
* @param p_validation_level		--> Indicates the level of the validation.
* @param x_return_status		--> Indicates the status of the program.
* @param x_msg_count			--> Provides the number of the messages returned by the program.
* @param x_msg_data			--> Returns messages by the program.
* @param p_process_setup_tbl            --> Table structure contains the price protection information
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Supplier Trade Profile
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------

PROCEDURE Process_price_protection(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_trade_prf_id               IN          NUMBER,
    p_process_setup_tbl          IN          process_setup_tbl_type  ,
    X_created_process_tbl        OUT NOCOPY  OZF_PROCESS_SETUP_PVT.process_setup_tbl_type,
    X_updated_process_tbl        OUT NOCOPY  OZF_PROCESS_SETUP_PVT.process_setup_tbl_type);




END OZF_SUPP_TRADE_PROFILE_PUB;




/
