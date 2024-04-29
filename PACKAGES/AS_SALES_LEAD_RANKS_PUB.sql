--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_RANKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_RANKS_PUB" AUTHID CURRENT_USER AS
/* #$Header: asxprnks.pls 115.5 2002/11/22 08:03:30 ckapoor ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_RANKS_PUB
-- Purpose          : to add ranks into AS_SALES_LEAD_RANKS_B and _TL
-- History          : 07/24/2000 raverma created
-- NOTE             :
-- End of Comments

  TYPE sales_lead_rank_rec_type IS RECORD (
        RANK_ID             NUMBER          ,
        LAST_UPDATE_DATE    DATE            ,
        LAST_UPDATE_LOGIN   NUMBER          ,
        CREATED_BY          NUMBER          ,
        CREATION_DATE       DATE            ,
        LAST_UPDATED_BY     NUMBER          ,
        MIN_SCORE           NUMBER          ,
        MAX_SCORE           NUMBER          ,
        ENABLED_FLAG        VARCHAR2(1)     ,
        MEANING             VARCHAR2(240)   ,
        DESCRIPTION         VARCHAR2(240)
        );
Procedure Create_Rank (p_api_version         IN NUMBER := 2.0,
                       p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                       p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level    IN NUMBER :=
                                                       FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
                       p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
                       x_sales_lead_rank_id  OUT NOCOPY NUMBER);

Procedure Update_Rank (p_api_version         IN NUMBER := 2.0,
                       p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                       p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level    IN NUMBER :=
                                                       FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
                       p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type);

Procedure Delete_Rank (p_api_version         IN NUMBER := 2.0,
                       p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                       p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level    IN NUMBER :=
                                                       FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
                       p_sales_lead_rank_id  IN NUMBER);
END;

 

/
