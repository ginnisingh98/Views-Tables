--------------------------------------------------------
--  DDL for Package OKC_REP_CONTRACT_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_CONTRACT_SEARCH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPSRCHS.pls 120.1 2005/08/22 10:01:55 dzima noship $ */

-----------------------------------------
-- Procedure for contracts
-----------------------------------------

-- Start of comments
--API name      : update_text_index
--Type          : Private.
--Function      : Updates Repository text index.
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

PROCEDURE update_text_index(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : update_text_index
--Type          : Private.
--Function      : Updates Repository text index.
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

PROCEDURE optimize_text_index(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

-- Start of comments
--API name      : update_text_index_ctx
--Type          : Private.
--Function      : Called from Concurrent Manager to update
--                Repository text index
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

PROCEDURE update_text_index_ctx(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER
);

-- Start of comments
--API name      : optimize_text_index_ctx
--Type          : Private.
--Function      : Called from Concurrent Manager to optimize
--                Repository text index
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

PROCEDURE optimize_text_index_ctx(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER
);

END;


 

/
