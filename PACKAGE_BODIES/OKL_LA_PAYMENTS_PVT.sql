--------------------------------------------------------
--  DDL for Package Body OKL_LA_PAYMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_PAYMENTS_PVT" as
/* $Header: OKLRPYTB.pls 120.35.12010000.6 2009/01/22 09:22:09 nikshah ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

--G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
--G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_PROCESSING    exception;
G_EXCEPTION_STOP_VALIDATION    exception;


G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_LA_PAYMENTS_PVT';
G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
l_api_name    VARCHAR2(35)    := 'LA_PAYMENTS';

l_detail_count NUMBER := 0;
l_payment_code varchar2(150) := null;

-- start: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement
 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

-- start: Sept 02, 2005 cklee: Modification for GE - 20 variable rate ER
 G_OKL_LLA_VAR_RATE_ERROR  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_ERROR';
 G_LEASE_TYPE              CONSTANT VARCHAR2(30) := 'LEASE_TYPE';
 G_INT_BASIS               CONSTANT VARCHAR2(30) := 'INT_BASIS';
 G_OKL_LLA_VAR_RATE_PAYMENT1  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_PAYMENT1';
 G_OKL_LLA_VAR_RATE_PAYMENT2  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_PAYMENT2';
 G_OKL_LLA_VAR_RATE_PAYMENT3  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_PAYMENT3';
 G_OKL_LLA_VAR_RATE_PAYMENT4  CONSTANT VARCHAR2(30) := 'OKL_LLA_VAR_RATE_PAYMENT4';
-- end: Sept 02, 2005 cklee: Modification for GE - 20 variable rate ER

  -- start: 07-25-2005 cklee/mvasudev -- Fixed Bug#4392051/okl.h 4437938
    CURSOR l_okl_sll_count_csr(p_rgp_id     IN NUMBER,
                         p_chr_id     IN NUMBER,
                         p_slh_id     IN VARCHAR2)
	IS
    SELECT COUNT(1)
    FROM   okc_rules_b sll
    WHERE  sll.dnz_chr_id = p_chr_id
    AND    sll.rgp_id = p_rgp_id
    AND    sll.rule_information_category  = 'LASLL' --| 17-Jan-06 cklee Fixed bug#4956483                                           |
    AND    sll.object2_id1 = p_slh_id;
  -- end: 07-25-2005 cklee/mvasudev -- Fixed Bug#4392051/okl.h 4437938

  -- Authoring OA Migration
  --------------------------------------------------------------------------
  ----- Check if the payment is for an Upfront Tax Fee line
  --------------------------------------------------------------------------
  FUNCTION is_upfront_tax_fee_payment(p_chr_id IN  NUMBER,
                                      p_cle_id IN  NUMBER)
  RETURN VARCHAR2 IS

    CURSOR l_fee_csr(p_cle_id IN NUMBER) IS
    SELECT kle.fee_purpose_code
    FROM okl_k_lines kle
    WHERE kle.id = p_cle_id;

    l_fee_rec l_fee_csr%ROWTYPE;

    l_ret_value VARCHAR2(1);

  BEGIN

    l_ret_value := OKL_API.G_FALSE;

    OPEN l_fee_csr(p_cle_id => p_cle_id);
    FETCH l_fee_csr INTO l_fee_rec;
    CLOSE l_fee_csr;

    IF l_fee_rec.fee_purpose_code = 'SALESTAX' THEN
      l_ret_value := OKL_API.G_TRUE;
    END IF;

    RETURN l_ret_value;

  END is_upfront_tax_fee_payment;

  --------------------------------------------------------------------------
  -- Perform Upfront Tax Fee Payment validations and update booking status
  --------------------------------------------------------------------------
  PROCEDURE process_upfront_tax_pymt(
    p_api_version     IN  NUMBER,
    p_init_msg_list   IN  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    p_chr_id          OKC_K_HEADERS_B.ID%TYPE) IS

    l_upfront_tax_prog_sts OKL_BOOK_CONTROLLER_TRX.progress_status%TYPE;

  BEGIN

      -- Validate upfront tax fee payments
      OKL_LA_SALES_TAX_PVT.validate_upfront_tax_fee(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_chr_id          => p_chr_id);

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_upfront_tax_prog_sts := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR;
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      ELSE
        l_upfront_tax_prog_sts := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
      END IF;

      --Update Contract Status to Passed
      OKL_CONTRACT_STATUS_PUB.update_contract_status(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_khr_status    => 'PASSED',
        p_chr_id        => p_chr_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --call to cascade status on to lines
      OKL_CONTRACT_STATUS_PUB.cascade_lease_status
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => p_chr_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Update status of Validate Contract process to Complete
      OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_khr_id             => p_chr_id ,
        p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_VALIDATE_CONTRACT ,
        p_progress_status    => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Update status of Calculate Upfront Tax process to Complete or Error
      -- based on the results of OKL_LA_SALES_TAX_PVT.validate_upfront_tax_fee
      OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_khr_id             => p_chr_id ,
        p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_CALC_UPFRONT_TAX ,
        p_progress_status    => l_upfront_tax_prog_sts);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END process_upfront_tax_pymt;

  --Bug# 7440232
  --------------------------------------------------------------------------
  -- Delete Interest Rate parameters if the Interest Calculation Basis is
  -- Fixed, Revenue Recognition Method is Streams and there are no Principal
  -- Payments defined
  --------------------------------------------------------------------------
  PROCEDURE delete_interest_rate_params(
    p_api_version     IN  NUMBER,
    p_init_msg_list   IN  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    p_chr_id          OKC_K_HEADERS_B.ID%TYPE) IS

    CURSOR c_rates_csr(p_chr_id IN NUMBER,
                       p_parameter_type_code IN VARCHAR2) IS
    SELECT rate.effective_from_date
    FROM   okl_k_rate_params rate
    WHERE  rate.khr_id = p_chr_id
    AND    rate.parameter_type_code = p_parameter_type_code;

    CURSOR c_principal_pymts_yn(p_chr_id IN NUMBER) IS
    SELECT 'Y'
    FROM okc_rule_groups_b rgp,
         okc_rules_b rul,
         okl_strm_type_b sty,
         okc_k_lines_b cle
    WHERE rgp.rgd_code = 'LALEVL'
    AND rgp.dnz_chr_id = p_chr_id
    AND rul.dnz_chr_id = rgp.dnz_chr_id
    AND rul.rgp_id = rgp.id
    AND rul.rule_information_category = 'LASLH'
    AND rul.object1_id1 = sty.id
    AND rul.jtot_object1_code = 'OKL_STRMTYP'
    AND sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
    AND rgp.cle_id = cle.id (+)
    AND cle.sts_code (+) <> 'ABANDONED';

    l_principal_pymts_yn VARCHAR2(1);
    l_count              NUMBER;
    l_krpdel_tbl         OKL_K_RATE_PARAMS_PVT.krpdel_tbl_type;
    l_pdt_params_rec     OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

  BEGIN

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

     IF (l_pdt_params_rec.interest_calculation_basis = 'FIXED' AND
         l_pdt_params_rec.revenue_recognition_method = 'STREAMS') THEN

       l_principal_pymts_yn := 'N';
       OPEN c_principal_pymts_yn(p_chr_id => p_chr_id);
       FETCH c_principal_pymts_yn INTO l_principal_pymts_yn;
       CLOSE c_principal_pymts_yn;

       IF (l_principal_pymts_yn = 'N') THEN

         l_count := 0;
         FOR l_rates_rec IN c_rates_csr(p_chr_id, 'ACTUAL') LOOP
           l_count := l_count + 1;
           l_krpdel_tbl(l_count).khr_id := p_chr_id;
           l_krpdel_tbl(l_count).effective_from_date := l_rates_rec.effective_from_date;
           l_krpdel_tbl(l_count).rate_type := 'INTEREST_RATE_PARAMS';
         END LOOP;

         IF l_count > 0 THEN
           OKL_K_RATE_PARAMS_PVT.delete_k_rate_params(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_krpdel_tbl     => l_krpdel_tbl);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
       END IF;
     END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END delete_interest_rate_params;

-- start: Sept 02, 2005 cklee: Modification for GE - 20 variable rate ER
  --------------------------------------------------------------------------
  ----- Validate stream/payment type for an asset line
  --------------------------------------------------------------------------
  FUNCTION validate_payment_type_asset
                       (p_chr_id         number,
                        p_asset_id       number,
                        p_service_fee_id number,
                        p_payment_id     number
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_api_version       NUMBER	:= 1.0;
    x_msg_count		NUMBER;
    x_msg_data    	VARCHAR2(4000);
    l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;

    l_stream_type_purpose OKL_STRM_TYPE_V.STREAM_TYPE_PURPOSE%type;

    l_book_class            OKL_PRODUCT_PARAMETERS_V.DEAL_TYPE%TYPE;
    l_interest_calc_basis   OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE;

    l_pdt_params_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

   CURSOR c_stream_type_purpose (p_sty_id number)
    IS
    SELECT sty.STREAM_TYPE_PURPOSE
      FROM OKL_STRM_TYPE_V sty
     WHERE sty.ID = p_sty_id
    ;

  BEGIN

    -- check only if it's an asset line payment
    IF (p_asset_id IS NOT NULL AND
        p_asset_id <> OKL_API.G_MISS_NUM)
        AND
       (p_service_fee_id IS NULL OR
        p_service_fee_id = OKL_API.G_MISS_NUM)
    THEN

      -- get stream type purpose code
      open c_stream_type_purpose(p_payment_id);
      fetch c_stream_type_purpose into l_stream_type_purpose;
      close c_stream_type_purpose;

      -- get product information: Book classification and interest_calc_basis
      OKL_K_RATE_PARAMS_PVT.get_product(
                p_api_version       => l_api_version,
                p_init_msg_list     => l_init_msg_list,
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

      -- scenario 1:
      -- Book Classification: Operating Lease, Direct Finance Lease, Sales Type Lease
      -- Interest Calculation Basis: Fixed, Reamort, Float Factors
      -- Payment/Stream Type Not in the following: Rent, Estimated Property Tax, and Down Payment
      IF l_book_class IN ('LEASEOP', 'LEASEDF', 'LEASEST') AND
         l_interest_calc_basis IN  ('FIXED','FLOAT_FACTORS', 'REAMORT') AND
         l_stream_type_purpose NOT IN ('RENT', 'ESTIMATED_PROPERTY_TAX', 'DOWN_PAYMENT') THEN

          OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_VAR_RATE_PAYMENT1);

          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- scenario 2:
      -- Book Classification: Loan
      -- Interest Calculation Basis: Fixed, Float, Catchup / Cleanup, and Reamort
      -- Payment/Stream Type Not in the following: Rent, Estimated Property Tax, Down Payment, and Principal Payment
      --modified by rkuttiya for bug # 7498330 to include unscheduled principal
      -- payment unscheduled loan payment
      IF l_book_class = 'LOAN' AND
         l_interest_calc_basis IN  ('FIXED','FLOAT', 'CATCHUP/CLEANUP',  'REAMORT') AND
         l_stream_type_purpose NOT IN ('RENT', 'ESTIMATED_PROPERTY_TAX', 'DOWN_PAYMENT', 'PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT','UNSCHEDULED_LOAN_PAYMENT') THEN

          OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_VAR_RATE_PAYMENT2);

          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- scenario 3:
      -- Book Classification: Loan-Revolving
      -- Interest Calculation Basis: Float
      -- Payment/Stream Type is not null
      IF l_book_class = 'LOAN-REVOLVING' AND
         l_interest_calc_basis IN  ('FLOAT') AND
         l_stream_type_purpose IS NOT NULL THEN

          OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_OKL_LLA_VAR_RATE_PAYMENT3);

          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- scenario 4:
      -- Book Classification: Loan
      -- Interest Calculation Basis: Fixed, Float, Catchup / Cleanup, and Reamort
      -- Payment/Stream Type is Principal Payment
      IF l_book_class = 'LOAN' AND
         l_interest_calc_basis IN  ('FIXED','FLOAT', 'CATCHUP/CLEANUP',  'REAMORT') AND
         l_stream_type_purpose IN ('PRINCIPAL_PAYMENT') THEN

         IF NOT (NVL(okl_streams_util.get_pricing_engine(p_chr_id), 'INTERNAL') = 'EXTERNAL') THEN

           OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                               ,p_msg_name     => G_OKL_LLA_VAR_RATE_PAYMENT4);

           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

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
  END validate_payment_type_asset;
-- end: Sept 02, 2005 cklee: Modification for GE - 20 variable rate ER


-- start: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement
  --------------------------------------------------------------------------
  ----- Validate Capitalize for an asset line
  --------------------------------------------------------------------------
  FUNCTION validate_capitalize_dp
                       (p_asset_id       number,
                        p_service_fee_id number,
                        p_payment_id     number
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_downpayment_sty_found boolean := false;

   CURSOR c_is_donwpayment_sty (p_sty_id number)
    IS
    SELECT sty.STREAM_TYPE_PURPOSE
      FROM OKL_STRM_TYPE_V sty
     WHERE sty.ID = p_sty_id
    ;

   CURSOR c_is_capitalize (p_asset_id number)
    IS
    SELECT NVL(cle.CAPITALIZE_DOWN_PAYMENT_YN,'N') CAPITALIZE_DOWN_PAYMENT_YN,
           cle.DOWN_PAYMENT_RECEIVER_CODE
      FROM okl_k_lines cle
     WHERE cle.id = p_asset_id
    ;

  BEGIN

    FOR this_r IN c_is_donwpayment_sty(p_payment_id) LOOP

      -- check only if it's an asset line payment
      IF (p_asset_id IS NOT NULL AND
          p_asset_id <> OKL_API.G_MISS_NUM)
          AND
         (p_service_fee_id IS NULL OR
          p_service_fee_id = OKL_API.G_MISS_NUM)
      THEN

        IF (this_r.STREAM_TYPE_PURPOSE = 'DOWN_PAYMENT') THEN

          FOR this_row IN c_is_capitalize(p_asset_id) LOOP

            IF NOT(this_row.CAPITALIZE_DOWN_PAYMENT_YN = 'N' AND
                   this_row.DOWN_PAYMENT_RECEIVER_CODE = 'LESSOR') THEN
              OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LA_CAPITALIZE_DOWNPAYMENT');

              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
          END LOOP;  -- dummy loop, return one row only

        END IF;

      ELSE -- downpayemnt only allow for asset line payment

        IF (this_r.STREAM_TYPE_PURPOSE = 'DOWN_PAYMENT') THEN

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LA_DOWNPAYMENT_STY_CODE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      END IF;

    END LOOP; -- dummy loop, return one row only

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
  END validate_capitalize_dp;
-- end: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement


--  l_log VARCHAR2(25) := 'pym.log';
--  l_out varchar2(25) := 'pym.out';

FUNCTION get_lty_code(
    p_rgp_id                       IN  NUMBER)
    RETURN OKC_LINE_STYLES_V.LTY_CODE%TYPE IS
    l_lty_code OKC_LINE_STYLES_V.LTY_CODE%TYPE := null;
    cursor LINE_STYLE_CSR(P_RGP_ID IN NUMBER) is
    SELECT LS.LTY_CODE
    FROM
    OKC_RULE_GROUPS_V RG, OKL_K_LINES_V LN, OKC_LINE_STYLES_V LS
    WHERE
    RG.ID = P_RGP_ID AND
    RG.CLE_ID = LN.ID AND
    LN.ID = LS.ID;

    BEGIN
        open  LINE_STYLE_CSR(p_rgp_id);
        fetch LINE_STYLE_CSR into l_lty_code;
        close LINE_STYLE_CSR;
        return l_lty_code;
END get_lty_code;


FUNCTION get_sll_period_count(
    p_rgp_id                       IN  NUMBER,
    p_slh_id                       IN  VARCHAR2,
    p_chr_id                       IN  NUMBER)
    RETURN NUMBER IS
    l_count NUMBER := null;
    cursor SLL_CSR(P_RGP_ID IN NUMBER, P_SLH_ID IN VARCHAR2, P_CHR_ID IN NUMBER) is
    SELECT COUNT(1)
    FROM OKL_LA_PAYMENTS_UV
    WHERE RGP_ID = P_RGP_ID
    AND  OBJECT2_ID1 = P_SLH_ID
    AND  DNZ_CHR_ID = P_CHR_ID
    AND  RULE_INFORMATION3 IS NOT NULL
    AND  RULE_INFORMATION_CATEGORY = 'LASLL';

    BEGIN
        open  SLL_CSR(p_rgp_id, p_slh_id, p_chr_id);
        fetch SLL_CSR into l_count;
        close SLL_CSR;
        if(l_count is null) then
            l_count := 0;
        end if;
        return l_count;
END get_sll_period_count;


FUNCTION verify_sec_deposit_count(
    p_rgp_id                       IN  NUMBER,
    p_slh_id                       IN  VARCHAR2,
    p_chr_id                       IN  NUMBER)
    RETURN NUMBER IS
    l_count NUMBER := null;
    cursor SLL_CSR(P_RGP_ID IN NUMBER, P_SLH_ID IN VARCHAR2, P_CHR_ID IN NUMBER) is
    SELECT SUM(TO_NUMBER(nvl(RULE_INFORMATION3,0)))
    FROM OKL_LA_PAYMENTS_UV
    WHERE RGP_ID = P_RGP_ID
    AND  OBJECT2_ID1 = P_SLH_ID
    AND  DNZ_CHR_ID = P_CHR_ID
    AND  RULE_INFORMATION3 is not null
    AND  RULE_INFORMATION_CATEGORY = 'LASLL';

    BEGIN
        open  SLL_CSR(p_rgp_id, p_slh_id, p_chr_id);
        fetch SLL_CSR into l_count;
        close SLL_CSR;
        if(l_count is null) then
            l_count := 0;
        end if;
        return l_count;
END verify_sec_deposit_count;



FUNCTION get_payment_type(p_slh_id IN  VARCHAR2)
    RETURN VARCHAR2 IS
    l_payment_code varchar2(150) := null;
    l_slh_id number := null;
    cursor PAYMENT_TYPE_CSR(P_SLH_ID IN VARCHAR2) is
--    SELECT STRM.CODE
    SELECT STRM.STREAM_TYPE_PURPOSE
    FROM   OKC_RULES_B RUL,
           OKL_STRM_TYPE_B STRM
    WHERE RUL.ID = TO_NUMBER(P_SLH_ID)
    AND   STRM.ID = TO_NUMBER(RUL.OBJECT1_ID1);

    BEGIN
        if(p_slh_id is null or p_slh_id = '') then return ''; end if;
        open  PAYMENT_TYPE_CSR(p_slh_id);
        fetch PAYMENT_TYPE_CSR into l_payment_code;
        close PAYMENT_TYPE_CSR;
        return l_payment_code;
END get_payment_type;


-- next one function property taxes

FUNCTION is_prop_tax_payment(p_stream_id IN  VARCHAR2)
    RETURN BOOLEAN IS
    l_payment_code varchar2(150) := null;
    l_slh_id number := null;
    cursor PAYMENT_TYPE_CSR(P_ID IN VARCHAR2) is
    SELECT STRM.STREAM_TYPE_PURPOSE
    FROM   OKL_STRMTYP_SOURCE_V STRM
    WHERE  TO_CHAR(STRM.ID1) = P_ID;

    BEGIN
        if(p_stream_id is null or p_stream_id = '') then return false; end if;
        open  PAYMENT_TYPE_CSR(p_stream_id);
        fetch PAYMENT_TYPE_CSR into l_payment_code;
        close PAYMENT_TYPE_CSR;
        if(l_payment_code is not null and l_payment_code = 'ESTIMATED_PROPERTY_TAX') then
            return true;
        else
            return false;
        end if;
END is_prop_tax_payment;

FUNCTION is_ppd_payment(p_stream_id IN  VARCHAR2)
    RETURN BOOLEAN IS
    l_flag varchar2(1) := null;
    l_slh_id number := null;
    cursor PAYMENT_TYPE_CSR(P_ID IN VARCHAR2) is
    SELECT 'Y'
    FROM   OKL_STRMTYP_SOURCE_V STRM,
           OKC_RULES_B RL
    WHERE  RL.ID = P_ID
           AND TO_CHAR(STRM.ID1) = RL.OBJECT1_ID1
           AND STRM.STREAM_TYPE_PURPOSE = 'UNSCHEDULED_PRINCIPAL_PAYMENT';

    BEGIN
        if(p_stream_id is null or p_stream_id = '') then return false; end if;
        open  PAYMENT_TYPE_CSR(p_stream_id);
        fetch PAYMENT_TYPE_CSR into l_flag;
        close PAYMENT_TYPE_CSR;
        if(l_flag is not null and l_flag = 'Y') then
            return true;
        else
            return false;
        end if;
END is_ppd_payment;


------------------------------------------------------------------------------
  -- FUNCTION is_rollover_fee_payment
  --
  --  Function to check if the fee type of the fee top line is rollover.
  --
  -- Calls:
  -- Created By:  Manu 13-Sep-2004
  -- Called By:
------------------------------------------------------------------------------

  FUNCTION is_rollover_fee_payment(p_service_or_fee_id IN
                                 OKC_K_LINES_B.ID%TYPE) RETURN BOOLEAN IS

    l_fee_type VARCHAR2(150) := NULL;
    CURSOR fee_type_csr(P_ID IN OKC_K_LINES_B.ID%TYPE) IS
    SELECT FEE_TYPE FROM okc_k_lines_b CLEB, okl_k_lines KLE
    WHERE KLE.ID = P_ID
    AND KLE.ID = CLEB.ID;

  BEGIN
        IF (p_service_or_fee_id IS NULL OR p_service_or_fee_id = '') THEN
      RETURN FALSE;
    END IF;
        OPEN  fee_type_csr(p_service_or_fee_id);
        FETCH fee_type_csr into l_fee_type;
        CLOSE fee_type_csr;
        IF (l_fee_type IS NOT NULL AND l_fee_type = 'ROLLOVER') THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
  END is_rollover_fee_payment;

-- start: cklee: 06/22/05 -- okl.h
------------------------------------------------------------------------------
  -- FUNCTION is_eligible_fee_payment
  --
  --  Function to check if the fee type of the fee top line is eligible
  --
  -- Calls:
  -- Created By:  cklee
  -- Called By:
------------------------------------------------------------------------------

  FUNCTION is_eligible_fee_payment(p_service_or_fee_id IN
                                 OKC_K_LINES_B.ID%TYPE) RETURN BOOLEAN IS

    l_fee_type VARCHAR2(150) := NULL;
    CURSOR fee_type_csr(P_ID IN OKC_K_LINES_B.ID%TYPE) IS
    SELECT FEE_TYPE FROM okl_k_lines KLE
    WHERE KLE.ID = P_ID;

  BEGIN
        IF (p_service_or_fee_id IS NULL OR p_service_or_fee_id = '') THEN
      RETURN FALSE;
    END IF;
        OPEN  fee_type_csr(p_service_or_fee_id);
        FETCH fee_type_csr into l_fee_type;
        CLOSE fee_type_csr;
        IF (l_fee_type IS NOT NULL AND l_fee_type IN ('MISCELLANEOUS','PASSTHROUGH','SECDEPOSIT','INCOME','FINANCED','ROLLOVER')) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
  END is_eligible_fee_payment;

-- end: cklee: 6/22/05 -- okl.h


FUNCTION get_start_date(
    p_chr_id                       IN  NUMBER  := NULL,
    p_cle_id                       IN  NUMBER  := NULL,
    p_rgp_id                       IN  NUMBER  := NULL )
    RETURN DATE IS

    l_chr_id OKC_K_HEADERS_B.ID%TYPE    := p_chr_id;
    l_cle_id OKC_K_LINES_B.ID%TYPE      := p_cle_id;
    l_rgp_id OKC_RULE_GROUPS_B.ID%TYPE  := p_rgp_id;

    l_start_date date;

    cursor KHR_CSR(P_ID IN NUMBER) is
    SELECT START_DATE
    FROM
    OKC_K_HEADERS_B
    WHERE
    ID = P_ID;

    cursor CLE_CSR(P_ID IN NUMBER) is
    SELECT START_DATE
    FROM
    OKC_K_LINES_B
    WHERE
    ID = P_ID;

    cursor RGP_CSR(P_ID IN NUMBER) is
    SELECT DNZ_CHR_ID, CLE_ID
    FROM
    OKC_RULE_GROUPS_B
    WHERE
    ID = P_ID;

    BEGIN

--        if(l_rgp_id is not null and l_rgp_id <> OKL_API.G_MISS_NUM) then
        if(l_rgp_id is not null) then
            open  RGP_CSR(l_rgp_id);
                fetch RGP_CSR into l_chr_id, l_cle_id;
            close RGP_CSR;
        end if;

        if(l_cle_id is not null) then
            open  CLE_CSR(l_cle_id);
            fetch CLE_CSR into l_start_date;
            close CLE_CSR;
            if(l_start_date is not null) then
                return l_start_date;
            end if;
        end if;
        if(l_chr_id is null) then
            return null;
        end if;
        open  KHR_CSR(l_chr_id);
        fetch KHR_CSR into l_start_date;
        close KHR_CSR;
        return l_start_date;

END get_start_date;

-- bug
-- gboomina Added for Bug 6152538
-- This function is used to find the end date of a line for
-- which we create payment
-- For Contract level payments, this will return contract end date and
-- For Line level payments, this will return respective line(Asset, Fee or Service)
-- end date for which we create payment.
FUNCTION get_line_end_date(p_rgp_id  IN  NUMBER )
  RETURN DATE
  IS
    l_chr_id OKC_K_HEADERS_B.ID%TYPE    := NULL;
    l_cle_id OKC_K_LINES_B.ID%TYPE      := NULL;
    l_rgp_id OKC_RULE_GROUPS_B.ID%TYPE  := p_rgp_id;

    l_line_end_date date;

    cursor khr_csr(p_id in number) is
    select end_date
    from okc_k_headers_b
    where id = p_id;

    cursor cle_csr(p_id in number) is
    select end_date
    from okc_k_lines_b
    where id = p_id;

    cursor rgp_csr(p_id in number) is
    select dnz_chr_id, cle_id
    from okc_rule_groups_b
    where id = p_id;

  BEGIN
    if(l_rgp_id is not null) then
      open  rgp_csr(l_rgp_id);
      fetch rgp_csr into l_chr_id, l_cle_id;
      close rgp_csr;
    end if;

    if(l_cle_id is not null) then
      open  cle_csr(l_cle_id);
      fetch cle_csr into l_line_end_date;
      close cle_csr;
      if(l_line_end_date is not null) then
        return l_line_end_date;
      end if;
    end if;

    if(l_chr_id is null) then
       return null;
    end if;
    open  khr_csr(l_chr_id);
    fetch khr_csr into l_line_end_date;
    close khr_csr;
    return l_line_end_date;

END get_line_end_date;


FUNCTION get_end_date(
    l_start_date      IN  DATE,
    p_frequency       IN  VARCHAR2,
    p_period          IN  NUMBER,
    ---- cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
    p_start_day   IN NUMBER DEFAULT NULL,
    p_contract_end_date IN DATE DEFAULT NULL --Bug#5441811
)
    RETURN DATE IS
    l_end_date date;
    factor number := 0;
    BEGIN
     if(p_frequency = 'M') then
        factor := 1;
     elsif(p_frequency = 'Q') then
        factor := 3;
     elsif(p_frequency = 'S') then
        factor := 6;
     elsif(p_frequency = 'A') then
        factor := 12;
     end if;

	 -- start: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
     --l_end_date := ADD_MONTHS(l_start_date, (factor * NVL(p_period,0)));
     -- l_end_date := l_end_date - 1;

	 l_end_date := Okl_Lla_Util_Pvt.calculate_end_date(p_start_date => l_start_date,
	                                                   p_months     =>  factor * NVL(p_period,0),
							   p_start_day => p_start_day,
                                            p_contract_end_date => p_contract_end_date );--Bug#5441811
      -- end: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938


     return l_end_date;
EXCEPTION
    WHEN OTHERS THEN
      RETURN null;
END get_end_date;


FUNCTION get_display_end_date(
    p_start_date      IN  VARCHAR2,
    p_stub_days       IN  VARCHAR2,
    p_frequency       IN  VARCHAR2,
    p_period          IN  VARCHAR2,
    ---- mvasudev,06-02-2005,Bug#4392051
    p_start_day   IN NUMBER,
    p_contract_end_date IN DATE DEFAULT NULL --Bug#5441811
    )
    RETURN VARCHAR2 IS
    l_end_date date;
    l_end_date_disp varchar2(40);
    BEGIN
     if(p_stub_days is not null and p_stub_days <> OKL_API.G_MISS_CHAR) then -- end date for stub entry.
        l_end_date := FND_DATE.canonical_to_date(p_start_date) + to_number(p_stub_days);
        l_end_date := l_end_date - 1;
        l_end_date_disp := OKL_LLA_UTIL_PVT.get_display_date(nvl(FND_DATE.date_to_canonical(l_end_date),''));
     else -- end date for level entry.
       -- cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
        --l_end_date := get_end_date(FND_DATE.canonical_to_date(p_start_date), p_frequency, TO_NUMBER(NVL(p_period,0)));
	 --l_end_date := get_end_date(FND_DATE.canonical_to_date(p_start_date), p_frequency, TO_NUMBER(NVL(p_period,0)),p_start_day);

       l_end_date := get_end_date(FND_DATE.canonical_to_date(p_start_date), p_frequency, TO_NUMBER(NVL(p_period,0)),p_start_day, p_contract_end_date); --Bug#5441811

        l_end_date_disp := OKL_LLA_UTIL_PVT.get_display_date(NVL(FND_DATE.date_to_canonical(l_end_date),''));
     end if;
     return l_end_date_disp;
EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
END get_display_end_date;

--START: 07-25-2005 cklee/mvasudev -- Fixed Bug#4392051/okl.h 4437938
FUNCTION get_start_day(
    p_rule_id      IN  NUMBER
   ,p_dnz_chr_id IN NUMBER
   ,p_rgp_id IN NUMBER
   ,p_slh_id IN NUMBER
   ,p_start_date IN VARCHAR2)
RETURN NUMBER
IS

  --Modified cursor for bug 6007644
  --Added FND_DATE.canonical_to_date(RULE_INFORMATION2)+to_number(RULE_INFORMATION7) to return the recurrence date
  --Also added FND_DATE.canonical_to_date(rule_information2) to covert the rule_information2 to date format
  CURSOR l_okl_stub_start_csr
  IS
  SELECT MAX(FND_DATE.canonical_to_date(RULE_INFORMATION2)+to_number(RULE_INFORMATION7)) start_date
  FROM   OKC_RULES_V
  WHERE  rgp_id = p_rgp_id
  AND    dnz_chr_id = p_dnz_chr_id
  AND    object2_id1 = p_slh_id
  AND    id <> p_rule_id
  AND    rule_information_category = 'LASLL'  --| 17-Jan-06 cklee Fixed bug#4956483                                           |
  AND    FND_DATE.canonical_to_date(rule_information2) < FND_DATE.canonical_to_date(p_start_date)
  AND    rule_information7 IS NOT NULL
  ORDER BY start_date;

  CURSOR l_okl_chr_start_csr
  IS
  SELECT START_DATE
  FROM   OKC_K_HEADERS_B
  WHERE ID = p_dnz_chr_id;

  l_start_date DATE;
  l_sll_count NUMBER := 0;
BEGIN
	  OPEN l_okl_sll_count_csr(p_rgp_id,p_dnz_chr_id,p_slh_id);
      FETCH l_okl_sll_count_csr INTO l_sll_count;
      CLOSE l_okl_sll_count_csr;

	  IF (l_sll_count > 1 ) THEN

		  FOR l_okl_stub_start_rec IN l_okl_stub_start_csr
		  LOOP
		    l_start_date :=  l_okl_stub_start_rec.start_date;
		  END LOOP;

		  IF l_start_date IS NULL THEN
		      FOR l_okl_chr_start_rec IN l_okl_chr_start_csr
		      LOOP
		        l_start_date :=  l_okl_chr_start_rec.start_date;
		      END LOOP;
		  END IF;

		  IF l_start_date IS NOT NULL THEN
		    RETURN (TO_CHAR(l_start_date,'DD'));
		  END IF;
	  ELSE
	    RETURN NULL;
	  END IF;



EXCEPTION
    WHEN OTHERS THEN
      RETURN '';  --Added for bug 6007644
       /*
            Commented so that the function would return days, which acts as an input parameter
            for OKL_LLA_UTIL_PVT.calculate_end_date. If the function returns NULL the
            calculate_end_date logic flows into calculating the contract end date logic.
           */
