--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEMGROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEMGROUP_PVT" AS
/* $Header: AHLVIGPB.pls 120.6.12010000.2 2008/11/18 07:06:40 skpathak ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'Ahl_MC_ItemGroup_Pvt';
G_FND_1WAY_CODE     CONSTANT VARCHAR2(30) := '1-WAY';

-- Added by skpathak for bug-7437855 on 18-NOV-2008 - Define a package scope VARCHAR2 associative array.
TYPE G_ITEM_DTL_TYPE IS TABLE OF NUMBER INDEX BY VARCHAR2(100);

----------------------------------
-- Define Validation Procedures --
----------------------------------
PROCEDURE Validate_Item_Group_Name(p_name IN VARCHAR2, p_item_group_id IN NUMBER, p_source_id IN NUMBER) IS

-- Validation for Create item group.
-- TAMAL -- IG Amendments --
CURSOR Item_group_csr IS
     select     'x'
     from       ahl_item_groups_b
     where      name = p_name and
                nvl(p_item_group_id, -1) <> item_group_id and
                nvl(p_source_id, -1) <> item_group_id;
-- TAMAL -- IG Amendments --

  l_junk   VARCHAR2(1);

BEGIN

  IF (p_name IS NULL OR p_name = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_NAME_NULL');
      FND_MSG_PUB.ADD;
      RETURN;
  END IF;

  OPEN Item_group_csr;
  FETCH Item_group_csr INTO l_junk;
  IF (Item_group_csr%FOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_EXISTS');
      FND_MESSAGE.Set_Token('ITEM_GRP',p_name);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Item Group already exists');
  END IF;
  CLOSE Item_group_csr;

End Validate_Item_Group_Name;

----------------------------------
PROCEDURE Validate_priority
(
        p_item_group_id in Number
) IS

        CURSOR check_priority_dup_exists
        IS
                SELECT  priority
                FROM    ahl_item_associations_b
                WHERE   item_group_id = p_item_group_id
                group by priority
                having count(item_group_id) > 1;

        l_priority NUMBER;

BEGIN


        OPEN check_priority_dup_exists;
        FETCH check_priority_dup_exists INTO l_priority;
        IF (check_priority_dup_exists%FOUND)
        THEN
                FND_MESSAGE.Set_Name('AHL', 'AHL_MC_PRIORITY_NON_UNIQUE');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
                THEN
                        fnd_log.message
                        (
                                fnd_log.level_exception,
                                'ahl.plsql.'||G_PKG_NAME||'.Validate_priority',
                                true
                        );
                END IF;
                CLOSE check_priority_dup_exists;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

END Validate_priority;

--Priyan IG Mass Update Changes
--Bug # 4330922
PROCEDURE Validate_IG_revision
(
		p_item_group_id IN NUMBER
)
IS

        CURSOR check_revision_dup_exists
        IS
                SELECT  revision
                FROM    ahl_item_associations_b
                WHERE   item_group_id = p_item_group_id
                group by inventory_item_id,revision
                having count(INVENTORY_ITEM_ID) > 1;

        l_revision VARCHAR2(2);

BEGIN

        OPEN check_revision_dup_exists;
        FETCH check_revision_dup_exists INTO l_revision;
        IF (check_revision_dup_exists%FOUND)
        THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_MC_REVISION_NON_UNIQUE');
                FND_MSG_PUB.ADD;
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
                THEN
                        fnd_log.message
                        (
                                fnd_log.level_exception,
                                'ahl.plsql.'||G_PKG_NAME||'.Validate_IG_revision',
                                true
                        );
                END IF;
                CLOSE check_revision_dup_exists;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

END Validate_IG_revision;
--Priyan IG Mass Update Changes Ends.

-------------------------------------

-- SATHAPLI::Bug# 4328454 fix
-- This private procedure is called to get the item details for an item association id to be deleted.
PROCEDURE get_Item_detail(
                           p_assoc_id              IN         NUMBER,
                           x_item_group_id         OUT NOCOPY NUMBER,
                           x_inventory_item_id     OUT NOCOPY NUMBER,
                           x_inventory_org_id      OUT NOCOPY NUMBER,
                           x_concatenated_segments OUT NOCOPY VARCHAR2,
                           x_revision              OUT NOCOPY VARCHAR2
                         ) IS

    CURSOR c_get_det (p_assoc_id NUMBER) IS
        SELECT SOURCE.item_group_id item_group_id,
               SOURCE.inventory_item_id inventory_item_id,
               SOURCE.inventory_org_id inventory_org_id,
               SOURCE.revision revision,
               MTL.concatenated_segments concatenated_segments
        FROM   AHL_ITEM_ASSOCIATIONS_B SOURCE, AHL_ITEM_ASSOCIATIONS_B REVISION,
               AHL_ITEM_GROUPS_B IGROUP, MTL_SYSTEM_ITEMS_KFV MTL
        WHERE  REVISION.item_association_id = p_assoc_id AND
               IGROUP.item_group_id         = REVISION.item_group_id AND
               SOURCE.item_group_id         = IGROUP.source_item_group_id AND
               SOURCE.inventory_item_id     = REVISION.inventory_item_id AND
               SOURCE.inventory_org_id      = REVISION.inventory_org_id AND
               MTL.inventory_item_id        = SOURCE.inventory_item_id AND
               MTL.organization_id          = SOURCE.inventory_org_id;

    l_get_det     c_get_det%ROWTYPE;

    l_api_name    CONSTANT  VARCHAR2(30)  := 'get_Item_detail';
    l_full_name   CONSTANT  VARCHAR2(60)  := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

BEGIN

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API...p_assoc_id => '||p_assoc_id);
    END IF;

    OPEN c_get_det(p_assoc_id);
    FETCH c_get_det INTO l_get_det;

    IF (c_get_det%FOUND) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,'Item details found.');
        END IF;

        x_item_group_id         := l_get_det.item_group_id;
        x_inventory_item_id     := l_get_det.inventory_item_id;
        x_inventory_org_id      := l_get_det.inventory_org_id;
        x_concatenated_segments := l_get_det.concatenated_segments;
        x_revision              := l_get_det.revision;
    ELSE

	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,'The item is newly added in the revision');
        END IF;

        NULL;
    END IF;

    CLOSE c_get_det;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

END get_Item_detail;

-------------------------------------

-- SATHAPLI::Bug# 4328454 fix
-- This private procedure is called to validate updation of interchange_type_code in an IG
-- against all the valid Units where the item is installed
PROCEDURE validate_IG_update(
                              p_ItemGroup_id     IN            NUMBER,
                              x_return_status    OUT NOCOPY    VARCHAR2,
                              x_msg_count        OUT NOCOPY    NUMBER,
                              x_msg_data         OUT NOCOPY    VARCHAR2
                            ) IS

    l_api_name    CONSTANT  VARCHAR2(30)  := 'validate_IG_update';
    l_full_name   CONSTANT  VARCHAR2(60)  := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_invalid_item_instance_tbl  AHL_UTIL_UC_PKG.Instance_Tbl_Type2;

    TYPE t_id IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

    l_item_group_id_tbl          t_id;
    l_inventory_item_id_tbl      t_id;
    l_inventory_org_id_tbl       t_id;

    TYPE t_item_det IS TABLE OF VARCHAR2(80)
    INDEX BY BINARY_INTEGER;

    l_concatenated_segments_tbl  t_item_det;
    l_revision_tbl               t_item_det;
    l_interchange_type_tbl       t_item_det;

BEGIN

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- SATHAPLI::Bug# 5566764 fix
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        -- Retrieve the items that are invalidated in the current revision
        SELECT SOURCE.item_group_id,
               SOURCE.inventory_item_id,
               SOURCE.inventory_org_id,
               SOURCE.revision,
               MTL.concatenated_segments,
               FL.meaning
        BULK COLLECT
        INTO   l_item_group_id_tbl,
               l_inventory_item_id_tbl,
               l_inventory_org_id_tbl,
               l_revision_tbl,
               l_concatenated_segments_tbl,
               l_interchange_type_tbl
        FROM   AHL_ITEM_ASSOCIATIONS_B SOURCE, AHL_ITEM_ASSOCIATIONS_B REVISION,
               AHL_ITEM_GROUPS_B IGROUP, MTL_SYSTEM_ITEMS_KFV MTL,
               FND_LOOKUP_VALUES_VL FL
        WHERE  IGROUP.item_group_id     = p_ItemGroup_id AND
               REVISION.item_group_id   = IGROUP.item_group_id AND
               SOURCE.item_group_id     = IGROUP.source_item_group_id AND
               SOURCE.inventory_item_id = REVISION.inventory_item_id AND
               SOURCE.inventory_org_id  = REVISION.inventory_org_id AND
               MTL.inventory_item_id    = SOURCE.inventory_item_id AND
               MTL.organization_id      = SOURCE.inventory_org_id AND
               FL.lookup_type           = 'AHL_INTERCHANGE_ITEM_TYPE' AND
               FL.lookup_code           = REVISION.interchange_type_code AND
               NVL(REVISION.interchange_type_code, 'DELETED') IN ('REFERENCE', 'DELETED');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN;
    END;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After the BEGIN-END block.');
    END IF;

    IF (l_item_group_id_tbl.COUNT > 0) THEN
        FOR i IN l_item_group_id_tbl.FIRST..l_item_group_id_tbl.LAST
        LOOP
            l_invalid_item_instance_tbl(i).item_group_id         := l_item_group_id_tbl(i);
            l_invalid_item_instance_tbl(i).inventory_item_id     := l_inventory_item_id_tbl(i);
            l_invalid_item_instance_tbl(i).inventory_org_id      := l_inventory_org_id_tbl(i);
            l_invalid_item_instance_tbl(i).concatenated_segments := l_concatenated_segments_tbl(i);
            l_invalid_item_instance_tbl(i).revision              := l_revision_tbl(i);
            l_invalid_item_instance_tbl(i).interchange_type      := l_interchange_type_tbl(i);
        END LOOP;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,'Validating '||l_item_group_id_tbl.COUNT||
                                                               ' items in the IG for update.');
        END IF;

        -- Call UC procedure to check if active Units are getting affected
        AHL_UTIL_UC_PKG.Check_Invalidate_Instance
        (
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_FALSE,
                p_instance_tbl          => l_invalid_item_instance_tbl,
                p_operator              => 'U',
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
        );
    END IF;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

END validate_IG_update;

-------------------------------------
PROCEDURE Validate_InventoryID(p_inventory_item_id         IN   NUMBER,
                               p_inventory_org_id          IN   NUMBER,
                               p_type_code                 IN   VARCHAR2,
                               x_master_org_id             OUT  NOCOPY NUMBER,
                               x_inv_segment               OUT  NOCOPY VARCHAR2,
                               x_revision_qty_control_code OUT  NOCOPY NUMBER,
                               x_serial_number_control     OUT  NOCOPY NUMBER) IS

  CURSOR mtl_system_items_csr(p_inventory_item_id    IN NUMBER,
                              p_inventory_org_id  IN NUMBER) IS
     SELECT NVL(comms_nl_trackable_flag,'N'), concatenated_segments,
            SERIAL_NBR_CNTRL_CODE,revision_qty_cntrl_code
     FROM  ahl_mtl_items_non_ou_v
     WHERE inventory_item_id = p_inventory_item_id
     AND   inventory_org_id = p_inventory_org_id;

 CURSOR mtl_system_items_non_ou_csr(p_inventory_item_id    IN NUMBER,
                              p_inventory_org_id  IN NUMBER) IS
     SELECT NVL(comms_nl_trackable_flag,'N'), concatenated_segments,
            SERIAL_NBR_CNTRL_CODE,revision_qty_cntrl_code
     FROM  ahl_mtl_items_non_ou_v
     WHERE inventory_item_id = p_inventory_item_id
     AND   inventory_org_id = p_inventory_org_id;

  CURSOR mtl_parameters_csr(p_inventory_org_id  IN NUMBER) IS
     SELECT organization_code,
            master_organization_id
     FROM mtl_parameters
     WHERE organization_id = p_inventory_org_id;

  l_instance_track             VARCHAR2(1);
  l_segment1                   ahl_mtl_items_non_ou_v.concatenated_segments%TYPE;
  l_serial_number_control      NUMBER;
  l_revision_qty_control_code  NUMBER;
  l_organization_code          mtl_parameters.organization_code%TYPE;

BEGIN

  IF (p_inventory_item_id IS NULL)
     OR (p_inventory_item_id = FND_API.G_MISS_NUM)
     OR (p_inventory_org_id IS NULL)
     OR (p_inventory_org_id = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_NULL');
      --FND_MESSAGE.Set_Token('INV_ITEM',p_inventory_item_id);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Inventory item is null.');
      RETURN;
  END IF;

  -- For organization code
  OPEN mtl_parameters_csr(p_inventory_org_id);
  FETCH mtl_parameters_csr INTO l_organization_code,x_master_org_id;
  IF (mtl_parameters_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_INVALID');
      FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Organization does not exist');
  END IF;
  CLOSE mtl_parameters_csr;


  OPEN mtl_system_items_csr(p_inventory_item_id,p_inventory_org_id);
  FETCH mtl_system_items_csr INTO l_instance_track, l_segment1, l_serial_number_control,
                                  l_revision_qty_control_code;
  l_segment1 := l_segment1 || ',' || l_organization_code;

  IF (mtl_system_items_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
      FND_MESSAGE.Set_Token('INV_ITEM',p_inventory_item_id);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Inventory item does not exist');

      l_segment1 := null;
      l_revision_qty_control_code := null;
      l_serial_number_control := null;

  ELSE

      /*
      IF ( UPPER(l_instance_track) <> 'Y') THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_TRACK');
         FND_MESSAGE.Set_Token('INV_ITEM',l_segment1);
         FND_MSG_PUB.ADD;
         --dbms_output.put_line('Inventory item not trackable');
      END IF;

      */
      IF ( UPPER(p_type_code) = 'TRACKED' AND UPPER(l_instance_track) <> 'Y')
      THEN
                 FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_TRACK');
                 FND_MESSAGE.Set_Token('INV_ITEM',l_segment1);
                 FND_MSG_PUB.ADD;
                 --dbms_output.put_line('Inventory item not trackable');
      ELSIF ( UPPER(p_type_code) = 'NON-TRACKED' AND UPPER(l_instance_track) = 'Y')
      THEN
                 FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_NON_TRACK');
                 FND_MESSAGE.Set_Token('INV_ITEM',l_segment1);
                 FND_MSG_PUB.ADD;
                 --dbms_output.put_line('Inventory item are trackable');
      END IF;

   END IF;

  CLOSE mtl_system_items_csr;

  x_inv_segment := l_segment1;
  x_revision_qty_control_code := l_revision_qty_control_code;
  x_serial_number_control := l_serial_number_control;

END Validate_InventoryID;

----------------------------------

PROCEDURE Validate_Interchange_Code(p_interchange_type_code IN  VARCHAR2,
                                    p_interchange_reason    IN  VARCHAR2,
                                    p_inv_segment           IN  VARCHAR2) IS

