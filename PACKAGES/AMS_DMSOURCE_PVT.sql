--------------------------------------------------------
--  DDL for Package AMS_DMSOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMSOURCE_PVT" AUTHID CURRENT_USER as
/* $Header: amsvdsrs.pls 115.13 2003/09/19 04:55:08 nyostos ship $ */
-- Start of Comments
-- Package name     : AMS_DMSource_PVT
-- Purpose          :
-- History          :
-- 30-jan-2001 choang   Changed p_rule_id to p_rule_id.
-- 09-Jul-2001 choang   Added bin_probability and replaced rule_id with decile.
-- 11-Jul-2001 choang   Added process_scores.
-- 26-Jul-2001 choang   Added generate_odm_input_views
-- 07-Jan-2002 choang   Removed security group id
-- 28-Jul-2003 nyostos  Added PERCENTILE column.
-- NOTE             :
-- End of Comments

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: Source_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    SOURCE_ID
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    OBJECT_VERSION_NUMBER
--    MODEL_TYPE
--    ARC_USED_FOR_OBJECT
--    USED_FOR_OBJECT_ID
--    PARTY_ID
--    SCORE_RESULT
--    TARGET_VALUE
--    CONFIDENCE
--    CONTINUOUS_SCORE
--    decile
--    PERCENTILE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Source_Rec_Type IS RECORD
(
       SOURCE_ID              NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE       DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY        NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE          DATE := FND_API.G_MISS_DATE,
       CREATED_BY             NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN      NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER  NUMBER := FND_API.G_MISS_NUM,
       MODEL_TYPE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ARC_USED_FOR_OBJECT    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       USED_FOR_OBJECT_ID     NUMBER := FND_API.G_MISS_NUM,
       PARTY_ID               NUMBER := FND_API.G_MISS_NUM,
       SCORE_RESULT           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       TARGET_VALUE           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CONFIDENCE             NUMBER := FND_API.G_MISS_NUM,
       CONTINUOUS_SCORE       NUMBER := FND_API.G_MISS_NUM,
       decile                 NUMBER := FND_API.G_MISS_NUM,
       PERCENTILE             NUMBER := FND_API.G_MISS_NUM
);

G_MISS_source_rec          Source_Rec_Type;
TYPE  dm_source_Tbl_Type      IS TABLE OF Source_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_source_TBL          dm_source_Tbl_Type;


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_source_Items (
    P_source_rec        IN    Source_Rec_Type,
    p_validation_mode   IN    VARCHAR2,
    x_return_status     OUT NOCOPY   VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Lock_Source
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_source_rec            IN   Source_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Lock_Source(
    p_api_version    IN   NUMBER,
    P_Init_Msg_List  IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status  OUT NOCOPY  VARCHAR2,
    X_Msg_Count      OUT NOCOPY  NUMBER,
    X_Msg_Data       OUT NOCOPY  VARCHAR2,

    p_SOURCE_ID      IN  NUMBER,
    p_object_version IN  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Source
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_source_rec            IN   Source_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Source(
    p_api_version       IN   NUMBER,
    P_Init_Msg_List     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status     OUT NOCOPY  VARCHAR2,
    X_Msg_Count         OUT NOCOPY  NUMBER,
    X_Msg_Data          OUT NOCOPY  VARCHAR2,

    P_source_rec        IN Source_Rec_Type  := G_MISS_source_rec,
    X_SOURCE_ID         OUT NOCOPY  NUMBER
     );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Source
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_source_rec            IN   Source_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_Source(
    p_api_version       IN   NUMBER,
    P_Init_Msg_List     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status     OUT NOCOPY  VARCHAR2,
    X_Msg_Count         OUT NOCOPY  NUMBER,
    X_Msg_Data          OUT NOCOPY  VARCHAR2,

    P_source_rec        IN    Source_Rec_Type,
    X_Object_Version_Number   OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Source
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_SOURCE_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_Source(
    p_api_version       IN   NUMBER,
    P_Init_Msg_List     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit            IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status     OUT NOCOPY  VARCHAR2,
    X_Msg_Count         OUT NOCOPY  NUMBER,
    X_Msg_Data          OUT NOCOPY  VARCHAR2,
    P_SOURCE_ID         IN  NUMBER,
    P_Object_Version_Number   IN   NUMBER
    );


-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_source_rec(
    p_api_version    IN   NUMBER,
    P_Init_Msg_List  IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status  OUT NOCOPY  VARCHAR2,
    X_Msg_Count      OUT NOCOPY  NUMBER,
    X_Msg_Data       OUT NOCOPY  VARCHAR2,
    P_source_rec     IN    Source_Rec_Type
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_Source(
    p_api_version       IN NUMBER,
    P_Init_Msg_List     IN VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode   IN VARCHAR2,
    P_source_rec        IN Source_Rec_Type,
    X_Return_Status     OUT NOCOPY VARCHAR2,
    X_Msg_Count         OUT NOCOPY NUMBER,
    X_Msg_Data          OUT NOCOPY VARCHAR2
    );


--
-- PURPOSE
--    Bin the scores for a scoring run by the probability of a positive score.
--
-- PARAMETERS
--    p_score_id - scoring run identifier.
--
-- NOTE
--    - The bin is generated from the following formula:
--       Bin = (10 - FLOOR (LEAST (99, continuous_score)/10))
--    - This procedure should be run after scores have been posted for the
--      scoring run.
--    - The probability of a positive score is represented by the continuous_score
--      field.
--
PROCEDURE bin_probability (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_score_id        IN NUMBER
);


--
-- PURPOSE
--    Extract the scoring output generated from the data mining engine, and
--    record the scores in the marketing table.
--
PROCEDURE process_scores (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_score_id        IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
);


--
-- PURPOSE
--    Generate the input data view for the data mining engine.
--
-- PARAMETERS
--    p_object_type - the type should be MODL or SCOR.
--    p_object_id - the ID of the respective object.
--    p_target_type - the type of target data, which could be either
--       persons or organization contacts.
--
-- NOTE
--    The view needs to be dynamically generated because the data
--    mining engine cannot filter on the input data.
--
-- API VERSION
--    2.0 - use data_source to determine select fields
--    1.0 - use target_group to determine select fields
--
PROCEDURE generate_odm_input_views (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER,
   p_data_source_id  IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
);

--
-- PURPOSE
--    Drops the input data views along with the synonyms
--    created for them in the ODM schema
--
-- PARAMETERS
--    p_object_type - the type should be MODL or SCOR.
--    p_object_id - the ID of the respective object.
--
-- HISTORY
--    Sep 17, 2003   nyostos     Created.
--
PROCEDURE cleanup_odm_input_views (
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER
);


End AMS_DMSource_PVT;

 

/
