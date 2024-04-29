--------------------------------------------------------
--  DDL for Package Body OKL_REVERSE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REVERSE_CONTRACT_PVT" AS
/* $Header: OKLRRVKB.pls 120.19.12010000.3 2008/11/20 23:38:46 sgiyer ship $ */

  G_TRX_RVC_TCN_TYPE            CONSTANT VARCHAR2(3)  := 'RVC';
  G_TRX_TSU_CODE_SUBMITTED      CONSTANT VARCHAR2(10) := 'SUBMITTED';
  G_TRX_TSU_CODE_PROCESSED      CONSTANT VARCHAR2(10) := 'PROCESSED';
  G_TRX_TYPE_REVERSE            CONSTANT VARCHAR2(10) := 'Reverse';
  G_REVERSE                     CONSTANT VARCHAR2(10) := 'REVERSE';

  -- Bug#4542290 - smadhava - 17-Aug-2005 - Added - Start
  G_INT_CALC_REV_NOT_ALLWD CONSTANT VARCHAR2(30) := 'OKL_LLA_INT_CALC_REV_NOT_ALLWD';
  -- Bug#4542290 - smadhava - 17-Aug-2005 - Added - End
   /*
   -- mvasudev, 08/17/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_REVERSE_COMP CONSTANT VARCHAR2(52) := 'oracle.apps.okl.la.lease_contract.reversal_completed';

   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(15) := 'CONTRACT_ID';
   G_WF_ITM_TRX_DATE CONSTANT VARCHAR2(20) := 'TRANSACTION_DATE';

PROCEDURE Check_Contract_Status(
                p_contract_id IN NUMBER,
                x_return_status OUT NOCOPY VARCHAR2)
IS

  CURSOR cntrct_status_cur IS
  SELECT '1'
  FROM  okc_k_headers_v
  WHERE id = p_contract_id
  AND sts_code = G_BOOKED;

  l_dummy_var      VARCHAR2(1);
  l_row_notfound   BOOLEAN;

BEGIN

-- Check contract status. If not BOOKED, error out

  x_return_status := G_RET_STS_SUCCESS;

  OPEN cntrct_status_cur;
  FETCH cntrct_status_cur INTO l_dummy_var;
  l_row_notfound := cntrct_status_cur%NOTFOUND;
  CLOSE cntrct_status_cur;

  IF (l_row_notfound) THEN
    OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                       ,p_msg_name       => OKL_LLA_CONT_REV_BOOKED);
    x_return_status    := G_RET_STS_ERROR;
    RAISE G_EXCEPTION_ERROR;
  END IF;

EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

END Check_Contract_Status;


-- Procedure to update the contract status

PROCEDURE Update_Contracts ( p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2,
                            x_return_status      OUT  NOCOPY VARCHAR2,
                            x_msg_count          OUT  NOCOPY NUMBER,
                            x_msg_data           OUT  NOCOPY VARCHAR2,
                            p_contract_id        IN   NUMBER)
IS
  l_return_status        VARCHAR2(1);
  l_api_version          CONSTANT NUMBER := 1;
BEGIN

-- Update the status of the contract to REVERSED.

           OKL_CONTRACT_STATUS_PUB.update_contract_status(
                p_api_version              => l_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => l_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
            p_khr_status           => G_REVERSED,
            p_chr_id               => p_contract_id );

        IF l_return_status = G_RET_STS_ERROR THEN
           RAISE G_EXCEPTION_ERROR;
        ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

END Update_Contracts;


-- Procedue to Check if the transcation type class is BOOKING, FUNDING etc

PROCEDURE  Check_Trx_Type(
                p_contract_id IN NUMBER,
                x_return_status OUT NOCOPY VARCHAR2)
IS

  CURSOR trx_type_cur IS
  SELECT '1'
  FROM  OKL_TRX_CONTRACTS TC, OKL_TRX_TYPES_B TTB
  WHERE TC.KHR_ID = p_contract_id
  AND TC.TRY_ID = TTB.ID
--rkuttiya added for 12.1.1 Multi GAAP
  AND TC.REPRESENTATION_TYPE = 'PRIMARY'
--
  AND TTB.TRX_TYPE_CLASS NOT IN (G_BOOKING, G_GENERATE_YIELDS, G_REVERSE,
                 G_UPFRONT_TAX); -- G_UPFRONT_TAX introduced for R12 ebTax requirement

  CURSOR asset_cur IS
  SELECT '1'
  FROM  OKL_TRX_ASSETS A, OKL_TXL_ASSETS_B B, OKL_TRX_TYPES_B TTB
  WHERE B.DNZ_KHR_ID = p_contract_id
  AND A.ID = B.TAS_ID
  AND A.TRY_ID = TTB.ID
  AND TTB.TRX_TYPE_CLASS NOT IN (G_INTERNAL_ASSET_CREATION);

  -- sjalasut, modified the cursor to refer khr_id from okl_txl_ap_inv_lns_all_b instead
  -- of okl_trx_ap_invoices_b. changes made as part of OKLR12B disbursements project
  CURSOR ap_inv_cur IS
  SELECT '1'
  FROM  OKL_TRX_AP_INVOICES_B TAI, OKL_TRX_TYPES_B TTB
       ,OKL_TXL_AP_INV_LNS_ALL_B TPL
  WHERE TAI.ID = TPL.TAP_ID
  AND TPL.KHR_ID = p_contract_id
  AND TAI.TRY_ID = TTB.ID
  AND TTB.TRX_TYPE_CLASS NOT IN (G_FUNDING)
  AND TAI.TRX_STATUS_CODE = 'PROCESSED';

-- cklee 04/01/04
  CURSOR ar_inv_cur IS
  SELECT '1'
  FROM  OKL_TRX_AR_INVOICES_B TAI
  WHERE TAI.KHR_ID = p_contract_id
  AND TAI.TRX_STATUS_CODE = 'PROCESSED';

  l_dummy_var      VARCHAR2(1);
  l_row_notfound   BOOLEAN;
  l_row_found   BOOLEAN;
  l_select_statement VARCHAR2(4000);

BEGIN
  x_return_status := G_RET_STS_SUCCESS;

  -- If there are any transactions with transaction type other than
  -- BOOKING, FUNDING, INTERNAL_ASSET_CREATION and GENERATE_YIELDS,
  -- error out.

  OPEN trx_type_cur;
  FETCH trx_type_cur INTO l_dummy_var;
  l_row_notfound := trx_type_cur%NOTFOUND;
  CLOSE trx_type_cur;

  IF NOT (l_row_notfound) THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                       ,p_msg_name       => okl_lla_cont_rev_trx_type
                       ,p_token1         => g_source_table
                       ,p_token1_value   => g_okl_txl_cntrct_lns);
    x_return_status    := G_RET_STS_ERROR;
        RAISE G_EXCEPTION_ERROR;
  END IF;

  OPEN asset_cur;
  FETCH asset_cur INTO l_dummy_var;
  l_row_notfound := asset_cur%NOTFOUND;
  CLOSE asset_cur;

  IF NOT (l_row_notfound) THEN
    OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                       ,p_msg_name       => okl_lla_cont_rev_trx_type
                       ,p_token1         => g_source_table
                       ,p_token1_value   => g_okl_txl_assets_b);
    x_return_status    := G_RET_STS_ERROR;
    RAISE G_EXCEPTION_ERROR;
  END IF;

  OPEN ap_inv_cur;
  FETCH ap_inv_cur INTO l_dummy_var;
  l_row_notfound := ap_inv_cur%NOTFOUND;
  CLOSE ap_inv_cur;

  IF NOT (l_row_notfound) THEN
    OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                       ,p_msg_name       => okl_lla_cont_rev_trx_type
                       ,p_token1         => g_source_table
                       ,p_token1_value   => g_okl_txl_ap_inv_lns_b);
    x_return_status    := G_RET_STS_ERROR;
    RAISE G_EXCEPTION_ERROR;
  END IF;

-- cklee 04/01/2004
  OPEN ar_inv_cur;
  FETCH ar_inv_cur INTO l_dummy_var;
  l_row_found := ar_inv_cur%FOUND;
  CLOSE ar_inv_cur;

  IF (l_row_found) THEN
    OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                       ,p_msg_name       => OKL_LLA_AR_INV_LINE_EXIST);

    x_return_status    := G_RET_STS_ERROR;
    RAISE G_EXCEPTION_ERROR;
  END IF;
-- cklee 04/01/2004

EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

END Check_Trx_Type;


-- Procedure to reverse the transactions..
PROCEDURE  Reverse_Trx (
                p_contract_id IN NUMBER,
                p_transaction_date IN DATE,
                x_return_status OUT NOCOPY VARCHAR2,
                -- R12B eBtax
                p_reverse_trx_id IN NUMBER)
IS
  l_tcnv_rec    tcnv_rec_type;
  l_tcnv_tbl    OKL_TCN_PVT.tcnv_tbl_type;
  x_tcnv_rec    tcnv_rec_type;
  l_tapv_rec    tapv_rec_type;
  x_tapv_rec    tapv_rec_type;
  l_thpv_rec    thpv_rec_type;
  x_thpv_rec    thpv_rec_type;

  l_api_version          CONSTANT NUMBER := 1;
  l_api_name             CONSTANT VARCHAR2(30) := 'REVERSE_CONTRACT';
  l_return_status        VARCHAR2(1);
  l_init_msg_list        VARCHAR2(20) DEFAULT G_FALSE;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_trx_type_class               VARCHAR2(60);
  l_dist_not_found               BOOLEAN;
  l_found                                VARCHAR2(1);
  l_count                NUMBER :=0;

  CURSOR ctrct_trx_cur IS
  SELECT ID, TRY_ID, transaction_date
  FROM  OKL_TRX_CONTRACTS
  WHERE KHR_ID = p_contract_id
 --rkuttiya added for 12.1.1 Multi GAAP
  AND REPRESENTATION_TYPE = 'PRIMARY';
 --

  CURSOR ctrct_trx_lines_cur (p_tcn_id NUMBER) IS
  SELECT ID
  FROM  OKL_TXL_CNTRCT_LNS
  WHERE TCN_ID = p_tcn_id;

  CURSOR asset_trx_cur IS
  SELECT DISTINCT TAS.ID TAS_ID,TAS.TRANSACTION_DATE
  FROM  OKL_TXL_ASSETS_B TA,OKL_TRX_ASSETS TAS
  WHERE TA.DNZ_KHR_ID = p_contract_id
  AND TA.TAS_ID=TAS.ID;

  CURSOR asset_trx_lines_cur (p_tas_id NUMBER) IS
  SELECT ID
  FROM  OKL_TXL_ASSETS_B TA
  WHERE TA.TAS_ID = p_tas_id;

  -- sjalasut, modified the cursor to refer khr_id from okl_txl_ap_inv_lns_all_b instead
  -- of okl_trx_ap_invoices_b. changes made as part of OKLR12B disbursements project
  CURSOR ap_inv_trx_cur IS
  SELECT a.ID, a.try_id
  FROM  OKL_TRX_AP_INVOICES_B a
       ,okl_txl_ap_inv_lns_all_b b
  WHERE a.id = b.tap_id
    AND b.khr_id = p_contract_id;

  CURSOR ap_inv_trx_lines_cur (p_tap_id NUMBER) IS
  SELECT ID
  FROM  OKL_TXL_AP_INV_LNS_B
  WHERE TAP_ID = p_tap_id;

  CURSOR trx_type_cur (p_try_id NUMBER) IS
  SELECT TRX_TYPE_CLASS
  FROM  OKL_TRX_TYPES_B
  WHERE ID = p_try_id;

  CURSOR dist_cur (p_source_table VARCHAR2, p_source_id NUMBER) IS
  SELECT '1'
  FROM  OKL_TRNS_ACC_DSTRS
  WHERE SOURCE_ID = p_source_id
  AND SOURCE_TABLE = p_source_table;

  -- sjalasut, added local variables to support logging
  l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_REVERSE_CONTRACT_PVT.REVERSE_TRX';
  l_debug_enabled VARCHAR2(10);
  is_debug_statement_on BOOLEAN;

  -- R12 Change - START

  SUBTYPE SOURCE_ID_TBL_TYPE IS OKL_REVERSAL_PVT.SOURCE_ID_TBL_TYPE;
  l_booking_source_id_tbl       SOURCE_ID_TBL_TYPE;
  l_upfronttax_source_id_tbl    SOURCE_ID_TBL_TYPE;
  l_upfronttax_trx_exists       BOOLEAN := FALSE;
  l_booking_trx_count           NUMBER := 1;
  l_upfronttax_trx_count        NUMBER := 1;
  l_upfronttax_trx_id           OKL_TRX_CONTRACTS.ID%TYPE;

  -- R12 Change - END


BEGIN

  -- check if debug is enabled
  l_debug_enabled := okl_debug_pub.check_log_enabled;
  -- check for logging on STATEMENT level
  is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

  -- Reverse Contract Lines Transactions
  FOR ctrct_trx_rec IN ctrct_trx_cur
  LOOP
    l_tcnv_rec.id := ctrct_trx_rec.id;
    l_tcnv_rec.tsu_code := G_CANCELED;
    l_tcnv_rec.transaction_date := ctrct_trx_rec.transaction_date;
    l_tcnv_rec.canceled_date := p_transaction_date;
    OKL_TRX_CONTRACTS_PUB.update_trx_contracts(
                 p_api_version      => l_api_version
                ,p_init_msg_list    => l_init_msg_list
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data
                ,p_tcnv_rec         => l_tcnv_rec
                ,x_tcnv_rec         => x_tcnv_rec );

    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    FOR trx_type_rec IN trx_type_cur (ctrct_trx_rec.try_id)
    LOOP
      l_trx_type_class :=   trx_type_rec.trx_type_class;
    END LOOP;

    -- Identify all Booking accounting entries
    IF l_trx_type_class = G_BOOKING THEN

      FOR ctrct_trx_lines_rec IN ctrct_trx_lines_cur (ctrct_trx_rec.id)
      LOOP
        OPEN dist_cur (G_OKL_TXL_CNTRCT_LNS, ctrct_trx_lines_rec.id);
        FETCH dist_cur INTO l_found;
        l_dist_not_found := dist_cur%NOTFOUND;
        CLOSE dist_cur;
        IF NOT l_dist_not_found THEN
          l_booking_source_id_tbl(l_booking_trx_count) := ctrct_trx_lines_rec.id;
        END IF;
        l_booking_trx_count := l_booking_trx_count + 1;
      END LOOP;

      l_count := l_count+1;
      l_tcnv_tbl(l_count).id := ctrct_trx_rec.id;
      l_tcnv_tbl(l_count).canceled_date := p_transaction_date;

    END IF;

    -- Identify all upfront tax accounting entries
    IF l_trx_type_class = G_UPFRONT_TAX THEN -- G_UPFRONT_TAX introduced for R12 ebTax requirement
      l_upfronttax_trx_id := ctrct_trx_rec.id;
      l_upfronttax_trx_exists := TRUE;

      FOR ctrct_trx_lines_rec IN ctrct_trx_lines_cur (ctrct_trx_rec.id)
      LOOP
        l_upfronttax_source_id_tbl(l_upfronttax_trx_count) := ctrct_trx_lines_rec.id;
        l_upfronttax_trx_count := l_upfronttax_trx_count + 1;
      END LOOP;

    END IF;

  END LOOP;

  -- R12 Changes - START
  -- In R12 accounting reversal API will be called only once for
  -- each transaction event, BOOKING and 'Upfront Tax'

  -- 1. Reverse Booking accounting entries
  OKL_REVERSAL_PUB.REVERSE_ENTRIES (
                           p_api_version      => l_api_version,
                           p_init_msg_list    => l_init_msg_list,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           p_source_table     => G_OKL_TXL_CNTRCT_LNS,
                           p_acct_date        => p_transaction_date,
                           p_source_id_tbl    => l_booking_source_id_tbl);
  IF l_return_status = G_RET_STS_ERROR THEN
    RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  --Bug 7555210. Multi-GAAP Engine Call for reversing secondary representation accounting
  OKL_MULTIGAAP_ENGINE_PVT.REVERSE_SEC_REP_TRX (
          P_API_VERSION                  => l_api_version,
          P_INIT_MSG_LIST                => l_init_msg_list,
          X_RETURN_STATUS                => l_return_status,
          X_MSG_COUNT                    => l_msg_count,
          X_MSG_DATA                     => l_msg_data,
          P_TCNV_TBL                     => l_tcnv_tbl);

  IF l_return_status = G_RET_STS_ERROR THEN
    RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;


  -- 2. Reverse Upfront Tax accounting entries
  IF l_upfronttax_trx_exists = TRUE THEN

    OKL_REVERSAL_PUB.REVERSE_ENTRIES (
                           p_api_version      => l_api_version,
                           p_init_msg_list    => l_init_msg_list,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           p_source_table     => G_OKL_TXL_CNTRCT_LNS,
                           p_acct_date        => p_transaction_date,
                           p_source_id_tbl    => l_upfronttax_source_id_tbl);

    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  END IF;

  -- R12B eBtax: Upfront Tax Lines should be reversed regardless of whether
  -- or not Upfront Tax accounting entries exist
  okl_process_sales_tax_pvt.calculate_sales_tax(
                           p_api_version      => l_api_version,
                           p_init_msg_list    => l_init_msg_list,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           p_source_trx_id    => p_reverse_trx_id,
                           p_source_trx_name  => 'Reverse',
                           p_source_table     => 'OKL_TRX_CONTRACTS');

  IF l_return_status = G_RET_STS_ERROR THEN
    RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- R12 Changes - END


  -- Reverse Asset Transactions
  FOR asset_trx_rec IN asset_trx_cur
  LOOP
    l_thpv_rec.id := asset_trx_rec.tas_id;
    l_thpv_rec.TSU_CODE := G_CANCELED;
    l_thpv_rec.transaction_date := asset_trx_rec.transaction_date;
    OKL_TRX_ASSETS_PUB.update_trx_ass_h_Def(
                 p_api_version      => l_api_version
                ,p_init_msg_list    => l_init_msg_list
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data
                ,p_thpv_rec         => l_thpv_rec
                ,x_thpv_rec         => x_thpv_rec );
     IF l_return_status = G_RET_STS_ERROR THEN
       RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
/*
-- Call the Accounting Engine to reverse the transactions, by passing source id
          -- and source tables

       FOR asset_trx_lines_rec IN asset_trx_lines_cur (asset_trx_rec.tas_id)
           LOOP

                  OKL_ACCOUNT_DIST_PUB.REVERSE_ENTRIES
                                                  (p_api_version      => l_api_version,
                           p_init_msg_list    => l_init_msg_list,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           p_source_id        => asset_trx_lines_rec.id,
                           p_source_table     => G_OKL_TXL_ASSETS_B,
                           p_acct_date        => p_transaction_date);


           IF l_return_status = G_RET_STS_ERROR THEN
             RAISE G_EXCEPTION_ERROR;
           ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
           END LOOP;
*/

         END LOOP;

   /*
    * sjalasut: Feb 25, 05 added logic to reverse subsidy pool transactions
    * for assets on the contract
    * Logic added as part of subsidy pools enhancement. START
    */
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'calling okl_subsidy_pool_auth_trx_pvt.create_pool_trx_khr_reverse with p_chr_id '|| p_contract_id ||
                                ' p_transaction_date '||p_transaction_date
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

      okl_subsidy_pool_auth_trx_pvt.create_pool_trx_khr_reverse(p_api_version => l_api_version
                                                               ,p_init_msg_list    => l_init_msg_list
                                                               ,x_return_status    => l_return_status
                                                               ,x_msg_count        => l_msg_count
                                                               ,x_msg_data         => l_msg_data
                                                               ,p_chr_id           => p_contract_id
                                                               ,p_reversal_date    => p_transaction_date
                                                               ,p_override_trx_reason => NULL -- pass this as null from there as this holds override value
                                                               );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_auth_trx_pvt.create_pool_trx_khr_reverse returned with '||l_return_status||
                                ' l_msg_data '||l_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

      IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
      ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

   /*
    * sjalasut: Feb 25, 05 added logic to reverse subsidy pool transactions
    * for assets on the contract
    * Logic added as part of subsidy pools enhancement. END
    */



