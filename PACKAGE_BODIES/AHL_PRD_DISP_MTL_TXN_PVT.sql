--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DISP_MTL_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DISP_MTL_TXN_PVT" AS
/* $Header: AHLVDMTB.pls 120.3.12010000.3 2009/12/04 21:21:30 jaramana ship $ */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'Ahl_Prd_Disp_Mtl_Txn_Pvt';
G_LOG_PREFIX  VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.';

------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Process_Disp_Mtl_Txn
--  Type        : Private
--  Function    : Creates and updates the disposition material transactions.
--  Pre-reqs    :
--  Parameters  :
--
--  Process_Disp_Mtl_Txn Parameters:
--       p_x_disp_mtl_txn_tbl IN OUT NOCOPY the material transaction +
--   disposition records.
--
--  End of Comments.

PROCEDURE Process_Disp_Mtl_Txn (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module              IN          VARCHAR2,
    p_x_disp_mtl_txn_tbl  IN OUT NOCOPY AHL_PRD_DISP_MTL_TXN_PVT.Disp_Mtl_Txn_Tbl_Type)
IS

--Begin Performance Tuning
-- Begin fix bug 4097556
CURSOR get_disp_rec_csr (p_disposition_id IN NUMBER) IS
SELECT disp.disposition_id, disp.object_version_number,
disp.inventory_item_id, disp.organization_id,
disp.immediate_disposition_code, disp.quantity, disp.UOM, disp.workorder_id
FROM AHL_PRD_DISPOSITIONS_B disp
WHERE disp.disposition_id = p_disposition_id;

-- Change made by jaramana on August 8, 2007 for bug 6326065 (FP of 6061600)
-- Start allowing Disp Txn association for Complete workorders (code 4)
cursor workorder_editable_csr(p_workorder_id IN NUMBER) IS
SELECT 'x', fnd.meaning from ahl_workorders wo, fnd_lookup_values_vl fnd
WHERE workorder_id = p_workorder_id
  AND wo.status_code IN ('12','7','17','22','5')
  and fnd.lookup_type = 'AHL_JOB_STATUS' and fnd.lookup_code = wo.status_code;
--AND wo.JOB_STATUS_CODE IN ('Closed', 'Cancelled','Draft','Deleted','Complete No-charge');

--End fix bug 4097556
--End Performance Tuning

CURSOR get_mtl_txn_rec_csr (p_mtl_txn_id IN NUMBER) IS
SELECT mt.transaction_type_id, mt.inventory_item_id, mt.organization_id,
   mt.quantity, mt.uom,  wop.workorder_id
FROM AHL_WORKORDER_MTL_TXNS mt, AHL_WORKORDER_OPERATIONS wop
WHERE mt.WORKORDER_MTL_TXN_ID = p_mtl_txn_id
AND wop.workorder_operation_id = mt.workorder_operation_id;
--
CURSOR get_disp_mtl_txn_rec_csr (p_disposition_id IN NUMBER,
			                	   p_mtl_txn_id IN NUMBER) IS
SELECT *
FROM AHL_PRD_DISP_MTL_TXNS
WHERE DISPOSITION_ID = p_disposition_id
AND WORKORDER_MTL_TXN_ID = p_mtl_txn_id;
--
CURSOR get_disp_mtx_qty_csr (p_mtl_txn_id IN NUMBER) IS
SELECT quantity, uom
FROM AHL_PRD_DISP_MTL_TXNS
WHERE WORKORDER_MTL_TXN_ID = p_mtl_txn_id;
--
CURSOR get_mtl_txn_qty_csr (p_mtl_txn_id IN NUMBER) IS
SELECT inventory_item_id, quantity, uom
FROM AHL_WORKORDER_MTL_TXNS
WHERE WORKORDER_MTL_TXN_ID = p_mtl_txn_id;
--
CURSOR get_disp_qty_csr (p_disposition_id IN NUMBER) IS
SELECT disp.quantity
FROM AHL_PRD_DISPOSITIONS_B disp
WHERE disp.disposition_id = p_disposition_id;
--
l_old_disp_mx_rec      get_disp_mtl_txn_rec_csr%ROWTYPE;
l_disp_mx_rec          AHL_PRD_DISP_MTL_TXN_PVT.disp_mtl_txn_rec_type;

l_api_version          CONSTANT NUMBER       := 1.0;
l_api_name             CONSTANT VARCHAR2(30) := 'Process_Disp_Mtl_Txn';

l_disp_rec       Get_Disp_Rec_Csr%ROWTYPE;
l_mtl_txn_rec      Get_Mtl_Txn_Rec_Csr%ROWTYPE;

TYPE DISP_ID_TBL_TYPE IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

l_update_disp_tbl DISP_ID_TBL_TYPE;    --table indexed by disposition id that store disposition object version number
l_disp_id_index NUMBER;   -- use as both index for l_update_disp_tbl and as disposition_id.
l_update_disp_rec AHL_PRD_DISPOSITION_PVT.disposition_rec_type;

-- SATHAPLI::Bug 7758131, 05-Mar-2009, a variable to nullify all the attributes of the record type
l_disp_rec_null   AHL_PRD_DISPOSITION_PVT.disposition_rec_type;

l_temp_qty             NUMBER;
l_temp_uom             VARCHAR2(3);

l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_exist                VARCHAR2(1);
l_job_status           VARCHAR2(80);
-- Dummy variable added by jaramana on Oct 11, 2007 for ER 5883257
l_mr_asso_tbl          AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type;

