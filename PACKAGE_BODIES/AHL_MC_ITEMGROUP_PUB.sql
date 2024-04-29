--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEMGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEMGROUP_PUB" AS
/* $Header: AHLPIGPB.pls 120.0.12010000.2 2010/01/20 21:02:07 jaramana ship $ */


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_MC_ITEMGROUP_PVT';



------------------------------
-- Declare Local Procedures --
------------------------------

PROCEDURE Convert_InTo_ID(p_x_item_assoc_rec  IN OUT NOCOPY AHL_MC_ItemGroup_Pvt.Item_association_rec_type);



-----------------------------------------
-- Define Procedures for Item Groups  --
-----------------------------------------

-- Start of Comments --
--  Procedure name    : PROCESS_ITEM_GROUP
--  Type        : Public
--  Function    : Creates Item Group for Master Configuration in ahl_item_groups_b and TL tables. Also creates item-group association in
--
--ahl_item_associations table.
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
--  Item Group Record :
--      Name or item_group_id           Required.
--      operation_flag                  only if record needs to be modified (M) or deleted.(D)
--  Item Associations Record :
--      Inventory_item_id/item_number  or organization_code/Organization_id
--                               Required, present and trackable in mtl_system_items_b.
--      priority                 Required.
--      Operation_code           Required to be 'C'.(Create)
--      INterchange_code         if present, must exist in fnd_lookups.
--      Item_type                if present, must exist in fnd_lookups.
--
-- End of Comments --


PROCEDURE PROCESS_ITEM_GROUP(p_api_version      IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             p_commit            IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             p_module_type       IN            VARCHAR2  := NULL,
                             x_return_status     OUT NOCOPY          VARCHAR2,
                             x_msg_count         OUT NOCOPY          NUMBER,
                             x_msg_data          OUT NOCOPY          VARCHAR2,
                             p_x_item_group_rec  IN OUT NOCOPY AHL_MC_ItemGroup_Pvt.Item_Group_Rec_Type,
                             p_x_items_tbl       IN OUT NOCOPY AHL_MC_ItemGroup_Pvt.Item_Association_Tbl_Type
                             ) IS


  l_api_name       CONSTANT VARCHAR2(30) := 'Process_Item_Group';
  l_api_version    CONSTANT NUMBER       := 1.0;


 -- For item_group_id.
  CURSOR ahl_item_group_csr(p_grp_name  IN  VARCHAR2) IS
     SELECT item_group_id,
            type_code
     FROM ahl_item_groups_b
     WHERE name = p_grp_name;

-- For item_group_id.
  CURSOR Item_grp_name_csr(p_item_grp_id  IN  VARCHAR2) IS
     SELECT name,
            type_code
     FROM ahl_item_groups_b
     WHERE item_group_id = p_item_grp_id;

  l_item_group_id   NUMBER;
  l_item_group_name AHL_ITEM_GROUPS_B.NAME%TYPE;
  l_type_code       AHL_ITEM_GROUPS_B.TYPE_CODE%TYPE;
  l_item_group_rec  AHL_MC_ItemGroup_Pvt.Item_Group_Rec_Type  DEFAULT p_X_item_group_rec;
  l_lookup_code     VARCHAR2(30);
  l_return_val      BOOLEAN;
  l_status          VARCHAR2(1);


BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Process_Item_group_Pub;

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
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Begin of process_item_group');
  END IF;

  IF l_item_group_rec.OPERATION_FLAG <> 'D' THEN
    IF l_item_group_rec.type_code IS NOT NULL THEN
        IF NOT AHL_UTIL_MC_PKG.VALIDATE_LOOKUP_CODE(P_LOOKUP_TYPE => 'AHL_ITEMGROUP_TYPE',
			 P_LOOKUP_CODE =>l_item_group_rec.type_code) THEN
              FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_INAVLID');
              FND_MSG_PUB.ADD;
        END IF;
    ELSIF l_item_group_rec.type_meaning IS NOT NULL THEN
        AHL_UTIL_MC_PKG.CONVERT_TO_LOOKUPCODE(
			P_LOOKUP_TYPE      => 'AHL_ITEMGROUP_TYPE',
			P_LOOKUP_MEANING   => l_item_group_rec.TYPE_MEANING,
			X_LOOKUP_CODE      => l_item_group_rec.type_code,
			X_RETURN_VAL       => l_return_val);
	IF NOT l_return_val THEN
              FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_INAVLID');
              FND_MSG_PUB.ADD;
        END IF;
    ELSIF l_item_group_rec.OPERATION_FLAG = 'C' THEN
              FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_NULL');
	      FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
              FND_MSG_PUB.ADD;
    END IF;

    IF l_item_group_rec.status_code IS NOT NULL THEN
        IF NOT AHL_UTIL_MC_PKG.VALIDATE_LOOKUP_CODE(P_LOOKUP_TYPE => 'AHL_ITEMGROUP_STATUS',
			 P_LOOKUP_CODE =>l_item_group_rec.status_code) THEN
              FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_STATUS_INAVLID');
              FND_MSG_PUB.ADD;
        END IF;
    ELSIF l_item_group_rec.status_meaning IS NOT NULL THEN
        AHL_UTIL_MC_PKG.CONVERT_TO_LOOKUPCODE(
			P_LOOKUP_TYPE      => 'AHL_ITEMGROUP_STATUS',
			P_LOOKUP_MEANING   => l_item_group_rec.status_meaning,
			X_LOOKUP_CODE      => l_item_group_rec.status_code,
			X_RETURN_VAL       => l_return_val);
	IF NOT l_return_val THEN
              FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_STATUS_INAVLID');
              FND_MSG_PUB.ADD;
        END IF;
    END IF;

  END IF;

  -- Convert values to ID's for Item Association record columns.
  IF (p_x_items_tbl.COUNT > 0) THEN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
          	   THEN
          	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
          	     'ahl_mc_itemgroup_pub.process_item_group', 'Begin Loop to convert Item Name to Id');
    END IF;


    FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST  LOOP

       -- Check p_module_type.
       -- Blank out id's and re-built them based on Values.
       IF (p_module_type = 'JSP') THEN
          p_x_items_tbl(i).inventory_item_id := NULL;
       END IF;
       IF p_x_items_tbl(i).OPERATION_FLAG <> 'D' THEN
	       Convert_InTo_ID(p_x_items_tbl(i));

       END IF;

    END LOOP;
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'End of Loop');
  END IF;

  END IF;

IF l_item_group_rec.OPERATION_FLAG = 'C' THEN


  IF l_item_group_rec.name IS NULL
  THEN
               FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_NAME_NULL');
               FND_MSG_PUB.ADD;

  END IF;

  IF l_item_group_rec.status_code IS NOT NULL
     AND l_item_group_rec.status_code <> FND_API.G_MISS_CHAR
     AND l_item_group_rec.status_code <> 'DRAFT'
  THEN
                FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_CRE_DRAFT');
                FND_MSG_PUB.ADD;

  END IF;

 IF l_item_group_rec.type_code IS NULL AND
    l_item_group_rec.TYPE_MEANING IS NULL
 THEN
              FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_NULL');
              FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
              FND_MSG_PUB.ADD;
  ELSIF l_item_group_rec.TYPE_MEANING IS NOT NULL THEN
               AHL_UTIL_MC_PKG.Convert_To_LookupCode('AHL_ITEMGROUP_TYPE',
                                                    l_item_group_rec.TYPE_MEANING,
                                                    l_lookup_code,
                                                    l_return_val);
              IF (l_return_val) THEN
                p_x_item_group_rec.type_code := l_lookup_code;
              ELSE
		      FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_INAVLID');
		      FND_MSG_PUB.ADD;
	       END IF;

 END IF;
END IF;


IF (l_item_group_rec.OPERATION_FLAG in ('M','D')) THEN
  -- Convert group name to ID for Item_group_rec.
  IF (l_item_group_rec.item_group_id IS NULL) OR
     (l_item_group_rec.item_group_id = FND_API.G_MISS_NUM)
  THEN
     -- Check if group name exists.
     IF (l_item_group_rec.name IS NOT NULL) AND
        (l_item_group_rec.name <> FND_API.G_MISS_CHAR) THEN
           OPEN ahl_item_group_csr(l_item_group_rec.name);
           FETCH ahl_item_group_csr INTO l_item_group_id,l_type_code;
           IF (ahl_item_group_csr%FOUND) THEN
              p_x_item_group_rec.item_group_id := l_item_group_id;
              IF l_type_code <> p_x_item_group_rec.type_code THEN
		      FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_NOUPDATE');
		      FND_MSG_PUB.ADD;
	      END IF;

           ELSE
              FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_INVALID');
              FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
              FND_MSG_PUB.ADD;
           END IF;

     ELSE
           -- Both ID and name are missing.
           FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_NULL');
           FND_MSG_PUB.ADD;

     END IF;
  ELSIF NVL(p_module_type,'X') <> 'JSP' THEN
           OPEN Item_grp_name_csr(l_item_group_rec.item_group_id);
           FETCH Item_grp_name_csr INTO l_item_group_name,l_type_code;
           IF (Item_grp_name_csr%FOUND) THEN
              IF l_item_group_name <> p_x_item_group_rec.name
              THEN
		      FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_INVALID');
		      FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
		      FND_MSG_PUB.ADD;
              END IF;
              IF l_type_code <> p_x_item_group_rec.type_code THEN
		      FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_TYPE_NOUPDATE');
		      FND_MSG_PUB.ADD;
	      END IF;

           ELSE
              FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_INVALID');
              FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
              FND_MSG_PUB.ADD;
           END IF;

  END IF;