--
-- Commented out as the logic for processing funding request changes.
--

/*
-- Reverse AP Invoice Lines Transactions

     FOR ap_inv_trx_rec IN ap_inv_trx_cur
         LOOP

       l_tapv_rec.id := ap_inv_trx_rec.id;
       l_tapv_rec.TRX_STATUS_CODE := G_CANCELED;

       OKL_TRX_AP_INVOICES_PUB.update_trx_ap_invoices(
                 p_api_version      => l_api_version
                ,p_init_msg_list    => l_init_msg_list
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data
                        ,p_tapv_rec         => l_tapv_rec
                        ,x_tapv_rec         => x_tapv_rec );

       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       FOR trx_type_rec IN trx_type_cur (ap_inv_trx_rec.try_id) LOOP
         l_trx_type_class :=   trx_type_rec.trx_type_class;
       END LOOP;


          -- Call the Accounting Engine to reverse the transactions, by passing source id
          -- and source tables

       IF l_trx_type_class = G_FUNDING THEN
         FOR ap_inv_trx_lines_rec IN ap_inv_trx_lines_cur (ap_inv_trx_rec.id)
           LOOP

                        OPEN dist_cur (G_OKL_TXL_AP_INV_LNS_B, ap_inv_trx_lines_rec.id);
                        FETCH dist_cur INTO l_found;
                    l_dist_not_found := dist_cur%NOTFOUND;
                    CLOSE dist_cur;

               IF NOT l_dist_not_found THEN

                  OKL_ACCOUNT_DIST_PUB.REVERSE_ENTRIES
                                                  (p_api_version      => l_api_version,
                           p_init_msg_list    => l_init_msg_list,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           p_source_id        => ap_inv_trx_lines_rec.id,
                           p_source_table     => G_OKL_TXL_AP_INV_LNS_B,
                           p_acct_date        => p_transaction_date);

           IF l_return_status = G_RET_STS_ERROR THEN
             RAISE G_EXCEPTION_ERROR;
           ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
                  END IF;
           END LOOP;
         END IF;

     END LOOP;

*/


