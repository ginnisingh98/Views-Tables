--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_CALC_PVT" AS
/* $Header: OKLRITUB.pls 120.24 2007/02/08 10:36:36 sjalasut noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.INTEREST';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator


PROCEDURE CREATE_TRX_ACCT(p_khr_id        IN  NUMBER,
                          p_product_id    IN  NUMBER,
                          p_amount        IN  NUMBER,
                          p_calc_date     IN  DATE,
                          x_source_id     OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2)


IS
  -- Code can be commented for billing transaction- HKPATEL
  /*
  l_tcnv_rec_in    OKL_TRX_CONTRACTS_PUB.TCNV_REC_TYPE;
  l_tcnv_rec_out   OKL_TRX_CONTRACTS_PUB.TCNV_REC_TYPE;
  l_tclv_tbl_in    OKL_TRX_CONTRACTS_PUB.TCLV_TBL_TYPE;
  l_tclv_tbl_out   OKL_TRX_CONTRACTS_PUB.TCLV_TBL_TYPE;
  */
  -- Commented code for billing transaction ends here- HKPATEL

  l_khrv_rec_in    OKL_CONTRACT_PUB.khrv_rec_type;
  l_khrv_rec_out   OKL_CONTRACT_PUB.khrv_rec_type;
  l_chrv_rec_in    okl_okc_migration_pvt.chrv_rec_type;
  l_chrv_rec_out   okl_okc_migration_pvt.chrv_rec_type;
  l_error_msg_rec  OKL_ACCOUNTING_UTIL.Error_message_Type;

  l_tmpl_identify_rec OKL_ACCOUNT_DIST_PUB.TMPL_IDENTIFY_REC_TYPE;
  l_dist_info_rec     OKL_ACCOUNT_DIST_PUB.DIST_INFO_REC_TYPE;
  l_ctxt_val_tbl      OKL_ACCOUNT_DIST_PUB.CTXT_VAL_TBL_TYPE;
  l_acc_gen_tbl       OKL_ACCOUNT_DIST_PUB.ACC_GEN_PRIMARY_KEY;
  l_avlv_tbl          OKL_TMPT_SET_PUB.avlv_tbl_type;
  l_amount_tbl        OKL_ACCOUNT_DIST_PUB.amount_tbl_type;

  l_try_id         NUMBER;
  l_sty_id         NUMBER;
  l_product_id     NUMBER;
  l_amount         NUMBER := 0;

  l_init_msg_list  VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  -- Code added by HKPATEL for billing transaction
  l_api_version    CONSTANT NUMBER    :=    1;
  l_line_number    CONSTANT NUMBER    :=    1;
  l_int_desc       VARCHAR2(4000)  := 'Interest Calculation';
  -- Invoice Header
  i_taiv_rec       okl_trx_ar_invoices_pub.taiv_rec_type;
  r_taiv_rec       okl_trx_ar_invoices_pub.taiv_rec_type;

  -- Invoice Line
  i_tilv_rec       okl_txl_ar_inv_lns_pub.tilv_rec_type;
  r_tilv_rec       okl_txl_ar_inv_lns_pub.tilv_rec_type;

  -- Added code by HKPATEL ends here

  -- Added by Santonyr on 27-Nov-2002 for Multi-Currency Changes
  l_functional_currency         GL_LEDGERS_PUBLIC_V.currency_code%TYPE;
  l_currency_code	 	okl_trx_contracts.currency_code%TYPE;
  l_currency_conversion_type	okl_trx_contracts.currency_conversion_type%TYPE;
  l_currency_conversion_rate	okl_trx_contracts.currency_conversion_rate%TYPE;
  l_currency_conversion_date	okl_trx_contracts.currency_conversion_date%TYPE;

  --Bug 4622198
  l_fact_sync_code         VARCHAR2(2000);
  l_inv_acct_code          VARCHAR2(2000);
  l_scs_code               VARCHAR2(2000);

  -- Derived the currency conversion factors from Contracts table

  CURSOR curr_csr (l_khr_id NUMBER) IS
  select CHRB.CURRENCY_CODE,
       KHR.CURRENCY_CONVERSION_TYPE,
       KHR.CURRENCY_CONVERSION_RATE,
       KHR.CURRENCY_CONVERSION_DATE
  from OKC_K_HEADERS_B CHRB,OKL_K_HEADERS KHR
  WHERE KHR.ID = CHRB.ID
  AND CHRB.ID = l_khr_id;

  CURSOR try_csr IS
  SELECT id
  FROM OKL_TRX_TYPES_TL
  WHERE name = 'Billing'
  AND language = 'US';

  -- cursor to get scs_code
  CURSOR scs_code_csr IS
  SELECT scs_code
  FROM OKL_K_HEADERS_FULL_V
  WHERE id = p_khr_id;


--commented as a part of user defined streams change  - kmotepal
-- Bug 3940088

/*  CURSOR sty_csr IS
  SELECT ID
  FROM OKL_STRM_TYPE_TL
  WHERE name = 'INTERIM INTEREST' ;   */


  l_org_id  NUMBER;


  Cursor sales_csr(v_khr_id NUMBER) IS
  SELECT ct.object1_id1 id
  from   okc_contacts        ct,
         okc_contact_sources csrc,
         okc_k_party_roles_b pty,
         okc_k_headers_b     chr
  where  ct.cpl_id               = pty.id
  and    ct.cro_code             = csrc.cro_code
  and    ct.jtot_object1_code    = csrc.jtot_object_code
  and    ct.dnz_chr_id           = chr.id
  and    pty.rle_code            = csrc.rle_code
  and    csrc.cro_code           = 'SALESPERSON'
  and    csrc.rle_code           = 'LESSOR'
  and    csrc.buy_or_sell        = chr.buy_or_sell
  and    pty.dnz_chr_id          = chr.id
  and    pty.chr_id              = chr.id
  and    chr.id                  = v_khr_id;

  l_sales_rep  OKC_CONTACTS.object1_id1%TYPE;

  CURSOR trx_csr IS
  SELECT cust_trx_type_id
  FROM ra_cust_trx_types
  WHERE name = 'Invoice-OKL';

  l_trx_type NUMBER;

  Cursor Billto_csr(v_khr_id NUMBER) IS
  SELECT object1_id1 cust_acct_site_id
  FROM okc_rules_b rul
  WHERE  rul.rule_information_category = 'BTO'
         and exists (select '1'
                     from okc_rule_groups_b rgp
                     where rgp.id = rul.rgp_id
                          and   rgp.rgd_code = 'LABILL'
                          and   rgp.chr_id   = rul.dnz_chr_id
                          and   rgp.chr_id = v_khr_id );

  l_ar_site_use OKC_RULES_B.object1_id1%TYPE;
