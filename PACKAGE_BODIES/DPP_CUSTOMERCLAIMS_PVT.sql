--------------------------------------------------------
--  DDL for Package Body DPP_CUSTOMERCLAIMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_CUSTOMERCLAIMS_PVT" AS
/* $Header: dppvcusb.pls 120.20.12010000.2 2010/04/21 13:35:54 kansari ship $ */

-- Package name     : DPP_CUSTOMERCLAIMS_PVT
-- Purpose          :
-- History          :
-- NOTE             : Contains Procedures - Select Data for Customer Claims Tab Prepopulation, Populate data in DPP
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_CUSTOMERCLAIMS_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvcusb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Select_CustomerPrice
--
-- PURPOSE
--    Select Customer Price
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Select_CustomerPrice(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_cust_hdr_rec	 IN   dpp_cust_hdr_rec_type
   ,p_customer_tbl	     IN OUT NOCOPY  dpp_customer_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Select_CustomerPrice';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_result                number;
l_count                 number;


l_return_status         varchar2(30);
l_msg_count             number;
l_msg_data              varchar2(4000);

l_cust_hdr_rec          DPP_CUSTOMERCLAIMS_PVT.dpp_cust_hdr_rec_type := p_cust_hdr_rec;
l_customer_tbl          DPP_CUSTOMERCLAIMS_PVT.dpp_customer_tbl_type := p_customer_tbl;
l_customer_price_tbl    DPP_CUSTOMERCLAIMS_PVT.dpp_customer_price_tbl_type;
l_module 				CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_CUSTOMERCLAIMS_PVT.SELECT_CUSTOMERPRICE';

    CURSOR get_customer_csr (p_org_id IN NUMBER,
                             p_inventory_item_id IN NUMBER,
                             p_start_date IN DATE,
                             p_end_date IN DATE) IS
    SELECT oola.sold_to_org_id customer_id
      FROM oe_order_headers_all ooha,
           oe_order_lines_all oola,
           hz_cust_accounts hca
     WHERE ooha.header_id = oola.header_id
       AND ooha.org_id = oola.org_id
       AND ooha.org_id = p_org_id
       AND oola.inventory_item_id = p_inventory_item_id
       AND (actual_shipment_date >= p_start_date AND actual_shipment_date < p_end_date)
       --BETWEEN p_start_date AND p_end_date
       AND hca.cust_account_id = oola.sold_to_org_id
       AND hca.status = 'A'
  GROUP BY oola.sold_to_org_id;

    CURSOR get_last_price_csr (p_org_id IN NUMBER,
                               p_inventory_item_id IN NUMBER,
                               p_customer_id	IN NUMBER,
                               p_uom_code IN VARCHAR2) IS
 SELECT
   rct.sold_to_customer_id cust_account_id,
   unit_selling_price last_price,
   rct.invoice_currency_code
 FROM
   ra_customer_trx_lines_all rctl,
   ra_customer_trx_all rct,
   ra_cust_trx_types_all rctt
 WHERE
   line_type = 'LINE'  AND
   inventory_item_id = p_inventory_item_id  AND
   uom_code = p_uom_code AND
   rct.customer_trx_id = rctl.customer_trx_id AND
   rct.org_id = p_org_id AND
   rctt.cust_trx_type_id = rct.cust_trx_type_id     AND
   rct.org_id = rctt.org_id     AND
   rctt.name = 'Invoice' AND
   rct.org_id = rctl.org_id AND
   rct.sold_to_customer_id = p_customer_id AND
   rct.complete_flag = 'Y' AND
   rctl.customer_trx_line_id = (
 SELECT
   MAX(rctl1.customer_trx_line_id)
 FROM
   ra_customer_trx_lines_all rctl1,
   ra_customer_trx_all rct1,
   ra_cust_trx_types_all rctt1
 WHERE
   line_type = 'LINE'  AND
   inventory_item_id = p_inventory_item_id  AND
   uom_code = p_uom_code AND
   rct1.customer_trx_id = rctl1.customer_trx_id AND
   rct1.org_id = p_org_id AND
   rctt1.cust_trx_type_id = rct1.cust_trx_type_id     AND
   rct1.org_id = rctt1.org_id     AND
   rctt1.name = 'Invoice' AND
   rct1.org_id = rctl1.org_id AND
   rct1.sold_to_customer_id = p_customer_id AND
   rct1.complete_flag = 'Y');

BEGIN


-- Standard begin of API savepoint
    SAVEPOINT  Select_CustomerPrice_PVT;
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

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
   IF l_cust_hdr_rec.org_id IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Org ID');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_cust_hdr_rec.Effective_Start_Date IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Effective Start Date');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_cust_hdr_rec.Effective_End_Date IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Effective End Date');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_cust_hdr_rec.currency_code IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Currency Code');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
    IF l_customer_tbl.EXISTS(1) THEN
      FOR i IN l_customer_tbl.FIRST..l_customer_tbl.LAST LOOP
         IF l_customer_tbl(i).inventory_item_id IS NULL THEN
            FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
            FND_MESSAGE.set_token('ID', 'Inventory Item Id');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_customer_tbl(i).uom_code IS NULL THEN
            FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
            FND_MESSAGE.set_token('ID', 'UOM Code');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
         ELSE --Inventory item id null
            l_customer_price_tbl.delete();
            l_count :=0;
            FOR get_customer_rec IN get_customer_csr(to_number(l_cust_hdr_rec.org_id),
                                                     to_number(l_customer_tbl(i).inventory_item_id),
                                                     l_cust_hdr_rec.Effective_Start_Date,
                                                     l_cust_hdr_rec.Effective_End_Date) LOOP
                l_count := l_count + 1;
                l_customer_price_tbl(l_count).cust_account_id :=  get_customer_rec.customer_id;
                -- Debug Message

			    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Start Date: ' || l_cust_hdr_rec.Effective_Start_Date );
			    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'End Date: ' || l_cust_hdr_rec.Effective_End_Date );
			    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Formatted Start Date: ' || to_char(l_cust_hdr_rec.Effective_Start_Date,'DD-MON-YYYY') );
			    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Formatted End Date: ' || to_char(l_cust_hdr_rec.Effective_End_Date,'DD-MON-YYYY') );

                FOR get_last_price_rec IN get_last_price_csr(to_number(l_cust_hdr_rec.org_id),
                                                             to_number(l_customer_tbl(i).inventory_item_id),
                                                             get_customer_rec.customer_id,
                                                             l_customer_tbl(i).uom_code) LOOP
                    l_customer_price_tbl(l_count).last_price :=  nvl(get_last_price_rec.last_price,0);
                    l_customer_price_tbl(l_count).invoice_currency_code := nvl(get_last_price_rec.invoice_currency_code,l_cust_hdr_rec.Currency_code);
	        END LOOP;
                IF l_customer_price_tbl(l_count).last_price IS NULL THEN
                   l_customer_price_tbl(l_count).last_price := 0 ;
                   l_customer_price_tbl(l_count).invoice_currency_code := l_cust_hdr_rec.currency_code;
                END IF;
   	    END LOOP;
	    IF l_customer_price_tbl.COUNT = 0 THEN
               l_customer_price_tbl(1).cust_account_id 	:= NULL;
               l_customer_price_tbl(1).last_price 	:= NULL;
               l_customer_price_tbl(1).invoice_currency_code	:= NULL;
            END IF;
            l_customer_tbl(i).customer_price_tbl := l_customer_price_tbl;
         END IF; --Inventory item id null
      END LOOP;
    ELSE --No line details available
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Line Details');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    p_customer_tbl := l_customer_tbl;
    x_return_status := l_return_status;
  END IF;
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );


--Exception Handling
    EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Select_CustomerPrice_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Select_CustomerPrice_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

WHEN OTHERS THEN
   ROLLBACK TO Select_CustomerPrice_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
			fnd_message.set_token('ROUTINE', 'DPP_CUSTOMERCLAIMS_PVT.Select_CustomerPrice');
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
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

  END Select_CustomerPrice;


---------------------------------------------------------------------
-- PROCEDURE
--    Populate_CustomerPrice
--
-- PURPOSE
--    Populate Customer and Price
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Populate_CustomerPrice(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_TRUE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_cust_hdr_rec	 IN    dpp_cust_hdr_rec_type
   ,p_customer_tbl	     IN    dpp_customer_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Populate_CustomerPrice';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status         varchar2(30);
l_msg_count             number;
l_msg_data              varchar2(4000);

l_cust_hdr_rec         dpp_cust_hdr_rec_type := p_cust_hdr_rec;
l_customer_tbl         dpp_customer_tbl_type := p_customer_tbl;
l_customer_price_tbl   dpp_customer_price_tbl_type;
l_claim_lines_tbl      DPP_LOG_PVT.dpp_claim_line_tbl_type;
l_hdr_rec              DPP_UTILITY_PVT.dpp_inv_hdr_rec_type;
l_cust_inv_tbl         DPP_UTILITY_PVT.dpp_cust_inv_tbl_type;

--l_lastprice_tbl        DPP_UTILITY_PVT.dpp_cust_price_tbl_type;
l_result               NUMBER;
l_cust_inv_line_id     NUMBER;
l_line_number 	       NUMBER := 0;
l_sysdate	       DATE := SYSDATE;
l_supp_new_price       NUMBER := 0;
l_conv_supp_new_price  NUMBER := 0;
l_rnd_supp_new_price   NUMBER := 0;
l_conv_cust_new_price  NUMBER := 0;
l_rnd_cust_new_price   NUMBER := 0;
l_price_change	       NUMBER := 0;
l_conv_price_change    NUMBER := 0;
l_rnd_price_change     NUMBER := 0;
l_reported_inventory   NUMBER := 0;
l_exchange_rate        NUMBER;
l_rec_count 	       NUMBER;
l_supp_claim_amt       NUMBER;
l_cust_claim_amt       NUMBER;
l_last_price           NUMBER;
l_rounding             NUMBER := fnd_profile.VALUE('DPP_NEW_PRICE_DECIMAL_PRECISION');
l_module 			   CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_CUSTOMERCLAIMS_PVT.POPULATE_CUSTOMERPRICE';

BEGIN
-- Standard begin of API savepoint
    SAVEPOINT  Populate_CustomerPrice_PVT;
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

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
--Assign ) to thr rounding value
IF l_rounding IS NULL THEN
   l_rounding := 4;