END IF;

IF (l_item_group_rec.OPERATION_FLAG = 'M') THEN

    IF (p_x_items_tbl.COUNT > 0) THEN
    FOR i IN p_x_items_tbl.FIRST..p_x_items_tbl.LAST  LOOP

        -- For group name.
        IF (p_x_items_tbl(i).item_group_id IS NULL) OR
           (p_x_items_tbl(i).item_group_id = FND_API.G_MISS_NUM)
        THEN
          -- Check if assoc group name same as group_rec name.
          IF (p_x_items_tbl(i).item_group_name = l_item_group_rec.name) THEN
              p_x_items_tbl(i).item_group_id := p_x_item_group_rec.item_group_id;
          ELSE
            -- if group name exists then it does not match group_rec.
            IF (p_x_items_tbl(i).item_group_name IS NOT NULL) AND
               (p_x_items_tbl(i).item_group_name <> FND_API.G_MISS_CHAR) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_MISMATCH');
                FND_MESSAGE.Set_Token('ITEM_GRP',l_item_group_rec.name);
                FND_MESSAGE.Set_Token('ASSO_GRP',p_x_items_tbl(i).item_group_name);
                FND_MSG_PUB.ADD;
                --dbms_output.put_line('Item Association record does not match Item Group');
            ELSE
                -- Both ID and Name are missing.
                FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEMGRP_NULL');
                FND_MSG_PUB.ADD;
            END IF;
          END IF;
        END IF;


    END LOOP;
  END IF;  /* for count > 0 */

END IF;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;


  IF p_x_item_group_rec.operation_flag ='C' THEN


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Calling ahl_mc_itemgroup_pvt.Create_Item_group');
  END IF;

-- Call Private API for Create

  ahl_mc_itemgroup_pvt.Create_Item_group(
                             p_api_version      => p_api_version,
                             --p_init_msg_list    => p_init_msg_list,
                             --p_commit           => p_commit,
                             p_validation_level => p_validation_level,
                             p_x_item_group_rec => p_x_item_group_rec,
                             p_x_items_tbl      => p_x_items_tbl ,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data );

  ELSIF p_x_item_group_rec.operation_flag ='M' THEN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Calling ahl_mc_itemgroup_pvt.Modify_Item_group');
  END IF;

  -- Call Private API for Create
  AHL_MC_ItemGroup_Pvt.Modify_Item_group(
                             p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
                             --p_commit           => p_commit,
                             p_validation_level => p_validation_level,
                             p_item_group_rec => p_x_item_group_rec,
                             p_x_items_tbl      => p_x_items_tbl ,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data );

ELSIF p_x_item_group_rec.operation_flag ='D' THEN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Calling ahl_mc_itemgroup_pvt.Remove_Item_group');
  END IF;

  -- Call Private API for Create
  AHL_MC_ItemGroup_Pvt.Remove_Item_group(
                             p_api_version      => p_api_version,
                             --p_init_msg_list    => p_init_msg_list,
                             --p_commit           => p_commit,
                             p_validation_level => p_validation_level,
                             p_item_group_rec => p_x_item_group_rec,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data );

END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'End of process_item_group');
  END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Process_Item_group_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Error in process_item_group');
  END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Process_Item_group_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Unexpected Error in process_item_group');
  END IF;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_Item_group_Pub;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Item_group',
                               p_error_text     => SQLERRM);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', 'Unknown Error in process_item_group');
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.process_item_group', SQLERRM);
  END IF;



END   PROCESS_ITEM_GROUP;



------------------------------
-- Define Local Procedures --
------------------------------

