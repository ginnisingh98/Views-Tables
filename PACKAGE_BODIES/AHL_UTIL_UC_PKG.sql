--------------------------------------------------------
--  DDL for Package Body AHL_UTIL_UC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UTIL_UC_PKG" AS
/*  $Header: AHLUUCB.pls 120.9 2008/03/11 05:52:10 jaramana ship $ */

 G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_UTIL_UC_PKG';

 G_STATUS_COMPLETE     CONSTANT  VARCHAR2(30) := 'COMPLETE';
 G_STATUS_INCOMPLETE   CONSTANT  VARCHAR2(30) := 'INCOMPLETE';
 G_STATUS_EXPIRED      CONSTANT  VARCHAR2(30) := 'EXPIRED';

-- ACL :: Added for R12
 G_STATUS_QUARANTINE     CONSTANT  VARCHAR2(30) := 'QUARANTINE';
 G_STATUS_D_QUARANTINE   CONSTANT  VARCHAR2(30) := 'DEACTIVATE_QUARANTINE';


----------------------------------------
-- Begin Local Procedures Declaration--
----------------------------------------

PROCEDURE update_csi_ii_relationships(
  x_return_status   OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_subject_id IN NUMBER
);

-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

-----------------------------------------------------------
-- Function to get location description for csi instance --
-----------------------------------------------------------

FUNCTION GetCSI_LocationDesc(p_location_id           IN  NUMBER,
                             p_location_type_code    IN  VARCHAR2,
                             p_inventory_org_id      IN  NUMBER,
                             p_subinventory_name     IN  VARCHAR2,
                             p_inventory_locator_id  IN  NUMBER,
                             p_wip_job_id            IN  NUMBER)
RETURN VARCHAR2 IS

  CURSOR mtl_item_locations_csr(p_inventory_org_id      IN  NUMBER,
                                p_inventory_locator_id  IN  NUMBER) IS
    SELECT concatenated_segments
    FROM   mtl_item_locations_kfv
    WHERE inventory_location_id = p_inventory_locator_id
      AND organization_id = p_inventory_org_id;

 -- Bug# 4902980 SQL id: 14398234
 -- Commenting out Cursor ahl_owner_loc_csr and spliting it into
 -- ahl_owner_loc_prty_csr and ahl_owner_loc_vndr_csr
 /*
  CURSOR ahl_owner_loc_csr (p_location_id  IN  NUMBER,
                            p_party_type   IN  VARCHAR2)  IS
    SELECT address
    FROM ahl_owner_locations_v
    WHERE owner_site_id = p_location_id
    AND party_type = p_party_type;
 */

  CURSOR ahl_owner_loc_prty_csr (p_location_id NUMBER) IS
    SELECT hzloc.address1 ||
           decode(hzloc.address2,null,null,';'||hzloc.address2) ||
           decode(hzloc.address3,null,null,';'||hzloc.address3) ||
           decode(hzloc.address4,null,null,';'||hzloc.address4) ||
           decode(hzloc.city,null,null,';'|| hzloc.city) ||
           decode(hzloc.postal_code, null,null,';'||hzloc.postal_code) ||
           decode(hzloc.state,null,null,';'||hzloc.state) ||
           decode(hzloc.province,null,null,';'||hzloc.province) ||
           hzloc.country Address
    FROM   hz_party_sites hzsite, hz_locations hzloc
    WHERE  hzsite.location_id  = hzloc.location_id
    AND    hzsite.party_site_id = p_location_id
    AND    hzsite.status  <> 'I';

  CURSOR ahl_owner_loc_vndr_csr (p_location_id NUMBER) IS
    SELECT decode(address_line1,null,null,address_line1) ||
           decode(address_line2,null,null,';'||address_line2) ||
           decode(address_line3,null,null,';'||address_line3) ||
           decode(city,null,null, ';'||city) ||
           decode(state,null,null,';'||state) ||
           decode(zip,null,null,';'||zip) ||
           decode(province,null,null,';'||province) ||
           decode(country,null,null,';'||country) Address
    FROM   po_vendor_sites_all
    WHERE  vendor_site_id = p_location_id;

  CURSOR hr_locations_csr (p_location_id  IN  NUMBER) IS
    SELECT decode(address_line_1,null,null,address_line_1) ||
           decode(address_line_2,null,null,';'||address_line_2) ||
           decode(address_line_3, null,null,';'||address_line_3) ||
           decode(town_or_city, null,null,';'||town_or_city) ||
           decode(country,null,null,';'||country) Location
    FROM hr_locations_all
    WHERE location_id = p_location_id;

  CURSOR hz_locations_csr(p_location_id  IN  NUMBER) IS
    SELECT hzloc.address1 ||
           decode(hzloc.address2,null,null,';'||hzloc.address2) ||
           decode(hzloc.address3,null,null,';'||hzloc.address3) ||
           decode(hzloc.address4,null,null,';'||hzloc.address4) ||
           decode(hzloc.city,null,null,';'||hzloc.city) ||
           decode(hzloc.postal_code, null,null,';'||hzloc.postal_code) ||
           decode(hzloc.state,null,null,';'||hzloc.state) ||
           decode(hzloc.province,null,null,';'||hzloc.province) ||
           hzloc.country Address
    FROM hz_locations hzloc
    WHERE location_id = p_location_id;

  -- if location is WIP.
  CURSOR wip_entity_csr(p_wip_job_id IN NUMBER) IS
    SELECT f.meaning || ';' || hou.name
    FROM csi_lookups f, hr_all_organization_units hou, wip_entities wip_ent
    WHERE wip_ent.organization_id = hou.organization_id
     AND wip_ent.wip_entity_id = p_wip_job_id
     AND f.lookup_code = 'WIP'
     AND f.lookup_type = 'CSI_INST_LOCATION_SOURCE_CODE';

  -- Get Organization name.
  CURSOR get_org_name_csr (p_organization_id  IN NUMBER) IS
    SELECT name
    FROM hr_all_organization_units
    WHERE organization_id = p_organization_id;

  l_concatenated_segments   mtl_item_locations_kfv.concatenated_segments%TYPE;
  l_location                VARCHAR2(2000);
  l_organization_name       hr_all_organization_units.name%TYPE;


BEGIN
  -- Check location type code.
IF (p_location_type_code = 'INVENTORY') THEN
    -- get organization name.
    OPEN get_org_name_csr(p_inventory_org_id);
    FETCH get_org_name_csr INTO l_organization_name;
    IF (get_org_name_csr%FOUND) THEN
      IF (p_inventory_locator_id IS NOT NULL) THEN
         OPEN mtl_item_locations_csr(p_inventory_org_id, p_inventory_locator_id);

         FETCH  mtl_item_locations_csr INTO l_concatenated_segments;
         IF (mtl_item_locations_csr%FOUND) THEN
           l_location := l_concatenated_segments;
         END IF;
         CLOSE mtl_item_locations_csr;
      END IF;
      IF (l_location IS NOT NULL) THEN
         l_location := l_location || ';' || p_subinventory_name || ';' || l_organization_name;
      ELSE
         l_location := p_subinventory_name || ';' || l_organization_name;
      END IF;
    ELSE
      l_location := null;
    END IF;
    CLOSE get_org_name_csr;
ELSIF (p_location_type_code = 'HZ_PARTY_SITES' OR p_location_type_code = 'VENDOR_SITE') THEN

 -- Bug# 4902980 SQL id: 14398234
 -- Commenting out Cursor usage ahl_owner_loc_csr and spliting it into
 -- ahl_owner_loc_prty_csr and ahl_owner_loc_vndr_csr based on p_location_type_code
 /*
    IF (p_location_type_code = 'VENDOR_SITE') THEN
       OPEN ahl_owner_loc_csr(p_location_id, 'VENDOR');
    ELSE
       OPEN ahl_owner_loc_csr(p_location_id, 'PARTY');
    END IF;

    FETCH ahl_owner_loc_csr INTO l_location;
    IF (ahl_owner_loc_csr%NOTFOUND) THEN
       l_location := null;
    END IF;
    CLOSE ahl_owner_loc_csr;
  */

    IF (p_location_type_code = 'VENDOR_SITE') THEN

      OPEN ahl_owner_loc_vndr_csr(p_location_id);
      FETCH ahl_owner_loc_vndr_csr INTO l_location;
      IF (ahl_owner_loc_vndr_csr%NOTFOUND) THEN
          l_location := null;
      END IF;
      CLOSE ahl_owner_loc_vndr_csr;

    ELSE

      OPEN ahl_owner_loc_prty_csr(p_location_id);
      FETCH ahl_owner_loc_prty_csr INTO l_location;
      IF (ahl_owner_loc_prty_csr%NOTFOUND) THEN
          l_location := null;
      END IF;
      CLOSE ahl_owner_loc_prty_csr;

    END IF;

ELSIF (p_location_type_code = 'HR_LOCATIONS' OR p_location_type_code = 'INTERNAL_SITE') THEN
    OPEN hr_locations_csr(p_location_id);
    FETCH hr_locations_csr INTO l_location;
    IF (hr_locations_csr%NOTFOUND) THEN
      l_location := null;
    END IF;
    CLOSE hr_locations_csr;
ELSIF (p_location_type_code = 'HZ_LOCATIONS') THEN
    OPEN hz_locations_csr(p_location_id);
    FETCH hz_locations_csr INTO l_location;
    IF (hz_locations_csr%NOTFOUND) THEN
      l_location := null;
    END IF;
    CLOSE hz_locations_csr;
ELSIF (p_location_type_code = 'WIP') THEN
    OPEN wip_entity_csr(p_wip_job_id);
    FETCH wip_entity_csr INTO l_location;
    IF (wip_entity_csr%NOTFOUND) THEN
      l_location := null;
    END IF;
    CLOSE wip_entity_csr;
ELSE
    l_location := null;
END IF;

return l_location;

END GetCSI_LocationDesc;


------------------------------------------------------
-- Function to get location code for a csi instance --
------------------------------------------------------

FUNCTION GetCSI_LocationCode(p_location_id           IN  NUMBER,
                             p_location_type_code    IN  VARCHAR2)

RETURN VARCHAR2 IS

 -- Bug# 4902980 SQL id: 14398234
 -- Commenting out Cursor ahl_owner_loc_csr and spliting it into
 -- ahl_owner_loc_prty_csr and ahl_owner_loc_vndr_csr
/*
  CURSOR ahl_owner_loc_csr (p_location_id  IN  NUMBER,
                            p_party_type   IN  VARCHAR2)  IS
    SELECT owner_site_number
    FROM ahl_owner_locations_v
    WHERE owner_site_id = p_location_id
    AND party_type = p_party_type;
*/
  CURSOR ahl_owner_loc_prty_csr (p_location_id NUMBER) IS
    SELECT party_site_number
    FROM   hz_party_sites
    WHERE  party_site_id = p_location_id
    AND    status  <> 'I';

  CURSOR ahl_owner_loc_vndr_csr (p_location_id NUMBER) IS
    SELECT vendor_site_code
    FROM   po_vendor_sites_all
    WHERE  vendor_site_id = p_location_id;

  l_location                VARCHAR2(2000);


BEGIN
  -- Check location type code.
IF (p_location_type_code = 'INVENTORY') THEN
       --l_location := p_location_type_code;
         l_location := null;

ELSIF (p_location_type_code = 'HZ_PARTY_SITES' OR p_location_type_code = 'VENDOR_SITE') THEN
    -- Bug# 4902980 SQL id: 14398234
    -- Commenting out Cursor usage ahl_owner_loc_csr and spliting it into
    -- ahl_owner_loc_prty_csr and ahl_owner_loc_vndr_csr based on p_location_type_code
    /*
    IF (p_location_type_code = 'VENDOR_SITE') THEN
       OPEN ahl_owner_loc_csr(p_location_id, 'VENDOR');
    ELSE
       OPEN ahl_owner_loc_csr(p_location_id, 'PARTY');
    END IF;

    FETCH ahl_owner_loc_csr INTO l_location;
    IF (ahl_owner_loc_csr%NOTFOUND) THEN
       l_location := null;
    END IF;
    CLOSE ahl_owner_loc_csr;
    */

    IF (p_location_type_code = 'VENDOR_SITE') THEN
      OPEN ahl_owner_loc_vndr_csr(p_location_id);
      FETCH ahl_owner_loc_vndr_csr INTO l_location;
      IF (ahl_owner_loc_vndr_csr%NOTFOUND) THEN
        l_location := null;
      END IF;
      CLOSE ahl_owner_loc_vndr_csr;

    ELSE
      OPEN ahl_owner_loc_prty_csr(p_location_id);
      FETCH ahl_owner_loc_prty_csr INTO l_location;
      IF (ahl_owner_loc_prty_csr%NOTFOUND) THEN
        l_location := null;
      END IF;
      CLOSE ahl_owner_loc_prty_csr;
    END IF;



ELSE
    --l_location := p_location_type_code;
    l_location := null;

END IF;

return l_location;

END GetCSI_LocationCode;

---------------------------------------------------------
-- Procedure to get CSI Transaction ID given the code  --
---------------------------------------------------------
PROCEDURE GetCSI_Transaction_ID(p_txn_code    IN         VARCHAR2,
                                x_txn_type_id OUT NOCOPY NUMBER,
                                x_return_val  OUT NOCOPY BOOLEAN)  IS

  -- For transaction code.
  CURSOR csi_txn_types_csr(p_txn_code  IN  VARCHAR2)  IS
     SELECT  ctxn.transaction_type_id
     FROM csi_txn_types ctxn, fnd_application app
     WHERE ctxn.source_application_id = app.application_id
      AND app.APPLICATION_SHORT_NAME = 'AHL'
      AND ctxn.source_transaction_type = p_txn_code;

  l_txn_type_id   NUMBER;
  l_return_val    BOOLEAN  DEFAULT TRUE;

BEGIN

  -- get transaction_type_id .
  OPEN csi_txn_types_csr(p_txn_code);
  FETCH csi_txn_types_csr INTO l_txn_type_id;
  IF (csi_txn_types_csr%NOTFOUND) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_UC_TXNCODE_INVALID');
     FND_MESSAGE.Set_Token('CODE',p_txn_code);
     FND_MSG_PUB.ADD;
     --dbms_output.put_line('Transaction code not found');
     l_return_val := FALSE;
  END IF;
  CLOSE csi_txn_types_csr;

  -- assign out parameters.
  x_return_val  := l_return_val;
  x_txn_type_id := l_txn_type_id;


END GetCSI_Transaction_ID;

