--------------------------------------------------------
--  DDL for Package Body OKL_MULTIGAAP_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MULTIGAAP_ENGINE_PVT" AS
/* $Header: OKLRMGEB.pls 120.0.12010000.14 2009/10/08 11:23:43 rpillay noship $ */

 G_PRIMARY   CONSTANT VARCHAR2(200) := 'PRIMARY';
 G_SECONDARY  CONSTANT VARCHAR2(200) := 'SECONDARY';
 G_SPLIT_ASSET CONSTANT VARCHAR2(200) := 'SPLIT_ASSET';
 G_TERMINATION CONSTANT VARCHAR2(200) := 'TERMINATION';
 G_EVERGREEN CONSTANT VARCHAR2(200) := 'EVERGREEN';
 G_API_TYPE  CONSTANT  VARCHAR2(4) := '_PVT';

 --Bug# 7698532
  G_MODULE VARCHAR2(255) := 'LEASE.ACCOUNTING.MGENGINE';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON BOOLEAN ;
 --Bug# 7698532

 -- Start of comments
--
-- Procedure Name  : get_reporting_product
-- Description     : This procedure checks if there is a reporting product attached to the contract and returns
--                   the deal type of the reporting product and MG reporting book
-- Business Rules  :
-- Parameters      :  p_contract_id - Contract ID
-- Version         : 1.0
-- History         : sechawla 12-Dec-07  - 6671849 Created
-- End of comments

PROCEDURE get_reporting_product(p_api_version           IN  	NUMBER,
           		 	 p_init_msg_list        IN  	VARCHAR2,
           			 x_return_status        OUT 	NOCOPY VARCHAR2,
           			 x_msg_count            OUT 	NOCOPY NUMBER,
           			 x_msg_data             OUT 	NOCOPY VARCHAR2,
                                 p_contract_id 	        IN 	NUMBER,
                                 x_rep_product_id       OUT   NOCOPY VARCHAR2) IS

  -- Get the financial product of the contract
  CURSOR l_get_fin_product(cp_khr_id IN NUMBER) IS
  SELECT a.start_date, a.contract_number, b.pdt_id
  FROM   okc_k_headers_b a, okl_k_headers b
  WHERE  a.id = b.id
  AND    a.id = cp_khr_id;

  SUBTYPE pdtv_rec_type IS OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
  SUBTYPE pdt_parameters_rec_type IS OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

  l_fin_product_id          NUMBER;
  l_start_date              DATE;
  lp_pdtv_rec               pdtv_rec_type;
  lp_empty_pdtv_rec         pdtv_rec_type;
  lx_no_data_found          BOOLEAN;
  lx_pdt_parameter_rec      pdt_parameters_rec_type ;
  l_contract_number         VARCHAR2(120);

  --mg_error                  EXCEPTION;
  l_reporting_product       OKL_PRODUCTS_V.NAME%TYPE;
  l_reporting_product_id    NUMBER;

  BEGIN
    -- get the financial product of the contract
    OPEN  l_get_fin_product(p_contract_id);
    FETCH l_get_fin_product INTO l_start_date, l_contract_number, l_fin_product_id;
    CLOSE l_get_fin_product;

    lp_pdtv_rec.id := l_fin_product_id;

    -- check if the fin product has a reporting product
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version => p_api_version,
  				  			               p_init_msg_list                => OKL_API.G_FALSE,
    						                       x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);

    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        -- Error getting financial product parameters for contract CONTRACT_NUMBER.
        OKL_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FIN_PROD_PARAM_ERR',
                           p_token1        =>  'CONTRACT_NUMBER',
                           p_token1_value  =>  l_contract_number);

    ELSE

        l_reporting_product := lx_pdt_parameter_rec.reporting_product;
        l_reporting_product_id := lx_pdt_parameter_rec.reporting_pdt_id;

        IF l_reporting_product IS NOT NULL AND l_reporting_product <> OKL_API.G_MISS_CHAR THEN
            -- Contract has a reporting product
            x_rep_product_id :=  l_reporting_product_id;
        END IF;
    END IF;
  EXCEPTION
      --WHEN mg_error THEN
      --   IF l_get_fin_product%ISOPEN THEN
      --      CLOSE l_get_fin_product;
      --   END IF;
      --   x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
         IF l_get_fin_product%ISOPEN THEN
            CLOSE l_get_fin_product;
         END IF;
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END get_reporting_product;

  ---------------------------------------------------------------------------
  -- FUNCTION is_srm_automated
  -- checks whether secondary representation method is AUTOMATED
  ---------------------------------------------------------------------------
FUNCTION is_srm_automated RETURN BOOLEAN IS
  l_is_srm_automated  VARCHAR2(1) := 'N';

  CURSOR is_srm_automated IS
  SELECT 'Y'
  FROM OKL_SYS_ACCT_OPTS
  WHERE secondary_rep_method IN ('AUTOMATED');

BEGIN
  --get batch id for conc requests from seq
  OPEN is_srm_automated;
  FETCH is_srm_automated INTO l_is_srm_automated;
  CLOSE is_srm_automated;

  IF(l_is_srm_automated = 'Y') THEN
   RETURN true;
  END IF;

 RETURN false;

EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END is_srm_automated;

  ---------------------------------------------------------------------------
  -- FUNCTION is_mg_enabled
  -- checks whether contract is multigaap enabled
  ---------------------------------------------------------------------------
FUNCTION is_mg_enabled(p_khr_id NUMBER) RETURN BOOLEAN IS
   l_is_mg_enabled  VARCHAR2(1) := 'N';

  CURSOR is_mg_enabled IS
  SELECT NVL(KHR.MULTI_GAAP_YN,'N')
  FROM OKL_K_HEADERS KHR
  WHERE ID = p_khr_id;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  --get batch id for conc requests from seq
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'is_mg_enabled begin....');

  OPEN is_mg_enabled;
  FETCH is_mg_enabled INTO l_is_mg_enabled;
  CLOSE is_mg_enabled;

  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_is_mg_enabled'|| NVL(l_is_mg_enabled,'X'));
  IF(l_is_mg_enabled = 'Y') THEN
   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'inside if condition');
   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'is_mg_enabled end');
   RETURN true;
  END IF;

  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'is_mg_enabled end');

 RETURN false;