-- Added by dpsingh for LE Uptake
 -- cursor to get the contract number
  CURSOR contract_num_csr (p_ctr_id NUMBER) IS
  SELECT  contract_number
  FROM okc_k_headers_b
  WHERE id = p_ctr_id;

l_legal_entity_id   Number;
l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

BEGIN

    OPEN try_csr;
    FETCH try_csr INTO l_try_id;
    CLOSE try_csr;

--kmotepal calling a util to get primary stream id as a part of user defined streams change
-- Bug 3940088

  Okl_Streams_Util.get_primary_stream_type(p_khr_id,'PREFUNDING_INTEREST_PAYMENT',l_return_status,l_sty_id);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

 -- Fetch the functional currency
   l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

-- Added by Santonyr on 22-Nov-2002. Multi-Currency Changes
-- Fetch the currency conversion factors from Contracts table

     FOR curr_rec IN curr_csr(p_khr_id) LOOP
       l_currency_code		  := curr_rec.currency_code;
       l_currency_conversion_type := curr_rec.currency_conversion_type;
       l_currency_conversion_rate := curr_rec.currency_conversion_rate;
       l_currency_conversion_date := curr_rec.currency_conversion_date;
     END LOOP;

-- Fetch the currency conversion factors from GL_DAILY_RATES if the
-- conversion type is not 'USER'.

     IF UPPER(l_currency_conversion_type) <> 'USER' THEN
	 l_currency_conversion_date := SYSDATE;
         l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate
         	(p_from_curr_code => l_currency_code,
       		p_to_curr_code => l_functional_currency,
       		p_con_date => l_currency_conversion_date,
		p_con_type => l_currency_conversion_type);

     END IF; -- End IF for (UPPER(l_currency_conversion_type) <> 'USER')

    l_amount    := OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT
    					   (p_amount        => p_amount,
			                    p_currency_code => l_currency_code);

    -- Code can be commented to create billing transaction - HKPATEL

    -- Code can be commented till here - HKPATEL

    -- Code needed for billing transaction- HKPATEL
    ----------------------------------------------------------------------------------
            -- Preparing Invoice Header.
    ----------------------------------------------------------------------------------
    --Added by dpsingh for LE Uptake
            l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id) ;
            IF  l_legal_entity_id IS NOT NULL THEN
                 i_taiv_rec.legal_entity_id :=  l_legal_entity_id;
            ELSE
                OPEN contract_num_csr(p_khr_id);
                FETCH contract_num_csr INTO l_cntrct_number;
                CLOSE contract_num_csr;
		Okl_Api.set_message(p_app_name     => g_app_name,
                                                 p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                         p_token1           =>  'CONTRACT_NUMBER',
			                         p_token1_value  =>  l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

    i_taiv_rec.try_id            := l_try_id;
    i_taiv_rec.khr_id            := p_khr_id;
    i_taiv_rec.date_entered      := SYSDATE;
    i_taiv_rec.date_invoiced     := SYSDATE;
    i_taiv_rec.description       := l_int_desc;
    i_taiv_rec.amount            := l_amount;
    i_taiv_rec.trx_status_code   := 'SUBMITTED';
    -- Populate the currency conversion factors
    i_taiv_rec.currency_code             := l_currency_code;
    i_taiv_rec.currency_conversion_type  := l_currency_conversion_type;
    i_taiv_rec.currency_conversion_rate  := l_currency_conversion_rate;
    i_taiv_rec.currency_conversion_date  := l_currency_conversion_date;

    -- Code needed for billing transaction ends here - HKPATEL

-- Populate the currency conversion factors
-- Code can be commented to create billing transaction - HKPATEL

-- Code can be commented till here - HKPATEL
-- Code needed for billing transaction - HKPATEL
----------------------------------------------------------------------------------
        -- Insert Invoice Header record
----------------------------------------------------------------------------------

  -- Start of wraper code generated automatically by Debug code generator for okl_trx_ar_invoices_pub.insert_trx_ar_invoices
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRITUB.pls call OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices ');
    END;
  END IF;

	okl_trx_ar_invoices_pub.insert_trx_ar_invoices(p_api_version     => l_api_version,
                                                   p_init_msg_list   => l_init_msg_list,
                                                   x_return_status   => l_return_status,
                                                   x_msg_count       => l_msg_count,
                                                   x_msg_data        => l_msg_data,
                                                   p_taiv_rec        => i_taiv_rec,
                                                   x_taiv_rec        => r_taiv_rec);

   IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

----------------------------------------------------------------------------------
       -- Prepare Invoice Line
----------------------------------------------------------------------------------
       i_tilv_rec.line_number            := l_line_number;
       i_tilv_rec.tai_id                 := r_taiv_rec.id;
       i_tilv_rec.description            := l_int_desc;
       i_tilv_rec.amount                 := r_taiv_rec.amount;
       i_tilv_rec.sty_id                 := l_sty_id;
       i_tilv_rec.inv_receiv_line_code   := 'LINE';

  ----------------------------------------------------------------------------------
      -- Insert transaction line record
  ----------------------------------------------------------------------------------

      okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns (p_api_version      => l_api_version,
                                                     p_init_msg_list   => l_init_msg_list,
                                                     x_return_status   => l_return_status,
                                                     x_msg_count       => l_msg_count,
                                                     x_msg_data        => l_msg_data,
                                                     p_tilv_rec        => i_tilv_rec,
                                                     x_tilv_rec        => r_tilv_rec);

      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRITUB.pls call OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices ');
    END;
    END IF;

-- Code needed for billing transaction ends here - HKPATEL

--Code commeneted by HKPATEL for billing
  /*
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRITUB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
  */
-- Commented code ends here - HKPATEL

-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts

    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

         l_khrv_rec_in.ID                             := p_khr_id;
         l_khrv_rec_in.DATE_LAST_INTERIM_INTEREST_CAL := p_calc_date;
         l_chrv_rec_in.ID                             := p_khr_id;

-- Start of wraper code generated automatically by Debug code generator for OKL_CONTRACT_PUB.update_contract_header
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRITUB.pls call OKL_CONTRACT_PUB.update_contract_header ');
    END;
  END IF;
         OKL_CONTRACT_PUB.update_contract_header(p_api_version       => 1.0,
                                                 p_init_msg_list     => l_init_msg_list,
                                                 x_return_status     => l_return_status,
                                                 x_msg_count         => l_msg_count,
                                                 x_msg_data          => l_msg_data,
                                                 p_restricted_update => OKL_API.G_TRUE,
                                                 p_chrv_rec          => l_chrv_rec_in,
                                                 p_khrv_rec          => l_khrv_rec_in,
        					 p_edit_mode         => 'N',
                                                 x_chrv_rec          => l_chrv_rec_out,
                                                 x_khrv_rec          => l_khrv_rec_out);


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRITUB.pls call OKL_CONTRACT_PUB.update_contract_header ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CONTRACT_PUB.update_contract_header

         IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

           -- get scs_code
           FOR x IN scs_code_csr
    	   LOOP
             l_scs_code := x.scs_code;
           END LOOP;
           IF l_scs_code IS NULL THEN
             OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCS_CODE');
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --Bug 4622198.
           OKL_SECURITIZATION_PVT.check_khr_ia_associated(
            p_api_version                  => 1.0
           ,p_init_msg_list                => l_init_msg_list
           ,x_return_status                => l_return_status
           ,x_msg_count                    => l_msg_count
           ,x_msg_data                     => l_msg_data
           ,p_khr_id                       => p_khr_id
           ,p_scs_code                     => l_scs_code
           ,p_trx_date                     => p_calc_date
           ,x_fact_synd_code               => l_fact_sync_code
           ,x_inv_acct_code                => l_inv_acct_code
           );

          -- store the highest degree of error
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

              l_tmpl_identify_rec.product_id           := p_product_id;
              l_tmpl_identify_rec.transaction_type_id  := l_try_id;
              l_tmpl_identify_rec.stream_type_id       := l_sty_id;
              l_tmpl_identify_rec.advance_arrears      := NULL;
              --Bug 4622198.
              l_tmpl_identify_rec.factoring_synd_flag  := l_fact_sync_code;
              l_tmpl_identify_rec.investor_code        := l_inv_acct_code;
              --l_tmpl_identify_rec.factoring_synd_flag  := NULL;
              l_tmpl_identify_rec.syndication_code     := NULL;
              l_tmpl_identify_rec.factoring_code       := NULL;
              l_tmpl_identify_rec.memo_yn              := 'N';
              l_tmpl_identify_rec.prior_year_yn        := 'N';

	      -- Populate the distribution attributes
              --l_dist_info_rec.source_id                := l_tclv_tbl_out(1).ID;

              -- Needed for billing transaction - HKPATEL
	      l_dist_info_rec.source_id                := r_tilv_rec.id;
	      -- Needed code ends here - HKPATEL

              --l_dist_info_rec.source_table             := 'OKL_TXL_CNTRCT_LNS';

              -- Needed for billing transaction - HKPATEL
	      l_dist_info_rec.source_table             := 'OKL_TXL_AR_INV_LNS_B';
	      -- Needed code ends here - HKPATEL

              l_dist_info_rec.accounting_date          := trunc(sysdate);
              l_dist_info_rec.gl_reversal_flag         := 'N';
              --l_dist_info_rec.post_to_gl               := 'Y';

              -- Needed for billing transaction - HKPATEL
	      l_dist_info_rec.post_to_gl               := 'N';
	      -- Needed code ends here - HKPATEL

              l_dist_info_rec.amount                   := l_amount;

	      -- Populate the currency conversion factors
	      l_dist_info_rec.currency_code                := l_currency_code;
      	      l_dist_info_rec.currency_conversion_type     := l_currency_conversion_type;
              l_dist_info_rec.currency_conversion_rate     := l_currency_conversion_rate;
              l_dist_info_rec.currency_conversion_date     := l_currency_conversion_date;


              -- Populate the Account Generator Parameters

              l_org_id := mo_global.get_current_org_id();

              OPEN sales_csr(p_khr_id);
              FETCH sales_csr INTO l_sales_rep;
              CLOSE sales_csr;

              OPEN trx_csr;
              FETCH trx_csr INTO l_trx_type;
              CLOSE trx_csr;

              OPEN billto_csr(p_khr_id);
              FETCH billto_csr INTO l_ar_site_use;
              CLOSE billto_csr;

              l_acc_gen_tbl(1).source_table        := 'FINANCIALS_SYSTEM_PARAMETERS';
              l_acc_gen_tbl(1).primary_key_column  := l_org_id;
              l_acc_gen_tbl(2).source_table        := 'JTF_RS_SALESREPS_MO_V';
              l_acc_gen_tbl(2).primary_key_column  :=  l_sales_rep;
              l_acc_gen_tbl(3).source_table        := 'AR_SITE_USES_V';
              l_acc_gen_tbl(3).primary_key_column  := l_ar_site_use;
              l_acc_gen_tbl(4).source_table        := 'RA_CUST_TRX_TYPES';
              l_acc_gen_tbl(4).primary_key_column  := l_trx_type;


              OKL_ACCOUNT_DIST_PUB.CREATE_ACCOUNTING_DIST
			   (p_api_version              => 1.0,
                            p_init_msg_list            => l_init_msg_list,
                            x_return_status            => l_return_status,
                            x_msg_count                => l_msg_count,
                            x_msg_data                 => l_msg_data,
                            p_tmpl_identify_rec        => l_tmpl_identify_rec,
                            p_dist_info_rec            => l_dist_info_rec,
                            p_ctxt_val_tbl             => l_ctxt_val_tbl,
                            p_acc_gen_primary_key_tbl  => l_acc_gen_tbl,
                            x_template_tbl             => l_avlv_tbl,
                            x_amount_tbl               => l_amount_tbl);




         END IF;

    END IF;

    x_return_status := l_return_status;
    -- Code can be commented for billing transaction - HKPATEL
    --x_source_id     := l_tclv_tbl_out(1).ID;
    -- Commented code should end here - HKPATEL

    -- Code for billing transaction - HKPATEL
    x_source_id     := r_tilv_rec.id;
    -- Code for billing transaction ends here


END CREATE_TRX_ACCT;



PROCEDURE CALC_INTEREST(p_contract_number IN  VARCHAR2,
                        p_start_date      IN  DATE,
                        p_end_date        IN  DATE,
                        p_mode            IN  VARCHAR2,
                        x_amount          OUT NOCOPY NUMBER,
                        x_return_status   OUT NOCOPY VARCHAR2)

IS

-- Cursor to select the interest Name
  CURSOR indx_csr IS
  SELECT distinct idx.NAME
    FROM OKL_K_RATE_PARAMS okl,
         OKL_INDICES idx
    WHERE okl.khr_id = (SELECT id
                           FROM OKC_K_HEADERS_B
                           WHERE contract_number =p_contract_number
                           AND   scs_code = 'LEASE')
      AND okl.parameter_type_code = 'ACTUAL'
      AND okl.effective_to_date IS NULL
      AND okl.interest_index_id = idx.id;

  -- Changed the select statementby Santonyr on 04-Aug-2004 to improve the performance
  -- sjalasut, modified the cursor to refer consolidated invoice id from okl_cnsld_ap_invs_all
  -- added okl_txl_ap_inv_lns_all_b in the from clause as khr_id now moves to the
  -- transaction line level.
  -- changes made as part of OKLR12B disbursements project.
  CURSOR change_csr(v_khr_id          NUMBER,
                    v_start_date      DATE,
                    v_end_date        DATE,
                    v_name            OKL_INDICES.NAME%TYPE) IS
  SELECT ac.check_date change_date
  FROM   OKL_TRX_AP_INVOICES_B oklinv,
         okl_txl_ap_inv_lns_all_b tpl,
         okl_cnsld_ap_invs_all okl_cnsld,
         AP_INVOICES  inv,
         AP_INVOICE_PAYMENTS pay,
      	  AP_CHECKS AC,
         fnd_application fnd_app
  WHERE  oklinv.id = tpl.tap_id
    AND tpl.khr_id = v_khr_id
    AND tpl.cnsld_ap_inv_id = okl_cnsld.cnsld_ap_inv_id
    AND inv.application_id = fnd_app.application_id
    AND fnd_app.application_short_name = 'OKL'
    AND inv.product_table = 'OKL_CNSLD_AP_INVS_ALL'
    AND okl_cnsld.cnsld_ap_inv_id       = to_number(inv.reference_key1)
    AND oklinv.funding_type_code        = 'PREFUNDING'
    AND oklinv.vendor_invoice_number    = inv.invoice_num -- sjalasut, is this required now?
    AND inv.invoice_id                  = pay.invoice_id
    AND pay.check_id 			                = ac.check_id
    AND ac.check_date                  >= v_start_date
    AND ac.check_date                  <= v_end_date
  UNION
  SELECT oiv.datetime_valid change_date
  FROM OKL_INDEX_VALUES oiv,
       OKL_INDICES oi
  WHERE oiv.idx_id    = oi.id
  AND   oi.name       = v_name
  AND   oiv.datetime_valid >= v_start_date
  AND   oiv.datetime_valid <= v_end_date;

-- This Cursor will Return Principal Funding Amount on any Particular Day

-- Changed the select statement by Santonyr on 04-Aug-2004 to improve the performance
  -- sjalasut, modified the below cursor to have included okl_txl_ap_inv_lns_all_b
  -- so that khr_id now refers from this table and also introduced the new
  -- okl consolidation table okl_cnsld_ap_invs_all to join the consolidated invoices
  -- from the transaction lines table.
  CURSOR princ_csr(v_date IN DATE, v_khr_id IN NUMBER) IS
  SELECT SUM(pay.amount)
  FROM   OKL_TRX_AP_INVOICES_B oklinv,
         okl_txl_ap_inv_lns_all_b okl_inv_ln,
         okl_cnsld_ap_invs_all okl_cnsld,
         AP_INVOICES  inv,
       	 AP_INVOICE_PAYMENTS pay,
    	    AP_CHECKS AC,
         fnd_application fnd_app
  WHERE  oklinv.id = okl_inv_ln.tap_id
     AND okl_inv_ln.khr_id = v_khr_id
     AND okl_inv_ln.cnsld_ap_inv_id = okl_cnsld.cnsld_ap_inv_id
     AND inv.application_id = fnd_app.application_id
     AND fnd_app.application_short_name = 'OKL'
     AND inv.product_table = 'OKL_CNSLD_AP_INVS_ALL'
     AND okl_cnsld.cnsld_ap_inv_id     = to_number(inv.reference_key1)
     AND oklinv.funding_type_code  = 'PREFUNDING'
     AND oklinv.vendor_invoice_number     = inv.invoice_num -- sjalasut, is this required now?
     AND inv.invoice_id            = pay.invoice_id
     AND pay.check_id 		   = ac.check_id
     AND ac.check_date 		   <= v_date;


  -- This cursor will return the rate of interest as on a particular Day.
  CURSOR int_max_csr(v_name  VARCHAR2,
           v_interest_date  DATE) IS
  SELECT idv.value
  FROM OKL_INDEX_VALUES idv,
       OKL_INDICES idx
  WHERE idx.ID   = idv.IDX_ID
  AND   idx.NAME = v_name
  AND   idv.datetime_valid = (SELECT MAX(idv.datetime_valid)
                             FROM OKL_INDEX_VALUES idv ,
                                  OKL_INDICES idx
                             WHERE idx.id              =  idv.idx_id
                             AND   idx.name            =  v_name
                             AND   idv.datetime_valid <=  v_interest_date);

-- This cursor will return the Contract ID from the given contract number
  CURSOR cont_csr(v_contract_number VARCHAR2) IS
  SELECT okch.ID
  FROM OKL_K_HEADERS oklh,
       OKC_K_HEADERS_B okch
  WHERE oklh.id                 = okch.id
  AND   okch.contract_number    = v_contract_number
  AND   okch.scs_code           = 'LEASE';

  CURSOR time1_csr IS
  SELECT quantity
  FROM okc_timeunit_v
  WHERE uom_code = 'YR'
  AND tce_code= 'DAY';

  CURSOR num_days_csr(p_date DATE) IS
  SELECT add_months(trunc(p_date,'year'),12) - trunc(p_date,'year')
  FROM dual;

  l_name   OKL_INDICES.name%TYPE;
  l_prev_start_date  DATE;
  l_temp_interest    NUMBER := 0;
  l_total_interest   NUMBER := 0;
  l_principal_amount NUMBER := 0;
  l_interest_rate    NUMBER := 0;
  l_khr_id           NUMBER := 0;
  l_no_of_days_in_year VARCHAR2(450);
  -- gboomina Bug 4900213 - Added - Start
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  -- though l_no_of_days_in_month is not used, need to pass this to OKL_PRICING_UTILS_PVT.get_day_convention method.
  l_no_of_days_in_month VARCHAR2(450);
  -- gboomina Bug 4900213 - Added - End

  FUNCTION DO_CALC(p_principal_amount IN NUMBER,
                   p_start_date       IN DATE,
                   p_end_date         IN DATE,
                   p_rate             IN NUMBER)

  RETURN NUMBER IS
  l_no_of_days  NUMBER := 0;
  l_interest    NUMBER := 0;

  BEGIN

     l_no_of_days :=  trunc(p_end_date) - trunc(p_start_date);

     IF (l_no_of_days_in_year = 'ACTUAL') THEN
       OPEN num_days_csr(p_start_date);
       FETCH num_days_csr INTO l_no_of_days_in_year;
       CLOSE num_days_csr;
     END IF;

     l_interest := (p_principal_amount * p_rate * (l_no_of_days + 1) ) /
                  (to_number(l_no_of_days_in_year) * 100);
     RETURN (l_interest);

  EXCEPTION

      WHEN OTHERS then RETURN 0;

  END DO_CALC;

BEGIN

-- gboomina bug 4900213 - Start
-- moved cont_csr here
    OPEN cont_csr(p_contract_number);
    FETCH cont_csr INTO l_khr_id;
    IF (cont_csr%NOTFOUND) THEN
   -- Abort the process.
       IF (p_mode = 'ONLINE') THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_CNTR_NO_INVALID',
                              p_token1       => 'CONTRACT_NUMBER',
                              p_token1_value => p_contract_number);
       ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract Number ' || p_contract_number ||
                     ' is not Valid');

       END IF;

       CLOSE cont_csr;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE cont_csr;

    -- Find out number of days in Year
    -- Now OKL_PRICING_UTILS_PVT.get_day_convention method is used to get no of days in a year.

    OKL_PRICING_UTILS_PVT.get_day_convention(p_id               => l_khr_id,
                                             p_source           => 'ISG', -- simply passing ISG
                                             x_days_in_month    => l_no_of_days_in_month,
					     x_days_in_year     => l_no_of_days_in_year,
                                             x_return_status    => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_no_of_days_in_year IS NULL THEN
          IF (p_mode = 'ONLINE') THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => 'OKL_DAYS_IN_YEAR_NOT_FOUND');
          ELSE
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : Could not get Number of Days in Year');
          END IF;
          RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- gboomina bug 4900213 - End

