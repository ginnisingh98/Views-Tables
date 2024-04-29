--------------------------------------------------------
--  DDL for Package Body OKL_BPD_ADVANCED_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_ADVANCED_BILLING_PVT" AS
/* $Header: OKLRABLB.pls 120.29.12010000.10 2010/05/11 22:49:39 sechawla ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
    G_MODULE VARCHAR2(255) := 'LEASE.RECEIVABLES.BILLING';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
    -- vpanwar 20-July-07 -- interface line length increase from 30 to 150
    G_AR_DATA_LENGTH CONSTANT VARCHAR2(4) := '150';
    -- end vpanwar 20-July-07 -- interface line length increase from 30 to 150
    G_ACC_SYS_OPTION VARCHAR2(4);
-- G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BPD_ADVANCED_BILLING_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : nullout_rec_method
-- Description     : This logic is migrated from okl_internal_to_external
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE nullout_rec_method(
    p_contract_id                  IN NUMBER
   ,p_Quote_number                 IN NUMBER
   ,p_sty_id                       IN NUMBER
   ,p_customer_bank_account_id     IN NUMBER
   ,p_receipt_method_id            IN NUMBER -- irm_id
   ,p_payment_trxn_extension_id    IN NUMBER --Bug 7623549
   ,x_customer_bank_account_id     OUT NOCOPY NUMBER
   ,x_receipt_method_id            OUT NOCOPY NUMBER
   ,x_payment_trxn_extension_id    OUT NOCOPY NUMBER --Bug 7623549
 )
IS
    l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
 lx_remrkt_sty_id number;

BEGIN

      IF p_contract_id IS NOT NULL THEN
        --bug 5160519 : Sales Order Billing
        -- Order Management sales for remarketing, these billing details are
        --purely from the Order, so if payment method,Bank Account is not passed,
        --then pass as NULL.

        --get primary stream type for remarketing stream
        Okl_Streams_Util.get_primary_stream_type(p_contract_id,
		                                        'ASSET_SALE_RECEIVABLE',
												 l_return_status,
												 lx_remrkt_sty_id);

        IF l_return_status = Okl_Api.g_ret_sts_success THEN

          IF(lx_remrkt_sty_id = p_sty_id) THEN

            x_customer_bank_account_id := NULL;
            x_receipt_method_id := NULL;
            x_payment_trxn_extension_id:=NULL; -- Bug 7623549
          ELSE
            x_customer_bank_account_id := p_customer_bank_account_id;
            x_receipt_method_id := p_receipt_method_id;
            x_payment_trxn_extension_id:= p_payment_trxn_extension_id; -- Bug 7623549

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
          x_payment_trxn_extension_id:=NULL; -- Bug 7623549
        ELSE
          x_customer_bank_account_id := p_customer_bank_account_id;
          x_receipt_method_id := p_receipt_method_id;
          x_payment_trxn_extension_id:= p_payment_trxn_extension_id; -- Bug 7623549

        END IF;

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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BPD_ADVANCED_BILLING_PVT',
               'EXCEPTION :'||'OTHERS');
        END IF;

end nullout_rec_method;

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


EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in Get_chr_inv_grp');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BPD_ADVANCED_BILLING_PVT',
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
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE Get_acct_disb(
   p_tld_id               IN NUMBER
   ,x_account_class        OUT NOCOPY VARCHAR2
   ,x_dist_amount          OUT NOCOPY VARCHAR2
   ,x_dist_percent         OUT NOCOPY VARCHAR2
   ,x_code_combination_id  OUT NOCOPY VARCHAR2
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

begin


      FOR acc_dtls_rec IN acc_dstrs_csr(p_tld_id, 'OKL_TXD_AR_LN_DTLS_B')
      LOOP

        x_code_combination_id := acc_dtls_rec.code_combination_id;
        x_dist_amount := acc_dtls_rec.amount;
        x_dist_percent := acc_dtls_rec.percentage;

        IF acc_dtls_rec.amount > 0 THEN

          IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            x_account_class := 'REV';
          ELSE
            x_account_class := 'REC';
          END IF;
        ELSE
          IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            x_account_class := 'REC';
          ELSE
            x_account_class := 'REV';
          END IF;
        END IF;

        --Start code changes for rev rec by fmiao on 10/05/2004
        IF(acc_dtls_rec.comments = 'CASH_RECEIPT'
           AND x_account_class <> 'REC')
           OR(acc_dtls_rec.comments <> 'CASH_RECEIPT') THEN

          IF(acc_dtls_rec.comments = 'CASH_RECEIPT') THEN
            x_account_class := 'UNEARN';
          END IF;

        END IF;

     END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in Get_acct_disb');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BPD_ADVANCED_BILLING_PVT',
               'EXCEPTION :'||'OTHERS');
        END IF;

end Get_acct_disb;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_customer_id
-- Description     :
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

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

      --modified by pgomes on 21-aug-2003 for rules migration
      -- Get the customer acct id
      OPEN  get_khr_id_csr(l_contract_number);
      FETCH get_khr_id_csr INTO l_customer_id;
      CLOSE get_khr_id_csr;

      --commented out by pgomes on 21-aug-2003 for rules migration

EXCEPTION
    WHEN OTHERS THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Failure in Get_Customer_Id');
        END IF;

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_BPD_ADVANCED_BILLING_PVT',
               'EXCEPTION :'||'OTHERS');
        END IF;

END get_customer_id;
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |


  --------------------------------------------
  -- Prepare batch_source Name record
  --------------------------------------------
  PROCEDURE PREPARE_BATCH_SOURCE_REC(
     x_return_status    OUT NOCOPY VARCHAR2
    ,p_trx_date         IN  DATE
    ,l_batch_source_rec OUT NOCOPY AR_INVOICE_API_PUB.batch_source_rec_type)
  IS
   CURSOR batch_src_csr( p_in_date DATE ) IS
          SELECT BATCH_SOURCE_ID
          FROM ra_batch_sources_all
          WHERE NAME = 'OKL_MANUAL'
          AND   START_DATE <= p_in_date
          AND   (END_DATE IS NULL OR p_in_date > END_DATE)
         --gkhuntet staRT
         AND   ORG_ID = MO_GLOBAL.get_current_org_id();
         --gkhuntet end.
  BEGIN

       x_return_status := OKL_API.G_RET_STS_SUCCESS;
       -------------------------------------------
       -- Fetch Batch Source Id for OKL_CONTRACTS
       -------------------------------------------
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'Fetching Batch Source');
       -- Establish Savepoint for rollback
         DBMS_TRANSACTION.SAVEPOINT('PREPARE_BATCH_SOURCE_REC_PVT');
       -- Savepoint established

       OPEN  batch_src_csr( p_trx_date );
       FETCH batch_src_csr INTO l_batch_source_rec.batch_source_id;
       IF (batch_src_csr%NOTFOUND) THEN
         CLOSE batch_src_csr;
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error: Unable to retrieve Batch Source');
 		 RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
       CLOSE batch_src_csr;
       l_batch_source_rec.default_date := p_trx_date;

       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PREPARE_BATCH_SOURCE_REC, p_trx_date: '||p_trx_date
       ||' l_batch_source_rec.default_date: '||l_batch_source_rec.default_date);

  EXCEPTION
	WHEN OTHERS THEN
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END PREPARE_BATCH_SOURCE_REC;


  --------------------------------------------
  -- Prepare Transaction Header Table
  --------------------------------------------
  PROCEDURE PREPARE_TRX_HDR_TBL(
                 x_return_status   OUT NOCOPY VARCHAR2
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--                ,r_xsiv_rec        IN  Okl_Ext_Sell_Invs_Pub.xsiv_rec_type
--                ,r_xlsv_rec        IN  Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type
                ,xfer_rec          IN OKL_ARINTF_PVT.xfer_rec_type
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
            -- rkuttiya added for bug 7209767
                ,p_source          IN VARCHAR2
                ,l_trx_header_tbl  OUT NOCOPY AR_INVOICE_API_PUB.trx_header_tbl_type
                 )
  IS

lx_customer_id number;
--Bug 7623549 START

    --11-MAY-10 sechawla  9692959
    --l_api_version         NUMBER := '1.0';
    l_api_version         NUMBER := 1.0;
    --11-MAY-10 sechawla  9692959

    l_init_msg_list       VARCHAR2(1):= OKL_API.G_FALSE;
    l_khr_id              NUMBER;
    l_return_status       VARCHAR2(100);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_payment_trxn_extension_id NUMBER := NULL;
    l_creation_method_code AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
    l_bank_line_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;
--Bug 7623549 END

	l_ship_to		      NUMBER;
	l_kle_id 		      NUMBER;
    l_top_kle_id          NUMBER;
    l_chr_id              okc_k_lines_b.chr_id%TYPE;
    l_asset_name          okc_k_lines_v.name%TYPE;
    l_install_location_id NUMBER;
    l_location_id         NUMBER;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--    l_exempt_flg          okl_ext_sell_invs_v.tax_exempt_flag%TYPE;
    l_exempt_flg          okl_trx_ar_invoices_b.tax_exempt_flag%TYPE;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
/*commented out for R12
    CURSOR get_kle_id ( p_lsm_id NUMBER ) IS
       SELECT kle_id
       FROM OKL_CNSLD_AR_STRMS_V
       WHERE id = p_lsm_id;

    CURSOR check_top_line ( p_cle_id NUMBER ) IS
       SELECT chr_id
       FROM okc_k_lines_b
       where id = p_cle_id;

    CURSOR derive_top_line_id (p_lsm_id   NUMBER) IS
       SELECT FA.ID
       FROM OKC_K_HEADERS_B CHR,
            OKC_K_LINES_B TOP_CLE,
            OKC_LINE_STYLES_b TOP_LSE,
            OKC_K_LINES_B SUB_CLE,
            OKC_LINE_STYLES_b SUB_LSE,
            OKC_K_ITEMS CIM,
            OKC_K_LINES_V  FA,
            OKC_LINE_STYLES_B AST_LSE,
            OKL_CNSLD_AR_STRMS_B LSM
       WHERE
            CHR.ID           = TOP_CLE.DNZ_CHR_ID              AND
            TOP_CLE.LSE_ID   = TOP_LSE.ID                      AND
            TOP_LSE.LTY_CODE IN('SOLD_SERVICE','FEE')          AND
            TOP_CLE.ID       = SUB_CLE.CLE_ID                  AND
            SUB_CLE.LSE_ID   = SUB_LSE.ID                      AND
            SUB_LSE.LTY_CODE IN ('LINK_SERV_ASSET', 'LINK_FEE_ASSET') AND
            SUB_CLE.ID       =  LSM.KLE_ID                     AND
            LSM.ID           =  p_lsm_id                       AND
            CIM.CLE_ID       = SUB_CLE.ID                      AND
            CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'              AND
            CIM.OBJECT1_ID1  = FA.ID                           AND
            FA.LSE_ID        = AST_LSE.ID                      AND
            AST_LSE.LTY_CODE = 'FREE_FORM1';
*/
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

    CURSOR top_line_asset ( p_cle_id NUMBER ) IS
       SELECT name
       FROM  okc_k_lines_v
       WHERE id = p_cle_id;


    CURSOR Ship_to_csr( p_kle_top_line IN NUMBER ) IS
        SELECT --cim.object1_id1 item_instance,
       	       --cim.object1_id2 "#",
       	       csi.install_location_id
             , csi.location_id
        FROM   csi_item_instances csi,
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
    CURSOR tax_exmpt_csr ( p_flg VARCHAR2 ) IS
           SELECT decode(p_flg,'S','S','E','E','R','R','S')
           FROM DUAL;

    --stmathew - Bug 4372869/4222231..start
    CURSOR sales_rep_csr(p_salesrep_id IN ra_salesreps.salesrep_id%TYPE) IS
       SELECT SALESREP_ID, NAME
       FROM ra_salesreps
       WHERE SALESREP_ID = p_salesrep_id;

    --cursor to fetch the sales rep for the contract.
    CURSOR get_sales_rep(p_contract_number okc_k_headers_b.contract_number%TYPE) IS
       SELECT contact.object1_id1
       FROM okc_k_headers_b hdr, okc_contacts contact
       WHERE contact.dnz_chr_id = hdr.id
       AND hdr.contract_number = p_contract_number
       AND contact.cro_code = 'SALESPERSON';

    l_salesrep_id          ra_salesreps.SALESREP_ID%TYPE;
    l_salesrep_name        ra_salesreps.NAME%TYPE;
    l_sales_person         okc_contacts_v.object1_id1%TYPE;
    --stmathew - Bug 4372869/4222231..end
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

    lxfer_rec OKL_ARINTF_PVT.xfer_rec_type;

-- rmunjulu R12 Fixes
l_customer_address_id OKL_TRX_AR_INVOICES_V.ibt_id%TYPE;
l_customer_bank_account_id OKL_TRX_AR_INVOICES_V.customer_bank_account_id%TYPE;
l_recept_method_id OKL_TRX_AR_INVOICES_V.irm_id%TYPE;

  BEGIN
      -- Assign IN record to local record
      lxfer_rec  := xfer_rec;

       x_return_status := OKL_API.G_RET_STS_SUCCESS;

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
                  -- 1. Check if it's a top line
       OPEN is_top_line(lxfer_rec.kle_id);
       FETCH is_top_line INTO l_is_top_line;
       is_top_line_flag := is_top_line%FOUND;
       CLOSE is_top_line;

       -- 2. get top line if needed
       IF NOT is_top_line_flag THEN
         OPEN get_top_line(lxfer_rec.kle_id);
         FETCH get_top_line INTO lxfer_rec.kle_id;
         CLOSE get_top_line;
       END IF;

       -- 3. get top line name (asset number)
       OPEN get_top_line_name(lxfer_rec.kle_id);
       FETCH get_top_line_name INTO lxfer_rec.ASSET_NUMBER;
       CLOSE get_top_line_name;

--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |

       l_chr_id := lxfer_rec.khr_id;
       l_kle_id := lxfer_rec.kle_id;
