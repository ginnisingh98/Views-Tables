--------------------------------------------------------
--  DDL for Package AS_OPP_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPP_COPY_PVT" AUTHID CURRENT_USER as
/* $Header: asxvlcps.pls 115.8 2002/12/10 19:33:41 kichan ship $ */
-- Start of Comments
-- Package name     : AS_OPP_COPY_PVT
-- Purpose          :
-- History          : 09-OCT-00 	XDING  	Created
-- NOTE             :
-- End of Comments-- Start of Comments
--
--    API name:     Copy_Opportunity
--
--    Function:     To copy an existing opportunity header with/without
--		    the salesteam, opportunity lines, sales_credits, contacts
--		    and competitors
--
--    Note:	    1. If the p_sales_credits = FND_API.G_TRUE then
--                     the p_opp_lines must be FND_API.G_TRUE.
-- 		    2. If the p_copy_salesteam is FALSE the salesteam
--                     will be defaulted as in creating a new opportunity.
--		    3. If the p_copy_sales_credit is FALSE then the
--                     the sales credits will be defaulted 100% to the
--                     logon salesforce.
--
--
--    Parameter specifications:
--    	p_lead_id 		- which opportunity you want to copy from
--      p_description           - name of opportunity
--      p_copy_salesteam        - whether to copy the sales team
--      p_copy_opp_lines	- whether to copy the opportunity lines
--      p_copy_lead_contacts    - whether to copy the opportunity contacts
--	p_copy_lead_competitors - whether to copy the opportunity competitors
--      p_copy_sales_credits 	- whether to copy the sales credits
--
-- End of Comments

PROCEDURE Copy_Opportunity
(   p_api_version_number            IN    NUMBER,
    p_init_msg_list                 IN    VARCHAR2  	:=FND_API.G_FALSE,
    p_commit                        IN    VARCHAR2   	:= FND_API.G_FALSE,
    p_validation_level      	    IN    NUMBER   	:= FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                       IN    NUMBER,
    p_description                   IN    VARCHAR2,
    p_copy_salesteam		    IN    VARCHAR2	:=FND_API.G_FALSE,
    p_copy_opp_lines		    IN    VARCHAR2	:=FND_API.G_FALSE,
    p_copy_lead_contacts     	    IN    VARCHAR2	:=FND_API.G_FALSE,
    p_copy_lead_competitors         IN    VARCHAR2	:=FND_API.G_FALSE,
    p_copy_sales_credits	    IN    VARCHAR2	:=FND_API.G_FALSE,
    p_copy_methodology	    	    IN    VARCHAR2     	:=FND_API.G_FALSE,
    p_new_customer_id		    IN 	  NUMBER,
    p_new_address_id		    IN    NUMBER,
    p_check_access_flag     	    IN 	  VARCHAR2,
    p_admin_flag	    	    IN 	  VARCHAR2,
    p_admin_group_id	    	    IN	  NUMBER,
    p_identity_salesforce_id 	    IN	  NUMBER,
    p_salesgroup_id		    IN    NUMBER        := NULL,
    p_partner_cont_party_id	    IN    NUMBER,
    p_profile_tbl	    	    IN	  AS_UTILITY_PUB.Profile_Tbl_Type
					  :=AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status                 OUT NOCOPY   VARCHAR2,
    x_msg_count                     OUT NOCOPY   NUMBER,
    x_msg_data                      OUT NOCOPY   VARCHAR2,
    x_lead_id                       OUT NOCOPY   NUMBER
);

End AS_OPP_COPY_PVT;

 

/
