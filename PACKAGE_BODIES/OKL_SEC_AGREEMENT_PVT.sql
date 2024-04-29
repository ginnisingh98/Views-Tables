--------------------------------------------------------
--  DDL for Package Body OKL_SEC_AGREEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_AGREEMENT_PVT" AS
/* $Header: OKLRSZAB.pls 120.20.12010000.4 2009/06/02 10:51:18 racheruv ship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
-- see FND_NEW_MESSAGES for full message text
G_NOT_FOUND                  CONSTANT VARCHAR2(30) := 'OKC_NOT_FOUND';  -- message_name
G_NOT_FOUND_V1               CONSTANT VARCHAR2(30) := 'VALUE1';         -- token 1
G_NOT_FOUND_V2               CONSTANT VARCHAR2(30) := 'VALUE2';         -- token 2

G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;
G_INVALID_VALUE              CONSTANT VARCHAR2(30) := 'OKL_INVALID_VALUE';

G_LESSOR_RLE_CODE            CONSTANT VARCHAR2(10) := 'LESSOR';
G_TRUSTEE_RLE_CODE           CONSTANT VARCHAR2(10) := 'TRUSTEE';
G_STS_CODE_NEW               CONSTANT VARCHAR2(10) := 'NEW';
G_STS_CODE_ACTIVE            CONSTANT VARCHAR2(10) := 'ACTIVE';
G_STS_CODE_BOOKED            CONSTANT VARCHAR2(10) := 'BOOKED';
G_SCS_CODE                   CONSTANT VARCHAR2(30) := 'INVESTOR';
G_POOL_TRX_ADD               CONSTANT VARCHAR2(30) := 'ADD';
G_POOL_TRX_REASON_ACTIVE     CONSTANT VARCHAR2(30) := 'ACTIVATION';
G_SECURITIZED_CODE_Y         CONSTANT VARCHAR2(30) := 'Y';
G_SECURITIZED_CODE_N         CONSTANT VARCHAR2(30) := 'N';
G_LESSOR_JTOT_OBJECT1_CODE   CONSTANT VARCHAR2(30) := 'OKX_OPERUNIT';
G_TRUSTEE_JTOT_OBJECT1_CODE  CONSTANT VARCHAR2(30) := 'OKX_VENDOR';

G_POC_STS_NEW                CONSTANT VARCHAR2(3)  := OKL_POOL_PVT.G_POC_STS_NEW;
G_POC_STS_ACTIVE             CONSTANT VARCHAR2(6)  := OKL_POOL_PVT.G_POC_STS_ACTIVE;
G_POC_STS_INACTIVE           CONSTANT VARCHAR2(8)  := OKL_POOL_PVT.G_POC_STS_INACTIVE;

G_FACTORING_SYND_FLAG_INVESTOR CONSTANT VARCHAR2(45) := 'INVESTOR';
G_OKL_SEC_ACCT_TRX_DESC      CONSTANT VARCHAR2(45) := 'OKL_SEC_ACCT_TRX_DESC';
G_RULE_GRP_LASEAC            CONSTANT VARCHAR2(45) := 'LASEAC';
G_RULE_LASEAC                CONSTANT VARCHAR2(45) := 'LASEAC';
G_TRY_TYPE_INV               CONSTANT VARCHAR2(30) := 'Investor';

 -- sosharma added codes for tranaction_status
   G_POOL_TRX_STATUS_COMPLETE               CONSTANT VARCHAR2(30) := 'COMPLETE';
   G_POOL_TRX_STATUS_PENDING           CONSTANT VARCHAR2(30) := 'PENDING';
   G_POOL_TRX_STATUS_INCOMPLETE               CONSTANT VARCHAR2(30) := 'INCOMPLETE';

 --added by kthiruva for bug 6691554
   G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
   G_HALT_PROCESSING  		 EXCEPTION;

  -- ankushar Added constants to be used by the workflow
 G_ADD_KHR_REQUEST_APPROVAL_WF          CONSTANT VARCHAR2(2)   := 'WF';
 G_ADD_KHR_REQUEST_APPRV_AME            CONSTANT VARCHAR2(3)   := 'AME';
 G_POOL_TRX_STATUS_SUBMITTED            CONSTANT VARCHAR2(30)  := 'SUBMITTED';
 G_POOL_TRX_STATUS_APPROVED             CONSTANT VARCHAR2(30)  := 'APPROVED';
 G_POOL_TRX_STATUS_NEW                  CONSTANT VARCHAR2(30)  := 'NEW';
 G_NO_MATCHING_RECORD                   CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
 G_POOL_TRX_STS_APPR_REJECTED           CONSTANT VARCHAR2(30)  := 'APPROVAL_REJECTED';
 G_POOL_TRX_STATUS_PENDING_APPR         CONSTANT VARCHAR2(30)  := 'PENDING_APPROVAL';

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------

 SUBTYPE khrv_rec_type IS OKL_CONTRACT_PVT.khrv_rec_type;
 SUBTYPE khrv_tbl_type IS OKL_CONTRACT_PVT.khrv_tbl_type;
 SUBTYPE klev_rec_type IS okl_CONTRACT_PVT.klev_rec_type;
 SUBTYPE klev_tbl_type IS okl_CONTRACT_PVT.klev_tbl_type;
 SUBTYPE clev_rec_type IS okl_okc_migration_pvt.clev_rec_type;
 SUBTYPE clev_tbl_type IS okl_okc_migration_pvt.clev_tbl_type;
 SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;

 SUBTYPE polv_rec_type IS OKL_POL_PVT.polv_rec_type;
 SUBTYPE polv_tbl_type IS OKL_POL_PVT.polv_tbl_type;
 SUBTYPE pocv_rec_type IS OKL_POC_PVT.pocv_rec_type;
 SUBTYPE pocv_tbl_type IS OKL_POC_PVT.pocv_tbl_type;
 SUBTYPE poxv_rec_type IS OKL_POX_PVT.poxv_rec_type;
 SUBTYPE poxv_tbl_type IS OKL_POX_PVT.poxv_tbl_type;

 SUBTYPE taiv_rec_type IS OKL_TAI_PVT.taiv_rec_type;
 SUBTYPE taiv_tbl_type IS OKL_TAI_PVT.taiv_tbl_type;
 SUBTYPE tilv_rec_type IS OKL_TIL_PVT.tilv_rec_type;
 SUBTYPE tilv_tbl_type IS OKL_TIL_PVT.tilv_tbl_type;


----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : generate_journal_entries
-- Description     : generate journal entries for securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- Version         : 2.0 - Uptaken new Accounting Engine functionality in R12 codeline.
--                       - Varangan - Bug#5964482.
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE generate_journal_entries(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN  NUMBER
   ,p_transaction_type             IN  VARCHAR2 -- 'INV'
   ,p_transaction_date             IN  DATE DEFAULT NULL)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'generate_journal_entries';
  l_api_version      CONSTANT NUMBER       := 1.0;

  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--
     -- Define PL/SQL Records and Tables
    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_in_rec        Okl_Trx_Contracts_Pvt.tclv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_out_rec       Okl_Trx_Contracts_Pvt.tclv_rec_type;

    -- Define variables
    l_sysdate         DATE;
    l_sysdate_trunc   DATE;
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

    CURSOR fnd_pro_csr IS
    SELECT mo_global.get_current_org_id() l_fnd_profile
    FROM dual;
    fnd_pro_rec fnd_pro_csr%ROWTYPE;
/*
    Cursor ra_cust_csr IS
    select cust_trx_type_id l_cust_trx_type_id
    from ra_cust_trx_types
    where name = 'Investor-OKL';
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
    select object1_id1 cust_acct_site_id
    from okc_rules_b rul
    where  rul.rule_information_category = 'BTO'
         and exists (select '1'
                     from okc_rule_groups_b rgp
                     where rgp.id = rul.rgp_id
                          and   rgp.rgd_code = 'LABILL'
                          and   rgp.dnz_chr_id = chrId );

    l_custBillTo_rec custBillTo_csr%ROWTYPE;
*/
    CURSOR Product_csr (p_contract_id IN okl_products_v.id%TYPE) IS
    SELECT pdt.id                       product_id
          ,pdt.name                     product_name
          ,khr.sts_code                 contract_status
          ,khr.start_date               start_date
          ,khr.currency_code            currency_code
          ,khr.authoring_org_id         authoring_org_id
          ,khr.currency_conversion_rate currency_conversion_rate
          ,khr.currency_conversion_type currency_conversion_type
          ,khr.currency_conversion_date currency_conversion_date
          --Bug# 4622198
          ,khr.scs_code
    FROM   okl_products_v        pdt
          ,okl_k_headers_full_v  khr
    WHERE  khr.id = p_contract_id
    AND    khr.pdt_id = pdt.id;

    l_func_curr_code               OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    l_chr_curr_code                OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
    x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
    x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

    CURSOR Transaction_Type_csr (p_transaction_type IN okl_trx_types_v.name%TYPE ) IS
    SELECT id       trx_try_id
    FROM  okl_trx_types_tl
    WHERE  name = p_transaction_type
         AND LANGUAGE = 'US';

    CURSOR fnd_lookups_csr( lkp_type VARCHAR2, mng VARCHAR2 ) IS
    SELECT description,
           lookup_code
    FROM   fnd_lookup_values
    WHERE LANGUAGE = 'US'
         AND lookup_type = lkp_type
         AND meaning = mng;

    CURSOR trx_csr( khrId NUMBER, tcntype VARCHAR2 ) IS
    SELECT txh.ID HeaderTransID,
           txl.ID LineTransID,
           txh.date_transaction_occurred date_transaction_occurred
    FROM okl_trx_contracts txh,
         okl_txl_cntrct_lns txl
    WHERE  txl.tcn_id = txh.id
         AND txh.tcn_type = tcntype
   --rkuttiya added for 12.1.1 Multi GAAP
         AND  txh.representation_type = 'PRIMARY'
     --
         AND txl.khr_id = khrId;


    -- investor code for agreement special accounting
    CURSOR special_acct_rec_csr( chrId NUMBER) IS
      SELECT rul.rule_information1 investor_code
    FROM okc_rules_b rul,
         okc_rule_groups_b rgp
    WHERE rgp.id = rul.rgp_id
    AND   rul.rule_information_category = G_RULE_GRP_LASEAC --'LASEAC'
    AND   rgp.rgd_code = G_RULE_LASEAC --'LASEAC'
    AND   rul.dnz_chr_id = chrId
    ;

    -- Cursor Types
    l_Product_rec      Product_csr%ROWTYPE;
    l_Trx_Type_rec     Transaction_Type_csr%ROWTYPE;
    l_fnd_rec          fnd_lookups_csr%ROWTYPE;
    l_fnd_rec1         fnd_lookups_csr%ROWTYPE;
    l_trx_rec          trx_csr%ROWTYPE;
    l_special_acct_rec special_acct_rec_csr%ROWTYPE;

    l_transaction_type VARCHAR2(256) := p_transaction_type;
    l_transaction_date DATE;

    l_tmpl_identify_rec  OKL_ACCOUNT_DIST_PVT.TMPL_IDENTIFY_REC_TYPE;
    l_dist_info_rec      OKL_ACCOUNT_DIST_PVT.dist_info_REC_TYPE;
    l_template_tbl       OKL_ACCOUNT_DIST_PVT.AVLV_TBL_TYPE;
    l_amount_tbl         OKL_ACCOUNT_DIST_PVT.AMOUNT_TBL_TYPE;

-- Begin - Bug#5964482 - AE Uptake Changes
  l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
  l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
  l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
  l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
  l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
  l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
  l_tcn_id                     NUMBER;
  l_tclv_tbl                  OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  x_tclv_tbl                  Okl_Trx_Contracts_Pub.tclv_tbl_type;
  l_count                     NUMBER;


-- End - Bug#5964482 - AE Uptake Changes
    l_ctxt_val_tbl       OKL_ACCOUNT_DIST_PVT.CTXT_VAL_TBL_TYPE;
    l_acc_gen_primary_key_tbl OKL_ACCOUNT_DIST_PVT.acc_gen_primary_key;

    l_has_trans          VARCHAR2(1);
    l_trx_desc           VARCHAR2(2000);

    --Bug# 4622198
    l_fact_synd_code      FND_LOOKUPS.Lookup_code%TYPE;
    l_inv_acct_code       OKC_RULES_B.Rule_Information1%TYPE;
    --Bug# 4622198
--
    --Added by kthiruva for Bug 6354647
    l_legal_entity_id      NUMBER;

BEGIN
  -- Set API savepoint
  SAVEPOINT generate_journal_entries_PVT;

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
    --------------------------------------------------------------------------
    -- Initialize API variables
    --------------------------------------------------------------------------
--dbms_output.put_line('Initialize API variables');

    l_sysdate        := SYSDATE;
    l_sysdate_trunc  := TRUNC(SYSDATE);
    i                := 0;
    l_post_to_gl_yn := 'Y';

    --------------------------------------------------------------------------
    -- Get indirect values
    --------------------------------------------------------------------------
