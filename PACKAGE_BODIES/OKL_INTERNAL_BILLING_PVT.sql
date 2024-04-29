--------------------------------------------------------
--  DDL for Package Body OKL_INTERNAL_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTERNAL_BILLING_PVT" AS
/* $Header: OKLRIARB.pls 120.24.12010000.4 2009/11/06 08:37:58 nikshah ship $ */
 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 subtype taiv_rec_type is okl_tai_pvt.taiv_rec_type;
 subtype taiv_tbl_type is okl_tai_pvt.taiv_tbl_type;
 subtype tilv_rec_type is okl_til_pvt.tilv_rec_type;
 subtype tilv_tbl_type is okl_til_pvt.tilv_tbl_type;
 subtype tldv_rec_type is okl_tld_pvt.tldv_rec_type;
 subtype tldv_tbl_type is okl_tld_pvt.tldv_tbl_type;

 ----------------------------------------------------------------------------
 -- Variables For Debugging and Logging
 ----------------------------------------------------------------------------
  G_MODULE                 VARCHAR2(40) := 'LEASE.RECEIVABLES';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_LEVEL_PROCEDURE        NUMBER;
  G_IS_DEBUG_PROCEDURE_ON  BOOLEAN;
  G_IS_DEBUG_STATEMENT_ON  BOOLEAN;
  G_IS_STREAM_BASED_BILLING  BOOLEAN := NULL;

 --gkhuntet added start.
 G_SUBMITTED CONSTANT VARCHAR2(30) := 'SUBMITTED';
 G_MANUAL   CONSTANT VARCHAR2(30) := 'MANUAL_INVOICE';
--gkhuntet added end.

----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------


----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_accounting_dist
-- Description     : abstract api to make Accounting transactions
-- Parameters      :
--                 p_tldv_tbl: Internal billing invoice/invoce line (OKL_TXD_AR_LN_DTLS_V)
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE create_accounting_dist(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
   ,p_tai_id                       IN  OKL_TRX_AR_INVOICES_B.ID%TYPE
)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'create_accounting_dist';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_til_loop_cnt                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type := p_tldv_tbl;
  lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  l_tld_loop_cnt     NUMBER;
  lx_tldv_rec        okl_tld_pvt.tldv_rec_type;
  l_til_id           NUMBER;
  l_trx_header_id    OKL_TRX_AR_INVOICES_B.ID%TYPE;
  l_til_debug_cnt    NUMBER;
  l_tld_debug_cnt    NUMBER;
  p_bpd_acc_rec      Okl_Acc_Call_Pub.bpd_acc_rec_type;


    l_tmpl_identify_rec    	    Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
    l_dist_info_rec        		Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE;
  	l_ctxt_val_tbl         		Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
  	l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY;

    l_tmpl_identify_tbl         Okl_Account_Dist_Pvt.TMPL_IDENTIFY_TBL_TYPE;
    l_dist_info_tbl             Okl_Account_Dist_Pvt.DIST_INFO_TBL_TYPE;
    l_ctxt_tbl                  Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl               Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
   	l_template_out_tbl		    Okl_Account_Dist_Pvt.avlv_out_tbl_type;
	l_amount_out_tbl		    Okl_Account_Dist_Pvt.amount_out_tbl_type;
	l_tcn_id                    NUMBER;
	l_trx_header_tbl            Varchar2(50);

BEGIN
    SAVEPOINT CREATE_ACCOUNTING_DIST;
    l_tld_loop_cnt := 0;
    -- 6. Process accounting distributions;
    l_tld_loop_cnt := lp_tldv_tbl.first;

loop
--FOR l_tld_loop_cnt  in  1 .. lp_tldv_tbl.count loop
  p_bpd_acc_rec.id           := lp_tldv_tbl(l_tld_loop_cnt).id;
  p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';



  /* apaul -- Code commented out because new accing API uptake not complete
  Okl_Acc_Call_Pub.CREATE_ACC_TRANS(p_api_version    =>  p_api_version,
                                    p_init_msg_list  =>  p_init_msg_list,
                                    x_return_status  =>  l_return_status,
                                    x_msg_count      =>  x_msg_count,
                                    x_msg_data       =>  x_msg_data,
                                    p_bpd_acc_rec    =>  p_bpd_acc_rec);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Acc_Call_Pub.CREATE_ACC_TRANS:p_bpd_acc_rec.id: '||to_char(p_bpd_acc_rec.id));
    END IF;
    */

    ---- Added by Vpanwar --- Code for new accounting API uptake

    Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW(p_api_version                 =>  p_api_version,
                                            p_init_msg_list             =>  p_init_msg_list,
                                            x_return_status             =>  l_return_status,
                                            x_msg_count                 =>  x_msg_count,
                                            x_msg_data                  =>  x_msg_data,
                                            p_bpd_acc_rec               =>  p_bpd_acc_rec,
                                            x_tmpl_identify_rec         =>  l_tmpl_identify_rec,
                                            x_dist_info_rec             =>  l_dist_info_rec,
                                            x_ctxt_val_tbl              =>  l_ctxt_val_tbl,
                                            x_acc_gen_primary_key_tbl   =>  l_acc_gen_primary_key_tbl);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    --debug_proc('Vipp 333...p_bpd_acc_rec.id '||p_bpd_acc_rec.id );
     --- populate the tables for passing to Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST

      l_acc_gen_tbl(l_tld_loop_cnt).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
      l_acc_gen_tbl(l_tld_loop_cnt).source_id       := l_dist_info_rec.source_id;

      l_ctxt_tbl(l_tld_loop_cnt).ctxt_val_tbl       := l_ctxt_val_tbl;
      l_ctxt_tbl(l_tld_loop_cnt).source_id          := l_dist_info_rec.source_id;

      l_tmpl_identify_tbl(l_tld_loop_cnt)           := l_tmpl_identify_rec;

      l_dist_info_tbl(l_tld_loop_cnt)               := l_dist_info_rec;

    ---- End Added by Vpanwar --- Code for new accounting API uptake

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW:p_bpd_acc_rec.id: '||to_char(p_bpd_acc_rec.id));
    END IF;

  EXIT WHEN l_tld_loop_cnt = lp_tldv_tbl.LAST;
  l_tld_loop_cnt := lp_tldv_tbl.NEXT(l_tld_loop_cnt);
