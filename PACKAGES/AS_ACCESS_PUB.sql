--------------------------------------------------------
--  DDL for Package AS_ACCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ACCESS_PUB" AUTHID CURRENT_USER as
/* $Header: asxpacss.pls 120.1.12010000.2 2008/08/05 08:46:00 snsarava ship $ */

-- Start of Comments
--
-- NAME
--   AS_ACCESS_PUB
--
-- PURPOSE
--   This package is a public API for manipulating access related info in
--   OSM. It contains specification for pl/sql records and tables and public
--   APIs
--
--   Procedures:
--
-- NOTES
--   This package is for public use
--
--


--     ***********************
--       Composite Types
--     ***********************

-- Start of Comments
--
--      Sales team (access Record): sales_team_rec_type
--
--      Parameters:
--     access_id
--     job_title
--     ptr_mgr_last_name
--     ptr_mgr_first_name
--     freeze_flag
--     reassign_flag
--     team_leader_flag
--     customer_id
--     address_id
--     salesforce_id
--     person_id
--     first_name
--     last_name
--     email_address
--     work_telephone
--     sales_group_id
--     sales_group_name
--     partner_customer_id
--     partner_address_id
--     partner_name
--     partner_number
--     partner_city
--     partner_phone_number
--     partner_area_code
--     partner_extension
--     created_person_id
--     lead_id
--     freeze_date
--     reassign_reason
--     downloadable_flag         - obsolete
--     attribute_category
--     attribute1 -15
--     salesforce_relationship_code
--     salesforce_relationship
--     <BEGIN added by ACNG>
--     salesforce_role_code
--     sales_lead_id
--     partner_cont_party_id
--     <END>
--     Required:
--    ACCESS_ID
--      FREEZE_FLAG
--    REASSIGN_FLAG
--    TEAM_LEADER_FLAG
--    CUSTOMER_ID
--    ADDRESS_ID
--
--
--      Defaults:
--
-- End of Comments

TYPE sales_team_rec_type               IS RECORD
        (
     access_id                      NUMBER           := NULL
     ,last_update_date		DATE		:= FND_API.G_MISS_DATE
     ,last_updated_by		NUMBER		:= FND_API.G_MISS_NUM
     ,creation_date			DATE		:= FND_API.G_MISS_DATE
     ,created_by			NUMBER		:= FND_API.G_MISS_NUM
     ,last_update_login		NUMBER		:= FND_API.G_MISS_NUM
    ,freeze_flag                    VARCHAR2(1)     := FND_API.G_MISS_CHAR
    ,reassign_flag                  VARCHAR2(1)     := FND_API.G_MISS_CHAR
    ,team_leader_flag               VARCHAR2(1)     := FND_API.G_MISS_CHAR
    ,customer_id                    NUMBER           := NULL
    ,address_id                     NUMBER           := NULL
    ,salesforce_id                  NUMBER           := NULL
    ,person_id                      NUMBER           := NULL
    ,job_title			    VARCHAR2(240)    := NULL  -- Only used for query
--    ,ptr_mgr_last_name		    VARCHAR2(40)     := NULL  -- Only used for query
--    ,ptr_mgr_first_name		    VARCHAR2(20)     := NULL  -- Only used for query
    ,first_name            VARCHAR2(150)    := FND_API.G_MISS_CHAR
    ,last_name            VARCHAR2(150)    := FND_API.G_MISS_CHAR
    ,email_address            VARCHAR2(240)   := FND_API.G_MISS_CHAR
    ,work_telephone            VARCHAR2(60)    := FND_API.G_MISS_CHAR
    ,sales_group_id            NUMBER             := FND_API.G_MISS_NUM
    ,sales_group_name        VARCHAR2(60)    := FND_API.G_MISS_CHAR
    ,partner_customer_id            NUMBER           := NULL
    ,partner_address_id             NUMBER           := NULL
    ,partner_name            VARCHAR2(50)    := FND_API.G_MISS_CHAR
    ,partner_number            VARCHAR2(30)    := FND_API.G_MISS_CHAR
    ,partner_city            VARCHAR2(60)    := FND_API.G_MISS_CHAR
    ,partner_phone_number        VARCHAR2(25)    := FND_API.G_MISS_CHAR
    ,partner_area_code        VARCHAR2(10)    := FND_API.G_MISS_CHAR
    ,partner_extension        VARCHAR2(20)    := FND_API.G_MISS_CHAR
    ,created_person_id              NUMBER           := NULL
    ,lead_id                        NUMBER           := NULL
    ,freeze_date                    DATE           := NULL
    ,reassign_reason                VARCHAR2(240)   := FND_API.G_MISS_CHAR
    ,reassign_request_date          DATE	:= FND_API.G_MISS_DATE
    ,reassign_requested_person_id    NUMBER := FND_API.G_MISS_NUM
    ,downloadable_flag              VARCHAR2(1)     := FND_API.G_MISS_CHAR
    ,attribute_category             VARCHAR2(30)    := FND_API.G_MISS_CHAR
    ,attribute1                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute2                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute3                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute4                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute5                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute6                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute7                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute8                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute9                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute10                    VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute11                    VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute12                    VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute13                    VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute14                    VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,attribute15                    VARCHAR2(150)   := FND_API.G_MISS_CHAR
    ,salesforce_role_code           VARCHAR2(30)    := FND_API.G_MISS_CHAR
    ,salesforce_relationship_code   VARCHAR2(30)    := FND_API.G_MISS_CHAR
    ,salesforce_relationship    VARCHAR2(80)    := FND_API.G_MISS_CHAR
    -- <BEGIN added by ACNG>
    ,sales_lead_id                  NUMBER   := FND_API.G_MISS_NUM
    ,partner_cont_party_id          NUMBER   := FND_API.G_MISS_NUM
    -- <END>
     ,owner_flag			varchar2(1) := FND_API.G_MISS_CHAR
     ,created_by_tap_flag varchar2(1) := FND_API.G_MISS_CHAR
     ,prm_keep_flag varchar2(1) := FND_API.G_MISS_CHAR
     ,contributor_flag varchar2(1) := FND_API.G_MISS_CHAR -- Added for ASNB
    );

