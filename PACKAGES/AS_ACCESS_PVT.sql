--------------------------------------------------------
--  DDL for Package AS_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ACCESS_PVT" AUTHID CURRENT_USER as
/* $Header: asxvacss.pls 120.1 2006/03/25 04:25:54 savadhan noship $ */

-- Start of Comments
--
-- NAME
--   AS_ACCESS_PVT
--
-- PURPOSE
--   This package is a private API for manipulating access related info into
--   OSM. It contains specification for pl/sql records and tables and the
--   Private API's for access and sales team manipulation
--
--   Procedures:
--	Create_SalesTeam
--	Delete SalesTeam
--	Update_SalesTeam
--	Validate_SalesTeam
--  	Has_ViewCustomerAccess
--	Has_UpdateCustomerAccess
--	Has_UpdateLeadAccess
--	Has_UpdateOpportunityAccess
--	Has_viewLeadAccess
--	Has_viewOpportunityAccess

-- NOTES
--   This package is for private use only
--
--
--
-- HISTORY
--   06/19/98   JKORNBER                Created
--   07/07/98   AWU			Updated
--
-- End of Comments


--     ***********************
--       Composite Types
--     ***********************

-- Start of Comments
--
--      Sales team (access Record): sales_team_rec_type
--
--      Parameters:
--	 access_id
--	 freeze_flag
--	 reassign_flag
--	 team_leader_flag
--	 customer_id
--	 address_id
--	 salesforce_id
--	 person_id
--	 partner_customer_id
--	 partner_address_id
--	 created_person_id
--	 lead_id
--	 freeze_date
--	 reassign_reason
--	 downloadable_flag          obsolete
--	 attribute_category
--	 attribute1 -15
--	 salesforce_relationship_code
--    <Added by ACNG>
--	 salesforce_role_code
--	 sales_lead_id
--	 sales_group_id
--	 partner_cont_party_id
--    <End>
--
--     Required:
--	ACCESS_ID
--      FREEZE_FLAG
--	REASSIGN_FLAG
--	TEAM_LEADER_FLAG
--	CUSTOMER_ID
--	ADDRESS_ID
--
--
--      Defaults:
--
-- End of Comments

TYPE sales_team_rec_type               IS RECORD
        (
	 access_id                      NUMBER       := NULL
	,last_update_date		DATE		:= FND_API.G_MISS_DATE
 	,last_updated_by		NUMBER		:= FND_API.G_MISS_NUM
 	,creation_date			DATE		:= FND_API.G_MISS_DATE
 	,created_by			NUMBER		:= FND_API.G_MISS_NUM
 	,last_update_login		NUMBER		:= FND_API.G_MISS_NUM
	,freeze_flag                    VARCHAR2(1)       := FND_API.G_MISS_CHAR
	,reassign_flag                  VARCHAR2(1)       := FND_API.G_MISS_CHAR
	,team_leader_flag               VARCHAR2(1)       := FND_API.G_MISS_CHAR
	,customer_id                    NUMBER       := NULL
	,address_id                     NUMBER       := NULL
	,salesforce_id                  NUMBER       := NULL
	,person_id                      NUMBER       := NULL
	,partner_customer_id            NUMBER       := NULL
	,partner_address_id             NUMBER       := NULL
	,created_person_id              NUMBER       := NULL
	,lead_id                        NUMBER       := NULL
	,freeze_date                    DATE       := FND_API.G_MISS_DATE
	,reassign_reason                VARCHAR2(240)       := FND_API.G_MISS_CHAR
	,reassign_request_date          DATE	:= FND_API.G_MISS_DATE
	,reassign_requested_person_id    NUMBER := FND_API.G_MISS_NUM
	,downloadable_flag              VARCHAR2(1)       := FND_API.G_MISS_CHAR
	,attribute_category             VARCHAR2(30)       := FND_API.G_MISS_CHAR
	,attribute1                     VARCHAR2(150)      := FND_API.G_MISS_CHAR
	,attribute2                     VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute3                     VARCHAR2(150)      := FND_API.G_MISS_CHAR
	,attribute4                     VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute5                     VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute6                     VARCHAR2(150)        := FND_API.G_MISS_CHAR
	,attribute7                     VARCHAR2(150)        := FND_API.G_MISS_CHAR
	,attribute8                     VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute9                     VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute10                    VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute11                    VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute12                    VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute13                    VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute14                    VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,attribute15                    VARCHAR2(150)       := FND_API.G_MISS_CHAR
	,salesforce_role_code           VARCHAR2(30)       := FND_API.G_MISS_CHAR
	,salesforce_relationship_code   VARCHAR2(30)       := FND_API.G_MISS_CHAR
	,sales_lead_id                  NUMBER             := FND_API.G_MISS_NUM
	,sales_group_id                 NUMBER             := FND_API.G_MISS_NUM
	,partner_cont_party_id          NUMBER             := FND_API.G_MISS_NUM
        ,owner_flag			varchar2(1) := FND_API.G_MISS_CHAR
	,created_by_tap_flag varchar2(1) := FND_API.G_MISS_CHAR
	,prm_keep_flag varchar2(1) := FND_API.G_MISS_CHAR
        ,contributor_flag varchar2(1) := FND_API.G_MISS_CHAR -- Added for ASNB
	);

G_MISS_SALES_TEAM_REC          	sales_team_rec_type;


