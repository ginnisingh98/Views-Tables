--------------------------------------------------------
--  DDL for Package Body OKL_QUOTE_TO_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QUOTE_TO_CONTRACT_PVT" AS
/* $Header: OKLRLQCB.pls 120.35.12010000.9 2010/04/26 12:55:55 smadhava ship $ */

  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;

  l_qte_cntrct_ast_tbl       qte_cntrct_ast_tbl_type;

  --Get the lease app header information
  CURSOR c_get_leaseapp_hdr(p_lap_id IN okl_lease_applications_v.ID%TYPE) IS
  SELECT olav.ID,
         olav.REFERENCE_NUMBER,
         olav.PROSPECT_ID,
         olav.PROSPECT_ADDRESS_ID,
         olav.CUST_ACCT_ID,
         olav.PROGRAM_AGREEMENT_ID,
         olav.CURRENCY_CODE,
         olav.CURRENCY_CONVERSION_TYPE,
         olav.CURRENCY_CONVERSION_RATE,
         olav.CURRENCY_CONVERSION_DATE,
         olav.CREDIT_LINE_ID,
         olav.MASTER_LEASE_ID,
         olav.PARENT_LEASEAPP_ID,
         olav.SALES_REP_ID,
         olav.ORG_ID,
         olav.INV_ORG_ID,
         olqv.EXPECTED_START_DATE,
         olqv.REFERENCE_NUMBER QUOTE_NUMBER,
         olqv.TERM,
         olqv.PRODUCT_ID,
         olqv.PROPERTY_TAX_APPLICABLE,
         olqv.PROPERTY_TAX_BILLING_TYPE,
         olqv.UPFRONT_TAX_TREATMENT,
         olqv.UPFRONT_TAX_STREAM_TYPE,
         olqv.TRANSFER_OF_TITLE,
         olqv.AGE_OF_EQUIPMENT,
         olqv.PURCHASE_OF_LEASE,
         olqv.SALE_AND_LEASE_BACK,
         olqv.INTEREST_DISCLOSED,
         olqv.ID QUOTE_ID,
         olqv.EXPECTED_DELIVERY_DATE,
         olqv.EXPECTED_FUNDING_DATE,
         olqv.LEGAL_ENTITY_ID,
         olqv.LINE_INTENDED_USE     -- Bug 5908845. eBTax Enhancement Project
         ,olav.SHORT_DESCRIPTION -- ER# 9161779
  FROM   okl_lease_applications_v olav,
         okl_lease_quotes_v olqv
  WHERE  olqv.PARENT_OBJECT_CODE = 'LEASEAPP'
  AND    olqv.PARENT_OBJECT_ID =  olav.ID
  AND    olav.APPLICATION_STATUS = 'CR-APPROVED'
  AND    olqv.primary_quote = 'Y'
  AND    olav.ID = p_lap_id;

  --Get the lease opp header information
  CURSOR c_get_leaseopp_hdr(p_lop_id IN okl_lease_opportunities_v.ID%TYPE) IS
  SELECT olov.ID,
         olov.REFERENCE_NUMBER,
         olov.PROSPECT_ID,
         olov.PROSPECT_ADDRESS_ID,
         olov.CUST_ACCT_ID,
         olov.PROGRAM_AGREEMENT_ID,
         olov.CURRENCY_CODE,
         olov.CURRENCY_CONVERSION_TYPE,
         olov.CURRENCY_CONVERSION_RATE,
         olov.CURRENCY_CONVERSION_DATE,
         NULL CREDIT_LINE_ID,
         olov.MASTER_LEASE_ID,
         NULL PARENT_LEASEAPP_ID,
         olov.SALES_REP_ID,
         olov.ORG_ID,
         olov.INV_ORG_ID,
         olqv.EXPECTED_START_DATE,
         olqv.REFERENCE_NUMBER QUOTE_NUMBER,
         olqv.TERM,
         olqv.PRODUCT_ID,
         olqv.PROPERTY_TAX_APPLICABLE,
         olqv.PROPERTY_TAX_BILLING_TYPE,
         olqv.UPFRONT_TAX_TREATMENT,
         olqv.UPFRONT_TAX_STREAM_TYPE,
         olqv.TRANSFER_OF_TITLE,
         olqv.AGE_OF_EQUIPMENT,
         olqv.PURCHASE_OF_LEASE,
         olqv.SALE_AND_LEASE_BACK,
         olqv.INTEREST_DISCLOSED,
         olqv.ID QUOTE_ID,
         olqv.EXPECTED_DELIVERY_DATE,
         olqv.EXPECTED_FUNDING_DATE,
         olqv.LEGAL_ENTITY_ID,
         olqv.LINE_INTENDED_USE     -- Bug 5908845. eBTax Enhancement Project
        ,olov.SHORT_DESCRIPTION -- ER# 9161779
  FROM   okl_lease_opportunities_v olov,
         okl_lease_quotes_v olqv
  WHERE  olqv.PARENT_OBJECT_CODE = 'LEASEOPP'
  AND    olqv.PARENT_OBJECT_ID =  olov.ID
  AND    olqv.status = 'CT-ACCEPTED'
  AND    olov.ID = p_lop_id;