end loop;

 ---- Added by Vpanwar --- Code for new accounting API uptake
    l_trx_header_tbl:= 'OKL_TRX_AR_INVOICES_B';
    l_trx_header_id := p_tai_id;
    --Call accounting with new signature

        Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				                  p_trx_header_id      => l_trx_header_id,
                                  p_trx_header_table   => l_trx_header_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --debug_proc('Vipp 333...l_trx_header_id '||l_trx_header_id );
    ---- End Added by Vpanwar --- Code for new accounting API uptake
           /*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_ACCOUNTING_DIST;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_ACCOUNTING_DIST;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_ACCOUNTING_DIST;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END create_accounting_dist;




----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : additional_tai_attr
-- Description     : Internal procedure to add additional columns for
--                   okl_trx_ar_invoices_b
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE additional_tai_attr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN taiv_rec_type
   ,x_taiv_rec                     OUT NOCOPY taiv_rec_type
   ,p_rle_code                     IN VARCHAR2 DEFAULT NULL
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'additional_tai_attr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_rgd_code         okc_rule_groups_b.rgd_code%TYPE DEFAULT NULL;

--START: cklee 3/20/07
	l_legal_entity_id       okl_trx_ar_invoices_b.legal_entity_id%TYPE; -- for LE Uptake project 08-11-2006

        l_jtot_object1_code okc_rules_b.jtot_object1_code%TYPE;
        l_jtot_object2_code okc_rules_b.jtot_object2_code%TYPE;
        l_object1_id1 okc_rules_b.object1_id1%TYPE;
        l_object1_id2 okc_rules_b.object1_id2%TYPE;

        CURSOR rule_code_csr(p_khr_id NUMBER,   p_rule_category VARCHAR2, p_rgd_code VARCHAR2) IS
        SELECT jtot_object1_code,
               object1_id1,
               object1_id2
        FROM okc_rules_b
        WHERE rgp_id =
        (SELECT id
        FROM okc_rule_groups_b
        WHERE dnz_chr_id = p_khr_id
        AND cle_id IS NULL
        AND rgd_code = p_rgd_code)
        AND rule_information_category = p_rule_category;

        l_cust_bank_acct okx_rcpt_method_accounts_v.bank_account_id%TYPE;

        CURSOR cust_trx_type_csr(p_sob_id NUMBER,   p_org_id NUMBER) IS
        SELECT id1
        FROM okx_cust_trx_types_v
        WHERE name = 'Invoice-OKL'
        AND set_of_books_id = p_sob_id
        AND org_id = p_org_id;

        CURSOR cm_trx_type_csr(p_sob_id NUMBER,   p_org_id NUMBER) IS
        SELECT id1
        FROM okx_cust_trx_types_v
        WHERE name = 'Credit Memo-OKL'
        AND set_of_books_id = p_sob_id
        AND org_id = p_org_id;

        CURSOR org_id_csr(p_khr_id NUMBER) IS
        SELECT authoring_org_id
        FROM okc_k_headers_b
        WHERE id = p_khr_id;

	  --gkhuntet added for Manual Invoices 06-07-2007 start
        --Cursor to get TRY_ID for the BILLING.
        CURSOR in_okx_trx_type_csr IS
        SELECT ID
        FROM OKL_TRX_TYPES_V
        WHERE AEP_CODE = 'BILLING';

         --Cursor to get TRY_ID for the CREDIT_MEMO.
        CURSOR cm_okx_trx_type_csr IS
        SELECT ID
        FROM OKL_TRX_TYPES_V
        WHERE AEP_CODE = 'CREDIT_MEMO';
       --gkhuntet added for Manual Invoices 06-07-2007 end

       --added for rules migration
       CURSOR cur_address_billto(p_contract_id IN VARCHAR2) IS
       SELECT a.cust_acct_id cust_account_id,
              b.cust_acct_site_id,
              c.standard_terms payment_term_id
       FROM okc_k_headers_v a,
            okx_cust_site_uses_v b,
            hz_customer_profiles c
       WHERE a.id = p_contract_id
       AND a.bill_to_site_use_id = b.id1
       AND a.bill_to_site_use_id = c.site_use_id(+);

       billto_rec cur_address_billto % ROWTYPE;

       CURSOR rcpt_mthd_csr(p_cust_rct_mthd NUMBER) IS
       SELECT c.receipt_method_id
       FROM ra_cust_receipt_methods c
       WHERE c.cust_receipt_method_id = p_cust_rct_mthd;

       -- For bank accounts
       CURSOR bank_acct_csr(p_id NUMBER) IS
       SELECT bank_account_id
       FROM okx_rcpt_method_accounts_v
       WHERE id1 = p_id;

       -- Default term Id
       cursor std_terms_csr IS
       SELECT B.TERM_ID
       FROM RA_TERMS_TL T, RA_TERMS_B B
       where T.name = 'IMMEDIATE' and T.LANGUAGE = userenv('LANG')
       and B.TERM_ID = T.TERM_ID;

       l_term_id okl_trx_ar_invoices_b.irt_id%type; -- cklee 3/20/07

  CURSOR rcpt_method_csr(p_rct_method_id NUMBER) IS
  SELECT c.creation_method_code
  FROM ar_receipt_methods m,
    ar_receipt_classes c
  WHERE m.receipt_class_id = c.receipt_class_id
   AND m.receipt_method_id = p_rct_method_id;

  l_rct_method_code ar_receipt_classes.creation_method_code%TYPE;

  --Start code added by pgomes on 20-NOV-2002
  SUBTYPE khr_id_type IS okl_k_headers_v.khr_id%TYPE;
  l_khr_id khr_id_type;
  l_currency_code okl_trx_ar_invoices_b.currency_code%TYPE;
  l_currency_conversion_type okl_trx_ar_invoices_b.currency_conversion_type%TYPE;
  l_currency_conversion_rate okl_trx_ar_invoices_b.currency_conversion_rate%TYPE;
  l_currency_conversion_date okl_trx_ar_invoices_b.currency_conversion_date%TYPE;

  --Get currency conversion attributes for a contract
  CURSOR l_curr_conv_csr(cp_khr_id IN khr_id_type) IS
  SELECT currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date
  FROM okl_k_headers_full_v
  WHERE id = cp_khr_id;

  --End code added by pgomes on 20-NOV-2002

  -- -------------------------------------------
  -- To support new fields in XSI and XLS
  -- Added on 21-MAR-2005
  -- -------------------------------------------
  -- rseela BUG# 4733028 Start: fetching review invoice flag
  CURSOR inv_frmt_csr(cp_khr_id IN NUMBER) IS
  SELECT to_number(rul.rule_information1), --inf.id, --sechawla 26-may-09 6826580
    rul.rule_information4 review_invoice_yn
  FROM okc_rule_groups_v rgp,
    okc_rules_v rul
  --,  okl_invoice_formats_v inf --sechawla 26-may-09 6826580
  WHERE rgp.dnz_chr_id = cp_khr_id
   AND rgp.chr_id = rgp.dnz_chr_id
   AND rgp.id = rul.rgp_id
   AND rgp.cle_id IS NULL
   AND rgp.rgd_code = 'LABILL'
   AND rul.rule_information_category = 'LAINVD';
  -- AND rul.rule_information1 = inf.name; --sechawla 26-may-09 6826580

  l_inf_id okl_invoice_formats_v.id%TYPE;

  -- -------------------------------------------
  -- To support private label transfers to
  -- AR. Bug 4525643
  -- -------------------------------------------
  CURSOR pvt_label_csr(cp_khr_id IN NUMBER) IS
  SELECT rule_information1 private_label
  FROM okc_rule_groups_b a,
       okc_rules_b b
  WHERE a.dnz_chr_id = cp_khr_id
   AND a.rgd_code = 'LALABL'
   AND a.id = b.rgp_id
   AND b.rule_information_category = 'LALOGO';

  l_private_label okc_rules_b.rule_information1%TYPE;

--END:  cklee 3/20/07

begin
  -- Set API savepoint
  SAVEPOINT additional_tai_attr;
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_taiv_rec.id :'||p_taiv_rec.id);
    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
  -- assign all passed in attributes from IN to OUT record
  x_taiv_rec := p_taiv_rec;

  IF p_rle_code = 'OKL_VENDOR' THEN
    l_rgd_code := 'LAVENB';
  ELSE
    l_rgd_code := 'LABILL';
  END IF;

      l_khr_id := p_taiv_rec.khr_id;
      IF l_khr_id IS NOT NULL THEN
        -- Changed if condition for bug 4155476
        --added by pgomes 11/20/2002 (multi-currency er)

        --Start code added by pgomes on 11/21/2002
        l_currency_code := NULL;
        l_currency_conversion_type := NULL;
        l_currency_conversion_rate := NULL;
        l_currency_conversion_date := NULL;

        FOR cur IN l_curr_conv_csr(l_khr_id)
        LOOP
          l_currency_code := cur.currency_code;
          l_currency_conversion_type := cur.currency_conversion_type;
          l_currency_conversion_rate := cur.currency_conversion_rate;
          l_currency_conversion_date := cur.currency_conversion_date;
        END LOOP;

        --End code added by pgomes on 11/21/2002

        -- Start; Bug 4525643; stmathew
        -- Private Label
        l_private_label := NULL;

        OPEN pvt_label_csr(l_khr_id);
        FETCH pvt_label_csr
        INTO l_private_label;
        CLOSE pvt_label_csr;
        x_taiv_rec.private_label := l_private_label;
        -- End; Bug 4525643; stmathew

        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_object1_id2 := NULL;
        l_jtot_object2_code := NULL;

        -- for LE Uptake project 08-11-2006
        IF (p_taiv_rec.legal_entity_id IS NULL OR (p_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM))  THEN
          l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_khr_id);
        ELSE
          l_legal_entity_id  := p_taiv_rec.legal_entity_id;
        END IF;
        x_taiv_rec.legal_entity_id := l_legal_entity_id;

--      IF l_khr_id IS NOT NULL THEN
--        -- Changed if condition for bug 4155476

        IF(p_taiv_rec.irm_id IS NULL) THEN
          --AND ln_dtls_rec.IXX_ID IS NULL )THEN

          OPEN rule_code_csr(l_khr_id,   'LAPMTH', l_rgd_code);
          FETCH rule_code_csr
          INTO l_jtot_object1_code,
            l_object1_id1,
            l_object1_id2;
          CLOSE rule_code_csr;

          IF l_object1_id2 <> '#' THEN
            x_taiv_rec.irm_id := l_object1_id2;
          ELSE
            -- This cursor needs to be removed when the view changes to
            -- include id2

            OPEN rcpt_mthd_csr(l_object1_id1);
            FETCH rcpt_mthd_csr
            INTO x_taiv_rec.irm_id;
            CLOSE rcpt_mthd_csr;
          END IF;

        ELSE
          x_taiv_rec.irm_id := p_taiv_rec.irm_id;
        END IF;

        -- Null out local variables
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_jtot_object2_code := NULL;

        billto_rec.cust_account_id := NULL;
        billto_rec.cust_acct_site_id := NULL;
        billto_rec.payment_term_id := NULL;

        OPEN cur_address_billto(l_khr_id);
        FETCH cur_address_billto
        INTO billto_rec;
        CLOSE cur_address_billto;

-- rmunjulu R12 Fixes -- commented
       -- x_taiv_rec.ixx_id := NVL(p_taiv_rec.ixx_id,   billto_rec.cust_account_id);
       -- x_taiv_rec.ibt_id := NVL(p_taiv_rec.ibt_id,   billto_rec.cust_acct_site_id);

-- rmunjulu R12 Fixes -- changed to check for g_miss
        IF (p_taiv_rec.ixx_id IS NULL OR (p_taiv_rec.ixx_id = Okl_Api.G_MISS_NUM))  THEN
          x_taiv_rec.ixx_id := billto_rec.cust_account_id;
        ELSE
          x_taiv_rec.ixx_id := p_taiv_rec.ixx_id;
        END IF;

        IF (p_taiv_rec.ibt_id IS NULL OR (p_taiv_rec.ibt_id = Okl_Api.G_MISS_NUM))  THEN
          x_taiv_rec.ibt_id := billto_rec.cust_acct_site_id;
        ELSE
          x_taiv_rec.ibt_id := p_taiv_rec.ibt_id;
        END IF;

        OPEN std_terms_csr;
        FETCH std_terms_csr
        INTO l_term_id;
        CLOSE std_terms_csr;

        -- cklee: set when irt_id is null
        --x_taiv_rec.irt_id := NVL(p_taiv_rec.irt_id,   l_term_id); -- 6140771
        if p_taiv_rec.irt_id is null or p_taiv_rec.irt_id = okl_api.g_miss_num
        then
          x_taiv_rec.irt_id := l_term_id;
        else
          x_taiv_rec.irt_id := p_taiv_rec.irt_id;
        end if;

        IF (p_taiv_rec.org_id IS NULL OR p_taiv_rec.org_id=OKL_API.G_MISS_NUM) THEN

          OPEN org_id_csr(l_khr_id);
          FETCH org_id_csr
          INTO x_taiv_rec.org_id;
          CLOSE org_id_csr;
        ELSE
          x_taiv_rec.org_id := p_taiv_rec.org_id;
          --TAI
        END IF;

        -- To resolve the bank account for the customer
        -- If receipt method is manual do not supply customer bank account
        -- Id. This is required for Auto Invoice Validation

        -- Null out variable
        l_rct_method_code := NULL;

        OPEN rcpt_method_csr(x_taiv_rec.irm_id);
        FETCH rcpt_method_csr
        INTO l_rct_method_code;
        CLOSE rcpt_method_csr;

        --Null out variables
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_object1_id2 := NULL;
        l_cust_bank_acct := NULL;

        IF(l_rct_method_code <> 'MANUAL') THEN

          OPEN rule_code_csr(l_khr_id,   'LABACC', l_rgd_code);
          FETCH rule_code_csr
          INTO l_jtot_object1_code,
            l_object1_id1,
            l_object1_id2;
          CLOSE rule_code_csr;

          OPEN bank_acct_csr(l_object1_id1);
          FETCH bank_acct_csr
          INTO l_cust_bank_acct;
          CLOSE bank_acct_csr;

          x_taiv_rec.customer_bank_account_id := l_cust_bank_acct;
        END IF;

        -- New fields added on 21-MAR-2005
        l_inf_id := NULL;
        -- rseela BUG# 4733028 Start: populating review invoice flag

        OPEN inv_frmt_csr(l_khr_id);
        FETCH inv_frmt_csr
        INTO x_taiv_rec.inf_id,
             x_taiv_rec.invoice_pull_yn;
        CLOSE inv_frmt_csr;

        --pgomes 11/22/2002 changed below line to output l_cust_bank_acct instead of l_xsiv_rec.customer_bank_account_id
/*** Move the following valiadtion rules to validate_tai_values
      ELSE
        -- Else for contract_id

        IF p_ie_tbl1(k).ixx_id IS NULL THEN
          --d*bms_output.put_line ('IXX_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IXX_ID must be populated WHEN the contract header IS NULL!');
        ELSE
          xsi_tbl(l_xsi_cnt).customer_id := p_ie_tbl1(k).ixx_id;
        END IF;

        IF p_ie_tbl1(k).irm_id IS NULL THEN
          -- d*bms_output.put_line ('IRM_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IRM_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).receipt_method_id := p_ie_tbl1(k).irm_id;
        END IF;

        IF p_ie_tbl1(k).irt_id IS NULL THEN
          -- d*bms_output.put_line ('IRT_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IRT_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).term_id := p_ie_tbl1(k).irt_id;
        END IF;

        IF p_ie_tbl1(k).ibt_id IS NULL THEN
          --d*bms_output.put_line ('IBT_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IBT_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).customer_address_id := p_ie_tbl1(k).ibt_id;
        END IF;

        IF p_ie_tbl1(k).org_id IS NULL THEN
          --d*bms_output.put_line ('ORG_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'ORG_ID must be populated WHEN the contract header IS NULL');
        ELSE
          --l_xsiv_rec.ORG_ID     := ln_dtls_rec.ORG_ID; --TAI
          xsi_tbl(l_xsi_cnt).org_id := NULL;
        END IF;
        -- for LE Uptake project 08-11-2006
        IF ( p_ie_tbl1(k).legal_entity_id IS NULL OR (p_ie_tbl1(k).legal_entity_id = Okl_Api.G_MISS_NUM))  THEN
          --d*bms_output.put_line ('LEGAL_ENTITY_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'LEGAL_ENTITY_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).legal_entity_id := p_ie_tbl1(k).legal_entity_id;
        END IF;
        -- for LE Uptake project 08-11-2006
***/
      END IF; -- IF l_khr_id IS NOT NULL THEN

      --How to get the set_of_books_id ?

      IF (p_taiv_rec.set_of_books_id IS NULL OR p_taiv_rec.set_of_books_id = OKL_API.G_MISS_NUM) THEN
        x_taiv_rec.set_of_books_id := Okl_Accounting_Util.get_set_of_books_id;
      ELSE
        x_taiv_rec.set_of_books_id := p_taiv_rec.set_of_books_id;
        --TAI
      END IF;

      --Start code added by pgomes on 20-NOV-2002
      --Check for currency code

      IF (p_taiv_rec.currency_code IS NULL OR p_taiv_rec.currency_code=OKL_API.G_MISS_CHAR) THEN
        x_taiv_rec.currency_code := l_currency_code;
      ELSE
        x_taiv_rec.currency_code := p_taiv_rec.currency_code;
      END IF;

      --Check for currency conversion type

      IF (p_taiv_rec.currency_conversion_type IS NULL OR p_taiv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR) THEN
        x_taiv_rec.currency_conversion_type := l_currency_conversion_type;
      ELSE
        x_taiv_rec.currency_conversion_type := p_taiv_rec.currency_conversion_type;
      END IF;

      --Check for currency conversion rate

      -- 6140771
      IF(x_taiv_rec.currency_conversion_type = 'User') THEN

        IF(x_taiv_rec.currency_code = Okl_Accounting_Util.get_func_curr_code) THEN
          x_taiv_rec.currency_conversion_rate := 1;
        ELSE

          IF (p_taiv_rec.currency_conversion_rate IS NULL OR p_taiv_rec.currency_conversion_rate=OKL_API.G_MISS_NUM) THEN
            x_taiv_rec.currency_conversion_rate := l_currency_conversion_rate;
          ELSE
            x_taiv_rec.currency_conversion_rate := p_taiv_rec.currency_conversion_rate;
          END IF;

        END IF;

      ELSE
        x_taiv_rec.currency_conversion_rate := NULL;
      END IF;

      --Check for currency conversion date

      --Bug 9001169: Adding IF condition for manual invoice check
      --             and for others keeping as it in ELSE part. (Added by NIKSHAH)
      IF NVL(p_taiv_rec.OKL_SOURCE_BILLING_TRX,'NONE') = 'MANUAL_INVOICE' THEN
        IF p_taiv_rec.currency_conversion_date IS NULL OR p_taiv_rec.currency_conversion_date = OKL_API.G_MISS_DATE THEN
          IF(x_taiv_rec.currency_conversion_type = 'User') THEN
            x_taiv_rec.currency_conversion_date := l_currency_conversion_date;
          ELSE
            x_taiv_rec.currency_conversion_date := p_taiv_rec.date_invoiced;
          END IF;
        ELSE
          x_taiv_rec.currency_conversion_date := p_taiv_rec.currency_conversion_date;
        END IF;
      ELSE
        IF (p_taiv_rec.currency_conversion_date IS NULL  OR p_taiv_rec.currency_conversion_date = OKL_API.G_MISS_DATE) THEN
          x_taiv_rec.currency_conversion_date := l_currency_conversion_date;
        ELSE
          x_taiv_rec.currency_conversion_date := p_taiv_rec.currency_conversion_date;
        END IF;
      END IF;

      --End code added by pgomes on 20-NOV-2002

      --Start code added by pgomes on 06-JAN-2003

      --Bug 9001169: Adding IF condition for manual invoice check
      --             and for others keeping as it in ELSE part. (Added by NIKSHAH)
      IF NVL(p_taiv_rec.OKL_SOURCE_BILLING_TRX,'NONE') = 'MANUAL_INVOICE' THEN
        IF(x_taiv_rec.currency_conversion_type    IS NULL OR x_taiv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR) THEN
          x_taiv_rec.currency_conversion_type := 'User';
          x_taiv_rec.currency_conversion_rate := 1;
          x_taiv_rec.currency_conversion_date := SYSDATE;
        END IF;
      ELSE
      -- 6140771
       /* ankushar 16-Apr-2008 Bug# 6237730, Added condition for defaulting currency rate, date and type
         start code changes
       */
        IF(x_taiv_rec.currency_conversion_type    IS NULL OR x_taiv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR
           OR x_taiv_rec.currency_conversion_date IS NULL OR x_taiv_rec.currency_conversion_date = OKL_API.G_MISS_DATE
           OR x_taiv_rec.currency_conversion_rate IS NULL OR x_taiv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM) THEN
         /* ankushar End Changes */

          x_taiv_rec.currency_conversion_type := 'User';
          x_taiv_rec.currency_conversion_rate := 1;
          x_taiv_rec.currency_conversion_date := SYSDATE;
        END IF;
      END IF;

      --End code added by pgomes on 06-JAN-2003
      -- Populate Customer TRX-TYPE ID From AR setup

      IF p_taiv_rec.amount < 0 THEN
        x_taiv_rec.irt_id := NULL;

        --OPEN cm_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id,   xsi_tbl(l_xsi_cnt).org_id);
        --xsi_tbl(l_xsi_cnt).org_id was null out, so use p_ie_tbl1(k).org_id
        OPEN cm_trx_type_csr(x_taiv_rec.set_of_books_id, x_taiv_rec.org_id);
        FETCH cm_trx_type_csr
        INTO x_taiv_rec.cust_trx_type_id;
        CLOSE cm_trx_type_csr;
      ELSE
      /* ankushar 25-Oct-2007 Bug# 6501426, Transaction Type corrected for Investor
         start code changes
       */
        --Check if Investor-Stake Billing, then do not populate l_cust_trx_id with 'Invoice-OKL', since Investor API is already populating
        --this value with 'Investor-OKL' as the transaction type value.
        IF p_taiv_rec.okl_source_billing_trx <> 'INVESTOR_STAKE' THEN
          --OPEN cust_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id,   xsi_tbl(l_xsi_cnt).org_id);
          OPEN cust_trx_type_csr(x_taiv_rec.set_of_books_id, x_taiv_rec.org_id);
          FETCH cust_trx_type_csr
          INTO x_taiv_rec.cust_trx_type_id;
          CLOSE cust_trx_type_csr;
        END IF;
      /* ankushar 25-Oct-2007 Bug# 6501426
         End Changes
       */
      END IF;

      --gkhuntet added for Manual Invoices 06-07-2007 start
        IF p_taiv_rec.okl_source_billing_trx = G_MANUAL THEN
          IF p_taiv_rec.amount < 0 THEN --TRY_ID for the CREDIT_MEMO.
                OPEN cm_okx_trx_type_csr;
                FETCH cm_okx_trx_type_csr
                INTO x_taiv_rec.try_id;
                CLOSE cm_okx_trx_type_csr;
          ELSE  --TRY_ID for the BILLING.
                OPEN in_okx_trx_type_csr;
                FETCH in_okx_trx_type_csr
                INTO x_taiv_rec.try_id;
                CLOSE in_okx_trx_type_csr;
          END IF;
      END IF;