/* commented out for R12
       -- To find the top line kle_id
       l_kle_id     := NULL;
       l_top_kle_id := NULL;

       -- Find top line kle_id
       OPEN  get_kle_id ( r_xlsv_rec.lsm_id );
       FETCH get_kle_id INTO l_top_kle_id;
       CLOSE get_kle_id;

       l_chr_id := NULL;

       OPEN  check_top_line( l_top_kle_id );
       FETCH check_top_line INTO l_chr_id;
       CLOSE check_top_line;

       IF l_chr_id IS NOT NULL THEN
            l_kle_id := l_top_kle_id;
       ELSE
            l_top_kle_id := NULL;
            OPEN  derive_top_line_id ( r_xlsv_rec.lsm_id );
            FETCH derive_top_line_id INTO l_top_kle_id;
            CLOSE derive_top_line_id;
            l_kle_id := l_top_kle_id;
       END IF;
*/
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       l_asset_name := NULL;
       OPEN  top_line_asset ( l_kle_id );
       FETCH top_line_asset INTO l_asset_name;
       CLOSE top_line_asset;

       OPEN  ship_to_csr(l_kle_id);
       FETCH ship_to_csr INTO l_install_location_id, l_location_id;
       CLOSE ship_to_csr;

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- Migrated the following logic from oklarintf_pvt
       -- Check if Vendor is the same as the customer on the Contract
       lx_customer_id := NULL;
       get_customer_id(  lxfer_rec.CONTRACT_NUMBER ,lx_customer_id );

       l_ship_to := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       OPEN  Ship_to_csr2( r_xsiv_rec.CUSTOMER_ID, l_install_location_id, l_location_id, r_xsiv_rec.ORG_ID);
       OPEN  Ship_to_csr2( lx_customer_id, l_install_location_id, l_location_id, lxfer_rec.ORG_ID);
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       FETCH Ship_to_csr2 INTO l_ship_to;
       CLOSE Ship_to_csr2;

       IF ( lx_customer_id = lxfer_rec.CUSTOMER_ID ) THEN
         NULL;
       ELSE
         l_ship_to := NULL;
       END IF;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       --stmathew - Bug 4372869/4222231..start
       l_salesrep_id       := NULL;
       l_salesrep_name     := NULL;
       --if the contract has an associated sales rep, fetch the
       --salesrep id and name
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       OPEN get_sales_rep(r_xlsv_rec.xtrx_contract);
       OPEN get_sales_rep(lxfer_rec.contract_number);
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       FETCH get_sales_rep INTO l_sales_person;
       IF get_sales_rep%FOUND THEN
         OPEN sales_rep_csr(l_sales_person);
         FETCH sales_rep_csr INTO l_salesrep_id, l_salesrep_name;
         CLOSE sales_rep_csr;
       END IF;
       CLOSE get_sales_rep;
       --stmathew - Bug 4372869/4222231..end


       l_trx_header_tbl(1).trx_header_id            := 110; --???????????????????????????
       l_trx_header_tbl(1).trx_number               := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       l_trx_header_tbl(1).trx_date                 := r_xsiv_rec.TRX_DATE;
--       l_trx_header_tbl(1).trx_currency             := r_xsiv_rec.CURRENCY_CODE;
       l_trx_header_tbl(1).trx_date                 := lxfer_rec.TRX_DATE;
       l_trx_header_tbl(1).trx_currency             := lxfer_rec.CURRENCY_CODE;
       l_trx_header_tbl(1).reference_number         := NULL;
       l_trx_header_tbl(1).trx_class                := NULL;
--       l_trx_header_tbl(1).cust_trx_type_id         := r_xsiv_rec.CUST_TRX_TYPE_ID;
       l_trx_header_tbl(1).cust_trx_type_id         := lxfer_rec.CUST_TRX_TYPE_ID;
--	   l_trx_header_tbl(1).gl_date			        := SYSDATE; --r_xsiv_rec.TRX_DATE;
	   l_trx_header_tbl(1).gl_date			        := lxfer_rec.TRX_DATE;-- the same as oklarintf_pvt
--       l_trx_header_tbl(1).bill_to_customer_id      := r_xsiv_rec.CUSTOMER_ID;
       l_trx_header_tbl(1).bill_to_customer_id      := lxfer_rec.CUSTOMER_ID;
       l_trx_header_tbl(1).bill_to_account_number   := NULL;
       l_trx_header_tbl(1).bill_to_customer_name    := NULL;
       l_trx_header_tbl(1).bill_to_contact_id       := NULL;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- get bill-to information from contract line if any

-- rmunjulu - R12 Fixes -- take the customer_address_id, customer_bank_account_id
-- and receipt_method_id into different variables
-- or else (since the in and out varaibles are same) the values are getting passed
-- as NULLs
                  l_customer_address_id := lxfer_rec.CUSTOMER_ADDRESS_ID;
                  l_customer_bank_account_id := lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID;
                  l_recept_method_id := lxfer_rec.RECEIPT_METHOD_ID;

                  OKL_ARINTF_PVT.get_cust_config_from_line(
                   p_kle_id                       => lxfer_rec.KLE_ID
                  ,p_customer_address_id          => l_customer_address_id
                  ,p_customer_bank_account_id     => l_customer_bank_account_id
                  ,p_receipt_method_id            => l_recept_method_id
                  ,x_customer_address_id          => lxfer_rec.CUSTOMER_ADDRESS_ID
                  ,x_customer_bank_account_id     => lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID
                  ,x_receipt_method_id            => lxfer_rec.RECEIPT_METHOD_ID
                  ,x_creation_method_code         => l_creation_method_code --Bug 7623549
                  ,x_bank_line_id1                => l_bank_line_id1 --Bug 7623549
                  );
--end: |           28-Mar-07 cklee  R12 Billing enhancement project

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       l_trx_header_tbl(1).bill_to_address_id       := r_xsiv_rec.CUSTOMER_ADDRESS_ID;
       l_trx_header_tbl(1).bill_to_address_id       := lxfer_rec.CUSTOMER_ADDRESS_ID;
       l_trx_header_tbl(1).bill_to_site_use_id      := NULL;
--       l_trx_header_tbl(1).ship_to_customer_id      := r_xsiv_rec.CUSTOMER_ID;
       l_trx_header_tbl(1).ship_to_customer_id      := lxfer_rec.CUSTOMER_ID;
       l_trx_header_tbl(1).ship_to_account_number   := NULL;
       l_trx_header_tbl(1).ship_to_customer_name    := NULL;
       l_trx_header_tbl(1).ship_to_contact_id       := NULL;
       l_trx_header_tbl(1).ship_to_address_id       := NVL(l_ship_to , lxfer_rec.CUSTOMER_ADDRESS_ID);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '.... l_ship_to '||l_ship_to);
       l_trx_header_tbl(1).ship_to_site_use_id      := NULL;
       l_trx_header_tbl(1).sold_to_customer_id      := NULL;
--       l_trx_header_tbl(1).term_id                  := r_xsiv_rec.TERM_ID;
--       l_trx_header_tbl(1).LEGAL_ENTITY_ID          := r_xsiv_rec.LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006
       l_trx_header_tbl(1).term_id                  := lxfer_rec.TERM_ID;
       l_trx_header_tbl(1).LEGAL_ENTITY_ID          := lxfer_rec.LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006
       l_trx_header_tbl(1).ORG_ID                  := lxfer_rec.ORG_ID; -- migrated from oklarintf_pvt

       --stmathew - Bug 4372869/4222231..start
       --removed hardcoded null and passing salesrep id and name if present
       l_trx_header_tbl(1).primary_salesrep_id      := l_salesrep_id;
       l_trx_header_tbl(1).primary_salesrep_name    := l_salesrep_name;
       --stmathew - Bug 4372869/4222231..end

       l_trx_header_tbl(1).territory_id             := NULL;
       l_trx_header_tbl(1).remit_to_address_id      := NULL;
       l_trx_header_tbl(1).invoicing_rule_id        := NULL;
       l_trx_header_tbl(1).printing_option	        := NULL;

       l_trx_header_tbl(1).purchase_order	        := NULL;
	   l_trx_header_tbl(1).purchase_order_revision	:= NULL;
	   l_trx_header_tbl(1).purchase_order_date	    := NULL;
	   l_trx_header_tbl(1).comments
--                := NVL (NVL (r_xlsv_rec.DESCRIPTION, r_xsiv_rec.DESCRIPTION), 'OKL Billing');
          := NVL (NVL (lxfer_rec.LINE_DESCRIPTION, lxfer_rec.HDR_DESCRIPTION), 'OKL Billing');
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

	   l_trx_header_tbl(1).internal_notes	        := NULL;
       l_trx_header_tbl(1).finance_charges	        := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       l_trx_header_tbl(1).receipt_method_id	    := r_xsiv_rec.RECEIPT_METHOD_ID;

--rkuttiya added the IF condition for PPD for bug # 7558039
         IF p_source <> 'PRINCIPAL_PAYDOWN' THEN
-- rmunjulu -- R12 Fixes -- do not null out record before assigning to trx_header_tbl
	   l_trx_header_tbl(1).receipt_method_id	    := lxfer_rec.RECEIPT_METHOD_ID;

           --Bug 7623549 START
           l_trx_header_tbl(1).customer_bank_account_id := lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID;

           IF (l_creation_method_code = 'AUTOMATIC') THEN
             l_khr_id := lxfer_rec.khr_id;
             OKL_ARINTF_PVT.get_auto_bank_dtls(
                                p_api_version               => l_api_version,
                                p_init_msg_list             => l_init_msg_list,
                                p_khr_id                    => l_khr_id,
                                p_customer_address_id       => lxfer_rec.CUSTOMER_ADDRESS_ID,
                                p_bank_id                   => lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID,
                                p_trx_date                  => lxfer_rec.trx_date,
                                x_payment_trxn_extension_id => l_payment_trxn_extension_id,
                                x_customer_bank_account_id  => l_trx_header_tbl(1).customer_bank_account_id,
                                x_return_status             => l_return_status,
                                x_msg_count                 => l_msg_count,
                                x_msg_data                  => l_msg_data
                               );

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;
             END IF;
             -- For Automatic receipt method, bank account id should be NULL as the column is obsoleted
             l_trx_header_tbl(1).customer_bank_account_id := NULL;
             lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID := NULL;
           END IF;
           --Bug 7623549 END

                  -- Null out receive mathod and bank account for Sales Order and Termination Quote,
                  -- These values will be taken from the AR setup for the customer.
                  nullout_rec_method(
                   p_contract_id                  => lxfer_rec.khr_id
                  ,p_Quote_number                 => lxfer_rec.Quote_number
                  ,p_sty_id                       => lxfer_rec.sty_id
                  ,p_customer_bank_account_id     => l_trx_header_tbl(1).customer_bank_account_id
                  ,p_receipt_method_id            => l_trx_header_tbl(1).receipt_method_id -- irm_id
                  ,p_payment_trxn_extension_id    => l_payment_trxn_extension_id -- Bug 7623549
                  ,x_customer_bank_account_id     => l_trx_header_tbl(1).CUSTOMER_BANK_ACCOUNT_ID
                  ,x_receipt_method_id            => l_trx_header_tbl(1).receipt_method_id
                  ,x_payment_trxn_extension_id    => l_trx_header_tbl(1).payment_trxn_extension_id -- Bug 7623549
                  );
         END IF; --rkuttiya added

	   --l_trx_header_tbl(1).receipt_method_id	    := lxfer_rec.RECEIPT_METHOD_ID; -- rmunjulu -- R12 Fixes
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       l_trx_header_tbl(1).related_customer_trx_id  := NULL;
       l_trx_header_tbl(1).agreement_id             := NULL;
	   l_trx_header_tbl(1).ship_via	                := NULL;
	   l_trx_header_tbl(1).ship_date_actual	        := NULL;
	   l_trx_header_tbl(1).waybill_number	        := NULL;
	   l_trx_header_tbl(1).fob_point	            := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--	   l_trx_header_tbl(1).customer_bank_account_id	:= r_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID;
        --rkuttiya added for bug # 7558039
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Source : '|| p_source);
        IF p_source <> 'PRINCIPAL_PAYDOWN' THEN
	   l_trx_header_tbl(1).customer_bank_account_id	:= lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID;
        ELSE
           l_trx_header_tbl(1).payment_trxn_extension_id := NULL;
        END IF;
	   l_trx_header_tbl(1).default_ussgl_transaction_code
                                                    := NULL;
       l_trx_header_tbl(1).status_trx	            := NULL;
	   l_trx_header_tbl(1).paying_customer_id	    := NULL;
	   l_trx_header_tbl(1).paying_site_use_id	    := NULL;

       l_exempt_flg := NULL;
--       OPEN  tax_exmpt_csr ( r_xsiv_rec.TAX_EXEMPT_FLAG );
       OPEN  tax_exmpt_csr ( lxfer_rec.TAX_EXEMPT_FLAG );
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       FETCH tax_exmpt_csr INTO l_exempt_flg;
       CLOSE tax_exmpt_csr;

	   l_trx_header_tbl(1).default_tax_exempt_flag
                    := l_exempt_flg;
       l_trx_header_tbl(1).doc_sequence_value        := NULL;
       l_trx_header_tbl(1).attribute_category        := NULL;
       l_trx_header_tbl(1).attribute1                := NULL;
       l_trx_header_tbl(1).attribute2                := NULL;
       l_trx_header_tbl(1).attribute3                := NULL;
       l_trx_header_tbl(1).attribute4                := NULL;
       l_trx_header_tbl(1).attribute5                := NULL;
       l_trx_header_tbl(1).attribute6                := NULL;
       l_trx_header_tbl(1).attribute7                := NULL;
       l_trx_header_tbl(1).attribute8                := NULL;
       l_trx_header_tbl(1).attribute9                := NULL;
       l_trx_header_tbl(1).attribute10               := NULL;
       l_trx_header_tbl(1).global_attribute_category := NULL;
       l_trx_header_tbl(1).global_attribute1         := NULL;
       l_trx_header_tbl(1).global_attribute2         := NULL;
       l_trx_header_tbl(1).global_attribute3         := NULL;
       l_trx_header_tbl(1).global_attribute4         := NULL;
       l_trx_header_tbl(1).global_attribute5         := NULL;
       l_trx_header_tbl(1).global_attribute6         := NULL;
       l_trx_header_tbl(1).global_attribute7         := NULL;
       l_trx_header_tbl(1).global_attribute8         := NULL;
       l_trx_header_tbl(1).global_attribute9         := NULL;
       l_trx_header_tbl(1).global_attribute10        := NULL;
       l_trx_header_tbl(1).global_attribute11        := NULL;
       l_trx_header_tbl(1).global_attribute12        := NULL;
       l_trx_header_tbl(1).global_attribute13        := NULL;
       l_trx_header_tbl(1).global_attribute14        := NULL;
       l_trx_header_tbl(1).global_attribute15        := NULL;
       l_trx_header_tbl(1).global_attribute16        := NULL;
       l_trx_header_tbl(1).global_attribute17        := NULL;
       l_trx_header_tbl(1).global_attribute18        := NULL;
       l_trx_header_tbl(1).global_attribute19        := NULL;
       l_trx_header_tbl(1).global_attribute20        := NULL;
       l_trx_header_tbl(1).global_attribute21        := NULL;
       l_trx_header_tbl(1).global_attribute22        := NULL;
       l_trx_header_tbl(1).global_attribute23        := NULL;
       l_trx_header_tbl(1).global_attribute24        := NULL;
       l_trx_header_tbl(1).global_attribute25        := NULL;
       l_trx_header_tbl(1).global_attribute26        := NULL;
       l_trx_header_tbl(1).global_attribute27        := NULL;
       l_trx_header_tbl(1).global_attribute28        := NULL;
       l_trx_header_tbl(1).global_attribute29        := NULL;
       l_trx_header_tbl(1).global_attribute30        := NULL;


  EXCEPTION
     WHEN OTHERS THEN
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END PREPARE_TRX_HDR_TBL;

  --------------------------------------------
  -- Prepare Transaction Lines Table
  --------------------------------------------
  PROCEDURE PREPARE_TRX_LNS_TBL(
                 x_return_status OUT NOCOPY VARCHAR2
                ,p_num           IN  NUMBER
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--                ,r_xsiv_rec        IN  Okl_Ext_Sell_Invs_Pub.xsiv_rec_type
--                ,r_xlsv_rec        IN  Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type
                ,xfer_rec        IN OKL_ARINTF_PVT.xfer_rec_type
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,l_trx_lines_tbl OUT NOCOPY AR_INVOICE_API_PUB.trx_line_tbl_type)
  IS

  l_group_by_contract_yn okl_invoice_types_v.group_by_contract_yn%type;
  l_group_asset_yn okl_invoice_types_v.group_asset_yn%type;
  l_contract_level_yn okl_invoice_formats_v.contract_level_yn%type;
  l_invoice_group okl_invoice_formats_v.name%type;
  l_khr_id okc_k_headers_b.id%type;
  x_tax_det_rec OKL_PROCESS_SALES_TAX_PVT.tax_det_rec_type;
    l_api_version       NUMBER	:= 1.0;
    x_msg_count		NUMBER;
    x_msg_data	VARCHAR2(4000);
    l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;

	l_ship_to		      NUMBER;
	l_kle_id 		      NUMBER;
    l_top_kle_id          NUMBER;
    l_chr_id              okc_k_lines_b.chr_id%TYPE;
    l_asset_name          okc_k_lines_v.name%TYPE;
    l_install_location_id NUMBER;
    l_location_id         NUMBER;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--    l_exempt_flg          okl_ext_sell_invs_v.tax_exempt_flag%TYPE;
    l_exempt_flg          okl_trx_ar_invoices_b.tax_exempt_flag%TYPE;