END get_start_day;
--END: 07-25-2005 cklee/mvasudev -- Fixed Bug#4392051/okl.h 4437938

FUNCTION get_order_sequence(
    p_sequence        IN  VARCHAR2)
    RETURN NUMBER IS
    l_sequence number;
    BEGIN
     if(p_sequence is null) then
        return 0;
     end if;
     l_sequence := to_number(p_sequence);
     return l_sequence;
EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END get_order_sequence;


PROCEDURE calculate_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_rgp_id                       IN NUMBER,
    p_slh_id                       IN VARCHAR2,
    structure                      IN VARCHAR2,
    frequency                      IN VARCHAR2,
    arrears                        IN VARCHAR2,
    --Bug# 6438785
    p_validate_date_yn             IN VARCHAR2 DEFAULT 'Y') IS
  i NUMBER := 0;
  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  l_start_date      date     := null;
  l_prev_start_date date     := null;
  l_end_date        date     := null;
  l_k_start_date    date     := null;
  l_chr_id          number   := null;
  factor            number   := null;

    CURSOR sll_instances(P_RGP_ID     IN NUMBER,
                         P_CHR_ID     IN NUMBER,
                         P_SLH_ID     IN VARCHAR2
                          ) IS
    SELECT
    SLL.*,
    FND_DATE.canonical_to_date(nvl(SLL.RULE_INFORMATION2,null))  START_DATE,
    OKL_LA_PAYMENTS_PVT.get_order_sequence(SLL.RULE_INFORMATION1) SEQUENCE
    FROM OKC_RULES_B SLL
    WHERE
    SLL.DNZ_CHR_ID = P_CHR_ID
    AND SLL.RGP_ID = P_RGP_ID
    AND SLL.RULE_INFORMATION_CATEGORY  = 'LASLL'
    AND SLL.OBJECT2_ID1 = P_SLH_ID
  ORDER BY START_DATE, SEQUENCE;

  l_rulv_tbl sll_instances%ROWTYPE;

  l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
  lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'CALCULATE_DETAILS';
  l_api_version            CONSTANT NUMBER    := 1.0;

  -- cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
  l_start_day NUMBER;
  l_sll_count NUMBER := 0;

  l_contract_end_date DATE; --Bug#5441811
  l_line_end_date DATE; -- Bug 6152538

  begin

        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;
      l_end_date := get_start_date(p_rgp_id => p_rgp_id);

      -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
  	  OPEN l_okl_sll_count_csr(p_rgp_id,p_chr_id,p_slh_id);
        FETCH l_okl_sll_count_csr INTO l_sll_count;
        CLOSE l_okl_sll_count_csr;

  	  IF (l_sll_count > 1 ) THEN
  	    l_start_day := TO_CHAR(l_end_date,'DD');
	  END IF;
      -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938

      l_end_date := l_end_date - 1;

      --For Bug#5441811 selecting the contract end date for calculating
             -- end dates in payment structure.
         FOR i IN ( SELECT end_date FROM okc_k_headers_b WHERE id = P_CHR_ID)
         LOOP
           l_contract_end_date := i.end_date;
         END LOOP;
         --Bug#5441811

      FOR rule_rec in sll_instances(P_RGP_ID, P_CHR_ID, P_SLH_ID) loop

        if( rule_rec.rule_information7 is not null and  -- stub days
            rule_rec.rule_information7 <> OKL_API.G_MISS_CHAR ) then
            l_start_date := l_end_date + 1;
            l_end_date   := l_start_date + to_number(rule_rec.rule_information7);
            l_end_date   := l_end_date - 1;
            l_rulv_rec.rule_information2 := FND_DATE.date_to_canonical(l_start_date);
            l_rulv_rec.id := rule_rec.id;

            -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
              IF (l_sll_count > 1 ) THEN
                l_start_day := TO_CHAR(l_end_date + 1,'DD');
			END IF;
            -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938

            -- nikshah Bug 7828786 - Start
            -- Added to avoid validating stub end date when this API is called
            -- at the time of updating the contract or line start dates
            IF p_validate_date_yn = 'Y' THEN
              -- Check whether stubs end date exceeds contract/line end date.
              l_line_end_date := get_line_end_date(p_rgp_id);
              if ( trunc(l_end_date) > trunc(l_line_end_date) ) then
                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                   , p_msg_name => 'OKL_PAYMENT_DT_EXCEEDS_LINE_DT');
                raise OKL_API.G_EXCEPTION_ERROR;
              end if;
            END IF;
            -- nikshah Bug 7828786 - End

        elsif(rule_rec.rule_information3 is not null and -- periods
            rule_rec.rule_information3 <> OKL_API.G_MISS_CHAR ) then
            l_start_date := l_end_date + 1;
            --l_end_date   := get_end_date(l_start_date, rule_rec.OBJECT1_ID1, rule_rec.RULE_INFORMATION3);
            l_end_date   := get_end_date(l_start_date, rule_rec.OBJECT1_ID1, rule_rec.RULE_INFORMATION3,l_start_day, l_contract_end_date);--Bug#5441811
            l_rulv_rec.rule_information2 := FND_DATE.date_to_canonical(l_start_date);
            l_rulv_rec.id := rule_rec.id;

            -- Bug# 6438785
            -- Added to avoid validating payment end date when this API is called
            -- at the time of updating the contract or line start dates
            IF p_validate_date_yn = 'Y' THEN
              -- gboomina Bug 6152538 - Start
              -- Check whether payments end date exceeds contract/line end date.
              l_line_end_date := get_line_end_date(p_rgp_id);
              if ( trunc(l_end_date) > trunc(l_line_end_date) ) then
                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                   , p_msg_name => 'OKL_PAYMENT_DT_EXCEEDS_LINE_DT');
                raise OKL_API.G_EXCEPTION_ERROR;
              end if;
              -- gboomina Bug 6152538 - End
            END IF;
            -- Bug# 6438785
        end if;


        if (frequency is not null and frequency <> OKL_API.G_MISS_CHAR) then
            l_rulv_rec.jtot_object1_code := 'OKL_TUOM';
            l_rulv_rec.object1_id1        := frequency;
        end if;
        if (arrears is not null and arrears <> OKL_API.G_MISS_CHAR) then
            l_rulv_rec.rule_information10 := arrears;
        end if;
        if (structure is not null and structure <> OKL_API.G_MISS_CHAR) then
            l_rulv_rec.rule_information5  := structure;
        end if;

        l_rulv_rec.rule_information1 := null;

        OKL_RULE_PUB.update_rule(
                    p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_rulv_rec           => l_rulv_rec,
                    x_rulv_rec           => lx_rulv_rec);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


   end loop;
   if(sll_instances%ISOPEN) then
        close sll_instances;
   end if;
   -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
   IF(l_okl_sll_count_csr%ISOPEN) THEN
        CLOSE l_okl_sll_count_csr;
   END IF;
   -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
        -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
        if(sll_instances%ISOPEN) then
          close sll_instances;
        end if;
        IF(l_okl_sll_count_csr%ISOPEN) THEN
          CLOSE l_okl_sll_count_csr;
        END IF;
        -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
        -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
        if(sll_instances%ISOPEN) then
          close sll_instances;
        end if;
        IF(l_okl_sll_count_csr%ISOPEN) THEN
          CLOSE l_okl_sll_count_csr;
        END IF;
        -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
        -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
        if(sll_instances%ISOPEN) then
          close sll_instances;
        end if;
        IF(l_okl_sll_count_csr%ISOPEN) THEN
          CLOSE l_okl_sll_count_csr;
        END IF;
        -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END calculate_details;