--dbms_output.put_line('Get indirect values');

    -- Get product_id
    OPEN  Product_csr(p_contract_id);
    FETCH Product_csr INTO l_Product_rec;
    IF Product_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'Product');
      CLOSE Product_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE Product_csr;

    l_currency_code  := l_Product_rec.currency_code;

    -- default trsanction date to contract start date
    IF ( p_transaction_date IS NULL ) THEN
        l_transaction_date  := l_Product_rec.start_date;
    ELSE
        l_transaction_date  := p_transaction_date;
    END IF;

    -- get translated transaction message
    l_trx_desc := fnd_message.get_string(G_APP_NAME, G_OKL_SEC_ACCT_TRX_DESC);
    IF l_trx_desc IS NULL THEN
      l_trx_desc := 'Journals - ' || l_transaction_type;
    END IF;

    --------------------------------------------------------------------------
    -- multi-currency setup
    --------------------------------------------------------------------------
--dbms_output.put_line('multi-currency setup');


    l_chr_curr_code  := l_Product_rec.CURRENCY_CODE;
    l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_Product_rec.authoring_org_id);

    x_currency_conversion_rate := NULL;
    x_currency_conversion_type := NULL;
    x_currency_conversion_date := NULL;

    IF ( ( l_func_curr_code IS NOT NULL) AND
         ( l_chr_curr_code <> l_func_curr_code ) ) THEN

        x_currency_conversion_type := l_Product_rec.currency_conversion_type;
        x_currency_conversion_date := l_Product_rec.start_date;

        IF ( l_Product_rec.currency_conversion_type = 'User') THEN
            x_currency_conversion_rate := l_Product_rec.currency_conversion_rate;
            x_currency_conversion_date := l_Product_rec.currency_conversion_date;
        ELSE
            x_currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
	                                       p_from_curr_code => l_chr_curr_code,
	                                       p_to_curr_code   => l_func_curr_code,
	                			         p_con_date       => l_Product_rec.start_date,
				                     p_con_type       => l_Product_rec.currency_conversion_type);

        END IF;

    END IF;

    --------------------------------------------------------------------------
    -- Validate passed parameters
    --------------------------------------------------------------------------
--dbms_output.put_line('Validate passed parameters');


    -- check contract
    IF   ( p_contract_id = Okl_Api.G_MISS_NUM       )
      OR ( p_contract_id IS NULL                    ) THEN
        Okl_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'contract');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF   ( l_transaction_type = Okl_Api.G_MISS_CHAR )
      OR ( l_transaction_type IS NULL               ) THEN
        Okl_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

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
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
      CLOSE fnd_lookups_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE fnd_lookups_csr;

    OPEN  trx_csr(p_contract_id,l_fnd_rec.lookup_code);
    FETCH trx_csr INTO l_trx_rec;
    IF trx_csr%NOTFOUND THEN -- While activation, create a new trans always.
        l_has_trans := OKL_API.G_FALSE;
    ELSE
        l_has_trans := OKL_API.G_TRUE;
    END IF;
    CLOSE trx_csr;

    -- Check special accounting code
    OPEN  special_acct_rec_csr(p_contract_id);
    FETCH special_acct_rec_csr INTO l_special_acct_rec;
/* comment out. it's not a required attribute
    IF special_acct_rec_csr%NOTFOUND THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Agreement Accounting Code');
      CLOSE special_acct_rec_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
*/
    CLOSE special_acct_rec_csr;

    --------------------------------------------------------------------------
    -- Assign passed in record values for transaction header and line
    --------------------------------------------------------------------------
--dbms_output.put_line('Assign passed in record values for transaction header and line');

    --Added by kthiruva on 22-Aug-2007
	--Bug 6354647 - Start of Changes
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;

    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxH_in_rec.legal_entity_id :=  l_legal_entity_id;
    END IF;
	--Bug 6354647 - End of Changes


    l_trxH_in_rec.khr_id         := p_contract_id;
    l_trxH_in_rec.pdt_id         := l_Product_rec.product_id;
    l_trxH_in_rec.tcn_type       := l_fnd_rec.lookup_code;
    l_trxH_in_rec.currency_code  := l_currency_code;
    l_trxH_in_rec.try_id         := l_Trx_Type_rec.trx_try_id;
    l_trxH_in_rec.description    := l_trx_desc;

    l_trxH_in_rec.currency_conversion_rate := x_currency_conversion_rate;
    l_trxH_in_rec.currency_conversion_type := x_currency_conversion_type;
    l_trxH_in_rec.currency_conversion_date := x_currency_conversion_date;

    OPEN  fnd_lookups_csr('OKL_TCL_TYPE', l_transaction_type);
    FETCH fnd_lookups_csr INTO l_fnd_rec1;
    IF fnd_lookups_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
      CLOSE fnd_lookups_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE fnd_lookups_csr;




    --------------------------------------------------------------------------
    -- Create transaction Header and line
    --------------------------------------------------------------------------
--dbms_output.put_line('Create transaction Header and line');


 --  IF ( l_has_trans = OKL_API.G_FALSE ) THEN
 -- Commenting the above IF condition to create Accounting Header, Lines and Distributions
 -- Always while activating an agreement

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

    -- Create Transaction Header, Lines
        Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF ((l_trxH_out_rec.id = OKL_API.G_MISS_NUM) OR
            (l_trxH_out_rec.id IS NULL) ) THEN
            OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
       l_fnd_rec := NULL;

    -------------------------------------------------------------------------
    --Bug# 4622198 :For special accounting treatment
    --------------------------------------------------------------------------
    OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
				  p_api_version             => l_api_version,
				  p_init_msg_list           => l_init_msg_list,
				  x_return_status           => l_return_status,
				  x_msg_count               => l_msg_count,
				  x_msg_data                => l_msg_data,
				  p_khr_id                  => p_contract_id,
				  p_scs_code                => l_product_rec.scs_code,
				  p_trx_date                => l_transaction_date,
				  x_fact_synd_code          => l_fact_synd_code,
				  x_inv_acct_code           => l_inv_acct_code
				  );

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    -------------------------------------------------------------------------
    -- Determine Number of transaction lines to create - accounting template record
    --------------------------------------------------------------------------
    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := l_Trx_Type_rec.trx_try_id;
    l_tmpl_identify_rec.PRODUCT_ID := l_Product_rec.product_id;
    l_tmpl_identify_rec.FACTORING_SYND_FLAG := G_FACTORING_SYND_FLAG_INVESTOR;
    l_tmpl_identify_rec.INVESTOR_CODE := l_special_acct_rec.investor_code;
    l_tmpl_identify_rec.factoring_synd_flag := l_fact_synd_code;
    l_tmpl_identify_rec.investor_code       := l_inv_acct_code;

     -------------------------------------------------------------------------
   --Call to get_template_info to determine the number of transaction lines to be created
   -------------------------------------------------------------------------
   Okl_Account_Dist_Pub.GET_TEMPLATE_INFO(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       x_return_status      => l_return_status,
                       x_msg_count          => l_msg_count,
                       x_msg_data           => l_msg_data,
                       p_tmpl_identify_rec  => l_tmpl_identify_rec,
                       x_template_tbl       => l_template_tbl,
                       p_validity_date      => l_transaction_date);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Build the transaction line table of records
    -------------------------------------------------------------------------
     FOR i IN l_template_tbl.FIRST..l_template_tbl.LAST
     LOOP
       l_tclv_tbl(i).line_number := i;
       l_tclv_tbl(i).khr_id := p_contract_id;
       l_tclv_tbl(i).tcl_type := l_fnd_rec1.lookup_code;
       l_tclv_tbl(i).currency_code  := l_currency_code;
       l_tclv_tbl(i).description    := l_trx_desc;
       l_tclv_tbl(i).tcn_id         := l_trxH_out_rec.id;
       l_tclv_tbl(i).sty_id := l_template_tbl(i).sty_id;
     END LOOP;




    --------------------------------------------------------------------------
    -- Create Transaction Header, Lines
    --------------------------------------------------------------------------
    Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
                                      p_api_version   => l_api_version,
                                      p_init_msg_list => l_init_msg_list,
                                      x_return_status => l_return_status,
                                      x_msg_count     => l_msg_count,
                                      x_msg_data      => l_msg_data,
                                      p_tclv_tbl      => l_tclv_tbl,
                                      x_tclv_tbl      => x_tclv_tbl);  --l_trxL_out_rec



        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        ----------------------------------------------------------------------------------------
        -- Populating the tmpl_identify_tbl  from the template_tbl returned by get_template_info
       ----------------------------------------------------------------------------------------
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

       ------------------------------------------------------------------------------------------------
      -- Populate account generator sources
      ------------------------------------------------------------------------------------------------
      OKL_ACC_CALL_PVT.okl_populate_acc_gen(
			p_contract_id	=>p_contract_id ,
			x_acc_gen_tbl	=> l_acc_gen_primary_key_tbl,
			x_return_status	 => l_return_status);


      IF l_Product_rec.contract_status = 'ACTIVE'
      THEN
         l_ctxt_val_tbl(0).NAME := 'p_transaction_reason';
         l_ctxt_val_tbl(0).VALUE := 'ADJUSTMENTS';
     END IF;


        --------------------------------------------------------------------------
	  /* Populating the dist_info_Tbl */
	--------------------------------------------------------------------------

	FOR i in x_tclv_tbl.FIRST..x_tclv_tbl.LAST
	LOOP
	  IF ((x_tclv_tbl(i).id = OKL_API.G_MISS_NUM) OR
            (x_tclv_tbl(i).id IS NULL) ) THEN
            OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --Assigning the account generator table
	 l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
	 l_acc_gen_tbl(i).source_id :=  x_tclv_tbl(i).id;

      IF (l_ctxt_val_tbl.COUNT > 0) THEN
        l_ctxt_tbl(i).ctxt_val_tbl := l_ctxt_val_tbl;
        l_ctxt_tbl(i).source_id := x_tclv_tbl(i).id;
      END IF;

          l_dist_info_tbl(i).SOURCE_ID := x_tclv_tbl(i).id;
	  l_dist_info_tbl(i).ACCOUNTING_DATE := l_trxH_out_rec.date_transaction_occurred;
          l_dist_info_tbl(i).SOURCE_TABLE := 'OKL_TXL_CNTRCT_LNS';
          l_dist_info_tbl(i).GL_REVERSAL_FLAG := 'N';
	  l_dist_info_tbl(i).POST_TO_GL := l_post_to_gl_yn;
	  l_dist_info_tbl(i).CONTRACT_ID := p_contract_id;
          l_dist_info_tbl(i).currency_conversion_rate := x_currency_conversion_rate;
	  l_dist_info_tbl(i).currency_conversion_type := x_currency_conversion_type;
	  l_dist_info_tbl(i).currency_conversion_date := x_currency_conversion_date;
	  l_dist_info_tbl(i).currency_code  := l_currency_code;
	END LOOP;

     /*  ELSE  -- Commenting out this Else condition, since there is no possibility of
               -- of just doing accounting distributions with existing Accounting header line and line
	       -- while activating an agreement.
	       -- Pls. update this code appropriately in future, if only accounting distribution
	       -- alone should be done while activating an Investor Agreement with already existing
	       -- Accounting entries
		    --------------------------------------------------------------------------
		    -- Refer transaction line ID if already exists -- future needs
		    --------------------------------------------------------------------------

			l_dist_info_rec.SOURCE_ID := l_trx_rec.LineTransId;
			l_dist_info_rec.ACCOUNTING_DATE := l_trx_rec.date_transaction_occurred;
       END IF;  */


      ------------------------------------------------------------------------------------------------
      -- Call Okl_Account_Dist_Pub API to create accounting entries for this transaction- new signature
      ------------------------------------------------------------------------------------------------
      --Assigning transaction header id from the transaction header record created

      l_tcn_id := l_trxH_out_rec.id;

      Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => 1.0,
                                  p_init_msg_list      => l_init_msg_list,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       =>  l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				  p_trx_header_id      => l_tcn_id);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------------------------------------------
    -- Summation amount after accounting API generate transction records from
    -- formula functions
    --------------------------------------------------------------------------