/* commented out for R12
    CURSOR get_kle_id ( p_lsm_id NUMBER ) IS
       SELECT kle_id
       FROM OKL_CNSLD_AR_STRMS_V
       WHERE id = p_lsm_id;

    CURSOR check_top_line ( p_cle_id NUMBER ) IS
       SELECT chr_id
       FROM okc_k_lines_b
       where id = p_cle_id;

    CURSOR derive_top_line_id (p_lsm_id   NUMBER) IS
       SELECT FA.ID
       FROM OKC_K_HEADERS_B CHR,
            OKC_K_LINES_B TOP_CLE,
            OKC_LINE_STYLES_b TOP_LSE,
            OKC_K_LINES_B SUB_CLE,
            OKC_LINE_STYLES_b SUB_LSE,
            OKC_K_ITEMS CIM,
            OKC_K_LINES_V  FA,
            OKC_LINE_STYLES_B AST_LSE,
            OKL_CNSLD_AR_STRMS_B LSM
       WHERE
            CHR.ID           = TOP_CLE.DNZ_CHR_ID              AND
            TOP_CLE.LSE_ID   = TOP_LSE.ID                      AND
            TOP_LSE.LTY_CODE IN('SOLD_SERVICE','FEE')          AND
            TOP_CLE.ID       = SUB_CLE.CLE_ID                  AND
            SUB_CLE.LSE_ID   = SUB_LSE.ID                      AND
            SUB_LSE.LTY_CODE IN ('LINK_SERV_ASSET', 'LINK_FEE_ASSET') AND
            SUB_CLE.ID       =  LSM.KLE_ID                     AND
            LSM.ID           =  p_lsm_id                       AND
            CIM.CLE_ID       = SUB_CLE.ID                      AND
            CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'              AND
            CIM.OBJECT1_ID1  = FA.ID                           AND
            FA.LSE_ID        = AST_LSE.ID                      AND
            AST_LSE.LTY_CODE = 'FREE_FORM1';
*/
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

    CURSOR top_line_asset ( p_cle_id NUMBER ) IS
       SELECT name
       FROM  okc_k_lines_v
       WHERE id = p_cle_id;


    CURSOR Ship_to_csr( p_kle_top_line IN NUMBER ) IS
        SELECT --cim.object1_id1 item_instance,
       	       --cim.object1_id2 "#",
       	       csi.install_location_id
             , csi.location_id
        FROM   csi_item_instances csi,
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


--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- migrated from oklarintf_pvt
    lx_customer_id     NUMBER;
    l_temp_sold_fee      VARCHAR2(1);
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
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

    l_inv_id        NUMBER;
    l_uom_code      mtl_system_items.primary_uom_code%TYPE;

    CURSOR get_inv_item_id ( p_fin_asset_line_id NUMBER ) IS
        SELECT c.OBJECT1_ID1
        FROM okc_k_lines_b a,
             okc_line_styles_b b,
             okc_k_items c
        WHERE a.cle_id   = p_fin_asset_line_id
        AND   b.lty_code = 'ITEM'
        AND   a.lse_id   = b.id
        AND   a.id       = c.cle_id;

    CURSOR get_uom_code ( p_inv_item_id NUMBER ) IS
       SELECT primary_uom_code
       FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id;

    CURSOR tax_exmpt_csr ( p_flg VARCHAR2 ) IS
           SELECT decode(p_flg,'S','S','E','E','R','R','S')
           FROM DUAL;

    CURSOR tax_exmpt_reason_csr ( p_flg VARCHAR2 ) IS
           SELECT decode(p_flg,'E','MANUFACTURER',NULL)
           FROM dual;

    l_reason_code       VARCHAR2(30);

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- Migrated logic from okl_arintf_pvt
    CURSOR get_memo_line_id_csr IS
        SELECT MEMO_LINE_ID
        FROM ar_memo_lines
        WHERE NAME = 'Lease Upfront Tax';

l_memo_line_id   ar_memo_lines.memo_line_id%TYPE;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
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
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
    CURSOR l_get_inv_org_yn_csr(cp_org_id IN NUMBER) IS
        SELECT lease_inv_org_yn
        FROM OKL_SYSTEM_PARAMS
        WHERE org_id = cp_org_id;

    l_rev_rec_basis     okl_strm_type_b.accrual_yn%type;
    l_org_id            NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
    l_use_inv_org       VARCHAR2(10) := NULL;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

    lxfer_rec OKL_ARINTF_PVT.xfer_rec_type;

  BEGIN

    -- Assign to local record
    lxfer_rec := xfer_rec;

       x_return_status := OKL_API.G_RET_STS_SUCCESS;

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- Migrated logic from okl_arintf_pvt
    -- get memo line id for tax only invoices
    l_memo_line_id := NULL;
    OPEN  get_memo_line_id_csr;
    FETCH get_memo_line_id_csr INTO l_memo_line_id;
    CLOSE get_memo_line_id_csr;

    if l_memo_line_id is null then
        FND_FILE.PUT_LINE(FND_FILE.LOG,
        'WARNING: A memo line with name -- Lease Upfront Tax,
        must exist to import tax-only invoices.');
    end if;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       -- To find the top line kle_id
       l_kle_id     := NULL;
       l_top_kle_id := NULL;

--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
                  -- 1. Check if it's a top line
       OPEN is_top_line(lxfer_rec.kle_id);
       FETCH is_top_line INTO l_is_top_line;
       is_top_line_flag := is_top_line%FOUND;
       CLOSE is_top_line;

       -- 2. get top line if needed
       IF NOT is_top_line_flag THEN
         OPEN get_top_line(lxfer_rec.kle_id);
         FETCH get_top_line INTO lxfer_rec.kle_id;
         CLOSE get_top_line;
       END IF;

       -- 3. get top line name (asset number)
       OPEN get_top_line_name(lxfer_rec.kle_id);
       FETCH get_top_line_name INTO lxfer_rec.ASSET_NUMBER;
       CLOSE get_top_line_name;

--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
       l_chr_id := lxfer_rec.khr_id;
       l_kle_id := lxfer_rec.kle_id;
/* commented out for R12
       -- Find top line kle_id
       OPEN  get_kle_id ( r_xlsv_rec.lsm_id );
       FETCH get_kle_id INTO l_top_kle_id;
       CLOSE get_kle_id;

       l_chr_id := NULL;
       OPEN  check_top_line( l_top_kle_id );
       FETCH check_top_line INTO l_chr_id;
       CLOSE check_top_line;

       IF l_chr_id IS NOT NULL THEN
            l_kle_id := l_top_kle_id;
       ELSE
            l_top_kle_id := NULL;
            OPEN  derive_top_line_id ( r_xlsv_rec.lsm_id );
            FETCH derive_top_line_id INTO l_top_kle_id;
            CLOSE derive_top_line_id;
            l_kle_id := l_top_kle_id;
       END IF;
*/
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       l_asset_name := NULL;
       OPEN  top_line_asset ( l_kle_id );
       FETCH top_line_asset INTO l_asset_name;
       CLOSE top_line_asset;

       OPEN  ship_to_csr(l_kle_id);
       FETCH ship_to_csr INTO l_install_location_id, l_location_id;
       CLOSE ship_to_csr;


--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- Migrated the following logic from oklarintf_pvt
       -- Check if Vendor is the same as the customer on the Contract
       lx_customer_id := NULL;
       get_customer_id(  lxfer_rec.CONTRACT_NUMBER ,lx_customer_id );

       l_ship_to := NULL;
--       OPEN  Ship_to_csr2( r_xsiv_rec.CUSTOMER_ID, l_install_location_id, l_location_id, r_xsiv_rec.ORG_ID);
       OPEN  Ship_to_csr2( lx_customer_id, l_install_location_id, l_location_id, lxfer_rec.ORG_ID);
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       FETCH Ship_to_csr2 INTO l_ship_to;
       CLOSE Ship_to_csr2;

       IF ( lx_customer_id = lxfer_rec.CUSTOMER_ID ) THEN
         NULL;
       ELSE
         l_ship_to := NULL;
       END IF;

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
       -- Get Inventory_item_id
       l_inv_id := NULL;
--       OPEN  get_inv_item_id ( l_kle_id );
--       FETCH get_inv_item_id INTO l_inv_id;
--       CLOSE get_inv_item_id;
-- Migrated the following logic from oklarintf_pvt
       l_temp_sold_fee := NULL;
       OPEN  sold_service_fee_csr ( l_kle_id );
       FETCH sold_service_fee_csr INTO l_temp_sold_fee;
       CLOSE sold_service_fee_csr;

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

       -- Get UOM Code
       l_uom_code := NULL;
       IF lxfer_rec.INVENTORY_ITEM_ID IS NULL THEN
         lxfer_rec.INVENTORY_ITEM_ID := l_inv_id;
         OPEN  get_uom_code ( l_inv_id );
         FETCH get_uom_code INTO l_uom_code;
         CLOSE get_uom_code;
       ELSE
         OPEN  get_uom_code ( lxfer_rec.INVENTORY_ITEM_ID );
         FETCH get_uom_code INTO l_uom_code;
         CLOSE get_uom_code;
       END IF;

       -- Get UOM Code
--       l_uom_code := NULL;
--       OPEN  get_uom_code ( l_inv_id );
--       FETCH get_uom_code INTO l_uom_code;
--       CLOSE get_uom_code;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       l_trx_lines_tbl(1).trx_header_id          := 110; --????????????????????
       l_trx_lines_tbl(1).trx_line_id            := p_num;
       l_trx_lines_tbl(1).link_to_trx_line_id    := NULL;
       l_trx_lines_tbl(1).LINE_NUMBER	         := 1; --p_num;
       l_trx_lines_tbl(1).REASON_CODE	         := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       l_trx_lines_tbl(1).INVENTORY_ITEM_ID	     :=l_inv_id;
       l_trx_lines_tbl(1).INVENTORY_ITEM_ID	     := lxfer_rec.INVENTORY_ITEM_ID;
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '.... Inventory_Item Id '||l_inv_id);
       l_trx_lines_tbl(1).DESCRIPTION
--          := NVL (NVL (r_xlsv_rec.DESCRIPTION, r_xsiv_rec.DESCRIPTION), 'OKL Billing');
          := NVL (NVL (lxfer_rec.LINE_DESCRIPTION, lxfer_rec.HDR_DESCRIPTION), 'OKL Billing');
--       l_trx_lines_tbl(1).QUANTITY_ORDERED	     := r_xlsv_rec.QUANTITY;

--start: migrated from oklarintf_pvt
--       l_trx_lines_tbl(1).QUANTITY_ORDERED	     := lxfer_rec.QUANTITY;
       l_trx_lines_tbl(1).QUANTITY_ORDERED	     := NULL;
       if lxfer_rec.AMOUNT = 0 then
         l_trx_lines_tbl(1).QUANTITY_INVOICED := 0;
       else
         l_trx_lines_tbl(1).QUANTITY_INVOICED := lxfer_rec.QUANTITY;
       end if;
