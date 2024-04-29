--------------------------------------------------------
--  DDL for Package Body AHL_UC_UTILIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_UTILIZATION_PVT" AS
/* $Header: AHLVUCUB.pls 120.4.12010000.5 2010/01/19 23:01:08 jaramana ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'AHL_UC_UTILIZATION_PVT';

G_LOG_PREFIX CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_UC_UTILIZATION_PVT';

-- Added by jaramana on 03-DEC-2008 to improve performance by localising FND_LOG package variables.
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

----------------------------------------------
-- Define local Procedures for Utilization  --
----------------------------------------------
-- Convert Value to ID.
PROCEDURE convert_value_id(p_utilization_rec IN OUT NOCOPY AHL_UC_UTILIZATION_PVT.utilization_rec_type);

-- Validate utilization record and get the two flag variables
PROCEDURE validate_utilization_rec(p_utilization_rec IN OUT NOCOPY AHL_UC_UTILIZATION_PVT.utilization_rec_type,
                                   x_found           OUT NOCOPY VARCHAR2,
                                   x_based_on        OUT NOCOPY VARCHAR2);

-- Update counter reading only for a given counter_id (p_cascade_flag is not applicable)
-- It is called by update_reading_ins and update_reading_all
PROCEDURE update_reading_id(p_utilization_rec IN utilization_rec_type);

-- Update counter readings for a given pair of counter_name and instance. It also update counter
-- readings for all the descendants of the start instance if p_cascade_flag is
-- set to Yes. The given start instance must have the p_counter_name associated. It is
-- called by update_reading_cn
PROCEDURE update_reading_ins(p_utilization_rec IN utilization_rec_type);

-- Update counter readings for a given given pair of counter_name and instance. It also update counter
-- readings for all the descendants of the start instance if p_cascade_flag is
-- set to Yes. The given start instance might not have the p_counter_name associated. It is
-- called by update_instance_all
PROCEDURE update_reading_cn(p_utilization_rec IN utilization_rec_type);

-- Update counter reading based on various inputs
PROCEDURE update_reading_all(p_utilization_rec IN utilization_rec_type,
                             p_based_on        IN VARCHAR2);

-- To get Counter ratio based on Master Configuration position.
FUNCTION get_counter_ratio(p_start_instance_id IN NUMBER,
                           p_desc_instance_id  IN NUMBER,
                           p_uom_code          IN VARCHAR2,
                           p_rule_code         IN VARCHAR2)
RETURN NUMBER;

-----------------------------------------
-- Define Procedure for Utilization    --
-----------------------------------------
-- Start of Comments --
--  Procedure name: update_utilization
--  Type:           Private
--  Function:       Updates the utilization based on the counter rules defined in the master configuration
--                  given the details of an item/counter id/counter name/uom_code.
--                  Casacades the updates down to all the children if the p_cascade_flag is set to 'Y'.
--  Pre-reqs:
--  Parameters:
--  Standard IN Parameters:
--    p_api_version                   IN      NUMBER                Required
--    p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--    p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--    p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters:
--    x_return_status                 OUT     VARCHAR2               Required
--    x_msg_count                     OUT     NUMBER                 Required
--    x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Utilization Parameters:
--
--    p_utilization_tbl                IN      Required.
--      For each record, at any given time only one of the following combinations is valid to identify the
--      item instance to be updated:
--        1.  Organization id and Inventory_item_id    AND  Serial Number.
--            This information will identify the part number and serial number of a configuration.
--        2.  Counter ID -- if this is passed a specific counter ONLY will be updated irrespective of the value
--            of p_cascade_flag.
--        3.  CSI_ITEM_INSTANCE_ID -- if this is passed, then this item instance and items down the hierarchy (depends on
--            the value p_cascade_flag) will be updated.
--      At any given time only one of the following parameters is valid to identify the type of item counters to be
--      updated:
--        1.  COUNTER_ID
--        2.  COUNTER_NAME
--        3.  UOM_CODE
--
--      reading_value                 IN   Required
--        This will be the value of the counter reading.
--      cascade_flag                  IN   Required
--        Can take values Y and N. Y indicates that the counter updates will cascade down the hierarchy
--        beginning at the item number passed. If its value is N then only the item counter will be updated.
--
-- End of Comments --

PROCEDURE update_utilization(p_api_version      IN NUMBER,
                             p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                             p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                             p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                             p_utilization_tbl  IN AHL_UC_UTILIZATION_PVT.utilization_tbl_type,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'update_utilization';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_utilization_rec AHL_UC_UTILIZATION_PVT.utilization_rec_type;
  l_utilization_tbl AHL_UC_UTILIZATION_PVT.utilization_tbl_type DEFAULT p_utilization_tbl;
  l_found           VARCHAR2(50) := NULL;
  l_based_on        VARCHAR2(50) := NULL;

  L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_Utilization';

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                   'Entering Procedure. p_utilization_tbl.count = ' || p_utilization_tbl.count);
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard start of API savepoint
  SAVEPOINT update_utilization;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  FOR i IN l_utilization_tbl.FIRST..l_utilization_tbl.LAST LOOP
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'Processing record ' || i);
    END IF;
    l_utilization_rec := l_utilization_tbl(i);
    -- Convert value's to ID's.
    convert_value_id(l_utilization_rec);
    -- Validate input parameters.
    validate_utilization_rec(l_utilization_rec, l_found, l_based_on);
    l_utilization_tbl(i) := l_utilization_rec;
  END LOOP;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'After successful completion of Value To Id conversion and Validation of all records in table.');
  END IF;
  -- Perform updates.
  FOR i IN l_utilization_tbl.FIRST..l_utilization_tbl.LAST LOOP
    l_utilization_rec := l_utilization_tbl(i);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'About to call update_reading_all for record ' || i ||
                     ', l_based_on = ' || l_based_on);
    END IF;
    update_reading_all(l_utilization_rec, l_based_on);
  END LOOP;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'After successful completion of update_reading_all calls for all records in table.');
  END IF;

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
  FND_MSG_PUB.count_and_get(
    p_count => x_msg_count,
    p_data  => x_msg_data,
    p_encoded => fnd_api.g_false);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK to update_utilization;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK to update_utilization;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK to update_utilization;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                              p_procedure_name => 'update_utilization',
                              p_error_text     => SQLERRM);
    END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END update_utilization;

---------------------------------------------------------------------------------

PROCEDURE convert_value_id(p_utilization_rec IN OUT NOCOPY
                          AHL_UC_UTILIZATION_PVT.utilization_rec_type)
IS
  -- For organization id.
  CURSOR mtl_parameters_csr(c_org_code VARCHAR2) IS
    SELECT organization_id
      FROM mtl_parameters
     WHERE organization_code = c_org_code;

  -- For inventory_item_id.
  CURSOR mtl_system_items_csr(c_item_number VARCHAR2,
                              c_inv_organization_id NUMBER) IS
    SELECT inventory_item_id
      FROM ahl_mtl_items_ou_v
     WHERE concatenated_segments = c_item_number
       AND inventory_org_id = c_inv_organization_id;

  -- For instance_id.
  CURSOR csi_item_instance_csr(c_instance_number VARCHAR2) IS
    SELECT instance_id
      FROM csi_item_instances
     WHERE instance_number = c_instance_number;

  l_return_val      BOOLEAN;
  l_lookup_code     fnd_lookups.lookup_code%TYPE;
  l_organization_id NUMBER;
  l_inventory_id    NUMBER;
  l_instance_id     NUMBER;
  L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Convert_Value_Id';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- For Inventory Organization Code.
  IF ((p_utilization_rec.organization_id IS NULL) OR
      (p_utilization_rec.organization_id = FND_API.G_MISS_NUM)) THEN
    -- if code is present.
    IF ((p_utilization_rec.organization_code IS NOT NULL) AND
        (p_utilization_rec.organization_code <> FND_API.G_MISS_CHAR)) THEN
      OPEN mtl_parameters_csr(p_utilization_rec.organization_code);
      FETCH mtl_parameters_csr INTO l_organization_id;
      IF (mtl_parameters_csr%FOUND) THEN
        p_utilization_rec.organization_id := l_organization_id;
      ELSE
        FND_MESSAGE.set_name('AHL','AHL_UC_ORG_INVALID');
        FND_MESSAGE.set_token('ORG',p_utilization_rec.organization_code);
        FND_MSG_PUB.add;
      END IF;
      CLOSE mtl_parameters_csr;
    END IF;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'p_utilization_rec.organization_id = ' || p_utilization_rec.organization_id);
  END IF;

  -- For Rule_Code_meaning.
  IF ((p_utilization_rec.rule_code IS NULL) OR
      (p_utilization_rec.rule_code = FND_API.G_MISS_CHAR)) THEN
    -- Check if meaning exists.
    IF ((p_utilization_rec.Rule_meaning IS NOT NULL) AND
        (p_utilization_rec.Rule_meaning <> FND_API.G_MISS_CHAR)) THEN
      AHL_UTIL_MC_PKG.convert_to_lookupcode('AHL_COUNTER_RULE_TYPE',
                                            p_utilization_rec.Rule_meaning,
                                            l_lookup_code,
                                            l_return_val);
      IF (l_return_val) THEN
        p_utilization_rec.rule_code := l_lookup_code;
      ELSE
        FND_MESSAGE.set_name('AHL','AHL_UC_RCODE_INVALID');
        FND_MESSAGE.set_token('CODE',p_utilization_rec.Rule_meaning);
        FND_MSG_PUB.add;
      END IF;
    END IF;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'p_utilization_rec.rule_code = ' || p_utilization_rec.rule_code);
  END IF;

  -- For Inventory item.
  IF ((p_utilization_rec.inventory_item_id IS NULL) OR
      (p_utilization_rec.inventory_item_id = FND_API.G_MISS_NUM)) THEN
    -- check if name exists.
    IF ((p_utilization_rec.item_number IS NOT NULL) AND
        (p_utilization_rec.item_number <> FND_API.G_MISS_CHAR)) THEN
      OPEN mtl_system_items_csr(p_utilization_rec.item_number,
                                p_utilization_rec.organization_id);
      FETCH mtl_system_items_csr INTO l_inventory_id;
      IF (mtl_system_items_csr%FOUND) THEN
        p_utilization_rec.inventory_item_id := l_inventory_id;
      ELSE
        FND_MESSAGE.set_name('AHL','AHL_MC_INV_INVALID');
        FND_MESSAGE.set_token('INV_ITEM',p_utilization_rec.item_number);
        FND_MSG_PUB.add;
      END IF;
      CLOSE mtl_system_items_csr;
    END IF;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'p_utilization_rec.inventory_item_id = ' || p_utilization_rec.inventory_item_id);
  END IF;

  -- For Instance.
  IF ((p_utilization_rec.csi_item_instance_id IS NULL) OR
      (p_utilization_rec.csi_item_instance_id = FND_API.G_MISS_NUM)) THEN
    -- check if name exists.
    IF ((p_utilization_rec.csi_item_instance_number IS NOT NULL) AND
        (p_utilization_rec.csi_item_instance_number <> FND_API.G_MISS_CHAR)) THEN
      OPEN csi_item_instance_csr(p_utilization_rec.csi_item_instance_number);
      FETCH csi_item_instance_csr INTO l_instance_id;
      IF (csi_item_instance_csr%FOUND) THEN
        p_utilization_rec.csi_item_instance_id := l_instance_id;
      ELSE
        FND_MESSAGE.set_name('AHL','AHL_UC_INSTANCE_INVALID');
        FND_MESSAGE.set_token('INSTANCE',p_utilization_rec.csi_item_instance_number);
        FND_MSG_PUB.add;
      END IF;
      CLOSE csi_item_instance_csr;
    END IF;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'p_utilization_rec.csi_item_instance_id = ' || p_utilization_rec.csi_item_instance_id);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END convert_value_id;

---------------------------------------------------------------------------------

PROCEDURE validate_utilization_rec(p_utilization_rec IN OUT NOCOPY AHL_UC_UTILIZATION_PVT.utilization_rec_type,
                                   x_found           OUT NOCOPY VARCHAR2,
                                   x_based_on        OUT NOCOPY VARCHAR2)
IS
  -- Get location type code.
  CURSOR csi_item_instances_csr(c_instance_id NUMBER) IS
    SELECT location_type_code
      FROM csi_item_instances
     WHERE instance_id = c_instance_id
       AND TRUNC(sysdate) < TRUNC(NVL(active_end_date, sysdate+1));

   -- Validate Counter ID.
   CURSOR cs_counters_csr (c_counter_id NUMBER) IS
     SELECT cgrp.source_object_id
       FROM cs_counters ctr, cs_counter_groups cgrp
      WHERE cgrp.counter_group_id = ctr.counter_group_id
        AND cgrp.source_object_code = 'CP'
        AND ctr.counter_id = c_counter_id
        AND trunc(sysdate) >= trunc(nvl(ctr.start_date_active,sysdate))
        AND trunc(sysdate) < trunc(nvl(ctr.end_date_active,sysdate+1));

   CURSOR csi_item_serial_csr(c_inventory_item_id NUMBER,
                              c_organization_id   NUMBER,
                              c_serial_number     VARCHAR2) IS
     SELECT instance_id,
            instance_usage_code,
            active_start_date,
            active_end_date
       FROM csi_item_instances csi
      WHERE inventory_item_id = c_inventory_item_id
        AND last_vld_organization_id = c_organization_id
        AND serial_number = c_serial_number;

   CURSOR mtl_units_of_measure_csr(c_uom_code VARCHAR2) IS
     SELECT 'X'
       FROM mtl_units_of_measure_vl
      WHERE uom_code = c_uom_code;

   -- Validate counter name.
   CURSOR cs_counter_name_csr(c_counter_name VARCHAR2) IS
     SELECT 'X'
       FROM cs_counters ctr
      WHERE ctr.name = c_counter_name
        AND trunc(sysdate) >= trunc(nvl(ctr.start_date_active,sysdate))
        AND trunc(sysdate) < trunc(nvl(ctr.end_date_active,sysdate+1));

   CURSOR ahl_unit_config_csr (c_instance_id NUMBER) IS
     SELECT unit_config_header_id
       FROM ahl_unit_config_headers
      WHERE csi_item_instance_id = c_instance_id
        AND trunc(sysdate) >= trunc(nvl(active_start_date,sysdate))
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

   l_csi_item_instance_id       NUMBER;
   l_tmp_instance_id            NUMBER := p_utilization_rec.csi_item_instance_id;
   l_csi_top_node_id            NUMBER;
   l_parent_uc_header_id        NUMBER;
   l_parent_uc_instance_id      NUMBER;
   l_root_uc_header_id          NUMBER;
   l_root_uc_instance_id        NUMBER;
   l_root_uc_status_code        FND_LOOKUP_VALUES_VL.lookup_code%TYPE;
   l_root_active_uc_status_code FND_LOOKUP_VALUES_VL.lookup_code%TYPE;
   l_root_uc_header_ovn         NUMBER;
   l_csi_instance_usage_code    CSI_LOOKUPS.lookup_code%TYPE;
   l_junk                       VARCHAR2(30);
   l_return_val                 BOOLEAN;

   l_config_status              ahl_unit_config_headers.unit_config_status_code%TYPE;
   l_master_config_status       ahl_mc_headers_b.config_status_code%TYPE;
   l_master_config_name         ahl_mc_headers_b.name%TYPE;
   l_master_config_id           NUMBER;

   l_unit_config_name           ahl_unit_config_headers.name%TYPE;
   l_location_type_code         csi_item_instances.location_type_code%TYPE;
   l_active_end_date            DATE;
   l_active_start_date          DATE;

   l_found                      VARCHAR2(50) := NULL;
   l_based_on                   VARCHAR2(50) := NULL;

   L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_Utilization_Rec';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Check if counter_id is valid.
  IF (p_utilization_rec.counter_id IS NOT NULL) AND
     (p_utilization_rec.counter_id <> FND_API.G_MISS_NUM) THEN
    OPEN cs_counters_csr(p_utilization_rec.counter_id);
    FETCH cs_counters_csr INTO l_csi_item_instance_id;
    IF (cs_counters_csr%NOTFOUND) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_CSCTR_INVALID');
      FND_MESSAGE.set_token('CTRID',p_utilization_rec.counter_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Counter ID not found');
    ELSE
      l_based_on :=  l_based_on || ':' || 'COUNTERID';
      l_found := l_found || ':' || 'COUNTER';

      -- Find out the csi item status code.
      OPEN csi_item_instances_csr(l_csi_item_instance_id);
      FETCH csi_item_instances_csr INTO l_location_type_code;
      IF (csi_item_instances_csr%NOTFOUND) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_CSII_INVALID');
        FND_MESSAGE.set_token('CSII',p_utilization_rec.csi_item_instance_id);
        FND_MSG_PUB.add;
        --dbms_output.put_line('CSI Item Instance not found');
      ELSE
        l_tmp_instance_id := l_csi_item_instance_id;
      END IF; -- csi not found.
      CLOSE csi_item_instances_csr;
    END IF;
    CLOSE cs_counters_csr;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated Counter Id.');
  END IF;

  -- Check if Inventory item and serial number are valid and exist in csi_item_instances.
  IF (p_utilization_rec.inventory_item_id IS NOT NULL) AND
     (p_utilization_rec.inventory_item_id <> FND_API.G_MISS_NUM) THEN
    OPEN csi_item_serial_csr(p_utilization_rec.inventory_item_id,
                             p_utilization_rec.organization_id,
                             p_utilization_rec.serial_number);
    FETCH csi_item_serial_csr INTO l_csi_item_instance_id, l_csi_instance_usage_code,
                                   l_active_start_date, l_active_end_date;
    IF (csi_item_serial_csr%NOTFOUND) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_INV_SERIAL_INVALID');
      FND_MESSAGE.set_token('INV_ITEM',p_utilization_rec.inventory_item_id);
      FND_MESSAGE.set_token('SERIAL',p_utilization_rec.serial_number);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Inventory item not found');
    ELSIF (trunc(sysdate)) < trunc(nvl(l_active_end_date, sysdate+1)) THEN
      l_found := l_found || ':' || 'INVENTORY';
      l_tmp_instance_id := l_csi_item_instance_id;
    ELSE
      -- Item expired.
      FND_MESSAGE.set_name('AHL','AHL_UC_INVITEM_INVALID');
      FND_MESSAGE.set_token('INV_ITEM',p_utilization_rec.inventory_item_id);
      FND_MESSAGE.set_token('SERIAL',p_utilization_rec.serial_number);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Inventory item not found');
    END IF;
    CLOSE csi_item_serial_csr;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated inventory_item_id, serial and instance.');
  END IF;

  -- Check if csi_item_instance_id present.
  IF (p_utilization_rec.csi_item_instance_id IS NOT NULL) AND
     (p_utilization_rec.csi_item_instance_id <> FND_API.G_MISS_NUM) THEN
    OPEN csi_item_instances_csr(p_utilization_rec.csi_item_instance_id);
    FETCH csi_item_instances_csr INTO l_location_type_code;
    IF (csi_item_instances_csr%NOTFOUND) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_CSII_INVALID');
      FND_MESSAGE.set_token('CSII',p_utilization_rec.csi_item_instance_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('CSI Item Instance not found');
    ELSIF (l_location_type_code IN ('PO','INVENTORY','PROJECT','IN-TRANSIT')) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_CSII_INVALID');
      FND_MESSAGE.set_token('CSII',p_utilization_rec.csi_item_instance_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('CSI Item Instance location invalid');
    ELSE
      l_found := l_found || ':' || 'INSTANCE';
    END IF;  /* csi item_instance */
    CLOSE csi_item_instances_csr;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated instance location.');
  END IF;

  p_utilization_rec.csi_item_instance_id := l_tmp_instance_id;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Setting p_utilization_rec.csi_item_instance_id to ' || p_utilization_rec.csi_item_instance_id);
  END IF;

  -- Check Error Message stack.
  IF FND_MSG_PUB.count_msg > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Raise error if no or too many parameters.
  IF (l_found IS NULL) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_UPARAM_NULL');
    FND_MSG_PUB.add;
    --dbms_output.put_line('Part number information is null');
    RAISE  FND_API.G_EXC_ERROR;
  ELSIF l_found <> ':INVENTORY' AND
    l_found <> ':INSTANCE'  AND
    l_found <> ':COUNTER'
  THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_UPARAM_INVALID');
    FND_MSG_PUB.add;
    --dbms_output.put_line('Too many parameters for part number.');
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Check if unit config is complete.
  -- First get its parent_uc_header_id
  ahl_util_uc_pkg.get_parent_uc_header(p_utilization_rec.csi_item_instance_id,
                                       l_parent_uc_header_id,
                                       l_parent_uc_instance_id);
  IF l_parent_uc_header_id IS NULL THEN
    --Then check to see whether this instance happens to be a top unit instance
    OPEN ahl_unit_config_csr(p_utilization_rec.csi_item_instance_id);
    FETCH ahl_unit_config_csr INTO l_parent_uc_header_id;
    IF ahl_unit_config_csr%NOTFOUND THEN
      --Means this instance is definately not in a UC
      FND_MESSAGE.set_name('AHL','AHL_UC_INSTANCE_NOT_IN_UC');
      FND_MESSAGE.set_token('INSTANCE', p_utilization_rec.csi_item_instance_id);
      FND_MSG_PUB.add;
    END IF;
    CLOSE ahl_unit_config_csr;
    --dbms_output.put_line('CSI Item Instance not found');
  ELSE
    ahl_util_uc_pkg.get_root_uc_attr(
      p_uc_header_id          => l_parent_uc_header_id,
      x_uc_header_id          => l_root_uc_header_id,
      x_instance_id           => l_root_uc_instance_id,
      x_uc_status_code        => l_root_uc_status_code,
      x_active_uc_status_code => l_root_active_uc_status_code,
      x_uc_header_ovn         => l_root_uc_header_ovn);

    IF (l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE', 'DRAFT')) THEN
       -- 'DRAFT' needs to be removed after testing
       FND_MESSAGE.set_name('AHL','AHL_UC_STATUS_INVALID');
       FND_MESSAGE.set_token('STATUS',l_root_uc_status_code);
       FND_MSG_PUB.add;
       --dbms_output.put_line('UC Status invalid');
    END IF;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated UC of instance');
  END IF;

  -- Check values of cascade_flag.
  IF (p_utilization_rec.cascade_flag IS NOT NULL AND
      p_utilization_rec.cascade_flag NOT IN ('Y','N'))
  THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_CASCADE_INVALID');
    FND_MESSAGE.set_token('FLAG',p_utilization_rec.cascade_flag);
    FND_MSG_PUB.add;
     --dbms_output.put_line('Cascade flag is invalid.');
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.cascade_flag: ' || p_utilization_rec.cascade_flag);
  END IF;

  -- Check values of delta_flag.
  IF (p_utilization_rec.delta_flag IS NOT NULL AND
      p_utilization_rec.delta_flag NOT IN ('Y','N'))
  THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_DELTA_FLAG_INVALID');
    FND_MESSAGE.set_token('FLAG',p_utilization_rec.delta_flag);
    FND_MSG_PUB.add;
     --dbms_output.put_line('Delta flag is invalid.');
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.delta_flag: ' || p_utilization_rec.delta_flag);
  END IF;

  -- Check Error Message stack.
  IF FND_MSG_PUB.count_msg > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Check UOM_CODE.
  IF (p_utilization_rec.uom_code IS NOT NULL)  AND
     (p_utilization_rec.uom_code <> FND_API.G_MISS_CHAR)  THEN
    OPEN mtl_units_of_measure_csr(p_utilization_rec.uom_code);
    FETCH mtl_units_of_measure_csr INTO l_junk;
    IF (mtl_units_of_measure_csr%NOTFOUND) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_UZ_UOM_INVALID');
      FND_MESSAGE.set_token('UOM_CODE',p_utilization_rec.uom_code);
      FND_MSG_PUB.add;
      --dbms_output.put_line('UOM CODE not found');
    ELSE
      l_based_on :=  l_based_on || ':' || 'UOM';
    END IF;
    CLOSE mtl_units_of_measure_csr;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.uom_code: ' || p_utilization_rec.uom_code);
  END IF;

  -- Check Counter Name.
  IF (p_utilization_rec.counter_name IS NOT NULL) AND
     (p_utilization_rec.counter_name <> FND_API.G_MISS_CHAR)
  THEN
    OPEN cs_counter_name_csr(p_utilization_rec.counter_name);
    FETCH cs_counter_name_csr INTO l_junk;
    IF (cs_counter_name_csr%NOTFOUND) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_CTRNAME_INVALID');
      FND_MESSAGE.set_token('CTR_NAME',p_utilization_rec.counter_name);
      FND_MSG_PUB.add;
        --dbms_output.put_line('Counter Name not found');
    ELSE
      l_based_on :=  l_based_on || ':' || 'COUNTER';
    END IF;
    CLOSE cs_counter_name_csr;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.counter_name: ' || p_utilization_rec.counter_name);
  END IF;

  -- Validate Rule Code.
  IF (p_utilization_rec.rule_code IS NOT NULL AND
      NOT(AHL_UTIL_MC_PKG.validate_lookup_code('AHL_COUNTER_RULE_TYPE', p_utilization_rec.rule_code))) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_RCODE_INVALID');
    FND_MESSAGE.set_token('CODE',p_utilization_rec.rule_code);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Invalid Rule code');
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.rule_code: ' || p_utilization_rec.rule_code);
  END IF;

  -- Default reading date
  IF (p_utilization_rec.reading_date IS NULL OR
      p_utilization_rec.reading_date = FND_API.G_MISS_DATE) THEN
    p_utilization_rec.reading_date := SYSDATE;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.reading_date: ' || p_utilization_rec.reading_date);
  END IF;

  --Validate Reading.
  --If reading_value is delta reading, then this value can be positive (ascending counter)
  --or negative (descending counter). And If reading value is net reading, then we require
  --the specific counter name provided or counter names with the speicific UOMs provided exist
  --for the start instance itself.
  IF (p_utilization_rec.reading_value IS NULL OR p_utilization_rec.reading_value = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_READING_INVALID');
    FND_MSG_PUB.add;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Validated p_utilization_rec.reading_value: ' || p_utilization_rec.reading_value);
  END IF;

  -- Check Error Message stack.
  IF FND_MSG_PUB.count_msg > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Raise error if no or too many parameters.
  IF (l_based_on IS NULL) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_UBASED_ON_NULL');
    FND_MSG_PUB.add;
    --dbms_output.put_line('Part number information is null');
    RAISE  FND_API.G_EXC_ERROR;
  ELSIF (l_based_on <> ':UOM' AND
         l_based_on <> ':COUNTER' AND
         l_based_on <> ':COUNTERID' ) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_UBASED_ON_INVALID');
    FND_MSG_PUB.add;
    --dbms_output.put_line('Input parameters contain both UOM Code and Counter Name');
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  x_found := l_found;
  x_based_on := l_based_on;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
    'Exiting Procedure. x_found = ' || x_found || ', x_based_on = ' || x_based_on);
  END IF;

END validate_utilization_rec;

---------------------------------------------------------------------------------

PROCEDURE update_reading_id(p_utilization_rec IN utilization_rec_type) IS
  -- Get current counter reading values based on the counter_id
  CURSOR get_current_value_id(c_counter_id NUMBER) IS
 -- Changed by jaramana on 03-DEC-2008 for bug 7426643 (FP of 7263702)
 -- To take advantage of the fix made in Counters bug 7561677 (FP of 7374316)
 -- and also to ignore disabled counter readings
     -- SATHAPLI::Bug 8765956, 07-Aug-2009, re-introducing NVL usage.
     -- NOTE: NVL() should be put for the entire inner SELECT, as it should take effect even if this inner SELECT doesn't
     -- fetch any rows.
     SELECT NVL((select ccr.net_reading
               from csi_counter_readings ccr
              where ccr.counter_value_id = c.ctr_val_max_seq_no), 0) counter_reading,
            DEFAULTED_GROUP_ID counter_group_id
       FROM CSI_COUNTERS_B C
      WHERE counter_id = c_counter_id
      -- Changes by jaramana on 28-DEC-2009 for bug 9229943
      -- Lock the CSI_COUNTERS_B row to prevent incorrect updates
     FOR UPDATE OF c.ctr_val_max_seq_no;

  -- Begin changes by jaramana on Feb 20, 2008 for Bug 6782765
  CURSOR is_counter_change_type_csr(c_counter_id NUMBER) IS
    select 'Y' from CSI_COUNTERS_B
    where counter_id = c_counter_id
      and reading_type = 2;

  l_change_type_flag  VARCHAR2(1) := 'N';
  -- End changes by jaramana on Feb 20, 2008 for Bug 6782765

  l_counter_grp_id  NUMBER;
  l_reading_value   NUMBER;
  l_start_current_value NUMBER;

  l_ctr_grp_log_rec CS_CTR_CAPTURE_READING_PUB.ctr_grp_log_rec_type;
  l_ctr_rdg_tbl     CS_CTR_CAPTURE_READING_PUB.ctr_rdg_tbl_type;
  l_prop_rdg_tbl    CS_CTR_CAPTURE_READING_PUB.prop_rdg_tbl_type;
  l_return_status   VARCHAR2(3);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_msg_index_out   NUMBER;
  L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_Reading_Id';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Begin changes by jaramana on Feb 20, 2008 for Bug 6782765
  OPEN is_counter_change_type_csr(p_utilization_rec.counter_id);
  FETCH is_counter_change_type_csr INTO l_change_type_flag;
  IF (is_counter_change_type_csr%FOUND) THEN
    l_change_type_flag := 'Y';
  ELSE
    l_change_type_flag := 'N';
  END IF;
  CLOSE is_counter_change_type_csr;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Counter is change type: ' || l_change_type_flag);
  END IF;
  -- End changes by jaramana on Feb 20, 2008 for Bug 6782765

  OPEN get_current_value_id(p_utilization_rec.counter_id);
  FETCH get_current_value_id INTO l_start_current_value, l_counter_grp_id;
  IF get_current_value_id%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_INST_NO_CTR_FOUND');
    FND_MSG_PUB.add;
    CLOSE get_current_value_id;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE get_current_value_id;
  END IF;
  IF p_utilization_rec.delta_flag = 'Y' THEN
    -- Begin Changes by jaramana on Feb 20, 2008 for Bug 6782765
    IF (l_change_type_flag = 'Y') THEN
      -- For Change type counters, always pass the delta value
      l_reading_value := p_utilization_rec.reading_value;
    ELSE
      -- For other counters, always pass the total value
      l_reading_value := l_start_current_value+p_utilization_rec.reading_value;
    END IF;
  ELSE
    -- Not Delta
    IF (l_change_type_flag = 'Y') THEN
      -- For Change type counters, delta_flag should always be Y
      FND_MESSAGE.set_name('AHL', 'AHL_UC_DELTA_FLAG_INVALID');
      FND_MESSAGE.set_token('FLAG', p_utilization_rec.delta_flag);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End changes by jaramana on Feb 20, 2008 for Bug 6782765
    l_reading_value := p_utilization_rec.reading_value;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'l_start_current_value = ' || l_start_current_value ||
                   ', p_utilization_rec.delta_flag = ' || p_utilization_rec.delta_flag ||
                   ', p_utilization_rec.reading_value = ' || p_utilization_rec.reading_value ||
                   ', Setting l_reading_value to ' || l_reading_value);
  END IF;

  -- Update reading for the counter.
  l_ctr_grp_log_rec.counter_group_id := l_counter_grp_id;
  l_ctr_grp_log_rec.value_timestamp := SYSDATE;
  l_ctr_grp_log_rec.source_transaction_id := p_utilization_rec.csi_item_instance_id;
  l_ctr_grp_log_rec.source_transaction_code := 'CP';

  l_ctr_rdg_tbl(1).counter_id := p_utilization_rec.counter_id;
  l_ctr_rdg_tbl(1).value_timestamp := p_utilization_rec.reading_date;
  l_ctr_rdg_tbl(1).counter_reading := l_reading_value;
  l_ctr_rdg_tbl(1).valid_flag := 'Y';
  -- Changed from 'Y' to 'N' by jaramana on July 10, 2007 for bug 6127957
  l_ctr_rdg_tbl(1).override_valid_flag := 'N';
  --Call CS Counter Update API to update the counter_reading of the start instance
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'About to call CS_CTR_CAPTURE_READING_PUB.capture_counter_reading');
  END IF;
  CS_CTR_CAPTURE_READING_PUB.capture_counter_reading(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => FND_API.G_FALSE,
                   p_commit             => FND_API.G_FALSE,
                   p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                   p_ctr_grp_log_rec    => l_ctr_grp_log_rec,
                   p_ctr_rdg_tbl        => l_ctr_rdg_tbl,
                   p_prop_rdg_tbl       => l_prop_rdg_tbl,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data );
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Returned from call to CS_CTR_CAPTURE_READING_PUB.capture_counter_reading. l_return_status = ' || l_return_status);
  END IF;
  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
    'Exiting Procedure.');
  END IF;