FUNCTION is_num(
    p_num        IN  VARCHAR2)
    RETURN boolean IS
    l_num number;
    BEGIN
     if(p_num is null or  p_num = OKL_API.G_MISS_CHAR ) then
        return false;
     else
        l_num := to_number(p_num);
        return true;
     end if;
EXCEPTION
    WHEN OTHERS THEN
      RETURN false;
END is_num;


PROCEDURE validate_payment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    p_fee_line_type                IN  VARCHAR2,
    p_payment_type                 IN  VARCHAR2,
    p_type                         IN  VARCHAR2
    ) IS


  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'VALIDATE_PAYMENTS';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;
  l_rulv_rec rulv_rec_type := p_rulv_rec;
  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  l_lty_code OKC_LINE_STYLES_V.LTY_CODE%TYPE  := null;

  l_days        boolean := false;
  l_days_amt    boolean := false;
  l_period      boolean := false;
  l_period_amt  boolean := false;
  -- Start fix for bug 7111749
  l_structure   boolean := false;
  -- End fix for bug 7111749
  l_message     VARCHAR2(1000);

  begin

        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

        if( p_rulv_rec.rule_information7 is not null and
            p_rulv_rec.rule_information7 <> OKL_API.G_MISS_CHAR) then
            l_days := true;

        end if;
        if( p_rulv_rec.rule_information8 is not null and
            p_rulv_rec.rule_information8 <> OKL_API.G_MISS_CHAR) then
            l_days_amt := true;
        end if;
        if( p_rulv_rec.rule_information3 is not null and
            p_rulv_rec.rule_information3 <> OKL_API.G_MISS_CHAR) then
            l_period := true;
        end if;
        if( p_rulv_rec.rule_information6 is not null and
            p_rulv_rec.rule_information6 <> OKL_API.G_MISS_CHAR) then
            l_period_amt := true;
        end if;
        -- Start fix for bug 7111749
        -- Set l_structure TRUE if non-level
        if( p_rulv_rec.rule_information5 is not null and
            p_rulv_rec.rule_information5 <> OKL_API.G_MISS_CHAR) and
            (TRUNC(NVL(p_rulv_rec.rule_information5, '-1')) <> '0') then
            l_structure := true;
        end if;
        -- End fix for bug 7111749

    if(p_payment_type = 'VIR_PAYMENT') then
        if(l_period and is_num(p_rulv_rec.rule_information3) and to_number(p_rulv_rec.rule_information3) > 0 ) then
            OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data     => x_msg_data);
            return;
        else
            x_return_status := OKL_API.g_ret_sts_error;
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => l_message);
            raise OKL_API.G_EXCEPTION_ERROR;
        end if;
    end if;

    if((l_days and l_period) or (l_days_amt and l_period_amt)) then
            l_message := 'OKL_LA_PYM_STUB_PERIOD';
    elsif((l_days and not l_days_amt) or (not l_days and l_days_amt)) then
            l_message := 'OKL_LA_PYM_STUB';
    elsif((l_period and not l_period_amt) or (not l_period and l_period_amt)) then
            l_message := 'OKL_LA_PYM_PERIOD';
    end if;

    if(l_message is null and l_period ) then
        if( is_num(p_rulv_rec.rule_information3) and to_number(p_rulv_rec.rule_information3) > 0 ) then
            if( not is_num(p_rulv_rec.rule_information6) ) then
                l_message := 'OKL_LA_PYM_AMOUNT';
            end if;
        else
            l_message := 'OKL_LA_PYM_PERIOD_ZERO';
        end if;
    end if;

    if(l_message is null and l_days ) then
        if( is_num(p_rulv_rec.rule_information7) and to_number(p_rulv_rec.rule_information7) > 0 ) then
            if( not is_num(p_rulv_rec.rule_information8) ) then
                l_message := 'OKL_LA_PYM_AMOUNT';
            end if;
        else
            l_message := 'OKL_LA_PYM_DAYS_ZERO';
        end if;
    end if;
    -- Start fix for bug 7111749
    l_payment_code := get_payment_type(l_rulv_rec.object2_id1);
    if (l_payment_code IN ('RENT', 'LOAN_PAYMENT', 'PRINCIPAL_PAYMENT')) then
       if(l_message is null and l_structure ) then
           if(l_days and l_days_amt) then
               l_message := 'OKL_QA_PAYMENT_STUB_NA';
           end if;
       end if;
    end if;
    -- End fix for bug 7111749
        if(l_message is not null) then
            x_return_status := OKL_API.g_ret_sts_error;
            OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => l_message);
            raise OKL_API.G_EXCEPTION_ERROR;
        end if;


        if( p_fee_line_type is null or
            p_fee_line_type = ''    or
            p_fee_line_type = OKL_API.G_MISS_CHAR ) then

            --x_rulv_rec := l_rulv_rec;

            OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data     => x_msg_data);
            return;
         end if;


        if(p_fee_line_type is not null and p_fee_line_type = 'SECDEPOSIT') then

            l_payment_code := get_payment_type(l_rulv_rec.object2_id1);
            if( l_payment_code <> 'SECURITY_DEPOSIT') then -- cklee: 11/01/04, 12-03-2004

                x_return_status := OKL_API.g_ret_sts_error;
                l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_PYMTS_TYPE');
                OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                        , p_msg_name => 'OKL_LLA_PYMTS_SEC_PYMT'
                                        , p_token1 => 'COL_NAME'
                                        , p_token1_value => l_ak_prompt
                                       );

                raise OKL_API.G_EXCEPTION_ERROR;

            end if;

        end if;


        if(p_fee_line_type is not null and p_fee_line_type = 'SECDEPOSIT') then
            l_lty_code := get_lty_code(l_rulv_rec.rgp_id);
            if(l_lty_code is not null and l_lty_code = 'LINK_FEE_ASSET') then
                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                        , p_msg_name => 'OKL_LLA_PYMTS_FEE_NO_ASSET');
                raise OKL_API.G_EXCEPTION_ERROR;
            end if;
        end if;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END validate_payment;