G_MISS_SALES_TEAM_REC              sales_team_rec_type;


-- Start of Comments
--
--  Sales Team Table:        sales_team_tbl_type
--
-- End of Comments

TYPE sales_team_tbl_type       IS TABLE OF     sales_team_rec_type
                                        INDEX BY BINARY_INTEGER;

G_MISS_SALES_TEAM_TBL         sales_team_tbl_type;

TYPE access_profile_rec_type IS RECORD
 (
	cust_access_profile_value varchar2(1),
	lead_access_profile_value varchar2(1),
        opp_access_profile_value varchar2(1) ,
        mgr_update_profile_value varchar2(1) ,
        admin_update_profile_value varchar2(1)
 ) ;



-- Start of Comments
--
--      API name        : Create_SalesTeam
--      Type            : Private
--      Function        : Insert sales team member records into the
--              sales team (access table)
--
--      Pre-reqs        : Existing Customer and Account, or Opportunity
--
--      Paramaeters     :
--      IN              :
--            p_api_version_number              IN      NUMBER,
--                p_init_msg_list                 IN      VARCHAR2
--                p_commit                        IN      VARCHAR2
--                    p_validation_level        IN    NUMBER
--      OUT             :
--                      x_return_status         OUT NOCOPY      VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY      NUMBER
--                      x_msg_data              OUT NOCOPY      VARCHAR2(2000)
--                      x_access_id             OUT NOCOPY      NUMBER
--
--      Version :       Current version 1.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for creating either an account or opportunity
--            sales team
--
--
-- End of Comments

PROCEDURE Create_SalesTeam
(       p_api_version_number              IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						DEFAULT  FND_API.G_VALID_LEVEL_FULL,
        p_access_profile_rec	IN access_profile_rec_type,
	p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2,
        x_access_id                     OUT NOCOPY      NUMBER
);


-- Start of Comments
--
--      API name        : Update_SalesTeam
--      Type            : Public
--      Function        : Update sales team member records into the
--              sales team (access table)
--
--      Pre-reqs        : Existing sales team record
--
--      Paramaeters     :
--      IN              :
--            p_api_version_number              IN      NUMBER,
--                p_init_msg_list                 IN      VARCHAR2
--                p_commit                        IN      VARCHAR2
--                    p_validation_level        IN    NUMBER
--      OUT             :
--                      x_return_status         OUT NOCOPY      VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY      NUMBER
--                      x_msg_data              OUT NOCOPY      VARCHAR2(2000)
--                      x_access_id             OUT NOCOPY      NUMBER
--
--      Version :       Current version 1.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for updating either an account or opportunity
--            sales team
--
--
-- End of Comments