END update_reading_id;

---------------------------------------------------------------------------------

--Update the counter reading value of the start instance and all of its components (if
--cascade_flag = 'Y'). This procedure assumes the given counter name exists for the start
--instance
PROCEDURE update_reading_ins(p_utilization_rec IN utilization_rec_type) IS
  CURSOR csi_relationships_csr(c_csi_item_instance_id NUMBER) IS
    SELECT subject_id csi_item_instance_id, position_reference
      FROM csi_ii_relationships
START WITH object_id = c_csi_item_instance_id
       AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(active_end_date,sysdate+1)) > trunc(sysdate)
       AND relationship_type_code = 'COMPONENT-OF'
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(active_end_date,sysdate+1)) > trunc(sysdate)
       AND relationship_type_code = 'COMPONENT-OF';

   -- Get current counter reading values based on the counter_id
   -- Cursor get_current_value_id commented out by jaramana on on June 13, 2007
   --  while fixing bug 6123549 since this cursor is not used in this procedure at all.
   /***
   CURSOR get_current_value_id(c_counter_id NUMBER) IS
     SELECT nvl(counter_reading,0) counter_reading,
            counter_group_id,
            uom_code
       FROM csi_cp_counters_v
      WHERE counter_id = c_counter_id;
   ***/
   -- Get current counter reading values based on the counter_name
   -- Cursor changed by jaramana on 03-DEC-2008 for bug 7426643 (FP of 7263702)
   -- Removed the use of csi_cp_counters_v and uptook
   -- changes made via Counters bug 7561677 (FP of 7374316)
   CURSOR get_current_value_name(c_instance_id NUMBER,
                                 c_counter_name VARCHAR2) IS
     -- SATHAPLI::Bug 8765956, 07-Aug-2009, re-introducing NVL usage.
     -- NOTE: NVL() should be put for the entire inner SELECT, as it should take effect even if this inner SELECT doesn't
     -- fetch any rows.
     SELECT C.DEFAULTED_GROUP_ID counter_group_id,
            NVL((select ccr.net_reading
               from csi_counter_readings ccr
              where ccr.counter_value_id = c.ctr_val_max_seq_no), 0) counter_reading,
            C.COUNTER_ID counter_id,
            C.START_DATE_ACTIVE start_date_active,
            C.END_DATE_ACTIVE end_date_active,
            C.UOM_CODE uom_code
       FROM CSI_COUNTERS_VL C, CSI_COUNTER_ASSOCIATIONS CCA
      WHERE C.COUNTER_ID = CCA.COUNTER_ID(+)
        AND CCA.SOURCE_OBJECT_CODE = 'CP'
        AND CCA.SOURCE_OBJECT_ID = c_instance_id
        AND C.COUNTER_TEMPLATE_NAME = c_counter_name
        AND trunc(nvl(C.start_date_active, sysdate)) <= trunc(sysdate)
        AND trunc(nvl(C.end_date_active, sysdate+1)) > trunc(sysdate)
      -- Changes by jaramana on 28-DEC-2009 for bug 9229943
      -- Lock the CSI_COUNTERS_VL row to prevent incorrect updates
      FOR UPDATE OF c.ctr_val_max_seq_no;

   l_get_current_value_name get_current_value_name%ROWTYPE;

   -- Begin changes by jaramana on Feb 20, 2008 for Bug 6782765
   CURSOR is_counter_change_type_csr(c_counter_id NUMBER) IS
     select 'Y' from CSI_COUNTERS_B
     where counter_id = c_counter_id
       and reading_type = 2;

   l_change_type_flag  VARCHAR2(1) := 'N';
   -- End changes by jaramana on Feb 20, 2008 for Bug 6782765

   l_utilization_rec utilization_rec_type;
   l_ratio           NUMBER;
   l_reading_value   NUMBER;
   l_start_current_value NUMBER;
   l_uom_code        cs_counters.uom_code%TYPE;

   l_ctr_grp_log_rec CS_CTR_CAPTURE_READING_PUB.ctr_grp_log_rec_type;
   l_ctr_rdg_tbl     CS_CTR_CAPTURE_READING_PUB.ctr_rdg_tbl_type;
   l_prop_rdg_tbl    CS_CTR_CAPTURE_READING_PUB.prop_rdg_tbl_type;
   l_return_status   VARCHAR2(3);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);
   l_msg_index_out   NUMBER;
   L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_Reading_Ins';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  l_utilization_rec := p_utilization_rec;
  --First get the current counter reading value for the start instance
  --This procedure assumes that counter exists for the instance
  OPEN get_current_value_name(l_utilization_rec.csi_item_instance_id,
                              l_utilization_rec.counter_name);
  FETCH get_current_value_name INTO l_get_current_value_name;
  IF get_current_value_name%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_CTR_INST_INVALID');
    FND_MESSAGE.set_token('COUNTER', l_utilization_rec.counter_name);
    FND_MESSAGE.set_token('INSTANCE', l_utilization_rec.csi_item_instance_id);
    FND_MSG_PUB.add;
    CLOSE get_current_value_name;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE get_current_value_name;
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'l_get_current_value_name.counter_id = ' || l_get_current_value_name.counter_id ||
                   ', l_get_current_value_name.counter_reading = ' || l_get_current_value_name.counter_reading ||
                   ', l_get_current_value_name.uom_code = ' || l_get_current_value_name.uom_code ||
                   ', l_get_current_value_name.start_date_active = ' || l_get_current_value_name.start_date_active ||
                   ', l_get_current_value_name.end_date_active = ' || l_get_current_value_name.end_date_active);
  END IF;

  l_utilization_rec.counter_id := l_get_current_value_name.counter_id;

  -- Begin changes by jaramana on Feb 20, 2008 for Bug 6782765
  OPEN is_counter_change_type_csr(l_utilization_rec.counter_id);
  FETCH is_counter_change_type_csr INTO l_change_type_flag;
  IF (is_counter_change_type_csr%FOUND) THEN
    l_change_type_flag := 'Y';
  ELSE
    l_change_type_flag := 'N';
  END IF;
  CLOSE is_counter_change_type_csr;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Counter is change type: ' || l_change_type_flag);
  END IF;
  -- End changes by jaramana on Feb 20, 2008 for Bug 6782765

  l_start_current_value := l_get_current_value_name.counter_reading;
  l_uom_code := l_get_current_value_name.uom_code;
  update_reading_id(l_utilization_rec);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   L_DEBUG_KEY, 'Returned from call to update_reading_id');
  END IF;

  IF (l_utilization_rec.cascade_flag = 'Y') THEN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY, 'l_utilization_rec.cascade_flag = Y');
    END IF;
  -- Process for config items.
    FOR child_rec IN csi_relationships_csr(p_utilization_rec.csi_item_instance_id) LOOP
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       L_DEBUG_KEY, 'Processing child instance ' || child_rec.csi_item_instance_id);
      END IF;
      -- Get counter ratio.
      IF ahl_util_uc_pkg.extra_node(child_rec.csi_item_instance_id, l_utilization_rec.csi_item_instance_id) THEN
        l_ratio := 1;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY, 'Instance is an extra node. Setting l_ratio to 1');
        END IF;
      ELSE
        l_ratio := get_counter_ratio(l_utilization_rec.csi_item_instance_id,
                                     child_rec.csi_item_instance_id,
                                     l_uom_code,
                                     l_utilization_rec.rule_code);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY, 'Instance is not an extra node. Setting l_ratio to ' || l_ratio);
        END IF;
      END IF;

      -- Get current counter reading values
      OPEN get_current_value_name(child_rec.csi_item_instance_id, l_utilization_rec.counter_name);
      FETCH get_current_value_name INTO l_get_current_value_name;
      IF get_current_value_name%FOUND THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY, 'get_current_value_name%FOUND is TRUE. ' ||
                         'l_get_current_value_name.counter_reading = ' || l_get_current_value_name.counter_reading);
        END IF;
      --Else the given counter name doesn't apply to this instance
      --Ensure that if the same counter existing for the component instance, then the counter's
      --UOM should be exactly the same as that of start instance's counter. Cheng has confirmed
      --this point with Barry.
        IF l_get_current_value_name.uom_code <> l_uom_code THEN
          FND_MESSAGE.set_name('AHL','AHL_UC_CTR_UOM_INVALID');
          FND_MESSAGE.set_token('COUNTER', l_utilization_rec.counter_name);
          FND_MESSAGE.set_token('INSTANCE', child_rec.csi_item_instance_id);
          FND_MESSAGE.set_token('UOM', l_get_current_value_name.uom_code);
          FND_MSG_PUB.add;
          CLOSE get_current_value_name;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          CLOSE get_current_value_name;
        END IF;

        IF l_utilization_rec.delta_flag = 'Y' THEN
          -- Begin Changes by jaramana on Feb 20, 2008 for Bug 6782765
          IF (l_change_type_flag = 'Y') THEN
            -- For Change type counters, always pass the multiplied delta value
            l_reading_value := l_ratio*l_utilization_rec.reading_value;
          ELSE
            -- For other counters, always pass the total value
            l_reading_value := l_get_current_value_name.counter_reading+l_ratio*l_utilization_rec.reading_value;
          END IF;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           L_DEBUG_KEY, 'l_utilization_rec.delta_flag is Y. Setting l_reading_value to ' || l_reading_value);
          END IF;
        ELSE
          -- Not Delta
          IF (l_change_type_flag = 'Y') THEN
            -- For Change type counters, delta_flag should always be Y
            FND_MESSAGE.set_name('AHL', 'AHL_UC_DELTA_FLAG_INVALID');
            FND_MESSAGE.set_token('FLAG', l_utilization_rec.delta_flag);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          -- End changes by jaramana on Feb 20, 2008 for Bug 6782765
          l_reading_value := l_get_current_value_name.counter_reading+
                             l_ratio*(l_utilization_rec.reading_value-l_start_current_value);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           L_DEBUG_KEY, 'l_utilization_rec.delta_flag is not Y. Setting l_reading_value to ' || l_reading_value);
          END IF;
        END IF;
        -- Update reading for the counter.
        l_ctr_grp_log_rec.counter_group_id := l_get_current_value_name.counter_group_id;
        l_ctr_grp_log_rec.value_timestamp := SYSDATE;
        l_ctr_grp_log_rec.source_transaction_id := child_rec.csi_item_instance_id;
        l_ctr_grp_log_rec.source_transaction_code := 'CP';
        l_ctr_rdg_tbl(1).counter_id := l_get_current_value_name.counter_id;
        l_ctr_rdg_tbl(1).value_timestamp := l_utilization_rec.reading_date;
        l_ctr_rdg_tbl(1).counter_reading := l_reading_value;
        l_ctr_rdg_tbl(1).valid_flag := 'Y';
        -- Changed from 'Y' to 'N' by jaramana on July 10, 2007 for bug 6127957
        l_ctr_rdg_tbl(1).override_valid_flag := 'N';
        --Call CS Counter Update API to update the counter_reading of the start instance
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY, 'About to call CS_CTR_CAPTURE_READING_PUB.capture_counter_reading with ' ||
                         'l_ctr_rdg_tbl(1).counter_reading = ' || l_ctr_rdg_tbl(1).counter_reading ||
                         ', l_ctr_rdg_tbl(1).counter_id = ' || l_ctr_rdg_tbl(1).counter_id ||
                         ', l_ctr_rdg_tbl(1).value_timestamp = ' || l_ctr_rdg_tbl(1).value_timestamp);
        END IF;
        CS_CTR_CAPTURE_READING_PUB.capture_counter_reading(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => FND_API.G_FALSE,
                   p_commit             => FND_API.G_FALSE,
                   p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                   p_ctr_grp_log_rec    => l_ctr_grp_log_rec,
                   p_ctr_rdg_tbl        => l_ctr_rdg_tbl,
                   p_prop_rdg_tbl       => l_prop_rdg_tbl,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data);
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY, 'Returned from call to CS_CTR_CAPTURE_READING_PUB.capture_counter_reading. l_return_status = ' || l_return_status);
        END IF;
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        CLOSE get_current_value_name;
        -- Added by jaramana on October 29, 2007 for bug 6513576
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY, 'get_current_value_name%FOUND is FALSE.');
        END IF;
      END IF;
    END LOOP;
  END IF;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure.');
  END IF;