BEGIN
  IF (p_interchange_type_code IS NULL
      OR p_interchange_type_code = FND_API.G_MISS_CHAR) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INTER_TYP_NULL');
      FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
      FND_MSG_PUB.ADD;
      RETURN;
  END IF;

  IF NOT(AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_INTERCHANGE_ITEM_TYPE', p_interchange_type_code))
     OR p_interchange_type_code = 'REMOVED' THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INTER_INVALID');
      FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
      FND_MESSAGE.Set_Token('INTER_CODE',p_interchange_type_code);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Interchange type code is invalid');
  END IF;

  IF p_interchange_type_code = '1-WAY INTERCHANGEABLE'
     AND TRIM(p_interchange_reason) IS NULL
  THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INTER_REASON_NULL');
      FND_MESSAGE.Set_Token('INTER_CODE',p_interchange_type_code);
      FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Interchange Reason is Null');
  END IF;


END Validate_Interchange_Code;

-----------------------------------
PROCEDURE Validate_Revision(p_revision         IN  VARCHAR2,
                            p_inventory_id     IN NUMBER,
                            p_organization_id  IN NUMBER,
                            p_inv_segment      IN VARCHAR2,
                            p_revision_qty_control_code IN NUMBER )  IS

   CURSOR mtl_item_revisions_csr (p_revision         IN  VARCHAR2,
                                  p_inventory_id     IN NUMBER,
                                  p_organization_id  IN NUMBER)  IS
       SELECT 'x'
       FROM   mtl_item_revisions
       WHERE    inventory_item_id = p_inventory_id
            AND organization_id = p_organization_id
            AND revision = p_revision;

   l_junk   VARCHAR2(1);

BEGIN
  IF (p_revision IS NULL) OR (p_revision = FND_API.G_MISS_CHAR) THEN
     RETURN;
  END IF;

  IF (nvl(p_revision_qty_control_code,0) <> 2) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_UC_REV_NOTNULL');
    FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
    FND_MSG_PUB.ADD;
    --dbms_output.put_line('Revision is not null. Revision not required.');
  ELSE
    OPEN mtl_item_revisions_csr(p_revision,p_inventory_id, p_organization_id);
    FETCH  mtl_item_revisions_csr INTO l_junk;
    IF (mtl_item_revisions_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INVREVI_INVALID');
      FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
      FND_MESSAGE.Set_Token('REVISION',p_revision);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Revision does not exist');
    END IF;

    CLOSE mtl_item_revisions_csr;

  END IF;

END Validate_Revision;

----------------------------------
PROCEDURE Validate_Dup_Inventory(p_name              IN VARCHAR2,
                                 p_item_group_id     IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_inventory_org_id  IN NUMBER,
                                 p_item_revision     IN VARCHAR2,
				 p_inv_segment       IN VARCHAR2,
				 p_operation_flag    IN VARCHAR2) IS

     --Priyan Item Group Change - Begins
     -- This cursor checks if the same Item with a revision(null/notnull)already exists in the DB..
	 --Bug # 4330922
     CURSOR item_revnotnull_csr(p_item_group_id IN NUMBER,
                             p_inventory_item_id IN NUMBER,
                             p_inventory_org_id IN NUMBER) IS
     SELECT REVISION
     FROM AHL_ITEM_ASSOCIATIONS_VL
     WHERE item_group_id = p_item_group_id
     AND inventory_org_id = ( Select master_organization_id
                              from   mtl_parameters
                              where  organization_id = p_inventory_org_id)
     AND inventory_item_id = p_inventory_item_id;

     -- This cursor checks if a record of the same Item with Null revision as the one passed from the UI, exists..
     CURSOR item_revnull_csr(p_item_group_id IN NUMBER,
                                        p_inventory_item_id IN NUMBER,
                                        p_item_revision IN VARCHAR2,
                                        p_inventory_org_id IN NUMBER) IS
     SELECT 'x'
     FROM AHL_ITEM_ASSOCIATIONS_VL
     WHERE item_group_id = p_item_group_id
     --AND (REVISION IS NULL OR REVISION = p_item_revision)
	 AND (REVISION IS NULL)
     AND inventory_org_id = ( Select master_organization_id
                                   from   mtl_parameters
                                   where  organization_id = p_inventory_org_id)
     AND inventory_item_id = p_inventory_item_id;


     --This cursor checks if a record of the same revision passed from the UI exists in the DB or not
     CURSOR rev_exists_csr(p_item_group_id IN NUMBER,
                            p_inventory_item_id IN NUMBER,
                            p_inventory_org_id IN NUMBER,
			    p_item_revision IN VARCHAR2) IS
     SELECT 'x'
     FROM AHL_ITEM_ASSOCIATIONS_VL
     WHERE item_group_id = p_item_group_id
        AND (REVISION = p_item_revision)
        AND inventory_org_id = (Select master_organization_id
                                  from mtl_parameters
                                 where organization_id = p_inventory_org_id)
        AND inventory_item_id = p_inventory_item_id;

     l_junk  VARCHAR2(30);

BEGIN

  IF (p_operation_flag = 'C' )  THEN
	  IF (p_item_revision = FND_API.G_MISS_CHAR OR p_item_revision IS NULL) THEN
		OPEN item_revnotnull_csr(p_item_group_id, p_inventory_item_id, p_inventory_org_id);
		FETCH item_revnotnull_csr INTO l_junk;
		IF (item_revnotnull_csr%FOUND) THEN
			    if l_junk is not null then
					FND_MESSAGE.Set_Name('AHL','AHL_MC_NOTNULL_REV_EXISTS');
					FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
					FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
					FND_MESSAGE.Set_Token('GRP_NAME',p_name);
					FND_MSG_PUB.ADD;
				ELSE
					FND_MESSAGE.Set_Name('AHL','AHL_MC_NULL_REV_EXISTS');
					FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
					FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
					FND_MESSAGE.Set_Token('GRP_NAME',p_name);
					 FND_MSG_PUB.ADD;
				END IF;
		END IF;
		CLOSE item_revnotnull_csr;
	  ELSE
		OPEN item_revnull_csr(p_item_group_id, p_inventory_item_id,p_item_revision,p_inventory_org_id);
		FETCH item_revnull_csr INTO l_junk;
		IF (item_revnull_csr%FOUND) THEN
			FND_MESSAGE.Set_Name('AHL','AHL_MC_NULL_REV_EXISTS');
			FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
			FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
			FND_MESSAGE.Set_Token('GRP_NAME',p_name);
			FND_MSG_PUB.ADD;
			CLOSE item_revnull_csr;
		ELSE
			OPEN rev_exists_csr(p_item_group_id,p_inventory_item_id,p_inventory_org_id,p_item_revision);
			FETCH rev_exists_csr INTO l_junk;
			IF (rev_exists_csr%FOUND) THEN
				FND_MESSAGE.Set_Name('AHL','AHL_MC_SAME_REV_EXISTS');
				FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
				FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
				FND_MESSAGE.Set_Token('GRP_NAME',p_name);
				FND_MSG_PUB.ADD;
			END IF;
			CLOSE rev_exists_csr;
		END IF;
	 END IF;
  ELSIF (p_operation_flag = 'M' )  THEN
	IF (p_item_revision = FND_API.G_MISS_CHAR OR p_item_revision IS NULL) THEN
	-- Check if any record exists, in the DB .
	-- If there are more than one row then the user cannot change the revison to Null as other not nul revision exists.
	-- If there is only one record, then no validation is required.
	-- If there are no records , then do nothing.
	-- If others,then raise unexpected error.
		BEGIN
			SELECT 'x'
			INTO
			   l_junk
			FROM
			   AHL_ITEM_ASSOCIATIONS_VL
			WHERE
			    item_group_id = p_item_group_id
			    AND inventory_org_id = (Select master_organization_id
						  from mtl_parameters
						 where organization_id = p_inventory_org_id)
			    AND inventory_item_id = p_inventory_item_id;

			EXCEPTION
			WHEN TOO_MANY_ROWS THEN
				FND_MESSAGE.Set_Name('AHL','AHL_MC_NOTNULL_REV_EXISTS');
				FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
				FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
				FND_MESSAGE.Set_Token('GRP_NAME',p_name);
				FND_MSG_PUB.ADD;
			WHEN NO_DATA_FOUND THEN
				NULL;
			WHEN OTHERS THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END;

  	/*ELSE --commented out for mass update changes --Priyan

		-- While updating check is made to see if the (itemgroup,item,org and rev) combination already exists in the DB,
		-- if so the user is not allowed to update the revision. Else the revision is updated
		OPEN rev_exists_csr(p_item_group_id,
				  p_inventory_item_id,
				  p_inventory_org_id,
				  p_item_revision);

		FETCH rev_exists_csr INTO l_junk;
		IF (rev_exists_csr%FOUND) THEN
			FND_MESSAGE.Set_Name('AHL','AHL_MC_NULL_OR_SAME_REV_EXISTS');
			FND_MESSAGE.Set_Token('GRP_NAME',p_name);
			FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
			FND_MSG_PUB.ADD;
		END IF;
		CLOSE rev_exists_csr;*/
	END IF;
  END IF; --checking of operation flag

END Validate_Dup_Inventory;

--Priyan Item Group Change- Ends

/* -- Bug Number 4069855
  -- Cursor changed on 21st  Dec 2004 , to allow for Items with different revisions to be added to the same Group
  -- 000 is used to denote that user has not entered a revision
  CURSOR item_assoc_csr(p_item_group_id IN NUMBER,
                        p_inventory_item_id IN NUMBER,
                        p_item_revision IN VARCHAR2,
                        p_inventory_org_id IN NUMBER) IS
     SELECT 'x'
     FROM AHL_ITEM_ASSOCIATIONS_VL
     WHERE item_group_id = p_item_group_id
     AND NVL(REVISION,'000') = p_item_revision
     AND inventory_org_id = ( Select master_organization_id
                              from   mtl_parameters
                              where  organization_id = p_inventory_org_id)
     AND inventory_item_id = p_inventory_item_id;
BEGIN
-- Bug Number 4069855
-- Changed on 21st Dec 2004, to allow for Items with different revisions to be added to the same Item Group
-- Now we have different Error mesages, depending on the combination which is Duplicate
IF (p_item_revision = FND_API.G_MISS_CHAR OR p_item_revision IS NULL) THEN
        OPEN item_assoc_csr(p_item_group_id, p_inventory_item_id,'000', p_inventory_org_id);
        FETCH item_assoc_csr INTO l_junk;
        IF (item_assoc_csr%FOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_ASSOC_DUP');
                FND_MESSAGE.Set_Token('GRP_NAME',p_name);
                FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
                FND_MSG_PUB.ADD;
        END IF;
        CLOSE item_assoc_csr;
ELSE
        OPEN item_assoc_csr(p_item_group_id, p_inventory_item_id,p_item_revision,p_inventory_org_id);
        FETCH item_assoc_csr INTO l_junk;
        IF (item_assoc_csr%FOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_ASSOC_REV_DUP');
                FND_MESSAGE.Set_Token('GRP_NAME',p_name);
                FND_MESSAGE.Set_Token('INV_ITEM',p_item_revision || ',' ||  p_inv_segment );
                FND_MSG_PUB.ADD;
        END IF;
        CLOSE item_assoc_csr;
END IF;
END Validate_Dup_Inventory;*/

----------------------------------
PROCEDURE Validate_Qty_UOM(p_uom_code           IN  VARCHAR2,
                           p_quantity           IN  NUMBER,
                           p_inventory_item_id  IN  NUMBER,
                           p_inventory_org_id   IN  NUMBER,
                           p_inv_segment        IN  VARCHAR2) IS


BEGIN

  IF (p_uom_code IS NULL AND (p_quantity IS NULL OR p_quantity = 0)) THEN
     RETURN;
  END IF;


  -- Check if UOM entered and valid.
  IF (p_uom_code IS NULL OR p_uom_code = FND_API.G_MISS_CHAR) THEN
         -- uom_code is null but quantity is not null.
         FND_MESSAGE.Set_Name('AHL','AHL_MC_INVUOM_NULL');
         FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
         FND_MSG_PUB.ADD;
         --dbms_output.put_line('Uom is null');
  ELSIF NOT(inv_convert.Validate_Item_Uom(p_item_id          => p_inventory_item_id,
                                          p_organization_id  => p_inventory_org_id,
                                          p_uom_code         => p_uom_code))
  THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_INVUOM_INVALID');
         FND_MESSAGE.Set_Token('UOM_CODE',p_uom_code);
         FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
         FND_MSG_PUB.ADD;
         --dbms_output.put_line('Invalid UOM code for the item');
  END IF;

  -- Validate quantity.
  IF (p_quantity IS NULL OR p_quantity = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_INVQTY_INVALID');
        FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
        FND_MESSAGE.Set_Token('QUANTITY',p_quantity);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Quantity is null');
   ELSIF (p_quantity < 0) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_INVQTY_INVALID');
        FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
        FND_MESSAGE.Set_Token('QUANTITY',p_quantity);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Invalid quantity');
   END IF;

END Validate_Qty_UOM;

----------------------------------
-- Added for ER# 2631303.
-- This procedure will validate if any part assignments exist in
-- Unit Configurations. This procedure will be called only when a part
-- is being deleted from an item group.
PROCEDURE Validate_UCItem_Assignment(p_item_group_id     IN NUMBER,
                                     p_inventory_item_id IN NUMBER,
                                     p_inventory_org_id  IN NUMBER,
                                     p_inv_segment       IN VARCHAR2) IS
/*
  -- Get all the positions associated to this item group.
  CURSOR get_associated_posns_csr(p_item_group_id IN NUMBER) IS
    SELECT posn.relationship_id
    FROM   ahl_relationships_b posn, ahl_item_associations_b iassoc,
           ahl_relationships_b topnode
    WHERE trunc(nvl(posn.active_end_date,sysdate+1)) > trunc(sysdate)
      AND iassoc.item_group_id = posn.item_group_id
      AND iassoc.item_group_id = p_item_group_id
      AND topnode.relationship_id = (SELECT reln.relationship_id
                                     FROM ahl_relationships_b reln
                                     WHERE parent_relationship_id is null
                                     START WITH relationship_id = posn.relationship_id
                                       AND trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate)
                                     CONNECT BY PRIOR parent_relationship_id = relationship_id
                                       AND trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate)
                                     );
                                     */
  -- Get all the positions associated to this item group.
  CURSOR get_associated_posns_csr(p_item_group_id IN NUMBER) IS
    SELECT relationship_id
      FROM ahl_mc_relationships
     WHERE trunc(nvl(active_end_date, sysdate + 1)) > trunc(sysdate)
       AND item_group_id = p_item_group_id;

  -- Get item instances that match the position and inventory_item_id.
  CURSOR get_item_instances_csr(p_position_reference IN VARCHAR2,
                                p_inventory_item_id  IN NUMBER,
                                p_inventory_org_id   IN NUMBER) IS
    SELECT instance_id csi_item_instance_id
    FROM   csi_ii_relationships reln, csi_item_instances csi
    WHERE  reln.subject_id = csi.instance_id
      AND  TRUNC(SYSDATE) < TRUNC(NVL(reln.active_end_date, SYSDATE+1))
      AND  reln.relationship_type_code = 'COMPONENT-OF'
      AND  reln.position_reference = p_position_reference
      AND  csi.inventory_item_id = p_inventory_item_id
      AND  csi.last_vld_organization_id = p_inventory_org_id;

  -- Check top nodes of a unit that match.
  CURSOR chk_top_node_csr(p_relationship_id IN NUMBER,
                            p_inventory_item_id  IN NUMBER,
                            p_inventory_org_id   IN NUMBER) IS
    SELECT 'x'
    FROM DUAL
    WHERE EXISTS (SELECT name
                  FROM ahl_unit_config_headers unit, csi_item_instances csi
                  WHERE unit.csi_item_instance_id = csi.instance_id
                    AND master_config_id = p_relationship_id
                    AND TRUNC(SYSDATE) < TRUNC(NVL(unit.active_end_date, SYSDATE+1))
                    AND csi.inventory_item_id = p_inventory_item_id
                    AND csi.last_vld_organization_id = p_inventory_org_id
                  );

  l_unitname    ahl_unit_config_headers.name%TYPE;
  l_unit_found  BOOLEAN;
  l_junk VARCHAR2(1);
BEGIN
  -- initialize.
  l_unit_found := FALSE;

  -- for each position that is associated to the item group, get all the item instances
  -- which match the position and inventory_item_id.
  FOR position_rec IN get_associated_posns_csr(p_item_group_id) LOOP
    -- Check if item assigned as top node.
    OPEN chk_top_node_csr(position_rec.relationship_id,
                          p_inventory_item_id,
                          p_inventory_org_id);
    FETCH chk_top_node_csr INTO l_junk;
    IF (chk_top_node_csr%FOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_PARTASSOC_EXISTS');
      FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
      FND_MSG_PUB.ADD;
      l_unit_found := TRUE;
    END IF;
    CLOSE chk_top_node_csr;

    --Check if item assigned as a component.
    IF NOT(l_unit_found) THEN
      FOR item_instance_rec IN get_item_instances_csr(position_rec.relationship_id,
                                                      p_inventory_item_id,
                                                      p_inventory_org_id)
      LOOP
        l_unitname := AHL_UMP_UTIL_PKG.Get_UnitName(item_instance_rec.csi_item_instance_id);
        IF (l_unitname IS NOT NULL) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_MC_PARTASSOC_EXISTS');
          FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
          FND_MSG_PUB.ADD;
          l_unit_found := TRUE;
          EXIT; -- exit instance loop.
        END IF;
      END LOOP;
    END IF;

    -- If unit found then exit.
    IF (l_unit_found) THEN
      EXIT; -- exit position loop.
    END IF;

  END LOOP;


END Validate_UCItem_Assignment;

----------------------------------
PROCEDURE Validate_Item_Assoc(p_item_group_id    IN  NUMBER    := NULL,
                              p_name             IN  VARCHAR2,
                              p_type_code        IN  VARCHAR2,
                              p_item_assoc_rec   IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type,
                              -- Changes by skpathak for bug-7437855 on 18-NOV-2008
                              -- Duplicate item association check is now done using G_ITEM_DTL_TYPE, instead of a string.
                              p_x_inventory_list IN OUT NOCOPY G_ITEM_DTL_TYPE,
                              x_row_id              OUT NOCOPY UROWID) IS


  --ROW_ID column points to AHL_ITEM_ASSOCIATIONS_B table.
  CURSOR Item_assoc_csr(p_item_assoc_id IN NUMBER) IS
     SELECT
        row_id,
        item_association_id,
        item_group_id,
        inventory_item_id,
        inventory_org_id,
        uom_code,
        quantity,
        concatenated_segments,
        revision_qty_cntrl_code,
        serial_nbr_cntrl_code  ,
        organization_code,
								REVISION
      FROM AHL_ITEM_ASSOCIATIONS_V
      WHERE item_association_id = p_item_assoc_id;

  l_item_assoc_rec   Item_assoc_csr%ROWTYPE;
  l_inv_segment      ahl_mtl_items_non_ou_v.concatenated_segments%TYPE;
  l_x_item_assoc_rec AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type DEFAULT p_item_assoc_rec;

  l_revision_qty_control_code  NUMBER;
  l_serial_number_control      NUMBER;

  l_inventory_item_id          NUMBER;

  -- Bug Number 4069855
  -- Added on 21st  Dec 2004 , to allow for Items with different revisions to be added to the same Group
  l_inventory_item_revision    VARCHAR2(3)  :=  '000';

  l_inventory_org_id           NUMBER;
  l_quantity                   ahl_item_associations_b.quantity%TYPE;
  l_uom_code                   ahl_item_associations_b.uom_code%TYPE;
  l_master_org_id              NUMBER;
  l_item_key                   VARCHAR2(200);

BEGIN

     IF (l_x_item_assoc_rec.operation_flag <> 'C') THEN
       -- Check if record exists in ahl_item_associations_b.
       OPEN Item_assoc_csr(l_x_item_assoc_rec.item_association_id);
       FETCH Item_assoc_csr INTO l_item_assoc_rec;
       IF (Item_assoc_csr%NOTFOUND) THEN
         CLOSE Item_assoc_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_ASSOS_NOT_EXISTS');
         FND_MESSAGE.Set_Token('INV_ITEM',l_item_assoc_rec.concatenated_segments);
         FND_MSG_PUB.ADD;
         --dbms_output.put_line('Item Assoc does not exist');
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Set variables.
       x_row_id   :=  l_item_assoc_rec.row_id;
       l_inv_segment  := l_item_assoc_rec.concatenated_segments || ',' || l_item_assoc_rec.organization_code;
       l_revision_qty_control_code := l_item_assoc_rec.revision_qty_cntrl_code;
       l_serial_number_control := l_item_assoc_rec.serial_nbr_cntrl_code;

       -- Check if primary key changed.
       IF ((l_x_item_assoc_rec.item_group_id IS NOT NULL) AND
           (l_x_item_assoc_rec.item_group_id <> l_item_assoc_rec.item_group_id))
          OR ((l_x_item_assoc_rec.inventory_item_id IS NOT NULL) AND
              (l_x_item_assoc_rec.inventory_item_id <> l_item_assoc_rec.inventory_item_id))
          OR ((l_x_item_assoc_rec.inventory_org_id IS NOT NULL) AND
              (l_x_item_assoc_rec.inventory_org_id <> l_item_assoc_rec.inventory_org_id))
       THEN
            CLOSE Item_assoc_csr;
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
          THEN
            l_item_key := 'Inventory Item Id '||to_char(l_x_item_assoc_rec.inventory_item_id)||' - '||to_Char(l_item_assoc_rec.inventory_item_id);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                'ahl_mc_itemgroup_pvt.Validate_Item_Assoc', l_item_key);
            l_item_key := 'Inventory Org Id '||to_Char(l_x_item_assoc_rec.inventory_org_id)||' - '||to_char(l_item_assoc_rec.inventory_org_id);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                'ahl_mc_itemgroup_pvt.Validate_Item_Assoc', l_item_key);
          END IF;

           FND_MESSAGE.Set_Name('AHL','AHL_COM_KEY_NOUPDATE');
           FND_MSG_PUB.ADD;
            --dbms_output.put_line('Primary key cannot be updated');
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

     -- plug primary key values.
     l_x_item_assoc_rec.inventory_item_id := l_item_assoc_rec.inventory_item_id;
     l_x_item_assoc_rec.inventory_org_id  := l_item_assoc_rec.inventory_org_id;
     l_x_item_assoc_rec.item_group_id := l_item_assoc_rec.item_group_id;


     END IF; /* operation_flag */

     -- Validate Inventory.
     IF (l_x_item_assoc_rec.operation_flag = 'C') THEN
       Validate_InventoryID(l_x_item_assoc_rec.inventory_item_id,
                            l_x_item_assoc_rec.inventory_org_id, p_type_code,l_master_org_id,l_inv_segment,
                            l_revision_qty_control_code, l_serial_number_control);

       -- Assigning the Master Org ID from the Validate procedure .
       -- As per 115.10 the Master Org Id should be stored in the Table.
                p_item_assoc_rec.INVENTORY_ORG_ID := l_master_org_id;

       -- This is performed only if item assoc records are being created for a
       -- existing item_group_id (i.e this is called from Modify_Item_Group.)
               IF (p_item_group_id IS NOT NULL ) THEN
                -- Priyan Bug Number 4069855
                -- Changed on 21st  Dec 2004 , to allow for Items with different revisions to be added to the same Group
                  Validate_Dup_Inventory(p_name,
                                         p_item_group_id,
                                         l_x_item_assoc_rec.inventory_item_id,
                                         l_x_item_assoc_rec.inventory_org_id,
                                         l_x_item_assoc_rec.revision,
                                         l_inv_segment,
										 l_x_item_assoc_rec.operation_flag
					 );
               END IF;

	       -- Check for duplicate inventory items in the 'create' list.
	       l_inventory_item_id := l_x_item_assoc_rec.inventory_item_id;
	       l_inventory_org_id  := l_x_item_assoc_rec.inventory_org_id;

		-- Bug Number 4069855
		-- Changed on 21st  Dec 2004 , to allow for Items with different revisions to be added to the same Group
		-- 000 is used to denote that user has not entered a revision
		IF (l_x_item_assoc_rec.revision = FND_API.G_MISS_CHAR OR l_x_item_assoc_rec.revision IS NULL) THEN
			l_inventory_item_revision := '000';
		ELSE
			l_inventory_item_revision := l_x_item_assoc_rec.revision;
		END IF;

		-- Bug Number 4069855
		-- Changed on 21st  Dec 2004 , to allow for Items with different revisions to be added to the same Group
                -- SATHAPLI::Bug# 4330922 fix
                -- Changed the way p_x_inventory_list was being created and
                -- checked for duplicate item-org-rev combinations...the
                -- delimiter ':' will be put in the end now

                -- Changes by skpathak for bug-7437855 on 18-NOV-2008 start
                -- Duplicate item association check is now done using G_ITEM_DTL_TYPE, instead of a string.
	        -- IF (p_x_inventory_list IS NOT NULL) THEN
                l_item_key := TO_CHAR(l_inventory_item_id) || '-' || TO_CHAR(l_inventory_org_id) || '-' || l_inventory_item_revision;

		    -- check if inventory id exists.
		    --Priyan : Another condition added in the IF to see if the revision is null
		    /*IF (INSTR(p_x_inventory_list,l_inventory_item_id || '-' || l_inventory_org_id||'-'||l_inventory_item_revision||':') > 0
			or (INSTR(p_x_inventory_list,l_inventory_item_id || '-' || l_inventory_org_id||'-'||'000:') >0)  ) THEN*/

                    IF (p_x_inventory_list.EXISTS(l_item_key)) THEN
                      -- if two lines without Revision are the same, show the old Error Message
		      IF (l_inventory_item_revision = '000')  THEN
			FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_ASSOC_DUP');
			FND_MESSAGE.Set_Token('GRP_NAME',p_name);
			FND_MESSAGE.Set_Token('INV_ITEM',l_inv_segment);
			FND_MSG_PUB.ADD;
			--dbms_output.put_line('Item already exists in the list');
		      ELSE
			-- if two lines have the same Revision, show new error message with Revision
			FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_ASSOC_REV_DUP');
			FND_MESSAGE.Set_Token('GRP_NAME',p_name);
			FND_MESSAGE.Set_Token('INV_ITEM',l_inventory_item_revision  || ',' || l_inv_segment);
			FND_MSG_PUB.ADD;
		      END IF;
		    ELSE
                      -- match not found, so add to the associative array p_x_inventory_list.
		      -- p_x_inventory_list := p_x_inventory_list || l_inventory_item_id || '-' || l_inventory_org_id || '-' || l_inventory_item_revision || ':' ;
                      p_x_inventory_list(l_item_key) := 1;
		    END IF;

	       /*ELSE
		 p_x_inventory_list := p_x_inventory_list || to_char(l_inventory_item_id) || '-' || to_char(l_inventory_org_id) || '-' || l_inventory_item_revision || ':' ;
	       END IF;*/
                -- Changes by skpathak for bug-7437855 on 18-NOV-2008 end

     END IF; /* for operation flag = 'C' */

     --Priyan (revision check change for update for Item Group)
	 --Bug # 4330922
     if (( l_x_item_assoc_rec.operation_flag = 'M')  and
      nvl(l_x_item_assoc_rec.revision,FND_API.G_MISS_CHAR) <>
      nvl(l_item_assoc_rec.revision,FND_API.G_MISS_CHAR))  THEN

		Validate_Dup_Inventory(p_name,
					 p_item_group_id,
					 l_x_item_assoc_rec.inventory_item_id,
					 l_x_item_assoc_rec.inventory_org_id,
					 l_x_item_assoc_rec.revision,
					 l_inv_segment,
					 l_x_item_assoc_rec.operation_flag
					 );
    END IF;
     -- End of Changes -Priyan

     -- Validate lookup codes and revision if present.
     IF (l_x_item_assoc_rec.operation_flag <> 'D') THEN
       Validate_Interchange_Code(l_x_item_assoc_rec.interchange_type_code,
                                 l_x_item_assoc_rec.interchange_reason,
                                 l_inv_segment);

       Validate_Revision(l_x_item_assoc_rec.revision,
                         l_x_item_assoc_rec.inventory_item_id,
                         l_x_item_assoc_rec.inventory_org_id, l_inv_segment,
                         l_revision_qty_control_code);

        --Interchange Reason can not be null for 1-way interchanges
        IF (l_x_item_assoc_rec.INTERCHANGE_TYPE_CODE IS NOT NULL AND
            l_x_item_assoc_rec.INTERCHANGE_TYPE_CODE = G_FND_1WAY_CODE AND
            l_x_item_assoc_rec.INTERCHANGE_REASON IS NULL) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_1WAY_MISSING_REASON');
            FND_MESSAGE.Set_Token('INV_ITEM',l_inv_segment);
            FND_MSG_PUB.ADD;
        END IF;
     END IF;


     -- Validate priority only for 'Create' and if changed during modify.
     IF (l_x_item_assoc_rec.priority <> FND_API.G_MISS_NUM AND l_x_item_assoc_rec.priority IS NOT NULL)
     THEN
          IF (l_x_item_assoc_rec.priority <= 0) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_MC_PRIORITY_INVALID');
            FND_MESSAGE.Set_Token('INV_ITEM',l_inv_segment);
            FND_MESSAGE.Set_Token('PRIORITY',l_x_item_assoc_rec.priority);
            FND_MSG_PUB.ADD;
            --dbms_output.put_line('Invalid priority');
          END IF;
     ELSIF l_x_item_assoc_rec.operation_flag = 'C' OR
          (l_x_item_assoc_rec.operation_flag = 'M' AND l_x_item_assoc_rec.priority = FND_API.G_MISS_NUM) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_MC_PRIORITY_NULL');
            FND_MESSAGE.Set_Token('INV_ITEM',l_inv_segment);
            FND_MSG_PUB.ADD;
            --dbms_output.put_line('Null priority');
     END IF;

     -- set quantity and uom values into local variables for validation.
     IF (l_x_item_assoc_rec.operation_flag = 'C') THEN
            l_quantity := l_x_item_assoc_rec.quantity;
            l_uom_code := l_x_item_assoc_rec.uom_code;
     ELSIF (l_x_item_assoc_rec.operation_flag = 'M') THEN

       -- For quantity
       IF (l_x_item_assoc_rec.quantity = FND_API.G_MISS_NUM) THEN
            l_quantity := null;
       ELSIF (l_x_item_assoc_rec.quantity = null ) THEN
            l_quantity := l_item_assoc_rec.quantity;
       ELSE
            l_quantity := l_x_item_assoc_rec.quantity;
       END IF;

       -- For uom code.
       IF (l_x_item_assoc_rec.uom_code = FND_API.G_MISS_CHAR) THEN
            l_uom_code := null;
       ELSIF (l_x_item_assoc_rec.uom_code = null) THEN
            l_uom_code := l_item_assoc_rec.uom_code;
       ELSE
            l_uom_code := l_x_item_assoc_rec.uom_code;
       END IF;

     END IF;

     -- Validate quantity and UOM.


     IF (l_x_item_assoc_rec.operation_flag = 'C' OR
         l_x_item_assoc_rec.operation_flag = 'M' )
     THEN
       Validate_Qty_UOM(p_uom_code           => l_uom_code,
                        p_quantity           => l_quantity,
                        p_inventory_item_id  => l_x_item_assoc_rec.inventory_item_id,
                        p_inventory_org_id   => l_x_item_assoc_rec.inventory_org_id,
                        p_inv_segment        => l_inv_segment);

     END IF;

     -- For serialized items quantity must be 1; if quantity not present then raise error.
     IF (l_x_item_assoc_rec.operation_flag = 'C' OR
         l_x_item_assoc_rec.operation_flag = 'M' )
     THEN
         IF (nvl(l_serial_number_control,0) IN (2,5,6)) THEN
            IF (l_quantity IS NULL OR
                l_quantity = 0 OR
                l_quantity = FND_API.G_MISS_NUM) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_SRLQTY_NULL');
                    FND_MESSAGE.Set_Token('INV_ITEM',l_inv_segment);
                    FND_MSG_PUB.ADD;
                    --dbms_output.put_line('Invalid UOM code for the item');
            ELSE
               IF (l_quantity <> 1)  THEN
                   FND_MESSAGE.Set_Name('AHL','AHL_UC_SRLQTY_MISMATCH');
                   FND_MESSAGE.Set_Token('QTY',l_quantity);
                   FND_MESSAGE.Set_Token('INV_ITEM',l_inv_segment);
                   FND_MSG_PUB.ADD;
                   --dbms_output.put_line('For serialized items Quantity must be 1');
               END IF;
            END IF;
         END IF;
     END IF; /* operation */

     -- Added for ER# 2631303.
     -- If item association is being deleted, then verify that this part is not installed in
     -- any of the unit configurations that are using this item group through their MC's.
     IF (l_x_item_assoc_rec.operation_flag = 'D') THEN
       Validate_UCItem_Assignment(l_x_item_assoc_rec.item_group_id,
                                  l_x_item_assoc_rec.inventory_item_id,
                                  l_x_item_assoc_rec.inventory_org_id,
                                  l_inv_segment);
     END IF;

     IF (Item_assoc_csr%ISOPEN) THEN
        CLOSE Item_assoc_csr;
     END IF;

End Validate_Item_Assoc;

-------------------------------------
-- Insert/Update/Delete procedures --
-------------------------------------
PROCEDURE Insert_Item_Group(p_x_item_grp_rec IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type) IS

   l_item_grp_id       NUMBER;
   l_last_update_login NUMBER;
   l_last_updated_by   NUMBER;
   l_row_id            VARCHAR2(30);

BEGIN

 -- Set default values.
 IF p_x_item_grp_rec.DESCRIPTION = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.DESCRIPTION := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE_CATEGORY =  FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE_CATEGORY := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE1 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE2 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE3 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE4 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE5 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE6 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE7 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE8 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE9 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE10 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE11 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE12 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE13 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE14 := null;
 END IF;
 IF p_x_item_grp_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
    p_x_item_grp_rec.ATTRIBUTE15 := null;
 END IF;


     --Gets the sequence Number
    SELECT AHL_ITEM_GROUPS_B_S.nextval INTO
           l_item_grp_id from DUAL;

 l_last_updated_by := to_number(fnd_global.USER_ID);
 l_last_update_login := to_number(fnd_global.LOGIN_ID);

 AHL_ITEM_GROUPS_PKG.INSERT_ROW(
X_ROWID                 =>      l_row_id,
X_ITEM_GROUP_ID         =>      l_item_grp_id,
X_TYPE_CODE             =>      p_x_item_grp_rec.type_code,
X_STATUS_CODE           =>      'DRAFT',
X_SOURCE_ITEM_GROUP_ID  =>      NULL,
X_OBJECT_VERSION_NUMBER =>      1,
X_NAME                  =>      p_x_item_grp_rec.name,
X_ATTRIBUTE_CATEGORY    =>      p_x_item_grp_rec.ATTRIBUTE_CATEGORY,
X_ATTRIBUTE1            =>      p_x_item_grp_rec.attribute1,
X_ATTRIBUTE2            =>      p_x_item_grp_rec.attribute2,
X_ATTRIBUTE3            =>      p_x_item_grp_rec.attribute3,
X_ATTRIBUTE4            =>      p_x_item_grp_rec.attribute4,
X_ATTRIBUTE5            =>      p_x_item_grp_rec.attribute5,
X_ATTRIBUTE6            =>      p_x_item_grp_rec.attribute6,
X_ATTRIBUTE7            =>      p_x_item_grp_rec.attribute7,
X_ATTRIBUTE8            =>      p_x_item_grp_rec.attribute8,
X_ATTRIBUTE9            =>      p_x_item_grp_rec.attribute9,
X_ATTRIBUTE10           =>      p_x_item_grp_rec.attribute10,
X_ATTRIBUTE11           =>      p_x_item_grp_rec.attribute11,
X_ATTRIBUTE12           =>      p_x_item_grp_rec.attribute12,
X_ATTRIBUTE13           =>      p_x_item_grp_rec.attribute13,
X_ATTRIBUTE14           =>      p_x_item_grp_rec.attribute14,
X_ATTRIBUTE15           =>      p_x_item_grp_rec.attribute15,
X_DESCRIPTION           =>      p_x_item_grp_rec.description,
X_CREATION_DATE         =>      sysdate,
X_CREATED_BY            =>      to_number(fnd_global.USER_ID),
X_LAST_UPDATE_DATE      =>      sysdate,
X_LAST_UPDATED_BY       =>      l_last_updated_by,
X_LAST_UPDATE_LOGIN     =>      l_last_update_login);


 p_x_item_grp_rec.ITEM_GROUP_ID := l_item_grp_id;  -- update id in record variable.
 p_x_item_grp_rec.OBJECT_VERSION_NUMBER := 1;


END Insert_Item_Group;

---------------------------------
PROCEDURE Create_Association(p_item_assoc_rec  IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type)
          IS

   l_item_assoc_rec   AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type  DEFAULT p_item_assoc_rec;

   l_item_association_id  NUMBER;
   l_row_id            VARCHAR2(30);
BEGIN

   -- Replace G_MISS values with nulls.
   IF (l_item_assoc_rec.REVISION = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.REVISION := null;
   END IF;
   IF (l_item_assoc_rec.QUANTITY = FND_API.G_MISS_NUM) THEN
      l_item_assoc_rec.QUANTITY := null;
      l_item_assoc_rec.UOM_CODE := null;
   ELSIF (l_item_assoc_rec.QUANTITY IS NULL OR l_item_assoc_rec.QUANTITY = 0) THEN
      l_item_assoc_rec.UOM_CODE := null;  -- if quantity = 0 then uom must be null.
   END IF;
   IF (l_item_assoc_rec.UOM_CODE = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.UOM_CODE := null;
   END IF;
   IF (l_item_assoc_rec.INTERCHANGE_TYPE_CODE =  FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.INTERCHANGE_TYPE_CODE := null;
   END IF;
   IF (l_item_assoc_rec.INTERCHANGE_REASON  = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.INTERCHANGE_REASON := null;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.ATTRIBUTE_CATEGORY := null;
   END IF;
   IF (l_item_assoc_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE1 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE2 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE3 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE4 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE5 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE6 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE7 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE8 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE9 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE10 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE11 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE12 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE13 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE14 := null;
   END IF;
      IF (l_item_assoc_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE15 := null;
   END IF;
     --Gets the sequence Number
    SELECT AHL_ITEM_ASSOCIATIONS_B_S.nextval INTO
           l_item_association_id from DUAL;

        AHL_ITEM_ASSOCIATIONS_PKG.INSERT_ROW(
                X_ROWID                         =>      l_row_id,
                X_ITEM_ASSOCIATION_ID           =>      l_item_association_id,
                X_SOURCE_ITEM_ASSOCIATION_ID    =>      NULL,
                X_OBJECT_VERSION_NUMBER         =>      1,
                X_ITEM_GROUP_ID                 =>      l_item_assoc_rec.ITEM_GROUP_ID,
                X_INVENTORY_ITEM_ID             =>      l_item_assoc_rec.INVENTORY_ITEM_ID,
                X_INVENTORY_ORG_ID              =>      l_item_assoc_rec.INVENTORY_ORG_ID,
                X_PRIORITY                      =>      l_item_assoc_rec.PRIORITY,
                X_UOM_CODE                      =>      l_item_assoc_rec.UOM_CODE,
                X_QUANTITY                      =>      l_item_assoc_rec.QUANTITY,
                X_REVISION                      =>      l_item_assoc_rec.REVISION,
                X_INTERCHANGE_TYPE_CODE         =>      l_item_assoc_rec.INTERCHANGE_TYPE_CODE,
                X_ITEM_TYPE_CODE                =>      NULL,
                X_ATTRIBUTE_CATEGORY            =>      l_item_assoc_rec.ATTRIBUTE_CATEGORY,
                X_ATTRIBUTE1                    =>      l_item_assoc_rec.ATTRIBUTE1,
                X_ATTRIBUTE2                    =>      l_item_assoc_rec.ATTRIBUTE2,
                X_ATTRIBUTE3                    =>      l_item_assoc_rec.ATTRIBUTE3,
                X_ATTRIBUTE4                    =>      l_item_assoc_rec.ATTRIBUTE4,
                X_ATTRIBUTE5                    =>      l_item_assoc_rec.ATTRIBUTE5,
                X_ATTRIBUTE6                    =>      l_item_assoc_rec.ATTRIBUTE6,
                X_ATTRIBUTE7                    =>      l_item_assoc_rec.ATTRIBUTE7,
                X_ATTRIBUTE8                    =>      l_item_assoc_rec.ATTRIBUTE8,
                X_ATTRIBUTE9                    =>      l_item_assoc_rec.ATTRIBUTE9,
                X_ATTRIBUTE10                   =>      l_item_assoc_rec.ATTRIBUTE10,
                X_ATTRIBUTE11                   =>      l_item_assoc_rec.ATTRIBUTE11,
                X_ATTRIBUTE12                   =>      l_item_assoc_rec.ATTRIBUTE12,
                X_ATTRIBUTE13                   =>      l_item_assoc_rec.ATTRIBUTE13,
                X_ATTRIBUTE14                   =>      l_item_assoc_rec.ATTRIBUTE14,
                X_ATTRIBUTE15                   =>      l_item_assoc_rec.ATTRIBUTE15,
                X_INTERCHANGE_REASON            =>      l_item_assoc_rec.INTERCHANGE_REASON,
                X_CREATION_DATE                 =>      sysdate,
                X_CREATED_BY                    =>      fnd_global.USER_ID,
                X_LAST_UPDATE_DATE              =>      sysdate,
                X_LAST_UPDATED_BY               =>      fnd_global.USER_ID,
                X_LAST_UPDATE_LOGIN             =>      fnd_global.LOGIN_ID
        );

   --Insert in AHL_ITEM_ASSOCIATIONS_B table

    l_item_assoc_rec.item_association_id := l_item_association_id;
    l_item_assoc_rec.object_version_number := 1;
    -- Set out parameter.
    p_item_assoc_rec := l_item_assoc_rec;

END Create_Association;

----------------------------
PROCEDURE Update_Association(p_item_assoc_rec   IN  AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type,
                             p_row_id           IN  UROWID)  IS

   CURSOR Item_assoc_csr(p_rowid  UROWID) IS
     SELECT
        b.ROWID ROW_ID,
        b.ITEM_ASSOCIATION_ID,
        b.SOURCE_ITEM_ASSOCIATION_ID,
        b.ITEM_GROUP_ID,
        b.INVENTORY_ITEM_ID,
        b.INVENTORY_ORG_ID,
        b.REVISION,
        b.PRIORITY,
        b.QUANTITY,
        b.UOM_CODE,
        b.INTERCHANGE_TYPE_CODE,
        tl.INTERCHANGE_REASON,
--        b.ITEM_TYPE_CODE,
        b.OBJECT_VERSION_NUMBER,
        tl.LANGUAGE,
        tl.SOURCE_LANG,
        b.ATTRIBUTE_CATEGORY,
        b.ATTRIBUTE1,
        b.ATTRIBUTE2,
        b.ATTRIBUTE3,
        b.ATTRIBUTE4,
        b.ATTRIBUTE5,
        b.ATTRIBUTE6 ,
        b.ATTRIBUTE7 ,
        b.ATTRIBUTE8,
        b.ATTRIBUTE9 ,
        b.ATTRIBUTE10,
        b.ATTRIBUTE11 ,
        b.ATTRIBUTE12,
        b.ATTRIBUTE13,
        b.ATTRIBUTE14,
        b.ATTRIBUTE15,
        b.LAST_UPDATE_DATE,
        b.LAST_UPDATED_BY,
        b.LAST_UPDATE_LOGIN
     FROM  ahl_item_associations_b b, ahl_item_associations_tl tl
     WHERE b.item_association_id = tl.item_association_id
        and b.rowid = p_rowid
        AND tl.LANGUAGE = USERENV('LANG')
    FOR UPDATE OF object_version_number NOWAIT;

   l_item_assoc_rec       AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type   DEFAULT p_item_assoc_rec;
   l_old_item_assoc_rec   Item_assoc_csr%ROWTYPE;

BEGIN

   OPEN Item_assoc_csr(p_row_id);
   FETCH Item_assoc_csr INTO l_old_item_assoc_rec;
   IF (Item_assoc_csr%NOTFOUND) THEN
         CLOSE Item_assoc_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
         FND_MSG_PUB.ADD;
         --dbms_output.put_line('Item Assoc does not exist');
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  -- Check Object version number.
  IF (l_old_item_assoc_rec.object_version_number <> l_item_assoc_rec.object_version_number) THEN
      CLOSE Item_assoc_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Check for changed columns.

   IF (l_item_assoc_rec.REVISION = NULL) THEN
      l_item_assoc_rec.REVISION := l_old_item_assoc_rec.REVISION;
   ELSIF (l_item_assoc_rec.REVISION = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.REVISION := NULL;
   END IF;

   IF (l_item_assoc_rec.PRIORITY = NULL) THEN
      l_item_assoc_rec.PRIORITY := l_old_item_assoc_rec.PRIORITY;
   ELSIF (l_item_assoc_rec.PRIORITY = FND_API.G_MISS_NUM) THEN
      l_item_assoc_rec.PRIORITY := NULL;
   END IF;

   IF (l_item_assoc_rec.QUANTITY = NULL) THEN
      l_item_assoc_rec.QUANTITY := l_old_item_assoc_rec.QUANTITY;
   ELSIF (l_item_assoc_rec.QUANTITY = FND_API.G_MISS_NUM) THEN
      l_item_assoc_rec.QUANTITY := NULL;
   ELSIF (l_item_assoc_rec.QUANTITY = 0) THEN
        l_item_assoc_rec.UOM_CODE := null;
   END IF;

   IF (l_item_assoc_rec.UOM_CODE = NULL) THEN
      l_item_assoc_rec.UOM_CODE := l_old_item_assoc_rec.UOM_CODE;
   ELSIF (l_item_assoc_rec.UOM_CODE = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.UOM_CODE := NULL;
   END IF;

   IF (l_item_assoc_rec.INTERCHANGE_TYPE_CODE =  NULL) THEN
      l_item_assoc_rec.INTERCHANGE_TYPE_CODE := l_old_item_assoc_rec.INTERCHANGE_TYPE_CODE;
   ELSIF (l_item_assoc_rec.INTERCHANGE_TYPE_CODE =  FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.INTERCHANGE_TYPE_CODE := NULL;
   END IF;

   IF (l_item_assoc_rec.INTERCHANGE_REASON  = NULL) THEN
      l_item_assoc_rec.INTERCHANGE_REASON := l_old_item_assoc_rec.INTERCHANGE_REASON;
   ELSIF (l_item_assoc_rec.INTERCHANGE_REASON  = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.INTERCHANGE_REASON := NULL;
   END IF;


   IF (l_item_assoc_rec.ATTRIBUTE_CATEGORY = NULL) THEN
      l_item_assoc_rec.ATTRIBUTE_CATEGORY := l_old_item_assoc_rec.ATTRIBUTE_CATEGORY;
   ELSIF (l_item_assoc_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
      l_item_assoc_rec.ATTRIBUTE_CATEGORY := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE1 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE1 := l_old_item_assoc_rec.ATTRIBUTE1;
   ELSIF (l_item_assoc_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE1 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE2 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE2 := l_old_item_assoc_rec.ATTRIBUTE2;
   ELSIF (l_item_assoc_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE2 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE3 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE3 := l_old_item_assoc_rec.ATTRIBUTE3;
   ELSIF (l_item_assoc_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE3 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE4 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE4 := l_old_item_assoc_rec.ATTRIBUTE4;
   ELSIF (l_item_assoc_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE4 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE6 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE6 := l_old_item_assoc_rec.ATTRIBUTE6;
   ELSIF (l_item_assoc_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE6 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE7 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE7 := l_old_item_assoc_rec.ATTRIBUTE7;
   ELSIF (l_item_assoc_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE7 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE8 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE8 := l_old_item_assoc_rec.ATTRIBUTE8;
   ELSIF (l_item_assoc_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE8 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE9 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE9 := l_old_item_assoc_rec.ATTRIBUTE9;
   ELSIF (l_item_assoc_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE9 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE10 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE10 := l_old_item_assoc_rec.ATTRIBUTE10;
   ELSIF (l_item_assoc_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE10 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE11 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE11 := l_old_item_assoc_rec.ATTRIBUTE11;
   ELSIF (l_item_assoc_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE11 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE12 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE12 := l_old_item_assoc_rec.ATTRIBUTE12;
   ELSIF (l_item_assoc_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE12 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE13 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE13 := l_old_item_assoc_rec.ATTRIBUTE13;
   ELSIF (l_item_assoc_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE13 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE14 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE14 := l_old_item_assoc_rec.ATTRIBUTE14;
   ELSIF (l_item_assoc_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE14 := NULL;
   END IF;

   IF (l_item_assoc_rec.ATTRIBUTE15 = NULL) THEN
       l_item_assoc_rec.ATTRIBUTE15 := l_old_item_assoc_rec.ATTRIBUTE15;
   ELSIF (l_item_assoc_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.ATTRIBUTE15 := NULL;
   END IF;

/*
   IF (l_item_assoc_rec.SOURCE_LANG = NULL) THEN
       l_item_assoc_rec.SOURCE_LANG := l_old_item_assoc_rec.SOURCE_LANG;
   ELSIF (l_item_assoc_rec.SOURCE_LANG = FND_API.G_MISS_CHAR) THEN
       l_item_assoc_rec.SOURCE_LANG := NULL;
   END IF;
 */

        AHL_ITEM_ASSOCIATIONS_PKG.UPDATE_ROW(
                X_ITEM_ASSOCIATION_ID           =>      l_item_assoc_rec.item_association_id,
                X_SOURCE_ITEM_ASSOCIATION_ID    =>      l_old_item_assoc_rec.SOURCE_ITEM_ASSOCIATION_ID,
                X_OBJECT_VERSION_NUMBER         =>      l_old_item_assoc_rec.object_version_number + 1,
                X_ITEM_GROUP_ID                 =>      l_item_assoc_rec.item_group_id,
                X_INVENTORY_ITEM_ID             =>      l_item_assoc_rec.inventory_item_id,
                X_INVENTORY_ORG_ID              =>      l_item_assoc_rec.inventory_org_id,
                X_PRIORITY                      =>      l_item_assoc_rec.priority,
                X_UOM_CODE                      =>      l_item_assoc_rec.uom_code,
                X_QUANTITY                      =>      l_item_assoc_rec.quantity,
                X_REVISION                      =>      l_item_assoc_rec.revision,
                X_INTERCHANGE_TYPE_CODE         =>      l_item_assoc_rec.interchange_type_code,
                X_ITEM_TYPE_CODE                =>      NULL,
                X_ATTRIBUTE_CATEGORY            =>      l_item_assoc_rec.ATTRIBUTE_CATEGORY,
                X_ATTRIBUTE1                    =>      l_item_assoc_rec.attribute1,
                X_ATTRIBUTE2                    =>      l_item_assoc_rec.attribute2,
                X_ATTRIBUTE3                    =>      l_item_assoc_rec.attribute3,
                X_ATTRIBUTE4                    =>      l_item_assoc_rec.attribute4,
                X_ATTRIBUTE5                    =>      l_item_assoc_rec.attribute5,
                X_ATTRIBUTE6                    =>      l_item_assoc_rec.attribute6,
                X_ATTRIBUTE7                    =>      l_item_assoc_rec.attribute7,
                X_ATTRIBUTE8                    =>      l_item_assoc_rec.attribute8,
                X_ATTRIBUTE9                    =>      l_item_assoc_rec.attribute9,
                X_ATTRIBUTE10                   =>      l_item_assoc_rec.attribute10,
                X_ATTRIBUTE11                   =>      l_item_assoc_rec.attribute11,
                X_ATTRIBUTE12                   =>      l_item_assoc_rec.attribute12,
                X_ATTRIBUTE13                   =>      l_item_assoc_rec.attribute13,
                X_ATTRIBUTE14                   =>      l_item_assoc_rec.attribute14,
                X_ATTRIBUTE15                   =>      l_item_assoc_rec.attribute15,
                X_INTERCHANGE_REASON            =>      l_item_assoc_rec.interchange_reason,
                X_LAST_UPDATE_DATE              =>      sysdate,
                X_LAST_UPDATED_BY               =>      fnd_global.USER_ID,
                X_LAST_UPDATE_LOGIN             =>      fnd_global.LOGIN_ID);


   CLOSE Item_assoc_csr;

END Update_Association;

-----------------------------
PROCEDURE Delete_Association(p_item_assoc_rec   IN  AHL_MC_ITEMGROUP_PVT.Item_Association_Rec_Type,
                             p_row_id           IN  UROWID)  IS

   CURSOR Item_assoc_csr(p_row_id  UROWID) IS
     SELECT
        Object_version_number
     FROM ahl_item_associations_vl
     WHERE row_id = p_row_id
     FOR UPDATE OF object_version_number NOWAIT;

   l_object_version_number NUMBER;

BEGIN

   OPEN Item_assoc_csr(p_row_id);
   FETCH Item_assoc_csr INTO l_object_version_number;
   IF (Item_assoc_csr%NOTFOUND) THEN
      CLOSE Item_assoc_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  -- Check Object version number.
  IF (l_object_version_number <> p_item_assoc_rec.object_version_number) THEN
      CLOSE Item_assoc_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Delete record.
  DELETE ahl_item_associations_b
  WHERE item_association_id = p_item_assoc_rec.item_association_id;

  DELETE ahl_item_associations_tl
  WHERE item_association_id = p_item_assoc_rec.item_association_id;

  CLOSE Item_assoc_csr;

END Delete_Association;


-----------------------------------------
-- Procedures for Item Groups  --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Create_Item_group
--  Type        : Private
--  Function    : Creates Item Group for Master Configuration in ahl_item_groups_b and TL tables. Also creates item-group association in ahl_item_associations_b/_tl table.
--  Pre-reqs    :
--  Parameters  :
-- End of Comments --

PROCEDURE Create_Item_group (p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2   := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status     OUT NOCOPY           VARCHAR2,
                             x_msg_count         OUT NOCOPY           NUMBER,
                             x_msg_data          OUT NOCOPY           VARCHAR2,
                             p_x_item_group_rec  IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type,
                             p_x_items_tbl       IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Association_Tbl_Type
                             ) IS

  l_api_name       CONSTANT VARCHAR2(30) := 'Create_Item_Group';
  l_api_version    CONSTANT NUMBER       := 1.0;

  -- Changes by skpathak for bug-7437855 on 18-NOV-2008
  -- Duplicate item association check is now done using G_ITEM_DTL_TYPE, instead of a string.
  l_inventory_list          G_ITEM_DTL_TYPE;
  l_inventory_item_id       NUMBER;
  l_item_group_id           NUMBER;  -- sequence generated item group id.
  l_name                    ahl_item_groups_b.name%TYPE;
  l_inv_segment             ahl_mtl_items_non_ou_v.concatenated_segments%TYPE;
     l_row_id            VARCHAR2(30);

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_Item_group_Pvt;


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

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
          'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Inside Create_Item_group');
  END IF;

  --dbms_output.put_line('Inside Create_Item_group');

  -- Validate Item Group Name.
  p_x_item_group_rec.name := RTRIM(p_x_item_group_rec.name);
  -- TAMAL -- IG Amendments --
  Validate_Item_Group_Name(p_x_item_group_rec.name, null, p_x_item_group_rec.source_item_group_id);
  -- TAMAL -- IG Amendments --
  l_name := p_x_item_group_rec.name;  -- Item Group name.

  --dbms_output.put_line('After validating Item Group Name');

  -- Validate Item Association record columns.
  IF (p_x_items_tbl.COUNT > 0) THEN
    -- Added by skpathak for bug-7437855 on 18-NOV-2008 - Clear l_inventory_list before using.
    l_inventory_list.DELETE;

    FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST  LOOP
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
               THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Before validating Item Group Associations');
       END IF;

       Validate_Item_Assoc(p_name => p_x_item_group_rec.name,
                           p_type_code => p_x_item_group_rec.type_code,
                            p_item_assoc_rec => p_x_items_tbl(i),
                            p_x_inventory_list  => l_inventory_list,
                            x_row_id => l_row_id);

    END LOOP;
  END IF;  /* for count > 0 */

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
               THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'After validating Item Group Associations');
   END IF;


  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
               THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Before calling Insert_Item_group');
  END IF;

  -- Insert into ahl_item_groups_b and TL.
  Insert_Item_group(p_x_item_group_rec);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
               THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'After calling Insert_Item_group');
  END IF;


  l_item_group_id := p_x_item_group_rec.item_group_id;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                 THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Before loop of Item Association');
    END IF;


  -- Insert into ahl_item_associations_b/_tl.
  IF (p_x_items_tbl.COUNT > 0) THEN
    FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST  LOOP
       p_x_items_tbl(i).ITEM_GROUP_ID := l_item_group_id;
       Create_Association(p_x_items_tbl(i));
    END LOOP;
  END IF; /* count > 0 */

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                 THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'After loop of Item Association');
    END IF;

validate_priority(l_item_group_id);

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'End of create_item_group private');
END IF;


  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Create_Item_group_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Error in create_item_group private');
   END IF;



 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Create_Item_group_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Unexpected error in create_item_group private');
END IF;


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Create_Item_group_pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_Item_group',
                               p_error_text     => SQLERRM);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', 'Unknown error in create_item_group private');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.create_item_group', SQLERRM);
END IF;

END Create_Item_group;


-- Start of Comments --
--  Procedure name    : Modify_Item_group
--  Type        : Private
--  Function    : Modifies Item Group for Master Configuration in ahl_item_groups_b and TL tables. Also creates/deletes/modifies item-group association in ahl_item_associations_b/_tl table.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :

PROCEDURE Modify_Item_group (p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2    := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER      := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status     OUT NOCOPY           VARCHAR2,
                             x_msg_count         OUT NOCOPY           NUMBER,
                             x_msg_data          OUT NOCOPY           VARCHAR2,
                             p_item_group_rec    IN            AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type,
                             p_x_items_tbl       IN OUT NOCOPY AHL_MC_ITEMGROUP_PVT.Item_Association_Tbl_Type
                             ) IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Modify_Item_Group';
  l_api_version CONSTANT NUMBER       := 1.0;

  CURSOR Item_group_csr(p_item_group_id  IN  NUMBER)  IS
     SELECT
        b.ROWID ROW_ID,
        b.ITEM_GROUP_ID,
        b.source_item_group_id,
        b.NAME,
        b.type_code,
        b.status_code,
        b.OBJECT_VERSION_NUMBER,
        b.ATTRIBUTE_CATEGORY,
        b.ATTRIBUTE1,
        b.ATTRIBUTE2,
        b.ATTRIBUTE3,
        b.ATTRIBUTE4,
        b.ATTRIBUTE5,
        b.ATTRIBUTE6,
        b.ATTRIBUTE7,
        b.ATTRIBUTE8,
        b.ATTRIBUTE9,
        b.ATTRIBUTE10,
        b.ATTRIBUTE11,
        b.ATTRIBUTE12,
        b.ATTRIBUTE13,
        b.ATTRIBUTE14,
        b.ATTRIBUTE15,
        b.LAST_UPDATE_DATE,
        b.LAST_UPDATED_BY,
        b.CREATION_DATE,
        b.CREATED_BY,
        b.LAST_UPDATE_LOGIN,
        TL.LANGUAGE,
        TL.SOURCE_LANG,
        TL.DESCRIPTION
     FROM
        AHL_ITEM_GROUPS_B b, AHL_ITEM_GROUPS_TL tl
     WHERE
        b.ITEM_GROUP_ID = tl.ITEM_GROUP_ID
        AND b.ITEM_GROUP_ID = p_item_group_id
        AND tl.LANGUAGE = USERENV('LANG')
     FOR UPDATE OF b.OBJECT_VERSION_NUMBER NOWAIT;

     l_old_item_group_rec    Item_group_csr%ROWTYPE;
     l_item_group_rec        AHL_MC_ITEMGROUP_PVT.Item_group_rec_Type   DEFAULT p_item_group_rec;

     TYPE l_rowid_tbl_type IS TABLE OF UROWID INDEX BY BINARY_INTEGER;
     -- Build table with Rowid for Item Associations.

     -- Changes by skpathak for bug-7437855 on 18-NOV-2008
     -- Duplicate item association check is now done using G_ITEM_DTL_TYPE, instead of a string.
     l_inventory_list    G_ITEM_DTL_TYPE;
     l_rowid_tbl         l_rowid_tbl_type;
     l_row_id            VARCHAR2(30);

-- SATHAPLI::Bug# 4328454 fix
     l_full_name   CONSTANT       VARCHAR(60)  := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
     l_invalid_item_instance_tbl  AHL_UTIL_UC_PKG.Instance_Tbl_Type2;
     l_update_flag                VARCHAR2(1)  := 'N';
     l_index                      NUMBER       := 1;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Modify_Item_group_Pvt;

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

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Begin of Modify_Item_group');
  END IF;

  -- Validate Item Group record.
  OPEN Item_group_csr(p_item_group_rec.item_group_id);
  FETCH Item_group_csr INTO l_old_item_group_rec;
  IF (Item_group_csr%NOTFOUND) THEN
      CLOSE Item_group_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Item Group does not exist');
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check Object version number.
  IF (l_old_item_group_rec.object_version_number <> NVL(p_item_group_rec.object_version_number,0)) THEN
      CLOSE Item_group_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check name
  -- TAMAL -- IG Amendments --
  IF (l_old_item_group_rec.status_code = 'DRAFT' and l_old_item_group_rec.source_item_group_id is not null)
  THEN
        Validate_Item_Group_Name (l_item_group_rec.name, l_old_item_group_rec.item_group_id, l_old_item_group_rec.source_item_group_id);
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0
        THEN
                CLOSE Item_group_csr;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_old_item_group_rec.name := l_item_group_rec.name;
  -- TAMAL -- IG Amendments --
  ELSIF (l_old_item_group_rec.name <> p_item_group_rec.name )
  THEN
         CLOSE Item_group_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_COM_KEY_NOUPDATE');
         FND_MSG_PUB.ADD;
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

        IF l_old_item_group_rec.status_code in ('COMPLETE','APPROVAL_PENDING')
        THEN
         CLOSE Item_group_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_NOUPDATE');
         FND_MESSAGE.Set_Token('STATUS',p_item_group_rec.status_code);
         FND_MSG_PUB.ADD;
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
         --dbms_output.put_line('Item Group cannot be updated if status is Complete or Approval Rejected');
        END IF;

  IF (p_item_group_rec.status_code <> FND_API.G_MISS_CHAR) THEN

     IF (p_item_group_rec.status_code <> l_old_item_group_rec.status_code)
     THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_STAT_NOUPDATE');
         FND_MSG_PUB.ADD;
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
         --dbms_output.put_line('Item Group Status cannot be updated');
     END IF;
  END IF;

  IF (p_item_group_rec.type_code <> FND_API.G_MISS_CHAR) THEN
     IF (p_item_group_rec.type_code <> l_old_item_group_rec.type_code)
     THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_NOUPDATE');
         FND_MSG_PUB.ADD;
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
         --dbms_output.put_line('Item Group Type cannot be updated');
     END IF;

  END IF;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Loop to validate Item Association');
  END IF;

  -- Validate Item Assoc records.
  IF (p_x_items_tbl.COUNT > 0 ) THEN
    -- Added by skpathak for bug-7437855 on 18-NOV-2008 - Clear l_inventory_list before using.
    l_inventory_list.DELETE;

    FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST LOOP
        -- Check if association record belongs to the item group.
        IF (p_x_items_tbl(i).item_group_id <> p_item_group_rec.item_group_id) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_MISMATCH');
          FND_MESSAGE.Set_Token('ITEM_GRP',p_item_group_rec.item_group_id);
          FND_MESSAGE.Set_Token('ASSO_GRP',p_x_items_tbl(i).item_group_id);
          FND_MSG_PUB.ADD;
          --dbms_output.put_line('Item Association record does not match Item Group');
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        Validate_Item_Assoc(p_name => p_item_group_rec.name,
                            p_type_code => p_item_group_rec.type_code,
                            p_item_group_id => p_item_group_rec.item_group_id,
                            p_item_assoc_rec => p_x_items_tbl(i),
                            p_x_inventory_list => l_inventory_list,
                            x_row_id => l_row_id);

        l_rowid_tbl(i)  :=  l_row_id;

    END LOOP;
  END IF; /* count > 0 */

IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'End of Loop');
END IF;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (l_item_group_rec.operation_flag = 'M') THEN

  -- Check for changed values.

    IF (l_old_item_group_rec.status_code = 'APPROVAL_REJECTED') THEN
       l_old_item_group_rec.status_code := 'DRAFT';
    END IF;

    IF (l_item_group_rec.DESCRIPTION = NULL) THEN
       l_item_group_rec.DESCRIPTION := l_old_item_group_rec.DESCRIPTION;
    ELSIF (l_item_group_rec.DESCRIPTION = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.DESCRIPTION := NULL;
    END IF;

   IF (l_item_group_rec.ATTRIBUTE_CATEGORY = NULL) THEN
      l_item_group_rec.ATTRIBUTE_CATEGORY := l_old_item_group_rec.ATTRIBUTE_CATEGORY;
   ELSIF (l_item_group_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
      l_item_group_rec.ATTRIBUTE_CATEGORY := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE1 = NULL) THEN
       l_item_group_rec.ATTRIBUTE1 := l_old_item_group_rec.ATTRIBUTE1;
   ELSIF (l_item_group_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE1 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE2 = NULL) THEN
       l_item_group_rec.ATTRIBUTE2 := l_old_item_group_rec.ATTRIBUTE2;
   ELSIF (l_item_group_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE2 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE3 = NULL) THEN
       l_item_group_rec.ATTRIBUTE3 := l_old_item_group_rec.ATTRIBUTE3;
   ELSIF (l_item_group_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE3 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE4 = NULL) THEN
       l_item_group_rec.ATTRIBUTE4 := l_old_item_group_rec.ATTRIBUTE4;
   ELSIF (l_item_group_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE4 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE6 = NULL) THEN
       l_item_group_rec.ATTRIBUTE6 := l_old_item_group_rec.ATTRIBUTE6;
   ELSIF (l_item_group_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE6 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE7 = NULL) THEN
       l_item_group_rec.ATTRIBUTE7 := l_old_item_group_rec.ATTRIBUTE7;
   ELSIF (l_item_group_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE7 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE8 = NULL) THEN
       l_item_group_rec.ATTRIBUTE8 := l_old_item_group_rec.ATTRIBUTE8;
   ELSIF (l_item_group_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE8 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE9 = NULL) THEN
       l_item_group_rec.ATTRIBUTE9 := l_old_item_group_rec.ATTRIBUTE9;
   ELSIF (l_item_group_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE9 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE10 = NULL) THEN
       l_item_group_rec.ATTRIBUTE10 := l_old_item_group_rec.ATTRIBUTE10;
   ELSIF (l_item_group_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE10 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE11 = NULL) THEN
       l_item_group_rec.ATTRIBUTE11 := l_old_item_group_rec.ATTRIBUTE11;
   ELSIF (l_item_group_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE11 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE12 = NULL) THEN
       l_item_group_rec.ATTRIBUTE12 := l_old_item_group_rec.ATTRIBUTE12;
   ELSIF (l_item_group_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE12 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE13 = NULL) THEN
       l_item_group_rec.ATTRIBUTE13 := l_old_item_group_rec.ATTRIBUTE13;
   ELSIF (l_item_group_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE13 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE14 = NULL) THEN
       l_item_group_rec.ATTRIBUTE14 := l_old_item_group_rec.ATTRIBUTE14;
   ELSIF (l_item_group_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE14 := NULL;
   END IF;

   IF (l_item_group_rec.ATTRIBUTE15 = NULL) THEN
       l_item_group_rec.ATTRIBUTE15 := l_old_item_group_rec.ATTRIBUTE15;
   ELSIF (l_item_group_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.ATTRIBUTE15 := NULL;
   END IF;

/*
   IF (l_item_group_rec.SOURCE_LANG = NULL) THEN
       l_item_group_rec.SOURCE_LANG := l_old_item_group_rec.SOURCE_LANG;
   ELSIF (l_item_group_rec.SOURCE_LANG = FND_API.G_MISS_CHAR) THEN
       l_item_group_rec.SOURCE_LANG := NULL;
   END IF;
*/

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Before calling Item Group Table Handler');
  END IF;

        AHL_ITEM_GROUPS_PKG.UPDATE_ROW(
                X_ITEM_GROUP_ID         =>      l_old_item_group_rec.item_group_id,
                X_TYPE_CODE             =>      l_old_item_group_rec.type_code,
                X_STATUS_CODE           =>      l_old_item_group_rec.status_code,
                X_SOURCE_ITEM_GROUP_ID  =>      l_old_item_group_rec.source_item_group_id,
                X_OBJECT_VERSION_NUMBER =>      l_old_item_group_rec.OBJECT_VERSION_NUMBER + 1,
                X_NAME                  =>      l_old_item_group_rec.name,
                X_ATTRIBUTE_CATEGORY    =>      l_item_group_rec.ATTRIBUTE_CATEGORY,
                X_ATTRIBUTE1            =>      l_item_group_rec.ATTRIBUTE1,
                X_ATTRIBUTE2            =>      l_item_group_rec.ATTRIBUTE2,
                X_ATTRIBUTE3            =>      l_item_group_rec.ATTRIBUTE3,
                X_ATTRIBUTE4            =>      l_item_group_rec.ATTRIBUTE4,
                X_ATTRIBUTE5            =>      l_item_group_rec.ATTRIBUTE5,
                X_ATTRIBUTE6            =>      l_item_group_rec.ATTRIBUTE6,
                X_ATTRIBUTE7            =>      l_item_group_rec.ATTRIBUTE7,
                X_ATTRIBUTE8            =>      l_item_group_rec.ATTRIBUTE8,
                X_ATTRIBUTE9            =>      l_item_group_rec.ATTRIBUTE9,
                X_ATTRIBUTE10           =>      l_item_group_rec.ATTRIBUTE10,
                X_ATTRIBUTE11           =>      l_item_group_rec.ATTRIBUTE11,
                X_ATTRIBUTE12           =>      l_item_group_rec.ATTRIBUTE12,
                X_ATTRIBUTE13           =>      l_item_group_rec.ATTRIBUTE13,
                X_ATTRIBUTE14           =>      l_item_group_rec.ATTRIBUTE14,
                X_ATTRIBUTE15           =>      l_item_group_rec.ATTRIBUTE15,
                X_DESCRIPTION           =>      l_item_group_rec.DESCRIPTION,
                X_LAST_UPDATE_DATE      =>      sysdate,
                X_LAST_UPDATED_BY       =>      fnd_global.USER_ID,
                X_LAST_UPDATE_LOGIN     =>      fnd_global.LOGIN_ID);

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'After Table Handler');
  END IF;


  END IF;  /* update only if operation_flag set */
  -- End Updates for Item_Groups.

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement,l_full_name,'l_old_item_group_rec.source_item_group_id => '||
                                                         l_old_item_group_rec.source_item_group_id);
  END IF;

  -- SATHAPLI::Bug# 5566764 fix
  -- Checking whether the item group being updated is a new revision or not
  -- The validation of the revision update will be done only for revisions
  IF l_old_item_group_rec.source_item_group_id IS NOT NULL THEN

    -- SATHAPLI::Bug# 4328454 fix
    -- Validate the deleted items before actually deleting them
    IF (p_x_items_tbl.COUNT > 0 ) THEN
        FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST  LOOP
            IF (p_x_items_tbl(i).operation_flag = 'D') THEN
                get_Item_detail(
                                p_assoc_id              => p_x_items_tbl(i).item_association_id,
                                x_item_group_id         => l_invalid_item_instance_tbl(l_index).item_group_id,
                                x_inventory_item_id     => l_invalid_item_instance_tbl(l_index).inventory_item_id,
                                x_inventory_org_id      => l_invalid_item_instance_tbl(l_index).inventory_org_id,
                                x_concatenated_segments => l_invalid_item_instance_tbl(l_index).concatenated_segments,
                                x_revision              => l_invalid_item_instance_tbl(l_index).revision
                               );
                l_index := l_index + 1;
            END IF;
        END LOOP;
    END IF;

    IF (l_index > 1) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,'Validating '||l_index||
                                                             ' items in the IG for remove.');
        END IF;

        AHL_UTIL_UC_PKG.Check_Invalidate_Instance
        (
              p_api_version           => 1.0,
              p_init_msg_list         => FND_API.G_FALSE,
              p_instance_tbl          => l_invalid_item_instance_tbl,
              p_operator              => 'D',
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data
        );
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF; -- end of l_old_item_group_rec.source_item_group_id IS NOT NULL

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Item Association Loop');
  END IF;

  -- Process Item Associations table.
  -- Priyan . Changed the order of the DML flag checks made for item group associations.
  --Bug # 4330922
  IF (p_x_items_tbl.COUNT > 0 ) THEN
    FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST  LOOP
       IF (p_x_items_tbl(i).operation_flag = 'D') THEN
           Delete_Association(p_x_items_tbl(i),l_rowid_tbl(i));
       ELSIF (p_x_items_tbl(i).operation_flag = 'M') THEN
           Update_Association(p_x_items_tbl(i), l_rowid_tbl(i));

           -- SATHAPLI::Bug# 4328454 fix
           l_update_flag := 'Y';

       ELSIF (p_x_items_tbl(i).operation_flag = 'C') THEN
           Create_Association(p_x_items_tbl(i));
       END IF;
    END LOOP;
  END IF;

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'End of Loop');
   END IF;

  -- The validation of the revision update will be done only for revisions
  IF l_old_item_group_rec.source_item_group_id IS NOT NULL THEN

    -- SATHAPLI::Bug# 4328454 fix
    -- Validate updation of interchange_type_code
    IF (l_update_flag = 'Y') THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling validate_IG_update.');
        END IF;

        validate_IG_update
        (
            p_ItemGroup_id   => p_item_group_rec.item_group_id,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data
        );
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF; -- end of l_old_item_group_rec.source_item_group_id IS NOT NULL

  CLOSE Item_group_csr;

  -- Validate priority for duplicate.
  validate_priority(l_old_item_group_rec.item_group_id);

  --Priyan for mass update
  --Validate revision
  --Bug # 4330922
	validate_IG_revision(l_old_item_group_rec.item_group_id);
	--Priyan  End

-- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group',
             'End of Modify_Item_group...x_return_status => '||x_return_status);
  END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Modify_Item_group_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Error in  Modify_Item_group');
  END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Modify_Item_group_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Unexpected error in Modify_Item_group');
  END IF;


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Modify_Item_group_pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Modify_Item_Group',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', 'Unknown Error in Modify_Item_group');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Modify_Item_group', SQLERRM);
  END IF;


END Modify_Item_group;


-- Start of Comments --
--  Procedure name    : Remove_Item_group
--  Type        : Private
--  Function    : Deletes an Item Group and associated item associations.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
PROCEDURE  Remove_Item_group(p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2    := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER      := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status     OUT NOCOPY           VARCHAR2,
                             x_msg_count         OUT NOCOPY           NUMBER,
                             x_msg_data          OUT NOCOPY           VARCHAR2,
                             p_item_group_rec    IN            AHL_MC_ITEMGROUP_PVT.Item_Group_Rec_Type
                             ) IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Remove_Item_Group';
  l_api_version CONSTANT NUMBER       := 1.0;


  CURSOR Item_group_csr(p_item_group_id  IN  NUMBER)  IS
     SELECT
        b.ROWID ROW_ID,
        b.ITEM_GROUP_ID,
        b.OBJECT_VERSION_NUMBER,
        b.NAME,
        b.Status_Code,
        b.source_item_group_id
     FROM
        AHL_ITEM_GROUPS_B b
     WHERE
        b.ITEM_GROUP_ID = p_item_group_id
     FOR UPDATE OF b.OBJECT_VERSION_NUMBER NOWAIT;

/*
  CURSOR ahl_relationships_csr(p_item_group_id  IN  NUMBER) IS
     SELECT 'x'
     from ahl_mc_relationships_v posn, ahl_mc_relationships_v topnode
     where trunc(nvl(posn.active_end_date,sysdate+1)) > trunc(sysdate)
     and posn.item_group_id = p_item_group_id
     and topnode.relationship_id = (SELECT reln.relationship_id from
                                    ahl_mc_relationships reln
                                    where parent_relationship_id is null
                                    start with relationship_id = posn.relationship_id
                                    and trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate)
                                    connect by prior parent_relationship_id = relationship_id
                                    and trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate)
                                    );
*/

 CURSOR ahl_relationships_csr(p_item_group_id IN NUMBER) IS
    SELECT 'x'
      FROM ahl_mc_relationships
     WHERE trunc(nvl(active_end_date, sysdate + 1)) > trunc(sysdate)
       AND item_group_id = p_item_group_id;

 CURSOR ahl_item_comp_csr(p_item_group_id IN NUMBER) IS
    SELECT 'x'
      FROM ahl_item_comp_details
     WHERE trunc(nvl(effective_end_date, sysdate + 1)) > trunc(sysdate)
       AND item_group_id = p_item_group_id;

     l_item_group_rec    Item_group_csr%ROWTYPE;
     l_dummy              VARCHAR2(1);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Remove_Item_group_Pvt;

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

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'Begin of Remove_Item_group');
  END IF;


  -- Validate Item Group record.
  OPEN Item_group_csr(p_item_group_rec.item_group_id);
  FETCH Item_group_csr INTO l_item_group_rec;
  IF (Item_group_csr%NOTFOUND) THEN
      CLOSE Item_group_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_INVALID');
      FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Item Group does not exist');
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check Object version number.
  IF (l_item_group_rec.object_version_number <> p_item_group_rec.object_version_number) THEN
      CLOSE Item_group_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check if this item group has any positions associated.
  OPEN ahl_relationships_csr(p_item_group_rec.item_group_id);
  FETCH ahl_relationships_csr INTO l_dummy;
  IF (ahl_relationships_csr%FOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_POSN_EXISTS');
      FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Positions exist for this item group');
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  CLOSE ahl_relationships_csr;

  -- Check if this item group has any composition associated.
  OPEN ahl_item_comp_csr(p_item_group_rec.item_group_id);
  FETCH ahl_item_comp_csr INTO l_dummy;
  IF (ahl_item_comp_csr%FOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_COMP_EXISTS');
      FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Positions exist for this item group');
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  CLOSE ahl_item_comp_csr;


-- Coded for 11.5.10

 IF l_item_group_rec.status_code ='APPROVAL_PENDING'
 THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_APPR_PEND');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;


 IF l_item_group_rec.status_code ='REMOVED'
 THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_REMOVED');
      FND_MSG_PUB.ADD;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;


 IF l_item_group_rec.status_code IN ('DRAFT' ,'APPROVAL_REJECTED')
 THEN

 IF (l_item_group_rec.status_code = 'DRAFT' and nvl(l_item_group_rec.source_item_group_id, 0) > 0)
 THEN
        UPDATE  ahl_mc_relationships
        SET     temp_item_group_id = null
        WHERE   item_group_id = p_item_group_rec.item_group_id;
 END IF;

  -- Delete item associations.
/*      AHL_ITEM_ASSOCIATIONS_PKG.DELETE_ROW(
          X_ITEM_ASSOCIATION_ID =>      p_item_group_rec.item_group_id
                );

*/

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'Deleting Item Group');
  END IF;

  DELETE AHL_ITEM_ASSOCIATIONS_TL
  WHERE item_association_id IN ( SELECT item_association_id
                                 FROM ahl_item_associations_b
                                 WHERE item_group_id = p_item_group_rec.item_group_id );

  DELETE AHL_ITEM_ASSOCIATIONS_B
  WHERE item_group_id = p_item_group_rec.item_group_id;

  -- Delete ahl_item_groups
  AHL_ITEM_GROUPS_PKG.DELETE_ROW(
        X_ITEM_GROUP_ID =>      p_item_group_rec.item_group_id
        );

  ELSIF l_item_group_rec.status_code ='COMPLETE'
  THEN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'Updating Item Group to Removed');
  END IF;

  Update Ahl_Item_groups_b
    set  status_code ='REMOVED',
         object_version_number = object_version_number +1
   Where item_group_id = p_item_group_rec.item_group_id;

  --Update Ahl_item_associations_b
  --  set INTERCHANGE_TYPE_CODE = 'REMOVED',
  --       object_version_number = object_version_number +1
  -- Where item_group_id = p_item_group_rec.item_group_id;

  END IF;

  CLOSE Item_group_csr;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'End of Remove_Item_group');
  END IF;



EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Remove_Item_group_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'Error in Remove_Item_group');
  END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Remove_Item_group_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'Unexpected error in Remove_Item_group');
  END IF;


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Remove_Item_group_pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Remove_Item_Group',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', 'Unknown error in Remove_Item_group');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Remove_Item_group', SQLERRM);
  END IF;


END  Remove_Item_group;

-- Start of Comments --
--  Procedure name    : Initiate_Itemgroup_Appr
--  Type        : Private
--  Function    : Intiates Approval Process for Item groups
--
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--      Source_Item_Group_id            Required.
--      Object_version_number    Required.
--      Approval type            Required.
--
--  Enhancement 115.10
-- End of Comments --
PROCEDURE Initiate_Itemgroup_Appr (
    p_api_version            IN         NUMBER,
    p_init_msg_list          IN         VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN         VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default                IN         VARCHAR2  := FND_API.G_FALSE,
    p_module_type            IN         VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_source_item_group_id   IN         NUMBER,
    p_object_version_number  IN         NUMBER,
    p_approval_type         IN         VARCHAR2
)
 IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Initiate_Itemgroup_Appr';
  l_api_version CONSTANT NUMBER       := 1.0;

 l_counter    NUMBER:=0;
 l_object           VARCHAR2(30):='IGWF';
 l_approval_type    VARCHAR2(100):='CONCEPT';
 l_active           VARCHAR2(50) := 'N';
 l_process_name     VARCHAR2(50);
 l_item_type        VARCHAR2(50);
 l_return_status    VARCHAR2(50);
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(2000);
 l_activity_id      NUMBER:=p_source_item_group_id;
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_object_Version_number  NUMBER:=nvl(p_object_Version_number,0);

 l_upd_status    VARCHAR2(50);
 l_rev_status    VARCHAR2(50);



 CURSOR get_Itemgroup_Det(c_itemgroup_id NUMBER)
 is
 Select Name,
        Status_code,
        Object_version_number,
        source_item_group_id
 From   ahl_item_groups_vl
 Where  item_group_id = c_itemgroup_id;

 CURSOR validate_item_group(c_itemgroup_id NUMBER)
 is
 Select 'x' from dual
                Where exists ( select item_association_id from ahl_item_associations_vl
                        Where Item_Group_id = c_itemgroup_id  and
                        INTERCHANGE_TYPE_CODE in ('1-WAY INTERCHANGEABLE','2-WAY INTERCHANGEABLE') );

CURSOR validate_item_group_positions(c_itemgroup_id NUMBER)
is
select 'x'
from ahl_mc_relationships a, ahl_mc_relationships b
where b.RELATIONSHIP_ID = a.PARENT_RELATIONSHIP_ID
and   a.ITEM_GROUP_ID = c_itemgroup_id
and exists
        ( select 'x'
          from ahl_item_associations_b
          where item_group_id = c_itemgroup_id
          and quantity > 1 );


CURSOR Item_group_name(p_name VARCHAR2) IS
     select     'x'
     from       ahl_item_groups_b
     where      name = p_name and
                p_source_item_group_id <> item_group_id;


 l_itemgroup_rec   get_Itemgroup_Det%rowtype;


 l_msg         VARCHAR2(30);
 l_dummy  VARCHAR2(1);

l_appr_status           VARCHAR2(30) :='APPROVED';
l_fork_or_merge         NUMBER;


BEGIN
       SAVEPOINT  Initiate_Itemgroup_Appr;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Begin Initiate_Itemgroup_Appr');
  END IF;




-- Start work Flow Process
        ahl_utility_pvt.get_wf_process_name(
                                    p_object     =>l_object,
                                    x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);

        IF p_object_Version_number is null or p_object_Version_number=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJ_VERSION_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_source_item_group_id is null or p_source_item_group_id = FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJECT_ID_NULL');
                FND_MSG_PUB.ADD;
        ELSE
                OPEN get_Itemgroup_Det(p_source_item_group_id);
                FETCH get_Itemgroup_Det INTO l_itemgroup_rec;
                CLOSE get_Itemgroup_Det;

                IF l_itemgroup_rec.source_item_group_id IS NOT NULL
                   AND Fork_Or_Merge(p_source_item_group_id) = 0
                THEN
                        OPEN Item_group_name(l_itemgroup_rec.name);
                        FETCH Item_group_name INTO l_dummy;
                        IF Item_group_name%FOUND
                        THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_MC_IG_MOD_NAME');
                                FND_MSG_PUB.ADD;
                                CLOSE Item_group_name;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        CLOSE Item_group_name;
                END IF;


                IF p_approval_type = 'APPROVE'
                THEN
                        IF l_itemgroup_rec.status_code='DRAFT' or
                           l_itemgroup_rec.status_code='APPROVAL_REJECTED'
                        THEN
                                l_upd_status := 'APPROVAL_PENDING';
                                l_fork_or_merge := Fork_Or_Merge(p_source_item_group_id);

                                IF (l_fork_or_merge = 0)
                                THEN
                                        Validate_Item_Group_Name(l_itemgroup_rec.name, p_source_item_group_id, null);
                                ELSE
                                        Validate_Item_Group_Name(l_itemgroup_rec.name, p_source_item_group_id, l_itemgroup_rec.source_item_group_id);
                                END IF;

                        ELSE
                                FND_MESSAGE.SET_NAME('AHL','AHL_MC_IG_STAT_NOT_DRFT');
                                FND_MESSAGE.set_token('IG',l_itemgroup_rec.name,false);
                                FND_MSG_PUB.ADD;
                        END IF;
                ELSE
                        FND_MESSAGE.SET_NAME('AHL','AHL_APPR_TYPE_CODE_MISSING');
                        FND_MSG_PUB.ADD;
                END IF;

                OPEN validate_item_group(p_source_item_group_id);
                FETCH validate_item_group INTO l_dummy;
                IF validate_item_group%NOTFOUND THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_MC_IG_INTERCHANGE_INAVLID');
                        FND_MSG_PUB.ADD;
                END IF;
                CLOSE validate_item_group;

                OPEN validate_item_group_positions(p_source_item_group_id);
                FETCH validate_item_group_positions INTO l_dummy;
                IF validate_item_group_positions%FOUND THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_MC_PAR_QTY_INV');
                        FND_MESSAGE.set_token('POSREF','');
                        FND_MSG_PUB.ADD;
                END IF;
                CLOSE validate_item_group_positions;



        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;


IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'l_active flag is yes');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Updating Item group');
END IF;

               Update  AHL_ITEM_GROUPS_B
               Set STATUS_CODE=l_upd_status,
               OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
               Where ITEM_GROUP_ID = p_source_item_group_id
               and OBJECT_VERSION_NUMBER=p_object_Version_number;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
               END IF;

        IF  l_ACTIVE='Y'
        THEN


IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Calling ahl_generic_aprv_pvt.start_wf_process');
END IF;

                        AHL_GENERIC_APRV_PVT.START_WF_PROCESS(
                                     P_OBJECT                =>l_object,
                                     P_ACTIVITY_ID           =>l_activity_id,
                                     P_APPROVAL_TYPE         =>'CONCEPT',
                                     P_OBJECT_VERSION_NUMBER =>l_object_version_number+1,
                                     P_ORIG_STATUS_CODE      =>'ACTIVE',
                                     P_NEW_STATUS_CODE       =>'APPROVED',
                                     P_REJECT_STATUS_CODE    =>'REJECTED',
                                     P_REQUESTER_USERID      =>fnd_global.user_id,
                                     P_NOTES_FROM_REQUESTER  =>NULL,
                                     P_WORKFLOWPROCESS       =>'AHL_GEN_APPROVAL',
                                     P_ITEM_TYPE             =>'AHLGAPP');
         ELSE

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Calling ahl_mc_itemgroup_pvt.Approve_ItemGroups');
END IF;

                       AHL_MC_ITEMGROUP_PVT.Approve_ItemGroups
                         (
                         p_api_version               =>l_api_version,
                 --        p_init_msg_list             =>l_init_msg_list,
                 --        p_commit                    =>l_commit,
                 --        p_validation_level          =>NULL ,
                 --        p_default                   =>NULL ,
                        p_module_type               =>NULL,
                         x_return_status             =>l_return_status,
                         x_msg_count                 =>l_msg_count ,
                         x_msg_data                  =>l_msg_data  ,
                         p_appr_status               =>l_appr_status,
                         p_ItemGroups_id                  =>p_source_item_group_id,
                         p_object_version_number     =>p_object_Version_number+1
                         );
         END IF ;

 l_msg_count := FND_MSG_PUB.count_msg;

 IF l_msg_count > 0
  THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
 END IF;


  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'End of Initiate_Itemgroup_Appr');
END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Initiate_Itemgroup_Appr;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Error in Initiate_Itemgroup_Appr');
END IF;



 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Initiate_Itemgroup_Appr;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Unexpected Error in Initiate_Itemgroup_Appr');
END IF;


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Initiate_Itemgroup_Appr;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Initiate_Itemgroup_Appr',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', 'Unknown Error in Initiate_Itemgroup_Appr');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Initiate_Itemgroup_Appr', SQLERRM);
END IF;

END  Initiate_Itemgroup_Appr;


-- Start of Comments --
--  Procedure name    : Create_ItemGroup_Revision
--  Type        : Private
--  Function    : To  create a New Revision of Item group
--
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required

--      Source_Item_Group_id            Required.
--      Object_version_number    Required.
--  Enhancement 115.10
--
-- End of Comments --

PROCEDURE Create_ItemGroup_Revision (
    p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN         VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_DEFAULT               IN         VARCHAR2  := FND_API.G_FALSE,
    P_MODULE_TYPE           IN         VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_source_ItemGroup_id   IN         NUMBER,
    p_object_version_number IN         NUMBER,
    x_ItemGroup_id          OUT NOCOPY NUMBER
) AS

 cursor get_itemgroup_det(c_itemgroup_id in Number)
 Is
 Select
        Name,
        Status_Code,
        Type_Code,
        Description,
        object_version_number   ,
         attribute_category     ,
         attribute1             ,
         attribute2             ,
         attribute3             ,
         attribute4             ,
         attribute5             ,
         attribute6             ,
         attribute7             ,
         attribute8             ,
         attribute9             ,
         attribute10            ,
         attribute11            ,
         attribute12            ,
         attribute13            ,
         attribute14            ,
         attribute15
 from   ahl_item_groups_vl
 Where Item_Group_id = c_itemgroup_id;

 l_itemgroups_det  get_itemgroup_det%rowtype;

  cursor get_itemgroup_assos_det(c_itemgroup_id in Number)
  Is
        Select
        item_association_id            ,
        object_version_number          ,
        item_group_id                  ,
        inventory_item_id              ,
        inventory_org_id               ,
        priority                       ,
        uom_code                       ,
        quantity                       ,
        revision                       ,
        interchange_type_code          ,
        interchange_reason             ,
        source_item_association_id,
        attribute_category             ,
        attribute1                     ,
        attribute2                     ,
        attribute3                     ,
        attribute4                     ,
        attribute5                     ,
        attribute6                     ,
        attribute7                     ,
        attribute8                     ,
        attribute9                     ,
        attribute10                    ,
        attribute11                    ,
        attribute12                    ,
        attribute13                    ,
        attribute14                    ,
        attribute15
        from ahl_item_associations_vl
        where item_group_id = c_itemgroup_id;


 cursor get_revision_info(c_itemgroup_id in Number)
 is
 Select 'x'
 from   ahl_item_groups_vl
 where  source_item_group_id = c_itemgroup_id and
        status_code <> 'COMPLETE';

        l_dummy VARCHAR2(1);
        l_msg_count Number;
        l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
        l_itemgroup_det   get_itemgroup_det%rowtype;
        l_item_group_id Number;
        l_last_update_login NUMBER;
        l_last_updated_by   NUMBER;
        l_rowid              VARCHAR2(30);
        l_item_association_id NUMBER;
        l_created_by NUMBER;

-- TAMAL -- IG Amendments --
CURSOR get_mc_posisions (c_item_group_id in number)
IS
SELECT  relationship_id, object_version_number
FROM    ahl_mc_relationships
WHERE   item_group_id = c_item_group_id;
-- TAMAL -- IG Amendments --

BEGIN


       SAVEPOINT  Create_ItemGroup_Revision;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'Begin of Create_ItemGroup_Revision');
END IF;



 OPEN get_itemgroup_det(p_source_ItemGroup_id);
 Fetch get_itemgroup_det into l_itemgroup_det;
 IF get_itemgroup_det%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJECT_ID_NULL');
        FND_MSG_PUB.ADD;
 END IF;
 close get_itemgroup_det;


 IF l_itemgroup_det.Status_Code <> 'COMPLETE'
 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_MC_IG_STAT_NOT_COMP');
        FND_MESSAGE.Set_Token('IG',l_itemgroup_det.name);
        FND_MSG_PUB.ADD;
 END IF;


 IF l_itemgroup_det.object_version_number <> p_object_version_number
 THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD');
        FND_MSG_PUB.ADD;
 END IF;


 OPEN get_revision_info(p_source_ItemGroup_id);
 FETCH get_revision_info INTO l_dummy;
 IF get_revision_info%FOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_MC_IG_REVISION_EXIST');
        FND_MSG_PUB.ADD;
 END IF;
 CLOSE get_revision_info;



  l_msg_count := FND_MSG_PUB.count_msg;

  IF l_msg_count > 0
   THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Sequence Number for the New Revision.

Select AHL_ITEM_GROUPS_B_S.nextval
into l_item_group_id
from dual;

 l_last_updated_by := to_number(fnd_global.USER_ID);
 l_last_update_login := to_number(fnd_global.LOGIN_ID);
 l_created_by := to_number(fnd_global.user_id);


-- Inserting a new Revision in the Header Table  Using table Handler

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'Calling Table handler');
END IF;


ahl_item_groups_pkg.insert_row(
        x_rowid                 =>      l_rowid,
        x_item_group_id         =>      l_item_group_id,
        x_type_code             =>      l_itemgroup_det.type_code,
        x_status_code           =>      'DRAFT',
        x_source_item_group_id  =>      p_source_ItemGroup_id,
        x_object_version_number =>      1,
        x_name                  =>      l_itemgroup_det.name,
        x_attribute_category    =>      l_itemgroup_det.attribute_category,
        x_attribute1            =>      l_itemgroup_det.attribute1,
        x_attribute2            =>      l_itemgroup_det.attribute2,
        x_attribute3            =>      l_itemgroup_det.attribute3,
        x_attribute4            =>      l_itemgroup_det.attribute4,
        x_attribute5            =>      l_itemgroup_det.attribute5,
        x_attribute6            =>      l_itemgroup_det.attribute6,
        x_attribute7            =>      l_itemgroup_det.attribute7,
        x_attribute8            =>      l_itemgroup_det.attribute8,
        x_attribute9            =>      l_itemgroup_det.attribute9,
        x_attribute10           =>      l_itemgroup_det.attribute10,
        x_attribute11           =>      l_itemgroup_det.attribute11,
        x_attribute12           =>      l_itemgroup_det.attribute12,
        x_attribute13           =>      l_itemgroup_det.attribute13,
        x_attribute14           =>      l_itemgroup_det.attribute14,
        x_attribute15           =>      l_itemgroup_det.attribute15,
        x_description           =>      l_itemgroup_det.description,
        x_creation_date         =>      sysdate,
        x_created_by            =>      l_created_by,
        x_last_update_date      =>      sysdate,
        x_last_updated_by       =>      l_last_updated_by,
        x_last_update_login     =>      l_last_update_login);


x_ItemGroup_id := l_item_group_id;

-- TAMAL -- IG Amendments --
FOR item_group_rec IN get_mc_posisions(p_source_itemgroup_id)
LOOP
        UPDATE  ahl_mc_relationships
        SET     temp_item_group_id = x_itemgroup_id,
                object_version_number = item_group_rec.object_version_number,
                last_update_date = sysdate,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login
        WHERE   relationship_id = item_group_rec.relationship_id and
                trunc(nvl(active_end_date, sysdate + 1)) > trunc(sysdate);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        THEN
                FND_LOG.STRING
                (
                        FND_LOG.LEVEL_PROCEDURE,
                        'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision',
                        'Updated MC position '||item_group_rec.relationship_id||' with temp_item_group_id '||x_itemgroup_id
                );
        END IF;
END LOOP;
-- TAMAL -- IG Amendments --

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'Loop to create Item Association');
END IF;

FOR I IN get_itemgroup_assos_det(p_source_ItemGroup_id)
LOOP

     --Gets the sequence Number
    SELECT AHL_ITEM_ASSOCIATIONS_B_S.nextval INTO
           l_item_association_id from DUAL;


ahl_item_associations_pkg.insert_row
(
        x_rowid                         =>      l_rowid,
        x_item_association_id           =>      l_item_association_id,
        x_source_item_association_id    =>      I.source_item_association_id,
        x_object_version_number         =>      1,
        x_item_group_id                 =>      l_item_group_id,
        x_inventory_item_id             =>      I.inventory_item_id,
        x_inventory_org_id              =>      I.INVENTORY_ORG_ID   ,
        x_priority                      =>      I.PRIORITY           ,
        x_uom_code                      =>      I.UOM_CODE           ,
        x_quantity                      =>      I.QUANTITY           ,
        x_revision                      =>      I.REVISION           ,
        x_interchange_type_code         =>      I.INTERCHANGE_TYPE_CODE ,
        x_item_type_code                =>      null,
        x_attribute_category            =>      I.ATTRIBUTE_CATEGORY,
        x_attribute1                    =>      i.attribute1,
        x_attribute2                    =>      i.attribute2,
        x_attribute3                    =>      i.attribute3,
        x_attribute4                    =>      i.attribute4,
        x_attribute5                    =>      i.attribute5,
        x_attribute6                    =>      i.attribute6,
        x_attribute7                    =>      i.attribute7,
        x_attribute8                    =>      i.attribute8,
        x_attribute9                    =>      i.attribute9,
        x_attribute10                   =>      i.attribute10,
        x_attribute11                   =>      i.attribute11,
        x_attribute12                   =>      i.attribute12,
        x_attribute13                   =>      i.attribute13,
        x_attribute14                   =>      i.attribute14,
        x_attribute15                   =>      i.attribute15,
        x_interchange_reason            =>      I.INTERCHANGE_REASON,
        x_creation_date                 =>      sysdate,
        x_created_by                    =>      l_created_by,
        x_last_update_date              =>      sysdate,
        x_last_updated_by               =>      l_last_updated_by,
        x_last_update_login             =>      l_last_update_login
  );
END LOOP;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'End of Loop');
END IF;

   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT WORK;
   END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'End of Create_ItemGroup_Revision');
 END IF;



EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Create_ItemGroup_Revision;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'Error in Create_ItemGroup_Revision');
 END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Create_ItemGroup_Revision;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'Unecpected Error in Create_ItemGroup_Revision');
 END IF;


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Create_ItemGroup_Revision;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_ItemGroup_Revision',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision', 'Unknown Error in Create_ItemGroup_Revision');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Create_ItemGroup_Revision',SQLERRM );

 END IF;