--gkhuntet added for Manual Invoices 06-07-2007 end

 -- Set Tax exempt flag to Standard
      x_taiv_rec.tax_exempt_flag := 'S';
      x_taiv_rec.tax_exempt_reason_code := NULL;

--start: |  30-Mar-2007 cklee -- validate taiv_rec.trx_status_code and default to     |
--|                       'SUBMITTED'                                          |
    IF p_taiv_rec.trx_status_code IS NULL or p_taiv_rec.trx_status_code = okl_api.g_miss_char
	THEN
      x_taiv_rec.trx_status_code := G_SUBMITTED;
    END IF;
--end: |  30-Mar-2007 cklee -- validate taiv_rec.trx_status_code and default to     |
--|                       'SUBMITTED'                                          |

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO additional_tai_attr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO additional_tai_attr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO additional_tai_attr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end additional_tai_attr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : additional_txl_attr
-- Description     : Internal procedure to add additional columns for
--                   OKL_TXL_AR_INV_LNS_B
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE additional_til_attr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tilv_rec                     IN tilv_rec_type
   ,x_tilv_rec                     OUT NOCOPY tilv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'additional_til_attr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_line_code                  CONSTANT VARCHAR2(30)    := 'LINE';


begin
  -- Set API savepoint
  SAVEPOINT additional_til_attr;
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_tilv_rec.id :'||p_tilv_rec.id);
    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
  -- assign all passed in attributes from IN to OUT record
  x_tilv_rec := p_tilv_rec;

-- Copy the following code from okl_stream_billing_pvt
-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns in til_tbl -- start
                -- apaul: Comment out hard coding isl_id
		--x_tilv_rec.ISL_ID    := 1;
		x_tilv_rec.inv_receiv_line_code  := l_line_code;
		x_tilv_rec.QUANTITY  := 1;
-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns in til_tbl -- end



/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO additional_til_attr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO additional_til_attr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO additional_til_attr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end additional_til_attr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : additional_tld_attr
-- Description     : Internal procedure to add additional columns for
--                   OKL_TXD_AR_LN_DTLS_B
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE additional_tld_attr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tldv_rec                     IN tldv_rec_type
   ,x_tldv_rec                     OUT NOCOPY tldv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'additional_tld_attr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
/*
        l_recv_inv_id NUMBER;
        CURSOR reverse_csr1(p_tld_id NUMBER) IS
        SELECT receivables_invoice_id
        FROM okl_txd_ar_ln_dtls_v
        WHERE id = p_tld_id;

        CURSOR reverse_csr2(p_til_id NUMBER) IS
        SELECT receivables_invoice_id
        FROM okl_txl_ar_inv_lns_v
        WHERE id = p_til_id;


  -- Get currency attributes
  CURSOR l_curr_csr(cp_currency_code VARCHAR2) IS
  SELECT c.minimum_accountable_unit,
    c.PRECISION
  FROM fnd_currencies c
  WHERE c.currency_code = cp_currency_code;
*/
  -- Get currency attributes
  CURSOR l_curr_csr(p_khr_id number) IS
  SELECT c.minimum_accountable_unit,
    c.PRECISION
  FROM fnd_currencies c,
       okl_trx_ar_invoices_b b
  WHERE c.currency_code = b.currency_code
  AND   b.khr_id = p_khr_id;


  l_min_acct_unit fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision fnd_currencies.PRECISION %TYPE;

  l_rounded_amount OKL_TXD_AR_LN_DTLS_B.amount%TYPE;

  -- to get inventory_org_id  bug 4890024 begin
  CURSOR inv_org_id_csr(p_contract_id NUMBER) IS
  SELECT NVL(inv_organization_id,   -99)
  FROM okc_k_headers_b
  WHERE id = p_contract_id;

begin
  -- Set API savepoint
  SAVEPOINT additional_tld_attr;
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_tldv_rec.id :'||p_tldv_rec.id);
    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
  -- assign all passed in attributes from IN to OUT record
  x_tldv_rec := p_tldv_rec;
/* For R12, okl_arfetch_pub is absolete, so the following logic won't work
since the receivable_invoice_id is null
      --For Credit Memo Processing
      IF p_tldv_rec.tld_id_reverses IS NOT NULL THEN
        -- Null out variables
        l_recv_inv_id := NULL;

        OPEN reverse_csr1(p_tldv_rec.tld_id_reverses);
        FETCH reverse_csr1
        INTO l_recv_inv_id;
        CLOSE reverse_csr1;
        x_tldv_rec.reference_line_id := l_recv_inv_id;
      ELSE
        x_tldv_rec.reference_line_id := NULL;
      END IF;

      x_tldv_rec.receivables_invoice_id := NULL;
      -- Populated later by fetch
*/

      IF(p_tldv_rec.inventory_org_id IS NULL OR p_tldv_rec.inventory_org_id=OKL_API.G_MISS_NUM) THEN

        OPEN inv_org_id_csr(p_tldv_rec.khr_id);
        FETCH inv_org_id_csr
        INTO x_tldv_rec.inventory_org_id;
        CLOSE inv_org_id_csr;
      ELSE
        x_tldv_rec.inventory_org_id := p_tldv_rec.inventory_org_id;
      END IF;

      -- Bug 4890024 end

      -------- Rounded Amount --------------
      l_rounded_amount := NULL;
      l_min_acct_unit := NULL;
      l_precision := NULL;

      OPEN l_curr_csr(p_tldv_rec.khr_id);
      FETCH l_curr_csr
      INTO l_min_acct_unit,
        l_precision;
      CLOSE l_curr_csr;

      IF(NVL(l_min_acct_unit,   0) <> 0) THEN
        -- Round the amount to the nearest Min Accountable Unit
        l_rounded_amount := ROUND(p_tldv_rec.amount / l_min_acct_unit) * l_min_acct_unit;

      ELSE
        -- Round the amount to the nearest precision
        l_rounded_amount := ROUND(p_tldv_rec.amount,   l_precision);
      END IF;
      -------- Rounded Amount --------------
      x_tldv_rec.amount := l_rounded_amount;
      --TIL
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO additional_tld_attr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO additional_tld_attr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO additional_tld_attr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end additional_tld_attr;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_billing_usage
-- Description     : Internal procedure to validate overall billing API usage
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  FUNCTION validate_billing_usage(
   p_tilv_tbl     IN tilv_tbl_type,
   p_tldv_tbl     IN tldv_tbl_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_til_exist BOOLEAN;
    l_tld_exist BOOLEAN;

  BEGIN

    -- 1) if it's 3 layers, set G_IS_STREAM_BASED_BILLING := TRUE;
    -- 2) if it's 2 layers, set G_IS_STREAM_BASED_BILLING := FALSE;
    -- 3) if p_tilv_tbl.count = 0, throw error

    IF p_tilv_tbl.COUNT > 0 AND p_tldv_tbl.COUNT > 0 THEN

      G_IS_STREAM_BASED_BILLING := TRUE;
    ELSIF p_tilv_tbl.COUNT > 0 AND p_tldv_tbl.COUNT = 0 THEN
      G_IS_STREAM_BASED_BILLING := FALSE;
    ELSIF p_tilv_tbl.COUNT = 0 THEN

      -- developer note: Replace with a proper message
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'p_tilv_tbl.STY_ID');

      raise G_EXCEPTION_HALT_VALIDATION;
    ELSE
      null;
    END IF;
    -- Note: Please refer to the business rules from spec API.

  RETURN l_return_status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_TXL_AR_LINE_NUMBER
-- Description     : Internal procedure to validate TXL_AR_LINE_NUMBER usage
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  FUNCTION validate_TXL_AR_LINE_NUMBER(
   p_tilv_tbl     IN tilv_tbl_type,
   p_tldv_tbl     IN tldv_tbl_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_til_loop_cnt    NUMBER := 0;
    l_til_ln_number   NUMBER := 0;
    l_current         NUMBER := 0;
    l_tld_loop_cnt    NUMBER := 0;
    l_total           NUMBER := 0;
  BEGIN

--  R2): If TXL_AR_LINE_NUMBER exists in p_tilv_tbl, but doesn't exists in p_tldv_tbl, throw error.
--  R3): If TXL_AR_LINE_NUMBER exists in p_tldv_tbl, but doesn't exists in p_tilv_tbl, throw error.
    l_til_loop_cnt := p_tilv_tbl.first;
    loop

--    for  l_til_loop_cnt in 1 .. p_tilv_tbl.count loop
       -- Raise Exception if any of til records does not  have TXL_AR_LINE_NUMBER
       if p_tilv_tbl(l_til_loop_cnt).TXL_AR_LINE_NUMBER is null OR
          p_tilv_tbl(l_til_loop_cnt).TXL_AR_LINE_NUMBER = Okl_Api.G_MISS_NUM
	   then
         raise G_EXCEPTION_HALT_VALIDATION;
       end if;
       l_til_ln_number := p_tilv_tbl(l_til_loop_cnt).TXL_AR_LINE_NUMBER;
       l_current := 0;
         l_tld_loop_cnt := p_tldv_tbl.first;
         loop
         --for l_tld_loop_cnt in 1 .. p_tldv_tbl.count loop
       -- Raise Exception if any of tld record does not  have txl_ar_ln_number
           if p_tldv_tbl(l_tld_loop_cnt).TXL_AR_LINE_NUMBER is null OR
              p_tilv_tbl(l_til_loop_cnt).TXL_AR_LINE_NUMBER = Okl_Api.G_MISS_NUM
           then
              raise G_EXCEPTION_HALT_VALIDATION;
           end if;
           if (p_tldv_tbl(l_tld_loop_cnt).TXL_AR_LINE_NUMBER = l_til_ln_number) then
             l_current := l_current+1;
           end if;
           EXIT WHEN l_tld_loop_cnt = p_tldv_tbl.LAST;
           l_tld_loop_cnt := p_tldv_tbl.NEXT(l_tld_loop_cnt);
         end loop;
         -- Raise Exception if any of the til records have 0 child tld records
         if l_current = 0 then
           raise G_EXCEPTION_HALT_VALIDATION;
           -- raise error
         else
            l_total := l_total+l_current;
         end if;
         EXIT WHEN l_til_loop_cnt = p_tilv_tbl.LAST;
         l_til_loop_cnt := p_tilv_tbl.NEXT(l_til_loop_cnt);
    end loop;

    -- Raise Exception if total children of til records is not equivalent to number of tld records
    -- If any tld record does not have corresponding til record
    if l_total <> p_tldv_tbl.count then
           -- raise error
           raise G_EXCEPTION_HALT_VALIDATION;
    end if;
  RETURN l_return_status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'TXL_AR_LINE_NUMBER');
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_attributes
-- Description     : Internal procedure to validate overall billing API usage
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION validate_attributes(
   p_taiv_rec     IN taiv_rec_type,
   p_tilv_tbl     IN tilv_tbl_type,
   p_tldv_tbl     IN tldv_tbl_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_billing_usage(p_tilv_tbl => p_tilv_tbl,
                                              p_tldv_tbl => p_tldv_tbl);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- If it's stream based billing usage (3 layers passed in structure)
    IF G_IS_STREAM_BASED_BILLING = TRUE THEN

      l_return_status := validate_TXL_AR_LINE_NUMBER(p_tilv_tbl => p_tilv_tbl,
                                                     p_tldv_tbl => p_tldv_tbl);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_attributes;
------------------

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_tai_values
-- Description     : Internal procedure to validate p_taiv_rec attributes
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE validate_tai_values(
   p_taiv_rec     IN taiv_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status   VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_taiv_rec.khr_id IS NULL OR p_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) AND
	   (p_taiv_rec.ixx_id IS NULL OR p_taiv_rec.ixx_id = Okl_Api.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'okl_trx_ar_invoices_b.ixx_id');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_taiv_rec.khr_id IS NULL OR p_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) AND
	   (p_taiv_rec.irm_id IS NULL OR p_taiv_rec.irm_id = Okl_Api.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'okl_trx_ar_invoices_b.irm_id');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_taiv_rec.khr_id IS NULL OR p_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) AND
	   (p_taiv_rec.irt_id IS NULL OR p_taiv_rec.irt_id = Okl_Api.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'okl_trx_ar_invoices_b.irt_id');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_taiv_rec.khr_id IS NULL OR p_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) AND
	   (p_taiv_rec.ibt_id IS NULL OR p_taiv_rec.ibt_id = Okl_Api.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'okl_trx_ar_invoices_b.ibt_id');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_taiv_rec.khr_id IS NULL OR p_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) AND
	   (p_taiv_rec.org_id IS NULL OR p_taiv_rec.org_id = Okl_Api.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'okl_trx_ar_invoices_b.org_id');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_taiv_rec.khr_id IS NULL OR p_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) AND
	   (p_taiv_rec.legal_entity_id IS NULL OR p_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'okl_trx_ar_invoices_b.legal_entity_id');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

