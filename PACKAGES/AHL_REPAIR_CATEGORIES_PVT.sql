--------------------------------------------------------
--  DDL for Package AHL_REPAIR_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_REPAIR_CATEGORIES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRCTS.pls 120.0 2005/07/04 03:28 tamdas noship $ */

G_APP_NAME  CONSTANT    VARCHAR2(3)     := 'AHL';               -- Use for all FND_MESSAGE.SET_NAME calls
G_PKG_NAME  CONSTANT    VARCHAR2(30)    := 'AHL_REPAIR_CATEGORIES_PVT'; -- Use for all debug messages, FND_API.COMPATIBLE_API_CALL, etc

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Repair_Category_Rec_Type IS RECORD
(
    REPAIR_CATEGORY_ID          NUMBER,
    OBJECT_VERSION_NUMBER       NUMBER,
    INCIDENT_URGENCY_ID         NUMBER,
    INCIDENT_URGENCY_NAME       VARCHAR2 (50),
    REPAIR_TIME                 NUMBER,
    ATTRIBUTE_CATEGORY          VARCHAR2 (30),
    ATTRIBUTE1                  VARCHAR2 (150),
    ATTRIBUTE2                  VARCHAR2 (150),
    ATTRIBUTE3                  VARCHAR2 (150),
    ATTRIBUTE4                  VARCHAR2 (150),
    ATTRIBUTE5                  VARCHAR2 (150),
    ATTRIBUTE6                  VARCHAR2 (150),
    ATTRIBUTE7                  VARCHAR2 (150),
    ATTRIBUTE8                  VARCHAR2 (150),
    ATTRIBUTE9                  VARCHAR2 (150),
    ATTRIBUTE10                 VARCHAR2 (150),
    ATTRIBUTE11                 VARCHAR2 (150),
    ATTRIBUTE12                 VARCHAR2 (150),
    ATTRIBUTE13                 VARCHAR2 (150),
    ATTRIBUTE14                 VARCHAR2 (150),
    ATTRIBUTE15                 VARCHAR2 (150),
    DML_OPERATION               VARCHAR2 (1)
);

TYPE Repair_Category_Tbl_Type IS TABLE OF Repair_Category_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name      : Process_Repair_Categories
--  Type                : Private
--  Description         : This procedure creates, updates and deletes repair categories from SR incident urgencies.
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_x_repair_category_tbl     Repair_Category_Tbl_Type                Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Process_Repair_Categories
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_repair_category_tbl     IN OUT NOCOPY   Repair_Category_Tbl_Type
);

End AHL_REPAIR_CATEGORIES_PVT;

 

/