END Create_ItemGroup_Revision;


 PROCEDURE update_histroy (
  p_ItemGroups_id             IN          NUMBER,
  p_action                    IN          VARCHAR2
)IS
--
      cursor get_item_assos_det_csr(c_itemgroup_id in number)
      is
      Select
      item_association_id         ,
      object_version_number       ,
      last_update_date            ,
      last_updated_by             ,
      creation_date               ,
      created_by                  ,
      last_update_login           ,
      item_group_id               ,
      inventory_item_id           ,
      inventory_org_id            ,
      priority                    ,
      uom_code                    ,
      quantity                    ,
      revision                    ,
      interchange_type_code       ,
      interchange_reason          ,
      item_type_code              ,
      source_item_association_id,
      attribute_category          ,
      attribute1                  ,
      attribute2                  ,
      attribute3                  ,
      attribute4                  ,
      attribute5                  ,
      attribute6                  ,
      attribute7                  ,
      attribute8                  ,
      attribute9                  ,
      attribute10                 ,
      attribute11                 ,
      attribute12                 ,
      attribute13                 ,
      attribute14                 ,
      attribute15
      from ahl_item_associations_vl
      where item_group_id = c_itemgroup_id;
--

  l_version_number  NUMBER;
  l_item_associations_h_id NUMBER;
  l_item_group_h_id       NUMBER;
  l_rowid   VARCHAR2(30);
  l_item_assos_det get_item_assos_det_csr%ROWTYPE;

