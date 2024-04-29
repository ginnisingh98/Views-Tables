--------------------------------------------------------
--  DDL for Package AMS_CLAIM_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CLAIM_INSTALL" AUTHID CURRENT_USER as
/* $Header: amsgcins.pls 115.7 2004/04/06 19:33:40 julou ship $ */
-- Start of Comments
-- Package name     : AMS_Claim_Install
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
--   IN
--
--   OUT:
--   Version : Current version 1.0
--
--   Note: This function checks if claims module is installed
--
--   End of Comments
--
FUNCTION Check_Installed return boolean;

/*=======================================================================*
 | API Name  : Get_Amount_Remaining
 | Type      : Public
 | Pre-Req   :
 | Parameters:
 |    IN
 |       p_claim_id               IN   NUMBER     Required
 |    OUT
 |       x_amount_remaining       OUT NOCOPY  NUMBER
 |       x_acctd_amount_remaining OUT NOCOPY  NUMBER
 |       x_currency_code          OUT NOCOPY  VARCHAR2
 |       x_return_status          OUT NOCOPY  VARCHAR2
 | Version   : Current version 1.0
 | Note      : This API returns the amount_remaing of the root claim.
 |
 | History   :
 |    28-MAY-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Get_Amount_Remaining (
  p_claim_id               IN  NUMBER,
  x_amount_remaining       OUT NOCOPY NUMBER,
  x_acctd_amount_remaining OUT NOCOPY NUMBER,
  x_currency_code          OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

End AMS_Claim_Install;

 

/
