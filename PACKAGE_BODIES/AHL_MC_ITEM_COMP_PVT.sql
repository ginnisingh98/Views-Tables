--------------------------------------------------------
--  DDL for Package Body AHL_MC_ITEM_COMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_ITEM_COMP_PVT" AS
/* $Header: AHLVICXB.pls 120.1 2006/01/10 03:41:28 sagarwal noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'ahl_mc_item_comp_pvt';

PROCEDURE Create_Line_Item (p_item_composition_id IN NUMBER,
	p_x_comp_det_rec IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Detail_Rec_Type
);

PROCEDURE Update_Line_Item (p_item_composition_id IN NUMBER,
	p_x_comp_det_rec IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Detail_Rec_Type
);

PROCEDURE Delete_Line_Item (p_item_composition_id IN NUMBER,
	p_x_comp_det_rec IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Detail_Rec_Type
);

PROCEDURE Validate_InventoryID(p_inventory_item_id         IN   NUMBER,
                               p_inventory_org_id          IN   NUMBER,
                               p_record_type                 IN   VARCHAR2,
                               p_master_org_id             IN OUT NOCOPY  NUMBER
                               ) IS


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
  l_segment1                   ahl_mtl_items_ou_v.concatenated_segments%TYPE;
  l_serial_number_control      NUMBER;
  l_revision_qty_control_code  NUMBER;
  l_organization_code          mtl_parameters.organization_code%TYPE;
  l_master_org_id              NUMBER;

BEGIN

                       -- For organization code
  OPEN mtl_parameters_csr(p_inventory_org_id);
  FETCH mtl_parameters_csr INTO l_organization_code,l_master_org_id;
  IF (mtl_parameters_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_ORG_INVALID');
      FND_MESSAGE.Set_Token('ORG',p_inventory_org_id);
      FND_MSG_PUB.ADD;
  ELSE
      p_master_org_id := l_master_org_id;
  /*IF l_master_org_id <> p_master_org_id THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_MASTER_ORG_INVALID');
      FND_MESSAGE.Set_Token('ORG',p_master_org_id);
      FND_MSG_PUB.ADD;
      */
  END IF;
  CLOSE mtl_parameters_csr;


  OPEN mtl_system_items_non_ou_csr(p_inventory_item_id,p_inventory_org_id);
  FETCH mtl_system_items_non_ou_csr INTO l_instance_track, l_segment1, l_serial_number_control,
                                  l_revision_qty_control_code;
  l_segment1 := l_segment1 || ',' || l_organization_code;

  IF (mtl_system_items_non_ou_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_INVALID');
      FND_MESSAGE.Set_Token('INV_ITEM',p_inventory_item_id);
      FND_MSG_PUB.ADD;
      --dbms_output.put_line('Inventory item does not exist');

      l_segment1 := null;
      l_revision_qty_control_code := null;
      l_serial_number_control := null;

  ELSE

      IF ( UPPER(p_record_type) = 'HEADER' AND UPPER(l_instance_track) <> 'Y')
      THEN
	         FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_TRACK');
	         FND_MESSAGE.Set_Token('INV_ITEM',l_segment1);
	         FND_MSG_PUB.ADD;
         --dbms_output.put_line('Rec Type '||p_record_type || ' and '||l_instance_track);
      ELSIF ( UPPER(p_record_type) = 'DETAIL' AND UPPER(l_instance_track) = 'Y')
      THEN
	         FND_MESSAGE.Set_Name('AHL','AHL_MC_INV_NON_TRACK');
	         FND_MESSAGE.Set_Token('INV_ITEM',l_segment1);
	         FND_MSG_PUB.ADD;
	         --dbms_output.put_line('Inventory item are trackable');
      END IF;

   END IF;

  CLOSE mtl_system_items_non_ou_csr;

END Validate_InventoryID;

PROCEDURE Validate_Qty_UOM(p_uom_code           IN  VARCHAR2,
                           p_quantity           IN  NUMBER,
                           p_inventory_item_id  IN  NUMBER,
                           p_inventory_org_id   IN  NUMBER,
                           p_inv_segment        IN  VARCHAR2,
                           p_item_group_name    IN  VARCHAR2) IS

cursor validate_uom(p_uom_code in varchar2) is
select uom_code
from   mtl_units_of_measure_vl
where  uom_code = p_uom_code;

l_uom_code varchar2(3);
BEGIN


  IF p_item_group_name IS NOT NULL AND
     (p_uom_code IS NULL AND (p_quantity IS NULL OR p_quantity = 0)) THEN
     RETURN;
  END IF;



  -- Check if UOM entered and valid.
  IF (p_uom_code IS NULL OR p_uom_code = FND_API.G_MISS_CHAR) THEN
         -- uom_code is null but quantity is not null.
         IF (p_inv_segment IS NULL OR p_inv_segment = FND_API.G_MISS_CHAR) THEN
		 FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_UOM_NULL');
		 FND_MESSAGE.Set_Token('IG',p_item_group_name);
		 FND_MSG_PUB.ADD;
         ELSE
		 FND_MESSAGE.Set_Name('AHL','AHL_MC_INVUOM_NULL');
		 FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
		 FND_MSG_PUB.ADD;
         END IF;
         --dbms_output.put_line('Uom is null');
  ELSIF p_inventory_item_id IS NOT NULL AND p_inventory_org_id IS NOT NULL THEN
	  IF NOT(inv_convert.Validate_Item_Uom(p_item_id          => p_inventory_item_id,
						  p_organization_id  => p_inventory_org_id,
						  p_uom_code         => p_uom_code))
	  THEN
		 FND_MESSAGE.Set_Name('AHL','AHL_MC_INVUOM_INVALID');
		 FND_MESSAGE.Set_Token('UOM_CODE',p_uom_code);
		 FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
		 FND_MSG_PUB.ADD;
		 --dbms_output.put_line('Invalid UOM code for the item');
	  END IF;
  ELSIF p_item_group_name IS NOT NULL THEN
  	OPEN validate_uom(p_uom_code);
  	FETCH validate_uom INTO l_uom_code;
  	IF validate_uom%NOTFOUND THEN
		 FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_UOM_INVALID');
		 FND_MESSAGE.Set_Token('UOM_CODE',p_uom_code);
		 FND_MESSAGE.Set_Token('IG',p_item_group_name);
		 FND_MSG_PUB.ADD;
        END IF;
  END IF ;

  -- Validate quantity.
  IF (p_quantity IS NULL OR p_quantity = FND_API.G_MISS_NUM) THEN
        IF (p_inv_segment IS NULL OR p_inv_segment = FND_API.G_MISS_CHAR) THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_QTY_NULL');
		FND_MESSAGE.Set_Token('IG',p_item_group_name);
		FND_MSG_PUB.ADD;
        ELSE
		FND_MESSAGE.Set_Name('AHL','AHL_MC_QTY_NULL');
		FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
		FND_MSG_PUB.ADD;
        END IF;
        --dbms_output.put_line('Quantity is null');
   ELSIF (p_quantity < 0) THEN
        IF (p_inv_segment IS NULL OR p_inv_segment = FND_API.G_MISS_CHAR) THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_IG_QTY_INVALID');
		FND_MESSAGE.Set_Token('IG',p_item_group_name);
		FND_MESSAGE.Set_Token('QUANTITY',p_quantity);
		FND_MSG_PUB.ADD;
        ELSE
		FND_MESSAGE.Set_Name('AHL','AHL_MC_INVQTY_INVALID');
		FND_MESSAGE.Set_Token('INV_ITEM',p_inv_segment);
		FND_MESSAGE.Set_Token('QUANTITY',p_quantity);
		FND_MSG_PUB.ADD;
        END IF;
        --dbms_output.put_line('Invalid quantity');
   END IF;

END Validate_Qty_UOM;



PROCEDURE Validate_Item_Comp_Det( p_item_composition_id IN NUMBER,
                                  P_inv_item_name      IN VARCHAR2,
                                  p_x_Detail_Rec_Type IN OUT NOCOPY ahl_mc_item_comp_pvt.Detail_Rec_Type
                                  )
AS


CURSOR validate_item_group(p_item_group_name IN VARCHAR2,
                           p_item_group_id         IN NUMBER)
IS
SELECT 'x'
FROM   ahl_item_groups_vl
WHERE  item_group_id = p_item_group_id
AND    name = p_item_group_name
AND    type_code = 'NON-TRACKED'
AND    status_code = 'COMPLETE';

CURSOR item_group_exists(p_item_group_id IN NUMBER,
			   p_item_composition_id IN NUMBER)
IS
SELECT 'x'
FROM AHL_ITEM_COMP_DETAILS
WHERE ITEM_GROUP_ID = p_item_group_id
AND ITEM_COMPOSITION_ID= p_item_composition_id
AND EFFECTIVE_END_DATE is null;

CURSOR inv_item_exists(p_inventory_item_id IN NUMBER,
                       p_inventory_master_org_id IN NUMBER,
			   p_item_composition_id IN NUMBER)
IS
SELECT 'x'
FROM AHL_ITEM_COMP_DETAILS
WHERE INVENTORY_ITEM_ID = p_inventory_item_id
AND INVENTORY_MASTER_ORG_ID = 	p_inventory_master_org_id
AND ITEM_COMPOSITION_ID= p_item_composition_id
AND EFFECTIVE_END_DATE is null;


CURSOR get_item_comp_det(  p_item_composition_id IN NUMBER,
			p_item_comp_detail_id IN NUMBER)
IS
SELECT 'x'
FROM AHL_ITEM_COMP_DETAILS
WHERE item_comp_detail_id = p_item_comp_detail_id
AND item_composition_id= p_item_composition_id;


l_dummy varchar2(1);

l_Detail_Rec_Type  ahl_mc_item_comp_pvt.Detail_Rec_Type DEFAULT p_x_Detail_Rec_Type;

BEGIN


 IF l_Detail_Rec_Type.operation_flag ='M' THEN

 --dbms_output.put_line(l_Detail_Rec_Type.item_composition_id ||'--'|| p_item_composition_id);
 	IF NVL(l_Detail_Rec_Type.item_composition_id,0) <> NVL(p_item_composition_id,0) THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_INVALID_HEADER');
		FND_MSG_PUB.ADD;
        END IF;

       	OPEN get_item_comp_det(p_item_composition_id,l_Detail_Rec_Type.item_comp_detail_id);
 	FETCH get_item_comp_det INTO l_dummy;
 	IF get_item_comp_det%NOTFOUND THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_DETAIL_NO_EXIST');
		FND_MSG_PUB.ADD;
        END IF;
 	CLOSE get_item_comp_det;

 END IF;



 IF   l_Detail_Rec_Type.item_group_name IS NOT NULL
      AND l_Detail_Rec_Type.item_group_id IS NOT NULL THEN
 	OPEN validate_item_group(l_Detail_Rec_Type.item_group_name,
 	                         l_Detail_Rec_Type.item_group_id);
 	FETCH validate_item_group INTO l_dummy;
 	IF validate_item_group%NOTFOUND THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_IG_INVALID');
		FND_MESSAGE.set_token('ITEM_GRP',l_Detail_Rec_Type.item_group_name);
		FND_MSG_PUB.ADD;
        END IF;
 	CLOSE validate_item_group;

     IF l_Detail_Rec_Type.operation_flag ='C' THEN
        OPEN item_group_exists(l_Detail_Rec_Type.item_group_id,
 	                       p_item_composition_id);
 	FETCH item_group_exists INTO l_dummy;
 	IF item_group_exists%FOUND THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_IG_EXISTS');
		FND_MESSAGE.set_token('ITEM_GRP',l_Detail_Rec_Type.item_group_name);
		FND_MESSAGE.set_token('INV_ITEM',p_inv_item_name);

		FND_MSG_PUB.ADD;
        END IF;
        CLOSE item_group_exists;
     END IF;
END IF;


IF l_Detail_Rec_Type.INVENTORY_ITEM_ID IS NOT NULL THEN
	Validate_InventoryID(l_Detail_Rec_Type.inventory_item_id  ,
				       l_Detail_Rec_Type.inventory_org_id ,
				       'DETAIL',
				       l_Detail_Rec_Type.inventory_master_org_id
				       ) ;
	 IF p_item_composition_id IS NOT NULL THEN
	  OPEN inv_item_exists(l_Detail_Rec_Type.inventory_item_id,
			       l_Detail_Rec_Type.inventory_master_org_id ,
			       p_item_composition_id);
	  FETCH inv_item_exists INTO l_dummy;
	  IF inv_item_exists%FOUND THEN
	     IF l_Detail_Rec_Type.operation_flag ='C' THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_INV_EXISTS');
		FND_MESSAGE.set_token('INV_ITM',l_Detail_Rec_Type.inventory_item_name);
		FND_MESSAGE.set_token('INV_ITEM',p_inv_item_name);
		FND_MSG_PUB.ADD;
	     END IF;
	  ELSE
	     IF  l_Detail_Rec_Type.operation_flag ='M' THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_INV_NOEXISTS');
		FND_MSG_PUB.ADD;
	      END IF;
	  END IF;
	  CLOSE inv_item_exists;
	 END IF;


 END IF;
          IF   l_Detail_Rec_Type.operation_flag <>'D' THEN
                Validate_Qty_UOM(p_uom_code  => l_Detail_Rec_Type.uom_code,
                                 p_quantity  => l_Detail_Rec_Type.quantity,
		                 p_inventory_item_id  => l_Detail_Rec_Type.inventory_item_id,
		                 p_inventory_org_id   => l_Detail_Rec_Type.inventory_org_id,
                                 p_inv_segment      => l_Detail_Rec_Type.inventory_item_name,
                                 p_item_group_name  => l_Detail_Rec_Type.item_group_name );
          END IF;

  IF (l_Detail_Rec_Type.inventory_item_id IS NULL AND
     l_Detail_Rec_Type.item_group_name   IS NULL AND
     l_Detail_Rec_Type.operation_flag <>'D') OR
     (l_Detail_Rec_Type.inventory_item_id IS NOT NULL AND
     l_Detail_Rec_Type.item_group_name   IS NOT NULL )
     THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_ASSOS_NULL');
		FND_MSG_PUB.ADD;
  END IF;

  IF l_Detail_Rec_Type.item_composition_id <> p_item_composition_id THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_HEADER_MISMATCH');
		FND_MSG_PUB.ADD;
  END IF;

  p_x_Detail_Rec_Type :=  l_Detail_Rec_Type;


END;

-- Start of Comments --
--  Procedure name    : Create_Item_Composition
--  Type        : Private
--  Function    : Creates Item Composition for Trackable Items in ahl_item_compositions.
--                Also creates item-group and Non-Trackable Item  association in ahl_comp_details table.
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
--  Item Header Composition Record :
--	inventory_item_id        required.
--	inventory_item_name      required.
--	inventory_org_id         required.
--	inventory_org_code       required.
--      operation_flag           required to be 'C'.(Create)
--  Item Associations Record :
--	item_group_id  	         Required. ( If inventory_item_id Non Trackable Item is NUll)
--	item_group_name          Required.
--	inventory_item_id  	 Required. ( If item group is NUll) Item Should be non trackable.
--	inventory_item_name      Required.
--	inventory_org_id         Required.
--	inventory_org_code       Required.
--      operation_flag           Required to be 'C'.(Create)
-- End of Comments --

PROCEDURE Create_Item_Composition(
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_x_ic_header_rec     IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Header_Rec_Type,
	p_x_det_tbl           IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
)

AS

CURSOR item_composition_dup(p_inventory_item_id IN NUMBER ,
                            p_master_org_id IN NUMBER)
IS
 SELECT 'x'
   FROM AHL_ITEM_COMPOSITIONS
   WHERE INVENTORY_ITEM_ID = p_inventory_item_id
   AND  INVENTORY_MASTER_ORG_ID = p_master_org_id;
   --AND TRUNC(NVL(EFFECTIVE_END_DATE,sysdate)) >= TRUNC(sysdate);

l_dummy varchar2(1);
l_item_composition_id NUMBER;
l_user_id NUMBER;

BEGIN

       SAVEPOINT  Create_Item_Composition;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Composition', 'Begin of Create_Item_Composition');
END IF;



Validate_InventoryID(p_x_ic_header_rec.INVENTORY_ITEM_ID  ,
                               p_x_ic_header_rec.INVENTORY_ORG_ID ,
                               'HEADER',
                               p_x_ic_header_rec.INVENTORY_MASTER_ORG_ID
                               ) ;

OPEN item_composition_dup(p_x_ic_header_rec.INVENTORY_ITEM_ID,
                          p_x_ic_header_rec.INVENTORY_MASTER_ORG_ID);
FETCH item_composition_dup INTO l_dummy;
IF item_composition_dup%FOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_EXISTS');
        FND_MESSAGE.Set_Token('INV_ITEM',p_x_ic_header_rec.inventory_item_name);
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

CLOSE item_composition_dup;


  Select AHL_ITEM_COMPOSITIONS_S.NEXTVAL
  INTO l_item_composition_id
  FROM DUAL;

l_user_id := to_number(fnd_global.USER_ID);

INSERT INTO AHL_ITEM_COMPOSITIONS(
	ITEM_COMPOSITION_ID    ,
	INVENTORY_ITEM_ID      ,
	INVENTORY_MASTER_ORG_ID,
	DRAFT_FLAG             ,
	APPROVAL_STATUS_CODE   ,
	EFFECTIVE_END_DATE     ,
	LINK_COMP_ID           ,
	LAST_UPDATE_DATE       ,
	LAST_UPDATED_BY        ,
	CREATION_DATE          ,
	CREATED_BY             ,
	LAST_UPDATE_LOGIN      ,
	OBJECT_VERSION_NUMBER  ,
	SECURITY_GROUP_ID      ,
	ATTRIBUTE_CATEGORY     ,
	ATTRIBUTE1             ,
	ATTRIBUTE2             ,
	ATTRIBUTE3             ,
	ATTRIBUTE4             ,
	ATTRIBUTE5             ,
	ATTRIBUTE6             ,
	ATTRIBUTE7             ,
	ATTRIBUTE8             ,
	ATTRIBUTE9             ,
	ATTRIBUTE10            ,
	ATTRIBUTE11            ,
	ATTRIBUTE12            ,
	ATTRIBUTE13            ,
	ATTRIBUTE14            ,
	ATTRIBUTE15            )

	VALUES
	(
	 l_item_composition_id,
	 p_x_ic_header_rec.INVENTORY_ITEM_ID  ,
	 p_x_ic_header_rec.INVENTORY_MASTER_ORG_ID,
	 'N',
	 'DRAFT',
	 NULL,
	 NULL,
	 sysdate,
	 l_user_id,
	 sysdate,
	 l_user_id ,
	 to_number(fnd_global.LOGIN_ID) ,
	 1	,
	 NULL,
	 p_x_ic_header_rec.ATTRIBUTE_CATEGORY,
	 p_x_ic_header_rec.ATTRIBUTE1,
	 p_x_ic_header_rec.ATTRIBUTE2,
	 p_x_ic_header_rec.ATTRIBUTE3,
	 p_x_ic_header_rec.ATTRIBUTE4,
	 p_x_ic_header_rec.ATTRIBUTE5,
	 p_x_ic_header_rec.ATTRIBUTE6,
	 p_x_ic_header_rec.ATTRIBUTE7,
	 p_x_ic_header_rec.ATTRIBUTE8,
	 p_x_ic_header_rec.ATTRIBUTE9,
	 p_x_ic_header_rec.ATTRIBUTE10,
	 p_x_ic_header_rec.ATTRIBUTE11,
	 p_x_ic_header_rec.ATTRIBUTE12,
	 p_x_ic_header_rec.ATTRIBUTE13,
	 p_x_ic_header_rec.ATTRIBUTE14,
	 p_x_ic_header_rec.ATTRIBUTE15);


-- Validate the Item Composition Details

FOR I IN 1..p_x_det_tbl.count
LOOP


Validate_Item_Comp_Det( p_item_composition_id => p_x_ic_header_rec.item_composition_id ,
                        p_inv_item_name  => p_x_ic_header_rec.inventory_item_name,
                        p_x_Detail_Rec_Type => p_x_det_tbl(I)
                                  );

x_msg_count := FND_MSG_PUB.count_msg;

IF  x_msg_count = 0 THEN

Create_Line_Item (p_item_composition_id => l_item_composition_id,
		p_x_comp_det_rec => p_x_det_tbl(I)
);

END IF;

END LOOP;


  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;


	 p_x_ic_header_rec.ITEM_COMPOSITION_ID := l_item_composition_id;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Composition', 'End of Create_Item_Composition');
END IF;


 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Create_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Composition', 'Error in Create_Item_Composition');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Create_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Composition', 'Unexpected Error in Create_Item_Composition');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Create_Item_Composition;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Create_Item_Composition',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Composition', 'Unknown Error in Create_Item_Composition');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Composition', SQLERRM);

  END IF;