-- Find out the interest Name.
    OPEN indx_csr;
    FETCH indx_csr INTO l_name;
    IF (indx_csr%NOTFOUND) THEN
-- Cannot Continue. Must Stop
      IF (p_mode = 'ONLINE') THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_INTR_NAME_NOT_FOUND');
      ELSE
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : Could not get Interest Rate '
             || 'Name in the Rules');

      END IF;
      CLOSE indx_csr;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE indx_csr;

    l_prev_start_date := p_start_date;

    FOR change_rec IN change_csr(l_khr_id,
                                 p_start_date,
                                 p_end_date,
                                 l_name)
    LOOP
        OPEN  int_max_csr(l_name, change_rec.change_date - 1);
        FETCH int_max_csr INTO l_interest_rate;
        IF (int_max_csr%NOTFOUND) THEN
           IF (p_mode = 'ONLINE') THEN
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_INTR_RATE_NOT_FOUND',
                                  p_token1       => 'INTR_DATE',
                                  p_token1_value => to_char(change_rec.change_date - 1,'DD-MM-YY'));
           ELSE
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest Rate is not available for ' ||
                  to_char(change_rec.change_date-1,'DD-MON-YY'));
           END IF;

           CLOSE int_max_csr;
           RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

        CLOSE int_max_csr;
        OPEN princ_csr(change_rec.change_date - 1, l_khr_id);
        FETCH princ_csr INTO l_principal_amount;
        CLOSE princ_csr;

        l_temp_interest   := DO_CALC(l_principal_amount
                                    ,l_prev_start_date
                                    ,(change_rec.change_date - 1)
                                   ,l_interest_rate);
        l_total_interest  := nvl(l_total_interest,0) + nvl(l_temp_interest,0);
        l_prev_start_date := change_rec.change_date;

    END LOOP;

    OPEN int_max_csr(l_name, p_end_date);
    FETCH int_max_csr INTO l_interest_rate;
    IF (int_max_csr%NOTFOUND) THEN
        IF (p_mode = 'ONLINE') THEN
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_INTR_RATE_NOT_FOUND',
                               p_token1       => 'INTR_DATE',
                               p_token1_value => to_char(p_end_date,'DD-MM-YY'));
        ELSE
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest Rate is not available for ' ||
                  to_char(p_end_date,'DD-MON-YY'));
        END IF;

        CLOSE int_max_csr;
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    CLOSE int_max_csr;

    OPEN princ_csr(p_end_date, l_khr_id);
    FETCH princ_csr INTO l_principal_amount;
    CLOSE princ_csr;
    l_temp_interest := DO_CALC(l_principal_amount
                              ,l_prev_start_date
                              ,p_end_date
                              ,l_interest_rate);

    l_total_interest := nvl(l_total_interest,0) + nvl(l_temp_interest,0);

    x_amount         := l_total_interest;
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END CALC_INTEREST;



