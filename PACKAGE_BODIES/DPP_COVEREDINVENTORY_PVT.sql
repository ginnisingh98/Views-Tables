--------------------------------------------------------
--  DDL for Package Body DPP_COVEREDINVENTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_COVEREDINVENTORY_PVT" AS
/* $Header: dppvcovb.pls 120.16.12010000.5 2010/04/26 07:08:11 pvaramba ship $ */

-- Package name     : DPP_COVEREDINVENTORY_PVT
-- Purpose          :
-- History          :
-- NOTE             :Contains Procedures - Select Covered Inventory from INV, Populate Covered Inventory in DPP
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_COVEREDINVENTORY_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvcovb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Select_CoveredInventory
--
-- PURPOSE
--    Select Covered Inventory
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Select_CoveredInventory
     (p_api_Version       IN NUMBER,
      p_Init_msg_List     IN VARCHAR2 := fnd_api.g_False,
      p_Commit            IN VARCHAR2 := fnd_api.g_False,
      p_Validation_Level  IN NUMBER := fnd_api.g_Valid_Level_Full,
      x_Return_Status     OUT NOCOPY VARCHAR2,
      x_msg_Count         OUT NOCOPY NUMBER,
      x_msg_Data          OUT NOCOPY VARCHAR2,
      p_Inv_hdr_rec       IN DPP_INV_HDR_REC_TYPE,
      p_Covered_Inv_Tbl   IN OUT NOCOPY DPP_INV_COV_TBL_TYPE)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Select_CoveredInventory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_hdr_rec  							dpp_inv_hdr_rec_type:= p_inv_hdr_rec;