--dbms_output.put_line('Summation amount after accounting API generate transction records from formula functions');


    -- Check Status
    IF(l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN

	    --From the l_amount_out_tbl returned , the transaction line amount and header amount
	    --need to be updated back on the contract
	    l_tclv_tbl := x_tclv_tbl;
	    l_trxH_in_rec := l_trxH_out_rec;
	    l_count := l_amount_out_tbl.FIRST;
	    FOR i in l_tclv_tbl.FIRST..l_tclv_tbl.LAST LOOP
	      IF l_tclv_tbl(i).id = l_amount_out_tbl(l_count).source_id THEN
       /*
         05-Sep-2007, ankushar Bug# 6391302
         start changes, added check for NULL and G_MISS_NUM for amount field
       */
       IF l_tclv_tbl(i).amount IS NULL OR l_tclv_tbl(i).amount = OKL_API.G_MISS_NUM THEN
                l_tclv_tbl(i).amount :=0;
       END IF;
       /* 05-Sep-2007 ankushar end changes */

		l_amount_tbl := l_amount_out_tbl(l_count).amount_tbl;
		IF l_amount_tbl.COUNT > 0 THEN
		    FOR j in l_amount_tbl.FIRST..l_amount_tbl.LAST LOOP
			l_tclv_tbl(i).amount := l_tclv_tbl(i).amount  + l_amount_tbl(j);
		    END LOOP;
		END IF;
	     END IF;
	       l_tclv_tbl(i).currency_code := l_currency_code;
       /*
         05-Sep-2007, ankushar Bug# 6391302
         start changes, added check for NULL and G_MISS_NUM for amount field
       */
         IF l_trxH_in_rec.amount IS NULL OR l_trxH_in_rec.amount = OKL_API.G_MISS_NUM THEN
            l_trxH_in_rec.amount :=0;
         END IF;
       /* 05-Sep-2007 ankushar end changes */

        l_trxH_in_rec.amount := l_trxH_in_rec.amount + l_tclv_tbl(i).amount;
	       l_count := l_count + 1;
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

    ELSE

        OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Error');
        FETCH fnd_lookups_csr INTO l_fnd_rec;
        IF fnd_lookups_csr%NOTFOUND THEN
          Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
          CLOSE fnd_lookups_csr;
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        CLOSE fnd_lookups_csr;
        l_trxH_in_rec.tsu_code := l_fnd_rec.lookup_code;
        l_trxH_in_rec.amount := NULL;
        FOR i in l_tclv_tbl.FIRST..l_tclv_tbl.LAST
	LOOP
          l_tclv_tbl(i).amount := NULL;
        END LOOP;
        --l_trxL_in_rec.amount := NULL;

    END IF;
    --------------------------------------------------------------------------
    -- Update amount and tsu_code for parent record refer from all chrildren
    -- records generated by accounting distribution API
    --------------------------------------------------------------------------
--dbms_output.put_line('Update amount and tsu_code for parent record refer from all chrildren...');


    Okl_Trx_Contracts_Pub.update_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    Okl_Trx_Contracts_Pub.update_trx_cntrct_lines(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
 	    ,p_tclv_tbl         => l_tclv_tbl
            ,x_tclv_tbl         => x_tclv_tbl);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => l_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => l_trxH_out_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO generate_journal_entries_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO generate_journal_entries_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO generate_journal_entries_PVT;
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

END generate_journal_entries;

  --------------------------------------------------------------------------
  ----- Validate Contract Number uniqueness check
  --------------------------------------------------------------------------
  FUNCTION validate_contract_number(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  VARCHAR2(1) := '?';

    CURSOR c (p_contract_number VARCHAR2)
    IS
    SELECT 'X'
      FROM okc_k_headers_b k
     WHERE k.contract_number = p_contract_number
    ;

    CURSOR c2 (p_contract_number VARCHAR2, p_id NUMBER)
    IS
    SELECT 'X'
      FROM okc_k_headers_b k
     WHERE k.contract_number = p_contract_number
     AND   k.id <> p_id -- except itself
  ;

  BEGIN

    -- check only if contract number exists
    IF (p_secAgreement_rec.contract_number IS NOT NULL AND
        p_secAgreement_rec.contract_number <> OKL_API.G_MISS_CHAR)
    THEN

      IF (p_mode = 'C') THEN
        OPEN c(p_secAgreement_rec.contract_number);
        FETCH c INTO l_dummy;
        CLOSE c;
      ELSIF (p_mode = 'U') THEN
        OPEN c2(p_secAgreement_rec.contract_number, p_secAgreement_rec.id);
        FETCH c2 INTO l_dummy;
        CLOSE c2;
      END IF;

      IF (l_dummy = 'X')
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_NOT_UNIQUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Agreement Number');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

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
  --------------------------------------------------------------------------
  ----- Validate Product
  --------------------------------------------------------------------------
  FUNCTION validate_product(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(10);
    l_row_not_found BOOLEAN := FALSE;

  CURSOR c_pdt IS
  SELECT 'x'
  FROM okl_products_v
  WHERE id = p_secAgreement_rec.pdt_id
;

  BEGIN

  IF (p_mode = 'C') THEN
    -- check required
    IF (p_secAgreement_rec.pdt_id IS NULL) OR
       (p_secAgreement_rec.pdt_id = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Product');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  IF (p_secAgreement_rec.pdt_id IS NOT NULL) AND
       (p_secAgreement_rec.pdt_id <> OKL_API.G_MISS_NUM)
  THEN

    -- check FK
    OPEN c_pdt;
    FETCH c_pdt INTO l_dummy;
    l_row_not_found := c_pdt%NOTFOUND;
    CLOSE c_pdt;

    IF l_row_not_found THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'pdt_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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

  --------------------------------------------------------------------------
  ----- Validate Pool number
  --------------------------------------------------------------------------
  FUNCTION validate_pool_number(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(10);
    l_row_not_found BOOLEAN := FALSE;
    l_row_found BOOLEAN := FALSE;

  CURSOR c_pool IS
  SELECT 'x'
  FROM okl_pools
  WHERE id = p_secAgreement_rec.pol_id
;
  BEGIN

  IF (p_mode = 'C') THEN
    IF (p_secAgreement_rec.pol_id IS NULL) OR
       (p_secAgreement_rec.pol_id = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Pool Number');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  IF (p_secAgreement_rec.pol_id IS NOT NULL) AND
       (p_secAgreement_rec.pol_id <> OKL_API.G_MISS_NUM)
  THEN

    -- check FK
    OPEN c_pool;
    FETCH c_pool INTO l_dummy;
    l_row_not_found := c_pool%NOTFOUND;
    CLOSE c_pool;

    IF l_row_not_found THEN
      OKL_API.Set_Message(p_app_name     => 'OKC',
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'pol_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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
  --------------------------------------------------------------------------
  ----- Validate pool number vs existing link for khr_id
  --------------------------------------------------------------------------
  FUNCTION validate_pool_number_unique(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(10);
    l_row_not_found BOOLEAN := FALSE;
    l_row_found BOOLEAN := FALSE;

  CURSOR c_pool IS
  SELECT 'x'
  FROM okl_pools
  WHERE khr_id IS NOT NULL
  AND id = p_secAgreement_rec.pol_id
;

  CURSOR c_pool_upd IS
  SELECT 'x'
  FROM okl_pools
  WHERE khr_id IS NOT NULL
  AND id = p_secAgreement_rec.pol_id
  AND khr_id <> p_secAgreement_rec.id
;


  BEGIN

  IF (p_secAgreement_rec.pol_id IS NOT NULL) AND
       (p_secAgreement_rec.pol_id <> OKL_API.G_MISS_NUM)
  THEN

    -- check 1 on 1 relationship between agreement contract and pool
    IF (p_mode = 'C') THEN
      OPEN c_pool;
      FETCH c_pool INTO l_dummy;
      l_row_found := c_pool%FOUND;
      CLOSE c_pool;
    ELSE
      OPEN c_pool_upd;
      FETCH c_pool_upd INTO l_dummy;
      l_row_found := c_pool_upd%FOUND;
      CLOSE c_pool_upd;
    END IF;

    IF l_row_found THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_INVALID_POOL_NUM');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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

  --------------------------------------------------------------------------
  ----- Validate Description
  --------------------------------------------------------------------------


  FUNCTION validate_description(
   p_secAgreement_rec             IN secAgreement_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_secAgreement_rec.short_description IS NOT NULL AND
        p_secAgreement_rec.short_description <> OKL_API.G_MISS_CHAR)
    THEN

      IF (LENGTH(p_secAgreement_rec.short_description) > 600) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_EXCEED_MAXIMUM_LENGTH',
                          p_token1       => 'MAX_CHARS',
                          p_token1_value => '600',
                          p_token2       => 'COL_NAME',
                          p_token2_value => 'Note');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

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
  --------------------------------------------------------------------------
  ----- Validate Effectve From
  --------------------------------------------------------------------------
  FUNCTION validate_effective_from(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

  IF (p_mode = 'C') THEN
    IF (p_secAgreement_rec.start_date IS NULL) OR
       (p_secAgreement_rec.start_date = OKL_API.G_MISS_DATE)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Effective From');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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
  --------------------------------------------------------------------------
  ----- Validate securitization type
  --------------------------------------------------------------------------
  FUNCTION validate_securitization_type(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(10);

    l_row_not_found BOOLEAN := FALSE;
    l_row_found BOOLEAN := FALSE;

  CURSOR c_sec_type IS
  SELECT 'x'
  FROM fnd_lookups
  WHERE lookup_type = 'OKL_SECURITIZATION_TYPE'
  AND lookup_code = p_secAgreement_rec.SECURITIZATION_TYPE
;

  BEGIN

  IF (p_mode = 'C') THEN
    IF (p_secAgreement_rec.securitization_type IS NULL) OR
       (p_secAgreement_rec.securitization_type = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Securitization Type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  IF (p_secAgreement_rec.securitization_type IS NOT NULL) AND
       (p_secAgreement_rec.securitization_type <> OKL_API.G_MISS_CHAR)
  THEN

    -- check FK
    OPEN c_sec_type;
    FETCH c_sec_type INTO l_dummy;
    l_row_not_found := c_sec_type%NOTFOUND;
    CLOSE c_sec_type;


    IF l_row_not_found THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Securitization Type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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

  --------------------------------------------------------------------------
  ----- Validate Recourse
  --------------------------------------------------------------------------
  FUNCTION validate_recourse(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(10);
    l_row_not_found BOOLEAN := FALSE;

  CURSOR c_rcs IS
  SELECT 'x'
  FROM fnd_lookups
  WHERE lookup_type = 'OKL_SEC_RECOURSE'
;

  BEGIN

  IF (p_secAgreement_rec.RECOURSE_CODE IS NOT NULL) AND
       (p_secAgreement_rec.RECOURSE_CODE <> OKL_API.G_MISS_CHAR)
  THEN

    -- check FK
    OPEN c_rcs;
    FETCH c_rcs INTO l_dummy;
    l_row_not_found := c_rcs%NOTFOUND;
    CLOSE c_rcs;

    IF l_row_not_found THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'RECOURSE_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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
  --------------------------------------------------------------------------
  ----- Validate LESSOR_SERV_ORG_CODE
  --------------------------------------------------------------------------
  FUNCTION validate_lessor_serv(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(10);
    l_row_not_found BOOLEAN := FALSE;

  CURSOR c_serv IS
  SELECT 'x'
  FROM fnd_lookups
  WHERE lookup_type = 'OKL_SEC_SERVICE_ORG'
;

  BEGIN

  IF (p_secAgreement_rec.LESSOR_SERV_ORG_CODE IS NOT NULL) AND
       (p_secAgreement_rec.LESSOR_SERV_ORG_CODE <> OKL_API.G_MISS_CHAR)
  THEN

    -- check FK
    OPEN c_serv;
    FETCH c_serv INTO l_dummy;
    l_row_not_found := c_serv%NOTFOUND;
    CLOSE c_serv;

    IF l_row_not_found THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'LESSOR_SERV_ORG_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

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

  --------------------------------------------------------------------------
  FUNCTION validate_header_attributes(
   p_secAgreement_rec             IN secAgreement_rec_type
   ,p_mode                        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN


    -- Do formal attribute validation:
    l_return_status := validate_contract_number(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_product(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_pool_number(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_pool_number_unique(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_description(p_secAgreement_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_effective_from(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_securitization_type(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_recourse(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_lessor_serv(p_secAgreement_rec, p_mode);
    --- Store the highest degree of error

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_header_attributes;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_sec_agreement
-- Description     : creates a securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_sec_agreement(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_secAgreement_rec             IN secAgreement_rec_type
   ,x_secAgreement_rec             OUT NOCOPY secAgreement_rec_type)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'create_sec_agreement_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_qcl_id           OKC_QA_CHECK_LISTS_TL.ID%TYPE;
  l_row_not_found BOOLEAN := FALSE;

    lp_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lx_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

  l_polv_rec         polv_rec_type;
  x_polv_rec         polv_rec_type;


CURSOR c_qcl IS
 SELECT qcl.id
   FROM  OKC_QA_CHECK_LISTS_TL qcl,
         OKC_QA_CHECK_LISTS_B qclv
   WHERE qclv.Id = qcl.id
          AND UPPER(qcl.name) = 'OKL LA QA INVESTOR AGMNT'
          AND qcl.LANGUAGE = 'US'
;


    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

BEGIN
  -- Set API savepoint
  SAVEPOINT create_sec_agreement_PVT;

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

-- get qcl_id for QA checker
  OPEN c_qcl;
  FETCH c_qcl INTO l_qcl_id;
  l_row_not_found := c_qcl%NOTFOUND;
  CLOSE c_qcl;

  lp_chrv_rec.qcl_id := l_qcl_id;

--
-- creates an agreement
--
    lp_chrv_rec.sfwt_flag := 'N';
    lp_chrv_rec.object_version_number := 1.0;
    lp_chrv_rec.sts_code := G_STS_CODE_NEW; -- 'ENTERED';
    lp_chrv_rec.scs_code := G_SCS_CODE;--p_scs_code;
    lp_chrv_rec.contract_number := p_secAgreement_rec.CONTRACT_NUMBER;

--    lp_chrv_rec.sts_code := p_secAgreement_rec.STS_CODE;
    lp_chrv_rec.description := p_secAgreement_rec.short_description;
    lp_chrv_rec.short_description := p_secAgreement_rec.short_description;
    lp_chrv_rec.start_date := p_secAgreement_rec.start_date;
--    IF (p_secAgreement_rec.end_date is null or p_secAgreement_rec.end_date = OKL_API.G_MISS_DATE) THEN
--      lp_chrv_rec.end_date :=  null;
--    ELSE
      lp_chrv_rec.end_date :=  p_secAgreement_rec.end_date;
--    END IF;
    lp_chrv_rec.date_approved := p_secAgreement_rec.date_approved;

    -- to resolve the validation for sign_by_date
--    lp_chrv_rec.sign_by_date := lp_chrv_rec.end_date;
    lp_chrv_rec.sign_by_date := NULL;
    lp_chrv_rec.currency_code := p_secAgreement_rec.CURRENCY_CODE;

--  set the OKL context from profiles
    OKL_CONTEXT.set_okc_org_context(p_org_id => mo_global.get_current_org_id); --MOAC
    lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
    lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;
--    lp_chrv_rec.inv_organization_id := 204;
--    lp_chrv_rec.currency_code := OKC_CURRENCY_API.GET_OU_CURRENCY(OKL_CONTEXT.GET_OKC_ORG_ID);
    lp_chrv_rec.currency_code_renewed := NULL;
    lp_chrv_rec.template_yn := 'N';
    lp_chrv_rec.chr_type := 'CYA';
    lp_chrv_rec.archived_yn := 'N';
    lp_chrv_rec.deleted_yn := 'N';
    lp_chrv_rec.buy_or_sell := 'S';
    lp_chrv_rec.issue_or_receive := 'I';
--
    lp_khrv_rec.object_version_number := 1.0;
--    lp_khrv_rec.khr_id := 1;
    lp_khrv_rec.generate_accrual_yn := 'Y';
    lp_khrv_rec.generate_accrual_override_yn := 'N';
--
    lp_khrv_rec.PDT_ID := p_secAgreement_rec.PDT_ID;

-- racheruv .. R12.1.2 .. start
    select decode(reporting_pdt_id, NULL, NULL, 'Y')
      into lp_khrv_rec.multi_gaap_yn
      from okl_products
     where id = p_secAgreement_rec.PDT_ID;
-- racheruv .. R12.1.2 end

    lp_khrv_rec.SECURITIZATION_TYPE := p_secAgreement_rec.SECURITIZATION_TYPE;
    IF (p_secAgreement_rec.LESSOR_SERV_ORG_CODE IS NULL OR
        p_secAgreement_rec.LESSOR_SERV_ORG_CODE = OKL_API.G_MISS_CHAR) THEN
      lp_khrv_rec.LESSOR_SERV_ORG_CODE :=  'O';
    ELSE
      lp_khrv_rec.LESSOR_SERV_ORG_CODE := p_secAgreement_rec.LESSOR_SERV_ORG_CODE;
    END IF;
    IF (p_secAgreement_rec.RECOURSE_CODE IS NULL OR p_secAgreement_rec.RECOURSE_CODE = OKL_API.G_MISS_CHAR) THEN
      lp_khrv_rec.RECOURSE_CODE :=  'N';
    ELSE
      lp_khrv_rec.RECOURSE_CODE := p_secAgreement_rec.RECOURSE_CODE;
    END IF;

    lp_khrv_rec.CURRENCY_CONVERSION_TYPE := p_secAgreement_rec.CURRENCY_CONVERSION_TYPE;
    lp_khrv_rec.CURRENCY_CONVERSION_RATE := p_secAgreement_rec.CURRENCY_CONVERSION_RATE;
    lp_khrv_rec.CURRENCY_CONVERSION_DATE := p_secAgreement_rec.CURRENCY_CONVERSION_DATE;
    lp_khrv_rec.AFTER_TAX_YIELD := p_secAgreement_rec.AFTER_TAX_YIELD;

-- arajagop  Begin Changes for Attributes (Flexfield Support)
    lp_khrv_rec.ATTRIBUTE_CATEGORY := p_secAgreement_rec.ATTRIBUTE_CATEGORY;
    lp_khrv_rec.ATTRIBUTE1         := p_secAgreement_rec.ATTRIBUTE1;
    lp_khrv_rec.ATTRIBUTE2         := p_secAgreement_rec.ATTRIBUTE2;
    lp_khrv_rec.ATTRIBUTE3         := p_secAgreement_rec.ATTRIBUTE3;
    lp_khrv_rec.ATTRIBUTE4         := p_secAgreement_rec.ATTRIBUTE4;
    lp_khrv_rec.ATTRIBUTE5         := p_secAgreement_rec.ATTRIBUTE5;
    lp_khrv_rec.ATTRIBUTE6         := p_secAgreement_rec.ATTRIBUTE6;
    lp_khrv_rec.ATTRIBUTE7         := p_secAgreement_rec.ATTRIBUTE7;
    lp_khrv_rec.ATTRIBUTE8         := p_secAgreement_rec.ATTRIBUTE8;
    lp_khrv_rec.ATTRIBUTE9         := p_secAgreement_rec.ATTRIBUTE9;
    lp_khrv_rec.ATTRIBUTE10        := p_secAgreement_rec.ATTRIBUTE10;
    lp_khrv_rec.ATTRIBUTE11        := p_secAgreement_rec.ATTRIBUTE11;
    lp_khrv_rec.ATTRIBUTE12        := p_secAgreement_rec.ATTRIBUTE12;
    lp_khrv_rec.ATTRIBUTE13        := p_secAgreement_rec.ATTRIBUTE13;
    lp_khrv_rec.ATTRIBUTE14        := p_secAgreement_rec.ATTRIBUTE14;
    lp_khrv_rec.ATTRIBUTE15        := p_secAgreement_rec.ATTRIBUTE15;
-- arajagop  End Changes for Attributes (Flexfield Support)
    lp_khrv_rec.legal_entity_id    := p_secAgreement_rec.legal_entity_id;

--
-- Contract header specific validation
--
    x_return_status := validate_header_attributes(p_secAgreement_rec, 'C');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CONTRACT_PUB.validate_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CONTRACT_PUB.create_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_secAgreement_rec.ID := lx_chrv_rec.id;

--
-- ********************* Lessor ***************************************
--

--    x_chr_id := lx_chrv_rec.id;

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := lx_chrv_rec.id;
    lp_cplv_rec.chr_id := lx_chrv_rec.id;
    lp_cplv_rec.cle_id := NULL;
    lp_cplv_rec.object1_id1 := lp_chrv_rec.authoring_org_id;
    lp_cplv_rec.object1_id2 := '#';
    lp_cplv_rec.jtot_object1_code := G_LESSOR_JTOT_OBJECT1_CODE;
    lp_cplv_rec.rle_code := G_LESSOR_RLE_CODE;


    OKC_CONTRACT_PARTY_PUB.validate_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

      okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                     p_init_msg_list  => OKC_API.G_FALSE,
                                                     x_return_status  => x_return_status,
                                                     x_msg_count	   => x_msg_count,
                                                     x_msg_data	   => x_msg_data,
                                                     p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                     p_id1            => lp_cplv_rec.object1_id1,
                                                     p_id2            => lp_cplv_rec.object1_id2);
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

     END IF;

----  Changes End


    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,

      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

--
-- ************************************************************
--
--
-- ********************* Trustee ***************************************
--

--    x_chr_id := lx_chrv_rec.id;

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := lx_chrv_rec.id;
    lp_cplv_rec.chr_id := lx_chrv_rec.id;
    lp_cplv_rec.cle_id := NULL;
    lp_cplv_rec.object1_id1 := p_secAgreement_rec.trustee_object1_id1;
    lp_cplv_rec.object1_id2 := p_secAgreement_rec.trustee_object1_id2;
    lp_cplv_rec.jtot_object1_code := G_TRUSTEE_JTOT_OBJECT1_CODE;
    lp_cplv_rec.rle_code := G_TRUSTEE_RLE_CODE;

    OKC_CONTRACT_PARTY_PUB.validate_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,

      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2


     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
	  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

----  Changes End


    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

--
-- ************************************************************
--
    x_secAgreement_rec.trustee_party_roles_id := lx_cplv_rec.id;

--
-- update okl_pools
--
  l_polv_rec.id := p_secAgreement_rec.pol_id;
  l_polv_rec.khr_id := x_secAgreement_rec.ID;

      OKL_POOL_PVT.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,

        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => x_polv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_sec_agreement_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_sec_agreement_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_sec_agreement_PVT;
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
END;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_sec_agreement
-- Description     : updates a securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_sec_agreement(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_secAgreement_rec             IN secAgreement_rec_type
   ,x_secAgreement_rec             OUT NOCOPY secAgreement_rec_type)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_sec_agreement_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_pol_id           OKL_POOLS.ID%TYPE;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lx_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
  l_polv_rec         polv_rec_type;
  x_polv_rec         polv_rec_type;

  lp_clev_rec         clev_rec_type;
  lx_clev_rec         clev_rec_type;
  lp_klev_rec         klev_rec_type;
  lx_klev_rec         klev_rec_type;
  l_kle_id            okc_k_lines_b.id%TYPE;

 CURSOR c_pool_upd IS
SELECT id
FROM okl_pools
WHERE khr_id = p_secAgreement_rec.id
AND id <> p_secAgreement_rec.pol_id
;

-- mvasudev, 11/04/2003
/*
-- Replacing this by writing two cursors with top line first
-- and sub lines next
CURSOR c_agr_lns(p_khr_id okc_k_headers_b.id%TYPE) IS
SELECT cle.id
FROM  apps.okc_k_lines_b cle
WHERE cle.dnz_chr_id = p_khr_id
;
*/
CURSOR l_okl_top_lines_csr(p_khr_id IN NUMBER)
IS
SELECT clet.id
FROM   okc_k_lines_b clet
WHERE  clet.dnz_chr_id = p_khr_id
AND    clet.cle_id IS NULL;

CURSOR l_okl_sub_lines_csr(p_khr_id IN NUMBER,p_kle_id IN NUMBER)
IS
SELECT cles.id
FROM   okc_k_lines_b cles
WHERE  cles.dnz_chr_id = p_khr_id
AND    cles.cle_id     = p_kle_id;
-- end, mvasudev changes, 11/04/2003

CURSOR role_csr(p_rle_code VARCHAR2)  IS
SELECT  access_level
FROM    OKC_ROLE_SOURCES
WHERE rle_code = p_rle_code
AND     buy_or_sell = 'S';

l_access_level OKC_ROLE_SOURCES.access_level%TYPE;


BEGIN
  -- Set API savepoint
  SAVEPOINT update_sec_agreement_PVT;

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
    lp_chrv_rec.id := p_secAgreement_rec.ID;
    lp_chrv_rec.contract_number := p_secAgreement_rec.CONTRACT_NUMBER;
    lp_chrv_rec.sts_code := p_secAgreement_rec.STS_CODE;
    lp_chrv_rec.description := p_secAgreement_rec.short_description;
    lp_chrv_rec.short_description := p_secAgreement_rec.short_description;
    lp_chrv_rec.start_date := p_secAgreement_rec.start_date;
    lp_chrv_rec.end_date :=  p_secAgreement_rec.end_date;
    lp_chrv_rec.date_approved :=  p_secAgreement_rec.date_approved;

    lp_chrv_rec.currency_code := p_secAgreement_rec.CURRENCY_CODE;
    lp_khrv_rec.PDT_ID := p_secAgreement_rec.PDT_ID;

-- racheruv .. R12.1.2 .. start
    select decode(reporting_pdt_id, NULL, NULL, 'Y')
      into lp_khrv_rec.multi_gaap_yn
      from okl_products a, okl_k_headers b
     where b.pdt_id = a.id
	   and b.id = lp_chrv_rec.id;
-- racheruv .. R12.1.2 end

    lp_khrv_rec.SECURITIZATION_TYPE := p_secAgreement_rec.SECURITIZATION_TYPE;
    lp_khrv_rec.LESSOR_SERV_ORG_CODE := p_secAgreement_rec.LESSOR_SERV_ORG_CODE;
    lp_khrv_rec.RECOURSE_CODE := p_secAgreement_rec.RECOURSE_CODE;

    lp_khrv_rec.CURRENCY_CONVERSION_TYPE := p_secAgreement_rec.CURRENCY_CONVERSION_TYPE;
    lp_khrv_rec.CURRENCY_CONVERSION_RATE := p_secAgreement_rec.CURRENCY_CONVERSION_RATE;
    lp_khrv_rec.CURRENCY_CONVERSION_DATE := p_secAgreement_rec.CURRENCY_CONVERSION_DATE;
    -- added for AFTER_TAX_YIELD akjain,v115.23
    lp_khrv_rec.AFTER_TAX_YIELD := p_secAgreement_rec.AFTER_TAX_YIELD;

-- arajagop  Begin Changes for Attributes (Flexfield Support)
    lp_khrv_rec.ATTRIBUTE_CATEGORY := p_secAgreement_rec.ATTRIBUTE_CATEGORY;
    lp_khrv_rec.ATTRIBUTE1         := p_secAgreement_rec.ATTRIBUTE1;
    lp_khrv_rec.ATTRIBUTE2         := p_secAgreement_rec.ATTRIBUTE2;
    lp_khrv_rec.ATTRIBUTE3         := p_secAgreement_rec.ATTRIBUTE3;
    lp_khrv_rec.ATTRIBUTE4         := p_secAgreement_rec.ATTRIBUTE4;
    lp_khrv_rec.ATTRIBUTE5         := p_secAgreement_rec.ATTRIBUTE5;
    lp_khrv_rec.ATTRIBUTE6         := p_secAgreement_rec.ATTRIBUTE6;
    lp_khrv_rec.ATTRIBUTE7         := p_secAgreement_rec.ATTRIBUTE7;
    lp_khrv_rec.ATTRIBUTE8         := p_secAgreement_rec.ATTRIBUTE8;
    lp_khrv_rec.ATTRIBUTE9         := p_secAgreement_rec.ATTRIBUTE9;
    lp_khrv_rec.ATTRIBUTE10        := p_secAgreement_rec.ATTRIBUTE10;
    lp_khrv_rec.ATTRIBUTE11        := p_secAgreement_rec.ATTRIBUTE11;
    lp_khrv_rec.ATTRIBUTE12        := p_secAgreement_rec.ATTRIBUTE12;
    lp_khrv_rec.ATTRIBUTE13        := p_secAgreement_rec.ATTRIBUTE13;
    lp_khrv_rec.ATTRIBUTE14        := p_secAgreement_rec.ATTRIBUTE14;
    lp_khrv_rec.ATTRIBUTE15        := p_secAgreement_rec.ATTRIBUTE15;
-- arajagop  End Changes for Attributes (Flexfield Support)
    lp_khrv_rec.legal_entity_id    := p_secAgreement_rec.legal_entity_id;

--
-- Contract header specific validation
--
    x_return_status := validate_header_attributes(p_secAgreement_rec, 'U');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- copy back to x_secAgreement_rec

    x_secAgreement_rec.id := lx_chrv_rec.ID;
    x_secAgreement_rec.contract_number := lx_chrv_rec.CONTRACT_NUMBER;
    x_secAgreement_rec.sts_code := lx_chrv_rec.STS_CODE;
    x_secAgreement_rec.short_description := lx_chrv_rec.short_description;
    x_secAgreement_rec.start_date := lx_chrv_rec.start_date;
    x_secAgreement_rec.end_date := lx_chrv_rec.end_date;
    x_secAgreement_rec.date_approved := lx_chrv_rec.date_approved;

    x_secAgreement_rec.currency_code := lx_chrv_rec.CURRENCY_CODE;

    x_secAgreement_rec.PDT_ID := lx_khrv_rec.PDT_ID;
--    x_secAgreement_rec.POL_ID := lx_khrv_rec.POL_ID;
    x_secAgreement_rec.SECURITIZATION_TYPE := lx_khrv_rec.SECURITIZATION_TYPE;
    x_secAgreement_rec.LESSOR_SERV_ORG_CODE := lx_khrv_rec.LESSOR_SERV_ORG_CODE;
    x_secAgreement_rec.RECOURSE_CODE := lx_khrv_rec.RECOURSE_CODE;
    x_secAgreement_rec.CURRENCY_CONVERSION_TYPE := lx_khrv_rec.CURRENCY_CONVERSION_TYPE;
    x_secAgreement_rec.CURRENCY_CONVERSION_RATE := lx_khrv_rec.CURRENCY_CONVERSION_RATE;
    x_secAgreement_rec.CURRENCY_CONVERSION_DATE := lx_khrv_rec.CURRENCY_CONVERSION_DATE;

--
-- ********************* Trustee ***************************************
--
  IF (p_secAgreement_rec.trustee_party_roles_id IS NOT NULL
      AND p_secAgreement_rec.trustee_party_roles_id <> OKL_API.G_MISS_NUM) THEN

--    x_chr_id := lx_chrv_rec.id;

    -- now we attach the party to the header
--    lp_cplv_rec.object_version_number := 1.0;
--    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;

--    lp_cplv_rec.dnz_chr_id := lx_chrv_rec.id;
--    lp_cplv_rec.chr_id := lx_chrv_rec.id;
--    lp_cplv_rec.cle_id := null;
    lp_cplv_rec.id := p_secAgreement_rec.trustee_party_roles_id;
    lp_cplv_rec.object1_id1 := p_secAgreement_rec.trustee_object1_id1;
    lp_cplv_rec.object1_id2 := p_secAgreement_rec.trustee_object1_id2;
--    lp_cplv_rec.jtot_object1_code := G_TRUSTEE_JTOT_OBJECT1_CODE;
--    lp_cplv_rec.rle_code := G_TRUSTEE_RLE_CODE;

    OKC_CONTRACT_PARTY_PUB.validate_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

     END IF;

----  Changes End

    OKC_CONTRACT_PARTY_PUB.update_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- copy back to x_secAgreement_rec
    x_secAgreement_rec.trustee_party_roles_id := lx_cplv_rec.id;
    x_secAgreement_rec.trustee_object1_id1 := lx_cplv_rec.object1_id1;
    x_secAgreement_rec.trustee_object1_id2 := lx_cplv_rec.object1_id2;
    x_secAgreement_rec.trustee_jtot_object1_code := lx_cplv_rec.jtot_object1_code;

  END IF;

--
-- ************************************************************
--

--
-- update okl_pools
--

  IF (p_secAgreement_rec.pol_id IS NOT NULL AND p_secAgreement_rec.pol_id <> OKL_API.G_MISS_NUM) THEN
-- 1. update khr_id to null if user switch to different pol_id

    OPEN c_pool_upd;
    i := 0;
    LOOP
       FETCH c_pool_upd INTO
                l_pol_id;
       EXIT WHEN c_pool_upd%NOTFOUND;

       l_polv_rec.id := l_pol_id;
       l_polv_rec.khr_id := NULL;

      OKL_POOL_PVT.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => x_polv_rec);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

       i := i + 1;
    END LOOP;
    CLOSE c_pool_upd;

-- 2. update khr_id to a specific pool header

    l_polv_rec.id := p_secAgreement_rec.pol_id;
    l_polv_rec.khr_id := p_secAgreement_rec.ID;

      OKL_POOL_PVT.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => x_polv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

-- copy back to x_secAgreement_rec
    x_secAgreement_rec.POL_ID := x_polv_rec.ID;

  END IF;
----------------------------------------------------------------------------
-- update agreement contract header lines end_date = header.end_date
-- cascade update all associated line end_date = header.end_date
-- loop
----------------------------------------------------------------------------
-- mvasudev, commented , 11/04/2003
-- Replacing this by writing two cursors with top line first
-- and sub lines next
/*
  OPEN c_agr_lns(p_secAgreement_rec.ID);
  i := 0;
  LOOP
    FETCH c_agr_lns INTO
                l_kle_id;
    EXIT WHEN c_agr_lns%NOTFOUND;


    lp_klev_rec.id := l_kle_id;
    lp_clev_rec.start_date := p_secAgreement_rec.start_date;
    lp_clev_rec.end_date := p_secAgreement_rec.end_date;
    lp_clev_rec.id := l_kle_id;


    okl_contract_pub.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => lp_clev_rec,
      p_klev_rec      => lp_klev_rec,
      x_clev_rec      => lx_clev_rec,
      x_klev_rec      => lx_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    i := i + 1;
  END LOOP;
  CLOSE c_agr_lns;
  */

  FOR l_okl_top_line_rec IN l_okl_top_lines_csr(p_secAgreement_rec.ID)
  LOOP
      -- Update Top Lines first
      lp_klev_rec.id := l_okl_top_line_rec.id;
      lp_clev_rec.start_date := p_secAgreement_rec.start_date;
      lp_clev_rec.end_date := p_secAgreement_rec.end_date;
      lp_clev_rec.id := l_okl_top_line_rec.id;


      okl_contract_pub.update_contract_line(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_clev_rec      => lp_clev_rec,
        p_klev_rec      => lp_klev_rec,
        x_clev_rec      => lx_clev_rec,
        x_klev_rec      => lx_klev_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    FOR l_okl_sub_line_rec IN l_okl_sub_lines_csr(p_secAgreement_rec.ID,l_okl_top_line_rec.id)
	LOOP
      -- Update Sub Lines next
      lp_klev_rec.id := l_okl_sub_line_rec.id;
      lp_clev_rec.start_date := p_secAgreement_rec.start_date;
      lp_clev_rec.end_date := p_secAgreement_rec.end_date;
      lp_clev_rec.id := l_okl_sub_line_rec.id;


      okl_contract_pub.update_contract_line(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_clev_rec      => lp_clev_rec,
        p_klev_rec      => lp_klev_rec,
        x_clev_rec      => lx_clev_rec,
        x_klev_rec      => lx_klev_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

	END LOOP;
  END LOOP;
  -- end, mvasudev , changes , 11/04/2003

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_sec_agreement_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_sec_agreement_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_sec_agreement_PVT;
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

END;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : activate_sec_agreement
-- Description     : activate a securitization agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE activate_sec_agreement(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN OKC_K_HEADERS_B.ID%TYPE)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'activate_sec_agreement_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_kle_id           OKC_K_LINES_B.ID%TYPE;
  l_pol_id           OKL_POOLS.ID%TYPE;
  l_currency_code    OKL_POOLS.CURRENCY_CODE%TYPE;
  l_org_id           OKL_POOLS.ORG_ID%TYPE;
  l_legal_entity_id  OKL_POOLS.LEGAL_ENTITY_ID%TYPE;
  l_chr_id           OKC_K_HEADERS_B.ID%TYPE;

  l_pox_id           OKL_POOL_CONTENTS.POX_ID%TYPE;
  l_poc_id           OKL_POOL_CONTENTS.ID%TYPE;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;



  lp_secagreement_rec secagreement_rec_type;
  lx_secagreement_rec secagreement_rec_type;
  l_row_found BOOLEAN := FALSE;
  l_row_not_found BOOLEAN := FALSE;
  lp_poxv_rec         poxv_rec_type;
  lx_poxv_rec         poxv_rec_type;
  lp_pocv_rec         pocv_rec_type;
  lx_pocv_rec         pocv_rec_type;
  lp_pocv2_rec         pocv_rec_type;
  lx_pocv2_rec         pocv_rec_type;


CURSOR c_pool IS
SELECT pol.id,
       pol.currency_code,
       pol.org_id,
       pol.legal_entity_id
FROM okl_pools pol
WHERE pol.khr_id = p_khr_id
;

CURSOR c_poc IS
SELECT poc.id
FROM okl_pool_contents poc
WHERE poc.pol_id = l_pol_id
;

-- mvasudev, Fixed bug#3987171
/*
CURSOR c_pool_chr IS
SELECT poc.khr_id
FROM  apps.okl_pool_contents poc
WHERE poc.pol_id = l_pol_id
;
*/
CURSOR c_pool_chr IS
SELECT poc.khr_id
FROM  okl_pool_contents poc
WHERE poc.pol_id = l_pol_id
;

/* ankushar Bug# 6773285 Added Principal Payment for Loan contracts also renamed Cursor
   Start Changes
*/
  -- mvasudev, 10/29/2003
  -- Cursor to check if sty is securitized ">=" effective_date
  CURSOR l_okl_sty_csr IS
  SELECT 1
  FROM   okl_pools polb
	    ,okl_strm_type_b styb
	    ,okl_pool_contents pocb
  WHERE  polb.khr_id = p_khr_id
  AND    pocb.pol_id = polb.id
  AND    pocb.sty_id = styb.id
  AND    styb.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
    AND pocb.status_code='NEW';
/* ankushar Bug# 6773285
   End Changes
*/

BEGIN
  -- Set API savepoint
  SAVEPOINT activate_sec_agreement_PVT;

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

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Begin Activating IA');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug','p_khr_id:'|| p_khr_id);
END IF;

/*** Begin API body ****************************************************/
/* process steps
--1  create a transaction for entire pool by pol_id
--2  update pool contents to point to this transaction
--3  Mark associated contract to securitizated
--4  call Stream Generator API to generate streams for income and expense fees
--5  call Streams Generator API to generate disbursement basis streams
--6  call Streams Generator API to generate PV Streams of Securitized Streams
--7  call Accrual API
--8  call BPD AR api
--9  call generate_journal_entries
--10  call update_sec_agreement_sts to update agreement header, lines
--11 update pool header and contents status to active
*/

----------------------------------------------------------------------------
--1 create a transaction for entire pool by pol_id
-- initial transaction when pool become active
--OKL_POOL_TRANSACTION_TYPE
----------------------------------------------------------------------------
--dbms_output.put_line('1. CREATE a TRANSACTION FOR entire pool BY pol_id');
--dbms_output.put_line('OKL_POOL_PVT.create_pool_transaction START');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '1. CREATE a TRANSACTION FOR entire pool BY pol_id: START');
END IF;
  OPEN c_pool;
  FETCH c_pool INTO l_pol_id,
                    l_currency_code,
                    l_org_id,
		    l_legal_entity_id;
  l_row_found := c_pool%FOUND;
  CLOSE c_pool;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_pol_id :' || l_pol_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_currency_code :' || l_currency_code);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_org_id :' || l_org_id);
END IF;

--dbms_output.put_line('l_pol_id' || l_pol_id);
--dbms_output.put_line('l_currency_code'|| l_currency_code);
--dbms_output.put_line('l_org_id'|| l_org_id);

  IF l_row_found THEN

      lp_poxv_rec.POL_ID := l_pol_id;
      lp_poxv_rec.TRANSACTION_DATE := SYSDATE;
      lp_poxv_rec.TRANSACTION_TYPE := G_POOL_TRX_ADD;
      lp_poxv_rec.TRANSACTION_REASON := G_POOL_TRX_REASON_ACTIVE;
      lp_poxv_rec.CURRENCY_CODE := l_currency_code;
--sosharma 03/12/2007 added to enable status on pool transaction
      lp_poxv_rec.TRANSACTION_STATUS := G_POOL_TRX_STATUS_COMPLETE;
      --added abhsaxen for Legal Entity Uptake
      lp_poxv_rec.LEGAL_ENTITY_ID := l_legal_entity_id;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling okl_pool_pvt.create_pool_transaction');
END IF;

      OKL_POOL_PVT.create_pool_transaction(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_poxv_rec      => lp_poxv_rec,
        x_poxv_rec      => lx_poxv_rec);
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_pol_id :' || l_pol_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'OKL_POOL_PVT.create_pool_transaction x_return_status :' || x_return_status);
END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  END IF;
--dbms_output.put_line('OKL_POOL_PVT.create_pool_transaction END');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'OKL_POOL_PVT.create_pool_transaction: END');
END IF;

----------------------------------------------------------------------------
-- get pox_id after create trx entry
--2. update pool contents to point to this transaction
-- make association between pool transaction and pool contents' records
----------------------------------------------------------------------------
-- loop
--dbms_output.put_line('2. update pool contents to point to this transaction');
--dbms_output.put_line('OKL_POOL_PVT.update_pool_contents Start');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '2. update pool contents to point to this transaction');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling OKL_POOL_PVT.update_pool_contents: START');
END IF;

  OPEN c_poc;
  LOOP
    FETCH c_poc INTO
                l_poc_id;
    EXIT WHEN c_poc%NOTFOUND;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_pol_id :' || l_pol_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_poc_id :' || l_poc_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'lx_poxv_rec.id :' || lx_poxv_rec.id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'lx_poxv_rec.TRANSACTION_NUMBER' ||lx_poxv_rec.TRANSACTION_NUMBER);
END IF;

    lp_pocv_rec.ID := l_poc_id;
    lp_pocv_rec.POL_ID := l_pol_id;
    lp_pocv_rec.POX_ID := lx_poxv_rec.id;
    lp_pocv_rec.TRANSACTION_NUMBER_IN := lx_poxv_rec.TRANSACTION_NUMBER;

    OKL_POOL_PVT.update_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => lp_pocv_rec,
        x_pocv_rec      => lx_pocv_rec);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_poc_id :' || l_poc_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'OKL_POOL_PVT.update_pool_contents x_return_status :' || x_return_status);
END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  END LOOP;
  CLOSE c_poc;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'OKL_POOL_PVT.update_pool_contents : END');
END IF;

--dbms_output.put_line('OKL_POOL_PVT.update_pool_contents End');

----------------------------------------------------------------------------
--3 Mark associated contract to securitizated
----------------------------------------------------------------------------
--dbms_output.put_line('3. Mark associated contract to securtizated');
--dbms_output.put_line('okl_contract_pub.update_contract_header start');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '3. Mark associated contract to securtizated.');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling okl_contract_pub.update_contract_header: START');
END IF;


  OPEN c_pool_chr;
  LOOP
    FETCH c_pool_chr INTO
                l_chr_id;
    EXIT WHEN c_pool_chr%NOTFOUND;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'l_chr_id :' || l_chr_id);
END IF;

    lp_chrv_rec.id := l_chr_id;
    lp_khrv_rec.id := l_chr_id;
    lp_khrv_rec.SECURITIZED_CODE := G_SECURITIZED_CODE_Y;

    okl_contract_pub.update_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_chrv_rec      => lp_chrv_rec,
      p_khrv_rec      => lp_khrv_rec,
      x_chrv_rec      => lx_chrv_rec,
      x_khrv_rec      => lx_khrv_rec);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_contract_pub.update_contract_header x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

  END LOOP;
  CLOSE c_pool_chr;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_contract_pub.update_contract_header: END');
END IF;

-- gboomina added for Bug 6763287 - Start
----------------------------------------------------------------------------
--4 call Streams Generator API to generate streams for income and expense fees
----------------------------------------------------------------------------
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '4 call Streams Generator API to generate streams for income and expense fees: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling okl_stream_generator_pvt.generate_streams_for_IA');
END IF;
OKL_STREAM_GENERATOR_PVT.generate_streams_for_IA(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        p_khr_id            => p_khr_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count  ,
                        x_msg_data          => x_msg_data );

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_stream_generator_pvt.generate_streams_for_IA x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '4 call Streams Generator API to generate streams for income and expense fees: END');
END IF;
-- gboomina added for Bug 6763287 - End
-- added by zrehman for making entry into okl_k_control Bug#6788005 on 07-Feb-2008 start
OKL_BILLING_CONTROLLER_PVT.track_next_bill_date(p_khr_id);
-- added by zrehman for making entry into okl_k_control Bug#6788005 on 07-Feb-2008 end
----------------------------------------------------------------------------

--5 call Streams Generator API to generate disbursement basis streams
--
----------------------------------------------------------------------------
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '5 call Streams Generator API to generate disbursement basis streams.');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling okl_stream_generator_pvt.create_disb_streams: START');
END IF;

OKL_STREAM_GENERATOR_PVT.create_disb_streams(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        p_agreement_id      => p_khr_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count  ,
                        x_msg_data          => x_msg_data );
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_stream_generator_pvt.create_disb_streams x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '5 call Streams Generator API to generate disbursement basis streams: END');
END IF;

----------------------------------------------------------------------------

--6 call Streams Generator API to generate PV Streams of Securitized Streams
--
----------------------------------------------------------------------------
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '6 call Streams Generator API to generate PV Streams of Securitized Streams: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling okl_stream_generator_pvt.create_pv_streams');
END IF;

  OKL_STREAM_GENERATOR_PVT.create_pv_streams(
                                p_api_version       => p_api_version,
                                p_init_msg_list     => p_init_msg_list,
                                p_agreement_id      => p_khr_id,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count  ,
                                x_msg_data          => x_msg_data );
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_stream_generator_pvt.create_pv_streams x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '6 call Streams Generator API to generate PV Streams of Securitized Streams: END');
END IF;


----------------------------------------------------------------------------
--7 call Accrual API
--
----------------------------------------------------------------------------
--dbms_output.put_line('OKL_SECURITIZE_ACCRUAL_PVT.CREATE_STREAMS begin');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '7 call to the Accrual API: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling okl_accrual_sec_pvt.create_streams');
END IF;


--    OKL_SECURITIZE_ACCRUAL_PVT.CREATE_STREAMS(

    -- mvasudev, 10/29/2003
	-- Call the Accrual API only when there are RENT streams
	-- This should loop EXACTLY one time
    FOR l_okl_sty_rent_rec IN l_okl_sty_csr
	LOOP
    OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_khr_id        => p_khr_id);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_stream_generator_pvt.create_pv_streams p_khr_id:' || p_khr_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'okl_stream_generator_pvt.create_pv_streams x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
	-- Fixed Bug#3386816, mvasudev
	EXIT WHEN l_okl_sty_csr%FOUND;
	END LOOP;
    -- mvasudev, end, 10/29/2003
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '7 call to the Accrual API: END');
END IF;

--dbms_output.put_line('OKL_SECURITIZE_ACCRUAL_PVT.CREATE_STREAMS end');
----------------------------------------------------------------------------
--8 call BPD AR api
--
----------------------------------------------------------------------------
--dbms_output.put_line('Okl_Investor_Billing_Pvt.create_investor_bill begin');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '8 call BPD Billing API: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling Okl_Investor_Billing_Pvt.create_investor_bill');
END IF;

    Okl_Investor_Billing_Pvt.create_investor_bill(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_inv_agr       => p_khr_id);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Okl_Investor_Billing_Pvt.create_investor_bill p_khr_id:' || p_khr_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Okl_Investor_Billing_Pvt.create_investor_bill x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '8 call BPD Billing API: END');
END IF;

--dbms_output.put_line('Okl_Investor_Billing_Pvt.create_investor_bill end');

----------------------------------------------------------------------------
--9 call generate_journal_entries
--
----------------------------------------------------------------------------
--dbms_output.put_line('generate_journal_entries begin');
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '9 call to the generate_journal_entries: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling generate_journal_entries');
END IF;

    generate_journal_entries(
      p_api_version          => p_api_version,
      p_init_msg_list        => p_init_msg_list,
      x_return_status        => x_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_contract_id          => p_khr_id
     ,p_transaction_type     => G_TRY_TYPE_INV);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Okl_Investor_Billing_Pvt.create_investor_bill x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '9 call to the generate_journal_entries: END');