END update_reading_ins;

---------------------------------------------------------------------------------

PROCEDURE update_reading_cn(p_utilization_rec IN utilization_rec_type) IS
  TYPE instance_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
/** Begin changes by jaramana on October 29, 2007 for bug 6513576
    Cannot use cs_counters and cs_counter_groups anymore **/
   -- Cursor changed by jaramana on 03-DEC-2008 for bug 7426643 (FP of 7263702)
   -- Removed the use of csi_cp_counters_v
  CURSOR get_components_counter(c_instance_id NUMBER, c_counter_name VARCHAR2) IS
    SELECT CI.subject_id
      FROM csi_ii_relationships CI
     WHERE EXISTS (SELECT 'X'
/*
                     FROM cs_counters CC,
                          cs_counter_groups CG
                    WHERE CC.counter_group_id = CG.counter_group_id
                      AND CG.source_object_id = CI.subject_id
                      AND CG.source_object_code = 'CP'
                      AND CC.name = c_counter_name
                      AND trunc(nvl(CC.start_date_active,sysdate)) <= trunc(sysdate)
                      AND trunc(nvl(CC.end_date_active,sysdate+1)) > trunc(sysdate))
*/
/*
                     FROM CSI_CP_COUNTERS_V CCCV
                    WHERE CCCV.CUSTOMER_PRODUCT_ID = CI.subject_id
                      AND CCCV.COUNTER_TEMPLATE_NAME = c_counter_name
                      AND trunc(nvl(CCCV.start_date_active, sysdate)) <= trunc(sysdate)
                      AND trunc(nvl(CCCV.end_date_active, sysdate+1)) > trunc(sysdate))
*/
                     FROM CSI_COUNTERS_VL C, CSI_COUNTER_ASSOCIATIONS CCA
                    WHERE CCA.SOURCE_OBJECT_ID = CI.subject_id
                      AND C.COUNTER_ID = CCA.COUNTER_ID(+)
                      AND CCA.SOURCE_OBJECT_CODE = 'CP'
                      AND C.COUNTER_TEMPLATE_NAME = c_counter_name
                      AND trunc(nvl(C.start_date_active, sysdate)) <= trunc(sysdate)
                      AND trunc(nvl(C.end_date_active, sysdate+1)) > trunc(sysdate))
