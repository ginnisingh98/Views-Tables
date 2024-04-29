--------------------------------------------------------
--  DDL for Package Body OKL_ARINTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ARINTF_PVT" AS
/* $Header: OKLRAINB.pls 120.79.12010000.27 2010/04/14 00:00:11 sachandr ship $ */

  G_MODULE VARCHAR2(255) := 'okl.plsql.okl_arintf_pvt';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON BOOLEAN;
  -- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED VARCHAR2(10);
--  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
	-- vpanwar 20-July-07 -- interface line length increase from 30 to 150
    G_AR_DATA_LENGTH CONSTANT VARCHAR2(4) := '150';
    -- end vpanwar 20-July-07 -- interface line length increase from 30 to 150
    G_ACC_SYS_OPTION VARCHAR2(4);
--end: |           15-FEB-07 cklee  R12 Billing enhancement project                 |

-- rmunjulu R12 Fixes
TYPE dist_rec_type IS RECORD (
   account_class          RA_INTERFACE_DISTRIBUTIONS_ALL.account_class%TYPE,
   dist_amount            OKL_TRNS_ACC_DSTRS.amount%TYPE,
   dist_percent           OKL_TRNS_ACC_DSTRS.percentage%TYPE,
   code_combination_id    OKL_TRNS_ACC_DSTRS.code_combination_id%TYPE);

-- rmunjulu R12 Fixes
TYPE dist_tbl_type IS TABLE OF dist_rec_type INDEX BY BINARY_INTEGER;
--
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_cust_config_from_line
-- Description     : This logic is migrated from okl_stream_billing_pvt
-- Business Rules  : irm_id, ibt_id, and customer_bank_account will be
--                   overrided if contract line setting exists
-- Parameters      :
--
-- Version         : 1.0
-- HISTORY:        : 12-Feb-2008 Bug 6755333 Populate line bill to address only if
--                               line level bill to adress is not null
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE get_cust_config_from_line(
   p_kle_id                       IN NUMBER
   ,p_customer_address_id          IN NUMBER
   ,p_customer_bank_account_id     IN NUMBER
   ,p_receipt_method_id            IN NUMBER
   ,x_customer_address_id          OUT NOCOPY NUMBER
   ,x_customer_bank_account_id     OUT NOCOPY NUMBER
   ,x_receipt_method_id            OUT NOCOPY NUMBER
   -- BANK-ACCOUNT-UPTAKE-START
   ,x_creation_method_code         OUT NOCOPY VARCHAR2
	 ,x_bank_line_id1                OUT NOCOPY NUMBER
   -- BANK-ACCOUNT-UPTAKE-START
	 )
IS
    l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    -- -----------------------------------------------------
    -- Variable definitions for line level bill-to_support
    -- -----------------------------------------------------
    l_pmth_line_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;
    l_rct_line_method_code         AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
    lp_rct_line_method_code         AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
    l_bank_line_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;

    l_line_cust_bank_acct_id       OKL_TRX_AR_INVOICES_V.customer_bank_account_id%TYPE;
    l_line_cust_address_id         OKL_TRX_AR_INVOICES_V.ibt_id%TYPE;
    l_line_receipt_method_id       OKL_TRX_AR_INVOICES_V.irm_id%TYPE;
    l_line_term_id                 OKL_TRX_AR_INVOICES_V.irt_id%TYPE;

    l_khr_id okc_k_headers_b.id%type;

   CURSOR get_chr_id (p_kle_id NUMBER) IS
     select dnz_chr_id
     from okc_k_lines_b
     where id = p_kle_id;

  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR line_bill_to_csr SQL definition
   CURSOR line_bill_to_csr(p_khr_id NUMBER, p_kle_id NUMBER) IS
        SELECT cs.cust_acct_site_id, cp.standard_terms payment_term_id
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
        SELECT cs.cust_acct_site_id, cp.standard_terms payment_term_id
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

   CURSOR cust_line_pmth_csr ( p_khr_id NUMBER, p_kle_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.cle_id     = p_kle_id                AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.dnz_chr_id = p_khr_id
        UNION
        SELECT  rul.object1_id1
        FROM okc_k_lines_b cle
            , okc_k_items_v item
            , okc_k_lines_b linked_asset
            , OKC_RULES_B       rul
            , Okc_rule_groups_B rgp
        WHERE cle.dnz_chr_id = p_khr_id                AND
              cle.id = p_kle_id                        AND
              cle.chr_id IS NULL                       AND
              cle.id = item.cle_id                     AND
              item.object1_id1 = linked_asset.id       AND
              linked_asset.id = rgp.cle_id             AND
              linked_asset.dnz_chr_id = rgp.dnz_chr_id AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rgp_id     = rgp.id                  AND
              rul.rule_information_category = 'LAPMTH';

    CURSOR rcpt_mthd_csr(p_cust_rct_mthd NUMBER) IS
 	   SELECT C.RECEIPT_METHOD_ID
	   FROM RA_CUST_RECEIPT_METHODS C
	   WHERE C.cust_receipt_method_id = p_cust_rct_mthd;

    -- Bank Account Cursor
   CURSOR rcpt_method_csr ( p_rct_method_id  NUMBER) IS
	   SELECT C.CREATION_METHOD_CODE
	   FROM  AR_RECEIPT_METHODS M,
       		 AR_RECEIPT_CLASSES C
	   WHERE  M.RECEIPT_CLASS_ID = C.RECEIPT_CLASS_ID AND
	   		  M.receipt_method_id = p_rct_method_id;

CURSOR cust_line_bank_csr ( p_khr_id NUMBER, p_kle_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.cle_id     = p_kle_id                AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rule_information_category = 'LABACC' AND
              rgp.dnz_chr_id = p_khr_id
        UNION
        SELECT  rul.object1_id1
        FROM okc_k_lines_b cle
            , okc_k_items_v item
            , okc_k_lines_b linked_asset
            , OKC_RULES_B       rul
            , Okc_rule_groups_B rgp
        WHERE cle.dnz_chr_id = p_khr_id                AND
              cle.id = p_kle_id                        AND
              cle.chr_id IS NULL                       AND
              cle.id = item.cle_id                     AND
              item.object1_id1 = linked_asset.id       AND
              linked_asset.id = rgp.cle_id             AND
              linked_asset.dnz_chr_id = rgp.dnz_chr_id AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rgp_id     = rgp.id                  AND
              rul.rule_information_category = 'LABACC';

   CURSOR bank_acct_csr(p_id1 NUMBER) IS
	   SELECT bank_account_id
	   FROM OKX_RCPT_METHOD_ACCOUNTS_V
	   WHERE id1 = p_id1;

BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','p_kle_id:'||p_kle_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','p_customer_address_id:'||p_customer_address_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','p_customer_bank_account_id:'||p_customer_bank_account_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','p_receipt_method_id:'||p_receipt_method_id);
    END IF;

     -- assign to out parameters 1st
     x_customer_address_id        := p_customer_address_id;
     x_customer_bank_account_id   := p_customer_bank_account_id;
     x_receipt_method_id          := p_receipt_method_id;

     -- -------------------------------------------------------
     -- Get bill-to_site and payment term, receipt method and
     -- bank account id
     -- -------------------------------------------------------
     l_line_cust_address_id   := NULL;
     l_line_term_id           := NULL;

     OPEN  rcpt_method_csr (p_receipt_method_id);
     FETCH rcpt_method_csr INTO l_rct_line_method_code;
     CLOSE rcpt_method_csr;

     -- BANK-ACCOUNT-UPTAKE-START
     x_creation_method_code := l_rct_line_method_code;
     -- BANK-ACCOUNT-UPTAKE-END

     IF (p_kle_id IS NOT NULL AND p_kle_id <> okl_api.g_miss_num) THEN

		    OPEN  get_chr_id(p_kle_id);
        FETCH get_chr_id INTO l_khr_id;
        CLOSE get_chr_id;

		    OPEN  line_bill_to_csr(l_khr_id, p_kle_id );
        FETCH line_bill_to_csr INTO l_line_cust_address_id, l_line_term_id;
        CLOSE line_bill_to_csr;

				IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
					fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_khr_id:'||l_khr_id);
					fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_line_cust_address_id:'||l_line_cust_address_id);
					fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_line_term_id:'||l_line_term_id);
				END IF;


      --  IF l_line_cust_address_id IS NOT NULL THEN --sosharma commented bug 6788194

            l_pmth_line_id1          := NULL;
            l_line_receipt_method_id := NULL;
          --  l_rct_line_method_code   := NULL;
            l_bank_line_id1          := NULL;

            OPEN  cust_line_pmth_csr (l_khr_id, p_kle_id );
            FETCH cust_line_pmth_csr INTO l_pmth_line_id1;
            CLOSE cust_line_pmth_csr;

            OPEN  rcpt_mthd_csr( l_pmth_line_id1 );
            FETCH rcpt_mthd_csr INTO l_line_receipt_method_id;
            CLOSE rcpt_mthd_csr;

            OPEN  rcpt_method_csr (l_line_receipt_method_id);
	        FETCH rcpt_method_csr INTO lp_rct_line_method_code;
	        CLOSE rcpt_method_csr;

            -- BANK-ACCOUNT-UPTAKE-START
            -- sosharma changes for setting variables only if valus is prsent
         IF lp_rct_line_method_code IS NOT NULL THEN
            x_creation_method_code := lp_rct_line_method_code;
            l_rct_line_method_code:=lp_rct_line_method_code;
         END IF;
            -- BANK-ACCOUNT-UPTAKE-END
            IF (l_rct_line_method_code <> 'MANUAL') THEN
              OPEN  cust_line_bank_csr ( l_khr_id, p_kle_id );
              FETCH cust_line_bank_csr INTO l_bank_line_id1;
              CLOSE cust_line_bank_csr;
          -- sosharma changes for setting variables only if value is prsent
        IF l_bank_line_id1 IS NOT NULL THEN
							  x_bank_line_id1 := l_bank_line_id1;
         END IF;

			  OPEN 	bank_acct_csr( l_bank_line_id1 );
			  FETCH bank_acct_csr INTO l_line_cust_bank_acct_id;
			  CLOSE bank_acct_csr;
	        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_pmth_line_id1:'||l_pmth_line_id1);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_line_receipt_method_id:'||l_line_receipt_method_id);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_rct_line_method_code:'||l_rct_line_method_code);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_bank_line_id1:'||l_bank_line_id1);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','l_line_cust_address_id:'||l_line_cust_address_id);
        END IF;


        -- END IF;-- sosharma commented bug 6788194

				-- Bug 6755333
				-- Populate line cust address id and line receipt method
        IF l_line_cust_address_id IS NOT NULL THEN -- rmunjulu bug 5594606 added

          x_customer_address_id := l_line_cust_address_id;  -- rmunjulu R12 Fixes -- added
        END IF;

				IF l_line_receipt_method_id IS NOT NULL THEN
          x_receipt_method_id := l_line_receipt_method_id; -- rmunjulu bug 5594606 -- l_ext_receipt_method_id; -- rmunjulu R12 Fixes -- added
        END IF;

        IF l_line_cust_bank_acct_id IS NOT NULL THEN
          x_customer_bank_account_id := l_line_cust_bank_acct_id;
        END IF;

     END IF; --IF p_kle_id IS NOT NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','x_customer_address_id:'||x_customer_address_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','x_receipt_method_id:'||x_receipt_method_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_cust_config_from_line.debug','x_customer_bank_account_id:'||x_customer_bank_account_id);
      END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in get_cust_config_from_line');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

END get_cust_config_from_line;
--

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : nullout_rec_method
-- Description     : This logic is migrated from okl_internal_to_external
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
--  added p_payment_trxn_extension_id and x_payment_trxn_extension_id  parameters for bug 6788231
--
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE nullout_rec_method(
    p_contract_id                  IN NUMBER
   ,p_Quote_number                 IN NUMBER
   ,p_sty_id                       IN NUMBER
   ,p_customer_bank_account_id     IN NUMBER
   ,p_receipt_method_id            IN NUMBER -- irm_id
   ,p_payment_trxn_extension_id    IN NUMBER
   ,x_customer_bank_account_id     OUT NOCOPY NUMBER
   ,x_receipt_method_id            OUT NOCOPY NUMBER
   ,x_payment_trxn_extension_id    OUT NOCOPY NUMBER
 )
IS
    l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    lx_remrkt_sty_id number;

BEGIN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','p_contract_id:'||p_contract_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','p_Quote_number:'||p_Quote_number);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','p_sty_id:'||p_sty_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','p_customer_bank_account_id:'||p_customer_bank_account_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','p_receipt_method_id:'||p_receipt_method_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','p_payment_trxn_extension_id:'||p_payment_trxn_extension_id);
      END IF;

      IF p_contract_id IS NOT NULL THEN
        --bug 5160519 : Sales Order Billing
        -- Order Management sales for remarketing, these billing details are
        --purely from the Order, so if payment method,Bank Account is not passed,
        --then pass as NULL.

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','calling Okl_Streams_Util.get_primary_stream_type');
        END IF;
        --get primary stream type for remarketing stream
        Okl_Streams_Util.get_primary_stream_type(p_contract_id,
                                                'ASSET_SALE_RECEIVABLE',
                                                 l_return_status,
                                                 lx_remrkt_sty_id);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','Okl_Streams_Util.get_primary_stream_type returned l_return_status:'||l_return_status||' and lx_remrkt_sty_id:'||lx_remrkt_sty_id);
        END IF;
        IF l_return_status = Okl_Api.g_ret_sts_success THEN

          IF(lx_remrkt_sty_id = p_sty_id) THEN

            x_customer_bank_account_id := NULL;
            x_receipt_method_id := NULL;
	    x_payment_trxn_extension_id:=NULL; -- added for bug 6788231
          ELSE
            x_customer_bank_account_id := p_customer_bank_account_id;
            x_receipt_method_id        := p_receipt_method_id;
            x_payment_trxn_extension_id:= p_payment_trxn_extension_id;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','x_customer_bank_account_id:'||x_customer_bank_account_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','x_receipt_method_id:'||x_receipt_method_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','x_payment_trxn_extension_id:'||x_payment_trxn_extension_id);
            END IF;
          END IF;
        END IF;

        --bug 5160519 : end

        --bug 5160519 : Lease Vendor Billing
        --  For termination quote to  Lease Vendor AND repurchase quote to Lease Vendor
        -- on VPA...the payment method should be taken from the Vendor Billing Details,
        -- if NULL, then as per above, pass nothing to AR and let AR default to Primary
        -- payment method

        IF p_Quote_number IS NOT NULL THEN
          -- if termination record
          x_receipt_method_id := NULL;
          x_customer_bank_account_id := NULL;
          x_payment_trxn_extension_id:=NULL; -- added for bug 6788231
        ELSE
          x_customer_bank_account_id := p_customer_bank_account_id;
          x_receipt_method_id := p_receipt_method_id;
          x_payment_trxn_extension_id:= p_payment_trxn_extension_id; -- added for bug 6788231
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','x_customer_bank_account_id:'||x_customer_bank_account_id);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','x_receipt_method_id:'||x_receipt_method_id);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.nullout_rec_method.debug','x_payment_trxn_extension_id:'||x_payment_trxn_extension_id);
          END IF;
        END IF;
      -- If p_contract_id IS NULL then, return the same values as passed into the procedure
			ELSE
          x_customer_bank_account_id := p_customer_bank_account_id;
          x_receipt_method_id := p_receipt_method_id;
          x_payment_trxn_extension_id:= p_payment_trxn_extension_id;
      END IF; -- IF p_contract_id IS NOT NULL THEN
        --bug 5160519:end

        --bug 5160519
        --if not remarketing invoice


EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in nullout_rec_method');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

END nullout_rec_method;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Get_chr_inv_grp
-- Description     :
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE Get_chr_inv_grp(
    p_inf_id                       IN NUMBER
   ,p_sty_id                       IN NUMBER
   ,x_group_by_contract_yn         OUT NOCOPY VARCHAR2
   ,x_contract_level_yn            OUT NOCOPY VARCHAR2
   ,x_group_asset_yn               OUT NOCOPY VARCHAR2
   ,x_invoice_group                OUT NOCOPY VARCHAR2
 )
is

    CURSOR inv_format_csr ( p_format_id IN NUMBER, p_stream_id IN NUMBER ) IS
		      SELECT  inf.contract_level_yn, -- Multi-contract Y/N
					  ity.group_by_contract_yn,  -- Provide Contract Details
                      ity.group_asset_yn, -- Combine Assets
                      inf.name -- invoice group
	           FROM   okl_invoice_formats_v   inf,
			          okl_invoice_types_v     ity,
       			      okl_invc_line_types_v   ilt,
       			      okl_invc_frmt_strms_v   frs,
       			      okl_strm_type_v         sty
		      WHERE   inf.id                  = ity.inf_id
		      AND     ity.inf_id              = p_format_id
		      AND     ilt.ity_id              = ity.id
		      AND     frs.ilt_id              = ilt.id
		      AND     sty.id                  = frs.sty_id
		      AND	  frs.sty_id		      = p_stream_id;

    CURSOR inv_format_default_csr ( p_format_id IN NUMBER ) IS
    	     SELECT   inf.contract_level_yn, -- Multi-contract Y/N
	                  ity.group_by_contract_yn,  -- Provide Contract Details
                      ity.group_asset_yn, -- Combine Assets
                      inf.name -- invoice group
	          FROM    okl_invoice_formats_v   inf,
       		          okl_invoice_types_v     ity,
            		  okl_invc_line_types_v   ilt
		      WHERE   inf.id                  = ity.inf_id
		      AND     ity.inf_id              = p_format_id
              AND     ilt.ity_id              = ity.id;

begin

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_chr_inv_grp.debug','p_inf_id:'||p_inf_id);
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_chr_inv_grp.debug','p_sty_id:'||p_sty_id);
  END IF;

  IF p_inf_id IS NOT NULL and p_sty_id IS NOT NULL THEN

    OPEN inv_format_csr ( p_inf_id, p_sty_id);
    FETCH inv_format_csr INTO x_contract_level_yn,
	                          x_group_by_contract_yn,
	                          x_group_asset_yn,
	                          x_invoice_group;
    CLOSE inv_format_csr;

  ELSIF p_inf_id IS NOT NULL and p_sty_id IS NULL THEN

    OPEN inv_format_default_csr ( p_inf_id);
    FETCH inv_format_default_csr INTO x_contract_level_yn,
	                                  x_group_by_contract_yn,
        	                          x_group_asset_yn,
        	                          x_invoice_group;
    CLOSE inv_format_default_csr;

  ELSE

    x_group_by_contract_yn := NULL;
    x_contract_level_yn := NULL;
    x_group_asset_yn := NULL;
    x_invoice_group := NULL;

  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_chr_inv_grp.debug','x_group_by_contract_yn:'||x_group_by_contract_yn);
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_chr_inv_grp.debug','x_contract_level_yn:'||x_contract_level_yn);
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_chr_inv_grp.debug','x_group_asset_yn:'||x_group_asset_yn);
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_chr_inv_grp.debug','x_invoice_group:'||x_invoice_group);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in Get_chr_inv_grp');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

end Get_chr_inv_grp;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Get_acct_disb
-- Description     :
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- rmunjulu : R12 Fixes - changed the out parameters to table type
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE Get_acct_disb(
   p_tld_id               IN NUMBER
   -- Bug 9464082
   ,p_try_name       IN VARCHAR2
   -- End Bug 9464082
   ,x_dist_tbl             OUT NOCOPY dist_tbl_type
   --,x_account_class        OUT NOCOPY VARCHAR2
   --,x_dist_amount          OUT NOCOPY VARCHAR2
   --,x_dist_percent         OUT NOCOPY VARCHAR2
   --,x_code_combination_id  OUT NOCOPY VARCHAR2
 )
is

        -- Selects distributions created by the accounting Engine
        CURSOR acc_dstrs_csr(p_source_id IN NUMBER,   p_source_table IN VARCHAR2) IS
        SELECT cr_dr_flag,
               code_combination_id,
               source_id,
               amount,
               percentage,
        --Start code changes for rev rec by fmiao on 10/05/2004
               NVL(comments,   '-99') comments --End code changes for rev rec by fmiao on 10/05/2004
        FROM okl_trns_acc_dstrs
        WHERE source_id = p_source_id
        AND source_table = p_source_table;

i NUMBER := 1; -- rmunjulu R12 Fixes
l_account_class varchar2(150); -- rmunjulu R12 Fixes
BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','p_tld_id:'||p_tld_id);
    END IF;
-- rmunjulu R12 Fixes -- modified code to populate the new out TBL type

