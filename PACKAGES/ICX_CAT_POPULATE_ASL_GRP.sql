--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_ASL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_ASL_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXGPPAS.pls 120.0 2005/10/19 11:07:24 sbgeorge noship $*/

PROCEDURE populateOnlineASLs
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
);

PROCEDURE populateOnlineASLStatusRule
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
);

END ICX_CAT_POPULATE_ASL_GRP;

 

/