----------------------------------------------------------
-- Procedure to get CSI Status ID given the status-name --
----------------------------------------------------------
PROCEDURE GetCSI_Status_ID (p_status_name  IN         VARCHAR2,
                            x_status_id    OUT NOCOPY NUMBER,
                            x_return_val   OUT NOCOPY BOOLEAN)  IS

  -- For instance status id.
  CURSOR csi_instance_statuses_csr (p_status_name IN  VARCHAR2) IS
     SELECT instance_status_id
     FROM csi_instance_statuses
     WHERE name = p_status_name;

  l_instance_status_id  NUMBER;
  l_return_val          BOOLEAN  DEFAULT TRUE;

BEGIN

  OPEN csi_instance_statuses_csr(p_status_name);
  FETCH csi_instance_statuses_csr INTO l_instance_status_id;
  IF (csi_instance_statuses_csr%NOTFOUND) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_UC_INST_STATUS_MISSING');
     FND_MESSAGE.Set_Token('CODE',p_status_name);
     FND_MSG_PUB.ADD;
     --dbms_output.put_line('Status code not found');
     l_return_val := FALSE;
  END IF;
  CLOSE csi_instance_statuses_csr;

  -- assign out parameters.
  x_return_val  := l_return_val;
  x_status_id   := l_instance_status_id;

END GetCSI_Status_ID;

----------------------------------------------------------
-- Procedure to get CSI Status name given the status-id --
----------------------------------------------------------
PROCEDURE GetCSI_Status_Name (p_status_id      IN         NUMBER,
                              x_status_name    OUT NOCOPY VARCHAR2,
                              x_return_val     OUT NOCOPY BOOLEAN)  IS

  -- For instance status name.
  CURSOR csi_instance_statuses_csr (p_status_id IN  NUMBER) IS
     SELECT name
     FROM csi_instance_statuses
     WHERE instance_status_id = p_status_id;

  l_status_name         csi_instance_statuses.name%TYPE;
  l_return_val          BOOLEAN  DEFAULT TRUE;

BEGIN

  OPEN csi_instance_statuses_csr(p_status_id);
  FETCH csi_instance_statuses_csr INTO l_status_name;
  IF (csi_instance_statuses_csr%NOTFOUND) THEN
     l_return_val := FALSE;
  END IF;
  CLOSE csi_instance_statuses_csr;

  -- assign out parameters.
  x_return_val  := l_return_val;
  x_status_name := l_status_name;

END GetCSI_Status_Name;

---------------------------------------------------------------------
-- Procedure to get extended attribute ID given the attribute code --
---------------------------------------------------------------------
PROCEDURE GetCSI_Attribute_ID (p_attribute_code  IN         VARCHAR2,
                               x_attribute_id    OUT NOCOPY NUMBER,
                               x_return_val      OUT NOCOPY BOOLEAN)  IS


 CURSOR csi_i_ext_attrib_csr(p_attribute_code  IN  VARCHAR2) IS
    SELECT attribute_id
    FROM csi_i_extended_attribs
    WHERE attribute_level = 'GLOBAL'
    AND attribute_code = p_attribute_code;

  l_return_val  BOOLEAN DEFAULT TRUE;
  l_attribute_id NUMBER;

BEGIN

  OPEN csi_i_ext_attrib_csr(p_attribute_code);
  FETCH csi_i_ext_attrib_csr INTO l_attribute_id;
  IF (csi_i_ext_attrib_csr%NOTFOUND) THEN
    l_return_val := FALSE;
    l_attribute_id := null;
  END IF;
  CLOSE csi_i_ext_attrib_csr;
  x_attribute_id := l_attribute_id;
  x_return_val  := l_return_val;

END GetCSI_Attribute_ID;

---------------------------------------------------------------------
-- Procedure to get extended attribute value given the attribute code --
---------------------------------------------------------------------
PROCEDURE GetCSI_Attribute_Value (p_csi_instance_id       IN         NUMBER,
                                  p_attribute_code        IN         VARCHAR2,
                                  x_attribute_value       OUT NOCOPY VARCHAR2,
                                  x_attribute_value_id    OUT NOCOPY NUMBER,
                                  x_object_version_number OUT NOCOPY NUMBER,
                                  x_return_val            OUT NOCOPY BOOLEAN)  IS


  CURSOR csi_i_iea_csr(p_attribute_code   IN  VARCHAR2,
                       p_csi_instance_id  IN  NUMBER) IS

    SELECT iea.attribute_value, iea.attribute_value_id, iea.object_version_number
    FROM csi_i_extended_attribs attb, csi_iea_values iea
    WHERE attb.attribute_id = iea.attribute_id
      AND attb.attribute_code = p_attribute_code
      AND iea.instance_id = p_csi_instance_id
      AND trunc(sysdate) >= trunc(nvl(iea.active_start_date, sysdate))
      AND trunc(sysdate) < trunc(nvl(iea.active_end_date, sysdate+1));

  l_return_val             BOOLEAN DEFAULT TRUE;
  l_attribute_value        csi_iea_values.attribute_value%TYPE;
  l_attribute_value_id     NUMBER;
  l_object_version_number  NUMBER;

BEGIN

  OPEN csi_i_iea_csr(p_attribute_code, p_csi_instance_id);
  FETCH csi_i_iea_csr INTO l_attribute_value, l_attribute_value_id,
                           l_object_version_number;
  IF (csi_i_iea_csr%NOTFOUND) THEN
    l_return_val := FALSE;
    l_attribute_value := null;
    l_attribute_value_id := null;
    l_object_version_number := null;
  END IF;

  CLOSE csi_i_iea_csr;
  x_attribute_value := l_attribute_value;
  x_return_val  := l_return_val;
  x_attribute_value_id := l_attribute_value_id;
  x_object_version_number := l_object_version_number;

END GetCSI_Attribute_Value;

--------------------------------------------------------------------------------
-- Procedure to validate csi_item_instance_id and if found return status name --
--------------------------------------------------------------------------------

PROCEDURE ValidateCSI_Item_Instance(p_instance_id        IN         NUMBER,
                                    x_status_name        OUT NOCOPY VARCHAR2,
                                    x_location_type_code OUT NOCOPY VARCHAR2,
                                    x_return_val         OUT NOCOPY BOOLEAN) IS

  -- For validation of csi_item_instance.
  CURSOR csi_item_instance_csr(p_csi_item_instance_id  IN  NUMBER) IS
    SELECT  instance_status_id, location_type_code
    FROM   csi_item_instances csi
    WHERE  csi.instance_id = p_csi_item_instance_id;

  CURSOR csi_inst_statuses_csr(p_instance_status_id  IN  NUMBER) IS
    SELECT name
    FROM csi_instance_statuses
    WHERE instance_status_id = p_instance_status_id;

  l_return_val   BOOLEAN  DEFAULT TRUE;
  l_status_name  csi_instance_statuses.name%TYPE DEFAULT NULL;
  l_status_id    NUMBER;

  l_location_type_code  csi_item_instances.location_type_code%TYPE;

BEGIN

  OPEN csi_item_instance_csr(p_instance_id);
  FETCH csi_item_instance_csr INTO l_status_id, l_location_type_code;
  IF (csi_item_instance_csr%NOTFOUND) THEN
    l_return_val := FALSE;
    l_status_name := null;
    l_location_type_code := null;
  ELSE
    OPEN csi_inst_statuses_csr(l_status_id);
    FETCH csi_inst_statuses_csr INTO l_status_name;
    IF (csi_inst_statuses_csr%NOTFOUND) THEN
       l_status_name := null;
    END IF;
    CLOSE csi_inst_statuses_csr;
  END IF;
  CLOSE csi_item_instance_csr;

  -- Set return parameters.
  x_status_name := l_status_name;
  x_return_val  := l_return_val;
  x_location_type_code := l_location_type_code;

END  ValidateCSI_Item_Instance;

------------------------------------------------------------------------
-- Procedure to return lookup meaning given the code from CSI_Lookups --
------------------------------------------------------------------------
PROCEDURE Convert_To_CSIMeaning (p_lookup_type     IN         VARCHAR2,
                                 p_lookup_code     IN         VARCHAR2,
                                 x_lookup_meaning  OUT NOCOPY VARCHAR2,
                                 x_return_val      OUT NOCOPY BOOLEAN)  IS

   CURSOR csi_lookup_csr (p_lookup_type     IN  VARCHAR2,
                          p_lookup_code     IN  VARCHAR2)  IS
      SELECT meaning
      FROM csi_lookups
      WHERE lookup_type = p_lookup_type
          AND lookup_code  = p_lookup_code
          AND TRUNC(SYSDATE) >= TRUNC(NVL(start_date_active, SYSDATE))
          AND TRUNC(SYSDATE) < TRUNC(NVL(end_date_active, SYSDATE+1));

      l_lookup_meaning   csi_lookups.meaning%TYPE DEFAULT NULL;
      l_return_val       BOOLEAN  DEFAULT  TRUE;

BEGIN

   OPEN csi_lookup_csr(p_lookup_type, p_lookup_code);
   FETCH  csi_lookup_csr INTO l_lookup_meaning;
   IF (csi_lookup_csr%NOTFOUND) THEN
      l_return_val := FALSE;
      l_lookup_meaning := NULL;
   END IF;

   CLOSE csi_lookup_csr;

   x_lookup_meaning := l_lookup_meaning;
   x_return_val  := l_return_val;

END  Convert_To_CSIMeaning;

----------------------------------------------------
-- Procedure to check existence of a relationship --
-- and if found, returns the position_ref_code    --
----------------------------------------------------
Procedure ValidateMC_Relationship(p_relationship_id   IN         NUMBER,
                                  x_position_ref_code OUT NOCOPY VARCHAR2,
                                  x_return_val        OUT NOCOPY BOOLEAN)  IS

  CURSOR l_ahl_relationship_csr(p_relationship_id IN NUMBER) IS
     SELECT position_ref_code
     FROM   AHL_MC_RELATIONSHIPS
     WHERE relationship_id = p_relationship_id
     AND TRUNC(SYSDATE) >= TRUNC(NVL(active_start_date, SYSDATE))
     AND TRUNC(SYSDATE) < TRUNC(NVL(active_end_date, SYSDATE+1));


  l_position_ref_code  ahl_mc_relationships.position_ref_code%TYPE DEFAULT NULL;

  l_return_val  BOOLEAN DEFAULT TRUE;

BEGIN

    OPEN l_ahl_relationship_csr(p_relationship_id);
    FETCH l_ahl_relationship_csr INTO l_position_ref_code;

    IF (l_ahl_relationship_csr%NOTFOUND) THEN
      l_return_val := FALSE;
      x_position_ref_code := NULL;
    ELSE
      x_position_ref_code := l_position_ref_code;
    END IF;

    CLOSE l_ahl_relationship_csr;

    x_return_val := l_return_val;

END ValidateMC_Relationship;


------------------------------------------------------------------------------
-- Procedure to validate if an inventory item can be assigned to a position --
-- Jerry made changes again to this procedure on 03/31/2005 on the basis of --
-- changes made on Jan. 2005
-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- Added p_ignore_quant_vald parameter to allow the quantity checks to be ignored when called from Production.
-- Additionally, as non-serialized item instances with partial quantities can be assigned to MC positions now,
-- their quantity check with position/associated-item quantity should be relaxed from '=' to '<='.
--
-- When calling the API inv_convert.inv_um_convert, note that it returns -99999 if the UOM conversion is not possible.
-- We should not be considering this as item match found.
------------------------------------------------------------------------------
PROCEDURE Validate_for_Position(p_mc_relationship_id   IN          NUMBER,
                                p_Inventory_id         IN          NUMBER,
                                p_Organization_id      IN          NUMBER,
                                p_quantity             IN          NUMBER,
                                p_revision             IN          VARCHAR2,
                                p_uom_code             IN          VARCHAR2,
                                p_position_ref_meaning IN          VARCHAR2,
                                p_ignore_quant_vald    IN          VARCHAR2 := 'N',
                                x_item_assoc_id        OUT  NOCOPY NUMBER) IS

  CURSOR ahl_relationships_csr (p_mc_relationship_id   IN   NUMBER,
                                p_Inventory_id         IN   NUMBER,
                                p_Organization_id      IN   NUMBER,
                                p_revision             IN   VARCHAR2) IS

    SELECT  iasso.quantity Itm_qty,
            iasso.uom_code Itm_uom_code,
            reln.quantity Posn_Qty,
            reln.uom_code Posn_uom_code,
            iasso.revision Itm_revision,
            iasso.item_association_id
    FROM    ahl_mc_relationships reln, ahl_item_associations_b iasso
    WHERE   reln.item_group_id = iasso.item_group_id
            AND reln.relationship_id = p_mc_relationship_id
            AND iasso.inventory_item_id  = p_Inventory_id
            AND iasso.inventory_org_id = p_Organization_id
            AND (iasso.revision IS NULL OR iasso.revision = p_revision)
            AND iasso.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
            --Added by Jerry on 04/26/2005
            AND trunc(sysdate) >=  trunc(nvl(reln.active_start_date,sysdate))
            AND trunc(sysdate) < trunc(nvl(reln.active_end_date, sysdate+1));

  CURSOR ahl_relationships_csr1 (p_mc_relationship_id   IN   NUMBER,
                                 p_Inventory_id         IN   NUMBER,
                                 p_revision             IN   VARCHAR2) IS

    SELECT  iasso.quantity Itm_qty,
            iasso.uom_code Itm_uom_code,
            reln.quantity Posn_Qty,
            reln.uom_code Posn_uom_code,
            iasso.revision Itm_revision,
            iasso.item_association_id
    FROM    ahl_mc_relationships reln, ahl_item_associations_b iasso
    WHERE   reln.item_group_id = iasso.item_group_id
            AND reln.relationship_id = p_mc_relationship_id
            AND iasso.inventory_item_id   = p_Inventory_id
            AND (iasso.revision IS NULL OR iasso.revision = p_revision)
            AND iasso.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
            --Added by Jerry on 04/26/2005
            AND trunc(sysdate) >=  trunc(nvl(reln.active_start_date,sysdate))
            AND trunc(sysdate) < trunc(nvl(reln.active_end_date, sysdate+1))
            order by iasso.inventory_org_id;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- Cursor to fetch the position lookup meaning for a given relationship id.
  CURSOR get_pos_lkup_meaning(p_mc_relationship_id   IN   NUMBER) IS
    SELECT fnd.lookup_code, fnd.meaning position_ref_meaning
      FROM ahl_mc_relationships mcr, fnd_lookup_values_vl fnd
     WHERE mcr.relationship_id = p_mc_relationship_id
       AND mcr.position_ref_code = fnd.lookup_code
       AND fnd.lookup_type = 'AHL_POSITION_REFERENCE';

    l_Item_Posn_rec    ahl_relationships_csr%ROWTYPE;
    l_item_posn_rec1   ahl_relationships_csr1%ROWTYPE;
    l_uom_rate         NUMBER;
    l_quantity         NUMBER;
    l_assoc_rec_found  BOOLEAN DEFAULT FALSE;

    l_pos_ref_code     fnd_lookups.lookup_code%TYPE;
    l_pos_ref_meaning  fnd_lookups.meaning%TYPE;
    l_debug_key        VARCHAR2(60) := 'ahl.plsql.AHL_UTIL_UC_PKG.Validate_for_Position';

