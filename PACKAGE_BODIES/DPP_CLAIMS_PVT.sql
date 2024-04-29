--------------------------------------------------------
--  DDL for Package Body DPP_CLAIMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_CLAIMS_PVT" AS
/* $Header: dppvclab.pls 120.36.12010000.5 2010/04/21 11:31:04 anbbalas ship $ */

-- Package name     : DPP_CLAIMS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_CLAIMS_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvclab.pls';
---------------------------------------------------------------------
-- PROCEDURE
--    Update_Executiondetails
--
-- PURPOSE
--    Update Executiondetails Table
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_Executiondetails(p_status           IN  VARCHAR2
                                 ,p_txn_hdr_rec      IN  dpp_txn_hdr_rec_type
                                 ,p_output_xml       IN  CLOB
                                 ,p_api_name         IN  VARCHAR2
                                 )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  --Update the execution details table
    UPDATE DPP_EXECUTION_DETAILS
       SET EXECUTION_END_DATE = sysdate,
           OUTPUT_XML = XMLTYPE(p_output_xml),
           EXECUTION_STATUS = p_status,
           LAST_UPDATED_BY = p_txn_hdr_rec.Last_Updated_By,
           LAST_UPDATE_DATE = sysdate,
           PROVIDER_PROCESS_ID = p_txn_hdr_rec.Provider_Process_Id,
           PROVIDER_PROCESS_INSTANCE_ID = p_txn_hdr_rec.Provider_Process_Instance_id,
           OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1
     WHERE EXECUTION_DETAIL_ID = p_txn_hdr_rec.Execution_Detail_ID
       AND transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
--In case of updtate flow
IF p_status = 'WARNING'  AND p_api_name = 'Update_Claims' THEN
   UPDATE dpp_transaction_claims_all
      SET approved_by_supplier = 'N',
          OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
          last_updated_by = p_txn_hdr_rec.LAST_UPDATED_BY,
          last_update_date = sysdate,
          last_update_login = p_txn_hdr_rec.LAST_UPDATED_BY
    WHERE claim_id = p_txn_hdr_rec.claim_id
      AND transaction_header_id = p_txn_hdr_rec.Transaction_Header_ID;
END IF;
COMMIT;
END Update_Executiondetails;
---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claims
--
-- PURPOSE
--    Create Claims
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Create_Claims(
    p_api_version         IN    NUMBER
   ,p_init_msg_list      IN    VARCHAR2     := FND_API.G_FALSE
   ,p_commit              IN    VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level      IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status      OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,x_msg_data              OUT NOCOPY   VARCHAR2
   ,p_txn_hdr_rec      IN  dpp_txn_hdr_rec_type
   ,p_txn_line_tbl     IN  dpp_txn_line_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Claims';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_CLAIMS_PVT.CREATE_CLAIMS';

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_txn_hdr_rec           DPP_CLAIMS_PVT.dpp_txn_hdr_rec_type := p_txn_hdr_rec;
l_txn_line_mtbl         DPP_CLAIMS_PVT.dpp_txn_line_tbl_type := p_txn_line_tbl;
l_txn_line_tbl          DPP_CLAIMS_PVT.dpp_txn_line_tbl_type;
l_txn_line_pi_tbl       DPP_CLAIMS_PVT.dpp_txn_line_tbl_type;
l_txn_line_pd_tbl       DPP_CLAIMS_PVT.dpp_txn_line_tbl_type;

l_claim_pub_rec         OZF_Claim_PUB.claim_rec_type;
l_claim_line_pub_tbl    OZF_Claim_PUB.claim_line_tbl_type;
l_claim_line_pub_tbl_updt  OZF_Claim_PUB.claim_line_tbl_type;

l_output_xml		CLOB;
l_queryCtx              dbms_xmlquery.ctxType;
l_status                VARCHAR2(20);
l_transaction_number    VARCHAR2(240);

l_approval_flag         VARCHAR2(1);
l_approved_by_supplier  VARCHAR(1);
l_x_claim_id            NUMBER;

l_cust_account_id       NUMBER;
l_count                 NUMBER;
l_object_version_number NUMBER ;
l_claim_number          VARCHAR2(240);
l_item_description      VARCHAR2(240);
l_item_type             VARCHAR2(30) := 'PRODUCT';

--nepanda for ER 8890930
l_settlement_method_supp_inc VARCHAR2(30);
l_settlement_method_supp_dec VARCHAR2(30);
l_settlement_method_customer VARCHAR2(30);

l_price_increase_flag VARCHAR2(1);
l_claim_line_amount_flag VARCHAR2(1);
l_claim_type VARCHAR2(30);
l_pi_count NUMBER;
l_pd_count NUMBER;
i NUMBER;
j NUMBER;

CURSOR get_claim_hdr_amt_pd_csr IS
    SELECT SUM(claim_line_amount) amount
      FROM DPP_CUSTOMER_CLAIMS_GT
      where claim_line_amount > 0;

CURSOR get_claim_hdr_amt_pi_csr IS
    SELECT SUM(ABS(claim_line_amount)) amount
      FROM DPP_CUSTOMER_CLAIMS_GT
      where claim_line_amount < 0;

CURSOR get_claim_id_csr (p_line_id  IN NUMBER) IS
      SELECT claim_id
        FROM DPP_CUSTOMER_CLAIMS_GT
       WHERE Transaction_Line_ID = p_line_id;

CURSOR grpby_currency_csr IS
   SELECT SUM(Claim_Line_Amount) amount,
          Currency
     FROM DPP_CUSTOMER_CLAIMS_GT
    GROUP BY Currency;

CURSOR get_claim_lines_csr (p_currency IN VARCHAR2) IS
       SELECT transaction_line_id,
              CUST_ACCOUNT_ID,
              claim_line_amount,
              inventory_item_id,
              claim_quantity,
              item_description,
              uom
         FROM DPP_CUSTOMER_CLAIMS_GT
        WHERE currency = p_currency;

CURSOR grpby_cur_cust_csr IS
   SELECT SUM(Claim_Line_Amount) amount,
          Currency,
          customer_id,
          cust_account_id
     FROM DPP_CUSTOMER_CLAIMS_GT
    GROUP BY Currency,
             customer_id,
             cust_account_id;

CURSOR get_cust_claim_lines_csr(p_currency IN VARCHAR2,
                                p_customer_id  IN NUMBER,
                                p_cust_account_id IN NUMBER) IS
       SELECT transaction_line_id,
              customer_id,
              claim_line_amount,
              inventory_item_id,
              claim_quantity,
              item_description,
              uom
         FROM DPP_CUSTOMER_CLAIMS_GT
        WHERE currency = p_currency
        AND customer_id = p_customer_id
        AND cust_account_id = p_cust_account_id;

CURSOR get_item_number_csr(p_item_id NUMBER) IS
        SELECT DISTINCT concatenated_segments item_number,
               description
          FROM mtl_system_items_kfv
         WHERE inventory_item_id = p_item_id;

CURSOR get_claim_number_csr(p_claim_id NUMBER) IS
       SELECT claim_number
         FROM ozf_claims_all
        WHERE claim_id = p_claim_id;

CURSOR get_customer_dtl_csr(p_cust_account_id NUMBER) IS
       SELECT account_name,
              party_id
         FROM hz_cust_accounts
        WHERE cust_account_id = p_cust_account_id;

BEGIN
-- Standard begin of API savepoint
    SAVEPOINT  CREATE_CLAIMS_PVT;

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
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'start');

-- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Transaction Number: ' || l_txn_hdr_rec.Transaction_number);
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Claim Type Flag: ' || l_txn_hdr_rec.claim_type_flag);

   l_transaction_number := ''''||l_txn_hdr_rec.Transaction_number||'''';

   MO_GLOBAL.set_policy_context('S',l_txn_hdr_rec.org_id);

  --Get the Cust account id for the supplier
  --nepanda for ER 8890930
  BEGIN
     SELECT pre_approval_flag,
            cust_account_id,
            settlement_method_supplier_inc,
            settlement_method_supplier_dec,
            settlement_method_customer
       INTO l_approval_flag,
            l_cust_account_id,
            l_settlement_method_supp_inc,
            l_settlement_method_supp_dec,
            l_settlement_method_customer
       FROM ozf_supp_trd_prfls_all
      WHERE supplier_id = l_txn_hdr_rec.Vendor_ID
        AND supplier_site_id = l_txn_hdr_rec.Vendor_site_ID
        AND org_id = l_txn_hdr_rec.org_id;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', 'NO CUST ACCOUNT ID RETRIEVED');
          FND_MSG_PUB.add;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', sqlerrm);
          FND_MSG_PUB.add;
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_TRD_PROFILE');
             fnd_message.set_token('VENDORID', l_txn_hdr_rec.Vendor_ID);
             FND_MSG_PUB.add;
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Pre Approval Required : ' || l_approval_flag);
  DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Customer Account ID : ' || l_cust_account_id);

   --Added code for DPP Price Increase Enhancement
   --Segregate the lines according to the claim_amount
   l_pi_count := 0;
   l_pd_count := 0;

   IF l_txn_line_mtbl.COUNT > 0 THEN
	FOR i in l_txn_line_mtbl.FIRST..l_txn_line_mtbl.LAST LOOP
	    IF l_txn_line_mtbl(i).Claim_Line_Amount < 0 THEN     --Price Increase Lines
		 l_pi_count := l_pi_count + 1;
	         l_txn_line_pi_tbl(l_pi_count) := l_txn_line_mtbl(i);

	    ELSIF l_txn_line_mtbl(i).Claim_Line_Amount > 0 THEN  --Price Decrease Lines
	         l_pd_count := l_pd_count + 1;
	         l_txn_line_pd_tbl(l_pd_count) := l_txn_line_mtbl(i);
	    END IF;
	END LOOP;
   END IF;

   IF l_txn_line_pi_tbl.COUNT > 0 AND l_txn_line_pd_tbl.COUNT > 0 THEN
    j := 2;
   ELSE
    j := 1;
   END IF;

-- Delete the existing lines if any from the DPP_CUSTOMER_CLAIMS_GT temporary table
  DELETE FROM DPP_CUSTOMER_CLAIMS_GT;

  l_price_increase_flag := NULL;
   FOR k in 1..j LOOP
    IF j = 2 THEN   --When transaction has both price increase and price decrease lines
      IF k = 1 THEN  --Price Decrease Lines
        l_txn_line_tbl := l_txn_line_pd_tbl;
        l_price_increase_flag := 'N';
      ELSIF k = 2 THEN --Price Increase Lines
        l_txn_line_tbl := l_txn_line_pi_tbl;
        l_price_increase_flag := 'Y';
      END IF;
    ELSIF j = 1 THEN --When transaction has either price increase or price decrease lines
      IF l_txn_line_pi_tbl.COUNT > 0 THEN --Price Increase Lines
        l_txn_line_tbl := l_txn_line_pi_tbl;
        l_price_increase_flag := 'Y';
      ELSE --Price Decrease Lines
        l_txn_line_tbl := l_txn_line_pd_tbl;
        l_price_increase_flag := 'N';
      END IF;
    END IF;

-- Delete the existing lines if any from the DPP_CUSTOMER_CLAIMS_GT temporary table
--DELETE FROM DPP_CUSTOMER_CLAIMS_GT;

--Insert the lines into the global temp table
  FOR i in l_txn_line_tbl.FIRST..l_txn_line_tbl.LAST LOOP
      BEGIN
        Insert into DPP_CUSTOMER_CLAIMS_GT(Transaction_Line_ID,
                                           Inventory_Item_Id,
                                           cust_account_id,
                                           Claim_Line_Amount,
                                           Currency,
                                           Claim_Quantity,
                                           UOM,
                                           claim_id)
        values(l_txn_line_tbl(i).Transaction_Line_ID,
               l_txn_line_tbl(i).Inventory_Item_Id,
               l_txn_line_tbl(i).cust_account_id,
               l_txn_line_tbl(i).Claim_Line_Amount,
               l_txn_line_tbl(i).Currency,
               l_txn_line_tbl(i).Claim_Quantity,
               l_txn_line_tbl(i).UOM,
               null
               );
      EXCEPTION
         WHEN OTHERS THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
           fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
           fnd_message.set_token('ERRNO', sqlcode);
           fnd_message.set_token('REASON', sqlerrm);
           FND_MSG_PUB.add;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
      --Get the item number
      IF l_txn_line_tbl(i).inventory_item_id IS NOT NULL THEN
         FOR get_item_number_rec IN get_item_number_csr(l_txn_line_tbl(i).inventory_item_id) LOOP
             UPDATE DPP_CUSTOMER_CLAIMS_GT
                SET item_number = get_item_number_rec.item_number,
                    item_description = get_item_number_rec.description
              WHERE transaction_line_id = l_txn_line_tbl(i).transaction_line_id;
             IF SQL%ROWCOUNT = 0 THEN
                DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, 'Unable to Update the column item_number in DPP_CUSTOMER_CLAIMS_GT Table');
             END IF;
         END LOOP;
      ELSE
         FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
         FND_MESSAGE.set_token('ID', 'Inventory Item ID');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --Get the customer name
      IF l_txn_hdr_rec.claim_type_flag = 'CUST_CL' THEN
         IF l_txn_line_tbl(i).cust_account_id IS NOT NULL THEN
            FOR get_customer_dtl_rec IN get_customer_dtl_csr(l_txn_line_tbl(i).cust_account_id) LOOP
                UPDATE DPP_CUSTOMER_CLAIMS_GT
                   SET customer_name = get_customer_dtl_rec.account_name,
                       customer_id = get_customer_dtl_rec.party_id
                 WHERE cust_account_id = l_txn_line_tbl(i).cust_account_id;
                IF SQL%ROWCOUNT = 0 THEN
                   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, 'Unable to Update the column customer_name in DPP_CUSTOMER_CLAIMS_GT Table');
                END IF;
            END LOOP;
         ELSE
            FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
            FND_MESSAGE.set_token('ID', 'Customer Account ID');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
  END LOOP;     --Checked for all the lines in the table type variable.

--Check for vendor claims
IF l_txn_hdr_rec.claim_type_flag = 'SUPP_DSTR_CL' THEN
   --Clear the existing records from the table type variable..
   l_claim_line_pub_tbl.delete();
   l_claim_pub_rec := NULL;
   IF l_approval_flag = 'Y' THEN
      l_approved_by_supplier := 'N';
      l_claim_pub_rec.status_code := 'PENDING_APPROVAL';
      l_claim_pub_rec.user_status_id := 2008; --Pending_Approval status
   ELSIF l_approval_flag = 'N' THEN
      l_approved_by_supplier := 'Y';
      l_claim_pub_rec.user_status_id := 2001; --OPEN status
      l_claim_pub_rec.status_code := 'OPEN';
   END IF;
   --Header record
    IF l_price_increase_flag = 'Y' THEN
       FOR get_claim_hdr_amt_rec IN get_claim_hdr_amt_pi_csr LOOP
           l_claim_pub_rec.amount := get_claim_hdr_amt_rec.amount;
       END LOOP;
    ELSIF l_price_increase_flag = 'N' THEN
       FOR get_claim_hdr_amt_rec IN get_claim_hdr_amt_pd_csr LOOP
           l_claim_pub_rec.amount := get_claim_hdr_amt_rec.amount;
       END LOOP;
    END IF;