--       l_trx_lines_tbl(1).QUANTITY_INVOICED	     := 1;
--end: migrated from oklarintf_pvt
--       l_trx_lines_tbl(1).UNIT_STANDARD_PRICE	 := r_xlsv_rec.AMOUNT;
--       l_trx_lines_tbl(1).UNIT_SELLING_PRICE	 := r_xlsv_rec.AMOUNT;
       l_trx_lines_tbl(1).UNIT_STANDARD_PRICE	 := lxfer_rec.AMOUNT;
       l_trx_lines_tbl(1).UNIT_SELLING_PRICE	 := lxfer_rec.AMOUNT;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       l_trx_lines_tbl(1).SALES_ORDER	         := NULL;
       l_trx_lines_tbl(1).SALES_ORDER_LINE	     := NULL;
       l_trx_lines_tbl(1).SALES_ORDER_DATE	     := NULL;
       l_trx_lines_tbl(1).ACCOUNTING_RULE_ID	 := NULL;

       l_trx_lines_tbl(1).LINE_TYPE	             := 'LINE';
       l_trx_lines_tbl(1).ATTRIBUTE_CATEGORY	 := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE1	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE2	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE3	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE4	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE5	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE6	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE7	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE8	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE9	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE10	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE11	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE12	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE13	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE14	         := NULL;
       l_trx_lines_tbl(1).ATTRIBUTE15	         := NULL;
       l_trx_lines_tbl(1).RULE_START_DATE	     := NULL;
       l_trx_lines_tbl(1).INTERFACE_LINE_CONTEXT	   := 'OKL_CONTRACTS';
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
/*
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE1
            := SUBSTR(LTRIM(RTRIM(r_xsiv_rec.XTRX_CONS_INVOICE_NUMBER)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE2
            := SUBSTR(LTRIM(RTRIM(r_xsiv_rec.XTRX_FORMAT_TYPE)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE3
            := SUBSTR(LTRIM(RTRIM(r_xsiv_rec.XTRX_INVOICE_PULL_YN)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE4
            := SUBSTR(LTRIM(RTRIM(r_xsiv_rec.XTRX_PRIVATE_LABEL)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE5
            := SUBSTR(LTRIM(RTRIM(r_xlsv_rec.XTRX_CONS_LINE_NUMBER)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE6
            := SUBSTR(LTRIM(RTRIM(r_xlsv_rec.XTRX_CONTRACT)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE7
            := SUBSTR(LTRIM(RTRIM(l_asset_name)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE8
            := SUBSTR(LTRIM(RTRIM(r_xlsv_rec.XTRX_STREAM_GROUP)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE9
            := SUBSTR(LTRIM(RTRIM(r_xlsv_rec.XTRX_STREAM_TYPE)),1,30);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE10
            := SUBSTR (r_xlsv_rec.XTRX_CONS_STREAM_ID,  1, 20);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE11
            := SUBSTR (r_xlsv_rec.XTRX_CONS_STREAM_ID, 21);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE12	:= NULL;
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE13	:= NULL;
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE14	:= NULL;
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE15	:= NULL;
*/
--start: |           15-FEB-07 cklee  R12 Billing enhancement project
       -- get invoice group related data
       Get_chr_inv_grp(
                    p_inf_id                => lxfer_rec.inf_id
                   ,p_sty_id                => lxfer_rec.sty_id
                   ,x_group_by_contract_yn  => l_group_by_contract_yn
                   ,x_contract_level_yn     => l_contract_level_yn
                   ,x_group_asset_yn        => l_group_asset_yn
                   ,x_invoice_group         => l_invoice_group
       );

       l_khr_id := lxfer_rec.KHR_ID;
       lxfer_rec.KHR_ID := NULL;
       --l_kle_id := l_xfer_tbl(k).KLE_ID;
       --l_xfer_tbl(k).KLE_ID := NULL;
       IF (l_group_by_contract_yn  = 'Y' OR l_contract_level_yn = 'N') THEN
         lxfer_rec.KHR_ID := l_khr_id;
         --IF l_group_by_assets_yn = 'N' THEN
         --  l_xfer_tbl(k).KLE_ID := l_kle_id;
         --END IF;
       END IF;