END IF;

--dbms_output.put_line('generate_journal_entries end');
----------------------------------------------------------------------------
--10 call update_sec_agreement_sts to update agreement header, lines
--
----------------------------------------------------------------------------
--dbms_output.put_line('OKL_SEC_AGREEMENT_PVT.update_sec_agreement_sts begin');

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '10 call update_sec_agreement_sts to update agreement header, lines: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling Okl_Sec_Agreement_Pvt.update_sec_agreement_sts');
END IF;

    Okl_Sec_Agreement_Pvt.update_sec_agreement_sts(
      p_api_version           => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_sec_agreement_status  => G_STS_CODE_ACTIVE,
      p_sec_agreement_id      => p_khr_id);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Okl_Sec_Agreement_Pvt.update_sec_agreement_sts x_return_status :' || x_return_status);
END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '10 call update_sec_agreement_sts to update agreement header, lines: END');
END IF;
--dbms_output.put_line('OKL_SEC_AGREEMENT_PVT.update_sec_agreement_sts end');

----------------------------------------------------------------------------
--11 update pool header and contents status to active
----------------------------------------------------------------------------
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '11 update pool header and contents status to active: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'Calling OKL_POOL_PVT.update_pool_status_active');
END IF;

    OKL_POOL_PVT.update_pool_status_active(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pol_id        => l_pol_id);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'OKL_POOL_PVT.update_pool_status_active x_return_status :' || x_return_status);
