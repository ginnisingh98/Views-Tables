--------------------------------------------------------
--  DDL for Package Body AHL_PRD_MATERIAL_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_MATERIAL_TXN_PUB" AS
 /* $Header: AHLPMTXB.pls 120.0.12000000.1 2007/10/23 00:41:59 sracha noship $ */

G_PKG_NAME   VARCHAR2(30)  := 'AHL_PRD_MATERIAL_TXN_PUB';

-- FND Logging Constants
G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_DEBUG_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE PERFORM_MATERIAL_TXN (
   p_api_version            IN            NUMBER,
   p_init_msg_list          IN            VARCHAR2   := FND_API.G_FALSE,
   p_commit                 IN            VARCHAR2   := FND_API.G_FALSE,
   p_default                IN            VARCHAR2   := FND_API.G_FALSE,
   p_x_material_txn_tbl     IN OUT NOCOPY AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
) IS

l_api_version      CONSTANT NUMBER := 1.0;
l_api_name         CONSTANT VARCHAR2(30)  := 'Perform_Material_Txn';
l_debug_module     CONSTANT VARCHAR2(100) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_ahl_mtltxn_tbl   AHL_PRD_MTLTXN_PVT.Ahl_MtlTxn_Tbl_Type;
l_disp_Mtl_Txn_Tbl AHL_PRD_DISP_MTL_TXN_PVT.Disp_Mtl_Txn_Tbl_Type;

