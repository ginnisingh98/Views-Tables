--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MEMO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MEMO_PVT" AS
/* $Header: OKLRCRMB.pls 120.15 2008/02/27 09:29:25 veramach noship $ */

  ------------------------------------------------------------------------------
  -- FUNCTION get_try_id
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Private Procedure to retrieve ID of a given Transaction Type
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------
     --cust_acct_site_id			          okx_cust_site_uses_v.cust_acct_site_id%TYPE;


    CURSOR line_bill_to_csr(p_khr_id NUMBER, p_kle_id NUMBER) IS
        SELECT cs.cust_acct_site_id  --, cp.standard_terms payment_term_id
        FROM okc_k_headers_b khr
           , okx_cust_site_uses_v cs
           , okc_k_lines_b cle
          , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle.chr_id IS NOT NULL
        AND cle.id = p_kle_id
        AND cle.BILL_TO_SITE_USE_ID = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+)
        UNION
        SELECT cs.cust_acct_site_id --, cp.standard_terms payment_term_id
        FROM okc_k_headers_b khr
           , okc_k_lines_b cle
           , okc_k_items item
           , okc_k_lines_b linked_asset
           , okx_cust_site_uses_v cs
          , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle.id = p_kle_id
        AND cle.chr_id IS NULL
        AND cle.id = item.cle_id
        AND item.object1_id1 = linked_asset.id
        AND linked_asset.BILL_TO_SITE_USE_ID = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+);

     CURSOR cust_acct_csr (p_khr_id NUMBER) IS
        SELECT cs.cust_acct_site_id
        --     , cp.standard_terms payment_term_id
        FROM okc_k_headers_v khr
           , okx_cust_site_uses_v cs
           , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND khr.bill_to_site_use_id = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+);



  FUNCTION get_try_id (p_try_name IN VARCHAR2) RETURN NUMBER IS

    CURSOR c_try IS
      SELECT  id
      FROM    okl_trx_types_tl
      WHERE   name = p_try_name
        AND   language = 'US';

    l_try_id      NUMBER;

  BEGIN

    OPEN c_try;
    FETCH c_try INTO l_try_id;
    CLOSE c_try;

    RETURN  l_try_id;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_try_id;


  ------------------------------------------------------------------------------
  -- FUNCTION get_pdt_id
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Private Procedure to retrieve Product ID of a given Contract
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_pdt_id (p_khr_id IN VARCHAR2) RETURN NUMBER IS

    CURSOR c_pdt IS
      SELECT  pdt_id
      FROM    okl_k_headers
      WHERE   id = p_khr_id;

    l_pdt_id      NUMBER;

  BEGIN

    OPEN c_pdt;
    FETCH c_pdt INTO l_pdt_id;
    CLOSE c_pdt;

    RETURN  l_pdt_id;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_pdt_id;


  ------------------------------------------------------------------------------
  -- FUNCTION get_factor_synd
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Returns NULL if Contract is neither syndicated nor factored.  Ortherwise returns
    --  the appropriate value.
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_factor_synd(p_khr_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR c_synd IS
        SELECT
          'SYNDICATION'
        FROM
          okc_k_headers_b chr
        WHERE
          EXISTS ( SELECT 'x' FROM okc_k_items cim
                        WHERE  cim.object1_id1 = to_char(chr.id) AND
          EXISTS ( SELECT 'x' FROM okc_k_lines_b cle, okc_line_styles_b  lse
                        WHERE  cle.lse_id = lse.id AND
          lse.lty_code = 'SHARED' AND cle.id = cim.cle_id ) AND
          EXISTS ( SELECT 'x' FROM okc_k_headers_b chr2
                        WHERE  chr2.id = cim.dnz_chr_id AND
          chr2.scs_code = 'SYNDICATION'                     AND
          chr2.sts_code not in  ('TERMINATED','ABANDONED') ) ) AND
          chr.scs_code = 'LEASE' AND
          id = p_khr_id;

    CURSOR c_fact IS
        select '1'
        from   okc_rules_b
        where  dnz_chr_id  = p_khr_id
        and    rule_information_category = 'LAFCTG'
        and    (rule_information1 is not null
        or      rule_information2 is not null
        or      rule_information3 is not null);
/*
 -- This check for Factoring and Syndication is not correct.
 -- so changed the queries as above.
 -- rvaduri
    CURSOR c_synd IS
       SELECT scs_code
       FROM   okc_k_headers_b
       WHERE  scs_code = 'SYNDICATION'
         AND  id = p_khr_id;

    CURSOR c_fact IS
       SELECT '1'
       FROM   okc_rules_b
       WHERE  dnz_chr_id = p_khr_id
         AND  rule_information_category = 'LAFCTG';
 */
    l_contract_type   VARCHAR2(30);

  BEGIN

    OPEN c_synd;
    FETCH c_synd INTO l_contract_type;
    CLOSE c_synd;

    IF l_contract_type IS NOT NULL THEN
      RETURN  l_contract_type;
    END IF;

    OPEN c_fact;
    FETCH c_fact INTO l_contract_type;
    CLOSE c_fact;

    IF l_contract_type IS NOT NULL THEN
      l_contract_type := 'FACTORING';
      RETURN  l_contract_type;
    END IF;

    RETURN NULL;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_factor_synd;

  -----------------------------------------------------------------------------------------------
  -- Procedure insert_request to insert a credit memo request
  -----------------------------------------------------------------------------------------------
  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           --p_lsm_id                  IN          NUMBER, -- Bug 5897792
                           p_tld_id                  IN          NUMBER,
                           p_credit_amount           IN          NUMBER,
                           p_credit_sty_id           IN          NUMBER,
                           p_credit_desc             IN          VARCHAR2,
                           p_credit_date             IN          DATE,
                           p_try_id                  IN          NUMBER,
-- Bug 5897792
                           p_transaction_source      IN          VARCHAR2 DEFAULT NULL,
                           p_source_trx_number       IN          VARCHAR2 DEFAULT NULL,
--  Bug 5897792

                           x_tai_id                  OUT NOCOPY  NUMBER,
                           x_taiv_rec                OUT NOCOPY  taiv_rec_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2) IS

    CURSOR c_3LevelInvoice IS

      SELECT  tai.set_of_books_id           set_of_books_id,
              tai.currency_code             currency_code,
              tai.ixx_id                    ixx_id,
            --tai.customer_address_id       ibt_id,
              tai.irm_id                     irm_id,
              tai.irt_id                    irt_id,
              tai.org_id                    org_id,
              tai.id                        tai_id_reverses,
              tai.khr_id                    khr_id,
              tai.legal_entity_id           legal_entity_id ,
              tai.date_invoiced             date_invoiced,
              til.id                        til_id_reverses,
              til.kle_id                    kle_id,
              tld.id                        tld_id_reverses,
              tld.sty_id                    sty_id,
              tld.til_id_details            til_id_details,
              tld.sel_id                    sel_id -- 6237730
      FROM
              okl_txd_ar_ln_dtls_b          tld,
              okl_txl_ar_inv_lns_b          til,
              okl_trx_ar_invoices_b         tai
      WHERE   tai.id                      = til.tai_id
      AND     til.id                      = tld.TIL_ID_DETAILS
    --AND     tld.lsm_id                  = p_tld_id;
      AND   (  tld.lsm_id                 = p_tld_id
      OR     tld.id                       = p_tld_id);

   CURSOR c_2LevelInvoice IS

      SELECT  tai.set_of_books_id           set_of_books_id,
              tai.currency_code             currency_code,
              tai.ixx_id                    ixx_id,
           -- tai.customer_address_id       ibt_id,
              tai.irm_id                    irm_id,
              tai.irt_id                    irt_id,
              tai.org_id                    org_id,
              tai.id                        tai_id_reverses,
              tai.khr_id                    khr_id,
              tai.legal_entity_id           legal_entity_id ,
              tai.date_invoiced             date_invoiced,
              til.id                        til_id_reverses,
              til.kle_id                    kle_id,
              til.sty_id                    sty_id
      FROM
              okl_txd_ar_ln_dtls_b          tld,
              okl_txl_ar_inv_lns_b          til,
              okl_trx_ar_invoices_b         tai
      WHERE   tai.id                      = til.tai_id
      AND     til.id                      = tld.TIL_ID_DETAILS
      --AND     tld.lsm_id                  = p_tld_id;
      AND   (  tld.lsm_id                 = p_tld_id
      OR     tld.id                       = p_tld_id);


    --dkagrawa added cursor to derive le_id
    /*CURSOR c_legal_entity_id IS
    SELECT cnr.legal_entity_id
    FROM okl_cnsld_ar_strms_b lsm,
         okl_cnsld_ar_lines_b lln,
	 okl_cnsld_ar_hdrs_b cnr
    WHERE lsm.lln_id = lln.id
    AND lln.cnr_id = cnr.id
    AND lsm.id = p_lsm_id;*/ -- Bug 5897792
    CURSOR c_legal_entity_id IS
    SELECT trx.legal_entity_id
    FROM okl_txd_ar_ln_dtls_b tld,
         okl_txl_ar_inv_lns_b til,
	 okl_trx_ar_invoices_b trx
    WHERE tld.til_id_details = til.id
    AND til.tai_id = trx.id
    AND tld.id = p_tld_id;

    v_3LevelInvoiceRec c_3LevelInvoice%ROWTYPE;
    v_2LevelInvoiceRec c_2LevelInvoice%ROWTYPE;

    -- Transaction headers
    i_taiv_rec      okl_trx_ar_invoices_pub.taiv_rec_type;
    r_taiv_rec      okl_trx_ar_invoices_pub.taiv_rec_type;

    -- Transaction lines
    i_tilv_rec      okl_txl_ar_inv_lns_pub.tilv_rec_type;
  --r_tilv_rec      okl_txl_ar_inv_lns_pub.tilv_rec_type;


    -- Transaction line details
    i_tldv_rec      okl_txd_ar_ln_dtls_pub.tldv_rec_type;
  --r_tldv_rec      okl_txd_ar_ln_dtls_pub.tldv_rec_type;

    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

 /*  --Accounting engine wrapper records.
    l_bpd_acc_rec 		             Okl_Acc_Call_Pub.bpd_acc_rec_type;
    -- OKL Accouting Engine Records
    l_tmpl_identify_rec             OKL_ACCOUNT_DIST_PUB.TMPL_IDENTIFY_REC_TYPE;
    l_dist_info_rec                 OKL_ACCOUNT_DIST_PUB.DIST_INFO_REC_TYPE;
    l_ctxt_val_tbl                  OKL_ACCOUNT_DIST_PUB.CTXT_VAL_TBL_TYPE;
    l_acc_gen_primary_key_tbl       OKL_ACCOUNT_DIST_PUB.ACC_GEN_PRIMARY_KEY;
    lx_template_tbl                 OKL_ACCOUNT_DIST_PUB.AVLV_TBL_TYPE;
    lx_amount_tbl                   OKL_ACCOUNT_DIST_PUB.AMOUNT_TBL_TYPE;*/

    l_try_id            NUMBER;
    l_sty_id            NUMBER;
    l_khr_id            NUMBER;
    l_pdt_id            NUMBER;
    l_factoring_synd    VARCHAR2(30);
    l_source_id         NUMBER;
    l_source_table      VARCHAR2(30);

    -- local parameters
    l_api_version       CONSTANT NUMBER      := 1;
    l_init_msg_list     CONSTANT CHAR        := 'F';
    l_return_status     VARCHAR2(1);
    l_line_number       NUMBER               := 1;

  BEGIN

    -------------------------------------------------------------------------
    -- Preparing Transaction Header (one record for each credit memo request)
    -------------------------------------------------------------------------

    l_try_id := p_try_id;

    IF l_try_id IS NULL THEN

      l_try_id := get_try_id( 'Credit Memo');

      IF l_try_id IS NULL THEN

        OKL_API.set_message(p_app_name      =>  G_APP_NAME,
                            p_msg_name      =>  'OKL_TRY_ID_NOT_FOUND',
                            p_token1        =>  'TRY_NAME',
                            p_token1_value  =>  'Credit Memo');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

    END IF;

    i_taiv_rec.try_id         := l_try_id;
    i_taiv_rec.date_entered   := TRUNC(SYSDATE);
    i_taiv_rec.description    := NVL(p_credit_desc, 'OKL Credit Memo');

    -- Only records with status SUBMITTED are processed
    -- Use ENTERED or WORKING to temporarily prevent processing
    -- See lookup_type OKL_TRANSACTION_STATUS for the full list of Status Codes
    -- Status code after processing will either be PROCESSED or ERROR

    i_taiv_rec.trx_status_code      := 'SUBMITTED';

    -- Amount must equal to sum of all lines (til records)
    i_taiv_rec.amount   := p_credit_amount;

    --dkagrawa added following code to populate legal_entity_id
    OPEN c_legal_entity_id;
    FETCH c_legal_entity_id INTO i_taiv_rec.legal_entity_id;
    CLOSE c_legal_entity_id;

    OPEN c_3LevelInvoice;
    FETCH c_3LevelInvoice INTO v_3LevelInvoiceRec;

    IF c_3LevelInvoice%FOUND THEN

      i_taiv_rec.khr_id           := v_3LevelInvoiceRec.khr_id;

      -- To populate Customer_Address_Id(IBT_ID) from cursor line_bill_to_csr
      -- If it returns null then populate from cust_acct_csr.
      OPEN line_bill_to_csr(i_taiv_rec.khr_id  ,v_3LevelInvoiceRec.kle_id );
      FETCH line_bill_to_csr INTO i_taiv_rec.ibt_id;
      CLOSE line_bill_to_csr;

      IF (i_taiv_rec.ibt_id IS NULL) THEN
          OPEN cust_acct_csr(i_taiv_rec.khr_id);
          FETCH cust_acct_csr INTO i_taiv_rec.ibt_id;
          CLOSE cust_acct_csr;
     --gkhuntet 26-07-2007 start.
     /* ELSE
            OKL_API.set_message(p_app_name      =>  G_APP_NAME,
                            p_msg_name      =>  'OKL_TRY_ID_NOT_FOUND',
                            p_token1        =>  'TRY_NAME',
                            p_token1_value  =>  'Credit Memo');

        RAISE OKL_API.G_EXCEPTION_ERROR;*/
     --gkhuntet 26-07-2007 end.
      END IF;

      ---------------------------------------------
      -- These columns need not be provided if khr_id is set
      -- because they will extracted from contract rules.
      -- These values must be provided if:
      -- 1. Credit goes to an account other than the invoiced account
      -- 2. The invoice being credited was not for any contract
      ---------------------------------------------
      i_taiv_rec.set_of_books_id  := v_3LevelInvoiceRec.set_of_books_id;
      i_taiv_rec.currency_code    := v_3LevelInvoiceRec.currency_code;
      i_taiv_rec.ixx_id           := v_3LevelInvoiceRec.ixx_id;  -- customer
      i_taiv_rec.irm_id           := v_3LevelInvoiceRec.irm_id;  -- payment method
      i_taiv_rec.irt_id           := v_3LevelInvoiceRec.irt_id;  -- payment term
      i_taiv_rec.org_id           := v_3LevelInvoiceRec.org_id;
      i_taiv_rec.tai_id_reverses  := v_3LevelInvoiceRec.tai_id_reverses;
      i_taiv_rec.legal_entity_id  := v_3LevelInvoiceRec.legal_entity_id;
      --Done this fix for bug 3816891, Passing the p_credit_date instead
      -- of date_invoiced to the API
      --i_taiv_rec.date_invoiced    := v_3LevelInvoiceRec.date_invoiced;
      --i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
      --Done this fix for bug:5171202,passing date invoiced if the date invoiced is greater than
      --sysdate and creates the credit memo form lease center only
      IF i_taiv_rec.description = 'OKL Credit Memo' AND v_3LevelInvoiceRec.date_invoiced > SYSDATE THEN
        i_taiv_rec.date_invoiced    := v_3LevelInvoiceRec.date_invoiced;
      ELSE
        i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
      END IF;

      ----------------------------------------------------------------------------------
      -- Not required for the Credit Process but may be useful to other functional areas
      ----------------------------------------------------------------------------------
      i_taiv_rec.cra_id           := NULL;  -- OKL_CURE_REP_AMTS_V
      i_taiv_rec.qte_id           := NULL;  -- OKL_TRX_QUOTES_V
      i_taiv_rec.tcn_id           := NULL;  -- OKL_TRX_CONTRACTS
      i_taiv_rec.svf_id           := NULL;  -- OKL_SERVICE_FEES_V
      i_taiv_rec.ipy_id           := NULL;  -- OKL_INS_POLICIES_V
      i_taiv_rec.tap_id           := NULL;  -- OKL_TRX_AP_INVOICES_V -- vendor bills

     --gkhuntet 26-07-07 start	.
      i_taiv_rec.okl_source_billing_trx  := p_transaction_source;
      --gkhuntet 26-07-07 end.

      ---------------------------------------------------------------------
      -- Prepare Transaction line (one record for each credit memo request)
      ---------------------------------------------------------------------
      i_tilv_rec.ibt_id                 := i_taiv_rec.ibt_id;
      i_tilv_rec.kle_id                 := v_3LevelInvoiceRec.kle_id;
      i_tilv_rec.line_number            := l_line_number;
      --i_tilv_rec.tai_id                 := r_taiv_rec.id;
      i_tilv_rec.description            := NVL(p_credit_desc, 'OKL Credit Memo');
      i_tilv_rec.til_id_reverses        := v_3LevelInvoiceRec.til_id_reverses;
      i_taiv_rec.legal_entity_id        := v_3LevelInvoiceRec.legal_entity_id;

      -- this field is passed as invoice description in AR
      -- you can actually put 'LINE' or 'CHARGE'
      -- 'CHARGE' is used for financial charges and has some accounting
      -- implications in AR; till further notice please always use LINE
      i_tilv_rec.inv_receiv_line_code := 'LINE';

      -- Same as Header amount (1 line per header)
      i_tilv_rec.amount   := p_credit_amount;

      -- every billing item must have stream type;
      -- it will be used for accrual, billing and consolidation;
      -- make sure Susan has your stream type on the list
      -- i_tilv_rec.sty_id   := your_stream_type_id;  -- only needed for 2 level insert

      ----------------------------------------------------------------------------------
      -- Not required for the Credit Process but may be useful to other functional areas
      ----------------------------------------------------------------------------------
      i_tilv_rec.acn_id_cost            := NULL;    -- OKL_ASSET_CNDTN_LNS_V
      i_tilv_rec.tpl_id                 := NULL;    -- OKL_TXL_AP_INV_LNS_V - for vendor bills
      i_tilv_rec.date_bill_period_end   := NULL;    -- For Variable Interest use only
      i_tilv_rec.date_bill_period_start := NULL;    -- For Variable Interest use only
      i_tilv_rec.quantity               := NULL;    -- No need for value since we don't use PO
      i_tilv_rec.org_id                 := NULL;
      i_tilv_rec.TXL_AR_LINE_NUMBER     := 1; -- 6237730

      lp_tilv_tbl(0) := i_tilv_rec;

      -- 3rd level insert
      ----------------------------------------------------
      -- Populate required columns
      ----------------------------------------------------

      -- Same as Line amount (1 sub-line per line)
      i_tldv_rec.amount               := p_credit_amount;

      i_tldv_rec.description          := NVL(p_credit_desc, 'OKL Credit Memo');
   -- i_tldv_rec.til_id_details       := r_tilv_rec.id;
      i_tldv_rec.line_detail_number   := l_line_number;
      i_tldv_rec.tld_id_reverses      := v_3LevelInvoiceRec.tld_id_reverses;

	-- gkhuntet 26-07-07 start.
      i_tldv_rec.TXL_AR_LINE_NUMBER     := 1;
  	-- gkhuntet 26-07-07 end.

      -- Customer Service will use the original invoice Stream Type.
      -- Insurance will provide a generic Insurance Credit Stream Type.

      IF p_credit_sty_id IS NULL THEN
        l_sty_id               := v_3LevelInvoiceRec.sty_id;
      ELSE
        l_sty_id               := p_credit_sty_id;
      END IF;

      i_tldv_rec.sty_id := l_sty_id;
      i_tldv_rec.sel_id := v_3LevelInvoiceRec.sel_id; -- 6237730

    --  l_source_id     := r_tldv_rec.id;
    --  l_source_table  := 'OKL_TXD_AR_LN_DTLS_B';

      lp_tldv_tbl(0) := i_tldv_rec;


    ELSE

      OPEN c_2LevelInvoice;
      FETCH c_2LevelInvoice INTO v_2LevelInvoiceRec;

      IF c_2LevelInvoice%FOUND THEN

         CLOSE c_2LevelInvoice;

            i_taiv_rec.khr_id           := v_2LevelInvoiceRec.khr_id;

          -- To populate Customer_Address_Id(IBT_ID) from cursor line_bill_to_csr
          -- If it returns null then populate from cust_acct_csr.
        OPEN line_bill_to_csr(i_taiv_rec.khr_id  ,v_3LevelInvoiceRec.kle_id );
        FETCH line_bill_to_csr INTO i_taiv_rec.ibt_id;
        CLOSE line_bill_to_csr;

          IF (i_taiv_rec.ibt_id IS NULL) THEN
              OPEN cust_acct_csr(i_taiv_rec.khr_id);
              FETCH cust_acct_csr INTO i_taiv_rec.ibt_id;
            CLOSE cust_acct_csr;
         END IF;

            i_taiv_rec.set_of_books_id  := v_2LevelInvoiceRec.set_of_books_id;
            i_taiv_rec.currency_code    := v_2LevelInvoiceRec.currency_code;
            i_taiv_rec.ixx_id           := v_2LevelInvoiceRec.ixx_id;
            i_taiv_rec.irm_id           := v_2LevelInvoiceRec.irm_id;
            i_taiv_rec.irt_id           := v_2LevelInvoiceRec.irt_id;
            i_taiv_rec.org_id           := v_2LevelInvoiceRec.org_id;
            i_taiv_rec.tai_id_reverses  := v_2LevelInvoiceRec.tai_id_reverses;
            i_taiv_rec.legal_entity_id  := v_3LevelInvoiceRec.legal_entity_id;
            --Done this fix for bug 3816891, Passing the p_credit_date instead
          -- of date_invoiced to the API
          --i_taiv_rec.date_invoiced    := v_3LevelInvoiceRec.date_invoiced;
          --i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
          --Done this fix for bug:5171202,passing date invoiced if the date invoiced is greater than
          --sysdate and creates the credit memo form lease center only
            IF i_taiv_rec.description = 'OKL Credit Memo' AND v_2LevelInvoiceRec.date_invoiced > SYSDATE THEN
              i_taiv_rec.date_invoiced    := v_2LevelInvoiceRec.date_invoiced;
            ELSE
              i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
            END IF;

            i_taiv_rec.cra_id           := NULL;
            i_taiv_rec.qte_id           := NULL;
            i_taiv_rec.tcn_id           := NULL;
            i_taiv_rec.svf_id           := NULL;
            i_taiv_rec.ipy_id           := NULL;
            i_taiv_rec.tap_id           := NULL;

            --gkhuntet 26-07-07 start.
	    i_taiv_rec.okl_source_billing_trx  :=  p_transaction_source;
            --gkhuntet 26-07-07 end

          -- Same as Header amount (1 line per header)
            i_tilv_rec.amount                 := r_taiv_rec.amount;
            i_tilv_rec.kle_id                 := v_2LevelInvoiceRec.kle_id;
            i_tilv_rec.line_number            := l_line_number;
        --      i_tilv_rec.tai_id                 := r_taiv_rec.id;
            i_tilv_rec.description            := NVL(p_credit_desc, 'OKL Credit Memo');
            i_tilv_rec.til_id_reverses        := v_2LevelInvoiceRec.til_id_reverses;
            i_tilv_rec.inv_receiv_line_code   := 'LINE';
            i_tilv_rec.acn_id_cost            := NULL;
            i_tilv_rec.tpl_id                 := NULL;
            i_tilv_rec.date_bill_period_end   := NULL;
            i_tilv_rec.date_bill_period_start := NULL;
            i_tilv_rec.quantity               := NULL;
            i_tilv_rec.org_id                 := NULL;


            -- Customer Service will use the original invoice Stream Type.
            -- Insurance will provide a generic Insurance Credit Stream Type.

            IF p_credit_sty_id IS NULL THEN
              l_sty_id               := v_2LevelInvoiceRec.sty_id;
            ELSE
              l_sty_id               := p_credit_sty_id;
            END IF;
            i_tilv_rec.sty_id := l_sty_id;
            i_tilv_rec.TXL_AR_LINE_NUMBER := 1; -- 6237730

            --l_source_id     := r_tilv_rec.id;
            --l_source_table  := 'OKL_TXL_AR_INV_LNS_B';
            lp_tilv_tbl(0) := i_tilv_rec;

      ELSE

            okl_api.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_INVOICE_TRX_NOT_FOUND');

            RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

    END IF;
   CLOSE c_3LevelInvoice;

      -- Bug 5897792
      OKL_INTERNAL_BILLING_PVT.create_billing_trx(
                                                  p_api_version => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status  => l_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data        => x_msg_data,
                                                  p_taiv_rec        => i_taiv_rec ,
                                                  p_tilv_tbl        => lp_tilv_tbl ,
                                                  p_tldv_tbl        => lp_tldv_tbl ,
                                                  x_taiv_rec        => r_taiv_rec ,
                                                  x_tilv_tbl        => lx_tilv_tbl ,
                                                  x_tldv_tbl        => lx_tldv_tbl );

     --x_tai_id             :=     r_taiv_rec.id;
     x_taiv_rec           :=     r_taiv_rec;
     x_return_status      :=     l_return_status;


     IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


  END insert_request;



  -----------------------------------------------------------------------------------------------
  -- Procedure insert_request to insert a credit memo request (TABLE OF CREDIT MEMOS)
  -----------------------------------------------------------------------------------------------

  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           p_credit_list             IN          credit_tbl,