--start: |  30-Mar-2007 cklee -- validate taiv_rec.trx_status_code and default to     |
--|                       'SUBMITTED'                                          |
    --gkhuntet added for Manual Invoice on 06-07-2007 Start.                                       |
    IF p_taiv_rec.okl_source_billing_trx <> G_MANUAL AND
--gkhuntet added for Manual Invoice on 06-07-2007 End.
    p_taiv_rec.trx_status_code IS NOT NULL
    and p_taiv_rec.trx_status_code <> G_SUBMITTED
	THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'okl_trx_ar_invoices_b.trx_status_code');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--end: |  30-Mar-2007 cklee -- validate taiv_rec.trx_status_code and default to     |
--|                       'SUBMITTED'                                          |


    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
  END validate_tai_values;


----------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : validate_tld_values
-- Description     : this procedure checks to make sure calling apis, do not pass
--                   values to some of the derived columns of OKL_TXD_AR_LN_DTLS_B
--                   The reason this procedure need not be invoked in the beginning
--                   is APIs normally would not pass these values and if we invoke
--                   it in the beginning then it would have to make an additional
--                   loop of p_tldv_rec, which would be not performant
--                   This procedure will check for error data and will set error
--                   message and the applicable return status
-- Usage           : Calling procedure should loop thru all tldv records and call
--                   this procedure for each record
--                   Calling procedure should handle x_return_status properly
--                   and raise proper exception after calling this procedure
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE validate_tld_values(
   p_tldv_rec     IN tldv_rec_type,
   p_source       IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status   VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
-- rmunjulu R12 Fixes -- do not allow caller to pass values to following columns
--INVOICE_FORMAT_LINE_TYPE
--LATE_CHARGE_ASSESS_DATE
--LATE_INT_ASSESS_DATE
--LATE_CHARGE_ASS_YN
--LATE_INT_ASS_YN
--INVESTOR_DISB_STATUS
--INVESTOR_DISB_ERR_MG
--DATE_DISBURSED
--PAY_STATUS_CODE
--TAX_AMOUNT
--INVOICE_FORMAT_TYPE
/*
    IF p_tldv_rec.INVOICE_FORMAT_LINE_TYPE IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'INVOICE_FORMAT_LINE_TYPE');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.LATE_CHARGE_ASSESS_DATE IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'LATE_CHARGE_ASSESS_DATE');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.LATE_INT_ASSESS_DATE IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'LATE_INT_ASSESS_DATE');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.LATE_CHARGE_ASS_YN IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'LATE_CHARGE_ASS_YN');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.LATE_INT_ASS_YN IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'LATE_INT_ASS_YN');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.INVESTOR_DISB_STATUS IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'INVESTOR_DISB_STATUS');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.INVESTOR_DISB_ERR_MG IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'INVESTOR_DISB_ERR_MG');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.DATE_DISBURSED IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'DATE_DISBURSED');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.PAY_STATUS_CODE IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'PAY_STATUS_CODE');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.TAX_AMOUNT IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'TAX_AMOUNT');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_tldv_rec.INVOICE_FORMAT_TYPE IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'INVOICE_FORMAT_TYPE');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
-- LSM_ID does not exist in tapi yet
/*
    IF p_tldv_rec.LSM_ID IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'LSM_ID');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
/*
    IF p_tldv_rec.KHR_ID IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'KHR_ID');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- if source not rebook then do not allow this column to be populated by called process
    IF nvl(p_source,'*') <> 'REBOOK' AND p_tldv_rec.RBK_ORI_INVOICE_NUMBER IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'RBK_ORI_INVOICE_NUMBER');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- if source not rebook then do not allow this column to be populated by called process
    IF nvl(p_source,'*') <> 'REBOOK' AND p_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'RBK_ORI_INVOICE_LINE_NUMBER');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- if source not rebook then do not allow this column to be populated by called process
    IF nvl(p_source,'*') <> 'REBOOK' AND p_tldv_rec.RBK_ADJUSTMENT_DATE IS NOT NULL THEN
       OKL_API.set_message(p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'RBK_ADJUSTMENT_DATE');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
--start: |  05-Apr-2007 cklee -- Fixed the following:                                 |


    IF G_IS_STREAM_BASED_BILLING = TRUE THEN

      IF (p_tldv_rec.SEL_ID IS NULL or p_tldv_rec.SEL_ID = okl_api.g_miss_num )
        AND (p_source <> 'UBB')
	--gkhuntet 26-07-2007
	AND (p_source <> 'REMARKETING')  THEN  ----gkhuntet 26-07-2007  -- apaul 20-June-2007
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'SEL_ID');
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

--end: |  05-Apr-2007 cklee -- Fixed the following:                                 |

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
  END validate_tld_values;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_non_sel_billing_trx
-- Description     : wrapper api to create internal billing transactions
-- Business Rules  :
--                 Usage:
--
--
--                       If caller pass the following parameters with data,
--                       ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
--                       ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
--                       then system assume caller is intend to create non-stream based (without stream element)
--                       internal billing transactions.
--
--                       In this scenario, p_tilv_tbl(n).TXL_AR_LINE_NUMBER is not a required attribute.
--                       If user does pass p_tilv_tbl(n).TXL_AR_LINE_NUMBER, system will assume this is a
--                       redundant data.
--                       System will copy the major attributes (STY_ID, AMOUNT, etc) from p_tilv_rec to
--                       create record in OKL_TXD_AR_LN_DTLS_b/tl table (Internal billing invoice/invoce line)
--
--                 Note: 1. Assume all calling API will validate attributes before make the call. This is
--                       the current architecture and we will adopt all validation logic from calling API
--                       to this central API in the future.
-- Parameters      :
--
--                 p_taiv_rec: Internal billing contract transaction header (okl_trx_ar_invoices_v)
--                 p_tilv_tbl: Internal billing contract transaction line (OKL_TXL_AR_INV_LNS_V)
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE create_non_sel_billing_trx(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
   ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
   ,x_taiv_rec                     OUT NOCOPY okl_tai_pvt.taiv_rec_type
   ,x_tilv_tbl                     OUT NOCOPY okl_til_pvt.tilv_tbl_type
-- start: cklee -- fixed return parameters issues 4/6/07
   ,x_tldv_tbl                     OUT NOCOPY okl_tld_pvt.tldv_tbl_type
-- end: cklee -- fixed return parameters issues 4/6/07
   ,p_cpl_id                       IN  NUMBER DEFAULT NULL
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_non_sel_billing_trx';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_til_loop_cnt                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_taiv_rec        okl_tai_pvt.taiv_rec_type := p_taiv_rec;
  lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
  lp_tilv_tbl        okl_til_pvt.tilv_tbl_type := p_tilv_tbl;
  lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
  lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  l_taiv_id          NUMBER;
  lx_tilv_rec	       okl_til_pvt.tilv_rec_type;
  l_tld_loop_cnt     NUMBER;
  l_til_ln_number    NUMBER;
  lx_tldv_rec        okl_tld_pvt.tldv_rec_type;
  l_til_id           NUMBER;
  l_til_debug_cnt    NUMBER;
  l_tld_debug_cnt    NUMBER;
  p_bpd_acc_rec      Okl_Acc_Call_Pub.bpd_acc_rec_type;
  --gkhuntet added start.
  l_flag_acc_call             VARCHAR2(5);
 --gkhuntet added end.

  ---- Added by Vpanwar --- Code for new accounting API uptake
	l_tmpl_identify_rec    	    Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
  	l_dist_info_rec        		Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE;
  	l_ctxt_val_tbl         		Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
  	l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY;

    l_tmpl_identify_tbl         Okl_Account_Dist_Pvt.TMPL_IDENTIFY_TBL_TYPE;
    l_dist_info_tbl             Okl_Account_Dist_Pvt.DIST_INFO_TBL_TYPE;
    l_ctxt_tbl                  Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl               Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
   	l_template_out_tbl		    Okl_Account_Dist_Pvt.avlv_out_tbl_type;
	l_amount_out_tbl		    Okl_Account_Dist_Pvt.amount_out_tbl_type;
	l_trx_header_id             NUMBER;
    l_trx_header_tbl            VARCHAR2(50);
  ---- End Added by Vpanwar --- Code for new accounting API uptake

    l_rle_code              VARCHAR2(30);

    cursor l_get_rle_code_csr (p_cpl_id in number) is
    select rle_Code
    from   okc_k_party_roles_b
    where  id = p_cpl_id;

begin
  -- Set API savepoint
  SAVEPOINT create_non_sel_billing_trx;
     IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Taiv Parameters '||' Currency Code  :'||p_taiv_rec.currency_code||' Currency conversion type  :'||p_taiv_rec.currency_conversion_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Currency conversion rate  :'||p_taiv_rec.currency_conversion_rate||' Currency conversion date  :'||p_taiv_rec.currency_conversion_date);

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'tilv Parameters');
      IF (p_tilv_tbl.count > 0) THEN -- 6402950
      l_til_debug_cnt := p_tilv_tbl.first;
      loop
      --for l_til_debug_cnt in 1 .. p_tilv_tbl.count loop
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inv receiv line code :'||p_tilv_tbl(l_til_debug_cnt).inv_receiv_line_code);
      EXIT WHEN l_til_debug_cnt = p_tilv_tbl.LAST; -- 6402950
      l_til_debug_cnt := p_tilv_tbl.NEXT(l_til_debug_cnt);
      end loop;
      END IF;

    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/


-- 2. Create okl_trx_ar_invoices_b record: okl_tai_pvt.insert_row;

-- start: cklee -- add additional columns 3/19/07
  validate_tai_values(
              p_taiv_rec       => lp_taiv_rec,
              x_return_status  => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_cpl_id IS NOT NULL THEN
      OPEN l_get_rle_code_csr(p_cpl_id);
      FETCH l_get_rle_code_csr INTO l_rle_code;
      CLOSE l_get_rle_code_csr;
    END IF;

  additional_tai_attr(
    p_api_version         => p_api_version,
    p_init_msg_list       => p_init_msg_list,
    x_return_status       => l_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_taiv_rec            => lp_taiv_rec,
    x_taiv_rec            => lx_taiv_rec,
    p_rle_code            => l_rle_code);


    lp_taiv_rec := lx_taiv_rec;

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
-- end: cklee -- add additional columns 3/19/07

  okl_tai_pvt.insert_row(
    p_api_version         => p_api_version,
    p_init_msg_list       => p_init_msg_list,
    x_return_status       => l_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_taiv_rec            => lp_taiv_rec,
    x_taiv_rec            => lx_taiv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_taiv_rec.id: '||to_char(lx_taiv_rec.id));
    END IF;
-- 3. Assign attributes back to lx_taiv_rec along with ID (passed lx_taiv_rec as OUT parameter)

    l_taiv_id := lx_taiv_rec.ID;

-- 4. Loop til tbl
  l_til_loop_cnt := lp_tilv_tbl.first;
  loop
  --FOR l_til_loop_cnt in 1 .. lp_tilv_tbl.count loop

  --  Assign lx_taiv_rec.ID to lp_til_rec.TAI_ID;
     lp_tilv_tbl(l_til_loop_cnt).TAI_ID := l_taiv_id;
--start: |  05-Apr-2007 cklee -- Fixed the following:                                 |
     lp_tilv_tbl(l_til_loop_cnt).ORG_ID := lp_taiv_rec.org_id;
--end: |  05-Apr-2007 cklee -- Fixed the following:                                 |

-- start: cklee -- add additional columns 3/19/07

     additional_til_attr(
      p_api_version         => p_api_version,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => l_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_tilv_rec            => lp_tilv_tbl(l_til_loop_cnt),
      x_tilv_rec            => lx_tilv_tbl(l_til_loop_cnt));

      lp_tilv_tbl(l_til_loop_cnt) := lx_tilv_tbl(l_til_loop_cnt);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
-- end: cklee -- add additional columns 3/19/07

     -- Create okl_TXL_AR_INV_LNS_B record: okl_til_pvt.insert_row;
         okl_til_pvt.insert_row(
                p_api_version          => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => l_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_tilv_rec             => lp_tilv_tbl(l_til_loop_cnt),
                x_tilv_rec             => lx_tilv_rec);

   --  Error handling lx_taiv_rec;
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tilv_rec.id: '||to_char(lx_tilv_rec.id));
    END IF;

--    l_til_ln_number := lx_tilv_rec.TXL_AR_LINE_NUMBER;
    l_til_id        := lx_tilv_rec.id;

--         Assign attributes back to lx_tilv_rec along with ID;
-- start: cklee -- fixed return parameters issues 4/6/07
    lp_tilv_tbl(l_til_loop_cnt) := lx_tilv_rec;
-- end: cklee -- fixed return parameters issues 4/6/07

/***
-- Developer Note:
-- 1. For each TIL record, copy STY_ID, AMOUNT, ORG_ID, INVENTORY_ORG_ID, INVENTORY_ITEM_ID
--    to TLD pl/sql record and call okl_tld_pvt.insert_row() to create TLD.
-- 2. lx_tilv_rec.TXL_AR_LINE_NUMBER is not required for this procesdure
--
***/
        lp_tldv_tbl(l_til_loop_cnt).TIL_ID_DETAILS := l_til_id;
        lp_tldv_tbl(l_til_loop_cnt).STY_ID := lx_tilv_rec.STY_ID;
        lp_tldv_tbl(l_til_loop_cnt).AMOUNT := lx_tilv_rec.AMOUNT; -- this is 2 level, so we need to copy to tld
        lp_tldv_tbl(l_til_loop_cnt).ORG_ID := lx_tilv_rec.ORG_ID;
        lp_tldv_tbl(l_til_loop_cnt).INVENTORY_ORG_ID := lx_tilv_rec.INVENTORY_ORG_ID;
        lp_tldv_tbl(l_til_loop_cnt).INVENTORY_ITEM_ID := lx_tilv_rec.INVENTORY_ITEM_ID;
-- start: cklee -- Add these columns since these are required columns
        lp_tldv_tbl(l_til_loop_cnt).LINE_DETAIL_NUMBER := l_til_loop_cnt;
        lp_tldv_tbl(l_til_loop_cnt).KHR_ID := lp_taiv_rec.KHR_ID;
        lp_tldv_tbl(l_til_loop_cnt).KLE_ID := lp_tilv_tbl(l_til_loop_cnt).KLE_ID;
-- end: cklee

-- rmunjulu R12 Fixes -- Default invoice_format_type, invoice_format_line_type
        Get_Invoice_format(
             p_api_version                  => p_api_version
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data
            ,p_inf_id                       => lp_taiv_rec.inf_id
            ,p_sty_id                       => lp_tldv_tbl(l_til_loop_cnt).STY_ID
            ,x_invoice_format_type          => lp_tldv_tbl(l_til_loop_cnt).invoice_format_type
            ,x_invoice_format_line_type     => lp_tldv_tbl(l_til_loop_cnt).invoice_format_line_type);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

-- start: cklee -- add additional columns 3/19/07
        additional_tld_attr(
         p_api_version         => p_api_version,
         p_init_msg_list       => p_init_msg_list,
         x_return_status       => l_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data,
         p_tldv_rec            => lp_tldv_tbl(l_til_loop_cnt),
         x_tldv_rec            => lx_tldv_tbl(l_til_loop_cnt));

        lp_tldv_tbl(l_til_loop_cnt) := lx_tldv_tbl(l_til_loop_cnt);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
-- end: cklee -- add additional columns 3/19/07

        okl_tld_pvt.insert_row(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_tbl(l_til_loop_cnt),
            x_tldv_rec             =>  lx_tldv_rec);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        lp_tldv_tbl(l_til_loop_cnt) := lx_tldv_rec;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tldv_rec.id: '||to_char(lx_tldv_rec.id));
        END IF;

/*
--  Set Loop counter to 0;
     l_tld_loop_cnt := 0;
--  Loop tld tbl with user key: TXL_AR_LINE_NUMBER
    l_tld_loop_cnt:= lp_tldv_tbl.first;
    loop
    --FOR l_tld_loop_cnt  in  1 .. lp_tldv_tbl.count loop
--  If TXL_AR_LINE_NUMBER matched then

      If lp_tldv_tbl(l_tld_loop_cnt).TXL_AR_LINE_NUMBER = l_til_ln_number then
--    Assign lx_til_rec.ID to lp_tld_rec.TIL_ID_DETAILS;
           lp_tldv_tbl(l_tld_loop_cnt).TIL_ID_DETAILS := l_til_id;
--             Create okl_TXD_AR_LN_DTLS_B record: okl_tld_pvt.insert_row;
        okl_tld_pvt.insert_row(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_tbl(l_tld_loop_cnt),
            x_tldv_rec             =>  lx_tldv_rec);
--             Assign attributes back to lx_tldv_rec along with ID;
--             Error handling;
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        lp_tldv_tbl(l_tld_loop_cnt) := lx_tldv_rec;
--    end if;
      End If;
      EXIT WHEN l_tld_loop_cnt = lp_tldv_tbl.LAST;
      l_tld_loop_cnt := lp_tldv_tbl.NEXT(l_tld_loop_cnt);
--         End loop;
    end loop;
*/
-- 5. End loop;
   EXIT WHEN l_til_loop_cnt = lp_tilv_tbl.LAST;
   l_til_loop_cnt := lp_tilv_tbl.NEXT(l_til_loop_cnt);
end loop;

x_taiv_rec := lx_taiv_rec;
x_tilv_tbl := lp_tilv_tbl;
-- start: cklee -- fixed return parameters issues 4/6/07
x_tldv_tbl := lp_tldv_tbl;
-- end: cklee -- fixed return parameters issues 4/6/07

--gkhuntet start.
l_flag_acc_call := 'Y';
   IF(lx_taiv_rec.okl_source_billing_trx = G_MANUAL
      AND lx_taiv_rec. trx_status_code <> 'SUBMITTED') THEN
        l_flag_acc_call := 'N';
 END IF;


      IF(l_flag_acc_call = 'Y') THEN
            create_accounting_dist(p_api_version   => p_api_version ,
                                   p_init_msg_list => p_init_msg_list ,
                                   x_return_status => l_return_status ,
                                   x_msg_count     => x_msg_count ,
                                   x_msg_data      => x_msg_data ,
                                   p_tldv_tbl      => lp_tldv_tbl ,
                                   p_tai_id        => lx_taiv_rec.ID
                                   );
       END IF;
       IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
--gkhuntet end.

/****** Code commented by gkhuntet , call the create_accounting_dist. ******/

/*--           Increase the counter;
l_tld_loop_cnt := 0;
-- 6. Process accounting distributions;
l_tld_loop_cnt := lp_tldv_tbl.first;
loop
--FOR l_tld_loop_cnt  in  1 .. lp_tldv_tbl.count loop
  p_bpd_acc_rec.id           := lp_tldv_tbl(l_tld_loop_cnt).id;
  p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';


  /* apaul -- Code commented out because new accing API uptake not complete
  Okl_Acc_Call_Pub.CREATE_ACC_TRANS(p_api_version    =>  p_api_version,
                                    p_init_msg_list  =>  p_init_msg_list,
                                    x_return_status  =>  l_return_status,
                                    x_msg_count      =>  x_msg_count,
                                    x_msg_data       =>  x_msg_data,
                                    p_bpd_acc_rec    =>  p_bpd_acc_rec);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Acc_Call_Pub.CREATE_ACC_TRANS:p_bpd_acc_rec.id: '||to_char(p_bpd_acc_rec.id));
    END IF;
    */

    ---- Added by Vpanwar --- Code for new accounting API uptake
  /*
    Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW(p_api_version                 =>  p_api_version,
                                            p_init_msg_list             =>  p_init_msg_list,
                                            x_return_status             =>  l_return_status,
                                            x_msg_count                 =>  x_msg_count,
                                            x_msg_data                  =>  x_msg_data,
                                            p_bpd_acc_rec               =>  p_bpd_acc_rec,
                                            x_tmpl_identify_rec         =>  l_tmpl_identify_rec,
                                            x_dist_info_rec             =>  l_dist_info_rec,
                                            x_ctxt_val_tbl              =>  l_ctxt_val_tbl,
                                            x_acc_gen_primary_key_tbl   =>  l_acc_gen_primary_key_tbl);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


     --- populate the tables for passing to Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST

      l_acc_gen_tbl(l_tld_loop_cnt).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
      l_acc_gen_tbl(l_tld_loop_cnt).source_id       := l_dist_info_rec.source_id;

      l_ctxt_tbl(l_tld_loop_cnt).ctxt_val_tbl       := l_ctxt_val_tbl;
      l_ctxt_tbl(l_tld_loop_cnt).source_id          := l_dist_info_rec.source_id;

      l_tmpl_identify_tbl(l_tld_loop_cnt)           := l_tmpl_identify_rec;

      l_dist_info_tbl(l_tld_loop_cnt)               := l_dist_info_rec;

    ---- End Added by Vpanwar --- Code for new accounting API uptake

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW:p_bpd_acc_rec.id: '||to_char(p_bpd_acc_rec.id));
    END IF;

  EXIT WHEN l_tld_loop_cnt = lp_tldv_tbl.LAST;
  l_tld_loop_cnt := lp_tldv_tbl.NEXT(l_tld_loop_cnt);
end loop;

 ---- Added by Vpanwar --- Code for new accounting API uptake
    l_trx_header_tbl:= 'okl_trx_ar_invoices_b';
    l_trx_header_id := lx_taiv_rec.id;
    --Call accounting with new signature
        Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				                  p_trx_header_id      => l_trx_header_id,
                                  p_trx_header_table   => l_trx_header_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */
    ---- End Added by Vpanwar --- Code for new accounting API uptake


--    Note: Refer to okl_billing_controller_pvt.bill_streams_master for details
--

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_non_sel_billing_trx;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_non_sel_billing_trx;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_non_sel_billing_trx;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
end create_non_sel_billing_trx;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_sel_billing_trx
-- Description     : wrapper api to create internal billing transactions
-- Business Rules  :
--
--                       If caller pass the following parameters with data,
--                       ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
--                       ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
--                       ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
--                       then system assume caller is intend to create stream based (with stream element)
--                       internal billing transactions.
--
--                       In this scenario, the following rules applied:
--                 R1): If p_tilv_tbl(n).TXL_AR_LINE_NUMBER exists, but p_tldv_tbl(n).TXL_AR_LINE_NUMBER
--                      doesn't exists, throw error.
--                 R2): If p_tldv_tbl(n).TXL_AR_LINE_NUMBER exists, but p_tilv_tbl(n).TXL_AR_LINE_NUMBER
--                      doesn't exists, throw error.
--
--                 Note:
--                 p_tilv_tbl(n).TXL_AR_LINE_NUMBER :
--                 User key to link between p_tilv_rec and p_tldv_tbl
--
--                 p_tldv_tbl(n).TXL_AR_LINE_NUMBER :
--                 User key to link between p_tldv_rec and p_tilv_rec
--
--                 Note: In order to process this API properly, you need to pass user enter TXL_AR_LINE_NUMBER
--                 to link between p_tilv_rec and p_tldv_tbl.
--
-- Parameters      :
--
--                 p_taiv_rec: Internal billing contract transaction header (okl_trx_ar_invoices_v)
--                 p_tilv_tbl: Internal billing contract transaction line (OKL_TXL_AR_INV_LNS_V)
--                 p_tldv_tbl: Internal billing invoice/invoce line (OKL_TXD_AR_LN_DTLS_V)
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE create_sel_billing_trx(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
   ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
   ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
   ,x_taiv_rec                     OUT NOCOPY okl_tai_pvt.taiv_rec_type
   ,x_tilv_tbl                     OUT NOCOPY okl_til_pvt.tilv_tbl_type
   ,x_tldv_tbl                     OUT NOCOPY okl_tld_pvt.tldv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_sel_billing_trx';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_til_loop_cnt                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_taiv_rec        okl_tai_pvt.taiv_rec_type := p_taiv_rec;
  lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
  lp_tilv_tbl        okl_til_pvt.tilv_tbl_type := p_tilv_tbl;
  lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
  lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type := p_tldv_tbl;
  lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  l_taiv_id          NUMBER;
  lx_tilv_rec	       okl_til_pvt.tilv_rec_type;
  l_tld_loop_cnt     NUMBER;
  l_til_ln_number    NUMBER;
  lx_tldv_rec        okl_tld_pvt.tldv_rec_type;
  l_til_id           NUMBER;
  l_til_debug_cnt    NUMBER;
  l_tld_debug_cnt    NUMBER;
  p_bpd_acc_rec      Okl_Acc_Call_Pub.bpd_acc_rec_type;

---- Added by Vpanwar --- Code for new accounting API uptake
	l_tmpl_identify_rec    	    Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
  	l_dist_info_rec        		Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE;
  	l_ctxt_val_tbl         		Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
  	l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY;

    l_tmpl_identify_tbl         Okl_Account_Dist_Pvt.TMPL_IDENTIFY_TBL_TYPE;
    l_dist_info_tbl             Okl_Account_Dist_Pvt.DIST_INFO_TBL_TYPE;
    l_ctxt_tbl                  Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl               Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
   	l_template_out_tbl		    Okl_Account_Dist_Pvt.avlv_out_tbl_type;
	l_amount_out_tbl		    Okl_Account_Dist_Pvt.amount_out_tbl_type;
	l_trx_header_id             NUMBER;
    l_trx_header_tbl            VARCHAR2(50);
---- End Added by Vpanwar --- Code for new accounting API uptake
begin
  -- Set API savepoint
  SAVEPOINT create_sel_billing_trx;
     IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Taiv Parameters '||' Currency Code  :'||p_taiv_rec.currency_code||' Currency conversion type  :'||p_taiv_rec.currency_conversion_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Currency conversion rate  :'||p_taiv_rec.currency_conversion_rate||' Currency conversion date  :'||p_taiv_rec.currency_conversion_date);

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'tilv Parameters');
      IF (p_tilv_tbl.count > 0) THEN -- 6402950
      l_til_debug_cnt := p_tilv_tbl.first;
      loop
      --for l_til_debug_cnt in 1 .. p_tilv_tbl.count loop
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inv receiv line code :'||p_tilv_tbl(l_til_debug_cnt).inv_receiv_line_code);
      EXIT WHEN l_til_debug_cnt = p_tilv_tbl.LAST; -- 6402950
      l_til_debug_cnt := p_tilv_tbl.NEXT(l_til_debug_cnt);
      end loop;
      END IF;

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'tldv Parameters');
      IF (lp_tldv_tbl.count > 0) THEN -- 6402950
      l_tld_debug_cnt := lp_tldv_tbl.first; -- 6402950
      loop
      --FOR  l_tld_debug_cnt in 1 .. p_tldv_tbl.count  LOOP
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'TXL AR LINE NUMBER :'||lp_tldv_tbl(l_tld_debug_cnt).TXL_AR_LINE_NUMBER);
      EXIT WHEN l_tld_debug_cnt = lp_tldv_tbl.LAST;
      l_tld_debug_cnt := lp_tldv_tbl.NEXT(l_tld_debug_cnt);
      END LOOP;
      END IF;
    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

