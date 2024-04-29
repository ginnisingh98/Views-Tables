--------------------------------------------------------
--  DDL for Package Body OKL_K_RATE_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_K_RATE_PARAMS_PVT" AS
/* $Header: OKLRKRPB.pls 120.26.12010000.8 2009/10/27 10:11:14 rpillay ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

  -- GLOBAL VARIABLES
G_MISS_NUM	CONSTANT NUMBER := FND_API.G_MISS_NUM;
G_MISS_CHAR	CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_DATE	CONSTANT DATE := FND_API.G_MISS_DATE;
G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
G_BULK_SIZE               CONSTANT  NUMBER := 10000;
G_OKL_LLA_VAR_RATE_ERROR  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_ERROR';
G_LEASE_TYPE              CONSTANT VARCHAR2(30) := 'LEASE_TYPE';
G_INT_BASIS               CONSTANT VARCHAR2(30) := 'INT_BASIS';
G_OKL_LLA_VAR_RATE_MISSING  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_MISSING';
G_CONT_ID               CONSTANT VARCHAR2(30) := 'CONT_ID';
G_REQUIRED_VALUE CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_COL_NAME_TOKEN CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  -- smadhava Bug#4542290 - 22-Aug-2005 - Added - Start
  G_OKL_LLA_REBOOK_INVALID      CONSTANT VARCHAR2(30) := 'OKL_LLA_REBOOK_INVALID';
  G_OKL_LLA_RBK_INT_PROC_INVAL  CONSTANT VARCHAR2(30) := 'OKL_LLA_RBK_INT_PROCESS_INVAL';
  G_OKL_LLA_RBK_DATE_BILL_INVAL CONSTANT VARCHAR2(30) := 'OKL_LLA_RBK_DATE_BILL_INVAL';
  G_OKL_LLA_RBK_DATE_ACCR_INVAL CONSTANT VARCHAR2(30) := 'OKL_LLA_RBK_DATE_ACCRUE_INVAL';

  G_BOOK_CLASS     CONSTANT VARCHAR2(30) := 'BOOK_CLASS';
  G_INT_CALC_BASIS CONSTANT VARCHAR2(30) := 'INT_CAL';
  G_STREAM         CONSTANT VARCHAR2(30) := 'STREAM';

  G_BOOK_CLASS_OP      CONSTANT OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE := 'LEASEOP';
  G_BOOK_CLASS_DF      CONSTANT OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE := 'LEASEDF';
  G_BOOK_CLASS_ST      CONSTANT OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE := 'LEASEST';
  G_BOOK_CLASS_LOAN    CONSTANT OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE := 'LOAN';
  G_BOOK_CLASS_REVLOAN CONSTANT OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE := 'LOAN-REVOLVING';

  G_ICB_FIXED           CONSTANT OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE := 'FIXED';
  G_ICB_FLOAT_FACTOR    CONSTANT OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE := 'FLOAT_FACTORS';
  G_ICB_FLOAT           CONSTANT OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE := 'FLOAT';
  G_ICB_REAMORT         CONSTANT OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE := 'REAMORT';
  G_ICB_CATCHUP_CLEANUP CONSTANT OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE := 'CATCHUP/CLEANUP';

  G_RRM_EST_ACTUAL CONSTANT OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE := 'ESTIMATED_AND_ACTUAL';
  G_RRM_ACTUAL     CONSTANT OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE := 'ACTUAL';

  G_STRM_RENT           CONSTANT OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE := 'RENT';
  G_STRM_RENT_ACCRUAL   CONSTANT OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE := 'RENT_ACCRUAL';
  G_STRM_PRE_TAX        CONSTANT OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE := 'LEASE_INCOME';
  G_STRM_INT_INCOME     CONSTANT OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE := 'INTEREST_INCOME';
  G_STRM_LOAN_PAYMENT     CONSTANT OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE := 'LOAN_PAYMENT';
  G_STRM_VAR_INT_INCOME CONSTANT OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE := 'VARIABLE_INTEREST_INCOME';

  G_COL_NAME            CONSTANT VARCHAR2(30) := OKC_API.G_COL_NAME_TOKEN;
  G_DUE_DATE            CONSTANT VARCHAR2(30) := 'DUE_DATE';
  -- smadhava Bug#4542290 - 22-Aug-2005 - Added - End


procedure print_krpv_rec(p_krpv_rec IN krpv_rec_type) IS
begin

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'KHR_ID=' ||   p_krpv_rec.KHR_ID);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'parameter_type_code=' ||   p_krpv_rec.PARAMETER_TYPE_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'effective_from_date=' ||   p_krpv_rec.EFFECTIVE_FROM_DATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'effective_to_date=' ||   p_krpv_rec.EFFECTIVE_TO_DATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'interest_index_id= '||   p_krpv_rec.INTEREST_INDEX_ID);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'base_rate=' ||   p_krpv_rec.BASE_RATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'interest_start_date=' ||   p_krpv_rec.INTEREST_START_DATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'adder_rate='||   p_krpv_rec.ADDER_RATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'maximum_rate=' ||   p_krpv_rec.MAXIMUM_RATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'minimum_rate=' ||   p_krpv_rec.MINIMUM_RATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'principal_basis_code='||   p_krpv_rec.PRINCIPAL_BASIS_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'days_in_a_month_code='||    p_krpv_rec.DAYS_IN_A_MONTH_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'days_in_a_year_code='||   p_krpv_rec.DAYS_IN_A_YEAR_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'interest_basis_code='||   p_krpv_rec.INTEREST_BASIS_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rate_delay_code='||   p_krpv_rec.RATE_DELAY_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rate_delay_frequency=' ||   p_krpv_rec.RATE_DELAY_FREQUENCY);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'compounding_frequency_code=' ||   p_krpv_rec.COMPOUNDING_FREQUENCY_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'calculation_formula_id=' ||   p_krpv_rec.CALCULATION_FORMULA_ID);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'catchup_frequency_code='||    p_krpv_rec.CATCHUP_frequency_code);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'catchup_basis_code='||    p_krpv_rec.CATCHUP_BASIS_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'catchup_start_date='||   p_krpv_rec.CATCHUP_START_DATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'catchup_settlement_code='||   p_krpv_rec.CATCHUP_SETTLEMENT_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rate_change_start_date='||   p_krpv_rec.RATE_CHANGE_START_DATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rate_change_frequency_code=' || p_krpv_rec.RATE_CHANGE_FREQUENCY_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rate_change_value=' ||   p_krpv_rec.RATE_CHANGE_VALUE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'conversion_option_code=' ||   p_krpv_rec.CONVERSION_OPTION_CODE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'next_conversion_date=' ||   p_krpv_rec.NEXT_CONVERSION_DATE);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'conversion_type_code=' ||   p_krpv_rec.CONVERSION_TYPE_CODE);
  END IF;
 /*print('    p_krpv_rec.ATTRIBUTE_CATEGORY,
  print('   p_krpv_rec.ATTRIBUTE1,
  print('   p_krpv_rec.ATTRIBUTE2,
  print('   p_krpv_rec.ATTRIBUTE3,
  print('   p_krpv_rec.ATTRIBUTE4,
  print('   p_krpv_rec.ATTRIBUTE5,
  print('   p_krpv_rec.ATTRIBUTE6,
  print('   p_krpv_rec.ATTRIBUTE7,
  print('   p_krpv_rec.ATTRIBUTE8,
 print('    p_krpv_rec.ATTRIBUTE9,
  print('   p_krpv_rec.ATTRIBUTE10,
  print('   p_krpv_rec.ATTRIBUTE11,
  print('   p_krpv_rec.ATTRIBUTE12,
  print('   p_krpv_rec.ATTRIBUTE13,
  print('   p_krpv_rec.ATTRIBUTE14,
  print('   p_krpv_rec.ATTRIBUTE15,
  print('   p_krpv_rec.CREATED_BY,
  print('   p_krpv_rec.CREATION_DATE,
  print('   p_krpv_rec.LAST_UPDATED_BY,
  print('   p_krpv_rec.LAST_UPDATE_DATE,
  print('   p_krpv_rec.LAST_UPDATE_LOGIN */
end;

FUNCTION interest_processing(p_chr_id IN NUMBER,
                             x_contract_number OUT NOCOPY VARCHAR2,
                             x_contract_start_date OUT NOCOPY DATE )
                            RETURN BOOLEAN IS
l_interest_date DATE;
l_billable_stream_exists VARCHAR2(1) := 'N';
l_orig_system_id1 okc_k_headers_b.orig_system_id1%type;
l_orig_system_source_code okc_k_headers_b.orig_system_source_code%type;
BEGIN
  SELECT A.DATE_LAST_INTERIM_INTEREST_CAL,
         B.CONTRACT_NUMBER,
         B.START_DATE,
         B.ORIG_SYSTEM_ID1,
         B.ORIG_SYSTEM_SOURCE_CODE
  INTO   l_interest_date,
         x_contract_number,
         x_contract_start_date,
         l_orig_system_id1,
         l_orig_system_source_code
  FROM   OKL_K_HEADERS A,
         OKC_K_HEADERS_B B
  WHERE  A.ID = p_chr_id
  AND    A.ID = B.ID;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_interest_date=' ||l_interest_date);
  END IF;

  IF (l_interest_date IS NULL) THEN

    -- Bug 4905142
    -- Check if billable streams exists in which case billing has been run
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Yes, l_interest_date is NULL...');
    END IF;
    Begin
      SELECT 'Y'
      INTO   l_billable_stream_exists
      FROM OKL_STREAMS A, OKL_STRM_TYPE_B C WHERE A.KHR_ID=p_chr_id
      AND EXISTS (
                   SELECT 'X' FROM OKL_STRM_ELEMENTS B
                   WHERE   B.STM_ID = A.ID
                   AND     B.DATE_BILLED IS NOT NULL)
      AND A.STY_ID = C.ID
      AND C.BILLABLE_YN='Y'
      AND A.SAY_CODE <> 'HIST'
      AND ROWNUM < 2;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_billable_stream_exists=' || l_billable_stream_exists);
      END IF;

      Exception when no_data_found then

      If (l_orig_system_source_code = 'OKL_REBOOK') Then -- 4905142
      Begin
        SELECT 'Y'
        INTO   l_billable_stream_exists
        FROM OKL_STREAMS A, OKL_STRM_TYPE_B C WHERE A.KHR_ID=l_orig_system_id1
        AND EXISTS (
                     SELECT 'X' FROM OKL_STRM_ELEMENTS B
                     WHERE   B.STM_ID = A.ID
                     AND     B.DATE_BILLED IS NOT NULL)
        AND A.STY_ID = C.ID
        AND C.BILLABLE_YN='Y'
        AND A.SAY_CODE <> 'HIST'
        AND ROWNUM < 2;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'2.l_billable_stream_exists=' || l_billable_stream_exists);
        END IF;
        exception when others then
          l_billable_stream_exists := 'N';
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Exception...sqlcode=' || sqlcode);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Exception...sqlerrm=' || sqlerrm);
          END IF;
      End;
      End If;

    WHEN OTHERS THEN
       l_billable_stream_exists := 'N';
    End;

    IF (NVL(l_billable_stream_exists,'N') = 'Y') THEN -- 4905142
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;
  ELSE
    RETURN(TRUE);
  END IF;
END;

FUNCTION Is_Rebook_Copy (p_chr_id IN NUMBER) return BOOLEAN IS
   Cursor Rbk_Cpy_Csr(p_chr_id IN Number) is
   Select orig_system_source_code
   From   okc_k_headers_b chr
   --where  chr.orig_system_source_code = 'OKL_REBOOK'
   where  chr.id = p_chr_id;

   l_rbk_cpy  BOOLEAN := FALSE;
   l_orig_system_source_code  okc_k_headers_b.orig_system_source_code%type;
Begin
   Open Rbk_Cpy_Csr(p_chr_id => p_chr_id);
   Fetch Rbk_Cpy_Csr into l_orig_system_source_code;
   Close Rbk_Cpy_Csr;
   IF (nvl(l_orig_system_source_code,'?') = 'OKL_REBOOK') THEN
    l_rbk_cpy := TRUE;
   ELSE
    l_rbk_cpy := FALSE;
   END IF;
   Return (l_rbk_cpy);
End Is_Rebook_Copy;

PROCEDURE get_effective_from_date(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_chr_id                  IN OKC_K_HEADERS_B.ID%TYPE,
    x_effective_from_date     OUT NOCOPY DATE,
    x_no_data_found           OUT NOCOPY BOOLEAN) IS
CURSOR effective_from_date_csr(p_id NUMBER) IS
SELECT MAX(EFFECTIVE_FROM_DATE)
FROM   OKL_K_RATE_PARAMS
WHERE  KHR_ID = p_id
AND    EFFECTIVE_TO_DATE IS NULL;
BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  OPEN effective_from_date_csr(p_chr_id);
  FETCH effective_from_date_csr
  INTO  x_effective_from_date;
  IF effective_from_date_csr%NOTFOUND THEN
    x_no_data_found := TRUE;
  ELSE
    x_no_data_found := FALSE;
  END IF;
  CLOSE effective_from_date_csr;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
END;

procedure get_product(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_khr_id                  IN  okc_k_headers_b.id%type,
    x_pdt_parameter_rec       OUT NOCOPY OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type)
