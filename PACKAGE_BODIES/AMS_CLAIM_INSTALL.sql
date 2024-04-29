--------------------------------------------------------
--  DDL for Package Body AMS_CLAIM_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CLAIM_INSTALL" as
/* $Header: amsgcinb.pls 115.13 2004/04/06 19:33:40 julou ship $ */

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
FUNCTION Check_Installed return boolean
IS

BEGIN

  return OZF_CLAIM_INSTALL.Check_Installed;

EXCEPTION
  WHEN OTHERS THEN
     return FALSE;
End Check_Installed ;


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
)
IS


BEGIN

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OZF_CLAIM_INSTALL.Get_Amount_Remaining (
      p_claim_id               => p_claim_id,
      x_amount_remaining       => x_amount_remaining,
      x_acctd_amount_remaining => x_acctd_amount_remaining,
      x_currency_code          => x_currency_code,
      x_return_status          => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAM_GET_AMTREM_ERR');
         FND_MSG_PUB.add;
      END IF;
END Get_Amount_Remaining;

End AMS_Claim_Install;

/