END Create_Item_Composition;

-- Start of Comments --
--  Procedure name    : Modify_Item_Composition
--  Type        : Private
--  Function    : Modifies Item Composition for Trackable Items in ahl_item_compositions.
--                Also creates,modifies item-group and Non-Trackable Item  association in ahl_comp_details table.
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
--  Item Header Composition Record :
--	inventory_item_id        required.
--	inventory_item_name      required.
--	inventory_org_id         required.
--	inventory_org_code       required.
--      operation_flag           required to be 'M'.(Create)
--  Item Associations Record :
--	item_group_id  	         Required. ( If inventory_item_id Non Trackable Item is NUll)
--	item_group_name          Required.
--	inventory_item_id  	 Required. ( If item group is NUll) Item Should be non trackable.
--	inventory_item_name      Required.
--	inventory_org_id         Required.
--	inventory_org_code       Required.
--      operation_flag           Required to be 'C'.(Create)
-- End of Comments --

PROCEDURE Modify_Item_Composition(
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_x_ic_header_rec     IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Header_Rec_Type,
	p_x_det_tbl           IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
)

AS

CURSOR item_composition_det(p_item_composition_id IN NUMBER)
IS
 SELECT
	item_composition_id    ,
	inventory_item_id      ,
	inventory_master_org_id,
	draft_flag             ,
	approval_status_code   ,
	effective_end_date     ,
	link_comp_id           ,
	last_update_date       ,
	last_updated_by        ,
	creation_date          ,
	created_by             ,
	last_update_login      ,
	object_version_number  ,
	security_group_id      ,
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
   FROM AHL_ITEM_COMPOSITIONS
   WHERE ITEM_COMPOSITION_ID = p_item_composition_id;

