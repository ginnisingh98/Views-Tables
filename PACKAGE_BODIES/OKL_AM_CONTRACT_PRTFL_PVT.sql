--------------------------------------------------------
--  DDL for Package Body OKL_AM_CONTRACT_PRTFL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CONTRACT_PRTFL_PVT" AS
/* $Header: OKLRPTFB.pls 120.2 2006/07/12 09:03:58 dpsingh noship $ */

-- Start of comments
--
-- Procedure Name  : create_cntrct_prtfl
-- Description     : procedure used to create portfolio management strategy profile.
-- Business Rules  :
-- Parameters      : p_contract_id   : Contract Id
-- Version         : 1.0
-- History         : SECHAWLA  24-DEC-02 : Bug # 2726739
--                   Added logic to store currency codes and conversion factors
--                 : SECHAWLA  21-AUG-03 : Bug # 108113
--                   Perform explicit conversion for rule_information fields
-- End of comments


   PROCEDURE create_cntrct_prtfl(
                        p_api_version                  	IN  NUMBER,
                        p_init_msg_list                	IN  VARCHAR2,
                        x_return_status                	OUT NOCOPY VARCHAR2,
                        x_msg_count                    	OUT NOCOPY NUMBER,
                        x_msg_data                     	OUT NOCOPY VARCHAR2,
                        p_contract_id                   IN  NUMBER) IS

   SUBTYPE pfcv_rec_type IS okl_prtfl_contracts_pub.pfcv_rec_type;
   SUBTYPE pflv_rec_type IS okl_prtfl_lines_pub.pflv_rec_type;

   l_return_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


   l_api_version                     CONSTANT NUMBER := 1;
   l_api_name                        CONSTANT VARCHAR2(30) := 'create_cntrct_prtfl';

   lp_pfcv_rec                       pfcv_rec_type;
   lx_pfcv_rec                       pfcv_rec_type;

   lp_pflv_rec                       pflv_rec_type;
   lx_pflv_rec                       pflv_rec_type;
   l_rulv_rec                        okl_rule_pub.rulv_rec_type;

   l_contract_number                 VARCHAR2(120);
   l_budget_amount                   NUMBER;
   l_strategy                        VARCHAR2(30);
   l_assignment_grp_id               NUMBER;
   l_formulae_id                     NUMBER;
   l_end_date                        DATE;
   l_approval_required               VARCHAR2(1);
   l_dummy                           VARCHAR2(1);
   budget_amount_error               EXCEPTION;
   strategy_error                    EXCEPTION;
   assignment_group_error            EXCEPTION;
   execution_date_error              EXCEPTION;

    --SECHAWLA  Bug # 2726739 : new declarations
    l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_contract_curr_code         okc_k_headers_b.currency_code%TYPE;
    lx_contract_currency         okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount          NUMBER;
    l_sysdate                    DATE;


   -- This cursor is used to get the formulae id
   CURSOR l_formulae_csr(p_name VARCHAR2) IS
   SELECT id
   FROM   okl_formulae_b
   WHERE  name = p_name;

   -- This cursor is used to get the contract end date
   CURSOR l_okcheaders_csr IS
   SELECT end_date, contract_number
   FROM   okc_k_headers_b
   WHERE  id = p_contract_id;

   -- TAPI validation ??
   -- This cursor is used to validate the contract ID
   CURSOR l_oklheaders_csr IS
   SELECT 'x'
   FROM   Okl_K_Headers_V
   WHERE  id   = p_contract_id;

   -- This cursor is used to make sure that the profile does not already exist for a contract.
   CURSOR l_oklprtfl_csr IS
   SELECT 'x'
   FROM   okl_prtfl_cntrcts_b
   WHERE  khr_id = p_contract_id;

   BEGIN

      l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);



      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     -- SECHAWLA  Bug # 2726739 : using sysdate as transaction date for currency conversion routines
     SELECT SYSDATE INTO l_sysdate FROM DUAL;

      IF p_contract_id IS NULL OR p_contract_id = OKL_API.G_MISS_NUM THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- Contarct ID is required
           OKL_API.set_message(    p_app_name      => 'OKC',
                                 p_msg_name      => G_REQUIRED_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'CONTRACT_ID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Validate contarct ID
      OPEN  l_oklheaders_csr;
      FETCH l_oklheaders_csr INTO l_dummy;
      IF l_oklheaders_csr%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Contarct ID is invalid
         OKL_API.set_message(    p_app_name      => 'OKC',
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'CONTRACT_ID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_oklheaders_csr;

      -- get the contarct number and end date
      OPEN  l_okcheaders_csr;
      FETCH l_okcheaders_csr INTO l_end_date, l_contract_number;
      IF l_okcheaders_csr%NOTFOUND THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- Contarct ID is invalid
          OKL_API.set_message(    p_app_name      => 'OKC',
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'Contract Id');
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_okcheaders_csr;

      -- Check if profile already exists
      OPEN  l_oklprtfl_csr;
      FETCH l_oklprtfl_csr INTO l_dummy;
      IF l_oklprtfl_csr%FOUND THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          -- Portfolio Management Strategy Profile already exists for contract CONTRACT_NUMBER.
          OKL_API.set_message(   p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_PROFILE_EXISTS',
                                 p_token1        => 'CONTRACT_NUMBER',
                                 p_token1_value  => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_oklprtfl_csr;

      -- create portfolio header
      lp_pfcv_rec.khr_id := p_contract_id;
      lp_pfcv_rec.line_level_yn := 'N';
      okl_prtfl_contracts_pub.insert_prtfl_contracts(
                                 p_api_version           => p_api_version
                                ,p_init_msg_list         => OKL_API.G_FALSE
                                ,x_return_status         => x_return_status
                                ,x_msg_count             => x_msg_count
                                ,x_msg_data              => x_msg_data
                                ,p_pfcv_rec              => lp_pfcv_rec
                                ,x_pfcv_rec              => lx_pfcv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;


       -- create portfolio line

       -- get budget amount
       okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMCOPO'
                                     ,p_rdf_code         => 'AMPRBA'
                                     ,p_chr_id           => p_contract_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => TRUE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

       IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but formula not found
          IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Portfolio Management DATA is not defined.
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_PRTFL_MISSING_DATA',
                                     p_token1        => 'DATA',
                                     p_token1_value  => 'Budget Amount Option');
               RAISE budget_amount_error;

          END IF;
       ELSE

          RAISE budget_amount_error;
       END IF;

       IF     l_rulv_rec.rule_information1 = 'NOT_APPLICABLE' THEN
              l_budget_amount := NULL;

       ELSIF  l_rulv_rec.rule_information1 = 'USE_FIXED_AMOUNT' THEN
              -- SECHAWLA 21-AUG-03 3108113: Changed G_MISS_NUM to G_MISS_CHAR
              IF l_rulv_rec.rule_information2 IS NULL OR l_rulv_rec.rule_information2 = OKL_API.G_MISS_CHAR THEN
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- -- Portfolio Management DATA is not defined.
                    OKL_API.set_message(  p_app_name      => 'OKL',
                                          p_msg_name      => 'OKL_AM_PRTFL_MISSING_DATA',
                                          p_token1        => 'DATA',
                                          p_token1_value  => 'Budget Amount');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
              ELSE
                    -- SECHAWLA 21-AUG-03 3108113: perform explicit conversion
                    l_budget_amount := to_number(l_rulv_rec.rule_information2);
              END IF;

       ELSIF  l_rulv_rec.rule_information1 = 'USE_FORMULA' THEN

              IF l_rulv_rec.rule_information3 IS NULL OR l_rulv_rec.rule_information3 = OKL_API.G_MISS_CHAR THEN
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Unable to create portfolio management strategy profile because of the missing budget amount formula.
                    OKL_API.set_message(  p_app_name      => 'OKL',
                                          p_msg_name      => 'OKL_AM_MISSING_BA_FORMULA');
                    RAISE budget_amount_error;
              END IF;

              OPEN  l_formulae_csr(l_rulv_rec.rule_information3);
              FETCH l_formulae_csr INTO l_formulae_id;
              IF l_formulae_csr%NOTFOUND THEN
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Budget Amount Formula Name is invalid
                    OKL_API.set_message(    p_app_name      => 'OKC',
                                            p_msg_name      => G_INVALID_VALUE,
                                            p_token1        => G_COL_NAME_TOKEN,
                                            p_token1_value  => 'Budget Amount Formula Name');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              CLOSE l_formulae_csr;

              okl_am_util_pvt.get_formula_value(
                  p_formula_name	=> l_rulv_rec.rule_information3,
                  p_chr_id	        => p_contract_id,
                  p_cle_id	        => NULL,
		          x_formula_value	=> l_budget_amount,
		          x_return_status	=> x_return_status);

              IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                   --Unable to calculate the budget amount because the budget amount formula returned an error.

                   OKL_API.set_message(
                               p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_INVALID_BUDGET_AMT',
                               p_token1        => 'FORMULA_NAME',
                               p_token1_value  => l_rulv_rec.rule_information3
                         );
                   RAISE budget_amount_error;
              END IF;
       ELSE
              x_return_status := OKL_API.G_RET_STS_ERROR;
              -- Budget Amount Option has an invalid value
              OKL_API.set_message(   p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Budget Amount Option');
              RAISE OKL_API.G_EXCEPTION_ERROR;

       END IF;

       -------------end get budget amount ------------------------------------

       ----------- get strategy ----------------------------------------------

       okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMCOPO'
                                     ,p_rdf_code         => 'AMPRST'
                                     ,p_chr_id           => p_contract_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => TRUE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

       IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but formula not found
          IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Portfolio Management DATA is not defined.
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_PRTFL_MISSING_DATA',
                                     p_token1        => 'DATA',
                                     p_token1_value  => 'Strategy');
               RAISE strategy_error;

          END IF;
          l_strategy := l_rulv_rec.rule_information1;
       ELSE

          RAISE strategy_error;
       END IF;



       -------------end get strategy ------------------------------------


       ----------- get assignment group ----------------------------------------------

       okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMCOPO'
                                     ,p_rdf_code         => 'AMPRAG'
                                     ,p_chr_id           => p_contract_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => TRUE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

       IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but formula not found
          -- SECHAWLA 21-AUG-03 3108113: Changed G_MISS_NUM to G_MISS_CHAR
          IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Portfolio management DATA is not defined.
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_PRTFL_MISSING_DATA',
                                     p_token1        => 'DATA',
                                     p_token1_value  => 'Assignment Group');
               RAISE assignment_group_error;

          END IF;
          -- SECHAWLA 21-AUG-03 3108113: perform explicit conversion
          l_assignment_grp_id := to_number(l_rulv_rec.rule_information1);
       ELSE

          RAISE assignment_group_error;
       END IF;



       -------------end get assignment group ------------------------------------


       ----------- get execution due date ----------------------------------------------

       okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMCOPO'
                                     ,p_rdf_code         => 'AMPRED'
                                     ,p_chr_id           => p_contract_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => TRUE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

       IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but formula not found
          -- SECHAWLA 21-AUG-03 3108113: Changed G_MISS_NUM to G_MISS_CHAR
          IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Portfolio management DATA is not defined.
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_PRTFL_MISSING_DATA',
                                     p_token1        => 'DATA',
                                     p_token1_value  => 'Execution Due Date');
               RAISE execution_date_error;

          END IF;


          -- SECHAWLA 21-AUG-03 3108113: perform explicit conversion
          l_end_date := l_end_date - to_number(l_rulv_rec.rule_information1);

       ELSE

          RAISE execution_date_error;
       END IF;



       -------------end get execution due date ------------------------------------


      ----------- get approval requirement ----------------------------------------------

       okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMCOPO'
                                     ,p_rdf_code         => 'AMAPRE'
                                     ,p_chr_id           => p_contract_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => TRUE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

       IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found, but has a null value
          IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN
              l_approval_required := 'N';
          ELSE
              l_approval_required := l_rulv_rec.rule_information1;
          END IF;
       ELSE
          l_approval_required := 'N';
       END IF;


       -- SECHAWLA  Bug # 2726739 : Added the following piece of code
       -- get the functional currency
       l_func_curr_code := okl_am_util_pvt.get_functional_currency;
       -- get the contract currency
       l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => p_contract_id);

       lp_pflv_rec.currency_code := l_contract_curr_code;
       lp_pflv_rec.currency_conversion_code := l_func_curr_code;

       IF l_contract_curr_code <> l_func_curr_code  THEN
           -- get the conversion factors from accounting util. No conversion is required here. We use
           -- convert_to_functional_currency procedure just to get the conversion factors

           okl_accounting_util.convert_to_functional_currency(
   	            p_khr_id  		  	       => p_contract_id,
   	            p_to_currency   		   => l_func_curr_code,
   	            p_transaction_date 	       => l_sysdate ,
   	            p_amount 			       => l_budget_amount,
                x_return_status		       => x_return_status,
   	            x_contract_currency	       => lx_contract_currency,
   		        x_currency_conversion_type => lx_currency_conversion_type,
   		        x_currency_conversion_rate => lx_currency_conversion_rate,
   		        x_currency_conversion_date => lx_currency_conversion_date,
   		        x_converted_amount 	       => lx_converted_amount );

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           lp_pflv_rec.currency_conversion_type := lx_currency_conversion_type;
           lp_pflv_rec.currency_conversion_rate := lx_currency_conversion_rate;
           lp_pflv_rec.currency_conversion_date := lx_currency_conversion_date;
       END IF;
       --- SECHAWLA  Bug # 2726739 : end new code -----



       -------------end get approval requirement ------------------------------------

       lp_pflv_rec.budget_amount := l_budget_amount;
       lp_pflv_rec.date_strategy_execution_due := l_end_date;
       lp_pflv_rec.trx_status_code := 'ENTERED';
       lp_pflv_rec.asset_track_strategy_code := l_strategy;
       lp_pflv_rec.pfc_id := lx_pfcv_rec.id;
       lp_pflv_rec.tmb_id := l_assignment_grp_id;
       lp_pflv_rec.fma_id := l_formulae_id;

       okl_prtfl_lines_pub.insert_prtfl_lines(
                                p_api_version            =>  p_api_version
                                ,p_init_msg_list         =>  OKL_API.G_FALSE
                                ,x_return_status         =>  x_return_status
                                ,x_msg_count             =>  x_msg_count
                                ,x_msg_data              =>  x_msg_data
                                ,p_pflv_rec              =>  lp_pflv_rec
                                ,x_pflv_rec              =>  lx_pflv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;


       IF upper(l_approval_required) = 'Y' THEN
           okl_am_wf.raise_business_event(p_contract_id,'oracle.apps.okl.am.approvecontportfolio');
       END IF;

      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION

      WHEN budget_amount_error THEN
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');

      WHEN strategy_error THEN
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');

      WHEN assignment_group_error THEN
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');

      WHEN execution_date_error THEN
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');


      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
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
        IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
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
        IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
        END IF;
        IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
        END IF;
        IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
        END IF;
        IF l_oklprtfl_csr%ISOPEN THEN
            CLOSE l_oklprtfl_csr;
         END IF;
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END create_cntrct_prtfl;



   -- Start of comments
   --
   -- Procedure Name  : batch_upd_cntrct_prtfl
   -- Description     : This procedure is used to execute update_cntrct_prtfl procedure
   --                   as a concurrent program. It has all the input parameters for
   --                   update_cntrct_prtfl and 2 standard OUT parameters - ERRBUF and RETCODE
   -- Business Rules  :
   -- Parameters      :  p_contract_id                  - contract id

   --
   --
   -- Version         : 1.0
   -- History         : SECHAWLA 16-JAN-03 Bug # 2754280
   --                      Changed the app name from OKL to OKC for g_unexpected_error
   -- End of comments

 PROCEDURE batch_upd_cntrct_prtfl(   ERRBUF                  OUT 	NOCOPY VARCHAR2,
                                      RETCODE                 OUT   NOCOPY VARCHAR2 ,
                                      p_api_version           IN  	NUMBER,
           		 	                  p_init_msg_list         IN  	VARCHAR2,
                                      p_contract_id           IN    NUMBER
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_transaction_status  VARCHAR2(1);
   lx_error_rec          OKL_API.error_rec_type;
   l_msg_idx             INTEGER := FND_MSG_PUB.G_FIRST;
   l_api_name            CONSTANT VARCHAR2(30) := 'batch_upd_cntrct_prtfl';
   l_total_count         NUMBER;
   l_processed_count     NUMBER;
   l_error_count         NUMBER;
   l_unchanged_txn_count NUMBER;

   BEGIN

                         update_cntrct_prtfl(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data,
				                p_contract_id    	    => p_contract_id ,
                                x_total_count           => l_total_count,
                                x_processed_count       => l_processed_count,
                                x_error_count           => l_error_count);


                        -- Add couple of blank lines
                         fnd_file.new_line(fnd_file.log,2);
                         fnd_file.new_line(fnd_file.output,2);

                        -- Get the messages in the log
                        LOOP

                            fnd_msg_pub.get(
                            p_msg_index     => l_msg_idx,
                            p_encoded       => FND_API.G_FALSE,
                            p_data          => lx_error_rec.msg_data,
                            p_msg_index_out => lx_error_rec.msg_count);

                            IF (lx_error_rec.msg_count IS NOT NULL) THEN

                                fnd_file.put_line(fnd_file.log,  lx_error_rec.msg_data);
                                fnd_file.put_line(fnd_file.output,  lx_error_rec.msg_data);

                            END IF;

                            EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
                                    OR (lx_error_rec.msg_count IS NULL));

                            l_msg_idx := FND_MSG_PUB.G_NEXT;
                        END LOOP;


                        fnd_file.new_line(fnd_file.log,2);
                        fnd_file.new_line(fnd_file.output,2);

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                           fnd_file.put_line(fnd_file.log, 'Portfolio Management Strategy Profile Update Failed, None of the transactions got processed.');
                           fnd_file.put_line(fnd_file.output, 'Portfolio Management Strategy Profile Update Failed, None of the transactions got processed.');
                        END IF;

                        IF l_total_count = 0 THEN
                            fnd_file.put_line(fnd_file.log, 'There were no portfolio management strategy profile transactions to process.');
                            fnd_file.put_line(fnd_file.output,'There were no portfolio management strategy profile transactions to process.');
                        ELSE

                            fnd_file.put_line(fnd_file.log, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Failed : '||l_error_count);

                            l_unchanged_txn_count := (l_total_count - (l_processed_count + l_error_count )) ;

                            fnd_file.put_line(fnd_file.output, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Failed : '||l_error_count);

                            IF l_unchanged_txn_count > 0 THEN
                               fnd_file.new_line(fnd_file.log,1);
                               fnd_file.new_line(fnd_file.output,1);

                               fnd_file.put_line(fnd_file.log, l_unchanged_txn_count||' transactions were not processed as there is no change in the budget amount.');
                               fnd_file.put_line(fnd_file.output, l_unchanged_txn_count||' transactions were not processed as there is no change in the budget amount.');
                            END IF;

                        END IF;


       EXCEPTION
           WHEN OTHERS THEN
                -- unexpected error
                -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
                OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

 END batch_upd_cntrct_prtfl;



    -- Start of comments
    --
    -- Procedure Name  : update_cntrct_prtfl
    -- Description     : procdure used to update portfolio management strategy profile.
    -- Business Rules  :
    -- parameters      : p_contract_id   : Contract ID
    -- Version         : 1.0
    -- End of comments

   PROCEDURE update_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_contract_id                   IN  NUMBER ,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER) IS

    SUBTYPE pfcv_rec_type IS okl_prtfl_contracts_pub.pfcv_rec_type;
    SUBTYPE pflv_rec_type IS okl_prtfl_lines_pub.pflv_rec_type;

    lp_pflv_rec                     pflv_rec_type;
    lx_pflv_rec                     pflv_rec_type;

    l_budget_amount                 NUMBER;
    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_contract_number               VARCHAR2(120);
    l_total_count                   NUMBER := 0;
    l_process_count                 NUMBER := 0;
    l_error_count                   NUMBER := 0;


    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'update_cntrct_prtfl';
    l_rulv_rec                      okl_rule_pub.rulv_rec_type;
    l_formulae_id                   NUMBER;
    budget_amount_error             EXCEPTION;
    l_name                          VARCHAR2(150);
    l_error_txn                     VARCHAR2(1);

    -- This cursor is used to get the contracts that need to be updated.
    CURSOR l_cntrctprtfl_csr IS
    SELECT h.id header_id, l.id line_id , l.fma_id fma_id, h.khr_id khr_id, l.budget_amount
    FROM   okl_prtfl_cntrcts_b h, okl_prtfl_lines_b l
    WHERE  h.id = l.pfc_id
    AND    l.fma_id IS NOT NULL   -- profiles that use budget amount formula
    AND    ((p_contract_id IS NOT NULL AND h.khr_id = p_contract_id) OR  (p_contract_id IS NULL));

    -- This cursor is used to get the contract number for a given contract ID
    CURSOR l_okcheaders_csr(p_id NUMBER) IS
    SELECT contract_number
    FROM   okc_k_headers_b
    WHERE  id = p_id;

    -- This cursor is used to get the formulae id
    CURSOR l_formulae_csr(p_id NUMBER) IS
    SELECT name
    FROM   okl_formulae_b
    WHERE  id = p_id;

    BEGIN

      l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);



      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;



      l_total_count := 0;
      l_process_count := 0;

      --loop thru all the contracts thet need to be updated and update the budget amount
      FOR l_cntrctprtfl_rec IN l_cntrctprtfl_csr LOOP


            l_total_count := l_total_count + 1;
            l_error_txn := 'N';


            OPEN  l_okcheaders_csr(l_cntrctprtfl_rec.khr_id);
            FETCH l_okcheaders_csr INTO l_contract_number;
            IF l_okcheaders_csr%NOTFOUND THEN
                  -- Contract Id is invalid
                  OKL_API.set_message(    p_app_name      => 'OKC',
                                          p_msg_name      => G_INVALID_VALUE,
                                          p_token1        => G_COL_NAME_TOKEN,
                                          p_token1_value  => 'Contract Id');
                  l_error_txn := 'Y';

            ELSE

                  OPEN  l_formulae_csr(l_cntrctprtfl_rec.fma_id);
                  FETCH l_formulae_csr INTO l_name;
                  IF l_formulae_csr%NOTFOUND THEN

                        -- Budget Amount Formula Name is invalid
                        OKL_API.set_message(
                           p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_INVALID_FORMULA',
                           p_token1        => 'CONTRACT_NUMBER',
                           p_token1_value  => l_contract_number);

                        l_error_txn := 'Y';

                  ELSE
                        okl_am_util_pvt.get_formula_value(
                                p_formula_name	    => l_name,
                                p_chr_id	        => l_cntrctprtfl_rec.khr_id,
                                p_cle_id	        => NULL,
		                        x_formula_value   	=> l_budget_amount,
		                        x_return_status   	=> l_return_status);

                         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                                --Can not process strategy profile update transaction for contract CONTARCT_NUMBER because the budget amount formula returned error.
                                OKL_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_UPD_BA_FORMULA_ERR',
                                            p_token1        => 'CONTRACT_NUMBER',
                                            p_token1_value  => l_contract_number,
                                            p_token2        => 'FORMULA_NAME',
                                            p_token2_value  => l_rulv_rec.rule_information3
                                 );
                                l_error_txn := 'Y';

                         ELSE

                             IF l_cntrctprtfl_rec.budget_amount <> l_budget_amount THEN

                                 lp_pflv_rec.id := l_cntrctprtfl_rec.line_id;
                                 lp_pflv_rec.budget_amount := l_budget_amount;

                                 okl_prtfl_lines_pub.update_prtfl_lines(
                                            p_api_version                  => p_api_version
                                            ,p_init_msg_list               => OKL_API.G_FALSE
                                            ,x_return_status               => l_return_status
                                            ,x_msg_count                   => x_msg_count
                                            ,x_msg_data                    => x_msg_data
                                            ,p_pflv_rec                    => lp_pflv_rec
                                            ,x_pflv_rec                    => lx_pflv_rec);


                                  IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN

                                      -- Portfolio Management Strategy Profile Update transaction failed for contract CONTRACT_NUMBER.
                                      OKC_API.set_message(  p_app_name      => 'OKL',
                                                                  p_msg_name      => 'OKL_AM_PRTFL_TRANS_FAILED',
                                                                  p_token1        =>  'CONTRACT_NUMBER',
                                                                  p_token1_value  =>  l_contract_number);
                                      l_error_txn := 'Y';
                                  ELSE
                                      l_process_count := l_process_count + 1;

                                      -- Budget amount updated successfully for contract CONTRACT_NUMBER
                                      OKC_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_PRTFL_UPD_PROCESSED',
                                            p_token1        => 'CONTRACT_NUMBER',
                                            p_token1_value  => l_contract_number);

                                      -- Old Budget Amount :
                                      OKC_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_OLD_BUDGET_AMT',
                                            p_token1        => 'OLD_AMT',
                                            p_token1_value  => l_cntrctprtfl_rec.budget_amount);

                                      -- New Budget Amount :
                                      OKC_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_NEW_BUDGET_AMT',
                                            p_token1        => 'NEW_AMT',
                                            p_token1_value  => l_budget_amount);
                                  END IF;
                              ELSE
                                 -- Budget amount not updated for contract CONTRACT_NUMBER as the new budget amount is same as the old budget amount.
                                 OKC_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_PRTFL_NO_UPD',
                                            p_token1        => 'CONTRACT_NUMBER',
                                            p_token1_value  => l_contract_number);
                              END IF;

                        END IF;

                    END IF;
                    CLOSE l_formulae_csr;

             END IF;
             CLOSE l_okcheaders_csr;

             IF l_error_txn = 'Y' THEN
                l_error_count:= l_error_count + 1;
             END IF;
      END LOOP;




      x_total_count := l_total_count;
      x_processed_count := l_process_count;
      x_error_count := l_error_count;

      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION

      WHEN budget_amount_error THEN
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');



      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
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
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
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
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_okcheaders_csr%ISOPEN THEN
            CLOSE l_okcheaders_csr;
         END IF;
         IF l_formulae_csr%ISOPEN THEN
            CLOSE l_formulae_csr;
         END IF;
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END update_cntrct_prtfl;




   -- Start of comments
   --
   -- Procedure Name  : batch_exe_cntrct_prtfl
   -- Description     : This procedure is used to execute execute_cntrct_prtfl procedure
   --                   as a concurrent program. It has all the input parameters for
   --                   execute_cntrct_prtfl and 2 standard OUT parameters - ERRBUF and RETCODE
   -- Business Rules  :
   --
   --
   -- Version         : 1.0
   -- History         : SECHAWLA 16-JAN-03 Bug # 2754280
   --                      Changed the app name from OKL to OKC for g_unexpected_error
   -- End of comments
   PROCEDURE batch_exe_cntrct_prtfl(	ERRBUF                  OUT 	NOCOPY   VARCHAR2,
                                        RETCODE                 OUT     NOCOPY   VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2
                                      )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   lx_error_rec          OKL_API.error_rec_type;
   l_msg_idx             INTEGER := FND_MSG_PUB.G_FIRST;
   l_api_name            CONSTANT VARCHAR2(30) := 'batch_exe_cntrct_prtfl';
   l_total_count         NUMBER;
   l_processed_count     NUMBER;
   l_error_count         NUMBER;

   BEGIN

                         execute_cntrct_prtfl(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data,
				                x_total_count           => l_total_count,
                                x_processed_count       => l_processed_count,
                                x_error_count           => l_error_count);


                        -- Add couple of blank lines
                         fnd_file.new_line(fnd_file.log,2);
                         fnd_file.new_line(fnd_file.output,2);

                        -- Get the messages in the log
                        LOOP

                            fnd_msg_pub.get(
                            p_msg_index     => l_msg_idx,
                            p_encoded       => FND_API.G_FALSE,
                            p_data          => lx_error_rec.msg_data,
                            p_msg_index_out => lx_error_rec.msg_count);

                            IF (lx_error_rec.msg_count IS NOT NULL) THEN

                                fnd_file.put_line(fnd_file.log,  lx_error_rec.msg_data);
                                fnd_file.put_line(fnd_file.output,  lx_error_rec.msg_data);

                            END IF;

                            EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
                                    OR (lx_error_rec.msg_count IS NULL));

                            l_msg_idx := FND_MSG_PUB.G_NEXT;
                        END LOOP;


                        fnd_file.new_line(fnd_file.log,2);
                        fnd_file.new_line(fnd_file.output,2);

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                           fnd_file.put_line(fnd_file.log, 'Portfolio Management Strategy Profile Execution Failed, None of the transactions got processed.');
                           fnd_file.put_line(fnd_file.output, 'Portfolio Management Strategy Profile Execution Failed, None of the transactions got processed.');
                        END IF;

                        IF l_total_count = 0 THEN
                            fnd_file.put_line(fnd_file.log, 'There were no portfolio management strategy profile transactions to process.');
                            fnd_file.put_line(fnd_file.output,'There were no portfolio management strategy profile transactions to process.');
                        ELSE

                            fnd_file.put_line(fnd_file.log, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Failed : '||l_error_count);

                            fnd_file.put_line(fnd_file.output, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Failed : '||l_error_count);

                        END IF;


       EXCEPTION
           WHEN OTHERS THEN
                -- unexpected error
                -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
                OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

 END batch_exe_cntrct_prtfl;



 -- Start of comments
    --
    -- Procedure Name  : execute_cntrct_prtfl
    -- Description     : procdure used to execute portfolio management strategy profile on the execution due date
    -- Business Rules  :
    -- parameters      :
    -- Version         : 1.0
    -- End of comments

 PROCEDURE execute_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER) IS

    SUBTYPE pflv_rec_type IS okl_prtfl_lines_pub.pflv_rec_type;

    lp_pflv_rec                     pflv_rec_type;
    lx_pflv_rec                     pflv_rec_type;

    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_contract_number               VARCHAR2(120);
    l_total_count                   NUMBER := 0;
    l_process_count                 NUMBER := 0;
    l_error_count                   NUMBER := 0;


    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'execute_cntrct_prtfl';
    l_sysdate                       DATE;
    l_team_name                     VARCHAR2(30);

    -- This cursor is used to get the portfolios that need to be executed.
    CURSOR l_cntrctprtfl_csr(p_date DATE) IS
    SELECT h.id header_id, l.id line_id , h.khr_id khr_id, khr.contract_number contract_number, l.tmb_id
    FROM   okl_prtfl_cntrcts_b h, okl_prtfl_lines_b l, okc_k_headers_b khr
    WHERE  h.id = l.pfc_id
    AND    h.khr_id = khr.id
    AND    l.date_strategy_executed IS NULL
    AND    khr.sts_code = 'BOOKED'
    AND    l.date_strategy_execution_due <= p_date;

    -- This cursor is used to get the assignment group name for a given id
    CURSOR l_jtfteams_csr(p_team_id NUMBER) IS
    SELECT team_name
    FROM   jtf_rs_teams_vl
    WHERE  team_id = p_team_id;

    BEGIN

      l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);



      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      SELECT SYSDATE INTO l_sysdate FROM dual;

      l_total_count := 0;
      l_process_count := 0;

      --loop thru all the portfolios that need to be executed and call the notify assignment group workflow
      FOR l_cntrctprtfl_rec IN l_cntrctprtfl_csr(l_sysdate) LOOP

            l_total_count := l_total_count + 1;


            -- call the notify assignment group workflow
            okl_am_wf.raise_business_event(l_cntrctprtfl_rec.khr_id,'oracle.apps.okl.am.notifyportexe');

            OPEN  l_jtfteams_csr(l_cntrctprtfl_rec.tmb_id);
            FETCH l_jtfteams_csr INTO l_team_name;
            IF l_jtfteams_csr%NOTFOUND THEN
               -- Assignment group ID is invalid
               OKL_API.set_message(
                                 p_app_name      => 'OKC',
                                 p_msg_name      => G_INVALID_VALUE,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'TMB_ID');
            ELSE
                -- Notifications have been sent to ASSIGNMENT_GROUP for executing the contract portfolio for contract CONTRACT_NUMBER
                OKC_API.set_message(  p_app_name      => 'OKL',
                                      p_msg_name      => 'OKL_AM_PRTFL_NOTF_SENT',
                                      p_token1        => 'ASSIGNMENT_GROUP',
                                      p_token1_value  => l_team_name,
                                      p_token2        => 'CONTRACT_NUMBER',
                                      p_token2_value  => l_cntrctprtfl_rec.contract_number);

                -- update date_strategy_executed field
                lp_pflv_rec.id := l_cntrctprtfl_rec.line_id;
                lp_pflv_rec.date_strategy_executed := l_sysdate;

                okl_prtfl_lines_pub.update_prtfl_lines(
                              p_api_version                  => p_api_version
                              ,p_init_msg_list               => OKL_API.G_FALSE
                              ,x_return_status               => l_return_status
                              ,x_msg_count                   => x_msg_count
                              ,x_msg_data                    => x_msg_data
                              ,p_pflv_rec                    => lp_pflv_rec
                              ,x_pflv_rec                    => lx_pflv_rec);


                IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN

                    -- Strategy execution date could not be set for Portfolio Management Strategy Profile for contract CONTRACT_NUMBER.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                      p_msg_name      => 'OKL_AM_STRTG_DT_UPD_FAILED',
                                      p_token1        => 'CONTRACT_NUMBER',
                                      p_token1_value  => l_cntrctprtfl_rec.contract_number);


                ELSE
                    l_process_count := l_process_count + 1;
                END IF;
            END IF;
            CLOSE l_jtfteams_csr;


      END LOOP;



      x_total_count := l_total_count;
      x_processed_count := l_process_count;
      x_error_count := l_total_count - l_process_count;

      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_jtfteams_csr%ISOPEN THEN
            CLOSE l_jtfteams_csr;
         END IF;

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
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_jtfteams_csr%ISOPEN THEN
            CLOSE l_jtfteams_csr;
         END IF;

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
         IF l_cntrctprtfl_csr%ISOPEN THEN
            CLOSE l_cntrctprtfl_csr;
         END IF;
         IF l_jtfteams_csr%ISOPEN THEN
            CLOSE l_jtfteams_csr;
         END IF;

        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END execute_cntrct_prtfl;


END OKL_AM_CONTRACT_PRTFL_PVT;

/
