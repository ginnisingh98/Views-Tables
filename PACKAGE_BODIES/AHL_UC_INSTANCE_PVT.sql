--------------------------------------------------------
--  DDL for Package Body AHL_UC_INSTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_INSTANCE_PVT" AS
/* $Header: AHLVUCIB.pls 120.16.12010000.7 2009/12/18 06:58:03 sathapli ship $ */

-- Define global internal variables
G_PKG_NAME VARCHAR2(30) := 'AHL_UC_INSTANCE_PVT';

-- Define global cursors
CURSOR get_instance_date(c_instance_id NUMBER) IS
  SELECT active_end_date
    FROM csi_item_instances
   WHERE instance_id = c_instance_id;

-- Local validation procedures
-- Procedure to validate serial numbers
PROCEDURE validate_serialnumber(p_inventory_id           IN  NUMBER,
                                p_serial_number          IN  VARCHAR2,
                                p_serial_number_control  IN  NUMBER,
                                p_serialnum_tag_code     IN  VARCHAR2,
                                p_quantity               IN  NUMBER,
                                p_concatenated_segments  IN  VARCHAR2) IS
  CURSOR mtl_serial_numbers_csr(c_inventory_id  IN NUMBER,
                                c_serial_number IN VARCHAR2) IS
    SELECT 'X'
      FROM mtl_serial_numbers
     WHERE inventory_item_id = c_inventory_id
       AND serial_number = c_serial_number;
  l_junk       VARCHAR2(1);