EXCEPTION
  WHEN OTHERS THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'is_mg_enabled Exception block');
    RETURN false;
  END is_mg_enabled;

---------------------------------------------------------------------------
  -- FUNCTION get_secondary_representations
  -- retunrns secondary representation code
  ---------------------------------------------------------------------------
  FUNCTION get_secondary_rep_code RETURN VARCHAR2 IS
  l_representation_code okl_representations_v.representation_code%type := null;

  CURSOR get_secondary_rep_code IS
  select representation_code
  from okl_representations_v
  where representation_type = G_SECONDARY;
  BEGIN

    OPEN get_secondary_rep_code;
    FETCH get_secondary_rep_code INTO l_representation_code;
    CLOSE get_secondary_rep_code;

    RETURN(l_representation_code);
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
  END get_secondary_rep_code;

  FUNCTION is_formula_based(p_id NUMBER) RETURN BOOLEAN IS
   l_is_formula_based  VARCHAR2(1) := 'N';

  CURSOR is_formula_based IS
    select nvl(typ.FORMULA_YN,'N')
    from okl_trx_contracts khr,
         okl_trx_types_b typ
    where  khr.try_id=typ.id
    and khr.id = p_id;
  BEGIN
     -- checks whether transaction type is formala based
  OPEN is_formula_based;
  FETCH is_formula_based INTO l_is_formula_based;
  CLOSE is_formula_based;

  IF(l_is_formula_based = 'Y') THEN
   RETURN true;
  END IF;

 RETURN false;

EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
  END is_formula_based;

  FUNCTION is_line_based(p_id NUMBER) RETURN BOOLEAN IS
  l_trx_type_class okl_trx_types_b.trx_type_class%type := null;

  CURSOR is_line_based IS
  select trx_type_class
  from okl_trx_contracts khr,
       okl_trx_types_b typ
  where  khr.try_id=typ.id
  and khr.id = p_id;
  BEGIN
     -- checks whether transaction type is contract based or line based.
     -- transaction types Termination, Evergreen, and Split Asset  are line based
  OPEN is_line_based;
  FETCH is_line_based INTO l_trx_type_class;
  CLOSE is_line_based;

  IF( (l_trx_type_class = G_SPLIT_ASSET) OR (l_trx_type_class = G_TERMINATION) OR (l_trx_type_class = G_EVERGREEN ))
  THEN
   RETURN true;
  END IF;

 RETURN false;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
  END is_line_based;

  -- below function is used for formula
  FUNCTION null_out_primary_trx_defaults (
    p_tcnv_rec	IN tcnv_rec_type
  ) RETURN tcnv_rec_type IS
    l_tcnv_rec	tcnv_rec_type := p_tcnv_rec;
  BEGIN

    l_tcnv_rec.object_version_number := NULL;
    l_tcnv_rec.pdt_id := NULL;
    l_tcnv_rec.set_of_books_id := NULL;
    l_tcnv_rec.REPRESENTATION_CODE := NULL;
    l_tcnv_rec.REPRESENTATION_NAME := null;
    l_tcnv_rec.BOOK_CLASSIFICATION_CODE := null;
    l_tcnv_rec.TAX_OWNER_CODE := null;
    l_tcnv_rec.PRODUCT_NAME := null;

   RETURN(l_tcnv_rec);
  END null_out_primary_trx_defaults;


  PROCEDURE set_secondary_trx_attribs(
                                 p_api_version           IN  	NUMBER,
                                 p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           			 x_return_status         OUT 	NOCOPY VARCHAR2,
           			 x_msg_count             OUT 	NOCOPY NUMBER,
           			 x_msg_data              OUT 	NOCOPY VARCHAR2,
                                 p_tcnv_rec	         IN     tcnv_rec_type,
                                 x_tcnv_tbl              OUT    NOCOPY tcnv_tbl_type)
  IS

    l_api_version NUMBER := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'set_secondary_trx_attribs';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found BOOLEAN := TRUE;

    CURSOR get_secondary_rep_code_csr IS
    select representation_code,representation_name
    from okl_representations_v
    where representation_type = G_SECONDARY;

    i NUMBER := 0;
    l_tcnv_rec	tcnv_rec_type := p_tcnv_rec;
    l_tcnv_tbl	tcnv_tbl_type ;

    l_rep_product_id okl_product_parameters_v.id%type := null;
    l_REPRESENTATION_CODE okl_representations_v.representation_code%type :=null;
    l_REPRESENTATION_name okl_representations_v.representation_name%type :=null;
    l_set_of_books_id  OKL_SYS_ACCT_OPTS.set_of_books_id%type := null;
    l_formula_yn boolean := false;

    lp_pdtv_rec OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    lp_pdt_param_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    lx_pdtv_rec OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    lx_pdt_param_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