------------------------------------------------------------------------------
  -- PROCEDURE create_contract_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_contract_val
  -- Description     : This procedure validates the contract creation from given
  --                   lease quote.
  -- Business Rules  : This procedure validates the contract creation from given
  --                   lease quote.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-Apr-2006 ASAWANKA created Bug 5115741
  --
  -- End of comments
  PROCEDURE create_contract_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_quote_id           IN  OKL_LEASE_QUOTES_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations

    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'CREATE_CONTRACT_VAL';
    l_return_status            VARCHAR2(1);

    --Cursor to check if contract already created from lease app linked to the
    --lease opp of this quote
    CURSOR l_uniq_contract_csr(p_qte_id NUMBER)
	IS
      SELECT LAB.REFERENCE_NUMBER LSE_APP
           , CHR.CONTRACT_NUMBER CONTRACT_NUMBER
      FROM OKL_LEASE_APPLICATIONS_B LAB
         , OKL_LEASE_QUOTES_B QTE
         , OKC_K_HEADERS_B CHR
         , OKC_STATUSES_V CSTS
      WHERE LAB.LEASE_OPPORTUNITY_ID = QTE.PARENT_OBJECT_ID
        AND QTE.PARENT_OBJECT_CODE = 'LEASEOPP'
        AND LAB.APPLICATION_STATUS = 'CONV-K'
        AND LAB.ID = CHR.ORIG_SYSTEM_ID1
        AND CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP'
        AND CHR.STS_CODE = CSTS.CODE
        AND CSTS.STE_CODE <> 'CANCELLED'
        AND QTE.ID = p_qte_id;
    l_uniq_contract_rec l_uniq_contract_csr%ROWTYPE;

    --Cursor to check if contract already created directly from quote
    CURSOR l_uniq_qte_contract_csr(p_quote_id NUMBER)
	IS
      SELECT LSQ.REFERENCE_NUMBER LSE_QTE
           , LOP.REFERENCE_NUMBER LSE_OPP
           , CHR.CONTRACT_NUMBER CONTRACT_NUMBER
      FROM OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_OPPORTUNITIES_B LOP
         , OKC_K_HEADERS_B CHR
         , OKC_STATUSES_V CSTS
      WHERE CHR.ORIG_SYSTEM_ID1 = LOP.ID
        AND CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_QUOTE'
        AND CSTS.CODE = CHR.STS_CODE
        AND CSTS.STE_CODE <> 'CANCELLED'
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEOPP'
        AND LSQ.PARENT_OBJECT_ID = LOP.ID
        AND LSQ.STATUS = 'CT-ACCEPTED'
        AND LSQ.ID = p_quote_id;
    l_uniq_qte_contract_rec l_uniq_qte_contract_csr%ROWTYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => p_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Validate that only one contract being created from source Lease Opp through
    --any Lease App
    OPEN l_uniq_contract_csr(p_quote_id);
    FETCH l_uniq_contract_csr INTO l_uniq_contract_rec;
      IF l_uniq_contract_csr%FOUND
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_CNTRCT_CRT_THRU_QUOTE',
            p_token1        => 'CONTRACT',
            p_token1_value  => l_uniq_contract_rec.contract_number,
            p_token2        => 'LSE_APP',
            p_token2_value  => l_uniq_contract_rec.lse_app);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE l_uniq_contract_csr;

    --Validate that only one contract being created from  Lease Opp through
    --accepted Lease Quote
    OPEN l_uniq_qte_contract_csr(p_quote_id);
    FETCH l_uniq_qte_contract_csr INTO l_uniq_qte_contract_rec;
      IF l_uniq_qte_contract_csr%FOUND
      THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_CNTRCT_CRT_THRU_QUOTE',
            p_token1        => 'LSE_OPP',
            p_token1_value  => l_uniq_qte_contract_rec.lse_opp,
            p_token2        => 'CONTRACT',
            p_token2_value  => l_uniq_qte_contract_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE l_uniq_qte_contract_csr;


    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      --Check if Unique Contract cursor is open
      IF l_uniq_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_contract_csr;
      END IF;
      --Check if Unique Contract from quote cursor is open
      IF l_uniq_qte_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_qte_contract_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      --Check if Unique Contract cursor is open
      IF l_uniq_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_contract_csr;
      END IF;
      --Check if Unique Contract from quote cursor is open
      IF l_uniq_qte_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_qte_contract_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN

      --Check if Unique Contract cursor is open
      IF l_uniq_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_contract_csr;
      END IF;
      --Check if Unique Contract from quote cursor is open
      IF l_uniq_qte_contract_csr%ISOPEN
      THEN
        CLOSE l_uniq_qte_contract_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_contract_val;


  -----------------------------------------------------------------------------
  -- PROCEDURE update_leaseapp_status
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_leaseapp_status
  -- Description     : This Procedure updates the status of lease app
  --                 : to Converted to Contract after contract creation from lease app
  -- Business Rules  :
  -- Parameters      : p_lap_id
  -- Version         : 1.0
  -- History         : 28-Oct-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE update_leaseapp_status(p_api_version                  IN NUMBER,
                                   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                OUT NOCOPY VARCHAR2,
                                   x_msg_count                    OUT NOCOPY NUMBER,
                                   x_msg_data                     OUT NOCOPY VARCHAR2,
                                   p_lap_id                       IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE) IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'UPD_LP_STS';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    lx_return_status              VARCHAR2(1);

    x_lapv_rec                    OKL_LAP_PVT.LAPV_REC_TYPE;
    x_lsqv_rec                    OKL_LSQ_PVT.LSQV_REC_TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_APP_PVT.set_lease_app_status'
       ,'begin debug  call lease_app_upd');
    END IF;
     OKL_LEASE_APP_PVT.set_lease_app_status(p_api_version     => p_api_version,
                                    p_init_msg_list   => p_init_msg_list,
                                    x_return_status   => x_return_status,
                                    x_msg_count       => x_msg_count,
                                    x_msg_data        => x_msg_data,
                                    p_lap_id          => p_lap_id,
                                    p_lap_status      => 'CONV-K'
                                    );
     IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASE_APP_PVT.set_lease_app_status'
       ,'end debug call lease_app_upd');
     END IF;
     IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     x_return_status := okc_api.G_RET_STS_SUCCESS;
     OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END update_leaseapp_status;
  -------------------------------------------------------------------------------
  -- PROCEDURE create_vendor
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_vendor
  -- Description     : This procedure is a wrapper that creates create_vendor

  -- End of comments
  PROCEDURE create_vendor(p_api_version                  IN  NUMBER,
                               p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status                OUT NOCOPY VARCHAR2,
                               x_msg_count                    OUT NOCOPY NUMBER,
                               x_msg_data                     OUT NOCOPY VARCHAR2,
                               p_chr_id                       IN  NUMBER,
                               p_cle_id                       IN  NUMBER,
                               p_vendor_id                    IN  NUMBER)IS
   -- Variables Declarations
   l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
   l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_PTY_RLS';
   l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_debug_enabled               VARCHAR2(10);
   row_count                     NUMBER DEFAULT 0;
   lp_cplv_rec                   okl_okc_migration_pvt.cplv_rec_type;
   lx_cplv_rec                   okl_okc_migration_pvt.cplv_rec_type;
   lp_kplv_rec                   okl_k_party_roles_pvt.kplv_rec_type;
   lx_kplv_rec                   okl_k_party_roles_pvt.kplv_rec_type;

    --Check for the existing party roles
    CURSOR check_line_party_csr IS
    SELECT COUNT(1)
    FROM okc_k_party_roles_v
    WHERE dnz_chr_id = p_chr_id
    AND chr_id = p_chr_id
    AND rle_code = 'OKL_VENDOR'
    AND JTOT_OBJECT1_CODE = 'OKX_VENDOR'
    AND cle_id      = p_cle_id
    AND object1_id1 = p_vendor_id;

    CURSOR check_top_party_csr IS
    SELECT COUNT(1)
    FROM okc_k_party_roles_v
    WHERE dnz_chr_id = p_chr_id
    AND chr_id = p_chr_id
    AND rle_code = 'OKL_VENDOR'
    AND JTOT_OBJECT1_CODE = 'OKX_VENDOR'
    AND cle_id      is null
    AND object1_id1 = p_vendor_id;


   BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- check for logging on PROCEDURE level
      l_debug_enabled := okl_debug_pub.check_log_enabled;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                                ,p_pkg_name      => G_PKG_NAME
                                                ,p_init_msg_list => p_init_msg_list
                                                ,l_api_version   => l_api_version
                                                ,p_api_version   => p_api_version
                                                ,p_api_type      => g_api_type
                                                ,x_return_status => x_return_status);
      -- check if activity started successfully
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      lp_cplv_rec.object_version_number := 1.0;
      lp_cplv_rec.sfwt_flag             := OKC_API.G_FALSE;
      lp_cplv_rec.dnz_chr_id            := p_chr_id;
      lp_cplv_rec.chr_id                := p_chr_id;
      lp_cplv_rec.cle_id                := p_cle_id;
      lp_cplv_rec.object1_id1           := p_vendor_id;
      lp_cplv_rec.object1_id2           := '#';
      lp_cplv_rec.jtot_object1_code     := 'OKX_VENDOR';
      lp_cplv_rec.rle_code              := 'OKL_VENDOR';
      IF p_cle_id IS NOT NULL THEN
        lp_cplv_rec.chr_id := NULL;
        OPEN check_line_party_csr;
        FETCH check_line_party_csr INTO row_count;
        CLOSE check_line_party_csr;
      ELSE
        OPEN check_top_party_csr;
        FETCH check_top_party_csr INTO row_count;
        CLOSE check_top_party_csr;
      END IF;


      IF row_count = 0 THEN
          lp_kplv_rec.validate_dff_yn := 'Y';
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
            ,'begin debug  call create_k_party_role');
          END IF;

          okl_k_party_roles_pvt.create_k_party_role(
                                        p_api_version      => p_api_version,
                                        p_init_msg_list    => p_init_msg_list,
                                        x_return_status    => x_return_status,
                                        x_msg_count        => x_msg_count,
                                        x_msg_data         => x_msg_data,
                                        p_cplv_rec         => lp_cplv_rec,
                                        x_cplv_rec         => lx_cplv_rec,
                                        p_kplv_rec         => lp_kplv_rec,
                                        x_kplv_rec         => lx_kplv_rec);
         IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
            ,'end debug  call create_k_party_role');
         END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
    END IF;
    x_return_status := okc_api.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data);
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
   END create_vendor;


  -----------------------------------------------------------------------------
  -- FUNCTION get_fin_line_id
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_fin_line_id
  -- Description     : This function returns the fin asset line id
  --                 :for respective quote asset id
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 27-Sep-2005 SKGAUTAM created
  --
  -- End of comments
  FUNCTION get_fin_line_id (p_qte_asset_id IN NUMBER)
  RETURN NUMBER IS
  BEGIN

   FOR i in l_qte_cntrct_ast_tbl.FIRST .. l_qte_cntrct_ast_tbl.LAST LOOP
    IF l_qte_cntrct_ast_tbl.EXISTS(i) THEN
      IF l_qte_cntrct_ast_tbl(i).qte_asset_id = p_qte_asset_id THEN
         RETURN l_qte_cntrct_ast_tbl(i).cntrct_asset_id;
      END IF;
    END IF;
   END LOOP;
   RETURN NULL;
  END;

  -----------------------------------------------------------------------------
  -- PROCEDURE populate_rule_record
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_rule_record
  -- Description     : This Procedure populates the default values
  --                 : for rule record
  -- Business Rules  :
  -- Parameters      : p_chr_id, p_rgp_id, p_rule_name,x_rulv_rec
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE populate_rule_record( p_chr_id     IN          NUMBER,
                                  p_rgp_id     IN          NUMBER,
                                  p_rule_name  IN          VARCHAR2,
                                  x_rulv_rec   OUT NOCOPY  okc_rule_pub.rulv_rec_type) IS
    l_rulv_rec    okc_rule_pub.rulv_rec_type;
  BEGIN
    l_rulv_rec.dnz_chr_id                  :=  p_chr_id;
    l_rulv_rec.rgp_id                      :=  p_rgp_id;
    l_rulv_rec.std_template_yn             :=  'N';
    l_rulv_rec.warn_yn                     :=  'N';
    l_rulv_rec.template_yn                 :=  'N';
    l_rulv_rec.rule_information_category   :=  p_rule_name;
    x_rulv_rec  :=  l_rulv_rec;
  END populate_rule_record;

  -----------------------------------------------------------------------------
  -- PROCEDURE create_rule_group
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rule_group
  -- Description     : This Procedure creates the rulegroup and
  --                 : returns rule group id
  -- Business Rules  :
  -- Parameters      : p_chr_id, p_cle_id, p_rgd_code,x_rgp_id
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE create_rule_group(p_api_version                  IN NUMBER,
                              p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_cle_id                       IN         NUMBER,
                              p_chr_id                       IN         NUMBER,
                              p_rgd_code                     IN         VARCHAR2,
                              x_rgp_id                       OUT NOCOPY NUMBER) IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_RL_GRP';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    lx_return_status              VARCHAR2(1);

    l_rgpv_rec                    okc_rule_pub.rgpv_rec_type;
    lx_rgpv_rec                   okc_rule_pub.rgpv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec.rgp_type    := 'KRG';
    l_rgpv_rec.cle_id      := p_cle_id;
    l_rgpv_rec.dnz_chr_id  := p_chr_id;
    l_rgpv_rec.rgd_code    := p_rgd_code;
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okc_rule_pub.create_rule_group'
       ,'begin debug  call create_rule_group');
    END IF;
    okc_rule_pub.create_rule_group(p_api_version      => p_api_version,
                                    p_init_msg_list   => p_init_msg_list,
                                    x_return_status   => x_return_status,
                                    x_msg_count       => x_msg_count,
                                    x_msg_data        => x_msg_data,
                                    p_rgpv_rec        => l_rgpv_rec,
                                    x_rgpv_rec        => lx_rgpv_rec);
     IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okc_rule_pub.create_rule_group'
       ,'end debug call create_rule_group');
     END IF;
     IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     x_rgp_id        := lx_rgpv_rec.id;
     x_return_status := okc_api.G_RET_STS_SUCCESS;
     OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_rule_group;

  -----------------------------------------------------------------------------
  -- FUNCTION is_lasll_modified
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : is_lasll_modified
  -- Description     : This function checks whether LASLL line is modified
  --                 : or not returns boolean
  -- Business Rules  :
  -- Parameters      :p_payment_levels_rec,p_payment_frequency,p_payment_arrears
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  FUNCTION is_lasll_modified(p_payment_levels_rec   IN  payment_levels_rec_type,
                             p_payment_frequency    IN  VARCHAR2,
                             p_payment_arrears      IN  VARCHAR2) RETURN BOOLEAN IS
  -- cursor to retrieve the details of the LASLL rule
  CURSOR find_lasll_dtls_csr(p_rul_id NUMBER) IS
    SELECT object1_id1 frequency, object2_id1 laslh_id, fnd_date.canonical_to_date(rule_information2) start_date,
        rule_information3 periods, rule_information6 amount,
        rule_information5 payment_structure, rule_information13 rate,
        rule_information7 stub_days, rule_information8 stub_amount, rule_information10 arrears
    FROM okc_rules_b
    WHERE id = p_rul_id;
  BEGIN
    FOR l_lasll_csr_rec IN find_lasll_dtls_csr(p_rul_id => p_payment_levels_rec.payment_level_id)
    LOOP
        IF(l_lasll_csr_rec.frequency <> p_payment_frequency) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.arrears <> p_payment_arrears) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.amount IS NULL AND p_payment_levels_rec.amount IS NOT NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.amount IS NOT NULL AND p_payment_levels_rec.amount IS NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.amount <> p_payment_levels_rec.amount) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.periods IS NULL AND p_payment_levels_rec.periods IS NOT NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.periods IS NOT NULL AND p_payment_levels_rec.periods IS NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.periods <> p_payment_levels_rec.periods) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.stub_days IS NULL AND p_payment_levels_rec.stub_days IS NOT NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.stub_days IS NOT NULL AND p_payment_levels_rec.stub_days IS NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.stub_days <> p_payment_levels_rec.stub_days) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.stub_amount IS NULL AND p_payment_levels_rec.stub_amount IS NOT NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.stub_amount IS NOT NULL AND p_payment_levels_rec.stub_amount IS NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.stub_amount <> p_payment_levels_rec.stub_amount) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.rate IS NULL AND p_payment_levels_rec.rate IS NOT NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.rate IS NOT NULL AND p_payment_levels_rec.rate IS NULL) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.rate <> p_payment_levels_rec.rate) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.payment_structure <> p_payment_levels_rec.payment_structure) THEN
            RETURN TRUE;
        ELSIF(l_lasll_csr_rec.start_date <> p_payment_levels_rec.start_date) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END LOOP;
  END is_lasll_modified;

  -----------------------------------------------------------------------------
  -- PROCEDURE check_redundant_levels
  -----------------------------------------------------------------------------
  PROCEDURE check_redundant_levels (p_payment_levels_tbl IN payment_levels_tbl_type,
                                    p_pricing_method     IN VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2) IS
    l_prev_sll_stub_yn       VARCHAR2(1);
    l_prev_sll_rate          NUMBER;
    l_prev_sll_amount        NUMBER;
    i                        BINARY_INTEGER;
    l_program_name           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'check_redundant_levels';
  BEGIN
    IF p_payment_levels_tbl.COUNT > 0 THEN
      i := p_payment_levels_tbl.FIRST;
      -- level rows are ordered by level start date
      -- upstream validations in place to ensure amount, stub amount and rate cannot be negative
      -- existence of stub days is the definitive indication of a level being
      LOOP
        IF p_payment_levels_tbl.EXISTS(i) THEN
          IF (p_payment_levels_tbl(i).stub_days IS NULL) AND (l_prev_sll_stub_yn = 'N') THEN
            IF p_pricing_method IN ('SY', 'NA') THEN
              IF p_payment_levels_tbl(i).amount = l_prev_sll_amount THEN
                OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                     p_msg_name     => 'OKL_REDUNDANT_PAYMENT_LEVELS');
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            ELSIF p_pricing_method = 'SP' THEN
              IF p_payment_levels_tbl(i).rate = l_prev_sll_rate THEN
                OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                     p_msg_name     => 'OKL_REDUNDANT_PAYMENT_LEVELS2');
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            ELSIF p_pricing_method = 'SM' THEN
              IF (p_payment_levels_tbl(i).rate = l_prev_sll_rate) AND (p_payment_levels_tbl(i).amount = l_prev_sll_amount) THEN
                OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                     p_msg_name     => 'OKL_REDUNDANT_PAYMENT_LEVELS3');
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;
          END IF;
          IF p_payment_levels_tbl(i).stub_days IS NOT NULL THEN
            l_prev_sll_stub_yn := 'Y';
          ELSE
            l_prev_sll_stub_yn := 'N';
          END IF;
          IF p_payment_levels_tbl(i).amount IS NOT NULL THEN
            l_prev_sll_amount := p_payment_levels_tbl(i).amount;
          ELSE
            l_prev_sll_amount := NULL;
          END IF;
          IF p_payment_levels_tbl(i).rate IS NOT NULL THEN
            l_prev_sll_rate := p_payment_levels_tbl(i).rate;
          ELSE
            l_prev_sll_rate := NULL;
          END IF;
          EXIT WHEN (i = p_payment_levels_tbl.LAST);
          i := p_payment_levels_tbl.NEXT(i);
        END IF;
      END LOOP;
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END check_redundant_levels;

  -----------------------------------------------------------------------------
  -- FUNCTION calculate_end_date
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : calculate_end_date
  -- Description     : This function calculates contract end date
  -- Business Rules  :
  -- Parameters      : p_start_date, p_periods, p_frequency
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  FUNCTION calculate_end_date(p_start_date   DATE,
                              p_periods      NUMBER,
                              p_frequency    VARCHAR2) RETURN DATE IS
  CURSOR find_months_per_period_csr(p_frequency VARCHAR2) IS
    SELECT DECODE(p_frequency,'M',1,'Q',3,'S',6,'A',12) months_per_period
    FROM DUAL;
    l_period_end_date   DATE;
  BEGIN
    FOR l_months_per_period_csr IN find_months_per_period_csr(p_frequency => p_frequency)
    LOOP
        l_period_end_date    :=  ADD_MONTHS(p_start_date,(l_months_per_period_csr.months_per_period)*p_periods);
    END LOOP;
    RETURN (l_period_end_date - 1);
  END calculate_end_date;

  -----------------------------------------------------------------------------
  -- PROCEDURE validate_payment_details
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_payment_details
  -- Description     : This Procedure validates the payment details
  --                 : fin_line id and amount of the assets as input
  -- Business Rules  :
  -- Parameters      : p_cle_id, p_chr_id, p_amount, p_asset_id_tbl
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE validate_payment_details(p_api_version           IN NUMBER,
                                     p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2,
                                     p_chr_id                IN         NUMBER,
                                     p_payment_type_id       IN         NUMBER,
                                     p_payment_frequency     IN         VARCHAR2,
                                     p_payment_arrears       IN         VARCHAR2,
                                     p_effective_from_date   IN         DATE,
                                     p_pricing_method        IN         VARCHAR2,
                                     p_pricing_engine        IN         VARCHAR2,
                                     p_payment_levels_tbl    IN         payment_levels_tbl_type,
                                     x_payment_levels_tbl    OUT NOCOPY payment_levels_tbl_type
                                    ) IS
    -- Variables Declarations
    l_api_version           CONSTANT NUMBER DEFAULT 1.0;
    l_api_name              CONSTANT VARCHAR2(30) DEFAULT 'VLD_PMT_DTL';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                       BINARY_INTEGER;
    l_payment_levels_tbl    payment_levels_tbl_type;
    l_level_end_date        DATE;
    l_level_start_date      DATE;
    l_contract_end_date     DATE;
    l_term                  NUMBER;
    l_mpp                   NUMBER;
    l_missing_count         NUMBER := 0;
    l_stub_count            NUMBER := 0;
  BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_payment_levels_tbl := p_payment_levels_tbl;
    SELECT end_date,
           term_duration
    INTO   l_contract_end_date,
           l_term
    FROM   okc_k_headers_b chr,
           okl_k_headers khr
    WHERE  chr.id = p_chr_id
    AND    chr.id = khr.id;
    SELECT DECODE(p_payment_frequency, 'A', 12, 'S', 6, 'Q', 3, 'M', 1)
    INTO   l_mpp
    FROM   dual;
    ----------------------------------------------------------------------------------------------
    -- Explanation of validations available in file 'SO Error Messages.xls' (see reference number)
    ----------------------------------------------------------------------------------------------
    -- 1.
    IF (p_payment_type_id IS NOT NULL AND p_payment_levels_tbl.COUNT = 0) OR
       (p_pricing_method <> 'NA' AND p_payment_levels_tbl.COUNT = 0) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LEVEL_REQD_LEVELS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 2.
    IF (p_payment_type_id IS NULL AND p_payment_levels_tbl.COUNT > 0) THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LEVEL_REQD_PAYMENTTYPE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 12.
    IF p_pricing_method = 'TR' THEN
      IF TRUNC(l_term / l_mpp) <> (l_term / l_mpp) THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_TERM_FREQ_MISMATCH');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF (p_payment_levels_tbl.COUNT > 0) THEN
      i                  := p_payment_levels_tbl.FIRST;
      l_level_start_date := p_effective_from_date;
      LOOP
        -- 16.
        IF (p_payment_levels_tbl(i).periods IS NOT NULL) AND (p_payment_levels_tbl(i).periods <= 0) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_PERIOD_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 17.
        IF (p_payment_levels_tbl(i).periods IS NOT NULL) AND
           (TRUNC(p_payment_levels_tbl(i).periods) <> p_payment_levels_tbl(i).periods) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_PERIOD_FRACTION');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 18.
        IF (p_payment_levels_tbl(i).stub_days IS NOT NULL) AND (p_payment_levels_tbl(i).stub_days <= 0) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_STUBDAYS_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 19.
        IF (p_payment_levels_tbl(i).stub_days IS NOT NULL) AND
           (TRUNC(p_payment_levels_tbl(i).stub_days) <> p_payment_levels_tbl(i).stub_days) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_STUBDAYS_FRACTION');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 20.
        IF (p_payment_levels_tbl(i).amount IS NOT NULL) AND (p_payment_levels_tbl(i).amount < 0) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_AMOUNT_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 21.
        IF (p_payment_levels_tbl(i).stub_amount IS NOT NULL) AND (p_payment_levels_tbl(i).stub_amount < 0) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_STUBAMT_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 22.

       --  04-Nov-2009 sechawla 9001225 : removed the validation
      /*  IF (p_payment_levels_tbl(i).rate IS NOT NULL) AND (p_payment_levels_tbl(i).rate <= 0) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_RATE_ZERO');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        */
        -- 3.
        IF (p_pricing_engine = 'I') AND (i <> p_payment_levels_tbl.FIRST) AND
           (p_payment_levels_tbl(i).stub_days IS NOT NULL OR p_payment_levels_tbl(i).stub_amount IS NOT NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_PLANSTUB_NA');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        /* -- Commented by gboomina for Bug#6869998
	-- 4.
        -- Validation : To check if payment structure has stub line at other than first position
	IF (p_pricing_engine = 'NA') AND (i <> p_payment_levels_tbl.FIRST) AND
           (p_payment_levels_tbl(i).stub_days IS NOT NULL OR p_payment_levels_tbl(i).stub_amount IS NOT NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_STUB_NA');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        */
        -- 5.
        IF (p_pricing_method IN ('SP', 'SM') AND p_payment_levels_tbl(i).rate IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_REQD_RATE');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 6.
        IF (p_payment_levels_tbl(i).stub_days IS NULL) AND (p_payment_levels_tbl(i).periods IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_NO_STUB_AND_PER');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 7.
        IF (p_payment_levels_tbl(i).stub_days IS NOT NULL) AND (p_payment_levels_tbl(i).periods IS NOT NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_BOTH_STUB_AND_PER');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 8.
        IF (p_payment_levels_tbl(i).stub_amount IS NOT NULL) AND (p_payment_levels_tbl(i).stub_days IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_STUBAMT_WO_DAYS');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 9.
        IF (p_payment_levels_tbl(i).amount IS NOT NULL) AND (p_payment_levels_tbl(i).periods IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_AMOUNT_WO_PERIODS');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- 10.
        IF (p_pricing_method IN ('SY', 'NA') AND p_payment_levels_tbl(i).amount IS NULL AND
            p_payment_levels_tbl(i).stub_days IS NULL) THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LEVEL_REQD_AMOUNT');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (p_payment_levels_tbl(i).stub_days IS NOT NULL AND p_payment_levels_tbl(i).stub_amount IS NULL) THEN
          l_missing_count := l_missing_count + 1;
        END IF;
        IF (p_payment_levels_tbl(i).stub_days IS NULL AND p_payment_levels_tbl(i).amount IS NULL) THEN
          l_missing_count := l_missing_count + 1;
        END IF;
        IF p_payment_levels_tbl(i).stub_days IS NOT NULL THEN
          l_stub_count := l_stub_count + 1;
        END IF;
        IF (l_payment_levels_tbl(i).stub_days IS NULL) THEN
          l_level_end_date := calculate_end_date(p_start_date => l_level_start_date,
                                                 p_periods    => l_payment_levels_tbl(i).periods,
                                                 p_frequency  => p_payment_frequency);
        ELSE
          l_level_end_date := l_level_start_date + l_payment_levels_tbl(i).stub_days - 1;
        END IF;
        l_payment_levels_tbl(i).start_date := l_level_start_date;
        l_level_start_date                 := l_level_end_date + 1;
        EXIT WHEN (i = l_payment_levels_tbl.LAST);
        i := l_payment_levels_tbl.NEXT(i);
      END LOOP;
      -- 15.
      IF (l_stub_count = p_payment_levels_tbl.COUNT) THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LEVEL_ALL_STUBS');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- 11.
      IF l_level_end_date > l_contract_end_date THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LEVEL_EXTENDS_K_END');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    x_payment_levels_tbl := l_payment_levels_tbl;
     x_return_status := okc_api.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END validate_payment_details;

  -----------------------------------------------------------------------------
  -- PROCEDURE create_payment_plans
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_payment_plans
  -- Description     : This procedure creates  the payment lines
  -- Business Rules  :
  -- Parameters      : p_cle_id,p_chr_id,p_payment_arrears,p_payment_type_id
  --                 : p_payment_levels_tbl
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE create_payment_plans(p_api_version                  IN         NUMBER,
                                        p_init_msg_list         IN         VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                        p_transaction_control   IN         VARCHAR2 DEFAULT OKL_API.G_TRUE,
                                        p_cle_id                IN         NUMBER,
                                        p_chr_id                IN         NUMBER,
                                        p_payment_type_id       IN         NUMBER,
                                        p_payment_frequency     IN         VARCHAR2,
                                        p_payment_arrears       IN         VARCHAR2,
                                        p_payment_structure     IN         VARCHAR2 DEFAULT NULL,
                                        p_rate_type             IN         VARCHAR2 DEFAULT NULL,
                                        p_payment_levels_tbl    IN         payment_levels_tbl_type,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_msg_count             OUT NOCOPY NUMBER,
                                        x_msg_data              OUT NOCOPY VARCHAR2) IS
    -- Variables Declarations
    l_api_version               CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) DEFAULT 'CRT_PMT_PLN';
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_payment_levels_tbl        payment_levels_tbl_type;
    l_laslh_rec                 okc_rule_pub.rulv_rec_type;
    l_lasll_rec                 okc_rule_pub.rulv_rec_type;
    lx_rgpv_rec                 okc_rule_pub.rgpv_rec_type;
    lx_rulv_rec                 okc_rule_pub.rulv_rec_type;
    line_number                 NUMBER := 0;
    l_laslh_id                  NUMBER;
    l_rgp_id                    NUMBER := NULL;
    l_start_date                DATE;
    l_lty_code                  VARCHAR2(30);
    l_pricing_method            VARCHAR2(2)  := 'NA';
    l_pricing_engine            VARCHAR2(2)  := 'NA';
    l_rgrp_id                   OKC_RULE_GROUPS_V.ID%TYPE := OKL_API.G_MISS_NUM;
  CURSOR find_payment_hdr_csr IS
    SELECT id
    FROM okc_rule_groups_b
    WHERE rgd_code = 'LALEVL' AND cle_id = p_cle_id;
  CURSOR find_laslh_dtls_csr(p_rgp_id NUMBER) IS
    SELECT id, object1_id1 payment_type_id, rule_information2 rate_type
    FROM okc_rules_b
    WHERE rgp_id = p_rgp_id AND rule_information_category = 'LASLH';
  CURSOR RGP_CLE_CSR(P_CHR_ID IN NUMBER, P_CLE_ID  IN NUMBER)IS
    SELECT
    ID
    FROM OKC_RULE_GROUPS_V RG WHERE
    RG.DNZ_CHR_ID = P_CHR_ID AND RG.CHR_ID IS NULL
    AND RGD_CODE = 'LALEVL'
    AND RG.CLE_ID = P_CLE_ID;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT lse.lty_code
    INTO   l_lty_code
    FROM   okc_k_lines_b cle,
          okc_line_styles_b lse
    WHERE  cle.id = p_cle_id
    AND    cle.lse_id = lse.id;

    IF l_lty_code = 'SO_PAYMENT' THEN
      SELECT pricing_method_code,
             pricing_engine_code
      INTO   l_pricing_method,
             l_pricing_engine
      FROM   okl_so_plan_details_uv
      WHERE  payment_plan_id = p_cle_id;
    END IF;
    IF(p_payment_type_id IS NOT NULL) THEN
        OPEN  RGP_CLE_CSR(p_chr_id, p_cle_id);
        FETCH RGP_CLE_CSR into l_rgrp_id;
        CLOSE RGP_CLE_CSR;
        IF(l_rgrp_id IS NULL OR l_rgrp_id = OKL_API.G_MISS_NUM) THEN
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_rule_group'
           ,'begin debug  call create_rule_group');
          END IF;
          -- call create rule group
          create_rule_group(p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_cle_id         =>  p_cle_id,
                            p_chr_id         =>  p_chr_id,
                            p_rgd_code       =>  'LALEVL',
                            x_rgp_id         =>  l_rgp_id);
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_rule_group'
           ,'end debug  call create_rule_group');
          END IF;
         IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       ELSE
        l_rgp_id := l_rgrp_id;
       END IF;
    END IF;
    IF(p_payment_type_id IS NOT NULL) THEN
        -- create rule for payment type
        -- populate defaults and mandatory fields
        populate_rule_record(p_chr_id       =>  p_chr_id,
                             p_rgp_id       =>  l_rgp_id,
                             p_rule_name    =>  'LASLH',
                             x_rulv_rec     =>  l_laslh_rec);
        l_laslh_rec.object1_id1                 :=  p_payment_type_id;
        l_laslh_rec.object1_id2                 :=  '#';
        l_laslh_rec.jtot_object1_code           :=  'OKL_STRMTYP';
        l_laslh_rec.rule_information2           :=  p_rate_type;

        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okc_rule_pub.create_rule'
         ,'begin debug  call create_rule');
        END IF;
        -- create rule for LASLH (payment header)
        okc_rule_pub.create_rule(p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 x_return_status => l_return_status,
                                 p_rulv_rec      => l_laslh_rec,
                                 x_rulv_rec      => lx_rulv_rec);
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okc_rule_pub.create_rule'
         ,'end debug  call create_rule');
        END IF;
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    l_laslh_id  :=  lx_rulv_rec.id;
    END IF;
    IF (p_payment_levels_tbl.COUNT > 0) THEN
      SELECT start_date INTO l_start_date FROM okc_k_lines_b where id = p_cle_id;

      IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.validate_payment_details'
         ,'begin debug  call validate_payment_details');
      END IF;
      validate_payment_details(p_api_version              => p_api_version,
                               p_init_msg_list	           => p_init_msg_list,
                               x_return_status 	          => x_return_status,
                               x_msg_count     	          => x_msg_count,
                               x_msg_data      	          => x_msg_data,
                               p_chr_id                   => p_chr_id,
                               p_payment_type_id          => p_payment_type_id,
                               p_payment_frequency        => p_payment_frequency,
                               p_payment_arrears          => p_payment_arrears,
                               p_effective_from_date      => l_start_date,
                               p_pricing_method           => l_pricing_method,
                               p_pricing_engine           => l_pricing_engine,
                               p_payment_levels_tbl       => p_payment_levels_tbl,
                               x_payment_levels_tbl       => l_payment_levels_tbl
                              );
      IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.validate_payment_details'
         ,'end debug  call validate_payment_details');
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      check_redundant_levels(p_payment_levels_tbl => l_payment_levels_tbl,
                             p_pricing_method     => l_pricing_method,
                             x_return_status      => l_return_status);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
        line_number          := l_payment_levels_tbl.FIRST;
        FOR line_number IN l_payment_levels_tbl.FIRST..l_payment_levels_tbl.LAST
        LOOP
             IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.populate_rule_record'
              ,'begin debug  call populate_rule_record');
             END IF;
            -- populate the defaults and mandatory fields
            populate_rule_record(p_chr_id       =>  p_chr_id,
                                 p_rgp_id       =>  l_rgp_id,
                                 p_rule_name    =>  'LASLL',
                                 x_rulv_rec     =>  l_lasll_rec);
            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.populate_rule_record'
              ,'end debug  call populate_rule_record');
            END IF;

            l_lasll_rec.object1_id1                 :=  p_payment_frequency;
            l_lasll_rec.object1_id2                 :=  '#';
            l_lasll_rec.jtot_object1_code           :=  'OKL_TUOM';
            l_lasll_rec.object2_id1                 :=  l_laslh_id;
            l_lasll_rec.object2_id2                 :=  '#';
            l_lasll_rec.jtot_object2_code           :=  'OKL_STRMHDR';
            l_lasll_rec.rule_information3           :=  l_payment_levels_tbl(line_number).periods;
            l_lasll_rec.rule_information6           :=  l_payment_levels_tbl(line_number).amount;
            l_lasll_rec.rule_information10          :=  p_payment_arrears;
            l_lasll_rec.rule_information5           :=  NVL(p_payment_structure, '0');
            l_lasll_rec.rule_information13          :=  l_payment_levels_tbl(line_number).rate;
            l_lasll_rec.rule_information2           :=  fnd_date.date_to_canonical(l_payment_levels_tbl(line_number).start_date);
            -- stub information will be null except for the first line ( validation done before)
            l_lasll_rec.rule_information7           :=  l_payment_levels_tbl(line_number).stub_days;
            l_lasll_rec.rule_information8           :=  l_payment_levels_tbl(line_number).stub_amount;

            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okc_rule_pub.create_rule'
              ,'begin debug  call create_rule');
            END IF;
            okc_rule_pub.create_rule(p_api_version    => p_api_version,
                                     p_init_msg_list  => p_init_msg_list,
                                     x_return_status  => x_return_status,
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_rulv_rec       => l_lasll_rec,
                                     x_rulv_rec       => lx_rulv_rec);
            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okc_rule_pub.create_rule'
              ,'end debug  call create_rule');
            END IF;
           IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        END LOOP; -- end of payment_level_table
    END IF; -- if payment_level_tbl has any records
    x_return_status := okc_api.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_payment_plans;
 -------------------------------------------------------------------------------
  -- PROCEDURE create_link_assets
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_link_assets
  -- Description     : This procedure is a wrapper that creates assets linked with fee/service
  --
  -- Business Rules  : This procedure is a wrapper that creates assets linked with fee/service
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --                   04-Jan-2008 RRAVIKIR modified for Bug#6707125 for correct allocation of
  --                                        amount to associated assets of a Fee Line
  -- End of comments
  PROCEDURE create_link_assets (p_api_version                   IN  NUMBER,
                                p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status                 OUT NOCOPY VARCHAR2,
                                x_msg_count                     OUT NOCOPY NUMBER,
                                x_msg_data                      OUT NOCOPY VARCHAR2,
                                p_cle_id                        IN  NUMBER,
                                p_chr_id                        IN  NUMBER,
                                p_capitalize_yn                 IN  VARCHAR2,
                                p_qte_fee_srv_id                IN  NUMBER,
                                --p_derive_assoc_amt              IN  VARCHAR2, -- Commented by rravikir for Bug#6707125
                                p_line_type                     IN  VARCHAR2) IS
    -- Variables Declarations
    l_api_version               CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                  CONSTANT VARCHAR2(30) DEFAULT 'CRT_LNK_AST';
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled             VARCHAR2(10);
    l_create_line_item_tbl      okl_contract_line_item_pvt.line_item_tbl_type;
    l_update_line_item_tbl      okl_contract_line_item_pvt.line_item_tbl_type;
    lx_line_item_tbl            okl_contract_line_item_pvt.line_item_tbl_type;
    l_link_asset_tbl            link_asset_tbl_type;
    k                           BINARY_INTEGER  := 1;  -- create table index
    m                           BINARY_INTEGER  := 1;  -- update table index
    i                           NUMBER := 0;
    l_line_amount               NUMBER;
    l_asset_oec                 NUMBER;
    l_oec_total                 NUMBER       := 0;
    l_assoc_amount              NUMBER;
    l_assoc_total               NUMBER       := 0;
    l_currency_code             VARCHAR2(15);
    l_compare_amt               NUMBER;
    l_diff                      NUMBER;
    l_adj_rec                   BINARY_INTEGER;
    lx_return_status            VARCHAR2(1);
    --Cursor declaration
    --Get the assets details linked with fee lines
    CURSOR c_fee_srv_asset_dtls(lp_fee_srv_id OKL_FEES_B.ID%TYPE) IS
      SELECT olrb.SOURCE_LINE_ID,
             olrb.amount
      FROM   okl_line_relationships_b olrb

      WHERE  olrb.RELATED_LINE_ID = lp_fee_srv_id
      AND    olrb.RELATED_LINE_TYPE = p_line_type
      AND    olrb.SOURCE_LINE_TYPE= 'ASSET';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT NVL(amount, 0)
    INTO   l_line_amount
    FROM   okl_k_lines
    WHERE  id = p_cle_id;

    SELECT currency_code
    INTO   l_currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    FOR l_fee_srv_asset_rec IN c_fee_srv_asset_dtls(p_qte_fee_srv_id) loop
        i:=i+1;
        l_link_asset_tbl(i).fin_asset_id := get_fin_line_id(l_fee_srv_asset_rec.SOURCE_LINE_ID);
        l_link_asset_tbl(i).amount:= l_fee_srv_asset_rec.amount;

    END LOOP;
    IF (l_link_asset_tbl.COUNT > 0) THEN
    ------------------------------------------------------------------
    -- 1. Loop through to get OEC total of all assets being associated
    ------------------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP
        IF l_link_asset_tbl.EXISTS(i) THEN

          SELECT NVL(oec, 0)
          INTO   l_asset_oec
          FROM   okl_k_lines
          WHERE  id = l_link_asset_tbl(i).fin_asset_id;
          l_oec_total := l_oec_total + l_asset_oec;
        END IF;
      END LOOP;
      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts
      ----------------------------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP
        IF l_link_asset_tbl.EXISTS(i) THEN

          /*
          -- Start : Commented by rravikir for Bug#6707125

          IF p_derive_assoc_amt = 'N' THEN
            l_assoc_amount := l_link_asset_tbl(i).amount;
          ELSIF l_oec_total = 0 THEN
            l_assoc_amount := l_line_amount / l_link_asset_tbl.COUNT;
          ELSE

            -- LLA APIs ensure asset OEC and line amount are rounded
            SELECT NVL(oec, 0)
            INTO   l_asset_oec
            FROM   okl_k_lines
            WHERE  id = l_link_asset_tbl(i).fin_asset_id;
            IF l_link_asset_tbl.COUNT = 1 THEN
              l_assoc_amount := l_line_amount;
            ELSE
              l_assoc_amount := l_line_amount * l_asset_oec / l_oec_total;
            END IF;
          END IF;
          l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                             p_currency_code => l_currency_code);

          -- End : Commented by rravikir for Bug#6707125
          */
		  l_assoc_amount := l_link_asset_tbl(i).amount;       -- Added by rravikir for Bug#6707125
          l_assoc_total := l_assoc_total + l_assoc_amount;

		  -- l_link_asset_tbl(i).amount := l_assoc_amount;	  -- Commented by rravikir for Bug#6707125
        END IF;
      END LOOP;
      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_line_amount THEN
        l_diff := ABS(l_assoc_total - l_line_amount);
        FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP
          IF l_link_asset_tbl.EXISTS(i) THEN
            -- if the total split amount is less than line amount add the difference amount to the
            -- asset with less amount and if the total split amount is greater than the line amount
            -- than subtract the difference amount from the asset with highest amount
            IF i = l_link_asset_tbl.FIRST THEN
              l_adj_rec     := i;
              l_compare_amt := l_link_asset_tbl(i).amount;
            ELSIF (l_assoc_total < l_line_amount) AND (l_link_asset_tbl(i).amount <= l_compare_amt) OR
                  (l_assoc_total > l_line_amount) AND (l_link_asset_tbl(i).amount >= l_compare_amt) THEN
                l_adj_rec     := i;
                l_compare_amt := l_link_asset_tbl(i).amount;
            END IF;
          END IF;
        END LOOP;
        IF l_assoc_total < l_line_amount THEN
          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount + l_diff;
        ELSE
          l_link_asset_tbl(l_adj_rec).amount := l_link_asset_tbl(l_adj_rec).amount - l_diff;
        END IF;
      END IF;
      ------------------------------------------------------
      -- 4. Prepare arrays to pass to create and update APIs
      ------------------------------------------------------
      FOR i IN l_link_asset_tbl.FIRST .. l_link_asset_tbl.LAST LOOP
        IF l_link_asset_tbl.EXISTS(i) THEN
          l_assoc_amount := l_link_asset_tbl(i).amount;
          l_create_line_item_tbl(k).chr_id            := p_chr_id;
          l_create_line_item_tbl(k).parent_cle_id     := p_cle_id;
          l_create_line_item_tbl(k).item_id1          := l_link_asset_tbl(i).fin_asset_id;
          l_create_line_item_tbl(k).item_id2          := '#';
          l_create_line_item_tbl(k).item_object1_code := 'OKX_COVASST';
          l_create_line_item_tbl(k).serv_cov_prd_id   := NULL;

            SELECT txl.asset_number
            INTO   l_create_line_item_tbl(k).name
            FROM   okc_k_lines_b cle,
                   okc_line_styles_b lse,
                   okl_txl_assets_b txl
            WHERE  cle.id = txl.kle_id
            AND    cle.lse_id = lse.id
            AND    lse.lty_code = 'FIXED_ASSET'
            AND    cle.cle_id = l_link_asset_tbl(i).fin_asset_id;
          -- The linked amount is always passed in as 'capital_amount' even though capital amount
          -- is applicable only for CAPITALIZED fee types.  The LLA API will ensure that
          -- the linked amount is stored in the appropriate column (AMOUNT vs CAPITAL_AMOUNT)
          l_create_line_item_tbl(k).capital_amount := l_assoc_amount;
          k := k + 1;
        END IF;
      END LOOP;
      IF l_create_line_item_tbl.COUNT > 0 THEN
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_contract_line_item_pvt.create_contract_line_item'
         ,'begin debug call create_contract_line_item');
        END IF;
        okl_contract_line_item_pvt.create_contract_line_item( p_api_version       => p_api_version,
                                                              p_init_msg_list     => p_init_msg_list,
                                                              x_return_status     => x_return_status,
                                                              x_msg_count         => x_msg_count,
                                                              x_msg_data          => x_msg_data,
                                                              p_line_item_tbl     => l_create_line_item_tbl,
                                                              x_line_item_tbl     => lx_line_item_tbl);
        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_contract_line_item_pvt.create_contract_line_item'
         ,'end debug call create_contract_line_item');
        END IF;
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;
   x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
   EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             p_api_name  => l_api_name,
                             p_pkg_name  => G_PKG_NAME,
                             p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data,
                             p_api_type  => G_API_TYPE);
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             p_api_name  => l_api_name,
                             p_pkg_name  => G_PKG_NAME,
                             p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data,
                             p_api_type  => G_API_TYPE);
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             p_api_name  => l_api_name,
                             p_pkg_name  => G_PKG_NAME,
                             p_exc_name  => 'OTHERS',
                             x_msg_count => x_msg_count,
                             x_msg_data  => x_msg_data,
                             p_api_type  => G_API_TYPE);
  END create_link_assets;
  -----------------------------------------------------------------------------
  -- PROCEDURE create_expense_dtls
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_expense_dtls
  -- Description     : This procedure creates fee/service expense details
  -- Business Rules  :
  -- Parameters      : p_periods, p_periodic_amount, p_exp_frequency
  --                 : p_cle_id, p_chr_id
  -- Version         : 1.0
  -- History         :  20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE create_expense_dtls(p_api_version                  IN NUMBER,
                                p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_count                    OUT NOCOPY NUMBER,
                                x_msg_data                     OUT NOCOPY VARCHAR2,
                                p_cle_id                       IN         NUMBER,
                                p_chr_id                       IN         NUMBER,
                                p_periods                      IN         NUMBER,
                                p_periodic_amount              IN         NUMBER,
                                p_exp_frequency                IN         VARCHAR2) IS
   -- Variables Declarations
    l_api_version CONSTANT      NUMBER DEFAULT 1.0;
    l_api_name CONSTANT         VARCHAR2(30) DEFAULT 'CRT_EXT_DTL';
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled             VARCHAR2(10);
    lx_return_status            VARCHAR2(1);
    lx_rulv_rec                 okc_rule_pub.rulv_rec_type;
    l_lafreq_rec                okc_rule_pub.rulv_rec_type;
    l_lafexp_rec                okc_rule_pub.rulv_rec_type;
    l_rgp_id                    NUMBER;
    -- find the LAFEXP rule group id
    CURSOR find_fexprg_csr IS
      SELECT id
      FROM okc_rule_groups_b
      WHERE rgd_code = 'LAFEXP' AND cle_id = p_cle_id;
    -- find the rule information for LAFEXP
    CURSOR find_lafexp_dtls_csr(p_rgp_id NUMBER) IS
      SELECT id, rule_information1 periods, rule_information2 periodic_amount
      FROM okc_rules_b
      WHERE rgp_id = p_rgp_id AND rule_information_category = 'LAFEXP';
    -- find the rule information for LAFREQ
    CURSOR find_lafreq_dtls_csr(p_rgp_id NUMBER) IS
      SELECT id, object1_id1 frequency
      FROM okc_rules_b
      WHERE rgp_id = p_rgp_id AND rule_information_category = 'LAFREQ';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lafexprg_csr_rec IN find_fexprg_csr
    LOOP
        l_rgp_id := l_lafexprg_csr_rec.id;
    END LOOP;
    IF(l_rgp_id IS NULL) THEN
        -- create rule group for service expenses
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_rule_group'
           ,'begin debug  call create_rule_group');
        END IF;
        create_rule_group(p_api_version    => p_api_version,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_cle_id           =>  p_cle_id,
                          p_chr_id           =>  p_chr_id,
                          p_rgd_code         =>  'LAFEXP',
                          x_rgp_id           =>  l_rgp_id);
      IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_rule_group'
           ,'end debug  call create_rule_group');
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of creating rule group
    -- create rule for frequency
    -- populate defaults and mandatory fields
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.populate_rule_record'
       ,'begin debug  call populate_rule_record');
    END IF;
    populate_rule_record(p_chr_id       =>  p_chr_id,
                         p_rgp_id       =>  l_rgp_id,
                         p_rule_name    =>  'LAFREQ',
                         x_rulv_rec     =>  l_lafreq_rec);
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.populate_rule_record'
       ,'end debug  call populate_rule_record');
    END IF;
    l_lafreq_rec.object1_id1                :=  p_exp_frequency;
    l_lafreq_rec.object1_id2                :=  '#';
    l_lafreq_rec.jtot_object1_code          :=  'OKL_TUOM';
    -- create the rule
    IF(l_lafreq_rec.id IS NULL OR l_lafreq_rec.id = OKL_API.G_MISS_NUM) THEN
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsqlokc_rule_pub.create_rule'
         ,'begin debug  call create_rule');
       END IF;
       okc_rule_pub.create_rule(p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_rulv_rec      => l_lafreq_rec,
                                x_rulv_rec      => lx_rulv_rec);
        IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsqlokc_rule_pub.create_rule'
         ,'end debug  call create_rule');
        END IF;
       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF; -- end of create
    -- populate defaults and mandatory fields
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.populate_rule_record'
       ,'begin debug  call creatpopulate_rule_record');
    END IF;
    populate_rule_record(p_chr_id       =>  p_chr_id,
                         p_rgp_id       =>  l_rgp_id,
                         p_rule_name    =>  'LAFEXP',
                         x_rulv_rec     =>  l_lafexp_rec);
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.populate_rule_record'
       ,'end debug  call creatpopulate_rule_record');
    END IF;
    l_lafexp_rec.rule_information1          :=  p_periods;
    l_lafexp_rec.rule_information2          :=  p_periodic_amount;
     -- create the rule
    IF(l_lafexp_rec.id IS NULL  OR l_lafexp_rec.id = OKL_API.G_MISS_NUM) THEN
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsqlokc_rule_pub.create_rule'
         ,'begin debug  call create_rule');
       END IF;
       okc_rule_pub.create_rule(p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_rulv_rec       => l_lafexp_rec,
                                x_rulv_rec       => lx_rulv_rec);
      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsqlokc_rule_pub.create_rule'
         ,'end debug  call create_rule');
      END IF;
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of create
    x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_expense_dtls;
  -----------------------------------------------------------------------------
  -- PROCEDURE create_insurance_lines
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_insurance_lines
  -- Description     : This procedure creates third part insurance policy
  --                 : associated with lease application
  -- Business Rules  :
  -- Parameters      : p_chr_id
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE create_insurance_lines (p_api_version                  IN NUMBER,
                                    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status                OUT NOCOPY VARCHAR2,
                                    x_msg_count                    OUT NOCOPY NUMBER,
                                    x_msg_data                     OUT NOCOPY VARCHAR2,
                                    p_chr_id                       IN NUMBER) IS
    -- Variables Declarations
    l_api_version CONSTANT      NUMBER DEFAULT 1.0;
    l_api_name CONSTANT         VARCHAR2(30) DEFAULT 'CRT_INS_LNS';
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled             VARCHAR2(10);

    x_ipyv_rec                  ipyv_rec_type;
   BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- set the org id and organization id
    OKL_CONTEXT.set_okc_org_context(p_chr_id => p_chr_id);
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_INS_QUOTE_PVT.lseapp_thrdprty_to_ctrct'
       ,'begin debug OKLRINQB.pls call lseapp_thrdprty_to_ctrct');
    END IF;
    OKL_INS_QUOTE_PVT.lseapp_thrdprty_to_ctrct(
                          p_api_version       => p_api_version,
                          p_init_msg_list     => p_init_msg_list,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          p_lakhr_id          => p_chr_id,
                          x_ipyv_rec          => x_ipyv_rec);
    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_INS_QUOTE_PVT.lseapp_thrdprty_to_ctrct'
       ,'end debug OKLRINQB.pls call lseapp_thrdprty_to_ctrct');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := okc_api.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_insurance_lines;

  -----------------------------------------------------------------------------
  -- PROCEDURE create_service_lines
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_service_lines
  -- Description     : This procedure creates service header and other lines
  --                 : associated with it
  -- Business Rules  :
  -- Parameters      : p_quote_fee_rec, p_payment_levels_tbl, p_asset_id_tbl
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE create_service_lines (p_api_version                  IN NUMBER,
                                  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status                OUT NOCOPY VARCHAR2,
                                  x_msg_count                    OUT NOCOPY NUMBER,
                                  x_msg_data                     OUT NOCOPY VARCHAR2,
                                  p_quote_id                     IN  NUMBER,
                                  p_chr_id                       IN NUMBER) IS
    -- Variables Declarations
    l_api_version CONSTANT      NUMBER DEFAULT 1.0;
    l_api_name CONSTANT         VARCHAR2(30) DEFAULT 'SRT_SER_LNS';
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled             VARCHAR2(10);
    l_klev_rec                  okl_kle_pvt.klev_rec_type;
    lx_klev_rec                 okl_kle_pvt.klev_rec_type;
    l_clev_rec                  okl_okc_migration_pvt.clev_rec_type;
    lx_clev_rec                 okl_okc_migration_pvt.clev_rec_type;
    l_cimv_rec                  okl_okc_migration_pvt.cimv_rec_type;
    lx_cimv_rec                 okl_okc_migration_pvt.cimv_rec_type;
    l_cplv_rec                  okl_okc_migration_pvt.cplv_rec_type;
    lx_cplv_rec                 okl_okc_migration_pvt.cplv_rec_type;
    l_quote_service_rec         quote_service_rec_type;
    line_number                 NUMBER := 0;
    lx_chr_id                   NUMBER;
    lx_cle_id                   NUMBER;
    --l_derive_assoc_amt          VARCHAR2(1); -- Commented by rravikir for Bug#6707125
    lx_return_status            VARCHAR2(1);
    l_periods                   NUMBER;
    l_periodic_amount           NUMBER;
    l_exp_frequency             VARCHAR2(1);
    l_cle_id                    NUMBER;
    l_pymnt_counter             NUMBER := 0;
    l_exp_counter               NUMBER := 0;
    l_payment_levels_tbl        payment_levels_tbl_type;
    l_expense_levels_tbl        payment_levels_tbl_type;

    CURSOR c_get_service_dtls(p_qte_id okl_lease_quotes_b.ID%TYPE) IS
      SELECT ID,
             INV_ITEM_ID,
             EFFECTIVE_FROM,
             SUPPLIER_ID
      FROM  okl_services_b osb
      WHERE osb.PARENT_OBJECT_CODE = 'LEASEQUOTE'
      AND   osb.PARENT_OBJECT_ID = p_qte_id;

    --Get service payment details
    CURSOR c_get_service_payment_dtls(p_service_id okl_fees_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_SERVICES_B'
    AND    cfo.SOURCE_ID =  p_service_id
    AND    ocf.cft_code = 'PAYMENT_SCHEDULE'
     -- sechawla 05-nov-09 Bug 9044309
    ORDER BY
    cfl.START_DATE;
    -- sechawla 05-nov-09 End Bug 9044309


    --Get service expense details
    CURSOR c_get_service_expense_dtls(p_service_id okl_fees_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_SERVICES_B'
    AND    cfo.SOURCE_ID =  p_service_id
    AND    ocf.cft_code = 'OUTFLOW_SCHEDULE';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- set the org id and organization id
    OKL_CONTEXT.set_okc_org_context(p_chr_id => p_chr_id);
    FOR l_quote_service_rec IN c_get_service_dtls(p_quote_id)LOOP
       l_pymnt_counter := 0;
       l_payment_levels_tbl.DELETE;
       FOR l_service_payment_rec IN c_get_service_payment_dtls(l_quote_service_rec.ID) LOOP
         l_payment_levels_tbl(l_pymnt_counter).START_DATE      := l_service_payment_rec.START_DATE;
         l_payment_levels_tbl(l_pymnt_counter).PERIODS         := l_service_payment_rec.NUMBER_OF_PERIODS;
         l_payment_levels_tbl(l_pymnt_counter).AMOUNT          := l_service_payment_rec.AMOUNT;
         l_payment_levels_tbl(l_pymnt_counter).STUB_DAYS       := l_service_payment_rec.STUB_DAYS;
         l_payment_levels_tbl(l_pymnt_counter).STUB_AMOUNT     := l_service_payment_rec.STUB_AMOUNT;
         l_payment_levels_tbl(l_pymnt_counter).PAYMENT_TYPE_ID := l_service_payment_rec.PAYMENT_TYPE_ID;
         l_payment_levels_tbl(l_pymnt_counter).FREQUENCY_CODE  := l_service_payment_rec.FREQUENCY_CODE;
         l_payment_levels_tbl(l_pymnt_counter).ARREARS_YN      := l_service_payment_rec.ARREARS_YN;
         l_pymnt_counter := l_pymnt_counter + 1;
       END LOOP;
       l_exp_counter := 0;
       l_expense_levels_tbl.DELETE;
       FOR l_service_expense_rec IN c_get_service_expense_dtls(l_quote_service_rec.ID) LOOP
         l_expense_levels_tbl(l_exp_counter).START_DATE      := l_service_expense_rec.START_DATE;
         l_expense_levels_tbl(l_exp_counter).PERIODS         := l_service_expense_rec.NUMBER_OF_PERIODS;
         l_expense_levels_tbl(l_exp_counter).AMOUNT          := l_service_expense_rec.AMOUNT;
         l_expense_levels_tbl(l_exp_counter).STUB_DAYS       := l_service_expense_rec.STUB_DAYS;
         l_expense_levels_tbl(l_exp_counter).STUB_AMOUNT     := l_service_expense_rec.STUB_AMOUNT;
         l_expense_levels_tbl(l_exp_counter).PAYMENT_TYPE_ID := l_service_expense_rec.PAYMENT_TYPE_ID;
         l_expense_levels_tbl(l_exp_counter).FREQUENCY_CODE  := l_service_expense_rec.FREQUENCY_CODE;
         l_expense_levels_tbl(l_exp_counter).ARREARS_YN      := l_service_expense_rec.ARREARS_YN;
         l_exp_counter := l_exp_counter + 1;
       END LOOP;
       -- assign the values to the respective rec structures
       l_clev_rec.dnz_chr_id       := p_chr_id;
       l_clev_rec.start_date       := l_quote_service_rec.effective_from;
       l_klev_rec.amount           := (l_expense_levels_tbl(0).periods)*(l_expense_levels_tbl(0).amount);
       l_cimv_rec.object1_id1      := l_quote_service_rec.INV_ITEM_ID;
       l_cplv_rec.object1_id1      := l_quote_service_rec.supplier_id;
       -- call process api to create_service_line
       IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SERVICE_LINE_PROCESS_PVT.create_service_line'
        ,'begin debug  call create_service_line');
       END IF;

       OKL_SERVICE_LINE_PROCESS_PVT.create_service_line( p_api_version    => p_api_version,
                                                       p_init_msg_list  => p_init_msg_list,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data,
                                                       p_clev_rec       => l_clev_rec,
                                                       p_klev_rec       => l_klev_rec,
                                                       p_cimv_rec       => l_cimv_rec ,
                                                       p_cplv_rec       => l_cplv_rec,
                                                       x_clev_rec       => lx_clev_rec,
                                                       x_klev_rec       => lx_klev_rec,
                                                       x_cimv_rec       => lx_cimv_rec,
                                                       x_cplv_rec       => lx_cplv_rec);
       IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SERVICE_LINE_PROCESS_PVT.create_service_line'
           ,'end debug  call create_service_line');
       END IF;
       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cle_id  :=  lx_clev_rec.id;
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_link_assets'
         ,'begin debug  call create_link_assets');
       END IF;

       create_link_assets ( p_api_version       => p_api_version,
                          p_init_msg_list     => p_init_msg_list,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          p_cle_id            => l_cle_id,
                          p_chr_id            => p_chr_id,
                          p_capitalize_yn     => 'N',
                          p_qte_fee_srv_id    => l_quote_service_rec.ID,
                          --p_derive_assoc_amt  => l_derive_assoc_amt, -- Commented by rravikir for Bug#6707125
                          p_line_type         => 'SERVICE');
        IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_link_assets'
         ,'end debug  call create_link_assets');
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- method for creating service expense details
        IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_expense_dtls'
           ,'begin debug  call create_expense_dtls');
        END IF;
        create_expense_dtls(p_api_version       => p_api_version,
                          p_init_msg_list     => p_init_msg_list,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          p_cle_id            => l_cle_id,
                          p_chr_id            => p_chr_id,
                          p_periods           => l_expense_levels_tbl(0).periods,
                          p_periodic_amount   => l_expense_levels_tbl(0).amount,
                          p_exp_frequency     => l_expense_levels_tbl(0).frequency_code);
        IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_expense_dtls'
           ,'end debug  call create_expense_dtls');
        END IF;
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- create EPT payment
        IF l_payment_levels_tbl.COUNT > 0 THEN
        IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
           ,'begin debug  call create_payment_plans');
        END IF;
        create_payment_plans(p_api_version             => p_api_version,
                             p_init_msg_list	        => p_init_msg_list,
                             x_return_status 	       => x_return_status,
                             x_msg_count     	       => x_msg_count,
                             x_msg_data         	    => x_msg_data,
                             p_transaction_control   => OKL_API.G_FALSE,
                             p_cle_id                => l_cle_id,
                             p_chr_id                => p_chr_id,
                             p_payment_type_id       => l_payment_levels_tbl(0).payment_type_id,
                             p_payment_frequency     => l_payment_levels_tbl(0).frequency_code,
                             p_payment_arrears       => l_payment_levels_tbl(0).arrears_yn,
                             p_payment_structure     => NULL,
                             p_rate_type             => NULL,
                             p_payment_levels_tbl    => l_payment_levels_tbl);
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
           ,'end debug  call create_payment_plans');
          END IF;
          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
       -- create the party as vendor for the supplier present on the service
       IF l_quote_service_rec.supplier_id IS NOT NULL THEN
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;

             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_chr_id,
                            p_cle_id             => NULL,
                            p_vendor_id          => l_quote_service_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;
             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_chr_id,
                            p_cle_id             => lx_clev_rec.id,
                            p_vendor_id          => l_quote_service_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;

    END LOOP;
    x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_service_lines;
  -------------------------------------------------------------------------------
  -- PROCEDURE create_fee_lines
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_fee_lines
  -- Description     : This procedure is a wrapper that creates contract fee lines from lease application/quote header
  --
  -- Business Rules  : this procedure is used to create a contract fee lines  from lease application/quote header
  --                 : The following details are copied to a Lease Contract from a credit approved Lease Application
  --                 : Lease Application Header fee line details
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_fee_lines(p_api_version                  IN  NUMBER,
                             p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_quote_id                     IN  NUMBER,
                             p_chr_id                       IN  NUMBER) IS
     -- Variables Declarations
    l_api_version CONSTANT      NUMBER DEFAULT 1.0;
    l_api_name CONSTANT         VARCHAR2(30) DEFAULT 'CRT_FEE_LNS';
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled             VARCHAR2(10);
    l_fee_types_rec             okl_maintain_fee_pvt.fee_types_rec_type;
    lx_fee_types_rec            okl_maintain_fee_pvt.fee_types_rec_type;
    l_k_effective_from          DATE;
    l_k_effective_to            DATE;
    l_cle_id                    NUMBER;
    --l_derive_assoc_amt          VARCHAR2(1); -- Commented by rravikir for Bug#6707125
    l_capitalize_yn             VARCHAR2(1)  := 'N';
    lx_return_status            VARCHAR2(1);
    l_periods                   NUMBER;
    l_periodic_amount           NUMBER;
    l_exp_frequency             VARCHAR2(1);
    l_pymnt_counter             NUMBER := 0;
    l_payment_levels_tbl        payment_levels_tbl_type;

    CURSOR c_get_fee_dtls(p_qte_id okl_lease_quotes_b.ID%TYPE) IS
      SELECT ID,
             STREAM_TYPE_ID,
             FEE_TYPE ,
             RATE_CARD_ID,
             RATE_TEMPLATE_ID,
             EFFECTIVE_FROM,
             EFFECTIVE_TO,
             SUPPLIER_ID,
             ROLLOVER_QUOTE_ID,
             INITIAL_DIRECT_COST,
             FEE_AMOUNT AMOUNT,
             FEE_PURPOSE_CODE
      FROM  okl_fees_b ofb
      WHERE ofb.PARENT_OBJECT_CODE = 'LEASEQUOTE'
      AND   ofb.PARENT_OBJECT_ID = p_qte_id;

   --Get fee payment details
    CURSOR c_get_fee_payment_dtls(p_fee_id okl_fees_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_FEES_B'
    AND    ocf.CFT_CODE ='PAYMENT_SCHEDULE'
    AND    cfo.SOURCE_ID =  p_fee_id
    -- sechawla 5-nov-09 : Bug 9044309
    ORDER BY
    cfl.START_DATE;
    -- sechawla 5-nov-09 End Bug 9044309


    --Get fee expense details
    CURSOR c_get_fee_expense_dtls(p_fee_id okl_fees_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_FEES_B'
    AND    ocf.CFT_CODE ='OUTFLOW_SCHEDULE'
    AND    cfo.SOURCE_ID =  p_fee_id;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    ------------------------------------
    -- Defaulting missing fee REC values
    ------------------------------------
    SELECT start_date,
           end_date
    INTO   l_k_effective_from,
           l_k_effective_to
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;
    FOR l_quote_fee_rec IN c_get_fee_dtls(p_quote_id)LOOP
       -- placeholder recurring expense
      IF l_quote_fee_rec.fee_type IN ('ABSORBED' , 'FINANCED') THEN
        l_periods                :=  1;
        l_exp_frequency          :=  'M';
        l_periodic_amount        :=  l_quote_fee_rec.amount;
      END IF;
      -- denormalized fee amount
      IF l_quote_fee_rec.fee_type IN ('EXPENSE' , 'MISCELLANEOUS') THEN
        FOR l_fee_expense_rec IN c_get_fee_expense_dtls(l_quote_fee_rec.ID) LOOP
         l_periods           := l_fee_expense_rec.NUMBER_OF_PERIODS;
         l_periodic_amount   := l_fee_expense_rec.AMOUNT;
         l_exp_frequency     := l_fee_expense_rec.Frequency_Code;
        END LOOP;
      END IF;

      OKL_CONTEXT.set_okc_org_context(p_chr_id => p_chr_id);
      ------------------------------------
      -- Defaulting missing fee REC values
      ------------------------------------
      l_fee_types_rec.line_id               := NULL;
      l_fee_types_rec.dnz_chr_id            := p_chr_id;
      l_fee_types_rec.fee_type              := l_quote_fee_rec.fee_type;
      l_fee_types_rec.item_id               := NULL;
      l_fee_types_rec.item_id1              := l_quote_fee_rec.STREAM_TYPE_ID;
      l_fee_types_rec.item_id2              := '#';
      l_fee_types_rec.party_id              := NULL;
      l_fee_types_rec.party_name            := NULL;
      l_fee_types_rec.party_id1             := l_quote_fee_rec.supplier_id;
      l_fee_types_rec.party_id2             := '#';
      l_fee_types_rec.effective_from        := l_quote_fee_rec.EFFECTIVE_FROM;
      l_fee_types_rec.effective_to          := l_k_effective_to;
      l_fee_types_rec.amount                := l_quote_fee_rec.amount;
      l_fee_types_rec.initial_direct_cost   := l_quote_fee_rec.INITIAL_DIRECT_COST;
      l_fee_types_rec.qte_id                := l_quote_fee_rec.ROLLOVER_QUOTE_ID;

      l_fee_types_rec.fee_purpose_code      := l_quote_fee_rec.fee_purpose_code;
      --l_fee_types_rec.funding_date          := l_quote_fee_rec.funding_date;

      IF l_quote_fee_rec.fee_type IN ('MISCELLANEOUS', 'EXPENSE', 'CAPITALIZED', 'FINANCED') THEN
       -- create the party as vendor for the supplier present on the subsidy
        IF l_quote_fee_rec.supplier_id IS NOT NULL THEN
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;
             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_chr_id,
                            p_cle_id             => NULL,
                            p_vendor_id          => l_quote_fee_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;
      END IF;
      --Bug # 5129446 ssdeshpa start
      /*
        The lookup code for Security Deposit is not matching in lease applications/quote and contract.
        It is 'SECDEPOSIT' in Contracts.Lease applications/Quote uses 'SEC_DEPOSIT' as lookup code
        Same lookup code should be used while creating Security Deposit Fees on Contract
      **/
      IF l_fee_types_rec.fee_type = 'SEC_DEPOSIT' THEN
         l_fee_types_rec.fee_type := 'SECDEPOSIT';
      END IF;
      --Bug # 5129446 ssdeshpa end;
      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_maintain_fee_pvt.create_fee_type'
         ,'begin debug  call create_fee_type');
      END IF;
      okl_maintain_fee_pvt.create_fee_type( p_api_version      => p_api_version,
                                            p_init_msg_list	   => p_init_msg_list,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
                                            p_fee_types_rec    => l_fee_types_rec,
                                            x_fee_types_rec    => lx_fee_types_rec);
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_maintain_fee_pvt.create_fee_type'
         ,'end debug  call create_fee_type');
       END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_cle_id  :=  lx_fee_types_rec.line_id;
      IF l_quote_fee_rec.fee_type IN ('MISCELLANEOUS', 'EXPENSE', 'CAPITALIZED', 'FINANCED','INCOME','ROLLOVER') THEN
          IF l_quote_fee_rec.fee_type = 'CAPITALIZED' THEN
           l_capitalize_yn := 'Y';
          END IF;
          IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_link_assets'
             ,'begin debug  call create_link_assets');
          END IF;
          create_link_assets (p_api_version             => p_api_version,
                                  p_init_msg_list       => p_init_msg_list,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
                                  p_cle_id              => l_cle_id,
                                  p_chr_id              => p_chr_id,
                                  p_capitalize_yn       => l_capitalize_yn,
                                  p_qte_fee_srv_id      => l_quote_fee_rec.ID,
                                  --p_derive_assoc_amt    => l_derive_assoc_amt, -- Commented by rravikir for Bug#6707125
                                  p_line_type           => l_quote_fee_rec.fee_type);
          IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_link_assets'
             ,'end debug  call create_link_assets');
          END IF;
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;

      IF l_quote_fee_rec.fee_type IN ('MISCELLANEOUS', 'EXPENSE', 'ABSORBED', 'FINANCED') THEN
         IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_expense_dtls'
         ,'begin debug  call create_expense_dtls');
         END IF;
         create_expense_dtls(p_api_version       => p_api_version,
                             p_init_msg_list     => p_init_msg_list,
                             x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data,
                             p_cle_id            =>  l_cle_id,
                             p_chr_id            =>  p_chr_id,
                             p_periods           =>  l_periods,
                             p_periodic_amount   =>  l_periodic_amount,
                             p_exp_frequency     =>  l_exp_frequency);
        IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_expense_dtls'
         ,'end debug  call create_expense_dtls');
        END IF;
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
     IF l_quote_fee_rec.fee_type IN ('MISCELLANEOUS', 'PASSTHROUGH', 'FINANCED', 'INCOME', 'ROLLOVER', 'SEC_DEPOSIT') THEN
        l_pymnt_counter := 0;
        l_payment_levels_tbl.DELETE;
        FOR l_fee_payment_rec IN c_get_fee_payment_dtls(l_quote_fee_rec.ID) LOOP
         l_payment_levels_tbl(l_pymnt_counter).START_DATE      := l_fee_payment_rec.START_DATE;
         l_payment_levels_tbl(l_pymnt_counter).PERIODS         := l_fee_payment_rec.NUMBER_OF_PERIODS;
         l_payment_levels_tbl(l_pymnt_counter).AMOUNT          := l_fee_payment_rec.AMOUNT;
         l_payment_levels_tbl(l_pymnt_counter).STUB_DAYS       := l_fee_payment_rec.STUB_DAYS;
         l_payment_levels_tbl(l_pymnt_counter).STUB_AMOUNT     := l_fee_payment_rec.STUB_AMOUNT;
         l_payment_levels_tbl(l_pymnt_counter).PAYMENT_TYPE_ID := l_fee_payment_rec.PAYMENT_TYPE_ID;
         l_payment_levels_tbl(l_pymnt_counter).FREQUENCY_CODE  := l_fee_payment_rec.FREQUENCY_CODE;
         l_payment_levels_tbl(l_pymnt_counter).ARREARS_YN      := l_fee_payment_rec.ARREARS_YN;
         l_pymnt_counter := l_pymnt_counter + 1;
         END LOOP;
          -- create EPT payment
      IF l_payment_levels_tbl.COUNT > 0 THEN

      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
         ,'begin debug  call create_payment_plans');
      END IF;
      create_payment_plans(p_api_version             => p_api_version,
                             p_init_msg_list	        => p_init_msg_list,
                             x_return_status 	       => x_return_status,
                             x_msg_count     	       => x_msg_count,
                             x_msg_data         	    => x_msg_data,
                             p_transaction_control   =>  OKL_API.G_FALSE,
                             p_cle_id                =>  l_cle_id,
                             p_chr_id                =>  p_chr_id,
                             p_payment_type_id       =>  l_payment_levels_tbl(0).payment_type_id,
                             p_payment_frequency     =>  l_payment_levels_tbl(0).frequency_code,
                             p_payment_arrears       =>  l_payment_levels_tbl(0).arrears_yn,
                             p_payment_structure     =>  NULL,
                             p_rate_type             =>  NULL,
                             p_payment_levels_tbl    =>  l_payment_levels_tbl);
        IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
         ,'end debug  call create_payment_plans');
        END IF;
        IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;
   END IF;
   END LOOP;
   x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_fee_lines;

  -----------------------------------------------------------------------------
  -- PROCEDURE create_asset_addon
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : asset_addon
  -- Description     : This procedure creates the addons for the
  --                 : given asset
  -- Business Rules  :
  -- Parameters      : p_quote_asset_rec, p_addon_tbl,
  --                 : x_return_status, x_msg_count, x_msg_data
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --
  -- End of comments
  PROCEDURE create_asset_addon( p_api_version                  IN NUMBER,
                                p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_count                    OUT NOCOPY NUMBER,
                                x_msg_data                     OUT NOCOPY VARCHAR2,
                                p_clev_fin_rec                 IN  clev_fin_rec,
                                p_asset_id                     IN NUMBER) IS
     -- Variables Declarations
    l_api_version CONSTANT            NUMBER DEFAULT 1.0;
    l_api_name CONSTANT               VARCHAR2(30) DEFAULT 'CRT_AST_ADN';
    l_return_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled                   VARCHAR2(10);
    l_cre_klev_tbl                    OKL_CREATE_KLE_PVT.klev_tbl_type;
    l_cre_clev_tbl                    OKL_CREATE_KLE_PVT.clev_tbl_type;
    l_cre_cimv_tbl                    OKL_CREATE_KLE_PVT.cimv_tbl_type;
    lx_cre_klev_tbl                   OKL_CREATE_KLE_PVT.klev_tbl_type;
    lx_cre_clev_tbl                   OKL_CREATE_KLE_PVT.clev_tbl_type;
    lx_cre_cimv_tbl                   OKL_CREATE_KLE_PVT.cimv_tbl_type;
    lx_cre_fin_clev_rec               OKL_CREATE_KLE_PVT.clev_rec_type;
    lx_cre_fin_klev_rec               OKL_CREATE_KLE_PVT.klev_rec_type;
    l_cre_counter                     NUMBER;
    l_line_number                     NUMBER;
    l_asset_number                    VARCHAR2(150);
    lx_return_status                  VARCHAR2(1);
    l_model_line_id                   okc_k_lines_b.id%TYPE;
    l_addon_item_id                   okc_k_items.object1_id1%TYPE;
    l_addon_unit_cost                 okc_k_lines_b.price_unit%TYPE;
    l_addon_modified                  BOOLEAN;
    TYPE qte_cntrct_addon_rec_type IS RECORD (qte_addon_id            NUMBER,
                                              addon_supplier_id       NUMBER,
                                              cntrct_addon_id         NUMBER);
    l_qte_cntrct_addon_tbl            qte_cntrct_addon_rec_type;

    CURSOR find_model_line_id_csr (p_fin_line_id NUMBER) IS
      -- to find id for model line style 34 which is parent of ADD ON Line
      SELECT cle.id MODEL_LINE_ID
      FROM   okc_k_lines_b cle,
             okc_line_styles_b cls
      WHERE  cle.cle_id = p_fin_line_id
      AND    cle.lse_id = cls.id
      AND    cls.lty_code = 'ITEM';
    -- to find the asset_num
    CURSOR find_asset_num_csr(p_fin_line_id NUMBER) IS
      SELECT name
      FROM   OKC_K_LINES_V
      WHERE  id = p_fin_line_id;
    --get asset add ons
    CURSOR c_get_asset_addons(p_ast_id okl_assets_b.ID%TYPE) IS
      SELECT oab.ID,
             oab.ASSET_NUMBER,
             oab.INSTALL_SITE_ID,
             oab.RATE_CARD_ID,
             oab.RATE_TEMPLATE_ID,
             oab.OEC,
             oab.END_OF_TERM_VALUE_DEFAULT,
             oab.END_OF_TERM_VALUE,
             oab.OEC_PERCENTAGE,
             oab.DESCRIPTION,
             oacb.INV_ITEM_ID,
             oacb.SUPPLIER_ID,
             oacb.PRIMARY_COMPONENT,
             oacb.UNIT_COST,
             oacb.NUMBER_OF_UNITS,
             oacb.MANUFACTURER_NAME,
             oacb.YEAR_MANUFACTURED,
             oacb.MODEL_NUMBER,
             oacb.id qte_add_on_id
      FROM   okl_assets_v oab,
             okl_asset_components_b  oacb
      WHERE  oab.ID = oacb.ASSET_ID
      AND    oab.PARENT_OBJECT_CODE = 'LEASEQUOTE'
      AND    oacb.PRIMARY_COMPONENT = 'NO'
      AND    oacb.ASSET_ID = p_ast_id;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- find asset number and set it
    open find_asset_num_csr(p_clev_fin_rec.ID);
    fetch find_asset_num_csr into l_asset_number;
    close find_asset_num_csr;
    l_cre_counter        := 0;
    FOR l_model_line_id_csr_rec in find_model_line_id_csr ( p_fin_line_id => p_clev_fin_rec.ID)
    LOOP
        l_model_line_id        := l_model_line_id_csr_rec.model_line_id;
    END LOOP;
    FOR l_asset_addon_rec IN c_get_asset_addons(p_asset_id) LOOP
        l_cre_counter := 0;
        l_cre_clev_tbl.DELETE;
        l_cre_cimv_tbl.DELETE;
        l_cre_klev_tbl.DELETE;
        l_cre_clev_tbl(l_cre_counter).chr_id          := NULL;
        l_cre_clev_tbl(l_cre_counter).cle_id          := l_model_line_id;
        l_cre_clev_tbl(l_cre_counter).price_unit      := l_asset_addon_rec.unit_cost;
        l_cre_clev_tbl(l_cre_counter).dnz_chr_id      := p_clev_fin_rec.chr_id;
        l_cre_clev_tbl(l_cre_counter).exception_yn    := 'N';
        l_cre_cimv_tbl(l_cre_counter).exception_yn    := 'N';
        l_cre_cimv_tbl(l_cre_counter).number_of_items := l_asset_addon_rec.number_of_units;
        l_cre_cimv_tbl(l_cre_counter).object1_id1     := l_asset_addon_rec.INV_ITEM_ID;
        -- assigning OKL_K_ITEMS_INVENTORY_ORG instead of ORG_ID
        l_cre_cimv_tbl(l_cre_counter).object1_id2     := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);
        l_cre_klev_tbl(l_cre_counter).manufacturer_name := l_asset_addon_rec.manufacturer_name;
        l_cre_klev_tbl(l_cre_counter).model_number := l_asset_addon_rec.model_number;
        l_cre_klev_tbl(l_cre_counter).year_of_manufacture := l_asset_addon_rec.year_manufactured;


   /* END LOOP; -- for addon table
    IF ( l_cre_counter > 0 ) THEN*/
        IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_CREATE_KLE_PVT.create_add_on_line'
         ,'begin debug  call create_add_on_line');
        END IF;

        OKL_CREATE_KLE_PVT.create_add_on_line(p_api_version    => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                              p_new_yn         => 'Y',
                                              p_asset_number   => l_asset_number,
                                              p_clev_tbl       => l_cre_clev_tbl,
                                              p_klev_tbl       => l_cre_klev_tbl,
                                              p_cimv_tbl       => l_cre_cimv_tbl,
                                              x_clev_tbl       => lx_cre_clev_tbl,
                                              x_klev_tbl       => lx_cre_klev_tbl,
                                              x_fin_clev_rec   => lx_cre_fin_clev_rec,
                                              x_fin_klev_rec   => lx_cre_fin_klev_rec,
                                              x_cimv_tbl       => lx_cre_cimv_tbl);

        IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_CREATE_KLE_PVT.create_add_on_line'
          ,'end debug  call create_add_on_line');
        END IF;
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- create the party as vendor for the supplier present on the asset
        IF l_asset_addon_rec.supplier_id IS NOT NULL THEN
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;

             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_clev_fin_rec.chr_id,
                            p_cle_id             => NULL,
                            p_vendor_id          => l_asset_addon_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;
             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_clev_fin_rec.chr_id,
                            p_cle_id             => lx_cre_clev_tbl(lx_cre_clev_tbl.FIRST).id,
                            p_vendor_id          => l_asset_addon_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;


   END LOOP;
   -- END IF;
    x_return_status := okc_api.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_asset_addon;
  -----------------------------------------------------------------------------
  -- PROCEDURE create_asset_subsidy
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_asset_subsidy
  -- Description     : This procedure creates and updates the subsidies for the
  --                 : given asset
  -- Business Rules  :
  -- Parameters      : p_quote_asset_rec, p_subsidy_tbl,
  --                 : x_return_status, x_msg_count, x_msg_data
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --                   04-Jan-2008 RRAVIKIR modified for bug#6707125 to handle
  --                                        the subsidy creation for Financed
  --                                        Amount Subsidy
  --
  -- End of comments
  PROCEDURE create_asset_subsidy (p_api_version                  IN NUMBER,
                                  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status                OUT NOCOPY VARCHAR2,
                                  x_msg_count                    OUT NOCOPY NUMBER,
                                  x_msg_data                     OUT NOCOPY VARCHAR2,
                                  --p_clev_fin_rec                 IN  clev_fin_rec, -- Commented by rravikir for bug#6707125
                                  --p_asset_id                     IN NUMBER, -- Commented by rravikir for bug#6707125
                                  p_quote_id                     IN  NUMBER,           -- Added by rravikir for bug#6707125
                                  p_chr_id                       IN NUMBER) IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_AST_SUB';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);

    -- Start : Added by rravikir for Bug#6707125
    CURSOR c_get_asset_id(p_qte_id okl_lease_quotes_b.ID%TYPE) IS
      SELECT oab.ID asset_id
      FROM   okl_assets_v oab,
             okl_asset_components_b  oacb
      WHERE  oab.ID = oacb.ASSET_ID
      AND    oab.PARENT_OBJECT_CODE = 'LEASEQUOTE'
      AND    oacb.PRIMARY_COMPONENT = 'YES'
      AND    oab.PARENT_OBJECT_ID = p_qte_id;
    -- End : Added by rravikir for Bug#6707125

    CURSOR c_get_asset_subsidy(p_ast_id okl_assets_b.ID%TYPE) IS
      SELECT ADJUSTMENT_SOURCE_ID,
             VALUE,
             SUPPLIER_ID,
             default_subsidy_amount
      FROM   okl_cost_adjustments_b
      WHERE  PARENT_OBJECT_CODE = 'ASSET'
      AND    ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
      AND    PARENT_OBJECT_ID = p_ast_id;
    l_cre_asb_tbl                     OKL_ASSET_SUBSIDY_PVT.asb_tbl_type;
    lx_cre_asb_tbl                    OKL_ASSET_SUBSIDY_PVT.asb_tbl_type;
    l_cre_asb_tmp_tbl                 OKL_ASSET_SUBSIDY_PVT.asb_tbl_type;  --temporary table for initialization
    l_cre_counter                     NUMBER;
    l_fin_line_id                     NUMBER;          -- Added by rravikir for Bug#6707125
    lx_return_status                  VARCHAR2(1);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Outer Loop : Added by rravikir for bug#6707125
    FOR l_get_asset_rec IN c_get_asset_id(p_quote_id) LOOP
      l_cre_counter := 0;
      l_cre_asb_tbl := l_cre_asb_tmp_tbl;  --Initialization of table
      l_fin_line_id := get_fin_line_id(l_get_asset_rec.asset_id);
      IF l_fin_line_id IS NOT NULL THEN
        --FOR l_asset_subsidy_rec IN c_get_asset_subsidy(p_asset_id) LOOP
        FOR l_asset_subsidy_rec IN c_get_asset_subsidy(l_get_asset_rec.asset_id) LOOP
          l_cre_asb_tbl(l_cre_counter).subsidy_id                   := l_asset_subsidy_rec.ADJUSTMENT_SOURCE_ID;
          --l_cre_asb_tbl(l_cre_counter).asset_cle_id                 := p_clev_fin_rec.id;
          l_cre_asb_tbl(l_cre_counter).asset_cle_id                 := l_fin_line_id;
          l_cre_asb_tbl(l_cre_counter).amount                       := l_asset_subsidy_rec.default_subsidy_amount;
          l_cre_asb_tbl(l_cre_counter).subsidy_override_amount      := l_asset_subsidy_rec.value;
          --l_cre_asb_tbl(l_cre_counter).dnz_chr_id                   := p_clev_fin_rec.chr_id;
          l_cre_asb_tbl(l_cre_counter).dnz_chr_id                   := p_chr_id;
          l_cre_asb_tbl(l_cre_counter).vendor_id                    := l_asset_subsidy_rec.SUPPLIER_ID;

		  -- create the party as vendor for the supplier present on the subsidy
          IF l_asset_subsidy_rec.SUPPLIER_ID IS NOT NULL THEN
            IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
            END IF;

            create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_chr_id,
                            p_cle_id             => NULL,
                            p_vendor_id          => l_asset_subsidy_rec.SUPPLIER_ID);

            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
            END IF;
            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

		  l_cre_counter := l_cre_counter + 1;
        END LOOP;

	    IF l_cre_counter > 0 THEN
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_asset_subsidy_pvt.create_asset_subsidy'
                             ,'begin debug  call create_asset_subsidy');
          END IF;

		  okl_asset_subsidy_pvt.create_asset_subsidy( p_api_version    => p_api_version,
                                                      p_init_msg_list  => p_init_msg_list,
                                                  	  x_return_status  => x_return_status,
                                                  	  x_msg_count      => x_msg_count,
                                                  	  x_msg_data       => x_msg_data,
                                                  	  p_asb_tbl        => l_cre_asb_tbl,
                                                  	  x_asb_tbl        => lx_cre_asb_tbl);
          IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_asset_subsidy_pvt.create_asset_subsidy'
                         ,'end debug  call create_asset_subsidy');
          END IF;

		  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;
    END LOOP; -- Outer Loop Added by rravikir for bug#6707125

    x_return_status := okc_api.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_asset_subsidy;

  -----------------------------------------------------------------------------
  -- PROCEDURE create_asset_down_payment
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_asset_down_payment
  -- Description     : This procedure creates down payment for an asset
  -- End of comments
  PROCEDURE create_asset_down_payment (p_api_version                  IN NUMBER,
                                       p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                       x_return_status                OUT NOCOPY VARCHAR2,
                                       x_msg_count                    OUT NOCOPY NUMBER,
                                       x_msg_data                     OUT NOCOPY VARCHAR2,
                                       p_clev_fin_rec                 IN  clev_fin_rec,
                                       p_asset_id                     IN NUMBER) IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_AST_DP';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    l_asset_number                VARCHAR2(240);
    l_top_line_id                 NUMBER;
    l_dnz_chr_id                  NUMBER;
    l_capital_reduction           NUMBER;
    l_capital_reduction_percent   NUMBER;
    l_oec                         NUMBER;
    l_cap_down_pay_yn             VARCHAR2(5);
    l_down_payment_receiver       VARCHAR2(30);
    l_dp_exists                   BOOLEAN := FALSE;

    --cursor to fetch asset down payment adjustment details
    CURSOR get_asset_dp_details(p_ast_id IN okl_Assets_b.id%TYPE) IS
     SELECT
       id
      ,parent_object_code
      ,parent_object_id
      ,adjustment_source_type
      ,adjustment_source_id
      ,basis
      ,value
      ,processing_type
      ,supplier_id
      ,default_subsidy_amount
      ,short_description
      ,description
      ,comments
      ,percent_basis_value
    FROM OKL_COST_ADJUSTMENTS_V
    WHERE parent_object_id = p_ast_id
    AND   parent_object_code = 'ASSET'
    AND   adjustment_source_type = 'DOWN_PAYMENT';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    SELECT ASSET_NUMBER
    INTO  l_asset_number
    FROM  OKL_ASSET_ADJUST_UV
    WHERE ID = p_clev_fin_rec.id;
    l_top_line_id               := p_clev_fin_rec.id;
    l_dnz_chr_id                := p_clev_fin_rec.dnz_chr_id;
    SELECT oec
    INTO  l_oec
    FROM OKL_K_LINES
    WHERE ID = p_clev_fin_rec.id;
     l_down_payment_receiver := 'LESSOR';
    FOR l_asset_dp_rec IN get_asset_dp_details(p_asset_id) LOOP
        l_dp_exists := TRUE;
        l_capital_reduction         := l_asset_dp_rec.value;
        l_capital_reduction_percent := null;
        IF l_asset_dp_rec.processing_type = 'BILL' THEN
           l_cap_down_pay_yn  := 'N';
        ELSE
           l_cap_down_pay_yn  := 'Y';
        END IF;
    END LOOP;
    IF l_dp_exists THEN
        IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.Okl_La_Asset_Pvt.update_Fin_Cap_Cost'
            ,'begin debug  call update_Fin_Cap_Cost');
        END IF;
        Okl_La_Asset_Pvt.update_Fin_Cap_Cost(
                                       p_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       'N',
                                       l_asset_number,
                                       l_top_line_id,
                                       l_dnz_chr_id,
                                       l_capital_reduction,
                                       l_capital_reduction_percent,
                                       l_oec,
                                       l_cap_down_pay_yn,
                                       l_down_payment_receiver
                                       );
        IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.Okl_La_Asset_Pvt.update_Fin_Cap_Cost'
            ,'end debug  call update_Fin_Cap_Cost');
        END IF;
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    x_return_status := okc_api.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_asset_down_payment;
    -----------------------------------------------------------------------------
  -- PROCEDURE create_asset_tradein
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_asset_tradein
  -- Description     : This procedure creates trade in  for an asset
  -- End of comments
  PROCEDURE create_asset_tradein (p_api_version                  IN NUMBER,
                                       p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                       x_return_status                OUT NOCOPY VARCHAR2,
                                       x_msg_count                    OUT NOCOPY NUMBER,
                                       x_msg_data                     OUT NOCOPY VARCHAR2,
                                       p_clev_fin_rec                 IN  clev_fin_rec,
                                       p_asset_id                     IN NUMBER) IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_AST_DP';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    l_tradein_rec                 Okl_La_Tradein_Pvt.tradein_rec_type;
    x_tradein_rec                 Okl_La_Tradein_Pvt.tradein_rec_type;
    l_chr_id                      okl_k_headers.id%TYPE;
    l_ti_exists                   BOOLEAN := false;

    --cursor to fetch asset trade in  adjustment details
    CURSOR get_asset_ti_details(p_ast_id IN okl_Assets_b.id%TYPE) IS
     SELECT
       id
      ,parent_object_code
      ,parent_object_id
      ,adjustment_source_type
      ,adjustment_source_id
      ,basis
      ,value
      ,processing_type
      ,supplier_id
      ,default_subsidy_amount
      ,short_description
      ,description
      ,comments
      ,percent_basis_value
    FROM OKL_COST_ADJUSTMENTS_V
    WHERE parent_object_id = p_ast_id
    AND   parent_object_code = 'ASSET'
    AND   adjustment_source_type = 'TRADEIN';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    SELECT ASSET_NUMBER
    INTO  l_tradein_rec.asset_number
    FROM  OKL_ASSET_ADJUST_UV
    WHERE ID = p_clev_fin_rec.id;
    l_tradein_rec.id            := p_clev_fin_rec.id;
    l_tradein_rec.asset_id      := p_clev_fin_rec.id;
    l_chr_id                    := p_clev_fin_rec.dnz_chr_id;
    FOR l_asset_ti_rec IN get_asset_ti_details(p_asset_id) LOOP
        l_tradein_rec.tradein_amount:= l_asset_ti_rec.value;
        l_ti_exists   := TRUE;
    END LOOP;

    IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.Okl_La_Tradein_Pvt.create_Tradein'
        ,'begin debug  call create_Tradein');
    END IF;

    IF l_ti_exists THEN

     Okl_La_Tradein_Pvt.create_Tradein(p_api_version,
                                   p_init_msg_list,
                                   x_return_status,
                                   x_msg_count,
                                   x_msg_data,
                                   l_chr_id,
                                   l_tradein_rec,
                                   x_tradein_rec);

     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.Okl_La_Tradein_Pvt.create_Tradein'
        ,'end debug  call create_Tradein');
     END IF;
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    END IF;
    x_return_status := okc_api.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END create_asset_tradein;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_asset_lines
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_asset_lines
  -- Description     : This procedure is a wrapper that creates contract asset lines from lease application/quote header
  --
  -- Business Rules  : this procedure is used to create a contract asset lines  from lease application/quote header
  --                 : The following details are copied to a Lease Contract from a credit approved Lease Application
  --                 : Lease Application Header asset line details
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_asset_lines(p_api_version                  IN NUMBER,
                               p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status                OUT NOCOPY VARCHAR2,
                               x_msg_count                    OUT NOCOPY NUMBER,
                               x_msg_data                     OUT NOCOPY VARCHAR2,
                               p_chr_id                       IN  NUMBER,
                               p_lapv_rec                     IN  c_get_leaseapp_hdr%ROWTYPE)IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_AST_LNS';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    l_new_yn                      VARCHAR2(1);
    l_update_date                 DATE;
    l_chr_id                      NUMBER;
    l_pymnt_counter               NUMBER := 0;
    l_ast_counter                 NUMBER:=0;
    l_lapv_rec                    c_get_leaseapp_hdr%ROWTYPE;
    --asset rec
    l_clev_fin_rec                okl_okc_migration_pvt.clev_rec_type;
    l_klev_fin_rec                okl_kle_pvt.klev_rec_type;
    l_cimv_model_rec              okl_okc_migration_pvt.cimv_rec_type;
    l_clev_fa_rec                 okl_okc_migration_pvt.clev_rec_type;
    l_cimv_fa_rec                 okl_okc_migration_pvt.cimv_rec_type;
    l_talv_fa_rec                 okl_tal_pvt.talv_rec_type;
    l_itiv_tbl                    okl_iti_pvt.itiv_tbl_type;
    lx_clev_fin_rec               okl_okc_migration_pvt.clev_rec_type;
    lx_clev_model_rec             okl_okc_migration_pvt.clev_rec_type;
    lx_clev_fa_rec                okl_okc_migration_pvt.clev_rec_type;
    lx_clev_ib_rec                okl_okc_migration_pvt.clev_rec_type;
    l_payment_levels_tbl          payment_levels_tbl_type;
    l_qte_payment_levels_tbl      payment_levels_tbl_type;
    l_pym_hdr_rec                 okl_la_payments_pvt.pym_hdr_rec_type;
    l_pym_tbl                     okl_la_payments_pvt.pym_tbl_type;
    lx_rulv_tbl                   okl_la_payments_pvt.rulv_tbl_type;
    l_payment_type_id             Number;
    l_eot_type                    VARCHAR2(40);
    l_ti_amt                      NUMBER := NULL;
    l_ti_desc                     OKL_COST_ADJUSTMENTS_V.description%TYPE;

    --sechawla 7-dec-09 9120203 : begin
    --get the corporate book from system options
    cursor l_corp_book_csr IS
    select ASST_ADD_BOOK_TYPE_CODE
    from   OKL_system_params ;
    l_corp_book VARCHAR2(15);
    --sechawla 7-dec-09 9120203 : end

    --Cursor declarations
    --Get asset line details
    CURSOR c_get_asset_dtls(p_qte_id okl_lease_quotes_b.ID%TYPE) IS
    SELECT oab.ID,
           oab.ASSET_NUMBER,
           oab.INSTALL_SITE_ID,
           oab.RATE_CARD_ID,
           oab.RATE_TEMPLATE_ID,
           oab.OEC,
           oab.END_OF_TERM_VALUE_DEFAULT,
           oab.END_OF_TERM_VALUE,
           oab.OEC_PERCENTAGE,
           oab.SHORT_DESCRIPTION,
           oacb.INV_ITEM_ID,
           oacb.SUPPLIER_ID,
           oacb.PRIMARY_COMPONENT,
           oacb.UNIT_COST,
           oacb.NUMBER_OF_UNITS,
           oacb.MANUFACTURER_NAME,
           oacb.YEAR_MANUFACTURED,
           oacb.MODEL_NUMBER
    FROM   okl_assets_v oab,
           okl_asset_components_b  oacb
    WHERE  oab.ID = oacb.ASSET_ID
    AND    oab.PARENT_OBJECT_CODE = 'LEASEQUOTE'
    AND    oacb.PRIMARY_COMPONENT = 'YES'
    AND    oab.PARENT_OBJECT_ID = p_qte_id;

   --Get asset rent payment details
    CURSOR c_get_asset_payment_dtls(p_ast_id okl_assets_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_ASSETS_B'
    AND    cfo.OTY_CODE = 'QUOTED_ASSET'
    AND    cfo.SOURCE_ID =  p_ast_id
    -- sechawla 5-nov-09 Bug 9044309
    ORDER BY
    cfl.START_DATE;
    --sechawla 5-nov-09  End Bug 9044309


    --Get asset billed down payment details
    CURSOR c_get_asset_dppayment_dtls(p_ast_id okl_assets_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_ASSETS_B'
    AND    cfo.OTY_CODE = 'QUOTED_ASSET_DOWN_PAYMENT'
    AND    cfo.SOURCE_ID =  p_ast_id;

    --Get asset estimated property tax payment details
    CURSOR c_get_asset_eptpayment_dtls(p_ast_id okl_assets_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_ASSETS_B'
    AND    cfo.OTY_CODE = 'QUOTED_ASSET_PROPERTY_TAX'
    AND    cfo.SOURCE_ID =  p_ast_id;

    --Get quote level payment details
    CURSOR c_get_quote_payment_dtls(p_qte_id okl_lease_quotes_b.ID%TYPE) IS
    SELECT ocf.STY_ID payment_type_id,
           ocf.DUE_ARREARS_YN Arrears_YN,
           cfl.FQY_CODE Frequency_Code,
           cfl.START_DATE,
           cfl.STUB_DAYS,
           cfl.STUB_AMOUNT,
           cfl.NUMBER_OF_PERIODS,
           cfl.AMOUNT
    FROM   OKL_CASH_FLOW_OBJECTS cfo,
           OKL_CASH_FLOWS ocf,
           OKL_CASH_FLOW_LEVELS cfl
    WHERE  cfl.caf_id = ocf.ID
    AND    ocf.CFO_ID = cfo.ID
    AND    cfo.SOURCE_TABLE = 'OKL_LEASE_QUOTES_B'
    AND    cfo.SOURCE_ID =  p_qte_id;

    --get the item description
    CURSOR itm_dtls_csr(p_inv_itm_id IN NUMBER, p_organization_id IN NUMBER) IS
    SELECT TL.DESCRIPTION DESCRIPTION
    FROM   MTL_SYSTEM_ITEMS_TL TL
    WHERE  TL.ORGANIZATION_ID = p_organization_id
    AND    TL.INVENTORY_ITEM_ID = p_inv_itm_id
    AND    TL.LANGUAGE = USERENV('LANG');

    --get the eot type
    CURSOR c_get_eot_type(p_qte_id IN okl_lease_quotes_b.ID%TYPE) IS
    SELECT eoth.eot_type_code
    FROM  OKL_FE_EO_TERM_VERS EOTV,
          OKL_FE_EO_TERMS_ALL_B EOTH,
          OKL_LEASE_QUOTES_B QTE
    WHERE QTE.END_OF_TERM_OPTION_ID = EOTV.END_OF_TERM_VER_ID
    AND   EOTV.END_OF_TERM_ID = EOTH.END_OF_TERM_ID
    AND   QTE.ID = p_qte_id;

    --cursor to fetch total trade in amount and description
    CURSOR get_ti_amt(p_qte_id IN okl_lease_quotes_b.ID%TYPE) IS
     SELECT sum(cdj.value) total_tradein
     FROM   OKL_COST_ADJUSTMENTS_b cdj,
            OKL_ASSETS_B ast
     WHERE cdj.parent_object_id = ast.id
     AND   cdj.parent_object_code = 'ASSET'
     AND   cdj.adjustment_source_type = 'TRADEIN'
     AND   ast.parent_object_id = p_qte_id
     AND   ast.parent_object_code ='LEASEQUOTE';

     --cursor to fetch trade in description for any one asset
    CURSOR get_ti_desc(p_qte_id IN okl_lease_quotes_b.ID%TYPE) IS
    SELECT cdj.description
     FROM   OKL_COST_ADJUSTMENTS_V cdj,
            OKL_ASSETS_B ast
     WHERE cdj.parent_object_id = ast.id
     AND   cdj.parent_object_code = 'ASSET'
     AND   cdj.adjustment_source_type = 'TRADEIN'
     AND   ast.parent_object_id = p_qte_id
     AND   ast.parent_object_code ='LEASEQUOTE'
	 AND   rownum = 1;

    -- Bug# 9478943 - Added - Start
    -- Get the default category setup for an inventory item
    CURSOR get_default_category(cp_inv_item_id MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE
                             , cp_inv_org_id MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE) IS
      SELECT mtl.asset_category_id
       FROM mtl_system_items_b mtl,
            okx_asst_catgrs_v cat
       WHERE  inventory_item_id = cp_inv_item_id
          AND organization_id = cp_inv_org_id
          AND cat.id1 = mtl.asset_category_id;

    -- Get the depreciation method defined on the category defaults for the category book
    CURSOR get_default_deprn_meth(cp_bk_type_code fa_category_book_defaults.book_type_code%TYPE
                                , cp_category_id fa_category_book_defaults.category_id%type
                                , cp_inservice_date DATE
                                , cp_term NUMBER) IS
       SELECT def.deprn_method
            , (def.adjusted_rate * 100) deprn_rate
            , NVL(mth.life_in_months,def.life_in_months) life_in_months
         FROM fa_category_book_defaults def
            , fa_methods mth
        WHERE  def.book_type_code = cp_bk_type_code
           AND def.category_id = cp_category_id
           AND cp_inservice_date BETWEEN def.start_dpis AND Nvl(def.end_dpis, cp_inservice_date)
           AND mth.method_code (+) = def.deprn_method
           AND mth.life_in_months (+) = cp_term;
    -- Bug# 9478943 - Added - End

    -- cursor to fetch lease
  BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- check for logging on PROCEDURE level
      l_debug_enabled := okl_debug_pub.check_log_enabled;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                                ,p_pkg_name      => G_PKG_NAME
                                                ,p_init_msg_list => p_init_msg_list
                                                ,l_api_version   => l_api_version
                                                ,p_api_version   => p_api_version
                                                ,p_api_type      => g_api_type
                                                ,x_return_status => x_return_status);
      -- check if activity started successfully
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_chr_id    := p_chr_id;
      l_lapv_rec  := p_lapv_rec;

      --sechawla 7-dec-09 9120203 : begin
      open  l_corp_book_csr ;
      fetch l_corp_book_csr into l_corp_book;
      close l_corp_book_csr;
      --sechawla 7-dec-09 9120203 : end

      --create asset line
      FOR l_quote_asset_rec IN c_get_asset_dtls(l_lapv_rec.quote_id) LOOP
          l_cimv_model_rec.object1_id1 := l_quote_asset_rec.INV_ITEM_ID;
          l_cimv_model_rec.object1_id2 := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);
          okl_context.set_okc_org_context(p_chr_id => l_chr_id);
          l_clev_fin_rec.exception_yn         := 'N';
          l_clev_fin_rec.dnz_chr_id           := l_chr_id;
          IF l_quote_asset_rec.short_description IS NOT NULL THEN
              l_clev_fin_rec.item_description     := l_quote_asset_rec.short_description;
          ELSE
            FOR l_itm_rec IN itm_dtls_csr(l_cimv_model_rec.object1_id1,l_cimv_model_rec.object1_id2) LOOP
              l_clev_fin_rec.item_description := l_itm_rec.description;
            END LOOP;
          END IF;
          -- passing G_MISS_NUM may cause error in LLA APIs

          FOR l_eot_typ_rec IN c_get_eot_type(l_lapv_rec.quote_id) LOOP
            l_eot_type := l_eot_typ_rec.eot_type_code;
          END LOOP;
          IF l_eot_type IN ('AMOUNT','RESIDUAL_AMOUNT') THEN
             l_klev_fin_rec.residual_value  := nvl(l_quote_asset_rec.end_of_term_value,l_quote_asset_rec.end_of_term_value_default);
             l_klev_fin_rec.residual_percentage := NULL;
          ELSE
          l_klev_fin_rec.residual_value := NULL;
          l_klev_fin_rec.residual_percentage       := nvl(l_quote_asset_rec.end_of_term_value,l_quote_asset_rec.end_of_term_value_default);
          END IF;

          --sechawla 7-dec-09 9120203 : begin
          l_talv_fa_rec.corporate_book        := l_corp_book;
          --sechawla 7-dec-09 9120203 : end

          --Bug#9478943 - Added - Start
          -- Default the asset category
          OPEN get_default_category(l_quote_asset_rec.INV_ITEM_ID, l_lapv_rec.INV_ORG_ID);
            FETCH get_default_category INTO l_talv_fa_rec.DEPRECIATION_ID;
          CLOSE get_default_category;

          -- Default In service Date from the expected delivery date
          l_talv_fa_rec.IN_SERVICE_DATE := l_lapv_rec.EXPECTED_DELIVERY_DATE;

          -- Default the depreciation method
          OPEN get_default_deprn_meth(l_corp_book,l_talv_fa_rec.DEPRECIATION_ID,l_talv_fa_rec.IN_SERVICE_DATE,l_lapv_rec.TERM);
            FETCH get_default_deprn_meth INTO l_talv_fa_rec.DEPRN_METHOD
                                            , l_talv_fa_rec.DEPRN_RATE
                                            , l_talv_fa_rec.LIFE_IN_MONTHS;
          CLOSE get_default_deprn_meth;
          --Bug#9478943 - Added - End

          l_talv_fa_rec.dnz_khr_id            := l_clev_fin_rec.dnz_chr_id;
          l_talv_fa_rec.asset_number          := l_quote_asset_rec.ASSET_NUMBER;
          l_talv_fa_rec.description           := l_clev_fin_rec.item_description;
          l_talv_fa_rec.fa_location_id        := NULL;
          l_talv_fa_rec.original_cost         := l_quote_asset_rec.unit_cost;
          l_talv_fa_rec.current_units         := l_quote_asset_rec.NUMBER_OF_UNITS;
          l_talv_fa_rec.model_number          := l_quote_asset_rec.MODEL_NUMBER;
          l_talv_fa_rec.year_manufactured     := l_quote_asset_rec.YEAR_MANUFACTURED;
          l_talv_fa_rec.manufacturer_name     := l_quote_asset_rec.MANUFACTURER_NAME;
          l_talv_fa_rec.used_asset_yn         := NULL;
          l_talv_fa_rec.fa_location_id        := null;
          l_new_yn                            := 'Y';
          l_itiv_tbl(1).mfg_serial_number_yn  := 'N';
          l_itiv_tbl(1).object_id1_new        := l_quote_asset_rec.install_site_id;
          l_itiv_tbl(1).object_id2_new        := '#';
          l_itiv_tbl(1).jtot_object_code_new  := 'OKX_PARTYSITE';

          -- call create_all_lines to create asset lines
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_create_kle_pvt.create_all_line'
           ,'begin debug  call create_all_line');
          END IF;
          okl_create_kle_pvt.create_all_line( p_api_version       => p_api_version,
                                              p_init_msg_list	    => p_init_msg_list,
                                              x_return_status 	   => x_return_status,
                                              x_msg_count     	   => x_msg_count,
                                              x_msg_data      	   => x_msg_data,
                                              p_new_yn            => l_new_yn,
                                              p_asset_number      => NULL,
                                              p_clev_fin_rec      => l_clev_fin_rec,
                                              p_klev_fin_rec      => l_klev_fin_rec,
                                              p_cimv_model_rec    => l_cimv_model_rec,
                                              p_clev_fa_rec       => l_clev_fa_rec,
                                              p_cimv_fa_rec       => l_cimv_fa_rec,
                                              p_talv_fa_rec       => l_talv_fa_rec,
                                              p_itiv_ib_tbl       => l_itiv_tbl,
                                              x_clev_fin_rec      => lx_clev_fin_rec,
                                              x_clev_model_rec    => lx_clev_model_rec,
                                              x_clev_fa_rec       => lx_clev_fa_rec,
                                              x_clev_ib_rec       => lx_clev_ib_rec);
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_create_kle_pvt.create_all_line'
           ,'end debug  call create_all_line');
          END IF;
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --populate quote contract asset id mapping table
          l_qte_cntrct_ast_tbl(l_ast_counter).qte_asset_id    := l_quote_asset_rec.ID;
          l_qte_cntrct_ast_tbl(l_ast_counter).cntrct_asset_id := lx_clev_fin_rec.id;
          l_ast_counter := l_ast_counter+1;
          -- create addons lines
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_addon'
           ,'begin debug  call create_asset_addon');
          END IF;
          create_asset_addon(p_api_version          => p_api_version,
                             p_init_msg_list	    => p_init_msg_list,
                             x_return_status 	   => x_return_status,
                             x_msg_count     	   => x_msg_count,
                             x_msg_data          => x_msg_data,
                             p_clev_fin_rec      => lx_clev_fin_rec,
                             p_asset_id          => l_quote_asset_rec.ID);

         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_addon'
           ,'end debug  call create_asset_addon');
         END IF;
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- create the party as vendor for the supplier present on the asset
         IF l_quote_asset_rec.supplier_id IS NOT NULL THEN
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;

             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_chr_id,
                            p_cle_id             => NULL,
                            p_vendor_id          => l_quote_asset_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'begin debug  call create_vendor');
             END IF;
             create_vendor( p_api_version        => p_api_version,
                            p_init_msg_list	     => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_chr_id             => p_chr_id,
                            p_cle_id             => lx_clev_model_rec.id,
                            p_vendor_id          => l_quote_asset_rec.supplier_id);

             IF(l_debug_enabled='Y') THEN
               okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_vendor'
               ,'end debug  call create_vendor');
             END IF;
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;

         /*
         -- Start : Commented by rravikir for bug#6707125

         -- Procedure create_asset_subsidy is now invoked from
         -- create_contract prodecure after creation of Asset Lines
         -- and Fee Lines

         -- create subsidy lines
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_subsidy'
           ,'begin debug  call create_asset_subsidy');
         END IF;
         create_asset_subsidy( p_api_version         => p_api_version,
                               p_init_msg_list	     => p_init_msg_list,
                               x_return_status 	    => x_return_status,
                               x_msg_count     	    => x_msg_count,
                               x_msg_data      	    => x_msg_data,
                               p_clev_fin_rec       => lx_clev_fin_rec,
                               p_asset_id           => l_quote_asset_rec.ID,
                               p_chr_id             => p_chr_id);

         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_subsidy'
           ,'end debug  call create_asset_subsidy');
         END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         End : Commented by rravikir for bug#6707125
         */

          -- create down payment
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_down_payment'
           ,'begin debug  call create_asset_down_payment');
         END IF;
         create_asset_down_payment( p_api_version         => p_api_version,
                               p_init_msg_list	     => p_init_msg_list,
                               x_return_status 	    => x_return_status,
                               x_msg_count     	    => x_msg_count,
                               x_msg_data      	    => x_msg_data,
                               p_clev_fin_rec       => lx_clev_fin_rec,
                               p_asset_id           => l_quote_asset_rec.ID);

         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_down_payment'
           ,'end debug  call create_asset_down_payment');
         END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
          -- create trade in
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_tradein'
           ,'begin debug  call create_asset_tradein');
         END IF;

         create_asset_tradein( p_api_version         => p_api_version,
                               p_init_msg_list	     => p_init_msg_list,
                               x_return_status 	    => x_return_status,
                               x_msg_count     	    => x_msg_count,
                               x_msg_data      	    => x_msg_data,
                               p_clev_fin_rec       => lx_clev_fin_rec,
                               p_asset_id           => l_quote_asset_rec.ID);

         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_tradein'
           ,'end debug  call create_asset_tradein');
         END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         --create asset rent payments
         l_pymnt_counter := 0;
         l_payment_levels_tbl.DELETE;
         FOR l_asset_payment_rec IN c_get_asset_payment_dtls(l_quote_asset_rec.ID) LOOP
           l_payment_levels_tbl(l_pymnt_counter).START_DATE      := l_asset_payment_rec.START_DATE;
           l_payment_levels_tbl(l_pymnt_counter).PERIODS         := l_asset_payment_rec.NUMBER_OF_PERIODS;
           l_payment_levels_tbl(l_pymnt_counter).AMOUNT          := l_asset_payment_rec.AMOUNT;
           l_payment_levels_tbl(l_pymnt_counter).STUB_DAYS       := l_asset_payment_rec.STUB_DAYS;
           l_payment_levels_tbl(l_pymnt_counter).STUB_AMOUNT     := l_asset_payment_rec.STUB_AMOUNT;
           l_payment_levels_tbl(l_pymnt_counter).PAYMENT_TYPE_ID := l_asset_payment_rec.PAYMENT_TYPE_ID;
           l_payment_levels_tbl(l_pymnt_counter).FREQUENCY_CODE  := l_asset_payment_rec.FREQUENCY_CODE;
           l_payment_levels_tbl(l_pymnt_counter).ARREARS_YN      := l_asset_payment_rec.ARREARS_YN;
           l_pymnt_counter := l_pymnt_counter + 1;
         END LOOP;
         -- create EPT payment
         IF l_payment_levels_tbl.COUNT > 0 THEN
              IF(l_debug_enabled='Y') THEN
                   okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
                   ,'begin  call create_payment_plans');
              END IF;
              create_payment_plans(p_api_version             => p_api_version,
                                     p_init_msg_list	        => p_init_msg_list,
                                     x_return_status 	       => x_return_status,
                                     x_msg_count     	       => x_msg_count,
                                     x_msg_data         	    => x_msg_data,
                                     p_transaction_control   =>  OKL_API.G_FALSE,
                                     p_cle_id                =>  lx_clev_fin_rec.ID,
                                     p_chr_id                =>  l_clev_fin_rec.dnz_chr_id ,
                                     p_payment_type_id       =>  l_payment_levels_tbl(0).PAYMENT_TYPE_ID,
                                     p_payment_frequency     =>  l_payment_levels_tbl(0).FREQUENCY_CODE,
                                     p_payment_arrears       =>  l_payment_levels_tbl(0).ARREARS_YN,
                                     p_payment_structure     =>  NULL,
                                     p_rate_type             =>  NULL,
                                     p_payment_levels_tbl    =>  l_payment_levels_tbl);
              IF(l_debug_enabled='Y') THEN
                   okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
                   ,'end debug  call create_payment_plans');
              END IF;
              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
         END IF;

         --create asset billed down payment details
         l_pymnt_counter := 0;
         l_payment_levels_tbl.DELETE;
         FOR l_asset_payment_rec IN c_get_asset_dppayment_dtls(l_quote_asset_rec.ID) LOOP
           l_payment_levels_tbl(l_pymnt_counter).START_DATE      := l_asset_payment_rec.START_DATE;
           l_payment_levels_tbl(l_pymnt_counter).PERIODS         := l_asset_payment_rec.NUMBER_OF_PERIODS;
           l_payment_levels_tbl(l_pymnt_counter).AMOUNT          := l_asset_payment_rec.AMOUNT;
           l_payment_levels_tbl(l_pymnt_counter).STUB_DAYS       := l_asset_payment_rec.STUB_DAYS;
           l_payment_levels_tbl(l_pymnt_counter).STUB_AMOUNT     := l_asset_payment_rec.STUB_AMOUNT;
           l_payment_levels_tbl(l_pymnt_counter).PAYMENT_TYPE_ID := l_asset_payment_rec.PAYMENT_TYPE_ID;
           l_payment_levels_tbl(l_pymnt_counter).FREQUENCY_CODE  := l_asset_payment_rec.FREQUENCY_CODE;
           l_payment_levels_tbl(l_pymnt_counter).ARREARS_YN      := l_asset_payment_rec.ARREARS_YN;
           l_pymnt_counter := l_pymnt_counter + 1;
         END LOOP;

         IF l_payment_levels_tbl.COUNT > 0 THEN
              IF(l_debug_enabled='Y') THEN
                   okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
                   ,'begin  call create_payment_plans');
              END IF;
              create_payment_plans(p_api_version             => p_api_version,
                                     p_init_msg_list	        => p_init_msg_list,
                                     x_return_status 	       => x_return_status,
                                     x_msg_count     	       => x_msg_count,
                                     x_msg_data         	    => x_msg_data,
                                     p_transaction_control   =>  OKL_API.G_FALSE,
                                     p_cle_id                =>  lx_clev_fin_rec.ID,
                                     p_chr_id                =>  l_clev_fin_rec.dnz_chr_id ,
                                     p_payment_type_id       =>  l_payment_levels_tbl(0).PAYMENT_TYPE_ID,
                                     p_payment_frequency     =>  l_payment_levels_tbl(0).FREQUENCY_CODE,
                                     p_payment_arrears       =>  l_payment_levels_tbl(0).ARREARS_YN,
                                     p_payment_structure     =>  NULL,
                                     p_rate_type             =>  NULL,
                                     p_payment_levels_tbl    =>  l_payment_levels_tbl);
              IF(l_debug_enabled='Y') THEN
                   okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
                   ,'end debug  call create_payment_plans');
              END IF;
              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
         END IF;

         --create asset estimated property tax payments
         l_pymnt_counter := 0;
         l_payment_levels_tbl.DELETE;
         FOR l_asset_payment_rec IN c_get_asset_eptpayment_dtls(l_quote_asset_rec.ID) LOOP
           l_payment_levels_tbl(l_pymnt_counter).START_DATE      := l_asset_payment_rec.START_DATE;
           l_payment_levels_tbl(l_pymnt_counter).PERIODS         := l_asset_payment_rec.NUMBER_OF_PERIODS;
           l_payment_levels_tbl(l_pymnt_counter).AMOUNT          := l_asset_payment_rec.AMOUNT;
           l_payment_levels_tbl(l_pymnt_counter).STUB_DAYS       := l_asset_payment_rec.STUB_DAYS;
           l_payment_levels_tbl(l_pymnt_counter).STUB_AMOUNT     := l_asset_payment_rec.STUB_AMOUNT;
           l_payment_levels_tbl(l_pymnt_counter).PAYMENT_TYPE_ID := l_asset_payment_rec.PAYMENT_TYPE_ID;
           l_payment_levels_tbl(l_pymnt_counter).FREQUENCY_CODE  := l_asset_payment_rec.FREQUENCY_CODE;
           l_payment_levels_tbl(l_pymnt_counter).ARREARS_YN      := l_asset_payment_rec.ARREARS_YN;
           l_pymnt_counter := l_pymnt_counter + 1;
         END LOOP;
         -- create EPT payment
         IF l_payment_levels_tbl.COUNT > 0 THEN
              IF(l_debug_enabled='Y') THEN
                   okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
                   ,'begin  call create_payment_plans');
              END IF;
              create_payment_plans(p_api_version             => p_api_version,
                                     p_init_msg_list	        => p_init_msg_list,
                                     x_return_status 	       => x_return_status,
                                     x_msg_count     	       => x_msg_count,
                                     x_msg_data         	    => x_msg_data,
                                     p_transaction_control   =>  OKL_API.G_FALSE,
                                     p_cle_id                =>  lx_clev_fin_rec.ID,
                                     p_chr_id                =>  l_clev_fin_rec.dnz_chr_id ,
                                     p_payment_type_id       =>  l_payment_levels_tbl(0).PAYMENT_TYPE_ID,
                                     p_payment_frequency     =>  l_payment_levels_tbl(0).FREQUENCY_CODE,
                                     p_payment_arrears       =>  l_payment_levels_tbl(0).ARREARS_YN,
                                     p_payment_structure     =>  NULL,
                                     p_rate_type             =>  NULL,
                                     p_payment_levels_tbl    =>  l_payment_levels_tbl);
              IF(l_debug_enabled='Y') THEN
                   okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
                   ,'end debug  call create_payment_plans');
              END IF;
              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
         END IF;
   END LOOP;

   --update contract header with total trade in amount and date
   FOR l_ti_amt_rec IN get_ti_amt(l_lapv_rec.QUOTE_ID) LOOP
     l_ti_amt := l_ti_amt_rec.total_tradein;
   END LOOP;
   FOR l_ti_des_rec IN get_ti_desc(l_lapv_rec.QUOTE_ID) LOOP
     l_ti_desc := l_ti_des_rec.description;
   END LOOP;
   IF l_ti_amt IS NOT NULL THEN
       IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_tradein'
           ,'begin debug  call create_asset_tradein');
       END IF;
       okl_la_tradein_pvt.update_contract( p_api_version        => p_api_version,
                                           p_init_msg_list	    => p_init_msg_list,
                                           x_return_status 	    => x_return_status,
                                           x_msg_count     	    => x_msg_count,
                                           x_msg_data      	    => x_msg_data,
                                           p_chr_id             => l_chr_id,
                                           p_tradein_date       => l_lapv_rec.expected_start_date,
                                           p_tradein_amount     => l_ti_amt,
                                           p_tradein_desc       => l_ti_desc);

       IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_tradein'
           ,'end debug  call create_asset_tradein');
       END IF;
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   END IF;
   /*
   --create contract level payment
   l_pymnt_counter := 1;
   FOR l_quote_payment_rec IN c_get_quote_payment_dtls(l_lapv_rec.QUOTE_ID) LOOP
         l_pym_tbl(l_pymnt_counter).PERIOD          := l_quote_payment_rec.NUMBER_OF_PERIODS;
         l_pym_tbl(l_pymnt_counter).AMOUNT          := l_quote_payment_rec.AMOUNT;
         l_pym_tbl(l_pymnt_counter).STUB_DAYS       := l_quote_payment_rec.STUB_DAYS;
         l_pym_tbl(l_pymnt_counter).STUB_AMOUNT     := l_quote_payment_rec.STUB_AMOUNT;
         l_pym_tbl(l_pymnt_counter).UPDATE_TYPE     := 'CREATE';
         l_pym_hdr_rec.ARREARS := l_quote_payment_rec.ARREARS_YN;
         l_pym_hdr_rec.frequency := l_quote_payment_rec.FREQUENCY_CODE;
         l_payment_type_id := l_quote_payment_rec.payment_type_id;
         l_pymnt_counter := l_pymnt_counter + 1;
   END LOOP;
       -- createcontract level payment
   IF l_pym_tbl.COUNT > 0 THEN
      IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
           ,'begin  call okl_la_payments_pvt.process_payment');
      END IF;
      okl_la_payments_pvt.process_payment(p_api_version     => p_api_version,
                             p_init_msg_list	            => p_init_msg_list,
                             x_return_status 	            => x_return_status,
                             x_msg_count     	            => x_msg_count,
                             x_msg_data         	        => x_msg_data,
                             p_chr_id                       => l_chr_id ,
                             p_service_fee_id               => NULL,
                             p_asset_id                     => NULL,
                             p_payment_id                   => l_payment_type_id,
                             p_pym_hdr_rec                  => l_pym_hdr_rec,
                             p_pym_tbl                      => l_pym_tbl,
                             p_update_type                  => 'UPDATE',
                             x_rulv_tbl                     => lx_rulv_tbl);
      IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_payment_plans'
           ,'end debug  call okl_la_payments_pvt.process_payment');
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   END IF;
   */
   x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data);
   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_asset_lines;
