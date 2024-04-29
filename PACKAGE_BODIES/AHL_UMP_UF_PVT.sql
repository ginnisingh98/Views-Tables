--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UF_PVT" AS
/* $Header: AHLVUMFB.pls 120.2 2008/02/11 00:35:06 sracha ship $ */

  --G_DEBUG varchar2(1) := FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
  G_PKG_NAME         CONSTANT  VARCHAR2(30) := 'AHL_UMP_UF_PVT';
  G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';


------------------------------
-- Declare Local Procedures --
------------------------------
PROCEDURE process_uf_header(
    p_validation_level IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_Rec_type
    );

PROCEDURE convert_uf_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    );

PROCEDURE convert_unit_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    );

PROCEDURE convert_part_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    );

PROCEDURE convert_node_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    );

PROCEDURE validate_uf_header(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type
    );
PROCEDURE validate_uf_header_pm(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type
    );

PROCEDURE default_unchanged_uf_header(
	p_x_uf_header_rec   		IN OUT NOCOPY 	AHL_UMP_UF_PVT.uf_header_Rec_type
    );

PROCEDURE process_uf_details(
    p_validation_level IN       NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type,
    p_x_uf_details_tbl IN OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type
    );


PROCEDURE validate_uf_details(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type,
    p_x_uf_details_tbl IN OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type
    );

PROCEDURE default_unchanged_uf_details(
	p_x_uf_details_tbl   		IN OUT NOCOPY 	AHL_UMP_UF_PVT.uf_details_tbl_type
    );

PROCEDURE validate_utilization_forecast(
    p_uf_header_rec  IN AHL_UMP_UF_PVT.uf_header_rec_type,
    x_uf_details_tbl OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type
    );

PROCEDURE post_process_uf_header(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type
    );

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

PROCEDURE process_utilization_forecast (
    p_api_version           IN              NUMBER    := 1.0,
    p_init_msg_list         IN              VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN              VARCHAR2  := NULL,
    p_x_uf_header_rec       IN OUT  NOCOPY  AHL_UMP_UF_PVT.uf_header_rec_type,
    p_x_uf_details_tbl      IN OUT  NOCOPY  AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2)  IS

  l_api_version      CONSTANT NUMBER := 1.0;
  l_api_name         CONSTANT VARCHAR2(30) := 'process_utilization_forecast';
  l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT process_uf_pvt;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name, G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Enable Debug.
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Started processing UF');
  END IF;
  -------
  process_uf_header(
              p_validation_level => p_validation_level,
              p_x_uf_header_rec  => p_x_uf_header_rec
  );
  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- PROCESS UF details
  IF (p_x_uf_details_tbl.count > 0) THEN
    process_uf_details(
        p_validation_level => p_validation_level,
        p_uf_header_rec    => p_x_uf_header_rec,
        p_x_uf_details_tbl => p_x_uf_details_tbl
    );
  END IF;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;


  -- post processing to delete header if use unit forecast is 'N' and there are no uf_details.
  post_process_uf_header(p_uf_header_rec  => p_x_uf_header_rec);

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Successfully ending processing UF');
  END IF;

  -- Disable debug
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to process_uf_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   -- Disable debug
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.disable_debug;
  END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to process_uf_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   -- Disable debug
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.disable_debug;
  END IF;

 WHEN OTHERS THEN
    Rollback to process_uf_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
    -- Disable debug
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;


END process_utilization_forecast;

----------------------------------------------------------
-- This procedure processes uf_header_rec
----------------------------------------------------------
PROCEDURE process_uf_header(
    p_validation_level IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_Rec_type
    ) IS
BEGIN
    -- Convert values to ID's for header rec
    IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
    THEN
        convert_uf_header_val_to_id(p_x_uf_header_rec => p_x_uf_header_rec);
    END IF;

    IF (AHL_UTIL_PKG.is_pm_installed() = 'N')
    THEN
        validate_uf_header(p_uf_header_rec => p_x_uf_header_rec);
    ELSE
        validate_uf_header_pm(p_uf_header_rec => p_x_uf_header_rec);
    END IF;
    default_unchanged_uf_header(p_x_uf_header_rec => p_x_uf_header_rec);

    --save uf header now
    IF(p_x_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE) THEN
        --setting object version number for create
        p_x_uf_header_rec.object_version_number := 1;
        --setting up user/create/update information
        p_x_uf_header_rec.created_by := fnd_global.user_id;
        p_x_uf_header_rec.creation_date := SYSDATE;
        p_x_uf_header_rec.last_updated_by := fnd_global.user_id;
        p_x_uf_header_rec.last_update_date := SYSDATE;
        p_x_uf_header_rec.last_update_login := fnd_global.user_id;

        AHL_UF_HEADERS_PKG.insert_row(
        x_uf_header_id => p_x_uf_header_rec.uf_header_id,
        x_object_version_number => p_x_uf_header_rec.object_version_number,
        x_created_by => p_x_uf_header_rec.created_by,
        x_creation_date => p_x_uf_header_rec.creation_date,
        x_last_updated_by => p_x_uf_header_rec.last_updated_by,
        x_last_update_date => p_x_uf_header_rec.last_update_date,
        x_last_update_login => p_x_uf_header_rec.last_update_login,
        x_unit_config_header_id => p_x_uf_header_rec.unit_config_header_id,
        x_pc_node_id => p_x_uf_header_rec.pc_node_id,
        x_inventory_item_id => p_x_uf_header_rec.inventory_item_id,
        x_inventory_org_id => p_x_uf_header_rec.inventory_org_id,
        x_csi_item_instance_id => p_x_uf_header_rec.csi_item_instance_id,
        x_use_unit_flag => p_x_uf_header_rec.use_unit_flag,
        x_attribute_category => p_x_uf_header_rec.attribute_category,
        x_attribute1 => p_x_uf_header_rec.attribute1,
        x_attribute2 => p_x_uf_header_rec.attribute2,
        x_attribute3 => p_x_uf_header_rec.attribute3,
        x_attribute4 => p_x_uf_header_rec.attribute4,
        x_attribute5 => p_x_uf_header_rec.attribute5,
        x_attribute6 => p_x_uf_header_rec.attribute6,
        x_attribute7 => p_x_uf_header_rec.attribute7,
        x_attribute8 => p_x_uf_header_rec.attribute8,
        x_attribute9 => p_x_uf_header_rec.attribute9,
        x_attribute10 => p_x_uf_header_rec.attribute10,
        x_attribute11 => p_x_uf_header_rec.attribute11,
        x_attribute12 => p_x_uf_header_rec.attribute12,
        x_attribute13 => p_x_uf_header_rec.attribute13,
        x_attribute14 => p_x_uf_header_rec.attribute14,
        x_attribute15 => p_x_uf_header_rec.attribute15
        );
    ELSIF (p_x_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE) THEN

        -- setting up object version number
        p_x_uf_header_rec.object_version_number := p_x_uf_header_rec.object_version_number + 1;
        --setting up user/create/update information
        p_x_uf_header_rec.last_updated_by := fnd_global.user_id;
        p_x_uf_header_rec.last_update_date := SYSDATE;
        p_x_uf_header_rec.last_update_login := fnd_global.user_id;

        AHL_UF_HEADERS_PKG.update_row(
        x_uf_header_id => p_x_uf_header_rec.uf_header_id,
        x_object_version_number => p_x_uf_header_rec.object_version_number,
        x_last_updated_by => p_x_uf_header_rec.last_updated_by,
        x_last_update_date => p_x_uf_header_rec.last_update_date,
        x_last_update_login => p_x_uf_header_rec.last_update_login,
        x_unit_config_header_id => p_x_uf_header_rec.unit_config_header_id,
        x_pc_node_id => p_x_uf_header_rec.pc_node_id,
        x_inventory_item_id => p_x_uf_header_rec.inventory_item_id,
        x_inventory_org_id => p_x_uf_header_rec.inventory_org_id,
        x_csi_item_instance_id => p_x_uf_header_rec.csi_item_instance_id,
        x_use_unit_flag => p_x_uf_header_rec.use_unit_flag,
        x_attribute_category => p_x_uf_header_rec.attribute_category,
        x_attribute1 => p_x_uf_header_rec.attribute1,
        x_attribute2 => p_x_uf_header_rec.attribute2,
        x_attribute3 => p_x_uf_header_rec.attribute3,
        x_attribute4 => p_x_uf_header_rec.attribute4,
        x_attribute5 => p_x_uf_header_rec.attribute5,
        x_attribute6 => p_x_uf_header_rec.attribute6,
        x_attribute7 => p_x_uf_header_rec.attribute7,
        x_attribute8 => p_x_uf_header_rec.attribute8,
        x_attribute9 => p_x_uf_header_rec.attribute9,
        x_attribute10 => p_x_uf_header_rec.attribute10,
        x_attribute11 => p_x_uf_header_rec.attribute11,
        x_attribute12 => p_x_uf_header_rec.attribute12,
        x_attribute13 => p_x_uf_header_rec.attribute13,
        x_attribute14 => p_x_uf_header_rec.attribute14,
        x_attribute15 => p_x_uf_header_rec.attribute15
        );
    END IF;


END process_uf_header;

----------------------------------------------------------
-- This procedure converts values to ids for uf_header_rec
----------------------------------------------------------
PROCEDURE convert_uf_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    ) IS

BEGIN
    -- conversion between uf_header_id : unit_config_header_id, inventory_item_id, pc_node_id

    IF(p_x_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_UNIT)THEN
        convert_unit_header_val_to_id(p_x_uf_header_rec);
    ELSIF (p_x_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PART)THEN
        convert_part_header_val_to_id(p_x_uf_header_rec);
    ELSIF (p_x_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PC_NODE)THEN
        convert_node_header_val_to_id(p_x_uf_header_rec);
    END IF;

    IF FND_MSG_PUB.count_msg > 0 THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END convert_uf_header_val_to_id;

----------------------------------------------------------------------------------------
-- This procedure converts values to ids for uf_header_rec for unit utilization forecast
----------------------------------------------------------------------------------------
PROCEDURE convert_unit_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    )IS

l_uf_header_id          NUMBER;
l_unit_config_header_id NUMBER;

CURSOR unit_config_header_id_csr(p_unit_name IN VARCHAR2) IS
SELECT unit_config_header_id
FROM ahl_unit_config_headers
WHERE name = p_unit_name;

CURSOR uf_header_id_uid_csr(p_unit_config_header_id IN NUMBER) IS
SELECT uf_header_id
FROM ahl_uf_headers
WHERE unit_config_header_id = p_unit_config_header_id;

BEGIN

    IF(p_x_uf_header_rec.uf_header_id IS NULL) THEN
        IF(p_x_uf_header_rec.unit_config_header_id IS NULL AND p_x_uf_header_rec.unit_name IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFHID_UCHID_NLL');
            FND_MSG_PUB.ADD;
        ELSIF (p_x_uf_header_rec.unit_config_header_id IS NULL AND p_x_uf_header_rec.unit_name IS NOT NULL) THEN
            OPEN unit_config_header_id_csr(p_x_uf_header_rec.unit_name);
            FETCH unit_config_header_id_csr INTO l_unit_config_header_id;
            IF(unit_config_header_id_csr%NOTFOUND) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_INV');
               FND_MSG_PUB.ADD;
            ELSE
               p_x_uf_header_rec.unit_config_header_id := l_unit_config_header_id;
            END IF;
            CLOSE unit_config_header_id_csr;
        END IF;
        --fetching uf_header_id based on unit_config_header_id
        IF (p_x_uf_header_rec.unit_config_header_id IS NOT NULL AND
                p_x_uf_header_rec.operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE) THEN
            OPEN uf_header_id_uid_csr(p_x_uf_header_rec.unit_config_header_id);
            FETCH uf_header_id_uid_csr INTO l_uf_header_id;
            IF(uf_header_id_uid_csr%NOTFOUND)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HREC_NOTINDB');
               FND_MSG_PUB.ADD;
            ELSE
               p_x_uf_header_rec.uf_header_id := l_uf_header_id;
            END IF;
            CLOSE uf_header_id_uid_csr;
        END IF;
    END IF;

END convert_unit_header_val_to_id;

----------------------------------------------------------------------------------------
-- This procedure converts values to ids for uf_header_rec for part/item utilization forecast
----------------------------------------------------------------------------------------
PROCEDURE convert_part_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    )IS

l_uf_header_id          NUMBER;
l_inventory_item_id     NUMBER;

CURSOR inventory_item_id_csr(p_inventory_item_name IN VARCHAR2) IS
SELECT inventory_item_id
FROM mtl_system_items_kfv
WHERE concatenated_segments = p_inventory_item_name;


CURSOR uf_header_id_pid_csr(p_inventory_item_id IN NUMBER) IS
SELECT uf_header_id
FROM ahl_uf_headers
WHERE inventory_item_id = p_inventory_item_id;