PROCEDURE CALC_INTEREST_PERD(p_errbuf      OUT NOCOPY VARCHAR2,
                             p_retcode     OUT NOCOPY NUMBER,
                             p_calc_upto   IN VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(40) := 'CALC_INTEREST_PERD';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_overall_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER := 1.0;
  l_row_count         NUMBER;
  l_set_of_books_id   NUMBER := 0;
  l_org_id            NUMBER;
  i                   NUMBER := 0;
  l_amount            NUMBER := 0;
  l_msg_count         NUMBER;
  l_source_id         NUMBER;
  l_count             NUMBER := 0;

  l_start_date           DATE;
  l_end_date             DATE;
  l_period_end_date      DATE;
  l_last_calc_date       DATE;
  l_int_calc_upto        DATE;
  l_contract_start_date  DATE;
  l_period_name          VARCHAR2(10);

  l_tcnv_rec_in       OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  l_tclv_tbl_in       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  l_tcnv_rec_out      OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  l_tclv_tbl_out      OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  l_description       OKL_TRX_CONTRACTS.DESCRIPTION%TYPE;
  l_khrv_tbl_in       OKL_CONTRACT_PUB.KHRV_TBL_TYPE;
  l_khrv_tbl_out      OKL_CONTRACT_PUB.KHRV_TBL_TYPE;


  l_error_msg_rec     OKL_ACCOUNTING_UTIL.Error_message_Type;


-- Cursor for getting all the eligible contracts (which have capitalization flag = 'N') and
-- which are in certain status
-- Bug 4704664. SGIYER. Adding org striping criteria.
  CURSOR cont_head_csr  IS
  SELECT okch.contract_number                contract_number,
         oklh.DATE_LAST_INTERIM_INTEREST_CAL last_calc_date,
         oklh.id                             khr_id,
         oklh.pdt_id                         pdt_id,
         okch.start_date                     start_date
  FROM OKL_K_HEADERS oklh,
       OKC_K_HEADERS_B okch,
       OKC_RULES_B rule
  WHERE okch.sts_code       IN ('ENTERED', 'COMPLETE','PASSED','INCOMPLETE','PENDING_APPROVAL',
            'APPROVED')
  AND   oklh.id             = okch.id
  AND   rule.DNZ_CHR_ID     = oklh.id
  AND   rule.rule_information_category = 'LACPLN'
  AND   rule.rule_information1 = 'N';



-- Cursor for selecting the earliest available funding date if the last calculation
-- date field in the contract header is NULL

-- Changed by Santonyr on 12 Mar 2004
-- Changed the invoice_number to vendor_invoice_number in the where condition
-- Changed the select statement by Santonyr on 04-Aug-2004 to improve the performance
  -- sjalasut, modified the below cursor to have included okl_txl_ap_inv_lns_all_b
  -- so that khr_id now refers from this table and also introduced the new
  -- okl consolidation table okl_cnsld_ap_invs_all to join the consolidated invoices
  -- from the transaction lines table.
  CURSOR fund_csr(v_khr_id NUMBER) IS
  SELECT MIN(ac.check_date)
  FROM   OKL_TRX_AP_INVOICES_B oklinv,
         okl_txl_ap_inv_lns_all_b okl_inv_ln,
         okl_cnsld_ap_invs_all okl_cnsld,
         AP_INVOICES  inv,
       	 AP_INVOICE_PAYMENTS pay,
    	    AP_CHECKS AC,
         fnd_application fnd_app
  WHERE  oklinv.id = okl_inv_ln.tap_id
     AND okl_inv_ln.khr_id = v_khr_id
     AND okl_inv_ln.cnsld_ap_inv_id = okl_cnsld.cnsld_ap_inv_id
     AND inv.application_id = fnd_app.application_id
     AND fnd_app.application_short_name = 'OKL'
     AND inv.product_table = 'OKL_CNSLD_AP_INVS_ALL'
     AND okl_cnsld.cnsld_ap_inv_id     = to_number(inv.reference_key1)
     AND oklinv.funding_type_code  = 'PREFUNDING'
     AND oklinv.vendor_invoice_number     = inv.invoice_num -- sjalasut, is this required now?
     AND oklinv.ipvs_id                   = inv.vendor_site_id
     AND inv.invoice_id                   =  pay.invoice_id
     AND pay.check_id 			  = ac.check_id;

  lv_msg_count NUMBER := 0;
  lv_msg_text VARCHAR2(2000) := NULL;


BEGIN

-- kmotepal bug # 4035770 User entered Interest Calculation Upto date will be taken as end date
-- and will be used for further calculations

    l_int_calc_upto := FND_DATE.CANONICAL_TO_DATE(p_calc_upto);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Given Interest Calculation Upto Date : ' || l_int_calc_upto);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting the Interest Calculation Process');

    OKL_ACCOUNTING_UTIL.get_period_info(p_date => l_int_calc_upto,
               p_period_name => l_period_name,
               p_start_date  => l_start_date,
               p_end_date    => l_period_end_date);