--
-- Reverse Funding Requests once contract has been reversed : cklee 06/27/02
--

    OKL_FUNDING_PVT.reverse_funding_requests
                 (p_api_version    => l_api_version
                  ,p_init_msg_list => l_init_msg_list
                  ,x_return_status => l_return_status
                  ,x_msg_count     => l_msg_count
                  ,x_msg_data      => l_msg_data
                  ,p_contract_id => p_contract_id);

    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
--
-- End of Reverse Funding Requests once contract has been reversed : cklee 06/27/02
--

END Reverse_Trx ;



-- Procedure which reverses a contract

PROCEDURE Reverse_Contract (p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            p_contract_id         IN   NUMBER,
                            p_transaction_date    IN   DATE )
IS
-- cklee
  l_tcnv_rec    tcnv_rec_type;
  x_tcnv_rec    tcnv_rec_type;
-- cklee
  l_allow_reversal VARCHAR2(1);
  l_dummy_var      VARCHAR2(1);
  l_trx_id                 NUMBER;
  l_row_notfound   BOOLEAN;
  -- Manu 11-Aug-2004
  l_contract_number      OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
  l_row_found   BOOLEAN;
  --Added by dpsingh for LE uptake
  l_legal_entity_id          NUMBER;
  l_api_version          CONSTANT NUMBER := 1;
  l_api_name             CONSTANT VARCHAR2(30) := 'REVERSE_CONTRACT';
  l_return_status        VARCHAR2(1);
  l_init_msg_list        VARCHAR2(20) DEFAULT G_FALSE;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