BEGIN

   -- Log API entry point
   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
   THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,l_api_name,
                                       G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard start of API savepoint
   SAVEPOINT Perform_Material_Txn_pub;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Assign variables to l_x_ahl_mtltxn_rec structure.
   IF (p_x_material_txn_tbl.COUNT > 0) THEN
     FOR i IN p_x_material_txn_tbl.FIRST..p_x_material_txn_tbl.LAST LOOP

        l_ahl_mtltxn_tbl(i).Workorder_Id            := p_x_material_txn_tbl(i).Workorder_Id;
        l_ahl_mtltxn_tbl(i).Workorder_Name          := p_x_material_txn_tbl(i).Workorder_Name;
        l_ahl_mtltxn_tbl(i).Operation_Seq_Num       := p_x_material_txn_tbl(i).Operation_Seq_Num;
        l_ahl_mtltxn_tbl(i).Transaction_Type_Id     := p_x_material_txn_tbl(i).Transaction_Type_Id;
        l_ahl_mtltxn_tbl(i).Transaction_Type_Name   := p_x_material_txn_tbl(i).Transaction_Type_Name;

        l_ahl_mtltxn_tbl(i).Inventory_Item_Id       := p_x_material_txn_tbl(i).Inventory_Item_Id;
        l_ahl_mtltxn_tbl(i).Inventory_Item_Segments := p_x_material_txn_tbl(i).Inventory_Item_Segments;
        l_ahl_mtltxn_tbl(i).Item_Instance_Number    := p_x_material_txn_tbl(i).Item_Instance_Number;
        l_ahl_mtltxn_tbl(i).Item_Instance_ID        := p_x_material_txn_tbl(i).Item_Instance_ID;
        l_ahl_mtltxn_tbl(i).Revision                := p_x_material_txn_tbl(i).Revision;
        l_ahl_mtltxn_tbl(i).Condition               := p_x_material_txn_tbl(i).Condition;
        l_ahl_mtltxn_tbl(i).Condition_desc          := p_x_material_txn_tbl(i).Condition_desc;
        l_ahl_mtltxn_tbl(i).Subinventory_Name       := p_x_material_txn_tbl(i).Subinventory_Name;
        l_ahl_mtltxn_tbl(i).Locator_Id              := p_x_material_txn_tbl(i).Locator_Id;
        l_ahl_mtltxn_tbl(i).Locator_Segments        := p_x_material_txn_tbl(i).Locator_Segments;
        l_ahl_mtltxn_tbl(i).Quantity                := p_x_material_txn_tbl(i).Quantity;
        l_ahl_mtltxn_tbl(i).Uom                     := p_x_material_txn_tbl(i).Uom_Code;
        l_ahl_mtltxn_tbl(i).UOM_Desc                := p_x_material_txn_tbl(i).Unit_Of_Measure;
        l_ahl_mtltxn_tbl(i).Serial_Number           := p_x_material_txn_tbl(i).Serial_Number;
        l_ahl_mtltxn_tbl(i).Lot_Number              := p_x_material_txn_tbl(i).Lot_Number;

        l_ahl_mtltxn_tbl(i).Transaction_Date        := p_x_material_txn_tbl(i).Transaction_Date;
        l_ahl_mtltxn_tbl(i).Transaction_Reference   := p_x_material_txn_tbl(i).Transaction_Reference;
        l_ahl_mtltxn_tbl(i).recepient_id            := p_x_material_txn_tbl(i).recepient_id;
        l_ahl_mtltxn_tbl(i).recepient_name          := p_x_material_txn_tbl(i).recepient_name;
        l_ahl_mtltxn_tbl(i).disposition_id          := p_x_material_txn_tbl(i).disposition_id;

        -- Target visit is currently not being used.
	--l_ahl_mtltxn_tbl(i).Target_Visit_Id       := p_x_material_txn_tbl(i).Target_Visit_Id;
        --l_ahl_mtltxn_tbl(i).Target_Visit_Num      := p_x_material_txn_tbl(i).Target_Visit_Num;

        l_ahl_mtltxn_tbl(i).Reason_Id               := p_x_material_txn_tbl(i).Reason_Id;
	l_ahl_mtltxn_tbl(i).Reason_Name             := p_x_material_txn_tbl(i).Reason_Name;
        l_ahl_mtltxn_tbl(i).Problem_Code            := p_x_material_txn_tbl(i).Problem_Code;
        l_ahl_mtltxn_tbl(i).Problem_Code_Meaning    := p_x_material_txn_tbl(i).Problem_Code_Meaning;
        l_ahl_mtltxn_tbl(i).Sr_Summary              := p_x_material_txn_tbl(i).Sr_Summary;
        l_ahl_mtltxn_tbl(i).Qa_Collection_Id        := p_x_material_txn_tbl(i).Qa_Collection_Id;

        -- Added for ER# 5903318.
        l_ahl_mtltxn_tbl(i).create_wo_option        := p_x_material_txn_tbl(i).create_wo_option;

        l_ahl_mtltxn_tbl(i).ATTRIBUTE_CATEGORY      := p_x_material_txn_tbl(i).ATTRIBUTE_CATEGORY;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE1              := p_x_material_txn_tbl(i).ATTRIBUTE1;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE2              := p_x_material_txn_tbl(i).ATTRIBUTE2;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE3              := p_x_material_txn_tbl(i).ATTRIBUTE3;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE4              := p_x_material_txn_tbl(i).ATTRIBUTE4;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE5              := p_x_material_txn_tbl(i).ATTRIBUTE5;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE6              := p_x_material_txn_tbl(i).ATTRIBUTE6;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE7              := p_x_material_txn_tbl(i).ATTRIBUTE7;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE8              := p_x_material_txn_tbl(i).ATTRIBUTE8;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE9              := p_x_material_txn_tbl(i).ATTRIBUTE9;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE10             := p_x_material_txn_tbl(i).ATTRIBUTE10;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE11             := p_x_material_txn_tbl(i).ATTRIBUTE11;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE12             := p_x_material_txn_tbl(i).ATTRIBUTE12;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE13             := p_x_material_txn_tbl(i).ATTRIBUTE13;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE14             := p_x_material_txn_tbl(i).ATTRIBUTE14;
        l_ahl_mtltxn_tbl(i).ATTRIBUTE15             := p_x_material_txn_tbl(i).ATTRIBUTE15;

     END LOOP;

     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
     THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'Before calling AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN api..count on l_ahl_mtltxn_tbl is:' || l_ahl_mtltxn_tbl.count
        );
     END IF;

     -- Call Private API.
     AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN(
          p_api_version        => 1.0,
          p_init_msg_list      => p_init_msg_list,
          p_commit             => p_commit,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          p_default            => p_default,
          p_module_type        => NULL,
          p_create_sr          => 'Y',
          p_x_ahl_mtltxn_tbl   => l_ahl_mtltxn_tbl,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data);

     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
     THEN
         fnd_log.string
         (
             G_DEBUG_STMT,
             l_debug_module,
             'Call to AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN failed...x_return_status:' || x_return_status
         );
         fnd_log.string
         (
            G_DEBUG_STMT,
            l_debug_module,
            'After call to AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN failed. Error count:' || x_msg_count
         );
     END IF;

     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (l_ahl_mtltxn_tbl.COUNT > 0) THEN
       FOR i IN l_ahl_mtltxn_tbl.FIRST..l_ahl_mtltxn_tbl.LAST LOOP

          -- Form disposition record structure if disposition ID is not null.
          IF (l_ahl_mtltxn_tbl(i).disposition_id IS NOT NULL) THEN
             -- Add record to disposition table.
             l_disp_Mtl_Txn_Tbl(i).wo_mtl_txn_id  := l_ahl_mtltxn_tbl(i).Ahl_MtlTxn_Id;
             l_disp_Mtl_Txn_Tbl(i).disposition_id := l_ahl_mtltxn_tbl(i).disposition_id;
             l_disp_Mtl_Txn_Tbl(i).quantity       := l_ahl_mtltxn_tbl(i).Quantity;
             l_disp_Mtl_Txn_Tbl(i).uom            := l_ahl_mtltxn_tbl(i).uom;
          END IF;

          -- set public api output record attributes.
          p_x_material_txn_tbl(i).Ahl_MtlTxn_Id            := l_ahl_mtltxn_tbl(i).Ahl_MtlTxn_Id;
          p_x_material_txn_tbl(i).Workorder_Id            := l_ahl_mtltxn_tbl(i).Workorder_Id;
          p_x_material_txn_tbl(i).Workorder_Name          := l_ahl_mtltxn_tbl(i).Workorder_Name;
          p_x_material_txn_tbl(i).Operation_Seq_Num       := l_ahl_mtltxn_tbl(i).Operation_Seq_Num;
          p_x_material_txn_tbl(i).Transaction_Type_Id     := l_ahl_mtltxn_tbl(i).Transaction_Type_Id;
          p_x_material_txn_tbl(i).Transaction_Type_Name   := l_ahl_mtltxn_tbl(i).Transaction_Type_Name;

          p_x_material_txn_tbl(i).Inventory_Item_Id       := l_ahl_mtltxn_tbl(i).Inventory_Item_Id;
          p_x_material_txn_tbl(i).Inventory_Item_Segments := l_ahl_mtltxn_tbl(i).Inventory_Item_Segments;
          p_x_material_txn_tbl(i).Item_Instance_Number    := l_ahl_mtltxn_tbl(i).Item_Instance_Number;
          p_x_material_txn_tbl(i).Item_Instance_ID        := l_ahl_mtltxn_tbl(i).Item_Instance_ID;
          p_x_material_txn_tbl(i).Revision                := l_ahl_mtltxn_tbl(i).Revision;
          p_x_material_txn_tbl(i).Condition               := l_ahl_mtltxn_tbl(i).Condition;
          p_x_material_txn_tbl(i).Condition_desc          := l_ahl_mtltxn_tbl(i).Condition_desc;
          p_x_material_txn_tbl(i).Subinventory_Name       := l_ahl_mtltxn_tbl(i).Subinventory_Name;
          p_x_material_txn_tbl(i).Locator_Id              := l_ahl_mtltxn_tbl(i).Locator_Id;
          p_x_material_txn_tbl(i).Locator_Segments        := l_ahl_mtltxn_tbl(i).Locator_Segments;
          p_x_material_txn_tbl(i).Quantity                := l_ahl_mtltxn_tbl(i).Quantity;
          p_x_material_txn_tbl(i).Uom_Code                := l_ahl_mtltxn_tbl(i).Uom;
          p_x_material_txn_tbl(i).Unit_Of_Measure         := l_ahl_mtltxn_tbl(i).Uom_Desc;
          p_x_material_txn_tbl(i).Serial_Number           := l_ahl_mtltxn_tbl(i).Serial_Number;
          p_x_material_txn_tbl(i).Lot_Number              := l_ahl_mtltxn_tbl(i).Lot_Number;
          p_x_material_txn_tbl(i).Transaction_Date        := l_ahl_mtltxn_tbl(i).Transaction_Date;
          p_x_material_txn_tbl(i).Transaction_Reference   := l_ahl_mtltxn_tbl(i).Transaction_Reference;
	  p_x_material_txn_tbl(i).recepient_id            := l_ahl_mtltxn_tbl(i).recepient_id;
	  p_x_material_txn_tbl(i).recepient_name          := l_ahl_mtltxn_tbl(i).recepient_name;
	  p_x_material_txn_tbl(i).disposition_id          := l_ahl_mtltxn_tbl(i).disposition_id;

          -- Target visit is currently not used.
          --p_x_material_txn_tbl(i).Target_Visit_Id       := l_x_ahl_mtltxn_tbl(i).Target_Visit_Id;
          --p_x_material_txn_tbl(i).Target_Visit_Num      := l_x_ahl_mtltxn_tbl(i).Target_Visit_Num;

          p_x_material_txn_tbl(i).Reason_Id               := l_ahl_mtltxn_tbl(i).Reason_Id;
          p_x_material_txn_tbl(i).Reason_Name             := l_ahl_mtltxn_tbl(i).Reason_Name;
          p_x_material_txn_tbl(i).Problem_Code            := l_ahl_mtltxn_tbl(i).Problem_Code;
          p_x_material_txn_tbl(i).Problem_Code_Meaning    := l_ahl_mtltxn_tbl(i).Problem_Code_Meaning;
          p_x_material_txn_tbl(i).Sr_Summary              := l_ahl_mtltxn_tbl(i).Sr_Summary;
          p_x_material_txn_tbl(i).Qa_Collection_Id        := l_ahl_mtltxn_tbl(i).Qa_Collection_Id;

          p_x_material_txn_tbl(i).ATTRIBUTE_CATEGORY      := l_ahl_mtltxn_tbl(i).ATTRIBUTE_CATEGORY;
          p_x_material_txn_tbl(i).ATTRIBUTE1              := l_ahl_mtltxn_tbl(i).ATTRIBUTE1;
          p_x_material_txn_tbl(i).ATTRIBUTE2              := l_ahl_mtltxn_tbl(i).ATTRIBUTE2;
          p_x_material_txn_tbl(i).ATTRIBUTE3              := l_ahl_mtltxn_tbl(i).ATTRIBUTE3;
          p_x_material_txn_tbl(i).ATTRIBUTE4              := l_ahl_mtltxn_tbl(i).ATTRIBUTE4;
          p_x_material_txn_tbl(i).ATTRIBUTE5              := l_ahl_mtltxn_tbl(i).ATTRIBUTE5;
          p_x_material_txn_tbl(i).ATTRIBUTE6              := l_ahl_mtltxn_tbl(i).ATTRIBUTE6;
          p_x_material_txn_tbl(i).ATTRIBUTE7              := l_ahl_mtltxn_tbl(i).ATTRIBUTE7;
          p_x_material_txn_tbl(i).ATTRIBUTE8              := l_ahl_mtltxn_tbl(i).ATTRIBUTE8;
          p_x_material_txn_tbl(i).ATTRIBUTE9              := l_ahl_mtltxn_tbl(i).ATTRIBUTE9;
          p_x_material_txn_tbl(i).ATTRIBUTE10             := l_ahl_mtltxn_tbl(i).ATTRIBUTE10;
          p_x_material_txn_tbl(i).ATTRIBUTE11             := l_ahl_mtltxn_tbl(i).ATTRIBUTE11;
          p_x_material_txn_tbl(i).ATTRIBUTE12             := l_ahl_mtltxn_tbl(i).ATTRIBUTE12;
          p_x_material_txn_tbl(i).ATTRIBUTE13             := l_ahl_mtltxn_tbl(i).ATTRIBUTE13;
          p_x_material_txn_tbl(i).ATTRIBUTE14             := l_ahl_mtltxn_tbl(i).ATTRIBUTE14;
          p_x_material_txn_tbl(i).ATTRIBUTE15             := l_ahl_mtltxn_tbl(i).ATTRIBUTE15;

       END LOOP;
     END IF;  -- l_ahl_mtltxn_tbl.COUNT
   END IF; -- p_x_material_txn_tbl.COUNT

   IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
   THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'Before calling Disposition API. Count on l_disp_Mtl_Txn_Tbl is:' || l_disp_Mtl_Txn_Tbl.COUNT
        );
    END IF;

   -- Call disposition API.
   IF (l_disp_Mtl_Txn_Tbl.COUNT > 0) THEN
      AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn (
                 p_api_version         => 1.0,
                 p_init_msg_list       => FND_API.G_FALSE,
                 p_commit              => FND_API.G_FALSE,
                 p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data,
                 p_module              => 'JSP',
                 p_x_disp_mtl_txn_tbl  => l_disp_Mtl_Txn_Tbl);

      IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
      THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'After call to AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn. Return status:' || x_return_status
        );
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'After call to AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn. Error count:' || x_msg_count
        );
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;

   -- Standard check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

    -- Log API exit point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.end', 'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Perform_Material_Txn_pub;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Perform_Material_Txn_pub;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    ROLLBACK TO Perform_Material_Txn_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Perform_Material_Txn;

END AHL_PRD_MATERIAL_TXN_PUB;

/