BEGIN
  x_item_assoc_id := NULL;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'p_ignore_quant_vald => '||p_ignore_quant_vald);
  END IF;

  OPEN ahl_relationships_csr(p_mc_relationship_id, p_Inventory_id, p_Organization_id, p_revision);
  LOOP
    FETCH ahl_relationships_csr into l_item_posn_rec;
    EXIT WHEN (l_assoc_rec_found OR ahl_relationships_csr%NOTFOUND);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Org check is done, p_Organization_id => '||p_Organization_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Item Quantity => '||l_Item_Posn_rec.Itm_qty||
                                                           ', Position Quantity => '||l_Item_Posn_rec.posn_qty);
    END IF;

    IF (l_Item_Posn_rec.Itm_qty IS NULL OR l_Item_Posn_rec.Itm_qty = 0) THEN
      -- position based validation.
      IF (l_Item_Posn_rec.Posn_uom_code = p_uom_code) THEN
        IF (nvl(p_quantity,0) <=  l_Item_Posn_rec.posn_qty OR nvl(p_ignore_quant_vald,'N') = 'Y') THEN
          l_assoc_rec_found := TRUE;
          x_item_assoc_id := l_Item_Posn_rec.item_association_id;
          RETURN;
        END IF;
      ELSE
        -- convert quantity to position uom.
        l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_Inventory_id,
                               precision      => 6,
                               from_quantity  => p_quantity,
                               from_unit      => p_uom_code,
                               to_unit        => l_Item_Posn_rec.posn_uom_code,
                               from_name      => NULL,
                               to_name        => NULL );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'inv_convert.inv_um_convert returned l_quantity => '||l_quantity);
        END IF;

        IF (l_quantity >=0 AND (l_quantity <= l_Item_Posn_rec.posn_qty OR nvl(p_ignore_quant_vald,'N') = 'Y')) THEN
          l_assoc_rec_found := TRUE;
          x_item_assoc_id := l_Item_Posn_rec.item_association_id;
          RETURN;
        END IF;
      END IF;
    ELSE
      -- item based validation.
      IF (l_Item_Posn_rec.Itm_uom_code = p_uom_code) THEN
        IF (p_quantity <= l_Item_Posn_rec.Itm_qty OR nvl(p_ignore_quant_vald,'N') = 'Y') THEN
          l_assoc_rec_found := TRUE;
          x_item_assoc_id := l_Item_Posn_rec.item_association_id;
          RETURN;
        END IF;
      ELSE
        -- convert quantity to Item uom.
        l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_Inventory_id,
                               precision      => 6,
                               from_quantity  => p_quantity,
                               from_unit      => p_uom_code,
                               to_unit        => l_Item_Posn_rec.Itm_uom_code,
                               from_name      => NULL,
                               to_name        => NULL );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'inv_convert.inv_um_convert returned l_quantity => '||l_quantity);
        END IF;

        IF (l_quantity >=0 AND (l_quantity <= l_Item_Posn_rec.Itm_qty OR  nvl(p_ignore_quant_vald,'N') = 'Y' )) THEN
          l_assoc_rec_found := TRUE;
          x_item_assoc_id := l_Item_Posn_rec.item_association_id;
          RETURN;
        END IF;
      END IF;
    END IF;
  END LOOP;
  CLOSE ahl_relationships_csr;

  -- Changed by jaramana for as CU2 front port for ADS bug 4414811 so that Org check will not be done.
  -- IF (NOT l_assoc_rec_found AND (fnd_profile.value('AHL_VALIDATE_ALT_ITEM_ORG') = 'N')) THEN
  IF (NOT l_assoc_rec_found) THEN
    OPEN ahl_relationships_csr1(p_mc_relationship_id, p_Inventory_id, p_revision);
    LOOP
      FETCH ahl_relationships_csr1 into l_item_posn_rec1;
      EXIT WHEN (l_assoc_rec_found OR ahl_relationships_csr1%NOTFOUND);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'No Org check done');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Item Quantity => '||l_Item_Posn_rec1.Itm_qty||
                                                             ', Position Quantity => '||l_Item_Posn_rec1.posn_qty);
      END IF;

      IF (l_Item_Posn_rec1.Itm_qty IS NULL OR l_Item_Posn_rec1.Itm_qty = 0) THEN
        -- position based validation.
        IF (l_Item_Posn_rec1.Posn_uom_code = p_uom_code) THEN
          IF (nvl(p_quantity,0) <=  l_Item_Posn_rec1.posn_qty OR  nvl(p_ignore_quant_vald,'N') = 'Y' ) THEN
            l_assoc_rec_found := TRUE;
            x_item_assoc_id := l_Item_Posn_rec1.item_association_id;
            RETURN;
          END IF;
        ELSE
          -- convert quantity to position uom.
          l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_Inventory_id,
                               precision      => 6,
                               from_quantity  => p_quantity,
                               from_unit      => p_uom_code,
                               to_unit        => l_Item_Posn_rec1.posn_uom_code,
                               from_name      => NULL,
                               to_name        => NULL );

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'inv_convert.inv_um_convert returned l_quantity => '||l_quantity);
          END IF;

          IF (l_quantity >=0 AND (l_quantity <= l_Item_Posn_rec1.posn_qty OR nvl(p_ignore_quant_vald,'N') = 'Y')) THEN
            l_assoc_rec_found := TRUE;
            x_item_assoc_id := l_Item_Posn_rec1.item_association_id;
            RETURN;
          END IF;
        END IF;
      ELSE
      -- item based validation.
        IF (l_Item_Posn_rec1.Itm_uom_code = p_uom_code) THEN
          IF (p_quantity <= l_Item_Posn_rec1.Itm_qty OR nvl(p_ignore_quant_vald,'N') = 'Y') THEN
            l_assoc_rec_found := TRUE;
            x_item_assoc_id := l_Item_Posn_rec1.item_association_id;
            RETURN;
          END IF;
        ELSE
        -- convert quantity to Item uom.
          l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_Inventory_id,
                               precision      => 6,
                               from_quantity  => p_quantity,
                               from_unit      => p_uom_code,
                               to_unit        => l_Item_Posn_rec1.Itm_uom_code,
                               from_name      => NULL,
                               to_name        => NULL );

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'inv_convert.inv_um_convert returned l_quantity => '||l_quantity);
          END IF;

          IF (l_quantity >=0 AND (l_quantity <= l_Item_Posn_rec1.Itm_qty OR nvl(p_ignore_quant_vald,'N') = 'Y')) THEN
            l_assoc_rec_found := TRUE;
            x_item_assoc_id := l_Item_Posn_rec1.item_association_id;
            RETURN;
          END IF;
        END IF;
      END IF;
    END LOOP;
    CLOSE ahl_relationships_csr1;
  END IF;

  IF NOT l_assoc_rec_found THEN
    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
    -- If the p_position_ref_meaning is NULL, then fetch it from the p_mc_relationship_id
    l_pos_ref_meaning := p_position_ref_meaning;
    IF l_pos_ref_meaning IS NULL THEN
      OPEN get_pos_lkup_meaning(p_mc_relationship_id);
      FETCH get_pos_lkup_meaning INTO l_pos_ref_code, l_pos_ref_meaning;
      CLOSE get_pos_lkup_meaning;

      IF(l_pos_ref_meaning IS NULL) THEN
        l_pos_ref_meaning := l_pos_ref_code;
      END IF;
    END IF;

    FND_MESSAGE.Set_Name('AHL','AHL_UC_INVGRP_MISMATCH');
    FND_MESSAGE.Set_Token('POSN_REF',l_pos_ref_meaning);
    FND_MSG_PUB.ADD;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_debug_key, 'Item invalid for l_pos_ref_meaning => '||l_pos_ref_meaning);
    END IF;
  END IF;

END Validate_for_Position;


-------------------------------------------------------
-- Procedure to check if item assigned to a position --
-- Return TRUE if position assigned else FALSE       --
-------------------------------------------------------
PROCEDURE Check_Position_Assigned (p_csi_item_instance_id   IN         NUMBER,
                                   p_mc_relationship_id     IN         NUMBER,
                                   x_subject_id             OUT NOCOPY NUMBER,
                                   x_return_val             OUT NOCOPY BOOLEAN) IS

  CURSOR csi_ii_relationships_csr(p_csi_item_instance_id   IN NUMBER,
                                  p_mc_relationship_id     IN NUMBER) IS
     SELECT subject_id
      FROM csi_ii_relationships
      WHERE position_reference = to_char(p_mc_relationship_id)
      START WITH object_id = p_csi_item_instance_id
            AND relationship_type_code = 'COMPONENT-OF'
            AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
      CONNECT BY PRIOR subject_id = object_id
            AND relationship_type_code = 'COMPONENT-OF'
            AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));


  l_subject_id  NUMBER;
  l_return_val  BOOLEAN DEFAULT TRUE;

BEGIN

  OPEN csi_ii_relationships_csr (p_csi_item_instance_id,
                                 p_mc_relationship_id);
  FETCH csi_ii_relationships_csr INTO l_subject_id;
  IF (csi_ii_relationships_csr%NOTFOUND) THEN
    l_return_val := FALSE;
    l_subject_id := null;
  END IF;

  x_return_val := l_return_val;
  x_subject_id := l_subject_id;

END Check_Position_Assigned;

-----------------------------------------------------------------------
-- Function will validate if an item is valid for a position or not. --
-- It is designed mainly to be used in SQL and views definitions.    --
-- IT WILL IMPLICITLY INITIALIZE THE ERROR MESSAGE STACK.            --
-- This will call Validate_for_Position procedure and will return :  --
--   ahl_item_associations.item_association_id that has been matched --
--   else if no record matched, it will return 0(zero).              --
-- OBSOLETED 10/24/2002.
-----------------------------------------------------------------------
FUNCTION  Validate_Alternate_Item (p_mc_relationship_id   IN   NUMBER,
                                   p_Inventory_id         IN   NUMBER,
                                   p_Organization_id      IN   NUMBER,
                                   p_quantity             IN   NUMBER,
                                   p_revision             IN   VARCHAR2,
                                   p_uom_code             IN   VARCHAR2) RETURN NUMBER IS

  l_item_assoc_id  NUMBER;
  l_msg_count      NUMBER;

BEGIN

  -- Initialize the message stack.
  FND_MSG_PUB.Initialize;

  -- Call Validate for position procedure.
  Validate_for_Position(p_mc_relationship_id   => p_mc_relationship_id,
                        p_Inventory_id         => p_Inventory_id,
                        p_Organization_id      => p_Organization_id,
                        p_quantity             => p_quantity,
                        p_revision             => p_revision,
                        p_uom_code             => p_uom_code,
                        p_position_ref_meaning => NULL,
                        x_item_assoc_id         => l_item_assoc_id);

  -- Check Error Message stack.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
     RETURN 0;
  ELSE
     RETURN l_item_assoc_id;
  END IF;

END Validate_Alternate_Item;
-----------------------------

