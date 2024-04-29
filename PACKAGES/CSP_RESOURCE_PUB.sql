--------------------------------------------------------
--  DDL for Package CSP_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_RESOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: cspgtres.pls 115.5 2002/11/26 06:39:07 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_RESOURCE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CSP_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    CSP_INV_LOC_ASSIGNMENT_ID
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    RESOURCE_ID
--    ORGANIZATION_ID
--    SUBINVENTORY_CODE
--    LOCATOR_ID
--    RESOURCE_TYPE
--    EFFECTIVE_DATE_START
--    EFFECTIVE_DATE_END
--    DEFAULT_CODE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE CSP_Rec_Type IS RECORD
(
       CSP_INV_LOC_ASSIGNMENT_ID       NUMBER := FND_API.G_MISS_NUM,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       RESOURCE_ID                     NUMBER := FND_API.G_MISS_NUM,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       SUBINVENTORY_CODE               VARCHAR2(20) := FND_API.G_MISS_CHAR,
       LOCATOR_ID                      NUMBER := FND_API.G_MISS_NUM,
       RESOURCE_TYPE                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       EFFECTIVE_DATE_START            DATE := FND_API.G_MISS_DATE,
       EFFECTIVE_DATE_END              DATE := FND_API.G_MISS_DATE,
       DEFAULT_CODE                    VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_CSP_REC          CSP_Rec_Type;
TYPE  CSP_Tbl_Type      IS TABLE OF CSP_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_CSP_TBL          CSP_Tbl_Type;

TYPE CSP_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      CREATED_BY   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_resource
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CSP_Rec     IN CSP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
Procedure ASSIGN_RESOURCE_INV_LOC (
   P_Api_Version_Number             IN   NUMBER
    ,P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE
    ,P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_action_code                  IN   NUMBER
    ,px_CSP_INV_LOC_ASSIGNMENT_ID   IN OUT NOCOPY  NUMBER
    ,p_CREATED_BY                   IN   NUMBER
    ,p_CREATION_DATE                IN   DATE
    ,p_LAST_UPDATED_BY              IN   NUMBER
    ,p_LAST_UPDATE_DATE             IN   DATE
    ,p_LAST_UPDATE_LOGIN            IN   NUMBER
    ,p_RESOURCE_ID                  IN   NUMBER
    ,p_ORGANIZATION_ID              IN   NUMBER
    ,p_SUBINVENTORY_CODE            IN   VARCHAR2
    ,p_LOCATOR_ID                   IN   NUMBER
    ,p_RESOURCE_TYPE                IN   VARCHAR2
    ,p_EFFECTIVE_DATE_START         IN   DATE
    ,p_EFFECTIVE_DATE_END           IN   DATE
    ,p_DEFAULT_CODE                 IN   VARCHAR2
    ,p_ATTRIBUTE_CATEGORY           IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE1                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE2                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE3                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE4                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE5                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE6                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE7                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE8                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE9                   IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE10                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE11                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE12                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE13                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE14                  IN   VARCHAR2 := NULL
    ,p_ATTRIBUTE15                  IN   VARCHAR2 := NULL
    ,x_return_status                OUT NOCOPY  VARCHAR2
    ,x_msg_count                    OUT NOCOPY  NUMBER
    ,x_msg_data                     OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_Assignment_Record (
        p_resource_id           IN  NUMBER
       ,p_resource_type         IN  VARCHAR2
       ,p_organization_id       IN  NUMBER
       ,p_subinventory_code     IN  VARCHAR2
       ,p_default_code          IN  VARCHAR2
       ,x_return_status         OUT NOCOPY VARCHAR2
);

End CSP_RESOURCE_PUB;

 

/