l_covered_inv_tbl   		dpp_inv_cov_tbl_type := p_covered_inv_tbl;
l_covered_inv_wh_tbl    dpp_inv_cov_wh_tbl_type;
l_covered_inv_rct_tbl   dpp_inv_cov_rct_tbl_type;
l_num_count 						NUMBER;
l_primary_uom_code			VARCHAR2(3);

   CURSOR get_covered_inventory_csr (p_org_id IN NUMBER,
                                     p_effective_start_date DATE,
                                     p_effective_end_date DATE,
                                     p_inventory_item_id IN NUMBER)
   IS
     SELECT sum(case when ( (NVL(moqd.orig_date_received,moqd.date_received) >= p_effective_start_date
                          AND NVL(moqd.orig_date_received,moqd.date_received) < p_effective_end_date))
     --BETWEEN p_effective_start_date and p_effective_end_date)
            then moqd.transaction_quantity else 0 end) covered_qty,
            sum(moqd.transaction_quantity) onhand_qty,
            moqd.transaction_uom_code
       FROM mtl_onhand_quantities_detail moqd,
            org_organization_definitions ood,
            mtl_parameters mp
      WHERE moqd.organization_id = ood.organization_id
        AND moqd.inventory_item_id = p_inventory_item_id
        AND mp.organization_id = ood.organization_id
        AND NVL(ood.disable_date,SYSDATE + 1) > SYSDATE
        AND ood.operating_unit = p_org_id
        AND moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.PLANNING_TP_TYPE = 2
        AND moqd.OWNING_TP_TYPE = 2
        AND moqd.IS_CONSIGNED = 2
        GROUP BY moqd.transaction_uom_code;

	CURSOR get_covered_inv_wh_csr(p_org_id IN NUMBER,
                                      p_effective_start_date DATE,
                                      p_effective_end_date DATE,
                                      p_inventory_item_id IN NUMBER)
        IS
	SELECT
	  SUM(moqd.transaction_quantity) sum,
	  ood.organization_name warehouse,
	  ood.organization_id warehouse_id
	FROM
	  mtl_onhand_quantities_detail moqd,
	  org_organization_definitions ood,
	  mtl_parameters mp
	WHERE moqd.organization_id = ood.organization_id
          AND moqd.inventory_item_id = p_inventory_item_id
          AND ood.operating_unit = p_org_id
          AND mp.organization_id = ood.organization_id
          AND NVL(ood.disable_date,SYSDATE + 1) > SYSDATE
          AND (NVL(moqd.orig_date_received,moqd.date_received) >= p_effective_start_date
              AND NVL(moqd.orig_date_received,moqd.date_received) < p_effective_end_date)
          --BETWEEN p_effective_start_date and p_effective_end_date
	  AND moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
          AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
          AND moqd.PLANNING_TP_TYPE = 2
          AND moqd.OWNING_TP_TYPE = 2
          AND moqd.IS_CONSIGNED = 2
          GROUP BY ood.organization_name,ood.organization_id;

	cursor get_covered_inv_rct_csr(p_org_id IN NUMBER, p_inventory_item_id IN NUMBER, p_warehouse_id IN NUMBER) is
	SELECT
	  (NVL(moqd.orig_date_received,moqd.date_received)) date_received,
	  SUM(moqd.transaction_quantity) sum
	FROM
	  mtl_onhand_quantities_detail moqd,
	  org_organization_definitions ood,
	  mtl_parameters mp
	WHERE
	  moqd.organization_id = ood.organization_id  AND
	  moqd.inventory_item_id = p_inventory_item_id AND
	  ood.operating_unit = p_org_id AND
	  mp.organization_id = ood.organization_id  AND
	  NVL(ood.disable_date,SYSDATE + 1) > SYSDATE AND
    moqd.organization_id = p_warehouse_id AND
		moqd.PLANNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.OWNING_ORGANIZATION_ID = mp.organization_id
        AND moqd.PLANNING_TP_TYPE = 2
        AND moqd.OWNING_TP_TYPE = 2
        AND moqd.IS_CONSIGNED = 2
    GROUP BY (NVL(moqd.orig_date_received,moqd.date_received));

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Select_CoveredInventory_PVT;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
  IF l_hdr_rec.org_id IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Org ID');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_hdr_rec.effective_start_date IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Effective Start Date');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_hdr_rec.effective_end_date IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Effective End Date');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     FOR i IN l_covered_inv_tbl.FIRST..l_covered_inv_tbl.LAST LOOP
        IF l_covered_inv_tbl(i).Transaction_Line_Id IS NULL THEN
           FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
           FND_MESSAGE.set_token('ID', 'Transaction Line ID');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_covered_inv_tbl(i).inventory_item_id IS NULL THEN
           FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
           FND_MESSAGE.set_token('ID', 'Inventory Item ID');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           FOR get_covered_inventory_rec IN get_covered_inventory_csr(l_hdr_rec.org_id, l_hdr_rec.effective_start_date, l_hdr_rec.effective_end_date, l_covered_inv_tbl(i).Inventory_ITem_ID)
           LOOP
               l_covered_inv_tbl(i).covered_quantity := NVL(get_covered_inventory_rec.covered_qty,0);
               l_covered_inv_tbl(i).onhand_quantity := NVL(get_covered_inventory_rec.onhand_qty,0);
               l_covered_inv_tbl(i).uom_code := get_covered_inventory_rec.transaction_uom_code;
               --IF covered inventory is negative then reassign it to 0
               IF l_covered_inv_tbl(i).covered_quantity < 0 THEN
                  l_covered_inv_tbl(i).covered_quantity := 0;
               END IF;
               l_num_count := 0;
               --Bug 7157230
               l_covered_inv_wh_tbl.delete;
               --Get the ware house level details only if the covered quantiy > 0
               IF l_covered_inv_tbl(i).covered_quantity > 0 THEN
                 FOR get_covered_inv_wh_rec IN get_covered_inv_wh_csr(l_hdr_rec.org_id, l_hdr_rec.effective_start_date, l_hdr_rec.effective_end_date, l_covered_inv_tbl(i).Inventory_ITem_ID)
                 LOOP
                   l_num_count := l_num_count + 1;
                   l_covered_inv_wh_tbl(l_num_count).warehouse_name :=  get_covered_inv_wh_rec.warehouse;
                   l_covered_inv_wh_tbl(l_num_count).warehouse_id :=  get_covered_inv_wh_rec.warehouse_id;
                   l_covered_inv_wh_tbl(l_num_count).covered_quantity :=  NVL(get_covered_inv_wh_rec.sum,0);
                   OPEN get_covered_inv_rct_csr(l_hdr_rec.org_id,
                                                l_covered_inv_tbl(i).Inventory_ITem_ID,
                                                get_covered_inv_wh_rec.warehouse_id);
                   LOOP
                       FETCH get_covered_inv_rct_csr BULK COLLECT INTO l_covered_inv_rct_tbl;
                       EXIT WHEN get_covered_inv_rct_csr%NOTFOUND;
                   END LOOP;
                   CLOSE get_covered_inv_rct_csr;
                   l_covered_inv_wh_tbl(l_num_count).rct_line_tbl := l_covered_inv_rct_tbl;
                 END LOOP;
               END IF; --ware house level details only if the covered quantiy > 0
               l_covered_inv_tbl(i).wh_line_tbl := l_covered_inv_wh_tbl;
           END LOOP;
			    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'On Hand Quantity: '||l_covered_inv_tbl(i).onhand_quantity);
             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Covered Quantity: '||l_covered_inv_tbl(i).covered_quantity);
             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'inventory_item_id: '||l_covered_inv_tbl(i).inventory_item_id);

           IF l_covered_inv_tbl(i).onhand_quantity IS NULL THEN
              l_covered_inv_tbl(i).covered_quantity := 0;
              l_covered_inv_tbl(i).onhand_quantity  := 0;
              BEGIN
                 SELECT primary_uom_code
                   INTO l_primary_uom_code
                   FROM mtl_system_items msi,
                        mtl_parameters mp
                  WHERE inventory_item_id = l_covered_inv_tbl(i).inventory_item_id
                    AND mp.organization_id = msi.organization_id
                    AND mp.organization_id = mp.master_organization_id
                    AND rownum = 1;
              EXCEPTION
                 WHEN OTHERS THEN
                     DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Error in fetching primary UOM: ' || SQLERRM);
                     x_return_status := FND_API.G_RET_STS_ERROR;
              END;
              l_covered_inv_tbl(i).uom_code := l_primary_uom_code; -- Default to Primary UOM
           END IF;  -- onhand qty null if
        END IF; -- txn line id null if
     END LOOP;
  END IF;
  p_covered_inv_tbl := l_covered_inv_tbl;
  x_return_status := l_return_status;
  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'select_coveredinventory(): x_return_status: ' || x_return_status);

 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Select_CoveredInventory_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );

  IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Select_CoveredInventory_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
  IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN OTHERS THEN
   ROLLBACK TO Select_CoveredInventory_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
			fnd_message.set_token('ROUTINE', 'DPP_COVEREDINVENTORY_PVT.Select_CoveredInventory');
			fnd_message.set_token('ERRNO', sqlcode);
			fnd_message.set_token('REASON', sqlerrm);
			FND_MSG_PUB.add;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
  IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


  END Select_CoveredInventory;