-- Start of Comments
--
--  Sales Team Table:    	sales_team_tbl_type
--
-- End of Comments

TYPE sales_team_tbl_type   	IS TABLE OF     sales_team_rec_type
                                        INDEX BY BINARY_INTEGER;

G_MISS_SALES_TEAM_TBL         sales_team_tbl_type;

-- Start of Comments
--
--      API name        : Create_SalesTeam
--      Type            : Private
--      Function        : Insert sales team member records into the
--			  sales team (access table)
--
--      Pre-reqs        : Existing Customer and Account, or Opportunity
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number          	IN      NUMBER,
--		        p_init_msg_list                 IN      VARCHAR2
--		        p_commit                        IN      VARCHAR2
--    		        p_validation_level		IN	NUMBER
--      OUT             :
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_access_id         	OUT     NUMBER
--
--      Version :       Current version 2.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for creating either an account or opportunity
--			sales team
--
--
-- End of Comments

PROCEDURE Create_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                := FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_access_id                 	OUT NOCOPY     NUMBER
);

-- Start of Comments
--
--      API name        : Delete_SalesTeam
--      Type            : Private
--      Function        : Delete sales team member records from the
--			  sales team (access table)
--
--      Pre-reqs        : Existing sales team record
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number          	IN      NUMBER,
--		        p_init_msg_list                 IN      VARCHAR2
--		        p_commit                        IN      VARCHAR2
--    		        p_validation_level		IN	NUMBER
--      OUT             :
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for delete either an account or opportunity
--			sales team
--
--
-- End of Comments

PROCEDURE Delete_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                := FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
);

-- Start of Comments
--
--      API name        : Update_SalesTeam
--      Type            : Private
--      Function        : Update sales team member records into the
--			  sales team (access table)
--
--      Pre-reqs        : Existing sales team record
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number          	IN      NUMBER,
--		        p_init_msg_list                 IN      VARCHAR2
--		        p_commit                        IN      VARCHAR2
--    		        p_validation_level		IN	NUMBER
--      OUT             :
--                      x_return_status         OUT NOCOPY     VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY     NUMBER
--                      x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--                      x_access_id         	OUT NOCOPY     NUMBER
--
--      Version :       Current version 2.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for updating either an account or opportunity
--			sales team
--
--
-- End of Comments

PROCEDURE Update_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                := FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_access_id                 	OUT NOCOPY     NUMBER
);


-- Start of Comments
--
--      API name        : Validate_SalesTeamItems
--      Type            : Private
--      Function        : Validate sales team member records
--
--      Pre-reqs        : None
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number          	IN      NUMBER,
--		        p_init_msg_list                 IN      VARCHAR2
--    		        p_validation_level		IN	NUMBER
--      OUT             :
--                      x_return_status         OUT NOCOPY     VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY     NUMBER
--                      x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--      Version :       Current version 2.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for validating either an account or opportunity
--			sales team member record
--
--
-- End of Comments

PROCEDURE Validate_SalesTeamItems
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
);

--      API name        : has_viewCustomerAccess
--      Type            : Public
--      Function        : This API is used for checking if login user has view access for
--                        the pass in customer id. If the user has view access for the customer,
--                        he/she can create contacts, update contacts, create sales leads and create
--			  opportunities for this customer.
--			  For PRM support, it also checks if login partner contact has view access for
--			  passing in customer id. PRM need to make sure to pass
--                        in p_partner_cont_party_id for partner contact access
--                        and pass in partner contact resource id to p_identity_salesforce_id.
--                        For LAM and CM login, make sure not to pass in this
--                        value. For has view access, this API will return
--                        x_view_access_flag = 'Y', otherwise return 'N'.

procedure has_viewCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
);

--      API name        : has_updateCustomerAccess
--      Type            : Public
--      Function        : This API is used for checking if login user has update access
--			  for passing in customer_id. For PRM support, it also checks
--			  if login partner contact has update access for passing in customer id.
--			  PRM need to make sure to pass in p_partner_cont_party_id for partner contact access
--		          and pass in partner contact resource id to p_identity_salesforce_id.
--			  For LAM and CM login, make sure not to pass in this value.
--			  If user has update access, x_update_access_flag = 'Y'.
--			  A user can also update all addresses of the customer.

procedure has_updateCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN  as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
);

--      API name        : has_updateLeadAccess
--      Type            : Public
--      Function        : This API is used for checking if login user has update access for
--			  passing in sales_lead_id. If user has update access,
--			  then x_update_access_flag = 'Y'. This API doesn't have
--			  PRM support since PRM doesn't handle sales leads for now.
--

procedure has_updateLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN  as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
);

--      API name        : has_updateOpportunityAccess
--      Type            : Public
--      Function        : This API is used for checking if login user has update access for passing in opportunity_id.
--			  For PRM support, it also checks if login partner contact has update access for passing
--			  in opportunity id. PRM need to make sure to pass in p_partner_cont_party_id for partner
--			  contact access and pass in partner contact resource id to p_identity_salesforce_id.
--	                  For LAM and CM login, make sure not to pass in this
--                        value. If user has update access, x_update_ access_flag = 'Y'.

procedure has_updateOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN  as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
);

procedure has_leadOwnerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
        ,p_access_profile_rec   IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
);


procedure has_oppOwnerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
        ,p_access_profile_rec   IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_lead_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
);


procedure has_viewLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
);

procedure has_viewOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
);



END AS_ACCESS_PVT;

 

/