IS

    l_api_name		CONSTANT VARCHAR2(30) := 'get_product';
    l_api_version	CONSTANT NUMBER	      := 1.0;

    p_pdtv_rec            OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    --x_pdt_parameter_rec2  OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    x_no_data_found       BOOLEAN;

    CURSOR l_hdr_csr(  chrId NUMBER ) IS
    SELECT
	   CHR.authoring_org_id,
	   CHR.inv_organization_id,
           khr.deal_type,
           pdt.id  pid,
	   NVL(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_b CHR,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = CHR.id
        AND CHR.id = chrId
        AND khr.pdt_id = pdt.id;

    l_hdr_rec l_hdr_csr%ROWTYPE;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN  l_hdr_csr(p_khr_id);
    FETCH l_hdr_csr INTO l_hdr_rec;
    IF l_hdr_csr%NOTFOUND THEN
        CLOSE l_hdr_csr;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_hdr_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In get_product: deal_type=' || l_hdr_rec.deal_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pid=' || l_hdr_rec.pid);
    END IF;

    p_pdtv_rec.id := l_hdr_rec.pid;

    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_pdtv_rec          => p_pdtv_rec,
	                x_no_data_found     => x_no_data_found,
                        p_pdt_parameter_rec => x_pdt_parameter_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF  NVL(x_pdt_parameter_rec.Name,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --x_pdt_parameter_rec := x_pdt_parameter_rec2;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_pdt_parameter_rec.name=' || x_pdt_parameter_rec.name);
    END IF;
EXCEPTION WHEN OTHERS
  THEN
    NULL;

END;

procedure get_product2(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_khr_id                  IN  okc_k_headers_b.id%type,
    x_product_id              OUT NOCOPY NUMBER,
    x_pdt_parameter_rec       OUT NOCOPY OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type)
IS

    l_api_name		CONSTANT VARCHAR2(30) := 'get_product2';
    l_api_version	CONSTANT NUMBER	      := 1.0;

    p_pdtv_rec            OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    --x_pdt_parameter_rec2  OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    x_no_data_found       BOOLEAN;

    CURSOR l_hdr_csr(  chrId NUMBER ) IS
    SELECT
	   CHR.authoring_org_id,
	   CHR.inv_organization_id,
           khr.deal_type,
           pdt.id  pid,
	   NVL(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_b CHR,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = CHR.id
        AND CHR.id = chrId
        AND khr.pdt_id = pdt.id;

    l_hdr_rec l_hdr_csr%ROWTYPE;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN  l_hdr_csr(p_khr_id);
    FETCH l_hdr_csr INTO l_hdr_rec;
    IF l_hdr_csr%NOTFOUND THEN
        CLOSE l_hdr_csr;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_hdr_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In get_product2: deal_type=' || l_hdr_rec.deal_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pid=' || l_hdr_rec.pid);
    END IF;

    p_pdtv_rec.id := l_hdr_rec.pid;
    x_product_id := l_hdr_rec.pid;

    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_pdtv_rec          => p_pdtv_rec,
	                x_no_data_found     => x_no_data_found,
                        p_pdt_parameter_rec => x_pdt_parameter_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF  NVL(x_pdt_parameter_rec.Name,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --x_pdt_parameter_rec := x_pdt_parameter_rec2;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_pdt_parameter_rec.name=' || x_pdt_parameter_rec.name);
    END IF;
EXCEPTION WHEN OTHERS
  THEN
    NULL;

END;

PROCEDURE get_rate_rec(p_chr_id IN NUMBER,
                       p_parameter_type_code IN VARCHAR2,
                       p_effective_from_date IN DATE,
                       x_krpv_rec OUT NOCOPY krpv_rec_type,
                       x_no_data_found OUT NOCOPY BOOLEAN
                      ) IS
    CURSOR okl_k_rate_params_v_u1_csr (p_effective_from_date IN DATE,
                                       p_khr_id              IN NUMBER,
                                       p_parameter_type_code IN VARCHAR2) IS
    SELECT
            KHR_ID,
            PARAMETER_TYPE_CODE,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            INTEREST_INDEX_ID,
            BASE_RATE,
            INTEREST_START_DATE,
            ADDER_RATE,
            MAXIMUM_RATE,
            MINIMUM_RATE,
            PRINCIPAL_BASIS_CODE,
            DAYS_IN_A_MONTH_CODE,
            DAYS_IN_A_YEAR_CODE,
            INTEREST_BASIS_CODE,
            RATE_DELAY_CODE,
            RATE_DELAY_FREQUENCY,
            COMPOUNDING_FREQUENCY_CODE,
            CALCULATION_FORMULA_ID,
            CATCHUP_BASIS_CODE,
            CATCHUP_START_DATE,
            CATCHUP_SETTLEMENT_CODE,
            RATE_CHANGE_START_DATE,
            RATE_CHANGE_FREQUENCY_CODE,
            RATE_CHANGE_VALUE,
            CONVERSION_OPTION_CODE,
            NEXT_CONVERSION_DATE,
            CONVERSION_TYPE_CODE,
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
            LAST_UPDATE_LOGIN
      FROM Okl_K_Rate_Params_V
     WHERE effective_from_date = NVL(p_effective_from_date,effective_from_date)
     AND   khr_id = p_khr_id
     AND   parameter_type_code = NVL(p_parameter_type_code,parameter_type_code);
    l_okl_k_rate_params_v_u1       okl_k_rate_params_v_u1_csr%ROWTYPE;
BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_rate_params_v_u1_csr (p_effective_from_date,
                                     p_chr_id,
                                     p_parameter_type_code);
    FETCH okl_k_rate_params_v_u1_csr INTO
              x_krpv_rec.khr_id,
              x_krpv_rec.parameter_type_code,
              x_krpv_rec.effective_from_date,
              x_krpv_rec.effective_to_date,
              x_krpv_rec.interest_index_id,
              x_krpv_rec.base_rate,
              x_krpv_rec.interest_start_date,
              x_krpv_rec.adder_rate,
              x_krpv_rec.maximum_rate,
              x_krpv_rec.minimum_rate,
              x_krpv_rec.principal_basis_code,
              x_krpv_rec.days_in_a_month_code,
              x_krpv_rec.days_in_a_year_code,
              x_krpv_rec.interest_basis_code,
              x_krpv_rec.rate_delay_code,
              x_krpv_rec.rate_delay_frequency,
              x_krpv_rec.compounding_frequency_code,
              x_krpv_rec.calculation_formula_id,
              x_krpv_rec.catchup_basis_code,
              x_krpv_rec.catchup_start_date,
              x_krpv_rec.catchup_settlement_code,
              x_krpv_rec.rate_change_start_date,
              x_krpv_rec.rate_change_frequency_code,
              x_krpv_rec.rate_change_value,
              x_krpv_rec.conversion_option_code,
              x_krpv_rec.next_conversion_date,
              x_krpv_rec.conversion_type_code,
              x_krpv_rec.attribute_category,
              x_krpv_rec.attribute1,
              x_krpv_rec.attribute2,
              x_krpv_rec.attribute3,
              x_krpv_rec.attribute4,
              x_krpv_rec.attribute5,
              x_krpv_rec.attribute6,
              x_krpv_rec.attribute7,
              x_krpv_rec.attribute8,
              x_krpv_rec.attribute9,
              x_krpv_rec.attribute10,
              x_krpv_rec.attribute11,
              x_krpv_rec.attribute12,
              x_krpv_rec.attribute13,
              x_krpv_rec.attribute14,
              x_krpv_rec.attribute15,
              x_krpv_rec.created_by,
              x_krpv_rec.creation_date,
              x_krpv_rec.last_updated_by,
              x_krpv_rec.last_update_date,
              x_krpv_rec.last_update_login;
    x_no_data_found := okl_k_rate_params_v_u1_csr%NOTFOUND;
    CLOSE okl_k_rate_params_v_u1_csr;
    --RETURN(x_krpv_rec);

END;

--Bug# 7566308
PROCEDURE validate_rate_params_rbk(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpv_rec                IN krpv_rec_type,
    p_orig_eff_from_date      IN DATE DEFAULT NULL) IS

  CURSOR txn_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT a.date_transaction_occurred,
         b.date_last_interim_interest_cal
  FROM   okl_trx_contracts a,
         okl_k_headers b
  WHERE  a.khr_id_new   = p_chr_id
  AND    a.tcn_type = 'TRBK'
  AND    a.tsu_code = 'ENTERED'
  --rkuttiya added for 12.1.1 Multi GAAP
  AND    a.representation_type = 'PRIMARY'
  --
  AND    a.khr_id_new = b.id;

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_RATE_PARAMS_RBK';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_count NUMBER;
    l_interest_processing_started BOOLEAN := FALSE;
    l_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_orig_rate_rec krpv_rec_type;
    l_no_data BOOLEAN;
    l_rebook_date DATE;
    l_pdt_parameter_rec   OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    l_deal_type VARCHAR2(30);
    l_interest_calculation_basis VARCHAR2(30);
    l_revenue_recognition_method VARCHAR2(30);
    l_last_interest_calc_date DATE;
    l_curr_effective_date DATE;
    l_product_id NUMBER;
    l_contract_start_date DATE;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);


    get_product2(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => p_krpv_rec.khr_id,
          x_product_id    => l_product_id,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_deal_type := l_pdt_parameter_rec.deal_type;
    l_interest_calculation_basis := l_pdt_parameter_rec.interest_calculation_basis;
    l_revenue_recognition_method := l_pdt_parameter_rec.revenue_recognition_method;

    l_interest_processing_started := interest_processing(
                                     p_krpv_rec.khr_id,
                                     l_contract_number,
                                     l_contract_start_date);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After l_interest_processing_started...');
    END IF;
    IF (l_interest_processing_started) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_interest_processing_started=TRUE');
      END IF;
    ELSE
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_interest_processing_started=FALSE');
      END IF;
    END IF;
    get_rate_rec(
            p_chr_id => p_krpv_rec.khr_id,
            p_parameter_type_code => p_krpv_rec.parameter_type_code,
            p_effective_from_date => p_krpv_rec.effective_from_date,
            x_krpv_rec => l_orig_rate_rec,
            x_no_data_found => l_no_data);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_rate_rec...');
    END IF;

    -- If validate_rate_params_rbk is called during create flow, then we need to
    -- check if rate parameters have been changed from the ones on the previous
    -- open-ended rate
    IF (l_no_data) AND (p_orig_eff_from_date IS NOT NULL )THEN
       get_rate_rec(
            p_chr_id => p_krpv_rec.khr_id,
            p_parameter_type_code => p_krpv_rec.parameter_type_code,
            p_effective_from_date => p_orig_eff_from_date,
            x_krpv_rec => l_orig_rate_rec,
            x_no_data_found => l_no_data);
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_rate_rec 1...');
      END IF;
    END IF;

    IF (l_interest_processing_started) THEN
      NULL;
      --get_rate_rec and compare if some values changed which are not allowed
      IF NOT(l_no_data) THEN
        IF ((l_orig_rate_rec.BASE_RATE IS NOT NULL AND
             l_orig_rate_rec.BASE_RATE <> G_MISS_NUM) OR
            (p_krpv_rec.BASE_RATE IS NOT NULL AND
             p_krpv_rec.BASE_RATE <> G_MISS_NUM)) AND
           (l_orig_rate_rec.BASE_RATE <> p_krpv_rec.BASE_RATE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'BASE_RATE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.INTEREST_START_DATE IS NOT NULL AND
             l_orig_rate_rec.INTEREST_START_DATE <> G_MISS_DATE) OR
            (p_krpv_rec.INTEREST_START_DATE IS NOT NULL AND
             p_krpv_rec.INTEREST_START_DATE <> G_MISS_DATE)) AND
           (l_orig_rate_rec.INTEREST_START_DATE <> p_krpv_rec.INTEREST_START_DATE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'INTEREST_START_DATE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.PRINCIPAL_BASIS_CODE IS NOT NULL AND
             l_orig_rate_rec.PRINCIPAL_BASIS_CODE <> G_MISS_CHAR) OR
            (p_krpv_rec.PRINCIPAL_BASIS_CODE IS NOT NULL AND
             p_krpv_rec.PRINCIPAL_BASIS_CODE <> G_MISS_CHAR)) AND
           (l_orig_rate_rec.PRINCIPAL_BASIS_CODE <> p_krpv_rec.PRINCIPAL_BASIS_CODE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'PRINCIPAL_BASIS_CODE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.DAYS_IN_A_MONTH_CODE IS NOT NULL AND
             l_orig_rate_rec.DAYS_IN_A_MONTH_CODE <> G_MISS_CHAR) OR
            (p_krpv_rec.DAYS_IN_A_MONTH_CODE IS NOT NULL AND
             p_krpv_rec.DAYS_IN_A_MONTH_CODE <> G_MISS_CHAR)) AND
           (l_orig_rate_rec.DAYS_IN_A_MONTH_CODE <> p_krpv_rec.DAYS_IN_A_MONTH_CODE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'DAYS_IN_A_MONTH_CODE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.DAYS_IN_A_YEAR_CODE IS NOT NULL AND
             l_orig_rate_rec.DAYS_IN_A_YEAR_CODE <> G_MISS_CHAR) OR
            (p_krpv_rec.DAYS_IN_A_YEAR_CODE IS NOT NULL AND
             p_krpv_rec.DAYS_IN_A_YEAR_CODE <> G_MISS_CHAR)) AND
           (l_orig_rate_rec.DAYS_IN_A_YEAR_CODE <> p_krpv_rec.DAYS_IN_A_YEAR_CODE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'DAYS_IN_A_YEAR_CODE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.CATCHUP_START_DATE IS NOT NULL AND
             l_orig_rate_rec.CATCHUP_START_DATE <> G_MISS_DATE) OR
            (p_krpv_rec.CATCHUP_START_DATE IS NOT NULL AND
             p_krpv_rec.CATCHUP_START_DATE <> G_MISS_DATE)) AND
           (l_orig_rate_rec.CATCHUP_START_DATE <> p_krpv_rec.CATCHUP_START_DATE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'CATCHUP_START_DATE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.CATCHUP_SETTLEMENT_CODE IS NOT NULL AND
             l_orig_rate_rec.CATCHUP_SETTLEMENT_CODE <> G_MISS_CHAR) OR
            (p_krpv_rec.CATCHUP_SETTLEMENT_CODE IS NOT NULL AND
             p_krpv_rec.CATCHUP_SETTLEMENT_CODE <> G_MISS_CHAR)) AND
           (l_orig_rate_rec.CATCHUP_SETTLEMENT_CODE <> p_krpv_rec.CATCHUP_SETTLEMENT_CODE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'CATCHUP_SETTLEMENT_CODE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF ((l_orig_rate_rec.RATE_CHANGE_START_DATE IS NOT NULL AND
             l_orig_rate_rec.RATE_CHANGE_START_DATE <> G_MISS_DATE) OR
            (p_krpv_rec.RATE_CHANGE_START_DATE IS NOT NULL AND
             p_krpv_rec.RATE_CHANGE_START_DATE <> G_MISS_DATE)) AND
           (l_orig_rate_rec.RATE_CHANGE_START_DATE <> p_krpv_rec.RATE_CHANGE_START_DATE) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                              ,p_token1       => 'PARAMETER_NAME'
                              ,p_token1_value => 'RATE_CHANGE_START_DATE'
                              ,p_token2       => 'CONTRACT_NUMBER'
                              ,p_token2_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
      END IF;  -- no_data
    END IF;  -- rebook_copy

    IF NOT(l_no_data) THEN
        -- If any of the rates change, then check effective date
        FOR txn_rec IN txn_csr (p_krpv_rec.khr_id)
        LOOP
          l_rebook_date := txn_rec.date_transaction_occurred;
          l_last_interest_calc_date := txn_rec.date_last_interim_interest_cal;
        END LOOP;
        l_curr_effective_date := l_orig_rate_rec.effective_from_date;


        IF (((l_orig_rate_rec.INTEREST_INDEX_ID IS NOT NULL AND
              l_orig_rate_rec.INTEREST_INDEX_ID <> G_MISS_NUM) OR
             (p_krpv_rec.INTEREST_INDEX_ID IS NOT NULL AND
              p_krpv_rec.INTEREST_INDEX_ID <> G_MISS_NUM)) AND
            (l_orig_rate_rec.INTEREST_INDEX_ID <> p_krpv_rec.INTEREST_INDEX_ID))
        OR
           (((l_orig_rate_rec.ADDER_RATE IS NOT NULL AND
              l_orig_rate_rec.ADDER_RATE <> G_MISS_NUM) OR
             (p_krpv_rec.ADDER_RATE IS NOT NULL AND
              p_krpv_rec.ADDER_RATE <> G_MISS_NUM)) AND
            (l_orig_rate_rec.ADDER_RATE <> p_krpv_rec.ADDER_RATE))
        OR
           (((l_orig_rate_rec.MAXIMUM_RATE IS NOT NULL AND
              l_orig_rate_rec.MAXIMUM_RATE <> G_MISS_NUM) OR
             (p_krpv_rec.MAXIMUM_RATE IS NOT NULL AND
              p_krpv_rec.MAXIMUM_RATE <> G_MISS_NUM)) AND
            (l_orig_rate_rec.MAXIMUM_RATE <> p_krpv_rec.MAXIMUM_RATE))
        OR
           (((l_orig_rate_rec.MINIMUM_RATE IS NOT NULL AND
              l_orig_rate_rec.MINIMUM_RATE <> G_MISS_NUM) OR
             (p_krpv_rec.MINIMUM_RATE IS NOT NULL AND
              p_krpv_rec.MINIMUM_RATE <> G_MISS_NUM)) AND
            (l_orig_rate_rec.MINIMUM_RATE <> p_krpv_rec.MINIMUM_RATE))
        OR
           (((l_orig_rate_rec.INTEREST_BASIS_CODE IS NOT NULL AND
              l_orig_rate_rec.INTEREST_BASIS_CODE <> G_MISS_CHAR) OR
             (p_krpv_rec.INTEREST_BASIS_CODE IS NOT NULL AND
              p_krpv_rec.INTEREST_BASIS_CODE <> G_MISS_CHAR)) AND
            (l_orig_rate_rec.INTEREST_BASIS_CODE <> p_krpv_rec.INTEREST_BASIS_CODE))
        OR
           (((l_orig_rate_rec.RATE_DELAY_CODE IS NOT NULL AND
              l_orig_rate_rec.RATE_DELAY_CODE <> G_MISS_CHAR) OR
             (p_krpv_rec.RATE_DELAY_CODE IS NOT NULL AND
              p_krpv_rec.RATE_DELAY_CODE <> G_MISS_CHAR)) AND
            (l_orig_rate_rec.RATE_DELAY_CODE <> p_krpv_rec.RATE_DELAY_CODE))
        OR
           (((l_orig_rate_rec.RATE_DELAY_FREQUENCY IS NOT NULL AND
              l_orig_rate_rec.RATE_DELAY_FREQUENCY <> G_MISS_NUM) OR
             (p_krpv_rec.RATE_DELAY_FREQUENCY IS NOT NULL AND
              p_krpv_rec.RATE_DELAY_FREQUENCY <> G_MISS_NUM)) AND
            (l_orig_rate_rec.RATE_DELAY_FREQUENCY <> p_krpv_rec.RATE_DELAY_FREQUENCY))
        OR
           (((l_orig_rate_rec.RATE_CHANGE_FREQUENCY_CODE IS NOT NULL AND
              l_orig_rate_rec.RATE_CHANGE_FREQUENCY_CODE <> G_MISS_CHAR) OR
             (p_krpv_rec.RATE_CHANGE_FREQUENCY_CODE IS NOT NULL AND
              p_krpv_rec.RATE_CHANGE_FREQUENCY_CODE <> G_MISS_CHAR)) AND
            (l_orig_rate_rec.RATE_CHANGE_FREQUENCY_CODE <> p_krpv_rec.RATE_CHANGE_FREQUENCY_CODE))
        OR
           (((l_orig_rate_rec.RATE_CHANGE_VALUE IS NOT NULL AND
              l_orig_rate_rec.RATE_CHANGE_VALUE <> G_MISS_NUM) OR
             (p_krpv_rec.RATE_CHANGE_VALUE IS NOT NULL AND
              p_krpv_rec.RATE_CHANGE_VALUE <> G_MISS_NUM)) AND
            (l_orig_rate_rec.RATE_CHANGE_VALUE <> p_krpv_rec.RATE_CHANGE_VALUE))
        THEN
           -- IF any of the above values changed
          IF (l_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
              l_interest_calculation_basis IN ('FIXED', 'FLOAT_FACTORS')) THEN
            IF (p_krpv_rec.EFFECTIVE_FROM_DATE < l_orig_rate_rec.EFFECTIVE_FROM_DATE) THEN
              OKC_API.SET_MESSAGE(
                               p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_EFF_DATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
          ELSIF (l_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
                 l_interest_calculation_basis = 'REAMORT' ) THEN
            IF (p_krpv_rec.EFFECTIVE_FROM_DATE <= l_rebook_date) OR
              (p_krpv_rec.EFFECTIVE_FROM_DATE <= l_last_interest_calc_date)
            THEN
              OKC_API.SET_MESSAGE(
                               p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_RBK_DATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
          ELSIF ((l_deal_type = 'LOAN') AND
                  l_interest_calculation_basis IN
                    ('FIXED', 'FLOAT', 'CATCHUP/CLEANUP' )) THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_krpv_rec.effective_from_date=' || p_krpv_rec.effective_from_date);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_rate_rec.effective_from_date=' || l_orig_rate_rec.effective_from_date);
            END IF;
            IF (p_krpv_rec.EFFECTIVE_FROM_DATE < l_orig_rate_rec.EFFECTIVE_FROM_DATE) THEN
              OKC_API.SET_MESSAGE(
                               p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_EFF_DATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
          ELSIF (l_deal_type = 'LOAN' AND
                 l_interest_calculation_basis = 'REAMORT') THEN
            IF (p_krpv_rec.EFFECTIVE_FROM_DATE <= l_rebook_date) OR
              (p_krpv_rec.EFFECTIVE_FROM_DATE <= l_last_interest_calc_date)
            THEN
              OKC_API.SET_MESSAGE(
                               p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_RBK_DATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
          ELSIF (l_deal_type = 'LOAN-REVOLVING' AND
                 l_interest_calculation_basis = 'FLOAT') THEN
            IF (p_krpv_rec.EFFECTIVE_FROM_DATE < l_orig_rate_rec.EFFECTIVE_FROM_DATE) THEN
              OKC_API.SET_MESSAGE(
                               p_app_name     => G_APP_NAME
                              ,p_msg_name     => 'OKL_LLA_VAR_RATE_EFF_DATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
          END IF;  -- if deal_type
        END IF; -- if any rate params changed

    END IF; -- if no_data

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;
--Bug# 7566308

  /* This is to be called from contract import and UI*/
--Zero
PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpv_rec                     IN  krpv_rec_type,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type,
    p_validate_flag                IN  VARCHAR2 DEFAULT 'Y') IS

    CURSOR C1(p_id NUMBER) IS
    SELECT start_date
    FROM   OKC_K_HEADERS_B
    WHERE  ID = p_id;

    CURSOR C2(p_id NUMBER, p_parameter_type_code VARCHAR2) IS
    SELECT COUNT(1) COUNT1
    FROM   OKL_K_RATE_PARAMS
    WHERE  KHR_ID = p_id
    AND    PARAMETER_TYPE_CODE = p_parameter_type_code
    AND    EFFECTIVE_TO_DATE IS NULL;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;

    l_krpv_rec krpv_rec_type;
    --x_krpv_rec krpv_rec_type;
    l_count NUMBER;
    l_rate_count NUMBER;
    l_k_rate_tbl krpv_tbl_type;
    l_pdt_parameter_rec   OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    l_product_id NUMBER;
    l_contract_start_date DATE;

    --Bug# 7566308
    l_rebook_copy BOOLEAN := FALSE;

    l_effective_from_date DATE;
    l_orig_system_source_code VARCHAR2(30);
    l_orig_system_id1 NUMBER;
    l_orig_effective_from_date DATE;
    l_last_interest_cal_date DATE;

    CURSOR get_effective_from_date_csr(
          p_khr_id NUMBER,
          p_parameter_type_code VARCHAR2) IS
    select rate.effective_from_date,
           contract.orig_system_source_code,
           lease.date_last_interim_interest_cal,
           contract.orig_system_id1
    FROM   OKL_K_RATE_PARAMS rate,
           OKC_K_HEADERS_B contract,
           OKL_K_HEADERS lease
    WHERE  rate.khr_id = p_khr_id
    AND    rate.parameter_type_code =  p_parameter_type_code
    AND    rate.effective_to_date is null
    AND    rate.khr_id = contract.id
    AND    contract.id = lease.id;

    --Cursor to query the last billed due date of the stream.
    CURSOR get_last_billed_due_date(
           p_chr_id OKC_K_HEADERS_B.ID%TYPE
         , p_stream_purpose OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE) IS
    SELECT MAX(STE.STREAM_ELEMENT_DATE) LAST_STREAM_DUE_DATE
    FROM  OKL_STRM_ELEMENTS STE
        , OKL_STREAMS       STM
        , OKL_STRM_TYPE_V   STY
        , OKL_K_HEADERS     KHR
        , OKC_K_HEADERS_B CHR
    WHERE STM.ID         = STE.STM_ID
      AND STY.ID         = STM.STY_ID
      AND KHR.ID         = STM.KHR_ID
      AND CHR.ID         = KHR.ID
      AND STE.DATE_BILLED IS NOT NULL
      AND CHR.ID         = p_chr_id
      AND STY.STREAM_TYPE_PURPOSE  = p_stream_purpose;

    l_last_billed_due_date DATE;
    --Bug# 7566308
begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    --Bug# 7566308
    l_rebook_copy := is_rebook_copy(p_krpv_rec.khr_id);
    IF (l_rebook_copy) THEN

      l_effective_from_date := null;
      FOR r IN get_effective_from_date_csr(p_krpv_rec.khr_id, p_krpv_rec.parameter_type_code)
      LOOP
        l_effective_from_date := r.effective_from_date;
        l_orig_system_source_code := r.orig_system_source_code;
        l_last_interest_cal_date := r.date_last_interim_interest_cal;
        l_orig_system_id1 := r.orig_system_id1;
      END LOOP;

      validate_rate_params_rbk(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_krpv_rec      => p_krpv_rec,
          p_orig_eff_from_date => l_effective_from_date);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    --Bug# 7566308

    FOR r IN C1(p_krpv_rec.khr_id)
    LOOP
      l_contract_start_date := r.start_date;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_start_date=' || l_contract_start_date);
    END IF;

    --Bug# 7566308
    IF NOT l_rebook_copy THEN
      FOR r IN C2(p_krpv_rec.khr_id, p_krpv_rec.parameter_type_code)
      LOOP
        l_rate_count := r.count1;
      END LOOP;

      IF (l_rate_count > 0) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => 'OKL_LLA_VAR_RATE_EXISTS');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --Bug# 7566308

    l_krpv_rec.khr_id := p_krpv_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpv_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpv_rec.effective_from_Date;
    l_krpv_rec.interest_index_id := p_krpv_rec.interest_index_id;
    l_krpv_rec.base_rate := p_krpv_rec.base_rate;
    l_krpv_rec.interest_start_date := p_krpv_rec.interest_start_date;
    l_krpv_rec.adder_rate := p_krpv_rec.adder_rate;
    l_krpv_rec.maximum_rate := p_krpv_rec.maximum_rate;
    l_krpv_rec.minimum_rate := p_krpv_rec.minimum_rate;
    l_krpv_rec.principal_basis_code := p_krpv_rec.principal_basis_code;
    l_krpv_rec.days_in_a_month_code := p_krpv_rec.days_in_a_month_code;
    l_krpv_rec.days_in_a_year_code := p_krpv_rec.days_in_a_year_code;
    l_krpv_rec.interest_basis_code := p_krpv_rec.interest_basis_code;

    l_krpv_rec.rate_delay_code := p_krpv_rec.rate_delay_code;
    l_krpv_rec.rate_delay_frequency := p_krpv_rec.rate_delay_frequency;
    l_krpv_rec.compounding_frequency_code := p_krpv_rec.compounding_frequency_code;
    l_krpv_rec.calculation_formula_id := p_krpv_rec.calculation_formula_id;
    l_krpv_rec.catchup_basis_code := p_krpv_rec.catchup_basis_code;
    l_krpv_rec.catchup_start_date := p_krpv_rec.catchup_start_date;
    l_krpv_rec.catchup_settlement_code := p_krpv_rec.catchup_settlement_code;
    l_krpv_rec.catchup_frequency_code := p_krpv_rec.catchup_frequency_code;
    l_krpv_rec.rate_change_start_date := p_krpv_rec.rate_change_start_date;
    l_krpv_rec.rate_change_frequency_code := p_krpv_rec.rate_change_frequency_code;
    l_krpv_rec.rate_change_value := p_krpv_rec.rate_change_value;

    l_krpv_rec.conversion_option_code := p_krpv_rec.conversion_option_code;
    l_krpv_rec.next_conversion_date := p_krpv_rec.next_conversion_date;
    l_krpv_rec.conversion_type_code := p_krpv_rec.conversion_type_code;
    print_krpv_rec(l_krpv_rec);

    select count(1) into l_count
    FROM   OKL_K_RATE_PARAMS
    WHERE  KHR_ID = p_krpv_rec.khr_id
    AND    EFFECTIVE_FROM_DATE = p_krpv_rec.effective_from_date
    AND    PARAMETER_TYPE_CODE = p_krpv_rec.parameter_type_code;

    l_k_rate_tbl(1) := l_krpv_rec;
    --Bug# 7440232
    IF (p_validate_flag IN ('Y','F')) THEN
      get_product2(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => l_krpv_rec.khr_id,
          x_product_id    => l_product_id,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

      --Bug# 7440232
      validate_k_rate_params(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_product_id    => l_product_id,
          p_k_rate_tbl    => l_k_rate_tbl,
          p_validate_flag =>  p_validate_flag);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Bug 4722746
      IF (l_pdt_parameter_rec.interest_calculation_basis = 'CATCHUP/CLEANUP'
          AND l_pdt_parameter_rec.revenue_recognition_method = 'STREAMS') THEN

        --print('Catchup :1');
        IF (l_krpv_rec.catchup_frequency_code is NULL OR
            l_krpv_rec.catchup_frequency_code = G_MISS_CHAR) AND
           (l_krpv_rec.catchup_start_date is NULL OR
            l_krpv_rec.catchup_start_date = G_MISS_DATE) AND
           (l_krpv_rec.catchup_settlement_code is NULL OR
            l_krpv_rec.catchup_settlement_code = G_MISS_CHAR) AND
           (l_krpv_rec.catchup_basis_code is NULL OR
            l_krpv_rec.catchup_basis_code = G_MISS_CHAR) THEN
          -- All four are null
           IF (l_krpv_rec.rate_change_start_date is NULL OR
               l_krpv_rec.rate_change_start_date = G_MISS_DATE) AND
              (l_krpv_rec.rate_change_value is NULL OR
               l_krpv_rec.rate_change_value = G_MISS_NUM) AND
              (l_krpv_rec.rate_change_frequency_code is NULL OR
               l_krpv_rec.rate_change_frequency_code = G_MISS_CHAR) AND
              (l_krpv_rec.compounding_frequency_code is NULL OR
               l_krpv_rec.compounding_frequency_code = G_MISS_CHAR) AND
              (l_krpv_rec.calculation_formula_id is NULL OR
               l_krpv_rec.calculation_formula_id = G_MISS_NUM) AND
              (l_krpv_rec.rate_delay_code is NULL OR
               l_krpv_rec.rate_delay_code = G_MISS_CHAR) AND
              (l_krpv_rec.rate_delay_frequency is NULL OR
               l_krpv_rec.rate_delay_frequency = G_MISS_NUM) THEN
              NULL;
           ELSE
             OKC_API.set_message(p_app_name => G_APP_NAME,
                                 p_msg_name => G_REQUIRED_VALUE,
                                 p_token1 => G_COL_NAME_TOKEN,
                                 p_token1_value => 'CATCHUP FREQUENCY');
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        ELSE
          -- One of the four is not null
          IF (l_krpv_rec.catchup_frequency_code is NOT NULL AND
              l_krpv_rec.catchup_frequency_code <> G_MISS_CHAR) THEN
            NULL;
          ELSE
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Catchup Frequency');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --print('Catchup :2');
          IF (l_krpv_rec.catchup_start_date is NOT NULL AND
              l_krpv_rec.catchup_start_date <> G_MISS_DATE) THEN
            NULL;
          ELSE
            -- Default from contract start date
            l_krpv_rec.catchup_start_date := l_contract_start_date;
          END IF;

          --print('Catchup :3');
          IF (l_krpv_rec.catchup_settlement_code is NOT NULL AND
              l_krpv_rec.catchup_settlement_code <> G_MISS_CHAR) THEN
            NULL;
          ELSE
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Catchup Settlement');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --print('Catchup :4');
          IF (l_krpv_rec.catchup_basis_code is NOT NULL AND
              l_krpv_rec.catchup_basis_code <> G_MISS_CHAR) THEN
            NULL;
          ELSE
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Catchup Basis');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


        END IF;

      END IF; -- if STREAMS and CATCHUP/CLEANUP

      --Bug# 7566308
      -- Moved validations on adding a new effective dated rate during rebook
      -- from copy_k_rate_params to here
      -- Start Rebook checks
      IF (l_rebook_copy) THEN

        -- Bug 4999888
        IF (l_pdt_parameter_rec.interest_calculation_basis = 'FIXED' and l_pdt_parameter_rec.revenue_recognition_method='ACTUAL') THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:Inside FIXED and ACTUAL...');
          END IF;

          OPEN get_last_billed_due_date(l_orig_system_id1, 'LOAN_PAYMENT');
          FETCH get_last_billed_due_date
          INTO l_last_billed_due_date;
          CLOSE get_last_billed_due_date;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_last_billed_due_date=' || l_last_billed_due_date);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_krpv_rec.effective_from_Date=' || p_krpv_rec.effective_from_Date);
          END IF;
          IF (l_last_billed_due_date IS NOT NULL AND
              p_krpv_rec.effective_from_Date <= l_last_billed_due_date) THEN
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_LLA_VAR_RATE_INT_DATE',
                                p_token1 => 'EFF_DATE',
                                p_token1_value => p_krpv_rec.effective_from_Date,
                                p_token2 => 'INTEREST_DATE',
                                p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- Bug 4999888
        IF (l_pdt_parameter_rec.interest_calculation_basis IN ('FLOAT', 'REAMORT', 'FLOAT_FACTORS', 'CATCHUP/CLEANUP')) THEN
          IF (l_last_interest_cal_date IS NOT NULL) THEN
            IF (p_krpv_rec.effective_from_Date <= l_last_interest_cal_date) THEN
              OKC_API.set_message(p_app_name => G_APP_NAME,
                                  p_msg_name => 'OKL_LLA_VAR_RATE_INT_DATE',
                                  p_token1 => 'EFF_DATE',
                                  p_token1_value => p_krpv_rec.effective_from_Date,
                                  p_token2 => 'INTEREST_DATE',
                                  p_token2_value => l_last_interest_cal_date);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END IF;
      END IF;
      -- End Rebook checks
      --Bug# 7566308

    END IF; -- if validate_flag

    IF (l_count > 0) THEN
      OKL_KRP_PVT.update_row(
         p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         l_krpv_rec,
         x_krpv_rec);
    ELSE
      OKL_KRP_PVT.insert_row(
         p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         l_krpv_rec,
         x_krpv_rec);

      --Bug# 7566308
      -- End date the previous open-ended rate record
      --  when a new effective dated rate is added
      IF (l_rebook_copy) THEN
        FOR r IN get_effective_from_date_csr(l_orig_system_id1,
                                             p_krpv_rec.parameter_type_code)
        LOOP
          l_orig_effective_from_date := r.effective_from_date;
        END LOOP;

        UPDATE  OKL_K_RATE_PARAMS
        SET   EFFECTIVE_TO_DATE = p_krpv_rec.effective_from_Date - 1
        WHERE KHR_ID = p_krpv_rec.khr_id
        AND   PARAMETER_TYPE_CODE = p_krpv_rec.parameter_type_code
        AND   EFFECTIVE_FROM_DATE = l_effective_from_date
        AND   EFFECTIVE_TO_DATE IS NULL;
      END IF;
      --Bug# 7566308
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_contract_status_pub.cascade_lease_status_edit
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 p_chr_id          => l_krpv_rec.khr_id);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

end;

-- First
PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpr_rec                     IN  krpr_rec_type,
    x_krpr_rec                     OUT NOCOPY krpr_rec_type) is

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;

    l_krpv_rec krpv_rec_type;
    x_krpv_rec krpv_rec_type;
    l_count NUMBER;

begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);


    l_krpv_rec.khr_id := p_krpr_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpr_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpr_rec.effective_from_Date;
    l_krpv_rec.interest_index_id := p_krpr_rec.interest_index_id;
    l_krpv_rec.base_rate := p_krpr_rec.base_rate;
    l_krpv_rec.interest_start_date := p_krpr_rec.interest_start_date;
    l_krpv_rec.adder_rate := p_krpr_rec.adder_rate;
    l_krpv_rec.maximum_rate := p_krpr_rec.maximum_rate;
    l_krpv_rec.minimum_rate := p_krpr_rec.minimum_rate;
    l_krpv_rec.principal_basis_code := p_krpr_rec.principal_basis_code;
    l_krpv_rec.days_in_a_month_code := p_krpr_rec.days_in_a_month_code;
    l_krpv_rec.days_in_a_year_code := p_krpr_rec.days_in_a_year_code;
    l_krpv_rec.interest_basis_code := p_krpr_rec.interest_basis_code;

    select count(1) into l_count
    FROM   OKL_K_RATE_PARAMS
    WHERE  KHR_ID = p_krpr_rec.khr_id
    AND    EFFECTIVE_FROM_DATE = p_krpr_rec.effective_from_date
    AND    PARAMETER_TYPE_CODE = p_krpr_rec.parameter_type_code;

    IF (l_count > 0) THEN
      OKL_KRP_PVT.update_row(
         p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         l_krpv_rec,
         x_krpv_rec);
    ELSE
      OKL_KRP_PVT.insert_row(
         p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         l_krpv_rec,
         x_krpv_rec);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_krpr_rec.khr_id := x_krpv_rec.khr_id;
    x_krpr_rec.parameter_type_code := x_krpv_rec.parameter_type_code;
    x_krpr_rec.effective_from_date := x_krpv_rec.effective_from_date;
    x_krpr_rec.effective_to_date := x_krpv_rec.effective_to_date;
    x_krpr_rec.interest_index_id := x_krpv_rec.interest_index_id;
    x_krpr_rec.base_rate := x_krpv_rec.base_rate;
    x_krpr_rec.interest_start_date := x_krpv_rec.interest_start_date;
    x_krpr_rec.adder_rate := x_krpv_rec.adder_rate;
    x_krpr_rec.maximum_rate := x_krpv_rec.maximum_rate;
    x_krpr_rec.minimum_rate := x_krpv_rec.minimum_rate;
    x_krpr_rec.principal_basis_code := x_krpv_rec.principal_basis_code;
    x_krpr_rec.days_in_a_month_code := x_krpv_rec.days_in_a_month_code;
    x_krpr_rec.days_in_a_year_code := x_krpv_rec.days_in_a_year_code;
    x_krpr_rec.interest_basis_code := x_krpv_rec.interest_basis_code;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

end;

-- Second
PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpar_rec                    IN  krpar_rec_type,
    x_krpar_rec                    OUT NOCOPY krpar_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    x_krpv_rec krpv_rec_type;
    l_count NUMBER;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    select count(1) into l_count
    FROM   OKL_K_RATE_PARAMS
    WHERE  KHR_ID = p_krpar_rec.khr_id
    AND    EFFECTIVE_FROM_DATE = p_krpar_rec.effective_from_date
    AND    PARAMETER_TYPE_CODE = p_krpar_rec.parameter_type_code;


    l_krpv_rec.khr_id := p_krpar_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpar_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpar_rec.effective_from_date;
    l_krpv_rec.effective_to_date := p_krpar_rec.effective_to_date;
    l_krpv_rec.rate_delay_code := p_krpar_rec.rate_delay_code;
    l_krpv_rec.rate_delay_frequency := p_krpar_rec.rate_delay_frequency;
    l_krpv_rec.compounding_frequency_code := p_krpar_rec.compounding_frequency_code;
    l_krpv_rec.calculation_formula_id := p_krpar_rec.calculation_formula_id;
    l_krpv_rec.catchup_basis_code := p_krpar_rec.catchup_basis_code;
    l_krpv_rec.catchup_start_date := p_krpar_rec.catchup_start_date;
    l_krpv_rec.catchup_settlement_code := p_krpar_rec.catchup_settlement_code;
    l_krpv_rec.rate_change_start_date := p_krpar_rec.rate_change_start_date;
    l_krpv_rec.rate_change_frequency_code := p_krpar_rec.rate_change_frequency_code;
    l_krpv_rec.rate_change_value := p_krpar_rec.rate_change_value;
    IF (l_count > 0) then
      OKL_KRP_PVT.update_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);
    ELSE
      OKL_KRP_PVT.insert_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_krpar_rec.khr_id := x_krpv_rec.khr_id;
    x_krpar_rec.parameter_type_code := x_krpv_rec.parameter_type_code;
    x_krpar_rec.effective_from_date := x_krpv_rec.effective_from_date;
    x_krpar_rec.effective_to_date := x_krpv_rec.effective_to_date;
    x_krpar_rec.rate_delay_code := x_krpv_rec.rate_delay_code;
    x_krpar_rec.rate_delay_frequency := x_krpv_rec.rate_delay_frequency;
    x_krpar_rec.compounding_frequency_code := x_krpv_rec.compounding_frequency_code;
    x_krpar_rec.calculation_formula_id := x_krpv_rec.calculation_formula_id;
    x_krpar_rec.catchup_basis_code := x_krpv_rec.catchup_basis_code;
    x_krpar_rec.catchup_start_date := x_krpv_rec.catchup_start_date;
    x_krpar_rec.catchup_settlement_code := x_krpv_rec.catchup_settlement_code;
    x_krpar_rec.rate_change_start_date := x_krpv_rec.rate_change_start_date;
    x_krpar_rec.rate_change_frequency_code := x_krpv_rec.rate_change_frequency_code;
    x_krpar_rec.rate_change_value := x_krpv_rec.rate_change_value;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

-- Third
PROCEDURE create_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_krpc_rec                     IN  krpc_rec_type,
    x_krpc_rec                     OUT NOCOPY krpc_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    x_krpv_rec krpv_rec_type;
    l_count NUMBER;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    select count(1) into l_count
    FROM   OKL_K_RATE_PARAMS
    WHERE  KHR_ID = p_krpc_rec.khr_id
    AND    EFFECTIVE_FROM_DATE = p_krpc_rec.effective_from_date
    AND    PARAMETER_TYPE_CODE = p_krpc_rec.parameter_type_code;

    l_krpv_rec.khr_id := p_krpc_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpc_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpc_rec.effective_from_date;
    l_krpv_rec.effective_to_date := p_krpc_rec.effective_to_date;
    l_krpv_rec.conversion_option_code := p_krpc_rec.conversion_option_code;
    l_krpv_rec.next_conversion_date := p_krpc_rec.next_conversion_date;
    l_krpv_rec.conversion_type_code := p_krpc_rec.conversion_type_code;

    IF (l_count > 0) then
      OKL_KRP_PVT.update_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);
    ELSE
      OKL_KRP_PVT.insert_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);
    END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_krpc_rec.khr_id := x_krpv_rec.khr_id;
    x_krpc_rec.parameter_type_code := x_krpv_rec.parameter_type_code;
    x_krpc_rec.effective_from_date := x_krpv_rec.effective_from_date;
    x_krpc_rec.effective_to_date := x_krpv_rec.effective_to_date;
    x_krpc_rec.conversion_option_code := x_krpv_rec.conversion_option_code;
    x_krpc_rec.next_conversion_date := x_krpv_rec.next_conversion_date;
    x_krpc_rec.conversion_type_code := x_krpv_rec.conversion_type_code;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

  /* For both UI and contract import */
--Zero
PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpv_rec                IN krpv_rec_type,
    x_krpv_rec                OUT NOCOPY krpv_rec_type) IS

  CURSOR txn_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT a.date_transaction_occurred,
         b.date_last_interim_interest_cal
  FROM   okl_trx_contracts a,
         okl_k_headers b
  WHERE  a.khr_id_new   = p_chr_id
  AND    a.tcn_type = 'TRBK'
  AND    a.tsu_code = 'ENTERED'
  --rkuttiya added for 12.1.1 Multi GAAP
  AND    a.representation_type = 'PRIMARY'
  --
  AND    a.khr_id_new = b.id;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    --x_krpv_rec krpv_rec_type;
    l_count NUMBER;
    l_rebook_copy BOOLEAN := FALSE;
    l_interest_processing_started BOOLEAN := FALSE;
    l_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_orig_rate_rec krpv_rec_type;
    l_no_data BOOLEAN;
    l_rebook_date DATE;
    l_pdt_parameter_rec   OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    l_deal_type VARCHAR2(30);
    l_interest_calculation_basis VARCHAR2(30);
    l_revenue_recognition_method VARCHAR2(30);
    l_last_interest_calc_date DATE;
    l_curr_effective_date DATE;
    l_product_id NUMBER;
    l_contract_start_date DATE;
    l_krpv_tbl krpv_tbl_type;
    --l_k_rate_tbl krpv_tbl_type;
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update_k_rate_params:Printing input p_krpv_rec...');
    END IF;
    print_krpv_rec(p_krpv_rec);

    get_product2(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => p_krpv_rec.khr_id,
          x_product_id    => l_product_id,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_deal_type := l_pdt_parameter_rec.deal_type;
    l_interest_calculation_basis := l_pdt_parameter_rec.interest_calculation_basis;
    l_revenue_recognition_method := l_pdt_parameter_rec.revenue_recognition_method;

    --Bug# 7566308
    l_rebook_copy := is_rebook_copy(p_krpv_rec.khr_id);
    IF (l_rebook_copy) THEN
      validate_rate_params_rbk(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_krpv_rec      => p_krpv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --Bug# 7566308

    l_krpv_rec.khr_id := p_krpv_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpv_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpv_rec.effective_from_date;
    l_krpv_rec.effective_to_date := p_krpv_rec.effective_to_date;
    l_krpv_rec.interest_index_id := p_krpv_rec.interest_index_id;
    l_krpv_rec.base_rate := p_krpv_rec.base_rate;
    l_krpv_rec.interest_start_date := p_krpv_rec.interest_start_date;
    l_krpv_rec.adder_rate := p_krpv_rec.adder_rate;
    l_krpv_rec.maximum_rate := p_krpv_rec.maximum_rate;
    l_krpv_rec.minimum_rate := p_krpv_rec.minimum_rate;
    l_krpv_rec.principal_basis_code := p_krpv_rec.principal_basis_code;
    l_krpv_rec.days_in_a_month_code := p_krpv_rec.days_in_a_month_code;
    l_krpv_rec.days_in_a_year_code := p_krpv_rec.days_in_a_year_code;
    l_krpv_rec.interest_basis_code := p_krpv_rec.interest_basis_code;
    l_krpv_rec.rate_delay_code := p_krpv_rec.rate_delay_code;
    l_krpv_rec.rate_delay_frequency := p_krpv_rec.rate_delay_frequency;
    l_krpv_rec.compounding_frequency_code := p_krpv_rec.compounding_frequency_code;
    l_krpv_rec.calculation_formula_id := p_krpv_rec.calculation_formula_id;
    l_krpv_rec.catchup_basis_code := p_krpv_rec.catchup_basis_code;
    l_krpv_rec.catchup_start_date := p_krpv_rec.catchup_start_date;
    l_krpv_rec.catchup_settlement_code := p_krpv_rec.catchup_settlement_code;
    l_krpv_rec.catchup_frequency_code := p_krpv_rec.catchup_frequency_code;
    l_krpv_rec.rate_change_start_date := p_krpv_rec.rate_change_start_date;
    l_krpv_rec.rate_change_frequency_code := p_krpv_rec.rate_change_frequency_code;
    l_krpv_rec.rate_change_value := p_krpv_rec.rate_change_value;
    l_krpv_rec.conversion_option_code := p_krpv_rec.conversion_option_code;
    l_krpv_rec.next_conversion_date := p_krpv_rec.next_conversion_date;
    l_krpv_rec.conversion_type_code := p_krpv_rec.conversion_type_code;

    l_krpv_tbl(1) := l_krpv_rec;

    /*get_product2(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => l_krpv_rec.khr_id,
          x_product_id    => l_product_id,
          x_pdt_parameter_rec => l_pdt_parameter_rec); */

    --Bug# 7440232
    validate_k_rate_params(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_product_id    => l_product_id,
          p_k_rate_tbl    => l_krpv_tbl,
          p_validate_flag => 'F');

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

      -- Bug 4722746
      IF (l_pdt_parameter_rec.interest_calculation_basis = 'CATCHUP/CLEANUP'
          AND l_pdt_parameter_rec.revenue_recognition_method = 'STREAMS') THEN

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Catchup :5.0');
        END IF;
        IF (l_krpv_rec.catchup_frequency_code is NULL OR
            l_krpv_rec.catchup_frequency_code = G_MISS_CHAR) AND
           (l_krpv_rec.catchup_start_date is NULL OR
            l_krpv_rec.catchup_start_date = G_MISS_DATE) AND
           (l_krpv_rec.catchup_settlement_code is NULL OR
            l_krpv_rec.catchup_settlement_code = G_MISS_CHAR) AND
           (l_krpv_rec.catchup_basis_code is NULL OR
            l_krpv_rec.catchup_basis_code = G_MISS_CHAR) THEN
          -- All four are null
           IF (l_krpv_rec.rate_change_start_date is NULL OR
               l_krpv_rec.rate_change_start_date = G_MISS_DATE) AND
              (l_krpv_rec.rate_change_value is NULL OR
               l_krpv_rec.rate_change_value = G_MISS_NUM) AND
              (l_krpv_rec.rate_change_frequency_code is NULL OR
               l_krpv_rec.rate_change_frequency_code = G_MISS_CHAR) AND
              (l_krpv_rec.compounding_frequency_code is NULL OR
               l_krpv_rec.compounding_frequency_code = G_MISS_CHAR) AND
              (l_krpv_rec.calculation_formula_id is NULL OR
               l_krpv_rec.calculation_formula_id = G_MISS_NUM) AND
              (l_krpv_rec.rate_delay_code is NULL OR
               l_krpv_rec.rate_delay_code = G_MISS_CHAR) AND
              (l_krpv_rec.rate_delay_frequency is NULL OR
               l_krpv_rec.rate_delay_frequency = G_MISS_NUM) THEN
              NULL;
           ELSE
             OKC_API.set_message(p_app_name => G_APP_NAME,
                                 p_msg_name => G_REQUIRED_VALUE,
                                 p_token1 => G_COL_NAME_TOKEN,
                                 p_token1_value => 'CATCHUP FREQUENCY');
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        ELSE
          -- One of the four is not null
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Catchup :5.1');
          END IF;
          IF (l_krpv_rec.catchup_frequency_code is NOT NULL AND
              l_krpv_rec.catchup_frequency_code <> G_MISS_CHAR) THEN
            NULL;
          ELSE
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Catchup Frequency');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Catchup :6');
          END IF;
          IF (l_krpv_rec.catchup_start_date is NOT NULL AND
              l_krpv_rec.catchup_start_date <> G_MISS_DATE) THEN
            NULL;
          ELSE
            -- Default from contract start date
            l_krpv_rec.catchup_start_date := l_contract_start_date;
          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Catchup :7');
          END IF;
          IF (l_krpv_rec.catchup_settlement_code is NOT NULL AND
              l_krpv_rec.catchup_settlement_code <> G_MISS_CHAR) THEN
            NULL;
          ELSE
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Catchup Settlement');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Catchup :8');
          END IF;
          IF (l_krpv_rec.catchup_basis_code is NOT NULL AND
              l_krpv_rec.catchup_basis_code <> G_MISS_CHAR) THEN
            NULL;
          ELSE
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Catchup Basis');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


        END IF;

      END IF; -- if STREAMS and CATCHUP/CLEANUP

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling update_row() ');
        END IF;
    OKL_KRP_PVT.update_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After update_row() finished');
        END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling cascade_lease_status_update...');
        END IF;
    okl_contract_status_pub.cascade_lease_status_edit
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 p_chr_id          => l_krpv_rec.khr_id);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	       raise OKL_API.G_EXCEPTION_ERROR;
    End If;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After cascade_lease_status_update finished ...');
        END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

-- First
PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpr_rec                IN krpr_rec_type,
    x_krpr_rec                OUT NOCOPY krpr_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    x_krpv_rec krpv_rec_type;
    l_count NUMBER;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    l_krpv_rec.khr_id := p_krpr_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpr_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpr_rec.effective_from_date;
    l_krpv_rec.effective_to_date := p_krpr_rec.effective_to_date;
    l_krpv_rec.interest_index_id := p_krpr_rec.interest_index_id;
    l_krpv_rec.base_rate := p_krpr_rec.base_rate;
    l_krpv_rec.interest_start_date := p_krpr_rec.interest_start_date;
    l_krpv_rec.adder_rate := p_krpr_rec.adder_rate;
    l_krpv_rec.maximum_rate := p_krpr_rec.maximum_rate;
    l_krpv_rec.minimum_rate := p_krpr_rec.minimum_rate;
    l_krpv_rec.principal_basis_code := p_krpr_rec.principal_basis_code;
    l_krpv_rec.days_in_a_month_code := p_krpr_rec.days_in_a_month_code;
    l_krpv_rec.days_in_a_year_code := p_krpr_rec.days_in_a_year_code;
    l_krpv_rec.interest_basis_code := p_krpr_rec.interest_basis_code;

    OKL_KRP_PVT.update_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_krpr_rec.khr_id := x_krpv_rec.khr_id;
    x_krpr_rec.parameter_type_code := x_krpv_rec.parameter_type_code;
    x_krpr_rec.effective_from_date := x_krpv_rec.effective_from_date;
    x_krpr_rec.effective_to_date := x_krpv_rec.effective_to_date;
    x_krpr_rec.interest_index_id := x_krpv_rec.interest_index_id;
    x_krpr_rec.base_rate := x_krpv_rec.base_rate;
    x_krpr_rec.interest_start_date := x_krpv_rec.interest_start_date;
    x_krpr_rec.adder_rate := x_krpv_rec.adder_rate;
    x_krpr_rec.maximum_rate := x_krpv_rec.maximum_rate;
    x_krpr_rec.minimum_rate := x_krpv_rec.minimum_rate;
    x_krpr_rec.principal_basis_code := x_krpv_rec.principal_basis_code;
    x_krpr_rec.days_in_a_month_code := x_krpv_rec.days_in_a_month_code;
    x_krpr_rec.days_in_a_year_code := x_krpv_rec.days_in_a_year_code;
    x_krpr_rec.interest_basis_code := x_krpv_rec.interest_basis_code;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