-- rmunjulu R12 Fixes -- modified code to populate x_dist_tbl with values from cursor

      FOR acc_dtls_rec IN acc_dstrs_csr(p_tld_id, 'OKL_TXD_AR_LN_DTLS_B') LOOP

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','acc_dtls_rec.cr_dr_flag'||acc_dtls_rec.cr_dr_flag);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','acc_dtls_rec.code_combination_id'||acc_dtls_rec.code_combination_id);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','acc_dtls_rec.source_id'||acc_dtls_rec.source_id);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','acc_dtls_rec.amount'||acc_dtls_rec.amount);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','acc_dtls_rec.percentage'||acc_dtls_rec.percentage);
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','acc_dtls_rec.comments'||acc_dtls_rec.comments);
        END IF;
        -- rmunjulu R12 Fixes -- commented and moved below
        --x_dist_tbl(i).code_combination_id := acc_dtls_rec.code_combination_id;
        --x_dist_tbl(i).dist_amount := acc_dtls_rec.amount;
        --x_dist_tbl(i).dist_percent := acc_dtls_rec.percentage;

        -- rmunjulu R12 Fixes Use local variable for l_account_class
        -- Bug 9464082 - Added if condition for Credit Memo
        IF p_try_name <> 'Credit Memo' THEN
          IF acc_dtls_rec.amount > 0 THEN

            IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            --x_dist_tbl(i).account_class := 'REV'; -- rmunjulu R12 Fixes
              l_account_class := 'REV'; -- rmunjulu R12 Fixes
            ELSE
            --x_dist_tbl(i).account_class := 'REC'; -- rmunjulu R12 Fixes
              l_account_class := 'REC'; -- rmunjulu R12 Fixes
            END IF;
          ELSE
            IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            --x_dist_tbl(i).account_class := 'REC'; -- rmunjulu R12 Fixes
              l_account_class := 'REC'; -- rmunjulu R12 Fixes
            ELSE
              --x_dist_tbl(i).account_class := 'REV'; -- rmunjulu R12 Fixes
              l_account_class := 'REV'; -- rmunjulu R12 Fixes
            END IF;
          END IF;
        ELSE
          IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            --x_dist_tbl(i).account_class := 'REC'; -- rmunjulu R12 Fixes
             l_account_class := 'REC'; -- rmunjulu R12 Fixes
          ELSE
              --x_dist_tbl(i).account_class := 'REV'; -- rmunjulu R12 Fixes
            l_account_class := 'REV'; -- rmunjulu R12 Fixes
          END IF;

        END IF;
        -- End bug 9464082

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','l_account_class'||l_account_class);
        END IF;

        --Start code changes for rev rec by fmiao on 10/05/2004
        -- rmunjulu R12 Fixes, modified the condition to create
        -- distributions only in case of REV
        /*
          02-Apr-2008 ankushar
          Bug# 6491269 Removed the condition on 'REC' since this needs to be now passed to AR interface
          after AR has given the fix for multiple REC accounts
          Start Changes
        */
        /*IF (((acc_dtls_rec.comments = 'CASH_RECEIPT'
           AND l_account_class <> 'REC') OR(acc_dtls_rec.comments <> 'CASH_RECEIPT'))
		   AND l_account_class <> 'REC') THEN*/

           -- rmunjulu R12 Fixes moved to here from above
           x_dist_tbl(i).code_combination_id := acc_dtls_rec.code_combination_id;
           x_dist_tbl(i).dist_amount := acc_dtls_rec.amount;
           x_dist_tbl(i).dist_percent := acc_dtls_rec.percentage;

           -- rmunjulu R12 Fixes set account class
           x_dist_tbl(i).account_class := l_account_class;

          IF(acc_dtls_rec.comments = 'CASH_RECEIPT') THEN
            x_dist_tbl(i).account_class := 'UNEARN';
          END IF;

--          i := i + 1; -- rmunjulu R12 Fixes -- Increment inside IF --nikshah Bug 8238593, incrementing i after below if statement

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','x_dist_tbl('||i||').code_combination_id:'||x_dist_tbl(i).code_combination_id);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','x_dist_tbl('||i||').dist_amount:'||x_dist_tbl(i).dist_amount);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','x_dist_tbl('||i||').dist_amount:'||x_dist_tbl(i).dist_amount);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','x_dist_tbl('||i||').dist_percent:'||x_dist_tbl(i).dist_percent);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','x_dist_tbl('||i||').account_class:'||x_dist_tbl(i).account_class);
          END IF;
    --  END IF;  -- ankushar Commented this as part of fix Bug # 6491269
     /* 02-Apr-2008 ankushar
        End Changes
      */
        i := i + 1; -- rmunjulu R12 Fixes -- comment and move up --nikshah Bug 8238593 incrementing i after if statement

     END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in Get_acct_disb');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

end Get_acct_disb;

---------------------------------------------------------------------------
-- PROCEDURE get_customer_id from a contract
---------------------------------------------------------------------------

PROCEDURE get_customer_id
  (  l_contract_number IN VARCHAR2
    ,l_customer_id   OUT NOCOPY NUMBER
  )
IS
    --modified by pgomes on 21-aug-2003 for rules migration
    CURSOR get_khr_id_csr ( p_contract_number VARCHAR2 ) IS
           SELECT cust_acct_id
           FROM okc_k_headers_b
           where contract_number = p_contract_number;

    --commented out by pgomes on 21-aug-2003 for rules migration
BEGIN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','l_contract_number:'||l_contract_number);
      END IF;
      --modified by pgomes on 21-aug-2003 for rules migration
      -- Get the customer acct id
      OPEN  get_khr_id_csr(l_contract_number);
      FETCH get_khr_id_csr INTO l_customer_id;
      CLOSE get_khr_id_csr;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.Get_acct_disb.debug','l_customer_id:'||l_customer_id);
      END IF;
      --commented out by pgomes on 21-aug-2003 for rules migration

EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in Get_Customer_Id');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

END get_customer_id;

PROCEDURE get_vendor_auto_bank_dtls
  ( p_api_version IN NUMBER,
   	p_init_msg_list IN VARCHAR2,
    p_khr_id IN NUMBER,
   	p_customer_address_id IN NUMBER,
    p_bank_id IN VARCHAR2,
    p_trx_date IN DATE,
    p_receipt_method_id IN NUMBER,
  	x_receipt_method_id            OUT NOCOPY NUMBER,
  	x_payment_trxn_extension_id    OUT NOCOPY NUMBER,
  	x_customer_bank_account_id     OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2

  ) IS

  l_bank_id OKL_TRX_AR_INVOICES_B.CUSTOMER_BANK_ACCOUNT_ID%TYPE := p_bank_id;

  CURSOR instr_type_csr(p_instr_use_id NUMBER)
  IS
  SELECT   ipiu.payment_function
		   , fpc.payment_channel_code
           , ipiu.payment_flow
  FROM iby_pmt_instr_uses_all ipiu
      ,iby_fndcpt_pmt_chnnls_vl fpc
  WHERE instrument_id = p_instr_use_id
    AND fpc.instrument_type = ipiu.instrument_type;

  CURSOR chr_dtls_csr (cp_khr_id IN NUMBER)
  IS
  SELECT cpr.object1_id1 party_id
   	   , khr.authoring_org_id org_id
	   , khr.cust_acct_id
	   , khr.contract_number
	   , khr.application_id app_id
       , khr.BILL_TO_SITE_USE_ID
       , khr.CURRENCY_CODE
  FROM OKL_K_HEADERS_FULL_V khr
	 , OKC_K_PARTY_ROLES_B CPR
  WHERE khr.ID = cpr.chr_id
    AND cpr.rle_code = 'LESSEE'
	AND khr.ID = cp_khr_id;

  CURSOR c_vendor_bank_csr ( cp_khr_id NUMBER) IS
  SELECT  object1_id1
  FROM OKC_RULES_B       rul,
  	   Okc_rule_groups_B rgp
  WHERE rul.rgp_id     = rgp.id                  AND
		rgp.rgd_code   = 'LAVENB'                AND
		rgp.dnz_chr_id = rgp.chr_id              AND
		rul.rule_information_category = 'LABACC' AND
		rgp.dnz_chr_id = cp_khr_id;

  CURSOR cust_site_use_id_csr (cp_customer_address_id NUMBER) IS
  Select site_use_id
  from HZ_CUST_SITE_USES
  where cust_acct_site_id=cp_customer_address_id
    and site_use_code = 'BILL_TO';

  CURSOR c_get_account_details (cp_customer_address_id NUMBER)IS
  select a.cust_account_id, a.party_id
  from hz_cust_acct_sites_all s,
       hz_cust_accounts a
  where s.cust_acct_site_id = cp_customer_address_id
    AND s.cust_account_id = a.cust_account_id;

  CURSOR instrument_payment_use_id_csr(
            p_payment_function  iby_pmt_instr_uses_all.payment_function%TYPE,
            p_party_id          okc_k_party_roles_b.object1_id1%TYPE,
            p_cust_acct_id      okl_k_headers_full_v.cust_acct_id%TYPE,
            p_site_use_id       hz_cust_site_uses_all.site_use_id%TYPE,
            p_org_id            okl_k_headers_full_v.authoring_org_id%TYPE,
            p_payment_flow      iby_pmt_instr_uses_all.payment_flow%TYPE) IS
  SELECT instrument_payment_use_id
  FROM  iby_pmt_instr_uses_all ibyinstr, iby_external_payers_all pay
  WHERE ibyinstr.instrument_id    = p_bank_id
  AND   ibyinstr.payment_flow     = p_payment_flow
  AND   pay.payment_function      = p_payment_function
  AND   ibyinstr.EXT_PMT_PARTY_ID = pay.EXT_PAYER_ID
  AND   pay.party_id              = p_party_id
  AND   NVL(pay.org_id,p_org_id)  = p_org_id
  AND   pay.cust_account_id       = p_cust_acct_id
  AND   NVL(pay.acct_site_use_id,p_site_use_id)      = p_site_use_id;

  CURSOR cust_instr_payment_use_id_csr (
            p_cust_acct_id      okl_k_headers_full_v.cust_acct_id%TYPE,
            p_site_use_id       hz_cust_site_uses_all.site_use_id%TYPE,
            p_currency_code     okl_k_headers_full_v.currency_code%type
            ) IS
  Select substrb(min(decode(acct_site_use_id, NULL, '2' || to_char(instr_assignment_id),
                                                '1' || to_char(instr_assignment_id))), 2)
  from  IBY_FNDCPT_payer_assgn_instr_v
  where instrument_type     = 'BANKACCOUNT'
  and   cust_account_id     = p_cust_acct_id
  and   p_site_use_id = nvl(acct_site_use_id,p_site_use_id)
  and   currency_code       = p_currency_code
  and   order_of_preference =  (select substrb(min(decode(acct_site_use_id, NULL, '2' || to_char(order_of_preference),
                                     '1' || to_char(order_of_preference))), 2) from  IBY_FNDCPT_payer_assgn_instr_v
                                     where instrument_type     = 'BANKACCOUNT'
                                     and   cust_account_id     = p_cust_acct_id
                                     and   p_site_use_id = nvl(acct_site_use_id,p_site_use_id)
                                     and   currency_code       = p_currency_code
                                     and   p_trx_date between NVL(assignment_start_date, p_trx_date)
                                                               and NVL(assignment_end_date, p_trx_date)
          )
  and   p_trx_date between NVL(assignment_start_date,p_trx_date)
  and NVL(assignment_end_date,p_trx_date);

  cursor instrument_id_csr (p_instr_payment_use_id iby_pmt_instr_uses_all.instrument_payment_use_id%type)
  is
  select instrument_id
  from iby_pmt_instr_uses_all
  where instrument_payment_use_id = p_instr_payment_use_id;

  --Get vendor payment method attached in a contract
  CURSOR c_ven_payment_method(p_khr_id NUMBER) IS
  SELECT  rul.object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LAVENB'                AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.dnz_chr_id = p_khr_id;

  CURSOR c_rcpt_mthd(p_payment_method_id NUMBER) IS
  SELECT C.RECEIPT_METHOD_ID
  FROM RA_CUST_RECEIPT_METHODS C
  WHERE C.cust_receipt_method_id = p_payment_method_id;

  CURSOR c_receipt_method ( p_rct_method_id  NUMBER) IS
  SELECT C.CREATION_METHOD_CODE, M.PAYMENT_CHANNEL_CODE
  FROM  AR_RECEIPT_METHODS M,
  		AR_RECEIPT_CLASSES C
  WHERE  M.RECEIPT_CLASS_ID = C.RECEIPT_CLASS_ID AND
  		 M.receipt_method_id = p_rct_method_id;

  --Get primary active vendor payment method from customer account or from site.
  CURSOR c_vendor_payment_method(p_cust_acct_id NUMBER, p_site_use_id NUMBER)
  IS
  SELECT RM.Payment_channel_code,
         CRM.CUST_RECEIPT_METHOD_ID,
         CRM.RECEIPT_METHOD_ID
  FROM RA_CUST_RECEIPT_METHODS CRM,
       AR_RECEIPT_METHODS RM
  WHERE RM.RECEIPT_METHOD_ID = CRM.RECEIPT_METHOD_ID
    AND customer_id = p_cust_acct_id
    AND NVL(site_use_id,-101) = NVL(p_site_use_id,-101)
    AND NVL(CRM.PRIMARY_FLAG,'N') = 'Y'
    AND NVL(TRUNC(CRM.END_DATE),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

  CURSOR c_vendor_payment_instrument(p_party_id NUMBER,
                                     p_cust_acct_id NUMBER,
                                     p_site_use_id NUMBER,
                                     p_instrument_type VARCHAR2)
  IS
  SELECT *
  FROM
    (
    SELECT * FROM
    (SELECT PIU.INSTRUMENT_PAYMENT_USE_ID,
           PIU.PAYMENT_FUNCTION,
           PIU.ORDER_OF_PREFERENCE,
           PIU.PAYMENT_FLOW
    FROM   IBY_PMT_INSTR_USES_ALL PIU,
           IBY_CREDITCARD ccard,
           iby_external_payers_all pay
    WHERE  ccard.INSTRID = PIU.instrument_id
       AND PIU.INSTRUMENT_TYPE = p_instrument_type
       AND sysdate <= NVL(ccard.inactive_date,sysdate)
       AND PIU.EXT_PMT_PARTY_ID = pay.EXT_PAYER_ID
       AND PAY.PARTY_ID = p_party_id
       AND PAY.CUST_ACCOUNT_ID = p_cust_acct_id
       AND NVL(PAY.ACCT_SITE_USE_ID,-101) = NVL(p_site_use_id,-101)
       AND PIU.PAYMENT_FUNCTION =  'CUSTOMER_PAYMENT'
       AND NVL(CCARD.EXPIRED_FLAG,'N') = 'N'
    UNION
    SELECT PIU.INSTRUMENT_PAYMENT_USE_ID,
           PIU.PAYMENT_FUNCTION,
           PIU.ORDER_OF_PREFERENCE,
           PIU.PAYMENT_FLOW
    FROM   IBY_PMT_INSTR_USES_ALL PIU,
           iby_ext_bank_accounts eb,
           iby_external_payers_all pay
    WHERE  PIU.instrument_id = eb.ext_bank_account_id
       AND PIU.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
       AND PIU.INSTRUMENT_TYPE = p_instrument_type
       AND PIU.EXT_PMT_PARTY_ID = pay.EXT_PAYER_ID
       AND pay.party_id  = p_party_id
       AND PAY.CUST_ACCOUNT_ID = p_cust_acct_id
       AND NVL(PAY.ACCT_SITE_USE_ID,-101) = NVL(p_site_use_id,-101)
       AND sysdate <= NVL(eb.end_date,sysdate)
    ) ORDER BY ORDER_OF_PREFERENCE
    )
  WHERE ROWNUM = 1;

  chr_dtls_rec chr_dtls_csr%ROWTYPE;
  instr_type_rec instr_type_csr%ROWTYPE;
  l_vendor_bank_rec c_vendor_bank_csr%ROWTYPE;
  l_site_use_id  HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE;
  l_instrument_payment_use_id iby_pmt_instr_uses_all.instrument_payment_use_id%type;
  l_instrument_id   iby_pmt_instr_uses_all.instrument_id%type;
  l_payment_method_id okc_rules_b.object1_id1%type;
  l_receipt_method_id RA_CUST_RECEIPT_METHODS.RECEIPT_METHOD_ID%TYPE;
  l_creation_method AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
  l_vend_pmt_mth_acct_rec c_vendor_payment_method%ROWTYPE;
  l_vend_pmt_mth_site_rec c_vendor_payment_method%ROWTYPE;
  l_vend_pmt_ins_acct_rec c_vendor_payment_instrument%ROWTYPE;
  l_vend_pmt_ins_site_rec c_vendor_payment_instrument%ROWTYPE;
  l_vend_acct_pmt_channel_code AR_RECEIPT_METHODS.PAYMENT_CHANNEL_CODE%TYPE DEFAULT NULL;
  l_vend_site_pmt_channel_code AR_RECEIPT_METHODS.PAYMENT_CHANNEL_CODE%TYPE DEFAULT NULL;
  l_instrument_type IBY_PMT_INSTR_USES_ALL.INSTRUMENT_TYPE%TYPE DEFAULT NULL;
  l_vend_payment_channel_code AR_RECEIPT_METHODS.PAYMENT_CHANNEL_CODE%TYPE DEFAULT NULL;

  l_vend_pmt_mth_acct_found BOOLEAN := FALSE;
  l_vend_pmt_mth_site_found BOOLEAN := FALSE;
  l_vend_pmt_ins_acct_found BOOLEAN := FALSE;
  l_vend_pmt_ins_site_found BOOLEAN := FALSE;
  l_vendor_bank_rec_found   BOOLEAN := FALSE;

  l_return_status	       VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(32767);

  l_payer                IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
  l_payer_equivalency    VARCHAR2(500);
  l_pmt_channel          IBY_FNDCPT_PMT_CHNNLS_VL.payment_channel_code%TYPE;
  l_trxn_attribs         IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
  l_entity_id            NUMBER;
  l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
  l_true                 VARCHAR2(1) := 'T';
  l_cust_acct_id         hz_cust_accounts.cust_account_id%TYPE;
  l_party_id             hz_parties.party_id%type;

BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_receipt_method_id := p_receipt_method_id;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_vendor_auto_bank_dtls.debug','p_api_version:'||p_api_version);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_vendor_auto_bank_dtls.debug','p_init_msg_list:'||p_init_msg_list);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_vendor_auto_bank_dtls.debug','p_khr_id:'||p_khr_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_vendor_auto_bank_dtls.debug','p_customer_address_id:'||p_customer_address_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_vendor_auto_bank_dtls.debug','p_bank_id:'||p_bank_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_vendor_auto_bank_dtls.debug','p_trx_date:'||p_trx_date);
    END IF;

    -- Fetch contract details
	OPEN chr_dtls_csr (cp_khr_id => p_khr_id);
	FETCH chr_dtls_csr INTO chr_dtls_rec;
	CLOSE chr_dtls_csr;

    --Get site use id based on cust account site id
    OPEN cust_site_use_id_csr (p_customer_address_id);
	FETCH cust_site_use_id_csr INTO l_site_use_id;
	CLOSE cust_site_use_id_csr;

    --Get cust account id and party id based on cust account site id
    OPEN c_get_account_details(p_customer_address_id);
    FETCH c_get_account_details INTO l_cust_acct_id,l_party_id;
    CLOSE c_get_account_details;

    --Populate payer information record
    l_payer.party_id                          := l_party_id;
    l_payer.org_type                          := 'OPERATING_UNIT';
    l_payer.org_id                            := chr_dtls_rec.org_id;
    l_payer.cust_account_id                   := l_cust_acct_id;
    l_payer.account_site_id                   := l_site_use_id;

    --Get primary payment method at vendor account level
    OPEN c_vendor_payment_method(l_cust_acct_id,NULL);
    FETCH c_vendor_payment_method INTO l_vend_pmt_mth_acct_rec;
    l_vend_pmt_mth_acct_found := c_vendor_payment_method%FOUND;
    CLOSE c_vendor_payment_method;

    --Get highest ordered instrument number for above payment method
    --at vendor account level
    IF l_vend_pmt_mth_acct_found THEN
      l_vend_acct_pmt_channel_code := l_vend_pmt_mth_acct_rec.PAYMENT_CHANNEL_CODE;
      IF l_vend_acct_pmt_channel_code = 'BANK_ACCT_XFER' THEN
        l_instrument_type := 'BANKACCOUNT';
      ELSIF l_vend_acct_pmt_channel_code = 'CREDIT_CARD' THEN
        l_instrument_type := 'CREDITCARD';
      END IF;
      IF l_instrument_type IS NOT NULL THEN
        OPEN c_vendor_payment_instrument(l_party_id, l_cust_acct_id, NULL, l_instrument_type);
        FETCH c_vendor_payment_instrument INTO l_vend_pmt_ins_acct_rec;
        l_vend_pmt_ins_acct_found := c_vendor_payment_instrument%FOUND;
        CLOSE c_vendor_payment_instrument;
      END IF;
    END IF;

    --Get primary payment method at vendor account site level
    OPEN c_vendor_payment_method(l_cust_acct_id,l_site_use_id);
    FETCH c_vendor_payment_method INTO l_vend_pmt_mth_site_rec;
    l_vend_pmt_mth_site_found := c_vendor_payment_method%FOUND;
    CLOSE c_vendor_payment_method;

    --Get highest ordered instrument number for above payment method
    --at vendor account site level
    l_instrument_type := NULL;
    IF l_vend_pmt_mth_site_found THEN
      l_vend_site_pmt_channel_code := l_vend_pmt_mth_site_rec.PAYMENT_CHANNEL_CODE;
      IF l_vend_site_pmt_channel_code = 'BANK_ACCT_XFER' THEN
        l_instrument_type := 'BANKACCOUNT';
      ELSIF l_vend_site_pmt_channel_code = 'CREDIT_CARD' THEN
        l_instrument_type := 'CREDITCARD';
      END IF;
      IF l_instrument_type IS NOT NULL THEN
        OPEN c_vendor_payment_instrument(l_party_id, l_cust_acct_id, l_site_use_id, l_instrument_type);
        FETCH c_vendor_payment_instrument INTO l_vend_pmt_ins_site_rec;
        l_vend_pmt_ins_site_found := c_vendor_payment_instrument%FOUND;
        CLOSE c_vendor_payment_instrument;
      END IF;
    END IF;


    IF l_bank_id IS NULL THEN
      --Get bank account associated to vendor or vendor account site
      --or vendor account. And if not available, throw an error.

      --First get payment method, if any, associated to vendor party details
      --in contract
      OPEN c_ven_payment_method(p_khr_id);
      FETCH c_ven_payment_method INTO l_payment_method_id;
      CLOSE c_ven_payment_method;

      IF l_payment_method_id IS NOT NULL
      THEN
        --Get creation code from below 2 cursors
        OPEN c_rcpt_mthd(l_payment_method_id);
        FETCH c_rcpt_mthd INTO l_receipt_method_id;
        CLOSE c_rcpt_mthd;

        OPEN c_receipt_method(l_receipt_method_id);
        FETCH c_receipt_method INTO l_creation_method, l_vend_payment_channel_code ;
        CLOSE c_receipt_method;

        --Get instrument ID
        OPEN c_vendor_bank_csr(p_khr_id);
        FETCH c_vendor_bank_csr INTO l_vendor_bank_rec;
        l_vendor_bank_rec_found := c_vendor_bank_csr%FOUND;
        CLOSE c_vendor_bank_csr;
      END IF;
    END IF;

    IF l_bank_id IS NOT NULL THEN
      OPEN  instr_type_csr(l_bank_id);
      FETCH instr_type_csr INTO instr_type_rec;
      CLOSE instr_type_csr;
       OPEN instrument_payment_use_id_csr(instr_type_rec.payment_function,l_party_id,
                                           l_cust_acct_id,l_site_use_id,
                                           chr_dtls_rec.org_id, instr_type_rec.payment_flow );
      FETCH instrument_payment_use_id_csr     INTO l_instrument_payment_use_id;
      CLOSE instrument_payment_use_id_csr;
      l_payer.payment_function                  := instr_type_rec.payment_function;
      l_pmt_channel                             := instr_type_rec.payment_channel_code;
    ELSIF l_vendor_bank_rec_found THEN
      l_instrument_payment_use_id := l_vendor_bank_rec.object1_id1;


      IF l_instrument_payment_use_id IS NULL THEN
        -- Write Contract Number in the log so that user can identify
        --for which contract it is failing
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number :'||chr_dtls_rec.contract_number);
        fnd_message.set_name('AR', 'AR_RAXTRX-1763');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OPEN instrument_id_csr(l_instrument_payment_use_id);
      FETCH instrument_id_csr INTO l_instrument_id;
      CLOSE instrument_id_csr;

      OPEN  instr_type_csr(l_instrument_id);
      FETCH instr_type_csr INTO instr_type_rec;
      CLOSE instr_type_csr;
      l_payer.payment_function                  := instr_type_rec.payment_function;
      l_pmt_channel                             := instr_type_rec.payment_channel_code;
    ELSE --In all other cases, get bank account details defined at account/site level
      --If payment method defined in parties tab but not payment instrument
      IF l_vend_payment_channel_code IS NOT NULL THEN
        --Get instrument for payment channel code derived from
        --payment method defined in parties tab
        l_instrument_type := NULL;
        IF l_vend_payment_channel_code = 'BANK_ACCT_XFER' THEN
          l_instrument_type := 'BANKACCOUNT';
        ELSIF l_vend_payment_channel_code = 'CREDIT_CARD' THEN
          l_instrument_type := 'CREDITCARD';
        END IF;
        IF l_instrument_type IS NOT NULL THEN
          --Get it from site level
          OPEN c_vendor_payment_instrument(l_party_id, l_cust_acct_id, l_site_use_id, l_instrument_type);
          FETCH c_vendor_payment_instrument INTO l_vend_pmt_ins_site_rec;
          l_vend_pmt_ins_site_found := c_vendor_payment_instrument%FOUND;
          CLOSE c_vendor_payment_instrument;

          --Get it from account level
          OPEN c_vendor_payment_instrument(l_party_id, l_cust_acct_id, NULL, l_instrument_type);
          FETCH c_vendor_payment_instrument INTO l_vend_pmt_ins_acct_rec;
          l_vend_pmt_ins_acct_found := c_vendor_payment_instrument%FOUND;
          CLOSE c_vendor_payment_instrument;
        END IF;

        --Now we got instrument from site and account level both for a payment channel
        --derived from payment method defined in parties tab.
        l_pmt_channel                             := l_vend_payment_channel_code;
        IF l_vend_pmt_ins_site_found THEN
          l_payer.payment_function                  := l_vend_pmt_ins_site_rec.payment_function;
          l_instrument_payment_use_id               := l_vend_pmt_ins_site_rec.INSTRUMENT_PAYMENT_USE_ID;
        ELSIF l_vend_pmt_ins_acct_found THEN
          l_payer.payment_function                  := l_vend_pmt_ins_acct_rec.payment_function;
          l_instrument_payment_use_id               := l_vend_pmt_ins_acct_rec.INSTRUMENT_PAYMENT_USE_ID;
        ELSE
          -- Write Contract Number in the log so that user can identify
          --for which contract it is failing
          FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number :'||chr_dtls_rec.contract_number);
          fnd_message.set_name('AR', 'AR_RAXTRX-1763');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      --Else payment method is not defined in parties tab
      --Hence derive from vendor account or site level
      ELSE
        IF l_vend_pmt_mth_site_found THEN
          IF l_vend_pmt_ins_site_found THEN
            l_payer.payment_function                  := l_vend_pmt_ins_site_rec.payment_function;
            l_pmt_channel                             := l_vend_site_pmt_channel_code;
            l_instrument_payment_use_id               := l_vend_pmt_ins_site_rec.INSTRUMENT_PAYMENT_USE_ID;
            x_receipt_method_id                       := l_vend_pmt_mth_site_rec.RECEIPT_METHOD_ID;
          ELSIF l_vend_pmt_ins_acct_found THEN
            l_payer.payment_function                  := l_vend_pmt_ins_acct_rec.payment_function;
            l_pmt_channel                             := l_vend_acct_pmt_channel_code;
            l_instrument_payment_use_id               := l_vend_pmt_ins_acct_rec.INSTRUMENT_PAYMENT_USE_ID;
            x_receipt_method_id                       := l_vend_pmt_mth_acct_rec.RECEIPT_METHOD_ID;
          END IF;
        ELSIF l_vend_pmt_mth_acct_found THEN
          IF l_vend_pmt_ins_acct_found THEN
            l_payer.payment_function                  := l_vend_pmt_ins_acct_rec.payment_function;
            l_pmt_channel                             := l_vend_acct_pmt_channel_code;
            l_instrument_payment_use_id               := l_vend_pmt_ins_acct_rec.INSTRUMENT_PAYMENT_USE_ID;
            x_receipt_method_id                       := l_vend_pmt_mth_acct_rec.RECEIPT_METHOD_ID;
          END IF;
        END IF;
        IF l_instrument_payment_use_id IS NULL THEN
          -- Write Contract Number in the log so that user can identify
          --for which contract it is failing
          FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number :'||chr_dtls_rec.contract_number);
          fnd_message.set_name('AR', 'AR_RAXTRX-1763');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    l_payer_equivalency                       := NULL;
	l_trxn_attribs.originating_application_id := chr_dtls_rec.app_id;
	l_trxn_attribs.order_id                   := chr_dtls_rec.contract_number;
	l_trxn_attribs.po_number                  := NULL;
	l_trxn_attribs.po_line_number             := NULL;
	l_trxn_attribs.trxn_ref_number1           := NULL;
	l_trxn_attribs.trxn_ref_number2           := NULL;
	l_trxn_attribs.instrument_security_code   := NULL;
	l_trxn_attribs.voiceauth_flag             := NULL;
	l_trxn_attribs.voiceauth_code             := NULL;
	l_trxn_attribs.voiceauth_date             := NULL;
	l_trxn_attribs.additional_info            := NULL;

    IF (l_payer_equivalency  IS NULL)
	THEN
	  l_payer_equivalency := 'UPWARD';
	END IF;

	-- Call to insert the transaction extension through Payments PL/SQL API
	IBY_FNDCPT_TRXN_PUB.CREATE_TRANSACTION_EXTENSION(
        p_api_version           => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => l_true,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_payer                 => l_payer,
        p_payer_equivalency     => l_payer_equivalency,
        p_pmt_channel           => l_pmt_channel,
        p_instr_assignment      => l_instrument_payment_use_id, --sosharma bug 6608452
        p_trxn_attribs          => l_trxn_attribs,
        x_entity_id             => l_entity_id,
        x_response              => l_response);

	IF (x_return_status = 'S') THEN
      okl_debug_pub.logmessage('AUTOINVOICE:Transaction Extension Id: '|| l_entity_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_entity_id:'||l_entity_id);
      END IF;
      x_payment_trxn_extension_id := l_entity_id;
    ELSE
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    x_customer_bank_account_id := null;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
	  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','x_payment_trxn_extension_id:'||x_payment_trxn_extension_id);
	  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','x_customer_bank_account_id:'||x_customer_bank_account_id);
	END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    x_return_status   :=  Okl_Api.G_RET_STS_ERROR;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, SQLERRM);
    END IF;
