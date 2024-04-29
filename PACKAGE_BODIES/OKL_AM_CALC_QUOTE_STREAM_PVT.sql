--------------------------------------------------------
--  DDL for Package Body OKL_AM_CALC_QUOTE_STREAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CALC_QUOTE_STREAM_PVT" AS
/* $Header: OKLRCQSB.pls 120.15.12010000.5 2010/02/24 00:52:21 sachandr ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION		CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_calc_quote_stream_pvt.';

--G_OUTSTANDING_BAL_DONE VARCHAR2(3); -- RMUNJULU 4691487 -- rmunjulu 4996136 remv from here and declare in spec

-- Start of comments
--
-- Procedure Name : add_element
-- Description  : Save a quote line
-- Business Rules :
-- Parameters  : contract line, stream type,
--     table of quote line records,
-- Version  : 1.0
-- History              : SECHAWLA 02-DEC-02 - Bug 2680542
--                        Added NOCOPY for IN OUT parameters
--                : rmunjulu 3797384 Added code for passing quote_eff_from date
--                  and quote_id to formula engine
-- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
-- End of comments

PROCEDURE add_element (
  p_qtev_rec		IN qtev_rec_type,
  p_cle_id		IN NUMBER,
  p_sty_id		IN NUMBER,
  p_formula_name	IN VARCHAR2,
  p_prorate_ratio	IN NUMBER,
  p_asset_cle_id	IN NUMBER,
  px_seq_num		IN OUT NOCOPY NUMBER,
  px_total		IN OUT NOCOPY NUMBER,
  px_tqlv_tbl		IN OUT NOCOPY tqlv_tbl_type,
  x_return_status	OUT NOCOPY VARCHAR2) IS

 l_tqlv_rec  tqlv_rec_type;
 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_formula_name  VARCHAR2(150);
 l_rule_value  NUMBER;
 l_params  okl_execute_formula_pub.ctxt_val_tbl_type;

-- for debug logging
L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'add_element';
is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

 IF  p_formula_name IS NOT NULL
 AND p_formula_name <> G_MISS_CHAR THEN
  l_formula_name := p_formula_name;
 ELSE
  l_formula_name := G_DEFAULT_FORMULA;
 END IF;

 l_params(1).name := G_FORMULA_PARAM_1;
 l_params(1).value := p_sty_id;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

    -- set the operands for formula engine with quote_effective_from date
    l_params(2).name := 'quote_effective_from_date';
    l_params(2).value := to_char(p_qtev_rec.date_effective_from,'MM/DD/YYYY');  -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

    -- set the operands for formula engine with quote_id
    l_params(3).name := 'quote_id';
    l_params(3).value := to_char(p_qtev_rec.id);

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End   ++++++++++++++++


 okl_am_util_pvt.get_formula_value (
  p_formula_name  => l_formula_name,
  p_chr_id  => p_qtev_rec.khr_id,
  p_cle_id  => p_cle_id,
  p_additional_parameters => l_params,
  x_formula_value  => l_rule_value,
  x_return_status  => l_return_status);

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_util_pvt.get_formula_value :'||l_return_status);
   END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 --okl_execute_formula_pub.g_additional_parameters(1).name  := G_FORMULA_PARAM_1;
 --okl_execute_formula_pub.g_additional_parameters(1).value := p_sty_id;
 --l_tqlv_rec.amount := okl_seeded_functions_pvt.line_unbilled_streams
 --  (p_qtev_rec.khr_id, p_cle_id);

 IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
 AND l_rule_value IS NOT NULL THEN

  l_tqlv_rec.kle_id := NVL (p_asset_cle_id, p_cle_id);
  l_tqlv_rec.sty_id := p_sty_id;
  l_tqlv_rec.amount := l_rule_value * p_prorate_ratio;

  px_seq_num  := px_seq_num + 1;
  px_tqlv_tbl(px_seq_num) := l_tqlv_rec;
  px_total  := px_total + l_tqlv_rec.amount;

 END IF;

 x_return_status := l_overall_status;

 IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN

 	IF (is_debug_exception_on) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		   || sqlcode || ' , SQLERRM : ' || sqlerrm);
	END IF;
  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END add_element;


-- Start of comments
--
-- Procedure Name : process_specific_line_style
-- Description  : Calculate unbilled streams for specific line styles
-- Business Rules :
-- Parameters  : operand, quote header record, contract line,
--     table of quote line records,
--     top line st
--History           : SECHAWLA 27-JAN-03 Bug # 2759726
--                    Changed the last group by column in the cursor l_linked_unbilled_streams_csr to capital_amount
--                  : SECHAWLA 04-MAR-03
--                      Commented out the condition sty.capitalize_yn = 'N' from the cursor selects
--                  : SECHAWLA 21-APR-03 2925120
--                      Modified procedure to get only future Service and Fee amounts. Replaced the use of hard coded
--                      value '1' for the prorate ratio of service and fee lines with global G_PRORATE_RATIO
--                  : rmunjulu EDAT Modified to get stream > quote eff date
--                  : rmunjulu 09-Dec-2004 bug 4056186 Modified cursor to get correct streams and modified NVL func
--                  : akrangan 12-Mar-2007 bug 5495474, check global flags to prevent duplicate for 'AMYFEE'
-- End of comments

PROCEDURE process_specific_line_style (
  p_operand IN VARCHAR2,
  p_qtev_rec IN qtev_rec_type,
  p_cle_id IN NUMBER,
  p_top_style IN VARCHAR2,
  p_link_style IN VARCHAR2,
  p_formula_name IN VARCHAR2,
  px_tqlv_tbl IN OUT NOCOPY tqlv_tbl_type,
  x_operand_total OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

 -- Select all unbilled streams for all contract lines of
 -- particular style and their linked sublines

    -- SECHAWLA 21-APR-03 2925120 : Added quote_eff_date parameter to the following cursor to get only future Service amd Maintenance abd Fee amounts
 CURSOR l_style_unbilled_streams_csr (
  cp_chr_id NUMBER,
  cp_top_style VARCHAR2,
  cp_link_style VARCHAR2,
        cp_quote_eff_date DATE) IS
  SELECT stm.kle_id   contract_line_id,
   stm.sty_id   stream_type_id
     FROM okl_streams   stm,
   okl_strm_type_b   sty,
   okc_k_lines_b   kle,
   okc_statuses_b   kls,
   okc_line_styles_b  lse,
            okl_strm_elements       ste                    -- SECHAWLA 21-APR-03 2925120 :Added this table
  WHERE stm.khr_id   = cp_chr_id
  AND stm.active_yn   = 'Y'
  AND stm.say_code   = 'CURR'
        AND ste.stm_id   = stm.id                   -- SECHAWLA 21-APR-03 2925120  : Added this condition
        AND ste.stream_element_date > cp_quote_eff_date   -- SECHAWLA 21-APR-03 2925120  : Added this condition  -- rmunjulu EDAT
  AND sty.id    = stm.sty_id
  AND sty.billable_yn   = 'Y'
  --AND sty.capitalize_yn  = 'N'   -- SECHAWLA 04-MAR-03
  AND kle.id    = stm.kle_id
  AND kls.code   = kle.sts_code
  AND kls.ste_code   = 'ACTIVE'
  AND lse.id    = kle.lse_id
  AND lse.lty_code   IN (cp_top_style, cp_link_style)
  GROUP BY stm.kle_id,
   stm.sty_id;

 -- Select unbilled streams linked to an asset
    --SECHAWLA 27-JAN-03 Bug # 2759726 : Changed the last column in the group by clause to capital_amount

    -- SECHAWLA 21-APR-03 2925120 : Added quote_eff_date parameter to the following cursor to get only future Service amd Maintenance abd Fee amounts
 CURSOR l_linked_unbilled_streams_csr (
  cp_chr_id NUMBER,
  cp_cle_id NUMBER,
  cp_link_style VARCHAR2,
        cp_quote_eff_date DATE) IS
  SELECT stm.kle_id   contract_line_id,
   stm.sty_id   stream_type_id,
   kle.capital_amount  line_payment
     FROM okc_k_items   ite,
   okc_k_lines_b   cle,
   okl_k_lines_v   kle,
   okc_line_styles_b  lse,
   okl_streams        stm,
   okl_strm_type_b   sty,
            okl_strm_elements       ste                      -- SECHAWLA 21-APR-03 2925120 :Added this table
  WHERE ite.object1_id1   = cp_cle_id
  AND cle.id    = ite.cle_id
  AND lse.id    = cle.lse_id
  AND lse.lty_code  = cp_link_style
  AND kle.id    = cle.id
  AND stm.kle_id   = cle.id -- rmunjulu bug 4056186 Check with Cle.id NOT cle.cle_id
  AND stm.khr_id   = cp_chr_id
  AND stm.active_yn  = 'Y'
  AND stm.say_code  = 'CURR'
        AND ste.stm_id   = stm.id                     -- SECHAWLA 21-APR-03 2925120 : Added this condition
        AND ste.stream_element_date > cp_quote_eff_date     -- SECHAWLA 21-APR-03 2925120 : Added this condition -- rmunjulu EDAT
  AND sty.id    = stm.sty_id
  AND sty.billable_yn  = 'Y'
 -- AND sty.capitalize_yn  = 'N'   -- SECHAWLA 04-MAR-03
  GROUP BY stm.kle_id,
   stm.sty_id,
   kle.capital_amount;

 -- Select total payments
 CURSOR l_total_payments_csr (
  cp_cle_id NUMBER,
  cp_link_style VARCHAR2) IS
  SELECT sum (kle.capital_amount) total_payment
  FROM okc_k_lines_b   cle,
   okl_k_lines_v   kle,
   okc_line_styles_b  lse
  WHERE cle.cle_id   = cp_cle_id
  AND lse.id    = cle.lse_id
  AND lse.lty_code   = cp_link_style
  AND kle.id    = cle.id;

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_total   NUMBER := 0;
 l_seq   NUMBER := NVL (px_tqlv_tbl.LAST, 0);
 l_total_payment  NUMBER;
 l_prorate_ratio  NUMBER;

     L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_specific_line_style';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


 IF  NVL (p_qtev_rec.partial_yn, 'N') <> 'Y'
 AND p_cle_id IS NULL
 --akrangan Bug 5495474 start
 AND ((p_top_style <> G_SERVICE_STYLE AND NVL(G_CONTRACTUAL_FEE_DONE,'N') <> 'Y')
  OR (p_top_style = G_SERVICE_STYLE AND NVL(G_SERVICE_BAL_DONE,'N') <> 'Y')
     )
 THEN
 --akrangan Bug 5495474 end

     -- **********************************************
     -- Get unbilled streams for all contract lines of
     -- particular style and their linked sublines
     -- **********************************************
        --SECHAWLA 21-APR-03 2925120 : Added date_effective_from parameter to the following cursor call
     FOR l_cont_str_rec IN l_style_unbilled_streams_csr
  (p_qtev_rec.khr_id, p_top_style, p_link_style, p_qtev_rec.date_effective_from  ) LOOP

   add_element (
    p_qtev_rec => p_qtev_rec,
    p_cle_id => l_cont_str_rec.contract_line_id,
    p_sty_id => l_cont_str_rec.stream_type_id,
    p_formula_name => p_formula_name,
    p_prorate_ratio => G_PRORATE_RATIO,  -- SECHAWLA 21-APR-03 2925120 : Use a global instead of hardcoded value 1
    p_asset_cle_id => NULL,
    px_seq_num => l_seq,
    px_total => l_total,
    px_tqlv_tbl => px_tqlv_tbl,
    x_return_status => l_return_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to add_element :'||l_return_status);
   END IF;



     END LOOP;
        --akrangan Bug 5495474 start
        --G_SERVICE_BAL_DONE := 'Y'; -- rmunjulu  5066471
	IF (p_top_style = G_SERVICE_STYLE) THEN
		G_SERVICE_BAL_DONE := 'Y';
	ELSE
		G_CONTRACTUAL_FEE_DONE := 'Y';
	END IF;
	--akrangan Bug 5495474 end
 ELSIF p_cle_id IS NOT NULL THEN

     -- ***************************************
     -- Get unbilled streams linked to an asset
     -- ***************************************

        --SECHAWLA 21-APR-03 2925120 : Added date_effective_from parameter to the following cursor call
     FOR l_link_str_rec IN l_linked_unbilled_streams_csr
  (p_qtev_rec.khr_id, p_cle_id, p_link_style, p_qtev_rec.date_effective_from) LOOP

   l_total_payment := 0;
   OPEN l_total_payments_csr
     (l_link_str_rec.contract_line_id, p_link_style);
   FETCH l_total_payments_csr INTO l_total_payment;
   CLOSE l_total_payments_csr;

   IF NVL (l_total_payment, 0) <> 0 THEN -- rmunjulu bug 4056186 check NVL with 0 NOT 1
    l_prorate_ratio := NVL (l_link_str_rec.line_payment, 1) /
         NVL (l_total_payment, 1);
   ELSE
    l_prorate_ratio := G_PRORATE_RATIO; -- SECHAWLA 21-APR-03 2925120  : Use a global instead of hardcoded value 1;
   END IF;

   add_element (
    p_qtev_rec => p_qtev_rec,
    p_cle_id => l_link_str_rec.contract_line_id,
    p_sty_id => l_link_str_rec.stream_type_id,
    p_formula_name => p_formula_name,
    p_prorate_ratio => l_prorate_ratio,
    p_asset_cle_id => p_cle_id,
    px_seq_num => l_seq,
    px_total => l_total,
    px_tqlv_tbl => px_tqlv_tbl,
    x_return_status => l_return_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to add_element :'||l_return_status);
   END IF;

     END LOOP;

 END IF;

 x_operand_total := l_total;
 x_return_status := l_overall_status;

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

 WHEN OTHERS THEN

 	IF (is_debug_exception_on) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		   || sqlcode || ' , SQLERRM : ' || sqlerrm);
	END IF;


  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END process_specific_line_style;


-- Start of comments
--
-- Procedure Name : process_unbilled_receivables
-- Description  : Calculate unbilled receivables
-- Business Rules :
-- Parameters  : operand, quote header record, contract line,
--     table of quote line records,
--     list of styles to be excluded
-- Version      : 1.0
--                  : SECHAWLA 04-MAR-03
--                      Commented out the condition sty.capitalize_yn = 'N' from the cursor selects
--                  : SECHAWLA 21-APR-03 2925120
--                      Modified procedure to calculate only future Unbilled Receivables
--                  : rmunjulu EDAT Modified to get stream > quote eff date
--                  : rmunjulu 5005225 do not calc unbilled for evergreen contracts
--                  : akrangan 12-Mar-2007 bug 5495474, check global flags to prevent duplicate
-- End of comments

PROCEDURE process_unbilled_receivables (
  p_operand IN VARCHAR2,
  p_qtev_rec IN qtev_rec_type,
  p_cle_id IN NUMBER,
  p_exclude_all_styles IN VARCHAR2,
  p_exclude_link_styles IN VARCHAR2,
  px_tqlv_tbl IN OUT NOCOPY tqlv_tbl_type,
  x_operand_total OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

 -- Note on cursor below:
 -- When this package is created, this cursor should always
 -- return zero rows, but it may change in future releases.
 -- Currently all billable streams are assigned to lines
 -- and therefore there are no streams attached to a contract

 -- Select all unbilled streams for a contract
    -- SECHAWLA 21-APR-03 2925120 : Added cp_quote_eff_date parameter to this cursor to get only future Unbilled Streams
 CURSOR l_contract_unbill_rcvbl_csr (
  cp_chr_id NUMBER,
        cp_quote_eff_date DATE) IS
  SELECT stm.kle_id   contract_line_id,
   stm.sty_id   stream_type_id,
   SUM (ste.amount)  amount_due
     FROM okl_streams   stm,
   okl_strm_elements  ste,
   okl_strm_type_b   sty
  WHERE stm.khr_id   = cp_chr_id
  AND stm.kle_id   IS NULL
  AND stm.active_yn   = 'Y'
  AND stm.say_code   = 'CURR'
  AND ste.stm_id   = stm.id
--  AND ste.date_billed   IS NULL -- rmunjulu EDAT FIXES Removed date billed as future bills are adjusted.
        AND ste.stream_element_date > cp_quote_eff_date  -- SECHAWLA 21-APR-03 2925120 :Added this condition -- rmunjulu EDAT
  AND NVL (ste.amount, 0)  <> 0
  AND sty.id    = stm.sty_id
  AND sty.billable_yn   = 'Y'
  --AND sty.capitalize_yn  = 'N'   -- SECHAWLA 04-MAR-03
  GROUP BY stm.kle_id,
   stm.sty_id;

 -- Select all unbilled streams for all contract lines
 -- of all styles except designated excluded styles

    -- SECHAWLA 21-APR-03 2925120 : Added cp_quote_eff_date parameter to this cursor to get only future Unbilled Streams
 CURSOR l_all_lines_unbill_rcvbl_csr (
  cp_chr_id   NUMBER,
  cp_exclude_styles VARCHAR2,
        cp_quote_eff_date DATE) IS
  SELECT stm.kle_id   contract_line_id,
   stm.sty_id   stream_type_id,
   SUM (ste.amount)  amount_due
     FROM okl_streams   stm,
   okl_strm_elements  ste,
   okl_strm_type_b   sty,
   okc_k_lines_b   kle,
   okc_statuses_b   kls,
   okc_line_styles_b  lse
  WHERE stm.khr_id   = cp_chr_id
  AND stm.active_yn   = 'Y'
  AND stm.say_code   = 'CURR'
  AND ste.stm_id   = stm.id
--  AND ste.date_billed   IS NULL -- rmunjulu EDAT FIXES Removed date billed as future bills are adjusted.
        AND ste.stream_element_date > cp_quote_eff_date  -- SECHAWLA 21-APR-03 2925120 :Added this condition -- rmunjulu EDAT
  AND NVL (ste.amount, 0)  <> 0
  AND sty.id    = stm.sty_id
  AND sty.billable_yn   = 'Y'
  --AND sty.capitalize_yn  = 'N'   -- SECHAWLA 04-MAR-03
  AND kle.id    = stm.kle_id
  AND kls.code   = kle.sts_code
  AND kls.ste_code   = 'ACTIVE'
  AND lse.id    = kle.lse_id
  AND cp_exclude_styles  NOT LIKE
   '%' || G_SEP || lse.lty_code || G_SEP || '%'
  GROUP BY stm.kle_id,
   stm.sty_id;

 -- Select all unbilled streams for a line
    -- SECHAWLA 21-APR-03 2925120 : Added cp_quote_eff_date parameter to this cursor to get only future Unbilled Streams
 CURSOR l_line_unbill_rcvbl_csr (
  cp_chr_id NUMBER,
  cp_cle_id NUMBER,
        cp_quote_eff_date DATE) IS
  SELECT stm.kle_id   contract_line_id,
   stm.sty_id   stream_type_id,
   SUM (ste.amount)  amount_due
     FROM okl_streams   stm,
   okl_strm_elements  ste,
   okl_strm_type_b   sty
  WHERE stm.khr_id   = cp_chr_id
  AND stm.kle_id   = cp_cle_id
  AND stm.active_yn   = 'Y'
  AND stm.say_code   = 'CURR'
  AND ste.stm_id   = stm.id
--  AND ste.date_billed   IS NULL -- rmunjulu EDAT FIXES Removed date billed as future bills are adjusted.
        AND ste.stream_element_date > cp_quote_eff_date  -- SECHAWLA 21-APR-03 2925120 :Added this condition -- rmunjulu EDAT
  AND NVL (ste.amount, 0)  <> 0
  AND sty.id    = stm.sty_id
  AND sty.billable_yn   = 'Y'
 -- AND sty.capitalize_yn  = 'N'   -- SECHAWLA 04-MAR-03
  GROUP BY stm.kle_id,
   stm.sty_id;

 -- Note on cursor below:
 -- When this package is created, this cursor should always
 -- return zero rows, but it may change in future releases.
 -- Currently all linked lines are handled in specific routines
 -- and therefore are included into list of excluded styles

 -- Select unbilled streams linked to an asset
 -- except designated excluded styles
    -- SECHAWLA 21-APR-03 2925120 : Added cp_quote_eff_date parameter to this cursor to get only future Unbilled Streams
 CURSOR l_linked_line_unbill_rcvbl_csr (
  cp_chr_id   NUMBER,
  cp_cle_id   NUMBER,
  cp_exclude_styles VARCHAR2,
        cp_quote_eff_date DATE) IS
  SELECT stm.kle_id   contract_line_id,
   stm.sty_id   stream_type_id,
   SUM (ste.amount)  amount_due
     FROM okc_k_items   ite,
   okc_k_lines_b   kle,
   okc_line_styles_b  lse,
   okl_streams   stm,
   okl_strm_type_b   sty,
   okl_strm_elements  ste
  WHERE ite.object1_id1   = to_char(cp_cle_id) -- rmunjulu bug 5129653 need to_char as object1_id1 can be alphanumeric
  AND kle.id    = ite.cle_id
  AND lse.id    = kle.lse_id
  AND cp_exclude_styles  NOT LIKE
   '%' || G_SEP || lse.lty_code || G_SEP || '%'
  AND stm.kle_id   = kle.id
  AND stm.khr_id   = cp_chr_id
  AND stm.active_yn   = 'Y'
  AND stm.say_code   = 'CURR'
  AND sty.id    = stm.sty_id
  AND sty.billable_yn   = 'Y'
  --AND sty.capitalize_yn  = 'N'   -- SECHAWLA 04-MAR-03
  AND ste.stm_id   = stm.id
--  AND ste.date_billed   IS NULL -- rmunjulu EDAT FIXES Removed date billed as future bills are adjusted.
        AND ste.stream_element_date > cp_quote_eff_date  -- SECHAWLA 21-APR-03 2925120 Added this condition -- rmunjulu EDAT
  AND NVL (ste.amount, 0)  <> 0
  GROUP BY stm.kle_id,
   stm.sty_id;

 l_tqlv_rec  tqlv_rec_type;
 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_total   NUMBER := 0;
 l_seq   NUMBER := NVL (px_tqlv_tbl.LAST, 0);

 -- rmunjulu bug 5005225
    CURSOR get_k_sts_csr (p_khr_id IN NUMBER) IS
    SELECT chr.sts_code
    FROM   OKC_K_HEADERS_B chr
    WHERE  chr.id = p_khr_id;

 -- rmunjulu bug 5005225
    l_sts_code OKC_K_HEADERS_B.sts_code%TYPE;

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_unbilled_receivables';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

 -- rmunjulu bug 5005225
    OPEN get_k_sts_csr (p_qtev_rec.khr_id);
    FETCH get_k_sts_csr INTO l_sts_code;
    CLOSE get_k_sts_csr;

 IF  NVL (p_qtev_rec.partial_yn, 'N') <> 'Y'
 AND p_cle_id IS NULL
 AND NVL(G_UNBILLED_RECEIVABLES_DONE,'N') <> 'Y' --akrangan bug 5495474
 AND l_sts_code <> 'EVERGREEN' THEN -- rmunjulu bug 5005225

     -- ***********************************
     -- Get unbilled streams for a contract
     -- ***********************************
        -- SECHAWLA 21-APR-03 2925120 : Added date_effective_from parameter to the cursor call
     FOR l_cont_rcv_rec IN l_contract_unbill_rcvbl_csr
  (p_qtev_rec.khr_id, p_qtev_rec.date_effective_from ) LOOP

  l_tqlv_rec.amount := l_cont_rcv_rec.amount_due;
  l_tqlv_rec.kle_id := l_cont_rcv_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_cont_rcv_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_cont_rcv_rec.amount_due;

     END LOOP;

     -- **********************************************
     -- Get unbilled streams for all contract lines of
     -- all styles except designated excluded styles
     -- **********************************************

        -- SECHAWLA 21-APR-03 2925120 : Added date_effective_from parameter to the cursor call
     FOR l_all_rcv_rec IN l_all_lines_unbill_rcvbl_csr
  (p_qtev_rec.khr_id, p_exclude_all_styles, p_qtev_rec.date_effective_from) LOOP


  l_tqlv_rec.amount := l_all_rcv_rec.amount_due;
  l_tqlv_rec.kle_id := l_all_rcv_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_all_rcv_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_all_rcv_rec.amount_due;

     END LOOP;
   G_UNBILLED_RECEIVABLES_DONE := 'Y'; -- akrangan bug 5495474
 ELSIF p_cle_id IS NOT NULL
    AND l_sts_code <> 'EVERGREEN' THEN -- rmunjulu bug 5005225

     -- *******************************
     -- Get unbilled streams for a line
     -- *******************************

        -- SECHAWLA 21-APR-03 2925120 : Added date_effective_from parameter to the cursor call
     FOR l_line_rcv_rec IN l_line_unbill_rcvbl_csr
  (p_qtev_rec.khr_id, p_cle_id, p_qtev_rec.date_effective_from) LOOP

  l_tqlv_rec.amount := l_line_rcv_rec.amount_due;
  l_tqlv_rec.kle_id := l_line_rcv_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_line_rcv_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_line_rcv_rec.amount_due;

     END LOOP;

     -- ***************************************
     -- Get unbilled streams linked to an asset
     -- except designated excluded styles
     -- ***************************************

        -- SECHAWLA 21-APR-03 2925120 : Added date_effective_from parameter to the cursor call
     FOR l_link_rcv_rec IN l_linked_line_unbill_rcvbl_csr
  (p_qtev_rec.khr_id, p_cle_id, p_exclude_link_styles, p_qtev_rec.date_effective_from) LOOP

  l_tqlv_rec.amount := l_link_rcv_rec.amount_due;
  l_tqlv_rec.kle_id := l_link_rcv_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_link_rcv_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_link_rcv_rec.amount_due;

     END LOOP;

 END IF;

 x_operand_total := l_total;
 x_return_status := l_overall_status;

 IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN

  IF (is_debug_exception_on) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		   || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;


  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END process_unbilled_receivables;


-- Start of comments
--
-- Procedure Name : process_outstanding_balances
-- Description  : Calculate outstanding balances
-- Business Rules :
-- Parameters  : operand, quote header record, contract line,
--     table of quote line records
-- Version  : 1.0
-- End of comments

PROCEDURE process_outstanding_balances (
  p_operand IN VARCHAR2,
  p_qtev_rec IN qtev_rec_type,
  p_cle_id IN NUMBER,
  px_tqlv_tbl IN OUT NOCOPY tqlv_tbl_type,
  x_operand_total OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

 --ansethur  01-MAR-2007  Added for R12 B Billing Architecture  Start Changes
 -- Changed the cursors to select data from the view(okl_bpd_ar_inv_lines_v)
 -- provided for the Enhanced Billing architecture
 -- Select all CONTRACT invoices which have not been fully paid
/*
CURSOR l_contract_outst_bal_csr (cp_chr_id NUMBER) IS
   SELECT l.contract_line_id  contract_line_id,
          l.stream_type_id  stream_type_id,
          SUM (l.amount_due_remaining) amount_due
   FROM okl_bpd_ar_inv_lines_v l --ansethur  01-MAR-2007  Added for R12 B Billing Architecture
-- FROM okl_bpd_leasing_payment_trx_v l --ansethur  01-MAR-2007  commented for R12 B Billing Architecture
   WHERE l.CONTRACT_ID   = cp_chr_id
   AND NVL (l.amount_due_remaining, 0) <> 0
   GROUP BY l.contract_line_id,
    l.stream_type_id; */
 --modified as part of bug 7303686 to include OKC_K_HEADERS_B

 --sechawla 24-nov-09 9001258 : commented out the cursor
 /*
	CURSOR l_contract_outst_bal_csr (
		cp_chr_id	NUMBER) IS
		SELECT	l.contract_line_id		contract_line_id,
			l.stream_type_id		stream_type_id,
			SUM (l.amount_due_remaining)	amount_due
		FROM	okl_bpd_ar_inv_lines_v	l
             , OKC_K_HEADERS_B CHR
		WHERE	l.contract_id			= cp_chr_id
		AND	NVL (l.amount_due_remaining, 0)	<> 0
		AND CHR.ID = l.contract_id
		AND CHR.CUST_ACCT_ID = l.IXX_ID
		GROUP	BY l.contract_line_id,
			l.stream_type_id;
 */
 --sechawla 24-nov-09 9001258 : added

 	CURSOR l_contract_outst_bal_csr (
		cp_chr_id	NUMBER) IS
		SELECT	l.contract_line_id		contract_line_id,
			l.stream_type_id		stream_type_id,
			SUM (l.amount_due_remaining)	amount_due
		FROM	okl_bpd_ar_inv_lines_v	l
             , OKC_K_HEADERS_B CHR
             ,okc_k_lines_b cle,
		        okc_statuses_b sts
		WHERE	l.contract_id			= cp_chr_id
	    and     l.contract_line_id = cle.id
	    and    sts.code = cle.sts_code
        and    sts.ste_code not in ('EXPIRED','TERMINATED','CANCELLED')
        AND	NVL (l.amount_due_remaining, 0)	<> 0
		AND CHR.ID = l.contract_id
                -- Bug 9363287
                AND l.class = 'INV'
                -- End Bug 9363287
		AND CHR.CUST_ACCT_ID = l.IXX_ID
		GROUP	BY l.contract_line_id,
			l.stream_type_id;



 -- Select all contract LINE invoices which have not been fully paid
