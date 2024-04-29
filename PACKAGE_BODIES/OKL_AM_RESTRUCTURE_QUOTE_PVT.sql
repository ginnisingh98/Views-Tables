--------------------------------------------------------
--  DDL for Package Body OKL_AM_RESTRUCTURE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RESTRUCTURE_QUOTE_PVT" AS
/* $Header: OKLRRTQB.pls 120.4 2006/11/22 13:38:37 zrehman noship $ */

  -- Start of comments
  --
  -- Procedure Name	: set_quote_defaults
  -- Description	  : Default the values of parameters if the values are not
  --                   passed to this API. This assumption is necessary because
  --                  this API can either be called from a screen or from some
  --                  other process api
  -- Business Rules	:
  -- Parameters		  : quot_rec, return_status
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE set_quote_defaults(
               px_quot_rec         IN OUT NOCOPY quot_rec_type,
               x_return_status     OUT NOCOPY VARCHAR2)  IS
    l_quote_eff_days         NUMBER;
    l_quote_eff_max_days     NUMBER;
    l_quote_status           VARCHAR2(200) := 'IN_PROCESS';
    l_quote_reason           VARCHAR2(200) := 'EOT';
    l_db_date                DATE;
    l_khr_end_date           DATE;
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Cursor to get the contract end_date
    CURSOR l_khr_csr (p_khr_id IN NUMBER) IS
       SELECT K.end_date
       FROM   OKL_K_HEADERS_FULL_V K
       WHERE  K.id = p_khr_id;

  BEGIN
    -- Get the sysdate
    SELECT SYSDATE INTO l_db_date FROM DUAL;

    -- Set the date_effective_from if null
    IF ((px_quot_rec.date_effective_from IS NULL) OR
        (px_quot_rec.date_effective_from = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_effective_from :=  l_db_date ;
    END IF;

   -- for LE Uptake project 08-11-2006
    IF ((px_quot_rec.legal_entity_id IS NULL) OR
        (px_quot_rec.legal_entity_id = OKL_API.G_MISS_NUM)) THEN
     px_quot_rec.legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(px_quot_rec.khr_id);
    END IF;
    -- for LE Uptake project 08-11-2006

    -- Set the date_effective_to if null
    IF ((px_quot_rec.date_effective_to IS NULL) OR
        (px_quot_rec.date_effective_to = OKL_API.G_MISS_DATE)) THEN

      -- set the date eff to using rules
      OKL_AM_CREATE_QUOTE_PVT.quote_effectivity(
           p_quot_rec             => px_quot_rec,
           x_quote_eff_days       => l_quote_eff_days,
           x_quote_eff_max_days   => l_quote_eff_max_days,
           x_return_status        => l_return_status);

      -- If error then above api will set the message, so exit now
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      px_quot_rec.date_effective_to   :=  px_quot_rec.date_effective_from
                                          + l_quote_eff_days;
    END IF;

    -- Set the qst_code if null
    IF ((px_quot_rec.qst_code IS NULL) OR
        (px_quot_rec.qst_code = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.qst_code            :=  l_quote_status;
    END IF;

    -- Set the qrs_code if null
    IF ((px_quot_rec.qrs_code IS NULL) OR
        (px_quot_rec.qrs_code = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.qrs_code            :=  l_quote_reason;
    END IF;

    -- Set the preproceeds_yn if null
    IF ((px_quot_rec.preproceeds_yn IS NULL) OR
        (px_quot_rec.preproceeds_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.preproceeds_yn      :=  G_NO;
    END IF;

    -- Set the summary_format_yn if null
    IF ((px_quot_rec.summary_format_yn IS NULL) OR
        (px_quot_rec.summary_format_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.summary_format_yn   :=  G_NO;
    END IF;

    -- Set the consolidated_yn if null
    IF ((px_quot_rec.consolidated_yn IS NULL) OR
        (px_quot_rec.consolidated_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.consolidated_yn     :=  G_NO;
    END IF;

    -- Set the approved_yn if null
    IF ((px_quot_rec.approved_yn IS NULL) OR
        (px_quot_rec.approved_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.approved_yn         :=  G_NO;
    END IF;

    -- Set the payment_received_yn if null
    IF ((px_quot_rec.payment_received_yn IS NULL) OR
        (px_quot_rec.payment_received_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.payment_received_yn :=  G_NO;
    END IF;

    -- Set the date_requested if null
    IF ((px_quot_rec.date_requested IS NULL) OR
        (px_quot_rec.date_requested = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_requested      :=  l_db_date;
    END IF;

    -- Set the date_proposal if null
    IF ((px_quot_rec.date_proposal IS NULL) OR
        (px_quot_rec.date_proposal = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_proposal       :=  l_db_date;
    END IF;

    -- Set the requested_by if null
    IF ((px_quot_rec.requested_by IS NULL) OR
        (px_quot_rec.requested_by = OKL_API.G_MISS_NUM)) THEN
      px_quot_rec.requested_by        :=  1;
    END IF;

    -- Always NO during quote creation
    px_quot_rec.accepted_yn           :=  G_NO;
    -- Always NO during RESTRUCTURE quote creation
    px_quot_rec.early_termination_yn  :=  G_NO;
    px_quot_rec.partial_yn            :=  G_NO;
    -- For now *** -- OKL_QTE_PVT.Validate_Trn_Code expects a value for trn_code
    px_quot_rec.trn_code              :=  'EXP';

    IF ((px_quot_rec.date_restructure_start IS NULL) OR
        (px_quot_rec.date_restructure_start = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_restructure_start := l_db_date;
    END IF;

    IF ((px_quot_rec.date_restructure_end IS NULL) OR
        (px_quot_rec.date_restructure_end = OKL_API.G_MISS_DATE)) THEN

      OPEN  l_khr_csr (px_quot_rec.khr_id);
      FETCH l_khr_csr INTO l_khr_end_date;
      CLOSE l_khr_csr;

      IF l_khr_end_date IS NOT NULL THEN
        IF ((px_quot_rec.term IS NULL) OR
            (px_quot_rec.term = OKL_API.G_MISS_NUM)) THEN
          px_quot_rec.date_restructure_end := l_khr_end_date;
        ELSE
          px_quot_rec.date_restructure_end := ADD_MONTHS (l_khr_end_date, px_quot_rec.term);
        END IF;
      END IF;

    END IF;

    x_return_status                   :=   l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF l_khr_csr%ISOPEN THEN
         CLOSE l_khr_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF l_khr_csr%ISOPEN THEN
         CLOSE l_khr_csr;
      END IF;
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END set_quote_defaults;

  -- Start of comments
  --
  -- Procedure Name	: quote_type_check
  -- Description	  : checks if quote is of Restructure type
  -- Business Rules	:
  -- Parameters		  : quote type, return_status
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE quote_type_check(
           p_qtp_code                    IN VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2)  IS
     l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_qtp_code IS NOT NULL AND p_qtp_code <> OKL_API.G_MISS_CHAR) AND
       (p_qtp_code NOT LIKE 'RES%') THEN
        l_return_status       := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END quote_type_check;




  -- Start of comments
  --
  -- Function  Name  : set_currency_defaults
  -- Description     : This procedure Defaults the Multi-Currency Columns
  -- Business Rules  :
  -- Parameters      : Input parameters : px_quot_rec, p_sys_date
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  --                 : 30-DEC-02 RMUNJULU 2699412 Added msg
  --
  -- End of comments
  PROCEDURE set_currency_defaults(
            px_quot_rec       IN OUT NOCOPY quot_rec_type,
            p_sys_date        IN DATE,
            x_return_status   OUT NOCOPY VARCHAR2) IS

       l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
       l_functional_currency_code VARCHAR2(15);
       l_contract_currency_code VARCHAR2(15);
       l_currency_conversion_type VARCHAR2(30);
       l_currency_conversion_rate NUMBER;
       l_currency_conversion_date DATE;

       l_converted_amount NUMBER;

       -- Since we do not use the amount or converted amount in TRX_Quotes table
       -- set a hardcoded value for the amount (and pass to to
       -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
       -- conversion values )
       l_hard_coded_amount NUMBER := 100;



  BEGIN

     -- Get the functional currency from AM_Util
     -- RMUNJULU 30-DEC-02 2699412 changed to call right function
     l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency;


     -- Get the contract currency details from ACCOUNTING_Util
     OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id  		  	          => px_quot_rec.khr_id,
                     p_to_currency   		        => l_functional_currency_code,
                     p_transaction_date 		    => p_sys_date,
                     p_amount 			            => l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency		    => l_contract_currency_code,
                     x_currency_conversion_type	=> l_currency_conversion_type,
                     x_currency_conversion_rate	=> l_currency_conversion_rate,
                     x_currency_conversion_date	=> l_currency_conversion_date,
                     x_converted_amount 		    => l_converted_amount);

     -- RMUNJULU 30-DEC-02 2699412 Added msg
     IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

        -- The currency conversion rate could not be identified for specified currency.
        OKL_API.set_message(
                  p_app_name     => 'OKL',
                  p_msg_name     => 'OKL_CONV_RATE_NOT_FOUND');

      END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     px_quot_rec.currency_code := l_contract_currency_code;
     px_quot_rec.currency_conversion_code := l_functional_currency_code;

     -- If the functional currency is different from contract currency then set
     -- currency conversion columns
     IF l_functional_currency_code <> l_contract_currency_code THEN

        -- Set the currency conversion columns
        px_quot_rec.currency_conversion_type := l_currency_conversion_type;
        px_quot_rec.currency_conversion_rate := l_currency_conversion_rate;
        px_quot_rec.currency_conversion_date := l_currency_conversion_date;

     END IF;

     -- Set the return status
     x_return_status := l_return_status;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

         x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN

         -- unexpected error
         OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END set_currency_defaults;



  -- Start of comments
  --
  -- Procedure Name	: validate_quote
  -- Description	  : checks the validity of the quote
  -- Business Rules	:
  -- Parameters		  : quote rec, return_status
  -- Version		    : 1.0
  -- History        : RMUNJULU 17-DEC-02 2484327 Changed the Accepted quote
  --                  exists and unproccessed transaction exists logic
  --
  -- End of comments
  PROCEDURE validate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_rec                      IN quot_rec_type,
    p_call_flag                     IN VARCHAR2)  IS

    -- Cursor to get the khr_id for the quote
    CURSOR k_details_for_qte_csr (p_qte_id IN NUMBER) IS
       SELECT K.id,
              K.contract_number
       FROM   OKL_TRX_QUOTES_V Q,
              OKL_K_HEADERS_FULL_V K
       WHERE  Q.id = p_qte_id
       AND    Q.khr_id = K.id;

    -- Get the accepted_yn flag
    CURSOR l_acpt_csr ( p_qte_id IN NUMBER) IS
      SELECT accepted_yn
      FROM   OKL_TRX_QUOTES_B
      WHERE  id = p_qte_id;

    -- MDOKAL Bug 3577018
    CURSOR k_deal_type (p_khr_id IN NUMBER) IS
       SELECT DEAL_TYPE
       FROM   OKL_K_HEADERS
       WHERE  id = p_khr_id;

    l_khr_id                   NUMBER;
    l_no_of_assets             NUMBER := 0;
    l_k_end_date               DATE;
    l_rule_found               BOOLEAN := FALSE;
    lx_contract_status         VARCHAR2(200);
    l_control_flag_create      VARCHAR2(200) := 'RESTR_QUOTE_CREATE';
    l_control_flag_update      VARCHAR2(200) := 'RESTR_QUOTE_UPDATE';
    l_return_status            VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
    l_quote_number             NUMBER;
    l_qtp_code                 VARCHAR2(30);
    l_quote_type               VARCHAR2(200);
    l_contract_number          VARCHAR2(200);
    db_accepted_yn             VARCHAR2(1);


    -- RMUNJULU 17-DEC-02 Bug # 2484327 -- Added variables for checking
    -- related to asset level termination
    lx_quote_tbl OKL_AM_UTIL_PVT.quote_tbl_type;
    lx_trn_tbl   OKL_AM_UTIL_PVT.trn_tbl_type;

    -- MDOKAL Bug 3577018
	l_deal_type                VARCHAR2(200);

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Get the database khr details
    OPEN  k_details_for_qte_csr(p_quot_rec.id);
    FETCH k_details_for_qte_csr INTO l_khr_id, l_contract_number;
    CLOSE k_details_for_qte_csr;

    -- Based on the call to validate from create or update api
    -- call validate_contract
    IF (p_call_flag = 'CREATE') THEN

      -- MDOKAL Bug 3577018 Get the Deal Type
      OPEN  k_deal_type(p_quot_rec.khr_id);
      FETCH k_deal_type INTO l_deal_type;
      CLOSE k_deal_type;

      -- MDOKAL Bug 3577018 - Ensure only Lease Products are processed.
      IF l_deal_type IN ('LOAN','LOAN-REVOLVING') THEN
          OKL_API.set_message (
         			 p_app_name  	  => G_APP_NAME,
         			 p_msg_name  	  => 'OKL_AM_REST_LOAN_ERROR');
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- Call the validate contract to check contract status
      OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   p_quot_rec.khr_id,
           p_control_flag                =>   l_control_flag_create,
           x_contract_status             =>   lx_contract_status);

      -- If error then above api will set the message, so exit now
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;


      -- RMUNJULU 17-DEC-02 Bug # 2484327 -- START --

      -- *****************
      -- IF accepted quote with no trn exists for contract then error
      -- *****************

      -- Get accepted quote for contract with no trn
      OKL_AM_UTIL_PVT.get_non_trn_contract_quotes (
           p_khr_id        => l_khr_id,
           x_quote_tbl     => lx_quote_tbl,
           x_return_status => l_return_status);

      -- Check the return status
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occured in util proc, message set by util proc raise exp
            RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      -- Check if accepted quote exists for the contract
      IF lx_quote_tbl.COUNT > 0 THEN

          l_quote_type := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      'OKL_QUOTE_TYPE',
                                      lx_quote_tbl(lx_quote_tbl.FIRST).qtp_code,
                                      'Y');

          -- Accepted quote QUOTE_NUMBER of quote type QUOTE_TYPE exists for
          -- contract CONTRACT_NUMBER. Cannot create another quote for the same contract.
          OKL_API.set_message (
         			 p_app_name  	  => G_APP_NAME,
         			 p_msg_name  	  => 'OKL_AM_QTE_ACC_EXISTS_MSG',
               p_token1       => 'QUOTE_NUMBER',
               p_token1_value => lx_quote_tbl(lx_quote_tbl.FIRST).quote_number,
               p_token2       => 'QUOTE_TYPE',
               p_token2_value => l_quote_type,
               p_token3       => 'CONTRACT_NUMBER',
               p_token3_value => l_contract_number);

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;



      -- *****************
      -- IF unprocessed termination trn exists for the contract then error
      -- *****************

      -- Get all the unprocessed transactions for the contract
      OKL_AM_UTIL_PVT.get_contract_transactions (
             p_khr_id        => l_khr_id,
             x_trn_tbl       => lx_trn_tbl,
             x_return_status => l_return_status);

      -- Check the return status
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

          -- Error occured in util proc, message set by util proc raise exp
          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      -- Check if termination transaction exists for the asset
      IF lx_trn_tbl.COUNT > 0 THEN

         -- A termination transaction for the contract CONTRACT_NUMBER
         -- is already in progress.
         OKL_API.set_message (
         			       p_app_name  	  => G_APP_NAME,
              			 p_msg_name  	  => 'OKL_AM_K_PENDING_TRN_ERROR',
                     p_token1       => 'CONTRACT_NUMBER',
                     p_token1_value => l_contract_number);

          RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      -- RMUNJULU 17-DEC-02 Bug # 2484327 -- END --



      -- Check date_eff_to >= date_eff_from
      IF  (p_quot_rec.date_effective_from IS NOT NULL)
      AND (p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE)
      AND (p_quot_rec.date_effective_to IS NOT NULL)
      AND (p_quot_rec.date_effective_to <> OKL_API.G_MISS_DATE) THEN

         IF (TRUNC(p_quot_rec.date_effective_to) <= TRUNC(p_quot_rec.date_effective_from)) THEN

           -- Message : Date Effective To DATE_EFFECTIVE_TO cannot be before
           -- Date Effective From DATE_EFFECTIVE_FROM.
           OKL_API.SET_MESSAGE(p_app_name    	 => 'OKL',
        			                 p_msg_name		   => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
        			                 p_token1		     => 'DATE_EFFECTIVE_TO',
      		  	                 p_token1_value	 => p_quot_rec.date_effective_to,
      			                   p_token2		     => 'DATE_EFFECTIVE_FROM',
      			                   p_token2_value	 => p_quot_rec.date_effective_from);

           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
      END IF;

    ELSIF (p_call_flag = 'UPDATE') THEN

      IF p_quot_rec.khr_id IS NOT NULL AND p_quot_rec.khr_id <> OKL_API.G_MISS_NUM THEN
        l_khr_id := p_quot_rec.khr_id;
      END IF;

      OPEN l_acpt_csr( p_quot_rec.id);
      FETCH l_acpt_csr INTO db_accepted_yn ;
      CLOSE l_acpt_csr;

      -- Call the validate contract to check contract status only if not accepted
      IF db_accepted_yn <> 'Y' THEN

        OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   l_khr_id,
           p_control_flag                =>   l_control_flag_update,
           x_contract_status             =>   lx_contract_status);

        -- If error then above api will set the message, so exit now
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;


    -- check if quote type is valid
    quote_type_check(
           p_qtp_code        =>  p_quot_rec.qtp_code,
           x_return_status   =>  l_return_status);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      -- Message: Please select a valid Quote Type.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      =>'OKL_AM_QTP_CODE_INVALID');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;



    -- Check Term is passed for Rent Restructure
    IF p_quot_rec.qtp_code = 'RES_SOLVE_RENT' THEN

        IF p_quot_rec.term IS NULL
        OR p_quot_rec.term = OKL_API.G_MISS_NUM THEN
            l_return_status	:= OKL_API.G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE (
                p_app_name	=> G_OKC_APP_NAME,
                p_msg_name	=> G_REQUIRED_VALUE,
                p_token1	=> G_COL_NAME_TOKEN,
                p_token1_value	=> 'Term Extension');
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

	IF p_quot_rec.pop_code_end IS NULL
	OR p_quot_rec.pop_code_end = OKL_API.G_MISS_CHAR THEN
            l_return_status	:= OKL_API.G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE (
                p_app_name	=> G_OKC_APP_NAME,
                p_msg_name	=> G_REQUIRED_VALUE,
                p_token1	=> G_COL_NAME_TOKEN,
                p_token1_value	=> 'Purchase Option');
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;

    -- Check Purchase_Amount and Purchase_Formula are mutually exclusive
    IF (     (     p_quot_rec.purchase_formula IS NULL
               OR  p_quot_rec.purchase_formula = OKL_API.G_MISS_CHAR)
         AND (     p_quot_rec.purchase_amount  IS NULL
               OR  p_quot_rec.purchase_amount  = OKL_API.G_MISS_NUM))
    OR (     (     p_quot_rec.purchase_formula IS NOT NULL
               AND p_quot_rec.purchase_formula <> OKL_API.G_MISS_CHAR)
         AND (     p_quot_rec.purchase_amount  IS NOT NULL
               AND p_quot_rec.purchase_amount  <> OKL_API.G_MISS_NUM))
    THEN
            l_return_status	:= OKL_API.G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE (
                p_app_name	=> G_OKC_APP_NAME,
                p_msg_name	=> 'OKC_POPULATE_ONLY_ONE',
                p_token1	=> 'COL_NAME1',
                p_token1_value	=> 'Purchase Amount',
                p_token2	=> 'COL_NAME2',
                p_token2_value	=> 'Purchase Formula');
            RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF k_details_for_qte_csr%ISOPEN THEN
         CLOSE k_details_for_qte_csr;
      END IF;
      IF (l_acpt_csr%ISOPEN) THEN
        CLOSE l_acpt_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF k_details_for_qte_csr%ISOPEN THEN
         CLOSE k_details_for_qte_csr;
      END IF;
      IF (l_acpt_csr%ISOPEN) THEN
        CLOSE l_acpt_csr;
      END IF;
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_quote;



  -- Start of comments
  --
  -- Procedure Name	: validate_updated_quote
  -- Description	  : checks if updating values ok, called from update_res_quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU 17-DEC-02 2484327 Changed the Accepted quote
  --                  exists and unproccessed transaction exists logic for
  --                  quote when accepted
  --
  -- End of comments
  PROCEDURE validate_updated_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_rec                      IN quot_rec_type)  IS

    -- Cursor to get the database values for the quote being updated
    CURSOR k_dets_csr ( p_id NUMBER) IS
    SELECT OTQV.khr_id,
           OTQV.accepted_yn,
           OTQV.date_effective_from,
           OTQV.date_effective_to,
           OKHV.contract_number,
           OTQV.quote_number,
           OTQV.id qte_id,
           OTQV.qtp_code
    FROM   OKL_TRX_QUOTES_V       OTQV,
           OKL_K_HEADERS_FULL_V   OKHV
    WHERE  OTQV.id       = p_id
    AND    OTQV.khr_id   = OKHV.id;


    -- Cursor to get the contract number
    CURSOR get_k_num_csr ( p_khr_id IN NUMBER) IS
    SELECT  contract_number
    FROM    OKL_K_HEADERS_FULL_V K
    WHERE   K.id = p_khr_id;

    lp_quot_rec                      quot_rec_type := p_quot_rec;
    l_q_eff_quot_rec                 quot_rec_type;
    l_return_status                  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_quote_eff_to_dt                DATE;
    db_accepted_yn                   VARCHAR2(200);
    db_date_effective_from           DATE;
    db_date_effective_to             DATE;
    db_contract_id                   NUMBER;
    db_sysdate                       DATE;
    db_contract_number               VARCHAR2(2000);
    db_quote_number                  NUMBER;
    db_qte_id                        NUMBER;
    db_qtp_code                      VARCHAR2(200);
    l_quote_eff_days                 NUMBER;
    l_quote_eff_max_days             NUMBER;
    l_quote_number                   NUMBER;
    l_qtp_code                       VARCHAR2(30);
    l_quote_type                     VARCHAR2(200);
    l_trn_exists                     VARCHAR2(1) := '?';
    l_contract_id                    NUMBER;
    l_contract_number                VARCHAR2(200);
    l_date_eff_from                  DATE;
    lx_contract_status               VARCHAR2(200);

    -- RMUNJULU 17-DEC-02 Bug # 2484327 -- Added variables for checking
    -- related to asset level termination
    lx_quote_tbl OKL_AM_UTIL_PVT.quote_tbl_type;
    lx_trn_tbl   OKL_AM_UTIL_PVT.trn_tbl_type;

  BEGIN

    -- Get the db_sys_date
    SELECT SYSDATE INTO db_sysdate FROM DUAL;

    -- Get the DB values for the quote being updated
    OPEN k_dets_csr(lp_quot_rec.id);
    FETCH k_dets_csr INTO db_contract_id,
                          db_accepted_yn,
                          db_date_effective_from,
                          db_date_effective_to,
                          db_contract_number,
                          db_quote_number,
                          db_qte_id,
                          db_qtp_code;
    IF k_dets_csr%NOTFOUND THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE k_dets_csr;

    -- Check if quote id passed is valid
    IF db_qte_id IS NULL OR db_qte_id = OKL_API.G_MISS_NUM THEN

      OKL_API.set_message( p_app_name     => OKC_API.G_APP_NAME,
                           p_msg_name     => OKC_API.G_INVALID_VALUE,
                           p_token1       => OKC_API.G_COL_NAME_TOKEN,
                           p_token1_value => 'Quote id');

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- check if quote valid
    validate_quote(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_quot_rec                    =>   lp_quot_rec,
           p_call_flag                   =>   'UPDATE');

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- if Khr_Id not passed get from DB
    IF lp_quot_rec.khr_id IS NULL OR lp_quot_rec.khr_id = OKL_API.G_MISS_NUM THEN
      l_contract_id := db_contract_id;
      l_contract_number := db_contract_number;
    ELSE
      l_contract_id := lp_quot_rec.khr_id;
      OPEN  get_k_num_csr (l_contract_id);
      FETCH get_k_num_csr INTO l_contract_number;
      CLOSE get_k_num_csr;
    END IF;

    -- if qtp_code is null then get from db and check
    IF  (lp_quot_rec.qtp_code IS NULL
    OR lp_quot_rec.qtp_code = OKL_API.G_MISS_CHAR)
    AND db_qtp_code NOT LIKE 'RES%' THEN

      -- Please select a valid Quote Type.
      OKL_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                           p_msg_name      => 'OKL_AM_QTP_CODE_INVALID');

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- Check if date_effective_to is NULL
    IF lp_quot_rec.date_effective_to IS NULL
    OR lp_quot_rec.date_effective_to = OKL_API.G_MISS_DATE THEN

      -- You must enter a value for PROMPT
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_EFFECTIVE_TO'));

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- Get the date_eff_from from database if not passed
    IF  (lp_quot_rec.date_effective_from IS NOT NULL)
    AND (lp_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE) THEN
      l_date_eff_from := lp_quot_rec.date_effective_from;
    ELSE
      l_date_eff_from := db_date_effective_from;
    END IF;

    -- Check date_eff_to > date_eff_from
    IF  (l_date_eff_from IS NOT NULL)
    AND (l_date_eff_from <> OKL_API.G_MISS_DATE)
    AND (lp_quot_rec.date_effective_to IS NOT NULL)
    AND (lp_quot_rec.date_effective_to <> OKL_API.G_MISS_DATE) THEN

       IF (TRUNC(lp_quot_rec.date_effective_to) <= TRUNC(l_date_eff_from)) THEN

         -- Message : Date Effective To DATE_EFFECTIVE_TO cannot be before
         -- Date Effective From DATE_EFFECTIVE_FROM.
         OKL_API.SET_MESSAGE(p_app_name    	 => 'OKL',
      			                 p_msg_name		   => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
      			                 p_token1		     => 'DATE_EFFECTIVE_TO',
    		  	                 p_token1_value	 => lp_quot_rec.date_effective_to,
    			                   p_token2		     => 'DATE_EFFECTIVE_FROM',
    			                   p_token2_value	 => l_date_eff_from);

         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;

    -- if quote eff to date changed then
    IF  (lp_quot_rec.date_effective_to IS NOT NULL)
    AND (lp_quot_rec.date_effective_to <> OKL_API.G_MISS_DATE)
    AND (lp_quot_rec.date_effective_to <> db_date_effective_to) THEN

      -- get the date eff to from rules
      l_q_eff_quot_rec.khr_id := l_contract_id;
      l_q_eff_quot_rec.qtp_code := lp_quot_rec.qtp_code;
      OKL_AM_CREATE_QUOTE_PVT.quote_effectivity(
           p_quot_rec             => l_q_eff_quot_rec,
           x_quote_eff_days       => l_quote_eff_days,
           x_quote_eff_max_days   => l_quote_eff_max_days,
           x_return_status        => l_return_status);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- get max date eff to from rules is
      l_quote_eff_to_dt := db_date_effective_from + l_quote_eff_max_days;

      -- if max quote eff to date is less than sysdate then error
      IF (TRUNC(l_quote_eff_to_dt) < TRUNC(db_sysdate)) THEN
            --Message : Quote QUOTE_NUMBER is already expired.
            OKC_API.set_message( p_app_name      => OKL_API.G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_QUOTE_ALREADY_EXP',
                                 p_token1        => 'QUOTE_NUMBER',
                                 p_token1_value  => db_quote_number);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- if quote eff to date is less than sysdate then error
      IF TRUNC(lp_quot_rec.date_effective_to) < TRUNC(db_sysdate) THEN
        -- Please enter an Effective To date that occurs after the
        -- current system date.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_DATE_EFF_TO_PAST');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- if eff_to date > eff to date from rule then err
      IF  TRUNC(lp_quot_rec.date_effective_to) > TRUNC(l_quote_eff_to_dt) THEN
        -- Please enter Effective To date before DATE_EFF_TO_MAX.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_DATE_EFF_TO_ERR',
                             p_token1        => 'DATE_EFF_TO_MAX',
                             p_token1_value  => l_quote_eff_to_dt);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;


    -- RMUNJULU 17-DEC-02 2484327 -- START --

    -- ACCEPTED YN VALIDATION -- QUOTE ACCEPTED NOW --

    IF  lp_quot_rec.accepted_yn IS NOT NULL
    AND lp_quot_rec.accepted_yn <> OKL_API.G_MISS_CHAR
    AND db_accepted_yn = G_NO
    AND lp_quot_rec.accepted_yn = G_YES THEN


        -- *****************
        -- IF quote expired then error
        -- *****************


        -- If date_eff_to is not passed
        IF ((lp_quot_rec.date_effective_to IS NULL) OR
           (lp_quot_rec.date_effective_to = OKL_API.G_MISS_DATE)) THEN

          --if quote expired
          IF TRUNC(db_sysdate) > TRUNC(db_date_effective_to) THEN
            --Message : Quote QUOTE_NUMBER is already expired.
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_QUOTE_ALREADY_EXP',
                                 p_token1        => 'QUOTE_NUMBER',
                                 p_token1_value  => db_quote_number);

            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        END IF;


        -- *****************
        -- IF accepted quote with no trn exists for contract then error
        -- *****************

        -- Get accepted quote for contract with no trn
        OKL_AM_UTIL_PVT.get_non_trn_contract_quotes (
           p_khr_id        => l_contract_id,
           x_quote_tbl     => lx_quote_tbl,
           x_return_status => l_return_status);

        -- Check the return status
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occured in util proc, message set by util proc raise exp
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        -- Check if accepted quote exists for the contract
        IF lx_quote_tbl.COUNT > 0 THEN

          l_quote_type := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      'OKL_QUOTE_TYPE',
                                      lx_quote_tbl(lx_quote_tbl.FIRST).qtp_code,
                                      'Y');

          -- Accepted quote QUOTE_NUMBER of quote type QUOTE_TYPE exists for
          -- contract CONTRACT_NUMBER. Cannot accept multiple quotes for the same contract.
          OKL_API.set_message (
         			 p_app_name  	  => G_APP_NAME,
         			 p_msg_name  	  => 'OKL_AM_QTE_ACC_EXISTS_ERR',
               p_token1       => 'QUOTE_NUMBER',
               p_token1_value => lx_quote_tbl(lx_quote_tbl.FIRST).quote_number,
               p_token2       => 'QUOTE_TYPE',
               p_token2_value => l_quote_type,
               p_token3       => 'CONTRACT_NUMBER',
               p_token3_value => l_contract_number);

          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        -- *****************
        -- IF unprocessed termination trn exists for the contract then error
        -- *****************

        -- Get all the unprocessed transactions for the contract
        OKL_AM_UTIL_PVT.get_contract_transactions (
             p_khr_id        => l_contract_id,
             x_trn_tbl       => lx_trn_tbl,
             x_return_status => l_return_status);

        -- Check the return status
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

          -- Error occured in util proc, message set by util proc raise exp
          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        -- Check if termination transaction exists for the asset
        IF lx_trn_tbl.COUNT > 0 THEN

         -- A termination transaction for the contract CONTRACT_NUMBER
         -- is already in progress.
         OKL_API.set_message (
         			       p_app_name  	  => G_APP_NAME,
              			 p_msg_name  	  => 'OKL_AM_K_PENDING_TRN_ERROR',
                     p_token1       => 'CONTRACT_NUMBER',
                     p_token1_value => l_contract_number);

          RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

    ELSIF lp_quot_rec.accepted_yn IS NOT NULL
    AND lp_quot_rec.accepted_yn <> OKL_API.G_MISS_CHAR
    AND db_accepted_yn = G_YES
    AND lp_quot_rec.accepted_yn = G_NO THEN

        -- Quote QUOTE_NUMBER is already accepted.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_QUOTE_ALREADY_ACCP',
                             p_token1        => 'QUOTE_NUMBER',
                             p_token1_value  => db_quote_number);

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- RMUNJULU 17-DEC-02 2484327 -- END --


    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF k_dets_csr%ISOPEN THEN
        CLOSE k_dets_csr;
      END IF;
      IF get_k_num_csr%ISOPEN THEN
        CLOSE get_k_num_csr;
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF k_dets_csr%ISOPEN THEN
        CLOSE k_dets_csr;
      END IF;
      IF get_k_num_csr%ISOPEN THEN
        CLOSE get_k_num_csr;
      END IF;

      OKL_API.set_message(p_app_name     => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_updated_quote;



  -- Start of comments
  --
  -- Procedure Name	: create_restructure_quote
  -- Description	  : create the restructure quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU 23-DEC-02 2726739 Multi-currency changes, default
  --                  currency columns
  -- rmunjulu bug 3884338, default all date fields to NULL so that correct date is stamped.
  -- issue occurs when g_miss_date passed from rossetta layer does not match okl_api.g_miss_date
  --
  --
  -- End of comments
  PROCEDURE create_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_rec                      IN quot_rec_type,
    x_quot_rec                      OUT NOCOPY quot_rec_type) AS

    lp_quot_rec             quot_rec_type := p_quot_rec;
    lx_quot_rec             quot_rec_type;
    l_api_version           CONSTANT NUMBER := 1;
    l_api_name              CONSTANT VARCHAR2(30) := 'create_restructure_quote';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_request_id            NUMBER;
    l_trans_status          VARCHAR2(30);

    -- RMUNJULU 23-DEC-02 2726739 Added variable
    l_sys_date DATE;

  BEGIN
    --Check API version, initialize message list and create savepoint.
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

    -- RMUNJULU 23-DEC-02 2726739 Added select
    SELECT SYSDATE INTO l_sys_date FROM DUAL;

    -- rmunjulu bug 3695751, default all date fields to NULL so that correct date is stamped.
    -- issue occurs when g_miss_date passed from rossetta layer does not match okl_api.g_miss_date

    lp_quot_rec.date_effective_from := NULL;
    lp_quot_rec.date_effective_to := NULL;
    lp_quot_rec.date_requested := NULL;
    lp_quot_rec.date_proposal := NULL;
    lp_quot_rec.date_restructure_start := NULL;
    lp_quot_rec.date_restructure_end := NULL;
    lp_quot_rec.date_due := NULL;
    lp_quot_rec.date_approved := NULL;
    lp_quot_rec.date_accepted := NULL;
    lp_quot_rec.date_payment_received := NULL;
    lp_quot_rec.currency_conversion_date := NULL;

    -- check if quote valid
    validate_quote(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_quot_rec                    =>   lp_quot_rec,
           p_call_flag                   =>   'CREATE');

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the quote defaults
    set_quote_defaults(
         px_quot_rec        => lp_quot_rec,
         x_return_status    => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- RMUNJULU 23-DEC-02 2726739 Multi-currency changes
    -- Default the Multi-Currency Columns
    set_currency_defaults(
         px_quot_rec              => lp_quot_rec,
         p_sys_date               => l_sys_date,
         x_return_status          => l_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- call the pub tapi insert
    OKL_TRX_QUOTES_PUB.insert_trx_quotes (
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   p_init_msg_list,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_qtev_rec         =>   lp_quot_rec,
         x_qtev_rec         =>   lx_quot_rec,
         x_return_status    =>   l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Request Rent Restructure
    OKL_AM_RESTRUCTURE_RENTS_PVT.initiate_request (
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   p_init_msg_list,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_quote_id         =>   lx_quot_rec.id,
         x_request_id       =>   l_request_id,
         x_trans_status     =>   l_trans_status,
         x_return_status    =>   l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set the return status and out variables
    x_return_status := l_return_status;
    x_quot_rec      := lx_quot_rec;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

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

  END create_restructure_quote;

  -- Start of comments
  --
  -- Procedure Name	: create_restructure_quote
  -- Description	  : Create multiple restructure quotes
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE create_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_tbl                      IN quot_tbl_type,
    x_quot_tbl                      OUT NOCOPY quot_tbl_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name              CONSTANT VARCHAR2(30) := 'create_restructure_quote';
    l_api_version           CONSTANT NUMBER := 1;

  BEGIN

    --Check API version, initialize message list and create savepoint.
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

    -- Make sure PL/SQL table has records in it before passing
    IF (p_quot_tbl.COUNT > 0) THEN
      i := p_quot_tbl.FIRST;
      LOOP
        create_restructure_quote (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quot_rec                     => p_quot_tbl(i),
          x_quot_rec                     => x_quot_tbl(i));

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (i = p_quot_tbl.LAST);
        i := p_quot_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
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
  END create_restructure_quote;

  -- Start of comments
  --
  -- Procedure Name	: update_restructure_quote
  -- Description	  : Update restructure quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History        : RMUNJULU 30-DEC-02 2699412 Multi-currency changes, default
  --                  currency columns
  --                  RMUNJULU 31-JAN-03 2779255 Added code to get khr_id if not
  --                  passed to get the currency code
  --
  -- End of comments
  PROCEDURE update_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_rec                      IN quot_rec_type,
    x_quot_rec                      OUT NOCOPY quot_rec_type) AS

    --Get the database value of the updating quote
    -- RMUNJULU 31-JAN-03 2779255 Added khr_id
    CURSOR okl_get_qte_db_vals_csr ( p_qte_id IN NUMBER) IS
      SELECT QTE.accepted_yn,
             QTE.khr_id
      FROM   OKL_TRX_QUOTES_V QTE
      WHERE  QTE.id = p_qte_id;

    lp_quot_rec           quot_rec_type := p_quot_rec;
    lx_quot_rec           quot_rec_type;
    l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name            CONSTANT VARCHAR2(30) := 'update_restructure_quote';
    l_api_version         CONSTANT NUMBER := 1;
    db_accepted_yn        VARCHAR2(1);
    db_sysdate            DATE;
    l_event_name          VARCHAR2(200) := 'oracle.apps.okl.am.acceptrestquote';
    l_event_desc          VARCHAR2(2000);


       -- RMUNJULU 31-JAN-03 2779255 Added variable
       db_khr_id NUMBER;

  BEGIN

    --Check API version, initialize message list and create savepoint.
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

    -- initialize return variables
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;

    SELECT SYSDATE INTO db_sysdate FROM DUAL;

    -- Check the values being updated
    validate_updated_quote(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_quot_rec                    =>   lp_quot_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- RMUNJULU 31-JAN-03 2779255 get khr_id from DB
    OPEN  okl_get_qte_db_vals_csr(lp_quot_rec.id);
    FETCH okl_get_qte_db_vals_csr INTO db_accepted_yn, db_khr_id;
    CLOSE okl_get_qte_db_vals_csr;

    -- Set the qst_code to ACCEPTED if the quote is accepted now
    IF (lp_quot_rec.accepted_yn = G_YES AND db_accepted_yn = G_NO) THEN

      -- RMUNJULU 31-JAN-03 2779255 get khr_id if not passed
      IF lp_quot_rec.khr_id IS NULL
      OR lp_quot_rec.khr_id = OKL_API.G_MISS_NUM THEN

        lp_quot_rec.khr_id := db_khr_id;

      END IF;

      -- RMUNJULU 30-DEC-02 2699412 Multi-currency changes
      -- Default the Multi-Currency Columns
      set_currency_defaults(
           px_quot_rec       => lp_quot_rec,
           p_sys_date        => db_sysdate,
           x_return_status   => l_return_status);


      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      lp_quot_rec.qst_code := 'ACCEPTED';
      lp_quot_rec.date_accepted := db_sysdate;

    END IF;

    -- update the quote
    OKL_TRX_QUOTES_PUB.update_trx_quotes(
             p_api_version                  => p_api_version,
             p_init_msg_list                => p_init_msg_list,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_qtev_rec                     => lp_quot_rec,
             x_qtev_rec                     => lx_quot_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Raise WF if the quote is accepted now
    IF (lp_quot_rec.accepted_yn = G_YES AND db_accepted_yn = G_NO) THEN

      -- Raise Restructure Quote WorkFlow event
      OKL_AM_WF.raise_business_event (
                          	p_transaction_id => lp_quot_rec.id,
		                        p_event_name	   => l_event_name);

      -- Get the event name
      l_event_desc := OKL_AM_UTIL_PVT.get_wf_event_name(
                            p_wf_process_type => 'OKLAMARQ',
                            p_wf_process_name => 'QUOTE_ACCEPTANCE_PROC',
                            x_return_status   => l_return_status);

      -- raise exception if error
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Set message on stack
      -- Workflow event EVENT_NAME has been requested.
      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_WF_EVENT_MSG',
                          p_token1       => 'EVENT_NAME',
                          p_token1_value => l_event_desc);


      -- Save message from stack into transaction message table
      OKL_AM_UTIL_PVT.process_messages(
  	                      p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
    	                    p_trx_id		        => lp_quot_rec.id,
    	                    x_return_status     => l_return_status);

      -- raise exception if error
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;


    -- set return variables
    x_return_status    := l_return_status;
    x_quot_rec         := lx_quot_rec;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF okl_get_qte_db_vals_csr%ISOPEN THEN
        CLOSE okl_get_qte_db_vals_csr;
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
      IF okl_get_qte_db_vals_csr%ISOPEN THEN
        CLOSE okl_get_qte_db_vals_csr;
      END IF;
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
      IF okl_get_qte_db_vals_csr%ISOPEN THEN
        CLOSE okl_get_qte_db_vals_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END update_restructure_quote;

  -- Start of comments
  --
  -- Procedure Name	: update_restructure_quote
  -- Description	  : Update multiple restructure quotes
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE update_restructure_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_quot_tbl                      IN quot_tbl_type,
    x_quot_tbl                      OUT NOCOPY quot_tbl_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_restructure_quote';
    l_api_version           CONSTANT NUMBER := 1;
  BEGIN

    --Check API version, initialize message list and create savepoint.
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

    -- Make sure PL/SQL table has records in it before passing
    IF (p_quot_tbl.COUNT > 0) THEN
      i := p_quot_tbl.FIRST;
      LOOP
        update_restructure_quote (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quot_rec                     => p_quot_tbl(i),
          x_quot_rec                     => x_quot_tbl(i));

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (i = p_quot_tbl.LAST);
        i := p_quot_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

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

  END update_restructure_quote;

END OKL_AM_RESTRUCTURE_QUOTE_PVT;

/