END get_vendor_auto_bank_dtls;

	---------------------------------------------------------------------------
	-- PROCEDURE get_auto_bank_dtls
	----------------------------------------------------------------------------------
	-- Start of comments
	--
	-- Procedure Name  : get_auto_bank_dtls
	-- Description     : Moved the code to derive the Payment Transaction Extension ID
	--                   into a separate procedure
	-- Business Rules  : Derives the Payment Transaction Extension ID from IBY
	-- Parameters      :
	--
	-- Version         : 1.0
	-- HISTORY:        : schodava 25-Feb-08 created
	-- End of comments
	----------------------------------------------------------------------------------
  PROCEDURE get_auto_bank_dtls
  ( p_api_version IN NUMBER,
   	p_init_msg_list IN VARCHAR2,
	   p_khr_id IN NUMBER,
   	p_customer_address_id IN NUMBER,
    p_bank_id IN VARCHAR2,
    p_trx_date IN DATE,
  		x_payment_trxn_extension_id OUT NOCOPY NUMBER,
  		x_customer_bank_account_id OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2

  ) IS
		 -- BANK-ACCOUNT-UPTAKE-START
    l_bank_id              okc_rules_b.object1_id1%TYPE := NULL;
		l_return_status	       VARCHAR2(1);
		l_msg_count            NUMBER;
		l_msg_data             VARCHAR2(32767);

		l_payer                IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
		l_payer_equivalency    VARCHAR2(500);
		l_pmt_channel          IBY_FNDCPT_PMT_CHNNLS_VL.payment_channel_code%TYPE;
		l_trxn_attribs         IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
		l_entity_id            NUMBER;
		l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
		-- This values based on global variables from FND_API G_TRUE and G_FALSE;
		l_true                 VARCHAR2(1) := 'T';
		l_cust_acct_id         hz_cust_accounts.cust_account_id%TYPE;
		l_party_id             hz_parties.party_id%type;

		CURSOR instr_type_csr(p_instr_use_id NUMBER)
		IS
		SELECT   ipiu.payment_function
			   , fpc.payment_channel_code
               , ipiu.payment_flow
			FROM iby_pmt_instr_uses_all ipiu
				 ,  iby_fndcpt_pmt_chnnls_vl fpc
			WHERE instrument_id = p_instr_use_id
			AND fpc.instrument_type = ipiu.instrument_type;

		instr_type_rec instr_type_csr%ROWTYPE;

		CURSOR chr_dtls_csr (cp_khr_id IN NUMBER)
		IS
			SELECT cpr.object1_id1 party_id
					 , khr.authoring_org_id org_id
					 , khr.cust_acct_id
					 , khr.contract_number
					 , khr.application_id app_id
      , khr.BILL_TO_SITE_USE_ID
      , khr.CURRENCY_CODE
			FROM OKL_K_HEADERS_FULL_V khr
				 , OKC_K_PARTY_ROLES_B CPR
			WHERE khr.ID = cpr.chr_id
				AND cpr.rle_code = 'LESSEE'
				AND khr.ID = cp_khr_id;
		chr_dtls_rec chr_dtls_csr%ROWTYPE;

	  -- Fetch the Contract Level Bank Id
	  CURSOR cust_bank_csr ( cp_khr_id NUMBER ) IS
					SELECT  object1_id1
					FROM OKC_RULES_B       rul,
							 Okc_rule_groups_B rgp
					WHERE rul.rgp_id     = rgp.id                  AND
								rgp.rgd_code   = 'LABILL'                AND
								rgp.dnz_chr_id = rgp.chr_id              AND
								rul.rule_information_category = 'LABACC' AND
								rgp.dnz_chr_id = cp_khr_id;
		cust_bank_rec cust_bank_csr%ROWTYPE;


    -- BANK-ACCOUNT-UPTAKE-END
    -- gboomina modified for bug 6832065 - Start
    -- Cursor to get site use id
    CURSOR cust_site_use_id_csr (cp_customer_address_id NUMBER) IS
      Select site_use_id
      from HZ_CUST_SITE_USES
      where cust_acct_site_id=cp_customer_address_id
      and site_use_code = 'BILL_TO';
  		l_site_use_id  HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE;
    -- gboomina modified for bug 6832065 - End

    CURSOR c_get_account_details (cp_customer_address_id NUMBER)IS
     select a.cust_account_id, a.party_id
     from hz_cust_acct_sites_all s,
          hz_cust_accounts a
     where s.cust_acct_site_id = cp_customer_address_id
       AND s.cust_account_id = a.cust_account_id;


--sosharma bug 6608452
    --instrument_payment_use_id to be passed to IBY Bug 7162253
    CURSOR instrument_payment_use_id_csr(
            p_payment_function  iby_pmt_instr_uses_all.payment_function%TYPE,
            p_party_id          okc_k_party_roles_b.object1_id1%TYPE,
            p_cust_acct_id      okl_k_headers_full_v.cust_acct_id%TYPE,
            p_site_use_id       hz_cust_site_uses_all.site_use_id%TYPE,
            p_org_id            okl_k_headers_full_v.authoring_org_id%TYPE,
            p_payment_flow      iby_pmt_instr_uses_all.payment_flow%TYPE) IS
    SELECT instrument_payment_use_id
    FROM  iby_pmt_instr_uses_all ibyinstr, iby_external_payers_all pay
    WHERE ibyinstr.instrument_id    = p_bank_id
    AND   ibyinstr.payment_flow     = p_payment_flow
    AND   pay.payment_function      = p_payment_function
    AND   ibyinstr.EXT_PMT_PARTY_ID = pay.EXT_PAYER_ID
    AND   pay.party_id              = p_party_id
    AND   NVL(pay.org_id,p_org_id)  = p_org_id
    AND   pay.cust_account_id       = p_cust_acct_id
    AND   NVL(pay.acct_site_use_id,p_site_use_id)      = p_site_use_id;

    l_instrument_payment_use_id iby_pmt_instr_uses_all.instrument_payment_use_id%type;

    CURSOR cust_instr_payment_use_id_csr (
            p_cust_acct_id      okl_k_headers_full_v.cust_acct_id%TYPE,
            p_site_use_id       hz_cust_site_uses_all.site_use_id%TYPE,
            p_currency_code     okl_k_headers_full_v.currency_code%type
            ) IS
      Select substrb(min(decode(acct_site_use_id, NULL, '2' || to_char(instr_assignment_id),
                                                '1' || to_char(instr_assignment_id))), 2)
      from  IBY_FNDCPT_payer_assgn_instr_v
      where instrument_type     = 'BANKACCOUNT'
      and   cust_account_id     = p_cust_acct_id
      and   p_site_use_id = nvl(acct_site_use_id,p_site_use_id)
      and   currency_code       = p_currency_code
      and   order_of_preference =  (select substrb(min(decode(acct_site_use_id, NULL, '2' || to_char(order_of_preference),
                                     '1' || to_char(order_of_preference))), 2) from  IBY_FNDCPT_payer_assgn_instr_v
                                     where instrument_type     = 'BANKACCOUNT'
                                     and   cust_account_id     = p_cust_acct_id
                                     and   p_site_use_id = nvl(acct_site_use_id,p_site_use_id)
                                     and   currency_code       = p_currency_code
                                     and   p_trx_date between NVL(assignment_start_date, p_trx_date)
                                                               and NVL(assignment_end_date, p_trx_date)
          )
      and   p_trx_date between NVL(assignment_start_date,p_trx_date)
      and NVL(assignment_end_date,p_trx_date);

      cursor instrument_id_csr (p_instr_payment_use_id iby_pmt_instr_uses_all.instrument_payment_use_id%type)
        is
        select instrument_id
        from iby_pmt_instr_uses_all
        where instrument_payment_use_id = p_instr_payment_use_id;

      l_instrument_id   iby_pmt_instr_uses_all.instrument_id%type;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','p_api_version:'||p_api_version);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','p_init_msg_list:'||p_init_msg_list);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','p_khr_id:'||p_khr_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','p_customer_address_id:'||p_customer_address_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','p_bank_id:'||p_bank_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','p_trx_date:'||p_trx_date);
    END IF;

    -- Fetch contract details
	OPEN chr_dtls_csr (cp_khr_id => p_khr_id);
	FETCH chr_dtls_csr INTO chr_dtls_rec;
	CLOSE chr_dtls_csr;

    OPEN cust_site_use_id_csr (p_customer_address_id);
	FETCH cust_site_use_id_csr INTO l_site_use_id;
	CLOSE cust_site_use_id_csr;

    OPEN c_get_account_details(p_customer_address_id);
    FETCH c_get_account_details INTO l_cust_acct_id,l_party_id;
    CLOSE c_get_account_details;

    l_party_id := NVL(l_party_id, chr_dtls_rec.party_id);
    l_cust_acct_id := NVL(l_cust_acct_id, chr_dtls_rec.cust_Acct_id);

    l_payer.party_id                          := l_party_id;
    l_payer.org_type                          := 'OPERATING_UNIT';
    l_payer.org_id                            := chr_dtls_rec.org_id;
    l_payer.cust_account_id                   := l_cust_acct_id;
    l_payer.account_site_id                   := l_site_use_id;

    l_bank_id := p_bank_id;

     -- gboomina added for bug 7513216 - start
  -- If Bank account is not passed from contract, get the bank account
  -- defined at AR Customer setup
     IF l_bank_id IS NOT NULL THEN
          OPEN  instr_type_csr(l_bank_id);
          FETCH instr_type_csr INTO instr_type_rec;
          CLOSE instr_type_csr;

          OPEN instrument_payment_use_id_csr(instr_type_rec.payment_function,l_party_id,
                                            l_cust_acct_id,l_site_use_id,
                                            chr_dtls_rec.org_id, instr_type_rec.payment_flow );
          FETCH instrument_payment_use_id_csr     INTO l_instrument_payment_use_id;
          CLOSE instrument_payment_use_id_csr;
     ELSE
          OPEN cust_instr_payment_use_id_csr(l_cust_acct_id ,
                                       l_site_use_id,
                                       chr_dtls_rec.currency_code);
          FETCH cust_instr_payment_use_id_csr INTO l_instrument_payment_use_id;
          CLOSE cust_instr_payment_use_id_csr;
          -- If Bank account is not defined at AR Customer Setup also, then throw error
          IF l_instrument_payment_use_id IS NULL THEN
          -- Write Contract Number in the log so that user can identify
          -- for which contract it is failing
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number :'||chr_dtls_rec.contract_number);
               fnd_message.set_name('AR', 'AR_RAXTRX-1763');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
          END IF;

          OPEN instrument_id_csr(l_instrument_payment_use_id);
          FETCH instrument_id_csr INTO l_instrument_id;
          CLOSE instrument_id_csr;

          OPEN  instr_type_csr(l_instrument_id);
          FETCH instr_type_csr INTO instr_type_rec;
          CLOSE instr_type_csr;
     END IF;
     -- gboomina bug 7513216 - end

--		l_instr_assignment                        := l_bank_id;
		l_payer_equivalency                       := NULL;
		l_payer.payment_function                  := instr_type_rec.payment_function;
		l_pmt_channel                             := instr_type_rec.payment_channel_code;
	  -- ansethur 07-feb-2007 for 6788194
		l_trxn_attribs.originating_application_id := chr_dtls_rec.app_id;
		l_trxn_attribs.order_id                   := chr_dtls_rec.contract_number; -- Some dummy value, not sure of the significance, need to investigate further

		l_trxn_attribs.po_number                  := NULL;
		l_trxn_attribs.po_line_number             := NULL;
		l_trxn_attribs.trxn_ref_number1           := NULL;
		l_trxn_attribs.trxn_ref_number2           := NULL;
		l_trxn_attribs.instrument_security_code   := NULL;
		l_trxn_attribs.voiceauth_flag             := NULL;
		l_trxn_attribs.voiceauth_code             := NULL;
		l_trxn_attribs.voiceauth_date             := NULL;
		l_trxn_attribs.additional_info            := NULL;

		-- Default value to UPWARD
		IF (l_payer_equivalency  IS NULL)
		THEN
			l_payer_equivalency := 'UPWARD';
		END IF;
		-- Call to insert the transaction extension through Payments PL/SQL API
		IBY_FNDCPT_TRXN_PUB.CREATE_TRANSACTION_EXTENSION(
        p_api_version           => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => l_true,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_payer                 => l_payer,
        p_payer_equivalency     => l_payer_equivalency,
        p_pmt_channel           => l_pmt_channel,
        p_instr_assignment      => l_instrument_payment_use_id, --sosharma bug 6608452
        p_trxn_attribs          => l_trxn_attribs,
        x_entity_id             => l_entity_id,
        x_response              => l_response);
 	-- The values are based on FND_API.  S, E, U (Success, Error, Unexpected
	IF (x_return_status = 'S') THEN
     okl_debug_pub.logmessage('AUTOINVOICE:Transaction Extension Id: '|| l_entity_id);
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_entity_id:'||l_entity_id);
     END IF;

     -- Assign out variables
        x_payment_trxn_extension_id := l_entity_id;
   ELSE
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
	  END IF;

   -- For a receipt method code of 'automatic', customer bank account id column is not used
   x_customer_bank_account_id := null;

		IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
			fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','x_payment_trxn_extension_id:'||x_payment_trxn_extension_id);
			fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_auto_bank_dtls.debug','x_customer_bank_account_id:'||x_customer_bank_account_id);
		END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    x_return_status   :=  Okl_Api.G_RET_STS_ERROR;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, SQLERRM);
    END IF;
	END get_auto_bank_dtls;

---------------------------------------------------------------------------
-- PROCEDURE Get_rec_feeder
---------------------------------------------------------------------------
PROCEDURE Get_REC_FEEDER
  ( p_api_version                  IN  NUMBER
  , p_init_msg_list                IN  VARCHAR2
  , x_return_status                OUT NOCOPY VARCHAR2
  , x_msg_count                    OUT NOCOPY NUMBER
  , x_msg_data                     OUT NOCOPY VARCHAR2
  , p_trx_date_from                IN  DATE
  , p_trx_date_to                  IN  DATE
  , p_assigned_process             IN  VARCHAR2
  ) IS

l_xfer_tbl     xfer_tbl_type;

type inv_lines_tbl_type is table of ra_interface_lines_all%rowtype index by binary_integer;
type inv_dist_tbl_type is table of ra_interface_distributions_all%rowtype index by pls_integer;
type sales_credits_tbl_type is table of ra_interface_salescredits_all%rowtype index by pls_integer;
type ar_contingency_tbl_type is table of ar_interface_conts_all%rowtype index by pls_integer;

inv_lines_tbl       inv_lines_tbl_type;
inv_dist_tbl        inv_dist_tbl_type;
sales_credits_tbl   sales_credits_tbl_type;
ar_contingency_tbl  ar_contingency_tbl_type;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
  l_group_by_contract_yn okl_invoice_types_v.group_by_contract_yn%type;
  l_group_asset_yn okl_invoice_types_v.group_asset_yn%type;
  l_contract_level_yn okl_invoice_formats_v.contract_level_yn%type;
  l_invoice_group okl_invoice_formats_v.name%type;
  l_khr_id okc_k_headers_b.id%type;
  l_bank_line_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;


        CURSOR acc_sys_option is
        select account_derivation
		from okl_sys_acct_opts;