-- cklee
  l_try_id NUMBER;

    -- Bug 5202448 :  kbbhavsa : 12-May-2006 : Start
    -- Changed the cursor definition for language support
    CURSOR l_tryv_csr IS
    SELECT TRYB.id
    FROM   OKL_TRX_TYPES_B TRYB,
	   OKL_TRX_TYPES_TL TRYT
    WHERE
     TRYB.ID = TRYT.ID and
     TRYT.LANGUAGE = 'US' and
     TRYT.NAME = G_TRX_TYPE_REVERSE;
    -- Bug 5202448 :  kbbhavsa : 12-May-2006 : End
 -- cklee

  CURSOR cntrct_cur IS
  SELECT '1'
  FROM  okc_k_headers_v
  WHERE id = p_contract_id;

  CURSOR ctrct_trx_cur IS
  SELECT '1'
  FROM  OKL_TRX_CONTRACTS
  WHERE KHR_ID = p_contract_id
  --rkuttiya added for 12.1.1 Multi GAAP
  AND REPRESENTATION_TYPE = 'PRIMARY';

  -- sjalasut, modified the cursor to refer khr_id from okl_txl_ap_inv_lns_all_b instead
  -- of okl_trx_ap_invoices_b. changes made as part of OKLR12B disbursements project
  CURSOR ap_inv_trx_cur IS
  SELECT '1'
  FROM  OKL_TRX_AP_INVOICES_B a
      , okl_txl_ap_inv_lns_all_b b
  WHERE a.id = b.tap_id
    AND b.KHR_ID = p_contract_id;

  CURSOR asset_trx_cur IS
  SELECT '1'
  FROM   OKL_TXL_ASSETS_B
  WHERE  DNZ_KHR_ID = p_contract_id;

  -- Start Manu 11-Aug-2004.
  -- Cursor to find if there are any Rollover Fee lines on a contract

  CURSOR rollover_fee_line_csr(p_k_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
  SELECT 1 FROM okc_k_lines_b CLEB, okl_k_lines KLE
  WHERE CLEB.dnz_chr_id = p_k_id
  AND KLE.FEE_TYPE = 'ROLLOVER'
  AND KLE.ID = CLEB.ID
  AND    NOT EXISTS (
                 SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

  -- Cursor to select contract number

  CURSOR contract_number_csr(p_k_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT contract_number FROM okc_k_headers_v
  WHERE id = p_k_id;

  -- End Manu  11-Aug-2004

  -- Bug#4542290 - smadhava - 17-Aug-2005 - Added - Start
  CURSOR chk_interest_processing(p_chr_id OKL_K_HEADERS.id%TYPE) IS
  SELECT
        'X'
    FROM
        OKL_K_HEADERS
    WHERE
          id = p_chr_id
      AND DATE_LAST_INTERIM_INTEREST_CAL IS NOT NULL;

  l_interest_processed_flag VARCHAR2(1);
  -- Bug#4542290 - smadhava - 17-Aug-2005 - Added - End

    /*
    -- mvasudev, 08/30/2004
    -- Added PROCEDURE to enable Business Event
    */
        PROCEDURE raise_business_event(x_return_status OUT NOCOPY VARCHAR2
    )
        IS
      l_parameter_list           wf_parameter_list_t;
        BEGIN

         wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_contract_id,l_parameter_list);
         wf_event.AddParameterToList(G_WF_ITM_TRX_DATE,fnd_date.date_to_canonical(p_transaction_date),l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                                                 x_return_status  => x_return_status,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data,
                                                                 p_event_name     => G_WF_EVT_KHR_REVERSE_COMP,
                                                                 p_parameters     => l_parameter_list);



     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 08/30/2004
    -- END, PROCEDURE to enable Business Event
    */


BEGIN

-- Start Activity

    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);


    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



-- Check for the required attributes
   IF (p_contract_id IS NULL OR p_contract_id = G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Contract ID');
       x_return_status    := G_RET_STS_ERROR;
           RAISE G_EXCEPTION_ERROR;
   END IF;

   IF (p_transaction_date IS NULL OR p_transaction_date = G_MISS_DATE) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Revision Date');
       x_return_status    := G_RET_STS_ERROR;
           RAISE G_EXCEPTION_ERROR;
   END IF;

-- Check if the contract is a valid one

     OPEN cntrct_cur;
     FETCH cntrct_cur INTO l_dummy_var;
     l_row_notfound := cntrct_cur%NOTFOUND;
     CLOSE cntrct_cur;

     IF (l_row_notfound) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Contract ID');
       x_return_status    := G_RET_STS_ERROR;
           RAISE G_EXCEPTION_ERROR;
     END IF;

  -- Check if the status of the contract is BOOKED. If not , Error out
     Check_Contract_Status(
                p_contract_id => p_contract_id,
                x_return_status => l_return_status) ;


      IF l_return_status = G_RET_STS_ERROR THEN
         RAISE G_EXCEPTION_ERROR;
      ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      -- Bug#4542290 - smadhava - 17-Aug-2005 - Modified - Start
      -- Moved code to facilitate usage of contract number in error messages
      -- Get Contract Number.
      OPEN contract_number_csr(p_k_id => p_contract_id);
         FETCH contract_number_csr INTO l_contract_number;
      CLOSE contract_number_csr;
      -- Bug#4542290 - smadhava - 17-Aug-2005 - Modified - End

     -- Bug#4542290 - smadhava - 17-Aug-2005 - Added - Start
     OPEN chk_interest_processing(p_contract_id);
       FETCH chk_interest_processing INTO l_interest_processed_flag;
     CLOSE chk_interest_processing;

     -- Contract Reversal not allowed if interest for this contract has already been processed.
     IF ( l_interest_processed_flag = 'X') THEN
       OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME
                          ,p_msg_name       => G_INT_CALC_REV_NOT_ALLWD
                           ,p_token1         => g_col_name_token
                           ,p_token1_value   => l_contract_number);
       RAISE G_EXCEPTION_ERROR;
     END IF; -- end of check for interest processing
     -- Bug#4542290 - smadhava - 17-Aug-2005 - Added - End

      -- Start Manu 11-Aug-2004.
      -- Check if there are any Rollover Fee lines on a contract.

      OPEN rollover_fee_line_csr(p_k_id => p_contract_id);
         FETCH rollover_fee_line_csr INTO l_dummy_var;
         l_row_found := rollover_fee_line_csr%FOUND;
      CLOSE rollover_fee_line_csr;

      -- Error out if there are any Rollover Fee lines on a contract.

      IF (l_row_found) THEN
        OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name       => OKL_LA_NO_REV_CONTRACT
                           ,p_token1         => g_col_name_token
                           ,p_token1_value   => l_contract_number);
        x_return_status    := G_RET_STS_ERROR;
        RAISE G_EXCEPTION_ERROR;
      END IF;

      -- End Manu  11-Aug-2004.