-------------------------------------------------------------------------------
  -- PROCEDURE create_rules
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rules
  -- Description     : This procedure is a wrapper that creates contract rules(Terms and Conditions) from lease application/quote header
  --
  -- Business Rules  : this procedure is used to create a contract rules(Terms and Conditions)  from lease application/quote header
  --                 : The following details are copied to a Lease Contract from a credit approved Lease Application
  --                 : Lease Application Header party details
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_rules(p_api_version                  IN NUMBER,
                         p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
                         p_chr_id                       IN  NUMBER,
                         p_lapv_rec                     IN  c_get_leaseapp_hdr%ROWTYPE)IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_RUL';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    lx_rgp_id                     NUMBER;
    l_contract_temp_id            NUMBER;
    l_chr_id                      NUMBER;
    l_lapv_rec                    c_get_leaseapp_hdr%ROWTYPE;

    --rule rec
    lp_rgpv_rec                   OKL_RULE_PUB.rgpv_rec_type;
    lx_rgpv_rec                   OKL_RULE_PUB.rgpv_rec_type;
    lp_rgpv_tbl                   OKL_RULE_PUB.rgpv_tbl_type;
    lx_rgpv_tbl                   OKL_RULE_PUB.rgpv_tbl_type;
    lp_rulv_rec                   OKL_RULE_PUB.rulv_rec_type;
    lx_rulv_rec                   OKL_RULE_PUB.rulv_rec_type;
    lp_rulv_tbl                   OKL_RULE_PUB.rulv_tbl_type;
    lx_rulv_tbl                   OKL_RULE_PUB.rulv_tbl_type;
    lp_rgr_rec                    OKL_RGRP_RULES_PROCESS_PVT.rgr_rec_type;
    lp_rgr_tbl                    OKL_RGRP_RULES_PROCESS_PVT.rgr_tbl_type;
    i                             NUMBER;
    --Cursor declaration
    --Get the contract template id associated with lease app template
    CURSOR c_get_contract_temp(p_lap_id IN okl_lease_applications_v.ID%TYPE) IS
    SELECT olav.ID,olvv.CONTRACT_TEMPLATE_ID
    FROM   okl_leaseapp_templ_versions_v olvv,
           okl_lease_applications_v olav
    WHERE  olav.leaseapp_template_id = olvv.ID
    AND    olav.ID = p_lap_id;

    CURSOR c_rgpv (p_chr_tmp_id okl_leaseapp_templ_versions_v.CONTRACT_TEMPLATE_ID%TYPE)IS
    SELECT rgp.id
    FROM okc_rule_groups_b rgp, okc_subclass_rg_defs rg_defs
    WHERE rgp.dnz_chr_id = p_chr_tmp_id
    AND rgp.rgd_code = rg_defs.rgd_code
    AND rg_defs.scs_code = 'LEASE'
    AND  rgp.cle_id IS NULL
    AND  rgp.rgd_code NOT IN ('LATOWN','CURRENCY');
  BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- check for logging on PROCEDURE level
      l_debug_enabled := okl_debug_pub.check_log_enabled;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                                ,p_pkg_name      => G_PKG_NAME
                                                ,p_init_msg_list => p_init_msg_list
                                                ,l_api_version   => l_api_version
                                                ,p_api_version   => p_api_version
                                                ,p_api_type      => g_api_type
                                                ,x_return_status => x_return_status);
      -- check if activity started successfully
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_chr_id    := p_chr_id;
      l_lapv_rec  := p_lapv_rec;
      -- create rules
      OPEN c_get_contract_temp(l_lapv_rec.ID);
      FETCH c_get_contract_temp INTO l_lapv_rec.ID,l_contract_temp_id;
      CLOSE c_get_contract_temp;
      IF l_lapv_rec.ID IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'quote_chr_id_not_found');
      x_return_status := OKL_API.g_ret_sts_error;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      IF l_contract_temp_id IS NOT NULL THEN
        FOR l_c_rgpv IN c_rgpv(l_contract_temp_id) LOOP
           IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_COPY_CONTRACT_PUB.copy_rules'
           ,'begin debug  call copy_rules');
           END IF;
           OKL_COPY_CONTRACT_PUB.copy_rules (p_api_version	      => p_api_version,
                                             p_init_msg_list	    => p_init_msg_list,
                                             x_return_status 	   => x_return_status,
                                             x_msg_count     	   => x_msg_count,
                                             x_msg_data      	   => x_msg_data,
                                             p_rgp_id	      	    => l_c_rgpv.id,
                                             p_cle_id		          => NULL,
                                             p_chr_id	           => l_chr_id, -- the new generated contract header id
                                             p_to_template_yn    => 'N',
                                             x_rgp_id		          => lx_rgp_id);
           IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_COPY_CONTRACT_PUB.copy_rules'
           ,'end debug call copy_rules');
           END IF;
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END LOOP;
      END IF;
     i := 1;
      --create property trax rule if required.
      IF (l_lapv_rec.PROPERTY_TAX_APPLICABLE IS NOT NULL AND
         l_lapv_rec.PROPERTY_TAX_BILLING_TYPE IS NOT NULL )
      THEN
         lp_rgr_tbl(i).rgd_code                  := 'LAHDTX';
         lp_rgr_tbl(i).object_version_number     :=  '1.0';
         lp_rgr_tbl(i).sfwt_flag                 := OKC_API.G_FALSE;
         lp_rgr_tbl(i).std_template_yn           := 'N';
         lp_rgr_tbl(i).warn_yn                   := 'N';
         lp_rgr_tbl(i).template_yn               := 'N';
         lp_rgr_tbl(i).rule_information_category := 'LAPRTX';
         lp_rgr_tbl(i).rule_information1         := l_lapv_rec.PROPERTY_TAX_APPLICABLE;
         lp_rgr_tbl(i).rule_information2         := 'N';
         lp_rgr_tbl(i).rule_information3         := l_lapv_rec.PROPERTY_TAX_BILLING_TYPE;
         i := i+1;
      END IF;
      --create sales tax rule if required
      IF l_lapv_rec.UPFRONT_TAX_TREATMENT IS NOT NULL AND
         l_lapv_rec.UPFRONT_TAX_STREAM_TYPE IS NOT NULL
      THEN
          lp_rgr_tbl(i).rgd_code                  := 'LAHDTX';
          lp_rgr_tbl(i).object_version_number     := '1.0';
          lp_rgr_tbl(i).sfwt_flag                 := OKC_API.G_FALSE;
          lp_rgr_tbl(i).std_template_yn           := 'N';
          lp_rgr_tbl(i).warn_yn                   := 'N';
          lp_rgr_tbl(i).template_yn               := 'N';
          lp_rgr_tbl(i).rule_information_category := 'LASTPR';
          lp_rgr_tbl(i).rule_information1         := l_lapv_rec.UPFRONT_TAX_TREATMENT;
          lp_rgr_tbl(i).rule_information3         := l_lapv_rec.UPFRONT_TAX_STREAM_TYPE;
          --Bug 5908845. eBTax Enhancement Project
          lp_rgr_tbl(i).rule_information5         := l_lapv_rec.LINE_INTENDED_USE;
          -- End Bug 5908845. eBTax Enhancement Project
          i := i+1;
      END IF;
     --copy tax parameters
      IF (l_lapv_rec.TRANSFER_OF_TITLE IS NOT NULL OR
         l_lapv_rec.AGE_OF_EQUIPMENT IS NOT NULL OR
         l_lapv_rec.PURCHASE_OF_LEASE IS NOT NULL OR
         l_lapv_rec.SALE_AND_LEASE_BACK IS NOT NULL OR
         l_lapv_rec.INTEREST_DISCLOSED IS NOT NULL)
      THEN
          lp_rgr_tbl(i).rgd_code                 := 'LAHDTX';
          lp_rgr_tbl(i).object_version_number    := '1.0';
          lp_rgr_tbl(i).sfwt_flag                := OKC_API.G_FALSE;
          lp_rgr_tbl(i).std_template_yn          := 'N';
          lp_rgr_tbl(i).warn_yn                  := 'N';
          lp_rgr_tbl(i).template_yn              := 'N';
          lp_rgr_tbl(i).rule_information_category := 'LASTCL';
          lp_rgr_tbl(i).rule_information1        := 'N';
          lp_rgr_tbl(i).rule_information2        := l_lapv_rec.INTEREST_DISCLOSED;
          lp_rgr_tbl(i).rule_information3        := l_lapv_rec.TRANSFER_OF_TITLE;
          lp_rgr_tbl(i).rule_information4        := l_lapv_rec.SALE_AND_LEASE_BACK;
          lp_rgr_tbl(i).rule_information5        := l_lapv_rec.PURCHASE_OF_LEASE;
          lp_rgr_tbl(i).rule_information7        := l_lapv_rec.AGE_OF_EQUIPMENT;
          i := i+1;
        END IF;

        lp_rgr_tbl(i).rgd_code                 := 'LAHDTX';
        lp_rgr_tbl(i).object_version_number    := '1.0';
        -- create all rules under this rule group
        lp_rgr_tbl(i).sfwt_flag                := OKC_API.G_FALSE;
        lp_rgr_tbl(i).std_template_yn          := 'N';
        lp_rgr_tbl(i).warn_yn                  := 'N';
        lp_rgr_tbl(i).template_yn              := 'N';
        lp_rgr_tbl(i).rule_information_category  := 'LAMETX';
        lp_rgr_tbl(i).rule_information1        := 'N';
        i := i+1;

        lp_rgr_tbl(i).rgd_code                 := 'LAHDTX';
        lp_rgr_tbl(i).object_version_number    := '1.0';
        -- create all rules under this rule group
        lp_rgr_tbl(i).sfwt_flag                := OKC_API.G_FALSE;
        lp_rgr_tbl(i).std_template_yn          := 'N';
        lp_rgr_tbl(i).warn_yn                  := 'N';
        lp_rgr_tbl(i).template_yn              := 'N';
        lp_rgr_tbl(i).rule_information_category := 'LAAUTX';
        lp_rgr_tbl(i).rule_information1 := 'N';

          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules'
           ,'begin debug  call process_rule_group_rules');
          END IF;
          OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules( p_api_version          => p_api_version,
                                                               p_init_msg_list	       => p_init_msg_list,
                                                               x_return_status 	      => x_return_status,
                                                               x_msg_count     	      => x_msg_count,
                                                               x_msg_data             => x_msg_data,
                                                               p_chr_id               => l_chr_id,
                                                               p_line_id              => NULL,
                                                               p_cpl_id               => NULL,
                                                               p_rrd_id               => NULL,
                                                               p_rgr_tbl              => lp_rgr_tbl);
          IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules'
           ,'end debug  call process_rule_group_rules');
          END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

   x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data);
   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_rules;
 -------------------------------------------------------------------------------
  -- PROCEDURE create_party_roles
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_lease_app_template
  -- Description     : This procedure is a wrapper that creates t contract party roles from lease application/quote header
  --
  -- Business Rules  : this procedure is used to create a contract party roles from lease application/quote header
  --                 : The following details are copied to a Lease Contract from a credit approved Lease Application
  --                 : Lease Application Header party details
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_party_roles(p_api_version                  IN  NUMBER,
                               p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status                OUT NOCOPY VARCHAR2,
                               x_msg_count                    OUT NOCOPY NUMBER,
                               x_msg_data                     OUT NOCOPY VARCHAR2,
                               p_chr_id                       IN  NUMBER,
                               p_lapv_rec                     IN  c_get_leaseapp_hdr%ROWTYPE)IS
   -- Variables Declarations
   l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
   l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_PTY_RLS';
   l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_debug_enabled               VARCHAR2(10);
   l_chr_id                      NUMBER;
   l_access_level                OKC_ROLE_SOURCES.access_level%TYPE;
   row_count                     NUMBER DEFAULT 0;
   l_cplv_id                     NUMBER;
   l_party_name                  VARCHAR2(200);
   l_party_desc                  VARCHAR2(2000);
   l_lapv_rec                    c_get_leaseapp_hdr%ROWTYPE;
   -- Record/Table Type Declarations
   --party rec
   lp_cplv_rec                   okl_okc_migration_pvt.cplv_rec_type;
   lx_cplv_rec                   okl_okc_migration_pvt.cplv_rec_type;
   --party contacts rec
   lp_ctcv_rec                   OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
   lx_ctcv_rec                   OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;

   lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
   lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
    --Check for the existing party roles
    CURSOR check_party_csr(p_chr_id NUMBER,p_customer_id  NUMBER) IS
    SELECT COUNT(1)
    FROM okc_k_party_roles_v
    WHERE dnz_chr_id = p_chr_id
    AND chr_id = p_chr_id
    AND rle_code = G_RLE_CODE
    AND object1_id1 = p_customer_id;
    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE   rle_code = p_rle_code
    AND     buy_or_sell = 'S';
    --Get the vendor id
    CURSOR c_cplv (p_khr_id IN okl_lease_applications_v.PROGRAM_AGREEMENT_ID%TYPE) IS
    SELECT cpl.id,  cpl.object1_id1
    FROM okc_k_party_roles_b cpl, okc_subclass_roles ROLES
    WHERE dnz_chr_id = p_khr_id
    AND cpl.rle_code = ROLES.rle_code
    AND cpl.rle_code = 'OKL_VENDOR'
    AND ROLES.scs_code = 'LEASE'
    AND cpl.cle_id IS NULL;

     -- ER# 9161779 - Start
           -- Cursor to get the contract template attached to a lease application template of a lease app
       CURSOR c_get_contract_temp(p_lap_id IN okl_lease_applications_v.ID%TYPE) IS
       SELECT olvv.contract_template_id
        FROM   okl_leaseapp_templ_versions_b olvv,
                    okl_lease_applications_b olav
       WHERE  olav.leaseapp_template_id = olvv.ID -- lease app stores the template version id
            AND olav.ID = p_lap_id
            AND EXISTS (SELECT 1
                      FROM   okl_k_headers khr
                      WHERE  khr.ID = olvv.contract_template_id
                             AND khr.template_type_code = 'CONTRACT') -- Consider only contract templates and not lease app contract templates
        ;

        -- From lease application, get to the case folder and fetch all guarantors
       CURSOR c_get_guarantors(cp_lap_id IN okl_lease_applications_v.ID%TYPE) IS
        SELECT credreq.trx_amount amount_requested, gdata.*
          FROM   ar_cmgt_credit_requests credreq,
                       ar_cmgt_guarantor_data gdata
           WHERE  gdata.credit_request_id = credreq.credit_request_id
                 AND credreq.source_column3 = 'LEASEAPP'
                AND credreq.source_column1 = cp_lap_id;

            -- Cursor checks if party already exists
       CURSOR c_chk_party_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE
                                                   , p_rle_code okc_k_party_roles_b.RLE_CODE%TYPE
                                                                                           , p_object1_id1 okc_k_party_roles_b.object1_id1%TYPE) IS
        SELECT 1
         FROM   okc_k_party_roles_b p_role
         WHERE  p_role.dnz_chr_id = p_chr_id
            AND p_role.rle_code = p_rle_code
                    AND p_role.object1_id1 = p_object1_id1;

           -- Cursor to get specific parties of the contract template
       CURSOR c_get_party_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE
                                                   , p_rle_code okc_k_party_roles_b.RLE_CODE%TYPE) IS
        SELECT p_role.ID,
          p_role.object1_id1,
          p_role.object1_id2,
          p_role.jtot_object1_code,
          p_role.rle_code
         FROM   okc_k_party_roles_b p_role
         WHERE  p_role.dnz_chr_id = p_chr_id
            AND p_role.rle_code = p_rle_code;

           -- Cursor to get parties of the contract template - parties other than Lessee, Lessor, Vendor
           -- Get Guarantors from contract template and those that are not in case folder of lease app
       CURSOR c_get_other_party_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE
                                                                ,cp_lap_id IN okl_lease_applications_v.ID%TYPE) IS
        SELECT p_role.ID,
          p_role.object1_id1,
          p_role.object1_id2,
          p_role.jtot_object1_code,
          p_role.rle_code
         FROM   okc_k_party_roles_b p_role
         WHERE  p_role.dnz_chr_id = p_chr_id
            AND (p_role.rle_code NOT IN ('LESSEE', 'LESSOR', 'OKL_VENDOR')
                      OR (p_role.rle_code = 'GUARANTOR'
                                              AND  p_role.jtot_object1_code= 'OKX_PARTY'
                                              AND p_role.object1_id1 NOT IN ( SELECT gdata.PARTY_ID
                                                                                                             FROM   ar_cmgt_credit_requests credreq,
                                                                                                  ar_cmgt_guarantor_data gdata
                                                                                    WHERE  gdata.credit_request_id = credreq.credit_request_id
                                                                                          AND credreq.source_column3 = 'LEASEAPP'
                                                                                          AND credreq.source_column1 = cp_lap_id
                                                                                   )
                                            )
                            );

       Cursor c_rrd_id (cp_chr_id OKC_K_HEADERS_B.ID%TYPE) is
       SELECT  rgrdfs.id
       from    okc_k_headers_b chr,
               okc_subclass_roles sre,
               okc_role_sources rse,
               okc_subclass_rg_defs rgdfs,
               okc_rg_role_defs rgrdfs
       where   chr.id =  cp_chr_id
         and   sre.scs_code = chr.scs_code
         and   sre.rle_code = rse.rle_code
         and   rse.rle_code = 'GUARANTOR'
         and   rse.buy_or_sell = chr.buy_or_sell
         and   rgdfs.scs_code = chr.scs_code
         and   rgdfs.rgd_code = 'LAGRDT'
         and   rgrdfs.srd_id = rgdfs.id
         and   rgrdfs.sre_id = sre.id;


           CURSOR c_get_primary_address(cp_party_id HZ_PARTIES.PARTY_ID%TYPE ) IS
       SELECT PARTY_SITE_ID
        FROM   HZ_PARTY_SITES
       WHERE  party_id = cp_party_id
          AND status = 'A'
          AND identifying_address_flag = 'Y' ;

        -- Variables Declaration Section
        null_cplv_rec                  okl_okc_migration_pvt.cplv_rec_type;
        null_kplv_rec                  okl_k_party_roles_pvt.kplv_rec_type;
        lp_rgpv_rec OKL_RULE_PUB.rgpv_rec_type;
        lx_rgpv_rec OKL_RULE_PUB.rgpv_rec_type;
        l_rulv_tbl OKL_RULE_PUB.rulv_tbl_type;
        x_rulv_tbl OKL_RULE_PUB.rulv_tbl_type;
        lp_rmpv_rec OKL_RULE_PUB.rmpv_rec_type;
        lx_rmpv_rec OKL_RULE_PUB.rmpv_rec_type;

            c_get_party_rec            c_get_party_csr%ROWTYPE;
            l_chr_tmpl_id                  OKC_K_HEADERS_B.ID%TYPE;
            l_party_site_id               HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
            lx_cpl_id                         NUMBER;
            l_rrd_id                         NUMBER;
            l_create_party_for_lap BOOLEAN;
            l_tmp NUMBER;
        -- ER# 9161779 - End

   BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- check for logging on PROCEDURE level
      l_debug_enabled := okl_debug_pub.check_log_enabled;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                                ,p_pkg_name      => G_PKG_NAME
                                                ,p_init_msg_list => p_init_msg_list
                                                ,l_api_version   => l_api_version
                                                ,p_api_version   => p_api_version
                                                ,p_api_type      => g_api_type
                                                ,x_return_status => x_return_status);
      -- check if activity started successfully
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_chr_id    := p_chr_id;
      l_lapv_rec  := p_lapv_rec;

     -- ER# 9161779 - Start
            -- Get the information on the contract template attached to the lease app template
            l_chr_tmpl_id := NULL;
            OPEN c_get_contract_temp(l_lapv_rec.ID);
              FETCH c_get_contract_temp INTO l_chr_tmpl_id;
            CLOSE c_get_contract_temp;
        -- ER# 9161779 - End

        -- ER# 9161779 - Start
            l_create_party_for_lap := TRUE;

            IF (l_chr_tmpl_id IS NOT NULL) THEN
              -- Check if the lessee on the contract template is the same as prospect of lease app
              OPEN c_get_party_csr(l_chr_tmpl_id,G_RLE_CODE);
                FETCH c_get_party_csr INTO c_get_party_rec;
              CLOSE c_get_party_csr;

              IF (c_get_party_rec.object1_id1 = l_lapv_rec.PROSPECT_ID) THEN

                    -- Copy the lessee from the contract template - copies DFF as well
            okl_copy_contract_pub.copy_party_roles(
                                                 p_api_version     => p_api_version,
                                                 p_init_msg_list   => p_init_msg_list,
                                                 x_return_status   => x_return_status,
                                                 x_msg_count       => x_msg_count,
                                                 x_msg_data        => x_msg_data,
                                                 p_cpl_id               => c_get_party_rec.id,
                                                 p_cle_id               => NULL,
                                                 p_chr_id              => l_chr_id,
                                                 p_rle_code          => c_get_party_rec.rle_code,
                                                 x_cpl_id                => lx_cpl_id
                                                );
            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

                -- Set the flag to false so that lessee is not created again
            l_create_party_for_lap := FALSE;
              END IF;

            END IF;
        -- ER# 9161779 - End

     IF l_create_party_for_lap THEN -- ER# 9161779
      lp_cplv_rec := null_cplv_rec; -- ER# 9161779
      lp_kplv_rec := null_kplv_rec; -- ER# 9161779

      -- now we attach the party to the header
      lp_cplv_rec.object_version_number := 1.0;
      lp_cplv_rec.sfwt_flag             := OKC_API.G_FALSE;
      lp_cplv_rec.dnz_chr_id            := l_chr_id;
      lp_cplv_rec.chr_id                := l_chr_id;
      lp_cplv_rec.cle_id                := NULL;
      lp_cplv_rec.object1_id1           := l_lapv_rec.PROSPECT_ID;
      lp_cplv_rec.object1_id2           := '#';
      lp_cplv_rec.jtot_object1_code     := 'OKX_PARTY';
      lp_cplv_rec.rle_code              := G_RLE_CODE;

      OPEN  check_party_csr(l_chr_id,l_lapv_rec.PROSPECT_ID);
      FETCH check_party_csr INTO row_count;
      CLOSE check_party_csr;
      IF row_count = 1 THEN
        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_already_exists');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Validate the JTOT Object code, ID1 and ID2
      OPEN role_csr(lp_cplv_rec.rle_code);
      FETCH role_csr INTO l_access_level;
      CLOSE role_csr;
      IF (l_access_level = 'S') THEN
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT'
           ,'begin debug  call VALIDATE_ROLE_JTOT');
         END IF;
         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version     => p_api_version,
                                                        p_init_msg_list   => OKC_API.G_FALSE,
                                                        x_return_status   => x_return_status,
                                                        x_msg_count	      => x_msg_count,
                                                        x_msg_data	       => x_msg_data,
                                                        p_object_name     => lp_cplv_rec.jtot_object1_code,
                                                        p_id1             => lp_cplv_rec.object1_id1,
                                                        p_id2             => lp_cplv_rec.object1_id2);
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT'
           ,'end debug  call VALIDATE_ROLE_JTOT');
         END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;
      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
         ,'begin debug  call create_k_party_role');
      END IF;

      lp_kplv_rec.validate_dff_yn := 'Y';

      okl_k_party_roles_pvt.create_k_party_role(
                                      p_api_version      => p_api_version,
                                      p_init_msg_list    => p_init_msg_list,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_cplv_rec         => lp_cplv_rec,
                                      x_cplv_rec         => lx_cplv_rec,
                                      p_kplv_rec         => lp_kplv_rec,
                                      x_kplv_rec         => lx_kplv_rec);
      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
         ,'end debug  call create_k_party_role');
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     END IF; -- ER# 9161779

      -- Create Lessor
       -- ER# 9161779 - Start
            l_create_party_for_lap := TRUE;

            IF (l_chr_tmpl_id IS NOT NULL) THEN
              -- Check if the lessee on the contract template is the same as prospect of lease app
              OPEN c_get_party_csr(l_chr_tmpl_id,'LESSOR');
                FETCH c_get_party_csr INTO c_get_party_rec;
              CLOSE c_get_party_csr;

              IF (c_get_party_rec.object1_id1 = l_lapv_rec.ORG_ID) THEN

                    -- Copy the lessee from the contract template - copies DFF as well
            okl_copy_contract_pub.copy_party_roles(
                                                 p_api_version     => p_api_version,
                                                 p_init_msg_list   => p_init_msg_list,
                                                 x_return_status   => x_return_status,
                                                 x_msg_count       => x_msg_count,
                                                 x_msg_data        => x_msg_data,
                                                 p_cpl_id               => c_get_party_rec.id,
                                                 p_cle_id               => NULL,
                                                 p_chr_id              => l_chr_id,
                                                 p_rle_code          => c_get_party_rec.rle_code,
                                                 x_cpl_id                => lx_cpl_id
                                                );
            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_cplv_id := lx_cpl_id; --Added by bkatraga for bug 9439724

                -- Set the flag to false so that lessor is not created again
            l_create_party_for_lap := FALSE;
              END IF;

            END IF;
        -- ER# 9161779 - End

	IF l_create_party_for_lap THEN -- ER# 9161779
      lp_cplv_rec := null_cplv_rec; -- ER# 9161779
      lp_kplv_rec := null_kplv_rec; -- ER# 9161779

      -- now we attach the party to the header
      lp_cplv_rec.object_version_number := 1.0;
      lp_cplv_rec.sfwt_flag             := OKC_API.G_FALSE;
      lp_cplv_rec.dnz_chr_id            := l_chr_id;
      lp_cplv_rec.chr_id                := l_chr_id;
      lp_cplv_rec.cle_id                := NULL;
      lp_cplv_rec.object1_id1           := l_lapv_rec.ORG_ID;
      lp_cplv_rec.object1_id2           := '#';
      lp_cplv_rec.jtot_object1_code     := 'OKX_OPERUNIT';
      lp_cplv_rec.rle_code              := 'LESSOR';

      OPEN check_party_csr(l_chr_id,l_lapv_rec.ORG_ID);
      FETCH check_party_csr INTO row_count;
      CLOSE check_party_csr;
      IF row_count = 1 THEN
        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_already_exists');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Validate the JTOT Object code, ID1 and ID2
      OPEN  role_csr(lp_cplv_rec.rle_code);
      FETCH role_csr INTO l_access_level;
      CLOSE role_csr;
      IF (l_access_level = 'S') THEN
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT'
           ,'begin debug  call VALIDATE_ROLE_JTOT');
         END IF;
         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                        p_init_msg_list  => OKC_API.G_FALSE,
                                                        x_return_status  => x_return_status,
                                                        x_msg_count	     => x_msg_count,
                                                        x_msg_data	      => x_msg_data,
                                                        p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                        p_id1            => lp_cplv_rec.object1_id1,
                                                        p_id2            => lp_cplv_rec.object1_id2);
         IF(l_debug_enabled='Y') THEN
           okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT'
           ,'end debug  call VALIDATE_ROLE_JTOT');
         END IF;
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
     END IF;
     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
        ,'begin debug  call create_k_party_role');
     END IF;

     lp_kplv_rec.validate_dff_yn := 'Y';

     okl_k_party_roles_pvt.create_k_party_role(
                                      p_api_version      => p_api_version,
                                      p_init_msg_list    => p_init_msg_list,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_cplv_rec         => lp_cplv_rec,
                                      x_cplv_rec         => lx_cplv_rec,
                                      p_kplv_rec         => lp_kplv_rec,
                                      x_kplv_rec         => lx_kplv_rec);
     IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
        ,'end debug  call create_k_party_role');
     END IF;
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_cplv_id := lx_cplv_rec.ID; --Added by bkatraga for bug 9439724

   END IF; -- ER# 9161779

     --l_cplv_id := lx_cplv_rec.ID; //Commented line by bkatraga for bug 9439724
     lp_ctcv_rec.object_version_number := 1.0;
     lp_ctcv_rec.cpl_id := l_cplv_id;
     lp_ctcv_rec.cro_code := 'SALESPERSON';
     lp_ctcv_rec.dnz_chr_id := l_chr_id;
     lp_ctcv_rec.object1_id1 := l_lapv_rec.SALES_REP_ID;
     lp_ctcv_rec.object1_id2 := '#';
     lp_ctcv_rec.jtot_object1_code := 'OKX_SALEPERS';
     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKC_CONTRACT_PARTY_PUB.create_contact'
         ,'begin debug  call create_contact');
     END IF;
     OKC_CONTRACT_PARTY_PUB.create_contact(p_api_version	   => p_api_version,
                                           p_init_msg_list	 => p_init_msg_list,
                                           x_return_status 	=> l_return_status,
                                           x_msg_count     	=> x_msg_count,
                                           x_msg_data      	=> x_msg_data,
                                           p_ctcv_rec		     => lp_ctcv_rec,
                                           x_ctcv_rec	      => lx_ctcv_rec);
     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKC_CONTRACT_PARTY_PUB.create_contact'
         ,'end debug  call create_contact');
     END IF;
     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
           x_return_status := OKC_API.G_RET_STS_WARNING;
      okc_util.get_name_desc_from_jtfv(p_object_code   => lx_cplv_rec.jtot_object1_code,
                                       p_id1           => lx_cplv_rec.object1_id1,
                                       p_id2           => lx_cplv_rec.object1_id2,
                                       x_name          => l_party_name,
                                       x_description   => l_party_desc);
            OKC_API.set_message(G_APP_NAME,'OKC_CONTACT_NOT_COPIED','PARTY_NAME',l_party_name);
        END IF;
     END IF;
      -- create vendor
      -- ER# 9161779 - Start
             -- If contract template exists, copy over vendors from contract template - Copy all the vendors from contract template to the new contract
             IF l_chr_tmpl_id IS NOT NULL THEN
           FOR c_get_party_rec IN c_get_party_csr(l_chr_tmpl_id,'OKL_VENDOR')
               LOOP
             okl_copy_contract_pub.copy_party_roles(
                                                 p_api_version     => p_api_version,
                                                 p_init_msg_list   => p_init_msg_list,
                                                 x_return_status   => x_return_status,
                                                 x_msg_count       => x_msg_count,
                                                 x_msg_data        => x_msg_data,
                                                 p_cpl_id               => c_get_party_rec.id,
                                                 p_cle_id               => NULL,
                                                 p_chr_id              => l_chr_id,
                                                 p_rle_code          => c_get_party_rec.rle_code,
                                                 x_cpl_id                => lx_cpl_id
                                                );
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
               END LOOP;
             END IF;
         -- ER# 9161779 - End

      FOR l_c_cplv IN c_cplv(l_lapv_rec.PROGRAM_AGREEMENT_ID) LOOP
       -- ER# 9161779 - Start
              l_create_party_for_lap := TRUE;
                   -- Check if vendor is already created in the new contract
                   OPEN  c_chk_party_csr(l_chr_id,'OKL_VENDOR',l_c_cplv.object1_id1);
                     FETCH c_chk_party_csr INTO l_tmp;
                     IF c_chk_party_csr%FOUND THEN
                       l_create_party_for_lap := FALSE;
                     END IF;
                   CLOSE c_chk_party_csr;
          -- ER# 9161779 - End

       IF l_create_party_for_lap THEN -- ER# 9161779
          lp_cplv_rec := null_cplv_rec; -- ER# 9161779
          lp_kplv_rec := null_kplv_rec; -- ER# 9161779

            lp_cplv_rec.object_version_number := 1.0;
            lp_cplv_rec.sfwt_flag             := OKC_API.G_FALSE;
            lp_cplv_rec.dnz_chr_id            := l_chr_id;
            lp_cplv_rec.chr_id                := l_chr_id;
            lp_cplv_rec.cle_id                := NULL;
            lp_cplv_rec.object1_id1           := l_c_cplv.object1_id1;
            lp_cplv_rec.object1_id2           := '#';
            lp_cplv_rec.jtot_object1_code     := 'OKX_VENDOR';
            lp_cplv_rec.rle_code              := 'OKL_VENDOR';

            OPEN check_party_csr(l_chr_id,l_c_cplv.object1_id1);
            FETCH check_party_csr INTO row_count;
            CLOSE check_party_csr;
            IF row_count = 1 THEN
              x_return_status := OKC_API.g_ret_sts_error;
              OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_already_exists');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            --Validate the JTOT Object code, ID1 and ID2
            OPEN  role_csr(lp_cplv_rec.rle_code);
            FETCH role_csr INTO l_access_level;
            CLOSE role_csr;
            IF (l_access_level = 'S') THEN
               IF(l_debug_enabled='Y') THEN
                 okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT'
                 ,'begin debug  call VALIDATE_ROLE_JTOT');
               END IF;
               okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                              p_init_msg_list  => OKC_API.G_FALSE,
                                                              x_return_status  => x_return_status,
                                                              x_msg_count	     => x_msg_count,
                                                              x_msg_data	      => x_msg_data,
                                                              p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                              p_id1            => lp_cplv_rec.object1_id1,
                                                              p_id2            => lp_cplv_rec.object1_id2);
               IF(l_debug_enabled='Y') THEN
                 okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT'
                 ,'end debug  call VALIDATE_ROLE_JTOT');
               END IF;
               IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
            END IF;
            IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
              ,'begin debug  call create_k_party_role');
            END IF;


            okl_k_party_roles_pvt.create_k_party_role(
                                            p_api_version      => p_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
                                            p_cplv_rec         => lp_cplv_rec,
                                            x_cplv_rec         => lx_cplv_rec,
                                            p_kplv_rec         => lp_kplv_rec,
                                            x_kplv_rec         => lx_kplv_rec);
           IF(l_debug_enabled='Y') THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_k_party_roles_pvt.create_k_party_role'
              ,'end debug  call create_k_party_role');
           END IF;

          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;-- ER# 9161779
      END LOOP;

     -- ER# 9161779 - Start

         --  Create Guarantor parties on contract
         FOR c_get_guarantors_rec IN c_get_guarantors(l_lapv_rec.ID)
         LOOP
           lp_cplv_rec := null_cplv_rec;
       lp_kplv_rec := null_kplv_rec;

       -- Set the CPLV rec
           lp_cplv_rec.object1_id1            := c_get_guarantors_rec.PARTY_ID;
           lp_cplv_rec.object1_id2            := '#';
           lp_cplv_rec.jtot_object1_code := 'OKX_PARTY';
           lp_cplv_rec.rle_code                 := 'GUARANTOR';
           lp_cplv_rec.dnz_chr_id             := l_chr_id;
           lp_cplv_rec.chr_id                     := l_chr_id;

           -- validate the party
       Okl_Jtot_Contact_Extract_Pub.validate_Party( p_api_version => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count=> x_msg_count,
                                                  x_msg_data=> x_msg_data,
                                                  p_chr_id =>lp_cplv_rec.chr_id ,
                                                  p_cle_id => null,  --Line id
                                                  p_cpl_id => null,
                                                  p_lty_code => null,--Line style
                                                  p_rle_code => lp_cplv_rec.rle_code,
                                                  p_id1 => lp_cplv_rec.object1_id1,
                                                  p_id2 => lp_cplv_rec.object1_id2,
                                                  p_name => c_get_guarantors_rec.REFERENCE_NAME,
                                                  p_object_code => 'OKX_PARTY');
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

                ----------------------------------------
                -- Create party role record --
                ----------------------------------------
        okl_k_party_roles_pvt.create_k_party_role(
                                      p_api_version      => p_api_version,
                                      p_init_msg_list    => p_init_msg_list,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_cplv_rec         => lp_cplv_rec,
                                      x_cplv_rec         => lx_cplv_rec,
                                      p_kplv_rec         => lp_kplv_rec,
                                      x_kplv_rec         => lx_kplv_rec);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

                ---------------------------------------------------------------------
                -- Create Rule Group for storing Guarantor Info --
                ---------------------------------------------------------------------
        lp_rgpv_rec.dnz_chr_id := l_chr_id;
        lp_rgpv_rec.chr_id := l_chr_id;
        lp_rgpv_rec.rgp_type := 'KRG';
        lp_rgpv_rec.rgd_code := 'LAGRDT';

        Okl_Rule_Pub.create_Rule_Group(p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count=> x_msg_count,
                                x_msg_data=> x_msg_data,
                                p_rgpv_rec => lp_rgpv_rec,
                                x_rgpv_rec => lx_rgpv_rec);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

                IF l_rulv_tbl.COUNT > 0 THEN
                  l_rulv_tbl.DELETE;
                END IF;
                ---------------------------------------------------------------------------------------------------------
                -- Create Rule to store Guarantor Correspondence site and guarantor type --
                ---------------------------------------------------------------------------------------------------------
        l_rulv_tbl(1).dnz_chr_id        := l_chr_id;
        l_rulv_tbl(1).rgp_id               := lx_rgpv_rec.id ;

                -- get identifying address of party
                OPEN c_get_primary_address(c_get_guarantors_rec.PARTY_ID);
                   FETCH c_get_primary_address INTO l_rulv_tbl(1).object1_id1 ;
                CLOSE c_get_primary_address;

        l_rulv_tbl(1).object1_id2      := '#';
        l_rulv_tbl(1).jtot_object1_code := 'OKL_PARTYSITE';

        l_rulv_tbl(1).rule_information_category := 'LAGRNP';
        l_rulv_tbl(1).rule_information1                :='PRIMARY'; -- Set Guarantor to Primary type
        l_rulv_tbl(1).std_template_yn                 := 'N';
        l_rulv_tbl(1).warn_yn                              := 'N';

                ------------------------------------------------------------------------
                -- Create Rule to store Guarantee type, amount and date --
                ------------------------------------------------------------------------
        l_rulv_tbl(2).dnz_chr_id         := l_chr_id;
        l_rulv_tbl(2).rgp_id                := lx_rgpv_rec.id ;
        l_rulv_tbl(2).object1_id1       := c_get_guarantors_rec.PARTY_ID;
        l_rulv_tbl(2).object1_id2       := '#';
        l_rulv_tbl(2).jtot_object1_code := null;

        l_rulv_tbl(2).rule_information_category := 'LAGRNT';

                -- raise an error if the currency code of the guarantor amount is different from the currency code of the lease app
                IF c_get_guarantors_rec.CURRENCY <> l_lapv_rec.CURRENCY_CODE THEN
                  -- Set message and raise error
          OKL_API.SET_MESSAGE(
            p_app_name      => G_APP_NAME,
            p_msg_name      => 'OKL_GUARANTOR_CURR_MISMATCH');
           RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                -- Decide the guarantee type - If guarantee amount is less than amount requested, then partial else Full guarantee type
                IF (c_get_guarantors_rec.GUARANTEED_AMOUNT  < c_get_guarantors_rec.amount_requested) THEN
           l_rulv_tbl(2).rule_information1                := 'PARTIAL';
                ELSE
           l_rulv_tbl(2).rule_information1                := 'FULL';
                END IF;

        l_rulv_tbl(2).rule_information2                := c_get_guarantors_rec.GUARANTEED_AMOUNT;
        l_rulv_tbl(2).rule_information3                := FND_DATE.date_to_canonical(c_get_guarantors_rec.FUNDING_AVAILABLE_FROM);

        l_rulv_tbl(2).std_template_yn   := 'N';
        l_rulv_tbl(2).warn_yn              := 'N';

                -- Call API to create the above rules
         Okl_Rule_Pub.create_Rule(p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count=> x_msg_count,
                             x_msg_data=> x_msg_data,
                             p_rulv_tbl => l_rulv_tbl,
                             x_rulv_tbl => x_rulv_tbl);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

                ---------------------------------------------------
                -- Create Rule Mode Party Role Record  --
                ---------------------------------------------------
        open c_rrd_id(l_chr_id);
          fetch c_rrd_id into l_rrd_id;
        close c_rrd_id;

        lp_rmpv_rec.rgp_id :=  lx_rgpv_rec.id;
        lp_rmpv_rec.cpl_id := lx_cplv_rec.id;
        lp_rmpv_rec.dnz_chr_id := l_chr_id;
        lp_rmpv_rec.rrd_id := l_rrd_id;
        Okl_Rule_Pub.create_Rg_Mode_Pty_Role(p_api_version => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count=> x_msg_count,
                                      x_msg_data=> x_msg_data,
                                      p_rmpv_rec => lp_rmpv_rec,
                                      x_rmpv_rec =>lx_rmpv_rec);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

         END LOOP; -- End of guarantors loop

         -- If contract template exists, create the other parties - parties other than Lessee, lessor, vendor -- also copy guarantors
         -- on contract template that are not on the case folder
         IF l_chr_tmpl_id IS NOT NULL THEN
       FOR c_get_other_party_rec IN c_get_other_party_csr(l_chr_tmpl_id,l_lapv_rec.ID)
           LOOP
         okl_copy_contract_pub.copy_party_roles(
                                              p_api_version     => p_api_version,
                                              p_init_msg_list   => p_init_msg_list,
                                              x_return_status   => x_return_status,
                                              x_msg_count       => x_msg_count,
                                              x_msg_data        => x_msg_data,
                                              p_cpl_id               => c_get_other_party_rec.id,
                                              p_cle_id               => NULL,
                                              p_chr_id              => l_chr_id,
                                              p_rle_code          => c_get_other_party_rec.rle_code,
                                              x_cpl_id                => lx_cpl_id
                                             );
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
           END LOOP;
         END IF;
     -- ER# 9161779 - End

   x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data);
   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
   END create_party_roles;
 -------------------------------------------------------------------------------
  -- PROCEDURE create_contract_header
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_lease_app_template
  -- Description     : This procedure is a wrapper that creates  contract header info from lease application/quote header
  --
  -- Business Rules  : this procedure is used to create a contract header from lease application/quote header
  --                 : The following details are copied to a Lease Contract from a credit approved Lease Application
  --                 : Lease Application Header details
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_contract_header(p_api_version                  IN NUMBER,
                                   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                OUT NOCOPY VARCHAR2,
                                   x_msg_count                    OUT NOCOPY NUMBER,
                                   x_msg_data                     OUT NOCOPY VARCHAR2,
                                   p_contract_number              IN  VARCHAR2,
                                   p_parent_object_id             IN  VARCHAR2,
                                   p_lapv_rec                     IN  c_get_leaseapp_hdr%ROWTYPE,
                                   x_chr_id                       OUT NOCOPY NUMBER)IS
   -- Variables Declarations
   l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
   l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_CNT_HDR';
   l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_debug_enabled               VARCHAR2(10);
   l_lapv_rec                    c_get_leaseapp_hdr%ROWTYPE;
   -- Record/Table Type Declarations
   lp_chrv_rec                   OKL_OKC_MIGRATION_PVT.chrv_rec_type;
   lx_chrv_rec                   OKL_OKC_MIGRATION_PVT.chrv_rec_type;
   lp_khrv_rec                   OKL_CONTRACT_PUB.khrv_rec_type;
   lx_khrv_rec                   OKL_CONTRACT_PUB.khrv_rec_type;
   --master lease/credit line rec
   lp_mla_gvev_rec               OKL_OKC_MIGRATION_PVT.gvev_rec_type;
   lx_mla_gvev_rec               OKL_OKC_MIGRATION_PVT.gvev_rec_type;

   -- Added by rravikir (Bug 5142890)
   ln_qcl_id					 OKC_K_HEADERS_B.QCL_ID%TYPE;
   CURSOR l_qcl_csr IS
   SELECT qcl.id
   FROM  OKC_QA_CHECK_LISTS_TL qcl,
         OKC_QA_CHECK_LISTS_B qclv
   WHERE qclv.Id = qcl.id
   AND UPPER(qcl.name) = 'OKL LA QA CHECK LIST'
   AND qcl.LANGUAGE = USERENV('LANG');
   -- End (Bug 5142890)

    -- ER# 9161779 - Start
        -- Cursor to get the contract template attached to a lease application template of a lease app
    CURSOR c_get_contract_temp(p_lap_id IN okl_lease_applications_v.ID%TYPE) IS
    SELECT chr.id , chr.description, khr.ATTRIBUTE_CATEGORY
          , khr.ATTRIBUTE1, khr.ATTRIBUTE2, khr.ATTRIBUTE3, khr.ATTRIBUTE4, khr.ATTRIBUTE5, khr.ATTRIBUTE6
          , khr.ATTRIBUTE7, khr.ATTRIBUTE8, khr.ATTRIBUTE9, khr.ATTRIBUTE10, khr.ATTRIBUTE11, khr.ATTRIBUTE12
          , khr.ATTRIBUTE13, khr.ATTRIBUTE14, khr.ATTRIBUTE15
     FROM   okl_leaseapp_templ_versions_b olvv,
                 okl_lease_applications_b olav,
                                 okc_k_headers_v chr,
                                 okl_k_headers khr
    WHERE  olav.leaseapp_template_id = olvv.ID -- lease app stores the template version id
         AND olav.ID = p_lap_id
                 AND chr.id = khr.id
                 AND chr.id = olvv.contract_template_id
         AND EXISTS (SELECT 1
                   FROM   okl_k_headers khr
                   WHERE  khr.ID = olvv.contract_template_id
                          AND khr.template_type_code = 'CONTRACT') -- Consider only contract templates and not lease app contract templates
     ;

         c_get_contract_temp_rec c_get_contract_temp%ROWTYPE;
         l_contract_templ_exists BOOLEAN DEFAULT FALSE;
    -- ER# 9161779 - End

  BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- check for logging on PROCEDURE level
      l_debug_enabled := okl_debug_pub.check_log_enabled;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                                ,p_pkg_name      => G_PKG_NAME
                                                ,p_init_msg_list => p_init_msg_list
                                                ,l_api_version   => l_api_version
                                                ,p_api_version   => p_api_version
                                                ,p_api_type      => g_api_type
                                                ,x_return_status => x_return_status);
      -- check if activity started successfully
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_lapv_rec                        := p_lapv_rec;
      lp_chrv_rec.id                    := NULL;
      lp_chrv_rec.scs_code              := 'LEASE';
      lp_khrv_rec.id                    := NULL;
      lp_chrv_rec.sfwt_flag             := 'N';
      lp_chrv_rec.object_version_number := 1.0;
      lp_chrv_rec.sts_code              := G_STS_CODE; -- 'ENTERED';
      lp_chrv_rec.contract_number       := p_contract_number;
      lp_chrv_rec.authoring_org_id      := OKL_CONTEXT.GET_OKC_ORG_ID;
      lp_chrv_rec.inv_organization_id   := OKL_CONTEXT.get_okc_organization_id;
      lp_chrv_rec.cust_acct_id          := l_lapv_rec.CUST_ACCT_ID;
      lp_chrv_rec.currency_code         := l_lapv_rec.CURRENCY_CODE;
      lp_chrv_rec.currency_code_renewed := NULL;
      lp_chrv_rec.template_yn           := 'N';
      lp_chrv_rec.chr_type              := 'CYA';
      lp_chrv_rec.archived_yn           := 'N';
      lp_chrv_rec.deleted_yn            := 'N';
      lp_chrv_rec.buy_or_sell           := 'S';
      lp_chrv_rec.issue_or_receive      := 'I';

          -- ER# 9161779 - Start
          -- Only if we are creating contract using a lease application
          IF p_parent_object_id =  'LEASEAPP' THEN
            lp_chrv_rec.description := l_lapv_rec.short_description;
        lp_chrv_rec.short_description := l_lapv_rec.short_description;

            OPEN c_get_contract_temp(l_lapv_rec.ID);
              FETCH c_get_contract_temp INTO c_get_contract_temp_rec;
                    IF c_get_contract_temp%FOUND THEN
                    l_contract_templ_exists := TRUE;
                  END IF;
            CLOSE c_get_contract_temp;

            -- In case the description on lease app is NULL, then look for contract template and its description
            IF lp_chrv_rec.description IS NULL AND l_contract_templ_exists THEN
              lp_chrv_rec.description := c_get_contract_temp_rec.description;
              lp_chrv_rec.short_description := c_get_contract_temp_rec.description;
            END IF;

            -- Copy DFF related fields from contract template if exists
            IF l_contract_templ_exists THEN
              lp_khrv_rec.ATTRIBUTE_CATEGORY := c_get_contract_temp_rec.ATTRIBUTE_CATEGORY;
          lp_khrv_rec.ATTRIBUTE1 := c_get_contract_temp_rec.ATTRIBUTE1;
          lp_khrv_rec.ATTRIBUTE2 := c_get_contract_temp_rec.ATTRIBUTE2;
          lp_khrv_rec.ATTRIBUTE3 := c_get_contract_temp_rec.ATTRIBUTE3;
          lp_khrv_rec.ATTRIBUTE4 := c_get_contract_temp_rec.ATTRIBUTE4;
          lp_khrv_rec.ATTRIBUTE5 := c_get_contract_temp_rec.ATTRIBUTE5;
          lp_khrv_rec.ATTRIBUTE6 := c_get_contract_temp_rec.ATTRIBUTE6;
          lp_khrv_rec.ATTRIBUTE7 := c_get_contract_temp_rec.ATTRIBUTE7;
          lp_khrv_rec.ATTRIBUTE8 := c_get_contract_temp_rec.ATTRIBUTE8;
          lp_khrv_rec.ATTRIBUTE9 := c_get_contract_temp_rec.ATTRIBUTE9;
          lp_khrv_rec.ATTRIBUTE10 := c_get_contract_temp_rec.ATTRIBUTE10;
          lp_khrv_rec.ATTRIBUTE11 := c_get_contract_temp_rec.ATTRIBUTE11;
          lp_khrv_rec.ATTRIBUTE12 := c_get_contract_temp_rec.ATTRIBUTE12;
          lp_khrv_rec.ATTRIBUTE13 := c_get_contract_temp_rec.ATTRIBUTE13;
          lp_khrv_rec.ATTRIBUTE14 := c_get_contract_temp_rec.ATTRIBUTE14;
          lp_khrv_rec.ATTRIBUTE15 := c_get_contract_temp_rec.ATTRIBUTE15;
            END IF;
         END IF;
          -- ER# 9161779 - End

      -- Added by rravikir (Bug 5142890)
      OPEN  l_qcl_csr;
      FETCH l_qcl_csr INTO ln_qcl_id;
      CLOSE l_qcl_csr;

      lp_chrv_rec.qcl_id				:= ln_qcl_id;
      -- End (Bug 5142890)

      --11/06/05 SNAMBIAR - As per AVSINGH, orig_syste_source_code
      --is changed to OKL_LEASE_APP instead of OKL_LEASEAPP

      IF p_parent_object_id = 'LEASEAPP' THEN
       lp_chrv_rec.orig_system_source_code := 'OKL_LEASE_APP';
      ELSIF p_parent_object_id = 'LEASEOPP' THEN
       lp_chrv_rec.orig_system_source_code := 'OKL_QUOTE'; -- Bug 5098124
      END IF;
      lp_chrv_rec.orig_system_id1         := l_lapv_rec.id;
      lp_chrv_rec.START_DATE            := l_lapv_rec.EXPECTED_START_DATE;
      lp_chrv_rec.END_DATE              := ADD_MONTHS(l_lapv_rec.EXPECTED_START_DATE,l_lapv_rec.TERM);
      lp_khrv_rec.expected_delivery_date := l_lapv_rec.expected_delivery_date;
      lp_khrv_rec.date_funding_expected := l_lapv_rec.expected_funding_date;
      lp_khrv_rec.object_version_number := 1.0;
      lp_khrv_rec.generate_accrual_yn := 'Y';
      lp_khrv_rec.generate_accrual_override_yn := 'N';
      lp_khrv_rec.currency_conversion_type := l_lapv_rec.CURRENCY_CONVERSION_TYPE;
      lp_khrv_rec.currency_conversion_date := l_lapv_rec.CURRENCY_CONVERSION_DATE;
      lp_khrv_rec.currency_conversion_rate := l_lapv_rec.CURRENCY_CONVERSION_RATE;
      lp_khrv_rec.khr_id                   := l_lapv_rec.PROGRAM_AGREEMENT_ID;
      lp_khrv_rec.pdt_id                   := l_lapv_rec.PRODUCT_ID;
      lp_khrv_rec.TERM_DURATION            := l_lapv_rec.TERM;
      lp_khrv_rec.LEGAL_ENTITY_ID          := l_lapv_rec.LEGAL_ENTITY_ID;
      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_CONTRACT_PUB.validate_contract_header'
         ,'begin debug  call validate_contract_header');
      END IF;
      -- call the TAPI insert_row to create a lease application template
      OKL_CONTRACT_PUB.validate_contract_header(p_api_version    => p_api_version,
                                          p_init_msg_list        => p_init_msg_list,
                                          x_return_status        => x_return_status,
                                          x_msg_count            => x_msg_count,
                                          x_msg_data             => x_msg_data,
                                          p_chrv_rec             => lp_chrv_rec,
                                          p_khrv_rec             => lp_khrv_rec);

      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_CONTRACT_PUB.validate_contract_header'
        ,'end debug  call validate_contract_header');
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_CONTRACT_PUB.create_contract_header'
         ,'begin debug  call create_contract_header');
      END IF;
      OKL_CONTRACT_PUB.create_contract_header(p_api_version    => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chrv_rec           => lp_chrv_rec,
                                          p_khrv_rec           => lp_khrv_rec,
                                          x_chrv_rec           => lx_chrv_rec,
                                          x_khrv_rec           => lx_khrv_rec);

      IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_CONTRACT_PUB.create_contract_header'
         ,'end debug  call create_contract_header');
      END IF;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      x_chr_id := lx_chrv_rec.id;
      -- copy master lease
      IF( l_lapv_rec.MASTER_LEASE_ID IS NOT NULL) THEN
          lp_mla_gvev_rec.id := NULL;
          lp_mla_gvev_rec.dnz_chr_id := x_chr_id;
          lp_mla_gvev_rec.chr_id := x_chr_id;
          lp_mla_gvev_rec.chr_id_referred := l_lapv_rec.MASTER_LEASE_ID;
          lp_mla_gvev_rec.copied_only_yn := 'N';
          IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_OKC_MIGRATION_PVT.create_governance'
             ,'begin debug  call create_governance');
          END IF;
          OKL_OKC_MIGRATION_PVT.create_governance(p_api_version    => p_api_version,
                                                  p_init_msg_list  => p_init_msg_list,
                                                  x_return_status  => x_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data       => x_msg_data,
                                                  p_gvev_rec       => lp_mla_gvev_rec,
                                                  x_gvev_rec       => lx_mla_gvev_rec);

          IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_OKC_MIGRATION_PVT.create_governance'
             ,'end debug  call create_governance');
          END IF;
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
       -- copy credit line
       IF( l_lapv_rec.CREDIT_LINE_ID IS NOT NULL) THEN
          lp_mla_gvev_rec.id := NULL;
          lp_mla_gvev_rec.dnz_chr_id := x_chr_id;
          lp_mla_gvev_rec.chr_id := x_chr_id;
          lp_mla_gvev_rec.chr_id_referred := l_lapv_rec.CREDIT_LINE_ID;
          lp_mla_gvev_rec.copied_only_yn := 'N';
           IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_OKC_MIGRATION_PVT.create_governance'
             ,'begin debug  call create_governance');
          END IF;
          OKL_OKC_MIGRATION_PVT.create_governance(p_api_version    => p_api_version,
                                                  p_init_msg_list  => p_init_msg_list,
                                                  x_return_status  => x_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data       => x_msg_data,
                                                  p_gvev_rec       => lp_mla_gvev_rec,
                                                  x_gvev_rec       => lx_mla_gvev_rec);

          IF(l_debug_enabled='Y') THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_OKC_MIGRATION_PVT.create_governance'
             ,'end debug  call create_governance');
          END IF;
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
       x_return_status := okc_api.G_RET_STS_SUCCESS;
   OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data);
   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (l_qcl_csr%ISOPEN) THEN
        CLOSE l_qcl_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (l_qcl_csr%ISOPEN) THEN
        CLOSE l_qcl_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      IF (l_qcl_csr%ISOPEN) THEN
        CLOSE l_qcl_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
   END create_contract_header;
 -------------------------------------------------------------------------------
  -- PROCEDURE create_contract
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_lease_app_template
  -- Description     : This procedure is a wrapper that creates transaction records for
  --                 : lease application template.
  --
  -- Business Rules  : this procedure is used to create a contract from lease application
  --                 : The following details are copied to a Lease Contract from a credit approved Lease Application
  --                 : Lease Application Header details
  --                 : Customer accepted Configuration, Financing Adjustments, Payments, Terms and Conditions from
  --                 : the Contract Template associated with the Lease Application Template on the Lease Application
  --                 : Guarantor on Credit data is copied over as a party with role Guarantor on the contract
  --                 : Terms and Conditionss from Contract Template associated to Lease Application Template are copied over as Terms and Conditionss on contract
  --                 : System defaults the Contract Start Date from the Expected Start Date field on the lease application header
  --                 : System changes the status on the Lease Application to Converted to Contract
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-Jun-2005 SKGAUTAM created
  --                   04-Jan-2008 RRAVIKIR code added to invoke procedure create_asset_subsidy for subsidy creation
  -- End of comments
  PROCEDURE create_contract(p_api_version                  IN NUMBER,
                            p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_contract_number              IN  VARCHAR2,
                            p_parent_object_code           IN VARCHAR2,
                            p_parent_object_id             IN  NUMBER,
                            x_chr_id                       OUT NOCOPY NUMBER,
							x_contract_number			   OUT NOCOPY VARCHAR2)IS
    -- Variables Declarations
    l_api_version                 CONSTANT NUMBER DEFAULT 1.0;
    l_api_name                    CONSTANT VARCHAR2(30) DEFAULT 'CRT_CNT';
    l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled               VARCHAR2(10);
    l_chr_id                      NUMBER;
    l_parent_object_code          VARCHAR2(15);
    l_parent_object_id            NUMBER;
    l_lapv_rec                    c_get_leaseapp_hdr%ROWTYPE;
    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list              wf_parameter_list_t;
    p_event_name                  VARCHAR2(240)       := 'oracle.apps.okl.sales.leaseapplication.contract_created';
    -- Bug#4741121 - viselvar  - Modified - End

    -- Added by rravikir (Bug 4901292) - Start
    l_contractevent_name          VARCHAR2(240)       := 'oracle.apps.okl.sales.leaseapplication.khr_created_with_lap';
    -- End (Bug 4901292)

    l_exists                      VARCHAR2(3) := 'N';
    l_count                       NUMBER;
    l_contract_number             VARCHAR2(240);
   --cursor to check existance of contract number
   CURSOR chk_cntrct_exists(lc_contract_number IN VARCHAR2 )IS
    SELECT 'Y'
    FROM okc_k_headers_b
    where contract_number = lc_contract_number;
   --cursor to count the contract numbers which are like the one we want to create
   CURSOR chk_count IS
   SELECT count(1)
   FROM okc_k_headers_b
   WHERE contract_number like p_contract_number || '%';

   CURSOR c_get_leaseopp IS
   SELECT parent_object_id
   FROM okl_lease_quotes_b
   WHERE id = p_parent_object_id;

   BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* Commented by rravikir (Bug 5086044)

    l_contract_number := p_contract_number;
    OPEN chk_cntrct_exists(p_contract_number);
    FETCH chk_cntrct_exists INTO l_exists;
    CLOSE chk_cntrct_exists;

    IF l_exists = 'Y' THEN
     OPEN chk_count;
     FETCH chk_count INTO l_count;
     CLOSE chk_count;
     l_contract_number := p_contract_number || to_Char(l_count);
    END IF;

    l_exists := 'N';
    OPEN chk_cntrct_exists(l_contract_number);
    FETCH chk_cntrct_exists INTO l_exists;
    CLOSE chk_cntrct_exists;

    WHILE l_exists = 'Y' LOOP
      l_count := l_count+1;
      l_contract_number := p_contract_number || to_Char(l_count);
      l_exists := 'N';
      OPEN chk_cntrct_exists(l_contract_number);
      FETCH chk_cntrct_exists INTO l_exists;
      CLOSE chk_cntrct_exists;
    END LOOP;

    */

    -- Added by rravikir (Bug 5086044)
    -- Commented out code for bug#6765840
    /* -- Generate Contract Number from the sequence
    IF (p_contract_number IS NULL) THEN -- Bug 6649617

  	  OKC_CONTRACT_PVT.GENERATE_CONTRACT_NUMBER(
            p_scs_code        => 'LEASE',
 			p_modifier	      => null,
 			x_return_status   => x_return_status,
 			x_contract_number => x_contract_number);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_contract_number := x_contract_number;
    ELSE
      l_contract_number := p_contract_number;
      x_contract_number := p_contract_number;
    END IF; -- End Bug 6649617
    -- End (Bug 5086044) */

    l_parent_object_code := p_parent_object_code;
    l_parent_object_id   := p_parent_object_id;
    IF l_parent_object_code = 'LEASEAPP' THEN
     OPEN  c_get_leaseapp_hdr(l_parent_object_id);
     FETCH c_get_leaseapp_hdr INTO
           l_lapv_rec.ID,
           l_lapv_rec.REFERENCE_NUMBER,
           l_lapv_rec.PROSPECT_ID,
           l_lapv_rec.PROSPECT_ADDRESS_ID,
           l_lapv_rec.CUST_ACCT_ID,
           l_lapv_rec.PROGRAM_AGREEMENT_ID,
           l_lapv_rec.CURRENCY_CODE,
           l_lapv_rec.CURRENCY_CONVERSION_TYPE,
           l_lapv_rec.CURRENCY_CONVERSION_RATE,
           l_lapv_rec.CURRENCY_CONVERSION_DATE,
           l_lapv_rec.CREDIT_LINE_ID,
           l_lapv_rec.MASTER_LEASE_ID,
           l_lapv_rec.PARENT_LEASEAPP_ID,
           l_lapv_rec.SALES_REP_ID,
           l_lapv_rec.ORG_ID,
           l_lapv_rec.INV_ORG_ID,
           l_lapv_rec.EXPECTED_START_DATE,
           l_lapv_rec.QUOTE_NUMBER,
           l_lapv_rec.TERM,
           l_lapv_rec.PRODUCT_ID,
           l_lapv_rec.PROPERTY_TAX_APPLICABLE,
           l_lapv_rec.PROPERTY_TAX_BILLING_TYPE,
           l_lapv_rec.UPFRONT_TAX_TREATMENT,
           l_lapv_rec.UPFRONT_TAX_STREAM_TYPE,
           l_lapv_rec.TRANSFER_OF_TITLE,
           l_lapv_rec.AGE_OF_EQUIPMENT,
           l_lapv_rec.PURCHASE_OF_LEASE,
           l_lapv_rec.SALE_AND_LEASE_BACK,
           l_lapv_rec.INTEREST_DISCLOSED,
           l_lapv_rec.QUOTE_ID,
           l_lapv_rec.EXPECTED_DELIVERY_DATE,
           l_lapv_rec.EXPECTED_FUNDING_DATE,
           l_lapv_rec.LEGAL_ENTITY_ID,
           l_lapv_rec.LINE_INTENDED_USE    -- Bug 5908845. eBTax Enhancement Project
		   ,l_lapv_rec.SHORT_DESCRIPTION; -- ER# 9161779
     CLOSE c_get_leaseapp_hdr;

     OKL_LEASE_APP_PVT.CREATE_CONTRACT_VAL(
        p_api_version     => p_api_version
       ,p_init_msg_list   => OKL_API.G_FALSE
       ,x_return_status   => x_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
       ,p_lap_id          => l_lapv_rec.ID);

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSIF l_parent_object_code = 'LEASEOPP' THEN

     -- Fetch the Lease opportunity id from the accepted Quote
     OPEN c_get_leaseopp;
     FETCH c_get_leaseopp INTO l_parent_object_id;
     CLOSE c_get_leaseopp;

     OPEN  c_get_leaseopp_hdr(l_parent_object_id);
     FETCH c_get_leaseopp_hdr INTO
           l_lapv_rec.ID,
           l_lapv_rec.REFERENCE_NUMBER,
           l_lapv_rec.PROSPECT_ID,
           l_lapv_rec.PROSPECT_ADDRESS_ID,
           l_lapv_rec.CUST_ACCT_ID,
           l_lapv_rec.PROGRAM_AGREEMENT_ID,
           l_lapv_rec.CURRENCY_CODE,
           l_lapv_rec.CURRENCY_CONVERSION_TYPE,
           l_lapv_rec.CURRENCY_CONVERSION_RATE,
           l_lapv_rec.CURRENCY_CONVERSION_DATE,
           l_lapv_rec.CREDIT_LINE_ID,
           l_lapv_rec.MASTER_LEASE_ID,
           l_lapv_rec.PARENT_LEASEAPP_ID,
           l_lapv_rec.SALES_REP_ID,
           l_lapv_rec.ORG_ID,
           l_lapv_rec.INV_ORG_ID,
           l_lapv_rec.EXPECTED_START_DATE,
           l_lapv_rec.QUOTE_NUMBER,
           l_lapv_rec.TERM,
           l_lapv_rec.PRODUCT_ID,
           l_lapv_rec.PROPERTY_TAX_APPLICABLE,
           l_lapv_rec.PROPERTY_TAX_BILLING_TYPE,
           l_lapv_rec.UPFRONT_TAX_TREATMENT,
           l_lapv_rec.UPFRONT_TAX_STREAM_TYPE,
           l_lapv_rec.TRANSFER_OF_TITLE,
           l_lapv_rec.AGE_OF_EQUIPMENT,
           l_lapv_rec.PURCHASE_OF_LEASE,
           l_lapv_rec.SALE_AND_LEASE_BACK,
           l_lapv_rec.INTEREST_DISCLOSED,
           l_lapv_rec.QUOTE_ID,
           l_lapv_rec.EXPECTED_DELIVERY_DATE,
           l_lapv_rec.EXPECTED_FUNDING_DATE,
           l_lapv_rec.LEGAL_ENTITY_ID,
           l_lapv_rec.LINE_INTENDED_USE    -- Bug 5908845. eBTax Enhancement Project
		   ,l_lapv_rec.SHORT_DESCRIPTION; -- ER# 9161779
      CLOSE c_get_leaseopp_hdr;

      CREATE_CONTRACT_VAL(
        p_api_version     => p_api_version
       ,p_init_msg_list   => OKL_API.G_FALSE
       ,x_return_status   => x_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
       ,p_quote_id          => p_parent_object_id);

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     END IF;

    IF l_lapv_rec.id IS NULL THEN
       OKL_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'quote_chr_id_not_found');
       x_return_status := OKL_API.g_ret_sts_error;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_contract_header'
         ,'begin debug  call create_contract_header');
    END IF;

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
            p_org_id            => l_lapv_rec.org_id,
            p_organization_id   => l_lapv_rec.INV_ORG_ID);

    -- moved code here for bug#6765840 start
    IF (p_contract_number IS NULL) THEN

  	  OKC_CONTRACT_PVT.GENERATE_CONTRACT_NUMBER(
                        p_scs_code        => 'LEASE',
 			p_modifier	  => null,
 			x_return_status   => x_return_status,
 			x_contract_number => x_contract_number);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_contract_number := x_contract_number;
    ELSE
      l_contract_number := p_contract_number;
      x_contract_number := p_contract_number;
    END IF;
    -- moved code here for bug#6765840 End

    create_contract_header(p_api_version        => p_api_version,
                           p_init_msg_list      => OKC_API.G_FALSE,
                           x_return_status      => x_return_status,
                           x_msg_count	         => x_msg_count,
                           x_msg_data	          => x_msg_data,
                           p_contract_number    => l_contract_number,
                           p_parent_object_id   => l_parent_object_code,
                           p_lapv_rec           => l_lapv_rec,
                           x_chr_id             => l_chr_id);

    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_contract_header'
         ,'end debug  call create_contract_header');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_party_roles'
         ,'begin debug  call create_party_roles');
    END IF;

    create_party_roles(p_api_version            => p_api_version,
                           p_init_msg_list      => OKC_API.G_FALSE,
                           x_return_status      => x_return_status,
                           x_msg_count	         => x_msg_count,
                           x_msg_data	          => x_msg_data,
                           p_chr_id             => l_chr_id,
                           p_lapv_rec           => l_lapv_rec);

    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_ccreate_party_roles'
         ,'end debug  call create_party_roles');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_pcreate_rulesarty_roles'
         ,'begin debug  call create_rules');
    END IF;
    create_rules(p_api_version        => p_api_version,
                 p_init_msg_list      => OKC_API.G_FALSE,
                 x_return_status      => x_return_status,
                 x_msg_count	         => x_msg_count,
                 x_msg_data	          => x_msg_data,
                 p_chr_id             => l_chr_id,
                 p_lapv_rec           => l_lapv_rec);

    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_rules'
         ,'end debug  call create_rules');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --create asset lines
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_lines'
         ,'begin debug  call create_asset_lines');
    END IF;

    create_asset_lines(p_api_version        => p_api_version,
                       p_init_msg_list      => OKC_API.G_FALSE,
                       x_return_status      => x_return_status,
                       x_msg_count	         => x_msg_count,
                       x_msg_data	          => x_msg_data,
                       p_chr_id             => l_chr_id,
                       p_lapv_rec           => l_lapv_rec);

    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_asset_lines'
         ,'end debug  call create_asset_lines');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --create fee lines
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_fee_lines'
         ,'begin debug  call create_fee_lines');
    END IF;
    create_fee_lines(p_api_version    => p_api_version,
                     p_init_msg_list	 => p_init_msg_list,
                     x_return_status 	=> x_return_status,
                     x_msg_count     	=> x_msg_count,
                     x_msg_data      	=> x_msg_data,
                     p_quote_id       => l_lapv_rec.quote_id,
                     p_chr_id         => l_chr_id);
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_fee_lines'
         ,'end debug  call create_fee_lines');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Start : Added by rravikir for Bug#6707125
    --create asset subsidy
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create asset subsidy'
         ,'begin debug  call create_asset_subsidy');
    END IF;
    create_asset_subsidy(p_api_version        => p_api_version,
                         p_init_msg_list      => OKC_API.G_FALSE,
                         x_return_status      => x_return_status,
                         x_msg_count	      => x_msg_count,
                         x_msg_data           => x_msg_data,
                         p_quote_id           => l_lapv_rec.quote_id,
                         p_chr_id             => l_chr_id);
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create asset subsidy'
         ,'end debug  call create_asset_subsidy');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --End   : Added by rravikir for Bug#6707125

    --create service lines
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_service_lines'
         ,'begin debug  call create_service_lines');
    END IF;
    create_service_lines(p_api_version    => p_api_version,
                         p_init_msg_list	 => p_init_msg_list,
                         x_return_status 	=> x_return_status,
                         x_msg_count     	=> x_msg_count,
                         x_msg_data      	=> x_msg_data,
                         p_quote_id       => l_lapv_rec.quote_id,
                         p_chr_id         => l_chr_id);
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_service_lines'
         ,'end debug  call create_service_lines');
    END IF;
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF  l_parent_object_code = 'LEASEAPP' THEN
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_insurance_lines'
         ,'begin debug  call create_insurance_lines');
    END IF;
    create_insurance_lines (p_api_version  => p_api_version,
                         p_init_msg_list  	=> p_init_msg_list,
                         x_return_status 	 => x_return_status,
                         x_msg_count     	 => x_msg_count,
                         x_msg_data      	 => x_msg_data,
                         p_chr_id          => l_chr_id);
     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.create_insurance_lines'
         ,'end debug  call create_insurance_lines');
    END IF;
     IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --asawanka bug 4930456  changes start
    --create the cheklist for the contract
    OKL_CHECKLIST_PVT.CREATE_CONTRACT_CHECKLIST(p_api_version              => p_api_version,
                                                p_init_msg_list            => p_init_msg_list,
                                                x_return_status            => x_return_status,
                                                x_msg_count                => x_msg_count,
                                                x_msg_data                 => x_msg_data,
                                                p_chr_id                   => l_chr_id);

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --asawanka bug 4930456 changes end
    --Update Lease App status
    IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.update_leaseapp_status'
         ,'begin debug  call update_leaseapp_status');
    END IF;
    update_leaseapp_status(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status 	 => x_return_status,
                           x_msg_count     	 => x_msg_count,
                           x_msg_data      	 => x_msg_data,
                           p_lap_id          => l_lapv_rec.id);

     IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.okl_quote_to_contract_pvt.update_leaseapp_status'
         ,'end debug  call update_leaseapp_status');
    END IF;
     IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    END IF; --Lease App end if
    x_chr_id := l_chr_id;
        -- Bug#4741121 - viselvar  - Modified - Start
    IF (p_parent_object_code='LEASEAPP') THEN
      -- raise the business event passing the lease application id added to the parameter list

      wf_event.addparametertolist('LAPP_ID'
                              ,p_parent_object_id
                              ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            x_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

     IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

      -- Added by rravikir (Bug 4901292)
      -- Business event for the Contract Created with Lease Application as Source
      wf_event.addparametertolist('CONTRACT_ID'
                              	 ,l_chr_id
                              	 ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_event_name    => l_contractevent_name
                            ,p_parameters    => l_parameter_list);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- End Bug 4901292

    END IF;
   -- Bug#4741121 - viselvar  - Modified - End

    x_return_status := okc_api.G_RET_STS_SUCCESS;
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count
			                   ,x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_contract;
END OKL_QUOTE_TO_CONTRACT_PVT;

/