-- Second
PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpar_rec               IN krpar_rec_type,
    x_krpar_rec               OUT NOCOPY krpar_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    x_krpv_rec krpv_rec_type;
    l_count NUMBER;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    l_krpv_rec.khr_id := p_krpar_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpar_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpar_rec.effective_from_date;
    l_krpv_rec.effective_to_date := p_krpar_rec.effective_to_date;
    l_krpv_rec.rate_delay_code := p_krpar_rec.rate_delay_code;
    l_krpv_rec.rate_delay_frequency := p_krpar_rec.rate_delay_frequency;
    l_krpv_rec.compounding_frequency_code := p_krpar_rec.compounding_frequency_code;
    l_krpv_rec.calculation_formula_id := p_krpar_rec.calculation_formula_id;
    l_krpv_rec.catchup_basis_code := p_krpar_rec.catchup_basis_code;
    l_krpv_rec.catchup_start_date := p_krpar_rec.catchup_start_date;
    l_krpv_rec.catchup_settlement_code := p_krpar_rec.catchup_settlement_code;
    l_krpv_rec.rate_change_start_date := p_krpar_rec.rate_change_start_date;
    l_krpv_rec.rate_change_frequency_code := p_krpar_rec.rate_change_frequency_code;
    l_krpv_rec.rate_change_value := p_krpar_rec.rate_change_value;

    OKL_KRP_PVT.update_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_krpar_rec.khr_id := x_krpv_rec.khr_id;
    x_krpar_rec.parameter_type_code := x_krpv_rec.parameter_type_code;
    x_krpar_rec.effective_from_date := x_krpv_rec.effective_from_date;
    x_krpar_rec.effective_to_date := x_krpv_rec.effective_to_date;
    x_krpar_rec.rate_delay_code := x_krpv_rec.rate_delay_code;
    x_krpar_rec.rate_delay_frequency := x_krpv_rec.rate_delay_frequency;
    x_krpar_rec.compounding_frequency_code := x_krpv_rec.compounding_frequency_code;
    x_krpar_rec.calculation_formula_id := x_krpv_rec.calculation_formula_id;
    x_krpar_rec.catchup_basis_code := x_krpv_rec.catchup_basis_code;
    x_krpar_rec.catchup_start_date := x_krpv_rec.catchup_start_date;
    x_krpar_rec.catchup_settlement_code := x_krpv_rec.catchup_settlement_code;
    x_krpar_rec.rate_change_start_date := x_krpv_rec.rate_change_start_date;
    x_krpar_rec.rate_change_frequency_code := x_krpv_rec.rate_change_frequency_code;
    x_krpar_rec.rate_change_value := x_krpv_rec.rate_change_value;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

-- Third
PROCEDURE update_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpc_rec                IN krpc_rec_type,
    x_krpc_rec                OUT NOCOPY krpc_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    x_krpv_rec krpv_rec_type;
    l_count NUMBER;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    l_krpv_rec.khr_id := p_krpc_rec.khr_id;
    l_krpv_rec.parameter_type_code := p_krpc_rec.parameter_type_code;
    l_krpv_rec.effective_from_date := p_krpc_rec.effective_from_date;
    l_krpv_rec.effective_to_date := p_krpc_rec.effective_to_date;
    l_krpv_rec.conversion_option_code := p_krpc_rec.conversion_option_code;
    l_krpv_rec.next_conversion_date := p_krpc_rec.next_conversion_date;
    l_krpv_rec.conversion_type_code := p_krpc_rec.conversion_type_code;

    OKL_KRP_PVT.update_row(
       p_api_version,
       p_init_msg_list,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_krpv_rec,
       x_krpv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_krpc_rec.khr_id := x_krpv_rec.khr_id;
    x_krpc_rec.parameter_type_code := x_krpv_rec.parameter_type_code;
    x_krpc_rec.effective_from_date := x_krpv_rec.effective_from_date;
    x_krpc_rec.effective_to_date := x_krpv_rec.effective_to_date;
    x_krpc_rec.conversion_option_code := x_krpv_rec.conversion_option_code;
    x_krpc_rec.next_conversion_date := x_krpv_rec.next_conversion_date;
    x_krpc_rec.conversion_type_code := x_krpv_rec.conversion_type_code;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

PROCEDURE delete_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_krpdel_tbl              IN krpdel_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_krpv_rec krpv_rec_type;
    l_krpv_rec2 krpv_rec_type;
    l_krpv_rec3 krpv_rec_type;

    CURSOR get_effective_to_date_csr(
              p_khr_id NUMBER,
              p_parameter_type_code VARCHAR2,
              p_effective_from_date DATE) IS
    select rate.effective_to_date,
           contract.sts_code,
           contract.orig_system_source_code,
           contract.orig_system_id1
    FROM   OKL_K_RATE_PARAMS rate,
           OKC_K_HEADERS_B contract
    WHERE  rate.khr_id = p_khr_id
    AND    rate.parameter_type_code =  p_parameter_type_code
    AND    rate.effective_from_date = p_effective_from_date
    AND    rate.khr_id = contract.id;

    CURSOR get_orig_effective_from_dt_csr(
              p_khr_id NUMBER,
              p_parameter_type_code VARCHAR2) IS
    select rate.effective_from_date
    FROM   OKL_K_RATE_PARAMS rate
    WHERE  rate.khr_id = p_khr_id
    AND    rate.parameter_type_code =  p_parameter_type_code
    AND    rate.effective_to_date IS NULL;

    l_all_rate_params_null BOOLEAN;
    l_parameter_type_code VARCHAR2(30);
    l_effective_to_date DATE;
    l_sts_code OKC_K_HEADERS_B.STS_CODE%TYPE;
    l_orig_system_source_code OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE;
    l_orig_system_id1 OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE;
    l_orig_effective_from_date DATE;
    l_del_count NUMBER := 0; -- Bug 4874280
    l_khr_id NUMBER;
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In delete_k_rate_params...');
    END IF;
    IF (p_krpdel_tbl.COUNT > 0) THEN
    FOR i in p_krpdel_tbl.FIRST..p_krpdel_tbl.LAST
    LOOP
      -- AKP: todo (change actual lookup values)
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Delete:rate_type=' || p_krpdel_tbl(i).rate_type);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Delete:khr_id=' || p_krpdel_tbl(i).khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Delete:effective_from_date=' || p_krpdel_tbl(i).effective_from_date);
      END IF;
      l_khr_id := p_krpdel_tbl(i).khr_id;
      --Bug# 7440232
      IF (p_krpdel_tbl(i).rate_type IN ('INTEREST_RATE_PARAMS', 'CONVERSION_BASIS')) THEN
        l_parameter_type_code := 'ACTUAL';
      --Bug# 7440232
      ELSIF (p_krpdel_tbl(i).rate_type IN ('INTEREST_RATE_PARAMS_CONV')) THEN
        l_parameter_type_code := 'CONVERSION';
      ELSE
        OKC_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_LLA_VAR_RATE_INV_PARAM');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      FOR r IN get_effective_to_date_csr(
                      p_krpdel_tbl(i).khr_id,
                      l_parameter_type_code,
                      p_krpdel_tbl(i).effective_from_date)
      LOOP
        l_effective_to_date := r.effective_to_date;
        l_sts_code := r.sts_code;
        l_orig_system_source_code := r.orig_system_source_code;
        l_orig_system_id1 := r.orig_system_id1;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_system_source_code=' || l_orig_system_source_code);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_system_id1=' || l_orig_system_id1);
      END IF;
      IF (l_effective_to_date IS NOT NULL) THEN
        OKC_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_LLA_VAR_RATE_DELETE_ERR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 7440232
      IF (l_sts_code = 'BOOKED') THEN
        OKC_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_LLA_VAR_RATE_DELETE_ERR1');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_orig_system_source_code = 'OKL_REBOOK') THEN

          FOR r IN get_orig_effective_from_dt_csr(
                        --p_krpdel_tbl(i).khr_id,
                        l_orig_system_id1,
                        l_parameter_type_code)
          LOOP
            l_orig_effective_from_date := r.effective_from_date;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_effective_from_date=' || l_orig_effective_from_date);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'krpdel.effective_from_date=' || p_krpdel_tbl(i).effective_from_date);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'krpdel.khr_id=' || p_krpdel_tbl(i).khr_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_parameter_type_code=' || l_parameter_type_code);
            END IF;
          END LOOP;

          --Bug# 7440232
          IF (l_orig_effective_from_date =
                  p_krpdel_tbl(i).effective_from_date) THEN
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_LLA_VAR_RATE_DELETE_ERR2');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          /*UPDATE OKL_K_RATE_PARAMS
          SET    EFFECTIVE_TO_DATE = NULL
          WHERE  KHR_ID = p_krpdel_tbl(i).khr_id
          AND    PARAMETER_TYPE_CODE = l_parameter_type_code
          AND    EFFECTIVE_TO_DATE = p_krpdel_tbl(i).effective_from_date - 1;*/
      END IF;

    SELECT KHR_ID, PARAMETER_TYPE_CODE, EFFECTIVE_FROM_DATE,
      EFFECTIVE_TO_DATE, INTEREST_INDEX_ID, BASE_RATE,
      INTEREST_START_DATE, ADDER_RATE, MAXIMUM_RATE,
      MINIMUM_RATE, PRINCIPAL_BASIS_CODE, DAYS_IN_A_MONTH_CODE,
      DAYS_IN_A_YEAR_CODE, INTEREST_BASIS_CODE, RATE_DELAY_CODE,
      RATE_DELAY_FREQUENCY, COMPOUNDING_FREQUENCY_CODE, CALCULATION_FORMULA_ID,
      CATCHUP_BASIS_CODE, CATCHUP_START_DATE, CATCHUP_SETTLEMENT_CODE,
      RATE_CHANGE_START_DATE, RATE_CHANGE_FREQUENCY_CODE, RATE_CHANGE_VALUE,
      CONVERSION_OPTION_CODE, NEXT_CONVERSION_DATE, CONVERSION_TYPE_CODE,
      ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
      ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
      ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
      ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
      ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
      ATTRIBUTE15, created_by, creation_date,
      last_updated_by, last_update_date, last_update_login,
      CATCHUP_FREQUENCY_CODE
    INTO
      l_krpv_rec.KHR_ID, l_krpv_rec.parameter_type_code, l_krpv_rec.effective_from_date,
      l_krpv_rec.EFFECTIVE_TO_DATE, l_krpv_rec.INTEREST_INDEX_ID, l_krpv_rec.BASE_RATE,
      l_krpv_rec.INTEREST_START_DATE, l_krpv_rec.ADDER_RATE, l_krpv_rec.MAXIMUM_RATE,
      l_krpv_rec.MINIMUM_RATE, l_krpv_rec.PRINCIPAL_BASIS_CODE, l_krpv_rec.DAYS_IN_A_MONTH_CODE,
      l_krpv_rec.DAYS_IN_A_YEAR_CODE, l_krpv_rec.INTEREST_BASIS_CODE, l_krpv_rec.RATE_DELAY_CODE,
      l_krpv_rec.RATE_DELAY_FREQUENCY, l_krpv_rec.COMPOUNDING_FREQUENCY_CODE, l_krpv_rec.CALCULATION_FORMULA_ID,
      l_krpv_rec.CATCHUP_BASIS_CODE, l_krpv_rec.CATCHUP_START_DATE, l_krpv_rec.CATCHUP_SETTLEMENT_CODE,
      l_krpv_rec.RATE_CHANGE_START_DATE, l_krpv_rec.RATE_CHANGE_FREQUENCY_CODE, l_krpv_rec.RATE_CHANGE_VALUE,
      l_krpv_rec.CONVERSION_OPTION_CODE, l_krpv_rec.NEXT_CONVERSION_DATE, l_krpv_rec.CONVERSION_TYPE_CODE,
      l_krpv_rec.ATTRIBUTE_CATEGORY, l_krpv_rec.ATTRIBUTE1, l_krpv_rec.ATTRIBUTE2,
      l_krpv_rec.ATTRIBUTE3, l_krpv_rec.ATTRIBUTE4, l_krpv_rec.ATTRIBUTE5,
      l_krpv_rec.ATTRIBUTE6, l_krpv_rec.ATTRIBUTE7, l_krpv_rec.ATTRIBUTE8,
      l_krpv_rec.ATTRIBUTE9, l_krpv_rec.ATTRIBUTE10, l_krpv_rec.ATTRIBUTE11,
      l_krpv_rec.ATTRIBUTE12, l_krpv_rec.ATTRIBUTE13, l_krpv_rec.ATTRIBUTE14,
      l_krpv_rec.ATTRIBUTE15, l_krpv_rec.CREATED_BY, l_krpv_rec.CREATION_DATE,
      l_krpv_rec.LAST_UPDATED_BY, l_krpv_rec.LAST_UPDATE_DATE, l_krpv_rec.LAST_UPDATE_LOGIN,
      l_krpv_rec.CATCHUP_FREQUENCY_CODE
      FROM OKL_K_RATE_PARAMS
      WHERE KHR_ID = p_krpdel_tbl(i).khr_id
      AND   parameter_type_code = l_parameter_type_code
      AND   effective_from_date = p_krpdel_tbl(i).effective_from_date;

      --Bug# 7440232
      IF (p_krpdel_tbl(i).rate_type IN ('INTEREST_RATE_PARAMS', 'INTEREST_RATE_PARAMS_CONV')) THEN
        l_krpv_rec.interest_index_id := null;
        l_krpv_rec.base_rate := null;
        l_krpv_rec.adder_rate := null;
        l_krpv_rec.minimum_rate := null;
        l_krpv_rec.maximum_rate := null;
        l_krpv_rec.principal_basis_code := null;
        l_krpv_rec.interest_basis_code := null;
        l_krpv_rec.interest_start_date := null;
        l_krpv_rec.days_in_a_month_code := null;
        l_krpv_rec.days_in_a_year_code := null;

        l_krpv_rec.rate_delay_code := null;
        l_krpv_rec.rate_delay_frequency := null;
        l_krpv_rec.compounding_frequency_code := null;
        l_krpv_rec.calculation_formula_id := null;
        l_krpv_rec.catchup_frequency_code := null;
        l_krpv_rec.catchup_start_date := null;
        l_krpv_rec.catchup_settlement_code := null;
        l_krpv_rec.catchup_basis_code := null;
        l_krpv_rec.rate_change_frequency_code := null;
        l_krpv_rec.rate_change_start_date := null;
        l_krpv_rec.rate_change_value := null;

        UPDATE OKL_K_RATE_PARAMS
        SET interest_index_id = null,
            base_rate = null,
            adder_rate = null,
            minimum_rate = null,
            maximum_rate = null,
            principal_basis_code = null,
            interest_basis_code = null,
            interest_start_date = null,
            days_in_a_month_code = null,
            days_in_a_year_code = null,
            rate_delay_code = null,
            rate_delay_frequency = null,
            compounding_frequency_code = null,
            calculation_formula_id = null,
            catchup_frequency_code = null,
            catchup_start_date = null,
            catchup_settlement_code = null,
            catchup_basis_code = null,
            rate_change_frequency_code = null,
            rate_change_start_date = null,
            rate_change_value = null
         WHERE KHR_ID = p_krpdel_tbl(i).khr_id
         AND   parameter_type_code = l_parameter_type_code
         AND   effective_from_date = p_krpdel_tbl(i).effective_from_date;
         l_del_count := l_del_count + sql%rowcount;

      ELSIF (p_krpdel_tbl(i).rate_type = 'CONVERSION_BASIS') THEN
        l_krpv_rec.conversion_option_code := null;
        l_krpv_rec.next_conversion_date := null;
        l_krpv_rec.conversion_type_code := null;

        UPDATE OKL_K_RATE_PARAMS
        SET    conversion_option_code = null,
               next_conversion_date = null,
               conversion_type_code = null
         WHERE KHR_ID = p_krpdel_tbl(i).khr_id
         AND   parameter_type_code = l_parameter_type_code
         AND   effective_from_date = p_krpdel_tbl(i).effective_from_date;
         l_del_count := l_del_count + sql%rowcount;
      END IF;

      -- Check if all null
      l_all_rate_params_null := FALSE;
      IF (l_krpv_rec.interest_index_id IS NULL AND
          l_krpv_rec.base_rate IS NULL AND
          l_krpv_rec.adder_rate IS NULL AND
          l_krpv_rec.minimum_rate IS NULL AND
          l_krpv_rec.maximum_rate IS NULL AND
          l_krpv_rec.principal_basis_code IS NULL AND
          l_krpv_rec.interest_basis_code IS NULL AND
          l_krpv_rec.interest_start_date IS NULL AND
          l_krpv_rec.days_in_a_month_code IS NULL AND
          l_krpv_rec.days_in_a_year_code IS NULL AND
          l_krpv_rec.rate_delay_code IS NULL AND
          l_krpv_rec.rate_delay_frequency IS NULL AND
          l_krpv_rec.compounding_frequency_code IS NULL AND
          l_krpv_rec.calculation_formula_id IS NULL AND
          l_krpv_rec.catchup_frequency_code IS NULL AND
          l_krpv_rec.catchup_start_date IS NULL AND
          l_krpv_rec.catchup_settlement_code IS NULL AND
          l_krpv_rec.catchup_basis_code IS NULL AND
          l_krpv_rec.rate_change_frequency_code IS NULL AND
          l_krpv_rec.rate_change_start_date IS NULL AND
          l_krpv_rec.rate_change_value IS NULL AND
          l_krpv_rec.conversion_option_code IS NULL AND
          l_krpv_rec.next_conversion_date IS NULL AND
          l_krpv_rec.conversion_type_code IS NULL) THEN

         l_all_rate_params_null := TRUE;

       END IF;

      IF (l_all_rate_params_null) THEN
        l_krpv_rec2.khr_id := p_krpdel_tbl(i).khr_id;
        l_krpv_rec2.parameter_type_code := l_parameter_type_code;
        l_krpv_rec2.effective_from_date := p_krpdel_tbl(i).effective_from_date;

        OKL_KRP_PVT.delete_row(
           p_api_version,
           p_init_msg_list,
           x_return_status,
           x_msg_count,
           x_msg_data,
           l_krpv_rec2);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (l_orig_system_source_code = 'OKL_REBOOK') THEN

          /*FOR r IN get_orig_effective_from_dt_csr(
                        p_krpdel_tbl(i).khr_id,
                        l_parameter_type_code)
          LOOP
            l_orig_effective_from_date := r.effective_from_date;
            print('l_orig_effective_from_date=' || l_orig_effective_from_date);
            print('krpdel.effective_from_date=' || p_krpdel_tbl(i).effective_from_date);
            print('krpdel.khr_id=' || p_krpdel_tbl(i).khr_id);
            print('l_parameter_type_code=' || l_parameter_type_code);
          END LOOP;

          IF (l_orig_effective_from_date =
                  p_krpdel_tbl(i).effective_from_date) THEN
            OKC_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_LA_VAR_RATE_DELETE_ERR2');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;*/

          UPDATE OKL_K_RATE_PARAMS
          SET    EFFECTIVE_TO_DATE = NULL
          WHERE  KHR_ID = p_krpdel_tbl(i).khr_id
          AND    PARAMETER_TYPE_CODE = l_parameter_type_code
          AND    EFFECTIVE_TO_DATE = p_krpdel_tbl(i).effective_from_date - 1;
          l_del_count := l_del_count + sql%rowcount;
        END IF;

      END IF;
      l_krpv_rec := l_krpv_rec3;
      l_krpv_rec2 := l_krpv_rec3;

    END LOOP;
    END IF;

      -- Bug 4874280
      IF (l_del_count > 0) THEN
        okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_chr_id          => l_khr_id);

        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
  	         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
  	         raise OKL_API.G_EXCEPTION_ERROR;
        End If;
      END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