--

-- 2. Create okl_trx_ar_invoices_b record: okl_tai_pvt.insert_row;

-- start: cklee -- add additional columns 3/19/07

  validate_tai_values(
              p_taiv_rec       => lp_taiv_rec,
              x_return_status  => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  additional_tai_attr(
    p_api_version         => p_api_version,
    p_init_msg_list       => p_init_msg_list,
    x_return_status       => l_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_taiv_rec            => lp_taiv_rec,
    x_taiv_rec            => lx_taiv_rec);

    lp_taiv_rec := lx_taiv_rec;

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
-- end: cklee -- add additional columns 3/19/07

  okl_tai_pvt.insert_row(
    p_api_version         => p_api_version,
    p_init_msg_list       => p_init_msg_list,
    x_return_status       => l_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_taiv_rec            => lp_taiv_rec,
    x_taiv_rec            => lx_taiv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
-- 3. Assign attributes back to lx_taiv_rec along with ID (passed lx_taiv_rec as OUT parameter)
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_taiv_rec.id: '||to_char(lx_taiv_rec.id));
    END IF;

    l_taiv_id := lx_taiv_rec.ID;

-- 4. Loop til tbl
  l_til_loop_cnt := lp_tilv_tbl.first;
  loop
  --FOR l_til_loop_cnt in 1 .. lp_tilv_tbl.count loop

  --  Assign lx_taiv_rec.ID to lp_til_rec.TAI_ID;
     lp_tilv_tbl(l_til_loop_cnt).TAI_ID := l_taiv_id;
--start: |  05-Apr-2007 cklee -- Fixed the following:                                 |
     lp_tilv_tbl(l_til_loop_cnt).ORG_ID := lp_taiv_rec.org_id;
--end: |  05-Apr-2007 cklee -- Fixed the following:                                 |

-- start: cklee -- add additional columns 3/19/07
     additional_til_attr(
      p_api_version         => p_api_version,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => l_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_tilv_rec            => lp_tilv_tbl(l_til_loop_cnt),
      x_tilv_rec            => lx_tilv_tbl(l_til_loop_cnt));

      lp_tilv_tbl(l_til_loop_cnt) := lx_tilv_tbl(l_til_loop_cnt);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
-- end: cklee -- add additional columns 3/19/07

     -- Create okl_TXL_AR_INV_LNS_B record: okl_til_pvt.insert_row;
         okl_til_pvt.insert_row(
                p_api_version          => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => l_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_tilv_rec             => lp_tilv_tbl(l_til_loop_cnt),
                x_tilv_rec             => lx_tilv_rec);

   --  Error handling lx_taiv_rec;
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tilv_rec.id: '||to_char(lx_tilv_rec.id));
    END IF;

    l_til_ln_number := lx_tilv_rec.TXL_AR_LINE_NUMBER;
    l_til_id        := lx_tilv_rec.id;

--         Assign attributes back to lx_tilv_rec along with ID;
-- start: cklee -- fixed return parameters issues 4/6/07
    lp_tilv_tbl(l_til_loop_cnt) := lx_tilv_rec;
-- end: cklee -- fixed return parameters issues 4/6/07

--  Set Loop counter to 0;
     l_tld_loop_cnt := 0;
--  Loop tld tbl with user key: TXL_AR_LINE_NUMBER
    l_tld_loop_cnt:= lp_tldv_tbl.first;
    loop
    --FOR l_tld_loop_cnt  in  1 .. lp_tldv_tbl.count loop
--  If TXL_AR_LINE_NUMBER matched then

      If lp_tldv_tbl(l_tld_loop_cnt).TXL_AR_LINE_NUMBER = l_til_ln_number then

-- rmunjulu R12 Fixes -- Validate that passed values for tld table are valid

        validate_tld_values(
              p_tldv_rec       => lp_tldv_tbl(l_til_loop_cnt),
              p_source         => lp_taiv_rec.okl_source_billing_trx,
              x_return_status  => l_return_status);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

--    Assign lx_til_rec.ID to lp_tld_rec.TIL_ID_DETAILS;
        lp_tldv_tbl(l_tld_loop_cnt).TIL_ID_DETAILS := l_til_id;
        lp_tldv_tbl(l_til_loop_cnt).LINE_DETAIL_NUMBER := l_til_loop_cnt;
        lp_tldv_tbl(l_tld_loop_cnt).KHR_ID := lp_taiv_rec.KHR_ID;
        lp_tldv_tbl(l_til_loop_cnt).KLE_ID := lp_tilv_tbl(l_til_loop_cnt).KLE_ID;
--             Create okl_TXD_AR_LN_DTLS_B record: okl_tld_pvt.insert_row;

-- rmunjulu R12 Fixes -- Added the below to populate the tld columns
--        lp_tldv_tbl(l_til_loop_cnt).STY_ID := lx_tilv_rec.STY_ID;
-- start: cklee til.amount may not be the same as tld amount, so commented the following code
--        lp_tldv_tbl(l_til_loop_cnt).AMOUNT := lx_tilv_rec.AMOUNT;
-- end: cklee til.amount may not be the same as tld amount, so commented the following code
        lp_tldv_tbl(l_til_loop_cnt).ORG_ID := lx_tilv_rec.ORG_ID;
        lp_tldv_tbl(l_til_loop_cnt).INVENTORY_ORG_ID := lx_tilv_rec.INVENTORY_ORG_ID;
        lp_tldv_tbl(l_til_loop_cnt).INVENTORY_ITEM_ID := lx_tilv_rec.INVENTORY_ITEM_ID;

-- rmunjulu R12 Fixes -- Default invoice_format_type, invoice_format_line_type
        Get_Invoice_format(
             p_api_version                  => p_api_version
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data
            ,p_inf_id                       => lp_taiv_rec.inf_id
            ,p_sty_id                       => lp_tldv_tbl(l_til_loop_cnt).STY_ID
            ,x_invoice_format_type          => lp_tldv_tbl(l_til_loop_cnt).invoice_format_type
            ,x_invoice_format_line_type     => lp_tldv_tbl(l_til_loop_cnt).invoice_format_line_type);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

-- start: cklee -- add additional columns 3/19/07
        additional_tld_attr(
         p_api_version         => p_api_version,
         p_init_msg_list       => p_init_msg_list,
         x_return_status       => l_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data,
         p_tldv_rec            => lp_tldv_tbl(l_tld_loop_cnt),
         x_tldv_rec            => lx_tldv_tbl(l_tld_loop_cnt));

        lp_tldv_tbl(l_tld_loop_cnt) := lx_tldv_tbl(l_tld_loop_cnt);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
-- end: cklee -- add additional columns 3/19/07

        okl_tld_pvt.insert_row(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_tbl(l_tld_loop_cnt),
            x_tldv_rec             =>  lx_tldv_rec);
--             Assign attributes back to lx_tldv_rec along with ID;
--             Error handling;
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        lp_tldv_tbl(l_tld_loop_cnt) := lx_tldv_rec;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tldv_rec.id: '||to_char(lx_tldv_rec.id));
        END IF;

--    end if;
      End If;
      EXIT WHEN l_tld_loop_cnt = lp_tldv_tbl.LAST;
      l_tld_loop_cnt := lp_tldv_tbl.NEXT(l_tld_loop_cnt);
--         End loop;
    end loop;

-- 5. End loop;
   EXIT WHEN l_til_loop_cnt = lp_tilv_tbl.LAST;
   l_til_loop_cnt := lp_tilv_tbl.NEXT(l_til_loop_cnt);
end loop;

x_taiv_rec := lx_taiv_rec;
x_tilv_tbl := lp_tilv_tbl;
x_tldv_tbl := lp_tldv_tbl;

--gkhuntet start
            create_accounting_dist(p_api_version   => p_api_version ,
                                   p_init_msg_list => p_init_msg_list ,
                                   x_return_status => l_return_status ,
                                   x_msg_count     => x_msg_count ,
                                   x_msg_data      => x_msg_data ,
                                   p_tldv_tbl      => lp_tldv_tbl ,
                                   p_tai_id        => lx_taiv_rec.ID);

       IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
--gkhuntet end.

/*--           Increase the counter;
l_tld_loop_cnt := 0;
-- 6. Process accounting distributions;
l_tld_loop_cnt := lp_tldv_tbl.first;

loop
--FOR l_tld_loop_cnt  in  1 .. lp_tldv_tbl.count loop
  p_bpd_acc_rec.id           := lp_tldv_tbl(l_tld_loop_cnt).id;
  p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';


  /* apaul -- Code commented out because new accing API uptake not complete
  Okl_Acc_Call_Pub.CREATE_ACC_TRANS(p_api_version    =>  p_api_version,
                                    p_init_msg_list  =>  p_init_msg_list,
                                    x_return_status  =>  l_return_status,
                                    x_msg_count      =>  x_msg_count,
                                    x_msg_data       =>  x_msg_data,
                                    p_bpd_acc_rec    =>  p_bpd_acc_rec);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Acc_Call_Pub.CREATE_ACC_TRANS:p_bpd_acc_rec.id: '||to_char(p_bpd_acc_rec.id));
    END IF;

    */


    ---- Added by Vpanwar --- Code for new accounting API uptake
  /*
    Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW(p_api_version                 =>  p_api_version,
                                            p_init_msg_list             =>  p_init_msg_list,
                                            x_return_status             =>  l_return_status,
                                            x_msg_count                 =>  x_msg_count,
                                            x_msg_data                  =>  x_msg_data,
                                            p_bpd_acc_rec               =>  p_bpd_acc_rec,
                                            x_tmpl_identify_rec         =>  l_tmpl_identify_rec,
                                            x_dist_info_rec             =>  l_dist_info_rec,
                                            x_ctxt_val_tbl              =>  l_ctxt_val_tbl,
                                            x_acc_gen_primary_key_tbl   =>  l_acc_gen_primary_key_tbl);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


      --- populate the tables for passing to Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST

      l_acc_gen_tbl(l_tld_loop_cnt).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
      l_acc_gen_tbl(l_tld_loop_cnt).source_id       := l_dist_info_rec.source_id;

      l_ctxt_tbl(l_tld_loop_cnt).ctxt_val_tbl       := l_ctxt_val_tbl;
      l_ctxt_tbl(l_tld_loop_cnt).source_id          := l_dist_info_rec.source_id;

      l_tmpl_identify_tbl(l_tld_loop_cnt)           := l_tmpl_identify_rec;

      l_dist_info_tbl(l_tld_loop_cnt)               := l_dist_info_rec;

    ---- End Added by Vpanwar --- Code for new accounting API uptake


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW:p_bpd_acc_rec.id: '||to_char(p_bpd_acc_rec.id));
    END IF;

  EXIT WHEN l_tld_loop_cnt = lp_tldv_tbl.LAST;
  l_tld_loop_cnt := lp_tldv_tbl.NEXT(l_tld_loop_cnt);
end loop;

    ---- Added by Vpanwar --- Code for new accounting API uptake
    l_trx_header_tbl:= 'okl_trx_ar_invoices_b';
    l_trx_header_id := lx_taiv_rec.id;
    --Call accounting with new signature
        Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				                  p_trx_header_id      => l_trx_header_id,
                                  p_trx_header_table   => l_trx_header_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */
    ---- End Added by Vpanwar --- Code for new accounting API uptake

--    Note: Refer to okl_billing_controller_pvt.bill_streams_master for details
--

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_sel_billing_trx;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_sel_billing_trx;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_sel_billing_trx;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
end create_sel_billing_trx;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : CREATE_BILLING_TRX
-- Description     : wrapper api to create internal billing transactions
-- Business Rules  :
--                 Usage:
--                 (1) Caller pass 3 layers of billing data:
--                 -----------------------------------------
--
--                       If caller pass the following parameters with data,
--                       ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
--                       ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
--                       ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
--                       then system assume caller is intend to create stream based (with stream element)
--                       internal billing transactions.
--
--                       In this scenario, the following rules applied:
--                 R1): If p_tilv_tbl(n).TXL_AR_LINE_NUMBER exists, but p_tldv_tbl(n).TXL_AR_LINE_NUMBER
--                      doesn't exists, throw error.
--                 R2): If p_tldv_tbl(n).TXL_AR_LINE_NUMBER exists, but p_tilv_tbl(n).TXL_AR_LINE_NUMBER
--                      doesn't exists, throw error.
--
--                 Note:
--                 p_tilv_tbl(n).TXL_AR_LINE_NUMBER :
--                 User key to link between p_tilv_rec and p_tldv_tbl
--
--                 p_tldv_tbl(n).TXL_AR_LINE_NUMBER :
--                 User key to link between p_tldv_rec and p_tilv_rec
--
--                 Note: In order to process this API properly, you need to pass user enter TXL_AR_LINE_NUMBER
--                 to link between p_tilv_rec and p_tldv_tbl.
--
--                 (2) Caller pass 2 layers of billing data:
--                 -----------------------------------------
--
--                       If caller pass the following parameters with data,
--                       ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
--                       ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
--                       then system assume caller is intend to create non-stream based (without stream element)
--                       internal billing transactions.
--
--                       In this scenario, p_tilv_tbl(n).TXL_AR_LINE_NUMBER is not a required attribute.
--                       If user does pass p_tilv_tbl(n).TXL_AR_LINE_NUMBER, system will assume this is a
--                       redundant data.
--                       System will copy the major attributes (STY_ID, AMOUNT, etc) from p_tilv_rec to
--                       create record in OKL_TXD_AR_LN_DTLS_b/tl table (Internal billing invoice/invoce line)
--
--                 (3) Caller pass 1 layer of billing data:
--                 -----------------------------------------
--                       If p_tilv_tbl.count = 0, throw error.
--
--                 Note: 1. Assume all calling API will validate attributes before make the call. This is
--                       the current architecture and we will adopt all validation logic from calling API
--                       to this central API in the future.
-- Parameters      :
--
--                 p_taiv_rec: Internal billing contract transaction header (okl_trx_ar_invoices_v)
--                 p_tilv_tbl: Internal billing contract transaction line (OKL_TXL_AR_INV_LNS_V)
--                 p_tldv_tbl: Internal billing invoice/invoce line (OKL_TXD_AR_LN_DTLS_V)
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_billing_trx(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
   ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
   ,p_tldv_tbl                     IN  okl_tld_pvt.tldv_tbl_type
   ,x_taiv_rec                     OUT NOCOPY okl_tai_pvt.taiv_rec_type
   ,x_tilv_tbl                     OUT NOCOPY okl_til_pvt.tilv_tbl_type
   ,x_tldv_tbl                     OUT NOCOPY okl_tld_pvt.tldv_tbl_type
   ,p_cpl_id                       IN  NUMBER DEFAULT NULL
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'CREATE_BILLING_TRX';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_til_loop_cnt                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_taiv_rec        okl_tai_pvt.taiv_rec_type := p_taiv_rec;
  lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
  lp_tilv_tbl        okl_til_pvt.tilv_tbl_type := p_tilv_tbl;
  lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
  lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type := p_tldv_tbl;
  lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  l_taiv_id          NUMBER;
  lx_tilv_rec	       okl_til_pvt.tilv_rec_type;
  l_tld_loop_cnt     NUMBER;
  l_til_ln_number    NUMBER;
  lx_tldv_rec        okl_tld_pvt.tldv_rec_type;
  l_til_id           NUMBER;
  l_til_debug_cnt    NUMBER;
  l_tld_debug_cnt    NUMBER;
  p_bpd_acc_rec      Okl_Acc_Call_Pub.bpd_acc_rec_type;
begin
  -- Set API savepoint
  SAVEPOINT CREATE_BILLING_TRX;
     IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Taiv Parameters '||' Currency Code  :'||p_taiv_rec.currency_code||' Currency conversion type  :'||p_taiv_rec.currency_conversion_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Currency conversion rate  :'||p_taiv_rec.currency_conversion_rate||' Currency conversion date  :'||p_taiv_rec.currency_conversion_date);

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'tilv Parameters');
      IF (p_tilv_tbl.count > 0) THEN -- 6402950
      l_til_debug_cnt := p_tilv_tbl.first;
      loop
      --for l_til_debug_cnt in 1 .. p_tilv_tbl.count loop
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inv receiv line code :'||p_tilv_tbl(l_til_debug_cnt).inv_receiv_line_code);
      EXIT WHEN l_til_debug_cnt = p_tilv_tbl.LAST; -- 6402950
      l_til_debug_cnt := p_tilv_tbl.NEXT(l_til_debug_cnt);
      end loop;
      END IF;

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'tldv Parameters');
      IF (p_tldv_tbl.count > 0) THEN -- 6402950
      l_tld_debug_cnt := lp_tldv_tbl.first;  -- 6402950
      loop
      --FOR  l_tld_debug_cnt in 1 .. p_tldv_tbl.count  LOOP
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'TXL AR LINE NUMBER :'||p_tldv_tbl(l_tld_debug_cnt).TXL_AR_LINE_NUMBER);
      EXIT WHEN l_tld_debug_cnt = lp_tldv_tbl.LAST;
      l_tld_debug_cnt := lp_tldv_tbl.NEXT(l_tld_debug_cnt);
      END LOOP;
      END IF;
    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

