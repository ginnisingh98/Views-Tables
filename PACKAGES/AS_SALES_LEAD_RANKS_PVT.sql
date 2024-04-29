--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_RANKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_RANKS_PVT" AUTHID CURRENT_USER AS
/* #$Header: asxvrnks.pls 115.8 2003/06/30 21:27:01 solin ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_RANKS_PVT
-- Purpose          : to add ranks into AS_SALES_LEAD_RANKS_B and _TL
-- History          : 07/24/2000 raverma created
-- NOTE             :
-- End of Comments

/*
  -- type is declared in Public API this is ONLY for reference
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
        DESCRIPTION         VARCHAR2(240)   ,
        RANK_CODE           VARCHAR2(15)
        );
*/


PROCEDURE Validate_Score_Range (
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode     IN   VARCHAR2,
    p_sales_lead_rank_rec IN   AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
    p_is_old_engine	  IN   VARCHAR2,
    X_Return_Status       OUT NOCOPY  VARCHAR2,
    X_Msg_Count           OUT NOCOPY  NUMBER,
    X_Msg_Data            OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_Rank_Meaning (
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode     IN   VARCHAR2,
    p_sales_lead_rank_rec IN   AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
    X_Return_Status       OUT NOCOPY  VARCHAR2,
    X_Msg_Count           OUT NOCOPY  NUMBER,
    X_Msg_Data            OUT NOCOPY  VARCHAR2
    );

Procedure Create_Rank (
    p_api_version         IN NUMBER := 2.0,
    p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
    x_sales_lead_rank_id  OUT NOCOPY NUMBER);

Procedure Update_Rank (
    p_api_version         IN NUMBER := 2.0,
    p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type);

Procedure Delete_Rank (
    p_api_version         IN NUMBER := 2.0,
    p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_sales_lead_rank_id  IN NUMBER);

PROCEDURE UPDATE_LEAD_RANK_SCORE(
  ERRBUF                  OUT NOCOPY VARCHAR2,
  RETCODE                 OUT NOCOPY VARCHAR2,
  X_LEAD_RANK_ID          IN         NUMBER,
  X_LEAD_RANK_SCORE       IN         NUMBER);

PROCEDURE Write_Log(p_which NUMBER, p_msg  VARCHAR2);

END AS_SALES_LEAD_RANKS_PVT;

 

/