---------------------------------------------------------------------
-- PROCEDURE
--    Populate_CoveredInventory
--
-- PURPOSE
--    Populate Covered Inventory
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Populate_CoveredInventory(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_inv_hdr_rec	     IN    dpp_inv_hdr_rec_type
   ,p_covered_inv_tbl	 IN    dpp_inv_cov_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Populate_CoveredInventory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_inv_hdr_rec           DPP_COVEREDINVENTORY_PVT.dpp_inv_hdr_rec_type    := p_inv_hdr_rec;
l_covered_inv_tbl       DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_tbl_type    := p_covered_inv_tbl;
l_covered_inv_wh_tbl    DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_wh_tbl_type;
l_covered_inv_rct_tbl   DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_rct_tbl_type;

l_inv_details_id        NUMBER;
l_include_flag          VARCHAR2(1);
l_days_out              NUMBER;

BEGIN
------------------------------------------
-- Initialization
------------------------------------------

-- Standard begin of API savepoint
    SAVEPOINT  Populate_CoveredInventory_PVT;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
   BEGIN
     UPDATE DPP_EXECUTION_DETAILS
	   SET execution_end_date = sysdate
              ,execution_status 	= DECODE(l_return_status,FND_API.G_RET_STS_SUCCESS,'SUCCESS','WARNING')
              ,last_update_date 	= sysdate
              ,last_updated_by 	= l_inv_hdr_rec.Last_Updated_By
              ,last_update_login 	= l_inv_hdr_rec.Last_Updated_By
              ,provider_process_id = l_inv_hdr_rec.Provider_Process_Id
              ,provider_process_instance_id = l_inv_hdr_rec.Provider_Process_Instance_id
              ,output_xml 		= XMLTYPE(l_inv_hdr_rec.Output_XML)
        WHERE execution_detail_id 	= l_inv_hdr_rec.Execution_Detail_ID;

	IF SQL%ROWCOUNT = 0 THEN

           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Invalid value for Execution Detail ID: ' || l_inv_hdr_rec.Execution_Detail_ID);
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

  EXCEPTION
     WHEN OTHERS THEN
	      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  substr(('Error in Updating DPP_EXECUTION_DETAILS: ' || SQLERRM || ' from Populate Covered Inventory API'),1,4000));
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END ;

