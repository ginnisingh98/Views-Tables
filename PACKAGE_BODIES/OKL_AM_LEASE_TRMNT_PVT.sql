--------------------------------------------------------
--  DDL for Package Body OKL_AM_LEASE_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LEASE_TRMNT_PVT" AS
/* $Header: OKLRLTNB.pls 120.77.12010000.13 2009/12/24 06:33:34 rgooty ship $ */


 G_LEVEL_PROCEDURE CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 G_LEVEL_EXCEPTION CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 G_LEVEL_STATEMENT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 G_MODULE_NAME CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_lease_trmnt_pvt.';

/* Bug 6674730 start */
subtype trxv_rec_type is OKL_TRX_ASSETS_PUB.thpv_rec_type;
subtype talv_rec_type is OKL_TXL_ASSETS_PUB.tlpv_rec_type;
subtype adpv_rec_type is okl_txd_assets_pvt.advv_rec_type;

G_TRANS_TYPE VARCHAR2(3) := 'CFA';
/* Bug 6674730 end */

/**----------------------------------------------------------------------------
  -- LOGIC
  ----------------------------------------------------------------------------

  Start API Transaction
  Rollback if setting transaction fails
  SET OVERALL STATUS

  If transaction not already set then
    Initialize Transaction Record
    **Insert Transaction  Record
    ** get id and pass along
  Else
    ** get trn rec and pass along
  End if

  Validate Lease + Contract
  SET OVERALL STATUS
  If validation failed then
    If batch process then
      **Update Transaction  Record
    End if
    abort
  End if

  Get Lines

  If contract expired then
    If evergreen_yn <> 'Y' Then
      Get Evergreen Eligibility
      If Batch process and Eligible Then
        Update contract header and lines
      End if
    End if
  End if

  SET OVERALL STATUS

  If return status = Success Then
    If set to evergreen then
      Set Transaction  Record
      **Update Transaction  Record
      SET OVERALL STATUS
      Rollback if Insert fails
      Abort
    Else
      Set Transaction  Record###
    End if
  Else
    Set Transaction  Record***
    **Update Transaction  Record
    SET OVERALL STATUS
    Rollback if Update fails
    Abort
  End if

  If Early Termination Then
    If Cancel Policies YN <> 'Y' Then
      Call Cancel Policies
      SET OVERALL STATUS
      Set Transaction  Record***
    End if
  Else
    Set Transaction  Record###
  End if

  If Total Balance < Tolerance Amount then
    Get Tolerance Amount
    Get Total Balance
    If close balances YN <> 'Y' then
      Call Adjust header to close balances
      SET OVERALL STATUS
      Call Accounting entries
      SET OVERALL STATUS
      Get code combination id
      Call Adjust Lines to close balances
      SET OVERALL STATUS
      Set Transaction  Record***
    End if
  Else
    Set Transaction  Record###
  End if

  If Streams to be updated Then
    If Update Streams YN <> 'Y' Then
      Call Update Streams
      SET OVERALL STATUS
      Set Transaction  Record***
    End if
  Else
    Set Transaction  Record###
  End if

  If Account Entries YN <> 'Y' Then
    Call Account Entries
    SET OVERALL STATUS
    Set Transaction  Record***
  End if

  If Term With Purchase Then
    If Asset Dispose <> 'Y' Then
      Call Asset Dispose
      SET OVERALL STATUS
      Set Transaction  Record***
    End if
    Set Transaction  Record###
  Else
    If Amortization YN <> 'Y' Then
      Call Amortization
      SET OVERALL STATUS
      Set Transaction  Record***
    End if
    If Asset Return YN <> 'Y' Then
      Call Asset Return
      SET OVERALL STATUS
      Set Transaction  Record***
    End if
    Set Transaction  Record###
  End If

  Set Transaction  Record***
  If overall status = Success and Update contract YN <> 'Y' then
    Update contract header and lines
    SET OVERALL STATUS
    Rollback if update fails
  End if

  **Update Transaction  Record
  SET OVERALL STATUS
  Rollback if insert fails

  End API Transaction


OKL_AM_LEASE_TRMNT_PVT
   -- Returns E or U only in case of Hard errors ie when errors are critical and
   -- need to rollabck the whole transaction. This will happen when there is a
   -- problem with creating or updating row in transaction table or validate
   -- lease/contract fails when it is not from batch process.
   -- All other errors such as not able to do accounting entries, or not able to
   -- update k header or lines will result in soft error so will be propagated
   -- out of this API as "Success".

OKL_AM_LEASE_LOAN_TRMNT_PVT
   -- The Rec Type procedure calls the rec type of Lease termination API
   -- The Tbl Type procedure calls the rec type of this same API

OKL_AM_LEASE_LOAN_TRMNT_PUB
   -- The Rec Type procedure calls the rec type of PVT API
   -- -- This version will be called from batch process, from termination quote
   -- -- API/ Termination Quote Update Screen
   -- The Tbl Type procedure calls the tbl type of PVT API
   -- -- This version will be called from Request Termination Screen
   -- -- This version will rollback if even one contract fails and will stop
   -- -- further processing as soon as it hits a contract which fails to
   -- -- terminate.

---------------------------------------------------------------------------**/

  -- Start of comments
  --
  -- Function Name : check_auto_invoice_yn
  -- Desciption     : Checks to see if auto invoice applicable
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 18-aug-05 BUYOUT_PROCESS
  --
  -- End of comments
  PROCEDURE check_auto_invoice_yn(
           p_term_rec        IN  term_rec_type,
           x_auto_invoce_yn  OUT NOCOPY VARCHAR2,
           x_return_status   OUT NOCOPY VARCHAR2)IS

     l_auto_invoce_yn  VARCHAR2(3);

     l_rule_code VARCHAR2(30);
     l_rgd_code  VARCHAR2(30);
     l_khr_id    NUMBER;

     l_rulv_rec   OKL_RULE_PUB.rulv_rec_type;
     l_params   OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

     l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
     l_dummy_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
     -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_auto_invoice_yn';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end

  BEGIN
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;

     l_auto_invoce_yn := 'N';

     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_quote_id = '||p_term_rec.p_quote_id);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
     END IF;
     -- Check if no quote and if new rule says Y
     IF p_term_rec.p_quote_id IS NULL
     OR p_term_rec.p_quote_id = OKL_API.G_MISS_NUM THEN -- means end of term processing

       l_rgd_code  := 'AMTFOC'; -- End of Term Purchase Option
       l_rule_code := 'AMTINV'; -- Automatically Invoice for Fixed Purchase Option

       l_khr_id := p_term_rec.p_contract_id;

       -- Check if Automatically Invoice YN is Y
     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_quote_id = '||p_term_rec.p_quote_id);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling OKL_AM_UTIL_PVT.get_rule_record');
     END IF;
       OKL_AM_UTIL_PVT.get_rule_record(
     p_rgd_code       => l_rgd_code,
     p_rdf_code     => l_rule_code,
     p_chr_id         => l_khr_id,
     p_cle_id         => NULL,
     x_rulv_rec     => l_rulv_rec,
      x_return_status => l_return_status,
     p_message_yn     => TRUE);

     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Called OKL_AM_UTIL_PVT.get_rule_record l_return_status = '||l_return_status);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information1 = '||l_rulv_rec.rule_information1);
     END IF;
       IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
          l_auto_invoce_yn  := nvl(l_rulv_rec.rule_information1,'N'); -- Automatically Invoice YN, NULL is considered N
       END IF;
     END IF;

     x_auto_invoce_yn := l_auto_invoce_yn;
     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'x_auto_invoce_yn = '||x_auto_invoce_yn);
     END IF;
     x_return_status := l_dummy_status; -- Don't use l_return_status, return success always

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
  END check_auto_invoice_yn;

  -- Start of comments
  --
  -- Function Name : get_purchase_amount
  -- Desciption     : gets the purchase amount for asset id
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 18-aug-05 BUYOUT_PROCESS
  --
  -- End of comments
  PROCEDURE get_purchase_amount(
           p_term_rec        IN  term_rec_type,
           p_kle_id          IN  NUMBER,
           x_purchase_amount OUT NOCOPY NUMBER,
           x_return_status   OUT NOCOPY VARCHAR2)IS

     l_purchase_amount NUMBER;

     l_rule_code VARCHAR2(30);
     l_rgd_code  VARCHAR2(30);
     l_khr_id    NUMBER;

     l_calc_option    VARCHAR2(150);
     l_fixed_value    NUMBER;
     l_formula_name    VARCHAR2(150);
     l_formula_value   NUMBER;
     l_prorate         VARCHAR2(150);

     l_rulv_rec   OKL_RULE_PUB.rulv_rec_type;
     l_params   OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

     l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
     l_dummy_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
     l_line_oec NUMBER;
     l_contract_oec NUMBER;
     G_EXCEPTION_ERROR EXCEPTION;

     -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_purchase_amount';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
     l_purchase_amount := 0;

     l_rgd_code := 'AMTFOC'; -- End of Term Purchase Option
     l_rule_code := 'AMBPOC'; -- Purchase Options
     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_kle_id = '||p_kle_id);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Called OKL_AM_UTIL_PVT.get_rule_record l_return_status = '||l_return_status);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information1 = '||l_rulv_rec.rule_information1);
     END IF;
     l_khr_id := p_term_rec.p_contract_id;
     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling OKL_AM_UTIL_PVT.get_rule_record');
     END IF;
     -- Get End of Term Purchase Amount Details
     OKL_AM_UTIL_PVT.get_rule_record(
     p_rgd_code       => l_rgd_code,
     p_rdf_code     => l_rule_code,
     p_chr_id         => l_khr_id,
     p_cle_id         => NULL,
     x_rulv_rec     => l_rulv_rec,
      x_return_status => l_return_status,
     p_message_yn     => TRUE);

     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Called OKL_AM_UTIL_PVT.get_rule_record l_return_status = '||l_return_status);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information1 = '||l_rulv_rec.rule_information1);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information2 = '||l_rulv_rec.rule_information2);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information3 = '||l_rulv_rec.rule_information3);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information4 = '||l_rulv_rec.rule_information4);
     END IF;

     IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
         l_calc_option   := l_rulv_rec.rule_information1; -- Purchase Option
         l_fixed_value   := NVL (TO_NUMBER (l_rulv_rec.rule_information2), 0); -- Purchase Option Amount
         l_formula_name   := l_rulv_rec.rule_information3; -- Purchase Option Formula
         l_prorate        := l_rulv_rec.rule_information4; -- Purchase Option Prorate
     ELSE
       RAISE G_EXCEPTION_ERROR;
     END IF;

     IF l_calc_option = 'NOT_APPLICABLE' THEN -- Purchase Amount is NOT APPLICABLE

         l_purchase_amount := 0;

     ELSIF l_calc_option = 'USE_FIXED_AMOUNT' THEN -- Purchase Amount is FIXED AMOUNT

         l_purchase_amount := l_fixed_value;

     ELSIF l_calc_option = 'USE_FORMULA' THEN -- Purchase Amount is FORMULA

             IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling OKL_AM_UTIL_PVT.get_formula_value');
             END IF;
            -- Get the formula value
            OKL_AM_UTIL_PVT.get_formula_value (
                    p_formula_name            => l_formula_name,
                    p_chr_id                  => l_khr_id,
                    p_cle_id                  => p_kle_id,
                    p_additional_parameters   => l_params,
                    x_formula_value           => l_formula_value,
                    x_return_status           => l_return_status);
            IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Called OKL_AM_UTIL_PVT.get_formula_value l_return_status = '||l_return_status);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_formula_value = '||l_formula_value);
            END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_ERROR;
            ELSE
              l_purchase_amount := l_formula_value;
            END IF;
     END IF;

     IF l_prorate = 'PRORATE' AND l_purchase_amount <> 0 THEN

        -- Get line oec (evaluate formula contract_oec and pass line id)
        IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling OKL_AM_UTIL_PVT.get_formula_value');
        END IF;
        OKL_AM_UTIL_PVT.get_formula_value (
    p_formula_name           => 'CONTRACT_OEC',
    p_chr_id               => l_khr_id,
                p_cle_id                  => p_kle_id,
             p_additional_parameters   => l_params,
    x_formula_value           => l_line_oec,
    x_return_status           => l_return_status);
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Called OKL_AM_UTIL_PVT.get_formula_value l_return_status = '||l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_formula_value = '||l_formula_value);
    END IF;

         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_ERROR;
         END IF;

        -- Get contract oec
        IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling OKL_AM_UTIL_PVT.get_formula_value');
        END IF;
        OKL_AM_UTIL_PVT.get_formula_value (
    p_formula_name           => 'CONTRACT_OEC',
    p_chr_id               => l_khr_id,
                p_cle_id                  => NULL,
             p_additional_parameters   => l_params,
    x_formula_value           => l_contract_oec,
    x_return_status           => l_return_status);
    IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Called OKL_AM_UTIL_PVT.get_formula_value l_return_status = '||l_return_status);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_formula_value = '||l_formula_value);
    END IF;


         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_ERROR;
         END IF;

  IF l_contract_oec <> 0 THEN
       l_purchase_amount := l_purchase_amount * l_line_oec/l_contract_oec;
    ELSE
       l_purchase_amount := 0;
  END IF;

     END IF;

     x_purchase_amount := l_purchase_amount;
     x_return_status := l_return_status;

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;
  END get_purchase_amount;

  -- Start of comments
  --
  -- Function Name : check_k_evergreen_ear
  -- Desciption     : Checks to see if any old trn exists which had set contract to evergreen
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 04-MAR-04 3485854 Created
  --
  -- End of comments
  FUNCTION check_k_evergreen_ear(
                       p_khr_id          IN NUMBER,
                       p_tcn_id          IN NUMBER,
                       x_return_status   OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

   -- Check if another transaction exists which is processed and for which tmt_evergreen_yn was Y
   -- which means this contract was evergreen earlier
   CURSOR chk_evergreen_ear_csr ( p_khr_id IN NUMBER, p_tcn_id IN NUMBER) IS
    SELECT trx.tmt_evergreen_yn
    FROM   OKL_TRX_CONTRACTS trx
    WHERE  trx.khr_id =  p_khr_id
    AND    trx.tmt_status_code = 'PROCESSED' --changed by akrangan sla tmt_status_code changes
    AND    trx.tcn_type IN ('TMT','ALT','EVG')-- akrangan bug 5354501 fix added 'EVG'
    AND    trx.tmt_evergreen_yn = 'Y'
--rkuttiya added for 12.1.1 Multi GAAP
    AND    trx.representation_type = 'PRIMARY'
    AND    trx.id <> p_tcn_id;

    l_evergreen_earlier VARCHAR2(3) := 'N';

    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_k_evergreen_ear';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_khr_id = '||p_khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_tcn_id = '||p_tcn_id);
      END IF;
      FOR chk_evergreen_ear_rec IN chk_evergreen_ear_csr (p_khr_id, p_tcn_id) LOOP
         l_evergreen_earlier := chk_evergreen_ear_rec.tmt_evergreen_yn;
      END LOOP;

      IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_evergreen_earlier= '||l_evergreen_earlier);
      END IF;

      IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
      END IF;

      RETURN l_evergreen_earlier;

  EXCEPTION

     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

         RETURN NULL;

  END  check_k_evergreen_ear;

  -- Start of comments
  --
  -- Procedure Name : delink_contract_from_asset
  -- Desciption     :  contract ID from FA asset, upon full termination of a Booked or Evergreen contract
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : SECHAWLA 18-Dec-07 6690811 Created
  --                  SECHAWLA 02-Jan-08 6720667 - Check if contract ID is already null, before updating to Null
  --                  rmunjulu bug 6853566 modify delink to work from partial termination aswell
  --
  -- End of comments

  PROCEDURE delink_contract_from_asset(
                       p_api_version      IN  NUMBER,
                       x_msg_count        OUT  NOCOPY NUMBER,
                       x_msg_data         OUT  NOCOPY VARCHAR2,
                       p_full_term_yn     IN VARCHAR2 DEFAULT NULL, -- rmunjulu bug 6853566
                       p_khr_id           IN NUMBER,
                       p_klev_tbl         IN OKL_AM_CNTRCT_LN_TRMNT_PVT.klev_tbl_type DEFAULT l_emty_tbl, -- rmunjulu bug 6853566
                       p_sts_code         IN VARCHAR2 DEFAULT NULL, -- rmunjulu bug 6853566 make it default null
                       p_quote_accpt_date IN DATE,
                       p_quote_eff_date   IN DATE,
                       x_return_status    OUT NOCOPY VARCHAR2) IS

   -- get the active financial asset lines for the contract
   CURSOR l_okcklines_csr(cp_khr_id IN NUMBER, cp_sts_code IN VARCHAR2) IS
   SELECT a.id, a.name
   FROM   okc_k_lines_v a , okc_line_styles_b b
   WHERE  a.chr_id = cp_khr_id
   AND    a.lse_id = b.id
   AND    b.lty_code = 'FREE_FORM1'
   AND    a.sts_code = cp_sts_code;

   -- Get all the FA books (corp and tax) that asset belongs to
   CURSOR l_fabooks_csr(cp_asset_number IN VARCHAR2, cp_sysdate IN DATE) IS
   SELECT fb.book_type_code, fb.asset_id, fb.contract_id --SECHAWLA 02-Jan-08 6720667 : Added contract_id
   FROM   fa_books fb, fa_additions_b fab, fa_book_controls fbc
   WHERE  fb.asset_id = fab.asset_id
   AND    fb.book_type_code = fbc.book_type_code
   AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
   AND    fb.transaction_header_id_out IS NULL
   AND    fab.asset_number = cp_asset_number;


   l_asset_fin_rec_empty_adj    FA_API_TYPES.asset_fin_rec_type;
   l_asset_hdr_empty_rec        FA_API_TYPES.asset_hdr_rec_type;
   l_trans_empty_rec			FA_API_TYPES.trans_rec_type;
   l_adj_trans_rec              FA_API_TYPES.trans_rec_type;
   l_adj_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_adj          FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new		    FA_API_TYPES.asset_fin_rec_type;
   l_inv_trans_rec              FA_API_TYPES.inv_trans_rec_type;
   l_adj_inv_tbl                FA_API_TYPES.inv_tbl_type;
   l_asset_deprn_rec_adj        FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new        FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new    FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;
   l_asset_fin_mrc_tbl_new	    FA_API_TYPES.asset_fin_tbl_type;


   l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   delink_exception          EXCEPTION;

   l_module_name VARCHAR2(500) := G_MODULE_NAME || 'delink_contract_from_asset';
   is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
   is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
   is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

   i NUMBER;

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_khr_id = '||p_khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_sts_code = '||p_sts_code);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_quote_accpt_date = '||p_quote_accpt_date);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_quote_eff_date = '||p_quote_eff_date);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_full_term_yn = '||nvl(p_full_term_yn,'Y'));
      END IF;


      IF p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- chr id is required
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Contract Id');
         RAISE delink_exception;
      END IF;

      -- rmunjulu modified to check for statusonly in case of full termination
      IF nvl(p_full_term_yn,'Y') = 'Y' AND (p_sts_code IS NULL OR p_sts_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Status code is required
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Contract Status Code');
         RAISE delink_exception;
      END IF;

      IF p_quote_accpt_date IS NULL OR p_quote_accpt_date = OKL_API.G_MISS_DATE THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Quote Acceptance Date is required
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Quote Acceptance Date');
         RAISE delink_exception;
      END IF;

      IF p_quote_eff_date IS NULL OR p_quote_eff_date = OKL_API.G_MISS_DATE THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Quote Effective Date is required
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Quote Effective Date');
         RAISE delink_exception;
      END IF;

      IF nvl(p_full_term_yn ,'Y') = 'Y' THEN -- rmunjulu bug 6853566 full termination-- do earlier processing
      IF (is_debug_statement_on) THEN

        okl_debug_pub.log_debug (g_level_statement, l_module_name, 'p_full_term_yn :'||nvl(p_full_term_yn ,'Y'));

      END IF;
      FOR l_okcklines_rec IN l_okcklines_csr(p_khr_id, p_sts_code) LOOP

          FOR l_fabooks_rec IN l_fabooks_csr(l_okcklines_rec.name, p_quote_accpt_date ) LOOP

           --SECHAWLA 02-Jan-08 6720667 - Added the following IF
           IF l_fabooks_rec.contract_id IS NOT NULL THEN

                l_asset_fin_rec_adj := l_asset_fin_rec_empty_adj ;
                l_adj_trans_rec := l_trans_empty_rec;
                l_adj_asset_hdr_rec := l_asset_hdr_empty_rec;

                l_adj_trans_rec.transaction_subtype := 'AMORTIZED';
                l_adj_asset_hdr_rec.asset_id :=  l_fabooks_rec.asset_id;
                l_adj_asset_hdr_rec.book_type_code := l_fabooks_rec.book_type_code;
                l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;
                l_adj_trans_rec.transaction_date_entered := p_quote_eff_date;

                IF (is_debug_statement_on) THEN

                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_okcklines_rec.name: '|| l_okcklines_rec.name);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, p_quote_accpt_date: '|| p_quote_accpt_date);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_trans_rec.transaction_subtype: '|| l_adj_trans_rec.transaction_subtype);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_asset_hdr_rec.asset_id: '|| l_adj_asset_hdr_rec.asset_id);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_asset_hdr_rec.book_type_code: '|| l_adj_asset_hdr_rec.book_type_code);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_trans_rec.transaction_date_entered: '|| l_adj_trans_rec.transaction_date_entered);

                END IF;

                fa_adjustment_pub.do_adjustment(
                                      p_api_version              => p_api_version,
                                      p_init_msg_list            => OKC_API.G_FALSE,
                                      p_commit                   => FND_API.G_FALSE,
                                      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                                      p_calling_fn               => NULL,
                                      x_return_status            => x_return_status,
                                      x_msg_count                => x_msg_count,
                                      x_msg_data                 => x_msg_data,
                                      px_trans_rec               => l_adj_trans_rec,
                                      px_asset_hdr_rec           => l_adj_asset_hdr_rec,
                                      p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
                                      x_asset_fin_rec_new        => l_asset_fin_rec_new,
                                      x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
                                      px_inv_trans_rec           => l_inv_trans_rec,
                                      px_inv_tbl                 => l_adj_inv_tbl,
                                      p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
                                      x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
                                      x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                      p_group_reclass_options_rec => l_group_reclass_options_rec);

                IF (is_debug_statement_on) THEN

                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'AFTER CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, x_return_status: '|| x_return_status);

                END IF;

               IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                  -- Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.
                  OKC_API.set_message(  p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_AM_AMT_TRANS_FAILED',
                                        p_token1        =>  'TRX_TYPE',
                                        p_token1_value  =>  'Contract Delink',
                                        p_token2        =>  'ASSET_NUMBER',
                                        p_token2_value  =>  l_okcklines_rec.name,
                                        p_token3        =>  'BOOK',
                                        p_token3_value  =>  l_fabooks_rec.book_type_code);
                   RAISE delink_exception;
               END IF;
            END IF; --SECHAWLA 02-Jan-08 6720667

         END LOOP;


      END LOOP;

      ELSE -- partial termination

      IF (is_debug_statement_on) THEN

        okl_debug_pub.log_debug (g_level_statement, l_module_name, 'p_full_term_yn :'||nvl(p_full_term_yn ,'Y'));

      END IF;
      -- if assets present for contract
      IF (p_klev_tbl.COUNT > 0) THEN
         -- Loop thru assets table
         i := p_klev_tbl.FIRST;
         LOOP


            FOR l_fabooks_rec IN l_fabooks_csr (p_klev_tbl (i).p_asset_name, p_quote_accpt_date) LOOP

              IF l_fabooks_rec.contract_id IS NOT NULL THEN

                l_asset_fin_rec_adj := l_asset_fin_rec_empty_adj ;
                l_adj_trans_rec := l_trans_empty_rec;
                l_adj_asset_hdr_rec := l_asset_hdr_empty_rec;

                l_adj_trans_rec.transaction_subtype := 'AMORTIZED';
                l_adj_asset_hdr_rec.asset_id :=  l_fabooks_rec.asset_id;
                l_adj_asset_hdr_rec.book_type_code := l_fabooks_rec.book_type_code;
                l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;
                l_adj_trans_rec.transaction_date_entered := p_quote_eff_date;

                IF (is_debug_statement_on) THEN

                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, p_klev_tbl('|| i || ').p_kle_id: '|| p_klev_tbl (i).p_kle_id);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, p_klev_tbl('|| i || ').p_asset_name: '|| p_klev_tbl (i).p_asset_name);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, p_quote_accpt_date: '|| p_quote_accpt_date);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_trans_rec.transaction_subtype: '|| l_adj_trans_rec.transaction_subtype);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_asset_hdr_rec.asset_id: '|| l_adj_asset_hdr_rec.asset_id);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_asset_hdr_rec.book_type_code: '|| l_adj_asset_hdr_rec.book_type_code);
                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'BEFORE CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, l_adj_trans_rec.transaction_date_entered: '|| l_adj_trans_rec.transaction_date_entered);

                END IF;

                fa_adjustment_pub.do_adjustment(
                                      p_api_version              => p_api_version,
                                      p_init_msg_list            => OKC_API.G_FALSE,
                                      p_commit                   => FND_API.G_FALSE,
                                      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                                      p_calling_fn               => NULL,
                                      x_return_status            => x_return_status,
                                      x_msg_count                => x_msg_count,
                                      x_msg_data                 => x_msg_data,
                                      px_trans_rec               => l_adj_trans_rec,
                                      px_asset_hdr_rec           => l_adj_asset_hdr_rec,
                                      p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
                                      x_asset_fin_rec_new        => l_asset_fin_rec_new,
                                      x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
                                      px_inv_trans_rec           => l_inv_trans_rec,
                                      px_inv_tbl                 => l_adj_inv_tbl,
                                      p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
                                      x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
                                      x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                      p_group_reclass_options_rec => l_group_reclass_options_rec);

                IF (is_debug_statement_on) THEN

                  okl_debug_pub.log_debug (g_level_statement, l_module_name,
                    'AFTER CALL TO FA_ADJUSTMENT_PUB.DO_ADJUSTMENT, x_return_status: '|| x_return_status);

                END IF;

                 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                    -- Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_AM_AMT_TRANS_FAILED',
                                        p_token1        =>  'TRX_TYPE',
                                        p_token1_value  =>  'Contract Delink',
                                        p_token2        =>  'ASSET_NUMBER',
                                        p_token2_value  =>  p_klev_tbl (i).p_asset_name,
                                        p_token3        =>  'BOOK',
                                        p_token3_value  =>  l_fabooks_rec.book_type_code);
                    RAISE delink_exception;
                 END IF;
               END IF;

            END LOOP; -- end of for loop

            EXIT WHEN (i = p_klev_tbl.LAST);
            i := p_klev_tbl.NEXT (i);
         END LOOP;      -- end of asset table loop

      END IF;
      END IF;

      IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
      END IF;


  EXCEPTION
     WHEN delink_exception THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'delink_exception');
        END IF;

        IF l_okcklines_csr%ISOPEN THEN
           CLOSE l_okcklines_csr;
        END IF;

        IF l_fabooks_csr%ISOPEN THEN
           CLOSE l_fabooks_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        IF l_okcklines_csr%ISOPEN THEN
           CLOSE l_okcklines_csr;
        END IF;

        IF l_fabooks_csr%ISOPEN THEN
           CLOSE l_fabooks_csr;
        END IF;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END  delink_contract_from_asset;

  -- Start of comments
  --
  -- Procedure Name : process_amortize
  -- Desciption     : Calls the Amortization API to do amortization
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 04-MAR-04 3485854 Moved Process_amortize out of
  --                  process_amortize_and_return so that it can be called from
  --                  evergreen too.
  --                : RMUNJULU 3485854 11-MAR-04 Added code to set return status properly
  --                : rmunjulu EDAT Added code to get the quote eff date and check for early term based on that
  --                  Also pass quote eff date and quote acceptance date to amortize api
  --                : rmunjulu 4150696 Changed to pass contract end date as effective dates when calling
  --                  AMORTIZE API
  --                : sechawla 18-dec-07 6690811 - delink contract id from fa asset for full termination of
  --                  Booked (thru term quote or EOT) or Evergreen contract.
  --                : sechawla 21-dec-07 6690811 - reverted back the changes done on 18-dec-07 for the same bug
  --                  and added IF block at the end.
  --
  -- End of comments
  PROCEDURE process_amortize(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2 DEFAULT NULL,
           p_call_origin                 IN VARCHAR2 DEFAULT NULL)  IS

   -- Cursor to get the end date of contract
   -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   CURSOR get_k_end_date_csr ( p_khr_id IN NUMBER) IS
    SELECT end_date, sts_code    --sechawla 18-dec-07 6690811 : added sts_code
    FROM   OKC_K_HEADERS_b       --sechawla 18-dec-07 6690811 : changed OKC_K_HEADERS_V to OKC_K_HEADERS_b
    WHERE  id =  p_khr_id;

   --sechawla 18-dec-07 6690811
   l_k_sts_code            VARCHAR2(30);

   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

   l_k_end_date            DATE := OKL_API.G_MISS_DATE;

   l_early_term_yn         VARCHAR2(1) := G_NO;

   l_trn_already_set   VARCHAR2(3);
   l_evergreen_earlier VARCHAR2(3) := 'N';

   -- rmunjulu EDAT
   l_quote_accpt_date DATE;
   l_quote_eff_date DATE;

   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_amortize';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end

  BEGIN  -- begin for amortize
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

     -- sechawla -
     -- p_call_origin = EVERGREEN, when contract is getting converted to Evergreen
     -- p_call_origin = TERMINATION, during full termination of Evergreen contract
     -- p_call_origin = TERMINATION, during EOT processing of a Booked contract
     -- p_call_origin = TERMINATION, during full termination of a Booked contract
      -- Start a savepoint
      SAVEPOINT asset_amortize;

      IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_trn_already_set = '||p_trn_already_set);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'px_tcnv_rec.tmt_amortization_yn = '||px_tcnv_rec.tmt_amortization_yn);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_contract_id =  '||p_term_rec.p_contract_id);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'px_tcnv_rec.id = '||px_tcnv_rec.id);
      END IF;
      IF p_trn_already_set IS NULL THEN
        l_trn_already_set := G_NO;
      ELSE
        l_trn_already_set := p_trn_already_set;
      END IF;

      -- Check if amortization required
      IF (l_trn_already_set = G_YES
          AND NVL(px_tcnv_rec.tmt_amortization_yn, '?') <> G_YES)
      OR (l_trn_already_set = G_NO) THEN

          -- CHECK TO see IF old evergreen transaction exists
          -- Check if another transaction exists which is processed and for which tmt_evergreen_yn was Y
          -- which means this contract was evergreen earlier
          -- so no need to run amortization again
          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling check_k_evergreen_ear ');
          END IF;
          l_evergreen_earlier := check_k_evergreen_ear(
                                    p_khr_id          => p_term_rec.p_contract_id,
                                    p_tcn_id          => px_tcnv_rec.id,
                                    x_return_status   => l_return_status);

          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called check_k_evergreen_ear l_return_status =  '||l_return_status);
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_evergreen_earlier = '||l_evergreen_earlier);
          END IF;

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occurred during the creation of an amortization transaction
            -- for assets of contract CONTRACT_NUMBER.
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_ERR_AMORTIZE',
                                 p_token1        => 'CONTRACT_NUMBER',
                                 p_token1_value  => p_term_rec.p_contract_number);

          END IF;

          --sechawla 18-dec-07 6690811 : Moved the folllowing code outside here from the IF below
          OPEN  get_k_end_date_csr(p_term_rec.p_contract_id);
          FETCH get_k_end_date_csr INTO l_k_end_date, l_k_sts_code; --sechawla 18-dec-07 6690811 : added l_k_sts_code
          CLOSE get_k_end_date_csr;
          IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

             l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
             l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

          ELSE

             l_quote_accpt_date := l_k_end_date;  -- rmunjulu 4150696 Changed to pass contract end date
             l_quote_eff_date := l_k_end_date; -- rmunjulu 4150696 Changed to pass contract end date

          END IF;
          IF (l_k_end_date <> OKL_API.G_MISS_DATE)
          AND (TRUNC(l_k_end_date) > TRUNC(l_quote_eff_date)) THEN -- rmunjulu EDAT
            l_early_term_yn := G_YES;
          END IF;
          --sechawla 18-dec-07 6690811 : end move


          -- Check to make sure amortization was not done
          IF NVL(l_evergreen_earlier,'N') <> 'Y' THEN  --termination(full) of a Booked contract
             --sechawla - This condition is met for Full Termination of a Booked contract (thru term quote or EOT)
             --and also when contract is changing to Evergreen

          -- RMUNJULU 3018641 Step Message
          -- Step : Amortization
          OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_AMT');

          -- call amortization

          --sechawla 18-dec-07 6690811 : Moved outside the IF
          --OPEN  get_k_end_date_csr(p_term_rec.p_contract_id);
          --FETCH get_k_end_date_csr INTO l_k_end_date, l_k_sts_code; --sechawla 18-dec-07 6690811 : added l_k_sts_code
          --CLOSE get_k_end_date_csr;

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

          -- rmunjulu EDAT
          -- If quote exists then cancelation date is quote eff from date else sysdate

          /* --sechawla 18-dec-07 6690811 : Moved outside the IF
          IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

             l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
             l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

          ELSE

             l_quote_accpt_date := l_k_end_date;  -- rmunjulu 4150696 Changed to pass contract end date
             l_quote_eff_date := l_k_end_date; -- rmunjulu 4150696 Changed to pass contract end date

          END IF;
          */

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

          /* --sechawla 18-dec-07 6690811 : Moved outside the IF
          IF (l_k_end_date <> OKL_API.G_MISS_DATE)
          AND (TRUNC(l_k_end_date) > TRUNC(l_quote_eff_date)) THEN -- rmunjulu EDAT
            l_early_term_yn := G_YES;
          END IF;
          */

          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_AMORTIZE_PUB.create_offlease_asset_trx ');
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_early_term_yn = '||l_early_term_yn);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_quote_eff_date = '||l_quote_eff_date);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_quote_accpt_date =  '||l_quote_accpt_date);
          END IF;
          OKL_AM_AMORTIZE_PUB.create_offlease_asset_trx(
            p_api_version                => p_api_version,
            p_init_msg_list              => OKL_API.G_FALSE,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            p_contract_id                 => p_term_rec.p_contract_id,
            p_early_termination_yn        => l_early_term_yn,
            p_quote_eff_date              => l_quote_eff_date,    -- rmunjulu EDAT
            p_quote_accpt_date            => l_quote_accpt_date); -- rmunjulu EDAT

          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_AMORTIZE_PUB.create_offlease_asset_trx l_return_status =  '||l_return_status);
          END IF;
          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occurred during the creation of an amortization transaction
            -- for assets of contract CONTRACT_NUMBER.
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_ERR_AMORTIZE',
                                 p_token1        => 'CONTRACT_NUMBER',
                                 p_token1_value  => p_term_rec.p_contract_number);

          END IF;

          -- Raise exception to rollback to savepoint if error
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


          -- store the highest degree of error
          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling set_overall_status');
          END IF;
          set_overall_status(
            p_return_status               => l_return_status,
            px_overall_status             => px_overall_status);
          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called set_overall_status');
          END IF;

          -- set the transaction record for amortization
          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling set_transaction_rec');
          END IF;
          set_transaction_rec(
            p_return_status               => l_return_status,
            p_overall_status              => px_overall_status,
            p_tmt_flag                    => 'TMT_AMORTIZATION_YN',
            p_tsu_code                    => 'WORKING',
            px_tcnv_rec                   => px_tcnv_rec);

          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called set_transaction_rec');
          END IF;

          ELSE
            -- Message : Amortization done earlier
            NULL;

          END IF;

          -- rmunjulu bug 6853566 The call to delink should be in this IF so that it is run only
          -- when amortize is done, also set a message if error and set the amortize step flag
          --sechawla 21-dec-07 6690811 - Delink Contract ID upon full termination of a Booked contract - begin
          IF p_call_origin <> 'EVERGREEN' then
          -- Delink the contract ID in case of full termination of a Booked contract, full termination of an
          -- Evergreen contract and contract expiration. Do not delink contract ID when contract is converting to
          -- Evergreen (p_call_origin = 'EVERGREEN')
          delink_contract_from_asset(
                       p_api_version      => p_api_version,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data,
                       p_khr_id           => p_term_rec.p_contract_id,
                       p_sts_code         => l_k_sts_code,
                       p_quote_accpt_date => l_quote_accpt_date,
                       p_quote_eff_date   => l_quote_eff_date,
                       x_return_status    => l_return_status);

          -- rmunjulu bug 6853566
          set_transaction_rec(
            p_return_status               => l_return_status,
            p_overall_status              => px_overall_status,
            p_tmt_flag                    => 'TMT_AMORTIZATION_YN',
            p_tsu_code                    => 'WORKING',
            px_tcnv_rec                   => px_tcnv_rec);

          -- rmunjulu bug 6853566
          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occurred during the creation of an amortization transaction
            -- for assets of contract CONTRACT_NUMBER.
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_ERR_AMORTIZE',
                                 p_token1        => 'CONTRACT_NUMBER',
                                 p_token1_value  => p_term_rec.p_contract_number);

          END IF;

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          END IF;
          --sechawla 21-dec-07 6690811 - Delink Contract ID upon full termination of a Booked contract - end

      END IF;


      -- RMUNJULU 3485854 11-MAR-04 Set the return_status
      x_return_status := l_return_status;

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF get_k_end_date_csr%ISOPEN THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;

         x_return_status := OKL_API.G_RET_STS_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

         IF get_k_end_date_csr%ISOPEN THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF get_k_end_date_csr%ISOPEN THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_amortize;


  -- Start of comments
  --
  -- Procedure Name : evergreen_eligibility
  -- Description : Checks if contract eligible for evergreen
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE evergreen_eligibility(
           p_term_rec                    IN term_rec_type,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_rule_found                  OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2)  IS

     l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_rule_found             VARCHAR2(1) := G_NO;
     l_rulv_rec              OKL_AM_CALCULATE_QUOTE_PVT.rulv_rec_type;
     l_rule_code            CONSTANT VARCHAR2(30) := 'LAEVEL';

     -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'evergreen_eligibility';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
    END IF;
    OKL_AM_UTIL_PVT.get_rule_record(
    p_rgd_code             => 'LAEVEL',
        p_rdf_code             => l_rule_code,
    p_chr_id               => p_term_rec.p_contract_id,
    p_cle_id               => NULL,
        x_rulv_rec             => l_rulv_rec,
       x_return_status         => l_return_status,
      p_message_yn           => FALSE);
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record l_return_status = '||l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_rulv_rec.rule_information1 = '||l_rulv_rec.rule_information1);
    END IF;
    IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
      IF (NVL (l_rulv_rec.rule_information1, '*') = G_YES) THEN
        l_rule_found := G_YES;
      END IF;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      l_return_status := OKL_API.G_RET_STS_SUCCESS;
      l_rule_found    := G_NO;
    END IF;

    x_return_status  := l_return_status;
    x_rule_found     := l_rule_found;

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

     x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     -- Set the oracle error message
     OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END evergreen_eligibility;


  -- Start of comments
  --
  -- Procedure Name : get_asset_name
  -- Description   : gets the name of asset for the line
  -- Business Rules :
  -- Parameters    :
  -- Version      : 1.0
  --
  -- End of comments
  FUNCTION get_asset_name ( p_kle_id IN NUMBER ) RETURN VARCHAR2 IS

    -- Cursor to get the asset name for the line number passed
    CURSOR  k_lines_csr(p_cle_id IN NUMBER) IS
    SELECT  OKLV.name           name
    FROM    OKC_K_LINES_V       OKLV
    WHERE   OKLV.id   = p_cle_id;

    l_name   OKC_K_LINES_V.name%TYPE;

    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_asset_name';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_kle_id = '||p_kle_id);
    END IF;

    OPEN k_lines_csr (p_kle_id);
    FETCH k_lines_csr INTO l_name;
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_name = '||l_name);
    END IF;
    IF k_lines_csr%FOUND THEN
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
      END IF;
      RETURN l_name;
    ELSE
      IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
      END IF;
      RETURN NULL;
    END IF;
    CLOSE k_lines_csr;


  EXCEPTION
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     IF k_lines_csr%ISOPEN THEN
        CLOSE k_lines_csr;
     END IF;

     -- Set the oracle error message
     OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);
     RETURN NULL;
  END get_asset_name;


  -- Start of comments
  --
  -- Procedure Name : initialize_transaction
  -- Description : Initializes the transaction record for the contract
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 05-MAR-03 Added code to store tmt_recycle_yn flag
  --
  -- End of comments
  PROCEDURE initialize_transaction (
    px_tcnv_rec                    IN OUT NOCOPY tcnv_rec_type,
    p_term_rec                     IN term_rec_type,
    p_sys_date                     IN DATE,
    p_control_flag                 IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    --akrangan bug 5354501 fix start
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2) IS


 	    CURSOR l_k_end_csr ( p_khr_id IN NUMBER) IS
 	      SELECT khr.end_date,
 	             khr.sts_code
 	      FROM   OKC_K_HEADERS_V khr
 	      WHERE  khr.id = p_khr_id;
  --akrangan bug 5354501 fix end

   l_try_id                NUMBER;
   l_currency_code         VARCHAR2(2000);
   l_trans_meaning         VARCHAR2(200);
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
   l_legal_entity_id       NUMBER;
    --akrangan bug 5354501 fix start
    l_k_end_date            DATE;
    l_rule_found            VARCHAR2(1) := G_NO;
    l_try_name              VARCHAR2(30);
    l_trans_code            VARCHAR2(30);
    l_tcn_type              VARCHAR2(3);
    l_k_sts_code            VARCHAR2(200);
    l_evergreen_earlier     VARCHAR2(3) := 'N';
  --akrangan bug 5354501 fix end

  -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'initialize_transaction';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    x_return_status   :=   OKL_API.G_RET_STS_SUCCESS;
--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
      l_legal_entity_id     :=  OKL_LEGAL_ENTITY_UTIL.get_khr_le_id (p_term_rec.p_contract_id);
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_legal_entity_id = '||l_legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_control_flag = '||p_control_flag);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
    END IF;
    IF p_control_flag = 'CREATE' THEN
   --akrangan bug 5354501 fix start
 	       -- check if contract is eligible for Evergreen

 	         -- Get the contract end date
 	         OPEN l_k_end_csr ( p_term_rec.p_contract_id);

 	         FETCH l_k_end_csr INTO l_k_end_date, l_k_sts_code;
 	         CLOSE l_k_end_csr;
 	         IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_k_end_date = '||l_k_end_date);
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_k_sts_code = '||l_k_sts_code);
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_tcnv_rec.id = '||px_tcnv_rec.id);
                 END IF;
 	         -- Check if this contract was evergreen earlier, so no need to set to evergreen again
 	         l_evergreen_earlier := check_k_evergreen_ear(
 	                                     p_khr_id          => p_term_rec.p_contract_id,
 	                                     p_tcn_id          => px_tcnv_rec.id,
 	                                     x_return_status   => l_return_status);
 	         IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_evergreen_earlier = '||l_evergreen_earlier);
                 END IF;
 	             IF  (l_evergreen_earlier <> 'Y'
 	 --              AND p_term_rec.p_control_flag LIKE 'BATCH_PROCESS%'
 	                     AND TRUNC(l_k_end_date) <= TRUNC(p_sys_date)
 	                     AND (p_term_rec.p_quote_id IS NULL
 	                      OR p_term_rec.p_quote_id = OKL_API.G_MISS_NUM))THEN

 	            OKL_API.set_message(
 	                         p_app_name      => G_APP_NAME,
 	                         p_msg_name      => 'OKL_AM_STEP_EVR');

 	            -- get evergreen eligiblility
 	            evergreen_eligibility(
 	               p_term_rec                       => p_term_rec,
 	               x_return_status                  => l_return_status,
 	               x_rule_found                     => l_rule_found,
 	               x_msg_count                      => x_msg_count,
 	               x_msg_data                       => x_msg_data);
 	            IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_return_status of evergreen_eligibility = '||l_return_status);
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_rule_found = '||l_rule_found);
                   END IF;
 	            -- Raise exception to rollback to the savepoint
 	            IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

 	              -- Error getting evergreen rule for contract.
 	              OKL_API.set_message(
 	                                 p_app_name     => G_APP_NAME,
 	                                 p_msg_name     => 'OKL_AM_EVERGREEN_RULE_ERR');
 	              RAISE OKL_API.G_EXCEPTION_ERROR;
 	            END IF;
 	         END IF;

 	         -- if control_flag = "batch process" and evergreen_status = "ok" then
 	            -- update contract_status to evergreen
 	            -- exit (raise exception)
 	         -- end if
 	         IF  (l_rule_found = G_YES) THEN
 	               l_try_name := 'Evergreen';
 	               l_trans_code := 'EVERGREEN';
 	               l_tcn_type := 'EVG';
 	         ELSE
 	               l_try_name := 'Termination';
 	               l_trans_code := 'TERMINATION';
 	               l_tcn_type := 'TMT';
 	         END IF;
--akrangan bug 5354501 fix end
      -- Get the Transaction Id
       IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_AM_UTIL_PVT.get_transaction_id ');
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_try_name = '||l_try_name);
      END IF;
      OKL_AM_UTIL_PVT.get_transaction_id (
       p_try_name           => l_try_name , --akrangan bug 5354501 fix added l_try_name
       x_return_status       => l_return_status,
       x_try_id             => l_try_id);
      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_AM_UTIL_PVT.get_transaction_id l_return_status = '||l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_trans_code = '||l_trans_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_try_id = '||l_try_id);
      END IF;
      -- Get the meaning of lookup
      l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                               p_lookup_type  => 'OKL_ACCOUNTING_EVENT_TYPE',
                               p_lookup_code => l_trans_code, --akrangan bug 5354501 fix added l_trans_code
                               p_validate_yn  => 'Y');
      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_trans_meaning = '||l_trans_meaning);
      END IF;
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

        -- Message: Unable to find a transaction type for the transaction TRY_NAME
        OKL_API.set_message(p_app_name            => G_APP_NAME,
                            p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                            p_token1              => 'TRY_NAME',
                            p_token1_value        => l_trans_meaning);

        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get the contract currency code
      l_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(p_term_rec.p_contract_id);
      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_currency_code = '||l_currency_code);
      END IF;
      -- initialize the transaction rec
      px_tcnv_rec.khr_id                     := p_term_rec.p_contract_id;
      px_tcnv_rec.tcn_type                   := l_tcn_type; --akrangan bug 5354501 fix added l_tcn_type
      px_tcnv_rec.try_id                     := l_try_id;
      px_tcnv_rec.currency_code              := l_currency_code;
--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
      px_tcnv_rec.legal_entity_id            := l_legal_entity_id;
    END IF;


    -- RMUNJULU 05-MAR-03 Get the tmt_recycle_yn flag if set and put in GLOBAL variable
    IF px_tcnv_rec.tmt_recycle_yn IS NULL
    OR px_tcnv_rec.tmt_recycle_yn = OKL_API.G_MISS_CHAR THEN
      G_TMT_RECYCLE_YN := NULL;
    ELSE
      G_TMT_RECYCLE_YN := px_tcnv_rec.tmt_recycle_yn;
    END IF;
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_quote_id = '||p_term_rec.p_quote_id);
    END IF;
    -- Set the rest of the transaction rec
    px_tcnv_rec.qte_id                     := p_term_rec.p_quote_id;
    px_tcnv_rec.tsu_code                   := 'ENTERED';
    px_tcnv_rec.tmt_status_code            := 'ENTERED'; --akrangan changes for sla tmt_status_code cr
    px_tcnv_rec.date_transaction_occurred  := p_sys_date;
--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
    px_tcnv_rec.legal_entity_id            := l_legal_entity_id;

    -- set the termination reason (TRN_CODE)
    IF (p_term_rec.p_termination_reason <> OKL_API.G_MISS_CHAR)
    AND (p_term_rec.p_termination_reason IS NOT NULL) THEN
      px_tcnv_rec.trn_code                := p_term_rec.p_termination_reason;
    ELSE
      px_tcnv_rec.trn_code                := 'EXP';
    END IF;

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

       x_return_status   :=   OKL_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

       OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);
       x_return_status   :=   OKL_API.G_RET_STS_UNEXP_ERROR;
  END initialize_transaction;


  -- Start of comments
  --
  -- Procedure Name : get_contract_lines
  -- Description : Gets the financial lines for the contract
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 20-FEB-03 2757368 Changed k_lines_csr cursor to get only
  --                  active lines
  --
  -- End of comments
  PROCEDURE get_contract_lines(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           x_klev_tbl                    OUT NOCOPY klev_tbl_type)  IS

    -- Cursor to get the lines for the contracts -- Get only financial lines
    -- RMUNJULU 20-FEB-03 2757368 Changed cursor to get only active lines
    CURSOR  k_lines_csr(p_khr_id IN NUMBER) IS
    SELECT  OKLV.id             kle_id,
            OKLV.name           asset_name
    FROM    OKC_K_LINES_V       OKLV,
            OKC_LINE_STYLES_V   OLSV,
            OKC_K_HEADERS_V     KHR
    WHERE   OKLV.chr_id   = p_khr_id
    AND     OKLV.lse_id   = OLSV.id
    AND     OLSV.lty_code = 'FREE_FORM1'
    AND     OKLV.chr_id = KHR.id
    AND     OKLV.sts_code = KHR.sts_code;


    k_lines_rec          k_lines_csr%ROWTYPE;
    lx_klev_tbl          klev_tbl_type;
    i                    NUMBER := 1;
    l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name           VARCHAR2(30) := 'get_contract_lines';

    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_contract_lines';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
    END IF;
    i := 1;
    -- get the contract lines
    FOR k_lines_rec IN k_lines_csr ( p_term_rec.p_contract_id) LOOP
       lx_klev_tbl(i).p_kle_id     := k_lines_rec.kle_id;
       lx_klev_tbl(i).p_asset_name := k_lines_rec.asset_name;
       i := i + 1;
    END LOOP;

    x_return_status      := l_return_status;
    x_klev_tbl           := lx_klev_tbl;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
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
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
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
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
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
  END get_contract_lines;


  -- Start of comments
  --
  -- Procedure Name : set_overall_status
  -- Description : Sets the overall status for the api
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE set_overall_status(
           p_return_status               IN VARCHAR2,
           px_overall_status             IN OUT NOCOPY VARCHAR2)  IS
  -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_overall_status';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- Store the highest degree of error
    -- Set p_overall_status only if p_overall_status was successful and
    -- p_return_status is not null
    IF px_overall_status = OKL_API.G_RET_STS_SUCCESS
    AND (p_return_status IS NOT NULL
         OR p_return_status <> OKL_API.G_MISS_CHAR) THEN
        px_overall_status := p_return_status;
    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END set_overall_status;


  -- Start of comments
  --
  -- Procedure Name : set_database_values
  -- Description : Sets the database values
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
  --
  -- End of comments
  PROCEDURE set_database_values(
           px_term_rec             IN OUT NOCOPY term_rec_type)  IS

    -- Cursor to get the quote details
    CURSOR get_quote_details_csr ( p_quote_id IN NUMBER ) IS
      SELECT qtp_code,
             qrs_code
      FROM   OKL_TRX_QUOTES_V
      WHERE  id = p_quote_id;

    -- Cursor to get the k details
    -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
    CURSOR get_k_details_csr (p_khr_id IN NUMBER) IS
      SELECT contract_number
      FROM   OKC_K_HEADERS_V
      WHERE  id = p_khr_id;
  -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_database_values';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_term_rec.p_contract_id = '||px_term_rec.p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_term_rec.p_quote_id = '||px_term_rec.p_quote_id);
    END IF;
    FOR get_k_details_rec IN get_k_details_csr(px_term_rec.p_contract_id) LOOP

       px_term_rec.p_contract_number   :=  get_k_details_rec.contract_number;

    END LOOP;

    -- If the termination request is from quote, populate the rest of the quote attributes
    IF  px_term_rec.p_quote_id IS NOT NULL
    AND px_term_rec.p_quote_id <> OKL_API.G_MISS_NUM THEN

       FOR get_quote_details_rec IN get_quote_details_csr(px_term_rec.p_quote_id) LOOP

         px_term_rec.p_quote_type    :=   get_quote_details_rec.qtp_code;
         px_term_rec.p_quote_reason  :=   get_quote_details_rec.qrs_code;

       END LOOP;

    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END set_database_values;


  -- Start of comments
  --
  -- Procedure Name : set_info_messages
  -- Description   : Sets the info messages when lease termination invoked
  -- Business Rules :
  -- Parameters    :
  -- Version      : 1.0
  --
  -- End of comments
  PROCEDURE set_info_messages(
           p_term_rec             IN term_rec_type)  IS

    l_quote_type VARCHAR2(2000);
  -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_info_messages';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_control_flag = '||p_term_rec.p_control_flag);
    END IF;
    -- Check and Set the message saying where the termination request came from
    IF (p_term_rec.p_control_flag = 'CONTRACT_TERMINATE_SCRN') THEN
      -- Message: Termination request from Request Contract Termination screen
      -- for contract CONTRACT_NUMBER.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_TERM_REQ_FRM_SCRN',
                           p_token1        => 'CONTRACT_NUMBER',
                           p_token1_value  => p_term_rec.p_contract_number);

      -- Set the additional message to let the user know if there was a quote
      IF  p_term_rec.p_quote_id IS NOT NULL
      AND p_term_rec.p_quote_id <> OKL_API.G_MISS_NUM THEN

        -- Get the lookup meaning for quote type
        l_quote_type := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      p_lookup_type  => 'OKL_QUOTE_TYPE',
                                      p_lookup_code  => p_term_rec.p_quote_type,
                                      p_validate_yn  => G_YES);

        --Message:Termination request from accepted QUOTE_TYPE
        -- for contract CONTRACT_NUMBER.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_TERM_REQ_FRM_QTE',
                             p_token1        => 'QUOTE_TYPE',
                             p_token1_value  => l_quote_type,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);
      END IF;

    ELSIF (p_term_rec.p_control_flag = 'TRMNT_QUOTE_UPDATE') THEN

      -- Get the lookup meaning for quote type
      l_quote_type := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      p_lookup_type  => 'OKL_QUOTE_TYPE',
                                      p_lookup_code  => p_term_rec.p_quote_type,
                                      p_validate_yn  => G_YES);

      --Message:Termination request from accepted QUOTE_TYPE
      -- for contract CONTRACT_NUMBER.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_TERM_REQ_FRM_QTE',
                           p_token1        => 'QUOTE_TYPE',
                           p_token1_value  => l_quote_type,
                           p_token2        => 'CONTRACT_NUMBER',
                           p_token2_value  => p_term_rec.p_contract_number);

    ELSIF (p_term_rec.p_control_flag = 'BATCH_PROCESS') THEN
      -- Message : Auto termination request for contract CONTRACT_NUMBER.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_AUTO_TERM_REQ',
                           p_token1        => 'CONTRACT_NUMBER',
                           p_token1_value  => p_term_rec.p_contract_number);
    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION

     WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

        OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END set_info_messages;

  -- Start of comments
  --
  -- Procedure Name : set_transaction_rec
  -- Description : Sets the transaction record for the contract
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : rmunjulu BUYOUT_PROCESS
  --
  -- End of comments
  PROCEDURE set_transaction_rec(
           p_return_status              IN VARCHAR2,
           p_overall_status             IN VARCHAR2,
           p_tmt_flag                   IN VARCHAR2,
           p_tsu_code                   IN VARCHAR2,
           p_ret_val                    IN VARCHAR2,
           px_tcnv_rec                  IN OUT NOCOPY tcnv_rec_type)  IS
    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'set_transaction_rec';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- set the transaction record
    IF (p_overall_status = OKL_API.G_RET_STS_SUCCESS) THEN
      px_tcnv_rec.tmt_status_code := p_tsu_code; --akrangan changes for sla tmt_status_code cr
    ELSE
      px_tcnv_rec.tmt_status_code := 'ERROR'; --akrangan changes for sla tmt_status_code cr
    END IF;

    IF (p_ret_val = OKL_API.G_MISS_CHAR) THEN -- No value for p_ret_val
      IF (p_return_status = OKL_API.G_RET_STS_SUCCESS) THEN -- ret stat success
        IF   (p_tmt_flag = 'TMT_EVERGREEN_YN') THEN
          px_tcnv_rec.TMT_EVERGREEN_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_CLOSE_BALANCES_YN') THEN
          px_tcnv_rec.TMT_CLOSE_BALANCES_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_ACCOUNTING_ENTRIES_YN') THEN
          px_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_CANCEL_INSURANCE_YN') THEN
          px_tcnv_rec.TMT_CANCEL_INSURANCE_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_ASSET_DISPOSITION_YN') THEN
          px_tcnv_rec.TMT_ASSET_DISPOSITION_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_AMORTIZATION_YN') THEN
          px_tcnv_rec.TMT_AMORTIZATION_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_ASSET_RETURN_YN') THEN
          px_tcnv_rec.TMT_ASSET_RETURN_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_CONTRACT_UPDATED_YN') THEN
          px_tcnv_rec.TMT_CONTRACT_UPDATED_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_STREAMS_UPDATED_YN') THEN
          px_tcnv_rec.TMT_STREAMS_UPDATED_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_VALIDATED_YN') THEN
          px_tcnv_rec.TMT_VALIDATED_YN := G_YES;
        --END IF;

        -- RMUNJULU BUYOUT_PROCESS Added
        ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG1_YN') THEN
          px_tcnv_rec.TMT_GENERIC_FLAG1_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG2_YN') THEN
          px_tcnv_rec.TMT_GENERIC_FLAG2_YN := G_YES;
        ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG3_YN') THEN
          px_tcnv_rec.TMT_GENERIC_FLAG3_YN := G_YES;
        END IF;
      ELSE -- return_status not success
        IF   (p_tmt_flag = 'TMT_EVERGREEN_YN') THEN
          px_tcnv_rec.TMT_EVERGREEN_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_CLOSE_BALANCES_YN') THEN
          px_tcnv_rec.TMT_CLOSE_BALANCES_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_ACCOUNTING_ENTRIES_YN') THEN
          px_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_CANCEL_INSURANCE_YN') THEN
          px_tcnv_rec.TMT_CANCEL_INSURANCE_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_ASSET_DISPOSITION_YN') THEN
          px_tcnv_rec.TMT_ASSET_DISPOSITION_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_AMORTIZATION_YN') THEN
          px_tcnv_rec.TMT_AMORTIZATION_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_ASSET_RETURN_YN') THEN
          px_tcnv_rec.TMT_ASSET_RETURN_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_CONTRACT_UPDATED_YN') THEN
          px_tcnv_rec.TMT_CONTRACT_UPDATED_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_STREAMS_UPDATED_YN') THEN
          px_tcnv_rec.TMT_STREAMS_UPDATED_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_VALIDATED_YN') THEN
          px_tcnv_rec.TMT_VALIDATED_YN := G_NO;
        --END IF;

        -- RMUNJULU BUYOUT_PROCESS Added
        ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG1_YN') THEN
          px_tcnv_rec.TMT_GENERIC_FLAG1_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG2_YN') THEN
          px_tcnv_rec.TMT_GENERIC_FLAG2_YN := G_NO;
        ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG3_YN') THEN
          px_tcnv_rec.TMT_GENERIC_FLAG3_YN := G_NO;
        END IF;

      END IF;
    ELSE -- value for p_ret_val passed ( will override return_status val)
      IF   (p_tmt_flag = 'TMT_EVERGREEN_YN') THEN
        px_tcnv_rec.TMT_EVERGREEN_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_CLOSE_BALANCES_YN') THEN
        px_tcnv_rec.TMT_CLOSE_BALANCES_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_ACCOUNTING_ENTRIES_YN') THEN
        px_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_CANCEL_INSURANCE_YN') THEN
        px_tcnv_rec.TMT_CANCEL_INSURANCE_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_ASSET_DISPOSITION_YN') THEN
        px_tcnv_rec.TMT_ASSET_DISPOSITION_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_AMORTIZATION_YN') THEN
        px_tcnv_rec.TMT_AMORTIZATION_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_ASSET_RETURN_YN') THEN
        px_tcnv_rec.TMT_ASSET_RETURN_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_CONTRACT_UPDATED_YN') THEN
        px_tcnv_rec.TMT_CONTRACT_UPDATED_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_STREAMS_UPDATED_YN') THEN
        px_tcnv_rec.TMT_STREAMS_UPDATED_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_VALIDATED_YN') THEN
        px_tcnv_rec.TMT_VALIDATED_YN := p_ret_val;
      --END IF;

      -- RMUNJULU BUYOUT_PROCESS Added
      ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG1_YN') THEN
        px_tcnv_rec.TMT_GENERIC_FLAG1_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG2_YN') THEN
        px_tcnv_rec.TMT_GENERIC_FLAG2_YN := p_ret_val;
      ELSIF(p_tmt_flag = 'TMT_GENERIC_FLAG3_YN') THEN
        px_tcnv_rec.TMT_GENERIC_FLAG3_YN := p_ret_val;
      END IF;

    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     OKL_API.set_message(p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);
  END set_transaction_rec;

  -- Start of comments
  --
  -- Procedure Name : validate_lease
  -- Description : Validates the lease (Contract) -- Add additional validations
  --                  if needed, most of the validations covered in validate_contract
  --                  of OKL_AM_LEASE_LOAN_TRMNT_PVT api
  --                : RMUNJULU 3061751 SERVICE K INTEGRATION CODE
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RNUMJULU 3485854 Changed condition to NOT check for recycle but for Non quote
  --                : RMUNJULU LOANS_ENNHANCEMENTS Check for accruals using new api
  --                : SECHAWLA 23-JAN-06 4970009 : variable rate processing fixes
  --
  -- End of comments
  PROCEDURE validate_lease(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_sys_date                    IN  DATE,
           p_term_rec                    IN  term_rec_type)  IS

   l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name               VARCHAR2(30) := 'validate_lease';

    -- RMUNJULU 3061751 Added variables for SERVICE_K_INTEGRATION
    l_recycle_yn VARCHAR2(1) := 'N';
    l_billing_done VARCHAR2(1);

    -- Get the nonprocessed termination transaction for the contract
    CURSOR get_trn_csr (p_khr_id IN NUMBER) IS
    SELECT TRN.tmt_recycle_yn
    FROM   OKL_TRX_CONTRACTS TRN
    WHERE  TRN.khr_id = p_khr_id
    AND    TRN.tmt_status_code  NOT IN ('PROCESSED', 'CANCELED') --akrangan changes for sla tmt_status_code cr
    AND    TRN.tcn_type in ( 'TMT','EVG') --akrangan bug 5354501 fix added 'EVG'
    AND    TRN.representation_type = 'PRIMARY'; --rkuttiya added for 12.1.1
    -- Multi GAAP project


    -- rmunjulu LOANS_ENNHANCEMENTS
    l_accrual_done VARCHAR2(3);
    l_int_calc_done VARCHAR2(3);

    /* 20-JAN-06 SECHAWLA 4970009 : not required
    -- gboomina Bug 4755490 - Added - Start
    -- Get the last interim interest date to check whether
    -- Variable Rate processing concurrent program run previously or not
    CURSOR get_last_intrm_intrst_dt_csr (p_khr_id IN NUMBER) IS
    SELECT date_last_interim_interest_cal
    FROM okl_k_headers
    WHERE id = p_khr_id;

    -- Cursor to get Interest Calculation Method of a Contract
    CURSOR get_interest_calc_method_csr(p_khr_id IN NUMBER) IS
    SELECT  QVE.VALUE value
    FROM    OKL_PDT_QUALITYS PQY,
         OKL_PDT_PQY_VALS PQV,
         OKL_PQY_VALUES QVE
    WHERE   PQV.PDT_ID IN (SELECT pdt_id FROM OKL_K_HEADERS WHERE id = p_khr_id)
    AND     PQV.QVE_ID = QVE.ID
    AND     QVE.PQY_ID = PQY.ID
    AND     PQY.NAME ='INTEREST_CALCULATION_BASIS';

    l_interest_calc_method OKL_PQY_VALUES.VALUE%TYPE;
    l_last_intrm_intrst_dt DATE;
    -- gboomina Bug 4755490 - Added - End
*/-- 20-JAN-06 SECHAWLA 4970009 : not required

-- 20-JAN-06 SECHAWLA 4970009 : added
    CURSOR l_okcheaders_b(cp_khr_id IN NUMBER) IS
 SELECT end_date
 FROM   okc_k_headers_b
 WHERE  id = cp_khr_id;

 l_end_date DATE;
 -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_lease';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- RMUNJULU 3018641 Step Message
    -- Step : Validate Contract
    OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_VAL');

    -- ADD ADDITIONAL VALIDATIONS HERE

    -- ++++++++++++++++++++  service contract integration begin ++++++++++++

    -- RMUNJULU 3061751 19-SEP-2003
    IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_control_flag = '||p_term_rec.p_control_flag);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_quote_id = '||p_term_rec.p_quote_id);
    END IF;
    -- Get the TRN details
    FOR get_trn_rec IN get_trn_csr(p_term_rec.p_contract_id) LOOP

        l_recycle_yn := NVL(get_trn_rec.tmt_recycle_yn,'N');

    END LOOP;

    -- If concurrent request and not from quote
--  -- RMUNJULU 3485854 Changed condition to check for request not from quote
    IF p_term_rec.p_control_flag LIKE 'BATCH%'
--    AND l_recycle_yn = 'N' THEN
    AND (p_term_rec.p_quote_id IS NULL OR p_term_rec.p_quote_id = OKL_API.G_MISS_NUM) THEN

-- 20-JAN-06 SECHAWLA 4970009 : not required since OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done has
    -- been modified to check for lease contracts ('FLOAT_FACTORS','REAMORT')
/* -- gboomina Bug 4755490 - Start
        FOR get_interest_calc_method_rec IN get_interest_calc_method_csr(p_term_rec.p_contract_id) LOOP
          l_interest_calc_method := get_interest_calc_method_rec.value;
        END LOOP;
        -- Only check for a Float Factor contract, Float Factor Adjustment streams exist
        IF l_interest_calc_method IN ('FLOAT_FACTORS','REAMORT') THEN -- SECHAWLA 09-JAN-05 4920618 : added REAMORT
          FOR get_last_intrm_intrst_dt_rec IN get_last_intrm_intrst_dt_csr(p_term_rec.p_contract_id) LOOP
            l_last_intrm_intrst_dt := get_last_intrm_intrst_dt_rec.date_last_interim_interest_cal;
          END LOOP;
          -- Check whether Float Factor Streams exist or not
          IF l_last_intrm_intrst_dt IS NULL THEN
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_VAR_RATE_NOT_COMPLETED',
                                 p_token1        => 'CONTRACT_NUMBER',
                                 p_token1_value  => p_term_rec.p_contract_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        -- gboomina Bug 4755490 - End
*/ -- 20-JAN-06 SECHAWLA 4970009 : not required  since OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done has
    -- been modified to check for lease contracts ('FLOAT_FACTORS','REAMORT')

        -- 23-JAN-06 SECHAWLA 4970009 : begin
        OPEN  l_okcheaders_b(p_term_rec.p_contract_id);
  FETCH l_okcheaders_b INTO l_end_date;
  CLOSE l_okcheaders_b;
        -- 23-JAN-06 SECHAWLA 4970009 : end

        -- 20-JAN-06 SECHAWLA 4970009 : added begin
        IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done');
        END IF;
        l_int_calc_done :=  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done(
                                   p_contract_id      => p_term_rec.p_contract_id,
                                   p_contract_number  => p_term_rec.p_contract_number,
                                  -- p_quote_number     => db_quote_number,
                                   p_source           =>  'TERMINATE',
                                   --p_trn_date         => p_sys_date); -- 23-JAN-06 SECHAWLA 4970009
                                   p_trn_date         => l_end_date); -- 23-JAN-06 SECHAWLA 4970009

        IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_int_calc_done = '||l_int_calc_done);
        END IF;

        IF l_int_calc_done IS NULL OR l_int_calc_done = 'N' THEN

            -- Message will be set in called procedure
            l_return_status :=  OKL_API.G_RET_STS_ERROR;
        END IF;
        -- 20-JAN-06 SECHAWLA 4970009 : added end
        IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_billing_done');
        END IF;
        -- BPD Now provides a API which tells till when the billing was done, use that
        l_billing_done :=  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_billing_done(
                                   p_contract_id      => p_term_rec.p_contract_id,
                                   p_contract_number  => p_term_rec.p_contract_number,
                                   p_trn_date         => p_sys_date );
        IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_billing_done = '||l_billing_done);
        END IF;

        IF l_billing_done IS NULL OR l_billing_done = 'N' THEN

            -- Message will be set in called procedure
            l_return_status :=  OKL_API.G_RET_STS_ERROR;
        END IF;
        IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling  OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till');
        END IF;
        -- rmunjulu LOANS_ENHANCEMENTS -- Check for accrual using new API
        l_accrual_done := OKL_GENERATE_ACCRUALS_PVT.check_date_accrued_till(
                                     p_khr_id => p_term_rec.p_contract_id,
                                     p_date   => p_sys_date);
        IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_accrual_done = '||l_accrual_done);
        END IF;

        -- if accrual not done then error
        IF (nvl(l_accrual_done,'N') = 'N' ) THEN

           -- Contract CONTRACT_NUMBER can not be terminated.
     -- Please run accruals for the contract till the termination date TERMINATION_DATE.
           OKL_API.set_message (
                   p_app_name     => OKL_API.G_APP_NAME,
                    p_msg_name     => 'OKL_AM_TERMNT_ACC_CHK',
                           p_token1       => 'CONTRACT_NUMBER',
                           p_token1_value => p_term_rec.p_contract_number,
                           p_token2       => 'TERMINATION_DATE',
                           p_token2_value => p_sys_date);

           RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;
    END IF;

    -- ++++++++++++++++++++  service contract integration end   ++++++++++++

    x_return_status   :=  l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

      -- 24-JAN-06 SECHAWLA 4970009 : close the open cursors
      IF l_okcheaders_b%ISOPEN THEN
         CLOSE l_okcheaders_b;
      END IF;

      IF get_trn_csr%ISOPEN THEN
         CLOSE get_trn_csr;
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
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

    -- 24-JAN-06 SECHAWLA 4970009 : close the open cursors
      IF l_okcheaders_b%ISOPEN THEN
         CLOSE l_okcheaders_b;
      END IF;

      IF get_trn_csr%ISOPEN THEN
         CLOSE get_trn_csr;
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
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     -- 24-JAN-06 SECHAWLA 4970009 : close the open cursors
      IF l_okcheaders_b%ISOPEN THEN
         CLOSE l_okcheaders_b;
      END IF;

      IF get_trn_csr%ISOPEN THEN
         CLOSE get_trn_csr;
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
   END validate_lease;

   --Start of comments
   --
   -- Procedure Name  : update_quote_status
   -- Desciption     : UPDATE TERMINATION QUOTES FROM STATUS ACCEPTED TO
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RBRUNO BUG 6801022
   --
   -- End of comments

PROCEDURE update_quote_status(p_term_rec IN term_rec_type) IS

    lp_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;
    lx_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;

    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_quote_status              VARCHAR2(200) := 'COMPLETE';--'OKL_QUOTE_STATUS'

    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(2000);

    l_qst_code                  varchar2(200);

    l_tmt_status_code           VARCHAR2(200);

    lx_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lx_quotes_found              VARCHAR2(1) := 'N';
    l_api_version               NUMBER := 1;
      l_module_name VARCHAR2(500) := G_MODULE_NAME || 'UPDATE_QUOTE_STATUS';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_STATEMENT);
    --:= okl_debug_pub.check_log_on (l_module_name, g_level_exception);


    -- Fetch tmt_status_code

         CURSOR c_tmt_status_code_csr (p_qte_id IN NUMBER) IS
         SELECT tmt_status_code
          FROM okl_trx_contracts trx
          WHERE trx.qte_id = p_qte_id
         --rkuttiya added for 12.1.1 Multi GAAP
          AND trx.representation_type = 'PRIMARY';

    --- Fetch quote satus

         CURSOR k_quotes_csr (p_qte_id IN NUMBER) IS
         SELECT qst_code
          FROM okl_trx_quotes_v
          WHERE id = p_qte_id
          AND (qtp_code LIKE 'TER%' OR qtp_code LIKE 'RES%');

BEGIN

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
  END IF;

--Get termination quote status

OPEN k_quotes_csr(p_term_rec.p_quote_id);
FETCH k_quotes_csr into l_qst_code;
CLOSE k_quotes_csr;

     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_qst_code =
'||l_qst_code);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_quote_id
= '||p_term_rec.p_quote_id);
     END IF;

IF p_term_rec.p_quote_id is not null and l_qst_code = 'ACCEPTED' THEN

 IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Quote in
status accepted exists');
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'p_term_rec.p_quote_id
= '||p_term_rec.p_quote_id);
  END IF;

      OPEN  c_tmt_status_code_csr(p_term_rec.p_quote_id);
      FETCH c_tmt_status_code_csr INTO l_tmt_status_code;
      CLOSE c_tmt_status_code_csr;

      IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_tmt_status_code
= '||l_tmt_status_code);
      END IF;

      IF l_tmt_status_code = 'ERROR' THEN
          lp_qtev_rec.id        :=     p_term_rec.p_quote_id;
          lp_qtev_rec.qst_code   :=    l_quote_status;

   IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lp_qtev_rec.id
= '||lp_qtev_rec.id);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lp_qtev_rec.qst_code
= '||lp_qtev_rec.qst_code );
      END IF;

      -- Call the update of the quote header api
      OKL_TRX_QUOTES_PUB.update_trx_quotes (
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKL_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => lx_msg_count,
           x_msg_data                     => lx_msg_data,
           p_qtev_rec                     => lp_qtev_rec,
           x_qtev_rec                     => lx_qtev_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN


       IF (is_debug_statement_on)
      THEN
       okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'failure while updating the quote status
');

       END IF;

      END IF;

    END IF;

  END IF;

END update_quote_status;

  -- Start of comments
  --
  -- Procedure Name : update_k_hdr_and_lines
  -- Description : set the termination record and call the tapis
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 18-FEB-03 2804703 changed to NOT set date_term
  --                  if setting to EVERGREEN
  --                : RMUNJULU 20-FEB-03 2757368 Changed k_lines_csr cursor to get
  --                  non TERMINATED/EXPIRED lines
  --                : RMUNJULU Bug # 3023206 27-JUN-03 Added call to
  --                  process_close_streams when TERMINATED/EXPIRED NOT when EVERGREEN
  --                : rmunjulu EDAT added code to set date_terminated as quote accpt date
  --
  -- End of comments
  PROCEDURE update_k_hdr_and_lines(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_status                      IN  VARCHAR2,
           p_term_rec                    IN term_rec_type,
           p_klev_tbl                    IN klev_tbl_type,
           p_trn_reason_code             IN VARCHAR2,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_chrv_rec                    OUT NOCOPY chrv_rec_type,
           x_clev_tbl                    OUT NOCOPY clev_tbl_type,
           p_sys_date                    IN DATE) IS

   -- Cursor to get the ste code
   CURSOR  get_old_ste_code_csr(p_sts_code VARCHAR2) IS
     SELECT STE_CODE
    FROM   OKC_STATUSES_V
    WHERE  CODE = p_sts_code;

   -- Cursor to get contract details
   CURSOR  k_header_csr IS
   SELECT  id,
           object_version_number,
         sts_code,
         authoring_org_id  --CDUBEY authoring_org_id added for MOAC
    FROM   OKC_K_HEADERS_B
    WHERE  id = p_term_rec.p_contract_id;

   -- Cursor to get all lines for the contract
   -- Cannot use the klev_tbl as these are financial lines only
   -- RMUNJULU 20-FEB-03 2757368 Changed code to get only active lines
   CURSOR  k_lines_csr (p_khr_id IN NUMBER) IS
   SELECT  KLE.id             kle_id,
           KLE.line_number    line_number
   FROM    OKC_K_LINES_B       KLE,
           OKC_K_HEADERS_B     KHR
   WHERE   KLE.dnz_chr_id   = p_khr_id
   AND     KLE.sts_code     = KHR.sts_code
   AND     KLE.dnz_chr_id   = KHR.id;

   -- Cursor to get the meaning of the sts_code passed
   CURSOR  k_sts_code_meaning_csr( p_sts_code IN VARCHAR2) IS
   SELECT  meaning
   FROM    OKC_STATUSES_V
   WHERE   code = p_sts_code;


   rec_k_header         k_header_csr%ROWTYPE;
   k_lines_rec          k_lines_csr%ROWTYPE;
   l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   --l_status_code        VARCHAR2(30);
   i                    NUMBER;
   l_scs_code           OKC_SUBCLASSES_V.code%TYPE;
   l_ste_code           OKC_STATUSES_V.CODE%TYPE;
   lp_chrv_rec          chrv_rec_type;
   lx_chrv_rec          chrv_rec_type;
   lp_clev_tbl          clev_tbl_type;
   lx_clev_tbl          clev_tbl_type;
   l_asset_name         VARCHAR2(200);
   l_sts_meaning        VARCHAR2(200);
   l_api_name           VARCHAR2(30) := 'update_k_hdr_and_lines';

   lx_stmv_tbl   stmv_tbl_type;

   -- rmunjulu EDAT
   l_quote_accpt_date DATE;
   l_quote_eff_date DATE;
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_k_hdr_and_lines';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- Initialize savepoint to rollback to if error in this block
    SAVEPOINT update_k_hdr_lines;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
    END IF;
    OPEN  k_header_csr;
    FETCH k_header_csr INTO rec_k_header;
    CLOSE k_header_csr;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'rec_k_header.sts_code = '||rec_k_header.sts_code);
    END IF;
    OPEN  get_old_ste_code_csr(rec_k_header.sts_code);
    FETCH get_old_ste_code_csr INTO l_ste_code;
    CLOSE get_old_ste_code_csr;

    OPEN  k_sts_code_meaning_csr(p_status);
    FETCH k_sts_code_meaning_csr INTO l_sts_meaning;
    CLOSE k_sts_code_meaning_csr;

    -- RMUNJULU 3018641 Step Message
    -- Step : Update Contract
    OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_UPD');




 -- RBRUNO BUG 6801022  START : UPDATE TERMINATION QUOTES FROM STATUS ACCEPTED

      IF (is_debug_statement_on)     THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'Invoking updating quote status');
                                  end if;

      --IF TERM QUOTE IN STATUS ACCEPTED EXISTS, UPDATE IT TO COMPLETE
      update_quote_status(p_term_rec);

      IF (is_debug_statement_on)   THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'post updating quote status');
                                  end if;
      -- RBRUNO BUG 6801022 END : UPDATE TERMINATION QUOTES FROM STATUS ACCEPTED

    -- RMUNJULU Bug # 3023206 Added call to Process_close_streams here
    -- Check if final termination ( DO NOT close streams if EVERGREEN)
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_status = '||p_status);
    END IF;

    IF p_status IN ( 'TERMINATED','EXPIRED') THEN

     IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  process_close_streams');
     END IF;
      process_close_streams(
            p_api_version       => p_api_version,
            p_init_msg_list     => OKL_API.G_FALSE,
            x_return_status      => l_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_term_rec           => p_term_rec,
            px_overall_status    => px_overall_status,
            px_tcnv_rec          => px_tcnv_rec,
            x_stmv_tbl           => lx_stmv_tbl,
            p_sys_date           => p_sys_date,
            p_trn_already_set    => G_NO); -- Always NO since this step was not done earlier
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  process_close_streams l_return_status = '||l_return_status);
      END IF;

      -- Raise exception to rollback to savepoint
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- RMUNJULU 20-FEB-03 2757368 flipped the order to update LINES and then CONTRACT

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

    -- rmunjulu EDAT
    -- If quote exists then cancelation date is quote eff from date else sysdate
    IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

        l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
        l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

    ELSE

        l_quote_accpt_date := p_sys_date;
        l_quote_eff_date := p_sys_date;

    END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

    -- Initialize i
    i := 1;
    -- set the line tbl

    -- RMUNJULU 20-FEB-03 2757368 Changed the cursor to send khr_id as IN param
    FOR k_lines_rec IN k_lines_csr (p_term_rec.p_contract_id) LOOP

       -- RMUNJULU 18-FEB-03 2804703 Added IF to check if being terminated
       IF p_status IN ('TERMINATED','EXPIRED') THEN

          -- Set the date terminated
          lp_clev_tbl(i).date_terminated  :=  l_quote_eff_date; -- rmunjulu EDAT

       END IF;

       -- set the k line tbl values
       lp_clev_tbl(i).id        :=  k_lines_rec.kle_id;
       lp_clev_tbl(i).sts_code  :=  p_status;

       i := i + 1;

    END LOOP;


     IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  OKC_CONTRACT_PUB.update_contract_line');
     END IF;

    -- call the update line tbl
    OKC_CONTRACT_PUB.update_contract_line(
            p_api_version   => p_api_version,
          p_init_msg_list  => OKL_API.G_FALSE,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_clev_tbl       => lp_clev_tbl,
             x_clev_tbl       => lx_clev_tbl);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  OKC_CONTRACT_PUB.update_contract_linel_return_status ='||l_return_status);
     END IF;
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

      -- Error updating assets of contract CONTRACT_NUMBER to status STATUS.
      OKL_API.set_message(
                         p_app_name      => G_APP_NAME,
                         p_msg_name      => 'OKL_AM_K_LINE_STATUS_UPD_ERR',
                         p_token1        => 'CONTRACT_NUMBER',
                         p_token1_value  => p_term_rec.p_contract_number,
                         p_token2        => 'STATUS',
                         p_token2_value  => l_sts_meaning);

    END IF;

    -- Raise exception to rollback to savepoint
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set the "in" record
    -- set the termination date
    -- RMUNJULU 18-FEB-03 2804703 Added IF to check if being terminated
    IF p_status IN ('TERMINATED','EXPIRED') THEN
       IF  (p_term_rec.p_termination_date IS NOT NULL)
       AND (p_term_rec.p_termination_date <> OKL_API.G_MISS_DATE) THEN
          lp_chrv_rec.date_terminated         := p_term_rec.p_termination_date;
       ELSE
          lp_chrv_rec.date_terminated         := l_quote_eff_date; -- rmunjulu EDAT
       END IF;

       lp_chrv_rec.trn_code                  := p_trn_reason_code;

    END IF;
    -- fix for bug 6945800 -start
    IF (p_status  = 'EXPIRED') THEN
             lp_chrv_rec.date_terminated         := null;
    END IF;
    -- fix for bug 6945800 -end
    lp_chrv_rec.id                        := rec_k_header.id;
    lp_chrv_rec.object_version_number     := rec_k_header.object_version_number;
    lp_chrv_rec.sts_code                  := p_status;
    lp_chrv_rec.old_sts_code              := rec_k_header.sts_code;
    lp_chrv_rec.new_sts_code              := p_status;
    lp_chrv_rec.old_ste_code              := l_ste_code;
    lp_chrv_rec.new_ste_code              := p_status;
    lp_chrv_rec.org_id                    := rec_k_header.authoring_org_id; --CDUBEY added for MOAC

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  OKC_CONTRACT_PUB.update_contract_header');
    END IF;
    -- Call the tapi to update contract with termination info
    OKC_CONTRACT_PUB.update_contract_header(
                     p_api_version   => p_api_version,
                        p_init_msg_list   => OKL_API.G_FALSE,
                        x_return_status   => l_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        p_restricted_update  => OKL_API.G_TRUE,
                        p_chrv_rec    => lp_chrv_rec,
                        x_chrv_rec    => lx_chrv_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  OKC_CONTRACT_PUB.update_contract_header l_return_status = '||l_return_status);
    END IF;
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

      -- Error updating contract CONTRACT_NUMBER to status STATUS.
      OKL_API.set_message(
                         p_app_name      => G_APP_NAME,
                         p_msg_name      => 'OKL_AM_K_STATUS_UPD_ERR',
                         p_token1        => 'CONTRACT_NUMBER',
                         p_token1_value  => p_term_rec.p_contract_number,
                         p_token2        => 'STATUS',
                         p_token2_value  => l_sts_meaning);

    END IF;

    -- Raise exception to rollback to savepoint
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- Set the success messages

    -- Contract line statuses updated to STATUS for assets of contract CONTRACT_NUMBER.
    OKL_API.set_message(
                           p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_K_LINE_STATUS_UPD',
                           p_token1        => 'STATUS',
                           p_token1_value  => l_sts_meaning,
                           p_token2        => 'CONTRACT_NUMBER',
                           p_token2_value  => p_term_rec.p_contract_number);


    -- Contract CONTRACT_NUMBER status updated to STATUS.
    OKL_API.set_message( p_app_name      => G_APP_NAME,
                         p_msg_name      => 'OKL_AM_K_STATUS_UPD',
                         p_token1        => 'CONTRACT_NUMBER',
                         p_token1_value  => p_term_rec.p_contract_number,
                         p_token2        => 'STATUS',
                         p_token2_value  => l_sts_meaning);

    -- store the highest degree of error
    set_overall_status(
        p_return_status                 => l_return_status,
        px_overall_status               => px_overall_status);

    -- set the transaction record
    set_transaction_rec(
        p_return_status                 => l_return_status,
        p_overall_status                => px_overall_status,
        p_tmt_flag                      => 'TMT_CONTRACT_UPDATED_YN',
        p_tsu_code                      => 'PROCESSED',
        px_tcnv_rec                     => px_tcnv_rec);

    -- set the out params
    x_return_status   :=   l_return_status;
    x_chrv_rec        :=   lx_chrv_rec;
    x_clev_tbl        :=   lx_clev_tbl;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

      IF get_old_ste_code_csr%ISOPEN THEN
         CLOSE get_old_ste_code_csr;
      END IF;
      IF k_header_csr%ISOPEN THEN
         CLOSE k_header_csr;
      END IF;
      IF k_sts_code_meaning_csr%ISOPEN THEN
         CLOSE k_sts_code_meaning_csr;
      END IF;

      ROLLBACK TO update_k_hdr_lines;

      x_return_status := OKL_API.G_RET_STS_ERROR;

      -- store the highest degree of error
      set_overall_status(
        p_return_status                 => x_return_status,
        px_overall_status               => px_overall_status);

      -- set the transaction record
      set_transaction_rec(
        p_return_status                 => x_return_status,
        p_overall_status                => px_overall_status,
        p_tmt_flag                      => 'TMT_CONTRACT_UPDATED_YN',
        p_tsu_code                      => 'ERROR',
        px_tcnv_rec                     => px_tcnv_rec);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

      IF get_old_ste_code_csr%ISOPEN THEN
         CLOSE get_old_ste_code_csr;
      END IF;
      IF k_header_csr%ISOPEN THEN
         CLOSE k_header_csr;
      END IF;
      IF k_sts_code_meaning_csr%ISOPEN THEN
         CLOSE k_sts_code_meaning_csr;
      END IF;

      ROLLBACK TO update_k_hdr_lines;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      -- store the highest degree of error
      set_overall_status(
        p_return_status                 => x_return_status,
        px_overall_status               => px_overall_status);

      -- set the transaction record
      set_transaction_rec(
        p_return_status                 => x_return_status,
        p_overall_status                => px_overall_status,
        p_tmt_flag                      => 'TMT_CONTRACT_UPDATED_YN',
        p_tsu_code                      => 'ERROR',
        px_tcnv_rec                     => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

      IF get_old_ste_code_csr%ISOPEN THEN
         CLOSE get_old_ste_code_csr;
      END IF;
      IF k_header_csr%ISOPEN THEN
         CLOSE k_header_csr;
      END IF;
      IF k_sts_code_meaning_csr%ISOPEN THEN
         CLOSE k_sts_code_meaning_csr;
      END IF;

      ROLLBACK TO update_k_hdr_lines;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      -- store the highest degree of error
      set_overall_status(
        p_return_status                 => x_return_status,
        px_overall_status               => px_overall_status);

      -- set the transaction record
      set_transaction_rec(
        p_return_status                 => x_return_status,
        p_overall_status                => px_overall_status,
        p_tmt_flag                      => 'TMT_CONTRACT_UPDATED_YN',
        p_tsu_code                      => 'ERROR',
        px_tcnv_rec                     => px_tcnv_rec);

       -- Set the oracle error message
       OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END update_k_hdr_and_lines;

  -- Start of comments
  --
  -- Procedure Name : process_transaction
  -- Description : Calls the Transaction TAPI based on whether in
  --                CREATE or UPDATE mode
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE process_transaction(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_id                          IN NUMBER,
           p_term_rec                    IN term_rec_type,
           p_tcnv_rec                    IN tcnv_rec_type,
           x_id                          OUT NOCOPY NUMBER,
           p_trn_mode                    IN VARCHAR2)  IS

   l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_tcnv_rec          tcnv_rec_type := p_tcnv_rec;
   lx_tcnv_rec          tcnv_rec_type;
   l_api_name           VARCHAR2(30) := 'process_transaction';

   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_transaction';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               p_init_msg_list,
                                               '_PVT',
                                               x_return_status);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Clear the recycle flag after processing
     lp_tcnv_rec.tmt_recycle_yn := NULL;
     IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_trn_mode = '||p_trn_mode);
     END IF;
     IF p_trn_mode = 'INSERT' THEN
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  OKL_TRX_CONTRACTS_PUB.create_trx_contracts');
       END IF;
       -- insert transaction rec
       OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
        p_api_version                => p_api_version,
        p_init_msg_list               => OKL_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_tcnv_rec                      => lp_tcnv_rec,
         x_tcnv_rec                      => lx_tcnv_rec);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  OKL_TRX_CONTRACTS_PUB.insert_trx_contracts l_return_status = '||l_return_status);
       END IF;
     ELSIF p_trn_mode = 'UPDATE' THEN
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  OKL_TRX_CONTRACTS_PUB.update_trx_contracts');
       END IF;

       -- update transaction rec
       OKL_TRX_CONTRACTS_PUB.update_trx_contracts(
        p_api_version                => p_api_version,
        p_init_msg_list               => OKL_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_tcnv_rec                      => lp_tcnv_rec,
         x_tcnv_rec                      => lx_tcnv_rec);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  OKL_TRX_CONTRACTS_PUB.update_trx_contracts l_return_status = '||l_return_status);
       END IF;
     END IF;

     -- rollback if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- set the return values
     x_return_status   :=  l_return_status;
     x_id              :=  lx_tcnv_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
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
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
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
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
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
  END process_transaction;


/*  -- This procedure is commented temporarily
  -- Start of comments
  --
  -- Procedure Name : process_evergreen_deprn
  -- Desciption     : This procedure is used to start depreciation of the assets
  --            under a particular contract, after the contract status changes
  --            to "Evergreen". Evergreen Contracts are Direct Finace/Sales type
  --            of contracts with no hold periods.
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE process_evergreen_deprn(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           p_sys_date                    IN DATE)  IS
   --This cursor will return all the Fixed Asset Lines for a particular contract
   CURSOR l_linesv_csr IS
   SELECT depreciation_category,
          corporate_book,
          salvage_value,
          deprn_method_code,
          life_in_months,
          parent_line_id,
          asset_number,
          item_description,
          asset_id,
          original_cost,
          current_units,
          in_service_date
   FROM   OKX_ASSET_LINES_V
   WHERE  dnz_chr_id = p_term_rec.p_contract_id;

   --This cursor returns the original cost from the original asset creation line
   CURSOR l_txlassetsv_csr(p_asset_number okl_txl_assets_v.asset_number%TYPE) IS
   SELECT original_cost
   FROM   okl_txl_assets_v
   WHERE  tal_type = 'CFA'
   AND    asset_number = p_asset_number
   AND    ROWNUM < 2;

   -- This cursor is used to get the cost,
   -- residual value of an asset from the Financial Asset (TOP LINE)
   CURSOR  l_linesfullv_csr(p_id  NUMBER) IS
   SELECT  oec, residual_value
   FROM    okl_k_lines_full_v
   WHERE   id = p_id;

   -- This cursor will return deal_type for a particular contract
   CURSOR l_lhrfv_csr IS
   SELECT deal_type
   FROM   OKL_K_HEADERS_FULL_V
   WHERE  id = p_term_rec.p_contract_id;

   l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name                   VARCHAR2(30) := 'process_evergreen_deprn';
   lp_thpv_rec                  OKL_TRX_ASSETS_PUB.thpv_rec_type;
   lx_thpv_rec                  OKL_TRX_ASSETS_PUB.thpv_rec_type;
   lp_tlpv_rec               tlpv_rec_type;
   lx_tlpv_rec               tlpv_rec_type;
   l_try_id                     NUMBER;
   l_method_id                  FA_METHODS.method_id%TYPE;
   l_corporate_book             VARCHAR2(70);
   l_df_original_cost           NUMBER;
   l_oec                        NUMBER;
   l_residual_value             NUMBER;
   l_tax_owner                  VARCHAR2(10);
   l_rulv_rec                   okl_rule_pub.rulv_rec_type;
   l_line_status                VARCHAR2(15);
   l_deal_type                  VARCHAR2(15);
   l_api_version                CONSTANT NUMBER := 1;
  BEGIN

    l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
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

    IF (p_term_rec.p_contract_id IS NULL)
    OR (p_term_rec.p_contract_id = OKL_API.G_MISS_NUM) THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         ---- contract id parameter is null
         OKL_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CONTRACT_ID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  l_lhrfv_csr;
    FETCH l_lhrfv_csr INTO l_deal_type;
    IF l_lhrfv_csr%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Contract ID is invalid
         OKL_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CONTRACT_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE l_lhrfv_csr;

    IF l_deal_type IS NULL THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
       --deal type not defined for this contract
        OKL_API.set_message(       p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_DEAL_TYPE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_deal_type='LEASEDF' THEN


         -- get the tax owner (LESSOR/LESSEE) for the asset.
         -- This will help us in future if FA gives us the ability
         -- to adjust tax books directly. Tax books need to be adjusted in a
         -- different manner for different tax owners.
         -- Currently we do not have any control over tax books adjusments

         okl_am_util_pvt.get_rule_record(p_rgd_code         => 'LATOWN'
                                     ,p_rdf_code         =>'LATOWN'
                                     ,p_chr_id           => p_contract_id
                                     ,p_cle_id           => NULL
                                     ,x_rulv_rec         => l_rulv_rec
                                     ,x_return_status    => l_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- l_rulv_rec.RULE_INFORMATION1 will contain the value 'LESSEE' or
          -- 'LESSOR'
             l_tax_owner := l_rulv_rec.RULE_INFORMATION1;
         END IF;

      END IF;



    OKL_AM_UTIL_PVT.get_transaction_id('?',x_return_status,l_try_id);
       IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            OKL_API.set_message(p_app_name    => 'OKL',
                        p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                        p_token1              => 'TRY_NAME',
                        p_token1_value        => '?');
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    -- scenario 8 - Direct Finance Lease expiration with NO hold period
    -- loop thru all the records from okx_asset_lines_v where
    -- contract id matches p_contract_id, validate the data
    -- and then create transaction header and line in okl_trx_assets_v and
    -- okl_txl_assets_v
    FOR l_lines_rec IN l_linesv_csr LOOP
       l_line_status := NULL;
       -- validate data before creating the transaction line.
       IF  l_lines_rec.parent_line_id IS NULL THEN
       --  Parent Line Id not defined for asset
            OKL_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_NO_PARENT_LINE_ID',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  l_lines_rec.asset_number);
            l_line_status := 'ERROR';
        END IF;
        IF  l_lines_rec.life_in_months IS NULL THEN
            -- Life in Months not defined for asset
            OKL_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_NO_LIFE_IN_MONTHS',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  l_lines_rec.asset_number);
             l_line_status := 'ERROR';
        END IF;
        OPEN  l_txlassetsv_csr(l_lines_rec.asset_number);
        FETCH l_txlassetsv_csr INTO l_df_original_cost;
        CLOSE l_txlassetsv_csr;

        OPEN  l_linesfullv_csr(l_lines_rec.parent_line_id);
        FETCH l_linesfullv_csr INTO l_oec, l_residual_value;
        CLOSE l_linesfullv_csr;

        IF l_residual_value IS NULL THEN
            -- Residual Value not defined for the asset
            OKL_API.set_message(p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_NO_RESIDUAL_VALUE',
                                p_token1        =>  'ASSET_NUMBER',
                                p_token1_value  =>  l_lines_rec.asset_number);
            l_line_status := 'ERROR';
        END IF;
        IF l_df_original_cost IS NULL THEN
            IF l_oec IS NULL THEN
               -- OEC not defined for the asset
               OKL_API.set_message(p_app_name     => 'OKL',
                                   p_msg_name     => 'OKL_AM_NO_OEC',
                                   p_token1       =>  'ASSET_NUMBER',
                                   p_token1_value =>  l_lines_rec.asset_number);
               l_line_status := 'ERROR';
            END IF;
        END IF;
       -- end validation

       -- Create Transaction Header
       lp_thpv_rec.tas_type            := 'AED';
       IF l_line_status IS NULL THEN
          lp_thpv_rec.tsu_code            := 'ENTERED';
       ELSE
          lp_thpv_rec.tsu_code            := 'ERROR';
       END IF;
       lp_thpv_rec.try_id                 :=  l_try_id;
       lp_thpv_rec.date_trans_occurred    :=  p_sys_date;

       OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                              p_api_version           => p_api_version,
                        p_init_msg_list         => p_init_msg_list,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
            p_thpv_rec        => lp_thpv_rec,
            x_thpv_rec        => lx_thpv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- Create transaction Line
       lp_tlpv_rec.tas_id        := lx_thpv_rec.id;   -- FK
       lp_tlpv_rec.iay_id        := l_lines_rec.depreciation_category;
       lp_tlpv_rec.kle_id        := l_lines_rec.parent_line_id;
       lp_tlpv_rec.line_number       := 1;
       lp_tlpv_rec.tal_type       := 'AER';
    lp_tlpv_rec.asset_number   := l_lines_rec.asset_number;
       lp_tlpv_rec.description          := l_lines_rec.item_description;
       lp_tlpv_rec.life_in_months       := l_lines_rec.life_in_months;
       lp_tlpv_rec.deprn_method         := l_lines_rec.deprn_method_code;
       lp_tlpv_rec.corporate_book   := l_lines_rec.corporate_book;
       lp_tlpv_rec.depreciation_cost  := l_residual_value;
       lp_tlpv_rec.salvage_value   := l_lines_rec.salvage_value;
    IF l_df_original_cost IS NOT NULL THEN
             lp_tlpv_rec.original_cost  := l_df_original_cost;
       ELSE
             lp_tlpv_rec.original_cost  := l_oec;
       END IF;
    lp_tlpv_rec.current_units   := l_lines_rec.current_units;
    lp_tlpv_rec.depreciate_yn   := G_YES;
    lp_tlpv_rec.dnz_asset_id         := TO_NUMBER(l_lines_rec.asset_id);
       lp_tlpv_rec.dnz_khr_id       := p_term_rec.p_contract_id;

       -- In case of direct finance / Sales type of lease,
       -- in_service_date is defaulted to the transaction date.
       lp_tlpv_rec.in_service_date     := lp_thpv_rec.date_trans_occurred;

       OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                                   p_api_version           => p_api_version,
                             p_init_msg_list         => p_init_msg_list,
                       x_return_status         => x_return_status,
                       x_msg_count             => x_msg_count,
                       x_msg_data              => x_msg_data,
                 p_tlpv_rec         => lp_tlpv_rec,
                 x_tlpv_rec         => lx_tlpv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END LOOP;
    END IF; -- if deal_type='LEASEDF'

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_linesv_csr%ISOPEN THEN
           CLOSE l_linesv_csr;
        END IF;
        IF l_lhrfv_csr%ISOPEN THEN
           CLOSE l_lhrfv_csr;
        END IF;
        IF l_txlassetsv_csr%ISOPEN THEN
           CLOSE l_txlassetsv_csr;
        END IF;
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
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
        IF l_linesv_csr%ISOPEN THEN
           CLOSE l_linesv_csr;
        END IF;
        IF l_lhrfv_csr%ISOPEN THEN
           CLOSE l_lhrfv_csr;
        END IF;
        IF l_txlassetsv_csr%ISOPEN THEN
           CLOSE l_txlassetsv_csr;
        END IF;
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
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
        IF l_linesv_csr%ISOPEN THEN
           CLOSE l_linesv_csr;
        END IF;
        IF l_lhrfv_csr%ISOPEN THEN
           CLOSE l_lhrfv_csr;
        END IF;
        IF l_txlassetsv_csr%ISOPEN THEN
           CLOSE l_txlassetsv_csr;
        END IF;
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
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
  END process_evergreen_deprn;
*/


  -- Start of comments
  --
  -- Procedure Name : process_evergreen_contract
  -- Desciption     : Sets the evergreen flag and updates the K Header to
  --                  set it to evergreen, and calls evergreen depreciation
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 14-FEB-03 2804703 Added code to check if contract
  --                  not already evergreen
  --                : RMUNJULU 05-MAR-03 Added code to NOT check evergreen eligibility
  --                  if already checked and was not needed
  --                : RMUNJULU 04-MAR-04 3485854 Added code to get if K was evergreen earlier
  --                  Changed condition when evergreen processing needs to be done and
  --                  Added call to process_amortize after evergreen update
  --                : rmunjulu Bug 4141991 Modify Process Evergreen to
  --                   Call Process Accounting during conversion of contract  to evergreen
  --                : PAGARG 01-Mar-05 Bug 4190887 Pass klev_tbl to process_accounting_entries
  -- End of comments
  PROCEDURE process_evergreen_contract(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2,
           p_klev_tbl                    IN klev_tbl_type, -- pagarg 4190887 Added
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_evergreen_status            OUT NOCOPY VARCHAR2) IS

   -- Get the contract end date
   -- RMUNJULU 14-FEB-03 2804703 Added sts_code to cursor
   CURSOR l_k_end_csr ( p_khr_id IN NUMBER) IS
     SELECT khr.end_date,
            khr.sts_code
     FROM   OKC_K_HEADERS_V khr
     WHERE  khr.id = p_khr_id;

   l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name           VARCHAR2(30) := 'process_evergreen_contract';
   l_evergreen_status   VARCHAR2(1) := OKL_API.G_FALSE;
   l_rule_found         VARCHAR2(1);
   lx_klev_tbl          klev_tbl_type;
   lx_chrv_rec          chrv_rec_type;
   lx_clev_tbl          clev_tbl_type;
   l_k_end_date         DATE;

   -- RMUNJULU 14-FEB-03 2804703 Added variable
   l_k_sts_code VARCHAR2(200);

   l_evergreen_earlier VARCHAR2(3) := 'N';
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_evergreen_contract';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- Initialize savepoint to rollback to if error in this block
    SAVEPOINT evergreen;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_tcnv_rec.id = '||px_tcnv_rec.id);
    END IF;
    -- Get the contract end date
    OPEN l_k_end_csr ( p_term_rec.p_contract_id);

    -- RMUNJULU 14-FEB-03 2804703 Added code to get sts_code
    FETCH l_k_end_csr INTO l_k_end_date, l_k_sts_code;
    CLOSE l_k_end_csr;

    -- RMUNJULU 04-MAR-04 3485854
    -- CHECK TO see IF old evergreen transaction exists
    -- Check if another transaction exists which is processed and for which tmt_evergreen_yn was Y
    -- which means this contract was evergreen earlier

    -- so no need to set to evergreen again
    l_evergreen_earlier := check_k_evergreen_ear(
                                    p_khr_id          => p_term_rec.p_contract_id,
                                    p_tcn_id          => px_tcnv_rec.id,
                                    x_return_status   => l_return_status);

    -- Check for evergreen and process evergreen only when
    -- no trn exists and from batch process
    -- and contract has reached its end date

    -- RMUNJULU 14-FEB-03 2804703 Added condition that contract was not already evergreen
    -- Should not check for Evergreen if Contract already in EVERGREEN status
    -- RMUNJULU 05-MAR-03 Added condition to not check for evergreen only when
    -- not a recycled transaction and evergreen flag was not check to T
/*
    IF  p_trn_already_set = G_NO
    AND p_term_rec.p_control_flag = 'BATCH_PROCESS'
    AND TRUNC(l_k_end_date) <= TRUNC(p_sys_date)
    AND l_k_sts_code <> 'EVERGREEN'
    AND NVL(G_TMT_RECYCLE_YN,'N') = 'N' THEN
*/

    -- RMUNJULU 04-MAR-04 3485854
    -- Revamped the condition when evergreen processing needs to be done

    -- Check contract was not earlier set for evergreen
    -- Check control from batch process
    -- Check k ended before termination date
    -- Check no quote triggered the termination process ( ie from batch at end of term)
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_evergreen_earlier = '||l_evergreen_earlier);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_control_flag = '||p_term_rec.p_control_flag);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_quote_id = '||p_term_rec.p_quote_id);
    END IF;
    IF  (l_evergreen_earlier <> 'Y'
    AND p_term_rec.p_control_flag LIKE 'BATCH_PROCESS%'
    AND TRUNC(l_k_end_date) <= TRUNC(p_sys_date)
    AND (p_term_rec.p_quote_id IS NULL
     OR p_term_rec.p_quote_id = OKL_API.G_MISS_NUM))THEN

        -- RMUNJULU 3018641 Step Message
        -- Step : Evergreen
        OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_EVR');

        -- get evergreen eligiblility
        IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling evergreen_eligibility');
        END IF;
        evergreen_eligibility(
           p_term_rec                       => p_term_rec,
           x_return_status                  => l_return_status,
           x_rule_found                     => l_rule_found,
           x_msg_count                      => x_msg_count,
           x_msg_data                       => x_msg_data);

        -- Raise exception to rollback to the savepoint
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

          -- Error getting evergreen rule for contract.
          OKL_API.set_message(
                             p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_AM_EVERGREEN_RULE_ERR');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_rule_found = '||l_rule_found);
        END IF;
        -- if control_flag = "batch process" and evergreen_status = "ok" then
          -- update contract_status to evergreen
          -- exit (raise exception)
        -- end if
        IF  (l_rule_found = G_YES) THEN
         IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling Okl_Am_Integration_Pvt.cancel_termination_quotes');
         END IF;
          -- rmunjulu EDAT cancel all quotes for the contract which are not accepted or completed
          Okl_Am_Integration_Pvt.cancel_termination_quotes  (
            p_api_version     => p_api_version,
                  p_init_msg_list   => OKL_API.G_FALSE,
                  p_khr_id          => p_term_rec.p_contract_id,
                  p_source_trx_id   => NULL ,
                  p_source          => 'EVERGREEN', -- rmunjulu bug 4556370 pass source to integration pvt
                  x_return_status   => l_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data);
          IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called Okl_Am_Integration_Pvt.cancel_termination_quotes l_return_status = '||l_return_status);
          END IF;
          -- Raise exception to rollback to the savepoint
          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling update_k_hdr_and_lines');
         END IF;
          -- set_and_update_contract
          update_k_hdr_and_lines(
                  p_api_version       => p_api_version,
                  p_init_msg_list     => OKL_API.G_FALSE,
                  x_return_status     => l_return_status,
                  x_msg_count         => x_msg_count,
                  x_msg_data          => x_msg_data,
                  p_status           => 'EVERGREEN',
                  p_term_rec          => p_term_rec,
                  p_klev_tbl          => lx_klev_tbl,
                  p_trn_reason_code   => px_tcnv_rec.trn_code,
                  px_overall_status   => px_overall_status,
                  px_tcnv_rec         => px_tcnv_rec,
                  x_chrv_rec          => lx_chrv_rec,
                  x_clev_tbl          => lx_clev_tbl,
                  p_sys_date          => p_sys_date);
           IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called update_k_hdr_and_lines l_return_status = '||l_return_status);
          END IF;
          -- Raise exception to rollback to the savepoint
          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- This code is commented out till further notice
          -- start depreciation for evergreen contract
          /*
          process_evergreen_deprn(
             p_api_version                  => p_api_version,
             p_init_msg_list                => p_init_msg_list,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_term_rec                     => p_term_rec,
             p_sys_date                     => p_sys_date);

          -- Raise exception to rollback to the savepoint
          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
         */
          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling process_accounting_entries');
         END IF;
          -- rmunjulu 4141991 do accounting entries
          --pagarg 4190887 Pass klev_tbl to do accounting at line level
          process_accounting_entries(
                p_api_version        => p_api_version,
                p_init_msg_list      => OKL_API.G_FALSE,
                x_return_status      => l_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,
                p_term_rec            => p_term_rec,
                px_overall_status     => px_overall_status,
                px_tcnv_rec           => px_tcnv_rec,
                p_sys_date            => p_sys_date,
                p_klev_tbl            => p_klev_tbl, -- pagarg 4190887 Added
                p_trn_already_set     => 'Y',
    p_source              => 'EVERGREEN'); -- rmunjulu Bug 4141991
          IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called process_accounting_entries l_return_status = '||l_return_status);
          END IF;
          -- rmunjulu 4141991 Raise exception to rollback to the savepoint
          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

         -- RMUNJULU 04-MAR-04 3485854 added call to process_amortize to do amortization
         -- Additional checks in process_amortize to cater to evergreen scenario
         IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling process_amortize');
         END IF;
         process_amortize(
                p_api_version       => p_api_version,
                p_init_msg_list     => OKL_API.G_FALSE,
                x_return_status     => l_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_term_rec          => p_term_rec,
                px_overall_status   => px_overall_status,
                px_tcnv_rec         => px_tcnv_rec,
                p_sys_date          => p_sys_date,
                p_call_origin       => 'EVERGREEN');
         IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called process_amortize l_return_status = '||l_return_status);
          END IF;
         -- Raise exception to rollback to the savepoint
         IF (px_overall_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

          -- set the transaction record
          set_transaction_rec(
              p_return_status               => l_return_status,
              p_overall_status              => px_overall_status,
              p_tmt_flag                    => 'TMT_EVERGREEN_YN',
              p_tsu_code                    => 'PROCESSED',
              px_tcnv_rec                   => px_tcnv_rec);

          -- Contract eligible for evergreen.
          OKL_API.set_message(
                             p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_AM_K_EVERGREEN');

          -- store the highest degree of error
          set_overall_status(
              p_return_status               => l_return_status,
              px_overall_status             => px_overall_status);

          l_evergreen_status := G_YES;

        ELSE -- contract not eligible for evergreen

          -- Contract not eligible for evergreen.
          OKL_API.set_message(
                             p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_AM_K_NOT_EVERGREEN');

          -- set the transaction record
          set_transaction_rec(
              p_return_status               => l_return_status,
              p_overall_status              => px_overall_status,
              p_tmt_flag                    => 'TMT_EVERGREEN_YN',
              p_tsu_code                    => 'WORKING',
              p_ret_val                     => NULL,
              px_tcnv_rec                   => px_tcnv_rec);

          -- store the highest degree of error
          set_overall_status(
              p_return_status               => l_return_status,
              px_overall_status             => px_overall_status);


          l_evergreen_status := G_NO;

        END IF;
        /* -- RMUNJULU 05-MAR-03 Removed ELSE
    ELSE

          -- Contract not eligible for evergreen.
          OKL_API.set_message(
                             p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_AM_K_NOT_EVERGREEN');
         */
    END IF;

    x_return_status      := l_return_status;
    x_evergreen_status   := l_evergreen_status;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF l_k_end_csr%ISOPEN THEN
           CLOSE l_k_end_csr;
         END IF;

         ROLLBACK TO evergreen;
         x_return_status    := OKL_API.G_RET_STS_ERROR;
         x_evergreen_status := G_YES;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_EVERGREEN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF l_k_end_csr%ISOPEN THEN
           CLOSE l_k_end_csr;
         END IF;

         ROLLBACK TO evergreen;
         x_return_status    := OKL_API.G_RET_STS_ERROR;
         x_evergreen_status := G_YES;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_EVERGREEN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_evergreen_contract;

  -- Start of comments
  --
  -- Procedure Name : process_cancel_insurance
  -- Desciption     : Calls the cancel insurance api to cancel insurances
  -- Business Rules :
  -- Parameters  :
  -- History        : rmunjulu EDAT Added code to pass proper date for cancelation
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE process_cancel_insurance(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2)  IS

   -- Cursor to get the end date of contract -- Can get from main API
   CURSOR   k_end_date_csr ( p_chr_id IN NUMBER) IS
    SELECT  end_date
    FROM    OKC_K_HEADERS_B
    WHERE   id = p_chr_id;

   l_k_end_date            DATE;
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_early_termination_yn  VARCHAR2(1) := G_NO;
   i                       NUMBER;

   -- rmunjulu EDAT
   l_quote_accpt_date DATE;
   l_quote_eff_date DATE;
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_cancel_insurance';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- Start savepoint to rollback to if error in this block
    SAVEPOINT cancel_insurance;

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

    -- rmunjulu EDAT
    -- If quote exists then cancelation date is quote eff from date else sysdate
    IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

        l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
        l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

    ELSE

        l_quote_accpt_date := p_sys_date;
        l_quote_eff_date := p_sys_date;

    END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++
    IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_early_termination_yn = '||p_term_rec.p_early_termination_yn);
    END IF;
    -- Get k end date
    OPEN k_end_date_csr(p_term_rec.p_contract_id);
    FETCH k_end_date_csr INTO l_k_end_date;
    CLOSE k_end_date_csr;

    -- check if early termination
    IF TRUNC (l_k_end_date) > TRUNC (l_quote_eff_date) THEN -- rmunjulu EDAT
       l_early_termination_yn := G_YES;
    END IF;

    -- if early termination then
    IF (NVL(p_term_rec.p_early_termination_yn, '?') = G_YES)
    OR (l_early_termination_yn = G_YES )THEN
       IF (p_trn_already_set = G_YES
           AND NVL(px_tcnv_rec.tmt_cancel_insurance_yn, '?') <> G_YES)
       OR (p_trn_already_set = G_NO) THEN
          -- cancel insurance

        -- RMUNJULU 3018641 Step Message
        -- Step : Cancel Insurance
        OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_INS');

          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling OKL_INSURANCE_POLICIES_PUB.cancel_policies');
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_quote_eff_date = '||l_quote_eff_date);
          END IF;

          OKL_INSURANCE_POLICIES_PUB.cancel_policies(
             p_api_version                => p_api_version,
             p_init_msg_list              => OKL_API.G_FALSE,
             x_return_status              => l_return_status,
             x_msg_count                  => x_msg_count,
             x_msg_data                   => x_msg_data,
             p_contract_id                => p_term_rec.p_contract_id,
             p_cancellation_date          => l_quote_eff_date, -- rmunjulu EDAT -- pass quote effective date
             p_crx_code                   => 'CONTRACT_CANCELED'); -- rmunjulu EDAT -- need to pass new cancelation code

          IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called OKL_INSURANCE_POLICIES_PUB.cancel_policies l_return_status = '||l_return_status);
          END IF;

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            -- Error in cancelling Insurance.
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_ERR_CAN_INS');
          END IF;

          -- Raise exception to rollback to the savepoint
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- store the highest degree of error
          set_overall_status(
            p_return_status                  => l_return_status,
            px_overall_status                => px_overall_status);

          -- set the transaction record
          set_transaction_rec(
            p_return_status                 => l_return_status,
            p_overall_status                => px_overall_status,
            p_tmt_flag                      => 'TMT_CANCEL_INSURANCE_YN',
            p_tsu_code                      => 'WORKING',
            px_tcnv_rec                     => px_tcnv_rec);

       END IF;
    ELSE --( no early termination then  set cancel insurance )
      -- Cancelling of insurance not needed because this
      -- is an end of term contract termination.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_CAN_INS_NOT_NEEDED');

      -- set the transaction record
      set_transaction_rec(
            p_return_status                 => l_return_status,
            p_overall_status                => px_overall_status,
            p_tmt_flag                      => 'TMT_CANCEL_INSURANCE_YN',
            p_tsu_code                      => 'WORKING',
            p_ret_val                       => NULL,
            px_tcnv_rec                     => px_tcnv_rec);
    END IF;

    x_return_status      := l_return_status;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF k_end_date_csr%ISOPEN THEN
            CLOSE k_end_date_csr;
         END IF;

         ROLLBACK TO cancel_insurance;

         x_return_status := OKL_API.G_RET_STS_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CANCEL_INSURANCE_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

         IF k_end_date_csr%ISOPEN THEN
            CLOSE k_end_date_csr;
         END IF;

         ROLLBACK TO cancel_insurance;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CANCEL_INSURANCE_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF k_end_date_csr%ISOPEN THEN
            CLOSE k_end_date_csr;
         END IF;

         ROLLBACK TO cancel_insurance;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CANCEL_INSURANCE_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_cancel_insurance;


  -- Start of comments
  --
  -- Procedure Name : process_close_streams
  -- Desciption     : Calls the streams api to close all streams of contract
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 28-MAR-03 2877278 Changed the cursor and code
  --                  to get only CURRENT streams and HISTORIZE them
  --                : RMUNJULU Bug # 3023206 27-JUN-03 Change priority of checks
  --                : rmunjulu Bug 4058630 Do not check return status of PURPOSE check and do NVLs
  --
  -- End of comments
  PROCEDURE process_close_streams(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_stmv_tbl                    OUT NOCOPY stmv_tbl_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2)  IS

   -- Cursor to get the streams of the contract
   -- RMUNJULU 28-MAR-03 2877278 Added conditions to pick only CURRENT
   -- streams.
   -- MDOKAL 19-SEP-03 Bug 3082639 Securitization
   -- Ensure we do not historize RESIDUAL VALUE and INVESTOR related streams
   -- SMODUGA 11-Oct-04 Bug 3925469
   -- Modified cursor by passing sty_id based on the purpose .
   CURSOR   k_streams_csr ( p_chr_id IN NUMBER,p_sty_id IN NUMBER) IS
    SELECT  STM.id
    FROM    OKL_STREAMS_V STM,
            OKL_STRM_TYPE_B STY
    WHERE   STM.khr_id   = p_chr_id
    AND     STM.say_code = 'CURR'
    AND     STM.STY_ID   = STY.ID
    AND     STY.ID  NOT IN (nvl(p_sty_id, OKL_API.G_MISS_NUM)) -- rmunjulu 4058630 check for NVL
    AND     nvl(STY.STREAM_TYPE_SUBCLASS, 'X') NOT IN ('INVESTOR_DISBURSEMENT') -- new subclass
--    AND     nvl(STM.sgn_code,'*') <> 'INTC'; -- rmunjulu 11-Apr-06 ER 5139307
    AND     nvl(STM.sgn_code,'*') NOT IN ('INTC','LATE_CALC'); -- Bug#i6472228 - Added to exclude streams generated
                                                               -- during late charge/interest calculation processs
                                                               -- These can be LATE FEE/LATE INTEREST/ INVESTOR LATE FEE/ INTEREST


   k_streams_rec           k_streams_csr%ROWTYPE;
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_stmv_tbl             stmv_tbl_type;
   lx_stmv_tbl             stmv_tbl_type;
   l_streams_found         VARCHAR2(1) := G_NO;
   i                       NUMBER;
   l_id                    NUMBER;

    --smoduga added variables for userdefined streams 3925469
   lx_sty_id NUMBER;

   -- rmunjulu bug 4058630
   l_dummy_status VARCHAR2(3);
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_close_streams';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- Start a savepoint to rollback to if error in this block
    SAVEPOINT close_streams;

    -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
   OKL_STREAMS_UTIL.get_primary_stream_type(p_term_rec.p_contract_id,
                                                   'RESIDUAL_VALUE',
                                                   l_dummy_status, -- rmunjulu 4058630 (get into dummy as return not needed)
                                                   lx_sty_id);
    -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_trn_already_set = '||p_trn_already_set);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_tcnv_rec.tmt_streams_updated_yn = '||px_tcnv_rec.tmt_streams_updated_yn);
    END IF;
    -- Check if streams exist
    OPEN k_streams_csr(p_term_rec.p_contract_id,nvl(lx_sty_id,OKL_API.G_MISS_NUM)); -- rmunjulu 4058630 check for NVL
    FETCH k_streams_csr INTO l_id;
    IF k_streams_csr%FOUND THEN
      l_streams_found := G_YES;
    END IF;
    CLOSE k_streams_csr;


    -- RMUNJULU Bug # 3023206 Changed the priority, first check if Close Streams
    -- needed and then check if streams exists which needs to be closed
    -- if streams found then

--    IF (l_streams_found = G_YES) THEN
    IF (p_trn_already_set = G_YES
        AND NVL(px_tcnv_rec.tmt_streams_updated_yn, '?') <> G_YES)
    OR (p_trn_already_set = G_NO) THEN

       -- if streams found then
       IF (l_streams_found = G_YES) THEN

             i := 1;
             -- set the tbl type for streams pub
             FOR k_streams_rec IN k_streams_csr(p_term_rec.p_contract_id,nvl(lx_sty_id,OKL_API.G_MISS_NUM)) LOOP -- rmunjulu 4058630 check for NVL
               lp_stmv_tbl(i).khr_id       :=   p_term_rec.p_contract_id;
               lp_stmv_tbl(i).active_yn    :=   G_NO;
               lp_stmv_tbl(i).id           :=   k_streams_rec.id;

               -- RMUNJULU 28-MAR-03 2877278 Added code to set say_code to HIST
               lp_stmv_tbl(i).say_code    :=   'HIST';
               lp_stmv_tbl(i).date_history :=   SYSDATE;

               i := i + 1;
             END LOOP;
             IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling OKL_STREAMS_PUB.update_streams');
             END IF;
             -- close streams
             OKL_STREAMS_PUB.update_streams(
               p_api_version                => p_api_version,
               p_init_msg_list              => OKL_API.G_FALSE,
               x_return_status              => l_return_status,
               x_msg_count                  => x_msg_count,
               x_msg_data                   => x_msg_data,
               p_stmv_tbl                   => lp_stmv_tbl,
               x_stmv_tbl                   => lx_stmv_tbl);
             IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called OKL_STREAMS_PUB.update_streams l_return_status ='||l_return_status);
             END IF;

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               -- Streams table update failed.
               OKL_API.set_message( p_app_name    => G_APP_NAME,
                                    p_msg_name    => 'OKL_AM_ERR_UPD_STREAMS');
             END IF;

             -- Raise exception to rollback to if error
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- store the highest degree of error
             set_overall_status(
               p_return_status                  => l_return_status,
               px_overall_status                => px_overall_status);

             -- set the transaction record
             set_transaction_rec(
               p_return_status                 => l_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_STREAMS_UPDATED_YN',
               p_tsu_code                      => 'WORKING',
               px_tcnv_rec                     => px_tcnv_rec);

--       END IF;
       ELSE --( no streams found )

         -- No future billable streams found.
         OKL_API.set_message( p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKL_AM_NO_STREAMS');

         -- set the transaction record
         set_transaction_rec(
            p_return_status                 => l_return_status,
            p_overall_status                => px_overall_status,
            p_tmt_flag                      => 'TMT_STREAMS_UPDATED_YN',
            p_tsu_code                      => 'WORKING',
            p_ret_val                       => NULL,
            px_tcnv_rec                     => px_tcnv_rec);

      END IF;

    END IF;

    x_return_status      := l_return_status;
    x_stmv_tbl           := lx_stmv_tbl;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF k_streams_csr%ISOPEN THEN
            CLOSE k_streams_csr;
         END IF;

         ROLLBACK TO close_streams;

         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_STREAMS_UPDATED_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

         IF k_streams_csr%ISOPEN THEN
            CLOSE k_streams_csr;
         END IF;

         ROLLBACK TO close_streams;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_STREAMS_UPDATED_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF k_streams_csr%ISOPEN THEN
            CLOSE k_streams_csr;
         END IF;

         ROLLBACK TO close_streams;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_STREAMS_UPDATED_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_close_streams;

  -- rmunjulu BUYOUT PROCESS --+++++++ START   ++++++++++++++++++++++++++++++
  -- Start of comments
  --
  -- Procedure Name : process_auto_invoice
  -- Desciption     : This procedure checks if auto invoice is required and does invoicing for those amounts
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU BUYOUT_PROCESS created
  --
  -- End of comments
  PROCEDURE process_auto_invoice(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           --x_adjv_rec                    OUT NOCOPY adjv_rec_type,
           --x_ajlv_tbl                    OUT NOCOPY ajlv_tbl_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2,
     p_auto_invoice_yn             IN VARCHAR2 DEFAULT NULL, -- rmunjulu BUYOUT_PROCESS
           p_klev_tbl                    IN klev_tbl_type DEFAULT empty_klev_tbl)  IS -- rmunjulu BUYOUT_PROCESS

   l_invoice_amount NUMBER;
   j NUMBER;
   l_curr_code VARCHAR2(200);
   l_formatted_inv_amt VARCHAR2(200);
   l_try_id  NUMBER;
   l_purchase_option_sty_id  NUMBER;
   l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_taiv_rec         okl_trx_ar_invoices_pub.taiv_rec_type;
   lx_taiv_rec        okl_trx_ar_invoices_pub.taiv_rec_type;
   l_tilv_rec         okl_txl_ar_inv_lns_pub.tilv_rec_type;
   lx_tilv_rec        okl_txl_ar_inv_lns_pub.tilv_rec_type;
   l_empty_taiv_rec   okl_trx_ar_invoices_pub.taiv_rec_type;
   l_empty_tilv_rec   okl_txl_ar_inv_lns_pub.tilv_rec_type;
   l_api_name         CONSTANT VARCHAR2(30) := 'process_auto_inv';
   l_api_version      CONSTANT NUMBER := 1;
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(2000);
   l_bpd_acc_rec       okl_acc_call_pub.bpd_acc_rec_type;

   l_quote_accpt_date DATE;
   l_quote_eff_date   DATE;

   l_functional_currency_code VARCHAR2(15);
   l_contract_currency_code VARCHAR2(15);
   l_currency_conversion_type VARCHAR2(30);
   l_currency_conversion_rate NUMBER;
   l_currency_conversion_date DATE;
   l_converted_amount NUMBER;

   -- Since we do not use the amount or converted amount
   -- set a hardcoded value for the amount (and pass to to
   -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
   -- conversion values )
   l_hard_coded_amount NUMBER := 100;

 -- ansethur  23-FEB-07  R12B Added for Billing Enhancement Project   Start Changes
   l_tldv_tbl          okl_tld_pvt.tldv_tbl_type;
   lx_tldv_tbl         okl_tld_pvt.tldv_tbl_type;

   l_tilv_tbl          okl_txl_ar_inv_lns_pub.tilv_tbl_type;
   lx_tilv_tbl         okl_txl_ar_inv_lns_pub.tilv_tbl_type;
 -- ansethur  23-FEB-07  R12B Added for Billing Enhancement Project  End Changes
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_auto_invoice';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

       SAVEPOINT auto_invoice;

       -- If quote exists then close date is quote accept date else sysdate
       IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

         l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
         l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

       ELSE

         l_quote_accpt_date := p_sys_date;
         l_quote_eff_date := p_sys_date;

       END IF;
       IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_contract_id = '||p_term_rec.p_contract_id);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_trn_already_set = '||p_trn_already_set);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_tcnv_rec.tmt_streams_updated_yn = '||px_tcnv_rec.tmt_streams_updated_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_auto_invoice_yn = '|| p_auto_invoice_yn);
       END IF;
       -- check if auto invoice needed and not done already
       IF  ((p_trn_already_set = G_YES
        AND  NVL(px_tcnv_rec.tmt_generic_flag3_yn, '?') <> G_YES)
        OR p_trn_already_set = G_NO)
    AND p_auto_invoice_yn = 'Y'
       AND p_klev_tbl.COUNT > 0 THEN

          IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_STREAMS_UTIL.get_primary_stream_type.');
          END IF;

          -- get stream type id for Quote Purchase Amount Purpose
          OKL_STREAMS_UTIL.get_primary_stream_type(
                           p_khr_id              => p_term_rec.p_contract_id,
                           p_primary_sty_purpose => 'AMBPOC', -- Quote Purchase Amount Purpose
                           x_return_status       => l_return_status,
                           x_primary_sty_id      => l_purchase_option_sty_id);

          IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_STREAMS_UTIL.get_primary_stream_type.l_return_status = '||l_return_status);
          END IF;

          IF l_return_status = OKL_API.G_RET_STS_SUCCESS
          AND (l_purchase_option_sty_id IS NULL OR l_purchase_option_sty_id = OKL_API.G_MISS_NUM) THEN

             l_return_status := OKL_API.G_RET_STS_ERROR;
          END IF;

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             -- Unable to auto invoice the purchase amount for Contract CONTRACT_NUMBER.
             OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_INV_CNTRCT_ERR',
                             p_token1        => 'CONTRACT_NUMBER',
                             p_token1_value  => p_term_rec.p_contract_number);
          END IF;

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- Get the currency code for contract
          l_curr_code := OKL_AM_UTIL_PVT.get_chr_currency(
                                 p_chr_id => p_term_rec.p_contract_id);

          -- Get the functional currency from AM_Util
          l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency();
          IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_ACCOUNTING_UTIL.convert_to_functional_currency');
          END IF;
          -- Get the currency conversion details from ACCOUNTING_Util
          OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id                   => p_term_rec.p_contract_id,
                     p_to_currency              => l_functional_currency_code,
                     p_transaction_date         => l_quote_accpt_date, -- rmunjulu EDAT
                     p_amount                   => l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency        => l_contract_currency_code,
                     x_currency_conversion_type => l_currency_conversion_type,
                     x_currency_conversion_rate => l_currency_conversion_rate,
                     x_currency_conversion_date => l_currency_conversion_date,
                     x_converted_amount         => l_converted_amount);
          IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_ACCOUNTING_UTIL.convert_to_functional_currency l_return_status ='||l_return_status);
          END IF;

          -- Set some of the taiv rec attributes
          l_taiv_rec.currency_code            := l_contract_currency_code;
          l_taiv_rec.currency_conversion_type := l_currency_conversion_type;
          l_taiv_rec.currency_conversion_rate := l_currency_conversion_rate;
          l_taiv_rec.currency_conversion_date := l_currency_conversion_date;
          l_taiv_rec.try_id                   := l_try_id;
          l_taiv_rec.khr_id                   := p_term_rec.p_contract_id;
          l_taiv_rec.date_invoiced            := l_quote_accpt_date;
          l_taiv_rec.date_entered             := l_quote_accpt_date;
          l_taiv_rec.description              := 'Automatically Invoice at End Of Term';
          l_taiv_rec.trx_status_code          := 'SUBMITTED';--'ENTERED';
          --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
          l_taiv_rec.legal_entity_id          :=  OKL_LEGAL_ENTITY_UTIL.get_khr_le_id (p_term_rec.p_contract_id);

          -- set some of the tilv rec attributes
          l_tilv_rec.description              := 'Automatically Invoice at End Of Term';
          l_tilv_rec.sty_id                   := l_purchase_option_sty_id;
          l_tilv_rec.inv_receiv_line_code     := 'LINE';

          -- loop thru assets and derive purchase amount and invoice the same
          FOR j IN p_klev_tbl.FIRST..p_klev_tbl.LAST LOOP

             -- get purchase amount for the asset
             get_purchase_amount(
                       p_term_rec        => p_term_rec,
                       p_kle_id          => p_klev_tbl(j).p_kle_id,
                       x_purchase_amount => l_invoice_amount,
                       x_return_status   => l_return_status);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                -- Unable to auto invoice the purchase amount for Contract CONTRACT_NUMBER.
                OKL_API.set_message(
                 p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_INV_CNTRCT_ERR',
                             p_token1        => 'CONTRACT_NUMBER',
                             p_token1_value  => p_term_rec.p_contract_number);
             END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- Get transaction id based on amount type
             IF l_invoice_amount > 0 THEN

                 okl_am_util_pvt.get_transaction_id (
                          p_try_name        => 'BILLING',
                          x_return_status   => l_return_status,
                          x_try_id          => l_try_id);

             ELSIF l_invoice_amount < 0 THEN

                 okl_am_util_pvt.get_transaction_id (
                          p_try_name        => 'CREDIT MEMO',
                          x_return_status   => l_return_status,
                          x_try_id          => l_try_id);
             END IF;

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
             OR NVL (l_try_id, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN

                 OKL_API.SET_MESSAGE (
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => G_INVALID_VALUE,
                     p_token1        => G_COL_NAME_TOKEN,
                     p_token1_value  => 'Transaction Type');

                -- Unable to auto invoice the purchase amount for Contract CONTRACT_NUMBER.
                OKL_API.set_message(
                 p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_INV_CNTRCT_ERR',
                             p_token1        => 'CONTRACT_NUMBER',
                             p_token1_value  => p_term_rec.p_contract_number);
             END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- start invoice part only if invoice amount <> 0
             IF  l_invoice_amount <> 0 THEN

                 l_taiv_rec.amount := l_invoice_amount;
                 l_taiv_rec.try_id := l_try_id;

 --ansethur  23-FEB-2007  Added for R12 B Billing Architecture Start Changes
 -- Included call to Enhanced Billing API in the place of the calls to Billing Header,Lines and Distributions
                 l_taiv_rec.okl_source_billing_trx := 'TERMINATION';
                 l_tilv_rec.line_number   := j;
                 l_tilv_rec.kle_id        := p_klev_tbl(j).p_kle_id;
                 l_tilv_rec.amount        := l_invoice_amount;

                 l_tilv_tbl(0)            := l_tilv_rec; -- Assign the line record in tilv_tbl structure

                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.okl_internal_billing_pvt.create_billing_trx.',
                         'Start(+)');
                 END IF;
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling okl_internal_billing_pvt.create_billing_trx');
                 END IF;
                 okl_internal_billing_pvt.create_billing_trx(p_api_version   => l_api_version,
                                                             p_init_msg_list => p_init_msg_list,
                                                             x_return_status => x_return_status,
                                                             x_msg_count     => x_msg_count,
                                                             x_msg_data      => x_msg_data,
                                                             p_taiv_rec      => l_taiv_rec,
                                                             p_tilv_tbl      => l_tilv_tbl,
                                                             p_tldv_tbl      => l_tldv_tbl,
                                                             x_taiv_rec      => lx_taiv_rec,
                                                             x_tilv_tbl      => lx_tilv_tbl,
                                                             x_tldv_tbl      => lx_tldv_tbl);
                 IF (is_debug_statement_on) THEN
                   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called okl_internal_billing_pvt.create_billing_trx x_return_status = '||x_return_status);
                 END IF;


               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.okl_internal_billing_pvt.create_billing_trx.',
                         'End(+)');
                 END IF;

/* --ansethur  23-FEB-2007  commented for R12 B Billing Architecture
                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.okl_trx_ar_invoices_pub.insert_trx_ar_invoices.',
                         'Start(+)');
                 END IF;

                 OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices (
                       p_api_version   => P_api_version,
                       p_init_msg_list => OKL_API.G_FALSE,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data,
                       p_taiv_rec      => l_taiv_rec,
                       x_taiv_rec      => lx_taiv_rec);

                 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                    -- Error invoicing Asset ASSET_NUMBER of Contract CONTRACT_NUMBER.
                    OKL_API.set_message(
                                         p_app_name      => G_APP_NAME,
                                         p_msg_name      => 'OKL_AM_INV_AMT_ERR',
                                         p_token1        => 'ASSET_NUMBER',
                                         p_token1_value  => p_klev_tbl(j).p_asset_name,
                                         p_token2        => 'CONTRACT_NUMBER',
                                         p_token2_value  => p_term_rec.p_contract_number);
                 END IF;

                 IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;

                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.okl_trx_ar_invoices_pub.insert_trx_ar_invoices.',
                         'End(-)');
                 END IF;

                 l_tilv_rec.line_number   := j;
                 l_tilv_rec.kle_id        := p_klev_tbl(j).p_kle_id;
                 l_tilv_rec.amount        := l_invoice_amount;
                 l_tilv_rec.tai_id        := lx_taiv_rec.id;

                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.okl_trx_ar_invoices_pub.insert_txl_ar_inv_lns.',
                         'Start(+)');
                 END IF;

                 -- Create Invoice Line
                 OKL_TXL_AR_INV_LNS_PUB.insert_txl_ar_inv_lns (
                     p_api_version   => l_api_version,
                     p_init_msg_list => OKL_API.G_FALSE,
                     x_return_status => l_return_status,
                     x_msg_count     => l_msg_count,
                     x_msg_data      => l_msg_data,
                     p_tilv_rec      => l_tilv_rec,
                     x_tilv_rec      => lx_tilv_rec);

                 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                    -- Error invoicing Asset ASSET_NUMBER of Contract CONTRACT_NUMBER.
                    OKL_API.set_message(
                                         p_app_name      => G_APP_NAME,
                                         p_msg_name      => 'OKL_AM_INV_AMT_ERR',
                                         p_token1        => 'ASSET_NUMBER',
                                         p_token1_value  => p_klev_tbl(j).p_asset_name,
                                         p_token2        => 'CONTRACT_NUMBER',
                                         p_token2_value  => p_term_rec.p_contract_number);
                 END IF;
                 IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;

                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.okl_trx_ar_invoices_pub.insert_txl_ar_inv_lns.',
                         'End(-)');
                 END IF;

                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.OKL_ACC_CALL_PUB.create_acc_trans.',
                         'Start(+)');
                 END IF;

                 l_bpd_acc_rec.id            := lx_tilv_rec.id;
                 l_bpd_acc_rec.source_table  := 'OKL_TXL_AR_INV_LNS_B';

                 -- Create Accounting Distribution
                 OKL_ACC_CALL_PUB.create_acc_trans(
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_bpd_acc_rec   => l_bpd_acc_rec);

                 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                    -- Error invoicing Asset ASSET_NUMBER of Contract CONTRACT_NUMBER.
                    OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_INV_AMT_ERR',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => p_klev_tbl(j).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number);
                 END IF;

                 IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;

                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'Process_Auto_Invoice.OKL_ACC_CALL_PUB.create_acc_trans.',
                         'End(-)');
                 END IF;
--ansethur  23-FEB-2007  commented for R12 B Billing Architecture  Ends
*/
 --ansethur  23-FEB-2007  Added for R12 B Billing Architecture End Changes
                 -- Format the invoice amt
                 l_formatted_inv_amt  := OKL_ACCOUNTING_UTIL.format_amount(
                                                           p_amount        => l_invoice_amount,
                                                           p_currency_code => l_curr_code);

                 -- Asset ASSET_NUMBER of Contract CONTRACT_NUMBER is invoiced with amount AMOUNT.
                 OKL_API.set_message(
                 p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_INV_AMT_SUCCESS',
                             p_token1        => 'ASSET_NUMBER',
                             p_token1_value  => p_klev_tbl(j).p_asset_name,
                             p_token2        => 'CONTRACT_NUMBER',
                             p_token2_value  => p_term_rec.p_contract_number,
                             p_token3        => 'AMOUNT',
                             p_token3_value  => l_formatted_inv_amt);

              END IF; -- end of if l_invoice_amount <> 0
           END LOOP;

           -- Set the tmt_generic_flag3_yn
           set_transaction_rec(
                 p_return_status   => l_return_status,
                 p_overall_status  => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'WORKING',
                 p_ret_val         => NULL,
                 px_tcnv_rec       => px_tcnv_rec);

       END IF;

       x_return_status := l_return_status;

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         ROLLBACK TO auto_invoice;

         x_return_status := OKL_API.G_RET_STS_ERROR;

         -- store the highest degree of error
         set_overall_status(
                 p_return_status    => x_return_status,
                 px_overall_status  => px_overall_status);

        -- Set the tmt_generic_flag3_yn
        set_transaction_rec(
                 p_return_status    => x_return_status,
                 p_overall_status   => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'ERROR',
                 p_ret_val         => NULL,
                 px_tcnv_rec       => px_tcnv_rec);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

         ROLLBACK TO auto_invoice;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
                 p_return_status    => x_return_status,
                 px_overall_status  => px_overall_status);

        -- Set the tmt_generic_flag3_yn
        set_transaction_rec(
                 p_return_status    => x_return_status,
                 p_overall_status   => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'ERROR',
                 p_ret_val         => NULL,
                 px_tcnv_rec       => px_tcnv_rec);

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         ROLLBACK TO auto_invoice;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
                 p_return_status    => x_return_status,
                 px_overall_status  => px_overall_status);

        -- Set the tmt_generic_flag3_yn
        set_transaction_rec(
                 p_return_status    => x_return_status,
                 p_overall_status   => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'ERROR',
                 p_ret_val         => NULL,
                 px_tcnv_rec       => px_tcnv_rec);

    END;
    -- rmunjulu BUYOUT PROCESS --+++++++ END   ++++++++++++++++++++++++++++++

  -- Start of comments
  --
  -- Procedure Name : process_close_balances
  -- Desciption     : Calls the AR adjustments apis for K header and
  --                  Lines to close balances
  -- Business Rules :
  -- Parameters    :
  -- Version      : 1.0
  -- History        : 03-JAN-03 RMUNJULU 2683876 Changed
  --                  to set the currency conversion columns
  --                  Added code to exit when product id not found
  --                  Changed cursor to get balance rec with 100 percent
  --                  DEBIT distribution
  --                : RMUNJULU 07-APR-03 2883292 Changed IF to check for NULL
  --                  tolerance_amt instead of -1
  --                : RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
  --                  Also changed the processing to do Create Header, Create Line , Create Accounting Distribution
  --                : rmunjulu EDAT Added code to get quote accept date and pass as close bal date
  --                  Also added code to get the unpaid invoices before the quote effective date
  --                  Also added code to send additional parameters of quote_id, contract_id and transaction_date
  --                  to accounting engine
  --                : rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
  --                : rmunjulu BUYOUT_PROCESS
  --
  -- End of comments
  PROCEDURE process_close_balances(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           x_adjv_rec                    OUT NOCOPY adjv_rec_type,
           x_ajlv_tbl                    OUT NOCOPY ajlv_tbl_type,
           p_sys_date                    IN DATE,
           p_trn_already_set             IN VARCHAR2,
     p_auto_invoice_yn             IN VARCHAR2 DEFAULT NULL, -- rmunjulu BUYOUT_PROCESS
           p_klev_tbl                    IN klev_tbl_type DEFAULT empty_klev_tbl)  IS -- rmunjulu BUYOUT_PROCESS

   -- Cursor to get the balances of contract
   CURSOR  k_balances_csr (p_khr_id IN NUMBER, p_trn_date DATE) IS -- rmunjulu EDAT
   SELECT  SUM(amount_due_remaining)
   FROM    OKL_BPD_LEASING_PAYMENT_TRX_V
   WHERE   contract_id = p_khr_id
   AND     invoice_date <= p_trn_date; -- rmunjulu EDAT -- Added condition to get only
                                --those invoices which are before quote effective date

   -- Cursor to get the lines with amount due and payment schedule id for the balances
   CURSOR k_bal_lns_csr (p_khr_id IN NUMBER, p_trn_date DATE) IS -- rmunjulu EDAT
   SELECT OBLP.amount_due_remaining       AMOUNT,
          OBLP.stream_type_id             STREAM_TYPE_ID,
          OSTY.name                       STREAM_MEANING,
          OBLP.payment_schedule_id        SCHEDULE_ID,
          OBLP.receivables_invoice_number AR_INVOICE_NUMBER,
          OTIL.id                         TIL_ID,
          -999                            TLD_ID
   FROM   OKL_BPD_LEASING_PAYMENT_TRX_V  OBLP,
          OKL_TXL_AR_INV_LNS_V           OTIL,
          OKL_STRM_TYPE_V                OSTY
   WHERE  OBLP.contract_id             = p_khr_id
   AND    OBLP.receivables_invoice_id  = OTIL.receivables_invoice_id
   AND    OBLP.stream_type_id          = OSTY.id
   AND    OBLP.amount_due_remaining > 0
   AND    OBLP.invoice_date <= p_trn_date -- rmunjulu EDAT -- Added condition to get only
                                --those invoices which are before quote effective date
   UNION
   SELECT OBLP.amount_due_remaining       AMOUNT,
          OBLP.stream_type_id             STREAM_TYPE_ID,
          OSTY.name                       STREAM_MEANING,
          OBLP.payment_schedule_id        SCHEDULE_ID,
          OBLP.receivables_invoice_number AR_INVOICE_NUMBER,
          OTAI.til_id_details             TIL_ID,
          OTAI.id                         TLD_ID
   FROM   OKL_BPD_LEASING_PAYMENT_TRX_V  OBLP,
          OKL_TXD_AR_LN_DTLS_V           OTAI,
          OKL_STRM_TYPE_V                OSTY
   WHERE  OBLP.contract_id             = p_khr_id
   AND    OBLP.receivables_invoice_id  = OTAI.receivables_invoice_id
   AND    OBLP.stream_type_id          = OSTY.id
   AND    OBLP.amount_due_remaining > 0
   AND    OBLP.invoice_date <= p_trn_date; -- rmunjulu EDAT -- Added condition to get only
                                --those invoices which are before quote effective date

   -- Cursor to get the product of the contract
   CURSOR prod_id_csr (p_khr_id IN NUMBER) IS
     SELECT   pdt_id
     FROM     OKL_K_HEADERS_V
     WHERE    id = p_khr_id;

   -- Cursor to get the code_combination_id for the transaction id and
   -- transaction table
   -- RMUNJULU 03-JAN-03 2683876 Added code to
   -- make sure we get the debit distribution and also it is 100percent
   CURSOR code_combination_id_csr(p_source_id    IN NUMBER,
                                  p_source_table IN VARCHAR2) IS
    SELECT DST.code_combination_id
    FROM   OKL_TRNS_ACC_DSTRS DST
    WHERE  DST.source_id     = p_source_id
    AND    DST.source_table  = p_source_table
    AND    DST.cr_dr_flag    = 'D'
    AND    DST.percentage    = 100;

   k_bal_lns_rec               k_bal_lns_csr%ROWTYPE;
   l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_adjv_rec                 adjv_rec_type;
   lx_adjv_rec                 adjv_rec_type;
--   lp_ajlv_tbl                 ajlv_tbl_type;
--   lx_ajlv_tbl                 ajlv_tbl_type;
   l_early_termination_yn      VARCHAR2(1) := OKL_API.G_FALSE;
   l_total_amount_due          NUMBER := -1;
   l_code_combination_id       NUMBER := -1;
   i                           NUMBER :=  1;
   l_tolerance_amt             NUMBER := -1;
   l_api_name                  VARCHAR2(30) := 'process_close_balances';
   l_pdt_id                    NUMBER := 0;
   lp_tmpl_identify_rec        OKL_ACCOUNT_DIST_PUB.tmpl_identify_rec_type;
   lp_dist_info_rec            OKL_ACCOUNT_DIST_PUB.dist_info_rec_type;
   lp_ctxt_val_tbl             OKL_ACCOUNT_DIST_PUB.ctxt_val_tbl_type;
   lp_acc_gen_primary_key_tbl  OKL_ACCOUNT_DIST_PUB.acc_gen_primary_key;
   lx_template_tbl             OKL_ACCOUNT_DIST_PUB.avlv_tbl_type;
   lx_amount_tbl               OKL_ACCOUNT_DIST_PUB.amount_tbl_type;
   l_overall_status            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_try_id                    NUMBER;
   l_trans_meaning             VARCHAR2(200);
   l_currency_code             VARCHAR2(200);
   l_formatted_bal_amt         VARCHAR2(200);
   l_formatted_tol_amt         VARCHAR2(200);
   l_formatted_adj_amt         VARCHAR2(200);

     -- RMUNJULU 03-JAN-03 2683876 Added variables
     l_functional_currency_code VARCHAR2(15);
     l_contract_currency_code   VARCHAR2(15);
     l_currency_conversion_type VARCHAR2(30);
     l_currency_conversion_rate NUMBER;
     l_currency_conversion_date DATE;
     l_converted_amount NUMBER;

     -- Since we do not use the amount or converted amount
     -- set a hardcoded value for the amount (and pass to to
     -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
     -- conversion values )
     l_hard_coded_amount NUMBER := 100;

     -- RMUNJULU 3596626
   lp_ajlv_rec                 OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;
   lx_ajlv_rec                 OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;

   l_ajlv_rec                  OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;

   -- rmunjulu EDAT
   l_quote_accpt_date DATE;
   l_quote_eff_date DATE;

   -- rmunjulu BUYOUT_PROCESS
   l_invoice_amount NUMBER;
   j NUMBER;
   l_curr_code VARCHAR2(200);
   l_formatted_inv_amt VARCHAR2(200);
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_close_balances';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

  ---
     --get the tolerance limit from profile
     -- get the total balances of ARs for the contract
     -- if total balance amount within the tolerance limit then
       -- close balances
     -- end if

    -- Establish savepoint so that when error rollback
    SAVEPOINT close_balances;

    -- RMUNJULU 3018641 Step Message
    -- Step : Close Balances
    OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_CLB');

    -- rmunjulu BUYOUT PROCESS --+++++++ START ++++++++++++++++++++++++++++++
    -- check for auto invoice yn and invoice if applicable
    process_auto_invoice(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_term_rec                      => p_term_rec,
        px_overall_status               => px_overall_status,
        px_tcnv_rec                     => px_tcnv_rec,
        --x_adjv_rec                      => lx_adjv_rec,
        --x_ajlv_tbl                      => lx_ajlv_tbl,
        p_sys_date                      => p_sys_date,
        p_trn_already_set               => p_trn_already_set,
        p_auto_invoice_yn               => p_auto_invoice_yn,
  p_klev_tbl                      => p_klev_tbl);

    -- If process auto invoice errors everything errors
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- store the highest degree of error
    set_overall_status(
               p_return_status                 => l_return_status,
               px_overall_status               => px_overall_status);

    -- set the transaction record
    set_transaction_rec(
               p_return_status                 => l_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
               p_tsu_code                      => 'WORKING',
               px_tcnv_rec                     => px_tcnv_rec);

    -- set the transaction record
    set_transaction_rec(
               p_return_status                 => l_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_GENERIC_FLAG3_YN',
               p_tsu_code                      => 'WORKING',
               px_tcnv_rec                     => px_tcnv_rec);

    -- rmunjulu BUYOUT PROCESS --+++++++ END   ++++++++++++++++++++++++++++++
    /*
    -- Establish savepoint so that when error rollback
    SAVEPOINT close_balances;

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

    -- rmunjulu EDAT
    -- If quote exists then close date is quote accept date else sysdate
    IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

      l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
      l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

    ELSE

      l_quote_accpt_date := p_sys_date;
      l_quote_eff_date := p_sys_date;

    END IF;

    -- rmunjulu EDAT
    -- set the additional parameters with contract_id, quote_id and transaction_date
    -- to be passed to formula engine

    lp_ctxt_val_tbl(1).name := 'contract_id';
    lp_ctxt_val_tbl(1).value := p_term_rec.p_contract_id;

    lp_ctxt_val_tbl(2).name := 'quote_id';
    lp_ctxt_val_tbl(2).value := p_term_rec.p_quote_id;

    lp_ctxt_val_tbl(3).name := 'transaction_date';
    lp_ctxt_val_tbl(3).value := to_char(l_quote_accpt_date,'MM/DD/YYYY'); -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

    -- get the total balances of ARs for the contract
    OPEN  k_balances_csr(p_term_rec.p_contract_id,l_quote_eff_date); -- rmunjulu EDAT
    FETCH k_balances_csr INTO l_total_amount_due;
    CLOSE k_balances_csr;

    -- set the total amount if it is null
    IF l_total_amount_due IS NULL THEN
       l_total_amount_due := 0;
    END IF;

    -- Check if total amount due is +ve else set message and exit
    IF l_total_amount_due <= 0 THEN

      -- No outstanding balances found.
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_NO_BAL');

      -- set the transaction record
      set_transaction_rec(
              p_return_status                 => l_return_status,
              p_overall_status                => px_overall_status,
              p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
              p_tsu_code                      => 'WORKING',
              p_ret_val                       => NULL,
              px_tcnv_rec                     => px_tcnv_rec);

    ELSE -- can try closing balances

      --get the tolerance limit from profile
      FND_PROFILE.get('OKL_SMALL_BALANCE_TOLERANCE',l_tolerance_amt);

      -- if no tolerance amt then assume tolerance amt = 0 ,
      -- raise warning msg and proceed
      -- RMUNJULU 07-APR-03 2883292 Changed IF to check for NULL instead of -1
      IF  l_tolerance_amt IS NULL THEN

        l_tolerance_amt := 0;
        -- No tolerance amount found for closing of balances.
        OKL_API.set_message( p_app_name    => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_NO_TOL_AMT');

      END IF;

      -- rmunjulu BUYOUT_PROCESS -- do not close balances if auto invoice was done
      -- in this case user will run small balance write off concurrent program separately.
      IF  p_auto_invoice_yn = 'N' -- No auto invoice
   AND px_tcnv_rec.tmt_close_balances_yn = 'N' THEN -- had already errored

      -- IF total balance amount within the tolerance limit and amount due>0 then
      IF (l_total_amount_due <= l_tolerance_amt) THEN

         IF (p_trn_already_set = G_YES
             AND NVL(px_tcnv_rec.tmt_close_balances_yn, '?') <> G_YES)
         OR (p_trn_already_set = G_NO) THEN

           -- ******** CREATE HEADER TRN ************* --

           -- set the adjusts rec
           lp_adjv_rec.trx_status_code           :=   'WORKING'; -- tsu_code
           -- tcn_id is set to transaction id from transaction rec
           lp_adjv_rec.tcn_id                    :=   px_tcnv_rec.id;
           -- adjustment_reason_code comes from OKL_ADJUSTMENT_REASON
           lp_adjv_rec.adjustment_reason_code    :=   'SMALL AMT REMAINING';
           lp_adjv_rec.apply_date                :=   l_quote_eff_date; -- rmunjulu EDAT
           lp_adjv_rec.gl_date                   :=   l_quote_accpt_date; -- rmunjulu EDAT

           -- call the adjusts api
           OKL_TRX_AR_ADJSTS_PUB.insert_trx_ar_adjsts(
             p_api_version                   => p_api_version,
             p_init_msg_list                 => OKL_API.G_FALSE,
             x_return_status                 => l_return_status,
             x_msg_count                     => x_msg_count,
             x_msg_data                      => x_msg_data,
             p_adjv_rec                      => lp_adjv_rec,
             x_adjv_rec                      => lx_adjv_rec);

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
             -- Error occurred when creating adjustment records to write off balances.
             OKL_API.set_message( p_app_name      => G_APP_NAME,
                                  p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');
           END IF;

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- ******** GET TRY ID FOR Balance Write off ************* --

           -- Get the transaction id for adjustments
           OKL_AM_UTIL_PVT.get_transaction_id(
                   p_try_name           => 'Balance Write off',
                   x_return_status       => l_return_status,
                   x_try_id             => l_try_id);

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             -- Message: Unable to find a transaction type for
             -- the transaction TRY_NAME
             OKL_API.set_message(
                              p_app_name       => G_APP_NAME,
                              p_msg_name       => 'OKL_AM_NO_TRX_TYPE_FOUND',
                              p_token1         => 'TRY_NAME',
                              p_token1_value   => l_trans_meaning);
           END IF;

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- Get the meaning of lookup BALANCE_WRITE_OFF
           l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                   p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                   p_lookup_code => 'BALANCE_WRITE_OFF',
                                   p_validate_yn => 'Y');

           -- ******** GET PRODUCT ID ************* --

           -- get the product id
           OPEN  prod_id_csr(p_term_rec.p_contract_id);
           FETCH prod_id_csr INTO l_pdt_id;
           CLOSE prod_id_csr;

           -- raise error message if no pdt_id
           IF l_pdt_id IS NULL OR l_pdt_id = 0 THEN
             -- Error: Unable to create accounting entries because of a missing
             -- Product Type for the contract CONTRACT_NUMBER.
             OKL_API.set_message(
                               p_app_name    => G_APP_NAME,
                               p_msg_name    => 'OKL_AM_PRODUCT_ID_ERROR',
                               p_token1      => 'CONTRACT_NUMBER',
                               p_token1_value=> p_term_rec.p_contract_number);
           END IF;

           -- RMUNJULU 03-JAN-03 2683876 Added code to raise exception when
           -- no product id.
           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- RMUNJULU 03-JAN-03 2683876 Added code to Get
           -- the currency conversion parameters -- START

           -- Get the functional currency from AM_Util
           l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency;

           -- Get the currency conversion details from ACCOUNTING_Util
           OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id                 => p_term_rec.p_contract_id,
                     p_to_currency           => l_functional_currency_code,
                     p_transaction_date     => l_quote_accpt_date, -- rmunjulu EDAT
                     p_amount              => l_hard_coded_amount,
                     x_return_status              => l_return_status,
                     x_contract_currency    => l_contract_currency_code,
                     x_currency_conversion_type   => l_currency_conversion_type,
                     x_currency_conversion_rate   => l_currency_conversion_rate,
                     x_currency_conversion_date   => l_currency_conversion_date,
                     x_converted_amount     => l_converted_amount);


            -- If error from OKL_ACCOUNTING_UTIL
           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

              -- Error occurred when creating accounting entries for
              -- transaction TRX_TYPE.
              OKL_API.set_message(
                           p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_ERR_ACC_ENT',
                           p_token1        => 'TRX_TYPE',
                           p_token1_value  => l_trans_meaning);

           END IF;


           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- RMUNJULU 03-JAN-03 2683876 -- END

           -- ******** LOOP THRU AR INVOICES WHICH HAS BALANCES ************* --

           i := 1;
           FOR k_bal_lns_rec IN k_bal_lns_csr ( p_term_rec.p_contract_id,l_quote_eff_date) LOOP --rmunjulu EDAT

             -- RMUNJULU 28-APR-04 3596626
             -- Changed the processing, now do create Header, create line, do accounting, or else
             -- accounting engine will delete initial entries and will leave only
             -- one entry

             -- ******** CREATE A TRN LINE ************* --

             -- set the rec for adjsts lns
             lp_ajlv_rec.adj_id            :=   lx_adjv_rec.id;
             lp_ajlv_rec.til_id            :=   k_bal_lns_rec.til_id;

             IF  k_bal_lns_rec.tld_id <> -999
             AND k_bal_lns_rec.tld_id IS NOT NULL
             AND k_bal_lns_rec.tld_id <> OKL_API.G_MISS_NUM THEN
                 lp_ajlv_rec.tld_id          :=   k_bal_lns_rec.tld_id;
             END IF;

             lp_ajlv_rec.amount            :=   k_bal_lns_rec.amount;
             lp_ajlv_rec.psl_id            :=   k_bal_lns_rec.schedule_id;

             --call the txl_lns_adjsts
             OKL_TXL_ADJSTS_LNS_PUB.insert_txl_adjsts_lns(
                   p_api_version       => p_api_version,
                   p_init_msg_list     => OKL_API.G_FALSE,
                   x_return_status     => l_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   p_ajlv_rec            => lp_ajlv_rec,
                   x_ajlv_rec            => lx_ajlv_rec);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  -- Error occurred when creating adjustment records to write
                  -- off balances.
                  OKL_API.set_message( p_app_name     => G_APP_NAME,
                                       p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
             END IF;

             -- Raise exception to rollback this whole block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- ******** CREATE ACCOUNTING DISTRIBUTIONS ************* --

             -- do accounting entries to get code_combination_id
             -- Set the tmpl_identify_rec in parameter
             lp_tmpl_identify_rec.product_id          :=  l_pdt_id;
             lp_tmpl_identify_rec.transaction_type_id :=  l_try_id;
             lp_tmpl_identify_rec.memo_yn             :=  G_NO;
             lp_tmpl_identify_rec.prior_year_yn       :=  G_NO;
             lp_tmpl_identify_rec.stream_type_id      :=  k_bal_lns_rec.stream_type_id;

             -- Set the dist_info_rec in parameter
             lp_dist_info_rec.source_id           :=  lx_ajlv_rec.id; -- RMUNJULU 3596626
             lp_dist_info_rec.source_table        :=  'OKL_TXL_ADJSTS_LNS_B'; -- RMUNJULU 3596626
             lp_dist_info_rec.accounting_date     :=  l_quote_accpt_date; -- rmunjulu EDAT
             lp_dist_info_rec.gl_reversal_flag    :=  G_NO;
             lp_dist_info_rec.post_to_gl          :=  G_NO;
             lp_dist_info_rec.contract_id         :=  p_term_rec.p_contract_id;
             lp_dist_info_rec.amount              :=  k_bal_lns_rec.amount;

             -- RMUNJULU 03-JAN-03 2683876 Added code to set
             -- the currency conversion parameters -- START

             -- Set the p_dist_info_rec for currency code
             lp_dist_info_rec.currency_code := l_contract_currency_code;


             -- If the functional currency code is different
             -- from contract currency code
             -- then set the rest of the currency conversion columns
             IF l_functional_currency_code <> l_contract_currency_code THEN

                -- Set the p_dist_info_rec currency conversion columns
                lp_dist_info_rec.currency_conversion_type := l_currency_conversion_type;
                lp_dist_info_rec.currency_conversion_rate := l_currency_conversion_rate;
                lp_dist_info_rec.currency_conversion_date := l_currency_conversion_date;

            END IF;

            -- RMUNJULU 03-JAN-03 2683876 -- END

            -- RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
            -- for account generator

            OKL_ACC_CALL_PVT.okl_populate_acc_gen (
                           p_contract_id       => p_term_rec.p_contract_id,
                           p_contract_line_id  => NULL,
                           x_acc_gen_tbl       => lp_acc_gen_primary_key_tbl,
                           x_return_status     => l_return_status);

             -- Raise exception to rollback to savepoint for this block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- call accounting engine
             -- This will calculate the adjstmnts and generate accounting entries
             OKL_ACCOUNT_DIST_PUB.create_accounting_dist(
                p_api_version                  => p_api_version,
                p_init_msg_list                => OKL_API.G_FALSE,
                x_return_status                => l_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data,
                p_tmpl_identify_rec             => lp_tmpl_identify_rec,
                p_dist_info_rec                 => lp_dist_info_rec,
                p_ctxt_val_tbl                  => lp_ctxt_val_tbl,
                p_acc_gen_primary_key_tbl       => lp_acc_gen_primary_key_tbl,
                x_template_tbl                  => lx_template_tbl,
                x_amount_tbl                    => lx_amount_tbl);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

               -- Error occurred when creating accounting entries
               -- for transaction type TRX_TYPE and stream type STREAM_TYPE.
               OKL_API.set_message( p_app_name      => G_APP_NAME,
                                    p_msg_name      => 'OKL_AM_ERR_ACC_ENT_MSG',
                                    p_token1        => 'TRX_TYPE',
                                    p_token1_value  => l_trans_meaning,
                                    p_token2        => 'STREAM_TYPE',
                                    p_token2_value  => k_bal_lns_rec.stream_meaning);

             END IF;

             -- Raise exception to rollback this whole block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- ******** GET CCID FROM ACCOUNTING DISTRIBUTIONS ************* --

             -- Get the first code_combination_id for the transaction
             -- from OKL_TRNS_ACC_DSTRS_V
             OPEN  code_combination_id_csr(lx_ajlv_rec.id, 'OKL_TXL_ADJSTS_LNS_B'); -- RMUNJULU 3596626
             FETCH code_combination_id_csr INTO l_code_combination_id;
             CLOSE code_combination_id_csr;

             -- if code_combination_id not found then raise error
             IF l_code_combination_id = -1 OR l_code_combination_id IS NULL THEN

               -- Error: Unable to process small balance
               -- adjustments because of a missing Code Combination ID for the
               -- contract CONTRACT_NUMBER.
               OKL_API.set_message(
                               p_app_name    => G_APP_NAME,
                               p_msg_name    => 'OKL_AM_CODE_CMB_ERROR',
                               p_token1      => 'CONTRACT_NUMBER',
                               p_token1_value=> p_term_rec.p_contract_number);

               RAISE OKL_API.G_EXCEPTION_ERROR;

             END IF;

             -- ******** UPDATE TRN LINE WITH CCID ************* --

             lp_ajlv_rec := l_ajlv_rec; -- Empty the rec

             -- Set the rec with CCID got from accounting distibutions
             lp_ajlv_rec.id  := lx_ajlv_rec.id;
             lp_ajlv_rec.code_combination_id  :=   l_code_combination_id;

             lx_ajlv_rec := l_ajlv_rec; -- Empty the rec

             --call the txl_lns_adjsts
             OKL_TXL_ADJSTS_LNS_PUB.update_txl_adjsts_lns(
                   p_api_version       => p_api_version,
                   p_init_msg_list     => OKL_API.G_FALSE,
                   x_return_status     => l_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   p_ajlv_rec            => lp_ajlv_rec,
                   x_ajlv_rec            => lx_ajlv_rec);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  -- Error occurred when creating adjustment records to write
                  -- off balances.
                  OKL_API.set_message( p_app_name     => G_APP_NAME,
                                       p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
             END IF;

             -- Raise exception to rollback this whole block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

/*
             -- Get the first code_combination_id for the transaction
             -- from OKL_TRNS_ACC_DSTRS_V
             OPEN  code_combination_id_csr(lx_adjv_rec.id, 'OKL_TRX_AR_ADJSTS_B');
             FETCH code_combination_id_csr INTO l_code_combination_id;
             CLOSE code_combination_id_csr;

             -- if code_combination_id not found then raise error
             IF l_code_combination_id = -1 OR l_code_combination_id IS NULL THEN

               -- Error: Unable to process small balance
               -- adjustments because of a missing Code Combination ID for the
               -- contract CONTRACT_NUMBER.
               OKL_API.set_message(
                               p_app_name    => G_APP_NAME,
                               p_msg_name    => 'OKL_AM_CODE_CMB_ERROR',
                               p_token1      => 'CONTRACT_NUMBER',
                               p_token1_value=> p_term_rec.p_contract_number);

               RAISE OKL_API.G_EXCEPTION_ERROR;

             END IF;

             -- Loop thru the code combination ids to set the lns tbl
             FOR code_combination_id_rec
             IN  code_combination_id_csr (lx_adjv_rec.id, 'OKL_TRX_AR_ADJSTS_B') LOOP

               -- set the tbl for adjsts lns
               lp_ajlv_tbl(i).adj_id            :=   lx_adjv_rec.id;
               lp_ajlv_tbl(i).til_id            :=   k_bal_lns_rec.til_id;

               IF  k_bal_lns_rec.tld_id <> -999
               AND k_bal_lns_rec.tld_id IS NOT NULL
               AND k_bal_lns_rec.tld_id <> OKL_API.G_MISS_NUM THEN
                 lp_ajlv_tbl(i).tld_id          :=   k_bal_lns_rec.tld_id;
               END IF;

               lp_ajlv_tbl(i).amount            :=   k_bal_lns_rec.amount;
               lp_ajlv_tbl(i).psl_id            :=   k_bal_lns_rec.schedule_id;

               lp_ajlv_tbl(i).code_combination_id    :=   code_combination_id_rec.code_combination_id;

               i := i + 1;
             END LOOP; -- code combination recs
*/

          -- END LOOP; -- balances res

/*
           --call the txl_lns_adjsts
           OKL_TXL_ADJSTS_LNS_PUB.insert_txl_adjsts_lns(
               p_api_version                     => p_api_version,
               p_init_msg_list                   => OKL_API.G_FALSE,
               x_return_status                   => l_return_status,
               x_msg_count                       => x_msg_count,
               x_msg_data                        => x_msg_data,
               p_ajlv_tbl                        => lp_ajlv_tbl,
               x_ajlv_tbl                        => lx_ajlv_tbl);

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
             -- Error occurred when creating adjustment records to write
             -- off balances.
             OKL_API.set_message( p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
           END IF;

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
*/

/*           -- Get the currency code for contract
           l_currency_code  := OKL_AM_UTIL_PVT.get_chr_currency(
                                                      p_term_rec.p_contract_id);

           -- Set all success messages for all balances
           FOR k_bal_lns_rec IN k_bal_lns_csr ( p_term_rec.p_contract_id, l_quote_eff_date) LOOP -- rmunjulu EDAT

             -- Format the adjustment amt
             l_formatted_adj_amt  := OKL_ACCOUNTING_UTIL.format_amount(
                                                            k_bal_lns_rec.amount,
                                                            l_currency_code);

             -- Append adjustment amt with currency code
             l_formatted_adj_amt  := l_formatted_adj_amt || ' ' ||l_currency_code;

             -- Adjustment transaction for AR invoice AR_INVOICE_NUM of amount AMOUNT
             -- has been created.
             OKL_API.set_message(
                                p_app_name      => G_APP_NAME,
                                p_msg_name      => 'OKL_AM_ACC_ENT_AR_INV_MSG',
                                p_token1        => 'AR_INVOICE_NUM',
                                p_token1_value  => k_bal_lns_rec.ar_invoice_number,
                                p_token2        => 'AMOUNT',
                                p_token2_value  => l_formatted_adj_amt);

             -- Accounting entries created for transaction type TRX_TYPE
             -- and stream type STREAM_TYPE.
             OKL_API.set_message(
                                p_app_name      => G_APP_NAME,
                                p_msg_name      => 'OKL_AM_ACC_ENT_CREATED_MSG',
                                p_token1        => 'TRX_TYPE',
                                p_token1_value  => l_trans_meaning,
                                p_token2        => 'STREAM_TYPE',
                                p_token2_value  => k_bal_lns_rec.stream_meaning);
           END LOOP;

           -- store the highest degree of error
           set_overall_status(
               p_return_status                 => l_return_status,
               px_overall_status               => px_overall_status);

           -- set the transaction record
           set_transaction_rec(
               p_return_status                 => l_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
               p_tsu_code                      => 'WORKING',
               px_tcnv_rec                     => px_tcnv_rec);
         END IF;

      ELSE  --(cannot close all balances since tolerance amt is less)

        -- Unable to close all outstanding balances due to tolerance amount.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_ERR_CLOSE_BAL');

        -- Get the currency code for contract
        l_currency_code      := OKL_AM_UTIL_PVT.get_chr_currency(p_term_rec.p_contract_id);

        -- Format the balance amt
        l_formatted_bal_amt  := OKL_ACCOUNTING_UTIL.format_amount(l_total_amount_due,l_currency_code);

        -- Append balance amt with currency code
        l_formatted_bal_amt  := l_formatted_bal_amt || ' ' ||l_currency_code;

        -- Format the tolerance amt
        l_formatted_tol_amt  := OKL_ACCOUNTING_UTIL.format_amount(l_tolerance_amt,l_currency_code);

        -- Append tolerance amt with currency code
        l_formatted_tol_amt  := l_formatted_tol_amt || ' ' ||l_currency_code;

        -- Outstanding balance BALANCE_AMT exceeds Tolerance Amount TOLERANCE_AMT.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_BAL_GTR_TOL',
                             p_token1        => 'BALANCE_AMT',
                             p_token1_value  => l_formatted_bal_amt,
                             p_token2        => 'TOLERANCE_AMT',
                             p_token2_value  => l_formatted_tol_amt);

        -- store the highest degree of error
        -- Outstanding balances being greater than tolerance amt is nomore a
        -- HARD error, it is now a SOFT error
        set_overall_status(
               p_return_status                 => OKL_API.G_RET_STS_SUCCESS,
               px_overall_status               => px_overall_status);

        -- set the transaction record
        set_transaction_rec(
              p_return_status                 => OKL_API.G_RET_STS_SUCCESS,
              p_overall_status                => px_overall_status,
              p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
              p_tsu_code                      => 'WORKING',
              p_ret_val                       => NULL,
              px_tcnv_rec                     => px_tcnv_rec);
      END IF;
      END IF; -- rmunjulu BUYOUT_PROCESS
    END IF;
*/
    x_return_status      := l_return_status;
    x_adjv_rec           := lx_adjv_rec;
    --x_ajlv_tbl           := lx_ajlv_tbl;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF k_balances_csr%ISOPEN THEN
            CLOSE k_balances_csr;
         END IF;
         IF k_bal_lns_csr%ISOPEN THEN
            CLOSE k_bal_lns_csr;
         END IF;
         IF code_combination_id_csr%ISOPEN THEN
            CLOSE code_combination_id_csr;
         END IF;

         ROLLBACK TO close_balances;

         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

        -- Set the tmt_generic_flag3_yn
        set_transaction_rec(
                 p_return_status    => x_return_status,
                 p_overall_status   => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'ERROR',
                 px_tcnv_rec       => px_tcnv_rec);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

         IF k_balances_csr%ISOPEN THEN
            CLOSE k_balances_csr;
         END IF;
         IF k_bal_lns_csr%ISOPEN THEN
            CLOSE k_bal_lns_csr;
         END IF;
         IF code_combination_id_csr%ISOPEN THEN
            CLOSE code_combination_id_csr;
         END IF;

         ROLLBACK TO close_balances;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

        -- Set the tmt_generic_flag3_yn
        set_transaction_rec(
                 p_return_status    => x_return_status,
                 p_overall_status   => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'ERROR',
                 px_tcnv_rec       => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF k_balances_csr%ISOPEN THEN
            CLOSE k_balances_csr;
         END IF;
         IF k_bal_lns_csr%ISOPEN THEN
            CLOSE k_bal_lns_csr;
         END IF;
         IF code_combination_id_csr%ISOPEN THEN
            CLOSE code_combination_id_csr;
         END IF;

         ROLLBACK TO close_balances;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_CLOSE_BALANCES_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

        -- Set the tmt_generic_flag3_yn
        set_transaction_rec(
                 p_return_status    => x_return_status,
                 p_overall_status   => px_overall_status,
                 p_tmt_flag        => 'TMT_GENERIC_FLAG3_YN',
                 p_tsu_code        => 'ERROR',
                 px_tcnv_rec       => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_close_balances;



  -- Start of comments
  --
  -- Procedure Name : process_accounting_entries
  -- Desciption     : Calls the Accounting engine to do the accounting entries
  -- Business Rules :
  -- Parameters     :
  -- Version     : 1.0
  -- History        : RMUNJULU 23-DEC-02 2726739 Added code for Multi-Currency settings
  --                : RMUNJULU Bug # 3023206 27-JUN-03 Increment the line number before the exit
  --                  to avoid duplicate line numbers when creating accnting transaction lines
  --                : RMUNJULU Bug # 2902876 23-JUL-03 Added code to pass valid GL date to GET_TEMPLATE_INFO
  --                : RMUNJULU Bug # 3097068 20-AUG-03 Added code to pass valid GL date to REVERSE LOSS PROVISIONS
  --                : RMUNJULU Bug # 3148215 19-SEP-03 Added code to pass valid GL date to CATCHUP OF ACCRUALS
  --
  --                : SMODUGA Bug # 3061772 21-OCT-03 Added call to process_discount_subsidy
  --                : MDOKAL  Bug # 3061765 21-OCT-03 Added IDC acceleration for Financed Fee's
  --                : SMODUGA Bug # 3061772 22-OCT-03 Moved call to process_discount_subsidy to end before success messages.
  --                : MDOKAL  Bug # 3061765 22-OCT-03 Added date validation for accruals acceleration
  --                : RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
  --                : rmunjulu EDAT Added code to pass quote accpt date as accounting date
  --                  Also added code for reversal of accruals
  --                : rmunjulu TNA Modified call to process_adjustments
  --                : rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
  --                : rmunjulu Bug 4162862 and Bug 4141991 Modify to do accounting on contract end date if no term quote. Also
  --                  provide a new parameter p_source which tells where the request is coming from. Act based on this new source
  --                : pagarg 01-Mar-05 Bug 4190887 Modified to do accounting for
  --                  each line, inorder to set KLE_ID in OKL_TXL_CNTRCT_LNS table
  --                : rmunjulu 4416094 pass interest income sty id for loans when doing acceleration of income
  --                : rmunjulu 4507662 pass proper date for reverse from when calling reversal of accruals
  --                : rmunjulu 4424713 check for product before getting stream type ids
  --                : rmunjulu LOANS_ENHANCEMENTS refund excess loan payments
  --                : akrangan 5514059 During termination, do accounting for asset, fees and service lines.
  --                : rbruno 7248153 FP:ACCELERATED IDC EXPENSE IS NOT CORRECT FOR TERMINATED CONTRACTS
  -- End of comments
PROCEDURE process_accounting_entries(p_api_version     IN NUMBER,
                                     p_init_msg_list   IN VARCHAR2,
                                     x_return_status   OUT NOCOPY VARCHAR2,
                                     x_msg_count       OUT NOCOPY NUMBER,
                                     x_msg_data        OUT NOCOPY VARCHAR2,
                                     p_term_rec        IN term_rec_type,
                                     px_overall_status IN OUT NOCOPY VARCHAR2,
                                     px_tcnv_rec       IN OUT NOCOPY tcnv_rec_type,
                                     p_sys_date        IN DATE,
                                     p_klev_tbl        IN klev_tbl_type, -- pagarg 4190887 Added
                                     p_trn_already_set IN VARCHAR2,
                                     p_source          IN VARCHAR2 DEFAULT NULL) IS
  -- rmunjulu Bug 4141991

  -- Cursor to get the product of the contract
  -- rmunjulu Bug 4162862 Modified to get contract end date
  CURSOR prod_id_csr(p_khr_id IN NUMBER) IS
    SELECT khr.pdt_id,
           chr.end_date, -- rmunjulu Bug 4162862
           khr.deal_type, -- rmunjulu bug 4424713
           chr.scs_code -- rmunjulu 4622198
           ,chr.org_id  --akrangan added for sla ae uptake cr
           ,khr.multi_gaap_yn  --MGAAP 7263041
           ,pdt.reporting_pdt_id  --MGAAP 7263041
    FROM   okl_k_headers_v khr,
           okc_k_headers_b chr, -- rmunjulu Bug 4162862
           okl_products pdt
    WHERE  khr.id = p_khr_id AND khr.id = chr.id -- rmunjulu Bug 4162862
    AND    khr.pdt_id = pdt.ID;  -- MGAAP 7263041

  -- Get the product type
  CURSOR l_product_type_csr(p_pdt_id IN NUMBER) IS
    SELECT description FROM okl_products_v WHERE id = p_pdt_id;

  l_return_status            VARCHAR2(1) := okl_api.g_ret_sts_success;
  l_api_name                 VARCHAR2(30) := 'process_accounting_entries';
  l_pdt_id                   NUMBER := 0;

  -- MGAAP 7263041 start
  l_reporting_pdt_id      NUMBER                                     := 0;
  l_multi_gaap_yn      okl_k_headers.MULTI_GAAP_YN%TYPE              := null;
  l_valid_gl_date_rep     DATE;
  l_sob_id_rep            NUMBER;
  -- MGAAP 7263041 end

  l_try_id                   NUMBER;
  lp_tmpl_identify_rec       okl_account_dist_pub.tmpl_identify_rec_type;
  lp_dist_info_rec           okl_account_dist_pub.dist_info_rec_type;
  lp_ctxt_val_tbl            okl_account_dist_pub.ctxt_val_tbl_type;
  lp_acc_gen_primary_key_tbl okl_account_dist_pub.acc_gen_primary_key;
  lx_template_tbl            okl_account_dist_pub.avlv_tbl_type;
  lx_amount_tbl              okl_account_dist_pub.amount_tbl_type;
  lx_tcnv_tbl                okl_trx_contracts_pub.tcnv_tbl_type;
  l_catchup_rec              okl_generate_accruals_pub.accrual_rec_type;
  l_lprv_rec                 okl_rev_loss_prov_pub.lprv_rec_type;
  l_trans_meaning            VARCHAR2(200);
  lp_tclv_rec                okl_trx_contracts_pub.tclv_rec_type;
  lx_tclv_rec                okl_trx_contracts_pub.tclv_rec_type;
  li_tclv_rec                okl_trx_contracts_pub.tclv_rec_type;
  i                          NUMBER;
  l_total_amount             NUMBER := 0;
  lip_tmpl_identify_rec      okl_account_dist_pub.tmpl_identify_rec_type;
  lix_template_tbl           okl_account_dist_pub.avlv_tbl_type;
  lip_tcnv_rec               okl_trx_contracts_pub.tcnv_rec_type;
  lix_tcnv_rec               okl_trx_contracts_pub.tcnv_rec_type;
  l_product_type             VARCHAR2(2000);
  l_line_number              NUMBER := 1;

  -- RMUNJULU 23-DEC-02 2726739 Added variables
  l_functional_currency_code VARCHAR2(15);
  l_contract_currency_code   VARCHAR2(15);
  l_currency_conversion_type VARCHAR2(30);
  l_currency_conversion_rate NUMBER;
  l_currency_conversion_date DATE;
  l_converted_amount         NUMBER;

  -- Since we do not use the amount or converted amount
  -- set a hardcoded value for the amount (and pass to to
  -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
  -- conversion values )
  l_hard_coded_amount NUMBER := 100;

  -- Bug 2902876
  l_valid_gl_date DATE;

  -- SMODUGA added variable for userdefined streams 3925469
  lx_sty_id             NUMBER;
  lx_sty_id_rep         NUMBER; -- MGAAP 7263041
  l_trx_number OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE;  -- MGAAP 7263041
  lx_pretax_sty_id      NUMBER;
  lx_rentaccrual_sty_id NUMBER;

  -- MDOKAL Bug 3061765
  -- Cursor to get amoritized expense streams for IDC acceleration
  -- SMODUGA 11-Oct-04 Bug 3925469
  -- Modified cursor by passing sty_id based on the purspose and
  -- removed reference to stream type view.
  CURSOR idc_accel_csr(p_khr_id IN NUMBER, p_sty_id IN NUMBER,p_kle_id IN Number) IS
    SELECT okl_line.fee_type fee_type
    FROM   okl_k_lines       okl_line,
           okc_k_lines_b     okc_line,
           okc_line_styles_b lse,
           okl_streams       stm
    WHERE  okl_line.id     = okc_line.id AND
           okc_line.lse_id = lse.id AND lse.lty_code = 'FEE' AND
           okc_line.chr_id = p_khr_id AND
           stm.khr_id      = okc_line.chr_id AND
           stm.kle_id      = okc_line.id AND
           stm.sty_id      = p_sty_id AND
           stm.active_yn   = 'Y' AND
           stm.say_code    = 'CURR' AND
           okc_line.id     = P_kle_id;   -- Parameter added by ansethur for bug#6156337

-- ansethur for bug#6156337 08-aug-07 start
        CURSOR primary_sty_id_csr (p_khr_id IN NUMBER) IS
        SELECT sty.id Primary_sty_id, sty.code,okc_line.id kle_id
          FROM okc_k_lines_b okc_line,
               okc_line_styles_b lse,
               okc_k_items item,
               okl_strm_type_b sty
         WHERE okc_line.dnz_chr_id = p_khr_id
           AND okc_line.lse_id = lse.id
           AND lse.lty_code = 'FEE'
           AND item.cle_id = okc_line.id
           AND item.JTOT_OBJECT1_CODE = 'OKL_STRMTYP'
           AND item.OBJECT1_ID2 = '#'
           AND item.OBJECT1_ID1 = sty.id
           AND sty.STREAM_TYPE_PURPOSE = 'EXPENSE';
-- ansethur for bug#6156337 08-aug-07 end

  -- MDOKAL Bug 3061765
  -- Cursor to get accelerate till date from contract income stream
  -- SMODUGA 11-Oct-04 Bug 3925469
  -- Modified cursor by passing sty_id based on the purspose and
  -- removed reference to stream type view.

  -- Bug#7248153 - rbruno - commented - Start
   /*
  -- -- rmunjulu bug 4416094
  CURSOR get_accel_till_csr(p_khr_id IN NUMBER, p_pretax_sty_id IN NUMBER, p_rentaccrual_sty_id IN NUMBER, p_interestincome_sty_id IN NUMBER) IS
    SELECT MAX(stream_element_date)
    FROM   okl_strm_elements_v sel,
           okl_streams         stm
    WHERE  sel.stm_id = stm.id AND
           stm.sty_id IN (p_pretax_sty_id, p_rentaccrual_sty_id,
            p_interestincome_sty_id) AND stm.khr_id = p_khr_id;
            */
   -- Bug#7248153 - rbruno - commented - End

   -- Bug#7248153 - rbruno - changed - Start

   CURSOR get_accel_till_csr(p_khr_id IN NUMBER, p_sty_id IN NUMBER) IS
    SELECT MAX(stream_element_date)
    FROM   okl_strm_elements_v sel,
           okl_streams         stm
    WHERE  sel.stm_id = stm.id AND
           stm.sty_id = p_sty_id AND stm.khr_id = p_khr_id;

  -- Bug#7248153 - rbruno - changed - End

  -- MDOKAL Bug 3061765
  -- data structure used for calling accruals acceleration
  l_acceleration_rec okl_generate_accruals_pvt.acceleration_rec_type;

  -- MDOKAL Bug 3061765
  -- new parameter declarations
  l_accelerate_till_date DATE;

  -- rmunjulu EDAT
  l_quote_accpt_date      DATE;
  l_quote_eff_date        DATE;
  l_empty_tcn_type        VARCHAR2(30);
  l_empty_reverse_to_date DATE;

  -- rmunjulu 4141991 Cursor to get the product of the contract
  CURSOR get_k_sts_csr(p_khr_id IN NUMBER) IS
    SELECT chr.sts_code
    FROM   okc_k_headers_b chr
    WHERE  chr.id = p_khr_id;

  -- rmunjulu 4141991
  l_k_sts VARCHAR2(300);

  -- rmunjulu Bug 4162862
  l_k_end_date DATE;

  -- pagarg 01-Mar-05 Bug 4190887: counter to loop through asset table
  asset_counter NUMBER;

  -- rmunjulu bug 4416094
  lx_interestincome_sty_id NUMBER;

  -- rmunjulu bug 4507662
  l_reverse_from DATE;

  -- rmunjulu 4424713
  l_deal_type VARCHAR2(150);

  -- rmunjulu 4622198
  l_scs_code       okc_k_headers_b.scs_code%TYPE;
  l_fact_synd_code fnd_lookups.lookup_code%TYPE;
  l_inv_acct_code  okc_rules_b.rule_information1%TYPE;

  --rmunjulu 4769094
  CURSOR check_accrual_previous_csr IS
    SELECT nvl(chk_accrual_previous_mnth_yn, 'N')
    FROM   okl_system_params;

  --rmunjulu 4769094
  l_accrual_previous_mnth_yn VARCHAR2(3);
  --akrangan Bug 5514059 start
  -- Cursor to get asset, fee and service lines in a contract.
  CURSOR k_asst_fee_srvc_lns_csr(p_khr_id IN NUMBER) IS
    SELECT oklv.id   kle_id,
           oklv.NAME asset_name
    FROM   okc_k_lines_v     oklv,
           okc_line_styles_v olsv,
           okc_k_headers_v   khr
    WHERE  oklv.chr_id = p_khr_id AND oklv.lse_id = olsv.id AND
           olsv.lty_code IN
           ('FREE_FORM1', 'FEE', 'SOLD_SERVICE') AND
           oklv.chr_id = khr.id AND oklv.sts_code = khr.sts_code;

  k_asst_fee_srvc_lns_rec k_asst_fee_srvc_lns_csr%ROWTYPE;
  --akrangan Bug 5514059 end
  --akrangan sla single accounting call to ae uptake starts
  l_org_id                   NUMBER(15);
  --txl contracts specific tbl types
  l_tclv_tbl  okl_trx_contracts_pub.tclv_tbl_type;
  lx_tclv_tbl okl_trx_contracts_pub.tclv_tbl_type;
  --ae new table types declaration
  l_tmpl_identify_tbl okl_account_dist_pvt.tmpl_identify_tbl_type;
  l_dist_info_tbl     okl_account_dist_pvt.dist_info_tbl_type;
  l_ctxt_tbl          okl_account_dist_pvt.ctxt_tbl_type;
  l_template_out_tbl  okl_account_dist_pvt.avlv_out_tbl_type;
  l_amount_out_tbl    okl_account_dist_pvt.amount_out_tbl_type;
  l_acc_gen_tbl       okl_account_dist_pvt.acc_gen_tbl_type;
  l_tcn_id            NUMBER;

  --hdr dff fields cursor
  --this cursor is to populate the
  -- desc flex fields columns in okl_trx_contracts
  CURSOR trx_contracts_dff_csr(p_khr_id IN NUMBER) IS
    SELECT attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   okl_k_headers okl
    WHERE  okl.id = p_khr_id;
  --line dff fields cursor
  --this cursor is to populate the
  -- desc flex fields columns in okl_txl_xontract_lines_b
  CURSOR txl_contracts_dff_csr(p_kle_id IN NUMBER) IS
    SELECT attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM   okl_k_lines okl
    WHERE  okl.id = p_kle_id;
  --record for storing okl_k_lines dffs and linked assets cle_id
  TYPE dff_rec_type IS RECORD(
    attribute_category okl_k_lines.attribute_category%TYPE,
    attribute1         okl_k_lines.attribute1%TYPE,
    attribute2         okl_k_lines.attribute2%TYPE,
    attribute3         okl_k_lines.attribute3%TYPE,
    attribute4         okl_k_lines.attribute4%TYPE,
    attribute5         okl_k_lines.attribute5%TYPE,
    attribute6         okl_k_lines.attribute6%TYPE,
    attribute7         okl_k_lines.attribute7%TYPE,
    attribute8         okl_k_lines.attribute8%TYPE,
    attribute9         okl_k_lines.attribute9%TYPE,
    attribute10        okl_k_lines.attribute10%TYPE,
    attribute11        okl_k_lines.attribute11%TYPE,
    attribute12        okl_k_lines.attribute12%TYPE,
    attribute13        okl_k_lines.attribute13%TYPE,
    attribute14        okl_k_lines.attribute14%TYPE,
    attribute15        okl_k_lines.attribute15%TYPE);
  txl_contracts_dff_rec dff_rec_type;
  --product name and tax owner
  CURSOR product_name_csr(p_pdt_id IN NUMBER) IS
    SELECT NAME,
           tax_owner
    FROM   okl_product_parameters_v
    WHERE  id = p_pdt_id;
  l_currency_code            okl_trx_contracts.currency_code%TYPE;
  --loop variables
  j NUMBER;
  k NUMBER;
  l NUMBER;
  m NUMBER;
  --akrangan sla single accounting call to ae uptake ends
  -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_accounting_entries';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

  -- Start savepoint for this block
  SAVEPOINT accounting_entries;

  -- get the product id
  OPEN prod_id_csr(p_term_rec.p_contract_id);
  FETCH prod_id_csr
    INTO l_pdt_id, l_k_end_date, l_deal_type, l_scs_code,l_org_id, -- rmunjulu Bug 4162862 Added -- rmunjulu 4424713 -- rmunjulu 4622198
         l_multi_gaap_yn, l_reporting_pdt_id;  -- MGAAP 7263041
  CLOSE prod_id_csr;

  -- ********************
  -- CHECK PRODUCT ID
  -- ********************

  -- raise error if no pdt_id
  IF l_pdt_id IS NULL OR l_pdt_id = 0
  THEN

    -- Error: Unable to create accounting entries because of a missing
    -- Product Type for the contract CONTRACT_NUMBER.
    okl_api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_AM_PRODUCT_ID_ERROR',
                        p_token1       => 'CONTRACT_NUMBER',
                        p_token1_value => p_term_rec.p_contract_number);

    RAISE okl_api.g_exception_error;

  END IF;
  IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,' l_pdt_id = '||l_pdt_id);
  END IF;
  -- get the product type
  OPEN l_product_type_csr(l_pdt_id);
  FETCH l_product_type_csr
    INTO l_product_type;
  CLOSE l_product_type_csr;

  -- If accounting entries needed
  IF (p_trn_already_set = g_yes AND
     nvl(px_tcnv_rec.tmt_accounting_entries_yn, '?') <> g_yes) OR
     (p_trn_already_set = g_no)
  THEN

    -- RMUNJULU 3018641 Step Message
    -- Step : Accounting Entries
    okl_api.set_message(p_app_name => g_app_name,
                        p_msg_name => 'OKL_AM_STEP_ACT');

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

    -- rmunjulu EDAT
    -- If quote exists then accnting date is quote accept date else sysdate
    IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
    THEN

      l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
      l_quote_eff_date   := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

    ELSE

      l_quote_accpt_date := l_k_end_date; -- rmunjulu Bug 4162862 Changed to contract end date
      l_quote_eff_date   := l_k_end_date; -- rmunjulu Bug 4162862 Changed to contract end date

    END IF;

    -- rmunjulu EDAT
    -- set the additional parameters with contract_id, quote_id and transaction_date
    -- to be passed to formula engine

    lp_ctxt_val_tbl(1).NAME := 'contract_id';
    lp_ctxt_val_tbl(1).VALUE := p_term_rec.p_contract_id;

    lp_ctxt_val_tbl(2).NAME := 'quote_id';
    lp_ctxt_val_tbl(2).VALUE := p_term_rec.p_quote_id;

    lp_ctxt_val_tbl(3).NAME := 'transaction_date';
    lp_ctxt_val_tbl(3).VALUE := to_char(l_quote_accpt_date,
                                        'MM/DD/YYYY'); -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

    -- ********************
    -- GET TEMPLATES
    -- ********************

    -- Get the meaning of lookup
    l_trans_meaning := okl_am_util_pvt.get_lookup_meaning(p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                                          p_lookup_code => 'TERMINATION',
                                                          p_validate_yn => 'Y');

    -- Set the tmpl_identify_rec in parameter to get accounting templates for the product
    lip_tmpl_identify_rec.product_id          := l_pdt_id;
    lip_tmpl_identify_rec.transaction_type_id := px_tcnv_rec.try_id;
    lip_tmpl_identify_rec.memo_yn             := g_no;
    lip_tmpl_identify_rec.prior_year_yn       := g_no;

    -- Bug 2902876 Added to get the valid GL date
    l_valid_gl_date := okl_accounting_util.get_valid_gl_date(p_gl_date => l_quote_accpt_date); -- rmunjulu EDAT

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling okl_securitization_pvt.check_khr_ia_associated');
    END IF;
    -- rmunjulu 4622198 SPECIAL_ACCNT Get special accounting details
    okl_securitization_pvt.check_khr_ia_associated(p_api_version    => p_api_version,
                                                   p_init_msg_list  => okl_api.g_false,
                                                   x_return_status  => l_return_status,
                                                   x_msg_count      => x_msg_count,
                                                   x_msg_data       => x_msg_data,
                                                   p_khr_id         => p_term_rec.p_contract_id,
                                                   p_scs_code       => l_scs_code,
                                                   p_trx_date       => l_quote_accpt_date,
                                                   x_fact_synd_code => l_fact_synd_code,
                                                   x_inv_acct_code  => l_inv_acct_code);
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called okl_securitization_pvt.check_khr_ia_associated l_return_status = '||l_return_status);
    END IF;

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- rmunjulu 4622198 SPECIAL_ACCNT set the special accounting parameters
    lip_tmpl_identify_rec.factoring_synd_flag := l_fact_synd_code;
    lip_tmpl_identify_rec.investor_code       := l_inv_acct_code;

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling okl_account_dist_pub.get_template_info');
    END IF;
    -- Get the accounting templates
    okl_account_dist_pub.get_template_info(p_api_version       => p_api_version,
                                           p_init_msg_list     => okl_api.g_false,
                                           x_return_status     => l_return_status,
                                           x_msg_count         => x_msg_count,
                                           x_msg_data          => x_msg_data,
                                           p_tmpl_identify_rec => lip_tmpl_identify_rec,
                                           x_template_tbl      => lix_template_tbl,
                                           p_validity_date     => l_valid_gl_date); -- Bug 2902876 Added to pass valid GL date
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called okl_account_dist_pub.get_template_info l_return_status = '||l_return_status);
    END IF;

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN

      -- No accounting templates found matching the transaction type TRX_TYPE
      -- and product  PRODUCT.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_NO_ACC_TEMPLATES',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning,
                          p_token2       => 'PRODUCT',
                          p_token2_value => l_product_type);

    END IF;

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_functional_currency_code := okl_am_util_pvt.get_functional_currency();
    --akrangan Bug 6147049 code fix start
    --call functional currency conversion only
    --if functional currency and contract currency are not same
    l_currency_code := okl_am_util_pvt.get_chr_currency(p_term_rec.p_contract_id);
    IF l_functional_currency_code IS NOT NULL AND
       l_functional_currency_code <>  l_currency_code
    THEN
    --akrangan Bug 6147049 code fix end
    -- Get the currency conversion details from ACCOUNTING_Util
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling okl_accounting_util.convert_to_functional_currency');
    END IF;
    okl_accounting_util.convert_to_functional_currency(
                           p_khr_id                   => p_term_rec.p_contract_id,
                           p_to_currency              => l_functional_currency_code,
                           p_transaction_date         => l_quote_accpt_date, -- rmunjulu EDAT
                           p_amount                   => l_hard_coded_amount,
                           x_return_status            => l_return_status,
                           x_contract_currency        => l_contract_currency_code,
                           x_currency_conversion_type => l_currency_conversion_type,
                           x_currency_conversion_rate => l_currency_conversion_rate,
                           x_currency_conversion_date => l_currency_conversion_date,
                           x_converted_amount         => l_converted_amount
                                                      );
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called okl_accounting_util.convert_to_functional_currency l_return_status = '||l_return_status);
    END IF;
    -- If error from OKL_ACCOUNTING_UTIL
    IF l_return_status <> okl_api.g_ret_sts_success
    THEN

      -- Error occurred when creating accounting entries for
      -- transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;
    --akrangan Bug 6147049 code fix start
    END IF;
    --akrangan Bug 6147049 code fix end
    -- If no templates present
    IF lix_template_tbl.COUNT = 0
    THEN

      -- No accounting templates found matching the transaction type TRX_TYPE
      -- and product  PRODUCT.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_NO_ACC_TEMPLATES',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning,
                          p_token2       => 'PRODUCT',
                          p_token2_value => l_product_type);

      RAISE okl_api.g_exception_error;

    END IF;

    -- *****************************
    -- CREATE TXL_CNTRCT LINES
    -- ****************************
    -- currency operations related variables assigned
    l_currency_code            := NVL(l_contract_currency_code,l_currency_code);
    j := 1 ;
   --looping thru the templates to set line records and template identify tbl
    i := lix_template_tbl.FIRST; -- at this point we know that there are some templates
    LOOP
      -- Loop thru templates
      FOR k_asst_fee_srvc_lns_rec IN k_asst_fee_srvc_lns_csr(p_term_rec.p_contract_id)
      LOOP
        -- set the TXL_CNTRCT Line details for template
        l_tclv_tbl(j).line_number := l_line_number;
        l_tclv_tbl(j).khr_id := p_term_rec.p_contract_id;
        l_tclv_tbl(j).tcn_id := px_tcnv_rec.id;
        l_tclv_tbl(j).sty_id := lix_template_tbl(i).sty_id;
        l_tclv_tbl(j).tcl_type := 'TMT';
        l_tclv_tbl(j).currency_code := l_currency_code;
        l_tclv_tbl(j).kle_id := k_asst_fee_srvc_lns_rec.kle_id;
	l_tclv_tbl(j).org_id := l_org_id;
        FOR txl_contracts_dff_rec IN txl_contracts_dff_csr( k_asst_fee_srvc_lns_rec.kle_id)
        LOOP
            --set dffs
            l_tclv_tbl(j).attribute_category := txl_contracts_dff_rec.attribute_category;
            l_tclv_tbl(j).attribute1 := txl_contracts_dff_rec.attribute1;
            l_tclv_tbl(j).attribute2 := txl_contracts_dff_rec.attribute2;
            l_tclv_tbl(j).attribute3 := txl_contracts_dff_rec.attribute3;
            l_tclv_tbl(j).attribute4 := txl_contracts_dff_rec.attribute4;
            l_tclv_tbl(j).attribute5 := txl_contracts_dff_rec.attribute5;
            l_tclv_tbl(j).attribute6 := txl_contracts_dff_rec.attribute6;
            l_tclv_tbl(j).attribute7 := txl_contracts_dff_rec.attribute7;
            l_tclv_tbl(j).attribute8 := txl_contracts_dff_rec.attribute8;
            l_tclv_tbl(j).attribute9 := txl_contracts_dff_rec.attribute9;
            l_tclv_tbl(j).attribute10 := txl_contracts_dff_rec.attribute10;
            l_tclv_tbl(j).attribute11 := txl_contracts_dff_rec.attribute11;
            l_tclv_tbl(j).attribute12 := txl_contracts_dff_rec.attribute12;
            l_tclv_tbl(j).attribute13 := txl_contracts_dff_rec.attribute13;
            l_tclv_tbl(j).attribute14 := txl_contracts_dff_rec.attribute14;
            l_tclv_tbl(j).attribute15 := txl_contracts_dff_rec.attribute15;
        END LOOP;

      -- This will calculate the amount and generate accounting entries
      -- Set the tmpl_identify_tbl in parameter
      l_tmpl_identify_tbl(j).product_id := l_pdt_id;
      l_tmpl_identify_tbl(j).transaction_type_id := px_tcnv_rec.try_id;
      l_tmpl_identify_tbl(j).memo_yn := g_no;
      l_tmpl_identify_tbl(j).prior_year_yn := g_no;
      l_tmpl_identify_tbl(j).stream_type_id := lix_template_tbl(i).sty_id;
      l_tmpl_identify_tbl(j).advance_arrears := lix_template_tbl(i).advance_arrears;
      l_tmpl_identify_tbl(j).factoring_synd_flag := lix_template_tbl(i).factoring_synd_flag;
      l_tmpl_identify_tbl(j).investor_code := lix_template_tbl(i).inv_code;
      l_tmpl_identify_tbl(j).syndication_code := lix_template_tbl(i).syt_code;
      l_tmpl_identify_tbl(j).factoring_code := lix_template_tbl(i).fac_code;
        --increment looping variable
	j := j + 1;
	--increment line number
        l_line_number := l_line_number + 1;
       END LOOP;
      EXIT WHEN(i = lix_template_tbl.LAST);
      i := lix_template_tbl.NEXT(i);
    END LOOP;
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling okl_trx_contracts_pub.create_trx_cntrct_lines');
    END IF;
    --create trx contract lines table
    okl_trx_contracts_pub.create_trx_cntrct_lines(p_api_version   => p_api_version,
                                                  p_init_msg_list => okl_api.g_false,
                                                  x_return_status => l_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_tclv_tbl      => l_tclv_tbl,
                                                  x_tclv_tbl      => lx_tclv_tbl);
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called okl_trx_contracts_pub.create_trx_cntrct_lines l_return_status = '||l_return_status);
    END IF;

    -- If error inserting line then set message
    IF l_return_status <> okl_api.g_ret_sts_success
    THEN

      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --setting the input table type to the obtained outout table type
    l_tclv_tbl := lx_tclv_tbl;

    -- ***************************
    -- POPULATE ACC GEN PRIMARY KEY TABLE
    -- ******************************
    -- added code to set lp_acc_gen_primary_key_tbl
    -- for account generator
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_acc_call_pvt.okl_populate_acc_gen');
    END IF;
    okl_acc_call_pvt.okl_populate_acc_gen(p_contract_id      => p_term_rec.p_contract_id,
                                          p_contract_line_id => NULL,
                                          x_acc_gen_tbl      => lp_acc_gen_primary_key_tbl,
                                          x_return_status    => l_return_status);
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called okl_acc_call_pvt.okl_populate_acc_gen l_return_status = '||l_return_status);
    END IF;
    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);
    END IF;
    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- *********************************************
    -- Accounting Engine Call
    -- *********************************************
    --txl contracts loop
    IF l_tclv_tbl.COUNT <> 0
    THEN
      i := l_tclv_tbl.FIRST;
      LOOP
        --Assigning the account generator table
        l_acc_gen_tbl(i).acc_gen_key_tbl := lp_acc_gen_primary_key_tbl;
        l_acc_gen_tbl(i).source_id := l_tclv_tbl(i).id;
        --populating dist info tbl
        l_dist_info_tbl(i).source_id := l_tclv_tbl(i).id;
        l_dist_info_tbl(i).source_table := 'OKL_TXL_CNTRCT_LNS';
        l_dist_info_tbl(i).accounting_date := l_quote_accpt_date;
        l_dist_info_tbl(i).gl_reversal_flag := g_no;
        l_dist_info_tbl(i).post_to_gl := g_yes;
        l_dist_info_tbl(i).contract_id := l_tclv_tbl(i).khr_id;
        l_dist_info_tbl(i).contract_line_id := l_tclv_tbl(i).kle_id;
        l_dist_info_tbl(i).currency_code := l_currency_code;
        IF ((l_functional_currency_code IS NOT NULL) AND
           (l_currency_code <> l_functional_currency_code))
        THEN
          l_dist_info_tbl(i).currency_conversion_rate := l_currency_conversion_rate;
          l_dist_info_tbl(i).currency_conversion_type := l_currency_conversion_type;
          l_dist_info_tbl(i).currency_conversion_date := l_currency_conversion_date;
        END IF;
	--form context val table
	IF lp_ctxt_val_tbl.COUNT > 0 THEN
	 l_ctxt_tbl(i).ctxt_val_tbl  := lp_ctxt_val_tbl;
         l_ctxt_tbl(i).source_id := l_tclv_tbl(i).id;
	END IF;
        EXIT WHEN i = l_tclv_tbl.LAST;
        i := l_tclv_tbl.NEXT(i);
      END LOOP;
    END IF;
    l_tcn_id := px_tcnv_rec.id;
    -- call accounting engine
    -- This will calculate the amount and generate accounting entries
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_account_dist_pvt.create_accounting_dist');
    END IF;
    okl_account_dist_pvt.create_accounting_dist(p_api_version             => p_api_version,
                                                p_init_msg_list           => okl_api.g_false,
                                                x_return_status           => l_return_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                                p_dist_info_tbl           => l_dist_info_tbl,
                                                p_ctxt_val_tbl            => l_ctxt_tbl,
                                                p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                                x_template_tbl            => l_template_out_tbl,
                                                x_amount_tbl              => l_amount_out_tbl,
                                                p_trx_header_id           => l_tcn_id);
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_account_dist_pvt.create_accounting_dist l_return_status = '||l_return_status);
    END IF;

    IF l_amount_out_tbl.COUNT = 0
    THEN
      l_return_status := okl_api.g_ret_sts_error;
    END IF;

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ******************************************************
    --   Update Trx Contracts with Header and Line Amounts
    -- ******************************************************

    --call the update trx contract api to update amount per stream type
    lip_tcnv_rec := px_tcnv_rec;
    --set all the necessary attributes of the record type
    lip_tcnv_rec.amount          := 0;
    lip_tcnv_rec.set_of_books_id := okl_accounting_util.get_set_of_books_id();
    --akrangan bug 6147049 fix start
    lip_tcnv_rec.currency_conversion_rate := l_currency_conversion_rate;
    lip_tcnv_rec.currency_conversion_type := l_currency_conversion_type;
    lip_tcnv_rec.currency_conversion_date := l_currency_conversion_date;
    --akrangan bug 6147049 fix end
    --akrangan bug 6215707 fix start
    lip_tcnv_rec.tsu_code := 'PROCESSED';
    --akrangan bug 6215707 fix end
    --product name and tax owner code
    OPEN product_name_csr(l_pdt_id);
    FETCH product_name_csr
      INTO lip_tcnv_rec.product_name, lip_tcnv_rec.tax_owner_code;
    CLOSE product_name_csr;

   --trx contracts hdr dffs
    OPEN trx_contracts_dff_csr(p_term_rec.p_contract_id);
    FETCH trx_contracts_dff_csr
      INTO lip_tcnv_rec.attribute_category, lip_tcnv_rec.attribute1,
           lip_tcnv_rec.attribute2, lip_tcnv_rec.attribute3,
           lip_tcnv_rec.attribute4, lip_tcnv_rec.attribute5,
           lip_tcnv_rec.attribute6, lip_tcnv_rec.attribute7,
           lip_tcnv_rec.attribute8, lip_tcnv_rec.attribute9,
           lip_tcnv_rec.attribute10, lip_tcnv_rec.attribute11,
           lip_tcnv_rec.attribute12, lip_tcnv_rec.attribute13,
           lip_tcnv_rec.attribute14, lip_tcnv_rec.attribute15;
    CLOSE trx_contracts_dff_csr;

    IF (l_tclv_tbl.COUNT) > 0 AND (l_amount_out_tbl.COUNT > 0)
    THEN
      k := l_tclv_tbl.FIRST;
      m := l_amount_out_tbl.FIRST;
      LOOP
          l_tclv_tbl(k).amount := 0;
          IF l_tclv_tbl(k).id = l_amount_out_tbl(m).source_id
          THEN
            lx_amount_tbl   := l_amount_out_tbl(m).amount_tbl;
            lx_template_tbl := l_template_out_tbl(m).template_tbl;
            IF (lx_amount_tbl.COUNT <> 1 OR lx_template_tbl.COUNT <> 1)
            THEN
              --raise error
              l_return_status := okl_api.g_ret_sts_error;
              -- Error occurred when creating accounting entries for transaction TRX_TYPE.
              okl_api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                                  p_token1       => 'TRX_TYPE',
                                  p_token1_value => l_trans_meaning);

              -- Raise exception to rollback to savepoint for this block
              RAISE okl_api.g_exception_error;
            ELSE
              l := lx_amount_tbl.FIRST;
              --update line amount
              l_tclv_tbl(k).amount := NVL(lx_amount_tbl(l),0);
            END IF;
          END IF;

        --update total header amount
        lip_tcnv_rec.amount := lip_tcnv_rec.amount + l_tclv_tbl(k)
                              .amount;
        EXIT WHEN k = l_tclv_tbl.LAST OR m = l_amount_out_tbl.LAST;
        k := l_tclv_tbl.NEXT(k);
	m := l_amount_out_tbl.NEXT(m);
      END LOOP;
    END IF;
    --call the api to update trx contracts hdr and lines
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_trx_contracts_pub.update_trx_contracts');
    END IF;
    okl_trx_contracts_pub.update_trx_contracts(p_api_version   => p_api_version,
                                               p_init_msg_list => okl_api.g_false,
                                               x_return_status => l_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_tcnv_rec      => lip_tcnv_rec,
                                               p_tclv_tbl      => l_tclv_tbl,
                                               x_tcnv_rec      => lix_tcnv_rec,
                                               x_tclv_tbl      => lx_tclv_tbl);
    --handle exception
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_trx_contracts_pub.update_trx_contracts l_return_status = '||l_return_status);
    END IF;
    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Set the return record
    px_tcnv_rec := lix_tcnv_rec;

    -- MGAAP 7628606.SGIYER. Changed input param for p_tcnv_rec
    -- from lip_tcnv_rec to lix_tcnv_rec.
    OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => l_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => lix_tcnv_rec
                           ,P_TCLV_TBL => lx_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => lp_acc_gen_primary_key_tbl);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- rmunjulu 4141991 Get the contract status
    OPEN get_k_sts_csr(p_term_rec.p_contract_id);
    FETCH get_k_sts_csr
      INTO l_k_sts;
    CLOSE get_k_sts_csr;

    -- rmunjulu 4141991 If contract is NOT TURNING TO EVERGREEN then do the rest of these steps
    IF nvl(p_source, '*') <> ('EVERGREEN')
    THEN

      -- *************
      -- REVERSAL OF NON-INCOME
      -- *************

      -- Reversal of non-income during contract termination
      -- Get the transaction id for Accrual
      okl_am_util_pvt.get_transaction_id(p_try_name      => 'Accrual',
                                         x_return_status => l_return_status,
                                         x_try_id        => l_try_id);

      -- Get the meaning of lookup
      l_trans_meaning := okl_am_util_pvt.get_lookup_meaning(p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                                            p_lookup_code => 'ACCRUAL',
                                                            p_validate_yn => 'Y');

      IF l_return_status <> okl_api.g_ret_sts_success
      THEN

        -- Message: Unable to find a transaction type for
        -- the transaction TRY_NAME
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AM_NO_TRX_TYPE_FOUND',
                            p_token1       => 'TRY_NAME',
                            p_token1_value => l_trans_meaning);

        --Message: Unable to do reversal of non-income during termination
        -- of contract CONTRACT_NUMBER.
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AM_REV_NONINC_ERR',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => p_term_rec.p_contract_number);

      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- Set the rec type in parameter
      l_catchup_rec.contract_id         := p_term_rec.p_contract_id;
      l_catchup_rec.accrual_date        := l_valid_gl_date; -- RMUNJULU 3148215
      l_catchup_rec.contract_number     := p_term_rec.p_contract_number;
      l_catchup_rec.rule_result         := g_yes;
      l_catchup_rec.override_status     := g_no;
      l_catchup_rec.product_id          := l_pdt_id;
      l_catchup_rec.trx_type_id         := l_try_id;
      l_catchup_rec.advance_arrears     := NULL;
      l_catchup_rec.factoring_synd_flag := NULL;
      l_catchup_rec.post_to_gl          := g_yes;
      l_catchup_rec.gl_reversal_flag    := g_no;
      l_catchup_rec.memo_yn             := g_no;
      l_catchup_rec.description         := 'Catchup of income on termination of the contract';
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_generate_accruals_pub.catchup_accruals');
      END IF;
      okl_generate_accruals_pub.catchup_accruals(p_api_version   => p_api_version,
                                                 p_init_msg_list => okl_api.g_false,
                                                 x_return_status => l_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_catchup_rec   => l_catchup_rec,
                                                 x_tcnv_tbl      => lx_tcnv_tbl,
                                                 x_tclv_tbl      => lx_tclv_tbl);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_generate_accruals_pub.catchup_accruals l_return_status = '||l_return_status);
      END IF;
      IF l_return_status <> okl_api.g_ret_sts_success
      THEN

        --Message: Unable to do reversal of non-income during termination
        -- of contract CONTRACT_NUMBER.
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AM_REV_NONINC_ERR',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => p_term_rec.p_contract_number);
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- MGAAP 7263041 start

      IF (l_multi_gaap_yn = 'Y') THEN

        l_sob_id_rep := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                                     p_representation_type => 'SECONDARY');

        l_valid_gl_date_rep :=
               okl_accounting_util.get_valid_gl_date (
                                 p_gl_date      => l_quote_accpt_date,
                                 p_ledger_id    => l_sob_id_rep
               );

        l_catchup_rec.product_id := l_reporting_pdt_id;
        l_catchup_rec.accrual_date := l_valid_gl_date_rep;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_generate_accruals_pub.catchup_accruals for SECONDARY');
        END IF;
        okl_generate_accruals_pub.catchup_accruals(p_api_version   => p_api_version,
                                                   p_init_msg_list => okl_api.g_false,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_catchup_rec   => l_catchup_rec,
                                                   x_tcnv_tbl      => lx_tcnv_tbl,
                                                   x_tclv_tbl      => lx_tclv_tbl,
                                                   p_representation_type   => 'SECONDARY');
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_generate_accruals_pub.catchup_accruals for SECONDARY l_return_status = '||l_return_status);
        END IF;
        IF l_return_status <> okl_api.g_ret_sts_success
        THEN

          --Message: Unable to do reversal of non-income during termination
          -- of contract CONTRACT_NUMBER.
          okl_api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AM_REV_NONINC_ERR',
                              p_token1       => 'CONTRACT_NUMBER',
                              p_token1_value => p_term_rec.p_contract_number);
        END IF;

        -- Raise exception to rollback this whole block
        IF (l_return_status = okl_api.g_ret_sts_unexp_error)
        THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error)
        THEN
          RAISE okl_api.g_exception_error;
        END IF;

      END IF;

      -- MGAAP 7263041 end

      -- *************
      -- REVERSAL OF LOSS-PROVISIONS
      -- *************

      -- Loss provisions reversal during contract termination
      -- Set the rec type in parameter
      l_lprv_rec.cntrct_num    := p_term_rec.p_contract_number;
      l_lprv_rec.reversal_type := NULL;

      -- RMUNJULU 3097068 Added code to set the reversal date with valid GL date
      l_lprv_rec.reversal_date := l_valid_gl_date;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_rev_loss_prov_pub.reverse_loss_provisions');
      END IF;
      okl_rev_loss_prov_pub.reverse_loss_provisions(p_api_version   => p_api_version,
                                                    p_init_msg_list => okl_api.g_false,
                                                    x_return_status => l_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data,
                                                    p_lprv_rec      => l_lprv_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_rev_loss_prov_pub.reverse_loss_provisions l_return_status = '||l_return_status);
      END IF;
      IF l_return_status <> okl_api.g_ret_sts_success
      THEN

        -- Message: Unable to do reversal of loss provisions during
        -- termination of contract CONTRACT_NUMBER.
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AM_REV_LOSPROV_ERR',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => p_term_rec.p_contract_number);
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

      -- rmunjulu 4769094 Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup check accruals till quote eff date OR previous month last date
      OPEN check_accrual_previous_csr;
      FETCH check_accrual_previous_csr
        INTO l_accrual_previous_mnth_yn;
      CLOSE check_accrual_previous_csr;
      -- fix for bug -- 5623356 -- added below condition
      -- If quote exists then cancelation date is quote eff from date else sysdate
     IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN
      IF nvl(l_accrual_previous_mnth_yn, 'N') = 'N'
      THEN
        -- rmunjulu 4769094 continue with current reversal date as quote effective date
        -- rmunjulu bug 4507662
        -- To get first day of the month after the month of the quote effective date to pass it for reversal of accural
        l_reverse_from := trunc(last_day(l_quote_eff_date) + 1);
      ELSE
        -- rmunjulu 4769094 new reversal date is quote eff dates month first day
        l_reverse_from := last_day(trunc(l_quote_eff_date,
                                         'MONTH') - 1) + 1; -- NOTE THIS IS A BIT DIFFERENT FROM OTHER SUCH FIXES
      END IF;
      ELSE
 	l_reverse_from := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
       END IF;
 	       -- fix for bug -- 5623356 --
      -- rmunjulu EDAT call reversal of accruals to reverse accruals from quote eff date
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling   okl_generate_accruals_pub.reverse_accruals');
      END IF;
      okl_generate_accruals_pub.reverse_accruals(p_api_version     => p_api_version,
                                                 p_init_msg_list   => okl_api.g_false,
                                                 x_return_status   => l_return_status,
                                                 x_msg_count       => x_msg_count,
                                                 x_msg_data        => x_msg_data,
                                                 p_khr_id          => p_term_rec.p_contract_id,
                                                 p_reversal_date   => l_quote_eff_date, -- Transaction date - Mandatory
                                                 p_accounting_date => l_valid_gl_date, -- Valid GL Date - Mandatory
                                                 p_reverse_from    => l_reverse_from, -- Date from when accruals need to be reversed - Mandatory -- rmunjulu bug 4507662
                                                 p_reverse_to      => l_empty_reverse_to_date, -- No value needs to be passed to this
                                                 p_tcn_type        => l_empty_tcn_type); -- No value needs to be passed to this
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_generate_accruals_pub.reverse_accruals l_return_status = '||l_return_status);
      END IF;
      IF l_return_status <> okl_api.g_ret_sts_success
      THEN

        -- Message: Unable to do reversal of accrual during
        -- termination of contract CONTRACT_NUMBER.
        okl_api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AM_EDT_REVERSAL_ERR',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => p_term_rec.p_contract_number);
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

      --Bug# 3999921: pagarg +++ T and A +++++++ Start ++++++++++
      IF p_term_rec.p_quote_type <> 'TER_RELEASE_WO_PURCHASE'
      THEN
        --Bug# 3999921: pagarg +++ T and A +++++++ End ++++++++++
        -- MDOKAL Bug 3061765
        -- The following code added for processing IDC acceleration.
        -- Currently only applicable for termination of Fee lines.

        -- Bug#7248153 - rbruno - commented - Start
        /*

        -- rmunjulu 4424713 Derive stream type id based on product type
        IF l_deal_type IN ('LEASEDF', 'LEASEST')
        THEN
          -- DF/ST Lease
          -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
          okl_streams_util.get_dependent_stream_type(p_term_rec.p_contract_id,
                                                     'RENT',
                                                     'LEASE_INCOME',
                                                     l_return_status,
                                                     lx_pretax_sty_id);
        ELSIF l_deal_type = 'LEASEOP'
        THEN
          -- OP Lease

          okl_streams_util.get_dependent_stream_type(p_term_rec.p_contract_id,
                                                     'RENT',
                                                     'RENT_ACCRUAL',
                                                     l_return_status,
                                                     lx_rentaccrual_sty_id);

          -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++
          -- 03-mar-06 sgorantl -- Bug 4931796
        ELSIF (l_deal_type = 'LOAN' OR
              l_deal_type = 'LOAN-REVOLVING')
        THEN
          -- Loan
          -- 03-mar-06 sgorantl -- Bug 4931796
          -- rmunjulu bug 4416094
          okl_streams_util.get_dependent_stream_type(p_term_rec.p_contract_id,
                                                     'RENT',
                                                     'INTEREST_INCOME',
                                                     l_return_status,
                                                     lx_interestincome_sty_id);

        END IF;

        OPEN get_accel_till_csr(p_term_rec.p_contract_id,
                                lx_pretax_sty_id,
                                lx_rentaccrual_sty_id,
                                lx_interestincome_sty_id); -- rmunjulu bug 4416094
        FETCH get_accel_till_csr
          INTO l_accelerate_till_date;
        CLOSE get_accel_till_csr;

    */
    -- Bug#7248153 - rbruno - commented - End


   -- Added by ansethur for bug#6156337 08-Aug-2007 start
        FOR primary_sty_id_rec in primary_sty_id_csr(p_term_rec.p_contract_id) LOOP



           OKL_STREAMS_UTIL.get_dependent_stream_type(p_term_rec.p_contract_id,
                                                      primary_sty_id_rec.Primary_sty_id,
                                                      'AMORTIZED_FEE_EXPENSE',
                                                      l_return_status,
                                                      lx_sty_id);

        -- Bug#7248153 - rbruno - Added - Start

        OPEN get_accel_till_csr(p_term_rec.p_contract_id,lx_sty_id);
        FETCH get_accel_till_csr  INTO l_accelerate_till_date;
        CLOSE get_accel_till_csr;

        -- Bug#7248153 - rbruno Added - End


   -- Added by ansethur for bug#6156337 08-Aug-2007 end
        /* commented by ansethur for bug#6156337 08-Aug-2007 start
        -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
        okl_streams_util.get_dependent_stream_type(p_term_rec.p_contract_id,
                                                   'EXPENSE',
                                                   'AMORTIZED_FEE_EXPENSE',
                                                   l_return_status,
                                                   lx_sty_id);
        -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++
      */ -- commented by ansethur for bug#6156337 08-Aug-2007 End
        FOR idc_accel_rec IN idc_accel_csr(p_term_rec.p_contract_id,
                                           lx_sty_id ,primary_sty_id_rec.kle_id )
        LOOP

          IF p_term_rec.p_termination_date IS NULL OR
             p_term_rec.p_termination_date = okc_api.g_miss_date
          THEN
            l_acceleration_rec.acceleration_date := l_valid_gl_date; --sysdate; -- rmunjulu EDAT
          ELSE
            l_acceleration_rec.acceleration_date := p_term_rec.p_termination_date;
          END IF;

          IF l_accelerate_till_date IS NULL OR
             l_accelerate_till_date = okc_api.g_miss_date
          THEN
            l_acceleration_rec.accelerate_till_date := p_term_rec.p_orig_end_date;
          ELSE
            l_acceleration_rec.accelerate_till_date := l_accelerate_till_date;
          END IF;
	  -- fix for bug -- 5623356 -- added below condition
 	  -- If quote exists then cancelation date is quote eff from date else sysdate
 	  IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN
          --akrangan Bug 5526955 fix start
 	  --Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup check accruals till quote eff date OR previous month last date
 	  IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN
 	    l_acceleration_rec.accelerate_from_date := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
 	  ELSE
 	    l_acceleration_rec.accelerate_from_date := LAST_DAY(TRUNC(l_quote_eff_date, 'MONTH')-1)+1;
 	  END IF;
 	  --akrangan Bug 5526955 fix end
	  ELSE
 	    l_acceleration_rec.accelerate_from_date := TRUNC(LAST_DAY(l_quote_eff_date) + 1);
 	  END IF;
 	  -- fix for bug -- 5623356 --
          l_acceleration_rec.khr_id          := p_term_rec.p_contract_id;
          l_acceleration_rec.sty_id          := lx_sty_id; -- User defined streams change 392546
          l_acceleration_rec.description     := 'Acceleration of IDC expense for Fee ' ||
                                                idc_accel_rec.fee_type ||
                                                ' - Accural';
          l_acceleration_rec.accrual_rule_yn := 'N';
          l_acceleration_rec.kle_id          := primary_sty_id_rec.kle_id;     -- Added by ansethur for bug#6156337 08-Aug-2007
          okl_generate_accruals_pvt.accelerate_accruals(p_api_version      => p_api_version,
                                                        p_init_msg_list    => p_init_msg_list,
                                                        x_return_status    => l_return_status,
                                                        x_msg_count        => x_msg_count,
                                                        x_msg_data         => x_msg_data,
                                                        p_acceleration_rec => l_acceleration_rec,
                             x_trx_number  => l_trx_number); -- MGAAP 7263041

          IF (l_return_status = okl_api.g_ret_sts_unexp_error)
          THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error)
          THEN
            RAISE okl_api.g_exception_error;
          END IF;

          -- Start MGAAP 7263041
          OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
          okl_streams_util.get_dependent_stream_type_rep(
                                                   p_term_rec.p_contract_id,
                                                   'EXPENSE',
                                                   'AMORTIZED_FEE_EXPENSE',
                                                   l_return_status,
                                                   lx_sty_id_rep);
          IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
            l_acceleration_rec.sty_id := lx_sty_id_rep;
            l_acceleration_rec.trx_number := l_trx_number;

            OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals (
                             p_api_version       => p_api_version,
                             p_init_msg_list     => p_init_msg_list,
                             x_return_status     => l_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data,
                             p_acceleration_rec  => l_acceleration_rec,
                             p_representation_type  => 'SECONDARY',
                             x_trx_number  => l_trx_number);

            OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_GENERATE_ACCRUALS_PVT.accelerate_accruals , return status : ' || l_return_status);
            END IF;

            IF (l_return_status = okl_api.g_ret_sts_unexp_error)
            THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error)
            THEN
              RAISE okl_api.g_exception_error;
            END IF;

          END IF;
          -- End MGAAP 7263041

        END LOOP;
      END LOOP;   -- Added by ansethur for bug#6156337 08-Aug-2007 start
        --Bug# 3999921: pagarg +++ T and A +++++++ Start ++++++++++
      END IF; -- p_term_rec.p_quote_type <> 'TER_RELEASE_WO_PURCHASE'
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling   okl_am_lease_loan_trmnt_pvt.process_adjustments');
      END IF;
      okl_am_lease_loan_trmnt_pvt.process_adjustments(p_api_version      => p_api_version,
                                                      p_init_msg_list    => okl_api.g_false,
                                                      x_return_status    => l_return_status,
                                                      x_msg_count        => x_msg_count,
                                                      x_msg_data         => x_msg_data,
                                                      p_term_rec         => p_term_rec,
                                                      p_tcnv_rec         => px_tcnv_rec, -- rmunjulu TNA Added since trn_id is needed
                                                      p_call_origin      => 'FULL',
                                                      p_termination_date => p_sys_date);
       IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_am_lease_loan_trmnt_pvt.process_adjustments l_return_status = '||l_return_status);
      END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_am_lease_loan_trmnt_pvt.process_adjustments');
      END IF;
      --Bug# 3999921: pagarg +++ T and A +++++++ End ++++++++++

      -- End MDOKAL Bug 3061765
      -- Smoduga
      -- Call to Process discount and Subsidy during acceptance of a termination quote
      okl_am_lease_loan_trmnt_pvt.process_discount_subsidy(p_api_version      => p_api_version,
                                                           p_init_msg_list    => okl_api.g_false,
                                                           x_return_status    => l_return_status,
                                                           x_msg_count        => x_msg_count,
                                                           x_msg_data         => x_msg_data,
                                                           p_term_rec         => p_term_rec,
                                                           p_call_origin      => NULL,
                                                           p_termination_date => p_sys_date);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_am_lease_loan_trmnt_pvt.process_adjustments l_return_status = '||l_return_status);
      END IF;
      IF l_return_status <> okl_api.g_ret_sts_success
      THEN

        okl_api.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKL_AM_SUBSIDY_PROC_FAIL');
      END IF;

      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;
      -- Smoduga
      -- Call to Process discount and Subsidy during acceptance of a termination quote
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'calling  okl_am_lease_loan_trmnt_pvt.process_loan_refunds');
      END IF;
      -- rmunjulu LOANS_ENHANCEMENTS Call to refund excess loan payments
      okl_am_lease_loan_trmnt_pvt.process_loan_refunds(p_api_version      => p_api_version,
                                                       p_init_msg_list    => okl_api.g_false,
                                                       x_return_status    => l_return_status,
                                                       x_msg_count        => x_msg_count,
                                                       x_msg_data         => x_msg_data,
                                                       p_term_rec         => p_term_rec,
                                                       p_tcnv_rec         => px_tcnv_rec,
                                                       p_call_origin      => 'FULL',
                                                       p_termination_date => p_sys_date);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  okl_am_lease_loan_trmnt_pvt.process_loan_refunds l_return_status = '||l_return_status);
      END IF;
      IF l_return_status <> okl_api.g_ret_sts_success
      THEN

        okl_api.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKL_AM_LOAN_REFUND_FAILED');
      END IF;

      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- *************
      -- SUCCESS MESSAGES
      -- *************

      -- Message: Reversal of non-income during termination
      -- of contract CONTRACT_NUMBER done successfully.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_REV_NONINC_SUC',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => p_term_rec.p_contract_number);

      -- Message: Reversal of loss provisions during
      -- termination of contract CONTRACT_NUMBER done successfully.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_REV_LOSPROV_SUC',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => p_term_rec.p_contract_number);

    END IF; -- rmunjulu 4141991 End of new If

    -- Set success messages here
    -- Get the meaning of lookup
    l_trans_meaning := okl_am_util_pvt.get_lookup_meaning(p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                                          p_lookup_code => 'TERMINATION',
                                                          p_validate_yn => 'Y');

    -- Accounting entries created for transaction type TRX_TYPE.
    okl_api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_AM_ACC_ENT_CREATED',
                        p_token1       => 'TRX_TYPE',
                        p_token1_value => l_trans_meaning);

    -- store the highest degree of error
    set_overall_status(p_return_status   => l_return_status,
                       px_overall_status => px_overall_status);

    -- set the transaction record
    set_transaction_rec(p_return_status  => l_return_status,
                        p_overall_status => px_overall_status,
                        p_tmt_flag       => 'TMT_ACCOUNTING_ENTRIES_YN',
                        p_tsu_code       => 'WORKING',
                        px_tcnv_rec      => px_tcnv_rec);

  END IF;

  x_return_status := l_return_status;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
EXCEPTION

  WHEN okl_api.g_exception_error THEN
          IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

    -- mdokal bug 3061765
    IF get_accel_till_csr%ISOPEN
    THEN
      CLOSE get_accel_till_csr;
    END IF;

    -- mdokal bug 3061765
    IF idc_accel_csr%ISOPEN
    THEN
      CLOSE idc_accel_csr;
    END IF;

    IF l_product_type_csr%ISOPEN
    THEN
      CLOSE l_product_type_csr;
    END IF;

    IF prod_id_csr%ISOPEN
    THEN
      CLOSE prod_id_csr;
    END IF;

    -- rmunjulu 4141991
    IF get_k_sts_csr%ISOPEN
    THEN
      CLOSE get_k_sts_csr;
    END IF;
    IF trx_contracts_dff_csr%ISOPEN
    THEN
      CLOSE trx_contracts_dff_csr;
    END IF;
    IF txl_contracts_dff_csr%ISOPEN
    THEN
      CLOSE txl_contracts_dff_csr;
    END IF;
    IF product_name_csr%ISOPEN
    THEN
      CLOSE product_name_csr;
    END IF;

    ROLLBACK TO accounting_entries;

    x_return_status := okl_api.g_ret_sts_error;
    -- store the highest degree of error
    set_overall_status(p_return_status   => x_return_status,
                       px_overall_status => px_overall_status);

    -- set the transaction record
    set_transaction_rec(p_return_status  => x_return_status,
                        p_overall_status => px_overall_status,
                        p_tmt_flag       => 'TMT_ACCOUNTING_ENTRIES_YN',
                        p_tsu_code       => 'ERROR',
                        px_tcnv_rec      => px_tcnv_rec);

  WHEN okl_api.g_exception_unexpected_error THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;


    -- mdokal bug 3061765
    IF get_accel_till_csr%ISOPEN
    THEN
      CLOSE get_accel_till_csr;
    END IF;

    -- mdokal bug 3061765
    IF idc_accel_csr%ISOPEN
    THEN
      CLOSE idc_accel_csr;
    END IF;

    IF l_product_type_csr%ISOPEN
    THEN
      CLOSE l_product_type_csr;
    END IF;

    IF prod_id_csr%ISOPEN
    THEN
      CLOSE prod_id_csr;
    END IF;

    -- rmunjulu 4141991
    IF get_k_sts_csr%ISOPEN
    THEN
      CLOSE get_k_sts_csr;
    END IF;
    IF trx_contracts_dff_csr%ISOPEN
    THEN
      CLOSE trx_contracts_dff_csr;
    END IF;
    IF txl_contracts_dff_csr%ISOPEN
    THEN
      CLOSE txl_contracts_dff_csr;
    END IF;
    IF product_name_csr%ISOPEN
    THEN
      CLOSE product_name_csr;
    END IF;

    ROLLBACK TO accounting_entries;

    x_return_status := okl_api.g_ret_sts_unexp_error;
    -- store the highest degree of error
    set_overall_status(p_return_status   => x_return_status,
                       px_overall_status => px_overall_status);

    -- set the transaction record
    set_transaction_rec(p_return_status  => x_return_status,
                        p_overall_status => px_overall_status,
                        p_tmt_flag       => 'TMT_ACCOUNTING_ENTRIES_YN',
                        p_tsu_code       => 'ERROR',
                        px_tcnv_rec      => px_tcnv_rec);

  WHEN OTHERS THEN
          IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

    -- mdokal bug 3061765
    IF get_accel_till_csr%ISOPEN
    THEN
      CLOSE get_accel_till_csr;
    END IF;

    -- mdokal bug 3061765
    IF idc_accel_csr%ISOPEN
    THEN
      CLOSE idc_accel_csr;
    END IF;

    IF l_product_type_csr%ISOPEN
    THEN
      CLOSE l_product_type_csr;
    END IF;

    IF prod_id_csr%ISOPEN
    THEN
      CLOSE prod_id_csr;
    END IF;

    -- rmunjulu 4141991
    IF get_k_sts_csr%ISOPEN
    THEN
      CLOSE get_k_sts_csr;
    END IF;
    IF trx_contracts_dff_csr%ISOPEN
    THEN
      CLOSE trx_contracts_dff_csr;
    END IF;
    IF txl_contracts_dff_csr%ISOPEN
    THEN
      CLOSE txl_contracts_dff_csr;
    END IF;
    IF product_name_csr%ISOPEN
    THEN
      CLOSE product_name_csr;
    END IF;

    ROLLBACK TO accounting_entries;

    x_return_status := okl_api.g_ret_sts_unexp_error;
    -- store the highest degree of error
    set_overall_status(p_return_status   => x_return_status,
                       px_overall_status => px_overall_status);

    -- set the transaction record
    set_transaction_rec(p_return_status  => x_return_status,
                        p_overall_status => px_overall_status,
                        p_tmt_flag       => 'TMT_ACCOUNTING_ENTRIES_YN',
                        p_tsu_code       => 'ERROR',
                        px_tcnv_rec      => px_tcnv_rec);

    -- Set the oracle error message
    okl_api.set_message(p_app_name     => okc_api.g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => SQLCODE,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => SQLERRM);

END process_accounting_entries;

PROCEDURE Create_Repo_asset_2(
              p_init_msg_list               IN  VARCHAR2,
              p_khr_id          IN OKC_K_HEADERS_B.ID%TYPE,
              p_kle_id          IN OKL_K_LINES.ID%TYPE,
              p_corporate_book  IN OKL_SYSTEM_PARAMS_ALL.CORPORATE_BOOK%TYPE,
              p_tax_book_1      IN OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_1%TYPE,
              p_tax_book_2      IN OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_2%TYPE,
              p_rep_book        IN OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE,
              p_fa_location_id  IN OKL_SYSTEM_PARAMS_ALL.FA_LOCATION_ID%TYPE,
              p_asset_key_id    IN OKL_SYSTEM_PARAMS_ALL.ASSET_KEY_ID%TYPE,
              p_depreciate_yn   IN OKL_SYSTEM_PARAMS_ALL.DEPRECIATE_YN%TYPE,
              p_tas_id          IN OKL_TRX_ASSETS.ID%TYPE,
              p_line_number     IN NUMBER,
              p_quote_id        IN NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2,
              x_msg_count       OUT NOCOPY NUMBER,
              x_msg_data        OUT NOCOPY VARCHAR2
           ) IS

       CURSOR l_sub_line_csr(p_chr_id   IN NUMBER
                            ,p_lty_code IN VARCHAR2
                            ,p_cle_id   IN NUMBER) IS
       SELECT cle.id,
              cim.object1_id1,
              cim.object1_id2,
              cim.number_of_items,
              fa_kle.year_of_manufacture
       FROM   okc_k_lines_b  cle,
              okc_k_items cim,
              okc_line_styles_b lse,
              okc_statuses_b sts,
              okl_k_lines fa_kle,
              okc_k_lines_b fa_cle,
              okc_line_styles_b fa_lse
       WHERE cle.dnz_chr_id = p_chr_id
       AND   cle.cle_id = p_cle_id
       AND   cle.lse_id = lse.id
       AND   lse.lty_code = p_lty_code
       AND   cim.cle_id = cle.id
       AND   cim.dnz_chr_id = cle.dnz_chr_id
       AND   sts.code = cle.sts_code
       AND   sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
       AND   fa_cle.id = p_cle_id
       AND   fa_kle.id = fa_cle.id
       AND   fa_cle.lse_id = fa_lse.id
       AND   fa_lse.lty_code = 'FREE_FORM1';

       l_model_line_rec  l_sub_line_csr%ROWTYPE;

       CURSOR l_inv_item_csr(p_inv_item_id IN NUMBER,
                             p_org_id IN NUMBER) IS
       SELECT asset_category_id
       FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id
       AND organization_id = p_org_id;

       l_inv_item_rec l_inv_item_csr%ROWTYPE;

       CURSOR c_asset_description(p_cle_id IN NUMBER) IS
       SELECT NAME, ITEM_DESCRIPTION
       FROM OKC_K_LINES_TL
       WHERE ID = p_cle_id
       AND LANGUAGE = USERENV('LANG');

       l_asset_description c_asset_description%ROWTYPE;

       CURSOR c_asset_ret_dtls(p_cle_id IN NUMBER) IS
       SELECT DATE_RETURNED, ASSET_FMV_AMOUNT
       FROM OKL_ASSET_RETURNS_B
       WHERE KLE_ID = p_cle_id
       AND ARS_CODE = 'REPOSSESSED';

       l_asset_ret_dtls c_asset_ret_dtls%ROWTYPE;

       CURSOR c_fa_expense_ccid(
                p_book_type_code FA_CATEGORY_BOOKS.BOOK_TYPE_CODE%TYPE,
                p_category_id    FA_CATEGORY_BOOKS.CATEGORY_ID%TYPE) IS
       SELECT DEPRN_EXPENSE_ACCOUNT_CCID
       FROM   FA_CATEGORY_BOOKS
       WHERE  BOOK_TYPE_CODE = p_book_type_code
       AND    CATEGORY_ID    = p_category_id;

       l_fa_expense_ccid c_fa_expense_ccid%ROWTYPE;

       CURSOR c_cim_asset_id(p_cle_id IN NUMBER) IS
       SELECT ITM.ID
       FROM   OKC_K_ITEMS ITM,
              OKC_K_LINES_B CLE,
              OKC_LINE_STYLES_B LSE
       WHERE ITM.CLE_ID = cle.ID
       AND   CLE.CLE_ID = p_cle_id
       AND   CLE.LSE_ID = LSE.ID
       AND   LSE.LTY_CODE = 'FIXED_ASSET';

       l_cim_asset_id c_cim_asset_id%ROWTYPE;

       CURSOR c_get_fa_books( p_book_type_code FA_BOOKS.BOOK_TYPE_CODE%TYPE,
                              p_asset_id FA_BOOKS.ASSET_ID%TYPE) IS
       SELECT DEPRN_METHOD_CODE,
              LIFE_IN_MONTHS,
              COST,
              SALVAGE_VALUE
       FROM   FA_BOOKS
       WHERE  ASSET_ID = p_asset_id
       AND    BOOK_TYPE_CODE = p_book_type_code ;

       l_get_fa_books c_get_fa_books%ROWTYPE;

       l_set_of_books_id OKL_SYS_ACCT_OPTS.SET_OF_BOOKS_ID%TYPE;
       l_max_books NUMBER;

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

l_calling_interface Varchar2(30) := 'OKLRLTNB:Create_Repo_asset';
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_REPO_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;
l_pkg_name  VARCHAR2(30) := 'OKL_AM_LEASE_TRMNT_PVT';
l_asset_id NUMBER;
l_talv_rec               talv_rec_type;
x_talv_rec               talv_rec_type;

l_oec NUMBER;
l_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;
x_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;

l_txdv_rec     adpv_rec_type;
x_txdv_rec     adpv_rec_type;
l_line_detail_number NUMBER := 1;
-- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'Create_Repo_asset';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

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
  IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_khr_id = '||p_khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_kle_id = '||p_kle_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_corporate_book = '||p_corporate_book);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_tax_book_1 = '||p_tax_book_1);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_tax_book_2 = '||p_tax_book_2);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_rep_book = '||p_rep_book);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_fa_location_id = '||p_fa_location_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_asset_key_id = '||p_asset_key_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_depreciate_yn = '||p_depreciate_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_tas_id = '||p_tas_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_line_number = '||p_line_number);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_quote_id = '||p_quote_id);
  END IF;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  OPEN l_sub_line_csr(p_chr_id => p_khr_id,
                      p_lty_code => 'ITEM',
                      p_cle_id => p_kle_id);
  FETCH l_sub_line_csr INTO l_model_line_rec;
  CLOSE l_sub_line_csr;

  OPEN l_inv_item_csr(p_inv_item_id => TO_NUMBER(l_model_line_rec.object1_id1),
                      p_org_id      => TO_NUMBER(l_model_line_rec.object1_id2));
  FETCH l_inv_item_csr INTO l_inv_item_rec;
  CLOSE l_inv_item_csr;

  OPEN c_asset_description(p_kle_id);
  FETCH c_asset_description INTO l_asset_description;
  CLOSE c_asset_description;

  OPEN c_asset_ret_dtls(p_kle_id);
  FETCH c_asset_ret_dtls INTO l_asset_ret_dtls;
  CLOSE c_asset_ret_dtls;
  l_oec := l_asset_ret_dtls.asset_fmv_amount;

  l_set_of_books_id := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;

  /*IF (p_tax_book_2 IS NOT NULL AND p_tax_book_2 <> OKL_API.G_MISS_CHAR)
  THEN
    l_max_books := 3;
  ELSE
    l_max_books := 2;
  END IF;*/
  l_max_books := 4;

  FOR l_counter IN 1..l_max_books
  LOOP

    IF (l_counter=1) OR
       (l_counter=2 AND p_tax_book_1 IS NOT NULL
            AND p_tax_book_1 <> OKL_API.G_MISS_CHAR) OR
       (l_counter=3 AND p_tax_book_2 IS NOT NULL
            AND p_tax_book_2 <> OKL_API.G_MISS_CHAR) OR
       (l_counter=4 AND p_rep_book IS NOT NULL
            AND p_rep_book <> OKL_API.G_MISS_CHAR) THEN
    l_trans_rec.transaction_type_code := 'ADDITION';
    l_asset_desc_rec.asset_key_ccid:= p_asset_key_id;
    l_asset_desc_rec.current_units:= l_model_line_rec.number_of_items;
    l_asset_hdr_rec.asset_id          := NULL;

    IF (l_counter = 1) THEN
      l_asset_hdr_rec.book_type_code :=p_corporate_book;
    ELSIF (l_counter=2) THEN
      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code :=p_tax_book_1;
    ELSIF (l_counter=3) THEN
      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code :=p_tax_book_2;
    ELSE
      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code :=p_rep_book;
    END IF;

    okl_debug_pub.logmessage('AKP:l_counter=' || l_counter || ' book=' || l_asset_hdr_rec.book_type_code);
    l_asset_hdr_rec.set_of_books_id :=l_set_of_books_id;

    l_asset_desc_rec.asset_number       := l_asset_description.NAME;
    l_asset_desc_rec.description        := l_asset_description.ITEM_DESCRIPTION;

    l_asset_cat_rec.category_id :=l_inv_item_rec.asset_category_id;

    l_asset_fin_rec.set_of_books_id :=l_set_of_books_id;
    l_asset_fin_rec.date_placed_in_service := l_asset_ret_dtls.DATE_RETURNED;
    IF (NVL(p_depreciate_yn, 'N')  = 'N' ) THEN
      l_asset_fin_rec.depreciate_flag :='NO';
    ELSE
      l_asset_fin_rec.depreciate_flag :='NO';
    END IF;

    l_asset_fin_rec.contract_id            := p_khr_id;

    l_asset_dist_rec.units_assigned :=l_model_line_rec.number_of_items;
    OPEN c_fa_expense_ccid(
           l_asset_hdr_rec.book_type_code,
           l_inv_item_rec.asset_category_id);
    FETCH c_fa_expense_ccid INTO l_fa_expense_ccid;
    CLOSE c_fa_expense_ccid;

    --l_asset_dist_rec.expense_ccid :=140417;
    l_asset_dist_rec.expense_ccid :=l_fa_expense_ccid.DEPRN_EXPENSE_ACCOUNT_CCID;
    l_asset_dist_rec.location_ccid :=p_fa_location_id;
    l_asset_dist_tbl(1) := l_asset_dist_rec;

    /*IF (l_counter=1) THEN
      OPEN c_asset_fmv_amount(p_kle_id);
      FETCH c_asset_fmv_amount INTO l_oec;
      CLOSE c_asset_fmv_amount;
    END IF;*/

    l_asset_fin_rec.cost := l_oec;
    l_asset_fin_rec.original_cost := l_oec;
   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling fa_addition_pub.do_addition');
   END IF;
   fa_addition_pub.do_addition
      (p_api_version             => l_api_version,
       p_init_msg_list           => OKL_API.G_FALSE,
       p_commit                  => OKL_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_calling_fn              => l_calling_interface,
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
   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called fa_addition_pub.do_addition x_return_status = '||x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_asset_hdr_rec.asset_id = '||l_asset_hdr_rec.asset_id);
   END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_asset_id := l_asset_hdr_rec.asset_id;


    IF (l_counter =1) THEN
      OPEN c_cim_asset_id(p_kle_id);
      FETCH c_cim_asset_id INTO l_cim_asset_id;
      CLOSE c_cim_asset_id;

      l_cim_rec.id          := l_cim_asset_id.ID;
      l_cim_rec.object1_id1 := to_char(l_asset_id);
      l_cim_rec.object1_id2 := '#';
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling okl_okc_migration_pvt.update_contract_item');
      END IF;

      okl_okc_migration_pvt.update_contract_item(
            p_api_version                  => 1.0,
            p_init_msg_list                => okc_api.g_false,
            x_return_status                =>x_return_status,
            x_msg_count                    =>x_msg_count,
            x_msg_data                     =>x_msg_data,
            p_cimv_rec                     =>l_cim_rec,
            x_cimv_rec                     =>x_cim_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called okl_okc_migration_pvt.update_contract_item x_return_status = '||x_return_status);
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Now create 'Internal Asset Creation' transaction lines

      l_talv_rec.tal_type := G_TRANS_TYPE;
      l_talv_rec.asset_number := l_asset_description.NAME;
      l_talv_rec.dnz_khr_id            := p_khr_id;
      l_talv_rec.tas_id                := p_tas_id;
      l_talv_rec.line_number           := p_line_number;
      l_talv_rec.original_cost         := l_oec;
      l_talv_rec.current_units         := l_model_line_rec.number_of_items;
      l_talv_rec.year_manufactured     := l_model_line_rec.year_of_manufacture;
      l_talv_rec.Depreciation_Cost     := l_oec;
      l_talv_rec.kle_id                := p_kle_id;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_TXL_ASSETS_PUB.create_txl_asset_def');
      END IF;
      OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                         p_api_version    => 1,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_tlpv_rec       => l_talv_rec,
                         x_tlpv_rec       => x_talv_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_TXL_ASSETS_PUB.create_txl_asset_def x_return_status = '||x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'x_talv_rec.ID = '||x_talv_rec.ID);
      END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    IF (l_counter > 1) THEN
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Before opening c_get_fa_books l_asset_hdr_rec.book_type_code = '||l_asset_hdr_rec.book_type_code);
      END IF;

    OPEN c_get_fa_books(l_asset_hdr_rec.book_type_code, l_asset_id);
    FETCH c_get_fa_books INTO l_get_fa_books;
    IF c_get_fa_books%NOTFOUND THEN
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'No Data Found in Cursor c_get_fa_books');
      END IF;
      CLOSE c_get_fa_books;
    ELSE
      l_txdv_rec.OBJECT_VERSION_NUMBER := 1;
      l_txdv_rec.TAL_ID := x_talv_rec.ID;
      l_txdv_rec.LINE_DETAIL_NUMBER := l_line_detail_number;
      l_txdv_rec.ASSET_NUMBER := l_talv_rec.asset_number;

      l_txdv_rec.QUANTITY := l_model_line_rec.number_of_items;

      l_txdv_rec.COST := l_get_fa_books.COST;

      l_txdv_rec.TAX_BOOK := l_asset_hdr_rec.book_type_code;

      l_txdv_rec.LIFE_IN_MONTHS_TAX := l_get_fa_books.LIFE_IN_MONTHS;

      l_txdv_rec.DEPRN_METHOD_TAX := l_get_fa_books.DEPRN_METHOD_CODE;

      l_txdv_rec.SALVAGE_VALUE := l_get_fa_books.SALVAGE_VALUE;

      CLOSE c_get_fa_books;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_TXD_ASSETS_PUB.create_txd_asset_def');
      END IF;

      OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                           p_api_version    => 1,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_adpv_rec       => l_txdv_rec,
                           x_adpv_rec       => x_txdv_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called  OKL_TXD_ASSETS_PUB.create_txd_asset_def x_return_status = '||x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'x_txdv_rec.ID = '||x_txdv_rec.ID);
      END IF;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_line_detail_number := l_line_detail_number + 1;
    END IF;
    END IF;

  END IF;
  END LOOP;

  OKL_API.END_ACTIVITY (x_msg_count, x_msg_data );
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');


END;

 --RKUTTIYA Added for bug 6674370
    --Call to  SLA Populate Sources
    PROCEDURE Populate_Sources(p_api_version     IN NUMBER,
                               p_init_msg_list   IN  VARCHAR2,
                               p_khr_id          IN OKC_K_HEADERS_B.ID%TYPE,
                               p_kle_id          IN OKL_K_LINES.ID%TYPE,
                               p_corporate_book  IN OKL_SYSTEM_PARAMS_ALL.CORPORATE_BOOK%TYPE,
                               p_tas_id          IN OKL_TRX_ASSETS.ID%TYPE,
                               p_tal_id          IN NUMBER,
                               p_line_type       IN VARCHAR2,
                               p_fa_trx_id       IN NUMBER,
                               p_asset_id        IN NUMBER,
                               p_quote_id        IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2) IS

     l_calling_interface    VARCHAR2(30) := 'OKLRLTNB:Populate_Sources';
     l_api_name             CONSTANT VARCHAR2(30) := 'POPULATE_SOURCES';
     l_api_version          CONSTANT NUMBER := 1.0;
     l_pkg_name  VARCHAR2(30) := 'OKL_AM_LEASE_TRMNT_PVT';

     CURSOR c_try_id(p_tas_id IN NUMBER) IS
     SELECT try_id
     FROM OKL_TRX_ASSETS
     WHERE id = p_tas_id;

     --Cursor for quote details
    CURSOR c_quote_details(p_quote_id IN NUMBER) IS
    SELECT QTP_CODE,
           QUOTE_NUMBER,
           DATE_ACCEPTED,
           REPO_QUOTE_INDICATOR_YN
    FROM OKL_TRX_QUOTES_B
    WHERE ID = p_quote_id;

     l_try_id    NUMBER;
     l_quote_id  NUMBER;

     l_fxhv_rec         okl_fxh_pvt.fxhv_rec_type;
     l_fxlv_rec         okl_fxl_pvt.fxlv_rec_type;

     l_quote_num         VARCHAR2(30);
     l_date_accepted     DATE;
     l_quote_type_code   VARCHAR2(30);
     l_repossess_flag    VARCHAR2(1);
   BEGIN
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

    -- get the try id
      OPEN c_try_id(p_tas_id);
      FETCH c_try_id INTO l_try_id;
      CLOSE c_try_id;

       OPEN c_quote_details(p_quote_id);
       FETCH c_quote_details INTO l_quote_type_code,l_quote_num, l_date_accepted,l_repossess_flag;
       CLOSE c_quote_details;

         -- header record
           l_fxhv_rec.source_id    := p_tas_id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id := p_khr_id;
           l_fxhv_rec.try_id := l_try_id;
           l_fxhv_rec.term_quote_type_code := l_quote_type_code;
           l_fxhv_rec.term_quote_num  := l_quote_num;
           l_fxhv_rec.term_quote_accept_date := l_date_accepted;
           l_fxhv_rec.repossess_flag         := l_repossess_flag;


           --line record

           l_fxlv_rec.source_id         := p_tal_id;
           IF p_line_type = 'L' THEN
             l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           ELSIF p_line_type = 'D' THEN
		     l_fxlv_rec.source_table  := 'OKL_TXD_ASSETS_B';
		   END IF;
           l_fxlv_rec.asset_id          :=  p_asset_id;
           l_fxlv_rec.kle_id            :=  p_kle_id;
           l_fxlv_rec.fa_transaction_id := p_fa_trx_id;
           l_fxlv_rec.asset_book_type_name := p_corporate_book;

           --call Populate sources api
           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data );
 END;


PROCEDURE Create_Repo_asset(
              p_init_msg_list               IN  VARCHAR2,
              p_khr_id          IN OKC_K_HEADERS_B.ID%TYPE,
              p_kle_id          IN OKL_K_LINES.ID%TYPE,
              p_corporate_book  IN OKL_SYSTEM_PARAMS_ALL.CORPORATE_BOOK%TYPE,
              p_tax_book_1      IN OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_1%TYPE,
              p_tax_book_2      IN OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_2%TYPE,
              p_rep_book        IN OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE,
              p_fa_location_id  IN OKL_SYSTEM_PARAMS_ALL.FA_LOCATION_ID%TYPE,
              p_asset_key_id    IN OKL_SYSTEM_PARAMS_ALL.ASSET_KEY_ID%TYPE,
              p_depreciate_yn   IN OKL_SYSTEM_PARAMS_ALL.DEPRECIATE_YN%TYPE,
              p_tas_id          IN OKL_TRX_ASSETS.ID%TYPE,
              p_line_number     IN NUMBER,
              p_quote_id        IN NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2,
              x_msg_count       OUT NOCOPY NUMBER,
              x_msg_data        OUT NOCOPY VARCHAR2
           ) IS

       CURSOR l_sub_line_csr(p_chr_id   IN NUMBER
                            ,p_lty_code IN VARCHAR2
                            ,p_cle_id   IN NUMBER) IS
       SELECT cle.id,
              cim.object1_id1,
              cim.object1_id2,
              cim.number_of_items,
              fa_kle.year_of_manufacture
       FROM   okc_k_lines_b  cle,
              okc_k_items cim,
              okc_line_styles_b lse,
              okc_statuses_b sts,
              okl_k_lines fa_kle,
              okc_k_lines_b fa_cle,
              okc_line_styles_b fa_lse
       WHERE cle.dnz_chr_id = p_chr_id
       AND   cle.cle_id = p_cle_id
       AND   cle.lse_id = lse.id
       AND   lse.lty_code = p_lty_code
       AND   cim.cle_id = cle.id
       AND   cim.dnz_chr_id = cle.dnz_chr_id
       AND   sts.code = cle.sts_code
       AND   sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
       AND   fa_cle.id = p_cle_id
       AND   fa_kle.id = fa_cle.id
       AND   fa_cle.lse_id = fa_lse.id
       AND   fa_lse.lty_code = 'FREE_FORM1';

       l_model_line_rec  l_sub_line_csr%ROWTYPE;

       CURSOR l_inv_item_csr(p_inv_item_id IN NUMBER,
                             p_org_id IN NUMBER) IS
       SELECT asset_category_id
       FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id
       AND organization_id = p_org_id;

       l_inv_item_rec l_inv_item_csr%ROWTYPE;

       CURSOR c_asset_description(p_cle_id IN NUMBER) IS
       SELECT NAME, ITEM_DESCRIPTION
       FROM OKC_K_LINES_TL
       WHERE ID = p_cle_id
       AND LANGUAGE = USERENV('LANG');

       l_asset_description c_asset_description%ROWTYPE;

       CURSOR c_asset_ret_dtls(p_cle_id IN NUMBER) IS
       SELECT DATE_RETURNED, ASSET_FMV_AMOUNT
       FROM OKL_ASSET_RETURNS_B
       WHERE KLE_ID = p_cle_id
       AND ARS_CODE = 'REPOSSESSED';

       l_asset_ret_dtls c_asset_ret_dtls%ROWTYPE;

       CURSOR c_fa_expense_ccid(
                p_book_type_code FA_CATEGORY_BOOKS.BOOK_TYPE_CODE%TYPE,
                p_category_id    FA_CATEGORY_BOOKS.CATEGORY_ID%TYPE) IS
       SELECT DEPRN_EXPENSE_ACCOUNT_CCID
       FROM   FA_CATEGORY_BOOKS
       WHERE  BOOK_TYPE_CODE = p_book_type_code
       AND    CATEGORY_ID    = p_category_id;

       l_fa_expense_ccid c_fa_expense_ccid%ROWTYPE;

       CURSOR c_cim_asset_id(p_cle_id IN NUMBER) IS
       SELECT ITM.ID
       FROM   OKC_K_ITEMS ITM,
              OKC_K_LINES_B CLE,
              OKC_LINE_STYLES_B LSE
       WHERE ITM.CLE_ID = cle.ID
       AND   CLE.CLE_ID = p_cle_id
       AND   CLE.LSE_ID = LSE.ID
       AND   LSE.LTY_CODE = 'FIXED_ASSET';

       l_cim_asset_id c_cim_asset_id%ROWTYPE;

       CURSOR c_get_fa_books( p_book_type_code FA_BOOKS.BOOK_TYPE_CODE%TYPE,
                              p_asset_id FA_BOOKS.ASSET_ID%TYPE) IS
       SELECT DEPRN_METHOD_CODE,
              LIFE_IN_MONTHS,
              COST,
              SALVAGE_VALUE
       FROM   FA_BOOKS
       WHERE  ASSET_ID = p_asset_id
       AND    BOOK_TYPE_CODE = p_book_type_code ;

       l_get_fa_books c_get_fa_books%ROWTYPE;

       l_set_of_books_id OKL_SYS_ACCT_OPTS.SET_OF_BOOKS_ID%TYPE;
       l_max_books NUMBER;

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

l_calling_interface Varchar2(30) := 'OKLRLTNB:Create_Repo_asset';
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_REPO_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;
l_pkg_name  VARCHAR2(30) := 'OKL_AM_LEASE_TRMNT_PVT';
l_asset_id NUMBER;
l_talv_rec               talv_rec_type;
x_talv_rec               talv_rec_type;

l_oec NUMBER;
l_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;
x_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;

l_txdv_rec     adpv_rec_type;
x_txdv_rec     adpv_rec_type;
l_line_detail_number NUMBER := 1;

l_asset_fin_rec_adj		    FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_rec_empty_adj    FA_API_TYPES.asset_fin_rec_type;
l_trans_empty_rec			FA_API_TYPES.trans_rec_type;

   l_asset_fin_rec_new		    FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new	    FA_API_TYPES.asset_fin_tbl_type;

   l_inv_trans_rec		        FA_API_TYPES.inv_trans_rec_type;
   l_asset_deprn_rec_adj	    FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new	    FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new	FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;
   l_tal_tld_id                     NUMBER;
   l_line_type                      VARCHAR2(1);

   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'Create_Repo_asset';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end

BEGIN

     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
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

  IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_khr_id = '||p_khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_kle_id = '||p_kle_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_corporate_book = '||p_corporate_book);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_tax_book_1 = '||p_tax_book_1);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_tax_book_2 = '||p_tax_book_2);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_rep_book = '||p_rep_book);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_fa_location_id = '||p_fa_location_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_asset_key_id = '||p_asset_key_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_depreciate_yn = '||p_depreciate_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_tas_id = '||p_tas_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_line_number = '||p_line_number);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_quote_id = '||p_quote_id);
  END IF;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  OPEN l_sub_line_csr(p_chr_id => p_khr_id,
                      p_lty_code => 'ITEM',
                      p_cle_id => p_kle_id);
  FETCH l_sub_line_csr INTO l_model_line_rec;
  CLOSE l_sub_line_csr;

  OPEN l_inv_item_csr(p_inv_item_id => TO_NUMBER(l_model_line_rec.object1_id1),
                      p_org_id      => TO_NUMBER(l_model_line_rec.object1_id2));
  FETCH l_inv_item_csr INTO l_inv_item_rec;
  CLOSE l_inv_item_csr;

  OPEN c_asset_description(p_kle_id);
  FETCH c_asset_description INTO l_asset_description;
  CLOSE c_asset_description;

  OPEN c_asset_ret_dtls(p_kle_id);
  FETCH c_asset_ret_dtls INTO l_asset_ret_dtls;
  CLOSE c_asset_ret_dtls;
  l_oec := l_asset_ret_dtls.asset_fmv_amount;

  l_set_of_books_id := OKL_ACCOUNTING_UTIL.GET_SET_OF_BOOKS_ID;

  /*IF (p_tax_book_2 IS NOT NULL AND p_tax_book_2 <> OKL_API.G_MISS_CHAR)
  THEN
    l_max_books := 3;
  ELSE
    l_max_books := 2;
  END IF;*/
  l_max_books := 4;

  FOR l_counter IN 1..l_max_books
  LOOP

    IF (l_counter=1) OR
       (l_counter=2 AND p_tax_book_1 IS NOT NULL
            AND p_tax_book_1 <> OKL_API.G_MISS_CHAR) OR
       (l_counter=3 AND p_tax_book_2 IS NOT NULL
            AND p_tax_book_2 <> OKL_API.G_MISS_CHAR) OR
       (l_counter=4 AND p_rep_book IS NOT NULL
            AND p_rep_book <> OKL_API.G_MISS_CHAR) THEN
    l_trans_rec.transaction_type_code := 'ADDITION';
    l_asset_desc_rec.asset_key_ccid:= p_asset_key_id;
    l_asset_desc_rec.current_units:= l_model_line_rec.number_of_items;
    l_asset_hdr_rec.asset_id          := NULL;

    IF (l_counter = 1) THEN
      l_asset_hdr_rec.book_type_code :=p_corporate_book;
    ELSIF (l_counter=2) THEN
      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code :=p_tax_book_1;
    ELSIF (l_counter=3) THEN
      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code :=p_tax_book_2;
    ELSE
      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code :=p_rep_book;
    END IF;

    l_asset_hdr_rec.set_of_books_id :=l_set_of_books_id;

    l_asset_desc_rec.asset_number       := l_asset_description.NAME;
    l_asset_desc_rec.description        := l_asset_description.ITEM_DESCRIPTION;

    l_asset_cat_rec.category_id :=l_inv_item_rec.asset_category_id;

    l_asset_fin_rec.set_of_books_id :=l_set_of_books_id;
    l_asset_fin_rec.date_placed_in_service := l_asset_ret_dtls.DATE_RETURNED;
    IF (NVL(p_depreciate_yn, 'N')  = 'N' ) THEN
      l_asset_fin_rec.depreciate_flag :='NO';
    ELSE
      l_asset_fin_rec.depreciate_flag :='YES';
    END IF;

    l_asset_fin_rec.contract_id            := p_khr_id;

    l_asset_dist_rec.units_assigned :=l_model_line_rec.number_of_items;
    OPEN c_fa_expense_ccid(
           l_asset_hdr_rec.book_type_code,
           l_inv_item_rec.asset_category_id);
    FETCH c_fa_expense_ccid INTO l_fa_expense_ccid;
    CLOSE c_fa_expense_ccid;

    --l_asset_dist_rec.expense_ccid :=140417;
    l_asset_dist_rec.expense_ccid :=l_fa_expense_ccid.DEPRN_EXPENSE_ACCOUNT_CCID;
    l_asset_dist_rec.location_ccid :=p_fa_location_id;
    l_asset_dist_tbl(1) := l_asset_dist_rec;

    /*IF (l_counter=1) THEN
      OPEN c_asset_fmv_amount(p_kle_id);
      FETCH c_asset_fmv_amount INTO l_oec;
      CLOSE c_asset_fmv_amount;
    END IF;*/

    l_asset_fin_rec.cost := l_oec;
    l_asset_fin_rec.original_cost := l_oec;

     IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling fa_addition_pub.do_addition');
   END IF;

   fa_addition_pub.do_addition
      (p_api_version             => l_api_version,
       p_init_msg_list           => OKL_API.G_FALSE,
       p_commit                  => OKL_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_calling_fn              => l_calling_interface,
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

     IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called fa_addition_pub.do_addition x_return_status = '||x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_asset_hdr_rec.asset_id = '||l_asset_hdr_rec.asset_id);
     END IF;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_asset_id := l_asset_hdr_rec.asset_id;
okl_debug_pub.logmessage('AKP:After do_addition: x_return_status=' || x_return_status || ' l_asset_id=' || l_asset_id);

    IF (l_counter =1) THEN
      OPEN c_cim_asset_id(p_kle_id);
      FETCH c_cim_asset_id INTO l_cim_asset_id;
      CLOSE c_cim_asset_id;

      l_cim_rec.id          := l_cim_asset_id.ID;
      l_cim_rec.object1_id1 := to_char(l_asset_id);
      l_cim_rec.object1_id2 := '#';

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling okl_okc_migration_pvt.update_contract_item');
      END IF;

      okl_okc_migration_pvt.update_contract_item(
            p_api_version                  => 1.0,
            p_init_msg_list                => okc_api.g_false,
            x_return_status                =>x_return_status,
            x_msg_count                    =>x_msg_count,
            x_msg_data                     =>x_msg_data,
            p_cimv_rec                     =>l_cim_rec,
            x_cimv_rec                     =>x_cim_rec);

       IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called okl_okc_migration_pvt.update_contract_item x_return_status = '||x_return_status);
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

okl_debug_pub.logmessage('AKP:After update_item: x_return_status=' || x_return_status || ' x_cim_rec.object1_id1=' || x_cim_rec.object1_id1);

      -- Now create 'Internal Asset Creation' transaction lines

      l_talv_rec.tal_type := G_TRANS_TYPE;
      l_talv_rec.asset_number := l_asset_description.NAME;
      l_talv_rec.dnz_khr_id            := p_khr_id;
      l_talv_rec.tas_id                := p_tas_id;
      l_talv_rec.line_number           := p_line_number;
      l_talv_rec.original_cost         := l_oec;
      l_talv_rec.current_units         := l_model_line_rec.number_of_items;
      l_talv_rec.year_manufactured     := l_model_line_rec.year_of_manufacture;
      l_talv_rec.Depreciation_Cost     := l_oec;
      l_talv_rec.kle_id                := p_kle_id;
      IF (NVL(p_depreciate_yn, 'N')  = 'N' ) THEN
        l_talv_rec.depreciate_yn                := 'N';
      ELSE
        l_talv_rec.depreciate_yn                := 'Y';
      END IF;

       IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_TXL_ASSETS_PUB.create_txl_asset_def');
      END IF;

      OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                         p_api_version    => 1,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_tlpv_rec       => l_talv_rec,
                         x_tlpv_rec       => x_talv_rec);

       IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_TXL_ASSETS_PUB.create_txl_asset_def x_return_status = '||x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'x_talv_rec.ID = '||x_talv_rec.ID);
      END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
okl_debug_pub.logmessage('AKP:x_return_status=' || x_return_status || 'x_talv_rec.ID=' || x_talv_rec.ID);

     --rkuttiya added for passing the line id to populate sources
     l_tal_tld_id := x_talv_rec.id;
     l_line_type  := 'L';
     --

   END IF;

    IF (l_counter > 1) THEN
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Before opening c_get_fa_books l_asset_hdr_rec.book_type_code = '||l_asset_hdr_rec.book_type_code);
      END IF;
okl_debug_pub.logmessage('AKP:Before open c_get_fa_books');
    OPEN c_get_fa_books(l_asset_hdr_rec.book_type_code, l_asset_id);
    FETCH c_get_fa_books INTO l_get_fa_books;
okl_debug_pub.logmessage('AKP:After fetch c_get_fa_books');
    IF c_get_fa_books%NOTFOUND THEN
      CLOSE c_get_fa_books;
    ELSE
      l_txdv_rec.OBJECT_VERSION_NUMBER := 1;
      l_txdv_rec.TAL_ID := x_talv_rec.ID;
      l_txdv_rec.LINE_DETAIL_NUMBER := l_line_detail_number;
      l_txdv_rec.ASSET_NUMBER := l_talv_rec.asset_number;

      l_txdv_rec.QUANTITY := l_model_line_rec.number_of_items;

      l_txdv_rec.COST := l_get_fa_books.COST;

      l_txdv_rec.TAX_BOOK := l_asset_hdr_rec.book_type_code;

      l_txdv_rec.LIFE_IN_MONTHS_TAX := l_get_fa_books.LIFE_IN_MONTHS;

      l_txdv_rec.DEPRN_METHOD_TAX := l_get_fa_books.DEPRN_METHOD_CODE;

      l_txdv_rec.SALVAGE_VALUE := l_get_fa_books.SALVAGE_VALUE;

      CLOSE c_get_fa_books;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_TXD_ASSETS_PUB.create_txd_asset_def');
      END IF;

      OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                           p_api_version    => 1,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_adpv_rec       => l_txdv_rec,
                           x_adpv_rec       => x_txdv_rec);

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called  OKL_TXD_ASSETS_PUB.create_txd_asset_def x_return_status = '||x_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'x_txdv_rec.ID = '||x_txdv_rec.ID);
      END IF;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

okl_debug_pub.logmessage('AKP:x_return_status=' || x_return_status || 'x_txdv_rec.ID=' || x_txdv_rec.ID);

      l_line_detail_number := l_line_detail_number + 1;

      --added by rkuttiya for populate sources
      l_tal_tld_id := x_txdv_rec.id;
      l_line_type  := 'D';
    --
    END IF;
    END IF;

    --call Populate Sources

      Populate_Sources(p_api_version     => l_api_version,
                       p_init_msg_list   => p_init_msg_list,
                       p_khr_id          => p_khr_id,
                       p_kle_id          => p_kle_id,
                       p_corporate_book  => l_asset_hdr_rec.book_type_code,
                       p_tas_id          => p_tas_id,
                       p_tal_id          => l_tal_tld_id,
                       p_line_type       => l_line_type,
                       p_fa_trx_id       => l_trans_rec.tranSaction_header_id,
                       p_asset_id        => l_asset_id,
                       p_quote_id        => p_quote_id,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      okl_debug_pub.logmessage('RK:x_return_status after populate sources' || x_return_status );


/* okl_debug_pub.logmessage('RK:Before calling FA Adjustment to delink the contract id..');
  --CALL TO FA_ADJUSTMENT PUB to delink the contract id
      l_trans_rec := l_trans_empty_rec;

      l_trans_rec.transaction_subtype := 'AMORTIZE';

      l_asset_fin_rec_adj := l_asset_fin_rec;
      l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;


                            fa_adjustment_pub.do_adjustment(
                                   p_api_version              => L_api_version,
    		                       p_init_msg_list            => OKC_API.G_FALSE,
    		                       p_commit                   => FND_API.G_FALSE,
    		                       p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
    		                       p_calling_fn               => NULL,
    		                       x_return_status            => x_return_status,
    		                       x_msg_count                => x_msg_count,
    		                       x_msg_data                 => x_msg_data,
    		                       px_trans_rec               => l_trans_rec,
    		                       px_asset_hdr_rec           => l_asset_hdr_rec,
    		                       p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
    		                       x_asset_fin_rec_new        => l_asset_fin_rec_new,
    		                       x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
    		                       px_inv_trans_rec           => l_inv_trans_rec,
    		                       px_inv_tbl                 => l_inv_tbl,
    		                       p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
    		                       x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
    		                       x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                   p_group_reclass_options_rec => l_group_reclass_options_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      okl_debug_pub.logmessage('RK:Return Status after calling FA Adjustment API'|| x_return_status);  */


  END IF;


  END LOOP;

  OKL_API.set_message( p_app_name      => 'OKL',
                       p_msg_name      => 'OKL_AM_ASSET_CR_SUCC',
                       p_token1        => 'ASSET_NUMBER',
                       p_token1_value  => l_asset_description.NAME);


  OKL_API.END_ACTIVITY (x_msg_count, x_msg_data );
  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
  END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_ASSET_CR_FAIL',
                           p_token1        => 'ASSET_NUMBER',
                           p_token1_value  => l_asset_description.NAME);

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_ASSET_CR_FAIL',
                           p_token1        => 'ASSET_NUMBER',
                           p_token1_value  => l_asset_description.NAME);

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
       IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_ASSET_CR_FAIL',
                           p_token1        => 'ASSET_NUMBER',
                           p_token1_value  => l_asset_description.NAME);

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');


END;


  -- Start of comments
  --
  -- Procedure Name : process_asset_dispose
  -- Desciption     : Calls the Asset disposition API to dispose off assets
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : SECHAWLA 31-DEC-02 Bug #2726739
  --                  Added logic to convert proceeds of sale amount to functional currency
  --                : RMUNJULU 04-FEB-03 2781557 Added code to get and set
  --                  proceeds of sale properly
  --                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
  --                : rmunjulu EDAT Added code to set trn_date as currency conversion trn date
  --                  also send quote eff date and quote acceptance date to disposal api
  --                : rmunjulu BUYOUT_PROCESS
  -- End of comments
  PROCEDURE process_asset_dispose(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           px_overall_status             IN  OUT NOCOPY VARCHAR2,
           p_sys_date                    IN DATE DEFAULT SYSDATE, -- rmunjulu EDAT
           px_tcnv_rec                   IN  OUT NOCOPY tcnv_rec_type,
           p_klev_tbl                    IN  klev_tbl_type,
           p_trn_already_set             IN  VARCHAR2,
     p_auto_invoice_yn             IN  VARCHAR2 DEFAULT NULL )  IS -- rmunjulu BUYOUT_PROCESS

   -- Cursor to get the asset id for the line
   CURSOR line_info_csr (p_l_id IN NUMBER) IS
     SELECT  asset_id,
             line_number
     FROM    OKX_ASSET_LINES_V    A
     WHERE   parent_line_id = p_l_id;

   -- Cursor to get the purchase amount for the line
   -- RMUNJULU 04-FEB-03 2781557 Changed cursor to get proper purchase amount lines
   CURSOR kle_pur_amt_csr  ( p_kle_id   IN NUMBER,
                             p_qte_id   IN NUMBER) IS
     SELECT amount
     FROM   OKL_TXL_QUOTE_LINES_V  TQL
     WHERE  kle_id = p_kle_id
     AND    qte_id = p_qte_id
     AND    qlt_code = 'AMBPOC'; -- Purchase Amount

   kle_pur_amt_rec           kle_pur_amt_csr%ROWTYPE;
   l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_dispose_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_asset_id                NUMBER;
   l_line_number             VARCHAR2(200);
   i                         NUMBER := 1;
   l_proceeds_of_sale        NUMBER;

   --SECHAWLA  Bug # 2726739 : new declarations
    l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_contract_curr_code         okc_k_headers_b.currency_code%TYPE;
    -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
    lx_contract_currency         okc_k_headers_v.currency_code%TYPE;
    lx_currency_conversion_type  okl_k_headers_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate  okl_k_headers_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date  okl_k_headers_v.currency_conversion_date%TYPE;
    lx_converted_amount          NUMBER;

    -- rmunjulu EDAT
    l_quote_accpt_date DATE;
    l_quote_eff_date DATE;

    -- rmunjulu BUYOUT_PROCESS
    l_invoice_amount NUMBER;

    -- Bug 6674730 start
    CURSOR c_get_repo_indicator(p_quote_id NUMBER) IS
           SELECT NVL(OTQV.REPO_QUOTE_INDICATOR_YN, 'N'),
                  KHR.DEAL_TYPE,
                  CHR.AUTHORING_ORG_ID
           FROM   OKL_TRX_QUOTES_V OTQV,
                  OKL_K_HEADERS KHR,
                  OKC_K_HEADERS_B CHR
           WHERE  OTQV.ID = p_quote_id
           AND    OTQV.KHR_ID = KHR.ID
           AND    KHR.ID = CHR.ID;

    l_repo_yn OKL_TRX_QUOTES_V.REPO_QUOTE_INDICATOR_YN%TYPE := 'N';
    l_deal_type OKL_K_HEADERS.DEAL_TYPE%TYPE;
    l_org_id OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE;

    CURSOR c_get_loan_repo_params(p_org_id NUMBER) IS
           --SELECT CORPORATE_BOOK,
           SELECT ASST_ADD_BOOK_TYPE_CODE CORPORATE_BOOK,
                  TAX_BOOK_1,
                  TAX_BOOK_2,
                  RPT_PROD_BOOK_TYPE_CODE,
                  FA_LOCATION_ID,
                  ASSET_KEY_ID,
                  DEPRECIATE_YN
           FROM   OKL_SYSTEM_PARAMS_ALL
           WHERE  ORG_ID = p_org_id;

    l_corporate_book OKL_SYSTEM_PARAMS_ALL.CORPORATE_BOOK%TYPE;
    l_tax_book_1 OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_1%TYPE;
    l_tax_book_2 OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_2%TYPE;
    l_rep_book   OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE;
    l_fa_location_id OKL_SYSTEM_PARAMS_ALL.FA_LOCATION_ID%TYPE;
    l_asset_key_id OKL_SYSTEM_PARAMS_ALL.ASSET_KEY_ID%TYPE;
    l_depreciate_yn OKL_SYSTEM_PARAMS_ALL.DEPRECIATE_YN%TYPE;

    CURSOR try_id_csr(p_try_name  OKL_TRX_TYPES_V.NAME%TYPE) IS
    SELECT id
    FROM   OKL_TRX_TYPES_tl
    WHERE  upper(name) = upper(p_try_name)
    AND    language = 'US';

    G_COL_NAME_TOKEN     CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
    G_NO_MATCHING_RECORD CONSTANT  VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';

    l_try_id  NUMBER;

    l_legal_entity_id         NUMBER;

    l_trxv_rec               trxv_rec_type;
    x_trxv_rec               trxv_rec_type;
    l_talv_rec               talv_rec_type;
    --l_line_number            NUMBER := 0;

l_pdt_parameter_rec  OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
l_pdtv_rec           OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
l_pdt_parameter_rec2 OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
x_no_data_found      BOOLEAN;


    -- Bug 6674730 end
  -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_asset_dispose';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

  ---
      -- set the dispose rec
      -- call asset dispose
      -- store the highest degree of error
      -- set the transaction record
  ---

      -- Start savepoint to rollback to if the block fails
      SAVEPOINT asset_dispose;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_trn_already_set = '||p_trn_already_set);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'px_tcnv_rec.tmt_asset_disposition_yn = '||px_tcnv_rec.tmt_asset_disposition_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'p_term_rec.p_quote_id = '||p_term_rec.p_quote_id);
      END IF;
      IF (p_trn_already_set = G_YES
          AND NVL(px_tcnv_rec.tmt_asset_disposition_yn, '?') <> G_YES)
      OR (p_trn_already_set = G_NO) THEN

          -- RMUNJULU 3018641 Step Message
          -- Step : Asset Dispose
          OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_ADP');

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

         -- rmunjulu EDAT
         -- If quote exists then accnting date is quote accept date else sysdate
         IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

             l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
             l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

         ELSE

             l_quote_accpt_date := p_sys_date;
             l_quote_eff_date :=  p_sys_date;

         END IF;

         -- 6674730 start
         IF (p_term_rec.p_quote_id IS NOT NULL AND
             p_term_rec.p_quote_id <> OKL_API.G_MISS_NUM) THEN
           OPEN c_get_repo_indicator(p_term_rec.p_quote_id);
           FETCH c_get_repo_indicator INTO l_repo_yn, l_deal_type, l_org_id;
           CLOSE c_get_repo_indicator;
         END IF;
         IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_repo_yn = '||l_repo_yn);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_deal_type = '||l_deal_type);
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_org_id = '||l_org_id);
         END IF;
         IF (l_repo_yn = 'Y' AND l_deal_type='LOAN') THEN
           -- Get system params for asset repossession
           OPEN c_get_loan_repo_params(l_org_id);
           FETCH c_get_loan_repo_params INTO
                 l_corporate_book,
                 l_tax_book_1,
                 l_tax_book_2,
                 l_rep_book,
                 l_fa_location_id,
                 l_asset_key_id,
                 l_depreciate_yn;

            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_K_RATE_PARAMS_PVT.get_product');
            END IF;
           -- Get PDT parameters and check reporting product and set l_rep_book
            OKL_K_RATE_PARAMS_PVT.get_product(
                 p_api_version   => p_api_version,
                 p_init_msg_list => p_init_msg_list,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_khr_id        => p_term_rec.p_contract_id,
                 x_pdt_parameter_rec => l_pdt_parameter_rec);
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_K_RATE_PARAMS_PVT.get_product x_return_status = '||x_return_status);
            END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_pdt_parameter_rec.reporting_pdt_id = '||l_pdt_parameter_rec.reporting_pdt_id);
            END IF;

            IF (l_pdt_parameter_rec.reporting_pdt_id IS NOT NULL AND
                l_pdt_parameter_rec.reporting_pdt_id <> OKL_API.G_MISS_NUM)
            THEN
              l_pdtv_rec.ID := l_pdt_parameter_rec.reporting_pdt_id;
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_SETUPPRODUCTS_PUB.Getpdt_parameters ');
            END IF;

              OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
                        p_api_version       => p_api_version,
                        p_init_msg_list     => p_init_msg_list,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_pdtv_rec          => l_pdtv_rec,
	                x_no_data_found     => x_no_data_found,
                        p_pdt_parameter_rec => l_pdt_parameter_rec2);
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_SETUPPRODUCTS_PUB.Getpdt_parameters x_return_status = '||x_return_status);
            END IF;

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              ELSIF  NVL(l_pdt_parameter_rec2.Name,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN
                 x_return_status := OKL_API.G_RET_STS_ERROR;
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF (l_pdt_parameter_rec2.DEAL_TYPE <> 'LOAN') THEN
                l_rep_book := NULL; -- No reporting book asset to be created
              END IF;

            ELSE
              l_rep_book := NULL; -- No reporting book asset to be created
            END IF;

         END IF;
         -- 6674730 end

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

          IF (p_klev_tbl.COUNT > 0) THEN

          -- Create 'Internal Asset Creation' transaction header
          -- get try id
          Open  try_id_csr(p_try_name => 'Internal Asset Creation');
          Fetch try_id_csr into l_try_id;
          If try_id_csr%NOTFOUND then
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_TRX_TYPES_V.ID');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          End If;
          Close try_id_csr;

          l_trxv_rec.try_id   := l_try_id;
          l_trxv_rec.tas_type := G_TRANS_TYPE;
          l_trxv_rec.tsu_code := 'PROCESSED';
          l_trxv_rec.date_trans_occurred := sysdate;

          l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id
                                       (p_term_rec.p_contract_id) ;
          IF  l_legal_entity_id IS NOT NULL THEN
            l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
          ELSE
	     Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  p_term_rec.p_contract_number);
               RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          /*-- Now creating the new header record
          OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => l_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;*/


            i := p_klev_tbl.FIRST;
            l_line_number := 1;
            LOOP

              -- Bug 6674730 start
              IF (l_repo_yn = 'Y' AND l_deal_type='LOAN') THEN

            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_TRX_ASSETS_PUB.create_trx_ass_h_def');
            END IF;

              -- Now creating the new header record
              OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => l_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_TRX_ASSETS_PUB.create_trx_ass_h_def x_return_status = '||x_return_status);
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'x_trxv_rec.ID =' ||x_trxv_rec.ID);
            END IF;

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;


                -- Create asset in FA for this KLE_ID
                --l_line_number := l_line_number + 1;
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling  Create_Repo_asset');
            END IF;

                Create_Repo_asset(
                   p_init_msg_list   => p_init_msg_list,
                   p_khr_id          => p_term_rec.p_contract_id,
                   p_kle_id          => p_klev_tbl(i).p_kle_id,
                   p_corporate_book  => l_corporate_book,
                   p_tax_book_1      => l_tax_book_1,
                   p_tax_book_2      => l_tax_book_2,
                   p_rep_book        => l_rep_book,
                   p_fa_location_id  => l_fa_location_id,
                   p_asset_key_id    => l_asset_key_id,
                   p_depreciate_yn   => l_depreciate_yn,
                   p_tas_id          => x_trxv_rec.ID,
                   p_line_number     => l_line_number,
                   p_quote_id        => p_term_rec.p_quote_id,
                   x_return_status   => x_return_status,
                   x_msg_count       => x_msg_count,
                   x_msg_data        => x_msg_data
                );
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'called  Create_Repo_asset x_return_status = '||x_return_status);
            END IF;

              IF  l_overall_dispose_status = OKL_API.G_RET_STS_SUCCESS
                  and x_return_status in (OKL_API.G_RET_STS_ERROR,OKL_API.G_RET_STS_UNEXP_ERROR) then
              l_overall_dispose_status := x_return_status;
              END IF;

              ELSE
              -- Bug 6674730 end

              -- Initialize proceeds_of_sale
              l_proceeds_of_sale := 0;

              IF p_auto_invoice_yn IS NULL
     OR p_auto_invoice_yn = 'N' THEN -- rmunjulu BUYOUT_PROCESS check if auto invoice due to buyout process

                -- Loop in the purchase amounts to set proceeds_of_sale
                FOR kle_pur_amt_rec
                 IN kle_pur_amt_csr(p_klev_tbl(i).p_kle_id, p_term_rec.p_quote_id) LOOP
                 l_proceeds_of_sale := l_proceeds_of_sale +
                                       kle_pur_amt_rec.amount;
                END LOOP;

              ELSE -- rmunjulu BUYOUT_PROCESS Proceeds calculated from terms and conditions

                 -- Derive value of sales proceeds
                get_purchase_amount(
                  p_term_rec        => p_term_rec,
                  p_kle_id          => p_klev_tbl(i).p_kle_id,
                  x_purchase_amount => l_invoice_amount,
                  x_return_status   => l_return_status);

                l_proceeds_of_sale := l_invoice_amount;

              END IF;

              -- RMUNJULU 04-FEB-03 2781557 Added if to set the proceeds of sales if no value
              IF l_proceeds_of_sale IS NULL  THEN

                l_proceeds_of_sale := 0;

              END IF;

              -- SECHAWLA  Bug # 2726739 : added the folowing piece of code

              -- get the functional currency
              l_func_curr_code := okl_am_util_pvt.get_functional_currency;
              -- get the contract currency
              l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => p_term_rec.p_contract_id);

              IF l_contract_curr_code <> l_func_curr_code  THEN
                    -- convert amount to functional currency
                    okl_accounting_util.convert_to_functional_currency(
                         p_khr_id              => p_term_rec.p_contract_id,
                         p_to_currency        => l_func_curr_code,
                         p_transaction_date     => l_quote_accpt_date , --px_tcnv_rec.date_transaction_occurred, -- rmunjulu EDAT
                         p_amount           => l_proceeds_of_sale,
                         x_return_status     =>  x_return_status,
                         x_contract_currency    => lx_contract_currency,
                      x_currency_conversion_type => lx_currency_conversion_type,
                      x_currency_conversion_rate => lx_currency_conversion_rate,
                      x_currency_conversion_date => lx_currency_conversion_date,
                      x_converted_amount      => lx_converted_amount );

                    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                        -- Error occurred during disposal of asset NAME.
                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                     p_msg_name      => 'OKL_AM_ERR_DISPOSAL',
                                     p_token1        => 'NAME',
                                     p_token1_value  => p_klev_tbl(i).p_asset_name);

                    END IF;

                    -- Raise exception to rollback to savepoint if error
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_proceeds_of_sale := lx_converted_amount ;

              END IF;

            -- RRAVIKIR Legal Entity Changes
              -- Populate the legal entity from the contract
              l_legal_entity_id :=
                OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id  => p_term_rec.p_contract_id);
              -- Legal Entity Changes end

               -- call asset dispose retirement
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling  OKL_AM_ASSET_DISPOSE_PUB.dispose_asset');
            END IF;

              OKL_AM_ASSET_DISPOSE_PUB.dispose_asset(
                 p_api_version                     => p_api_version,
                 p_init_msg_list                   => OKL_API.G_FALSE,
                 x_return_status                   => l_return_status,
                 x_msg_count                       => x_msg_count,
                 x_msg_data                        => x_msg_data,
                 p_financial_asset_id              => p_klev_tbl(i).p_kle_id,
                 p_quantity                        => NULL,
                 p_proceeds_of_sale                => l_proceeds_of_sale,
                 p_quote_eff_date                  => l_quote_eff_date,    -- rmunjulu EDAT Pass additional parameters now required by disposal api
                 p_quote_accpt_date                => l_quote_accpt_date,  -- rmunjulu EDAT Pass additional parameters now required by disposal api
                 p_legal_entity_id                 => l_legal_entity_id);  -- RRAVIKIR Legal Entity Changes
            IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called  OKL_AM_ASSET_DISPOSE_PUB.dispose_asset l_return_status = '||l_return_status);
            END IF;

              -- -- SECHAWLA  Bug # 2726739 : end new code

/*               -- call asset dispose retirement
              OKL_AM_ASSET_DISPOSE_PUB.dispose_asset(
                 p_api_version                     => p_api_version,
                 p_init_msg_list                   => OKL_API.G_FALSE,
                 x_return_status                   => l_return_status,
                 x_msg_count                       => x_msg_count,
                 x_msg_data                        => x_msg_data,
                 p_financial_asset_id              => p_klev_tbl(i).p_kle_id,
                 p_quantity                        => NULL,
                 p_proceeds_of_sale                => l_proceeds_of_sale,
                 p_quote_eff_date                  => l_quote_eff_date,    -- rmunjulu EDAT Pass additional parameters now required by disposal api
                 p_quote_accpt_date                => l_quote_accpt_date); -- rmunjulu EDAT Pass additional parameters now required by disposal api
*/
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                -- Error occurred during disposal of asset NAME.
                OKL_API.set_message( p_app_name      => G_APP_NAME,
                                     p_msg_name      => 'OKL_AM_ERR_DISPOSAL',
                                     p_token1        => 'NAME',
                                     p_token1_value  => p_klev_tbl(i).p_asset_name);

              END IF;
     --08-mar-06 sgorantl -- Bug 3895098
     IF  l_overall_dispose_status = OKL_API.G_RET_STS_SUCCESS
         and l_return_status in (OKL_API.G_RET_STS_ERROR,OKL_API.G_RET_STS_UNEXP_ERROR) then
     l_overall_dispose_status := l_return_status;
     END IF;

              END IF;
              EXIT WHEN (i = p_klev_tbl.LAST);
              i := p_klev_tbl.NEXT(i);
            END LOOP;

       --08-mar-06 sgorantl -- Bug 3895098
              -- Raise exception to rollback to savepoint if error
              IF (l_overall_dispose_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_overall_dispose_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
       --08-mar-06 sgorantl -- Bug 3895098

            -- Set success message
            -- Asset dispostion for assets of contract CONTRACT_NUMBER done successfully.
            OKL_API.set_message( p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_AM_ASS_DISPOSE_SUCCESS',
                                 p_token1       => 'CONTRACT_NUMBER',
                                 p_token1_value => p_term_rec.p_contract_number);

            -- store the highest degree of error
            set_overall_status(
              p_return_status                 => l_overall_dispose_status,
              px_overall_status               => px_overall_status);

            -- set the transaction record for asset disposition
            set_transaction_rec(
              p_return_status                 => l_overall_dispose_status,
              p_overall_status                => px_overall_status,
              p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
              p_tsu_code                      => 'WORKING',
              px_tcnv_rec                     => px_tcnv_rec);

          END IF;
      END IF;

      -- set the transaction record for amortization
      set_transaction_rec(
             p_return_status                 => l_return_status,
             p_overall_status                => px_overall_status,
             p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
             p_tsu_code                      => 'WORKING',
             p_ret_val                       => NULL,
             px_tcnv_rec                     => px_tcnv_rec);

      -- set the transaction record for asset return
      set_transaction_rec(
             p_return_status                 => l_return_status,
             p_overall_status                => px_overall_status,
             p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
             p_tsu_code                      => 'WORKING',
             p_ret_val                       => NULL,
             px_tcnv_rec                     => px_tcnv_rec);

    x_return_status      := l_return_status;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF kle_pur_amt_csr%ISOPEN THEN
            CLOSE kle_pur_amt_csr;
         END IF;

         ROLLBACK TO asset_dispose;

         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record for amortization
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record for asset return
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

         IF kle_pur_amt_csr%ISOPEN THEN
            CLOSE kle_pur_amt_csr;
         END IF;

         ROLLBACK TO asset_dispose;


         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record for amortization
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record for asset return
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF kle_pur_amt_csr%ISOPEN THEN
            CLOSE kle_pur_amt_csr;
         END IF;

         ROLLBACK TO asset_dispose;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record for amortization
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record for asset return
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_asset_dispose;

  -- Start of comments
  --
  -- Procedure Name : process_amortize_and_return
  -- Desciption     : Calls the Amortization API and Asset Return API to do
  --                  amortization and then return of assets of contract
  -- Business Rules :
  -- Parameters  :
  -- Version  : 1.0
  -- History        : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
  --                : RMUNJULU 04-MAR-04 3485854 Changed the code to make call to
  --                  process_amortize proc instead of having the code in this proc
  --                : rmunjulu EDAT modified code to check for quote exists to set reason code
  --                  Also pass date_returned as quote eff date
  --                : rmunjulu EDAT Removed code to set date_returned
  --
  -- End of comments
  PROCEDURE process_amortize_and_return(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN term_rec_type,
           px_overall_status             IN OUT NOCOPY VARCHAR2,
           px_tcnv_rec                   IN OUT NOCOPY tcnv_rec_type,
           p_sys_date                    IN DATE,
           p_klev_tbl                    IN klev_tbl_type,
           p_trn_already_set             IN  VARCHAR2)  IS

   -- Cursor to get the end date of contract
   -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   CURSOR get_k_end_date_csr ( p_khr_id IN NUMBER) IS
    SELECT end_date
    FROM   OKC_K_HEADERS_V
    WHERE  id =  p_khr_id;

   -- Get the non-cancelled asset return for asset
   CURSOR get_asset_return_csr ( p_kle_id IN NUMBER) IS
    SELECT id id,
           OKL_AM_UTIL_PVT.get_lookup_meaning('OKL_ASSET_RETURN_STATUS',ars_code,'N') ret_status
    FROM   OKL_ASSET_RETURNS_V
    WHERE  kle_id = p_kle_id
    AND    ars_code <> 'CANCELLED';

   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;
   lx_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;

   i                       NUMBER := 1;
   j                       NUMBER := 1;
   l_kle_id                NUMBER;
   l_k_end_date            DATE := OKL_API.G_MISS_DATE;
   l_early_term_yn         VARCHAR2(1) := G_NO;
   l_return_needed         VARCHAR2(1) := G_NO;
   l_asset_return_status   VARCHAR2(2000);

   l_temp_klev_tbl         klev_tbl_type;

   -- rmunjulu EDAT
   l_quote_accpt_date DATE;
   l_quote_eff_date DATE;
   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'process_amortize_and_return';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

  --
      -- set the amortization rec
      -- call amortization
      -- store the highest degree of error
      -- set the transaction record

      -- set the return rec
      -- call asset return
      -- store the highest degree of error
      -- set the transaction record
  ---

    SAVEPOINT amortize_and_return;

    ----------------------------
    --- START ASSET AMORTIZATION
    ----------------------------
/* -- RMUNJULU 04-MAR-04 3485854 Removed this code for amortization and added call to
-- process_amortize to do amortization
    BEGIN  -- begin for amortize

      -- Start a savepoint
      SAVEPOINT asset_amortize;

      -- Check if amortization required
      IF (p_trn_already_set = G_YES
          AND NVL(px_tcnv_rec.tmt_amortization_yn, '?') <> G_YES)
      OR (p_trn_already_set = G_NO) THEN

          -- RMUNJULU 3018641 Step Message
          -- Step : Amortization
          OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_AMT');

          -- call amortization

          OPEN  get_k_end_date_csr(p_term_rec.p_contract_id);
          FETCH get_k_end_date_csr INTO l_k_end_date;
          CLOSE get_k_end_date_csr;

          IF (l_k_end_date <> OKL_API.G_MISS_DATE)
          AND (TRUNC(l_k_end_date) > TRUNC(p_sys_date)) THEN
            l_early_term_yn := G_YES;
          END IF;

          OKL_AM_AMORTIZE_PUB.create_offlease_asset_trx(
            p_api_version                => p_api_version,
            p_init_msg_list              => OKL_API.G_FALSE,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            p_contract_id                 => p_term_rec.p_contract_id,
            p_early_termination_yn        => l_early_term_yn);


          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occurred during the creation of an amortization transaction
            -- for assets of contract CONTRACT_NUMBER.
            OKL_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_AM_ERR_AMORTIZE',
                                 p_token1        => 'CONTRACT_NUMBER',
                                 p_token1_value  => p_term_rec.p_contract_number);

          END IF;

          -- Raise exception to rollback to savepoint if error
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- store the highest degree of error
          set_overall_status(
            p_return_status               => l_return_status,
            px_overall_status             => px_overall_status);

          -- set the transaction record for amortization
          set_transaction_rec(
            p_return_status               => l_return_status,
            p_overall_status              => px_overall_status,
            p_tmt_flag                    => 'TMT_AMORTIZATION_YN',
            p_tsu_code                    => 'WORKING',
            px_tcnv_rec                   => px_tcnv_rec);

      END IF;
    EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN

         IF get_k_end_date_csr%ISOPEN THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;

         x_return_status := OKL_API.G_RET_STS_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

         IF get_k_end_date_csr%ISOPEN THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

      WHEN OTHERS THEN

         IF get_k_end_date_csr%ISOPEN THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

    END;
*/

-- RMUNJULU 04-MAR-04 3485854 added call to process_amortize to do amortization
-- Additional checks in process_amortize to cater to evergreen scenario
    process_amortize(
                p_api_version       => p_api_version,
                p_init_msg_list     => OKL_API.G_FALSE,
                x_return_status     => l_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_term_rec          => p_term_rec,
                px_overall_status   => px_overall_status,
                px_tcnv_rec         => px_tcnv_rec,
                p_sys_date          => p_sys_date,
                p_trn_already_set   => p_trn_already_set,
                p_call_origin       => 'TERMINATION');

    ----------------------
    --- START ASSET RETURN
    ----------------------

    BEGIN -- begin asset return

      SAVEPOINT asset_return;

      -- Check if asset return required
      IF (p_trn_already_set = G_YES
          AND NVL(px_tcnv_rec.tmt_asset_return_yn, '?') <> G_YES)
      OR (p_trn_already_set = G_NO) THEN

          -- RMUNJULU 3018641 Step Message
          -- Step : Asset Return
          OKL_API.set_message(
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_STEP_ART');

          -- if assets present for contract
          IF (p_klev_tbl.COUNT > 0) THEN


    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

              -- rmunjulu EDAT
              -- If quote exists then accnting date is quote accept date else sysdate
              IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

                 l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
                 l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

              ELSE

                 l_quote_accpt_date := p_sys_date;
                 l_quote_eff_date :=  p_sys_date;

              END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

              -- Loop thru assets table
              i := p_klev_tbl.FIRST;
              LOOP

                l_return_needed := G_NO;

                -- Check if return created
                OPEN  get_asset_return_csr (p_klev_tbl(i).p_kle_id);
                FETCH get_asset_return_csr INTO l_kle_id, l_asset_return_status;
                IF get_asset_return_csr%NOTFOUND OR l_kle_id IS NULL THEN
                   l_return_needed := G_YES;
                END IF;
                CLOSE get_asset_return_csr;

                -- if no return try creating else set message
                IF l_return_needed = G_YES THEN


                  -- set the temp table to contain all assets returned NOW
                  l_temp_klev_tbl(j).p_kle_id := p_klev_tbl(i).p_kle_id;
                  l_temp_klev_tbl(j).p_asset_name := p_klev_tbl(i).p_asset_name;
                  j := j + 1;

                  -- set the asset return id
                  lp_artv_rec.kle_id    :=  p_klev_tbl(i).p_kle_id;

                  -- set the art1_code for asset return --'OKL_ASSET_RETURN_TYPE'
                  -- if early termination assume from quote else contract exp
--                  IF (l_k_end_date <> OKL_API.G_MISS_DATE)
--                  AND (TRUNC(l_k_end_date) < TRUNC(p_sys_date)) THEN
                  -- rmunjulu EDAT modified condition to say if quote exists then EXE_TERMINATION_QUOTE else EXPIRATION
                  IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN -- rmunjulu EDAT
                     lp_artv_rec.art1_code := 'EXE_TERMINATION_QUOTE';
                  ELSE
                     lp_artv_rec.art1_code := 'CONTRACT_EXPIRATION';
                  END IF;

                  -- set the ars_code for asset return --'OKL_ASSET_RETURN_STATUS'
                  --Bug #3925453: pagarg +++ T and A +++++++ Start ++++++++++
                  if p_term_rec.p_quote_type = 'TER_RELEASE_WO_PURCHASE'
                  then
                      lp_artv_rec.ars_code := 'RELEASE_IN_PROCESS';
                  else
                      lp_artv_rec.ars_code := 'SCHEDULED';
                  end if;
                  --Bug #3925453: pagarg +++ T and A +++++++ End ++++++++++

                  --lp_artv_rec.date_returned := l_quote_eff_date; -- rmunjulu EDAT added to send return date

                  --Bug #3925453: pagarg +++ T and A ++++
                  -- Passing quote_id also to create_asset_return
                  -- call asset return
                  OKL_AM_ASSET_RETURN_PUB.create_asset_return(
                    p_api_version                => p_api_version,
                    p_init_msg_list              => OKL_API.G_FALSE,
                    x_return_status              => l_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data,
                    p_artv_rec       => lp_artv_rec,
                    x_artv_rec       => lx_artv_rec,
                    p_quote_id                    => p_term_rec.p_quote_id);

                  IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                    -- Error occurred during the creation of an asset return record
                    -- for asset  NAME.
                    OKL_API.set_message(
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => 'OKL_AM_ERR_ASS_RET',
                            p_token1        => 'NAME',
                            p_token1_value  => p_klev_tbl(i).p_asset_name);

                    -- Raise exception to rollback to savepoint if error
                    RAISE OKL_API.G_EXCEPTION_ERROR;

                  END IF;

                ELSE -- Asset return already exists -- This is not an error

                  -- Asset Return already exists for this asset NAME with the
                  -- status STATUS so cannot create a new asset return now.
                  OKL_API.set_message(
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => 'OKL_AM_ASS_RET_ARS_ERR',
                            p_token1        => 'NAME',
                            p_token1_value  =>  p_klev_tbl(i).p_asset_name,
                            p_token2        => 'STATUS',
                            p_token2_value  =>  l_asset_return_status);

                END IF;
                EXIT WHEN (i = p_klev_tbl.LAST);
                i := p_klev_tbl.NEXT(i);
              END LOOP;

              -- Set success messages once all returns done NOW
              IF l_temp_klev_tbl.COUNT > 0 THEN
                i := l_temp_klev_tbl.FIRST;
                LOOP

                    -- Asset return created for asset  NAME.
                    OKL_API.set_message(
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => 'OKL_AM_ASS_RET_CREATED',
                            p_token1        => 'NAME',
                            p_token1_value  => l_temp_klev_tbl(i).p_asset_name);

                  EXIT WHEN (i = l_temp_klev_tbl.LAST);
                  i := l_temp_klev_tbl.NEXT(i);
                END LOOP;
              END IF;

              -- set the transaction record for asset return
              set_transaction_rec(
                p_return_status               => l_return_status,
                p_overall_status              => px_overall_status,
                p_tmt_flag                    => 'TMT_ASSET_RETURN_YN',
                p_tsu_code                    => 'WORKING',
                px_tcnv_rec                   => px_tcnv_rec);

              -- Set overall status
              set_overall_status(
                p_return_status               => l_return_status,
                px_overall_status             => px_overall_status);

          END IF;
      END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         IF get_asset_return_csr%ISOPEN THEN
            CLOSE get_asset_return_csr;
         END IF;

         ROLLBACK TO asset_return;

         x_return_status := OKL_API.G_RET_STS_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;


         IF get_asset_return_csr%ISOPEN THEN
            CLOSE get_asset_return_csr;
         END IF;

         ROLLBACK TO asset_return;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         IF get_asset_return_csr%ISOPEN THEN
            CLOSE get_asset_return_csr;
         END IF;

         ROLLBACK TO asset_return;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

    END;

    -- set the transaction record for asset disose
    set_transaction_rec(
            p_return_status               => l_return_status,
            p_overall_status              => px_overall_status,
            p_tmt_flag                    => 'TMT_ASSET_DISPOSITION_YN',
            p_tsu_code                    => 'WORKING',
            p_ret_val                     => NULL,
            px_tcnv_rec                   => px_tcnv_rec);

    x_return_status      := l_return_status;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
        END IF;

         ROLLBACK TO amortize_and_return;

         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;


         ROLLBACK TO amortize_and_return;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

         ROLLBACK TO amortize_and_return;

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         -- store the highest degree of error
         set_overall_status(
               p_return_status                 => x_return_status,
               px_overall_status               => px_overall_status);

         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_AMORTIZATION_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_RETURN_YN',
               p_tsu_code                      => 'ERROR',
               px_tcnv_rec                     => px_tcnv_rec);
         -- set the transaction record
         set_transaction_rec(
               p_return_status                 => x_return_status,
               p_overall_status                => px_overall_status,
               p_tmt_flag                      => 'TMT_ASSET_DISPOSITION_YN',
               p_tsu_code                      => 'ERROR',
               p_ret_val                       => NULL,
               px_tcnv_rec                     => px_tcnv_rec);

         -- Set the oracle error message
         OKL_API.set_message(
                         p_app_name      => OKC_API.G_APP_NAME,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => SQLCODE,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => SQLERRM);

  END process_amortize_and_return;

  -- Start of comments
  --
  -- Procedure Name : lease_termination
  -- Desciption     : Main API which does the termination of Lease
  --                 Always rollback the whole process if processing transaction
  --                 fails this is done or else we lose information as to
  --                 the success/failure of different APIs
  --                 if the process is rolled back, then it will be picked
  --                 again by the batch_process
  -- Business Rules :
  -- Parameters     :
  -- History        : RMUNJULU 31-JAN-03 2780539 Added TER_MAN_PURCHASE check
  --                : RMUNJULU 27-JUN-03 3023206 Removed Process_Close_Streams
  --                  from this procedure as it is now called from
  --                  update_k_hdr_and_lines
  --                : RMUNJULU 3061751  Changed code to create a termination
  --                  trn even when request is NON BATCH and validation has failed
  --                : RMUNJULU 3018641 Added code to get and set TMG_RUN on OKL_TRX_MSGS
  --                : RMUNJULU 11-MAR-04 3485854 Changed the IF after evergreen to check for ERROR properly
  --                : rmunjulu EDAT Added code to get quote eff dates and set them as global
  --                : PAGARG 01-Mar-05 Bug 4190887 Pass klev_tbl to process_accounting_entries
  --                : rmunjulu BUYOUT_PROCESS
  -- Version     : 1.0
  --
  -- End of comments
  PROCEDURE lease_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type) IS
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_tcnv_rec             tcnv_rec_type;
   lx_stmv_tbl             stmv_tbl_type;
   lx_adjv_rec             adjv_rec_type;
   lx_ajlv_tbl             ajlv_tbl_type;
   lp_klev_tbl             klev_tbl_type;
   lx_klev_tbl             klev_tbl_type;
   lx_chrv_rec             chrv_rec_type;
   lx_clev_tbl             clev_tbl_type;
   lx_id                   NUMBER;
   i                       NUMBER := 1;
   l_tran_started          VARCHAR2(1)  := OKL_API.G_FALSE;
   l_evergreen_status      VARCHAR2(1)  := OKL_API.G_FALSE;
   l_api_name              VARCHAR2(30) := 'lease_termination';
   l_sys_date              DATE;
   l_trn_already_set       VARCHAR2(1)  := G_NO;
   lx_contract_status      VARCHAR2(200);
   l_validate              VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
   l_api_version           CONSTANT NUMBER := 1;
   l_status                VARCHAR2(200);
   l_term_rec              term_rec_type := p_term_rec;

   -- rmunjulu BUYOUT_PROCESS
   l_auto_invoice_yn  VARCHAR2(3);
   l_purchase_amount NUMBER;
   -- Added for bug# 6964174
--start:|  05-29-08 cklee -- fixed bug: 7017824(R12)/OKL.H: bug#6964174              |
      l_is_securitized    VARCHAR2(1) := OKC_API.G_FALSE;
      l_inv_agmt_chr_id_tbl OKL_SECURITIZATION_PVT.inv_agmt_chr_id_tbl_type;
--end:|  05-29-08 cklee -- fixed bug: 7017824(R12)/OKL.H: bug#6964174              |

   -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'lease_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end

  BEGIN
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

    -- Set the transaction
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    -- Rollback if error setting activity for api
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the x return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- store the highest degree of error
    set_overall_status(
           p_return_status               => l_return_status,
           px_overall_status             => l_overall_status);

    -- If the termination request is from quote, populate the rest of the quote attributes
    set_database_values(
           px_term_rec                   => l_term_rec);

    -- Set the info messages intially
    set_info_messages(
           p_term_rec                    => l_term_rec);

    -- check if transaction already exists
    IF (p_tcnv_rec.id IS NOT NULL AND p_tcnv_rec.id <> OKL_API.G_MISS_NUM) THEN
      l_trn_already_set := G_YES;
    END IF;

    --get sysdate
    SELECT SYSDATE INTO l_sys_date FROM DUAL;

    IF l_trn_already_set = G_NO THEN

      -- initialize the transaction rec
      initialize_transaction (
          px_tcnv_rec                   => lp_tcnv_rec,
          p_term_rec                    => l_term_rec,
          p_sys_date                    => l_sys_date,
          p_control_flag                => 'CREATE',
	  x_return_status               => l_return_status,
 	  --akrangan bug 5354501 fix start
 	  x_msg_count                   => x_msg_count,
 	  x_msg_data                    => x_msg_data);
	  --akrangan bug 5354501 fix end
      -- rollback if intialize transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- insert the transaction record
      process_transaction(
          p_api_version                => p_api_version,
          p_init_msg_list              => OKL_API.G_FALSE,
          x_return_status              => l_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data,
          p_id                          => 0,
          p_term_rec                    => l_term_rec,
          p_tcnv_rec                    => lp_tcnv_rec,
          x_id                          => lx_id,
          p_trn_mode                    => 'INSERT');

      -- rollback if processing transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- set the trn rec id
      lp_tcnv_rec.id := lx_id;

    ELSE -- transaction already set

      lp_tcnv_rec := p_tcnv_rec;

      -- initialize the transaction rec
      initialize_transaction (
          px_tcnv_rec                   => lp_tcnv_rec,
          p_term_rec                    => l_term_rec,
          p_sys_date                    => l_sys_date,
          p_control_flag                => 'UPDATE',
	  x_return_status               => l_return_status,
 	  --akrangan bug 5354501 fix start
 	  x_msg_count                   => x_msg_count,
 	  x_msg_data                    => x_msg_data);
	  --akrangan bug 5354501 fix end


      -- rollback if intialize transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

    -- rmunjulu EDAT Get the quote effectivity date and quote acceptance date
    -- and store as global variables, will be used later on in other procedures
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling    OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates');
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_term_rec.p_quote_id = '||l_term_rec.p_quote_id);
    END IF;

    OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates(
          p_qte_id              => l_term_rec.p_quote_id,
          x_return_status       => l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called    OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates');
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_return_status = '||l_return_status);
    END IF;

    -- Rollback if error setting activity for api
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

    -- check if lease valid
    validate_lease(
        p_api_version                   => p_api_version,
        p_init_msg_list                 => OKL_API.G_FALSE,
        x_return_status                 => l_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data,
        p_sys_date                       => l_sys_date,
        p_term_rec                       => l_term_rec);

    -- Store the validation return status
    l_validate  := l_return_status;

    -- store the highest degree of error
    set_overall_status(
        p_return_status                  => l_return_status,
        px_overall_status                => l_overall_status);

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_term_rec.p_control_flag = '||l_term_rec.p_control_flag);
    END IF;

    IF (l_term_rec.p_control_flag = 'BATCH_PROCESS') THEN

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Calling OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract');
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_term_rec.p_contract_id = '||l_term_rec.p_contract_id);
    END IF;

      -- Since batch process is not checked initially in LLT check here
      OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 => p_api_version,
           p_init_msg_list               => OKL_API.G_FALSE,
           x_return_status               => l_return_status,
           x_msg_count                   => x_msg_count,
           x_msg_data                    => x_msg_data,
           p_contract_id                 => l_term_rec.p_contract_id,
           p_control_flag                => l_term_rec.p_control_flag,
           x_contract_status             => lx_contract_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'Called OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract l_return_status = '||l_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name  ,'l_validate = '||l_validate);
    END IF;

      -- Store the highest validation return status
      -- To capture the return status of validate lease called above
      IF (l_validate = OKL_API.G_RET_STS_SUCCESS) THEN
        l_validate  := l_return_status;
      END IF;

      -- store the highest degree of error
      set_overall_status(
        p_return_status                 => l_validate, -- RMUNJULU 3018641 Changed from l_return_status
        px_overall_status               => l_overall_status);

      -- set the transaction record
      set_transaction_rec(
        p_return_status                 => l_validate, -- RMUNJULU 3018641 Changed from l_return_status
        p_overall_status                => l_overall_status,
        p_tmt_flag                      => 'TMT_VALIDATED_YN',
        p_tsu_code                      => 'ENTERED',
        px_tcnv_rec                     => lp_tcnv_rec);

      -- if validation failed then insert transaction
      -- AND abort else continue next process
      IF (l_validate <> OKL_API.G_RET_STS_SUCCESS) THEN

        -- Validation of contract failed.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_VAL_OF_K_FAILED');

        -- set the transaction record
        set_transaction_rec(
          p_return_status               => l_validate, -- RMUNJULU 3018641 Changed from l_return_status
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_VALIDATED_YN',
          p_tsu_code                    => 'ERROR',
          px_tcnv_rec                   => lp_tcnv_rec);

        -- update the transaction record
        process_transaction(
          p_api_version                => p_api_version,
          p_init_msg_list              => OKL_API.G_FALSE,
          x_return_status              => l_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data,
          p_id                          => 0,
          p_term_rec                    => l_term_rec,
          p_tcnv_rec                    => lp_tcnv_rec,
          x_id                          => lx_id,
          p_trn_mode                    => 'UPDATE');

        -- rollback if processing transaction failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Save messages from stack into transaction message table
        OKL_AM_UTIL_PVT.process_messages(
         p_trx_source_table            => 'OKL_TRX_CONTRACTS',
         p_trx_id                     => lp_tcnv_rec.id,
         x_return_status                => l_return_status);

        -- RMUNJULU 3018641 Added code to get and set TMG_RUN
        OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);

        -- abort since validation failed
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    ELSE --( not from batch process) then

/* -- RMUNJULU 3061751 Changed this code to create a termination trn even when
-- request is NON BATCH and validation has failed

      -- rollback if validation failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- set the transaction record
      set_transaction_rec(
        p_return_status                 => l_return_status,
        p_overall_status                => l_overall_status,
        p_tmt_flag                      => 'TMT_VALIDATED_YN',
        p_tsu_code                      => 'ENTERED',
        px_tcnv_rec                     => lp_tcnv_rec);
*/

        -- RMUNJULU 3061751 Changed this code to create a termination trn even when
        -- request is NON BATCH and validation has failed

        IF (l_validate <> OKL_API.G_RET_STS_SUCCESS) THEN

        -- Validation of contract failed.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_VAL_OF_K_FAILED');

        -- set the transaction record
        set_transaction_rec(
          p_return_status               => l_validate, -- RMUNJULU 3018641 Changed from l_return_status
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_VALIDATED_YN',
          p_tsu_code                    => 'ERROR',
          px_tcnv_rec                   => lp_tcnv_rec);

        -- update the transaction record
        process_transaction(
          p_api_version                => p_api_version,
          p_init_msg_list              => OKL_API.G_FALSE,
          x_return_status              => l_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data,
          p_id                            => 0,
          p_term_rec                      => l_term_rec,
          p_tcnv_rec                      => lp_tcnv_rec,
          x_id                            => lx_id,
          p_trn_mode                      => 'UPDATE');

        -- rollback if processing transaction failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Save messages from stack into transaction message table
        OKL_AM_UTIL_PVT.process_messages(
         p_trx_source_table    => 'OKL_TRX_CONTRACTS',
         p_trx_id         => lp_tcnv_rec.id,
         x_return_status        => l_return_status);

        -- RMUNJULU 3018641 Added code to get and set TMG_RUN
        OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);

        -- abort since validation failed
        RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

    END IF;

    -- get the lines
    get_contract_lines(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_term_rec                      => l_term_rec,
        x_klev_tbl                      => lx_klev_tbl);

    -- check and process an evergreen lease
    process_evergreen_contract(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_term_rec                      => l_term_rec,
          p_sys_date                      => l_sys_date,
          p_trn_already_set               => l_trn_already_set,
          p_klev_tbl                      => lx_klev_tbl, -- pagarg 4190887 Added
          px_overall_status               => l_overall_status,
          px_tcnv_rec                     => lp_tcnv_rec,
          x_evergreen_status              => l_evergreen_status);

    -- Update transaction only if evergreen was found and successful or if error
    IF  (l_evergreen_status = G_YES
         AND l_return_status = OKL_API.G_RET_STS_SUCCESS)
    -- RMUNJULU 11-MAR-04 3485854
    -- Changed the IF condition to check for ERROR properly
    OR  (l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN

      -- update the transaction record
      process_transaction(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_id                            => 0,
          p_term_rec                      => l_term_rec,
          p_tcnv_rec                      => lp_tcnv_rec,
          x_id                            => lx_id,
          p_trn_mode                      => 'UPDATE');

      -- rollback if processing transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Save messages from stack into transaction message table
      OKL_AM_UTIL_PVT.process_messages(
       p_trx_source_table               => 'OKL_TRX_CONTRACTS',
       p_trx_id                        => lp_tcnv_rec.id,
       x_return_status                   => l_return_status);

        -- RMUNJULU 3018641 Added code to get and set TMG_RUN
        OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);

      -- abort since evergreen was found
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- do cancellation of insurance
    process_cancel_insurance(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_term_rec                      => l_term_rec,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        p_sys_date                      => l_sys_date,
        p_trn_already_set               => l_trn_already_set);

    -- rmunjulu Check the buyout process BUYOUT_PROCESS
    check_auto_invoice_yn(
           p_term_rec        => l_term_rec,
           x_auto_invoce_yn  => l_auto_invoice_yn,
           x_return_status   => l_return_status);

    -- do closing of balances
    process_close_balances(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_term_rec                      => l_term_rec,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        x_adjv_rec                      => lx_adjv_rec,
        x_ajlv_tbl                      => lx_ajlv_tbl,
        p_sys_date                      => l_sys_date,
        p_trn_already_set               => l_trn_already_set,
        p_auto_invoice_yn               => l_auto_invoice_yn, -- rmunjulu BUYOUT_PROCESS
  p_klev_tbl                      => lx_klev_tbl); -- rmunjulu BUYOUT_PROCESS

    -- RMUNJULU BUG # 3023206 Moved Close Streams into update_k_hdr_and_lines
    -- as accounting uses some CURR streams and so they should not be closed
    -- before accounting is done

/*
    -- process close streams
    process_close_streams(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_term_rec                      => l_term_rec,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        x_stmv_tbl                      => lx_stmv_tbl,
        p_sys_date                      => l_sys_date,
        p_trn_already_set               => l_trn_already_set);
*/
    -- do accounting entries
    process_accounting_entries(
         p_api_version                  => p_api_version,
         p_init_msg_list                => OKL_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_sys_date                     => l_sys_date,
         p_klev_tbl                     => lx_klev_tbl, -- PAGARG 4190887 Added
         p_trn_already_set              => l_trn_already_set);

    -- RMUNJULU 31-JAN-03 2780539 Added TER_MAN_PURCHASE which is also a
    -- termination with purchase
    IF (l_term_rec.p_quote_type IN('TER_PURCHASE',
                                   'TER_RECOURSE',
                                   'TER_ROLL_PURCHASE',
                                   'TER_MAN_PURCHASE')) THEN

      -- do asset dispose
      process_asset_dispose(
         p_api_version                  => p_api_version,
         p_init_msg_list                => OKL_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         p_sys_date                     => l_sys_date, -- rmunjulu EDAT -- pass sysdate to asset dispose api
         px_tcnv_rec                    => lp_tcnv_rec,
         p_klev_tbl                     => lx_klev_tbl,
         p_trn_already_set              => l_trn_already_set);

      -- Amortization of assets not needed since termination with purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_AMORTIZE_NOT_NEED');

      -- Return of assets not needed since termination with purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_RETURN_NOT_NEED');

    ELSIF (l_auto_invoice_yn = 'Y')   THEN -- rmunjulu BUYOUT_PROCESS

      process_asset_dispose(
         p_api_version                  => p_api_version,
         p_init_msg_list                => OKL_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         p_sys_date                     => l_sys_date,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_klev_tbl                     => lx_klev_tbl,
         p_trn_already_set              => l_trn_already_set,
   p_auto_invoice_yn              => l_auto_invoice_yn); -- rmunjulu BUYOUT_PROCESS

      -- Amortization of assets not needed since termination with purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_AMORTIZE_NOT_NEED');

      -- Return of assets not needed since termination with purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_RETURN_NOT_NEED');

    ELSE
      -- do amortization and asset return
      process_amortize_and_return(
         p_api_version                  => p_api_version,
         p_init_msg_list                => OKL_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_sys_date                     => l_sys_date,
         p_klev_tbl                     => lx_klev_tbl,
         p_trn_already_set              => l_trn_already_set);

      -- Disposition of assets not needed since termination without purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_DISPOSE_NOT_NEED');

    END IF;

    -- update the contract only if the overall_status is success
    IF (l_overall_status = OKL_API.G_RET_STS_SUCCESS) THEN
--start:|  05-29-08 cklee -- fixed bug: 7017824(R12)/OKL.H: bug#6964174              |
        -- Added Bug# 6964174 - Start
             -- Introduced the call to modify pool content api to inactivate pool contents
             -- and recreate them. This was initially present as part of the early termination
             -- workflow and the inactivation portion as part of the bug fix is being moved from
             -- the workflow to the last step in termination transaction so that the accounting
             -- transaction like termination billing, termination accounting can have special
             -- accounting before the pool contents are inactivated.

             -- Logic to run only for early termination -- check for quote_id
             IF l_term_rec.p_quote_id IS NOT NULL AND l_term_rec.p_quote_id <> OKL_API.G_MISS_NUM THEN
               -- Check if contract is securitized for RENT
               OKL_SECURITIZATION_PVT.check_khr_securitized(
                                 p_api_version          => p_api_version
                                ,p_init_msg_list        => OKL_API.G_FALSE
                                ,x_return_status        => l_return_status
                                ,x_msg_count            => x_msg_count
                                ,x_msg_data             => x_msg_data
                                ,p_khr_id               => l_term_rec.p_contract_id
                                ,p_effective_date       => okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date
                                ,p_stream_type_subclass => 'RENT'
                                ,x_value                => l_is_securitized
                                ,x_inv_agmt_chr_id_tbl  => l_inv_agmt_chr_id_tbl );
           -- rollback if processing transaction failed
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

               -- if contract is securitized, then call the modify pool contents. Prior to fix for bug# 6964174
               -- this was present in OKL_AM_SECURITIZATION_PVT.create_pool_transaction
               IF l_is_securitized = OKC_API.G_TRUE THEN
                 OKL_SECURITIZATION_PVT.MODIFY_POOL_CONTENTS
                   ( p_api_version        => p_api_version
                    ,p_init_msg_list      => OKL_API.G_FALSE
                    ,p_transaction_reason => OKL_SECURITIZATION_PVT.G_TRX_REASON_EARLY_TERMINATION
                    ,p_khr_id             => l_term_rec.p_contract_id
                    ,p_stream_type_subclass => 'RENT'
                    ,p_transaction_date   => okl_am_lease_loan_trmnt_pvt.g_quote_accept_date
                    ,p_effective_date     => okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date
                    ,x_return_status      => l_return_status
                    ,x_msg_count          => x_msg_count
                    ,x_msg_data           => x_msg_data  );
             -- rollback if processing transaction failed
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
               END IF;
             END IF;
             -- Added Bug# 6964174 - End
--end:|  05-29-08 cklee -- fixed bug: 7017824(R12)/OKL.H: bug#6964174              |

      -- Set the p_status (which sets the sts_code) for the contract
      IF  l_term_rec.p_control_flag = 'BATCH_PROCESS'
      AND (   l_term_rec.p_quote_id IS NULL
           OR l_term_rec.p_quote_id = OKL_API.G_MISS_NUM) THEN
         l_status := 'EXPIRED';
      ELSE
         l_status := 'TERMINATED';
      END IF;

      -- set_and_update_contract
      update_k_hdr_and_lines(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_status                       => l_status,
        p_term_rec                      => l_term_rec,
        p_klev_tbl                      => lx_klev_tbl,
        p_trn_reason_code               => lp_tcnv_rec.trn_code,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        x_chrv_rec                      => lx_chrv_rec,
        x_clev_tbl                      => lx_clev_tbl,
        p_sys_date                      => l_sys_date);

      IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

        -- set the transaction record
        set_transaction_rec(
          p_return_status               => l_return_status,
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_CONTRACT_UPDATED_YN',
          p_tsu_code                    => 'PROCESSED',
          px_tcnv_rec                   => lp_tcnv_rec);

      ELSE -- Update of K hdr and lines failed

        -- Contract table update failed.
        OKL_API.set_message( p_app_name => G_APP_NAME,
                             p_msg_name => 'OKL_AM_ERR_K_UPD');

        -- set the transaction record
        set_transaction_rec(
          p_return_status               => l_return_status,
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_CONTRACT_UPDATED_YN',
          p_tsu_code                    => 'ERROR',
          px_tcnv_rec                   => lp_tcnv_rec);
      END IF;
    END IF;

    -- update the transaction record
    process_transaction(
          p_api_version                => p_api_version,
          p_init_msg_list              => OKL_API.G_FALSE,
          x_return_status              => l_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data,
          p_id                          => 0,
          p_term_rec                    => l_term_rec,
          p_tcnv_rec                    => lp_tcnv_rec,
          x_id                          => lx_id,
          p_trn_mode                    => 'UPDATE');

    -- rollback if processing transaction failed
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Save messages from stack into transaction message table
    OKL_AM_UTIL_PVT.process_messages(
     p_trx_source_table               => 'OKL_TRX_CONTRACTS',
     p_trx_id                        => lp_tcnv_rec.id,
     x_return_status                   => l_return_status);

        -- RMUNJULU 3018641 Added code to get and set TMG_RUN
        OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);

    -- Set the return status

    x_return_status  :=  OKL_API.G_RET_STS_SUCCESS;


    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT_VALIDATION');
        END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
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
        IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
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
        IF (is_debug_exception_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
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
    END lease_termination;


END OKL_AM_LEASE_TRMNT_PVT;

/
