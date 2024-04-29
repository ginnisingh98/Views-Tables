--------------------------------------------------------
--  DDL for Package AHL_RM_ASO_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_ASO_RESOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVASRS.pls 120.0.12010000.2 2008/10/24 07:17:09 pdoki ship $ */

TYPE aso_resource_rec_type IS RECORD
(
        RESOURCE_ID                      NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),
        RESOURCE_TYPE_ID                 NUMBER,
        RESOURCE_TYPE                    VARCHAR2(80),
        NAME                             VARCHAR2(30),
        DESCRIPTION                      VARCHAR2(240),
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

TYPE bom_resource_rec_type IS RECORD
(
        RESOURCE_MAPPING_ID              NUMBER,
        OBJECT_VERSION_NUMBER            NUMBER,
        LAST_UPDATE_DATE                 DATE,
        LAST_UPDATED_BY                  NUMBER(15),
        CREATION_DATE                    DATE,
        CREATED_BY                       NUMBER(15),
        LAST_UPDATE_LOGIN                NUMBER(15),
        BOM_RESOURCE_ID                  NUMBER,
        BOM_ORG_ID                       HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE,
        BOM_RESOURCE_CODE                VARCHAR2(30),
        BOM_ORG_NAME                     HR_ALL_ORGANIZATION_UNITS.name%TYPE,
        DISCRIPTION                      VARCHAR2(240),
        DISABLE_DATE                     DATE,
        --pdoki ER 7436910 Begin.
        DEPARTMENT_ID                    NUMBER,
        DEPARTMENT_NAME                  BOM_DEPARTMENTS.DESCRIPTION%TYPE,
        --pdoki ER 7436910 End.
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

TYPE bom_resource_tbl_type IS TABLE OF bom_resource_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : process_aso_resource
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
-- process_aso_resource IN parameters:
--      None
--
-- process_rt_oper_resource IN OUT parameters:
--      p_x_aso_resource_rec        aso_resource_rec_type Required
--      p_x_bom_resource_tbl        bom_resource_tbl_type Required
--
-- process_rt_oper_resource OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_aso_resource
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
  p_x_aso_resource_rec IN OUT NOCOPY aso_resource_rec_type,
  p_x_bom_resource_tbl IN OUT NOCOPY bom_resource_tbl_type
);

END AHL_RM_ASO_RESOURCE_PVT;

/