l_dummy varchar2(1);

l_item_composition_rec item_composition_det%ROWTYPE;

BEGIN

       SAVEPOINT  Modify_Item_Composition;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Modify_Item_Composition', 'Begin of Modify_Item_Composition');
END IF;


OPEN item_composition_det(p_x_ic_header_rec.item_composition_id
                          );
FETCH item_composition_det INTO l_item_composition_rec;
IF item_composition_det%NOTFOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_NOT_EXISTS');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

CLOSE item_composition_det;


IF l_item_composition_rec.object_version_number <>  p_x_ic_header_rec.object_version_number THEN
        FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;


IF l_item_composition_rec.approval_status_code NOT IN ('DRAFT','APPROVAL_REJECTED') THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_STATUS_NO_EDIT');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;


IF (l_item_composition_rec.approval_status_code = 'APPROVAL_REJECTED') THEN
l_item_composition_rec.approval_status_code := 'DRAFT';
END IF;



UPDATE AHL_ITEM_COMPOSITIONS
SET
	APPROVAL_STATUS_CODE  = l_item_composition_rec.approval_status_code ,
	LAST_UPDATE_DATE      = sysdate,
	LAST_UPDATED_BY        = to_number(fnd_global.USER_ID),
	LAST_UPDATE_LOGIN     =to_number(fnd_global.LOGIN_ID) ,
	OBJECT_VERSION_NUMBER  = OBJECT_VERSION_NUMBER+1,
	SECURITY_GROUP_ID      =NULL,
	ATTRIBUTE_CATEGORY     = p_x_ic_header_rec.ATTRIBUTE_CATEGORY,
	ATTRIBUTE1             = p_x_ic_header_rec.ATTRIBUTE1,
	ATTRIBUTE2             = p_x_ic_header_rec.ATTRIBUTE2,
	ATTRIBUTE3             = p_x_ic_header_rec.ATTRIBUTE3,
	ATTRIBUTE4             = p_x_ic_header_rec.ATTRIBUTE4,
	ATTRIBUTE5             = p_x_ic_header_rec.ATTRIBUTE5,
	ATTRIBUTE6             = p_x_ic_header_rec.ATTRIBUTE6,
	ATTRIBUTE7             = p_x_ic_header_rec.ATTRIBUTE7,
	ATTRIBUTE8             = p_x_ic_header_rec.ATTRIBUTE8,
	ATTRIBUTE9             = p_x_ic_header_rec.ATTRIBUTE9,
	ATTRIBUTE10            = p_x_ic_header_rec.ATTRIBUTE10,
	ATTRIBUTE11            = p_x_ic_header_rec.ATTRIBUTE11,
	ATTRIBUTE12            = p_x_ic_header_rec.ATTRIBUTE12,
	ATTRIBUTE13            = p_x_ic_header_rec.ATTRIBUTE13,
	ATTRIBUTE14            = p_x_ic_header_rec.ATTRIBUTE14,
	ATTRIBUTE15            = p_x_ic_header_rec.ATTRIBUTE15
  WHERE  ITEM_COMPOSITION_ID = 	 p_x_ic_header_rec.ITEM_COMPOSITION_ID
  AND OBJECT_VERSION_NUMBER =  	 p_x_ic_header_rec.object_version_number;