--
 BEGIN

 -- To get the maximum of version number
        Select NVl(max(VERSION_NUMBER),0)
        into   l_version_number
        from   ahl_item_groups_b_h
        where ITEM_GROUP_ID  = p_ItemGroups_id;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Inserting into History Tables');
  END IF;


                Select ahl_item_associations_b_h_s.nextval
                into l_item_associations_h_id from dual;

                INSERT INTO ahl_item_groups_b_h
                (item_group_h_id        ,
                item_group_id          ,
                object_version_number,
                creation_date          ,
                created_by             ,
                last_update_date       ,
                last_updated_by        ,
                name                   ,
                type_code              ,
                status_code            ,
                version_number         ,
                transaction_date       ,
                action                 ,
                source_item_group_id   ,
                last_update_login      ,
                attribute_category     ,
                attribute1             ,
                attribute2             ,
                attribute3             ,
                attribute4             ,
                attribute5             ,
                attribute6             ,
                attribute7             ,
                attribute8             ,
                attribute9             ,
                attribute10            ,
                attribute11            ,
                attribute12            ,
                attribute13            ,
                attribute14            ,
                attribute15            )

                SELECT

                AHL_ITEM_GROUPS_B_H_S.NEXTVAL        ,
                item_group_id          ,
                object_version_number,
                creation_date          ,
                created_by             ,
                last_update_date       ,
                last_updated_by        ,
                name                   ,
                type_code              ,
                status_code            ,
                l_version_number+1         ,
                sysdate      ,
                p_action                 ,
                source_item_group_id   ,
                last_update_login      ,
                attribute_category     ,
                attribute1             ,
                attribute2             ,
                attribute3             ,
                attribute4             ,
                attribute5             ,
                attribute6             ,
                attribute7             ,
                attribute8             ,
                attribute9             ,
                attribute10            ,
                attribute11            ,
                attribute12            ,
                attribute13            ,
                attribute14            ,
                attribute15
                FROM ahl_item_groups_b
                WHERE item_group_id = p_ItemGroups_id;


                INSERT INTO ahl_item_groups_tl_h
                (item_group_h_id  ,
                language          ,
                last_update_date  ,
                last_updated_by   ,
                source_lang       ,
                creation_date     ,
                created_by        ,
                description       ,
                last_update_login )
                SELECT
                AHL_ITEM_GROUPS_B_H_S.CURRVAL ,
                language          ,
                last_update_date  ,
                last_updated_by   ,
                source_lang       ,
                creation_date     ,
                created_by        ,
                description       ,
                last_update_login
                FROM ahl_item_groups_tl
                WHERE item_group_id = p_ItemGroups_id;



  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Inserting Item Association into history table Start of Loop');
  END IF;


                FOR l_item_assos_det IN get_item_assos_det_csr(p_ItemGroups_id) LOOP

                Select ahl_item_associations_b_h_s.nextval
                into l_item_associations_h_id from dual;

                AHL_ITEM_ASSOCIATIONS_H_PKG.INSERT_ROW(
                        X_ROWID                         =>      l_rowid,
                        X_ITEM_ASSOCIATION_H_ID         =>      l_item_associations_h_id ,
                        X_ITEM_ASSOCIATION_ID           =>      l_item_assos_det.ITEM_ASSOCIATION_ID  ,
                        X_ITEM_GROUP_ID                 =>      l_item_assos_det.ITEM_GROUP_ID                ,
                        X_OBJECT_VERSION_NUMBER         =>      l_item_assos_det.OBJECT_VERSION_NUMBER        ,
                        X_INVENTORY_ITEM_ID             =>      l_item_assos_det.INVENTORY_ITEM_ID            ,
                        X_INVENTORY_ORG_ID              =>      l_item_assos_det.INVENTORY_ORG_ID             ,
                        X_PRIORITY                      =>      l_item_assos_det.PRIORITY                     ,
                        X_TRANSACTION_DATE              =>      sysdate,
                        X_ACTION                        =>      p_action,
                        X_SOURCE_ITEM_ASSOCIATION_ID    =>      l_item_assos_det.SOURCE_ITEM_ASSOCIATION_ID,
                        X_VERSION_NUMBER                =>      l_version_number              ,
                        X_UOM_CODE                      =>      l_item_assos_det.UOM_CODE                     ,
                        X_QUANTITY                      =>      l_item_assos_det.QUANTITY                     ,
                        X_REVISION                      =>      l_item_assos_det.REVISION                     ,
                        X_INTERCHANGE_TYPE_CODE         =>      l_item_assos_det.INTERCHANGE_TYPE_CODE        ,
                        X_ATTRIBUTE_CATEGORY            =>      l_item_assos_det.ATTRIBUTE_CATEGORY           ,
                        X_ATTRIBUTE1                    =>      l_item_assos_det.ATTRIBUTE1                   ,
                        X_ATTRIBUTE2                    =>      l_item_assos_det.ATTRIBUTE2                   ,
                        X_ATTRIBUTE3                    =>      l_item_assos_det.ATTRIBUTE3                   ,
                        X_ATTRIBUTE4                    =>      l_item_assos_det.ATTRIBUTE4                   ,
                        X_ATTRIBUTE5                    =>      l_item_assos_det.ATTRIBUTE5                   ,
                        X_ATTRIBUTE6                    =>      l_item_assos_det.ATTRIBUTE6                   ,
                        X_ATTRIBUTE7                    =>      l_item_assos_det.ATTRIBUTE7                   ,
                        X_ATTRIBUTE8                    =>      l_item_assos_det.ATTRIBUTE8                   ,
                        X_ATTRIBUTE9                    =>      l_item_assos_det.ATTRIBUTE9                   ,
                        X_ATTRIBUTE10                   =>      l_item_assos_det.ATTRIBUTE10                  ,
                        X_ATTRIBUTE11                   =>      l_item_assos_det.ATTRIBUTE11                  ,
                        X_ATTRIBUTE12                   =>      l_item_assos_det.ATTRIBUTE12                  ,
                        X_ATTRIBUTE13                   =>      l_item_assos_det.ATTRIBUTE13                  ,
                        X_ATTRIBUTE14                   =>      l_item_assos_det.ATTRIBUTE14                  ,
                        X_ATTRIBUTE15                   =>      l_item_assos_det.ATTRIBUTE15                  ,
                        X_INTERCHANGE_REASON            =>      l_item_assos_det.INTERCHANGE_REASON           ,
                        X_CREATION_DATE                 =>      l_item_assos_det.CREATION_DATE                ,
                        X_CREATED_BY                    =>      l_item_assos_det.CREATED_BY                   ,
                        X_LAST_UPDATE_DATE              =>      l_item_assos_det.LAST_UPDATE_DATE             ,
                        X_LAST_UPDATED_BY               =>      l_item_assos_det.LAST_UPDATED_BY              ,
                        X_LAST_UPDATE_LOGIN             =>      l_item_assos_det.LAST_UPDATE_LOGIN            );

                END LOOP;

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                   THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'End of Loop');
        END IF;