START WITH object_id = c_instance_id
       AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(active_end_date,sysdate+1)) > trunc(sysdate)
       AND relationship_type_code = 'COMPONENT-OF'
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(active_end_date,sysdate+1)) > trunc(sysdate)
       AND relationship_type_code = 'COMPONENT-OF';

  CURSOR get_all_ancestors(c_desc_instance_id NUMBER, c_ance_instance_id NUMBER) IS
    SELECT object_id
      FROM csi_ii_relationships
START WITH subject_id = c_desc_instance_id
       AND object_id <> c_ance_instance_id
       -- This condition is really required because of the extreme case in which
       -- subject_id = c_desc_instance_id and object_id happens to be c_ance_instance_id
       -- thus it will include c_ance_instance_id and probably all of its ancestors if it has.
       AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(active_end_date,sysdate+1)) > trunc(sysdate)
       AND relationship_type_code = 'COMPONENT-OF'
CONNECT BY subject_id = PRIOR object_id
       AND object_id <> c_ance_instance_id
       AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(active_end_date,sysdate+1)) > trunc(sysdate)
       AND relationship_type_code = 'COMPONENT-OF';

   -- Get counters that match on a given counter name.
   CURSOR cs_counters_name_csr(c_csi_item_instance_id NUMBER, c_name VARCHAR2) IS
