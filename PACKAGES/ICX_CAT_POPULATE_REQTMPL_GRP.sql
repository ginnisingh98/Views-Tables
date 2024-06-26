--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_REQTMPL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_REQTMPL_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXGPPRS.pls 120.0 2005/10/19 11:07:14 sbgeorge noship $*/

PROCEDURE populateOnlineReqTemplates
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
);

END ICX_CAT_POPULATE_REQTMPL_GRP;

 

/