END update_histroy;


-- Start of Comments --
--  Procedure name    : Approve_ItemGroups
--  Type        : Private
--  Function    : To  Approve Item group will be called by approval package
--  Version     : Added for 115.10
--
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required

--      P_appr_status            Required.
--      Item_Group_id            Required.
--      Object_version_number    Required.
--
--
-- End of Comments --

PROCEDURE Approve_ItemGroups (
 p_api_version               IN         NUMBER,
 p_init_msg_list             IN         VARCHAR2  := FND_API.G_FALSE,
 p_commit                    IN         VARCHAR2  := FND_API.G_FALSE,
 p_validation_level          IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 P_DEFAULT                   IN         VARCHAR2  := FND_API.G_FALSE,
 P_MODULE_TYPE               IN         VARCHAR2,
 x_return_status             OUT NOCOPY  VARCHAR2,
 x_msg_count                 OUT NOCOPY  NUMBER,
 x_msg_data                  OUT NOCOPY  VARCHAR2,
 p_appr_status               IN          VARCHAR2,
 p_ItemGroups_id             IN          NUMBER,
 p_object_version_number     IN          NUMBER)

 AS

  cursor get_itemgroup_det(c_itemgroup_id in Number)
   Is  Select
         item_group_id,
         Name,
         Status_Code,
         Type_Code,
         Source_Item_group_id,
         object_version_number,
         Description,
         attribute_category     ,
         attribute1             ,
         attribute2             ,
         attribute3             ,
         attribute4             ,
         attribute5             ,
         attribute6             ,
         attribute7             ,
         attribute8             ,
         attribute9             ,
         attribute10            ,
         attribute11            ,
         attribute12            ,
         attribute13            ,
         attribute14            ,
         attribute15
  from   ahl_item_groups_vl
 Where Item_Group_id = c_itemgroup_id;

 l_itemgroup_det get_itemgroup_det%rowType;


   cursor get_itemgroup_assos_det(c_itemgroup_id in Number)
   Is
        Select
        item_association_id            ,
        source_item_association_id     ,
        object_version_number          ,
        item_group_id                  ,
        inventory_item_id              ,
        inventory_org_id               ,
        priority                       ,
        uom_code                       ,
        quantity                       ,
        revision                       ,
        interchange_type_code          ,
        interchange_reason             ,
        source_item_association_id,
        attribute_category             ,
        attribute1                     ,
        attribute2                     ,
        attribute3                     ,
        attribute4                     ,
        attribute5                     ,
        attribute6                     ,
        attribute7                     ,
        attribute8                     ,
        attribute9                     ,
        attribute10                    ,
        attribute11                    ,
        attribute12                    ,
        attribute13                    ,
        attribute14                    ,
        attribute15
        from ahl_item_associations_vl
        where item_group_id = c_itemgroup_id;


 l_status VARCHAR2(30);
 l_msg_count Number;
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_rowid   VARCHAR2(30);
 l_action varchar2(2);