BEGIN

    get_reporting_product( p_api_version     => l_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => l_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_contract_id     => l_tcnv_rec.khr_id,
                         x_rep_product_id  => l_rep_product_id);

   IF (l_rep_product_id IS NULL) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'PDT_ID');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   lp_pdtv_rec.id := l_rep_product_id;
   OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
           p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => l_return_status,
      	   x_no_data_found => x_no_data_found,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
      	   p_pdtv_rec      => lp_pdtv_rec,
      	   p_product_date  => NULL,
      	   p_pdt_parameter_rec => lx_pdt_param_rec);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   l_set_of_books_id := Okl_Accounting_util.get_set_of_books_id(G_SECONDARY);
   IF (l_set_of_books_id IS NULL) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'SET_OF_BOOKS_ID');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_formula_yn := is_formula_based (l_tcnv_rec.id);
   IF(l_formula_yn) THEN
      l_tcnv_rec.amount := NULL;
   END IF;

  l_tcnv_rec.primary_rep_trx_id := l_tcnv_rec.id;
  l_tcnv_rec.id := NULL;

  FOR get_secondary_rep_code IN get_secondary_rep_code_csr LOOP
    i := i + 1;
    l_representation_code := null;
    l_representation_name := null;
    l_representation_code := get_secondary_rep_code.representation_code;
    l_representation_name := get_secondary_rep_code.representation_name;
    IF (l_representation_code IS NULL) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'REPRESENTATION_CODE');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_representation_name IS NULL ) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'REPRESENTATION_NAME');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_tcnv_tbl(i) := l_tcnv_rec;
    --l_tcnv_tbl(i).trx_number := null;
    l_tcnv_tbl(i).TSU_CODE := 'ENTERED';
    l_tcnv_tbl(i).pdt_id := l_rep_product_id;
    l_tcnv_tbl(i).set_of_books_id := l_set_of_books_id;
    l_tcnv_tbl(i).REPRESENTATION_CODE := l_representation_code;
    l_tcnv_tbl(i).REPRESENTATION_NAME := l_representation_name;
    l_tcnv_tbl(i).REPRESENTATION_TYPE := G_SECONDARY;
    l_tcnv_tbl(i).BOOK_CLASSIFICATION_CODE := lx_pdt_param_rec.Deal_Type;
    l_tcnv_tbl(i).TAX_OWNER_CODE := lx_pdt_param_rec.tax_owner;
    l_tcnv_tbl(i).PRODUCT_NAME := lx_pdt_param_rec.name;

  END LOOP;

  x_tcnv_tbl := l_tcnv_tbl;
  x_return_status := l_return_status;

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


END set_secondary_trx_attribs;

PROCEDURE CREATE_SEC_REP_TRX (
          P_API_VERSION                  IN NUMBER,
          P_INIT_MSG_LIST                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY NUMBER,
          X_MSG_DATA                     OUT NOCOPY VARCHAR2,
          P_TCNV_REC                     OKL_TCN_PVT.TCNV_REC_TYPE,
          P_TCLV_TBL                     OKL_TCL_PVT.TCLV_TBL_TYPE,
          p_ctxt_val_tbl                 Okl_Account_Dist_Pvt.CTXT_TBL_TYPE,
          p_acc_gen_primary_key_tbl      OKL_ACCOUNT_DIST_PVT.acc_gen_primary_key --SGIYER
   ) IS

  l_api_version NUMBER := 1.0;
  l_api_name  CONSTANT VARCHAR2(30) := 'CREATE_SEC_REP_TRX';
  l_row_notfound  BOOLEAN := TRUE;
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_try_id      NUMBER := 0;

  l_pri_trx_tcnv_rec    tcnv_rec_type := p_tcnv_rec;
  l_pri_trx_id NUMBER := p_tcnv_rec.id;

  l_sec_trx_tcnv_tbl    tcnv_tbl_type;
  x_sec_trx_tcnv_tbl    tcnv_tbl_type;

  l_pri_trx_tclv_rec    tclv_rec_type := p_tclv_tbl(1);

  l_sec_trx_tclv_tbl    tclv_tbl_type; --SGIYER := p_tclv_tbl;
  x_sec_trx_tclv_tbl    tclv_tbl_type ;

  CURSOR prdt_csr (l_pdt_id OKL_PRODUCTS.ID%TYPE) IS
  SELECT name
  FROM okl_products
  WHERE id = l_pdt_id ;

  CURSOR trx_type_csr (l_trx_type_id OKL_TRX_TYPES_TL.ID%TYPE) IS
  SELECT name
  FROM okl_trx_types_tl
  WHERE id = l_trx_type_id ;

  CURSOR sty_type_csr (l_sty_type_id OKL_STRM_TYPE_TL.ID%TYPE) IS
  SELECT name
  FROM okl_strm_type_tl
  WHERE id = l_sty_type_id ;

  CURSOR get_kle_ids_csr (l_id NUMBER) IS
  select distinct lns.kle_id
  from okl_trx_contracts khr,
       OKL_TXL_CNTRCT_LNS lns
  where khr.id = l_id
  and khr.id = lns.tcn_id;

  l_formula_yn boolean := false;
  l_is_line_based boolean := false;
  l_trx_type_name okl_trx_types_b.trx_type_class%type := null;
  i NUMBER := 0;
  k NUMBER := 0;
  j NUMBER := 0;
  m NUMBER := 0;

  l_valid_gl_date date;

  -- get template infofor acc dist
  l_tmpl_identify_rec  Okl_Account_Dist_Pvt.tmpl_identify_rec_type;
  l_template_tbl       Okl_Account_Dist_Pvt.AVLV_TBL_TYPE;

  l_tmpl_identify_tbl  Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
  l_dist_info_tbl      Okl_Account_Dist_Pvt.dist_info_tbl_TYPE;
  l_ctxt_val_tbl       OKL_ACCOUNT_DIST_PVT.CTXT_VAL_TBL_TYPE;
  l_acc_gen_tbl        Okl_Account_Dist_Pvt.acc_gen_tbl_type; --SGIYER := p_acc_gen_primary_key_tbl;
  x_template_tbl       Okl_Account_Dist_Pvt.AVLV_OUT_TBL_TYPE;
  x_amount_out_tbl     Okl_Account_Dist_Pvt.AMOUNT_OUT_TBL_TYPE;

  l_acc_gen_primary_key_tbl   OKL_ACCOUNT_DIST_PVT.acc_gen_primary_key := p_acc_gen_primary_key_tbl; --SGIYER
  l_amount_tbl                Okl_Account_Dist_Pvt.AMOUNT_TBL_TYPE;
  l_ctxt_tbl                  Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;

  CURSOR l_contract_currency_csr IS
     SELECT  currency_code,
             currency_conversion_rate,
             currency_conversion_type,
             currency_conversion_date
     FROM    okl_k_headers_full_v
     WHERE   id = l_pri_trx_tclv_rec.khr_id ;

  l_currency_conversion_rate   okl_k_headers_full_v.currency_conversion_rate%TYPE := null;
  l_currency_conversion_type   okl_k_headers_full_v.currency_conversion_type%TYPE := null;
  l_currency_conversion_date   okl_k_headers_full_v.currency_conversion_date%TYPE := null;
  l_curr_code   GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE := null;

  l_sty_id number := null;
  l_contract_start_date date :=null;

  CURSOR cntrct_csr (p_khr_id NUMBER)IS
  SELECT start_date
  FROM   okl_k_headers_full_v
  WHERE id = p_khr_id;

  --Bug# 8969376
  CURSOR get_primary_sty_id_csr
         (p_pdt_id number,
          p_strm_purpose okl_strm_type_v.stream_type_purpose%type,
          p_contract_start_date date)  IS
  SELECT PRIMARY_STY_ID
  FROM   OKL_STRM_TMPT_LINES_UV STL
  WHERE --STL.PRIMARY_YN = 'Y' AND
         STL.PDT_ID = p_pdt_id
  AND    (STL.START_DATE <= p_contract_start_date)
  AND    (STL.END_DATE >= p_contract_start_date OR STL.END_DATE IS NULL)
  AND	 PRIMARY_STY_PURPOSE =   p_strm_purpose;

  CURSOR get_dependent_sty_id_csr
         (p_pdt_id number,
          p_strm_purpose okl_strm_type_v.stream_type_purpose%type,
          p_contract_start_date date)  IS
  SELECT DEPENDENT_STY_ID
  FROM   OKL_STRM_TMPT_LINES_UV STL
  WHERE --STL.PRIMARY_YN = 'Y' AND
         STL.PDT_ID = p_pdt_id
  AND    (STL.START_DATE <= p_contract_start_date)
  AND    (STL.END_DATE >= p_contract_start_date OR STL.END_DATE IS NULL)
  AND	 DEPENDENT_STY_PURPOSE = p_strm_purpose;
  --Bug# 8969376