-- We should not take the end date returned from the above call. Hence we are not using
-- the variable l_period_end_date anywhere as Interest Calculation Upto is the correct end date

    IF (l_start_date IS NULL) THEN

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'The Period ' || l_period_name || ' is Invalid');
        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    FOR cont_head_rec IN cont_head_csr

    LOOP

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calculating Interest for Contract Number: ' ||
                    cont_head_rec.contract_number);
       l_last_calc_date := cont_head_rec.last_calc_date;
       l_contract_start_date := cont_head_rec.start_date;
       l_end_date := l_int_calc_upto;

       IF (l_last_calc_date IS NULL) THEN
           OPEN fund_csr(cont_head_rec.khr_id);
           FETCH fund_csr INTO l_last_calc_date;
           CLOSE fund_csr;
       END IF;

       -- If l_last_calc_date is NULL then it means that no funding is available
       -- for the contract

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last calculation Date was ' || l_last_calc_Date);

-- If the Interest Calculation Upto is given as more than the contract start date
-- then Interest should be calculated one day prior to the start date

       IF l_contract_start_date < l_end_date THEN
          l_end_date := l_contract_start_date - 1;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest will be calculated only upto contract start date for this contract : '||
                   cont_head_rec.contract_number);
       END IF;


       IF  (l_last_calc_date IS NOT NULL) AND (l_last_calc_date < l_end_date) THEN

          CALC_INTEREST(p_contract_number => cont_head_rec.contract_number,
                        p_start_date      => l_last_calc_date + 1,
                        p_end_date        => l_end_date,
                        p_mode            => 'BATCH',
                        x_amount          => l_amount,
                        x_return_status   => l_return_status);

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total amount calculated was ' || l_amount);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest Calculation was made upto ' || l_end_date);

          IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

              SAVEPOINT CREATE_TRX_ACCT;

              CREATE_TRX_ACCT(p_khr_id          => cont_head_rec.khr_id,
                              p_product_id      => cont_head_rec.pdt_id,
                              p_amount          => l_amount,
                              p_calc_date       => l_end_date,
                              x_source_id       => l_source_id,
                              x_return_status   => l_return_status);


               IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                   l_count := l_count + 1;
                   COMMIT WORK;
                   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest Successfully Calculated. ' ||
                     'Total Amount was ' || OKL_ACCOUNTING_UTIL.ROUND_AMOUNT(p_amount => l_amount,
                                      p_currency_code => OKL_ACCOUNTING_UTIL.get_func_curr_code));
               ELSE
                  ROLLBACK TO CREATE_TRX_ACCT;
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'There was a problem calculating interest for ' ||
                 'Contract Number ' || cont_head_rec.contract_number);