-- SATHAPLI::Bug# 4328454 fix
-- The declared variables are not being used now as the call to
-- AHL_UTIL_UC_PKG.Invalidate_Instance will not be made in this procedure.
-- The validation of Item group updates for active UCs is now being done
-- in procedure Modify_Item_group. Refer to old version of the package
-- for details.

 l_fork_or_merge        NUMBER;

 BEGIN

       SAVEPOINT  Approve_ItemGroups;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Begin of Approve_ItemGroups');
 END IF;



       OPEN get_itemgroup_det(p_ItemGroups_id);
       FETCH get_itemgroup_det INTO l_itemgroup_det;
        IF get_itemgroup_det%NOTFOUND
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJECT_ID_NULL');
                FND_MSG_PUB.ADD;
        END IF;
       CLOSE get_itemgroup_det;

       IF l_itemgroup_det.object_version_number <> p_object_version_number
       THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD');
        FND_MSG_PUB.ADD;
       END IF;


  l_msg_count := FND_MSG_PUB.count_msg;

  IF l_msg_count > 0
   THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
  END IF;


     IF p_appr_status='APPROVED'
     THEN
       l_status:='COMPLETE';
     ELSE
       l_status:='APPROVAL_REJECTED';
     END IF;


     IF l_status = 'COMPLETE'
     THEN
                -- Insert record into histroy table.


         IF l_itemgroup_det.Source_Item_group_id IS NULL THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Source Item group id is null');
                END IF;

             update  ahl_item_groups_b
                set status_code=l_status,
                    object_version_number = object_version_number+1,
                    last_update_date = sysdate,
                    last_updated_by = to_number(fnd_global.user_id),
                    last_update_login = to_number(fnd_global.login_id)
              where item_group_id=l_itemgroup_det.item_group_id
                and object_version_number = l_itemgroup_det.object_version_number;

             l_action :='C';

                update_histroy (
                  p_ItemGroups_id      => l_itemgroup_det.item_group_id,
                  p_action             => l_action
                        );

         ELSE


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                   THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Source Item Group id is not null');
        END IF;