-- Validate the Item Composition Details

FOR I IN p_x_det_tbl.FIRST..p_x_det_tbl.LAST
LOOP

Validate_Item_Comp_Det( p_item_composition_id => p_x_ic_header_rec.item_composition_id ,
			P_inv_item_name => p_x_ic_header_rec.inventory_item_name,
                        p_x_Detail_Rec_Type => p_x_det_tbl(I)
                                  );

x_msg_count := FND_MSG_PUB.count_msg;

IF x_msg_count = 0 THEN

	IF p_x_det_tbl(I).operation_flag = 'C' THEN

	Create_Line_Item (p_item_composition_id => p_x_ic_header_rec.ITEM_COMPOSITION_ID,
			p_x_comp_det_rec => p_x_det_tbl(I)
	);

	ELSIF p_x_det_tbl(I).operation_flag = 'M' THEN

	Update_Line_Item (p_item_composition_id => p_x_ic_header_rec.ITEM_COMPOSITION_ID,
			p_x_comp_det_rec => p_x_det_tbl(I)
	);


	ELSIF p_x_det_tbl(I).operation_flag = 'D' THEN

	Delete_Line_Item (p_item_composition_id => p_x_ic_header_rec.ITEM_COMPOSITION_ID,
			p_x_comp_det_rec => p_x_det_tbl(I)
	);

	END IF;

END IF;

END LOOP;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;


IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Modify_Item_Composition', 'End of Modify_Item_Composition');
END IF;



 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Modify_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Modify_Item_Composition', 'Error in Modify_Item_Composition');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Modify_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Modify_Item_Composition', 'Unexpected Error in Modify_Item_Composition');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Modify_Item_Composition;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Modify_Item_Composition',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Modify_Item_Composition', 'Unknown Error in Modify_Item_Composition');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Modify_Item_Composition', SQLERRM);

  END IF;

END Modify_Item_Composition;

-- Start of Comments --
--  Procedure name    : Delete_Item_Composition
--  Type        : Private
--  Function    : Deletes Item Composition for Trackable Items in ahl_item_compositions.
--                Also deletes association in ahl_comp_details table.
--                Incase of Complete status Item Composition it Expires it.
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
--  Item Header Composition Record :
--       p_item_composition_ID  Required
--       p_object_version_number Required.
-- End of Comments --

PROCEDURE Delete_Item_Composition (
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_item_composition_ID IN NUMBER ,
	p_object_version_number IN NUMBER
)

AS

CURSOR item_composition_det(p_item_composition_id IN NUMBER)
IS
 SELECT
	item_composition_id    ,
	inventory_item_id      ,
	inventory_master_org_id,
	draft_flag             ,
	approval_status_code   ,
	effective_end_date     ,
	link_comp_id           ,
	last_update_date       ,
	last_updated_by        ,
	creation_date          ,
	created_by             ,
	last_update_login      ,
	object_version_number  ,
	security_group_id      ,
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
   FROM AHL_ITEM_COMPOSITIONS
   WHERE ITEM_COMPOSITION_ID = p_item_composition_id;

CURSOR disposition_exist(p_item_composition_id IN NUMBER)
IS
 -- Modified Cursor Below for Perf Fix - Bug 4913935
 -- SELECT  'x'
 -- FROM    ahl_route_effectivities_v
 -- WHERE   ITEM_COMPOSITION_ID = p_item_composition_id;
 SELECT 'x'
  FROM ahl_route_effectivities re, AHL_ITEM_COMP_V icd
 WHERE icd.ITEM_COMPOSITION_ID = p_item_composition_id
   AND re.inventory_item_id = ICD.inventory_item_id
   AND re.INVENTORY_MASTER_ORG_ID = ICD.INVENTORY_MASTER_ORG_ID
   AND ICD.APPROVAL_STATUS_CODE = 'COMPLETE';

 CURSOR item_rev_exists(p_item_composition_id IN NUMBER)
 IS
   SELECT item_composition_id
   FROM   AHL_ITEM_COMPOSITIONS
   WHERE  link_comp_id = p_item_composition_id;


l_dummy varchar2(1);
l_rev_item_composition_id NUMBER;

l_item_composition_rec item_composition_det%ROWTYPE;

BEGIN

       SAVEPOINT  Delete_Item_Composition;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Delete_Item_Composition', 'Begin of Delete_Item_Composition');
END IF;


OPEN item_composition_det(p_item_composition_id
                          );
FETCH item_composition_det INTO l_item_composition_rec;
IF item_composition_det%NOTFOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_NOT_EXISTS');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

CLOSE item_composition_det;


IF l_item_composition_rec.object_version_number <>  p_object_version_number THEN
        FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;


IF l_item_composition_rec.approval_status_code = 'APPROVAL_PENDING' THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_STATUS_NO_DELETE');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;


-- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;


IF  l_item_composition_rec.approval_status_code = 'COMPLETE' THEN

OPEN disposition_exist(p_item_composition_id
                          );
FETCH disposition_exist INTO l_dummy;
IF disposition_exist%FOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_DISP_EXISTS');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

CLOSE disposition_exist;

OPEN item_rev_exists(p_item_composition_id);
FETCH item_rev_exists INTO l_rev_item_composition_id;
IF item_rev_exists%FOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_REV_EXISTS');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;
CLOSE item_rev_exists;


IF l_item_composition_rec.effective_end_date IS NOT NULL AND
   TRUNC(l_item_composition_rec.effective_end_date) <= TRUNC(SYSDATE) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_COMP_STATUS_NO_DELETE');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;



