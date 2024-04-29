--------------------------------------------------------
--  DDL for Package PV_REFERRAL_DQM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_REFERRAL_DQM_PUB" AUTHID CURRENT_USER as
/* $Header: pvxvdqms.pls 115.0 2003/12/12 01:51:06 amaram noship $*/

-- ============================================================================
--
-- Global Variables
--
-- ============================================================================

-- ============================================================================

-- ------------------------------------------------------------------------
-- Create_Lead_Opportunity
--
-- THis procedure is used for creating a lead/opportunity for a referral.
-- ------------------------------------------------------------------------
PROCEDURE Create_Lead_Opportunity (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2  := FND_API.g_false,
   p_commit                    IN  VARCHAR2  := FND_API.g_false,
   p_validation_level          IN  NUMBER    := FND_API.g_valid_level_full,
   p_referral_id               IN  NUMBER,
   p_customer_party_id         IN  NUMBER  := NULL,
   p_customer_party_site_id    IN  NUMBER  := NULL,
   p_customer_org_contact_id   IN  NUMBER  := NULL,
   p_customer_contact_party_id IN  NUMBER  := NULL,
   p_get_from_db_flag          IN  VARCHAR2 := 'Y',
   x_entity_type               OUT NOCOPY VARCHAR2,
   x_entity_id                 OUT NOCOPY NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
);


END PV_REFERRAL_DQM_PUB;

 

/