-- Procedure to match if the sub-tree below p_csi_item_instance_id matches with the
-- master config sub-tree below p_mc_relationship_id.
/* comment out by Jerry Li on 09/16/2004 for bug 3893965
PROCEDURE Match_Tree_Components (p_csi_item_instance_id  IN         NUMBER,
                                 p_mc_relationship_id    IN         NUMBER,
                                 x_match_part_posn_tbl   OUT NOCOPY AHL_UTIL_UC_PKG.matched_tbl_type,
                                 x_match_flag            OUT NOCOPY BOOLEAN)
IS

  -- Cursor to read the parts tree from IB.
  CURSOR csi_part_tree_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT object_id, subject_id, position_reference, level, relationship_id csi_ii_relationship_id,
           object_version_number csi_ii_object_version_number
    FROM csi_ii_relationships
    START WITH object_id = p_csi_item_instance_id
           AND relationship_type_code = 'COMPONENT-OF'
           AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
           AND relationship_type_code = 'COMPONENT-OF'
           AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    ORDER BY level;

  -- Cursor to read the master config tree.
  CURSOR ahl_relationships_csr (p_mc_relationship_id  IN  NUMBER) IS
    SELECT relationship_id, position_ref_code, level
    FROM   ahl_mc_relationships
    START WITH parent_relationship_id = p_mc_relationship_id
           AND TRUNC(SYSDATE) >=  TRUNC(NVL(active_start_date, SYSDATE))
           AND TRUNC(SYSDATE) < TRUNC(NVL(active_end_date, SYSDATE+1))
    CONNECT BY PRIOR relationship_id = parent_relationship_id
           AND TRUNC(SYSDATE) >=  TRUNC(NVL(active_start_date, SYSDATE))
           AND TRUNC(SYSDATE) < TRUNC(NVL(active_end_date, SYSDATE+1))
    ORDER BY level;

  -- Cursor to read instance details.
  CURSOR csi_item_instance_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT inventory_item_id, last_vld_organization_id, quantity, unit_of_measure,
           inventory_revision, instance_number
    FROM csi_item_instances csi
    WHERE instance_id = p_csi_item_instance_id;

  -- Cursor to get position ref code.
  CURSOR ahl_relationships_csr1 (p_mc_relationship_id IN NUMBER) IS
    SELECT posn.position_ref_code, f.meaning
    FROM ahl_relationships_vl posn, fnd_lookups f
    WHERE posn.relationship_id = p_mc_relationship_id
      AND posn.position_ref_code = f.lookup_code;

  -- Define part record structure.
  TYPE part_rec_type IS RECORD (
                 object_id                    NUMBER,
                 subject_id                   NUMBER,
                 position_reference           VARCHAR2(30),
                 level                        NUMBER,
                 csi_ii_relationship_id       NUMBER,
                 csi_ii_object_version        NUMBER);

  -- Define mc-position record structure.
  TYPE mc_posn_rec_type IS RECORD (
                 relationship_id   NUMBER,
                 position_ref_code VARCHAR2(30),
                 level             NUMBER);


  -- Define table for part records.
  TYPE part_tbl_type IS TABLE OF part_rec_type INDEX BY BINARY_INTEGER;

  -- Define table for mc-position records.
  TYPE mc_posn_tbl_type IS TABLE OF mc_posn_rec_type INDEX BY BINARY_INTEGER;

  -- define variables to hold part-tree and mc-posn tree.
  l_part_tbl     part_tbl_type;
  l_mc_posn_tbl  mc_posn_tbl_type;
  l_matched_tbl  AHL_UTIL_UC_PKG.matched_tbl_type;

  l_index  NUMBER;

  l_Inventory_item_id           NUMBER;
  l_inventory_org_id            NUMBER;
  l_quantity                    NUMBER;
  l_inventory_revision          csi_item_instances.inventory_revision%TYPE;
  l_uom_code                    csi_item_instances.unit_of_measure%TYPE;
  l_position_ref_meaning        FND_LOOKUPS.meaning%TYPE;
  l_item_assoc_id               NUMBER;
  l_part_posn_ref_code          FND_LOOKUPS.lookup_code%TYPE;
  l_instance_number             csi_item_instances.instance_number%TYPE;

  --l_debug  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON'),'N');
  l_debug  VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;

BEGIN

  -- Add debug mesg.
  IF (l_debug = 'Y') THEN
    AHL_DEBUG_PUB.debug('In Match Tree Components');
  END IF;

  -- Initialize x_match_flag to true.
  x_match_flag := TRUE;
  x_match_part_posn_tbl := l_matched_tbl;

  l_index := 0;

  -- Build part tree array.
  FOR part_rec IN csi_part_tree_csr(p_csi_item_instance_id) LOOP
      l_index := l_index + 1;
      l_part_tbl(l_index) := part_rec;
  END LOOP;  -- end part tree.

  -- Add debug mesg.
  IF (l_debug = 'Y') THEN
    AHL_DEBUG_PUB.debug('Part tree:' || l_part_tbl.count);
  END IF;

  -- Check if the instance has any children.
  -- If there are no children, return as there is nothing to match.
  IF (l_part_tbl.COUNT <= 0) THEN
     RETURN;
  END IF;

  l_index := 0;

  -- Build mc-tree array.
  FOR mc_posn_rec IN ahl_relationships_csr(p_mc_relationship_id) LOOP
      l_index := l_index + 1;
      l_mc_posn_tbl(l_index) := mc_posn_rec;
  END LOOP;  -- end part tree.

  -- Add debug mesg.
  IF (l_debug = 'Y') THEN
    AHL_DEBUG_PUB.debug('mc tree:' || l_mc_posn_tbl.count);
  END IF;

  IF (l_mc_posn_tbl.COUNT = 0) THEN
    -- raise error if there are parts in the part-tree but the mc-tree
    -- has no children.
    -- Get instance number to display error message.
    OPEN csi_item_instance_csr (p_csi_item_instance_id);
    FETCH csi_item_instance_csr INTO l_inventory_item_id, l_inventory_org_id, l_quantity, l_uom_code,
                                     l_inventory_revision, l_instance_number;
    IF (csi_item_instance_csr%NOTFOUND) THEN
       l_instance_number := p_csi_item_instance_id;
    END IF;
    CLOSE csi_item_instance_csr;
    FND_MESSAGE.Set_Name('AHL','AHL_UC_SUBTREE_MISMATCH');
    FND_MESSAGE.Set_Token('INSTANCE',l_instance_number);
    FND_MSG_PUB.ADD;
    x_match_flag := FALSE;
    RETURN;
  END IF;

  l_index := 0;

  -- Match trees and build matched table with part and mc-position.
  FOR i IN l_part_tbl.FIRST..l_part_tbl.LAST LOOP
     -- find the part's position ref code.
     OPEN ahl_relationships_csr1 (to_number(l_part_tbl(i).position_reference));
     FETCH ahl_relationships_csr1 INTO l_part_posn_ref_code, l_position_ref_meaning;
     -- exit if the position is not found.
     IF (ahl_relationships_csr1%NOTFOUND) THEN
       CLOSE ahl_relationships_csr1;
       x_match_flag := FALSE;
       EXIT;
     END IF;
     CLOSE ahl_relationships_csr1;

     -- Read MC tree for matching.
     FOR j IN l_mc_posn_tbl.FIRST..l_mc_posn_tbl.LAST LOOP
        -- if position ref code and level match then delete entries from the mc_posn table.
        IF (l_part_posn_ref_code = l_mc_posn_tbl(j).position_ref_code
           AND l_part_tbl(i).level = l_mc_posn_tbl(j).level) THEN

              l_matched_tbl(i).object_id := l_part_tbl(i).object_id;
              l_matched_tbl(i).subject_id := l_part_tbl(i).subject_id;
              l_matched_tbl(i).mc_relationship_id := l_mc_posn_tbl(j).relationship_id;
              l_matched_tbl(i).csi_ii_relationship_id := l_part_tbl(i).csi_ii_relationship_id;
              l_matched_tbl(i).csi_ii_object_version := l_part_tbl(i).csi_ii_object_version;


              -- Check if this is a valid alternate item for this position.
              OPEN csi_item_instance_csr (l_part_tbl(i).subject_id);
              FETCH csi_item_instance_csr INTO l_inventory_item_id, l_inventory_org_id, l_quantity, l_uom_code,
                                               l_inventory_revision, l_instance_number;
              IF (csi_item_instance_csr%NOTFOUND) THEN
                 FND_MESSAGE.Set_Name('AHL','AHL_UC_CHILD_DELETED');
                 FND_MESSAGE.Set_Token('CHILD', l_part_tbl(i).subject_id);
                 FND_MSG_PUB.ADD;
                 CLOSE csi_item_instance_csr;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              CLOSE csi_item_instance_csr;

              -- Validate w.r.t positional attributes.
              AHL_UTIL_UC_PKG.Validate_for_Position(l_mc_posn_tbl(j).relationship_id,
                                                    l_Inventory_Item_id,
                                                    l_Inventory_Org_id,
                                                    l_quantity,
                                                    l_inventory_revision,
                                                    l_uom_code,
                                                    l_position_ref_meaning,
                                                    l_item_assoc_id);
              IF (l_item_assoc_id IS NULL) THEN
                 x_match_flag := FALSE;
              END IF;

              -- delete.
              l_mc_posn_tbl.DELETE(j);
              l_part_tbl.DELETE(i);
              EXIT; -- exit mc loop as match was found.

        ELSIF (l_part_tbl(i).level < l_mc_posn_tbl(j).level) THEN
            x_match_flag := FALSE;
            EXIT;
        END IF;

     END LOOP;

    -- Abort matching process if match has failed for a part.
    IF NOT(x_match_flag) THEN
       EXIT;
    END IF;

  END LOOP;

  -- the count on parts table should be zero else, add message to error stack.
  IF (l_part_tbl.COUNT <> 0) OR (x_match_flag = FALSE) THEN
     FND_MESSAGE.Set_Name('AHL','AHL_UC_SUBTREE_MISMATCH');
     -- Get instance number to display error message.
     OPEN csi_item_instance_csr (p_csi_item_instance_id);
     FETCH csi_item_instance_csr INTO l_inventory_item_id, l_inventory_org_id, l_quantity, l_uom_code,
                                      l_inventory_revision, l_instance_number;
     IF (csi_item_instance_csr%NOTFOUND) THEN
        l_instance_number := p_csi_item_instance_id;
     END IF;
     CLOSE csi_item_instance_csr;
     FND_MESSAGE.Set_Token('INSTANCE',l_instance_number);
     FND_MSG_PUB.ADD;
     x_match_flag := FALSE;
  END IF;

  -- set return parameters.
  x_match_part_posn_tbl := l_matched_tbl;
  --dbms_output.put_line('matched table:' || x_match_part_posn_tbl.count);

  -- Add debug mesg.
  IF (l_debug = 'Y') THEN
    AHL_DEBUG_PUB.debug('matched table:' || x_match_part_posn_tbl.count);

    if (l_matched_tbl.count > 0) then
      for i in l_matched_tbl.first..l_matched_tbl.last loop
           AHL_DEBUG_PUB.debug(l_matched_tbl(i).subject_id);
           AHL_DEBUG_PUB.debug(l_matched_tbl(i).mc_relationship_id);
           AHL_DEBUG_PUB.debug(l_matched_tbl(i).csi_ii_relationship_id);
           AHL_DEBUG_PUB.debug(l_matched_tbl(i).csi_ii_object_version);
      end loop;
    end if;

  END IF;

EXCEPTION
-- Last position_reference not available for the part.
WHEN NO_DATA_FOUND THEN
   OPEN csi_item_instance_csr (p_csi_item_instance_id);
   FETCH csi_item_instance_csr INTO l_inventory_item_id, l_inventory_org_id, l_quantity, l_uom_code,
                                    l_inventory_revision,l_instance_number;
   IF (csi_item_instance_csr%NOTFOUND) THEN
      l_instance_number := p_csi_item_instance_id;
   END IF;
   CLOSE csi_item_instance_csr;
   FND_MESSAGE.Set_Name('AHL','AHL_UC_SUBTREE_MISMATCH');
   FND_MESSAGE.Set_Token('INSTANCE',l_instance_number);
   FND_MSG_PUB.ADD;
   x_match_flag := FALSE;

WHEN VALUE_ERROR THEN
   OPEN csi_item_instance_csr (p_csi_item_instance_id);
   FETCH csi_item_instance_csr INTO l_inventory_item_id, l_inventory_org_id, l_quantity, l_uom_code,
                                    l_inventory_revision,l_instance_number;
   IF (csi_item_instance_csr%NOTFOUND) THEN
      l_instance_number := p_csi_item_instance_id;
   END IF;
   CLOSE csi_item_instance_csr;
   FND_MESSAGE.Set_Name('AHL','AHL_UC_SUBTREE_MISMATCH');
   FND_MESSAGE.Set_Token('INSTANCE',l_instance_number);
   FND_MSG_PUB.ADD;
   x_match_flag := FALSE;


END Match_Tree_Components;
*/
--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Invalidate_Instance
--  Type            : Private
--  Function        : Removes the reference to an Instance that has been deleted
--                    or referenced from an Item Group.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2                    Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Invalidate_Instance parameters :
--  p_instance_table    IN  Instance_Tbl_Type
--              A table of inv item id, inv org id and item_group_id
--
--  History:
--      06/03/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Invalidate_Instance(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_instance_tbl          IN  Instance_Tbl_Type
)
IS
--
  --Check if the item group, inventory and org combination are valid
  CURSOR check_item_group_csr(c_item_group_id     IN NUMBER,
                              c_inventory_item_id IN NUMBER,
                              c_inventory_org_id  IN NUMBER ) IS
  SELECT item_group_id
  FROM ahl_item_associations_b
  WHERE item_group_id = c_item_group_id
    AND inventory_item_id = c_inventory_item_id
    AND inventory_org_id = c_inventory_org_id;

  -- Get all the positions associated to this item group.
  CURSOR get_associated_posns_csr(c_item_group_id IN NUMBER) IS
     SELECT relationship_id
     FROM ahl_mc_relationships rel, ahl_mc_headers_b hdr
     WHERE trunc(nvl(rel.active_end_date,sysdate+1)) > trunc(sysdate)
        AND trunc(nvl(rel.active_start_date,sysdate-1)) < trunc(sysdate)
        AND hdr.mc_header_id = rel.mc_header_id
        AND rel.item_group_id = c_item_group_id
        AND hdr.config_status_code not in ('EXPIRED','CLOSED');

  -- Get item instances that match the position and inventory_item_id.
  CURSOR get_item_instances_csr(c_position_reference IN VARCHAR2,
                                c_inventory_item_id  IN NUMBER,
                                c_inventory_org_id   IN NUMBER) IS
    SELECT instance_id csi_item_instance_id, csi.object_version_number
    FROM   csi_ii_relationships reln, csi_item_instances csi
    WHERE  reln.subject_id = csi.instance_id
      AND  TRUNC(SYSDATE) < TRUNC(NVL(reln.active_end_date, SYSDATE+1))
      AND trunc(nvl(reln.active_start_date,sysdate-1)) < trunc(sysdate)
      AND  reln.relationship_type_code = 'COMPONENT-OF'
      AND  reln.position_reference = c_position_reference
      AND  csi.inventory_item_id = c_inventory_item_id
      AND  csi.inv_master_organization_id = c_inventory_org_id;

  -- Check top nodes of a unit or sub-unit that match.
  CURSOR chk_top_node_csr(c_relationship_id IN NUMBER,
                          c_inventory_item_id  IN NUMBER,
                          c_inventory_org_id   IN NUMBER) IS
    SELECT uc.csi_item_instance_id, uc.unit_config_header_id, uc.parent_uc_header_id, uc.unit_config_status_code
    FROM ahl_unit_config_headers uc, csi_item_instances csi, ahl_mc_relationships mc
    WHERE uc.csi_item_instance_id = csi.instance_id
        AND uc.master_config_id = mc.mc_header_id
        AND mc.relationship_id  = c_relationship_id
        AND TRUNC(SYSDATE) < TRUNC(NVL(uc.active_end_date, SYSDATE+1))
        AND trunc(nvl(uc.active_start_date,sysdate-1)) < trunc(sysdate)
        AND csi.inventory_item_id = c_inventory_item_id
        AND csi.inv_master_organization_id = c_inventory_org_id;