PROCEDURE Update_SalesTeam
(       p_api_version_number              IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						DEFAULT  FND_API.G_VALID_LEVEL_FULL,
        p_access_profile_rec	IN access_profile_rec_type,
	p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2,
        x_access_id                     OUT NOCOPY      NUMBER
);

-- Start of Comments
--
--      API name        : Delete_SalesTeam
--      Type            : Public
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
--                      x_return_status         OUT NOCOPY      VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY      NUMBER
--                      x_msg_data              OUT NOCOPY      VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for delete either an customer or opportunity
--			sales team
--
--
-- End of Comments

PROCEDURE Delete_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						DEFAULT  FND_API.G_VALID_LEVEL_FULL,
	 p_access_profile_rec	IN access_profile_rec_type,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2
);


Procedure validate_accessProfiles
(	p_init_msg_list       IN       VARCHAR2 DEFAULT  FND_API.G_FALSE,
	p_access_profile_rec IN		ACCESS_PROFILE_REC_TYPE,
	x_return_status       OUT NOCOPY       VARCHAR2,
        x_msg_count           OUT NOCOPY       NUMBER,
        x_msg_data            OUT NOCOPY       VARCHAR2
);

/*
 This API is used for checking if login user has view access for the pass in
customer id. If the user has view access for the customer, he/she can create
contacts, update contacts, create sales leads and create opportunities for this
customer. For has view access, this API will return x_view_access_flag = 'Y',
otherwise return 'N'. */

procedure has_viewCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_view_access_flag	OUT NOCOPY  VARCHAR2
);

procedure has_updateCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_update_access_flag	OUT NOCOPY  VARCHAR2
);

procedure has_updateLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_update_access_flag	OUT NOCOPY  VARCHAR2
);

procedure has_updateOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_update_access_flag	OUT NOCOPY  VARCHAR2
);
/* p_security_id allowed are org party_id, opportunity_id and sales_lead_id
   p_security_type allowed are 'ORGANIZATION', 'OPPORTUNITY' and 'LEAD'
   p_person_party_id is person's party id. This id is required to check person's
   update access. To check consumer access, you can pass in null for
    p_security_id and p_security_type */
procedure has_updatePersonAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_security_id		IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_update_access_flag	OUT NOCOPY  VARCHAR2
);

procedure has_viewPersonAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_security_id		IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_view_access_flag	OUT NOCOPY  VARCHAR2
);
procedure has_viewLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_view_access_flag	OUT NOCOPY  VARCHAR2
);

procedure has_viewOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_view_access_flag	OUT NOCOPY  VARCHAR2
);

/*
 This API is used for checking if login user has access for the pass in
organization party id. x_access_privilege might return one of the following
three values: 'N'(no access), 'R'(read only access) and 'F'(read/update access)
*/

procedure has_organizationAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_access_privilege	OUT NOCOPY  VARCHAR2
);


/* p_security_id allowed are org party_id, opportunity_id and sales_lead_id
   p_security_type allowed are 'ORGANIZATION', 'OPPORTUNITY' and 'LEAD'
   p_person_party_id is person's party id. This id is required to check person's
   access. To check consumer access, you can pass in null for
   p_security_id and p_security_type
   x_access_privilege might return one of the following
   three values: 'N'(no access), 'R'(read only access) and 'F'(read/update access)
*/
procedure has_personAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_security_id		IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_access_privilege	OUT NOCOPY  VARCHAR2
);

/*
Wrapper on has_viewLeadAccess and has_updateLeadAccess.
x_access_privilege might return one of the following
three values: 'N'(no access), 'R'(read only access) and 'F'(read/update access)
*/
procedure has_leadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_access_privilege	OUT NOCOPY  VARCHAR2
);
/*
Wrapper on has_viewOpportunityAccess and has_updateLeadAccess.
x_access_privilege might return one of the following
three values: 'N'(no access), 'R'(read only access) and 'F'(read/update access)
*/
procedure has_opportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY  VARCHAR2
	,x_msg_count		OUT NOCOPY  NUMBER
	,x_msg_data		OUT NOCOPY  VARCHAR2
	,x_access_privilege	OUT NOCOPY  VARCHAR2
);

END AS_ACCESS_PUB;

/