BEGIN
  --Validate serial number(1 = No serial number control; 2 = Pre-defined;
  --3 = Dynamic Entry at inventory receipt.)
  IF (nvl(p_serial_number_control,0) IN (2,5,6)) THEN
    -- serial number is mandatory.
    IF (p_serial_number IS NULL) OR (p_serial_number = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_SERIAL_NULL');
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Serial Number is null');
    ELSE
/**
      Commented out by jaramana on April 26, 2005 since IB does this validation.
      -- If serial tag code = INVENTORY  then validate serial number against inventory.
      IF (p_serialnum_tag_code = 'INVENTORY') THEN
        OPEN  mtl_serial_numbers_csr(p_inventory_id,p_Serial_Number);
        FETCH mtl_serial_numbers_csr INTO l_junk;
        IF (mtl_serial_numbers_csr%NOTFOUND) THEN
          FND_MESSAGE.set_name('AHL','AHL_UC_SERIAL_INVALID');
          FND_MESSAGE.set_token('SERIAL',p_Serial_Number);
          FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
          FND_MSG_PUB.add;
          --dbms_output.put_line('Serial Number does not exist in master ');
        END IF;
        CLOSE mtl_serial_numbers_csr;
      END IF;
**/
      -- Check quantity.
      IF (nvl(p_quantity,0) <> 1)  THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_SRLQTY_MISMATCH');
        FND_MESSAGE.set_token('QTY',p_quantity);
        FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.add;
        --dbms_output.put_line('For serialized items Quantity must be 1');
      END IF;
    END IF;
  ELSE
    -- if not serialized item, then serial number must be null.
    IF (p_serial_number <> FND_API.G_MISS_CHAR) AND (p_serial_number IS NOT NULL) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_SERIAL_NOTNULL');
      FND_MESSAGE.set_token('SERIAL',p_Serial_Number);
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Serial Number is not null');
    END IF;
  END IF; /* for serial number control */
END validate_serialnumber;

--Procedure to validate quantity
PROCEDURE validate_quantity(p_inventory_id          IN  NUMBER,
                            p_organization_id       IN  NUMBER,
                            p_quantity              IN  NUMBER,
                            p_uom_code              IN  VARCHAR2,
                            p_concatenated_segments IN  VARCHAR2) IS
BEGIN
  --Validate quantity and UOM code.
  IF (p_quantity = FND_API.G_MISS_NUM OR p_quantity IS NULL) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_QTY_NULL');
    FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Quantity is null.');
  ELSIF (p_quantity <= 0) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_QTY_INVALID');
    FND_MESSAGE.set_token('QTY',p_quantity);
    FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Quantity is less than or equal to zero.');
  ELSE
    --Call inv function to validate uom.
    IF NOT(inv_convert.validate_Item_Uom(p_item_id          => p_inventory_id,
                                         p_organization_id  => p_organization_id,
                                         p_uom_code         => p_uom_code))
    THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_UOM_INVALID');
      FND_MESSAGE.set_token('UOM',p_uom_code);
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Invalid UOM code for the item');
    END IF;
  END IF; /* for p_quantity */
END validate_quantity;

--Procedure to validate Lot Number
PROCEDURE validate_lotnumber(p_inventory_id          IN  NUMBER,
                             p_organization_id       IN  NUMBER,
                             p_lot_control_code      IN  NUMBER,
                             p_lot_number            IN  VARCHAR2,
                             p_concatenated_segments IN  VARCHAR2) IS
  CURSOR mtl_lot_numbers_csr(c_inventory_id      IN  NUMBER,
                             c_organization_id   IN  NUMBER,
                             c_lot_number        IN  VARCHAR2)  IS
    SELECT 'X'
      FROM mtl_lot_numbers
     WHERE inventory_item_id = c_inventory_id
       AND organization_id =  c_organization_id
       AND lot_number =  c_lot_number
       AND nvl(disable_flag,2) = 2;
  l_junk  VARCHAR(1);
BEGIN
  -- Validate Lot number.(1 = No lot control; 2 = Full lot control)
  IF (nvl(p_lot_control_code,0) = 2) THEN
    IF (p_lot_number IS NULL) OR (p_lot_number = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_LOT_NULL');
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Lot Number is null');
    ELSE
      OPEN mtl_lot_numbers_csr(p_inventory_id,p_organization_id, p_lot_number);
      FETCH mtl_lot_numbers_csr INTO l_junk;
      IF (mtl_lot_numbers_csr%NOTFOUND) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_LOT_INVALID');
        FND_MESSAGE.set_token('LOT',p_Lot_number);
        FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.add;
        --dbms_output.put_line('Lot number does not exist in master');
      END IF;
      CLOSE mtl_lot_numbers_csr;
    END IF;
  ELSIF (p_Lot_number <> FND_API.G_MISS_CHAR) AND (p_lot_Number IS NOT NULL) THEN

    -- If lot number not controlled; then lot num must be null.
    FND_MESSAGE.set_name('AHL','AHL_UC_LOT_NOTNULL');
    --FND_MESSAGE.set_token('LOT',p_Lot_Number);
    FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Lot Number is not null');
  END IF; /* for lot_control_code */
END validate_lotnumber;

--Procedure to validate Revision
PROCEDURE validate_revision(p_inventory_id              IN  NUMBER,
                            p_organization_id           IN  NUMBER,
                            p_revision_qty_control_code IN  NUMBER,
                            p_Revision                  IN  VARCHAR2,
                            p_concatenated_segments     IN  VARCHAR2) IS
  CURSOR mtl_item_revisions_csr(c_inventory_id          IN  NUMBER,
                                c_organization_id       IN  NUMBER,
                                c_revision              IN  VARCHAR2) IS
    SELECT 'X'
      FROM mtl_item_revisions
     WHERE inventory_item_id = c_inventory_id
       AND organization_id = c_organization_id
       AND revision = c_revision;
    l_junk   VARCHAR2(1);
BEGIN
  --Validate Revision.
  IF (nvl(p_revision_qty_control_code,0) = 2) THEN
    IF (p_revision IS NULL) OR (p_revision = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_REV_NULL');
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Revision is null');
    ELSE
      OPEN mtl_item_revisions_csr(p_inventory_id,p_organization_id, p_revision);
      FETCH mtl_item_revisions_csr INTO l_junk;
      IF (mtl_item_revisions_csr%NOTFOUND) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_REV_INVALID');
        FND_MESSAGE.set_token('REV',p_revision);
        FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.add;
        --dbms_output.put_line('Revision does not exist in master');
      END IF;
      CLOSE mtl_item_revisions_csr;
    END IF;
  ELSIF (p_revision IS NOT NULL) AND (p_revision <> FND_API.G_MISS_CHAR) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_REV_NOTNULL');
    --FND_MESSAGE.set_token('REV',p_revision);
    FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Revision is not null. Revision not required.');
  END IF; /* for revision_qty_control_code */
END validate_revision;

--Procedure to validate Serial Number Tag
PROCEDURE validate_serialnum_tag(p_serialnum_tag_code    IN  VARCHAR2,
                                 p_serial_number_control IN  NUMBER,
                                 p_concatenated_segments IN  VARCHAR2) IS

BEGIN
  IF (p_serial_number_control IN (2,5,6)) THEN
    IF (p_serialnum_tag_code IS NULL OR p_serialnum_tag_code = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_SERIALTAG_NULL');
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
    ELSE
      IF NOT(AHL_UTIL_MC_PKG.validate_Lookup_Code('AHL_SERIALNUMBER_TAG',p_serialnum_tag_code)) THEN

        FND_MESSAGE.set_name('AHL','AHL_UC_SERIALTAG_INVALID');
        FND_MESSAGE.set_token('TAG',p_serialnum_tag_code);
        FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.add;
        --dbms_output.put_line('Serial Tag code is invalid.');
      END IF;
    END IF;
  ELSE
    IF (p_serialnum_tag_code IS NOT NULL AND p_serialnum_tag_code <> FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_SERIALTAG_NOTNULL');
      FND_MESSAGE.set_token('TAG',p_serialnum_tag_code);
      FND_MESSAGE.set_token('INV_ITEM',p_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Serial Tag code is invalid.');
    END IF;
  END IF; /* p_serial_number_control */
END validate_serialnum_tag;

--Procedure to call the above procedures to validate the attributes
PROCEDURE validate_uc_invdetails(p_inventory_id          IN         NUMBER,
                                 p_organization_id       IN         NUMBER,
                                 p_Serial_Number         IN         VARCHAR2,
                                 p_serialnum_tag_code    IN         VARCHAR2,
                                 p_quantity              IN         NUMBER,
                                 p_uom_code              IN         VARCHAR2,
                                 p_revision              IN         VARCHAR2,
                                 p_lot_number            IN         VARCHAR2,
                                 p_position_ref_meaning  IN         VARCHAR2,
                                 x_concatenated_segments OUT NOCOPY VARCHAR2 ) IS

  CURSOR mtl_system_items_csr(c_inventory_id IN NUMBER, c_organization_id IN NUMBER) IS
    SELECT serial_number_control_code,
           lot_control_code,
           concatenated_segments,
           revision_qty_control_code,
           comms_nl_trackable_flag
      FROM mtl_system_items_kfv
     WHERE inventory_item_id = c_inventory_id
       AND organization_id = c_organization_id;
    l_serial_number_control     NUMBER;
    l_lot_control_code          NUMBER;
    -- Changed by jaramana on 16-APR-2008 for bug 6977832
    -- Changed from 40 to mtl_system_items_kfv.concatenated_segments%TYPE in order
    -- to accommodate longer item names.
    l_concatenated_segments     mtl_system_items_kfv.concatenated_segments%TYPE;
    l_revision_qty_control_code NUMBER;
    l_comms_nl_trackable_flag   VARCHAR2(1);
BEGIN
  IF (p_inventory_id IS NULL) OR (p_inventory_id = FND_API.G_MISS_NUM)
      OR (p_organization_id IS NULL) OR (p_organization_id = FND_API.G_MISS_NUM)
  THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_INVITEM_NULL');
    FND_MESSAGE.set_token('POSN_REF',p_position_ref_meaning);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Inventory Item is null');
    RETURN;
  END IF;
  -- Check for existence of inventory item .
  OPEN mtl_system_items_csr (p_inventory_id, p_organization_id);
  FETCH mtl_system_items_csr INTO l_serial_number_control,
                                  l_lot_control_code,
                                  l_concatenated_segments,
                                  l_revision_qty_control_code,
                                  l_comms_nl_trackable_flag;
  IF (mtl_system_items_csr%NOTFOUND) THEN
    CLOSE mtl_system_items_csr;
    FND_MESSAGE.set_name('AHL','AHL_UC_INVITEM_INVALID');
    FND_MESSAGE.set_token('POSN_REF',p_position_ref_meaning);
    FND_MSG_PUB.add;
    x_concatenated_segments := null;
    --dbms_output.put_line('Inventory item does not exist in Master');
    RETURN;
  END IF;
  CLOSE mtl_system_items_csr;
  IF upper(nvl(l_comms_nl_trackable_flag,'N')) = 'N' THEN
    FND_MESSAGE.set_name('AHL','AHL_MC_INV_TRACK');
    FND_MESSAGE.set_token('INV_ITEM',l_concatenated_segments);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Inventory item does not exist in Master');
  END IF;
  -- Validate quantity .
  validate_quantity(p_inventory_id,
                    p_organization_id,
                    p_quantity,
                    p_uom_code,
                    l_concatenated_segments);
  -- Validate serialnumber.
  validate_serialnumber(p_inventory_id,
                        p_Serial_Number,
                        l_serial_number_control,
                        p_serialnum_tag_code,
                        p_quantity,
                        l_concatenated_segments);
  -- Validate serialnum_tag_code.
  validate_serialnum_tag(p_serialnum_tag_code,
                         l_serial_number_control,
                         l_concatenated_segments);
  -- Validate lot.
  validate_lotnumber(p_inventory_id,
                     p_organization_id,
                     l_lot_control_code,
                     p_lot_number,
                     l_concatenated_segments);
  -- Validate Revision.
  validate_revision(p_inventory_id,
                    p_organization_id,
                    l_revision_qty_control_code,
                    p_revision,
                    l_concatenated_segments);
  x_concatenated_segments := l_concatenated_segments;
END validate_uc_invdetails;

--Function to get the operating unit of a given instance_id
FUNCTION get_operating_unit(p_instance_id NUMBER) RETURN NUMBER IS
  l_operating_unit NUMBER;
  CURSOR get_instance_ou IS

    -- SATHAPLI::Bug#4912576 fix::SQL ID 14401150 --
    /*
    SELECT o.operating_unit
      FROM org_organization_definitions o,
           mtl_system_items_kfv m,
           csi_item_instances c
     WHERE c.instance_id = p_instance_id
       AND c.inventory_item_id = m.inventory_item_id
       AND c.inv_master_organization_id = m.organization_id
       AND m.organization_id = o.organization_id;
    */
    SELECT i.operating_unit
    FROM   inv_organization_info_v i, mtl_system_items_kfv m,
           csi_item_instances c
    WHERE  c.instance_id = p_instance_id AND
           c.inventory_item_id = m.inventory_item_id AND
           c.inv_master_organization_id = m.organization_id AND
           m.organization_id = i.organization_id;

BEGIN
  OPEN get_instance_ou;
  FETCH get_instance_ou INTO l_operating_unit;
  CLOSE get_instance_ou;
  return l_operating_unit;
END;

-- Define Procedure unassociate_instance_pos --
-- This API is used to to remove a child instance's position reference but keep
-- the parent-child relationship in a UC tree structure (in other word, to make
-- the child instance as an extra node in the UC).
PROCEDURE unassociate_instance_pos (
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_instance_id           IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'unassociate_instance_pos';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_subject_id                NUMBER;
  l_object_id                 NUMBER;
  l_csi_relationship_id       NUMBER;
  l_object_version_number     NUMBER;
  l_transaction_type_id       NUMBER;
  l_return_value              BOOLEAN;
  l_root_uc_header_id         NUMBER;
  l_root_instance_id          NUMBER;
  l_root_uc_status_code       FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_uc_ovn               NUMBER;
  l_end_date                  DATE;
  CURSOR check_uc_header IS
    SELECT unit_config_header_id,
           object_version_number,
           unit_config_status_code,
           active_uc_status_code,
           csi_item_instance_id
      FROM ahl_unit_config_headers
     WHERE unit_config_header_id = p_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_uc_header check_uc_header%ROWTYPE;
  CURSOR get_uc_descendants(c_instance_id NUMBER) IS
    SELECT relationship_id,
           object_version_number,
           object_id,
           subject_id
      FROM csi_ii_relationships
START WITH object_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT unassociate_instance_pos;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  --Validate input parameters p_prod_user_flag
  IF (upper(p_prod_user_flag) <> 'Y' AND upper(p_prod_user_flag) <> 'N') THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'prod_user_flag');
    FND_MESSAGE.set_token('VALUE', p_prod_user_flag);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Validate input parameters p_csi_ii_ovn
  IF (p_csi_ii_ovn IS NULL OR p_csi_ii_ovn <= 0 ) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'csi_ii_ovn');
    FND_MESSAGE.set_token('VALUE', p_csi_ii_ovn);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Validate input parameter p_uc_header_id, its two status
  OPEN check_uc_header;
  FETCH check_uc_header INTO l_check_uc_header;
  IF check_uc_header%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_uc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    -- ACL :: Changes for R12
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ahl_util_uc_pkg.get_root_uc_attr(p_uc_header_id,
                                     l_root_uc_header_id,
                                     l_root_instance_id,
                                     l_root_uc_status_code,
                                     l_root_active_uc_status_code,
                                     l_root_uc_ovn);
    IF (p_prod_user_flag = 'Y' AND --For production user, no need to confirm either one of the statuses is not APPROVAL_PENDING
        l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_NOT_ACTIVE' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (p_prod_user_flag = 'N' AND
           (l_root_uc_status_code = 'APPROVAL_PENDING' OR
            l_root_active_uc_status_code = 'APPROVAL_PENDING')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_PENDING' );
      FND_MESSAGE.set_token('UC_HEADER_ID', l_root_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_uc_header;
    END IF;
  END IF;
  --Make sure p_instance_id is valid and installed in the UC
  FOR l_get_uc_descendant IN get_uc_descendants(l_check_uc_header.csi_item_instance_id) LOOP
    l_csi_relationship_id := l_get_uc_descendant.relationship_id;
    l_object_version_number := l_get_uc_descendant.object_version_number;
    l_object_id := l_get_uc_descendant.object_id;
    l_subject_id := l_get_uc_descendant.subject_id;
    EXIT WHEN l_subject_id = p_instance_id;
  END LOOP;
  IF (p_instance_id IS NULL OR l_subject_id IS NULL OR l_subject_id <> p_instance_id)THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'instance_id');
    FND_MESSAGE.set_token('VALUE', p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  --Ensure no current user makes change to the same csi_ii_relationships record
  ELSIF l_object_version_number <> p_csi_ii_ovn THEN
    FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Make sure p_instance_id is not expired otherwise unassociation is not allowed
  --Added on 02/26/2004
  OPEN get_instance_date(p_instance_id);
  FETCH get_instance_date INTO l_end_date;
  CLOSE get_instance_date;
  IF TRUNC(NVL(l_end_date, SYSDATE+1)) <= TRUNC(SYSDATE) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_EXPIRED');
    FND_MESSAGE.set_token('INSTANCE', p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --The following lines are used to update the position_reference column in csi_ii_relationships
  --First, get transaction_type_id .
  AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_value);
  IF NOT l_return_value THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Set the CSI transaction record
  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
  --Set CSI relationship record
  l_csi_relationship_rec.relationship_id := l_csi_relationship_id;
  l_csi_relationship_rec.object_version_number := l_object_version_number;
  l_csi_relationship_rec.position_reference := NULL;
  l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
  l_csi_relationship_rec.object_id := l_object_id;
  l_csi_relationship_rec.subject_id := l_subject_id;
  l_csi_relationship_tbl(1) := l_csi_relationship_rec;
  CSI_II_RELATIONSHIPS_PUB.update_relationship(
                           p_api_version      => 1.0,
                           p_relationship_tbl => l_csi_relationship_tbl,
                           p_txn_rec          => l_csi_transaction_rec,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --For UC user, UC header status change needs to be made after the operation
  --Not confirmed whether need to copy the record into UC header history table
  --after status change. Not include the copy right now. (Confirmed and not necessary here)
  IF p_prod_user_flag = 'N' THEN
    IF l_root_uc_status_code = 'COMPLETE' THEN
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code = 'INCOMPLETE' AND
           (l_root_active_uc_status_code IS NULL OR
            l_root_active_uc_status_code <> 'UNAPPROVED')) THEN
      UPDATE ahl_unit_config_headers
         SET active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE', 'DRAFT') THEN
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'DRAFT',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  ELSIF p_prod_user_flag = 'Y' THEN
    IF l_root_uc_status_code = 'COMPLETE' THEN
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF; --For production user, no need to change any one of the status.

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;
  --Get all the error messages from the previous steps (if any) and raise the appropriate Exception

  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  --Count and Get messages(optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO unassociate_instance_pos;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO unassociate_instance_pos;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO unassociate_instance_pos;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END unassociate_instance_pos;

-- Define Procedure remove_instance
-- This API is used to remove an instance (leaf, branch node or sub-unit) from aUC node.

PROCEDURE remove_instance (
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_instance_id           IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'remove_instance';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_upd_transaction_rec   csi_datastructures_pub.transaction_rec;
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_instance_id_lst       csi_datastructures_pub.id_tbl;
  l_subject_id                NUMBER;
  l_object_id                 NUMBER;
  l_csi_relationship_id       NUMBER;
  l_object_version_number     NUMBER;
  l_position_reference        csi_ii_relationships.position_reference%TYPE;
  l_position_necessity        FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_transaction_type_id       NUMBER;
  l_return_value              BOOLEAN;
  l_dummy_num                 NUMBER;
  l_sub_uc_header_id          NUMBER;
  l_root_uc_header_id         NUMBER;
  l_root_instance_id          NUMBER;
  l_root_uc_status_code       FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_uc_ovn               NUMBER;
  l_uc_status_code            FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  CURSOR check_uc_header IS
    SELECT unit_config_header_id,
           object_version_number,
           unit_config_status_code,
           active_uc_status_code,
           csi_item_instance_id
      FROM ahl_unit_config_headers
     WHERE unit_config_header_id = p_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_uc_header check_uc_header%ROWTYPE;

  CURSOR get_uc_descendants(c_instance_id NUMBER) IS
    SELECT relationship_id,
           object_version_number,
           object_id,
           subject_id,
           to_number(position_reference) position_reference
      FROM csi_ii_relationships
START WITH object_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_csi_obj_ver_num(c_instance_id NUMBER) IS
    SELECT object_version_number
      FROM csi_item_instances
     WHERE instance_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR check_instance_non_leaf(c_instance_id NUMBER) IS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE object_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR check_instance_subunit(c_instance_id NUMBER) IS
    SELECT unit_config_header_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_position_necessity(c_relationship_id NUMBER) IS
    SELECT position_necessity_code
      FROM ahl_mc_relationships
     WHERE relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --To get all the first level sub-units for a given branch node. First get all of the
  --branch node's sub-units and then remove those sub-units which are not first level
  --(from the branch node's perspective)
  CURSOR get_1st_level_subunits(c_instance_id NUMBER) IS
  /*This query is replaced by the one below it for performance gain
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE subject_id IN (SELECT csi_item_instance_id
                            FROM ahl_unit_config_headers
                           WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH object_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
     MINUS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE subject_id IN (SELECT csi_item_instance_id
                            FROM ahl_unit_config_headers
                           WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH object_id IN (SELECT subject_id
                           FROM csi_ii_relationships
                          WHERE subject_id IN (SELECT csi_item_instance_id
                                                 FROM ahl_unit_config_headers
                                                WHERE trunc(nvl(active_end_date,SYSDATE+1)) > trunc(SYSDATE))
                     START WITH object_id = c_instance_id
                            AND relationship_type_code = 'COMPONENT-OF'
                            AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                            AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                     CONNECT BY object_id = PRIOR subject_id
                            AND relationship_type_code = 'COMPONENT-OF'
                            AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                            AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  */
  SELECT i.subject_id
    FROM csi_ii_relationships i
   WHERE EXISTS (SELECT 'x'
                  FROM ahl_unit_config_headers u
                 WHERE u.csi_item_instance_id = i.subject_id
                   AND trunc(nvl(u.active_end_date, SYSDATE+1)) > trunc(SYSDATE))
     AND NOT EXISTS (SELECT ci.object_id
                       FROM csi_ii_relationships ci
                      WHERE (EXISTS (SELECT 'x'
                                       FROM ahl_unit_config_headers ui
                                      WHERE ui.csi_item_instance_id = ci.object_id)
                                AND ci.object_id <> c_instance_id)
                 START WITH ci.subject_id = i.subject_id
                        AND ci.relationship_type_code = 'COMPONENT-OF'
                        AND trunc(nvl(ci.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                        AND trunc(nvl(ci.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                 CONNECT BY ci.subject_id = prior ci.object_id
                        AND ci.relationship_type_code = 'COMPONENT-OF'
                        AND trunc(nvl(ci.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                        AND trunc(nvl(ci.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                        AND ci.subject_id <> c_instance_id)
START WITH i.object_id = c_instance_id
       AND i.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(i.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(i.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY i.object_id = PRIOR i.subject_id
       AND i.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(i.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(i.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_id(c_instance_id NUMBER) IS
    SELECT unit_config_header_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT remove_instance;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  --Validate input parameters p_prod_user_flag
  IF upper(p_prod_user_flag) <> 'Y' AND upper(p_prod_user_flag) <> 'N' THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'prod_user_flag');
    FND_MESSAGE.set_token('VALUE', p_prod_user_flag);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate input parameters p_csi_ii_ovn
  IF (p_csi_ii_ovn IS NULL OR p_csi_ii_ovn <= 0 ) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'csi_ii_ovn');
    FND_MESSAGE.set_token('VALUE', p_csi_ii_ovn);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Validate input parameter p_uc_header_id, its two statuses
  OPEN check_uc_header;
  FETCH check_uc_header INTO l_check_uc_header;
  IF check_uc_header%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('NAME', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_uc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    -- ACL :: Changes for R12
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ahl_util_uc_pkg.get_root_uc_attr(p_uc_header_id,
                                     l_root_uc_header_id,
                                     l_root_instance_id,
                                     l_root_uc_status_code,
                                     l_root_active_uc_status_code,
                                     l_root_uc_ovn);
    IF (p_prod_user_flag = 'Y' AND --For production user, no need to confirm either one of the statuses is not APPROVAL_PENDING
        l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_NOT_ACTIVE' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (p_prod_user_flag = 'N' AND
           (l_root_uc_status_code = 'APPROVAL_PENDING' OR
            l_root_active_uc_status_code = 'APPROVAL_PENDING')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_PENDING' );
      FND_MESSAGE.set_token('UC_HEADER_ID', l_root_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_uc_header;
    END IF;
  END IF;
  --Make sure p_instance_id is in the UC
  FOR l_get_uc_descendant IN get_uc_descendants(l_check_uc_header.csi_item_instance_id) LOOP
    l_csi_relationship_id := l_get_uc_descendant.relationship_id;
    l_object_version_number := l_get_uc_descendant.object_version_number;
    l_object_id := l_get_uc_descendant.object_id;
    l_subject_id := l_get_uc_descendant.subject_id;
    l_position_reference := l_get_uc_descendant.position_reference;
    EXIT WHEN l_subject_id = p_instance_id;
  END LOOP;
  --Ensure the instance is installed in this UC but it could be an extra node(l_position_referece=null)

  IF (p_instance_id IS NULL OR l_subject_id IS NULL OR l_subject_id <> p_instance_id) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_API_PARAMETER_INVALID' );
    FND_MESSAGE.set_token('NAME', 'instance_id');
    FND_MESSAGE.set_token('VALUE', p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  --Ensure no current user makes change to the same csi_ii_relationships record
  ELSIF l_object_version_number <> p_csi_ii_ovn THEN
    FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --The following lines are used to update the position_reference column in csi_ii_relationships
  --First, get transaction_type_id .
  AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_value);
  IF NOT l_return_value THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Set the CSI transaction record
  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
  l_csi_upd_transaction_rec := l_csi_transaction_rec;

  --Set CSI relationship record
  l_csi_relationship_rec.relationship_id := l_csi_relationship_id;
  l_csi_relationship_rec.object_version_number := l_object_version_number;

  CSI_II_RELATIONSHIPS_PUB.expire_relationship(
                           p_api_version      => 1.0,
                           p_relationship_rec => l_csi_relationship_rec,
                           p_txn_rec          => l_csi_transaction_rec,
                           x_instance_id_lst  => l_csi_instance_id_lst,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data);

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Expire the instance and its descendant instances if it is a branch node or sub-unit when the
  --UC is not in active status. Even the sub-unit's descendants get also expired. The sub-unit
  --itself is inactive because inactive units can only contain inactive sub-units.

  /* According to the new requirement, this is no longer necessary
  IF (l_check_uc_header.unit_config_status_code NOT IN ('COMPLETE', 'INCOMPLETE'
)) THEN
     --get the object_version_number of the instance
     OPEN get_csi_obj_ver_num(l_subject_id);
     FETCH get_csi_obj_ver_num INTO l_dummy;
     IF (get_csi_obj_ver_num%NOTFOUND) THEN
        CLOSE get_csi_obj_ver_num;
        FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_DELETED');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSE
       CLOSE get_csi_obj_ver_num;
     END IF;
     --Call CSI API to expire the instance and all its descendants if exist
     l_csi_instance_rec.instance_id := l_subject_id;
     l_csi_instance_rec.object_version_number := l_dummy;

     CSI_ITEM_INSTANCE_PUB.expire_item_instance(
                           p_api_version         => 1.0,
                           p_instance_rec        => l_csi_instance_rec,
                           p_expire_children     => FND_API.G_TRUE,
                           p_txn_rec             => l_csi_upd_transaction_rec,
                           x_instance_id_lst     => l_csi_instance_id_lst,
                           x_return_status       => l_return_status,
                           x_msg_count           => l_msg_count,
                           x_msg_data            => l_msg_data);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF; --unit_config_status_code check
  */

  --Derive unit_config_status_code based on its root UC
  IF l_root_uc_status_code IN ('DRAFT', 'APPROVAL_REJECTED') THEN
    l_uc_status_code := 'DRAFT';
  ELSIF l_root_uc_status_code = 'COMPLETE' THEN
    l_uc_status_code := 'COMPLETE';
  ELSIF l_root_uc_status_code = 'INCOMPLETE' THEN
    l_uc_status_code := 'INCOMPLETE';
  ELSE --'APPROVAL_PENDING' might be possible for production user
    l_uc_status_code := 'DRAFT'; --not sure whether 'DRAFT' is appropriate here?
  END IF;
  --Derive active_uc_status_code based on its original parent unit
  IF l_root_active_uc_status_code = 'UNAPPROVED' THEN
    l_active_uc_status_code := 'UNAPPROVED';
  ELSIF l_root_active_uc_status_code = 'APPROVED' THEN
    l_active_uc_status_code := 'APPROVED';
  ELSE --'APPROVAL_PENDING' might be possible for production user
    l_active_uc_status_code := 'UNAPPROVED'; --not sure whether 'UNAPPROVED' is appropriate here?
  END IF;

  --If the node is the top node of a sub-unit then just itself, otherwise if it is a
  --branch node, then get all of its first level sub-units. For all of these sub-units,
  --we have to remove their parent_uc_header_id and derive their own two statuses.
  --Here we asume removing the top node instance within its own UC context is not allowed
  OPEN check_instance_subunit(p_instance_id);
  FETCH check_instance_subunit INTO l_sub_uc_header_id;
  IF check_instance_subunit%FOUND THEN --this instance is a sub-unit top node
    UPDATE ahl_unit_config_headers
       SET parent_uc_header_id = NULL,
           unit_config_status_code = l_uc_status_code,
           active_uc_status_code = l_active_uc_status_code,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
     WHERE unit_config_header_id = l_sub_uc_header_id;
       --Not necessary to check the object_version_number here

    --Copy the change to UC history table
    ahl_util_uc_pkg.copy_uc_header_to_history(l_sub_uc_header_id, l_return_status);
    --IF history copy failed, then don't raise exception, just add the messageto the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;
  ELSE --Non subunit top node
    OPEN check_instance_non_leaf(p_instance_id);
    FETCH check_instance_non_leaf INTO l_dummy_num;
    IF check_instance_non_leaf%FOUND THEN
    --This instance is a branch node
      FOR l_get_1st_level_subunit IN get_1st_level_subunits(p_instance_id) LOOP
        OPEN get_uc_header_id(l_get_1st_level_subunit.subject_id);
        FETCH get_uc_header_id INTO l_sub_uc_header_id;
        IF get_uc_header_id%NOTFOUND THEN
          FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_INVALID');
          FND_MESSAGE.set_token('INSTANCE', l_get_1st_level_subunit.subject_id);
          FND_MSG_PUB.add;
        END IF;
        CLOSE get_uc_header_id;

        UPDATE ahl_unit_config_headers
           SET parent_uc_header_id = NULL,
               unit_config_status_code = l_uc_status_code,
               active_uc_status_code = l_active_uc_status_code,
               object_version_number = object_version_number + 1,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.user_id,
               last_update_login = FND_GLOBAL.login_id
         WHERE unit_config_header_id = l_sub_uc_header_id;
         --csi_item_instance_id = l_get_1st_level_subunit.subject_id
         --AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
         --Not necessary to check the object_version_number here

        --Copy the change to UC history table
        ahl_util_uc_pkg.copy_uc_header_to_history(l_sub_uc_header_id, l_return_status);
        --IF history copy failed, then don't raise exception, just add the messae to the message stack
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
          FND_MSG_PUB.add;
        END IF;
      END LOOP;
    END IF;
    CLOSE check_instance_non_leaf;
  END IF;
  CLOSE check_instance_subunit;

  IF (l_position_reference IS NOT NULL AND
      NOT ahl_util_uc_pkg.extra_node(p_instance_id, l_root_instance_id)) THEN
    OPEN get_position_necessity(l_position_reference);
    FETCH get_position_necessity INTO l_position_necessity;
    IF get_position_necessity%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_POSTION_INVALID' );
      FND_MESSAGE.set_token('POSITION', l_position_reference);
      FND_MSG_PUB.add;
      CLOSE get_position_necessity;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_position_necessity;
    END IF;
  END IF;
  --For UC user, UC header status change needs to be made after the operation
  --Not confirmed whether need to copy the record into UC header history table
  --after status change. Not include the copy right now.
  IF p_prod_user_flag = 'N' THEN
    IF (l_root_uc_status_code = 'COMPLETE' AND l_position_necessity = 'MANDATORY') THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code IN ('COMPLETE', 'INCOMPLETE') AND
           (l_root_active_uc_status_code IS NULL OR
            l_root_active_uc_status_code <> 'UNAPPROVED')) THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE', 'DRAFT') THEN
    --IF unit_config_status_code='DRAFT', this update is only object_version_number change and
    --not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'DRAFT',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  ELSIF p_prod_user_flag = 'Y' THEN
    IF (l_root_uc_status_code = 'COMPLETE' AND l_position_necessity = 'MANDATORY') THEN
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;

  --Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  --Count and Get messages(optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO remove_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO remove_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO remove_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Define procedure update_instance_attr
-- This API is used to update an instance's (top node or non top node) attribute
-- (serial number, serial_number_tag, lot_number, revision, mfg_date and etc.)
PROCEDURE update_instance_attr(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_uc_instance_rec       IN  uc_instance_rec_type,
  p_prod_user_flag        IN  VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'update_instance_attr';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_subject_id                NUMBER;
  l_object_id                 NUMBER;
  l_csi_relationship_id       NUMBER;
  l_object_version_number     NUMBER;
  l_position_reference        csi_ii_relationships.position_reference%TYPE;
  l_transaction_type_id       NUMBER;
  l_dummy                     NUMBER;
  l_uc_status_code            VARCHAR2(30);
  l_active_uc_status_code     VARCHAR2(30);
  l_root_uc_header_id         NUMBER;
  l_root_instance_id          NUMBER;
  l_root_uc_status_code       FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_uc_ovn               NUMBER;
  l_return_val                BOOLEAN;
  l_attribute_value_id        NUMBER;
  l_attribute_value           csi_iea_values.attribute_value%TYPE;
  l_subscript                 NUMBER DEFAULT 0;
  l_subscript1                NUMBER DEFAULT 0;
  l_uc_instance_rec           uc_instance_rec_type;
  l_old_uc_instance_rec       uc_instance_rec_type;
  l_sn_tag_code               csi_iea_values.attribute_value%TYPE;
  l_sn_tag_rec_found          VARCHAR2(1) DEFAULT 'Y';
  l_serial_number_control     NUMBER;
  l_mfg_date                  csi_iea_values.attribute_value%TYPE;
  l_mfg_date_rec_found        VARCHAR2(1) DEFAULT 'Y';
  l_concatenated_segments     mtl_system_items_kfv.concatenated_segments%TYPE;
  l_lookup_code               fnd_lookups.lookup_code%TYPE;
  l_item_assoc_id             NUMBER;
  l_end_date                  DATE;

  --Variables needed for CSI API call
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_party_rec             csi_datastructures_pub.party_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_upd_transaction_rec   csi_datastructures_pub.transaction_rec;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_party_tbl             csi_datastructures_pub.party_tbl;
  l_csi_account_tbl           csi_datastructures_pub.party_account_tbl;
  l_csi_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
  l_csi_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
  l_csi_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
  l_csi_instance_id_lst       csi_datastructures_pub.id_tbl;

  --Variables used for creating extended attributes.
  l_attribute_id               NUMBER;
  l_csi_extend_attrib_rec      csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_extend_attrib_rec1     csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_ext_attrib_values_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
  l_csi_ext_attrib_values_tbl1 csi_datastructures_pub.extend_attrib_values_tbl;

  CURSOR check_uc_header IS
    SELECT unit_config_header_id,
           object_version_number,
           unit_config_status_code,
           active_uc_status_code,
           csi_item_instance_id
      FROM ahl_unit_config_headers
     WHERE unit_config_header_id = p_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_uc_header check_uc_header%ROWTYPE;
  CURSOR get_uc_descendants(c_instance_id NUMBER) IS
    SELECT relationship_id,
           object_version_number,
           object_id,
           subject_id,
           position_reference
      FROM csi_ii_relationships
START WITH object_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_instance_attributes(c_instance_id NUMBER) IS
    SELECT instance_id,
           instance_number,
           inventory_item_id,
           last_vld_organization_id,
           serial_number,
           lot_number,
           quantity,
           unit_of_measure,
           install_date,
           inventory_revision,
           object_version_number
      FROM csi_item_instances
     WHERE instance_id = c_instance_id;
       --Removed on 02/26/2004, otherwise for expired instance, the error message displayed makes no sense.
       --AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       --AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT update_instance_attr;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  --Validate input parameters p_prod_user_flag
  IF upper(p_prod_user_flag) <> 'Y' AND upper(p_prod_user_flag) <> 'N' THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'prod_user_flag');
    FND_MESSAGE.set_token('VALUE', p_prod_user_flag);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Validate input parameter p_uc_header_id, its two statuses
  OPEN check_uc_header;
  FETCH check_uc_header INTO l_check_uc_header;
  IF check_uc_header%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_uc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API',
                   ' p_uc_header_id = '||p_uc_header_id||
                   ' IS_UNIT_QUARANTINED ='||ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null));
  END IF;

    -- ACL :: Changes for R12
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ahl_util_uc_pkg.get_root_uc_attr(p_uc_header_id,
                                     l_root_uc_header_id,
                                     l_root_instance_id,
                                     l_root_uc_status_code,
                                     l_root_active_uc_status_code,
                                     l_root_uc_ovn);
    IF (p_prod_user_flag = 'Y' AND --For production user, no need to confirm either one of the statuses is not APPROVAL_PENDING
        l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_NOT_ACTIVE' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (p_prod_user_flag = 'N' AND
           (l_root_uc_status_code = 'APPROVAL_PENDING' OR
            l_root_active_uc_status_code = 'APPROVAL_PENDING')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_PENDING' );
      FND_MESSAGE.set_token( 'UC_HEADER_ID', l_root_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_uc_header;
    END IF;
  END IF;
  --Make sure p_uc_instance_rec is installed in the UC
  FOR l_get_uc_descendant IN get_uc_descendants(l_check_uc_header.csi_item_instance_id) LOOP
    l_csi_relationship_id := l_get_uc_descendant.relationship_id;
    l_object_version_number := l_get_uc_descendant.object_version_number;
    l_object_id := l_get_uc_descendant.object_id;
    l_subject_id := l_get_uc_descendant.subject_id;
    l_position_reference := l_get_uc_descendant.position_reference;
    EXIT WHEN l_subject_id = p_uc_instance_rec.instance_id OR
              l_object_id = p_uc_instance_rec.instance_id;
  END LOOP;
  --Ensure the instance is installed in this UC
  IF (l_object_id <> p_uc_instance_rec.instance_id AND
      (l_subject_id <> p_uc_instance_rec.instance_id OR
       l_subject_id IS NULL)) THEN
    --Do we allow an extra node's attributes to be changed? Yes
    FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_NOT_IN_UC' );
    FND_MESSAGE.set_token('INSTANCE', p_uc_instance_rec.instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Make sure p_uc_instance_rec.instance_id is not expired otherwise update is not allowed
  --Added on 02/26/2004
  OPEN get_instance_date(p_uc_instance_rec.instance_id);
  FETCH get_instance_date INTO l_end_date;
  CLOSE get_instance_date;
  IF TRUNC(NVL(l_end_date, SYSDATE+1)) <= TRUNC(SYSDATE) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_EXPIRED');
    FND_MESSAGE.set_token('INSTANCE', p_uc_instance_rec.instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the original instance attributes from database. Instance_id can't be changed
  --And p_uc_instance_rec contains the new attributes
  OPEN get_instance_attributes(p_uc_instance_rec.instance_id);
  FETCH get_instance_attributes INTO l_old_uc_instance_rec.instance_id,
                                     l_old_uc_instance_rec.instance_number,
                                     l_old_uc_instance_rec.inventory_item_id,
                                     l_old_uc_instance_rec.inventory_org_id,
                                     l_old_uc_instance_rec.serial_number,
                                     l_old_uc_instance_rec.lot_number,
                                     l_old_uc_instance_rec.quantity,
                                     l_old_uc_instance_rec.uom_code,
                                     l_old_uc_instance_rec.install_date,
                                     l_old_uc_instance_rec.revision,
                                     l_old_uc_instance_rec.object_version_number;

  CLOSE get_instance_attributes;

  --Added by mpothuku on 16-Jul-2007 to fix the Bug 4337259
  --Retrieve the old serial tag code so that change validations can be performed
  AHL_UTIL_UC_PKG.getcsi_attribute_value(l_old_uc_instance_rec.instance_id,
                                         'AHL_TEMP_SERIAL_NUM',
                                         l_attribute_value,
                                         l_attribute_value_id,
                                         l_object_version_number,
                                         l_return_val);
  IF l_return_val THEN
    l_old_uc_instance_rec.sn_tag_code := l_attribute_value;
  ELSE
    l_old_uc_instance_rec.sn_tag_code := null;
  END IF;
  --mpothuku End
  l_uc_instance_rec := p_uc_instance_rec;

  /*
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','The input rec is as following:');
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','instance_id = '||l_uc_instance_rec.instance_id);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','obj_ver_num = '||l_uc_instance_rec.object_version_number);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','instance_num = '||l_uc_instance_rec.instance_number);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','inv_item_id = '||l_uc_instance_rec.inventory_item_id);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','org_id = '||l_uc_instance_rec.inventory_org_id);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','serial_no = '||l_uc_instance_rec.serial_number);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','lot_no = '||l_uc_instance_rec.lot_number);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','quantity = '||l_uc_instance_rec.quantity);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','uom_code = '||l_uc_instance_rec.uom_code);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','install_date = '||l_uc_instance_rec.install_date);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API','revision = '||l_uc_instance_rec.revision);
  */

  --Convert serial_number_tag_meaning to its code
  IF (l_uc_instance_rec.sn_tag_code IS NULL OR
      l_uc_instance_rec.sn_tag_code = FND_API.G_MISS_CHAR) THEN
    IF (l_uc_instance_rec.sn_tag_meaning IS NOT NULL AND
        l_uc_instance_rec.sn_tag_meaning <> FND_API.G_MISS_CHAR) THEN
      AHL_UTIL_MC_PKG.convert_to_lookupcode('AHL_SERIALNUMBER_TAG',
                                            l_uc_instance_rec.sn_tag_meaning,
                                            l_lookup_code,
                                            l_return_val);
      IF NOT(l_return_val) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_TAGMEANING_INVALID');
        FND_MESSAGE.set_token('TAG',l_uc_instance_rec.sn_tag_meaning);
        FND_MSG_PUB.add;
      ELSE
        l_uc_instance_rec.sn_tag_code := l_lookup_code;
      END IF;
    END IF;
  END IF;
  --dbms_output.put_line('After convert serial tag');

  --Like instance_id, inventory_item_id and inventory_org_id can't be changed
  IF ((l_uc_instance_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
       l_uc_instance_rec.inventory_item_id <> l_old_uc_instance_rec.inventory_item_id) OR
      (l_uc_instance_rec.inventory_org_id <> FND_API.G_MISS_NUM AND
       l_uc_instance_rec.inventory_org_id <> l_old_uc_instance_rec.inventory_org_id)) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_COM_KEY_NOUPDATE');
    FND_MSG_PUB.ADD;
    --dbms_output.put_line('Cannot update key values');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate against inventory for changed items.
  --Following the old G_MISS standard, passing G_MISS value means no change for that column.
  IF (l_uc_instance_rec.relationship_id = FND_API.G_MISS_NUM OR
      l_uc_instance_rec.relationship_id IS NULL ) THEN
    l_uc_instance_rec.relationship_id := TO_NUMBER(l_position_reference);
  END IF;

  IF (l_uc_instance_rec.inventory_item_id = FND_API.G_MISS_NUM OR
      l_uc_instance_rec.inventory_item_id IS NULL ) THEN
    l_uc_instance_rec.inventory_item_id := l_old_uc_instance_rec.inventory_item_id;
  END IF;

  IF (l_uc_instance_rec.inventory_org_id = FND_API.G_MISS_NUM OR
      l_uc_instance_rec.inventory_org_id IS NULL) THEN
    l_uc_instance_rec.inventory_org_id := l_old_uc_instance_rec.inventory_org_id;
  END IF;

  IF (l_uc_instance_rec.quantity = FND_API.G_MISS_NUM OR
      l_uc_instance_rec.quantity IS NULL) THEN
    l_uc_instance_rec.quantity := l_old_uc_instance_rec.quantity;
  END IF;

  IF (l_uc_instance_rec.uom_code = FND_API.G_MISS_CHAR OR
      l_uc_instance_rec.uom_code IS NULL) THEN
    l_uc_instance_rec.uom_code := l_old_uc_instance_rec.uom_code;
  END IF;

  IF (l_uc_instance_rec.install_date = FND_API.G_MISS_DATE OR
      l_uc_instance_rec.install_date IS NULL) THEN
    l_uc_instance_rec.install_date := l_old_uc_instance_rec.install_date;
  END IF;

  --For the following updatable columns, front end code following the new
  --API G_MISS standard. If the value is blank, then pass G_MISS, othewise
  --pass the old value(unchanged) or new value (changed)
  IF (l_uc_instance_rec.serial_number = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.serial_number := NULL;
  END IF;

  IF (l_uc_instance_rec.revision = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.revision := NULL;
  END IF;

  IF (l_uc_instance_rec.lot_number = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.lot_number := NULL;
  END IF;

  IF (l_uc_instance_rec.sn_tag_code = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.sn_tag_code := NULL;
  END IF;

  IF (l_uc_instance_rec.mfg_date = FND_API.G_MISS_DATE) THEN
    l_uc_instance_rec.mfg_date := NULL;
  END IF;

  -- SATHAPLI::FP ER 6453212, 10-Nov-2008
  -- nullify the flexfield data in the UC instance record if G_MISS_CHAR is there
  IF (l_uc_instance_rec.context = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.context := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute1 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute2 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute3 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute4 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute5 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute6 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute7 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute8 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute9 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute10 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute11 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute12 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute13 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute14 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute15 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute16 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute16 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute17 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute17 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute18 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute18 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute19 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute19 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute20 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute20 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute21 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute21 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute22 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute22 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute23 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute23 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute24 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute24 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute25 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute25 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute26 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute26 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute27 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute27 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute28 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute28 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute29 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute29 := NULL;
  END IF;

  IF (l_uc_instance_rec.attribute30 = FND_API.G_MISS_CHAR) THEN
    l_uc_instance_rec.attribute30 := NULL;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                     ' l_old_uc_instance_rec.instance_id => '||l_old_uc_instance_rec.instance_id||
                     ' l_old_uc_instance_rec.sn_tag_code => '||l_old_uc_instance_rec.sn_tag_code ||
                     ' l_uc_instance_rec.sn_tag_code =>' || l_uc_instance_rec.sn_tag_code);
  END IF;

  --mpothuku added on 13-Jul-2007 to fix the Bug 4337259
  IF(l_old_uc_instance_rec.sn_tag_code is not NULL AND l_old_uc_instance_rec.sn_tag_code IN ('ACTUAL','TEMPORARY')) THEN
    IF(l_uc_instance_rec.sn_tag_code is not NULL AND l_uc_instance_rec.sn_tag_code = 'INVENTORY') THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UC_SER_TG_EDIT_INVEN');
      FND_MSG_PUB.ADD;
    END IF;
  END IF;
  --mpothuku End

  --Validate Inventory Item details.
  validate_uc_invdetails(l_uc_instance_rec.inventory_item_id,
                         l_uc_instance_rec.inventory_org_id,
                         l_uc_instance_rec.serial_number,
                         l_uc_instance_rec.sn_tag_code,
                         l_uc_instance_rec.quantity,
                         l_uc_instance_rec.uom_code,
                         l_uc_instance_rec.revision,
                         l_uc_instance_rec.lot_number,
                         NULL,
                         l_concatenated_segments);

  --dbms_output.put_line('after validating invdetails');
  --Validate positional attributes.
  /*
  AHL_UTIL_UC_PKG.validate_for_position(l_uc_instance_rec.relationship_id,
                                        l_uc_instance_rec.inventory_item_id,
                                        l_uc_instance_rec.inventory_org_id,
                                        l_uc_instance_rec.quantity,
                                        l_uc_instance_rec.revision,
                                        l_uc_instance_rec.uom_code,
                                        NULL,
                                        l_item_assoc_id);
  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  */
  --Validate Installation Date.
  --Removed this validation after Alex talking to Barry. Because in UC we don't provide any
  --way for the user to update the installation date. (04/21/2004)
  /*
  IF (l_uc_instance_rec.install_date IS NOT NULL AND
      l_uc_instance_rec.install_date <> FND_API.G_MISS_DATE) THEN
    IF (l_uc_instance_rec.install_date > SYSDATE) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UC_INSTDATE_INVALID');
      FND_MESSAGE.Set_Token('DATE',l_uc_instance_rec.install_date);
      FND_MESSAGE.Set_Token('INV_ITEM',l_concatenated_segments);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Installation date invalid.');
    END IF;
  END IF;
  */

  --Validate mfg_date if not null.
  IF (l_uc_instance_rec.mfg_date IS NOT NULL AND l_uc_instance_rec.mfg_date <> FND_API.G_MISS_DATE) THEN
    IF (l_uc_instance_rec.mfg_date > SYSDATE) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UC_MFGDATE_INVALID');
      FND_MESSAGE.Set_Token('DATE',l_uc_instance_rec.mfg_date);
      FND_MESSAGE.Set_Token('INV_ITEM',l_concatenated_segments);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Mfg date invalid.');
    END IF;
  END IF;

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Retrieve existing value of sn_tag_code if present.
  AHL_UTIL_UC_PKG.getcsi_attribute_value(l_uc_instance_rec.instance_id,
                                         'AHL_TEMP_SERIAL_NUM',
                                         l_attribute_value,
                                         l_attribute_value_id,
                                         l_object_version_number,
                                         l_return_val);
  IF l_return_val THEN
    l_sn_tag_code := l_attribute_value;
    l_sn_tag_rec_found := 'Y';
  ELSE
    l_sn_tag_code := null;
    l_sn_tag_rec_found := 'N';
  END IF;
  --dbms_output.put_line('After get serial tag code');

  --Build extended attribute record for sn_tag_code.
  IF (l_sn_tag_rec_found = 'Y' ) THEN
    /* This IF condition is not necessary
    IF (l_uc_instance_rec.sn_tag_code IS NULL AND l_sn_tag_code IS NOT NULL) OR
       (l_sn_tag_code IS NULL AND l_uc_instance_rec.sn_tag_code IS NOT NULL) OR
       (l_uc_instance_rec.sn_tag_code IS NOT NULL AND l_sn_tag_code IS NOT NULL AND
        l_uc_instance_rec.sn_tag_code <> FND_API.G_MISS_CHAR AND
        l_uc_instance_rec.sn_tag_code <> l_sn_tag_code) THEN
    */
      --Changed value so update attribute record.
      l_csi_extend_attrib_rec.attribute_value_id := l_attribute_value_id;
      l_csi_extend_attrib_rec.attribute_value := l_uc_instance_rec.sn_tag_code;
      l_csi_extend_attrib_rec.object_version_number := l_object_version_number;
      l_subscript := l_subscript + 1;
      l_csi_ext_attrib_values_tbl(l_subscript) := l_csi_extend_attrib_rec;
    --END IF;
  ELSIF (l_sn_tag_rec_found = 'N') THEN
    IF (l_uc_instance_rec.sn_tag_code IS NOT NULL) THEN
      -- create extended attributes.
      AHL_Util_UC_Pkg.getcsi_attribute_id('AHL_TEMP_SERIAL_NUM', l_attribute_id,l_return_val);
      IF NOT(l_return_val) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
        FND_MESSAGE.Set_Token('CODE', 'AHL_TEMP_SERIAL_NUM');
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Attribute code for TEMP_SERIAL_NUM not found');
      ELSE
        l_csi_extend_attrib_rec1.attribute_id := l_attribute_id;
        l_csi_extend_attrib_rec1.attribute_value := l_uc_instance_rec.sn_tag_code;
        l_csi_extend_attrib_rec1.instance_id := l_uc_instance_rec.instance_id;
        l_subscript1 := l_subscript1 + 1;
        l_csi_ext_attrib_values_tbl1(l_subscript1) := l_csi_extend_attrib_rec1;
      END IF;
    END IF;
  END IF;

  --Retrieve existing value of manufacturing date if present.
  AHL_UTIL_UC_PKG.getcsi_attribute_value(l_uc_instance_rec.instance_id,
                                         'AHL_MFG_DATE',
                                         l_attribute_value,
                                         l_attribute_value_id,
                                         l_object_version_number,
                                         l_return_val);
  --Adding exception part in case l_attribute_value without an valid DATE fromat
  BEGIN
    IF NOT(l_return_val) THEN
      l_mfg_date := null;
      l_mfg_date_rec_found := 'N';
    ELSE
      l_mfg_date := to_date(l_attribute_value, 'DD/MM/YYYY');
      l_mfg_date_rec_found := 'Y';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UC_MFGDATE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;
  --dbms_output.put_line('after get mfg_date');

  --Build extended attribs record for mfg_date.
  IF (l_mfg_date_rec_found = 'Y' ) THEN
    /* This IF condition is not necessary
    IF (l_uc_instance_rec.mfg_date IS NULL AND l_mfg_date IS NOT NULL) OR
       (l_mfg_date IS NULL AND l_uc_instance_rec.mfg_date IS NOT NULL) OR
       (l_uc_instance_rec.mfg_date IS NOT NULL AND l_mfg_date IS NOT NULL AND
        l_uc_instance_rec.mfg_date <> FND_API.G_MISS_DATE AND
        l_uc_instance_rec.mfg_date <> l_mfg_date) THEN
    */
      --Changed value so update attribute record.
      l_csi_extend_attrib_rec.attribute_value_id := l_attribute_value_id;
      l_csi_extend_attrib_rec.attribute_value := to_char(l_uc_instance_rec.mfg_date, 'DD/MM/YYYY');
      l_csi_extend_attrib_rec.object_version_number := l_object_version_number;
      l_subscript := l_subscript + 1;
      l_csi_ext_attrib_values_tbl(l_subscript) := l_csi_extend_attrib_rec;
    --END IF;
  ELSIF (l_mfg_date_rec_found = 'N' ) THEN
    IF (l_uc_instance_rec.mfg_date IS NOT NULL) THEN
      AHL_Util_UC_Pkg.getcsi_attribute_id('AHL_MFG_DATE', l_attribute_id, l_return_val);
      IF NOT(l_return_val) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
        FND_MESSAGE.Set_Token('CODE', 'AHL_MFG_DATE');
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Attribute code for AHL_MFG_DATE not found');
      ELSE
        l_csi_extend_attrib_rec1.attribute_id := l_attribute_id;
        l_csi_extend_attrib_rec1.attribute_value := to_char(l_uc_instance_rec.mfg_date, 'DD/MM/YYYY');
        l_subscript1 := l_subscript1 + 1;
        l_csi_extend_attrib_rec1.instance_id := l_uc_instance_rec.instance_id;
        l_csi_ext_attrib_values_tbl1(l_subscript1) := l_csi_extend_attrib_rec1;
      END IF;
    END IF;
  END IF;

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Update item.
  l_csi_instance_rec.instance_id := l_uc_instance_rec.instance_id;
  l_csi_instance_rec.object_version_number := l_uc_instance_rec.object_version_number;
  l_csi_instance_rec.quantity := l_uc_instance_rec.quantity;
  l_csi_instance_rec.lot_number := l_uc_instance_rec.lot_number;
  l_csi_instance_rec.serial_number := l_uc_instance_rec.serial_number;
  l_csi_instance_rec.unit_of_measure := l_uc_instance_rec.uom_code;
  l_csi_instance_rec.inventory_revision := l_uc_instance_rec.revision;
  l_csi_instance_rec.install_date := l_uc_instance_rec.install_date;

  -- SATHAPLI::FP ER 6453212, 10-Nov-2008
  -- populate the flexfield data in the CSI record
  l_csi_instance_rec.context     := l_uc_instance_rec.context;
  l_csi_instance_rec.attribute1  := l_uc_instance_rec.attribute1;
  l_csi_instance_rec.attribute2  := l_uc_instance_rec.attribute2;
  l_csi_instance_rec.attribute3  := l_uc_instance_rec.attribute3;
  l_csi_instance_rec.attribute4  := l_uc_instance_rec.attribute4;
  l_csi_instance_rec.attribute5  := l_uc_instance_rec.attribute5;
  l_csi_instance_rec.attribute6  := l_uc_instance_rec.attribute6;
  l_csi_instance_rec.attribute7  := l_uc_instance_rec.attribute7;
  l_csi_instance_rec.attribute8  := l_uc_instance_rec.attribute8;
  l_csi_instance_rec.attribute9  := l_uc_instance_rec.attribute9;
  l_csi_instance_rec.attribute10 := l_uc_instance_rec.attribute10;
  l_csi_instance_rec.attribute11 := l_uc_instance_rec.attribute11;
  l_csi_instance_rec.attribute12 := l_uc_instance_rec.attribute12;
  l_csi_instance_rec.attribute13 := l_uc_instance_rec.attribute13;
  l_csi_instance_rec.attribute14 := l_uc_instance_rec.attribute14;
  l_csi_instance_rec.attribute15 := l_uc_instance_rec.attribute15;
  l_csi_instance_rec.attribute16 := l_uc_instance_rec.attribute16;
  l_csi_instance_rec.attribute17 := l_uc_instance_rec.attribute17;
  l_csi_instance_rec.attribute18 := l_uc_instance_rec.attribute18;
  l_csi_instance_rec.attribute19 := l_uc_instance_rec.attribute19;
  l_csi_instance_rec.attribute20 := l_uc_instance_rec.attribute20;
  l_csi_instance_rec.attribute21 := l_uc_instance_rec.attribute21;
  l_csi_instance_rec.attribute22 := l_uc_instance_rec.attribute22;
  l_csi_instance_rec.attribute23 := l_uc_instance_rec.attribute23;
  l_csi_instance_rec.attribute24 := l_uc_instance_rec.attribute24;
  l_csi_instance_rec.attribute25 := l_uc_instance_rec.attribute25;
  l_csi_instance_rec.attribute26 := l_uc_instance_rec.attribute26;
  l_csi_instance_rec.attribute27 := l_uc_instance_rec.attribute27;
  l_csi_instance_rec.attribute28 := l_uc_instance_rec.attribute28;
  l_csi_instance_rec.attribute29 := l_uc_instance_rec.attribute29;
  l_csi_instance_rec.attribute30 := l_uc_instance_rec.attribute30;

  --dbms_output.put_line('The new csi rec is as following:');
  --dbms_output.put_line('instance_id = '||l_csi_instance_rec.instance_id);
  --dbms_output.put_line('obj_ver_num = '||l_csi_instance_rec.object_version_number);
  --dbms_output.put_line('serial_no = '||l_csi_instance_rec.serial_number);
  --dbms_output.put_line('lot_no = '||l_csi_instance_rec.lot_number);
  --dbms_output.put_line('quantity = '||l_csi_instance_rec.quantity);
  --dbms_output.put_line('uom_code = '||l_csi_instance_rec.unit_of_measure);
  --dbms_output.put_line('install_date = '||l_csi_instance_rec.install_date);
  --dbms_output.put_line('revision = '||l_csi_instance_rec.inventory_revision);

--  IF (l_uc_instance_rec.sn_tag_code = 'INVENTORY') THEN
--    l_csi_instance_rec.mfg_serial_number_flag := 'Y';
--  ELSE
--  Changed by jaramana on April 26, 2005,
--  As per request from IB team (Briestly Manesh), always setting to N
    l_csi_instance_rec.mfg_serial_number_flag := 'N';
--  END IF;

  --Build CSI transaction record
  --First get transaction_type_id
  AHL_Util_UC_Pkg.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_val);

  IF NOT(l_return_val) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;

  /**
    Added by jaramana on April 26, 2005.
    Throw an exception if there are error messages even before calling
    the CSI APIs since the CSI API returns a Confirmation/Warning message
    even when the return status is S when the serial number is changed.
  **/
  --Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'l_msg_count='||l_msg_count||' x_return_status='||x_return_status);
  END IF;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  /** End addition by jaramana **/

  --Call CSI API to update instance attributes.
  CSI_ITEM_INSTANCE_PUB.update_item_instance(
                       p_api_version            => 1.0,
                       p_instance_rec           => l_csi_instance_rec,
                       p_txn_rec                => l_csi_transaction_rec,
                       p_ext_attrib_values_tbl  => l_csi_ext_attrib_values_tbl,
                       p_party_tbl              => l_csi_party_tbl,
                       p_account_tbl            => l_csi_account_tbl,
                       p_pricing_attrib_tbl     => l_csi_pricing_attrib_tbl,
                       p_org_assignments_tbl    => l_csi_org_assignments_tbl,
                       p_asset_assignment_tbl   => l_csi_asset_assignment_tbl,
                       x_instance_id_lst        => l_csi_instance_id_lst,
                       x_return_status          => l_return_status,
                       x_msg_count              => l_msg_count,
                       x_msg_data               => l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Create extended attributes if applicable.
  IF (l_subscript1 > 0) THEN
    --Call CSI API to create extended attributes.
    CSI_ITEM_INSTANCE_PUB.create_extended_attrib_values(
                          p_api_version            => 1.0,
                          p_txn_rec                => l_csi_transaction_rec,
                          p_ext_attrib_tbl         => l_csi_ext_attrib_values_tbl1,
                          x_return_status          => l_return_status,
                          x_msg_count              => l_msg_count,
                          x_msg_data               => l_msg_data);

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --For UC user, UC header status change needs to be made after the operation
  --Not confirmed whether need to copy the record into UC header history table
  --after status change. Not include the copy right now. (No)
  IF p_prod_user_flag = 'N' THEN
    IF l_root_uc_status_code = 'COMPLETE' THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code = 'INCOMPLETE' AND
           (l_root_active_uc_status_code IS NULL OR
            l_root_active_uc_status_code <> 'UNAPPROVED')) THEN
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE', 'DRAFT')) THEN
    --IF unit_config_status_code='DRAFT', this update is only object_version_number change and
    --not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'DRAFT',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF; --For production user, no need to change any one of the status.
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;


  /* Commented out by jaramana on April 26, 2005.
     Moved this to the location before calling the CSI API sinc the CSI API
     returns a Confirmation/Warning Message even when the status is S
     while changing the serial number.
  --Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'l_msg_count='||l_msg_count||' x_return_status='||x_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  */

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  --Count and Get messages(optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to update_instance_attr;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to update_instance_attr;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK to update_instance_attr;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Define procedure install_new_instance
-- This API is used to create a new instance in csi_item_instances and assign it
-- to a UC node.
PROCEDURE install_new_instance(
  p_api_version           IN NUMBER := 1.0,
  p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN NUMBER,
  p_parent_instance_id    IN NUMBER,
  p_prod_user_flag        IN VARCHAR2,
  p_x_uc_instance_rec     IN OUT NOCOPY uc_instance_rec_type,
  p_x_sub_uc_rec          IN OUT NOCOPY uc_header_rec_type,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type
)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'install_new_instance';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_subject_id                NUMBER;
  l_object_id                 NUMBER;
  l_csi_relationship_id       NUMBER;
  l_object_version_number     NUMBER;
  l_position_reference        csi_ii_relationships.position_reference%TYPE;
  l_sub_mc_header_id          NUMBER := NULL;
  l_top_relationship_id       NUMBER := NULL;
  l_position_id               NUMBER := NULL;
  l_parent_relationship_id    NUMBER;
  l_root_uc_header_id         NUMBER;
  l_root_instance_id          NUMBER;
  l_root_uc_status_code       FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_uc_ovn               NUMBER;
  l_root_instance_ou          NUMBER;
  l_new_instance_ou           NUMBER;
  l_uc_status_code            FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_active_uc_status_code     FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_dummy                     NUMBER;
  l_dummy_char                VARCHAR2(1);
  i                           NUMBER := 0;
  l_transaction_type_id       NUMBER;
  l_return_val                BOOLEAN;
  l_attribute_value_id        NUMBER;
  l_attribute_value           csi_iea_values.attribute_value%TYPE;
  l_attribute_id              NUMBER;
  l_subscript                 NUMBER DEFAULT 0;
  l_concatenated_segments     mtl_system_items_kfv.concatenated_segments%TYPE;
  l_item_assoc_id             NUMBER;
  l_new_instance_id           NUMBER;
  l_new_csi_instance_ovn      NUMBER;
  l_parent_uc_header_id       NUMBER;
  l_parent_instance_id        NUMBER;
  l_position_ref_meaning      fnd_lookups.meaning%TYPE;
  l_interchange_type_code     ahl_item_associations_b.interchange_type_code%TYPE;
  l_interchange_reason        ahl_item_associations_tl.interchange_reason%TYPE;

  --Variables needed for CSI API call
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_party_rec             csi_datastructures_pub.party_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_party_tbl             csi_datastructures_pub.party_tbl;
  l_csi_account_tbl           csi_datastructures_pub.party_account_tbl;
  l_csi_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
  l_csi_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
  l_csi_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
  l_csi_instance_id_lst       csi_datastructures_pub.id_tbl;
  l_party_account_rec         csi_datastructures_pub.party_account_rec;
  l_csi_extend_attrib_rec     csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;

  CURSOR check_uc_header IS
    SELECT A.unit_config_header_id,
           A.object_version_number,
           A.unit_config_status_code,
           A.active_uc_status_code,
           A.csi_item_instance_id,
           B.relationship_id
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.unit_config_header_id = p_uc_header_id
       AND trunc(nvl(A.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND A.master_config_id = B.mc_header_id
       AND B.parent_relationship_id IS NULL;
  l_check_uc_header check_uc_header%ROWTYPE;
  CURSOR get_uc_descendants(c_instance_id NUMBER) IS
    SELECT relationship_id,
           object_version_number,
           object_id,
           subject_id,
           to_number(position_reference) position_id
      FROM csi_ii_relationships
START WITH object_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Cursor to check whether the c_parent_relationship_id is the parent of
  --c_child_relationshp_id or c_child_relationship_id's own parent as the top node of the sub-config
  --can be installed in c_parent_relationship_id
  CURSOR check_parent_relationship(c_child_relationship_id NUMBER, c_parent_relationship_id NUMBER) IS
    SELECT 'X'
      FROM ahl_mc_relationships
     WHERE relationship_id = c_child_relationship_id
       AND (parent_relationship_id = c_parent_relationship_id OR
            mc_header_id IN (SELECT mc_header_id
                               FROM ahl_mc_config_relations
                              WHERE relationship_id = c_parent_relationship_id
                                AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                                AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)));

  --Cursor to check whether c_parent_instance_id's child position c_relationship_id is empty
  CURSOR check_position_empty(c_parent_instance_id NUMBER, c_relationship_id NUMBER) IS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE object_id = c_parent_instance_id
       AND position_reference = to_char(c_relationship_id)
       AND subject_id IS NOT NULL
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR csi_item_instance_csr(c_csi_instance_id IN NUMBER) IS
    SELECT location_id,
           location_type_code,
           party_id,
           party_source_table,
           instance_party_id,
           csi.wip_job_id
      FROM csi_item_instances csi, csi_i_parties p
     WHERE csi.instance_id = p.instance_id
       AND p.relationship_type_code = 'OWNER'
       AND csi.instance_id = c_csi_instance_id
       AND trunc(SYSDATE) < trunc(nvl(csi.active_end_date, SYSDATE+1));
  l_uc_owner_loc_rec          csi_item_instance_csr%ROWTYPE;

  CURSOR csi_ip_accounts_csr(c_instance_party_id IN NUMBER) IS
    SELECT party_account_id
      FROM csi_ip_accounts
     WHERE relationship_type_code = 'OWNER'
       AND instance_party_id = c_instance_party_id
       AND trunc(SYSDATE) >= trunc(nvl(active_start_date, SYSDATE))
       AND trunc(SYSDATE) < trunc(nvl(active_end_date, SYSDATE+1));

  --Cursor to check the uniqueness of the sub unit
  CURSOR check_uc_name_unique(c_uc_name VARCHAR2) IS
    SELECT 'X'
      FROM ahl_unit_config_headers
     WHERE name = c_uc_name
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  --Cursor to check the validatiy of the mc_header_id (for sub config) according to the mc_name, mc_revision and
  --relationship_id (in parent MC)
  CURSOR get_sub_mc_header(c_mc_name VARCHAR2, c_mc_revision VARCHAR2, c_relationship_id NUMBER) IS
    SELECT H.mc_header_id,
           R.relationship_id
      FROM ahl_mc_headers_b H,
           ahl_mc_relationships R
     WHERE H.mc_header_id = R.mc_header_id
       AND R.parent_relationship_id IS NULL
       AND trunc(nvl(R.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND H.name = c_mc_name
       AND H.revision = c_mc_revision
       AND H.mc_header_id IN (SELECT mc_header_id
                              FROM ahl_mc_config_relations
                             WHERE relationship_id = c_relationship_id
                               AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                               AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE));

  -- SATHAPLI::ER 7419780, 24-Aug-2009, fetch the INTERCHANGE_REASON from the table ahl_item_associations_tl too
  CURSOR get_interchange_type (c_instance_id NUMBER, c_relationship_id NUMBER) IS
    SELECT i.interchange_type_code,
           itl.interchange_reason
      FROM csi_item_instances c,
           ahl_item_associations_b i,
           ahl_item_associations_tl itl,
           ahl_mc_relationships m
     WHERE m.relationship_id = c_relationship_id
       AND c.instance_id = c_instance_id
       AND m.item_group_id = i.item_group_id
       AND c.inventory_item_id = i.inventory_item_id
       AND c.inv_master_organization_id = i.inventory_org_id
       AND itl.item_association_id = i.item_association_id
       AND itl.language = USERENV('LANG')
       AND (c.inventory_revision IS NULL OR
            i.revision is NULL OR
            (c.inventory_revision IS NOT NULL AND
             i.revision IS NOT NULL AND
             c.inventory_revision = i.revision));
   --Added this last condition due to the impact of bug fixing 4102152, added by Jerry on 01/05/2005
   --Need to confirm which one is more accurate here to use c.inv_master_organization_id or
   --c.last_vld_organization_id

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT install_new_instance;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  --Validate input parameters p_prod_user_flag
  IF upper(p_prod_user_flag) <> 'Y' AND upper(p_prod_user_flag) <> 'N' THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'prod_user_flag');
    FND_MESSAGE.set_token('VALUE', p_prod_user_flag);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Validate input parameter p_uc_header_id, its two statuses
  OPEN check_uc_header;
  FETCH check_uc_header INTO l_check_uc_header;
  IF check_uc_header%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_uc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    -- ACL :: Changes for R12
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ahl_util_uc_pkg.get_root_uc_attr(p_uc_header_id,
                                     l_root_uc_header_id,
                                     l_root_instance_id,
                                     l_root_uc_status_code,
                                     l_root_active_uc_status_code,
                                     l_root_uc_ovn);
    IF (p_prod_user_flag = 'Y' AND --For production user, no need to confirm either one of the statuses is not APPROVAL_PENDING
        l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_NOT_ACTIVE' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (p_prod_user_flag = 'N' AND
           (l_root_uc_status_code = 'APPROVAL_PENDING' OR
            l_root_active_uc_status_code = 'APPROVAL_PENDING')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_PENDING' );
      FND_MESSAGE.set_token( 'UC_HEADER_ID', l_root_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_uc_header;
    END IF;
  END IF;

  --Get the operating unit of the root instance.
  l_root_instance_ou := get_operating_unit(l_root_instance_id);

  --Make sure p_parent_instance_id is installed in the UC
  IF p_parent_instance_id = l_check_uc_header.csi_item_instance_id THEN
    --The parent instance is the root node
    l_parent_relationship_id := l_check_uc_header.relationship_id;
  ELSE
    FOR l_get_uc_descendant IN get_uc_descendants(l_check_uc_header.csi_item_instance_id) LOOP
      l_csi_relationship_id := l_get_uc_descendant.relationship_id;
      l_object_version_number := l_get_uc_descendant.object_version_number;
      l_object_id := l_get_uc_descendant.object_id;
      l_subject_id := l_get_uc_descendant.subject_id;
      l_parent_relationship_id := l_get_uc_descendant.position_id;
      EXIT WHEN l_subject_id = p_parent_instance_id;
    END LOOP;
    --Ensure the instance is installed in this UC and not an extra node
    IF (l_subject_id <> p_parent_instance_id OR
        p_parent_instance_id IS NULL OR
        l_subject_id IS NULL OR
        l_parent_relationship_id IS NULL) THEN
      --Do we allow an extra node's attributes to be changed?
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_NOT_IN_UC' );
      FND_MESSAGE.set_token('INSTANCE', p_parent_instance_id);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --Then validate p_x_uc_instance_rec.relationship_id can be child of l_parent_relationship_id
  OPEN check_parent_relationship(p_x_uc_instance_rec.relationship_id, l_parent_relationship_id);
  FETCH check_parent_relationship INTO l_dummy_char;
  IF check_parent_relationship%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_MISMATCH' );
    FND_MESSAGE.set_token('CHILD', p_x_uc_instance_rec.relationship_id);
    FND_MESSAGE.set_token('PARENT', l_parent_relationship_id);
    FND_MSG_PUB.add;
    CLOSE check_parent_relationship;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_parent_relationship;
  END IF;

  --Make sure position p_x_uc_instance_rec.relationship_id is empty
  OPEN check_position_empty(p_parent_instance_id, p_x_uc_instance_rec.relationship_id);
  FETCH check_position_empty INTO l_dummy;
  IF check_position_empty%FOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_INSTALLED' );
    FND_MESSAGE.set_token('POSITION', p_x_uc_instance_rec.relationship_id);
    FND_MSG_PUB.add;
    CLOSE check_position_empty;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_position_empty;
  END IF;
  --When creating the new instances, the "From Inventory" Serial Tag should not be used anymore.
  --mpothuku added on 13-Jul-2007 to fix the Bug 4337259
  IF(p_x_uc_instance_rec.sn_tag_code is not null AND p_x_uc_instance_rec.sn_tag_code = 'INVENTORY') THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_SER_TG_CR_INVEN' );
    FND_MSG_PUB.add;
  END IF;
  --mpothuku End

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Validate Inventory details.
  validate_uc_invdetails (p_x_uc_instance_rec.inventory_item_id,
                          p_x_uc_instance_rec.inventory_org_id,
                          p_x_uc_instance_rec.serial_number,
                          p_x_uc_instance_rec.sn_tag_code,
                          p_x_uc_instance_rec.quantity,
                          p_x_uc_instance_rec.uom_code,
                          p_x_uc_instance_rec.revision,
                          p_x_uc_instance_rec.lot_number,
                          NULL,
                          l_concatenated_segments);

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Check all sub mc_name, mc_revision and uc_name are NULL or NOT NULL
  IF (p_x_sub_uc_rec.mc_name IS NOT NULL AND (p_x_sub_uc_rec.mc_revision IS NULL OR
                                                p_x_sub_uc_rec.uc_name IS NULL) OR
      p_x_sub_uc_rec.mc_revision IS NOT NULL AND (p_x_sub_uc_rec.mc_name IS NULL OR
                                                p_x_sub_uc_rec.uc_name IS NULL) OR
      p_x_sub_uc_rec.uc_name IS NOT NULL AND (p_x_sub_uc_rec.mc_revision IS NULL OR
                                                p_x_sub_uc_rec.mc_name IS NULL))
  THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_SUB_UNIT_INFO_MISSING');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Check the sub unit name is unique
  IF p_x_sub_uc_rec.uc_name IS NOT NULL THEN
    OPEN check_uc_name_unique(p_x_sub_uc_rec.uc_name);
    FETCH check_uc_name_unique INTO l_dummy_char;
    IF check_uc_name_unique%FOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_NAME_DUPLICATE');
      FND_MESSAGE.set_token('NAME', p_x_sub_uc_rec.uc_name);
      FND_MSG_PUB.add;
      CLOSE check_uc_name_unique;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE check_uc_name_unique;
    END IF;
  END IF;

  --Derive mc_header_id from mc_name and mc_revision
  IF p_x_sub_uc_rec.mc_name IS NOT NULL THEN
    OPEN get_sub_mc_header(p_x_sub_uc_rec.mc_name,
                           p_x_sub_uc_rec.mc_revision,
                           p_x_uc_instance_rec.relationship_id);
    FETCH get_sub_mc_header INTO l_sub_mc_header_id, l_top_relationship_id;
    IF get_sub_mc_header%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_SUB_MC_INVALID');
      FND_MESSAGE.set_token('NAME', p_x_sub_uc_rec.mc_name);
      FND_MESSAGE.set_token('REVISION', p_x_sub_uc_rec.mc_revision);
      FND_MSG_PUB.add;
      CLOSE get_sub_mc_header;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE get_sub_mc_header;
    END IF;
  END IF;

  IF (l_top_relationship_id IS NOT NULL) THEN
    l_position_id := l_top_relationship_id;
  ELSE
    l_position_id := p_x_uc_instance_rec.relationship_id;
  END IF;

  --Validate whether an item can be installed into a position, the position refers to the
  --top node position in the sub UC if sub UC information is provided otherwise it refers
  --to the position from Parent UC.
  AHL_UTIL_UC_PKG.validate_for_position(l_position_id,
                                        p_x_uc_instance_rec.inventory_Item_id,
                                        p_x_uc_instance_rec.inventory_Org_id,
                                        p_x_uc_instance_rec.quantity,
                                        p_x_uc_instance_rec.revision,
                                        p_x_uc_instance_rec.uom_code,
                                        NULL,
                                        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
                                        -- Pass 'N' for p_ignore_quant_vald.
                                        'N',
                                        l_item_assoc_id);

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Validate manufacturing date.
  IF (p_x_uc_instance_rec.mfg_date IS NOT NULL AND
      p_x_uc_instance_rec.mfg_date <> FND_API.G_MISS_DATE) THEN
    IF (p_x_uc_instance_rec.mfg_date > SYSDATE) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_MFGDATE_INVALID');
      FND_MESSAGE.set_token('DATE',p_x_uc_instance_rec.mfg_date);
      FND_MESSAGE.set_token('INV_ITEM',l_concatenated_segments);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Mfg date invalid.');
    END IF;
  END IF;

  --Validate installation date.
  --Keep the installation date validation only for production user (04/21/2004)
  IF (p_x_uc_instance_rec.install_date IS NOT NULL AND
      p_x_uc_instance_rec.install_date <> FND_API.G_MISS_DATE) THEN
    IF (p_prod_user_flag = 'Y' AND trunc(p_x_uc_instance_rec.install_date) > trunc(SYSDATE)) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_INSTDATE_INVALID');
      FND_MESSAGE.set_token('DATE',p_x_uc_instance_rec.install_date);
      FND_MESSAGE.set_token('POSN_REF',p_x_uc_instance_rec.relationship_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Installation date invalid.');
    END IF;
  END IF;

  -- Build CSI records and call API.
  -- First get unit config location and owner details.
  OPEN csi_item_instance_csr(p_parent_instance_id);
  FETCH csi_item_instance_csr INTO l_uc_owner_loc_rec;
  IF (csi_item_instance_csr%NOTFOUND) THEN
    CLOSE csi_item_instance_csr;
    FND_MESSAGE.set_name('AHL','AHL_UC_CSII_INVALID');
    FND_MESSAGE.set_token('CSII',p_parent_instance_id);
    FND_MESSAGE.Set_Token('POSN_REF',p_x_uc_instance_rec.relationship_id);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Top node item instance does not exist.');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE csi_item_instance_csr;

  --Set csi instance record
  l_csi_instance_rec.inventory_item_id := p_x_uc_instance_rec.inventory_item_id;
  l_csi_instance_rec.vld_organization_id := p_x_uc_instance_rec.inventory_org_id;
  l_csi_instance_rec.quantity := p_x_uc_instance_rec.quantity;
  l_csi_instance_rec.unit_of_measure := p_x_uc_instance_rec.uom_code;
  l_csi_instance_rec.install_date := p_x_uc_instance_rec.install_date;
  l_csi_instance_rec.location_id := l_uc_owner_loc_rec.location_id;
  l_csi_instance_rec.location_type_code := l_uc_owner_loc_rec.location_type_code;

  --In case item is in WIP; copy the parent WIP job ID to the component.
  l_csi_instance_rec.wip_job_id := l_uc_owner_loc_rec.wip_job_id;
--  IF (p_x_uc_instance_rec.sn_tag_code = 'INVENTORY') THEN
--    l_csi_instance_rec.mfg_serial_number_flag := 'Y';
--  ELSE
--  Changed by jaramana on April 26, 2005,
--  As per request from IB team (Briestly Manesh), always setting to N
    l_csi_instance_rec.mfg_serial_number_flag := 'N';
--  END IF;

  IF (p_x_uc_instance_rec.serial_number IS NOT NULL AND
      p_x_uc_instance_rec.serial_number <> FND_API.G_MISS_CHAR)  THEN
    l_csi_instance_rec.serial_number := p_x_uc_instance_rec.serial_number;
  END IF;

  IF (p_x_uc_instance_rec.lot_number IS NOT NULL AND
      p_x_uc_instance_rec.lot_number <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.lot_number := p_x_uc_instance_rec.lot_number;
  END IF;

  IF (p_x_uc_instance_rec.revision IS NOT NULL AND
      p_x_uc_instance_rec.revision <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.inventory_revision := p_x_uc_instance_rec.revision;
  END IF;

  --l_csi_instance_rec.instance_usage_code := 'IN_SERVICE';
  l_csi_instance_rec.instance_usage_code := NULL;

  -- SATHAPLI::FP ER 6453212, 10-Nov-2008
  -- populate the flexfield data in the CSI record
  IF (p_x_uc_instance_rec.context IS NOT NULL AND
      p_x_uc_instance_rec.context <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.context := p_x_uc_instance_rec.context;
  END IF;

  IF (p_x_uc_instance_rec.attribute1 IS NOT NULL AND
      p_x_uc_instance_rec.attribute1 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute1 := p_x_uc_instance_rec.attribute1;
  END IF;

  IF (p_x_uc_instance_rec.attribute2 IS NOT NULL AND
      p_x_uc_instance_rec.attribute2 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute2 := p_x_uc_instance_rec.attribute2;
  END IF;

  IF (p_x_uc_instance_rec.attribute3 IS NOT NULL AND
      p_x_uc_instance_rec.attribute3 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute3 := p_x_uc_instance_rec.attribute3;
  END IF;

  IF (p_x_uc_instance_rec.attribute4 IS NOT NULL AND
      p_x_uc_instance_rec.attribute4 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute4 := p_x_uc_instance_rec.attribute4;
  END IF;

  IF (p_x_uc_instance_rec.attribute5 IS NOT NULL AND
      p_x_uc_instance_rec.attribute5 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute5 := p_x_uc_instance_rec.attribute5;
  END IF;

  IF (p_x_uc_instance_rec.attribute6 IS NOT NULL AND
      p_x_uc_instance_rec.attribute6 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute6 := p_x_uc_instance_rec.attribute6;
  END IF;

  IF (p_x_uc_instance_rec.attribute7 IS NOT NULL AND
      p_x_uc_instance_rec.attribute7 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute7 := p_x_uc_instance_rec.attribute7;
  END IF;

  IF (p_x_uc_instance_rec.attribute8 IS NOT NULL AND
      p_x_uc_instance_rec.attribute8 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute8 := p_x_uc_instance_rec.attribute8;
  END IF;

  IF (p_x_uc_instance_rec.attribute9 IS NOT NULL AND
      p_x_uc_instance_rec.attribute9 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute9 := p_x_uc_instance_rec.attribute9;
  END IF;

  IF (p_x_uc_instance_rec.attribute10 IS NOT NULL AND
      p_x_uc_instance_rec.attribute10 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute10 := p_x_uc_instance_rec.attribute10;
  END IF;

  IF (p_x_uc_instance_rec.attribute11 IS NOT NULL AND
      p_x_uc_instance_rec.attribute11 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute11 := p_x_uc_instance_rec.attribute11;
  END IF;

  IF (p_x_uc_instance_rec.attribute12 IS NOT NULL AND
      p_x_uc_instance_rec.attribute12 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute12 := p_x_uc_instance_rec.attribute12;
  END IF;

  IF (p_x_uc_instance_rec.attribute13 IS NOT NULL AND
      p_x_uc_instance_rec.attribute13 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute13 := p_x_uc_instance_rec.attribute13;
  END IF;

  IF (p_x_uc_instance_rec.attribute14 IS NOT NULL AND
      p_x_uc_instance_rec.attribute14 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute14 := p_x_uc_instance_rec.attribute14;
  END IF;

  IF (p_x_uc_instance_rec.attribute15 IS NOT NULL AND
      p_x_uc_instance_rec.attribute15 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute15 := p_x_uc_instance_rec.attribute15;
  END IF;

  IF (p_x_uc_instance_rec.attribute16 IS NOT NULL AND
      p_x_uc_instance_rec.attribute16 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute16 := p_x_uc_instance_rec.attribute16;
  END IF;

  IF (p_x_uc_instance_rec.attribute17 IS NOT NULL AND
      p_x_uc_instance_rec.attribute17 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute17 := p_x_uc_instance_rec.attribute17;
  END IF;

  IF (p_x_uc_instance_rec.attribute18 IS NOT NULL AND
      p_x_uc_instance_rec.attribute18 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute18 := p_x_uc_instance_rec.attribute18;
  END IF;

  IF (p_x_uc_instance_rec.attribute19 IS NOT NULL AND
      p_x_uc_instance_rec.attribute19 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute19 := p_x_uc_instance_rec.attribute19;
  END IF;

  IF (p_x_uc_instance_rec.attribute20 IS NOT NULL AND
      p_x_uc_instance_rec.attribute20 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute20 := p_x_uc_instance_rec.attribute20;
  END IF;

  IF (p_x_uc_instance_rec.attribute21 IS NOT NULL AND
      p_x_uc_instance_rec.attribute21 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute21 := p_x_uc_instance_rec.attribute21;
  END IF;

  IF (p_x_uc_instance_rec.attribute22 IS NOT NULL AND
      p_x_uc_instance_rec.attribute22 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute22 := p_x_uc_instance_rec.attribute22;
  END IF;

  IF (p_x_uc_instance_rec.attribute23 IS NOT NULL AND
      p_x_uc_instance_rec.attribute23 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute23 := p_x_uc_instance_rec.attribute23;
  END IF;

  IF (p_x_uc_instance_rec.attribute24 IS NOT NULL AND
      p_x_uc_instance_rec.attribute24 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute24 := p_x_uc_instance_rec.attribute24;
  END IF;

  IF (p_x_uc_instance_rec.attribute25 IS NOT NULL AND
      p_x_uc_instance_rec.attribute25 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute25 := p_x_uc_instance_rec.attribute25;
  END IF;

  IF (p_x_uc_instance_rec.attribute26 IS NOT NULL AND
      p_x_uc_instance_rec.attribute26 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute26 := p_x_uc_instance_rec.attribute26;
  END IF;

  IF (p_x_uc_instance_rec.attribute27 IS NOT NULL AND
      p_x_uc_instance_rec.attribute27 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute27 := p_x_uc_instance_rec.attribute27;
  END IF;

  IF (p_x_uc_instance_rec.attribute28 IS NOT NULL AND
      p_x_uc_instance_rec.attribute28 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute28 := p_x_uc_instance_rec.attribute28;
  END IF;

  IF (p_x_uc_instance_rec.attribute29 IS NOT NULL AND
      p_x_uc_instance_rec.attribute29 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute29 := p_x_uc_instance_rec.attribute29;
  END IF;

  IF (p_x_uc_instance_rec.attribute30 IS NOT NULL AND
      p_x_uc_instance_rec.attribute30 <> FND_API.G_MISS_CHAR) THEN
    l_csi_instance_rec.attribute30 := p_x_uc_instance_rec.attribute30;
  END IF;

  --Build csi extended attribs.
  IF (p_x_uc_instance_rec.mfg_date IS NOT NULL AND
      p_x_uc_instance_rec.mfg_date <> FND_API.G_MISS_DATE) THEN
    AHL_UTIL_UC_PKG.getcsi_attribute_id('AHL_MFG_DATE',l_attribute_id, l_return_val);
    IF NOT(l_return_val) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
      FND_MESSAGE.set_token('CODE', 'AHL_MFG_DATE');
      FND_MSG_PUB.add;
      --dbms_output.put_line('Attribute code for AHL_MFG_DATE not found');
    ELSE
      l_csi_extend_attrib_rec.attribute_id := l_attribute_id;
      l_csi_extend_attrib_rec.attribute_value := to_char(p_x_uc_instance_rec.mfg_date, 'DD/MM/YYYY');
      l_subscript := l_subscript + 1;
      l_csi_ext_attrib_values_tbl(l_subscript) := l_csi_extend_attrib_rec;
    END IF;
  END IF;

  IF (p_x_uc_instance_rec.serial_number IS NOT NULL AND
      p_x_uc_instance_rec.serial_number <> FND_API.G_MISS_CHAR) THEN
    AHL_UTIL_UC_PKG.getcsi_attribute_id('AHL_TEMP_SERIAL_NUM',l_attribute_id, l_return_val);

    IF NOT(l_return_val) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
      FND_MESSAGE.set_token('CODE', 'AHL_TEMP_SERIAL_NUM');
      FND_MSG_PUB.add;
      --dbms_output.put_line('Attribute code for TEMP_SERIAL_NUM not found');
    ELSE
      l_csi_extend_attrib_rec.attribute_id := l_attribute_id;
      l_csi_extend_attrib_rec.attribute_value := p_x_uc_instance_rec.sn_tag_code;
      l_csi_ext_attrib_values_tbl(l_subscript+1) := l_csi_extend_attrib_rec;
    END IF;
  END IF;

  --Build CSI party record.
  l_csi_party_rec.party_id := l_uc_owner_loc_rec.party_id;
  l_csi_party_rec.relationship_type_code := 'OWNER';
  l_csi_party_rec.party_source_table := l_uc_owner_loc_rec.party_source_table;
  l_csi_party_rec.contact_flag := 'N';
  l_csi_party_tbl(1) := l_csi_party_rec;

  --dbms_output.put_line('before build accounts:...');
  --Build CSI accounts table.
  FOR party_ip_acct IN csi_ip_accounts_csr(l_uc_owner_loc_rec.instance_party_id)
  LOOP
    l_party_account_rec.party_account_id := party_ip_acct.party_account_id;
    l_party_account_rec.relationship_type_code := 'OWNER';
    l_party_account_rec.parent_tbl_index := 1;
    i := i + 1;
    l_csi_account_tbl(i) := l_party_account_rec;
  END LOOP;

  --Build CSI transaction record, first get transaction_type_id
  AHL_Util_UC_Pkg.getcsi_transaction_id('UC_CREATE',l_transaction_type_id, l_return_val);

  IF NOT(l_return_val) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

   --Call CSI API to create instance
  CSI_ITEM_INSTANCE_PUB.create_item_instance(
                       p_api_version            => 1.0,
                       p_instance_rec           => l_csi_instance_rec,
                       p_txn_rec                => l_csi_transaction_rec,
                       p_ext_attrib_values_tbl  => l_csi_ext_attrib_values_tbl,
                       p_party_tbl              => l_csi_party_tbl,
                       p_account_tbl            => l_csi_account_tbl,
                       p_pricing_attrib_tbl     => l_csi_pricing_attrib_tbl,
                       p_org_assignments_tbl    => l_csi_org_assignments_tbl,
                       p_asset_assignment_tbl   => l_csi_asset_assignment_tbl,
                       x_return_status          => l_return_status,
                       x_msg_count              => l_msg_count,
                       x_msg_data               => l_msg_data);

  --Assign out parameters.

  l_new_instance_id := l_csi_instance_rec.instance_id;
  l_new_csi_instance_ovn := l_csi_instance_rec.object_version_number;
  p_x_uc_instance_rec.instance_id := l_new_instance_id;
  p_x_uc_instance_rec.object_version_number := l_new_csi_instance_ovn;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API',
                   ' After calling create_item_instance and instance_id = '||l_csi_instance_rec.instance_id||
                   ' l_return_status ='||l_return_status||
                   ' p_x_uc_instance_rec.instance_id='||p_x_uc_instance_rec.instance_id);
  END IF;

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Before installing the new instance, make sure its operating unit is exactly the same as that
  --of the root instance.
  l_new_instance_ou := get_operating_unit(l_new_instance_id);
  IF l_root_instance_ou IS NULL THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_NULL');
    FND_MESSAGE.set_token('INSTANCE', l_root_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_new_instance_ou IS NULL THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_NULL');
    FND_MESSAGE.set_token('INSTANCE', l_new_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_root_instance_ou <> l_new_instance_ou THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_UNMATCH');
    FND_MESSAGE.set_token('INSTANCE', l_new_instance_id);
    FND_MESSAGE.set_token('ROOT_INSTANCE', l_root_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Building csi_ii_relationship record should be after create_uc_header because create_uc_header
  --will validate the newly created instance, and this validation ensures that the instance is available
  --that is not in table csi_ii_realtionships and ahl_unit_config_headers
  --Build CSI relationships table
  l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
  l_csi_relationship_rec.object_id := p_parent_instance_id;
  l_csi_relationship_rec.position_reference := to_number(p_x_uc_instance_rec.relationship_id);
  l_csi_relationship_rec.subject_id := l_new_instance_id;
  l_csi_relationship_tbl(1) := l_csi_relationship_rec;

  CSI_II_RELATIONSHIPS_PUB.create_relationship(
                           p_api_version            => 1.0,
                           p_relationship_tbl       => l_csi_relationship_tbl,
                           p_txn_rec                => l_csi_transaction_rec,
                           x_return_status          => l_return_status,
                           x_msg_count              => l_msg_count,
                           x_msg_data               => l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Create the sub unit header record in ahl_unit_config_headers
  IF l_sub_mc_header_id IS NOT NULL THEN
    --Insert the newly added sub unit into UC headers table.
    p_x_sub_uc_rec.mc_header_id := l_sub_mc_header_id;
    p_x_sub_uc_rec.instance_id := l_new_instance_id;
    ahl_util_uc_pkg.get_parent_uc_header(l_new_instance_id,
                                         l_parent_uc_header_id,
                                         l_parent_instance_id);
    p_x_sub_uc_rec.parent_uc_header_id := l_parent_uc_header_id;
    --p_x_sub_uc_rec.parent_uc_header_id := p_uc_header_id;
    --The parameter p_uc_header_id is not necessarily the parent uc_header_id of the newly
    --installed instance.

    --dbms_output.put_line('Before calling create uc_header API:...');
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API',
                   ' p_x_sub_uc_rec.uc_header_id='||p_x_sub_uc_rec.uc_header_id||
                   ' p_x_sub_uc_rec.mc_header_id='||p_x_sub_uc_rec.mc_header_id||
                   ' p_x_sub_uc_rec.mc_name='||p_x_sub_uc_rec.mc_name||
                   ' p_x_sub_uc_rec.mc_revision='||p_x_sub_uc_rec.mc_revision||
                   ' p_x_sub_uc_rec.instance_id='||p_x_sub_uc_rec.instance_id||
                   ' p_x_sub_uc_rec.parent_uc_header_id='||p_x_sub_uc_rec.parent_uc_header_id);
    END IF;
    AHL_UC_UNITCONFIG_PVT.create_uc_header(
                            p_api_version        => 1.0,
                            p_init_msg_list      => FND_API.G_FALSE,
                            p_commit             => FND_API.G_FALSE,
                            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                            p_module_type        => NULL,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_x_uc_header_rec    => p_x_sub_uc_rec);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API',
                   ' p_x_sub_uc_rec.uc_header_id='||p_x_sub_uc_rec.uc_header_id||
                   ' p_x_sub_uc_rec.mc_header_id='||p_x_sub_uc_rec.mc_header_id||
                   ' p_x_sub_uc_rec.mc_name='||p_x_sub_uc_rec.mc_name||
                   ' p_x_sub_uc_rec.mc_revision='||p_x_sub_uc_rec.mc_revision||
                   ' p_x_sub_uc_rec.instance_id='||p_x_sub_uc_rec.instance_id||
                   ' p_x_sub_uc_rec.parent_uc_header_id='||p_x_sub_uc_rec.parent_uc_header_id);
    END IF;
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --dbms_output.put_line('After calling create uc_header API:...');

    --Copy the newly created UC header to history table
    ahl_util_uc_pkg.copy_uc_header_to_history(p_x_sub_uc_rec.uc_header_id, l_return_status);

    --IF history copy failed, then don't raise exception, just add the message to the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;

  END IF;

  --Call completeness check API for the newly assigned instance
  ahl_uc_validation_pub.validate_complete_for_pos(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_csi_instance_id     => p_x_uc_instance_rec.instance_id,
      x_error_tbl           => x_warning_msg_tbl);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --IF 1-WAY INTERCHANGEABLE item is installed, we will display the warning message to the user
  --This warning message is not added to the global message stack.
  -- SATHAPLI::ER 7419780, 24-Aug-2009, add the fetched INTERCHANGE_REASON as well, to the warning message AHL_UC_1WAY_ITEM_INSTALLED.

  IF p_x_sub_uc_rec.mc_header_id IS NOT NULL THEN
    OPEN get_interchange_type(p_x_uc_instance_rec.instance_id, l_top_relationship_id);
  ELSE
    OPEN get_interchange_type(p_x_uc_instance_rec.instance_id, p_x_uc_instance_rec.relationship_id);
  END IF;
  FETCH get_interchange_type INTO l_interchange_type_code, l_interchange_reason;
  IF get_interchange_type%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_ITEM_INTERCHANGE_MISS');
    FND_MESSAGE.set_token('INSTANCE', p_x_uc_instance_rec.instance_id);
    FND_MSG_PUB.add;
    CLOSE get_interchange_type;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_interchange_type_code = '1-WAY INTERCHANGEABLE' THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_1WAY_ITEM_INSTALLED');
    SELECT f.meaning INTO l_position_ref_meaning
      FROM ahl_mc_relationships a,
           fnd_lookups f
     WHERE a.relationship_id = p_x_uc_instance_rec.relationship_id
       AND f.lookup_code (+) = A.position_ref_code
       AND f.lookup_type (+) = 'AHL_POSITION_REFERENCE' ;
    --Here always use p_x_uc_instance_rec.relationship_id instead of l_top_relationship_id because
    --UC tree UI always displays the parent leaf relationship_id instead of sub-uc top relationship_id
    --when it comes to the sub-uc.
    FND_MESSAGE.set_token('POSITION', l_position_ref_meaning);
    FND_MESSAGE.set_token('REASON', l_interchange_reason);
    --Here the message is not added to the global message stack;
    IF x_warning_msg_tbl.count > 0 THEN
      x_warning_msg_tbl(x_warning_msg_tbl.last + 1) := FND_MESSAGE.get;
    ELSE
      x_warning_msg_tbl(0) := FND_MESSAGE.get;
    END IF;
  END IF;
  CLOSE get_interchange_type;

  --For UC user, UC header status change needs to be made after the operation
  --Not confirmed whether need to copy the record into UC header history table
  --after status change. Not include the copy right now. (No history copy)
  IF p_prod_user_flag = 'N' THEN
    IF (l_root_uc_status_code = 'COMPLETE' AND
        x_warning_msg_tbl.count > 0 ) THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code IN ('COMPLETE', 'INCOMPLETE') AND
           (l_root_active_uc_status_code IS NULL OR
            l_root_active_uc_status_code <> 'UNAPPROVED')) THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE', 'DRAFT')) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Before calling completeness check',
                   'p_uc_header_id='||p_uc_header_id||'l_root_uc_header_id='||l_root_uc_header_id||
                   'l_root_uc_ovn='||l_root_uc_ovn);
      END IF;
    --IF unit_config_status_code='DRAFT', this update is only object_version_number change and
    --not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'DRAFT',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  ELSIF (p_prod_user_flag = 'Y' AND
         x_warning_msg_tbl.count > 0 AND
         l_root_uc_status_code = 'COMPLETE') THEN
    UPDATE ahl_unit_config_headers
       SET unit_config_status_code = 'INCOMPLETE',
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
     WHERE unit_config_header_id = l_root_uc_header_id
       AND object_version_number = l_root_uc_ovn;
    IF SQL%ROWCOUNT = 0 THEN
      FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;

  --Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  --Count and Get messages(optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO install_new_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO install_new_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO install_new_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Define procedure install_existing_instance
-- This API is used to assign an existing instance to a UC node.
PROCEDURE install_existing_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_parent_instance_id    IN  NUMBER,
  p_instance_id           IN  NUMBER,
  p_instance_number       IN  csi_item_instances.instance_number%TYPE := NULL,
  p_relationship_id       IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'install_existing_instance';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_subject_id                NUMBER;
  l_object_id                 NUMBER;
  l_csi_relationship_id       NUMBER;
  l_object_version_number     NUMBER;
  l_position_reference        csi_ii_relationships.position_reference%TYPE;
  l_mc_header_id              NUMBER;
  l_sub_uc_header_id          NUMBER;
  l_parent_relationship_id    NUMBER;
  l_instance_type             VARCHAR2(1);
  l_dummy                     NUMBER;
  l_dummy_char                VARCHAR2(1);
  l_subunit                   BOOLEAN;
  i                           NUMBER := 0;
  l_subscript                 NUMBER DEFAULT 0;
  l_concatenated_segments     mtl_system_items_kfv.concatenated_segments%TYPE;
  l_item_assoc_id             NUMBER;
  l_meaning                   fnd_lookups.meaning%TYPE;
  l_parent_uc_header_id       NUMBER;
  l_parent_instance_id        NUMBER;
  l_root_uc_header_id         NUMBER;
  l_root_instance_id          NUMBER;
  l_root_uc_status_code       FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_uc_ovn               NUMBER;
  l_root_instance_ou          NUMBER;
  l_instance_ou               NUMBER;
  l_uc_status_code            FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_active_uc_status_code     FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_position_ref_meaning      fnd_lookups.meaning%TYPE;
  l_interchange_type_code     ahl_item_associations_b.interchange_type_code%TYPE;
  l_interchange_reason        ahl_item_associations_tl.interchange_reason%TYPE;

  --Variables needed for CSI API call
  l_csi_party_rec             csi_datastructures_pub.party_rec;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_new_rec  csi_datastructures_pub.ii_relationship_rec; -- SATHAPLI::FP ER 6504147, 18-Nov-2008
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_party_tbl             csi_datastructures_pub.party_tbl;
  l_csi_account_tbl           csi_datastructures_pub.party_account_tbl;
  l_csi_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
  l_csi_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
  l_csi_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
  l_csi_instance_id_lst       csi_datastructures_pub.id_tbl;
  l_party_account_rec         csi_datastructures_pub.party_account_rec;
  l_serial_number             csi_item_instances.serial_number%TYPE;
  l_mfg_serial_number_flag    csi_item_instances.mfg_serial_number_flag%TYPE;
  l_serial_number_tag         csi_iea_values.attribute_value%TYPE;

  l_return_val                BOOLEAN;
  l_transaction_type_id       NUMBER;
  l_attribute_id              NUMBER;
  l_attribute_value_id        NUMBER;
  l_attribute_value           csi_iea_values.attribute_value%TYPE;
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_extend_attrib_rec     csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;

  CURSOR check_uc_header IS
    SELECT A.unit_config_header_id,
           A.object_version_number,
           A.unit_config_status_code,
           A.active_uc_status_code,
           A.csi_item_instance_id,
           B.relationship_id
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.unit_config_header_id = p_uc_header_id
       AND trunc(nvl(A.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND A.master_config_id = B.mc_header_id
       AND B.parent_relationship_id IS NULL;
  l_check_uc_header check_uc_header%ROWTYPE;
  CURSOR get_uc_descendants(c_instance_id NUMBER) IS
    SELECT relationship_id,
           object_version_number,
           object_id,
           subject_id,
           to_number(position_reference) position_id
      FROM csi_ii_relationships
START WITH object_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Cursor to check whether the c_parent_relationship_id is the parent of
  --c_child_relationshp_id or c_child_relationship_id's own parent as the top node of the sub-config
  --can be installed in c_parent_relationship_id
  CURSOR check_parent_relationship(c_child_relationship_id NUMBER, c_parent_relationship_id NUMBER) IS
    SELECT 1
      FROM ahl_mc_relationships
     WHERE relationship_id = c_child_relationship_id
       AND (parent_relationship_id = c_parent_relationship_id OR
            mc_header_id IN (SELECT mc_header_id
                               FROM ahl_mc_config_relations
                              WHERE relationship_id = c_parent_relationship_id
                                AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                                AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)));

  --Cursor to check whether c_parent_instance_id's child position c_relationship_id is empty
  CURSOR check_position_empty(c_parent_instance_id NUMBER, c_relationship_id NUMBER) IS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE object_id = c_parent_instance_id
       AND position_reference = to_char(c_relationship_id)
       AND subject_id IS NOT NULL
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR check_instance_leaf(c_instance_id NUMBER) IS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE object_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header(c_instance_id NUMBER) IS
    SELECT unit_config_header_id, master_config_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --To get all the first level sub-units for a given branch node. First get all of the
  --branch node's sub-units and then remove those sub-units which are not first level
  --(from the branch node's perspective)

  CURSOR get_1st_level_subunits(c_instance_id NUMBER) IS
  /*This query is replaced by the query below it for performance gain.
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE subject_id IN (SELECT csi_item_instance_id
                            FROM ahl_unit_config_headers
                           WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH object_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
     MINUS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE subject_id IN (SELECT csi_item_instance_id
                            FROM ahl_unit_config_headers
                           WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH object_id IN (SELECT subject_id
                           FROM csi_ii_relationships
                          WHERE subject_id IN (SELECT csi_item_instance_id
                                                 FROM ahl_unit_config_headers
                                                WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
                     START WITH object_id = c_instance_id
                            AND relationship_type_code = 'COMPONENT-OF'
                            AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                            AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                     CONNECT BY object_id = PRIOR subject_id
                            AND relationship_type_code = 'COMPONENT-OF'
                            AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
                            AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  */
   SELECT i.subject_id
    FROM csi_ii_relationships i
   WHERE EXISTS (SELECT 'x'
                  FROM ahl_unit_config_headers u
                 WHERE u.csi_item_instance_id = i.subject_id
                   AND trunc(nvl(u.active_end_date, SYSDATE+1)) > trunc(SYSDATE))
     AND NOT EXISTS (SELECT ci.object_id
                       FROM csi_ii_relationships ci
                      WHERE (EXISTS (SELECT 'x'
                                       FROM ahl_unit_config_headers ui
                                      WHERE ui.csi_item_instance_id = ci.object_id)
                                AND ci.object_id <> c_instance_id)
                 START WITH ci.subject_id = i.subject_id
                        AND ci.relationship_type_code = 'COMPONENT-OF'
                        AND trunc(nvl(ci.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                        AND trunc(nvl(ci.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                 CONNECT BY ci.subject_id = prior ci.object_id
                        AND ci.relationship_type_code = 'COMPONENT-OF'
                        AND trunc(nvl(ci.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                        AND trunc(nvl(ci.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                        AND ci.subject_id <> c_instance_id)
START WITH i.object_id = c_instance_id
       AND i.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(i.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(i.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY i.object_id = PRIOR i.subject_id
       AND i.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(i.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(i.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR csi_item_instance_csr(c_instance_id  IN  NUMBER) IS
    SELECT C.inventory_item_id,
           C.inv_master_organization_id inventory_org_id,
           C.quantity,
           C.unit_of_measure uom_code,
           C.inventory_revision revision,
           C.install_date,
           C.instance_usage_code,
           C.location_type_code,
           C.object_version_number,
           U.unit_config_header_id uc_header_id
      FROM csi_item_instances C,
           ahl_unit_config_headers U
     WHERE C.instance_id = c_instance_id
       AND C.instance_id = U.csi_item_instance_id (+)
       --AND U.parent_uc_header_id (+) IS NULL
       --Comment out in order to include the extra sibling subunits whose parent_uc_header_id
       --is not null
       AND trunc(SYSDATE) < trunc(nvl(C.active_end_date,SYSDATE+1))
       AND trunc(SYSDATE) < trunc(nvl(U.active_end_date (+),SYSDATE+1));
  l_instance_rec        csi_item_instance_csr%ROWTYPE;

  CURSOR check_sub_mc(c_relationship_id NUMBER) IS
    SELECT mc_header_id
      FROM ahl_mc_config_relations
     WHERE relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR check_extra_node(c_object_id NUMBER, c_subject_id NUMBER) IS
    SELECT relationship_id, object_version_number
      FROM csi_ii_relationships
     WHERE object_id = c_object_id
       AND subject_id = c_subject_id
       AND position_reference IS NULL
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  -- SATHAPLI::FP ER 6504147, 18-Nov-2008
  CURSOR check_unasgnd_extra_node_csr(p_parent_instance_id NUMBER, p_instance_id NUMBER) IS
    SELECT relationship_id, object_version_number
      FROM csi_ii_relationships
     WHERE object_id IN (
                         SELECT ii.object_id
                         FROM   csi_ii_relationships ii
                         START WITH ii.subject_id = p_parent_instance_id
                         AND    ii.relationship_type_code = 'COMPONENT-OF'
                         AND    trunc(nvl(ii.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                         AND    trunc(nvl(ii.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                         CONNECT BY ii.subject_id = PRIOR ii.object_id
                         AND    ii.relationship_type_code = 'COMPONENT-OF'
                         AND    trunc(nvl(ii.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                         AND    trunc(nvl(ii.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                        )
       AND subject_id = p_instance_id
       AND position_reference IS NULL
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_serial_number(c_instance_id NUMBER) IS
    SELECT serial_number, mfg_serial_number_flag
      FROM csi_item_instances
     WHERE instance_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR check_instance_installed(c_instance_id NUMBER) IS
    SELECT 'X'
      FROM csi_ii_relationships
     WHERE subject_id = c_instance_id
       AND position_reference IS NOT NULL
       --for extra node, it is still available for its sibling nodes even
       --if it is installed and not removed
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  -- SATHAPLI::ER 7419780, 24-Aug-2009, fetch the INTERCHANGE_REASON from the table ahl_item_associations_tl too
  CURSOR get_interchange_type (c_instance_id NUMBER, c_relationship_id NUMBER) IS
    SELECT i.interchange_type_code,
           itl.interchange_reason
      FROM csi_item_instances c,
           ahl_item_associations_b i,
           ahl_item_associations_tl itl,
           ahl_mc_relationships m
     WHERE m.relationship_id = c_relationship_id
       AND c.instance_id = c_instance_id
       AND m.item_group_id = i.item_group_id
       AND c.inventory_item_id = i.inventory_item_id
       AND c.inv_master_organization_id = i.inventory_org_id
       AND itl.item_association_id = i.item_association_id
       AND itl.language = USERENV('LANG')
       AND (c.inventory_revision IS NULL OR
            i.revision is NULL OR
            (c.inventory_revision IS NOT NULL AND
             i.revision IS NOT NULL AND
             c.inventory_revision = i.revision));
   --Added this last condition due to the impact of bug fixing 4102152, added by Jerry on 01/05/2005
   --Need to confirm which one is more accurate here to use c.inv_master_organization_id or
   --c.last_vld_organization_id

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT install_existing_instance;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,  G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  --Validate input parameters p_prod_user_flag
  IF upper(p_prod_user_flag) <> 'Y' AND upper(p_prod_user_flag) <> 'N' THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'prod_user_flag');
    FND_MESSAGE.set_token('VALUE', p_prod_user_flag);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate input parameter p_uc_header_id, its two statuses
  OPEN check_uc_header;
  FETCH check_uc_header INTO l_check_uc_header;
  IF check_uc_header%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_uc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    -- ACL :: Changes for R12
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ahl_util_uc_pkg.get_root_uc_attr(p_uc_header_id,
                                     l_root_uc_header_id,
                                     l_root_instance_id,
                                     l_root_uc_status_code,
                                     l_root_active_uc_status_code,
                                     l_root_uc_ovn);
    IF (p_prod_user_flag = 'Y' AND --For production user, no need to confirm either one of the statuses is not APPROVAL_PENDING
        l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_NOT_ACTIVE' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (p_prod_user_flag = 'N' AND
           (l_root_uc_status_code = 'APPROVAL_PENDING' OR
            l_root_active_uc_status_code = 'APPROVAL_PENDING')) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_PENDING' );
      FND_MESSAGE.set_token('UC_HEADER_ID', l_root_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_uc_header;
    END IF;
  END IF;

  --Get the operating unit of the root instance.
  l_root_instance_ou := get_operating_unit(l_root_instance_id);

  --Make sure p_parent_instance_id is installed in the UC
  IF p_parent_instance_id = l_check_uc_header.csi_item_instance_id THEN
    --The parent instance is the root node
    l_parent_relationship_id := l_check_uc_header.relationship_id;
  ELSE
    FOR l_get_uc_descendant IN get_uc_descendants(l_check_uc_header.csi_item_instance_id) LOOP
      l_csi_relationship_id := l_get_uc_descendant.relationship_id;
      l_object_version_number := l_get_uc_descendant.object_version_number;
      l_object_id := l_get_uc_descendant.object_id;
      l_subject_id := l_get_uc_descendant.subject_id;
      l_parent_relationship_id := l_get_uc_descendant.position_id;
      EXIT WHEN l_subject_id = p_parent_instance_id;
    END LOOP;
    --Ensure the instance is installed in this UC and not an extra node
    IF (l_subject_id <> p_parent_instance_id OR
        p_parent_instance_id IS NULL OR
        l_subject_id IS NULL OR
        l_parent_relationship_id IS NULL) THEN
      --We don't allow installing child instance to an extra node.
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_NOT_IN_UC' );
      FND_MESSAGE.set_token('INSTANCE', p_parent_instance_id);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  --Then validate p_relationship_id can be child of l_parent_relationship_id
  OPEN check_parent_relationship(p_relationship_id, l_parent_relationship_id);
  FETCH check_parent_relationship INTO l_dummy;
  IF check_parent_relationship%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_MISMATCH' );
    FND_MESSAGE.set_token('CHILD', p_relationship_id);
    FND_MESSAGE.set_token('PARENT', l_parent_relationship_id);
    FND_MSG_PUB.add;
    CLOSE check_parent_relationship;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_parent_relationship;
  END IF;
  --Make sure position p_relationship_id is empty
  OPEN check_position_empty(p_parent_instance_id, p_relationship_id);
  FETCH check_position_empty INTO l_dummy;
  IF check_position_empty%FOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_INSTALLED' );
    FND_MESSAGE.set_token('POSITION', p_relationship_id);
    FND_MSG_PUB.add;
    CLOSE check_position_empty;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_position_empty;
  END IF;


  --Validate the instance to be installed is existing
  OPEN csi_item_instance_csr(p_instance_id);
  FETCH csi_item_instance_csr INTO l_instance_rec;
  IF (csi_item_instance_csr%NOTFOUND) THEN
    CLOSE csi_item_instance_csr;
    FND_MESSAGE.set_name('AHL','AHL_UC_CSII_INVALID');
    FND_MESSAGE.set_token('CSII',p_instance_id);
    FND_MESSAGE.set_token('POSN_REF',p_relationship_id);
    FND_MSG_PUB.add;
    --dbms_output.put_line('CSI item instance ID does not exist.');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE csi_item_instance_csr;

  --Ensure the instance is available, not installed. For extra node, even if it
  --is installed but it is still available for its sibling nodes.
  OPEN check_instance_installed(p_instance_id);
  FETCH check_instance_installed INTO l_dummy_char;
  IF (check_instance_installed%FOUND) THEN
    CLOSE check_instance_installed;
    FND_MESSAGE.set_name('AHL','AHL_UC_INSTANCE_INSTALLED');
    FND_MESSAGE.set_token('INSTANCE',p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE check_instance_installed;


  --Check object_version_number of the instance
/*  IF (p_uc_instance_rec.object_version_number <> l_csi_inst_rec.object_version
_number) THEN
    CLOSE csi_item_instance_csr;
    FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.add;
    --dbms_output.put_line('Item Instance id object version changed');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
*/
  --Validate the status of the instance
  IF (l_instance_rec.location_type_code IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_INST_STATUS_INVALID');
    AHL_UTIL_UC_PKG.convert_to_csimeaning('CSI_INST_LOCATION_SOURCE_CODE',
                                          l_instance_rec.location_type_code,
                                          l_meaning,l_return_val);
    IF NOT(l_return_val) THEN
      l_meaning := l_instance_rec.location_type_code;
    END IF;
    FND_MESSAGE.set_token('LOCATION',l_meaning);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Item Instance location is not valid');
  END IF;

  --If the instance is not a unit, then validate positional attributes. For unit, it is not
  --necessary to validate.
  IF (l_instance_rec.uc_header_id IS NULL) THEN
    AHL_UTIL_UC_PKG.validate_for_position(p_relationship_id,
                                          l_instance_rec.inventory_item_id,
                                          l_instance_rec.inventory_org_id,
                                          l_instance_rec.quantity,
                                          l_instance_rec.revision,
                                          l_instance_rec.uom_code,
                                          NULL,
                                          -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
                                          -- Pass 'N' for p_ignore_quant_vald.
                                          'N',
                                          l_item_assoc_id);
  END IF;

  --Validate installation date.
  --Keep the installation date validation only for production user(04/21/2004).
  IF (l_instance_rec.install_date IS NOT NULL AND
      l_instance_rec.install_date <> FND_API.G_MISS_DATE) THEN
    IF (p_prod_user_flag = 'Y' AND trunc(l_instance_rec.install_date) > trunc(SYSDATE)) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_INSTDATE_INVALID');
      FND_MESSAGE.set_token('DATE',l_instance_rec.install_date);
      FND_MESSAGE.set_token('POSN_REF',p_relationship_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Installation date invalid.');
    END IF;
  END IF;

  --Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Before installing the existing instance, make sure its operating unit is exactly the same as that
  --of the root instance.
  l_instance_ou := get_operating_unit(p_instance_id);
  IF l_root_instance_ou IS NULL THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_NULL');
    FND_MESSAGE.set_token('INSTANCE', l_root_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_instance_ou IS NULL THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_NULL');
    FND_MESSAGE.set_token('INSTANCE', p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_root_instance_ou <> l_instance_ou THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_UNMATCH');
    FND_MESSAGE.set_token('INSTANCE', p_instance_id);
    FND_MESSAGE.set_token('ROOT_INSTANCE', l_root_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Check the instance to be installed is a leaf node, branch node or sub-unit top node(in this
  --case, it might also be a leaf node in csi_ii_relationships if all of its descendants are empty)
  OPEN get_uc_header(p_instance_id);
  FETCH get_uc_header INTO l_sub_uc_header_id, l_mc_header_id;
  IF get_uc_header%FOUND THEN
    -- ACL :: R12 Changes
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => l_sub_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --The instance is a unit top node, needs to see whether it can be a candidate sub-unit
    --in that position
    l_instance_type := 'S';
    l_subunit := FALSE;
    FOR l_check_sub_mc IN check_sub_mc(p_relationship_id) LOOP
      IF l_mc_header_id = l_check_sub_mc.mc_header_id THEN
        l_subunit := TRUE;
        EXIT;
      END IF;
    END LOOP;
    IF NOT l_subunit THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_SUBUNIT_MISMATCH');
      FND_MESSAGE.set_token('INSTANCE', p_instance_id);
      FND_MESSAGE.set_token('POSITION', p_relationship_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    OPEN check_instance_leaf(p_instance_id);
    FETCH check_instance_leaf INTO l_dummy;
    IF check_instance_leaf%FOUND THEN --Non leaf instance
      --The instance is a branch node, needs to call remap_uc_subtree to see whether the branch
      --can be installed in that position. If match, the corresponding position reference will be
      --updated as well.
      l_instance_type := 'B';
      ahl_uc_tree_pvt.remap_uc_subtree(
                          p_api_version      => 1.0,
                          p_init_msg_list    => FND_API.G_FALSE,
                          p_commit           => FND_API.G_FALSE,
                          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status    => l_return_status,
                          x_msg_count        => l_msg_count,
                          x_msg_data         => l_msg_data,
                          p_instance_id      => p_instance_id,
                          p_relationship_id  => p_relationship_id);
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        CLOSE check_instance_leaf;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        CLOSE check_instance_leaf;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
      l_instance_type := 'L';
    END IF;
    CLOSE check_instance_leaf;
  END IF;
  CLOSE get_uc_header;

  --Build CSI transaction record, first get transaction_type_id
  AHL_Util_UC_Pkg.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_val);
  IF NOT(l_return_val) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;

  --Update installation date if provided.
  IF (l_instance_rec.install_date IS NOT NULL AND
      l_instance_rec.install_date <> FND_API.G_MISS_DATE) THEN
    -- Build CSI instance rec.
    l_csi_instance_rec.instance_id           := p_instance_id;
    l_csi_instance_rec.object_version_number := l_instance_rec.object_version_number;
    l_csi_instance_rec.install_date          := l_instance_rec.install_date;

    -- Call API to update installation date.
    CSI_ITEM_INSTANCE_PUB.update_item_instance(
                          p_api_version            => 1.0,
                          p_instance_rec           => l_csi_instance_rec,
                          p_txn_rec                => l_csi_transaction_rec,
                          p_ext_attrib_values_tbl  => l_csi_ext_attrib_values_tbl,
                          p_party_tbl              => l_csi_party_tbl,
                          p_account_tbl            => l_csi_account_tbl,
                          p_pricing_attrib_tbl     => l_csi_pricing_attrib_tbl,
                          p_org_assignments_tbl    => l_csi_org_assignments_tbl,
                          p_asset_assignment_tbl   => l_csi_asset_assignment_tbl,
                          x_instance_id_lst        => l_csi_instance_id_lst,
                          x_return_status          => l_return_status,
                          x_msg_count              => l_msg_count,
                          x_msg_data               => l_msg_data);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --Need to check if the instance picked from CSI with serial_number has a serial_no_tag, and
  --if not, we have to derive its value according to mfg_serail_number_flag ('Y'->'INVENTORY',
  --assuming CSI has the validation to ensure the serial_number exisiting in table
  --mfg_searil_numbers, otherwise it is 'TEMPORARY'
  OPEN get_serial_number(p_instance_id);
  FETCH get_serial_number INTO l_serial_number, l_mfg_serial_number_flag;
  IF get_serial_number%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_CSII_INVALID');
    FND_MESSAGE.set_token('CSII', p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
    CLOSE get_serial_number;
  ELSE
    CLOSE get_serial_number;
  END IF;

  IF l_serial_number IS NOT NULL THEN
    --Retrieve existing value of serial_number_tag if present.
    AHL_UTIL_UC_PKG.getcsi_attribute_value(p_instance_id,
                                           'AHL_TEMP_SERIAL_NUM',
                                           l_attribute_value,
                                           l_attribute_value_id,
                                           l_object_version_number,
                                           l_return_val);
    IF NOT l_return_val THEN --serial_number_tag doesn't exist
      --Modified by mpothuku on 13-Jul-2007 for fixing the Bug 4337259
      /*
      IF l_mfg_serial_number_flag = 'Y' THEN
        l_serial_number_tag := 'INVENTORY';
      ELSE
        l_serial_number_tag := 'TEMPORARY';
      END IF;
      */
      l_serial_number_tag := 'ACTUAL';
      --mpothuku End
      AHL_Util_UC_Pkg.getcsi_attribute_id('AHL_TEMP_SERIAL_NUM', l_attribute_id, l_return_val);

      IF NOT(l_return_val) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
        FND_MESSAGE.set_token('CODE', 'AHL_TEMP_SERIAL_NUM');
        FND_MSG_PUB.add;
      ELSE
        l_csi_extend_attrib_rec.attribute_id := l_attribute_id;
        l_csi_extend_attrib_rec.attribute_value := l_serial_number_tag;
        l_csi_extend_attrib_rec.instance_id := p_instance_id;
        l_csi_ext_attrib_values_tbl(1) := l_csi_extend_attrib_rec;
      END IF;

      CSI_ITEM_INSTANCE_PUB.create_extended_attrib_values(
                          p_api_version            => 1.0,
                          p_txn_rec                => l_csi_transaction_rec,
                          p_ext_attrib_tbl         => l_csi_ext_attrib_values_tbl,
                          x_return_status          => l_return_status,
                          x_msg_count              => l_msg_count,
                          x_msg_data               => l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  --Check to see whether an extra node relationship record has already existed.
  --then just update the position_reference from null to p_relationship_id, otherwise
  --need to create a new csi_ii_relationship record
  OPEN check_extra_node(p_parent_instance_id, p_instance_id);
  FETCH check_extra_node INTO l_csi_relationship_id, l_object_version_number;
  IF check_extra_node%FOUND THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                       ' sibling extra node found'||
                       ' p_csi_ii_ovn => '||p_csi_ii_ovn);
    END IF;

    --Validate input parameters p_csi_ii_ovn
    IF (p_csi_ii_ovn IS NULL OR p_csi_ii_ovn <= 0 ) THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'csi_ii_ovn');
      FND_MESSAGE.set_token('VALUE', p_csi_ii_ovn);
      FND_MSG_PUB.add;
      CLOSE check_extra_node;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_object_version_number <> p_csi_ii_ovn THEN
      FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      CLOSE check_extra_node;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_csi_relationship_rec.relationship_id := l_csi_relationship_id;
    l_csi_relationship_rec.object_version_number := l_object_version_number;
    l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
    l_csi_relationship_rec.object_id := p_parent_instance_id;
    l_csi_relationship_rec.subject_id := p_instance_id;
    l_csi_relationship_rec.position_reference := to_char(p_relationship_id);
    l_csi_relationship_tbl(1) := l_csi_relationship_rec;
    CSI_II_RELATIONSHIPS_PUB.update_relationship(
                             p_api_version      => 1.0,
                             p_relationship_tbl => l_csi_relationship_tbl,
                             p_txn_rec          => l_csi_transaction_rec,
                             x_return_status    => l_return_status,
                             x_msg_count        => l_msg_count,
                             x_msg_data         => l_msg_data);
  ELSE
    -- SATHAPLI::FP ER 6504147, 18-Nov-2008
    -- check if it is unassigned extra instance attached to any of the parents uptill the root node
    OPEN check_unasgnd_extra_node_csr(p_parent_instance_id, p_instance_id);
    FETCH check_unasgnd_extra_node_csr INTO l_csi_relationship_id, l_object_version_number;

    IF check_unasgnd_extra_node_csr%FOUND THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                         ' extra node attached to any of the parents uptill root found'||
                         ' p_parent_instance_id => '||p_parent_instance_id||
                         ' p_instance_id => '||p_instance_id||
                         ' p_csi_ii_ovn => '||p_csi_ii_ovn);
      END IF;

      -- Validate input parameters p_csi_ii_ovn
      IF (p_csi_ii_ovn IS NULL OR p_csi_ii_ovn <= 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
        FND_MESSAGE.set_token('NAME', 'csi_ii_ovn');
        FND_MESSAGE.set_token('VALUE', p_csi_ii_ovn);
        FND_MSG_PUB.add;
        CLOSE check_unasgnd_extra_node_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_object_version_number <> p_csi_ii_ovn THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        CLOSE check_unasgnd_extra_node_csr;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- expire the existing relationship
      -- Set CSI relationship record
      l_csi_relationship_rec.relationship_id := l_csi_relationship_id;
      l_csi_relationship_rec.object_version_number := l_object_version_number;

      CSI_II_RELATIONSHIPS_PUB.expire_relationship(
                               p_api_version      => 1.0,
                               p_relationship_rec => l_csi_relationship_rec,
                               p_txn_rec          => l_csi_transaction_rec,
                               x_instance_id_lst  => l_csi_instance_id_lst,
                               x_return_status    => l_return_status,
                               x_msg_count        => l_msg_count,
                               x_msg_data         => l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                         ' unassigned extra node relationship expired');
      END IF;

      -- create new relationship
      -- create new CSI record
      l_csi_relationship_new_rec.relationship_type_code := 'COMPONENT-OF';
      l_csi_relationship_new_rec.object_id := p_parent_instance_id;
      l_csi_relationship_new_rec.subject_id := p_instance_id;
      l_csi_relationship_new_rec.position_reference := to_char(p_relationship_id);
      l_csi_relationship_tbl(1) := l_csi_relationship_new_rec;
      CSI_II_RELATIONSHIPS_PUB.create_relationship(
                               p_api_version      => 1.0,
                               p_relationship_tbl => l_csi_relationship_tbl,
                               p_txn_rec          => l_csi_transaction_rec,
                               x_return_status    => l_return_status,
                               x_msg_count        => l_msg_count,
                               x_msg_data         => l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                         ' unassigned extra node new relationship created');
      END IF;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                         ' free standing instance found'||
                         ' p_csi_ii_ovn => '||p_csi_ii_ovn);
      END IF;

      l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
      l_csi_relationship_rec.object_id := p_parent_instance_id;
      l_csi_relationship_rec.subject_id := p_instance_id;
      l_csi_relationship_rec.position_reference := to_char(p_relationship_id);
      l_csi_relationship_tbl(1) := l_csi_relationship_rec;
      CSI_II_RELATIONSHIPS_PUB.create_relationship(
                               p_api_version      => 1.0,
                               p_relationship_tbl => l_csi_relationship_tbl,
                               p_txn_rec          => l_csi_transaction_rec,
                               x_return_status    => l_return_status,
                               x_msg_count        => l_msg_count,
                               x_msg_data         => l_msg_data);
    END IF; -- end IF check_unasgnd_extra_node_csr%FOUND

    CLOSE check_unasgnd_extra_node_csr;
  END IF;
  CLOSE check_extra_node;
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --If the node is the top node of a sub-unit then just itself, otherwise if it is a
  --branch node, then get all of its first level sub-units. For all of these sub-units,
  --we have to update their parent_uc_header_id to p_uc_header_id. Once a unit is installed
  --to another unit and automatically becomes a sub-unit, then it loses all its statuses. So
  --we don't have to update the two statuses here.

  IF l_subunit THEN
    ahl_util_uc_pkg.get_parent_uc_header(p_instance_id,
                                         l_parent_uc_header_id,
                                         l_parent_instance_id);
    UPDATE ahl_unit_config_headers
       --SET parent_uc_header_id = p_uc_header_id
       --The parameter p_uc_header_id is not necessarily the parent uc_header_id of the newly
       --installed instance.
       SET parent_uc_header_id = l_parent_uc_header_id,
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
     WHERE csi_item_instance_id = p_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
           --Not necessary to check the object_version_number here
    --Copy the change to history table
    ahl_util_uc_pkg.copy_uc_header_to_history(l_sub_uc_header_id, l_return_status);
    --IF history copy failed, then don't raise exception, just add the message to the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;
  ELSIF l_instance_type = 'B' THEN --this instance is a branch node
    ahl_util_uc_pkg.get_parent_uc_header(p_instance_id,
                                         l_parent_uc_header_id,
                                         l_parent_instance_id);
    FOR l_get_1st_level_subunit IN get_1st_level_subunits(p_instance_id) LOOP
      UPDATE ahl_unit_config_headers
         SET parent_uc_header_id = l_parent_uc_header_id,
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE csi_item_instance_id = l_get_1st_level_subunit.subject_id
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
             --Not necessary to check the object_version_number here

      OPEN get_uc_header(l_get_1st_level_subunit.subject_id);
      FETCH get_uc_header INTO l_sub_uc_header_id, l_mc_header_id;
      IF get_uc_header%NOTFOUND THEN
        FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_NOT_IN_UC');
        FND_MESSAGE.set_token('INSTANCE', l_get_1st_level_subunit.subject_id);
        FND_MSG_PUB.add;
        CLOSE get_uc_header;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        CLOSE get_uc_header;
      END IF;

      --Copy the change to history table
      ahl_util_uc_pkg.copy_uc_header_to_history(l_sub_uc_header_id, l_return_status);
      --IF history copy failed, then don't raise exception, just add the messageto the message stack

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
        FND_MSG_PUB.add;
      END IF;
    END LOOP;
  END IF;

  --Call completeness check API for the newly assigned instance
  ahl_uc_validation_pub.validate_complete_for_pos(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_csi_instance_id     => p_instance_id,
      x_error_tbl           => x_warning_msg_tbl);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --For sub unit top node, it is not necessary to have this item interchange type
  --code validation check
  -- SATHAPLI::ER 7419780, 24-Aug-2009, add the fetched INTERCHANGE_REASON as well, to the warning message AHL_UC_1WAY_ITEM_INSTALLED.

  IF l_instance_type <> 'S' THEN
    OPEN get_interchange_type(p_instance_id, p_relationship_id);
    FETCH get_interchange_type INTO l_interchange_type_code, l_interchange_reason;
    IF get_interchange_type%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_ITEM_INTERCHANGE_MISS');
      FND_MESSAGE.set_token('INSTANCE', p_instance_id);
      FND_MSG_PUB.add;
      CLOSE get_interchange_type;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_interchange_type_code = '1-WAY INTERCHANGEABLE' THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_1WAY_ITEM_INSTALLED');
      SELECT f.meaning INTO l_position_ref_meaning
        FROM ahl_mc_relationships a,
             fnd_lookups f
       WHERE a.relationship_id = p_relationship_id
         AND f.lookup_code (+) = A.position_ref_code
         AND f.lookup_type (+) = 'AHL_POSITION_REFERENCE' ;
      FND_MESSAGE.set_token('POSITION', l_position_ref_meaning);
      FND_MESSAGE.set_token('REASON', l_interchange_reason);
      --Here the message is not added to the global message stack;
      IF x_warning_msg_tbl.count > 0 THEN
        x_warning_msg_tbl(x_warning_msg_tbl.last + 1) := FND_MESSAGE.get;
      ELSE
        x_warning_msg_tbl(0) := FND_MESSAGE.get;
      END IF;
    END IF;
    CLOSE get_interchange_type;
  END IF;

  --For UC user, UC header status change needs to be made after the operation
  --Not confirmed whether need to copy the record into UC header history table
  --after status change. Not include the copy right now. (No history copy)
  IF p_prod_user_flag = 'N' THEN
    IF (l_root_uc_status_code = 'COMPLETE' AND x_warning_msg_tbl.count > 0) THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'INCOMPLETE',
             active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (l_root_uc_status_code IN ('COMPLETE', 'INCOMPLETE') AND
           (l_root_active_uc_status_code IS NULL OR
            l_root_active_uc_status_code <> 'UNAPPROVED')) THEN
    --IF unit_config_status_code='INCOMPLETE' and active_uc_status_code='UNAPPROVED', this
    --update is only object_version_number change and not necessary.
      UPDATE ahl_unit_config_headers
         SET active_uc_status_code = 'UNAPPROVED',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF l_root_uc_status_code NOT IN ('COMPLETE', 'INCOMPLETE', 'DRAFT') THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Before calling completeness check',
                   'p_uc_header_id='||p_uc_header_id||'l_root_uc_header_id='||l_root_uc_header_id||
                   'l_root_uc_ovn='||l_root_uc_ovn);
      END IF;
    --IF unit_config_status_code='DRAFT', this update is only object_version_number change and
    --not necessary.
      UPDATE ahl_unit_config_headers
         SET unit_config_status_code = 'DRAFT',
             object_version_number = object_version_number + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
       WHERE unit_config_header_id = l_root_uc_header_id
         AND object_version_number = l_root_uc_ovn;
      IF SQL%ROWCOUNT = 0 THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  ELSIF (p_prod_user_flag = 'Y' AND
         x_warning_msg_tbl.count > 0 AND
         l_root_uc_status_code = 'COMPLETE') THEN
    UPDATE ahl_unit_config_headers
       SET unit_config_status_code = 'INCOMPLETE',
           object_version_number = object_version_number + 1,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
     WHERE unit_config_header_id = l_root_uc_header_id
       AND object_version_number = l_root_uc_ovn;
    IF SQL%ROWCOUNT = 0 THEN
      FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
                   'At the end of the procedure');
  END IF;

  --Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  --Count and Get messages(optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO install_existing_instance;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO install_existing_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO install_existing_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Define procedure swap_instances
-- This API is used by Production user to make parts change: replace an old instance
-- a new one in a UC tree.
PROCEDURE swap_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_parent_instance_id    IN  NUMBER,
  p_old_instance_id       IN  NUMBER,
  p_new_instance_id       IN  NUMBER,
  p_new_instance_number   IN  csi_item_instances.instance_number%TYPE := NULL,
  p_relationship_id       IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'swap_instance';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_relationship_id           NUMBER;
  CURSOR check_relationship_id(c_subject_id NUMBER, c_relationship_id NUMBER) IS
    SELECT 'X'
      FROM csi_ii_relationships
     WHERE subject_id = c_subject_id
       AND position_reference = to_char(c_relationship_id)
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT swap_instance;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  --Call remove_instance to remove the old instance
  remove_instance(
                  p_api_version      => 1.0,
                  p_init_msg_list    => FND_API.G_FALSE,
                  p_commit           => FND_API.G_FALSE,
                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                  x_return_status    => l_return_status,
                  x_msg_count        => l_msg_count,
                  x_msg_data         => l_msg_data,
                  p_uc_header_id     => p_uc_header_id,
                  p_instance_id      => p_old_instance_id,
                  p_csi_ii_ovn       => p_csi_ii_ovn,
                  p_prod_user_flag   => p_prod_user_flag);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After calling remove_instance API',
                   'At the middle of the procedure');
  END IF;

  --Only need to ensure, the position_reference of the old_instance_id is just
  --the one of the new_instance_id. All the other validations will be made in the
  --other two called APIs.
  OPEN check_relationship_id(p_old_instance_id, p_relationship_id);
  IF check_relationship_id%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_NOT_SAME' );
    FND_MESSAGE.set_token('POSITION', p_relationship_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Call install_existing_instance to install the new instance
  install_existing_instance(p_api_version        => 1.0,
                            p_init_msg_list      => FND_API.G_FALSE,
                            p_commit             => FND_API.G_FALSE,
                            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_uc_header_id       => p_uc_header_id,
                            p_parent_instance_id => p_parent_instance_id,
                            p_instance_id        => p_new_instance_id,
                            p_instance_number    => p_new_instance_number,
                            p_relationship_id    => p_relationship_id,
                            p_csi_ii_ovn         => p_csi_ii_ovn,
                            p_prod_user_flag     => p_prod_user_flag,
                            x_warning_msg_tbl    => x_warning_msg_tbl);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After calling install_existing_instance API and comes to normal execution',
                   'At the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO swap_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO swap_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO swap_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

--****************************************************************************
-- Procedure for getting all instances that are available in sub inventory and
-- available for installation at a particular UC position.
-- Adithya added for OGMA issue # 86 FP
--****************************************************************************
PROCEDURE Get_Avail_Subinv_Instances(
  p_api_version            IN  NUMBER := 1.0,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  p_relationship_id        IN  NUMBER,
  p_item_number            IN  VARCHAR2 :='%',
  p_serial_number          IN  VARCHAR2 :='%',
  p_instance_number        IN  VARCHAR2 :='%',
  p_workorder_id           IN  NUMBER := NULL, --required by Part Changes
  p_start_row_index        IN  NUMBER,
  p_max_rows               IN  NUMBER,
  x_avail_subinv_instance_tbl OUT NOCOPY available_instance_tbl_type
)
IS


--Cursor for getting visit details

CURSOR c_get_visit_details(c_workorder_id NUMBER)
IS
SELECT
  VST.visit_id,
  VST.project_id,
  VST.inv_locator_id,
  AWO.wip_entity_id
FROM
  AHL_VISITS_B VST,
  AHL_WORKORDERS AWO
WHERE
      VST.status_code NOT IN ('DELETED', 'CANCELLED')
      AND AWO.visit_id = VST.visit_id
      AND AWO.workorder_id = c_workorder_id;

l_visit_details_rec c_get_visit_details%ROWTYPE;


CURSOR c_get_subinv_inst(c_relationship_id NUMBER,
                       c_item_number VARCHAR2,
                       c_instance_number VARCHAR2,
                       c_serial_number VARCHAR2,
                       c_wip_job_id NUMBER,
                       c_project_id NUMBER,
                       c_inv_locator_id NUMBER
                       )
IS
    SELECT C.instance_id,
           C.instance_number,
           C.inventory_item_id,
           C.inv_master_organization_id,
           C.quantity,
           C.inventory_revision,
           C.unit_of_measure uom_code,
           C.inv_subinventory_name,
           C.inv_locator_id,
           to_number(NULL) uc_header_id
      FROM csi_item_instances C,
           mtl_system_items_kfv M,
           ahl_mc_relationships R,
           ahl_item_associations_b A
     WHERE C.inventory_item_id = M.inventory_item_id
       AND C.inv_master_organization_id = M.organization_id
       AND R.item_group_id = A.item_group_id
       AND C.inventory_item_id = A.inventory_item_id
       AND R.relationship_id = c_relationship_id
       AND trunc(nvl(R.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND trunc(nvl(C.active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND C.location_type_code IN ('INVENTORY')
       --AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')
       AND A.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
       AND (A.revision IS NULL OR A.revision = C.inventory_revision) --Added by Jerry on 03/31/2005
       --
       -- not installed in any position so far.
       --
       AND NOT EXISTS (
			 SELECT 1
			  FROM csi_ii_relationships i1
			 WHERE i1.subject_id = C.instance_id
			   AND i1.relationship_type_code = 'COMPONENT-OF'
			   AND trunc(nvl(i1.active_start_date, SYSDATE)) <= trunc(SYSDATE)
			   AND trunc(nvl(i1.active_end_date, SYSDATE+1)) >trunc(SYSDATE)
                       )
       --
       -- its not issued to any workorder already.
       --
       AND C.wip_job_id IS NULL
       --
       -- Its not in the top node of any UC.
       --
       AND NOT EXISTS (
                        SELECT 1
                         FROM ahl_unit_config_headers H
                        WHERE H.csi_item_instance_id = C.instance_id
                          AND trunc(nvl(H.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                      )
       --
       -- and it satisfies other checks like serial number, instance and item number that are passed
       --
       AND upper(M.concatenated_segments) LIKE nvl(c_item_number,'%')
       AND upper(C.instance_number) LIKE nvl(c_instance_number,'%')
       AND upper(nvl(C.serial_number, '%')) LIKE nvl(c_serial_number,'%')
       AND M.organization_id IN (SELECT mp.master_organization_id
                                   FROM mtl_parameters mp, org_organization_definitions ood
                                  WHERE mp.organization_Id = ood.organization_id
                                  -- jaramana on Feb 14, 2008
                                  -- Removed reference to CLIENT_INFO
                                  AND NVL(ood.operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id())
       AND C.inv_locator_id IN (
	                            SELECT
	                              ILOC.inventory_location_id
	                            FROM
	                              -- jaramana on Feb 14, 2008 for bug 6819370
	                              -- Changed MTL_ITEM_LOCATIONS_KFV to MTL_ITEM_LOCATIONS
	                              MTL_ITEM_LOCATIONS ILOC,
	                              AHL_VISITS_B VST
	                            WHERE
	                              ILOC.subinventory_code = C.inv_subinventory_name
	                              AND ILOC.organization_id = C.inv_organization_id
	                              AND (ILOC.end_date_active IS NULL OR ILOC.end_date_active >= SYSDATE)
	                              AND ILOC.segment19 = c_project_id
	                              AND ILOC.physical_location_id = c_inv_locator_id
	                       )

      AND EXISTS(--If serial number is present then check the status is "in stores"
                 (SELECT
		   'X'
		  FROM
		   MTL_SERIAL_NUMBERS MSLN,
		   MFG_LOOKUPS SL
		  WHERE
		   C.serial_number is not null
		   AND MSLN.serial_number = C.serial_number
		   AND MSLN.inventory_item_id = C.inventory_item_id
		   AND MSLN.CURRENT_ORGANIZATION_ID = C.INV_ORGANIZATION_ID
		   AND MSLN.CURRENT_STATUS  = SL.lookup_code
		   AND SL.lookup_type = 'SERIAL_NUM_STATUS'
		   AND MSLN.current_status = '3' -- "in stores"
		  )
		  UNION
		  --If serial number not present then check on hand quantity > 0
		  (
		   SELECT
		    'X'
		   FROM
		    MTL_ONHAND_QUANTITIES MOQ
		   WHERE
		    C.serial_number is null
		    AND MOQ.inventory_item_id = C.inventory_item_id
		    AND MOQ.ORGANIZATION_ID = C.INV_ORGANIZATION_ID
  		    AND MOQ.TRANSACTION_QUANTITY > 0
		  )
		)

UNION ALL
--
-- A position can include alternate subconfigurations.
-- This part of select clause is for picking top node instances of all alternate subconfigs.
--
        SELECT C.instance_id,
               C.instance_number,
               C.inventory_item_id,
               C.inv_master_organization_id,
               C.quantity,
               C.inventory_revision,
               C.unit_of_measure uom_code,
               C.inv_subinventory_name,
               C.inv_locator_id,
               U.uc_header_id uc_header_id
          FROM ahl_unit_config_headers_v U,
               csi_item_instances C,
               mtl_system_items_kfv M
         WHERE U.csi_instance_id = C.instance_id
           AND C.inventory_item_id = M.inventory_item_id
           AND C.inv_master_organization_id = M.organization_id
           AND trunc(nvl(U.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
           AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
           AND C.location_type_code IN ('INVENTORY')
           --
           -- Check to see this UC is a subconfig
           --
           AND EXISTS (
                        SELECT 1
                         FROM ahl_mc_config_relations R
                        WHERE R.mc_header_id = U.mc_header_id
                          AND R.relationship_id = c_relationship_id
                          AND trunc(nvl(R.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                          AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                      )
	   --
	   -- sub config is in valid status
	   --
           AND (
                 U.parent_instance_id IS NULL
                 AND U.uc_status_code in ('COMPLETE', 'INCOMPLETE')
	       )
	   --
	   -- its not issued to any workorder already.
	   --
	   AND C.wip_job_id IS NULL
	   --
	   -- its not a parent for any other mc position.
	   --
           AND NOT EXISTS (
                            SELECT 1
                             FROM ahl_mc_relationships MR
                            WHERE MR.parent_relationship_id = c_relationship_id
                              AND trunc(nvl(MR.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                              AND trunc(nvl(MR.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                           )
	   --
	   -- and it satisfies other checks like serial number, instance and item number that are passed
	   --
           AND upper(M.concatenated_segments) LIKE nvl(c_item_number,'%')
           AND upper(C.instance_number) LIKE nvl(c_instance_number,'%')
           AND upper(nvl(C.serial_number, '%')) LIKE nvl(c_serial_number,'%')
           AND M.organization_id IN (SELECT mp.master_organization_id
                                       FROM mtl_parameters mp, org_organization_definitions ood
                                      WHERE mp.organization_Id = ood.organization_id
                                      -- jaramana on Feb 14, 2008
                                      -- Removed reference to CLIENT_INFO
                                      AND NVL(ood.operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id())
	   AND C.inv_locator_id IN (
	                            SELECT
	                              ILOC.inventory_location_id
	                            FROM
	                              -- jaramana on Feb 14, 2008 for bug 6819370
	                              -- Changed MTL_ITEM_LOCATIONS_KFV to MTL_ITEM_LOCATIONS
	                              MTL_ITEM_LOCATIONS ILOC,
	                              AHL_VISITS_B VST
	                            WHERE
	                              ILOC.subinventory_code = C.inv_subinventory_name
	                              AND ILOC.organization_id = C.inv_organization_id
	                              AND (ILOC.end_date_active IS NULL OR ILOC.end_date_active >= SYSDATE)
	                              AND ILOC.segment19 = c_project_id
	                              AND ILOC.physical_location_id = c_inv_locator_id
	                           )
      AND EXISTS(--If serial number is present then check the status is "in stores"
                 (SELECT
		   'X'
		  FROM
		   MTL_SERIAL_NUMBERS MSLN,
		   MFG_LOOKUPS SL
		  WHERE
		   C.serial_number is not null
		   AND MSLN.serial_number = C.serial_number
		   AND MSLN.inventory_item_id = C.inventory_item_id
		   AND MSLN.CURRENT_ORGANIZATION_ID = C.INV_ORGANIZATION_ID
		   AND MSLN.CURRENT_STATUS  = SL.lookup_code
		   AND SL.lookup_type = 'SERIAL_NUM_STATUS'
		   AND MSLN.current_status = '3' -- "in stores"
		  )
		  UNION
		  --If serial number not present then check on hand quantity > 0
		  (
		   SELECT
		    'X'
		   FROM
		    MTL_ONHAND_QUANTITIES MOQ
		   WHERE
		    C.serial_number is null
		    AND MOQ.inventory_item_id = C.inventory_item_id
		    AND MOQ.ORGANIZATION_ID = C.INV_ORGANIZATION_ID
  		    AND MOQ.TRANSACTION_QUANTITY > 0
		  )
		);

-- Cursor for validating relationship
CURSOR check_relationship_id
IS
SELECT
   relationship_id
FROM
   ahl_mc_relationships
WHERE
    relationship_id = p_relationship_id
    AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
    AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    AND mc_header_id IN (
                         SELECT
                            mc_header_id
                         FROM
                            ahl_mc_headers_b
                         WHERE
                             config_status_code = 'COMPLETE'
                        );
-- Cursor for checking parent instance.
CURSOR check_parent_instance(c_instance_id NUMBER)
IS
  --Parent instance could be either in ahl_unit_config_headers(top node) or in csi_ii_relationships
  --(as the subject_id)
SELECT
  'x'
FROM
   ahl_unit_config_headers
WHERE
   csi_item_instance_id = c_instance_id
   AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)

UNION ALL

SELECT
    'x'
FROM
    csi_ii_relationships
WHERE
    subject_id = c_instance_id
    AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE);

-- Cursor for getting top node instance
CURSOR get_top_unit_instance(c_instance_id NUMBER)
IS
SELECT
    object_id
FROM
    csi_ii_relationships
WHERE
    object_id NOT IN (SELECT subject_id
                               FROM csi_ii_relationships
                              WHERE relationship_type_code = 'COMPONENT-OF'
                                AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
                                AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

-- Cursor for getting UC status.
CURSOR get_uc_status(c_instance_id NUMBER) IS
    SELECT unit_config_status_code
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR ahl_instance_details (c_csi_item_instance_id IN NUMBER) IS
    SELECT A.csi_item_instance_id,
           A.csi_object_version csi_object_version_number,
           A.item_number,
           A.item_description,
           A.csi_instance_number,
           A.inventory_item_id,
           A.inventory_org_id,
           A.organization_code,
           A.serial_number,
           A.revision,
           A.lot_number,
           A.uom_code,
           A.quantity,
           A.install_date,
           A.mfg_date,
           A.location_description,
           A.party_type,
           A.owner_id,
           A.owner_number,
           A.owner_name,
           A.csi_location_id owner_site_id,
           A.owner_site_number,
           A.csi_party_object_version_num,
           A.status,
           A.condition,
           A.wip_entity_name,
           B.uc_header_id,
           B.uc_name,
           B.uc_status,
           B.mc_header_id,
           B.mc_name,
           B.mc_revision,
           B.mc_status,
           B.position_ref,
           B.root_uc_header_id
      FROM ahl_unit_installed_details_v A,
           ahl_unit_config_headers_v B
     WHERE csi_item_instance_id = c_csi_item_instance_id
       AND A.csi_item_instance_id = B.csi_instance_id (+)
       AND trunc(nvl(B.active_end_date (+), SYSDATE+1)) > trunc(SYSDATE);
  l_instance_details_rec ahl_instance_details%ROWTYPE;

CURSOR get_priority (c_item_association_id IN NUMBER) IS
    SELECT priority
    FROM ahl_item_associations_b
    WHERE item_association_id = c_item_association_id;

CURSOR get_csi_ii_relationship_ovn (c_instance_id NUMBER) IS
    SELECT object_version_number
      FROM csi_ii_relationships
     WHERE subject_id = c_instance_id
       AND position_reference IS NULL
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_csi_ii_relationship_ovn   NUMBER;

CURSOR c_get_locator_segments(c_inv_location_id NUMBER)
IS
SELECT
  concatenated_segments
FROM
  MTL_ITEM_LOCATIONS_KFV
WHERE
  inventory_location_id = c_inv_location_id;

-- declare all local variables here
  l_api_name       CONSTANT   VARCHAR2(30) := 'Get_Avail_Subinv_Instances';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_relationship_id           NUMBER;
  l_item_assoc_id             NUMBER;
  l_priority                  NUMBER;
  i                           NUMBER;
  j                           NUMBER;
  l_dummy_char                VARCHAR2(1);
  l_top_uc_status             ahl_unit_config_headers.unit_config_status_code%TYPE;
  l_top_instance_id           NUMBER;
  l_status                    fnd_lookup_values_vl.meaning%TYPE;
  l_msg_count                 NUMBER;

BEGIN

     -- 0. Intial logic for the API.
     -------------------------------
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.compatible_api_call(
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                      'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
   			       'At the start of the procedure');
     END IF;


     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'Logging API inputs');
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     '******************');
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'p_relationship_id->'||p_relationship_id);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'p_item_number->'||p_item_number);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'p_serial_number->'||p_serial_number);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'p_instance_number->'||p_instance_number);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'p_workorder_id->'||p_workorder_id);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'p_start_row_index->'||p_start_row_index);
     	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
     		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
     			     'p_max_rows->'||p_max_rows);
     END IF;

     --1. Do all mandatory validation here.
     --------------------------------------
     -- Work Order id is mandatory parmater. Throw error if its not passed.
     IF p_workorder_id IS NULL THEN
        -- Workorder is mandatory. Throw an error.
         FND_MESSAGE.set_name( 'AHL','AHL_COM_PARAM_MISSING' );-- check the message name here.
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- 1.b get all visit details and its validations
     OPEN c_get_visit_details(p_workorder_id);
     FETCH c_get_visit_details INTO l_visit_details_rec;
     CLOSE c_get_visit_details;

     -- 1.a validation corresponding to Work Order
     IF l_visit_details_rec.wip_entity_id IS NULL THEN
         FND_MESSAGE.set_name( 'AHL','AHL_UC_WORKORDER_INVALID' );
         FND_MESSAGE.set_token('WORKORDER', p_workorder_id);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'Visit Id derived->'||l_visit_details_rec.visit_id);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'project_id derived ->'||l_visit_details_rec.project_id);
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'inv_locator_id setup at visit level->'||l_visit_details_rec.inv_locator_id);
     END IF;

     -- Rest of the logic is not applicable if visit doesnt have subinventory or inv_locator_id defined
     IF l_visit_details_rec.inv_locator_id IS NULL THEN
       RETURN;
     END IF;

     -- 1.c validation corresponding to relationship
     OPEN check_relationship_id;
     FETCH check_relationship_id INTO l_relationship_id;
     CLOSE check_relationship_id;

     IF l_relationship_id IS NULL THEN
       FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_INVALID' );
       FND_MESSAGE.set_token('POSITION', p_relationship_id);
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     i := 0;
     j := 0;
     -- 2. Fetch all applicable instances and populate it in the out variable
     FOR  l_subinv_inst_rec IN c_get_subinv_inst(p_relationship_id,
                        			 p_item_number,
                        			 p_instance_number,
                        			 p_serial_number,
                        			 l_visit_details_rec.wip_entity_id,
						 l_visit_details_rec.project_id,
						 l_visit_details_rec.inv_locator_id)
     LOOP

	    --If the instance is not a unit then, call procedure to validate whether thecorresponding inventory
	    --can be assigned to that position

	    IF l_subinv_inst_rec.uc_header_id IS NULL THEN
        AHL_UTIL_UC_PKG.validate_for_position(p_mc_relationship_id   => p_relationship_id,
                p_inventory_id         => l_subinv_inst_rec.inventory_item_id,
                p_organization_id      => l_subinv_inst_rec.inv_master_organization_id,
                p_quantity             => l_subinv_inst_rec.quantity,
                p_revision             => l_subinv_inst_rec.inventory_revision,
                p_uom_code             => l_subinv_inst_rec.uom_code,
                p_position_ref_meaning => NULL,
                x_item_assoc_id        => l_item_assoc_id,
                --Added by mpothuku on 17-May-2007 to fix the OGMA Issue 105.
                p_ignore_quant_vald    => 'Y');
	    END IF;

	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
				     'After position validation for l_subinv_inst_rec.instance_id->'||l_subinv_inst_rec.instance_id);
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
				     'fnd_msg_pub.count_msg->'||fnd_msg_pub.count_msg);
	    END IF;

	    IF (fnd_msg_pub.count_msg = 0) THEN
	      i := i + 1;
	      IF (i >= p_start_row_index AND i < p_start_row_index + p_max_rows) THEN
		OPEN ahl_instance_details(l_subinv_inst_rec.instance_id);
		FETCH ahl_instance_details INTO l_instance_details_rec;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
				     'l_instance_details_rec.csi_item_instance_id->'||l_instance_details_rec.csi_item_instance_id);
		END IF;

		IF (ahl_instance_details%FOUND) THEN
		  j := j + 1;
		  x_avail_subinv_instance_tbl(j).csi_item_instance_id := l_instance_details_rec.csi_item_instance_id;
		  x_avail_subinv_instance_tbl(j).csi_object_version_number := l_instance_details_rec.csi_object_version_number;
		  x_avail_subinv_instance_tbl(j).item_number := l_instance_details_rec.item_number;
		  x_avail_subinv_instance_tbl(j).item_description := l_instance_details_rec.item_description;
		  x_avail_subinv_instance_tbl(j).csi_instance_number := l_instance_details_rec.csi_instance_number;
		  x_avail_subinv_instance_tbl(j).organization_code := l_instance_details_rec.organization_code;
		  x_avail_subinv_instance_tbl(j).inventory_item_id := l_instance_details_rec.inventory_item_id;
		  x_avail_subinv_instance_tbl(j).inventory_org_id := l_instance_details_rec.inventory_org_id;
		  x_avail_subinv_instance_tbl(j).serial_number := l_instance_details_rec.serial_number;
		  x_avail_subinv_instance_tbl(j).revision := l_instance_details_rec.revision;
		  x_avail_subinv_instance_tbl(j).lot_number := l_instance_details_rec.lot_number;
		  x_avail_subinv_instance_tbl(j).uom_code := l_instance_details_rec.uom_code;
		  x_avail_subinv_instance_tbl(j).quantity := l_instance_details_rec.quantity;
		  x_avail_subinv_instance_tbl(j).install_date := l_instance_details_rec.install_date;
		  x_avail_subinv_instance_tbl(j).mfg_date := l_instance_details_rec.mfg_date;
		  -- Verify if location description return correct details else
		  -- the logic in ahl_util_uc_pkg.getcsi_locationDesc need to be modified or
		  -- a new cursor need to be opened to get correct description.
		  x_avail_subinv_instance_tbl(j).location_description := l_instance_details_rec.location_description;
		  x_avail_subinv_instance_tbl(j).party_type := l_instance_details_rec.party_type;
		  x_avail_subinv_instance_tbl(j).owner_site_number := l_instance_details_rec.owner_site_number;
		  x_avail_subinv_instance_tbl(j).owner_site_ID := l_instance_details_rec.owner_site_ID;
		  x_avail_subinv_instance_tbl(j).owner_number := l_instance_details_rec.owner_number;
		  x_avail_subinv_instance_tbl(j).owner_name := l_instance_details_rec.owner_name;
		  x_avail_subinv_instance_tbl(j).owner_ID := l_instance_details_rec.owner_ID;
		  x_avail_subinv_instance_tbl(j).csi_party_object_version_num := l_instance_details_rec.csi_party_object_version_num;
		  x_avail_subinv_instance_tbl(j).status := l_instance_details_rec.status;
		  x_avail_subinv_instance_tbl(j).condition := l_instance_details_rec.condition;
		  x_avail_subinv_instance_tbl(j).wip_entity_name := l_instance_details_rec.wip_entity_name;
		  x_avail_subinv_instance_tbl(j).uc_header_id := l_instance_details_rec.uc_header_id;
		  x_avail_subinv_instance_tbl(j).uc_name := l_instance_details_rec.uc_name;
		  --Modified on 02/26/2004 in case the status inconsistency occurred between an extra sub-unit and
		  --its root unit

		  IF l_instance_details_rec.root_uc_header_id IS NOT NULL THEN
		    SELECT uc_status INTO l_status
		      FROM ahl_unit_config_headers_v
		     WHERE uc_header_id = l_instance_details_rec.root_uc_header_id;
		    x_avail_subinv_instance_tbl(j).uc_status := l_status;
		  ELSE
		    x_avail_subinv_instance_tbl(j).uc_status := l_instance_details_rec.uc_status;
		  END IF;
		  x_avail_subinv_instance_tbl(j).mc_header_id := l_instance_details_rec.mc_header_id;
		  x_avail_subinv_instance_tbl(j).mc_name := l_instance_details_rec.mc_name;
		  x_avail_subinv_instance_tbl(j).mc_revision := l_instance_details_rec.mc_revision;
		  x_avail_subinv_instance_tbl(j).mc_status := l_instance_details_rec.mc_status;
		  x_avail_subinv_instance_tbl(j).position_ref := l_instance_details_rec.position_ref;
		  --Get priority

		  OPEN get_priority(l_item_assoc_id);
		  FETCH get_priority INTO l_priority;
		  CLOSE get_priority;
		  x_avail_subinv_instance_tbl(j).priority := l_priority;
		  --If the instance is an extra sibling node, then get its object version number in
		  --table csi_ii_relationship
		  OPEN get_csi_ii_relationship_ovn(x_avail_subinv_instance_tbl(j).csi_item_instance_id);
		  FETCH get_csi_ii_relationship_ovn INTO l_csi_ii_relationship_ovn;
		  IF get_csi_ii_relationship_ovn%FOUND THEN
		    x_avail_subinv_instance_tbl(j).csi_ii_relationship_ovn := l_csi_ii_relationship_ovn;
		  ELSE
		    x_avail_subinv_instance_tbl(j).csi_ii_relationship_ovn := NULL;
		  END IF;
		  CLOSE get_csi_ii_relationship_ovn;

		  x_avail_subinv_instance_tbl(j).subinventory_code :=  l_subinv_inst_rec.inv_subinventory_name;
		  x_avail_subinv_instance_tbl(j).inventory_locator_id :=  l_subinv_inst_rec.inv_locator_id;

		  OPEN c_get_locator_segments(l_subinv_inst_rec.inv_locator_id);
		  FETCH c_get_locator_segments INTO x_avail_subinv_instance_tbl(j).locator_segments;
		  CLOSE c_get_locator_segments;

		END IF;
		CLOSE ahl_instance_details;
	      END IF;
	    END IF;
	    fnd_msg_pub.initialize;
   END LOOP;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
			     'x_avail_subinv_instance_tbl count->'||x_avail_subinv_instance_tbl.COUNT);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
			       'After normal execution');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

END Get_Avail_Subinv_Instances;

-- Define procedure get_available_instances
-- This API is used to get all the available instances for a given node in a UC tree.

PROCEDURE get_available_instances(
  p_api_version            IN  NUMBER := 1.0,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  p_parent_instance_id     IN  NUMBER, --in order to include the extra siblings
  p_relationship_id        IN  NUMBER,
  p_item_number            IN  VARCHAR2 :='%',
  p_serial_number          IN  VARCHAR2 :='%',
  p_instance_number        IN  VARCHAR2 :='%',
  p_workorder_id           IN  NUMBER := NULL, --required by Part Changes
  p_start_row_index        IN  NUMBER,
  p_max_rows               IN  NUMBER,
  x_available_instance_tbl OUT NOCOPY available_instance_tbl_type,
  x_tbl_count              OUT NOCOPY NUMBER)
IS
  l_api_name       CONSTANT   VARCHAR2(30) := 'get_available_instances';
  l_api_version    CONSTANT   NUMBER       := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_relationship_id           NUMBER;

  -- SATHAPLI Bug# 4912576 fix
  -- Code pertaining to Org check has been removed from here
  -- Please refer earlier version for the details

  l_instance_id               NUMBER;
  l_inventory_item_id         NUMBER;
  l_instance_number           csi_item_instances.instance_number%TYPE := upper(nvl(p_instance_number, '%'));
  l_inventory_org_id          NUMBER;
  l_quantity                  NUMBER;
  l_inventory_revision        VARCHAR2(3);
  l_uom_code                  VARCHAR2(3);
  l_item_assoc_id             NUMBER;
  l_priority                  NUMBER;
  l_item_number               mtl_system_items_kfv.concatenated_segments%TYPE :=upper(nvl(p_item_number, '%'));
  l_serial_number             csi_item_instances.serial_number%TYPE := upper(nvl(p_serial_number, '%'));
  l_uc_header_id              NUMBER;
  i                           NUMBER;
  j                           NUMBER;
  l_dummy_char                VARCHAR2(1);
  l_top_uc_status             ahl_unit_config_headers.unit_config_status_code%TYPE;
  l_top_instance_id           NUMBER;
  l_status                    fnd_lookup_values_vl.meaning%TYPE;
  l_ignore_quant_vald         VARCHAR2(1);

  -- SATHAPLI Bug# 4912576 fix
  -- Code pertaining to Org check has been removed from here
  -- cursor get_instance1 is not used anymore
  -- Please refer earlier version for the details

  --Cursor to pick up all instances that match the item association setup. But units can only
  --be installed in MC leaf node which has associated sub-MC, in other words, any units
  --can't be installed in a branch node. Also need to include those sibling extra nodes which
  --are item-matched to the position

  CURSOR get_instance2(c_relationship_id NUMBER,
                       c_item_number VARCHAR2,
                       c_instance_number VARCHAR2,
                       c_serial_number VARCHAR2,
                       c_wip_job_id NUMBER,
                       c_parent_instance_id NUMBER,
                       c_uc_status VARCHAR2) IS

  -- SATHAPLI Bug# 4912576 fix::SQLid 14402108
  -- The query was changed to the following one for performance improvement.
  -- Please refer earlier version for previous query.
SELECT
    C.instance_id,
    C.instance_number,
    C.inventory_item_id,
    C.inv_master_organization_id,
    C.quantity,
    C.inventory_revision,
    C.unit_of_measure uom_code,
    to_number(NULL) uc_header_id
FROM csi_item_instances C,
    mtl_system_items_kfv M,
    ahl_mc_relationships R,
    ahl_item_associations_b A
WHERE C.inventory_item_id = M.inventory_item_id
    AND C.inv_master_organization_id = M.organization_id
    AND R.item_group_id = A.item_group_id
    AND C.inventory_item_id = A.inventory_item_id
    AND R.relationship_id = c_relationship_id
    AND trunc(nvl(R.active_start_date, SYSDATE)) <= trunc(SYSDATE)
    AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    AND trunc(nvl(C.active_start_date, SYSDATE)) <= trunc(SYSDATE)
    AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    -- SATHAPLI::FP Bug 7498459, 27-Nov-2008 - For the root position, i.e. for UC header creation, make the inventory
    -- instances available, which are not issued to any job. This should be done only for the edit UC flow, i.e.
    -- when c_wip_job_id is NULL.
    -- AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')
    AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT', (DECODE(c_parent_instance_id, NULL, 'X', 'INVENTORY')))
    AND A.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
    AND nvl(A.revision, nvl(C.inventory_revision,-1)) = nvl(C.inventory_revision,-1)
    AND (
        (c_wip_job_id IS NULL -- SATHAPLI, 30-Jan-2008 :: extra nodes should not come up during parts change
         AND
         EXISTS
            (
            SELECT 1
            FROM csi_ii_relationships i2
            WHERE i2.subject_id = C.instance_id
                AND i2.position_reference IS NULL --because parent is not extra
                -- SATHAPLI::FP ER 6504147, 18-Nov-2008
                -- include extra nodes of all the parents uptill root
                -- AND i2.object_id = NVL(c_parent_instance_id, -1)
                AND i2.object_id IN (
                                     SELECT i3.object_id
                                     FROM   csi_ii_relationships i3
                                     START WITH i3.subject_id = nvl(c_parent_instance_id, -1)
                                     AND    i3.relationship_type_code = 'COMPONENT-OF'
                                     AND    trunc(nvl(i3.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                                     AND    trunc(nvl(i3.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                                     CONNECT BY i3.subject_id = PRIOR i3.object_id
                                     AND    i3.relationship_type_code = 'COMPONENT-OF'
                                     AND    trunc(nvl(i3.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                                     AND    trunc(nvl(i3.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                                     UNION ALL
                                     SELECT nvl(c_parent_instance_id, -1)
                                     FROM   DUAL
                                    )
                AND i2.relationship_type_code = 'COMPONENT-OF'
                AND trunc(nvl(i2.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                AND trunc(nvl(i2.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
            )
        )
        OR
        (NOT EXISTS
            (
            SELECT 1
            FROM csi_ii_relationships i1
            WHERE i1.subject_id = C.instance_id
                AND i1.relationship_type_code = 'COMPONENT-OF'
                AND trunc(nvl(i1.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                AND trunc(nvl(i1.active_end_date, SYSDATE+1)) >trunc(SYSDATE)
            )
            -- SATHAPLI, 30-Jan-2008 :: If c_wip_job_id is not passed, instances issued to any job should not be fetched.
            -- If c_wip_job_id is passed, then fetch only those instances which are issued to this job.
            -- AND nvl(C.wip_job_id, -1) = nvl(c_wip_job_id, nvl(C.wip_job_id, -1))
            AND ((c_wip_job_id IS NULL AND C.wip_job_id IS NULL)
                 OR
                 (c_wip_job_id IS NOT NULL AND c_wip_job_id = NVL(C.wip_job_id, -1))
                )
        )
    )
    --This wip_entity check is not necessary for an extra sibling nodes even for
    --so just include it here.
    AND NOT EXISTS
    (
    SELECT 1
    FROM ahl_unit_config_headers H
    WHERE H.csi_item_instance_id = C.instance_id
        AND trunc(nvl(H.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    )
    AND upper(M.concatenated_segments) LIKE c_item_number
    AND upper(C.instance_number) LIKE c_instance_number
    AND upper(nvl(C.serial_number, '%')) LIKE c_serial_number
    AND EXISTS
    (
     SELECT 'X'
     FROM   mtl_parameters mp, inv_organization_info_v io
     WHERE  mp.master_organization_id = M.organization_id AND
            mp.organization_Id = io.organization_id AND
            NVL(io.operating_unit, mo_global.get_current_org_id()) =
            mo_global.get_current_org_id()
    )
    --Plus those units could be installed
UNION ALL
SELECT
    C.instance_id,
    C.instance_number,
    C.inventory_item_id,
    C.inv_master_organization_id,
    C.quantity,
    C.inventory_revision,
    C.unit_of_measure uom_code,
    U.uc_header_id uc_header_id
FROM (
      SELECT UH.unit_config_header_id uc_header_id,
             UH.csi_item_instance_id csi_instance_id,
             UH.master_config_id mc_header_id,
             UH.unit_config_status_code uc_status_code,
             UH.active_end_date,
             CR.object_id parent_instance_id
      FROM   ahl_unit_config_headers UH, csi_ii_relationships CR
      WHERE  UH.csi_item_instance_id = CR.subject_id (+) AND
             CR.relationship_type_code (+) = 'COMPONENT-OF' AND
             trunc(nvl(CR.active_start_date (+), SYSDATE)) <= trunc(SYSDATE) AND
             trunc(nvl(CR.active_end_date (+), SYSDATE+1)) > trunc(SYSDATE)
     ) U,
    csi_item_instances C,
    mtl_system_items_kfv M
WHERE U.csi_instance_id = C.instance_id
    AND C.inventory_item_id = M.inventory_item_id
    AND C.inv_master_organization_id = M.organization_id
    -- SATHAPLI::Bug 9022080, 05-Nov-2009, filter out sub UCs in INVENTORY, i.e. with root instance in INVENTORY
    AND C.location_type_code NOT IN ('INVENTORY')
    AND trunc(nvl(U.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    --Per Barry, if the top instance is expired then this UC is also taken as
    --Either JOIN or IN, performance cost is bigger than EXISTS
    AND EXISTS
    (
    SELECT 1
    FROM ahl_mc_config_relations R
    WHERE R.mc_header_id = U.mc_header_id
        AND R.relationship_id = c_relationship_id
        AND trunc(nvl(R.active_start_date, SYSDATE)) <= trunc(SYSDATE)
        AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    )
    --Either a separate unit or extra sibling subunit
    AND (
        (
            U.parent_instance_id IS NULL
            AND decode(U.uc_status_code, 'DRAFT', 'DRAFT',
                       'APPROVAL_REJECTED', 'DRAFT',
                       'COMPLETE','COMPLETE',
                       'INCOMPLETE','COMPLETE', NULL) = c_uc_status
            -- SATHAPLI, 30-Jan-2008 :: If c_wip_job_id is not passed, instances issued to any job should not be fetched.
            -- If c_wip_job_id is passed, then fetch only those instances which are issued to this job.
            -- AND nvl(C.wip_job_id, -1) = nvl(c_wip_job_id, nvl(C.wip_job_id, -1))
            AND ((c_wip_job_id IS NULL AND C.wip_job_id IS NULL)
                 OR
                 (c_wip_job_id IS NOT NULL AND c_wip_job_id = NVL(C.wip_job_id, -1))
                )
        )
        --This wip_entity check is not necessary for an extra sibling nodes even
        --so just include it here.
        OR
        (
            c_wip_job_id IS NULL -- SATHAPLI::ER# 6504147 :: extra nodes should not come up during parts change
            AND
            -- SATHAPLI::FP ER 6504147, 18-Nov-2008
            -- include extra nodes of all the parents uptill root
            -- U.parent_instance_id = nvl(c_parent_instance_id, -1)
            U.parent_instance_id IN (
                                     SELECT i3.object_id
                                     FROM   csi_ii_relationships i3
                                     START WITH i3.subject_id = nvl(c_parent_instance_id, -1)
                                     AND    i3.relationship_type_code = 'COMPONENT-OF'
                                     AND    trunc(nvl(i3.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                                     AND    trunc(nvl(i3.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                                     CONNECT BY i3.subject_id = PRIOR i3.object_id
                                     AND    i3.relationship_type_code = 'COMPONENT-OF'
                                     AND    trunc(nvl(i3.active_start_date, SYSDATE)) <= trunc(SYSDATE)
                                     AND    trunc(nvl(i3.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
                                     UNION ALL
                                     SELECT nvl(c_parent_instance_id, -1)
                                     FROM   DUAL
                                    )
            AND EXISTS
            (SELECT 1
            FROM csi_ii_relationships CI
            WHERE CI.object_id = U.parent_instance_id
                AND CI.subject_id = U.csi_instance_id
                AND CI.position_reference IS NULL
                AND CI.relationship_type_code = 'COMPONENT-OF'
                AND trunc(nvl(CI.active_start_date,SYSDATE)) <= trunc(SYSDATE)
                AND trunc(nvl(CI.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
            )
        )
    )
    AND NOT EXISTS
    (SELECT 1
    FROM ahl_mc_relationships MR
    WHERE MR.parent_relationship_id = c_relationship_id
        AND trunc(nvl(MR.active_start_date, SYSDATE)) <= trunc(SYSDATE)
        AND trunc(nvl(MR.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    )
    AND upper(M.concatenated_segments) LIKE c_item_number
    AND upper(C.instance_number) LIKE c_instance_number
    AND upper(nvl(C.serial_number, '%')) LIKE c_serial_number
    AND EXISTS
    (
     SELECT 'X'
     FROM   mtl_parameters mp, inv_organization_info_v io
     WHERE  mp.master_organization_id = M.organization_id AND
            mp.organization_Id = io.organization_id AND
            NVL(io.operating_unit, mo_global.get_current_org_id()) =
            mo_global.get_current_org_id()
    )
    AND ahl_util_uc_pkg.IS_UNIT_QUARANTINED(U.uc_header_id , null) =
        FND_API.G_FALSE
ORDER BY 2;

  CURSOR check_relationship_id IS
    SELECT relationship_id
      FROM ahl_mc_relationships
     WHERE relationship_id = p_relationship_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND mc_header_id IN (SELECT mc_header_id
                              FROM ahl_mc_headers_b
                             WHERE config_status_code = 'COMPLETE');

  CURSOR get_priority (c_item_association_id IN NUMBER) IS
    SELECT priority
    FROM ahl_item_associations_b
    WHERE item_association_id = c_item_association_id;

  -- SATHAPLI Bug# 4912576 fix::SQLid 14402138
  -- The cursor definition below is changed so that reference
  -- to view ahl_unit_config_headers_v is changed to base tables.
  -- Please refer earlier version for previous definition.
  CURSOR ahl_instance_details (c_csi_item_instance_id IN NUMBER) IS
select a.csi_item_instance_id,
       a.csi_object_version csi_object_version_number,
       a.item_number,
       a.item_description,
       a.csi_instance_number,
       a.inventory_item_id,
       a.inventory_org_id,
       a.organization_code,
       a.serial_number,
       a.revision,
       a.lot_number,
       a.uom_code,
       a.quantity,
       a.install_date,
       a.mfg_date,
       a.location_description,
       a.party_type,
       a.owner_id,
       a.owner_number,
       a.owner_name,
       a.csi_location_id owner_site_id,
       a.owner_site_number,
       a.csi_party_object_version_num,
       a.status,
       a.condition,
       a.wip_entity_name,
       b.uc_header_id,
       b.uc_name,
       b.uc_status,
       b.mc_header_id,
       b.mc_name,
       b.mc_revision,
       b.mc_status,
       b.position_ref,
       b.root_uc_header_id
 from  ahl_unit_installed_details_v a,
       (
        SELECT U.unit_config_header_id uc_header_id,
               U.name uc_name,
               UCSC.meaning uc_status,
               U.master_config_id mc_header_id,
               M.name mc_name,
               M.revision mc_revision,
               MCSC.meaning mc_status,
               MRSC.meaning position_ref,
               (
                SELECT unit_config_header_id
                FROM   ahl_unit_config_headers
                WHERE  parent_uc_header_id IS NULL
                START WITH
                       unit_config_header_id = U.unit_config_header_id
                CONNECT BY
                       unit_config_header_id = PRIOR parent_uc_header_id
               ) root_uc_header_id,
               U.csi_item_instance_id csi_instance_id,
               U.active_end_date active_end_date
        FROM   AHL_UNIT_CONFIG_HEADERS U, AHL_MC_HEADERS_B M,
               AHL_MC_RELATIONSHIPS R, FND_LOOKUP_VALUES UCSC,
               FND_LOOKUP_VALUES MRSC, FND_LOOKUP_VALUES MCSC
        WHERE  U.master_config_id = M.mc_header_id AND
               M.mc_header_id = R.mc_header_id AND
               R.parent_relationship_id IS NULL AND
               U.unit_config_status_code = UCSC.lookup_code AND
               'AHL_CONFIG_STATUS' = UCSC.lookup_type AND
	       UCSC.language = USERENV('LANG') AND
               M.config_status_code = MCSC.lookup_code AND
               'AHL_CONFIG_STATUS' = MCSC.lookup_type AND
	       MCSC.language = USERENV('LANG') AND
               R.position_ref_code = MRSC.lookup_code AND
               'AHL_POSITION_REFERENCE' = MRSC.lookup_type AND
	       MRSC.language = USERENV('LANG')
       ) b
where  a.csi_item_instance_id = c_csi_item_instance_id
  and  a.csi_item_instance_id = b.csi_instance_id (+)
  and  trunc(nvl(b.active_end_date (+), sysdate+1)) > trunc(sysdate);

  l_instance_details_rec ahl_instance_details%ROWTYPE;

  CURSOR get_wip_entity_id (c_workorder_id NUMBER) IS
    SELECT wip_entity_id
      FROM ahl_workorders
     WHERE workorder_id = c_workorder_id;
  l_wip_entity_id   NUMBER;

  CURSOR check_parent_instance(c_instance_id NUMBER) IS
  --Parent instance could be either in ahl_unit_config_headers(top node) or in csi_ii_relationships
  --(as the subject_id)
    SELECT 'x'
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
     UNION ALL
    SELECT 'x'
      FROM csi_ii_relationships
     WHERE subject_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE);

  CURSOR get_top_unit_instance(c_instance_id NUMBER) IS

  -- SATHAPLI::Bug#4912576 fix::SQL ID 14402149 --
  /*
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id NOT IN (SELECT subject_id
                               FROM csi_ii_relationships
                              WHERE relationship_type_code = 'COMPONENT-OF'
                                AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
                                AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  */
    SELECT object_id
    FROM   csi_ii_relationships co
    WHERE  NOT EXISTS
           (
            SELECT 'X'
            FROM   csi_ii_relationships ci
            WHERE  ci.relationship_type_code = 'COMPONENT-OF' AND
                   ci.subject_id = co.object_id AND
                   trunc(nvl(ci.active_start_date,SYSDATE)) <= trunc(SYSDATE) AND
                   trunc(nvl(ci.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
           )
           START WITH co.subject_id = c_instance_id AND
           co.relationship_type_code = 'COMPONENT-OF' AND
           trunc(nvl(co.active_start_date,SYSDATE)) <= trunc(SYSDATE) AND
           trunc(nvl(co.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
           CONNECT BY co.subject_id = PRIOR co.object_id AND
           co.relationship_type_code = 'COMPONENT-OF' AND
           trunc(nvl(co.active_start_date,SYSDATE)) <= trunc(SYSDATE) AND
           trunc(nvl(co.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_status(c_instance_id NUMBER) IS
    SELECT unit_config_status_code
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_csi_ii_relationship_ovn (c_instance_id NUMBER) IS
    SELECT object_version_number
      FROM csi_ii_relationships
     WHERE subject_id = c_instance_id
       AND position_reference IS NULL
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_csi_ii_relationship_ovn   NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  OPEN check_relationship_id;
  FETCH check_relationship_id INTO l_relationship_id;
  IF check_relationship_id%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_INVALID' );
    FND_MESSAGE.set_token('POSITION', p_relationship_id);
    FND_MSG_PUB.add;
    CLOSE check_relationship_id;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_relationship_id;
  END IF;

  --Get wip_entity_id from p_workorder_id
  IF p_workorder_id IS NOT NULL THEN
    OPEN get_wip_entity_id(p_workorder_id);
    FETCH get_wip_entity_id INTO l_wip_entity_id;
    IF get_wip_entity_id%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_WORKORDER_INVALID' );
      FND_MESSAGE.set_token('WORKORDER', p_workorder_id);
      FND_MSG_PUB.add;
      CLOSE get_wip_entity_id;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_wip_entity_id;
    END IF;
  ELSE
    l_wip_entity_id := NULL;
  END IF;

  --Validate p_parent_instance_id is Null(for top node) or existing in
  --ahl_unit_config_headers or csi_ii_relationships(for non-top node)
  IF p_parent_instance_id IS NOT NULL THEN
    OPEN check_parent_instance(p_parent_instance_id);
    FETCH check_parent_instance INTO l_dummy_char;
    IF check_parent_instance%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_PARENT_INST_INVALID' );
      FND_MESSAGE.set_token('INSTANCE', p_parent_instance_id);
      FND_MSG_PUB.add;
      CLOSE check_parent_instance;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_parent_instance;
    END IF;
  END IF;

  --Get the instance's ancestor unit's status, just in order to meet the regulation that
  --Draft unit can only be installed into Draft unit and Complete unit can only be installed
  --into Complete unit.
  IF p_parent_instance_id IS NOT NULL THEN --Not top position
    OPEN get_top_unit_instance(p_parent_instance_id);
    FETCH get_top_unit_instance INTO l_top_instance_id;
    IF get_top_unit_instance%NOTFOUND THEN --Parent_instance_id happens to be top node
      l_top_instance_id := p_parent_instance_id;
    END IF;
    CLOSE get_top_unit_instance;

    OPEN get_uc_status(l_top_instance_id);
    FETCH get_uc_status INTO l_top_uc_status;
    IF get_uc_status%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_NOT_IN_UC' );
      FND_MESSAGE.set_token('INSTANCE', l_top_instance_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_status;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_uc_status;
    END IF;
  ELSE
    l_top_uc_status := NULL; --Doesn't matter wether what it is, because no existing units will
  END IF;                    --be available for this top position

  SELECT decode(l_top_uc_status, 'DRAFT', 'DRAFT',
                     'APPROVAL_REJECTED', 'DRAFT',
                            'COMPLETE','COMPLETE',
                    'INCOMPLETE','COMPLETE', NULL) INTO l_top_uc_status
  FROM dual;

  --Based on profile value open the cursor.
  -- SATHAPLI Bug# 4912576 fix
  -- Code pertaining to Org check has been removed from here
  -- Please refer earlier version for the details

    OPEN get_instance2 (p_relationship_id,
                        l_item_number,
                        l_instance_number,
                        l_serial_number,
                        l_wip_entity_id,
                        p_parent_instance_id,
                        l_top_uc_status);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
                       ' ;p_relationship_id = '||p_relationship_id||' ;l_item_number = '||l_item_number||
                       ' ;l_instance_number = '||l_instance_number||' ;l_serial_number = '||l_serial_number||
                       ' ;l_wip_entity_id = '||l_wip_entity_id||' ;p_parent_instance_id = '||p_parent_instance_id||
                       ' ;l_top_uc_status = '||l_top_uc_status);
    END IF;

  i := 0;
  j := 0;
  -- row count.
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
                     'part_number='||l_item_number||'instance_number='||l_instance_number||
                     'serial_number='||l_serial_number||'wip_entity_id='||l_wip_entity_id||
                     'p_parent_instance_id='||p_parent_instance_id);
  END IF;

  LOOP

  -- SATHAPLI Bug# 4912576 fix
  -- Code pertaining to Org check has been removed from here
  -- Please refer earlier version for the details

      FETCH get_instance2 INTO l_instance_id, l_instance_number, l_inventory_item_id, l_inventory_org_id,
                               l_quantity, l_inventory_revision, l_uom_code, l_uc_header_id;
      EXIT WHEN get_instance2%NOTFOUND;

    --If the instance is not a unit then, call procedure to validate whether thecorresponding inventory
    --can be assigned to that position
    IF l_uc_header_id IS NULL THEN
      -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
      -- If p_workorder_id is not NULL, then the call is from Production. So pass 'Y' for p_ignore_quant_vald.
      -- Else, pass 'N' for p_ignore_quant_vald.
      IF(p_workorder_id IS NOT NULL) THEN
        l_ignore_quant_vald := 'Y';
      ELSE
        l_ignore_quant_vald := 'N';
      END IF;

      AHL_UTIL_UC_PKG.validate_for_position(p_mc_relationship_id   => p_relationship_id,
                                            p_inventory_id         => l_inventory_item_id,
                                            p_organization_id      => l_inventory_Org_id,
                                            p_quantity             => l_quantity,
                                            p_revision             => l_inventory_revision,
                                            p_uom_code             => l_uom_code,
                                            p_position_ref_meaning => NULL,
                                            p_ignore_quant_vald    => l_ignore_quant_vald,
                                            x_item_assoc_id        => l_item_assoc_id);
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Within API',
                     'After position validation');
    END IF;

    IF (fnd_msg_pub.count_msg = 0) THEN
      i := i + 1;
      IF (i >= p_start_row_index AND i < p_start_row_index + p_max_rows) THEN
        OPEN ahl_instance_details(l_instance_id);
        FETCH ahl_instance_details INTO l_instance_details_rec;
        IF (ahl_instance_details%FOUND) THEN
          j := j + 1;
          x_available_instance_tbl(j).csi_item_instance_id := l_instance_details_rec.csi_item_instance_id;
          x_available_instance_tbl(j).csi_object_version_number := l_instance_details_rec.csi_object_version_number;
          x_available_instance_tbl(j).item_number := l_instance_details_rec.item_number;
          x_available_instance_tbl(j).item_description := l_instance_details_rec.item_description;
          x_available_instance_tbl(j).csi_instance_number := l_instance_details_rec.csi_instance_number;
          x_available_instance_tbl(j).organization_code := l_instance_details_rec.organization_code;
          x_available_instance_tbl(j).inventory_item_id := l_instance_details_rec.inventory_item_id;
          x_available_instance_tbl(j).inventory_org_id := l_instance_details_rec.inventory_org_id;
          x_available_instance_tbl(j).serial_number := l_instance_details_rec.serial_number;
          x_available_instance_tbl(j).revision := l_instance_details_rec.revision;
          x_available_instance_tbl(j).lot_number := l_instance_details_rec.lot_number;
          x_available_instance_tbl(j).uom_code := l_instance_details_rec.uom_code;
          x_available_instance_tbl(j).quantity := l_instance_details_rec.quantity;
          x_available_instance_tbl(j).install_date := l_instance_details_rec.install_date;
          x_available_instance_tbl(j).mfg_date := l_instance_details_rec.mfg_date;
          x_available_instance_tbl(j).location_description := l_instance_details_rec.location_description;
          x_available_instance_tbl(j).party_type := l_instance_details_rec.party_type;
          x_available_instance_tbl(j).owner_site_number := l_instance_details_rec.owner_site_number;
          x_available_instance_tbl(j).owner_site_ID := l_instance_details_rec.owner_site_ID;
          x_available_instance_tbl(j).owner_number := l_instance_details_rec.owner_number;
          x_available_instance_tbl(j).owner_name := l_instance_details_rec.owner_name;
          x_available_instance_tbl(j).owner_ID := l_instance_details_rec.owner_ID;
          x_available_instance_tbl(j).csi_party_object_version_num := l_instance_details_rec.csi_party_object_version_num;
          x_available_instance_tbl(j).status := l_instance_details_rec.status;
          x_available_instance_tbl(j).condition := l_instance_details_rec.condition;
          x_available_instance_tbl(j).wip_entity_name := l_instance_details_rec.wip_entity_name;
          x_available_instance_tbl(j).uc_header_id := l_instance_details_rec.uc_header_id;
          x_available_instance_tbl(j).uc_name := l_instance_details_rec.uc_name;
          --Modified on 02/26/2004 in case the status inconsistency occurred between an extra sub-unit and
          --its root unit
          IF l_instance_details_rec.root_uc_header_id IS NOT NULL THEN

            -- SATHAPLI::Bug#4912576 fix::SQL ID 14402160 --
	    /*
	    SELECT uc_status INTO l_status
              FROM ahl_unit_config_headers_v
             WHERE uc_header_id = l_instance_details_rec.root_uc_header_id;
            */
            SELECT FLV.meaning INTO l_status
            FROM   AHL_UNIT_CONFIG_HEADERS AUCH, FND_LOOKUP_VALUES FLV
            WHERE  AUCH.unit_config_header_id = l_instance_details_rec.root_uc_header_id AND
                   AUCH.unit_config_status_code = FLV.lookup_code AND
                   FLV.lookup_type  = 'AHL_CONFIG_STATUS' AND
                   FLV.language = USERENV('LANG');

            x_available_instance_tbl(j).uc_status := l_status;
          ELSE
            x_available_instance_tbl(j).uc_status := l_instance_details_rec.uc_status;
          END IF;
          x_available_instance_tbl(j).mc_header_id := l_instance_details_rec.mc_header_id;
          x_available_instance_tbl(j).mc_name := l_instance_details_rec.mc_name;
          x_available_instance_tbl(j).mc_revision := l_instance_details_rec.mc_revision;
          x_available_instance_tbl(j).mc_status := l_instance_details_rec.mc_status;
          x_available_instance_tbl(j).position_ref := l_instance_details_rec.position_ref;
          --Get priority
          OPEN get_priority(l_item_assoc_id);
          FETCH get_priority INTO l_priority;
          CLOSE get_priority;
          x_available_instance_tbl(j).priority := l_priority;
          --If the instance is an extra sibling node, then get its object version number in
          --table csi_ii_relationship
          OPEN get_csi_ii_relationship_ovn(x_available_instance_tbl(j).csi_item_instance_id);
          FETCH get_csi_ii_relationship_ovn INTO l_csi_ii_relationship_ovn;
          IF get_csi_ii_relationship_ovn%FOUND THEN
            x_available_instance_tbl(j).csi_ii_relationship_ovn := l_csi_ii_relationship_ovn;
          ELSE
            x_available_instance_tbl(j).csi_ii_relationship_ovn := NULL;
          END IF;
          CLOSE get_csi_ii_relationship_ovn;
        END IF;
        CLOSE ahl_instance_details;
      END IF;
    END IF;
    fnd_msg_pub.initialize;
  END LOOP;
  x_tbl_count := i;

  -- SATHAPLI Bug# 4912576 fix
  -- Code pertaining to Org check has been removed from here
  -- Please refer earlier version for the details

  IF (get_instance2%ISOPEN) THEN
    CLOSE get_instance2;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': End API',
                   'After normal execution');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END get_available_instances;

-- SATHAPLI::FP ER 6504147, 18-Nov-2008
-- Define procedure create_unassigned_instance.
-- This API is used to create a new instance in csi_item_instances and assign it
-- to the UC root node as extra node.

PROCEDURE create_unassigned_instance(
    p_api_version           IN            NUMBER   := 1.0,
    p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_uc_header_id          IN            NUMBER,
    p_x_uc_instance_rec     IN OUT NOCOPY uc_instance_rec_type
)
IS

CURSOR check_uc_header_csr (p_uc_header_id NUMBER) IS
    SELECT unit_config_header_id,
           unit_config_status_code,
           active_uc_status_code,
           csi_item_instance_id,
           parent_uc_header_id
    FROM   ahl_unit_config_headers
    WHERE  unit_config_header_id  = p_uc_header_id
    AND    trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

CURSOR csi_item_instance_csr(p_csi_instance_id NUMBER) IS
    SELECT location_id,
           location_type_code,
           party_id,
           party_source_table,
           instance_party_id,
           csi.wip_job_id
    FROM   csi_item_instances csi, csi_i_parties p
    WHERE  csi.instance_id          = p.instance_id
    AND    p.relationship_type_code = 'OWNER'
    AND    csi.instance_id          = p_csi_instance_id
    AND    trunc(nvl(csi.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

CURSOR csi_ip_accounts_csr(p_instance_party_id NUMBER) IS
    SELECT party_account_id
    FROM   csi_ip_accounts
    WHERE  relationship_type_code = 'OWNER'
    AND    instance_party_id      = p_instance_party_id
    AND    trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
    AND    trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
--
    l_api_version    CONSTANT   NUMBER       := 1.0;
    l_api_name       CONSTANT   VARCHAR2(30) := 'create_unassigned_instance';
    l_full_name      CONSTANT   VARCHAR2(70) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_check_uc_header_rec       check_uc_header_csr%ROWTYPE;
    l_uc_owner_loc_rec          csi_item_instance_csr%ROWTYPE;
    l_msg_count_bef             NUMBER;
    l_msg_count                 NUMBER;
    l_root_instance_ou          NUMBER;
    l_new_instance_ou           NUMBER;
    l_parent_instance_id        NUMBER;
    l_return_status             VARCHAR2(1);
    l_msg_data                  VARCHAR2(2000);
    l_subscript                 NUMBER       DEFAULT 0;
    i                           NUMBER       := 0;
    l_transaction_type_id       NUMBER;
    l_return_val                BOOLEAN;
    l_attribute_id              NUMBER;
    l_concatenated_segments     mtl_system_items_kfv.concatenated_segments%TYPE;
    l_new_instance_id           NUMBER;
    l_new_csi_instance_ovn      NUMBER;
    l_end_date                  DATE;

    -- Variables needed for CSI API call
    l_csi_instance_rec          csi_datastructures_pub.instance_rec;
    l_csi_party_rec             csi_datastructures_pub.party_rec;
    l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
    l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
    l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
    l_csi_party_tbl             csi_datastructures_pub.party_tbl;
    l_csi_account_tbl           csi_datastructures_pub.party_account_tbl;
    l_csi_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_csi_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
    l_csi_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
    l_csi_instance_id_lst       csi_datastructures_pub.id_tbl;
    l_party_account_rec         csi_datastructures_pub.party_account_rec;
    l_csi_extend_attrib_rec     csi_datastructures_pub.extend_attrib_values_rec;
    l_csi_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT create_unassigned_instance;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Validate input parameter p_uc_header_id
    OPEN check_uc_header_csr(p_uc_header_id);
    FETCH check_uc_header_csr INTO l_check_uc_header_rec;

    IF check_uc_header_csr%NOTFOUND THEN
        CLOSE check_uc_header_csr;
        -- p_uc_header_id in invalid
        FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
        FND_MESSAGE.set_token('NAME', 'uc_header_id');
        FND_MESSAGE.set_token('VALUE', p_uc_header_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_check_uc_header_rec.unit_config_status_code = 'APPROVAL_PENDING' OR
           l_check_uc_header_rec.active_uc_status_code = 'APPROVAL_PENDING') THEN
        CLOSE check_uc_header_csr;
        -- UC status is not editable
        FND_MESSAGE.set_name('AHL','AHL_UC_STATUS_PENDING');
        FND_MESSAGE.set_token('UC_HEADER_ID', l_check_uc_header_rec.unit_config_header_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_check_uc_header_rec.parent_uc_header_id IS NOT NULL) THEN
        CLOSE check_uc_header_csr;
        -- UC is installed sub config
        FND_MESSAGE.set_name('AHL','AHL_UC_INST_SUB_CONFIG');
        FND_MESSAGE.set_token('UC_HEADER_ID', l_check_uc_header_rec.unit_config_header_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
        CLOSE check_uc_header_csr;
    END IF;

    -- Get the operating unit of the root instance
    l_root_instance_ou := get_operating_unit(l_check_uc_header_rec.csi_item_instance_id);

    -- The parent instance is the root node
    l_parent_instance_id := l_check_uc_header_rec.csi_item_instance_id;

    -- Check whether the UC is expired or not by checking for the root instance
    OPEN get_instance_date(l_parent_instance_id);
    FETCH get_instance_date INTO l_end_date;
    CLOSE get_instance_date;
    IF TRUNC(NVL(l_end_date, SYSDATE+1)) <= TRUNC(SYSDATE) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_STATUS_EXPIRED');
        FND_MESSAGE.set_token('UC_NAME', l_check_uc_header_rec.unit_config_header_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- When creating the new instances, the "From Inventory" Serial Tag should not be used anymore.
    IF(p_x_uc_instance_rec.sn_tag_code IS NOT NULL AND p_x_uc_instance_rec.sn_tag_code = 'INVENTORY') THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_SER_TG_CR_INVEN' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                       ' l_root_instance_ou => '||l_root_instance_ou||
     	               ' l_parent_instance_id => '||l_parent_instance_id);
    END IF;

    -- Get the msg count befrore API call
    l_msg_count_bef := FND_MSG_PUB.count_msg;

    -- Validate Inventory details
    validate_uc_invdetails (
        p_inventory_id          => p_x_uc_instance_rec.inventory_item_id,
        p_organization_id       => p_x_uc_instance_rec.inventory_org_id,
        p_serial_number         => p_x_uc_instance_rec.serial_number,
        p_serialnum_tag_code    => p_x_uc_instance_rec.sn_tag_code,
        p_quantity              => p_x_uc_instance_rec.quantity,
        p_uom_code              => p_x_uc_instance_rec.uom_code,
        p_revision              => p_x_uc_instance_rec.revision,
        p_lot_number            => p_x_uc_instance_rec.lot_number,
        p_position_ref_meaning  => NULL,
        x_concatenated_segments => l_concatenated_segments);

    -- Check Error Message stack
    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > l_msg_count_bef) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate manufacturing date
    IF (p_x_uc_instance_rec.mfg_date IS NOT NULL AND
        p_x_uc_instance_rec.mfg_date <> FND_API.G_MISS_DATE AND
        p_x_uc_instance_rec.mfg_date > SYSDATE) THEN
        -- mfg_date is invalid
        FND_MESSAGE.set_name('AHL','AHL_UC_MFGDATE_INVALID');
        FND_MESSAGE.set_token('DATE',p_x_uc_instance_rec.mfg_date);
        FND_MESSAGE.set_token('INV_ITEM',l_concatenated_segments);
        FND_MSG_PUB.add;
    END IF;

    -- Build CSI records and call API
    -- First get unit config location and owner details
    OPEN csi_item_instance_csr(l_parent_instance_id);
    FETCH csi_item_instance_csr INTO l_uc_owner_loc_rec;

    IF (csi_item_instance_csr%NOTFOUND) THEN
        CLOSE csi_item_instance_csr;
        -- parent instance is invalid
        FND_MESSAGE.set_name('AHL','AHL_UC_CSII_INVALID');
        FND_MESSAGE.set_token('CSII',l_parent_instance_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    CLOSE csi_item_instance_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                       ' l_uc_owner_loc_rec.location_id => '||l_uc_owner_loc_rec.location_id||
                       ' l_uc_owner_loc_rec.location_type_code => '||l_uc_owner_loc_rec.location_type_code||
                       ' l_uc_owner_loc_rec.party_id => '||l_uc_owner_loc_rec.party_id||
                       ' l_uc_owner_loc_rec.party_source_table => '||l_uc_owner_loc_rec.party_source_table||
                       ' l_uc_owner_loc_rec.instance_party_id => '||l_uc_owner_loc_rec.instance_party_id||
                       ' l_uc_owner_loc_rec.wip_job_id => '||l_uc_owner_loc_rec.wip_job_id);
    END IF;

    -- Set csi instance record
    l_csi_instance_rec.inventory_item_id      := p_x_uc_instance_rec.inventory_item_id;
    l_csi_instance_rec.vld_organization_id    := p_x_uc_instance_rec.inventory_org_id;
    l_csi_instance_rec.quantity               := p_x_uc_instance_rec.quantity;
    l_csi_instance_rec.unit_of_measure        := p_x_uc_instance_rec.uom_code;
    l_csi_instance_rec.install_date           := p_x_uc_instance_rec.install_date;
    l_csi_instance_rec.location_id            := l_uc_owner_loc_rec.location_id;
    l_csi_instance_rec.location_type_code     := l_uc_owner_loc_rec.location_type_code;
    l_csi_instance_rec.wip_job_id             := l_uc_owner_loc_rec.wip_job_id;
    l_csi_instance_rec.mfg_serial_number_flag := 'N';
    l_csi_instance_rec.instance_usage_code    := NULL;

    IF (p_x_uc_instance_rec.serial_number IS NOT NULL AND
        p_x_uc_instance_rec.serial_number <> FND_API.G_MISS_CHAR) THEN
        l_csi_instance_rec.serial_number := p_x_uc_instance_rec.serial_number;
    END IF;

    IF (p_x_uc_instance_rec.lot_number IS NOT NULL AND
        p_x_uc_instance_rec.lot_number <> FND_API.G_MISS_CHAR) THEN
        l_csi_instance_rec.lot_number := p_x_uc_instance_rec.lot_number;
    END IF;

    IF (p_x_uc_instance_rec.revision IS NOT NULL AND
        p_x_uc_instance_rec.revision <> FND_API.G_MISS_CHAR) THEN
        l_csi_instance_rec.inventory_revision := p_x_uc_instance_rec.revision;
    END IF;

    -- Build CSI extended attribs
    IF (p_x_uc_instance_rec.mfg_date IS NOT NULL AND
        p_x_uc_instance_rec.mfg_date <> FND_API.G_MISS_DATE) THEN
        AHL_UTIL_UC_PKG.getcsi_attribute_id('AHL_MFG_DATE',l_attribute_id, l_return_val);

        IF NOT(l_return_val) THEN
            FND_MESSAGE.set_name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
            FND_MESSAGE.set_token('CODE', 'AHL_MFG_DATE');
            FND_MSG_PUB.add;
        ELSE
            l_csi_extend_attrib_rec.attribute_id := l_attribute_id;
            l_csi_extend_attrib_rec.attribute_value := to_char(p_x_uc_instance_rec.mfg_date, 'DD/MM/YYYY');
            l_subscript := l_subscript + 1;
            l_csi_ext_attrib_values_tbl(l_subscript) := l_csi_extend_attrib_rec;
        END IF;
    END IF;

    IF (p_x_uc_instance_rec.serial_number IS NOT NULL AND
        p_x_uc_instance_rec.serial_number <> FND_API.G_MISS_CHAR) THEN
        AHL_UTIL_UC_PKG.getcsi_attribute_id('AHL_TEMP_SERIAL_NUM',l_attribute_id, l_return_val);

        IF NOT(l_return_val) THEN
            FND_MESSAGE.set_name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
            FND_MESSAGE.set_token('CODE', 'AHL_TEMP_SERIAL_NUM');
            FND_MSG_PUB.add;
        ELSE
            l_csi_extend_attrib_rec.attribute_id         := l_attribute_id;
            l_csi_extend_attrib_rec.attribute_value      := p_x_uc_instance_rec.sn_tag_code;
            l_csi_ext_attrib_values_tbl(l_subscript + 1) := l_csi_extend_attrib_rec;
        END IF;
    END IF;

    -- Build CSI party record
    l_csi_party_rec.party_id               := l_uc_owner_loc_rec.party_id;
    l_csi_party_rec.relationship_type_code := 'OWNER';
    l_csi_party_rec.party_source_table     := l_uc_owner_loc_rec.party_source_table;
    l_csi_party_rec.contact_flag           := 'N';
    l_csi_party_tbl(1)                     := l_csi_party_rec;

    -- Build CSI accounts table
    FOR party_ip_acct IN csi_ip_accounts_csr(l_uc_owner_loc_rec.instance_party_id)
    LOOP
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                           ' i => '||i||
                           ' party_ip_acct.party_account_id => '||party_ip_acct.party_account_id);
        END IF;

        l_party_account_rec.party_account_id       := party_ip_acct.party_account_id;
        l_party_account_rec.relationship_type_code := 'OWNER';
        l_party_account_rec.parent_tbl_index       := 1;
        i := i + 1;
        l_csi_account_tbl(i)                       := l_party_account_rec;
    END LOOP;

    -- Build CSI transaction record, first get transaction_type_id
    AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_CREATE',l_transaction_type_id, l_return_val);

    IF NOT(l_return_val) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_csi_transaction_rec.source_transaction_date := SYSDATE;
    l_csi_transaction_rec.transaction_type_id     := l_transaction_type_id;

    -- Check Error Message stack
    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > l_msg_count_bef) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                       ' About to call CSI_ITEM_INSTANCE_PUB.create_item_instance');
    END IF;

    --Call CSI API to create instance
    CSI_ITEM_INSTANCE_PUB.create_item_instance(
        p_api_version           => 1.0,
        p_instance_rec          => l_csi_instance_rec,
        p_txn_rec               => l_csi_transaction_rec,
        p_ext_attrib_values_tbl => l_csi_ext_attrib_values_tbl,
        p_party_tbl             => l_csi_party_tbl,
        p_account_tbl           => l_csi_account_tbl,
        p_pricing_attrib_tbl    => l_csi_pricing_attrib_tbl,
        p_org_assignments_tbl   => l_csi_org_assignments_tbl,
        p_asset_assignment_tbl  => l_csi_asset_assignment_tbl,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    l_new_instance_id                         := l_csi_instance_rec.instance_id;
    l_new_csi_instance_ovn                    := l_csi_instance_rec.object_version_number;
    p_x_uc_instance_rec.instance_id           := l_new_instance_id;
    p_x_uc_instance_rec.object_version_number := l_new_csi_instance_ovn;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                       ' After call to CSI_ITEM_INSTANCE_PUB.create_item_instance'||
                       ' instance_id => '||l_csi_instance_rec.instance_id||
     	               ' l_return_status => '||l_return_status||
                       ' p_x_uc_instance_rec.instance_id='||p_x_uc_instance_rec.instance_id);
    END IF;

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Before assigning the new instance as extra node, make sure its operating unit is exactly the same as that
    -- of the root instance
    l_new_instance_ou := get_operating_unit(l_new_instance_id);

    IF l_root_instance_ou IS NULL THEN
        FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_NULL');
        FND_MESSAGE.set_token('INSTANCE', l_parent_instance_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_new_instance_ou IS NULL THEN
        FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_NULL');
        FND_MESSAGE.set_token('INSTANCE', l_new_instance_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_root_instance_ou <> l_new_instance_ou THEN
        FND_MESSAGE.set_name('AHL', 'AHL_UC_INSTANCE_OU_UNMATCH');
        FND_MESSAGE.set_token('INSTANCE', l_new_instance_id);
        FND_MESSAGE.set_token('ROOT_INSTANCE', l_parent_instance_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Build CSI relationships table
    l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
    l_csi_relationship_rec.object_id              := l_parent_instance_id;
    l_csi_relationship_rec.position_reference     := NULL;
    l_csi_relationship_rec.subject_id             := l_new_instance_id;
    l_csi_relationship_tbl(1)                     := l_csi_relationship_rec;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                       ' About to call CSI_II_RELATIONSHIPS_PUB.create_relationship');
    END IF;

    CSI_II_RELATIONSHIPS_PUB.create_relationship(
        p_api_version      => 1.0,
        p_relationship_tbl => l_csi_relationship_tbl,
        p_txn_rec          => l_csi_transaction_rec,
        x_return_status    => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                       ' After call to CSI_II_RELATIONSHIPS_PUB.create_relationship'||
     	               ' l_return_status => '||l_return_status);
    END IF;

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    ( p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE
    );

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to create_unassigned_instance;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to create_unassigned_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to create_unassigned_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END create_unassigned_instance;

END AHL_UC_INSTANCE_PVT; -- Package body,

/
