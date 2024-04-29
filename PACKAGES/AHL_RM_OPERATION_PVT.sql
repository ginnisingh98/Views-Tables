--------------------------------------------------------
--  DDL for Package AHL_RM_OPERATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_OPERATION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVOPES.pls 120.0.12010000.2 2008/11/23 14:25:14 bachandr ship $ */

TYPE operation_rec_type IS RECORD
(
        OPERATION_ID                     NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),
        STANDARD_OPERATION_FLAG          VARCHAR2(1),
        REVISION_NUMBER                  VARCHAR2(30),
        REVISION_STATUS_CODE             VARCHAR2(30),
        REVISION_STATUS                  VARCHAR2(80),
        ACTIVE_START_DATE                DATE,
        ACTIVE_END_DATE                  DATE,
        QA_INSPECTION_TYPE               VARCHAR2(150),
        QA_INSPECTION_TYPE_DESC          VARCHAR2(150),
        OPERATION_TYPE_CODE              VARCHAR2(30),
        OPERATION_TYPE                   VARCHAR2(80),
        PROCESS_CODE                     VARCHAR2(30),
        PROCESS                          VARCHAR2(80),
        --bachandr Enigma Phase I changes -- start
        MODEL_CODE                       VARCHAR2(30),
        MODEL_MEANING                    VARCHAR2(80),
        ENIGMA_OP_ID                     VARCHAR2 (80),
        --bachandr Enigma Phase I changes -- end
        DESCRIPTION                      VARCHAR2(2000),
        REMARKS                          VARCHAR2(2000),
        REVISION_NOTES                   VARCHAR2(2000),
        CONCATENATED_SEGMENTS            AHL_OPERATIONS_V.CONCATENATED_SEGMENTS%TYPE,
        SEGMENT1                         VARCHAR2(30),
        SEGMENT2                         VARCHAR2(30),
        SEGMENT3                         VARCHAR2(30),
        SEGMENT4                         VARCHAR2(30),
        SEGMENT5                         VARCHAR2(30),
        SEGMENT6                         VARCHAR2(30),
        SEGMENT7                         VARCHAR2(30),
        SEGMENT8                         VARCHAR2(30),
        SEGMENT9                         VARCHAR2(30),
        SEGMENT10                        VARCHAR2(30),
        SEGMENT11                        VARCHAR2(30),
        SEGMENT12                        VARCHAR2(30),
        SEGMENT13                        VARCHAR2(30),
        SEGMENT14                        VARCHAR2(30),
        SEGMENT15                        VARCHAR2(30),
        ATTRIBUTE_CATEGORY               VARCHAR2(30),
        ATTRIBUTE1                       VARCHAR2(150),
        ATTRIBUTE2                       VARCHAR2(150),
        ATTRIBUTE3                       VARCHAR2(150),
        ATTRIBUTE4                       VARCHAR2(150),
        ATTRIBUTE5                       VARCHAR2(150),
        ATTRIBUTE6                       VARCHAR2(150),
        ATTRIBUTE7                       VARCHAR2(150),
        ATTRIBUTE8                       VARCHAR2(150),
        ATTRIBUTE9                       VARCHAR2(150),
        ATTRIBUTE10                      VARCHAR2(150),
        ATTRIBUTE11                      VARCHAR2(150),
        ATTRIBUTE12                      VARCHAR2(150),
        ATTRIBUTE13                      VARCHAR2(150),
        ATTRIBUTE14                      VARCHAR2(150),
        ATTRIBUTE15                      VARCHAR2(150),
        DML_OPERATION                    VARCHAR2(1)
);

-- Start of Comments
-- Procedure name              : process_operation
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- process_operation IN parameters:
--      None
--
-- process_operation IN OUT parameters:
--      p_x_operation_rec           operation_rec_type Required
--
-- process_operation OUT parameters:
--      None
--
-- Version:
--      Current version        1.0
--
-- End of Comments

PROCEDURE process_operation
(
 p_api_version        IN            NUMBER     := 1.0,
 p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN            VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count          OUT NOCOPY    NUMBER,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_x_operation_rec    IN OUT NOCOPY operation_rec_type
);

-- Start of Comments
-- Procedure name              : delete_operation
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- delete_operation IN parameters:
--      p_operation_id              NUMBER   Required
--      p_object_version_number     NUMBER   Required
--
-- delete_operation IN OUT parameters:
--      None
--
-- delete_operation OUT parameters:
--      None
--
-- Version:
--      Current version        1.0
--
-- End of Comments

PROCEDURE delete_operation
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2   := NULL,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 p_operation_id          IN            NUMBER,
 p_object_version_number IN            NUMBER
);

-- Start of Comments
-- Procedure name              : create_oper_revision
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- create_oper_revision IN parameters:
--      p_operation_id              NUMBER   Required
--      p_object_version_number     NUMBER   Required
--
-- create_oper_revision IN OUT parameters:
--      None
--
-- create_oper_revision OUT parameters:
--      x_operation_id              NUMBER   Required
--
-- Version:
--      Current version        1.0
--
-- End of Comments

PROCEDURE create_oper_revision
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2   := NULL,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 p_operation_id          IN            NUMBER,
 p_object_version_number IN            NUMBER,
 x_operation_id          OUT NOCOPY    NUMBER
);

END AHL_RM_OPERATION_PVT;

/