/*
      SELECT ctr.name counter_name, ctr.counter_id, ctr.uom_code, cgrp.counter_group_id
      FROM cs_counter_groups cgrp, cs_counters ctr
      WHERE cgrp.counter_group_id = ctr.counter_group_id
      AND  cgrp.source_object_code = 'CP'
      AND  cgrp.source_object_id = c_csi_item_instance_id
      AND  ctr.name = c_name
      AND  trunc(sysdate) >= trunc(nvl(ctr.start_date_active,sysdate))
      AND  trunc(sysdate) <= trunc(nvl(ctr.end_date_active,sysdate+1));
*/
      SELECT CCCV.COUNTER_TEMPLATE_NAME counter_name, CCCV.counter_id, CCCV.uom_code, CCCV.counter_group_id
        FROM CSI_CP_COUNTERS_V CCCV
       WHERE CCCV.CUSTOMER_PRODUCT_ID = c_csi_item_instance_id
         AND CCCV.COUNTER_TEMPLATE_NAME = c_name
         AND trunc(nvl(CCCV.start_date_active, sysdate)) <= trunc(sysdate)
         AND trunc(nvl(CCCV.end_date_active, sysdate+1)) > trunc(sysdate);
 /** End changes by jaramana on October 29, 2007 for bug 6513576 **/
     l_cs_counters_name_csr cs_counters_name_csr%ROWTYPE;

   -- Get current counter reading values based on the counter_id
   -- Cursor get_current_value_id commented out by jaramana on on June 13, 2007
   --  while fixing bug 6123549 since this cursor is not used in this procedure at all.
   /***
   CURSOR get_current_value_id(c_counter_id NUMBER) IS
     SELECT nvl(counter_reading,0) counter_reading,
            counter_group_id,
            uom_code
       FROM csi_cp_counters_v
      WHERE counter_id = c_counter_id;
   ***/

   l_utilization_rec utilization_rec_type;
   l_ctr_grp_log_rec CS_CTR_CAPTURE_READING_PUB.ctr_grp_log_rec_type;
   l_ctr_rdg_tbl     CS_CTR_CAPTURE_READING_PUB.ctr_rdg_tbl_type;
   l_prop_rdg_tbl    CS_CTR_CAPTURE_READING_PUB.prop_rdg_tbl_type;
   l_return_status   VARCHAR2(3);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);
   l_msg_index_out   NUMBER;
   l_instance_tbl    instance_tbl_type;
   l_inst_tmp_tbl    instance_tbl_type;
   l_parents_tbl     instance_tbl_type;
   l_inst_idx        BINARY_INTEGER;
   l_parent_idx      BINARY_INTEGER;
   l_keep_flag       BOOLEAN;
   L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_Reading_Cn';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  l_utilization_rec := p_utilization_rec;
  OPEN cs_counters_name_csr(l_utilization_rec.csi_item_instance_id,
                            l_utilization_rec.counter_name);
  FETCH cs_counters_name_csr INTO l_cs_counters_name_csr;
  IF cs_counters_name_csr%FOUND THEN
    --p_utilization_rec.uom_code := l_cs_counters_name_csr.uom_code;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'cs_counters_name_csr%FOUND. Calling update_reading_ins');
    END IF;
    update_reading_ins(l_utilization_rec);
    CLOSE cs_counters_name_csr;
  ELSE
    CLOSE cs_counters_name_csr;
    IF (NVL(l_utilization_rec.delta_flag, 'N') = 'N') THEN
      --The start instance doesn't have the given counter associated, reading value is
      --net reading but the counter doesn't exists for the start instance
      --So raise error and return, no need to go further down.
      FND_MESSAGE.set_name('AHL','AHL_UC_INST_NO_CTR_FOUND');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      IF (NVL(l_utilization_rec.cascade_flag,'N') = 'Y') THEN
      --The start instance doesn't have the given counter associated, reading value is delta
      --reading and cascade_flag = 'Y', then get all of its highest level components which
      --have the given counter associated but their ancestors don't.
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         'cs_counters_name_csr%FOUND is false. l_utilization_rec.delta_flag is Y and l_utilization_rec.cascade_flag is Y');
        END IF;
        l_inst_idx :=1;
        -- Begin changes made by jaramana on 03-DEC-2008 for bug 7426643 (FP of 7263702)
        OPEN get_components_counter(l_utilization_rec.csi_item_instance_id, l_utilization_rec.counter_name);
        FETCH get_components_counter BULK COLLECT INTO l_instance_tbl;
        CLOSE get_components_counter;
        l_inst_tmp_tbl := l_instance_tbl;
        /**
        FOR l_get_components_counter IN get_components_counter(l_utilization_rec.csi_item_instance_id,
                                                               l_utilization_rec.counter_name) LOOP
          l_instance_tbl(l_inst_idx) := l_get_components_counter.subject_id;
          l_inst_tmp_tbl(l_inst_idx) := l_instance_tbl(l_inst_idx);
          --dbms_output.put_line('l_instance_tbl:'||l_inst_idx||' '||l_instance_tbl(l_inst_idx));
          l_inst_idx := l_inst_idx + 1;
        END LOOP;
        **/
        -- End changes made by jaramana on 03-DEC-2008 for bug 7426643 (FP of 7263702)
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         'l_instance_tbl.count = ' || l_instance_tbl.count);
        END IF;
        IF l_instance_tbl.count > 0 THEN
          FOR i IN l_instance_tbl.FIRST..l_instance_tbl.LAST LOOP
            l_keep_flag := TRUE;
            --l_inst_tmp_tbl := l_instance_tbl;
            --l_inst_tmp_tbl.DELETE(i);
            l_parent_idx := 1;
            --l_parents_tbl needs to be reset after each loop
            IF l_parents_tbl.COUNT > 0 THEN
              l_parents_tbl.DELETE;
            END IF;
            FOR l_get_all_ancestors IN get_all_ancestors(l_instance_tbl(i), l_utilization_rec.csi_item_instance_id) LOOP
              l_parents_tbl(l_parent_idx) :=  l_get_all_ancestors.object_id;
              l_parent_idx := l_parent_idx + 1;
            END LOOP;
            IF l_parents_tbl.COUNT > 0 THEN
              <<OUTER1>>
              FOR j IN l_parents_tbl.FIRST..l_parents_tbl.LAST LOOP
                IF l_inst_tmp_tbl.COUNT > 0 THEN
                  FOR k IN l_inst_tmp_tbl.FIRST..l_inst_tmp_tbl.LAST LOOP
                    IF l_parents_tbl(j) = l_inst_tmp_tbl(k) THEN
                      l_keep_flag := FALSE;
                      EXIT OUTER1;
                    END IF;
                  END LOOP;
                END IF;
              END LOOP;
            END IF;
            IF NOT l_keep_flag AND l_instance_tbl.EXISTS(i) THEN
              l_instance_tbl.DELETE(i);
            END IF;
          END LOOP;
        END IF;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         'After processing, l_instance_tbl.count = ' || l_instance_tbl.count);
        END IF;
        FOR i IN l_instance_tbl.FIRST..l_instance_tbl.LAST LOOP
          IF l_instance_tbl.EXISTS(i) THEN
            l_utilization_rec.csi_item_instance_id := l_instance_tbl(i);
            --p_utilization_rec.cascade_flag := 'Y';
            update_reading_ins(l_utilization_rec);
          END IF;
        END LOOP;
      ELSE
        --The start instance doesn't have the given counter associated, reading value is delta
        --reading and cascade_flag = 'N', then raise error and stop.
        FND_MESSAGE.set_name('AHL','AHL_UC_INST_NO_CTR_FOUND');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure.');
  END IF;
