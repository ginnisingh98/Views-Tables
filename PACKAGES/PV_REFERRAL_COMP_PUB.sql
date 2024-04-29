--------------------------------------------------------
--  DDL for Package PV_REFERRAL_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_REFERRAL_COMP_PUB" AUTHID CURRENT_USER as
/* $Header: pvxvrfcs.pls 115.1 2003/11/23 03:10:49 pklin ship $*/

-- ----------------------------------------------------------------------------
-- Global Variables
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Public Procedures
-- ----------------------------------------------------------------------------
PROCEDURE Get_Beneficiary (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   p_order_header_id       IN  NUMBER,
   p_order_line_id         IN  NUMBER,
   p_offer_id              IN  NUMBER,
   x_beneficiary_id        OUT NOCOPY NUMBER,
   x_referral_id           OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
);


PROCEDURE Check_Order_Completion (
   ERRBUF              OUT  NOCOPY VARCHAR2,
   RETCODE             OUT  NOCOPY VARCHAR2,
   p_log_to_file       IN   VARCHAR2 := 'Y'
);


PROCEDURE Update_Referral_Status (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   p_offer_id              IN  NUMBER,
   p_pass_validation_flag  IN  VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
);


END PV_REFERRAL_COMP_PUB;

 

/