--
-- 1. Validation
    l_return_status := validate_attributes(p_taiv_rec => lp_taiv_rec,
                                           p_tilv_tbl => lp_tilv_tbl,
                                           p_tldv_tbl => lp_tldv_tbl);

    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF G_IS_STREAM_BASED_BILLING = TRUE THEN

        create_sel_billing_trx(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_taiv_rec             =>  lp_taiv_rec,
            p_tilv_tbl             =>  lp_tilv_tbl,
            p_tldv_tbl             =>  lp_tldv_tbl,
            x_taiv_rec             =>  lx_taiv_rec,
            x_tilv_tbl             =>  lx_tilv_tbl,
            x_tldv_tbl             =>  lx_tldv_tbl);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

    ELSE

        create_non_sel_billing_trx(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_taiv_rec             =>  lp_taiv_rec,
            p_tilv_tbl             =>  lp_tilv_tbl,
            x_taiv_rec             =>  lx_taiv_rec,
-- start: cklee -- fixed return parameters issues 4/6/07
            x_tilv_tbl             =>  lx_tilv_tbl,
            x_tldv_tbl             =>  lx_tldv_tbl,
-- end: cklee -- fixed return parameters issues 4/6/07
            p_cpl_id               =>  p_cpl_id);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

    END IF;

