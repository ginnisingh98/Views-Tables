--------------------------------------------------------
--  DDL for Package PV_REFERRAL_GENERAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_REFERRAL_GENERAL_PUB" AUTHID CURRENT_USER as
/* $Header: pvxvrfgs.pls 115.4 2004/03/05 19:22:51 pklin ship $*/

-- ============================================================================
--
-- Global Variables
--
-- ============================================================================

-- ============================================================================
--
-- Public Procedures
--
-- ============================================================================

-- ------------------------------------------------------------------------
-- Update_Referral_Status
--
-- This is to be called by a concurrent program, PV_UPDATE_REFERRAL_STATUS,
-- (PV - Update Referral Status)
-- to update the referral status to one of the following four statuses:
-- CLOSED_LOST_OPPTY, CLOSED_OPPTY_WON, CLOSED_DEAD_LEAD, EXPIRED.
-- ------------------------------------------------------------------------
PROCEDURE Update_Referral_Status (
   ERRBUF              OUT  NOCOPY VARCHAR2,
   RETCODE             OUT  NOCOPY VARCHAR2,
   p_log_to_file       IN   VARCHAR2 := 'Y'
);


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



PROCEDURE Link_Lead_Opportunity (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2  := FND_API.g_false,
   p_commit                    IN  VARCHAR2  := FND_API.g_false,
   p_validation_level          IN  NUMBER    := FND_API.g_valid_level_full,
   p_referral_id               IN  VARCHAR2,
   p_entity_type               IN  VARCHAR2, -- 'LEAD', 'SALES_LEAD'
   p_entity_id                 IN  NUMBER,
   x_a_link_already_exists     OUT NOCOPY VARCHAR2,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
);


END PV_REFERRAL_GENERAL_PUB;

 

/