END update_reading_cn;

---------------------------------------------------------------------------------

PROCEDURE update_reading_all(p_utilization_rec IN utilization_rec_type,
                             p_based_on        IN VARCHAR2)
IS
  l_utilization_rec  utilization_rec_type;
  i NUMBER;
  L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Update_Reading_All';

/** Begin changes by jaramana on October 29, 2007 for bug 6513576
    Cannot use cs_counters and cs_counter_groups anymore **/
  --Given start instance_id and uom_code, this cursor is used to get all of the distinct
  --counters this start instance has
  CURSOR get_inst_counters(c_instance_id NUMBER, c_uom_code VARCHAR2) IS
    SELECT DISTINCT CCCV.COUNTER_TEMPLATE_NAME counter_name
      FROM CSI_CP_COUNTERS_V CCCV
     WHERE CCCV.UOM_CODE = c_uom_code
       AND CCCV.CUSTOMER_PRODUCT_ID = c_instance_id
       AND trunc(nvl(CCCV.start_date_active, sysdate)) <= trunc(sysdate)
       AND trunc(nvl(CCCV.end_date_active, sysdate+1)) > trunc(sysdate);

  --Given start instance_id and uom_code, this cursor is used to get all of the distinct
  --counters this start instance and all of its components have
  -- Cursor changed by jaramana on 03-DEC-2008 for bug 7426643 (FP of 7263702)
  -- Removed the use of csi_cp_counters_v
  CURSOR get_all_counters(c_instance_id NUMBER, c_uom_code VARCHAR2) IS
    SELECT DISTINCT C.COUNTER_TEMPLATE_NAME counter_name
      FROM CSI_COUNTERS_VL C, CSI_COUNTER_ASSOCIATIONS CCA
     WHERE C.UOM_CODE = c_uom_code
       AND trunc(nvl(C.start_date_active, sysdate)) <= trunc(sysdate)
       AND trunc(nvl(C.end_date_active, sysdate+1)) > trunc(sysdate)
       AND C.COUNTER_ID = CCA.COUNTER_ID(+)
       AND CCA.SOURCE_OBJECT_CODE = 'CP'
       AND CCA.SOURCE_OBJECT_ID IN (SELECT c_instance_id
                                     FROM DUAL
                                UNION ALL
                                   SELECT subject_id
                                     FROM csi_ii_relationships CI
                               START WITH object_id = c_instance_id
                                      AND trunc(nvl(CI.active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(nvl(CI.active_end_date,sysdate+1)) > trunc(sysdate)
                                      AND CI.relationship_type_code = 'COMPONENT-OF'
                               CONNECT BY object_id = PRIOR subject_id
                                      AND trunc(nvl(CI.active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(nvl(CI.active_end_date,sysdate+1)) > trunc(sysdate)
                                      AND CI.relationship_type_code = 'COMPONENT-OF');

/** End changes by jaramana on October 29, 2007 for bug 6513576 **/

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  l_utilization_rec := p_utilization_rec;
  IF (p_based_on = ':COUNTERID') THEN
    -- No cascade issue no matter whether cascade flag is set to 'Y' or 'N', just update the
    -- specific counter_id
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'p_based_on is COUNTERID. Calling update_reading_id');
    END IF;
    update_reading_id(l_utilization_rec);
  ELSIF (p_based_on = ':COUNTER') THEN
    --For a given pair of counter_name and instance_id, it will uniquely identify the counter_id(confirmed).
    --If the counter_name exsits in the start instance, and the cascade_flag = 'Y', then the counter ratio
    --for the components are calculated from the start instance(here reading_value(can be either delta
    --reading or net reading) refers to the counter of
    --the start instance). Otherwise, if the counter_name doesn't exist for the start instance and if the
    --reading value is net reading then raise error and stop, and if the reading value is delta reading,
    --then we get all of the highest level components of the start instance which
    --have the counter_name associated but all of their ancestors don't and make each of these components
    --as start point(assuming reading_value (only delta reading) refers to their counters) and calculate the
    --counter ratio of their own components.
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'p_based_on is COUNTER. Calling update_reading_cn');
    END IF;
    update_reading_cn(l_utilization_rec);
  ELSIF (p_based_on = ':UOM') THEN
    --For a given pair of UOM and instance_id, we may get none, one or multiple counters.
    --IF cascade_flag = 'Y' and delta_flag = 'Y', then we traverse down the UC tree with the start instance
    --as the starting point and get all of the distinct counters with the same UOM. Otherwise if delta_flag = 'N',
    --then we just get all the counters associated with the start instance with the same UOM. For all of these
    --distinct counters loop just like p_based_on = ':COUNTER'.
    i := 0;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     L_DEBUG_KEY,
                     'p_based_on is UOM, l_utilization_rec.delta_flag = ' || l_utilization_rec.delta_flag);
    END IF;
    IF NVL(l_utilization_rec.delta_flag, 'N') = 'N' THEN
      FOR l_get_inst_counters IN get_inst_counters(l_utilization_rec.csi_item_instance_id,
                                                   l_utilization_rec.uom_code) LOOP
        l_utilization_rec.counter_name := l_get_inst_counters.counter_name;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         'l_get_inst_counters.counter_name = ' || l_get_inst_counters.counter_name ||
                         ', i = ' || i || ', Calling update_reading_cn');
        END IF;
        update_reading_cn(l_utilization_rec);
        i := i+1;
      END LOOP;
    ELSE
      FOR l_get_all_counters IN get_all_counters(l_utilization_rec.csi_item_instance_id,
                                                 l_utilization_rec.uom_code) LOOP
        l_utilization_rec.counter_name := l_get_all_counters.counter_name;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         L_DEBUG_KEY,
                         ' l_get_all_counters.counter_name = ' || l_get_all_counters.counter_name ||
                         ', i = ' || i || ', Calling update_reading_cn');
        END IF;
        update_reading_cn(l_utilization_rec);
        i := i+1;
      END LOOP;
    END IF;
    IF i=0 THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_INST_NO_CTR_FOUND');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure.');
  END IF;