FUNCTION get_subline_id(
    p_chr_id                       IN  NUMBER,
    p_topline_id                   IN  NUMBER,
    p_asset_id                     IN  NUMBER)
    RETURN OKC_K_LINES_B.ID%TYPE IS

    l_subline_id OKC_K_LINES_B.ID%TYPE := null;
    l_lty_code OKC_LINE_STYLES_b.LTY_CODE%TYPE := null;

    cursor LTY_CODE_CSR(P_LINE_ID IN NUMBER) is
    SELECT LTY_CODE
    FROM
    OKC_LINE_STYLES_B LS, OKC_K_LINES_B L
    WHERE LS.ID = L.LSE_ID AND L.ID = P_LINE_ID;

    cursor SERVICES_CSR(P_CHR_ID IN NUMBER, P_TOPLINE_ID  IN NUMBER, P_ASSET_ID IN NUMBER) is
    SELECT KLINES1.ID
    FROM OKL_PYMTS_SERVICE_INSTS_UV SFINTS,OKC_K_LINES_B KLINES,
    OKC_K_LINES_B KLINES1, OKC_LINE_STYLES_B LS, OKC_K_ITEMS KITMS
    WHERE KLINES.ID = SFINTS.LINE_ID
    AND KLINES.ID = KLINES1.CLE_ID
    AND KLINES1.LSE_ID = LS.ID AND LS.LTY_CODE = 'LINK_SERV_ASSET'
    AND KITMS.CLE_ID = KLINES1.ID AND KITMS.JTOT_OBJECT1_CODE='OKX_COVASST'
    AND KLINES.DNZ_CHR_ID = P_CHR_ID AND KLINES.ID = P_TOPLINE_ID
    AND KITMS.OBJECT1_ID1 = P_ASSET_ID;


    cursor FEES_CSR(P_CHR_ID IN NUMBER, P_TOPLINE_ID  IN NUMBER, P_ASSET_ID IN NUMBER) is
    SELECT KLINES1.ID
    FROM OKL_PYMTS_FEE_INSTS_UV SFINTS,OKC_K_LINES_B KLINES,
    OKC_K_LINES_B KLINES1, OKC_LINE_STYLES_B LS, OKC_K_ITEMS KITMS
    WHERE KLINES.ID = SFINTS.LINE_ID
    AND KLINES.ID = KLINES1.CLE_ID
    AND KLINES1.LSE_ID = LS.ID AND LS.LTY_CODE = 'LINK_FEE_ASSET'
    AND KITMS.CLE_ID = KLINES1.ID AND KITMS.JTOT_OBJECT1_CODE='OKX_COVASST'
    AND KLINES.DNZ_CHR_ID = P_CHR_ID AND KLINES.ID = P_TOPLINE_ID
    AND KITMS.OBJECT1_ID1 = P_ASSET_ID;

    BEGIN

        open  LTY_CODE_CSR(p_topline_id);
        fetch LTY_CODE_CSR into l_lty_code;
        close LTY_CODE_CSR;


        if(l_lty_code = 'SOLD_SERVICE') then
            open  SERVICES_CSR(p_chr_id, p_topline_id, p_asset_id);
            fetch SERVICES_CSR into l_subline_id;
            close SERVICES_CSR;
        else
            open  FEES_CSR(p_chr_id, p_topline_id, p_asset_id);
            fetch FEES_CSR into l_subline_id;
            close FEES_CSR;
        end if;
        return l_subline_id;
END get_subline_id;


PROCEDURE migrate_rec(
         p_chr_id          IN NUMBER,
         p_rgp_id          IN NUMBER,
         p_slh_id          IN NUMBER,
         p_pym_hdr_rec     IN  pym_hdr_rec_type,
         p_pym_rec         IN  pym_rec_type,
         x_rulv_rec        OUT NOCOPY rulv_rec_type) IS

l_rulv_rec rulv_rec_type;
i NUMBER := 0;
l_slh_id varchar2(300);

-- temp
valid boolean := true;

Begin

        if((p_pym_rec.stub_days is null or p_pym_rec.stub_days = OKL_API.G_MISS_CHAR) and
           (p_pym_rec.stub_amount is null or p_pym_rec.stub_amount = OKL_API.G_MISS_CHAR) and
           (p_pym_rec.period is null or p_pym_rec.period = OKL_API.G_MISS_CHAR) and
           (p_pym_rec.amount is null or p_pym_rec.amount = OKL_API.G_MISS_CHAR)) then
           valid := false;
        end if;

        if(not valid) then
            x_rulv_rec := null;
            return;
        end if;

        l_slh_id := to_char(p_slh_id);
            if(p_pym_rec.update_type = 'CREATE') then
                l_rulv_rec.id                := null;
            elsif(p_pym_rec.update_type = 'UPDATE') then
                l_rulv_rec.id                := p_pym_rec.rule_id;
            end if;
            if(p_pym_rec.update_type <> 'DELETE') then

                l_rulv_rec.rule_information7 := p_pym_rec.stub_days;
                l_rulv_rec.rule_information8 := p_pym_rec.stub_amount;
                l_rulv_rec.rule_information3 := p_pym_rec.period;
                l_rulv_rec.rule_information6 := p_pym_rec.amount;
                l_rulv_rec.rule_information2 := p_pym_rec.sort_date;
                l_rulv_rec.jtot_object1_code := 'OKL_TUOM';
                l_rulv_rec.object1_id1       := p_pym_hdr_rec.frequency;
                l_rulv_rec.rule_information10 := p_pym_hdr_rec.arrears;
                l_rulv_rec.rule_information5 := p_pym_hdr_rec.structure;
                l_rulv_rec.jtot_object2_code := 'OKL_STRMHDR';
                l_rulv_rec.object2_id1       := l_slh_id;
                l_rulv_rec.object2_id2       := '#';
                l_rulv_rec.dnz_chr_id        := p_chr_id;
                l_rulv_rec.rgp_id            := p_rgp_id;
                l_rulv_rec.sfwt_flag         := 'N';
                l_rulv_rec.std_template_yn   := 'N';
                l_rulv_rec.warn_yn           := 'N';
                l_rulv_rec.rule_information_category := 'LASLL';
             end if;


        x_rulv_rec := l_rulv_rec;

END migrate_rec;


FUNCTION check_rec(p_pym_rec         IN  pym_rec_type)
         RETURN boolean IS

BEGIN
        if((p_pym_rec.stub_days is null or p_pym_rec.stub_days = OKL_API.G_MISS_CHAR) and
           (p_pym_rec.stub_amount is null or p_pym_rec.stub_amount = OKL_API.G_MISS_CHAR) and
           (p_pym_rec.period is null or p_pym_rec.period = OKL_API.G_MISS_CHAR) and
           (p_pym_rec.amount is null or p_pym_rec.amount = OKL_API.G_MISS_CHAR)) then
           return true;
        else
            return false;
        end if;
END check_rec;


PROCEDURE get_payment(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                           OKC_K_HEADERS_B.ID%TYPE,
    p_service_fee_id                   OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_asset_id                         OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_payment_id                       OKL_STRMTYP_SOURCE_V.ID1%TYPE,
    x_pym_level                    OUT NOCOPY VARCHAR2,
    x_slh_id                       OUT NOCOPY OKC_RULES_V.ID%TYPE,
    x_rgp_id                       OUT NOCOPY OKC_RULE_GROUPS_V.ID%TYPE,
    x_cle_id                       OUT NOCOPY OKC_K_LINES_B.ID%TYPE) IS

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'GET_PAYMENT';
  l_api_version            CONSTANT NUMBER    := 1.0;

  l_pym_level       VARCHAR2(30) := 'HEADER';
  l_subline_id      OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;
  l_slh_id          OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM;
  l_rgp_id          OKC_RULE_GROUPS_V.ID%TYPE := OKL_API.G_MISS_NUM;
  l_cle_id          OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;

  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    ------------- temp
  Cursor get_dir is
  SELECT nvl(substrb(translate(ltrim(value),',',' '),
                           1,
  instr(translate(ltrim(value),',',' '),' ') - 1),value)
  FROM v$parameter
  WHERE name = 'utl_file_dir';

  l_TEMP_DIR  varchar2(200);
  delimit   varchar2(10) := '  ';

  ------------- temp

  cursor RGP_HDR_CSR(P_CHR_ID IN NUMBER) is
    SELECT
    ID
    FROM OKC_RULE_GROUPS_V WHERE
    DNZ_CHR_ID = P_CHR_ID AND CHR_ID = P_CHR_ID
    AND RGD_CODE = 'LALEVL'
    AND CLE_ID IS NULL;

  cursor RGP_CLE_CSR(P_CHR_ID IN NUMBER, P_CLE_ID  IN NUMBER) is
    SELECT
    ID
    FROM OKC_RULE_GROUPS_V RG WHERE
    RG.DNZ_CHR_ID = P_CHR_ID AND RG.CHR_ID IS NULL
    AND RGD_CODE = 'LALEVL'
    AND RG.CLE_ID = P_CLE_ID;

  cursor SLH_CSR(P_RGP_ID IN NUMBER, P_PAYMENT_ID IN VARCHAR2) is
    SELECT
    ID
    FROM OKC_RULES_B SLH WHERE
    SLH.RGP_ID = P_RGP_ID AND