/* For QA checker to call  - stack Error messages and no raise exception*/
PROCEDURE validate_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_khr_id                  IN  okc_k_headers_b.id%type,
    p_validate_flag           IN  VARCHAR2 DEFAULT 'Y') IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_K_RATE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1.0;

    p_pdtv_rec            OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    x_pdt_parameter_rec   OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    x_no_data_found       BOOLEAN;
    l_k_rate_tbl          krpv_tbl_type;
    l_k_rate_tbl2         krpv_tbl_type;
    l_rate_counter        NUMBER := 1;

    CURSOR l_hdr_csr(  chrId NUMBER ) IS
    SELECT
	   CHR.authoring_org_id,
	   CHR.inv_organization_id,
           khr.deal_type,
           pdt.id  pid,
	   NVL(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_b CHR,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = CHR.id
        AND CHR.id = chrId
        AND khr.pdt_id = pdt.id(+);

    l_hdr_rec l_hdr_csr%ROWTYPE;

    CURSOR csr_get_rate_tbl(p_id NUMBER) IS
    SELECT
     khr_id
    ,parameter_type_code
    ,effective_from_date
    ,effective_to_date
    ,interest_index_id
    ,base_rate
    ,interest_start_date
    ,adder_rate
    ,maximum_rate
    ,minimum_rate
    ,principal_basis_code
    ,days_in_a_month_code
    ,days_in_a_year_code
    ,interest_basis_code
    ,rate_delay_code
    ,rate_delay_frequency
    ,compounding_frequency_code
    ,calculation_formula_id
    ,catchup_basis_code
    ,catchup_start_date
    ,catchup_settlement_code
    ,rate_change_start_date
    ,rate_change_frequency_code
    ,rate_change_value
    ,conversion_option_code
    ,next_conversion_date
    ,conversion_type_code
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,catchup_frequency_code
    FROM okl_k_rate_params
    WHERE khr_id = p_id;

l_deal_type VARCHAR2(30);
l_interest_calculation_basis VARCHAR2(30);
l_revenue_recognition_method VARCHAR2(30);
begin
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In validate_k_rate_params QA checker' || to_char(sysdate,'HH24:MI:SS') || ' with p_khr_id= ' || p_khr_id || ' ...');
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN  l_hdr_csr(p_khr_id);
    FETCH l_hdr_csr INTO l_hdr_rec;
    IF l_hdr_csr%NOTFOUND THEN
        CLOSE l_hdr_csr;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_hdr_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'deal_type=' || l_hdr_rec.deal_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pid=' || l_hdr_rec.pid);
    END IF;

    p_pdtv_rec.id := l_hdr_rec.pid;
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_pdtv_rec          => p_pdtv_rec,
	                x_no_data_found     => x_no_data_found,
                        p_pdt_parameter_rec => x_pdt_parameter_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF  NVL(x_pdt_parameter_rec.Name,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --print('Product_subclass=' || x_pdt_parameter_rec.product_subclass);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Deal_type=' || x_pdt_parameter_rec.Deal_type);
    END IF;
    --print('Tax_owner=' || x_pdt_parameter_rec.Tax_owner);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Revenue_Recognition_Method=' || x_pdt_parameter_rec.Revenue_Recognition_Method);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Interest_Calculation_Basis=' || x_pdt_parameter_rec.Interest_Calculation_Basis);
    END IF;
    l_deal_type := x_pdt_parameter_rec.deal_type;
    l_interest_calculation_basis := x_pdt_parameter_rec.interest_calculation_basis;
    l_revenue_recognition_method := x_pdt_parameter_rec.revenue_recognition_method;

    -- AKP: Todo: Get l_k_rate_tbl from database
    Open csr_get_rate_tbl(p_khr_id);
    LOOP
      Fetch csr_get_rate_tbl BULK COLLECT INTO l_k_rate_tbl2 LIMIT G_BULK_SIZE;
      EXIT WHEN l_k_rate_tbl2.COUNT = 0;
      FOR i IN l_k_rate_tbl2.FIRST..l_k_rate_tbl2.LAST
      LOOP
        l_k_rate_tbl(l_rate_counter) := l_k_rate_tbl2(i);
        l_rate_counter := l_rate_counter + 1;
      END LOOP;
    END LOOP;
    CLOSE csr_get_rate_tbl;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After csr_get_rate_tbl...');
    END IF;
    /* IF (((l_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST')) AND
         (l_interest_calculation_basis IN ('FIXED', 'REAMORT'))) OR
        ((l_deal_type = 'LOAN') AND
         (l_interest_calculation_basis = 'REAMORT')) ) THEN
        IF (l_k_rate_tbl.COUNT > 0) THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_VAR_RATE_ERROR
                              ,p_token1       => G_LEASE_TYPE
                              ,p_token1_value => 'LEASEOP,LEASEDF,LEASEST'
                              ,p_token2       => G_INT_BASIS
                              ,p_token2_value => 'FIXED,REAMORT');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    ELS */
    IF (((l_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST')) AND
           (l_interest_calculation_basis IN ( 'FLOAT_FACTORS', 'REAMORT'))) OR
          --((l_deal_type = 'LOAN') AND
           --(l_interest_calculation_basis IN
                    --('FIXED','FLOAT', 'CATCHUP/CLEANUP')))  OR
           (l_deal_type = 'LOAN' AND
             (l_interest_calculation_basis IN
                  ('FLOAT', 'REAMORT', 'CATCHUP/CLEANUP')
              OR
              (l_interest_calculation_basis='FIXED' AND
               l_revenue_recognition_method = 'ACTUAL')  )) OR
          ((l_deal_type = 'LOAN-REVOLVING') AND
           (l_interest_calculation_basis = 'FLOAT')) ) THEN
      IF (l_k_rate_tbl.COUNT < 1) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_OKL_LLA_VAR_RATE_MISSING
                            ,p_token1       => G_CONT_ID
                            ,p_token1_value => p_khr_id);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF (l_k_rate_tbl.COUNT > 0) THEN
    okl_krp_pvt.validate_row(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_deal_type         => x_pdt_parameter_rec.deal_type,
        p_rev_rec_method    => x_pdt_parameter_rec.Revenue_recognition_method,
        p_int_calc_basis    => x_pdt_parameter_rec.interest_calculation_basis,
        p_krpv_tbl          => l_k_rate_tbl,
        p_stack_messages    => 'Y',
        p_validate_flag     => 'F'
    );
    END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validation_row: x_return_status=' || x_return_status);
  END IF;

  -- Bug 4722746
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_k_rate_tbl.COUNT=' || l_k_rate_tbl.COUNT);
      END IF;
      IF (l_interest_calculation_basis = 'CATCHUP/CLEANUP'
          AND l_revenue_recognition_method = 'STREAMS'
          AND l_k_rate_tbl.COUNT > 0 ) THEN

        FOR i IN l_k_rate_tbl.FIRST..l_k_rate_tbl.LAST
        LOOP
        --print('Catchup :1');
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i=' || i || ':' || l_k_rate_tbl(i).catchup_frequency_code);
        END IF;
        IF (l_k_rate_tbl(i).catchup_frequency_code is NOT NULL AND
            l_k_rate_tbl(i).catchup_frequency_code <> G_MISS_CHAR) THEN
          NULL;
        ELSE
          OKC_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Catchup Frequency');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --print('Catchup :2');
        /*IF (l_k_rate_tbl(i).catchup_start_date is NOT NULL AND
            l_k_rate_tbl(i).catchup_start_date <> G_MISS_DATE) THEN
          NULL;
        ELSE
          l_k_rate_tbl(i).catchup_start_date := l_contract_start_date;
        END IF;*/

        --print('Catchup :3');
        IF (l_k_rate_tbl(i).catchup_settlement_code is NOT NULL AND
            l_k_rate_tbl(i).catchup_settlement_code <> G_MISS_CHAR) THEN
          NULL;
        ELSE
          OKC_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Catchup Settlement');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --print('Catchup :4');
        IF (l_k_rate_tbl(i).catchup_basis_code is NOT NULL AND
            l_k_rate_tbl(i).catchup_basis_code <> G_MISS_CHAR) THEN
          NULL;
        ELSE
          OKC_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Catchup Basis');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        END LOOP;

      END IF;


  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
end;

/* For UI/contract import to call */
PROCEDURE validate_k_rate_params(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_product_id              IN  okl_products_v.id%type,
    p_k_rate_tbl              IN  krpv_tbl_type,
    --Bug# 7440232
    p_validate_flag           IN  VARCHAR2 DEFAULT 'Y') IS

    p_pdtv_rec            OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    x_pdt_parameter_rec   OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    x_no_data_found       BOOLEAN;

    l_pdt_id number;
begin

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In validate_k_rate_params from UI/contract import...');
   END IF;
   /*begin
     select id into l_pdt_id
     from okl_products_v
     where name = p_product_name;
   exception when no_data_found then
     null;
     -- ToDo AKP: Set Message : Product not found. Raise error.
   end; */
    p_pdtv_rec.id := p_product_id;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_product_id=' || to_char(p_product_id));
    END IF;
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_pdtv_rec          => p_pdtv_rec,
	                x_no_data_found     => x_no_data_found,
                        p_pdt_parameter_rec => x_pdt_parameter_rec);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_return_status=' || x_return_status);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'name=' || x_pdt_parameter_rec.name);
   END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    /*ELSIF  NVL(x_pdt_parameter_rec.Name,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;*/
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Deal_type=' || x_pdt_parameter_rec.Deal_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Revenue_Recognition_Method=' || x_pdt_parameter_rec.Revenue_Recognition_Method);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Interest_Calculation_Basis=' || x_pdt_parameter_rec.Interest_Calculation_Basis);
    END IF;

    okl_krp_pvt.validate_row(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_deal_type         => x_pdt_parameter_rec.deal_type,
        p_rev_rec_method    => x_pdt_parameter_rec.Revenue_recognition_method,
        p_int_calc_basis    => x_pdt_parameter_rec.interest_calculation_basis,
        p_krpv_tbl          => p_k_rate_tbl,
        --Bug# 7440232
        p_stack_messages    => 'Y',
        p_validate_flag     => p_validate_flag
    );
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_row: x_return_status=' || x_return_status);
   END IF;
end;

-- Start of comments
--
-- Procedure Name  : generate_rate_summary
-- Description     : Called through rosetta to generate summary of interest and additional interest
--                   rate parameters for actual and conversion records with
--                   different effectivities.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0, ramurt Created.
-- End of comments

  Procedure generate_rate_summary(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  NUMBER,
            x_var_par_tbl          OUT NOCOPY var_prm_tbl_type)
  AS
  l_api_version    CONSTANT NUMBER := 1;
  l_api_name       CONSTANT VARCHAR2(30) := 'GENERATE_RATE_SUMMARY';
  l_return_value   VARCHAR2(1) := '';

CURSOR c_int_rate_param IS
SELECT parameter_type_code,
       interest_index_id,
       base_rate,
       interest_start_date,
       adder_rate,
       maximum_rate,
       minimum_rate,
       principal_basis_code,
       days_in_a_month_code,
       days_in_a_year_code,
       interest_basis_code,
       effective_from_date,
       effective_to_date,
       rate_delay_code,
       rate_delay_frequency,
       compounding_frequency_code,
       calculation_formula_id,
       catchup_basis_code,
       catchup_start_date,
       catchup_settlement_code,
       rate_change_start_date,
       rate_change_frequency_code,
       rate_change_value,
       conversion_option_code,
       next_conversion_date,
       conversion_type_code
FROM   OKL_K_RATE_PARAMS
WHERE  KHR_ID = p_chr_id
AND    parameter_type_code IN ('ACTUAL', 'CONVERSION')
ORDER BY effective_from_date, parameter_type_code;

CURSOR fnd_csr(p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE) IS
SELECT meaning
FROM   FND_LOOKUPS
WHERE  lookup_type = 'OKL_VAR_RATE_PARAMS_TYPE'
AND    lookup_code = p_lookup_code
AND    nvl(enabled_flag,'N') = 'Y'
AND    sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate);
l_meaning FND_LOOKUPS.MEANING%TYPE;

  i NUMBER;
  l_int_rate_exist BOOLEAN;
  l_addl_int_rate_exist BOOLEAN;
  l_conv_basis_exist BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => G_API_TYPE,
                        x_return_status => x_return_status);

  --dbms_output.put_line('here1');

  i := 0;

  FOR c_int_rate_param_rec IN c_int_rate_param
  LOOP
    l_int_rate_exist := c_int_rate_param_rec.interest_index_id       IS NOT NULL
                        OR c_int_rate_param_rec.base_rate            IS NOT NULL
                        OR c_int_rate_param_rec.interest_start_date  IS NOT NULL
                        OR c_int_rate_param_rec.adder_rate           IS NOT NULL
                        OR c_int_rate_param_rec.maximum_rate         IS NOT NULL
                        OR c_int_rate_param_rec.minimum_rate         IS NOT NULL
                        OR c_int_rate_param_rec.principal_basis_code IS NOT NULL
                        OR c_int_rate_param_rec.days_in_a_month_code IS NOT NULL
                        OR c_int_rate_param_rec.days_in_a_year_code  IS NOT NULL
                        OR c_int_rate_param_rec.interest_basis_code  IS NOT NULL;

    l_addl_int_rate_exist := c_int_rate_param_rec.rate_delay_code               IS NOT NULL
                             OR c_int_rate_param_rec.rate_delay_frequency       IS NOT NULL
                             OR c_int_rate_param_rec.compounding_frequency_code IS NOT NULL
                             OR c_int_rate_param_rec.calculation_formula_id     IS NOT NULL
                             OR c_int_rate_param_rec.catchup_basis_code         IS NOT NULL
                             OR c_int_rate_param_rec.catchup_start_date         IS NOT NULL
                             OR c_int_rate_param_rec.catchup_settlement_code    IS NOT NULL
                             OR c_int_rate_param_rec.rate_change_start_date     IS NOT NULL
                             OR c_int_rate_param_rec.rate_change_frequency_code IS NOT NULL
                             OR c_int_rate_param_rec.rate_change_value          IS NOT NULL;

    l_conv_basis_exist := c_int_rate_param_rec.conversion_option_code   IS NOT NULL
                          OR c_int_rate_param_rec.next_conversion_date  IS NOT NULL
                          OR c_int_rate_param_rec.conversion_type_code  IS NOT NULL;

    -- Interest Rate Parameters and Additional Interest Rate Parameters.
    IF ( c_int_rate_param_rec.parameter_type_code = 'ACTUAL') THEN
      --Bug# 7440232
      IF( l_int_rate_exist ) OR ( l_addl_int_rate_exist ) THEN
        i := i+1;
        OPEN fnd_csr('INTEREST_RATE_PARAMS');
        FETCH fnd_csr INTO l_meaning;
        CLOSE fnd_csr;
        x_var_par_tbl(i).param_identifier_meaning := l_meaning;
        x_var_par_tbl(i).param_identifier := 'INTEREST_RATE_PARAMS';
        x_var_par_tbl(i).effective_from_date := c_int_rate_param_rec.effective_from_date;
        x_var_par_tbl(i).effective_to_date := c_int_rate_param_rec.effective_to_date;
        -- gboomina modified for Bug 5876083 - Start
        -- Returning Parameter Type Code which is used in the UI
        x_var_par_tbl(i).parameter_type_code := c_int_rate_param_rec.parameter_type_code;
        -- gboomina modified for Bug 5876083 - End
      END IF;

      IF( l_conv_basis_exist ) THEN
        i := i+1;
        OPEN fnd_csr('CONVERSION_BASIS');
        FETCH fnd_csr INTO l_meaning;
        CLOSE fnd_csr;
        x_var_par_tbl(i).param_identifier_meaning := l_meaning;
        x_var_par_tbl(i).param_identifier := 'CONVERSION_BASIS';
        x_var_par_tbl(i).effective_from_date := c_int_rate_param_rec.effective_from_date;
        x_var_par_tbl(i).effective_to_date := c_int_rate_param_rec.effective_to_date;
        -- gboomina modified for Bug 5876083 - Start
        -- Returning Parameter Type Code which is used in the UI
        x_var_par_tbl(i).parameter_type_code := c_int_rate_param_rec.parameter_type_code;
        -- gboomina modified for Bug 5876083 - End
      END IF;
    END IF;
    -- Interest Rate Parameters and Additional Interest Rate Parameters for Conversion
    -- and parameters for Conversion Basis.
    IF ( c_int_rate_param_rec.parameter_type_code = 'CONVERSION') THEN
      --Bug# 7440232
      IF( l_int_rate_exist ) OR ( l_addl_int_rate_exist ) THEN
        i := i+1;
        OPEN fnd_csr('INTEREST_RATE_PARAMS_CONV');
        FETCH fnd_csr INTO l_meaning;
        CLOSE fnd_csr;
        x_var_par_tbl(i).param_identifier_meaning := l_meaning;
        x_var_par_tbl(i).param_identifier := 'INTEREST_RATE_PARAMS_CONV';
        x_var_par_tbl(i).effective_from_date := c_int_rate_param_rec.effective_from_date;
        x_var_par_tbl(i).effective_to_date := c_int_rate_param_rec.effective_to_date;
        -- gboomina modified for Bug 5876083 - Start
        -- Returning Parameter Type Code which is used in the UI
        x_var_par_tbl(i).parameter_type_code := c_int_rate_param_rec.parameter_type_code;
        -- gboomina modified for Bug 5876083 - End
      END IF;

    END IF;
  END LOOP;

--dbms_output.put_line('here4');
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Close all cursors if open
      IF c_int_rate_param%ISOPEN THEN
        CLOSE c_int_rate_param;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Close all cursors if open
      IF c_int_rate_param%ISOPEN THEN
        CLOSE c_int_rate_param;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

    WHEN OTHERS THEN
      --Close all cursors if open
      IF c_int_rate_param%ISOPEN THEN
        CLOSE c_int_rate_param;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END generate_rate_summary;

-- default_k_rate_params
-- Default the values based on business rules

PROCEDURE default_k_rate_params(
    p_api_version      IN NUMBER,
    p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_deal_type        IN  okl_product_parameters_v.deal_type%type,
    p_rev_rec_method   IN  okl_product_parameters_v.revenue_recognition_method%type,
    p_int_calc_basis   IN  okl_product_parameters_v.interest_calculation_basis%type,
    p_column_name      IN  VARCHAR2,
    p_krpv_rec         IN OUT NOCOPY krpv_rec_type) IS
BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  IF (p_column_name = 'PRINCIPAL_BASIS_CODE' OR p_column_name = 'ALL') THEN
    IF (p_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
       (p_int_calc_basis = 'REAMORT' AND p_rev_rec_method = 'STREAMS')) THEN
      p_krpv_rec.PRINCIPAL_BASIS_CODE := 'SCHEDULED';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'FLOAT' AND p_rev_rec_method = 'ACTUAL') THEN
      p_krpv_rec.PRINCIPAL_BASIS_CODE := 'ACTUAL';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'REAMORT' AND
           p_rev_rec_method IN ('STREAMS', 'ACTUAL')) THEN
      p_krpv_rec.PRINCIPAL_BASIS_CODE := 'SCHEDULED';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'CATCHUP/CLEANUP' AND
           p_rev_rec_method = 'STREAMS' ) THEN
      p_krpv_rec.PRINCIPAL_BASIS_CODE := 'ACTUAL';
    ELSIF (p_deal_type = 'LOAN-REVOLVING' AND
           p_int_calc_basis = 'FLOAT' AND
           p_rev_rec_method IN ( 'ESTIMATED_AND_BILLED', 'ACTUAL' )) THEN
      p_krpv_rec.PRINCIPAL_BASIS_CODE := 'ACTUAL';
    END IF;

    IF (p_column_name = 'PRINCIPAL_BASIS_CODE') THEN
      RETURN;
    END IF;
  END IF;

  IF (p_column_name = 'DAYS_IN_A_MONTH_CODE' OR p_column_name = 'ALL') THEN
    IF (p_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
       (p_int_calc_basis = 'REAMORT' AND p_rev_rec_method = 'STREAMS')) THEN
      p_krpv_rec.DAYS_IN_A_MONTH_CODE := '30';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'REAMORT' AND
           p_rev_rec_method = 'STREAMS' ) THEN
      p_krpv_rec.DAYS_IN_A_MONTH_CODE := '30';
    END IF;

    IF (p_column_name = 'DAYS_IN_A_MONTH_CODE' ) THEN
      RETURN;
    END IF;
  END IF;

  IF (p_column_name = 'DAYS_IN_A_YEAR_CODE' OR p_column_name = 'ALL') THEN
    IF (p_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
       (p_int_calc_basis = 'REAMORT' AND p_rev_rec_method = 'STREAMS')) THEN
      p_krpv_rec.DAYS_IN_A_YEAR_CODE := '360';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'REAMORT' AND
           p_rev_rec_method = 'STREAMS' ) THEN
      p_krpv_rec.DAYS_IN_A_YEAR_CODE := '360';
    END IF;

    IF (p_column_name = 'DAYS_IN_A_YEAR_CODE' ) THEN
      RETURN;
    END IF;
  END IF;

  IF (p_column_name = 'INTEREST_BASIS_CODE' OR p_column_name = 'ALL') THEN
    IF (p_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
       (p_int_calc_basis = 'REAMORT' AND p_rev_rec_method = 'STREAMS')) THEN
      p_krpv_rec.INTEREST_BASIS_CODE := 'SIMPLE';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'REAMORT' AND
           p_rev_rec_method = 'STREAMS' ) THEN
      p_krpv_rec.INTEREST_BASIS_CODE := 'SIMPLE';
    END IF;

    IF (p_column_name = 'INTEREST_BASIS_CODE') THEN
      RETURN;
    END IF;
  END IF;

  IF (p_column_name = 'RATE_CHANGE_FREQUENCY_CODE' OR p_column_name= 'ALL') THEN
    IF (p_deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
       (p_int_calc_basis = 'REAMORT' AND p_rev_rec_method = 'STREAMS')) THEN
      p_krpv_rec.RATE_CHANGE_FREQUENCY_CODE := 'BILLING_DATE';
    ELSIF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'REAMORT' AND
           p_rev_rec_method = 'STREAMS' ) THEN
      p_krpv_rec.RATE_CHANGE_FREQUENCY_CODE := 'BILLING_DATE';
    END IF;

    IF (p_column_name = 'RATE_CHANGE_FREQUENCY_CODE' ) THEN
      RETURN;
    END IF;
  END IF;

  IF (p_column_name = 'CATCHUP_BASIS_CODE' OR p_column_name= 'ALL') THEN
    IF (p_deal_type = 'LOAN' AND
           p_int_calc_basis = 'CATCHUP/CLEANUP' AND
           p_rev_rec_method = 'STREAMS' ) THEN
      p_krpv_rec.CATCHUP_BASIS_CODE := 'ACTUAL';
    END IF;

    IF (p_column_name = 'CATCHUP_BASIS_CODE' ) THEN
      RETURN;
    END IF;
  END IF;

END;

PROCEDURE cascade_contract_start_date(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_chr_id                  IN OKC_K_HEADERS_B.ID%TYPE,
    p_new_start_date          IN DATE) IS
l_effective_from_date DATE;
l_api_name varchar2(30) := 'cascade_cntrct_start_date';
l_api_version number := 1;
l_no_data_found BOOLEAN:= FALSE;
l_krpv_rec krpv_rec_type;
x_krpv_rec krpv_rec_type;
l_pdt_parameter_rec  OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
l_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
l_interest_processing_started BOOLEAN;
l_product_id NUMBER;
l_contract_start_date DATE;

--Bug 4735972
CURSOR rate_csr(p_id NUMBER) IS
SELECT COUNT(1) COUNT1
FROM   OKL_K_RATE_PARAMS
WHERE  KHR_ID = p_id
AND    EFFECTIVE_TO_DATE IS NULL;
l_rate_count NUMBER;
l_catchup_start_date DATE;


BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);


  --Bug 4735972
  FOR r IN rate_csr(p_chr_id)
  LOOP
    l_rate_count := r.COUNT1;
  END LOOP;

  --Bug 4735972
  IF (l_rate_count > 0) THEN

    get_product(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_khr_id        => p_chr_id,
            x_pdt_parameter_rec => l_pdt_parameter_rec);

    l_interest_processing_started := interest_processing
                                      (p_chr_id,
                                       l_contract_number,
                                       l_contract_start_date);

    IF (l_interest_processing_started) THEN
      -- Parameters RATE_CHANGE_START_DATE can not be updated because
      -- Interest Processing has already started for contract CONTRACT_NUMBER.
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => 'OKL_LLA_VAR_RATE_INT_PROC'
                          ,p_token1       => 'PARAMETER_NAME'
                          --,p_token1_value => 'INTEREST_START_DATE'
                          ,p_token1_value =>
               'INTEREST_START_DATE,RATE_CHANGE_START_DATE,CATCHUP_START_DATE'
                          ,p_token2       => 'CONTRACT_NUMBER'
                          ,p_token2_value => l_contract_number);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF (l_pdt_parameter_rec.DEAL_TYPE IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
        l_pdt_parameter_rec.interest_calculation_basis IN
              ('REAMORT', 'FLOAT_FACTORS')  AND
        l_pdt_parameter_rec.revenue_recognition_method ='STREAMS' )  OR
       (l_pdt_parameter_rec.DEAL_TYPE IN ('LOAN') AND
        l_pdt_parameter_rec.interest_calculation_basis = 'FLOAT'  AND
        l_pdt_parameter_rec.revenue_recognition_method IN
            ('ESTIMATED_AND_BILLED', 'ACTUAL' ) )                    OR
       (l_pdt_parameter_rec.DEAL_TYPE IN ('LOAN') AND
        l_pdt_parameter_rec.interest_calculation_basis IN
              ('REAMORT', 'CATCHUP/CLEANUP', 'FIXED')  AND
        l_pdt_parameter_rec.revenue_recognition_method IN
            ('STREAMS', 'ACTUAL' ) )                                 OR
       (l_pdt_parameter_rec.DEAL_TYPE IN ('LOAN-REVOLVING') AND
        l_pdt_parameter_rec.interest_calculation_basis = 'FLOAT'  AND
        l_pdt_parameter_rec.revenue_recognition_method IN
            ('ESTIMATED_AND_BILLED', 'ACTUAL' ) )                    THEN

      get_effective_from_date(
        p_api_version  ,
        p_init_msg_list,
        x_return_status,
        x_msg_count    ,
        x_msg_data     ,
        p_chr_id       ,
        l_effective_from_date,
        l_no_data_found);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF NOT(l_no_data_found) THEN
        l_krpv_rec.khr_id := p_chr_id;
        l_krpv_rec.effective_from_date := l_effective_from_date;
        --l_krpv_rec.effective_from_date := p_new_start_date;
        l_krpv_rec.parameter_type_code := 'ACTUAL';

        l_krpv_rec.interest_start_date := p_new_start_date;
        l_krpv_rec.rate_change_start_date := p_new_start_date;

        IF (l_pdt_parameter_rec.DEAL_TYPE = 'LOAN' AND
            l_pdt_parameter_rec.interest_calculation_basis =
                  'CATCHUP/CLEANUP' AND
            l_pdt_parameter_rec.revenue_recognition_method = 'STREAMS' ) THEN
          l_krpv_rec.catchup_start_date := p_new_start_date;
          l_catchup_start_date := p_new_start_date;
        ELSE
          l_catchup_start_date := null;
        END IF;

        update OKL_K_RATE_PARAMS
        SET    interest_start_date = p_new_start_date,
               rate_change_start_date = p_new_start_date,
               catchup_start_date = nvl(l_catchup_start_date,catchup_start_date)
        WHERE  khr_id = p_chr_id
        AND    effective_from_date = l_effective_from_date
        AND    effective_to_date is NULL;

        /*update_k_rate_params(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_krpv_rec      => l_krpv_rec,
            x_krpv_rec      => x_krpv_rec);
            --p_validate_flag => 'Y');
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF; */

        update okl_k_rate_params
        set    effective_from_date = p_new_start_date
        WHERE  khr_id = p_chr_id
        AND    effective_from_date = l_effective_from_date
        AND    effective_to_date IS NULL;
        --AND    parameter_type_code = 'ACTUAL';

      /*ELSE
        update okl_k_rate_params
        set    effective_from_date = p_new_start_date
        WHERE  khr_id = p_chr_id
        AND    effective_from_date = l_effective_from_date
        AND    effective_to_date is NULL;
        --AND    parameter_type_code = 'ACTUAL'; */

      END IF;

    END IF;

  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

  EXCEPTION
	WHEN OTHERS THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END;

  -- smadhava Bug#4542290 - 22-Aug-2005 - Added - Start
  --------------------------------------------------------------------------------
  --Start of Comments
  --API Name    : Check_Rebook_Allowed
  --Description : Process API to check if the rebook transaction can be allowed
  --              for the contract.
  --              1. Obtain the Product Parameters - Book Classification, Interest
  --                 Calculation Basis and Revenue Recognition Method.
  --              2. Obtain the due date for various streams accrued and billed.
  --              3. Ensure that the rebook date is after the due date of streams
  --                 billed/accrued.
  -- The valid combinations of Book classification and Interest Calculation Basis:
  --  (i)   OPLease/STLease/DFLease and Fixed/Reamort(If interest has not been
  --                                    processed before)/Float Factors
  --  (ii)  Loan and Fixed/Reamort(If interest has not been processed before)/
  --                 Float/ Catchup-Cleanup
  --  (iii) Revolving Loan and Float
  -- Streams Used to calculate due date:
  --   ------------------------------------------------------------------------
  --   S.NO BOOK_CLASS  ICB       RRM      ACCRUAL_STREAM           BILL_STREAM
  --   ------------------------------------------------------------------------
  --     1  LEASEOP    REAMORT              RENT_ACCRUAL             RENT
  --     2  LEASEST    REAMORT              LEASE_INCOME             RENT
  --     3  LEASEDF    REAMORT              LEASE_INCOME             RENT
  --     4  LOAN       REAMORT              INTEREST_INCOME          RENT
  --     5  LOAN       FLOAT    ESTIMATED   VARIABLE_INTEREST  VARIABLE_INTEREST
  --                            and ACTUAL  _INCOME            _INCOME
  --     6  LOAN       FLOAT      ACTUAL    INTEREST_INCOME      LOAN_PAYMENT
  --     7  REV_LOAN   FLOAT    ESTIMATED   VARIABLE_INTEREST  VARIABLE_INTEREST
  --                            and ACTUAL  _INCOME            _INCOME
  --     8  REV_LOAN   FLOAT      ACTUAL    INTEREST_INCOME      LOAN_PAYMENT
  --    ------------------------------------------------------------------------
  --History     :
  --              22-AUG-2005 smadhava Created
  --End of Comments
  ------------------------------------------------------------------------------
  PROCEDURE check_rebook_allowed (
    p_api_version             IN         NUMBER,
    p_init_msg_list           IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_chr_id                  IN         OKC_K_HEADERS_B.ID%TYPE,
    p_rebook_date             IN         DATE) IS

    l_api_name             VARCHAR2(30) := 'check_rebook_allowed';
    l_api_version          NUMBER := 1;

    l_contract_number       OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_book_class            OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE;
    l_book_class_meaning    OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE_MEANING%TYPE;
    l_interest_calc_basis   OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE;
    l_interest_calc_meaning OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_MEANING%TYPE;
    l_rev_recog_method      OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE;
    --l_rev_recog_meaning     OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_MEANING%TYPE;
    l_interest_proc_date    OKL_K_HEADERS.DATE_LAST_INTERIM_INTEREST_CAL%TYPE;
    l_stream_name           OKL_STRM_TYPE_V.STYB_PURPOSE_MEANING%TYPE;

    l_last_accrued_due_date DATE;
    l_last_billed_due_date  DATE;

    l_pdt_params_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

    -- Get the quality descriptions
    CURSOR get_prod_param_values(cp_name OKL_PDT_QUALITYS.NAME%TYPE
                               , cp_value OKL_PQY_VALUES.VALUE%TYPE) IS
    SELECT
         QVE.DESCRIPTION
      FROM
         OKL_PDT_QUALITYS PQY
       , OKL_PQY_VALUES QVE
     WHERE
          QVE.PQY_ID = PQY.ID
      AND PQY.NAME   = cp_name
      AND QVE.VALUE  = cp_value;

    -- Get the lookup meanings
    CURSOR get_lkp_meaning(cp_lkp_type FND_LOOKUPS.LOOKUP_TYPE%TYPE
                         , cp_lkp_code FND_LOOKUPS.LOOKUP_CODE%TYPE) IS
    SELECT
         FNDLUP.MEANING
      FROM
          FND_LOOKUPS FNDLUP
     WHERE
           FNDLUP.LOOKUP_TYPE = cp_lkp_type
       AND FNDLUP.LOOKUP_CODE = cp_lkp_code
       AND SYSDATE BETWEEN
                         NVL(FNDLUP.START_DATE_ACTIVE,SYSDATE)
                         AND NVL(FNDLUP.END_DATE_ACTIVE,SYSDATE);

    -- Cursor to query to get the Interest Processed flag
    CURSOR get_contract_details(cp_chr_id OKL_K_HEADERS.ID%TYPE) IS
      SELECT
           CHR.CONTRACT_NUMBER
         , KHR.DATE_LAST_INTERIM_INTEREST_CAL INTEREST_PROCESSED_FLAG
       FROM
            OKL_K_HEADERS     KHR
          , OKC_K_HEADERS_B   CHR
      WHERE
            CHR.ID  = KHR.ID
        AND KHR.ID  = cp_chr_id;

     --Cursor to query the last accrued due date of the stream.
     --Bug# 9058664: Corrected GROUP BY clause
     CURSOR get_last_accrued_due_date(
               p_chr_id OKC_K_HEADERS_B.ID%TYPE
             , p_stream_purpose OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE) IS
       SELECT
             MAX(STE.STREAM_ELEMENT_DATE) LAST_STREAM_DUE_DATE
           , STY.STYB_PURPOSE_MEANING
         FROM
            OKL_STRM_ELEMENTS STE
          , OKL_STREAMS       STM
          , OKL_STRM_TYPE_V   STY
          , OKL_K_HEADERS     KHR
          , OKC_K_HEADERS_B CHR
        WHERE
            STM.ID         = STE.STM_ID
        AND STY.ID         = STM.STY_ID
        AND KHR.ID         = STM.KHR_ID
        AND CHR.ID         = KHR.ID
        AND STE.ACCRUED_YN ='Y'
        AND CHR.ID         = p_chr_id
        AND STY.STREAM_TYPE_PURPOSE  = p_stream_purpose
        GROUP BY STY.STYB_PURPOSE_MEANING;

     --Cursor to query the last billed due date of the stream.
     --Bug# 9058664: Corrected GROUP BY clause
     CURSOR get_last_billed_due_date(
               p_chr_id OKC_K_HEADERS_B.ID%TYPE
             , p_stream_purpose OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE) IS
       SELECT
           MAX(STE.STREAM_ELEMENT_DATE) LAST_STREAM_DUE_DATE
           , STY.STYB_PURPOSE_MEANING
         FROM
            OKL_STRM_ELEMENTS STE
          , OKL_STREAMS       STM
          , OKL_STRM_TYPE_V   STY
          , OKL_K_HEADERS     KHR
          , OKC_K_HEADERS_B CHR
        WHERE
            STM.ID         = STE.STM_ID
        AND STY.ID         = STM.STY_ID
        AND KHR.ID         = STM.KHR_ID
        AND CHR.ID         = KHR.ID
        AND STE.DATE_BILLED IS NOT NULL
        AND CHR.ID         = p_chr_id
        AND STY.STREAM_TYPE_PURPOSE  = p_stream_purpose
        GROUP BY STY.STYB_PURPOSE_MEANING;
  l_product_id NUMBER;
  -- 4766555
  l_mass_rebook_flag varchar2(1) := 'N';

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
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

    -- Obtain the contract details - Book classification, Interest Calculation Basis, Revenue Recognition Method, Interest Processed flag
    OKL_K_RATE_PARAMS_PVT.get_product(
                p_api_version       => p_api_version,
                p_init_msg_list     => p_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_khr_id            => p_chr_id,
                x_pdt_parameter_rec => l_pdt_params_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    l_book_class          := l_pdt_params_rec.deal_type;
    l_interest_calc_basis := l_pdt_params_rec.interest_calculation_basis;
    l_rev_recog_method    := l_pdt_params_rec.revenue_recognition_method;

    OPEN get_lkp_meaning('OKL_BOOK_CLASS',l_book_class);
      FETCH get_lkp_meaning INTO l_book_class_meaning;
    CLOSE get_lkp_meaning;

    OPEN get_prod_param_values('INTEREST_CALCULATION_BASIS',
                                                l_interest_calc_basis);
      FETCH get_prod_param_values INTO l_interest_calc_meaning;
    CLOSE get_prod_param_values;

    /*
    OPEN get_prod_param_values('REVENUE_RECOGNITION_METHOD',
                                                l_rev_recog_method);
      FETCH get_prod_param_values INTO l_rev_recog_meaning;
    CLOSE get_prod_param_values; */

    OPEN get_contract_details(p_chr_id);
      FETCH get_contract_details INTO l_contract_number, l_interest_proc_date;
    CLOSE get_contract_details;

    -- 4766555
    l_mass_rebook_flag := okl_lla_util_pvt.check_mass_rebook_contract(
                            p_chr_id => p_chr_id);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'check_rebook_allowed:l_mass_rebook_flag=' || l_mass_rebook_flag);
    END IF;

    -- Check the combinations of Book classification,
    -- Revenue Recognition Method  Calculation Basis
    -- Check for Operating Lease

    IF (l_book_class = G_BOOK_CLASS_OP) THEN
      IF (l_interest_calc_basis NOT IN
            (G_ICB_FIXED, G_ICB_FLOAT_FACTOR, G_ICB_REAMORT )) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_OKL_LLA_REBOOK_INVALID
                            ,p_token1       => G_BOOK_CLASS
                            ,p_token1_value => l_book_class_meaning
                            ,p_token2       => G_INT_CALC_BASIS
                            ,p_token2_value => l_interest_calc_meaning);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF ( l_interest_calc_basis = G_ICB_REAMORT) THEN
        -- Donot allow Rebook if  interest has been processed
        IF ( l_interest_proc_date IS NOT NULL ) THEN
          IF (l_mass_rebook_flag = OKL_API.G_TRUE) THEN -- 4766555
            NULL;
          ELSE
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_RBK_INT_PROC_INVAL
                              ,p_token1       => G_COL_NAME
                              ,p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          -- Get the due date of the Rental stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_RENT);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Rental Accrual stream that was last accrued
          /* -- Bug 5000110
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_RENT_ACCRUAL);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL
             AND p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL
                AND p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        END IF; -- end of check for interest rate processed

      END IF; -- end of REAMORT check

    -- Check for Sales Type Lease
    ELSIF (l_book_class = G_BOOK_CLASS_ST) THEN
      IF (l_interest_calc_basis NOT IN
            (G_ICB_FIXED, G_ICB_FLOAT_FACTOR, G_ICB_REAMORT )) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_OKL_LLA_REBOOK_INVALID
                            ,p_token1       => G_BOOK_CLASS
                            ,p_token1_value => l_book_class_meaning
                            ,p_token2       => G_INT_CALC_BASIS
                            ,p_token2_value => l_interest_calc_meaning);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF ( l_interest_calc_basis = G_ICB_REAMORT) THEN
        -- Donot allow Rebook if  interest has been processed
        IF ( l_interest_proc_date IS NOT NULL ) THEN
          IF (l_mass_rebook_flag = OKL_API.G_TRUE) THEN -- 4766555
            NULL;
          ELSE
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_RBK_INT_PROC_INVAL
                              ,p_token1       => G_COL_NAME
                              ,p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          -- Get the due date of the Rental stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_RENT);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Pre-Tax Income stream that was last accrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_PRE_TAX);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL AND
               p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        END IF; -- end of check for interest rate processed

      END IF; -- end of REAMORT check

    -- Check for Direct Finance Lease
    ELSIF (l_book_class = G_BOOK_CLASS_DF) THEN
      IF (l_interest_calc_basis NOT IN
             (G_ICB_FIXED, G_ICB_FLOAT_FACTOR, G_ICB_REAMORT )) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_OKL_LLA_REBOOK_INVALID
                            ,p_token1       => G_BOOK_CLASS
                            ,p_token1_value => l_book_class_meaning
                            ,p_token2       => G_INT_CALC_BASIS
                            ,p_token2_value => l_interest_calc_meaning);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF ( l_interest_calc_basis = G_ICB_REAMORT) THEN
        -- Donot allow Rebook if  interest has been processed
        IF ( l_interest_proc_date IS NOT NULL ) THEN
          IF (l_mass_rebook_flag = OKL_API.G_TRUE) THEN -- 4766555
            NULL;
          ELSE
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_RBK_INT_PROC_INVAL
                              ,p_token1       => G_COL_NAME
                              ,p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          -- Get the due date of the rent stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_RENT);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Pre-Tax Income stream that was last accrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_PRE_TAX);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL AND
               p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        END IF; -- end of check for interest rate processed

      END IF; -- end of REAMORT check

         -- Check for Loan
    ELSIF (l_book_class = G_BOOK_CLASS_LOAN) THEN
      IF (l_interest_calc_basis NOT IN
          (G_ICB_FIXED, G_ICB_FLOAT, G_ICB_REAMORT, G_ICB_CATCHUP_CLEANUP)) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_OKL_LLA_REBOOK_INVALID
                            ,p_token1       => G_BOOK_CLASS
                            ,p_token1_value => l_book_class_meaning
                            ,p_token2       => G_INT_CALC_BASIS
                            ,p_token2_value => l_interest_calc_meaning);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF ( l_interest_calc_basis = G_ICB_REAMORT) THEN
        IF ( l_interest_proc_date IS NOT NULL ) THEN
          IF (l_mass_rebook_flag = OKL_API.G_TRUE) THEN -- 4766555
            NULL;
          ELSE
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_RBK_INT_PROC_INVAL
                              ,p_token1       => G_COL_NAME
                              ,p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          -- Get the due date of the rent stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_RENT);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Interest Income stream that was last accrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_INT_INCOME);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL
               AND p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        END IF; -- end of check for interest rate processed

      END IF; -- end of REAMORT check

      IF ( l_interest_calc_basis = G_ICB_FLOAT) THEN
        -- Check if the Revenue Recognition Method is Estimated and Actual
        IF ( l_rev_recog_method = G_RRM_EST_ACTUAL) THEN
          -- Get the due date of the Variable Interest Income stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_VAR_INT_INCOME);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Variable Interest Income stream that was last acrrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_VAR_INT_INCOME);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL AND
               p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        -- Check if the Revenue Recognition Method is Actual
        ELSIF ( l_rev_recog_method = G_RRM_ACTUAL) THEN
          -- Get the due date of the Variable Loan Payment stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_LOAN_PAYMENT);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Interest Income stream that was last accrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_INT_INCOME);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL AND
               p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        END IF; -- end of check for Revenue Recognition Method
      END IF; -- end of check for Interest Calculation Basis=FLOAT

    -- Check for Revolving Loans
    ELSIF (l_book_class = G_BOOK_CLASS_REVLOAN) THEN
      IF (l_interest_calc_basis <> G_ICB_FLOAT) THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_OKL_LLA_REBOOK_INVALID
                            ,p_token1       => G_BOOK_CLASS
                            ,p_token1_value => l_book_class_meaning
                            ,p_token2       => G_INT_CALC_BASIS
                            ,p_token2_value => l_interest_calc_meaning);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
        -- Check if the Revenue Recognition Method is Estimated and Actual
        IF ( l_rev_recog_method = G_RRM_EST_ACTUAL) THEN
          -- Get the due date of the Variable Interest Income stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_VAR_INT_INCOME);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Variable Interest Income stream that was last accrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_VAR_INT_INCOME);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL AND
               p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        -- Check if the Revenue Recognition Method is Actual
        ELSIF ( l_rev_recog_method = G_RRM_ACTUAL) THEN
          -- Get the due date of the Variable Loan Payment stream that was last billed
          OPEN get_last_billed_due_date(p_chr_id, G_STRM_LOAN_PAYMENT);
            FETCH get_last_billed_due_date
            INTO l_last_billed_due_date, l_stream_name;
          CLOSE get_last_billed_due_date;
          -- Get the due date of the Interest Income stream that was last accrued
          -- Bug 5000110
          /*
          OPEN get_last_accrued_due_date(p_chr_id, G_STRM_INT_INCOME);
            FETCH get_last_accrued_due_date
            INTO l_last_accrued_due_date, l_stream_name;
          CLOSE get_last_accrued_due_date; */

          IF ( l_last_billed_due_date IS NOT NULL AND
               p_rebook_date <= l_last_billed_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_BILL_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_billed_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          /*ELSIF ( l_last_accrued_due_date IS NOT NULL AND
                  p_rebook_date <= l_last_accrued_due_date) THEN
            OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                                ,p_msg_name     => G_OKL_LLA_RBK_DATE_ACCR_INVAL
                                ,p_token1       => G_STREAM
                                ,p_token1_value => l_stream_name
                                ,p_token2       => G_DUE_DATE
                                ,p_token2_value => l_last_accrued_due_date);
            RAISE OKL_API.G_EXCEPTION_ERROR; */ -- Bug 5000110
          END IF; -- end of check for rebook date
        END IF; -- end of check for Revenue Recognition Method
      END IF; -- end of check for Interest Calculation Basis=FLOAT
    /*-- Raise an error if the book classification is not valid.
         ELSE
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR; */
    END IF;

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
  END; -- end of procedure Check_Rebook_Allowed

  -- smadhava Bug#4542290 - 22-Aug-2005 - Added - End

PROCEDURE SYNC_RATE_PARAMS(
                     p_orig_contract_id  IN NUMBER,
                     p_new_contract_id   IN NUMBER) IS
    TYPE l_kkhr_id_type is table of okl_k_rate_params.khr_id%TYPE index by binary_integer;
    TYPE l_kparameter_type_code_type is table of okl_k_rate_params.parameter_type_code%TYPE index by binary_integer;
    TYPE l_keffective_from_date_type is table of okl_k_rate_params.effective_from_date%TYPE index by binary_integer;
    TYPE l_keffective_to_date_type is table of okl_k_rate_params.effective_to_date%TYPE index by binary_integer;
    TYPE l_kinterest_index_id_type is table of okl_k_rate_params.interest_index_id%TYPE index by binary_integer;
    TYPE l_kbase_rate_type is table of okl_k_rate_params.base_rate%TYPE index by binary_integer;
    TYPE l_kinterest_start_date_type is table of okl_k_rate_params.interest_start_date%TYPE index by binary_integer;
    TYPE l_kadder_rate_type is table of okl_k_rate_params.adder_rate%TYPE index by binary_integer;
    TYPE l_kmaximum_rate_type is table of okl_k_rate_params.maximum_rate%TYPE index by binary_integer;
    TYPE l_kminimum_rate_type is table of okl_k_rate_params.minimum_rate%TYPE index by binary_integer;
    TYPE l_kprincipal_basis_code_type is table of okl_k_rate_params.principal_basis_code%TYPE index by binary_integer;
    TYPE l_kdays_in_a_month_code_type is table of okl_k_rate_params.days_in_a_month_code%TYPE index by binary_integer;
    TYPE l_kdays_in_a_year_code_type is table of okl_k_rate_params.days_in_a_year_code%TYPE index by binary_integer;
    TYPE l_kinterest_basis_code_type is table of okl_k_rate_params.interest_basis_code%TYPE index by binary_integer;
    TYPE l_krate_delay_code_type is table of okl_k_rate_params.rate_delay_code%TYPE index by binary_integer;
    TYPE l_krate_delay_frequency_type is table of okl_k_rate_params.rate_delay_frequency%TYPE index by binary_integer;
    TYPE l_kcompounding_frequ_code_type is table of okl_k_rate_params.compounding_frequency_code%TYPE index by binary_integer;
    TYPE l_kcalculation_formula_id_type is table of okl_k_rate_params.calculation_formula_id%TYPE index by binary_integer;
    TYPE l_kcatchup_basis_code_type is table of okl_k_rate_params.catchup_basis_code%TYPE index by binary_integer;
    TYPE l_kcatchup_start_date_type is table of okl_k_rate_params.catchup_start_date%TYPE index by binary_integer;
    TYPE l_kcatchup_settlemen_code_type is table of okl_k_rate_params.catchup_settlement_code%TYPE index by binary_integer;
    TYPE l_krate_change_start_date_type is table of okl_k_rate_params.rate_change_start_date%TYPE index by binary_integer;
    TYPE l_krate_change_frequ_code_type is table of okl_k_rate_params.rate_change_frequency_code%TYPE index by binary_integer;
    TYPE l_krate_change_value_type is table of okl_k_rate_params.rate_change_value%TYPE index by binary_integer;
    TYPE l_kconversion_option_code_type is table of okl_k_rate_params.conversion_option_code%TYPE index by binary_integer;
    TYPE l_knext_conversion_date_type is table of okl_k_rate_params.next_conversion_date%TYPE index by binary_integer;
    TYPE l_kconversion_type_code_type is table of okl_k_rate_params.conversion_type_code%TYPE index by binary_integer;
    TYPE l_kattribute_category_type is table of okl_k_rate_params.attribute_category%TYPE index by binary_integer;
    TYPE l_kattribute1_type is table of okl_k_rate_params.attribute1%TYPE index by binary_integer;
    TYPE l_kattribute2_type is table of okl_k_rate_params.attribute2%TYPE index by binary_integer;
    TYPE l_kattribute3_type is table of okl_k_rate_params.attribute3%TYPE index by binary_integer;
    TYPE l_kattribute4_type is table of okl_k_rate_params.attribute4%TYPE index by binary_integer;
    TYPE l_kattribute5_type is table of okl_k_rate_params.attribute5%TYPE index by binary_integer;
    TYPE l_kattribute6_type is table of okl_k_rate_params.attribute6%TYPE index by binary_integer;
    TYPE l_kattribute7_type is table of okl_k_rate_params.attribute7%TYPE index by binary_integer;
    TYPE l_kattribute8_type is table of okl_k_rate_params.attribute8%TYPE index by binary_integer;
    TYPE l_kattribute9_type is table of okl_k_rate_params.attribute9%TYPE index by binary_integer;
    TYPE l_kattribute10_type is table of okl_k_rate_params.attribute10%TYPE index by binary_integer;
    TYPE l_kattribute11_type is table of okl_k_rate_params.attribute11%TYPE index by binary_integer;
    TYPE l_kattribute12_type is table of okl_k_rate_params.attribute12%TYPE index by binary_integer;
    TYPE l_kattribute13_type is table of okl_k_rate_params.attribute13%TYPE index by binary_integer;
    TYPE l_kattribute14_type is table of okl_k_rate_params.attribute14%TYPE index by binary_integer;
    TYPE l_kattribute15_type is table of okl_k_rate_params.attribute15%TYPE index by binary_integer;
    TYPE l_kcatchup_frequency_code_type is table of okl_k_rate_params.catchup_frequency_code%TYPE index by binary_integer;

    l_kkhr_id_tab l_kkhr_id_type;
    l_kparameter_type_code_tab l_kparameter_type_code_type;
    l_keffective_from_date_tab l_keffective_from_date_type;
    l_keffective_to_date_tab l_keffective_to_date_type;
    l_kinterest_index_id_tab l_kinterest_index_id_type;
    l_kbase_rate_tab l_kbase_rate_type;
    l_kinterest_start_date_tab l_kinterest_start_date_type;
    l_kadder_rate_tab l_kadder_rate_type;
    l_kmaximum_rate_tab l_kmaximum_rate_type;
    l_kminimum_rate_tab l_kminimum_rate_type;
    l_kprincipal_basis_code_tab l_kprincipal_basis_code_type;
    l_kdays_in_a_month_code_tab l_kdays_in_a_month_code_type;
    l_kdays_in_a_year_code_tab l_kdays_in_a_year_code_type;
    l_kinterest_basis_code_tab l_kinterest_basis_code_type;
    l_krate_delay_code_tab l_krate_delay_code_type;
    l_krate_delay_frequency_tab l_krate_delay_frequency_type;
    l_kcompounding_frequ_code_tab l_kcompounding_frequ_code_type;
    l_kcalculation_formula_id_tab l_kcalculation_formula_id_type;
    l_kcatchup_basis_code_tab l_kcatchup_basis_code_type;
    l_kcatchup_start_date_tab l_kcatchup_start_date_type;
    l_kcatchup_settlemen_code_tab l_kcatchup_settlemen_code_type;
    l_krate_change_start_date_tab l_krate_change_start_date_type;
    l_krate_change_frequ_code_tab l_krate_change_frequ_code_type;
    l_krate_change_value_tab l_krate_change_value_type;
    l_kconversion_option_code_tab l_kconversion_option_code_type;
    l_knext_conversion_date_tab l_knext_conversion_date_type;
    l_kconversion_type_code_tab l_kconversion_type_code_type;
    l_kattribute_category_tab l_kattribute_category_type;
    l_kattribute1_tab l_kattribute1_type;
    l_kattribute2_tab l_kattribute2_type;
    l_kattribute3_tab l_kattribute3_type;
    l_kattribute4_tab l_kattribute4_type;
    l_kattribute5_tab l_kattribute5_type;
    l_kattribute6_tab l_kattribute6_type;
    l_kattribute7_tab l_kattribute7_type;
    l_kattribute8_tab l_kattribute8_type;
    l_kattribute9_tab l_kattribute9_type;
    l_kattribute10_tab l_kattribute10_type;
    l_kattribute11_tab l_kattribute11_type;
    l_kattribute12_tab l_kattribute12_type;
    l_kattribute13_tab l_kattribute13_type;
    l_kattribute14_tab l_kattribute14_type;
    l_kattribute15_tab l_kattribute15_type;
    l_kcatchup_frequency_code_tab l_kcatchup_frequency_code_type;

    l_kkhr_id_tab2 l_kkhr_id_type;
    l_kparameter_type_code_tab2 l_kparameter_type_code_type;
    l_keffective_from_date_tab2 l_keffective_from_date_type;
    l_keffective_to_date_tab2 l_keffective_to_date_type;
    l_kinterest_index_id_tab2 l_kinterest_index_id_type;
    l_kbase_rate_tab2 l_kbase_rate_type;
    l_kinterest_start_date_tab2 l_kinterest_start_date_type;
    l_kadder_rate_tab2 l_kadder_rate_type;
    l_kmaximum_rate_tab2 l_kmaximum_rate_type;
    l_kminimum_rate_tab2 l_kminimum_rate_type;
    l_kprincipal_basis_code_tab2 l_kprincipal_basis_code_type;
    l_kdays_in_a_month_code_tab2 l_kdays_in_a_month_code_type;
    l_kdays_in_a_year_code_tab2 l_kdays_in_a_year_code_type;
    l_kinterest_basis_code_tab2 l_kinterest_basis_code_type;
    l_krate_delay_code_tab2 l_krate_delay_code_type;
    l_krate_delay_frequency_tab2 l_krate_delay_frequency_type;
    l_kcompounding_frequ_code_tab2 l_kcompounding_frequ_code_type;
    l_kcalculation_formula_id_tab2 l_kcalculation_formula_id_type;
    l_kcatchup_basis_code_tab2 l_kcatchup_basis_code_type;
    l_kcatchup_start_date_tab2 l_kcatchup_start_date_type;
    l_kcatchup_settlemen_code_tab2 l_kcatchup_settlemen_code_type;
    l_krate_change_start_date_tab2 l_krate_change_start_date_type;
    l_krate_change_frequ_code_tab2 l_krate_change_frequ_code_type;
    l_krate_change_value_tab2 l_krate_change_value_type;
    l_kconversion_option_code_tab2 l_kconversion_option_code_type;
    l_knext_conversion_date_tab2 l_knext_conversion_date_type;
    l_kconversion_type_code_tab2 l_kconversion_type_code_type;
    l_kattribute_category_tab2 l_kattribute_category_type;
    l_kattribute1_tab2 l_kattribute1_type;
    l_kattribute2_tab2 l_kattribute2_type;
    l_kattribute3_tab2 l_kattribute3_type;
    l_kattribute4_tab2 l_kattribute4_type;
    l_kattribute5_tab2 l_kattribute5_type;
    l_kattribute6_tab2 l_kattribute6_type;
    l_kattribute7_tab2 l_kattribute7_type;
    l_kattribute8_tab2 l_kattribute8_type;
    l_kattribute9_tab2 l_kattribute9_type;
    l_kattribute10_tab2 l_kattribute10_type;
    l_kattribute11_tab2 l_kattribute11_type;
    l_kattribute12_tab2 l_kattribute12_type;
    l_kattribute13_tab2 l_kattribute13_type;
    l_kattribute14_tab2 l_kattribute14_type;
    l_kattribute15_tab2 l_kattribute15_type;
    l_kcatchup_frequency_code_tab2 l_kcatchup_frequency_code_type;

    l_k_rate_params_counter number := 1;

--CURSOR C30(p_id NUMBER, p_date DATE) IS
CURSOR C30(p_id NUMBER) IS
SELECT
       a.khr_id, a.parameter_type_code, a.effective_from_date,
       a.effective_to_date, a.interest_index_id, a.base_rate,
       a.interest_start_date, a.adder_rate, a.maximum_rate,
       a.minimum_rate, a.principal_basis_code, a.days_in_a_month_code,
       a.days_in_a_year_code, a.interest_basis_code, a.rate_delay_code,
       a.rate_delay_frequency, a.compounding_frequency_code, a.calculation_formula_id,
       a.catchup_basis_code, a.catchup_start_date, a.catchup_settlement_code,
       a.rate_change_start_date, a.rate_change_frequency_code, a.rate_change_value,
       a.conversion_option_code, a.next_conversion_date, a.conversion_type_code,
       a.attribute_category, a.attribute1, a.attribute2,
       a.attribute3, a.attribute4, a.attribute5,
       a.attribute6, a.attribute7, a.attribute8,
       a.attribute9, a.attribute10, a.attribute11,
       a.attribute12, a.attribute13, a.attribute14,
       a.attribute15, a.catchup_frequency_code
FROM   OKL_K_RATE_PARAMS a
WHERE  a.khr_id = p_id;
--AND    (effective_to_date is NULL OR
--        effective_to_date = p_date);

/*CURSOR max_effective_to_date_csr(p_id NUMBER) IS
SELECT max(effective_to_date) effective_to_date
FROM   OKL_K_RATE_PARAMS
WHERE KHR_ID = p_id;

l_max_effective_to_date DATE;*/
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  DELETE OKL_K_RATE_PARAMS
  WHERE  KHR_ID = p_new_contract_id;
  --AND    effective_to_date is NULL;

  /*FOR r IN max_effective_to_date_csr(p_orig_contract_id)
  LOOP
    l_max_effective_to_date := r.effective_to_date;
  END LOOP;*/

  --OPEN C30(p_orig_contract_id, l_max_effective_to_date);
  OPEN C30(p_orig_contract_id);
  LOOP
    FETCH C30 BULK COLLECT INTO
     l_kkhr_id_tab2, l_kparameter_type_code_tab2, l_keffective_from_date_tab2,
     l_keffective_to_date_tab2, l_kinterest_index_id_tab2, l_kbase_rate_tab2,
     l_kinterest_start_date_tab2, l_kadder_rate_tab2, l_kmaximum_rate_tab2,
     l_kminimum_rate_tab2, l_kprincipal_basis_code_tab2, l_kdays_in_a_month_code_tab2,
     l_kdays_in_a_year_code_tab2, l_kinterest_basis_code_tab2, l_krate_delay_code_tab2,
     l_krate_delay_frequency_tab2, l_kcompounding_frequ_code_tab2, l_kcalculation_formula_id_tab2,
     l_kcatchup_basis_code_tab2, l_kcatchup_start_date_tab2, l_kcatchup_settlemen_code_tab2,
     l_krate_change_start_date_tab2, l_krate_change_frequ_code_tab2, l_krate_change_value_tab2,
     l_kconversion_option_code_tab2, l_knext_conversion_date_tab2, l_kconversion_type_code_tab2,
     l_kattribute_category_tab2, l_kattribute1_tab2, l_kattribute2_tab2,
     l_kattribute3_tab2, l_kattribute4_tab2, l_kattribute5_tab2,
     l_kattribute6_tab2, l_kattribute7_tab2, l_kattribute8_tab2,
     l_kattribute9_tab2, l_kattribute10_tab2, l_kattribute11_tab2,
     l_kattribute12_tab2, l_kattribute13_tab2, l_kattribute14_tab2,
     l_kattribute15_tab2, l_kcatchup_frequency_code_tab2
    LIMIT G_BULK_SIZE;
    EXIT WHEN l_kkhr_id_tab2.COUNT = 0;

    FOR i IN l_kkhr_id_tab2.FIRST..l_kkhr_id_tab2.LAST
    LOOP
      l_kkhr_id_tab(l_k_rate_params_counter) := l_kkhr_id_tab2(i);
      l_kkhr_id_tab(l_k_rate_params_counter) := p_new_contract_id;

      l_kparameter_type_code_tab(l_k_rate_params_counter) := l_kparameter_type_code_tab2(i);
      l_keffective_from_date_tab(l_k_rate_params_counter) := l_keffective_from_date_tab2(i);
      l_keffective_to_date_tab(l_k_rate_params_counter) := l_keffective_to_date_tab2(i);
      l_kinterest_index_id_tab(l_k_rate_params_counter) := l_kinterest_index_id_tab2(i);
      l_kbase_rate_tab(l_k_rate_params_counter) := l_kbase_rate_tab2(i);
      l_kinterest_start_date_tab(l_k_rate_params_counter) := l_kinterest_start_date_tab2(i);

      l_kadder_rate_tab(l_k_rate_params_counter) := l_kadder_rate_tab2(i);
      l_kmaximum_rate_tab(l_k_rate_params_counter) := l_kmaximum_rate_tab2(i);
      l_kminimum_rate_tab(l_k_rate_params_counter) := l_kminimum_rate_tab2(i);
      l_kprincipal_basis_code_tab(l_k_rate_params_counter) := l_kprincipal_basis_code_tab2(i);
      l_kdays_in_a_month_code_tab(l_k_rate_params_counter) := l_kdays_in_a_month_code_tab2(i);
      l_kdays_in_a_year_code_tab(l_k_rate_params_counter) := l_kdays_in_a_year_code_tab2(i);
      l_kinterest_basis_code_tab(l_k_rate_params_counter) := l_kinterest_basis_code_tab2(i);
      l_krate_delay_code_tab(l_k_rate_params_counter) := l_krate_delay_code_tab2(i);
      l_krate_delay_frequency_tab(l_k_rate_params_counter) := l_krate_delay_frequency_tab2(i);
      l_kcompounding_frequ_code_tab(l_k_rate_params_counter) := l_kcompounding_frequ_code_tab2(i);
      l_kcalculation_formula_id_tab(l_k_rate_params_counter) := l_kcalculation_formula_id_tab2(i);
      l_kcatchup_basis_code_tab(l_k_rate_params_counter) := l_kcatchup_basis_code_tab2(i);
      l_kcatchup_start_date_tab(l_k_rate_params_counter) := l_kcatchup_start_date_tab2(i);

      l_kcatchup_settlemen_code_tab(l_k_rate_params_counter) := l_kcatchup_settlemen_code_tab2(i);
      l_krate_change_start_date_tab(l_k_rate_params_counter) := l_krate_change_start_date_tab2(i);

      l_krate_change_frequ_code_tab(l_k_rate_params_counter) := l_krate_change_frequ_code_tab2(i);
      l_krate_change_value_tab(l_k_rate_params_counter) := l_krate_change_value_tab2(i);
      l_kconversion_option_code_tab(l_k_rate_params_counter) := l_kconversion_option_code_tab2(i);
      l_knext_conversion_date_tab(l_k_rate_params_counter) := l_knext_conversion_date_tab2(i);
      l_kconversion_type_code_tab(l_k_rate_params_counter) := l_kconversion_type_code_tab2(i);
      l_kattribute_category_tab(l_k_rate_params_counter) := l_kattribute_category_tab2(i);
      l_kattribute1_tab(l_k_rate_params_counter) := l_kattribute1_tab2(i);
      l_kattribute2_tab(l_k_rate_params_counter) := l_kattribute2_tab2(i);
      l_kattribute3_tab(l_k_rate_params_counter) := l_kattribute3_tab2(i);
      l_kattribute4_tab(l_k_rate_params_counter) := l_kattribute4_tab2(i);
      l_kattribute5_tab(l_k_rate_params_counter) := l_kattribute5_tab2(i);
      l_kattribute6_tab(l_k_rate_params_counter) := l_kattribute6_tab2(i);
      l_kattribute7_tab(l_k_rate_params_counter) := l_kattribute7_tab2(i);
      l_kattribute8_tab(l_k_rate_params_counter) := l_kattribute8_tab2(i);
      l_kattribute9_tab(l_k_rate_params_counter) := l_kattribute9_tab2(i);
      l_kattribute10_tab(l_k_rate_params_counter) := l_kattribute10_tab2(i);
      l_kattribute11_tab(l_k_rate_params_counter) := l_kattribute11_tab2(i);
      l_kattribute12_tab(l_k_rate_params_counter) := l_kattribute12_tab2(i);
      l_kattribute13_tab(l_k_rate_params_counter) := l_kattribute13_tab2(i);
      l_kattribute14_tab(l_k_rate_params_counter) := l_kattribute14_tab2(i);
      l_kattribute15_tab(l_k_rate_params_counter) := l_kattribute15_tab2(i);
      l_kcatchup_frequency_code_tab(l_k_rate_params_counter) := l_kcatchup_frequency_code_tab2(i);

      l_k_rate_params_counter := l_k_rate_params_counter + 1;
    END LOOP;
  END LOOP;
  CLOSE C30;

  IF l_k_rate_params_counter > 1 THEN
    FORALL i IN l_kkhr_id_tab.FIRST..l_kkhr_id_tab.LAST
      INSERT INTO okl_k_rate_params (
       khr_id, parameter_type_code, effective_from_date,
       effective_to_date, interest_index_id, base_rate,
       interest_start_date, adder_rate, maximum_rate,
       minimum_rate, principal_basis_code, days_in_a_month_code,
       days_in_a_year_code, interest_basis_code, rate_delay_code,
       rate_delay_frequency,compounding_frequency_code, calculation_formula_id,
       catchup_basis_code, catchup_start_date, catchup_settlement_code,
       rate_change_start_date, rate_change_frequency_code, rate_change_value,
       conversion_option_code, next_conversion_date, conversion_type_code,
       attribute_category, attribute1, attribute2,
       attribute3, attribute4, attribute5,
       attribute6, attribute7, attribute8,
       attribute9, attribute10, attribute11,
       attribute12, attribute13, attribute14,
       attribute15, created_by, creation_date,
       last_updated_by, last_update_date, last_update_login,
       catchup_frequency_code
      ) VALUES (
       l_kkhr_id_tab(i), l_kparameter_type_code_tab(i), l_keffective_from_date_tab(i),
       l_keffective_to_date_tab(i), l_kinterest_index_id_tab(i), l_kbase_rate_tab(i),
       l_kinterest_start_date_tab(i), l_kadder_rate_tab(i), l_kmaximum_rate_tab(i),
       l_kminimum_rate_tab(i), l_kprincipal_basis_code_tab(i), l_kdays_in_a_month_code_tab(i),
       l_kdays_in_a_year_code_tab(i), l_kinterest_basis_code_tab(i), l_krate_delay_code_tab(i),
       l_krate_delay_frequency_tab(i), l_kcompounding_frequ_code_tab(i), l_kcalculation_formula_id_tab(i),
       l_kcatchup_basis_code_tab(i), l_kcatchup_start_date_tab(i), l_kcatchup_settlemen_code_tab(i),
       l_krate_change_start_date_tab(i), l_krate_change_frequ_code_tab(i), l_krate_change_value_tab(i),
       l_kconversion_option_code_tab(i), l_knext_conversion_date_tab(i), l_kconversion_type_code_tab(i),
       l_kattribute_category_tab(i),l_kattribute1_tab(i), l_kattribute2_tab(i),
       l_kattribute3_tab(i), l_kattribute4_tab(i), l_kattribute5_tab(i),
       l_kattribute6_tab(i), l_kattribute7_tab(i), l_kattribute8_tab(i),
       l_kattribute9_tab(i), l_kattribute10_tab(i), l_kattribute11_tab(i),
       l_kattribute12_tab(i), l_kattribute13_tab(i), l_kattribute14_tab(i),
       l_kattribute15_tab(i), fnd_global.user_id, SYSDATE,
       fnd_global.user_id, SYSDATE, fnd_global.login_id,
       l_kcatchup_frequency_code_tab(i)
      );
  END IF;

EXCEPTION WHEN OTHERS THEN

  --x_return_status := OKL_API.G_RET_STS_ERROR;
    /* DEBUG */
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'sqlcode=' || SQLCODE || ':sqlerrm=' || SQLERRM);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Printing copy_var_int_rate_params:l_kkhr_id_tab.count=' || l_kkhr_id_tab.COUNT || ' ...');
  END IF;
  IF (l_kkhr_id_tab.COUNT > 0) THEN
  FOR i IN l_kkhr_id_tab.first..l_kkhr_id_tab.last
  LOOP
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'KHR_ID('||i||')=' || l_kKHR_ID_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PARAMETER_TYPE_CODE('||i||')=' || l_kPARAMETER_TYPE_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'EFFECTIVE_FROM_DATE('||i||')=' || l_kEFFECTIVE_FROM_DATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'EFFECTIVE_TO_DATE('||i||')=' || l_kEFFECTIVE_TO_DATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'INTEREST_INDEX_ID('||i||')=' || l_kINTEREST_INDEX_ID_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'BASE_RATE('||i||')=' || l_kBASE_RATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'INTEREST_START_DATE('||i||')=' || l_kINTEREST_START_DATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ADDER_RATE('||i||')=' || l_kADDER_RATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'MAXIMUM_RATE('||i||')=' || l_kMAXIMUM_RATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'MINIMUM_RATE('||i||')=' || l_kMINIMUM_RATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PRINCIPAL_BASIS_CODE('||i||')=' || l_kPRINCIPAL_BASIS_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'DAYS_IN_A_MONTH_CODE('||i||')=' || l_kDAYS_IN_A_MONTH_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'DAYS_IN_A_YEAR_CODE('||i||')=' || l_kDAYS_IN_A_YEAR_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'INTEREST_BASIS_CODE('||i||')=' || l_kINTEREST_BASIS_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'RATE_DELAY_CODE('||i||')=' || l_kRATE_DELAY_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'RATE_DELAY_FREQUENCY('||i||')=' || l_kRATE_DELAY_FREQUENCY_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'COMPOUNDING_FREQUENCY_CODE('||i||')=' || l_kCOMPOUNDING_FREQU_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CALCULATION_FORMULA_ID('||i||')=' || l_kCALCULATION_FORMULA_ID_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CATCHUP_BASIS_CODE('||i||')=' || l_kCATCHUP_BASIS_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CATCHUP_START_DATE('||i||')=' || l_kCATCHUP_START_DATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CATCHUP_SETTLEMENT_CODE('||i||')=' || l_kCATCHUP_SETTLEMEN_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'RATE_CHANGE_START_DATE('||i||')=' || l_kRATE_CHANGE_START_DATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'RATE_CHANGE_FREQUENCY_CODE('||i||')=' || l_kRATE_CHANGE_FREQU_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'RATE_CHANGE_VALUE('||i||')=' || l_kRATE_CHANGE_VALUE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CONVERSION_OPTION_CODE('||i||')=' || l_kCONVERSION_OPTION_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'NEXT_CONVERSION_DATE('||i||')=' || l_kNEXT_CONVERSION_DATE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CONVERSION_TYPE_CODE('||i||')=' || l_kCONVERSION_TYPE_CODE_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE_CATEGORY('||i||')=' || l_kATTRIBUTE_CATEGORY_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE1('||i||')=' || l_kATTRIBUTE1_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE2('||i||')=' || l_kATTRIBUTE2_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE3('||i||')=' || l_kATTRIBUTE3_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE4('||i||')=' || l_kATTRIBUTE4_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE5('||i||')=' || l_kATTRIBUTE5_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE6('||i||')=' || l_kATTRIBUTE6_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE7('||i||')=' || l_kATTRIBUTE7_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE8('||i||')=' || l_kATTRIBUTE8_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE9('||i||')=' || l_kATTRIBUTE9_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE10('||i||')=' || l_kATTRIBUTE10_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE11('||i||')=' || l_kATTRIBUTE11_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE12('||i||')=' || l_kATTRIBUTE12_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE13('||i||')=' || l_kATTRIBUTE13_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE14('||i||')=' || l_kATTRIBUTE14_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ATTRIBUTE15('||i||')=' || l_kATTRIBUTE15_tab(i));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CATCHUP_FREQUENCY_CODE('||i||')=' || l_kCATCHUP_FREQUENCY_CODE_tab(i));
    END IF;
  END LOOP;
  END IF;

  RAISE OKC_API.G_EXCEPTION_ERROR;
