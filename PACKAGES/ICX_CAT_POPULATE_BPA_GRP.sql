--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_BPA_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_BPA_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXGPPBS.pls 120.0 2005/10/19 11:06:52 sbgeorge noship $*/

PROCEDURE populateOnlineBlankets
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
);

PROCEDURE populateOnlineOrgAssgnmnts
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
);

END ICX_CAT_POPULATE_BPA_GRP;

 

/