--  bug 3377730.
    SLH.OBJECT1_ID1 = P_PAYMENT_ID;
--    SLH.OBJECT1_ID1 = TO_CHAR(P_PAYMENT_ID);

  begin

        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

/* -- temp
    open get_dir;
    fetch get_dir into l_temp_dir;
    if get_dir%notfound then
       null;
    end if;
    close get_dir;
    */
   --fnd_file.put_names(l_log, l_out, l_temp_dir);
-- temp


        if( p_payment_id is null or p_payment_id = OKL_API.G_MISS_NUM) then
            x_return_status := OKL_API.g_ret_sts_error;
            OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_LLA_PMT_SELECT');
            raise OKL_API.G_EXCEPTION_ERROR;
        end if;


        if( p_asset_id is not null and p_asset_id <> OKL_API.G_MISS_NUM) then
            l_pym_level := 'ASSET';
            l_cle_id := p_asset_id;
        end if;
        if(p_service_fee_id is not null and  p_service_fee_id <> OKL_API.G_MISS_NUM) then
            if(l_pym_level = 'ASSET') then
                l_pym_level := 'SUBLINE';
            else
                l_pym_level := 'SERVICE_FEE';
                l_cle_id    := p_service_fee_id;
            end if;
        end if;


        if(l_pym_level = 'SUBLINE') then
            l_subline_id := get_subline_id(p_chr_id, p_service_fee_id, p_asset_id);
            l_cle_id     := l_subline_id;
        end if;

        if(l_pym_level = 'HEADER') then
            open  RGP_HDR_CSR(p_chr_id);
            fetch RGP_HDR_CSR into l_rgp_id;
            close RGP_HDR_CSR;
        else
            open  RGP_CLE_CSR(p_chr_id, l_cle_id);
            fetch RGP_CLE_CSR into l_rgp_id;
            close RGP_CLE_CSR;
        end if;

        if(l_rgp_id is not null and l_rgp_id <> OKL_API.G_MISS_NUM) then
            open  SLH_CSR(l_rgp_id, p_payment_id);
            fetch SLH_CSR into l_slh_id;
            close SLH_CSR;

        end if;


        x_pym_level    :=  l_pym_level;
        x_slh_id       :=  l_slh_id;
        x_rgp_id       :=  l_rgp_id;
        x_cle_id       :=  l_cle_id;


 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END get_payment;


FUNCTION is_investor_fee_payment(p_chr_id IN  NUMBER,
                                      p_payment IN  NUMBER, p_rgp_id IN  NUMBER)
  RETURN boolean IS

     cursor inv_dtls_csr(p_chr_id IN NUMBER) is
      SELECT scs_code
      FROM OKC_K_HEADERS_B
      WHERE ID = p_chr_id ;
       CURSOR fee_line_amount_csr(p_rgp_id IN NUMBER) is
    SELECT kleb.amount amount
    FROM okc_k_lines_b cleb,
         okl_k_lines kleb,
         okc_line_styles_b lseb,
         okc_k_headers_b chrb,
         okc_rule_groups_b rg
    WHERE chrb.id = cleb.dnz_chr_id
    AND kleb.id = cleb.id
    AND cleb.lse_id = lseb.id
    AND lseb.lty_code = 'FEE'
    AND rg.cle_id = cleb.id
    AND rg.id = p_rgp_id;



    l_inv_dtls inv_dtls_csr%ROWTYPE;
   l_fee_amount_dtls  fee_line_amount_csr%ROWTYPE ;


    --l_ret_value VARCHAR2(1);

  BEGIN

    --l_ret_value := OKL_API.G_FALSE;

    OPEN inv_dtls_csr(p_chr_id => p_chr_id);
    FETCH inv_dtls_csr INTO l_inv_dtls;
    CLOSE inv_dtls_csr;

    IF l_inv_dtls.scs_code = 'INVESTOR' THEN
  OPEN fee_line_amount_csr(p_rgp_id => p_rgp_id);
    FETCH fee_line_amount_csr INTO l_fee_amount_dtls;
    CLOSE fee_line_amount_csr;


  IF(p_payment=l_fee_amount_dtls.amount) THEN
     return true;
      ELSE
       return false;
    END IF;
    ELSE
    return true;
    END IF ;


    RETURN true;

  END is_investor_fee_payment;


PROCEDURE process_payment(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                           OKC_K_HEADERS_B.ID%TYPE,
    p_service_fee_id                   OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_asset_id                         OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_payment_id                       OKL_STRMTYP_SOURCE_V.ID1%TYPE,
    p_pym_hdr_rec                  IN  pym_hdr_rec_type,
    p_pym_tbl                      IN  pym_tbl_type,
    p_update_type                  IN  VARCHAR2,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'PROCESS_PAYMENT';
  l_api_version            CONSTANT NUMBER    := 1.0;
  l_totalpayment NUMBER :=0 ;
  i NUMBER := 0;
  j NUMBER := 0;
  k NUMBER := 0;
  l NUMBER := 0;
  kount NUMBER := 0;
  empty_rec boolean := false;

  l_start_date OKC_K_HEADERS_B.START_DATE%TYPE          := null;
  l_org_id     OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE    := null;
  l_ccode      OKC_K_HEADERS_B.CURRENCY_CODE%TYPE       := null;

  l_crea_rulv_tbl rulv_tbl_type;
  l_updt_rulv_tbl rulv_tbl_type;
  l_delt_rulv_tbl rulv_tbl_type;

  l_rulv_rec      rulv_rec_type := NULL;
  lx_rulv_rec     rulv_rec_type := NULL;
  l_rulv_rec2     rulv_rec_type := NULL;

  lx_rulv_tbl     rulv_tbl_type;

  l_rgpv_rec  OKL_RULE_PUB.rgpv_rec_type := NULL;
  lx_rgpv_rec OKL_RULE_PUB.rgpv_rec_type := NULL;

  l_pym_level       VARCHAR2(30) := 'HEADER';
  l_subline_id      OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;
  l_slh_id          OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM;
  l_rgp_id          OKC_RULE_GROUPS_V.ID%TYPE := OKL_API.G_MISS_NUM;
  l_cle_id          OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;
  l_stream_id       OKC_RULES_V.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR;

  l_fee_line_type OKL_K_FEE_LINES_UV.FEE_TYPE%TYPE := null;
  l_lty_code OKC_LINE_STYLES_V.LTY_CODE%TYPE  := null;
  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    ------------- temp
  Cursor get_dir is
  SELECT nvl(substrb(translate(ltrim(value),',',' '),
                           1,
  instr(translate(ltrim(value),',',' '),' ') - 1),value)
  FROM v$parameter
  WHERE name = 'utl_file_dir';

  l_TEMP_DIR  varchar2(200);
  delimit   varchar2(10) := '  ';

  ------------- temp

  cursor CHR_DTLS_CSR(P_CHR_ID IN NUMBER) is
      SELECT
      -- bug
      -- START_DATE,
      -- bug
      A.AUTHORING_ORG_ID,
      A.CURRENCY_CODE,
      B.DEAL_TYPE          -- Bug 4887014
      FROM OKC_K_HEADERS_B A, OKL_K_HEADERS B WHERE
      A.ID = P_CHR_ID
      AND A.ID = B.ID;

    --Changed query for performance --dkagrawa
    CURSOR FEE_LINE_CSR(P_RGP_ID IN NUMBER) is
    SELECT kleb.fee_type fee_type
    FROM okc_k_lines_b cleb,
         okl_k_lines kleb,
         okc_line_styles_b lseb,
         okc_k_headers_b chrb,
         okc_rule_groups_b rg
    WHERE chrb.id = cleb.dnz_chr_id
    AND kleb.id = cleb.id
    AND cleb.lse_id = lseb.id
    AND lseb.lty_code = 'FEE'
    AND rg.cle_id = cleb.id
    AND rg.id = p_rgp_id;


    CURSOR INVALID_LINE_CSR(P_CLE_ID IN NUMBER) is
    SELECT 'Y'
    FROM OKC_STATUSES_V OKCS, OKC_K_LINES_B CLE
    WHERE CLE.STS_CODE = OKCS.CODE
--    AND OKCS.STE_CODE IN ('EXPIRED','HOLD','CANCELLED','TERMINATED')
    AND OKCS.STE_CODE IN ('TERMINATED')
    AND CLE.ID = P_CLE_ID;
    -- added for bug 5115701 - start
   CURSOR GET_FEE_TYPE_SUB_CSR(P_CHR_ID IN NUMBER, p_service_fee_id IN NUMBER) is
  SELECT  fee_line.fee_type
  FROM   okl_k_lines_full_v l,
         okc_line_styles_v sty,
         okc_statuses_v sts,
         okl_k_lines fee_line
  WHERE  l.lse_id = sty.id
  AND    l.sts_code = sts.code
  AND    sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    sty.lty_code = 'LINK_FEE_ASSET'
  AND    l.dnz_chr_id = P_CHR_ID
  AND    l.cle_id = fee_line.id
  and    fee_line.id = p_service_fee_id;

    l_subline_fee_type okl_k_lines.fee_type%type;
-- added for bug 5115701 - end
    l_invalid_line varchar2(1) := 'N';

    l_chr_rec       CHR_DTLS_CSR%ROWTYPE;
    l_deal_type     OKL_K_HEADERS.DEAL_TYPE%TYPE;

    -- R12B Authoring OA Migration
    l_upfront_tax_pymt_yn VARCHAR2(1);

    CURSOR l_contract_csr(p_chr_id IN NUMBER) IS
    SELECT chrb.sts_code
    FROM okc_k_headers_b chrb
    WHERE chrb.id = p_chr_id;

    l_contract_rec l_contract_csr%ROWTYPE;

  begin



        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

/* -- temp
    open get_dir;
    fetch get_dir into l_temp_dir;
    if get_dir%notfound then
       null;
    end if;
    close get_dir;
    */
   --fnd_file.put_names(l_log, l_out, l_temp_dir);
-- temp

-- R12B Authoring OA Migration
-- Check if the Payment is for an Upfront Tax Fee line
 /*  IF(not is_investor_fee_payment(p_chr_id =>p_chr_id, p_cle_id => p_service_fee_id , p_rgp_id => l_rulv_rec.rgp_id  )) then
                            x_return_status := OKL_API.g_ret_sts_error;
         OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                 , p_msg_name => 'OKL_LA_INV_PAY_MISMATCH');
         raise OKL_API.G_EXCEPTION_ERROR;
       end if;
       */
l_upfront_tax_pymt_yn := OKL_API.G_FALSE;
IF (p_service_fee_id IS NOT NULL) THEN
  l_upfront_tax_pymt_yn := is_upfront_tax_fee_payment(p_chr_id => p_chr_id,
                                                      p_cle_id => p_service_fee_id);

  IF (l_upfront_tax_pymt_yn = OKL_API.G_TRUE) THEN
    OPEN l_contract_csr(p_chr_id => p_chr_id);
    FETCH l_contract_csr INTO l_contract_rec;
    CLOSE l_contract_csr;

  END IF;
END IF;

-- START: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement
    x_return_status := validate_capitalize_dp
                       (p_asset_id       => p_asset_id,
                        p_service_fee_id => p_service_fee_id,
                        p_payment_id     => p_payment_id);
    --- Store the highest degree of error
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- END: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement

-- START: Setp 02, 2005 cklee: Variable rate ER for GE - 20
    x_return_status := validate_payment_type_asset
                       (p_chr_id         => p_chr_id,
                        p_asset_id       => p_asset_id,
                        p_service_fee_id => p_service_fee_id,
                        p_payment_id     => p_payment_id);
    --- Store the highest degree of error
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- END: Setp 02, 2005 cklee: Variable rate ER for GE - 20

        get_payment(
                    p_api_version     =>  p_api_version,
                    p_init_msg_list   =>  p_init_msg_list,
                    x_return_status   =>  x_return_status,
                    x_msg_count       =>  x_msg_count,
                    x_msg_data        =>  x_msg_data,
                    p_chr_id          =>  p_chr_id,
                    p_service_fee_id  =>  p_service_fee_id,
                    p_asset_id        =>  p_asset_id,
                    p_payment_id      =>  p_payment_id,
                    x_pym_level       =>  l_pym_level,
                    x_slh_id          =>  l_slh_id,
                    x_rgp_id          =>  l_rgp_id,
                    x_cle_id          =>  l_cle_id);


         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --Bug# 4959361
         IF l_cle_id IS NOT NULL THEN
           OKL_LLA_UTIL_PVT.check_line_update_allowed
             (p_api_version     => p_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              p_cle_id          => l_cle_id);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
         --Bug# 4959361

        if(l_rgp_id is null or l_rgp_id = OKL_API.G_MISS_NUM) then
            if(l_pym_level = 'HEADER') then
                l_rgpv_rec.chr_id        :=  p_chr_id;
                l_rgpv_rec.dnz_chr_id    :=  p_chr_id;
                l_rgpv_rec.cle_id        :=  null;
            else
                l_rgpv_rec.chr_id        :=  null;
                l_rgpv_rec.dnz_chr_id    :=  p_chr_id;
                l_rgpv_rec.cle_id        :=  l_cle_id;
            end if;

        l_rgpv_rec.rgd_code      :=  'LALEVL';
        l_rgpv_rec.rgp_type      :=  'KRG';




        OKL_RULE_PUB.create_rule_group(
            p_api_version                =>  p_api_version,
            p_init_msg_list              =>  p_init_msg_list,
            x_return_status              =>  x_return_status,
            x_msg_count                  =>  x_msg_count,
            x_msg_data                   =>  x_msg_data,
            p_rgpv_rec                   =>  l_rgpv_rec,
            x_rgpv_rec                   =>  lx_rgpv_rec);


            l_rgp_id := lx_rgpv_rec.id;

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        end if;


        IF(l_slh_id is null or l_slh_id = OKL_API.G_MISS_NUM) then
            l_rulv_rec := l_rulv_rec2;
--            l_rulv_rec.object_version_number    := l_rgr_rec.object_version_number;
            l_rulv_rec.dnz_chr_id               := p_chr_id;
            l_rulv_rec.rgp_id                   := l_rgp_id;
            l_rulv_rec.jtot_object1_code        := 'OKL_STRMTYP';
            l_rulv_rec.object1_id1              := p_payment_id;
            l_rulv_rec.std_template_yn          := 'N';
            l_rulv_rec.warn_yn                  := 'N';
            l_rulv_rec.template_yn              := 'N';
            l_rulv_rec.sfwt_flag                := 'N';
            l_rulv_rec.rule_information_category := 'LASLH';

            OKL_RULE_PUB.create_rule(
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_rulv_rec            => l_rulv_rec,
                  x_rulv_rec            => lx_rulv_rec);

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_slh_id := lx_rulv_rec.id;
         end if;

        OPEN  FEE_LINE_CSR(l_rgp_id);
        FETCH FEE_LINE_CSR INTO l_fee_line_type;
        CLOSE FEE_LINE_CSR;

      open  CHR_DTLS_CSR(p_chr_id);
      -- bug
      fetch CHR_DTLS_CSR into l_org_id, l_ccode, l_deal_type;
      l_start_date := get_start_date(p_chr_id, l_cle_id);
      -- bug
      close CHR_DTLS_CSR;
       MO_GLOBAL.set_policy_context('S',l_org_id);


       j := 0;
       k := 0;
       l := 0;

       if(p_pym_tbl.count > 0) then
       i := p_pym_tbl.FIRST;
       loop
         l_rulv_rec := null;
         empty_rec := check_rec(p_pym_tbl(i));

         if(p_pym_tbl(i).update_type = 'DELETE' or (empty_rec
            and p_pym_tbl(i).rule_id is not null and p_pym_tbl(i).rule_id <> OKL_API.G_MISS_NUM)) then
            l_rulv_rec.id := p_pym_tbl(i).rule_id;
            l := l + 1;
            l_delt_rulv_tbl(l) := l_rulv_rec;

         else if ( not empty_rec) then


            migrate_rec(
            p_chr_id      =>    p_chr_id,
            p_rgp_id      =>    l_rgp_id,
            p_slh_id      =>    l_slh_id,
            p_pym_hdr_rec =>    p_pym_hdr_rec,
            p_pym_rec     =>    p_pym_tbl(i),
            x_rulv_rec    =>    l_rulv_rec);


             validate_payment(
                      p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_rulv_rec           => l_rulv_rec,
                      p_fee_line_type      => l_fee_line_type,
                      p_payment_type       => p_update_type,
                      p_type               => p_pym_tbl(i).update_type);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                   raise OKL_API.G_EXCEPTION_ERROR;
            END IF;

            if(l_rulv_rec.rule_information8 is not null and is_num(l_rulv_rec.rule_information8)) then
                l_rulv_rec.rule_information8 := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(
                               p_amount         => to_number(l_rulv_rec.rule_information8),
                               p_currency_code  => l_ccode);
			        l_totalpayment:=l_totalpayment+l_rulv_rec.rule_information8;
            end if;

            if(l_rulv_rec.rule_information6 is not null and is_num(l_rulv_rec.rule_information6)) then
                l_rulv_rec.rule_information6 := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(
                               p_amount         => to_number(l_rulv_rec.rule_information6),
                               p_currency_code  => l_ccode);
			       l_totalpayment:=l_totalpayment+(l_rulv_rec.rule_information6*l_rulv_rec.rule_information3);
            end if;

            if(p_pym_tbl(i).update_type = 'CREATE') then
                 j := j + 1;
                 l_crea_rulv_tbl(j) := l_rulv_rec;
             else
                 k := k + 1;
                 l_updt_rulv_tbl(k) := l_rulv_rec;
             end if;
            end if;
          end if;

            exit when (i >= p_pym_tbl.last);
            i:= p_pym_tbl.NEXT(i);
        end loop;
    end if;
        IF(not is_investor_fee_payment(p_chr_id =>p_chr_id, p_payment =>l_totalpayment , p_rgp_id => l_rgp_id  )) then
                            x_return_status := OKL_API.g_ret_sts_error;
         OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                 , p_msg_name => 'OKL_LA_INV_PAY_MISMATCH');
         raise OKL_API.G_EXCEPTION_ERROR;
       end if;

    if (l_delt_rulv_tbl.count > 0) then
        OKL_RULE_PUB.delete_rule(
             p_api_version         => p_api_version,
             p_init_msg_list       => p_init_msg_list,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_rulv_tbl            => l_delt_rulv_tbl);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
             END IF;
     end if;

    if (l_crea_rulv_tbl.count > 0) then
        --Bug# 4861465
        i := l_crea_rulv_tbl.FIRST;
        --i := p_pym_tbl.FIRST;
        loop
            l_crea_rulv_tbl(i).rule_information1 := to_char(i);
            exit when (i >= l_crea_rulv_tbl.last);
            i:= l_crea_rulv_tbl.NEXT(i);
        end loop;

        OKL_RULE_PUB.create_rule(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_rulv_tbl           => l_crea_rulv_tbl,
            x_rulv_tbl           => x_rulv_tbl);



        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     end if;

    if (l_updt_rulv_tbl.count > 0) then

    -- added for bug 5115701 - start
          -- check only if it's an asset sub line payment
    IF (p_asset_id IS NOT NULL AND
        p_asset_id <> OKL_API.G_MISS_NUM)
        AND
       (p_service_fee_id IS NOT NULL AND
        p_service_fee_id <> OKL_API.G_MISS_NUM)
    THEN

     OPEN  GET_FEE_TYPE_SUB_CSR(p_chr_id, p_service_fee_id);
     FETCH GET_FEE_TYPE_SUB_CSR INTO l_subline_fee_type;
     CLOSE GET_FEE_TYPE_SUB_CSR;


     IF(l_subline_fee_type IS NOT NULL AND l_subline_fee_type = 'FINANCED') then

                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                        , p_msg_name => 'OKL_LLA_PYMTS_NO_UPDATE');
                raise OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;