END update_reading_all;

---------------------------------------------------------------------------------

FUNCTION get_counter_ratio(p_start_instance_id IN NUMBER,
                           p_desc_instance_id  IN NUMBER,
                           p_uom_code          IN VARCHAR2,
                           p_rule_code         IN VARCHAR2)
RETURN NUMBER IS
  -- for counter rules given a relationship_id.
  CURSOR ahl_ctr_rule_csr (c_relationship_id NUMBER,
                           c_uom_code        VARCHAR2,
                           c_rule_code       VARCHAR2) IS
    SELECT ratio
      FROM ahl_ctr_update_rules
     WHERE relationship_id = c_relationship_id
       AND rule_code = c_rule_code
       AND uom_code  = c_uom_code;

  CURSOR get_ancestors(c_start_instance_id NUMBER, c_desc_instance_id NUMBER) IS
    SELECT object_id,
           subject_id,
           to_number(position_reference) relationship_id
      FROM csi_ii_relationships
START WITH subject_id = c_desc_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND subject_id <> c_start_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  l_rule_code             ahl_ctr_update_rules.rule_code%TYPE := p_rule_code;
  l_ratio                 NUMBER;
  l_total_ratio           NUMBER;
  l_position_ref          NUMBER;
  l_uom_code              ahl_ctr_update_rules.uom_code%TYPE;
  l_match_found_flag      BOOLEAN;
  l_table_count           NUMBER;
  l_posn_master_config_id NUMBER;
  L_DEBUG_KEY       CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Counter_Ratio';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Function' ||
                   ', p_rule_code = ' || p_rule_code);
  END IF;
  IF (p_rule_code IS NULL OR p_rule_code = FND_API.G_MISS_CHAR) THEN
    l_rule_code := 'STANDARD';
  END IF;

  l_total_ratio := 1;

  FOR l_get_ancestor IN get_ancestors(p_start_instance_id, p_desc_instance_id) LOOP
    OPEN ahl_ctr_rule_csr(l_get_ancestor.relationship_id, p_uom_code, l_rule_code);
    FETCH ahl_ctr_rule_csr INTO l_ratio;
    IF ahl_ctr_rule_csr%FOUND THEN
      l_total_ratio := l_total_ratio * l_ratio;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       L_DEBUG_KEY,
                       'l_ratio = ' || l_ratio || ', Setting l_total_ratio to ' || l_total_ratio);
      END IF;
    END IF;
    CLOSE ahl_ctr_rule_csr;
  END LOOP;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Function' ||
                   '. Returning l_total_ratio as ' || l_total_ratio);
  END IF;

  RETURN l_total_ratio;

EXCEPTION
  WHEN INVALID_NUMBER THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_INST_POSITION_INVALID');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_counter_ratio;

END AHL_UC_UTILIZATION_PVT;

/