CURSOR xfer_csr IS
       SELECT
        TAI.ID TAI_ID
--        , TIL.AMOUNT AMOUNT
--  19-Mar-2007 cklee -- Change amount referece to TLD instead                |
        , TLD.AMOUNT AMOUNT
        , TIL.DESCRIPTION LINE_DESCRIPTION
        , NVL(TLD.INVENTORY_ITEM_ID, TIL.INVENTORY_ITEM_ID) INVENTORY_ITEM_ID
        , TIL.inv_receiv_line_code LINE_TYPE
        , TIL.QUANTITY
        , TIL.LINE_NUMBER
        , NVL(TLD.STY_ID, TIL.STY_ID) STY_ID
        , KHR.ID KHR_ID
        , KHR.CONTRACT_NUMBER
--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
--        , KLE.NAME ASSET_NUMBER
        , NULL ASSET_NUMBER
--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
        , TLD.INVOICE_FORMAT_LINE_TYPE -- STREAM_GROUP
        , STY.NAME STREAM_TYPE
        , TAI.CURRENCY_CODE
        , TAI.currency_conversion_date
        , TAI.currency_conversion_rate
        , TAI.currency_conversion_type
        , TAI.CUST_TRX_TYPE_ID
        , TAI.IBT_ID CUSTOMER_ADDRESS_ID
--        , TAI.CUSTOMER_BANK_ACCOUNT_ID
        , NVL(TIL.bank_acct_id, TAI.CUSTOMER_BANK_ACCOUNT_ID) CUSTOMER_BANK_ACCOUNT_ID
        , TAI.IXX_ID CUSTOMER_ID
        , TAI.DESCRIPTION HDR_DESCRIPTION
        , NULL INVOICE_MESSAGE
        , TAI.ORG_ID
        , TAI.IRM_ID RECEIPT_METHOD_ID
        , TAI.SET_OF_BOOKS_ID
        , TAI.TAX_EXEMPT_FLAG
        , TAI.IRT_ID TERM_ID
        , TAI.DATE_INVOICED TRX_DATE
--        , TAI.TRX_NUMBER
--if auto-transaction generation is turn on, invoice_number (trx_number) is not a required column.
        , NULL TRX_NUMBER -- refer to metalink: Note:277086.1
        , TAI.CONSOLIDATED_INVOICE_NUMBER
        , TLD.INVOICE_FORMAT_TYPE
        , TAI.INVOICE_PULL_YN
        , TAI.PRIVATE_LABEL
	, TAI.LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
        , NULL ACCOUNT_CLASS
        , NULL DIST_AMOUNT
        , NULL DIST_PERCENT
        , NULL CODE_COMBINATION_ID
--        , XLS.LSM_ID
        , STY.ACCRUAL_YN rev_rec_basis
        , NULL CM_ACCT_RULE
        , TLD.TLD_ID_REVERSES rev_txn_id
--        , NULL REV_LSM_ID
        , NVL(TLD.INVENTORY_ORG_ID, TIL.INVENTORY_ORG_ID) INVENTORY_ORG_ID
        , KHR.inv_organization_id WARE_HOUSE_ID
        , NVL(TLD.KLE_ID, TIL.KLE_ID) KLE_ID
        , NULL SHIP_TO
        , NULL l_inv_id
        , NULL uom_code
        , TLD.ID TXN_ID
--
-- R12 additional columns pass to AR interface
        , TAI.OKL_SOURCE_BILLING_TRX
        , TAI.Investor_Agreement_Number
        , TAI.Investor_Name
        , (select qte.quote_number from OKL_TRX_QUOTES_B qte where qte.id = TAI.QTE_ID) Quote_number
        , NULL rbk_request_number
        , TLD.RBK_ORI_INVOICE_NUMBER
        , TLD.RBK_ORI_INVOICE_LINE_NUMBER
        , TLD.RBK_ADJUSTMENT_DATE
        , TAI.INF_ID
        , TAI.TRY_ID
        , TRYT.NAME TRY_NAME
		-- bug 6744584: contingency fix, added contingecy_id..racheruv
		, STY.CONTINGENCY_ID
        , TLD.INVOICE_FORMAT_LINE_TYPE INVOICE_LINE_TYPE -- Bug 7045347
       FROM OKL_TXD_AR_LN_DTLS_B TLD,
            OKL_TXL_AR_INV_LNS_V TIL,
            OKL_TRX_AR_INVOICES_V TAI,
            OKC_K_HEADERS_ALL_B  KHR,
--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
--            OKC_K_LINES_V KLE,
--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
            OKL_STRM_TYPE_V  STY,
            OKL_TRX_TYPES_TL TRYT,
            OKL_PARALLEL_PROCESSES OPP
       WHERE TLD.STY_ID = STY.ID
       AND TLD.TIL_ID_DETAILS = TIL.ID
       AND TIL.TAI_ID = TAI.ID
       AND TAI.KHR_ID = KHR.ID
--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
--	   AND KLE.ID = TIL.KLE_ID
--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
       AND TAI.TRY_ID = TRYT.ID
       AND TRYT.LANGUAGE = 'US'
	   AND TAI.TRX_STATUS_CODE = 'SUBMITTED'
       AND OPP.OBJECT_TYPE = 'XTRX_CONTRACT'
       AND OPP.OBJECT_VALUE = KHR.CONTRACT_NUMBER
       AND OPP.ASSIGNED_PROCESS = p_assigned_process
       ORDER BY TAI.ID
       ;

--  l_try_name OKL_TRX_TYPES_TL.name%type;
  x_tax_det_rec OKL_PROCESS_SALES_TAX_PVT.tax_det_rec_type;

    -- ------------------------------------------------
    -- Printing and debug log
    -- ------------------------------------------------
    l_request_id      NUMBER;

    CURSOR req_id_csr IS
	  SELECT
          DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
	  FROM dual;

 	 ------------------------------------------------------------
	 -- Operating Unit
	 ------------------------------------------------------------
     CURSOR op_unit_csr IS
            SELECT NAME
            FROM hr_operating_units
            WHERE organization_id = mo_global.get_current_org_id;


-- For R12, OKL_TXD_AR_LN_DTLS_B will be invoice line.
--
    CURSOR tld_cnt_csr( p_req_id NUMBER, p_sts VARCHAR2 ) IS
          SELECT count(1)
          FROM OKL_TXD_AR_LN_DTLS_B TLD
          WHERE EXISTS
		         (SELECT 1
                  FROM OKL_TRX_AR_INVOICES_B TAI,
                       OKL_TXL_AR_INV_LNS_B  TIL
                  WHERE TLD.TIL_ID_DETAILS = TIL.ID
                  AND TIL.TAI_ID = TAI.ID
                  AND TAI.trx_status_code = p_sts
				  AND TAI.request_id = p_req_id);

      CURSOR tld_cnt_csr_selected( p_req_id NUMBER ) IS
          SELECT count(1)
          FROM OKL_TXD_AR_LN_DTLS_B TLD
          WHERE EXISTS
                         (SELECT 1
                  FROM OKL_TRX_AR_INVOICES_B TAI,
                       OKL_TXL_AR_INV_LNS_B  TIL
                  WHERE TLD.TIL_ID_DETAILS = TIL.ID
                  AND TIL.TAI_ID = TAI.ID
                                  AND TAI.request_id = p_req_id);



--end: |           15-FEB-07 cklee  R12 Billing enhancement project                 |

    l_selected_count    NUMBER;
    l_succ_cnt          NUMBER;
    l_err_cnt           NUMBER;
    l_op_unit_name      hr_operating_units.name%TYPE;
    lx_msg_data         VARCHAR2(450);
    l_msg_index_out     NUMBER :=0;

    -- ------------------------------------------------
    -- Bind variables to address issues in bug 3761940
    -- ------------------------------------------------
    processed_sts  okl_trx_ar_invoices_b.trx_status_code%TYPE;
    error_sts      okl_trx_ar_invoices_b.trx_status_code%TYPE;

    -- -------------------------
    -- Bulk Fetch Size
    -- -------------------------
    L_FETCH_SIZE   NUMBER := 10000;
    l_hdr_id       NUMBER := -9999;

    l_commit_cnt   NUMBER := 0;

    -- ----------------------
    -- Std Who columns
    -- ----------------------
    lx_last_updated_by     okl_trx_ar_invoices_b.last_updated_by%TYPE := Fnd_Global.USER_ID;
    lx_last_update_login   okl_trx_ar_invoices_b.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
    lx_request_id          okl_trx_ar_invoices_b.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;

    lx_program_application_id
                okl_trx_ar_invoices_b.program_application_id%TYPE := Fnd_Global.PROG_APPL_ID;
    lx_program_id  okl_trx_ar_invoices_b.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;

    -- ---------------------------
    -- Bulk Insert changes
    -- ---------------------------

    CURSOR l_get_inv_org_yn_csr(cp_org_id IN NUMBER) IS
        SELECT lease_inv_org_yn
        FROM OKL_SYSTEM_PARAMS
        WHERE org_id = cp_org_id;

    l_rev_rec_basis     okl_strm_type_b.accrual_yn%type;
    l_org_id            NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
    l_use_inv_org       VARCHAR2(10) := NULL;


    --vthiruva - Bug 4222231..start
    --modified sales_rep_csr to remove hard coded where clause
    CURSOR sales_rep_csr(p_salesrep_id IN ra_salesreps.salesrep_id%TYPE) IS
       SELECT SALESREP_ID, SALESREP_NUMBER
       FROM ra_salesreps
       --WHERE NAME = 'No Sales Credit';
       WHERE SALESREP_ID = p_salesrep_id;

    --added new cursor to fetch the sales rep for the contract.
    CURSOR get_sales_rep(p_contract_number okc_k_headers_b.contract_number%TYPE) IS
       SELECT contact.object1_id1
       FROM okc_k_headers_b hdr, okc_contacts contact
       WHERE contact.dnz_chr_id = hdr.id
       AND hdr.contract_number = p_contract_number
       AND contact.cro_code = 'SALESPERSON';

    l_prev_contract_num    okc_k_headers_b.contract_number%TYPE;
    l_sales_person         okc_contacts_v.object1_id1%TYPE;
    --vthiruva - Bug 4222231..end

    CURSOR sales_type_credit_csr IS
       SELECT sales_credit_type_id
       FROM so_sales_credit_types
       WHERE name = 'Quota Sales Credit';

    l_salesrep_id          ra_salesreps.SALESREP_ID%TYPE;
    l_salesrep_number      ra_salesreps.SALESREP_NUMBER%TYPE;
    l_sales_type_credit    so_sales_credit_types.sales_credit_type_id%TYPE;

    l_kle_id        NUMBER;
    l_top_kle_id    NUMBER;

--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
    l_is_top_line number;
    is_top_line_flag boolean;

    CURSOR is_top_line ( p_cle_id NUMBER ) IS
       SELECT 1
       FROM okc_k_lines_b kle
       where kle.id = p_cle_id
       and   kle.cle_id is null; -- it's top line

    CURSOR get_top_line ( p_cle_id NUMBER ) IS
      select cle.id--, lse.lty_code
      from okc_k_lines_b cle--,
--           okc_line_styles_b lse
--      where lse.id = cle.lse_id
--      and cle.cle_id is null
      where cle.cle_id is null -- it's top line
      start with cle.id = p_cle_id
      connect by cle.id = prior cle.cle_id;

    CURSOR get_top_line_name ( p_cle_id NUMBER ) IS
      select cle.name
      from OKC_K_LINES_V cle
      where cle.id = p_cle_id;

--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |

    l_chr_id        okc_k_lines_b.chr_id%TYPE;

  	l_ship_to		   NUMBER;

    lx_customer_id     NUMBER;

    -- Local Variables
    l_install_location_id NUMBER;
    l_location_id         NUMBER;

    -- Code Changed for Bug 3044872
    CURSOR get_inv_item_id ( p_fin_asset_line_id NUMBER ) IS
        SELECT c.OBJECT1_ID1
        FROM okc_k_lines_b a,
             okc_line_styles_b b,
             okc_k_items c
        WHERE a.cle_id   = p_fin_asset_line_id
        AND   b.lty_code = 'ITEM'
        AND   a.lse_id   = b.id
        AND   a.id       = c.cle_id;

    l_inv_id        NUMBER;

    l_uom_code      mtl_system_items.primary_uom_code%TYPE;

    CURSOR get_uom_code ( p_inv_item_id NUMBER ) IS
       SELECT primary_uom_code
       FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id;

    l_temp_sold_fee      VARCHAR2(1);


    CURSOR Ship_to_csr( p_kle_top_line IN NUMBER ) IS
        SELECT --cim.object1_id1 item_instance,
       	       --cim.object1_id2 "#",
       	    csi.install_location_id
            , csi.location_id
        FROM  csi_item_instances csi,
       	      okc_k_items cim,
       	      okc_k_lines_b   inst,
       	      okc_k_lines_b   ib,
       	      okc_line_styles_b lse
        WHERE  csi.instance_id = TO_NUMBER(cim.object1_id1)
	    AND    cim.cle_id = ib.id
	    AND    ib.cle_id = inst.id
	    AND    inst.lse_id = lse.id
	    AND    lse.lty_code = 'FREE_FORM2'
	    AND    inst.cle_id = p_kle_top_line;

    CURSOR Ship_to_csr2( p_customer_num NUMBER, p_install_location NUMBER, p_location NUMBER, p_org_id NUMBER ) IS
       SELECT a.CUST_ACCT_SITE_ID
       FROM   hz_cust_acct_sites_all a,
              hz_cust_site_uses_all  b,
              hz_party_sites      c
       WHERE  a.CUST_ACCT_SITE_ID = b.CUST_ACCT_SITE_ID AND
              b.site_use_code     = 'SHIP_TO'           AND
              a.party_site_id     = c.party_site_id     AND
              a.cust_account_id   = p_customer_num      AND
              a.org_id            = p_org_id            AND
              c.party_site_id     = p_install_location  AND
              c.location_id       = p_location;

    CURSOR sold_service_fee_csr ( p_cle_id NUMBER ) IS
       SELECT '1'
       FROM okc_k_lines_v a,
            okc_line_styles_v b
       WHERE a.lse_id = b.id
       AND b.lty_code = 'SOLD_SERVICE'
       AND a.id = p_cle_id;

    CURSOR get_service_inv_csr ( p_cle_id NUMBER ) IS
        SELECT c.object1_id1
        FROM okc_k_lines_v a,
             okc_line_styles_v b,
             okc_k_items c
        WHERE a.lse_id = b.id
        AND b.lty_code = 'SOLD_SERVICE'
        AND a.id = p_cle_id
        AND c.cle_id = a.id;


type error_tbl_type is table of error_rec_type index by binary_integer;

error_tbl   error_tbl_type;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--l_error_xsi_id    okl_ext_sell_invs_v.id%TYPE;
l_error_tai_id    okl_trx_ar_invoices_b.id%TYPE;
l_error_txd_id    OKL_TXD_AR_LN_DTLS_B.id%TYPE;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

hdr_cnt         NUMBER;
sales_cr_cnt    NUMBER;
cont_cnt        NUMBER;

    -- Bug 6619311
    /*CURSOR get_memo_line_id_csr IS
        SELECT MEMO_LINE_ID
        FROM ar_memo_lines
        WHERE NAME = 'Lease Upfront Tax';

l_memo_line_id   ar_memo_lines.memo_line_id%TYPE;
*/

  Cursor is_legacy_invoice (p_rev_txn_id OKL_TXD_AR_LN_DTLS_B.id%type) is
    select lsm_id
    from OKL_TXD_AR_LN_DTLS_B
    where id = p_rev_txn_id;

    l_lsm_id OKL_TXD_AR_LN_DTLS_B.lsm_id%type;

  Cursor get_invoice_line_id (p_rev_txn_id OKL_TXD_AR_LN_DTLS_B.id%type) is
    select a.customer_trx_line_id
	    from ra_customer_trx_lines_all a
    where a.INTERFACE_LINE_ATTRIBUTE14 = to_char(p_rev_txn_id); -- AKP

    l_customer_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%type;

     --akrangan addeed ebtax billing impacts coding start
      CURSOR tax_sources_csr(p_tai_id IN NUMBER
                             ,p_tld_id IN number
                             )
      IS
      SELECT txs.trx_id,
             txs.trx_line_id,
             txs.trx_level_type,
             txs.application_id,
             txs.event_class_code,
             txs.entity_code,
             inv.tax_line_id -- Bug 6619311
      FROM   okl_tax_sources txs,
             okl_txl_ar_inv_lns_b inv
             ,okl_txd_ar_ln_dtls_b tld
      WHERE  txs.trx_id =  inv.txs_trx_id
      AND    trx_line_id  = inv.txs_trx_line_id
      AND    inv.id =  tld.til_id_details
      AND    inv.tai_id = p_tai_id
      AND    tld.id = p_tld_id;

     tax_sources_rec      tax_sources_csr%ROWTYPE;
      -- Bug 6619311
      CURSOR zx_lines_csr(p_zx_lines_id IN NUMBER)
      IS
      SELECT HISTORICAL_FLAG,
             TAX_REGIME_CODE,
             TAX,
             TAX_STATUS_CODE,
             TAX_RATE_CODE,
             TAX_JURISDICTION_CODE,
             TAXABLE_AMT,
             LEGAL_ENTITY_ID
      FROM   ZX_LINES
      WHERE  TAX_LINE_ID = p_zx_lines_id;
     zx_lines_rec      zx_lines_csr%ROWTYPE;

     tx                  NUMBER;
     l_tx                NUMBER;
   --akrangan added ebtax billing impacts coding end

lx_dist_tbl dist_tbl_type; -- rmunjulu R12 Fixes
n NUMBER; -- rmunjulu R12 Fixes
    l_creation_method_code AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;

  -- gboomina added for bug 7513216 - start
  cursor get_khr_id_csr (p_contract_number okc_k_headers_all_b.contract_number%type)
  is
    select id from okc_k_headers_all_b
    where contract_number = p_contract_number;
  -- gboomina added for bug 7513216 - end

    --nikshah added for bug 9223230 start
    --Cursor to check if invoice line belongs to customer?
    CURSOR c_inv_customer(p_chr_id OKC_K_HEADERS_B.ID%TYPE, p_cust_acct_id OKC_K_HEADERS_B.CUST_ACCT_ID%TYPE) IS
    SELECT 1
     FROM   okc_k_headers_b
     WHERE  id = p_chr_id
        AND cust_acct_id = p_cust_acct_id;

    l_inv_customer_rec c_inv_customer%ROWTYPE;
    l_inv_customer BOOLEAN := TRUE;
    --nikshah added for bug 9223230 end

    -- Bug#9576651 - Start
    -- Define error table
    type error_tai_tbl_type IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    l_error_tai_tbl error_tai_tbl_type;
    l_error_tai_cnt NUMBER DEFAULT 0;
    l_conc_status BOOLEAN;
    -- Bug#9576651 - End

