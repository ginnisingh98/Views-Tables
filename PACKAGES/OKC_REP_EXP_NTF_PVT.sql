--------------------------------------------------------
--  DDL for Package OKC_REP_EXP_NTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_EXP_NTF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPEXNTFS.pls 120.0 2005/05/25 18:27:16 appldev noship $ */

-- Start of comments
--API name      : submit_contract_for_approval
--Type          : Private.
--Function      : Iterates through contracts that are about to expire
--                and calls repository_notifier() procedure
--                for all of them. This procedure will send notifications
--                to all contract contacts.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE contract_expiration_notifier(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : contract_expiration_manager
--Type          : Private.
--Function      : Called from Concurrent Manager to send
--                notifications to contract contacts for
--                contracts that are about to expire
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments
PROCEDURE contract_expiration_manager(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2);

END OKC_REP_EXP_NTF_PVT;

 

/