--end: |           15-FEB-07 cklee  R12 Billing enhancement project

       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE1 := NULL;
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE2 := SUBSTR(TRIM(l_invoice_group),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE3 := SUBSTR(TRIM(lxfer_rec.INVOICE_PULL_YN),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE4 := SUBSTR(TRIM(lxfer_rec.PRIVATE_LABEL),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE5 := NULL;
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE6 := SUBSTR(TRIM(lxfer_rec.CONTRACT_NUMBER),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE7 := SUBSTR(TRIM(lxfer_rec.ASSET_NUMBER),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE8 := SUBSTR(TRIM(lxfer_rec.INVOICE_FORMAT_LINE_TYPE),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE9 := SUBSTR(TRIM(lxfer_rec.STREAM_TYPE),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE10 := SUBSTR(TRIM(TO_CHAR(lxfer_rec.TXN_ID)),1,G_AR_DATA_LENGTH);
       -- if the source of the billing trx is termination quote, the OKL billing trx number is Quite_number
       IF lxfer_rec.OKL_SOURCE_BILLING_TRX = 'TERMINATION_QUOTE' THEN
         l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE11 := SUBSTR(TRIM(lxfer_rec.Quote_number),1,G_AR_DATA_LENGTH);
       END IF;
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE12 := SUBSTR(TRIM(TO_CHAR(lxfer_rec.KHR_ID)),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE13 := SUBSTR(TRIM(lxfer_rec.OKL_SOURCE_BILLING_TRX),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE14 := SUBSTR(TRIM(TO_CHAR(lxfer_rec.TXN_ID)),1,G_AR_DATA_LENGTH);
       l_trx_lines_tbl(1).INTERFACE_LINE_ATTRIBUTE15 := SUBSTR(TRIM(lxfer_rec.INVOICE_FORMAT_TYPE),1,G_AR_DATA_LENGTH);

--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       l_trx_lines_tbl(1).SALES_ORDER_SOURCE	        := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       l_trx_lines_tbl(1).AMOUNT	                    := r_xlsv_rec.AMOUNT;
       l_trx_lines_tbl(1).AMOUNT	                    := lxfer_rec.AMOUNT;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       l_trx_lines_tbl(1).TAX_PRECEDENCE	            := NULL;
       l_trx_lines_tbl(1).TAX_RATE	                    := NULL;
       l_trx_lines_tbl(1).TAX_EXEMPTION_ID	            := NULL;

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
-- Migrated logic from okl_arintf_pvt
       if lxfer_rec.AMOUNT = 0 then
         l_trx_lines_tbl(1).MEMO_LINE_ID := l_memo_line_id;
       else
         l_trx_lines_tbl(1).MEMO_LINE_ID := NULL;
       end if;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       l_trx_lines_tbl(1).UOM_CODE	                    := l_uom_code;
       l_trx_lines_tbl(1).DEFAULT_USSGL_TRANSACTION_CODE := NULL;
       l_trx_lines_tbl(1).DEFAULT_USSGL_TRX_CODE_CONTEXT := NULL;
       l_trx_lines_tbl(1).VAT_TAX_ID	                 := NULL;

       l_exempt_flg := NULL;
--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
--       OPEN  tax_exmpt_csr ( r_xsiv_rec.TAX_EXEMPT_FLAG );
       OPEN  tax_exmpt_csr ( lxfer_rec.TAX_EXEMPT_FLAG );
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |
       FETCH tax_exmpt_csr INTO l_exempt_flg;
       CLOSE tax_exmpt_csr;

       l_trx_lines_tbl(1).TAX_EXEMPT_FLAG	            := l_exempt_flg;
       l_trx_lines_tbl(1).TAX_EXEMPT_NUMBER	            := NULL;

       l_reason_code := NULL;
       OPEN  tax_exmpt_reason_csr ( l_exempt_flg );
       FETCH tax_exmpt_reason_csr INTO l_reason_code;
       CLOSE tax_exmpt_reason_csr;

       l_trx_lines_tbl(1).TAX_EXEMPT_REASON_CODE	    := l_reason_code;
       l_trx_lines_tbl(1).TAX_VENDOR_RETURN_CODE	    := NULL;

--start:           02-APR-07 cklee  R12 Billing enhancement project                 |
       IF lxfer_rec.try_name IN ('Billing', 'Credit Memo') THEN

                    OKL_PROCESS_SALES_TAX_PVT.get_tax_determinants(
                      p_api_version     => l_api_version,
                      p_init_msg_list   => l_init_msg_list,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_source_trx_id   => lxfer_rec.TXN_ID,
                      p_source_trx_name => lxfer_rec.try_name,
                      p_source_table    => 'OKL_TXD_AR_LN_DTLS_B',
                      x_tax_det_rec     => x_tax_det_rec);


                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

--                    l_trx_lines_tbl(1).TAX_CODE := x_tax_det_rec.x_TAX_CODE;
/*                      inv_lines_tbl(hdr_cnt).TRX_BUSINESS_CATEGORY := x_tax_det_rec.x_TRX_BUSINESS_CATEGORY;                    */
/*                      inv_lines_tbl(hdr_cnt).PRODUCT_CATEGORY := x_tax_det_rec.x_PRODUCT_CATEGORY;                    */
/*                      inv_lines_tbl(hdr_cnt).PRODUCT_TYPE := x_tax_det_rec.x_PRODUCT_TYPE;                    */
/*                      inv_lines_tbl(hdr_cnt).LINE_INTENDED_USE := x_tax_det_rec.x_LINE_INTENDED_USE;                    */
/*                      inv_lines_tbl(hdr_cnt).USER_DEFINED_FISC_CLASS := x_tax_det_rec.x_USER_DEFINED_FISC_CLASS;                    */
/*                      inv_lines_tbl(hdr_cnt).ASSESSABLE_VALUE := x_tax_det_rec.x_ASSESSABLE_VALUE;                    */
/*                      inv_lines_tbl(hdr_cnt).DEFAULT_TAXATION_COUNTRY := x_tax_det_rec.x_DEFAULT_TAXATION_COUNTRY;                    */
/*                      inv_lines_tbl(hdr_cnt).UPSTREAM_TRX_REPORTED_FLAG := x_tax_det_rec.x_UPSTREAM_TRX_REPORTED_FLAG;                    */

       END IF;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |


       l_trx_lines_tbl(1).MOVEMENT_ID	                := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE1	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE2	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE3	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE4	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE5	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE6	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE7	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE8	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE9	            := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE10	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE11	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE12	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE13	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE14	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE15	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE16	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE17	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE18	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE19	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE20	        := NULL;
       l_trx_lines_tbl(1).GLOBAL_ATTRIBUTE_CATEGORY	    := NULL;
       l_trx_lines_tbl(1).AMOUNT_INCLUDES_TAX_FLAG	    := NULL;

--start:           02-APR-07 cklee  R12 Billing enhancement project
-- Migrated from OKL_ARIntf_Pvt                 |
       OPEN l_get_inv_org_yn_csr( l_org_id );
       FETCH l_get_inv_org_yn_csr INTO l_use_inv_org;
       CLOSE l_get_inv_org_yn_csr;

       -- Populate warehouse_id
       IF (NVL(l_use_inv_org, 'N') = 'Y') THEN
       --if it is a Remarketing invoice
         IF (lxfer_rec.inventory_org_id IS NOT NULL) THEN
           l_trx_lines_tbl(1).warehouse_id := lxfer_rec.inventory_org_id;
         END IF;
       ELSE
         l_trx_lines_tbl(1).warehouse_id := NULL;
       END IF;
--       l_trx_lines_tbl(1).WAREHOUSE_ID	                := NULL;
--end:           02-APR-07 cklee  R12 Billing enhancement project                 |

       l_trx_lines_tbl(1).CONTRACT_LINE_ID	            := NULL;
       l_trx_lines_tbl(1).SOURCE_DATA_KEY1	            := NULL;
       l_trx_lines_tbl(1).SOURCE_DATA_KEY2	            := NULL;
       l_trx_lines_tbl(1).SOURCE_DATA_KEY3	            := NULL;
       l_trx_lines_tbl(1).SOURCE_DATA_KEY4	            := NULL;
       l_trx_lines_tbl(1).SOURCE_DATA_KEY5	            := NULL;
       l_trx_lines_tbl(1).INVOICED_LINE_ACCTG_LEVEL	    := NULL;
       l_trx_lines_tbl(1).SHIP_DATE_ACTUAL	            := NULL;

  EXCEPTION
     WHEN OTHERS THEN
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END PREPARE_TRX_LNS_TBL;


  --------------------------------------------
  -- Prepare Distributions Table
  --------------------------------------------
  PROCEDURE PREPARE_TRX_DIST_TBL(
             x_return_status  OUT NOCOPY VARCHAR2
            ,p_line_id        IN  NUMBER
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--            ,r_xsiv_rec        IN  Okl_Ext_Sell_Invs_Pub.xsiv_rec_type
--            ,r_xlsv_rec        IN  Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type
            ,xfer_rec         IN OKL_ARINTF_PVT.xfer_rec_type
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
            ,l_trx_dist_tbl   OUT NOCOPY AR_INVOICE_API_PUB.trx_dist_tbl_type )
  IS
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
      CURSOR dist_csr ( p_xls_id NUMBER ) IS
            SELECT *
            FROM OKL_XTD_SELL_INVS_V
            WHERE XLS_ID = p_xls_id;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

      i     NUMBER;
      lxfer_rec OKL_ARINTF_PVT.xfer_rec_type;
  BEGIN

    -- Assign IN to local record
    lxfer_rec := xfer_rec;

       x_return_status := OKL_API.G_RET_STS_SUCCESS;

       i := 0;
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
       FOR dist_rec IN dist_csr ( r_xlsv_rec.id ) LOOP
            i := i + 1;

            l_trx_dist_tbl(i).trx_dist_id              := i;
            l_trx_dist_tbl(i).trx_header_id		   	   := 110;

            IF dist_rec.ACCOUNT_CLASS <> 'REC' THEN
                l_trx_dist_tbl(i).trx_LINE_ID	           := p_line_id;
            END IF;

            l_trx_dist_tbl(i).ACCOUNT_CLASS	           := dist_rec.ACCOUNT_CLASS;
            l_trx_dist_tbl(i).AMOUNT	               := dist_rec.AMOUNT;
            l_trx_dist_tbl(i).acctd_amount             := dist_rec.AMOUNT;
            l_trx_dist_tbl(i).PERCENT	               := dist_rec.PERCENT;
            l_trx_dist_tbl(i).CODE_COMBINATION_ID	   := dist_rec.CODE_COMBINATION_ID;
            l_trx_dist_tbl(i).ATTRIBUTE_CATEGORY	   := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE1	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE2	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE3	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE4	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE5	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE6	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE7	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE8	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE9	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE10	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE11	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE12	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE13	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE14	           := NULL;
            l_trx_dist_tbl(i).ATTRIBUTE15	           := NULL;
            l_trx_dist_tbl(i).COMMENTS	               := NULL;
       END LOOP;
*/
       IF G_ACC_SYS_OPTION = 'ATS' THEN
-- get accounting disb via internal billing details table
         Get_acct_disb(
            p_tld_id               => lxfer_rec.txn_id
           ,x_account_class        => lxfer_rec.account_class
           ,x_dist_amount          => lxfer_rec.dist_amount
           ,x_dist_percent         => lxfer_rec.dist_percent
           ,x_code_combination_id  => lxfer_rec.code_combination_id
         );

         IF (lxfer_rec.rev_rec_basis = 'CASH_RECEIPT' AND  lxfer_rec.AMOUNT < 0
                      AND lxfer_rec.ACCOUNT_CLASS = 'REV') THEN
           l_trx_dist_tbl(i).ACCOUNT_CLASS := 'UNEARN';
         ELSE
           l_trx_dist_tbl(i).ACCOUNT_CLASS := lxfer_rec.ACCOUNT_CLASS;
         END IF;
         l_trx_dist_tbl(i).AMOUNT := lxfer_rec.DIST_AMOUNT;
         l_trx_dist_tbl(i).PERCENT := lxfer_rec.DIST_PERCENT;

         l_trx_dist_tbl(i).acctd_amount := lxfer_rec.DIST_AMOUNT; -- cklee

         l_trx_dist_tbl(i).CODE_COMBINATION_ID := lxfer_rec.CODE_COMBINATION_ID;
/*
         l_trx_dist_tbl(i).ORG_ID := lxfer_rec.ORG_ID;
         l_trx_dist_tbl(i).CREATED_BY := G_user_id;
         l_trx_dist_tbl(i).CREATION_DATE := sysdate;
         l_trx_dist_tbl(i).LAST_UPDATED_BY := G_user_id;
         l_trx_dist_tbl(i).LAST_UPDATE_DATE := sysdate;
*/
        END IF; -- IF G_ACC_SYS_OPTION = 'ATS' THEN

--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

  EXCEPTION
     WHEN OTHERS THEN
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END PREPARE_TRX_DIST_TBL;

  ------------------------------------------------------------------
  -- Procedure ADVANCED_BILLING to bill outstanding stream elements
  ------------------------------------------------------------------
  PROCEDURE ADVANCED_BILLING
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2
	,p_from_bill_date	IN  DATE
	,p_to_bill_date		IN  DATE
	,p_source      		IN  VARCHAR2
        ,x_ar_inv_tbl           OUT NOCOPY ar_inv_tbl_type
        ,p_ppd_flow             IN VARCHAR2 DEFAULT 'N'
 ) IS

    	-- ---------------------------------------------------------
    	-- Declare variables required by APIs
    	-- ---------------------------------------------------------
    	l_api_version	CONSTANT NUMBER        := 1;
    	l_api_name	    CONSTANT VARCHAR2(30)  := 'ADVANCED_BILLING';
    	l_return_status	VARCHAR2(1)            := Okl_Api.G_RET_STS_SUCCESS;

--start: |           02-APR-07 cklee  R12 Billing enhancement project

  --gkhuntet - FP Bug 5516814..start
	 CURSOR  c_get_adv_rcpt_for_cont(cp_cont_number IN VARCHAR2) IS
	    SELECT  DISTINCT c.contract_number
        FROM    okl_trx_csh_rcpt_all_b a,  okl_txl_rcpt_apps_b b,
okc_k_headers_b c
        WHERE   a.FULLY_APPLIED_FLAG = 'N'
        AND    a.receipt_type = 'ADV'
        AND    a.id = b.rct_id_details
        AND    b.khr_id = c.id
        AND    c.sts_code IN ('BOOKED', 'EVERGREEN','TERMINATED')
        AND    c.contract_number = NVL(cp_cont_number ,c.contract_number)
    --gkhuntet - FP Bug 5516814..end
    --dkagrawa added union for ppd to to select contract number even if there is no advance receipt for contract
        UNION
        SELECT cp_cont_number
        FROM dual
        WHERE p_ppd_flow = 'Y';

    CURSOR l_get_inv_org_yn_csr(cp_org_id IN NUMBER) IS
        SELECT lease_inv_org_yn
        FROM OKL_SYSTEM_PARAMS
        WHERE org_id = cp_org_id;

    l_rev_rec_basis     okl_strm_type_b.accrual_yn%type;
    l_org_id            NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
    l_use_inv_org       VARCHAR2(10) := NULL;

  l_group_by_contract_yn okl_invoice_types_v.group_by_contract_yn%type;
  l_group_asset_yn okl_invoice_types_v.group_asset_yn%type;
  l_contract_level_yn okl_invoice_formats_v.contract_level_yn%type;
  l_invoice_group okl_invoice_formats_v.name%type;
  l_khr_id okc_k_headers_b.id%type;

        CURSOR acc_sys_option is
        select account_derivation
		from okl_sys_acct_opts;
--end: |           02-APR-07 cklee  R12 Billing enhancement project

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/*commented out for R12
        CURSOR xsi_csr ( p_contract_number IN VARCHAR2 ) IS
            SELECT
                A.ID,
                A.OBJECT_VERSION_NUMBER,
                A.SFWT_FLAG,
                A.ISI_ID,
                A.TRX_DATE,
                A.CUSTOMER_ID,
                A.RECEIPT_METHOD_ID,
                A.TERM_ID,
                A.CURRENCY_CODE,
                A.CURRENCY_CONVERSION_TYPE,
                A.CURRENCY_CONVERSION_RATE,
                A.CURRENCY_CONVERSION_DATE,
                A.CUSTOMER_ADDRESS_ID,
                A.SET_OF_BOOKS_ID,
                A.RECEIVABLES_INVOICE_ID,
                A.CUST_TRX_TYPE_ID,
                A.INVOICE_MESSAGE,
                A.DESCRIPTION,
                A.XTRX_CONS_INVOICE_NUMBER,
                A.XTRX_FORMAT_TYPE,
                A.XTRX_PRIVATE_LABEL,
                A.ATTRIBUTE_CATEGORY,
                A.ATTRIBUTE1,
                A.ATTRIBUTE2,
                A.ATTRIBUTE3,
                A.ATTRIBUTE4,
                A.ATTRIBUTE5,
                A.ATTRIBUTE6,
                A.ATTRIBUTE7,
                A.ATTRIBUTE8,
                A.ATTRIBUTE9,
                A.ATTRIBUTE10,
                A.ATTRIBUTE11,
                A.ATTRIBUTE12,
                A.ATTRIBUTE13,
                A.ATTRIBUTE14,
                A.ATTRIBUTE15,
                A.REFERENCE_LINE_ID,
                A.TRX_NUMBER,
                A.CUSTOMER_BANK_ACCOUNT_ID,
                A.TAX_EXEMPT_FLAG,
                A.TAX_EXEMPT_REASON_CODE,
                A.XTRX_INVOICE_PULL_YN,
                A.TRX_STATUS_CODE,
                A.REQUEST_ID,
                A.PROGRAM_APPLICATION_ID,
                A.PROGRAM_ID,
                A.PROGRAM_UPDATE_DATE,
                A.ORG_ID,
                A.CREATED_BY,
                A.CREATION_DATE,
                A.LAST_UPDATED_BY,
                A.LAST_UPDATE_DATE,
                A.LAST_UPDATE_LOGIN,
		A.LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
          FROM Okl_Ext_Sell_Invs_V a,
               Okl_Xtl_Sell_Invs_V b
          WHERE a.ID = b.XSI_ID_DETAILS
          AND xtrx_contract = p_contract_number
          AND trx_status_code = 'ENTERED';


        CURSOR xls_csr ( p_xsi_id IN NUMBER ) IS
            SELECT
                B.ID,
                B.OBJECT_VERSION_NUMBER,
                B.SFWT_FLAG,
                B.TLD_ID,
                B.LSM_ID,
                B.TIL_ID,
                B.ILL_ID,
                B.XSI_ID_DETAILS,
                B.LINE_TYPE,
                B.DESCRIPTION,
                B.AMOUNT,
                B.QUANTITY,
                B.XTRX_CONS_LINE_NUMBER,
                B.XTRX_CONTRACT,
                B.XTRX_ASSET,
                B.XTRX_STREAM_GROUP,
                B.XTRX_STREAM_TYPE,
                B.XTRX_CONS_STREAM_ID,
                B.ISL_ID,
                B.SEL_ID,
                B.ATTRIBUTE_CATEGORY,
                B.ATTRIBUTE1,
                B.ATTRIBUTE2,
                B.ATTRIBUTE3,
                B.ATTRIBUTE4,
                B.ATTRIBUTE5,
                B.ATTRIBUTE6,
                B.ATTRIBUTE7,
                B.ATTRIBUTE8,
                B.ATTRIBUTE9,
                B.ATTRIBUTE10,
                B.ATTRIBUTE11,
                B.ATTRIBUTE12,
                B.ATTRIBUTE13,
                B.ATTRIBUTE14,
                B.ATTRIBUTE15,
                B.REQUEST_ID,
                B.PROGRAM_APPLICATION_ID,
                B.PROGRAM_ID,
                B.PROGRAM_UPDATE_DATE,
                B.ORG_ID,
                B.CREATED_BY,
                B.CREATION_DATE,
                B.LAST_UPDATED_BY,
                B.LAST_UPDATE_DATE,
                B.LAST_UPDATE_LOGIN
          FROM Okl_Xtl_Sell_Invs_V b
          WHERE b.xsi_id_details = p_xsi_id;
*/
-- added the following cusor to retrieve billing from internal tables

        CURSOR xfer_csr ( p_contract_number IN VARCHAR2 ) IS
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
-- start: bug 6744584 .. racheruv. get the contingency_id and pass to AR
--        for cash basis rev rec method on stream type.
		, STY.CONTINGENCY_ID
-- end  : bug 6744584 .. racheruv
       FROM OKL_TXD_AR_LN_DTLS_B TLD,
            OKL_TXL_AR_INV_LNS_V TIL,
            OKL_TRX_AR_INVOICES_V TAI,
            OKC_K_HEADERS_ALL_B  KHR,
--start:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
--            OKC_K_LINES_V KLE,
--end:|  06-Apr-2007 cklee -- Fixed kle_id, asset_number issues                    |
            OKL_STRM_TYPE_V  STY,
            OKL_TRX_TYPES_TL TRYT--,
--            OKL_PARALLEL_PROCESSES OPP
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
           AND TLD.receivables_invoice_id IS  null
	   AND KHR.CONTRACT_NUMBER = p_contract_number
	   AND TAI.okl_source_billing_trx = 'STREAM' -- cklee 04/10/07 handle regular stream billing only
--       AND OPP.OBJECT_TYPE = 'XTRX_CONTRACT'
--       AND OPP.OBJECT_VALUE = KHR.CONTRACT_NUMBER
--       AND OPP.ASSIGNED_PROCESS = p_assigned_process
       ORDER BY TAI.ID
       ;

      lxfer_rec OKL_ARINTF_PVT.xfer_rec_type;
--      xfer_rec OKL_ARINTF_PVT.xfer_rec_type;

--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
          -- ------------------------------------------
          -- Variable definition for AR API call
          -- ------------------------------------------
          l_batch_source_rec          AR_INVOICE_API_PUB.batch_source_rec_type;
          l_init_batch_source_rec     AR_INVOICE_API_PUB.batch_source_rec_type;

          l_contingency_tbl           AR_INVOICE_API_PUB.trx_contingencies_tbl_type;
          l_init_contingency_tbl      AR_INVOICE_API_PUB.trx_contingencies_tbl_type;

          l_trx_header_tbl            AR_INVOICE_API_PUB.trx_header_tbl_type;
          l_init_trx_header_tbl       AR_INVOICE_API_PUB.trx_header_tbl_type;

          l_trx_lines_tbl             AR_INVOICE_API_PUB.trx_line_tbl_type;
          l_init_trx_lines_tbl        AR_INVOICE_API_PUB.trx_line_tbl_type;

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/*commented out for R12
          --Bug# 4488818: Sales Tax Billing
          l_tax_indx                  NUMBER;
          l_tax_line_number           NUMBER;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

          l_trx_dist_tbl              AR_INVOICE_API_PUB.trx_dist_tbl_type;
          l_init_trx_dist_tbl         AR_INVOICE_API_PUB.trx_dist_tbl_type;

          l_trx_salescredits_tbl      AR_INVOICE_API_PUB.trx_salescredits_tbl_type;
          l_init_trx_salescredits_tbl AR_INVOICE_API_PUB.trx_salescredits_tbl_type;

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
          l_init_xsiv_rec             Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
	  r_xsiv_rec	      Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;

          l_init_xlsv_rec             Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
	      r_xlsv_rec	              Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

          l_num_cnt                   NUMBER;
          l_customer_trx_id           NUMBER;
          l_msg_count                 NUMBER;
          l_msg_data                  VARCHAR2(2000);
          l_cnt                       NUMBER;
          l_err_cnt                   NUMBER;
          l_ar_inv_num                ra_customer_trx_all.trx_number%TYPE;

    -- ------------------------------------------
    -- For Screen Display of AR Invoice Number
    -- ------------------------------------------
    CURSOR ar_invs_csr( p_cust_trx_id  NUMBER ) IS
           SELECT trx_number
           FROM ra_customer_trx_all
           WHERE customer_trx_id = p_cust_trx_id;

    CURSOR ar_trx_errs_csr( p_hdr_id  NUMBER ) IS
           SELECT *
           FROM ar_trx_errors_gt
           WHERE TRX_HEADER_ID = p_hdr_id;

    l_ar_inv_disp_num       VARCHAR2(3000);

    AR_API_CALL_EXCP        EXCEPTION;

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
    CURSOR tax_amount_csr( p_cust_trx_id  NUMBER ) IS
           SELECT SUM(NVL( extended_amount ,0))
  	       FROM ra_customer_trx_lines
   	       WHERE customer_trx_id = p_cust_trx_id AND
		         LINE_TYPE = 'TAX';

    l_tax_amount               ra_customer_trx_lines.extended_amount%TYPE;

    l_lln_id                   okl_cnsld_ar_lines_v.id%TYPE;
    l_cnr_id                   okl_cnsld_ar_hdrs_v.id%TYPE;
    l_due_date                 okl_cnsld_ar_hdrs_v.due_date%TYPE;

    CURSOR cnr_lln_csr( p_lsm_id  NUMBER ) IS
           SELECT cnr.id cnr_id, lln.id lln_id
  	       FROM okl_cnsld_ar_hdrs_v cnr,
                okl_cnsld_ar_lines_v lln,
                okl_cnsld_ar_strms_v lsm
   	       WHERE cnr.id = lln.cnr_id
           AND lln.id = lsm.lln_id
           AND lsm.id = p_lsm_id;


    CURSOR ar_due_date_csr ( p_cust_trx_id NUMBER ) IS
           SELECT due_date
  	       FROM   ar_payment_schedules_all
   	       WHERE  customer_trx_id = p_cust_trx_id;

    CURSOR get_accrual_csr ( p_lsm_id  NUMBER ) IS
           SELECT NVL(sty.accrual_yn, '1')
           FROM okl_cnsld_ar_strms_v lsm
              , okl_strm_type_v sty
           WHERE lsm.id = p_lsm_id
           AND   lsm.sty_id = sty.id;


    l_rev_rec_basis     okl_strm_type_b.accrual_yn%type;

    CURSOR sales_rep_csr IS
       SELECT SALESREP_ID, SALESREP_NUMBER
       FROM ra_salesreps
       WHERE NAME = 'No Sales Credit';


    CURSOR sales_type_credit_csr IS
       SELECT sales_credit_type_id
       FROM so_sales_credit_types
       WHERE name = 'Quota Sales Credit';

    l_salesrep_id          ra_salesreps.SALESREP_ID%TYPE;
    l_salesrep_number      ra_salesreps.SALESREP_NUMBER%TYPE;
    l_sales_type_credit    so_sales_credit_types.sales_credit_type_id%TYPE;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

    CURSOR seq_csr IS
       SELECT AR_INTERFACE_CONTS_S.nextval
       FROM DUAL;

    CURSOR err_csr IS
        SELECT error_message, invalid_value
        FROM ar_trx_errors_gt;

    -- For PPD process error reporting

     --gkhuntet  FP Bug 5516814 start
    l_contract_number          OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT
p_contract_number;
         --gkhuntet  FP Bug 5516814 end

    l_overall_err_sts   VARCHAR2(1);

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
    --Bug# 4488818: Sales Tax Billing
    CURSOR xfer_tax_csr(p_trx_id IN NUMBER) IS
       SELECT TXS.TRX_BUSINESS_CATEGORY,
              TTD.ID,
              TTD.TAXABLE_AMT,
              TTD.TAX_RATE_CODE,
              TTD.TAX_AMT,
              TTD.tax_rate_id
       FROM OKL_TAX_SOURCES TXS,
            OKL_TAX_TRX_DETAILS TTD
       WHERE TXS.TRX_LINE_ID = p_trx_id
       AND TTD.TXS_ID = TXS.ID;

    l_tax_trx_line_id  NUMBER;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

i Number;
j Number;
BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------
  l_overall_err_sts := Okl_Api.G_RET_STS_SUCCESS;

	x_return_status   := Okl_Api.G_RET_STS_SUCCESS;

	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
--gkhuntet FP Bug 5516814 start
FOR c_get_adv_rcpt_for_cont_rec IN c_get_adv_rcpt_for_cont (p_contract_number)
  LOOP
  Begin
  l_contract_number:=  c_get_adv_rcpt_for_cont_rec.contract_number;
--gkhuntet FP Bug 5516814 end




--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
    -- Verify if contract number is passed in
    -- gboomina Bug 7168534 - start
    -- passing correct variable for contract number
    IF (l_contract_number is null or l_contract_number = okl_api.g_miss_char ) THEN -- rmunjulu R12 Fixes
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'OKL_BPD_ADVANCED_BILLING_PVT.ADVANCED_BILLING.p_contract_number');

        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- gboomina Bug 7168534 - end
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

    -- ----------------------------------------------
    -- Bill eligible streams
    -- ----------------------------------------------
    Okl_Stream_Billing_Pvt.bill_streams (
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status		=> l_return_status,
			x_msg_count		    => x_msg_count,
			x_msg_data		    => x_msg_data,
			--p_contract_number	=> p_contract_number,
			p_from_bill_date	=> p_from_bill_date,
		        p_contract_number	=>l_contract_number ,
                        --gkhuntet FP Bug 5516814 end
			p_to_bill_date		=> p_to_bill_date,
            p_source            => p_source);

    IF p_source = 'PRINCIPAL_PAYDOWN' THEN
       l_overall_err_sts := l_return_status;
    END IF;


--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* For R12, Okl_Internal_To_External.Internal_To_External logic has been migrated to okl_internal_billing_pvt.create_billing_trx();
--so no need to call API here.
    IF p_source = 'TERM_QUOTE' THEN
        Okl_Internal_To_External.Internal_To_External(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status		=> l_return_status,
			x_msg_count		    => x_msg_count,
			x_msg_data		    => x_msg_data,
			p_contract_number	=> p_contract_number);
    END IF;


    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                            p_msg_name     => 'OKL_BPD_RTA_REC_ERR',
                            p_token1       => 'TABLE',
						    p_token1_value => 'AR BATCH SOURCE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ----------------------------------------------
    -- Contract Specific Consolidation
    -- ----------------------------------------------
    Okl_Cons_Bill.create_cons_bill(p_contract_number => p_contract_number,
                                   p_api_version     => p_api_version,
                                   p_init_msg_list   => p_init_msg_list,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                            p_msg_name     => 'OKL_BPD_RTA_REC_ERR',
                            p_token1       => 'TABLE',
						    p_token1_value => 'AR BATCH SOURCE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

--start: |           02-APR-07 cklee  R12 Billing enhancement project
    OPEN acc_sys_option;
    FETCH acc_sys_option INTO G_ACC_SYS_OPTION;
    CLOSE acc_sys_option;
    -- ----------------------------
    -- Work out common parameters
    -- ----------------------------

/*      OPEN l_get_inv_org_yn_csr( l_org_id );  */
/*      FETCH l_get_inv_org_yn_csr INTO l_use_inv_org;  */
/*      CLOSE l_get_inv_org_yn_csr;  */

--end: |           02-APR-07 cklee  R12 Billing enhancement project


    l_num_cnt := 0;
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
  --gkhuntet FP Bug 5516814 start
   FOR xfer_rec in xfer_csr( l_contract_number ) LOOP

 --gkhuntet FP Bug 5516814 end
--    FOR xsi_rec in xsi_csr( p_contract_number ) LOOP
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--      lxfer_rec := xfer_rec;
-- somehow we are not able to pass xfer_rec to procedure so we have to copy to local record
--      lxfer_rec := xfer_rec;
            lxfer_rec.TAI_ID := xfer_rec.TAI_ID;
            lxfer_rec.AMOUNT := xfer_rec.AMOUNT;
            lxfer_rec.LINE_DESCRIPTION := xfer_rec.LINE_DESCRIPTION;
            lxfer_rec.INVENTORY_ITEM_ID := xfer_rec.INVENTORY_ITEM_ID;
            lxfer_rec.LINE_TYPE := xfer_rec.LINE_TYPE;
            lxfer_rec.QUANTITY := xfer_rec.QUANTITY;
            lxfer_rec.LINE_NUMBER := xfer_rec.LINE_NUMBER;
            lxfer_rec.STY_ID := xfer_rec.STY_ID;
            lxfer_rec.KHR_ID := xfer_rec.KHR_ID;
            lxfer_rec.CONTRACT_NUMBER := xfer_rec.CONTRACT_NUMBER;
            lxfer_rec.ASSET_NUMBER := xfer_rec.ASSET_NUMBER;
            lxfer_rec.INVOICE_FORMAT_LINE_TYPE := xfer_rec.INVOICE_FORMAT_LINE_TYPE;
            lxfer_rec.STREAM_TYPE := xfer_rec.STREAM_TYPE;
            lxfer_rec.CURRENCY_CODE := xfer_rec.CURRENCY_CODE;
            lxfer_rec.currency_conversion_date := xfer_rec.currency_conversion_date;
            lxfer_rec.currency_conversion_rate := xfer_rec.currency_conversion_rate;
            lxfer_rec.currency_conversion_type := xfer_rec.currency_conversion_type;
            lxfer_rec.CUST_TRX_TYPE_ID := xfer_rec.CUST_TRX_TYPE_ID;
            lxfer_rec.CUSTOMER_ADDRESS_ID := xfer_rec.CUSTOMER_ADDRESS_ID;
            lxfer_rec.CUSTOMER_BANK_ACCOUNT_ID := xfer_rec.CUSTOMER_BANK_ACCOUNT_ID;
            lxfer_rec.CUSTOMER_ID := xfer_rec.CUSTOMER_ID;
            lxfer_rec.HDR_DESCRIPTION := xfer_rec.HDR_DESCRIPTION;
            lxfer_rec.INVOICE_MESSAGE := xfer_rec.INVOICE_MESSAGE;
            lxfer_rec.ORG_ID := xfer_rec.ORG_ID;
            lxfer_rec.RECEIPT_METHOD_ID := xfer_rec.RECEIPT_METHOD_ID;
            lxfer_rec.SET_OF_BOOKS_ID := xfer_rec.SET_OF_BOOKS_ID;
            lxfer_rec.TAX_EXEMPT_FLAG := xfer_rec.TAX_EXEMPT_FLAG;
            lxfer_rec.TERM_ID := xfer_rec.TERM_ID;
            lxfer_rec.TRX_DATE := xfer_rec.TRX_DATE;
            lxfer_rec.TRX_NUMBER := xfer_rec.TRX_NUMBER;
            lxfer_rec.CONSOLIDATED_INVOICE_NUMBER := xfer_rec.CONSOLIDATED_INVOICE_NUMBER;
            lxfer_rec.INVOICE_FORMAT_TYPE := xfer_rec.INVOICE_FORMAT_TYPE;
            lxfer_rec.INVOICE_PULL_YN := xfer_rec.INVOICE_PULL_YN;
            lxfer_rec.PRIVATE_LABEL := xfer_rec.PRIVATE_LABEL;
            lxfer_rec.LEGAL_ENTITY_ID := xfer_rec.LEGAL_ENTITY_ID;
            lxfer_rec.ACCOUNT_CLASS := xfer_rec.ACCOUNT_CLASS;
            lxfer_rec.DIST_AMOUNT := xfer_rec.DIST_AMOUNT;
            lxfer_rec.DIST_PERCENT := xfer_rec.DIST_PERCENT;
            lxfer_rec.CODE_COMBINATION_ID := xfer_rec.CODE_COMBINATION_ID;
            lxfer_rec.rev_rec_basis := xfer_rec.rev_rec_basis;
            lxfer_rec.cm_acct_rule := xfer_rec.cm_acct_rule;
            lxfer_rec.rev_txn_id := xfer_rec.rev_txn_id;
            lxfer_rec.INVENTORY_ORG_ID := xfer_rec.INVENTORY_ORG_ID;
            lxfer_rec.ware_house_id := xfer_rec.ware_house_id;
            lxfer_rec.kle_id := xfer_rec.kle_id;
            lxfer_rec.ship_to := xfer_rec.ship_to;
            lxfer_rec.l_inv_id := xfer_rec.l_inv_id;
            lxfer_rec.uom_code := xfer_rec.uom_code;
            lxfer_rec.txn_id := xfer_rec.txn_id;
            lxfer_rec.OKL_SOURCE_BILLING_TRX := xfer_rec.OKL_SOURCE_BILLING_TRX;
            lxfer_rec.Investor_Agreement_Number := xfer_rec.Investor_Agreement_Number;
            lxfer_rec.Investor_Name := xfer_rec.Investor_Name;
            lxfer_rec.Quote_number := xfer_rec.Quote_number;
            lxfer_rec.rbk_request_number := xfer_rec.rbk_request_number;
            lxfer_rec.RBK_ORI_INVOICE_NUMBER := xfer_rec.RBK_ORI_INVOICE_NUMBER;
            lxfer_rec.RBK_ORI_INVOICE_LINE_NUMBER := xfer_rec.RBK_ORI_INVOICE_LINE_NUMBER;
            lxfer_rec.RBK_ADJUSTMENT_DATE := xfer_rec.RBK_ADJUSTMENT_DATE;
            lxfer_rec.INF_ID := xfer_rec.INF_ID;
            lxfer_rec.TRY_ID := xfer_rec.TRY_ID;
            lxfer_rec.TRY_NAME := xfer_rec.TRY_NAME;
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
            l_num_cnt := l_num_cnt + 1;
            ---------------------------------------
            -- Prepare batch_source rec
            ---------------------------------------
            l_batch_source_rec     := l_init_batch_source_rec;

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Preparing Batch rec '||l_num_cnt);
            PREPARE_BATCH_SOURCE_REC(
                 x_return_status
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,xfer_rec.TRX_DATE
--                ,xsi_rec.TRX_DATE
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,l_batch_source_rec );
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Done Preparing Batch rec '||l_num_cnt);

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_BPD_RTA_REC_ERR',
                          p_token1       => 'TABLE',
						  p_token1_value => 'AR BATCH SOURCE'
                         );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            ---------------------------------------
            -- Prepare trx hdr tbl
            ---------------------------------------
            l_trx_header_tbl       := l_init_trx_header_tbl;

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
            -- -----------------------------------------
            -- Initialize XSI record
            -- -----------------------------------------
	        r_xsiv_rec	           := l_init_xsiv_rec;

            -- ------------------------------
            -- Populate XSI record
            -- ------------------------------
            r_xsiv_rec.ID                           := xsi_rec.ID;
            r_xsiv_rec.OBJECT_VERSION_NUMBER        := xsi_rec.OBJECT_VERSION_NUMBER;
            r_xsiv_rec.SFWT_FLAG                    := xsi_rec.SFWT_FLAG;
            r_xsiv_rec.ISI_ID                       := xsi_rec.ISI_ID;
            r_xsiv_rec.TRX_DATE                     := xsi_rec.TRX_DATE;
            r_xsiv_rec.CUSTOMER_ID                  := xsi_rec.CUSTOMER_ID;
            r_xsiv_rec.RECEIPT_METHOD_ID            := xsi_rec.RECEIPT_METHOD_ID;
            r_xsiv_rec.TERM_ID                      := xsi_rec.TERM_ID;
            r_xsiv_rec.CURRENCY_CODE                := xsi_rec.CURRENCY_CODE;
            r_xsiv_rec.CURRENCY_CONVERSION_TYPE     := xsi_rec.CURRENCY_CONVERSION_TYPE;
            r_xsiv_rec.CURRENCY_CONVERSION_RATE     := xsi_rec.CURRENCY_CONVERSION_RATE;
            r_xsiv_rec.CURRENCY_CONVERSION_DATE     := xsi_rec.CURRENCY_CONVERSION_DATE;
            r_xsiv_rec.CUSTOMER_ADDRESS_ID          := xsi_rec.CUSTOMER_ADDRESS_ID;
            r_xsiv_rec.SET_OF_BOOKS_ID              := xsi_rec.SET_OF_BOOKS_ID;
            r_xsiv_rec.RECEIVABLES_INVOICE_ID       := xsi_rec.RECEIVABLES_INVOICE_ID;
            r_xsiv_rec.CUST_TRX_TYPE_ID             := xsi_rec.CUST_TRX_TYPE_ID;
            r_xsiv_rec.INVOICE_MESSAGE              := xsi_rec.INVOICE_MESSAGE;
            r_xsiv_rec.DESCRIPTION                  := xsi_rec.DESCRIPTION;
            r_xsiv_rec.XTRX_CONS_INVOICE_NUMBER     := xsi_rec.XTRX_CONS_INVOICE_NUMBER;
            r_xsiv_rec.XTRX_FORMAT_TYPE             := xsi_rec.XTRX_FORMAT_TYPE;
            r_xsiv_rec.XTRX_PRIVATE_LABEL           := xsi_rec.XTRX_PRIVATE_LABEL;
            r_xsiv_rec.ATTRIBUTE_CATEGORY           := xsi_rec.ATTRIBUTE_CATEGORY;
            r_xsiv_rec.ATTRIBUTE1                   := xsi_rec.ATTRIBUTE1;
            r_xsiv_rec.ATTRIBUTE2                   := xsi_rec.ATTRIBUTE2;
            r_xsiv_rec.ATTRIBUTE3                   := xsi_rec.ATTRIBUTE3;
            r_xsiv_rec.ATTRIBUTE4                   := xsi_rec.ATTRIBUTE4;
            r_xsiv_rec.ATTRIBUTE5                   := xsi_rec.ATTRIBUTE5;
            r_xsiv_rec.ATTRIBUTE6                   := xsi_rec.ATTRIBUTE6;
            r_xsiv_rec.ATTRIBUTE7                   := xsi_rec.ATTRIBUTE7;
            r_xsiv_rec.ATTRIBUTE8                   := xsi_rec.ATTRIBUTE8;
            r_xsiv_rec.ATTRIBUTE9                   := xsi_rec.ATTRIBUTE9;
            r_xsiv_rec.ATTRIBUTE10                  := xsi_rec.ATTRIBUTE10;
            r_xsiv_rec.ATTRIBUTE11                  := xsi_rec.ATTRIBUTE11;
            r_xsiv_rec.ATTRIBUTE12                  := xsi_rec.ATTRIBUTE12;
            r_xsiv_rec.ATTRIBUTE13                  := xsi_rec.ATTRIBUTE13;
            r_xsiv_rec.ATTRIBUTE14                  := xsi_rec.ATTRIBUTE14;
            r_xsiv_rec.ATTRIBUTE15                  := xsi_rec.ATTRIBUTE15;
            r_xsiv_rec.REFERENCE_LINE_ID            := xsi_rec.REFERENCE_LINE_ID;
            r_xsiv_rec.TRX_NUMBER                   := xsi_rec.TRX_NUMBER;
            r_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID     := xsi_rec.CUSTOMER_BANK_ACCOUNT_ID;
            r_xsiv_rec.TAX_EXEMPT_FLAG              := xsi_rec.TAX_EXEMPT_FLAG;
            r_xsiv_rec.TAX_EXEMPT_REASON_CODE       := xsi_rec.TAX_EXEMPT_REASON_CODE;
            r_xsiv_rec.XTRX_INVOICE_PULL_YN         := xsi_rec.XTRX_INVOICE_PULL_YN;
            r_xsiv_rec.TRX_STATUS_CODE              := xsi_rec.TRX_STATUS_CODE;
            r_xsiv_rec.REQUEST_ID                   := xsi_rec.REQUEST_ID;
            r_xsiv_rec.PROGRAM_APPLICATION_ID       := xsi_rec.PROGRAM_APPLICATION_ID;
            r_xsiv_rec.PROGRAM_ID                   := xsi_rec.PROGRAM_ID;
            r_xsiv_rec.PROGRAM_UPDATE_DATE          := xsi_rec.PROGRAM_UPDATE_DATE;
            r_xsiv_rec.ORG_ID                       := xsi_rec.ORG_ID;
            r_xsiv_rec.CREATED_BY                   := xsi_rec.CREATED_BY;
            r_xsiv_rec.CREATION_DATE                := xsi_rec.CREATION_DATE;
            r_xsiv_rec.LAST_UPDATED_BY              := xsi_rec.LAST_UPDATED_BY;
            r_xsiv_rec.LAST_UPDATE_DATE             := xsi_rec.LAST_UPDATE_DATE;
            r_xsiv_rec.LAST_UPDATE_LOGIN            := xsi_rec.LAST_UPDATE_LOGIN;
            r_xsiv_rec.LEGAL_ENTITY_ID              := xsi_rec.LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006

            -- -----------------------------------------
            -- Initialize XLS record
            -- -----------------------------------------
	        r_xlsv_rec	           := l_init_xlsv_rec;

            -- ------------------------------
            -- Populate XLS record
            -- ------------------------------
            FOR xls_rec IN xls_csr( r_xsiv_rec.id ) LOOP

                r_xlsv_rec.ID                       := xls_rec.ID;
                r_xlsv_rec.OBJECT_VERSION_NUMBER    := xls_rec.OBJECT_VERSION_NUMBER;
                r_xlsv_rec.SFWT_FLAG                := xls_rec.SFWT_FLAG;
                r_xlsv_rec.TLD_ID                   := xls_rec.TLD_ID;
                r_xlsv_rec.LSM_ID                   := xls_rec.LSM_ID;
                r_xlsv_rec.TIL_ID                   := xls_rec.TIL_ID;
                r_xlsv_rec.ILL_ID                   := xls_rec.ILL_ID;
                r_xlsv_rec.XSI_ID_DETAILS           := xls_rec.XSI_ID_DETAILS;
                r_xlsv_rec.LINE_TYPE                := xls_rec.LINE_TYPE;
                r_xlsv_rec.DESCRIPTION              := xls_rec.DESCRIPTION;
                r_xlsv_rec.AMOUNT                   := xls_rec.AMOUNT;
                r_xlsv_rec.QUANTITY                 := xls_rec.QUANTITY;
                r_xlsv_rec.XTRX_CONS_LINE_NUMBER    := xls_rec.XTRX_CONS_LINE_NUMBER;
                r_xlsv_rec.XTRX_CONTRACT            := xls_rec.XTRX_CONTRACT;
                r_xlsv_rec.XTRX_ASSET               := xls_rec.XTRX_ASSET;
                r_xlsv_rec.XTRX_STREAM_GROUP        := xls_rec.XTRX_STREAM_GROUP;
                r_xlsv_rec.XTRX_STREAM_TYPE         := xls_rec.XTRX_STREAM_TYPE;
                r_xlsv_rec.XTRX_CONS_STREAM_ID      := xls_rec.XTRX_CONS_STREAM_ID;
                r_xlsv_rec.ISL_ID                   := xls_rec.ISL_ID;
                r_xlsv_rec.SEL_ID                   := xls_rec.SEL_ID;
                r_xlsv_rec.ATTRIBUTE_CATEGORY       := xls_rec.ATTRIBUTE_CATEGORY;
                r_xlsv_rec.ATTRIBUTE1               := xls_rec.ATTRIBUTE1;
                r_xlsv_rec.ATTRIBUTE2               := xls_rec.ATTRIBUTE2;
                r_xlsv_rec.ATTRIBUTE3               := xls_rec.ATTRIBUTE3;
                r_xlsv_rec.ATTRIBUTE4               := xls_rec.ATTRIBUTE4;
                r_xlsv_rec.ATTRIBUTE5               := xls_rec.ATTRIBUTE5;
                r_xlsv_rec.ATTRIBUTE6               := xls_rec.ATTRIBUTE6;
                r_xlsv_rec.ATTRIBUTE7               := xls_rec.ATTRIBUTE7;
                r_xlsv_rec.ATTRIBUTE8               := xls_rec.ATTRIBUTE8;
                r_xlsv_rec.ATTRIBUTE9               := xls_rec.ATTRIBUTE9;
                r_xlsv_rec.ATTRIBUTE10              := xls_rec.ATTRIBUTE10;
                r_xlsv_rec.ATTRIBUTE11              := xls_rec.ATTRIBUTE11;
                r_xlsv_rec.ATTRIBUTE12              := xls_rec.ATTRIBUTE12;
                r_xlsv_rec.ATTRIBUTE13              := xls_rec.ATTRIBUTE13;
                r_xlsv_rec.ATTRIBUTE14              := xls_rec.ATTRIBUTE14;
                r_xlsv_rec.ATTRIBUTE15              := xls_rec.ATTRIBUTE15;
                r_xlsv_rec.REQUEST_ID               := xls_rec.REQUEST_ID;
                r_xlsv_rec.PROGRAM_APPLICATION_ID   := xls_rec.PROGRAM_APPLICATION_ID;
                r_xlsv_rec.PROGRAM_ID               := xls_rec.PROGRAM_ID;
                r_xlsv_rec.PROGRAM_UPDATE_DATE      := xls_rec.PROGRAM_UPDATE_DATE;
                r_xlsv_rec.ORG_ID                   := xls_rec.ORG_ID;
                r_xlsv_rec.CREATED_BY               := xls_rec.CREATED_BY;
                r_xlsv_rec.CREATION_DATE            := xls_rec.CREATION_DATE;
                r_xlsv_rec.LAST_UPDATED_BY          := xls_rec.LAST_UPDATED_BY;
                r_xlsv_rec.LAST_UPDATE_DATE         := xls_rec.LAST_UPDATE_DATE;
                r_xlsv_rec.LAST_UPDATE_LOGIN        := xls_rec.LAST_UPDATE_LOGIN;

            END LOOP;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Preparing Trx Hdr tbl '||l_num_cnt);
            PREPARE_TRX_HDR_TBL(
                 x_return_status
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,lxfer_rec
--                ,r_xsiv_rec
--                ,r_xlsv_rec
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,p_source
                ,l_trx_header_tbl );

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Done Preparing Trx Hdr tbl '||l_num_cnt);


            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_BPD_RTA_REC_ERR',
                          p_token1       => 'TABLE',
						  p_token1_value => 'AR Transaction Header Table '
                         );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            ---------------------------------------
            -- Prepare trx lines tbl
            ---------------------------------------
            l_trx_lines_tbl        := l_init_trx_lines_tbl;

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Preparing Trx Lines tbl '||l_num_cnt);
            PREPARE_TRX_LNS_TBL(
                 x_return_status
                ,l_num_cnt
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,lxfer_rec
--                ,r_xsiv_rec
--                ,r_xlsv_rec
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,l_trx_lines_tbl );
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Done Preparing Trx Lines tbl '||l_num_cnt);

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_BPD_RTA_REC_ERR',
                          p_token1       => 'TABLE',
			  p_token1_value => 'AR Transaction Lines Table '
                         );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/* commented out for R12
            --Bug# 4488818: Sales Tax Billing
            l_tax_trx_line_id := NULL;

            IF r_xlsv_rec.til_id IS NOT NULL THEN
              l_tax_trx_line_id := r_xlsv_rec.til_id ;
            ELSE
              l_tax_trx_line_id := r_xlsv_rec.tld_id ;
            END IF;

            l_tax_line_number := 0;
            FOR xfer_tax_rec IN xfer_tax_csr(l_tax_trx_line_id) LOOP

              l_tax_indx := l_trx_lines_tbl.count + 1;
              l_tax_line_number := l_tax_line_number + 1;

              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Preparing Trx Tax Lines tbl '||(l_num_cnt + l_tax_line_number));
              --
              l_trx_lines_tbl(l_tax_indx).trx_header_id       := 110;
              l_trx_lines_tbl(l_tax_indx).trx_line_id         := (l_num_cnt + l_tax_line_number);
              l_trx_lines_tbl(l_tax_indx).link_to_trx_line_id := l_num_cnt;
              l_trx_lines_tbl(l_tax_indx).LINE_NUMBER	      := l_tax_line_number;

              l_trx_lines_tbl(l_tax_indx).DESCRIPTION
                := NVL (NVL (r_xlsv_rec.DESCRIPTION, r_xsiv_rec.DESCRIPTION), 'OKL Billing')|| ' - Tax';
              l_trx_lines_tbl(l_tax_indx).LINE_TYPE	         := 'TAX';

              l_trx_lines_tbl(l_tax_indx).INTERFACE_LINE_CONTEXT	   := 'OKL_MANUAL';
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE1 := l_trx_lines_tbl(1).ATTRIBUTE1;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE2 := l_trx_lines_tbl(1).ATTRIBUTE2;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE3 := l_trx_lines_tbl(1).ATTRIBUTE3;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE4 := l_trx_lines_tbl(1).ATTRIBUTE4;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE5 := l_trx_lines_tbl(1).ATTRIBUTE5;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE6 := l_trx_lines_tbl(1).ATTRIBUTE6;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE7 := l_trx_lines_tbl(1).ATTRIBUTE7;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE8 := l_trx_lines_tbl(1).ATTRIBUTE8;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE9 := l_trx_lines_tbl(1).ATTRIBUTE9;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE10 := SUBSTR(xfer_tax_rec.ID,  1, 20);
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE11 := SUBSTR (xfer_tax_rec.ID, 21);
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE12	:= NULL;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE13	:= NULL;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE14	:= NULL;
              l_trx_lines_tbl(l_tax_indx).ATTRIBUTE15	:= NULL;

              l_trx_lines_tbl(l_tax_indx).AMOUNT	                  := xfer_tax_rec.TAX_AMT;
              l_trx_lines_tbl(l_tax_indx).TAX_PRECEDENCE	            := NULL;
              l_trx_lines_tbl(l_tax_indx).TAX_RATE	                  := NULL;
              l_trx_lines_tbl(l_tax_indx).TAX_EXEMPTION_ID	            := NULL;
              l_trx_lines_tbl(l_tax_indx).VAT_TAX_ID	                  := xfer_tax_rec.TAX_RATE_ID;
              --

              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Done Preparing Trx Tax Lines tbl '||(l_num_cnt + l_tax_line_number));
            END LOOP;
            --Bug# 4488818: Sales Tax Billing
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

            ---------------------------------------
            -- Prepare trx distributions tbl
            ---------------------------------------
            l_trx_dist_tbl         := l_init_trx_dist_tbl;

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Preparing Trx Dist tbl '||l_num_cnt);
            PREPARE_TRX_DIST_TBL(
                 x_return_status
                ,l_num_cnt
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,lxfer_rec
--                ,r_xsiv_rec
--                ,r_xlsv_rec
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
                ,l_trx_dist_tbl );
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Done Preparing trx dist tbl '||l_num_cnt);

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_BPD_RTA_REC_ERR',
                          p_token1       => 'TABLE',
			  p_token1_value => 'AR Transaction Distributions Table '
                         );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_trx_salescredits_tbl := l_init_trx_salescredits_tbl;

/*              l_salesrep_id          := NULL;  */
/*              l_salesrep_number      := NULL;  */
/*              l_sales_type_credit    := NULL;  */
/*                */
/*              OPEN  sales_type_credit_csr;  */
/*              FETCH sales_type_credit_csr INTO l_sales_type_credit;  */
/*              CLOSE sales_type_credit_csr;  */
/*                */
/*              l_trx_salescredits_tbl(1).SALESCREDIT_PERCENT_SPLIT := 100;  */
/*              l_trx_salescredits_tbl(1).SALES_CREDIT_TYPE_ID := l_sales_type_credit;  */
/*              l_trx_salescredits_tbl(1).SALES_CREDIT_TYPE_NAME := 'Quota Sales Credit';  */
/*              l_trx_salescredits_tbl(1).SALESREP_ID := -3;  */
/*              l_trx_salescredits_tbl(1).SALESREP_NUMBER := -3;  */

            l_customer_trx_id      := NULL;
            l_msg_count            := 0;
            l_msg_data             := NULL;

            -----------------------------
            -- Create AR Invoice
            -----------------------------
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Invoking Invoice API for'
            ||' Contract Number '||xfer_rec.CONTRACT_NUMBER
			||',Stream Type '||xfer_rec.STREAM_TYPE
            ||',Invoice Date '||xfer_rec.TRX_DATE
            ||',Currency Code '||xfer_rec.CURRENCY_CODE);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Before calling invoice Api ');

            -- Establish Savepoint for rollback
            DBMS_TRANSACTION.SAVEPOINT('AR_INVOICE_API_PVT');
            -- Savepoint established

            -- -----------------------------------------
            -- Check for revenue based cash recognition
            -- -----------------------------------------
            -- Start comment
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/*
              l_rev_rec_basis := NULL;
              OPEN  get_accrual_csr ( r_xlsv_rec.LSM_ID );
              FETCH get_accrual_csr INTO l_rev_rec_basis;
              CLOSE get_accrual_csr;
*/
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

 	 		  l_contingency_tbl := l_init_contingency_tbl;
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--              IF l_rev_rec_basis = 'CASH_RECEIPT' THEN
              IF xfer_rec.rev_rec_basis = 'CASH_RECEIPT' THEN
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

--strat: cklee 4/9/07
-- Migrated the following logic from oklarintf_pvt
                --Added if clause by bkatraga for bug 5616268
                --Accounting_rule_id will not be populated in case of on-account credit memo
                IF ((xfer_rec.AMOUNT >= 0) OR (xfer_rec.rev_txn_id IS NOT NULL)) THEN
                  l_trx_header_tbl(1).INVOICING_RULE_ID := -2;
                  l_trx_lines_tbl(1).ACCOUNTING_RULE_ID := 1;
                END IF;
                --end bkatraga

--                 l_trx_header_tbl(1).INVOICING_RULE_ID := -2;
--                 l_trx_lines_tbl(1).ACCOUNTING_RULE_ID := 1;
                -- Added
                l_trx_lines_tbl(1).RULE_START_DATE    := l_trx_header_tbl(1).trx_date;
                -- Added
                l_trx_lines_tbl(1).OVERRIDE_AUTO_ACCOUNTING_FLAG := 'Y';

--end: cklee 4/9/07

                OPEN  seq_csr;
                FETCH seq_csr INTO l_contingency_tbl(1).trx_contingency_id ;
                CLOSE seq_csr;

--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
--start: bug 6744584 .. racheruv: populate contingency_id from stream type table.

                --l_contingency_tbl(1).CONTINGENCY_ID := l_contingency_tbl(1).trx_contingency_id;

                l_contingency_tbl(1).CONTINGENCY_ID := xfer_rec.contingency_id;

--end: bug 6744584.. racheruv.
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

                l_contingency_tbl(1).trx_line_id := l_num_cnt;
--start: bug 6744584 .. racheruv: populate contingency_id from stream type table.
--       contingency_code is not required now.
                --l_contingency_tbl(1).contingency_code := 'OKL_COLLECTIBILITY';
--end  : bug 6744584 .. racheruv: contingency_code is not required anymore.
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
              ELSE
                l_trx_header_tbl(1).INVOICING_RULE_ID := NULL;
                l_trx_lines_tbl(1).ACCOUNTING_RULE_ID := NULL;
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |
              END IF;
            -- End comment

--rkuttiya adding debug messages for getting values of attributes passed to
--
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Batch Source Id '||l_batch_source_rec.batch_source_id);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Default Date  '||
l_batch_source_rec.default_date);

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Trx Header Id :
'||l_trx_header_tbl(1).trx_header_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Trx_Number :
'||l_trx_header_tbl(1).trx_number);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Trx Date :'||l_trx_header_tbl(1).trx_date);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Trx_Currency
:'||l_trx_header_tbl(1).trx_currency);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Receipt Method Id : '||
l_trx_header_tbl(1).receipt_method_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Payment Trxn Extn Id :
'||l_trx_header_tbl(1).payment_trxn_extension_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Customer Bank Account Id
:'||l_trx_header_tbl(1).customer_bank_account_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Bill to Customer Id:
'||l_trx_header_tbl(1).bill_to_customer_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Bill to Address Id:
'||l_trx_header_tbl(1).bill_to_address_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Ship to customer id:
'||l_trx_header_tbl(1).ship_to_customer_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Ship to address id:
'||l_trx_header_tbl(1).ship_to_address_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Org Id: '||l_trx_header_tbl(1).org_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Legal Entity Id:
'||l_trx_header_tbl(1).legal_entity_id);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Billing Date
:'||l_trx_header_tbl(1).billing_date);
fnd_file.put_line(fnd_file.output,'Term Id: '||l_trx_header_tbl(1).term_id);
fnd_file.put_line(fnd_file.output,'Comments" '||l_trx_header_tbl(1).comments);

fnd_file.put_line(fnd_file.output,'Lines Table');

FOR i in l_trx_lines_tbl.FIRST..l_trx_lines_tbl.LAST LOOP
fnd_file.put_line(fnd_file.output,'Trx Header Id :'||
l_trx_lines_tbl(i).trx_header_id);
fnd_file.put_line(fnd_file.output,'Trx Line Id
:'||l_trx_lines_tbl(i).trx_line_id);
fnd_file.put_line(fnd_file.output,'Line
Number:'||l_trx_lines_tbl(i).line_number);
fnd_file.put_line(fnd_file.output,'Inventory Item
Id:'||l_trx_lines_tbl(i).inventory_item_id);
fnd_file.put_line(fnd_file.output,'Quantity Ordered
:'||l_trx_lines_tbl(i).quantity_ordered);
fnd_file.put_line(fnd_file.output,'unit standard
price:'||l_trx_lines_tbl(i).unit_standard_price);
fnd_file.put_line(fnd_file.output,'unit selling price
'||l_trx_lines_tbl(i).unit_selling_price);
fnd_file.put_line(fnd_file.output,'line type:'||l_trx_lines_tbl(i).line_type);
fnd_file.put_line(fnd_file.output,'Interface Line
Context:'||l_trx_lines_tbl(i).interface_line_context);
fnd_file.put_line(fnd_file.output,'Interface Line Attribute6
:'||l_trx_lines_tbl(i).interface_line_attribute6);
fnd_file.put_line(fnd_file.output,'Interface Line Attribute7
:'||l_trx_lines_tbl(i).interface_line_attribute7);
fnd_file.put_line(fnd_file.output,'Interface Line
Attribute9:'||l_trx_lines_tbl(i).interface_line_Attribute9);
fnd_file.put_line(fnd_file.output,'Interface Line
Attribute10:'||l_trx_lines_tbl(i).interfacE_line_attribute10);
fnd_file.put_line(fnd_file.output,'Interface Line Attribute
13:'||l_trx_lines_tbl(i).interfacE_line_Attribute13);
fnd_file.put_line(fnd_file.output,'Interface Line Atribute14
:'||l_trx_lines_tbl(i).interface_line_attribute14);
fnd_file.put_line(fnd_file.output,'Amount :'||l_trx_lines_tbl(i).amount);
fnd_file.put_line(fnd_file.output,'UOM Code :'||l_trx_lines_tbl(i).UOM_CODE);
fnd_file.put_line(fnd_file.output,'Tax Exempt Flag
:'||l_trx_lines_tbl(i).tax_exempt_flag);

End LOOP;

fnd_file.put_line(fnd_file.output,'Distributions Table');

FOR j in L_TRX_DIST_TBL.FIRST..L_TRX_DIST_TBL.LAST LOOP
fnd_file.put_line(fnd_file.output,'Trx Dist Id :'||
l_trx_dist_tbl(j).trx_dist_id);
fnd_file.put_line(fnd_file.output,'Trx Header Id
:'||l_trx_dist_tbl(j).trx_line_id);
fnd_file.put_line(fnd_file.output,'Trx Line Id
:'||l_trx_dist_tbl(j).trx_line_id);
fnd_file.put_line(fnd_file.output,'Account class
:'||l_trx_dist_tbl(j).account_class);
fnd_file.put_line(fnd_file.output,'Amount
:'||l_trx_dist_tbl(j).amount);
fnd_file.put_line(fnd_file.output,'acctd_amount
:'||l_trx_dist_tbl(j).acctd_amount);
fnd_file.put_line(fnd_file.output,'Percent
'||l_trx_dist_tbl(j).percent);
fnd_file.put_line(fnd_file.output,'Code Combination Id
:'||l_trx_dist_tbl(j).code_combination_id);
End LOOP;

            AR_INVOICE_API_PUB.create_single_invoice(
                p_api_version           => 1.0,
                p_batch_source_rec	    => l_batch_source_rec,
                p_trx_header_tbl        => l_trx_header_tbl,
                p_trx_lines_tbl         => l_trx_lines_tbl,
                p_trx_dist_tbl          => l_trx_dist_tbl,
                p_trx_salescredits_tbl  => l_trx_salescredits_tbl,
                p_trx_contingencies_tbl => l_contingency_tbl,
                x_customer_trx_id       => l_customer_trx_id,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'After calling Invoice API'||
l_return_status);

            x_ar_inv_tbl(l_num_cnt).receivables_invoice_id := l_customer_trx_id;

            IF (p_source = 'PRINCIPAL_PAYDOWN' AND l_customer_trx_id IS NULL) THEN
-- cklee 4/4/07 note: set a proper error message!
                l_overall_err_sts := 'E';
            END IF;

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'After calling Invoice API '||l_num_cnt
            ||'.. Assigned l_customer_trx_id = '||l_customer_trx_id|| ' ret sts '||l_return_status);


            -- Post Call Processing Block
            FOR err_rec IN err_csr LOOP
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error_message: '||err_rec.error_message);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Invalid_value: '||err_rec.Invalid_value);
            END LOOP;

            IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := l_msg_count;
                x_msg_data := l_msg_data;
                OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_BPD_RTA_TXN_ERR1',
                          p_token1       => 'TXN',
						  p_token1_value => 'Receivables Invoice'
                         );
                RAISE AR_API_CALL_EXCP;
            ELSE

                SELECT count(*) INTO l_cnt
                FROM ar_trx_errors_gt;

                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Count is : '||l_cnt);
                IF l_cnt > 0 THEN
                   l_err_cnt := 0;
                   FOR ar_trx_rec IN ar_trx_errs_csr( 110 ) LOOP
                    l_err_cnt := l_err_cnt + 1;
                    OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_BPD_RTA_GEN_ERR1',
                          p_token1       => 'NUM',
						  p_token1_value => to_char(l_err_cnt),
                          p_token2       => 'MESSAGE',
						  p_token2_value => ar_trx_rec.ERROR_MESSAGE
                         );
                   END LOOP;
                   x_return_status := 'E';
                   RAISE AR_API_CALL_EXCP;
                END IF;
            END IF;

            l_ar_inv_num := NULL;
            OPEN  ar_invs_csr ( l_customer_trx_id );
            FETCH ar_invs_csr INTO l_ar_inv_num;
            CLOSE ar_invs_csr;

            -----------------------------------------------
            -- Keep appending created AR Invoice Numbers
            -----------------------------------------------
            l_ar_inv_disp_num := l_ar_inv_disp_num||' '||l_ar_inv_num;

            --------------------------------------
            -- Post invoice creation updates for
            -- referential integrity
            --------------------------------------
--start: |           02-APR-07 cklee  R12 Billing enhancement project                 |
/*
            l_tax_amount := 0;

            OPEN  tax_amount_csr ( l_customer_trx_id );
            FETCH tax_amount_csr INTO l_tax_amount;
            CLOSE tax_amount_csr;

            l_cnr_id     := NULL;
            l_lln_id     := NULL;
            OPEN  cnr_lln_csr( r_xlsv_rec.LSM_ID );
            FETCH cnr_lln_csr INTO l_cnr_id, l_lln_id;
            CLOSE cnr_lln_csr;

            l_due_date   := NULL;
            OPEN  ar_due_date_csr ( l_customer_trx_id );
            FETCH ar_due_date_csr INTO l_due_date;
            CLOSE ar_due_date_csr;

            UPDATE Okl_Cnsld_Ar_Strms_b
            SET RECEIVABLES_INVOICE_ID = l_customer_trx_id,
                tax_amount			   = NVL(l_tax_amount,0)
            WHERE ID = r_xlsv_rec.LSM_ID;

            UPDATE Okl_Cnsld_Ar_Lines_B
            SET TAX_AMOUNT = NVL(TAX_AMOUNT,0)+NVL(l_tax_amount,0)
            WHERE ID = l_lln_id;

            UPDATE Okl_Cnsld_Ar_Hdrs_B
            SET amount   = NVL(amount,0) + NVL(l_tax_amount,0),
                due_date = l_due_date
            WHERE ID = l_cnr_id;

            UPDATE Okl_Ext_Sell_Invs_B
            SET RECEIVABLES_INVOICE_ID = l_customer_trx_id,
                TRX_STATUS_CODE = 'PROCESSED'
            WHERE ID = r_xsiv_rec.id;

            UPDATE Okl_Txl_Ar_Inv_Lns_B
            SET RECEIVABLES_INVOICE_ID = l_customer_trx_id
            WHERE id = xfer_rec.TIL_ID;
*/
            UPDATE Okl_Txd_Ar_Ln_Dtls_B
            SET RECEIVABLES_INVOICE_ID = l_customer_trx_id
            WHERE id = xfer_rec.TXN_ID;
--end: |           02-APR-07 cklee  R12 Billing enhancement project                 |

    END LOOP; -- For each rec in XSI loop

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Assigned Invoice Numbers: '||l_ar_inv_disp_num);

    -- -------------------------------------------------------
    -- Invoke Advance Receipts
    -- -------------------------------------------------------
    IF p_source = 'ADVANCE_RECEIPTS' THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Begin: Apply Advance Receipts');
        OKL_BPD_ADVANCED_CASH_APP_PUB.ADVANCED_CASH_APP
                                  ( p_api_version   => p_api_version
	                               ,p_init_msg_list => p_init_msg_list
	                               ,x_return_status => x_return_status
	                               ,x_msg_count	    => x_msg_count
	                               ,x_msg_data      => x_msg_data
				      --gkhuntet FP Bug 5516814 start
                                   ,p_contract_num  => l_contract_number
                                   --gkhuntet FP Bug 5516814 end
                                  -- ,p_contract_num  => p_contract_number
                                  ,p_cross_currency_allowed => 'Y'
                                  );

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'End: Apply Advance Receipts');
    END IF;

    IF p_source = 'PRINCIPAL_PAYDOWN' THEN
       x_return_status := l_overall_err_sts;
    END IF;

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------
	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);



--gkhuntet FP Bug 5516814 start
     End;
   End loop;
  --gkhuntet FP Bug 5516814 end


 EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
    WHEN AR_API_CALL_EXCP THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (AR_API_CALL_EXCP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> 'AR_INVOICE_API',
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');




  END ADVANCED_BILLING;


END OKL_BPD_ADVANCED_BILLING_PVT;

/