END SYNC_RATE_PARAMS;

PROCEDURE check_base_rate(
                             p_khr_id            IN NUMBER,
                             x_base_rate_defined OUT NOCOPY BOOLEAN,
                             x_return_status     OUT NOCOPY VARCHAR2) IS
CURSOR base_rate_csr(p_id NUMBER) IS
SELECT base_rate
FROM   OKL_K_RATE_PARAMS
WHERE  KHR_ID = p_id
AND    PARAMETER_TYPE_CODE = 'ACTUAL'
AND    EFFECTIVE_TO_DATE IS NULL;

l_base_rate NUMBER := NULL;
BEGIN
  NULL;
  OPEN base_rate_csr(p_khr_id);
  FETCH base_rate_csr
  INTO  l_base_rate;
  CLOSE base_rate_csr;

  IF (l_base_rate IS NULL OR
      l_base_rate = OKL_API.G_MISS_NUM) THEN
    x_base_rate_defined := FALSE;
  ELSE
    x_base_rate_defined := TRUE;
  END IF;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN -- Bug 4905142
      x_base_rate_defined := FALSE;
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_base_rate_defined := FALSE;
END;

PROCEDURE check_principal_payment(
            p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_chr_id                  IN OKC_K_HEADERS_B.ID%TYPE,
            x_principal_payment_defined  OUT NOCOPY BOOLEAN) IS