--   FOR get_claim_hdr_amt_rec IN get_claim_hdr_amt_csr LOOP
--       l_claim_pub_rec.amount := get_claim_hdr_amt_rec.amount;
--   END LOOP;
   l_claim_pub_rec.cust_account_id := l_cust_account_id;
   l_claim_pub_rec.claim_class := 'CLAIM';

   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_txn_hdr_rec.claim_amount : ' || l_txn_hdr_rec.claim_amount);

   l_claim_pub_rec.currency_code := l_txn_hdr_rec.currency_code;
   l_claim_pub_rec.vendor_id := l_txn_hdr_rec.Vendor_ID;
   l_claim_pub_rec.vendor_site_id := l_txn_hdr_rec.Vendor_site_ID;
   l_claim_pub_rec.custom_setup_id := 300;

   l_claim_line_amount_flag := NULL;
   --Line records
   FOR i in l_txn_line_tbl.FIRST..l_txn_line_tbl.LAST LOOP
   BEGIN
     IF l_claim_line_amount_flag IS NULL THEN
       IF l_txn_line_tbl(i).Claim_Line_Amount < 0 THEN    -- Price Increase Lines
          l_claim_pub_rec.source_object_class := 'PPINCVENDOR';
          --nepanda for ER 8890930
          --l_claim_pub_rec.payment_method := 'AP_DEFAULT';
          l_claim_pub_rec.payment_method := nvl(l_settlement_method_supp_inc,'AP_DEFAULT');
          l_claim_line_amount_flag := 'Y';
       ELSIF l_txn_line_tbl(i).Claim_Line_Amount > 0 THEN -- Price Decrease Lines
          l_claim_pub_rec.source_object_class := 'PPVENDOR';
          --l_claim_pub_rec.payment_method := 'AP_DEBIT';
          l_claim_pub_rec.payment_method := nvl(l_settlement_method_supp_dec,'AP_DEBIT');
          l_claim_line_amount_flag := 'N';
       END IF;
     END IF;
     --Get the item description
     SELECT DISTINCT description
           INTO l_item_description
           FROM mtl_system_items_kfv
          WHERE inventory_item_id = l_txn_line_tbl(i).Inventory_Item_Id;
   EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ROLLBACK TO CREATE_CLAIMS_PVT;
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', 'NO ITEM DESC RETRIEVED');
             FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'Inventory Item ID');
               FND_MSG_PUB.add;
               FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
      IF l_price_increase_flag = 'Y' THEN
        l_claim_line_pub_tbl(i).source_object_class := 'PPINCVENDOR';
        l_claim_line_pub_tbl(i).claim_currency_amount := -1 * l_txn_line_tbl(i).Claim_Line_Amount;
      ELSIF l_price_increase_flag = 'N' THEN
        l_claim_line_pub_tbl(i).source_object_class := 'PPVENDOR';
        l_claim_line_pub_tbl(i).claim_currency_amount := l_txn_line_tbl(i).Claim_Line_Amount;
      END IF;

      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_claim_line_pub_tbl(i).claim_currency_amount: ' || l_claim_line_pub_tbl(i).claim_currency_amount);

      l_claim_line_pub_tbl(i).item_description := l_item_description;
      l_claim_line_pub_tbl(i).item_type := l_item_type;
      l_claim_line_pub_tbl(i).item_id := l_txn_line_tbl(i).Inventory_Item_Id;
      l_claim_line_pub_tbl(i).currency_code := l_txn_line_tbl(i).Currency;
      l_claim_line_pub_tbl(i).quantity := l_txn_line_tbl(i).Claim_Quantity;
      l_claim_line_pub_tbl(i).quantity_uom := l_txn_line_tbl(i).UOM;
   END LOOP;

   --Invoke the standard API with the above defined parameters.
    OZF_Claim_PUB.Create_Claim(p_api_version_number => 1.0,
                              p_init_msg_list => FND_API.G_TRUE,
                              p_commit => FND_API.G_FALSE,
                              p_validation_level => p_validation_level,
                              x_return_status => l_return_status,
                              x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data,
                              p_claim_rec => l_claim_pub_rec,
                              p_claim_line_tbl => l_claim_line_pub_tbl,
                              x_claim_id => l_x_claim_id
                             );

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Create_Claim =>'||l_return_status);
   dpp_utility_pvt.debug_message (FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message data from OZF Create Claim =>'||l_msg_data),1,4000));

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', 'Error while Creating Claim in Trade Management');
      FND_MSG_PUB.add;
      --Update the GT table with the reason for failure
      UPDATE DPP_CUSTOMER_CLAIMS_GT
         SET reason_for_failure = nvl(substr(l_msg_data,1,4000),'Error while Creating Claim in Trade Management');
      IF SQL%ROWCOUNT = 0 THEN
         DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update DPP_CUSTOMER_CLAIMS_GT Table');
      END IF;
   ELSE
      --Assign the claim id to the header record to call the update claim api
      l_txn_hdr_rec.claim_id := l_x_claim_id ;
      --Get the claim number corresponding to the claim id
      FOR get_claim_number_rec IN get_claim_number_csr(l_x_claim_id) LOOP
          l_claim_number := get_claim_number_rec.claim_number;
      END LOOP;
      --Insert the claim id into the dpp_transaction_claims_all table
      BEGIN
      --Derive the claim type based on the change type i.e. price increase or price decrease
      IF l_price_increase_flag = 'Y' THEN
        l_claim_type := 'SUPP_DSTR_INC_CL';
      ELSIF l_price_increase_flag = 'N' THEN
        l_claim_type := 'SUPP_DSTR_CL';
      END IF;
        INSERT INTO dpp_transaction_claims_all(CLAIM_ID,
                                               TRANSACTION_HEADER_ID,
                                               OBJECT_VERSION_NUMBER,
                                               CLAIM_TYPE,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               ORG_ID,
                                               APPROVED_BY_SUPPLIER)
                                        VALUES(to_char(l_x_claim_id),
                                               l_txn_hdr_rec.transaction_header_id,
                                               1,
                                               l_claim_type,
                                               sysdate,
                                               l_txn_hdr_rec.LAST_UPDATED_BY,
                                               sysdate,
                                               l_txn_hdr_rec.LAST_UPDATED_BY,
                                               l_txn_hdr_rec.LAST_UPDATED_BY,
                                               to_char(l_txn_hdr_rec.ORG_ID),
                                               l_approved_by_supplier);
      EXCEPTION
        WHEN OTHERS THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
           fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
           fnd_message.set_token('ERRNO', sqlcode);
           fnd_message.set_token('REASON', sqlerrm);
           FND_MSG_PUB.add;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
      --Insert the claim id into the global temp table..
      IF l_price_increase_flag = 'Y' THEN
          UPDATE DPP_CUSTOMER_CLAIMS_GT
             SET claim_id = l_x_claim_id,
                 claim_number = l_claim_number
             where claim_line_amount < 0;
      ELSIF l_price_increase_flag = 'N' THEN
          UPDATE DPP_CUSTOMER_CLAIMS_GT
             SET claim_id = l_x_claim_id,
                 claim_number = l_claim_number
             where claim_line_amount > 0;
      END IF;

--    UPDATE DPP_CUSTOMER_CLAIMS_GT
--       SET claim_id = l_x_claim_id,
--           claim_number = l_claim_number;
      IF SQL%ROWCOUNT = 0 THEN
         DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column claim_id in DPP_CUSTOMER_CLAIMS_GT Table');
      END IF;
      --Assign the claim id to the corresponding lines
      FOR i IN l_txn_line_tbl.FIRST..l_txn_line_tbl.LAST LOOP
         --Insert into the output xml table to generate the error log
         FOR get_claim_id_rec IN get_claim_id_csr (l_txn_line_tbl(i).transaction_line_id) LOOP
             UPDATE DPP_TRANSACTION_LINES_ALL
                SET supp_dist_claim_id = to_char(get_claim_id_rec.claim_id),
                    supp_dist_claim_status = 'Y',
                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_txn_hdr_rec.LAST_UPDATED_BY,
                    last_update_date = sysdate,
                    last_update_login = l_txn_hdr_rec.LAST_UPDATED_BY
              WHERE transaction_line_id = l_txn_line_tbl(i).transaction_line_id;

             IF SQL%ROWCOUNT = 0 THEN
                DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column supp_dist_claim_id in DPP_TRANSACTION_LINES_ALL Table');
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END LOOP; --getting the claim id loop
      END LOOP; --lines table loop

      --Check if pre approval is required and update the claim
      IF l_approval_flag = 'N' THEN
          --Call the Update_Claims Procedure to flip the status of the claim to Pending Close
          --Clear the existing records from the table type and record type variable..
          l_claim_line_pub_tbl.delete();
          l_claim_pub_rec := NULL;
          l_claim_pub_rec.claim_id := l_x_claim_id;
          l_claim_pub_rec.user_status_id := 2003; --For pending Close Status
          l_claim_pub_rec.status_code := 'PENDING_CLOSE';

          IF l_price_increase_flag = 'Y' THEN
            --nepanda for ER 8890930
            --l_claim_pub_rec.payment_method := 'AP_DEFAULT';
            l_claim_pub_rec.payment_method := nvl(l_settlement_method_supp_inc,'AP_DEFAULT');
          ELSIF l_price_increase_flag = 'N' THEN
            --nepanda for ER 8890930
            --l_claim_pub_rec.payment_method := 'AP_DEBIT';
            l_claim_pub_rec.payment_method := nvl(l_settlement_method_supp_dec,'AP_DEBIT');
          END IF;

          --Retrieve the object version number
          BEGIN
              l_object_version_number := NULL;

              SELECT Object_version_number
                INTO l_object_version_number
                FROM ozf_claims
               WHERE claim_id = l_x_claim_id;
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
                  fnd_message.set_token('ERRNO', sqlcode);
                  fnd_message.set_token('REASON', 'OBJECT VERSION NUMBER NOT FOUND');
                  FND_MSG_PUB.add;
                  IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                     FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               WHEN OTHERS THEN
                  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
                  fnd_message.set_token('ERRNO', sqlcode);
                  fnd_message.set_token('REASON', sqlerrm);
                  FND_MSG_PUB.add;
                  IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                     FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_OBJ_VER_NUM');
                     fnd_message.set_token('CLAIM_ID', l_x_claim_id);
                     FND_MSG_PUB.add;
                     FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
          l_claim_pub_rec.object_version_number  := l_object_version_number;
          --Invoke the standard API with the above defined parameters.
          OZF_CLAIM_PUB.Update_Claim (p_api_version_number => l_api_version
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,p_commit => FND_API.G_FALSE
                                     ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                     ,x_return_status => l_return_status
                                     ,x_msg_count => l_msg_count
                                     ,x_msg_data => l_msg_data
                                     ,p_claim_rec => l_claim_pub_rec
                                     ,p_claim_line_tbl => l_claim_line_pub_tbl
                                     ,x_object_version_number => l_object_version_number
                                     );

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for OZF Update_Claims =>'||l_return_status);
          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message data for OZF Update_Claims =>'||l_msg_data),1,4000));

          --If the claim updation process failed
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', 'Error while Updating Claim in Trade Management');
             FND_MSG_PUB.add;
             --Delete the claim numbers from the GT table
             UPDATE DPP_CUSTOMER_CLAIMS_GT
                SET claim_id = null,
                    claim_number = null;
             IF SQL%ROWCOUNT = 0 THEN
                DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update DPP_CUSTOMER_CLAIMS_GT Table');
             END IF;
          END IF;
      END IF; --Pre approval is not required
   END IF;

--Check for vendor claims for customer
ELSIF l_txn_hdr_rec.claim_type_flag = 'SUPP_CUST_CL' AND l_price_increase_flag = 'N' THEN
   FOR grpby_currency_rec IN grpby_currency_csr LOOP
      --Clear the existing records from the table type variable..
      l_claim_line_pub_tbl.delete();
      l_claim_pub_rec := null;
      --Header Record
      l_claim_pub_rec.cust_account_id := l_cust_account_id;
      l_claim_pub_rec.claim_class := 'CLAIM';
      l_claim_pub_rec.source_object_class := 'PPVENDOR';
      l_claim_pub_rec.amount := grpby_currency_rec.amount;
      l_claim_pub_rec.currency_code := grpby_currency_rec.Currency;
      l_claim_pub_rec.vendor_id := l_txn_hdr_rec.Vendor_ID;
      l_claim_pub_rec.vendor_site_id := l_txn_hdr_rec.Vendor_site_ID;
      l_claim_pub_rec.status_code := 'OPEN';
      l_claim_pub_rec.user_status_id := 2001; --OPEN status
      l_claim_pub_rec.custom_setup_id := 300;
      --Line records
      l_count := 1;
      FOR get_claim_lines_rec IN get_claim_lines_csr(grpby_currency_rec.Currency) LOOP
        l_claim_line_pub_tbl(l_count).claim_currency_amount := get_claim_lines_rec.claim_line_amount;
        l_claim_line_pub_tbl(l_count).item_id := get_claim_lines_rec.Inventory_Item_Id;
        l_claim_line_pub_tbl(l_count).item_description := get_claim_lines_rec.item_description;
        l_claim_line_pub_tbl(l_count).item_type := l_item_type;
        l_claim_line_pub_tbl(l_count).source_object_class := 'PPVENDOR';
        l_claim_line_pub_tbl(l_count).dpp_cust_account_id := get_claim_lines_rec.CUST_ACCOUNT_ID;
        l_claim_line_pub_tbl(l_count).currency_code := grpby_currency_rec.Currency;
        l_claim_line_pub_tbl(l_count).quantity := get_claim_lines_rec.Claim_Quantity;
        l_claim_line_pub_tbl(l_count).quantity_uom := get_claim_lines_rec.uom;
        l_count := l_count + 1;
      END LOOP;

      --Invoke the standard API with the above defined parameters.
      OZF_Claim_PUB.Create_Claim(p_api_version_number => 1.0,
                               p_init_msg_list => FND_API.G_TRUE,
                               p_commit => FND_API.G_FALSE,
                               p_validation_level => p_validation_level,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data,
                               p_claim_rec => l_claim_pub_rec,
                               p_claim_line_tbl => l_claim_line_pub_tbl,
                               x_claim_id => l_x_claim_id
                               );

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Create_Claim =>'||l_return_status);
      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message Data for OZF Create_Claim =>'||l_msg_data),1,4000));

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', 'Error while Creating Claim in Trade Management');
         FND_MSG_PUB.add;
         --Update the claim id into the global temp table..
         UPDATE DPP_CUSTOMER_CLAIMS_GT
            SET reason_for_failure =  nvl(substr(l_msg_data,1,4000),'Error while Creating Claim in Trade Management')
          WHERE currency = grpby_currency_rec.Currency;

         IF SQL%ROWCOUNT = 0 THEN
            DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column claim_id in DPP_CUSTOMER_CLAIMS_GT Table');
         END IF;
      ELSE
         --Update the claim to pending close status
         --Call the update_claims procedure to update the claim status to open
         l_claim_pub_rec.claim_id := l_x_claim_id;
         l_claim_pub_rec.user_status_id := 2003; -- For pending close status
         --nepanda for ER 8890930
         --l_claim_pub_rec.payment_method := 'AP_DEBIT';
         l_claim_pub_rec.payment_method := nvl(l_settlement_method_supp_dec, 'AP_DEBIT');
         l_claim_pub_rec.status_code := 'PENDING_CLOSE';
         --Retrieve the object version number
         BEGIN
             SELECT Object_version_number
               INTO l_object_version_number
               FROM ozf_claims
              WHERE claim_id = l_x_claim_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
                fnd_message.set_token('ERRNO', sqlcode);
                fnd_message.set_token('REASON', 'OBJECT VERSION NUMBER NOT FOUND');
                FND_MSG_PUB.add;
                IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             WHEN OTHERS THEN
                fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
                fnd_message.set_token('ERRNO', sqlcode);
                fnd_message.set_token('REASON', sqlerrm);
                FND_MSG_PUB.add;
                IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                   FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_OBJ_VER_NUM');
                   fnd_message.set_token('CLAIM_ID', l_x_claim_id);
                   FND_MSG_PUB.add;
                   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        l_claim_pub_rec.object_version_number  := l_object_version_number;
        --Invoke the standard API with the above defined parameters.
        OZF_CLAIM_PUB.Update_Claim (p_api_version_number => l_api_version
                                   ,p_init_msg_list => FND_API.G_FALSE
                                   ,p_commit => FND_API.G_FALSE
                                   ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                   ,x_return_status => l_return_status
                                   ,x_msg_count => l_msg_count
                                   ,x_msg_data => l_msg_data
                                   ,p_claim_rec => l_claim_pub_rec
                                   ,p_claim_line_tbl => l_claim_line_pub_tbl_updt
                                   ,x_object_version_number => l_object_version_number
                                   );

		  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Update_Claims =>'||l_return_status);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message data for OZF Update_Claims =>'||l_msg_data),1,4000));

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
           fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
           fnd_message.set_token('ERRNO', sqlcode);
           fnd_message.set_token('REASON', 'Error while Updating Claim in Trade Management');
           FND_MSG_PUB.add;
        ELSE
           --Get the claim number corresponding to the claim id
           FOR get_claim_number_rec IN get_claim_number_csr(l_x_claim_id) LOOP
               l_claim_number := get_claim_number_rec.claim_number;
           END LOOP;
           --Insert the claim id into the dpp_transaction_claims_all table
           BEGIN
             INSERT INTO dpp_transaction_claims_all(CLAIM_ID,
                                                    TRANSACTION_HEADER_ID,
                                                    OBJECT_VERSION_NUMBER,
                                                    CLAIM_TYPE,
                                                    CREATION_DATE,
                                                    CREATED_BY,
                                                    LAST_UPDATE_DATE,
                                                    LAST_UPDATED_BY,
                                                    LAST_UPDATE_LOGIN,
                                                    ORG_ID,
                                                    APPROVED_BY_SUPPLIER)
                                             VALUES(to_char(l_x_claim_id),
                                                    l_txn_hdr_rec.transaction_header_id,
                                                    1,
                                                    l_txn_hdr_rec.claim_type_flag,
                                                    sysdate,
                                                    l_txn_hdr_rec.LAST_UPDATED_BY,
                                                    sysdate,
                                                    l_txn_hdr_rec.LAST_UPDATED_BY,
                                                    l_txn_hdr_rec.LAST_UPDATED_BY,
                                                    to_char(l_txn_hdr_rec.ORG_ID),
                                                    'Y');
           EXCEPTION
              WHEN OTHERS THEN
                 fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                 fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
                 fnd_message.set_token('ERRNO', sqlcode);
                 fnd_message.set_token('REASON', sqlerrm);
                 FND_MSG_PUB.add;
                 IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           --Update the claim id into the global temp table..
           UPDATE DPP_CUSTOMER_CLAIMS_GT
            SET claim_id = l_x_claim_id,
                claim_number = l_claim_number
          WHERE currency = grpby_currency_rec.Currency;

           IF SQL%ROWCOUNT = 0 THEN
              DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column claim_id in DPP_CUSTOMER_CLAIMS_GT Table');
           END IF;
        END IF;  --Update claim call success
      END IF;  --Create claim success
   END LOOP;