UPDATE AHL_ITEM_COMPOSITIONS
SET
	LAST_UPDATE_DATE      = sysdate,
	LAST_UPDATED_BY        = to_number(fnd_global.USER_ID),
	LAST_UPDATE_LOGIN     =to_number(fnd_global.LOGIN_ID) ,
	OBJECT_VERSION_NUMBER  = OBJECT_VERSION_NUMBER+1,
	SECURITY_GROUP_ID      =NULL,
        EFFECTIVE_END_DATE     = sysdate -1
  WHERE  ITEM_COMPOSITION_ID = 	 p_item_composition_ID
  AND OBJECT_VERSION_NUMBER =  	 p_object_version_number;


ELSIF l_item_composition_rec.approval_status_code IN ('DRAFT','APPROVAL_REJECTED') THEN


DELETE FROM AHL_ITEM_COMP_DETAILS
WHERE ITEM_COMPOSITION_ID = p_item_composition_id;

DELETE FROM AHL_ITEM_COMPOSITIONS
WHERE ITEM_COMPOSITION_ID = p_item_composition_id;

END IF;



IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Delete_Item_Composition', 'End of Delete_Item_Composition');
END IF;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Delete_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Delete_Item_Composition', 'Error in Delete_Item_Composition');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Delete_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Delete_Item_Composition', 'Unexpected Error in Delete_Item_Composition');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Delete_Item_Composition;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Delete_Item_Composition',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Delete_Item_Composition', 'Unknown Error in Delete_Item_Composition');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Delete_Item_Composition', SQLERRM);

  END IF;


END Delete_Item_Composition;


-- Start of Comments --
--  Procedure name    : Reopen_Item_Composition
--  Type        : Private
--  Function    : Re-Open'ss Item Composition for Trackable Items in ahl_item_compositions.
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
--  Item Header Composition Record :
--       p_item_composition_ID  Required
--       p_object_version_number Required.
-- End of Comments --

PROCEDURE Reopen_Item_Composition (
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_item_composition_ID IN NUMBER ,
	p_object_version_number IN NUMBER

)

AS

CURSOR item_composition_det(p_item_composition_id IN NUMBER)
IS
 SELECT
	item_composition_id    ,
	inventory_item_id      ,
	inventory_master_org_id,
	draft_flag             ,
	approval_status_code   ,
	effective_end_date     ,
	link_comp_id           ,
	last_update_date       ,
	last_updated_by        ,
	creation_date          ,
	created_by             ,
	last_update_login      ,
	object_version_number  ,
	security_group_id      ,
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
   FROM AHL_ITEM_COMPOSITIONS
   WHERE ITEM_COMPOSITION_ID = p_item_composition_id;

/*
   CURSOR item_composition_exists(p_inv_item_id IN NUMBER,
				p_inv_master_org_id IN NUMBER)
   IS
   SELECT 'x'
   FROM   AHL_ITEM_COMPOSITIONS
   WHERE inventory_item_id = p_inv_item_id
   AND   inventory_master_org_id = p_inv_master_org_id
   AND TRUNC(NVL(EFFECTIVE_END_DATE,sysdate)) >= TRUNC(sysdate);
*/

l_dummy varchar2(1);

l_item_composition_rec item_composition_det%ROWTYPE;


BEGIN

       SAVEPOINT  Reopen_Item_Composition;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Reopen_Item_Composition', 'Begin of Reopen_Item_Composition');
END IF;

OPEN item_composition_det(p_item_composition_ID);
FETCH item_composition_det INTO l_item_composition_rec;
IF item_composition_det%NOTFOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_NOT_EXISTS');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

CLOSE item_composition_det;


IF l_item_composition_rec.object_version_number <>  p_object_version_number THEN
        FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

/*
OPEN item_composition_exists(l_item_composition_rec.inventory_item_id,
				l_item_composition_rec.inventory_master_org_id);
FETCH item_composition_exists INTO l_dummy;
IF item_composition_exists%FOUND THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_EXISTS');
        FND_MESSAGE.Set_Token('INV_ITEM',p_x_ic_header_rec.inventory_item_id);
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;

CLOSE item_composition_exists;
*/


IF NVL(l_item_composition_rec.effective_end_date,TRUNC(SYSDATE)) >= TRUNC(SYSDATE) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_ITEM_COMP_OPEN');
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
END IF;


-- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;



UPDATE AHL_ITEM_COMPOSITIONS
SET
	LAST_UPDATE_DATE      = sysdate,
	LAST_UPDATED_BY        = to_number(fnd_global.USER_ID),
	LAST_UPDATE_LOGIN     =to_number(fnd_global.LOGIN_ID) ,
	OBJECT_VERSION_NUMBER  = OBJECT_VERSION_NUMBER+1,
	SECURITY_GROUP_ID      =NULL,
        EFFECTIVE_END_DATE     = null
  WHERE  ITEM_COMPOSITION_ID = 	 p_item_composition_ID
  AND OBJECT_VERSION_NUMBER =  	 p_object_version_number;


-- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;


 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Reopen_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Reopen_Item_Composition', 'Error in Reopen_Item_Composition');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Reopen_Item_Composition;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Reopen_Item_Composition', 'Unexpected Error in Reopen_Item_Composition');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Reopen_Item_Composition;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Reopen_Item_Composition',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Reopen_Item_Composition', 'Unknown Error in Reopen_Item_Composition');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Reopen_Item_Composition', SQLERRM);
  END IF;


END Reopen_Item_Composition;



PROCEDURE Create_Line_Item (p_item_composition_id IN NUMBER,
	p_x_comp_det_rec IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Detail_Rec_Type
)

AS

l_item_comp_detail_id NUMBER;
l_user_id NUMBER;

BEGIN

SELECT AHL_ITEM_COMP_DETAILS_S.NEXTVAL
INTO  l_item_comp_detail_id
FROM DUAL;

l_user_id := to_number(fnd_global.USER_ID);

IF p_item_composition_id IS NOT NULL THEN

	INSERT INTO AHL_ITEM_COMP_DETAILS(
		ITEM_COMP_DETAIL_ID    ,
		ITEM_COMPOSITION_ID    ,
		ITEM_GROUP_ID          ,
		INVENTORY_ITEM_ID      ,
		INVENTORY_MASTER_ORG_ID,
		UOM_CODE                    ,
		QUANTITY               ,
		EFFECTIVE_END_DATE     ,
		LINK_COMP_DETL_ID      ,
		LAST_UPDATE_DATE       ,
		LAST_UPDATED_BY        ,
		CREATION_DATE          ,
		CREATED_BY             ,
		LAST_UPDATE_LOGIN      ,
		OBJECT_VERSION_NUMBER  ,
		SECURITY_GROUP_ID      ,
		ATTRIBUTE_CATEGORY     ,
		ATTRIBUTE1             ,
		ATTRIBUTE2             ,
		ATTRIBUTE3             ,
		ATTRIBUTE4             ,
		ATTRIBUTE5             ,
		ATTRIBUTE6             ,
		ATTRIBUTE7             ,
		ATTRIBUTE8             ,
		ATTRIBUTE9             ,
		ATTRIBUTE10            ,
		ATTRIBUTE11            ,
		ATTRIBUTE12            ,
		ATTRIBUTE13            ,
		ATTRIBUTE14            ,
		ATTRIBUTE15            )

	VALUES
	(
		l_item_comp_detail_id  ,
		p_item_composition_id ,
		p_x_comp_det_rec.ITEM_GROUP_ID  ,
		p_x_comp_det_rec.INVENTORY_ITEM_ID  ,
		p_x_comp_det_rec.INVENTORY_MASTER_ORG_ID,
		p_x_comp_det_rec.UOM_CODE                    ,
		p_x_comp_det_rec.QUANTITY               ,
		NULL ,
		NULL,
		sysdate,
		l_user_id        ,
		sysdate,
		l_user_id,
		to_number(fnd_global.LOGIN_ID),
		1,
		NULL,
		p_x_comp_det_rec.ATTRIBUTE_CATEGORY     ,
		p_x_comp_det_rec.ATTRIBUTE1             ,
		p_x_comp_det_rec.ATTRIBUTE2             ,
		p_x_comp_det_rec.ATTRIBUTE3             ,
		p_x_comp_det_rec.ATTRIBUTE4             ,
		p_x_comp_det_rec.ATTRIBUTE5             ,
		p_x_comp_det_rec.ATTRIBUTE6             ,
		p_x_comp_det_rec.ATTRIBUTE7             ,
		p_x_comp_det_rec.ATTRIBUTE8             ,
		p_x_comp_det_rec.ATTRIBUTE9             ,
		p_x_comp_det_rec.ATTRIBUTE10            ,
		p_x_comp_det_rec.ATTRIBUTE11            ,
		p_x_comp_det_rec.ATTRIBUTE12            ,
		p_x_comp_det_rec.ATTRIBUTE13            ,
		p_x_comp_det_rec.ATTRIBUTE14            ,
		p_x_comp_det_rec.ATTRIBUTE15
	) RETURNING
		ITEM_COMP_DETAIL_ID    ,
		ITEM_COMPOSITION_ID
	  INTO
	        p_x_comp_det_rec.ITEM_COMP_DETAIL_ID,
	        p_x_comp_det_rec.ITEM_COMPOSITION_ID
	  ;