--Bug 5897792
                           p_transaction_source      IN          VARCHAR2 DEFAULT NULL,
                           p_source_trx_number       IN          VARCHAR2 DEFAULT NULL,
--  Bug 5897792
                           x_taiv_tbl                OUT NOCOPY  taiv_tbl_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2) IS

    l_return_status   VARCHAR2(1);
    l_try_id          NUMBER;
    l_cm_try_id       NUMBER;
    lx_tai_id         NUMBER;  -- place holder only

    lx_taiv_rec       okl_trx_ar_invoices_pub.taiv_rec_type;


  BEGIN

    FOR i IN 1..p_credit_list.COUNT LOOP

      IF p_credit_list(i).credit_try_name <> 'Credit Memo' THEN

        l_try_id        := get_try_id(p_credit_list(i).credit_try_name);

        IF l_try_id IS NULL THEN

          OKL_API.set_message(p_app_name      =>  G_APP_NAME,
                              p_msg_name      =>  'OKL_TRY_ID_NOT_FOUND',
                              p_token1        =>  'TRY_NAME',
                              p_token1_value  =>  p_credit_list(i).credit_try_name);

          RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

      ELSE

        IF l_cm_try_id IS NULL THEN

          l_cm_try_id := get_try_id('Credit Memo');

          IF l_cm_try_id IS NULL THEN

            OKL_API.set_message(p_app_name      =>  G_APP_NAME,
                                p_msg_name      =>  'OKL_TRY_ID_NOT_FOUND',
                                p_token1        =>  'TRY_NAME',
                                p_token1_value  =>  'Credit Memo');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        ELSE

          l_try_id := l_cm_try_id;

        END IF;

      END IF;

      insert_request(p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     p_tld_id             => p_credit_list(i).lsm_id,
                     p_credit_amount      => p_credit_list(i).credit_amount,
                     p_credit_sty_id      => p_credit_list(i).credit_sty_id,
                     p_credit_desc        => p_credit_list(i).credit_desc,
                     p_credit_date        => p_credit_list(i).credit_date,
                     p_try_id             => l_try_id,
--Bug 5897792
                     p_transaction_source  => p_credit_list(i).transaction_source,
                     p_source_trx_number   => p_credit_list(i).source_trx_number,
-- Bug 5897792
                     x_tai_id             => lx_tai_id,
                     x_taiv_rec           => lx_taiv_rec,
                     x_return_status      => l_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data);

      IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      x_taiv_tbl(i) := lx_taiv_rec;

    END LOOP;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END insert_request;

  --rkuttiya added for bug#4341480