-- added for bug 5115701 - End

        OKL_RULE_PUB.update_rule(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_rulv_tbl           => l_updt_rulv_tbl,
            x_rulv_tbl           => x_rulv_tbl);


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    end if;

    if(l_pym_level <> 'HEADER') then
        OPEN  INVALID_LINE_CSR(l_cle_id);
        FETCH INVALID_LINE_CSR INTO l_invalid_line;
        CLOSE INVALID_LINE_CSR;
    end if;

    l_detail_count := get_sll_period_count(l_rgp_id,
                                           l_slh_id,
                                           p_chr_id);
    if( l_detail_count  < 1 and l_invalid_line = 'N') then
         IF (l_deal_type NOT IN ('LOAN', 'LOAN-REVOLVING')) THEN  -- Bug 4887014
         x_return_status := OKL_API.g_ret_sts_error;
         OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                 , p_msg_name => 'OKL_LLA_PYM_ONE_PERIOD');
         raise OKL_API.G_EXCEPTION_ERROR;
         END IF;
    end if;
    if(l_fee_line_type is not null and l_fee_line_type = 'SECDEPOSIT') then
        l_detail_count := verify_sec_deposit_count(l_rgp_id,
                                                   l_slh_id,
                                                   p_chr_id);
        if( l_detail_count  > 1 ) then
             x_return_status := OKL_API.g_ret_sts_error;
             OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                     , p_msg_name => 'OKL_LLA_PYMTS_FEE_PERIOD');
             raise OKL_API.G_EXCEPTION_ERROR;
        end if;
    end if;


    calculate_details(
                      p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_chr_id             => p_chr_id,
                      p_rgp_id             => l_rgp_id,
                      p_slh_id             => l_slh_id,
                      structure            => p_pym_hdr_rec.STRUCTURE,
                      frequency            => p_pym_hdr_rec.FREQUENCY,
                      arrears              => p_pym_hdr_rec.ARREARS);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      lx_rulv_tbl(1).id         := l_slh_id;
      lx_rulv_tbl(1).rgp_id     := l_rgp_id;
      lx_rulv_tbl(1).dnz_chr_id := p_chr_id;

      x_rulv_tbl := lx_rulv_tbl;

      -- R12B Authoring OA Migration
      IF (l_upfront_tax_pymt_yn = OKL_API.G_TRUE) THEN
        IF (l_contract_rec.sts_code IN ('PASSED','COMPLETE','APPROVED','PENDING_APPROVAL')) THEN

          OKL_LA_PAYMENTS_PVT.process_upfront_tax_pymt(
            p_api_version     => p_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_chr_id          => p_chr_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
      END IF;

      -- Bug# 7440232
      -- Delete Interest Rate payments for FIXED/STREAMS
      -- Loans when all Principal payments are deleted
      OKL_LA_PAYMENTS_PVT.delete_interest_rate_params(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_chr_id          => p_chr_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END process_payment;


PROCEDURE variable_interest_payment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
                                   ) IS
  i NUMBER := 0;
  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

  l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
  lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;
  -- x_rulv_tbl  OKL_RULE_PUB.RULV_TBL_TYPE;

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'VARIABLE_INTEREST_PAYMENT';
  l_api_version            CONSTANT NUMBER    := 1.0;

  l_payment_id    NUMBER;
  l_pym_hdr_rec   PYM_HDR_REC_TYPE;
  l_pym_tbl       PYM_TBL_TYPE;

  l_flag          VARCHAR2(1) := 'N';
  l_term          okl_k_headers.term_duration%TYPE;

    l_pym_level       VARCHAR2(30) := 'HEADER';
    l_slh_id          OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    l_rgp_id          OKC_RULE_GROUPS_V.ID%TYPE := OKL_API.G_MISS_NUM;
    l_cle_id          OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;

-- x_return_status varchar2(1);
 x_primary_sty_id okl_strm_type_b.ID%TYPE;

  /*
  *CURSOR VIR_PAYMENT (P_CHR_ID IN NUMBER) IS
  *SELECT 'Y', K.TERM_DURATION
  *FROM  OKC_RULES_B IVAR, OKC_RULES_B INTP, OKC_RULE_GROUPS_B RG, OKL_K_HEADERS K
  *WHERE
  *IVAR.RULE_INFORMATION_CATEGORY = 'LAIVAR' AND IVAR.RULE_INFORMATION1 = 'FLOAT' AND
  *INTP.RULE_INFORMATION_CATEGORY = 'LAINTP' AND INTP.RULE_INFORMATION1 = 'Y' AND
  *RG.ID = IVAR.RGP_ID AND RG.RGD_CODE = 'LAIIND' AND RG.ID = INTP.RGP_ID
  *AND K.ID = P_CHR_ID AND RG.DNZ_CHR_ID = P_CHR_ID AND RG.CHR_ID = P_CHR_ID;
  */

  CURSOR VIR_PAYMENT (P_CHR_ID IN NUMBER) IS
  SELECT IVAR.RULE_INFORMATION1 var_method,
         K.DEAL_TYPE deal_type,
         ICLC.RULE_INFORMATION5 calc_method,
         K.TERM_DURATION
  FROM
         OKC_RULES_B IVAR,
         OKC_RULES_B INTP,
         OKC_RULES_B ICLC,
         OKC_RULE_GROUPS_B RG,
         OKL_K_HEADERS K
  WHERE
         IVAR.RULE_INFORMATION_CATEGORY = 'LAIVAR'
         AND INTP.RULE_INFORMATION_CATEGORY = 'LAINTP'
         AND ICLC.RULE_INFORMATION_CATEGORY = 'LAICLC'
         AND INTP.RULE_INFORMATION1 = 'Y'
         AND RG.ID = IVAR.RGP_ID
         AND RG.RGD_CODE = 'LAIIND'
         AND RG.ID = INTP.RGP_ID
         AND RG.ID = ICLC.RGP_ID
         AND RG.CLE_ID IS NULL
         AND K.ID = P_CHR_ID
         AND RG.DNZ_CHR_ID = P_CHR_ID
         AND RG.CHR_ID = P_CHR_ID;

  l_deal_type OKL_K_HEADERS.deal_type%TYPE;
  l_var_method OKC_RULES_B.RULE_INFORMATION1%TYPE;
  l_calc_method OKC_RULES_B.RULE_INFORMATION5%TYPE;
  l_data_found BOOLEAN;

/*
  cursor PAYMENT_TYPE is
      SELECT ID1
      FROM OKL_STRMTYP_SOURCE_V WHERE
      CODE = 'VARIABLE_INTEREST';
      */

  begin

        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => p_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;


        --Bug 4018298
        OPEN  VIR_PAYMENT(P_CHR_ID);
        FETCH VIR_PAYMENT INTO l_var_method, l_deal_type, l_calc_method, l_term;
        l_data_found := VIR_PAYMENT%FOUND;
        CLOSE VIR_PAYMENT;
        IF ( l_data_found
             AND ( l_deal_type = 'LOAN-REVOLVING' OR l_deal_type = 'LOAN' )
             AND l_var_method = 'FLOAT' AND l_calc_method = 'FORMULA') THEN

          OKL_STREAMS_UTIL.get_primary_stream_type(
                           p_khr_id               => p_chr_id,
                           p_primary_sty_purpose  => 'VARIABLE_INTEREST',
                           x_return_status        => l_return_status,
                           x_primary_sty_id       => l_payment_id
               );

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
             raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
             raise OKL_API.G_EXCEPTION_ERROR;
          END IF;

          /*
          OPEN  PAYMENT_TYPE;
          FETCH PAYMENT_TYPE INTO l_payment_id;
          CLOSE PAYMENT_TYPE;
          */

          get_payment(
                     p_api_version     =>  p_api_version,
                     p_init_msg_list   =>  p_init_msg_list,
                     x_return_status   =>  x_return_status,
                     x_msg_count       =>  x_msg_count,
                     x_msg_data        =>  x_msg_data,
                     p_chr_id          =>  p_chr_id,
                     p_service_fee_id  =>  null,
                     p_asset_id        =>  null,
                     p_payment_id      =>  l_payment_id,
                     x_pym_level       =>  l_pym_level,
                     x_slh_id          =>  l_slh_id,
                     x_rgp_id          =>  l_rgp_id,
                     x_cle_id          =>  l_cle_id);


          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
          END IF;

          if(l_slh_id is not null and l_slh_id <> OKL_API.G_MISS_NUM) then
              OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                   x_msg_data     => x_msg_data);
              return;
          end if;

          /*OPEN  VIR_PAYMENT(P_CHR_ID);
          *FETCH VIR_PAYMENT INTO l_flag, l_term;
          *CLOSE VIR_PAYMENT;
          *
          *if(l_flag <> 'Y') then
          *    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
          *                         x_msg_data     => x_msg_data);
          *    return;
          *end if;
          */

          l_pym_hdr_rec.STRUCTURE := 0;
          l_pym_hdr_rec.STRUCTURE_NAME := NULL;
          l_pym_hdr_rec.FREQUENCY := 'M';
          l_pym_hdr_rec.FREQUENCY_NAME := NULL;
          l_pym_hdr_rec.ARREARS := 'Y';
          l_pym_hdr_rec.ARREARS_NAME := NULL;

          l_pym_tbl(1).RULE_ID := NULL;
          l_pym_tbl(1).STUB_DAYS := NULL;
          l_pym_tbl(1).STUB_AMOUNT := NULL;