DPP_COVEREDINVENTORY_PVT.Update_CoveredInventory(
    p_api_version   	  => l_api_version
   ,p_init_msg_list	    => FND_API.G_FALSE
   ,p_commit	          => FND_API.G_FALSE
   ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	    => l_return_status
   ,x_msg_count	        => l_msg_count
   ,x_msg_data	        => l_msg_data
   ,p_inv_hdr_rec	      => l_inv_hdr_rec
   ,p_covered_inv_tbl	  => l_covered_inv_tbl
   );

   x_return_status := l_return_status;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
EXCEPTION
WHEN DPP_UTILITY_PVT.resource_locked THEN
   ROLLBACK TO Populate_CoveredInventory_PVT;
   x_return_status := FND_API.g_ret_sts_error;
   DPP_UTILITY_PVT.Error_Message(p_message_name => 'API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Populate_CoveredInventory_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Populate_CoveredInventory_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN OTHERS THEN
   ROLLBACK TO Populate_CoveredInventory_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_COVEREDINVENTORY_PVT.Populate_CoveredInventory');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      FND_MSG_PUB.add;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

  END Populate_CoveredInventory;


PROCEDURE Update_CoveredInventory(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_inv_hdr_rec	     IN    dpp_inv_hdr_rec_type
   ,p_covered_inv_tbl	 IN    dpp_inv_cov_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_CoveredInventory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_inv_hdr_rec           DPP_COVEREDINVENTORY_PVT.dpp_inv_hdr_rec_type    := p_inv_hdr_rec;
l_covered_inv_tbl       DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_tbl_type    := p_covered_inv_tbl;
l_covered_inv_wh_tbl    DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_wh_tbl_type;
l_covered_inv_rct_tbl   DPP_COVEREDINVENTORY_PVT.dpp_inv_cov_rct_tbl_type;
l_inv_details_id        NUMBER;
l_txn_lines_tbl 	      DPP_LOG_PVT.dpp_txn_line_tbl_type;
l_include_flag          VARCHAR2(1);
l_flag                  VARCHAR2(1);
l_days_out              NUMBER;
l_sysdate 		          DATE := SYSDATE;

l_price_change_flag     VARCHAR2(20);
l_user_id  NUMBER :=FND_PROFILE.VALUE('USER_ID');

TYPE  inventory_details_id_tbl IS TABLE OF dpp_inventory_details_all.inventory_details_id%TYPE
      INDEX BY PLS_INTEGER;

inventory_details_ids inventory_details_id_tbl;

BEGIN
-- Standard begin of API savepoint
    SAVEPOINT  Update_CoveredInventory_PVT;
-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
  --Check whether the last updated by value is passed
  IF l_inv_hdr_rec.Last_Updated_By IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Last Updated By');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_inv_hdr_rec.effective_start_date IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Effective Start Date');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_inv_hdr_rec.effective_end_date IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Effective End Date');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR i IN l_covered_inv_tbl.FIRST..l_covered_inv_tbl.LAST LOOP
     IF l_covered_inv_tbl(i).Transaction_Line_Id IS NULL THEN
        FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
        FND_MESSAGE.set_token('ID', 'Transaction Line ID');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
     ELSIF
        l_covered_inv_tbl(i).inventory_item_id IS NULL THEN
        FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
        FND_MESSAGE.set_token('ID', 'Inventory Item ID');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
     ELSIF
        l_covered_inv_tbl(i).UOM_Code IS NULL THEN
        FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
        FND_MESSAGE.set_token('ID', 'UOM Code');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
     ELSE
        BEGIN
	        UPDATE DPP_TRANSACTION_LINES_ALL
             SET covered_inventory 	= NVL(l_covered_inv_tbl(i).Covered_quantity,0),
             	 approved_inventory 	= NVL(l_covered_inv_tbl(i).Covered_quantity,0),
	               onhand_inventory 	= NVL(l_covered_inv_tbl(i).Onhand_Quantity,0),
	               UOM             	   = l_covered_inv_tbl(i).UOM_Code,
                 last_update_date    = l_sysdate,
                 last_updated_by     = l_inv_hdr_rec.Last_Updated_By,
                 last_calculated_by  = l_inv_hdr_rec.Last_Updated_By,
                 last_update_login   = FND_GLOBAL.LOGIN_ID,
                 last_calculated_date = l_sysdate
           WHERE transaction_line_id = l_covered_inv_tbl(i).Transaction_Line_Id;
             IF SQL%ROWCOUNT = 0 THEN

	          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Invalid value for Transaction Line ID: ' || l_covered_inv_tbl(i).Transaction_Line_Id);

               RAISE FND_API.G_EXC_ERROR;
	     END IF;
        EXCEPTION
          WHEN OTHERS THEN
             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  substr(('Error in Updating DPP_TRANSACTION_LINES_ALL: ' || SQLERRM || ' from Update Covered Inventory API'),1,4000));
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END ;

     --Get the supplier trade profile value to include price increase value for claim or not
       BEGIN
        SELECT nvl(create_claim_price_increase,'N')
          INTO l_price_change_flag
          FROM ozf_supp_trd_prfls_all ostp,
                 dpp_transaction_headers_all dtha
         WHERE ostp.supplier_id = to_number(dtha.vendor_id)
             AND ostp.supplier_site_id = to_number(dtha.vendor_site_id)
             AND ostp.org_id = to_number(dtha.org_id)
             AND dtha.transaction_header_id = l_inv_hdr_rec.transaction_header_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                  fnd_message.set_token('ERRNO', sqlcode);
                  fnd_message.set_token('REASON', 'SUPPLIER TRADE PROFILE IS NOT FOUND'); --To be modified
                  FND_MSG_PUB.add;
              IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
              END IF;
              RAISE FND_API.g_exc_error;
           WHEN OTHERS THEN
               fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                  fnd_message.set_token('ERRNO', sqlcode);
                  fnd_message.set_token('REASON', sqlerrm);
               IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                 FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_EXE_DET_ID'); --To be modified
                 fnd_message.set_token('SEQ_NAME', 'DPP_EXECUTION_DETAIL_ID_SEQ'); --To be modified
                 FND_MSG_PUB.add;
                 FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

         IF (l_price_change_flag = 'N') THEN   -- Only Price Decrease
             UPDATE dpp_transaction_lines_all dtla
               SET dtla.claim_amount = dtla.approved_inventory * price_change,
                   dtla.object_version_number =  dtla.object_version_number +1,
                   dtla.last_updated_by   = nvl(l_user_id,0),
                   dtla.last_update_login = nvl(l_user_id,0),
                   dtla.last_update_date  = sysdate
             WHERE dtla.transaction_header_id = l_inv_hdr_rec.transaction_header_id
               AND dtla.transaction_line_id = l_covered_inv_tbl(i).transaction_line_id
               AND dtla.price_change > 0;
         ELSE                                  -- Both Price Increase and Price Decrease
             UPDATE dpp_transaction_lines_all dtla
               SET dtla.claim_amount = dtla.approved_inventory * price_change,
                   dtla.object_version_number =  dtla.object_version_number +1,
                   dtla.last_updated_by   = nvl(l_user_id,0),
                   dtla.last_update_login = nvl(l_user_id,0),
                   dtla.last_update_date  = sysdate
             WHERE dtla.transaction_header_id = l_inv_hdr_rec.transaction_header_id
               AND dtla.transaction_line_id = l_covered_inv_tbl(i).transaction_line_id
               AND dtla.price_change <> 0;
         END IF;

     END IF;