--Assign the claim id to the corresponding lines
  FOR i IN l_txn_line_tbl.FIRST..l_txn_line_tbl.LAST LOOP
    --Insert into the output xml table to generate the error log
    FOR get_claim_id_rec IN get_claim_id_csr (l_txn_line_tbl(i).transaction_line_id) LOOP
        IF get_claim_id_rec.claim_id IS NOT NULL THEN
           UPDATE DPP_CUSTOMER_CLAIMS_ALL
              SET SUPP_CUST_CLAIM_ID = to_char(get_claim_id_rec.claim_id),
                  supplier_claim_created = 'Y',
                  OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_txn_hdr_rec.LAST_UPDATED_BY,
                    last_update_date = sysdate,
                    last_update_login = l_txn_hdr_rec.LAST_UPDATED_BY
            WHERE CUSTOMER_INV_LINE_ID = l_txn_line_tbl(i).transaction_line_id;

           IF SQL%ROWCOUNT = 0 THEN
              DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column SUPP_CUST_CLAIM_ID in DPP_CUSTOMER_CLAIMS_ALL Table');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        ELSE
           UPDATE DPP_CUSTOMER_CLAIMS_ALL
              SET supplier_claim_created = 'N',
                  OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_txn_hdr_rec.LAST_UPDATED_BY,
                    last_update_date = sysdate,
                    last_update_login = l_txn_hdr_rec.LAST_UPDATED_BY
            WHERE CUSTOMER_INV_LINE_ID = l_txn_line_tbl(i).transaction_line_id;

           IF SQL%ROWCOUNT = 0 THEN
              DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column supplier_claim_created in DPP_CUSTOMER_CLAIMS_ALL Table');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
    END LOOP;