BEGIN

    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_arintf_pvt','Begin(+)');
    END IF;

    -- ------------------------
    -- Print Input variables
    -- ------------------------
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_trx_date_from '||p_trx_date_from);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_trx_date_to '||p_trx_date_to);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','p_trx_date_from:'||p_trx_date_from);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','p_trx_date_to:'||p_trx_date_to);
    END IF;


    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
    OPEN acc_sys_option;
    FETCH acc_sys_option INTO G_ACC_SYS_OPTION;
    CLOSE acc_sys_option;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','G_ACC_SYS_OPTION:'||G_ACC_SYS_OPTION);
    END IF;

    -- ----------------------------
    -- Work out common parameters
    -- ----------------------------

    OPEN l_get_inv_org_yn_csr( l_org_id );
    FETCH l_get_inv_org_yn_csr INTO l_use_inv_org;
    CLOSE l_get_inv_org_yn_csr;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_use_inv_org:'||l_use_inv_org);
    END IF;

    --vthiruva - Bug 4222231..start
    --defaulted salesrep variables to 'No Sales Credit'
    l_salesrep_id       := -3;
    l_salesrep_number   := -3;
    l_prev_contract_num := NULL;
    --vthiruva - Bug 4222231..end

    l_sales_type_credit := NULL;
    OPEN  sales_type_credit_csr;
    FETCH sales_type_credit_csr INTO l_sales_type_credit;
    CLOSE sales_type_credit_csr;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_sales_type_credit:'||l_sales_type_credit);
    END IF;

    -- Bug 6619311
    /*
    -- get memo line id for tax only invoices
    l_memo_line_id := NULL;
    OPEN  get_memo_line_id_csr;
    FETCH get_memo_line_id_csr INTO l_memo_line_id;
    CLOSE get_memo_line_id_csr;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_memo_line_id:'||l_memo_line_id);
    END IF;

    if l_memo_line_id is null then
        FND_FILE.PUT_LINE(FND_FILE.LOG,
        'WARNING: A memo line with name -- Lease Upfront Tax,
        must exist to import tax-only invoices.');
    end if;
    */

    -- -----------------------------
    -- Start Bulk Fetch Code
    -- -----------------------------
    OPEN  xfer_csr;
    LOOP
    l_xfer_tbl.delete;
    FETCH xfer_csr BULK COLLECT INTO l_xfer_tbl LIMIT L_FETCH_SIZE;

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_xfer_tbl count is: '||l_xfer_tbl.COUNT);
        -- --------------------------------------
        -- Process bulk-fetched records
        -- --------------------------------------
        IF l_xfer_tbl.COUNT > 0 THEN

           --l_hdr_id     := -9999;  -- Bug 7234827

           l_commit_cnt := 0;

           -- ---------------------------------------------------
           -- Update rest of the table records with missing data
           -- ---------------------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updating records with missing data');
           END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Updating records with missing data');
            END IF;

           hdr_cnt := 0;
           FOR K IN l_xfer_tbl.FIRST..l_xfer_tbl.LAST LOOP
            UPDATE okl_trx_ar_invoices_b
            SET request_id = lx_request_id
            WHERE ID = l_xfer_tbl(k).tai_id ;


            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','starting l_xfer_tbl with k:'||k);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').tai_id:'||l_xfer_tbl(k).tai_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').amount:'||l_xfer_tbl(k).amount);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').line_description:'||l_xfer_tbl(k).line_description);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').inventory_item_id:'||l_xfer_tbl(k).inventory_item_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').line_type:'||l_xfer_tbl(k).line_type);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').quantity:'||l_xfer_tbl(k).quantity);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').line_number:'||l_xfer_tbl(k).line_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').sty_id:'||l_xfer_tbl(k).sty_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').khr_id:'||l_xfer_tbl(k).khr_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').contract_number:'||l_xfer_tbl(k).contract_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').asset_number:'||l_xfer_tbl(k).asset_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').invoice_format_line_type:'||l_xfer_tbl(k).invoice_format_line_type);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').stream_type:'||l_xfer_tbl(k).stream_type);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').currency_code:'||l_xfer_tbl(k).currency_code);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').currency_conversion_date:'||l_xfer_tbl(k).currency_conversion_date);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').currency_conversion_rate:'||l_xfer_tbl(k).currency_conversion_rate);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').currency_conversion_type:'||l_xfer_tbl(k).currency_conversion_type);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').cust_trx_type_id:'||l_xfer_tbl(k).cust_trx_type_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').customer_address_id:'||l_xfer_tbl(k).customer_address_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').customer_bank_account_id:'||l_xfer_tbl(k).customer_bank_account_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').customer_id:'||l_xfer_tbl(k).customer_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').hdr_description:'||l_xfer_tbl(k).hdr_description);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').invoice_message:'||l_xfer_tbl(k).invoice_message);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').org_id:'||l_xfer_tbl(k).org_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').receipt_method_id:'||l_xfer_tbl(k).receipt_method_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').set_of_books_id:'||l_xfer_tbl(k).set_of_books_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').tax_exempt_flag:'||l_xfer_tbl(k).tax_exempt_flag);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').term_id:'||l_xfer_tbl(k).term_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').trx_date:'||l_xfer_tbl(k).trx_date);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').trx_number:'||l_xfer_tbl(k).trx_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').consolidated_invoice_number:'||l_xfer_tbl(k).consolidated_invoice_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').invoice_format_type:'||l_xfer_tbl(k).invoice_format_type);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').invoice_pull_yn:'||l_xfer_tbl(k).invoice_pull_yn);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').private_label:'||l_xfer_tbl(k).private_label);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').legal_entity_id:'||l_xfer_tbl(k).legal_entity_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').account_class:'||l_xfer_tbl(k).account_class);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').dist_amount:'||l_xfer_tbl(k).dist_amount);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').dist_percent:'||l_xfer_tbl(k).dist_percent);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').code_combination_id:'||l_xfer_tbl(k).code_combination_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').rev_rec_basis:'||l_xfer_tbl(k).rev_rec_basis);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').cm_acct_rule:'||l_xfer_tbl(k).cm_acct_rule);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').rev_txn_id:'||l_xfer_tbl(k).rev_txn_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').inventory_org_id:'||l_xfer_tbl(k).inventory_org_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').ware_house_id:'||l_xfer_tbl(k).ware_house_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').kle_id:'||l_xfer_tbl(k).kle_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').ship_to:'||l_xfer_tbl(k).ship_to);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').l_inv_id:'||l_xfer_tbl(k).l_inv_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').uom_code:'||l_xfer_tbl(k).uom_code);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').txn_id:'||l_xfer_tbl(k).txn_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').okl_source_billing_trx:'||l_xfer_tbl(k).okl_source_billing_trx);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').investor_agreement_number:'||l_xfer_tbl(k).investor_agreement_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').investor_name:'||l_xfer_tbl(k).investor_name);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').quote_number:'||l_xfer_tbl(k).quote_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').rbk_request_number:'||l_xfer_tbl(k).rbk_request_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').rbk_ori_invoice_number:'||l_xfer_tbl(k).rbk_ori_invoice_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').rbk_ori_invoice_line_number:'||l_xfer_tbl(k).rbk_ori_invoice_line_number);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').rbk_adjustment_date:'||l_xfer_tbl(k).rbk_adjustment_date);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').inf_id:'||l_xfer_tbl(k).inf_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').try_id:'||l_xfer_tbl(k).try_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').try_name:'||l_xfer_tbl(k).try_name);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').invoice_line_type:'||l_xfer_tbl(k).invoice_line_type);
            END IF;


--start: |           15-FEB-07 cklee  R12 Billing enhancement project
-- It seems like the folowing is a block of dead code. l_rev_rec_basis initial as null
-- so the "then" will never be happened
                  -- Populate CM acct rule
--                  IF (  l_rev_rec_basis = 'CASH_RECEIPT'
                  -- cklee : start: For bug 5387704/R12: 5447521
                  IF (  l_xfer_tbl(k).rev_rec_basis = 'CASH_RECEIPT'
                  -- cklee : end: For bug 5387704/R12: 5447521
--                        AND l_xfer_tbl(k).XLS_AMOUNT < 0    )
                        AND l_xfer_tbl(k).AMOUNT < 0    )
                  THEN
                    l_xfer_tbl(k).cm_acct_rule := 'PRORATE';
                  END IF;

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').cm_acct_rule:'||l_xfer_tbl(k).cm_acct_rule);
                 END IF;

                  -- To find the top line kle_id
                  l_kle_id     := NULL;
--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
                  -- 1. Check if it's a top line
                  OPEN is_top_line(l_xfer_tbl(k).kle_id);
                  FETCH is_top_line INTO l_is_top_line;
                  is_top_line_flag := is_top_line%FOUND;
                  CLOSE is_top_line;

                  IF is_top_line_flag THEN
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug',l_xfer_tbl(k).kle_id || ' is top line');
                    END IF;
                  ELSE
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug',l_xfer_tbl(k).kle_id || ' is not a top line');
                    END IF;
                  END IF;

                  -- 2. get top line if needed
                  IF NOT is_top_line_flag THEN
                    OPEN get_top_line(l_xfer_tbl(k).kle_id);
                    FETCH get_top_line INTO l_xfer_tbl(k).kle_id;
                    CLOSE get_top_line;
                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug',l_xfer_tbl(k).kle_id || ' fetched as a top line');
                  END IF;

                  -- 3. get top line name (asset number)
                  OPEN get_top_line_name(l_xfer_tbl(k).kle_id);
                  FETCH get_top_line_name INTO l_xfer_tbl(k).ASSET_NUMBER;
                  CLOSE get_top_line_name;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug',l_xfer_tbl(k).ASSET_NUMBER || ' fetched as asset number');
                  END IF;

--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
                  l_top_kle_id := l_xfer_tbl(k).kle_id;

                  -- Populate warehouse_id
                  IF (NVL(l_use_inv_org, 'N') = 'Y') THEN
                       --if it is a Remarketing invoice
                       IF (l_xfer_tbl(k).inventory_org_id IS NOT NULL) THEN
                         l_xfer_tbl(k).ware_house_id := l_xfer_tbl(k).inventory_org_id;
                       END IF;
                  ELSE
                      l_xfer_tbl(k).ware_house_id := NULL;
                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').ware_house_id:'||l_xfer_tbl(k).ware_house_id);
                  END IF;

                  l_chr_id := l_xfer_tbl(k).khr_id;
                  l_kle_id := l_xfer_tbl(k).kle_id;

--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                  -- Bug 4523079; stmathew
                  l_install_location_id := NULL;
                  l_location_id := NULL;
                  -- End Code; Bug 4523079; stmathew

                  OPEN  ship_to_csr(l_kle_id);
                  FETCH ship_to_csr INTO l_install_location_id, l_location_id;
                  CLOSE ship_to_csr;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_install_location_id:'||l_install_location_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_location_id:'||l_location_id);
                  END IF;

                  l_temp_sold_fee := NULL;
                  OPEN  sold_service_fee_csr ( l_kle_id );
                  FETCH sold_service_fee_csr INTO l_temp_sold_fee;
                  CLOSE sold_service_fee_csr;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_temp_sold_fee:'||l_temp_sold_fee);
                  END IF;

                  IF l_temp_sold_fee = '1' THEN
                    -- Get Inventory_item_id
                    l_inv_id := NULL;
                    OPEN  get_service_inv_csr ( l_kle_id );
                    FETCH get_service_inv_csr INTO l_inv_id;
                    CLOSE get_service_inv_csr;
                  ELSE
                    -- Get Inventory_item_id
                    l_inv_id := NULL;
                    OPEN  get_inv_item_id ( l_kle_id );
                    FETCH get_inv_item_id INTO l_inv_id;
                    CLOSE get_inv_item_id;
                  END IF;

                  -- -------------------------------------------
                  -- Store inventory item id for the item on
                  -- contract line
                  -- -------------------------------------------
                  l_xfer_tbl(k).l_inv_id := l_inv_id;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_inv_id:'||l_inv_id);
                  END IF;

                  -- Get UOM Code
                  l_uom_code := NULL;
                  IF l_xfer_tbl(k).INVENTORY_ITEM_ID IS NULL THEN
                    l_xfer_tbl(k).INVENTORY_ITEM_ID := l_inv_id;
                    OPEN  get_uom_code ( l_inv_id );
                    FETCH get_uom_code INTO l_uom_code;
                    CLOSE get_uom_code;
                  ELSE
                    OPEN  get_uom_code ( l_xfer_tbl(k).INVENTORY_ITEM_ID );
                    FETCH get_uom_code INTO l_uom_code;
                    CLOSE get_uom_code;
                  END IF;

                  l_xfer_tbl(k).uom_code := l_uom_code;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_uom_code:'||l_uom_code);
                  END IF;
                  -- Check if Vendor is the same as the customer on the Contract
                  lx_customer_id := NULL;
                  get_customer_id(  l_xfer_tbl(k).CONTRACT_NUMBER ,lx_customer_id );
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','lx_customer_id:'||lx_customer_id);
                  END IF;
                  -- Bug 4523079; stmathew
                  l_ship_to := NULL;
                  -- End code Bug 4523079; stmathew

                  OPEN  Ship_to_csr2( lx_customer_id, l_install_location_id, l_location_id, l_xfer_tbl(k).ORG_ID);
                  FETCH Ship_to_csr2 INTO l_ship_to;
                  CLOSE Ship_to_csr2;

                  IF ( lx_customer_id = l_xfer_tbl(k).CUSTOMER_ID ) THEN
                          NULL;
                  ELSE
                          l_ship_to := NULL;
                  END IF;

                  l_xfer_tbl(k).ship_to := l_ship_to;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').ship_to:'||l_xfer_tbl(k).ship_to);
                  END IF;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
                  -- Bug 7622476
                  /*
                  -- get invoice group related data
                  Get_chr_inv_grp(
                    p_inf_id                => l_xfer_tbl(k).inf_id
                   ,p_sty_id                => l_xfer_tbl(k).sty_id
                   ,x_group_by_contract_yn  => l_group_by_contract_yn
                   ,x_contract_level_yn     => l_contract_level_yn
                   ,x_group_asset_yn        => l_group_asset_yn
                   ,x_invoice_group         => l_invoice_group
                   );

                 l_khr_id := l_xfer_tbl(k).KHR_ID;
                 l_xfer_tbl(k).KHR_ID := NULL;
                 --l_kle_id := l_xfer_tbl(k).KLE_ID;
                 --l_xfer_tbl(k).KLE_ID := NULL;
                 IF (l_group_by_contract_yn  = 'Y' OR l_contract_level_yn = 'N') THEN
                   l_xfer_tbl(k).KHR_ID := l_khr_id;
                   --IF l_group_by_assets_yn = 'N' THEN
                   --  l_xfer_tbl(k).KLE_ID := l_kle_id;
                   --END IF;
                 END IF; */
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

           END LOOP; -- Populate missing values

           inv_lines_tbl.delete;
           inv_dist_tbl.delete;
           sales_credits_tbl.delete;
           ar_contingency_tbl.delete;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','finished deleting pl/sql tables');
           END IF;
           -- Build ra_interface_lines_rec
           -- Build ra_interface_distributions_rec
           -- Build ra_interface_salescredits_all
           -- Build ar_interface_conts_all

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Building AR records');
           END IF;

           n := 1; -- rmunjulu R12 Fixes  -- initialize n
           FOR K IN l_xfer_tbl.FIRST..l_xfer_tbl.LAST LOOP

           BEGIN -- Bug#9576651
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','starting l_xfer_tbl loop with k:'||k);
             END IF;
             --Check if invoice line is belonging to vendor as a customer
             --or contract customer
             OPEN c_inv_customer(l_xfer_tbl(K).KHR_ID, l_xfer_tbl(K).CUSTOMER_ID);
             FETCH c_inv_customer INTO l_inv_customer_rec;
             l_inv_customer := c_inv_customer%FOUND;
             CLOSE c_inv_customer;
               -- ----------------------------------
               -- Update prev header status
               -- Except for first record
               -- ----------------------------------
               IF l_hdr_id <> -9999 THEN
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                    UPDATE OKL_EXT_SELL_INVS_B
                    UPDATE okl_trx_ar_invoices_b
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
                    SET trx_status_code = 'PROCESSED',
                        last_update_date = sysdate,
                        last_updated_by = lx_last_updated_by,
                        last_update_login = lx_last_update_login,
                        request_id = lx_request_id,
                        program_update_date = sysdate,
                        program_application_id = lx_program_application_id,
                        program_id = lx_program_id
                    WHERE ID = l_hdr_id;
                    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updating header record with id: '||l_hdr_id);
                    END IF;
                   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Updating header record with id: '||l_hdr_id);
                   END IF;
               END IF;

               -- --------------------------
               -- Increment Commit counter
               -- --------------------------

               l_commit_cnt := l_commit_cnt + 1;

               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updating header record with id: '||l_xfer_tbl(k).xsi_id );
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updating header record with id: '||l_xfer_tbl(k).tai_id );
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
               END IF;
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Updating header record with id: '||l_xfer_tbl(k).tai_id);
               END IF;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--               IF l_hdr_id <> l_xfer_tbl(k).xsi_id THEN
--commented out for R12               IF l_hdr_id <> l_xfer_tbl(k).tai_id THEN
--                  hdr_cnt := hdr_cnt + 1;
                  hdr_cnt := k;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                  --vthiruva - Bug 4222231..start
                  --for each new contract fetch the sales rep is and number and if there is no
                  --sales rep attached to the contract, default it to 'No Sales Credit'(-3)
                  -- Bug 7622476
                  -- get invoice group related data
                  Get_chr_inv_grp(
                    p_inf_id                => l_xfer_tbl(k).inf_id
                   ,p_sty_id                => l_xfer_tbl(k).sty_id
                   ,x_group_by_contract_yn  => l_group_by_contract_yn
                   ,x_contract_level_yn     => l_contract_level_yn
                   ,x_group_asset_yn        => l_group_asset_yn
                   ,x_invoice_group         => l_invoice_group
                   );

                 l_khr_id := l_xfer_tbl(k).KHR_ID;
                 l_xfer_tbl(k).KHR_ID := NULL;
                 --l_kle_id := l_xfer_tbl(k).KLE_ID;
                 --l_xfer_tbl(k).KLE_ID := NULL;
                 IF (l_group_by_contract_yn  = 'Y' OR l_contract_level_yn = 'N') THEN
                   l_xfer_tbl(k).KHR_ID := l_khr_id;
                   --IF l_group_by_assets_yn = 'N' THEN
                   --  l_xfer_tbl(k).KLE_ID := l_kle_id;
                   --END IF;
                 END IF;

                  IF (l_prev_contract_num IS NULL OR
                      l_prev_contract_num <> l_xfer_tbl(k).CONTRACT_NUMBER) THEN

                    OPEN get_sales_rep(l_xfer_tbl(k).CONTRACT_NUMBER);
                    FETCH get_sales_rep INTO l_sales_person;
                    IF get_sales_rep%NOTFOUND THEN
                      l_salesrep_id := -3;
                      l_salesrep_number := -3;
                    ELSE
                      OPEN sales_rep_csr(l_sales_person);
                      FETCH sales_rep_csr INTO l_salesrep_id, l_salesrep_number;
                      CLOSE sales_rep_csr;
                    END IF;
                    CLOSE get_sales_rep;
                   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_salesrep_id:'||l_salesrep_id);
                     fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_salesrep_number:'||l_salesrep_number);
                   END IF;
                    l_prev_contract_num := l_xfer_tbl(k).CONTRACT_NUMBER;

                  END IF;
                  --vthiruva - Bug 4222231..end

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Preparing Ra_interface_lines_all record.');
                  END IF;

                  -- -------------------------------------
                  -- Build Invoice Lines Table
                  -- -------------------------------------
                  inv_lines_tbl(hdr_cnt).WAREHOUSE_ID := l_xfer_tbl(k).ware_house_id;

                  IF (l_xfer_tbl(k).rev_rec_basis = 'CASH_RECEIPT') THEN
                    --Added if clause by bkatraga for bug 5616268
                    --Accounting_rule_id will not be populated in case of on-account credit memo
                    IF ((l_xfer_tbl(k).AMOUNT >= 0) OR (l_xfer_tbl(k).rev_txn_id IS NOT NULL)) THEN
                        inv_lines_tbl(hdr_cnt).ACCOUNTING_RULE_ID := 1;
                    END IF;
                    --end bkatraga
                  ELSE
                        inv_lines_tbl(hdr_cnt).ACCOUNTING_RULE_ID := NULL;
                  END IF;

                  inv_lines_tbl(hdr_cnt).ACCOUNTING_RULE_DURATION := NULL;
                  inv_lines_tbl(hdr_cnt).AGREEMENT_ID := NUll;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                  inv_lines_tbl(hdr_cnt).AMOUNT := l_xfer_tbl(k).XLS_AMOUNT;
                  inv_lines_tbl(hdr_cnt).AMOUNT := l_xfer_tbl(k).AMOUNT;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                  -- tax-only invoice
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                  if l_xfer_tbl(k).XLS_AMOUNT = 0 then
                  -- Bug 6619311
                  /*
                  if l_xfer_tbl(k).AMOUNT = 0 then
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
                     inv_lines_tbl(hdr_cnt).memo_line_id := l_memo_line_id;
                  end if;
                  */

                  inv_lines_tbl(hdr_cnt).BATCH_SOURCE_NAME := 'OKL_CONTRACTS';
                  inv_lines_tbl(hdr_cnt).COMMENTS := l_xfer_tbl(k).INVOICE_MESSAGE;
                  inv_lines_tbl(hdr_cnt).CONVERSION_DATE := l_xfer_tbl(k).currency_conversion_date;
                  inv_lines_tbl(hdr_cnt).CONVERSION_RATE := l_xfer_tbl(k).currency_conversion_rate;
                  inv_lines_tbl(hdr_cnt).CONVERSION_TYPE := l_xfer_tbl(k).currency_conversion_type;
                  inv_lines_tbl(hdr_cnt).CREATED_BY := G_user_id;
                  inv_lines_tbl(hdr_cnt).CREATION_DATE := sysdate;
                  inv_lines_tbl(hdr_cnt).CREDIT_METHOD_FOR_ACCT_RULE := l_xfer_tbl(k).cm_acct_rule;
                  inv_lines_tbl(hdr_cnt).CREDIT_METHOD_FOR_INSTALLMENTS := NULL;
                  inv_lines_tbl(hdr_cnt).CURRENCY_CODE := l_xfer_tbl(k).CURRENCY_CODE;
                  inv_lines_tbl(hdr_cnt).CUST_TRX_TYPE_ID := l_xfer_tbl(k).CUST_TRX_TYPE_ID;
                  /*inv_lines_tbl(hdr_cnt).DESCRIPTION := NVL (NVL (l_xfer_tbl(k).LINE_DESCRIPTION,
                                l_xfer_tbl(k).HDR_DESCRIPTION), 'OKL Billing');*/
                  -- Bug 7045347
                  inv_lines_tbl(hdr_cnt).DESCRIPTION := NVL(l_xfer_tbl(k).INVOICE_LINE_TYPE, SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH));
                  inv_lines_tbl(hdr_cnt).LAST_UPDATED_BY := G_user_id;
                  inv_lines_tbl(hdr_cnt).LAST_UPDATE_DATE := sysdate;
                  inv_lines_tbl(hdr_cnt).LINE_TYPE := l_xfer_tbl(k).LINE_TYPE;

                  inv_lines_tbl(hdr_cnt).TRX_NUMBER := l_xfer_tbl(k).TRX_NUMBER;
                  inv_lines_tbl(hdr_cnt).TRX_DATE := l_xfer_tbl(k).TRX_DATE;
                  inv_lines_tbl(hdr_cnt).GL_DATE := l_xfer_tbl(k).TRX_DATE;
                  inv_lines_tbl(hdr_cnt).PRINTING_OPTION := NULL;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
                  inv_lines_tbl(hdr_cnt).CONS_BILLING_NUMBER := NULL;
                  IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'INVESTOR_STAKE' THEN
		    -- gkhuntet 24-JUL-2007  added for Investor Invoices Start.
                    inv_lines_tbl(hdr_cnt).BATCH_SOURCE_NAME := 'OKL_INVESTOR';
	 	    -- gkhuntet 24-JUL-2007  added for Investor Invoices End.
		    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE1 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Agreement_Number),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE2 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE3 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Name),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE5 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE6 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE7 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE8 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE9 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE11 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE12 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE13 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE15 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_CONTEXT := 'OKL_INVESTOR';

                  ELSE
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE1 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE2 := SUBSTR(TRIM(l_invoice_group),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE3 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_PULL_YN),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).PRIVATE_LABEL),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE5 := NULL;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE6 := SUBSTR(TRIM(l_xfer_tbl(k).CONTRACT_NUMBER),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE7 := SUBSTR(TRIM(l_xfer_tbl(k).ASSET_NUMBER),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE8 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_LINE_TYPE),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE9 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    -- if the source of the billing trx is termination quote, the OKL billing trx number is Quite_number
                    IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'TERMINATION_QUOTE' THEN
                      inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE11 := SUBSTR(TRIM(l_xfer_tbl(k).Quote_number),1,G_AR_DATA_LENGTH);
                    END IF;
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE12 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).KHR_ID)),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE13 := SUBSTR(TRIM(l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_ATTRIBUTE15 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_TYPE),1,G_AR_DATA_LENGTH);
                    inv_lines_tbl(hdr_cnt).INTERFACE_LINE_CONTEXT := 'OKL_CONTRACTS';
                  END IF;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