PROCEDURE Convert_InTo_ID(p_x_item_assoc_rec  IN OUT NOCOPY AHL_MC_ItemGroup_Pvt.Item_association_rec_type) IS


  -- For organization id.
  CURSOR mtl_parameters_csr (p_org_code  IN  VARCHAR2) IS
     SELECT organization_id
     FROM mtl_parameters
     WHERE organization_code = p_org_code;

  -- For inventory_item_id.
  CURSOR mtl_system_items_csr(p_inventory_item_name  IN VARCHAR2,
                              p_inv_organization_id  IN NUMBER) IS
     SELECT inventory_item_id
     FROM  ahl_mtl_items_non_ou_v
     WHERE concatenated_segments = p_inventory_item_name
     AND   inventory_org_id = p_inv_organization_id;

  -- For concatenated segments.
  CURSOR mtl_segment_csr(p_inventory_item_id    IN NUMBER,
                         p_inv_organization_id  IN NUMBER) IS
     SELECT concatenated_segments
     FROM  ahl_mtl_items_non_ou_v
     WHERE inventory_item_id = p_inventory_item_id
     AND  inventory_org_id = p_inv_organization_id;

  -- For item association id.
  CURSOR ahl_item_associations_csr(p_item_grp_id       IN  NUMBER,
                                   p_inventory_org_id  IN  NUMBER,
                                   p_inventory_item_id IN  NUMBER)  IS
     SELECT item_association_id
     FROM ahl_item_associations_vl
     WHERE item_group_id = p_item_grp_id
     AND   inventory_org_id = p_inventory_org_id
     AND   inventory_item_id = p_inventory_item_id;


  l_inventory_id            NUMBER;
  l_item_assoc_rec          ahl_mc_itemgroup_pvt.Item_association_rec_type  DEFAULT p_x_item_assoc_rec;
  l_inventory_org_id        NUMBER;
  l_item_association_id     NUMBER;
  l_item_group_id           NUMBER;
  l_lookup_code             fnd_lookups.lookup_code%TYPE;
  l_return_val              BOOLEAN;
  l_concatenated_segments   ahl_mtl_items_non_ou_v.concatenated_segments%TYPE;
  l_dummy varchar2(200);

BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.Convert_InTo_ID', 'Begin of Convert_InTo_ID');
  END IF;


      -- For Inventory Organization Code.
      IF (l_item_assoc_rec.inventory_org_id IS NULL) OR
         (l_item_assoc_rec.inventory_org_id = FND_API.G_MISS_NUM)
      THEN
         -- if code is present.
         IF (l_item_assoc_rec.inventory_org_code IS NOT NULL) AND
            (l_item_assoc_rec.inventory_org_code <> FND_API.G_MISS_CHAR) THEN
                OPEN mtl_parameters_csr (l_item_assoc_rec.inventory_org_code);
                FETCH mtl_parameters_csr INTO l_inventory_org_id;
                IF (mtl_parameters_csr%FOUND) THEN
                    l_item_assoc_rec.inventory_org_id := l_inventory_org_id;
                ELSE
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_INVALID');
                    FND_MESSAGE.Set_Token('ORG',l_item_assoc_rec.inventory_org_code);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE mtl_parameters_csr;
         ELSIF (l_item_assoc_rec.operation_flag = 'C') THEN
            -- Both ID and code are missing.
            FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_NULL');
            FND_MSG_PUB.ADD;
         END IF;

      END IF;

      -- For Inventory item.
      IF (l_item_assoc_rec.inventory_item_id IS NULL) OR
         (l_item_assoc_rec.inventory_item_id = FND_API.G_MISS_NUM)
      THEN
         -- check if name exists.
         IF (l_item_assoc_rec.inventory_item_name IS NOT NULL) AND
            (l_item_assoc_rec.inventory_item_name <> FND_API.G_MISS_CHAR) THEN

               OPEN mtl_system_items_csr(l_item_assoc_rec.inventory_item_name,
                                          l_item_assoc_rec.inventory_org_id);
               FETCH mtl_system_items_csr INTO l_inventory_id;
               IF (mtl_system_items_csr%FOUND) THEN
                  l_item_assoc_rec.inventory_item_id := l_inventory_id;

               ELSE
                  FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
                  FND_MESSAGE.Set_Token('INV_ITEM',l_item_assoc_rec.inventory_item_name);
                  FND_MSG_PUB.ADD;
               END IF;
               CLOSE mtl_system_items_csr;
         ELSIF (l_item_assoc_rec.operation_flag = 'C') THEN
            -- Both ID and name missing.
            FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_NULL');
            FND_MSG_PUB.ADD;
         END IF;

      ELSE
         OPEN mtl_segment_csr(l_item_assoc_rec.inventory_item_id,
                              l_item_assoc_rec.inventory_org_id);
         FETCH mtl_segment_csr INTO l_concatenated_segments;
         IF (mtl_segment_csr%NOTFOUND) THEN
             FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
             FND_MESSAGE.Set_Token('INV_ITEM',l_item_assoc_rec.inventory_item_id);
             FND_MSG_PUB.ADD;
         ELSE
             l_item_assoc_rec.inventory_item_name := l_concatenated_segments;
         END IF;
         CLOSE mtl_segment_csr;

      END IF;

	-- For priority
	IF (l_item_assoc_rec.priority IS NULL OR
	l_item_assoc_rec.priority = FND_API.G_MISS_NUM)
	THEN
	 FND_MESSAGE.Set_Name('AHL','AHL_MC_PRIORITY_NULL');
	 FND_MESSAGE.Set_Token('INV_ITEM',l_item_assoc_rec.inventory_item_name);
	 FND_MSG_PUB.ADD;
	ELSIF ( INSTR(l_item_assoc_rec.priority,'.') > 0 )
	THEN
	 FND_MESSAGE.Set_Name('AHL','AHL_MC_PRIORITY_INVALID_JSP');
	 FND_MSG_PUB.ADD;
	END IF;


      -- Check if item association id exists; if not populate it.
      IF (l_item_assoc_rec.operation_flag <> 'C') THEN
        IF (l_item_assoc_rec.item_association_id IS NULL OR
           l_item_assoc_rec.item_association_id = FND_API.G_MISS_NUM) THEN
             OPEN ahl_item_associations_csr(l_item_assoc_rec.item_group_id,
                                            l_item_assoc_rec.inventory_org_id,
                                            l_item_assoc_rec.inventory_item_id);

             FETCH ahl_item_associations_csr INTO l_item_association_id;
             IF (ahl_item_associations_csr%FOUND) THEN
                 l_item_assoc_rec.item_association_id := l_item_association_id;
             ELSE
                 FND_MESSAGE.Set_Name('AHL','AHL_MC_ASSOC_NULL');
                 FND_MSG_PUB.ADD;
              END IF;
        END IF;
      END IF; /* operation flag */

      -- For Interchange_type_meaning.
      IF (l_item_assoc_rec.interchange_type_code IS NULL) OR
         (l_item_assoc_rec.interchange_type_code =  FND_API.G_MISS_CHAR)
      THEN
         -- Check if meaning exists.
         IF (l_item_assoc_rec.Interchange_type_meaning IS NOT NULL) AND
            (l_item_assoc_rec.Interchange_type_meaning <>  FND_API.G_MISS_CHAR) THEN
              AHL_UTIL_MC_PKG.Convert_To_LookupCode('AHL_INTERCHANGE_ITEM_TYPE',
                                                    l_item_assoc_rec.Interchange_type_meaning,
                                                    l_lookup_code,
                                                    l_return_val);
              IF (l_return_val) THEN
                 l_item_assoc_rec.interchange_type_code := l_lookup_code;
              ELSE
                 FND_MESSAGE.Set_Name('AHL','AHL_MC_INTER_INVALID');
                 FND_MESSAGE.Set_Token('INV_ITEM',l_item_assoc_rec.inventory_item_name);
                 FND_MESSAGE.Set_Token('INTER_CODE',l_item_assoc_rec.Interchange_type_meaning);
                 FND_MSG_PUB.ADD;
              END IF;
         ELSE
           IF (l_item_assoc_rec.Interchange_type_meaning IS NULL) THEN
             l_item_assoc_rec.interchange_type_code := null;
           END IF;
         END IF;
      END IF;

      -- return changed record.
      p_x_item_assoc_rec := l_item_assoc_rec;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
      l_dummy := 'Inventory p_x_item_assoc_rec '||to_char(p_x_item_assoc_rec.inventory_item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'ahl_mc_itemgroup_pvt.Convert_InTo_ID', l_dummy);
      END IF;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_itemgroup_pub.Convert_InTo_ID', 'End of Convert_InTo_ID');
  END IF;

END Convert_InTo_ID;


End AHL_MC_ITEMGROUP_PUB;

/
