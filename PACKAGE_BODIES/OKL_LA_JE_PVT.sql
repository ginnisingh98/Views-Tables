--------------------------------------------------------
--  DDL for Package Body OKL_LA_JE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_JE_PVT" as
/* $Header: OKLRJNLB.pls 120.10.12010000.4 2008/09/10 17:54:03 rkuttiya ship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_FND_APP		        CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PVT';

 --Bug# 5964482
  G_MODULE VARCHAR2(255) := 'okl.lla.okl_la_je_pvt';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON BOOLEAN ;
 --Bug# 5964482

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------

  Function is_release_contract( p_contract_id NUMBER ) return varchar2 is

      l_is_release_contract VARCHAR2(1) := 'N';

      --cursor to check if contract is a re-lease contract
      CURSOR l_chk_rel_khr_csr (p_chr_id IN Number) IS
      SELECT 'Y'
      FROM   okc_k_headers_b CHR
      where  chr.ID = p_chr_id
      AND    nvl(chr.orig_system_source_code,'XXXX') = 'OKL_RELEASE';

      l_rel_khr    VARCHAR2(1) DEFAULT 'N';


      --cursor to check if contract has re-lease assets
      CURSOR l_chk_rel_ast_csr (p_chr_id IN Number) IS
      SELECT 'Y'
      FROM   okc_k_headers_b CHR
      WHERE   nvl(chr.orig_system_source_code,'XXXX') <> 'OKL_RELEASE'
      and     chr.ID = p_chr_id
      AND     exists (SELECT '1'
                     FROM   OKC_RULES_B rul
                     WHERE  rul.dnz_chr_id = chr.id
                     AND    rul.rule_information_category = 'LARLES'
                     AND    nvl(rule_information1,'N') = 'Y');

      l_rel_ast     VARCHAR2(1) DEFAULT 'N';

  Begin

      OPEN  l_chk_rel_khr_csr( p_contract_id );
      FETCH l_chk_rel_khr_csr INTO l_rel_khr;
      CLOSE l_chk_rel_khr_csr;

      If ( nvl(l_rel_khr,'N') = 'Y' ) Then
          l_is_release_contract := 'Y';
      End If;

      OPEN l_chk_rel_ast_csr( p_contract_id );
      FETCH l_chk_rel_ast_csr INTO l_rel_ast;
      CLOSE l_chk_rel_ast_csr;

      If ( nvl(l_rel_ast,'N') = 'Y' ) Then
          l_is_release_contract := 'Y';
      End If;

      return l_is_release_contract;

  end is_release_contract;

  -- in the following signature x_trxH_rec is
  -- introduced as part of Sales Tax Project to return transaction record
  Procedure generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_date IN  DATE,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn          IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2,
                      x_trxH_rec         OUT NOCOPY tcnv_rec_type)  IS


     -- Define PL/SQL Records and Tables
    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_in_rec        Okl_Trx_Contracts_Pvt.tclv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_out_rec       Okl_Trx_Contracts_Pvt.tclv_rec_type;

    -- Define variables
    l_sysdate         DATE;
    l_sysdate_trunc   DATE;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_post_to_gl_yn   VARCHAR2(1);

    i                 NUMBER;
    l_amount          NUMBER;
    l_init_msg_list   VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_currency_code   okl_txl_cntrct_lns.currency_code%TYPE;
    l_fnd_profile     VARCHAR2(256);
    l_cust_trx_type_id NUMBER;

            l_msg_index_out   NUMBER; --TBR

     -- Define constants
    l_api_name        CONSTANT VARCHAR(30) := 'GENERATE_JOURNAL_ENTRIES';
    l_api_version     CONSTANT NUMBER      := 1.0;

    Cursor fnd_pro_csr IS
    select mo_global.get_current_org_id() l_fnd_profile
    from dual;
    fnd_pro_rec fnd_pro_csr%ROWTYPE;

    Cursor ra_cust_csr IS
    select cust_trx_type_id l_cust_trx_type_id
    from ra_cust_trx_types
    where name = 'Invoice-OKL';
    ra_cust_rec ra_cust_csr%ROWTYPE;

    Cursor salesP_csr( chrId NUMBER) IS
    select ct.object1_id1 id
    from   okc_contacts        ct,
           okc_contact_sources csrc,
           okc_k_party_roles_b pty,
           okc_k_headers_b     chr
    where  ct.cpl_id               = pty.id
          and    ct.cro_code             = csrc.cro_code
          and    ct.jtot_object1_code    = csrc.jtot_object_code
          and    ct.dnz_chr_id           =  chr.id
          and    pty.rle_code            = csrc.rle_code
          and    csrc.cro_code           = 'SALESPERSON'
          and    csrc.rle_code           = 'LESSOR'
          and    csrc.buy_or_sell        = chr.buy_or_sell
          and    pty.dnz_chr_id          = chr.id
          and    pty.chr_id              = chr.id
          and    chr.id                  = chrId;

    l_salesP_rec salesP_csr%ROWTYPE;

    Cursor custBillTo_csr( chrId NUMBER) IS
    select bill_to_site_use_id cust_acct_site_id
    from   okc_k_headers_b
    where  id = chrId;

/* Rule migration - BTO

    Cursor custBillTo_csr( chrId NUMBER) IS
    select object1_id1 cust_acct_site_id
    from okc_rules_b rul
    where  rul.rule_information_category = 'BTO'
         and exists (select '1'
                     from okc_rule_groups_b rgp
                     where rgp.id = rul.rgp_id
                          and   rgp.rgd_code = 'LABILL'
                          and   rgp.chr_id   = rul.dnz_chr_id
                          and   rgp.chr_id = chrId );
*/

    l_custBillTo_rec custBillTo_csr%ROWTYPE;

    CURSOR Product_csr (p_contract_id IN okl_products_v.id%TYPE) IS
    SELECT khr.pdt_id                    product_id
          ,NULL                          product_name
          ,khr.sts_code                 contract_status
          ,khr.start_date               start_date
          ,khr.currency_code            currency_code
	  ,khr.authoring_org_id         authoring_org_id
	  ,khr.currency_conversion_rate currency_conversion_rate
	  ,khr.currency_conversion_type currency_conversion_type
	  ,khr.currency_conversion_date currency_conversion_date
          --Bug# 4622198
          ,khr.scs_code
          --Bug# 5964482: Accounting Engine CR
          --Bug# 6073872: DFF attributes are being taken from okc_k_headers instead of okl_k_headers
          ,khr.khr_attribute_category
          ,khr.khr_attribute1
          ,khr.khr_attribute2
          ,khr.khr_attribute3
          ,khr.khr_attribute4
          ,khr.khr_attribute5
          ,khr.khr_attribute6
          ,khr.khr_attribute7
          ,khr.khr_attribute8
          ,khr.khr_attribute9
          ,khr.khr_attribute10
          ,khr.khr_attribute11
          ,khr.khr_attribute12
          ,khr.khr_attribute13
          ,khr.khr_attribute14
          ,khr.khr_attribute15
    FROM  okl_k_headers_full_v  khr
    WHERE khr.id = p_contract_id;

    l_func_curr_code OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    l_chr_curr_code  OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
    x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
    x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

    CURSOR Transaction_Type_csr (p_transaction_type IN okl_trx_types_v.name%TYPE ) IS
    SELECT id       trx_try_id
    FROM  okl_trx_types_tl
    WHERE  name = p_transaction_type
         AND language = 'US';

    CURSOR fnd_lookups_csr( lkp_type VARCHAR2, mng VARCHAR2 ) IS
    select description,
           lookup_code
    from   fnd_lookup_values
    where language = 'US'
         AND lookup_type = lkp_type
         AND meaning = mng;

    Cursor trx_csr( khrId NUMBER, tcntype VARCHAR2 ) is
    Select txh.ID HeaderTransID,
           txh.date_transaction_occurred date_transaction_occurred,
           txh.tsu_code
    From okl_trx_contracts txh
    Where txh.tcn_type = tcntype
         and txh.khr_id = khrId
    --rkuttiya added for 12.1.1 Multi GAAP
    and txh.representation_type = 'PRIMARY';
    --

    -- Cursor Types
    l_Product_rec      Product_csr%ROWTYPE;
    l_Trx_Type_rec     Transaction_Type_csr%ROWTYPE;
    l_fnd_rec          fnd_lookups_csr%ROWTYPE;
    l_fnd_rec1         fnd_lookups_csr%ROWTYPE;
    l_trx_rec          trx_csr%ROWTYPE;


    l_isJrnlGenAllowed BOOLEAN := TRUE;
    l_passStatus       VARCHAR2(256);
    l_failStatus       VARCHAR2(256);
    p_chr_id           VARCHAR2(2000) := TO_CHAR(p_contract_id);
    l_transaction_type VARCHAR2(256) := p_transaction_type;
    l_transaction_date DATE;


    l_tmpl_identify_rec  OKL_ACCOUNT_DIST_PVT.TMPL_IDENTIFY_REC_TYPE;
    l_dist_info_rec      OKL_ACCOUNT_DIST_PVT.dist_info_REC_TYPE;
    l_template_tbl       OKL_ACCOUNT_DIST_PVT.AVLV_TBL_TYPE;
    l_amount_tbl         OKL_ACCOUNT_DIST_PVT.AMOUNT_TBL_TYPE;
    l_ctxt_val_tbl       OKL_ACCOUNT_DIST_PVT.CTXT_VAL_TBL_TYPE;
    l_acc_gen_primary_key_tbl OKL_ACCOUNT_DIST_PVT.acc_gen_primary_key;
    l_has_trans          VARCHAR2(1);
    l_memo_yn            VARCHAR2(1);

    --Bug# 3153003
    l_upd_trxH_rec  Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    lx_upd_trxH_rec Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    --Bug# 3153003

    --Bug# 4622198
    l_fact_synd_code      FND_LOOKUPS.Lookup_code%TYPE;
    l_inv_acct_code       OKC_RULES_B.Rule_Information1%TYPE;
    --Bug# 4622198

    --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

  --Bug# 5964482
  l_trxl_del_tbl          Okl_trx_contracts_pvt.tclv_tbl_type;
  l_tclv_tbl              Okl_trx_contracts_pvt.tclv_tbl_type;
  x_tclv_tbl              Okl_trx_contracts_pvt.tclv_tbl_type;
  l_tcnv_rec              Okl_trx_contracts_pvt.tcnv_rec_type;
  x_tcnv_rec              Okl_trx_contracts_pvt.tcnv_rec_type;

  /* New Type Declarations*/
  l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
  l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
  l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
  l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
  l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
  l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;

  l_tcn_id                     NUMBER;
  l_tcl_type                   okl_trx_types_tl.name%TYPE;
  --Bug# 5964482 End

  BEGIN

    --Bug# 5964482
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    --Bug# 5964482 End

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate        := SYSDATE;
    l_sysdate_trunc  := trunc(SYSDATE);
    i                := 0;


    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    --Bug# 5964482 : Disable draft Accounting
    If (p_draft_yn = OKL_API.G_TRUE) Then
        Null; -- do not do anything
    ELSE --do normal accounting

    -- Get product_id
    OPEN  Product_csr(p_contract_id);
    FETCH Product_csr INTO l_Product_rec;
    IF Product_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'Product');
      CLOSE Product_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE Product_csr;

    If ( p_transaction_date IS NULL ) Then
        l_transaction_date  := l_Product_rec.start_date;
    Else
        l_transaction_date  := p_transaction_date;
    End If;

    l_chr_curr_code  := l_Product_rec.CURRENCY_CODE;
    l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_Product_rec.authoring_org_id);

    x_currency_conversion_rate := NULL;
    x_currency_conversion_type := NULL;
    x_currency_conversion_date := NULL;

    If ( ( l_func_curr_code IS NOT NULL) AND
         ( l_chr_curr_code <> l_func_curr_code ) ) Then

        x_currency_conversion_type := l_Product_rec.currency_conversion_type;
        x_currency_conversion_date := l_Product_rec.start_date;

        If ( l_Product_rec.currency_conversion_type = 'User') Then
            x_currency_conversion_rate := l_Product_rec.currency_conversion_rate;
            x_currency_conversion_date := l_Product_rec.currency_conversion_date;
	Else
            x_currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
	                                       p_from_curr_code => l_chr_curr_code,
	                                       p_to_curr_code   => l_func_curr_code,
					       p_con_date       => l_Product_rec.start_date,
					       p_con_type       => l_Product_rec.currency_conversion_type);

	End If;

    End If;

    IF ((p_draft_yn = OKL_API.G_TRUE) AND (l_Product_rec.contract_status <> 'BOOKED')) Then
        /*--Bug# 5964482 Commenting the code as Draft Accounting is being disabled
        okl_contract_status_pub.get_contract_status(l_api_version,
                                                p_init_msg_list,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data,
                                                l_isJrnlGenAllowed,
                                                l_passStatus,
                                                l_failStatus,
                                                OKL_CONTRACT_STATUS_PUB.G_K_JOURNAL,
                                                p_chr_id);


        If ( l_isJrnlGenAllowed = FALSE )  then
            x_return_status := OKL_API.G_RET_STS_ERROR;
            okl_api.set_message(
               p_app_name => G_APP_NAME,
               p_msg_name => OKL_CONTRACT_STATUS_PUB.G_CANNOT_GENJRNL);
            raise OKL_API.G_EXCEPTION_ERROR;
        ElsIf (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
        End If;
        -----Bug# 5964482 End of comments - Draft Accounting Disabled*/
        Null;

    End If;

    -- Validate passed parameters
    IF   ( p_contract_id = Okl_Api.G_MISS_NUM       )
      OR ( p_contract_id IS NULL                    ) THEN
        Okl_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'contract');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Bug 5909373
    /*
    If ( is_release_contract( p_contract_id ) = 'Y' ) Then
	    l_transaction_type := 'Release';
    End If;*/
    --Bug 5909373

    IF   ( l_transaction_type = Okl_Api.G_MISS_CHAR )
      OR ( l_transaction_type IS NULL               ) THEN
        Okl_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- set POST_TO_GL and MEMO_YN flag always to YES !!!!
    l_memo_yn := OKL_API.G_MISS_CHAR;
    IF (p_draft_yn = OKL_API.G_TRUE) THEN
       --Bug# 5964482 : Disable Draft Accounting
       --l_post_to_gl_yn := 'N';
       --l_memo_yn       := 'Y';
       Null;
       --Bug# 5964482 End
    ELSE
       l_post_to_gl_yn := 'Y';
    END IF;

    l_currency_code  := l_Product_rec.currency_code;

    -- Check Transaction_Type
    OPEN  Transaction_Type_csr(l_transaction_type);
    FETCH Transaction_Type_csr INTO l_Trx_Type_rec;
    IF Transaction_Type_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
      CLOSE Transaction_Type_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE Transaction_Type_csr;

    OPEN  fnd_lookups_csr('OKL_TCN_TYPE', l_transaction_type);
    FETCH fnd_lookups_csr INTO l_fnd_rec;
    IF fnd_lookups_csr%NOTFOUND THEN
      CLOSE fnd_lookups_csr;
      OPEN  fnd_lookups_csr('OKL_TCN_TYPE', 'Miscellaneous');
      FETCH fnd_lookups_csr INTO l_fnd_rec;
      IF fnd_lookups_csr%NOTFOUND THEN
          Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
          CLOSE fnd_lookups_csr;
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      End If;
    END IF;
    CLOSE fnd_lookups_csr;

    OPEN  trx_csr(p_contract_id,l_fnd_rec.lookup_code);
    FETCH trx_csr INTO l_trx_rec;
    IF (l_fnd_rec.lookup_code = 'TRBK') THEN -- For Rebook, create a new trans always
        l_has_trans := OKL_API.G_FALSE;
    ELSIF (trx_csr%FOUND AND l_trx_rec.tsu_code = 'ENTERED') THEN -- Otherwise use existing transaction, if it is in Entered status
        l_has_trans := OKL_API.G_TRUE;
    ELSE
        l_has_trans := OKL_API.G_FALSE; -- In all other cases, create a new trans
    END IF;
    CLOSE trx_csr;

    l_trxH_in_rec.khr_id         := p_contract_id;
    l_trxH_in_rec.pdt_id         := l_Product_rec.product_id;
    l_trxH_in_rec.tcn_type       := l_fnd_rec.lookup_code; --'BKG'/'SYND'/'TRBK';
    l_trxH_in_rec.currency_code  := l_currency_code;
    l_trxH_in_rec.try_id         := l_Trx_Type_rec.trx_try_id;

    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxH_in_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_contract_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    If ( p_draft_yn = OKL_API.G_TRUE ) Then
       --Bug# 5964482 : Disable draft Accounting
        Null;
        --l_trxH_in_rec.description   := 'Draft Journals - ' || l_transaction_type;
    Else
        l_trxH_in_rec.description   := 'Journals - ' || l_transaction_type;
    End If;

    l_trxH_in_rec.currency_conversion_rate := x_currency_conversion_rate;
    l_trxH_in_rec.currency_conversion_type := x_currency_conversion_type;
    l_trxH_in_rec.currency_conversion_date := x_currency_conversion_date;

    --Bug# 5964482 : code for l_trxL_in_rec not changed here
    -- But, l_trxL_in_rec will not be used because of
    -- changes for accounting CR.
    l_trxL_in_rec.khr_id        := p_contract_id;
    l_trxL_in_rec.line_number   := 1;
    l_trxL_in_rec.currency_code   := l_currency_code;
    If ( p_draft_yn = OKL_API.G_TRUE ) Then
        -- Bug# 5964482 : Disable draft accounting
        Null;
        --l_trxL_in_rec.description   := 'Draft Journals - ' || l_transaction_type;
    Else
        l_trxL_in_rec.description   := 'Journals - ' || l_transaction_type;
    End If;

    --Bug# 5964482
    If (l_transaction_type = 'Rebook') then
        l_tcl_type := 'Rebooking';
    Else
        l_tcl_type := l_transaction_type;
    End If;
    --Bug# 5964482

    --OPEN  fnd_lookups_csr('OKL_TCL_TYPE', l_transaction_type);
    OPEN  fnd_lookups_csr('OKL_TCL_TYPE', l_tcl_type);
    FETCH fnd_lookups_csr INTO l_fnd_rec1;
    IF fnd_lookups_csr%NOTFOUND THEN
      l_trxL_in_rec.tcl_type      := 'MAE';
    Else
      l_trxL_in_rec.tcl_type      := l_fnd_rec1.lookup_code;
    END IF;
    CLOSE fnd_lookups_csr;

    If ( l_has_trans = OKL_API.G_FALSE ) Then

        If (UPPER(l_fnd_rec.lookup_code) = 'TRBK') THEN
           l_trxH_in_rec.rbr_code       := ''; -- lokup 'OKL_REBOOK_REASON'
           l_trxH_in_rec.rpy_code       := ''; -- lokup 'OKL_REBOOK_PROCESS_TYPE'
        End If;

        OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Submitted');
        FETCH fnd_lookups_csr INTO l_fnd_rec;
        IF fnd_lookups_csr%NOTFOUND THEN
          Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
          CLOSE fnd_lookups_csr;
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        CLOSE fnd_lookups_csr;

        l_trxH_in_rec.tsu_code       := l_fnd_rec.lookup_code;

        l_trxH_in_rec.date_transaction_occurred  := l_transaction_date;
        l_trxH_in_rec.description    := l_fnd_rec.description;
        --Bug# 5964482 : Accounting engine CR for uniform accounting call
        --Bug# 6073872: DFF attributes to be taken from okl_k_headers
        l_trxH_in_rec.attribute_category := l_product_rec.khr_attribute_category;
        l_trxH_in_rec.attribute1         := l_product_rec.khr_attribute1;
        l_trxH_in_rec.attribute2         := l_product_rec.khr_attribute2;
        l_trxH_in_rec.attribute3         := l_product_rec.khr_attribute3;
        l_trxH_in_rec.attribute4         := l_product_rec.khr_attribute4;
        l_trxH_in_rec.attribute5         := l_product_rec.khr_attribute5;
        l_trxH_in_rec.attribute6         := l_product_rec.khr_attribute6;
        l_trxH_in_rec.attribute7         := l_product_rec.khr_attribute7;
        l_trxH_in_rec.attribute8         := l_product_rec.khr_attribute8;
        l_trxH_in_rec.attribute9         := l_product_rec.khr_attribute9;
        l_trxH_in_rec.attribute10        := l_product_rec.khr_attribute10;
        l_trxH_in_rec.attribute11        := l_product_rec.khr_attribute11;
        l_trxH_in_rec.attribute12        := l_product_rec.khr_attribute12;
        l_trxH_in_rec.attribute13        := l_product_rec.khr_attribute13;
        l_trxH_in_rec.attribute14        := l_product_rec.khr_attribute14;
        l_trxH_in_rec.attribute15        := l_product_rec.khr_attribute15;
        --Bug# 5964482 : End

    -- Create Transaction Header, Lines
        Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF ((l_trxH_out_rec.id = OKL_API.G_MISS_NUM) OR
            (l_trxH_out_rec.id IS NULL) ) THEN
            OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- populate the output transaction record
        x_trxH_rec := l_trxH_out_rec;

        l_fnd_rec := null;

      /*--------------Bug# 5964482 : Commenting creation of transaction lines
       -- as transaction lines will be created based on unified accounting call
        -- Create Transaction Line
        --l_trxL_in_rec.tcn_id        := l_trxH_out_rec.id;

    -- Create Transaction Header, Lines
        --Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
             --p_api_version      => l_api_version
            --,p_init_msg_list    => l_init_msg_list
            --,x_return_status    => x_return_status
            --,x_msg_count        => l_msg_count
            --,x_msg_data         => l_msg_data
            --,p_tclv_rec         => l_trxL_in_rec
            --,x_tclv_rec         => l_trxL_out_rec);

        --IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        --    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        --ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        --    RAISE Okl_Api.G_EXCEPTION_ERROR;
        --END IF;
        --IF ((l_trxL_out_rec.id = OKL_API.G_MISS_NUM) OR
        --    (l_trxL_out_rec.id IS NULL) ) THEN
        --    OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
        --    RAISE OKL_API.G_EXCEPTION_ERROR;
        --END IF;

        --l_dist_info_rec.SOURCE_ID := l_trxL_out_rec.id;
        --l_dist_info_rec.ACCOUNTING_DATE := l_trxH_out_rec.date_transaction_occurred;
      -------------Bug# 5964482 - End of Comments -------------------------*/
    ELSE

        ------------------
        --Bug# : 3153003
        -----------------
        --if transaction exists change the date transaction occured
        l_upd_trxH_rec.id                       := l_trx_rec.HeaderTransID;
        l_upd_trxH_rec.date_transaction_occurred := l_transaction_date;
        Okl_Trx_Contracts_Pub.update_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_upd_trxH_rec
            ,x_tcnv_rec         => lx_upd_trxH_rec);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF ((lx_upd_trxH_rec.id = OKL_API.G_MISS_NUM) OR
            (lx_upd_trxH_rec.id IS NULL) ) THEN
            OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- populate the output transaction record
        x_trxH_rec := lx_upd_trxH_rec;
        l_trxH_out_rec := lx_upd_trxH_rec;


        --Bug# 5964482 : Coomented for Accounting engine CR
        --l_dist_info_rec.SOURCE_ID := l_trx_rec.LineTransId;
        --l_dist_info_rec.ACCOUNTING_DATE := l_trx_rec.date_transaction_occurred;
        --l_dist_info_rec.ACCOUNTING_DATE := lx_upd_trxH_rec.date_transaction_occurred;
        --Bug# 5964482 : End of Comments

        -----------------------
        --Bug# : 3153003
        -----------------------

        ----------------------
        --Bug# 5964482
        -----------------------
        --delete existing lines
        -- Commented out code to delete_trx_cntrct_lines since draft journal entry is always FALSE
        /*l_trxl_del_tbl.delete;
        For l_trx_rec in trx_csr(p_contract_id,l_fnd_rec.lookup_code)
        Loop
            l_trxl_del_tbl(i).id := l_trx_rec.linetransid;
        End Loop;

       okl_trx_contracts_pub.delete_trx_cntrct_lines(
                             p_api_version             => l_api_version,
                             p_init_msg_list           => l_init_msg_list,
                             x_return_status           => x_return_status,
                             x_msg_count               => l_msg_count,
                             x_msg_data                => l_msg_data,
                             p_tclv_tbl                => l_trxl_del_tbl);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        --End delete existing lines
        ---------------------------
        --End Bug# 5964482
        ---------------------------*/

    END IF;

    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := l_Trx_Type_rec.trx_try_id;
    l_tmpl_identify_rec.PRODUCT_ID := l_Product_rec.product_id;
    l_tmpl_identify_rec.memo_yn := l_memo_yn;

    --Bug# 4622198 :For special accounting treatment
    OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
                                  p_api_version             => p_api_version,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_khr_id                  => p_chr_id,
                                  p_scs_code                => l_product_rec.scs_code,
                                  p_trx_date                => l_transaction_date,
                                  x_fact_synd_code          => l_fact_synd_code,
                                  x_inv_acct_code           => l_inv_acct_code
                                  );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_tmpl_identify_rec.factoring_synd_flag := l_fact_synd_code;
    l_tmpl_identify_rec.investor_code       := l_inv_acct_code;
    --Bug# 4622198

    -----------------
    --Bug 5964482 : Accounting CR - get template information and build template line records
    -------------------
    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Call to OKL_ACCOUNT_DIST_PUB.GET_TEMPLATE_INFO : '||x_return_status);
    END IF;
    --Call to get_template_info to determine the number of transaction lines to be created
    Okl_Account_Dist_Pub.GET_TEMPLATE_INFO(p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_tmpl_identify_rec  => l_tmpl_identify_rec,
                      x_template_tbl       => l_template_tbl,
                      p_validity_date      => l_trxH_out_rec.date_transaction_occurred);
         IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Call to OKL_ACCOUNT_DIST_PUB.GET_TEMPLATE_INFO : '||x_return_status);
         END IF;
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         -- gboomina Bug 6151201 - Start
         -- check whether templates present or not. If not throw error.
         IF l_template_tbl.COUNT = 0 THEN
          	Okl_Api.set_message(p_app_name       => g_app_name,
                               p_msg_name       => 'OKL_LA_NO_ACCOUNTING_TMPLTS',
                               p_token1         => 'TRANSACTION_TYPE',
                               p_token1_value   => l_transaction_type);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         -- gboomina Bug 6151201 - End

     --Build the transaction line table of records
     FOR i IN l_template_tbl.FIRST..l_template_tbl.LAST
     LOOP
             l_tclv_tbl(i).line_number := i;
             l_tclv_tbl(i).khr_id := p_contract_id;
             l_tclv_tbl(i).sty_id := l_template_tbl(i).sty_id;
             l_tclv_tbl(i).tcl_type := l_trxl_in_rec.tcl_type;
             If ( p_draft_yn = OKL_API.G_TRUE ) Then
                 --Bug# 5964482 : disbale draft accounting
                 Null;
                 --l_tclv_tbl(i).description   := 'Draft Journals - ' || l_transaction_type;
             Else
                 l_tclv_tbl(i).description   := 'Journals - ' || l_transaction_type;
             End If;
             l_tclv_tbl(i).tcn_id := l_trxh_out_rec.id;
             l_tclv_tbl(i).currency_code := l_currency_code;
      END LOOP;


     --Call to create transaction lines
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before  OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines :'|| x_return_status);
     END IF;
     Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tclv_tbl         => l_tclv_tbl
            ,x_tclv_tbl         => x_tclv_tbl);
         IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before  OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines :'|| x_return_status);
         END IF;
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    /* Populating the tmpl_identify_tbl  from the template_tbl returned by get_template_info*/

    FOR i in l_template_tbl.FIRST.. l_template_tbl.LAST
    LOOP
        l_tmpl_identify_tbl(i).product_id          := l_Product_rec.product_id;
        l_tmpl_identify_tbl(i).transaction_type_id := l_Trx_Type_rec.trx_try_id;
        l_tmpl_identify_tbl(i).stream_type_id      := l_template_tbl(i).sty_id;
        l_tmpl_identify_tbl(i).advance_arrears     := l_template_tbl(i).advance_arrears;
        l_tmpl_identify_tbl(i).prior_year_yn       := l_template_tbl(i).prior_year_yn;
        l_tmpl_identify_tbl(i).memo_yn             := l_template_tbl(i).memo_yn;
        l_tmpl_identify_tbl(i).factoring_synd_flag := l_template_tbl(i).factoring_synd_flag;
        l_tmpl_identify_tbl(i).investor_code       := l_template_tbl(i).inv_code;
        l_tmpl_identify_tbl(i).SYNDICATION_CODE    := l_template_tbl(i).syt_code;
        l_tmpl_identify_tbl(i).FACTORING_CODE      := l_template_tbl(i).fac_code;
    END LOOP;
    --Bug# 5964482 END

    /* -- Bug# 5964482 - code commented
    --l_dist_info_rec.SOURCE_TABLE := 'OKL_TXL_CNTRCT_LNS';
    --l_dist_info_rec.GL_REVERSAL_FLAG := 'N';
    --l_dist_info_rec.POST_TO_GL := l_post_to_gl_yn;
    --l_dist_info_rec.CONTRACT_ID := p_contract_id;

    --l_dist_info_rec.currency_conversion_rate := x_currency_conversion_rate;
    --l_dist_info_rec.currency_conversion_type := x_currency_conversion_type;
    --l_dist_info_rec.currency_conversion_date := x_currency_conversion_date;
    --l_dist_info_rec.currency_code  := l_currency_code;
     ----Bug# 5964482 - end of commented code */

    l_acc_gen_primary_key_tbl(1).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
    OPEN  fnd_pro_csr;
    FETCH fnd_pro_csr INTO fnd_pro_rec;
    If ( fnd_pro_csr%NOTFOUND ) Then
        l_acc_gen_primary_key_tbl(1).primary_key_column := '';
    Else
        l_acc_gen_primary_key_tbl(1).primary_key_column := fnd_pro_rec.l_fnd_profile;
    End If;
    CLOSE fnd_pro_csr;

    l_acc_gen_primary_key_tbl(2).source_table := 'AR_SITE_USES_V';
    OPEN  custBillTo_csr(p_contract_id);
    FETCH custBillTo_csr INTO l_custBillTo_rec;
    CLOSE custBillTo_csr;
    l_acc_gen_primary_key_tbl(2).primary_key_column := l_custBillTo_rec.cust_acct_site_id;

    l_acc_gen_primary_key_tbl(3).source_table := 'RA_CUST_TRX_TYPES';
    OPEN  ra_cust_csr;
    FETCH ra_cust_csr INTO ra_cust_rec;
    If ( ra_cust_csr%NOTFOUND ) Then
        l_acc_gen_primary_key_tbl(3).primary_key_column := '';
    Else
        l_acc_gen_primary_key_tbl(3).primary_key_column := TO_CHAR(ra_cust_rec.l_cust_trx_type_id);
    End If;
    CLOSE ra_cust_csr;

    l_acc_gen_primary_key_tbl(4).source_table := 'JTF_RS_SALESREPS_MO_V';
    OPEN  salesP_csr(p_contract_id);
    FETCH salesP_csr INTO l_salesP_rec;
    CLOSE salesP_csr;
    l_acc_gen_primary_key_tbl(4).primary_key_column := l_salesP_rec.id;


    --Bug# 5964482 : Accounting engine CR
    /* Populating the dist_info_Tbl */
    FOR i in x_tclv_tbl.FIRST..x_tclv_tbl.LAST
    LOOP
    --Assigning the account generator table
        l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
        l_acc_gen_tbl(i).source_id :=  x_tclv_tbl(i).id;

        IF (l_ctxt_val_tbl.COUNT > 0) THEN
            l_ctxt_tbl(i).ctxt_val_tbl := l_ctxt_val_tbl;
            l_ctxt_tbl(i).source_id := x_tclv_tbl(i).id;
        END IF;

        l_dist_info_tbl(i).SOURCE_ID := x_tclv_tbl(i).id;
        l_dist_info_tbl(i).SOURCE_TABLE := 'OKL_TXL_CNTRCT_LNS';
        l_dist_info_tbl(i).GL_REVERSAL_FLAG := 'N';
        l_dist_info_tbl(i).POST_TO_GL := l_post_to_gl_yn;
        l_dist_info_tbl(i).CONTRACT_ID := p_contract_id;

        l_dist_info_tbl(i).currency_conversion_rate := x_currency_conversion_rate;
        l_dist_info_tbl(i).currency_conversion_type := x_currency_conversion_type;
        l_dist_info_tbl(i).currency_conversion_date := x_currency_conversion_date;
        l_dist_info_tbl(i).currency_code  := l_currency_code;
        l_dist_info_tbl(i).ACCOUNTING_DATE := l_trxh_out_rec.date_transaction_occurred;
    END LOOP;

    --Assigning transaction header id from the transaction header record created
    l_tcn_id := l_trxH_out_rec.id;


    /* Making the new single accounting engine call*/

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before accounting engine OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST call :'|| x_return_status);
    END IF;
    Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => l_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl  => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
		                  p_trx_header_id     => l_tcn_id);

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After accounting engine OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST call :'|| x_return_status);
    END IF;

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* --Bug# 5964482 : Code commented
    --If ( l_has_trans = OKL_API.G_TRUE ) Then
     --    l_trxH_in_rec.id := l_trx_rec.HeaderTransId;
    --Else
     --    l_trxH_in_rec.id := l_trxH_out_rec.id;
    --End If;

    --l_trxL_in_rec.id := l_dist_info_rec.source_id;
    ----Bug# 5964482 : End of Comments */

    OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Processed');
    FETCH fnd_lookups_csr INTO l_fnd_rec;
    IF fnd_lookups_csr%NOTFOUND THEN
        Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
        CLOSE fnd_lookups_csr;
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE fnd_lookups_csr;

    --From the l_amount_out_tbl returned , the transaction line amount and header amount need to be updated back on the contract
    l_tclv_tbl := x_tclv_tbl;
    l_tcnv_rec := l_trxH_out_rec;

    If l_tclv_tbl.COUNT > 0 then
        FOR i in l_tclv_tbl.FIRST..l_tclv_tbl.LAST LOOP
          l_amount_tbl.delete;
          If l_amount_out_tbl.COUNT > 0 then
              For k in l_amount_out_tbl.FIRST..l_amount_out_tbl.LAST LOOP
                  IF l_tclv_tbl(i).id = l_amount_out_tbl(k).source_id THEN
                      l_amount_tbl := l_amount_out_tbl(k).amount_tbl;
                      l_tclv_tbl(i).currency_code := l_currency_code;
                      IF l_amount_tbl.COUNT > 0 THEN
                          FOR j in l_amount_tbl.FIRST..l_amount_tbl.LAST LOOP
                              l_tclv_tbl(i).amount := nvl(l_tclv_tbl(i).amount,0)  + l_amount_tbl(j);
                          END LOOP; -- for j in
                      END IF;-- If l_amount_tbl.COUNT
                   END IF; ---- IF l_tclv_tbl(i).id
              END LOOP; -- For k in
          END IF; -- If l_amount_out_tbl.COUNT
          l_tcnv_rec.amount := nvl(l_tcnv_rec.amount,0) + l_tclv_tbl(i).amount;
          l_tcnv_rec.currency_code := l_currency_code;
          l_tcnv_rec.tsu_code      := l_fnd_rec.lookup_code;
        END LOOP; -- For i in
     End If; -- If l_tclv_tbl.COUNT


    --Making the call to update the amounts on transaction header and line
    Okl_Trx_Contracts_Pub.update_trx_contracts
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,p_tcnv_rec => l_tcnv_rec
                           ,p_tclv_tbl => l_tclv_tbl
                           ,x_tcnv_rec => x_tcnv_rec
                           ,x_tclv_tbl => x_tclv_tbl );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => x_tcnv_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);


    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