/*
  CURSOR l_line_outst_bal_csr (cp_chr_id NUMBER,cp_cle_id NUMBER) IS
   SELECT l.contract_line_id  contract_line_id,
          l.stream_type_id  stream_type_id,
          SUM (l.amount_due_remaining) amount_due
   FROM okl_bpd_ar_inv_lines_v l  --ansethur  01-MAR-2007  Added for R12 B Billing Architecture
-- FROM okl_bpd_leasing_payment_trx_v l  --ansethur  01-MAR-2007  commented for R12 B Billing Architecture
   WHERE l.CONTRACT_ID   = cp_chr_id
   AND   l.contract_line_id  = cp_cle_id
   AND   NVL (l.amount_due_remaining, 0) <> 0
   GROUP BY l.contract_line_id,l.stream_type_id;
*/
 --modified as part of bug 7303686 to include OKC_K_HEADERS_B
	CURSOR l_line_outst_bal_csr (
		cp_chr_id	NUMBER,
		cp_cle_id	NUMBER) IS
		SELECT	l.contract_line_id		contract_line_id,
			l.stream_type_id		stream_type_id,
			SUM (l.amount_due_remaining)	amount_due
   FROM okl_bpd_ar_inv_lines_v l  --ansethur  01-MAR-2007  Added for R12 B Billing Architecture
             , OKC_K_HEADERS_B CHR
		WHERE	l.contract_id			= cp_chr_id
		AND	l.contract_line_id		= cp_cle_id
		AND	NVL (l.amount_due_remaining, 0)	<> 0
		AND CHR.ID = l.contract_id
		AND CHR.CUST_ACCT_ID = l.IXX_ID
		GROUP	BY l.contract_line_id,
			l.stream_type_id;

 -- Select all contract SUBLINE invoices which have not been fully paid