END LOOP;
--Check for vendor claims for customer
ELSIF l_txn_hdr_rec.claim_type_flag = 'CUST_CL' AND l_price_increase_flag = 'N' THEN
   FOR grpby_cur_cust_rec IN grpby_cur_cust_csr  LOOP
       --Clear the existing records from the table type variable..
       l_claim_line_pub_tbl.delete();
       l_claim_pub_rec := null;
       --Header Records
       l_claim_pub_rec.cust_account_id := grpby_cur_cust_rec.cust_account_id;
       l_claim_pub_rec.claim_class := 'CLAIM';
       l_claim_pub_rec.source_object_class := 'PPCUSTOMER';
       l_claim_pub_rec.amount := grpby_cur_cust_rec.amount;
       l_claim_pub_rec.currency_code := grpby_cur_cust_rec.Currency;
       l_claim_pub_rec.status_code := 'OPEN';
       l_claim_pub_rec.user_status_id := 2001; --OPEN status
       l_claim_pub_rec.custom_setup_id := 300;
       --Line records
       l_count := 1;
       FOR get_cust_claim_lines_rec IN get_cust_claim_lines_csr(grpby_cur_cust_rec.Currency,
                                                                grpby_cur_cust_rec.customer_id,
                                                                grpby_cur_cust_rec.cust_account_id) LOOP
         l_claim_line_pub_tbl(l_count).claim_currency_amount := get_cust_claim_lines_rec.claim_line_amount;
         l_claim_line_pub_tbl(l_count).item_id := get_cust_claim_lines_rec.inventory_item_id;
         l_claim_line_pub_tbl(l_count).item_description := get_cust_claim_lines_rec.item_description;
         l_claim_line_pub_tbl(l_count).item_type := l_item_type;
         l_claim_line_pub_tbl(l_count).source_object_class := 'PPCUSTOMER';
         l_claim_line_pub_tbl(l_count).currency_code := grpby_cur_cust_rec.Currency;
         l_claim_line_pub_tbl(l_count).quantity := get_cust_claim_lines_rec.Claim_Quantity;
         l_claim_line_pub_tbl(l_count).quantity_uom := get_cust_claim_lines_rec.uom;
         l_count := l_count + 1;
       END LOOP;

      --Invoke the standard API with the above defined parameters.
      OZF_Claim_PUB.Create_Claim(p_api_version_number => 1.0,
                                 p_init_msg_list => FND_API.G_TRUE,
                                 p_commit => FND_API.G_FALSE,
                                 p_validation_level => p_validation_level,
                                 x_return_status => l_return_status,
                                 x_msg_count => l_msg_count,
                                 x_msg_data => l_msg_data,
                                 p_claim_rec => l_claim_pub_rec,
                                 p_claim_line_tbl => l_claim_line_pub_tbl,
                                 x_claim_id => l_x_claim_id
                                 );

      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Create_Claim =>'||l_return_status);
      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message data for OZF Create_Claim =>'||l_msg_data),1,4000));

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', 'Error while Creating Claim in Trade Management');
         FND_MSG_PUB.add;
         --Insert the claim id into the global temp table..
         UPDATE DPP_CUSTOMER_CLAIMS_GT
            SET reason_for_failure =  nvl(substr(l_msg_data,1,4000),'Error while Creating Claim in Trade Management')
          WHERE currency = grpby_cur_cust_rec.Currency
            AND customer_id = grpby_cur_cust_rec.customer_id
            AND cust_account_id = grpby_cur_cust_rec.cust_account_id;

         IF SQL%ROWCOUNT = 0 THEN
            DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update the column claim_id in DPP_CUSTOMER_CLAIMS_GT Table');
         END IF;
      ELSE
        --Update the claim to Pending Close status
        l_claim_pub_rec.claim_id := l_x_claim_id;
        l_claim_pub_rec.user_status_id := 2003; -- For pending close status
        --nepanda for ER 8890930
        --l_claim_pub_rec.payment_method := 'CREDIT_MEMO';
        l_claim_pub_rec.payment_method := nvl(l_settlement_method_customer, 'CREDIT_MEMO');
        l_claim_pub_rec.status_code := 'PENDING_CLOSE';
        --Retrieve the object version number
        BEGIN
         SELECT Object_version_number
           INTO l_object_version_number
           FROM ozf_claims
          WHERE claim_id = l_x_claim_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', 'OBJECT VERSION NUMBER NOT FOUND');
                FND_MSG_PUB.add;
             IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
                FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_OBJ_VER_NUM');
              fnd_message.set_token('CLAIM_ID', l_x_claim_id);
            FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        l_claim_pub_rec.object_version_number  := l_object_version_number;
        --Invoke the standard API with the above defined parameters.
        OZF_CLAIM_PUB.Update_Claim (p_api_version_number => l_api_version
                                   ,p_init_msg_list => FND_API.G_FALSE
                                   ,p_commit => FND_API.G_FALSE
                                   ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                   ,x_return_status => l_return_status
                                   ,x_msg_count => l_msg_count
                                   ,x_msg_data => l_msg_data
                                   ,p_claim_rec => l_claim_pub_rec
                                   ,p_claim_line_tbl => l_claim_line_pub_tbl_updt
                                   ,x_object_version_number => l_object_version_number
                                   );

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Update_Claims =>'||l_return_status);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message Data for OZF Update_Claims =>'||l_msg_data),1,4000));

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
           fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
           fnd_message.set_token('ERRNO', sqlcode);
           fnd_message.set_token('REASON', 'Error while Creating Claim in Trade Management');
           FND_MSG_PUB.add;
        ELSE
           --Get the claim number corresponding to the claim id
           FOR get_claim_number_rec IN get_claim_number_csr(l_x_claim_id) LOOP
               l_claim_number := get_claim_number_rec.claim_number;
           END LOOP;
           --Insert the claim id into the dpp_transaction_claims_all table
           BEGIN
              INSERT INTO dpp_transaction_claims_all(CLAIM_ID,
                                               TRANSACTION_HEADER_ID,
                                               OBJECT_VERSION_NUMBER,
                                               CLAIM_TYPE,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               ORG_ID,
                                               APPROVED_BY_SUPPLIER)
                                        VALUES(to_char(l_x_claim_id),
                                               l_txn_hdr_rec.transaction_header_id,
                                               1,
                                               l_txn_hdr_rec.claim_type_flag,
                                               sysdate,
                                               l_txn_hdr_rec.LAST_UPDATED_BY,
                                               sysdate,
                                               l_txn_hdr_rec.LAST_UPDATED_BY,
                                               l_txn_hdr_rec.LAST_UPDATED_BY,
                                               to_char(l_txn_hdr_rec.ORG_ID),
                                               'Y');
           EXCEPTION
               WHEN OTHERS THEN
                  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
                  fnd_message.set_token('ERRNO', sqlcode);
                  fnd_message.set_token('REASON', sqlerrm);
                  FND_MSG_PUB.add;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           --Insert the claim id into the global temp table..
           UPDATE DPP_CUSTOMER_CLAIMS_GT
              SET claim_id = l_x_claim_id,
                  claim_number = l_claim_number,
                  reason_for_failure = nvl(substr(l_msg_data,1,4000),'Error while Updating Claim in Trade Management')
            WHERE currency = grpby_cur_cust_rec.Currency
              AND customer_id = grpby_cur_cust_rec.customer_id
              AND cust_account_id = grpby_cur_cust_rec.cust_account_id;
           IF SQL%ROWCOUNT = 0 THEN
              DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update the column claim_id in DPP_CUSTOMER_CLAIMS_GT Table');
           END IF;
        END IF;
      END IF;
   END LOOP;

   --Assign the claim id to the corresponding lines
   FOR i IN l_txn_line_tbl.FIRST..l_txn_line_tbl.LAST LOOP
      FOR get_claim_id_rec IN get_claim_id_csr (l_txn_line_tbl(i).transaction_line_id) LOOP
         IF get_claim_id_rec.claim_id IS NOT NULL THEN
            UPDATE DPP_CUSTOMER_CLAIMS_ALL
               SET CUSTOMER_CLAIM_ID = to_char(get_claim_id_rec.claim_id),
                   customer_claim_created = 'Y',
                   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_txn_hdr_rec.LAST_UPDATED_BY,
                    last_update_date = sysdate,
                    last_update_login = l_txn_hdr_rec.LAST_UPDATED_BY
             WHERE CUSTOMER_INV_LINE_ID = l_txn_line_tbl(i).transaction_line_id;

            IF SQL%ROWCOUNT = 0 THEN
               DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update the column CUSTOMER_CLAIM_ID in DPP_CUSTOMER_CLAIMS_ALL Table');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         ELSE
            UPDATE DPP_CUSTOMER_CLAIMS_ALL
               SET customer_claim_created = 'N',
                   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
                    last_updated_by = l_txn_hdr_rec.LAST_UPDATED_BY,
                    last_update_date = sysdate,
                    last_update_login = l_txn_hdr_rec.LAST_UPDATED_BY
             WHERE CUSTOMER_INV_LINE_ID = l_txn_line_tbl(i).transaction_line_id;

            IF SQL%ROWCOUNT = 0 THEN
               DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update the column customer_claim_created in DPP_CUSTOMER_CLAIMS_ALL Table');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END LOOP;
   END LOOP;