END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', '11 update pool header and contents status to active: END');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_sec_agreement.debug', 'End of Activating IA, completed Successfully');
END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO activate_sec_agreement_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO activate_sec_agreement_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO activate_sec_agreement_PVT;
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

END activate_sec_agreement;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_sec_agreement_sts
-- Description     : updates a securitization agreement header, all lines status
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_sec_agreement_sts(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_sec_agreement_status         IN okc_k_headers_b.sts_code%TYPE
   ,p_sec_agreement_id             IN okc_k_headers_b.id%TYPE)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_sec_agreement_sts';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_kle_id           OKC_K_LINES_B.ID%TYPE;
  l_chr_id           OKC_K_HEADERS_B.ID%TYPE;

  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  lp_secagreement_rec secagreement_rec_type;
  lx_secagreement_rec secagreement_rec_type;
  l_row_found BOOLEAN := FALSE;
  l_row_not_found BOOLEAN := FALSE;

  lp_clev_rec         clev_rec_type;
  lx_clev_rec         clev_rec_type;
  lp_klev_rec         klev_rec_type;
  lx_klev_rec         klev_rec_type;

  lp_khrv_rec         khrv_rec_type;
  lx_khrv_rec         khrv_rec_type;
  lp_chrv_rec         chrv_rec_type;
  lx_chrv_rec         chrv_rec_type;