/*
 CURSOR l_subline_outst_bal_csr (cp_chr_id NUMBER,cp_cle_id NUMBER) IS
  SELECT l.contract_line_id  contract_line_id,
         l.stream_type_id  stream_type_id,
         SUM (l.amount_due_remaining) amount_due
   FROM okc_k_items   i,
        okl_bpd_ar_inv_lines_v l  --ansethur  01-MAR-2007  Added for R12 B Billing Architecture
--       okl_bpd_leasing_payment_trx_v l --ansethur  01-MAR-2007  commented for R12 B Billing Architecture
   WHERE i.object1_id1   = cp_cle_id
   AND   l.CONTRACT_ID   = cp_chr_id
   AND   l.contract_line_id  = i.cle_id
   AND   NVL (l.amount_due_remaining, 0) <> 0
   GROUP BY l.contract_line_id,l.stream_type_id;
*/
 --modified as part of bug 7303686 to include OKC_K_HEADERS_B
	CURSOR l_subline_outst_bal_csr (
		cp_chr_id	NUMBER,
		cp_cle_id	NUMBER) IS
		SELECT	l.contract_line_id		contract_line_id,
			l.stream_type_id		stream_type_id,
			SUM (l.amount_due_remaining)	amount_due
		FROM	okc_k_items			i,
        okl_bpd_ar_inv_lines_v l  --ansethur  01-MAR-2007  Added for R12 B Billing Architecture
             , OKC_K_HEADERS_B CHR
		WHERE	i.object1_id1			= cp_cle_id
		AND	l.contract_id			= cp_chr_id
		AND	l.contract_line_id		= i.cle_id
		AND	NVL (l.amount_due_remaining, 0)	<> 0
		AND CHR.ID = l.contract_id
		AND CHR.CUST_ACCT_ID = l.IXX_ID
		GROUP	BY l.contract_line_id,
			l.stream_type_id;
 --ansethur  01-MAR-2007  Added for R12 B Billing Architecture  End Changes
 l_tqlv_rec  tqlv_rec_type;
 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_total   NUMBER := 0;
 l_seq   NUMBER := NVL (px_tqlv_tbl.LAST, 0);

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_outstanding_balances';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

 IF  NVL (p_qtev_rec.partial_yn, 'N') <> 'Y'
 AND p_cle_id IS NULL
 AND NVL(G_OUTSTANDING_BAL_DONE,'N')='N' THEN -- RMUNJULU 4691487 ADD CHECK TO SEE IF OUTSTANDING BAL CALCULATED ALREADY

     -- ************************************
     -- Get all CONTRACT outstanding amounts
     -- ************************************

     FOR l_cont_bal_rec IN l_contract_outst_bal_csr
  (p_qtev_rec.khr_id) LOOP

  l_tqlv_rec.amount := l_cont_bal_rec.amount_due;
  l_tqlv_rec.kle_id := l_cont_bal_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_cont_bal_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_cont_bal_rec.amount_due;

     END LOOP;

     G_OUTSTANDING_BAL_DONE := 'Y'; -- RMUNJULU 4691487 SET GLOBAL VALUE TO Y

 ELSIF p_cle_id IS NOT NULL THEN

     -- ********************************
     -- Get all LINE outstanding amounts
     -- ********************************

     FOR l_line_bal_rec IN l_line_outst_bal_csr
  (p_qtev_rec.khr_id, p_cle_id) LOOP

  l_tqlv_rec.amount := l_line_bal_rec.amount_due;
  l_tqlv_rec.kle_id := l_line_bal_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_line_bal_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_line_bal_rec.amount_due;

     END LOOP;

     -- ***********************************
     -- Get all SUBLINE outstanding amounts
     -- ***********************************

     FOR l_sub_bal_rec IN l_subline_outst_bal_csr
  (p_qtev_rec.khr_id, p_cle_id) LOOP

  l_tqlv_rec.amount := l_sub_bal_rec.amount_due;
  l_tqlv_rec.kle_id := l_sub_bal_rec.contract_line_id;
  l_tqlv_rec.sty_id := l_sub_bal_rec.stream_type_id;

  l_seq   := l_seq  + 1;
  px_tqlv_tbl(l_seq) := l_tqlv_rec;
  l_total   := l_total + l_sub_bal_rec.amount_due;

     END LOOP;

 END IF;

 x_operand_total := l_total;
 x_return_status := l_overall_status;

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
  END IF;