-- Assign values to l_txn_lines_tbl for History
 l_txn_lines_tbl(i).log_mode                  := 'U';
 l_txn_lines_tbl(i).transaction_header_id     :=  l_inv_hdr_rec.transaction_header_id;
 l_txn_lines_tbl(i).transaction_line_id       := l_covered_inv_tbl(i).Transaction_Line_Id;
 l_txn_lines_tbl(i).covered_inventory         := NVL(l_covered_inv_tbl(i).Covered_quantity,0);
 l_txn_lines_tbl(i).org_id                    := l_inv_hdr_rec.org_id;
 l_txn_lines_tbl(i).last_update_date          := l_sysdate;
 l_txn_lines_tbl(i).last_updated_by           := l_inv_hdr_rec.Last_Updated_By;
 l_txn_lines_tbl(i).creation_date             := l_sysdate;
 l_txn_lines_tbl(i).created_by                := l_inv_hdr_rec.Last_Updated_By;
 l_txn_lines_tbl(i).last_update_login         := FND_GLOBAL.LOGIN_ID;
 l_txn_lines_tbl(i).inventory_item_id         := l_covered_inv_tbl(i).inventory_item_id;
 l_txn_lines_tbl(i).last_calculated_by        := l_inv_hdr_rec.Last_Updated_By;
 l_txn_lines_tbl(i).last_calculated_date      := l_sysdate;
 l_txn_lines_tbl(i).onhand_inventory          := NVL(l_covered_inv_tbl(i).Onhand_Quantity,0);

     BEGIN

         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Org Id: ' || l_inv_hdr_rec.org_id || 'transaction_line_id ' || l_covered_inv_tbl(i).Transaction_Line_Id);

        -- Delete existing rows in DPP_INVENTORY_DETAILS_ADJ_ALL (if any)
				SELECT
					inventory_details_id
				BULK COLLECT INTO
					inventory_details_ids
				FROM
					dpp_inventory_details_all
				WHERE
					org_id = l_inv_hdr_rec.org_id
				 AND transaction_line_id = l_covered_inv_tbl(i).Transaction_Line_Id;

   FORALL indx IN inventory_details_ids.FIRST .. inventory_details_ids .LAST
   DELETE
	  FROM DPP_INVENTORY_DETAILS_ADJ_ALL
	 WHERE INVENTORY_DETAILS_ID = inventory_details_ids(indx);

  -- Delete existing rows in DPP_INVENTORY_DETAILS_ALL (if any)
	DELETE
	  FROM DPP_INVENTORY_DETAILS_ALL
	 WHERE org_id = l_inv_hdr_rec.org_id
	   AND transaction_line_id = l_covered_inv_tbl(i).Transaction_Line_Id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
         IF g_debug THEN
						fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
						fnd_message.set_token('ROUTINE', 'DPP_COVEREDINVENTORY_PVT.Update_CoveredInventory - Delete rows');
						fnd_message.set_token('ERRNO', sqlcode);
						fnd_message.set_token('REASON', sqlerrm);
						FND_MSG_PUB.add;
				 END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;
    --Insert child records if covered quantity <> 0
    IF NVL(l_covered_inv_tbl(i).Covered_quantity,0) <> 0 THEN
       FOR j IN l_covered_inv_tbl(i).wh_line_tbl.FIRST..l_covered_inv_tbl(i).wh_line_tbl.LAST LOOP
           SELECT DPP_INVENTORY_DETAILS_SEQ.nextval
             INTO l_inv_details_id
             FROM DUAL;
         l_flag := 'N';
         INSERT INTO DPP_INVENTORY_DETAILS_ALL(
                inventory_details_id,
                transaction_line_id,
                quantity,
                uom,
                include_flag,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                inventory_item_id,
                org_id,
                organization_id,
                object_version_number)
        VALUES(	l_inv_details_id,
                l_covered_inv_tbl(i).Transaction_Line_Id,
                NVL(l_covered_inv_tbl(i).wh_line_tbl(j).Covered_quantity,0),
                l_covered_inv_tbl(i).UOM_Code,
                'N',
                l_sysdate,
                l_inv_hdr_rec.Last_Updated_By,
                l_sysdate,
                l_inv_hdr_rec.Last_Updated_By,
                l_inv_hdr_rec.Last_Updated_By,
                l_covered_inv_tbl(i).inventory_item_id,
                l_inv_hdr_rec.org_id,
                l_covered_inv_tbl(i).wh_line_tbl(j).Warehouse_id,
                1);

             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Inventory Details ID: '||l_inv_details_id);

          FOR k IN l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl.FIRST..l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl.LAST LOOP
              BEGIN
                IF ((l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received >= l_inv_hdr_rec.effective_start_date)
                    AND (l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received < l_inv_hdr_rec.effective_end_date)) THEN
                   l_include_flag := 'Y';
                   l_flag := 'Y';
                   l_days_out      := 0;
                ELSIF (l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received < l_inv_hdr_rec.effective_start_date) THEN
                   l_include_flag := 'N';
                   l_days_out     := -(l_inv_hdr_rec.effective_start_date - l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received);
                   l_days_out := floor(l_days_out);
                ELSIF (l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received >= l_inv_hdr_rec.effective_end_date ) THEN
                   l_include_flag := 'N';
                   l_days_out     := l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received - l_inv_hdr_rec.effective_end_date;
                   l_days_out := ceil(l_days_out);
                   IF l_days_out = 0 THEN
                      l_days_out := 1;
                   END IF;
                END IF;
              END;

          INSERT INTO DPP_INVENTORY_DETAILS_ADJ_ALL(
						inv_details_adj_id,
						inventory_details_id,
						date_received,
						days_out,
						quantity,
						uom,
						comments,
						include_flag,
						creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login,
						org_id,
						object_version_number)
					VALUES(dpp_inv_details_adj_id_seq.nextval,
						l_inv_details_id,
						l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).date_received,
						l_days_out,
						NVL(l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl(k).Onhand_quantity,0),
						l_covered_inv_tbl(i).UOM_Code,
						null,
						l_include_flag,
						l_sysdate,
						l_inv_hdr_rec.Last_Updated_By,
						l_sysdate,
						l_inv_hdr_rec.Last_Updated_By,
						l_inv_hdr_rec.Last_Updated_By,
						l_inv_hdr_rec.org_id,
						1
						);

          END LOOP;  --l_covered_inv_tbl(i).wh_line_tbl(j).rct_line_tbl.FIRST..
          IF l_flag = 'Y' THEN
             UPDATE DPP_INVENTORY_DETAILS_ALL
                SET include_flag = 'Y',
                    object_version_number = object_version_number + 1,
                    last_update_date = l_sysdate,
                    last_updated_by = l_inv_hdr_rec.Last_Updated_By,
                    last_update_login = l_inv_hdr_rec.Last_Updated_By
              WHERE inventory_details_id = l_inv_details_id;
          END IF;
       END LOOP; --l_covered_inv_tbl(i).wh_line_tbl.FIRST
    END IF; -- qty > 0