-- mvasudev, Fixed bug#3987171
/*
CURSOR c_agr_lns IS
SELECT cle.id
FROM  apps.okc_k_lines_b cle
WHERE cle.dnz_chr_id = p_sec_agreement_id
;
*/
CURSOR c_agr_lns IS
SELECT cle.id
FROM  okc_k_lines_b cle
WHERE cle.dnz_chr_id = p_sec_agreement_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_sec_agreement_sts_PVT;

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
----------------------------------------------------------------------------
--1. update agreement contract header status
----------------------------------------------------------------------------
--dbms_output.put_line('1. update agreement contract header status');
--dbms_output.put_line('OKL_SEC_AGREEMENT_PVT.update_sec_agreement start');

  lp_secagreement_rec.ID := p_sec_agreement_id;
  lp_secagreement_rec.STS_CODE := p_sec_agreement_status;

    Okl_Sec_Agreement_Pvt.update_sec_agreement(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_secagreement_rec => lp_secagreement_rec,
      x_secagreement_rec => lx_secagreement_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--dbms_output.put_line('OKL_SEC_AGREEMENT_PVT.update_sec_agreement end');

----------------------------------------------------------------------------
--2. update agreement contract header lines status
-- cascade update all associated line sts_code to active
-- loop
----------------------------------------------------------------------------
--dbms_output.put_line('2. update agreement contract header lines status');
--dbms_output.put_line('okl_contract_pub.update_contract_line start');

  OPEN c_agr_lns;
  LOOP
    FETCH c_agr_lns INTO
                l_kle_id;
    EXIT WHEN c_agr_lns%NOTFOUND;


    lp_klev_rec.id := l_kle_id;
    lp_clev_rec.STS_CODE := p_sec_agreement_status;
    lp_clev_rec.id := l_kle_id;

    okl_contract_pub.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => lp_clev_rec,
      p_klev_rec      => lp_klev_rec,
      x_clev_rec      => lx_clev_rec,
      x_klev_rec      => lx_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

  END LOOP;
  CLOSE c_agr_lns;
--dbms_output.put_line('okl_contract_pub.update_contract_line start');

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_sec_agreement_sts_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_sec_agreement_sts_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_sec_agreement_sts_PVT;
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

END update_sec_agreement_sts;

  --Added by kthiruva on 18-Dec-2007
  -- New method to validate an add request on an active investor agreement
  --Bug 6691554 - Start of Changes
  Procedure validate_add_request(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  NUMBER)
  IS
    --Declaring local variables
    l_stream_value            NUMBER;
    l_api_name		CONSTANT VARCHAR2(30) := 'validate_add_request';
    l_api_version	CONSTANT NUMBER	      := 1.0;


    CURSOR get_pol_id_csr(p_chr_id NUMBER)
	IS
	SELECT ID
	FROM OKL_POOLS
	WHERE KHR_ID = p_chr_id
	AND STATUS_CODE = 'ACTIVE';

	l_pol_id         NUMBER;
    x_reconciled     VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;


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

    FOR get_pol_id_rec IN get_pol_id_csr(p_chr_id)
    LOOP
      l_pol_id := get_pol_id_rec.id;
    END LOOP;

    IF l_pol_id IS NULL
    THEN
       Okl_Api.set_message(G_APP_NAME,
                           G_INVALID_VALUE,
                           G_COL_NAME_TOKEN,
                           'POOL_ID');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OKL_POOL_PVT.get_tot_recei_amt_pend(
                   p_api_version   => '1.0',
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   x_value         => l_stream_value,
                   p_pol_id        => l_pol_id );

    If( l_stream_value IS NULL OR l_stream_value = 0 ) Then
        OKL_API.set_message(
             p_app_name     => G_APP_NAME,
             p_msg_name     => 'OKL_QA_STREAM_VALUE');
        -- notify caller of an error but do not raise an exception
        x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    --Check to see if the pool recquires reconcilation
    OKL_POOL_PVT.reconcile_contents(
                                p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_pol_id => l_pol_id,
                                p_mode   => 'ACTIVE',
                                x_reconciled => x_reconciled );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF ( x_reconciled = OKL_API.G_TRUE ) Then
        x_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.set_message(
                    p_app_name      => G_APP_NAME,
                    p_msg_name      => 'OKL_LLA_RECONCILED');
        raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);


  EXCEPTION
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


  END validate_add_request;

  Procedure activate_add_request (
    		p_api_version         IN NUMBER
     		,p_init_msg_list      IN VARCHAR2
    		,x_return_status      OUT NOCOPY VARCHAR2
    		,x_msg_count          OUT NOCOPY NUMBER
   	    	,x_msg_data           OUT NOCOPY VARCHAR2
   		    ,p_khr_id             IN OKC_K_HEADERS_B.ID%TYPE)
  IS

	l_api_name         CONSTANT VARCHAR2(30) := 'activate_add_request';
    l_api_version      CONSTANT NUMBER       := 1.0;
    i                  NUMBER;
    l_kle_id           OKC_K_LINES_B.ID%TYPE;
    l_pol_id           OKL_POOLS.ID%TYPE;
    l_currency_code    OKL_POOLS.CURRENCY_CODE%TYPE;
    l_org_id           OKL_POOLS.ORG_ID%TYPE;
    l_legal_entity_id  OKL_POOLS.LEGAL_ENTITY_ID%TYPE;
    l_chr_id           OKC_K_HEADERS_B.ID%TYPE;

    l_pox_id           OKL_POOL_CONTENTS.POX_ID%TYPE;
    l_poc_id           OKL_POOL_CONTENTS.ID%TYPE;
    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;



    lp_secagreement_rec secagreement_rec_type;
    lx_secagreement_rec secagreement_rec_type;
    l_row_found BOOLEAN := FALSE;
    l_row_not_found BOOLEAN := FALSE;
    lp_poxv_rec         poxv_rec_type;
    lx_poxv_rec         poxv_rec_type;
    lp_pocv_rec         pocv_rec_type;
    lx_pocv_rec         pocv_rec_type;
    lp_pocv2_rec         pocv_rec_type;
    lx_pocv2_rec         pocv_rec_type;


    CURSOR c_pool_csr(p_khr_id NUMBER)
	IS
    SELECT pol.id
    FROM okl_pools pol
    WHERE pol.khr_id = p_khr_id;

    CURSOR c_pool_chr_csr(p_pol_id NUMBER)
	IS
    SELECT poc.khr_id,
           poc.id
    FROM  okl_pool_contents poc
    WHERE poc.pol_id = p_pol_id
	AND poc.status_code = Okl_Pool_Pvt.G_POC_STS_PENDING;

