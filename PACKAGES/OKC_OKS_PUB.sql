--------------------------------------------------------
--  DDL for Package OKC_OKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OKS_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPOKSS.pls 120.0 2005/05/26 09:29:43 appldev noship $ */
--------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
G_UNEXPECTED_ERROR          		CONSTANT VARCHAR2(200) := 'OKC_RENEW_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN              		CONSTANT VARCHAR2(200) := 'SQLcode';
G_SQLERRM_TOKEN              		CONSTANT VARCHAR2(200) := 'SQLerrm';


---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_OKS_PUB';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  OKS_UPDATE_CONTRACT
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_from_id          NUMBER   - Id of the Old Parent
   --     p_to_id            NUMBER   - Id of the New Parent
   --   OUT:
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   End of Comments
   --

PROCEDURE OKS_UPDATE_CONTRACT
(    p_from_id         IN   hz_merge_parties.from_party_id%type,
     p_to_id           IN   hz_merge_parties.to_party_id%type,
     x_return_status   OUT NOCOPY  VARCHAR2);

--   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  IS_RENEW_ALLOWED
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_chr_id           NUMBER   - Contract id
   --   OUT:
   --     x_return_status    VARCHAR2 - Return status
   --
   --   End of Comments
   --
FUNCTION Is_Renew_Allowed(p_chr_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

FUNCTION VALIDATE_OKS_LINES(p_chr_id        IN  NUMBER
                            ) RETURN VARCHAR2;

END OKC_OKS_PUB;



 

/