--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Process_Disp_Mtl_Txn_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize message list if p_init_msg_list is set to TRUE

  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': Begin API',
			       'At the start of the procedure');
  END IF;

  --1) Insert or update all the records in the update table
  IF p_x_disp_mtl_txn_tbl.count > 0 THEN
  FOR i IN p_x_disp_mtl_txn_tbl.FIRST..p_x_disp_mtl_txn_tbl.LAST  LOOP
    l_disp_mx_rec := p_x_disp_mtl_txn_tbl(i);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     G_LOG_PREFIX||l_api_name||': Within API',
		             'Just before validating disposition_id i='||i||
                     ' disp_mtl_txn_id='||l_disp_mx_rec.disp_mtl_txn_id||
                     ' wo_mtl_txn_id='||l_disp_mx_rec.wo_mtl_txn_id||
                     ' quantity='||l_disp_mx_rec.quantity||
                     ' uom='||l_disp_mx_rec.uom);
    END IF;
    --validate that disposition id is valid
    OPEN get_disp_rec_csr(l_disp_mx_rec.disposition_id);
    FETCH get_disp_rec_csr INTO l_disp_rec;
    IF (get_disp_rec_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_ID_INV');
       FND_MESSAGE.Set_Token('DISPOSITION_ID', l_disp_mx_rec.disposition_id);
       FND_MSG_PUB.ADD;
       l_return_status := FND_API.G_RET_STS_ERROR;
       CLOSE get_disp_rec_csr;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_disp_rec_csr;

    -- Begin fix bug 4097556
    --validate that the disposition is updateable based on the current workorder's status
    OPEN workorder_editable_csr(l_disp_rec.workorder_id);
    FETCH workorder_editable_csr INTO l_exist, l_job_status;
    IF (workorder_editable_csr%FOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_DIS_ASSOC_WO_STATUS');   --Cannot update disposition because of current workorder's status
       FND_MESSAGE.Set_Token('STATUS', l_job_status);
       FND_MSG_PUB.ADD;
       l_return_status := FND_API.G_RET_STS_ERROR;
       CLOSE workorder_editable_csr;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE workorder_editable_csr;
    -- End fix bug 4097556

    l_update_disp_tbl(l_disp_rec.disposition_id) := l_disp_rec.object_version_number;

    --validate that mtl txn id is valid
    OPEN get_mtl_txn_rec_csr(l_disp_mx_rec.wo_mtl_txn_id);
    FETCH get_mtl_txn_rec_csr INTO l_mtl_txn_rec;
    IF (get_mtl_txn_rec_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_TXN_ID_INV');
       FND_MESSAGE.Set_Token('MTL_TXN_ID', l_disp_mx_rec.wo_mtl_txn_id);
       FND_MSG_PUB.ADD;
       l_return_status := FND_API.G_RET_STS_ERROR;
       CLOSE get_mtl_txn_rec_csr;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_mtl_txn_rec_csr;

    --Validate that disposition item and mtl txn item are equal for matching types.
    -- The following check was commented out by jaramana on 04-DEC-2009 for the bug 9184392
    -- This check fails incorrectly when the instance has undergone a part number change
    -- before the instance is returned. So, remove this check.
/**
    IF (((l_disp_rec.immediate_disposition_code <> 'NOT_RECEIVED' AND
          l_mtl_txn_rec.transaction_type_id = WIP_CONSTANTS.RETCOMP_TYPE ) OR
         (l_disp_rec.immediate_disposition_code = 'NOT_RECEIVED' AND
          l_mtl_txn_rec.transaction_type_id = WIP_CONSTANTS.ISSCOMP_TYPE))
     AND (l_disp_rec.inventory_item_id <> l_mtl_txn_rec.inventory_item_id)) THEN
     -- (Jay found this problem) The organization_id in disposition entity maps to instance's last_vld_org_id
     -- if the instance_id is not null. Thus it could be different from job's org which equals to material
     -- transaction organization.
     -- OR l_disp_rec.organization_id <> l_mtl_txn_rec.organization_id)) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_MTL_TXN_ITEM_ILL');
       FND_MSG_PUB.ADD;
       l_return_status := FND_API.G_RET_STS_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
**/
    -- End Changes by jaramana on 04-DEC-2009 for the bug 9184392
    IF (l_disp_rec.workorder_id <> l_mtl_txn_rec.workorder_id) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_MTL_TXN_WO_ILL');
       FND_MSG_PUB.ADD;
       l_return_status := FND_API.G_RET_STS_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --If transaction item equals the disposition item,
    -- then do UOM conversion to Disposition UOM.
    IF (l_disp_rec.inventory_item_id = l_mtl_txn_rec.inventory_item_id AND
        l_disp_rec.UOM <> l_disp_mx_rec.UOM AND
        l_disp_mx_rec.QUANTITY IS NOT NULL AND
        l_disp_mx_rec.QUANTITY <> FND_API.G_MISS_NUM ) THEN
        l_disp_mx_rec.quantity:= inv_convert.inv_um_convert(item_id => l_disp_rec.inventory_item_id,
                                           precision => 6,
                                           from_quantity => l_disp_mx_rec.quantity,
                                           from_unit => l_disp_mx_rec.uom,
                                           to_unit => l_disp_rec.uom,
                                           from_name => null,
                                           to_name => null);
        l_disp_mx_rec.uom := l_disp_rec.uom;
       IF (l_disp_mx_rec.quantity < 0) THEN
         FND_MESSAGE.Set_Name('AHL','AHL_COM_UOM_CONV_FAILED');
         FND_MESSAGE.Set_Token('FROM_UOM', l_disp_mx_rec.UOM);
         FND_MESSAGE.Set_Token('TO_UOM', l_disp_rec.uom);
         FND_MSG_PUB.ADD;
         l_return_status := FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    --Fetch the record and see if it exists already
    OPEN get_disp_mtl_txn_rec_csr(l_disp_mx_rec.disposition_id,
				  l_disp_mx_rec.wo_mtl_txn_id);
    FETCH get_disp_mtl_txn_rec_csr INTO l_old_disp_mx_rec;

    IF (get_disp_mtl_txn_rec_csr%NOTFOUND) THEN
      --CREATE new record.
     IF (p_module = 'JSP') THEN
       IF (l_disp_mx_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
        l_disp_mx_rec.ATTRIBUTE_CATEGORY := null;
       END IF;
       IF (l_disp_mx_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
         l_disp_mx_rec.ATTRIBUTE1 := null;
       END IF;
       IF (l_disp_mx_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE2 := null;
       END IF;
       IF (l_disp_mx_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
         l_disp_mx_rec.ATTRIBUTE3 := null;
       END IF;
       IF (l_disp_mx_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE4 := null;
       END IF;
      IF (l_disp_mx_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
        l_disp_mx_rec.ATTRIBUTE5 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
         l_disp_mx_rec.ATTRIBUTE6 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
         l_disp_mx_rec.ATTRIBUTE7 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE8 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE9 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE10 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE11 := null;
     END IF;
      IF (l_disp_mx_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE12 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE13 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE14 := null;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
       l_disp_mx_rec.ATTRIBUTE15 := null;
      END IF;
    END IF;  --p_module = JSP

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Within the API',
			       'Immediately before inserting record');
    END IF;
    --Do inserts
    INSERT INTO ahl_prd_disp_mtl_txns (
        DISP_MTL_TXN_ID,
     	OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        DISPOSITION_ID,
        WORKORDER_MTL_TXN_ID,
        QUANTITY,
        UOM,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
        ) VALUES (
        AHL_PRD_DISP_MTL_TXNS_S.nextval,
      	1,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        l_disp_mx_rec.disposition_id,
        l_disp_mx_rec.wo_mtl_txn_id,
        l_disp_mx_rec.quantity,
        l_disp_mx_rec.uom,
       	l_disp_mx_rec.attribute_category ,
  	    l_disp_mx_rec.attribute1 ,
        l_disp_mx_rec.attribute2 ,
	    l_disp_mx_rec.attribute3 ,
	    l_disp_mx_rec.attribute4 ,
	   l_disp_mx_rec.attribute5 ,
	   l_disp_mx_rec.attribute6 ,
	   l_disp_mx_rec.attribute7 ,
	   l_disp_mx_rec.attribute8 ,
	   l_disp_mx_rec.attribute9 ,
	   l_disp_mx_rec.attribute10 ,
	   l_disp_mx_rec.attribute11 ,
	   l_disp_mx_rec.attribute12 ,
	   l_disp_mx_rec.attribute13 ,
	   l_disp_mx_rec.attribute14 ,
	   l_disp_mx_rec.attribute15
        )
        returning DISP_MTL_TXN_ID INTO p_x_disp_mtl_txn_tbl(i).disp_mtl_txn_id;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Within the API',
			       'disp_mtl_txn_id ='||p_x_disp_mtl_txn_tbl(i).disp_mtl_txn_id);
      END IF;
    ELSE

     --Use existing disposition mtl txn id.
     l_disp_mx_rec.DISP_MTL_TXN_ID := l_old_disp_mx_rec.DISP_MTL_TXN_ID;
     p_x_disp_mtl_txn_tbl(i).disp_mtl_txn_id := l_disp_mx_rec.disp_mtl_txn_id;

    -- Check Object version number.
    IF (l_old_disp_mx_rec.object_version_number <> l_disp_mx_rec.object_version_number) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      l_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE get_disp_mtl_txn_rec_csr;
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     --Do NULL/G_MISS conversion
     IF (p_module = 'JSP') THEN
      IF (l_disp_mx_rec.QUANTITY IS NULL) THEN
         l_disp_mx_rec.QUANTITY := l_old_disp_mx_rec.QUANTITY;
      ELSIF (l_disp_mx_rec.QUANTITY= FND_API.G_MISS_NUM) THEN
         l_disp_mx_rec.QUANTITY:= NULL;
      END IF;

      IF (l_disp_mx_rec.UOM IS NULL) THEN
         l_disp_mx_rec.UOM:= l_old_disp_mx_rec.UOM;
      ELSIF (l_disp_mx_rec.UOM= FND_API.G_MISS_CHAR) THEN
         l_disp_mx_rec.UOM:= NULL;
         l_disp_mx_rec.UOM := l_old_disp_mx_rec.UOM;
      END IF;

      IF (l_disp_mx_rec.ATTRIBUTE_CATEGORY IS NULL) THEN
         l_disp_mx_rec.ATTRIBUTE_CATEGORY := l_old_disp_mx_rec.ATTRIBUTE_CATEGORY;
      ELSIF (l_disp_mx_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
         l_disp_mx_rec.ATTRIBUTE_CATEGORY := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE1 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE1 := l_old_disp_mx_rec.ATTRIBUTE1;
      ELSIF (l_disp_mx_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE1 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE2 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE2 := l_old_disp_mx_rec.ATTRIBUTE2;
      ELSIF (l_disp_mx_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE2 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE3 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE3 := l_old_disp_mx_rec.ATTRIBUTE3;
      ELSIF (l_disp_mx_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE3 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE4 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE4 := l_old_disp_mx_rec.ATTRIBUTE4;
      ELSIF (l_disp_mx_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE4 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE5 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE5 := l_old_disp_mx_rec.ATTRIBUTE5;
      ELSIF (l_disp_mx_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE5 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE6 IS NULL) THEN
         l_disp_mx_rec.ATTRIBUTE6 := l_old_disp_mx_rec.ATTRIBUTE6;
      ELSIF (l_disp_mx_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE6 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE7 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE7 := l_old_disp_mx_rec.ATTRIBUTE7;
      ELSIF (l_disp_mx_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE7 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE8 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE8 := l_old_disp_mx_rec.ATTRIBUTE8;
      ELSIF (l_disp_mx_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE8 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE9 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE9 := l_old_disp_mx_rec.ATTRIBUTE9;
      ELSIF (l_disp_mx_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE9 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE10 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE10 := l_old_disp_mx_rec.ATTRIBUTE10;
      ELSIF (l_disp_mx_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE10 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE11 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE11 := l_old_disp_mx_rec.ATTRIBUTE11;
      ELSIF (l_disp_mx_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE11 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE12 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE12 := l_old_disp_mx_rec.ATTRIBUTE12;
      ELSIF (l_disp_mx_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE12 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE13 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE13 := l_old_disp_mx_rec.ATTRIBUTE13;
      ELSIF (l_disp_mx_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE13 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE14 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE14 := l_old_disp_mx_rec.ATTRIBUTE14;
      ELSIF (l_disp_mx_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE14 := NULL;
      END IF;
      IF (l_disp_mx_rec.ATTRIBUTE15 IS NULL) THEN
          l_disp_mx_rec.ATTRIBUTE15 := l_old_disp_mx_rec.ATTRIBUTE15;
      ELSIF (l_disp_mx_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
          l_disp_mx_rec.ATTRIBUTE15 := NULL;
      END IF;
    END IF; -- p_module flag: JSP

    --UPDATE existing record
    UPDATE ahl_prd_disp_mtl_txns SET
	    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
        LAST_UPDATE_DATE      = sysdate,
        LAST_UPDATED_BY       = fnd_global.USER_ID,
        LAST_UPDATE_LOGIN     = fnd_global.LOGIN_ID,
 	    QUANTITY             = l_disp_mx_rec.quantity,
 	    UOM                = l_disp_mx_rec.uom,
 	    ATTRIBUTE_CATEGORY = l_disp_mx_rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1   = l_disp_mx_rec.ATTRIBUTE1,
        ATTRIBUTE2 = l_disp_mx_rec.ATTRIBUTE2,
        ATTRIBUTE3 = l_disp_mx_rec.ATTRIBUTE3,
        ATTRIBUTE4 = l_disp_mx_rec.ATTRIBUTE4,
        ATTRIBUTE5 = l_disp_mx_rec.ATTRIBUTE5,
        ATTRIBUTE6 = l_disp_mx_rec.ATTRIBUTE6,
        ATTRIBUTE7 = l_disp_mx_rec.ATTRIBUTE7,
        ATTRIBUTE8 = l_disp_mx_rec.ATTRIBUTE8,
        ATTRIBUTE9 = l_disp_mx_rec.ATTRIBUTE9,
        ATTRIBUTE10 = l_disp_mx_rec.ATTRIBUTE10,
        ATTRIBUTE11 = l_disp_mx_rec.ATTRIBUTE11,
        ATTRIBUTE12 = l_disp_mx_rec.ATTRIBUTE12,
        ATTRIBUTE13 = l_disp_mx_rec.ATTRIBUTE13,
        ATTRIBUTE14 = l_disp_mx_rec.ATTRIBUTE14,
        ATTRIBUTE15 = l_disp_mx_rec.ATTRIBUTE15
      WHERE DISP_MTL_TXN_ID =  l_disp_mx_rec.disp_mtl_txn_id;

    END IF;
    CLOSE get_disp_mtl_txn_rec_csr;

  END LOOP;


  --2) Now validate that the sums of the dispositions and mtl transactions are valid.
  FOR i IN p_x_disp_mtl_txn_tbl.FIRST..p_x_disp_mtl_txn_tbl.LAST  LOOP
    OPEN get_disp_qty_csr (p_x_disp_mtl_txn_tbl(i).disposition_id);
    FETCH get_disp_qty_csr INTO l_disp_rec.quantity;
    CLOSE get_disp_qty_csr;

    --Verify that disposition quantity is not exceeded.
    --No UOM conversion is necessary, because all QTYs store in Disposition UOM
    IF (Calculate_Txned_Qty(p_x_disp_mtl_txn_tbl(i).disposition_id) > l_disp_rec.quantity) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_DISP_QTY_EXCEEDED');
      FND_MESSAGE.Set_Token('DISPOSITION_ID', p_x_disp_mtl_txn_tbl(i).disposition_id);
      FND_MSG_PUB.ADD;
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --Verify the mtl transaction quantity is not exceeded by the various dispositions.
    OPEN get_mtl_txn_qty_csr(p_x_disp_mtl_txn_tbl(i).wo_mtl_txn_id);
    FETCH get_mtl_txn_qty_csr INTO l_mtl_txn_rec.inventory_item_id,
                                l_mtl_txn_rec.quantity, l_mtl_txn_rec.uom;
    CLOSE get_mtl_txn_qty_csr;

    OPEN get_disp_mtx_qty_csr(p_x_disp_mtl_txn_tbl(i).wo_mtl_txn_id);
    LOOP
        FETCH get_disp_mtx_qty_csr INTO l_temp_qty, l_temp_uom;
        EXIT WHEN get_disp_mtx_qty_csr%NOTFOUND;

       --If transaction item equals the disposition item, then do UOM conversion.
       IF (l_temp_uom =  l_mtl_txn_rec.uom) THEN
         l_mtl_txn_rec.quantity := l_mtl_txn_rec.quantity - l_temp_qty;
       ELSE
        l_temp_qty:= inv_convert.inv_um_convert(item_id => l_mtl_txn_rec.inventory_item_id,
                                           precision => 6,
                                           from_quantity => l_temp_qty,
                                           from_unit => l_temp_uom,
                                           to_unit => l_mtl_txn_rec.uom,
                                           from_name => null,
                                           to_name => null);
         --Make sure that the temporary qty is valid after conversion
         IF (l_temp_qty>0) THEN
           l_mtl_txn_rec.quantity := l_mtl_txn_rec.quantity - l_temp_qty;
         END IF;
        END IF;

        --If quantity count is less than 0, then raise exception
        IF (l_mtl_txn_rec.quantity<0) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_TXN_QTY_EXCEEDED');
          FND_MESSAGE.Set_Token('MTL_TXN_ID', p_x_disp_mtl_txn_tbl(i).wo_mtl_txn_id);
          FND_MSG_PUB.ADD;
          l_return_status := FND_API.G_RET_STS_ERROR;
          EXIT;
        END IF;
     END LOOP;
     CLOSE get_disp_mtx_qty_csr;
  END LOOP;

  --Added by Peter
  --Call process_disposition so that disposition status will be recalculated
  --to be in synch with material transaction
  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- SATHAPLI::Bug 7758131, 05-Mar-2009, corrected the traversing of the associative array l_update_disp_tbl
    -- FOR l_disp_id_index IN l_update_disp_tbl.FIRST..l_update_disp_tbl.LAST LOOP
    l_disp_id_index := l_update_disp_tbl.FIRST;
    WHILE l_disp_id_index IS NOT NULL LOOP
     l_update_disp_rec.disposition_id := l_disp_id_index;
     l_update_disp_rec.object_version_number :=  l_update_disp_tbl(l_disp_id_index);
     l_update_disp_rec.operation_flag := AHL_PRD_DISPOSITION_PVT.G_OP_UPDATE;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   G_LOG_PREFIX||l_api_name||': Before calling process_disposition: ',
			       ' disposition_id' || l_update_disp_rec.disposition_id  ||
				   ' obj_ver_num: ' || l_update_disp_rec.object_version_number
				   ||' x_msg_data: ' || x_msg_data );
      END IF;

     AHL_PRD_DISPOSITION_PVT.process_disposition(
        p_api_version          =>   p_api_version,
        p_init_msg_list        =>   p_init_msg_list,
        p_commit               =>   Fnd_Api.g_false,
        p_validation_level     =>   p_validation_level,
        p_module_type          =>   p_module,
        p_x_disposition_rec    =>   l_update_disp_rec,
        -- Dummy parameter added by jaramana on Oct 11, 2007 for ER 5883257
        p_mr_asso_tbl          =>   l_mr_asso_tbl,
        x_return_status        =>   x_return_status,
        x_msg_count            =>   x_msg_count,
        x_msg_data             =>   x_msg_data);

      -- get the next index
      l_disp_id_index := l_update_disp_tbl.NEXT(l_disp_id_index);

      -- nullify the entire record structure l_update_disp_rec for the next iteration
      l_update_disp_rec := l_disp_rec_null;
    END LOOP;

  END IF;

  END IF; -- If p_x_disp_mtl_txn_tbl.count > 0


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   G_LOG_PREFIX||l_api_name||': End API',
			       'At the end of the procedure');
  END IF;
  -- Check Error Message stack.
  /*
   Do not use this check since this API can be called after
   performing a material txn which puts a message (success)
   into the message stack

  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;
  */
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
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

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Process_Disp_Mtl_Txn_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Process_Disp_Mtl_Txn_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Process_Disp_Mtl_Txn_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Process_Disp_Mtl_Txn;

------------------------
-- Start of Comments --
--  Procedure name    : Get_Disp_For_Mtl_Txn
--  Type        : Private
--  Function    : Fetch the matching dispositions for given material txn
--  Pre-reqs    :
--  Parameters  : p_wo_mtl_txn_id: The material transaction id
--                x_disp_list_tbl: returning list of dispositions
--
--
--  End of Comments.

PROCEDURE Get_Disp_For_Mtl_Txn (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_wo_mtl_txn_id       IN NUMBER,
    x_disp_list_tbl    OUT NOCOPY  disp_mtxn_assoc_tbl_type)
IS
--
CURSOR get_mtl_txn_csr(p_mtl_txn_id IN NUMBER) IS
 SELECT oper.workorder_id, txn.transaction_type_id,
        txn.inventory_item_id, txn.organization_id,
        txn.serial_number, txn.lot_number,
        NVL(mtl.comms_nl_trackable_flag,'N') trackable_flag
  FROM  AHL_WORKORDER_MTL_TXNS txn, AHL_WORKORDER_OPERATIONS oper,
        mtl_system_items_kfv mtl
  WHERE txn.workorder_mtl_txn_id = p_mtl_txn_id
    AND txn.workorder_operation_id = oper.workorder_operation_id
    AND txn.inventory_item_id = mtl.inventory_item_id
    AND txn.organization_id = mtl.organization_id;
--
--This fetches all dispositions for wo, that has same mtl_txn_id
--or has not been completed transacted.
CURSOR get_disp_return_csr (p_mtl_txn_id IN NUMBER,
                            p_workorder_id IN NUMBER,
                            p_trackable_flag IN VARCHAR2,
                            p_txn_item_id  IN NUMBER,
                            p_txn_org_id IN NUMBER,
                            p_serial_number IN VARCHAR2,
                            p_lot_number IN VARCHAR2) IS
/*
SELECT distinct disp.disposition_id,
        disp.inventory_item_id,
        disp.organization_id,
        disp.item_number,
        disp.item_group_id,
        disp.item_group_name,
        disp.serial_number,
        disp.lot_number,
        disp.immediate_disposition_code,
        disp.immediate_type,
        disp.secondary_disposition_code,
        disp.secondary_type,
        disp.status_code,
        disp.status,
        disp.quantity,
        disp.uom,
        0, --default is 0.  will populate this field inside the loop
        disp.uom assoc_uom,
        disp.quantity-Calculate_Txned_Qty(disp.disposition_id),
        disp.uom
  FROM AHL_PRD_DISPOSITIONS_V disp, AHL_PRD_DISP_MTL_TXNS assoc
 WHERE  (disp.disposition_id = assoc.disposition_id   --Either match on existing reln
         AND assoc.workorder_mtl_txn_id = p_mtl_txn_id)
     OR (disp.trackable_flag = p_trackable_flag
       AND disp.workorder_id = p_workorder_id
       AND (disp.status_code IS NULL OR disp.status_code <> 'TERMINATED')
       AND disp.quantity > Calculate_Txned_Qty(disp.disposition_id) --Find untxned dispositions
       AND disp.immediate_disposition_code NOT IN ('NOT_RECEIVED','NA','NOT_REMOVED')
       AND disp.inventory_item_id = p_txn_item_id
       AND disp.organization_id = p_txn_org_id
       AND (disp.serial_number IS NULL OR disp.serial_number = p_serial_number)
       AND (disp.lot_number IS NULL OR disp.lot_number = p_lot_number));
*/
      -- AnRaj: Changed the query for the cursor, issue #2, bug # 5258284
      SELECT   distinct disp.disposition_id,
               disp.inventory_item_id,
               disp.organization_id,
               mtl.concatenated_segments item_number,
               disp.item_group_id ,
               grp.name item_group_name ,
               disp.serial_number,
               disp.lot_number,
               disp.immediate_disposition_code,
               flvt1.meaning immediate_type,
               disp.secondary_disposition_code,
               flvt2.meaning secondary_type,
               disp.STATUS_CODE ,
               flvt3.MEANING STATUS ,
               disp.quantity,
               disp.uom,
               0,
               disp.uom assoc_uom,
               disp.quantity-calculate_txned_qty(disp.disposition_id),
               disp.uom
      FROM     ahl_prd_dispositions_vl disp,
               ahl_prd_disp_mtl_txns assoc,
               mtl_system_items_kfv mtl,
               ahl_item_groups_b grp,
               fnd_lookup_values flvt1,
               fnd_lookup_values flvt2,
               fnd_lookup_values flvt3
      WHERE    (
                  (   disp.disposition_id = assoc.disposition_id   --Either match on existing reln
                     AND
                     assoc.workorder_mtl_txn_id = p_mtl_txn_id
                  )
                  OR
                  (  decode(disp.instance_id, null, decode(disp.path_position_id, null, 'N', 'Y'), 'Y') = p_trackable_flag
                     AND disp.workorder_id = p_workorder_id
                     AND (disp.status_code IS NULL OR disp.status_code <> 'TERMINATED')
                     AND disp.quantity > Calculate_Txned_Qty(disp.disposition_id) --Find untxned dispositions
                     AND disp.immediate_disposition_code NOT IN ('NOT_RECEIVED','NA','NOT_REMOVED')
                     AND disp.inventory_item_id = p_txn_item_id
                     AND disp.organization_id = p_txn_org_id
                     AND (disp.serial_number IS NULL OR disp.serial_number = p_serial_number)
                     AND (disp.lot_number IS NULL OR disp.lot_number = p_lot_number)
                  )
               )
      AND      disp.inventory_item_id = mtl.inventory_item_id (+)
      AND      disp.organization_id = mtl.organization_id (+)
      AND      disp.ITEM_GROUP_ID = grp.item_group_id (+)
      AND      flvt1.lookup_type(+) = 'AHL_IMMED_DISP_TYPE'
      AND      flvt1.LOOKUP_CODE (+) = disp.immediate_disposition_code
      AND      flvt1.LANGUAGE(+) = userenv('LANG')
      AND      flvt2.lookup_type(+) = 'AHL_SECND_DISP_TYPE'
      AND      flvt2.lookup_code (+) = disp.secondary_disposition_code
      AND      flvt2.LANGUAGE(+) = userenv('LANG')
      AND      flvt3.lookup_type(+) = 'AHL_DISP_STATUS'
      AND      flvt3.lookup_code (+) = disp.STATUS_CODE
      AND      flvt3.LANGUAGE(+) = userenv('LANG') ;
--
--This fetches all dispositions for wo, that has same mtl_txn_id
--or has not been completed transacted.
CURSOR get_disp_issue_csr (p_mtl_txn_id IN NUMBER,
                            p_workorder_id IN NUMBER,
                            p_trackable_flag IN VARCHAR2) IS
/*
SELECT distinct disp.disposition_id,
        disp.inventory_item_id,
        disp.organization_id,
        disp.item_number,
        disp.item_group_id,
        disp.item_group_name,
        disp.serial_number,
        disp.lot_number,
        disp.immediate_disposition_code,
        disp.immediate_type,
        disp.secondary_disposition_code,
        disp.secondary_type,
        disp.status_code,
        disp.status,
        disp.quantity,
		disp.uom,
        0,
        disp.uom assoc_uom,
        disp.quantity-Calculate_Txned_Qty(disp.disposition_id),
        disp.uom
  FROM AHL_PRD_DISPOSITIONS_V disp, AHL_PRD_DISP_MTL_TXNS assoc
 WHERE (disp.disposition_id = assoc.disposition_id   --Either match on existing reln
       AND assoc.workorder_mtl_txn_id = p_mtl_txn_id)
     OR (disp.trackable_flag = p_trackable_flag
       AND disp.workorder_id = p_workorder_id
       AND disp.status_code <> 'TERMINATED'
       AND (disp.immediate_disposition_code NOT IN ('NOT_RECEIVED','NA','NOT_REMOVED')
          OR (disp.immediate_disposition_code = 'NOT_RECEIVED'
             AND disp.quantity > Calculate_Txned_Qty(disp.disposition_id))));
*/
      -- AnRaj: Changed the query for the cursor, issue #1, bug # 5258284
      SELECT   distinct disp.disposition_id,
               disp.inventory_item_id,
               disp.organization_id,
               mtl.concatenated_segments item_number,
               disp.item_group_id ,
               grp.name item_group_name ,
               disp.serial_number,
               disp.lot_number,
               disp.immediate_disposition_code,
               flvt1.meaning immediate_type,
               disp.secondary_disposition_code,
               flvt2.meaning secondary_type,
               disp.STATUS_CODE ,
               flvt3.MEANING STATUS ,
               disp.quantity,
               disp.uom,
               0,
               disp.uom assoc_uom,
               disp.quantity-calculate_txned_qty(disp.disposition_id),
               disp.uom
      FROM     ahl_prd_dispositions_vl disp,
               ahl_prd_disp_mtl_txns assoc,
               mtl_system_items_kfv mtl,
               ahl_item_groups_b grp,
               fnd_lookup_values flvt1,
               fnd_lookup_values flvt2,
               fnd_lookup_values flvt3
      WHERE    (
                  (  disp.disposition_id = assoc.disposition_id
                     and assoc.workorder_mtl_txn_id = p_mtl_txn_id
                  )
                  or
                  (  decode(disp.instance_id, null, decode(disp.path_position_id, null, 'N', 'Y'), 'Y') = p_trackable_flag
                     and disp.workorder_id = p_workorder_id
                     and disp.status_code <> 'TERMINATED'
                     and ( disp.immediate_disposition_code not in ('NOT_RECEIVED','NA','NOT_REMOVED')
                           or
                          (   disp.immediate_disposition_code = 'NOT_RECEIVED'
                              and
                              disp.quantity > calculate_txned_qty(disp.disposition_id)
                           )
                        )
                  )
               )
      AND      disp.inventory_item_id = mtl.inventory_item_id (+)
      AND      disp.organization_id = mtl.organization_id (+)
      AND      disp.ITEM_GROUP_ID = grp.item_group_id (+)
      AND      flvt1.lookup_type(+) = 'AHL_IMMED_DISP_TYPE'
      AND      flvt1.LOOKUP_CODE (+) = disp.immediate_disposition_code
      AND      flvt1.LANGUAGE(+) = userenv('LANG')
      AND      flvt2.lookup_type(+) = 'AHL_SECND_DISP_TYPE'
      AND      flvt2.lookup_code (+) = disp.secondary_disposition_code
      AND      flvt2.LANGUAGE(+) = userenv('LANG')
      AND      flvt3.lookup_type(+) = 'AHL_DISP_STATUS'
      AND      flvt3.lookup_code (+) = disp.STATUS_CODE
      AND      flvt3.LANGUAGE(+) = userenv('LANG') ;
--
--added by peter
-- get the total associated quantity based on the disposition id and material transaction id
CURSOR get_assoc_qty_csr(p_disp_id IN NUMBER, p_workorder_txn_id IN NUMBER)
 IS
 SELECT quantity, uom FROM AHL_PRD_DISP_MTL_TXNS
   WHERE DISPOSITION_ID = p_disp_id  -- 11016 -- 11044
   AND WORKORDER_MTL_TXN_ID = p_workorder_txn_id;

--Added by Jerry for fixing bug 4092624
CURSOR check_issue_items(c_disposition_id NUMBER, c_inventory_item_id NUMBER, c_organization_id NUMBER) IS
  SELECT 1
    FROM ahl_prd_dispositions_b A
   WHERE A.disposition_id = c_disposition_id
     AND ((A.inventory_item_id = c_inventory_item_id
           AND A.organization_id = c_organization_id)
           OR EXISTS
           (SELECT 1
              FROM ahl_item_associations_b B
             WHERE B.item_group_id = A.item_group_id
               AND B.inventory_item_id = c_inventory_item_id
               AND B.inventory_org_id = (SELECT master_organization_id
                                           FROM mtl_parameters
                                          WHERE organization_id = c_organization_id)
               AND B.interchange_type_code IN ('1-WAY INTERCHANGEABLE','2-WAY INTERCHANGEABLE')));

l_dummy NUMBER;
l_assoc_qty NUMBER;
l_assoc_uom VARCHAR2(3);


l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Disp_For_Mtl_Txn';
l_txn_rec           get_mtl_txn_csr%ROWTYPE;
l_disp_assoc_rec   DISP_MTXN_ASSOC_REC_TYPE;
i NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_Mtl_Txn_Type_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  OPEN get_mtl_txn_csr(p_wo_mtl_txn_id);
  FETCH get_mtl_txn_csr INTO l_txn_rec;
  IF (get_mtl_txn_csr%NOTFOUND) THEN
       CLOSE get_mtl_txn_csr;
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_TXN_ID_INV');
       FND_MESSAGE.Set_Token('MTL_TXN_ID', p_wo_mtl_txn_id);
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_mtl_txn_csr;

  --If return material transaction, fetch all matching disp for wo, mtl_txn
  -- and disposition item with txn item.
  IF (l_txn_rec.transaction_type_id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
   i:=0;
    --dbms_output.put_line('Transaction is Return type i= ' || i);
   OPEN get_disp_return_csr(p_wo_mtl_txn_id, l_txn_rec.workorder_id,
                            l_txn_rec.trackable_flag,
                            l_txn_rec.inventory_item_id, l_txn_rec.organization_id,
                            l_txn_rec.serial_number, l_txn_rec.lot_number);
   LOOP
     --dbms_output.put_line('before fetch i= ' || i);
     FETCH get_disp_return_csr INTO l_disp_assoc_rec.DISPOSITION_ID,
                                    l_disp_assoc_rec.INVENTORY_ITEM_ID,
                                    l_disp_assoc_rec.ITEM_ORG_ID,
                                    l_disp_assoc_rec.ITEM_NUMBER,
                                    l_disp_assoc_rec.ITEM_GROUP_ID,
                                    l_disp_assoc_rec.item_group_name,
                                    l_disp_assoc_rec.serial_number,
                                    l_disp_assoc_rec.lot_number,
                                    l_disp_assoc_rec.immediate_disposition_code,
                                    l_disp_assoc_rec.immediate_type,
                                    l_disp_assoc_rec.secondary_disposition_code,
                                    l_disp_assoc_rec.secondary_type,
                                    l_disp_assoc_rec.status_code,
                                    l_disp_assoc_rec.status,
                                    l_disp_assoc_rec.quantity,
                                    l_disp_assoc_rec.uom,
                                    l_disp_assoc_rec.assoc_qty,
                                    l_disp_assoc_rec.assoc_uom,
                                    l_disp_assoc_rec.UNTXNED_QTY,
                                    l_disp_assoc_rec.UNTXNED_UOM;
       OPEN get_assoc_qty_csr(l_disp_assoc_rec.disposition_id, p_wo_mtl_txn_id );
	   FETCH get_assoc_qty_csr INTO l_assoc_qty, l_assoc_uom;
	   IF get_assoc_qty_csr%FOUND THEN
	    l_disp_assoc_rec.assoc_qty := l_assoc_qty;
	    l_disp_assoc_rec.assoc_uom := l_assoc_uom;
	   END IF;
	   CLOSE get_assoc_qty_csr;
    --dbms_output.put_line('after fetch i= ' || i);
     EXIT WHEN get_disp_return_csr%NOTFOUND;
     x_disp_list_tbl(i):= l_disp_assoc_rec;
     i:=i+1;
   END LOOP;
   CLOSE get_disp_return_csr;
  ELSIF (l_txn_rec.transaction_type_id = WIP_CONSTANTS.ISSCOMP_TYPE) THEN
   i:=0;
   OPEN get_disp_issue_csr(p_wo_mtl_txn_id, l_txn_rec.workorder_id,
                            l_txn_rec.trackable_flag);
   LOOP
     FETCH get_disp_issue_csr INTO l_disp_assoc_rec;
     EXIT WHEN get_disp_issue_csr%NOTFOUND;
     OPEN check_issue_items(l_disp_assoc_rec.disposition_id,l_txn_rec.inventory_item_id, l_txn_rec.organization_id);
     FETCH check_issue_items INTO l_dummy;
     IF check_issue_items%FOUND THEN
       OPEN get_assoc_qty_csr(l_disp_assoc_rec.disposition_id, p_wo_mtl_txn_id );
       FETCH get_assoc_qty_csr INTO l_assoc_qty, l_assoc_uom;
       IF get_assoc_qty_csr%FOUND THEN
	    l_disp_assoc_rec.assoc_qty := l_assoc_qty;
	    l_disp_assoc_rec.assoc_uom := l_assoc_uom;
       END IF;
       CLOSE get_assoc_qty_csr;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        G_LOG_PREFIX||l_api_name||': End API',
		       'disp_id = '||l_disp_assoc_rec.disposition_id||'item='||l_txn_rec.inventory_item_id||'org='||l_txn_rec.organization_id);
       END IF;
       x_disp_list_tbl(i):= l_disp_assoc_rec;
       i:=i+1;
     END IF;
     CLOSE check_issue_items;
   END LOOP;
   CLOSE get_disp_issue_csr;

  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Get_Mtl_Txn_Type_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Get_Mtl_Txn_Type_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Get_Mtl_Txn_Type_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Get_Disp_For_Mtl_Txn;

----------------------
--  Function name    : Calculate_Txned_Qty
--  Type        : Private
--  Function    : Calculates the mtl transactions qtys txned for a disposition.
--  Pre-reqs    :
--  Parameters  :
--
--  Calculate_Txned_Qty parameters:
--       p_disposition_id is the disposition_id
--    Returns: qty of the mtl transaction that's assoc to disp. can be
--  >0 or =0
--
--  End of Comments.

FUNCTION Calculate_Txned_Qty(
     p_disposition_id  IN NUMBER)
 RETURN NUMBER
 IS
 --
 CURSOR get_remain_qty_csr(p_disp_id IN NUMBER)
 IS
  SELECT sum (assoc.quantity)
  FROM AHL_PRD_DISPOSITIONS_B disp, AHL_PRD_DISP_MTL_TXNS assoc,
  AHL_WORKORDER_MTL_TXNS mtxn
  WHERE disp.disposition_id = p_disp_id
  AND assoc.workorder_mtl_txn_id = mtxn.workorder_mtl_txn_id
  AND mtxn.transaction_type_id = decode (disp.immediate_disposition_code,'NOT_RECEIVED',WIP_CONSTANTS.ISSCOMP_TYPE,WIP_CONSTANTS.RETCOMP_TYPE)
  AND disp.disposition_id = assoc.disposition_id
  GROUP BY disp.disposition_id, assoc.disposition_id;
 --
 l_txn_qty NUMBER :=0;
 --
 BEGIN
     OPEN get_remain_qty_csr (p_disposition_id);
     FETCH get_remain_qty_csr INTO l_txn_qty;
     CLOSE get_remain_qty_csr;
     RETURN l_txn_qty;
 END Calculate_Txned_Qty;

----------------------
--  Function name    : Calculate_Txned_Qty
--  Type        : Private
--  Function    : Calculates the mtl transactions qtys txned for a disposition.
--  Pre-reqs    :
--  Parameters  :
--
--  Get_Assoc_Quantity parameters:
--       p_disposition_id is the disposition_id
--    Returns: qty of the mtl transaction that's assoc to disp. can be
--  >0 or =0
--
--  End of Comments.

FUNCTION Get_Assoc_Quantity(
     p_disposition_id  IN NUMBER,
	 p_workorder_txn_id IN NUMBER)
 RETURN NUMBER
 IS
 --
 CURSOR get_assoc_qty_csr(p_disp_id IN NUMBER, p_workorder_txn_id IN NUMBER)
 IS
  SELECT sum (assoc.quantity)
  FROM AHL_PRD_DISPOSITIONS_B disp, AHL_PRD_DISP_MTL_TXNS assoc,
  AHL_WORKORDER_MTL_TXNS mtxn
  WHERE disp.disposition_id = p_disp_id
  AND assoc.workorder_mtl_txn_id = p_workorder_txn_id
  AND assoc.workorder_mtl_txn_id = mtxn.workorder_mtl_txn_id
  AND mtxn.transaction_type_id = decode (disp.immediate_disposition_code,'NOT_RECEIVED',WIP_CONSTANTS.ISSCOMP_TYPE,WIP_CONSTANTS.RETCOMP_TYPE)
  AND disp.disposition_id = assoc.disposition_id
  GROUP BY disp.disposition_id, assoc.disposition_id;
 --
 l_txn_qty NUMBER :=0;
 --
 BEGIN
     OPEN get_assoc_qty_csr (p_disposition_id, p_workorder_txn_id);
     FETCH get_assoc_qty_csr INTO l_txn_qty;
     CLOSE get_assoc_qty_csr;
     RETURN l_txn_qty;
 END Get_Assoc_Quantity;

End AHL_PRD_DISP_MTL_TXN_PVT;

/