--
  -- Get UC header info
  CURSOR get_uc_header_info_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT uc.unit_config_header_id, uc.unit_config_status_code
    FROM ahl_unit_config_headers uc
    WHERE csi_item_instance_id in
      ( SELECT object_id
          FROM csi_ii_relationships
         START WITH subject_id = p_csi_item_instance_id
           AND relationship_type_code = 'COMPONENT-OF'
           AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
           AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR object_id = subject_id
           AND relationship_type_code = 'COMPONENT-OF'
           AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
           AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
     AND uc.parent_uc_header_id IS NULL
     AND trunc(nvl(uc.active_start_date,sysdate)) <= trunc(sysdate)
     AND trunc(sysdate) < trunc(nvl(uc.active_end_date, sysdate+1));
--
 l_api_version      CONSTANT NUMBER := 1.0;
 l_api_name         CONSTANT VARCHAR2(30) := 'Invalidate_Instance';

 l_instance_tbl              Instance_Tbl_Type := p_instance_tbl;
 l_unit_config_header_id     ahl_unit_config_headers.unit_config_header_id%TYPE;
 l_unit_config_status_code   ahl_unit_config_headers.unit_config_status_code%TYPE;
 l_unitname                  ahl_unit_config_headers.name%TYPE;

 l_chk_top_node_csr          chk_top_node_csr%ROWTYPE;
 l_check_item_group_csr      check_item_group_csr%ROWTYPE;
 l_return_status             varchar2(1);


BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Invalidate_Instance;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing

  -- Validating the instance table
  IF ( l_instance_tbl.count >0 ) THEN

    --For all the records in the instance table
    FOR i in l_instance_tbl.FIRST..l_instance_tbl.LAST LOOP

    OPEN check_item_group_csr(l_instance_tbl(i).item_group_id,
                              l_instance_tbl(i).inventory_item_id,
                              l_instance_tbl(i).inventory_org_id);
    FETCH check_item_group_csr into l_check_item_group_csr;

    --Proceed if item group is found
    IF (check_item_group_csr%FOUND) THEN

        --Get all the positions the item group is associated to
        FOR position_rec IN get_associated_posns_csr( l_instance_tbl(i).item_group_id ) LOOP

            --Check if the item is assigned as a top node
            OPEN chk_top_node_csr(position_rec.relationship_id,
                                  l_instance_tbl(i).inventory_item_id,
                                  l_instance_tbl(i).inventory_org_id);
            FETCH chk_top_node_csr INTO l_chk_top_node_csr;
            IF (chk_top_node_csr%FOUND) THEN

                -- updating active_end_date and incrementing object version number
                update ahl_unit_config_headers
                set active_end_date = sysdate,
                    object_version_number=object_version_number+1
                where unit_config_header_id = l_chk_top_node_csr.unit_config_header_id;

                --check if the unit is a sub-unit
                IF ( l_chk_top_node_csr.parent_uc_header_id is not null ) THEN

                  --update the csi_ii_relationships table and make it an extra node
                 update_csi_ii_relationships(x_return_status =>x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_subject_id=>l_chk_top_node_csr.csi_item_instance_id);
                  IF x_msg_count > 0 THEN
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
                END IF; --parent_uc_header_id is not null

            END IF;
            CLOSE chk_top_node_csr;


            --Check if the item is assigned as a component
            FOR item_instance_rec IN get_item_instances_csr(to_char(position_rec.relationship_id),
                                                             l_instance_tbl(i).inventory_item_id,
                                                             l_instance_tbl(i).inventory_org_id)
             LOOP

               --update the csi_ii_relationships table and make it an extra node

                 update_csi_ii_relationships(x_return_status =>x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_subject_id=>item_instance_rec.csi_item_instance_id);
               IF x_msg_count > 0 THEN
             RAISE  FND_API.G_EXC_ERROR;
               END IF;

               OPEN get_uc_header_info_csr(item_instance_rec.csi_item_instance_id );
               FETCH get_uc_header_info_csr into l_unit_config_header_id, l_unit_config_status_code;

               --update status and object_version_number
               IF ( l_unit_config_status_code = 'APPROVAL_PENDING' ) THEN
                    --modify UC status to APPROVAL_REJECTED
                    update ahl_unit_config_headers
                    set unit_config_status_code = 'APPROVAL_REJECTED',
                        object_version_number=object_version_number+1
                    where unit_config_header_id = l_unit_config_header_id;

               ELSIF ( l_unit_config_status_code = 'COMPLETE' ) THEN
                    --modify UC status to INCOMPLETE
                    update ahl_unit_config_headers
                    set unit_config_status_code = 'INCOMPLETE',
                        object_version_number=object_version_number+1
                    where unit_config_header_id = l_unit_config_header_id;

               END IF;
               CLOSE get_uc_header_info_csr;

             END LOOP; --item_instance_rec

        END LOOP;
      END IF;
      CLOSE check_item_group_csr;

    END LOOP;
  END IF; -- IF count > 0

  --Completed Processing

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;


  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  --commit the updates
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT;
  END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Rollback to Invalidate_Instance;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Invalidate_Instance;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Rollback to Invalidate_Instance;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Invalidate_Instance',
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
END Invalidate_Instance;



PROCEDURE update_csi_ii_relationships(
  x_return_status   OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_subject_id IN NUMBER
)
IS
--
  CURSOR get_csi_record_csr(c_subject_id NUMBER) IS
  SELECT relationship_id, object_id, object_version_number
  FROM csi_ii_relationships
  WHERE subject_id = c_subject_id
    AND relationship_type_code = 'COMPONENT-OF'
    AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    AND trunc(sysdate) > trunc(nvl(active_start_date, sysdate-1));
--
  l_mc_header_count           NUMBER;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_return_val                boolean;
  l_transaction_type_id       number;
  l_csi_record_csr            get_csi_record_csr%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Define the l_csi_transaction_rec
  l_csi_transaction_rec.source_transaction_date := sysdate;

  AHL_Util_UC_Pkg.GetCSI_Transaction_ID('UC_UPDATE',l_transaction_type_id,
                    l_return_val);
  IF NOT(l_return_val) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;

  OPEN get_csi_record_csr( p_subject_id );
  FETCH get_csi_record_csr into l_csi_record_csr;

  --Define the l_csi_relationship_rec
  l_csi_relationship_rec.relationship_id := l_csi_record_csr.relationship_id;
  l_csi_relationship_rec.subject_id := p_subject_id;
  l_csi_relationship_rec.object_id  := l_csi_record_csr.object_id;
  l_csi_relationship_rec.object_version_number := l_csi_record_csr.object_version_number;
  l_csi_relationship_rec.position_reference := null;
  l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
  l_csi_relationship_tbl(1) := l_csi_relationship_rec;
  CLOSE get_csi_record_csr;

  --Updating the csi_ii_relationships table
  CSI_II_Relationships_PUB.Update_Relationship(
                            p_api_version            => 1.0,
                            p_init_msg_list          => FND_API.G_TRUE,
                            p_commit                 => FND_API.G_FALSE,
                            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                            p_relationship_tbl       => l_csi_relationship_tbl,
                            p_txn_rec                => l_csi_transaction_rec,
                            x_return_status          => x_return_status,
                            x_msg_count              => x_msg_count,
                            x_msg_data               => x_msg_data );

END update_csi_ii_relationships;

----------------------------


-- Function to get the Status (Meaning) of a Unit Configuration
-- This function considers if the unit is installed in another unit, if it is expired etc.
-- It returns the concatenation of the status with the active status if the status
-- ic Complete or Incomplete
FUNCTION Get_UC_Status(p_uc_header_id IN NUMBER)
RETURN VARCHAR2
IS

-- Perf Bug Fix for - 4902980.
-- Cursor uc_details_csr to be split.
/*
  CURSOR uc_details_csr(p_uc_header_id IN NUMBER) IS
    SELECT UC.ROOT_UC_HEADER_ID,
           UC.UC_STATUS_CODE,
           UC.UC_STATUS,
           UC.ACTIVE_UC_STATUS,
           NVL(UC.ACTIVE_END_DATE, SYSDATE + 1),
           NVL(UC.INSTANCE_END_DATE, SYSDATE + 1),
           ROOT_UC.UNIT_CONFIG_STATUS_CODE,
           FL.MEANING,
           FLA.MEANING,
           NVL(ROOT_UC.ACTIVE_END_DATE, SYSDATE + 1),
           NVL(CSI.ACTIVE_END_DATE, SYSDATE + 1)
    FROM AHL_UNIT_CONFIG_HEADERS_V UC, AHL_UNIT_CONFIG_HEADERS ROOT_UC,
         FND_LOOKUP_VALUES_VL FL, FND_LOOKUP_VALUES_VL FLA,
         CSI_ITEM_INSTANCES CSI
    WHERE UC.UC_HEADER_ID = p_uc_header_id AND
          ROOT_UC.UNIT_CONFIG_HEADER_ID = UC.ROOT_UC_HEADER_ID AND
          ROOT_UC.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID AND
          FL.lookup_type  = 'AHL_CONFIG_STATUS' AND
          ROOT_UC.unit_config_status_code = FL.lookup_code AND
          FLA.lookup_type (+) = 'AHL_CONFIG_STATUS' AND
          ROOT_UC.active_uc_status_code = FLA.lookup_code (+);
*/

  CURSOR get_expired_value IS
    SELECT MEANING CsifutLookupMeaning
    FROM FND_LOOKUP_VALUES_VL
    WHERE LOOKUP_TYPE = 'AHL_CONFIG_STATUS' AND
          LOOKUP_CODE = G_STATUS_EXPIRED;

  l_root_uc_header_id    NUMBER;
  l_uc_status_code       AHL_UNIT_CONFIG_HEADERS.UNIT_CONFIG_STATUS_CODE%TYPE;
  l_uc_status            FND_LOOKUP_VALUES.MEANING%TYPE;
  l_uc_active_status     FND_LOOKUP_VALUES.MEANING%TYPE;
  l_uc_end_date          AHL_UNIT_CONFIG_HEADERS.ACTIVE_END_DATE%TYPE;
  l_uc_inst_end_date     CSI_ITEM_INSTANCES.ACTIVE_END_DATE%TYPE;
  l_root_status_code     AHL_UNIT_CONFIG_HEADERS.UNIT_CONFIG_STATUS_CODE%TYPE;
  l_root_status          FND_LOOKUP_VALUES.MEANING%TYPE;
  l_root_active_status   FND_LOOKUP_VALUES.MEANING%TYPE;
  l_root_end_date        AHL_UNIT_CONFIG_HEADERS.ACTIVE_END_DATE%TYPE;
  l_root_inst_end_date   CSI_ITEM_INSTANCES.ACTIVE_END_DATE%TYPE;
  l_return_value         VARCHAR2(100) := null;
  L_DEBUG_KEY            CONSTANT VARCHAR2(150) := 'ahl.plsql.AHL_UTIL_UC_PKG.Get_UC_Status';

BEGIN

-- Perf Bug Fix for - 4902980.
-- Cursor uc_details_csr to be split below.
/*
  OPEN uc_details_csr(p_uc_header_id);
  FETCH uc_details_csr INTO l_root_uc_header_id,
                            l_uc_status_code,
                            l_uc_status,
                            l_uc_active_status,
                            l_uc_end_date,
                            l_uc_inst_end_date,
                            l_root_status_code,
                            l_root_status,
                            l_root_active_status,
                            l_root_end_date,
                            l_root_inst_end_date;
  IF(uc_details_csr%NOTFOUND) THEN
    CLOSE uc_details_csr;
    RETURN l_return_value;  -- Null
  END IF;
  CLOSE uc_details_csr;
*/

  -- Fetching Root UC Header Id
  BEGIN

        SELECT unit_config_header_id
          INTO l_root_uc_header_id
          FROM ahl_unit_config_headers
         WHERE parent_uc_header_id IS NULL
    START WITH unit_config_header_id = p_uc_header_id
           -- Commented out by jaramana on August 23, 2006 to show the status of Expired units correctly
           -- AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    CONNECT BY unit_config_header_id = PRIOR parent_uc_header_id;
           -- AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  EXCEPTION
      WHEN OTHERS THEN
           RETURN l_return_value;  -- Null
  END;

  -- Fetching Details for UC Id passed to the API.
  BEGIN
        SELECT UC.UNIT_CONFIG_STATUS_CODE,
               UCSC.MEANING,
               UASC.MEANING,
               NVL(UC.ACTIVE_END_DATE, SYSDATE + 1),
               NVL(CSI.active_end_date,SYSDATE + 1)
         INTO l_uc_status_code,
              l_uc_status,
              l_uc_active_status,
              l_uc_end_date,
              l_uc_inst_end_date
         FROM AHL_UNIT_CONFIG_HEADERS UC, FND_LOOKUP_VALUES UCSC,
              CSI_ITEM_INSTANCES CSI, FND_LOOKUP_VALUES UASC
        WHERE UC.UNIT_CONFIG_HEADER_ID = p_uc_header_id
          AND UC.csi_item_instance_id = CSI.instance_id
          AND UC.unit_config_status_code                    = UCSC.lookup_code
          AND 'AHL_CONFIG_STATUS'                           = UCSC.lookup_type
          AND UCSC.language                                 = USERENV('LANG')
          AND UC.active_uc_status_code                      = UASC.lookup_code (+)
          AND 'AHL_CONFIG_STATUS'                           = UASC.lookup_type (+)
          AND UASC.language (+)                             = USERENV('LANG');
  EXCEPTION
      WHEN OTHERS THEN
           RETURN l_return_value;  -- Null
  END;

  IF (l_root_uc_header_id IS NOT NULL AND l_root_uc_header_id <> p_uc_header_id) THEN
     -- That is a Subconfig UC Header Id is passed to the API.
     -- Fetch Details for the Root Node.
        BEGIN
              SELECT UC.UNIT_CONFIG_STATUS_CODE,
                     UCSC.MEANING,
                     UASC.MEANING,
                     NVL(UC.ACTIVE_END_DATE, SYSDATE + 1),
                     NVL(CSI.active_end_date,SYSDATE + 1)
               INTO l_root_status_code,
                    l_root_status,
                    l_root_active_status,
                    l_root_end_date,
                    l_root_inst_end_date
               FROM AHL_UNIT_CONFIG_HEADERS UC, FND_LOOKUP_VALUES UCSC,
                    CSI_ITEM_INSTANCES CSI, FND_LOOKUP_VALUES UASC
              WHERE UC.UNIT_CONFIG_HEADER_ID = l_root_uc_header_id
                AND UC.csi_item_instance_id = CSI.instance_id
                AND UC.unit_config_status_code                    = UCSC.lookup_code
                AND 'AHL_CONFIG_STATUS'                           = UCSC.lookup_type
                AND UCSC.language                                 = USERENV('LANG')
                AND UC.active_uc_status_code                      = UASC.lookup_code (+)
                AND 'AHL_CONFIG_STATUS'                           = UASC.lookup_type (+)
                AND UASC.language (+)                             = USERENV('LANG');
        EXCEPTION
            WHEN OTHERS THEN
                 RETURN l_return_value;  -- Null
        END;

  ELSE
     -- That is a Root UC Header Id is passed to the API.
     -- Defaulting l_root variables to l_uc values.
        l_root_status_code     := l_uc_status_code;
        l_root_status          := l_uc_status;
        l_root_active_status   := l_uc_active_status;
        l_root_end_date        := l_uc_end_date;
        l_root_inst_end_date   := l_uc_inst_end_date;
  END IF;

  IF(l_root_uc_header_id IS NOT NULL AND l_root_uc_header_id <> p_uc_header_id) THEN
    -- This unit is installed under another unit
    -- Use the details from the root unit except itself is expired either from UC or IB
    IF (l_uc_end_date < SYSDATE OR l_uc_inst_end_date < SYSDATE OR l_root_end_date < SYSDATE OR l_root_inst_end_date < SYSDATE) THEN
      -- Expired
      OPEN get_expired_value;
      FETCH get_expired_value INTO l_return_value;
      CLOSE get_expired_value;
    -- ACL :: Added Check for Quarantine and Deactivate Quarantine Status Below
    ELSIF (l_root_status_code IN (G_STATUS_COMPLETE, G_STATUS_INCOMPLETE,G_STATUS_QUARANTINE,G_STATUS_D_QUARANTINE) AND
           l_root_active_status IS NOT NULL) THEN
      -- Append active status value with status value
      l_return_value := l_root_status || ' ' || l_root_active_status;
    ELSE
      l_return_value := l_root_status;
    END IF;
  ELSE
    -- This is a stand-alone unit or is installed in an IB Tree
    -- Use the details directly from this unit itself
    IF (l_uc_end_date < SYSDATE OR l_uc_inst_end_date < SYSDATE) THEN
      -- Expired
      OPEN get_expired_value;
      FETCH get_expired_value INTO l_return_value;
      CLOSE get_expired_value;
    -- ACL :: Added Check for Quarantine and Deactivate Quarantine Status Below
    ELSIF (l_uc_status_code IN (G_STATUS_COMPLETE, G_STATUS_INCOMPLETE,G_STATUS_QUARANTINE,G_STATUS_D_QUARANTINE) AND
           l_uc_active_status IS NOT NULL) THEN
      -- Append active status value with status value
      l_return_value := l_uc_status || ' ' || l_uc_active_status;
    ELSE
      l_return_value := l_uc_status;
    END IF;
  END IF;
  RETURN l_return_value;
END Get_UC_Status;

-- Added by Jerry on 03/29/2005 in order for fixing a VWP bug 4251688(Siberian)
-- Function to get the Status (code) of a Unit Configuration
-- This function considers if the unit is installed in another unit, if it is expired etc.
-- This function is similar to the previous one but this one returns code instead of
-- meaning. It doesn't check the active status.
FUNCTION Get_UC_Status_code(p_uc_header_id IN NUMBER)
RETURN VARCHAR2
IS
-- Perf Bug Fix for - 4902980.
-- Cursor uc_details_csr to be split.
/*
  CURSOR uc_details_csr(p_uc_header_id IN NUMBER) IS
    SELECT UC.ROOT_UC_HEADER_ID,
           UC.UC_STATUS_CODE,
           UC.UC_STATUS,
           NVL(UC.ACTIVE_END_DATE, SYSDATE + 1),
           NVL(UC.INSTANCE_END_DATE, SYSDATE + 1),
           ROOT_UC.UNIT_CONFIG_STATUS_CODE,
           FL.meaning,
           NVL(ROOT_UC.ACTIVE_END_DATE, SYSDATE + 1),
           NVL(CSI.ACTIVE_END_DATE, SYSDATE + 1)
    FROM AHL_UNIT_CONFIG_HEADERS_V UC, AHL_UNIT_CONFIG_HEADERS ROOT_UC,
         CSI_ITEM_INSTANCES CSI, FND_LOOKUP_VALUES_VL FL
    WHERE UC.UC_HEADER_ID = p_uc_header_id AND
          ROOT_UC.UNIT_CONFIG_HEADER_ID = UC.ROOT_UC_HEADER_ID AND
          ROOT_UC.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID AND
          ROOT_UC.UNIT_CONFIG_STATUS_CODE = FL.LOOKUP_CODE AND
          FL.LOOKUP_TYPE = 'AHL_CONFIG_STATUS';
*/

  l_root_uc_header_id    NUMBER;
  l_uc_status_code       AHL_UNIT_CONFIG_HEADERS.UNIT_CONFIG_STATUS_CODE%TYPE;
  l_uc_status            FND_LOOKUP_VALUES.MEANING%TYPE;
  l_uc_end_date          AHL_UNIT_CONFIG_HEADERS.ACTIVE_END_DATE%TYPE;
  l_uc_inst_end_date     CSI_ITEM_INSTANCES.ACTIVE_END_DATE%TYPE;
  l_root_status_code     AHL_UNIT_CONFIG_HEADERS.UNIT_CONFIG_STATUS_CODE%TYPE;
  l_root_status          FND_LOOKUP_VALUES.MEANING%TYPE;
  l_root_end_date        AHL_UNIT_CONFIG_HEADERS.ACTIVE_END_DATE%TYPE;
  l_root_inst_end_date   CSI_ITEM_INSTANCES.ACTIVE_END_DATE%TYPE;
  l_return_value         VARCHAR2(100) := null;
  L_DEBUG_KEY            CONSTANT VARCHAR2(150) := 'ahl.plsql.AHL_UTIL_UC_PKG.Get_UC_Status_code';

BEGIN

-- Perf Bug Fix for - 4902980.
-- Cursor uc_details_csr to be split below.
/*
  OPEN uc_details_csr(p_uc_header_id);
  FETCH uc_details_csr INTO l_root_uc_header_id,
                            l_uc_status_code,
                            l_uc_status,
                            l_uc_end_date,
                            l_uc_inst_end_date,
                            l_root_status_code,
                            l_root_status,
                            l_root_end_date,
                            l_root_inst_end_date;
  IF(uc_details_csr%NOTFOUND) THEN
    CLOSE uc_details_csr;
    RETURN l_return_value;  -- Null
  END IF;
  CLOSE uc_details_csr;
*/


  -- Fetching Root UC Header Id
  BEGIN

        SELECT unit_config_header_id
          INTO l_root_uc_header_id
          FROM ahl_unit_config_headers
         WHERE parent_uc_header_id IS NULL
    START WITH unit_config_header_id = p_uc_header_id
           -- Commented out by jaramana on August 23, 2006 to show the status of Expired units correctly
           -- AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    CONNECT BY unit_config_header_id = PRIOR parent_uc_header_id;
           -- AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  EXCEPTION
      WHEN OTHERS THEN
           RETURN l_return_value;  -- Null
  END;

  -- Fetching Details for UC Id passed to the API.
  BEGIN
        SELECT UC.UNIT_CONFIG_STATUS_CODE,
               UCSC.MEANING,
               NVL(UC.ACTIVE_END_DATE, SYSDATE + 1),
               NVL(CSI.active_end_date,SYSDATE + 1)
         INTO l_uc_status_code,
              l_uc_status,
              l_uc_end_date,
              l_uc_inst_end_date
         FROM AHL_UNIT_CONFIG_HEADERS UC, FND_LOOKUP_VALUES UCSC,
              CSI_ITEM_INSTANCES CSI
        WHERE UC.UNIT_CONFIG_HEADER_ID = p_uc_header_id
          AND UC.csi_item_instance_id = CSI.instance_id
          AND UC.unit_config_status_code = UCSC.lookup_code
          AND 'AHL_CONFIG_STATUS' = UCSC.lookup_type
          AND UCSC.language = USERENV('LANG');
  EXCEPTION
      WHEN OTHERS THEN
           RETURN l_return_value;  -- Null
  END;

  IF (l_root_uc_header_id IS NOT NULL AND l_root_uc_header_id <> p_uc_header_id) THEN
     -- That is a Subconfig UC Header Id is passed to the API.
     -- Fetch Details for the Root Node.
        BEGIN
              SELECT UC.UNIT_CONFIG_STATUS_CODE,
                     UCSC.MEANING,
                     NVL(UC.ACTIVE_END_DATE, SYSDATE + 1),
                     NVL(CSI.active_end_date,SYSDATE + 1)
               INTO l_root_status_code,
                    l_root_status,
                    l_root_end_date,
                    l_root_inst_end_date
               FROM AHL_UNIT_CONFIG_HEADERS UC, FND_LOOKUP_VALUES UCSC,
                    CSI_ITEM_INSTANCES CSI
              WHERE UC.UNIT_CONFIG_HEADER_ID = l_root_uc_header_id
                AND UC.csi_item_instance_id = CSI.instance_id
                AND UC.unit_config_status_code = UCSC.lookup_code
                AND 'AHL_CONFIG_STATUS' = UCSC.lookup_type
                AND UCSC.language = USERENV('LANG');
        EXCEPTION
            WHEN OTHERS THEN
                 RETURN l_return_value;  -- Null
        END;

  ELSE
     -- That is a Root UC Header Id is passed to the API.
     -- Defaulting l_root variables to l_uc values.
        l_root_status_code     := l_uc_status_code;
        l_root_status          := l_uc_status;
        l_root_end_date        := l_uc_end_date;
        l_root_inst_end_date   := l_uc_inst_end_date;
  END IF;

  IF(l_root_uc_header_id IS NOT NULL AND l_root_uc_header_id <> p_uc_header_id) THEN
    -- This unit is installed under another unit
    -- Use the details from the root unit except itself is expired either from UC or IB
    IF (l_uc_end_date < SYSDATE OR l_uc_inst_end_date < SYSDATE OR l_root_end_date < SYSDATE OR l_root_inst_end_date < SYSDATE) THEN
      -- Expired
      l_return_value := G_STATUS_EXPIRED;
    ELSE
      l_return_value := l_root_status_code;
    END IF;
  ELSE
    -- This is a stand-alone unit or is installed in an IB Tree
    -- Use the details directly from this unit itself
    IF (l_uc_end_date < SYSDATE OR l_uc_inst_end_date < SYSDATE) THEN
      -- Expired
      l_return_value := G_STATUS_EXPIRED;
    ELSE
      l_return_value := l_uc_status_code;
    END IF;
  END IF;
  RETURN l_return_value;
END get_uc_status_code;

-- Define Procedure copy_uc_header_to_history --
-- This common utility API is used to copy a UC header to history table whenever this UC is just newly created
-- or updated
PROCEDURE copy_uc_header_to_history (
  p_uc_header_id          IN  NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2
) IS
  l_version_no NUMBER;
  CURSOR get_uc_header IS
    SELECT *
      FROM ahl_unit_config_headers
     WHERE unit_config_header_id = p_uc_header_id;
     --AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
     --For expiration operation, when copying to history, the record has already been expired.
  l_uc_header_rec get_uc_header%ROWTYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Get the maximum version number of the particualr UC from history table
  SELECT nvl(max(version_no), 0) INTO l_version_no
  FROM ahl_uc_headers_h
  WHERE unit_config_header_id = p_uc_header_id;

  -- Insert into the exactly same record into ahl_unit_config_headers_h
  OPEN get_uc_header;
  FETCH get_uc_header INTO l_uc_header_rec;
  IF get_uc_header%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  ELSE
    INSERT INTO ahl_uc_headers_h(
        unit_config_header_id,
        version_no,
        object_version_number,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        name,
        master_config_id,
        csi_item_instance_id,
        unit_config_status_code,
        active_start_date,
        active_end_date,
        active_uc_status_code,
        parent_uc_header_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15)
    VALUES(
        l_uc_header_rec.unit_config_header_id,
        l_version_no+1,
        l_uc_header_rec.object_version_number,
        l_uc_header_rec.creation_date,
        l_uc_header_rec.created_by,
        l_uc_header_rec.last_update_date,
        l_uc_header_rec.last_updated_by,
        l_uc_header_rec.last_update_login,
        l_uc_header_rec.name,
        l_uc_header_rec.master_config_id,
        l_uc_header_rec.csi_item_instance_id,
        l_uc_header_rec.unit_config_status_code,
        l_uc_header_rec.active_start_date,
        l_uc_header_rec.active_end_date,
        l_uc_header_rec.active_uc_status_code,
        l_uc_header_rec.parent_uc_header_id,
        l_uc_header_rec.attribute_category,
        l_uc_header_rec.attribute1,
        l_uc_header_rec.attribute2,
        l_uc_header_rec.attribute3,
        l_uc_header_rec.attribute4,
        l_uc_header_rec.attribute5,
        l_uc_header_rec.attribute6,
        l_uc_header_rec.attribute7,
        l_uc_header_rec.attribute8,
        l_uc_header_rec.attribute9,
        l_uc_header_rec.attribute10,
        l_uc_header_rec.attribute11,
        l_uc_header_rec.attribute12,
        l_uc_header_rec.attribute13,
        l_uc_header_rec.attribute14,
        l_uc_header_rec.attribute15);
    END IF;
  CLOSE get_uc_header;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE get_root_uc_attr(
  p_uc_header_id          IN  NUMBER,
  x_uc_header_id          OUT NOCOPY NUMBER,
  x_instance_id           OUT NOCOPY NUMBER,
  x_uc_status_code        OUT NOCOPY VARCHAR2,
  x_active_uc_status_code OUT NOCOPY VARCHAR2,
  x_uc_header_ovn         OUT NOCOPY NUMBER)
IS
  l_uc_header_id          NUMBER := NULL;
  l_instance_id           NUMBER := NULL;
  l_uc_status_code        fnd_lookup_values.lookup_code%TYPE := NULL;
  l_active_uc_status_code fnd_lookup_values.lookup_code%TYPE := NULL;
  l_uc_header_ovn         NUMBER;
  CURSOR get_top_unit(c_uc_header_id NUMBER) IS
    SELECT unit_config_header_id,
           csi_item_instance_id,
           unit_config_status_code,
           active_uc_status_code,
           object_version_number
      FROM ahl_unit_config_headers
     WHERE parent_uc_header_id IS NULL
START WITH unit_config_header_id = c_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY unit_config_header_id = PRIOR parent_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_top_unit(p_uc_header_id);
  FETCH get_top_unit INTO l_uc_header_id,
                          l_instance_id,
                          l_uc_status_code,
                          l_active_uc_status_code,
                          l_uc_header_ovn;
  IF get_top_unit%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
  END IF;
  CLOSE get_top_unit;
  x_uc_header_id := l_uc_header_id;
  x_instance_id := l_instance_id;
  x_uc_status_code := l_uc_status_code;
  x_active_uc_status_code := l_active_uc_status_code;
  x_uc_header_ovn := l_uc_header_ovn;
END;

FUNCTION extra_node(p_instance_id IN NUMBER, p_top_instance_id NUMBER) RETURN BOOLEAN
IS
  l_dummy_num NUMBER;
  CURSOR check_extra IS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE position_reference IS NULL
START WITH subject_id = p_instance_id
       AND subject_id <> p_top_instance_id
       --And this one more condition just in order to avoid p_instance_id = p_top_instance_id
       --and it is a subunit or installed unit
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND subject_id <> p_top_instance_id;
BEGIN
  OPEN check_extra;
  FETCH check_extra INTO l_dummy_num;
  IF check_extra%FOUND THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
  CLOSE check_extra;
END;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
-- As non-serialized item instances with partial quantities can be assigned to MC positions now,
-- their quantity check with position/associated-item quantity should be relaxed from '=' to '<='.
--
-- When calling the API inv_convert.inv_um_convert, note that it returns -99999 if the UOM conversion is not possible.
-- We should not be considering this as item match found.
FUNCTION item_match(p_mc_relationship_id   IN   NUMBER,
                    p_inventory_item_id    IN   NUMBER,
                    p_organization_id      IN   NUMBER,
                    p_revision             IN   VARCHAR2,
                    p_quantity             IN   NUMBER,
                    p_uom_code             IN   VARCHAR2)
RETURN BOOLEAN IS
  l_return_value  BOOLEAN;
  CURSOR ahl_relationships_csr(c_mc_relationship_id   IN   NUMBER,
                               c_inventory_item_id    IN   NUMBER,
                               c_organization_id      IN   NUMBER) IS
    SELECT A.quantity item_quantity,
           A.uom_code item_uom_code,
           A.revision item_revision,
           R.quantity position_quantity,
           R.uom_code position_uom_code
      FROM ahl_mc_relationships R,
           ahl_item_associations_b A
     WHERE R.item_group_id = A.item_group_id
       AND R.relationship_id = c_mc_relationship_id
       AND A.inventory_item_id  = c_inventory_item_id
       AND A.inventory_org_id = c_organization_id
       AND A.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
       --Added by Jerry on 04/26/2005
       AND trunc(nvl(R.active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(nvl(R.active_end_date, sysdate+1)) > trunc(sysdate);
  l_item_posn_rec ahl_relationships_csr%ROWTYPE;
  l_quantity      NUMBER;
BEGIN
  l_return_value := FALSE;
  OPEN ahl_relationships_csr(p_mc_relationship_id,
                             p_inventory_item_id,
                             p_organization_id);
  LOOP
    FETCH ahl_relationships_csr INTO l_item_posn_rec;
    EXIT WHEN ahl_relationships_csr%NOTFOUND OR l_return_value;
    --Validations for quantity, uom_code and revision.
    IF (l_item_posn_rec.item_quantity IS NULL OR l_item_posn_rec.item_quantity = 0) THEN
      -- position based validation.
      IF (l_item_posn_rec.position_uom_code = p_uom_code) THEN
        IF (p_quantity <= l_item_posn_rec.position_quantity) THEN
          l_return_value := TRUE;
        END IF;
      ELSE
      --Convert quantity to position uom.
        l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_inventory_item_id,
                               precision      => 6,
                               from_quantity  => p_quantity,
                               from_unit      => p_uom_code,
                               to_unit        => l_item_posn_rec.position_uom_code,
                               from_name      => NULL,
                               to_name        => NULL );
        IF (l_quantity >=0 AND l_quantity <= l_item_posn_rec.position_quantity) THEN
          l_return_value := TRUE;
        END IF;
      END IF;
    ELSE
      --Item based validation
      IF (l_item_posn_rec.item_uom_code = p_uom_code) THEN
        IF (p_quantity <= l_item_posn_rec.item_quantity) THEN
          l_return_value := TRUE;
        END IF;
      ELSE
      --Convert quantity to item uom
        l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_inventory_item_id,
                               precision      => 6,
                               from_quantity  => p_quantity,
                               from_unit      => p_uom_code,
                               to_unit        => l_item_posn_rec.item_uom_code,
                               from_name      => NULL,
                               to_name        => NULL);
        IF (l_quantity >=0 AND l_quantity <= l_item_posn_rec.item_quantity) THEN
          l_return_value := TRUE;
        END IF;
      END IF;
    END IF;

    --Check for revision.
    IF (l_return_value AND l_item_posn_rec.item_revision IS NOT NULL)  THEN
      IF (p_revision IS NULL OR (p_revision IS NOT NULL AND p_revision <> l_item_posn_rec.item_revision)) THEN
        l_return_value := FALSE;
      END IF;
    END IF;
  END LOOP;

  RETURN l_return_value;
END;

-- Define procedure get_parent_uc_header --
-- This common utility is used to get the parent uc_header_id and parent instance_id
-- for a given instance_id. This procedure always returns the parent uc_header_id and
-- the instance_id of the parent_uc_header_id (not necessary to be the immediated parent
-- instance_id of itself). If the given instance happens to be a standalone unit instance,
-- then both the return variables will be null.
PROCEDURE get_parent_uc_header(p_instance_id           IN  NUMBER,
                               x_parent_uc_header_id   OUT NOCOPY NUMBER,
                               x_parent_uc_instance_id OUT NOCOPY NUMBER)
IS
  l_uc_header_id NUMBER;
  l_instance_id  NUMBER;
  CURSOR get_parent_uc IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = p_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_id(c_instance_id NUMBER) IS
    SELECT unit_config_header_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_parent_uc;
  FETCH get_parent_uc INTO l_instance_id;
  IF get_parent_uc%NOTFOUND THEN
    x_parent_uc_header_id := NULL;
    x_parent_uc_instance_id := NULL;
  ELSE
    OPEN get_uc_header_id(l_instance_id);
    FETCH get_uc_header_id INTO l_uc_header_id;
    IF get_uc_header_id%NOTFOUND THEN
      x_parent_uc_header_id := NULL;
      x_parent_uc_instance_id := l_instance_id;
    ELSE
      x_parent_uc_header_id := l_uc_header_id;
      x_parent_uc_instance_id := l_instance_id;
    END IF;
    CLOSE get_uc_header_id;
  END IF;
  CLOSE get_parent_uc;
END;

------------------------------------------------------
-- Function to Map the instance id to a relationship id
------------------------------------------------------
FUNCTION Map_Instance_to_RelID(p_csi_ii_id           IN  NUMBER)
RETURN NUMBER
IS
--
CURSOR get_top_rel_id (csi_id IN NUMBER)
 IS
SELECT rel.relationship_id
FROM AHL_MC_RELATIONSHIPS rel,
     AHL_UNIT_CONFIG_HEADERS uch
WHERE rel.mc_header_id = uch.master_config_id
  AND rel.parent_relationship_id IS NULL
  AND uch.csi_item_instance_id = csi_id;
--
CURSOR get_relationship_id (csi_id IN NUMBER)
 IS
SELECT TO_NUMBER(position_reference)
FROM csi_ii_relationships
WHERE SUBJECT_ID = csi_id
  AND relationship_type_code = 'COMPONENT-OF'
  AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
--
l_rel_id NUMBER;
--
BEGIN
  l_rel_id := null;
  OPEN get_relationship_id (p_csi_ii_id);
  FETCH get_relationship_id INTO l_rel_id;
  IF (get_relationship_id%NOTFOUND) THEN
    OPEN get_top_rel_id (p_csi_ii_id);
    FETCH get_top_rel_id INTO l_rel_id;
    CLOSE get_top_rel_id;
  END IF;
  CLOSE get_relationship_id;

  RETURN l_rel_id;
END Map_Instance_to_RelID;

-- Define procedure get_unit_name --
-- This common utility is used to get the root unit name for a given instance_id
-- The unit name is the highest standalone unit to which the instance belongs.
-- IF the instance happens to be the root unit instance, then return the unit name
-- of itself
FUNCTION get_unit_name(p_instance_id  IN  NUMBER) RETURN VARCHAR2 IS
  l_unit_name VARCHAR2(80);
  l_instance_id    NUMBER;
  CURSOR get_uc_instance_id IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = p_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_name(c_instance_id NUMBER) IS
    SELECT name
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_uc_instance_id;
  LOOP
    FETCH get_uc_instance_id INTO l_instance_id;
    EXIT when get_uc_instance_id%NOTFOUND;
  END LOOP;
  CLOSE get_uc_instance_id;

  IF l_instance_id IS NULL THEN
    l_instance_id := p_instance_id;
  END IF;
  OPEN get_uc_header_name(l_instance_id);
  FETCH get_uc_header_name INTO l_unit_name;
  CLOSE get_uc_header_name;
  RETURN l_unit_name;
END;

-- Define procedure get_uc_header_id --
-- This common utility is used to get the root uc_header_id for a given instance_id
-- The uc_header_id is the highest standalone unit to which the instance belongs.
-- IF the instance happens to be the root unit instance, then return the uc_header_id
-- of itself
FUNCTION get_uc_header_id(p_instance_id  IN  NUMBER) RETURN NUMBER IS
  l_uc_header_id VARCHAR2(80);
  l_instance_id  NUMBER;
  CURSOR get_uc_instance_id IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = p_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_id(c_instance_id NUMBER) IS
    SELECT unit_config_header_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_uc_instance_id;
  LOOP
    FETCH get_uc_instance_id INTO l_instance_id;
    EXIT when get_uc_instance_id%NOTFOUND;
  END LOOP;
  CLOSE get_uc_instance_id;

  IF l_instance_id IS NULL THEN
    l_instance_id := p_instance_id;
  END IF;
  OPEN get_uc_header_id(l_instance_id);
  FETCH get_uc_header_id INTO l_uc_header_id;
  CLOSE get_uc_header_id;
  RETURN l_uc_header_id;
END;

-- Define function get_sub_unit_name --
-- This common utility is used to get the sub unit name for a given instance_id
-- The unit name is the lowerest sub unit to which the instance belongs.
-- IF the instance happens to be the sub unit instance, then return the sub unit name
-- of itself
FUNCTION get_sub_unit_name(p_instance_id  IN  NUMBER) RETURN VARCHAR2 IS
  l_unit_name VARCHAR2(80);
  l_instance_id    NUMBER;
  CURSOR get_uc_instance_id IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = p_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_name(c_instance_id NUMBER) IS
    SELECT name
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_uc_header_name(p_instance_id);
  FETCH get_uc_header_name INTO l_unit_name;
  IF get_uc_header_name%NOTFOUND THEN
    CLOSE get_uc_header_name;
    OPEN get_uc_instance_id;
    FETCH get_uc_instance_id INTO l_instance_id;
    IF get_uc_instance_id%FOUND THEN
      OPEN get_uc_header_name(l_instance_id);
      FETCH get_uc_header_name INTO l_unit_name;
      CLOSE get_uc_header_name;
    ELSE
      l_unit_name := NULL;
    END IF;
  ELSE
    CLOSE get_uc_header_name;
  END IF;
  RETURN l_unit_name;
END;

-- Define function get_sub_uc_header_id --
-- This common utility is used to get the sub uc_header_id for a given instance_id
-- The uc_header_id is the lowest sub uc_header_id to which the instance_id belongs.
-- IF the instance happens to be the sub unit top instance, then return the sub uc_header_id
-- of itself
FUNCTION get_sub_uc_header_id(p_instance_id  IN  NUMBER) RETURN VARCHAR2 IS
  l_uc_header_id   NUMBER;
  l_instance_id    NUMBER;
  CURSOR get_uc_instance_id IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = p_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_id(c_instance_id NUMBER) IS
    SELECT unit_config_header_id
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_uc_header_id(p_instance_id);
  FETCH get_uc_header_id INTO l_uc_header_id;
  IF get_uc_header_id%NOTFOUND THEN
    CLOSE get_uc_header_id;
    OPEN get_uc_instance_id;
    FETCH get_uc_instance_id INTO l_instance_id;
    IF get_uc_instance_id%FOUND THEN
      OPEN get_uc_header_id(l_instance_id);
      FETCH get_uc_header_id INTO l_uc_header_id;
      CLOSE get_uc_header_id;
    ELSE
      l_uc_header_id := NULL;
    END IF;
  ELSE
    CLOSE get_uc_header_id;
  END IF;
  RETURN l_uc_header_id;
END;

--  Function: This API will return FND_API.G_TRUE if a UC is in Quarantine or Deactivate
--            Quarantine Status
--  ACL :: Added for R12 changes.
FUNCTION IS_UNIT_QUARANTINED(p_unit_header_id IN NUMBER,
                             p_instance_id IN NUMBER) RETURN VARCHAR2 IS
  l_uc_header_id   NUMBER;
  l_uc_status_code VARCHAR2(30);
  l_debug_key      VARCHAR2(150) := 'ahl.plsql.AHL_UTIL_UC_PKG.IS_UNIT_QUARANTINED';

BEGIN

  -- If unit header id is not passed then derived using the instance id
  IF p_unit_header_id IS NULL THEN
     l_uc_header_id := get_uc_header_id(p_instance_id);
  ELSE
     l_uc_header_id := p_unit_header_id;
  END IF;

  -- if valid uc header id could not be derived return false.
  IF l_uc_header_id IS NULL THEN
     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EVENT, l_debug_key, 'UC Header Id Derived as NULL. p_unit_header_id :'||p_unit_header_id);
         FND_LOG.STRING(FND_LOG.LEVEL_EVENT, l_debug_key, 'UC Header Id Derived as NULL. l_uc_header_id :'||l_uc_header_id  );
         FND_LOG.STRING(FND_LOG.LEVEL_EVENT, l_debug_key, 'UC Header Id Derived as NULL. p_instance_id :'||p_instance_id);
     END IF;
     RETURN FND_API.G_FALSE;
  ELSE
  -- else derive uc status code
     l_uc_status_code := GET_UC_STATUS_CODE(l_uc_header_id);
     -- if uc status code in quarantine / deactivate quarantine then return true
     IF l_uc_status_code in (G_STATUS_QUARANTINE,G_STATUS_D_QUARANTINE) THEN
        RETURN FND_API.G_TRUE;
     ELSE
     -- else return false
        RETURN FND_API.G_FALSE;
     END IF;
  END IF;