ELSE
   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
   FND_MESSAGE.set_token('ID', 'Claim Type Flag');
   FND_MSG_PUB.add;
   RAISE FND_API.G_EXC_ERROR;
END IF;
END LOOP; -- End Loop for DPP Price Increase Enhancement

IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
   x_return_status := l_return_status;
END IF;
IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
   l_status := 'SUCCESS';
   --Output XML Generation Code.
   l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_transaction_number||'Txnnumber,
                                             CURSOR (SELECT DISTINCT claim_number  claimnumber
                                            FROM DPP_CUSTOMER_CLAIMS_GT) TRANSACTION
                                            FROM dual');
ELSE
   l_status := 'WARNING';
   --Output XML Generation Code.
   l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_transaction_number||'Txnnumber,
                                                                CURSOR(SELECT claim_number claimnumber,
                                                                              customer_name customername,
                                                                              currency,
                                                                              item_number itemnumber ,
                                                                              reason_for_failure reason
                                                                         FROM DPP_CUSTOMER_CLAIMS_GT) transaction FROM dual');
END IF;
dbms_xmlquery.setRowTag(l_queryCtx
                       ,'ROOT'
                       );
l_output_xml := dbms_xmlquery.getXml(l_queryCtx);
dbms_xmlquery.closeContext(l_queryCtx);
--Call the Update_Executiondetails Procedure to update the execution details table and commit the transaction
  Update_Executiondetails(l_status,
                          l_txn_hdr_rec,
                          l_output_xml,
                          l_api_name
                          );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