-- Commented out code to fix bug 3695764

/*
		  Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
                  IF (l_error_msg_rec.COUNT > 0) THEN
                      FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                      LOOP
                         FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
                      END LOOP;
                  END IF;
*/


-- Added by Santonyr on 13-Aug-2004 to fix bug 3695764
-- Get the last message from the message stack and display in the log file.

                Fnd_Msg_Pub.get
                (p_msg_index => Fnd_Msg_Pub.count_msg,
                p_encoded => Fnd_Api.g_false,
		p_data => lv_msg_text,
                p_msg_index_out => lv_msg_count);

             	Fnd_File.PUT_LINE(Fnd_File.LOG, lv_msg_text);

               END IF;

          ELSE

               FND_FILE.PUT_LINE(FND_FILE.LOG, 'There was a problem calculating interest for ' ||
                 ' Contract Number ' || cont_head_rec.contract_number);
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'In the else part ' || l_return_status);

          END IF;

       ELSE

           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Funding not Available');

       END IF;

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '                      ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '                      ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest was successfully calculated for ' ||
                                       l_count || ' contracts');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '***Successful End of Interest Calculation Process***');

EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest Calculation Process Aborted');
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
      END IF;

    WHEN OTHERS THEN

       p_errbuf := SQLERRM;
       p_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interest Calculation Process Aborted');
       Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
       IF (l_error_msg_rec.COUNT > 0) THEN
           FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
           LOOP
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
           END LOOP;
       END IF;