-- start cklee
    OPEN  l_tryv_csr;
    FETCH l_tryv_csr INTO l_try_id;
    CLOSE l_tryv_csr;

    l_tcnv_rec.tcn_type                   := G_TRX_RVC_TCN_TYPE;
    l_tcnv_rec.tsu_code                   := G_TRX_TSU_CODE_SUBMITTED;
    l_tcnv_rec.khr_id                     := p_contract_id;
    l_tcnv_rec.try_id                     := l_try_id;
    l_tcnv_rec.date_transaction_occurred  := p_transaction_date;
    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
       Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_contract_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

      -- Create Transaction Header
        Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_tcnv_rec
            ,x_tcnv_rec         => x_tcnv_rec);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
-- end cklee

  -- If the contract does not have any transactions, then update the status
  -- of the contract to REVERSED

     OPEN ctrct_trx_cur;
     FETCH ctrct_trx_cur INTO l_dummy_var;
     l_row_notfound := ctrct_trx_cur%NOTFOUND;
     CLOSE ctrct_trx_cur;

         IF l_row_notfound THEN
       OPEN ap_inv_trx_cur;
       FETCH ap_inv_trx_cur INTO l_dummy_var;
       l_row_notfound := ap_inv_trx_cur%NOTFOUND;
       CLOSE ap_inv_trx_cur;
         END IF;

         IF l_row_notfound THEN
       OPEN asset_trx_cur;
       FETCH asset_trx_cur INTO l_dummy_var;
       l_row_notfound := asset_trx_cur%NOTFOUND;
       CLOSE asset_trx_cur;
         END IF;

     IF (l_row_notfound) THEN  -- If the contract does not have transactions

       -- Update the status of the contract to REVERSED.


        Update_Contracts ( p_api_version      => l_api_version,
                         p_init_msg_list     => l_init_msg_list,
                         x_return_status     => l_return_status,
                         x_msg_count         => l_msg_count,
                         x_msg_data          => l_msg_data,
                         p_contract_id       => p_contract_id );


        IF l_return_status = G_RET_STS_ERROR THEN
           RAISE G_EXCEPTION_ERROR;
        ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

     ELSE -- If the contract does have any transactions

  -- If the contract has any transactions, then check to see if the transaction type
  -- class is not in FUNDING and BOOKING, INTERNAL ASSET CREATION and GENEATE YIELS.
  -- If there are transactions with any other trx type, then error out.

      Check_Trx_Type(p_contract_id => p_contract_id,
                     x_return_status => l_return_status) ;

      IF l_return_status = G_RET_STS_ERROR THEN
         RAISE G_EXCEPTION_ERROR;
      ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


         Reverse_Trx (
                p_contract_id => p_contract_id,
                p_transaction_date => p_transaction_date,
                x_return_status => x_return_status,
                -- R12B eBTax
                p_reverse_trx_id => x_tcnv_rec.id);

        IF l_return_status = G_RET_STS_ERROR THEN
           RAISE G_EXCEPTION_ERROR;
        ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;


  -- Update the status of the contract to REVERSED once all the transactions are reversed
         Update_Contracts ( p_api_version      => l_api_version,
                         p_init_msg_list     => l_init_msg_list,
                         x_return_status     => l_return_status,
                         x_msg_count         => l_msg_count,
                         x_msg_data          => l_msg_data,
                         p_contract_id       => p_contract_id );

        IF l_return_status = G_RET_STS_ERROR THEN
           RAISE G_EXCEPTION_ERROR;
        ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

  END IF; -- If the contract has any transactions

-- start cklee
    l_tcnv_rec.id                   := x_tcnv_rec.id;
    l_tcnv_rec.tsu_code             := G_TRX_TSU_CODE_PROCESSED;
    l_tcnv_rec.transaction_date     := x_tcnv_rec.transaction_date;
    -- Update Transaction Header
    Okl_Trx_Contracts_Pub.update_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_tcnv_rec
            ,x_tcnv_rec         => x_tcnv_rec);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
-- end cklee

   /*
   -- mvasudev, 08/23/2004
   -- Code change to enable Business Event
   */
        raise_business_event(x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/23/2004
   -- END, Code change to enable Business Event
   */

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := G_RET_STS_SUCCESS;


EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

END Reverse_Contract;




END OKL_REVERSE_CONTRACT_PVT;

/
