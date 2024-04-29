--------------------------------------------------------
--  DDL for Package AHL_RM_MATERIAL_AS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_MATERIAL_AS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMTLS.pls 120.1 2008/01/30 05:18:11 pdoki ship $ */

--modify the existing material record type to accommodate extra fields of disposition list
TYPE material_req_rec_type IS RECORD
(
 RT_OPER_MATERIAL_ID              NUMBER,
 OBJECT_VERSION_NUMBER            NUMBER,
 ITEM_GROUP_ID                    NUMBER,
 ITEM_GROUP_NAME                  VARCHAR2(80),
 ITEM_NUMBER                      VARCHAR2(40),
 INVENTORY_ITEM_ID                NUMBER,
 INVENTORY_ORG_ID                 NUMBER,
 UOM                              VARCHAR2(25),
 UOM_CODE                         VARCHAR2(3),
 QUANTITY                         NUMBER,
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
 DML_OPERATION                    VARCHAR2(1),
 POSITION_PATH 		          VARCHAR2(4000),
 POSITION_PATH_ID 		  NUMBER,
 ITEM_COMP_DETAIL_ID 	          NUMBER,
 EXCLUDE_FLAG 		          VARCHAR2(1),
 REWORK_PERCENT		          NUMBER,
 REPLACE_PERCENT		  NUMBER,
 COMP_MATERIAL_FLAG	  	  VARCHAR2(1),
 IN_SERVICE             VARCHAR2(1) --pdoki added for OGMA 105 issue
);

TYPE material_req_tbl_type IS TABLE OF material_req_rec_type INDEX BY BINARY_INTEGER;

TYPE route_efct_rec_type IS RECORD
(
 ROUTE_EFFECTIVITY_ID  NUMBER
 , ROUTE_NO  VARCHAR2(30)
 , INVENTORY_ITEM_ID  NUMBER
 , INVENTORY_MASTER_ORG_ID  NUMBER
 , ITEM_NUMBER  VARCHAR2(40)
 , DESCRIPTION  VARCHAR2(240)
 , ORGANIZATION_CODE  VARCHAR2(3)
 , MC_ID  NUMBER
 , MC_NAME  VARCHAR2(80)
 , MC_VERSION_NUMBER  NUMBER
 , MC_REVISION VARCHAR2(30)
 , MC_DESCRIPTION VARCHAR2(240)
 , MC_HEADER_ID NUMBER
 , LAST_UPDATE_DATE  DATE
 , LAST_UPDATED_BY  NUMBER(15)
 , CREATION_DATE  DATE
 , CREATED_BY  NUMBER(15)
 , LAST_UPDATE_LOGIN  NUMBER(15)
 , OBJECT_VERSION_NUMBER  NUMBER
 , SECURITY_GROUP_ID  NUMBER
 , ATTRIBUTE_CATEGORY VARCHAR2(30)
 , ATTRIBUTE1  VARCHAR2(150)
 , ATTRIBUTE2  VARCHAR2(150)
 , ATTRIBUTE3  VARCHAR2(150)
 , ATTRIBUTE4  VARCHAR2(150)
 , ATTRIBUTE5  VARCHAR2(150)
 , ATTRIBUTE6  VARCHAR2(150)
 , ATTRIBUTE7  VARCHAR2(150)
 , ATTRIBUTE8  VARCHAR2(150)
 , ATTRIBUTE9  VARCHAR2(150)
 , ATTRIBUTE10  VARCHAR2(150)
 , ATTRIBUTE11  VARCHAR2(150)
 , ATTRIBUTE12  VARCHAR2(150)
 , ATTRIBUTE13  VARCHAR2(150)
 , ATTRIBUTE14  VARCHAR2(150)
 , ATTRIBUTE15  VARCHAR2(150)
 , DML_OPERATION VARCHAR2(1)
 )
 ;

TYPE route_efct_tbl_type IS TABLE OF route_efct_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : process_material_req
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
-- process_material_req IN parameters:
--      p_object_id                 NUMBER               Required
--      p_association_type          VARCHAR2             Required
--
-- process_material_req IN OUT parameters:
--      p_x_material_req_tbl        material_req_tbl_type Required
--
-- process_material_req OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_material_req
(
 p_api_version        IN            NUMBER     := '1.0',
 p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN            VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count          OUT NOCOPY    NUMBER,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_x_material_req_tbl IN OUT NOCOPY material_req_tbl_type,
 p_object_id          IN            NUMBER,
 p_association_type   IN            VARCHAR2
);

-- Start of Comments
-- Procedure name              : process_route_efct_
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
-- process_route_efct_ IN parameters:
--      p_object_id                 NUMBER   Required
--
-- process_route_efct_ IN OUT parameters:
--      p_x_route_efct_tbl         route_efct_tbl_type Required
--
-- process_route_efct OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE process_route_efcts
(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN            VARCHAR2   := NULL,
  p_object_id                 IN      NUMBER,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_route_efct_tbl IN OUT NOCOPY route_efct_tbl_type
);


END AHL_RM_MATERIAL_AS_PVT;


/