PROCEDURE insert_on_acc_cm_request(p_api_version   IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           p_tld_id                  IN          NUMBER,
                           p_credit_amount           IN          NUMBER,
                           p_credit_sty_id           IN          NUMBER,
                           p_credit_desc             IN          VARCHAR2,
                           p_credit_date             IN          DATE,
                           p_try_id                  IN          NUMBER,
--Bug 5897792
                           p_transaction_source      IN          VARCHAR2 DEFAULT NULL,
                           p_source_trx_number       IN          VARCHAR2 DEFAULT NULL,
--  Bug 5897792
                           x_tai_id                  OUT NOCOPY  NUMBER,
                           x_taiv_rec                OUT NOCOPY  taiv_rec_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2)IS
CURSOR c_3LevelInvoice IS

      SELECT  tai.set_of_books_id           set_of_books_id,
              tai.currency_code             currency_code,
              tai.ixx_id                    ixx_id,
            --tai.customer_address_id       ibt_id,
              tai.irm_id                     irm_id,
              tai.irt_id                    irt_id,
              tai.org_id                    org_id,
              tai.id                        tai_id_reverses,
              tai.khr_id                    khr_id,
              tai.legal_entity_id           legal_entity_id ,
              tai.date_invoiced             date_invoiced,
              til.id                        til_id_reverses,
              til.kle_id                    kle_id,
              tld.id                        tld_id_reverses,
              tld.sty_id                    sty_id,
              tld.til_id_details            til_id_details,
              tld.sel_id                    sel_id
      FROM
              okl_txd_ar_ln_dtls_b          tld,
              okl_txl_ar_inv_lns_b          til,
              okl_trx_ar_invoices_b         tai
      WHERE   tai.id                      = til.tai_id
      AND     til.id                      = tld.TIL_ID_DETAILS
      AND     tld.id                      = p_tld_id;

   CURSOR c_2LevelInvoice IS

      SELECT  tai.set_of_books_id           set_of_books_id,
              tai.currency_code             currency_code,
              tai.ixx_id                    ixx_id,
           -- tai.customer_address_id       ibt_id,
              tai.irm_id                    irm_id,
              tai.irt_id                    irt_id,
              tai.org_id                    org_id,
              tai.id                        tai_id_reverses,
              tai.khr_id                    khr_id,
              tai.legal_entity_id           legal_entity_id ,
              tai.date_invoiced             date_invoiced,
              til.id                        til_id_reverses,
              til.kle_id                    kle_id,
              til.sty_id                    sty_id
      FROM
              okl_txd_ar_ln_dtls_b          tld,
              okl_txl_ar_inv_lns_b          til,
              okl_trx_ar_invoices_b         tai
      WHERE   tai.id                      = til.tai_id
      AND     til.id                      = tld.TIL_ID_DETAILS
      AND     tld.id                      = p_tld_id;

    v_3LevelInvoiceRec c_3LevelInvoice%ROWTYPE;
    v_2LevelInvoiceRec c_2LevelInvoice%ROWTYPE;

    -- Transaction headers
    i_taiv_rec      okl_trx_ar_invoices_pub.taiv_rec_type;
    r_taiv_rec      okl_trx_ar_invoices_pub.taiv_rec_type;

    -- Transaction lines
    i_tilv_rec      okl_txl_ar_inv_lns_pub.tilv_rec_type;
  --r_tilv_rec      okl_txl_ar_inv_lns_pub.tilv_rec_type;


    -- Transaction line details
    i_tldv_rec      okl_txd_ar_ln_dtls_pub.tldv_rec_type;
  --r_tldv_rec      okl_txd_ar_ln_dtls_pub.tldv_rec_type;

    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

    l_try_id            NUMBER;
    l_sty_id            NUMBER;
    l_khr_id            NUMBER;
    l_pdt_id            NUMBER;
    l_factoring_synd    VARCHAR2(30);
    l_source_id         NUMBER;
    l_source_table      VARCHAR2(30);

    -- local parameters
    l_api_version       CONSTANT NUMBER      := 1;
    l_init_msg_list     CONSTANT CHAR        := 'F';
    l_return_status     VARCHAR2(1);
    l_line_number       NUMBER               := 1;

  BEGIN

    -------------------------------------------------------------------------
    -- Preparing Transaction Header (one record for each credit memo request)
    -------------------------------------------------------------------------

    l_try_id := p_try_id;

    IF l_try_id IS NULL THEN

      l_try_id := get_try_id( 'Credit Memo');

      IF l_try_id IS NULL THEN

        OKL_API.set_message(p_app_name      =>  G_APP_NAME,
                            p_msg_name      =>  'OKL_TRY_ID_NOT_FOUND',
                            p_token1        =>  'TRY_NAME',
                            p_token1_value  =>  'Credit Memo');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

    END IF;
    --g_debug_proc('TRY_ID ' || l_try_id);

    i_taiv_rec.try_id         := l_try_id;
    i_taiv_rec.date_entered   := TRUNC(SYSDATE);
    i_taiv_rec.description    := NVL(p_credit_desc, 'OKL Credit Memo');

    -- Only records with status SUBMITTED are processed
    -- Use ENTERED or WORKING to temporarily prevent processing
    -- See lookup_type OKL_TRANSACTION_STATUS for the full list of Status Codes
    -- Status code after processing will either be PROCESSED or ERROR

    i_taiv_rec.trx_status_code      := 'SUBMITTED';

    -- Amount must equal to sum of all lines (til records)
    i_taiv_rec.amount   := p_credit_amount;
    i_taiv_rec.okl_source_billing_trx  := 'COLLECTION';

    --g_debug_proc('insert_on_acc_cm_request');

    OPEN c_3LevelInvoice;
    FETCH c_3LevelInvoice INTO v_3LevelInvoiceRec;

    IF c_3LevelInvoice%FOUND THEN

      i_taiv_rec.khr_id           := v_3LevelInvoiceRec.khr_id;

      --g_debug_proc('KHR_ID ' ||  i_taiv_rec.khr_id  || 'KLE_ID   ' || v_3LevelInvoiceRec.kle_id);

      -- To populate Customer_Address_Id(IBT_ID) from cursor line_bill_to_csr
      -- If it returns null then populate from cust_acct_csr.
      OPEN line_bill_to_csr(i_taiv_rec.khr_id  ,v_3LevelInvoiceRec.kle_id );
      FETCH line_bill_to_csr INTO i_taiv_rec.ibt_id;
      CLOSE line_bill_to_csr;

        --g_debug_proc('i_taiv_rec.ibt_id  ' || i_taiv_rec.ibt_id);

      IF (i_taiv_rec.ibt_id IS  NULL) THEN
          OPEN cust_acct_csr(i_taiv_rec.khr_id);
          FETCH cust_acct_csr INTO i_taiv_rec.ibt_id;
          CLOSE cust_acct_csr;
      END IF;

      IF(i_taiv_rec.ibt_id IS  NULL) THEN
           OKL_API.set_message(p_app_name      =>  G_APP_NAME,
                            p_msg_name      =>  'OKL_IBT_ID_NOT_FOUND',
                            p_token1        =>  'TRY_NAME',
                            p_token1_value  =>  'Credit Memo');
            RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      ---------------------------------------------
      -- These columns need not be provided if khr_id is set
      -- because they will extracted from contract rules.
      -- These values must be provided if:
      -- 1. Credit goes to an account other than the invoiced account
      -- 2. The invoice being credited was not for any contract
      ---------------------------------------------
      i_taiv_rec.set_of_books_id  := v_3LevelInvoiceRec.set_of_books_id;
      i_taiv_rec.currency_code    := v_3LevelInvoiceRec.currency_code;
      i_taiv_rec.ixx_id           := v_3LevelInvoiceRec.ixx_id;  -- customer
      i_taiv_rec.irm_id           := v_3LevelInvoiceRec.irm_id;  -- payment method
      i_taiv_rec.irt_id           := v_3LevelInvoiceRec.irt_id;  -- payment term
      i_taiv_rec.org_id           := v_3LevelInvoiceRec.org_id;
     --i_taiv_rec.tai_id_reverses  := v_3LevelInvoiceRec.tai_id_reverses;
      i_taiv_rec.legal_entity_id  := v_3LevelInvoiceRec.legal_entity_id;
      --Done this fix for bug 3816891, Passing the p_credit_date instead
      -- of date_invoiced to the API
      --i_taiv_rec.date_invoiced    := v_3LevelInvoiceRec.date_invoiced;
      --i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
      --Done this fix for bug:5171202,passing date invoiced if the date invoiced is greater than
      --sysdate and creates the credit memo form lease center only
      IF i_taiv_rec.description = 'OKL Credit Memo' AND v_3LevelInvoiceRec.date_invoiced > SYSDATE THEN
        i_taiv_rec.date_invoiced    := v_3LevelInvoiceRec.date_invoiced;
      ELSE
        i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
      END IF;

      ----------------------------------------------------------------------------------
      -- Not required for the Credit Process but may be useful to other functional areas
      ----------------------------------------------------------------------------------
      i_taiv_rec.cra_id           := NULL;  -- OKL_CURE_REP_AMTS_V
      i_taiv_rec.qte_id           := NULL;  -- OKL_TRX_QUOTES_V
      i_taiv_rec.tcn_id           := NULL;  -- OKL_TRX_CONTRACTS
      i_taiv_rec.svf_id           := NULL;  -- OKL_SERVICE_FEES_V
      i_taiv_rec.ipy_id           := NULL;  -- OKL_INS_POLICIES_V
      i_taiv_rec.tap_id           := NULL;  -- OKL_TRX_AP_INVOICES_V -- vendor bills
      i_taiv_rec.legal_entity_id        := v_3LevelInvoiceRec.legal_entity_id;

      i_taiv_rec.okl_source_billing_trx  := NVL(p_transaction_source,i_taiv_rec.okl_source_billing_trx); -- vpanwar for bug no 6334774

      ---------------------------------------------------------------------
      -- Prepare Transaction line (one record for each credit memo request)
      ---------------------------------------------------------------------
      i_tilv_rec.ibt_id                 := i_taiv_rec.ibt_id;
      i_tilv_rec.kle_id                 := v_3LevelInvoiceRec.kle_id;
      i_tilv_rec.line_number            := l_line_number;
      --i_tilv_rec.tai_id                 := r_taiv_rec.id;
      i_tilv_rec.description            := NVL(p_credit_desc, 'OKL Credit Memo');
    --i_tilv_rec.til_id_reverses        := v_3LevelInvoiceRec.til_id_reverses;


      -- this field is passed as invoice description in AR
      -- you can actually put 'LINE' or 'CHARGE'
      -- 'CHARGE' is used for financial charges and has some accounting
      -- implications in AR; till further notice please always use LINE
      i_tilv_rec.inv_receiv_line_code := 'LINE';

      -- Same as Header amount (1 line per header)
      i_tilv_rec.amount   := p_credit_amount;

      -- every billing item must have stream type;
      -- it will be used for accrual, billing and consolidation;
      -- make sure Susan has your stream type on the list
      -- i_tilv_rec.sty_id   := your_stream_type_id;  -- only needed for 2 level insert

      ----------------------------------------------------------------------------------
      -- Not required for the Credit Process but may be useful to other functional areas
      ----------------------------------------------------------------------------------
      i_tilv_rec.acn_id_cost            := NULL;    -- OKL_ASSET_CNDTN_LNS_V
      i_tilv_rec.tpl_id                 := NULL;    -- OKL_TXL_AP_INV_LNS_V - for vendor bills
      i_tilv_rec.date_bill_period_end   := NULL;    -- For Variable Interest use only
      i_tilv_rec.date_bill_period_start := NULL;    -- For Variable Interest use only
      i_tilv_rec.quantity               := NULL;    -- No need for value since we don't use PO
      i_tilv_rec.org_id                 := NULL;
      i_tilv_rec.TXL_AR_LINE_NUMBER     := 1;

      lp_tilv_tbl(0) := i_tilv_rec;

      -- 3rd level insert
      ----------------------------------------------------
      -- Populate required columns
      ----------------------------------------------------

      -- Same as Line amount (1 sub-line per line)
      i_tldv_rec.amount               := p_credit_amount;

      i_tldv_rec.description          := NVL(p_credit_desc, 'OKL Credit Memo');
   -- i_tldv_rec.til_id_details       := r_tilv_rec.id;
      i_tldv_rec.line_detail_number   := l_line_number;
    --i_tldv_rec.tld_id_reverses      := v_3LevelInvoiceRec.tld_id_reverses;


      -- Customer Service will use the original invoice Stream Type.
      -- Insurance will provide a generic Insurance Credit Stream Type.

      IF p_credit_sty_id IS NULL THEN
        l_sty_id               := v_3LevelInvoiceRec.sty_id;
      ELSE
        l_sty_id               := p_credit_sty_id;
      END IF;

      i_tldv_rec.sty_id := l_sty_id;
      i_tldv_rec.sel_id := v_3LevelInvoiceRec.sel_id;
      i_tldv_rec.TXL_AR_LINE_NUMBER := 1; -- 6237730

    --  l_source_id     := r_tldv_rec.id;
    --  l_source_table  := 'OKL_TXD_AR_LN_DTLS_B';

      lp_tldv_tbl(0) := i_tldv_rec;


    ELSE

      OPEN c_2LevelInvoice;
      FETCH c_2LevelInvoice INTO v_2LevelInvoiceRec;
            --g_debug_proc('In else of insert_on_acc_cm_request');
      IF c_2LevelInvoice%FOUND THEN

         CLOSE c_2LevelInvoice;

            i_taiv_rec.khr_id           := v_2LevelInvoiceRec.khr_id;

          -- To populate Customer_Address_Id(IBT_ID) from cursor line_bill_to_csr
          -- If it returns null then populate from cust_acct_csr.
        OPEN line_bill_to_csr(i_taiv_rec.khr_id  ,v_3LevelInvoiceRec.kle_id );
        FETCH line_bill_to_csr INTO i_taiv_rec.ibt_id;
        CLOSE line_bill_to_csr;

          IF (i_taiv_rec.ibt_id = NULL) THEN
              OPEN cust_acct_csr(i_taiv_rec.khr_id);
              FETCH cust_acct_csr INTO i_taiv_rec.ibt_id;
            CLOSE cust_acct_csr;
         END IF;

            i_taiv_rec.set_of_books_id  := v_2LevelInvoiceRec.set_of_books_id;
            i_taiv_rec.currency_code    := v_2LevelInvoiceRec.currency_code;
            i_taiv_rec.ixx_id           := v_2LevelInvoiceRec.ixx_id;
            i_taiv_rec.irm_id           := v_2LevelInvoiceRec.irm_id;
            i_taiv_rec.irt_id           := v_2LevelInvoiceRec.irt_id;
            i_taiv_rec.org_id           := v_2LevelInvoiceRec.org_id;
            --i_taiv_rec.tai_id_reverses  := v_2LevelInvoiceRec.tai_id_reverses;
            i_taiv_rec.legal_entity_id  := v_3LevelInvoiceRec.legal_entity_id;
            --Done this fix for bug 3816891, Passing the p_credit_date instead
          -- of date_invoiced to the API
          --i_taiv_rec.date_invoiced    := v_3LevelInvoiceRec.date_invoiced;
          --i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
          --Done this fix for bug:5171202,passing date invoiced if the date invoiced is greater than
          --sysdate and creates the credit memo form lease center only
            IF i_taiv_rec.description = 'OKL Credit Memo' AND v_2LevelInvoiceRec.date_invoiced > SYSDATE THEN
              i_taiv_rec.date_invoiced    := v_2LevelInvoiceRec.date_invoiced;
            ELSE
              i_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
            END IF;

            i_taiv_rec.cra_id           := NULL;
            i_taiv_rec.qte_id           := NULL;
            i_taiv_rec.tcn_id           := NULL;
            i_taiv_rec.svf_id           := NULL;
            i_taiv_rec.ipy_id           := NULL;
            i_taiv_rec.tap_id           := NULL;

	    i_taiv_rec.okl_source_billing_trx  :=  NVL(p_transaction_source,i_taiv_rec.okl_source_billing_trx); -- vpanwar for bug no 6334774


          -- Same as Header amount (1 line per header)
            i_tilv_rec.amount                 := r_taiv_rec.amount;
            i_tilv_rec.kle_id                 := v_2LevelInvoiceRec.kle_id;
            i_tilv_rec.line_number            := l_line_number;
        --      i_tilv_rec.tai_id                 := r_taiv_rec.id;
            i_tilv_rec.description            := NVL(p_credit_desc, 'OKL Credit Memo');
           -- i_tilv_rec.til_id_reverses        := v_2LevelInvoiceRec.til_id_reverses;
            i_tilv_rec.inv_receiv_line_code   := 'LINE';
            i_tilv_rec.acn_id_cost            := NULL;
            i_tilv_rec.tpl_id                 := NULL;
            i_tilv_rec.date_bill_period_end   := NULL;
            i_tilv_rec.date_bill_period_start := NULL;
            i_tilv_rec.quantity               := NULL;
            i_tilv_rec.org_id                 := NULL;


            -- Customer Service will use the original invoice Stream Type.
            -- Insurance will provide a generic Insurance Credit Stream Type.

            IF p_credit_sty_id IS NULL THEN
              l_sty_id               := v_2LevelInvoiceRec.sty_id;
            ELSE
              l_sty_id               := p_credit_sty_id;
            END IF;
            i_tilv_rec.sty_id := l_sty_id;
            i_tilv_rec.TXL_AR_LINE_NUMBER := 1; -- 6237730

            --l_source_id     := r_tilv_rec.id;
            --l_source_table  := 'OKL_TXL_AR_INV_LNS_B';
            lp_tilv_tbl(0) := i_tilv_rec;

      ELSE

            okl_api.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_INVOICE_TRX_NOT_FOUND');

            RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

    END IF;
   CLOSE c_3LevelInvoice;

      -- Bug 5897792
            --g_debug_proc('Before call to create_billing_trx');
      OKL_INTERNAL_BILLING_PVT.create_billing_trx(
                                                  p_api_version => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status  => l_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data        => x_msg_data,
                                                  p_taiv_rec        => i_taiv_rec ,
                                                  p_tilv_tbl        => lp_tilv_tbl ,
                                                  p_tldv_tbl        => lp_tldv_tbl ,
                                                  x_taiv_rec        => r_taiv_rec ,
                                                  x_tilv_tbl        => lx_tilv_tbl ,
                                                  x_tldv_tbl        => lx_tldv_tbl );

     --x_tai_id             :=     r_taiv_rec.id;
     x_taiv_rec           :=     r_taiv_rec;
     x_return_status      :=     l_return_status;
     x_tai_id             :=     r_taiv_rec.id;
    --g_debug_proc('After call of create_billing_trx  ' || x_tai_id || '  ' || lx_tilv_tbl(lx_tilv_tbl.FIRST).id);

     IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


  END insert_on_acc_cm_request;

--end fix for bug #4341480

END okl_credit_memo_pvt;

/