-- start: cklee 3/22/2007
-- Credit memo:
-- If It's a credit memo invoice, we need to assign the invoice reference
-- to interfcae table for the following:
-- 1. If the invoice reference is a legacy invoice (up to OKL.H), assign FK to
--    REFERENCE_LINExxx
-- 2. If the invoice reference is NOT a legacy invoice (R12 going forward), get the AR
--    invoice line and then assign to REFERENCE_LINE_ID.
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').accounting_rule_id:'||inv_lines_tbl(hdr_cnt).accounting_rule_id);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').amount:'||inv_lines_tbl(hdr_cnt).amount);
            -- Bug 6619311
            /*
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').memo_line_id:'||inv_lines_tbl(hdr_cnt).memo_line_id);
            */
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').batch_source_name:'||inv_lines_tbl(hdr_cnt).batch_source_name);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').comments:'||inv_lines_tbl(hdr_cnt).comments);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').conversion_date:'||inv_lines_tbl(hdr_cnt).conversion_date);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').conversion_rate:'||inv_lines_tbl(hdr_cnt).conversion_rate);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').conversion_type:'||inv_lines_tbl(hdr_cnt).conversion_type);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').created_by:'||inv_lines_tbl(hdr_cnt).created_by);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').creation_date:'||inv_lines_tbl(hdr_cnt).creation_date);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').credit_method_for_acct_rule:'||inv_lines_tbl(hdr_cnt).credit_method_for_acct_rule);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').credit_method_for_installments:'|| inv_lines_tbl(hdr_cnt).credit_method_for_installments);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').currency_code:'||inv_lines_tbl(hdr_cnt).currency_code);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').cust_trx_type_id:'||inv_lines_tbl(hdr_cnt).cust_trx_type_id);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').description:'||inv_lines_tbl(hdr_cnt).description);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').last_updated_by:'||inv_lines_tbl(hdr_cnt).last_updated_by);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').last_update_date:'||inv_lines_tbl(hdr_cnt).last_update_date);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').line_type:'||inv_lines_tbl(hdr_cnt).line_type);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').trx_number:'||inv_lines_tbl(hdr_cnt).trx_number);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').trx_date:'||inv_lines_tbl(hdr_cnt).trx_date);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').gl_date:'||inv_lines_tbl(hdr_cnt).gl_date);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').printing_option:'||inv_lines_tbl(hdr_cnt).printing_option);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').batch_source_name:'||inv_lines_tbl(hdr_cnt).batch_source_name);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute1:'||inv_lines_tbl(hdr_cnt).interface_line_attribute1);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute2:'||inv_lines_tbl(hdr_cnt).interface_line_attribute2);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute3:'||inv_lines_tbl(hdr_cnt).interface_line_attribute3);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute4:'||inv_lines_tbl(hdr_cnt).interface_line_attribute4);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute5:'||inv_lines_tbl(hdr_cnt).interface_line_attribute5);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute6:'||inv_lines_tbl(hdr_cnt).interface_line_attribute6);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute7:'||inv_lines_tbl(hdr_cnt).interface_line_attribute7);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute8:'||inv_lines_tbl(hdr_cnt).interface_line_attribute8);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute9:'||inv_lines_tbl(hdr_cnt).interface_line_attribute9);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute10:'||inv_lines_tbl(hdr_cnt).interface_line_attribute10);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute11:'||inv_lines_tbl(hdr_cnt).interface_line_attribute11);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute12:'||inv_lines_tbl(hdr_cnt).interface_line_attribute12);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute13:'||inv_lines_tbl(hdr_cnt).interface_line_attribute13);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute14:'||inv_lines_tbl(hdr_cnt).interface_line_attribute14);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_attribute15:'||inv_lines_tbl(hdr_cnt).interface_line_attribute15);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').interface_line_context:'||inv_lines_tbl(hdr_cnt).interface_line_context);

          END IF;


                  IF (l_xfer_tbl(k).rev_txn_id IS NOT NULL) THEN


                    open is_legacy_invoice(l_xfer_tbl(k).rev_txn_id);
                    fetch is_legacy_invoice into l_lsm_id;
                    close is_legacy_invoice;


                    -- it's a legacy invoice for which the credit memo is applied
					IF l_lsm_id is not null THEN


                        inv_lines_tbl(hdr_cnt).REFERENCE_LINE_CONTEXT := 'OKL_CONTRACTS';
                        inv_lines_tbl(hdr_cnt).REFERENCE_LINE_ATTRIBUTE14
                            := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).rev_txn_id)),1,G_AR_DATA_LENGTH);

                    ELSE


                      OPEN get_invoice_line_id(l_xfer_tbl(k).rev_txn_id);
                      fetch get_invoice_line_id into l_customer_trx_line_id;
                      close get_invoice_line_id;


                      inv_lines_tbl(hdr_cnt).REFERENCE_LINE_ID := TO_CHAR(l_customer_trx_line_id);


                    END IF;
                  END IF;
-- end: cklee 3/22/2007

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_lsm_id:'||l_lsm_id);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').reference_line_context:'||inv_lines_tbl(hdr_cnt).reference_line_context);
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').reference_line_id:'||inv_lines_tbl(hdr_cnt).reference_line_id);
          END IF;


                  --akrangan added ebtax billing impacts coding start
                  IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'TAX_ONLY_INVOICE_TAX' THEN
 	          OPEN tax_sources_csr(p_tai_id => l_xfer_tbl(k).tai_id,
 	                              p_tld_id =>l_xfer_tbl(k).txn_id);
 	          FETCH tax_sources_csr INTO tax_sources_rec;
 	          CLOSE tax_sources_csr;
 	          --populating the invoice lines interface tbl with tax sources rec
 	          inv_lines_tbl(hdr_cnt).source_trx_id := tax_sources_rec.trx_id;
 	          inv_lines_tbl(hdr_cnt).source_trx_line_id := tax_sources_rec.trx_line_id;
 	          inv_lines_tbl(hdr_cnt).source_trx_line_type := tax_sources_rec.trx_level_type;
 	          inv_lines_tbl(hdr_cnt).source_application_id := tax_sources_rec.application_id;
 	          inv_lines_tbl(hdr_cnt).source_event_class_code := tax_sources_rec.event_class_code;
 	          inv_lines_tbl(hdr_cnt).source_entity_code := tax_sources_rec.entity_code;
                  -- Bug 6619311
                  inv_lines_tbl(hdr_cnt).SOURCE_TRX_DETAIL_TAX_LINE_ID := tax_sources_rec.tax_line_id;
                  inv_lines_tbl(hdr_cnt).TAXED_UPSTREAM_FLAG := 'Y';
                  inv_lines_tbl(hdr_cnt).TAXABLE_FLAG := 'N';
                  OPEN zx_lines_csr(tax_sources_rec.tax_line_id);
                  FETCH zx_lines_csr into zx_lines_rec;
                  CLOSE zx_lines_csr;
                  inv_lines_tbl(hdr_cnt).HISTORICAL_FLAG := zx_lines_rec.HISTORICAL_FLAG;
                  inv_lines_tbl(hdr_cnt).TAX_REGIME_CODE := zx_lines_rec.TAX_REGIME_CODE;
                  inv_lines_tbl(hdr_cnt).TAX := zx_lines_rec.TAX;
                  inv_lines_tbl(hdr_cnt).TAX_STATUS_CODE := zx_lines_rec.TAX_STATUS_CODE;
                  inv_lines_tbl(hdr_cnt).TAX_RATE_CODE := zx_lines_rec.TAX_RATE_CODE;
                  inv_lines_tbl(hdr_cnt).TAX_JURISDICTION_CODE := zx_lines_rec.TAX_JURISDICTION_CODE;
                  inv_lines_tbl(hdr_cnt).TAXABLE_AMOUNT := zx_lines_rec.TAXABLE_AMT;
                  inv_lines_tbl(hdr_cnt).LEGAL_ENTITY_ID := zx_lines_rec.LEGAL_ENTITY_ID;
                  /*inv_lines_tbl(hdr_cnt).TRX_BUSINESS_CATEGORY := NULL;
                  inv_lines_tbl(hdr_cnt).TAX_CODE := NULL;
                  inv_lines_tbl(hdr_cnt).PRODUCT_CATEGORY := NULL;
                  inv_lines_tbl(hdr_cnt).PRODUCT_TYPE := NULL;
                  inv_lines_tbl(hdr_cnt).LINE_INTENDED_USE := NULL;
                  inv_lines_tbl(hdr_cnt).USER_DEFINED_FISC_CLASS := NULL;
                  inv_lines_tbl(hdr_cnt).ASSESSABLE_VALUE := NULL;
                  --inv_lines_tbl(hdr_cnt).DEFAULT_TAXATION_COUNTRY := NULL;*/
                  inv_lines_tbl(hdr_cnt).DEFAULT_TAXATION_COUNTRY := x_tax_det_rec.X_DEFAULT_TAXATION_COUNTRY;

                  END IF;
 	          --akrangan added ebtax billing impacts coding end
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').source_trx_id:'||inv_lines_tbl(hdr_cnt).source_trx_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').source_trx_line_id:'||inv_lines_tbl(hdr_cnt).source_trx_line_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').source_trx_line_type:'||inv_lines_tbl(hdr_cnt).source_trx_line_type);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').source_application_id:'||inv_lines_tbl(hdr_cnt).source_application_id);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').source_event_class_code:'||inv_lines_tbl(hdr_cnt).source_event_class_code);
              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').source_entity_code:'||inv_lines_tbl(hdr_cnt).source_entity_code);
            END IF;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                  IF l_xfer_tbl(k).INVENTORY_ITEM_ID IS NULL
		    AND l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX <> 'TAX_ONLY_INVOICE_TAX' THEN
                     inv_lines_tbl(hdr_cnt).INVENTORY_ITEM_ID := l_xfer_tbl(k).l_inv_id;
                  ELSIF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX <> 'TAX_ONLY_INVOICE_TAX' THEN
                     inv_lines_tbl(hdr_cnt).INVENTORY_ITEM_ID := l_xfer_tbl(k).INVENTORY_ITEM_ID;
                  END IF;

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').inventory_item_id:'||inv_lines_tbl(hdr_cnt).inventory_item_id);
                END IF;

                  IF (l_xfer_tbl(k).rev_rec_basis = 'CASH_RECEIPT') THEN
                    --Added if clause by bkatraga for bug 5616268
                    --Accounting_rule_id will not be populated in case of on-account credit memo
                    IF ((l_xfer_tbl(k).AMOUNT >= 0) OR (l_xfer_tbl(k).rev_txn_id IS NOT NULL)) THEN
                         inv_lines_tbl(hdr_cnt).INVOICING_RULE_ID := -2;
                    END IF;
                    --end bkatraga
                  ELSE
                        inv_lines_tbl(hdr_cnt).INVOICING_RULE_ID := NULL;
                  END IF;

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').invoicing_rule_id:'||inv_lines_tbl(hdr_cnt).invoicing_rule_id);
                END IF;

                  IF (l_xfer_tbl(k).rev_rec_basis = 'CASH_RECEIPT') THEN
                        inv_lines_tbl(hdr_cnt).OVERRIDE_AUTO_ACCOUNTING_FLAG := 'Y';
                  ELSE
                        inv_lines_tbl(hdr_cnt).OVERRIDE_AUTO_ACCOUNTING_FLAG := NULL;
                  END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').override_auto_accounting_flag:'||inv_lines_tbl(hdr_cnt).override_auto_accounting_flag);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').RECEIPT_METHOD_ID:'||l_xfer_tbl(k).RECEIPT_METHOD_ID);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl('||k||').KLE_ID:'||l_xfer_tbl(k).KLE_ID);
                END IF;

--start: |           28-Mar-07 cklee  R12 Billing enhancement project
-- get bill-to information from contract line if any
                  --nikshah for bug 9223230, added if clause
		  --nikshah for bug 9255769, switch the order of if blocks
                        --  and added investor stake condition
                  IF NOT l_inv_customer AND
                     l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX <> 'INVESTOR_STAKE'THEN
                    --Vendor bank account details
                    get_vendor_auto_bank_dtls
                                ( p_api_version => p_api_version,
                             	  p_init_msg_list => p_init_msg_list,
                                  p_khr_id => l_khr_id,
                                  p_customer_address_id => l_xfer_tbl(k).CUSTOMER_ADDRESS_ID,
                                  p_bank_id => l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID,
                                  p_trx_date => l_xfer_tbl(k).trx_date,
                                  p_receipt_method_id => l_xfer_tbl(k).RECEIPT_METHOD_ID,
                                  x_receipt_method_id => l_xfer_tbl(k).RECEIPT_METHOD_ID,
                                  x_payment_trxn_extension_id => inv_lines_tbl(hdr_cnt).payment_trxn_extension_id,
                                  x_customer_bank_account_id => inv_lines_tbl(hdr_cnt).customer_bank_account_id,
                                  x_return_status             => x_return_status,
                                  x_msg_count                 => x_msg_count,
                                  x_msg_data                  => x_msg_data);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    -- For Automatic receipt method, bank account id should be NULL as the column is obsoleted
                    l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID := NULL;

                  ELSE
                    get_cust_config_from_line(
                     p_kle_id                       => l_xfer_tbl(k).KLE_ID
                    ,p_customer_address_id          => l_xfer_tbl(k).CUSTOMER_ADDRESS_ID
                    ,p_customer_bank_account_id     => l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID
                    ,p_receipt_method_id            => l_xfer_tbl(k).RECEIPT_METHOD_ID
                    ,x_customer_address_id          => l_xfer_tbl(k).CUSTOMER_ADDRESS_ID
                    ,x_customer_bank_account_id     => l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID
                    ,x_receipt_method_id            => l_xfer_tbl(k).RECEIPT_METHOD_ID
                    -- BANK-ACCOUNT-UPTAKE-START
                    ,x_creation_method_code         => l_creation_method_code
					,x_bank_line_id1                => l_bank_line_id1
                    -- BANK-ACCOUNT-UPTAKE-END
                    );
                  END IF;

--end: |           28-Mar-07 cklee  R12 Billing enhancement project

                  inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_BILL_CUSTOMER_ID := l_xfer_tbl(k).CUSTOMER_ID;
                  inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_BILL_ADDRESS_ID := l_xfer_tbl(k).CUSTOMER_ADDRESS_ID;
                  inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_SHIP_CUSTOMER_ID := l_xfer_tbl(k).CUSTOMER_ID;

                  IF l_xfer_tbl(k).ship_to IS NOT NULL THEN
                        inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_SHIP_ADDRESS_ID := l_xfer_tbl(k).ship_to;
                  ELSE
                        inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_SHIP_ADDRESS_ID := l_xfer_tbl(k).CUSTOMER_ADDRESS_ID;
                  END IF;

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').orig_system_bill_customer_id:'||inv_lines_tbl(hdr_cnt).orig_system_bill_customer_id);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').orig_system_bill_address_id:'||inv_lines_tbl(hdr_cnt).orig_system_bill_address_id);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').orig_system_ship_customer_id:'||inv_lines_tbl(hdr_cnt).orig_system_ship_customer_id);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').orig_system_ship_address_id:'||inv_lines_tbl(hdr_cnt).orig_system_ship_address_id);
                END IF;

                  inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_BILL_CONTACT_ID := NULL;
                  inv_lines_tbl(hdr_cnt).ORIG_SYSTEM_SOLD_CUSTOMER_ID := NULL;
                  --vthiruva - Bug 4222231..start..removed hardcoding of sales rep
                  inv_lines_tbl(hdr_cnt).PRIMARY_SALESREP_NUMBER := l_salesrep_number;
                  inv_lines_tbl(hdr_cnt).PRIMARY_SALESREP_ID := l_salesrep_id;
                  --vthiruva - Bug 4222231..end
                  inv_lines_tbl(hdr_cnt).PURCHASE_ORDER := NULL;
                  inv_lines_tbl(hdr_cnt).PURCHASE_ORDER_REVISION := NULL;
                  inv_lines_tbl(hdr_cnt).PURCHASE_ORDER_DATE := NULL;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').primary_salesrep_number:'||inv_lines_tbl(hdr_cnt).primary_salesrep_number);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').primary_salesrep_id:'||inv_lines_tbl(hdr_cnt).primary_salesrep_id);
                  END IF;

-- BANK-ACCOUNT-UPTAKE-START
  IF (l_creation_method_code = 'AUTOMATIC') THEN
    -- call procedure get_auto_bank_dtls to derive banking details for the
    -- automatic receipt creation method
    -- gboomina Bug 6832065 - Start
    -- get khr_id from contract number. khr_id is not populated in l_xfer_tbl for all records.
    -- some of l_xfer_tbl records can have khr_id as NULL. so getting khr_id using l_xfer_tbl(k).contract_number.
    if (l_xfer_tbl(k).khr_id is null) then
      open get_khr_id_csr(l_xfer_tbl(k).contract_number);
      fetch get_khr_id_csr into l_khr_id;
      close get_khr_id_csr;
    else
      l_khr_id := l_xfer_tbl(k).khr_id;
    end if;
    --nikshah added for bug 9223230, if clause.
    --Added ELSE block
    IF l_inv_customer THEN
    get_auto_bank_dtls(p_api_version               => p_api_version,
                       p_init_msg_list             => p_init_msg_list,
                       p_khr_id                    => l_khr_id, -- gboomina for bug 7513216
                       p_customer_address_id       => l_xfer_tbl(k).CUSTOMER_ADDRESS_ID,
                       p_bank_id                   => l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID,
                       -- gboomina added p_trx_date for bug 7513216
		                     p_trx_date                  => l_xfer_tbl(k).trx_date,
                       x_payment_trxn_extension_id => inv_lines_tbl(hdr_cnt).payment_trxn_extension_id,
                       x_customer_bank_account_id  => inv_lines_tbl(hdr_cnt).customer_bank_account_id,
                       x_return_status             => x_return_status,
                       x_msg_count                 => x_msg_count,
                       x_msg_data                  => x_msg_data
                       );
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- For Automatic receipt method, bank account id should be NULL as the column is obsoleted
    l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID := NULL;
    -- gboomina Bug 6832065 - End
	END IF;


--start: |           23-Mar-07 cklee  R12 Billing enhancement project
                  -- Null out receive mathod and bank account for Sales Order and Termination Quote,
                  -- These values will be taken from the AR setup for the customer.
		  -- 08-feb-2008 ansethur  added payment trx extension  as well to get nulled out
                  nullout_rec_method(
                   p_contract_id                  => l_xfer_tbl(k).khr_id
                  ,p_Quote_number                 => l_xfer_tbl(k).Quote_number
                  ,p_sty_id                       => l_xfer_tbl(k).sty_id
                  ,p_customer_bank_account_id     => l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID
                  ,p_receipt_method_id            => l_xfer_tbl(k).RECEIPT_METHOD_ID -- irm_id
                  ,p_payment_trxn_extension_id    => inv_lines_tbl(hdr_cnt).PAYMENT_TRXN_EXTENSION_ID
                  ,x_customer_bank_account_id     => inv_lines_tbl(hdr_cnt).CUSTOMER_BANK_ACCOUNT_ID
                  ,x_receipt_method_id            => inv_lines_tbl(hdr_cnt).RECEIPT_METHOD_ID
                  ,x_payment_trxn_extension_id    => inv_lines_tbl(hdr_cnt).PAYMENT_TRXN_EXTENSION_ID
                  );

--                  inv_lines_tbl(hdr_cnt).CUSTOMER_BANK_ACCOUNT_ID := l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID;
--                  inv_lines_tbl(hdr_cnt).RECEIPT_METHOD_ID := l_xfer_tbl(k).RECEIPT_METHOD_ID;
--end: |           23-Mar-07 cklee  R12 Billing enhancement project
                  inv_lines_tbl(hdr_cnt).RECEIPT_METHOD_NAME := NULL;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_creation_method_code:'||l_creation_method_code);
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl(k).CUSTOMER_ADDRESS_ID:'||l_xfer_tbl(k).CUSTOMER_ADDRESS_ID);
    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID'||l_xfer_tbl(k).CUSTOMER_BANK_ACCOUNT_ID);
   END IF;



                  -- tax-only invoice
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                  if l_xfer_tbl(k).XLS_AMOUNT = 0 then
                  if l_xfer_tbl(k).AMOUNT = 0 then
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
                     inv_lines_tbl(hdr_cnt).QUANTITY := 0;
                  else
                     inv_lines_tbl(hdr_cnt).QUANTITY := l_xfer_tbl(k).QUANTITY;
                  end if;


                  inv_lines_tbl(hdr_cnt).QUANTITY_ORDERED := NULL;
                  inv_lines_tbl(hdr_cnt).REASON_CODE := NULL;
                  inv_lines_tbl(hdr_cnt).REASON_CODE_MEANING := NULL;