l_fork_or_merge := Fork_Or_Merge(l_itemgroup_det.item_group_id);
IF (l_fork_or_merge = 0)
THEN

-- SATHAPLI::Bug# 4328454 fix
-- Call to AHL_UTIL_UC_PKG.Invalidate_Instance will not be made in this
-- procedure.The validation of Item group updates for active UCs is now
-- being done in procedure Modify_Item_group. Refer to old version of
-- the package for details.

                -- Fork the IG to a new one, maintain the earlier complete version

                -- Update the IG with status as complete
                update  ahl_item_groups_b
                set     status_code = 'COMPLETE',
                        object_version_number = object_version_number + 1,
                        source_item_group_id = NULL,
                        last_update_date = sysdate,
                        last_updated_by = to_number(fnd_global.user_id),
                        last_update_login = to_number(fnd_global.login_id)
                where   item_group_id = l_itemgroup_det.item_group_id and
                        object_version_number = l_itemgroup_det.object_version_number;

                -- For the positions with temp_item_group_id = null, such positions are not associated to the forked
                -- copy of the IG, hence no change to the positions

                -- For the positions with temp_item_group_id <> null, such positions are associated to the forked
                -- copy of the IG, hence update the item_group_id = temp_item_group_id's value and set latter = null
                update  ahl_mc_relationships
                set     item_group_id = l_itemgroup_det.item_group_id,
                        temp_item_group_id = null
                where   item_group_id = l_itemgroup_det.source_item_group_id and
                        temp_item_group_id is not null and
                        trunc(nvl(active_end_date, sysdate+1)) > trunc(sysdate);

                -- Update history table
                update_histroy
                (
                        p_itemgroups_id => l_itemgroup_det.item_group_id,
                        p_action => 'U'
                );

