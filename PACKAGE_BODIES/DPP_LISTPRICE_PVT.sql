--------------------------------------------------------
--  DDL for Package Body DPP_LISTPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_LISTPRICE_PVT" AS
/* $Header: dppvlprb.pls 120.19.12010000.2 2010/04/21 11:33:45 anbbalas ship $ */

-- Package name     : DPP_LISTPRICE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_LISTPRICE_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvlprb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Update_ListPrice
--
-- PURPOSE
--    Update list price.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_ListPrice(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	 NOCOPY NUMBER
   ,x_msg_data	         OUT 	 NOCOPY VARCHAR2
   ,p_txn_hdr_rec	     IN    dpp_txn_hdr_rec_type
   ,p_item_cost_tbl	     IN    dpp_txn_line_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_ListPrice';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_LISTPRICE_PVT.UPDATE_LISTPRICE';

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_txn_hdr_rec           DPP_LISTPRICE_PVT.dpp_txn_hdr_rec_type := p_txn_hdr_rec;
l_item_cost_tbl         DPP_LISTPRICE_PVT.dpp_txn_line_tbl_type := p_item_cost_tbl;
l_exe_update_rec 	DPP_ExecutionDetails_PVT.DPP_EXE_UPDATE_REC_TYPE;
l_status_Update_tbl 	DPP_ExecutionDetails_PVT.dpp_status_Update_tbl_type;

l_to_amount            NUMBER := 0;
l_set_of_books_id      NUMBER;
l_mrc_sob_type_code    VARCHAR2(1);
l_fc_currency_code     VARCHAR2(15);
l_exchange_rate_type   VARCHAR2(30);
l_exchange_rate        NUMBER;
l_execution_status     VARCHAR2(10);

l_item_rec              INV_ITEM_GRP.Item_rec_type;
l_x_item_rec            INV_ITEM_GRP.Item_rec_type;
l_error_tbl             INV_ITEM_GRP.Error_tbl_type;
l_revision_rec          INV_ITEM_GRP.Item_Revision_Rec_Type;

l_output_xml		CLOB;
l_queryCtx              dbms_xmlquery.ctxType;
l_Transaction_Number    CLOB;
l_control_level         NUMBER;
l_count                 NUMBER;
l_reason                fnd_new_messages.message_text%TYPE;
l_item_number           VARCHAR2(240);

CURSOR Item_cur(p_inventory_item_id IN NUMBER,p_org_id IN NUMBER, p_control_level IN NUMBER)
IS
SELECT  DECODE( p_control_level, 1, mp.master_organization_id, 2, mp.organization_id) organization_id,
        msi.concatenated_segments item_number
FROM    mtl_parameters mp,
        financials_system_params_all fspa,
        mtl_system_items_kfv msi
WHERE   mp.organization_id = fspa.inventory_organization_id and
        mp.organization_id = msi.organization_id  and
        msi.inventory_item_id = p_inventory_item_id and
        fspa.org_id = p_org_id;

BEGIN
-- Standard begin of API savepoint
    SAVEPOINT  Update_ListPrice_PVT;
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
   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := l_return_status;
--
-- API body
--
  IF l_txn_hdr_rec.org_id IS NULL THEN
         FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
         FND_MESSAGE.set_token('ID', 'Org ID');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
  ELSIF l_txn_hdr_rec.Transaction_Number IS NULL THEN
         FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
         FND_MESSAGE.set_token('ID', 'Transaction Number');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
  ELSIF l_txn_hdr_rec.Transaction_Header_ID IS NULL THEN
         FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
         FND_MESSAGE.set_token('ID', 'Transaction Header ID');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
  END IF;
--Assign
l_Transaction_Number := ''''||l_txn_hdr_rec.Transaction_Number||'''';

--Control Level:1 - Master level, 2 - Org level
  BEGIN
     SELECT control_level
       INTO l_control_level
       FROM mtl_item_attributes_v miav,
            mtl_item_attr_appl_inst_v miaaiv
      WHERE status_control_code IS NULL
        AND miaaiv.attribute_name = miav.attribute_name
        AND miaaiv.attribute_name = 'MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT';
  EXCEPTION
     WHEN NO_DATA_FOUND THEN --
         FND_MESSAGE.set_name('DPP', 'DPP_INVALID_CONTROL_LEVEL');
         FND_MSG_PUB.add;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_LISTPRICE_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', sqlerrm);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;
   IF l_item_cost_tbl.EXISTS(1) THEN
      FOR i IN l_item_cost_tbl.FIRST..l_item_cost_tbl.LAST LOOP
          l_to_amount := 0;
          DPP_UTILITY_PVT.calculate_functional_curr(p_from_amount          => l_item_cost_tbl(i).new_price
						   ,p_conv_date            => SYSDATE
                                                   ,p_tc_currency_code     => l_item_cost_tbl(i).currency
                                                   ,p_org_id               => l_txn_hdr_rec.org_id
                                                   ,x_to_amount            => l_to_amount
                                                   ,x_set_of_books_id      => l_set_of_books_id
                                                   ,x_mrc_sob_type_code    => l_mrc_sob_type_code
                                                   ,x_fc_currency_code     => l_fc_currency_code
                                                   ,x_exchange_rate_type   => l_exchange_rate_type
                                                   ,x_exchange_rate        => l_exchange_rate
                                                   ,x_return_status        => l_return_status);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_item_cost_tbl(i).inventory_item_id IS NULL THEN
             FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
             FND_MESSAGE.set_token('ID', 'Inventory Item ID');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_count := 0;
          FOR Item_rec IN Item_cur(l_item_cost_tbl(i).inventory_item_id,l_txn_hdr_rec.org_id, l_control_level)  LOOP
              l_item_cost_tbl(i).item_number := Item_rec.item_number;
              l_item_rec.inventory_item_id := l_item_cost_tbl(i).inventory_item_id;
              l_item_rec.organization_id := Item_rec.organization_id;
              l_item_rec.list_price_per_unit := NVL(l_to_amount,l_item_cost_tbl(i).new_price);
              l_count := l_count + 1;

              inv_item_grp.Update_Item(p_commit              => fnd_api.g_FALSE
                                    ,  p_lock_rows           => fnd_api.g_TRUE
                                    ,  p_validation_level    => fnd_api.g_VALID_LEVEL_FULL
                                    ,  p_Item_rec            => l_item_rec
                                    ,  x_Item_rec            => l_x_item_rec
                                    ,  x_return_status       => l_return_status
                                    ,  x_Error_tbl           => l_error_tbl
                                    ,  p_Template_Id         => NULL
                                    ,  p_Template_Name       => NULL
                                    ,  p_Revision_rec        => l_revision_rec
                                    );
              IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 l_item_cost_tbl(i).update_status := 'Y';
                 INSERT INTO DPP_OUTPUT_XML_GT(Item_Number,
                                               NewPrice,
                                               Currency,
                                               Reason_For_Failure)
                                        VALUES(l_item_cost_tbl(i).item_number,
                                               l_item_rec.list_price_per_unit,
                                               l_item_cost_tbl(i).Currency,
                                               NULL);
              ELSE
                 l_item_cost_tbl(i).update_status := 'N';
                 l_return_status := FND_API.G_RET_STS_ERROR;
                 FOR j IN l_error_tbl.FIRST..l_error_tbl.LAST LOOP
                     l_item_cost_tbl(i).Reason_For_Failure := NVL(l_item_cost_tbl(i).Reason_For_Failure,' ')
                                                              ||'Org ID: '||Item_rec.organization_id
                                                              ||' Error: '||l_error_tbl(j).MESSAGE_TEXT;

                     INSERT INTO DPP_OUTPUT_XML_GT(
                        Item_Number,NewPrice,
                        Currency,Reason_For_Failure)
                     VALUES(
                        l_item_cost_tbl(i).item_number,l_item_rec.list_price_per_unit,
                        l_item_cost_tbl(i).Currency,l_item_cost_tbl(i).Reason_For_Failure);
                 END LOOP;
              END IF;
              IF x_return_status NOT IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := l_return_status;
              END IF;
          END LOOP;
          --Check if the item belongs to that inventory organization
          IF l_count = 0 THEN
             l_item_cost_tbl(i).update_status := 'N';
             l_return_status := FND_API.G_RET_STS_ERROR;
             SELECT fnd_message.get_string('DPP','DPP_INVALID_ITEM')
               INTO l_reason
               FROM dual;

             SELECT DISTINCT(concatenated_segments)
               INTO l_item_number
               FROM mtl_system_items_kfv
              WHERE inventory_item_id = l_item_cost_tbl(i).inventory_item_id;

             INSERT INTO DPP_OUTPUT_XML_GT(Item_Number,
                                           NewPrice,
                                           Currency,
                                           Reason_For_Failure)
                                    VALUES(l_item_number,
                                           NVL(l_to_amount,l_item_cost_tbl(i).new_price),
                                           l_item_cost_tbl(i).Currency,
                                           l_reason);
          END IF;
          IF x_return_status NOT IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
          END IF;
          l_status_Update_tbl(i).transaction_line_id := l_item_cost_tbl(i).transaction_line_id;
          l_status_Update_tbl(i).update_status := l_item_cost_tbl(i).update_status;
       END LOOP;
   ELSE
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Line Details');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   BEGIN
     IF x_return_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
        l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_Transaction_Number||' TXNNUMBER,
                                                CURSOR (Select Item_Number ITEMNUMBER,
                                                NewPrice NEWPRICE,
                                                Currency CURRENCY,
                                                Reason_For_Failure REASON
                                                from DPP_OUTPUT_XML_GT
                                                where Reason_For_Failure IS NOT NULL) TRANSACTION from dual');
     ELSE
        l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_Transaction_Number||' TXNNUMBER from dual');
     END IF;
     dbms_xmlquery.setRowTag(l_queryCtx
                            ,'ROOT'
                            );
     l_output_xml := dbms_xmlquery.getXml(l_queryCtx);
     dbms_xmlquery.closeContext(l_queryCtx);
   EXCEPTION
      WHEN OTHERS THEN
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_LISTPRICE_PVT.Update_ListPrice');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         fnd_msg_pub.add;
   END;
   IF x_return_status NOT IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
   END IF;

		SELECT DECODE(x_return_status,'S','SUCCESS','WARNING')
		INTO l_execution_status
		FROM DUAL;

    l_exe_update_rec.Transaction_Header_ID 	:= l_txn_hdr_rec.Transaction_Header_ID;
    l_exe_update_rec.Org_ID 			:= l_txn_hdr_rec.Org_ID;
    l_exe_update_rec.Execution_Detail_ID 	:= l_txn_hdr_rec.Execution_Detail_ID;
    l_exe_update_rec.Output_XML 		:= l_output_xml;
    l_exe_update_rec.EXECUTION_Status 		:= l_execution_status;
    l_exe_update_rec.Execution_End_Date 	:= SYSDATE;
    l_exe_update_rec.Provider_Process_Id 	:= l_txn_hdr_rec.Provider_Process_Id;
    l_exe_update_rec.Provider_Process_Instance_id := l_txn_hdr_rec.Provider_Process_Instance_id;
    l_exe_update_rec.Last_Updated_By 		:= l_txn_hdr_rec.Last_Updated_By;

    DPP_ExecutionDetails_PVT.Update_ExecutionDetails(
		         p_api_version   	 	=> l_api_version
		        ,p_init_msg_list	 	=> FND_API.G_FALSE
		        ,p_commit	         	=> FND_API.G_FALSE
		        ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
		        ,x_return_status	 	=> l_return_status
		        ,x_msg_count	     	=> l_msg_count
		        ,x_msg_data	         => l_msg_data
		        ,p_EXE_UPDATE_rec	   => l_exe_update_rec
		        ,p_status_Update_tbl => l_status_Update_tbl
        );

  IF x_return_status NOT IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := l_return_status;
  END IF;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     FND_MESSAGE.set_name('DPP', 'DPP_UPDATE_ITEM_ERR');
     x_msg_data := fnd_message.get();
  END IF;

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
 /*  FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;*/


--Exception Handling
    EXCEPTION
WHEN DPP_UTILITY_PVT.resource_locked THEN
   ROLLBACK TO UPDATE_LISTPRICE_PVT;
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
   ROLLBACK TO UPDATE_LISTPRICE_PVT;
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
   ROLLBACK TO UPDATE_LISTPRICE_PVT;
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
   ROLLBACK TO UPDATE_LISTPRICE_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	 fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
	 fnd_message.set_token('ROUTINE', l_full_name);
   fnd_message.set_token('ERRNO', sqlcode);
   fnd_message.set_token('REASON', sqlerrm);
   fnd_msg_pub.add;
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

  END Update_ListPrice;

END DPP_LISTPRICE_PVT;

/