BEGIN

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

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


  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to is_srm_automated');
   END IF;

   IF NOT (is_srm_automated()) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Secondary representation method is not automated, returning...');
    RETURN;
   END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to is_srm_automated');
   END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to is_mg_enabled:'||to_char(l_pri_trx_tcnv_rec.khr_id));
   END IF;

   IF NOT (is_mg_enabled(l_pri_trx_tcnv_rec.khr_id)) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Multi gaap is not enabled, returning...');
    RETURN;
   END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to is_mg_enabled');
   END IF;


    -- null out the primary trx attributes which are not applicable to secondary trx
    l_pri_trx_tcnv_rec := null_out_primary_trx_defaults (l_pri_trx_tcnv_rec);


  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to set_secondary_trx_attribs');
   END IF;


    -- set secondary transaction attributes
    set_secondary_trx_attribs( p_api_version  => l_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count  => x_msg_count,
                         x_msg_data  => x_msg_data,
                         p_tcnv_rec  => l_pri_trx_tcnv_rec,
                         x_tcnv_tbl  => l_sec_trx_tcnv_tbl);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to set_secondary_trx_attribs, the return status is :'||x_return_status);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


   -- create the secondary transaction header
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_TRX_CONTRACTS_PUB.create_trx_contracts');
   END IF;


   OKL_TRX_CONTRACTS_PUB.create_trx_contracts(p_api_version   => l_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_tcnv_rec      => l_sec_trx_tcnv_tbl(1),
                                              x_tcnv_rec      => x_sec_trx_tcnv_tbl(1));

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_TRX_CONTRACTS_PUB.create_trx_contracts, the return status is :'||x_return_status);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to okl_accounting_util.get_valid_gl_date');
   END IF;

    -- SGIYER.12/08/08.Get valid GL date for template info and AE
    l_valid_gl_date := okl_accounting_util.get_valid_gl_date
                              (p_gl_date => l_sec_trx_tcnv_tbl(1).date_transaction_occurred,
                               p_ledger_id => l_sec_trx_tcnv_tbl(1).set_of_books_id);

    IF (l_valid_gl_date is null) THEN
       	    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_INVALID_GL_DATE');
             RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_TRX_CONTRACTS_PUB.create_trx_contracts'||to_char(l_valid_gl_date));
   END IF;

  -- FOR m IN 1.. x_sec_trx_tcnv_tbl.COUNT -- this for loop is to handle multiple secondary trxs
  -- LOOP
   -- is_formula_based
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to is_formula_based');
   END IF;

   l_formula_yn := is_formula_based (l_pri_trx_id);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to is_formula_based');
   END IF;

    IF(l_formula_yn) THEN        -- get the amount from acc engine and update the secondary trx hdr and lines

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to is_formula_based TRUE');
   END IF;

       l_tmpl_identify_rec.product_id := x_sec_trx_tcnv_tbl(1).pdt_id;
       l_tmpl_identify_rec.transaction_type_id  :=  x_sec_trx_tcnv_tbl(1).try_id;
       l_tmpl_identify_rec.memo_yn  :=  'N';
       l_tmpl_identify_rec.prior_year_yn  :=  'N';

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO');
   END IF;

       OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO(p_api_version => l_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_tmpl_identify_rec => l_tmpl_identify_rec,
                        x_template_tbl => l_template_tbl,
                        p_validity_date => l_valid_gl_date); -- SGIYER-12/08/08.

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO, the return status is :'||l_return_status);
   END IF;
        -- Raise an error if template is not found.

        IF (l_template_tbl.COUNT = 0) THEN
            FOR trx_type_rec IN trx_type_csr (l_tmpl_identify_rec.transaction_type_id) LOOP
              l_trx_type_name := trx_type_rec.name;
            END LOOP;
       	    Okl_Api.set_message(p_app_name       => g_app_name,
                               p_msg_name       => 'OKL_LA_NO_ACCOUNTING_TMPLTS',
                               p_token1         => 'TRANSACTION_TYPE',
                               p_token1_value   => l_trx_type_name);
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

     -- chekc if the transaction line or contract based
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to is_line_based');
   END IF;
     l_is_line_based := is_line_based(l_pri_trx_id);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to is_line_based');
   END IF;

     IF( l_is_line_based ) THEN -- that is trans type termination, split, evergreen

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to is_line_based TRUE');
   END IF;
     -- read all the distinct kle ids of primary trx lines and create  kle ids * acc tmpl
      FOR get_kle_ids_rec IN  get_kle_ids_csr( l_pri_trx_id )  LOOP

           -- read all the accounting template lines and assign to secondary trx lines
           FOR k IN l_template_tbl.first..l_template_tbl.LAST LOOP

             -- bug 7625968. SGIYER - 12/09/2008
             -- Changed variable from 'k' to 'j' in the tbl l_sec_trx_tclv_tbl
             j := j + 1;
             l_sec_trx_tclv_tbl(j).khr_id := l_pri_trx_tcnv_rec.khr_id;
             l_sec_trx_tclv_tbl(j).tcl_type := l_pri_trx_tclv_rec.tcl_type;
             l_sec_trx_tclv_tbl(j).kle_id := get_kle_ids_rec.kle_id;
             l_sec_trx_tclv_tbl(j).tcn_id := x_sec_trx_tcnv_tbl(1).id;
             l_sec_trx_tclv_tbl(j).id := null;
             l_sec_trx_tclv_tbl(j).line_number := j;
             l_sec_trx_tclv_tbl(j).OBJECT_VERSION_NUMBER := null;
             l_sec_trx_tclv_tbl(j).amount := null;
             l_sec_trx_tclv_tbl(j).STY_ID := l_template_tbl(k).sty_id;
             l_sec_trx_tclv_tbl(j).currency_code := x_sec_trx_tcnv_tbl(1).currency_code;

             --Bug 7625968. brough the below inside the loop.
             l_tmpl_identify_tbl(j).product_id := l_tmpl_identify_rec.product_id;
             l_tmpl_identify_tbl(j).transaction_type_id := l_tmpl_identify_rec.transaction_type_id;
             l_tmpl_identify_tbl(j).memo_yn := l_tmpl_identify_rec.memo_yn;
             l_tmpl_identify_tbl(j).prior_year_yn := l_tmpl_identify_rec.prior_year_yn;
             l_tmpl_identify_tbl(j).stream_type_id := l_template_tbl(k).sty_id;
             l_tmpl_identify_tbl(j).advance_arrears := l_template_tbl(k).advance_arrears;
             l_tmpl_identify_tbl(j).factoring_synd_flag := l_template_tbl(k).factoring_synd_flag;
             l_tmpl_identify_tbl(j).investor_code := l_template_tbl(k).inv_code;
             l_tmpl_identify_tbl(j).syndication_code := l_template_tbl(k).syt_code;
             l_tmpl_identify_tbl(j).factoring_code := l_template_tbl(k).fac_code;

           END LOOP;

      END LOOP;

     ELSE     -- for all the other trx types
       j := 0;
        -- read all the accounting template lines and assign to secondary trx lines
        -- we do not need
         FOR k IN l_template_tbl.FIRST..l_template_tbl.LAST LOOP
            j := j + 1;
            l_sec_trx_tclv_tbl(j) := l_pri_trx_tclv_rec;
            l_sec_trx_tclv_tbl(j).id := null;
            l_sec_trx_tclv_tbl(j).line_number := k;
            l_sec_trx_tclv_tbl(j).OBJECT_VERSION_NUMBER := null;
            l_sec_trx_tclv_tbl(j).amount := null;
            l_sec_trx_tclv_tbl(j).sty_id := l_template_tbl(k).sty_id;
            l_sec_trx_tclv_tbl(j).tcn_id := x_sec_trx_tcnv_tbl(1).id;
            l_sec_trx_tclv_tbl(j).currency_code := x_sec_trx_tcnv_tbl(1).currency_code;

             --Bug 7625968. brough the below inside the loop.
             l_tmpl_identify_tbl(j).product_id := l_tmpl_identify_rec.product_id;
             l_tmpl_identify_tbl(j).transaction_type_id := l_tmpl_identify_rec.transaction_type_id;
             l_tmpl_identify_tbl(j).memo_yn := l_tmpl_identify_rec.memo_yn;
             l_tmpl_identify_tbl(j).prior_year_yn := l_tmpl_identify_rec.prior_year_yn;
             l_tmpl_identify_tbl(j).stream_type_id := l_template_tbl(k).sty_id;
             l_tmpl_identify_tbl(j).advance_arrears := l_template_tbl(k).advance_arrears;
             l_tmpl_identify_tbl(j).factoring_synd_flag := l_template_tbl(k).factoring_synd_flag;
             l_tmpl_identify_tbl(j).investor_code := l_template_tbl(k).inv_code;
             l_tmpl_identify_tbl(j).syndication_code := l_template_tbl(k).syt_code;
             l_tmpl_identify_tbl(j).factoring_code := l_template_tbl(k).fac_code;

         END LOOP;

     END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines');
       END IF;

         -- create the secondary transaction lines for each acc tmpl
         OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines
                        (p_api_version     => l_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => l_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_tclv_tbl        => l_sec_trx_tclv_tbl,
                         x_tclv_tbl        => x_sec_trx_tclv_tbl);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines :'||l_return_status);
         END IF;

         --  accounting distributiions

         OPEN l_contract_currency_csr;
         FETCH l_contract_currency_csr INTO  l_curr_code, l_currency_conversion_rate,l_currency_conversion_type, l_currency_conversion_date ;
         CLOSE l_contract_currency_csr;

          IF( l_curr_code IS NULL ) THEN
                            OKL_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => G_REQUIRED_VALUE,
                           p_token1        =>  g_col_name_token,
                           p_token1_value  =>  'CURRENCY_CODE');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          FOR i IN x_sec_trx_tclv_tbl.FIRST..x_sec_trx_tclv_tbl.LAST LOOP

            l_dist_info_tbl(i).SOURCE_ID                  := x_sec_trx_tclv_tbl(i).ID;
            l_dist_info_tbl(i).SOURCE_TABLE               := 'OKL_TXL_CNTRCT_LNS';
            l_dist_info_tbl(i).GL_REVERSAL_FLAG           := 'N';
            l_dist_info_tbl(i).POST_TO_GL                 := 'Y';
            l_dist_info_tbl(i).CONTRACT_ID                := l_pri_trx_tcnv_rec.KHR_ID;
            l_dist_info_tbl(i).CONTRACT_LINE_ID           := x_sec_trx_tclv_tbl(i).KLE_ID; -- Bug 7626121
            l_dist_info_tbl(i).CURRENCY_CONVERSION_RATE   := l_currency_conversion_rate;
            l_dist_info_tbl(i).CURRENCY_CONVERSION_TYPE   := l_currency_conversion_type;
            l_dist_info_tbl(i).CURRENCY_CONVERSION_DATE   := l_currency_conversion_date;
            l_dist_info_tbl(i).CURRENCY_CODE              := l_curr_code;
            l_dist_info_tbl(i).ACCOUNTING_DATE            := l_valid_gl_date;
            l_dist_info_tbl(i).amount                     := x_sec_trx_tclv_tbl(i).amount;

            --Assigning the account generator table.SGIYER
            l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
            l_acc_gen_tbl(i).source_id :=  x_sec_trx_tclv_tbl(i).ID;

            IF (l_ctxt_val_tbl.COUNT > 0) THEN
              l_ctxt_tbl(i).source_id := x_sec_trx_tclv_tbl(i).id;
            END IF;

          END LOOP;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST');
       END IF;

          OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST(
                         p_api_version             => l_api_version,
                         p_init_msg_list           => p_init_msg_list,
                         x_return_status           => l_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data,
                         p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                         p_dist_info_tbl           => l_dist_info_tbl,
                         p_ctxt_val_tbl            => l_ctxt_tbl,
                         p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                         x_template_tbl            => x_template_tbl,
                         x_amount_tbl              => x_amount_out_tbl,
                         p_trx_header_id           => x_sec_trx_tcnv_tbl(1).id);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST :'||l_return_status);
         END IF;

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         If x_sec_trx_tclv_tbl.COUNT > 0 then
         FOR i in x_sec_trx_tclv_tbl.FIRST..x_sec_trx_tclv_tbl.LAST LOOP
          l_amount_tbl.delete;
          If x_amount_out_tbl.COUNT > 0 then
              For k in x_amount_out_tbl.FIRST..x_amount_out_tbl.LAST LOOP
                  IF x_sec_trx_tclv_tbl(i).id = x_amount_out_tbl(k).source_id THEN
                      l_amount_tbl := x_amount_out_tbl(k).amount_tbl;
                      x_sec_trx_tclv_tbl(i).currency_code := l_curr_code;
                      IF l_amount_tbl.COUNT > 0 THEN
                          FOR j in l_amount_tbl.FIRST..l_amount_tbl.LAST LOOP
                              x_sec_trx_tclv_tbl(i).amount := nvl(x_sec_trx_tclv_tbl(i).amount,0)  + l_amount_tbl(j);
                          END LOOP; -- for j in
                      END IF;-- If l_amount_tbl.COUNT
                   END IF; ---- IF x_sec_trx_tclv_tbl(i).id
              END LOOP; -- For k in
          END IF; -- If l_amount_out_tbl.COUNT
          x_sec_trx_tcnv_tbl(1).amount := nvl(x_sec_trx_tcnv_tbl(1).amount,0) + x_sec_trx_tclv_tbl(i).amount;
         -- l_tcnv_rec.currency_code := l_currency_code;
         -- l_tcnv_rec.tsu_code      := 'PROCESSED';
         END LOOP; -- For i in
         End If; -- If l_tclv_tbl.COUNT

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines');
       END IF;
         --Update the lines with the amount
         OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines
                        (p_api_version     => l_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_tclv_tbl        => x_sec_trx_tclv_tbl,
                         x_tclv_tbl        => l_sec_trx_tclv_tbl);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines :'||x_return_status);
         END IF;

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --Update the header with the amount
         x_sec_trx_tcnv_tbl(1).tsu_code := 'PROCESSED';
         x_sec_trx_tcnv_tbl(1).amount := x_sec_trx_tcnv_tbl(1).amount;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_TRX_CONTRACTS_PUB.update_trx_contracts');
       END IF;

         OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version   => l_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_tcnv_rec      => x_sec_trx_tcnv_tbl(1),
                                              x_tcnv_rec      => x_sec_trx_tcnv_tbl(1));


         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_TRX_CONTRACTS_PUB.update_trx_contracts :'||x_return_status);
         END IF;

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

   ELSE

         -- if not formula then do not null out the amt and
         -- copy the lines as is from the primary  trx hdr onto secondary trx lines
         -- first get sty id, get the purpose code of the primary, then query

           l_sec_trx_tclv_tbl    := p_tclv_tbl;

         FOR i IN l_sec_trx_tclv_tbl.FIRST..l_sec_trx_tclv_tbl.LAST  LOOP

            l_sec_trx_tclv_tbl(i).id := null;
            l_sec_trx_tclv_tbl(i).tcn_id := x_sec_trx_tcnv_tbl(1).id;
            l_sec_trx_tclv_tbl(i).object_version_number := null;


            l_sty_id := null;
            l_contract_start_date := null;

            OPEN cntrct_csr (l_sec_trx_tcnv_tbl(1).khr_id);
            FETCH cntrct_csr INTO l_contract_start_date;
            CLOSE cntrct_csr;

            IF l_contract_start_date IS NULL THEN
              OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'CONTRACT_START_DATE');

              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --Bug# 8969376
            open get_primary_sty_id_csr(l_sec_trx_tcnv_tbl(1).pdt_id, l_sec_trx_tclv_tbl(i).stream_type_purpose, l_contract_start_date);
            fetch get_primary_sty_id_csr into l_sty_id;
            close get_primary_sty_id_csr;

            IF( l_sty_id IS NULL ) THEN
              open get_dependent_sty_id_csr(l_sec_trx_tcnv_tbl(1).pdt_id, l_sec_trx_tclv_tbl(i).stream_type_purpose, l_contract_start_date);
              fetch get_dependent_sty_id_csr into l_sty_id;
              close get_dependent_sty_id_csr;
            END IF;
            --Bug# 8969376

            IF( l_sty_id IS NULL ) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                                p_token1       => g_stream_name_token,
                                p_token1_value => l_sec_trx_tclv_tbl(i).stream_type_purpose);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_sec_trx_tclv_tbl(i).sty_id := l_sty_id;

         END LOOP;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines');
       END IF;

         -- create the secondary transaction lines for each acc tmpl
         OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines
                        (p_api_version     => l_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_tclv_tbl        => l_sec_trx_tclv_tbl,
                         x_tclv_tbl        => x_sec_trx_tclv_tbl);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines :'||x_return_status);
         END IF;

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- make the call to accounting distributions
         OPEN l_contract_currency_csr;
         FETCH l_contract_currency_csr INTO  l_curr_code, l_currency_conversion_rate,l_currency_conversion_type, l_currency_conversion_date ;
         CLOSE l_contract_currency_csr;

          IF( l_curr_code IS NULL ) THEN
                            OKL_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => G_REQUIRED_VALUE,
                           p_token1        =>  g_col_name_token,
                           p_token1_value  =>  'CURRENCY_CODE');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


         FOR i IN x_sec_trx_tclv_tbl.FIRST..x_sec_trx_tclv_tbl.LAST  LOOP

           l_tmpl_identify_tbl(i).product_id             := x_sec_trx_tcnv_tbl(1).pdt_id;
           l_tmpl_identify_tbl(i).stream_type_id         := x_sec_trx_tclv_tbl(i).sty_id;
           l_tmpl_identify_tbl(i).transaction_type_id    := x_sec_trx_tcnv_tbl(1).try_id;
           l_tmpl_identify_tbl(i).advance_arrears        := NULL;
           l_tmpl_identify_tbl(i).prior_year_yn          := NULL;
           l_tmpl_identify_tbl(i).memo_yn                := NULL;
           l_tmpl_identify_tbl(i).investor_code          := NULL;
           l_tmpl_identify_tbl(i).SYNDICATION_CODE       := NULL;
           l_tmpl_identify_tbl(i).FACTORING_CODE         := NULL;
           l_tmpl_identify_tbl(i).rev_rec_flag           := NULL;
           l_tmpl_identify_tbl(i).factoring_synd_flag    := NULL;

           l_dist_info_tbl(i).SOURCE_ID                  := x_sec_trx_tclv_tbl(i).ID;
           l_dist_info_tbl(i).SOURCE_TABLE               := 'OKL_TXL_CNTRCT_LNS';
           l_dist_info_tbl(i).GL_REVERSAL_FLAG           := 'N';
           l_dist_info_tbl(i).POST_TO_GL                 := 'Y';
           l_dist_info_tbl(i).CONTRACT_ID                := l_pri_trx_tcnv_rec.KHR_ID;
           l_dist_info_tbl(i).CONTRACT_LINE_ID           := x_sec_trx_tclv_tbl(i).KLE_ID; -- Bug 7626121
           l_dist_info_tbl(i).CURRENCY_CONVERSION_RATE   := l_currency_conversion_rate;
           l_dist_info_tbl(i).CURRENCY_CONVERSION_TYPE   := l_currency_conversion_type;
           l_dist_info_tbl(i).CURRENCY_CONVERSION_DATE   := l_currency_conversion_date;
           l_dist_info_tbl(i).CURRENCY_CODE              := l_curr_code;
           l_dist_info_tbl(i).ACCOUNTING_DATE            := x_sec_trx_tcnv_tbl(1).date_transaction_occurred;
           l_dist_info_tbl(i).amount                     := x_sec_trx_tclv_tbl(i).amount;

            --Assigning the account generator table.SGIYER
            l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
            l_acc_gen_tbl(i).source_id :=  x_sec_trx_tclv_tbl(i).ID;


         END LOOP;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST');
       END IF;

         OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST(
                         p_api_version             => l_api_version,
                         p_init_msg_list           => p_init_msg_list,
                         x_return_status           => l_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data,
                         p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                         p_dist_info_tbl           => l_dist_info_tbl,
                         p_ctxt_val_tbl            => l_ctxt_tbl,
                         p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                         x_template_tbl            => x_template_tbl,
                         x_amount_tbl              => x_amount_out_tbl,
                         p_trx_header_id           => x_sec_trx_tcnv_tbl(1).id);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to  OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST :'||l_return_status);
         END IF;

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_TRX_CONTRACTS_PUB.update_trx_contracts');
       END IF;

             --Update the header with the amount
         x_sec_trx_tcnv_tbl(1).tsu_code := 'PROCESSED';
         OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version   => l_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_tcnv_rec      => x_sec_trx_tcnv_tbl(1),
                                              x_tcnv_rec      => x_sec_trx_tcnv_tbl(1));


         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to  OKL_TRX_CONTRACTS_PUB.update_trx_contracts :'||x_return_status);
         END IF;

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

   END IF;
             x_return_status :=   okl_api.g_ret_sts_success;
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

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
        '_PVT');