--                  inv_lines_tbl(hdr_cnt).REFERENCE_LINE_ID := NULL;
                  inv_lines_tbl(hdr_cnt).RULE_START_DATE := NULL;
                  inv_lines_tbl(hdr_cnt).SALES_ORDER := NULL;
                  inv_lines_tbl(hdr_cnt).SALES_ORDER_LINE := NULL;
                  inv_lines_tbl(hdr_cnt).SALES_ORDER_DATE := NULL;
                  inv_lines_tbl(hdr_cnt).SALES_ORDER_SOURCE := NULL;
                  inv_lines_tbl(hdr_cnt).SET_OF_BOOKS_ID := l_xfer_tbl(k).SET_OF_BOOKS_ID;

                  IF l_xfer_tbl(k).TAX_EXEMPT_FLAG = 'S' THEN
                    inv_lines_tbl(hdr_cnt).TAX_EXEMPT_FLAG := 'S';
                  ELSIF l_xfer_tbl(k).TAX_EXEMPT_FLAG = 'E' THEN
                    inv_lines_tbl(hdr_cnt).TAX_EXEMPT_FLAG := 'E';
                  ELSIF l_xfer_tbl(k).TAX_EXEMPT_FLAG = 'R' THEN
                    inv_lines_tbl(hdr_cnt).TAX_EXEMPT_FLAG := 'R';
                  ELSE
                    inv_lines_tbl(hdr_cnt).TAX_EXEMPT_FLAG := 'S';
                  END IF;

                  inv_lines_tbl(hdr_cnt).TAX_EXEMPT_NUMBER := NULL;

                  IF l_xfer_tbl(k).TAX_EXEMPT_FLAG = 'E' THEN
                    inv_lines_tbl(hdr_cnt).TAX_EXEMPT_REASON_CODE := 'MANUFACTURER';
                  ELSE
                    inv_lines_tbl(hdr_cnt).TAX_EXEMPT_REASON_CODE := NULL;
                  END IF;

                  inv_lines_tbl(hdr_cnt).TERM_ID := l_xfer_tbl(k).TERM_ID;
                  inv_lines_tbl(hdr_cnt).UNIT_SELLING_PRICE := NULL;
                  inv_lines_tbl(hdr_cnt).UNIT_STANDARD_PRICE := NULL;
                  inv_lines_tbl(hdr_cnt).UOM_CODE := l_xfer_tbl(k).uom_code;
                  inv_lines_tbl(hdr_cnt).ORG_ID := l_xfer_tbl(k).ORG_ID;
		  inv_lines_tbl(hdr_cnt).LEGAL_ENTITY_ID := l_xfer_tbl(k).LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006


                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Preparing Ra_interface_lines_all record.');
                  END IF;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').legal_entity_id:' || inv_lines_tbl(hdr_cnt).legal_entity_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').org_id:' || inv_lines_tbl(hdr_cnt).org_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').quantity:' || inv_lines_tbl(hdr_cnt).quantity);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').quantity_ordered:' || inv_lines_tbl(hdr_cnt).quantity_ordered);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').reason_code:' || inv_lines_tbl(hdr_cnt).reason_code);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').reason_code_meaning:' || inv_lines_tbl(hdr_cnt).reason_code_meaning);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').receipt_method_name:' || inv_lines_tbl(hdr_cnt).receipt_method_name);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').rule_start_date:' || inv_lines_tbl(hdr_cnt).rule_start_date);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').sales_order:' || inv_lines_tbl(hdr_cnt).sales_order);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').sales_order_date:' || inv_lines_tbl(hdr_cnt).sales_order_date);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').sales_order_line:' || inv_lines_tbl(hdr_cnt).sales_order_line);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').sales_order_source:' || inv_lines_tbl(hdr_cnt).sales_order_source);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').set_of_books_id:' || inv_lines_tbl(hdr_cnt).set_of_books_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').tax_exempt_flag:' || inv_lines_tbl(hdr_cnt).tax_exempt_flag);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').tax_exempt_number:' || inv_lines_tbl(hdr_cnt).tax_exempt_number);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').tax_exempt_reason_code:' || inv_lines_tbl(hdr_cnt).tax_exempt_reason_code);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').term_id:' || inv_lines_tbl(hdr_cnt).term_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').unit_selling_price:' || inv_lines_tbl(hdr_cnt).unit_selling_price);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').unit_standard_price:' || inv_lines_tbl(hdr_cnt).unit_standard_price);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').uom_code:' || inv_lines_tbl(hdr_cnt).uom_code);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Done Preparing Ra_interface_lines_all record.');
                  END IF;
                  -- Start Sales Tax Code

                  -- -------------------------------------
                  -- Insert Tax record
                  -- -------------------------------------

                  -- Insert tax record for ivoices and on-account credit memos
                IF NVL(l_xfer_tbl(k).TAX_EXEMPT_FLAG, 'S') <> 'E' THEN

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Preparing Ra_interface_lines_all tax record.');
                  END IF;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Preparing Ra_interface_lines_all tax record.');
                  END IF;
--start|           02-MAR-07 cklee  R12 Billing enhancement project                 |
-- ebtax integration
/*
                  open c_try_name(l_xfer_tbl(k).try_id);
                  fetch c_try_name into l_try_name;
                  close c_try_name;
*/

                IF (((l_xfer_tbl(k).try_name = 'Credit Memo') AND (l_xfer_tbl(k).rev_txn_id IS NULL))
                    OR (l_xfer_tbl(k).try_name = 'Billing')) THEN                  --- vpanwar for bug no 6401432
                 -- IF l_xfer_tbl(k).try_name IN ('Billing', 'Credit Memo') THEN   --- vpanwar for bug no 6401432
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','calling okl_process_sales_tax_pvt.get_tax_determinants');
                    END IF;
                    OKL_PROCESS_SALES_TAX_PVT.get_tax_determinants(
                      p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_source_trx_id   => l_xfer_tbl(k).TXN_ID,
                      p_source_trx_name => l_xfer_tbl(k).try_name,
                      p_source_table    => 'OKL_TXD_AR_LN_DTLS_B',
                      x_tax_det_rec     => x_tax_det_rec); -- 5902234
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','okl_process_sales_tax_pvt.get_tax_determinants returned with x_return_status:'||x_return_status);
                    END IF;


                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    --akrangan code fix  begin
		    --added to eliminate tax attributes for tax only invoices
                    IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX <> 'TAX_ONLY_INVOICE_TAX' THEN
                    -- 5902234
                    inv_lines_tbl(hdr_cnt).TAX_CODE := x_tax_det_rec.X_TAX_CODE;
                    inv_lines_tbl(hdr_cnt).TRX_BUSINESS_CATEGORY := x_tax_det_rec.X_TRX_BUSINESS_CATEGORY;
                    inv_lines_tbl(hdr_cnt).PRODUCT_CATEGORY := x_tax_det_rec.X_PRODUCT_CATEGORY;
                    inv_lines_tbl(hdr_cnt).PRODUCT_TYPE := x_tax_det_rec.X_PRODUCT_TYPE;
                    inv_lines_tbl(hdr_cnt).LINE_INTENDED_USE := x_tax_det_rec.X_LINE_INTENDED_USE;
		    --added by akrangan for ebtax billing impacts start
                    inv_lines_tbl(hdr_cnt).USER_DEFINED_FISC_CLASS := x_tax_det_rec.X_USER_DEFINED_FISC_CLASS;
		    --akrangan code fix  begin
		    END IF; --IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX <> 'TAX_ONLY_INVOICE_TAX'
                    --akrangan code fix  end
		    inv_lines_tbl(hdr_cnt).TAXED_UPSTREAM_FLAG := 'Y';
		    --added by akrangan for ebtax billing impacts end
                    inv_lines_tbl(hdr_cnt).ASSESSABLE_VALUE := x_tax_det_rec.X_ASSESSABLE_VALUE;
                    inv_lines_tbl(hdr_cnt).DEFAULT_TAXATION_COUNTRY := x_tax_det_rec.X_DEFAULT_TAXATION_COUNTRY;
                    /*inv_lines_tbl(hdr_cnt).UPSTREAM_TRX_REPORTED_FLAG := x_tax_det_rec.X_UPSTREAM_TRX_REPORTED_FLAG; */
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').tax_code:' || inv_lines_tbl(hdr_cnt).tax_code);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').trx_business_category:' || inv_lines_tbl(hdr_cnt).trx_business_category);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').product_category:' || inv_lines_tbl(hdr_cnt).product_category);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').product_type:' || inv_lines_tbl(hdr_cnt).product_type);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').line_intended_use:' || inv_lines_tbl(hdr_cnt).line_intended_use);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').user_defined_fisc_class :' || inv_lines_tbl(hdr_cnt).user_defined_fisc_class );
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').taxed_upstream_flag:' || inv_lines_tbl(hdr_cnt).taxed_upstream_flag);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').assessable_value:' || inv_lines_tbl(hdr_cnt).assessable_value);
                      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_lines_tbl('||hdr_cnt||').default_taxation_country:' || inv_lines_tbl(hdr_cnt).default_taxation_country);
                    END IF;
                  END IF;

--end|           02-MAR-07 cklee  R12 Billing enhancement project                 |

--start|           02-MAR-07 cklee  R12 Billing enhancement project                 |


                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Preparing Ra_interface_lines_all tax record.');
                  END IF;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Done Preparing Ra_interface_lines_all tax record.');
                  END IF;
                END IF;

                  -- End Sales Tax Code


                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Preparing Ra_Sales_Credits_all record.');
                  END IF;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Preparing Ra_Sales_Credits_all record.');
                  END IF;
                  -- -------------------------------------
                  -- Build Sales Credits Table
                  -- -------------------------------------
                  sales_cr_cnt := ( sales_credits_tbl.count + 1 );
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
-- Change variable name to match the main cursor query name
                IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'INVESTOR_STAKE' THEN
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE1 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Agreement_Number),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE2 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE3 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Name),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE5 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE6 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE7 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE8 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE9 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE11 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE12 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE13 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE15 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_CONTEXT := 'OKL_INVESTOR';

                  ELSE
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE1 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE2 := SUBSTR(TRIM(l_invoice_group),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE3 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_PULL_YN),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).PRIVATE_LABEL),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE5 := NULL;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE6 := SUBSTR(TRIM(l_xfer_tbl(k).CONTRACT_NUMBER),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE7 := SUBSTR(TRIM(l_xfer_tbl(k).ASSET_NUMBER),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE8 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_LINE_TYPE),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE9 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    -- if the source of the billing trx is termination quote, the OKL billing trx number is Quite_number
                    IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'TERMINATION_QUOTE' THEN
                      sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE11 := SUBSTR(TRIM(l_xfer_tbl(k).Quote_number),1,G_AR_DATA_LENGTH);
                    END IF;
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE12 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).KHR_ID)),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE13 := SUBSTR(TRIM(l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_ATTRIBUTE15 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_TYPE),1,G_AR_DATA_LENGTH);
                    sales_credits_tbl(sales_cr_cnt).INTERFACE_LINE_CONTEXT := 'OKL_CONTRACTS';
                  END IF;

--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                  sales_credits_tbl(sales_cr_cnt).SALES_CREDIT_AMOUNT_SPLIT := NULL;
                  sales_credits_tbl(sales_cr_cnt).SALES_CREDIT_PERCENT_SPLIT := 100;
                  sales_credits_tbl(sales_cr_cnt).SALES_CREDIT_TYPE_ID := l_sales_type_credit;
                  sales_credits_tbl(sales_cr_cnt).SALES_CREDIT_TYPE_NAME := 'Quota Sales Credit';
                  --vthiruva - Bug 4222231..start..removed hardcoding of sales rep
                  sales_credits_tbl(sales_cr_cnt).SALESREP_ID := l_salesrep_id;
                  sales_credits_tbl(sales_cr_cnt).SALESREP_NUMBER := l_salesrep_number;
                  --vthiruva - Bug 4222231..end
                  sales_credits_tbl(sales_cr_cnt).CREATED_BY := G_user_id;
                  sales_credits_tbl(sales_cr_cnt).CREATION_DATE := sysdate;
                  sales_credits_tbl(sales_cr_cnt).LAST_UPDATED_BY := G_user_id;
                  sales_credits_tbl(sales_cr_cnt).LAST_UPDATE_DATE := sysdate;
                  sales_credits_tbl(sales_cr_cnt).ORG_ID := l_xfer_tbl(k).ORG_ID;
                  sales_credits_tbl(sales_cr_cnt).CREATED_BY := G_user_id;
                  sales_credits_tbl(sales_cr_cnt).CREATION_DATE := sysdate;
                  sales_credits_tbl(sales_cr_cnt).LAST_UPDATED_BY := G_user_id;
                  sales_credits_tbl(sales_cr_cnt).LAST_UPDATE_DATE := sysdate;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').created_by:' || sales_credits_tbl(sales_cr_cnt).created_by);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').creation_date:' || sales_credits_tbl(sales_cr_cnt).creation_date);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute1:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute1);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute10 :' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute10);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute11 :' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute11);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute12 :' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute12);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute13 :' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute13);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute14 :' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute14);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute15 :' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute15);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute2:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute2);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute3:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute3);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute4:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute4);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute5:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute5);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute6:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute6);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute7:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute7);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute8:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute8);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_attribute9:' || sales_credits_tbl(sales_cr_cnt).interface_line_attribute9);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').interface_line_context:' || sales_credits_tbl(sales_cr_cnt).interface_line_context);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').last_update_date:' || sales_credits_tbl(sales_cr_cnt).last_update_date);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').last_updated_by:' || sales_credits_tbl(sales_cr_cnt).last_updated_by);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').org_id:' || sales_credits_tbl(sales_cr_cnt).org_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').sales_credit_amount_split:' || sales_credits_tbl(sales_cr_cnt).sales_credit_amount_split);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').sales_credit_percent_split :' || sales_credits_tbl(sales_cr_cnt).sales_credit_percent_split);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').sales_credit_type_id:' || sales_credits_tbl(sales_cr_cnt).sales_credit_type_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').sales_credit_type_name:' || sales_credits_tbl(sales_cr_cnt).sales_credit_type_name);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').salesrep_id:' || sales_credits_tbl(sales_cr_cnt).salesrep_id);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','sales_credits_tbl('||sales_cr_cnt||').salesrep_number:' || sales_credits_tbl(sales_cr_cnt).salesrep_number);
                    fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Done Preparing Ra_Sales_Credits_all record.');
                  END IF;

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Preparing Ra_Sales_Credits_all record.');
                  END IF;
                  -- -------------------------------------
                  -- Build Contingency table
                  -- -------------------------------------
                  IF (l_xfer_tbl(k).rev_rec_basis = 'CASH_RECEIPT') THEN
                      -- -------------------------------------
                      -- Build AR contingencies table
                      -- -------------------------------------
                      --begin bug 5474184
                      cont_cnt := ( ar_contingency_tbl.count + 1 );

                      BEGIN
                        SELECT AR_INTERFACE_CONTS_S.NEXTVAL
                        INTO ar_contingency_tbl(cont_cnt).INTERFACE_CONTINGENCY_ID
                        FROM DUAL;
                      EXCEPTION
                        WHEN OTHERS THEN
                            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ERROR retrieving ar_contingency_tbl(cont_cnt).INTERFACE_CONTINGENCY_ID: '
                                                        ||sqlerrm);
                            END IF;
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ERROR retrieving ar_contingency_tbl(cont_cnt).INTERFACE_CONTINGENCY_ID:'||sqlerrm);
                            END IF;
                      END;
                      --end  bug 5474184

                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Preparing ar_contingency record.');
                      END IF;
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Preparing ar_contingency record.');
                      END IF;
--                      cont_cnt := ( ar_contingency_tbl.count + 1 );
-- start: cklee 3/29/2007
                      /* 6472168
                      cont_cnt := hdr_cnt;
                      --ar_contingency_tbl(cont_cnt).CONTINGENCY_ID := ar_contingency_tbl(hdr_cnt).INTERFACE_CONTINGENCY_ID; */
                      -- 6472168
					  -- start: bug 6744584 .. contingency_id populated from stream type table rather than
					  -- a sequence id.. contingency_code is no longer used...racheruv
                      --ar_contingency_tbl(cont_cnt).CONTINGENCY_ID := ar_contingency_tbl(cont_cnt).INTERFACE_CONTINGENCY_ID;
                      ar_contingency_tbl(cont_cnt).CONTINGENCY_ID := l_xfer_tbl(k).contingency_id;

                      --ar_contingency_tbl(cont_cnt).CONTINGENCY_CODE := 'OKL_COLLECTIBILITY';
					  -- end: bug 6744584 .. contingency_id populated from stream type table rather than
-- end: cklee 3/29/2007

                      ar_contingency_tbl(cont_cnt).EXPIRATION_DATE := NULL;
                      ar_contingency_tbl(cont_cnt).EXPIRATION_DAYS := NULL;
                      ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ID := NULL;
                      ar_contingency_tbl(cont_cnt).INTERFACE_LINE_CONTEXT := 'OKL_CONTRACTS';
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
-- Change variable name to match the main cursor query name

                  IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'INVESTOR_STAKE' THEN
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE1 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Agreement_Number),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE2 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE3 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Name),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE5 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE6 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE7 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE8 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE9 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE11 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE12 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE13 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE15 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_CONTEXT := 'OKL_INVESTOR';

                  ELSE
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE1 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE2 := SUBSTR(TRIM(l_invoice_group),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE3 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_PULL_YN),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).PRIVATE_LABEL),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE5 := NULL;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE6 := SUBSTR(TRIM(l_xfer_tbl(k).CONTRACT_NUMBER),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE7 := SUBSTR(TRIM(l_xfer_tbl(k).ASSET_NUMBER),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE8 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_LINE_TYPE),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE9 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    -- if the source of the billing trx is termination quote, the OKL billing trx number is Quite_number
                    IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'TERMINATION_QUOTE' THEN
                      ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE11 := SUBSTR(TRIM(l_xfer_tbl(k).Quote_number),1,G_AR_DATA_LENGTH);
                    END IF;
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE12 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).KHR_ID)),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE13 := SUBSTR(TRIM(l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_ATTRIBUTE15 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_TYPE),1,G_AR_DATA_LENGTH);
                    ar_contingency_tbl(cont_cnt).INTERFACE_LINE_CONTEXT := 'OKL_CONTRACTS';

                  END IF;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project


                      ar_contingency_tbl(cont_cnt).ORG_ID := l_xfer_tbl(k).ORG_ID;
                      ar_contingency_tbl(cont_cnt).REQUEST_ID := NULL;
                      ar_contingency_tbl(cont_cnt).CREATED_BY := G_user_id;
                      ar_contingency_tbl(cont_cnt).CREATION_DATE := sysdate;
                      ar_contingency_tbl(cont_cnt).LAST_UPDATED_BY := G_user_id;
                      ar_contingency_tbl(cont_cnt).LAST_UPDATE_DATE := sysdate;
                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Preparing ar_contingency record.');
                      END IF;
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
						--bug 6744584 .. contingency_code is not used anymore.
                        --fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').contingency_code:' || ar_contingency_tbl(cont_cnt).contingency_code);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').contingency_id:' || ar_contingency_tbl(cont_cnt).contingency_id);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').expiration_date:' || ar_contingency_tbl(cont_cnt).expiration_date);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').expiration_days:' || ar_contingency_tbl(cont_cnt).expiration_days);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute1:' || ar_contingency_tbl(cont_cnt).interface_line_attribute1);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute10 :' || ar_contingency_tbl(cont_cnt).interface_line_attribute10);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute11 :' || ar_contingency_tbl(cont_cnt).interface_line_attribute11);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute12 :' || ar_contingency_tbl(cont_cnt).interface_line_attribute12);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute13 :' || ar_contingency_tbl(cont_cnt).interface_line_attribute13);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute14 :' || ar_contingency_tbl(cont_cnt).interface_line_attribute14);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute15 :' || ar_contingency_tbl(cont_cnt).interface_line_attribute15);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute2:' || ar_contingency_tbl(cont_cnt).interface_line_attribute2);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute3:' || ar_contingency_tbl(cont_cnt).interface_line_attribute3);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute4:' || ar_contingency_tbl(cont_cnt).interface_line_attribute4);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute5:' || ar_contingency_tbl(cont_cnt).interface_line_attribute5);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute6:' || ar_contingency_tbl(cont_cnt).interface_line_attribute6);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute7:' || ar_contingency_tbl(cont_cnt).interface_line_attribute7);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute8:' || ar_contingency_tbl(cont_cnt).interface_line_attribute8);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_attribute9:' || ar_contingency_tbl(cont_cnt).interface_line_attribute9);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_context:' || ar_contingency_tbl(cont_cnt).interface_line_context);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').interface_line_id:' || ar_contingency_tbl(cont_cnt).interface_line_id);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').org_id:' || ar_contingency_tbl(cont_cnt).org_id);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').request_id:' || ar_contingency_tbl(cont_cnt).request_id);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').created_by:' || ar_contingency_tbl(cont_cnt).created_by);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').creation_date:' || ar_contingency_tbl(cont_cnt).creation_date);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').last_updated_by:' || ar_contingency_tbl(cont_cnt).last_updated_by);
                        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','ar_contingency_tbl('||cont_cnt||').last_update_date:' || ar_contingency_tbl(cont_cnt).last_update_date);
                      END IF;
                  END IF; -- Contingency Table check
-- cklee: start: 3/7/07
--commented out for R12               END IF;
-- cklee: end: 3/7/07

               -- -------------------------------------
               -- Build AR invoice distributions table
               -- -------------------------------------
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--               IF l_xfer_tbl(k).XLS_AMOUNT <> 0 THEN
               IF l_xfer_tbl(k).AMOUNT <> 0 THEN
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Preparing inv_dist record.');
                 END IF;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
                 IF G_ACC_SYS_OPTION = 'ATS' THEN
-- get accounting disb via internal billing details table
-- rmunjulu R12 Fixes, modified to use the new signature of Get_acct_disb
                   Get_acct_disb(
                    p_tld_id               => l_xfer_tbl(k).txn_id,
                    -- Bug 9464082
                    p_try_name             => l_xfer_tbl(k).TRY_NAME,
                    -- End Bug 9464082
                    x_dist_tbl             => lx_dist_tbl);