END LOOP;

--For insertion into Log table
  DPP_LOG_PVT.Insert_LinesLog(p_api_version      => 1.0
                             ,p_init_msg_list    => FND_API.G_FALSE
                             ,p_commit	         => FND_API.G_FALSE
                             ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                             ,x_return_status	 		=> l_return_status
                             ,x_msg_count	 				=> l_msg_count
                             ,x_msg_data	 				=> l_msg_data
                             ,p_txn_lines_tbl	 		=> l_txn_lines_tbl
                             );

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'return status for Insert_LinesLog =>'||l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  substr(('Message dat for the DPP Insert_LinesLog API =>'||l_msg_data),1,4000));
   END IF;


 x_return_status := l_return_status;
-- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
EXCEPTION
   WHEN DPP_UTILITY_PVT.resource_locked THEN
      ROLLBACK TO Update_CoveredInventory_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      DPP_UTILITY_PVT.Error_Message(p_message_name => 'API_RESOURCE_LOCKED');
      FND_MSG_PUB.Count_And_Get (
		 p_encoded => FND_API.G_FALSE,
		 p_count   => x_msg_count,
		 p_data    => x_msg_data
		 );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

	WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO Update_CoveredInventory_PVT;
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 -- Standard call to get message count and if count=1, get the message
		 FND_MSG_PUB.Count_And_Get (
		 p_encoded => FND_API.G_FALSE,
		 p_count   => x_msg_count,
		 p_data    => x_msg_data
		 );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO Update_CoveredInventory_PVT;
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 -- Standard call to get message count and if count=1, get the message
		 FND_MSG_PUB.Count_And_Get (
		 p_encoded => FND_API.G_FALSE,
		 p_count => x_msg_count,
		 p_data  => x_msg_data
		 );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

	WHEN OTHERS THEN
		 ROLLBACK TO Update_CoveredInventory_PVT;
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
				fnd_message.set_token('ROUTINE', 'DPP_COVEREDINVENTORY_PVT.Update_CoveredInventory');
				fnd_message.set_token('ERRNO', sqlcode);
				fnd_message.set_token('REASON', sqlerrm);
				FND_MSG_PUB.add;
		 -- Standard call to get message count and if count=1, get the message
		 FND_MSG_PUB.Count_And_Get (
		 p_encoded => FND_API.G_FALSE,
		 p_count => x_msg_count,
		 p_data  => x_msg_data
		 );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


END Update_CoveredInventory;

END DPP_COVEREDINVENTORY_PVT;

/