END IF;

IF l_cust_hdr_rec.org_id IS NULL THEN
   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
   FND_MESSAGE.set_token('ID', 'Org Id');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
ELSIF  l_cust_hdr_rec.effective_start_date IS NULL THEN
   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
   FND_MESSAGE.set_token('ID', 'Effective Start Date');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
ELSIF  l_cust_hdr_rec.effective_end_date IS NULL THEN
   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
   FND_MESSAGE.set_token('ID', 'Effective End Date');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
ELSIF  l_cust_hdr_rec.currency_code IS NULL THEN
   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
   FND_MESSAGE.set_token('ID', 'Currency Code');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
ELSE
   IF l_customer_tbl.EXISTS(1) THEN
      FOR i IN l_customer_tbl.FIRST..l_customer_tbl.LAST LOOP
          l_supp_new_price := 0;
          IF l_customer_tbl(i).inventory_item_id IS NULL THEN
             FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
             FND_MESSAGE.set_token('ID', 'Inventory Item Id');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          ELSE
             BEGIN
                SELECT SUPPLIER_NEW_PRICE, PRICE_CHANGE
                  INTO l_supp_new_price, l_price_change
                  FROM DPP_TRANSACTION_LINES_ALL
                 WHERE transaction_line_id = l_customer_tbl(i).transaction_line_id;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_supp_new_price := 0;
             END;
             -- Debug Message

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Supp Price: '||l_supp_new_price);

             IF l_customer_tbl(i).customer_price_tbl.EXISTS(1) THEN
                FOR j IN l_customer_tbl(i).customer_price_tbl.FIRST..l_customer_tbl(i).customer_price_tbl.LAST LOOP
                    l_conv_supp_new_price := 0;
                    l_rnd_supp_new_price := 0;
                    l_conv_price_change   := 0;
                    l_rnd_price_change  := 0;
                    l_reported_inventory	 := 0;
                    IF l_customer_tbl(i).customer_price_tbl(j).cust_account_id IS NOT NULL THEN
                       SELECT DPP_CUST_INV_LINE_ID_SEQ.nextval
                         INTO l_cust_inv_line_id
                         FROM DUAL;
                       l_line_number          := l_line_number + 1;
                       l_hdr_rec.org_id       := l_cust_hdr_rec.org_id;
                       l_hdr_rec.effective_start_date 	:= l_cust_hdr_rec.effective_start_date;
                       l_hdr_rec.effective_end_date 	:= l_cust_hdr_rec.effective_end_date;

                       l_cust_inv_tbl.delete();
                       l_cust_inv_tbl(1).inventory_item_id := to_number(l_customer_tbl(i).inventory_item_id);
                       l_cust_inv_tbl(1).customer_id 	:= l_customer_tbl(i).customer_price_tbl(j).cust_account_id;

                       DPP_UTILITY_PVT.Get_CustomerInventory(p_hdr_rec 		=> l_hdr_rec
                                                            ,p_cust_inv_tbl	=> l_cust_inv_tbl
                                                            ,x_rec_count 		=> l_rec_count
                                                            ,x_return_status	=> l_return_status
                                                            );
                       --Debug Message

                       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Return status for Get_CustomerInventory: '||l_return_status);
                       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Cust O/H: '||l_cust_inv_tbl(1).onhand_quantity);
                       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Customer ID: '||l_customer_tbl(i).customer_price_tbl(j).cust_account_id);

	               --Convert supp new price
                       DPP_UTILITY_PVT.convert_currency(p_from_currency   => l_cust_hdr_rec.currency_code
                                                       ,p_to_currency     => l_customer_tbl(i).customer_price_tbl(j).invoice_currency_code
                                                       ,p_conv_type       => FND_API.G_MISS_CHAR
                                                       ,p_conv_rate       => FND_API.G_MISS_NUM
                                                       ,p_conv_date       => trunc(SYSDATE)
                                                       ,p_from_amount     => l_supp_new_price
                                                       ,x_return_status   => l_return_status
                                                       ,x_to_amount       => l_conv_supp_new_price
                                                       ,x_rate            => l_exchange_rate);
                       l_rnd_supp_new_price := ROUND(l_conv_supp_new_price,l_rounding);
                       IF l_price_change <> 0 THEN
                          -- convert price change
                          DPP_UTILITY_PVT.convert_currency(p_from_currency   => l_cust_hdr_rec.currency_code
                                                          ,p_to_currency     => l_customer_tbl(i).customer_price_tbl(j).invoice_currency_code
                                                          ,p_conv_type       => FND_API.G_MISS_CHAR
                                                          ,p_conv_rate       => FND_API.G_MISS_NUM
                                                          ,p_conv_date       => trunc(SYSDATE)
                                                          ,p_from_amount     => l_price_change
                                                          ,x_return_status   => l_return_status
                                                          ,x_to_amount       => l_conv_price_change
                                                          ,x_rate            => l_exchange_rate);
                       l_rnd_price_change := ROUND(l_conv_price_change,l_rounding);
                       ELSE
                          l_conv_price_change := 0;
                          l_rnd_price_change :=0;
                       END IF;
                       -- if last invoice price is not available, default customer new price to 0.
                       IF NVL(l_customer_tbl(i).customer_price_tbl(j).last_price,0) > 0 THEN
                          l_conv_cust_new_price := NVL(l_customer_tbl(i).customer_price_tbl(j).last_price,0) - l_rnd_price_change;
                          l_rnd_cust_new_price := ROUND(l_conv_cust_new_price,l_rounding);
                          IF l_rnd_cust_new_price < 0 THEN
                             l_rnd_cust_new_price := 0;
                          END IF;
                       ELSE
                          l_conv_cust_new_price := 0;
                          l_rnd_cust_new_price := 0;
                       END IF;
                       -- If calculated inventory is -ve, then reported inventory should be 0.
                       IF NVL(l_cust_inv_tbl(1).onhand_quantity,0)	< 0 THEN
                          l_reported_inventory		:= 0;
                       ELSE
                          l_reported_inventory  := NVL(l_cust_inv_tbl(1).onhand_quantity,0);
                       END IF;
                       --Calculate the supplier and the customer claim amount
                       --prior price = last_price
                       --price change := converted price change from get_last price api
                       l_last_price := ROUND(NVL(l_customer_tbl(i).customer_price_tbl(j).last_price,0),l_rounding);
                       l_cust_claim_amt := (l_reported_inventory * (l_last_price - l_rnd_cust_new_price));
                       l_supp_claim_amt := (l_reported_inventory * l_rnd_price_change);

                       BEGIN
                          INSERT INTO DPP_CUSTOMER_CLAIMS_ALL(TRANSACTION_HEADER_ID,
                                                              CUSTOMER_INV_LINE_ID,
                                                              LINE_NUMBER,
                                                              LAST_PRICE,
                                                              SUPPLIER_NEW_PRICE,
                                                              CUSTOMER_NEW_PRICE,
                                                              TRX_CURRENCY,
                                                              REPORTED_INVENTORY,
                                                              CALCULATED_INVENTORY,
                                                              UOM,
                                                              CREATION_DATE,
                                                              CREATED_BY,
                                                              LAST_UPDATE_DATE,
                                                              LAST_UPDATED_BY,
                                                              LAST_UPDATE_LOGIN,
                                                              INVENTORY_ITEM_ID,
                                                              CUST_ACCOUNT_ID,
                                                              ORG_ID,
                                                              OBJECT_VERSION_NUMBER,
                                                              SUPPLIER_PRICE_DROP,
                                                              CUST_CLAIM_AMT,
                                                              SUPP_CLAIM_AMT,
                                                              CUSTOMER_CLAIM_CREATED,
                                                              SUPPLIER_CLAIM_CREATED)
                                                       VALUES(l_cust_hdr_rec.transaction_header_id,
                                                              l_cust_inv_line_id,
                                                              l_line_number,
                                                              l_last_price,
                                                              l_rnd_supp_new_price,
                                                              l_rnd_cust_new_price,
                                                              nvl(l_customer_tbl(i).customer_price_tbl(j).invoice_currency_code,l_cust_hdr_rec.currency_code),
                                                              l_reported_inventory,
                                                              NVL(l_cust_inv_tbl(1).onhand_quantity,0),
                                                              NVL(l_cust_inv_tbl(1).uom_code, l_customer_tbl(i).uom_code),
                                                              l_sysdate,
                                                              l_cust_hdr_rec.Last_Updated_By,
                                                              l_sysdate,
                                                              l_cust_hdr_rec.Last_Updated_By,
                                                              FND_GLOBAL.login_ID,
                                                              l_customer_tbl(i).inventory_item_id,
                                                              l_customer_tbl(i).customer_price_tbl(j).cust_account_id,
                                                              l_cust_hdr_rec.org_id,
                                                              1,
                                                              l_rnd_price_change,
                                                              l_cust_claim_amt,
                                                              l_supp_claim_amt,
                                                              'N',
                                                              'N');
                       EXCEPTION
                          WHEN OTHERS THEN
                              fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                              fnd_message.set_token('ROUTINE', 'DPP_CUSTOMERCLAIMS_PVT.Populate_CustomerPrice');
                              fnd_message.set_token('ERRNO', sqlcode);
                              fnd_message.set_token('REASON', sqlerrm);
                              fnd_msg_pub.add;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       END;
                       -- Debug Message

                       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Insertion Done in table DPP_CUSTOMER_CLAIMS_ALL');

                       --Assign values to l_claim_lines_tbl for insertion into Log table
                       l_claim_lines_tbl(i).log_mode := 'I'; -- Insert
                       l_claim_lines_tbl(i).transaction_header_id := l_cust_hdr_rec.transaction_header_id;
                       l_claim_lines_tbl(i).customer_inv_line_id := l_cust_inv_line_id;
                       l_claim_lines_tbl(i).line_number		:=    l_line_number;
                       l_claim_lines_tbl(i).last_price          :=    l_customer_tbl(i).customer_price_tbl(j).last_price;
                       l_claim_lines_tbl(i).supplier_new_price  := l_supp_new_price;
                       l_claim_lines_tbl(i).calculated_inventory 	:= l_cust_inv_tbl(1).onhand_quantity;
                       l_claim_lines_tbl(i).creation_date          := l_sysdate;
                       l_claim_lines_tbl(i).created_by             := l_cust_hdr_rec.Last_Updated_By;
                       l_claim_lines_tbl(i).last_update_date       := l_sysdate;
                       l_claim_lines_tbl(i).last_updated_by        := l_cust_hdr_rec.Last_Updated_By;
                       l_claim_lines_tbl(i).last_update_login      := FND_GLOBAL.login_ID;
                       l_claim_lines_tbl(i).inventory_item_id      := l_customer_tbl(i).inventory_item_id;
                       l_claim_lines_tbl(i).cust_account_id	   := l_customer_tbl(i).customer_price_tbl(j).cust_account_id;
                       l_claim_lines_tbl(i).org_id                 := l_cust_hdr_rec.org_id;
                    END IF;  --If cust account id is not null
                END LOOP;    --customer_price_tbl loop
             ELSE   --customer_price_tbl exists
                FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
                FND_MESSAGE.set_token('ID', 'Line Details');
                FND_MSG_PUB.add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;   --customer_price_tbl exists
          END IF;  --inventory_item_id is not null
      END LOOP;  --l_customer_tbl loop
      -- Call the procedure to insert history record
      DPP_LOG_PVT.Insert_ClaimsLog(p_api_version   	 => l_api_version
                                  ,p_init_msg_list	   => FND_API.G_FALSE
                                  ,p_commit	         => FND_API.G_FALSE
                                  ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
                                  ,x_return_status	     => l_return_status
                                  ,x_msg_count	         => l_msg_count
                                  ,x_msg_data	         => l_msg_data
                                  ,p_claim_lines_tbl	   => l_claim_lines_tbl
                                  );
      -- Debug Message

      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Insertion Done in table DPP_CUSTOMER_CLAIMS_LOG');
      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Return Status from DPP_LOG_PVT.Insert_ClaimsLog: '|| l_return_status);


      UPDATE DPP_EXECUTION_DETAILS
         SET execution_end_date = sysdate
            ,execution_status = DECODE(l_return_status,'S','SUCCESS','WARNING')
            ,last_update_date = sysdate
            ,last_updated_by = l_cust_hdr_rec.Last_Updated_By
            ,last_update_login = l_cust_hdr_rec.Last_Updated_By
            ,provider_process_id = l_cust_hdr_rec.Provider_Process_Id
            ,provider_process_instance_id = l_cust_hdr_rec.Provider_Process_Instance_id
            ,output_xml = XMLType(l_cust_hdr_rec.Output_XML)
            ,object_version_number = nvl(object_version_number,0) + 1
      WHERE execution_detail_id = l_cust_hdr_rec.Execution_Detail_ID;
      -- Debug Message

      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, l_api_name||': Exe Detail ID: '||l_cust_hdr_rec.Execution_Detail_ID);
      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, l_api_name|| ': '||SQL%ROWCOUNT ||' row(s) updated in DPP_EXECUTION_DETAILS.');

   ELSE
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Line Details');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;   --l_customer_tbl.EXISTS(1)
END IF; --l_cust_hdr_rec.org_id IS NULL

  x_return_status := l_return_status;
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

--Exception Handling
    EXCEPTION
WHEN DPP_UTILITY_PVT.resource_locked THEN
   ROLLBACK TO Populate_CustomerPrice_PVT;
   x_return_status := FND_API.g_ret_sts_error;
   DPP_UTILITY_PVT.Error_Message(p_message_name => 'API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Populate_CustomerPrice_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Populate_CustomerPrice_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;

WHEN OTHERS THEN
   ROLLBACK TO Populate_CustomerPrice_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
			   fnd_message.set_token('ROUTINE', 'DPP_CUSTOMERCLAIMS_PVT.Populate_CustomerPrice');
			   fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.ADD;
         dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Error in inserting into DPP_CUSTOMER_CLAIMS_ALL: '||SQLERRM);

   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
END IF;


  END Populate_CustomerPrice;

END DPP_CUSTOMERCLAIMS_PVT;

/