END IS_UNIT_QUARANTINED;

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Check_Invalidate_Instance
--  Type            : Private
--  Function        : Validates the updation of interchange_type_code in an item group
--                    against active UCs where the item is installed.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version                IN      NUMBER     Required
--      p_init_msg_list              IN      VARCHAR2   Default  FND_API.G_TRUE
--      p_commit                     IN      VARCHAR2   Default  FND_API.G_FALSE
--      p_validation_level           IN      NUMBER     Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status              OUT     VARCHAR2   Required
--      x_msg_count                  OUT     NUMBER     Required
--      x_msg_data                   OUT     VARCHAR2   Required
--
--  Check_Invalidate_Instance parameters :
--      p_instance_table             IN      Instance_Tbl_Type2
--      A table of inv item id, inv org id, item_group_id, item name, item rev and
--      item interchange type
--
--  History:
--      07-JUN-06       SATHAPLI       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Invalidate_Instance
          (
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
            p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
            p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
            p_instance_tbl          IN  Instance_Tbl_Type2,
            p_operator              IN  VARCHAR2,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2
          ) IS

    --Check if the item group, inventory and org combination are valid
    CURSOR c_check_item_group_csr(c_item_group_id     NUMBER,
                                  c_inventory_item_id NUMBER,
                                  c_inventory_org_id  NUMBER ) IS
        SELECT item_group_id
        FROM   AHL_ITEM_ASSOCIATIONS_B
        WHERE  item_group_id     = c_item_group_id AND
               inventory_item_id = c_inventory_item_id AND
               inventory_org_id  = c_inventory_org_id;

    -- Get all the positions associated to this item group.
    CURSOR c_get_associated_posns_csr(c_item_group_id NUMBER) IS
        SELECT relationship_id
        FROM   AHL_MC_RELATIONSHIPS REL, AHL_MC_HEADERS_B HDR
        WHERE  HDR.mc_header_id       = REL.mc_header_id AND
               REL.item_group_id      = c_item_group_id AND
               HDR.config_status_code NOT IN ('EXPIRED','CLOSED') AND
               TRUNC(NVL(REL.active_end_date,SYSDATE+1)) > TRUNC(SYSDATE) AND
               TRUNC(NVL(REL.active_start_date,SYSDATE)) <= TRUNC(SYSDATE);

    -- Get item instances that match the position and inventory_item_id.
    CURSOR c_get_item_instances_csr(c_position_reference VARCHAR2,
                                    c_inventory_item_id  NUMBER,
                                    c_inventory_org_id   NUMBER) IS
        SELECT CSI.instance_id
        FROM   CSI_II_RELATIONSHIPS RELN, CSI_ITEM_INSTANCES CSI
        WHERE  RELN.subject_id = CSI.instance_id AND
               RELN.relationship_type_code    = 'COMPONENT-OF' AND
               RELN.position_reference        = c_position_reference AND
               CSI.inventory_item_id          = c_inventory_item_id AND
               CSI.inv_master_organization_id = c_inventory_org_id AND
               TRUNC(NVL(RELN.active_end_date, SYSDATE+1)) > TRUNC(SYSDATE) AND
               TRUNC(NVL(RELN.active_start_date,SYSDATE)) <= TRUNC(SYSDATE);

    -- Check top nodes of active unit or sub-unit that match.
    CURSOR c_chk_top_node_csr(c_relationship_id   NUMBER,
                              c_inventory_item_id NUMBER,
                              c_inventory_org_id  NUMBER) IS
        SELECT UC.name,
               UC.unit_config_header_id
        FROM   AHL_UNIT_CONFIG_HEADERS UC, CSI_ITEM_INSTANCES CSI,
               AHL_MC_RELATIONSHIPS MC
        WHERE  UC.csi_item_instance_id        = CSI.instance_id AND
               UC.master_config_id            = MC.mc_header_id AND
               UC.parent_uc_header_id         IS NULL AND
               MC.parent_relationship_id      IS NULL AND
               MC.relationship_id             = c_relationship_id AND
               CSI.inventory_item_id          = c_inventory_item_id AND
               CSI.inv_master_organization_id = c_inventory_org_id AND
               TRUNC(NVL(UC.active_end_date, SYSDATE+1)) > TRUNC(SYSDATE) AND
               TRUNC(NVL(UC.active_start_date,SYSDATE)) <= TRUNC(SYSDATE) AND
               TRUNC(NVL(CSI.active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);

    -- Get UC header info
    CURSOR c_get_uc_header_info_csr(p_csi_item_instance_id NUMBER) IS
        SELECT UC.name,
               UC.unit_config_header_id
        FROM   AHL_UNIT_CONFIG_HEADERS UC, CSI_ITEM_INSTANCES CSI
        WHERE  UC.csi_item_instance_id IN
               (SELECT object_id
                FROM   CSI_II_RELATIONSHIPS
                START WITH
                subject_id = p_csi_item_instance_id AND
                relationship_type_code = 'COMPONENT-OF' AND
                TRUNC(NVL(active_start_date,SYSDATE)) <= TRUNC(SYSDATE) AND
                TRUNC(NVL(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE)
                CONNECT BY
                PRIOR object_id = subject_id AND
                relationship_type_code = 'COMPONENT-OF' AND
                TRUNC(NVL(active_start_date,SYSDATE)) <= TRUNC(SYSDATE) AND
                TRUNC(NVL(active_end_date, SYSDATE+1)) > TRUNC(SYSDATE)
               ) AND
               UC.parent_uc_header_id                     IS NULL AND
               UC.csi_item_instance_id                    = CSI.instance_id AND
               TRUNC(NVL(UC.active_start_date,SYSDATE))   <= TRUNC(SYSDATE) AND
               TRUNC(NVL(UC.active_end_date, SYSDATE+1))  > TRUNC(SYSDATE) AND
               TRUNC(NVL(CSI.active_end_date, SYSDATE+1)) > TRUNC(SYSDATE);

    l_api_version  CONSTANT  NUMBER         := 1.0;
    l_api_name     CONSTANT  VARCHAR2(30)   := 'Check_Invalidate_Instance';
    l_full_name    CONSTANT  VARCHAR2(60)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_instance_tbl           Instance_Tbl_Type2 := p_instance_tbl;
    l_unitname               ahl_unit_config_headers.name%TYPE;
    l_unitid                 ahl_unit_config_headers.unit_config_header_id%TYPE;

    l_check_item_group_rec   c_check_item_group_csr%ROWTYPE;
    l_valid_UC_lst           VARCHAR2(2000) := NULL;

BEGIN

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validating the instance table
    IF (l_instance_tbl.COUNT >0) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,'Validating for '||
                           l_instance_tbl.COUNT||' items with flag: '||p_operator);
        END IF;

        --For all the records in the instance table
        FOR i in l_instance_tbl.FIRST..l_instance_tbl.LAST LOOP
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement,l_full_name,'Details of '||i||
                               ' table item: IG id '||l_instance_tbl(i).item_group_id||
                               ' INV id '||l_instance_tbl(i).inventory_item_id||
                               ' ORG id '||l_instance_tbl(i).inventory_org_id);
            END IF;

            l_valid_UC_lst := NULL;

            OPEN c_check_item_group_csr(l_instance_tbl(i).item_group_id,
                                      l_instance_tbl(i).inventory_item_id,
                                      l_instance_tbl(i).inventory_org_id);
            FETCH c_check_item_group_csr INTO l_check_item_group_rec;

            --Proceed if item group is found
            IF (c_check_item_group_csr%FOUND) THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement,l_full_name,i||' table item exists');
                END IF;

                --Get all the positions the item group is associated to
                FOR position_rec IN c_get_associated_posns_csr(l_instance_tbl(i).item_group_id)
                LOOP
                    --Check if the item is assigned as a top node
                    FOR top_node_csr_rec IN c_chk_top_node_csr
                                           (position_rec.relationship_id,
                                           l_instance_tbl(i).inventory_item_id,
                                           l_instance_tbl(i).inventory_org_id)
                    LOOP
                        -- append the token with the UC name
                        l_valid_UC_lst := l_valid_UC_lst || top_node_csr_rec.name || ' - '||
                                          AHL_MC_PATH_POSITION_PVT.get_posref_for_uc(
                                          top_node_csr_rec.unit_config_header_id,position_rec.relationship_id) || ', ';

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(FND_LOG.level_statement,l_full_name,i||
                                           ' table item installed at root of '||
                                           top_node_csr_rec.name||' with rel id: '||
                                           position_rec.relationship_id);
                        END IF;
                    END LOOP;

                    --Check if the item is assigned as a component
                    FOR item_instance_rec IN c_get_item_instances_csr
                                          (to_char(position_rec.relationship_id),
                                           l_instance_tbl(i).inventory_item_id,
                                           l_instance_tbl(i).inventory_org_id)
                    LOOP
                        OPEN c_get_uc_header_info_csr(item_instance_rec.instance_id);
                        FETCH c_get_uc_header_info_csr INTO l_unitname, l_unitid;

                        IF (c_get_uc_header_info_csr%FOUND) THEN
                            -- append the token with the UC name
                            l_valid_UC_lst := l_valid_UC_lst || l_unitname || ' - '||
                                              AHL_MC_PATH_POSITION_PVT.get_posref_for_uc(
                                              l_unitid,position_rec.relationship_id) || ', ';

                            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string(FND_LOG.level_statement,l_full_name,i||
                                               ' table item installed in '||l_unitname||
                                               ' with rel id: '||position_rec.relationship_id);
                            END IF;
                        END IF;

                        CLOSE c_get_uc_header_info_csr;
                    END LOOP; --item_instance_rec
                END LOOP; --position_rec

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement,l_full_name,'Msg token formed: '||l_valid_UC_lst||
                                   ' for Item name: '||l_instance_tbl(i).concatenated_segments||
                                   ' revision: '||l_instance_tbl(i).revision);
                END IF;

                IF (l_valid_UC_lst IS NOT NULL) THEN
                    -- setting the return status to error
                    x_return_status := FND_API.G_RET_STS_ERROR;

                    -- reducing the UCLIST token to appropriate length
                    IF (length(l_valid_UC_lst) > 1750) THEN
                        l_valid_UC_lst := substr(l_valid_UC_lst, 1, 1747);
                        l_valid_UC_lst := l_valid_UC_lst||'...';
                    END IF;

                    -- putting the error msg with the token in the stack
                    IF (p_operator = 'D') THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_UC_DEL_INVALID');
                    ELSIF (p_operator = 'U') THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_UC_UPD_INVALID');
                        FND_MESSAGE.Set_Token('INTCHG',l_instance_tbl(i).interchange_type);
                    END IF;
                    FND_MESSAGE.Set_Token('UCLIST',l_valid_UC_lst);
                    FND_MESSAGE.Set_Token('ITNAME',l_instance_tbl(i).concatenated_segments);
                    FND_MESSAGE.Set_Token('ITREV',l_instance_tbl(i).revision);
                    FND_MSG_PUB.ADD;
                END IF;

            END IF; -- c_check_item_group_csr%FOUND
            CLOSE c_check_item_group_csr;

        END LOOP;
    END IF; -- IF count > 0

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                   p_data  => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                   p_data  => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'Check_Invalidate_Instance',
                                 p_error_text     => SQLERRM);

        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                   p_data  => x_msg_data,
                                   p_encoded => fnd_api.g_false);