cursor l_hdrrl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                    rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                    chrId NUMBER) IS
    SELECT crl.object1_id1
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    WHERE  crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

CURSOR strm_name_csr ( styid NUMBER ) is
    SELECT tl.name name,
           stm.stream_type_purpose
    FROM okl_strm_type_b stm,
         OKL_STRM_TYPE_TL tl
    WHERE tl.id = stm.id
         AND tl.language = 'US'
         AND stm.id = styid;

l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
l_strm_name_rec strm_name_csr%ROWTYPE;
l_api_version NUMBER := 1;
l_api_name VARCHAR2(30) := 'check_principal_payment';

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_principal_payment_defined := FALSE;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    FOR l_hdrrl_rec in l_hdrrl_csr ( 'LALEVL', 'LASLH', p_chr_id )
    LOOP
        OPEN  strm_name_csr ( l_hdrrl_rec.object1_id1 );
        FETCH strm_name_csr into l_strm_name_rec;
        IF strm_name_csr%NOTFOUND THEN
            CLOSE strm_name_csr;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        CLOSE strm_name_csr;

        IF ( l_strm_name_rec.stream_type_purpose = 'PRINCIPAL_PAYMENT' ) Then
          x_principal_payment_defined := TRUE;
        END IF;
    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END;

FUNCTION get_formula_id(p_name IN VARCHAR2) RETURN NUMBER IS
l_formula_id number := NULL;
begin
  IF (p_name is NOT NULL) THEN
    --RETURN(NULL);
  --ELSE
    select id
    INTO   l_formula_id
    FROM   OKL_FORMULAE_B
    WHERE  NAME = p_name;

  END IF;
  return(l_formula_id);
end;

PROCEDURE copy_k_rate_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_id                       IN  NUMBER,
    p_effective_from_date          IN  DATE,
    p_rate_type                    IN  VARCHAR2,
    x_krpv_rec                     OUT NOCOPY krpv_rec_type) IS

l_effective_from_date DATE;
l_parameter_type_code VARCHAR2(30);
l_orig_system_source_code VARCHAR2(30);
l_orig_system_id1 NUMBER;
l_orig_effective_from_date DATE;
l_last_interest_cal_date DATE;
l_api_name varchar2(240) := 'copy_k_rate_params';
l_krpv_rec krpv_rec_type;

CURSOR get_effective_from_date_csr(
          p_khr_id NUMBER,
          p_parameter_type_code VARCHAR2) IS
select rate.effective_from_date,
       contract.orig_system_source_code,
       lease.date_last_interim_interest_cal,
       contract.orig_system_id1
FROM   OKL_K_RATE_PARAMS rate,
       OKC_K_HEADERS_B contract,
       OKL_K_HEADERS lease
WHERE  rate.khr_id = p_khr_id
AND    rate.parameter_type_code =  p_parameter_type_code
AND    rate.effective_to_date is null
AND    rate.khr_id = contract.id
AND    contract.id = lease.id;

-- Bug 4999888
 l_interest_calc_basis OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE;
 l_rev_recog_method OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE;
 l_pdt_params_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

     --Cursor to query the last billed due date of the stream.
     CURSOR get_last_billed_due_date(
               p_chr_id OKC_K_HEADERS_B.ID%TYPE
             , p_stream_purpose OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%TYPE) IS
       SELECT
           MAX(STE.STREAM_ELEMENT_DATE) LAST_STREAM_DUE_DATE
           --, STY.STYB_PURPOSE_MEANING
         FROM
            OKL_STRM_ELEMENTS STE
          , OKL_STREAMS       STM
          , OKL_STRM_TYPE_V   STY
          , OKL_K_HEADERS     KHR
          , OKC_K_HEADERS_B CHR
        WHERE
            STM.ID         = STE.STM_ID
        AND STY.ID         = STM.STY_ID
        AND KHR.ID         = STM.KHR_ID
        AND CHR.ID         = KHR.ID
        AND STE.DATE_BILLED IS NOT NULL
        AND CHR.ID         = p_chr_id
        AND STY.STREAM_TYPE_PURPOSE  = p_stream_purpose;
        --GROUP BY STY.STREAM_TYPE_PURPOSE;

  l_last_billed_due_date DATE;
BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => 1,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    OKL_K_RATE_PARAMS_PVT.get_product(
                p_api_version       => p_api_version,
                p_init_msg_list     => p_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_khr_id            => p_khr_id,
                x_pdt_parameter_rec => l_pdt_params_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    l_interest_calc_basis := l_pdt_params_rec.interest_calculation_basis;
    l_rev_recog_method    := l_pdt_params_rec.revenue_recognition_method;

    -- AKP: todo (change actual lookup values)
    IF (p_rate_type IN ('INTEREST_RATE_PARAMS', 'ADDL_INTEREST_RATE_PARAMS', 'CONVERSION_BASIS')) THEN
      l_parameter_type_code := 'ACTUAL';
    ELSIF (p_rate_type IN ('INTEREST_RATE_PARAMS_CONV', 'ADDL_INTEREST_RATE_PARAMS_CONV')) THEN
      l_parameter_type_code := 'CONVERSION';
    ELSE
      OKC_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_LLA_VAR_RATE_INV_PARAM');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_effective_from_date := null;
    FOR r IN get_effective_from_date_csr(p_khr_id, l_parameter_type_code)
    LOOP
      l_effective_from_date := r.effective_from_date;
      l_orig_system_source_code := r.orig_system_source_code;
      l_last_interest_cal_date := r.date_last_interim_interest_cal;
      l_orig_system_id1 := r.orig_system_id1;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:p_khr_id=' || p_khr_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:l_parameter_type_code=' || l_parameter_type_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:l_effective_from_date=' || l_effective_from_date);
    END IF;
    IF (l_effective_from_date is NULL) THEN
      l_krpv_rec.effective_from_date := NULL;
      x_krpv_rec := l_krpv_rec;
      OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data);
      return;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:l_orig_system_source_code=' || l_orig_system_source_code);
    END IF;
    IF (l_orig_system_source_code <> 'OKL_REBOOK') THEN
      OKC_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_LLA_VAR_RATE_COPY_NA');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug 4999888
    IF (l_interest_calc_basis = 'FIXED' and l_rev_recog_method='ACTUAL') THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:Inside FIXED and ACTUAL...');
      END IF;
      OPEN get_last_billed_due_date(l_orig_system_id1, 'LOAN_PAYMENT');
      FETCH get_last_billed_due_date
        INTO l_last_billed_due_date;
      CLOSE get_last_billed_due_date;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_last_billed_due_date=' || l_last_billed_due_date);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_effective_from_date=' || p_effective_from_date);
      END IF;
      IF (l_last_billed_due_date IS NOT NULL AND
            p_effective_from_date <= l_last_billed_due_date) THEN
        OKC_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_LLA_VAR_RATE_INT_DATE',
                            p_token1 => 'EFF_DATE',
                            p_token1_value => p_effective_from_date,
                            p_token2 => 'INTEREST_DATE',
                            p_token2_value => l_last_billed_due_date);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Bug 4999888
    IF (l_interest_calc_basis IN
         ('FLOAT', 'REAMORT', 'FLOAT_FACTORS', 'CATCHUP/CLEANUP')) THEN
    IF (l_last_interest_cal_date IS NOT NULL) THEN
      IF (p_effective_from_date <= l_last_interest_cal_date) THEN
      OKC_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_LLA_VAR_RATE_INT_DATE',
                          p_token1 => 'EFF_DATE',
                          p_token1_value => p_effective_from_date,
                          p_token2 => 'INTEREST_DATE',
                          p_token2_value => l_last_interest_cal_date);
      RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    END IF;

    FOR r IN get_effective_from_date_csr(l_orig_system_id1,
                                         l_parameter_type_code)
    LOOP
      l_orig_effective_from_date := r.effective_from_date;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:l_orig_system_id1=' || l_orig_system_id1);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:l_effective_from_date=' || l_effective_from_date);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:l_orig_effective_from_date=' || l_orig_effective_from_date);
    END IF;
    IF (l_orig_effective_from_date <> l_effective_from_date) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'copy:Yes, inside...');
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      OKC_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_LLA_VAR_RATE_EXISTS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT
    KHR_ID, l_parameter_type_code, p_effective_from_date,
      EFFECTIVE_TO_DATE, INTEREST_INDEX_ID, BASE_RATE,
      INTEREST_START_DATE, ADDER_RATE, MAXIMUM_RATE,
      MINIMUM_RATE, PRINCIPAL_BASIS_CODE, DAYS_IN_A_MONTH_CODE,
      DAYS_IN_A_YEAR_CODE, INTEREST_BASIS_CODE, RATE_DELAY_CODE,
      RATE_DELAY_FREQUENCY, COMPOUNDING_FREQUENCY_CODE, CALCULATION_FORMULA_ID,
      CATCHUP_BASIS_CODE, CATCHUP_START_DATE, CATCHUP_SETTLEMENT_CODE,
      RATE_CHANGE_START_DATE, RATE_CHANGE_FREQUENCY_CODE, RATE_CHANGE_VALUE,
      CONVERSION_OPTION_CODE, NEXT_CONVERSION_DATE, CONVERSION_TYPE_CODE,
      ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
      ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
      ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
      ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
      ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
      ATTRIBUTE15, fnd_global.user_id, SYSDATE,
      fnd_global.user_id, SYSDATE, fnd_global.user_id,
      CATCHUP_FREQUENCY_CODE
    INTO
      x_krpv_rec.KHR_ID, x_krpv_rec.parameter_type_code, x_krpv_rec.effective_from_date,
      x_krpv_rec.EFFECTIVE_TO_DATE, x_krpv_rec.INTEREST_INDEX_ID, x_krpv_rec.BASE_RATE,
      x_krpv_rec.INTEREST_START_DATE, x_krpv_rec.ADDER_RATE, x_krpv_rec.MAXIMUM_RATE,
      x_krpv_rec.MINIMUM_RATE, x_krpv_rec.PRINCIPAL_BASIS_CODE, x_krpv_rec.DAYS_IN_A_MONTH_CODE,
      x_krpv_rec.DAYS_IN_A_YEAR_CODE, x_krpv_rec.INTEREST_BASIS_CODE, x_krpv_rec.RATE_DELAY_CODE,
      x_krpv_rec.RATE_DELAY_FREQUENCY, x_krpv_rec.COMPOUNDING_FREQUENCY_CODE, x_krpv_rec.CALCULATION_FORMULA_ID,
      x_krpv_rec.CATCHUP_BASIS_CODE, x_krpv_rec.CATCHUP_START_DATE, x_krpv_rec.CATCHUP_SETTLEMENT_CODE,
      x_krpv_rec.RATE_CHANGE_START_DATE, x_krpv_rec.RATE_CHANGE_FREQUENCY_CODE, x_krpv_rec.RATE_CHANGE_VALUE,
      x_krpv_rec.CONVERSION_OPTION_CODE, x_krpv_rec.NEXT_CONVERSION_DATE, x_krpv_rec.CONVERSION_TYPE_CODE,
      x_krpv_rec.ATTRIBUTE_CATEGORY, x_krpv_rec.ATTRIBUTE1, x_krpv_rec.ATTRIBUTE2,
      x_krpv_rec.ATTRIBUTE3, x_krpv_rec.ATTRIBUTE4, x_krpv_rec.ATTRIBUTE5,
      x_krpv_rec.ATTRIBUTE6, x_krpv_rec.ATTRIBUTE7, x_krpv_rec.ATTRIBUTE8,
      x_krpv_rec.ATTRIBUTE9, x_krpv_rec.ATTRIBUTE10, x_krpv_rec.ATTRIBUTE11,
      x_krpv_rec.ATTRIBUTE12, x_krpv_rec.ATTRIBUTE13, x_krpv_rec.ATTRIBUTE14,
      x_krpv_rec.ATTRIBUTE15, x_krpv_rec.CREATED_BY, x_krpv_rec.CREATION_DATE,
      x_krpv_rec.LAST_UPDATED_BY, x_krpv_rec.LAST_UPDATE_DATE, x_krpv_rec.LAST_UPDATE_LOGIN,
      x_krpv_rec.CATCHUP_FREQUENCY_CODE
    FROM  OKL_K_RATE_PARAMS
    WHERE KHR_ID = p_khr_id
    AND   PARAMETER_TYPE_CODE = l_parameter_type_code
    AND   EFFECTIVE_FROM_DATE = l_effective_from_date
    AND   EFFECTIVE_TO_DATE IS NULL;

    INSERT INTO OKL_K_RATE_PARAMS (
      KHR_ID, PARAMETER_TYPE_CODE, EFFECTIVE_FROM_DATE,
      EFFECTIVE_TO_DATE, INTEREST_INDEX_ID, BASE_RATE,
      INTEREST_START_DATE, ADDER_RATE, MAXIMUM_RATE,
      MINIMUM_RATE, PRINCIPAL_BASIS_CODE, DAYS_IN_A_MONTH_CODE,
      DAYS_IN_A_YEAR_CODE, INTEREST_BASIS_CODE, RATE_DELAY_CODE,
      RATE_DELAY_FREQUENCY, COMPOUNDING_FREQUENCY_CODE, CALCULATION_FORMULA_ID,
      CATCHUP_BASIS_CODE, CATCHUP_START_DATE, CATCHUP_SETTLEMENT_CODE,
      RATE_CHANGE_START_DATE, RATE_CHANGE_FREQUENCY_CODE, RATE_CHANGE_VALUE,
      CONVERSION_OPTION_CODE, NEXT_CONVERSION_DATE, CONVERSION_TYPE_CODE,
      ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
      ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
      ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
      ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
      ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
      ATTRIBUTE15, CREATED_BY, CREATION_DATE,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CATCHUP_FREQUENCY_CODE
    )
    VALUES (
      x_krpv_rec.KHR_ID, x_krpv_rec.parameter_type_code, x_krpv_rec.effective_from_date,
      x_krpv_rec.EFFECTIVE_TO_DATE, x_krpv_rec.INTEREST_INDEX_ID, x_krpv_rec.BASE_RATE,
      x_krpv_rec.INTEREST_START_DATE, x_krpv_rec.ADDER_RATE, x_krpv_rec.MAXIMUM_RATE,
      x_krpv_rec.MINIMUM_RATE, x_krpv_rec.PRINCIPAL_BASIS_CODE, x_krpv_rec.DAYS_IN_A_MONTH_CODE,
      x_krpv_rec.DAYS_IN_A_YEAR_CODE, x_krpv_rec.INTEREST_BASIS_CODE, x_krpv_rec.RATE_DELAY_CODE,
      x_krpv_rec.RATE_DELAY_FREQUENCY, x_krpv_rec.COMPOUNDING_FREQUENCY_CODE, x_krpv_rec.CALCULATION_FORMULA_ID,
      x_krpv_rec.CATCHUP_BASIS_CODE, x_krpv_rec.CATCHUP_START_DATE, x_krpv_rec.CATCHUP_SETTLEMENT_CODE,
      x_krpv_rec.RATE_CHANGE_START_DATE, x_krpv_rec.RATE_CHANGE_FREQUENCY_CODE, x_krpv_rec.RATE_CHANGE_VALUE,
      x_krpv_rec.CONVERSION_OPTION_CODE, x_krpv_rec.NEXT_CONVERSION_DATE, x_krpv_rec.CONVERSION_TYPE_CODE,
      x_krpv_rec.ATTRIBUTE_CATEGORY, x_krpv_rec.ATTRIBUTE1, x_krpv_rec.ATTRIBUTE2,
      x_krpv_rec.ATTRIBUTE3, x_krpv_rec.ATTRIBUTE4, x_krpv_rec.ATTRIBUTE5,
      x_krpv_rec.ATTRIBUTE6, x_krpv_rec.ATTRIBUTE7, x_krpv_rec.ATTRIBUTE8,
      x_krpv_rec.ATTRIBUTE9, x_krpv_rec.ATTRIBUTE10, x_krpv_rec.ATTRIBUTE11,
      x_krpv_rec.ATTRIBUTE12, x_krpv_rec.ATTRIBUTE13, x_krpv_rec.ATTRIBUTE14,
      x_krpv_rec.ATTRIBUTE15, x_krpv_rec.CREATED_BY, x_krpv_rec.CREATION_DATE,
      x_krpv_rec.LAST_UPDATED_BY, x_krpv_rec.LAST_UPDATE_DATE, x_krpv_rec.LAST_UPDATE_LOGIN,
      x_krpv_rec.CATCHUP_FREQUENCY_CODE);

    UPDATE  OKL_K_RATE_PARAMS
    SET   EFFECTIVE_TO_DATE = p_effective_from_date - 1
    WHERE KHR_ID = p_khr_id
    AND   PARAMETER_TYPE_CODE = l_parameter_type_code
    AND   EFFECTIVE_FROM_DATE = l_effective_from_date
    AND   EFFECTIVE_TO_DATE IS NULL;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END;

-- Bug 4917614
PROCEDURE SYNC_BASE_RATE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS
CURSOR implicit_interest_rate_csr(p_id NUMBER) IS
       SELECT IMPLICIT_INTEREST_RATE
       FROM   OKL_K_HEADERS
       WHERE  ID = p_id;

l_base_count NUMBER;
l_api_name varchar2(240) := 'sync_base_rate';
l_implicit_interest_rate NUMBER;
BEGIN
  NULL;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Sync_base_rate procedure...');
  END IF;
  x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => 1,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

  SELECT COUNT(1)
  INTO   l_base_count
  FROM   OKL_K_RATE_PARAMS
  WHERE  khr_id = p_khr_id
  AND    PARAMETER_TYPE_CODE = 'ACTUAL'
  AND    EFFECTIVE_TO_DATE IS NULL
  AND    BASE_RATE IS NULL;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_base_count=' || l_base_count);
  END IF;
  IF (l_base_count > 0) THEN
    OPEN implicit_interest_rate_csr(p_khr_id);
    FETCH implicit_interest_rate_csr INTO l_implicit_interest_rate;
    CLOSE implicit_interest_rate_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_implicit_interest_rate=' || l_implicit_interest_rate);
    END IF;
    UPDATE OKL_K_RATE_PARAMS
    SET    BASE_RATE = l_implicit_interest_rate
    WHERE  khr_id = p_khr_id
    AND    PARAMETER_TYPE_CODE = 'ACTUAL'
    AND    EFFECTIVE_TO_DATE IS NULL
    AND    BASE_RATE IS NULL;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

  EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END;

END OKL_K_RATE_PARAMS_PVT;

/