END CALC_INTEREST_PERD;




PROCEDURE CALC_INTEREST_ACTIVATE(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 p_contract_number  IN  VARCHAR2,
                                 p_activation_date  IN  DATE,
                                 x_amount           OUT NOCOPY NUMBER,
                                 x_source_id        OUT NOCOPY NUMBER)

IS

  l_api_name          CONSTANT VARCHAR2(40) := 'CALC_INTEREST_ACTIVATE';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_captl_flag        VARCHAR2(1);
  l_init_msg_list     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);

  l_api_version       CONSTANT NUMBER       := 1.0;
  l_khr_id            NUMBER;
  l_amount            NUMBER;
  l_row_count         NUMBER;
  l_msg_count         NUMBER;
  l_product_id        NUMBER;
  l_source_id         NUMBER;
  l_total_oec         NUMBER := 0;
  i                   NUMBER := 0;

  l_last_calc_date    DATE;

  l_description       OKL_TRX_CONTRACTS.DESCRIPTION%TYPE;
  l_khrv_rec_in       OKL_CONTRACT_PUB.khrv_rec_type;
  l_khrv_rec_out      OKL_CONTRACT_PUB.khrv_rec_type;
  l_chrv_rec_in       okl_okc_migration_pvt.chrv_rec_type;
  l_chrv_rec_out      okl_okc_migration_pvt.chrv_rec_type;

  l_klev_tbl_in       OKL_CONTRACT_PUB.klev_tbl_type;
  l_klev_tbl_out      OKL_CONTRACT_PUB.klev_tbl_type;

  l_clev_tbl_in       OKL_OKC_MIGRATION_PVT.clev_tbl_type;
  l_clev_tbl_out      OKL_OKC_MIGRATION_PVT.clev_tbl_type;

  l_tcnv_rec_in       OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  l_tclv_tbl_in       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  l_tcnv_rec_out      OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  l_tclv_tbl_out      OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;

-- Cursor for getting the last calculation date

  CURSOR cont_head_csr  IS
  SELECT oklh.DATE_LAST_INTERIM_INTEREST_CAL,
         oklh.PDT_ID,
         oklh.ID
  FROM OKL_K_HEADERS oklh,
       OKC_K_HEADERS_B okch
  WHERE oklh.id                  = okch.id
  AND   okch.contract_number     = p_contract_number
  AND   okch.scs_code            = 'LEASE';


-- Cursor for getting the earliest funding date

-- Changed the select statement by Santonyr on 04-Aug-2004 to improve the performance

  CURSOR fund_csr(v_khr_id NUMBER) IS
  SELECT MIN(ac.check_date)
  FROM   OKL_TRX_AP_INVOICES_B oklinv,
         okl_txl_ap_inv_lns_all_b okl_inv_ln,
         okl_cnsld_ap_invs_all okl_cnsld,
         AP_INVOICES  inv,
       	 AP_INVOICE_PAYMENTS pay,
    	    AP_CHECKS AC,
         fnd_application fnd_app
  WHERE  oklinv.id = okl_inv_ln.tap_id
     AND okl_inv_ln.khr_id = v_khr_id
     AND okl_inv_ln.cnsld_ap_inv_id = okl_cnsld.cnsld_ap_inv_id
     AND inv.application_id = fnd_app.application_id
     AND fnd_app.application_short_name = 'OKL'
     AND inv.product_table = 'OKL_CNSLD_AP_INVS_ALL'
     AND okl_cnsld.cnsld_ap_inv_id     = to_number(inv.reference_key1)
     AND oklinv.funding_type_code  = 'PREFUNDING'
     AND oklinv.vendor_invoice_number     = inv.invoice_num -- sjalasut, is this required now?
     AND oklinv.ipvs_id                   = inv.vendor_site_id
     AND inv.invoice_id                   =  pay.invoice_id
     AND pay.check_id 			  = ac.check_id;


-- Cursor for getting the capitalization flag information
  CURSOR captl_csr(v_khr_id NUMBER)  IS
  SELECT rule_information1
  FROM OKC_RULES_B
  WHERE DNZ_CHR_ID = v_khr_id
  AND   rule_information_category = 'LACPLN';

-- Cursor for getting OEC and then updating the CAPITALIZED_INTEREST field

  CURSOR oec_csr(v_contract_number VARCHAR2) IS
  SELECT kln.ID  ID,
         kln.OEC OEC,
         --Added by kthiruva on 20-Feb-2006 for Bug 4899328
         kln.CAPITAL_AMOUNT CAPITAL_AMOUNT,
         kln.CAPITALIZED_INTEREST CAPITALIZED_INTEREST
  FROM okl_k_lines kln,
       okc_k_lines_b cln,
       okc_k_headers_b chr,
       okc_line_styles_b cls
  WHERE chr.contract_number = v_contract_number AND
        chr.scs_code = 'LEASE' AND
        chr.ID = cln.chr_id AND
	kln.ID = cln.ID AND
	cln.lse_id = cls.ID AND
	cls.lty_code = 'FREE_FORM1' AND
        cln.STS_CODE <> 'ABANDONED';

 --Added by kthiruva on 20-Feb-2006
 --Bug 4899328 - Start of Changes
   l_old_capitalized_interest NUMBER;
 --Bug 4899328 - End of Changes

