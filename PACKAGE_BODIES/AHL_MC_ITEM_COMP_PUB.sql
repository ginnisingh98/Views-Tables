--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEM_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEM_COMP_PUB" AS
/* $Header: AHLPICXB.pls 115.2 2003/08/29 09:59:39 tamdas noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_MC_ITEM_COMP_PUB';

PROCEDURE Convert_code_to_ID(p_x_item_comp_rec  IN OUT NOCOPY ahl_mc_item_comp_pvt.Detail_Rec_Type);

PROCEDURE Process_Item_Composition(
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	p_module_type       IN            VARCHAR2  := NULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_x_ic_header_rec     IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Header_Rec_Type,
	p_x_ic_det_tbl           IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
) AS

l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;


  CURSOR mtl_parameters_csr (p_org_code  IN  VARCHAR2) IS
     SELECT organization_id
     FROM mtl_parameters
     WHERE organization_code = p_org_code;


  CURSOR mtl_system_items_csr(p_inventory_item_name  IN VARCHAR2,
                              p_inv_organization_id  IN NUMBER) IS
     SELECT inventory_item_id
     FROM  ahl_mtl_items_non_ou_v
     WHERE concatenated_segments = p_inventory_item_name
     AND   inventory_org_id = p_inv_organization_id;

  CURSOR mtl_segment_csr(p_inventory_item_id    IN NUMBER,
                         p_inv_organization_id  IN NUMBER) IS
     SELECT concatenated_segments
     FROM  ahl_mtl_items_non_ou_v
     WHERE inventory_item_id = p_inventory_item_id
     AND  inventory_org_id = p_inv_organization_id;

l_inv_org_id NUMBER;
l_inv_item_id NUMBER;
l_item_name VARCHAR2(2000);
l_msg_count NUMBER;

BEGIN

       SAVEPOINT  Process_Item_Composition;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	'ahl.plsql.'||G_PKG_NAME||'.Process_Item_Composition', 'Begin of Process_Item_Composition');
END IF;


IF p_x_ic_header_rec.operation_flag IN ('C','M') THEN

   IF  p_x_ic_header_rec.inventory_org_id IS NULL THEN

     IF p_x_ic_header_rec.inventory_org_code IS NOT NULL THEN
	OPEN mtl_parameters_csr (p_x_ic_header_rec.inventory_org_code);
	FETCH mtl_parameters_csr INTO l_inv_org_id;
	IF (mtl_parameters_csr%FOUND) THEN
	    p_x_ic_header_rec.inventory_org_id := l_inv_org_id;
	ELSE
	    FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_INVALID');
	    FND_MESSAGE.Set_Token('ORG',p_x_ic_header_rec.inventory_org_code);
	    FND_MSG_PUB.ADD;
	END IF;
     ELSE
    	FND_MESSAGE.SET_NAME('AHL','AHL_MC_ORG_NULL');
    	FND_MSG_PUB.ADD;
     END IF;
   END IF; -- end of inventory_org_id condition.

  IF p_x_ic_header_rec.inventory_item_id IS NULL THEN

     IF p_x_ic_header_rec.inventory_item_name IS NOT NULL THEN
	OPEN mtl_system_items_csr (p_x_ic_header_rec.inventory_item_name,
	                           p_x_ic_header_rec.inventory_org_id);
	FETCH mtl_system_items_csr INTO l_inv_item_id;
	IF (mtl_system_items_csr%FOUND) THEN
		p_x_ic_header_rec.inventory_item_id := l_inv_item_id;
	ELSE
	    FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
	    FND_MESSAGE.Set_Token('INV_ITEM',p_x_ic_header_rec.inventory_item_name);
	    FND_MSG_PUB.ADD;
	END IF;
    ELSE
    	FND_MESSAGE.SET_NAME('AHL','AHL_MC_INV_NULL');
    	FND_MSG_PUB.ADD;
    END IF;
   ELSIF p_x_ic_header_rec.inventory_item_id IS NOT NULL THEN
         OPEN mtl_segment_csr(p_x_ic_header_rec.inventory_item_id,
                              p_x_ic_header_rec.inventory_org_id);
         FETCH mtl_segment_csr INTO l_item_name;
         IF (mtl_segment_csr%NOTFOUND) THEN
             FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
             FND_MESSAGE.Set_Token('INV_ITEM',p_x_ic_header_rec.inventory_item_id);
             FND_MSG_PUB.ADD;
         ELSE
             p_x_ic_header_rec.inventory_item_name := l_item_name;
         END IF;
         CLOSE mtl_segment_csr;
   END IF; -- end of inventory_item_id check



END IF;  --- end of flag condition

IF (p_x_ic_det_tbl.COUNT > 0) THEN

FOR I IN p_x_ic_det_tbl.first..p_x_ic_det_tbl.last
Loop

       IF (p_module_type = 'JSP') THEN
          p_x_ic_det_tbl(i).inventory_item_id := NULL;
	  p_x_ic_det_tbl(i).item_group_id := NULL;
       END IF;
       IF p_x_ic_det_tbl(i).OPERATION_FLAG <> 'D' THEN
	       Convert_code_to_ID(p_x_ic_det_tbl(i));

       END IF;

End Loop;

END IF;

  l_msg_count := FND_MSG_PUB.count_msg;

  IF l_msg_count > 0
   THEN
       X_msg_count := l_msg_count;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

IF p_x_ic_header_rec.operation_flag = 'C' THEN

	 ahl_mc_item_comp_pvt.Create_Item_Composition(
		p_api_version              => p_api_version,
		--p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
		--p_commit              IN VARCHAR2  := FND_API.G_FALSE,
		--p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status            => x_return_status,
		 x_msg_count                => x_msg_count,
		 x_msg_data                 => x_msg_data,
		p_x_ic_header_rec     =>  p_x_ic_header_rec,
		p_x_det_tbl           =>  p_x_ic_det_tbl);

ELSIF p_x_ic_header_rec.operation_flag = 'M' THEN

	 ahl_mc_item_comp_pvt.Modify_Item_Composition(
		p_api_version              => p_api_version,
		--p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
		--p_commit              IN VARCHAR2  := FND_API.G_FALSE,
		--p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status            => x_return_status,
		 x_msg_count                => x_msg_count,
		 x_msg_data                 => x_msg_data,
		p_x_ic_header_rec     =>  p_x_ic_header_rec,
		p_x_det_tbl           =>  p_x_ic_det_tbl);

ELSIF p_x_ic_header_rec.operation_flag = 'D' THEN

	 ahl_mc_item_comp_pvt.delete_item_composition(
		 p_api_version              => p_api_version,
		-- p_init_msg_list            =>
		-- p_commit                   =>
		-- p_validation_level         =>
		 x_return_status            => x_return_status,
		 x_msg_count                => x_msg_count,
		 x_msg_data                 => x_msg_data,
		 p_item_composition_id      => p_x_ic_header_rec.item_composition_id,
		 p_object_version_number    => p_x_ic_header_rec.object_version_number);

END IF;

 IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT WORK;
 END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Process_Item_Composition', 'End of Process_Item_Composition');
 END IF;


 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Process_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Process_Item_Composition', 'Error in Process_Item_Composition');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Process_Item_Composition', 'Unexpected Error in Process_Item_Composition');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Process_Item_Composition;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Process_Item_Composition',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Process_Item_Composition', 'Unknown Error in Process_Item_Composition');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Process_Item_Composition', SQLERRM);
  END IF;


END Process_Item_Composition;


PROCEDURE Convert_code_to_ID(p_x_item_comp_rec  IN OUT NOCOPY ahl_mc_item_comp_pvt.Detail_Rec_Type) IS


  -- For Item Group  id.
  CURSOR get_itemGroup_csr(p_item_group_name  IN  VARCHAR2) IS
     SELECT item_group_id
     FROM ahl_item_groups_vl
     WHERE name = p_item_group_name
     AND status_code = 'COMPLETE'
     AND type_code = 'NON-TRACKED';

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



  l_inventory_id            NUMBER;
  l_item_group_id           NUMBER;
  l_item_comp_rec          ahl_mc_item_comp_pvt.Detail_Rec_Type  DEFAULT p_x_item_comp_rec;
  l_inventory_org_id        NUMBER;
  l_item_association_id     NUMBER;
  l_lookup_code             fnd_lookups.lookup_code%TYPE;
  l_return_val              BOOLEAN;
  l_concatenated_segments   ahl_mtl_items_ou_v.concatenated_segments%TYPE;
  l_dummy varchar2(200);

BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_item_comp_pvt.Convert_InTo_ID', 'Begin of Convert_InTo_ID');
  END IF;

IF (l_item_comp_rec.item_group_name IS NOT NULL)   THEN
	OPEN get_itemGroup_csr (l_item_comp_rec.item_group_name);
	FETCH get_itemGroup_csr INTO l_item_group_id;
	IF (get_itemGroup_csr%FOUND) THEN
	    l_item_comp_rec.item_group_id := l_item_group_id;
	ELSE
   	    FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_IG_INVALID');
	    FND_MESSAGE.Set_Token('ITEM_GRP',l_item_comp_rec.item_group_name);
	    FND_MSG_PUB.ADD;
	END IF;
	CLOSE get_itemGroup_csr;
END IF;

IF (l_item_comp_rec.inventory_item_id IS NOT NULL) OR
	(l_item_comp_rec.inventory_item_name IS NOT NULL) THEN


      -- For Inventory Organization Code.
      IF (l_item_comp_rec.inventory_org_id IS NULL) OR
         (l_item_comp_rec.inventory_org_id = FND_API.G_MISS_NUM)
      THEN
         -- if code is present.
         IF (l_item_comp_rec.inventory_org_code IS NOT NULL) AND
            (l_item_comp_rec.inventory_org_code <> FND_API.G_MISS_CHAR) THEN
                OPEN mtl_parameters_csr (l_item_comp_rec.inventory_org_code);
                FETCH mtl_parameters_csr INTO l_inventory_org_id;
                IF (mtl_parameters_csr%FOUND) THEN
                    l_item_comp_rec.inventory_org_id := l_inventory_org_id;
                ELSE
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_INVALID');
                    FND_MESSAGE.Set_Token('ORG',l_item_comp_rec.inventory_org_code);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE mtl_parameters_csr;
         ELSIF (l_item_comp_rec.operation_flag = 'C') THEN
            -- Both ID and code are missing.
            FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_NULL');
            FND_MSG_PUB.ADD;
         END IF;

      END IF;

      -- For Inventory item.
      IF (l_item_comp_rec.inventory_item_id IS NULL) OR
         (l_item_comp_rec.inventory_item_id = FND_API.G_MISS_NUM)
      THEN
         -- check if name exists.
         IF (l_item_comp_rec.inventory_item_name IS NOT NULL) AND
            (l_item_comp_rec.inventory_item_name <> FND_API.G_MISS_CHAR) THEN

               OPEN mtl_system_items_csr(l_item_comp_rec.inventory_item_name,
                                          l_item_comp_rec.inventory_org_id);
               FETCH mtl_system_items_csr INTO l_inventory_id;
               IF (mtl_system_items_csr%FOUND) THEN
                  l_item_comp_rec.inventory_item_id := l_inventory_id;

               ELSE
                  FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
                  FND_MESSAGE.Set_Token('INV_ITEM',l_item_comp_rec.inventory_item_name);
                  FND_MSG_PUB.ADD;
               END IF;
               CLOSE mtl_system_items_csr;
         ELSIF (l_item_comp_rec.operation_flag = 'C') THEN
            -- Both ID and name missing.
            FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_NULL');
            FND_MSG_PUB.ADD;
         END IF;

      ELSE
         OPEN mtl_segment_csr(l_item_comp_rec.inventory_item_id,
                              l_item_comp_rec.inventory_org_id);
         FETCH mtl_segment_csr INTO l_concatenated_segments;
         IF (mtl_segment_csr%NOTFOUND) THEN
             FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
             FND_MESSAGE.Set_Token('INV_ITEM',l_item_comp_rec.inventory_item_id);
             FND_MSG_PUB.ADD;
         ELSE
             l_item_comp_rec.inventory_item_name := l_concatenated_segments;
         END IF;
         CLOSE mtl_segment_csr;

      END IF;

 END IF;


      -- return changed record.
      p_x_item_comp_rec := l_item_comp_rec;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
      l_dummy := 'Inventory p_x_item_comp_rec '||to_char(p_x_item_comp_rec.inventory_item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'ahl_mc_item_comp_pvt.Convert_InTo_ID', l_dummy);
      END IF;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
        	   THEN
        	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        	     'ahl_mc_item_comp_pvt.Convert_InTo_ID', 'End of Convert_InTo_ID');
  END IF;

END Convert_code_to_ID;



End AHL_MC_ITEM_COMP_PUB;

/