/*--Update the execution details table
        UPDATE DPP_EXECUTION_DETAILS
           SET EXECUTION_END_DATE = sysdate,
               OUTPUT_XML = XMLTYPE(l_output_xml),
               EXECUTION_STATUS = l_status,
               LAST_UPDATED_BY = l_txn_hdr_rec.Last_Updated_By,
               LAST_UPDATE_DATE = sysdate,
               PROVIDER_PROCESS_ID = l_txn_hdr_rec.Provider_Process_Id,
               PROVIDER_PROCESS_INSTANCE_ID = l_txn_hdr_rec.Provider_Process_Instance_id,
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1
         WHERE EXECUTION_DETAIL_ID = l_txn_hdr_rec.Execution_Detail_ID
           AND transaction_header_id = l_txn_hdr_rec.Transaction_Header_ID;

        IF SQL%ROWCOUNT = 0 THEN
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update DPP_EXECUTION_DETAILS Table');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
 */


-- Debug Message
DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'end');

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT;
   END IF;
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
(p_count => x_msg_count,
p_data => x_msg_data
   );
--Exception Handling
EXCEPTION
WHEN DPP_UTILITY_PVT.resource_locked THEN
   ROLLBACK TO CREATE_CLAIMS_PVT;
   x_return_status := FND_API.g_ret_sts_error;
DPP_UTILITY_PVT.Error_Message(p_message_name => 'API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO CREATE_CLAIMS_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO CREATE_CLAIMS_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;
WHEN OTHERS THEN
   ROLLBACK TO CREATE_CLAIMS_PVT;
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
    IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

END Create_Claims;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claims
--
-- PURPOSE
--    Update Claims
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE Update_Claims(
    p_api_version          IN    NUMBER
   ,p_init_msg_list       IN    VARCHAR2     := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_count               OUT NOCOPY   NUMBER
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,p_txn_hdr_rec       IN OUT NOCOPY  dpp_txn_hdr_rec_type
   ,p_txn_line_tbl       IN OUT  NOCOPY dpp_txn_line_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Claims';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_CLAIMS_PVT.UPDATE_CLAIMS';

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_txn_hdr_rec           DPP_CLAIMS_PVT.dpp_txn_hdr_rec_type := p_txn_hdr_rec;
l_txn_line_tbl          DPP_CLAIMS_PVT.dpp_txn_line_tbl_type := p_txn_line_tbl;

l_claim_pub_rec         OZF_Claim_PUB.claim_rec_type;
l_claim_line_pub_tbl    OZF_Claim_PUB.claim_line_tbl_type;

l_output_xml		CLOB;
l_queryCtx              dbms_xmlquery.ctxType;

l_object_version_number NUMBER := 1.0;
l_claim_line_id         NUMBER;
l_claim_line_number     NUMBER;
l_set_of_books_id       NUMBER;
l_valid_flag            VARCHAR2(1);
l_user_status_id        NUMBER  := 2003;  --Pending_close status: 2003
l_cust_account_id       NUMBER;
l_status                VARCHAR2(240);
l_transaction_number    VARCHAR2(240);
l_reason                VARCHAR2(4000);
L_CLAIM_LINE_OBJ_VER    NUMBER;

BEGIN
-- Standard begin of API savepoint
    SAVEPOINT  Update_Claims_PVT;
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
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_txn_hdr_rec.Transaction_number IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Transaction Number');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_txn_hdr_rec.claim_id IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Claim ID');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_txn_hdr_rec.Transaction_Header_ID IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Transaction Header ID');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     l_transaction_number := ''''||l_txn_hdr_rec.Transaction_number||'''';

     DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Transaction Number: ' || l_txn_hdr_rec.Transaction_number);
     DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Claim Id to be updated : ' || l_txn_hdr_rec.claim_id);

  END IF;
--
-- API body
--
 MO_GLOBAL.set_policy_context('S',l_txn_hdr_rec.org_id);
 --Object Version Number and the cust account id
    BEGIN
       SELECT Object_version_number,
              cust_account_id
         INTO l_object_version_number,
              l_cust_account_id
         FROM ozf_claims_all
        WHERE claim_id = l_txn_hdr_rec.claim_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', 'OBJECT VERSION NUMBER NOT FOUND');
                FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
                FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_OBJ_VER_NUM');
              fnd_message.set_token('CLAIM_ID', l_txn_hdr_rec.claim_id);
              FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
--Clear the existing records from the table type variable..
    l_claim_line_pub_tbl.delete();
    l_claim_pub_rec := NULL;
    --Header record
    l_claim_pub_rec.claim_id := l_txn_hdr_rec.claim_id;

    IF l_txn_hdr_rec.claim_amount < 0 THEN  --ANBBALAS: For Price Increase enhancement
      l_claim_pub_rec.amount := -1 * l_txn_hdr_rec.claim_amount;
    ELSE
      l_claim_pub_rec.amount := l_txn_hdr_rec.claim_amount;
    END IF;

    l_claim_pub_rec.currency_code := l_txn_hdr_rec.currency_code;
    l_claim_pub_rec.status_code := 'OPEN';
    l_claim_pub_rec.cust_account_id := l_cust_account_id;
    l_claim_pub_rec.object_version_number := l_object_version_number;
    l_claim_pub_rec.user_status_id := 2001; --For OPEN status
    --l_claim_pub_rec.payment_method := 'AP_DEBIT'; --ANBBALAS: For Price Increase enhancement
    l_claim_pub_rec.custom_setup_id := 300;
   --Line records
   IF l_txn_line_tbl.COUNT >0 THEN
      FOR i in l_txn_line_tbl.FIRST..l_txn_line_tbl.LAST LOOP
    BEGIN
       SELECT claim_line_id,
              line_number,
              set_of_books_id,
              valid_flag,
              object_version_number
         INTO l_claim_line_id,
              l_claim_line_number,
              l_set_of_books_id,
              l_valid_flag,
              L_CLAIM_LINE_OBJ_VER
         FROM ozf_claim_lines_all
        WHERE claim_id = l_txn_hdr_rec.claim_id
          AND item_id = l_txn_line_tbl(i).Inventory_Item_Id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', 'CLAIM LINE DETAILS NOT FOUND');
             FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_LINE_DETAILS');
               fnd_message.set_token('CLAIM_ID', l_txn_hdr_rec.claim_id);
               fnd_message.set_token('ITEM_ID', l_txn_line_tbl(i).Inventory_Item_Id);
               FND_MSG_PUB.add;
               FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
        l_claim_line_pub_tbl(i).claim_id := l_txn_hdr_rec.claim_id;
        l_claim_line_pub_tbl(i).claim_line_id := l_claim_line_id;
        --l_claim_line_pub_tbl(i).claim_currency_amount := l_txn_line_tbl(i).Claim_Line_Amount; --ANBBALAS: For Price Increase enhancement
        l_claim_line_pub_tbl(i).quantity := l_txn_line_tbl(i).Claim_Quantity;
        l_claim_line_pub_tbl(i).currency_code := l_txn_line_tbl(i).Currency;
        l_claim_line_pub_tbl(i).item_id := l_txn_line_tbl(i).inventory_item_id;
        l_claim_line_pub_tbl(i).line_number :=l_claim_line_number;
        l_claim_line_pub_tbl(i).set_of_books_id := l_set_of_books_id;
        l_claim_line_pub_tbl(i).valid_flag := l_valid_flag;
        l_claim_line_pub_tbl(i).object_version_number  := l_claim_line_obj_ver;
        --l_claim_line_pub_tbl(i).amount := l_txn_line_tbl(i).Claim_Line_Amount;  --ANBBALAS: For Price Increase enhancement

        IF l_txn_line_tbl(i).Claim_Line_Amount < 0 THEN  --ANBBALAS: For Price Increase enhancement
          l_claim_line_pub_tbl(i).claim_currency_amount := -1 * l_txn_line_tbl(i).Claim_Line_Amount;
          l_claim_line_pub_tbl(i).amount := -1 * l_txn_line_tbl(i).Claim_Line_Amount;
        ELSE
          l_claim_line_pub_tbl(i).claim_currency_amount := l_txn_line_tbl(i).Claim_Line_Amount;
          l_claim_line_pub_tbl(i).amount := l_txn_line_tbl(i).Claim_Line_Amount;
        END IF;

   END LOOP;
  END IF;

   --Invoke the standard API with the above defined parameters.
     OZF_CLAIM_PUB.Update_Claim (p_api_version_number => l_api_version
                                ,p_init_msg_list => FND_API.G_FALSE
                                ,p_commit => FND_API.G_False
                                ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                ,x_return_status => l_return_status
                                ,x_msg_count => l_msg_count
                                ,x_msg_data => l_msg_data
                                ,p_claim_rec => l_claim_pub_rec
                                ,p_claim_line_tbl => l_claim_line_pub_tbl
                                ,x_object_version_number => l_object_version_number
                                );

dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Update_Claims =>'||l_return_status);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message Data for OZF Update_Claims =>'||l_msg_data),1,4000));

IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Update_Claims =>'||l_return_status);
   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update the claim to OPEN status');
ELSE
  --Bug#6928445
  IF l_txn_hdr_rec.claim_amount <> 0 THEN --ANBBALAS: For Price Increase enhancement
--Update the Claim to PENDING CLOSE status
   l_claim_pub_rec := NULL;
   l_claim_line_pub_tbl.delete();
   l_claim_pub_rec.claim_id := l_txn_hdr_rec.claim_id;
   l_claim_pub_rec.user_status_id := 2003;  --For PENDING_CLOSE status
   l_claim_pub_rec.status_code := l_txn_hdr_rec.claim_status_code;
   --l_claim_pub_rec.payment_method := 'AP_DEBIT';  --ANBBALAS: For Price Increase enhancement
   l_claim_pub_rec.custom_setup_id := 300;

   --Retrieve the object version number
   BEGIN
       SELECT Object_version_number
         INTO l_object_version_number
         FROM ozf_claims
        WHERE claim_id = l_txn_hdr_rec.claim_id;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
           fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
           fnd_message.set_token('ERRNO', sqlcode);
           fnd_message.set_token('REASON', 'OBJECT VERSION NUMBER NOT FOUND');
           FND_MSG_PUB.add;
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
            FND_MSG_PUB.add;
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MESSAGE.set_name('DPP', 'DPP_CLAIM_INVALID_OBJ_VER_NUM');
               fnd_message.set_token('CLAIM_ID', l_txn_hdr_rec.claim_id);
               FND_MSG_PUB.add;
              FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    l_claim_pub_rec.object_version_number  := l_object_version_number;
    --Invoke the standard API with the above defined parameters.
    OZF_CLAIM_PUB.Update_Claim (p_api_version_number => l_api_version
                                ,p_init_msg_list => FND_API.G_FALSE
                                ,p_commit => FND_API.G_FALSE
                                ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                ,x_return_status => l_return_status
                                ,x_msg_count => l_msg_count
                                ,x_msg_data => l_msg_data
                                ,p_claim_rec => l_claim_pub_rec
                                ,p_claim_line_tbl => l_claim_line_pub_tbl
                                ,x_object_version_number => l_object_version_number
                                );

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'return status for Update_Claims =>'||l_return_status);
    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Message data for OZF Update_Claims =>'||l_msg_data),1,4000));

  END IF; --IF l_txn_hdr_rec.claim_amount > 0 THEN
END IF;
l_reason := ''''||substr(l_msg_data,1,3990)||'''';
IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
   l_status := 'SUCCESS';
ELSE
   l_status := 'WARNING';
END IF;
--Output XML Generation Code
l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_transaction_number||'txnnumber,
                                                    claim_number claimnumber,'
                                                    ||l_reason||'reason
                                               FROM ozf_claims_all
                                              WHERE claim_id = '||l_txn_hdr_rec.claim_id);
dbms_xmlquery.setRowTag(l_queryCtx
                       ,'ROOT'
                       );
l_output_xml := dbms_xmlquery.getXml(l_queryCtx);
dbms_xmlquery.closeContext(l_queryCtx);
--Call the Update_Executiondetails Procedure to update the execution details table and commit the transaction
  Update_Executiondetails(l_status,
                          l_txn_hdr_rec,
                          l_output_xml,
                          l_api_name
                          );
x_return_status :=  l_return_status;
IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
    fnd_message.set_token('ERRNO', sqlcode);
    fnd_message.set_token('REASON', 'Error while Updating claim in Trade Management');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

-- Debug Message
DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Public API: ' || l_api_name || 'end');

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT;
   END IF;
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
(p_count => x_msg_count,
p_data => x_msg_data
   );
--Exception Handling
EXCEPTION
WHEN DPP_UTILITY_PVT.resource_locked THEN
   ROLLBACK TO UPDATE_CLAIMS_PVT;
   x_return_status := FND_API.g_ret_sts_error;
DPP_UTILITY_PVT.Error_Message(p_message_name => 'API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
    IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO UPDATE_CLAIMS_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO UPDATE_CLAIMS_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;
WHEN OTHERS THEN
   ROLLBACK TO UPDATE_CLAIMS_PVT;
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_CLAIMS_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
                FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
p_encoded => FND_API.G_FALSE,
p_count => x_msg_count,
p_data => x_msg_data
   );
 IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

END Update_Claims;
END DPP_CLAIMS_PVT;

/