BEGIN

  l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


-- First Get the last calculation Date

  OPEN cont_head_csr;
  FETCH cont_head_csr INTO l_last_calc_date,
                           l_product_id,
                           l_khr_id;
  IF  (cont_head_csr%NOTFOUND) THEN
    OKL_API.set_message('OKC', G_INVALID_VALUE, G_COL_NAME_TOKEN,'CONTRACT_NUMBER');
    CLOSE cont_head_csr;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  CLOSE cont_head_csr;


-- IF last calculation date is null then it means that interest has never been calculated.
-- So we should take the  earliest funding date and start calculating the interest
-- from that date.

  IF (l_last_calc_date IS NULL) THEN
      OPEN fund_csr(l_khr_id);
      FETCH fund_csr INTO l_last_calc_date;
      CLOSE fund_csr;
  END IF;

-- IF even the funding table does not have any record then it means that interest should be Zero.
-- Call the CALC_INTEREST only if the last calculation date is NOT NULL

  IF (l_last_calc_date IS NOT NULL) AND (l_last_calc_date < p_activation_date) THEN

       CALC_INTEREST(p_contract_number => p_contract_number,
                     p_start_date      => l_last_calc_date,
                     p_end_date        => p_activation_date - 1,
                     p_mode            => 'ONLINE',
                     x_amount          => l_amount,
                     x_return_status   => l_return_status);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status  = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
  ELSE
       l_amount := 0;

  END IF;

-- If capitalization flag is Set for the contract then just return the Amount
-- If capitalization flag is not set then we have to create a transaction record

  OPEN captl_csr(l_khr_id);
  FETCH captl_csr INTO l_captl_flag;
  IF (captl_csr%NOTFOUND) THEN
  /*
      Changed by HKPATEL for bug 3589126
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_CAPTL_INFO_NOT_FOUND',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => p_contract_number);
  */
      l_captl_flag := 'N';
      --CLOSE captl_csr;

      --RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  CLOSE captl_csr;

  IF (l_captl_flag = 'N') THEN

       IF (l_amount > 0) THEN

           CREATE_TRX_ACCT(p_khr_id          => l_khr_id,
                           p_product_id      => l_product_id,
                           p_amount          => l_amount,
                           p_calc_date       => p_activation_date,
                           x_source_id       => l_source_id,
                           x_return_status   => l_return_status);

       END IF;


  ELSE

    i := 0;

    FOR oec_rec IN oec_csr(p_contract_number)
    LOOP
        i := i + 1;
        l_clev_tbl_in(i).ID  := oec_rec.ID;
        l_klev_tbl_in(i).ID  := oec_rec.ID;
        l_klev_tbl_in(i).OEC := oec_rec.OEC;
        l_total_oec      := l_total_oec + NVL(oec_rec.OEC,0);
        --Added by kthiruva on 20-Feb-2006
        --Bug 4899328 - Start of Changes
        l_klev_tbl_in(i).CAPITALIZED_INTEREST := oec_rec.CAPITALIZED_INTEREST;
        l_klev_tbl_in(i).CAPITAL_AMOUNT       := oec_rec.CAPITAL_AMOUNT;
        --Bug 4899328 - End of Changes

    END LOOP;

    FOR i IN 1..l_klev_tbl_in.COUNT
    LOOP
       --Modified by kthiruva on 20-Feb-2006
       --Bug 4899328 - Start of Changes
       l_old_capitalized_interest            :=  nvl(l_klev_tbl_in(i).CAPITALIZED_INTEREST,0);
       l_klev_tbl_in(i).CAPITALIZED_INTEREST :=  (l_klev_tbl_in(i).OEC / l_total_oec) * l_amount;
       l_klev_tbl_in(i).CAPITAL_AMOUNT       := l_klev_tbl_in(i).CAPITAL_AMOUNT - l_old_capitalized_interest + l_klev_tbl_in(i).CAPITALIZED_INTEREST;
       --Bug 4899328 - End of Changes
    END LOOP;

    OKL_CONTRACT_PUB.update_contract_line
               (p_api_version      =>  p_api_version,
                p_init_msg_list    =>  p_init_msg_list,
                x_return_status    =>  l_return_status,
                x_msg_count        =>  x_msg_count,
                x_msg_data         =>  x_msg_data,
                p_clev_tbl         =>  l_clev_tbl_in,
                p_klev_tbl         =>  l_klev_tbl_in,
                p_edit_mode        =>  'N',
                x_clev_tbl         =>  l_clev_tbl_out,
                x_klev_tbl         =>  l_klev_tbl_out);

  END IF;

  x_amount        := l_amount;
  x_source_id     := l_source_id;
  x_return_status := l_return_status;

  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END CALC_INTEREST_ACTIVATE;



FUNCTION SUBMIT_CALCULATE_INTEREST(p_api_version      IN NUMBER,
                                   p_init_msg_list    IN VARCHAR2,
                                   x_return_status    OUT NOCOPY VARCHAR2,
                                   x_msg_count        OUT NOCOPY NUMBER,
                                   x_msg_data         OUT NOCOPY VARCHAR2,
                                   p_period_name      IN VARCHAR2 )

RETURN NUMBER IS

    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'SUBMIT_CALCULATE_INTEREST';
    l_return_status        VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_init_msg_list        VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    x_request_id           NUMBER;

BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- check for period name before submitting the request.
    IF (p_period_name IS NULL) OR (p_period_name = Okl_Api.G_MISS_CHAR) THEN
       OKL_API.set_message('OKC', G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Period Name');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   -- Submit Concurrent Program Request for interest calculation

    x_request_id := FND_REQUEST.SUBMIT_REQUEST
         (application    => 'OKL',
          program        => 'OKLINTCALC',
          description    => 'Interest Calculation',
          argument1      =>  p_period_name);

    IF (x_request_id = 0) THEN

       OKL_API.set_message(p_app_name     => 'OFA',
                           p_msg_name     => 'FA_DEPRN_TAX_ERROR',
                           p_token1       => 'REQUEST_ID',
                           p_token1_value => x_request_id);
       RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    RETURN x_request_id;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      RETURN x_request_id;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      RETURN x_request_id;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      RETURN x_request_id;

END SUBMIT_CALCULATE_INTEREST;


END OKL_INTEREST_CALC_PVT;

/