END CREATE_SEC_REP_TRX;

PROCEDURE REVERSE_SEC_REP_TRX (
          P_API_VERSION                  IN NUMBER,
          P_INIT_MSG_LIST                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY NUMBER,
          X_MSG_DATA                     OUT NOCOPY VARCHAR2,
          P_TCNV_REC                     OKL_TCN_PVT.TCNV_REC_TYPE
) IS

  l_return_status          VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;

  /* variables */
  l_api_name               CONSTANT VARCHAR2(40) := 'REVERSE_SEC_REP_TRX';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_source_table           CONSTANT OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
  l_cntrct_id              OKL_K_HEADERS_FULL_V.ID%TYPE;
  l_sysdate                DATE := SYSDATE;
  l_reversal_date          DATE;
  l_COUNT                  NUMBER :=0;
  /* record and table structure variables */
  l_pri_tcnv_rec           OKL_TRX_CONTRACTS_PUB.tcnv_rec_type := P_TCNV_REC;
  l_tcnv_rec               OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  x_tclv_tbl               OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  l_tcnv_tbl               OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
  x_tcnv_tbl               OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
  l_source_id_tbl          OKL_REVERSAL_PUB.source_id_tbl_type;
--
  TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  l_trx_date_tbl	 t_date;
--
  -- Cursor to select transaction headers for reversal
  CURSOR reverse_trx_csr(p_id NUMBER) IS
  SELECT id, date_transaction_occurred, transaction_date
  FROM OKL_TRX_CONTRACTS trx
  WHERE trx.primary_rep_trx_id = p_id
  AND trx.tsu_code = 'PROCESSED'
  AND trx.representation_type = G_SECONDARY;

  -- Cursor to select transaction lines for reversal
  CURSOR reverse_txl_csr(p_tcn_id NUMBER) IS
  SELECT txl.id, txl.amount, txl.currency_code
  FROM OKL_TXL_CNTRCT_LNS txl,
       OKL_TRX_CONTRACTS trx
  WHERE txl.tcn_id = trx.id
  AND txl.tcn_id = p_tcn_id
  AND trx.tsu_code = 'PROCESSED'
  AND trx.representation_type = G_SECONDARY;

  BEGIN

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;


       l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- Open reverse trx csr for update of transaction header
       FOR l_reverse_trx_csr IN reverse_trx_csr(l_pri_tcnv_rec.ID)
        LOOP
             l_tcnv_tbl(l_COUNT).id := l_reverse_trx_csr.id;
             l_COUNT := l_COUNT+1;
        END LOOP;

       l_COUNT :=0;

       IF l_tcnv_tbl.COUNT > 0 THEN
       -- proceed only if records found for reversal

       -- Build the transaction record for update
       FOR i IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
       LOOP

         l_tcnv_tbl(i).tsu_code := 'CANCELED';
         l_tcnv_tbl(i).canceled_date := l_pri_tcnv_rec.canceled_date;

       END LOOP;

       l_COUNT :=0;

       -- New code to process reversals by tcn_id .. bugs 6194225 and 6194204
       FOR i IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST LOOP

           -- Open reverse txl cursor to find out transaction line id's for reversal
           FOR l_reverse_txl_csr IN reverse_txl_csr(l_tcnv_tbl(i).id)
            LOOP
                l_source_id_tbl(l_COUNT) := l_reverse_txl_csr.id;
                l_COUNT := l_COUNT+1;
            END LOOP;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to Okl_Reversal_Pub.REVERSE_ENTRIES');
       END IF;

            -- reverse accounting entries
            Okl_Reversal_Pub.REVERSE_ENTRIES(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_source_table => l_source_table,
                          p_acct_date => l_tcnv_tbl(i).canceled_date, -- l_reversal_date,
                          p_source_id_tbl => l_source_id_tbl);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to  Okl_Reversal_Pub.REVERSE_ENTRIES :'||l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to  Okl_Reversal_Pub.REVERSE_ENTRIES, l_source_table :'||l_source_table);
         END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

	 END LOOP; -- new logic for reversing by tcn_id.

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to Okl_Trx_Contracts_Pub.update_trx_contracts');
       END IF;
       --Call the transaction public api to update tsu_code
       Okl_Trx_Contracts_Pub.update_trx_contracts
                         (p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_tcnv_tbl => l_tcnv_tbl,
                          x_tcnv_tbl => x_tcnv_tbl);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to  Okl_Trx_Contracts_Pub.update_trx_contracts :'||l_return_status);
         END IF;

       -- store the highest degree of error
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;


     END IF; -- for if tcnv_tbl.count > 0 condition

       -- set the return status
       x_return_status := l_return_status;

       OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
END REVERSE_SEC_REP_TRX;

PROCEDURE REVERSE_SEC_REP_TRX (
          P_API_VERSION                  IN NUMBER,
          P_INIT_MSG_LIST                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY NUMBER,
          X_MSG_DATA                     OUT NOCOPY VARCHAR2,
          P_TCNV_TBL                     tcnv_tbl_type)
  IS

  /* variables */
  l_api_name               CONSTANT VARCHAR2(40) := 'REVERSE_SEC_REP_TRX';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_return_status          VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

       l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (p_tcnv_tbl.COUNT > 0) THEN

         -- call recrod level implementation in loop
	 FOR i in p_tcnv_tbl.FIRST..p_tcnv_tbl.LAST  LOOP
	     REVERSE_SEC_REP_TRX (
                           p_api_version    => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => l_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
                          ,p_tcnv_rec       => p_tcnv_tbl(i));

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

	 END LOOP;

       END IF;

       -- set the overall return status
       x_return_status := l_return_status;

       OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END REVERSE_SEC_REP_TRX;

END OKL_MULTIGAAP_ENGINE_PVT;

/