/* ankushar Bug# 6773285 Added Principal Payment for Loan contracts also renamed Cursor
   Start Changes
*/
    -- mvasudev, 10/29/2003
    -- Cursor to check if sty is securitized ">=" effective_date
    CURSOR l_okl_sty_csr(p_khr_id NUMBER)
	IS
    SELECT 1
    FROM   okl_pools polb
	      ,okl_strm_type_b styb
	      ,okl_pool_contents pocb
    WHERE  polb.khr_id = p_khr_id
    AND    pocb.pol_id = polb.id
    AND    pocb.sty_id = styb.id
  AND    styb.stream_type_purpose IN ('RENT', 'PRINCIPAL_PAYMENT')
  AND pocb.status_code='PENDING';
/* ankushar Bug# 6773285
   End Changes
*/
   	CURSOR get_pox_csr(p_pol_id NUMBER)
	IS
	SELECT POX.ID
	FROM OKL_POOL_TRANSACTIONS POX
	WHERE POX.POL_ID = p_pol_id
	AND POX.TRANSACTION_STATUS = 'APPROVED'
	AND POX.TRANSACTION_TYPE = 'ADD'
	AND POX.TRANSACTION_REASON = 'ADJUSTMENTS';

	--Cursor to fetch the investor stake
	--Cursor to fetch the investor stake
	CURSOR get_inv_stake_csr(p_khr_id NUMBER)
	IS
    SELECT TOP_KLE.ID,
           TOP_KLE.AMOUNT original_Stake,
           TOP_KLE.AMOUNT_STAKE additional_Stake
    FROM OKC_K_LINES_B        TOP_LINE,
         OKL_K_LINES          TOP_KLE,
         OKC_K_PARTY_ROLES_B  PARTY_ROLE
    WHERE TOP_LINE.dnz_chr_id       = p_khr_id
    AND   TOP_KLE.ID                = TOP_LINE.ID
    AND   PARTY_ROLE.cle_id         = TOP_LINE.id
    AND   PARTY_ROLE.dnz_chr_id     = TOP_LINE.dnz_chr_id
    AND   PARTY_ROLE.rle_code       = 'INVESTOR'
    AND   PARTY_ROLE.jtot_object1_code = 'OKX_PARTY';

	l_clev_rec    clev_rec_type;
    l_klev_rec    klev_rec_type;
	lx_clev_rec    clev_rec_type;
    lx_klev_rec    klev_rec_type;

  BEGIN
    -- Set API savepoint
    SAVEPOINT activate_add_request_pvt;

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

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Begin Processing Add Request');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug','p_khr_id:'|| p_khr_id);
    END IF;

    /*** Begin API body ****************************************************/
    /* process steps
    --1  Validate the add request
    --2  Mark associated contract to securitizated
    --3  call Streams Generator API to generate disbursement basis streams
    --4  call Streams Generator API to generate PV Streams of Securitized Streams
    --5  call Accrual API
    --6  call generate_journal_entries
    --7  call BPD AR api
    --8 update pool header and contents status to active
    --9 Update the stake amount per investor and clear out the amount_stake field

    */

    ----------------------------------------------------------------------------
    --1 Validate the add request
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '1. Validate the add request.');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling validate_add_request: START');
    END IF;

    --Fetch the pool id from the Investor Agreement Id passed
    FOR c_pool_rec IN c_pool_csr(p_khr_id)
    LOOP
      l_pol_id := c_pool_rec.id;
    END LOOP;

    IF l_pol_id IS NULL
    THEN
       Okl_Api.set_message(G_APP_NAME,
                           G_INVALID_VALUE,
                           G_COL_NAME_TOKEN,
                           'POOL_ID');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    --Fetch the transaction id of the Pool Transaction
    FOR get_pox_rec IN get_pox_csr(l_pol_id)
    LOOP
      l_pox_id := get_pox_rec.id;
    END LOOP;

    IF l_pox_id IS NULL
    THEN
       Okl_Api.set_message(G_APP_NAME,
                           G_INVALID_VALUE,
                           G_COL_NAME_TOKEN,
                           'POX_ID');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    validate_add_request(
            p_api_version     => p_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_chr_id          => p_khr_id);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'validate_add_request x_return_status :' || x_return_status);
    END IF;

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
	   --Update the status of the Pool Transaction to INCOMPLETE and Halt processing
       lp_poxv_rec.id := l_pox_id;
       lp_poxv_rec.TRANSACTION_STATUS := G_POOL_TRX_STATUS_INCOMPLETE;

       OKL_POOL_PVT.update_pool_transaction(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_poxv_rec      => lp_poxv_rec,
                                         x_poxv_rec      => lx_poxv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --Stop submit processing
       RAISE G_HALT_PROCESSING;
    END IF;


    ----------------------------------------------------------------------------
    --2 Mark associated contract to securitizated
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '2. Mark associated contract to securtizated.');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling okl_contract_pub.update_contract_header: START');
    END IF;

    OPEN c_pool_chr_csr(l_pol_id);
    LOOP
      FETCH c_pool_chr_csr INTO l_chr_id,l_poc_id;
      EXIT WHEN c_pool_chr_csr%NOTFOUND;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'l_chr_id :' || l_chr_id);
      END IF;

      lp_chrv_rec.id := l_chr_id;
      lp_khrv_rec.id := l_chr_id;
      lp_khrv_rec.SECURITIZED_CODE := G_SECURITIZED_CODE_Y;

      okl_contract_pub.update_contract_header(
         p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_chrv_rec      => lp_chrv_rec,
         p_khrv_rec      => lp_khrv_rec,
         x_chrv_rec      => lx_chrv_rec,
         x_khrv_rec      => lx_khrv_rec);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'okl_contract_pub.update_contract_header x_return_status :' || x_return_status);
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;
    CLOSE c_pool_chr_csr;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'okl_contract_pub.update_contract_header: END');
    END IF;


    ----------------------------------------------------------------------------

    -- 3. call Streams Generator API to generate disbursement basis streams
    --
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '3 call Streams Generator API to generate disbursement basis streams.');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling okl_stream_generator_pvt.create_disb_streams: START');
    END IF;

    OKL_STREAM_GENERATOR_PVT.create_disb_streams(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        p_agreement_id      => p_khr_id,
                        p_pool_status       => 'ACTIVE',
                        p_mode              => 'ACTIVE',
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count  ,
                        x_msg_data          => x_msg_data );

	IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'okl_stream_generator_pvt.create_disb_streams x_return_status :' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '3 call Streams Generator API to generate disbursement basis streams: END');
    END IF;

    ----------------------------------------------------------------------------

    --4 call Streams Generator API to generate PV Streams of Securitized Streams
    --
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '4 call Streams Generator API to generate PV Streams of Securitized Streams: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling okl_stream_generator_pvt.create_pv_streams');
    END IF;

    OKL_STREAM_GENERATOR_PVT.create_pv_streams(
                                p_api_version       => p_api_version,
                                p_init_msg_list     => p_init_msg_list,
                                p_agreement_id      => p_khr_id,
                                p_pool_status       => 'ACTIVE',
                                p_mode              => 'ACTIVE',
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count  ,
                                x_msg_data          => x_msg_data );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'okl_stream_generator_pvt.create_pv_streams x_return_status :' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '4 call Streams Generator API to generate PV Streams of Securitized Streams: END');
    END IF;


    ----------------------------------------------------------------------------
    --5 call Accrual API
    --
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '5 call to the Accrual API: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling okl_accrual_sec_pvt.create_streams');
    END IF;


    -- mvasudev, 10/29/2003
    -- Call the Accrual API only when there are RENT streams
    -- This should loop EXACTLY one time
    FOR l_okl_sty_rent_rec IN l_okl_sty_csr(p_khr_id)
    LOOP
      OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS(
       p_api_version   => p_api_version,
       p_init_msg_list => p_init_msg_list,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_khr_id        => p_khr_id,
	   p_mode          => 'ACTIVE');

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'okl_stream_generator_pvt.create_pv_streams p_khr_id:' || p_khr_id);
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'okl_stream_generator_pvt.create_pv_streams x_return_status :' || x_return_status);
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
	  -- Fixed Bug#3386816, mvasudev
	  EXIT WHEN l_okl_sty_csr%FOUND;
    END LOOP;
    -- mvasudev, end, 10/29/2003
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '5 call to the Accrual API: END');
    END IF;

    ----------------------------------------------------------------------------
    --6 call generate_journal_entries
    --
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '6 call to the generate_journal_entries: START');
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling generate_journal_entries');
    END IF;

    generate_journal_entries(
      p_api_version          => p_api_version,
      p_init_msg_list        => p_init_msg_list,
      x_return_status        => x_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_contract_id          => p_khr_id
     ,p_transaction_type     => G_TRY_TYPE_INV);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'generate_journal_entries x_return_status :' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '6 call to the generate_journal_entries: END');
    END IF;

    ----------------------------------------------------------------------------
    --7 call BPD AR api
    --
    ----------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '7 call BPD Billing API: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling Okl_Investor_Billing_Pvt.create_investor_bill');
    END IF;

    Okl_Investor_Billing_Pvt.create_investor_bill(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_inv_agr       => p_khr_id);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Okl_Investor_Billing_Pvt.create_investor_bill p_khr_id:' || p_khr_id);
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Okl_Investor_Billing_Pvt.create_investor_bill x_return_status :' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '7 call BPD Billing API: END');
    END IF;

    --Update the total stake to include the additional stake
    FOR get_inv_stake_rec IN get_inv_stake_csr(p_khr_id)
    LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'OKL_CONTRACT_PUB.update_contract_line');
      END IF;

      --Only if an additional stake amount has been captured, then add this stake to the original stake
      IF get_inv_stake_rec.additional_stake IS NOT NULL THEN
        l_clev_rec.id           := get_inv_stake_rec.id;
        l_klev_rec.id           := get_inv_stake_rec.id;
        l_klev_rec.amount       := get_inv_stake_rec.original_stake + get_inv_stake_rec.additional_stake;
        l_klev_rec.amount_stake := NULL;

        OKL_CONTRACT_PUB.update_contract_line(
          p_api_version        => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_clev_rec           => l_clev_rec,
          p_klev_rec           => l_klev_rec,
          x_clev_rec           => lx_clev_rec,
          x_klev_rec           => lx_klev_rec);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Okl_Sec_Investor_Pvt.update_investor' || x_return_status);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END LOOP;




    ----------------------------------------------------------------------------------
    --8 update pool contents status to active and pool transactions status to COMPLETE
    ----------------------------------------------------------------------------------
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '8 update pool contents status to active: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling OKL_POOL_PVT.update_pool_contents');
    END IF;

    --Update pool contents to ACTIVE
    FOR c_pool_chr_rec IN c_pool_chr_csr(l_pol_id)
    LOOP
      lp_pocv_rec.id          := c_pool_chr_rec.id;
      lp_pocv_rec.status_code := Okl_Pool_Pvt.G_POC_STS_ACTIVE;

      Okl_Pool_Pvt.update_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => lp_pocv_rec,
        x_pocv_rec      => lx_pocv_rec);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'OKL_POOL_PVT.update_pool_status_active x_return_status :' || x_return_status);
      END IF;


      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
	  END IF;
    END LOOP;


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', '8 update pool transaction to Complete: START');
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Calling OKL_POOL_PVT.update_pool_transaction');
    END IF;

    --Update pool transaction to COMPLETE
	lp_poxv_rec.id := l_pox_id;
    lp_poxv_rec.TRANSACTION_STATUS := G_POOL_TRX_STATUS_COMPLETE;

    OKL_POOL_PVT.update_pool_transaction(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_poxv_rec      => lp_poxv_rec,
                                         x_poxv_rec      => lx_poxv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'OKL_POOL_PVT.update_pool_transaction x_return_status :' || x_return_status);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'Update investor stake');
    END IF;

    /*** End API body ******************************************************/

    -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
      (p_count          =>      x_msg_count,
       p_data           =>      x_msg_data);

  EXCEPTION
  --For this User defined exception, do not rollback
  WHEN G_HALT_PROCESSING THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO activate_add_request_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO activate_add_request_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);
  WHEN OTHERS THEN
	ROLLBACK TO activate_add_request_pvt;
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


  END activate_add_request;

  -- Bug 6691554 - End of Changes

 -------------------------------------------------------------------------------------------------
 -- PROCEDURE submit_add_khr_request
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_add_khr_request
  -- Description     :
  -- Business Rules  : Submit the Add Contracts Request for Approval.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, , p_agreement_id, p_pool_id, x_pool_trx_status.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE submit_add_khr_request (p_api_version     IN  NUMBER,
                                    p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                    x_return_status   OUT NOCOPY VARCHAR2,
                                    x_msg_count       OUT NOCOPY NUMBER,
                                    x_msg_data        OUT NOCOPY VARCHAR2,
                                    p_agreement_id    IN  OKC_K_HEADERS_V.ID%TYPE,
                                    p_pool_id         IN  OKL_POOLS.ID%TYPE,
                                    x_pool_trx_status OUT NOCOPY OKL_POOL_TRANSACTIONS.TRANSACTION_STATUS%TYPE)
  IS
    -- Get Pool Transaction Details
    CURSOR c_fetch_pool_trans_id_csr(p_transaction_id  OKL_POOLS.ID%TYPE)
    IS
    SELECT pox.id
    FROM okl_pool_transactions pox
    WHERE pox.pol_id = p_pool_id
    AND pox.TRANSACTION_STATUS IN (G_POOL_TRX_STATUS_NEW, G_POOL_TRX_STS_APPR_REJECTED, G_POOL_TRX_STATUS_INCOMPLETE);

    l_return_status    VARCHAR2(3);
    l_api_name         CONSTANT VARCHAR2(30) := 'submit_add_khr_request';
    l_parameter_list   wf_parameter_list_t;
    l_key              VARCHAR2(240);
    l_event_name       VARCHAR2(240) := 'oracle.apps.okl.ia.approve_add_contracts_request';
    l_agreement_id     OKC_K_HEADERS_V.ID%TYPE;
    l_pool_id          OKL_POOLS.ID%TYPE;
    l_pool_trans_id    OKL_POOL_TRANSACTIONS.ID%TYPE;
    lp_poxv_rec        poxv_rec_type;
    lx_poxv_rec        poxv_rec_type;
    l_approval_process fnd_lookups.lookup_code%TYPE;
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

  BEGIN

    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pool_id       := p_pool_id;
    l_agreement_id  := p_agreement_id;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--      fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.submit_add_khr_request.debug', 'Okl_Sec_Agreement_Pvt.submit_add_khr_request x_return_status :' || x_return_status);

    -- read the profile OKL: Investor Add Contracts Approval Process
    l_approval_process := fnd_profile.value('OKL_IA_ADD_KHR_APPR_PROCESS');

    -- get the pool transaction id which needs to be updated, since we can have only one transaction in 'NEW' status
    OPEN c_fetch_pool_trans_id_csr(p_pool_id);
     FETCH c_fetch_pool_trans_id_csr into l_pool_trans_id;
      IF c_fetch_pool_trans_id_csr%NOTFOUND THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_NO_MATCHING_RECORD,
		                          p_token1       => G_COL_NAME_TOKEN,
		                          p_token1_value => 'OKL_POOL_TRANSACTIONS.ID');
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;
     CLOSE c_fetch_pool_trans_id_csr ;

     --Set the Pool Transaction Id for the update call
     lp_poxv_rec.ID      := l_pool_trans_id;

    -- basic validation. API call should be in status passed before it can be submitted for approval
   /* Place the Validation API Call here :TODO */
   validate_add_request(p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        l_msg_count,
                        l_msg_data,
                        l_agreement_id);
    IF (x_return_status <>  OKL_API.G_RET_STS_SUCCESS) THEN
      lp_poxv_rec.TRANSACTION_STATUS    := G_POOL_TRX_STATUS_INCOMPLETE;

      OKL_POOL_PVT.update_pool_transaction(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_poxv_rec      => lp_poxv_rec,
                                         x_poxv_rec      => lx_poxv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   --Since the Validation returned an Error need to raise an exception and return the control,
   --no further processing needs to be done.
      RAISE G_HALT_PROCESSING;

    END IF; --x_return_status <>  OKL_API.G_RET_STS_SUCCESS

    IF(NVL(l_approval_process, 'NONE')) = 'NONE' THEN
       -- since no option is set at the profile, approve the operating agreement by default
       lp_poxv_rec.TRANSACTION_STATUS    := G_POOL_TRX_STATUS_APPROVED;

      OKL_POOL_PVT.update_pool_transaction(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_poxv_rec      => lp_poxv_rec,
                                         x_poxv_rec      => lx_poxv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSIF(l_approval_process IN (G_ADD_KHR_REQUEST_APPROVAL_WF, G_ADD_KHR_REQUEST_APPRV_AME))THEN

  --  We need to status to Approved Pending since We are sending for approval
      lp_poxv_rec.TRANSACTION_STATUS    := G_POOL_TRX_STATUS_PENDING_APPR;

      OKL_POOL_PVT.update_pool_transaction(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_poxv_rec      => lp_poxv_rec,
                                           x_poxv_rec      => lx_poxv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Raise Event
       OKL_SEC_AGREEMENT_WF.raise_add_khr_approval_event(p_api_version    => p_api_version
                                                         ,p_init_msg_list  => p_init_msg_list
                                                         ,x_return_status  => x_return_status
                                                         ,x_msg_count      => x_msg_count
                                                         ,x_msg_data       => x_msg_data
                                                         ,p_agreement_id   => l_agreement_id
                                                         ,p_pool_id        => l_pool_id
                                                         ,p_pool_trans_id  => l_pool_trans_id);

       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   END IF; -- end of NVL(l_approval_process,'NONE')='NONE'

   OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                        x_msg_data   => x_msg_data);
  EXCEPTION
  --For this User defined exception, do not rollback
    WHEN G_HALT_PROCESSING THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count         =>      l_msg_count,
                                p_data          =>      l_msg_data);

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF c_fetch_pool_trans_id_csr%ISOPEN THEN
        CLOSE c_fetch_pool_trans_id_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF c_fetch_pool_trans_id_csr%ISOPEN THEN
        CLOSE c_fetch_pool_trans_id_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      IF c_fetch_pool_trans_id_csr%ISOPEN THEN
        CLOSE c_fetch_pool_trans_id_csr;
      END IF;
      -- store SQL error message on message stack
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END submit_add_khr_request;
  /*
   19-Dec-2007, ankushar Bug# 6691554
   endchanges
  */

   /* sosharma 03-01-2008
Added procedure to cancel the add request on active Investor Agreement
Start changes*/


  Procedure cancel_add_request(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  OKC_K_HEADERS_B.ID%TYPE)
  IS
    --Declaring local variables
    l_api_name		CONSTANT VARCHAR2(30) := 'cancel_add_request';
    l_api_version	CONSTANT NUMBER	      := 1.0;


 CURSOR get_pol_id_csr(p_chr_id NUMBER)
  IS
  SELECT ID
  FROM OKL_POOLS
  WHERE KHR_ID = p_chr_id
  AND STATUS_CODE = 'ACTIVE';

 CURSOR get_pox_id_csr(p_pol_id NUMBER)
  IS
  SELECT ID
  FROM OKL_POOL_TRANSACTIONS
  WHERE pol_id = p_pol_id
  AND TRANSACTION_STATUS <> 'COMPLETE';


   CURSOR get_pol_contents_csr(p_pox_id NUMBER)
  IS
  SELECT ID
  FROM OKL_POOL_CONTENTS
  WHERE pox_id = p_pox_id
  AND STATUS_CODE <> 'ACTIVE';


CURSOR get_inv_stake_csr(p_khr_id NUMBER)
	IS
    SELECT TOP_KLE.ID,
           TOP_KLE.AMOUNT original_Stake,
           TOP_KLE.AMOUNT_STAKE additional_Stake
    FROM OKC_K_LINES_B        TOP_LINE,
         OKL_K_LINES          TOP_KLE,
         OKC_K_PARTY_ROLES_B  PARTY_ROLE
    WHERE TOP_LINE.dnz_chr_id       = p_khr_id
    AND   TOP_KLE.ID                = TOP_LINE.ID
    AND   PARTY_ROLE.cle_id         = TOP_LINE.id
    AND   PARTY_ROLE.dnz_chr_id     = TOP_LINE.dnz_chr_id
    AND   PARTY_ROLE.rle_code       = 'INVESTOR'
    AND   PARTY_ROLE.jtot_object1_code = 'OKX_PARTY';


	l_pol_id         NUMBER;
 l_pox_id         NUMBER;
 i                NUMBER;
 l_pocv_tbl       OKL_POC_PVT.pocv_tbl_type;
 l_poxv_rec       OKL_POX_PVT.poxv_rec_type;
 l_clev_rec    clev_rec_type;
 l_klev_rec    klev_rec_type;
 lx_clev_rec    clev_rec_type;
 lx_klev_rec    klev_rec_type;



  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;


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

    FOR get_pol_id_rec IN get_pol_id_csr(p_chr_id)
    LOOP
      l_pol_id := get_pol_id_rec.id;
    END LOOP;

    IF l_pol_id IS NULL
    THEN
       Okl_Api.set_message(G_APP_NAME,
                           G_INVALID_VALUE,
                           G_COL_NAME_TOKEN,
                           'POOL_ID');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    FOR get_pox_id_rec IN get_pox_id_csr(l_pol_id)
    LOOP
      l_pox_id := get_pox_id_rec.id;
    END LOOP;

    IF l_pox_id IS NULL
    THEN
       Okl_Api.set_message(G_APP_NAME,
                           G_INVALID_VALUE,
                           G_COL_NAME_TOKEN,
                           'POX_ID');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

-- create table of pool contents to be deleted
     i:=0;
    FOR get_pol_contents_rec IN get_pol_contents_csr(l_pox_id)
    LOOP
      l_pocv_tbl(i).id:= get_pol_contents_rec.id;
      i:=i+1;
    END LOOP;

-- delete pool contents
           OKL_POC_PVT.delete_row(
                                p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_pocv_tbl => l_pocv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- Assign pool transaction to be deleted to the record

l_poxv_rec.id:= l_pox_id;

--delete pool transactions

           OKL_POX_PVT.delete_row(
                                p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_poxv_rec => l_poxv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--Update the additional stake on removing transaction
    FOR get_inv_stake_rec IN get_inv_stake_csr(p_chr_id)
    LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.activate_add_request.debug', 'OKL_CONTRACT_PUB.update_contract_line');
      END IF;


      --Remove the additional stake amount
      IF get_inv_stake_rec.additional_stake IS NOT NULL THEN
        l_clev_rec.id           := get_inv_stake_rec.id;
        l_klev_rec.id           := get_inv_stake_rec.id;
        l_klev_rec.amount_stake := NULL;

        OKL_CONTRACT_PUB.update_contract_line(
          p_api_version        => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_clev_rec           => l_clev_rec,
          p_klev_rec           => l_klev_rec,
          x_clev_rec           => lx_clev_rec,
          x_klev_rec           => lx_klev_rec);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_statement,'okl.plsql.okl_sec_agreement_pvt.cancel_add_request.debug', 'Okl_Sec_Investor_Pvt.update_investor' || x_return_status);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END LOOP;



    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);


  EXCEPTION
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


  END cancel_add_request;
  /*sosharma end changes*/


END Okl_Sec_Agreement_Pvt;

/
