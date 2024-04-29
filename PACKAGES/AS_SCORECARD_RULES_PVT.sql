--------------------------------------------------------
--  DDL for Package AS_SCORECARD_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SCORECARD_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: asxvscos.pls 120.1 2005/06/24 17:15:18 appldev ship $ */

Procedure Create_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC           IN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                     := AS_SCORECARD_RULES_PUB.G_MISS_SCORECARD_REC,
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
                                     := AS_SCORECARD_RULES_PUB.G_MISS_SCORECARD_REC);

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


-- Validation
Procedure Validate_Seed_Qual_ID(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );

Procedure Validate_Seed_Qual_Value_Num(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    P_High_Value_Number          IN   NUMBER,
    P_Low_Value_Number           IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );

Procedure Validate_Seed_Qual_Value_Char(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    P_High_Value_Char            IN   VARCHAR2,
    P_Low_Value_Char             IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );

Procedure Validate_Seed_Qual_Value_Date(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    P_High_Value_Date            IN   DATE,
    P_Low_Value_Date             IN   DATE,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );

Procedure Validate_Seed_Qual(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CARDRULE_QUAL_rec          IN   AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );

END AS_SCORECARD_RULES_PVT;


 

/
