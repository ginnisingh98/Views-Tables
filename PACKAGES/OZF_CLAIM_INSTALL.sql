--------------------------------------------------------
--  DDL for Package OZF_CLAIM_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_INSTALL" AUTHID CURRENT_USER AS
/* $Header: ozfgcins.pls 120.0.12010000.2 2008/12/30 04:53:14 psomyaju ship $ */
-- Start of Comments
-- Package name     : OZF_CLAIM_INSTALL
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Installed
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   Version : Current version 1.0
--
--   Note: This function checks if claims module is installed.
--
--   End of Comments
--  *******************************************************
--Bugfix : 7668608 - p_org_id parameter added
FUNCTION Check_Installed (p_org_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Amount_Remaining
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_claim_id               IN   NUMBER     Required
--
--   OUT:
--       x_amount_remaining       OUT  NUMBER
--       x_acctd_amount_remaining OUT  NUMBER
--       x_currency_code          OUT  VARCHAR2
--       x_return_status          OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   Note: This API returns the amount_remaing of the root claim.
--
--   End of Comments
--  *******************************************************
PROCEDURE Get_Amount_Remaining (
  p_claim_id               IN  NUMBER,
  x_amount_remaining       OUT NOCOPY NUMBER,
  x_acctd_amount_remaining OUT NOCOPY NUMBER,
  x_currency_code          OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Default_Setup
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--
--   Version : Current version 1.0
--
--   Note: This function checks if claims module is installed and defualt
--         sys parameters are setup.
--
--   End of Comments
--  *******************************************************
--Bugfix : 7668608 - p_org_id parameter added
FUNCTION Check_Default_Setup (p_org_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION Netting_Claims_Allowed
RETURN BOOLEAN;



END OZF_CLAIM_INSTALL;

/
