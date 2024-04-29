--------------------------------------------------------
--  DDL for Package Body OKL_ACTIVATE_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACTIVATE_ASSET_PVT" as
/* $Header: OKLRACAB.pls 120.49.12010000.5 2009/07/17 09:06:24 rpillay ship $ */
G_PKG_NAME                 VARCHAR2(100) := 'OKL_ACTIVATE_ASSET_PVT';
G_CHR_CURRENCY_CODE        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
G_FUNC_CURRENCY_CODE        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
G_CHR_AUTHORING_ORG_ID     OKL_K_HEADERS_FULL_V.authoring_org_id%TYPE;
G_CHR_START_DATE           DATE;
G_CHR_REPORT_PDT_ID        OKL_PRODUCTS_V.reporting_pdt_id%TYPE;

--------------------------------------------------------------------------------
--Global Constants used in the program
--------------------------------------------------------------------------------
G_TRX_LINE_TYPE_BOOK       CONSTANT Varchar2(30)  := 'CFA';
G_TRX_HDR_TYPE_BOOK        CONSTANT Varchar2(30)  := 'CFA';
G_TRX_LINE_TYPE_REBOOK     CONSTANT Varchar2(30)  := 'CRB';
G_TRX_HDR_TYPE_REBOOK      CONSTANT Varchar2(30)  := 'CRB';
G_TRX_HDR_TYPE_RELEASE     CONSTANT Varchar2(30)  := 'CRL';
G_TRX_LINE_TYPE_RELEASE    CONSTANT Varchar2(30)  := 'CRL';
G_FA_LINE_LTY_CODE         CONSTANT VARCHAR2(30)  := 'FIXED_ASSET';
G_FA_LINE_LTY_ID	   CONSTANT NUMBER        := 42;
G_FIN_AST_LINE_LTY_CODE    CONSTANT VARCHAR2(30)  := 'FREE_FORM1';
--G_ADJ_TRX_SUBTYPE          CONSTANT VARCHAR2(100) := 'AMORTIZE'; --while adjusting costs to zero whether to amortize or expense
G_ADJ_TRX_SUBTYPE          CONSTANT VARCHAR2(100) := 'AMORTIZED'; --while adjusting costs to zero whether to amortize or expense
G_AMORT_START_DATE         CONSTANT DATE          := sysdate; -- adjustment amortization start date
G_ADJ_TRX_TYPE_CODE        CONSTANT VARCHAR2(100) := 'ADJUSTMENT';
G_ADD_TRX_TYPE_CODE        CONSTANT VARCHAR2(100) := 'ADDITION';
G_ADD_ASSET_TYPE           CONSTANT VARCHAR2(100) := 'CAPITALIZED'; --Lease assets will always be capitalized
G_ADD_RATE_ADJ_FACTOR      CONSTANT NUMBER        := 1;
G_TAX_OWNER_RGP_CODE       CONSTANT VARCHAR2(30)  := 'LATOWN';
G_TAX_OWNER_RUL_CODE       CONSTANT VARCHAR2(30)  := 'LATOWN';
G_TAX_OWNER_RUL_PROMPT     CONSTANT VARCHAR2(80)  := 'Tax Owner';
--Bug# 2525946 start
G_TAX_OWNER_RUL_SEG_NUMBER CONSTANT NUMBER        := 1;
--Bug# 2525946 end
G_APPROVED_STS_CODE        CONSTANT VARCHAR2(100) := 'APPROVED';
G_LEASE_SCS_CODE           CONSTANT VARCHAR2(100) := 'LEASE';
G_DF_LEASE_BK_CLASS        CONSTANT VARCHAR2(30)  := 'LEASEDF';
G_ST_LEASE_BK_CLASS        CONSTANT VARCHAR2(30)  := 'LEASEST';
G_OP_LEASE_BK_CLASS        CONSTANT VARCHAR2(30)  := 'LEASEOP';
G_LOAN_BK_CLASS            CONSTANT VARCHAR2(30)  := 'LOAN';
G_REVOLVING_LOAN_BK_CLASS  CONSTANT VARCHAR2(30)  := 'LOAN-REVOLVING';
G_FA_CORP_BOOK_CLASS_CODE  CONSTANT VARCHAR2(15)  := 'CORPORATE';
G_FA_TAX_BOOK_CLASS_CODE   CONSTANT VARCHAR2(15)  := 'TAX';
G_TSU_CODE_PROCESSED       CONSTANT VARCHAR2(30)   := 'PROCESSED';
G_TSU_CODE_ENTERED         CONSTANT Varchar2(30)  := 'ENTERED';
--bug# 3143522 : 11.5.10 Subsidies
G_FORMULA_LINE_DISCOUNT    CONSTANT Varchar2(150) := 'LINE_DISCOUNT';
--Bug# 2981308 :
G_FORMULA_LINE_TRADEIN      CONSTANT Varchar2(150) := 'LINE_TRADEIN';
G_FORMULA_LINE_CAPREDUCTION CONSTANT Varchar2(150) := 'LINE_CAPREDUCTION';
G_FORMULA_LINE_CAPINTEREST  CONSTANT Varchar2(150) := 'LINE_CAPITALIZED_INTEREST';
-------------------------------------------------------------------------------
--Global Messages
-------------------------------------------------------------------------------
G_SOB_FETCH_FAILED         CONSTANT VARCHAR2(200) := 'OKL_LLA_BK_SOB_NOT_FOUND';
G_FA_BOOK_TOKEN            CONSTANT VARCHAR2(200) := 'FA_BOOK';
G_FA_BOOK_NOT_ENTERED      CONSTANT VARCHAR2(200) := 'OKL_LLA_FA_BK_NOT_ENTERED';
G_ASSET_NUMBER_TOKEN       CONSTANT VARCHAR2(200) := 'ASSET_NUMBER';
G_AST_CAT_NOT_ENTERED      CONSTANT VARCHAR2(200) := 'OKL_LLA_AST_CAT_NOT_ENTERED';
G_AST_LOC_NOT_ENTERED      CONSTANT VARCHAR2(200) := 'OKL_LLA_AST_LOC_NOT_ENTERED';
G_EXP_ACCT_NOT_ENTERED     CONSTANT VARCHAR2(200) := 'OKL_LLA_EXP_ACCT_NOT_ENTERED';
G_CONTRACT_NOT_FOUND       CONSTANT VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_FOUND';
G_CONTRACT_ID              CONSTANT VARCHAR2(200) := 'CONTRACT_ID';
G_CONTRACT_NOT_APPROVED    CONSTANT VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_APPROVED';
G_CONTRACT_NOT_LEASE       CONSTANT VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_LEASE';
G_FA_ITEM_REC_NOT_FOUND    CONSTANT VARCHAR2(200) := 'OKL_LLA_FA_ITM_REC_NOT_FOUND';
G_FA_LINE_ID               CONSTANT VARCHAR2(200) := 'FA_LINE_ID';
G_FA_TRX_REC_NOT_FOUND     CONSTANT VARCHAR2(200) := 'OKL_LLA_FA_TRX_REC_NOT_FOUND';
G_FA_INVALID_BK_CAT        CONSTANT VARCHAR2(200) := 'OKL_LLA_FA_INVALID_BOOK_CAT';
G_FA_BOOK                  CONSTANT VARCHAR2(200) := 'FA_BOOK';
G_ASSET_CATEGORY           CONSTANT VARCHAR2(200) := 'FA_CATEGORY';
G_FA_TAX_CPY_NOT_ALLOWED   CONSTANT VARCHAR2(200) := 'OKL_LLA_FA_TAX_CPY_NOT_ALLOWED';
G_JTF_UNDEF_LINE_SOURCE    CONSTANT VARCHAR2(200) := 'OKL_LLA_JTF_LINE_SRC_NOT_FOUND';
G_LTY_CODE                 CONSTANT VARCHAR2(200) := 'G_LTY_CODE';
G_STS_UPDATE_TRX_MISSING   CONSTANT VARCHAR2(200) := 'OKL_LLA_STS_UPDATE_TRX_MISSING';
G_TAS_ID_TOKEN             CONSTANT VARCHAR2(100) := 'TAS_ID';
G_TRX_ALREADY_PROCESSED    CONSTANT VARCHAR2(200) := 'OKL_LLA_TRX_ALREADY_PROCESSED';
G_FUTURE_IN_SERVICE_DATE   CONSTANT VARCHAR2(200) := 'OKL_LLA_FUTURE_IN_SERVICE_DATE';
G_CURRENT_OPEN_PERIOD      CONSTANT VARCHAR2(30)  := 'OPEN_PERIOD';
G_REQUIRED_VALUE           CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_COL_NAME_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_CONV_RATE_NOT_FOUND      CONSTANT VARCHAR2(200)  := 'OKL_LLA_CONV_RATE_NOT_FOUND';
G_FROM_CURRENCY_TOKEN      CONSTANT VARCHAR2(200)  := 'FROM_CURRENCY';
G_TO_CURRENCY_TOKEN        CONSTANT VARCHAR2(200)  := 'TO_CURRENCY';
G_CONV_TYPE_TOKEN          CONSTANT VARCHAR2(200)  := 'CONVERSION_TYPE';
G_CONV_DATE_TOKEN          CONSTANT VARCHAR2(200)  := 'CONVERSION_DATE';
G_SALVAGE_VALUE            CONSTANT VARCHAR2(200)  := 'OKL_LLA_SALVAGE_VALUE';
--Bug# 3143522 : 11.5.10 Subsidies
G_SUBSIDY_ADJ_COST_ERROR   CONSTANT VARCHAR2(200)  := 'OKL_SUBSIDY_ADJ_COST_ERROR';
G_BOOK_TYPE_TOKEN          CONSTANT VARCHAR2(30)   := 'BOOK_TYPE_CODE';
G_BULK_BATCH_SIZE          CONSTANT NUMBER         := 10000;

------------------------------------------------------------------------------
  --Bug# 5946411
  --Start of comments
  --
  --Procedure Name        : get_deprn_reserve
  --Purpose               : get_deprn_reserve - used internally
  --Modification History  :
  --02-May-2007    avsingh   Created
  --                         To get accumulated depreciation of an asset
  --                         As per Bug# 6027547 raised on FA, the suggestion
  --                         from FA is to back out depreciation reserve
  --                         if cost is being adjusted in the period of
  --                         of addition.
  ------------------------------------------------------------------------------
  PROCEDURE get_deprn_reserve
                   (p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    p_asset_id        IN  NUMBER,
                    p_book_type_code  IN  VARCHAR2,
                    x_asset_deprn_rec   OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'GET_DEPRN_RESERVE';
    l_api_version	CONSTANT NUMBER	:= 1.0;

    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

    l_deprn_reserve            NUMBER;

  BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_asset_hdr_rec.asset_id          := p_asset_id;
     l_asset_hdr_rec.book_type_code    := p_book_type_code;

     if NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Depreciation Reserve
     if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => 'P'
                 ) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     x_asset_deprn_rec := l_asset_deprn_rec;

     --Call end Activity
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_UNEXP_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OTHERS',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
  END get_deprn_reserve;
--------------------------------------------------------------------------------------------------------
--Bug# 5946411 End
------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKC_K_ITEMS_V
---------------------------------------------------------------------------
FUNCTION get_cimv_rec (p_cle_id                       IN NUMBER,
         x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cimv_rec_type IS
CURSOR okc_cimv_csr (p_cle_id  IN NUMBER) IS
       SELECT
            cim.ID,
            cim.OBJECT_VERSION_NUMBER,
            cim.CLE_ID,
            cim.CHR_ID,
            cim.CLE_ID_FOR,
            cim.DNZ_CHR_ID,
            cim.OBJECT1_ID1,
            cim.OBJECT1_ID2,
            cim.JTOT_OBJECT1_CODE,
            cim.UOM_CODE,
            cim.EXCEPTION_YN,
            cim.NUMBER_OF_ITEMS,
            cim.UPG_ORIG_SYSTEM_REF,
            cim.UPG_ORIG_SYSTEM_REF_ID,
            cim.PRICED_ITEM_YN,
            cim.CREATED_BY,
            cim.CREATION_DATE,
            cim.LAST_UPDATED_BY,
            cim.LAST_UPDATE_DATE,
            cim.LAST_UPDATE_LOGIN
      FROM  Okc_K_Items_V cim
      where cle_id = p_cle_id;

      l_cimv_rec     cimv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cimv_csr (p_cle_id);
    FETCH okc_cimv_csr INTO
              l_cimv_rec.ID,
              l_cimv_rec.OBJECT_VERSION_NUMBER,
              l_cimv_rec.CLE_ID,
              l_cimv_rec.CHR_ID,
              l_cimv_rec.CLE_ID_FOR,
              l_cimv_rec.DNZ_CHR_ID,
              l_cimv_rec.OBJECT1_ID1,
              l_cimv_rec.OBJECT1_ID2,
              l_cimv_rec.JTOT_OBJECT1_CODE,
              l_cimv_rec.UOM_CODE,
              l_cimv_rec.EXCEPTION_YN,
              l_cimv_rec.NUMBER_OF_ITEMS,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_cimv_rec.PRICED_ITEM_YN,
              l_cimv_rec.CREATED_BY,
              l_cimv_rec.CREATION_DATE,
              l_cimv_rec.LAST_UPDATED_BY,
              l_cimv_rec.LAST_UPDATE_DATE,
              l_cimv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cimv_csr%NOTFOUND;
    CLOSE okc_cimv_csr;
    RETURN(l_cimv_rec);
  END get_cimv_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_TXL_ASSETS_V
---------------------------------------------------------------------------
FUNCTION get_talv_rec (
    p_kle_id                       IN NUMBER,
    p_trx_type                     IN VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN talv_rec_type IS

CURSOR okl_talv_csr (p_kle_id      IN NUMBER) IS
      SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           TAS_ID,
           ILO_ID,
           ILO_ID_OLD,
           IAY_ID,
           IAY_ID_NEW,
           KLE_ID,
           DNZ_KHR_ID,
           LINE_NUMBER,
           ORG_ID,
           TAL_TYPE,
           ASSET_NUMBER,
           DESCRIPTION,
           FA_LOCATION_ID,
           ORIGINAL_COST,
           CURRENT_UNITS,
           MANUFACTURER_NAME,
           YEAR_MANUFACTURED,
           SUPPLIER_ID,
           USED_ASSET_YN,
           TAG_NUMBER,
           MODEL_NUMBER,
           CORPORATE_BOOK,
           DATE_PURCHASED,
           DATE_DELIVERY,
           IN_SERVICE_DATE,
           LIFE_IN_MONTHS,
           DEPRECIATION_ID,
           DEPRECIATION_COST,
           DEPRN_METHOD,
           DEPRN_RATE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
--Bug# 2981308
           ASSET_KEY_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           DEPRECIATE_YN,
           HOLD_PERIOD_DAYS,
           OLD_SALVAGE_VALUE,
           NEW_RESIDUAL_VALUE,
           OLD_RESIDUAL_VALUE,
           UNITS_RETIRED,
           COST_RETIRED,
           SALE_PROCEEDS,
           REMOVAL_COST,
           DNZ_ASSET_ID,
           DATE_DUE,
           CURRENCY_CODE,
           CURRENCY_CONVERSION_TYPE,
           CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_DATE
     FROM  Okl_Txl_Assets_V
     WHERE okl_txl_assets_v.kle_id  = p_kle_id
     and   okl_txl_assets_v.tal_type = p_trx_type
     and   exists (select '1' from  OKL_TRX_ASSETS
                   where  OKL_TRX_ASSETS.TAS_TYPE = p_trx_type
                   and    OKL_TRX_ASSETS.TSU_CODE = G_TSU_CODE_ENTERED
                   and    OKL_TRX_ASSETS.ID       = Okl_txl_assets_v.tas_id);
    l_talv_rec     talv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_talv_csr (p_kle_id);
    FETCH okl_talv_csr INTO
              l_talv_rec.ID,
              l_talv_rec.OBJECT_VERSION_NUMBER,
              l_talv_rec.SFWT_FLAG,
              l_talv_rec.TAS_ID,
              l_talv_rec.ILO_ID,
              l_talv_rec.ILO_ID_OLD,
              l_talv_rec.IAY_ID,
              l_talv_rec.IAY_ID_NEW,
              l_talv_rec.KLE_ID,
              l_talv_rec.DNZ_KHR_ID,
              l_talv_rec.LINE_NUMBER,
              l_talv_rec.ORG_ID,
              l_talv_rec.TAL_TYPE,
              l_talv_rec.ASSET_NUMBER,
              l_talv_rec.DESCRIPTION,
              l_talv_rec.FA_LOCATION_ID,
              l_talv_rec.ORIGINAL_COST,
              l_talv_rec.CURRENT_UNITS,
              l_talv_rec.MANUFACTURER_NAME,
              l_talv_rec.YEAR_MANUFACTURED,
              l_talv_rec.SUPPLIER_ID,
              l_talv_rec.USED_ASSET_YN,
              l_talv_rec.TAG_NUMBER,
              l_talv_rec.MODEL_NUMBER,
              l_talv_rec.CORPORATE_BOOK,
              l_talv_rec.DATE_PURCHASED,
              l_talv_rec.DATE_DELIVERY,
              l_talv_rec.IN_SERVICE_DATE,
              l_talv_rec.LIFE_IN_MONTHS,
              l_talv_rec.DEPRECIATION_ID,
              l_talv_rec.DEPRECIATION_COST,
              l_talv_rec.DEPRN_METHOD,
              l_talv_rec.DEPRN_RATE,
              l_talv_rec.SALVAGE_VALUE,
              l_talv_rec.PERCENT_SALVAGE_VALUE,
--Bug# 2981308
              l_talv_rec.ASSET_KEY_ID,
              l_talv_rec.ATTRIBUTE_CATEGORY,
              l_talv_rec.ATTRIBUTE1,
              l_talv_rec.ATTRIBUTE2,
              l_talv_rec.ATTRIBUTE3,
              l_talv_rec.ATTRIBUTE4,
              l_talv_rec.ATTRIBUTE5,
              l_talv_rec.ATTRIBUTE6,
              l_talv_rec.ATTRIBUTE7,
              l_talv_rec.ATTRIBUTE8,
              l_talv_rec.ATTRIBUTE9,
              l_talv_rec.ATTRIBUTE10,
              l_talv_rec.ATTRIBUTE11,
              l_talv_rec.ATTRIBUTE12,
              l_talv_rec.ATTRIBUTE13,
              l_talv_rec.ATTRIBUTE14,
              l_talv_rec.ATTRIBUTE15,
              l_talv_rec.CREATED_BY,
              l_talv_rec.CREATION_DATE,
              l_talv_rec.LAST_UPDATED_BY,
              l_talv_rec.LAST_UPDATE_DATE,
              l_talv_rec.LAST_UPDATE_LOGIN,
              l_talv_rec.DEPRECIATE_YN,
              l_talv_rec.HOLD_PERIOD_DAYS,
              l_talv_rec.OLD_SALVAGE_VALUE,
              l_talv_rec.NEW_RESIDUAL_VALUE,
              l_talv_rec.OLD_RESIDUAL_VALUE,
              l_talv_rec.UNITS_RETIRED,
              l_talv_rec.COST_RETIRED,
              l_talv_rec.SALE_PROCEEDS,
              l_talv_rec.REMOVAL_COST,
              l_talv_rec.DNZ_ASSET_ID,
              l_talv_rec.DATE_DUE,
              l_talv_rec.CURRENCY_CODE,
              l_talv_rec.CURRENCY_CONVERSION_TYPE,
              l_talv_rec.CURRENCY_CONVERSION_RATE,
              l_talv_rec.CURRENCY_CONVERSION_DATE;
    x_no_data_found := okl_talv_csr%NOTFOUND;
    CLOSE okl_talv_csr;
    RETURN(l_talv_rec);
  END get_talv_rec;

------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : convert_2functional_currency
  --Purpose               : check to see if the contract currency is same as
  --                        functional currency and convert -- used internally
  --Modification History  :
  --10-DEC-2002    ssiruvol   Created
------------------------------------------------------------------------------
  PROCEDURE convert_2functional_currency(
                            p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
	                        x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_chr_id        IN  NUMBER,
			                p_amount        IN  NUMBER,
			                x_amount        OUT NOCOPY NUMBER
                            ) IS

  l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'CONVERT_2FUNCT_CURRENCY';
  l_api_version	      CONSTANT NUMBER	    := 1.0;


  l_func_curr_code OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
  l_chr_curr_code  OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;

  x_contract_currency		    okl_k_headers_full_v.currency_code%TYPE;
  x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
  x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
  x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

BEGIN
   x_return_status := OKL_API.G_RET_STS_SUCCESS;
   --call start activity to set savepoint
   x_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   x_amount := p_amount;


   l_chr_curr_code  := G_CHR_CURRENCY_CODE;
   --l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(G_CHR_authoring_org_id);
   l_func_curr_code := G_FUNC_CURRENCY_CODE;

   If ( ( l_func_curr_code IS NOT NULL) AND ( l_chr_curr_code <> l_func_curr_code )) Then

       okl_accounting_util.convert_to_functional_currency(
                          p_khr_id                    => p_chr_id,
                          p_to_currency               => l_func_curr_code,
                          p_transaction_date          => G_CHR_START_DATE,
                          p_amount 	                  => p_amount,
                          x_contract_currency	      => x_contract_currency,
                          x_currency_conversion_type  => x_currency_conversion_type,
                          x_currency_conversion_rate  => x_currency_conversion_rate,
                          x_currency_conversion_date  => x_currency_conversion_date,
                          x_converted_amount          => x_amount);

      --trap the conversion exception
      --if conv rate is not found GL API returns negative
      If (p_amount > 0) and (x_amount < 0) Then
          --currency conversion rate was not found in Oracle GL
           OKC_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_CONV_RATE_NOT_FOUND,
                               p_token1       => G_FROM_CURRENCY_TOKEN,
                               p_token1_value => x_contract_currency,
                               p_token2       => G_TO_CURRENCY_TOKEN,
                               p_token2_value => l_func_curr_code,
                               p_token3       => G_CONV_TYPE_TOKEN,
                               p_token3_value => x_currency_conversion_type,
                               p_token4       => G_CONV_DATE_TOKEN,
                               p_token4_value => to_char(x_currency_conversion_date,'DD-MON-YYYY'));
           x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;


  End If;

  --Call end Activity
  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  Exception
    When OKL_API.G_EXCEPTION_ERROR Then

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END convert_2functional_currency;


------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : update_trx_status
  --Purpose               : Update transaction status - used internally
  --Modification History  :
  --20-Feb-2001    avsingh   Created
------------------------------------------------------------------------------
  PROCEDURE update_trx_status(p_api_version       IN  NUMBER,
                              p_init_msg_list     IN  VARCHAR2,
	                          x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2,
                              p_tas_id            IN  NUMBER,
                              p_tsu_code          IN  VARCHAR2) IS
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'update_trx_status';
  l_api_version	      CONSTANT NUMBER	:= 1.0;

  l_thpv_rec          OKL_TRX_ASSETS_PUB.thpv_rec_type;
  l_thpv_rec_out      OKL_TRX_ASSETS_PUB.thpv_rec_type;
  --cursor to check existing tsu code
  CURSOR tsu_code_csr (p_tas_id IN NUMBER) is
  SELECT tsu_code
  FROM   OKL_TRX_ASSETS
  WHERE  id = p_tas_id;

  l_tsu_code OKL_TRX_ASSETS.TSU_CODE%TYPE;
BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --check if tsu code has already been updated to processed
     OPEN tsu_code_csr(p_tas_id => p_tas_id);
          FETCH tsu_code_csr into l_tsu_code;
          If tsu_code_csr%NOTFOUND Then
             --internal error unable to find trransaction record while trying to update status
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                 p_msg_name     => G_STS_UPDATE_TRX_MISSING,
				                 p_token1       => G_TAS_ID_TOKEN,
				                 p_token1_value => p_tas_id
				                );
             Raise OKL_API.G_EXCEPTION_ERROR;
          Else
             If l_tsu_code = p_tsu_code Then
                --transaction already processed by another user
                OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                    p_msg_name     => G_TRX_ALREADY_PROCESSED
				                   );
                 Raise OKL_API.G_EXCEPTION_ERROR;
             Else
                 l_thpv_rec.id := p_tas_id;
                 l_thpv_rec.tsu_code := p_tsu_code;
                 OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                                    p_api_version    => p_api_version,
                                    p_init_msg_list  => p_init_msg_list,
                                    x_return_status  => x_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_thpv_rec       => l_thpv_rec,
                                    x_thpv_rec       => l_thpv_rec_out);
                    --dbms_output.put_line('after updating trx status '||x_return_status);
                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
             End If;
          End If;
        CLOSE tsu_code_csr;
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    Exception
    When OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END update_trx_status;
--------------------------------------------------------------------------------
--Function to calculate Net Book Value of an asset
--This function is not being used anywhere for time being
--------------------------------------------------------------------------------
Procedure Calc_NBV (p_api_version   IN  NUMBER,
                    p_init_msg_list IN  VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2,
                    p_asset_id      IN VARCHAR2,
                    x_nbv           OUT NOCOPY Number,
                    x_current_units OUT NOCOPY Number,
                    x_asset_number  OUT NOCOPY Varchar2,
                    x_asset_description OUT NOCOPY Varchar2)  IS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CALC_NBV';
l_api_version          CONSTANT NUMBER := 1.0;

l_book_type_code       okx_assets_v.Corporate_Book%TYPE;


Cursor asset_cost_csr (p_asset_id     IN VARCHAR2) IS
Select cost,
       corporate_book,
       current_units,
       name,
       description
from   OKX_ASSETS_V
where  ID1 = p_asset_id
and    status = 'A'
and    nvl(start_date_active,sysdate) <= sysdate
and    nvl(end_date_active,sysdate + 1) > sysdate;

Cursor Deprn_csr (p_asset_id     IN VARCHAR2,
                  p_Book_Type_Code IN VARCHAR2) IS
select sum(deprn_amount)
from   OKX_AST_DPRTNS_V
where  Asset_id = to_number(p_asset_id)
and    book_type_code = p_book_type_code
and    status = 'A'
and    nvl(start_date_active,sysdate) <= sysdate
and    nvl(end_date_active,sysdate + 1) > sysdate;

l_current_asset_cost  Number;
l_current_units       Number;
l_corporate_book      OKX_ASSETS_V.Corporate_Book%Type;
l_total_deprn         Number;
l_Nbv                 Number;
l_asset_number        OKX_ASSETS_V.Name%Type;
l_asset_description   OKX_ASSETS_V.Description%Type;
Begin
-----
     Open asset_cost_csr (p_asset_id);
     Fetch asset_cost_csr into l_current_asset_cost,
                               l_corporate_book,
                               l_current_units,
                               l_asset_number,
                               l_asset_description;
     If asset_cost_csr%NOTFOUND Then
        --dbms_output.put_line('current Cost Not Found');
        RAISE OKL_API.G_EXCEPTION_ERROR;
        --error handling
     End If;
     Close asset_cost_csr;

     Open Deprn_csr  (p_asset_id, l_book_type_code);
     Fetch Deprn_csr into l_total_deprn;
     If Deprn_csr%NOTFOUND Then
        l_total_Deprn := 0;
     End If;
     Close Deprn_csr;
     l_Nbv := l_current_asset_cost - l_total_deprn;
     x_Nbv := l_Nbv;
     x_current_units     := l_Current_Units;
     x_asset_number      := l_asset_number;
     x_asset_description := l_asset_description;

     Exception
     When OKL_API.G_EXCEPTION_ERROR Then
          Null;
          --set message and stop
          -- for testing
End Calc_Nbv;

--Bug# 3783518: start
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : validate_release_date
  --Purpose               : Check if Release Contract Start Date
  --                        falls within the current open FA period
  --                        - used internally
  --Modification History  :
  --08-Jul-2004    rpillay   Created
------------------------------------------------------------------------------
PROCEDURE  validate_release_date
                 (p_api_version     IN  NUMBER,
                  p_init_msg_list   IN  VARCHAR2,
                  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2,
                  p_book_type_code  IN  VARCHAR2,
                  p_release_date    IN  DATE) IS

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'validate_release_date';
  l_api_version	    CONSTANT NUMBER	:= 1.0;

  CURSOR open_period_cur(p_book_type_code IN VARCHAR2) IS
  select period_name,
         calendar_period_open_date,
         calendar_period_close_date
  from fa_deprn_periods
  where book_type_code = p_book_type_code
  and period_close_date is null;

  open_period_rec          open_period_cur%rowtype;
  l_current_open_period    varchar2(240) default null;

  l_icx_date_format        varchar2(240);
BEGIN

   open open_period_cur(p_book_type_code);
   fetch open_period_cur into open_period_rec;
   close open_period_cur;

   IF NOT ( p_release_date BETWEEN open_period_rec.calendar_period_open_date AND
            open_period_rec.calendar_period_close_date ) THEN

     l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

     l_current_open_period := open_period_rec.period_name||' ('||
                  to_char(open_period_rec.calendar_period_open_date,l_icx_date_format)
                  ||' - '||to_char(open_period_rec.calendar_period_close_date,l_icx_date_format)||')';
     OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_LLA_RELEASE_DATE_INVALID',
                         p_token1       => 'BOOK_TYPE_CODE',
                         p_token1_value => p_book_type_code,
                         p_token2       => 'OPEN_PERIOD',
                         p_token2_value => l_current_open_period
				 );
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR Then
    x_return_status := OKL_API.G_RET_STS_ERROR;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END validate_release_date;

------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : validate_rebook_date
  --Purpose               : Check to ensure that Revision Date does not fall
  --                        after the current open FA period
  --                        - used internally
  --Modification History  :
  --08-Jul-2004    rpillay   Created
------------------------------------------------------------------------------
PROCEDURE  validate_rebook_date
                 (p_api_version     IN  NUMBER,
                  p_init_msg_list   IN  VARCHAR2,
                  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2,
                  p_book_type_code  IN  VARCHAR2,
                  p_rebook_date     IN  DATE,
                  p_cost_adjustment IN  NUMBER,
                  p_contract_start_date IN DATE) IS

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'validate_rebook_date';
  l_api_version	    CONSTANT NUMBER	:= 1.0;

  CURSOR open_period_cur(p_book_type_code IN VARCHAR2) IS
  select period_name,
         calendar_period_open_date,
         calendar_period_close_date
  from fa_deprn_periods
  where book_type_code = p_book_type_code
  and period_close_date is null;

  open_period_rec          open_period_cur%rowtype;
  l_current_open_period    varchar2(240) default null;

  l_icx_date_format        varchar2(240);
BEGIN

   open open_period_cur(p_book_type_code);
   fetch open_period_cur into open_period_rec;
   close open_period_cur;

   -- Revision Date should be in the current or a prior FA period
   IF (p_rebook_date > open_period_rec.calendar_period_close_date) THEN

     l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

     l_current_open_period := open_period_rec.period_name||' ('||
                  to_char(open_period_rec.calendar_period_open_date,l_icx_date_format)
                  ||' - '||to_char(open_period_rec.calendar_period_close_date,l_icx_date_format)||')';
     OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_LLA_REBOOK_DATE_INVALID',
                         p_token1       => 'BOOK_TYPE_CODE',
                         p_token1_value => p_book_type_code,
                         p_token2       => 'OPEN_PERIOD',
                         p_token2_value => l_current_open_period
				 );
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- sechawla : Bug# 8370324 Removed validation that Revision Date should be the
   -- same as Contract Start Date in order to make an asset cost change

   /*
   -- Revision Date should be the same as Contract Start Date inorder to make an
   -- asset cost change
   IF (p_cost_adjustment IS NOT NULL AND
       p_contract_start_date <> p_rebook_date) THEN

     OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_LLA_VALIDATE_DEPR_COST_CHG'
				 );
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   */
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR Then
    x_return_status := OKL_API.G_RET_STS_ERROR;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END validate_rebook_date;
--Bug# 3783518: end
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_ADJUST
--Description    : Calls FA adJUSTMENTS api to adjust the book costs
--History        :
--                 28-Nov-2001  ashish.singh Created
-- Notes        :
-- IN Parameters
--               p_asset_id  - asset for which cost is to be adjusted
--               p_book_type_code - Book in whic cost cost is to be adjusted
--               p_adjust_cost    - cost to be adjusted
--               Bug# 2657558
--               p_adj_salvage_value - salvage value to be adjusted
--
--               Bug# 6373605 (OKL.R12.B SLA CRs
--               p_sla_source_header_id    IN Number,
--                  ID of source OKL_TRX_ASSETS record
--               p_sla_source_header_table IN Varchar2,
--                  'OKL_TRX_ASSETS'
--               p_sla_source_try_id       IN Number,
--                   OKL_TRX_ASSETS.try_id (transaction type id)
--               p_sla_source_line_id      IN Number,
--                   ID of line table (OKL_TXL_ASSETS_B or
--                                     OKL_TXD_ASSETS_B
--               p_sla_source_line_table   IN Varchar2,
--                    OKL_TXL_ASSETS_B or OKL_TXD_ASSETS_B
--               p_sla_source_chr_id       IN Number,
--                    Contract id of the contract on which
--                    source transaction happened
--               p_sla_source_kle_id       IN Number,
--                    Financial asset line id (lse_id = 33)
--               p_sla_asset_chr_id        IN Number,
--                    Contract on which asset is present
--                    at the time of transaction (in case of
--                    online rebook transaction is against the rebook
--                    copy contract whereas the asset is on
--                    original contract
--
-- OUT Parameters
--               x_asset_fin_rec - asset financial info record with adjusted
--                                 costs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_ADJUST_COST(p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
		                  p_chr_id         IN  NUMBER,
                                  p_asset_id       IN  NUMBER,
                                  p_book_type_code IN  OKX_AST_BKS_V.BOOK_TYPE_CODE%TYPE,
                                  p_adjust_cost    IN  NUMBER,
                                  --Bug# 2657558
                                  p_adj_salvage_value IN NUMBER,
                                  --Bug# 2981308
                                  p_adj_percent_sv    IN NUMBER,
                                  --Bug# 3156924
                                  p_trans_number      IN VARCHAR2,
                                  p_calling_interface IN VARCHAR2,
                                  --Bug Fix# 2925461
                                  p_adj_date       IN  DATE,
                                  --Bug# 6373605--SLA populate source
                                  p_sla_source_header_id    IN Number,
                                  p_sla_source_header_table IN Varchar2,
                                  p_sla_source_try_id       IN Number,
                                  p_sla_source_line_id      IN Number,
                                  p_sla_source_line_table   IN Varchar2,
                                  --source transaction contract id
                                  p_sla_source_chr_id       IN Number,
                                  p_sla_source_kle_id       IN Number,
                                  --contract id to which the asset belongs
                                  p_sla_asset_chr_id        IN Number,
                                 --Bug# 6373605--SLA populate source
                                  --Bug# 4028371
                                  x_fa_trx_date    OUT NOCOPY DATE,
                                  x_asset_fin_rec  OUT NOCOPY FA_API_TYPES.asset_fin_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'FIXED_ASSET_ADJ_CST';
l_api_version          CONSTANT NUMBER := 1.0;

l_trans_rec               FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
l_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;
l_inv_tbl                 FA_API_TYPES.inv_tbl_type;
l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
l_inv_rec                 FA_API_TYPES.inv_rec_type;
l_asset_deprn_rec         FA_API_TYPES.asset_deprn_rec_type;
l_group_recalss_option_rec FA_API_TYPES.group_reclass_options_rec_type;

l_asset_id               NUMBER;
l_book_type_code         OKX_AST_BKS_V.BOOK_TYPE_CODE%TYPE;
l_adjust_cost            NUMBER;
--Bug # 2657558
l_adj_salvage_value      NUMBER;
--Bug# 2981308
l_adj_percent_sv         NUMBER;

--Bug# 5946411: parameters for getting depreciation reserve
l_fa_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
l_fa_asset_deprn_rec FA_API_TYPES.asset_deprn_rec_type;

--Bug# 6373605 begin
l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;
--Bug# 6373605 end

Begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_asset_id := p_asset_id;
    l_book_type_code := p_book_type_code;
    l_adjust_cost := p_adjust_cost;
    --Bug # 2657558
    l_adj_salvage_value := p_adj_salvage_value;

    --Bug# 2981308 :
    l_adj_percent_sv := p_adj_percent_sv;

    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --dbms_output.enable(1000000);

   --Bug# 2726366
   --FA_SRVR_MSG.Init_Server_Message;
   --FA_DEBUG_PKG.Initialize;

    -- asset header info
   l_asset_hdr_rec.asset_id       := l_asset_id ;
   l_asset_hdr_rec.book_type_code := l_book_type_code;

   -- Bug# 3783518 - This api will be called only to adjust the
   -- the cost and salvage value to zero for assets on
   -- DF/ST Lease, immediately after creation of the asset, so
   -- the cost adjustment is to be Expensed in the current open period.

   --Bug# 3156924 :
   l_trans_rec.transaction_name  := substr(p_trans_number,1,20); --optional
   l_trans_rec.calling_interface := p_calling_interface; --optional

/*
   -- fin info
   convert_2functional_currency( p_chr_id,
                                 l_adjust_cost,
				 l_asset_fin_rec_adj.cost);

   --l_asset_fin_rec_adj.cost := l_adjust_cost;
   convert_2functional_currency( p_chr_id,
                                 l_adj_salvage_value,
				 l_asset_fin_rec_adj.salvage_value);

*/

   --Bug # 2657558
   l_asset_fin_rec_adj.salvage_value         := l_adj_salvage_value;
   l_asset_fin_rec_adj.cost                  := l_adjust_cost;
   --Bug# 2981308
   l_asset_fin_rec_adj.percent_salvage_value := l_adj_percent_sv;
   --Bug# 6373605
   l_asset_fin_rec_adj.contract_id           := p_sla_asset_chr_id;

   --Bug# 6804043: In R12 codeline, do not back out depreciation reserve
   --              when cost adjustment is done in period of addition
   /*

    ---------------------------------------------------------------------------------------------
    --Bug# 5946411 :
    -- If adjustment being done in period of addition depreciation reserve needs to be backed out
    ---------------------------------------------------------------------------------------------
    --1. Check if adjustment is being made in the period of addition of the asset
    ---------------------------------------------------------------------------------------------
    l_fa_asset_hdr_rec.asset_id       := l_asset_id;
    l_fa_asset_hdr_rec.book_type_code := l_book_type_code;

    If NOT fa_cache_pkg.fazcbc(x_book => l_fa_asset_hdr_rec.book_type_code) then
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                           );
        Raise OKL_API.G_EXCEPTION_ERROR;
    end if;

    If not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_fa_asset_hdr_rec.asset_id,
              p_book                => l_fa_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_fa_asset_hdr_rec.period_of_addition
             ) then
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_LLA_FA_POA_ERROR'
                           );
        Raise OKL_API.G_EXCEPTION_ERROR;
    end if;


    If nvl(l_fa_asset_hdr_rec.period_of_addition,'N') = 'Y' Then
        --------------------------------------
        --2. Get the depreciation reserve
        --------------------------------------
        get_deprn_reserve
                   (p_api_version      =>  p_api_version,
                    p_init_msg_list    =>  p_init_msg_list,
                    x_return_status    =>  x_return_status,
                    x_msg_count        =>  x_msg_count,
                    x_msg_data         =>  x_msg_data,
                    p_asset_id         =>  l_asset_id,
                    p_book_type_code   =>  l_book_type_code,
                    x_asset_deprn_rec  =>  l_fa_asset_deprn_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        If l_fa_asset_deprn_rec.deprn_reserve > 0 then
            l_asset_deprn_rec_adj.deprn_reserve := (-1) * l_fa_asset_deprn_rec.deprn_reserve;
        End If;
        If l_fa_asset_deprn_rec.ytd_deprn > 0 then
            l_asset_deprn_rec_adj.ytd_deprn     := (-1) * l_fa_asset_deprn_rec.ytd_deprn;
        End If;
        If l_fa_asset_deprn_rec.prior_fy_expense > 0 then
            l_asset_deprn_rec_adj.prior_fy_expense := (-1) * l_fa_asset_deprn_rec.prior_fy_expense;
        End If;
        If l_fa_asset_deprn_rec.bonus_ytd_deprn > 0 then
            l_asset_deprn_rec_adj.bonus_ytd_deprn  := (-1) * l_fa_asset_deprn_rec.bonus_ytd_deprn;
        End If;
        If l_fa_asset_deprn_rec.bonus_deprn_reserve > 0 then
            l_asset_deprn_rec_adj.bonus_deprn_reserve := (-1) * l_fa_asset_deprn_rec.bonus_deprn_reserve;
        End If;

    End If;
    --End Bug# 5946411
    */
    --End Bug# 6804043

    FA_ADJUSTMENT_PUB.do_adjustment
      (p_api_version             => p_api_version,
       p_init_msg_list           => p_init_msg_list,
       p_commit                  => FND_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       --Bug# 3156924
       --p_calling_fn              => l_api_name,
       p_calling_fn              => p_calling_interface,
       px_trans_rec              => l_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
       x_asset_fin_rec_new       => l_asset_fin_rec_new,
       x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
       px_inv_trans_rec          => l_inv_trans_rec,
       px_inv_tbl                => l_inv_tbl,
       p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
       x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
       x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
       p_group_reclass_options_rec => l_group_recalss_option_rec
      );

     --dbms_output.put_line('After Call to FA ADJUST API "'||l_return_status||'"');
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --Bug# 4028371
     x_fa_trx_date       :=  l_trans_rec.transaction_date_entered;
     --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;



      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --bug# 6373605 -- call populate SLA sources

     OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    --dbms_output.put_line('Raising unexpected here...');
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    --dbms_output.put_line('Raising when others here...'||SQLERRM);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END FIXED_ASSET_ADJUST_COST;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_ADJUST
--Description    : Calls FA adJUSTMENTS api to adjust the book deprn parameters
--History        :
--                 28-Nov-2001  ashish.singh Created
-- Notes        :
-- IN Parameters
--               p_asset_id  - asset for which cost is to be adjusted
--               p_book_type_code - Book in whic cost cost is to be adjusted
--               p_asset_fin_rec_adj - asset fin rec to adjust
--
--               Bug# 6373605 -R12.B SAL CRs
--               New IN parameters as descriped earlier in
--               FIXED_ASSET_ADJUST_COST
--
-- OUT Parameters
--               x_asset_fin_rec_new - asset financial info record with adjusted
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_ADJUST   (p_api_version          IN  NUMBER,
                                p_init_msg_list        IN  VARCHAR2,
                                x_return_status        OUT NOCOPY VARCHAR2,
                                x_msg_count            OUT NOCOPY NUMBER,
                                x_msg_data             OUT NOCOPY VARCHAR2,
				p_chr_id               IN  NUMBER,
                                p_asset_id             IN  NUMBER,
                                p_book_type_code       IN  OKX_AST_BKS_V.BOOK_TYPE_CODE%TYPE,
                                p_asset_fin_rec_adj    IN  FA_API_TYPES.asset_fin_rec_type,
                                --Bug Fix# 2925461
                                p_adj_date             IN  DATE,
                                --Bug# 3156924
                                p_trans_number         IN  VARCHAR2,
                                p_calling_interface    IN  VARCHAR2,
                                --Bug# 3156924
                                --Bug# 6373605--SLA populate source
                                p_sla_source_header_id    IN Number,
                                p_sla_source_header_table IN Varchar2,
                                p_sla_source_try_id       IN Number,
                                p_sla_source_line_id      IN Number,
                                p_sla_source_line_table   IN Varchar2,
                                p_sla_source_chr_id       IN Number,
                                p_sla_source_kle_id       IN Number,
                                --Bug# 6373605--SLA populate source
                                --Bug# 4028371
                                x_fa_trx_date          OUT NOCOPY DATE,
                                x_asset_fin_rec_new    OUT NOCOPY FA_API_TYPES.asset_fin_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'FIXED_ASSET_ADJUST';
l_api_version          CONSTANT NUMBER := 1.0;

l_trans_rec               FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
l_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;
l_inv_tbl                 FA_API_TYPES.inv_tbl_type;
l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
l_inv_rec                 FA_API_TYPES.inv_rec_type;
l_asset_deprn_rec         FA_API_TYPES.asset_deprn_rec_type;
l_group_recalss_option_rec FA_API_TYPES.group_reclass_options_rec_type;

l_asset_id               NUMBER;
l_book_type_code         OKX_AST_BKS_V.BOOK_TYPE_CODE%TYPE;

l_mesg_len NUMBER;
l_mesg     Varchar2(2000);

--Bug# 5946411: parameters for getting depreciation reserve
l_fa_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
l_fa_asset_deprn_rec FA_API_TYPES.asset_deprn_rec_type;

--Bug# 6373605 begin
l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;
--Bug# 6373605 end

Begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_asset_id := p_asset_id;
    l_book_type_code := p_book_type_code;

    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --dbms_output.enable(1000000);

   --bug# 2726366
   --FA_SRVR_MSG.Init_Server_Message;
   --FA_DEBUG_PKG.Initialize;

    -- asset header info
   l_asset_hdr_rec.asset_id       := l_asset_id ;
   l_asset_hdr_rec.book_type_code := l_book_type_code;

   --------------
   --Bug# 3156924
   --------------
   l_trans_rec.transaction_name := substr(p_trans_number,1,20);
   l_trans_rec.calling_interface := p_calling_interface;

   --------------
   --Bug# 3783518
   --------------
   l_trans_rec.transaction_subtype     := 'AMORTIZED';
   l_trans_rec.amortization_start_date := p_adj_date;

   l_asset_fin_rec_adj := p_asset_fin_rec_adj;

    /*
    -- convert to functional currency if need be.
    convert_2functional_currency( p_chr_id,
                                  p_asset_fin_rec_adj.cost,
                                  l_asset_fin_rec_adj.cost);

    convert_2functional_currency( p_chr_id,
                                  p_asset_fin_rec_adj.salvage_value,
                                  l_asset_fin_rec_adj.salvage_value);

    */

   --Bug# 6804043: In R12 codeline, do not back out depreciation reserve
   --              when cost adjustment is done in period of addition
   /*
       ---------------------------------------------------------------------------------------------
       --Bug# 5946411 :
       -- If adjustment being done in period of addition depreciation reserve needs to be backed out
       ---------------------------------------------------------------------------------------------
       --1. Check if adjustment is being made in the period of addition of the asset
       ---------------------------------------------------------------------------------------------
       l_fa_asset_hdr_rec.asset_id       := l_asset_id;
       l_fa_asset_hdr_rec.book_type_code := l_book_type_code;

       If NOT fa_cache_pkg.fazcbc(x_book => l_fa_asset_hdr_rec.book_type_code) then
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                              );
           Raise OKL_API.G_EXCEPTION_ERROR;
       end if;

       If not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_fa_asset_hdr_rec.asset_id,
              p_book                => l_fa_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_fa_asset_hdr_rec.period_of_addition
             ) then
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_LLA_FA_POA_ERROR'
                              );
           Raise OKL_API.G_EXCEPTION_ERROR;
       end if;


       If nvl(l_fa_asset_hdr_rec.period_of_addition,'N') = 'Y' Then
           --------------------------------------
           --2. Get the depreciation reserve
           --------------------------------------
           get_deprn_reserve
                   (p_api_version      =>  p_api_version,
                    p_init_msg_list    =>  p_init_msg_list,
                    x_return_status    =>  x_return_status,
                    x_msg_count        =>  x_msg_count,
                    x_msg_data         =>  x_msg_data,
                    p_asset_id         =>  l_asset_id,
                    p_book_type_code   =>  l_book_type_code,
                    x_asset_deprn_rec  =>  l_fa_asset_deprn_rec);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           If l_fa_asset_deprn_rec.deprn_reserve > 0 then
               l_asset_deprn_rec_adj.deprn_reserve := (-1) * l_fa_asset_deprn_rec.deprn_reserve;
           End If;
           If l_fa_asset_deprn_rec.ytd_deprn > 0 then
               l_asset_deprn_rec_adj.ytd_deprn     := (-1) * l_fa_asset_deprn_rec.ytd_deprn;
           End If;
           If l_fa_asset_deprn_rec.prior_fy_expense > 0 then
               l_asset_deprn_rec_adj.prior_fy_expense := (-1) * l_fa_asset_deprn_rec.prior_fy_expense;
           End If;
           If l_fa_asset_deprn_rec.bonus_ytd_deprn > 0 then
               l_asset_deprn_rec_adj.bonus_ytd_deprn  := (-1) * l_fa_asset_deprn_rec.bonus_ytd_deprn;
           End If;
           If l_fa_asset_deprn_rec.bonus_deprn_reserve > 0 then
               l_asset_deprn_rec_adj.bonus_deprn_reserve := (-1) * l_fa_asset_deprn_rec.bonus_deprn_reserve;
           End If;
       End If;
       --End Bug# 5946411
    */
    --End Bug# 6804043

    FA_ADJUSTMENT_PUB.do_adjustment
      (p_api_version             => p_api_version,
       p_init_msg_list           => p_init_msg_list,
       p_commit                  => FND_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       --Bug# 3156924
       --p_calling_fn              => l_api_name,
       p_calling_fn              => p_calling_interface,
       px_trans_rec              => l_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
       x_asset_fin_rec_new       => x_asset_fin_rec_new,
       x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
       px_inv_trans_rec          => l_inv_trans_rec,
       px_inv_tbl                => l_inv_tbl,
       p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
       x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
       x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
       p_group_reclass_options_rec => l_group_recalss_option_rec
      );

     --dbms_output.put_line('After Call to FA ADJUST API "'||x_return_status||'"');
--      if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then

--      x_msg_count := fnd_msg_pub.count_msg;

--      if x_msg_count > 0 then

--         l_mesg := chr(10) || substr(fnd_msg_pub.get
--                                     (fnd_msg_pub.G_FIRST, fnd_api.G_FALSE),
--                                      1, 512);

--         for i in 1..2 loop -- (l_mesg_count - 1) loop
--            l_mesg := l_mesg || chr(10) ||
--                        substr(fnd_msg_pub.get
--                               (fnd_msg_pub.G_NEXT,
--                                fnd_api.G_FALSE), 1, 512);
--         end loop;

--         fnd_msg_pub.delete_msg();

--         l_mesg_len := length(l_mesg);
--         for i in 1..ceil(l_mesg_len/255) loop
--                dbms_output.put_line(substr(l_mesg, ((i*255)-254), 255));
--         end loop;
--      end if;

--   else

      --dbms_output.put_line('SUCCESS');
      --dbms_output.put_line('THID' ||
                            --to_char(l_trans_rec.transaction_header_id));

--   end if;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --Bug# 4028371
     x_fa_trx_date := l_trans_rec.transaction_date_entered;
   --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --bug# 6373605 -- call populate SLA sources

     OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    --dbms_output.put_line('Raising unexpected here...');
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    --dbms_output.put_line('Raising when others here...'||SQLERRM);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END FIXED_ASSET_ADJUST;
--------------------------------------------------------------------------------
--Start of Comments
--Function Name   : CALC_DEPRN_COST (Local) Bug fix# 2788745
--Description     : Local function to calculate effective depreciation cost
--                  for an asset
--History         :
--                 05-Feb-2003  ashish.singh Created
--                 11-Sep-2003  avsingh      Bug# 3143522 : Converted into procedure for
--                                           subsidies enhancement
--                 09-Jun-2005  avsingh      Bug# 4414408
--                                           Performance fix-avoid evaluation of formulae
--End of Comments
--------------------------------------------------------------------------------
Procedure Calc_Deprn_Cost ( p_api_version   IN  NUMBER,
                           p_init_msg_list IN  VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           p_entered_deprn IN  NUMBER,
                           p_fa_cle_id     IN  NUMBER,
                           x_calculated_deprn  OUT NOCOPY NUMBER) IS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CALC_DEPRN_COST';
l_api_version          CONSTANT NUMBER := 1.0;

l_entered_deprn    Number;
l_cap_interest     Number;
l_cle_id           Number;
l_chr_id           Number;
l_calculated_deprn Number;

l_capital_amount   Number;
l_oec              Number;

--Bug# 4899328: Start
--cursor to check if the contract is undergoing on-line rebook
cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
SELECT '!'
FROM   okl_trx_contracts ktrx
WHERE  ktrx.khr_id_old = p_chr_id
AND    ktrx.tsu_code = 'ENTERED'
AND    ktrx.rbr_code is NOT NULL
AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP Project
AND    ktrx.representation_type = 'PRIMARY';
--

l_rbk_khr      VARCHAR2(1) DEFAULT '?';
--Bug# 4899328: End

Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_entered_deprn := p_entered_deprn;

    Select cleb_fin.id,
           kle_fin.oec,
           kle_fin.capital_amount,
           cleb_fin.dnz_chr_id
    into   l_cle_id,
           l_oec,
           l_capital_amount,
           l_chr_id
    From
           okc_k_lines_b cleb_fa,
           okc_k_lines_b cleb_fin,
           okl_k_lines   kle_fin
    where
           cleb_fa.id          = p_fa_cle_id
    and    cleb_fin.id         = cleb_fa.cle_id
    and    cleb_fin.dnz_chr_id = cleb_fa.dnz_chr_id
    and    kle_fin.id          = cleb_fin.id;

    -- Bug# 4899328: For On-line Rebook, the Depreciation cost
    -- will be updated automatically to reflect changes to
    -- Capital amount

    --check for rebook contract
    -- l_chr_id is the original contract
    l_rbk_khr := '?';
    OPEN l_chk_rbk_csr (p_chr_id => l_chr_id);
    FETCH l_chk_rbk_csr INTO l_rbk_khr;
    CLOSE l_chk_rbk_csr;

    If l_rbk_khr = '!' Then
      l_calculated_deprn := l_entered_deprn;
    Else

      --Bug# 4899328: Capitalized Interest will be added to Line Capital
      --              amount at the time it is calculated
      /*
      OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_formula_name  => G_FORMULA_LINE_CAPINTEREST,
                                      p_contract_id   => l_chr_id,
                                      p_line_id       => l_cle_id,
                                      x_value         => l_cap_interest);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      l_calculated_deprn := (l_capital_amount) - (l_oec) + (l_entered_deprn) + nvl(l_cap_interest,0);
      */

      l_calculated_deprn := (l_capital_amount) - (l_oec) + (l_entered_deprn);
      --Bug# 4899328: End
      --------------------------------------------------------------
    End If;
    -- Bug# 4899328: End

    x_calculated_deprn := l_calculated_deprn;

    Exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End  Calc_Deprn_Cost;
--Bug fix# 2788745:End

--------------------------------------------------------------------------------
--Start of Comments
--Function Name   : CALC_CAP_FEE_ADJUSTMENT (Local) Bug fix# 3548044
--Description     : Local function to calculate capitalized fee adjustment on
--                  Re-book
--
--History         :
--                 05-May-2004  rpillay Created
--
--End of Comments
--------------------------------------------------------------------------------
Procedure Calc_Cap_Fee_Adjustment(p_api_version  IN  NUMBER,
                           p_init_msg_list       IN  VARCHAR2,
                           x_return_status       OUT NOCOPY VARCHAR2,
                           x_msg_count           OUT NOCOPY NUMBER,
                           x_msg_data            OUT NOCOPY VARCHAR2,
                           p_rbk_fa_cle_id       IN  NUMBER,
                           p_rbk_chr_id          IN  NUMBER,
                           x_cap_fee_adjustment  OUT NOCOPY NUMBER) IS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CALC_CAP_FEE_ADJUSTMENT';
l_api_version          CONSTANT NUMBER := 1.0;

--Cursor to get FA line id of original contract
Cursor orig_fa_cle_csr(fa_cle_id IN NUMBER) is
Select orig_system_id1
From   okc_k_lines_b
where  id = fa_cle_id;

--cursor to get Cap fees added during Re-book for the asset
Cursor cap_fee_csr(fa_cle_id   in number
                  ,rbk_chr_id  in number) IS
Select nvl(sum(cov_ast_kle.capital_amount),0) capitalized_fee
From
       OKL_K_LINES       fee_kle,
       OKC_K_LINES_B     fee_cle,
       OKC_STATUSES_B    fee_sts,
       OKL_K_LINES       cov_ast_kle,
       OKC_K_LINES_B     cov_ast_cle,
       OKC_LINE_STYLES_B cov_ast_lse,
       OKC_STATUSES_B    cov_ast_sts,
       OKC_K_ITEMS       cov_ast_cim,
       OKC_K_LINES_B     fa_cle,
       OKC_K_LINES_B     src_cle
Where  fee_kle.id                    = fee_cle.id
and    fee_kle.fee_type              = 'CAPITALIZED'
and    fee_cle.id                    = cov_ast_cle.cle_id
and    fee_cle.dnz_chr_id            = cov_ast_cle.dnz_chr_id
and    fee_cle.sts_code              = fee_sts.code
and    fee_sts.ste_code not in         ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
and    cov_ast_kle.id                = cov_ast_cle.id
and    cov_ast_cle.id                = cov_ast_cim.cle_id
and    cov_ast_cle.lse_id            = cov_ast_lse.id
and    cov_ast_lse.lty_code          = 'LINK_FEE_ASSET'
and    cov_ast_cle.sts_code          = cov_ast_sts.code
and    cov_ast_sts.ste_code not in    ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
and    cov_ast_cle.dnz_chr_id        = cov_ast_cim.dnz_chr_id
and    cov_ast_cim.object1_id1       = to_char(fa_cle.cle_id)
and    cov_ast_cim.object1_id2       = '#'
and    cov_ast_cim.jtot_object1_code = 'OKX_COVASST'
and    fa_cle.id                     = fa_cle_id
and    fee_cle.orig_system_id1       = src_cle.id
and    src_cle.dnz_chr_id            = rbk_chr_id;

l_orig_fa_cle_id       Number;
l_new_cap_fee          Number;

Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    open orig_fa_cle_csr(fa_cle_id   => p_rbk_fa_cle_id);
    fetch orig_fa_cle_csr into l_orig_fa_cle_id;
    close orig_fa_cle_csr;

    open cap_fee_csr(fa_cle_id   => l_orig_fa_cle_id
                    ,rbk_chr_id  => p_rbk_chr_id);
    fetch cap_fee_csr into l_new_cap_fee;
    close cap_fee_csr;

    x_cap_fee_adjustment := NVL(l_new_cap_fee,0);

Exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End  Calc_Cap_Fee_Adjustment;
--Bug fix# 3548044:End

--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_ADD
--Description    : Calls FA additions api to create new assets for
--                 and split children
--History        :
--                 28-Nov-2001  ashish.singh Created
--
--               Bug# 6373605 -R12.B SAL CRs
--               New IN parameters as descriped earlier in
--               FIXED_ASSET_ADJUST_COST
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_ADD   (p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_talv_rec      IN  talv_rec_type,
		             p_no_curr_conv  IN  VARCHAR2,
                             --Bug# 3156924
                             p_trans_number  IN  VARCHAR2,
                             p_calling_interface IN VARCHAR2,
                             --Bug# 5261704
                             p_depreciate_flag   IN VARCHAR2,
                            --Bug# 6373605--SLA populate source
                             p_sla_source_header_id    IN Number,
                             p_sla_source_header_table IN Varchar2,
                             p_sla_source_try_id       IN Number,
                             p_sla_source_line_id      IN Number,
                             p_sla_source_line_table   IN Varchar2,
                             p_sla_source_chr_id       IN Number,
                             p_sla_source_kle_id       IN Number,
                             p_sla_asset_chr_id        IN Number,
                             --Bug# 6373605--SLA populate source
                             --Bug# 4028371
                             x_fa_trx_date       OUT NOCOPY DATE,
                             x_asset_hdr_rec OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'FIXED_ASSET_ADD';
l_api_version          CONSTANT NUMBER := 1.0;

l_trans_rec                FA_API_TYPES.trans_rec_type;
l_dist_trans_rec           FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
l_asset_hierarchy_rec      fa_api_types.asset_hierarchy_rec_type;
l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
l_inv_tbl                  FA_API_TYPES.inv_tbl_type;

--Bug Fix # 2887948
--CURSOR to fetch expense account id
CURSOR exp_act_csr (p_kle_id IN NUMBER) IS
SELECT msi.expense_account
FROM   MTL_SYSTEM_ITEMS msi,
       OKC_K_ITEMS      cim,
       OKC_K_LINES_B    mdl,
       OKC_K_LINES_B    fal
WHERE  cim.object1_id1       = msi.inventory_item_id
AND    cim.object1_id2       = to_char(msi.organization_id)
AND    cim.jtot_object1_code = 'OKX_SYSITEM'
AND    cim.dnz_chr_id        = mdl.dnz_chr_id
AND    cim.cle_id            = mdl.id
AND    mdl.dnz_chr_id        = fal.dnz_chr_id
AND    mdl.cle_id            = fal.cle_id
AND    fal.id                = p_kle_id;

l_expense_account    NUMBER;

--CURSOR to get SET OF BOOKS
CURSOR sob_csr(p_book_type_code IN VARCHAR2) IS
select set_of_books_id
from   OKX_ASST_BK_CONTROLS_V
where  book_type_code = p_book_type_code
and    status = 'A';

l_sob_id   NUMBER;

--Bug#2476805
CURSOR open_period_cur(p_book_type_code IN VARCHAR2) IS
SELECT fcp.start_date,
       fcp.end_date,
       fbc.book_type_code,
       fbc.deprn_calendar,
       fbc.prorate_calendar,
       fbc.last_period_counter,
       fdp.period_name
FROM   fa_book_controls fbc,
       fa_deprn_periods fdp,
       fa_calendar_periods fcp
WHERE  fcp.period_name    = fdp.period_name
AND    fdp.period_counter = (fbc.last_period_counter + 1)
AND    fdp.book_type_code = fbc.book_type_code
AND    fcp.calendar_type  = fbc.deprn_calendar
AND    fbc.date_ineffective is null
AND    fbc.book_type_code = p_book_type_code;

open_period_rec     open_period_cur%rowtype;
l_current_open_period    varchar2(100) default null;
--Bug#2476805

l_deprn_cost Number;

--Bug# 6373605 begin
l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;

--Bug# 6373605 end

Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --Bug#2476805
   --validate in_service_date
   OPEN open_period_cur(p_book_type_code => p_talv_rec.corporate_book);
   Fetch open_period_cur into open_period_rec;
   If open_period_cur%NotFound Then
       Null; --unexpected error
   Else
       If p_talv_rec.in_service_date > open_period_rec.end_date then
          l_current_open_period := open_period_rec.period_name||' ('||to_char(open_period_rec.start_date,'DD-MON-YYYY')||' to '||to_char(open_period_rec.end_date,'DD-MON-YYYY')||')';
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				              p_msg_name     => G_FUTURE_IN_SERVICE_DATE,
				              p_token1       => G_ASSET_NUMBER_TOKEN,
				              p_token1_value => p_talv_rec.asset_number,
                              p_token2       => G_CURRENT_OPEN_PERIOD,
                              p_token2_value => l_current_open_period
				              );
           RAISE OKL_API.G_EXCEPTION_ERROR;
       elsIf p_talv_rec.in_service_date <= open_period_rec.end_date then
           null;
       End If;
   End If;
   --Bug#2476805

   --dbms_output.enable(1000000);

   --Bug# 2726366
   --FA_SRVR_MSG.Init_Server_Message;
   --FA_DEBUG_PKG.Initialize;

   ----------------
   --trans_rec_info
   ----------------
   l_trans_rec.transaction_type_code    := G_ADD_TRX_TYPE_CODE; --optional
   --Big# 3156924
   --l_trans_rec.transaction_date_entered := p_talv_rec.in_service_date; --optional defaults to in_service_date
   l_trans_rec.who_info.last_updated_by := FND_GLOBAL.USER_ID;
   --Bug# 3156924 :
   --l_trans_rec.calling_interface        := l_api_name;
   l_trans_rec.calling_interface        := p_calling_interface; --optional
   l_trans_rec.transaction_name         := substr(p_trans_number,1,20);--optional

   --------------
   --hdr_rec info
   --------------
   If p_talv_rec.dnz_asset_id is not null Then
      l_asset_hdr_rec.asset_id := p_talv_rec.dnz_asset_id;
   End If;
   l_asset_hdr_rec.book_type_code := p_talv_rec.corporate_book;
   If p_talv_rec.corporate_book is Null Then
      --dbms_output.put_line('No FA Book Type entered for Transaction..');
      --raise error
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				          p_msg_name     => G_FA_BOOK_NOT_ENTERED,
				          p_token1       => G_ASSET_NUMBER_TOKEN,
				          p_token1_value => p_talv_rec.asset_number
				         );
      RAISE OKL_API.G_EXCEPTION_ERROR;
      --l_asset_hdr_rec.book_type_code := 'OPS CORP';
   End If;

   OPEN sob_csr(p_book_type_code => l_asset_hdr_rec.book_type_code);
   FETCH sob_csr into l_sob_id;
   If sob_csr%NOTFOUND Then
      --dbms_output.put_line('Set of books attached to book not found..');
      --raise appropriate error
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				          p_msg_name     => G_SOB_FETCH_FAILED,
				          p_token1       => G_FA_BOOK_TOKEN,
				          p_token1_value => l_asset_hdr_rec.book_type_code
				         );
      RAISE OKL_API.G_EXCEPTION_ERROR;
   Else
      l_asset_hdr_rec.set_of_books_id := l_sob_id; --optional
   End If;
   CLOSE sob_csr;

   -------------
   -- desc info
   -------------
   l_asset_desc_rec.asset_number := p_talv_rec.asset_number;
   l_asset_desc_rec.description  := p_talv_rec.description;

   l_asset_desc_rec.model_number     := p_talv_rec.model_number;
   --l_asset_desc_rec.manufacturer_name := p_talv_rec.tag_number;
   --Bug # 2397777 : Manufacturer Name now getting populated in correct field
   l_asset_desc_rec.manufacturer_name := p_talv_rec.manufacturer_name;

   If p_talv_rec.used_asset_yn is not null Then
       If p_talv_rec.used_asset_yn = 'Y' or upper(p_talv_rec.used_asset_yn) = 'YES' Then
           l_asset_desc_rec.new_used := 'USED';
       Elsif p_talv_rec.used_asset_yn = 'N' or upper(p_talv_rec.used_asset_yn) = 'NO' Then
           l_asset_desc_rec.new_used := 'NEW';
       End If;
   End If;

   -- how to get the asset key ccid??
   -- asset key ccid is not mandatory
   --l_asset_desc_rec.asset_key_ccid := 2;

   /*
   select asset_key_ccid
   into   l_asset_desc_rec.asset_key_ccid
   from   fa_additions
   where  asset_id = p_ast_line_rec.asset_id;
   */
   l_asset_desc_rec.current_units  := p_talv_rec.current_units;

   ----------------
   --Bug#  2981308
   ---------------
   l_asset_desc_rec.asset_key_ccid := p_talv_rec.asset_key_id;

   -----------------------
   --asset_type_rec info ??
   -----------------------
   --assuming okl assets will always be 'CAPITALIZED'
   l_asset_type_rec.asset_type := G_ADD_ASSET_TYPE;

   ---------------------
   --asset_cat_rec_info
   --------------------
   l_asset_cat_rec.category_id  := p_talv_rec.depreciation_id;

   ----------------
   --asset_fin_rec
   ----------------
   l_asset_fin_rec.set_of_books_id        := l_asset_hdr_rec.set_of_books_id;
   l_asset_fin_rec.date_placed_in_service := p_talv_rec.in_service_date;
   l_asset_fin_rec.deprn_method_code      := p_talv_rec.deprn_method;
   l_asset_fin_rec.life_in_months         := p_talv_rec.life_in_months;
   --Bug# 6373605 start
   l_asset_fin_rec.contract_id            := p_sla_asset_chr_id;
   --Bug# 6373605 end

   --Bug fix# 2788745: depreciation cost should be = (deprn cost - tradein - cap reduction + cap fee + cap interest)
   --call function to calculate the final depeciation cost to go into FA
   --Bug#314352 : Subsidies - local function call changed to local procedure
   Calc_Deprn_Cost ( p_api_version      => p_api_version,
                     p_init_msg_list    => p_init_msg_list,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data,
                     x_return_status    => x_return_status,
                     p_entered_deprn    => p_talv_rec.depreciation_cost,
                     p_fa_cle_id        => p_talv_rec.kle_id,
                     x_calculated_deprn => l_deprn_cost);
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   --Bug fix# 2788745: End

   --Bug# 2823405 : Raise error if depreciation cost is lesser than salvage value
   IF (l_deprn_cost < p_talv_rec.salvage_value) Then
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
		          p_msg_name     => G_SALVAGE_VALUE
		         );
      RAISE OKL_API.G_EXCEPTION_ERROR;
   End If;
   --End Bug# 2823405

-- Check and convert to functional currency.
   If ( p_no_curr_conv = OKL_API.G_FALSE ) Then -- amounts not converted to functional curr need to convert

       convert_2functional_currency(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
	                                x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_chr_id        => p_talv_rec.dnz_khr_id,
                                    --Bug fix# 2788745
			                        --p_amount        => p_talv_rec.depreciation_cost,
                                    p_amount        => l_deprn_cost,
			                        x_amount        => l_asset_fin_rec.cost);

       --dbms_output.put_line('After Calling Fixed Asset ADD api "'||x_return_status||'"');
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       l_asset_fin_rec.original_cost := l_asset_fin_rec.cost;

       convert_2functional_currency(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
	                                x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_chr_id        => p_talv_rec.dnz_khr_id,
			                        p_amount        => p_talv_rec.salvage_value,
			                        x_amount        => l_asset_fin_rec.salvage_value);

       --dbms_output.put_line('After Calling Fixed Asset ADD api "'||x_return_status||'"');
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

  ELSE --amounts already in funtional currency no need to convert
         --Bug fix# 2788745
         --l_asset_fin_rec.cost                   := p_talv_rec.depreciation_cost;
         --l_asset_fin_rec.original_cost          := p_talv_rec.depreciation_cost;
         l_asset_fin_rec.cost                   := l_deprn_cost;
         l_asset_fin_rec.original_cost          := l_deprn_cost;
         l_asset_fin_rec.salvage_value          := p_talv_rec.salvage_value;
  End If;

   --l_asset_fin_rec.cost                   := p_talv_rec.depreciation_cost;
   --l_asset_fin_rec.original_cost          := p_talv_rec.depreciation_cost;
   --l_asset_fin_rec.salvage_value          := p_talv_rec.salvage_value;
   --CONFIRM ABOUT RATES
   --confirmation : for flat rate methods these rates will be taken
   --else default rates for depreciation methods will be taken
   l_asset_fin_rec.basic_rate        := p_talv_rec.deprn_rate;
   l_asset_fin_rec.adjusted_rate     := p_talv_rec.deprn_rate;
   --confirm about this
   --Bug# 3143522 - FA API expects salvage value percent in decimals(divided by 100)
   --l_asset_fin_rec.percent_salvage_value        := p_talv_rec.percent_salvage_value;
   l_asset_fin_rec.percent_salvage_value        := (p_talv_rec.percent_salvage_value/100);
   l_asset_fin_rec.rate_adjustment_factor       := G_ADD_RATE_ADJ_FACTOR; --optional

   --Bug# 3156924 :
   --l_asset_fin_rec.depreciate_flag              := 'YES'; --gets pulled from
                                                            --asset book defaults

   --Bug# 5261704
   If NVL(p_depreciate_flag,OKL_API.G_MISS_CHAR) = 'NO' then
       l_asset_fin_rec.depreciate_flag := 'NO';
   End If;
   --End Bug # 5261704

   --asset_deprn_rec
   --no  need to populate asset depreciation rec as asset has not depreciated

   -----------------
   --asset_dist_rec
   ----------------
   l_asset_dist_rec.units_assigned := p_talv_rec.current_units;
   l_asset_dist_rec.location_ccid  := p_talv_rec.fa_location_id;

   -- CONFIRM ABOUT EXPENSE CCID
   --how to get the expense ccid ??
   --l_asset_dist_rec.code_combination_id := ??
   --expence ccid will come from mtl_system_items expense ccid
   OPEN exp_act_csr (p_kle_id => p_talv_rec.kle_id);
   Fetch exp_act_csr into
                     l_expense_account;
   If exp_act_csr%NOTFOUND Then
      --raise appropriate error
      --dbms_output.put_line('expense account not found...');
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				          p_msg_name     => G_EXP_ACCT_NOT_ENTERED,
				          p_token1       => G_ASSET_NUMBER_TOKEN,
				          p_token1_value => p_talv_rec.asset_number
				          );
      RAISE OKL_API.G_EXCEPTION_ERROR;
      --select code_combination_id
      --into   l_asset_dist_rec.expense_ccid
      --from   okx_ast_dst_hst_v
      --where  book_type_code = 'OPS CORP'
      --where  book_type_code = l_asset_hdr_rec.book_type_code
      --and    rownum < 2;
   Else
       --dbms_output.put_line('Expense ccid found in msi:-)'||to_char(l_expense_account));
       l_asset_dist_rec.expense_ccid := l_expense_account;
   End If;
   Close exp_act_csr;

   l_asset_dist_tbl(1) := l_asset_dist_rec;


   ---------------
   -- call the api
   ---------------
   fa_addition_pub.do_addition
      (p_api_version             => p_api_version,
       p_init_msg_list           => p_init_msg_list,
       p_commit                  => OKL_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       --Bug# 3156924
       --p_calling_fn              => l_api_name,
       p_calling_fn              => p_calling_interface,
       px_trans_rec              => l_trans_rec,
       px_dist_trans_rec         => l_dist_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       px_asset_desc_rec         => l_asset_desc_rec,
       px_asset_type_rec         => l_asset_type_rec,
       px_asset_cat_rec          => l_asset_cat_rec,
       px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
       px_asset_fin_rec          => l_asset_fin_rec,
       px_asset_deprn_rec        => l_asset_deprn_rec,
       px_asset_dist_tbl         => l_asset_dist_tbl,
       px_inv_tbl                => l_inv_tbl
      );
     --dbms_output.put_line('After Calling Fixed Asset ADD api "'||x_return_status||'"');
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     x_asset_hdr_rec := l_asset_hdr_rec;
     --Bug# 4028371:
     x_fa_trx_date   := l_trans_rec.transaction_date_entered;

     --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --bug# 6373605 -- call populate SLA sources
     OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    --dbms_output.put_line('Raising unexpected here...');
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    --dbms_output.put_line('Raising when others here...'||SQLERRM);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END FIXED_ASSET_ADD;

--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_ADD
--Description    : Calls FA additions api to create new assets for
--                 and split children
--History        :
--                 28-Nov-2001  ashish.singh Created
--
--               Bug# 6373605 -R12.B SAL CRs
--               New IN parameters as descriped earlier in
--               FIXED_ASSET_ADJUST_COST
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_ADD   (p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_talv_rec      IN  talv_rec_type,
                             --bug# 3156924
                             p_trans_number      IN VARCHAR2,
                             p_calling_interface IN VARCHAR2,
                             --Bug# 5261704
                             p_depreciate_flag   IN VARCHAR2,
                             --Bug# 6373605--SLA populate source
                             p_sla_source_header_id    IN Number,
                             p_sla_source_header_table IN Varchar2,
                             p_sla_source_try_id       IN Number,
                             p_sla_source_line_id      IN Number,
                             p_sla_source_line_table   IN Varchar2,
                             p_sla_source_chr_id       IN Number,
                             p_sla_source_kle_id       IN Number,
                             p_sla_asset_chr_id        IN Number,
                           --Bug# 6373605--SLA populate source
                             --Bug# 4028371
                             x_fa_trx_date       OUT NOCOPY DATE,
                             x_asset_hdr_rec OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type) is

Begin

     FIXED_ASSET_ADD(p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_talv_rec      => p_talv_rec,
	             p_no_curr_conv  => OKL_API.G_FALSE,
                     --bug# 3156924
                     p_trans_number      => p_trans_number,
                     p_calling_interface => p_calling_interface,
                     --Bug# 5261704
                     p_depreciate_flag   => p_depreciate_flag,
                     --Bug# 6373605--SLA populate source
                      p_sla_source_header_id    => p_sla_source_header_id,
                      p_sla_source_header_table => p_sla_source_header_table,
                      p_sla_source_try_id       => p_sla_source_try_id,
                      p_sla_source_line_id      => p_sla_source_line_id,
                      p_sla_source_line_table   => p_sla_source_line_table,
                      p_sla_source_chr_id       => p_sla_source_chr_id,
                      p_sla_source_kle_id       => p_sla_source_kle_id ,
                      p_sla_asset_chr_id        => p_sla_asset_chr_id,
                    --Bug# 6373605--SLA populate source
                     --Bug# 4028371
                     x_fa_trx_date       => x_fa_trx_date,
                     x_asset_hdr_rec => x_asset_hdr_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

End FIXED_ASSET_ADD;

--Bug# 3533936
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_TRANSFER
--Description    : Does location change on a re-lease asset in FA
--History        :
--                 25-Mar-2004  rekha.pillay Created
--End of Comments
--------------------------------------------------------------------------------
  PROCEDURE FIXED_ASSET_TRANSFER
                             (p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_asset_id       IN  NUMBER,
                              p_book_type_code IN  VARCHAR2,
                              p_location_id    IN  NUMBER,
                              p_trx_date       IN  DATE,
                              p_trx_number     IN  VARCHAR2,
                              --Bug# 6373605--SLA populate source
                              p_sla_source_header_id    IN Number,
                              p_sla_source_header_table IN Varchar2,
                              p_sla_source_try_id       IN Number,
                              p_sla_source_line_id      IN Number,
                              p_sla_source_line_table   IN Varchar2,
                              p_sla_source_chr_id       IN Number,
                              p_sla_source_kle_id       IN Number,
                              --Bug# 6373605 End
                              --Bug# 4028371
                              x_fa_trx_date       OUT NOCOPY DATE,
                              p_calling_interface IN VARCHAR2) is

  l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT varchar2(30) := 'FIXED_ASSET_TRANSFER';
  l_api_version          CONSTANT NUMBER := 1.0;


  l_trans_rec          fa_api_types.trans_rec_type;
  l_asset_hdr_rec      fa_api_types.asset_hdr_rec_type;
  l_asset_dist_tbl     fa_api_types.asset_dist_tbl_type;

   --cursor to get the distributions
   cursor    l_dist_curs(p_asset_id       IN NUMBER,
                         p_corporate_book IN VARCHAR2) is
   select  units_assigned,
           location_id,
           distribution_id,
           code_combination_id
   from    fa_distribution_history
   where   asset_id = p_asset_id
   and     book_type_code = p_corporate_book
   and     transaction_header_id_out is null
   and     retirement_id is null;

   l_units_assigned      NUMBER;
   l_location_id         NUMBER;
   l_distribution_id     NUMBER;
   l_code_combination_id NUMBER;

   --Bug# 6373605 begin
   l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
   l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;
   --Bug# 6373605 end


  begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_asset_hdr_rec.asset_id := p_asset_id;
      l_asset_hdr_rec.book_type_code := p_book_type_code;

      -- transaction date must be filled in if performing
      -- prior period transfer
      l_trans_rec.transaction_date_entered   := NULL;
      l_trans_rec.transaction_name           := substr(p_trx_number,1,20);
      l_trans_rec.calling_interface          := p_calling_interface;
      l_trans_rec.who_info.last_updated_by   := FND_GLOBAL.USER_ID;
      l_trans_rec.who_info.last_update_login := FND_GLOBAL.LOGIN_ID;

      open l_dist_curs(p_asset_id, p_book_type_code);
      Loop
           Fetch l_dist_curs into l_units_assigned, l_location_id, l_distribution_id, l_code_combination_id;
           Exit When l_dist_curs%NOTFOUND;
           If l_location_id <> p_location_id Then

             l_asset_dist_tbl.delete;

             l_asset_dist_tbl(1).distribution_id := l_distribution_id;
             l_asset_dist_tbl(1).transaction_units := (-1)*l_units_assigned;

             l_asset_dist_tbl(2).transaction_units := l_units_assigned;
             l_asset_dist_tbl(2).expense_ccid := l_code_combination_id;
             l_asset_dist_tbl(2).location_ccid := p_location_id;

             FA_TRANSFER_PUB.do_transfer(
                p_api_version      => p_api_version,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                p_calling_fn       => p_calling_interface,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data,
                px_trans_rec       => l_trans_rec,
                px_asset_hdr_rec   => l_asset_hdr_rec,
                px_asset_dist_tbl  => l_asset_dist_tbl);

             --dbms_output.put_line('After calling FA Transfer Api '||x_return_status);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --Bug# 6504515 -- moved inside the loop and if clause as
             --                SLA sources need to be populated only is
             ---               FA_TRANSFER_PUB is called i.e. on actual
             --                asset location change. If there is no
             --                asset location change FA_TRANSFER_PUB will
             --                not be called because of the if clause
             --                 If l_location_id <> p_location_id Then
             --bug# 6373605 -- call populate sla sources
             l_fxhv_rec.source_id := p_sla_source_header_id;
             l_fxhv_rec.source_table := p_sla_source_header_table;
             l_fxhv_rec.khr_id := p_sla_source_chr_id;
             l_fxhv_rec.try_id := p_sla_source_try_id;

             l_fxlv_rec.source_id := p_sla_source_line_id;
             l_fxlv_rec.source_table := p_sla_source_line_table;
             l_fxlv_rec.kle_id := p_sla_source_kle_id;

             l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
             l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
             l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

             OKL_SLA_ACC_SOURCES_PVT.populate_sources(
               p_api_version  => p_api_version
              ,p_init_msg_list => p_init_msg_list
              ,p_fxhv_rec => l_fxhv_rec
              ,p_fxlv_rec => l_fxlv_rec
              ,x_return_status => x_return_status
              ,x_msg_count    => x_msg_count
              ,x_msg_data    => x_msg_data
              );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            --bug# 6373605 -- call populate SLA sources
            --Bug# 6504515 -- end

           End If;
      End Loop;
      close l_dist_curs;

     --Bug# 4028371
      x_fa_trx_date := l_trans_rec.transaction_date_entered;


      OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
     WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END FIXED_ASSET_TRANSFER;
--Bug# 3533936

--Bug#5207066
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_ADJUST_UNIT
--Description    :
--History        :
--
--               Bug# 6373605 -R12.B SAL CRs
--               New IN parameters as descriped earlier in
--               FIXED_ASSET_ADJUST_COST
--
--
--End of Comments
--------------------------------------------------------------------------------
  PROCEDURE FIXED_ASSET_ADJUST_UNIT
                             (p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_asset_id       IN  NUMBER,
                              p_book_type_code IN  VARCHAR2,
                              p_diff_in_units  IN  NUMBER,
                              p_trx_date       IN  DATE,
                              p_trx_number     IN  VARCHAR2,
                              --Bug# 6373605--SLA populate source
                              p_sla_source_header_id    IN Number,
                              p_sla_source_header_table IN Varchar2,
                              p_sla_source_try_id       IN Number,
                              p_sla_source_line_id      IN Number,
                              p_sla_source_line_table   IN Varchar2,
                              p_sla_source_chr_id       IN Number,
                              p_sla_source_kle_id       IN Number,
                             --Bug# 6373605--SLA populate source
                              --Bug# 4028371
                              x_fa_trx_date       OUT NOCOPY DATE,
                              p_calling_interface IN VARCHAR2) is

  l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT varchar2(30) := 'FIXED_ASSET_ADJUST_UNIT';
  l_api_version          CONSTANT NUMBER := 1.0;


  l_trans_rec          fa_api_types.trans_rec_type;
  l_asset_hdr_rec      fa_api_types.asset_hdr_rec_type;
  l_asset_dist_tbl     fa_api_types.asset_dist_tbl_type;

    l_units_to_adjust    NUMBER;
    i    number;

   --cursor to get the distributions
   cursor    l_dist_curs(p_asset_id       IN NUMBER,
                         p_corporate_book IN VARCHAR2) is
   select  units_assigned,
           distribution_id
   from    fa_distribution_history
   where   asset_id = p_asset_id
   and     book_type_code = p_corporate_book
   and     transaction_header_id_out is null
   and     retirement_id is null;


   l_units_assigned      NUMBER;
   l_location_id         NUMBER;
   l_distribution_id     NUMBER;
   l_code_combination_id NUMBER;

   --Bug# 6373605 begin
   l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
   l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;
   --Bug# 6373605 end

  begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_asset_hdr_rec.asset_id := p_asset_id;
      l_asset_hdr_rec.book_type_code := p_book_type_code;

      -- transaction date must be filled in if performing
      -- prior period transfer
      l_trans_rec.transaction_date_entered   := NULL;
      l_trans_rec.transaction_name           := substr(p_trx_number,1,20);
      l_trans_rec.calling_interface          := p_calling_interface;
      l_trans_rec.who_info.last_updated_by   := FND_GLOBAL.USER_ID;
      l_trans_rec.who_info.last_update_login := FND_GLOBAL.LOGIN_ID;

      l_units_to_adjust := p_diff_in_units;
      i := 1;
       if (p_diff_in_units > 0) then
         OPEN l_dist_curs(p_asset_id, p_book_type_code);
         --Loop
         FETCH l_dist_curs INTO l_units_assigned, l_distribution_id;
          l_asset_dist_tbl(i).distribution_id := l_distribution_id;
          l_asset_dist_tbl(i).transaction_units := p_diff_in_units;
          l_asset_dist_tbl(i).units_assigned := NULL;
          l_asset_dist_tbl(i).assigned_to := NULL;
          l_asset_dist_tbl(i).expense_ccid := NULL;
          l_asset_dist_tbl(i).location_ccid := NULL;
          --EXIT;
          --END LOOP;
          CLOSE l_dist_curs;
       Elsif (p_diff_in_units < 0) then
           l_units_to_adjust := (-1) * p_diff_in_units;
       OPEN l_dist_curs(p_asset_id, p_book_type_code);
       LOOP
           FETCH l_dist_curs INTO l_units_assigned, l_distribution_id;
           EXIT WHEN l_dist_curs%NOTFOUND;
           IF l_units_to_adjust = 0 THEN --input param
              EXIT;
           ELSIF l_units_to_adjust >= l_units_assigned THEN
              l_asset_dist_tbl(i).distribution_id := l_distribution_id;
              l_asset_dist_tbl(i).transaction_units := (-1)*l_units_assigned;
              --dbms_output.put_line('Units to adjust '||to_char(l_asset_dist_tbl(i).transaction_units));
              l_asset_dist_tbl(i).units_assigned := NULL;
              l_asset_dist_tbl(i).assigned_to := NULL;
              l_asset_dist_tbl(i).expense_ccid := NULL;
              l_asset_dist_tbl(i).location_ccid := NULL;
              l_units_to_adjust := l_units_to_adjust - l_units_assigned;
              i := i + 1;
           ELSIF l_units_to_adjust < l_units_assigned THEN
              l_asset_dist_tbl(i).distribution_id := l_distribution_id;
              l_asset_dist_tbl(i).transaction_units := (-1)*l_units_to_adjust;
              --dbms_output.put_line('Units to adjust '||to_char(l_asset_dist_tbl(i).transaction_units));
              l_asset_dist_tbl(i).units_assigned := NULL;
              l_asset_dist_tbl(i).assigned_to := NULL;
              l_asset_dist_tbl(i).expense_ccid := NULL;
              l_asset_dist_tbl(i).location_ccid := NULL;
              l_units_to_adjust := l_units_to_adjust - l_units_to_adjust;
              i := i + 1;
           END IF;
       END LOOP;
       CLOSE l_dist_curs;
       end if;
      FA_UNIT_ADJ_PUB.do_unit_adjustment(
           p_api_version       => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           p_commit            => FND_API.G_FALSE,
           p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
           --bug# 3156924 :
           p_calling_fn        => p_calling_interface,
           --p_calling_fn        => NULL,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           px_trans_rec        => l_trans_rec,
           px_asset_hdr_rec    => l_asset_hdr_rec,
           px_asset_dist_tbl   => l_asset_dist_tbl);

         --dbms_output.put_line('After calling FA unit adjust Api '||x_return_status);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
      x_fa_trx_date := l_trans_rec.transaction_date_entered;
      --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --bug# 6373605 -- call populate SLA sources

      OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
     WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END FIXED_ASSET_ADJUST_UNIT;
--akrangan Bug# 5362977 start
   --------------------------------------------------------------------------------
   --Start of Comments
   --Procedure Name : FIXED_ASSET_UPDATE_DESC
   --Description    : Change Asset Description, Model and Manufacturer in FA
   --History        :
   --                 26-May-2006  rekha.pillay Created
   --
   --               Bug# 6373605 -R12.B SAL CRs
   --               New IN parameters as descriped earlier in
   --               FIXED_ASSET_ADJUST_COST
   --
   --End of Comments
   --------------------------------------------------------------------------------
     PROCEDURE FIXED_ASSET_UPDATE_DESC
                                (p_api_version       IN  NUMBER,
                                 p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 x_msg_data          OUT NOCOPY VARCHAR2,
                                 p_asset_id          IN  NUMBER,
                                 p_model_number      IN  VARCHAR2,
                                 p_manufacturer      IN  VARCHAR2,
                                 p_description       IN  VARCHAR2,
                                 p_trx_date          IN  DATE,
                                 p_trx_number        IN  VARCHAR2,
                                 x_fa_trx_date       OUT NOCOPY DATE,
                                 p_calling_interface IN VARCHAR2,
                                 --Bug# 8652738
                                 p_asset_key_id      IN  NUMBER) is

     l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
     l_api_name             CONSTANT varchar2(30) := 'FIXED_ASSET_UPDATE_DESC';
     l_api_version          CONSTANT NUMBER := 1.0;

     l_trans_rec          fa_api_types.trans_rec_type;
     l_asset_hdr_rec      fa_api_types.asset_hdr_rec_type;
     l_asset_desc_rec     fa_api_types.asset_desc_rec_type;
     l_asset_type_rec     fa_api_types.asset_type_rec_type;
     l_asset_cat_rec      fa_api_types.asset_cat_rec_type;

     begin
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
         -- Call start_activity to create savepoint, check compatibility
         -- and initialize message list
         x_return_status := OKL_API.START_ACTIVITY (
                                  l_api_name
                                  ,p_init_msg_list
                                  ,'_PVT'
                                  ,x_return_status);
         -- Check if activity started successfully
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_asset_hdr_rec.asset_id := p_asset_id;

         -- transaction date must be filled in if performing
         -- prior period transfer
         l_trans_rec.transaction_date_entered   := NULL;
         l_trans_rec.transaction_name           := substr(p_trx_number,1,20);
         l_trans_rec.calling_interface          := p_calling_interface;
         l_trans_rec.who_info.last_updated_by   := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.last_update_login := FND_GLOBAL.LOGIN_ID;

         l_asset_desc_rec.model_number       := p_model_number;
         l_asset_desc_rec.manufacturer_name  := p_manufacturer;

         If p_description is not null AND p_description <> OKL_API.G_MISS_CHAR THEN
           l_asset_desc_rec.description    := p_description;
         end if;

         --Bug# 8652738
         l_asset_desc_rec.asset_key_ccid   := p_asset_key_id;

         FA_ASSET_DESC_PUB.update_desc(
           p_api_version         => p_api_version,
           p_init_msg_list       => p_init_msg_list,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_calling_fn          => p_calling_interface,
           px_trans_rec          => l_trans_rec,
           px_asset_hdr_rec      => l_asset_hdr_rec,
           px_asset_desc_rec_new => l_asset_desc_rec,
           px_asset_cat_rec_new  => l_asset_cat_rec);

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         x_fa_trx_date := l_trans_rec.transaction_date_entered;

         OKL_API.END_ACTIVITY (x_msg_count,
                               x_msg_data );
     EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                   l_api_name,
                                  G_PKG_NAME,
                                  'OKL_API.G_RET_STS_ERROR',
                                  x_msg_count,
                                  x_msg_data,
                                  '_PVT');
        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
        WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
     END FIXED_ASSET_UPDATE_DESC;
--akrangan Bug# 5362977 end

-- bug#5207066

--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : Process_FA_Line
--Description    : Processes FA Line and its transactions to create new asset
--History        :
--                 28-April-2002  ashish.singh Created
--                 27-Nov-2002    ashish.singh 11.5.9 enhacements
--End of Comments
--------------------------------------------------------------------------------
Procedure Process_FA_Line (p_api_version       IN  NUMBER,
                           p_init_msg_list     IN  VARCHAR2,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_chrv_id           IN  Number,
                           p_fa_line_id        IN  Number,
                           p_fin_ast_line_id   IN  Number,
                           p_deal_type         IN  Varchar2,
                           p_trx_type          IN  Varchar2,
                           P_Multi_GAAP_YN     IN  Varchar2,
                           P_rep_pdt_book      IN  Varchar2,
                           --Bug# 3574232
                           p_adjust_asset_to_zero IN Varchar2,
                           --Bug# 3156924
                           p_trans_number      IN  Varchar2,
                           p_calling_interface IN  Varchar2,
                           --Bug# 6373605--SLA populate source
                           p_sla_asset_chr_id  IN  Number,
                           --Bug# 6373605 end
                           x_cimv_rec          OUT NOCOPY cimv_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'PROCESS_FA_LINE';
l_api_version          CONSTANT NUMBER := 1.0;
l_fa_lty_code          Varchar2(30) := G_FA_LINE_LTY_CODE;

--cursor definitions------------------------------------------------------------
--Cursor to fetch residual value from top line for operating leas
CURSOR residual_val_csr(p_fin_ast_line_id IN NUMBER) is
SELECT residual_value
FROM   OKL_K_LINES
WHERE  id = p_fin_ast_line_id;

l_residual_value    NUMBER default 0;

--Cursor to chk book validity for an asset category
CURSOR chk_cat_bk_csr(p_book_type_code IN VARCHAR2,
                      p_category_id    IN NUMBER) is
SELECT '!'
FROM   OKX_AST_CAT_BKS_V
WHERE  CATEGORY_ID = p_category_id
AND    BOOK_TYPE_CODE = p_book_type_code
AND    STATUS = 'A';

l_cat_bk_exists    Varchar2(1) default '?';


--Cursor to fetch tax book information for transaction
CURSOR okl_tadv_csr (p_tal_id                 IN NUMBER) IS
SELECT asset_number,
        description,
        quantity,
        cost,
        tax_book,
        life_in_months_tax,
        deprn_method_tax,
        deprn_rate_tax,
        salvage_value,
        --bug# 6373605 start
        id asd_id
        --bug# 6373605 end
FROM   okl_txd_Assets_v
where  tal_id = p_tal_id;

okl_tadv_rec    okl_tadv_csr%ROWTYPE;


--Cursor to check if asset_id already exists in tax_book
CURSOR chk_ast_bk_csr(p_book_type_code IN Varchar2,
                      p_asset_id       IN Number) is
SELECT '!'
FROM   OKX_AST_BKS_V
WHERE  asset_id = p_asset_id
AND    book_type_code = p_book_type_code
AND    status = 'A';

l_ast_bk_exists     Varchar2(1) default '?';

--Cursor to fetch line style source
Cursor lse_source_csr(p_lty_code IN VARCHAR2) is
select src.jtot_object_code
from   OKC_LINE_STYLE_SOURCES src,
       OKC_LINE_STYLES_B      lse
where  src.lse_id = lse.id
and    lse.lty_code = p_lty_code;

--Cursor to fetch book records for an asset
--Bug# 2657558 : select of salvage value added
Cursor ast_bks_csr(p_asset_id    IN NUMBER,
                   p_book_class  IN VARCHAR2) is
select book_type_code,
       cost,
       --Bug# 2657558
       salvage_value,
       --Bug# 2981308
       percent_salvage_value
from   okx_ast_bks_v
where  asset_id = p_Asset_id
and    book_class = p_book_class;

l_book_type_code     OKX_AST_BKS_V.BOOK_TYPE_CODE%TYPE;
l_asset_cost         NUMBER;
l_adjust_cost        NUMBER;
--Bug# 2657558
l_salvage_value      NUMBER;
l_adj_salvage_value  NUMBER;
--Bug# 2981308
l_percent_sv         NUMBER;
l_adj_percent_sv     NUMBER;

--Cursor chk if corp book is the mass copy source book
CURSOR chk_mass_cpy_book(p_corp_book IN Varchar2,
                         p_tax_book  IN Varchar2) is
SELECT '!'
FROM   OKX_ASST_BK_CONTROLS_V
WHERE  book_type_code = p_tax_book
AND    book_class = 'TAX'
AND    mass_copy_source_book = p_corp_book
AND    allow_mass_copy = 'YES'
AND    copy_additions_flag = 'YES';

l_mass_cpy_book   Varchar2(1) default '?';

-- Bug# : 11.5.9 - Multi-GAAP
-- cursor to get values from Corporate Book for rep Prod Book
-- cursor to get the actual values from FA for the contract
  CURSOR okx_ast_csr (p_asset_id         IN VARCHAR2,
                      p_book_type_code   IN VARCHAR2) is
  SELECT  okx.acquisition_date       in_service_date,
          okx.life_in_months         life_in_months,
          okx.cost                   cost,
          okx.depreciation_category  depreciation_category,
          okx.deprn_method_code      deprn_method_code,
          okx.adjusted_rate          adjusted_rate,
          okx.basic_rate             basic_rate,
          okx.salvage_value          salvage_value,
          okx.percent_salvage_value  percent_salvage_value,
          okx.book_type_code         book_type_code,
          okx.book_class             book_class,
          okx.asset_number           asset_number,
          okx.asset_id               asset_id
   FROM   okx_ast_bks_v okx
   WHERE  okx.asset_id          = p_asset_id
   AND    okx.book_type_code    = p_book_type_code;

  okx_ast_rec okx_ast_csr%RowType;
-- Bug# : 11.5.9 - Multi-GAAP


--end-----------cursor definitions----------------------------------------------

l_deal_type         OKL_K_HEADERS.DEAL_TYPE%TYPE;
l_talv_rec_in       talv_rec_type;
l_cimv_rec_in       cimv_rec_type;
l_cimv_rec_out      cimv_rec_type;
l_talv_rec          talv_rec_type;
l_cimv_rec          cimv_rec_type;
l_no_data_found     BOOLEAN DEFAULT TRUE;
l_current_units     Number;
l_asset_number      OKX_ASSETS_V.NAME%Type;
l_asset_description OKX_ASSETS_V.Description%Type;
l_fa_line_id        Number;
l_fin_ast_line_id   Number;
l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
l_asst_count        Number default 0;

--parameters for rule apis
l_rgd_code         OKC_RULE_GROUPS_B.RGD_CODE%TYPE default    G_TAX_OWNER_RGP_CODE;
l_rdf_code         OKC_RG_DEF_RULES.RDF_CODE%TYPE default     G_TAX_OWNER_RUL_CODE;
l_rdf_name         OKC_RULES_B.RULE_INFORMATION1%TYPE default G_TAX_OWNER_RUL_PROMPT;
--Bug #2525946
l_segment_number   NUMBER default G_TAX_OWNER_RUL_SEG_NUMBER;
l_id1              OKC_RULES_B.OBJECT1_ID1%TYPE;
l_id2              OKC_RULES_B.OBJECT1_ID2%TYPE;
l_tax_owner        Varchar2(200);
l_description      Varchar2(1995);
l_status           Varchar2(3);
l_start_date       date;
l_end_date         date;
l_org_id           Number;
l_inv_org_id       Number;
--l_book_type_code   OKX_ASSETS_V.CORPORATE_BOOK%TYPE;
l_select           Varchar2(2000);
--bug #2675391 : to store corporate book code for future
l_corp_book        OKX_ASSETS_V.CORPORATE_BOOK%TYPE;
l_orig_cost        OKX_ASSETS_V.ORIGINAL_COST%TYPE;
l_corp_salvage_value    NUMBER;
--Bug# 3156924 : corporate book salvage value should also be preserved for future use
l_corp_percent_sv  NUMBER;
--bug # : 11.5.9 enhancements
l_rep_pdt_book    OKX_AST_BKS_V.book_type_code%TYPE;
l_Multi_GAAP_YN   Varchar2(1);
l_rep_pdt_bk_done Varchar2(1) default 'N';

l_chrv_rec   okl_okc_migration_pvt.chrv_rec_type;
l_khrv_rec   okl_contract_pub.khrv_rec_type;
x_chrv_rec   okl_okc_migration_pvt.chrv_rec_type;
x_khrv_rec   okl_contract_pub.khrv_rec_type;

  l_bk_dfs_rec bk_dfs_csr%ROWTYPE;

  l_func_curr_code OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
  l_chr_curr_code  OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;

  x_contract_currency		okl_k_headers_full_v.currency_code%TYPE;
  x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
  x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
  x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

  --Bug# 3156924 :
  --cursor to fetch transaction number from okl_trx_assets
  cursor l_tas_csr(p_tas_id in number) is
  select to_char(trans_number),
         DATE_TRANS_OCCURRED,
         --Bug# 6373605 start
         id tas_id,
         try_id
         --Bug# 6373605 end
  from   okl_trx_assets
  where  id = p_tas_id;

  l_trans_number             okl_trx_contracts.trx_number%TYPE := p_trans_number;
  l_trans_date               okl_trx_assets.date_trans_occurred%TYPE;
  l_calling_interface        varchar2(30) := p_calling_interface;
  --Bug# 3156924
  --Bug# 6373605 start
  l_tas_id                   okl_trx_assets.id%TYPE;
  l_try_id                   okl_trx_assets.try_id%TYPE;
  --Bug# 6373605 end

  --Bug# 4028371
  l_fa_add_date_corp         date;
  l_fa_add_date_tax          date;
  l_fa_add_date_mg           date;
  l_fa_adj_date_corp         date;
  l_fa_adj_date_tax          date;
  l_fa_adj_date_mg           date;
  l_talv_date_rec            okl_tal_pvt.talv_rec_type;
  lx_talv_date_rec           okl_tal_pvt.talv_rec_type;
  --Bug# 4028371

  --Bug# 3548044
  l_corp_cost                NUMBER;

  --Bug# 3838703
  --cursor to get tax owner rule
  Cursor town_rul_csr (pchrid number) is
  Select rule_information1 tax_owner,
         id
  From   okc_rules_b rul
  where  rul.dnz_chr_id = pchrid
  and    rul.rule_information_category = 'LATOWN'
  and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

  l_town_rul      okc_rules_b.rule_information1%TYPE;
  l_town_rul_id   okc_rules_b.id%TYPE;

  --Bug# 5261704
  l_depreciate_flag VARCHAR2(3);
  --Bug# 6373605
  -- Cursor to fetch txd transaction for a tax book
  Cursor l_txd_for_book_csr (p_book_type_code in varchar2,
                             p_tal_id         in number) is
  select id
  from   okl_txd_assets_b txdb
  where  tal_id = p_tal_id
  and    tax_book = p_book_type_code;

  l_txd_for_book_rec l_txd_for_book_csr%ROWTYPE;

  l_sla_source_line_id   NUMBER;
  l_sla_source_line_table OKL_EXT_FA_LINE_SOURCES_V.SOURCE_TABLE%TYPE;
  --Bug# 6373605 end

Begin


    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 5261704 : opened this cursor earlier as tax owner value is required
    --               for asset addition for setting depreciation flag to 'NO'
    -- with cursor town_rul_csr
    Open town_rul_csr(pchrid => p_chrv_id);
    Fetch town_rul_csr into l_town_rul, l_town_rul_id;
    Close town_rul_csr;

    l_tax_owner := rtrim(ltrim(l_town_rul,' '),' ');

    l_fa_line_id        := p_fa_line_id;
    l_fin_ast_line_id   := p_fin_ast_line_id;
    l_deal_type         := p_deal_type;
    --Bug # : 11.5.9 - Multi-GAAP
    l_rep_pdt_book      := p_rep_pdt_book;
    l_Multi_GAAP_YN     := p_Multi_GAAP_YN;

    l_cimv_rec := get_cimv_rec(l_fa_line_id, l_no_data_found);
    If l_no_data_found = TRUE Then
        --dbms_output.put_line('no fa item (line source) records ...!');
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
	                    p_msg_name     => G_FA_ITEM_REC_NOT_FOUND,
                            p_token1       => G_FA_LINE_ID,
                            p_token1_value => to_char(l_fa_line_id)
				           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
     Else
        If (l_cimv_rec.jtot_object1_code is not null) and (l_cimv_rec.object1_id1) is not null Then
            Null; --asset is already linked
            x_cimv_rec := l_cimv_rec;
            l_asst_count := l_asst_count+1;
        Elsif (l_cimv_rec.jtot_object1_code is null) OR (l_cimv_rec.object1_id1 is null) Then
            --go to txlv to fetch the transaction record
            l_talv_rec := get_talv_rec(l_fa_line_id, p_trx_type, l_no_data_found);
        If l_no_data_found = TRUE Then
            --dbms_output.put_line('no asset creation transaction records ...!');
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
		                        p_msg_name     => G_FA_TRX_REC_NOT_FOUND,
                                p_token1       => G_FA_LINE_ID,
                                p_token1_value => to_char(l_fa_line_id)
				                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
            --bug#2675391 set corp book name for future use
            l_corp_book     := l_talv_rec.corporate_book;
            --check if depreciation category has been entered
            if l_talv_rec.depreciation_id is null then
                --dbms_output.put_line('Asset category not entered for Asset transaction..');
                OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                    p_msg_name     => G_AST_CAT_NOT_ENTERED,
				                    p_token1       => G_ASSET_NUMBER_TOKEN,
				                    p_token1_value => l_talv_rec.asset_number
				                    );
                RAISE OKL_API.G_EXCEPTION_ERROR;
             end if;

             --check if asset category has been entered
             If l_talv_rec.fa_location_id is null then
                 --dbms_output.put_line('FA location not entered for Asset transaction..');
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                     p_msg_name     => G_AST_LOC_NOT_ENTERED,
				                     p_token1       => G_ASSET_NUMBER_TOKEN,
				                     p_token1_value => l_talv_rec.asset_number
				                     );
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             End If;

             --Bug# 3156924 : Fetch transaction details for calling FA interfaces
             -----------------
             --Bug# 6791359 : Commented the If clause
             ----------------
             --If nvl(l_trans_number,okl_api.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
              Open l_tas_csr(p_tas_id => l_talv_rec.tas_id);
              Fetch l_tas_csr into l_trans_number,
                                   l_trans_date,
                                   --bug# 6373605 start
                                   l_tas_id,
                                   l_try_id;
                                   --Bug# 6373605 end
              if l_tas_csr%NOTFOUND then
                  Null;
              end if;
              Close l_tas_csr;
             --End If;
             -----------------
             --END Bug# 6791359 : Commented the If clause
             ----------------
             --Bug# 3156924

             --check salvage value for operating Lease

             -- Bug# 3103387 - Changed NVL check from 0 to okl_api.G_MISS_NUM
             If (nvl(l_talv_rec.salvage_value,okl_api.G_MISS_NUM) = okl_api.G_MISS_NUM and nvl(l_talv_rec.percent_salvage_value,okl_api.G_MISS_NUM) = okl_api.G_MISS_NUM
                 and l_Deal_Type = G_OP_LEASE_BK_CLASS) Then

                 --get the residual value from top line
                 OPEN residual_val_csr(p_fin_ast_line_id => l_fin_ast_line_id);
                 FETCH residual_val_csr into
                                        l_residual_value;
                 IF residual_val_csr%NOTFOUND Then
                     Null;
                 Else
                     l_talv_rec.salvage_value :=l_residual_value;
                 End If;
                 CLOSE residual_val_csr;
             End If;

             --Bug# 2967286: store corp book salvage value for future use
             l_corp_salvage_value := l_talv_rec.salvage_value;
             --Bug# 2967286 end
             --Bug# 3156924 : percent sv should also be saved for future use
             l_corp_percent_sv    := l_talv_rec.percent_salvage_value;
             --Bug# 3548044
             l_corp_cost          := l_talv_rec.depreciation_cost;

             --check for category-id book type code validity
             l_cat_bk_exists := '?';
             open chk_cat_bk_csr(p_book_type_code => l_talv_rec.corporate_book,
                                 p_category_id    => l_talv_rec.depreciation_id);
             Fetch chk_cat_bk_csr into l_cat_bk_exists;
             If chk_cat_bk_csr%NOTFOUND Then
                 null;
             End If;
             Close chk_cat_bk_csr;
             If l_cat_bk_exists = '?' Then
                 --dbms_output.put_line('Not a valid corporate book for category..');
                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                     p_msg_name     => G_FA_INVALID_BK_CAT,
                                     p_token1       => G_FA_BOOK,
                                     p_token1_value => l_talv_rec.corporate_book,
                                     p_token2       => G_ASSET_CATEGORY,
                                     p_token2_value => to_char(l_talv_rec.depreciation_id)
				                     );
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             Else
                 --Bug# 5261704 : Set depreciate flag to 'NO' for
                 --               deal types where cost will be subsequently adjusted to zero
                 l_depreciate_flag := 'YES';
                 If (l_deal_type = 'LOAN') OR
                    (l_deal_type in (G_ST_LEASE_BK_CLASS,G_DF_LEASE_BK_CLASS)) Then
                    l_depreciate_flag := 'NO';
                 End If;
                 --End Bug# 5261704
                 FIXED_ASSET_ADD(p_api_version       => p_api_version,
                                 p_init_msg_list     => p_init_msg_list,
                                 x_return_status     => x_return_status,
                                 x_msg_count         => x_msg_count,
                                 x_msg_data          => x_msg_data,
                                 p_talv_rec          => l_talv_rec,
                                 --bug# 3156924
                                 p_trans_number      => l_trans_number,
                                 p_calling_interface => l_calling_interface,
                                 --Bug# 5261704
                                 p_depreciate_flag   => l_depreciate_flag,
          --Bug# 6373605--SLA populate source
          p_sla_source_header_id    => l_tas_id,
          p_sla_source_header_table => 'OKL_TRX_ASSETS',
          p_sla_source_try_id       => l_try_id,
          p_sla_source_line_id      => l_talv_rec.id,
          p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
          p_sla_source_chr_id       => p_chrv_id,
          p_sla_source_kle_id       => p_fin_ast_line_id,
          p_sla_asset_chr_id        => p_sla_asset_chr_id,
          --Bug# 6373605--SLA populate sources
                                 --Bug# 4028371
                                 x_fa_trx_date       => l_fa_add_date_corp,
                                 x_asset_hdr_rec     => l_asset_hdr_rec);
                 --dbms_output.put_line('After fixed_asset_add corp book'||x_return_status);
                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
              End If;

              --Bug# : 11.5.9 Multi GAAP
              l_rep_pdt_bk_done := 'N';
              --get the tax book records
              open  okl_tadv_csr(p_tal_id => l_talv_rec.id);
              Loop
                  Fetch okl_tadv_csr
                        into okl_tadv_rec;
                  --check whether correct tax book for asset category
                  Exit When okl_tadv_csr%NOTFOUND;
                  l_cat_bk_exists := '?';
                  open chk_cat_bk_csr(p_book_type_code => okl_tadv_rec.tax_book,
                                      p_category_id    => l_talv_rec.depreciation_id);
                  Fetch chk_cat_bk_csr into l_cat_bk_exists;
                  If chk_cat_bk_csr%NOTFOUND Then
                      null;
                  End If;
                  Close chk_cat_bk_csr;

                  If l_cat_bk_exists = '?' Then
                      --dbms_output.put_line('Not a valid tax book for category..');
                      --raise appropriate error
                      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
         	                          p_msg_name     => G_FA_INVALID_BK_CAT,
                                          p_token1       => G_FA_BOOK,
                                          p_token1_value => okl_tadv_rec.tax_book,
                                          p_token2       => G_ASSET_CATEGORY,
                                          p_token2_value => to_char(l_talv_rec.depreciation_id)
                                         );
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                  Else
                       --check if asset already exists in tax book
                       l_ast_bk_exists := '?';
                       Open chk_ast_bk_csr(p_book_type_code => okl_tadv_rec.tax_book,
                                           p_asset_id       => l_asset_hdr_rec.asset_id);
                       Fetch chk_ast_bk_csr into l_ast_bk_exists;
                       If chk_ast_bk_csr%NOTFOUND Then
                           Null;
                       End If;
                       Close chk_ast_bk_csr;

                       If l_ast_bk_exists = '!' Then --asset already exists in tax book
                           null; --do not have to add again
                       Else
                           --chk if corp book is the mass copy book for the tax book
                           l_mass_cpy_book := '?';
                           OPEN chk_mass_cpy_book(
                                                  --bug#2675391 : use previously stored corp book code
                                                  --p_corp_book => l_talv_rec.corporate_book,
                                                  p_corp_book => l_corp_book,
                                                  p_tax_book  => okl_tadv_rec.tax_book);
                           Fetch chk_mass_cpy_book into l_mass_cpy_book;
                           If chk_mass_cpy_book%NOTFOUND Then
                               Null;
                           End If;
                           Close chk_mass_cpy_book;

                           If l_mass_cpy_book = '?' Then
                               --can not mass copy into tax book
                               --dbms_output.put_line('Can not copy into tax book ...');
                               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                                   p_msg_name     => G_FA_TAX_CPY_NOT_ALLOWED,
                                                   p_token1       => G_FA_BOOK,
                                                   p_token1_value => okl_tadv_rec.tax_book
				                                  );
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                                      --raise appropriate error message;
                           Else
                                --can masscopy
                                --intialize talv record for tax book
                                l_talv_rec.corporate_book    := okl_tadv_rec.tax_book;
                                l_talv_rec.dnz_asset_id      := l_asset_hdr_rec.asset_id;
                                --l_talv_rec.asset_number      := okl_tadv_rec.asset_number;
                                --l_talv_rec.description       := okl_tadv_rec.description;
                                If okl_tadv_rec.cost is not null Then
                                    l_talv_rec.depreciation_cost := okl_tadv_rec.cost;
                                End If;
                                    l_talv_rec.life_in_months    := okl_tadv_rec.life_in_months_tax;
                                    l_talv_rec.deprn_method      := okl_tadv_rec.deprn_method_tax;
                                    l_talv_rec.deprn_rate        := okl_tadv_rec.deprn_rate_tax;
                                --Bug#-2397777 : residual value should be salvage value for operating lease if no sal. value given explicitly:
                                --Bug#2967286 : salvage value should be equal to
                                --corp book salvage value only for Multi-Gapp tax books.
                                --For others it should be eqaul to zero

                                --check salvage value for operating Lease
                                If  l_rep_pdt_book = okl_tadv_rec.tax_book Then

                                -- Bug# 3103387 - Changed NVL check from 0
                                -- to okl_api.G_MISS_NUM
                                    If (nvl(l_talv_rec.salvage_value,okl_api.G_MISS_NUM) = okl_api.G_MISS_NUM and nvl(l_talv_rec.percent_salvage_value,okl_api.G_MISS_NUM) = okl_api.G_MISS_NUM
                                        and l_Deal_Type = G_OP_LEASE_BK_CLASS) Then
                                        --null; --salvage value shouldbe residual value as for corp book
                                        --salvage value should be equal to corp book salvage value
                                        l_talv_rec.salvage_value := l_corp_salvage_value;
                                        --Bug# 3156924 :
                                        l_talv_rec.percent_salvage_value := l_corp_percent_sv;
                                    else
                                        --tadv salvage value not getting populated now so
                                        --l_talv_rec.salvage_value     := okl_tadv_rec.salvage_value;
                                        l_talv_rec.salvage_value     := l_corp_salvage_value;
                                        --Bug# 3156924 :
                                        l_talv_rec.percent_salvage_value := l_corp_percent_sv;
                                    end if;
                                Else
                                    --bug# 2967286
                                    --l_talv_rec.salvage_value := 0;
                                    --Bug# 3156924
                                    l_talv_rec.salvage_value := null;
                                    --bug# 3156924 :
                                    l_talv_rec.percent_salvage_value := null;
                                End If;

                                --Bug# 5261704 : Set depreciate flag to 'NO' for
                                --               deal types where cost will be subsequently adjusted to zero
                                -- If LOAN  or
                                -- If DF ST with LESSEE AND
                                -- Book <> Multi-GAAP Book
                                l_depreciate_flag := 'YES';
                                If ((l_deal_type = 'LOAN') OR
                                    (l_deal_type  in (G_ST_LEASE_BK_CLASS,G_DF_LEASE_BK_CLASS) AND l_tax_owner = 'LESSEE')
                                   ) AND
                                   l_talv_rec.corporate_book <> nvl(l_rep_pdt_book,okl_api.g_miss_char) Then
                                    l_depreciate_flag := 'NO';
                                End If;
                                If (l_Multi_GAAP_YN = 'Y') AND
                                    (l_talv_rec.corporate_book = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR)) AND
                                    (p_adjust_asset_to_zero = 'Y') Then
                                    l_depreciate_flag := 'NO';
                                End If;
                                --End Bug# 5261704
                                --call mass additions add for tax book
                                FIXED_ASSET_ADD(p_api_version   => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_talv_rec      => l_talv_rec,
                                                --Bug# 3156924
                                                p_trans_number      => l_trans_number,
                                                p_calling_interface => l_calling_interface,
                                                --Bug# 5261704
                                                p_depreciate_flag   => l_depreciate_flag,
              --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              p_sla_source_line_id      => okl_tadv_rec.asd_id,
              p_sla_source_line_table   => 'OKL_TXD_ASSETS_B',
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources
                                                --Bug# 4028371
                                                x_fa_trx_date => l_fa_add_date_tax,
                                                x_asset_hdr_rec     => l_asset_hdr_rec);
                                --dbms_output.put_line('After tax book "'||okl_tadv_rec.tax_book||'" :'||x_return_status);
                                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                         RAISE OKL_API.G_EXCEPTION_ERROR;
                                    END IF;
                                End If; --can mass copy into tax book
                           End If; --asset does not exist in tax book
                       End If; -- valid tax book for category

                       --Bug# : 11.5.9 Multi GAAP Begin

                       If l_rep_pdt_book = okl_tadv_rec.tax_book Then
                          l_rep_pdt_bk_done := 'Y';
                       End If;

                  End Loop; -- get tax book records

                  --Bug# : 11.5.9 Multi GAAP End
                  Close okl_tadv_csr;

                  --Bug# : 11.5.9 Multi GAAP
                  If (l_Multi_GAAP_YN = 'Y') and (l_rep_pdt_book is not null) Then
                      If l_rep_pdt_bk_done = 'Y' Then
                          Null;
                      Elsif l_rep_pdt_bk_done = 'N' Then
                          --add asset to reporting product book
                          Open okx_ast_csr(p_asset_id => l_asset_hdr_rec.asset_id,
                                           p_book_type_code => l_corp_book);
                          Fetch okx_ast_csr into okx_ast_rec;
                          If okx_ast_csr%NotFound Then
                             null;
                             --asset should be already in corp book to reach this stage;
                             --so not raising an error
                          End if;
                          Close okx_ast_csr;

                          l_cat_bk_exists := '?';
                          open chk_cat_bk_csr(p_book_type_code => l_rep_pdt_book,
                                              p_category_id    => okx_ast_rec.depreciation_category);
                          Fetch chk_cat_bk_csr into l_cat_bk_exists;
                          If chk_cat_bk_csr%NOTFOUND Then
                              null;
                          End If;
                          Close chk_cat_bk_csr;

                          If l_cat_bk_exists = '?' Then
                          --dbms_output.put_line('Not a valid tax book for category..');
                          --raise appropriate error
                              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
		                                  p_msg_name     => G_FA_INVALID_BK_CAT,
                                                  p_token1       => G_FA_BOOK,
                                                  p_token1_value => l_rep_pdt_book,
                                                  p_token2       => G_ASSET_CATEGORY,
                                                  p_token2_value => to_char(okx_ast_rec.depreciation_category)
                                                 );
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                          Else
                              --check if asset already exists in tax book
                              l_ast_bk_exists := '?';
                              Open chk_ast_bk_csr(p_book_type_code => l_rep_pdt_book,
                                                  p_asset_id       => okx_ast_rec.asset_id);
                              Fetch chk_ast_bk_csr into l_ast_bk_exists;
                              If chk_ast_bk_csr%NOTFOUND Then
                                  Null;
                              End If;
                              Close chk_ast_bk_csr;

                              If l_ast_bk_exists = '!' Then --asset already exists in tax book
                                  null; --do not have to add again
                              Else
                                  --chk if corp book is the mass copy book for the tax book
                                  l_mass_cpy_book := '?';
                                  OPEN chk_mass_cpy_book(
                                                      --bug#2675391 : use previously stored corp book code
                                                      --p_corp_book => l_talv_rec.corporate_book,
                                                      p_corp_book => l_corp_book,
                                                      p_tax_book  => l_rep_pdt_book);
                                  Fetch chk_mass_cpy_book into l_mass_cpy_book;
                                  If chk_mass_cpy_book%NOTFOUND Then
                                      Null;
                                  End If;
                                  Close chk_mass_cpy_book;

                                  If l_mass_cpy_book = '?' Then
                                      --can not mass copy into tax book
                                      --dbms_output.put_line('Can not copy into tax book ...');
                                      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
		                                          p_msg_name     => G_FA_TAX_CPY_NOT_ALLOWED,
                                                          p_token1       => G_FA_BOOK,
                                                          p_token1_value => l_rep_pdt_book
				                                         );
                                      RAISE OKL_API.G_EXCEPTION_ERROR;
                                      --raise appropriate error message;
                                  Else

                                      open bk_dfs_csr(ctId   => okx_ast_rec.depreciation_category,
                                                      effDat => okx_ast_rec.in_service_date,
			                              bk     => l_rep_pdt_book);
                                      Fetch bk_dfs_csr into l_bk_dfs_rec;
                                      If bk_dfs_csr%NOTFOUND Then
                                          Close bk_dfs_csr;
                                          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                              p_msg_name     => G_FA_INVALID_BK_CAT,
                                                              p_token1       => G_FA_BOOK,
                                                              p_token1_value => l_rep_pdt_book,
                                                              p_token2       => G_ASSET_CATEGORY,
                                                              p_token2_value => to_char(okx_ast_rec.depreciation_category));
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      End If;
                                      Close bk_dfs_csr;

                                      --can masscopy
                                      --intialize talv record for tax book
                                      l_talv_rec.corporate_book    := l_rep_pdt_book;

                                      l_talv_rec.dnz_asset_id      := l_asset_hdr_rec.asset_id;
                                      --l_talv_rec.asset_number      := okl_tadv_rec.asset_number;
                                      --l_talv_rec.description       := okl_tadv_rec.description;

                                      --l_chr_curr_code  := l_hdr_rec.CURRENCY_CODE;
                                      --l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_hdr_rec.authoring_org_id);


                                      --Bug# 3548044 :
                                      l_talv_rec.depreciation_cost       := l_corp_cost;
                                      l_talv_rec.salvage_value           := l_corp_salvage_value;
                                      l_talv_rec.percent_salvage_value   := l_corp_percent_sv;
                                      --l_talv_rec.depreciation_cost     := okx_ast_rec.cost;
                                      --l_talv_rec.salvage_value         := okx_ast_rec.salvage_value;
                                      --l_talv_rec.percent_salvage_value := okx_ast_rec.percent_salvage_value;

                                      /* --As already adding in Functional currency Following conversion is not required
                                      If ( ( l_func_curr_code IS NOT NULL) AND ( l_chr_curr_code <> l_func_curr_code )) Then

                                          okl_accounting_util.convert_to_contract_currency(
                                                          p_khr_id                    => p_chrv_id,
                                                          p_from_currency             => l_func_curr_code,
                                                          p_transaction_date          => l_hdr_rec.start_date,
                                                          p_amount 	              => okx_ast_rec.cost,
                                                          x_contract_currency	      => x_contract_currency,
                                                          x_currency_conversion_type  => x_currency_conversion_type,
                                                          x_currency_conversion_rate  => x_currency_conversion_rate,
                                                          x_currency_conversion_date  => x_currency_conversion_date,
                                                          x_converted_amount          => l_talv_rec.depreciation_cost);

                                          okl_accounting_util.convert_to_contract_currency(
                                                          p_khr_id                    => p_chrv_id,
                                                          p_from_currency             => l_func_curr_code,
                                                          p_transaction_date          => G_CHR_START_DATE,
                                                          p_amount 	              => okx_ast_rec.salvage_value,
                                                          x_contract_currency	      => x_contract_currency,
                                                          x_currency_conversion_type  => x_currency_conversion_type,
                                                          x_currency_conversion_rate  => x_currency_conversion_rate,
                                                          x_currency_conversion_date  => x_currency_conversion_date,
                                                          x_converted_amount          => l_talv_rec.salvage_value);

                                      End If;
                                      --As already adding in Functional currency Following conversion is not required */

                                      -----------------------------------------------------------------
                                      --Bug# 2981308 : Multi-Gaap Book should be identical to CORP Book
                                      --Bug# 3548044 : Re-fix on above: Multi-Gaap Book should read from category defaults
                                      -----------------------------------------------------------------
                                      l_talv_rec.life_in_months    := l_bk_dfs_rec.life_in_months;
                                      l_talv_rec.deprn_method      := l_bk_dfs_rec.deprn_method;
                                      l_talv_rec.deprn_rate        := l_bk_dfs_rec.adjusted_rate;
                                      --l_talv_rec.life_in_months    := okx_ast_rec.life_in_months;
                                      --l_talv_rec.deprn_method      := okx_ast_rec.deprn_method_code;
                                      --l_talv_rec.deprn_rate        := okx_ast_rec.adjusted_rate;

                                      --call mass additions add for reporting product tax book
                                      --Bug# 5261704 :
                                      l_depreciate_flag := 'YES';
                                      If p_adjust_asset_to_zero = 'Y' Then
                                          l_depreciate_flag := 'NO';
                                      End If;
                                      FIXED_ASSET_ADD(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => x_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_talv_rec      => l_talv_rec,
                                                      --Bug# 3621663
        		                              --p_no_curr_conv  => OKL_API.G_TRUE,
                                                      --Bug# 3156924
                                                      p_trans_number  => l_trans_number,
                                                      p_calling_interface => l_calling_interface,
                                                      --Bug# :5261704
                                                      p_depreciate_flag   => l_depreciate_flag,
              --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              --as no transaction exists for Multi-Gaap book using the parent
              --corporate book transaction as source
              p_sla_source_line_id      => l_talv_rec.id,
              p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources

                                                      --Bug# 4028371
                                                      x_fa_trx_date       => l_fa_add_date_mg,
                                                      x_asset_hdr_rec => l_asset_hdr_rec);
                                      --dbms_output.put_line('After tax book "'||okl_tadv_rec.tax_book||'" :'||x_return_status);
                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;
                                  End If; --can mass copy into tax book
                              End If; --asset does not exist in tax book
                          End If; -- valid tax book for category
                      End If; --l_rep_pdt_book_done = 'N'
                  End If; --l_Multi_GAAP_YN = 'Y'
                  --Bug# : 11.5.9 Multi GAAP Book creation End

                  --tie back asset id into fa item record
                  l_cimv_rec.object1_id1 := to_char(l_asset_hdr_rec.asset_id);
                  l_cimv_rec.object1_id2 := '#';
                  Open lse_source_csr(l_fa_lty_code);
                  Fetch lse_source_csr into l_cimv_rec.jtot_object1_code;
                  If lse_source_csr%NOTFOUND Then
                      --dbms_output.put_line('Fatal error due to setup - lse source undefined');
                      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				          p_msg_name     => G_JTF_UNDEF_LINE_SOURCE,
                                          p_token1       => G_LTY_CODE,
                                          p_token1_value => l_fa_lty_code
                                          );
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  End If;
                  Close lse_source_csr;

                  OKL_OKC_MIGRATION_PVT.update_contract_item
                                     (p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_cimv_rec      => l_cimv_rec,
                                      x_cimv_rec      => l_cimv_rec_out);
                  --dbms_output.put_line('After calling update item :'||x_return_status);
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                  x_cimv_rec := l_cimv_rec_out;
                  l_asst_count := l_asst_count+1;

                  -- if sales type lease then adjust the costs to zero
                  --dbms_output.put_line('Deal Type :'||l_deal_type);
                  --Bug: 11.5.9 - Now will check for 'LOAN' Book Class
                  --IF l_Deal_Type = G_ST_LEASE_BK_CLASS Then
                  IF l_Deal_Type = 'LOAN' Then
                      --call adjustment API to set the costs to zero in
                      --both types of books
                      -- 1. for corporate cook
                      Open  ast_bks_csr(p_asset_id    => l_asset_hdr_rec.asset_id,
                                        p_book_class  => G_FA_CORP_BOOK_CLASS_CODE);
                      --Bug#2657558 : selecting salvage_value
                      Fetch ast_bks_csr into
                                             l_book_type_code,
                                             l_asset_cost,
                                             l_salvage_value,
                                             --Bug# 2981308
                                             l_percent_sv;
                      If ast_bks_csr%NOTFOUND Then
                          --dbms_output.put_line('Book information not found for asset..');
                          --no need to raise error here
                          null;
                      Else
                          l_adjust_cost := (-1)* l_asset_cost;
                          --Bug # 2657558
                          l_adj_salvage_value := (-1)*l_salvage_value;
                          --Bug #2774529:
                          --Bug# 2981308 :
                          l_adj_percent_sv := (-1)*l_percent_sv;
                          IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0 and nvl(l_adj_percent_sv,0) = 0 Then
                             Null;
                          Else
                              -- to_make asset cost zero
                              FIXED_ASSET_ADJUST_COST
                                     (p_api_version    => p_api_version,
                                      p_init_msg_list  => p_init_msg_list,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
		                      p_chr_id         => p_chrv_id,
                                      p_asset_id       => l_asset_hdr_rec.asset_id,
                                      p_book_type_code => l_book_type_code,
                                      p_adjust_cost    => l_adjust_cost,
                                      --Bug # 2657558
                                      p_adj_salvage_value => l_adj_salvage_value,
                                      -- Bug Fix# 2925461
                                      --Bug# 2981308
                                      p_adj_percent_sv    => l_adj_percent_sv,
                                      p_trans_number      => l_trans_number,
                                      p_calling_interface => l_calling_interface,
                                      --Bug# 4028371:
                                      x_fa_trx_date       => l_fa_adj_date_corp,
                                      --Bug# 3156924
                                      p_adj_date          => l_talv_rec.in_service_date,
              --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              p_sla_source_line_id      => l_talv_rec.id,
              p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources
                                      x_asset_fin_rec  => l_asset_fin_rec);
                               --dbms_output.put_line('After fixed asset adjust Corp Bk for ST Lease :'||x_return_status);
                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;
                           End If;
                           --Bug #2774529:  End
                      End If;
                      Close ast_bks_csr;

                      --2. for tax books
                      Open  ast_bks_csr(p_asset_id    => l_asset_hdr_rec.asset_id,
                                        p_book_class  => G_FA_TAX_BOOK_CLASS_CODE);
                      Loop
                          --Bug# 2657558 : selecting salvage_value
                          Fetch ast_bks_csr into
                                                 l_book_type_code,
                                                 l_asset_cost,
                                                 l_salvage_value,
                                                 --Bug# 2981308
                                                 l_percent_sv;
                          Exit When ast_bks_csr%NOTFOUND;

                          --Bug# 11.5.9: Multi-GAAP Check for reporting book added
                          --cost has to be preserved in Tax Book
                          If l_book_type_code = nvl(l_rep_pdt_book,'NO_BOOK')  Then
                              Null;
                          Else
                              l_adjust_cost := (-1)* l_asset_cost;
                              --Bug # 2657558
                              l_adj_salvage_value := (-1)*l_salvage_value;
                              --Bug# 2774529:
                              --Bug# 3156924:
                              l_adj_percent_sv    := (-1)*l_percent_sv;
                              --Bug# 3156924
                              IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0 and nvl(l_adj_percent_sv,0) = 0 Then
                                  Null;
                              Else

                                  --Bug# 6373605
                                  Open l_txd_for_book_csr (p_book_type_code =>
l_book_type_code,
                                                           p_tal_id         =>
l_talv_rec.id);
                                  Fetch l_txd_for_book_csr into
l_txd_for_book_rec;
                                  If l_txd_for_book_csr%NOTFOUND then
                                     l_sla_source_line_table :=
'OKL_TXL_ASSETS_B';
                                     l_sla_source_line_id := l_talv_rec.id;
                                  Else
                                     l_sla_source_line_table :=
'OKL_TXD_ASSETS_B';
                                     l_sla_source_line_id :=
l_txd_for_book_rec.id;
                                  End If;
                                  Close l_txd_for_book_csr;
                                  --Bug # 6373605 end;
                                  -- to_make asset cost zero
                                  FIXED_ASSET_ADJUST_COST
                                     (p_api_version    => p_api_version,
                                      p_init_msg_list  => p_init_msg_list,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
				                      p_chr_id         => p_chrv_id,
                                      p_asset_id       => l_asset_hdr_rec.asset_id,
                                      p_book_type_code => l_book_type_code,
                                      p_adjust_cost    => l_adjust_cost,
                                      --Bug # 2657558
                                      p_adj_salvage_value => l_adj_salvage_value,
                                     --Bug# 2981308
                                      p_adj_percent_sv    => l_adj_percent_sv,
                                      --Bug# 3156924
                                      p_trans_number      => l_trans_number,
                                      p_calling_interface => l_calling_interface,
                                      --Bug# 4028371:
                                      x_fa_trx_date       => l_fa_adj_date_tax,
                                      -- Bug Fix# 2925461
                                      p_adj_date          => l_talv_rec.in_service_date,
              --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              p_sla_source_line_id      => l_sla_source_line_id,
              p_sla_source_line_table   => l_sla_source_line_table,
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources
                                      x_asset_fin_rec     => l_asset_fin_rec);
                                  --dbms_output.put_line('After fixed asset adjust for Tax bk ST Lease :'||x_return_status);
                                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                      RAISE OKL_API.G_EXCEPTION_ERROR;
                                  END IF;
                               End If;
                               --Bug# 2774529: End
                          End If;
                      End Loop; -- for tax books
                      Close ast_bks_csr;
                      --dbms_output.put_line('Deal Type Leasest :'||l_deal_type);

                  --Bug # : 11.i.9 enhancements - DF an ST lease treatment as to be same
                  --Elsif l_Deal_Type = G_DF_LEASE_BK_CLASS Then
                  ElsIf l_Deal_Type in  (G_DF_LEASE_BK_CLASS, G_ST_LEASE_BK_CLASS) Then
                      --Get Tax Owner
                      --dbms_output.put_line('Deal Type Leasedf :'||l_deal_type);

                      -- Bug# 3838403
                      -- Replaced call to OKL_RULE_APIS_PUB.Get_rule_Segment_Value
                      -- with cursor town_rul_csr
                      --Bug# 5261704: Moved to the top of this procedure
                      /*--------------------------------------------
                      Open town_rul_csr(pchrid => p_chrv_id);
                      Fetch town_rul_csr into l_town_rul, l_town_rul_id;
                      Close town_rul_csr;

                      l_name := rtrim(ltrim(l_town_rul,' '),' ');
                      ---------------------------------------------*/

                      /*OKL_RULE_APIS_PUB.Get_rule_Segment_Value
                               (p_api_version => p_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => x_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_chr_id          => p_chrv_id,
                                p_cle_id          => null,
                                p_rgd_code        => l_rgd_code,
                                p_rdf_code        => l_rdf_code,
                                --Bug#2525946
                                --p_rdf_name        => l_rdf_name,
                                p_segment_number  => l_segment_number,
                                x_id1             => l_id1,
                                x_id2             => l_id2,
                                x_name            => l_name,
                                x_description     => l_description,
                                x_status          => l_status,
                                x_start_date      => l_start_date,
                                x_end_date        => l_end_date,
                                x_org_id          => l_org_id,
                                x_inv_org_id      => l_inv_org_id,
                                x_book_type_code  => l_book_type_code,
                                x_select          => l_select);
                         --dbms_output.put_line('TAX Owner :'||l_name);
                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;*/

                         If upper(l_tax_owner) = 'LESSOR' Then
                             --call the adjustment api to set the cost to zero in corp book only
                             Open  ast_bks_csr(p_asset_id    => l_asset_hdr_rec.asset_id,
                                               p_book_class  => G_FA_CORP_BOOK_CLASS_CODE);
                             --Bug# 2657558 : selecting salvage_value
                             Fetch ast_bks_csr into
                                               l_book_type_code,
                                               l_asset_cost,
                                               l_salvage_value,
                                               --Bug# 3156924
                                               l_percent_sv;
                             If ast_bks_csr%NOTFOUND Then
                                 --dbms_output.put_line('Book information not found for asset..');
                                 -- no need to raise error
                                 null;
                             Else
                                 l_adjust_cost := (-1)* l_asset_cost;
                                 --Bug # 2657558
                                 l_adj_salvage_value := (-1)*l_salvage_value;
                                 --Bug# 2981308
                                 l_adj_percent_sv := (-1)*l_percent_sv;
                                 IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0 and nvl(l_adj_percent_sv,0) = 0 Then
                                     Null;
                                 Else
                                     -- to_make asset cost zero
                                     FIXED_ASSET_ADJUST_COST
                                             (p_api_version    => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                              p_chr_id         => p_chrv_id,
                                              p_asset_id       => l_asset_hdr_rec.asset_id,
                                              p_book_type_code => l_book_type_code,
                                              p_adjust_cost    => l_adjust_cost,
                                              --Bug 2657558
                                              p_adj_salvage_value => l_adj_salvage_value,
                                              --Bug# 2981308
                                              p_adj_percent_sv    => l_adj_percent_sv,
                                              --Bug# 3156924
                                              p_trans_number      => l_trans_number,
                                              p_calling_interface => l_calling_interface,
                                              --Bug# 4028371:
                                              x_fa_trx_date       => l_fa_adj_date_corp,
                                              -- Bug Fix# 2925461
                                              p_adj_date       => l_talv_rec.in_service_date,
              --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              p_sla_source_line_id      => l_talv_rec.id,
              p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources
                                              x_asset_fin_rec  => l_asset_fin_rec);
                                       --dbms_output.put_line('After fixed asset adjust for Direct Fin Lease :'||x_return_status);
                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                         RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;
                                  End If;
                                  --Bug# End
                             End If;
                             Close ast_bks_csr;
                         Elsif upper(l_tax_owner) = 'LESSEE' Then
                             --call the adjustment api to set the cost to zero in corp and tax book
                             -- 1. for corporate cook
                             Open  ast_bks_csr(p_asset_id    => l_asset_hdr_rec.asset_id,
                                               p_book_class  => G_FA_CORP_BOOK_CLASS_CODE);
                             --Bug# 2657558 : selecting salvage_value
                             Fetch ast_bks_csr into
                                                 l_book_type_code,
                                                 l_asset_cost,
                                                 l_salvage_value,
                                                 --Bug# 2981308
                                                 l_percent_sv;
                             If ast_bks_csr%NOTFOUND Then
                                 --dbms_output.put_line('Book information not found for asset..');
                                 --no need to raise  error
                                 null;
                             Else
                                 l_adjust_cost := (-1)* l_asset_cost;
                                 --Bug # 2657558
                                 l_adj_salvage_value := (-1)*l_salvage_value;
                                 --Bug# 2981308
                                 l_adj_percent_sv := (-1)*l_percent_sv;
                                 --Bug 2774529#
                                 IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0 and nvl(l_adj_percent_sv,0) = 0 Then
                                     Null;
                                 Else
                                 -- to_make asset cost zero
                                     FIXED_ASSET_ADJUST_COST
                                             (p_api_version    => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
               	                              p_chr_id         => p_chrv_id,
                                              p_asset_id       => l_asset_hdr_rec.asset_id,
                                              p_book_type_code => l_book_type_code,
                                              p_adjust_cost    => l_adjust_cost,
                                              --Bug # 2657558
                                              p_adj_salvage_value => l_adj_salvage_value,
                                              --Bug# 2981308
                                              p_adj_percent_sv    => l_adj_percent_sv,
                                              --Bug# 3156924
                                              p_trans_number      => l_trans_number,
                                              p_calling_interface => l_calling_interface,
                                              --Bug# 4028371
                                              x_fa_trx_date       => l_fa_adj_date_corp,
                                              -- Bug Fix# 2925461
                                              p_adj_date       => l_talv_rec.in_service_date,
             --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              p_sla_source_line_id      => l_talv_rec.id,
              p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources
                                              x_asset_fin_rec  => l_asset_fin_rec);
                                     --dbms_output.put_line('After fixed asset adjust Corp Bk for DF Lease :'||x_return_status);
                                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                         RAISE OKL_API.G_EXCEPTION_ERROR;
                                     END IF;
                                 End If;
                                 --Bug#2774529 End
                             End If;
                             Close ast_bks_csr;

                             --2. for tax books
                             Open  ast_bks_csr(p_asset_id    => l_asset_hdr_rec.asset_id,
                                               p_book_class  => G_FA_TAX_BOOK_CLASS_CODE);
                             Loop
                                 --Bug# 2657558 : selecting salvage_value
                                 Fetch ast_bks_csr into
                                                     l_book_type_code,
                                                     l_asset_cost,
                                                     l_salvage_value,
                                                     --Bug 3156924
                                                     l_percent_sv;
                                 Exit When ast_bks_csr%NOTFOUND;
                                 --Bug : 11.i.9 enhanceent
                                 --check if tax book is a reporting product book
                                 -- if t is do not update te cost to zero
                                 If nvl(l_rep_pdt_book,'NO_BOOK') = l_book_type_code Then
                                     Null;
                                 Else
                                     l_adjust_cost := (-1)* l_asset_cost;
                                     --Bug # 2657558
                                     l_adj_salvage_value := (-1)*l_salvage_value;
                                     --Bug# 2774529
                                     --Bug# 2981308
                                     l_adj_percent_sv := (-1) * l_percent_sv;
                                     IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0 and nvl(l_adj_percent_sv,0) = 0 Then
                                         Null;
                                     Else
                                         --Bug# 6373605
                                         Open l_txd_for_book_csr (p_book_type_code =>
l_book_type_code,
                                                                  p_tal_id         =>
l_talv_rec.id);
                                         Fetch l_txd_for_book_csr into
l_txd_for_book_rec;
                                         If l_txd_for_book_csr%NOTFOUND then
                                            l_sla_source_line_table :=
'OKL_TXL_ASSETS_B';
                                            l_sla_source_line_id := l_talv_rec.id;
                                         Else
                                            l_sla_source_line_table :=
'OKL_TXD_ASSETS_B';
                                            l_sla_source_line_id :=
l_txd_for_book_rec.id;
                                         End If;
                                         Close l_txd_for_book_csr;
                                         --Bug # 6373605 end;

                                         FIXED_ASSET_ADJUST_COST
                                             (p_api_version    => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
            	                              p_chr_id         => p_chrv_id,
                                              p_asset_id       => l_asset_hdr_rec.asset_id,
                                              p_book_type_code => l_book_type_code,
                                              p_adjust_cost    => l_adjust_cost,
                                              --Bug # 2657558
                                              p_adj_salvage_value => l_adj_salvage_value,
                                              --Bug# 2981308
                                              p_adj_percent_sv    => l_adj_percent_sv,
                                              --Bug# 3156924
                                              p_trans_number      => l_trans_number,
                                              p_calling_interface => l_calling_interface,
                                              --Bug# 4028371:
                                              x_fa_trx_date       => l_fa_adj_date_tax,
                                              -- Bug Fix# 2925461
                                              p_adj_date       => l_talv_rec.in_service_date,
                  --Bug# 6373605--SLA populate source
                  p_sla_source_header_id    => l_tas_id,
                  p_sla_source_header_table => 'OKL_TRX_ASSETS',
                  p_sla_source_try_id       => l_try_id,
                  p_sla_source_line_id      => l_sla_source_line_id,
                  p_sla_source_line_table   => l_sla_source_line_table,
                  p_sla_source_chr_id       => p_chrv_id,
                  p_sla_source_kle_id       => p_fin_ast_line_id,
                  p_sla_asset_chr_id        => p_sla_asset_chr_id,
                  --Bug# 6373605--SLA populate sources
                                              x_asset_fin_rec  => l_asset_fin_rec);
                                         --dbms_output.put_line('After fixed asset adjust for Tax bk DF Lease :'||x_return_status);
                                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                             RAISE OKL_API.G_EXCEPTION_ERROR;
                                         END IF;
                                      End If;
                                      --Bug# 2774529 End
                                 End If;
                             End Loop; -- for tax books
                             Close ast_bks_csr;
                         End if; -- if LESSEE
                     Else
                         --dbms_output.put_line('in else for operating lease');
                         null;
                     End If; --if deal_type

                     --Bug# 3574232 start
                     -- If the reporting product is DF/ST lease, the asset
                     -- should be created and written to zero in the reporting
                     -- book.
                     If (l_Multi_GAAP_YN = 'Y' and p_adjust_asset_to_zero = 'Y') Then

                       Open okx_ast_csr(p_asset_id  => l_asset_hdr_rec.asset_id,
                                        p_book_type_code => l_rep_pdt_book);
                       Fetch okx_ast_csr into okx_ast_rec;
                       If okx_ast_csr%NotFound Then
                         Close okx_ast_csr;
                       Else
                         Close okx_ast_csr;
                         l_adjust_cost := (-1)* okx_ast_rec.cost;
                         l_adj_salvage_value := (-1)*okx_ast_rec.salvage_value;
                         l_adj_percent_sv := (-1)*okx_ast_rec.percent_salvage_value;

                         IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0
                            and nvl(l_adj_percent_sv,0) = 0 Then
                            Null;
                         ELSE
                            --Bug# 6373605
                            Open l_txd_for_book_csr (p_book_type_code =>
l_rep_pdt_book,
                                                     p_tal_id         =>
l_talv_rec.id);
                            Fetch l_txd_for_book_csr into
l_txd_for_book_rec;
                            If l_txd_for_book_csr%NOTFOUND then
                               l_sla_source_line_table :=
'OKL_TXL_ASSETS_B';
                               l_sla_source_line_id := l_talv_rec.id;
                            Else
                               l_sla_source_line_table :=
'OKL_TXD_ASSETS_B';
                               l_sla_source_line_id :=
l_txd_for_book_rec.id;
                            End If;
                            Close l_txd_for_book_csr;
                            --Bug # 6373605 end;

                            FIXED_ASSET_ADJUST_COST
                            (p_api_version       => p_api_version,
                             p_init_msg_list     => p_init_msg_list,
                             x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data,
                             p_chr_id            => p_chrv_id,
                             p_asset_id          => l_asset_hdr_rec.asset_id,
                             p_book_type_code    => l_rep_pdt_book,
                             p_adjust_cost       => l_adjust_cost,
                             p_adj_salvage_value => l_adj_salvage_value,
                             p_adj_percent_sv    => l_adj_percent_sv,
                             p_trans_number      => l_trans_number,
                             p_calling_interface => l_calling_interface,
                             --Bug# 4028371 :
                             x_fa_trx_date       => l_fa_adj_date_mg,
                             p_adj_date          => okx_ast_rec.in_service_date,
              --Bug# 6373605--SLA populate source
              p_sla_source_header_id    => l_tas_id,
              p_sla_source_header_table => 'OKL_TRX_ASSETS',
              p_sla_source_try_id       => l_try_id,
              p_sla_source_line_id      => l_sla_source_line_id,
              p_sla_source_line_table   => l_sla_source_line_table,
              p_sla_source_chr_id       => p_chrv_id,
              p_sla_source_kle_id       => p_fin_ast_line_id,
              p_sla_asset_chr_id        => p_sla_asset_chr_id,
              --Bug# 6373605--SLA populate sources
                             x_asset_fin_rec     => l_asset_fin_rec);

                             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                             END IF;
                         END IF;
                       End if;
                     End if;
                     --Bug# 3574232 end

                     If ( (l_Multi_GAAP_YN = 'Y') OR
		          (G_CHR_REPORT_PDT_ID <> -1 ) ) Then

                         l_chrv_rec.id := p_chrv_id;
                         l_khrv_rec.id := p_chrv_id;
                         l_khrv_rec.multi_gaap_yn := 'Y';

                         okl_contract_pub.update_contract_header(
                                             p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_chrv_rec      => l_chrv_rec,
                                             p_khrv_rec      => l_khrv_rec,
				             p_edit_mode     => 'N',
                                             x_chrv_rec      => x_chrv_rec,
                                             x_khrv_rec      => x_khrv_rec);

                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;

                     End If;


                     --update the trx type for this record to processed
                     --dbms_output.put_line('transaction id to update '||l_talv_rec.tas_id);
                     update_trx_status(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
	                                   x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_tas_id        => l_talv_rec.tas_id,
                                       p_tsu_code      => G_TSU_CODE_PROCESSED);

                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      --Bug# 4028371
                      --update the fa trx date on transaction line
                      l_talv_date_rec.id     := l_talv_rec.id;
                      l_talv_date_rec.fa_trx_date := l_fa_add_date_corp;

                      okl_tal_pvt.update_row
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_talv_rec      => l_talv_date_rec,
                                         x_talv_rec      => lx_talv_date_rec);
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                      --End Bug# 4028371
                  End If;--if asset transaction records found
               End If; --if unplugged okc_k_items records for fa line
    End If; --fa line is found
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End Process_FA_Line;
--------------------------------------------------------------------------------
--Start of comments
--Procedure Name : Get_Pdt_Params (local)
--Description    : 11.5.9 Enhancement Multi-GAAP - Calls product api to fetch
--                 product specific parameters
--History        : 27-Nov-2002  ashish.singh Created
--Notes          : local procedure
--                 IN Parameters-
--                               p_pdt_id - product id
--                               p_pdt_date - product effective date
--                 OUT Parameters -
--                               x_rep_pdt_id    - Reporting product id
--                               x_tax_owner     - tax owner
--                               x_rep_deal_type - Reporting product deal type
--End of comments
--------------------------------------------------------------------------------
Procedure Get_Pdt_Params (p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_pdt_id        IN  NUMBER,
                          p_pdt_date      IN  DATE,
                          x_rep_pdt_id    OUT NOCOPY NUMBER,
                          x_tax_owner     OUT NOCOPY VARCHAR2,
                          x_rep_deal_type OUT NOCOPY VARCHAR2) is

l_pdtv_rec                okl_setupproducts_pub.pdtv_rec_type;
l_pdt_parameter_rec       okl_setupproducts_pub.pdt_parameters_rec_type;
l_rep_pdt_parameter_rec   okl_setupproducts_pub.pdt_parameters_rec_type;
l_pdt_date                DATE;
l_no_data_found           BOOLEAN;
l_error_condition         Exception;
l_return_status           VARCHAR2(1) default OKL_API.G_RET_STS_SUCCESS;
Begin
     l_pdtv_rec.id    := p_pdt_id;
     l_pdt_date       := p_pdt_date;
     l_no_data_found  := TRUE;
     x_return_status  := OKL_API.G_RET_STS_SUCCESS;

     okl_setupproducts_pub.Getpdt_parameters(p_api_version      => p_api_version,
                                             p_init_msg_list     => p_init_msg_list,
                      			             x_return_status     => l_return_status,
            			                     x_no_data_found     => l_no_data_found,
                              		         x_msg_count         => x_msg_count,
                              		         x_msg_data          => x_msg_data,
					                         p_pdtv_rec          => l_pdtv_rec,
					                         p_product_date      => l_pdt_date,
					                         p_pdt_parameter_rec => l_pdt_parameter_rec);

     IF l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
         x_rep_pdt_id    := Null;
         x_tax_owner     := Null;
     --Bug# 4775166
     Elsif l_pdt_parameter_rec.reporting_pdt_id IS NULL Then
         x_rep_pdt_id    := Null;
         x_tax_owner     := l_pdt_parameter_rec.tax_owner;
         x_rep_deal_type := Null;
     Else
         x_rep_pdt_id    := l_pdt_parameter_rec.reporting_pdt_id;
         x_tax_owner     := l_pdt_parameter_rec.tax_owner;
         --get reporting product param values
         l_no_data_found := TRUE;
         l_pdtv_rec.id := x_rep_pdt_id;
         okl_setupproducts_pub.Getpdt_parameters(p_api_version      => p_api_version,
                                                 p_init_msg_list     => p_init_msg_list,
                                                 x_return_status     => l_return_status,
                                                 x_no_data_found     => l_no_data_found,
                                 		         x_msg_count         => x_msg_count,
                                 		         x_msg_data          => x_msg_data,
    					                         p_pdtv_rec          => l_pdtv_rec,
    					                         p_product_date      => l_pdt_date,
    					                         p_pdt_parameter_rec => l_rep_pdt_parameter_rec);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
             x_rep_deal_type := NULL;
          Else
             x_rep_deal_type :=  l_rep_pdt_parameter_rec.deal_type;
          End If;
     End If;

     Exception
     When l_error_condition Then
          Null;
     When Others Then
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
End Get_Pdt_Params;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : ACTIVATE_ASSET
--Description    : Selects the 'CFA' - Create Asset Transaction from a ready to be
--                 Booked Contract which has passed Approval
--                 and created assets in FA
--
--History        :
--                 03-Nov-2001  ashish.singh Created
--                 27-Nov-2002  ashish.singh 11.5.9 enhacements
-- Notes         :
--      IN Parameters -
--                     p_chr_id    - contract id to be activated
--                     p_call_mode - 'BOOK' for booking
--                                   'REBOOK' for rebooking
--                                   'RELEASE' for release
--                    x_cimv_tbl   - OKC line source table showing
--                                   fa links in ID1 , ID2 columns
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE ACTIVATE_ASSET(p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_chrv_id       IN  NUMBER,
                         p_call_mode     IN  VARCHAR2,
                         x_cimv_tbl      OUT NOCOPY cimv_tbl_type) IS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'ACTIVATE_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;
l_fa_lty_code          Varchar2(30) := G_FA_LINE_LTY_CODE;
l_trx_type             Varchar2(30) := G_TRX_LINE_TYPE_BOOK;

l_hdr_rec              l_hdr_csr%ROWTYPE;

--cursor to verify the subclass code
--contract has to be a 'LEASE' subclass contract to qualify for FA_ADDITION
Cursor chk_subclass_csr(p_chrv_id IN NUMBER) is
SELECT chr.SCS_CODE,
       chr.STS_CODE,
       khr.DEAL_TYPE,
--11.5.9(Multi GAAP)
       khr.PDT_ID,
       chr.START_DATE
From   OKC_K_HEADERS_B chr,
       OKL_K_HEADERS   khr
WHERE  khr.id = chr.id
AND    chr.ID = P_CHRV_ID;

--cursor for fetching passed fixed asset lines
--within the contract
--Bug# 4899328
Cursor fa_line_csr(p_chrv_id IN Number) is
SELECT cle.id,
       cle.cle_id
from   okc_k_lines_b cle,
       okc_statuses_b sts
where  cle.lse_id = G_FA_LINE_LTY_ID
and    cle.dnz_chr_id = p_chrv_id
and    cle.sts_code = sts.code
and    sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

l_scs_code          Varchar2(30);
l_sts_code          Varchar2(30);
l_deal_type         Varchar2(30);
l_cimv_rec          cimv_rec_type;
l_fa_line_id        Number;
l_fin_ast_line_id   Number;
l_asst_count        Number default 0;
--11.5.9 (Multi GAAP)
l_pdt_id            Number;
l_start_date        Date;
l_rep_pdt_id        Number;
l_tax_owner         Varchar2(150);
l_rep_deal_type     Varchar2(150);
l_Multi_GAAP_YN     Varchar2(1);
l_rep_pdt_book      OKX_AST_BKS_V.Book_Type_Code%Type;
--cursor to get tax owner rule
Cursor town_rul_csr (pchrid number) is
Select rule_information1 tax_owner,
       id
From   okc_rules_b rul
where  rul.dnz_chr_id = pchrid
and    rul.rule_information_category = 'LATOWN'
and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

l_town_rul      okc_rules_b.rule_information1%TYPE;
l_town_rul_id   okc_rules_b.id%TYPE;

--Bug# 3156924
l_trans_number       okl_trx_assets.trans_number%TYPE := Null;
l_calling_interface  varchar2(30) :=  'OKLRACAB:Booking';

--Bug# 3574232
l_adjust_asset_to_zero varchar2(30);

TYPE fa_line_id_tbl is table of okc_k_lines_b.id%TYPE INDEX BY BINARY_INTEGER;
l_fa_line_id_tbl    fa_line_id_tbl;

TYPE fin_ast_line_id_tbl is table of okc_k_lines_b.cle_id%TYPE INDEX BY BINARY_INTEGER;
l_fin_ast_line_id_tbl fin_ast_line_id_tbl;

TYPE fin_asst_rec_type IS RECORD (
     fa_line_id          OKC_K_LINES_B.id%TYPE    ,
     fin_ast_line_id     OKC_K_LINES_B.cle_id %TYPE);

TYPE fin_asst_tbl_type IS TABLE OF fin_asst_rec_type  INDEX BY BINARY_INTEGER;
l_fin_asst_tbl      fin_asst_tbl_type;
l_counter NUMBER;
l_loop_index NUMBER;



BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    Open chk_subclass_csr(p_chrv_id);
        Fetch chk_subclass_csr into l_scs_code, l_sts_code, l_deal_type, l_pdt_id, l_start_date;
        If chk_subclass_csr%NOTFOUND Then
           --dbms_output.put_line('Contract Not Found ....!');
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_CONTRACT_NOT_FOUND,
				               p_token1       => G_CONTRACT_ID,
				               p_token1_value => to_char(p_chrv_id)
				               );
           RAISE OKL_API.G_EXCEPTION_ERROR;
           --Handle error appropriately
        ElsIf upper(l_sts_code) <> G_APPROVED_STS_CODE Then
           --dbms_output.put_line('Contract has not been approved...!');
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_CONTRACT_NOT_APPROVED
				               );
           RAISE OKL_API.G_EXCEPTION_ERROR;
           --Raise appropraite error message
        ElsIf l_scs_code <> G_LEASE_SCS_CODE and upper(l_sts_code) = G_APPROVED_STS_CODE Then
             --dbms_output.put_line('Contract is not a lease contract...!');
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                 p_msg_name     => G_CONTRACT_NOT_LEASE
				                 );
           RAISE OKL_API.G_EXCEPTION_ERROR;
            --Raise appropriate error message or do nothing
        ElsIf l_scs_code = G_LEASE_SCS_CODE  and upper(l_sts_code) = G_APPROVED_STS_CODE Then
            --Bug# : 11.5.9 enhancement Multi-Gaap :to create FA for reporting book
            --If l_deal_type in (G_LOAN_BK_CLASS,G_REVOLVING_LOAN_BK_CLASS) Then
            If l_deal_type in (G_REVOLVING_LOAN_BK_CLASS) Then
                --nothing to be done for these deal types
                Null;
            Else
            --Bug# :11.5.9 : Multi-GAAP Begin
            Get_Pdt_Params (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_pdt_id        => l_pdt_id,
                            p_pdt_date      => l_start_date,
                            x_rep_pdt_id    => l_rep_pdt_id,
                            x_tax_owner     => l_tax_owner,
                            x_rep_deal_type => l_rep_deal_type);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            If l_tax_owner is null then
               Open town_rul_csr(pchrid => p_chrv_id);
               Fetch town_rul_csr into l_town_rul,
                                       l_town_rul_id;
               If town_rul_csr%NOTFOUND Then
                  OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Tax Owner');
                   x_return_status := OKC_API.G_RET_STS_ERROR;
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               Else
                   l_tax_owner := rtrim(ltrim(l_town_rul,' '),' ');
               End If;
               Close town_rul_csr;
            End If;

            OPEN l_hdr_csr( p_chrv_id );
            FETCH l_hdr_csr INTO l_hdr_rec;
            CLOSE l_hdr_csr;

	    G_CHR_CURRENCY_CODE := l_hdr_rec.currency_code;
	    G_FUNC_CURRENCY_CODE := okl_accounting_util.get_func_curr_code;
	    G_CHR_AUTHORING_ORG_ID  := l_hdr_rec.authoring_org_id;
	    G_CHR_START_DATE    := l_hdr_rec.start_date;
	    G_CHR_REPORT_PDT_ID := l_hdr_rec.report_pdt_id;

            l_Multi_GAAP_YN := 'N';
            -- Bug# 3574232
            l_adjust_asset_to_zero := 'N';
            --checks wheter Multi-GAAP processing needs tobe done
            If l_rep_pdt_id is not NULL Then

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.
                   l_Multi_GAAP_YN := 'Y';
/*
               If l_deal_type = 'LEASEOP' and
               nvl(l_rep_deal_type,'X') = 'LEASEOP' and
               nvl(l_tax_owner,'X') = 'LESSOR' Then
                   l_Multi_GAAP_YN := 'Y';
               End If;

               If l_deal_type in ('LEASEDF','LEASEST') and
               nvl(l_rep_deal_type,'X') = 'LEASEOP' and
               nvl(l_tax_owner,'X') = 'LESSOR' Then
                   l_Multi_GAAP_YN := 'Y';
               End If;

               If l_deal_type in ('LEASEDF','LEASEST') and
               nvl(l_rep_deal_type,'X') = 'LEASEOP' and
               nvl(l_tax_owner,'X') = 'LESSEE' Then
                   l_Multi_GAAP_YN := 'Y';
               End If;

               If l_deal_type = 'LOAN' and
               nvl(l_rep_deal_type,'X') = 'LEASEOP' and
               nvl(l_tax_owner,'X') = 'LESSEE' Then
                   l_Multi_GAAP_YN := 'Y';
               End If;
*/
               -- Bug# 3574232 start
               -- If the reporting product is DF/ST lease, the asset should
               -- be created and written to zero in the reporting book.

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.


               If l_deal_type = 'LEASEOP' and
               nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
               nvl(l_tax_owner,'X') = 'LESSOR' Then
                   --l_Multi_GAAP_YN := 'Y';
                   l_adjust_asset_to_zero := 'Y';
               End If;

               If l_deal_type in ('LEASEDF','LEASEST') and
               nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
               nvl(l_tax_owner,'X') = 'LESSOR' Then
                   --l_Multi_GAAP_YN := 'Y';
                   l_adjust_asset_to_zero := 'Y';
               End If;

               If l_deal_type in ('LEASEDF','LEASEST') and
               nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
               nvl(l_tax_owner,'X') = 'LESSEE' Then
                   --l_Multi_GAAP_YN := 'Y';
                   l_adjust_asset_to_zero := 'Y';
               End If;
               -- Bug# 3574232 end
            End If;

            If l_Multi_GAAP_YN = 'Y' Then
                --get reporting product book type
                l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
            End If;

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.


            If ((l_deal_type = 'LOAN') --and nvl(l_Multi_GAAP_YN,'N') = 'N')
              OR (l_deal_type = 'LOAN_REVOLVING'))  Then
                Null;
                --Assets will not be activatted for LOANS which are not Multi-GAAP
            Else
            --Bug# :11.5.9 : Multi-GAAP End
                -- get the transaction records

                l_asst_count := 1;
		l_counter := 1;

		Open fa_line_csr(p_chrv_id);

                Loop
		    l_fa_line_id_tbl.delete;
		    l_fin_ast_line_id_tbl.delete;

                    Fetch fa_line_csr BULK COLLECT
		    into l_fa_line_id_tbl, l_fin_ast_line_id_tbl
		    LIMIT G_BULK_BATCH_SIZE;

		    if (l_fa_line_id_tbl.COUNT > 0) then
		       for i in l_fa_line_id_tbl.FIRST .. l_fa_line_id_tbl.LAST LOOP
                         l_fin_asst_tbl(l_counter).fa_line_id := l_fa_line_id_tbl(i);
                         l_fin_asst_tbl(l_counter).fin_ast_line_id := l_fin_ast_line_id_tbl(i);
			 l_counter := l_counter + 1;
		       End Loop;
		    end if;

                    Exit When fa_line_csr%NotFound;
                End Loop;
		CLOSE fa_line_csr;

		IF (l_fin_asst_tbl.COUNT > 0) THEN

		  l_loop_index := l_fin_asst_tbl.FIRST;
		  LOOP
		    l_fa_line_id := l_fin_asst_tbl(l_loop_index).fa_line_id;
		    l_fin_ast_line_id := l_fin_asst_tbl(l_loop_index).fin_ast_line_id;


                    Process_FA_Line (p_api_version       => p_api_version,
                                     p_init_msg_list     => p_init_msg_list,
                                     x_return_status     => x_return_status,
                                     x_msg_count         => x_msg_count,
                                     x_msg_data          => x_msg_data,
                                     p_chrv_id           => p_chrv_id,
                                     p_fa_line_id        => l_fa_line_id,
                                     p_fin_ast_line_id   => l_fin_ast_line_id,
                                     p_deal_type         => l_deal_type,
                                     p_trx_type          => l_trx_type,
                                     --Bug : 11.5.9 Multi GAAP Begin
                                     p_multi_GAAP_YN     => l_Multi_GAAP_YN,
                                     p_rep_pdt_book      => l_rep_pdt_book,
                                     --Bug : 11.5.9 Multi GAAP end
                                     --Bug# 3574232
                                     p_adjust_asset_to_zero => l_adjust_asset_to_zero,
                                     --Bug# 3156924
                                     p_trans_number      => to_char(l_trans_number),
                                     p_calling_interface => l_calling_interface,
                                     --Bug# 6373605 startd
                                     p_sla_asset_chr_id  => p_chrv_id,
                                     --Bug# 6373605 end
                                     x_cimv_rec          => l_cimv_rec);


                    --dbms_output.put_line('after process fa line '||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                    x_cimv_tbl(l_asst_count) := l_cimv_rec;
                    l_asst_count := l_asst_count+1;

		    EXIT WHEN l_loop_index = l_fin_asst_tbl.LAST;
		    l_loop_index := l_fin_asst_tbl.NEXT(l_loop_index);

                End Loop; -- fa line csr
               End IF;

            End if; --for deal type = 'LOAN' and no Multi-GAAP

        End If; -- for deal types
    Close chk_subclass_csr;
    End If;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
      CLOSE l_hdr_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
      CLOSE l_hdr_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If ( l_hdr_csr%ISOPEN ) Then
      CLOSE l_hdr_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

END ACTIVATE_ASSET;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name :  REBOOK_ASSET (Activate code branch for rebook)
--Description    :  Will be called from activate asset and make rebook adjustments
--                  in FA
--History        :
--                 21-Mar-2002  ashish.singh Created
--                 27-Nov-2002  ashish.singh Bug# : 11.5.9 enhancements
--                                                1. Multi-GAAP
-- Notes         :
--      IN Parameters -
--                     p_rbk_chr_id    - contract id of rebook copied contract
--
--                     This APi should be called after syncronization of copied k
--                     to the original (being re-booked ) K
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE REBOOK_ASSET  (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rbk_chr_id    IN  NUMBER
                        ) IS

   l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
   l_api_name             CONSTANT varchar2(30) := 'REBOOK_ASSET';
   l_api_version          CONSTANT NUMBER := 1.0;
   l_trx_type             Varchar2(30) := G_TRX_LINE_TYPE_REBOOK;

   --Cursor to get the rebook transaction reason codes
   CURSOR rbr_code_csr (p_rbk_chr_id IN NUMBER) IS
   SELECT ktrx.rbr_code,
          ktrx.date_transaction_occurred,
          khr.deal_type,
          chr.id,
          chr.sts_code,
          rul.rule_information1,
--Bug# : 11.5.9 Multi-GAAP
          khr.pdt_id,
          chr.start_date,
--Bug# 3156924
          ktrx.trx_number
   FROM   OKC_RULES_B       rul,
          OKL_K_HEADERS     khr,
          OKC_K_HEADERS_B   chr,
          OKL_TRX_CONTRACTS ktrx,
          OKC_K_HEADERS_B   rbk_chr
   WHERE  rul.dnz_chr_id                  = chr.id
   AND    rul.rule_information_category   = 'LATOWN'
   AND    khr.id                          = chr.id
   AND    chr.id                          = rbk_chr.orig_system_id1
   AND    exists (select null
                  from   okl_trx_types_tl tl
                  where  tl.language = 'US'
                  and    tl.name = 'Rebook'
                  and    tl.id   = ktrx.try_id)
   AND    ktrx.KHR_ID                      = chr.id
   AND    ktrx.KHR_ID_NEW                 = rbk_chr.id
   AND    ktrx.tsu_code                   = G_TSU_CODE_ENTERED
--rkuttiya added for 12.1.1 Multi GAAP Project
   AND    ktrx.representation_type = 'PRIMARY'
--
   AND    rbk_chr.orig_system_source_code = 'OKL_REBOOK'
   AND    rbk_chr.id                      = p_rbk_chr_id;

   l_rbr_code          OKL_TRX_CONTRACTS.rbr_code%TYPE;
   l_deal_type         OKL_K_HEADERS.deal_type%TYPE;
   l_chr_id            OKC_K_HEADERS_B.ID%TYPE;
   l_sts_code          OKC_K_HEADERS_B.STS_CODE%TYPE;
   l_date_trx_occured  OKL_TRX_CONTRACTS.date_transaction_occurred%TYPE;
   l_tax_owner         OKC_RULES_B.RULE_INFORMATION1%TYPE;
   --Bug# : 11.5.9 enhancement Multi GAAP
   l_pdt_id            OKL_K_HEADERS.pdt_id%TYPE;
   l_start_date        Date;
   l_rep_pdt_id        Number;
   l_pdt_tax_owner         Varchar2(150);
   l_rep_deal_type     Varchar2(150);
   l_Multi_GAAP_YN     Varchar2(1) := 'N';
   l_rep_pdt_book      OKX_AST_BKS_V.Book_Type_Code%Type;
   --Bug# 3156924 :
   l_trx_number        okl_trx_contracts.trx_number%TYPE;
   l_calling_interface varchar2(30) := 'OKL: Rebook';

   --cursor to get the modified transaction values against the rebook contract
   CURSOR adj_txl_csr (p_rbk_chr_id IN NUMBER, p_effective_date IN DATE ) IS
   SELECT txl.in_service_date   in_service_date,
          txl.life_in_months    life_in_months,
          txl.depreciation_cost depreciation_cost,
          txl.depreciation_id   asset_category_id,
          txl.deprn_method      deprn_method,
          txl.deprn_rate        deprn_rate,
          txl.salvage_value     salvage_value,
          txl.corporate_book    book_type_code,
          txl.asset_number      asset_number,
          txl.kle_id            kle_id,
          --bug# 3548044
          txl.tas_id            tas_id,
          txl.salvage_value     corp_salvage_value,
          --Bug# 4028371
          txl.id                tal_id,
          --Bug# 3950089
          txl.percent_salvage_value pct_salvage_value,
          txl.percent_salvage_value corp_pct_salvage_value,
          --Bug# 5207066
          txl.current_units   rbk_current_units,
	  --akrangan bug# 5362977 start
	  cle.cle_id          rbk_fin_ast_cle_id,
	  txl.model_number      model_number,
	  txl.manufacturer_name manufacturer_name,
	  txl.description       description,
          --Bug# 6373605 start
          txl.id  sla_source_line_id,
          txl.tas_id sla_source_header_id,
          'OKL_TXL_ASSETS_B' sla_source_line_table,
          tas.try_id sla_source_try_id,
          --Bug# 6373605 end

          --sechawla : Bug# 8370324
          cle.start_date      line_start_date,
          --Bug# 8652738
          txl.asset_key_id    asset_key_id
      FROM   OKL_TXL_ASSETS_V  txl,
      --akrangan bug# 5362977 end
          --Bug# 6373605 start
          OKL_TRX_ASSETS    tas,
          --Bug# 6373605 end
          OKC_K_LINES_B     cle,
          OKC_LINE_STYLES_B lse
   WHERE  txl.kle_id     = cle.id
   --Bug# 6373605 start
   AND tas.id = txl.tas_id
   --Bug# 6373605 end
   AND    cle.dnz_chr_id = p_rbk_chr_id
   AND    cle.lse_id     = lse.id
   AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                      )
   AND    lse.lty_code   = G_FA_LINE_LTY_CODE
   UNION
   SELECT txl.in_service_date    in_service_date,
          txd.life_in_months_tax life_in_months,
          txd.cost               depreciation_cost,
          txl.depreciation_id    asset_category_id,
          txd.deprn_method_tax   deprn_method,
          txd.deprn_rate_tax     deprn_rate,
          txd.salvage_value      salvage_value,
          txd.tax_book           book_type_code,
          txd.asset_number       asset_number,
          txl.kle_id             kle_id,
          --BUG# 3548044
          null                   tas_id,
          txl.salvage_value      corp_salvage_value,
          --Bug# 4028371
          null                   tal_id,
          --Bug# 3950089
          txl.percent_salvage_value pct_salvage_value,
          txl.percent_salvage_value corp_pct_salvage_value,
          --Bug# 5207066
          null,
          cle.cle_id             rbk_fin_ast_cle_id,
	  -- akrangan Bug# 5362977 start
             null      model_number,
             null      manufacturer_name,
             null      description,
	  -- akrangan Bug# 5362977 end
          --Bug# 6373605 start
          txd.id  sla_source_line_id,
          txl.tas_id sla_source_header_id,
          'OKL_TXD_ASSETS_B' sla_source_line_table,
          tas.try_id        sla_source_try_id,
          --Bug# 6373605 end

           --sechawla bug 8370324
          cle.start_date         line_start_date,
          --Bug# 8652738
          NULL    asset_key_id
    FROM  OKL_TXD_ASSETS_B  txd,
          OKL_TXL_ASSETS_B  txl,
          --Bug# 6373605 start
          OKL_TRX_ASSETS    tas,
          --Bug# 6373605 end
          OKC_K_LINES_B     cle,
          OKC_LINE_STYLES_B lse
    WHERE  txd.tal_id = txl.id
    --Bug# 6373605 start
    AND    tas.id     = txl.tas_id
    --Bug# 6373605
    AND    txl.kle_id     = cle.id
    AND    cle.dnz_chr_id = p_rbk_chr_id
    AND    cle.lse_id     = lse.id
    AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                      )
   AND    lse.lty_code   = G_FA_LINE_LTY_CODE;

   adj_txl_rec  adj_txl_csr%ROWTYPE;
   l_corp_bk VARCHAR2(256);

   --cursor to get the actual values from FA for the contract
   CURSOR okx_ast_csr (p_asset_number     IN VARCHAR2,
                       p_book_type_code   IN VARCHAR2) is
  SELECT  okx.acquisition_date       in_service_date,
          okx.life_in_months         life_in_months,
          okx.cost                   cost,
          okx.depreciation_category  depreciation_category,
          okx.deprn_method_code      deprn_method_code,
          okx.adjusted_rate          adjusted_rate,
          okx.basic_rate             basic_rate,
          okx.salvage_value          salvage_value,
          okx.book_type_code         book_type_code,
          okx.book_class             book_class,
          okx.asset_number           asset_number,
          okx.asset_id               asset_id,
          --Bug# 3950089
          okx.percent_salvage_value  percent_salvage_value,
          --Bug# 5207066
          okx.current_units  fa_current_units
   FROM   okx_ast_bks_v okx
   WHERE  okx.asset_number       = p_asset_number
   AND    okx.book_type_code    =  nvl(p_book_type_code,okx.book_type_code);

   okx_ast_rec   okx_ast_csr%ROWTYPE;

   --Cursor to check if the asset has no been deactivated/canceled on the original contract
   Cursor chk_line_csr (p_chr_id         IN NUMBER,
                        p_asset_id1      IN VARCHAR2,
                        p_asset_id2      IN VARCHAR2,
                        p_effective_date IN DATE) IS
   Select '!'
   from   OKC_K_LINES_B  cle,
          OKC_STATUSES_B sts,
          OKC_K_ITEMS    cim
   Where  cle.sts_code = sts.CODE
   And    cle.id = cim.cle_id
   And    cle.dnz_chr_id  = p_chr_id
   And    cim.dnz_chr_id  = p_chr_id
   And    cim.object1_id1 = p_asset_id1
   And    cim.object1_id2 = p_asset_id2
   And    cim.jtot_object1_code = 'OKX_ASSET'
   And    sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

  l_chk_cle_effective    Varchar2(1) default '?';

  l_cost_delta              Number;
  l_salvage_delta           Number;
  l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
  l_adjust_yn               Varchar2(1);

  --check if a new line exists on rbk copy contract
  --select the fin asset and fixed asset line id
  --of the original contract
  CURSOR new_ast_csr  (p_rbk_chr_id IN NUMBER) is
  Select clev.id              new_fin_cle_id,
         fa_cle.id            new_fa_cle_id,
         clev.chr_id          orig_chr_id
  From   okc_k_lines_v        clev,
         okc_line_styles_b    lse,
         okc_k_lines_b        fa_cle,
         okc_line_styles_b    fa_lse,
         okc_k_headers_b      chr
  where  clev.chr_id                 = chr.orig_system_id1
  and    clev.dnz_chr_id             = chr.orig_system_id1
  and    chr.id                      = p_rbk_chr_id
  and    chr.orig_system_source_code = 'OKL_REBOOK'
  and    exists (select null
                 from   okc_k_lines_v rbk_line
                 where  rbk_line.chr_id      = chr.id
                 and    rbk_line.dnz_chr_id  = chr.id
                 and    rbk_line.lse_id      = clev.lse_id
                 and    rbk_line.name        = clev.name
                 and    rbk_line.id          = clev.orig_system_id1)
  and   clev.lse_id        = lse.id
  and   lse.lty_code       = G_FIN_AST_LINE_LTY_CODE
  and   fa_cle.cle_id      = clev.id
  and   fa_cle.dnz_chr_id  = chr.orig_system_id1
  and   fa_cle.lse_id      = fa_lse.id
  and   fa_lse.lty_code    = G_FA_LINE_LTY_CODE;

  l_new_fin_cle_id      OKC_K_LINES_B.ID%TYPE;
  l_new_fa_cle_id       OKC_K_LINES_B.ID%TYPE;
  l_orig_chr_id         OKC_K_HEADERS_B.ID%TYPE;
  lx_cimv_rec           cimv_rec_type;
  lx_cimv_ib_tbl        cimv_tbl_type;

  l_dummy_amount NUMBER;

  --cursor to get tax owner rule
  Cursor town_rul_csr (pchrid number) is
  Select rule_information1 tax_owner,
         id
  From   okc_rules_b rul
  where  rul.dnz_chr_id = pchrid
  and    rul.rule_information_category = 'LATOWN'
  and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

  l_town_rul      okc_rules_b.rule_information1%TYPE;
  l_town_rul_id   okc_rules_b.id%TYPE;

  --bug# 2942543 :
  l_new_salvage_value Number;
  l_new_cost          Number;


  --Bug# 3574232
  l_adjust_asset_to_zero varchar2(30);

  --Bug# 3548044
  l_cap_fee_delta number;
  l_cap_fee_delta_converted_amt number;

  l_rebook_allowed_on_mg_book  varchar2(1);

  --Bug# 3783518
  l_subsidy_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;

  --Bug# 4028371
  l_fa_adj_date date;
  l_fa_sub_adj_date date;
  l_talv_date_rec okl_tal_pvt.talv_rec_type;
  lx_talv_date_rec okl_tal_pvt.talv_rec_type;

  l_hdr_rec              l_hdr_csr%ROWTYPE;

  -- Bug# 5174778
  l_func_curr_code OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;

  -- Bug# 5207066
  l_unit_difference number;

  --sechawla bug 8370324
  CURSOR chk_release_chr_csr(p_chr_id IN NUMBER) IS
  SELECT 'Y'
  FROM   okc_rules_b rul_rel_ast
  WHERE  rul_rel_ast.dnz_chr_id = p_chr_id
  AND    rul_rel_ast.rule_information_category = 'LARLES'
  AND    nvl(rule_information1,'N') = 'Y';

  l_release_chr_yn     VARCHAR2(1);
  l_rebook_fa_trx_date DATE;
  --sechawla bug 8370324


BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    --get rebook reason code
    --dbms_output.put_line('before rebook reason code cursor :');
    OPEN rbr_code_csr (p_rbk_chr_id => p_rbk_chr_id);
    Fetch rbr_code_csr into l_rbr_code,
                            l_date_trx_occured,
                            l_deal_type,
                            l_chr_id,
                            l_sts_code,
                            l_tax_owner,
                            --Bug# : 11.5.9 enhamcement Multigaap
                            l_pdt_id,
                            l_start_date,
                            --Bug# 3156924
                            l_trx_number;

    If rbr_code_csr%NOTFOUND Then
       --rebook transacton not found
       --does this call for raising error
       Null;
    Else
        --Bug# :11.5.9 : Multi-GAAP Begin
        Get_Pdt_Params (p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_pdt_id        => l_pdt_id,
                        p_pdt_date      => l_start_date,
                        x_rep_pdt_id    => l_rep_pdt_id,
                        x_tax_owner     => l_tax_owner,
                        x_rep_deal_type => l_rep_deal_type);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    	If l_tax_owner is null then
        Open town_rul_csr(pchrid => l_chr_id);
            Fetch town_rul_csr into l_town_rul,
                                    l_town_rul_id;
            If town_rul_csr%NOTFOUND Then
                OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Tax Owner');
                x_return_status := OKC_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
            Else
                l_tax_owner := rtrim(ltrim(l_town_rul,' '),' ');
            End If;
        Close town_rul_csr;
        End If;

        OPEN l_hdr_csr( p_rbk_chr_id );
        FETCH l_hdr_csr INTO l_hdr_rec;
        CLOSE l_hdr_csr;

        G_CHR_CURRENCY_CODE := l_hdr_rec.currency_code;
	G_FUNC_CURRENCY_CODE := okl_accounting_util.get_func_curr_code;
	G_CHR_AUTHORING_ORG_ID  := l_hdr_rec.authoring_org_id;
	G_CHR_START_DATE    := l_hdr_rec.start_date;
	G_CHR_REPORT_PDT_ID := l_hdr_rec.report_pdt_id;

        l_rebook_allowed_on_mg_book := 'Y';
        l_Multi_GAAP_YN := 'N';
        --checks wheter Multi-GAAP processing needs tobe done
      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.


        If l_rep_pdt_id is not NULL Then
                l_Multi_GAAP_YN := 'Y';

            --Bug# 3548044
            --Bug# 3621663
      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

            If l_deal_type  = 'LEASEOP' and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST')
            and nvl(l_tax_owner,'X') = 'LESSOR' then
                --l_Multi_GAAP_YN := 'Y';
                l_rebook_allowed_on_mg_book := 'N';
            End If;
            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
            nvl(l_tax_owner,'X') = 'LESSOR'  then
                --l_Multi_GAAP_YN := 'Y';
                l_rebook_allowed_on_mg_book := 'N';
            End If;
            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
            nvl(l_tax_owner,'X') = 'LESSEE'  then
                --l_Multi_GAAP_YN := 'Y';
                l_rebook_allowed_on_mg_book := 'N';
            End If;
            --Bug# 3548044

        End If;

        If l_Multi_GAAP_YN = 'Y' Then
            --get reporting product book type
            l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
        End If;



       Open adj_txl_csr(p_rbk_chr_id     => p_rbk_chr_id,
                        p_effective_date => l_date_trx_occured);
       Loop
           Fetch adj_txl_csr into adj_txl_rec;

           IF adj_txl_csr%NOTFOUND Then

      ------------------------------------------------------------------
      -- Bug# 3103387 : Residual value is only used to default salvage value.
      -- Salvage value should not be updated when there is a change in residual
      -- value for an Operating Lease. So the following code is not required.

      --Bug# 3103387 : End of commented code
      -------------------------------------------------------------------------

              Exit;-- exit from adj_txl_csr
           ---------------------------------------------
           Else --adj_txl_csr  found
           ---------------------------------------------


               ---------------------------------------------------------------
               -- Bug# 3548044 : A part of this bug the multi-gaap book should
               -- not mimic corporate book . It should adjust based on entered
               -- parameters. DF/ST(local) vs DF/ST(reporting) MG books are created with cost
               -- and SV zero to be untouched till offlease amortization process
               ---------------------------------------------------------------
               If ( adj_txl_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR))
                  and (l_rebook_allowed_on_mg_book = 'N') Then
                   --Exit;
                   Null; --do not do anything for reporting book
               Else

                   --get actual parameters from FA to get the Delta
                   Open okx_ast_csr (p_asset_number => adj_txl_rec.asset_number,
                                     p_book_type_code => adj_txl_rec.book_type_code);
                   Loop
                       Fetch okx_ast_csr into okx_ast_rec;
                       Exit When okx_ast_csr%NOTFOUND;
                       --dbms_output.put_line('book type code '||okx_ast_rec.book_type_code);
                       --check if the line is effective on the original contract
                       l_chk_cle_effective := '?';
                       Open chk_line_csr(p_chr_id         => l_chr_id,
                                         p_asset_id1      => okx_ast_rec.asset_id,
                                         p_asset_id2      => '#',
                                         p_effective_date => l_date_trx_occured);
                       Fetch chk_line_csr into l_chk_cle_effective;
                       If chk_line_csr%NOTFOUND Then
                           Null;
                       End If;
                       Close chk_line_csr;
                       If l_chk_cle_effective = '?' Then
                           Exit; -- this line is not effective on the original contract
                           --dbms_output.put_line('not an effective line.');
                       Else
                           --initialize
                           l_adjust_yn := 'N';
                           l_cost_delta := 0;
                           l_salvage_delta := 0;

                           --Bug# 3548044 : removed comments
                           l_asset_fin_rec_adj.cost                   := null;
                           l_asset_fin_rec_adj.salvage_value          := null;
                           l_asset_fin_rec_adj.date_placed_in_service := null;
                           l_asset_fin_rec_adj.life_in_months         := null;
                           l_asset_fin_rec_adj.deprn_method_code      := null;
                           l_asset_fin_rec_adj.basic_rate             := null;
                           l_asset_fin_rec_adj.adjusted_rate          := null;
                           --Bug# 3950089
                           l_asset_fin_rec_adj.percent_salvage_value  := null;
                           --Bug# 3548044

                           -- Bug# 5174778
                           l_func_curr_code := okl_accounting_util.get_func_curr_code;

                           l_dummy_amount := null;
                           convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
	                                 x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rbk_chr_id,
			                 p_amount        => adj_txl_rec.depreciation_cost,
			                 x_amount        => l_dummy_amount);

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;

                           -- Bug# 5174778
                           l_dummy_amount := okl_accounting_util.cross_currency_round_amount(
                                                p_amount        => l_dummy_amount,
                                                p_currency_code => l_func_curr_code
                                             );

                           --calculate deltas
                           l_cost_delta     := (l_dummy_amount - okx_ast_rec.cost);

                           -- Bug# 4899328: Cap fee changes are now included in the
                           -- Depreciation cost. Depreciation cost amount is automatically
                           -- recalculated whenever there is a change to cap fee.

                           --Bug# 4899328: End

                           --Bug# 3548044 : Added if-else clause for reporting product books
                           If okx_ast_rec.book_type_code <> nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) then

                             --Bug# 3950089
                             If (okx_ast_rec.percent_salvage_value is not null) Then

                               If (adj_txl_rec.pct_salvage_value is null) or
                                  (adj_txl_rec.salvage_value is not null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;

                             Elsif (okx_ast_rec.salvage_value is not null) Then

                               If (adj_txl_rec.salvage_value is null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;
                             End If;

                             If (okx_ast_rec.percent_salvage_value is not null) and
                                (okx_ast_rec.book_class = 'CORPORATE') Then

                               l_salvage_delta  := ((adj_txl_rec.pct_salvage_value/100)
                                                   - okx_ast_rec.percent_salvage_value);

                             Else

                               l_dummy_amount := null;
                               convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
	                                 x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rbk_chr_id,
			                 p_amount        => adj_txl_rec.salvage_value,
			                 x_amount        => l_dummy_amount);

                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;

                               -- Bug# 5174778
                               l_dummy_amount := okl_accounting_util.cross_currency_round_amount(
                                                   p_amount        => l_dummy_amount,
                                                   p_currency_code => l_func_curr_code
                                                 );

                               l_salvage_delta  := (l_dummy_amount - okx_ast_rec.salvage_value);
                             End If;

                           ElsIf okx_ast_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) then

                             --Bug# 3950089
                             If (okx_ast_rec.percent_salvage_value is not null) Then

                               If (adj_txl_rec.corp_pct_salvage_value is null) or
                                  (adj_txl_rec.corp_salvage_value is not null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;

                             Elsif (okx_ast_rec.salvage_value is not null) Then

                               If (adj_txl_rec.corp_salvage_value is null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;
                             End If;

                             If (okx_ast_rec.percent_salvage_value is not null) Then

                               l_salvage_delta  := ((adj_txl_rec.corp_pct_salvage_value/100)
                                                   - okx_ast_rec.percent_salvage_value);

                             Else
                               l_dummy_amount := null;
                               convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rbk_chr_id,
                                         p_amount        => adj_txl_rec.corp_salvage_value,
                                         x_amount        => l_dummy_amount);

                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;

                              -- Bug# 5174778
                               l_dummy_amount := okl_accounting_util.cross_currency_round_amount(
                                                   p_amount        => l_dummy_amount,
                                                   p_currency_code => l_func_curr_code
                                                 );

                               l_salvage_delta  := (l_dummy_amount - okx_ast_rec.salvage_value);
                             End If;

                           End If;
                           --Bug# 3548044 end


      ------------------------------------------------------------------
      -- Bug# 3103387 : Residual value is only used to default salvage value.
      -- Salvage value should not be updated when there is a change in residual
      -- value for an Operating Lease. So the following code is not required.

       --Bug# 3103387 : End of commented code
       ------------------------------------------------------------------------

                           --Bug# 2942543 : cost updates for DF lease contracts
                           If (l_cost_delta <> 0) Then
                              If l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 l_tax_owner = 'LESSEE' Then
                                 --no cost updates for df/st lease with tax owner 'LESSEE'
                                 Null;
                              Elsif l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 okx_ast_rec.book_class = 'CORPORATE' Then
                                 --No cost updates for df/st lease on corporate asset book as
                                 --cost is adjusted to zero there from creation time
                                 Null;
                              Else
                                  l_asset_fin_rec_adj.cost := l_cost_delta;
                                  l_adjust_yn := 'Y';
                              End If;
                           End If;

                           --Bug# 2942543 : salvage value updates for DF lease contracts
                           If (l_salvage_delta <> 0) Then
                              If l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 l_tax_owner = 'LESSEE' Then
                                  --no sv updates for df/st lease with tax owner 'LESSEE'
                                  Null;
                              Elsif l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 okx_ast_rec.book_class = 'CORPORATE' Then
                                  --No cost updates for df/st lease on corporate asset book as
                                  --sv is adjusted to zero there from creation time
                                  Null;
                              Elsif okx_ast_rec.book_class = 'TAX'
                                  --Bug # 3548044
                                  and okx_ast_rec.book_type_code <>  nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR)Then
                                  --Salvage value will be zero in all the tax books as per bug#2967286
                                  --except for Muti-GAAP reporting books --Bug# 3548044
                                  Null;
                              Else

                                  --Bug# 3950089
                                  If (okx_ast_rec.percent_salvage_value is not null) Then
                                    l_asset_fin_rec_adj.percent_salvage_value := l_salvage_delta;
                                  Else
                                    l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                                  End if;
                                  l_adjust_yn := 'Y';
                              End If;
                           End If;

                           If  trunc(nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date)) <> trunc(okx_ast_rec.in_service_date) Then
                              l_asset_fin_rec_adj.date_placed_in_service := nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date);
                              l_adjust_yn := 'Y';
                           End If;

                           If  nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months) <> okx_ast_rec.life_in_months Then
                              l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                              l_asset_fin_rec_adj.life_in_months    := nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months);
                              l_asset_fin_rec_adj.basic_rate        := adj_txl_rec.deprn_rate;
                              l_asset_fin_rec_adj.adjusted_rate     := adj_txl_rec.deprn_rate;
                              l_adjust_yn := 'Y';
                           End If;

                           --category updates not supported by API
                           --If adj_txl_rec.depreciation_id <> okx_ast_rec.depreciation_category Then
                           If nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code) <> okx_ast_rec.deprn_method_code Then
                              l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                              l_asset_fin_rec_adj.life_in_months    := adj_txl_rec.life_in_months;
                              l_asset_fin_rec_adj.basic_rate        := adj_txl_rec.deprn_rate;
                              l_asset_fin_rec_adj.adjusted_rate     := adj_txl_rec.deprn_rate;
                              l_adjust_yn := 'Y';
                           End If;

                           If nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate) <> okx_ast_rec.adjusted_rate Then
                              l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                              l_asset_fin_rec_adj.life_in_months    := adj_txl_rec.life_in_months;
                              l_asset_fin_rec_adj.basic_rate        := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.basic_rate);
                              l_asset_fin_rec_adj.adjusted_rate     := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate);
                              l_adjust_yn := 'Y';
                           End If;

                           If nvl(l_adjust_yn,'N') = 'Y' AND
                              l_deal_type not in (G_LOAN_BK_CLASS,G_REVOLVING_LOAN_BK_CLASS) then

                               --bug # 2942543 :
                               --check if salvage value is becoming more than asset cost
                               --BUG# 3548044: check for all the books (not only corporate book)
                               --If okx_ast_rec.book_class = 'CORPORATE' then --salvage value updates only for CORP

                               --Bug# 3950089
                               l_new_cost          := okx_ast_rec.cost + l_cost_delta;
                               If (okx_ast_rec.percent_salvage_value is not null) Then
                                 l_new_salvage_value := l_new_cost * (NVL(adj_txl_rec.pct_salvage_value,0)/100);
                               Else
                                 l_new_salvage_value := okx_ast_rec.salvage_value + l_salvage_delta;
                               End If;

                               If (l_new_cost < l_new_salvage_value) Then
                                   OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                       p_msg_name     => G_SALVAGE_VALUE
                                                      );
                                       RAISE OKL_API.G_EXCEPTION_ERROR;
                               End If;
                               --End If; --Bug# 3548044

                               --Sechawla : Bug# 8370324
                               l_release_chr_yn := 'N';
                               OPEN chk_release_chr_csr(p_chr_id => p_rbk_chr_id);
                               FETCH chk_release_chr_csr INTO l_release_chr_yn;
                               CLOSE chk_release_chr_csr;

                               IF (l_release_chr_yn = 'Y') THEN
                                 l_rebook_fa_trx_date := adj_txl_rec.line_start_date;
                               ELSE
                                 l_rebook_fa_trx_date := nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date);
                               END IF;
                               --Bug# 8370324

                               -- Bug# 3783518
                               -- Revision date should be in the current open period or in a
                               -- prior period in FA

                               validate_rebook_date
                                  (p_api_version     => p_api_version,
                                   p_init_msg_list   => p_init_msg_list,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data,
                                   p_book_type_code  => okx_ast_rec.book_type_code,
                                   --sechawla : Bug# 8370324
                                   p_rebook_date     => l_rebook_fa_trx_date,
                                   p_cost_adjustment => l_asset_fin_rec_adj.cost,
                                   p_contract_start_date => l_start_date);

                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;

                               -------------------
                               --Bug# 6373605
                               l_asset_fin_rec_adj.contract_id := l_orig_chr_id;
                               ---------------------
                               --call the adjustment api to do adjustment
                               FIXED_ASSET_ADJUST
                                     (p_api_version         => p_api_version,
                                      p_init_msg_list       => p_init_msg_list,
                                      x_return_status       => x_return_status,
                                      x_msg_count           => x_msg_count,
                                      x_msg_data            => x_msg_data,
                    	              p_chr_id              => p_rbk_chr_id,
                                      p_book_type_code      => okx_ast_rec.book_type_code,
                                      p_asset_id            => okx_ast_rec.asset_id,
                                      p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                                      --sechawla Bug# 8370324
                                      p_adj_date            => l_rebook_fa_trx_date,
                                      --Bug# 3156924
                                      p_trans_number        => l_trx_number,
                                      p_calling_interface   => l_calling_interface,
            --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
            p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
            p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
            p_sla_source_chr_id       => p_rbk_chr_id,
            p_sla_source_kle_id       => adj_txl_rec.rbk_fin_ast_cle_id,
            --Bug# 6373605--SLA populate sources
                                      --Bug# 4028371
                                      x_fa_trx_date         => l_fa_adj_date,
                                      x_asset_fin_rec_new   => l_asset_fin_rec_new);

                              --dbms_output.put_line('After fixed asset adjust for rebook :'||x_return_status);
                              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                              END IF;

                              -- Bug# 5207066 start

                              -- Bug# 5207066 end

                              --Bug# 4028371
                              If adj_txl_rec.tal_id is not null Then
                                  --update the fa trx date on transaction line
                                      l_talv_date_rec.id     := adj_txl_rec.tal_id;
                                      l_talv_date_rec.fa_trx_date := l_fa_adj_date;

                                      okl_tal_pvt.update_row
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_talv_rec      => l_talv_date_rec,
                                         x_talv_rec      => lx_talv_date_rec);
                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;
                             End If;
                             --End Bug# 4028371
                            --5362977 akrangan start
                            End If; --l_adjust_yn = 'Y'
                             --Bug# 5121256/5150355
                              If (l_deal_type not in (G_LOAN_BK_CLASS,G_REVOLVING_LOAN_BK_CLASS) AND
                                  okx_ast_rec.book_class = 'CORPORATE') Then

                              l_unit_difference :=  adj_txl_rec.rbk_current_units - okx_ast_rec.fa_current_units;

                              if (l_unit_difference <> 0) then
                                FIXED_ASSET_ADJUST_UNIT
                                      (p_api_version       => p_api_version,
                                       p_init_msg_list     => p_init_msg_list,
                                       x_return_status     => x_return_status,
                                       x_msg_count         => x_msg_count,
                                       x_msg_data          => x_msg_data,
                                       p_asset_id          => okx_ast_rec.asset_id,
                                       p_book_type_code    => okx_ast_rec.book_type_code,
                                       p_diff_in_units     => l_unit_difference,
                                       --sechawla bug# 8370324
                                       p_trx_date          => l_rebook_fa_trx_date,
                                       p_trx_number        => l_trx_number,
                                       p_calling_interface => l_calling_interface,
                --Bug# 6373605--SLA populate source
                p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
                p_sla_source_header_table => 'OKL_TRX_ASSETS',
                p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
                p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
                p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
                p_sla_source_chr_id       => p_rbk_chr_id,
                p_sla_source_kle_id       => adj_txl_rec.rbk_fin_ast_cle_id,
                --Bug# 6373605--SLA populate sources
                                      --Bug# 4028371
                                       --Bug# 4028371
                                       x_fa_trx_date       => l_fa_adj_date);

                                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;

                                 end if;
				 --Bug# 5362977
                                -- Update Model number, manufacturer and description
                                FIXED_ASSET_UPDATE_DESC
                                 (p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data,
				  p_asset_id          => okx_ast_rec.asset_id,
				  p_model_number      => adj_txl_rec.model_number,
				  p_manufacturer      => adj_txl_rec.manufacturer_name,
				  p_description       => adj_txl_rec.description,
                                  --sechawla : Bug# 8370324
                                  p_trx_date          => l_rebook_fa_trx_date,
				  p_trx_number        => l_trx_number,
				  p_calling_interface => l_calling_interface,
				--Bug# 4028371
				  x_fa_trx_date       => l_fa_adj_date,
                                  --Bug# 8652738
                                  p_asset_key_id      => adj_txl_rec.asset_key_id);
                               --akrangan bug 5362977 end

                                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;


                               --akrangan bug 5362977 start
                                -- Handle updates to serial numbers even when units are not changed
                                OKL_ACTIVATE_IB_PVT.RBK_SRL_NUM_IB_INSTANCE

                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_rbk_fin_ast_cle_id => adj_txl_rec.rbk_fin_ast_cle_id,
                                         p_rbk_chr_id        => p_rbk_chr_id);
                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;
                            End If;
                         --akrangan bug 5362977 end


                           ---------------------------------------------------------------
                           --Bug# 3548044 : MultiGaap Book to follow its own changes
                           --will not mimic corporate book
                           ---------------------------------------------------------------
                           --start of comments
                           -- end of comments
                           ------------------------------------------------------------------*/
                           --Bug# 3548044

                        End If; --chk_cle effective
                    End Loop;
                    Close okx_ast_csr;
                End If; -- proceed for books other than reporting book  in case of local and reporting Tax leases
               --BUG# 3548044 : Process status for mass rebook asset transaction
                If adj_txl_rec.tas_id is not NULL then

                    update_trx_status(p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_tas_id        => adj_txl_rec.tas_id,
                                      p_tsu_code      => G_TSU_CODE_PROCESSED);

                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                End If;
                --BUG# 3548044
                End If; --adj_txl_rec found

            End Loop;
            Close adj_txl_csr;
--          End If; --rebook reason code
            End If; --rbr code csr
        CLOSE rbr_code_csr;
        --to check if new asset has been added and process accordingly
        OPEN new_ast_csr (p_rbk_chr_id => p_rbk_chr_id);
        Loop
            FETCH new_ast_csr into l_new_fin_cle_id,
                                   l_new_fa_cle_id,
                                   l_orig_chr_id;
            Exit When new_ast_csr%NOTFOUND;

            -- Bug# 3574232 start
            l_adjust_asset_to_zero := 'N';
            If l_rep_pdt_id is not NULL Then

              l_Multi_GAAP_YN := 'Y';
              -- If the reporting product is DF/ST lease, the asset should
              -- be created and written to zero in the reporting book.
      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.


              If l_deal_type = 'LEASEOP' and
              nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
              nvl(l_tax_owner,'X') = 'LESSOR' Then
--                l_Multi_GAAP_YN := 'Y';
                l_adjust_asset_to_zero := 'Y';
              End If;

              If l_deal_type in ('LEASEDF','LEASEST') and
              nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
              nvl(l_tax_owner,'X') = 'LESSOR' Then
--                l_Multi_GAAP_YN := 'Y';
                l_adjust_asset_to_zero := 'Y';
              End If;

              If l_deal_type in ('LEASEDF','LEASEST') and
              nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
              nvl(l_tax_owner,'X') = 'LESSEE' Then
--                l_Multi_GAAP_YN := 'Y';
                l_adjust_asset_to_zero := 'Y';
              End If;
            End If;

            If l_Multi_GAAP_YN = 'Y' Then
              --get reporting product book type
              l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
            End If;
            -- Bug# 3574232 end

            --process new fa line for asset additions
            --dbms_output.put_line('Found new line going in to add asset now.');
      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

            If ((l_deal_type = 'LOAN') --and nvl(l_Multi_GAAP_YN,'N') = 'N')
              OR (l_deal_type = 'LOAN_REVOLVING'))  Then
                Null;
                --Assets will not be activatted for LOANS which are not Multi-GAAP
            Else
                Process_FA_Line (p_api_version       => p_api_version,
                                 p_init_msg_list     => p_init_msg_list,
                                 x_return_status     => x_return_status,
                                 x_msg_count         => x_msg_count,
                                 x_msg_data          => x_msg_data,
                                 p_chrv_id           => l_orig_chr_id,
                                 p_fa_line_id        => l_new_fa_cle_id,
                                 p_fin_ast_line_id   => l_new_fin_cle_id,
                                 p_deal_type         => l_deal_type,
                                 p_trx_type          => l_trx_type,
                                 --Bug# : 11.5.9 enhance ment - Multi GAAP
                                 p_Multi_GAAP_YN     => l_Multi_GAAP_YN,
                                 p_rep_pdt_book      => l_rep_pdt_book,
                                 --Bug# : 11.5.9 enhance ment - Multi GAAP End
                                 --Bug# 3574232
                                 p_adjust_asset_to_zero => l_adjust_asset_to_zero,
                                 --Bug# 3156924
                                 p_trans_number      => l_trx_number,
                                 p_calling_interface => l_calling_interface,
                                 --Bug# 3156924
                                 --Bug# 6373605 start
                                 p_sla_asset_chr_id  => l_orig_chr_id,
                                 --Bug# 6373605
                                 x_cimv_rec          => lx_cimv_rec);
                --dbms_output.put_line('After process FA line. '||x_return_status );
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            End IF;
            --Bug# :11.5.9 : Multi-GAAP End

            --process new fa line for IB Additions
            --dbms_output.put_line('going in to add IB now.');
            OKL_ACTIVATE_IB_PVT.ACTIVATE_RBK_IB_INST
                              (p_api_version         => p_api_version,
                               p_init_msg_list       => p_init_msg_list,
                               x_return_status       => x_return_status,
                               x_msg_count           => x_msg_count,
                               x_msg_data            => x_msg_data,
                               p_fin_ast_cle_id      => l_new_fin_cle_id,
                               x_cimv_tbl            => lx_cimv_ib_tbl);
            --dbms_output.put_line('After doing IB. '||x_return_status );
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End Loop;
        Close new_ast_csr;

        -- Bug# 4899328: Subsidy changes are now included in the
        -- Depreciation cost. Depreciation cost amount is automatically
        -- recalculated whenever there is a change to subsidies.
        /*

       */
       -- Bug# 4899328: End

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END REBOOK_ASSET;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name :  MASS_REBOOK_ASSET (Activate code branch for mass_rebook)
--Description    :  Will be called to make mass rebook adjustments in Oracle FA
--History        :
--                 30-APR-2002  ashish.singh Created
-- Notes         :
--      IN Parameters -
--                     p_rbk_chr_id    - contract id of rebook  contract
--                     although similar to rebook_asset processing this is kept
--                     separate as there may be differences later between rebook
--                     and mass Rebook
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE MASS_REBOOK_ASSET  (p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_rbk_chr_id    IN  NUMBER
                             ) IS

   l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
   l_api_name             CONSTANT varchar2(30) := 'MASS_REBOOK_ASSET';
   l_api_version          CONSTANT NUMBER := 1.0;

   --Cursor to get the rebook transaction reason codes
   CURSOR rbr_code_csr (p_rbk_chr_id IN NUMBER) IS
   SELECT ktrx.rbr_code,
          ktrx.date_transaction_occurred,
          khr.deal_type,
          chr.id,
          chr.sts_code,
          rul.rule_information1,
          khr.pdt_id,
          chr.start_date,
          --Bug# 3156924
          ktrx.trx_number
   FROM   OKC_RULES_B       rul,
          OKL_K_HEADERS     khr,
          OKC_K_HEADERS_B   chr,
          OKL_TRX_CONTRACTS ktrx
   WHERE  rul.dnz_chr_id                  = chr.id
   AND    rul.rule_information_category   = 'LATOWN'
   AND    khr.id                          = chr.id
   AND    chr.id                          = p_rbk_chr_id
   AND    exists (select null
                  from   okl_trx_types_tl tl
                  where  tl.language = 'US'
                  and    tl.name = 'Rebook'
                  and    tl.id   = ktrx.try_id)
   AND    ktrx.KHR_ID                      = chr.id
   AND    ktrx.KHR_ID  = rul.dnz_chr_id
--rkuttiya added for 12.1.1  Multi GAAP Project
   AND    ktrx.representation_type = 'PRIMARY'
--
   AND    ktrx.KHR_ID_NEW is null
   AND    ktrx.tsu_code                   = G_TSU_CODE_ENTERED;

   l_rbr_code          OKL_TRX_CONTRACTS.rbr_code%TYPE;
   l_deal_type         OKL_K_HEADERS.deal_type%TYPE;
   l_chr_id            OKC_K_HEADERS_B.ID%TYPE;
   l_sts_code          OKC_K_HEADERS_B.STS_CODE%TYPE;
   l_date_trx_occured  OKL_TRX_CONTRACTS.date_transaction_occurred%TYPE;
   l_tax_owner         OKC_RULES_B.RULE_INFORMATION1%TYPE;
   --Bug# 3156924
   l_trans_number      OKL_TRX_CONTRACTS.trx_number%TYPE;
   l_calling_interface Varchar2(30) := 'OKLRACAB:Mass Rebook';

   --sechawla : bug 8370324
   /*
   --cursor to get the adjusted residual value and OEC
   CURSOR adj_cle_csr (p_chr_id IN NUMBER, p_fa_cle_id IN NUMBER, p_effective_date IN date) IS
   SELECT kle.OEC,
          kle.RESIDUAL_VALUE,
          cle.id,
          cle.name
   FROM   OKC_K_LINES_V      cle,
          OKC_LINE_STYLES_B  lse,
          OKL_K_LINES        kle,
          OKC_K_LINES_B      fa_cle,
          OKC_LINE_STYLES_B  fa_cle_lse
   WHERE  kle.id              = cle.id
   AND    cle.chr_id          = p_chr_id
   AND    cle.dnz_chr_id      = p_chr_id
   AND    cle.lse_id          = lse.id
   AND    lse.lty_code        = G_FIN_AST_LINE_LTY_CODE
   AND    cle.id              = fa_cle.cle_id
   AND    fa_cle.id           = nvl(p_fa_cle_id,fa_cle.id)
   AND    fa_cle.lse_id       = fa_cle_lse.id
   AND    fa_cle_lse.lty_code = G_FA_LINE_LTY_CODE
   --Bug# 2942543 : effectivity should be checked by keeping start and end date as inclusive
   --AND    nvl(cle.start_date,p_effective_date) <= p_effective_date
   --AND    nvl(cle.end_date,p_effective_date+1) >  p_effective_date
   AND    p_effective_date between cle.start_date and cle.end_date
   AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      --Bug# 2522268
                      --And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELED'));
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED'));

   l_oec                OKL_K_LINES.OEC%TYPE;
   l_residual_value     OKL_K_LINES.RESIDUAL_VALUE%TYPE;
   l_cle_id             OKC_K_LINES_V.ID%TYPE;
   l_asset_number       OKC_K_LINES_V.NAME%TYPE;
*/

   --cursor to get the modified transaction values against the rebook contract
   CURSOR adj_txl_csr (p_rbk_chr_id IN NUMBER, p_effective_date IN DATE ) IS
   SELECT txl.in_service_date   in_service_date,
          txl.life_in_months    life_in_months,
          txl.depreciation_cost depreciation_cost,
          txl.depreciation_id   asset_category_id,
          txl.deprn_method      deprn_method,
          txl.deprn_rate        deprn_rate,
          txl.salvage_value     salvage_value,
          txl.corporate_book    book_type_code,
          txl.asset_number      asset_number,
          txl.kle_id            kle_id,
          --Bug# 3548044
          txl.tas_id            tas_id,
          txl.salvage_value     corp_salvage_value,
          --Bug# 4028371
          txl.id                tal_id,
          --Bug# 6373605 start
          txl.id  sla_source_line_id,
          txl.tas_id sla_source_header_id,
          'OKL_TXL_ASSETS_B' sla_source_line_table,
          tas.try_id sla_source_try_id,
          cle.cle_id sla_source_kle_id,
          --Bug# 6373605 end
          --sechawla : Bug# 8370324
          cle.start_date        line_start_date
   FROM   OKL_TXL_ASSETS_B  txl,
          --Bug# 6373605 start
          OKL_TRX_ASSETS    tas,
          --Bug# 6373605 end
          OKC_K_LINES_B     cle,
          OKC_LINE_STYLES_B lse
   WHERE  txl.kle_id     = cle.id
   AND    txl.tal_type   = 'CRB'
   --Bug# 6373605 start
   AND    tas.id         = txl.tas_id
   --Bug# 6373605 end
   AND    cle.dnz_chr_id = p_rbk_chr_id
   AND    cle.lse_id     = lse.id
--sechawla : Bug# 8370324
--   AND p_effective_date between cle.start_date and cle.end_date
   AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                      )
   AND    lse.lty_code   = G_FA_LINE_LTY_CODE
   AND    exists (select '1'
                  from   OKL_TRX_ASSETS TRX
                  Where  TRX.ID = Txl.tas_id
                  And    TRX.tas_type = 'CRB'
                  And    TRX.tsu_code = 'ENTERED')
   UNION
   SELECT txl.in_service_date    in_service_date,
          txd.life_in_months_tax life_in_months,
          txd.cost               depreciation_cost,
          txl.depreciation_id    asset_category_id,
          txd.deprn_method_tax   deprn_method,
          txd.deprn_rate_tax     deprn_rate,
          txd.salvage_value      salvage_value,
          txd.tax_book           book_type_code,
          txd.asset_number       asset_number,
          txl.kle_id             kle_id,
          --bug# 3548044
          null                   tas_id,
          txl.salvage_value      corp_salvage_value,
          --Bgu# 4028371
          null                   tal_id,
          --Bug# 6373605 start
          txd.id  sla_source_line_id,
          txl.tas_id sla_source_header_id,
          'OKL_TXD_ASSETS_B' sla_source_line_table,
          tas.try_id        sla_source_try_id,
          cle.cle_id        sla_source_kle_id,
          --Bug# 6373605 end
          --sechawla : Bug# 8370324
          cle.start_date        line_start_date
    FROM  OKL_TXD_ASSETS_B  txd,
          OKL_TXL_ASSETS_B  txl,
          --Bug# 6373605 start
          OKL_TRX_ASSETS    tas,
          --Bug# 6373605 end
          OKC_K_LINES_B     cle,
          OKC_LINE_STYLES_B lse
    WHERE  txd.tal_id = txl.id
    --Bug# 6373605 start
    AND    tas.id     = txl.tas_id
    --Bug# 6373605
    AND    txl.kle_id     = cle.id
    AND    cle.dnz_chr_id = p_rbk_chr_id
    AND    cle.lse_id     = lse.id
     --sechawla : Bug# 8370324
    --AND      p_effective_date between cle.start_date and cle.end_date
    AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                      )
   AND    lse.lty_code   = G_FA_LINE_LTY_CODE
   AND    exists (select '1'
                  from   OKL_TRX_ASSETS TRX
                  Where  TRX.ID = Txl.tas_id
                  And    TRX.tas_type = 'CRB'
                  And    TRX.tsu_code = 'ENTERED');

   adj_txl_rec  adj_txl_csr%ROWTYPE;
   --Bug# : 11.5.9 enhancement Multi GAAP
   l_pdt_id            OKL_K_HEADERS.pdt_id%TYPE;
   l_start_date        Date;
   l_rep_pdt_id        Number;
   l_rep_deal_type     Varchar2(150);
   l_Multi_GAAP_YN     Varchar2(1) := 'N';
   l_rep_pdt_book      OKX_AST_BKS_V.Book_Type_Code%Type;

   l_dummy_amount NUMBER;

   --cursor to get the actual values from FA for the contract
  CURSOR okx_ast_csr (p_asset_number     IN VARCHAR2,
                      p_book_type_code   IN VARCHAR2) is
  SELECT  okx.acquisition_date       in_service_date,
          okx.life_in_months         life_in_months,
          okx.cost                   cost,
          okx.depreciation_category  depreciation_category,
          okx.deprn_method_code      deprn_method_code,
          okx.adjusted_rate          adjusted_rate,
          okx.basic_rate             basic_rate,
          okx.salvage_value          salvage_value,
          okx.book_type_code         book_type_code,
          okx.book_class             book_class,
          okx.asset_number           asset_number,
          okx.asset_id               asset_id
   FROM   okx_ast_bks_v okx
   WHERE  okx.asset_number       = p_asset_number
   AND    okx.book_type_code     = nvl(p_book_type_code,okx.book_type_code);

   okx_ast_rec   okx_ast_csr%ROWTYPE;

   --Cursor to check if the asset has no been deactivated/canceled on the original contract
   Cursor chk_line_csr (p_chr_id         IN NUMBER,
                        p_asset_id1      IN VARCHAR2,
                        p_asset_id2      IN VARCHAR2,
                        p_effective_date IN DATE) IS
   Select '!'
   from   OKC_K_LINES_B  cle,
          OKC_STATUSES_B sts,
          OKC_K_ITEMS    cim
   Where  cle.sts_code = sts.CODE
   --sechawla : Bug# 8370324
   --And p_effective_date between cle.start_date and cle.end_date
   And    cle.id = cim.cle_id
   And    cle.dnz_chr_id  = p_chr_id
   And    cim.dnz_chr_id  = p_chr_id
   And    cim.object1_id1 = p_asset_id1
   And    cim.object1_id2 = p_asset_id2
   And    cim.jtot_object1_code = 'OKX_ASSET'
   And    sts.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

  l_chk_cle_effective    Varchar2(1) default '?';

  l_cost_delta              Number;
  l_salvage_delta           Number;
  l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
  l_adjust_yn               Varchar2(1);

  --cursor to get tax owner rule
  Cursor town_rul_csr (pchrid number) is
  Select rule_information1 tax_owner,
         id
  From   okc_rules_b rul
  where  rul.dnz_chr_id = pchrid
  and    rul.rule_information_category = 'LATOWN'
  and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

  l_town_rul      okc_rules_b.rule_information1%TYPE;
  l_town_rul_id   okc_rules_b.id%TYPE;

  l_mass_rebook_date date default sysdate;

  --Bug# 2942543 :
  l_new_salvage_value number;
  l_new_cost          number;

  --Bug# 3548044
  l_rebook_allowed_on_mg_book  varchar2(1);
  --Bug# 4028371
  l_fa_adj_date date;
  l_talv_date_rec okl_tal_pvt.talv_rec_type;
  lx_talv_date_rec okl_tal_pvt.talv_rec_type;

  l_hdr_rec              l_hdr_csr%ROWTYPE;

  --sechawla : Bug# 8370324
  CURSOR chk_release_chr_csr(p_chr_id IN NUMBER) IS
  SELECT 'Y'
  FROM   okc_rules_b rul_rel_ast
  WHERE  rul_rel_ast.dnz_chr_id = p_chr_id
  AND    rul_rel_ast.rule_information_category = 'LARLES'
  AND    nvl(rule_information1,'N') = 'Y';

  l_release_chr_yn     VARCHAR2(1);
  l_rebook_fa_trx_date DATE;
  --sechawla : Bug# 8370324


BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --get rebook reason code
    --dbms_output.put_line('before rebook reason code cursor :');
    OPEN rbr_code_csr (p_rbk_chr_id => p_rbk_chr_id);
    Fetch rbr_code_csr into l_rbr_code,
                            l_date_trx_occured,
                            l_deal_type,
                            l_chr_id,
                            l_sts_code,
                            l_tax_owner,
                            l_pdt_id,
                            l_start_date,
                            --Bug# 3156924
                            l_trans_number;


    If rbr_code_csr%NOTFOUND Then
       --rebook transacton not found
       --does this call for raising error
       Null;
    Else

        --Bug# 3156924
        l_mass_rebook_date := l_date_trx_occured;
        --Bug# 3156924

        --almost redundant code here as for mass rebook no changes in scope
        -- for the corporate book
        Get_Pdt_Params (p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_pdt_id        => l_pdt_id,
                        p_pdt_date      => l_start_date,
                        x_rep_pdt_id    => l_rep_pdt_id,
                        x_tax_owner     => l_tax_owner,
                        x_rep_deal_type => l_rep_deal_type);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    	If l_tax_owner is null then
        Open town_rul_csr(pchrid => l_chr_id);
            Fetch town_rul_csr into l_town_rul,
                                    l_town_rul_id;
            If town_rul_csr%NOTFOUND Then
                OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Tax Owner');
                x_return_status := OKC_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
            Else
                l_tax_owner := rtrim(ltrim(l_town_rul,' '),' ');
            End If;
        Close town_rul_csr;
        End If;

	OPEN l_hdr_csr( p_rbk_chr_id );
        FETCH l_hdr_csr INTO l_hdr_rec;
        CLOSE l_hdr_csr;

	G_CHR_CURRENCY_CODE := l_hdr_rec.currency_code;
	G_FUNC_CURRENCY_CODE := okl_accounting_util.get_func_curr_code;
	G_CHR_AUTHORING_ORG_ID  := l_hdr_rec.authoring_org_id;
	G_CHR_START_DATE    := l_hdr_rec.start_date;
	G_CHR_REPORT_PDT_ID := l_hdr_rec.report_pdt_id;


        --BUG# 3548044
        l_rebook_allowed_on_mg_book := 'Y';
        l_Multi_GAAP_YN := 'N';
        --checks wheter Multi-GAAP processing needs tobe done
        If l_rep_pdt_id is not NULL Then

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

            l_Multi_GAAP_YN := 'Y';
/*
            If l_deal_type = 'LEASEOP' and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSOR' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSOR' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSEE' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

            If l_deal_type = 'LOAN' and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSEE' Then
                l_Multi_GAAP_YN := 'Y';
            End If;
*/
           --Bug# 3548044
           --Bug# 3621663
      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

           If l_deal_type  = 'LEASEOP' and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST')
            and nvl(l_tax_owner,'X') = 'LESSOR' then
                --l_Multi_GAAP_YN := 'Y';
                l_rebook_allowed_on_mg_book := 'N';
            End If;
            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
            nvl(l_tax_owner,'X') = 'LESSOR'  then
                --l_Multi_GAAP_YN := 'Y';
                l_rebook_allowed_on_mg_book := 'N';
            End If;
            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
            nvl(l_tax_owner,'X') = 'LESSEE'  then
                --l_Multi_GAAP_YN := 'Y';
                l_rebook_allowed_on_mg_book := 'N';
            End If;
            --Bug# 3548044
        End If;

        If l_Multi_GAAP_YN = 'Y' Then
            --get reporting product book type
            l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
        End If;


       --dbms_output.put_line('deal type :'||l_deal_type);
       --get the adjusted parameters for all the lines from line transactions
       Open adj_txl_csr(p_rbk_chr_id     => p_rbk_chr_id,
                        p_effective_date => l_date_trx_occured);
       Loop
           Fetch adj_txl_csr into adj_txl_rec;

           IF adj_txl_csr%NOTFOUND Then

      ------------------------------------------------------------------
      -- Bug# 3103387 : Residual value is only used to default salvage value.
      -- Salvage value should not be updated when there is a change in residual
      -- value for an Operating Lease. So the following code is not required.
      /*---------------------------------------------------------------


      ------------------------------------------------------------------------*/
      --Bug# 3103387 : End of commented code
      -------------------------------------------------------------------------
              Exit;-- exit from adj_txl_csr
           ---------------------------------------------
           Else --adj_txl_csr  found
           ---------------------------------------------

               ----------------------------------------------------------------------
               --Bug# 3548044: Multi-GAAP reporting Books should not follow CORP book
               --changes . But Mass rebook does not support corp book changes
               --does not support Multi-GAAP book changes
               ----------------------------------------------------------------------
               If ( adj_txl_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR)) Then
                   --Exit;
                   Null;
                   --do not change the reporting tax book
               Else
                   --get actual parameters from FA to get the Delta
                   Open okx_ast_csr (p_asset_number => adj_txl_rec.asset_number,
                                     p_book_type_code => adj_txl_rec.book_type_code);
                   Loop
                       Fetch okx_ast_csr into okx_ast_rec;
                       Exit When okx_ast_csr%NOTFOUND;
                       --dbms_output.put_line('book type code '||okx_ast_rec.book_type_code);
                       --check if the line is effective on the original contract
                       l_chk_cle_effective := '?';
                       Open chk_line_csr(p_chr_id         => l_chr_id,
                                         p_asset_id1      => okx_ast_rec.asset_id,
                                         p_asset_id2      => '#',
                                         p_effective_date => l_date_trx_occured);
                       Fetch chk_line_csr into l_chk_cle_effective;
                       If chk_line_csr%NOTFOUND Then
                           Null;
                       End If;
                       Close chk_line_csr;
                       If l_chk_cle_effective = '?' Then
                           Exit; -- this line is not effective on the original contract
                       --dbms_output.put_line('not an effective line.');
                       Else
                           --initialize
                           l_adjust_yn := 'N';
                           l_cost_delta := 0;
                           l_salvage_delta := 0;



      ------------------------------------------------------------------
      -- Bug# 3103387 : Residual value is only used to default salvage value.
      -- Salvage value should not be updated when there is a change in residual
      -- value for an Operating Lease. So the following code is not required.

      ------------------------------------------------------------------------*/
      --Bug# 3103387 : End of commented code
      --------------------------------------------------------------------------

                           --Bug# 2942543 : cost updates for DF lease contracts
                           If (l_cost_delta <> 0) Then
                              If l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 l_tax_owner = 'LESSEE' Then
                                 --no cost updates for df/st lease with tax owner 'LESSEE'
                                 Null;
                              Elsif l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 okx_ast_rec.book_class = 'CORPORATE' Then
                                 --No cost updates for df/st lease on corporate asset book as
                                 --cost is adjusted to zero there from creation time
                                 Null;
                              --BUG# 3548044 : cost updates on corp book not supported
                              Elsif okx_ast_rec.Book_class = 'CORPORATE' then
                                  null;
                              Else
                                  l_asset_fin_rec_adj.cost := l_cost_delta;
                                  l_adjust_yn := 'Y';
                              End If;
                           End If;

                           --Bug# 2942543 : salvage value updates for DF lease contracts
                           If (l_salvage_delta <> 0) Then
                              If l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 l_tax_owner = 'LESSEE' Then
                                  --no sv updates for df/st lease with tax owner 'LESSEE'
                                  Null;
                              Elsif l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) And
                                 okx_ast_rec.book_class = 'CORPORATE' Then
                                  --No cost updates for df/st lease on corporate asset book as
                                  --sv is adjusted to zero there from creation time
                                  Null;
                              Elsif okx_ast_rec.book_class = 'TAX' Then
                                  --Salvage value will be zero in all the tax books as per bug#2967286
                                  Null;
                              --BUG# 3548044 : SV updates on corp book not supported
                              Elsif okx_ast_rec.Book_class = 'CORPORATE' then
                                  null;
                              Else
                                  l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                                  l_adjust_yn := 'Y';
                              End If;
                           End If;


                           -- Mass rebook - Other than residual value change no other
                           --updates are allowed on the CORP Book
                           If okx_ast_rec.book_class = 'CORPORATE' then
                              Null;
                           Else
                               If  trunc(nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date)) <> trunc(okx_ast_rec.in_service_date) Then
                                   l_asset_fin_rec_adj.date_placed_in_service := nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date);
                                   l_adjust_yn := 'Y';
                               End If;
                               --dbms_output.put_line('txl life :'|| to_char(adj_txl_rec.life_in_months));
                               --dbms_output.put_line('okx life :'|| to_char(okx_ast_rec.life_in_months));
                               --Bug# 3621663
                               If  nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months) <> okx_ast_rec.life_in_months
                               Then
                                   l_asset_fin_rec_adj.life_in_months    := nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months);
                                   l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                                   l_asset_fin_rec_adj.basic_rate            := Null;
                                   l_asset_fin_rec_adj.adjusted_rate         := Null;
                                   l_adjust_yn := 'Y';
                               End If;

                               --category updates not supported by API
                               --If adj_txl_rec.depreciation_id <> okx_ast_rec.depreciation_category Then
                               If nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code) <> okx_ast_rec.deprn_method_code Then
                                   l_asset_fin_rec_adj.deprn_method_code  := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                                   If adj_txl_rec.life_in_months is not null then
                                       l_asset_fin_rec_adj.life_in_months     := nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months);
                                       l_asset_fin_rec_adj.basic_rate         := null;
                                       l_asset_fin_rec_adj.adjusted_rate      := null;
                                   Elsif adj_txl_rec.life_in_months is null then
                                       If adj_txl_rec.deprn_rate is not null then
                                           l_asset_fin_rec_adj.basic_rate         := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.basic_rate);
                                           l_asset_fin_rec_adj.adjusted_rate      := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate);
                                       End If;
                                    End If;
                                   l_adjust_yn := 'Y';
                               End If;

                               If nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate) <> okx_ast_rec.adjusted_rate Then
                                   If adj_txl_rec.life_in_months is  NULL then
                                       l_asset_fin_rec_adj.deprn_method_code  := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                                       l_asset_fin_rec_adj.basic_rate         := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.basic_rate);
                                       l_asset_fin_rec_adj.adjusted_rate      := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate);
                                       l_asset_fin_rec_adj.life_in_months     := NULL;
                                       l_adjust_yn := 'Y';
                                   End If;
                               End If;
                               --Bug# 3621663 (BP of Bug 3548044)

                           End If; --change deprn parameters only for Tax Books

                           If nvl(l_adjust_yn,'N') = 'Y' AND
                              l_deal_type not in (G_LOAN_BK_CLASS,G_REVOLVING_LOAN_BK_CLASS) then
                               --call the adjustment api to do adjustment
                              --dbms_output.put_line('Cost :'||to_char(l_asset_fin_rec_adj.cost));
                              --dbms_output.put_line('Sal Val :'||to_char(l_asset_fin_rec_adj.salvage_value));
                              --dbms_output.put_line('DPIS :'||to_char(l_asset_fin_rec_adj.date_placed_in_service,'dd-mon-yyyy'));
                              --dbms_output.put_line('life :'||to_char(l_asset_fin_rec_adj.life_in_months));
                              --dbms_output.put_line('DPRN Method :'||l_asset_fin_rec_adj.deprn_method_code);
                              --dbms_output.put_line('Rate B :'||to_char(l_asset_fin_rec_adj.basic_rate));
                              --dbms_output.put_line('Rate A :'||to_char(l_asset_fin_rec_adj.adjusted_rate));

                               --bug # 2942543 :
                               --check if salvage value is becoming more than asset cost
                               --BUG# 3548044: check for all the books (not only corporate book)
                               --If okx_ast_rec.book_class = 'CORPORATE' then --salvage value updates only for CORP
                               l_new_salvage_value := okx_ast_rec.salvage_value + l_salvage_delta;
                               l_new_cost          := okx_ast_rec.cost + l_cost_delta;
                               If (l_new_cost < l_new_salvage_value) Then
                                   OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                       p_msg_name     => G_SALVAGE_VALUE
                                                      );
                                       RAISE OKL_API.G_EXCEPTION_ERROR;
                               End If;
                               --End If; --Bug# 3548044

                               --sechawla bug 8370324
                               l_release_chr_yn := 'N';
                               OPEN chk_release_chr_csr(p_chr_id => p_rbk_chr_id);
                               FETCH chk_release_chr_csr INTO l_release_chr_yn;
                               CLOSE chk_release_chr_csr;

                               IF (l_release_chr_yn = 'Y') THEN
                                 l_rebook_fa_trx_date := adj_txl_rec.line_start_date;
                               ELSE
                                 l_rebook_fa_trx_date := nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date);
                               END IF;
                               --sechawla bug 8370324

                               -- Bug# 3783518
                               -- Revision date should be in the current open period or in a
                               -- prior period in FA

                               validate_rebook_date
                                  (p_api_version     => p_api_version,
                                   p_init_msg_list   => p_init_msg_list,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data,
                                   p_book_type_code  => okx_ast_rec.book_type_code,
                                   --bug# 8370324
                                   p_rebook_date     => l_rebook_fa_trx_date,
                                   p_cost_adjustment => l_asset_fin_rec_adj.cost,
                                   p_contract_start_date => l_start_date);

                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;

                               --Bug# 6373605
                               l_asset_fin_rec_adj.contract_id := p_rbk_chr_id;
                               --Bug# 6373605 end
                               FIXED_ASSET_ADJUST
                                     (p_api_version         => p_api_version,
                                      p_init_msg_list       => p_init_msg_list,
                                      x_return_status       => x_return_status,
                                      x_msg_count           => x_msg_count,
                                      x_msg_data            => x_msg_data,
                                      p_chr_id              => p_rbk_chr_id,
                                      p_asset_id            => okx_ast_rec.asset_id,
                                      p_book_type_code      => okx_ast_rec.book_type_code,
                                      p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                                      --Bug# 8370324
                                      p_adj_date            => l_rebook_fa_trx_date,
                                      --Bug# 3156924
                                      p_trans_number        => l_trans_number,
                                      p_calling_interface   => l_calling_interface,
            --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
            p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
            p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
            p_sla_source_chr_id       => p_rbk_chr_id,
            p_sla_source_kle_id       => adj_txl_rec.sla_source_kle_id,
            --Bug# 6373605--SLA populate sources
                                      --Bug# 4028371
                                      x_fa_trx_date         => l_fa_adj_date,
                                      --Bug# 3156924
                                      x_asset_fin_rec_new   => l_asset_fin_rec_new);

                              --dbms_output.put_line('After fixed asset adjust for rebook :'||x_return_status);
                              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                              END IF;
                             --Bug# 4028371
                              If adj_txl_rec.tal_id is not null Then
                                  --update the fa trx date on transaction line
                                      l_talv_date_rec.id     := adj_txl_rec.tal_id;
                                      l_talv_date_rec.fa_trx_date := l_fa_adj_date;

                                      okl_tal_pvt.update_row
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_talv_rec      => l_talv_date_rec,
                                         x_talv_rec      => lx_talv_date_rec);
                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;
                             End If;
                             --End Bug# 4028371
                          End If; --l_adjust_yn = 'Y'



                           ---------------------------------------------------------------
                           --Bug# 3548044 : MultiGaap Book to follow its own changes
                           --will not mimic corporate book.mass rebook does not support
                           --changes on multi-gaap and local corporate book
                           ---------------------------------------------------------------
                           --start of comments
                           /*-------------------------------------------------------------

                        --end of comments
                        ------------------------------------------------------------------*/
                        --Bug# 3548044


                        End If; --chk_cle effective
                    End Loop;
                    Close okx_ast_csr;
                End If; -- tax book is not reporting book

               --Bug# 3548044 : set the status of transaction to processed
                If adj_txl_rec.tas_id is not NULL then

                    update_trx_status(p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_tas_id        => adj_txl_rec.tas_id,
                                      p_tsu_code      => G_TSU_CODE_PROCESSED);

                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                End If;
                --End Bug# 3548044

                End If; --adj_txl_rec found
            End Loop;
            Close adj_txl_csr;
        End If; --rbr code csr
        CLOSE rbr_code_csr;
        OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;

    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;

    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;

    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END MASS_REBOOK_ASSET;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name :  RELEASE_ASSET (Activate code branch for release)
--Description    :  Will be called from activate asset and make re-lease adjustments
--                  in FA
--History        :
--                 06-May-2002  ashish.singh Created
-- Notes         :
--      IN Parameters -
--                     p_rel_chr_id    - contract id of released contract
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE RELEASE_ASSET (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rel_chr_id    IN  NUMBER
                        ) IS

   l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
   l_api_name             CONSTANT varchar2(30) := 'RELEASE_ASSET';
   l_api_version          CONSTANT NUMBER := 1.0;
   l_trx_type             Varchar2(30) := G_TRX_LINE_TYPE_RELEASE;

   --Cursor to get the k header infor
   --do you have records in trx contracts for re-lease - iguess no
   CURSOR k_hdr_csr (p_rel_chr_id IN NUMBER) IS
   SELECT khr.deal_type,
          chr.id,
          chr.sts_code,
          rul.rule_information1,
          chr.orig_system_id1,
          khr.pdt_id,
          chr.start_date,
          --Bug# 4631549
          chr.orig_system_source_code
   FROM   OKC_RULES_B       rul,
          OKL_K_HEADERS     khr,
          OKC_K_HEADERS_B   chr
   WHERE  rul.dnz_chr_id                  = chr.id
   AND    rul.rule_information_category   = 'LATOWN'
   AND    rul.dnz_chr_id                  = khr.id
   AND    khr.id                          = chr.id
   AND    chr.id                          = p_rel_chr_id
   --Bug#2522439
   --AND    chr.orig_system_source_code     = 'OKL_RELEASE';
   AND     exists (SELECT '1'
               FROM   OKC_RULES_B rul_rel_Ast
               WHERE  rul_rel_ast.dnz_chr_id = chr.id
               AND    rul_rel_ast.rule_information_category = 'LARLES'
               AND    nvl(rule_information1,'N') = 'Y');
   --Bug#2522439

   l_deal_type         OKL_K_HEADERS.deal_type%TYPE;
   l_rel_chr_id        OKC_K_HEADERS_B.ID%TYPE;
   l_sts_code          OKC_K_HEADERS_B.STS_CODE%TYPE;
   l_tax_owner         OKC_RULES_B.RULE_INFORMATION1%TYPE;
   l_orig_chr_id       OKC_K_HEADERS_B.ID%TYPE;
   --Bug# : 11.5.9 enhancement Multi GAAP
   l_pdt_id            OKL_K_HEADERS.pdt_id%TYPE;
   l_start_date        Date;
   l_rep_pdt_id        Number;
   l_rep_deal_type     Varchar2(150);
   l_Multi_GAAP_YN     Varchar2(1) := 'N';
   l_rep_pdt_book      OKX_AST_BKS_V.Book_Type_Code%Type;
   --Bug# 4631549
   l_orig_system_source_code okc_k_headers_b.orig_system_source_code%TYPE;

---------------- ---------------------------------------------------------------*/

   --cursor to get the modified transaction values against the release contract
   CURSOR adj_txl_csr (p_rel_chr_id IN NUMBER ) IS
   SELECT txl.in_service_date   in_service_date,
          txl.life_in_months    life_in_months,
          txl.depreciation_cost depreciation_cost,
          txl.depreciation_id   asset_category_id,
          txl.deprn_method      deprn_method,
          txl.deprn_rate        deprn_rate,
          txl.salvage_value     salvage_value,
          txl.corporate_book    book_type_code,
          txl.asset_number      asset_number,
          txl.kle_id            kle_id,
          --Bug# 3156924
          trx.trans_number,
          --Bug# 3533936
          txl.fa_location_id    fa_location_id,
          trx.id                tas_id,
          txl.salvage_value     corp_salvage_value,
          --Bug# 3631094
          txl.percent_salvage_value corp_percent_sv,
          txl.corporate_book    corp_book,
          fab.book_class        book_class,
          --Bug# 4028371
          txl.id                tal_id,
          --Bug# 3950089
          txl.percent_salvage_value pct_salvage_value,
          txl.percent_salvage_value corp_pct_salvage_value,
          --Bug# 6373605 start
          trx.id sla_source_header_id,
          txl.id sla_source_line_id,
          'OKL_TXL_ASSETS_B' sla_source_line_table,
          trx.try_id         sla_source_try_id,
          cle.cle_id         sla_source_kle_id
          --Bug# 6373605 end
   FROM   OKL_TRX_TYPES_TL  ttyp,
          OKL_TRX_ASSETS    trx,
          OKL_TXL_ASSETS_B  txl,
          OKC_K_LINES_B     cle,
          OKC_LINE_STYLES_B lse,
          -- Bug# 3631094
          FA_BOOK_CONTROLS  fab
   WHERE  txl.kle_id     = cle.id
   AND    cle.dnz_chr_id = p_rel_chr_id
   AND    cle.lse_id     = lse.id
--effectivity
   --And    nvl(cle.start_date,p_effective_date) <= p_effective_date
   --And    nvl(cle.end_date,p_effective_date+1) >  p_effective_date
   AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      --Bug# 2522268
                      --And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELED')
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                      )
   AND    lse.lty_code   = G_FA_LINE_LTY_CODE
   --Bug# 3156924:
   /*----------------------------------------------------
   --AND    exists (select  null
                  --from    OKL_TRX_ASSETS    trx,
                          --OKL_TRX_TYPES_TL  ttyp
                  --where   trx.id        = txl.tas_id
                  --and     trx.try_id    = ttyp.id
                  --and     ttyp.name     = 'Internal Asset Creation'
                  --and     ttyp.language = 'US'
                  --and     trx.tsu_code  <>  'PROCESSED'
                  --Bug#2522439
                  ----and     trx.tas_type   = G_TRX_HDR_TYPE_RELEASE)
                  --and     trx.tas_type   = G_TRX_HDR_TYPE_BOOK)
   -------------------------------------------------------*/
   AND     trx.id        = txl.tas_id
   and     trx.try_id    = ttyp.id
   and     ttyp.name     = 'Internal Asset Creation'
   and     ttyp.language = 'US'
   and     trx.tsu_code  <>  'PROCESSED'
   --Bug#2522439
   --and     trx.tas_type   = G_TRX_HDR_TYPE_RELEASE)
   and     trx.tas_type   = G_TRX_HDR_TYPE_RELEASE
   AND    txl.tal_type = G_TRX_LINE_TYPE_RELEASE
   --Bug# 3631094
   AND fab.book_type_code = txl.corporate_book
   UNION
   SELECT txl.in_service_date    in_service_date,
          txd.life_in_months_tax life_in_months,
          txd.cost               depreciation_cost,
          txl.depreciation_id    asset_category_id,
          txd.deprn_method_tax   deprn_method,
          txd.deprn_rate_tax     deprn_rate,
          txd.salvage_value      salvage_value,
          txd.tax_book           book_type_code,
          txd.asset_number       asset_number,
          txl.kle_id             kle_id,
          --Bug# 3156924
          trx.trans_number,
          --Bug# 3533936
          null                   fa_location_id,
          null                   tas_id,
          txl.salvage_value      corp_salvage_value,
          --Bug# 3631094
          txl.percent_salvage_value corp_percent_sv,
          txl.corporate_book    corp_book,
          fab.book_class        book_class,
          --Bug# 4028371
          null                  tal_id,
          --Bug# 3950089
          txl.percent_salvage_value pct_salvage_value,
          txl.percent_salvage_value corp_pct_salvage_value,
          --bug# 6373605 start
          trx.id       sla_source_header_id,
          txd.id       sla_source_line_id,
          'OKL_TXD_ASSETS_B' sla_source_line_table,
          trx.try_id   sla_source_try_id,
          cle.cle_id   sla_source_kle_id
          --Bug# 6373605 end
    FROM  OKL_TRX_TYPES_TL  ttyp,
          OKL_TRX_ASSETS    trx,
          OKL_TXD_ASSETS_B  txd,
          OKL_TXL_ASSETS_B  txl,
          OKC_K_LINES_B     cle,
          OKC_LINE_STYLES_B lse,
          -- Bug# 3631094
          FA_BOOK_CONTROLS  fab
    WHERE  txd.tal_id = txl.id
    AND    txl.kle_id     = cle.id
    AND    cle.dnz_chr_id = p_rel_chr_id
    AND    cle.lse_id     = lse.id
    --effectivity
    --And    nvl(cle.start_date,p_effective_date) <= p_effective_date
    --And    nvl(cle.end_date,p_effective_date+1) >  p_effective_date
    AND    not exists (select '1'
                      from   OKC_STATUSES_B sts
                      Where  sts.code = cle.sts_code
                      --Bug#2522268
                      --And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELED')
                      And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                      )
   AND    lse.lty_code   = G_FA_LINE_LTY_CODE
   --bug# 3156924
  /*-------------------------------------------------------------
   --AND    exists (select  null
                  --from    OKL_TRX_ASSETS    trx,
                          --OKL_TRX_TYPES_TL  ttyp
                  --where   trx.id        = txl.tas_id
                  --and     trx.try_id    = ttyp.id
                  --and     ttyp.name     = 'Release'
                  --and     ttyp.language = 'US'
                  --and     trx.tsu_code <>  'PROCESSED'
                  --and     trx.tas_type  = G_TRX_HDR_TYPE_RELEASE)
  ---------------------------------------------------------------*/
  AND  trx.id        = txl.tas_id
  AND  trx.try_id    = ttyp.id
  and  ttyp.name     = 'Internal Asset Creation'
  and  ttyp.language = 'US'
  and  trx.tsu_code <>  'PROCESSED'
  and  trx.tas_type  = G_TRX_HDR_TYPE_RELEASE
  --bug# 3156924
  AND    txl.tal_type = G_TRX_LINE_TYPE_RELEASE
  --Bug# 3631094
  AND fab.book_type_code = txd.tax_book
  ORDER BY asset_number, book_class ;

   adj_txl_rec  adj_txl_csr%ROWTYPE;

  --cursor to get the actual values from FA for the contract
  CURSOR okx_ast_csr (p_asset_number     IN VARCHAR2,
                      p_book_type_code   IN VARCHAR2) is
  SELECT  okx.acquisition_date       in_service_date,
          okx.life_in_months         life_in_months,
          okx.cost                   cost,
          okx.depreciation_category  depreciation_category,
          okx.deprn_method_code      deprn_method_code,
          okx.adjusted_rate          adjusted_rate,
          okx.basic_rate             basic_rate,
          okx.salvage_value          salvage_value,
          --Bug# 3631094
          okx.percent_salvage_value  percent_salvage_value,
          okx.book_type_code         book_type_code,
          okx.book_class             book_class,
          okx.asset_number           asset_number,
          okx.asset_id               asset_id
   FROM   okx_ast_bks_v okx
   WHERE  okx.asset_number       = p_asset_number
   AND    okx.book_type_code    =  nvl(p_book_type_code,okx.book_type_code);

   okx_ast_rec   okx_ast_csr%ROWTYPE;

  l_cost_delta              Number;
  l_salvage_delta           Number;
  l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
  l_adjust_yn               Varchar2(1);
  l_dummy_amount NUMBER;

  --cursor to get tax owner rule
  Cursor town_rul_csr (pchrid number) is
  Select rule_information1 tax_owner,
         id
  From   okc_rules_b rul
  where  rul.dnz_chr_id = pchrid
  and    rul.rule_information_category = 'LATOWN'
  and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

  l_town_rul      okc_rules_b.rule_information1%TYPE;
  l_town_rul_id   okc_rules_b.id%TYPE;

  --Bug# 2942543 :
  l_new_salvage_value number;
  l_new_cost          number;

  ---------------------------------------------------
  --Bug# 3143522 : 11.5.10 Subsidies
  ---------------------------------------------------
  cursor l_allast_csr (p_chr_id in number) is
  select cleb.id,
         --Bug# 3783518
         cleb.orig_system_id1
  from   okc_k_lines_b     cleb,
         okc_line_styles_b lseb,
         okc_statuses_b     stsb
  where  cleb.chr_id        = p_chr_id
  and    cleb.dnz_chr_id    = p_chr_id
  and    lseb.id            = cleb.lse_id
  and    lseb.lty_code      = G_FIN_AST_LINE_LTY_CODE
  and    stsb.code          = cleb.sts_code
  and    stsb.ste_code      not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

  l_asset_cle_id okc_k_lines_b.ID%TYPE;

  l_subsidy_exists      varchar2(1) default OKL_API.G_FALSE;
  l_total_discount      number;
  l_cost_adjustment     number;

  --cursor to get asset id
  cursor l_asset_csr (p_asset_cle_id in number) is
  select fab.asset_id          asset_id,
         ast_clet.name         asset_number,
         fab.cost              asset_cost,
         fab.book_type_code    book_type_code,
         txl.in_service_date   in_service_date,
         --bug# 3156924
         trx.trans_number,
         --Bug# 6373605 start
         trx.id sla_source_header_id,
         txl.id sla_source_line_id,
         trx.try_id sla_source_try_id,
         fa_cleb.cle_id sla_source_kle_id,
         fbc.book_class
         --Bug# 6373605 end
  from
         fa_books              fab,
         --Bug# 6373605 start
         fa_book_controls      fbc,
         --Bug# 6373605 end
         okc_k_items           fa_cim,
         okl_trx_types_tl      ttyp,
         okl_trx_assets        trx,
         okl_txl_assets_b      txl,
         okc_k_lines_b         fa_cleb,
         okc_line_styles_b     fa_lseb,
         okc_k_lines_tl        ast_clet
  where
         fab.asset_id               = to_number(fa_cim.object1_id1)
  and    fab.transaction_header_id_out is NULL
  --Bug# 6373605 start
  and    fab.book_type_code         = fbc.book_type_code
  --bug# 6373605 end
  and    fa_cim.object1_id2         = '#'
  and    fa_cim.jtot_object1_code   = 'OKX_ASSET'
  and    fa_cim.dnz_chr_id          = fa_cleb.dnz_chr_id
  and    fa_cim.cle_id              = fa_cleb.id
  and    txl.kle_id                 = fa_cleb.id
  and    txl.tal_type               = G_TRX_LINE_TYPE_RELEASE
  and    trx.id                     = txl.tas_id
  and    trx.try_id                 = ttyp.id
  --Bug# 2981308
  and    ttyp.name                  = 'Internal Asset Creation'
  --and    ttyp.name                  = 'Release'
  and    ttyp.language              = 'US'
  and    trx.tsu_code               <>  'PROCESSED'
  --Bug# 2981308
  and    trx.tas_type               = G_TRX_HDR_TYPE_RELEASE
  --and    trx.tas_type               = G_TRX_HDR_TYPE_RELEASE
  and    fa_cleb.cle_id             = p_asset_cle_id
  and    fa_lseb.id                 = fa_cleb.lse_id
  and    fa_lseb.lty_code           = G_FA_LINE_LTY_CODE
  and    ast_clet.id                = p_asset_cle_id
  and    ast_clet.language          = userenv('LANG');

  l_asset_rec     l_asset_csr%RowType;

  --Bug# 6373605 start
  Cursor l_txd_from_book_type_csr (p_book_type_code in varchar2,
                               p_tal_id         in number) is
  select id sla_source_line_id,
         tax_book
  from   okl_txd_Assets_b
  where  tal_id = p_tal_id
  and    tax_book = p_book_type_code;

  l_txd_from_book_type_rec l_txd_from_book_type_csr%ROWTYPE;

  l_sla_source_line_id number;
  l_sla_source_line_table OKL_EXT_FA_LINE_SOURCES_V.SOURCE_TABLE%TYPE;
  --Bug# 6373605 End

  --Bug# 3156924
  l_release_date      date;
  l_trans_number      okl_trx_assets.trans_number%TYPE;
  l_calling_interface varchar2(30) := 'OKLRACAB:Release';

  --BUG# 3548044
  l_release_allowed_on_mg_book  varchar2(1);

  ---------------------------------------------------
  --Bug# 3631094 : start
  ---------------------------------------------------
  --Cursor to set transaction status to Processed
  CURSOR tas_csr(p_chr_id in number) IS
  SELECT trx.id
  FROM   OKL_TRX_ASSETS    trx,
         OKL_TXL_ASSETS_B  txl,
         OKC_K_LINES_B     cle,
         OKC_LINE_STYLES_B lse
  WHERE  txl.kle_id     = cle.id
  AND    cle.dnz_chr_id = p_chr_id
  AND    cle.lse_id     = lse.id
  AND    not exists (select '1'
                     from   OKC_STATUSES_B sts
                     Where  sts.code = cle.sts_code
                     And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
                     )
  AND    lse.lty_code  =  G_FA_LINE_LTY_CODE
  AND    trx.id        =  txl.tas_id
  and    trx.tsu_code  <> 'PROCESSED'
  and    trx.tas_type  =  G_TRX_HDR_TYPE_RELEASE
  AND    txl.tal_type  =  G_TRX_LINE_TYPE_RELEASE;

  --Cursor to check if asset_id already exists in tax_book
  CURSOR chk_ast_bk_csr(p_book_type_code IN Varchar2,
                      p_asset_id       IN Number) is
  SELECT '!'
  FROM   OKX_AST_BKS_V
  WHERE  asset_id = p_asset_id
  AND    book_type_code = p_book_type_code
  AND    status = 'A';

  l_ast_bk_exists     Varchar2(1) default '?';

  --Cursor to chk book validity for an asset category
  CURSOR chk_cat_bk_csr(p_book_type_code IN VARCHAR2,
                        p_category_id    IN NUMBER) is
  SELECT '!'
  FROM   OKX_AST_CAT_BKS_V
  WHERE  CATEGORY_ID = p_category_id
  AND    BOOK_TYPE_CODE = p_book_type_code
  AND    STATUS = 'A';

  l_cat_bk_exists    Varchar2(1) default '?';

  --Cursor chk if corp book is the mass copy source book
  CURSOR chk_mass_cpy_book(p_corp_book IN Varchar2,
                           p_tax_book  IN Varchar2) is
  SELECT '!'
  FROM   OKX_ASST_BK_CONTROLS_V
  WHERE  book_type_code = p_tax_book
  AND    book_class = 'TAX'
  AND    mass_copy_source_book = p_corp_book
  AND    allow_mass_copy = 'YES'
  AND    copy_additions_flag = 'YES';

  l_mass_cpy_book   Varchar2(1) default '?';

  --Cursor to fetch book records for an asset
  Cursor ast_bks_csr(p_asset_id    IN NUMBER,
                     p_book_class  IN VARCHAR2) is
  select book_type_code,
         cost,
         salvage_value,
         percent_salvage_value
  from   okx_ast_bks_v
  where  asset_id = p_Asset_id
  and    book_class = p_book_class;

  ast_corp_book_rec    okx_ast_csr%ROWTYPE;
  ast_rep_book_rec     okx_ast_csr%ROWTYPE;
  l_bk_dfs_rec         bk_dfs_csr%ROWTYPE;
  l_asset_hdr_rec      FA_API_TYPES.asset_hdr_rec_type;
  l_talv_rec           talv_rec_type;
  l_no_data_found      BOOLEAN;
  l_asset_fin_rec      FA_API_TYPES.asset_fin_rec_type;
  l_adjust_cost        NUMBER;
  l_adj_salvage_value  NUMBER;
  l_adj_percent_sv     NUMBER;

  l_current_asset_number OKX_ASSETS_V.Name%Type;
  l_asset_corp_book_cost NUMBER;
  ---------------------------------------------------
  --Bug# 3631094 : end
  ---------------------------------------------------

  --Bug# 3783518
  CURSOR orig_pdt_csr(p_cle_id IN NUMBER) is
  SELECT pdt.reporting_pdt_id
  FROM okc_k_lines_b cle,
       okl_k_headers khr,
       okl_products pdt
  WHERE cle.id = p_cle_id
  AND   khr.id = cle.dnz_chr_id
  AND   pdt.id = khr.pdt_id;

  l_subsidy_asset_fin_rec_adj  FA_API_TYPES.asset_fin_rec_type;
  l_orig_system_id1    NUMBER;
  l_orig_reporting_pdt_id NUMBER;


  ------
  --Bug# 4028371
  -----
  l_fa_add_date_mg   date;
  l_fa_adj_date_mg   date;
  l_fa_adj_date      date;
  l_fa_tsfr_date     date;
  l_talv_date_rec    okl_tal_pvt.talv_rec_type;
  lx_talv_date_rec   okl_tal_pvt.talv_rec_type;
  ------
  --Bug# 4028371
  ------
  l_hdr_rec          l_hdr_csr%ROWTYPE;

  -- Bug# 4627009
  l_add_cap_fee      varchar2(1) ;
  l_cap_fee_delta number;
  l_cap_fee_delta_converted_amt number;

  Cursor cap_fee_csr(fa_cle_id   in number
                    ,rel_chr_id  in number) IS
  Select nvl(sum(cov_ast_kle.capital_amount),0) capitalized_fee
  From
       OKL_K_LINES       fee_kle,
       OKC_K_LINES_B     fee_cle,
       OKC_STATUSES_B    fee_sts,
       OKL_K_LINES       cov_ast_kle,
       OKC_K_LINES_B     cov_ast_cle,
       OKC_LINE_STYLES_B cov_ast_lse,
       OKC_STATUSES_B    cov_ast_sts,
       OKC_K_ITEMS       cov_ast_cim,
       OKC_K_LINES_B     fa_cle
  Where  fee_kle.id                    = fee_cle.id
  and    fee_kle.fee_type              = 'CAPITALIZED'
  and    fee_cle.id                    = cov_ast_cle.cle_id
  and    fee_cle.dnz_chr_id            = cov_ast_cle.dnz_chr_id
  and    fee_cle.sts_code              = fee_sts.code
  and    fee_sts.ste_code not in         ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
  and    cov_ast_kle.id                = cov_ast_cle.id
  and    cov_ast_cle.id                = cov_ast_cim.cle_id
  and    cov_ast_cle.lse_id            = cov_ast_lse.id
  and    cov_ast_lse.lty_code          = 'LINK_FEE_ASSET'
  and    cov_ast_cle.sts_code          = cov_ast_sts.code
  and    cov_ast_sts.ste_code not in    ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
  and    cov_ast_cle.dnz_chr_id        = cov_ast_cim.dnz_chr_id
  and    cov_ast_cim.object1_id1       = to_char(fa_cle.cle_id)
  and    cov_ast_cim.object1_id2       = '#'
  and    cov_ast_cim.jtot_object1_code = 'OKX_COVASST'
  and    fa_cle.id                     = fa_cle_id
  and    fee_cle.dnz_chr_id             = rel_chr_id ;

  --Bug# 4627009 end

  --5261704
  l_depreciate_flag  VARCHAR2(3);

  --Bug# 6373605 start
  l_dummy_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
  --Bug# 6373605 end

BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --get rebook reason code
    --dbms_output.put_line('before rebook reason code cursor :');
    OPEN  k_hdr_csr (p_rel_chr_id => p_rel_chr_id);
    Fetch k_hdr_csr into
                            l_deal_type,
                            l_rel_chr_id,
                            l_sts_code,
                            l_tax_owner,
                            l_orig_chr_id,
                            l_pdt_id,
                            l_start_date,
                            --Bug# 4631549
                            l_orig_system_source_code;


    If k_hdr_csr%NOTFOUND Then
       --rebook transacton not found
       --does this call for raising error
       Null;
    Else

        --Bug# :11.5.9 : Multi-GAAP Begin
        Get_Pdt_Params (p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_pdt_id        => l_pdt_id,
                        p_pdt_date      => l_start_date,
                        x_rep_pdt_id    => l_rep_pdt_id,
                        x_tax_owner     => l_tax_owner,
                        x_rep_deal_type => l_rep_deal_type);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    	If l_tax_owner is null then
        Open town_rul_csr(pchrid => p_rel_chr_id);
            Fetch town_rul_csr into l_town_rul,
                                    l_town_rul_id;
            If town_rul_csr%NOTFOUND Then
                OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Tax Owner');
                x_return_status := OKC_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
            Else
                l_tax_owner := rtrim(ltrim(l_town_rul,' '),' ');
            End If;
        Close town_rul_csr;
        End If;

        OPEN l_hdr_csr( p_rel_chr_id );
        FETCH l_hdr_csr INTO l_hdr_rec;
        CLOSE l_hdr_csr;

        G_CHR_CURRENCY_CODE := l_hdr_rec.currency_code;
	G_FUNC_CURRENCY_CODE := okl_accounting_util.get_func_curr_code;
	G_CHR_AUTHORING_ORG_ID  := l_hdr_rec.authoring_org_id;
	G_CHR_START_DATE    := l_hdr_rec.start_date;
	G_CHR_REPORT_PDT_ID := l_hdr_rec.report_pdt_id;


       -- Bug# 3631094
       --BUG# 354804
       -- l_release_allowed_on_mg_book := 'Y';
        l_Multi_GAAP_YN := 'N';
        --checks wheter Multi-GAAP processing needs tobe done
        If l_rep_pdt_id is not NULL Then

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

            l_Multi_GAAP_YN := 'Y';
/*
            If l_deal_type = 'LEASEOP' and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSOR' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSOR' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSEE' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

            If l_deal_type = 'LOAN' and
            nvl(l_rep_deal_type,'X') = 'LEASEOP' and
            nvl(l_tax_owner,'X') = 'LESSEE' Then
                l_Multi_GAAP_YN := 'Y';
            End If;

           --Bug# 3548044
           --Bug# 3621663
           If l_deal_type  = 'LEASEOP' and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST')
            and nvl(l_tax_owner,'X') = 'LESSOR' then
                l_Multi_GAAP_YN := 'Y';
                -- Bug# 3631094
                --l_release_allowed_on_mg_book := 'N';
            End If;
            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
            nvl(l_tax_owner,'X') = 'LESSOR'  then
                l_Multi_GAAP_YN := 'Y';
                -- Bug# 3631094
                --l_release_allowed_on_mg_book := 'N';
            End If;
            If l_deal_type in ('LEASEDF','LEASEST') and
            nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
            nvl(l_tax_owner,'X') = 'LESSEE'  then
                l_Multi_GAAP_YN := 'Y';
                -- Bug# 3631094
                --l_release_allowed_on_mg_book := 'N';
            End If;
            --Bug# 3548044
*/
        End If;

        -- Bug# 3631094
        /*If l_Multi_GAAP_YN = 'Y' Then
            --get reporting product book type
            l_rep_pdt_book := fnd_profile.value('OKL_REPORTING_PDT_ASSET_BOOK');
        End If;*/

        --get reporting product book type
        l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);


        --dbms_output.put_line('deal type :'||l_deal_type);
        --dbms_output.put_line('rbr code :'||l_rbr_code);
        --get the adjusted parameters for all the lines from line transactions
        --dbms_output.put_line('deal type :'||l_deal_type);
        --get the adjusted parameters for all the lines from line transactions

       --Bug# 3631094
       l_current_asset_number := null;
       l_asset_corp_book_cost := null;

       Open adj_txl_csr(p_rel_chr_id     => p_rel_chr_id);
       Loop
           Fetch adj_txl_csr into adj_txl_rec;

           IF adj_txl_csr%NOTFOUND Then

              Exit;-- exit from adj_txl_csr

           ---------------------------------------------
           Else --adj_txl_csr  found
           ---------------------------------------------

              --Bug# 3631094
              IF (( l_current_asset_number is null ) OR
                 ( l_current_asset_number is not null and
                   l_current_asset_number <> adj_txl_rec.asset_number)) THEN

                l_current_asset_number := adj_txl_rec.asset_number;

                open okx_ast_csr(p_asset_number   => adj_txl_rec.asset_number,
                                 p_book_type_code => adj_txl_rec.corp_book);
                fetch okx_ast_csr into ast_corp_book_rec;
                close okx_ast_csr;

                l_asset_corp_book_cost := ast_corp_book_rec.cost;

              END IF;

              ---------------------------------------------------------------
               -- Bug# 3548044 : A part of this bug the multi-gaap book should
               -- not mimic corporate book . It should adjust based on entered
               -- parameters. DF/ST(local) vs DF/ST(reporting) MG books are created with cost
               -- and SV zero to be untouched till offlease amortization process
               ---------------------------------------------------------------
               -- Bug# 3631094
               /*If ( adj_txl_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR))
                  and (l_release_allowed_on_mg_book = 'N') Then
                   --Exit;
                   Null; --do not do anything for reporting book
               Else*/
                   --get actual parameters from FA to get the Delta
                   Open okx_ast_csr (p_asset_number => adj_txl_rec.asset_number,
                                     p_book_type_code => adj_txl_rec.book_type_code);

                       Fetch okx_ast_csr into okx_ast_rec;
                       If okx_ast_csr%NOTFOUND Then

                         -- Bug# 3631094: start
                         Close okx_ast_csr;

                         -- add asset to reporting product book
                         If l_Multi_GAAP_YN = 'Y' AND
                            adj_txl_rec.book_type_code = l_rep_pdt_book Then

                           open okx_ast_csr(p_asset_number   => adj_txl_rec.asset_number,
                                            p_book_type_code => adj_txl_rec.corp_book);
                           fetch okx_ast_csr into ast_corp_book_rec;
                           close  okx_ast_csr;

                           --chk if asset category is valid for the tax book
                           l_cat_bk_exists := '?';
                           open chk_cat_bk_csr(p_book_type_code => adj_txl_rec.book_type_code,
                                               p_category_id    => adj_txl_rec.asset_category_id);
                           Fetch chk_cat_bk_csr into l_cat_bk_exists;
                           Close chk_cat_bk_csr;

                           If l_cat_bk_exists = '?' Then
                             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
         	                              p_msg_name     => G_FA_INVALID_BK_CAT,
                                          p_token1       => G_FA_BOOK,
                                          p_token1_value => adj_txl_rec.book_type_code,
                                          p_token2       => G_ASSET_CATEGORY,
                                          p_token2_value => to_char(adj_txl_rec.asset_category_id)
                                         );
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                           Else
                             --check if asset already exists in tax book
                             l_ast_bk_exists := '?';
                             Open chk_ast_bk_csr(p_book_type_code => adj_txl_rec.book_type_code,
                                                 p_asset_id       => ast_corp_book_rec.asset_id);
                             Fetch chk_ast_bk_csr into l_ast_bk_exists;
                             Close chk_ast_bk_csr;

                             If l_ast_bk_exists = '!' Then --asset already exists in tax book
                               null; --do not have to add again
                             Else
                             --chk if corp book is the mass copy book for the tax book
                             l_mass_cpy_book := '?';
                             OPEN chk_mass_cpy_book(
                                                  p_corp_book => adj_txl_rec.corp_book,
                                                  p_tax_book  => adj_txl_rec.book_type_code);
                             Fetch chk_mass_cpy_book into l_mass_cpy_book;
                             Close chk_mass_cpy_book;

                             If l_mass_cpy_book = '?' Then
                               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                           p_msg_name     => G_FA_TAX_CPY_NOT_ALLOWED,
                                                   p_token1       => G_FA_BOOK,
                                                   p_token1_value => adj_txl_rec.book_type_code
				                                  );
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                             Else
                                --can masscopy
                                --intialize talv record for tax book

                                l_talv_rec := get_talv_rec(adj_txl_rec.kle_id, l_trx_type, l_no_data_found);
                                If l_no_data_found = TRUE Then
                                  --dbms_output.put_line('no asset creation transaction records ...!');
                                  OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
		                                          p_msg_name     => G_FA_TRX_REC_NOT_FOUND,
                                                      p_token1       => G_FA_LINE_ID,
                                                      p_token1_value => to_char(adj_txl_rec.kle_id)
				                              );
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                                End if;

                                l_talv_rec.corporate_book        := adj_txl_rec.book_type_code;
                                l_talv_rec.dnz_asset_id          := ast_corp_book_rec.asset_id;
                                l_talv_rec.depreciation_cost     := l_asset_corp_book_cost;
                                l_talv_rec.life_in_months        := adj_txl_rec.life_in_months;
                                l_talv_rec.deprn_method          := adj_txl_rec.deprn_method;
                                l_talv_rec.deprn_rate            := adj_txl_rec.deprn_rate;
                                l_talv_rec.salvage_value         := adj_txl_rec.corp_salvage_value;
                                l_talv_rec.percent_salvage_value := adj_txl_rec.corp_percent_sv;

                                l_release_date := l_start_date;
                                l_trans_number := adj_txl_rec.trans_number;

                                --Bug# 5261704 : Set depreciate flag to 'NO' if cost will be adjusted to zero
                                l_depreciate_flag := 'YES';
                                IF (l_rep_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS)) THEN
                                    l_depreciate_flag := 'NO';
                                End If;
                                --End Bug# 5261704

                                --call mass additions add for tax book
                                FIXED_ASSET_ADD(p_api_version       => p_api_version,
                                                p_init_msg_list     => p_init_msg_list,
                                                x_return_status     => x_return_status,
                                                x_msg_count         => x_msg_count,
                                                x_msg_data          => x_msg_data,
                                                p_talv_rec          => l_talv_rec,
                                                p_trans_number      => l_trans_number,
                                                p_calling_interface => l_calling_interface,
                                                --Bug# 5261704
                                                p_depreciate_flag   => l_depreciate_flag,
            --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
            p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
            p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
            p_sla_source_chr_id       => p_rel_chr_id,
            p_sla_source_kle_id       => adj_txl_rec.sla_source_kle_id,
            p_sla_asset_chr_id        => p_rel_chr_id,
            --Bug# 6373605--SLA populate sources
                                                --Bug# 4028371
                                                x_fa_trx_date       => l_fa_add_date_mg,
                                                x_asset_hdr_rec     => l_asset_hdr_rec);

                                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;

                                IF (l_rep_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS)) THEN

                                  open okx_ast_csr(p_asset_number   => adj_txl_rec.asset_number,
                                                   p_book_type_code => l_rep_pdt_book);
                                  fetch okx_ast_csr into ast_rep_book_rec;
                                  close okx_ast_csr;

                                  l_adjust_cost := (-1)* ast_rep_book_rec.cost;
                                  l_adj_salvage_value := (-1)*ast_rep_book_rec.salvage_value;
                                  l_adj_percent_sv := (-1)*ast_rep_book_rec.percent_salvage_value;

                                  IF nvl(l_adjust_cost,0) = 0 and nvl(l_adj_salvage_value,0) = 0
                                     and nvl(l_adj_percent_sv,0) = 0 Then
                                     Null;
                                  ELSE
                                    FIXED_ASSET_ADJUST_COST
                                    (p_api_version       => p_api_version,
                                     p_init_msg_list     => p_init_msg_list,
                                     x_return_status     => x_return_status,
                                     x_msg_count         => x_msg_count,
                                     x_msg_data          => x_msg_data,
                                     p_chr_id            => p_rel_chr_id,
                                     p_asset_id          => ast_corp_book_rec.asset_id,
                                     p_book_type_code    => l_rep_pdt_book,
                                     p_adjust_cost       => l_adjust_cost,
                                     p_adj_salvage_value => l_adj_salvage_value,
                                     p_adj_percent_sv    => l_adj_percent_sv,
                                     p_trans_number      => l_trans_number,
                                     p_calling_interface => l_calling_interface,
                                     p_adj_date          => l_release_date,
            --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
            p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
            p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
            p_sla_source_chr_id       => p_rel_chr_id,
            p_sla_source_kle_id       => adj_txl_rec.sla_source_kle_id,
            p_sla_asset_chr_id        => p_rel_chr_id,
            --Bug# 6373605--SLA populate sources
                                     --Bug# 4028371
                                     x_fa_trx_date       => l_fa_adj_date_mg,
                                     x_asset_fin_rec     => l_asset_fin_rec);

                                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                      RAISE OKL_API.G_EXCEPTION_ERROR;
                                    END IF;
                                  END IF;
                                END IF;

                             End If; --can mass copy into tax book
                            End If; --asset does not exist in tax book
                           End If; -- valid tax book for category
                         End If; -- l_Multi_GAAP_YN = 'Y'
                         -- Bug 3631094: end

                       Else

                           --Bug# 3631094
                           Close okx_ast_csr;

                           --initialize
                           l_adjust_yn := 'N';
                           l_cost_delta := 0;
                           l_salvage_delta := 0;

                           --Bug# 3548044 : Removed comments
                           l_asset_fin_rec_adj.cost                   := null;
                           l_asset_fin_rec_adj.salvage_value          := null;
                           l_asset_fin_rec_adj.date_placed_in_service := null;
                           l_asset_fin_rec_adj.life_in_months         := null;
                           l_asset_fin_rec_adj.deprn_method_code      := null;
                           l_asset_fin_rec_adj.basic_rate             := null;
                           l_asset_fin_rec_adj.adjusted_rate          := null;
                           --Bug# 3950089
                           l_asset_fin_rec_adj.percent_salvage_value  := null;
                           --Bug# 3548044 : Removed comments

                           --Bug# 4627009
                           l_add_cap_fee:='Y';
                           --Include Cap fee

                         -- Bug# 5150150 -- Don't Include Cap Fee for Re-lease contracts
                          l_cap_fee_delta := 0;
                          l_cap_fee_delta_converted_amt := 0;
                         IF NVL(l_orig_system_source_code,OKL_API.G_MISS_CHAR) <> 'OKL_RELEASE' THEN

                           open cap_fee_csr(fa_cle_id   => adj_txl_rec.kle_id
                                            ,rel_chr_id  => p_rel_chr_id);
                           fetch cap_fee_csr into l_cap_fee_delta;
                           close cap_fee_csr;
                           l_cap_fee_delta := NVL(l_cap_fee_delta,0);

                           l_cap_fee_delta_converted_amt := 0;
                           convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rel_chr_id,
                                         p_amount        => l_cap_fee_delta,
                                         x_amount        => l_cap_fee_delta_converted_amt);

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;

                           l_cap_fee_delta_converted_amt := NVL(l_cap_fee_delta_converted_amt,0);
                         END IF;   --Bug# 5150150

                           if (l_cap_fee_delta_converted_amt>0) THEN
			           l_add_cap_fee:='Y';
			         else
				     l_add_cap_fee:='N';
                           END IF;
                           --Bug# 4627009 end

      ------------------------------------------------------------------
      -- Bug# 3533936 : Update of Asset cost should not be allowed for a
      -- Re-lease contract.
      /*---------------------------------------------------------------

                           l_dummy_amount := null;
                           convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
	                                 x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rel_chr_id,
		                         p_amount        => adj_txl_rec.depreciation_cost,
		                         x_amount        => l_dummy_amount);

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;

                           --calculate deltas
                           l_cost_delta     := (l_dummy_amount - okx_ast_rec.cost);

      -----------------------------------------------------------------------*/
      --Bug# 3533936 : End of commented code
      ------------------------------------------------------------------------

                           --Bug# 3548044 : Added if-else clause for reporting product books
                           If okx_ast_rec.book_type_code <> nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) then

                             --Bug# 3950089
                             If (okx_ast_rec.percent_salvage_value is not null) Then

                               If (adj_txl_rec.pct_salvage_value is null) or
                                  (adj_txl_rec.salvage_value is not null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;

                             Elsif (okx_ast_rec.salvage_value is not null) Then

                               If (adj_txl_rec.salvage_value is null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;
                             End If;

                             If (okx_ast_rec.percent_salvage_value is not null) and
                                (okx_ast_rec.book_class = 'CORPORATE') Then

                               l_salvage_delta  := ((adj_txl_rec.pct_salvage_value/100)
                                                   - okx_ast_rec.percent_salvage_value);

                             Else
                               l_dummy_amount := null;
                               convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rel_chr_id,
                                         p_amount        => adj_txl_rec.salvage_value,
                                         x_amount        => l_dummy_amount);

                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;

                               l_salvage_delta  := (l_dummy_amount - okx_ast_rec.salvage_value);
                             End if;

                           ElsIf okx_ast_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) then

                             --Bug# 3950089
                             If (okx_ast_rec.percent_salvage_value is not null) Then

                               If (adj_txl_rec.corp_pct_salvage_value is null) or
                                  (adj_txl_rec.corp_salvage_value is not null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;

                             Elsif (okx_ast_rec.salvage_value is not null) Then

                               If (adj_txl_rec.corp_salvage_value is null) Then

                                 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                     p_msg_name     => 'OKL_LA_REVISE_SALVAGE_TYPE',
                                                     p_token1       => G_ASSET_NUMBER_TOKEN,
                                                     p_token1_value => okx_ast_rec.asset_number
                                                    );
                                 x_return_status := OKL_API.G_RET_STS_ERROR;
                                 RAISE OKL_API.G_EXCEPTION_ERROR;
                               End if;
                             End If;

                             If (okx_ast_rec.percent_salvage_value is not null) Then

                               l_salvage_delta  := ((adj_txl_rec.corp_pct_salvage_value/100)
                                                   - okx_ast_rec.percent_salvage_value);

                             Else
                               l_dummy_amount := null;
                               convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rel_chr_id,
                                         p_amount        => adj_txl_rec.corp_salvage_value,
                                         x_amount        => l_dummy_amount);

                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;

                               l_salvage_delta  := (l_dummy_amount - okx_ast_rec.salvage_value);
                             End If;

                           End If;
                           --Bug# 3548044 end

                           -- Bug# 3631094: start

                           --  Update of Asset cost
                           If okx_ast_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) Then

                             If ( nvl(l_rep_deal_type,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR AND
                                  okx_ast_rec.cost <> 0 ) Then

                               --Bug# 3872534
                               -- Adjust Asset COST and salvage value in
                               -- Reporting Book  to zero, if the product is
                               -- not a Multi-Gaap product

                               l_cost_delta := -1 * okx_ast_rec.cost;
                               l_asset_fin_rec_adj.cost := l_cost_delta;
                               l_adjust_yn := 'Y';
                               --Bug# 4627009
                               l_add_cap_fee:='N';
                               --Bug# 4627009 end

                             Elsif ( l_rep_deal_type = G_OP_LEASE_BK_CLASS AND
                                     l_Multi_GAAP_YN = 'Y' AND
                                     okx_ast_rec.cost = 0 ) Then

                               -- Adjust Asset cost in Reporting book to Asset
                               -- cost in  Corp book, if Reporting
                               -- product is OP Lease and Asset cost in
                               -- Reporting book is zero

                               l_cost_delta :=  l_asset_corp_book_cost;
                               l_asset_fin_rec_adj.cost := l_cost_delta;
                               l_adjust_yn := 'Y';

                             Elsif ( l_rep_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) AND
                                     l_Multi_GAAP_YN = 'Y' AND
                                     okx_ast_rec.cost <> 0 ) Then

                               --Bug# 3872534
                               -- Adjust Asset COST in Reporting book to zero
                               -- if Reporting product is DF/ST Lease

                               l_cost_delta := -1 * okx_ast_rec.cost;
                               l_asset_fin_rec_adj.cost := l_cost_delta;
                               l_adjust_yn := 'Y';
                               --Bug# 4627009
                               l_add_cap_fee:='N';
                               --Bug# 4627009 end

                             End If;

                           ElsIf ( l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) and
                                   l_tax_owner = 'LESSOR' and
                                   okx_ast_rec.book_class = 'CORPORATE') OR
                                 ( l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) and
                                   l_tax_owner = 'LESSEE' ) Then

                              --Bug# 3872534
                              -- Adjust Asset COST in Corp book to zero
                              -- if Local product is DF/ST Lease
                              -- Adjust Asset COST in Tax book to zero
                              -- if Local product is DF/ST Lease and Tax Owner
                              -- is Lessee

                              If  okx_ast_rec.cost <> 0 Then
                                l_cost_delta := -1 * okx_ast_rec.cost;
                                l_asset_fin_rec_adj.cost := l_cost_delta;
                                l_adjust_yn := 'Y';
                              End If;
                              --Bug# 4627009
                              l_add_cap_fee:='N';
                              --Bug# 4627009 end

                           End If;


                           --  Update of Asset Salvage Value
                           If okx_ast_rec.book_type_code = nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) Then

                             If ( nvl(l_rep_deal_type,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR) THEN

                                -- Adjust Asset cost and salvage value in
                                -- Reporting Book to zero, if the product
                                -- is not a Multi-Gaap product

                                --Bug# 3950089
                                If (okx_ast_rec.percent_salvage_value is not null) And
                                   (okx_ast_rec.percent_salvage_value <> 0) Then
                                  l_salvage_delta := -1 * okx_ast_rec.percent_salvage_value;
                                  l_asset_fin_rec_adj.percent_salvage_value := l_salvage_delta;
                                  l_adjust_yn := 'Y';

                                Elsif  (okx_ast_rec.salvage_value is not null) And
                                       (okx_ast_rec.salvage_value <> 0) Then
                                  l_salvage_delta := -1 * okx_ast_rec.salvage_value;
                                  l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                                  l_adjust_yn := 'Y';

                                Else
                                  l_salvage_delta := 0;
                                End if;

                             Elsif ( l_rep_deal_type = G_OP_LEASE_BK_CLASS AND
                                  l_Multi_GAAP_YN = 'Y' AND
                                  l_salvage_delta  <> 0 ) Then

                                  -- Adjust Salvage value in Reporting book
                                  -- to salvage value in Corp Book if
                                  -- Reporting product is OP Lease

                                  --Bug# 3950089
                                  If (okx_ast_rec.percent_salvage_value is not null) Then
                                    l_asset_fin_rec_adj.percent_salvage_value := l_salvage_delta;
                                  Else
                                    l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                                  End If;
                                  l_adjust_yn := 'Y';

                             Elsif ( l_rep_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS) AND
                                     l_Multi_GAAP_YN = 'Y' AND
                                     okx_ast_rec.salvage_value <> 0 ) Then

                               -- Adjust salvage value in Reporting book to zero
                               -- if Reporting product is DF/ST Lease

                               --Bug# 3950089
                               If (okx_ast_rec.percent_salvage_value is not null) And
                                  (okx_ast_rec.percent_salvage_value <> 0) Then
                                 l_salvage_delta := -1 * okx_ast_rec.percent_salvage_value;
                                 l_asset_fin_rec_adj.percent_salvage_value := l_salvage_delta;
                                 l_adjust_yn := 'Y';

                               Elsif (okx_ast_rec.salvage_value is not null) And
                                     (okx_ast_rec.salvage_value <> 0) Then

                                 l_salvage_delta := -1 * okx_ast_rec.salvage_value;
                                 l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                                 l_adjust_yn := 'Y';
                               End If;

                             Else
                               l_salvage_delta := 0;
                             End If;

                           Elsif ( l_deal_type = G_OP_LEASE_BK_CLASS AND
                                   okx_ast_rec.book_class = 'CORPORATE' AND
                                   l_salvage_delta <> 0 ) Then

                               -- Adjust Salvage value in Corp book to user
                               -- entered salvage value, if Local product
                               -- is OP Lease

                               --Bug# 3950089
                               If (okx_ast_rec.percent_salvage_value is not null) Then
                                 l_asset_fin_rec_adj.percent_salvage_value := l_salvage_delta;
                               Else
                                 l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                               End if;
                               l_adjust_yn := 'Y';

                           Elsif ((l_deal_type = G_OP_LEASE_BK_CLASS and okx_ast_rec.book_class = 'TAX') OR
                                  (l_deal_type in (G_DF_LEASE_BK_CLASS,G_ST_LEASE_BK_CLASS))
                                 ) Then

                                -- Adjust salvage value in Corp book to zero
                                -- if Local product is DF/ST Lease
                                -- Adjust salvage value in Tax book to zero
                                -- if Local product is OP Lease or DF/ST Lease

                                --Bug# 3950089
                                If (okx_ast_rec.percent_salvage_value is not null) And
                                   (okx_ast_rec.percent_salvage_value <> 0) Then
                                  l_salvage_delta := -1 * okx_ast_rec.percent_salvage_value;
                                  l_asset_fin_rec_adj.percent_salvage_value := l_salvage_delta;
                                  l_adjust_yn := 'Y';

                                Elsif (okx_ast_rec.salvage_value is not null) And
                                      (okx_ast_rec.salvage_value <> 0) Then

                                  l_salvage_delta := -1 * okx_ast_rec.salvage_value;
                                  l_asset_fin_rec_adj.salvage_value := l_salvage_delta;
                                  l_adjust_yn := 'Y';
                                Else
                                  l_salvage_delta := 0;
                                End If;

                           End If;
                           --Bug# 3631094: end
      ------------------------------------------------------------------
      -- Bug# 3533936 : Update of In-service date should not be allowed for a
      -- Re-lease contract.
      /*---------------------------------------------------------------

                           If  trunc(nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date)) <> trunc(okx_ast_rec.in_service_date) Then
                              l_asset_fin_rec_adj.date_placed_in_service := nvl(adj_txl_rec.in_service_date,okx_ast_rec.in_service_date);
                              l_adjust_yn := 'Y';
                           End If;
      -----------------------------------------------------------------------*/
      --Bug# 3533936 : End of commented code
      ------------------------------------------------------------------------

                           If  nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months) <> okx_ast_rec.life_in_months Then
                              l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                              l_asset_fin_rec_adj.life_in_months    := nvl(adj_txl_rec.life_in_months,okx_ast_rec.life_in_months);
                              l_asset_fin_rec_adj.basic_rate        := adj_txl_rec.deprn_rate;
                              l_asset_fin_rec_adj.adjusted_rate     := adj_txl_rec.deprn_rate;
                              l_adjust_yn := 'Y';
                           End If;

                           --category updates not supported by API
                           --If adj_txl_rec.depreciation_id <> okx_ast_rec.depreciation_category Then
                           If nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code) <> okx_ast_rec.deprn_method_code Then
                              l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                              --18-Jan-03 modified this
                             l_asset_fin_rec_adj.life_in_months    := adj_txl_rec.life_in_months;
                              l_asset_fin_rec_adj.basic_rate        := adj_txl_rec.deprn_rate;
                              l_asset_fin_rec_adj.adjusted_rate     := adj_txl_rec.deprn_rate;
                              l_adjust_yn := 'Y';
                           End If;

                           If nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate) <> okx_ast_rec.adjusted_rate Then
                              l_asset_fin_rec_adj.deprn_method_code := nvl(adj_txl_rec.deprn_method,okx_ast_rec.deprn_method_code);
                              l_asset_fin_rec_adj.life_in_months    := adj_txl_rec.life_in_months;
                              l_asset_fin_rec_adj.basic_rate        := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.basic_rate);
                              l_asset_fin_rec_adj.adjusted_rate     := nvl(adj_txl_rec.deprn_rate,okx_ast_rec.adjusted_rate);
                              l_adjust_yn := 'Y';
                          End If;

                          --Bug# 4627009
                          if ( l_add_cap_fee='Y') THEN
                               l_cost_delta := l_cost_delta + l_cap_fee_delta_converted_amt;
                               l_asset_fin_rec_adj.cost:=NVL(l_asset_fin_rec_adj.cost,0) + l_cap_fee_delta_converted_amt;
                               l_adjust_yn := 'Y';
                          end if;
                          --Bug# 4627009 end

                          If nvl(l_adjust_yn,'N') = 'Y' AND
                              l_deal_type not in (G_LOAN_BK_CLASS,G_REVOLVING_LOAN_BK_CLASS) then

                               --bug # 2942543 :
                               --check if salvage value is becoming more than asset cost
                               --BUG# 3548044: check for all the books (not only corporate book)
                               --If okx_ast_rec.book_class = 'CORPORATE' then --salvage value updates only for CORP

                               --Bug# 3950089
                               l_new_cost          := okx_ast_rec.cost + l_cost_delta;
                               If (okx_ast_rec.percent_salvage_value is not null) Then
                                 l_new_salvage_value := l_new_cost * (NVL(adj_txl_rec.pct_salvage_value,0)/100);
                               Else
                                 l_new_salvage_value := okx_ast_rec.salvage_value + l_salvage_delta;
                               End if;

                               If (l_new_cost < l_new_salvage_value) Then
                                   OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                       p_msg_name     => G_SALVAGE_VALUE
                                                      );
                                       RAISE OKL_API.G_EXCEPTION_ERROR;
                               End If;
                               --End If; --Bug# 3548044

                              --bug# 3156924 :
                              --Bug# 3533936 : Use contract start date as the
                              --               transaction date
                              -- l_release_date := adj_txl_rec.in_service_date;

                              l_release_date := l_start_date;
                              l_trans_number := adj_txl_rec.trans_number;
                              --bug# 3156924

                              --Bug# 4631549
                              --For re-lease contract move this validation upfront to
                              --OKL_CONTRACT_BOOK_PVT
                              --Bug# 4869443
                              -- No date validation required for Re-lease asset and Re-lease contract
                              /*If nvl(l_orig_system_source_code,OKL_API.G_MISS_CHAR) <> 'OKL_RELEASE' Then
                                  --Bug# 3783518
                                  -- Release contract start date should fall in the current
                                  -- open period in FA
                                  validate_release_date
                                      (p_api_version     => p_api_version,
                                       p_init_msg_list   => p_init_msg_list,
                                       x_return_status   => x_return_status,
                                       x_msg_count       => x_msg_count,
                                       x_msg_data        => x_msg_data,
                                       p_book_type_code  => okx_ast_rec.book_type_code,
                                       p_release_date    => l_release_date);

                                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                      RAISE OKL_API.G_EXCEPTION_ERROR;
                                  END IF;
                              End If;*/
                              --Bug# End 4631549

                              --Bug# 6373605 start
                              l_asset_fin_rec_adj.contract_id := p_rel_chr_id;
                              --Bug# 6373605 end
                              --call the adjustment api to do adjustment
                              FIXED_ASSET_ADJUST
                                 (p_api_version         => p_api_version,
                                  p_init_msg_list       => p_init_msg_list,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
         		                p_chr_id              => p_rel_chr_id,
                                  p_asset_id            => okx_ast_rec.asset_id,
                                  p_book_type_code      => okx_ast_rec.book_type_code,
                                  p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                                  -- Bug Fix# 2925461
                                  --p_adj_date            => adj_txl_rec.in_service_date,
                                  p_adj_date            => l_release_date,
                                  --Bug# 3156924
                                  p_trans_number        => l_trans_number,
                                  p_calling_interface   => l_calling_interface,
                                  -- Bug# 3156924
            --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
            p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
            p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
            p_sla_source_chr_id       => p_rel_chr_id,
            p_sla_source_kle_id       => adj_txl_rec.sla_source_kle_id,
            --Bug# 6373605--SLA populate sources
                                  --Bug# 4028371
                                  x_fa_trx_date       => l_fa_adj_date,
                                  x_asset_fin_rec_new   => l_asset_fin_rec_new);

                              --dbms_output.put_line('After fixed asset adjust for rebook :'||x_return_status);
                              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                              END IF;
                             --Bug# 4028371
                              If adj_txl_rec.tal_id is not null Then
                                  --update the fa trx date on transaction line
                                      l_talv_date_rec.id     := adj_txl_rec.tal_id;
                                      l_talv_date_rec.fa_trx_date := l_fa_adj_date;

                                      okl_tal_pvt.update_row
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_talv_rec      => l_talv_date_rec,
                                         x_talv_rec      => lx_talv_date_rec);
                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;
                             End If;
                             --End Bug# 4028371
                        Else
                             --------------------
                             --Bug# 6373605 start
                             --------------------
                             --Even if nothing is being adjusted in FA
                             --make a dummy transaction to update the
                             --contract_id as assets are moving from
                             -- off-lease or old contract to new contract

                             l_dummy_asset_fin_rec_adj.contract_id := p_rel_chr_id;
                             --call the adjustment api to do adjustment
                              FIXED_ASSET_ADJUST
                                 (p_api_version         => p_api_version,
                                  p_init_msg_list       => p_init_msg_list,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
                                  p_chr_id              => p_rel_chr_id,
                                  p_asset_id            => okx_ast_rec.asset_id,
                                  p_book_type_code      => okx_ast_rec.book_type_code,
                                  p_asset_fin_rec_adj   => l_dummy_asset_fin_rec_adj,
                                  p_adj_date            => l_release_date,
                                  p_trans_number        => l_trans_number,
                                  p_calling_interface   => l_calling_interface,
                                  --Bug# 6373605--SLA populate source
                                  p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
                                  p_sla_source_header_table => 'OKL_TRX_ASSETS',
                                  p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
                                  p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
                                  p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
                                  p_sla_source_chr_id       => p_rel_chr_id,
                                  p_sla_source_kle_id       => adj_txl_rec.sla_source_kle_id,
                                 --Bug# 6373605--SLA populate sources
                                  x_fa_trx_date       => l_fa_adj_date,
                                  x_asset_fin_rec_new   => l_asset_fin_rec_new);

                             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                              END IF;

                             If adj_txl_rec.tal_id is not null then
                                 --update th fa trx date on transaction line
                                 l_talv_date_rec.id      := adj_txl_rec.tal_id;

                                  --Bug# 6373605 : Commented as we have
                                  --actual FA transaction noe and do not
                                  --need to derive date
                                 /*okl_accounting_util.get_fa_trx_date
                                  (p_book_type_code  =>  okx_ast_rec.book_type_code,
                                   x_return_status   =>  x_return_status,
                                   x_fa_trx_date     =>  l_fa_adj_date);

                                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_ERROR;
                                 END IF;

                                 l_talv_date_rec.fa_trx_date := l_fa_adj_date;*/
                                 l_talv_date_rec.fa_trx_date := l_fa_adj_date;
                                 -----------
                                 --Bug# 6373605 end
                                 -------------

                                 okl_tal_pvt.update_row
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_talv_rec      => l_talv_date_rec,
                                         x_talv_rec      => lx_talv_date_rec);
                                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_ERROR;
                                 END IF;
                              End If; --adj_txl_rec.tal_id is not null
                          End If; --l_adjust_yn = 'Y'


                           -- Bug# 3533936
                           IF  adj_txl_rec.fa_location_id is not null THEN
                             FIXED_ASSET_TRANSFER
                               (p_api_version       => p_api_version,
                                p_init_msg_list     => p_init_msg_list,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                p_asset_id          => okx_ast_rec.asset_id,
                                p_book_type_code    => okx_ast_rec.book_type_code,
                                p_location_id       => adj_txl_rec.fa_location_id,
                                p_trx_date          => l_release_date,
                                p_trx_number        => l_trans_number,
                                p_calling_interface => l_calling_interface,
            --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => adj_txl_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => adj_txl_rec.sla_source_try_id,
            p_sla_source_line_id      => adj_txl_rec.sla_source_line_id,
            p_sla_source_line_table   => adj_txl_rec.sla_source_line_table,
            p_sla_source_chr_id       => p_rel_chr_id,
            p_sla_source_kle_id       => adj_txl_rec.sla_source_kle_id,
            --Bug# 6373605--SLA populate sources
                                --Bug# 4028371
                                x_fa_trx_date       => l_fa_tsfr_date
                               );

                             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                             END IF;
                           END IF;
                       End If;

                -- Bug# 3631094
                --End If; -- do not do explicit changes for multi-gaap reporting book

                -- Bug 3631094 : Setting transaction status to processed is moved
                --               to the end of Release_asset procedure.
                /*--Bug# 3533936 : set the status of transaction to processed
                If adj_txl_rec.tas_id is not NULL then

                    update_trx_status(p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_tas_id        => adj_txl_rec.tas_id,
                                      p_tsu_code      => G_TSU_CODE_PROCESSED);

                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                End If;
                --End Bug# 3533936*/

                End If; --adj_txl_rec found
            End Loop;
            Close adj_txl_csr;
          End If; --k hdr csr
        CLOSE k_hdr_csr;

        ---------------------------------------------------------------
        --Bug# 3143522 : Adjust subsidy adjustments into asset cost
        ---------------------------------------------------------------
        open l_allast_csr(p_chr_id  => p_rel_chr_id);
        loop
            fetch l_allast_csr into l_asset_cle_id,l_orig_system_id1;
            exit when l_allast_csr%NOTFOUND;
            l_subsidy_exists := OKL_API.G_FALSE;
            okl_subsidy_process_pvt.is_asset_subsidized
                          (p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_asset_cle_id  => l_asset_cle_id,
                          x_subsidized    => l_subsidy_exists);
            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;


            If l_subsidy_exists = OKL_API.G_TRUE then

                --get total discount for original asset
                OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_formula_name  => G_FORMULA_LINE_DISCOUNT,
                                                p_contract_id   => l_rel_chr_id,
                                                p_line_id       => l_asset_cle_id,
                                                x_value         => l_total_discount);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                --Bug# 3621663 : Fix for Multi-Currency
                l_dummy_amount := null;
                convert_2functional_currency(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_chr_id        => p_rel_chr_id,
                                         p_amount        => l_total_discount,
                                         x_amount        => l_dummy_amount);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_total_discount := l_dummy_amount;
                --Bug# 3621663 : Fix for Multi-Currency

                If (l_total_discount <> 0) then
                    l_cost_adjustment := (-1)* l_total_discount;
                    --open cursor to get asset details
                    open l_Asset_csr(p_asset_cle_id => l_asset_cle_id);
                    Loop
                        Fetch l_asset_csr into l_asset_rec;
                        Exit when l_asset_csr%NOTFOUND;

                        -- Bug# 3783518
                        -- Do not make adjustment for subsidy for the Reporting
                        -- Book for cases where the asset is added to the
                        -- Reporting Book on Re-lease. The subsidy adjustment
                        -- is done by the call to Fixed_Asset_Add

                        If l_asset_rec.book_type_code =
                          nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) Then

                          open orig_pdt_csr(l_orig_system_id1);
                          fetch orig_pdt_csr into l_orig_reporting_pdt_id;
                          close orig_pdt_csr;

                        End If;

                        If (l_asset_rec.book_type_code =
                            nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR)
                           AND l_orig_reporting_pdt_id is null) Then

                          NULL;

                        Else

                        --Bug# 3872534: Replace NBV checks with cost checks
                        If (l_asset_rec.asset_cost <> 0) then
                            If ((l_asset_rec.asset_cost + l_cost_adjustment) <= 0) then
                                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                           p_msg_name     => G_SUBSIDY_ADJ_COST_ERROR,
                                           p_token1       => G_ASSET_NUMBER_TOKEN,
                                           p_token1_value => l_asset_rec.asset_number,
                                           p_token2       => G_BOOK_TYPE_TOKEN,
                                           p_token2_value => l_asset_rec.book_type_code,
                                           p_token3       => G_ASSET_NUMBER_TOKEN,
                                           p_token3_value => l_asset_rec.asset_number);
                                x_return_status := OKL_API.G_RET_STS_ERROR;
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                             Elsif ((l_asset_rec.asset_cost + l_cost_adjustment) > 0) then

                                --Bug# 3156924
                                l_trans_number := l_asset_rec.trans_number;

                                --Bug# 3533936 : Use contract start date as the
                                --               transaction date
                                -- l_release_date := l_asset_rec.in_service_date;
                                l_release_date := l_start_date;
                                --bug# 3156924

                                --call api to adjust FA cost-amortize adjustment

                                -- Bug# 3783518
                                -- Release contract start date should fall in the current
                                -- open period in FA
                                --Bug# 4869443
                                -- No date validation required for Re-lease asset and Re-lease contract
                                /*
                                validate_release_date
                                  (p_api_version     => p_api_version,
                                   p_init_msg_list   => p_init_msg_list,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data,
                                   p_book_type_code  => l_asset_rec.book_type_code,
                                   p_release_date    => l_release_date);

                                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                  RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;
                                */

                                l_subsidy_asset_fin_rec_adj.cost := l_cost_adjustment;
                                --Bug# 6373605 start
                                If l_asset_rec.book_class = 'CORPORATE' then
                                   l_sla_source_line_id :=
l_asset_rec.sla_source_line_id;
                                   l_sla_source_line_table :=
'OKL_TXL_ASSETS_B';
                                Elsif l_asset_rec.book_class = 'TAX' then
                                    Open l_txd_from_book_type_csr(p_book_type_code =>
l_asset_rec.book_type_code,
                                                             p_tal_id =>
l_asset_rec.sla_source_line_id);
                                    Fetch l_txd_from_book_type_csr into
l_txd_from_book_type_rec;
                                    If l_txd_from_book_type_csr%NOTFOUND then
                                        l_sla_source_line_id :=
l_asset_rec.sla_source_line_id;
                                        l_sla_source_line_table :=
'OKL_TXL_ASSETS_B';
                                    Else
                                        l_sla_source_line_id :=
l_txd_from_book_type_rec.sla_source_line_id;
                                        l_sla_source_line_table :=
'OKL_TXD_ASSETS_B';
                                    End If;
                                    Close l_txd_from_book_type_Csr;
                               End If;

                               l_asset_fin_rec_adj.contract_id := p_rel_chr_id;
                               --bug# 6373605 End;

                                FIXED_ASSET_ADJUST
                                             (p_api_version       => p_api_version,
                                              p_init_msg_list     => p_init_msg_list,
                                              x_return_status     => x_return_status,
                                              x_msg_count         => x_msg_count,
                                              x_msg_data          => x_msg_data,
                                              p_chr_id            => l_rel_chr_id,
                                              p_asset_id          => l_asset_rec.asset_id,
                                              p_book_type_code    => l_asset_rec.book_type_code,
                                              p_asset_fin_rec_adj => l_subsidy_asset_fin_rec_adj,
                                              p_adj_date          => l_release_date,
                                              p_trans_number      => l_trans_number,
                                              p_calling_interface   => l_calling_interface,
           --Bug# 6373605--SLA populate source
            p_sla_source_header_id    => l_asset_rec.sla_source_header_id,
            p_sla_source_header_table => 'OKL_TRX_ASSETS',
            p_sla_source_try_id       => l_Asset_rec.sla_source_try_id,
            p_sla_source_line_id      => l_sla_source_line_id,
            p_sla_source_line_table   => l_sla_source_line_table,
            p_sla_source_chr_id       => p_rel_chr_id,
            p_sla_source_kle_id       => l_asset_rec.sla_source_kle_id,
            --Bug# 6373605--SLA populate sources
                                              --Bug# 4028371
                                              x_fa_trx_date       => l_fa_adj_date,
                                              x_asset_fin_rec_new => l_asset_fin_rec_new);

                                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                     RAISE OKL_API.G_EXCEPTION_ERROR;
                                 END IF;

                             End If;
                        End If;
                      End If;
                    End Loop;
                    Close l_asset_csr;
               End If;
           End If; --if l_subsidy_exist = TRUE
       End Loop;
       Close l_allast_csr;
       ----------------------------------------------------------------
       --Bug# 3143522 : 11.5.10 End processing for subsidies
       ----------------------------------------------------------------

       --Bug 3631094: start
       --Bug# 3533936 : set the status of transaction to processed
       FOR tas_rec in tas_csr(p_chr_id => p_rel_chr_id) LOOP

         update_trx_status(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_tas_id        => tas_rec.id,
                           p_tsu_code      => G_TSU_CODE_PROCESSED);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       END LOOP;
       --End Bug# 3533936
       --Bug 3631094: end

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;

    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;

    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If ( l_hdr_csr%ISOPEN ) Then
       CLOSE l_hdr_csr;
    End If;

    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END RELEASE_ASSET;

  --Bug# 3621875: fetching depreciaion parameters for pricing
   ---------------------------------------------------------------------
  --Bug# 3621875: pricing parameters
  --------------------------------------------------------------------
  Procedure Get_pricing_Parameters ( p_api_version   IN  NUMBER,
                                     p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER,
                                     x_msg_data      OUT NOCOPY VARCHAR2,
                                     p_chr_id        IN  NUMBER,
                                     p_cle_id        IN  NUMBER,
                                     x_ast_dtl_tbl   OUT NOCOPY ast_dtl_tbl_type) is

  l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT varchar2(30) := 'GET_PRICING_PARAMS';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to get transaction going on on this asset
  cursor l_curr_trx_csr(p_chr_id in number,
                        p_cle_id in number) is
  select ttyt.name      transaction_type,
         trx.tas_type,
         txl.tal_type,
         txl.id         tal_id,
         trx.creation_date
  from   okl_trx_types_tl         ttyt,
         okl_trx_assets           trx,
         okl_txl_assets_b         txl,
         okc_k_lines_b            cleb,
         okc_line_styles_b        lseb
  where  ttyt.id            = trx.try_id
  and    ttyt.language      = 'US'
  and    trx.id             = txl.tas_id
  and    trx.tsu_code       = 'ENTERED'
  and    txl.kle_id         = cleb.id
  and    cleb.cle_id        = p_cle_id
  and    cleb.dnz_chr_id    = p_chr_id
  and    cleb.lse_id        = lseb.id
  and    lseb.lty_code      = 'FIXED_ASSET'
  order by trx.creation_date desc;

  l_curr_trx_rec l_curr_trx_csr%ROWTYPE;

  --cursor to check if the contract is selected for Mass Rebook
  CURSOR  l_chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
  SELECT 'Y'
  FROM   okc_k_headers_b CHR,
         okl_trx_contracts ktrx
  where  CHR.ID          = p_chr_id
  AND    ktrx.KHR_ID     =  chr.id
  AND    ktrx.tsu_code   = 'ENTERED'
  AND    ktrx.rbr_code   IS NOT NULL
  AND    ktrx.tcn_type   = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP Proect
  AND    ktrx.representation_type = 'PRIMARY'
--
  AND   EXISTS (SELECT '1'
              FROM   okl_rbk_selected_contract rbk_khr
              WHERE  rbk_khr.KHR_ID = chr.id
              AND    rbk_khr.STATUS <> 'PROCESSED');

  l_mass_rbk_yn varchar2(1);


  --cursor to get all the data from fa in case of mass rebook
  -- and no transaction
  cursor l_fa_csr2 (p_cle_id in number,
                    p_chr_id in number) is
  select fab.*,
         fa.asset_category_id,
         fbc.book_class,
         fa.asset_number
  from   fa_additions      fa,
         fa_books          fab,
         fa_book_controls  fbc,
         okc_k_items       cim,
         okc_k_lines_b     cleb,
         okc_line_styles_b lseb
  where  fab.asset_id             = fa.asset_id
  and    fab.transaction_header_id_out is null
  and    fbc.book_type_code       =  fab.book_type_code
  and    fa.asset_id              =  cim.object1_id1
  and    cim.object1_id2          = '#'
  and    cim.jtot_object1_code    = 'OKX_ASSET'
  and    cim.cle_id               = cleb.id
  and    cim.dnz_chr_id           = cleb.dnz_chr_id
  and    cleb.cle_id              = p_cle_id
  and    cleb.lse_id              = lseb.id
  and    cleb.dnz_chr_id          = p_chr_id
  and    lseb.lty_code            = 'FIXED_ASSET';

  l_fa_rec2 l_fa_csr2%ROWTYPE;


  --cursor to get contract header details
  cursor l_chr_csr (p_chr_id in number) is
  select khr.pdt_id,
         khr.deal_type,
         chrb.start_date,
         rul.rule_information1
  from   okc_rules_b       rul,
         okc_rule_groups_b rgp,
         okl_k_headers     khr,
         okc_k_headers_b   chrb
  where  rul.rule_information_category       = 'LATOWN'
  and    rul.rgp_id                          = rgp.id
  and    rul.dnz_chr_id                      = rgp.dnz_chr_id
  and    rgp.dnz_chr_id                      = chrb.id
  and    rgp.chr_id                          = chrb.id
  and    rgp.rgd_code                        = 'LATOWN'
  and    khr.id                              = chrb.id
  and    chrb.id                             = p_chr_id;

  l_pdt_id               number;
  l_start_date           date;
  l_rep_pdt_id           number;
  l_tax_owner            okc_rules_b.rule_information_category%TYPE;
  l_deal_type            okl_k_headers.deal_type%TYPE;
  l_rep_deal_type        okl_k_headers.deal_type%TYPE;
  l_Multi_GAAP_YN        varchar2(1);
  l_adjust_asset_to_zero varchar2(1);
  l_multi_gaap_book_done varchar2(1);



  --cursor to get asset details for contract undergoing booking :
  cursor l_booking_corp_csr (p_tal_id in number) is
  select txl.asset_number,
         txl.corporate_book,
         fbc.book_class,
         txl.deprn_method,
         txl.in_service_date,
         txl.life_in_months,
         txl.deprn_rate,
         txl.salvage_value,
         txl.percent_salvage_value,
         fcbd.prorate_convention_code,
         txl.depreciation_cost,
         txl.depreciation_id,
         txl.kle_id
   from  okl_txl_Assets_b txl,
         fa_book_controls fbc,
         fa_category_book_defaults fcbd
   where fcbd.category_id          = txl.depreciation_id
   and   fcbd.book_type_code       = txl.corporate_book
   and   txl.in_service_date between fcbd.start_dpis and nvl(fcbd.end_dpis,txl.in_service_date)
   and   fbc.book_type_code        = txl.corporate_book
   and   txl.id                    = p_tal_id;

   l_booking_corp_rec     l_booking_corp_csr%ROWTYPE;

  --cursor to get asset details for contract undergoing mass rebook :
  cursor l_mass_rebook_corp_csr (p_tal_id in number) is
  select txl.asset_number,
         txl.corporate_book,
         fbc.book_class,
         txl.deprn_method,
         txl.in_service_date,
         txl.life_in_months,
         txl.deprn_rate,
         txl.salvage_value,
         txl.percent_salvage_value,
         fcbd.prorate_convention_code,
         txl.depreciation_cost,
         txl.depreciation_id,
         txl.kle_id
   from  okl_txl_Assets_b txl,
         fa_book_controls fbc,
         fa_category_book_defaults fcbd,
         fa_additions fa
   where fcbd.category_id          = fa.asset_category_id
   and   fcbd.book_type_code       = txl.corporate_book
   and   fa.asset_number           = txl.asset_number
   and   txl.in_service_date between fcbd.start_dpis and nvl(fcbd.end_dpis,txl.in_service_date)
   and   fbc.book_type_code        = txl.corporate_book
   and   txl.id                    = p_tal_id;

   l_mass_rebook_corp_rec l_mass_rebook_corp_csr%ROWTYPE;

   cursor l_booking_tax_csr (p_tal_id in number,
                             p_category_id in number,
                             p_in_service_date date) is
   select txd.tax_book,
          fbc.book_class,
          txd.deprn_method_tax,
          txd.life_in_months_tax,
          txd.deprn_rate_tax,
          fcbd.prorate_convention_code,
          txd.cost
   from   okl_txd_Assets_b          txd,
          fa_book_controls          fbc,
          fa_category_book_defaults fcbd
   where  fcbd.category_id          = p_category_id
   and    fcbd.book_type_code       = txd.tax_book
   and    p_in_service_date  between fcbd.start_dpis and nvl(fcbd.end_dpis,p_in_service_date)
   and    fbc.book_type_code        = txd.tax_book
   and    txd.tal_id                = p_tal_id;


   l_booking_tax_rec     l_booking_tax_csr%ROWTYPE;

  cursor l_mass_rebook_tax_csr (p_tal_id in number,
                                p_category_id in number,
                                p_in_service_date date,
                                p_book in varchar2    ) is
   select txd.tax_book,
          fbc.book_class,
          txd.deprn_method_tax,
          txd.life_in_months_tax,
          txd.deprn_rate_tax,
          fcbd.prorate_convention_code,
          txd.cost
   from   okl_txd_Assets_b          txd,
          fa_book_controls          fbc,
          fa_category_book_defaults fcbd
   where  fcbd.category_id          = p_category_id
   and    fcbd.book_type_code       = txd.tax_book
   and    p_in_service_date  between fcbd.start_dpis and nvl(fcbd.end_dpis,p_in_service_date)
   and    fbc.book_type_code        = txd.tax_book
   and    txd.tal_id                = p_tal_id
   and    txd.tax_book              = p_book;

   l_mass_rebook_tax_rec l_mass_rebook_tax_csr%ROWTYPE;


  --cursor to get method id
  cursor l_method_csr1 (p_method_code in varchar2,
                        p_life        in number) is
  select fm.method_id
  from   fa_methods fm
  where  fm.method_code = p_method_code
  and    fm.life_in_months = p_life
  and    fm.life_in_months is not null;

  cursor l_method_csr2 (p_method_code in varchar2,
                        p_basic_rate  in number,
                        p_adj_rate    in number) is
  select fm.method_id
  from   fa_methods fm
  where  fm.method_code   = p_method_code
  and    fm.life_in_months is null
  and    exists (select 1
                 from   fa_flat_rates ffr
                 where  ffr.method_id     = fm.method_id
                 and    ffr.basic_rate    = p_basic_rate
                 and    ffr.adjusted_rate = p_adj_rate);

  l_method_id    fa_methods.method_id%TYPE;

  l_rep_pdt_book fa_books.book_type_code%TYPE;


  --cursor to get defaults for multi-GAAP book
  cursor l_defaults_csr (p_book           in varchar2,
                         p_category_id    in number,
                         p_date           in date) is
  select deprn_method,
         life_in_months,
         basic_rate,
         adjusted_rate,
         prorate_convention_code
  from   fa_category_book_defaults
  where  book_type_code      = p_book
  and    category_id         = p_category_id
  and    p_date between start_dpis and nvl(end_dpis,p_date);


  l_defaults_rec      l_defaults_csr%ROWTYPE;
  i                   number;

  --Cursor to get values from FA
  Cursor l_fa_csr (p_asset_number in varchar2,
                   p_book         in varchar2) is
  select fab.*,
         fa.asset_category_id
  from   fa_books      fab,
         fa_additions  fa
  where  fab.book_type_code    = p_book
  and    fab.asset_id          = fa.asset_id
  and    fa.asset_number       = p_asset_number
  and    fab.transaction_header_id_out is null;

  l_fa_rec  l_fa_csr%ROWTYPE;

  l_cap_fee_delta number;
  l_ast_trx_not_found varchar2(1);

  --Bug# 4775166
  Cursor l_clev_csr(p_cle_id in number) is
  select name
  from okc_k_lines_v
  where id = p_cle_id;

  l_clev_rec l_clev_csr%rowtype;

  -- Bug# 5150150 - start
  -- cursor to get expected asset cost
  cursor l_exp_asset_cost_csr (p_cle_id in number) is
  select id,EXPECTED_ASSET_COST
  from okl_k_lines_v
  where id = p_cle_id;

  -- cursor to get ORIG_SYSTEM_SOURCE_CODE of the contract

  cursor l_orig_sys_src_code_csr (p_chr_id in number) is
  select id, ORIG_SYSTEM_SOURCE_CODE
  from okc_k_headers_b
  where id = p_chr_id;

  l_chr_id okc_k_headers_b.id%type;
  l_orig_system_source_code okc_k_headers_b.orig_system_source_code%type;
  l_cle_id okl_k_lines_v.id%type;
  l_exp_asset_cost okl_k_lines_v.expected_asset_cost%type;

  --cursor to get Cap fees added during Re-lease for the asset
  Cursor cap_fee_csr(p_fin_ast_cle_id   in number
                    ,p_chr_id           in number) IS
  Select nvl(sum(cov_ast_kle.capital_amount),0) capitalized_fee
  From
       OKL_K_LINES       fee_kle,
       OKC_K_LINES_B     fee_cle,
       OKC_STATUSES_B    fee_sts,
       OKL_K_LINES       cov_ast_kle,
       OKC_K_LINES_B     cov_ast_cle,
       OKC_STATUSES_B    cov_ast_sts,
       OKC_K_ITEMS       cov_ast_cim
  Where  fee_kle.id                    = fee_cle.id
  and    fee_kle.fee_type              = 'CAPITALIZED'
  and    fee_cle.dnz_chr_id            = p_chr_id
  and    fee_cle.chr_id                = p_chr_id
  and    fee_cle.lse_id                = 52 -- FEE
  and    fee_cle.sts_code              = fee_sts.code
  and    fee_sts.ste_code not in         ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
  and    fee_cle.id                    = cov_ast_cle.cle_id
  and    fee_cle.dnz_chr_id            = cov_ast_cle.dnz_chr_id
  and    cov_ast_kle.id                = cov_ast_cle.id
  and    cov_ast_cle.id                = cov_ast_cim.cle_id
  and    cov_ast_cle.lse_id            = 53 --LINK_FEE_ASSET
  and    cov_ast_cle.sts_code          = cov_ast_sts.code
  and    cov_ast_sts.ste_code not in    ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
  and    cov_ast_cle.dnz_chr_id        = cov_ast_cim.dnz_chr_id
  and    cov_ast_cim.object1_id1       = to_char(p_fin_ast_cle_id)
  and    cov_ast_cim.object1_id2       = '#'
  and    cov_ast_cim.jtot_object1_code = 'OKX_COVASST';

  l_new_cap_fee NUMBER;
  -- Bug# 5150150 - End

  begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY (
                                l_api_name
                                ,p_init_msg_list
                                ,'_PVT'
                                ,x_return_status);
     -- Check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -------------------------------------------------
     --1. Find out details of the current transactions
     -------------------------------------------------
     open l_curr_trx_csr (p_chr_id  =>  p_chr_id,
                          p_cle_id  =>  p_cle_id) ;
     fetch l_curr_trx_csr into l_curr_trx_rec;
     If l_curr_trx_csr%NOTFOUND then
         --Raise error
         l_ast_trx_not_found := 'Y';
     else
         l_ast_trx_not_found := 'N';
     end if;
     close l_curr_trx_csr;

     If l_ast_trx_not_found = 'Y' then
             i := 0;
             open l_fa_csr2(p_chr_id => p_chr_id,
                            p_cle_id => p_cle_id);
             loop
                 fetch  l_fa_csr2 into l_fa_rec2;
                 exit when l_fa_csr2%NOTFOUND;
                 i := i + 1;
                 x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_fa_rec2.asset_number;
                 x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_fa_rec2.book_type_code;
                 x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_fa_rec2.book_class;
                 x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_fa_rec2.deprn_method_code;
                 x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_fa_rec2.date_placed_in_service;
                 x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_fa_rec2.life_in_months;
                 x_ast_dtl_tbl(i).BASIC_RATE              :=  l_fa_rec2.basic_rate;
                 x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_fa_rec2.adjusted_rate;
                 x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_fa_rec2.salvage_value;
                 x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_fa_rec2.percent_salvage_value;
                 x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec2.prorate_convention_code;
                 x_ast_dtl_tbl(i).COST                    :=  l_fa_rec2.cost;
                  --get method id
                 l_method_id := null;
                 If nvl(l_fa_rec2.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                     open l_method_csr1(p_method_code => l_fa_rec2.deprn_method_code,
                                        p_life        => l_fa_rec2.life_in_months);
                     fetch l_method_csr1 into l_method_id;
                     if l_method_csr1%NOTFOUND then
                         null;
                     end if;
                     close l_method_csr1;
                 ElsIf nvl(l_fa_rec2.adjusted_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                     open l_method_csr2(p_method_code   => l_fa_rec2.deprn_method_code,
                                        p_basic_rate    => l_fa_rec2.basic_rate,
                                        p_adj_rate      => l_fa_rec2.adjusted_rate);
                     fetch l_method_csr2 into l_method_id;
                     --Bug# 4775166
                     if l_method_csr2%NOTFOUND then
                         null;
                     end if;
                     close l_method_csr2;
                 End If;
                 x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;

             end loop;
             --Bug# 4775166
             close l_fa_csr2;
     End If;

     If l_ast_trx_not_found = 'N' then
     --cursor to get contract detials :
     open l_chr_csr (p_chr_id => p_chr_id);
     fetch l_chr_csr into l_pdt_id,
                          l_deal_type,
                          l_start_date,
                          l_tax_owner;
     If l_chr_csr%NOTFOUND then
         --Raise Error : contract header details not found
         null;
     End If;
     close l_chr_csr;

     -- Multi-GAAP Begin
     Get_Pdt_Params (p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_pdt_id        => l_pdt_id,
                     p_pdt_date      => l_start_date,
                     x_rep_pdt_id    => l_rep_pdt_id,
                     x_tax_owner     => l_tax_owner,
                     x_rep_deal_type => l_rep_deal_type);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     l_Multi_GAAP_YN := 'N';
     l_adjust_asset_to_zero := 'N';
     --checks wheter Multi-GAAP processing needs tobe done
     If l_rep_pdt_id is not NULL Then

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

        l_Multi_GAAP_YN := 'Y';
/*
        If l_deal_type = 'LEASEOP' and
        nvl(l_rep_deal_type,'X') = 'LEASEOP' and
        nvl(l_tax_owner,'X') = 'LESSOR' Then
            l_Multi_GAAP_YN := 'Y';
        End If;

        If l_deal_type in ('LEASEDF','LEASEST') and
        nvl(l_rep_deal_type,'X') = 'LEASEOP' and
        nvl(l_tax_owner,'X') = 'LESSOR' Then
            l_Multi_GAAP_YN := 'Y';
        End If;

        If l_deal_type in ('LEASEDF','LEASEST') and
        nvl(l_rep_deal_type,'X') = 'LEASEOP' and
        nvl(l_tax_owner,'X') = 'LESSEE' Then
            l_Multi_GAAP_YN := 'Y';
        End If;

        If l_deal_type = 'LOAN' and
        nvl(l_rep_deal_type,'X') = 'LEASEOP' and
        nvl(l_tax_owner,'X') = 'LESSEE' Then
            l_Multi_GAAP_YN := 'Y';
        End If;
*/
      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

        If l_deal_type = 'LEASEOP' and
        nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
        nvl(l_tax_owner,'X') = 'LESSOR' Then
            --l_Multi_GAAP_YN := 'Y';
            l_adjust_asset_to_zero := 'Y';
        End If;

        If l_deal_type in ('LEASEDF','LEASEST') and
        nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
        nvl(l_tax_owner,'X') = 'LESSOR' Then
            --l_Multi_GAAP_YN := 'Y';
            l_adjust_asset_to_zero := 'Y';
        End If;

       If l_deal_type in ('LEASEDF','LEASEST') and
        nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
        nvl(l_tax_owner,'X') = 'LESSEE' Then
            --l_Multi_GAAP_YN := 'Y';
            l_adjust_asset_to_zero := 'Y';
        End If;
     End If;

     If l_Multi_GAAP_YN = 'Y' Then
         --get reporting product book type
         l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
     End If;

     If (l_curr_trx_rec.transaction_type) = 'Internal Asset Creation' then
         --1. Booking and Online rebook new asset addition
         If (l_curr_trx_rec.tas_type = 'CFA') and (l_curr_trx_rec.tal_type = 'CFA') then
             open l_booking_corp_csr(p_tal_id => l_curr_trx_rec.tal_id);
             Fetch l_booking_corp_csr into l_booking_corp_rec;
             If l_booking_corp_csr%NOTFOUND then
               --Bug# 4775166
               close l_booking_corp_csr;
               open l_clev_csr(p_cle_id => p_cle_id);
               fetch l_clev_csr into l_clev_rec;
               close l_clev_csr;

               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_LA_NO_CORP_BOOK_DFLTS',
                                   p_token1       => 'ASSET_NUMBER',
                                   p_token1_value => l_clev_rec.name
				           );
               Raise OKL_API.G_EXCEPTION_ERROR;
               --Bug# 4775166
             End If;
             close l_booking_corp_csr;

             l_method_id := null;
             If nvl(l_booking_corp_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr1(p_method_code => l_booking_corp_rec.deprn_method,
                                    p_life        => l_booking_corp_rec.life_in_months);
                 fetch l_method_csr1 into l_method_id;
                 if l_method_csr1%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr1;
              ElsIf nvl(l_booking_corp_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr2(p_method_code   => l_booking_corp_rec.deprn_method,
                                    p_basic_rate    => l_booking_corp_rec.deprn_rate,
                                    p_adj_rate      => l_booking_corp_rec.deprn_rate);
                 fetch l_method_csr2 into l_method_id;
                 --Bug# 4775166
                 if l_method_csr2%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr2;
              End If;

              i := 1;
              x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
              x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_corp_rec.corporate_book;
              x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_corp_rec.book_class;
              x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_corp_rec.deprn_method;
              x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
              x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
              x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_corp_rec.life_in_months;
              x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
              x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_corp_rec.deprn_rate;
              x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
              x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
              x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_booking_corp_rec.prorate_convention_code;

              If l_deal_type in ('LEASEDF','LEASEST','LOAN') then
                  x_ast_dtl_tbl(i).cost                  := 0;
                  x_ast_dtl_tbl(i).salvage_value         := 0;
                  x_ast_dtl_tbl(i).percent_salvage_value := null;
              Else

                  Calc_Deprn_Cost ( p_api_version      => p_api_version,
                                    p_init_msg_list    => p_init_msg_list,
                                    x_msg_count        => x_msg_count,
                                    x_msg_data         => x_msg_data,
                                    x_return_status    => x_return_status,
                                    p_entered_deprn    => l_booking_corp_rec.depreciation_cost,
                                    p_fa_cle_id        => l_booking_corp_rec.kle_id,
                                    x_calculated_deprn => x_ast_dtl_tbl(i).cost);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
              End If;

              --process tax_books
              l_multi_gaap_book_done := 'N';
              open l_booking_tax_csr(p_tal_id          => l_curr_trx_rec.tal_id,
                                     p_category_id     => l_booking_corp_rec.depreciation_id,
                                     p_in_service_date => l_booking_corp_rec.in_service_date);
              loop
                  fetch l_booking_tax_csr into l_booking_tax_rec;
                  Exit when l_booking_tax_csr%NOTFOUND;
                  i := i + 1;

                  --get deprn method
                  l_method_id := null;
                  If nvl(l_booking_tax_rec.life_in_months_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr1(p_method_code => l_booking_tax_rec.deprn_method_tax,
                                         p_life        => l_booking_tax_rec.life_in_months_tax);
                      fetch l_method_csr1 into l_method_id;
                      if l_method_csr1%NOTFOUND then
                          null;
                      end if;
                      close l_method_csr1;
                  ElsIf nvl(l_booking_tax_rec.deprn_rate_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr2(p_method_code   => l_booking_tax_rec.deprn_method_tax,
                                         p_basic_rate    => l_booking_tax_rec.deprn_rate_tax,
                                         p_adj_rate      => l_booking_tax_rec.deprn_rate_tax);
                      fetch l_method_csr2 into l_method_id;
                      --Bug# 4775166
                      if l_method_csr2%NOTFOUND then
                           null;
                      end if;
                      close l_method_csr2;
                  End If;

                  x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
                  x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_tax_rec.tax_book;
                  x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_tax_rec.book_class;
                  x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_tax_rec.deprn_method_tax;
                  x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
                  x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
                  x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_tax_rec.life_in_months_tax;
                  x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
                  x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_tax_rec.deprn_rate_tax;
                  If nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR and
                     l_multi_gaap_yn = 'Y' and
                     l_rep_pdt_book = l_booking_tax_rec.tax_book then
                     x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
                     x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
                     l_multi_gaap_book_done                   :=  'Y';
                  end if;
                  x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_booking_tax_rec.prorate_convention_code;

                  If (l_multi_GAAP_yn = 'N') OR
                     (l_multi_GAAP_yn = 'Y' and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> l_booking_tax_rec.tax_book) then
                      If (l_deal_type = 'LOAN') OR
                         (l_deal_type in ('LEASEST','LEASEDF') AND l_tax_owner = 'LESSEE')
                      then
                          x_ast_dtl_tbl(i).cost  := 0;
                      Else
                          Calc_Deprn_Cost ( p_api_version      => p_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
                                            x_return_status    => x_return_status,
                                            p_entered_deprn    => l_booking_tax_rec.cost,
                                            p_fa_cle_id        => l_booking_corp_rec.kle_id,
                                            x_calculated_deprn => x_ast_dtl_tbl(i).cost);

                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;
                      End If;
                  ElsIf (l_multi_gaap_yn = 'Y') and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) = l_booking_tax_rec.tax_book then
                      If (l_rep_deal_type = 'LEASEOP') then
                          Calc_Deprn_Cost ( p_api_version      => p_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
                                            x_return_status    => x_return_status,
                                            p_entered_deprn    => l_booking_tax_rec.cost,
                                            p_fa_cle_id        => l_booking_corp_rec.kle_id,
                                            x_calculated_deprn => x_ast_dtl_tbl(i).cost);

                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;
                       ElsIf l_rep_deal_type in ('LEASEST','LEASEDF') then
                          x_ast_dtl_tbl(i).cost := 0;
                          x_ast_dtl_tbl(i).salvage_value := 0;
                          x_ast_dtl_tbl(i).percent_salvage_value := null;
                       End If;
                  End If;
              End Loop;
              close l_booking_tax_csr;

              --if multigaap book has not been done
              If (l_multi_gaap_yn = 'Y') and (l_multi_gaap_book_done = 'N') then
                  i := i+1;
                  --get defaults
                  open l_defaults_csr (p_book        => l_rep_pdt_book,
                                       p_category_id => l_booking_corp_rec.depreciation_id,
                                       p_date        => l_booking_corp_rec.in_service_date);
                  fetch l_defaults_csr into l_defaults_rec;
                  If l_defaults_csr%NOTFOUND then
                      --Raise Error
                      null;
                  End If;
                  close l_defaults_csr;

                  --get deprn method
                  l_method_id := null;
                  If nvl(l_defaults_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr1(p_method_code => l_defaults_rec.deprn_method,
                                         p_life        => l_defaults_rec.life_in_months);
                      fetch l_method_csr1 into l_method_id;
                      if l_method_csr1%NOTFOUND then
                          null;
                      end if;
                      close l_method_csr1;
                  ElsIf nvl(l_defaults_rec.basic_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr2(p_method_code   => l_defaults_rec.deprn_method,
                                         p_basic_rate    => l_defaults_rec.basic_rate,
                                         p_adj_rate      => l_defaults_rec.adjusted_rate);
                      fetch l_method_csr2 into l_method_id;
                      --Bug# 4775166
                      if l_method_csr2%NOTFOUND then
                           null;
                      end if;
                      close l_method_csr2;
                  End If;

                  x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
                  x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_rep_pdt_book;
                  x_ast_dtl_tbl(i).BOOK_CLASS              :=  'TAX';
                  x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_defaults_rec.deprn_method;
                  x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
                  x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
                  x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_defaults_rec.life_in_months;
                  x_ast_dtl_tbl(i).BASIC_RATE              :=  l_defaults_rec.basic_rate;
                  x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_defaults_rec.adjusted_rate;
                  x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
                  x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
                  x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_defaults_rec.prorate_convention_code;
                  l_multi_gaap_book_done                   :=  'Y';

                  If (l_rep_deal_type = 'LEASEOP') then
                      Calc_Deprn_Cost ( p_api_version      => p_api_version,
                                        p_init_msg_list    => p_init_msg_list,
                                        x_msg_count        => x_msg_count,
                                        x_msg_data         => x_msg_data,
                                        x_return_status    => x_return_status,
                                        p_entered_deprn    => l_booking_tax_rec.cost,
                                        p_fa_cle_id        => l_booking_corp_rec.kle_id,
                                        x_calculated_deprn => x_ast_dtl_tbl(i).cost);

                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                  Elsif l_rep_deal_type in ('LEASEST','LEASEDF') then
                      x_ast_dtl_tbl(i).cost := 0;
                      x_ast_dtl_tbl(i).salvage_value := 0;
                      x_ast_dtl_tbl(i).percent_salvage_value := null;
                  End If;
            End If;

         --2. Online Rebook adjustments
         ElsIf (l_curr_trx_rec.tas_type = 'CRB') and (l_curr_trx_rec.tal_type = 'CRB') then

             open l_booking_corp_csr(p_tal_id => l_curr_trx_rec.tal_id);
             Fetch l_booking_corp_csr into l_booking_corp_rec;
             If l_booking_corp_csr%NOTFOUND then
               --Bug# 4775166
               close l_booking_corp_csr;
               open l_clev_csr(p_cle_id => p_cle_id);
               fetch l_clev_csr into l_clev_rec;
               close l_clev_csr;

               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_LA_NO_CORP_BOOK_DFLTS',
                                   p_token1       => 'ASSET_NUMBER',
                                   p_token1_value => l_clev_rec.name
				           );
               Raise OKL_API.G_EXCEPTION_ERROR;
               --Bug# 4775166
             End If;
             close l_booking_corp_csr;

             l_method_id := null;
             If nvl(l_booking_corp_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr1(p_method_code => l_booking_corp_rec.deprn_method,
                                    p_life        => l_booking_corp_rec.life_in_months);
                 fetch l_method_csr1 into l_method_id;
                 if l_method_csr1%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr1;
             ElsIf nvl(l_booking_corp_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr2(p_method_code   => l_booking_corp_rec.deprn_method,
                                    p_basic_rate    => l_booking_corp_rec.deprn_rate,
                                    p_adj_rate      => l_booking_corp_rec.deprn_rate);
                 fetch l_method_csr2 into l_method_id;
                 --Bug# 4775166
                 if l_method_csr2%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr2;
             End If;

             --fetch data from FA
             l_fa_rec := null;
             open l_fa_csr (p_asset_number  => l_booking_corp_rec.asset_number,
                            p_book          => l_booking_corp_rec.corporate_book);
             fetch l_fa_csr into l_fa_rec;
             If l_fa_csr%NOTFOUND then
                 --Raise error
                 null;
             End If;
             close l_fa_csr;

             i := 1;
             x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
             x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_corp_rec.corporate_book;
             x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_corp_rec.book_class;
             x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_corp_rec.deprn_method;
             x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
             x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
             x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_corp_rec.life_in_months;
             x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
             x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_corp_rec.deprn_rate;
             x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
             x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
             x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;



             If l_deal_type in ('LEASEDF','LEASEST','LOAN') then
                 x_ast_dtl_tbl(i).cost                  := l_fa_rec.cost;
                 x_ast_dtl_tbl(i).salvage_value         := l_fa_rec.salvage_value;
                 x_ast_dtl_tbl(i).percent_salvage_value := l_fa_rec.percent_salvage_value;
             Else

                 -- Bug# 4899328: Cap fee changes are now included in the
                 -- Depreciation cost. Depreciation cost amount is automatically
                 -- recalculated whenever there is a change to cap fee.
                 /*
                 --find out if new capitalized fee has been added
                 Calc_Cap_Fee_Adjustment
                            (p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             x_return_status      => x_return_status,
                             p_rbk_fa_cle_id      => l_booking_corp_rec.kle_id,
                             p_rbk_chr_id         => p_chr_id,
                             x_cap_fee_adjustment => l_cap_fee_delta);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                  x_ast_dtl_tbl(i).cost   := l_booking_corp_rec.depreciation_cost + l_cap_fee_delta;
                  */

                  x_ast_dtl_tbl(i).cost   := l_booking_corp_rec.depreciation_cost;
                  -- Bug# 4899328: End

             End If;

             --process tax_books
             l_multi_gaap_book_done := 'N';
             open l_booking_tax_csr(p_tal_id          => l_curr_trx_rec.tal_id,
                                 p_category_id     => l_booking_corp_rec.depreciation_id,
                                 p_in_service_date => l_booking_corp_rec.in_service_date);
             loop
                  fetch l_booking_tax_csr into l_booking_tax_rec;
                  Exit when l_booking_tax_csr%NOTFOUND;
                  i := i + 1;

                  --get deprn method
                  l_method_id := null;
                  If nvl(l_booking_tax_rec.life_in_months_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr1(p_method_code => l_booking_tax_rec.deprn_method_tax,
                                         p_life        => l_booking_tax_rec.life_in_months_tax);
                      fetch l_method_csr1 into l_method_id;
                      if l_method_csr1%NOTFOUND then
                          null;
                      end if;
                      close l_method_csr1;
                  ElsIf nvl(l_booking_tax_rec.deprn_rate_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr2(p_method_code   => l_booking_tax_rec.deprn_method_tax,
                                         p_basic_rate    => l_booking_tax_rec.deprn_rate_tax,
                                         p_adj_rate      => l_booking_tax_rec.deprn_rate_tax);
                      fetch l_method_csr2 into l_method_id;
                      --Bug# 4775166
                      if l_method_csr2%NOTFOUND then
                           null;
                      end if;
                      close l_method_csr2;
                  End If;

                  --fetch data from FA
                  l_fa_rec := null;
                  open l_fa_csr (p_asset_number  => l_booking_corp_rec.asset_number,
                                 p_book          => l_booking_tax_rec.tax_book);
                  fetch l_fa_csr into l_fa_rec;
                  If l_fa_csr%NOTFOUND then
                      --Raise error
                      null;
                  End If;
                  close l_fa_csr;

                  x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
                  x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_tax_rec.tax_book;
                  x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_tax_rec.book_class;
                  x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_tax_rec.deprn_method_tax;
                  x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
                  x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
                  x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_tax_rec.life_in_months_tax;
                  x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
                  x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_tax_rec.deprn_rate_tax;
                  If nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR and
                     l_multi_gaap_yn = 'Y' and
                     l_rep_pdt_book = l_booking_tax_rec.tax_book then
                     x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
                     x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
                     l_multi_gaap_book_done                   :=  'Y';
                  end if;
                  x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;

                  If (l_multi_GAAP_yn = 'N') OR
                     (l_multi_GAAP_yn = 'Y' and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> l_booking_tax_rec.tax_book) then
                      If (l_deal_type = 'LOAN') OR
                         (l_deal_type in ('LEASEST','LEASEDF') AND l_tax_owner = 'LESSEE')
                      then
                          x_ast_dtl_tbl(i).cost  := l_fa_rec.cost;
                      Else

                          -- Bug# 4899328: Cap fee changes are now included in the
                          -- Depreciation cost. Depreciation cost amount is automatically
                          -- recalculated whenever there is a change to cap fee.
                          /*
                          --find out if new capitalized fee has been added
                          Calc_Cap_Fee_Adjustment
                            (p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             x_return_status      => x_return_status,
                             p_rbk_fa_cle_id      => l_booking_corp_rec.kle_id,
                             p_rbk_chr_id         => p_chr_id,
                             x_cap_fee_adjustment => l_cap_fee_delta);

                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;
                          x_ast_dtl_tbl(i).cost   := l_booking_tax_rec.cost + l_cap_fee_delta;
                          */

                          x_ast_dtl_tbl(i).cost   := l_booking_tax_rec.cost;
                          --Bug# 4899328: End
                      End If;

                  ElsIf (l_multi_gaap_yn = 'Y') and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) = l_booking_tax_rec.tax_book then
                      If (l_rep_deal_type = 'LEASEOP') then

                          -- Bug# 4899328: Cap fee changes are now included in the
                          -- Depreciation cost. Depreciation cost amount is automatically
                          -- recalculated whenever there is a change to cap fee.
                          /*
                          --find out if new capitalized fee has been added
                          Calc_Cap_Fee_Adjustment
                            (p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             x_return_status      => x_return_status,
                             p_rbk_fa_cle_id      => l_booking_corp_rec.kle_id,
                             p_rbk_chr_id         => p_chr_id,
                             x_cap_fee_adjustment => l_cap_fee_delta);

                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;
                          x_ast_dtl_tbl(i).cost   := l_booking_tax_rec.cost + l_cap_fee_delta;
                          */

                          x_ast_dtl_tbl(i).cost   := l_booking_tax_rec.cost;
                          --Bug# 4899328: End

                       ElsIf l_rep_deal_type in ('LEASEST','LEASEDF') then

                          x_ast_dtl_tbl(i).cost                  := l_fa_rec.cost;
                          x_ast_dtl_tbl(i).salvage_value         := l_fa_rec.salvage_value;
                          x_ast_dtl_tbl(i).percent_salvage_value := l_fa_rec.percent_salvage_value;

                       End If;
                  End If;
              End Loop;
              close l_booking_tax_csr;
          --3. Release Asset and Release Contract Case
          ElsIf (l_curr_trx_rec.tas_type = 'CRL') and (l_curr_trx_rec.tal_type = 'CRL') then
            open l_booking_corp_csr(p_tal_id => l_curr_trx_rec.tal_id);
             Fetch l_booking_corp_csr into l_booking_corp_rec;
             If l_booking_corp_csr%NOTFOUND then
               --Bug# 4775166
               close l_booking_corp_csr;
               open l_clev_csr(p_cle_id => p_cle_id);
               fetch l_clev_csr into l_clev_rec;
               close l_clev_csr;

               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_LA_NO_CORP_BOOK_DFLTS',
                                   p_token1       => 'ASSET_NUMBER',
                                   p_token1_value => l_clev_rec.name
				           );
               Raise OKL_API.G_EXCEPTION_ERROR;
               --Bug# 4775166
             End If;
             close l_booking_corp_csr;

             l_method_id := null;
             If nvl(l_booking_corp_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr1(p_method_code => l_booking_corp_rec.deprn_method,
                                    p_life        => l_booking_corp_rec.life_in_months);
                 fetch l_method_csr1 into l_method_id;
                 if l_method_csr1%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr1;
             ElsIf nvl(l_booking_corp_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr2(p_method_code   => l_booking_corp_rec.deprn_method,
                                    p_basic_rate    => l_booking_corp_rec.deprn_rate,
                                    p_adj_rate      => l_booking_corp_rec.deprn_rate);
                 fetch l_method_csr2 into l_method_id;
                 --Bug# 4775166
                 if l_method_csr2%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr2;
             End If;

             --fetch data from FA
             l_fa_rec := null;
             open l_fa_csr (p_asset_number  => l_booking_corp_rec.asset_number,
                            p_book          => l_booking_corp_rec.corporate_book);
             fetch l_fa_csr into l_fa_rec;
             If l_fa_csr%NOTFOUND then
                 --Raise error
                 null;
             End If;
             close l_fa_csr;

             i := 1;
             x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
             x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_corp_rec.corporate_book;
             x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_corp_rec.book_class;
             x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_corp_rec.deprn_method;
             x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
             x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
             x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_corp_rec.life_in_months;
             x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
             x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_corp_rec.deprn_rate;
             x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
             x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
             x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;

             -- Bug# 5150150
             OPEN  l_orig_sys_src_code_csr ( p_chr_id );
             FETCH l_orig_sys_src_code_csr INTO l_chr_id, l_orig_system_source_code;
             CLOSE l_orig_sys_src_code_csr;

             -- If Re-lease contract
             if ((l_orig_system_source_code is not null) and (l_orig_system_source_code = 'OKL_RELEASE')) then

                        OPEN  l_exp_asset_cost_csr ( p_cle_id );
                        FETCH l_exp_asset_cost_csr INTO l_cle_id, l_exp_asset_cost;
                        CLOSE l_exp_asset_cost_csr;
             end if;
             -- Bug# 5150150

             If l_deal_type in ('LEASEDF','LEASEST','LOAN') then
                 -- Bug# 5150150
                 x_ast_dtl_tbl(i).cost                  := 0;
                 x_ast_dtl_tbl(i).salvage_value         := 0;
                 x_ast_dtl_tbl(i).percent_salvage_value := 0;
             Else
                  -- Bug# 5150150-start
                  -- If Re-lease contract
                    if ((l_orig_system_source_code is not null) and (l_orig_system_source_code = 'OKL_RELEASE')) then
                        if (NVL(l_fa_rec.cost,0) = 0) then
                          x_ast_dtl_tbl(i).cost   := l_exp_asset_cost ;
                        else
                          x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;
                        end if;

                    -- if Re-lease asset
                    else
                        x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;

                        --find out if new capitalized fee has been added
                        open cap_fee_csr(p_fin_ast_cle_id   => p_cle_id
                                        ,p_chr_id           => p_chr_id);
                        fetch cap_fee_csr into l_new_cap_fee;
                        close cap_fee_csr;

                        x_ast_dtl_tbl(i).cost := x_ast_dtl_tbl(i).cost + NVL(l_new_cap_fee,0);
                    end if;

                    -- Bug# 5150150-End
             End If;

             --process tax_books
             l_multi_gaap_book_done := 'N';
             open l_booking_tax_csr(p_tal_id          => l_curr_trx_rec.tal_id,
                                    p_category_id     => l_booking_corp_rec.depreciation_id,
                                    p_in_service_date => l_booking_corp_rec.in_service_date);
             loop
                  fetch l_booking_tax_csr into l_booking_tax_rec;
                  Exit when l_booking_tax_csr%NOTFOUND;
                  i := i + 1;

                  --get deprn method
                  l_method_id := null;
                  If nvl(l_booking_tax_rec.life_in_months_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr1(p_method_code => l_booking_tax_rec.deprn_method_tax,
                                         p_life        => l_booking_tax_rec.life_in_months_tax);
                      fetch l_method_csr1 into l_method_id;
                      if l_method_csr1%NOTFOUND then
                          null;
                      end if;
                      close l_method_csr1;
                  ElsIf nvl(l_booking_tax_rec.deprn_rate_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr2(p_method_code   => l_booking_tax_rec.deprn_method_tax,
                                         p_basic_rate    => l_booking_tax_rec.deprn_rate_tax,
                                         p_adj_rate      => l_booking_tax_rec.deprn_rate_tax);
                      fetch l_method_csr2 into l_method_id;
                      --Bug# 4775166
                      if l_method_csr2%NOTFOUND then
                           null;
                      end if;
                      close l_method_csr2;
                  End If;

                  --fetch data from FA
                  l_fa_rec := null;
                  open l_fa_csr (p_asset_number  => l_booking_corp_rec.asset_number,
                                 p_book          => l_booking_tax_rec.tax_book);
                  fetch l_fa_csr into l_fa_rec;
                  If l_fa_csr%NOTFOUND then
                      --Raise error
                      null;
                  End If;
                  close l_fa_csr;

                  x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
                  x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_tax_rec.tax_book;
                  x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_tax_rec.book_class;
                  x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_tax_rec.deprn_method_tax;
                  x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
                  x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
                  x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_tax_rec.life_in_months_tax;
                  x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
                  x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_tax_rec.deprn_rate_tax;
                  If nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR and
                     l_multi_gaap_yn = 'Y' and
                     l_rep_pdt_book = l_booking_tax_rec.tax_book then
                     x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
                     x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
                     l_multi_gaap_book_done                   :=  'Y';
                  end if;
                  x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;
                If (l_multi_GAAP_yn = 'N') OR
                     (l_multi_GAAP_yn = 'Y' and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> l_booking_tax_rec.tax_book) then

                      -- Bug# 5150150
                      If (l_deal_type = 'LOAN') OR
                         (l_deal_type in ('LEASEST','LEASEDF') AND l_tax_owner = 'LESSEE')
                      then
                          x_ast_dtl_tbl(i).cost  := 0;
                      Else
                          -- Bug# 5150150-start
                          -- If Re-lease contract
                          if ((l_orig_system_source_code is not null) and (l_orig_system_source_code = 'OKL_RELEASE')) then
                            if (NVL(l_fa_rec.cost,0) = 0) then
                              x_ast_dtl_tbl(i).cost   := l_exp_asset_cost ;
                            else
                              x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;
                            end if;
                          -- if Re-lease asset
                          else
                            x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;

                            --find out if new capitalized fee has been added
                            open cap_fee_csr(p_fin_ast_cle_id   => p_cle_id
                                            ,p_chr_id           => p_chr_id);
                            fetch cap_fee_csr into l_new_cap_fee;
                            close cap_fee_csr;

                            x_ast_dtl_tbl(i).cost := x_ast_dtl_tbl(i).cost + NVL(l_new_cap_fee,0);
                          end if;
                          -- Bug# 5150150-End
                      End If;

                  ElsIf (l_multi_gaap_yn = 'Y') and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) = l_booking_tax_rec.tax_book then
                      If (l_rep_deal_type = 'LEASEOP') then
                          --find out if new capitalized fee has been added

                          -- Bug# 5150150-start
                          -- If Re-lease contract
                          if (NVL(l_orig_system_source_code,OKL_API.G_MISS_CHAR) = 'OKL_RELEASE') then
                            if (NVL(l_fa_rec.cost,0) = 0) then
                              x_ast_dtl_tbl(i).cost   := l_exp_asset_cost ;
                            else
                              x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;
                            end if;
                          -- if Re-lease asset
                          else
                            x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;

                            --find out if new capitalized fee has been added
                            open cap_fee_csr(p_fin_ast_cle_id   => p_cle_id
                                            ,p_chr_id           => p_chr_id);
                            fetch cap_fee_csr into l_new_cap_fee;
                            close cap_fee_csr;

                            x_ast_dtl_tbl(i).cost := x_ast_dtl_tbl(i).cost + NVL(l_new_cap_fee,0);
                          end if;
                          -- Bug# 5150150-End

                       ElsIf l_rep_deal_type in ('LEASEST','LEASEDF') then
                          -- Bug# 5150150
                          x_ast_dtl_tbl(i).cost                  := 0;
                          x_ast_dtl_tbl(i).salvage_value         := 0;
                          x_ast_dtl_tbl(i).percent_salvage_value := 0;

                       End If;
                  End If;
              End Loop;
              close l_booking_tax_csr;
          -------------
          --Bug# 4138635
          --4. Split Asset Case
          ElsIf (l_curr_trx_rec.tas_type = 'CSP') and (l_curr_trx_rec.tal_type = 'CSP') then
            open l_booking_corp_csr(p_tal_id => l_curr_trx_rec.tal_id);
             Fetch l_booking_corp_csr into l_booking_corp_rec;
             If l_booking_corp_csr%NOTFOUND then
                --Bug# 4775166
               close l_booking_corp_csr;
               open l_clev_csr(p_cle_id => p_cle_id);
               fetch l_clev_csr into l_clev_rec;
               close l_clev_csr;

               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_LA_NO_CORP_BOOK_DFLTS',
                                   p_token1       => 'ASSET_NUMBER',
                                   p_token1_value => l_clev_rec.name
				           );
               Raise OKL_API.G_EXCEPTION_ERROR;
               --Bug# 4775166
             End If;
             close l_booking_corp_csr;

             l_method_id := null;
             If nvl(l_booking_corp_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr1(p_method_code => l_booking_corp_rec.deprn_method,
                                    p_life        => l_booking_corp_rec.life_in_months);
                 fetch l_method_csr1 into l_method_id;
                 if l_method_csr1%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr1;
             ElsIf nvl(l_booking_corp_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr2(p_method_code   => l_booking_corp_rec.deprn_method,
                                    p_basic_rate    => l_booking_corp_rec.deprn_rate,
                                    p_adj_rate      => l_booking_corp_rec.deprn_rate);
                 fetch l_method_csr2 into l_method_id;
                 --Bug# 4775166
                 if l_method_csr2%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr2;
             End If;

             --fetch data from FA
             l_fa_rec := null;
             open l_fa_csr (p_asset_number  => l_booking_corp_rec.asset_number,
                            p_book          => l_booking_corp_rec.corporate_book);
             fetch l_fa_csr into l_fa_rec;
             If l_fa_csr%NOTFOUND then
                 --Raise error
                 null;
             End If;
             close l_fa_csr;

             i := 1;
             x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
             x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_corp_rec.corporate_book;
             x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_corp_rec.book_class;
             x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_corp_rec.deprn_method;
             x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
             x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
             x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_corp_rec.life_in_months;
             x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
             x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_corp_rec.deprn_rate;
             x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
             x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
             x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;



             If l_deal_type in ('LEASEDF','LEASEST','LOAN') then
                 x_ast_dtl_tbl(i).cost                  := l_fa_rec.cost;
                 x_ast_dtl_tbl(i).salvage_value         := l_fa_rec.salvage_value;
                 x_ast_dtl_tbl(i).percent_salvage_value := l_fa_rec.percent_salvage_value;
             Else
                  x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;
             End If;

             --process tax_books
             l_multi_gaap_book_done := 'N';
             open l_booking_tax_csr(p_tal_id          => l_curr_trx_rec.tal_id,
                                    p_category_id     => l_booking_corp_rec.depreciation_id,
                                    p_in_service_date => l_booking_corp_rec.in_service_date);
             loop
                  fetch l_booking_tax_csr into l_booking_tax_rec;
                  Exit when l_booking_tax_csr%NOTFOUND;
                  i := i + 1;

                  --get deprn method
                  l_method_id := null;
                  If nvl(l_booking_tax_rec.life_in_months_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr1(p_method_code => l_booking_tax_rec.deprn_method_tax,
                                         p_life        => l_booking_tax_rec.life_in_months_tax);
                      fetch l_method_csr1 into l_method_id;
                      if l_method_csr1%NOTFOUND then
                          null;
                      end if;
                      close l_method_csr1;
                  ElsIf nvl(l_booking_tax_rec.deprn_rate_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      open l_method_csr2(p_method_code   => l_booking_tax_rec.deprn_method_tax,
                                         p_basic_rate    => l_booking_tax_rec.deprn_rate_tax,
                                         p_adj_rate      => l_booking_tax_rec.deprn_rate_tax);
                      fetch l_method_csr2 into l_method_id;
                      --Bug# 4775166
                      if l_method_csr2%NOTFOUND then
                           null;
                      end if;
                      close l_method_csr2;
                  End If;

                  --fetch data from FA
                  l_fa_rec := null;
                  open l_fa_csr (p_asset_number  => l_booking_corp_rec.asset_number,
                                 p_book          => l_booking_tax_rec.tax_book);
                  fetch l_fa_csr into l_fa_rec;
                  If l_fa_csr%NOTFOUND then
                      --Raise error
                      null;
                  End If;
                  close l_fa_csr;

                  x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_booking_corp_rec.asset_number;
                  x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_booking_tax_rec.tax_book;
                  x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_booking_tax_rec.book_class;
                  x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_booking_tax_rec.deprn_method_tax;
                  x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
                  x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_booking_corp_rec.in_service_date;
                  x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_booking_tax_rec.life_in_months_tax;
                  x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
                  x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_booking_tax_rec.deprn_rate_tax;
                  If nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR and
                     l_multi_gaap_yn = 'Y' and
                     l_rep_pdt_book = l_booking_tax_rec.tax_book then
                     x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_booking_corp_rec.salvage_value;
                     x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_booking_corp_rec.percent_salvage_value;
                     l_multi_gaap_book_done                   :=  'Y';
                  end if;
                  x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;
                If (l_multi_GAAP_yn = 'N') OR
                     (l_multi_GAAP_yn = 'Y' and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) <> l_booking_tax_rec.tax_book) then
                      x_ast_dtl_tbl(i).cost  := l_fa_rec.cost;

                  ElsIf (l_multi_gaap_yn = 'Y') and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) = l_booking_tax_rec.tax_book then
                      If (l_rep_deal_type = 'LEASEOP') then
                          --find out if new capitalized fee has been added
                          x_ast_dtl_tbl(i).cost   := l_fa_rec.cost ;

                       ElsIf l_rep_deal_type in ('LEASEST','LEASEDF') then

                          x_ast_dtl_tbl(i).cost                  := l_fa_rec.cost;
                          x_ast_dtl_tbl(i).salvage_value         := l_fa_rec.salvage_value;
                          x_ast_dtl_tbl(i).percent_salvage_value := l_fa_rec.percent_salvage_value;

                       End If;
                  End If;
              End Loop;
              close l_booking_tax_csr;
              --Bug# 4138635
          End If;
      --Mass rebook - created transaction type

      --Bug# 6344223 : Included transaction type 'Split Asset'
      ElsIf (l_curr_trx_rec.transaction_type) in('Rebook', 'Split Asset') then
          --Bug# 6344223 Included tas_type 'ALI'
          If (l_curr_trx_rec.tas_type in('CRB','ALI')) and (l_curr_trx_rec.tal_type in('CRB','ALI')) then
             open l_mass_rebook_corp_csr(p_tal_id => l_curr_trx_rec.tal_id);
             Fetch l_mass_rebook_corp_csr into l_mass_rebook_corp_rec;
             If l_mass_rebook_corp_csr%NOTFOUND then
               --Bug# 4775166
               close l_mass_rebook_corp_csr;
               open l_clev_csr(p_cle_id => p_cle_id);
               fetch l_clev_csr into l_clev_rec;
               close l_clev_csr;

               OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_LA_NO_CORP_BOOK_DFLTS',
                                   p_token1       => 'ASSET_NUMBER',
                                   p_token1_value => l_clev_rec.name
				           );
               Raise OKL_API.G_EXCEPTION_ERROR;
               --Bug# 4775166
             End If;
             close l_mass_rebook_corp_csr;

             l_method_id := null;
             If nvl(l_mass_rebook_corp_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr1(p_method_code => l_mass_rebook_corp_rec.deprn_method,
                                    p_life        => l_mass_rebook_corp_rec.life_in_months);
                 fetch l_method_csr1 into l_method_id;
                 if l_method_csr1%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr1;
             ElsIf nvl(l_mass_rebook_corp_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                 open l_method_csr2(p_method_code   => l_mass_rebook_corp_rec.deprn_method,
                                    p_basic_rate    => l_mass_rebook_corp_rec.deprn_rate,
                                    p_adj_rate      => l_mass_rebook_corp_rec.deprn_rate);
                 fetch l_method_csr2 into l_method_id;
                 --Bug# 4775166
                 if l_method_csr2%NOTFOUND then
                     null;
                 end if;
                 close l_method_csr2;
             End If;

             --fetch data from FA
             l_fa_rec := null;
             open l_fa_csr (p_asset_number  => l_mass_rebook_corp_rec.asset_number,
                            p_book          => l_mass_rebook_corp_rec.corporate_book);
             fetch l_fa_csr into l_fa_rec;
             If l_fa_csr%NOTFOUND then
                 --Raise error
                 null;
             End If;
             close l_fa_csr;

             i := 1;

             x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_mass_rebook_corp_rec.asset_number;
             x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_mass_rebook_corp_rec.corporate_book;
             x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_mass_rebook_corp_rec.book_class;
             x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_mass_rebook_corp_rec.deprn_method;
             x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
             x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  nvl(l_mass_rebook_corp_rec.in_service_date,l_fa_rec.date_placed_in_service);
             x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_mass_rebook_corp_rec.life_in_months;
             x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
             x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_mass_rebook_corp_rec.deprn_rate;
             x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  nvl(l_mass_rebook_corp_rec.salvage_value,l_fa_rec.salvage_value);
             x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  nvl(l_mass_rebook_corp_rec.percent_salvage_value,l_fa_rec.percent_salvage_value);
             x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec.prorate_convention_code;

             If x_ast_dtl_tbl(i).asset_number is not null and l_method_id is null Then
                 --unable to resolve method from supplied deprn parameters
                 x_ast_dtl_tbl(i).DEPRN_METHOD    := l_fa_rec.deprn_method_code;
                 x_ast_dtl_tbl(i).LIFE_IN_MONTHS  := l_fa_rec.life_in_months;
                 x_ast_dtl_tbl(i).BASIC_RATE      := l_fa_Rec.basic_rate;
                 x_ast_dtl_tbl(i).ADJUSTED_RATE   := l_fa_rec.adjusted_rate;
                 --get method id
                 l_method_id := null;
                 If nvl(l_fa_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                     open l_method_csr1(p_method_code => l_fa_rec.deprn_method_code,
                                        p_life        => l_fa_rec.life_in_months);
                     fetch l_method_csr1 into l_method_id;
                     if l_method_csr1%NOTFOUND then
                         null;
                     end if;
                     close l_method_csr1;
                 ElsIf nvl(l_fa_rec.adjusted_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                     open l_method_csr2(p_method_code   => l_fa_rec.deprn_method_code,
                                        p_basic_rate    => l_fa_rec.basic_rate,
                                        p_adj_rate      => l_fa_rec.adjusted_rate);
                     fetch l_method_csr2 into l_method_id;
                     --Bug# 4775166
                     if l_method_csr2%NOTFOUND then
                         null;
                     end if;
                     close l_method_csr2;
                 End If;
             End If;

             x_ast_dtl_tbl(i).DEPRN_METHOD_ID     :=  l_method_id;
             x_ast_dtl_tbl(i).COST                := l_fa_rec.cost;

             --process tax_books
             open l_fa_csr2 (p_chr_id => p_chr_id,
                             p_cle_id => p_cle_id);
             Loop
                 fetch l_fa_csr2 into l_fa_rec2;
                 Exit when l_fa_csr2%NOTFOUND ;
                 If l_fa_rec2.book_class = 'TAX' then
                 open l_mass_rebook_tax_csr(p_tal_id          => l_curr_trx_rec.tal_id,
                                            p_category_id     => l_fa_rec.asset_category_id,
                                            p_in_service_date => l_fa_rec.date_placed_in_service,
                                            p_book            => l_fa_rec2.book_type_code);

                  fetch l_mass_rebook_tax_csr into l_mass_rebook_tax_rec;
                  If l_mass_rebook_tax_csr%NOTFOUND then
                      i := i + 1;
                      x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_fa_rec2.asset_number;
                      x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_fa_rec2.book_type_code;
                      x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_fa_rec2.book_class;
                      x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_fa_rec2.deprn_method_code;
                      x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  l_fa_rec2.date_placed_in_service;
                      x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_fa_rec2.life_in_months;
                      x_ast_dtl_tbl(i).BASIC_RATE              :=  l_fa_rec2.basic_rate;
                      x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_fa_rec2.adjusted_rate;
                      x_ast_dtl_tbl(i).SALVAGE_VALUE           :=  l_fa_rec2.salvage_value;
                      x_ast_dtl_tbl(i).PERCENT_SALVAGE_VALUE   :=  l_fa_rec2.percent_salvage_value;
                      x_ast_dtl_tbl(i).PRORATE_CONVENTION_CODE :=  l_fa_rec2.prorate_convention_code;
                      x_ast_dtl_tbl(i).COST                    :=  l_fa_rec2.cost;
                       --get method id
                      l_method_id := null;
                      If nvl(l_fa_rec2.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                          open l_method_csr1(p_method_code => l_fa_rec2.deprn_method_code,
                                             p_life        => l_fa_rec2.life_in_months);
                          fetch l_method_csr1 into l_method_id;
                          if l_method_csr1%NOTFOUND then
                              null;
                          end if;
                          close l_method_csr1;
                      ElsIf nvl(l_fa_rec2.adjusted_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                          open l_method_csr2(p_method_code   => l_fa_rec2.deprn_method_code,
                                             p_basic_rate    => l_fa_rec2.basic_rate,
                                             p_adj_rate      => l_fa_rec2.adjusted_rate);
                          fetch l_method_csr2 into l_method_id;
                          --Bug# 4775166
                          if l_method_csr2%NOTFOUND then
                              null;
                          end if;
                          close l_method_csr2;
                      End If;
                      x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;

                   ElsIf l_mass_rebook_tax_csr%FOUND then
                       --get deprn method
                      i := i + 1;
                      l_method_id := null;
                      If nvl(l_mass_rebook_tax_rec.life_in_months_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                          open l_method_csr1(p_method_code => l_mass_rebook_tax_rec.deprn_method_tax,
                                             p_life        => l_mass_rebook_tax_rec.life_in_months_tax);
                          fetch l_method_csr1 into l_method_id;
                          if l_method_csr1%NOTFOUND then
                             null;
                          end if;
                          close l_method_csr1;
                      ElsIf nvl(l_mass_rebook_tax_rec.deprn_rate_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                          open l_method_csr2(p_method_code   => l_mass_rebook_tax_rec.deprn_method_tax,
                                             p_basic_rate    => l_mass_rebook_tax_rec.deprn_rate_tax,
                                             p_adj_rate      => l_mass_rebook_tax_rec.deprn_rate_tax);
                          fetch l_method_csr2 into l_method_id;
                          --Bug# 4775166
                          if l_method_csr2%NOTFOUND then
                               null;
                          end if;
                          close l_method_csr2;
                      End If;

                      x_ast_dtl_tbl(i).ASSET_NUMBER            :=  l_mass_rebook_corp_rec.asset_number;
                      x_ast_dtl_tbl(i).BOOK_TYPE_CODE          :=  l_mass_rebook_tax_rec.tax_book;
                      x_ast_dtl_tbl(i).BOOK_CLASS              :=  l_mass_rebook_tax_rec.book_class;
                      x_ast_dtl_tbl(i).DEPRN_METHOD            :=  l_mass_rebook_tax_rec.deprn_method_tax;
                      x_ast_dtl_tbl(i).DEPRN_METHOD_ID         :=  l_method_id;
                      x_ast_dtl_tbl(i).IN_SERVICE_DATE         :=  nvl(l_mass_rebook_corp_rec.in_service_date,l_fa_rec2.date_placed_in_service);
                      x_ast_dtl_tbl(i).LIFE_IN_MONTHS          :=  l_mass_rebook_tax_rec.life_in_months_tax;
                      x_ast_dtl_tbl(i).BASIC_RATE              :=  null;
                      x_ast_dtl_tbl(i).ADJUSTED_RATE           :=  l_mass_rebook_tax_rec.deprn_rate_tax;
                      x_ast_dtl_tbl(i).salvage_value           :=  l_fa_rec2.salvage_value;
                      x_ast_dtl_tbl(i).percent_salvage_value   :=  l_fa_rec2.percent_salvage_value;
                      x_ast_dtl_tbl(i).COST                    :=  l_fa_rec2.cost;
                      If x_ast_dtl_tbl(i).asset_number is not null and l_method_id is null Then
                          --unable to resolve method from supplied deprn parameters
                         x_ast_dtl_tbl(i).DEPRN_METHOD    := l_fa_rec2.deprn_method_code;
                         x_ast_dtl_tbl(i).LIFE_IN_MONTHS  := l_fa_rec2.life_in_months;
                         x_ast_dtl_tbl(i).BASIC_RATE      := l_fa_Rec2.basic_rate;
                         x_ast_dtl_tbl(i).ADJUSTED_RATE   := l_fa_rec2.adjusted_rate;
                         --get method id
                         l_method_id := null;
                         If nvl(l_fa_rec.life_in_months,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                             open l_method_csr1(p_method_code => l_fa_rec2.deprn_method_code,
                                               p_life        => l_fa_rec2.life_in_months);
                             fetch l_method_csr1 into l_method_id;
                             if l_method_csr1%NOTFOUND then
                                 null;
                             end if;
                             close l_method_csr1;
                         ElsIf nvl(l_fa_rec2.adjusted_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                             open l_method_csr2(p_method_code   => l_fa_rec2.deprn_method_code,
                                                p_basic_rate    => l_fa_rec2.basic_rate,
                                                p_adj_rate      => l_fa_rec2.adjusted_rate);
                             fetch l_method_csr2 into l_method_id;
                             --Bug# 4775166
                             if l_method_csr2%NOTFOUND then
                                 null;
                             end if;
                             close l_method_csr2;
                         End If;
                      End If;
                      x_ast_dtl_tbl(i).DEPRN_METHOD_ID     :=  l_method_id;
                  End If;
                  close l_mass_rebook_tax_csr;
                  End If;
                  End Loop;
              close l_fa_csr2;
          End If;
      End If;
      End If;
      OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      If l_curr_trx_csr%ISOPEN then
          close l_curr_trx_csr;
      end if;
      If l_booking_corp_csr%ISOPEN then
          close l_booking_corp_csr;
      end if;
      if l_booking_tax_csr%ISOPEN then
          close l_booking_tax_csr;
      end if;
      if l_method_csr1%isopen then
          close l_method_csr1;
      end if;
      if l_method_csr2%isopen then
          close l_method_csr2;
      end if;
      if l_defaults_csr%isopen then
          close l_defaults_csr;
      end if;
      if l_chr_csr%isopen then
          close l_chr_csr;
      end if;
      if l_chk_mass_rbk_csr%isopen then
          close l_chk_mass_rbk_csr;
      end if;
      if l_fa_csr2%isopen then
          close l_fa_csr2;
      end if;
      if l_fa_csr%isopen then
          close l_fa_csr;
      end if;
      if l_mass_rebook_corp_csr%isopen then
          close l_mass_rebook_corp_csr;
      end if;
      if l_mass_rebook_tax_csr%isopen then
          close l_mass_rebook_tax_csr;
      end if;
      if l_clev_csr%isopen then
          close l_clev_csr;
      end if;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      If l_curr_trx_csr%ISOPEN then
          close l_curr_trx_csr;
      end if;
      If l_booking_corp_csr%ISOPEN then
          close l_booking_corp_csr;
      end if;
      if l_booking_tax_csr%ISOPEN then
          close l_booking_tax_csr;
      end if;
      if l_method_csr1%isopen then
          close l_method_csr1;
      end if;
      if l_method_csr2%isopen then
          close l_method_csr2;
      end if;
      if l_defaults_csr%isopen then
          close l_defaults_csr;
      end if;
      if l_chr_csr%isopen then
          close l_chr_csr;
      end if;
      if l_chk_mass_rbk_csr%isopen then
          close l_chk_mass_rbk_csr;
      end if;
      if l_fa_csr2%isopen then
          close l_fa_csr2;
      end if;
      if l_fa_csr%isopen then
          close l_fa_csr;
      end if;
      if l_mass_rebook_corp_csr%isopen then
          close l_mass_rebook_corp_csr;
      end if;
      if l_mass_rebook_tax_csr%isopen then
          close l_mass_rebook_tax_csr;
      end if;
      if l_clev_csr%isopen then
          close l_clev_csr;
      end if;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
      WHEN OTHERS THEN
      If l_curr_trx_csr%ISOPEN then
          close l_curr_trx_csr;
      end if;
      If l_booking_corp_csr%ISOPEN then
          close l_booking_corp_csr;
      end if;
      if l_booking_tax_csr%ISOPEN then
          close l_booking_tax_csr;
      end if;
      if l_method_csr1%isopen then
          close l_method_csr1;
      end if;
      if l_method_csr2%isopen then
          close l_method_csr2;
      end if;
      if l_defaults_csr%isopen then
          close l_defaults_csr;
      end if;
      if l_chr_csr%isopen then
          close l_chr_csr;
      end if;
      if l_chk_mass_rbk_csr%isopen then
          close l_chk_mass_rbk_csr;
      end if;
      if l_fa_csr2%isopen then
          close l_fa_csr2;
      end if;
      if l_fa_csr%isopen then
          close l_fa_csr;
      end if;
      if l_mass_rebook_corp_csr%isopen then
          close l_mass_rebook_corp_csr;
      end if;
      if l_mass_rebook_tax_csr%isopen then
          close l_mass_rebook_tax_csr;
      end if;
      if l_clev_csr%isopen then
          close l_clev_csr;
      end if;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END Get_Pricing_parameters;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Function Name   : RECALCULATE_ASSET_COST Bug fix# 4899328
  --Description     : Procedure to recalculate Asset Depreciable Cost on Rebook
  --                  when there is a change to Capitalized Fee or Subsidy
  --
  --History         :
  --                 05-Dec-2005  rpillay Created
  --
  --End of Comments
--------------------------------------------------------------------------------
  Procedure recalculate_asset_cost ( p_api_version   IN  NUMBER,
                                     p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER,
                                     x_msg_data      OUT NOCOPY VARCHAR2,
                                     p_chr_id        IN  NUMBER,
                                     p_cle_id        IN  NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT varchar2(30) := 'RECALCULATE_ASSET_COST';
    l_api_version          CONSTANT NUMBER := 1.0;

    --cursor to check if the contract is undergoing on-line rebook
    cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
    SELECT '!'
    FROM   okc_k_headers_b CHR,
           okl_trx_contracts ktrx
    WHERE  ktrx.khr_id_new = chr.id
    AND    ktrx.tsu_code = 'ENTERED'
    AND    ktrx.rbr_code is NOT NULL
    AND    ktrx.tcn_type = 'TRBK'
   --rkuttiya added for 12.1.1 Multi GAAP Project
    AND    ktrx.representation_type = 'PRIMARY'
   --
    AND    CHR.id = p_chr_id
    AND    CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_REBOOK';

    l_rbk_khr      VARCHAR2(1) DEFAULT '?';

    --cursor to get transaction going on on this asset
    cursor l_curr_trx_csr(p_chr_id in number,
                          p_cle_id in number) is
    select ttyt.name      transaction_type,
           trx.tas_type,
           txl.tal_type,
           txl.id         tal_id,
           trx.creation_date
    from   okl_trx_types_tl         ttyt,
           okl_trx_assets           trx,
           okl_txl_assets_b         txl,
           okc_k_lines_b            cleb,
           okc_line_styles_b        lseb
    where  ttyt.id            = trx.try_id
    and    ttyt.language      = 'US'
    and    trx.id             = txl.tas_id
    and    trx.tsu_code       = 'ENTERED'
    and    txl.kle_id         = cleb.id
    and    cleb.cle_id        = p_cle_id
    and    cleb.dnz_chr_id    = p_chr_id
    and    cleb.lse_id        = lseb.id
    and    lseb.lty_code      = 'FIXED_ASSET'
    order by trx.creation_date desc;

    l_curr_trx_rec l_curr_trx_csr%ROWTYPE;

    --cursor to get contract header details
    cursor l_chr_csr (p_chr_id in number) is
    select khr.pdt_id,
           khr.deal_type,
           chrb.start_date,
           rul.rule_information1
    from   okc_rules_b       rul,
           okc_rule_groups_b rgp,
           okl_k_headers     khr,
           okc_k_headers_b   chrb
    where  rul.rule_information_category       = 'LATOWN'
    and    rul.rgp_id                          = rgp.id
    and    rul.dnz_chr_id                      = rgp.dnz_chr_id
    and    rgp.dnz_chr_id                      = chrb.id
    and    rgp.chr_id                          = chrb.id
    and    rgp.rgd_code                        = 'LATOWN'
    and    khr.id                              = chrb.id
    and    chrb.id                             = p_chr_id;

    l_pdt_id               number;
    l_start_date           date;
    l_rep_pdt_id           number;
    l_tax_owner            okc_rules_b.rule_information_category%TYPE;
    l_deal_type            okl_k_headers.deal_type%TYPE;
    l_rep_deal_type        okl_k_headers.deal_type%TYPE;
    l_Multi_GAAP_YN        varchar2(1);

    cursor l_tax_book_csr(p_tal_id in number) is
    select txd.id,
           txd.tax_book
    from   okl_txd_Assets_b txd
    where  txd.tal_id = p_tal_id;

    l_rep_pdt_book fa_books.book_type_code%TYPE;

    cursor l_capital_cost_csr(p_fin_cle_id in number) IS
    select kle_fin.capital_amount
    from   okc_k_lines_b cleb_fin,
           okl_k_lines   kle_fin
    where  cleb_fin.id = p_fin_cle_id
    and    kle_fin.id  = cleb_fin.id;

    l_capital_amount okl_k_lines.capital_amount%TYPE;

    l_talv_rec         okl_txl_assets_pub.tlpv_rec_type;
    lx_talv_rec        okl_txl_assets_pub.tlpv_rec_type;
    l_txdv_rec         okl_txd_assets_pub.adpv_rec_type;
    lx_txdv_rec        okl_txd_assets_pub.adpv_rec_type;

  BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY (
                                l_api_name
                                ,p_init_msg_list
                                ,'_PVT'
                                ,x_return_status);
     -- Check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --check for rebook contract
     l_rbk_khr := '?';
     OPEN l_chk_rbk_csr (p_chr_id => p_chr_id);
     FETCH l_chk_rbk_csr INTO l_rbk_khr;
     CLOSE l_chk_rbk_csr;

     If l_rbk_khr = '!' Then

       -------------------------------------------------
       --1. Find out details of the current transactions
       -------------------------------------------------

       For l_curr_trx_rec in l_curr_trx_csr(p_chr_id => p_chr_id,
                                            p_cle_id => p_cle_id) Loop

         --cursor to get capital cost
         l_capital_amount := 0;
         open l_capital_cost_csr(p_fin_cle_id => p_cle_id);
         fetch l_capital_cost_csr into l_capital_amount;
         close l_capital_cost_csr;

         --cursor to get contract detials :
         open l_chr_csr (p_chr_id => p_chr_id);
         fetch l_chr_csr into l_pdt_id,
                              l_deal_type,
                              l_start_date,
                              l_tax_owner;
         close l_chr_csr;

         -- Multi-GAAP Begin
         Get_Pdt_Params (p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_pdt_id        => l_pdt_id,
                         p_pdt_date      => l_start_date,
                         x_rep_pdt_id    => l_rep_pdt_id,
                         x_tax_owner     => l_tax_owner,
                         x_rep_deal_type => l_rep_deal_type);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_Multi_GAAP_YN := 'N';
         --checks wheter Multi-GAAP processing needs tobe done
         If l_rep_pdt_id is not NULL Then

      --Bug 7708944. SMEREDDY 01/15/2009.
      -- Implemented MG changes based on PM recommendation.

           l_Multi_GAAP_YN := 'Y';
/*
           If l_deal_type = 'LEASEOP' and
           nvl(l_rep_deal_type,'X') = 'LEASEOP' and
           nvl(l_tax_owner,'X') = 'LESSOR' Then
             l_Multi_GAAP_YN := 'Y';
           End If;

           If l_deal_type in ('LEASEDF','LEASEST') and
           nvl(l_rep_deal_type,'X') = 'LEASEOP' and
           nvl(l_tax_owner,'X') = 'LESSOR' Then
             l_Multi_GAAP_YN := 'Y';
           End If;

           If l_deal_type in ('LEASEDF','LEASEST') and
           nvl(l_rep_deal_type,'X') = 'LEASEOP' and
           nvl(l_tax_owner,'X') = 'LESSEE' Then
             l_Multi_GAAP_YN := 'Y';
           End If;

           If l_deal_type = 'LOAN' and
           nvl(l_rep_deal_type,'X') = 'LEASEOP' and
           nvl(l_tax_owner,'X') = 'LESSEE' Then
             l_Multi_GAAP_YN := 'Y';
           End If;

           If l_deal_type = 'LEASEOP' and
           nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
           nvl(l_tax_owner,'X') = 'LESSOR' Then
             l_Multi_GAAP_YN := 'Y';
           End If;

           If l_deal_type in ('LEASEDF','LEASEST') and
           nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
           nvl(l_tax_owner,'X') = 'LESSOR' Then
             l_Multi_GAAP_YN := 'Y';
           End If;

           If l_deal_type in ('LEASEDF','LEASEST') and
           nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
           nvl(l_tax_owner,'X') = 'LESSEE' Then
             l_Multi_GAAP_YN := 'Y';
           End If;
*/
         End If;

         If l_Multi_GAAP_YN = 'Y' Then
           --get reporting product book type
           l_rep_pdt_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
         End If;

         If (l_curr_trx_rec.transaction_type) = 'Internal Asset Creation' then
           --1. Online rebook new asset addition
           If (l_curr_trx_rec.tas_type = 'CFA') and (l_curr_trx_rec.tal_type = 'CFA') then

             -- Update Depreciation_Cost in Okl_Txl_Assets_B to
             -- the calculated Line Capital Amount
             l_talv_rec.id                    := l_curr_trx_rec.tal_id;
             l_talv_rec.depreciation_cost     := l_capital_amount;

             OKL_TXL_ASSETS_PUB.update_txl_asset_def(
               p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_tlpv_rec       => l_talv_rec,
               x_tlpv_rec       => lx_talv_rec);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --process tax_books
             For l_tax_book_rec in l_tax_book_csr(p_tal_id => l_curr_trx_rec.tal_id)
             Loop

               -- Update Cost in Okl_Txd_Assets to the calculated Line Capital Amount
               l_txdv_rec.id       := l_tax_book_rec.id;
               l_txdv_rec.cost     := l_capital_amount;

               OKL_TXD_ASSETS_PUB.UPDATE_TXD_ASSET_DEF
                 (p_api_version    =>  p_api_version,
                  p_init_msg_list  =>  p_init_msg_list,
                  x_return_status  =>  x_return_status,
                  x_msg_count      =>  x_msg_count,
                  x_msg_data       =>  x_msg_data,
                  p_adpv_rec       =>  l_txdv_rec,
                  x_adpv_rec       =>  lx_txdv_rec);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
             End Loop;

           --2. Online Rebook adjustments
           ElsIf (l_curr_trx_rec.tas_type = 'CRB') and (l_curr_trx_rec.tal_type = 'CRB') then

             If l_deal_type in ('LEASEDF','LEASEST','LOAN') then
                 -- Do not recalculate asset cost for DF/ST Lease and Loan
                 NULL;

             ElsIf l_deal_type = 'LEASEOP' Then
                 -- Update Depreciation_Cost in Okl_Txl_Assets_B to
                 -- the calculated Line Capital Amount
                 l_talv_rec.id                    := l_curr_trx_rec.tal_id;
                 l_talv_rec.depreciation_cost     := l_capital_amount;

                 OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => l_talv_rec,
                       x_tlpv_rec       => lx_talv_rec);

                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
             End If;

             --process tax_books
             For l_tax_book_rec in l_tax_book_csr(p_tal_id => l_curr_trx_rec.tal_id)
             Loop

               --Multi-Gaap Book
               If (l_multi_GAAP_yn = 'Y' and nvl(l_rep_pdt_book,OKL_API.G_MISS_CHAR) = l_tax_book_rec.tax_book) then

                 If l_rep_deal_type in ('LEASEDF','LEASEST','LOAN') then
                   -- Do not recalculate asset cost for DF/ST Lease and Loan
                   NULL;

                 ElsIf  l_rep_deal_type = 'LEASEOP' then

                   -- Update Cost in Okl_Txd_Assets to the calculated Line Capital Amount
                   l_txdv_rec.id       := l_tax_book_rec.id;
                   l_txdv_rec.cost     := l_capital_amount;

                   OKL_TXD_ASSETS_PUB.UPDATE_TXD_ASSET_DEF
                     (p_api_version    =>  p_api_version,
                      p_init_msg_list  =>  p_init_msg_list,
                      x_return_status  =>  x_return_status,
                      x_msg_count      =>  x_msg_count,
                      x_msg_data       =>  x_msg_data,
                      p_adpv_rec       =>  l_txdv_rec,
                      x_adpv_rec       =>  lx_txdv_rec);

                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;

                 End If;

               -- Tax Books
               Else

                 If (l_deal_type = 'LOAN') OR
                    (l_deal_type in ('LEASEST','LEASEDF') AND l_tax_owner = 'LESSEE') then

                      -- Do not recalculate asset cost for Loan and DF/ST Lease with Tax owner Lessee
                      NULL;
                 Else

                    -- Update Cost in Okl_Txd_Assets to the calculated Line Capital Amount
                    l_txdv_rec.id       := l_tax_book_rec.id;
                    l_txdv_rec.cost     := l_capital_amount;

                    OKL_TXD_ASSETS_PUB.UPDATE_TXD_ASSET_DEF
                     (p_api_version    =>  p_api_version,
                      p_init_msg_list  =>  p_init_msg_list,
                      x_return_status  =>  x_return_status,
                      x_msg_count      =>  x_msg_count,
                      x_msg_data       =>  x_msg_data,
                      p_adpv_rec       =>  l_txdv_rec,
                      x_adpv_rec       =>  lx_txdv_rec);

                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;

                 End if;
               End if;
             End Loop;

           End If;
         End If;
       End Loop;
     End If;
     OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
      WHEN OTHERS THEN
      If l_chk_rbk_csr%ISOPEN then
          close l_chk_rbk_csr;
      end if;
      If l_capital_cost_csr%ISOPEN then
          close l_capital_cost_csr;
      end if;
      if l_chr_csr%ISOPEN then
          close l_chr_csr;
      end if;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END recalculate_asset_cost;

END OKL_ACTIVATE_ASSET_PVT;

/
