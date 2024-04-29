--------------------------------------------------------
--  DDL for Package AHL_FMP_EFFECTIVITY_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_EFFECTIVITY_DTL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMEDS.pls 120.0.12010000.4 2009/09/22 21:27:59 sikumar ship $ */

TYPE effectivity_detail_rec_type IS RECORD
(
        MR_EFFECTIVITY_DETAIL_ID         NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        EXCLUDE_FLAG                     VARCHAR2(1),
        SERIAL_NUMBER_FROM               VARCHAR2(30),
        SERIAL_NUMBER_TO                 VARCHAR2(30),
        MANUFACTURER_ID                  NUMBER,
        MANUFACTURER                     VARCHAR2(30),
        MANUFACTURE_DATE_FROM            DATE,
        MANUFACTURE_DATE_TO              DATE,
        COUNTRY_CODE                     VARCHAR2(2),
        COUNTRY                          VARCHAR2(80),
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

TYPE effectivity_detail_tbl_type IS TABLE OF effectivity_detail_rec_type INDEX BY BINARY_INTEGER;

TYPE effty_ext_detail_rec_type IS RECORD
(
        MR_EFFECTIVITY_EXT_DTL_ID        NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        EFFECT_EXT_DTL_REC_TYPE          VARCHAR2(30),
        EXCLUDE_FLAG                     VARCHAR2(1),
        OWNER_ID                         NUMBER,
        OWNER                            VARCHAR2(360),--this is owner name
        LOCATION                         VARCHAR2(80),
        LOCATION_TYPE_CODE               VARCHAR2(30),
        CSI_EXT_ATTRIBUTE_CODE           VARCHAR2(30),
        CSI_EXT_ATTRIBUTE_NAME           VARCHAR2(50),
        CSI_EXT_ATTRIBUTE_VALUE          VARCHAR2(240),
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

TYPE effty_ext_detail_tbl_type IS TABLE OF effty_ext_detail_rec_type INDEX BY BINARY_INTEGER;


-- Start of Comments
-- Procedure name              : process_effectivity_detail
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
-- process_effectivity_detail IN parameters:
--      p_mr_header_id              NUMBER                      Required
--      p_mr_effectivity_id         NUMBER                      Required
--
-- process_effectivity_detail IN OUT parameters:
--      p_x_effectivity_detail_tbl  effectivity_detail_tbl_type Required
--
-- process_effectivity_detail OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_effectivity_detail
(
 p_api_version                  IN  NUMBER     := '1.0',
 p_init_msg_list                IN  VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_effectivity_detail_tbl     IN OUT NOCOPY  effectivity_detail_tbl_type,
 p_x_effty_ext_detail_tbl       IN OUT NOCOPY  effty_ext_detail_tbl_type,
 p_mr_header_id                 IN  NUMBER,
 p_mr_effectivity_id            IN  NUMBER
);

END AHL_FMP_EFFECTIVITY_DTL_PVT;

/