/*-------Bug# 5964482 : Commented code to update header and Lines with Amount--------------------
  --as new code has been incorporated above-----------------------------------------------------
    -- Check Status
    IF(x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN

        l_trxH_in_rec.amount := 0;
        FOR i in 1..l_amount_tbl.COUNT
        LOOP
            l_trxH_in_rec.amount := l_trxH_in_rec.amount + l_amount_tbl(i);
        END LOOP;
        l_trxH_in_rec.currency_code := l_currency_code;

        OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Processed');
        FETCH fnd_lookups_csr INTO l_fnd_rec;
        IF fnd_lookups_csr%NOTFOUND THEN
          Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
          CLOSE fnd_lookups_csr;
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        CLOSE fnd_lookups_csr;
        l_trxH_in_rec.tsu_code := l_fnd_rec.lookup_code;

        l_trxL_in_rec.amount := 0;
        FOR i in 1..l_amount_tbl.COUNT
        LOOP
            l_trxL_in_rec.amount := l_trxL_in_rec.amount + l_amount_tbl(i);
        END LOOP;
        l_trxL_in_rec.currency_code := l_currency_code;


    Else

        OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Error');
        FETCH fnd_lookups_csr INTO l_fnd_rec;
        IF fnd_lookups_csr%NOTFOUND THEN
          Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
          CLOSE fnd_lookups_csr;
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        CLOSE fnd_lookups_csr;
        l_trxH_in_rec.tsu_code := l_fnd_rec.lookup_code;
        l_trxH_in_rec.amount := null;

        l_trxL_in_rec.amount := null;

    End If;

    Okl_Trx_Contracts_Pub.update_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

    Okl_Trx_Contracts_Pub.update_trx_cntrct_lines(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tclv_rec         => l_trxL_in_rec
            ,x_tclv_rec         => l_trxL_out_rec);
    -------Bug# 5964482 : End of comments ------------------------------------------------------*/

    IF (p_draft_yn = OKL_API.G_TRUE) Then
        --Bug# 5964482: disable draft Accounting
        Null;
        /*-----------Commented Code-----------------------
        IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN

            okl_contract_status_pub.update_contract_status(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       l_passStatus,
                                       p_chr_id );

           --call to cascade status on to lines
           OKL_CONTRACT_STATUS_PUB.cascade_lease_status
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_contract_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSE
            okl_contract_status_pub.update_contract_status(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       l_failStatus,
                                       p_chr_id );
            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR)  THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;

           --call to cascade status on to lines
           OKL_CONTRACT_STATUS_PUB.cascade_lease_status
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_contract_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
        ----------End of commented Code-----------------------*/
       --Bug# 5964482
    End If; --Bug# 5964482 Disable Draft Accounting
  End If; --Bug# 5964482 Disable Draft Accounting

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END generate_journal_entries;

  Procedure generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_date IN  DATE,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn          IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)  IS

    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;

  Begin

            generate_journal_entries(
                  p_api_version      => p_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  p_commit           => p_commit,
                  p_contract_id      => p_contract_id,
                  p_transaction_type => p_transaction_type,
                  p_transaction_date => p_transaction_date,
                  p_draft_yn         => p_draft_yn,
                  p_memo_yn          => p_memo_yn,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  x_trxH_rec         => l_trxH_out_rec
                  );

  End generate_journal_entries;

  Procedure generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)  IS

  Begin

            generate_journal_entries(
                  p_api_version      => p_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  p_commit           => p_commit,
                  p_contract_id      => p_contract_id,
                  p_transaction_type => p_transaction_type,
                  p_transaction_date => NULL,
                  p_draft_yn         => p_draft_yn,
                  p_memo_yn          => p_memo_yn,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data);

  End generate_journal_entries;

End OKL_LA_JE_PVT;

/
