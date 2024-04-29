--------------------------------------------------------
--  DDL for Package AHL_UMP_UF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UF_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUMFS.pls 120.1 2008/01/18 01:22:23 sikumar ship $ */

  G_OP_CREATE        CONSTANT  VARCHAR(1) := 'C';
  G_OP_UPDATE        CONSTANT  VARCHAR(1) := 'U';
  G_OP_DELETE        CONSTANT  VARCHAR(1) := 'D';

  G_UF_TYPE_PC_NODE  CONSTANT  VARCHAR(1) := 'N';
  G_UF_TYPE_UNIT     CONSTANT  VARCHAR(1) := 'U';
  G_UF_TYPE_PART     CONSTANT  VARCHAR(1) := 'I';
  G_UF_TYPE_INSTANCE CONSTANT  VARCHAR(1) := 'C';

  G_UF_USE_UNIT_DEFAULT CONSTANT VARCHAR(1) := 'N';
  G_UF_USE_UNIT_YES     CONSTANT VARCHAR(1) := 'Y';

  G_PC_PRIMARY_FLAG 	CONSTANT VARCHAR2(1) := 'Y';
  G_PC_ITEM_ASSOCIATION CONSTANT VARCHAR2(1) := 'I';
  G_PC_UNIT_ASSOCIATION CONSTANT VARCHAR2(1) := 'U';
  G_DRAFT_STATUS        CONSTANT VARCHAR2(30) := 'DRAFT';
  G_COMPLETE_STATUS     CONSTANT VARCHAR2(30) := 'COMPLETE';

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE uf_header_rec_type IS RECORD (
        UF_HEADER_ID            NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        CREATED_BY              NUMBER,
        CREATION_DATE           DATE,
        LAST_UPDATED_BY         NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATE_LOGIN       NUMBER,
        UNIT_CONFIG_HEADER_ID   NUMBER,
        UNIT_NAME               VARCHAR2(80),
        PC_NODE_ID              NUMBER,
        INVENTORY_ITEM_ID		NUMBER,
        INVENTORY_ITEM_NAME     VARCHAR2(2000),
        INVENTORY_ORG_CODE      VARCHAR2(3),
        INVENTORY_ORG_ID       	NUMBER,
        CSI_ITEM_INSTANCE_ID   	NUMBER,
        USE_UNIT_FLAG           VARCHAR2(1),
        FORECAST_TYPE           VARCHAR2(1),
        OPERATION_FLAG          VARCHAR2(1),
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150)
        );

TYPE uf_details_rec_type IS RECORD (
        UF_DETAIL_ID            NUMBER,
        OBJECT_VERSION_NUMBER   NUMBER,
        CREATED_BY              NUMBER,
        CREATION_DATE           DATE,
        LAST_UPDATED_BY         NUMBER,
        LAST_UPDATE_DATE        DATE,
        LAST_UPDATE_LOGIN       NUMBER,
        UF_HEADER_ID            NUMBER,
        UOM_CODE                VARCHAR2(3),
        START_DATE              DATE,
        END_DATE                DATE,
        USAGE_PER_DAY           NUMBER,
        OPERATION_FLAG          VARCHAR2(1),
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(150),
        ATTRIBUTE2              VARCHAR2(150),
        ATTRIBUTE3              VARCHAR2(150),
        ATTRIBUTE4              VARCHAR2(150),
        ATTRIBUTE5              VARCHAR2(150),
        ATTRIBUTE6              VARCHAR2(150),
        ATTRIBUTE7              VARCHAR2(150),
        ATTRIBUTE8              VARCHAR2(150),
        ATTRIBUTE9              VARCHAR2(150),
        ATTRIBUTE10             VARCHAR2(150),
        ATTRIBUTE11             VARCHAR2(150),
        ATTRIBUTE12             VARCHAR2(150),
        ATTRIBUTE13             VARCHAR2(150),
        ATTRIBUTE14             VARCHAR2(150),
        ATTRIBUTE15             VARCHAR2(150)
        );


----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE uf_details_tbl_type IS TABLE OF uf_details_rec_type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : process_utilization_forecast
--  Type              : Public
--  Function          : For a given set of utilization forecast header and details, will validate and insert/update
--                      the utilization forecast information.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_utilization_forecast Parameters:
--
--       p_x_uf_header_rec         IN OUT  AHL_UMP_UF_PVT.uf_header_rec_type    Required
--         Utilization Forecast Header Details
--       p_x_uf_detail_tbl        IN OUT  AHL_UMP_UF_PVT.uf_detail_tbl_type   Required
--         Utilization Forecast details
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE process_utilization_forecast(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_uf_header_rec       IN OUT NOCOPY  AHL_UMP_UF_PVT.uf_header_rec_type,
    p_x_uf_details_tbl      IN OUT NOCOPY  AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

----------------------------------------------------------------------
-- Procedure to get Utilzation Forecast from Product Classification --
----------------------------------------------------------------------
PROCEDURE get_uf_from_pc (

    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_pc_node_id             IN  NUMBER    := NULL,
    p_inventory_item_id      IN  NUMBER    := NULL,
    p_inventory_org_id       IN  NUMBER    := NULL,
    p_unit_config_header_id  IN  NUMBER    := NULL ,
    p_unit_name              IN  VARCHAR2  := NULL ,
    p_part_number            IN  VARCHAR2  := NULL,
    p_onward_end_date        IN  DATE      := NULL,
    p_add_unit_item_forecast IN  VARCHAR2  := 'N',
    x_UF_details_tbl         OUT NOCOPY    AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status          OUT NOCOPY    VARCHAR2);

-------------------------------------------------------------------------
-- Procedure to get Utilzation Forecast from Part for an instance when pm is installed --
--------------------------------------------------------------------------
PROCEDURE get_uf_from_part (

    p_init_msg_list          IN          VARCHAR2  := FND_API.G_FALSE,
    p_csi_item_instance_id   IN          NUMBER,
    p_onward_end_date        IN          DATE     := NULL,
	x_UF_details_tbl       OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status          OUT NOCOPY VARCHAR2);

End AHL_UMP_UF_PVT;

/
