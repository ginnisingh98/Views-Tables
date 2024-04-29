--------------------------------------------------------
--  DDL for Package Body OKL_EXT_BILLING_CHARGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXT_BILLING_CHARGES_PVT" AS
/* $Header: OKLRBCGB.pls 120.26.12010000.3 2009/06/03 04:15:16 racheruv ship $ */

  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON BOOLEAN;
  -- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED VARCHAR2(10);
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  -- End of wraper code generated automatically by Debug code generator

  -- Global variable for total records processed
  g_total_rec_count  NUMBER := 0;
  g_txn_rec_count    NUMBER := 0;
  g_apt_rec_count    NUMBER := 0;
  g_batch_num        NUMBER := 0;

  ------------------------------------------------------------------
  -- Procedure BIL_STREAMS to bill outstanding stream elements
  ------------------------------------------------------------------
  PROCEDURE billing_charges(
      p_api_version        IN  NUMBER
     ,p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
     ,x_return_status      OUT NOCOPY VARCHAR2
     ,x_msg_count          OUT NOCOPY NUMBER
     ,x_msg_data           OUT NOCOPY VARCHAR2
     ,p_name               IN  VARCHAR2 DEFAULT NULL
     ,p_sequence_number    IN  NUMBER   DEFAULT NULL
     ,p_date_transmission  IN  DATE     DEFAULT NULL
     ,p_origin             IN  VARCHAR2 DEFAULT NULL
     ,p_destination        IN  VARCHAR2 DEFAULT NULL)
  IS
    ------------------------------------------------------------
    -- Extract all External records to be billed
    ------------------------------------------------------------
    CURSOR c_bill_chrgs
    IS
      SELECT rowid
           , CONTRACT_NUMBER
           , STY_NAME
           , ASSET_NUMBER
           , INVOICE_DATE
           , AMOUNT
           , CURRENCY_CODE
           , STREAM_TYPE_PURPOSE
      FROM OKL_EXT_BILLING_INTERFACE
      WHERE TRX_STATUS_CODE = 'SUBMITTED';

    -- --------------------------------------------
    -- Cursor for all actual property tax records
    -- --------------------------------------------
    CURSOR act_prop_tax_csr ( p_request_id NUMBER )
    IS
      SELECT rowid
           , TRX_STATUS_CODE
           , ERROR_MESSAGE
           , CONTRACT_NUMBER
           , CONTRACT_ID
           , STY_ID
           , STY_NAME
           , ASSET_ID
           , ASSET_NUMBER
           , INVOICE_DATE
           , AMOUNT
           , CURRENCY_CODE
           , ORG_ID
           , JURSDCTN_TYPE
           , JURSDCTN_NAME
           , MLRT_TAX
           , TAX_VENDOR_ID
           , TAX_VENDOR_NAME
           , TAX_VENDOR_SITE_ID
           , TAX_VENDOR_SITE_NAME
           , STREAM_TYPE_PURPOSE
           , TAX_ASSESSMENT_DATE --FPbug#5891876
      FROM OKL_EXT_BILLING_INTERFACE
      WHERE TRX_STATUS_CODE = 'PASSED'
        AND REQUEST_ID = p_request_id
        AND STREAM_TYPE_PURPOSE = 'ACTUAL_PROPERTY_TAX'
      ORDER BY contract_id, asset_id, sty_id ; -- Bug 6375368

    /* Bug#6375368 The Unique Constraint error fires if there are multiple
     * contracts to be processed in OKL_EXT_BILLING_INTERFACE table. As the
     * contract changes and the contract repeats for further processing the
     * max_line_num_csr returns l_max_line_num as NULL or a number thats used
     * earlier for the contract, as the insert for okl_strm_elements is done
     * outside the loop. When the insert is done a unique constraint is fired
     * due to duplication of se_line_number in SEL_TBL. The order by clause
     * is added in act_prop_tax_csr to process the records in order of
     * contract_id, asset_id,sty_id resulting in unique se_line_number for
     * each contract, asset and sty_id.*/
    -- --------------------------------------------
    -- Cursor for all non-actual property tax records
    -- --------------------------------------------
    CURSOR bill_txn_csr ( p_request_id NUMBER )
    IS
      SELECT rowid
           , TRX_STATUS_CODE
           , ERROR_MESSAGE
           , CONTRACT_NUMBER
           , CONTRACT_ID
           , STY_ID
           , STY_NAME
           , ASSET_ID
           , ASSET_NUMBER
           , INVOICE_DATE
           , AMOUNT
           , CURRENCY_CODE
           , ORG_ID
           , JURSDCTN_TYPE
           , JURSDCTN_NAME
           , MLRT_TAX
           , TAX_VENDOR_ID
           , TAX_VENDOR_NAME
           , TAX_VENDOR_SITE_ID
           , TAX_VENDOR_SITE_NAME
           , STREAM_TYPE_PURPOSE
           , TAX_ASSESSMENT_DATE --FPbug#5891876
      FROM OKL_EXT_BILLING_INTERFACE
      WHERE TRX_STATUS_CODE = 'PASSED'
        AND REQUEST_ID = p_request_id
        AND STREAM_TYPE_PURPOSE <> 'ACTUAL_PROPERTY_TAX';

    ------------------------------------------------------------
    -- Declare variables required by APIs
    ------------------------------------------------------------
    l_api_version	CONSTANT NUMBER := 1;
    l_api_name	CONSTANT VARCHAR2(30)  := 'EXTERNAL_BILLING_CHARGES';
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stm_id		NUMBER;

    CURSOR c_stm_id ( p_khr_id NUMBER, p_sty_id NUMBER ) IS
      SELECT id
      FROM okl_streams
      WHERE khr_id = p_khr_id
		    AND sty_id = p_sty_id;

    CURSOR c_sty_id ( p_stream_name VARCHAR2 ) IS
		  SELECT id
		  FROM okl_strm_type_v
		  WHERE name = p_stream_name;

    CURSOR get_khr_id_csr ( p_contract_number VARCHAR2 ) IS
		  SELECT id
		  FROM okc_k_headers_b
		  WHERE contract_number = p_contract_number;

    CURSOR get_currency_csr ( p_contract_number VARCHAR2 ) IS
		  SELECT currency_code
		  FROM okc_k_headers_b
		  WHERE contract_number = p_contract_number;

    CURSOR get_try_id_csr (cp_name VARCHAR2, cp_language VARCHAR2) IS
		  SELECT id
		  FROM okl_trx_types_tl
		  WHERE	name	= cp_name
		   AND LANGUAGE	= cp_language;

    CURSOR get_sty_id_csr ( p_sty_name VARCHAR2, p_purpose_code VARCHAR2 ) IS
		  SELECT id, billable_yn
		  FROM okl_strm_type_v
		  WHERE name =  p_sty_name
		    AND stream_type_purpose = p_purpose_code;

    CURSOR get_sty_name_csr ( p_sty_id NUMBER ) IS
		  SELECT name
		  FROM okl_strm_type_v
		  WHERE id =  p_sty_id;

    CURSOR get_purpose_csr ( p_sty_name VARCHAR2 ) IS
		  SELECT stream_type_purpose
		  FROM okl_strm_type_v
		  WHERE name =  p_sty_name;

    CURSOR get_kle_id_csr ( p_asset_number  VARCHAR2 ) IS
		  SELECT ID
		  FROM okl_k_lines_full_v
		  WHERE name = p_asset_number;

    CURSOR curr_code_csr ( p_currency_code  VARCHAR2) IS
		  SELECT currency_code
		  FROM fnd_currencies
		  WHERE currency_code = p_currency_code;

    ------------------------------------------------------------------
    --Variables required for Billing Engine
    ------------------------------------------------------------------
    l_taiv_rec            okl_tai_pvt.taiv_rec_type;
    l_tldv_rec            okl_tld_pvt.tldv_rec_type;
    l_tilv_rec            okl_til_pvt.tilv_rec_type;
    l_tilv_tbl            okl_til_pvt.tilv_tbl_type;
    l_tldv_tbl            okl_tld_pvt.tldv_tbl_type;
    x_taiv_rec            okl_tai_pvt.taiv_rec_type;
    x_tilv_tbl            okl_til_pvt.tilv_tbl_type;
    x_tldv_tbl            okl_tld_pvt.tldv_tbl_type;
    l_bsl_id              OKS_BILL_SUB_LINES.id%TYPE;
    l_bcl_id              OKS_BILL_CONT_LINES.id%TYPE;
    l_btn_id              OKC_K_REL_OBJS.id%TYPE;

    -- ********************************
    --	Local Variables
    -- ********************************
    l_khr_id 	     okc_k_headers_b.id%type;
    l_kle_id		 NUMBER;
    l_try_id		 okl_trx_types_tl.id%type;
    l_sty_id		 okl_strm_type_b.id%type;
    l_currency_code  fnd_currencies.currency_code%type;
    l_khr_currency   fnd_currencies.currency_code%type;
    l_amount		 okl_trx_ar_invoices_v.amount%TYPE;
    l_strm_purpose   okl_strm_type_v.stream_type_purpose%TYPE;
    l_trx_type_name	 VARCHAR2(30);
    l_trx_type_lang	 CONSTANT VARCHAR2(30)	:= 'US';
    l_err_status	 VARCHAR2(1);
    l_err_msg		 VARCHAR2(1995);

    -- Transaction Headers
    i_taiv_rec		 Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    r_taiv_rec		 Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;

    -- Transaction Lines
    i_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    r_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    l_init_ptcv_rec   okl_property_tax_pub.ptcv_rec_type;
    p_ptcv_rec        okl_property_tax_pub.ptcv_rec_type;
    x_ptcv_rec        okl_property_tax_pub.ptcv_rec_type;

    ------------------------------------------------------------
    -- Declare variables to call Accounting Engine.
    ------------------------------------------------------------
    p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;

		l_actual_tax_count              NUMBER;
		l_max_line_num                  NUMBER;

		l_p_tax_applicable              okc_rules_b.rule_information3%TYPE;
		l_vendor_id                     NUMBER;
		l_vendor_site_id                NUMBER;
		l_p_tax_option                  okl_property_tax_setups.payable_invoice%TYPE;

		------------------------------------------------------------
		-- Get Count of specific stream type
		------------------------------------------------------------
		CURSOR c_sty_count_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_id NUMBER ) IS
      SELECT count(*)
      FROM okl_streams stm
         , okl_strm_type_v sty
      WHERE stm.khr_id = p_khr_id
        AND NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND sty.id = p_sty_id;

    ------------------------------------------------------------
    -- Get stm_id of Actual Property Tax record
    ------------------------------------------------------------
    CURSOR c_stm_id_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_id NUMBER ) IS
		   SELECT stm.id
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
           AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y'
		   AND 	 sty.id = p_sty_id;

    ------------------------------------------------------------
    -- Transaction Number Cursor
    ------------------------------------------------------------
    CURSOR c_tran_num_csr IS
      SELECT okl_sif_seq.nextval
      FROM dual;

    ------------------------------------------------------------
    -- Max Line Number
    ------------------------------------------------------------
    CURSOR max_line_num_csr (p_stm_id NUMBER) IS
      SELECT max(se_line_number)
      FROM okl_strm_elements
      WHERE stm_id = p_stm_id;

    ------------------------------------------------------------
    -- Property Tax applicable cursor
    ------------------------------------------------------------
    CURSOR p_tax_app_csr( p_chr_id IN NUMBER, p_cle_id IN NUMBER ) IS
      SELECT rul.rule_information1
      FROM okc_rule_groups_b rgp,
           okc_rules_b rul
      WHERE rgp.id = rul.rgp_id
        AND rgp.rgd_code = 'LAASTX'
        AND rul.RULE_INFORMATION_CATEGORY = 'LAPRTX'
        AND rul.rule_information3 is not null
        AND rgp.dnz_chr_id = p_chr_id
        AND rgp.cle_id = p_cle_id;

    ------------------------------------------------------------
    -- Vendor Site Cursor (revalidate and retrieve)
    ------------------------------------------------------------
    CURSOR vendor_site_csr( p_vendor_id IN NUMBER,
                            p_vendor_site_id IN NUMBER,
                            p_vendor_site_code IN VARCHAR2 ) IS
      SELECT VENDOR_SITE_ID
      FROM po_vendor_sites_all
      WHERE VENDOR_ID = p_vendor_id
        AND (VENDOR_SITE_ID = p_vendor_site_id OR VENDOR_SITE_CODE = p_vendor_site_code);

    ------------------------------------------------------------
    -- Property Tax set up cursor
    ------------------------------------------------------------
    CURSOR p_tax_options_csr IS
      SELECT PAYABLE_INVOICE
      FROM okl_property_tax_setups;

    -- -------------------------------------------------
    -- Streams Record
    -- -------------------------------------------------
    l_stmv_rec          Okl_Streams_Pub.stmv_rec_type;
    lx_stmv_rec         Okl_Streams_Pub.stmv_rec_type;
    l_init_stmv_rec     Okl_Streams_Pub.stmv_rec_type;
    -- -------------------------------------------------
    -- Stream Elements Record
    -- -------------------------------------------------
    p_selv_rec	        Okl_Sel_Pvt.selv_rec_type;
    x_selv_rec	            Okl_Sel_Pvt.selv_rec_type;
    l_init_selv_rec     Okl_Sel_Pvt.selv_rec_type;

    p_man_inv_rec       OKL_PAY_INVOICES_MAN_PVT.man_inv_rec_type;
    x_man_inv_rec       OKL_PAY_INVOICES_MAN_PVT.man_inv_rec_type;

    l_primary_sty_id    OKL_STRM_TYPE_V.id%TYPE;
    l_dependent_sty_id  OKL_STRM_TYPE_V.id%TYPE;

    l_billable_yn       OKL_STRM_TYPE_V.billable_yn%TYPE;

    l_sty_name          OKL_STRM_TYPE_V.name%TYPE;
    l_valid_strm_yn     VARCHAR2(1);

    l_bill_try_id       NUMBER;
    l_cm_try_id         NUMBER;
    l_commit_cnt        NUMBER;
    l_MAX_commit_cnt    NUMBER := 500;

    -- ------------------------------------------
    -- Performance improvements
    -- ------------------------------------------
    ext_bill_tbl          ext_tbl_type;
    L_FETCH_SIZE          NUMBER := 5000;

    type num_tbl is table of number index  by binary_integer ;
    type date_tbl is table of date index  by binary_integer ;
    type chr_tbl is table of varchar2(2000) index  by binary_integer ;
    type rowid_tbl is table of rowid index  by binary_integer ;

    l_rowid_tbl            rowid_tbl;
    l_contract_tbl         chr_tbl;
    l_sty_tbl              chr_tbl;
    l_asset_num            chr_tbl;
    l_inv_date             date_tbl;
    l_amt_tbl              num_tbl;
    l_curr_code_tbl        chr_tbl;
    l_strm_purpose_tbl     chr_tbl;
    upd_rowid_tbl          rowid_tbl;
    tai_succ_rowid_tbl     rowid_tbl;
    tai_err_rowid_tbl      rowid_tbl;

    -- Base tables for insert
    TYPE tai_tbl_type IS TABLE OF OKL_TRX_AR_INVOICES_B%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE til_tbl_type IS TABLE OF OKL_TXL_AR_INV_LNS_B%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE ptc_tbl_type IS TABLE OF OKL_PROPERTY_TAX_B%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE stm_tbl_type IS TABLE OF OKL_STREAMS%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE sel_tbl_type IS TABLE OF OKL_STRM_ELEMENTS%ROWTYPE INDEX BY BINARY_INTEGER;

    -- TL tables for insert
    TYPE taitl_tbl_type IS TABLE OF OKL_TRX_AR_INVOICES_TL%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE tiltl_tbl_type IS TABLE OF OKL_TXL_AR_INV_LNS_TL%ROWTYPE INDEX BY BINARY_INTEGER;

    TYPE ptctl_tbl_type IS TABLE OF OKL_PROPERTY_TAX_TL%ROWTYPE INDEX BY BINARY_INTEGER;

    tai_tbl       tai_tbl_type;
    til_tbl       til_tbl_type;
    ptc_tbl       ptc_tbl_type;
    stm_tbl       stm_tbl_type;
    sel_tbl       sel_tbl_type;

    taitl_tbl     taitl_tbl_type;
    tiltl_tbl     tiltl_tbl_type;
    ptctl_tbl     ptctl_tbl_type;

    -- Record definitions
    type tai_succ_rec_type is record (id number);
    type tai_succ_tbl_type is table of tai_succ_rec_type index by binary_integer;

    tai_succ_tbl  num_tbl;
    tai_err_tbl   num_tbl;
    header_id_tbl num_tbl;
    upd_sel_tbl   num_tbl;

    l_header_id   NUMBER;
    l_line_id     NUMBER;
    l_taitl_cnt   NUMBER;
    l_tiltl_cnt   NUMBER;
    l_ptctl_cnt   NUMBER;
    l_stmtbl_cnt  NUMBER;
    l_acc_cmt_cnt NUMBER;
    l_legal_entity_id OKL_TRX_AR_INVOICES_B.legal_entity_id%TYPE; -- for LE Uptake project 08-11-2006

    CURSOR get_languages IS
      SELECT *
      FROM FND_LANGUAGES
      WHERE INSTALLED_FLAG IN ('I', 'B');

    -- ----------------------
    -- Std Who columns
    -- ----------------------
    l_last_updated_by     okl_trx_ar_invoices_v.last_updated_by%TYPE := Fnd_Global.USER_ID;
    l_last_update_login   okl_trx_ar_invoices_v.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
    l_request_id          okl_trx_ar_invoices_v.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;

    l_program_application_id
                okl_trx_ar_invoices_v.program_application_id%TYPE := Fnd_Global.PROG_APPL_ID;
    l_program_id  okl_trx_ar_invoices_v.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;

    bulk_errors   EXCEPTION;
    PRAGMA EXCEPTION_INIT (bulk_errors, -24381);

    -- print processing summary variables
    -- ----------------------------------------------------
    -- count successful records for actual property tax
    -- also counts errors
    -- ----------------------------------------------------
    cursor ext_apt_stat_csr( p_request_id NUMBER, p_sts_code VARCHAR2, p_strm_purpose VARCHAR2 ) is
      select count(*)
      from okl_ext_billing_interface
      where request_id = p_request_id
        and trx_status_code = p_sts_code
        and STREAM_TYPE_PURPOSE = p_strm_purpose;

    -- ------------------------------------------------------
    -- count successful records for non-actual property tax
    -- also counts errors
    -- ------------------------------------------------------
    cursor ext_non_apt_stat_csr( p_request_id NUMBER, p_sts_code VARCHAR2, p_strm_purpose VARCHAR2 ) is
      select count(*)
      from okl_ext_billing_interface
      where request_id = p_request_id
        and trx_status_code = p_sts_code
        and STREAM_TYPE_PURPOSE <> p_strm_purpose;

    -- ------------------------------------------------------
    -- print error message
    -- ------------------------------------------------------
    cursor error_msg_csr( p_request_id NUMBER, p_sts_code VARCHAR2 ) is
      select rpad(substr(contract_number,1,30),30,' ') contract_number,
             rpad(substr(asset_number,1,30),30,' ') asset_number,
             rpad(substr(sty_name,1,30),30,' ') sty_name,
             to_char(invoice_date,'DD-MON-RRRR') invoice_date,
             error_message
      from okl_ext_billing_interface
      where request_id = p_request_id
        and trx_status_code = p_sts_code;

    -- ----------------------------------------------------------
    -- Operating Unit
    -- ----------------------------------------------------------
    CURSOR op_unit_csr IS
      SELECT NAME
      FROM hr_operating_units
      WHERE ORGANIZATION_ID = MO_GLOBAL.GET_CURRENT_ORG_ID; -- MOAC fix - Bug#5378114 --varangan- 29-9-06

    l_succ_apt_cnt      NUMBER;
    l_err_apt_cnt       NUMBER;

    l_succ_non_apt_cnt  NUMBER;
    l_err_non_apt_cnt   NUMBER;
    lx_msg_data         VARCHAR2(450);
    l_msg_index_out     NUMBER := 0;
    l_op_unit_name      hr_operating_units.name%TYPE;

    processed_sts       okl_trx_ar_invoices_v.trx_status_code%TYPE := 'PROCESSED';
    error_sts           okl_trx_ar_invoices_v.trx_status_code%TYPE := 'ERROR';

    --added by kbbhavsa : Bug 5344799/5362220 : 27-June-06
    l_sty_desc          OKL_STRM_TYPE_V.name%TYPE;
 	  l_temp_index NUMBER;
 	  x_multiple_line_error EXCEPTION;
 	  PRAGMA EXCEPTION_INIT (x_multiple_line_error, -24381 ); -- ORA-24381: error(s) in array DML
  BEGIN
    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Begin(+)');
      END IF;
    END IF;

    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name     => l_api_name
                          ,p_pkg_name     => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => '_PVT'
                          ,x_return_status => l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    ------------------------------------------------------------
    -- Process every external billing line for billing import
    ------------------------------------------------------------
    FND_FILE.PUT_LINE (FND_FILE.log, '================================================================');
    FND_FILE.PUT_LINE (FND_FILE.log, '    *** START PROCESSING THIRD PARTY BILLING RECORDS ***');
    FND_FILE.PUT_LINE (FND_FILE.log, '================================================================');

    -- -----------------------------------------------------
    -- Fetch property tax
    -- -----------------------------------------------------
    l_p_tax_applicable := NULL;
    OPEN  p_tax_options_csr;
    FETCH p_tax_options_csr INTO l_p_tax_applicable;
    CLOSE p_tax_options_csr;

    -- -----------------------------------------------------
    -- Get transaction type
    -- -----------------------------------------------------
    l_trx_type_name	 := 'Billing';
    l_bill_try_id    := NULL;
    OPEN  get_try_id_csr (l_trx_type_name, l_trx_type_lang);
    FETCH get_try_id_csr INTO l_bill_try_id;
    CLOSE get_try_id_csr;

    l_trx_type_name	 := 'Credit Memo';
    l_cm_try_id      := NULL;
   	OPEN  get_try_id_csr (l_trx_type_name, l_trx_type_lang);
    FETCH get_try_id_csr INTO l_cm_try_id;
    CLOSE get_try_id_csr;
    -- --------------------------------------------
    -- Print error message and stop processing
    -- --------------------------------------------
    if l_bill_try_id is null or l_cm_try_id is null then
      	FND_FILE.PUT_LINE (FND_FILE.log, '********************** ERROR **********************');
      	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'BILLING or CREDIT MEMO transaction type is invalid.');
      	FND_FILE.PUT_LINE (FND_FILE.log, '********************** ERROR **********************');

        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    if l_request_id = -1 then
       l_request_id := NULL;
    end if;

    if l_program_application_id = -1 then
       l_program_application_id := NULL;
    end if;

    if l_program_id = -1 then
       l_program_id := NULL;
    end if;

    if l_request_id is null then
      FND_FILE.PUT_LINE (FND_FILE.log, '********************** ERROR **********************');
      FND_FILE.PUT_LINE (FND_FILE.log,
       'Cannot determine request Id from profile. The function Fnd_Global.CONC_REQUEST_ID returns -1.');
      FND_FILE.PUT_LINE (FND_FILE.log, '********************** ERROR **********************');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- -------------------------------
    -- Process each cursor record
    -- -------------------------------
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*** Start Validation ***');
    END IF;

    g_batch_num := 0;

    OPEN c_bill_chrgs;
    LOOP
      g_batch_num := g_batch_num + 1;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validating batch number: '||g_batch_num);
      END IF;

      l_rowid_tbl.delete;
      l_contract_tbl.delete;
      l_sty_tbl.delete;
      l_asset_num.delete;
      l_inv_date.delete;
      l_amt_tbl.delete;
      l_curr_code_tbl.delete;
      l_strm_purpose_tbl.delete;

      FETCH c_bill_chrgs BULK COLLECT INTO
	                   l_rowid_tbl,
	                   l_contract_tbl,
	                   l_sty_tbl,
	                   l_asset_num,
	                   l_inv_date,
	                   l_amt_tbl,
	                   l_curr_code_tbl,
                       l_strm_purpose_tbl
                       LIMIT L_FETCH_SIZE;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> number of records: '||l_rowid_tbl.count);
      END IF;

      -- update global total rec count
      g_total_rec_count := g_total_rec_count + l_rowid_tbl.count;

      -- -------------------------------------------------------
      -- update std who parameters in okl_ext_billing_interface
      -- -------------------------------------------------------
      if l_rowid_tbl.count > 0 then
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - populate std who columns.');
        END IF;
        forall indx in l_rowid_tbl.first..l_rowid_tbl.last
          update okl_ext_billing_interface
          set CREATED_BY          = l_last_updated_by,
              CREATION_DATE       = sysdate,
              LAST_UPDATED_BY     = l_last_updated_by,
              LAST_UPDATE_DATE    = sysdate,
              LAST_UPDATE_LOGIN   = l_last_update_login,
              REQUEST_ID          = l_request_id,
              PROGRAM_APPLICATION_ID = l_program_application_id,
              PROGRAM_ID          = l_program_id,
              PROGRAM_UPDATE_DATE = sysdate
          where rowid = l_rowid_tbl(indx);
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - populate std who columns.');
        END IF;
      END IF;

      IF l_strm_purpose_tbl.count > 0 THEN
        -- ---------------------------------
        -- Validate Stream Type Purpose
        -- ---------------------------------
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate stream type purpose.');
        END IF;
        forall indx in l_strm_purpose_tbl.first..l_strm_purpose_tbl.last
          update okl_ext_billing_interface
          set trx_status_code =
                decode(l_strm_purpose_tbl(indx),NULL,'ERROR',
--                       'RENT','ERROR',
--                       'ADVANCE_RENT','ERROR',
--                       'INTEREST_PAYMENT','ERROR',
--                       'PRINCIPAL_PAYMENT','ERROR',
                       trx_status_code
                       )
               ,error_message =
                decode(l_strm_purpose_tbl(indx),NULL,'Stream Type purpose cannot be null. '--,
--                       'RENT','STREAM PURPOSE RENT is not supported. ',
--                       'ADVANCE_RENT','STREAM PURPOSE ADVANCE RENT is not supported. ',
--                       'INTEREST_PAYMENT','STREAM PURPOSE INTEREST PAYMENT is not supported. ',
--                       'PRINCIPAL_PAYMENT','STREAM PURPOSE PRINCIPAL PAYMENT is not supported. '
                       )
            where rowid = l_rowid_tbl(indx);
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate stream type purpose.');
        END IF;
      END IF; -- stream type purpose validation

      -- ---------------------------------
      -- Validate Amount
      -- ---------------------------------
      if l_amt_tbl.count > 0 then
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate amount.');
        END IF;
        forall indx in l_amt_tbl.first..l_amt_tbl.last
          update okl_ext_billing_interface
            set trx_status_code = decode(l_amt_tbl(indx),NULL, 'ERROR',trx_status_code),
                error_message =
                    decode(l_amt_tbl(indx),NULL, error_message||'Amount Cannot be null. ',
                           0, error_message||'Amount must be non-zero. ',
                           error_message)
          where rowid = l_rowid_tbl(indx);
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate amount.');
        END IF;
      END IF; -- Update rows to passed status

      -- ---------------------------------
      -- Validate Contract
      -- ---------------------------------
      if l_contract_tbl.count > 0 then
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate contract number.');
        END IF;
        FORALL indx in l_contract_tbl.first..l_contract_tbl.last
          update okl_ext_billing_interface a
            set contract_id = (select id
                               from okc_k_headers_b b
                               where b.contract_number = a.contract_number)
          where rowid = l_rowid_tbl(indx);
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate contract number.');
        END IF;
      END IF;

      -- ---------------------------------
      -- Validate Asset
      -- ---------------------------------
      -- PAGARG - Bug# 6884934 - Modified Start
 	    -- Modified to enhance the logic when ASSET_ID is also part of import record
 	    -- The following cases are handled by the BULK UPDATION CODE
 	    -- CASE 1 - When ASSET_NUMBER is NULL, the record is not updated
 	    -- CASE 2 - When ASSET_NUMBER present and ASSET_ID present, code validates and updates the
 	    --          NULL if the ASSET_ID doesnot correspond to the ASSET_NUMBER
 	    -- CASE 3 - When ASSET_NUMBER present and ASSET_ID is NULL, code checks if there are multiple
 	    --          contract lines with same line name and errors accordingly
      IF l_asset_num.count > 0 THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate asset number.');
        END IF;
 	      BEGIN
          FORALL indx IN l_asset_num.FIRST..l_asset_num.LAST SAVE EXCEPTIONS
            UPDATE okl_ext_billing_interface a
              SET asset_id = (SELECT id
                              FROM OKL_K_LINES_FULL_V b
                              -- NVL is for imported contracts where
                              -- Service Name is NULL in OKC_K_LINES_TL
                              WHERE NVL(b.name, a.ASSET_NUMBER) = a.ASSET_NUMBER
                                AND b.ID = NVL(A.ASSET_ID, b.ID)
                                AND b.dnz_chr_id = a.contract_id)
            WHERE rowid = l_rowid_tbl(indx)
              AND a.ASSET_NUMBER IS NOT NULL;
        EXCEPTION
 	        WHEN x_multiple_line_error THEN
 	          -- This exception will be thrown if there are similar service lines
 	          -- on the same contract and ASSET_ID is not present in the record
 	          -- OKL_EXT_BILLING_INTERFACE. In this case the select query returns
 	          -- all the service lines based on the Service Name

 	          -- Update the status of the record as ERROR with error message
 	          FOR err_indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
 	          LOOP
 	            l_temp_index := SQL%BULK_EXCEPTIONS(err_indx).ERROR_INDEX;
 	            UPDATE OKL_EXT_BILLING_INTERFACE B_INT
 	              SET TRX_STATUS_CODE = 'ERROR'
 	                , ERROR_MESSAGE = ERROR_MESSAGE || 'Multiple contract lines with same name. Please also provide Contract Line ID.'
 	            WHERE rowid = l_rowid_tbl(l_temp_index);
 	          END LOOP;
 	      END; -- end of ASSET_ID updation
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate asset number.');
        END IF;
      END IF;
      -- PAGARG - Bug# 6884934 - Modified End

      -- ---------------------------------
      -- Validate Stream Type Name
      -- ---------------------------------
      IF l_sty_tbl.count > 0 THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate stream type assignment to a stream generation template.');
        END IF;
        forall indx in l_sty_tbl.first..l_sty_tbl.last
          update okl_ext_billing_interface a
            set sty_id = (SELECT GTLV.PRIMARY_STY_ID STY_ID
                          FROM
                                OKL_ST_GEN_TMPT_LNS GTLV,
                                OKL_ST_GEN_TEMPLATES GTTV,
                                OKL_ST_GEN_TMPT_SETS GTSV,
                                OKL_AE_TMPT_SETS AES,
                                OKL_PRODUCTS PDT,
                                OKL_STRM_TYPE_V STY,
                                okl_k_headers khr,
                                okc_k_headers_b chr
                          WHERE
                                GTLV.GTT_ID = GTTV.ID AND
                                GTTV.GTS_ID = GTSV.ID AND
                                GTTV.TMPT_STATUS = 'ACTIVE' AND
                                GTSV.ID = AES.GTS_ID AND
                                AES.ID = PDT.AES_ID AND
                                GTLV.PRIMARY_STY_ID = STY.ID AND
                                GTLV.PRIMARY_YN = 'Y' and
                                -- added stmathew
                                khr.id = chr.id and
                                khr.pdt_id = pdt.id and
                                GTTV.start_date <= chr.start_date and
                                (GTTV.end_date >= chr.start_date or GTTV.end_date is null ) and
                                sty.billable_yn = 'Y' and
                                khr.id = a.CONTRACT_ID and
                                sty.name = a.STY_NAME and
                                sty.stream_type_purpose = a.STREAM_TYPE_PURPOSE
                          UNION ALL
                          SELECT
                                DISTINCT
                                GTLV.DEPENDENT_STY_ID STY_ID
                          FROM
                                OKL_ST_GEN_TMPT_LNS GTLV,
                                OKL_ST_GEN_TEMPLATES GTTV,
                                OKL_ST_GEN_TMPT_SETS GTSV,
                                OKL_AE_TMPT_SETS AES,
                                OKL_PRODUCTS PDT,
                                OKL_STRM_TYPE_V STY,
                                okl_k_headers khr,
                                okc_k_headers_b chr
                          WHERE
                                GTLV.GTT_ID = GTTV.ID AND
                                GTTV.GTS_ID = GTSV.ID AND
                                GTTV.TMPT_STATUS = 'ACTIVE' AND
                                GTSV.ID = AES.GTS_ID AND
                                AES.ID = PDT.AES_ID AND
                                GTLV.DEPENDENT_STY_ID = STY.ID AND
                                (GTLV.PRIMARY_YN = 'N' or GTLV.PRIMARY_YN is null) AND
                                -- added stmathew
                                khr.id = chr.id and
                                khr.pdt_id = pdt.id and
                                GTTV.start_date <= chr.start_date and
                                (GTTV.end_date >= chr.start_date or GTTV.end_date is null ) and
                                sty.billable_yn = 'Y' and
                                khr.id = a.CONTRACT_ID and
                                sty.name = a.STY_NAME and
                                sty.stream_type_purpose = a.STREAM_TYPE_PURPOSE)
          WHERE rowid = l_rowid_tbl(indx);
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate stream type assignment to a stream generation template.');
        END IF;
      END IF;

      -- ---------------------------------
      -- Validate khr_id
      -- ---------------------------------
      if l_rowid_tbl.count > 0 then
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - flag invalid contracts.');
        END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface
                set trx_status_code = decode(contract_id,NULL,'ERROR',trx_status_code),
                    error_message = decode(contract_id,NULL,error_message||'Invalid Contract. ',error_message)
                where rowid = l_rowid_tbl(indx);
            commit;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - flag invalid contracts.');
        END IF;
      END IF;

      -- PAGARG - Bug# 6884934 - Modified Start
      -- ---------------------------------
      -- Validate kle_id
         -- Errors if
            -- Line ID doesnot match the Line Name
 	          -- Line ID is not correct for the contract
 	          -- Line Name is not correct for the contract
      -- ---------------------------------
      IF l_rowid_tbl.count > 0 THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - flag invalid lines.');
        END IF;
        FORALL indx in l_rowid_tbl.first..l_rowid_tbl.last
          UPDATE OKL_EXT_BILLING_INTERFACE a
            SET TRX_STATUS_CODE = 'ERROR',
                ERROR_MESSAGE = ERROR_MESSAGE||'Invalid Line name or Line Id.'
          WHERE rowid = l_rowid_tbl(indx)
            AND (a.ASSET_NUMBER IS NOT NULL OR a.ASSET_ID IS NOT NULL)
            AND NOT EXISTS ( SELECT 1
                             FROM OKL_K_LINES_FULL_V LNS
                             WHERE LNS.ID = a.ASSET_ID
                               -- IS NULL condition is useful for imported contracts
                               -- where Service Name is NULL in OKC_K_LINES_TL
                               AND ( LNS.NAME IS NULL OR LNS.NAME = NVL(a.ASSET_NUMBER, LNS.NAME))
                               AND LNS.DNZ_CHR_ID = a.CONTRACT_ID);
        COMMIT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - flag invalid lines.');
        END IF;
      END IF;
      -- PAGARG - Bug# 6884934 - Modified End

        -- ---------------------------------
        -- Validate sty_id
        -- ---------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - flag invalid stream types.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface
                set trx_status_code = decode(sty_id,NULL,'ERROR',trx_status_code),
                    error_message = decode(sty_id,NULL,
                    error_message||'Stream type is invalid, non-billable or unattached to a template. ',
                    error_message)
                where rowid = l_rowid_tbl(indx);
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - flag invalid stream types.');
            END IF;
        end if;

        -- ---------------------------------
        -- Validate invoice_date
        -- ---------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate invoice date.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface
                set trx_status_code = decode(invoice_date,NULL,'ERROR',trx_status_code),
                    error_message = decode(invoice_date,NULL,error_message||'Invoice Date is Null. ',error_message)
                where rowid = l_rowid_tbl(indx);
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate invoice date.');
            END IF;
        end if;

        -- ---------------------------------
        -- update vendor_id
        -- ---------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - populate vendor id.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set TAX_VENDOR_ID = (SELECT VENDOR_ID
                                     FROM po_vendors b
                                     WHERE b.VENDOR_TYPE_LOOKUP_CODE = 'TAX AUTHORITY'
                                     AND b.VENDOR_NAME = a.TAX_VENDOR_NAME)
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - populate vendor id.');
            END IF;
        end if;

        -- ---------------------------------
        -- update vendor_site_id
        -- ---------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - populate vendor site id.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set TAX_VENDOR_SITE_ID = (SELECT VENDOR_SITE_ID
                                     FROM po_vendor_sites_all b
                                     WHERE b.VENDOR_ID = a.TAX_VENDOR_ID
                                     AND b.VENDOR_SITE_CODE = a.TAX_VENDOR_SITE_NAME
                                     AND b.ORG_ID = a.ORG_ID ) --6144718
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - populate vendor site id.');
            END IF;
        end if;

        -- --------------------------------------
        -- validate vendor_id or vendor site id
        -- for actual property tax
        -- --------------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - flag invalid tax vendor id.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set trx_status_code = decode( TAX_VENDOR_ID,NULL,'ERROR', trx_status_code),
                    error_message = decode( TAX_VENDOR_ID,NULL,error_message||'Invalid Tax Vendor Id. ', error_message)
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - flag invalid tax vendor id.');
            END IF;
        end if;

        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - flag invalid tax vendor site id.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set trx_status_code = decode( TAX_VENDOR_SITE_ID,NULL,'ERROR', trx_status_code),
                    error_message = decode( TAX_VENDOR_SITE_ID,NULL,
                    error_message||'Invalid Tax Vendor Site Id. ', error_message)
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - flag invalid tax vendor site id.');
            END IF;
        end if;

        -- --------------------------------------------
        -- kle_id is mandatory for Actual Property Tax
        -- --------------------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - asset id check for actual property tax.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set trx_status_code = decode( ASSET_ID,NULL,'ERROR', trx_status_code),
                    error_message = decode( ASSET_ID,NULL,
                        error_message||'Asset Id is mandatory for ACTUAL_PROPERTY_TAX. ', error_message)
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - asset id check for actual property tax.');
            END IF;
        end if;

        -- --------------------------------------------
        -- prop_tax_applicable_yn update with right values
        -- for actual property tax
        -- --------------------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - populate property tax applicable flag.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set prop_tax_applicable_yn = (
                            SELECT NVL(rul.rule_information1,'N')
                            FROM okc_rule_groups_b rgp,
                                 okc_rules_b rul
                            WHERE rgp.id = rul.rgp_id
                            AND rgp.rgd_code = 'LAASTX'
                            AND rul.RULE_INFORMATION_CATEGORY = 'LAPRTX'
                            AND rul.rule_information3 is not null
                            AND rgp.dnz_chr_id = a.contract_id
                            AND rgp.cle_id = a.asset_id)
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - populate property tax applicable flag.');
            END IF;
        end if;

        -- --------------------------------------------
        -- validate prop_tax_applicable_yn
        -- --------------------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - validate property tax applicable flag.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface a
                set trx_status_code = decode( prop_tax_applicable_yn,NULL,'ERROR','N','ERROR', trx_status_code),
                    error_message = decode( prop_tax_applicable_yn,NULL,error_message
                                                                    ||'Property Tax Not Applicable for Asset. '
                                                                  ,'N',error_message
                                                                    ||'Property Tax Not Applicable for Asset. '
                                            ,error_message)
                where rowid = l_rowid_tbl(indx)
                and stream_type_purpose = 'ACTUAL_PROPERTY_TAX';
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validate property tax applicable flag.');
            END IF;
        end if;

        -- -----------------------------------------
        -- Update non-error rows to PASSED status
        -- -----------------------------------------
        if l_rowid_tbl.count > 0 then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - update successfully validated rows to status of PASSED.');
            END IF;
            forall indx in l_rowid_tbl.first..l_rowid_tbl.last
                update okl_ext_billing_interface
                set trx_status_code = decode(trx_status_code,'SUBMITTED', 'PASSED',trx_status_code)
                where rowid = l_rowid_tbl(indx);
            commit;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - update successfully validated rows to status of PASSED.');
            END IF;
        end if; -- Update rows to passed status

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - validating batch number: '||g_batch_num);
      END IF;
      EXIT WHEN c_bill_chrgs%NOTFOUND;
    END LOOP;
    CLOSE c_bill_chrgs;

    g_batch_num := 0;
    -- -------------------------------------
    -- process billing transaction records
    -- -------------------------------------
    OPEN  bill_txn_csr( l_request_id );
    LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - processing billing transactions batch number: '||g_batch_num);
      END IF;
      ext_bill_tbl.delete;
      tai_tbl.delete;
      til_tbl.delete;
      taitl_tbl.delete;
      tiltl_tbl.delete;
      upd_rowid_tbl.delete;
      header_id_tbl.delete;
      FETCH bill_txn_csr BULK COLLECT
        INTO ext_bill_tbl
        LIMIT L_FETCH_SIZE;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> number of records: '||ext_bill_tbl.count);
      END IF;

      -- -------------------------------------
      -- process billing transaction records
      -- -------------------------------------
      if ext_bill_tbl.count > 0 then
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - populating transaction header and line record.');
        END IF;
        for indx in ext_bill_tbl.first..ext_bill_tbl.last loop
          -- save rowid for later update
          upd_rowid_tbl(indx) := ext_bill_tbl(indx).ext_rowid;

          tai_tbl(indx).khr_id		:= ext_bill_tbl(indx).contract_id;
          tai_tbl(indx).legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(ext_bill_tbl(indx).contract_id);
          tai_tbl(indx).date_invoiced	:= ext_bill_tbl(indx).INVOICE_DATE;

          IF ext_bill_tbl(indx).amount > 0 THEN
            tai_tbl(indx).try_id := l_bill_try_id;
          ELSE
            tai_tbl(indx).try_id := l_cm_try_id;
          END IF;

          tai_tbl(indx).date_entered		:= sysdate;
          tai_tbl(indx).trx_status_code	:= 'ERROR';
          tai_tbl(indx).amount		    := ext_bill_tbl(indx).amount;
          --added by kbbhavsa : Bug 5344799/5362220 : 27-June-06
          l_sty_desc        := ext_bill_tbl(indx).STY_NAME;
          ---------------------------------------------
          -- Other Mandatory Columns
          ---------------------------------------------
          tai_tbl(indx).CREATION_DATE     := SYSDATE;
          tai_tbl(indx).CREATED_BY        := l_last_updated_by;
          tai_tbl(indx).LAST_UPDATE_DATE  := SYSDATE;
          tai_tbl(indx).LAST_UPDATED_BY   := l_last_updated_by;
          tai_tbl(indx).LAST_UPDATE_LOGIN := l_last_update_login;
          tai_tbl(indx).OBJECT_VERSION_NUMBER := 1;
          l_header_id   := Okc_P_Util.raw_to_number(sys_guid());
          tai_tbl(indx).ID                     := l_header_id;
          tai_tbl(indx).trx_number             := SUBSTR(TO_CHAR(l_header_id),-6);
          tai_tbl(indx).request_id             := l_request_id;
          tai_tbl(indx).program_application_id := l_program_application_id;
          tai_tbl(indx).program_id             := l_program_id;
          tai_tbl(indx).program_update_date    := sysdate;

          -- save tai_id's
          header_id_tbl(indx) := l_header_id;
          -------------------------------------------------------------------
          -- Process Invoice record for calling Billing Engine
          -------------------------------------------------------------------
          IF ext_bill_tbl(indx).amount > 0 THEN
            l_taiv_rec.try_id := l_bill_try_id;
          ELSE
            l_taiv_rec.try_id := l_cm_try_id;
          END IF;
          l_khr_id                   := ext_bill_tbl(indx).contract_id;
          l_taiv_rec.khr_id          := l_khr_id;
          l_taiv_rec.date_invoiced   := ext_bill_tbl(indx).INVOICE_DATE;
          l_taiv_rec.date_entered    := sysdate;
          l_taiv_rec.amount          := ext_bill_tbl(indx).amount;
          /* sosharma 10-Apr-07
             added parameters to be passed to billing procedure
             Start Changes*/
          l_taiv_rec.trx_status_code:='SUBMITTED';
          l_taiv_rec.okl_source_billing_trx:='THIRD_PARTY_IMPORT';
          l_taiv_rec.description := l_sty_desc;
          /* sosharma end changes */
	        --other mandatory columns
	        l_taiv_rec.CREATION_DATE     := SYSDATE;
	        l_taiv_rec.CREATED_BY        := l_last_updated_by;
	        l_taiv_rec.LAST_UPDATE_DATE  := SYSDATE;
	        l_taiv_rec.LAST_UPDATED_BY   := l_last_updated_by;
	        l_taiv_rec.LAST_UPDATE_LOGIN := l_last_update_login;
	        l_taiv_rec.OBJECT_VERSION_NUMBER := 1;
	        l_taiv_rec.request_id             := l_request_id;
	        l_taiv_rec.program_application_id := l_program_application_id;
	        l_taiv_rec.program_id             := l_program_id;
	        l_taiv_rec.program_update_date    := sysdate;

	        ---------------------------------------------
	        -- Create TAI_TL records
	        ---------------------------------------------
	        l_taitl_cnt     := taitl_tbl.count;
	        FOR l_lang_rec IN get_languages LOOP
            l_taitl_cnt     := l_taitl_cnt + 1;
            taitl_tbl(l_taitl_cnt).ID                := l_header_id;
            taitl_tbl(l_taitl_cnt).LANGUAGE          := l_lang_rec.language_code;
            taitl_tbl(l_taitl_cnt).SOURCE_LANG       := USERENV('LANG');
            taitl_tbl(l_taitl_cnt).SFWT_FLAG         := 'N';
            --taitl_tbl(l_taitl_cnt).DESCRIPTION       := 'Imported Billing Transaction';
            taitl_tbl(l_taitl_cnt).DESCRIPTION       := l_sty_desc;  -- Added : bug 5362220 : prasjian
            taitl_tbl(l_taitl_cnt).CREATION_DATE     := SYSDATE;
            taitl_tbl(l_taitl_cnt).CREATED_BY        := l_last_updated_by;
            taitl_tbl(l_taitl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            taitl_tbl(l_taitl_cnt).LAST_UPDATED_BY   := l_last_updated_by;
            taitl_tbl(l_taitl_cnt).LAST_UPDATE_LOGIN := l_last_update_login;
          END LOOP;

          ---------------------------------------------
          -- Populate required columns
          ---------------------------------------------
          til_tbl(indx).kle_id		        := ext_bill_tbl(indx).asset_id;
          til_tbl(indx).line_number		    := 1;
          til_tbl(indx).tai_id		        := l_header_id;
          til_tbl(indx).sty_id		        := ext_bill_tbl(indx).sty_id;
          til_tbl(indx).inv_receiv_line_code	:= 'LINE';
          til_tbl(indx).amount		        := ext_bill_tbl(indx).amount;
          l_line_id                           := Okc_P_Util.raw_to_number(sys_guid());
          til_tbl(indx).ID                    := l_line_id;
          til_tbl(indx).OBJECT_VERSION_NUMBER  := 1;
          til_tbl(indx).CREATION_DATE          := SYSDATE;
          til_tbl(indx).CREATED_BY             := l_last_updated_by;
          til_tbl(indx).LAST_UPDATE_DATE       := SYSDATE;
          til_tbl(indx).LAST_UPDATED_BY        := l_last_updated_by;
          til_tbl(indx).LAST_UPDATE_LOGIN      := l_last_update_login;
          til_tbl(indx).request_id             := l_request_id;
          til_tbl(indx).program_application_id := l_program_application_id;
          til_tbl(indx).program_id             := l_program_id;
          til_tbl(indx).program_update_date    := sysdate;

          ---------------------------------------------
          -- Create TIL_TL records
          ---------------------------------------------
          l_tiltl_cnt := tiltl_tbl.count;
          FOR l_lang_rec IN get_languages LOOP
            l_tiltl_cnt     := l_tiltl_cnt + 1;
            tiltl_tbl(l_tiltl_cnt).ID                := l_line_id;
            tiltl_tbl(l_tiltl_cnt).LANGUAGE          := l_lang_rec.language_code;
            tiltl_tbl(l_tiltl_cnt).SOURCE_LANG       := USERENV('LANG');
            tiltl_tbl(l_tiltl_cnt).SFWT_FLAG         := 'N';
            -- tiltl_tbl(l_tiltl_cnt).DESCRIPTION       :=  'Imported Billing Transaction';
            tiltl_tbl(l_tiltl_cnt).DESCRIPTION       := l_sty_desc;  -- Added : bug 5362220 : prasjian
            tiltl_tbl(l_tiltl_cnt).CREATION_DATE     := SYSDATE;
            tiltl_tbl(l_tiltl_cnt).CREATED_BY        := l_last_updated_by;
            tiltl_tbl(l_tiltl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            tiltl_tbl(l_tiltl_cnt).LAST_UPDATED_BY   := l_last_updated_by;
            tiltl_tbl(l_tiltl_cnt).LAST_UPDATE_LOGIN := l_last_update_login;
          END LOOP;

          ---------------------------------------------------------------------
          -- Process Invoice Line record for Billing Engine
          ---------------------------------------------------------------------
          l_tilv_rec.kle_id		        := ext_bill_tbl(indx).asset_id;
	        l_tilv_rec.line_number		        := 1;
	        l_tilv_rec.sty_id		        := ext_bill_tbl(indx).sty_id;
	        l_tilv_rec.inv_receiv_line_code	:= 'LINE';
	        l_tilv_rec.amount		        := ext_bill_tbl(indx).amount;
	        --other mandatory columns
	        l_tilv_rec.OBJECT_VERSION_NUMBER  := 1;
	        l_tilv_rec.CREATION_DATE          := SYSDATE;
	        l_tilv_rec.CREATED_BY             := l_last_updated_by;
	        l_tilv_rec.LAST_UPDATE_DATE       := SYSDATE;
	        l_tilv_rec.LAST_UPDATED_BY        := l_last_updated_by;
	        l_tilv_rec.LAST_UPDATE_LOGIN      := l_last_update_login;
	        l_tilv_rec.request_id             := l_request_id;
	        l_tilv_rec.program_application_id := l_program_application_id;
	        l_tilv_rec.program_id             := l_program_id;
	        l_tilv_rec.program_update_date    := sysdate;

	        /* sosharma 10-Apr-07
             added parameters to be passed to billing procedure
             Srart Changes*/
          l_tilv_rec.TXL_AR_LINE_NUMBER     :=1;
          l_tilv_rec.description := l_sty_desc;
          /*  sosharma end changes */
          ---------------------------------------------------------------------
          -- Process Line Detail record for Billing Engine
          ---------------------------------------------------------------------
          l_tilv_tbl(0)				:= l_tilv_rec;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - call to billing centralized API.');
          END IF;

          OKL_INTERNAL_BILLING_PVT.CREATE_BILLING_TRX(
              p_api_version
             ,p_init_msg_list
             ,x_return_status
             ,x_msg_count
             ,x_msg_data
             ,l_taiv_rec
             ,l_tilv_tbl
             ,l_tldv_tbl
             ,x_taiv_rec
             ,x_tilv_tbl
             ,x_tldv_tbl);

          IF x_return_status <> 'S' THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' -- ERROR: Creating Billing Transactions using Billing Engine');
            END IF;
            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
	        END IF;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - call to billing centralized API.');
          END IF;

          l_tilv_tbl.delete;
          l_tldv_tbl.delete;
        END LOOP; -- process records in ext_bill_tbl

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - populating transaction header and line record.');
        END IF;
      END IF; -- check if ext_bill_tbl has records
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - processing billing transactions batch number: '||g_batch_num);
      END IF;
      EXIT WHEN bill_txn_csr%NOTFOUND;
    END LOOP; -- process transaction records

    COMMIT;
    -- ----------------------------------------------
    -- clean up after processing transaction records
    -- ----------------------------------------------
    ext_bill_tbl.delete;
    tai_tbl.delete;
    til_tbl.delete;
    taitl_tbl.delete;
    tiltl_tbl.delete;
    upd_rowid_tbl.delete;
    header_id_tbl.delete;

    -- ---------------------------------------
    -- end process billing transaction records
    -- ---------------------------------------

    -- ---------------------------------------
    -- begin processing actual prop tax strm
    -- elements
    -- ---------------------------------------
    g_batch_num := 0;
    OPEN  act_prop_tax_csr( l_request_id );
    LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - processing actual property tax records batch number: '||g_batch_num);
      END IF;

      ext_bill_tbl.delete;
      ptc_tbl.delete;
      ptctl_tbl.delete;
      stm_tbl.delete;
      sel_tbl.delete;
      upd_rowid_tbl.delete;
      upd_sel_tbl.delete;
      FETCH act_prop_tax_csr BULK COLLECT
        INTO ext_bill_tbl
        LIMIT L_FETCH_SIZE;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> number of records: '||ext_bill_tbl.count);
      END IF;
      -- -------------------------------------
      -- process billing transaction records
      -- -------------------------------------
      IF ext_bill_tbl.count > 0 THEN
        -- -------------------------------------------
        -- loop thru ext_bill_tbl and process records
        -- -------------------------------------------
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++ begin - populate property tax parameters record, stm rec and sel rec.');
        END IF;
        FOR indx in ext_bill_tbl.first..ext_bill_tbl.last
        LOOP
          -- save rowid for later update
          upd_rowid_tbl(indx) := ext_bill_tbl(indx).ext_rowid;

          ptc_tbl(indx).id                   := Okc_P_Util.raw_to_number(sys_guid());
          ptc_tbl(indx).asset_id             := ext_bill_tbl(indx).ASSET_ID;
          ptc_tbl(indx).asset_number         := ext_bill_tbl(indx).ASSET_NUMBER;
          ptc_tbl(indx).khr_id               := ext_bill_tbl(indx).contract_id;
          ptc_tbl(indx).contract_number      := ext_bill_tbl(indx).CONTRACT_NUMBER;
  		    --rviriyal 05-Feb-2008 bug#6764803 Populated kle_id to view actual property tax in lease center.
          ptc_tbl(indx).kle_id              := ext_bill_tbl(indx).ASSET_ID;
		      --end 05-Feb-2008 bug#6764803
          ptc_tbl(indx).sty_name             := ext_bill_tbl(indx).STY_NAME;
          ptc_tbl(indx).sty_id               := ext_bill_tbl(indx).sty_id;
          ptc_tbl(indx).invoice_date         := ext_bill_tbl(indx).INVOICE_DATE;
          ptc_tbl(indx).amount               := ext_bill_tbl(indx).AMOUNT;
          ptc_tbl(indx).org_id               := ext_bill_tbl(indx).ORG_ID;
          ptc_tbl(indx).JURSDCTN_TYPE        := ext_bill_tbl(indx).JURSDCTN_TYPE;
          ptc_tbl(indx).JURSDCTN_NAME        := ext_bill_tbl(indx).JURSDCTN_NAME;
          ptc_tbl(indx).MLRT_TAX             := ext_bill_tbl(indx).MLRT_TAX;
          ptc_tbl(indx).TAX_VENDOR_ID        := ext_bill_tbl(indx).TAX_VENDOR_ID;
          ptc_tbl(indx).TAX_VENDOR_NAME      := ext_bill_tbl(indx).TAX_VENDOR_NAME;
          ptc_tbl(indx).TAX_VENDOR_SITE_ID   := ext_bill_tbl(indx).TAX_VENDOR_SITE_ID;
          ptc_tbl(indx).TAX_VENDOR_SITE_NAME := ext_bill_tbl(indx).TAX_VENDOR_SITE_NAME;
          ptc_tbl(indx).CREATED_BY           := l_last_updated_by;
          ptc_tbl(indx).CREATION_DATE        := SYSDATE;
          ptc_tbl(indx).LAST_UPDATED_BY      := l_last_updated_by;
          ptc_tbl(indx).LAST_UPDATE_DATE     := SYSDATE;
          ptc_tbl(indx).LAST_UPDATE_LOGIN    := l_last_update_login;
          ptc_tbl(indx).TAX_ASSESSMENT_DATE  := ext_bill_tbl(indx).TAX_ASSESSMENT_DATE; --vpanwar FPbug#5891876

          l_ptctl_cnt := ptctl_tbl.count;
          FOR l_lang_rec IN get_languages
          LOOP
            l_ptctl_cnt     := l_ptctl_cnt + 1;
            ptctl_tbl(l_ptctl_cnt).ID                := ptc_tbl(indx).id;
            ptctl_tbl(l_ptctl_cnt).LANGUAGE          := l_lang_rec.language_code;
            ptctl_tbl(l_ptctl_cnt).SOURCE_LANG       := USERENV('LANG');
            ptctl_tbl(l_ptctl_cnt).SFWT_FLAG         := 'N';
            ptctl_tbl(l_ptctl_cnt).CREATION_DATE     := SYSDATE;
            ptctl_tbl(l_ptctl_cnt).CREATED_BY        := l_last_updated_by;
            ptctl_tbl(l_ptctl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            ptctl_tbl(l_ptctl_cnt).LAST_UPDATED_BY   := l_last_updated_by;
            ptctl_tbl(l_ptctl_cnt).LAST_UPDATE_LOGIN := l_last_update_login;
          END LOOP;

          -- check for actual property tax stream type
          l_actual_tax_count := 0;
          OPEN  c_sty_count_csr ( ext_bill_tbl(indx).contract_id,
                                  ext_bill_tbl(indx).asset_id,
                                  ext_bill_tbl(indx).sty_id );
          FETCH c_sty_count_csr INTO l_actual_tax_count;
          CLOSE c_sty_count_csr;

          IF l_actual_tax_count > 0 THEN -- check for actual property tax stream
            NULL;
          ELSE -- check for actual property tax stream
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - create ACTUAL PROPERTY TAX stream.');
            END IF;
            -- -------------------------
            -- Null out records
            -- -------------------------
            l_stmtbl_cnt  := stm_tbl.count;
            l_stmtbl_cnt  := l_stmtbl_cnt + 1;
            l_stmv_rec    := l_init_stmv_rec;
            lx_stmv_rec   := l_init_stmv_rec;

            OPEN  c_tran_num_csr;
            FETCH c_tran_num_csr INTO stm_tbl(l_stmtbl_cnt).transaction_number;
            CLOSE c_tran_num_csr;

            stm_tbl(l_stmtbl_cnt).sty_id       := ext_bill_tbl(indx).sty_id;
            stm_tbl(l_stmtbl_cnt).khr_id       := ext_bill_tbl(indx).contract_id;
            stm_tbl(l_stmtbl_cnt).kle_id       := ext_bill_tbl(indx).asset_id;
            stm_tbl(l_stmtbl_cnt).sgn_code     := 'MANL';
            stm_tbl(l_stmtbl_cnt).say_code     := 'CURR';
            stm_tbl(l_stmtbl_cnt).active_yn    := 'Y';
            stm_tbl(l_stmtbl_cnt).date_current := sysdate;
            stm_tbl(l_stmtbl_cnt).comments     := 'ACTUAL PROPERTY TAX';

            -- other mandatory columns
            stm_tbl(l_stmtbl_cnt).id                     := Okc_P_Util.raw_to_number(sys_guid());
            stm_tbl(l_stmtbl_cnt).OBJECT_VERSION_NUMBER  := 1;
            stm_tbl(l_stmtbl_cnt).PROGRAM_ID             := l_program_id;
            stm_tbl(l_stmtbl_cnt).REQUEST_ID             := l_request_id;
            stm_tbl(l_stmtbl_cnt).PROGRAM_APPLICATION_ID := l_program_application_id;
            stm_tbl(l_stmtbl_cnt).PROGRAM_UPDATE_DATE    := sysdate;
            stm_tbl(l_stmtbl_cnt).CREATED_BY             := l_last_updated_by;
            stm_tbl(l_stmtbl_cnt).CREATION_DATE          := sysdate;
            stm_tbl(l_stmtbl_cnt).LAST_UPDATED_BY        := l_last_updated_by;
            stm_tbl(l_stmtbl_cnt).LAST_UPDATE_DATE       := sysdate;
            stm_tbl(l_stmtbl_cnt).LAST_UPDATE_LOGIN      := l_last_update_login;

            -- insert stm records
            if stm_tbl.count > 0 then
              forall i in stm_tbl.first..stm_tbl.last
                insert into okl_streams
                values stm_tbl(i);
              commit;
              stm_tbl.delete;
            end if;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - create ACTUAL PROPERTY TAX stream.');
            END IF;
          END IF; -- end check for actual property tax stream

          -- Create stream element actual property tax stream element
          -- Create Stream Element
          l_stm_id := NULL;
          OPEN  c_stm_id_csr ( ext_bill_tbl(indx).contract_id,
                               ext_bill_tbl(indx).asset_id,
                               ext_bill_tbl(indx).sty_id );
          FETCH c_stm_id_csr INTO l_stm_id;
          CLOSE c_stm_id_csr;

          -- --------------------------------
          -- fetch max se_line_number from
          -- sel table
          -- --------------------------------
          l_max_line_num := 0;
          OPEN  max_line_num_csr ( l_stm_id );
          FETCH max_line_num_csr INTO l_max_line_num;
          CLOSE max_line_num_csr;

          -- populate parent PK
          sel_tbl(indx).stm_id 				  := l_stm_id;

          -- --------------------------------
          -- To prevent constraint violation
          -- OKL_SEL_U2
          -- --------------------------------
          IF sel_tbl.exists(indx-1) then
            IF sel_tbl(indx-1).stm_id = l_stm_id then
              l_max_line_num := sel_tbl(indx-1).SE_LINE_NUMBER;
            END IF;
          END IF;

          sel_tbl(indx).SE_LINE_NUMBER      := NVL( l_max_line_num, 0 ) + 1;
          sel_tbl(indx).STREAM_ELEMENT_DATE := ext_bill_tbl(indx).INVOICE_DATE;
          sel_tbl(indx).AMOUNT              := ext_bill_tbl(indx).AMOUNT;
          sel_tbl(indx).COMMENTS            := 'ACTUAL PROPERTY TAX';
          sel_tbl(indx).SOURCE_ID			      := ptc_tbl(indx).id;
          sel_tbl(indx).SOURCE_TABLE			  := 'OKL_PROPERTY_TAX_V';
          -- Other columns
          sel_tbl(indx).id                  := Okc_P_Util.raw_to_number(sys_guid());
          -- save sel_id for update
          upd_sel_tbl(indx)                 := sel_tbl(indx).id;

          sel_tbl(indx).OBJECT_VERSION_NUMBER	  := 1;
          sel_tbl(indx).PROGRAM_ID              := l_program_id;
          sel_tbl(indx).REQUEST_ID              := l_request_id;
          sel_tbl(indx).PROGRAM_APPLICATION_ID  := l_program_application_id;
          sel_tbl(indx).PROGRAM_UPDATE_DATE     := sysdate;
          sel_tbl(indx).CREATED_BY              := l_last_updated_by;
          sel_tbl(indx).CREATION_DATE           := sysdate;
          sel_tbl(indx).LAST_UPDATED_BY         := l_last_updated_by;
          sel_tbl(indx).LAST_UPDATE_DATE        := sysdate;
          sel_tbl(indx).LAST_UPDATE_LOGIN       := l_last_update_login;

          -- end creation of actual property tax stream element
        END LOOP; -- end processing ext table records

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - populate property tax parameters record, stm rec and sel rec.');
        END IF;

        -- insert records into okl_property_tax_b
        if ptc_tbl.count > 0 then
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - create ptc_b rec.');
          END IF;
          forall i in ptc_tbl.first..ptc_tbl.last
            insert into okl_property_tax_b
            values ptc_tbl(i);
          COMMIT;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - create ptc_b rec.');
          END IF;
        END IF;

        -- insert records into okl_property_tax_tl
        if ptctl_tbl.count > 0 then
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - create ptc_tl rec.');
          END IF;
          FORALL i in ptctl_tbl.first..ptctl_tbl.last
            INSERT INTO okl_property_tax_tl
            VALUES ptctl_tbl(i);
          COMMIT;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - create ptc_tl rec.');
          END IF;
        END IF;

        -- update okl_ext_billing_interface with sel_id
        IF upd_rowid_tbl.count > 0 then
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - update ext billing interface with sel_id.');
          END IF;
          FORALL i in upd_rowid_tbl.first..upd_rowid_tbl.last
            UPDATE okl_ext_billing_interface
              SET sel_id = upd_sel_tbl(i)
            WHERE rowid = upd_rowid_tbl(i);
          COMMIT;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - update ext billing interface with sel_id.');
          END IF;
        END IF;

        -- insert sel records
        IF sel_tbl.count > 0 THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - create actual property tax stream elements.');
          END IF;
          forall i in sel_tbl.first..sel_tbl.last
            insert into okl_strm_elements
            values sel_tbl(i);
          COMMIT;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - create actual property tax stream elements.');
          END IF;
        END IF;

        -- create payable invoices
        IF ( l_p_tax_applicable = 'YES' ) THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - create payable invoice.');
          END IF;
          l_acc_cmt_cnt := 0;
          FOR indx in ext_bill_tbl.first..ext_bill_tbl.last
          LOOP
            l_acc_cmt_cnt := l_acc_cmt_cnt + 1;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Creating Payable Invoice to Tax Authority');
            END IF;
            p_man_inv_rec.ipvs_id          := ext_bill_tbl(indx).TAX_VENDOR_SITE_ID;
            p_man_inv_rec.khr_id           := ext_bill_tbl(indx).contract_id;
            p_man_inv_rec.vendor_id        := ext_bill_tbl(indx).TAX_VENDOR_ID;
            p_man_inv_rec.invoice_date     := ext_bill_tbl(indx).INVOICE_DATE;
            p_man_inv_rec.amount           := ext_bill_tbl(indx).AMOUNT;
            p_man_inv_rec.sty_id           := ext_bill_tbl(indx).sty_id;
            p_man_inv_rec.sel_id           := upd_sel_tbl(indx);
            -- for LE Uptake project 08-11-2006
            l_legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(ext_bill_tbl(indx).contract_id);
            IF l_legal_entity_id IS NOT NULL THEN
              p_man_inv_rec.legal_entity_id  :=  l_legal_entity_id;
            END IF;
            -- for LE Uptake project 08-11-2006

            OKL_PAY_INVOICES_MAN_PUB.manual_entry(
                p_api_version
               ,p_init_msg_list
               ,x_return_status
               ,x_msg_count
               ,x_msg_data
               ,p_man_inv_rec
               ,x_man_inv_rec);

            -- ---------------------------------------
            -- Create a payable Invoice
            -- ---------------------------------------
            IF x_return_status <> 'S' THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- ERROR: Creating Payable Invoice');
              END IF;
		          UPDATE OKL_EXT_BILLING_INTERFACE
		            SET trx_status_code = 'ERROR',
		   	            ERROR_MESSAGE   = ERROR_MESSAGE||'Error Creating Payable Invoice. '
  		        WHERE rowid = ext_bill_tbl(indx).ext_rowid;
              -- ------------------------------
              -- delete orphan record in PTC for
              -- referential integrity
              -- ------------------------------
              delete from OKL_PROPERTY_TAX_tl where id = ptc_tbl(indx).id;
              delete from OKL_PROPERTY_TAX_b  where id = ptc_tbl(indx).id;
              delete from okl_strm_elements where id = upd_sel_tbl(indx);
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Deleting records from OKL_PROPERTY_TAX_tl and OKL_PROPERTY_TAX_b.');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Deleting record from OKL_STRM_ELEMENTS.');
              END IF;
            END IF;

            IF l_acc_cmt_cnt > 500 THEN
              COMMIT;
              l_acc_cmt_cnt := 0;
            END IF;
          END LOOP;
          COMMIT;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - create payable invoice.');
          END IF;
        END IF;
        -- end creation of payable invoices

        -- Update records in the interface to PROCESSED status
        if upd_rowid_tbl.count > 0 then
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    ++ begin - update status on okl_ext_billing_interface for successful records .');
          END IF;
          forall j in upd_rowid_tbl.first..upd_rowid_tbl.last
            update okl_ext_billing_interface
              set trx_status_code = decode(trx_status_code,'PASSED','PROCESSED',trx_status_code)
            where rowid = upd_rowid_tbl(j);
          COMMIT;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    -- end - update status on okl_ext_billing_interface for successful records .');
          END IF;
        END IF;

        -- Start Bug 4520466
        for indx in ext_bill_tbl.first..ext_bill_tbl.last loop
          OKL_BILLING_CONTROLLER_PVT.track_next_bill_date( ext_bill_tbl(indx).contract_id );
        end loop;
        -- End Bug 4520466
      END IF; -- check if ext_bill_tbl has records

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-- end - processing actual property tax records batch number: '||g_batch_num);
      END IF;
      EXIT WHEN act_prop_tax_csr%NOTFOUND;
    END LOOP; -- process transaction records

    -- -----------------------------
    -- Print processing summary
    -- -----------------------------
    -- Success Count for actual property tax
    l_succ_apt_cnt := NULL;
    OPEN   ext_apt_stat_csr( l_request_id, 'PROCESSED', 'ACTUAL_PROPERTY_TAX'  );
    FETCH  ext_apt_stat_csr INTO l_succ_apt_cnt;
    CLOSE  ext_apt_stat_csr;

    -- Error Count for actual property tax
    l_err_apt_cnt := NULL;
    OPEN   ext_apt_stat_csr( l_request_id, 'ERROR', 'ACTUAL_PROPERTY_TAX'  );
    FETCH  ext_apt_stat_csr INTO l_err_apt_cnt;
    CLOSE  ext_apt_stat_csr;

    -- Success Count for NON-actual property tax
    l_succ_non_apt_cnt := NULL;
    OPEN   ext_non_apt_stat_csr( l_request_id, 'PROCESSED', 'ACTUAL_PROPERTY_TAX'  );
    FETCH  ext_non_apt_stat_csr INTO l_succ_non_apt_cnt;
    CLOSE  ext_non_apt_stat_csr;

    -- Error Count for NON-actual property tax
    l_err_non_apt_cnt := NULL;
    OPEN   ext_non_apt_stat_csr( l_request_id, 'ERROR', 'ACTUAL_PROPERTY_TAX'  );
    FETCH  ext_non_apt_stat_csr INTO l_err_non_apt_cnt;
    CLOSE  ext_non_apt_stat_csr;

    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    -- Start New Out File stmathew
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'Oracle Lease and Finance Management'||LPAD(' ', 55, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 53, ' ')||'Third Party Billing Import'||LPAD(' ', 53, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'------------------------'||LPAD(' ', 54, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Operating Unit: '||l_op_unit_name);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Request Id: '||l_request_id||LPAD(' ',74,' ') ||'Run Date: '||TO_CHAR(SYSDATE));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Currency: '||Okl_Accounting_Util.get_func_curr_code);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Processing Details:'||LPAD(' ', 113, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '      Number of Successful Actual Property Tax records: '||l_succ_apt_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '      Number of Errored Actual Property Tax records: '||l_err_apt_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '      Number of Successful Non-Actual Property Tax records: '||l_succ_non_apt_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '      Number of Errored Non-Actual Property Tax records: '||l_err_non_apt_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '      Total records processed: '||g_total_rec_count);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));

    -- End New Out File stmathew
    IF x_msg_count > 0 THEN
      FOR i IN 1..x_msg_count LOOP
            IF i = 1 THEN
                Fnd_File.PUT_LINE (Fnd_File.log,'Details of TAPI errors:'||LPAD(' ', 97, ' '));
                Fnd_File.PUT_LINE (Fnd_File.log,RPAD(' ', 132, ' '));
            END IF;
            Fnd_Msg_Pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);
            Fnd_File.PUT_LINE (Fnd_File.log,TO_CHAR(i) || ': ' || lx_msg_data);
      END LOOP;
    END IF;

    -- ---------------------------------------------------------
    -- print all error messages from okl_ext_billing_interface
    -- ---------------------------------------------------------
    Fnd_File.PUT_LINE (Fnd_File.log,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.log,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.log,'Contract Number'||LPAD(' ', 16, ' ')
                                  ||'Asset Number'||LPAD(' ', 19, ' ')
                                  ||'Stream Name'||LPAD(' ', 20, ' ')
                                  ||'Invoice Date'||' Error Message');
    Fnd_File.PUT_LINE (Fnd_File.log,'---------------'||LPAD(' ', 16, ' ')
                                  ||'------------'||LPAD(' ', 19, ' ')
                                  ||'-----------'||LPAD(' ', 20, ' ')
                                  ||'------------'||' -------------');

    FOR error_msg_rec in error_msg_csr( l_request_id, 'ERROR' )
    LOOP
      Fnd_File.PUT_LINE (Fnd_File.log,error_msg_rec.contract_number||' '
                                  ||error_msg_rec.asset_number||' '
                                  ||error_msg_rec.sty_name||' '
                                  ||error_msg_rec.invoice_date||'   '
                                  ||error_msg_rec.error_message);
    END LOOP;
    Fnd_File.PUT_LINE (Fnd_File.log,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.log,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.log,RPAD(' ', 132, ' '));
    -- -------------------------------
    -- End Print processing Summary
    -- -------------------------------

    FND_FILE.PUT_LINE (FND_FILE.log, '================================================================');
    FND_FILE.PUT_LINE (FND_FILE.log, '    *** END PROCESSING THIRD PARTY BILLING RECORDS ***');
    FND_FILE.PUT_LINE (FND_FILE.log, '================================================================');

    ------------------------------------------------------------
    -- End processing
    ------------------------------------------------------------
    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End (-)');
      END IF;
    END IF;

    Okl_Api.END_ACTIVITY (
      x_msg_count	=> x_msg_count,
      x_msg_data	=> x_msg_data);
  EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>ERROR: '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>ERROR: '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>ERROR: '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
  END BILLING_CHARGES;

END OKL_EXT_BILLING_CHARGES_PVT;

/