END Check_Invalidate_Instance;

--------------------------------------------------------------------------------------------
-- Added by jaramana on March 10, 2008 for fixing the Bug 6723950 (FP of 6720010)
-- This API will validate if the instance can become the new item through part change.
-- p_instance_id can be currently in an IB Tree or UC or it may be a stand alone instance.
-- It may also be the root node of a unit.
-- The return value x_matches_flag will be FND_API.G_TRUE or FND_API.G_FALSE.
PROCEDURE Item_Matches_Instance_Pos(p_inventory_item_id  IN NUMBER,
                                    p_item_revision IN VARCHAR2 default NULL,
                                    p_instance_id   IN NUMBER,
                                    x_matches_flag  OUT NOCOPY VARCHAR2) IS

  CURSOR get_uc_header_id_csr IS
   SELECT unit_config_header_id, master_config_id
     FROM ahl_unit_config_headers
    WHERE csi_item_instance_id = p_instance_id
      AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_root_mc_ig_csr (c_mc_header_id IN NUMBER) IS
   SELECT reln.relationship_id, reln.item_group_id
     FROM ahl_mc_relationships reln
    WHERE reln.mc_header_id = c_mc_header_id
      AND nvl(reln.active_start_date, sysdate - 1) <= sysdate
      AND nvl(reln.active_end_date, sysdate + 1) > sysdate
      AND reln.parent_relationship_id is null;

  CURSOR get_pos_reference_csr IS
   SELECT position_reference
     FROM csi_ii_relationships
    WHERE subject_id = p_instance_id
      AND RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
      AND NVL(ACTIVE_START_DATE, sysdate - 1) <= sysdate
      AND NVL(ACTIVE_END_DATE, sysdate + 1) > sysdate;

  CURSOR get_mc_ig_csr(c_pos_ref IN VARCHAR2) IS
   SELECT reln.item_group_id
     FROM ahl_mc_relationships reln
    WHERE relationship_id = TO_NUMBER(c_pos_ref);

  CURSOR item_group_has_item_csr(c_item_group_id IN NUMBER) IS
   SELECT 1 from ahl_item_associations_b
    WHERE item_group_id = c_item_group_id
      AND inventory_item_id = p_inventory_item_id
      AND ((revision IS NULL) OR (revision = p_item_revision))
      AND interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE');


  L_DEBUG_KEY VARCHAR2(150) := 'ahl.plsql.AHL_UTIL_UC_PKG.Item_Matches_Instance_Pos';

  l_uc_header_id     NUMBER;
  l_master_config_id NUMBER;
  l_node_ig_id       NUMBER;
  l_mc_root_rel_id   NUMBER;
  l_pos_reference    csi_ii_relationships.position_reference%TYPE;
  l_temp_num         NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.begin',
                   'At the start of the procedure. p_inventory_item_id = ' || p_inventory_item_id ||
                   ', p_item_revision = ' || p_item_revision ||
                   ', p_instance_id = ' || p_instance_id);
  END IF;
  x_matches_flag := FND_API.G_TRUE;
  IF (p_instance_id IS NOT NULL AND p_inventory_item_id IS NOT NULL) THEN
    -- Check if the instance is a unit configuration
    OPEN get_uc_header_id_csr;
    FETCH get_uc_header_id_csr INTO l_uc_header_id, l_master_config_id;
    CLOSE get_uc_header_id_csr;
    IF (l_uc_header_id IS NOT NULL) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       L_DEBUG_KEY,
                       'Instance is a unit. Unit Id: ' || l_uc_header_id);
      END IF;
      -- Instance is a unit: Get the item group of the root node of the unit's MC
      OPEN get_root_mc_ig_csr(l_master_config_id);
      FETCH get_root_mc_ig_csr INTO l_mc_root_rel_id, l_node_ig_id;
      CLOSE get_root_mc_ig_csr;
    ELSE
      -- Instance is not a unit: Check if instance is installed or not
      OPEN get_pos_reference_csr;
      FETCH get_pos_reference_csr into l_pos_reference;
      CLOSE get_pos_reference_csr;
      IF (l_pos_reference IS NULL) THEN
        -- Instance is either not installed or does not belong to a UC
        -- Cannot validate item against item group - just return TRUE
        x_matches_flag := FND_API.G_TRUE;
      ELSE
        -- Get Item group of position reference
        OPEN get_mc_ig_csr(l_pos_reference);
        FETCH get_mc_ig_csr INTO l_node_ig_id;
        CLOSE get_mc_ig_csr;
      END IF;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   L_DEBUG_KEY,
                   'Item group id of instance: ' || l_node_ig_id);
  END IF;

  IF l_node_ig_id IS NOT NULL THEN
    -- Check if the Item Group has the passed in item/revision
    OPEN item_group_has_item_csr(l_node_ig_id);
    FETCH item_group_has_item_csr INTO l_temp_num;
    IF(item_group_has_item_csr%FOUND) THEN
      x_matches_flag := FND_API.G_TRUE;
    ELSE
      x_matches_flag := FND_API.G_FALSE;
    END IF;
    CLOSE item_group_has_item_csr;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   L_DEBUG_KEY || '.end',
                   'At the end of the procedure. x_matches_flag = ' || x_matches_flag);
  END IF;
END Item_Matches_Instance_Pos;

END AHL_UTIL_UC_PKG;

/