--        l_pym_tbl(1).PERIOD := 1;
          l_pym_tbl(1).PERIOD := l_term;
          l_pym_tbl(1).AMOUNT := NULL;
          l_pym_tbl(1).SORT_DATE := NULL;
          l_pym_tbl(1).UPDATE_TYPE := 'CREATE';


          process_payment(
                          p_api_version     =>  p_api_version,
                          p_init_msg_list   =>  p_init_msg_list,
                          x_return_status   =>  x_return_status,
                          x_msg_count       =>  x_msg_count,
                          x_msg_data        =>  x_msg_data,
                          p_chr_id          =>  p_chr_id,
                          p_service_fee_id  =>  null,
                          p_asset_id        =>  null,
                          p_payment_id      => l_payment_id,
                          p_pym_hdr_rec     => l_pym_hdr_rec,
                          p_pym_tbl         => l_pym_tbl,
                          p_update_type     => 'VIR_PAYMENT',
                          x_rulv_tbl        => x_rulv_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

-- ----------------------------------------

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END variable_interest_payment;



PROCEDURE process_payment(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  OKC_K_HEADERS_B.ID%TYPE,
    p_service_fee_id               IN  OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_asset_id                     IN  OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM,
    p_payment_id                   IN  OKL_STRMTYP_SOURCE_V.ID1%TYPE,
    p_update_type                  IN  VARCHAR2,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'PROCESS_PAYMENT2';
  l_api_version            CONSTANT NUMBER    := 1.0;

  l_pym_level       VARCHAR2(30) := 'HEADER';
  l_subline_id      OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;
  l_slh_id          OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM;
  l_rgp_id          OKC_RULE_GROUPS_V.ID%TYPE := OKL_API.G_MISS_NUM;
  l_cle_id          OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;
  l_stream_id       OKL_STRMTYP_SOURCE_V.ID1%TYPE := OKL_API.G_MISS_NUM;

  lx_rulv_tbl     rulv_tbl_type;

  -- R12B Authoring OA Migration
  l_upfront_tax_pymt_yn VARCHAR2(1);

  CURSOR l_contract_csr(p_chr_id IN NUMBER) IS
  SELECT chrb.sts_code
  FROM okc_k_headers_b chrb
  WHERE chrb.id = p_chr_id;

  l_contract_rec l_contract_csr%ROWTYPE;

  begin

        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => p_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

/* -- temp
    open get_dir;
    fetch get_dir into l_temp_dir;
    if get_dir%notfound then
       null;
    end if;
    close get_dir;
    */
   --fnd_file.put_names(l_log, l_out, l_temp_dir);
-- temp

  -- R12B Authoring OA Migration
  -- Check if the Payment is for an Upfront Tax Fee line
  l_upfront_tax_pymt_yn := OKL_API.G_FALSE;
  IF (p_service_fee_id IS NOT NULL) THEN
    l_upfront_tax_pymt_yn := is_upfront_tax_fee_payment(p_chr_id => p_chr_id,
                                                        p_cle_id => p_service_fee_id);

    IF (l_upfront_tax_pymt_yn = OKL_API.G_TRUE) THEN
      OPEN l_contract_csr(p_chr_id => p_chr_id);
      FETCH l_contract_csr INTO l_contract_rec;
      CLOSE l_contract_csr;
    END IF;
  END IF;

-- START: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement
    x_return_status := validate_capitalize_dp
                       (p_asset_id       => p_asset_id,
                        p_service_fee_id => p_service_fee_id,
                        p_payment_id     => p_payment_id);
    --- Store the highest degree of error
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- END: June 24, 2005 cklee: Modification for okl.h Sales Quote enhancement

        /* -- 4542290 Do not create var interest schedules. Will do from
              contract creation API
        if(p_update_type is not null and p_update_type = 'VIR_PAYMENT') then
            variable_interest_payment(
                                p_api_version     =>  p_api_version,
                                p_init_msg_list   =>  p_init_msg_list,
                                x_return_status   =>  x_return_status,
                                x_msg_count       =>  x_msg_count,
                                x_msg_data        =>  x_msg_data,
                                p_chr_id          =>  p_chr_id,
                                x_rulv_tbl        =>  lx_rulv_tbl
                                );

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            END IF;
/*
            lx_rulv_tbl(1).id         := l_slh_id;
            lx_rulv_tbl(1).rgp_id     := l_rgp_id;
            lx_rulv_tbl(1).dnz_chr_id := p_chr_id;
            */

            /* - 4542290
            x_rulv_tbl := lx_rulv_tbl;

 --Call End Activity
            OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                     x_msg_data     => x_msg_data);
            return;

        end if; */

--       else

        get_payment(
                p_api_version     =>  p_api_version,
                p_init_msg_list   =>  p_init_msg_list,
                x_return_status   =>  x_return_status,
                x_msg_count       =>  x_msg_count,
                x_msg_data        =>  x_msg_data,
                p_chr_id          =>  p_chr_id,
                p_service_fee_id  =>  p_service_fee_id,
                p_asset_id        =>  p_asset_id,
                p_payment_id      =>  p_payment_id,
                x_pym_level       =>  l_pym_level,
                x_slh_id          =>  l_slh_id,
                x_rgp_id          =>  l_rgp_id,
                x_cle_id          =>  l_cle_id);


         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --Bug# 4959361
         IF l_cle_id IS NOT NULL THEN
           OKL_LLA_UTIL_PVT.check_line_update_allowed
             (p_api_version     => p_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              p_cle_id          => l_cle_id);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
         --Bug# 4959361

        if(p_update_type is not null and p_update_type = 'DELETE') then
            if(l_slh_id is not null and l_slh_id <> OKL_API.G_MISS_NUM
               and l_rgp_id is not null and l_rgp_id <> OKL_API.G_MISS_NUM) then
               OKL_PAYMENT_APPLICATION_PUB.delete_payment(
                        p_api_version     =>  p_api_version,
                        p_init_msg_list   =>  p_init_msg_list,
                        x_return_status   =>  x_return_status,
                        x_msg_count       =>  x_msg_count,
                        x_msg_data        =>  x_msg_data,
                        p_chr_id          =>  p_chr_id,
                        p_rgp_id          =>  l_rgp_id,
                        p_rule_id         =>  l_slh_id);

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                           raise OKL_API.G_EXCEPTION_ERROR;
                    END IF;
            else
                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                        , p_msg_name => 'OKL_LLA_PMT_SELECT');
                raise OKL_API.G_EXCEPTION_ERROR;
            end if;
       elsif(p_update_type is not null and p_update_type = 'APPLY') then
            if(p_chr_id is not null and p_chr_id <> OKL_API.G_MISS_NUM
               and p_payment_id is not null and p_payment_id <> OKL_API.G_MISS_NUM) then
                   l_stream_id := to_char(p_payment_id);
               if is_prop_tax_payment(l_stream_id) then
                    OKL_PAYMENT_APPLICATION_PVT.apply_propery_tax_payment(
                        p_api_version     =>  p_api_version,
                        p_init_msg_list   =>  p_init_msg_list,
                        x_return_status   =>  x_return_status,
                        x_msg_count       =>  x_msg_count,
                        x_msg_data        =>  x_msg_data,
                        p_chr_id          =>  p_chr_id,
                        p_stream_id       =>  l_stream_id);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                           raise OKL_API.G_EXCEPTION_ERROR;
                    END IF;
               /* Manu 13-Sep-2004. For Rollover Fee Payment */
-- start: cklee: 6/22/05 -- okl.h
--               elsif is_rollover_fee_payment(p_service_fee_id) then
               elsif is_eligible_fee_payment(p_service_fee_id) then
-- end: cklee: 6/22/05 -- okl.h
--                    OKL_PAYMENT_APPLICATION_PVT.apply_rollover_fee_payment(
                    OKL_PAYMENT_APPLICATION_PVT.apply_eligible_fee_payment(
-- end: cklee: 6/22/05 -- okl.h
                         p_api_version     =>  p_api_version,
                         p_init_msg_list   =>  p_init_msg_list,
                         x_return_status   =>  x_return_status,
                         x_msg_count       =>  x_msg_count,
                         x_msg_data        =>  x_msg_data,
                         p_chr_id          =>  p_chr_id,
                         p_kle_id          =>  p_service_fee_id,
                        p_stream_id        =>  l_stream_id);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                           raise OKL_API.G_EXCEPTION_ERROR;
                    END IF;
               else
                    OKL_PAYMENT_APPLICATION_PUB.apply_payment(
                        p_api_version     =>  p_api_version,
                        p_init_msg_list   =>  p_init_msg_list,
                        x_return_status   =>  x_return_status,
                        x_msg_count       =>  x_msg_count,
                        x_msg_data        =>  x_msg_data,
                        p_chr_id          =>  p_chr_id,
                        p_stream_id       =>  l_stream_id);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                           raise OKL_API.G_EXCEPTION_ERROR;
                    END IF;
               end if;
            else
                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                        , p_msg_name => 'OKL_LLA_PMT_SELECT');
                raise OKL_API.G_EXCEPTION_ERROR;
            end if;
       elsif(p_update_type is not null and p_update_type = 'CALCULATE') then
            if(l_slh_id is not null and l_slh_id <> OKL_API.G_MISS_NUM
               and l_rgp_id is not null and l_rgp_id <> OKL_API.G_MISS_NUM) then

                   calculate_details(
                          p_api_version        => p_api_version,
                          p_init_msg_list      => p_init_msg_list,
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_chr_id             => p_chr_id,
                          p_rgp_id             => l_rgp_id,
                          p_slh_id             => l_slh_id,
                          structure            => null,
                          frequency            => null,
                          arrears              => null);

                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;

            else
                x_return_status := OKL_API.g_ret_sts_error;
                OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                        , p_msg_name => 'OKL_LLA_PMT_SELECT');
                raise OKL_API.G_EXCEPTION_ERROR;
            end if;
    end if;