-- start: cklee -- fixed return parameters issues 4/6/07
-- Assign to out parametrs
    x_taiv_rec := lx_taiv_rec;
    x_tilv_tbl := lx_tilv_tbl;
    x_tldv_tbl := lx_tldv_tbl;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_taiv_rec.id: '||to_char(x_taiv_rec.id));
             --OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_tilv_tbl(1).id: '||to_char(x_tilv_tbl(1).id));
             --OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_tldv_tbl(1).id: '||to_char(x_tldv_tbl(1).id));
    END IF;
-- end: cklee -- fixed return parameters issues 4/6/07

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_BILLING_TRX;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_BILLING_TRX;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_BILLING_TRX;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end CREATE_BILLING_TRX;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Get_Invoice_format
-- Description     : wrapper api to retrieve OKL invoice format type and
--                   invoice format line type
-- Business Rules  :
--  1. If passed in inf_id and sty_id matches, get the invoice_format_type and
--     invoice format line type
--  2. If passed in inf_id matches, but stream is missing, get the defaulted
--     invoice_format_type and invoice format line type
--  3 If passed in inf_id and sty_id are null, assign null to the
--    invoice_format_type and invoice format line type
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE Get_Invoice_format(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_inf_id                       IN NUMBER DEFAULT NULL
   ,p_sty_id                       IN NUMBER DEFAULT NULL
   ,x_invoice_format_type          OUT NOCOPY VARCHAR2
   ,x_invoice_format_line_type     OUT NOCOPY VARCHAR2
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'Get_Invoice_format';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR inv_format_csr ( p_format_id IN NUMBER, p_stream_id IN NUMBER ) IS
		      SELECT
		        ity.name ity_name,
				ilt.name ilt_name
	           FROM   okl_invoice_types_v     ity,
       			      okl_invc_line_types_v   ilt,
       			      okl_invc_frmt_strms_v   frs,
       			      okl_strm_type_v         sty
		      WHERE   ity.inf_id              = p_format_id
		      AND     ilt.ity_id              = ity.id
		      AND     frs.ilt_id              = ilt.id
		      AND     sty.id                  = frs.sty_id
		      AND	  frs.sty_id		      = p_stream_id;

    CURSOR inv_format_default_csr ( p_format_id IN NUMBER ) IS
	 	     SELECT
            	ity.name ity_name,
    			ilt.name ilt_name
       		 FROM    okl_invoice_types_v     ity,
            		 okl_invc_line_types_v   ilt
    		 WHERE   ity.inf_id             = p_format_id
    		 AND     ilt.ity_id             = ity.id;

begin
  -- Set API savepoint
  SAVEPOINT Get_Invoice_format;
     IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_inf_id :'||p_inf_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_sty_id :'||p_sty_id);

    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

  IF p_inf_id IS NOT NULL and p_sty_id IS NOT NULL THEN

    OPEN inv_format_csr ( p_inf_id, p_sty_id);
--start:|  08-Mar-2005 cklee -- Fixed Get_Invoice_format logic error                 |
    FETCH inv_format_csr INTO x_invoice_format_type, x_invoice_format_line_type;
--end:|  08-Mar-2005 cklee -- Fixed Get_Invoice_format logic error                 |
    CLOSE inv_format_csr;

  ELSIF p_inf_id IS NOT NULL and p_sty_id IS NULL THEN

    OPEN inv_format_default_csr ( p_inf_id);
--start:|  08-Mar-2005 cklee -- Fixed Get_Invoice_format logic error                 |
    FETCH inv_format_default_csr INTO x_invoice_format_type, x_invoice_format_line_type;
--endt:|  08-Mar-2005 cklee -- Fixed Get_Invoice_format logic error                 |
    CLOSE inv_format_default_csr;

  ELSE

    x_invoice_format_type := NULL;
    x_invoice_format_line_type := NULL;

  END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO Get_Invoice_format;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_Invoice_format;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO Get_Invoice_format;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end Get_Invoice_format;



-- Start of comments

  -- API name       : update_manual_invoice
  -- Pre-reqs       : None
  -- Function       :  It is Used to Update header in TAI and Insert/Update line
  --                    in TIL/TLD. And if the trx_status_code is submitted then
  --                    make a accounting call for all TLD records.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_taiv_rec - Record type for OKL_TRX_AR_INVOICES_B.
  --                  p_tilv_tbl -- Table type for OKL_TXL_AR_INV_LNS_B.
  -- Version        : 1.0
  -- History        : gkhuntet created.
-- End of comments

PROCEDURE  update_manual_invoice(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN  okl_tai_pvt.taiv_rec_type
   ,p_tilv_tbl                     IN  okl_til_pvt.tilv_tbl_type
   ,x_taiv_rec                     OUT NOCOPY okl_tai_pvt.taiv_rec_type
   ,x_tilv_tbl                     OUT NOCOPY okl_til_pvt.tilv_tbl_type
   ,x_tldv_tbl                     OUT NOCOPY okl_tld_pvt.tldv_tbl_type
)
IS

  l_api_name         CONSTANT VARCHAR2(30) := 'update_manual_invoice';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_til_loop_cnt     NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_taiv_rec        okl_tai_pvt.taiv_rec_type := p_taiv_rec;
  lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
  lp_tilv_tbl        okl_til_pvt.tilv_tbl_type := p_tilv_tbl;
  lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
  lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
  l_taiv_id          NUMBER;
  lx_tilv_rec	     okl_til_pvt.tilv_rec_type;
  l_tld_loop_cnt     NUMBER;
  l_til_ln_number    NUMBER;
  lx_tldv_rec        okl_tld_pvt.tldv_rec_type;
  l_til_id           NUMBER;
  til_id             NUMBER;
  i                  NUMBER DEFAULT 0;
  crt_count            NUMBER := 0;
  updt_count           NUMBER := 0;
  l_tilv_Updt_tbl   okl_til_pvt.tilv_tbl_type;
  l_tilv_Crt_tbl    okl_til_pvt.tilv_tbl_type;
  l_flag_acc_call             VARCHAR2(5);

  CURSOR get_tld_csr(p_til_id_details okl_txd_ar_ln_dtls_b.TIL_ID_DETAILS%TYPE) IS
    SELECT ID  FROM OKL_TXD_AR_LN_DTLS_B
    WHERE  TIL_ID_DETAILS = p_til_id_details;




