--------------------------------------------------------
--  DDL for Package AHL_MEL_CDL_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MEL_CDL_HEADERS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMEHS.pls 120.0 2005/07/04 02:58 tamdas noship $ */

G_APP_NAME  CONSTANT    VARCHAR2(3)     := 'AHL';                       -- Use for all FND_MESSAGE.SET_NAME calls
G_PKG_NAME  CONSTANT    VARCHAR2(30)    := 'AHL_MEL_CDL_HEADERS_PVT';   -- Use for all debug messages, FND_API.COMPATIBLE_API_CALL, etc

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Header_Rec_Type IS RECORD
(
    MEL_CDL_HEADER_ID           NUMBER,
    OBJECT_VERSION_NUMBER       NUMBER,
    PC_NODE_ID                  NUMBER,
    MEL_CDL_TYPE_CODE           VARCHAR2 (30),
    MEL_CDL_TYPE_MEANING        VARCHAR2 (80),
    STATUS_CODE                 VARCHAR2 (30),
    STATUS_MEANING              VARCHAR2 (80),
    REVISION                    VARCHAR2 (30),
    VERSION_NUMBER              NUMBER,
    REVISION_DATE               DATE,
    EXPIRED_DATE                DATE,
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
    ATTRIBUTE15                 VARCHAR2 (150)
);

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name      : Create_Mel_Cdl
--  Type                : Private
--  Description         : This procedure creates a MEL/CDL
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
--      p_x_mel_cdl_header_rec      Header_Rec_Type                         Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Create_Mel_Cdl
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_mel_cdl_header_rec      IN OUT NOCOPY   Header_Rec_Type
);

--  Start of Comments  --
--
--  Procedure name      : Update_Mel_Cdl
--  Type                : Private
--  Description         : This procedure updates a MEL/CDL
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
--      p_x_mel_cdl_header_rec      Header_Rec_Type                         Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Update_Mel_Cdl
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_mel_cdl_header_rec      IN OUT NOCOPY   Header_Rec_Type
);

--  Start of Comments  --
--
--  Procedure name      : Delete_Mel_Cdl
--  Type                : Private
--  Description         : This procedure deletes a MEL/CDL and its associations
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
--      p_mel_cdl_header_id         NUMBER                                  Required
--      p_mel_cdl_object_version    NUMBER                                  Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Delete_Mel_Cdl
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id         IN              NUMBER,
    p_mel_cdl_object_version    IN              NUMBER
);

--  Start of Comments  --
--
--  Procedure name      : Create_Mel_Cdl_Revision
--  Type                : Private
--  Description         : This procedure creates a new revision of an existing MEL/CDL and its associations
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
--      p_mel_cdl_header_id         NUMBER                                  Required
--      p_mel_cdl_object_version    NUMBER                                  Required
--      x_new_mel_cdl_header_id     NUMBER                                  Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Create_Mel_Cdl_Revision
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id         IN              NUMBER,
    p_mel_cdl_object_version    IN              NUMBER,
    x_new_mel_cdl_header_id     OUT NOCOPY      NUMBER
);

--  Start of Comments  --
--
--  Procedure name      : Initiate_Mel_Cdl_Approval
--  Type                : Private
--  Description         : This procedure submits an existing MEL/CDL for approval
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
--      p_mel_cdl_header_id         NUMBER                                  Required
--      p_mel_cdl_object_version    NUMBER                                  Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Initiate_Mel_Cdl_Approval
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id         IN              NUMBER,
    p_mel_cdl_object_version    IN              NUMBER
);

End AHL_MEL_CDL_HEADERS_PVT;

 

/