-- rmunjulu R12 Fixes, loop through the lx_dist_tbl and populate inv_dist_tbl
-- Note : the inv_dist_tbl loop has changed from k to n ( n might be more than k)
                   IF lx_dist_tbl.COUNT > 0 THEN
                      FOR m in lx_dist_tbl.FIRST .. lx_dist_tbl.LAST LOOP

               --Commented by ssiruvol for bug 5946084
	         --akrangan uncommnetd the code here for enabling billing distribution begin
                         IF (l_xfer_tbl(k).rev_rec_basis = 'CASH_RECEIPT' AND  l_xfer_tbl(k).AMOUNT < 0
                         AND lx_dist_tbl(m).ACCOUNT_CLASS = 'REV') THEN
                            inv_dist_tbl(n).ACCOUNT_CLASS := 'UNEARN';
                         ELSE
                            inv_dist_tbl(n).ACCOUNT_CLASS := lx_dist_tbl(m).ACCOUNT_CLASS;
                         END IF;
	           --akrangan uncommnetd the code here for enabling billing distribution end
			 /*
			 --code commented by akrangan since it is breaking the billing distribution flow
               inv_dist_tbl(k).ACCOUNT_CLASS := l_xfer_tbl(k).ACCOUNT_CLASS; --Added by ssiruvol for Bug 5946084
*/

                         inv_dist_tbl(n).AMOUNT := lx_dist_tbl(m).DIST_AMOUNT;
                         inv_dist_tbl(n).PERCENT := lx_dist_tbl(m).DIST_PERCENT;

                         inv_dist_tbl(n).CODE_COMBINATION_ID := lx_dist_tbl(m).CODE_COMBINATION_ID;
                         inv_dist_tbl(n).INTERFACE_LINE_CONTEXT := 'OKL_CONTRACTS';

                          IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'INVESTOR_STAKE' THEN
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE1 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Agreement_Number),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE2 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE3 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).Investor_Name),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE5 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE6 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE7 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE8 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE9 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE11 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE12 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE13 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE15 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_CONTEXT := 'OKL_INVESTOR';

                         ELSE
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE1 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE2 := SUBSTR(TRIM(l_invoice_group),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE3 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_PULL_YN),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(l_xfer_tbl(k).PRIVATE_LABEL),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE5 := NULL;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE6 := SUBSTR(TRIM(l_xfer_tbl(k).CONTRACT_NUMBER),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE7 := SUBSTR(TRIM(l_xfer_tbl(k).ASSET_NUMBER),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE8 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_LINE_TYPE),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE9 := SUBSTR(TRIM(l_xfer_tbl(k).STREAM_TYPE),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                            -- if the source of the billing trx is termination quote, the OKL billing trx number is Quite_number
                            IF l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX = 'TERMINATION_QUOTE' THEN
                              inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE11 := SUBSTR(TRIM(l_xfer_tbl(k).Quote_number),1,G_AR_DATA_LENGTH);
                            END IF;
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE12 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).KHR_ID)),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE13 := SUBSTR(TRIM(l_xfer_tbl(k).OKL_SOURCE_BILLING_TRX),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(l_xfer_tbl(k).TXN_ID)),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_ATTRIBUTE15 := SUBSTR(TRIM(l_xfer_tbl(k).INVOICE_FORMAT_TYPE),1,G_AR_DATA_LENGTH);
                            inv_dist_tbl(n).INTERFACE_LINE_CONTEXT := 'OKL_CONTRACTS';
                         END IF;

                         inv_dist_tbl(n).ORG_ID := l_xfer_tbl(k).ORG_ID;
                         inv_dist_tbl(n).CREATED_BY := G_user_id;
                         inv_dist_tbl(n).CREATION_DATE := sysdate;
                         inv_dist_tbl(n).LAST_UPDATED_BY := G_user_id;
                         inv_dist_tbl(n).LAST_UPDATE_DATE := sysdate;

                         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Preparing inv_dist record.');
                         END IF;
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').account_class:' || inv_dist_tbl(n).account_class);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').amount:' || inv_dist_tbl(n).amount);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').code_combination_id:' || inv_dist_tbl(n).code_combination_id);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').created_by:' || inv_dist_tbl(n).created_by);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').creation_date:' || inv_dist_tbl(n).creation_date);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute1:' || inv_dist_tbl(n).interface_line_attribute1 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute10 :' || inv_dist_tbl(n).interface_line_attribute10);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute11 :' || inv_dist_tbl(n).interface_line_attribute11);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute12 :' || inv_dist_tbl(n).interface_line_attribute12);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute13 :' || inv_dist_tbl(n).interface_line_attribute13);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute14 :' || inv_dist_tbl(n).interface_line_attribute14);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute15 :' || inv_dist_tbl(n).interface_line_attribute15);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute2:' || inv_dist_tbl(n).interface_line_attribute2 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute3:' || inv_dist_tbl(n).interface_line_attribute3 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute4:' || inv_dist_tbl(n).interface_line_attribute4 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute5:' || inv_dist_tbl(n).interface_line_attribute5 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute6:' || inv_dist_tbl(n).interface_line_attribute6 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute7:' || inv_dist_tbl(n).interface_line_attribute7 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute8:' || inv_dist_tbl(n).interface_line_attribute8 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_attribute9:' || inv_dist_tbl(n).interface_line_attribute9 );
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').interface_line_context:' || inv_dist_tbl(n).interface_line_context);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').last_update_date:' || inv_dist_tbl(n).last_update_date);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').last_updated_by:' || inv_dist_tbl(n).last_updated_by);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').org_id:' || inv_dist_tbl(n).org_id);
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','inv_dist_tbl('||n||').percent:' || inv_dist_tbl(n).percent);
                        END IF;
                         n := n + 1;
                      END LOOP;

                   END IF;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
                 END IF; -- IF G_ACC_SYS_OPTION = 'ATS' THEN
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

               END IF; -- IF l_xfer_tbl(k).AMOUNT <> 0 THEN
                -- ---------------------------------
                -- Check and reset commit counter
                -- ---------------------------------

                IF l_commit_cnt > G_COMMIT_SIZE THEN
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
-- Additional check to see if all TAI related TXD records have been completed
                --Added below if condition by nikshah for bug 7696685
                IF l_xfer_tbl.exists(k+1) THEN
                  IF l_xfer_tbl(k).TAI_ID <> l_xfer_tbl(k+1).TAI_ID THEN
                    l_commit_cnt := 0;
                    COMMIT;
                  END IF;
                END IF;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
                END IF;

                -- ---------------------------------
                -- Set header_id local variable
                -- ---------------------------------

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                l_hdr_id := l_xfer_tbl(k).xsi_id;
                l_hdr_id := l_xfer_tbl(k).tai_id;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

          -- Bug#9576651 - Start
          -- Added exception block to handle exceptions raised by APIs
          EXCEPTION
            WHEN OTHERS THEN
              l_error_tai_tbl(l_error_tai_cnt) := l_xfer_tbl(k).tai_id;

              FND_FILE.put_line(fnd_file.log,
                       '--------- ERROR LOG START ---------------' );
              FND_FILE.put_line(fnd_file.log,
                       'CONTRACT_NUMBER : ' || l_xfer_tbl(k).CONTRACT_NUMBER);
              FND_FILE.put_line(fnd_file.log,
                       'ASSET_NUMBER : ' || l_xfer_tbl(k).ASSET_NUMBER);

              FND_MSG_PUB.Count_And_Get
                     (p_count         =>      x_msg_count,
                      p_data          =>      x_msg_data);


              IF x_msg_count > 0 THEN
                 FOR i IN 1..x_msg_count LOOP
                   fnd_msg_pub.get (p_msg_index => i,
                           p_encoded => 'F',
                           p_data => lx_msg_data,
                           p_msg_index_out => l_msg_index_out);
                --   FND_FILE.put_line(fnd_file.log,
                --       'ERROR (OKL_ARIntf_Pvt.Get_REC_FEEDER): ' || lx_msg_data);
                 END LOOP;
                  FND_FILE.put_line(fnd_file.log,
                       'ERROR (OKL_ARIntf_Pvt.Get_REC_FEEDER): ' || lx_msg_data);

               END IF;
              FND_FILE.put_line(fnd_file.log,
                       '--------- ERROR LOG END ---------------' );

              l_error_tai_cnt := l_error_tai_cnt + 1;
          END;
          -- Bug#9576651 - End
           END LOOP;

           -- ----------------------------------
           -- Update prev header status
           -- ----------------------------------
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--           UPDATE OKL_EXT_SELL_INVS_B
-- Update internal billing table instead
           UPDATE okl_trx_ar_invoices_b
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
           SET trx_status_code = 'PROCESSED',
               last_update_date = sysdate,
               last_updated_by = lx_last_updated_by,
               last_update_login = lx_last_update_login,
               request_id = lx_request_id,
               program_update_date = sysdate,
               program_application_id = lx_program_application_id,
               program_id = lx_program_id
           WHERE ID = l_hdr_id;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Updating last record with id: '||l_hdr_id);
          END IF;
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updating last record with id: '||l_hdr_id);
           END IF;
           COMMIT;

           -- -------------------------------------
           -- Clear error table before bulk insert
           -- -------------------------------------
           error_tbl.delete;

           -- ---------------------------------------------
           -- Transfer line records to the AR interface
           -- ---------------------------------------------

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into ra_interface_lines_all');
           END IF;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Inserting into ra_interface_lines_all');
          END IF;

           IF inv_lines_tbl.COUNT > 0 THEN
            FORALL indx in inv_lines_tbl.first..inv_lines_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO ra_interface_lines_all
                VALUES inv_lines_tbl(indx);
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into ra_interface_lines_all');
           END IF;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Done Inserting into ra_interface_lines_all');
          END IF;
           IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'For interface lines, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                END IF;

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Oracle error is ' ||
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                    -- bug 5474184
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','For interface lines, error ' || i || ' occurred during iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Oracle error is ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                error_tbl(error_tbl.count + 1).id :=   to_number(inv_lines_tbl(i).interface_line_attribute10||
--                                                               inv_lines_tbl(i).interface_line_attribute11);
                error_tbl(error_tbl.count + 1).id :=   to_number(inv_lines_tbl(i).interface_line_attribute14);
--start: |           15-FEB-07 cklee  R12 Billing enhancement project

            END LOOP;
           END IF;

           -- ---------------------------------------------
           -- Transfer sales credits records to the AR interface
           -- ---------------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into sales_credits');
           END IF;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Inserting into sales_credits');
           END IF;
           IF sales_credits_tbl.COUNT > 0 THEN
            FORALL indx in sales_credits_tbl.first..sales_credits_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
                VALUES sales_credits_tbl(indx);
           END IF;

           IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'For sales credits, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                END IF;
        		IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Oracle error is ' ||
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','For sales credits, error ' || i || ' occurred during iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Oracle error is ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                error_tbl(error_tbl.count + 1).id :=   to_number(sales_credits_tbl(i).interface_line_attribute10||
--                                                               sales_credits_tbl(i).interface_line_attribute11);
                error_tbl(error_tbl.count + 1).id :=   to_number(sales_credits_tbl(i).interface_line_attribute14);
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
            END LOOP;
           END IF;

           -- ---------------------------------------------
           -- Transfer contingency records to the AR interface
           -- ---------------------------------------------

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into ar_contingency');
           END IF;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Inserting into ar_contingency');
           END IF;
           IF ar_contingency_tbl.COUNT > 0 THEN

            FORALL indx in ar_contingency_tbl.first..ar_contingency_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO AR_INTERFACE_CONTS_ALL
                VALUES ar_contingency_tbl(indx);

           END IF;

           IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'For AR contingencies, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                END IF;

				IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Oracle error is ' ||
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','For AR contingencies, error ' || i || ' occurred during iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Oracle error is ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                error_tbl(error_tbl.count + 1).id :=   to_number(ar_contingency_tbl(i).interface_line_attribute10||
--                                                               ar_contingency_tbl(i).interface_line_attribute11);
                error_tbl(error_tbl.count + 1).id :=   to_number(ar_contingency_tbl(i).interface_line_attribute14);
--end: |           15-FEB-07 cklee  R12 Billing enhancement project
            END LOOP;
           END IF;

           -- ----------------------------------------------------------
           -- Transfer invoice distribution records to the AR interface
           -- ----------------------------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into inv_dist');
           END IF;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Inserting into inv_dist');
           END IF;
           IF inv_dist_tbl.count > 0 THEN
            FORALL indx in inv_dist_tbl.first..inv_dist_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO RA_INTERFACE_DISTRIBUTIONS_ALL
                VALUES inv_dist_tbl(indx);
           END IF;

           IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'For distributions, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                END IF;

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Oracle error is ' ||
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','For distributions, error ' || i || ' occurred during iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Oracle error is ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                error_tbl(error_tbl.count + 1).id :=   to_number(inv_dist_tbl(i).interface_line_attribute10||
--                                                               inv_dist_tbl(i).interface_line_attribute11);
                error_tbl(error_tbl.count + 1).id :=   to_number(inv_dist_tbl(i).interface_line_attribute14);
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

            END LOOP;
           END IF;

           if error_tbl.count > 0 then
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error Processing');
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Error Processing');
                END IF;
                for indx in error_tbl.FIRST..error_tbl.LAST loop

--start: |           15-FEB-07 cklee  R12 Billing enhancement project
-- Modify the error table keys to internal billing tables
                    -- UPDATE XSI trx_status_code to 'WORKING'
--                    l_error_xsi_id := NULL;
                    Begin
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
--                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'** XSI_ID is : '||l_error_xsi_id);
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'** TXD_ID is : '||error_tbl(indx).id);
                        END IF;
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','** TXD_ID is : '||error_tbl(indx).id);
                        END IF;
                    Exception
                        When Others Then
--                            l_error_xsi_id := NULL;
                            l_error_txd_id := NULL;
                            l_error_tai_id := NULL;

                            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
--                                                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'** Exception ** error_xsi_id: '||l_error_xsi_id);
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'** Exception ** error_txd_id: '||error_tbl(indx).id);
                            END IF;
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','** Exception ** error_txd_id: '||error_tbl(indx).id);
                            END IF;
                    End;
--                    update okl_ext_sell_invs_b
                    update okl_trx_ar_invoices_b tai
                    set tai.trx_status_code = 'WORKING'
--                    where id = l_error_xsi_id;
                    where id = l_error_tai_id;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

                    -- --------------------------------------------
                    -- delete records from sales credits interface
                    -- --------------------------------------------
                    delete from RA_INTERFACE_SALESCREDITS
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                    where interface_line_attribute10 = to_char(SUBSTR (error_tbl(indx).id,1, 20))
--                    and interface_line_attribute11 = to_char(SUBSTR(error_tbl(indx).id,21));
                    where interface_line_attribute14 = to_char(error_tbl(indx).id);
--endt: |           15-FEB-07 cklee  R12 Billing enhancement project

                    -- ----------------------------------
                    -- delete records from contingencies
                    -- ----------------------------------
                    delete from AR_INTERFACE_CONTS
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                    where interface_line_attribute10 = to_char(SUBSTR (error_tbl(indx).id,1, 20))
--                    and interface_line_attribute11 = to_char(SUBSTR(error_tbl(indx).id,21));
                    where interface_line_attribute14 = to_char(error_tbl(indx).id);
--endt: |           15-FEB-07 cklee  R12 Billing enhancement project

                    -- ---------------------------
                    -- delete records from distributions
                    -- ---------------------------
                    delete from RA_INTERFACE_DISTRIBUTIONS
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                    where interface_line_attribute10 = to_char(SUBSTR (error_tbl(indx).id,1, 20))
--                    and interface_line_attribute11 = to_char(SUBSTR(error_tbl(indx).id,21));
                    where interface_line_attribute14 = to_char(error_tbl(indx).id);
--endt: |           15-FEB-07 cklee  R12 Billing enhancement project

                    -- ---------------------------
                    -- delete records from lines
                    -- ---------------------------
                    delete from ra_interface_lines
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
--                    where interface_line_attribute10 = to_char(SUBSTR (error_tbl(indx).id,1, 20))
--                    and interface_line_attribute11 = to_char(SUBSTR(error_tbl(indx).id,21));
                    where interface_line_attribute14 = to_char(error_tbl(indx).id);
--endt: |           15-FEB-07 cklee  R12 Billing enhancement project

                end loop;
           end if;

        END IF; -- If PL/sql table has any records
    EXIT WHEN xfer_csr%NOTFOUND;
    END LOOP;
    CLOSE xfer_csr;

    l_xfer_tbl.delete;
    -- -----------------------------
    -- End Bulk Fetch Code
    -- -----------------------------

    -- Bug#9576651 - Start
    -- Handle the records with error

  --  IF l_error_tai_cnt > 0 THEN
      IF l_error_tai_tbl.count > 0 THEN
      -- Delete AR Interface tables
      FOR err_tai_cnt IN l_error_tai_tbl.first .. l_error_tai_tbl.last
      LOOP
        DELETE FROM RA_INTERFACE_SALESCREDITS
         WHERE interface_line_attribute14 IN
               (SELECT TLD.ID
                  FROM OKL_TXD_AR_LN_DTLS_B TLD
                     , OKL_TXL_AR_INV_LNS_B TIL
                     , OKL_TRX_AR_INVOICES_B TAI
                  WHERE TIL.ID = TLD.TIL_ID_DETAILS
                    AND TAI.ID = TIL.TAI_ID
                    AND TAI.ID = l_error_tai_tbl(err_tai_cnt));

        DELETE FROM AR_INTERFACE_CONTS
         WHERE interface_line_attribute14 IN
               (SELECT TLD.ID
                  FROM OKL_TXD_AR_LN_DTLS_B TLD
                     , OKL_TXL_AR_INV_LNS_B TIL
                     , OKL_TRX_AR_INVOICES_B TAI
                  WHERE TIL.ID = TLD.TIL_ID_DETAILS
                    AND TAI.ID = TIL.TAI_ID
                    AND TAI.ID = l_error_tai_tbl(err_tai_cnt));

        DELETE FROM RA_INTERFACE_DISTRIBUTIONS
         WHERE interface_line_attribute14 IN
               (SELECT TLD.ID
                  FROM OKL_TXD_AR_LN_DTLS_B TLD
                     , OKL_TXL_AR_INV_LNS_B TIL
                     , OKL_TRX_AR_INVOICES_B TAI
                  WHERE TIL.ID = TLD.TIL_ID_DETAILS
                    AND TAI.ID = TIL.TAI_ID
                    AND TAI.ID = l_error_tai_tbl(err_tai_cnt));

        DELETE FROM RA_INTERFACE_LINES
         WHERE interface_line_attribute14 IN
               (SELECT TLD.ID
                  FROM OKL_TXD_AR_LN_DTLS_B TLD
                     , OKL_TXL_AR_INV_LNS_B TIL
                     , OKL_TRX_AR_INVOICES_B TAI
                  WHERE TIL.ID = TLD.TIL_ID_DETAILS
                    AND TAI.ID = TIL.TAI_ID
                    AND TAI.ID = l_error_tai_tbl(err_tai_cnt));

      -- Update the OKL_TRX_AR_INVOICES_B back to Submitted status
        UPDATE OKL_TRX_AR_INVOICES_B
          SET TRX_STATUS_CODE = 'SUBMITTED'
        WHERE ID  = l_error_tai_tbl(err_tai_cnt);
      END LOOP;

      -- Update the concurrent program status to Warning
      l_conc_status:= FND_CONCURRENT.set_completion_status(status=>'WARNING',message=>NULL);
    END IF;
    -- Bug#9576651 - End

	------------------------------------------------------------
	-- Print log and output messages
	------------------------------------------------------------

    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    processed_sts       := 'PROCESSED';
    error_sts           := 'ERROR';

    l_succ_cnt          := 0;
    l_err_cnt           := 0;

--start: |           15-FEB-07 cklee  R12 Billing enhancement project                 |
     OPEN   tld_cnt_csr_selected( l_request_id);
     FETCH  tld_cnt_csr_selected INTO l_selected_count;
     CLOSE  tld_cnt_csr_selected;

     OPEN   tld_cnt_csr( l_request_id, processed_sts );
     FETCH  tld_cnt_csr INTO l_succ_cnt;
     CLOSE  tld_cnt_csr;

     -- Error Count
     OPEN   tld_cnt_csr( l_request_id, error_sts );
     FETCH  tld_cnt_csr INTO l_err_cnt;
     CLOSE  tld_cnt_csr;


--end: |           15-FEB-07 cklee  R12 Billing enhancement project                 |


    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    -- Start New Out File stmathew 15-OCT-2004
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 54, ' ')||'Oracle Leasing and Finance Management'||lpad(' ', 55, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 49, ' ')||'Receivables Invoice Transfer To AR'||lpad(' ', 49, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 49, ' ')||'----------------------------------'||lpad(' ', 49, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Operating Unit: '||l_op_unit_name);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Request Id: '||l_request_id||lpad(' ',74,' ') ||'Run Date: '||to_char(sysdate));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Currency: '||Okl_Accounting_Util.get_func_curr_code);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad('-', 132, '-'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'From Bill Date  : ' ||p_trx_date_from);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'To Bill Date    : ' ||p_trx_date_to);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad('-', 132, '-'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Processing Details:'||lpad(' ', 113, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '                Number of Invoice Lines Selected: '||l_selected_count);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '                Number of Invoice Lines Transferred: '||l_succ_cnt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '                Number of Invoice Lines Errored: '||(l_selected_count - l_succ_cnt));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    -- End New Out File stmathew 15-OCT-2004
    IF x_msg_count > 0 THEN
       FOR i IN 1..x_msg_count LOOP
            IF i = 1 THEN
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Details of Errored Invoice Lines:'||lpad(' ', 97, ' '));
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
            END IF;
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);

            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
                  TO_CHAR(i) || ': ' || lx_msg_data);
            END IF;

      END LOOP;
    END IF;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_arintf_pvt'
									,'End(-)');
    END IF;

	-- ----------------------------------------------------------
	-- End processing
	-- ----------------------------------------------------------

    -- -------------------------------------------
    -- Purge data from the Parallel process Table
    -- -------------------------------------------
    IF p_assigned_process IS NOT NULL THEN

        DELETE okl_parallel_processes
        WHERE assigned_process = p_assigned_process;

        COMMIT;

    END IF;


EXCEPTION

    WHEN bulk_errors THEN

        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE okl_parallel_processes
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

           IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Exception: For interface lines, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                END IF;
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Oracle error is ' ||
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Exception: For interface lines, error ' || i || ' occurred during iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                  fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','Oracle error is ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                -- bug 5474184
                END IF;
            END LOOP;
           END IF;

        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);

        IF x_msg_count > 0 THEN
           FOR i IN 1..x_msg_count LOOP

                fnd_msg_pub.get (p_msg_index => i,
                           p_encoded => 'F',
                           p_data => lx_msg_data,
                           p_msg_index_out => l_msg_index_out);

                FND_FILE.put_line(fnd_file.log,'ERROR (OKL_ARIntf_Pvt.Get_REC_FEEDER): ' || lx_msg_data);
          END LOOP;
        END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);

        IF x_msg_count > 0 THEN
           FOR i IN 1..x_msg_count LOOP

                fnd_msg_pub.get (p_msg_index => i,
                           p_encoded => 'F',
                           p_data => lx_msg_data,
                           p_msg_index_out => l_msg_index_out);

                FND_FILE.put_line(fnd_file.log,'ERROR (OKL_ARIntf_Pvt.Get_REC_FEEDER): ' || lx_msg_data);
          END LOOP;
        END IF;

   WHEN OTHERS THEN
        x_return_status   :=  Okl_Api.G_RET_STS_ERROR;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'INSERT Failed ' || SQLERRM);
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_arintf_pvt.get_rec_feeder.debug','INSERT Failed ' || SQLERRM);
        END IF;
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE okl_parallel_processes
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_arintf_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

END Get_REC_FEEDER;

END Okl_Arintf_Pvt;

/