END IF;



END;


PROCEDURE Update_Line_Item (p_item_composition_id IN NUMBER,
	p_x_comp_det_rec IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Detail_Rec_Type
)

AS

BEGIN

	UPDATE AHL_ITEM_COMP_DETAILS
	SET
		ITEM_GROUP_ID           =p_x_comp_det_rec.ITEM_GROUP_ID,
		INVENTORY_ITEM_ID       =p_x_comp_det_rec.INVENTORY_ITEM_ID,
		INVENTORY_MASTER_ORG_ID = p_x_comp_det_rec.INVENTORY_MASTER_ORG_ID,
		UOM_CODE                =p_x_comp_det_rec.UOM_CODE    ,
		QUANTITY                =p_x_comp_det_rec.QUANTITY,
		LAST_UPDATE_DATE       =sysdate,
		LAST_UPDATED_BY        = to_number(fnd_global.USER_ID),
		LAST_UPDATE_LOGIN      = to_number(fnd_global.LOGIN_ID),
		OBJECT_VERSION_NUMBER  =object_version_number+1,
		SECURITY_GROUP_ID      =NULL,
		ATTRIBUTE_CATEGORY     =p_x_comp_det_rec.ATTRIBUTE_CATEGORY,
		ATTRIBUTE1             =p_x_comp_det_rec.ATTRIBUTE1,
		ATTRIBUTE2             =p_x_comp_det_rec.ATTRIBUTE2,
		ATTRIBUTE3             =p_x_comp_det_rec.ATTRIBUTE3,
		ATTRIBUTE4             =p_x_comp_det_rec.ATTRIBUTE4,
		ATTRIBUTE5             =p_x_comp_det_rec.ATTRIBUTE5,
		ATTRIBUTE6             =p_x_comp_det_rec.ATTRIBUTE6,
		ATTRIBUTE7             =p_x_comp_det_rec.ATTRIBUTE7,
		ATTRIBUTE8             =p_x_comp_det_rec.ATTRIBUTE8,
		ATTRIBUTE9             =p_x_comp_det_rec.ATTRIBUTE9,
		ATTRIBUTE10            =p_x_comp_det_rec.ATTRIBUTE10,
		ATTRIBUTE11            =p_x_comp_det_rec.ATTRIBUTE11,
		ATTRIBUTE12            =p_x_comp_det_rec.ATTRIBUTE12,
		ATTRIBUTE13            =p_x_comp_det_rec.ATTRIBUTE13,
		ATTRIBUTE14            =p_x_comp_det_rec.ATTRIBUTE14,
		ATTRIBUTE15            =p_x_comp_det_rec.ATTRIBUTE15
		WHERE
		ITEM_COMP_DETAIL_ID  =  p_x_comp_det_rec.item_comp_detail_id
		AND ITEM_COMPOSITION_ID  =  p_item_composition_id ;


END Update_Line_Item;



PROCEDURE Delete_Line_Item (p_item_composition_id IN NUMBER,
	p_x_comp_det_rec IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Detail_Rec_Type
)

AS

BEGIN

DELETE FROM AHL_ITEM_COMP_DETAILS
WHERE ITEM_COMP_DETAIL_ID = p_x_comp_det_rec.item_comp_detail_id
AND ITEM_COMPOSITION_ID = p_item_composition_id;


END Delete_Line_Item;



-- Start of Comments --
--  Procedure name    : Initiate_Item_Comp_Approval
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
--      Item_Composition_id            Required.
--      Object_version_number    Required.
--      Approval type            Required.
--
--  Enhancement 115.10
-- End of Comments --
PROCEDURE Initiate_Item_Comp_Approval (
	p_api_version           IN NUMBER,
	p_init_msg_list         IN VARCHAR2  := FND_API.G_FALSE,
	p_commit                IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status         OUT NOCOPY        VARCHAR2,
	x_msg_count             OUT NOCOPY        NUMBER,
	x_msg_data              OUT NOCOPY        VARCHAR2,
	p_Item_Composition_id   IN NUMBER,
	p_object_version_number IN NUMBER,
        p_approval_type         IN         VARCHAR2
)


 IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Initiate_Item_Comp_Approval';
  l_api_version CONSTANT NUMBER       := 1.0;

 l_counter    NUMBER:=0;
 l_status     VARCHAR2(30);
 l_object           VARCHAR2(30):='ICWF';
 l_approval_type    VARCHAR2(100):='CONCEPT';
 l_active           VARCHAR2(50) := 'N';
 l_process_name     VARCHAR2(50);
 l_item_type        VARCHAR2(50);
 l_return_status    VARCHAR2(50);
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(2000);
 l_activity_id      NUMBER:=p_Item_Composition_id;
 l_Status           VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_object_Version_number  NUMBER:=nvl(p_object_Version_number,0);

 l_upd_status    VARCHAR2(50);
 l_rev_status    VARCHAR2(50);
 l_approval_status VARCHAR2(30) := 'APPROVED';



 CURSOR get_Item_comp_Det(c_item_comp_id NUMBER)
 is
 Select item_composition_id,
 	approval_status_code,
	object_version_number,
	concatenated_segments
 From   ahl_item_comp_v
 Where  item_composition_id = c_item_comp_id;



 l_item_comp_rec   get_Item_comp_Det%rowtype;


 l_msg         VARCHAR2(30);
 l_dummy  VARCHAR2(1);
 l_count  NUMBER ;


BEGIN
       SAVEPOINT  Initiate_Item_Comp_Approval;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    	   THEN
    	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'Begin Initiate_Item_Comp_Approval');
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

        Select count(*)
          into l_count
          from ahl_item_comp_details
         where item_composition_id = p_Item_Composition_id;


        IF p_object_Version_number is null or p_object_Version_number=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJ_VERSION_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_Item_Composition_id is null or p_Item_Composition_id = FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJECT_ID_NULL');
                FND_MSG_PUB.ADD;
        ELSE

                OPEN get_Item_comp_Det(p_Item_Composition_id);
                FETCH get_Item_comp_Det INTO l_item_comp_rec;
                CLOSE get_Item_comp_Det;


		select count(*)
		  into l_count
	          from ahl_item_comp_details
	         where item_composition_id = p_Item_Composition_id;

		 IF l_count < 1 THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_MC_IC_EMPTY');
			FND_MESSAGE.Set_Token('ITEM_COMP',l_item_comp_rec.concatenated_segments);
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		 END IF;


                IF p_approval_type = 'APPROVE'
                THEN
                        IF l_item_comp_rec.approval_status_code='DRAFT' or
                           l_item_comp_rec.approval_status_code='APPROVAL_REJECTED'
                        THEN
                                l_upd_status := 'APPROVAL_PENDING';
                        ELSE
                                FND_MESSAGE.SET_NAME('AHL','AHL_MC_IC_STAT_NOT_DRFT');
                                FND_MSG_PUB.ADD;
                        END IF;
                ELSE
			FND_MESSAGE.SET_NAME('AHL','AHL_APPR_TYPE_CODE_MISSING');
			FND_MSG_PUB.ADD;
	        END IF;

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
	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'Updating Item group');
