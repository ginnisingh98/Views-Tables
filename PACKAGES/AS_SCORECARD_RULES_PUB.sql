--------------------------------------------------------
--  DDL for Package AS_SCORECARD_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SCORECARD_RULES_PUB" AUTHID CURRENT_USER AS
/* $Header: asxpscos.pls 120.1 2005/06/24 16:56:03 appldev ship $ */

TYPE CARDRULE_QUAL_REC_TYPE IS RECORD (
    QUAL_VALUE_ID           NUMBER      ,
    LAST_UPDATE_DATE        DATE        ,
    LAST_UPDATED_BY         NUMBER      ,
    CREATION_DATE           DATE        ,
    CREATED_BY              NUMBER      ,
    LAST_UPDATE_LOGIN       NUMBER      ,
    SCORECARD_ID            NUMBER      ,
    SCORE                   NUMBER      ,
    CARD_RULE_ID            NUMBER      ,
    SEED_QUAL_ID            NUMBER      ,
    HIGH_VALUE_NUMBER       NUMBER      ,
    LOW_VALUE_NUMBER        NUMBER      ,
    HIGH_VALUE_CHAR         VARCHAR2(60),
    LOW_VALUE_CHAR          VARCHAR2(60),
    CURRENCY_CODE           VARCHAR2(15),
    LOW_VALUE_DATE          DATE        ,
    HIGH_VALUE_DATE         DATE        ,
    START_DATE_ACTIVE       DATE        ,
    END_DATE_ACTIVE         DATE);

G_MISS_CARDRULE_QUAL_REC     AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE ;
TYPE CARDRULE_QUAL_Tbl_Type  IS TABLE OF AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE
                                      INDEX BY BINARY_INTEGER;
G_MISS_CARDRULE_QUAL_TBL          AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_Tbl_Type;

TYPE SCORECARD_REC_TYPE IS RECORD (
    SCORECARD_ID           NUMBER        ,
    LAST_UPDATE_DATE       DATE          ,
    LAST_UPDATED_BY        NUMBER        ,
    CREATION_DATE          DATE          ,
    CREATED_BY             NUMBER        ,
    LAST_UPDATE_LOGIN      NUMBER        ,
    DESCRIPTION            VARCHAR2(240) ,
    ENABLED_FLAG           VARCHAR2(1)   ,
    START_DATE_ACTIVE      DATE          ,
    END_DATE_ACTIVE        DATE);
G_MISS_SCORECARD_REC          AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE;

  -- Start of comments
  -- API name   : Init_AS_SCORECARD_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by AS_SCORECARD_RULES_PUB
  -- Parameters : None
  -- Returns    : AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_AS_SCORECARD_Rec RETURN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE;

  -- Start of comments
  -- API name   : Init_AS_CARDRULE_QUAL_Rec
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by AS_SCORECARD_RULES_PUB
  -- Parameters : None
  -- Returns    : AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_AS_CARDRULE_QUAL_Rec RETURN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE;

  -- Start of comments
  -- API name   : Init_AS_CARDRULE_QUAL_Tbl
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns a new raw SQL query record type
  --              as required by AS_SCORECARD_RULES_PUB
  -- Parameters : None
  -- Returns    : AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_Tbl_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments
  FUNCTION Init_AS_CARDRULE_QUAL_Tbl RETURN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_Tbl_TYPE;

Procedure Create_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC           IN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                                          := G_MISS_SCORECARD_REC,
    X_SCORECARD_ID            OUT NOCOPY  NUMBER);

Procedure Update_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC           IN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                     := G_MISS_SCORECARD_REC);

Procedure Delete_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_ID            IN NUMBER);

Procedure Create_CardRule_QUAL (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_CardRule_Qual_rec       IN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE,
    x_qual_value_id           OUT NOCOPY  NUMBER);

Procedure Update_CardRule_QUAL (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_CardRule_Qual_rec       IN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE);

-- pass in the qual value Id
Procedure Delete_CardRule_QUAL (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_qual_value_id           IN NUMBER);



END AS_SCORECARD_RULES_PUB;

 

/
