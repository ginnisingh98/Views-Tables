--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_EFFECTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_EFFECTIVITY_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMRES.pls 120.0 2005/05/26 00:06:31 appldev noship $ */

TYPE effectivity_rec_type IS RECORD
(
        MR_EFFECTIVITY_ID                NUMBER,
        NAME                             VARCHAR2(80),
        OBJECT_VERSION_NUMBER            NUMBER,
        ITEM_NUMBER                      VARCHAR2(40),
        INVENTORY_ITEM_ID                NUMBER,
        POSITION_REF_MEANING             VARCHAR2(80),
        RELATIONSHIP_ID                  NUMBER,
        POSITION_ITEM_NUMBER             VARCHAR2(40),
        POSITION_INVENTORY_ITEM_ID       NUMBER,
        PC_NODE_ID                       NUMBER,
        PC_NODE_NAME                     VARCHAR2(240),
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
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),
        DML_OPERATION                    VARCHAR2(1)
);

TYPE effectivity_tbl_type IS TABLE OF effectivity_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : process_effectivity
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
-- process_effectivity IN parameters:
--      p_mr_header_id              NUMBER               Required
--
-- process_effectivity IN OUT parameters:
--      p_x_effectivity_tbl         effectivity_tbl_type Required
--
-- process_effectivity OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_effectivity
(
 p_api_version        IN            NUMBER     := '1.0',
 p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN            VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count          OUT NOCOPY    NUMBER,
 x_msg_data           OUT NOCOPY   VARCHAR2,
 p_x_effectivity_tbl  IN OUT NOCOPY effectivity_tbl_type,
 p_mr_header_id       IN            NUMBER,
 p_super_user         IN            VARCHAR2
);

END AHL_FMP_MR_EFFECTIVITY_PVT;

 

/