END IF;

               Update  ahl_item_compositions
               Set APPROVAL_STATUS_CODE=l_upd_status,
               OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
               Where ITEM_COMPOSITION_ID = p_Item_Composition_id
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
    	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'Calling ahl_generic_aprv_pvt.start_wf_process');
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
			ahl_mc_item_comp_pvt.approve_item_composiiton
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
			 p_appr_status               =>l_approval_status,
			 P_ITEM_COMP_ID                  =>p_Item_Composition_id,
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
    	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'End of Initiate_Item_Comp_Approval');
END IF;



 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Initiate_Item_Comp_Approval;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'Error in Initiate_Item_Comp_Approval');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Initiate_Item_Comp_Approval;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'Unexpected Error in Initiate_Item_Comp_Approval');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Initiate_Item_Comp_Approval;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Initiate_Item_Comp_Approval',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', 'Unknown Error in Initiate_Item_Comp_Approval');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.'||G_PKG_NAME||'.Initiate_Item_Comp_Approval', SQLERRM);

  END IF;


END Initiate_Item_Comp_Approval;


-- Start of Comments --
--  Procedure name    : Create_Item_Comp_Revision
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

--      Item_Comp_id            Required.
--      Object_version_number    Required.
--  Enhancement 115.10
--
-- End of Comments --

PROCEDURE Create_Item_Comp_Revision (
    p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN         VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN         NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_DEFAULT               IN         VARCHAR2  := FND_API.G_FALSE,
    P_MODULE_TYPE           IN         VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_Item_comp_id   IN         NUMBER,
    p_object_version_number IN         NUMBER,
    x_Item_comp_id          OUT NOCOPY NUMBER
) AS

 cursor get_item_comp_det(c_item_comp_id in Number)
 Is
 Select
        item_composition_id,
        approval_status_code,
        draft_flag,
        inventory_item_id,
	inventory_master_org_id,
        effective_end_date,
        object_version_number
 from   ahl_item_compositions
 Where item_composition_id = c_item_comp_id;

 l_item_comp_det  get_item_comp_det%rowtype;


 cursor get_revision_info(c_item_comp_id in Number)
 is
 Select 'x'
 from   ahl_item_compositions
 where  link_comp_id = c_item_comp_id;

	l_dummy VARCHAR2(1);
	l_msg_count Number;
	l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
	l_item_comp_id Number;
	l_last_update_login NUMBER;
	l_last_updated_by   NUMBER;
	l_rowid             UROWID;
	l_item_composition_id NUMBER;
	l_created_by NUMBER;

BEGIN


       SAVEPOINT  Create_Item_Comp_Revision;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    	   THEN
    	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision', 'Begin of Create_Item_Comp_Revision');
END IF;



 OPEN get_item_comp_det(p_Item_comp_id);
 Fetch get_item_comp_det into l_item_comp_det;
 IF get_item_comp_det%NOTFOUND THEN
	FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJECT_ID_NULL');
	FND_MSG_PUB.ADD;
 END IF;
 close get_item_comp_det;


 IF l_item_comp_det.approval_status_code <> 'COMPLETE'
 	OR l_item_comp_det.effective_end_date IS NOT NULL
 THEN
	FND_MESSAGE.SET_NAME('AHL','AHL_MC_IC_STAT_NOT_COMP');
	FND_MSG_PUB.ADD;
 END IF;


 IF l_item_comp_det.object_version_number <> p_object_version_number
 THEN
	FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
	FND_MSG_PUB.ADD;
 END IF;


 OPEN get_revision_info(p_Item_comp_id);
 FETCH get_revision_info INTO l_dummy;
 IF get_revision_info%FOUND THEN
 	FND_MESSAGE.SET_NAME('AHL','AHL_MC_IC_REVISION_EXIST');
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


 l_last_updated_by := to_number(fnd_global.USER_ID);
 l_last_update_login := to_number(fnd_global.LOGIN_ID);
 l_created_by := to_number(fnd_global.user_id);


  Select AHL_ITEM_COMPOSITIONS_S.NEXTVAL
  INTO l_item_composition_id
  FROM DUAL;


INSERT INTO AHL_ITEM_COMPOSITIONS(
	ITEM_COMPOSITION_ID    ,
	INVENTORY_ITEM_ID      ,
	INVENTORY_MASTER_ORG_ID,
	DRAFT_FLAG             ,
	APPROVAL_STATUS_CODE   ,
	EFFECTIVE_END_DATE     ,
	LINK_COMP_ID           ,
	LAST_UPDATE_DATE       ,
	LAST_UPDATED_BY        ,
	CREATION_DATE          ,
	CREATED_BY             ,
	LAST_UPDATE_LOGIN      ,
	OBJECT_VERSION_NUMBER  ,
	SECURITY_GROUP_ID      ,
	ATTRIBUTE_CATEGORY     ,
	ATTRIBUTE1             ,
	ATTRIBUTE2             ,
	ATTRIBUTE3             ,
	ATTRIBUTE4             ,
	ATTRIBUTE5             ,
	ATTRIBUTE6             ,
	ATTRIBUTE7             ,
	ATTRIBUTE8             ,
	ATTRIBUTE9             ,
	ATTRIBUTE10            ,
	ATTRIBUTE11            ,
	ATTRIBUTE12            ,
	ATTRIBUTE13            ,
	ATTRIBUTE14            ,
	ATTRIBUTE15            )

SELECT l_item_composition_id,
	inventory_item_id      ,
	inventory_master_org_id,
	draft_flag             ,
	'DRAFT'   ,
	effective_end_date     ,
	p_Item_comp_id           ,
	sysdate       ,
	l_last_updated_by        ,
	sysdate          ,
	l_created_by             ,
	l_last_update_login      ,
	1  ,
	security_group_id      ,
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
FROM   ahl_item_compositions
WHERE item_composition_id = p_Item_comp_id
AND   object_version_number = p_object_version_number
AND   effective_end_date is null;



x_Item_comp_id := l_item_composition_id;




IF p_Item_comp_id IS NOT NULL THEN

	INSERT INTO AHL_ITEM_COMP_DETAILS(
		ITEM_COMP_DETAIL_ID    ,
		ITEM_COMPOSITION_ID    ,
		ITEM_GROUP_ID          ,
		INVENTORY_ITEM_ID      ,
		INVENTORY_MASTER_ORG_ID,
		UOM_CODE                    ,
		QUANTITY               ,
		EFFECTIVE_END_DATE     ,
		LINK_COMP_DETL_ID      ,
		LAST_UPDATE_DATE       ,
		LAST_UPDATED_BY        ,
		CREATION_DATE          ,
		CREATED_BY             ,
		LAST_UPDATE_LOGIN      ,
		OBJECT_VERSION_NUMBER  ,
		SECURITY_GROUP_ID      ,
		ATTRIBUTE_CATEGORY     ,
		ATTRIBUTE1             ,
		ATTRIBUTE2             ,
		ATTRIBUTE3             ,
		ATTRIBUTE4             ,
		ATTRIBUTE5             ,
		ATTRIBUTE6             ,
		ATTRIBUTE7             ,
		ATTRIBUTE8             ,
		ATTRIBUTE9             ,
		ATTRIBUTE10            ,
		ATTRIBUTE11            ,
		ATTRIBUTE12            ,
		ATTRIBUTE13            ,
		ATTRIBUTE14            ,
		ATTRIBUTE15            )

 SELECT       	AHL_ITEM_COMP_DETAILS_S.NEXTVAL ,
		l_item_composition_id    ,
		item_group_id          ,
		inventory_item_id      ,
		inventory_master_org_id,
		uom_code                    ,
		quantity               ,
		effective_end_date     ,
		item_comp_detail_id      ,
		sysdate       ,
		l_last_updated_by        ,
		sysdate          ,
		l_created_by             ,
		l_last_update_login      ,
		1  ,
		security_group_id      ,
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
FROM ahl_item_comp_details
WHERE item_composition_id = p_Item_comp_id
AND   effective_end_date is null;