BEGIN
    IF(p_x_uf_header_rec.uf_header_id IS NULL) THEN
        IF(p_x_uf_header_rec.inventory_item_id IS NULL AND p_x_uf_header_rec.inventory_item_name IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INVID_NLL');
            FND_MSG_PUB.ADD;
        ELSIF (p_x_uf_header_rec.inventory_item_id IS NULL AND p_x_uf_header_rec.inventory_item_name IS NOT NULL) THEN
            OPEN inventory_item_id_csr(p_x_uf_header_rec.inventory_item_name);
            FETCH inventory_item_id_csr INTO l_inventory_item_id;
            IF(inventory_item_id_csr%NOTFOUND) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_INV');
               FND_MSG_PUB.ADD;
            ELSE
               p_x_uf_header_rec.inventory_item_id := l_inventory_item_id;
            END IF;
            CLOSE inventory_item_id_csr;
        END IF;
        --fetching uf_header_id based on inventory_item_id
        IF (p_x_uf_header_rec.inventory_item_id IS NOT NULL AND
                p_x_uf_header_rec.operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE) THEN
            OPEN uf_header_id_pid_csr(p_x_uf_header_rec.inventory_item_id);
            FETCH uf_header_id_pid_csr INTO l_uf_header_id;
            IF(uf_header_id_pid_csr%NOTFOUND)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HREC_NOTINDB');
               FND_MSG_PUB.ADD;
            ELSE
               p_x_uf_header_rec.uf_header_id := l_uf_header_id;
            END IF;
            CLOSE uf_header_id_pid_csr;
        END IF;
    END IF;
END convert_part_header_val_to_id;

----------------------------------------------------------------------------------------
-- This procedure converts values to ids for uf_header_rec for pc node utilization forecast
----------------------------------------------------------------------------------------
PROCEDURE convert_node_header_val_to_id(
    p_x_uf_header_rec  IN OUT NOCOPY AHL_UMP_UF_PVT.uf_header_rec_type
    )IS

CURSOR uf_header_id_nid_csr(p_pc_node_id IN NUMBER) IS
SELECT uf_header_id
FROM ahl_uf_headers
WHERE pc_node_id = p_pc_node_id;

l_uf_header_id          NUMBER;


BEGIN
    IF p_x_uf_header_rec.operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE THEN
        IF(p_x_uf_header_rec.uf_header_id IS NULL) THEN
            IF(p_x_uf_header_rec.pc_node_id IS NULL) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_NODEID_NLL');
                FND_MSG_PUB.ADD;
            ELSE
                OPEN uf_header_id_nid_csr(p_x_uf_header_rec.pc_node_id);
                FETCH uf_header_id_nid_csr INTO l_uf_header_id;
                IF(uf_header_id_nid_csr%NOTFOUND)THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HREC_NOTINDB');
                   FND_MSG_PUB.ADD;
                ELSE
                    p_x_uf_header_rec.uf_header_id := l_uf_header_id;
                END IF;
                CLOSE uf_header_id_nid_csr;
            END IF;
        END IF;
    END IF;

END convert_node_header_val_to_id;

------------------------------------------------------------------------
-- This procedure does the following validations for uf_header_rec
-- check whether forecast type is AHL_UMP_UF_PVT.G_UF_TYPE_UNIT,AHL_UMP_UF_PVT.G_UF_TYPE_PART or AHL_UMP_UF_PVT.G_UF_TYPE_PC_NODE
-- check of uf_header_id , if null, verify operation flag is create AHL_UMP_UF_PVT.G_OP_CREATE, else AHL_UMP_UF_PVT.G_UF_TYPE_UNIT
-- check for object version number if latest. If uf_header_id is null, it should be null too.
-- for forecast type U : Unit
--        validate whether this unit is a complete Unit Configuration.
--        validate whether this unit is attached to a complete primary PC.
--        validate whether use unit flag is not null
-- for forecast type P : Part
--        validate whether this part is in inventory.A VALID Part
--        validate whether this part is attached to a complete primary PC.
--        use unit flag should be null.
-- for forecast type N : Node
--        validate whether this node is defined in PC nodes table.
--        validate whether this node is attached to a complete primary PC.
--        use unit flag should be null.
-------------------------------------------------------------------------
PROCEDURE validate_uf_header(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type
    ) IS

    CURSOR uf_header_csr (p_uf_header_id  IN  NUMBER) IS
    SELECT object_version_number, unit_config_header_id,pc_node_id,inventory_item_id,inventory_org_id,use_unit_flag
    FROM ahl_uf_headers
    WHERE uf_header_id = p_uf_header_id;


    l_object_version_number NUMBER;
    l_unit_config_header_id NUMBER;
    l_pc_node_id NUMBER;
    l_inventory_item_id NUMBER;
    l_inventory_org_id NUMBER;
    l_use_unit_flag ahl_uf_headers.use_unit_flag%TYPE;

    CURSOR unit_status_check_csr(p_unit_config_header_id IN NUMBER) IS
    SELECT UCH.unit_config_status_code
    FROM ahl_unit_config_headers UCH
    WHERE (UCH.active_end_date IS NULL OR TRUNC(UCH.active_end_date) > TRUNC(SYSDATE))
    AND UCH.unit_config_header_id = p_unit_config_header_id;

    l_unit_config_status_code ahl_unit_header_details_v.unit_config_status_code%TYPE;

    CURSOR part_check_csr(p_inventory_item_id IN NUMBER) IS
    SELECT 'x'
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_inventory_item_id;

    l_exists VARCHAR2(1);

    CURSOR pc_status_check_up_csr(p_unit_item_id IN NUMBER,p_association_type IN VARCHAR2) IS
    SELECT a.primary_flag,a.status
    FROM ahl_pc_headers_b a, ahl_pc_nodes_b b, ahl_pc_associations c
    WHERE a.pc_header_id = b.pc_header_id AND b.pc_node_id = c.pc_node_id AND
    a.primary_flag = G_PC_PRIMARY_FLAG AND
    a.status = G_COMPLETE_STATUS AND
    c.association_type_flag = p_association_type AND
    c.unit_item_id = p_unit_item_id;

    CURSOR pc_status_check_n_csr(p_pc_node_id IN NUMBER) IS
    SELECT a.primary_flag,a.status
    FROM ahl_pc_headers_b a, ahl_pc_nodes_b b
    WHERE a.pc_header_id = b.pc_header_id
    AND b.pc_node_id = p_pc_node_id;

    l_pc_primary_flag ahl_pc_headers_b.primary_flag%TYPE;
    l_pc_status ahl_pc_headers_b.status%TYPE;

BEGIN

    -- Operation Flag and Header ID validation.
    IF (p_uf_header_rec.forecast_type NOT IN(AHL_UMP_UF_PVT.G_UF_TYPE_UNIT,AHL_UMP_UF_PVT.G_UF_TYPE_PART,AHL_UMP_UF_PVT.G_UF_TYPE_PC_NODE))THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UF_TYPE');
        FND_MSG_PUB.ADD;
    ELSIF (p_uf_header_rec.operation_flag IS NOT NULL AND p_uf_header_rec.operation_flag NOT IN(AHL_UMP_UF_PVT.G_OP_CREATE,AHL_UMP_UF_PVT.G_OP_UPDATE,AHL_UMP_UF_PVT.G_OP_DELETE))THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HEADER');
        FND_MSG_PUB.ADD;
    ELSIF ((p_uf_header_rec.uf_header_id IS NULL)
            AND (p_uf_header_rec.operation_flag IS NULL OR p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_UFHID_NLL');
        FND_MSG_PUB.ADD;
    ELSIF(p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND
          p_uf_header_rec.uf_header_id IS NOT NULL ) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_UFHID_N_NLL');
        FND_MSG_PUB.ADD;
    END IF;



    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (( p_uf_header_rec.operation_flag IS NULL OR p_uf_header_rec.operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE) AND p_uf_header_rec.uf_header_id IS NOT NULL)THEN
        OPEN  uf_header_csr(p_uf_header_rec.uf_header_id);
        FETCH uf_header_csr INTO l_object_version_number, l_unit_config_header_id,l_pc_node_id,l_inventory_item_id,l_inventory_org_id,l_use_unit_flag;
        IF (uf_header_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HREC_NOTINDB');
            FND_MSG_PUB.ADD;
        ELSIF (l_object_version_number <> p_uf_header_rec.object_version_number)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_HREC_OBJV_MIS');
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE uf_header_csr;

        IF(FND_MSG_PUB.count_msg > 0)THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF(p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_UNIT) THEN
            IF(p_uf_header_rec.unit_config_header_id = FND_API.G_MISS_NUM)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFHID_UCHID_NLL');
               FND_MSG_PUB.ADD;
            ELSIF (p_uf_header_rec.unit_config_header_id IS NOT NULL AND
                   p_uf_header_rec.unit_config_header_id <> l_unit_config_header_id )THEN                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UCHID_MIS');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN unit_status_check_csr(l_unit_config_header_id);
                FETCH unit_status_check_csr INTO l_unit_config_status_code;
                IF (unit_status_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_INV');
                    FND_MSG_PUB.ADD;
                ELSIF (l_unit_config_status_code = AHL_UMP_UF_PVT.G_DRAFT_STATUS)THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UC_STATUS_DRAFT');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE unit_status_check_csr;

                OPEN pc_status_check_up_csr(l_unit_config_header_id,AHL_UMP_UF_PVT.G_PC_UNIT_ASSOCIATION);
                FETCH pc_status_check_up_csr INTO l_pc_primary_flag,l_pc_status;
                IF (pc_status_check_up_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_PC_INV');
                    FND_MSG_PUB.ADD;
                ELSIF (l_pc_primary_flag <> AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG OR l_pc_status <> AHL_UMP_UF_PVT.G_COMPLETE_STATUS) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_PC_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE pc_status_check_up_csr;


            END IF;
        ELSIF(p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PART) THEN
            IF(p_uf_header_rec.inventory_item_id = FND_API.G_MISS_NUM)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INVID_NLL');
               FND_MSG_PUB.ADD;
            ELSIF (p_uf_header_rec.inventory_item_id IS NOT NULL AND
                   p_uf_header_rec.inventory_item_id <> l_inventory_item_id )THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVID_MIS');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN part_check_csr(l_inventory_item_id);
                FETCH part_check_csr INTO l_exists;
                IF (part_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE part_check_csr;

                OPEN pc_status_check_up_csr(l_inventory_item_id,AHL_UMP_UF_PVT.G_PC_ITEM_ASSOCIATION);
                FETCH pc_status_check_up_csr INTO l_pc_primary_flag,l_pc_status;
                IF (pc_status_check_up_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_PC_INV');
                    FND_MSG_PUB.ADD;
                ELSIF (l_pc_primary_flag <> AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG OR l_pc_status <> AHL_UMP_UF_PVT.G_COMPLETE_STATUS) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_PC_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE pc_status_check_up_csr;

            END IF;
        ELSIF(p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PC_NODE) THEN
            IF(p_uf_header_rec.pc_node_id = FND_API.G_MISS_NUM)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_NODEID_NLL');
               FND_MSG_PUB.ADD;
            ELSIF (p_uf_header_rec.pc_node_id IS NOT NULL AND
                   p_uf_header_rec.pc_node_id <> l_pc_node_id )THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_NODEID_MIS');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN pc_status_check_n_csr(l_pc_node_id);
                FETCH pc_status_check_n_csr INTO l_pc_primary_flag,l_pc_status;
                IF (pc_status_check_n_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_NODE_PC_INV');
                    FND_MSG_PUB.ADD;
                ELSIF (l_pc_primary_flag <> AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG OR l_pc_status <> AHL_UMP_UF_PVT.G_COMPLETE_STATUS) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_NODE_PC_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE pc_status_check_n_csr;

            END IF;
        END IF;
    ELSIF (p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND
            p_uf_header_rec.uf_header_id IS NULL)THEN
        IF(p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_UNIT) THEN
            IF(p_uf_header_rec.unit_config_header_id IS NULL OR
               p_uf_header_rec.unit_config_header_id = FND_API.G_MISS_NUM) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFHID_UCHID_NLL');
               FND_MSG_PUB.ADD;
            ELSE
               OPEN unit_status_check_csr(p_uf_header_rec.unit_config_header_id);
               FETCH unit_status_check_csr INTO l_unit_config_status_code;
               IF (unit_status_check_csr%NOTFOUND) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_INV');
                   FND_MSG_PUB.ADD;
               ELSIF (l_unit_config_status_code = AHL_UMP_UF_PVT.G_DRAFT_STATUS)THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UC_STATUS_DRAFT');
                   FND_MSG_PUB.ADD;
               END IF;
               CLOSE unit_status_check_csr;

               OPEN pc_status_check_up_csr(p_uf_header_rec.unit_config_header_id, AHL_UMP_UF_PVT.G_PC_UNIT_ASSOCIATION);
               FETCH pc_status_check_up_csr INTO l_pc_primary_flag,l_pc_status;
               IF (pc_status_check_up_csr%NOTFOUND) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_PC_INV');
                   FND_MSG_PUB.ADD;
               ELSIF (l_pc_primary_flag <> AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG OR l_pc_status <> AHL_UMP_UF_PVT.G_COMPLETE_STATUS) THEN
                   FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UNIT_PC_INV');
                   FND_MSG_PUB.ADD;
               END IF;
               CLOSE pc_status_check_up_csr;

            END IF;
        ELSIF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PART) THEN
            IF(p_uf_header_rec.inventory_item_id IS NULL OR
               p_uf_header_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INVID_NLL');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN part_check_csr(p_uf_header_rec.inventory_item_id);
                FETCH part_check_csr INTO l_exists;
                IF (part_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE part_check_csr;

                OPEN pc_status_check_up_csr(p_uf_header_rec.inventory_item_id, AHL_UMP_UF_PVT.G_PC_ITEM_ASSOCIATION);
                FETCH pc_status_check_up_csr INTO l_pc_primary_flag,l_pc_status;
                IF (pc_status_check_up_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_PC_INV');
                    FND_MSG_PUB.ADD;
                ELSIF (l_pc_primary_flag <> AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG OR l_pc_status <> AHL_UMP_UF_PVT.G_COMPLETE_STATUS) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_PC_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE pc_status_check_up_csr;

            END IF;
        ELSIF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PC_NODE) THEN
            IF(p_uf_header_rec.pc_node_id IS NULL OR
               p_uf_header_rec.pc_node_id = FND_API.G_MISS_NUM) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_NODEID_NLL');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN pc_status_check_n_csr(p_uf_header_rec.pc_node_id);
                FETCH pc_status_check_n_csr INTO l_pc_primary_flag,l_pc_status;
                IF (pc_status_check_n_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_NODE_PC_INV');
                    FND_MSG_PUB.ADD;
                ELSIF (l_pc_primary_flag <> AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG OR l_pc_status <> AHL_UMP_UF_PVT.G_COMPLETE_STATUS) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_NODE_PC_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE pc_status_check_n_csr;
            END IF;
        END IF;
    ELSE
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_HEADER');
        FND_MSG_PUB.ADD;
    END IF;

    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF((p_uf_header_rec.use_unit_flag IS NOT NULL OR p_uf_header_rec.use_unit_flag <> FND_API.G_MISS_CHAR)
        AND p_uf_header_rec.use_unit_flag NOT IN (AHL_UMP_UF_PVT.G_UF_USE_UNIT_DEFAULT,AHL_UMP_UF_PVT.G_UF_USE_UNIT_YES)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UNT_FLG');
        FND_MSG_PUB.ADD;
    END IF;

    IF(FND_MSG_PUB.count_msg > 0)THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;


END validate_uf_header;
----------------------------------------------------------
------------------------------------------------------------------------
-- This procedure does the following validations for uf_header_rec when preventive maintenance is installed
-- check whether forecast type is AHL_UMP_UF_PVT.G_UF_TYPE_PART or AHL_UMP_UF_PVT.G_UF_TYPE_INSTANCE
-- check of uf_header_id , if null, verify operation flag is create AHL_UMP_UF_PVT.G_OP_CREATE
-- check for object version number if latest. If uf_header_id is null, it should be null too.
-- for forecast type P : Part
--        validate whether this part is in inventory.A VALID Part--
--        use unit flag should be "N" or null.
-- for forecast type C : Instance
--        validate whether this instance is defined in csi instance tables
--        validate whether this is an instanc of a valid part.
--        use unit flag should be valid.
-------------------------------------------------------------------------
PROCEDURE validate_uf_header_pm(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type
    ) IS

    CURSOR uf_header_csr (p_uf_header_id  IN  NUMBER) IS
    SELECT object_version_number, inventory_item_id,csi_item_instance_id,use_unit_flag
    FROM ahl_uf_headers
    WHERE uf_header_id = p_uf_header_id;


    l_object_version_number NUMBER;
    l_inventory_item_id NUMBER;
    l_csi_item_instance_id NUMBER;
    l_use_unit_flag ahl_uf_headers.use_unit_flag%TYPE;

    --l_part_number mtl_system_items_kfv.concatenated_segments%TYPE;

    CURSOR part_check_csr(p_inventory_item_id IN NUMBER) IS
    SELECT 'x'
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_inventory_item_id;

    l_exists VARCHAR2(1);

    CURSOR instance_check_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT 'x'
    FROM csi_item_instances
    WHERE instance_id = p_csi_item_instance_id;


BEGIN
    -- Operation Flag and Header ID validation.
    IF (p_uf_header_rec.forecast_type NOT IN(AHL_UMP_UF_PVT.G_UF_TYPE_PART,AHL_UMP_UF_PVT.G_UF_TYPE_INSTANCE))THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UF_TYPE');
        FND_MSG_PUB.ADD;
    ELSIF (p_uf_header_rec.operation_flag IS NOT NULL AND p_uf_header_rec.operation_flag NOT IN(AHL_UMP_UF_PVT.G_OP_CREATE,AHL_UMP_UF_PVT.G_OP_UPDATE,AHL_UMP_UF_PVT.G_OP_DELETE))THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HEADER');
        FND_MSG_PUB.ADD;
    ELSIF ((p_uf_header_rec.uf_header_id IS NULL)
            AND (p_uf_header_rec.operation_flag IS NULL OR p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_UFHID_NLL');
        FND_MSG_PUB.ADD;
    ELSIF(p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND
          p_uf_header_rec.uf_header_id IS NOT NULL ) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_UFHID_N_NLL');
        FND_MSG_PUB.ADD;
    END IF;



    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (( p_uf_header_rec.operation_flag IS NULL OR p_uf_header_rec.operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE) AND p_uf_header_rec.uf_header_id IS NOT NULL)THEN
        OPEN  uf_header_csr(p_uf_header_rec.uf_header_id);
        FETCH uf_header_csr INTO l_object_version_number, l_inventory_item_id,l_csi_item_instance_id,l_use_unit_flag;
        IF (uf_header_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HREC_NOTINDB');
            FND_MSG_PUB.ADD;
        ELSIF (l_object_version_number <> p_uf_header_rec.object_version_number)THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_HREC_OBJV_MIS');
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE uf_header_csr;

        IF(FND_MSG_PUB.count_msg > 0)THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF(p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PART) THEN
            IF(p_uf_header_rec.inventory_item_id = FND_API.G_MISS_NUM)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INVID_NLL');
               FND_MSG_PUB.ADD;
            ELSIF (p_uf_header_rec.inventory_item_id IS NOT NULL AND
                   p_uf_header_rec.inventory_item_id <> l_inventory_item_id )THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVID_MIS');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN part_check_csr(l_inventory_item_id);
                FETCH part_check_csr INTO l_exists;
                IF (part_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE part_check_csr;
            END IF;
        ELSIF(p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_INSTANCE) THEN
            IF(p_uf_header_rec.csi_item_instance_id = FND_API.G_MISS_NUM)THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INSTID_NLL');
               FND_MSG_PUB.ADD;
            ELSIF (p_uf_header_rec.csi_item_instance_id IS NOT NULL AND
                   p_uf_header_rec.csi_item_instance_id <> l_csi_item_instance_id )THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INSTID_MIS');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN instance_check_csr(l_csi_item_instance_id);
                FETCH instance_check_csr INTO l_exists;
                IF (instance_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INST_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE instance_check_csr;
            END IF;
        END IF;
    ELSIF (p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND
            p_uf_header_rec.uf_header_id IS NULL)THEN
        IF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PART) THEN
            IF(p_uf_header_rec.inventory_item_id IS NULL OR
               p_uf_header_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INVID_NLL');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN part_check_csr(p_uf_header_rec.inventory_item_id);
                FETCH part_check_csr INTO l_exists;
                IF (part_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_PART_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE part_check_csr;
            END IF;
        ELSIF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_INSTANCE) THEN
            IF(p_uf_header_rec.csi_item_instance_id IS NULL OR
               p_uf_header_rec.csi_item_instance_id = FND_API.G_MISS_NUM) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UFH_INSTID_NLL');
               FND_MSG_PUB.ADD;
            ELSE
                OPEN instance_check_csr(p_uf_header_rec.csi_item_instance_id);
                FETCH instance_check_csr INTO l_exists;
                IF (instance_check_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INST_INV');
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE instance_check_csr;
            END IF;
        END IF;
    ELSE
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_HEADER');
        FND_MSG_PUB.ADD;
    END IF;

    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF((p_uf_header_rec.use_unit_flag IS NOT NULL OR p_uf_header_rec.use_unit_flag <> FND_API.G_MISS_CHAR)
        AND p_uf_header_rec.use_unit_flag NOT IN (AHL_UMP_UF_PVT.G_UF_USE_UNIT_DEFAULT,AHL_UMP_UF_PVT.G_UF_USE_UNIT_YES)) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UNT_FLG');
        FND_MSG_PUB.ADD;
    END IF;

    IF(FND_MSG_PUB.count_msg > 0)THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;


END validate_uf_header_pm;

----------------------------------------------------------
-- This procedure processes defaults unchanged attribute in uf header record
----------------------------------------------------------
PROCEDURE default_unchanged_uf_header(
	p_x_uf_header_rec   		IN OUT NOCOPY 	AHL_UMP_UF_PVT.uf_header_Rec_type
    ) IS

CURSOR uf_header_csr(p_uf_header_id IN NUMBER, p_object_version_number IN NUMBER) IS
SELECT  unit_config_header_id, inventory_item_id, pc_node_id, inventory_org_id,csi_item_instance_id,
        use_unit_flag, attribute_category, attribute1,attribute2, attribute3,
        attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,
        attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
FROM ahl_uf_headers
WHERE object_version_number= p_object_version_number
AND uf_header_id = p_uf_header_id;

l_uf_header_rec AHL_UMP_UF_PVT.uf_header_Rec_type;

BEGIN
    IF(p_x_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE) THEN
        OPEN uf_header_csr(p_x_uf_header_rec.uf_header_id, p_x_uf_header_rec.object_version_number);
        FETCH uf_header_csr INTO l_uf_header_rec.unit_config_header_id, l_uf_header_rec.inventory_item_id,l_uf_header_rec.csi_item_instance_id,
         l_uf_header_rec.pc_node_id, l_uf_header_rec.inventory_org_id, l_uf_header_rec.use_unit_flag,
         l_uf_header_rec.attribute_category,l_uf_header_rec.attribute1,l_uf_header_rec.attribute2,
         l_uf_header_rec.attribute3, l_uf_header_rec.attribute4, l_uf_header_rec.attribute5,
         l_uf_header_rec.attribute6, l_uf_header_rec.attribute7, l_uf_header_rec.attribute8,
         l_uf_header_rec.attribute9, l_uf_header_rec.attribute10, l_uf_header_rec.attribute11,
         l_uf_header_rec.attribute12, l_uf_header_rec.attribute13, l_uf_header_rec.attribute14,
         l_uf_header_rec.attribute15;
        IF (uf_header_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_HREC_NOTINDB');
            FND_MSG_PUB.ADD;
        ELSE
            IF (p_x_uf_header_rec.unit_config_header_id is null) THEN
                p_x_uf_header_rec.unit_config_header_id := l_uf_header_rec.unit_config_header_id;
            ELSIF(p_x_uf_header_rec.unit_config_header_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_header_rec.unit_config_header_id := null;
            END IF;

            IF (p_x_uf_header_rec.inventory_item_id is null) THEN
                p_x_uf_header_rec.inventory_item_id := l_uf_header_rec.inventory_item_id;
            ELSIF(p_x_uf_header_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_header_rec.inventory_item_id := null;
            END IF;

            IF (p_x_uf_header_rec.pc_node_id is null) THEN
                p_x_uf_header_rec.pc_node_id := l_uf_header_rec.pc_node_id;
            ELSIF(p_x_uf_header_rec.pc_node_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_header_rec.pc_node_id := null;             END IF;

            IF (p_x_uf_header_rec.inventory_org_id is null) THEN
                p_x_uf_header_rec.inventory_org_id := l_uf_header_rec.inventory_org_id;
            ELSIF(p_x_uf_header_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_header_rec.inventory_org_id := null;
            END IF;

            IF (p_x_uf_header_rec.csi_item_instance_id is null) THEN
                p_x_uf_header_rec.csi_item_instance_id := l_uf_header_rec.csi_item_instance_id;
            ELSIF(p_x_uf_header_rec.csi_item_instance_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_header_rec.csi_item_instance_id := null;
            END IF;

            IF (p_x_uf_header_rec.use_unit_flag is null) THEN
                p_x_uf_header_rec.use_unit_flag := l_uf_header_rec.use_unit_flag;
            ELSIF(p_x_uf_header_rec.use_unit_flag = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.use_unit_flag := AHL_UMP_UF_PVT.G_UF_USE_UNIT_DEFAULT;
            END IF;

            IF (p_x_uf_header_rec.attribute_category is null) THEN
                p_x_uf_header_rec.attribute_category := l_uf_header_rec.attribute_category;
            ELSIF(p_x_uf_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute_category := null;
            END IF;

            IF (p_x_uf_header_rec.attribute1 is null) THEN
                p_x_uf_header_rec.attribute1 := l_uf_header_rec.attribute1;
            ELSIF(p_x_uf_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute1 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute2 is null) THEN
                p_x_uf_header_rec.attribute2 := l_uf_header_rec.attribute2;
            ELSIF(p_x_uf_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute2 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute3 is null) THEN
                p_x_uf_header_rec.attribute3 := l_uf_header_rec.attribute3;
            ELSIF(p_x_uf_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute3 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute4 is null) THEN
                p_x_uf_header_rec.attribute4 := l_uf_header_rec.attribute4;
            ELSIF(p_x_uf_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute4 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute5 is null) THEN
                p_x_uf_header_rec.attribute5 := l_uf_header_rec.attribute5;
            ELSIF(p_x_uf_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute5 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute6 is null) THEN
                p_x_uf_header_rec.attribute6 := l_uf_header_rec.attribute6;
            ELSIF(p_x_uf_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute6 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute7 is null) THEN
                p_x_uf_header_rec.attribute7 := l_uf_header_rec.attribute7;
            ELSIF(p_x_uf_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute7 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute8 is null) THEN
                p_x_uf_header_rec.attribute8 := l_uf_header_rec.attribute8;
            ELSIF(p_x_uf_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute8 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute9 is null) THEN
                p_x_uf_header_rec.attribute9 := l_uf_header_rec.attribute9;
            ELSIF(p_x_uf_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute9 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute10 is null) THEN
                p_x_uf_header_rec.attribute10 := l_uf_header_rec.attribute10;
            ELSIF(p_x_uf_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute10 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute11 is null) THEN
                p_x_uf_header_rec.attribute11 := l_uf_header_rec.attribute11;
            ELSIF(p_x_uf_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute11 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute12 is null) THEN
                p_x_uf_header_rec.attribute12 := l_uf_header_rec.attribute12;
            ELSIF(p_x_uf_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute12 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute13 is null) THEN
                p_x_uf_header_rec.attribute13 := l_uf_header_rec.attribute13;
            ELSIF(p_x_uf_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute13 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute14 is null) THEN
                p_x_uf_header_rec.attribute14 := l_uf_header_rec.attribute14;
            ELSIF(p_x_uf_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute14 := null;
            END IF;

            IF (p_x_uf_header_rec.attribute15 is null) THEN
                p_x_uf_header_rec.attribute15 := l_uf_header_rec.attribute15;
            ELSIF(p_x_uf_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_header_rec.attribute15 := null;
            END IF;

        END IF;
        CLOSE uf_header_csr;
    ELSIF (p_x_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE) THEN

        IF (p_x_uf_header_rec.unit_config_header_id = FND_API.G_MISS_NUM) THEN
            p_x_uf_header_rec.unit_config_header_id := null;
        END IF;

        IF (p_x_uf_header_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN
            p_x_uf_header_rec.inventory_item_id := null;
        END IF;

        IF (p_x_uf_header_rec.csi_item_instance_id = FND_API.G_MISS_NUM) THEN
            p_x_uf_header_rec.csi_item_instance_id := null;
        END IF;

        IF (p_x_uf_header_rec.pc_node_id = FND_API.G_MISS_NUM) THEN
            p_x_uf_header_rec.pc_node_id := null;
        END IF;

        IF (p_x_uf_header_rec.inventory_org_id = FND_API.G_MISS_NUM) THEN
            p_x_uf_header_rec.inventory_org_id := null;
        END IF;

        IF (p_x_uf_header_rec.use_unit_flag is null) THEN
                p_x_uf_header_rec.use_unit_flag := AHL_UMP_UF_PVT.G_UF_USE_UNIT_DEFAULT;
        ELSIF(p_x_uf_header_rec.use_unit_flag = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.use_unit_flag := AHL_UMP_UF_PVT.G_UF_USE_UNIT_DEFAULT;
        END IF;

        IF (p_x_uf_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute_category := null;
        END IF;
        IF (p_x_uf_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute1 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute2 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute3 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute4 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute5 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute6 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN             p_x_uf_header_rec.attribute7 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute8 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute9 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute10 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute11 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute12 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute13 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute14 := null;
        END IF;
        IF (p_x_uf_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_header_rec.attribute15 := null;
        END IF;
     END IF;
END default_unchanged_uf_header;


----------------------------------------------------------
-- This procedure processes uf_detail_rec
----------------------------------------------------------
PROCEDURE process_uf_details(
    p_validation_level IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type,
    p_x_uf_details_tbl IN OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type
    ) IS

BEGIN
    --no value to id conversion involved here

    validate_uf_details(
    p_uf_header_rec    => p_uf_header_rec,
    p_x_uf_details_tbl => p_x_uf_details_tbl
    );

    default_unchanged_uf_details(p_x_uf_details_tbl => p_x_uf_details_tbl);
    --save details now
    FOR i IN p_x_uf_details_tbl.FIRST..p_x_uf_details_tbl.LAST  LOOP
        IF(p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_DELETE) THEN
            AHL_UF_DETAILS_PKG.delete_row(p_x_uf_details_tbl(i).uf_detail_id);
        END IF;
    END LOOP;

    FOR i IN p_x_uf_details_tbl.FIRST..p_x_uf_details_tbl.LAST  LOOP
        IF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE) THEN

           --setting object version number for create
           p_x_uf_details_tbl(i).object_version_number := p_x_uf_details_tbl(i).object_version_number + 1;
           --setting up user/create/update information
           p_x_uf_details_tbl(i).last_updated_by := fnd_global.user_id;
           p_x_uf_details_tbl(i).last_update_date := SYSDATE;
           p_x_uf_details_tbl(i).last_update_login := fnd_global.user_id;

           AHL_UF_DETAILS_PKG.update_row(
           x_uf_detail_id => p_x_uf_details_tbl(i).uf_detail_id,
           x_object_version_number => p_x_uf_details_tbl(i).object_version_number,
           x_last_updated_by => p_x_uf_details_tbl(i).last_updated_by,
           x_last_update_date => p_x_uf_details_tbl(i).last_update_date,
           x_last_update_login => p_x_uf_details_tbl(i).last_update_login,
           x_uf_header_id => p_x_uf_details_tbl(i).uf_header_id,
           x_uom_code => p_x_uf_details_tbl(i).uom_code,
           x_start_date => p_x_uf_details_tbl(i).start_date,
           x_end_date => p_x_uf_details_tbl(i).end_date,
           x_usage_per_day => p_x_uf_details_tbl(i).usage_per_day,
           x_attribute_category => p_x_uf_details_tbl(i).attribute_category,
           x_attribute1 => p_x_uf_details_tbl(i).attribute1,
           x_attribute2 => p_x_uf_details_tbl(i).attribute2,
           x_attribute3 => p_x_uf_details_tbl(i).attribute3,
           x_attribute4 => p_x_uf_details_tbl(i).attribute4,
           x_attribute5 => p_x_uf_details_tbl(i).attribute5,
           x_attribute6 => p_x_uf_details_tbl(i).attribute6,
           x_attribute7 => p_x_uf_details_tbl(i).attribute7,
           x_attribute8 => p_x_uf_details_tbl(i).attribute8,
           x_attribute9 => p_x_uf_details_tbl(i).attribute9,
           x_attribute10 => p_x_uf_details_tbl(i).attribute10,
           x_attribute11 => p_x_uf_details_tbl(i).attribute11,
           x_attribute12 => p_x_uf_details_tbl(i).attribute12,
           x_attribute13 => p_x_uf_details_tbl(i).attribute13,
           x_attribute14 => p_x_uf_details_tbl(i).attribute14,
           x_attribute15 => p_x_uf_details_tbl(i).attribute15
           );
        END IF;
    END LOOP;
    FOR i IN p_x_uf_details_tbl.FIRST..p_x_uf_details_tbl.LAST  LOOP
        IF(p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE) THEN
           --setting object version number for create
           p_x_uf_details_tbl(i).object_version_number := 1;
           --setting up user/create/update information
           p_x_uf_details_tbl(i).created_by := fnd_global.user_id;
           p_x_uf_details_tbl(i).creation_date := SYSDATE;
           p_x_uf_details_tbl(i).last_updated_by := fnd_global.user_id;
           p_x_uf_details_tbl(i).last_update_date := SYSDATE;
           p_x_uf_details_tbl(i).last_update_login := fnd_global.user_id;

           p_x_uf_details_tbl(i).uf_header_id := p_uf_header_rec.uf_header_id;

           AHL_UF_DETAILS_PKG.insert_row(
           x_uf_detail_id => p_x_uf_details_tbl(i).uf_detail_id,
           x_object_version_number => p_x_uf_details_tbl(i).object_version_number,
           x_created_by => p_x_uf_details_tbl(i).created_by,
           x_creation_date => p_x_uf_details_tbl(i).creation_date,
           x_last_updated_by => p_x_uf_details_tbl(i).last_updated_by,
           x_last_update_date => p_x_uf_details_tbl(i).last_update_date,
           x_last_update_login => p_x_uf_details_tbl(i).last_update_login,
           x_uf_header_id => p_x_uf_details_tbl(i).uf_header_id,
           x_uom_code => p_x_uf_details_tbl(i).uom_code,
           x_start_date => p_x_uf_details_tbl(i).start_date,
           x_end_date => p_x_uf_details_tbl(i).end_date,
           x_usage_per_day => p_x_uf_details_tbl(i).usage_per_day,
           x_attribute_category => p_x_uf_details_tbl(i).attribute_category,
           x_attribute1 => p_x_uf_details_tbl(i).attribute1,
           x_attribute2 => p_x_uf_details_tbl(i).attribute2,
           x_attribute3 => p_x_uf_details_tbl(i).attribute3,
           x_attribute4 => p_x_uf_details_tbl(i).attribute4,
           x_attribute5 => p_x_uf_details_tbl(i).attribute5,
           x_attribute6 => p_x_uf_details_tbl(i).attribute6,
           x_attribute7 => p_x_uf_details_tbl(i).attribute7,
           x_attribute8 => p_x_uf_details_tbl(i).attribute8,
           x_attribute9 => p_x_uf_details_tbl(i).attribute9,
           x_attribute10 => p_x_uf_details_tbl(i).attribute10,
           x_attribute11 => p_x_uf_details_tbl(i).attribute11,
           x_attribute12 => p_x_uf_details_tbl(i).attribute12,
           x_attribute13 => p_x_uf_details_tbl(i).attribute13,
           x_attribute14 => p_x_uf_details_tbl(i).attribute14,
           x_attribute15 => p_x_uf_details_tbl(i).attribute15
           );
        END IF;
    END LOOP;

    --validate saved data.. check for gaps etc
    validate_utilization_forecast(
    p_uf_header_rec    => p_uf_header_rec,
    x_uf_details_tbl  => p_x_uf_details_tbl
    );

    IF(FND_MSG_PUB.count_msg > 0)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END process_uf_details;


---------------------------------------------------------------------------------------------------------------------------------------------------
-- This procedure does the following validations for uf_details_tbl
-- verify operation flag is not null for all records
-- check if uf_header_id , if null, verify operation flag is create AHL_UMP_UF_PVT.G_OP_CREATE for all records in details
-- check if uf_detail_id is not null then operation flag is update AHL_UMP_UF_PVT.G_UF_TYPE_UNIT or 'D' and uf_header_id is not null
-- Validate that for every record in p_x_uf_details_tbl, start_date is < end_date(IF not null) and start_date is not null.
-- Validate that for every record in p_x_uf_details_tbl, usage_per_day is a valid number +ve,-ve or 0 .
-- Validate that for every record in p_x_uf_details_tbl, uom  is valid.
-- If operation_flag is "U" or "D" verfiy object version number if they are same as in database.
-- If operation_flag is "U", if start_date < SYSDATE, split this record and
--                  update current record with UOM for this record in DB and end date as SYSDATE - 1
--                  add a new one with with start date as SYSDATE and operation flag as AHL_UMP_UF_PVT.G_OP_CREATE
-- If operation_flag is "D", if start_date < SYSDATE, put end date as SYSDATE -1 (yesterday's date).set operation_flag as AHL_UMP_UF_PVT.G_UF_TYPE_UNIT
-- update x_return_status on error , break if required
---------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE validate_uf_details(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type,
    p_x_uf_details_tbl IN OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type
    ) IS

 CURSOR uf_details_csr (p_uf_detail_id  IN  NUMBER) IS
 SELECT object_version_number, uf_header_id,uom_code,start_date,end_date,usage_per_day
 FROM ahl_uf_details
 WHERE uf_detail_id = p_uf_detail_id;

 l_object_version_number NUMBER;
 l_uf_header_id NUMBER;
 l_uom_code ahl_uf_details.uom_code%TYPE;
 l_start_date DATE;
 l_end_date DATE;
 l_usage_per_day NUMBER;

 l_total NUMBER;
 l_last NUMBER;

 CURSOR part_uom_code_ckeck_csr(p_uom_code IN VARCHAR2) IS
 select 'x'
 from mtl_units_of_measure_vl
 where uom_code = p_uom_code;

 CURSOR node_uom_code_ckeck_csr(p_uom_code IN VARCHAR2) IS
 select 'x'
 from mtl_units_of_measure_vl
 where uom_code = p_uom_code;

 CURSOR unit_uom_code_ckeck_csr(p_uom_code IN VARCHAR2) IS
 select 'x'
 from mtl_units_of_measure_vl
 where uom_code = p_uom_code;

 l_exists VARCHAR2(1);

BEGIN
    l_total := p_x_uf_details_tbl.count;
    FOR i IN p_x_uf_details_tbl.FIRST..l_total  LOOP
       --checking for unexpected errors
       IF ( p_x_uf_details_tbl(i).operation_flag IS NOT NULL AND p_x_uf_details_tbl(i).operation_flag NOT IN(AHL_UMP_UF_PVT.G_OP_CREATE,AHL_UMP_UF_PVT.G_OP_UPDATE,AHL_UMP_UF_PVT.G_OP_DELETE))THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_DETAIL');
           FND_MSG_PUB.ADD;
       ELSIF (p_uf_header_rec.operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND p_x_uf_details_tbl(i).operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_OP_DET_HED');
           FND_MSG_PUB.ADD;
       ELSIF ((p_x_uf_details_tbl(i).operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE AND p_x_uf_details_tbl(i).uf_detail_id IS NULL) OR
              (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND p_x_uf_details_tbl(i).uf_detail_id IS NOT NULL))  THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INVOP_DETAIL');
           FND_MSG_PUB.ADD;
       END IF;
       -- Raise if unexpected errors
       IF FND_MSG_PUB.count_msg > 0 THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE AND
           p_x_uf_details_tbl(i).end_date = FND_API.G_MISS_DATE) THEN
           p_x_uf_details_tbl(i).end_date := NULL;

       -- checking for expected error if record is modified
       ELSIF (p_x_uf_details_tbl(i).operation_flag <> AHL_UMP_UF_PVT.G_OP_CREATE AND p_x_uf_details_tbl(i).uf_detail_id IS NOT NULL)THEN
           OPEN  uf_details_csr(p_x_uf_details_tbl(i).uf_detail_id);
           FETCH uf_details_csr INTO l_object_version_number, l_uf_header_id,l_uom_code,l_start_date,l_end_date,l_usage_per_day;
           IF (uf_details_csr%NOTFOUND) THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_DET_INV_NOTINDB');
               FND_MSG_PUB.ADD;
           ELSIF l_object_version_number <> p_x_uf_details_tbl(i).object_version_number THEN
               FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_DET_OBJV_MIS');
               FND_MSG_PUB.ADD;
           ELSE
            IF p_x_uf_details_tbl(i).end_date IS NULL THEN
               p_x_uf_details_tbl(i).end_date := l_end_date;
            ELSIF p_x_uf_details_tbl(i).end_date = FND_API.G_MISS_DATE THEN
               p_x_uf_details_tbl(i).end_date := NULL;
            END IF;
            IF p_x_uf_details_tbl(i).uf_header_id IS NULL THEN
                p_x_uf_details_tbl(i).uf_header_id := l_uf_header_id;
            ELSIF p_x_uf_details_tbl(i).uf_header_id = FND_API.G_MISS_NUM THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_DET_UFHID');
                FND_MSG_PUB.ADD;
            ELSIF (p_x_uf_details_tbl(i).uf_header_id <> l_uf_header_id) THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_DET_UFHID');
                FND_MSG_PUB.ADD;
            END IF;
           END IF;
          CLOSE uf_details_csr;
       END IF;

       IF(FND_MSG_PUB.count_msg > 0)THEN
           RAISE  FND_API.G_EXC_ERROR;
       END IF;

       -- checking for expected error if start date , end date,UOM are invalid
       IF(p_x_uf_details_tbl(i).operation_flag IN (AHL_UMP_UF_PVT.G_OP_CREATE,AHL_UMP_UF_PVT.G_OP_UPDATE))THEN
         -- checking for start and end dates
         IF(p_x_uf_details_tbl(i).start_date IS NULL) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_SDATE_NLL');
            FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
            FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
            FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
            FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
            FND_MSG_PUB.ADD;
         ELSIF (p_x_uf_details_tbl(i).end_date IS NOT NULL) THEN
            IF ((TRUNC(p_x_uf_details_tbl(i).end_date) < TRUNC(p_x_uf_details_tbl(i).start_date)) OR
                (TRUNC(p_x_uf_details_tbl(i).end_date) < TRUNC(SYSDATE)))THEN
              FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_EDATE');
              FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
              FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
              FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
              FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
              FND_MSG_PUB.ADD;
            ELSIF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE) THEN
              IF(TRUNC(p_x_uf_details_tbl(i).start_date) < TRUNC(SYSDATE))THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_SDATE');
                FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                FND_MSG_PUB.ADD;
              END IF;
            ELSIF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE) THEN
              IF ( TRUNC(p_x_uf_details_tbl(i).start_date) < TRUNC(SYSDATE) AND
                  (TRUNC(p_x_uf_details_tbl(i).start_date) <> TRUNC(l_start_date) OR
                 p_x_uf_details_tbl(i).uom_code <> l_uom_code))  THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_DONCHG_STD_UOM');
                 FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                 FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                 FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                 FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                 FND_MSG_PUB.ADD;
              END IF;
            END IF;
         ELSIF (p_x_uf_details_tbl(i).end_date IS NULL) THEN
            IF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE) THEN
              IF(TRUNC(p_x_uf_details_tbl(i).start_date) < TRUNC(SYSDATE))THEN
                FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_SDATE');
                FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                FND_MSG_PUB.ADD;
              END IF;
            ELSIF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE) THEN
              IF ( TRUNC(p_x_uf_details_tbl(i).start_date) < TRUNC(SYSDATE) AND
                  (TRUNC(p_x_uf_details_tbl(i).start_date) <> TRUNC(l_start_date) OR
                 p_x_uf_details_tbl(i).uom_code <> l_uom_code))  THEN
                 FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_DONCHG_STD_UOM');
                 FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                 FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                 FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                 FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                 FND_MSG_PUB.ADD;
              END IF;
            END IF;
         END IF;

        --checking for expected error if UOM is invalid
        IF(p_x_uf_details_tbl(i).uom_code IS NULL) THEN
           FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_UOMCD_NLL');
           FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
           FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
           FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
           FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
           FND_MSG_PUB.ADD;
        ELSE
           IF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_OP_UPDATE)THEN
                OPEN unit_uom_code_ckeck_csr(p_x_uf_details_tbl(i).uom_code);
                FETCH unit_uom_code_ckeck_csr into l_exists;
                IF (unit_uom_code_ckeck_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UOMCD');
                    FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                    FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                    FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                    FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE unit_uom_code_ckeck_csr;
           ELSIF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PART)THEN
                OPEN part_uom_code_ckeck_csr(p_x_uf_details_tbl(i).uom_code);
                FETCH part_uom_code_ckeck_csr into l_exists;
                IF (part_uom_code_ckeck_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UOMCD');
                    FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                    FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                    FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                    FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE part_uom_code_ckeck_csr;
           ELSIF (p_uf_header_rec.forecast_type = AHL_UMP_UF_PVT.G_UF_TYPE_PC_NODE)THEN
                OPEN node_uom_code_ckeck_csr(p_x_uf_details_tbl(i).uom_code);
                FETCH node_uom_code_ckeck_csr into l_exists;
                IF (node_uom_code_ckeck_csr%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_INV_UOMCD');
                    FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                    FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                    FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                    FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE node_uom_code_ckeck_csr;
           END IF;
        END IF;--UOM code check
      END IF;

      --spliting and end-dating
      IF (FND_MSG_PUB.count_msg = 0) THEN
       IF(p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE)THEN
           IF TRUNC(p_x_uf_details_tbl(i).start_date) < TRUNC(SYSDATE) THEN
               IF((TRUNC(p_x_uf_details_tbl(i).start_date) <> TRUNC(l_start_date))OR
                   (p_x_uf_details_tbl(i).uom_code <> l_uom_code))  THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_DONCHG_STD_UOM');
                    FND_MESSAGE.Set_Token('START_DATE',p_x_uf_details_tbl(i).start_date);
                    FND_MESSAGE.Set_Token('END_DATE',p_x_uf_details_tbl(i).end_date);
                    FND_MESSAGE.Set_Token('UOM_CODE',p_x_uf_details_tbl(i).uom_code);
                    FND_MESSAGE.Set_Token('USAGE_PER_DAY',p_x_uf_details_tbl(i).usage_per_day);
                    FND_MSG_PUB.ADD;
               ELSIF ((TRUNC(p_x_uf_details_tbl(i).end_date) <> TRUNC(l_end_date))OR
                   (p_x_uf_details_tbl(i).usage_per_day <> l_usage_per_day))  THEN
                   -- adding new record
                   l_last := p_x_uf_details_tbl.count + 1;
                   p_x_uf_details_tbl(l_last).start_date := SYSDATE;
                   p_x_uf_details_tbl(l_last).end_date := p_x_uf_details_tbl(i).end_date;
                   p_x_uf_details_tbl(l_last).usage_per_day := p_x_uf_details_tbl(i).usage_per_day;
                   p_x_uf_details_tbl(l_last).uom_code := p_x_uf_details_tbl(i).uom_code;
                   p_x_uf_details_tbl(l_last).operation_flag := AHL_UMP_UF_PVT.G_OP_CREATE;
                   p_x_uf_details_tbl(l_last).uf_header_id := p_x_uf_details_tbl(i).uf_header_id;
                   -- Modifying and end-dating existing record.
                   p_x_uf_details_tbl(i).end_date := TRUNC(SYSDATE - 1);
                   p_x_uf_details_tbl(i).uom_code := l_uom_code;
                   p_x_uf_details_tbl(i).usage_per_day := l_usage_per_day;

                END IF;
           END IF;
       -- end dating if start date < sysdate
       ELSIF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_DELETE)THEN
           IF(TRUNC(l_start_date) < TRUNC(SYSDATE))THEN
                p_x_uf_details_tbl(i).start_date := l_start_date;
                p_x_uf_details_tbl(i).end_date := SYSDATE - 1;
                p_x_uf_details_tbl(i).uom_code := l_uom_code;
                p_x_uf_details_tbl(i).usage_per_day := l_usage_per_day;
                p_x_uf_details_tbl(i).operation_flag := AHL_UMP_UF_PVT.G_OP_UPDATE;
          END IF;
       END IF;
      END IF; --end splitting and end dating

    END LOOP;

    IF FND_MSG_PUB.count_msg > 0 THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

END validate_uf_details;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- This procedure verfies whether saved utilization forecast was validate_uf_detailsand had no gaps.
-- fetch details table records for this uf_header_id ordered by UOM, start date where endt_date >= Sysdate - 1.
-- for same UOM, end date of one record should always be one less than the start date of next record
-- update x_return_status on error , break if required
-----------------------------------------------------------------------------------------------------------------------------------------------------


PROCEDURE validate_utilization_forecast(
    p_uf_header_rec  IN AHL_UMP_UF_PVT.uf_header_rec_type,
    x_uf_details_tbl OUT NOCOPY AHL_UMP_UF_PVT.uf_details_tbl_type
    ) IS

    CURSOR uf_sorted_details_csr (p_uf_header_id  IN  NUMBER) IS
    SELECT object_version_number, uf_detail_id, uf_header_id,uom_code,start_date,end_date,usage_per_day
    FROM ahl_uf_details
    WHERE uf_header_id = p_uf_header_id
    AND (end_date IS NULL OR TRUNC(end_date) >= TRUNC(SYSDATE))
    ORDER BY uom_code,start_date;

    i NUMBER;

BEGIN
    i:= 1;

    OPEN  uf_sorted_details_csr(p_uf_header_rec.uf_header_id);
    LOOP
        FETCH uf_sorted_details_csr INTO x_uf_details_tbl(i).object_version_number,
        				 x_uf_details_tbl(i).uf_detail_id,
        				 x_uf_details_tbl(i).uf_header_id,
        				 x_uf_details_tbl(i).uom_code,
        				 x_uf_details_tbl(i).start_date,
        				 x_uf_details_tbl(i).end_date,
        				 x_uf_details_tbl(i).usage_per_day;
        exit when uf_sorted_details_csr%notfound;
        i := i + 1;
    END LOOP;

    CLOSE uf_sorted_details_csr;
    IF(x_uf_details_tbl.COUNT > 0) THEN
     FOR i IN x_uf_details_tbl.FIRST..x_uf_details_tbl.LAST  LOOP
        IF(x_uf_details_tbl.LAST > i) THEN
            IF(x_uf_details_tbl(i).uom_code = x_uf_details_tbl(i+1).uom_code) THEN
               IF(x_uf_details_tbl(i).end_date IS NULL) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_UMP_UF_OLAPS_IN_UF');
                FND_MESSAGE.Set_Token('FSTART_DATE',x_uf_details_tbl(i).start_date);
                FND_MESSAGE.Set_Token('FEND_DATE',x_uf_details_tbl(i).end_date);
                FND_MESSAGE.Set_Token('FUOM_CODE',x_uf_details_tbl(i).uom_code);
                FND_MESSAGE.Set_Token('FUSAGE_PER_DAY',x_uf_details_tbl(i).usage_per_day);
                FND_MESSAGE.Set_Token('NSTART_DATE',x_uf_details_tbl(i+1).start_date);
                FND_MESSAGE.Set_Token('NEND_DATE',x_uf_details_tbl(i+1).end_date);
                FND_MESSAGE.Set_Token('NUOM_CODE',x_uf_details_tbl(i+1).uom_code);
                FND_MESSAGE.Set_Token('NUSAGE_PER_DAY',x_uf_details_tbl(i+1).usage_per_day);
                FND_MSG_PUB.ADD;
               ELSIF TRUNC(x_uf_details_tbl(i+1).start_date) <> TRUNC(x_uf_details_tbl(i).end_date + 1) THEN
                IF(TRUNC(x_uf_details_tbl(i+1).start_date) > TRUNC(x_uf_details_tbl(i).end_date + 1)) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_UMP_UF_GAPS_IN_UF');
                ELSE
                    FND_MESSAGE.Set_Name('AHL','AHL_UMP_UF_OLAPS_IN_UF');
                END IF;
                FND_MESSAGE.Set_Token('FSTART_DATE',x_uf_details_tbl(i).start_date);
                FND_MESSAGE.Set_Token('FEND_DATE',x_uf_details_tbl(i).end_date);
                FND_MESSAGE.Set_Token('FUOM_CODE',x_uf_details_tbl(i).uom_code);
                FND_MESSAGE.Set_Token('FUSAGE_PER_DAY',x_uf_details_tbl(i).usage_per_day);
                FND_MESSAGE.Set_Token('NSTART_DATE',x_uf_details_tbl(i+1).start_date);
                FND_MESSAGE.Set_Token('NEND_DATE',x_uf_details_tbl(i+1).end_date);
                FND_MESSAGE.Set_Token('NUOM_CODE',x_uf_details_tbl(i+1).uom_code);
                FND_MESSAGE.Set_Token('NUSAGE_PER_DAY',x_uf_details_tbl(i+1).usage_per_day);
                FND_MSG_PUB.ADD;
               END IF;
            END IF;
        END IF;
     END LOOP;
    END IF;

    IF FND_MSG_PUB.count_msg > 0 THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

END validate_utilization_forecast;

--------------------------------------------------------------------------------
-- This procedure writes message.
--------------------------------------------------------------------------------
PROCEDURE default_unchanged_uf_details(
	p_x_uf_details_tbl   		IN OUT NOCOPY 	AHL_UMP_UF_PVT.uf_details_tbl_type
    ) IS

CURSOR uf_details_csr(p_uf_detail_id IN NUMBER, p_object_version_number IN NUMBER) IS
SELECT uf_header_id,end_date,attribute_category, attribute1,attribute2, attribute3, attribute4,
     attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, attribute11,
     attribute12, attribute13, attribute14, attribute15
FROM ahl_uf_details
WHERE object_version_number= p_object_version_number
AND uf_detail_id = p_uf_detail_id;

l_uf_details_rec AHL_UMP_UF_PVT.uf_details_rec_type;

BEGIN
    FOR i IN p_x_uf_details_tbl.FIRST..p_x_uf_details_tbl.LAST  LOOP
    IF(p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_UPDATE) THEN
        OPEN uf_details_csr(p_x_uf_details_tbl(i).uf_detail_id, p_x_uf_details_tbl(i).object_version_number);
        FETCH uf_details_csr INTO l_uf_details_rec.uf_header_id,l_uf_details_rec.end_date,l_uf_details_rec.attribute_category,l_uf_details_rec.attribute1,l_uf_details_rec.attribute2,
         l_uf_details_rec.attribute3, l_uf_details_rec.attribute4, l_uf_details_rec.attribute5, l_uf_details_rec.attribute6, l_uf_details_rec.attribute7,
         l_uf_details_rec.attribute8, l_uf_details_rec.attribute9, l_uf_details_rec.attribute10, l_uf_details_rec.attribute11, l_uf_details_rec.attribute12,
         l_uf_details_rec.attribute13, l_uf_details_rec.attribute14, l_uf_details_rec.attribute15;
        IF (uf_details_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_UMP_UF_DET_OBJV_MIS');
            FND_MSG_PUB.ADD;
        ELSE
            IF (p_x_uf_details_tbl(i).uf_header_id is null) THEN
                p_x_uf_details_tbl(i).uf_header_id := l_uf_details_rec.uf_header_id;
            ELSIF(p_x_uf_details_tbl(i).uf_header_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_details_tbl(i).uf_header_id := null;
            END IF;

            IF (p_x_uf_details_tbl(i).end_date is null) THEN
                p_x_uf_details_tbl(i).end_date := l_uf_details_rec.end_date;
            ELSIF(p_x_uf_details_tbl(i).end_date = FND_API.G_MISS_DATE) THEN
                p_x_uf_details_tbl(i).end_date := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute_category is null) THEN
                p_x_uf_details_tbl(i).attribute_category := l_uf_details_rec.attribute_category;
            ELSIF(p_x_uf_details_tbl(i).attribute_category = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute_category := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute1 is null) THEN
                p_x_uf_details_tbl(i).attribute1 := l_uf_details_rec.attribute1;
            ELSIF(p_x_uf_details_tbl(i).attribute1 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute1 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute2 is null) THEN
                p_x_uf_details_tbl(i).attribute2 := l_uf_details_rec.attribute2;
            ELSIF(p_x_uf_details_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute2 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute3 is null) THEN
                p_x_uf_details_tbl(i).attribute3 := l_uf_details_rec.attribute3;
            ELSIF(p_x_uf_details_tbl(i).attribute3 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute3 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute4 is null) THEN
                p_x_uf_details_tbl(i).attribute4 := l_uf_details_rec.attribute4;
            ELSIF(p_x_uf_details_tbl(i).attribute4 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute4 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute5 is null) THEN
                p_x_uf_details_tbl(i).attribute5 := l_uf_details_rec.attribute5;
            ELSIF(p_x_uf_details_tbl(i).attribute5 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute5 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute6 is null) THEN
                p_x_uf_details_tbl(i).attribute6 := l_uf_details_rec.attribute6;
            ELSIF(p_x_uf_details_tbl(i).attribute6 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute6 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute7 is null) THEN
                p_x_uf_details_tbl(i).attribute7 := l_uf_details_rec.attribute7;
            ELSIF(p_x_uf_details_tbl(i).attribute7 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute7 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute8 is null) THEN
                p_x_uf_details_tbl(i).attribute8 := l_uf_details_rec.attribute8;
            ELSIF(p_x_uf_details_tbl(i).attribute8 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute8 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute9 is null) THEN
                p_x_uf_details_tbl(i).attribute9 := l_uf_details_rec.attribute9;
            ELSIF(p_x_uf_details_tbl(i).attribute9 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute9 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute10 is null) THEN
                p_x_uf_details_tbl(i).attribute10 := l_uf_details_rec.attribute10;
            ELSIF(p_x_uf_details_tbl(i).attribute10 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute10 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute11 is null) THEN
                p_x_uf_details_tbl(i).attribute11 := l_uf_details_rec.attribute11;
            ELSIF(p_x_uf_details_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute11 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute12 is null) THEN
                p_x_uf_details_tbl(i).attribute12 := l_uf_details_rec.attribute12;
            ELSIF(p_x_uf_details_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute12 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute13 is null) THEN
                p_x_uf_details_tbl(i).attribute13 := l_uf_details_rec.attribute13;
            ELSIF(p_x_uf_details_tbl(i).attribute13 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute13 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute14 is null) THEN
                p_x_uf_details_tbl(i).attribute14 := l_uf_details_rec.attribute14;
            ELSIF(p_x_uf_details_tbl(i).attribute14 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute14 := null;
            END IF;

            IF (p_x_uf_details_tbl(i).attribute15 is null) THEN
                p_x_uf_details_tbl(i).attribute15 := l_uf_details_rec.attribute15;
            ELSIF(p_x_uf_details_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
                p_x_uf_details_tbl(i).attribute15 := null;
            END IF;

        END IF;
        CLOSE uf_details_csr;
    ELSIF (p_x_uf_details_tbl(i).operation_flag = AHL_UMP_UF_PVT.G_OP_CREATE) THEN

        IF(p_x_uf_details_tbl(i).uf_header_id = FND_API.G_MISS_NUM) THEN
                p_x_uf_details_tbl(i).uf_header_id := null;
        END IF;

        IF(p_x_uf_details_tbl(i).end_date = FND_API.G_MISS_DATE) THEN
            p_x_uf_details_tbl(i).end_date := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute_category = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute_category := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute1 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute1 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute2 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute3 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute3 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute4 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute4 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute5 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute5 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute6 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute6 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute7 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute7 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute8 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute8 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute9 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute9 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute10 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute10 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute11 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute12 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute13 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute13 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute14 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute14 := null;
        END IF;
        IF (p_x_uf_details_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
            p_x_uf_details_tbl(i).attribute15 := null;
        END IF;

    END IF;
    END LOOP;

END default_unchanged_uf_details;
-------------------------------------------------------------------------------------
-- This procedure deletes header if no forecast detials and use unit flag is also 'N'
-------------------------------------------------------------------------------------
PROCEDURE post_process_uf_header(
    p_uf_header_rec    IN AHL_UMP_UF_PVT.uf_header_Rec_type
    ) IS

    CURSOR uf_details_csr (p_uf_header_id  IN  NUMBER) IS
    SELECT 'x'
    FROM ahl_uf_details WHERE uf_header_id = p_uf_header_id;

    l_exist VARCHAR2(1);


BEGIN
    IF(p_uf_header_rec.use_unit_flag IS NULL OR p_uf_header_rec.use_unit_flag = G_UF_USE_UNIT_DEFAULT) THEN
      OPEN uf_details_csr (p_uf_header_rec.uf_header_id);
      FETCH uf_details_csr INTO l_exist;
      IF(uf_details_csr%NOTFOUND) THEN
         AHL_UF_HEADERS_PKG.delete_row(p_uf_header_rec.uf_header_id);
      END IF;
      CLOSE uf_details_csr;
    END IF;
END post_process_uf_header;



----------------------------------------------------------------------
-- Procedure to get Utilzation Forecast from Product Classification --
----------------------------------------------------------------------
-- added parameter p_add_unit_item_forecast to fix bug# 6749351.
-- This flag is currently being applied to only item based forecasts.
PROCEDURE get_uf_from_pc (
                          p_init_msg_list               IN            VARCHAR2  := FND_API.G_FALSE,
                          p_pc_node_id                  IN            NUMBER := NULL,
                          p_inventory_item_id           IN            NUMBER := NULL,
                          p_inventory_org_id            IN            NUMBER := NULL,
                          p_unit_config_header_id       IN            NUMBER := NULL,
                          p_unit_name                   IN            VARCHAR2:=NULL,
                          p_part_number                 IN            VARCHAR2 :=NULL,
                          p_onward_end_date             IN            DATE     := NULL,
                          p_add_unit_item_forecast IN  VARCHAR2  := 'N',
                          x_UF_details_tbl              OUT NOCOPY    AHL_UMP_UF_PVT.uf_details_tbl_type,
                          x_return_status               OUT NOCOPY    VARCHAR2)
IS
--
 CURSOR ahl_get_config_header_id_csr(c_unit_name  IN   VARCHAR2) IS
   SELECT  unit_config_header_id
    FROM    ahl_unit_config_headers
    WHERE   name = c_unit_name;
--
 CURSOR ahl_get_inv_item_id_csr(c_part_number  IN   mtl_system_items_kfv.concatenated_segments%TYPE) IS
   SELECT  inventory_item_id
    FROM    mtl_system_items_kfv
    WHERE   concatenated_segments = c_part_number;
--
 CURSOR ahl_pc_id_from_assoc_csr(c_unit_config_header_id  IN NUMBER,
				c_type IN VARCHAR2,
				c_primary_flag IN VARCHAR2,
				c_complete_status IN VARCHAR2 ) IS
   SELECT a.pc_node_id
    FROM  ahl_pc_associations a, ahl_pc_nodes_b b, ahl_pc_headers_b c
    WHERE   a.unit_item_id = c_unit_config_header_id
      AND   a.association_type_flag = c_type
      AND   a.pc_node_id = b.pc_node_id
      AND   b.pc_header_id = c.pc_header_id
      AND   c.primary_flag = c_primary_flag
      AND   c.status = c_complete_status;
--
 CURSOR ahl_item_id_from_uc_header_csr(c_uc_header_id IN NUMBER) IS
    SELECT a.inventory_item_id
      FROM csi_item_instances a, ahl_unit_config_headers b
     WHERE a.instance_id = b.csi_item_instance_id
       AND b.unit_config_header_id = c_uc_header_id;
--
 CURSOR ahl_check_pc_id_csr(p_pc_node_id  IN NUMBER,
			    c_primary_flag IN VARCHAR2,
			    c_complete_status IN VARCHAR2 ) IS
  SELECT 'x'
    FROM   ahl_pc_nodes_b a, ahl_pc_headers_b b
    WHERE   a.pc_node_id = p_pc_node_id
      AND   a.pc_header_id = b.pc_header_id
      AND   b.primary_flag = c_primary_flag
      AND   b.status = c_complete_status;
--
 CURSOR ahl_trav_pc_nodes_csr (c_pc_id  IN   NUMBER) IS
   SELECT  pc_node_id
    FROM    ahl_pc_nodes_b
    START WITH pc_node_id = c_pc_id
    CONNECT BY pc_node_id = PRIOR parent_node_id;
--
 CURSOR ahl_uf_uom_nodes_csr (c_pc_id  IN   NUMBER) IS
   SELECT  distinct a.uom_code
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE a.uf_header_id = b.uf_header_id
     AND  b.pc_node_id = c_pc_id;
--
 CURSOR ahl_uf_details_csr (c_pc_id  IN   NUMBER, p_uom_code IN VARCHAR2) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE a.uom_code = p_uom_code
     AND  b.pc_node_id = c_pc_id
     AND a.uf_header_id = b.uf_header_id;
--
   CURSOR ahl_uf_details_date_csr (p_pc_id  IN   NUMBER, p_uom_code IN VARCHAR2,p_onward_end_date IN DATE) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE (a.end_date IS NULL OR TRUNC(a.end_date) >= TRUNC(p_onward_end_date))
     AND a.uf_header_id = b.uf_header_id
     AND a.uom_code = p_uom_code
     AND  b.pc_node_id = p_pc_id;

   -- added to fix bug# 6749351
   CURSOR ahl_uf_uom_item_csr (p_inventory_item_id  IN   NUMBER) IS
   SELECT  distinct a.uom_code
   FROM    ahl_uf_details a, ahl_uf_headers b
   WHERE a.uf_header_id = b.uf_header_id
      AND  b.inventory_item_id = p_inventory_item_id;

   -- get uf details for item for all dates.
   CURSOR ahl_uf_item_details_csr(p_inventory_item_id IN   NUMBER,
                                  p_uom_code          IN   VARCHAR2) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE a.uf_header_id = b.uf_header_id
     AND a.uom_code = p_uom_code
     AND  b.inventory_item_id = p_inventory_item_id;

   -- get uf details for item based on p_onward_end_date.
   CURSOR ahl_uf_item_details_date_csr(p_inventory_item_id IN   NUMBER,
                                       p_uom_code          IN   VARCHAR2,
                                       p_onward_end_date   IN   DATE) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE (a.end_date IS NULL OR TRUNC(a.end_date) >= TRUNC(p_onward_end_date))
    AND a.uf_header_id = b.uf_header_id
     AND a.uom_code = p_uom_code
     AND  b.inventory_item_id = p_inventory_item_id;

   -- added to fix bug# 6749351
   CURSOR ahl_uf_uom_unit_csr (p_unit_config_id IN  NUMBER) IS
   SELECT  distinct a.uom_code
   FROM    ahl_uf_details a, ahl_uf_headers b
   WHERE a.uf_header_id = b.uf_header_id
      AND  b.unit_config_header_id = p_unit_config_id;

   -- get uf details for item for all dates.
   CURSOR ahl_uf_unit_details_csr(p_unit_config_id IN   NUMBER,
                                  p_uom_code          IN   VARCHAR2) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE a.uf_header_id = b.uf_header_id
     AND a.uom_code = p_uom_code
     AND  b.unit_config_header_id = p_unit_config_id;

   -- get uf details for item based on p_onward_end_date.
   CURSOR ahl_uf_unit_details_date_csr(p_unit_config_id    IN   NUMBER,
                                       p_uom_code          IN   VARCHAR2,
                                       p_onward_end_date   IN   DATE) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b
    WHERE (a.end_date IS NULL OR TRUNC(a.end_date) >= TRUNC(p_onward_end_date))
    AND a.uf_header_id = b.uf_header_id
    AND a.uom_code = p_uom_code
    AND  b.unit_config_header_id = p_unit_config_id;
--
    l_UF_details_tbl     	AHL_UMP_UF_PVT.uf_details_tbl_type;
    l_UF_details_rec 		AHL_UMP_UF_PVT.uf_details_rec_type;
    l_temp_details_rec     	ahl_uf_details_csr%ROWTYPE;
    l_unit_config_header_id     NUMBER DEFAULT p_unit_config_header_id;
    l_inventory_item_id         NUMBER DEFAULT p_inventory_item_id;
    l_pc_node_id   		NUMBER DEFAULT p_PC_node_id;
    l_pc_id          NUMBER;
    l_uom_code       AHL_UF_DETAILS.UOM_CODE%TYPE;
    l_msg_count      NUMBER;
    l_duplicate      VARCHAR2(1);
    l_junk           VARCHAR2(1);
    j                NUMBER;
--
BEGIN

  -- Initialize Procedure return status to success
   -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;   j := 0;

  --Part 1. Resolve all possible inputs to l_pc_node_id

  --Resolve unit name into unit config header id
  IF (p_unit_config_header_id IS NULL AND p_unit_name IS NOT NULL) THEN
     OPEN ahl_get_config_header_id_csr(p_unit_name);
     FETCH ahl_get_config_header_id_csr INTO l_unit_config_header_id;
     CLOSE ahl_get_config_header_id_csr;
  END IF;

  --Resolve part number into inventory item id
  IF (p_inventory_item_id IS NULL AND p_part_number IS NOT NULL) THEN
     OPEN ahl_get_inv_item_id_csr(p_part_number);
     FETCH ahl_get_inv_item_id_csr INTO l_inventory_item_id;
     CLOSE ahl_get_inv_item_id_csr;
  END IF;

  --Verify that exactly one of the IDs is defined.
  IF ((l_pc_node_id IS NULL AND
       l_inventory_item_id IS NULL AND
       l_unit_config_header_id IS NULL)
      OR (l_pc_node_id IS NOT NULL AND
          l_inventory_item_id IS NOT NULL)
      OR (l_pc_node_id IS NOT NULL AND
          l_unit_config_header_id IS NOT NULL)
      OR (l_unit_config_header_id IS NOT NULL AND
          l_inventory_item_id IS NOT NULL) ) THEN
         FND_MESSAGE.Set_Name('AHL','AHL_UMP_UTIL_ONLY_ONE_ID');
         FND_MSG_PUB.ADD;
  END IF;

  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RETURN;
  END IF;

  --Now verify pc node id is in 'COMPLETE' and 'PRIMARY' PC tree
  IF (l_pc_node_id IS NOT NULL) THEN
      OPEN ahl_check_pc_id_csr(l_pc_node_id,
  			        AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG,
  			        AHL_UMP_UF_PVT.G_COMPLETE_STATUS);
      FETCH ahl_check_pc_id_csr INTO l_junk;
      IF (ahl_check_pc_id_csr%NOTFOUND) THEN
	  l_pc_node_id := NULL;
  --       FND_MESSAGE.Set_Name('AHL','AHL_UMP_UTIL_NO_PRIM_PC');
  --       FND_MESSAGE.Set_Token('UID',l_pc_node_id);
  --      FND_MSG_PUB.ADD;
      END IF;
      CLOSE ahl_check_pc_id_csr;
  END IF;

  --Resolve unit_config_header_id into a pc node id
  IF (l_unit_config_header_id IS NOT NULL) THEN
     OPEN ahl_pc_id_from_assoc_csr(l_unit_config_header_id,
				 AHL_UMP_UF_PVT.G_PC_UNIT_ASSOCIATION,
				 AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG,
				 AHL_UMP_UF_PVT.G_COMPLETE_STATUS);
     FETCH ahl_pc_id_from_assoc_csr INTO l_pc_node_id;
     IF (ahl_pc_id_from_assoc_csr%NOTFOUND) THEN
        l_pc_node_id := NULL;

        --If can not find PC as unit, then try it with item
        OPEN ahl_item_id_from_uc_header_csr(l_unit_config_header_id);
        FETCH ahl_item_id_from_uc_header_csr INTO l_inventory_item_id;
	CLOSE ahl_item_id_from_uc_header_csr;

     --   FND_MESSAGE.Set_Name('AHL','AHL_UMP_UTIL_NO_PRIM_PC');
     --   FND_MESSAGE.Set_Token('UID',l_unit_config_header_id);
     --   FND_MSG_PUB.ADD;
     END IF;
     CLOSE ahl_pc_id_from_assoc_csr;

     /*
     -- Added to fix bug# 6749351
     IF (p_add_unit_item_forecast = 'Y') THEN
      OPEN ahl_uf_uom_unit_csr(l_unit_config_header_id);
      LOOP
         FETCH ahl_uf_uom_unit_csr INTO l_uom_code;
         EXIT WHEN ahl_uf_uom_unit_csr%NOTFOUND;
         IF(p_onward_end_date IS NULL) THEN
            OPEN ahl_uf_unit_details_csr(l_unit_config_header_id, l_uom_code);
            LOOP
              FETCH ahl_uf_unit_details_csr INTO l_temp_details_rec;
              EXIT WHEN ahl_uf_unit_details_csr%NOTFOUND;

              l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
              l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
              l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
              l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
              l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
              l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
              l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
              l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
              l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
              l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
              l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
              l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
              l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
              l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
              l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
              l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
              l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
              l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
              l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
              l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
              l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
              l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
              l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
              l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
              l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
              l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
              l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
              l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;
              l_UF_details_tbl(j) := l_UF_details_rec;
              j := j+1;
            END LOOP;
            CLOSE ahl_uf_unit_details_csr;
        ELSE
            OPEN ahl_uf_unit_details_date_csr(l_unit_config_header_id, l_uom_code,p_onward_end_date);
            LOOP
              FETCH ahl_uf_unit_details_date_csr INTO l_temp_details_rec;
              EXIT WHEN ahl_uf_unit_details_date_csr%NOTFOUND;

              l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
              l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
              l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
              l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
              l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
              l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
              l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
              l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
              l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
              l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
              l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
              l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
              l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
              l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
              l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
              l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
              l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
              l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
              l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
              l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
              l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
              l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
              l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
              l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
              l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
              l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
              l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
              l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;

              l_UF_details_tbl(j) := l_UF_details_rec;
              j := j+1;
            END LOOP;
            CLOSE ahl_uf_unit_details_date_csr;
         END IF; --p_onward_date
      END LOOP;
      CLOSE ahl_uf_uom_unit_csr;
     END IF; -- p_unit_item_forecast
     */
  END IF; -- l_unit_config header_id.

  --Or resolve inventory item id into l_pc_node_id
  IF (l_inventory_item_id IS NOT NULL) THEN
     OPEN ahl_pc_id_from_assoc_csr(l_inventory_item_id,
				 AHL_UMP_UF_PVT.G_PC_ITEM_ASSOCIATION,
				 AHL_UMP_UF_PVT.G_PC_PRIMARY_FLAG,
				 AHL_UMP_UF_PVT.G_COMPLETE_STATUS);
     FETCH ahl_pc_id_from_assoc_csr INTO l_pc_node_id;
     IF (ahl_pc_id_from_assoc_csr%NOTFOUND) THEN
          l_pc_node_id := NULL;
     -- FND_MESSAGE.Set_Name('AHL','AHL_UMP_UTIL_NO_PRIM_PC');
     --   FND_MESSAGE.Set_Token('UID',l_inventory_item_id);
     --   FND_MSG_PUB.ADD;
     END IF;
     CLOSE ahl_pc_id_from_assoc_csr;

     -- Added to fix bug# 6749351
     IF (p_add_unit_item_forecast = 'Y') THEN
      OPEN ahl_uf_uom_item_csr(l_inventory_item_id);
      LOOP
         FETCH ahl_uf_uom_item_csr INTO l_uom_code;
         EXIT WHEN ahl_uf_uom_item_csr%NOTFOUND;
         IF(p_onward_end_date IS NULL) THEN
            OPEN ahl_uf_item_details_csr(l_inventory_item_id, l_uom_code);
            LOOP
              FETCH ahl_uf_item_details_csr INTO l_temp_details_rec;
              EXIT WHEN ahl_uf_item_details_csr%NOTFOUND;

              l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
              l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
              l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
              l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
              l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
              l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
              l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
              l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
              l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
              l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
              l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
              l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
              l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
              l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
              l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
              l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
              l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
              l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
              l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
              l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
              l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
              l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
              l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
              l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
              l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
              l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
              l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
              l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;
              l_UF_details_tbl(j) := l_UF_details_rec;
              j := j+1;
            END LOOP;
            CLOSE ahl_uf_item_details_csr;
        ELSE
            OPEN ahl_uf_item_details_date_csr(l_inventory_item_id, l_uom_code,p_onward_end_date);
            LOOP
              FETCH ahl_uf_item_details_date_csr INTO l_temp_details_rec;
              EXIT WHEN ahl_uf_item_details_date_csr%NOTFOUND;

              l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
              l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
              l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
              l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
              l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
              l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
              l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
              l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
              l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
              l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
              l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
              l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
              l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
              l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
              l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
              l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
              l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
              l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
              l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
              l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
              l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
              l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
              l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
              l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
              l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
              l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
              l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
              l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;

              l_UF_details_tbl(j) := l_UF_details_rec;
              j := j+1;
            END LOOP;
            CLOSE ahl_uf_item_details_date_csr;
         END IF; --p_onward_date
      END LOOP;
      CLOSE ahl_uf_uom_item_csr;
     END IF; -- p_unit_item_forecast
  END IF; -- l_inventory_item_id

  --Return if the l_pc_node_id is NULL
  IF (l_pc_node_id IS NULL) THEN
    x_UF_details_tbl := l_UF_details_tbl;
    RETURN;
  END IF;

 --Part 2. With l_pc_node_id, build forecast data.
 --Now traverse up the pc tree.
 OPEN ahl_trav_pc_nodes_csr(l_pc_node_id);
 LOOP
   FETCH ahl_trav_pc_nodes_csr INTO l_pc_id;
   EXIT WHEN ahl_trav_pc_nodes_csr%NOTFOUND;
   --Now fetch all unique UOM_code for given pc
   OPEN ahl_uf_uom_nodes_csr(l_pc_id);
   LOOP
     FETCH ahl_uf_uom_nodes_csr INTO l_uom_code;
     EXIT WHEN ahl_uf_uom_nodes_csr%NOTFOUND;

     l_duplicate := 'N';
     IF (l_UF_details_tbl.COUNT > 0) THEN
       FOR i IN l_UF_details_tbl.FIRST..l_UF_details_tbl.LAST LOOP
         IF (l_UF_details_tbl(i).uom_code = l_uom_code) THEN
             l_duplicate := 'Y';
	    EXIT;
         END IF;
       END LOOP;
     END IF;

     -- If no duplicates are found for given uom, add to table all dates
     IF (l_duplicate = 'N') THEN
        IF(p_onward_end_date IS NULL) THEN
            OPEN ahl_uf_details_csr(l_pc_id, l_uom_code);
            LOOP
            FETCH ahl_uf_details_csr INTO l_temp_details_rec;
 	        EXIT WHEN ahl_uf_details_csr%NOTFOUND;

            l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
 	        l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
            l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
            l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
            l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
            l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
            l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
            l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
            l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
            l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
            l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
            l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
            l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
            l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
            l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
            l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
            l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
            l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
            l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
            l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
            l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
            l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
            l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
            l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
            l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
            l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
            l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
            l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;
            l_UF_details_tbl(j) := l_UF_details_rec;
            j := j+1;
            END LOOP;
            CLOSE ahl_uf_details_csr;
        ELSE
            OPEN ahl_uf_details_date_csr(l_pc_id, l_uom_code, p_onward_end_date);
            LOOP
            FETCH ahl_uf_details_date_csr INTO l_temp_details_rec;
 	        EXIT WHEN ahl_uf_details_date_csr%NOTFOUND;

            l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
 	        l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
            l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
            l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
            l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
            l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
            l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
            l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
            l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
            l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
            l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
            l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
            l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
            l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
            l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
            l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
            l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
            l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
            l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
            l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
            l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
            l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
            l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
            l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
            l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
            l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
            l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
            l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;
            l_UF_details_tbl(j) := l_UF_details_rec;
            j := j+1;
            END LOOP;
            CLOSE ahl_uf_details_date_csr;
        END IF;
     END IF;

   END LOOP;
   CLOSE ahl_uf_uom_nodes_csr;


 END LOOP;
 CLOSE ahl_trav_pc_nodes_csr;

 x_UF_details_tbl := l_UF_details_tbl;

END get_uf_from_pc;

PROCEDURE get_uf_from_part (

    p_init_msg_list          IN           VARCHAR2  := FND_API.G_FALSE,
    p_csi_item_instance_id   IN           NUMBER,
    p_onward_end_date        IN           DATE      := NULL,
	x_UF_details_tbl       OUT NOCOPY   AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status          OUT NOCOPY   VARCHAR2)
    IS

--
CURSOR ahl_uf_details_csr (p_csi_item_instance_id  IN   NUMBER) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b,csi_item_instances c
    WHERE a.uf_header_id = b.uf_header_id
     AND  b.inventory_item_id = c.inventory_item_id
     AND  c.instance_id = p_csi_item_instance_id;

CURSOR ahl_uf_details_date_csr (p_csi_item_instance_id  IN   NUMBER, p_onward_end_date IN DATE) IS
   SELECT  a.UF_DETAIL_ID,
 	   a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE   ,
           a.LAST_UPDATED_BY    ,
           a.CREATION_DATE      ,
           a.CREATED_BY         ,
           a.LAST_UPDATE_LOGIN  ,
           a.UF_HEADER_ID       ,
           a.UOM_CODE           ,
           a.START_DATE         ,
           a.END_DATE           ,
           a.USAGE_PER_DAY      ,
           a.ATTRIBUTE_CATEGORY ,
           a.ATTRIBUTE1  ,
           a.ATTRIBUTE2  ,
           a.ATTRIBUTE3  ,
           a.ATTRIBUTE4  ,
           a.ATTRIBUTE5  ,
           a.ATTRIBUTE6  ,
           a.ATTRIBUTE7  ,
           a.ATTRIBUTE8  ,
           a.ATTRIBUTE9  ,
           a.ATTRIBUTE10 ,
           a.ATTRIBUTE11 ,
           a.ATTRIBUTE12 ,
           a.ATTRIBUTE13 ,
           a.ATTRIBUTE14 ,
           a.ATTRIBUTE15
    FROM    ahl_uf_details a, ahl_uf_headers b,csi_item_instances c
    WHERE (a.end_date IS NULL OR TRUNC(a.end_date) >= TRUNC(p_onward_end_date))
     AND a.uf_header_id = b.uf_header_id
     AND  b.inventory_item_id = c.inventory_item_id
     AND  c.instance_id = p_csi_item_instance_id;


    l_UF_details_tbl     	AHL_UMP_UF_PVT.uf_details_tbl_type;
    l_UF_details_rec 		AHL_UMP_UF_PVT.uf_details_rec_type;
    l_temp_details_rec     	ahl_uf_details_csr%ROWTYPE;
    j NUMBER;


BEGIN

    IF FND_API.To_Boolean( p_init_msg_list)
    THEN
    FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    j := 0;
    IF(p_onward_end_date IS NULL) THEN
       OPEN ahl_uf_details_csr(p_csi_item_instance_id);
       LOOP
       FETCH ahl_uf_details_csr INTO l_temp_details_rec;
 	   EXIT WHEN ahl_uf_details_csr%NOTFOUND;

       l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
 	   l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
       l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
       l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
       l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
       l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
       l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
       l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
       l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
       l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
       l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
       l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
       l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
       l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
       l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
       l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
       l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
       l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
       l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
       l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
       l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
       l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
       l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
       l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
       l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
       l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
       l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
       l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;
       l_UF_details_tbl(j) := l_UF_details_rec;
       j := j+1;
       END LOOP;
       CLOSE ahl_uf_details_csr;
    ELSE
       OPEN ahl_uf_details_date_csr(p_csi_item_instance_id, p_onward_end_date);
       LOOP
       FETCH ahl_uf_details_date_csr INTO l_temp_details_rec;
 	   EXIT WHEN ahl_uf_details_date_csr%NOTFOUND;

       l_UF_details_rec.UF_DETAIL_ID  := l_temp_details_rec.UF_DETAIL_ID;
       l_UF_details_rec.OBJECT_VERSION_NUMBER := l_temp_details_rec.OBJECT_VERSION_NUMBER ;
       l_UF_details_rec.LAST_UPDATE_DATE   := l_temp_details_rec.LAST_UPDATE_DATE ;
       l_UF_details_rec.LAST_UPDATED_BY    := l_temp_details_rec.LAST_UPDATED_BY ;
       l_UF_details_rec.CREATION_DATE      := l_temp_details_rec.CREATION_DATE ;
       l_UF_details_rec.CREATED_BY         := l_temp_details_rec.CREATED_BY ;
       l_UF_details_rec.LAST_UPDATE_LOGIN  := l_temp_details_rec.LAST_UPDATE_LOGIN ;
       l_UF_details_rec.UF_HEADER_ID       := l_temp_details_rec.UF_HEADER_ID ;
       l_UF_details_rec.UOM_CODE           := l_temp_details_rec.UOM_CODE ;
       l_UF_details_rec.START_DATE         := l_temp_details_rec.START_DATE ;
       l_UF_details_rec.END_DATE           := l_temp_details_rec.END_DATE ;
       l_UF_details_rec.USAGE_PER_DAY      := l_temp_details_rec.USAGE_PER_DAY ;
       l_UF_details_rec.ATTRIBUTE_CATEGORY := l_temp_details_rec.ATTRIBUTE_CATEGORY ;
       l_UF_details_rec.ATTRIBUTE1  := l_temp_details_rec.ATTRIBUTE1 ;
       l_UF_details_rec.ATTRIBUTE2  := l_temp_details_rec.ATTRIBUTE2 ;
       l_UF_details_rec.ATTRIBUTE3  := l_temp_details_rec.ATTRIBUTE3 ;
       l_UF_details_rec.ATTRIBUTE4  := l_temp_details_rec.ATTRIBUTE4 ;
       l_UF_details_rec.ATTRIBUTE5  := l_temp_details_rec.ATTRIBUTE5 ;
       l_UF_details_rec.ATTRIBUTE6  := l_temp_details_rec.ATTRIBUTE6 ;
       l_UF_details_rec.ATTRIBUTE7  := l_temp_details_rec.ATTRIBUTE7 ;
       l_UF_details_rec.ATTRIBUTE8  := l_temp_details_rec.ATTRIBUTE8 ;
       l_UF_details_rec.ATTRIBUTE9  := l_temp_details_rec.ATTRIBUTE9 ;
       l_UF_details_rec.ATTRIBUTE10 := l_temp_details_rec.ATTRIBUTE10 ;
       l_UF_details_rec.ATTRIBUTE11 := l_temp_details_rec.ATTRIBUTE11 ;
       l_UF_details_rec.ATTRIBUTE12 := l_temp_details_rec.ATTRIBUTE12 ;
       l_UF_details_rec.ATTRIBUTE13 := l_temp_details_rec.ATTRIBUTE13 ;
       l_UF_details_rec.ATTRIBUTE14 := l_temp_details_rec.ATTRIBUTE14 ;
       l_UF_details_rec.ATTRIBUTE15 := l_temp_details_rec.ATTRIBUTE15 ;
       l_UF_details_tbl(j) := l_UF_details_rec;
       j := j+1;
       END LOOP;
       CLOSE ahl_uf_details_date_csr;
    END IF;

    x_UF_details_tbl := l_UF_details_tbl;


END get_uf_from_part;
-----------------------------------
END AHL_UMP_UF_PVT;

/