--  end if;

    lx_rulv_tbl(1).id         := l_slh_id;
    lx_rulv_tbl(1).rgp_id     := l_rgp_id;
    lx_rulv_tbl(1).dnz_chr_id := p_chr_id;

    x_rulv_tbl := lx_rulv_tbl;

    -- R12B Authoring OA Migration
    IF (l_upfront_tax_pymt_yn = OKL_API.G_TRUE) THEN
      IF (l_contract_rec.sts_code IN ('PASSED','COMPLETE','APPROVED','PENDING_APPROVAL')) THEN

        OKL_LA_PAYMENTS_PVT.process_upfront_tax_pymt(
          p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_chr_id          => p_chr_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;
    END IF;

    -- Bug# 7440232
    -- Delete Interest Rate payments for FIXED/STREAMS
    -- Loans when all Principal payments are deleted
    OKL_LA_PAYMENTS_PVT.delete_interest_rate_params(
      p_api_version     => p_api_version,
      p_init_msg_list   => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chr_id          => p_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END process_payment;

PROCEDURE delete_payment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_pym_tbl                  IN  pym_del_tbl_type,
   -- Bug #7498330
    p_source_trx                   IN  VARCHAR2 DEFAULT 'NA') IS


  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'DELETE_PAYMENT';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;

  -- R12B Authoring OA Migration
  l_upfront_tax_pymt_yn VARCHAR2(1);

  CURSOR l_contract_csr(p_chr_id IN NUMBER) IS
  SELECT chrb.sts_code
  FROM okc_k_headers_b chrb
  WHERE chrb.id = p_chr_id;

  l_contract_rec l_contract_csr%ROWTYPE;

  CURSOR l_pymt_cle_csr(p_rgp_id IN NUMBER) IS
  SELECT rgp.cle_id  pymt_cle_id,
         cleb.cle_id parent_cle_id
  FROM okc_rule_groups_b rgp,
       okc_k_lines_b cleb
  WHERE rgp.id = p_rgp_id
  AND   cleb.id = rgp.cle_id;

  l_pymt_cle_rec   l_pymt_cle_csr%ROWTYPE;
  l_cle_id         OKC_K_LINES_B.id%TYPE;
  l_chr_id         OKC_K_HEADERS_B.id%TYPE;

  begin

        x_return_status := OKL_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
        END IF;


     -- R12B Authoring OA Migration
     -- Check if the Payment is for an Upfront Tax Fee line
     l_upfront_tax_pymt_yn := OKL_API.G_FALSE;

      if (p_del_pym_tbl.count > 0) then
      i := p_del_pym_tbl.FIRST;
      loop
 --bug # 7498330 added check for source trx is Termination (TQ)
 --added by rkuttiya
       IF p_source_trx <> 'TQ' THEN
          if( is_ppd_payment(p_del_pym_tbl(i).slh_id)) then
             x_return_status := OKL_API.g_ret_sts_error;
             OKL_API.SET_MESSAGE(      p_app_name => g_app_name
                                     , p_msg_name => 'OKL_LA_PPD_PAYMENT');
             raise OKL_API.G_EXCEPTION_ERROR;
          end if;
       END IF;

      -- R12B Authoring OA Migration
      -- Check if the Payment is for an Upfront Tax Fee line
      IF (p_del_pym_tbl(i).rgp_id IS NOT NULL) THEN

        OPEN l_pymt_cle_csr(p_rgp_id => p_del_pym_tbl(i).rgp_id);
        FETCH l_pymt_cle_csr INTO l_pymt_cle_rec;
        CLOSE l_pymt_cle_csr;

        l_cle_id := NVL(l_pymt_cle_rec.parent_cle_id,l_pymt_cle_rec.pymt_cle_id);

        IF l_cle_id IS NOT NULL THEN

          l_chr_id := p_del_pym_tbl(i).chr_id;
          IF (is_upfront_tax_fee_payment(p_chr_id => l_chr_id,
                                         p_cle_id => l_cle_id) = OKL_API.G_TRUE) THEN
            l_upfront_tax_pymt_yn := OKL_API.G_TRUE;

            OPEN l_contract_csr(p_chr_id => l_chr_id);
            FETCH l_contract_csr INTO l_contract_rec;
            CLOSE l_contract_csr;
          END IF;
        END IF;
      END IF;

    OKL_PAYMENT_APPLICATION_PUB.delete_payment(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_chr_id           => p_del_pym_tbl(i).chr_id,
        p_rgp_id           => p_del_pym_tbl(i).rgp_id,
        p_rule_id          => p_del_pym_tbl(i).slh_id);



      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    exit when (i >= p_del_pym_tbl.last);
    i:= p_del_pym_tbl.NEXT(i);
    end loop;
  end if;

   -- R12B Authoring OA Migration
   IF (l_upfront_tax_pymt_yn = OKL_API.G_TRUE) THEN
     IF (l_contract_rec.sts_code IN ('PASSED','COMPLETE','APPROVED','PENDING_APPROVAL')) THEN

        OKL_LA_PAYMENTS_PVT.process_upfront_tax_pymt(
          p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_chr_id          => l_chr_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;
   END IF;

   -- Bug# 7440232
   -- Delete Interest Rate payments for FIXED/STREAMS
   -- Loans when all Principal payments are deleted
   OKL_LA_PAYMENTS_PVT.delete_interest_rate_params(
     p_api_version     => p_api_version,
     p_init_msg_list   => p_init_msg_list,
     x_return_status   => x_return_status,
     x_msg_count       => x_msg_count,
     x_msg_data        => x_msg_data,
     p_chr_id          => p_del_pym_tbl(i).chr_id);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END delete_payment;

FUNCTION get_term(p_id IN NUMBER) RETURN NUMBER IS
CURSOR contract_csr(p_contract_id NUMBER) IS
SELECT TERM_DURATION
FROM   OKL_K_HEADERS
WHERE  ID = p_contract_id;
begin
  for r IN contract_csr(p_id)
  LOOP
    return (r.TERM_DURATION);
  END LOOP;
end;

PROCEDURE variable_interest_schedule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
                                   ) IS
  i NUMBER := 0;

  l_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
  lx_rulv_rec OKL_RULE_PUB.rulv_rec_type;
  -- x_rulv_tbl  OKL_RULE_PUB.RULV_TBL_TYPE;

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) :='VARIABLE_INTEREST_SCHEDULE';
  l_api_version            CONSTANT NUMBER    := 1.0;

  l_payment_id    NUMBER;
  l_pym_hdr_rec   PYM_HDR_REC_TYPE;
  l_pym_tbl       PYM_TBL_TYPE;

  l_term          okl_k_headers.term_duration%TYPE;

    l_pym_level       VARCHAR2(30) := 'HEADER';
    l_slh_id          OKC_RULES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    l_rgp_id          OKC_RULE_GROUPS_V.ID%TYPE := OKL_API.G_MISS_NUM;
    l_cle_id          OKC_K_LINES_B.ID%TYPE := OKL_API.G_MISS_NUM;

 x_primary_sty_id okl_strm_type_b.ID%TYPE;

  l_deal_type OKL_K_HEADERS.deal_type%TYPE;
  l_interest_calculation_basis VARCHAR2(30);
  l_revenue_recognition_method VARCHAR2(30);
  l_data_found BOOLEAN;
  l_pdt_parameter_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

  -- 4895333
  CURSOR get_sts_code_csr(p_id NUMBER) IS
  SELECT sts_code
  FROM   OKC_K_HEADERS_B
  WHERE  ID = p_id;
  l_sts_code okc_k_headers_b.sts_code%type;

  CURSOR var_int_sched_counter_csr(p_id NUMBER,  p_stream_id NUMBER) IS
  SELECT COUNT(1) counter
  FROM   OKC_RULES_B
  WHERE  DNZ_CHR_ID = p_id
  AND    rule_information_category = 'LASLH'
  AND    object1_id1 = to_char(p_stream_id);

  l_var_int_sched_counter NUMBER;

begin
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In variable_interest_schedule... p_chr_id=' || p_chr_id);
  END IF;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => p_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
    raise OKL_API.G_EXCEPTION_ERROR;
  END IF;


  /*
  OKL_K_RATE_PARAMS_PVT.get_product(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => p_chr_id,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

  l_interest_calculation_basis :=l_pdt_parameter_rec.interest_calculation_basis;
  l_revenue_recognition_method :=l_pdt_parameter_rec.revenue_recognition_method;
  l_deal_type := l_pdt_parameter_rec.deal_type;

  l_term := get_term(p_chr_id);

  okl_debug_pub.logmessage('p_chr_id=' || p_chr_id);
  okl_debug_pub.logmessage('l_int_cal_basis=' || l_interest_calculation_basis);
  okl_debug_pub.logmessage('l_rev_rec_method=' || l_revenue_recognition_method);
  okl_debug_pub.logmessage('l_deal_type=' || l_deal_type);
  IF ( l_deal_type = 'LOAN' AND
       l_interest_calculation_basis IN ('FLOAT', 'CATCHUP/CLEANUP') ) OR
     ( l_deal_type = 'LOAN-REVOLVING' AND
       l_interest_calculation_basis = 'FLOAT' ) THEN
  */

  -- 4722839
  l_term := get_term(p_chr_id);

    OKL_STREAMS_UTIL.get_primary_stream_type(
                     p_khr_id               => p_chr_id,
                     p_primary_sty_purpose  => 'VARIABLE_INTEREST_SCHEDULE',
                     x_return_status        => l_return_status,
                     x_primary_sty_id       => l_payment_id
                  );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- 4895333
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_payment_id=' || l_payment_id);
    END IF;
    FOR r IN get_sts_code_csr(p_chr_id)
    LOOP
      l_sts_code := r.sts_code;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_sts_code=' || l_sts_code);

    END IF;
    FOR r_var_int_sched_counter_csr IN
         var_int_sched_counter_csr(p_chr_id, l_payment_id)
    LOOP
      l_var_int_sched_counter := r_var_int_sched_counter_csr.counter;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_var_int_sched_counter=' || l_var_int_sched_counter);
    END IF;
    -- 4895333
    IF (l_var_int_sched_counter < 1) AND (l_sts_code <> 'BOOKED') THEN
      get_payment(
                         p_api_version     =>  p_api_version,
                         p_init_msg_list   =>  p_init_msg_list,
                         x_return_status   =>  x_return_status,
                         x_msg_count       =>  x_msg_count,
                         x_msg_data        =>  x_msg_data,
                         p_chr_id          =>  p_chr_id,
                         p_service_fee_id  =>  null,
                         p_asset_id        =>  null,
                         p_payment_id      =>  l_payment_id,
                         x_pym_level       =>  l_pym_level,
                         x_slh_id          =>  l_slh_id,
                         x_rgp_id          =>  l_rgp_id,
                         x_cle_id          =>  l_cle_id);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      if(l_slh_id is not null and l_slh_id <> OKL_API.G_MISS_NUM) then
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_slh_id null... cant create...');
        END IF;
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                             x_msg_data     => x_msg_data);
        return;
      end if;

      l_pym_hdr_rec.STRUCTURE := 0;
      l_pym_hdr_rec.STRUCTURE_NAME := NULL;
      l_pym_hdr_rec.FREQUENCY := 'M';
      l_pym_hdr_rec.FREQUENCY_NAME := NULL;
      l_pym_hdr_rec.ARREARS := 'Y';
      l_pym_hdr_rec.ARREARS_NAME := NULL;

      l_pym_tbl(1).RULE_ID := NULL;
      l_pym_tbl(1).STUB_DAYS := NULL;
      l_pym_tbl(1).STUB_AMOUNT := NULL;
      --l_pym_tbl(1).PERIOD := 1;
      l_pym_tbl(1).PERIOD := l_term;
      -- 4722839
      l_pym_tbl(1).AMOUNT := 0;
      l_pym_tbl(1).SORT_DATE := NULL;
      l_pym_tbl(1).UPDATE_TYPE := 'CREATE';


      process_payment(
                              p_api_version     =>  p_api_version,
                              p_init_msg_list   =>  p_init_msg_list,
                              x_return_status   =>  x_return_status,
                              x_msg_count       =>  x_msg_count,
                              x_msg_data        =>  x_msg_data,
                              p_chr_id          =>  p_chr_id,
                              p_service_fee_id  =>  null,
                              p_asset_id        =>  null,
                              p_payment_id      => l_payment_id,
                              p_pym_hdr_rec     => l_pym_hdr_rec,
                              p_pym_tbl         => l_pym_tbl,
                              p_update_type     => 'VIR_PAYMENT',
                              x_rulv_tbl        => x_rulv_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF; -- if counter < 1
  /* END IF; */

  OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                       x_msg_data     => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END variable_interest_schedule;

--Bug# 6438785
-- Update the start dates for payments when the Contract start date
-- or Line start date is changed.
PROCEDURE update_pymt_start_date(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT NULL) IS

  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) :='UPDATE_PYMT_START_DATE';
  l_api_version            CONSTANT NUMBER    := 1.0;

  CURSOR c_all_pymts_csr(p_chr_id NUMBER) IS
  SELECT rgp.id rgp_lalevl_id,
         slh.id rul_laslh_id,
         rgp.cle_id
  FROM okc_rule_groups_b rgp,
       okc_rules_b slh,
       okc_k_lines_b cle,
       okc_statuses_b sts
  WHERE rgp.dnz_chr_id = p_chr_id
  AND   rgp.rgd_code = 'LALEVL'
  AND   slh.rgp_id = rgp.id
  AND   slh.dnz_chr_id = rgp.dnz_chr_id
  AND   slh.rule_information_category = 'LASLH'
  AND   cle.id (+) = rgp.cle_id
  AND   cle.sts_code = sts.code (+)
  AND   sts.ste_code (+) NOT IN ('EXPIRED','TERMINATED','CANCELLED');

  CURSOR c_line_pymts_csr(p_cle_id NUMBER,
                          p_chr_id NUMBER) IS
  SELECT rgp.id rgp_lalevl_id,
         slh.id rul_laslh_id,
         rgp.cle_id
  FROM okc_rule_groups_b rgp,
       okc_rules_b slh,
       okc_k_lines_b cle,
       okc_statuses_b sts
  WHERE rgp.dnz_chr_id = p_chr_id
  AND   (rgp.cle_id = p_cle_id OR
         rgp.cle_id IN (SELECT cle_sub.id
                        FROM okc_k_lines_b cle_sub
                        WHERE cle_sub.cle_id = p_cle_id
                        AND   cle_sub.dnz_chr_id = p_chr_id))
  AND   rgp.rgd_code = 'LALEVL'
  AND   slh.rgp_id = rgp.id
  AND   slh.dnz_chr_id = rgp.dnz_chr_id
  AND   slh.rule_information_category = 'LASLH'
  AND   cle.id = rgp.cle_id
  AND   cle.sts_code = sts.code
  AND   sts.ste_code NOT IN ('EXPIRED','TERMINATED','CANCELLED');

begin
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  x_return_status := OKL_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => p_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

  -- check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
    raise OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF p_cle_id IS NOT NULL THEN

    FOR r_line_pymts_rec IN c_line_pymts_csr(p_chr_id => p_chr_id,
                                             p_cle_id => p_cle_id) LOOP

      calculate_details(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_chr_id             => p_chr_id,
        p_rgp_id             => r_line_pymts_rec.rgp_lalevl_id,
        p_slh_id             => r_line_pymts_rec.rul_laslh_id,
        structure            => NULL,
        frequency            => NULL,
        arrears              => NULL,
        p_validate_date_yn   => 'N');

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

  ELSE

    FOR r_all_pymts_rec IN c_all_pymts_csr(p_chr_id => p_chr_id) LOOP

      calculate_details(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_chr_id             => p_chr_id,
        p_rgp_id             => r_all_pymts_rec.rgp_lalevl_id,
        p_slh_id             => r_all_pymts_rec.rul_laslh_id,
        structure            => NULL,
        frequency            => NULL,
        arrears              => NULL,
        p_validate_date_yn   => 'N');

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;
  END IF;

  OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                       x_msg_data     => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


  END update_pymt_start_date;

END OKL_LA_PAYMENTS_PVT;

/
