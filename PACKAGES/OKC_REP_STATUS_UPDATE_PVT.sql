--------------------------------------------------------
--  DDL for Package OKC_REP_STATUS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_STATUS_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPSTATCHS.pls 120.0 2005/05/26 09:31:26 appldev noship $ */

-- Start of comments
--API name      : contract_status_updater
--Type          : Private.
--Function      : Updates status for contracts
--                reaching their termination date
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Required
--              : p_status              IN VARCHAR2     Required
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE contract_status_updater(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  p_status        IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : contract_status_update_manager
--Type          : Private.
--Function      : Called from Concurrent Manager to update
--                status for contract reaching their
--                termination date
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

  PROCEDURE contract_status_update_manager(
    p_status IN VARCHAR2,
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2);

 END OKC_REP_STATUS_UPDATE_PVT;

 

/