END IF;

	UPDATE ahl_item_compositions
	SET 	DRAFT_FLAG = 'Y',
		LAST_UPDATE_DATE      = sysdate,
		LAST_UPDATED_BY       = to_number(fnd_global.USER_ID),
		LAST_UPDATE_LOGIN     =to_number(fnd_global.LOGIN_ID),
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
		SECURITY_GROUP_ID     =NULL
	WHERE item_composition_id = p_Item_comp_id
	AND   object_version_number = p_object_version_number;


IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    	   THEN
    	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision', 'End of Loop');
END IF;

   -- Standard check of p_commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT WORK;
   END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision', 'End of Create_Item_Comp_Revision');
 END IF;



EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Create_Item_Comp_Revision;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision', 'Error in Create_Item_Comp_Revision');
 END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Create_Item_Comp_Revision;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision', 'Unecpected Error in Create_Item_Comp_Revision');
 END IF;


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Create_Item_Comp_Revision;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_Item_Comp_Revision',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision', 'Unknown Error in Create_Item_Comp_Revision');
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.'||G_PKG_NAME||'.Create_Item_Comp_Revision',SQLERRM );

 END IF;



END Create_Item_Comp_Revision;



-- Start of Comments --
--  Procedure name    : Approve_Item_Composiiton
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

PROCEDURE Approve_Item_Composiiton (
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
 p_Item_comp_id             IN          NUMBER,
 p_object_version_number     IN          NUMBER)

 AS

  cursor get_item_comp_det(c_item_comp_id in Number)
   Is  Select
        item_composition_id,
        approval_status_code,
        draft_flag,
        link_comp_id,
        inventory_item_id,
	inventory_master_org_id,
        effective_end_date,
        object_version_number
 from   ahl_item_compositions
 Where item_composition_id = c_item_comp_id;

 l_item_comp_det get_item_comp_det%rowType;

 type t_id is table of number index by binary_integer;
 type t_uom_code is table of varchar2(3) index by binary_integer;

l_item_group_id          t_id;
l_inventory_item_id      t_id;
l_inventory_master_org_id t_id;
l_uom_code               t_uom_code;
l_quantity               t_id;
l_link_comp_detl_id      t_id;
l_object_version_number  t_id;

 l_status VARCHAR2(30);
 l_msg_count Number;
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_rowid  urowid;
 l_action varchar2(2);


 BEGIN

       SAVEPOINT  Approve_Item_Composiiton;


   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'Begin of Approve_Item_Composiiton');
 END IF;



       OPEN get_item_comp_det(p_Item_comp_id);
       FETCH get_item_comp_det INTO l_item_comp_det;
       	IF get_item_comp_det%NOTFOUND
       	THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_MC_OBJECT_ID_NULL');
		FND_MSG_PUB.ADD;
	END IF;
       CLOSE get_item_comp_det;

       IF l_item_comp_det.object_version_number <> p_object_version_number
       THEN
	FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
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



         IF l_item_comp_det.link_comp_id IS NULL THEN

		 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
			   THEN
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'link_comp_id is null');
		 END IF;


             update  ahl_item_compositions
	        set approval_status_code=l_status,
	            object_version_number = object_version_number+1
	      where item_composition_id=l_item_comp_det.item_composition_id
	        and object_version_number = l_item_comp_det.object_version_number;

	     l_action :='C';


	 ELSE

		 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
			   THEN
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'link_comp_id is not null');
		 END IF;


		select
			item_group_id          ,
			inventory_item_id      ,
			inventory_master_org_id,
			uom_code               ,
			quantity               ,
			link_comp_detl_id      ,
			object_version_number
		bulk collect
		into
			l_item_group_id          ,
			l_inventory_item_id      ,
			l_inventory_master_org_id,
			l_uom_code               ,
			l_quantity               ,
			l_link_comp_detl_id      ,
			l_object_version_number
		from   ahl_item_comp_details
		where item_composition_id =  l_item_comp_det.item_composition_id
		and  link_comp_detl_id is not null
		and effective_end_date is null;


      FORALL I IN 1..l_object_version_number.count
      update ahl_item_comp_details set
      			uom_code               	=l_uom_code(I),
      			quantity               	=l_quantity(I),
      			last_update_date        = sysdate,
      			last_updated_by         = to_number(fnd_global.user_id),
      			last_update_login       = to_number(fnd_global.login_id),
      			object_version_number  	=l_object_version_number(I)+1
	where ITEM_COMP_DETAIL_ID  = l_link_comp_detl_id(I)
	and   item_composition_id =   l_item_comp_det.LINK_COMP_ID
	and NVL(item_group_id,-3)   = NVL(l_item_group_id(I),-3)
	and NVL(inventory_item_id,-3) = NVL(l_inventory_item_id(I),-3)
	and NVL(inventory_master_org_id,-3)= NVL(l_inventory_master_org_id(I),-3)
	and effective_end_date is null;


	Update ahl_item_comp_details
		   Set  effective_end_date = sysdate-1,
			last_update_date       =sysdate,
			last_updated_by        = to_number(fnd_global.user_id),
			last_update_login      = to_number(fnd_global.login_id),
			object_version_number  =object_version_number+1
		Where  item_composition_id=l_item_comp_det.link_comp_id
		and   effective_end_date is null
		and   ITEM_COMP_DETAIL_ID  not in (
		      Select link_comp_detl_id
		      from ahl_item_comp_details
		      where item_composition_id = l_item_comp_det.item_composition_id
		      and link_comp_detl_id is not null);


		Update ahl_item_comp_details
		   Set item_composition_id = l_item_comp_det.link_comp_id,
			last_update_date       =sysdate,
			last_updated_by        = to_number(fnd_global.user_id),
			last_update_login      = to_number(fnd_global.login_id),
			object_version_number  =object_version_number+1
		Where  item_composition_id=l_item_comp_det.item_composition_id
		and   link_comp_detl_id is null;


        Update ahl_item_compositions
           Set 	last_update_date       =sysdate,
		last_updated_by        = to_number(fnd_global.user_id),
		last_update_login      = to_number(fnd_global.login_id),
		object_version_number  =object_version_number+1
        Where  item_composition_id=l_item_comp_det.link_comp_id;

        Delete from ahl_item_comp_details
	where item_composition_id = l_item_comp_det.item_composition_id;

        Delete from ahl_item_compositions
         Where item_composition_id=l_item_comp_det.item_composition_id;


  End if;





    ELSIF l_status = 'APPROVAL_REJECTED'  THEN

		 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
			   THEN
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'Approval Rejected');
		 END IF;

             update  ahl_item_compositions
	        set approval_status_code=l_status,
	            object_version_number = object_version_number+1
	      where item_composition_id=l_item_comp_det.item_composition_id
	        and object_version_number = l_item_comp_det.object_version_number;




   End if;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     	   THEN
     	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     	     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'End of Approve_Item_Composiiton');
 END IF;



 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Rollback to Approve_Item_Composiiton;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'Error in Approve_Item_Composiiton');
  END IF;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Approve_Item_Composiiton;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'Unexpected Error in Approve_Item_Composiiton');
  END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Rollback to Approve_Item_Composiiton;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Approve_Item_Composiiton',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
     END IF;
     FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      	   THEN
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', 'Unknown Error in Approve_Item_Composiiton');
      	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      	     'ahl.plsql.ahl_mc_itemgroup_pvt.Approve_Item_Composiiton', SQLERRM);

  END IF;


 END Approve_Item_Composiiton;



End AHL_MC_ITEM_COMP_PVT;

/