-- SATHAPLI::Bug# 4328454 fix
-- Code pertaining to call to AHL_UTIL_UC_PKG.Invalidate_Instance removed.
-- Refer to old version of the package for details.

ELSE
        -- Merge the IG with the previous complete version
        ahl_item_groups_pkg.update_row(
                 x_item_group_id                =>      l_itemgroup_det.Source_Item_group_id,
                 x_type_code                    =>      l_itemgroup_det.type_code,
                 x_status_code                  =>      'COMPLETE',
                 x_source_item_group_id         =>      null,
                 x_object_version_number        =>      l_itemgroup_det.object_version_number + 1,
                 x_name                         =>      l_itemgroup_det.name,
                 x_attribute_category           =>      l_itemgroup_det.attribute_category,
                 x_attribute1                   =>      l_itemgroup_det.attribute1,
                 x_attribute2                   =>      l_itemgroup_det.attribute2,
                 x_attribute3                   =>      l_itemgroup_det.attribute3,
                 x_attribute4                   =>      l_itemgroup_det.attribute4,
                 x_attribute5                   =>      l_itemgroup_det.attribute5,
                 x_attribute6                   =>      l_itemgroup_det.attribute6,
                 x_attribute7                   =>      l_itemgroup_det.attribute7,
                 x_attribute8                   =>      l_itemgroup_det.attribute8,
                 x_attribute9                   =>      l_itemgroup_det.attribute9,
                 x_attribute10                  =>      l_itemgroup_det.attribute10,
                 x_attribute11                  =>      l_itemgroup_det.attribute11,
                 x_attribute12                  =>      l_itemgroup_det.attribute12,
                 x_attribute13                  =>      l_itemgroup_det.attribute13,
                 x_attribute14                  =>      l_itemgroup_det.attribute14,
                 x_attribute15                  =>      l_itemgroup_det.attribute15,
                 x_description                  =>      l_itemgroup_det.description,
                 x_last_update_date             =>      sysdate,
                 x_last_updated_by              =>      fnd_global.user_id,
                 x_last_update_login            =>      fnd_global.login_id);

-- SATHAPLI::Bug# 4328454 fix
-- Call to AHL_UTIL_UC_PKG.Invalidate_Instance will not be made in this
-- procedure.The validation of Item group updates for active UCs is now
-- being done in procedure Modify_Item_group. Refer to old version of
-- the package for details.

                        Delete from ahl_item_associations_tl
                        where item_association_id in
                          ( Select item_association_id
                            from  ahl_item_associations_b
                            where item_group_id = l_itemgroup_det.Source_Item_group_id);

                        Delete from ahl_item_associations_b
                        where item_group_id = l_itemgroup_det.Source_Item_group_id;

                        -- The following is to associate the Temporary Item Group Part Numbers
                        -- to the Permant(Complete) Item Group.

                        update ahl_item_associations_b
                        set    item_group_id = l_itemgroup_det.Source_Item_group_id,
                               object_version_number = object_version_number+1
                        Where  item_group_id = l_itemgroup_det.item_group_id;

                        -- This is to update the Master Configuration Node which are associated
                        -- with 'Draft' Item Group.


                        update ahl_mc_relationships
                         set ITEM_GROUP_ID = l_itemgroup_det.Source_Item_group_id,
                             object_version_number = object_version_number+1
                        Where  item_group_id = l_itemgroup_det.item_group_id;

                        l_action :='U';


                        -- Updating the history tables.

                        update_histroy (
                          p_ItemGroups_id      => l_itemgroup_det.item_group_id,
                          p_action             => l_action
                                );

                        -- This is to delete the temporary version of Item group.


                        Delete from ahl_item_groups_tl
                        where item_group_id = l_itemgroup_det.item_group_id;

                        Delete from ahl_item_groups_b
                        where item_group_id = l_itemgroup_det.item_group_id;

-- SATHAPLI::Bug# 4328454 fix
-- Code pertaining to call to AHL_UTIL_UC_PKG.Invalidate_Instance removed.
-- Refer to old version of the package for details.

END IF; -- Fork_Or_Merge
  End if;





    ELSIF l_status = 'APPROVAL_REJECTED'  THEN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Approval Rejected');
 END IF;

        update  ahl_item_groups_b
                set status_code=l_status,
                    object_version_number = object_version_number+1
              where item_group_id=l_itemgroup_det.item_group_id
                and object_version_number = l_itemgroup_det.object_version_number;




   End if;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'End of Approve_ItemGroups');
 END IF;



 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Approve_ItemGroups;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Error in Approve_ItemGroups');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Approve_ItemGroups;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Unexpected Error in Approve_ItemGroups');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Approve_ItemGroups;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Approve_ItemGroups',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', 'Unknown Error in Approve_ItemGroups');
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_ItemGroups', SQLERRM);

  END IF;


 END Approve_ItemGroups;

PROCEDURE Modify_Position_Assos
(
        p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2  := FND_API.G_FALSE,
        p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
        p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type           IN              VARCHAR2,
        x_return_status         OUT     NOCOPY  VARCHAR2,
        x_msg_count             OUT     NOCOPY  NUMBER,
        x_msg_data              OUT     NOCOPY  VARCHAR2,
        p_item_group_id         IN              NUMBER,
        p_object_version_number IN              NUMBER,
        p_nodes_tbl             IN              AHL_MC_Node_PVT.Node_Tbl_Type
)
IS
        CURSOR get_itemgroup_details
        (
                p_item_group_id in number
        )
        IS
                SELECT object_version_number, source_item_group_id, status_code
                FROM ahl_item_groups_b
                WHERE item_group_id = p_item_group_id;

        CURSOR check_position_exists
        (
                p_relationship_id in number
        )
        IS
                SELECT 'x'
                FROM ahl_mc_relationships
                WHERE relationship_id = p_relationship_id;

        -- Define local variables
        l_api_name      CONSTANT        VARCHAR2(30)    := 'Create_Node';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);

        l_obj_ver_num                   NUMBER;
        l_source_id                     NUMBER;
        l_status                        VARCHAR2(30);
        l_junk                          VARCHAR2(1);

BEGIN

        -- Standard start of API savepoint
        SAVEPOINT Modify_Position_Assos_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.TO_BOOLEAN(p_init_msg_list)
        THEN
                FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- API body starts here
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
                fnd_log.string
                (
                        fnd_log.level_procedure,
                        'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
                        'At the start of PLSQL procedure'
                );
        END IF;

        -- Validate whether the IG exists, if yes, then validate that object_version_number has not been
        -- already bounced and status = 'DRAFT' and the IG is a draft copy
        OPEN get_itemgroup_details(p_item_group_id);
        FETCH get_itemgroup_details INTO l_obj_ver_num, l_source_id, l_status;
        IF (get_itemgroup_details%NOTFOUND)
        THEN
                CLOSE get_itemgroup_details;
                FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_DELETED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_obj_ver_num <> p_object_version_number)
        THEN
                CLOSE get_itemgroup_details;
                FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_status <> 'DRAFT' or nvl(l_source_id, 0) <= 0)
        THEN
                CLOSE get_itemgroup_details;
                FND_MESSAGE.Set_Name('AHL', 'AHL_MC_IG_NOUPDATE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE get_itemgroup_details;

        -- All above validations have passed
        IF (p_nodes_tbl.COUNT > 0)
        THEN
                -- For each node in the p_nodes_tbl, unassociate the itemgroup, assumption is that only the
                -- to-be-unassociated records are passed from the frontend
                FOR i IN p_nodes_tbl.FIRST..p_nodes_tbl.LAST
                LOOP
                        OPEN check_position_exists(p_nodes_tbl(i).relationship_id);
                        FETCH check_position_exists INTO l_junk;
                        -- Validate node exists, if yes, go ahead and unassociate the item group
                        IF (check_position_exists%NOTFOUND)
                        THEN
                                CLOSE check_position_exists;
                                FND_MESSAGE.Set_Name('AHL', 'AHL_MC_NODE_NOT_FOUND');
                                FND_MSG_PUB.ADD;
                        ELSIF (p_nodes_tbl(i).operation_flag = 'C')
                        THEN
                                UPDATE ahl_mc_relationships
                                SET temp_item_group_id = p_item_group_id
                                WHERE relationship_id = p_nodes_tbl(i).relationship_id;
                        ELSIF (p_nodes_tbl(i).operation_flag = 'D')
                        THEN
                                UPDATE ahl_mc_relationships
                                SET temp_item_group_id = null
                                WHERE relationship_id = p_nodes_tbl(i).relationship_id;
                        END IF;
                        CLOSE check_position_exists;
                END LOOP;

                -- Check Error Message stack.
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count > 0 THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
                fnd_log.string
                (
                        fnd_log.level_procedure,
                        'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
                        'At the end of PLSQL procedure'
                );
        END IF;
        -- API body ends here

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Standard check for p_commit
        IF FND_API.TO_BOOLEAN (p_commit)
        THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.count_and_get
        (
                p_count         => x_msg_count,
                p_data          => x_msg_data,
                p_encoded       => FND_API.G_FALSE
        );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                Rollback to Modify_Position_Assos_SP;
                FND_MSG_PUB.count_and_get
                (
                        p_count         => x_msg_count,
                        p_data          => x_msg_data,
                        p_encoded       => FND_API.G_FALSE
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Rollback to Modify_Position_Assos_SP;
                FND_MSG_PUB.count_and_get
                (
                        p_count         => x_msg_count,
                        p_data          => x_msg_data,
                        p_encoded       => FND_API.G_FALSE
                );

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Rollback to Modify_Position_Assos_SP;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                        (
                                p_pkg_name              => G_PKG_NAME,
                                p_procedure_name        => 'Modify_Position_Assos',
                                p_error_text            => SUBSTR(SQLERRM,1,240)
                        );
                END IF;
                FND_MSG_PUB.count_and_get
                (
                        p_count         => x_msg_count,
                        p_data          => x_msg_data,
                        p_encoded       => FND_API.G_FALSE
                );

END Modify_Position_Assos;

FUNCTION Fork_Or_Merge
(
        p_item_group_id in number
)
RETURN NUMBER
-- Return values:
--      -1 : Neither fork nor merge, for the case of a non-draft copy of the IG
--       0 : Fork the draft copy of the IG
--       1 : Merge the draft copy of the IG
IS

        CURSOR get_itemgroup_details
        (
                p_item_group_id in number
        )
        IS
                SELECT source_item_group_id, status_code
                FROM ahl_item_groups_b
                WHERE item_group_id = p_item_group_id;

        CURSOR check_fork
        (
                p_parent_ig_id in number
        )
        IS
                SELECT 'x'
                FROM    ahl_mc_relationships
                WHERE   temp_item_group_id is null and
                        item_group_id = p_parent_ig_id and
                        trunc(nvl(active_end_date, sysdate + 1)) > trunc(sysdate);

        l_source_id     NUMBER;
        l_status        VARCHAR2(30);
        l_junk          VARCHAR2(1);

BEGIN
        OPEN get_itemgroup_details(p_item_group_id);
        FETCH get_itemgroup_details INTO l_source_id, l_status;
        CLOSE get_itemgroup_details;

        -- For checking fork/merge, the IG should be a draft copy
        IF (nvl(l_source_id, 0) > 0 and (l_status = 'DRAFT' or l_status = 'APPROVAL_PENDING'))
        THEN
                OPEN check_fork(l_source_id);
                FETCH check_fork INTO l_junk;
                IF (check_fork%FOUND)
                THEN
                        -- IG is to be forked
                        CLOSE check_fork;
                        RETURN 0;
                ELSE
                        -- IG is to be merged
                        CLOSE check_fork;
                        RETURN 1;
                END IF;
        ELSE
                -- IG is not a draft copy
                RETURN -1;
        END IF;

END Fork_Or_Merge;

End AHL_MC_ITEMGROUP_PVT;

/