BEGIN

   SAVEPOINT UPDATE_MANUAL_INVOICE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Validating the TAI Attributes.
    validate_tai_values(
              p_taiv_rec       => lp_taiv_rec,
              x_return_status  => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Updating the TAI table.
    okl_tai_pvt.update_row(
    p_api_version         => p_api_version,
    p_init_msg_list       => p_init_msg_list,
    x_return_status       => l_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_taiv_rec            => lp_taiv_rec,
    x_taiv_rec            => lx_taiv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_taiv_rec.id: '||to_char(lx_taiv_rec.id));
    END IF;
    x_taiv_rec := lx_taiv_rec;
    -- Delete TIL record and correspondingly its TLD record which is not coming in p_tilv_tbl.


    --TO filter the insert and update record from the the lp_tilv_tbl.
    FOR i IN lp_tilv_tbl.FIRST .. lp_tilv_tbl.LAST LOOP
        IF (lp_tilv_tbl(i).id = OKL_API.G_MISS_NUM or
                lp_tilv_tbl(i).id IS NULL) THEN
                l_tilv_Crt_tbl(crt_count) := lp_tilv_tbl(i);
                crt_count := crt_count + 1;
        ELSE
           l_tilv_Updt_tbl(updt_count) := lp_tilv_tbl(i);
           updt_count := updt_count + 1;
        END IF;
    END LOOP;

 /*****  Update the TIL records and correspondingly its TLD record. *****/
    FOR i IN l_tilv_Updt_tbl.FIRST .. l_tilv_Updt_tbl.LAST LOOP

       okl_til_pvt.update_row(
                      p_api_version    => p_api_version ,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => l_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_tilv_rec       => l_tilv_Updt_tbl(i),
                      x_tilv_rec       => lx_tilv_rec);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
           END IF;
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

      --Run the Cursor that query record from the TLD on the basis l_tilv_Updt_tbl(i).id
      -- Which is TIL_ID_Details in the TLD table.
      OPEN get_tld_csr(l_tilv_Updt_tbl(i).ID);
      FETCH get_tld_csr INTO til_id;
      CLOSE get_tld_csr;

/***
-- Developer Note:
-- 1. For each TIL record, copy STY_ID, AMOUNT, ORG_ID, INVENTORY_ORG_ID, INVENTORY_ITEM_ID
--    to TLD pl/sql record and call okl_tld_pvt.insert_row() to create TLD.
-- 2. lx_tilv_rec.TXL_AR_LINE_NUMBER is not required for this procesdure
***/
        lp_tldv_tbl(i).ID :=  til_id;
        lp_tldv_tbl(i).STY_ID := lx_tilv_rec.STY_ID;
        lp_tldv_tbl(i).AMOUNT := lx_tilv_rec.AMOUNT; -- this is 2 level, so we need to copy to tld
        lp_tldv_tbl(i).ORG_ID := lx_tilv_rec.ORG_ID;
        lp_tldv_tbl(i).INVENTORY_ORG_ID := lx_tilv_rec.INVENTORY_ORG_ID;
        lp_tldv_tbl(i).INVENTORY_ITEM_ID := lx_tilv_rec.INVENTORY_ITEM_ID;
        --lp_tldv_tbl(i).LINE_DETAIL_NUMBER := l_til_loop_cnt;
        lp_tldv_tbl(i).KHR_ID := lp_taiv_rec.KHR_ID;
        lp_tldv_tbl(i).KLE_ID := lx_tilv_rec.KLE_ID;

        okl_tld_pvt.update_row(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_tbl(i),
            x_tldv_rec             =>  lx_tldv_rec);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
   END LOOP;
 /***** Updation Completed in TIL and TLD *****/


  l_flag_acc_call := 'Y';
   IF(lx_taiv_rec.okl_source_billing_trx = G_MANUAL
      AND lx_taiv_rec. trx_status_code <> 'SUBMITTED') THEN
        l_flag_acc_call := 'N';
   END IF;



   -- Make Accounting call for all Updated records if the trx_status_code != 'SUBMITTED'
   IF(lp_tldv_tbl.COUNT > 0 ) THEN
        IF(l_flag_acc_call = 'Y') THEN
            create_accounting_dist(p_api_version   => p_api_version ,
                                   p_init_msg_list => p_init_msg_list ,
                                   x_return_status => l_return_status ,
                                   x_msg_count     => x_msg_count ,
                                   x_msg_data      => x_msg_data ,
                                   p_tldv_tbl      => lp_tldv_tbl ,
                                   p_tai_id        => lx_taiv_rec.ID
                                   );
       END IF;
       IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
   END IF;



 /*****  Insert into TIL records and correspondingly its TLD record. *****/

   lp_tldv_tbl.delete;

   IF(l_tilv_Crt_tbl.COUNT > 0) THEN
     FOR i IN l_tilv_Crt_tbl.FIRST .. l_tilv_Crt_tbl.LAST LOOP
        --  Assign lx_taiv_rec.ID to lp_til_rec.TAI_ID;
         l_tilv_Crt_tbl(i).TAI_ID := lx_taiv_rec.ID;
         l_tilv_Crt_tbl(i).ORG_ID := lx_taiv_rec.org_id;

         additional_til_attr(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_tilv_rec            => l_tilv_Crt_tbl(i),
          x_tilv_rec            => lx_tilv_tbl(i));

          l_tilv_Crt_tbl(i) := lx_tilv_tbl(i);

          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      x_return_status := l_return_status;
                END IF;
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;


            -- Create okl_TXL_AR_INV_LNS_B record: okl_til_pvt.insert_row;
         okl_til_pvt.insert_row(
                p_api_version          => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => l_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_tilv_rec             => l_tilv_Crt_tbl(i),
                x_tilv_rec             => lx_tilv_rec);
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
          END IF;
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tilv_rec.id: '||to_char(lx_tilv_rec.id));
        END IF;

-- l_til_ln_number := lx_tilv_rec.TXL_AR_LINE_NUMBER;
      l_til_id        := lx_tilv_rec.id;
/***
-- Developer Note:
-- 1. For each TIL record, copy STY_ID, AMOUNT, ORG_ID, INVENTORY_ORG_ID, INVENTORY_ITEM_ID
--    to TLD pl/sql record and call okl_tld_pvt.insert_row() to create TLD.
-- 2. lx_tilv_rec.TXL_AR_LINE_NUMBER is not required for this procesdure
--
***/
        lp_tldv_tbl(i).TIL_ID_DETAILS := l_til_id;
        lp_tldv_tbl(i).STY_ID := lx_tilv_rec.STY_ID;
        lp_tldv_tbl(i).AMOUNT := lx_tilv_rec.AMOUNT; -- this is 2 level, so we need to copy to tld
        lp_tldv_tbl(i).ORG_ID := lx_tilv_rec.ORG_ID;
        lp_tldv_tbl(i).INVENTORY_ORG_ID := lx_tilv_rec.INVENTORY_ORG_ID;
        lp_tldv_tbl(i).INVENTORY_ITEM_ID := lx_tilv_rec.INVENTORY_ITEM_ID;
        lp_tldv_tbl(i).LINE_DETAIL_NUMBER := i;
        lp_tldv_tbl(i).KHR_ID := lx_taiv_rec.KHR_ID;
        lp_tldv_tbl(i).KLE_ID := lx_tilv_rec.KLE_ID;

        Get_Invoice_format(
             p_api_version                  => p_api_version
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data
            ,p_inf_id                       => lp_taiv_rec.inf_id
            ,p_sty_id                       => lp_tldv_tbl(i).STY_ID
            ,x_invoice_format_type          => lp_tldv_tbl(i).invoice_format_type
            ,x_invoice_format_line_type     => lp_tldv_tbl(i).invoice_format_line_type);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        additional_tld_attr(
         p_api_version         => p_api_version,
         p_init_msg_list       => p_init_msg_list,
         x_return_status       => l_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data,
         p_tldv_rec            => lp_tldv_tbl(i),
         x_tldv_rec            => lx_tldv_tbl(i));

         lp_tldv_tbl(i) := lx_tldv_tbl(i);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        okl_tld_pvt.insert_row(
            p_api_version          =>  p_api_version,
            p_init_msg_list        =>  p_init_msg_list,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_tbl(i),
            x_tldv_rec             =>  lx_tldv_rec);

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
       -- lp_tldv_tbl(l_til_loop_cnt) := lx_tldv_rec;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tldv_rec.id: '||to_char(lx_tldv_rec.id));
        END IF;

  END LOOP;
END IF;
/***** Insertion completed in TIL and TLD *****/

   l_flag_acc_call := 'Y';
   IF(lx_taiv_rec.okl_source_billing_trx = G_MANUAL
      AND lx_taiv_rec. trx_status_code <> 'SUBMITTED') THEN
        l_flag_acc_call := 'N';
   END IF;


  -- Make Accounting call for all inserted records if the trx_status_code = 'SUBMITTED'
   IF(lp_tldv_tbl.COUNT > 0 ) THEN
        IF(l_flag_acc_call = 'Y') THEN
            create_accounting_dist(p_api_version   => p_api_version ,
                                   p_init_msg_list => p_init_msg_list ,
                                   x_return_status => l_return_status ,
                                   x_msg_count     => x_msg_count ,
                                   x_msg_data      => x_msg_data ,
                                   p_tldv_tbl      => lp_tldv_tbl ,
                                   p_tai_id        => lx_taiv_rec.ID
                                   );
       END IF;
       IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
   END IF;


-- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO UPDATE_MANUAL_INVOICE;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_MANUAL_INVOICE;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO UPDATE_MANUAL_INVOICE;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);


END update_manual_invoice;



-- Start of comments

  -- API name       : delete_manual_invoice
  -- Pre-reqs       : None
  -- Function       :  It is Used to delete the TAI , TIL ,TLD records.
  --                   Either p_taiv_id or p_tilv_id should be passed.
  --                   If p_taiv_id is passed then delete TAI ,all TIL of TAI and all TLD of TIL records.
  --                   And If p_tilv_id is passed then delete TIL and all TLD of TIL.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_taiv_id - ID of OKL_TRX_AR_INVOICES_B.
  --                  p_tilv_id -- ID of OKL_TXL_AR_INV_LNS_B.
  -- Version        : 1.0
  -- History        : gkhuntet created.
-- End of comments

PROCEDURE  delete_manual_invoice(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_id                      NUMBER
   ,p_tilv_id                      NUMBER
)
IS

  l_api_name         CONSTANT VARCHAR2(30) := 'update_manual_invoice';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_til_loop_cnt     NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_tai_id  OKL_TRX_AR_INVOICES_B.ID%TYPE :=p_taiv_id;
  lp_til_id  OKL_TXL_AR_INV_LNS_B.ID%TYPE  :=p_tilv_id;
  l_tai_id  OKL_TRX_AR_INVOICES_B.ID%TYPE;
  l_til_id  OKL_TXL_AR_INV_LNS_B.ID%TYPE ;
  l_til_id  OKL_TXD_AR_LN_DTLS_B.ID%TYPE ;
  l_taiv_rec okl_tai_pvt.taiv_rec_type;
  l_tilv_rec okl_til_pvt.tilv_rec_type;
  l_tldv_rec okl_tld_pvt.tldv_rec_type;

CURSOR get_til_dtl_csr  IS
SELECT  ID til_id
FROM OKL_TXL_AR_INV_LNS_B
WHERE TAI_ID = p_taiv_id;

get_til_dtl_rec   get_til_dtl_csr%rowtype;

CURSOR get_tld_dtl_csr (g_til_id OKL_TXL_AR_INV_LNS_B.ID%TYPE) IS
SELECT  ID tld_id
FROM OKL_TXD_AR_LN_DTLS_B
WHERE TIL_ID_DETAILS = g_til_id;

get_tld_dtl_rec get_tld_dtl_csr%rowtype;



BEGIN
SAVEPOINT DELETE_MANUAL_INVOICE ;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  -- IF lp_taiv_id is not null then delete TAI , TIL and TLD records else TIL and TLD.
    IF lp_tai_id IS NOT NULL THEN
        --Retrive all the TIL Records.
        FOR get_til_dtl_rec in get_til_dtl_csr
        LOOP
            l_tilv_rec.id  := get_til_dtl_rec.til_id;
            --Retrive all the TLD Records for a l_tilv_rec.id.
             FOR get_tld_dtl_rec in get_tld_dtl_csr(l_tilv_rec.id )
             LOOP
                   l_tldv_rec.id := get_tld_dtl_rec.tld_id;
                    --Delete a TLD Record.
                   OKL_TLD_PVT.delete_row(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => l_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_tldv_rec      => l_tldv_rec
                                          );
                    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                x_return_status := l_return_status;
                          END IF;
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    END IF;

             END LOOP; --End loop for TLD
                      --Delete a TIL Record.
                     OKL_TIL_PVT.delete_row(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => l_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_tilv_rec      => l_tilv_rec
                                          );
                      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                              IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                    x_return_status := l_return_status;
                              END IF;
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      END IF;

        END LOOP;--End loop for TIL.
         --Delete a TAI Record.
        l_taiv_rec.id := lp_tai_id;
        OKL_TAI_PVT.delete_row(p_api_version   => p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               x_return_status => l_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_taiv_rec      => l_taiv_rec);
         IF(l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              x_return_status := l_return_status;
                   END IF;
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

   ELSIF lp_til_id IS NOT NULL THEN -- Delete a TIL Rccord and all its TLD Records.
          FOR get_tld_dtl_rec in get_tld_dtl_csr(lp_til_id)
          LOOP
                   l_tldv_rec.id := get_tld_dtl_rec.tld_id;
                   --Delete a TLD Record.
                   OKL_TLD_PVT.delete_row(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => l_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_tldv_rec      => l_tldv_rec
                                          );
                   IF(l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                    x_return_status := l_return_status;
                             END IF;
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   END IF;

          END LOOP; --End loop for TLD.
                  l_tilv_rec.id := lp_til_id;
                   --Delete a TIL Record.
                  OKL_TIL_PVT.delete_row(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => l_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_tilv_rec      => l_tilv_rec
                                          );
                 IF(l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                    x_return_status := l_return_status;
                             END IF;
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 END IF;

   END IF ;



-- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO DELETE_MANUAL_INVOICE;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_MANUAL_INVOICE;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO DELETE_MANUAL_INVOICE;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);



END delete_manual_invoice;



END OKL_INTERNAL_BILLING_PVT;

/