EXCEPTION

 WHEN OTHERS THEN

 	IF (is_debug_exception_on) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		   || sqlcode || ' , SQLERRM : ' || sqlerrm);
	END IF;

  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END process_outstanding_balances;


-- Start of comments
--
-- Procedure Name : calc_stream_type_operand
-- Description  : Calculate an operand based on stream type
-- Business Rules :
-- Parameters  : operand, quote header record, contract line,
--     table of quote line records
-- Version  : 1.0
-- End of comments

PROCEDURE calc_stream_type_operand (
  p_operand IN VARCHAR2,
  p_qtev_rec IN qtev_rec_type,
  p_cle_id IN NUMBER, -- if null, calculate for contract
  p_formula_name IN VARCHAR2, -- DEFAULT NULL in specs
  px_tqlv_tbl IN OUT NOCOPY tqlv_tbl_type,
  x_operand_total OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_operand_total  NUMBER;

 -- Some styles are processed by a designated routine.
 -- All other styles are included into Unbilled Receivables
 l_processed_all_styles VARCHAR2(1000);
 l_processed_link_styles VARCHAR2(1000);

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'calc_stream_type_operand';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_operand : '||p_operand);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_formula_name : '||p_formula_name);
   END IF;

 IF p_operand = 'AMYSAM' THEN

  process_specific_line_style (
   p_operand => p_operand,
   p_qtev_rec => p_qtev_rec,
   p_cle_id => p_cle_id,
   p_top_style => G_SERVICE_STYLE,
   p_link_style => G_SERVICE_LINK_STYLE,
   p_formula_name => p_formula_name,
   px_tqlv_tbl => px_tqlv_tbl,
   x_operand_total => l_operand_total,
   x_return_status => l_return_status);

 ELSIF p_operand = 'AMYFEE' THEN

  process_specific_line_style (
   p_operand => p_operand,
   p_qtev_rec => p_qtev_rec,
   p_cle_id => p_cle_id,
   p_top_style => G_FEE_STYLE,
   p_link_style => G_FEE_LINK_STYLE,
   p_formula_name => p_formula_name,
   px_tqlv_tbl => px_tqlv_tbl,
   x_operand_total => l_operand_total,
   x_return_status => l_return_status);

 ELSIF p_operand = 'AMYOUB' THEN

  process_outstanding_balances (
   p_operand => p_operand,
   p_qtev_rec => p_qtev_rec,
   p_cle_id => p_cle_id,
   px_tqlv_tbl => px_tqlv_tbl,
   x_operand_total => l_operand_total,
   x_return_status => l_return_status);

 ELSIF p_operand = 'AMCTUR' THEN

  l_processed_all_styles :=    G_SEP ||
   G_SERVICE_STYLE  || G_SEP ||
   G_SERVICE_LINK_STYLE || G_SEP ||
   G_FEE_STYLE  || G_SEP ||
   G_FEE_LINK_STYLE || G_SEP;

  l_processed_link_styles :=    G_SEP ||
   G_SERVICE_LINK_STYLE || G_SEP ||
   G_FEE_LINK_STYLE || G_SEP;

  process_unbilled_receivables (
   p_operand => p_operand,
   p_qtev_rec => p_qtev_rec,
   p_cle_id => p_cle_id,
   p_exclude_all_styles => l_processed_all_styles,
   p_exclude_link_styles => l_processed_link_styles,
   px_tqlv_tbl => px_tqlv_tbl,
   x_operand_total => l_operand_total,
   x_return_status => l_return_status);

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 x_operand_total := l_operand_total;
 x_return_status := l_overall_status;

 IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN

IF (is_debug_exception_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
		   || sqlcode || ' , SQLERRM : ' || sqlerrm);
END IF;
  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END  calc_stream_type_operand;


END OKL_AM_CALC_QUOTE_STREAM_PVT;

/
