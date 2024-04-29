--------------------------------------------------------
--  DDL for Package Body OKL_AM_CALCULATE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CALCULATE_QUOTE_PVT" AS
/* $Header: OKLRCQUB.pls 120.46.12010000.3 2009/06/12 06:14:20 sechawla ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER        := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER        := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER        := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_calculate_quote_pvt.';

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

    -- declare g_add_params as global variable, so that it can be passed to all formulae
    g_add_params                okl_execute_formula_pub.ctxt_val_tbl_type;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

     -- bug 5380712 rbruno start
        g_compute_qte_fee   BOOLEAN;
    -- bug 5380712 rbruno end

-- Forward Declaration


PROCEDURE process_top_formula (
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                p_formula_name  IN VARCHAR2,
                p_operand       IN VARCHAR2,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_formula_total OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2);


-- Start of comments
--
-- Procedure Name       : append_quote_line
-- Description          : Add a record to array of quote lines
-- Business Rules       :
-- Parameters           : array of quote lines, data for new record
-- Version                  : 1.0
-- History          : SECHAWLA 20-NOV-02 - Bug 2680542 : Added 2 optional paramaters : p_asset_qty, p_quote_qty
--                    SECHAWLA 14-FEB-03 - Bug 2749690 : Added code to store net investment, unbilled rec and residual value on quote lines
--                    SECHAWLA 20-FEB-03 - Bug 2757368 : Added logic to prorate the quote line amounts based upon the selected quote quantity
--                    SECHAWLA 24-FEB-03 - Bug 2817025 : Added code to convert the repurchase quote line amount to functional currency
--                    SECHAWLA 21-APR-03 - Bug 2925120 Modified code to fix the unit proration problem for unbiled rec, Service and Fee Lines
--                    RMUNJULU 2757312 Added p_split_asset_number to store asset_number entered by user
--                    PAGARG   29-SEP-04 - Bug 3921591 : Added AMRFEE also as part
--                    of if construct to prorate rollover quote line amount also.
--                  : rmunjulu 02/09/05 Bug 4161133 Added code to insert billing adjustment due date into quote amounts
--                  : rmunjulu 02/16/05 Bug 4161133 Added code to insert billing adjustment due date into quote amounts
-- End of comments


 PROCEDURE append_quote_line (
                p_qtev_rec                 IN qtev_rec_type,
                p_qlt_code                 IN VARCHAR2,
                p_amount                   IN NUMBER,
                p_kle_id                   IN NUMBER,
        p_asset_qty            IN NUMBER DEFAULT NULL,
        p_quote_qty            IN NUMBER DEFAULT NULL,
        p_net_investment       IN NUMBER DEFAULT NULL, -- SECHAWLA 14-FEB-03 2749690 :Added another parameter
        p_unbilled_rec         IN NUMBER DEFAULT NULL, -- SECHAWLA 14-FEB-03 2749690 :Added another parameter
        p_residual_value       IN NUMBER DEFAULT NULL, -- SECHAWLA 14-FEB-03 2749690 :Added another parameter
        p_split_asset_number   IN VARCHAR2 DEFAULT NULL, -- RMUNJULU 2757312 Added
        p_rule_information4    IN OKC_RULES_V.RULE_INFORMATION4%TYPE DEFAULT NULL, --SECHAWLA 20-FEB-03 2757368 : Added anothe parameter
                p_success_yn           IN VARCHAR2,
                p_sty_id                   IN NUMBER,
                p_formula_name         IN VARCHAR2,
                p_sub_tqlv_tbl         IN tqlv_tbl_type,
                p_defaulted_yn         IN VARCHAR2,
                p_due_date             IN DATE DEFAULT NULL, -- rmunjulu Bug 4161133 Added 4161133 Modified
                px_tqlv_tbl            IN OUT NOCOPY tqlv_tbl_type,
                px_tbl_total           IN OUT NOCOPY NUMBER) IS

    SUBTYPE tqlv_rec_type       IS okl_txl_quote_lines_pub.tqlv_rec_type;

        l_tqlv_rec                             tqlv_rec_type;
        l_seq                                  NUMBER;
        l_amount                               NUMBER;
        l_qlt_exists_yn                    VARCHAR2(1);
        l_qlt_code                             VARCHAR2(30);
        l_append_yn                        BOOLEAN := TRUE;
        l_tbl_ind                              NUMBER;
        l_defaulted_yn                     VARCHAR2(1) := p_defaulted_yn;

    ----SECHAWLA 24-FEB-03 Bug # 2817025 : new declarations
    l_func_curr_code               GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_contract_curr_code           okc_k_headers_b.currency_code%TYPE;
    lx_contract_currency           okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type    okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate    okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date    okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount            NUMBER;
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- rmunjulu Sales_Tax_Enhancement
    CURSOR get_try_id_csr (p_trx_name IN VARCHAR2) IS
    SELECT try.id
    FROM   okl_trx_types_tl try  --okl_trx_types_v try --sechawla 6-may-09 8491816
    WHERE  try.name = p_trx_name;

    l_try_id NUMBER;
    l_trx_name okl_trx_types_v.name%TYPE;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'append_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --       'p_qtev_rec :'||p_qtev_rec);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_qlt_code :'||p_qlt_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_amount :'||p_amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_kle_id :'||p_kle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_asset_qty :'||p_asset_qty);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_quote_qty :'||p_quote_qty);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_net_investment :'||p_net_investment);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_unbilled_rec :'||p_unbilled_rec);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_residual_value :'||p_residual_value);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_split_asset_number :'||p_split_asset_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_rule_information4 :'||p_rule_information4);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_success_yn :'||p_success_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_formula_name :'||p_formula_name);
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --       'p_sub_tqlv_tbl :'||p_sub_tqlv_tbl);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_defaulted_yn :'||p_defaulted_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_due_date :'||p_due_date);
   END IF;

        -- ********************************************************
        -- Save lines for operands which are treated as top formula
        -- ********************************************************

        IF p_sub_tqlv_tbl.COUNT > 0 THEN

   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'before OKL_AM_CALCULATE_QUOTE_PVT.append_quote_line calls append_quote_line'||l_return_status);

   END IF;

                l_tbl_ind := p_sub_tqlv_tbl.FIRST;
        -- append quote lines
                LOOP

                    append_quote_line (
                        p_qtev_rec      => p_qtev_rec,
                        p_qlt_code      => p_sub_tqlv_tbl(l_tbl_ind).qlt_code,
                        p_amount        => p_sub_tqlv_tbl(l_tbl_ind).amount,
                        p_kle_id        => p_sub_tqlv_tbl(l_tbl_ind).kle_id,
            p_success_yn        => OKL_API.G_RET_STS_SUCCESS,
                        p_sty_id        => p_sub_tqlv_tbl(l_tbl_ind).sty_id,
                        p_formula_name  => p_formula_name,
                        p_sub_tqlv_tbl  => G_EMPTY_TQLV_TBL,
                        p_defaulted_yn  => p_defaulted_yn,
                        px_tqlv_tbl     => px_tqlv_tbl,
                        px_tbl_total    => px_tbl_total, -- Added below 3 parameters for bug 5871029
                        p_asset_qty => p_asset_qty,
                        p_quote_qty =>  p_quote_qty,
                        p_rule_information4 => p_rule_information4);


                    EXIT WHEN (l_tbl_ind = p_sub_tqlv_tbl.LAST);
                    l_tbl_ind := p_sub_tqlv_tbl.NEXT (l_tbl_ind);

                END LOOP;

   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.append_quote_line calls append_quote_line'||l_return_status);
   END IF;


        END IF;

        -- ***********************************
        -- Check success of operand evaluation
        -- ***********************************

        IF p_success_yn <> OKL_API.G_RET_STS_SUCCESS THEN

                -- Unable to complete process due to missing
                -- information (OPERAND operand in FORMULA formula)
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_NO_OPERAND_DATA'
                        ,p_token1       => 'FORMULA'
                        ,p_token1_value => p_formula_name
                        ,p_token2       => 'OPERAND'
                        ,p_token2_value => p_qlt_code);

                l_amount        := 0;
                l_defaulted_yn  := 'Y';

        ELSE

                IF p_amount IS NULL THEN
                        l_append_yn     := FALSE;
                ELSE
                        l_amount        := p_amount;
                END IF;

        END IF;

        -- *******************************
        -- Check if quote line type exists
        -- *******************************

        l_qlt_exists_yn := okl_util.check_lookup_code
                (G_QUOTE_LINE_LOOKUP, p_qlt_code);

        IF l_qlt_exists_yn <> OKL_API.G_RET_STS_SUCCESS THEN

                -- Quote line type does not exist for
                -- OPERAND operand in FORMULA formula
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_INVALID_QUOTE_LINE_TYPE'
                        ,p_token1       => 'FORMULA'
                        ,p_token1_value => p_formula_name
                        ,p_token2       => 'OPERAND'
                        ,p_token2_value => p_qlt_code);

                IF p_success_yn <> OKL_API.G_RET_STS_SUCCESS THEN
                        l_append_yn     := FALSE;
                ELSE
                        l_qlt_code      := G_MISC_QLT;
                        l_defaulted_yn  := 'Y';
                END IF;

        ELSE
                        l_qlt_code      := p_qlt_code;
        END IF;

        -- *********************************
        -- Some quote lines must be negative
        -- *********************************

        IF  l_qlt_code IN ('AMCQDR','AMCSDD','AMCRIN','AMCTCD')
        AND l_amount > 0 THEN

                -- Amount for QLT_CODE quote line is switched to negative
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_NEGATIVE_QUOTE_LINE'
                        ,p_msg_level    => OKL_AM_UTIL_PVT.G_DEBUG_LEVEL
                        ,p_token1       => 'QLT_CODE'
                        ,p_token1_value => l_qlt_code);

                l_amount := - ABS (l_amount);

        END IF;

        -- ************
        -- Save results
        -- ************

        IF l_append_yn THEN

                l_seq   := NVL (px_tqlv_tbl.LAST, 0)  + 1;

                l_tqlv_rec.qte_id       := p_qtev_rec.id;
                l_tqlv_rec.line_number  := l_seq;
                l_tqlv_rec.qlt_code     := l_qlt_code;
        l_tqlv_rec.split_kle_name := p_split_asset_number; -- RMUNJULU 2757312  Added to store split asset number entered by user

        --SECHAWLA 20-FEB-03 2757368 : prorate by unit if prorate option is LINE_CALCULATION or PRORATE

        -- SECHAWLA 21-APR-03 - Bug 2925120 : Unbilled Receivables amounts not getting Unit Prorated.
        -- Added the 2nd condition to the following IF, to do unit proration for Unbilled rec, Service and Fee Lines.
        -- Currently, a null value is passed in p_rule_information4, to this procedure, for these 3 operands.
        --Bug #3921591: pagarg +++ Rollover +++
        -- Added AMRFEE operand also in the condition as need
        -- to prorate quote line amount in case of rollover quote line also.
        --akrangan Bug 5495474 start
        -- Added 'AMYOUB' in the flow IF condition to prorate "Outstanding Balance" line
        IF (p_rule_information4 IN ('LINE_CALCULATION','PRORATE')) OR (p_qlt_code IN ('AMCTUR','AMYSAM','AMYFEE','AMRFEE', 'AMYOUB')) THEN
        --akrangan Bug 5495474 end
           --SECHAWLA 24-FEB-03 Bug # 2817025 : added a check to prorate the amounts only if the asset and quote quantity is not null

           -- SECHAWLA 21-APR-03 Bug 2925120 : Added G_MISS_NUM check in the following IF statement
           IF (p_asset_qty IS NOT NULL AND p_asset_qty <> G_MISS_NUM ) AND (p_quote_qty IS NOT NULL AND p_quote_qty <> G_MISS_NUM) THEN
              l_amount := (l_amount / p_asset_qty) * p_quote_qty;
              -- bug 5480622 -- start
              l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => p_qtev_rec.khr_id);
              l_amount := okl_accounting_util.round_amount(p_amount => l_amount,
                                                           p_currency_code => l_contract_curr_code);
              -- bug 5480622 --end
           END IF;
        END IF;
        --SECHAWLA 20-FEB-03 2757368 : end new code

        --SECHAWLA 24-FEB-03 Bug # 2817025 : Convert the repurchase quote amount to functional currency
        IF p_qtev_rec.qtp_code = 'REP_STANDARD' THEN
           -- get the functional currency
           l_func_curr_code := okl_am_util_pvt.get_functional_currency;
           -- get the contract currency
           l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => p_qtev_rec.khr_id);

           IF l_contract_curr_code <> l_func_curr_code  THEN
                -- convert amount to functional currency

      IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'before OKL_AM_CALCULATE_QUOTE_PVT.append_quote_line calls okl_accounting_util.convert_to_functional_currency'||l_return_status);
       END IF;


                     okl_accounting_util.convert_to_functional_currency(
                         p_khr_id                               => p_qtev_rec.khr_id,
                         p_to_currency                      => l_func_curr_code,
                         p_transaction_date         => G_SYSDATE,
                         p_amount                               => l_amount,
                     x_return_status                => l_return_status,
                         x_contract_currency        => lx_contract_currency,
                             x_currency_conversion_type => lx_currency_conversion_type,
                             x_currency_conversion_rate => lx_currency_conversion_rate,
                             x_currency_conversion_date => lx_currency_conversion_date,
                             x_converted_amount             => lx_converted_amount );

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.append_quote_line calls okl_accounting_util.convert_to_functional_currency'||l_return_status);
       END IF;


                IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                   l_tqlv_rec.amount := lx_converted_amount ;
                ELSE
                   l_tqlv_rec.amount := l_amount;
                END IF;

           ELSE
                l_tqlv_rec.amount := l_amount;
           END IF;

        ELSE
           l_tqlv_rec.amount    := l_amount;
        END IF;
        --SECHAWLA 24-FEB-03 Bug # 2817025 : end currency conversion changes


        --      l_tqlv_rec.amount       := l_amount;
                l_tqlv_rec.kle_id       := p_kle_id;
  -- SECHAWLA - Bug 2680542 : Added the following code to store asset qty and quote qty on quote lines.
        l_tqlv_rec.asset_quantity := p_asset_qty; -- added
        l_tqlv_rec.quote_quantity := p_quote_qty; --added
  -- end new code

  -- SECHAWLA 14-FEB-03 Bug 2749690 : Added the following code to store net investment, unbileld rec and residual value on quote lines
        l_tqlv_rec.asset_value := p_net_investment;
        l_tqlv_rec.unbilled_receivables := p_unbilled_rec;
        l_tqlv_rec.residual_value := p_residual_value;
  -- end new code
                l_tqlv_rec.sty_id       := p_sty_id;
                l_tqlv_rec.defaulted_yn := l_defaulted_yn;
                l_tqlv_rec.modified_yn  := 'N';
                l_tqlv_rec.taxed_yn     := 'N';

         -- rmunjulu Sales_Tax_Enhancement
        IF nvl(l_tqlv_rec.amount,0) >= 0 THEN

          -- Added by rravikir (eBTax enhancement) Bug 5866207
          l_trx_name := 'Estimated Billing' ;

                  --get and set try_id with try_id of billing transaction
                  OPEN  get_try_id_csr (l_trx_name );
                  FETCH get_try_id_csr INTO l_try_id;
                  CLOSE get_try_id_csr;

                ELSE -- amount < 0

         -- Added by rravikir (eBTax enhancement) Bug 5866207
         IF p_qtev_rec.qtp_code IN ('TER_MAN_PURCHASE', 'TER_MAN_WO_PURCHASE',
                                     'TER_PURCHASE', 'TER_RECOURSE', 'TER_RECOURSE_WO_PURCHASE',
                                     'TER_RELEASE_WO_PURCHASE', 'TER_ROLL_PURCHASE',
                                     'TER_ROLL_WO_PURCHASE', 'TER_WO_PURCHASE') THEN
                    l_trx_name := 'Estimated Billing' ;
         ELSE
         -- End rravikir (eBTax enhancement)
                    l_trx_name := 'Credit Memo';
         END IF;

             --get and set try_id with try_id of billing transaction
                 OPEN  get_try_id_csr (l_trx_name );
                 FETCH get_try_id_csr INTO l_try_id;
                 CLOSE get_try_id_csr;

                END IF;

        -- rmunjulu Sales_Tax_Enhancement
        l_tqlv_rec.try_id := l_try_id;

                -- rmunjulu 4161133 Added to store date -- 4161133 modified to store due_date
        IF p_due_date IS NOT NULL THEN
          l_tqlv_rec.due_date := p_due_date;
        END IF;

                px_tqlv_tbl(l_seq)      := l_tqlv_rec;
                px_tbl_total            := NVL (px_tbl_total, 0)
                                         + NVL (l_amount, 0);

        END IF;

   IF (is_debug_statement_on) THEN
                --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                --      'px_tqlv_tbl..'||px_tqlv_tbl);
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'px_tbl_total..'||px_tbl_total);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'ret status at the end.. '||l_return_status);
   END IF;

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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

END append_quote_line;


-- Start of comments
--
-- Procedure Name       : contract_lines - CURRENTLY NOT USED
-- Description          : Adds every asset as a zero-amount quote line to improve performance of AM screens.
-- Business Rules       :
-- Parameters           : quote record, contract line, rule group, rule code
-- Version                  : 1.0
-- History          : SECHAWLA - 20-NOV-02 - Bug 2468222
--                       Added p_asset_qty and p_quote_qty parameters in call to append_quote_lines procedure.
--                       Changed reference p_asset_tbl(l_asset_tbl_index) to p_asset_tbl(l_asset_tbl_index).p_asset_id
--                    SECHAWLA - 14-FEB-03 - Bug 2749690
--                       Added logic to calculate Net Investment, Unbileld Receivables and Residual Value for all quote lines
--                    SECHAWLA - 21-APR-03 Bug 2925120
--                       Modified code to get the Unbilled Rec using calc quote strm API, instead of using LINE_UNBILLED_STREAMS formula
--                   RMUNJULU 2757312 Added to store p_split_asset_number
--                   SECHAWLA 09-AUG-05 4304230 Modified to return 0 residual value if asset status is Evergreen
--                   PRASJAIN Bug 6030917 Modified the signature of
--                   okl_am_util_pvt.get_net_investment() and Removed the proration
--                   after the call
-- End of comments


PROCEDURE contract_lines (
                p_qtev_rec      IN qtev_rec_type,
                p_asset_tbl     IN asset_tbl_type,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_quote_line_type       CONSTANT VARCHAR2(30) := 'AMCFIA';
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_line_value            NUMBER          := 0;
        l_line_total            NUMBER;
        l_asset_tbl_index       NUMBER;

    --SECHAWLA 14-FEB-03  2749690 : New declarations
    l_net_investment    NUMBER;
    --l_unbilled_rec      NUMBER; --SECHAWLA 21-APR-03 Bug 2925120
    l_residual_value    NUMBER;
    l_asset_value           ak_attributes_vl.attribute_label_long%TYPE;

    -- SECHAWLA 09-AUG-05 4304230 : Modified to get line status
    -- This cursor is used to get the residual value for an asset
    CURSOR l_okllines_csr(p_kle_id IN NUMBER) IS
    SELECT nvl(kle.residual_value,0), cle.sts_code
    FROM   okl_k_lines kle, okc_k_lines_b cle
    WHERE  kle.id = p_kle_id
    AND    kle.id = cle.id;

    l_asset_status        VARCHAR2(30); -- SECHAWLA 09-AUG-05 4304230

    --SECHAWLA 14-FEB-03  2749690 : end new declarations

    --SECHAWLA 21-APR-03 Bug 2925120: New declarations
    l_tqlv_tbl                      tqlv_tbl_type;
    l_total_line_unbilled_rec   NUMBER;

    -- Start : Bug 6030917 : prasjain
    l_proration_factor          NUMBER;
    -- End : Bug 6030917 : prasjain
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'contract_lines';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


        -- *************************************************
        -- Set Quote Line - Contract Line FK for performance
        -- *************************************************

        IF p_asset_tbl.COUNT > 0 THEN

                l_asset_tbl_index := p_asset_tbl.FIRST;

                LOOP

            --SECHAWLA 14-FEB-03 2749690 : Calculate Asset Value, Unbilled Receivables and Residual Value for each
            --quote line

             -- Start : Bug 6030917 : prasjain
             l_proration_factor := p_asset_tbl(l_asset_tbl_index).p_quote_qty/p_asset_tbl(l_asset_tbl_index).p_asset_qty;
             -- End : Bug 6030917 : prasjain

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'Before OKL_AM_CALCULATE_QUOTE_PVT.contract_lines calls okl_am_util_pvt.get_net_investment'||l_return_status);
       END IF;


            -- Calculate Net Investment
            l_net_investment := okl_am_util_pvt.get_net_investment(
                                               p_khr_id         => p_qtev_rec.khr_id,
                                               p_kle_id         => p_asset_tbl(l_asset_tbl_index).p_asset_id,
                                               p_quote_id       => p_qtev_rec.id, -- rmunjulu LOANS_ENHANCEMENT -- pass quote id as it is required to derive eff from date in formula
                                               p_message_yn     => TRUE,
                                               p_proration_factor => l_proration_factor,
                                               x_return_status  => l_return_status);

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.contract_lines calls okl_am_util_pvt.get_net_investment'||l_return_status);
       END IF;

             -- Start : Bug 6030917 : prasjain
             --NIV prorated okl_am_util_pvt.inside get_net_investment().
             /**

            -- prorate net investment
            IF l_net_investment <> 0 THEN
                l_net_investment := (l_net_investment/p_asset_tbl(l_asset_tbl_index).p_asset_qty)*(p_asset_tbl(l_asset_tbl_index).p_quote_qty);
            END IF;

            */
            -- End : Bug 6030917 : prasjain

            --SECHAWLA 21-APR-03 Bug 2925120: Get the Unbilled Rec value for the financial assets using calc quote stream API
            -- instead of using  LINE_UNBILLED_STREAMS formula

         /*   -- Calculate Unbilled Receivables
            okl_am_util_pvt.get_formula_value(
                  p_formula_name        => 'LINE_UNBILLED_STREAMS',
                  p_chr_id              => p_qtev_rec.khr_id,
                  p_cle_id              => p_asset_tbl(l_asset_tbl_index).p_asset_id,
                          x_formula_value       => l_unbilled_rec,
                          x_return_status       => l_return_status);
        */

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'Before OKL_AM_CALCULATE_QUOTE_PVT.contract_lines calls okl_am_calc_quote_stream_pvt.calc_stream_type_operand'||l_return_status);
       END IF;



         okl_am_calc_quote_stream_pvt.calc_stream_type_operand (
                        p_operand             => 'AMCTUR',
                        p_qtev_rec            => p_qtev_rec,
                        p_cle_id              => p_asset_tbl(l_asset_tbl_index).p_asset_id,
                        --p_formula_name        => l_formula_name, -- formula name is used only for AMYSAM
                        px_tqlv_tbl       => l_tqlv_tbl,
                        x_operand_total   => l_total_line_unbilled_rec,
                        x_return_status   => l_return_status);

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.contract_lines calls okl_am_calc_quote_stream_pvt.calc_stream_type_operand'||l_return_status);
       END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                l_asset_value := okl_am_util_pvt.get_ak_attribute(p_code => 'OKL_UNBILLED_RECIVABLES');
                -- Unable to calculate ASSET_VALUE
                OKL_API.set_message(  p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_FORMULA_ERROR',
                              p_token1        => 'ASSET_VALUE',
                              p_token1_value  => l_asset_value);
                l_total_line_unbilled_rec := 0;  -- SECHAWLA 21-APR-03 Bug 2925120: Changed the variable name
            END IF;

            -- SECHAWLA 21-APR-03 Bug 2925120: Changed the variable name l_unbilled_rec to l_total_line_unbilled_rec
            IF l_total_line_unbilled_rec IS NULL THEN
               l_total_line_unbilled_rec := 0;
            END IF;

            --Prorate Unbilled Receivables
            IF l_total_line_unbilled_rec <> 0 THEN
               l_total_line_unbilled_rec := (l_total_line_unbilled_rec/p_asset_tbl(l_asset_tbl_index).p_asset_qty)*(p_asset_tbl(l_asset_tbl_index).p_quote_qty);
            END IF;

            --Get the Residual value
            OPEN   l_okllines_csr( p_asset_tbl(l_asset_tbl_index).p_asset_id);
            FETCH  l_okllines_csr INTO l_residual_value, l_asset_status; -- SECHAWLA 09-AUG-05 4304230 : added asset status
            IF l_okllines_csr%NOTFOUND THEN
               OKC_API.set_message( p_app_name      => 'OKC',
                           p_msg_name      => G_INVALID_VALUE,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'KLE_ID');
               l_residual_value := 0;
            END IF;
            CLOSE l_okllines_csr;

            --Prorate Residual Value
            IF l_residual_value <> 0 THEN
               IF l_asset_status <> 'EVERGREEN' THEN -- SECHAWLA 09-AUG-05 4304230 : added this condition
                  l_residual_value := (l_residual_value/p_asset_tbl(l_asset_tbl_index).p_asset_qty)*(p_asset_tbl(l_asset_tbl_index).p_quote_qty);
               ELSE
                  l_residual_value := 0; -- SECHAWLA 09-AUG-05 4304230 : added
                           END IF;
            END IF;
           --SECHAWLA 14-FEB-03 2749690 : End new code



  -- SECHAWLA - Bug 2680542 : Added p_asset_qty and p_quote_qty parameters in call to append_quote_line procedure.
  --                          Changed reference p_asset_tbl(l_asset_tbl_index) to p_asset_tbl(l_asset_tbl_index).p_asset_id
           IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'Before OKL_AM_CALCULATE_QUOTE_PVT.contract_lines calls append_quote_line'||l_return_status);
       END IF;


            append_quote_line (
                        p_qtev_rec                 => p_qtev_rec,
                        p_qlt_code                 => l_quote_line_type,
                        p_amount                   => l_line_value,
                        p_kle_id                   => p_asset_tbl(l_asset_tbl_index).p_asset_id, -- changed,
            p_asset_qty            => p_asset_tbl(l_asset_tbl_index).p_asset_qty, -- added
            p_quote_qty            => p_asset_tbl(l_asset_tbl_index).p_quote_qty, -- added
            p_net_investment       => l_net_investment, -- SECHAWLA 14-FEB-03 2749690 :Added another parameter
            p_split_asset_number   => p_asset_tbl(l_asset_tbl_index).p_split_asset_number, -- RMUNJULU 2757312 Added to store p_split_asset_number
            p_unbilled_rec         => l_total_line_unbilled_rec, -- SECHAWLA 14-FEB-03 2749690 :Added another parameter
            p_residual_value       => l_residual_value, -- SECHAWLA 14-FEB-03 2749690 :Added another parameter
                        p_success_yn           => OKL_API.G_RET_STS_SUCCESS,
                        p_sty_id                   => NULL,
                        p_formula_name         => NULL,
                        p_sub_tqlv_tbl         => G_EMPTY_TQLV_TBL,
                        p_defaulted_yn         => 'N',
                        px_tqlv_tbl            => px_tqlv_tbl,
                        px_tbl_total           => l_line_total);

                    EXIT WHEN (l_asset_tbl_index = p_asset_tbl.LAST);
                    l_asset_tbl_index   :=
                                p_asset_tbl.NEXT (l_asset_tbl_index);
                END LOOP;

           IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.contract_lines calls append_quote_line'||l_return_status);
       END IF;

        END IF;

  x_return_status       := l_overall_status;

 IF (is_debug_statement_on) THEN
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --       'px_tqlv_tbl     :'||px_tqlv_tbl);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
             'ret status at the end.. '||l_return_status);
   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
        --SECHAWLA 14-FEB-03  2749690 : Close the new cursor
        IF l_okllines_csr%ISOPEN THEN
           CLOSE l_okllines_csr;
        END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END contract_lines;


-- Start of comments
--
-- Procedure Name       : estimate_tax
-- Description          : Estimate tax on all quote elements
-- Business Rules       :
-- Parameters           : array of quote elements
-- Version                  : 1.0
-- History          : SECHAWLA 20-NOV-02 - Bug 2468222
--                  : Changed reference  p_asset_tbl(l_seq) to  p_asset_tbl(l_seq).p_asset_id
--                    Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
--                  : rmunjulu 3797384 added code to send quote_effective_from_date and quote_id
--                  : rmunjulu Sales_Tax_Enhancement Call the OKL Tax engine
--                    to formula engine
-- End of comments

PROCEDURE estimate_tax (
                p_qtev_rec      IN qtev_rec_type,
                p_asset_tbl     IN asset_tbl_type,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS

        TYPE amount_tbl_type IS TABLE OF NUMBER
                INDEX BY BINARY_INTEGER;

        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_tax_amount            NUMBER;
        l_asset_tbl_index       NUMBER;
        l_dummy_total           NUMBER;

        l_tax_cle_id            asset_tbl_type;
        e_tax_cle_id            asset_tbl_type;
        l_taxable_amt           amount_tbl_type;
        l_chr_taxable_amt       NUMBER          := 0;
        l_total_taxable_amt     NUMBER          := 0;
        l_seq                   NUMBER          := 0;
        l_params                okl_execute_formula_pub.ctxt_val_tbl_type;

        l_curr_amt              NUMBER;
        l_curr_cle              NUMBER;
        l_match_found           BOOLEAN;
        l_asset_found           BOOLEAN;

        -- rmunjulu Sales_Tax_Enhancement
        l_api_version NUMBER := 1;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(3000);
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'estimate_tax';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN


/* -- rmunjulu Sales_Tax_Enhancement
        IF px_tqlv_tbl.COUNT > 0 THEN

            -- ****************************************
            -- Add up tax for every line and a contract
            -- ****************************************

            l_asset_tbl_index := px_tqlv_tbl.FIRST;

            LOOP

                IF NVL (px_tqlv_tbl(l_asset_tbl_index).qlt_code, G_MISC_QLT)
                        NOT IN ('AMYOUB', 'AMPRTX', G_TAX_QLT)
                THEN

                    -- Local variables to impove readibility
                    l_curr_amt := NVL(px_tqlv_tbl(l_asset_tbl_index).amount,0);
                    l_curr_cle := px_tqlv_tbl(l_asset_tbl_index).kle_id;
                    -- Taxable quote total
                    l_total_taxable_amt := l_total_taxable_amt + l_curr_amt;
                    -- Element is taxable
                    px_tqlv_tbl(l_asset_tbl_index).taxed_yn := 'Y';

                    -- Element on contract level
                    IF l_curr_cle IS NULL THEN
                        l_chr_taxable_amt := l_chr_taxable_amt + l_curr_amt;

                    -- Non-zero element on line level
                    ELSIF l_curr_amt <> 0 THEN

                        -- Flag to show if curr_cle is found in p_asset_tbl
                        l_asset_found   := FALSE;

                        IF p_asset_tbl.COUNT > 0 THEN

                            l_seq       := p_asset_tbl.FIRST;

                            LOOP

                                -- Element is found in p_asset_tbl
    -- SECHAWLA - Bug 2680542 : Changed reference  p_asset_tbl(l_seq) to  p_asset_tbl(l_seq).p_asset_id
                                IF p_asset_tbl(l_seq).p_asset_id = l_curr_cle THEN
                                    l_asset_found := TRUE;
                                END IF;

                                EXIT WHEN (l_seq = p_asset_tbl.LAST
                                        OR l_asset_found);
                                l_seq := p_asset_tbl.NEXT(l_seq);

                            END LOOP;

                        END IF;

                        IF NOT l_asset_found THEN

                            -- Non-asset lines found for full termination
                            l_chr_taxable_amt   := l_chr_taxable_amt + l_curr_amt;
                            l_match_found       := TRUE;

                        ELSE

                            -- Flag to show if curr_cle is found in l_tax_cle_id
                            l_match_found       := FALSE;

                        END IF;

                        -- Find if curr_cle is already in l_tax_cle_id
                        IF (NOT l_match_found) AND (l_tax_cle_id.COUNT > 0) THEN

                            l_seq := l_tax_cle_id.FIRST;

                            LOOP

                                -- Element is already in l_tax_cle_id
    -- SECHAWLA - Bug 2680542 : Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
                                IF l_tax_cle_id(l_seq).p_asset_id = l_curr_cle THEN
                                    l_taxable_amt(l_seq) :=
                                        l_taxable_amt(l_seq) + l_curr_amt;
                                    l_match_found := TRUE;
                                END IF;

                                EXIT  WHEN (l_seq = l_tax_cle_id.LAST)
                                        OR (l_match_found);
                                l_seq := l_tax_cle_id.NEXT (l_seq);

                            END LOOP;

                        END IF;

                        -- Element is not in l_tax_cle_id yet
                        IF NOT l_match_found THEN
                            l_seq := NVL (l_tax_cle_id.LAST, 0) + 1;
        -- SECHAWLA - Bug 2680542 : Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
                            l_tax_cle_id(l_seq).p_asset_id       := l_curr_cle;
                            l_taxable_amt(l_seq) := l_curr_amt;
                        END IF;

                    END IF;

                END IF;

                EXIT WHEN (l_asset_tbl_index = px_tqlv_tbl.LAST);
                l_asset_tbl_index :=
                        px_tqlv_tbl.NEXT (l_asset_tbl_index);

            END LOOP;

            -- ********************************
            -- Check total and contract amounts
            -- ********************************

            IF NVL (l_total_taxable_amt, 0) = 0 THEN
                -- Only one tax line need to be created
                l_tax_cle_id            := e_tax_cle_id;
                l_seq := NVL (l_tax_cle_id.LAST, 0) + 1;
   -- SECHAWLA - Bug 2680542 : Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
                l_tax_cle_id(l_seq).p_asset_id  := NULL;
                l_taxable_amt(l_seq)    := 0;
            ELSIF NVL (l_chr_taxable_amt, 0) <> 0 THEN
                -- Tax for elements on contract level
                l_seq := NVL (l_tax_cle_id.LAST, 0) + 1;
   -- SECHAWLA - Bug 2680542 : Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
                l_tax_cle_id(l_seq).p_asset_id  := NULL;
                l_taxable_amt(l_seq)    := l_chr_taxable_amt;
            END IF;

            -- *******************************************
            -- Calculate tax and create TAX quote elements
            -- *******************************************

            IF l_tax_cle_id.COUNT > 0 THEN

                l_seq := l_tax_cle_id.FIRST;

                LOOP

                    l_tax_amount := 0;
                    l_return_status := OKL_API.G_RET_STS_SUCCESS;

                    IF NVL (l_taxable_amt(l_seq), 0) <> 0 THEN

                        l_params(1).name  := G_TAX_AMT_PARAM;
                        l_params(1).value := l_taxable_amt(l_seq);

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- send quote_effective_from_date and quote_id
                        l_params(2).name  := g_add_params(1).name;
                        l_params(2).value := g_add_params(1).value;

                        l_params(3).name  := g_add_params(2).name;
                        l_params(3).value := g_add_params(2).value;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

                        IF SYS_CONTEXT('USERENV','CLIENT_INFO') IS NOT NULL THEN
                            okl_am_util_pvt.get_formula_value (
                                p_formula_name  => G_TAX_FORMULA,
                                p_chr_id        => p_qtev_rec.khr_id,
     -- SECHAWLA - Bug 2680542 : Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
                                p_cle_id        => l_tax_cle_id(l_seq).p_asset_id,
                                p_additional_parameters => l_params,
                                x_formula_value => l_tax_amount,
                                x_return_status => l_return_status);
                        ELSE
                            IF G_ORG_ID_MISSING_MSG THEN
                                -- ORG_ID is not defined
                                OKL_API.SET_MESSAGE (
                                     p_app_name => 'FND'
                                    ,p_msg_name => 'FND-ORG_ID PROFILE CANNOT READ'
                                    ,p_token1   => 'OPTION'
                                    ,p_token1_value => 'ORG_ID');
                                G_ORG_ID_MISSING_MSG := FALSE;
                            END IF;
                            l_return_status := OKL_API.G_RET_STS_ERROR;
                        END IF;

                    END IF;

                    append_quote_line (
                        p_qtev_rec      => p_qtev_rec,
                        p_qlt_code      => G_TAX_QLT,
                        p_amount        => l_tax_amount,
    -- SECHAWLA - Bug 2680542 : Changed reference  l_tax_cle_id(l_seq) to  l_tax_cle_id(l_seq).p_asset_id
                        p_kle_id        => l_tax_cle_id(l_seq).p_asset_id,
            p_success_yn        => l_return_status,
                        p_sty_id        => NULL,
                        p_formula_name  => G_TAX_FORMULA,
                        p_sub_tqlv_tbl  => G_EMPTY_TQLV_TBL,
                        p_defaulted_yn  => 'N',
                        px_tqlv_tbl     => px_tqlv_tbl,
                        px_tbl_total    => l_dummy_total);

                    EXIT WHEN (l_seq = l_tax_cle_id.LAST);
                    l_seq := l_tax_cle_id.NEXT (l_seq);

                END LOOP;

            END IF;

        END IF;
*/
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
    -- rmunjulu Sales_Tax_Enhancement
    -- Call the new OKL Tax engine to calculate tax
    -- TAX API SHOULD CALCULATE TAX FOR ALL QUOTE LINES EXCEPT (AMCFIA, AMYOUB, AMCTAX)
        -- QUESTION :: WHAT ABT BILL_ADJST AND AMPRTX QUOTE LINES
        -- TAX API WILL CALCULATE TAX AND INSERT INTO TAX ENTITY THE TAX LINES
        OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
        p_api_version          => l_api_version,
        p_init_msg_list        => OKL_API.G_FALSE,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data,
        p_source_trx_id            => p_qtev_rec.id, -- TRX_ID is QUOTE_ID
        p_source_trx_name      => 'Estimated Billing',  -- TRX_NAME IS NULL
        p_source_table         => 'OKL_TRX_QUOTES_B');  -- SOURCE_TABLE IS OKL_TRX_QUOTES_B

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After OKL_AM_CALCULATE_QUOTE_PVT.estimate_tax calls OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax :'||l_return_status);
END IF;
        x_return_status := l_return_status; -- rmunjulu Sales_Tax_Enhancement

EXCEPTION

        WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END estimate_tax;

PROCEDURE adjust_prorated_amounts (
		p_qtev_rec	IN qtev_rec_type,
		p_asset_tbl	IN asset_tbl_type,
		px_tqlv_tbl	IN OUT NOCOPY tqlv_tbl_type,
		x_return_status	OUT NOCOPY VARCHAR2) IS


	l_tqlv_tbl		tqlv_tbl_type;
    l_AMBCOC  NUMBER :=0;
    l_AMCQFE number :=0;
    l_AMCRFE number :=0;
    l_AMCQDR NUMBER :=0;
    l_AMCRIN NUMBER :=0;
    l_AMCSDD NUMBER :=0;
    l_AMCTPE NUMBER :=0;
    l_AMPRTX NUMBER :=0;
    l_AMBPOC NUMBER :=0;

    l_operand_value		NUMBER;
    ambcoc_high_index  number :=-1;
    ambcoc_low_index  number  :=-1;
    amcqfe_high_index  number :=-1;
    amcqfe_low_index  number  :=-1;
    amcrfe_high_index  number :=-1;
    amcrfe_low_index  number  :=-1;

    amcqdr_high_index  number :=-1;
    amcqdr_low_index  number  :=-1;
    amcrin_high_index  number :=-1;
    amcrin_low_index  number  :=-1;
    amcsdd_high_index  number :=-1;
    amcsdd_low_index  number  :=-1;
    amctpe_high_index  number :=-1;
    amctpe_low_index  number  :=-1;
    amprtx_high_index  number :=-1;
    amprtx_low_index  number  :=-1;

    ambpoc_high_index  number :=-1;
    ambpoc_low_index  number  :=-1;

    l_ambcoc_diff NUMBER :=0;
    l_amcqfe_diff NUMBER :=0;
    l_amcrfe_diff NUMBER :=0;
    l_amcqdr_diff NUMBER :=0;
    l_amcrin_diff NUMBER :=0;
    l_amcsdd_diff NUMBER :=0;
    l_amctpe_diff NUMBER :=0;
    l_amprtx_diff NUMBER :=0;
    l_ambpoc_diff NUMBER :=0;

    li number := G_MISS_NUM;
    l_ael_apply_diff OKL_SYSTEM_PARAMS.PART_TRMNT_APPLY_ROUND_DIFF%type;
   	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN

    l_tqlv_tbl := px_tqlv_tbl;

    select PART_TRMNT_APPLY_ROUND_DIFF into l_ael_apply_diff
    from OKL_SYSTEM_PARAMS;

	IF  l_tqlv_tbl.COUNT > 0 THEN
	 li := l_tqlv_tbl.FIRST;
        -- append quote lines
		LOOP
		   if l_tqlv_tbl(li).qlt_code = 'AMBCOC' THEN
		        if ambcoc_high_index = -1 then
		            ambcoc_high_index := li;
                end if;

		        ambcoc_low_index := li;

		        l_AMBCOC := l_AMBCOC +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMCRFE' THEN
                 if amcrfe_high_index = -1 then
		            amcrfe_high_index := li;
                 end if;

		         amcrfe_low_index := li;
	            l_AMCRFE := l_AMCRFE +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMCQFE' THEN
                if amcqfe_high_index = -1 then
		            amcqfe_high_index := li;
                 end if;

		         amcqfe_low_index := li;
	            l_AMCQFE := l_AMCQFE +  l_tqlv_tbl(li).amount;


           elsif l_tqlv_tbl(li).qlt_code = 'AMCQDR' THEN
                if amcqdr_high_index = -1 then
		            amcqdr_high_index := li;
                 end if;

		         amcqdr_low_index := li;
	            l_AMCQDR := l_AMCQDR +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMCRIN' THEN
                if amcrin_high_index = -1 then
		            amcrin_high_index := li;
                 end if;

		         amcrin_low_index := li;
	            l_AMCRIN := l_AMCRIN +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMCSDD' THEN
                if amcsdd_high_index = -1 then
		            amcsdd_high_index := li;
                 end if;

		         amcsdd_low_index := li;
	            l_AMCSDD := l_AMCSDD +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMCTPE' THEN
                if amctpe_high_index = -1 then
		            amctpe_high_index := li;
                 end if;

		         amctpe_low_index := li;
	            l_AMCTPE := l_AMCTPE +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMPRTX' THEN
                if amprtx_high_index = -1 then
		            amprtx_high_index := li;
                 end if;

		         amprtx_low_index := li;
	            l_AMPRTX := l_AMPRTX +  l_tqlv_tbl(li).amount;

           elsif l_tqlv_tbl(li).qlt_code = 'AMBPOC' THEN
                if ambpoc_high_index = -1 then
		            ambpoc_high_index := li;
                 end if;

		         ambpoc_low_index := li;
	            l_AMBPOC := l_AMBPOC +  l_tqlv_tbl(li).amount;
           end if;


	      EXIT WHEN (li = l_tqlv_tbl.LAST);
		    li	:= l_tqlv_tbl.NEXT (li);
		END LOOP;
	END IF;

          l_ambcoc_diff := abs(G_AMBCOC-l_AMBCOC);
          l_amcqfe_diff := abs(G_AMCQFE-l_AMCQFE);
          l_amcrfe_diff := abs(G_AMCRFE-l_AMCRFE);
          l_amcqdr_diff := abs(G_AMCQDR-l_AMCQDR);
          l_amcrin_diff := abs(G_AMCRIN-l_AMCRIN);
          l_amcsdd_diff := abs(G_AMCSDD-l_AMCSDD);
          l_amctpe_diff := abs(G_AMCTPE-l_AMCTPE);
          l_amprtx_diff := abs(G_AMPRTX-l_AMPRTX);
          l_ambpoc_diff := abs(G_AMBPOC-l_AMBPOC);

    if l_ambcoc_diff <> 0 or l_amcqfe_diff <> 0 or
       l_amcrfe_diff <> 0 or l_amcqdr_diff <> 0 or
       l_amcrin_diff <> 0 or l_amcsdd_diff <> 0 or
       l_amctpe_diff <> 0 or l_amprtx_diff <> 0 or l_ambpoc_diff <> 0 then

     IF (l_ael_apply_diff = 'ADD_TO_HIGH') or (l_ael_apply_diff = 'ADD_NEW_LINE') THEN
         IF (G_AMBCOC_OPTION = 'PRORATE') THEN
            if l_ambcoc_diff <> 0 then
              l_tqlv_tbl(ambcoc_high_index).AMOUNT := l_tqlv_tbl(ambcoc_high_index).AMOUNT
                                               + l_ambcoc_diff;
             end if;
         END IF;
         IF (G_AMCQFE_OPTION = 'PRORATE') THEN
             if l_amcqfe_diff <> 0 then
                l_tqlv_tbl(amcqfe_high_index).AMOUNT := l_tqlv_tbl(amcqfe_high_index).AMOUNT
                                                   + l_amcqfe_diff;
              end if;
         END IF;
         IF (G_AMCRFE_OPTION = 'PRORATE') THEN
            if l_amcrfe_diff <> 0 then
              l_tqlv_tbl(amcrfe_high_index).AMOUNT := l_tqlv_tbl(amcrfe_high_index).AMOUNT
                                                   + l_amcrfe_diff;
            end if;
         END IF;
         IF (G_AMCQDR_OPTION = 'PRORATE') THEN
           if l_amcqdr_diff <> 0 then
              l_tqlv_tbl(amcqdr_high_index).AMOUNT := l_tqlv_tbl(amcqdr_high_index).AMOUNT
                                                   + l_amcqdr_diff;
            end if;
          END IF;
          IF (G_AMCRIN_OPTION = 'PRORATE') THEN
            if l_amcrin_diff <> 0 then
              l_tqlv_tbl(amcrin_high_index).AMOUNT := l_tqlv_tbl(amcrin_high_index).AMOUNT
                                                    + l_amcrin_diff;
            end if;
          END IF;
          IF (G_AMCSDD_OPTION = 'PRORATE') THEN
            if l_amcsdd_diff <> 0 then
              l_tqlv_tbl(amcsdd_high_index).AMOUNT := l_tqlv_tbl(amcsdd_high_index).AMOUNT
                                                   + l_amcsdd_diff;
            end if;
          END IF;
          IF (G_AMCTPE_OPTION = 'PRORATE') THEN
            if l_amctpe_diff <> 0 then
              l_tqlv_tbl(amctpe_high_index).AMOUNT := l_tqlv_tbl(amctpe_high_index).AMOUNT
                                                   + l_amctpe_diff;
            end if;
          END IF;
          IF (G_AMPRTX_OPTION = 'PRORATE') THEN
            if l_amprtx_diff <> 0 then
              l_tqlv_tbl(amprtx_high_index).AMOUNT := l_tqlv_tbl(amprtx_high_index).AMOUNT
                                                   + l_amprtx_diff;
            end if;
          END IF;

           IF (G_AMBPOC_OPTION = 'PRORATE') THEN
            if l_ambpoc_diff <> 0 then
                 l_tqlv_tbl(ambpoc_high_index).AMOUNT := l_tqlv_tbl(ambpoc_high_index).AMOUNT
                                                   + l_ambpoc_diff;
            end if;
          END IF;

       ELSIF (l_ael_apply_diff = 'ADD_TO_LOW') THEN
          IF (G_AMBCOC_OPTION = 'PRORATE') THEN
            if l_ambcoc_diff <> 0 then
               l_tqlv_tbl(ambcoc_low_index).AMOUNT        := l_tqlv_tbl(ambcoc_low_index).AMOUNT
                                                            + l_ambcoc_diff;
            end if;
          END IF;
          IF (G_AMCQFE_OPTION = 'PRORATE') THEN
            if l_amcqfe_diff <> 0 then
              l_tqlv_tbl(amcqfe_low_index).AMOUNT := l_tqlv_tbl(amcqfe_low_index).AMOUNT
                                                   + l_amcqfe_diff;
            end if;
          END IF;
          IF (G_AMCRFE_OPTION = 'PRORATE') THEN
            if l_amcrfe_diff <> 0 then
              l_tqlv_tbl(amcrfe_low_index).AMOUNT := l_tqlv_tbl(amcrfe_low_index).AMOUNT
                                                   + l_amcrfe_diff;
            end if;
          END IF;
          IF (G_AMCQDR_OPTION = 'PRORATE') THEN
            if l_amcqdr_diff <> 0 then
              l_tqlv_tbl(amcqdr_low_index).AMOUNT := l_tqlv_tbl(amcqdr_low_index).AMOUNT
                                                   + l_amcqdr_diff;
            end if;
          END IF;
          IF (G_AMCRIN_OPTION = 'PRORATE') THEN
            if l_amcrin_diff <> 0 then
              l_tqlv_tbl(amcrin_low_index).AMOUNT := l_tqlv_tbl(amcrin_low_index).AMOUNT
                                                   + l_amcrin_diff;
            end if;
          END IF;
          IF (G_AMCSDD_OPTION = 'PRORATE') THEN
            if l_amcsdd_diff <> 0 then
              l_tqlv_tbl(amcsdd_low_index).AMOUNT := l_tqlv_tbl(amcsdd_low_index).AMOUNT
                                                   + l_amcsdd_diff;
            end if;
          END IF;
          IF (G_AMCTPE_OPTION = 'PRORATE') THEN
            if l_amctpe_diff <> 0 then
              l_tqlv_tbl(amctpe_low_index).AMOUNT := l_tqlv_tbl(amctpe_low_index).AMOUNT
                                                   + l_amctpe_diff;
            end if;
          END IF;
          IF (G_AMPRTX_OPTION = 'PRORATE') THEN
            if l_amprtx_diff <> 0 then
              l_tqlv_tbl(amprtx_low_index).AMOUNT := l_tqlv_tbl(amprtx_low_index).AMOUNT
                                                   + l_amprtx_diff;
            end if;
          END IF;
          IF (G_AMBPOC_OPTION = 'PRORATE') THEN
             if l_ambpoc_diff <> 0 then
              l_tqlv_tbl(ambpoc_low_index).AMOUNT := l_tqlv_tbl(ambpoc_low_index).AMOUNT
                                                   + l_ambpoc_diff;
            end if;
          END IF;

      end if;
    end if;
    px_tqlv_tbl := l_tqlv_tbl;
    G_AMBCOC  :=0;
    G_AMCQDR  :=0;
    G_AMCQFE  :=0;
    G_AMCRFE  :=0;
    G_AMCRIN  :=0;
    G_AMCSDD  :=0;
    G_AMCTPE  :=0;
    G_AMPRTX  :=0;
    G_AMBPOC  :=0;
    G_AMBCOC_OPTION  :='LINE_CALCULATION';
    G_AMCQDR_OPTION  :='LINE_CALCULATION';
    G_AMCQFE_OPTION  :='LINE_CALCULATION';
    G_AMCRFE_OPTION  :='LINE_CALCULATION';
    G_AMCRIN_OPTION  :='LINE_CALCULATION';
    G_AMCSDD_OPTION  :='LINE_CALCULATION';
    G_AMCTPE_OPTION  :='LINE_CALCULATION';
    G_AMPRTX_OPTION  :='LINE_CALCULATION';
    G_AMBPOC_OPTION  :='LINE_CALCULATION';
	x_return_status	:= l_overall_status;

EXCEPTION

	WHEN OTHERS THEN
		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END adjust_prorated_amounts;

-- Start of comments
--
-- Procedure Name       : prorate_operand
-- Description          : Calculate amount to be allocated to an asset
-- Business Rules       :
-- Parameters           : contract, contract line, total amount
-- Version                  : 1.0
-- History          : SECHAWLA 20-FEB-03 2757368
--                      Modified the general proration logic to use CONTRACT_OEC formula instead of QUOTE_GENERIC_LINE_PRORATION
--                      formula.
--                    SECHAWLA 21-APR-03 Bug 2925120
--                      Modified procedure to fix the infinite loop problem
--                  : rmunjulu 3797384 added code to send quote_effective_from_date and quote_id
--                    to formula engine
-- End of comments

PROCEDURE prorate_operand (
                p_operand               IN VARCHAR2,
                p_chr_id                IN NUMBER,
                p_cle_id                IN NUMBER,
                p_chr_amt               IN NUMBER,
                p_formula_name          IN VARCHAR2,
                p_head_sub_tqlv_tbl     IN tqlv_tbl_type,
                px_line_sub_tqlv_tbl    IN OUT NOCOPY tqlv_tbl_type,
                x_cle_amt               OUT NOCOPY NUMBER,
                x_return_status         OUT NOCOPY VARCHAR2) IS

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_formula_name          okl_formulae_v.name%TYPE;
        l_formula_string        okl_formulae_v.formula_string%TYPE := NULL;
        l_proration_fraction    NUMBER  := 0;
        l_tbl_ind               NUMBER;
        l_cle_amt               NUMBER;

 --SECHAWLA 20-FEB-03 Bug # 2757368 : new declarations
    l_line_oec      NUMBER;
    l_contract_oec  NUMBER;

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'prorate_operand';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
        -- ********************************************************
        -- Prorate operands which are treated as top formula
        -- ********************************************************
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Inside prorate_operand :: p_head_sub_tqlv_tbl.COUNT :'||p_head_sub_tqlv_tbl.COUNT);
END IF;
        IF p_head_sub_tqlv_tbl.COUNT > 0 THEN

            l_tbl_ind := p_head_sub_tqlv_tbl.FIRST;

            LOOP

                IF NVL (p_head_sub_tqlv_tbl(l_tbl_ind).kle_id, G_MISS_NUM) =
                        G_MISS_NUM THEN

                    prorate_operand (
                        p_operand       => p_head_sub_tqlv_tbl(l_tbl_ind).qlt_code,
                        p_chr_id        => p_chr_id,
                        p_cle_id        => p_cle_id,
                        p_chr_amt       => p_head_sub_tqlv_tbl(l_tbl_ind).amount,
                        p_formula_name  => p_formula_name,
                        p_head_sub_tqlv_tbl     => G_EMPTY_TQLV_TBL,
                        px_line_sub_tqlv_tbl    => G_EMPTY_TQLV_TBL,
                        x_cle_amt       => l_cle_amt,
                        x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to prorate_operand:'||l_return_status);
                   END IF;
                    px_line_sub_tqlv_tbl(l_tbl_ind) := p_head_sub_tqlv_tbl(l_tbl_ind);
                    px_line_sub_tqlv_tbl(l_tbl_ind).amount      := l_cle_amt;
                    px_line_sub_tqlv_tbl(l_tbl_ind).kle_id      := p_cle_id;

                 --   EXIT WHEN (l_tbl_ind = p_head_sub_tqlv_tbl.LAST);
                 --   l_tbl_ind := p_head_sub_tqlv_tbl.NEXT (l_tbl_ind);

                END IF;
          -- SECHAWLA 21-APR-03 Bug 2925120 : Moved the following loop control statements outside the IF to prevent infinite loop
          EXIT WHEN (l_tbl_ind = p_head_sub_tqlv_tbl.LAST);
          l_tbl_ind := p_head_sub_tqlv_tbl.NEXT (l_tbl_ind);

            END LOOP;

        END IF;

        -- ***************
        -- Prorate operand
        -- ***************

        IF NVL (p_chr_amt, 0) <> 0 THEN

            l_formula_name      := p_operand || G_PRORATE_SUFFIX;
            l_formula_string    := okl_am_util_pvt.get_formula_string
                                        (l_formula_name);

            IF l_formula_string IS NULL THEN
                l_formula_name  := G_GENERIC_PRORATE;
            END IF;

        --SECHAWLA 20-FEB-03 Bug # 2757368 : Execute the CONTRACT_OEC formula first at the line level, to get the
        --line amount, then execute the formula at header level to get the contract amount. Calculate proration fraction
        --manually by dividing the line amount with contract amount.

        -- get the line oec
            okl_am_util_pvt.get_formula_value (
                p_formula_name   => l_formula_name,
                p_chr_id             => p_chr_id,
                p_cle_id             => p_cle_id,
                --x_formula_value       => l_proration_fraction,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- pass additional parameters quote_effective_from_date and quote_id
        p_additional_parameters => g_add_params,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++
        x_formula_value  => l_line_oec,
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

        -- get the contract oec
            okl_am_util_pvt.get_formula_value (
                p_formula_name   => l_formula_name,
                p_chr_id             => p_chr_id,
                p_cle_id             => NULL,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- pass additional parameters quote_effective_from_date and quote_id
        p_additional_parameters => g_add_params,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++
                x_formula_value  => l_contract_oec,
                x_return_status  => l_return_status);

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_util_pvt.get_formula_value  :'||l_return_status);
           END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                  END IF;
            END IF;

        l_proration_fraction := l_line_oec/l_contract_oec;

        --SECHAWLA 20-FEB-03 Bug # 2757368 :  end modifications
        END IF;

        IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS
        AND l_proration_fraction BETWEEN 0 AND 1 THEN
                x_cle_amt       := p_chr_amt * l_proration_fraction;
        ELSE

                -- Unable to prorate quote element
                -- OPERAND in FORMULA formula
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_INVALID_PRORATION'
                        ,p_token1       => 'FORMULA'
                        ,p_token1_value => p_formula_name
                        ,p_token2       => 'OPERAND'
                        ,p_token2_value => p_operand);

                x_cle_amt       := 0;

        END IF;
	-- bug 5480622 -- start
	-- set global variable
	IF NVL (p_chr_amt, 0) <> 0 THEN
	    IF (p_operand = 'AMBCOC') AND (G_AMBCOC = 0 )then
	       G_AMBCOC := p_chr_amt;
        END IF;
        IF (p_operand = 'AMCQFE') AND (G_AMCQFE = 0 )then
	       G_AMCQFE := p_chr_amt;
        END IF;
        IF (p_operand = 'AMCRFE') AND (G_AMCRFE = 0 )then
	       G_AMCRFE := p_chr_amt;
        END IF;
        IF (p_operand = 'AMCRIN') AND (G_AMCRIN = 0 )then
	       G_AMCRIN := p_chr_amt;
        END IF;
        IF (p_operand = 'AMCSDD') AND (G_AMCSDD = 0 )then
	       G_AMCSDD := p_chr_amt;
        END IF;
        IF (p_operand = 'AMCTPE') AND (G_AMCTPE = 0 )then
	       G_AMCTPE := p_chr_amt;
        END IF;
        IF (p_operand = 'AMPRTX') AND (G_AMPRTX = 0 )then
	       G_AMPRTX := p_chr_amt;
        END IF;
     END IF;
     -- bug 5480622 -- end
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END prorate_operand;


-- Start of comments
--
-- Procedure Name       : create_default_quote_lines
-- Description          : Create quote lines with zero amount for every record in the table of default line types
-- Business Rules       :
-- Parameters           : contract line or table of contract lines, quote header record, table of quote line records,
--                                 table of default line types
-- Version                  : 1.0
-- History          : SECHAWLA 20-NOV-02 - Bug 2680542 :
--                    Changed reference  p_asset_tbl(l_asset_cnt) to  p_asset_tbl(l_asset_cnt).p_asset_id
-- End of comments

PROCEDURE create_default_quote_lines (
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                p_default_tql   IN qlt_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_lines_created         NUMBER          := 0;
        l_default_amount        NUMBER          := 0;
        l_asset_cnt             NUMBER;
        l_default_cnt           NUMBER;
        l_default_total         NUMBER;

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_default_quote_lines';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        IF    p_default_tql.COUNT > 0 THEN

            IF p_cle_id IS NOT NULL
            OR p_asset_tbl.COUNT > 0    -- only one set of defaults for a contract
                                        -- comment out this condition to use ELSIF
            THEN

                -- **********************************************
                -- Create default quote lines for a contract line
                -- **********************************************

                l_default_cnt := p_default_tql.FIRST;

                LOOP

                        append_quote_line (
                                p_qtev_rec      => p_qtev_rec,
                                p_qlt_code      => p_default_tql (l_default_cnt),
                                p_amount        => l_default_amount,
                                p_kle_id        => p_cle_id,
                                p_success_yn    => OKL_API.G_RET_STS_SUCCESS,
                                p_sty_id        => NULL,
                                p_formula_name  => NULL,
                                p_sub_tqlv_tbl  => G_EMPTY_TQLV_TBL,
                                p_defaulted_yn  => 'Y',
                                px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_default_total);


                        l_lines_created         := l_lines_created + 1;

                        EXIT WHEN (l_default_cnt = p_default_tql.LAST);
                        l_default_cnt := p_default_tql.NEXT(l_default_cnt);

                END LOOP;

            ELSIF p_asset_tbl.COUNT > 0 THEN    -- set of defaults for every line

                -- *******************************************************
                -- Recursively create default lines for all contract lines
                -- *******************************************************

                l_asset_cnt := p_asset_tbl.FIRST;

                LOOP

                        create_default_quote_lines (
                                p_qtev_rec      => p_qtev_rec,
     -- SECHAWLA - Bug 2680542 : Changed reference  p_asset_tbl(l_asset_cnt) to  p_asset_tbl(l_asset_cnt).p_asset_id
                                p_cle_id        => p_asset_tbl(l_asset_cnt).p_asset_id,
                                p_asset_tbl     => p_asset_tbl,
                                px_tqlv_tbl     => px_tqlv_tbl,
                                p_default_tql   => p_default_tql,
                                x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to create_default_quote_lines :'||l_return_status);
                   END IF;

                        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                                IF l_overall_status <>
                                    OKL_API.G_RET_STS_UNEXP_ERROR THEN
                                        l_overall_status := l_return_status;
                                END IF;
                        END IF;

                        EXIT WHEN (l_asset_cnt = p_asset_tbl.LAST);
                        l_asset_cnt := p_asset_tbl.NEXT(l_asset_cnt);

                END LOOP;

            END IF;

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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END create_default_quote_lines;


-- Start of comments
--
-- Procedure Name       : validate_qlt_conditions
-- Description          : Validate conditions specific for quote line types
-- Business Rules       :
-- Parameters           : quote header records, quote line type
-- Version              : 1.0
-- End of comments

PROCEDURE validate_qlt_conditions (
                p_qtev_rec      IN qtev_rec_type,
                p_qlt_code      IN VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;

        L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_qlt_conditions';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
        -- ************************************************
        -- If an operand contradicts quote type, dismiss it
        -- ************************************************
        IF (    p_qlt_code = 'AMCRFE'
            AND p_qtev_rec.qtp_code NOT IN (
                        'TER_WO_PURCHASE',
                        'TER_ROLL_WO_PURCHASE'))
        OR (    p_qlt_code = 'AMCRIN'
            AND p_qtev_rec.qtp_code NOT IN (
                        'TER_ROLL_PURCHASE',
                        'TER_ROLL_WO_PURCHASE'))
        THEN

                -- QLT_CODE quote line is not
                -- allowed for QTP_CODE quote type
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_ILLEGAL_OPERAND'
                        ,p_msg_level    => OKL_AM_UTIL_PVT.G_DEBUG_LEVEL
                        ,p_token1       => 'QTP_CODE'
                        ,p_token1_value => p_qtev_rec.qtp_code
                        ,p_token2       => 'QLT_CODE'
                        ,p_token2_value => p_qlt_code);

                l_return_status := OKL_API.G_RET_STS_ERROR;

        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := l_return_status;
            END IF;
        END IF;

        IF p_qlt_code IN (G_TAX_QLT, 'AMBPOC') THEN
                -- No message needed
                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := l_return_status;
            END IF;
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);


                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END validate_qlt_conditions;


-- Start of comments
--
-- Procedure Name       : validate_rule_level
-- Description          : Validate if rule specified on the correct level
-- Business Rules       :
-- Parameters           : operand, quote header record, rule group, contract line or table of contract lines,
-- Version                  : 1.0
-- History          : SECHAWLA 20-NOV-02 - Bug 2680542 :
--                    Changed reference  p_asset_tbl(l_asset_cnt) to  p_asset_tbl(l_asset_cnt).p_asset_id
-- End of comments

PROCEDURE validate_rule_level (
                p_rgd_code      IN VARCHAR2,
                p_operand       IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS



        l_rulv_rec                  rulv_rec_type;
        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_line_level_yn         BOOLEAN := FALSE;
        l_asset_cnt             NUMBER;
        l_rule_chr_id           NUMBER;
        L_MODULE_NAME           VARCHAR2(500) := G_MODULE_NAME||'validate_rule_level';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        l_rule_chr_id   := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

        IF p_operand IN ('AMYSAM', 'AMYFEE', 'AMYOUB') THEN

            l_asset_cnt := p_asset_tbl.FIRST;

            LOOP

                okl_am_util_pvt.get_rule_record (
                        p_rgd_code      => p_rgd_code,
                        p_rdf_code      => p_operand,
                        p_chr_id        => l_rule_chr_id,
   -- SECHAWLA - Bug 2680542 : Changed reference  p_asset_tbl(l_asset_cnt) to  p_asset_tbl(l_asset_cnt).p_asset_id
                        p_cle_id        => p_asset_tbl(l_asset_cnt).p_asset_id,
                        x_rulv_rec      => l_rulv_rec,
                        x_return_status => l_return_status,
                        p_message_yn    => FALSE);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
                   END IF;

                IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
                        l_line_level_yn := TRUE;
                END IF;

                EXIT WHEN (l_asset_cnt = p_asset_tbl.LAST
                        OR l_line_level_yn);
                l_asset_cnt := p_asset_tbl.NEXT(l_asset_cnt);

            END LOOP;

            IF l_line_level_yn THEN

                -- Rule for RULE quote element
                -- must be specified on contract level
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_WRONG_OPERAND_LEVEL'
                        ,p_token1       => 'RULE'
                        ,p_token1_value => p_operand);

                l_return_status := OKL_API.G_RET_STS_ERROR;

            ELSE
                l_return_status := OKL_API.G_RET_STS_SUCCESS;
            END IF;

        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := l_return_status;
            END IF;
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);


                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END validate_rule_level;


-- Start of comments
--
-- Procedure Name       : get_rule_value
-- Description          : Evaluate rule record. It can be  not_applicable, constant or formula
-- Business Rules       :
-- Parameters           : contract, line, rule group, rule name, calculation option,  optional fixed amount or formula name
-- Version                  : 1.0
-- History          : SECHAWLA 26-FEB-03 Bug # 2819559 : Added code to convert the fixed amount to contract currency
--                    in case of Recourse type of quoets
--                  : 20-OCT-03 MDOKAL Bug # 3061765 : Financed Fees modifications
--                  : rmunjulu 3797384 added code to send quote_effective_from_date and quote_id
--                    to formula engine
--                  : 29-SEP-04 PAGARG Bug #3921591: Added AMRFEE (rollover) operand processing.
-- End of comments

PROCEDURE get_rule_value (
                p_calc_option   IN VARCHAR2,
                p_fixed_value   IN VARCHAR2,
                p_formula_name  IN VARCHAR2,
                p_rgd_code      IN VARCHAR2,
                p_operand       IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_sub_check_yn  IN BOOLEAN,
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_asset_tbl     IN asset_tbl_type,
                px_sub_tqlv_tbl IN OUT NOCOPY tqlv_tbl_type,
                x_rule_value    OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_overall_status                   VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
        l_return_status                VARCHAR2(1)      := OKL_API.G_RET_STS_SUCCESS;
        l_rule_value                       NUMBER;

    --SECHAWLA 26-FEB-03 Bug # 2819559 : New declarations
    l_rule_chr_id                          NUMBER;
    l_vendor_program_curr_code     GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_lease_contract_curr_code     okc_k_headers_b.currency_code%TYPE;
    lx_contract_currency           okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type    okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate    okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date    okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount            NUMBER;

    -- Bug # 3061765 MDOKAL
    -- Finanaced Fees - passing additonal parameter for calling generic formula
    l_add_params                okl_execute_formula_pub.ctxt_val_tbl_type;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_rule_value';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


        IF    p_calc_option = 'NOT_APPLICABLE' THEN

                l_rule_value    := NULL;

        ELSIF p_calc_option = 'USE_FIXED_AMOUNT'
        AND   NVL (p_fixed_value, G_MISS_CHAR) <> G_MISS_CHAR THEN

                l_rule_value := To_Number (p_fixed_value);

        --SECHAWLA 26-FEB-03 Bug # 2819559 : Convert the fixed amount to contract curency in case of Recourse type of quotes
        IF p_qtev_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
           -- get the functional currency
          -- l_vendor_program_curr_code := okl_am_util_pvt.get_functional_currency;
          l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);
          l_vendor_program_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => l_rule_chr_id);

           -- get the contract currency
           l_lease_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => p_qtev_rec.khr_id);
           IF l_vendor_program_curr_code <> l_lease_contract_curr_code THEN
                okl_accounting_util.convert_to_contract_currency
                    (
                        p_khr_id                        => p_qtev_rec.khr_id,
                        p_from_currency                         => l_vendor_program_curr_code,
                        p_transaction_date                      => G_SYSDATE,
                        p_amount                                    => l_rule_value,
                        x_return_status                     => l_return_status,
                        x_contract_currency                     => lx_contract_currency,
                        x_currency_conversion_type          => lx_currency_conversion_type,
                        x_currency_conversion_rate          => lx_currency_conversion_rate,
                        x_currency_conversion_date          => lx_currency_conversion_date,
                        x_converted_amount                      => lx_converted_amount
                    );

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_accounting_util.convert_to_contract_currency:'||l_return_status);
                   END IF;

                IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                   l_rule_value := lx_converted_amount ;
                END IF;
            END IF;
        END IF;
        -- SECHAWLA 26-FEB-03 Bug # 2819559 : end modifications

        ELSIF p_calc_option = 'USE_FORMULA'
        AND   NVL (p_formula_name, G_MISS_CHAR) <> G_MISS_CHAR THEN

                IF  p_sub_check_yn
                AND p_operand IN ('AMBCOC') THEN

                    process_top_formula (
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => p_line_rgd_code,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_asset_tbl     => p_asset_tbl,
                        p_formula_name  => p_formula_name,
                        p_operand       => p_operand,
                        px_tqlv_tbl     => px_sub_tqlv_tbl,
                        x_formula_total => l_rule_value,
                        x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to process_top_formula :'||l_return_status);
                   END IF;
                    l_rule_value := NULL;

                ELSE

                    okl_am_util_pvt.get_formula_value (
                        p_formula_name  => p_formula_name,
                        p_chr_id        => p_qtev_rec.khr_id,
                        p_cle_id        => p_cle_id,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- pass additional parameters quote_effective_from_date and quote_id
        p_additional_parameters => g_add_params,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++
                        x_formula_value => l_rule_value,
                        x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_formula_value :'||l_return_status);
                   END IF;

                END IF;

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
                        THEN
                                l_overall_status := l_return_status;
                        END IF;
                END IF;

    -- Bug # 3061765 MDOKAL
    -- Finanaced Fees - processing for operands pertaining to financed fee's
    --Bug #3921591: pagarg +++ Rollover +++
    -- Included Rollover Fee opernad also.
    ELSIF p_operand IN ('AMFFEE','AMAFEE','AMIFEE','AMPFEE','AMEFEE','AMMFEE','AMGFEE','AMRFEE')
    THEN
        IF p_formula_name IS NOT NULL THEN -- User has selected a formula
          G_FORMULA_VALUE_FOUND := TRUE;

          -- If the defautl formula (CONTRACT_FEE_AMOUNT) is used then the
          -- operand is passed as an additional parameter
          l_add_params(1).name  := 'p_operand';
              l_add_params(1).value     := p_operand;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- set the quote_effective_from_date and quote_id
          l_add_params(2).name  := g_add_params(1).name;
              l_add_params(2).value     := g_add_params(1).value;

          l_add_params(3).name  := g_add_params(2).name;
              l_add_params(3).value     := g_add_params(2).value;
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++

          --Bug #3921591: pagarg +++ Rollover +++
          -- if cle_id is passed then need to calculate for that asset only. This
          -- will be in case of partial termination and formula will be calculated
          -- for asset level streams for the fee. instead of passing null pass p_cle_id,
          -- value of which will be either nul or asset id
          okl_am_util_pvt.get_formula_value (
                        p_formula_name  => p_formula_name,
                        p_chr_id            => p_qtev_rec.khr_id,
                        p_cle_id            => p_cle_id,
                        p_additional_parameters => l_add_params,
                        x_formula_value => l_rule_value,
                        x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_util_pvt.get_formula_value :'||l_return_status);
           END IF;

        ELSE
          G_FORMULA_VALUE_FOUND := FALSE;
        END IF;
        ELSE

                -- Invalid combination of values
                -- for RULE rule in GROUP group
                okl_am_util_pvt.set_message(
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_INVALID_RULE_FORMULA'
                        ,p_msg_level    => OKL_AM_UTIL_PVT.G_DEBUG_LEVEL
                        ,p_token1       => 'GROUP'
                        ,p_token1_value => p_rgd_code
                        ,p_token2       => 'RULE'
                        ,p_token2_value => p_operand);

                l_overall_status        := OKL_API.G_RET_STS_ERROR;

        END IF;

        x_rule_value    := l_rule_value;
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_rule_value;


-- Start of comments
--
-- Procedure Name       : get_min_max_rule_value
-- Description          : Calculate value of rules with min or max
-- Business Rules       :
-- Parameters           : contract, line, rule group, rule name,
--                        calculation option,
--                        optional fixed amount or formula name
-- History          : PAGARG Bug 4102565 Added 2 new out nocopy parameters
-- Version                  : 1.0
-- End of comments

PROCEDURE get_min_max_rule_value (
                p_rulv_rec      IN rulv_rec_type,
                p_rgd_code      IN VARCHAR2,
                p_operand       IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                px_rule_value   IN OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2,
                x_min_value             OUT NOCOPY NUMBER, -- PAGARG 4102565 Added
                x_max_value             OUT NOCOPY NUMBER) IS -- PAGARG 4102565 Added

        l_dummy_tqlv_tbl        tqlv_tbl_type   := G_EMPTY_TQLV_TBL;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_max_status            VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_min_status            VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_max_value             NUMBER;
        l_min_value             NUMBER;
        L_MODULE_NAME           VARCHAR2(500)   := G_MODULE_NAME||'get_min_max_rule_value';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        IF  p_operand = 'AMCTPE' THEN

                get_rule_value (
                        p_calc_option   => p_rulv_rec.RULE_INFORMATION5,
                        p_fixed_value   => p_rulv_rec.RULE_INFORMATION6,
                        p_formula_name  => p_rulv_rec.RULE_INFORMATION7,
                        p_rgd_code      => p_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_sub_check_yn  => FALSE,
                        p_head_rgd_code => NULL,
                        p_line_rgd_code => NULL,
                        p_asset_tbl     => G_EMPTY_ASSET_TBL,
                        px_sub_tqlv_tbl => l_dummy_tqlv_tbl,
                        x_rule_value    => l_max_value,
                        x_return_status => l_max_status);

        IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_rule_value :'||l_max_status);
        END IF;

                IF l_max_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
                        THEN
                                l_overall_status := l_max_status;
                        END IF;
                END IF;

                IF  l_max_status = OKL_API.G_RET_STS_SUCCESS
                AND l_max_value IS NOT NULL THEN
                        px_rule_value := least (px_rule_value, l_max_value);
                END IF;

        ELSIF  p_operand = 'AMBPOC' THEN

                get_rule_value (
                        p_calc_option   => p_rulv_rec.RULE_INFORMATION5,
                        p_fixed_value   => p_rulv_rec.RULE_INFORMATION6,
                        p_formula_name  => p_rulv_rec.RULE_INFORMATION7,
                        p_rgd_code      => p_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_sub_check_yn  => FALSE,
                        p_head_rgd_code => NULL,
                        p_line_rgd_code => NULL,
                        p_asset_tbl     => G_EMPTY_ASSET_TBL,
                        px_sub_tqlv_tbl => l_dummy_tqlv_tbl,
                        x_rule_value    => l_max_value,
                        x_return_status => l_max_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to get_rule_value :'||l_max_status);
                END IF;

                IF l_max_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
                        THEN
                                l_overall_status := l_max_status;
                        END IF;
                END IF;

                get_rule_value (
                        p_calc_option   => p_rulv_rec.RULE_INFORMATION8,
                        p_fixed_value   => p_rulv_rec.RULE_INFORMATION9,
                        p_formula_name  => p_rulv_rec.RULE_INFORMATION10,
                        p_rgd_code      => p_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_sub_check_yn  => FALSE,
                        p_head_rgd_code => NULL,
                        p_line_rgd_code => NULL,
                        p_asset_tbl     => G_EMPTY_ASSET_TBL,
                        px_sub_tqlv_tbl => l_dummy_tqlv_tbl,
                        x_rule_value    => l_min_value,
                        x_return_status => l_min_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to get_rule_value :'||l_min_status);
                END IF;

                IF l_min_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
                        THEN
                                l_overall_status := l_min_status;
                        END IF;
                END IF;

                IF  l_max_status = OKL_API.G_RET_STS_SUCCESS
                AND l_max_value IS NOT NULL
                AND l_min_status = OKL_API.G_RET_STS_SUCCESS
                AND l_min_value IS NOT NULL
                AND l_max_value < l_min_value THEN

                    -- Invalid combination of values
                    -- for RULE rule in GROUP group
                    okl_am_util_pvt.set_message(
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_MAX_MIN_MISMATCH'
                        ,p_token1       => 'MAX'
                        ,p_token1_value => l_max_value
                        ,p_token2       => 'MIN'
                        ,p_token2_value => l_min_value
                        ,p_token3       => 'GROUP'
                        ,p_token3_value => p_rgd_code
                        ,p_token4       => 'RULE'
                        ,p_token4_value => p_operand);

                    l_overall_status    := OKL_API.G_RET_STS_ERROR;

                END IF;

                IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS
                AND l_max_status = OKL_API.G_RET_STS_SUCCESS
                AND l_max_value IS NOT NULL THEN
                        px_rule_value := least (px_rule_value, l_max_value);
                END IF;

                IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS
                AND l_min_status = OKL_API.G_RET_STS_SUCCESS
                AND l_min_value IS NOT NULL THEN
                        px_rule_value := greatest (px_rule_value, l_min_value);
                END IF;

        END IF;

            x_min_value := l_min_value; -- PAGARG 4102565 Added
            x_max_value := l_max_value; -- PAGARG 4102565 Added

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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_min_max_rule_value;


-- Start of comments
--
-- Procedure Name       : get_operand_value
-- Description          : Calculate value of an operand as
--                        an operand-rule combo or an executable operand
-- Business Rules       :
-- Parameters           : contract, contract line, rule group, rule code
-- History          : PAGARG Bug 4102565 Added 2 new out nocopy parameters
-- Version                  : 1.0
-- End of comments

PROCEDURE get_operand_value (
                p_rgd_code      IN VARCHAR2,
                p_operand       IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_rule_cle_id   IN NUMBER,
                p_formul_cle_id IN NUMBER,
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_asset_tbl     IN asset_tbl_type,
                px_sub_tqlv_tbl IN OUT NOCOPY tqlv_tbl_type,
                x_operand_value OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2,
                x_min_value             OUT NOCOPY NUMBER, -- PAGARG 4102565 Added
                x_max_value             OUT NOCOPY NUMBER) IS -- PAGARG 4102565 Added

        l_rulv_rec              rulv_rec_type;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_operand_value         NUMBER;
        l_rule_chr_id           NUMBER;
          L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_operand_value';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_rgd_code :'||p_rgd_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_operand :'||p_operand);
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --       'p_qtev_rec :'||p_qtev_rec);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_rule_cle_id :'||p_rule_cle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_formul_cle_id :'||p_formul_cle_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_head_rgd_code :'||p_head_rgd_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_line_rgd_code :'||p_line_rgd_code);
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --       'p_asset_tbl :'||p_asset_tbl);
   END IF;



        -- ****************************************************************
        -- Operand Name = Rule Code or Executable Operand = Quote Line Type
        -- ****************************************************************

        -- **********************************************
        -- Try to process operand as a operand-rule combo
        -- **********************************************

        l_rule_chr_id   := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

     IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'before call to okl_am_util_pvt.get_rule_record'||l_return_status);
   END IF;

        okl_am_util_pvt.get_rule_record (
                        p_rgd_code      => p_rgd_code,
                        p_rdf_code      => p_operand,
                        p_chr_id        => l_rule_chr_id,
                        p_cle_id        => p_rule_cle_id,
                        x_rulv_rec      => l_rulv_rec,
                        x_return_status => l_return_status,
                        p_message_yn    => FALSE);

   IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
         'after call to okl_am_util_pvt.get_rule_record'||l_return_status);
   END IF;

        IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

                -- ********************************************************
                -- Evalute rule record: not_applicable, constant or formula
                -- The field INFO1 indicated if the rule is either
                -- not applicable (evaluated to null), equals to a
                -- constant value, or equals to a value of a formula.
                -- The field INFO2 allows to specify the value of a
                -- the constant. The field INFO3 allows to specify a
                -- formula to use for calculations.
                -- ********************************************************

     IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'before call to get_rule_value'||l_return_status);
   END IF;

                get_rule_value (
                        p_calc_option   => l_rulv_rec.RULE_INFORMATION1,
                        p_fixed_value   => l_rulv_rec.RULE_INFORMATION2,
                        p_formula_name  => l_rulv_rec.RULE_INFORMATION3,
                        p_rgd_code      => p_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_formul_cle_id,
                        p_sub_check_yn  => TRUE,
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => p_line_rgd_code,
                        p_asset_tbl     => p_asset_tbl,
                        px_sub_tqlv_tbl => px_sub_tqlv_tbl,
                        x_rule_value    => l_operand_value,
                        x_return_status => l_return_status);

     IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
            'after call to get_rule_value'||l_return_status);
     END IF;

                IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND p_operand IN ('AMCTPE','AMBPOC')
                AND l_operand_value IS NOT NULL THEN

        IF (is_debug_statement_on) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'before call to get_min_max_rule_value'||l_return_status);
        END IF;

                        get_min_max_rule_value (
                                p_rulv_rec      => l_rulv_rec,
                                p_rgd_code      => p_rgd_code,
                                p_operand       => p_operand,
                                p_qtev_rec      => p_qtev_rec,
                                p_cle_id        => p_formul_cle_id,
                                px_rule_value   => l_operand_value,
                                x_return_status => l_return_status,
                                x_min_value => x_min_value, -- rmunjulu 4102565 Added
                                x_max_value => x_max_value); -- rmunjulu 4102565 Added

          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after call to get_min_max_rule_value'||l_return_status);
          END IF;

                END IF;

        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        x_operand_value := l_operand_value;
        x_return_status := l_overall_status;

   IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'x_operand_value..'||x_operand_value);
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'ret status at the end.. '||l_return_status);

   END IF;

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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_operand_value;


-- Start of comments
--
-- Procedure Name       : get_non_rule_operand_value
-- Description          : Look for executable operands and constants
-- Business Rules       :
-- Parameters           : contract, contract line, operand
-- HISTORY          : rmunjulu 3797384 added code to send quote_effective_from_date and quote_id
--                    to formula engine
-- Version              : 1.0
-- End of comments

PROCEDURE get_non_rule_operand_value (
                p_chr_id        IN NUMBER,
                p_cle_id        IN NUMBER,
                px_operand      IN OUT NOCOPY VARCHAR2,
                x_operand_value OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_formula_string        okl_formulae_v.formula_string%TYPE      := NULL;
        l_operand_value         NUMBER;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_non_rule_operand_value';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

           IF (is_debug_procedure_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
           END IF;
        -- *********************************
        -- Try to process executable operand
        -- *********************************

        l_formula_string        := okl_am_util_pvt.get_formula_string
                                        (px_operand);

        IF l_formula_string IS NOT NULL THEN

            okl_am_util_pvt.get_formula_value (
                p_formula_name  => px_operand,
                p_chr_id        => p_chr_id,
                p_cle_id        => p_cle_id,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- pass additional parameters quote_effective_from_date and quote_id
        p_additional_parameters => g_add_params,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++
                x_formula_value => l_operand_value,
                x_return_status => l_return_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_util_pvt.get_formula_value :'||l_return_status);
   END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            END IF;

        -- ***************************
        -- Try to process fixed number
        -- ***************************

        ELSE

            BEGIN
                l_operand_value  := to_number (px_operand);
                px_operand       := G_MISC_QLT;
            EXCEPTION
                WHEN OTHERS THEN
                    l_overall_status := OKL_API.G_RET_STS_ERROR;
            END;

        END IF;

        x_operand_value := l_operand_value;
        x_return_status := l_overall_status;

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

EXCEPTION
        WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_non_rule_operand_value;


-- Start of comments
--
-- Procedure Name       : process_stream_type_operand
-- Description          : Calculate an operand based on stream type
-- Business Rules       :
-- Parameters           : operand, quote header record, contract line or table of contract lines,
--                                table of quote line records, header and line rule groups
-- Version                  : 1.0
-- History          : SECHAWLA 20-NOV-02 - Bug 2680542 :
--                      Changed reference  p_asset_tbl(l_tbl_ind) to  p_asset_tbl(l_tbl_ind).p_asset_id
--                    SECHAWLA 21-APR-03 Bug 2925120
--                      Modified procedure to fix the Unit proration problem for Unbilled rec, Service and Fee lines.
--                  : 20-OCT-03 MDOKAL Bug # 3061765 : Financed Fees modifications
--                  : 12-Apr-05 PAGARG Bug 4300443 Comment the call to validate_rule_level
--                    as user can't specify the T and C at asset level so this
--                    validation is not needed
-- End of comments

PROCEDURE process_stream_type_operand (
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_operand       IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                p_formula_name  IN VARCHAR2,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_operand_total OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_rulv_rec              rulv_rec_type;
        l_tqlv_tbl              tqlv_tbl_type;
        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_operand_total         NUMBER;
        l_line_total            NUMBER;
        l_rgd_code              VARCHAR2(30);
        l_calculate_yn          BOOLEAN;
        l_tbl_ind               NUMBER;
        l_formula_name          VARCHAR2(150)   := NULL;
        l_rule_chr_id           NUMBER;

    -- SECHAWLA 21-APR-03 - Bug 2925120: Unbilled Receivebles amounts not getting Unit Prorated.
    -- New declaraions
    l_asset_ind         NUMBER;
    --akrangan Bug 5495474 start
    l_orig_kle_id NUMBER;
     --cursor to check if financial asset appears as linked asset
        CURSOR l_lnk_ast_csr (p_link_line_id  OKC_K_LINES_B.ID%TYPE) IS
         SELECT cim.object1_id1 kle_id -- original asset id
         FROM   okc_k_lines_b lnk,
                okc_line_styles_b lnk_lse,
                okc_statuses_b sts,
                okc_k_items    cim
         WHERE  lnk.id = cim.cle_id
         AND    lnk.dnz_chr_id = cim.dnz_chr_id
         AND    lnk.lse_id = lnk_lse.id
         AND    lnk_lse.lty_code in ('LINK_FEE_ASSET','LINK_SERV_ASSET')
         AND    sts.code = lnk.sts_code
         AND    sts.ste_code not in ('EXPIRED','TERMINATED','CANCELLED')
         AND    cim.jtot_object1_code = 'OKX_COVASST'
         AND    cim.cle_id = to_char(p_link_line_id)
         AND    cim.object1_id2 = '#';
    --akrangan Bug 5495474 end
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_stream_type_operand';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
        -- **************
        -- Validate lines
        -- **************
        IF p_cle_id IS NOT NULL THEN

                l_rgd_code      := p_line_rgd_code;

        ELSIF p_asset_tbl.COUNT > 0
        AND p_qtev_rec.qtp_code NOT LIKE 'TER_MAN%' THEN
        -- PAGARG Bug 4300443 Comment the call to validate_rule_level as this
                -- validation is redundant
                /*
                validate_rule_level (
                        p_rgd_code      => p_line_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_asset_tbl     => p_asset_tbl,
                        x_return_status => l_return_status);
                */

                l_rgd_code      := p_head_rgd_code;

        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- ***********************************************
        -- Decide if element should be included into quote
        -- ***********************************************

        IF p_qtev_rec.qtp_code LIKE 'TER_MAN%' THEN
                l_calculate_yn  := TRUE;

        ELSIF p_operand IN ('AMYOUB', 'AMYSAM', 'AMYFEE')
        AND   l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

            l_rule_chr_id       := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

            okl_am_util_pvt.get_rule_record (
                p_rgd_code      => l_rgd_code,
                p_rdf_code      => p_operand,
                p_chr_id        => l_rule_chr_id,
                p_cle_id        => p_cle_id,
                x_rulv_rec      => l_rulv_rec,
                x_return_status => l_return_status,
                p_message_yn    => FALSE);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
           END IF;

            IF (        l_return_status <> OKL_API.G_RET_STS_SUCCESS)
            OR (        l_return_status = OKL_API.G_RET_STS_SUCCESS
                    AND l_rulv_rec.RULE_INFORMATION1 = 'Y')
            THEN
/*
                IF  p_qtev_rec.partial_yn = 'Y' THEN

                    -- OPERAND quote element in FORMULA formula can
                    -- not be fully calculated for partial quote
                    okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_INVALID_FOR_PARTIAL'
                        ,p_token1       => 'FORMULA'
                        ,p_token1_value => p_formula_name
                        ,p_token2       => 'OPERAND'
                        ,p_token2_value => p_operand);

                END IF;
*/

                l_calculate_yn  := TRUE;

        -- Bug # 3061765 MDOKAL
        -- Financed Fees, global set to indicate that the contractual fee will
        -- be calculated and therefore do not calculate financed fee types
        -- in process_operand
        IF p_operand = 'AMYFEE' THEN
            G_CONT_FEE_CALC_DONE := TRUE;
        END IF;

                -- Service and Maintenance can have user-defined formula
                -- By default, unbilled streams are calculated
                IF  p_operand = 'AMYSAM'
                AND l_rulv_rec.RULE_INFORMATION2 IS NOT NULL
                AND l_rulv_rec.RULE_INFORMATION2 <> G_MISS_CHAR THEN
                        l_formula_name  := l_rulv_rec.RULE_INFORMATION2;
                END IF;

            ELSE
                l_calculate_yn  := FALSE;

            END IF;

        ELSIF p_operand IN ('AMCTUR') THEN
                l_calculate_yn  := TRUE;

        ELSE
                l_calculate_yn  := FALSE;

        END IF;

        IF l_calculate_yn THEN

            -- *****************************************
            -- Calculate elements for all contract lines
            -- *****************************************

            IF  NVL (p_qtev_rec.partial_yn, 'N') <> 'Y'
            AND p_cle_id IS NULL THEN

                okl_am_calc_quote_stream_pvt.calc_stream_type_operand (
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => NULL,
                        p_formula_name  => l_formula_name,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        x_operand_total => l_line_total,
                        x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_calc_quote_stream_pvt.calc_stream_type_operand :'||l_return_status);
           END IF;

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                    END IF;
                END IF;

            -- **************************************
            -- Calculate elements for a contract line
            -- **************************************

            ELSIF p_cle_id IS NOT NULL THEN

                okl_am_calc_quote_stream_pvt.calc_stream_type_operand (
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_formula_name  => l_formula_name,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        x_operand_total => l_line_total,
                        x_return_status => l_return_status);


                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_calc_quote_stream_pvt.calc_stream_type_operand :'||l_return_status);
                   END IF;


                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                    END IF;
                END IF;

            -- **********************************************
            -- Calculate elements for selected contract lines
            -- **********************************************

            ELSIF p_asset_tbl.COUNT > 0 THEN

                l_tbl_ind := p_asset_tbl.FIRST;

                LOOP

                    okl_am_calc_quote_stream_pvt.calc_stream_type_operand (
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
   -- SECHAWLA - Bug 2680542 : Changed reference  p_asset_tbl(l_tbl_ind) to  p_asset_tbl(l_tbl_ind).p_asset_id
                        p_cle_id        => p_asset_tbl(l_tbl_ind).p_asset_id,
                        p_formula_name  => l_formula_name,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        x_operand_total => l_line_total,
                        x_return_status => l_return_status);


                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_calc_quote_stream_pvt.calc_stream_type_operand :'||l_return_status);
                   END IF;

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
                        THEN
                                l_overall_status := l_return_status;
                        END IF;
                    END IF;

                    EXIT WHEN (l_tbl_ind = p_asset_tbl.LAST);
                    l_tbl_ind := p_asset_tbl.NEXT(l_tbl_ind);

                END LOOP;

            END IF;

            -- ************
            -- Save results
            -- ************

            IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN


                IF l_tqlv_tbl.COUNT > 0 THEN

                    l_tbl_ind := l_tqlv_tbl.FIRST;

                    LOOP

             --SECHAWLA 21-APR-03 - Bug 2925120: Unbilled Receivebles amounts not getting Unit Prorated.
             -- Added the following piece of code to update quantities in l_tqlv_tbl using G_ASSET_TBL
             IF l_tqlv_tbl(l_tbl_ind).kle_id IS NOT NULL THEN
                --akrangan Bug 5495474 start
                FOR l_lnk_ast IN l_lnk_ast_csr(l_tqlv_tbl(l_tbl_ind).kle_id) LOOP
                        l_orig_kle_id := l_lnk_ast.kle_id;
                END LOOP;
                --akrangan Bug 5495474 end
                IF G_ASSET_TBL.COUNT > 0 THEN
                   l_asset_ind := G_ASSET_TBL.FIRST;
                   LOOP
                       IF G_ASSET_TBL(l_asset_ind).p_asset_id = l_tqlv_tbl(l_tbl_ind).kle_id
                       OR (G_ASSET_TBL(l_asset_ind).p_asset_id = l_orig_kle_id) THEN  --added OR condition--akrangan Bug 5495474
                           l_tqlv_tbl(l_tbl_ind).asset_quantity := G_ASSET_TBL(l_asset_ind).p_asset_qty;
                           l_tqlv_tbl(l_tbl_ind).quote_quantity := G_ASSET_TBL(l_asset_ind).p_quote_qty;
                       END IF;

                       EXIT WHEN (l_asset_ind = G_ASSET_TBL.LAST);
                                   l_asset_ind := G_ASSET_TBL.NEXT (l_asset_ind);
                   END LOOP;
                END IF;
             END IF;
             --SECHAWLA 21-APR-03 Bug 2925120: end new code

                        append_quote_line (
                            p_qtev_rec          => p_qtev_rec,
                            p_qlt_code          => p_operand,
                            p_amount            => l_tqlv_tbl(l_tbl_ind).amount,
                            p_kle_id            => l_tqlv_tbl(l_tbl_ind).kle_id,
                p_asset_qty     => l_tqlv_tbl(l_tbl_ind).asset_quantity,
                p_quote_qty     => l_tqlv_tbl(l_tbl_ind).quote_quantity,
                            p_sty_id            => l_tqlv_tbl(l_tbl_ind).sty_id,
                            p_formula_name      => p_formula_name,
                            p_success_yn        => l_return_status,
                            p_sub_tqlv_tbl      => G_EMPTY_TQLV_TBL,
                            p_defaulted_yn      => 'N',
                            px_tqlv_tbl         => px_tqlv_tbl,
                            px_tbl_total        => l_operand_total);

                        EXIT WHEN (l_tbl_ind = l_tqlv_tbl.LAST);
                        l_tbl_ind := l_tqlv_tbl.NEXT (l_tbl_ind);

                    END LOOP;

                ELSE

                    -- No values found for OPERAND operand
                    -- in FORMULA formula
                    okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_NO_OPERAND_VALUES'
                        ,p_token1       => 'FORMULA'
                        ,p_token1_value => p_formula_name
                        ,p_token2       => 'OPERAND'
                        ,p_token2_value => p_operand);

                END IF;

            ELSE

                append_quote_line (
                            p_qtev_rec          => p_qtev_rec,
                            p_qlt_code          => p_operand,
                            p_amount            => G_MISS_NUM,
                            p_kle_id            => NULL,
                            p_formula_name      => p_formula_name,
                            p_success_yn        => l_return_status,
                            p_sty_id            => NULL,
                            p_sub_tqlv_tbl      => G_EMPTY_TQLV_TBL,
                            p_defaulted_yn      => 'N',
                            px_tqlv_tbl         => px_tqlv_tbl,
                            px_tbl_total        => l_operand_total);

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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END  process_stream_type_operand;


-- Start of comments
-- Procedure Name       : process_operand
-- Description          : Calculate quote line(s) for an operand
-- Business Rules       :
-- Parameters           : rule group, operand (= rule code),
--                                quote header record,
--                                contract line or table of contract lines,
--                                table of quote line records,
-- Version                 : 1.0
-- History         : SECHAWLA 20-NOV-02 - Bug 2680542 :
--                     Changed reference  p_asset_tbl(l_asset_cnt) to  p_asset_tbl(l_asset_cnt).p_asset_id
--                     Changed reference l_reject_asset_tbl (l_asset_cnt) to l_reject_asset_tbl (l_asset_cnt).p_asset_id
--                   SECHAWLA 20-FEB-03 Bug # 2757368 :
--                     Added 3 extra parameters asset qty, quote qty and rule_information4 to those calls to
--                     append_quote_lines procedure, which are relevant for proration calculations.
--                   SECHAWLA 24-FEB-03 - Bug 2817025 :
--                     Modified code to by pass proration logic in case of Repurchase quotes
--                  : 20-OCT-03 MDOKAL Bug # 3061765 : Financed Fees modifications
--                 : 29-SEP-2004 PAGARG   Bug #3921591: Added the logic to process rollover fee
--                   operand (AMRFEE) also.
--                 : 21-Dec-2004 PAGARG Bug# 4080063 Remove the Bill Tax parameter
--                   check while calculating estimated property tax quote line.
--                   Check for Property Tax applicable only.
--                 : PAGARG Bug 4102565 Updated the call to get_operand_value
--                   Two additional parameters are passed
--                 : RBRUNO Bug 5380712 - Added check to be introduced  for all quote
--                   line amounts setup as option type of 'No Prorate'.
--                   Added check in the IF condition for 'No Prorate' instead.
-- End of comments

PROCEDURE process_operand (
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_operand       IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                p_formula_name  IN VARCHAR2,
                p_check_qlt_yn  IN BOOLEAN,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_operand_total OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_head_rulv_rec         rulv_rec_type;  -- Header rule record
        l_reject_asset_tbl      asset_tbl_type; -- Lines without rules

        -- Some operands are treated as top formula, that is
        -- their operands are stored separately in this variables
        l_sub_line_tqlv_tbl     tqlv_tbl_type := G_EMPTY_TQLV_TBL;
        l_sub_head_tqlv_tbl     tqlv_tbl_type := G_EMPTY_TQLV_TBL;
        l_sub_head2_tqlv_tbl    tqlv_tbl_type := G_EMPTY_TQLV_TBL;

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_header_status         VARCHAR2(1);
        l_operand               VARCHAR2(30);
        l_operand_total         NUMBER;
        l_operand_value         NUMBER;
        l_header_value          NUMBER;
        l_asset_cnt             NUMBER;
        l_chr_id                NUMBER;
        l_invalid_operand       EXCEPTION;
        l_tbl_ind               NUMBER;
        l_rule_chr_id           NUMBER;

     --Bug # 3061765 MDOKAL - New declarations
    l_head_rgd_code     VARCHAR2(50);
    l_rulv_rec          rulv_rec_type;

    --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
    -- To find out whether given asset is associated to given fee line ot not.
    CURSOR l_asset_partof_fee_csr(cp_chr_id IN NUMBER,
                                  cp_asset_id IN NUMBER,
                                  cp_fee_type IN VARCHAR2)
    IS
    SELECT '1'
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse,
         okc_k_items cim,
         okc_k_lines_v clep,
         okc_line_styles_b lsep,
         OKL_K_LINES kle
    WHERE cle.lse_id = lse.id
      AND lse.lty_code = 'LINK_FEE_ASSET'
      AND cim.cle_id = cle.id
      AND cle.cle_id = clep.id
      AND clep.lse_id = lsep.id
      AND lsep.lty_code = 'FEE'
      AND clep.id = kle.id
      AND clep.chr_id = cp_chr_id
      AND cim.object1_id1 = cp_asset_id
      AND kle.fee_type = cp_fee_type;

    l_partof varchar2(1);

    -- Constants storing different fee type codes that are used to map
    -- operand to fee types
    l_fee_type                 VARCHAR2(50);
    l_amafee          CONSTANT VARCHAR2(30)   := 'ABSORBED';
    l_amefee          CONSTANT VARCHAR2(30)   := 'EXPENSE';
    l_amffee          CONSTANT VARCHAR2(30)   := 'FINANCED';
    l_amgfee          CONSTANT VARCHAR2(30)   := 'GENERAL';
    l_amifee          CONSTANT VARCHAR2(30)   := 'INCOME';
    l_ammfee          CONSTANT VARCHAR2(30)   := 'MISCELLANEOUS';
    l_ampfee          CONSTANT VARCHAR2(30)   := 'PASSTHROUGH';
    l_amsfee          CONSTANT VARCHAR2(30)   := 'SECDEPOSIT';
    l_amrfee          CONSTANT VARCHAR2(30)   := 'ROLLOVER';
    --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

    --Bug# 3925492: pagarg +++ Estd. Prop Tax ++++
    eptx_rulv_rec       rulv_rec_type;
    --Bug 4102565: pagarg
    l_min_value         NUMBER;
    l_max_value         NUMBER;
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_operand';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    --added by akrangan for bug 7043654 begin
    l_qlt_indx          NUMBER;
    --added by akrangan for bug 7043654 end
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
        l_chr_id        := p_qtev_rec.khr_id;
        l_rule_chr_id   := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

        -- ***********************************
        -- Validate operand against quote type
        -- ***********************************

        IF p_check_qlt_yn THEN

            validate_qlt_conditions (
                p_qtev_rec      => p_qtev_rec,
                p_qlt_code      => p_operand,
                x_return_status => l_return_status);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After validate_qlt_conditions call Value of l_return_status'|| l_return_status);
END IF;
            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                RAISE l_invalid_operand;
            END IF;

        END IF;

        -- Bug # 3061765 MDOKAL  **************** Start *******************

    -- As there is no dedicated rule group for manual quotes, variable l_head_rgd_code
    -- is used to store the relevant rule group that exists for auto quotes.
    IF p_head_rgd_code = 'MANUAL' AND nvl(p_qtev_rec.early_termination_yn, 'N') = 'N' THEN
        l_head_rgd_code  := 'AMTFWC'; -- Rule Group for EOT
    ELSIF p_head_rgd_code = 'MANUAL' AND nvl(p_qtev_rec.early_termination_yn, 'N') = 'Y' THEN
        l_head_rgd_code  := 'AMTEWC'; -- Rule Group for Early Termination
    ELSE
        l_head_rgd_code :=  p_head_rgd_code;
    END IF;

    -- If quote is manual and the current operand is for contract fee's,
    -- determine if the corresponding auto quote rule have the contractual fee
    -- option checked or unchecked.
    IF p_head_rgd_code = 'MANUAL' AND p_operand = 'AMYFEE' THEN
        --determine the contractual fee rule value
        okl_am_util_pvt.get_rule_record (
                        p_rgd_code          => l_head_rgd_code, -- use modified rule group
                        p_rdf_code          => p_operand,
                        p_chr_id            => l_rule_chr_id,
                        p_cle_id            => NULL,
                        x_rulv_rec          => l_rulv_rec,
                        x_return_status => l_return_status,
                        p_message_yn    => FALSE);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
           END IF;

        -- If the corresponding rule is not checked (<> 'Y') then set the global
        -- variable (G_PERFORM_CONT_FEE_CALC) to False which will ensure that
        -- processing downstream will calculate financed fee's
        IF l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_rulv_rec.RULE_INFORMATION1 <> 'Y'
        THEN
            G_PERFORM_CONT_FEE_CALC := FALSE;
        END IF;
    END IF;

        -- Bug # 3061765 MDOKAL  **************** End *******************

        -- ***************************************
        -- Calculate elements split by stream type
        -- ***************************************

        IF p_operand IN ('AMYOUB', 'AMYSAM', 'AMYFEE', 'AMCTUR') THEN

        -- Bug # 3061765 MDOKAL
        -- The following condition determines if the global variable
        -- 'G_PERFORM_CONT_FEE_CALC' is TRUE. It will be TRUE by default
        -- unless the quote is manual and the current operand is AMYFEE
        -- (contractual fee) where the corresponding auto quote rule and rule
        -- group indicate that contratual fee should not be calculated.
        -- To verify logic used, search for G_PERFORM_CONT_FEE_CALC

        IF G_PERFORM_CONT_FEE_CALC <> FALSE THEN

            process_stream_type_operand (
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => p_line_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_asset_tbl     => p_asset_tbl,
                        p_formula_name  => p_formula_name,
                        px_tqlv_tbl     => px_tqlv_tbl,
                        x_operand_total => l_operand_total,
                        x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to process_stream_type_operand :'||l_return_status);
           END IF;

        END IF;
        -- *************************
    -- Bug # 3061765 MDOKAL
        -- Processing fee lines
        -- *************************
    ELSIF p_operand LIKE 'AM%FEE' THEN

        --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
        -- Store fee type using constant into l_fee_type based on p_operand value
        IF p_operand = 'AMAFEE' THEN
            l_fee_type := l_amafee;
        ELSIF p_operand = 'AMEFEE' THEN
            l_fee_type := l_amefee;
        ELSIF p_operand = 'AMFFEE' THEN
            l_fee_type := l_amffee;
        ELSIF p_operand = 'AMGFEE' THEN
            l_fee_type := l_amgfee;
        ELSIF p_operand = 'AMIFEE' THEN
            l_fee_type := l_amifee;
        ELSIF p_operand = 'AMMFEE' THEN
            l_fee_type := l_ammfee;
        ELSIF p_operand = 'AMPFEE' THEN
            l_fee_type := l_ampfee;
        ELSIF p_operand = 'AMSFEE' THEN
            l_fee_type := l_amsfee;
        ELSIF p_operand = 'AMRFEE' THEN
            l_fee_type := l_amrfee;
        END IF;
        --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

        -- The following condition ensures that the termination is full and
        -- checks that contractual fee lines have not already been appended
        -- Auto quotes and Manual quotes have separate globals and conditions to
        -- check due the fact the auto quotes are supported by specific rules groups
        -- whereas with manual quotes the corresponding auto quote rule group
        -- has to be applied.
        IF nvl(p_qtev_rec.partial_yn, 'N') = 'N'
            AND (p_head_rgd_code <> 'MANUAL' AND G_CONT_FEE_CALC_DONE = FALSE)
            OR (p_head_rgd_code = 'MANUAL' AND G_PERFORM_CONT_FEE_CALC = FALSE)
        THEN
            --sechawla 30-apr-09 7575939 : begin
            IF ((G_FIN_FEE_CALC_DONE <> TRUE) OR
	                   (G_ABS_FEE_CALC_DONE <> TRUE) OR
	                    (G_EXP_FEE_CALC_DONE <> TRUE) OR
	                    (G_GEN_FEE_CALC_DONE <> TRUE) OR
	                     (G_IN_FEE_CALC_DONE <> TRUE) OR
	                     (G_MISC_FEE_CALC_DONE <> TRUE) OR
	                     (G_PASS_FEE_CALC_DONE <> TRUE) OR
                   (G_ROLL_FEE_CALC_DONE <> TRUE)) THEN
                   --sechawla 30-apr-09 7575939 : end


                l_operand       := p_operand;

                get_operand_value (
                        p_rgd_code      => l_head_rgd_code,
                        p_operand       => l_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_rule_cle_id   => NULL,
                        p_formul_cle_id => NULL,
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => NULL,
                        p_asset_tbl     => G_EMPTY_ASSET_TBL,
                        px_sub_tqlv_tbl => l_sub_line_tqlv_tbl,
                        x_operand_value => l_operand_value,
                        x_return_status => l_return_status,
                        x_min_value             => l_min_value,  -- PAGARG 4102565 Added
                        x_max_value             => l_max_value); -- PAGARG 4102565 Added
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_operand_value call Value of l_return_status'|| l_return_status);
END IF;
            IF G_FORMULA_VALUE_FOUND THEN
              G_FORMULA_VALUE_FOUND := FALSE;  -- cklee added Bug: 6816439

                  append_quote_line (
                        p_qtev_rec      => p_qtev_rec,
                        p_qlt_code      => l_operand,
                        p_amount        => l_operand_value,
                        p_kle_id        => NULL,
                        p_formula_name  => p_formula_name,
                        p_success_yn    => l_return_status,
                        p_sub_tqlv_tbl  => l_sub_line_tqlv_tbl,
                        p_sty_id        => NULL,
                        p_defaulted_yn  => 'N',
                        px_tqlv_tbl     => px_tqlv_tbl,
                        px_tbl_total    => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call Value of l_return_status'|| l_return_status);
END IF;
            END IF;

            --sechawla 30-apr-09 7575939 : begin
            IF  l_operand = 'AMAFEE' THEN
	                G_ABS_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMEFEE' THEN
	                G_EXP_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMFFEE' THEN
	                G_FIN_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMGFEE' THEN
	                G_GEN_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMIFEE' THEN
	                G_IN_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMMFEE' THEN
	                G_MISC_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMPFEE' THEN
	                G_PASS_FEE_CALC_DONE := TRUE;
	            ELSIF l_operand = 'AMRFEE' THEN
	                G_ROLL_FEE_CALC_DONE := TRUE;
            END IF;
          END IF;  --sechawla 30-apr-09 7575939 : end

        --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
        -- If quote is a partial termination quote then get the fee operand value
        -- based on the fee asset level streams.
        ELSIF p_asset_tbl.COUNT > 0
        THEN
           l_asset_cnt := p_asset_tbl.FIRST;
           LOOP
              -- Check whether given asset is associated to fee or not. If yes then
              -- pass asset id also to get_operand_value
              OPEN l_asset_partof_fee_csr (p_qtev_rec.khr_id,
                                               p_asset_tbl(l_asset_cnt).p_asset_id,
                                               l_fee_type);
              FETCH l_asset_partof_fee_csr INTO l_partof;
                 IF l_asset_partof_fee_csr%FOUND
                 THEN
                    get_operand_value (
                         p_rgd_code      => l_head_rgd_code,
                         p_operand       => p_operand,
                         p_qtev_rec      => p_qtev_rec,
                         p_rule_cle_id   => null,
                         p_formul_cle_id => p_asset_tbl(l_asset_cnt).p_asset_id,
                         p_head_rgd_code => p_head_rgd_code,
                         p_line_rgd_code => p_line_rgd_code,
                         p_asset_tbl     => G_EMPTY_ASSET_TBL,
                         px_sub_tqlv_tbl => l_sub_line_tqlv_tbl,
                         x_operand_value => l_operand_value,
                         x_return_status => l_return_status,
                         x_min_value     => l_min_value,  -- PAGARG 4102565 Added
                         x_max_value     => l_max_value); -- PAGARG 4102565 Added
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_operand_value call 2 Value of l_return_status'|| l_return_status);
END IF;
                    IF l_return_status = OKL_API.G_RET_STS_SUCCESS
                    THEN
                       append_quote_line (
                              p_qtev_rec     => p_qtev_rec,
                              p_qlt_code     => p_operand,
                              p_amount       => l_operand_value,
                              p_kle_id       => p_asset_tbl(l_asset_cnt).p_asset_id,
                              p_asset_qty    => p_asset_tbl(l_asset_cnt).p_asset_qty,
                              p_quote_qty    => p_asset_tbl(l_asset_cnt).p_quote_qty,
                              p_formula_name => p_formula_name,
                              p_success_yn   => l_return_status,
                              p_sub_tqlv_tbl => l_sub_line_tqlv_tbl,
                              p_sty_id       => NULL,
                              p_defaulted_yn => 'N',
                              px_tqlv_tbl    => px_tqlv_tbl,
                              px_tbl_total   => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 2 Value of l_return_status'|| l_return_status);
END IF;
                    END IF;
                 END IF;
              CLOSE l_asset_partof_fee_csr;
                  -- Clear variable for the next loop cycle
                  l_sub_line_tqlv_tbl := G_EMPTY_TQLV_TBL;
           EXIT WHEN (l_asset_cnt = p_asset_tbl.LAST);
              l_asset_cnt := p_asset_tbl.NEXT(l_asset_cnt);
           END LOOP;
        --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++
        END IF;

    --Bug# 3925492: pagarg +++ Estd. Prop Tax +++++++ Start ++++++++++
        -- *************************
        -- Processing Estimated Property Tax Operand
        -- *************************
    ELSIF p_operand = 'AMPRTX' THEN
       l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

       IF p_asset_tbl.COUNT > 0
       THEN
          l_asset_cnt := p_asset_tbl.FIRST;
          LOOP
             okl_am_util_pvt.get_rule_record (
                p_rgd_code      => p_head_rgd_code,
                p_rdf_code      => p_operand,
                p_chr_id        => l_rule_chr_id,
                p_cle_id        => NULL,
                x_rulv_rec      => l_rulv_rec,
                x_return_status => l_return_status,
                p_message_yn    => FALSE);

             --Check for rule_information4 to be LINE_CLCULATION or PRORATE
             IF l_return_status = OKL_API.G_RET_STS_SUCCESS
             AND l_rulv_rec.RULE_INFORMATION4 IN ('LINE_CALCULATION', 'PRORATE')
             THEN
                --Obtain the line level rule information for applicability of Property Tax and Bill Tax
                okl_am_util_pvt.get_rule_record(
                       p_rgd_code      => 'LAASTX',
                       p_rdf_code      => 'LAPRTX',
                       p_chr_id        => l_rule_chr_id,
                       p_cle_id        => p_asset_tbl(l_asset_cnt).p_asset_id,
                       x_rulv_rec      => eptx_rulv_rec,
                       x_return_status => l_return_status,
                       p_message_yn    => FALSE);

                IF l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND eptx_rulv_rec.RULE_INFORMATION1 = 'Y' -- Property Tax Applicable
                THEN
                   -- Obtain the operand value

                   -- ********************************************************
                   -- Evalute rule record: not_applicable, constant or formula
                   -- The field INFO1 indicated if the rule is either
                   -- not applicable (evaluated to null), equals to a
                   -- constant value, or equals to a value of a formula.
                   -- The field INFO2 allows to specify the value of a
                   -- the constant. The field INFO3 allows to specify a
                   -- formula to use for calculations.
                   -- ********************************************************
                   get_rule_value (
                         p_calc_option   => l_rulv_rec.RULE_INFORMATION1,
                         p_fixed_value   => l_rulv_rec.RULE_INFORMATION2,
                         p_formula_name  => l_rulv_rec.RULE_INFORMATION3,
                         p_rgd_code      => p_head_rgd_code,
                         p_operand       => p_operand,
                         p_qtev_rec      => p_qtev_rec,
                         p_cle_id        => p_asset_tbl(l_asset_cnt).p_asset_id,
                         p_sub_check_yn  => TRUE,
                         p_head_rgd_code => p_head_rgd_code,
                         p_line_rgd_code => p_line_rgd_code,
                         p_asset_tbl     => G_EMPTY_ASSET_TBL,
                         px_sub_tqlv_tbl => l_sub_line_tqlv_tbl,
                         x_rule_value    => l_operand_value,
                         x_return_status => l_return_status);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_rule_value call 3 Value of l_return_status'|| l_return_status);
END IF;
                   IF l_return_status = OKL_API.G_RET_STS_SUCCESS
                   THEN
                      append_quote_line (
                            p_qtev_rec          => p_qtev_rec,
                            p_qlt_code          => p_operand,
                            p_amount            => l_operand_value,
                            p_kle_id            => p_asset_tbl(l_asset_cnt).p_asset_id,
                            p_asset_qty         => p_asset_tbl(l_asset_cnt).p_asset_qty,
                            p_quote_qty         => p_asset_tbl(l_asset_cnt).p_quote_qty,
                            p_formula_name      => p_formula_name,
                            p_success_yn        => l_return_status,
                            p_sub_tqlv_tbl      => l_sub_line_tqlv_tbl,
                            p_sty_id            => NULL,
                            p_defaulted_yn      => 'N',
                            px_tqlv_tbl         => px_tqlv_tbl,
                            px_tbl_total        => l_operand_total,
                            p_rule_information4 => l_rulv_rec.rule_information4);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 3 Value of l_return_status'|| l_return_status);
END IF;
                   END IF;
                END IF;
             END IF;
             -- Clear variable for the next loop cycle
                 l_sub_line_tqlv_tbl := G_EMPTY_TQLV_TBL;
           EXIT WHEN (l_asset_cnt = p_asset_tbl.LAST);
              l_asset_cnt := p_asset_tbl.NEXT(l_asset_cnt);
           END LOOP;
        END IF;
    --Bug# 3925492: pagarg +++ Estd. Prop Tax +++++++ End ++++++++++

        -- *************************
        -- Processing a single asset
        -- *************************

        ELSIF p_cle_id IS NOT NULL THEN

                l_operand       := p_operand;

                get_operand_value (
                        p_rgd_code      => p_line_rgd_code,
                        p_operand       => l_operand,
                        p_qtev_rec      => p_qtev_rec,
                        p_rule_cle_id   => p_cle_id,
                        p_formul_cle_id => p_cle_id,
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => p_line_rgd_code,
                        p_asset_tbl     => G_EMPTY_ASSET_TBL,
                        px_sub_tqlv_tbl => l_sub_line_tqlv_tbl,
                        x_operand_value => l_operand_value,
                        x_return_status => l_return_status,
                        x_min_value             => l_min_value,  -- PAGARG 4102565 Added
                        x_max_value             => l_max_value); -- PAGARG 4102565 Added
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_operand_value call 4 Value of l_return_status'|| l_return_status);
END IF;
                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                    get_non_rule_operand_value (
                        p_chr_id        => l_chr_id,
                        p_cle_id        => p_cle_id,
                        px_operand      => l_operand,
                        x_operand_value => l_operand_value,
                        x_return_status => l_return_status);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_non_rule_operand_value call 4 Value of l_return_status'|| l_return_status);
END IF;
                END IF;

                append_quote_line (
                        p_qtev_rec      => p_qtev_rec,
                        p_qlt_code      => l_operand,
                        p_amount        => l_operand_value,
                        p_kle_id        => p_cle_id,
                        p_formula_name  => p_formula_name,
                        p_success_yn    => l_return_status,
                        p_sub_tqlv_tbl  => l_sub_line_tqlv_tbl,
                        p_sty_id        => NULL,
                        p_defaulted_yn  => 'N',
                        px_tqlv_tbl     => px_tqlv_tbl,
                        px_tbl_total    => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 5 Value of l_return_status'|| l_return_status);
END IF;

        -- ********************************************************************
        -- Processing array of assets
        -- The following sequence is used to determine value of every operand:
        -- 1. For every asset passed, try to resolve operand-rule combo in the
        --    line rule group for the selected quote type. Unless specified
        --    otherwise, Contract Line IDs (kle_id) of Financial Asset Lines
        --    are used in calls to the Formula Engine.
        -- 2. For all lines which are not resolved in step 1, try to resolve
        --    operand-rule combo in the contract rule group for the selected
        --    quote type. If an operand is found in both rule groups, the line
        --    group take precedence. If an operand-rule combo is only found in
        --    the contract rule group, check Prorate Option to make a decision:
        --     - If some lines were resolved in step 1 and contract rule is
        --       not found, generate warning message and save all unresolved
        --       lines with zero amount.
        --     - If Prorate Option = Line Calculation then calculate operand
        --       on line level which means it is used as a default for all
        --       lines where operand-rule combo is not specified.
        --       There is no proration for line-level operands.
        --     - If Prorate Option = Prorate then calculate operand
        --       on contract level and then prorate it.
        --     - If Prorate Option = No Prorate then calculate operand on
        --       contract level and do not prorate it. If an operand-rule
        --       combo is found for any line is step 1, generate warning
        --       message and save all unresolved lines with zero amount.
        -- 3. If an operand is not resolved in step 1 for all lines and in
        --    step 2 for a contract, the API performs the following steps
        --    in the exact order:
        --     - to treat it as an executable operand
        --     - to treat it as a fixed number
        --     - to save it with zero amount and a warning message
        -- ********************************************************************

        ELSIF p_asset_tbl.COUNT > 0 THEN

            -- ***************************
            -- First find line-level rules
            -- ***************************

            l_asset_cnt := p_asset_tbl.FIRST;

            LOOP

                get_operand_value (
                        p_rgd_code      => p_line_rgd_code,
                        p_operand       => p_operand,
                        p_qtev_rec      => p_qtev_rec,
    -- SECHAWLA - Bug 2680542 : Changed reference  p_asset_tbl(l_asset_cnt) to  p_asset_tbl(l_asset_cnt).p_asset_id
                        p_rule_cle_id   => p_asset_tbl(l_asset_cnt).p_asset_id,
                        p_formul_cle_id => p_asset_tbl(l_asset_cnt).p_asset_id,
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => p_line_rgd_code,
                        p_asset_tbl     => G_EMPTY_ASSET_TBL,
                        px_sub_tqlv_tbl => l_sub_line_tqlv_tbl,
                        x_operand_value => l_operand_value,
                        x_return_status => l_return_status,
                        x_min_value             => l_min_value,  -- PAGARG 4102565 Added
                        x_max_value             => l_max_value); -- PAGARG 4102565 Added
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_operand_value call 6 Value of l_return_status'|| l_return_status);
END IF;
                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
-- SECHAWLA - Bug 2680542 : Changed reference l_reject_asset_tbl (l_asset_cnt) to l_reject_asset_tbl (l_asset_cnt).p_asset_id
--                          Changed reference p_asset_tbl (l_asset_cnt) to p_asset_tbl (l_asset_cnt).p_asset_id
                    l_reject_asset_tbl (l_asset_cnt).p_asset_id :=  p_asset_tbl (l_asset_cnt).p_asset_id;
      --SECHAWLA 20-FEB-03 Bug # 2757368 : added code to populate asset qty and quote qty in l_reject_asset_tbl
             l_reject_asset_tbl (l_asset_cnt).p_asset_qty :=  p_asset_tbl (l_asset_cnt).p_asset_qty;
             l_reject_asset_tbl (l_asset_cnt).p_quote_qty :=  p_asset_tbl (l_asset_cnt).p_quote_qty;


                ELSE

                    append_quote_line (
                        p_qtev_rec            => p_qtev_rec,
                        p_qlt_code            => p_operand,
                        p_amount              => l_operand_value,
   --SECHAWLA - Bug 2680542 : Changed reference p_asset_tbl (l_asset_cnt) to p_asset_tbl (l_asset_cnt).p_asset_id
                        p_kle_id              => p_asset_tbl(l_asset_cnt).p_asset_id,
            p_formula_name        => p_formula_name,
                        p_success_yn      => l_return_status,
                        p_sub_tqlv_tbl    => l_sub_line_tqlv_tbl,
                        p_sty_id              => NULL,
                        p_defaulted_yn    => 'N',
                        px_tqlv_tbl       => px_tqlv_tbl,
                        px_tbl_total      => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 6 Value of l_return_status'|| l_return_status);
END IF;
                END IF;

                -- Clear variable for the next loop cycle
                l_sub_line_tqlv_tbl     := G_EMPTY_TQLV_TBL;

                EXIT WHEN (l_asset_cnt = p_asset_tbl.LAST);
                l_asset_cnt := p_asset_tbl.NEXT(l_asset_cnt);

            END LOOP;

            -- ***************************************************
            -- If any line-level operands failed, try header level
            -- ***************************************************

            IF l_reject_asset_tbl.COUNT > 0 THEN

                l_asset_cnt := l_reject_asset_tbl.FIRST;

                okl_am_util_pvt.get_rule_record (
                        p_rgd_code      => p_head_rgd_code,
                        p_rdf_code      => p_operand,
                        p_chr_id        => l_rule_chr_id,
                        p_cle_id        => NULL,
                        x_rulv_rec      => l_head_rulv_rec,
                        x_return_status => l_return_status,
                        p_message_yn    => FALSE);

                IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND l_head_rulv_rec.RULE_INFORMATION4 IN
                        ('LINE_CALCULATION','PRORATE','NO_PRORATE') THEN

                    IF l_head_rulv_rec.RULE_INFORMATION4 <>
                         'LINE_CALCULATION' THEN

                        get_operand_value (
                                p_rgd_code      => p_head_rgd_code,
                                p_operand       => p_operand,
                                p_qtev_rec      => p_qtev_rec,
                                p_rule_cle_id   => NULL,
                                p_formul_cle_id => NULL,
                                p_head_rgd_code => p_head_rgd_code,
                                p_line_rgd_code => p_line_rgd_code,
                                p_asset_tbl     => p_asset_tbl,
                                px_sub_tqlv_tbl => l_sub_head_tqlv_tbl,
                                x_operand_value => l_header_value,
                                x_return_status => l_header_status,
                        x_min_value             => l_min_value,  -- PAGARG 4102565 Added
                        x_max_value             => l_max_value); -- PAGARG 4102565 Added
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_operand_value call 7 Value of l_return_status'|| l_return_status);
END IF;
                    END IF;

                END IF;

                -- **********************************
                -- Contract-level rule does not exist
                -- **********************************

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                    -- *********************************************
                    -- No line-level or header-level rules are found
                    -- Try to find executable operand or constant
                    -- *********************************************

                    IF l_reject_asset_tbl.COUNT = p_asset_tbl.COUNT THEN

                        l_operand       := p_operand;

                        get_non_rule_operand_value (
                                p_chr_id        => l_chr_id,
                                p_cle_id        => NULL,
                                px_operand      => l_operand,
                                x_operand_value => l_operand_value,
                                x_return_status => l_return_status);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_non_rule_operand_value call 8 Value of l_return_status'|| l_return_status);
END IF;
                        append_quote_line (
                                p_qtev_rec      => p_qtev_rec,
                                p_qlt_code      => l_operand,
                                p_amount        => l_operand_value,
                                p_kle_id        => NULL,
                                p_formula_name  => p_formula_name,
                                p_success_yn    => l_return_status,
                                p_sty_id        => NULL,
                                p_sub_tqlv_tbl  => G_EMPTY_TQLV_TBL,
                                p_defaulted_yn  => 'N',
                                px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 8 Value of l_return_status'|| l_return_status);
END IF;
                    -- ************************************************
                    -- Operand-rule exist for some lines but not others
                    -- ************************************************

                    ELSE

                        LOOP

                            append_quote_line (
                                p_qtev_rec               => p_qtev_rec,
                                p_qlt_code               => p_operand,
                                p_amount                 => G_MISS_NUM,
    --SECHAWLA - Bug 2680542 : Changed reference  l_reject_asset_tbl(l_asset_cnt) to  l_reject_asset_tbl(l_asset_cnt).p_asset_id
                                p_kle_id                 => l_reject_asset_tbl(l_asset_cnt).p_asset_id,
    --SECHAWLA 20-FEB-03 Bug # 2757368 : pass 3 extra parameters - asset qty, quote qty and rule_information 4 to append_quote_lines
                p_asset_qty          => l_reject_asset_tbl(l_asset_cnt).p_asset_qty,
                p_quote_qty          => l_reject_asset_tbl(l_asset_cnt).p_quote_qty,
                p_rule_information4  => l_head_rulv_rec.RULE_INFORMATION4,
                p_formula_name       => p_formula_name,
                                p_success_yn         => OKL_API.G_RET_STS_ERROR,
                                px_tqlv_tbl          => px_tqlv_tbl,
                                p_sty_id                 => NULL,
                                p_sub_tqlv_tbl       => G_EMPTY_TQLV_TBL,
                                p_defaulted_yn       => 'N',
                                px_tbl_total         => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 9 Value of l_return_status'|| l_return_status);
END IF;
                            EXIT WHEN (l_asset_cnt = l_reject_asset_tbl.LAST);
                            l_asset_cnt :=l_reject_asset_tbl.NEXT(l_asset_cnt);

                        END LOOP;

                    END IF;

                -- ***********************************************************
                -- Contract-level rule is used as default for line calculation
                -- ***********************************************************

                ELSIF l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND   l_head_rulv_rec.RULE_INFORMATION4 =
                         'LINE_CALCULATION' THEN

                    LOOP

                        -- look for header-level rule but use cle_id in formula
                        get_operand_value (
                            p_rgd_code          => p_head_rgd_code,
                            p_operand           => p_operand,
                            p_qtev_rec          => p_qtev_rec,
                            p_rule_cle_id       => NULL,
       -- SECHAWLA - Bug 2680542 : Changed reference  l_reject_asset_tbl(l_asset_cnt) to  l_reject_asset_tbl(l_asset_cnt).p_asset_id
                            p_formul_cle_id => l_reject_asset_tbl(l_asset_cnt).p_asset_id,
                            p_head_rgd_code     => p_head_rgd_code,
                            p_line_rgd_code => p_line_rgd_code,
                            p_asset_tbl         => G_EMPTY_ASSET_TBL,
                            px_sub_tqlv_tbl     => l_sub_line_tqlv_tbl,
                            x_operand_value     => l_operand_value,
                            x_return_status     => l_return_status,
                        x_min_value             => l_min_value,  -- PAGARG 4102565 Added
                        x_max_value             => l_max_value); -- PAGARG 4102565 Added
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After get_operand_value call 10 Value of l_return_status'|| l_return_status);
END IF;
                        append_quote_line (
                            p_qtev_rec          => p_qtev_rec,
                            p_qlt_code          => p_operand,
                            p_amount            => l_operand_value,
           --SECHAWLA - Bug 2680542 : Changed reference  l_reject_asset_tbl(l_asset_cnt) to  l_reject_asset_tbl(l_asset_cnt).p_asset_id
                            p_kle_id            => l_reject_asset_tbl(l_asset_cnt).p_asset_id,
        --SECHAWLA 20-FEB-03 Bug # 2757368 : pass 3 extra parameters - asset qty, quote qty and rule_information 4 to append_quote_lines
                p_asset_qty          => l_reject_asset_tbl(l_asset_cnt).p_asset_qty,
                p_quote_qty          => l_reject_asset_tbl(l_asset_cnt).p_quote_qty,
                p_rule_information4  => l_head_rulv_rec.RULE_INFORMATION4,
                p_formula_name  => p_formula_name,
                            p_success_yn        => l_return_status,
                            p_sub_tqlv_tbl      => l_sub_line_tqlv_tbl,
                            p_sty_id            => NULL,
                            p_defaulted_yn      => 'N',
                            px_tqlv_tbl         => px_tqlv_tbl,
                            px_tbl_total        => l_operand_total);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 10 Value of l_return_status'|| l_return_status);
END IF;
                        -- Clear variable for the next loop cycle
                        l_sub_line_tqlv_tbl     := G_EMPTY_TQLV_TBL;

                        EXIT WHEN (l_asset_cnt = l_reject_asset_tbl.LAST);
                        l_asset_cnt := l_reject_asset_tbl.NEXT(l_asset_cnt);

                    END LOOP;

                -- *****************************************
                -- Contract-level rule is used for proration
                -- *****************************************

                ELSIF l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND   l_head_rulv_rec.RULE_INFORMATION4 = 'PRORATE' THEN

                    LOOP

              IF  l_header_status = OKL_API.G_RET_STS_SUCCESS THEN
                -- SECHAWLA 24-FEB-03 - Bug 2817025 : Do not prorate the amount in case of Repurchase quote
                IF p_qtev_rec.qtp_code <> 'REP_STANDARD' THEN
                                -- Use prorated header value
                                prorate_operand (
                                    p_operand           => p_operand,
                                    p_chr_id            => l_chr_id,
                    --SECHAWLA - Bug 2680542 : Changed reference  l_reject_asset_tbl(l_asset_cnt) to  l_reject_asset_tbl(l_asset_cnt).p_asset_id
                                    p_cle_id    => l_reject_asset_tbl(l_asset_cnt).p_asset_id,
                                    p_chr_amt           => l_header_value,
                                    p_formula_name              => p_formula_name,
                                    p_head_sub_tqlv_tbl => l_sub_head_tqlv_tbl,
                                    px_line_sub_tqlv_tbl        => l_sub_line_tqlv_tbl,
                                    x_cle_amt           => l_operand_value,
                                    x_return_status     => l_return_status);
                         IF (is_debug_statement_on) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                                 'After prorate_operand call 10 Value of l_return_status'|| l_return_status);
                         END IF;
                ELSE
                    l_operand_value := l_header_value;
                END IF;
             ELSE
                            l_return_status     := l_header_status;
             END IF;
	    IF (p_operand = 'AMBCOC') THEN
	        G_AMBCOC_OPTION := 'PRORATE';
	    END IF;
            IF (p_operand = 'AMCQFE') then
	            G_AMCQFE_OPTION := 'PRORATE';
            END IF;
            IF (p_operand = 'AMCRFE') then
	           G_AMCRFE_OPTION := 'PRORATE';
            END IF;
            IF (p_operand = 'AMCRIN') then
	            G_AMCRIN_OPTION := 'PRORATE';
            END IF;
            IF (p_operand = 'AMCSDD')  then
	            G_AMCSDD_OPTION := 'PRORATE';
            END IF;
            IF (p_operand = 'AMCTPE') then
	           G_AMCTPE_OPTION := 'PRORATE';
            END IF;
            IF (p_operand = 'AMPRTX') then
	           G_AMPRTX_OPTION := 'PRORATE';
            END IF;
            IF (p_operand = 'AMBPOC') then
	           G_AMBPOC_OPTION := 'PRORATE';
            END IF;

                        append_quote_line (
                                p_qtev_rec      => p_qtev_rec,
                                p_qlt_code      => p_operand,
                                p_amount        => l_operand_value,
        --SECHAWLA - Bug 2680542 : Changed reference  l_reject_asset_tbl(l_asset_cnt) to  l_reject_asset_tbl(l_asset_cnt).p_asset_id
                                p_kle_id        => l_reject_asset_tbl(l_asset_cnt).p_asset_id,
     --SECHAWLA 20-FEB-03 Bug # 2757368 : pass 3 extra parameters - asset qty, quote qty and rule_information 4 to append_quote_lines
                p_asset_qty          => l_reject_asset_tbl(l_asset_cnt).p_asset_qty,
                p_quote_qty          => l_reject_asset_tbl(l_asset_cnt).p_quote_qty,
                p_rule_information4  => l_head_rulv_rec.RULE_INFORMATION4,
                p_formula_name  => p_formula_name,
                                p_success_yn    => l_return_status,
                                p_sub_tqlv_tbl  => l_sub_line_tqlv_tbl,
                                p_sty_id        => NULL,
                                p_defaulted_yn  => 'N',
                                px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);

                        -- Clear variable for the next loop cycle
                        l_sub_line_tqlv_tbl     := G_EMPTY_TQLV_TBL;
            IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 11 Value of l_return_status'|| l_return_status);
END IF;
                        EXIT WHEN (l_asset_cnt = l_reject_asset_tbl.LAST);
                        l_asset_cnt := l_reject_asset_tbl.NEXT(l_asset_cnt);

                    END LOOP;

                    -- *****************************************************
                    -- Save results of disected operand calculated for lines
                    -- *****************************************************

                    IF l_sub_head_tqlv_tbl.COUNT > 0 THEN

                        l_tbl_ind := l_sub_head_tqlv_tbl.FIRST;

                        LOOP

                            IF NVL (l_sub_head_tqlv_tbl(l_tbl_ind).kle_id,
                                        G_MISS_NUM) <> G_MISS_NUM THEN
                                l_sub_head2_tqlv_tbl(l_tbl_ind) :=
                                    l_sub_head_tqlv_tbl(l_tbl_ind);
                            END IF;

                            EXIT WHEN (l_tbl_ind = l_sub_head_tqlv_tbl.LAST);
                            l_tbl_ind := l_sub_head_tqlv_tbl.NEXT (l_tbl_ind);

                        END LOOP;

                    END IF;

                    IF l_sub_head2_tqlv_tbl.COUNT > 0 THEN

                        append_quote_line (
                                p_qtev_rec      => p_qtev_rec,
                                p_qlt_code      => p_operand,
                                p_amount        => NULL,
                                p_kle_id        => NULL,
                                p_formula_name  => p_formula_name,
                                p_success_yn    => OKL_API.G_RET_STS_SUCCESS,
                                p_sub_tqlv_tbl  => l_sub_head2_tqlv_tbl,
                                p_sty_id        => NULL,
                                p_defaulted_yn  => 'N',
                                px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);
            IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 12 Value of l_return_status'|| l_return_status);
END IF;
                    END IF;

                -- *********************************************
                -- Contract-level rule is used without proration
                -- *********************************************

                ELSIF l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND   l_head_rulv_rec.RULE_INFORMATION4 = 'NO_PRORATE' THEN

                    -- ********************************************
                    -- Save one non-prorate header-level quote line
                    -- ********************************************

             -- bug 5380712 rbruno start
             -- Check if the current operand is existing in the operands
             -- appended to the array of quote lines
             -- This indicates the operand (quote line) is already processed for one asset
             -- (the first) for this contract

             --modified by akrangan for bug 7043654 begin
             --changed for i in loop structure to normal loop structure
             --to avoide plsql numeric/value error

               IF px_tqlv_tbl.COUNT > 0
               THEN
                  l_qlt_indx := px_tqlv_tbl.FIRST;

                  LOOP
                     IF p_operand = px_tqlv_tbl (l_qlt_indx).qlt_code
                     THEN
                        -- The current operand is already present in the table
                        -- set the boolean flag off
                        g_compute_qte_fee := FALSE;
                        EXIT;
                     ELSE
                        -- Set the boolean to true
                        -- This executes when the boolean is set to false in the processing
                        -- of the prior operand (quote line) in the loop
                        g_compute_qte_fee := TRUE;
                     END IF;

                     EXIT WHEN (l_qlt_indx = px_tqlv_tbl.LAST);
                     l_qlt_indx := px_tqlv_tbl.NEXT (l_qlt_indx);
                  END LOOP;
               END IF;

             --modified by akrangan for bug 7043654 end
             -- call append quote line only once for a contract and for
             -- a particular quote fee, with the Rule having Fee Prorate
             -- set to 'No Prorate' (i.e. should be computed only once
             -- for a contract, and for a particular fee not per asset)

          IF g_compute_qte_fee = TRUE THEN

            -- bug 5380712 rbruno end

                    IF l_reject_asset_tbl.COUNT = p_asset_tbl.COUNT THEN

                        append_quote_line (
                                p_qtev_rec      => p_qtev_rec,
                                p_qlt_code      => p_operand,
                                p_amount        => l_header_value,
                                p_kle_id        => NULL,
                                p_formula_name  => p_formula_name,
                                p_success_yn    => l_header_status,
                                p_sub_tqlv_tbl  => l_sub_head_tqlv_tbl,
                                p_sty_id        => NULL,
                                p_defaulted_yn  => 'N',
                                px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);
            IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 13 Value of l_return_status'|| l_return_status);
END IF;
                    -- *********************************************
                    -- Header rule NO_PRORATE contradicts line rules
                    -- *********************************************

                    ELSE

                        LOOP

                            append_quote_line (
                                p_qtev_rec      => p_qtev_rec,
                                p_qlt_code      => p_operand,
                                p_amount        => G_MISS_NUM,
        --SECHAWLA - Bug 2680542 : Changed reference  l_reject_asset_tbl(l_asset_cnt) to  l_reject_asset_tbl(l_asset_cnt).p_asset_id
                                p_kle_id    => l_reject_asset_tbl(l_asset_cnt).p_asset_id,
     --SECHAWLA 20-FEB-03 Bug # 2757368 : pass 3 extra parameters - asset qty, quote qty and rule_information 4 to append_quote_lines
                p_asset_qty          => l_reject_asset_tbl(l_asset_cnt).p_asset_qty,
                p_quote_qty          => l_reject_asset_tbl(l_asset_cnt).p_quote_qty,
                p_rule_information4  => l_head_rulv_rec.RULE_INFORMATION4,
                p_formula_name  => p_formula_name,
                                p_success_yn    => OKL_API.G_RET_STS_ERROR,
                                p_sty_id        => NULL,
                                p_sub_tqlv_tbl  => G_EMPTY_TQLV_TBL,
                                p_defaulted_yn  => 'N',
                                px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);

            IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After append_quote_line call 13 Value of l_return_status'|| l_return_status);
END IF;
                            EXIT WHEN (l_asset_cnt = l_reject_asset_tbl.LAST);
                            l_asset_cnt :=l_reject_asset_tbl.NEXT(l_asset_cnt);

                        END LOOP;

                    END IF;

                END IF;

              END IF;

            END IF;

        END IF;

IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_operand_total'|| l_operand_total);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_overall_status'|| l_overall_status);
END IF;
        x_operand_total := l_operand_total;
        x_return_status := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


EXCEPTION

        WHEN l_invalid_operand THEN
                x_return_status := l_overall_status;

        WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END  process_operand;


-- Start of comments
--
-- Procedure Name       : process_top_formula
-- Description          :       Disect formula string, calculate each operand
--                                              and their total
-- Business Rules       :
-- Parameters           :       rule group, formula string, quote record,
--                                              contract line or table of contract lines,
--                                              table of quote line records,
-- HISTORY          : rmunjulu 3797384 added code to send quote_effective_from_date and quote_id
--                    to formula engine
-- Version              : 1.0
-- End of comments

PROCEDURE process_top_formula (
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                p_formula_name  IN VARCHAR2,
                p_operand       IN VARCHAR2,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_formula_total OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_operand_total         NUMBER;
        l_formula_total         NUMBER := 0;
        l_curr_char             VARCHAR2(1);
        l_formula_id            okl_formulae_v.id%TYPE := NULL;
        l_formula_string        okl_formulae_v.formula_string%TYPE := NULL;
        l_temp_string           okl_formulae_v.formula_string%TYPE := NULL;
        l_operand_name          okl_operands_v.name%TYPE;
        l_dummy_value           NUMBER;

        -- Extract evaluation string for a formula
        CURSOR l_formula_csr
                (cp_formula_name IN okl_formulae_v.name%TYPE) IS
                SELECT  f.id, f.formula_string
                FROM    okl_formulae_v f
                WHERE   f.name = cp_formula_name
                AND     f.start_date <= SYSDATE
                AND     NVL (f.end_date, sysdate) >= SYSDATE;

        -- Extract operand name
        CURSOR l_operand_csr (
                cp_formula_id    IN okl_formulae_v.id%TYPE,
                cp_operand_label IN okl_fmla_oprnds_v.label%TYPE) IS
                SELECT  o.name
                FROM    okl_formulae_v  f,
                        okl_fmla_oprnds_v l,
                        okl_operands_v  o
                WHERE   f.id            = cp_formula_id
                AND     l.fma_id        = f.id
                AND     l.label         = cp_operand_label
                AND     o.id            = l.opd_id;
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_top_formula';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


        -- *************************************************
        -- Validate formula and get formula string to disect
        -- *************************************************

        -- Make sure Formula Engine can validate the formula
        okl_am_util_pvt.get_formula_value (
                p_formula_name  => p_formula_name,
                p_chr_id        => p_qtev_rec.khr_id,
                p_cle_id        => p_cle_id,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- pass additional parameters quote_effective_from_date and quote_id
        p_additional_parameters => g_add_params,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++
                x_formula_value => l_dummy_value,
                x_return_status => l_return_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to okl_am_util_pvt.get_formula_value :'||l_return_status);
   END IF;


        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        OPEN    l_formula_csr (p_formula_name);
        FETCH   l_formula_csr INTO l_formula_id, l_formula_string;
        CLOSE   l_formula_csr;

/*    Gkadarka removed below check for bug  4333243 -- Start
        IF NVL (l_formula_string, G_MISS_CHAR) = G_MISS_CHAR
        OR (    p_operand IS NOT NULL
            AND l_formula_string LIKE '%' || p_operand || '%')
        THEN
                -- First condition ensures non-empty string
                -- Second condition ensures absence of recursive references
                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;
bug  4333243 -- End*/
        -- *******************************************************************
        -- The top formula consists of a number of operands separated by PLUS
        -- signs only. Each operand of the formula has a label which directly
        -- corresponds to either
        -- (a) a rule found in rule groups for the selected quote type
        --     (operand-rule combo) or
        -- (b) another formula in the formula engine (executable operand).
        -- *******************************************************************

        IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

            -- make sure last operand is processed
            l_formula_string := l_formula_string || '+';

            -- check every character
            FOR i IN 1 .. LENGTH (l_formula_string) LOOP

                l_curr_char := SUBSTR (l_formula_string, i, 1);

                IF l_curr_char IN ('(','+','-','*','/',')') THEN

                    IF l_curr_char <> '+' THEN

                        -- Only PLUS signs are allowed in the top quote
                        -- formula. Other signs are treated as "+"
                        okl_am_util_pvt.set_message (
                             p_app_name  => G_APP_NAME
                            ,p_msg_name  => 'OKL_AM_INVALID_FORMULA_SIGN'
                            ,p_msg_level => OKL_AM_UTIL_PVT.G_DEBUG_LEVEL);

                    END IF;

                    IF l_temp_string IS NOT NULL THEN

                        l_operand_name := NULL;
                        OPEN    l_operand_csr (l_formula_id, l_temp_string);
                        FETCH   l_operand_csr INTO l_operand_name;
                        CLOSE   l_operand_csr;

                        -- ************************
                        -- Get value for an operand
                        -- ************************

                        IF l_operand_name IS NOT NULL THEN

                            process_operand (
                                p_head_rgd_code => p_head_rgd_code,
                                p_line_rgd_code => p_line_rgd_code,
                                p_operand       => l_operand_name,
                                p_qtev_rec      => p_qtev_rec,
                                p_cle_id        => p_cle_id,
                                p_asset_tbl     => p_asset_tbl,
                                p_formula_name  => p_formula_name,
                                p_check_qlt_yn  => TRUE,
                                px_tqlv_tbl     => px_tqlv_tbl,
                                x_operand_total => l_operand_total,
                                x_return_status => l_return_status);

                           IF (is_debug_statement_on) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                               'before call to oprocess_operand :'||l_return_status);
                           END IF;

                        ELSE
                            -- Should never happen because
                            -- Formula Engine validation above would fail
                            l_return_status := OKL_API.G_RET_STS_ERROR;
       -- invalid id Formula Label Id
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'Formula Label Id');
                        END IF;

                        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                            IF l_overall_status <>
                                OKL_API.G_RET_STS_UNEXP_ERROR THEN
                                    l_overall_status := l_return_status;
                            END IF;
                        END IF;

                        l_formula_total := l_formula_total +
                                           NVL (l_operand_total, 0);
                        l_temp_string   := NULL;

                    END IF;

                ELSE
                    l_temp_string := l_temp_string || l_curr_char;
                END IF;

            END LOOP;

        ELSE

            l_return_status := OKL_API.G_RET_STS_ERROR;
            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            END IF;

        END IF;

        x_formula_total := l_formula_total;
        x_return_status := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


EXCEPTION

        WHEN OTHERS THEN

                IF (l_formula_csr%ISOPEN) THEN
                        CLOSE l_formula_csr;
                END IF;

                IF (l_operand_csr%ISOPEN) THEN
                        CLOSE l_operand_csr;
                END IF;

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END process_top_formula;

-- Start of comments
--
-- Procedure Name       : process_top_formula_new
-- Description          : Disect formula string, calculate each operand
--                                and their total
-- Business Rules       :
-- Parameters           : rule group, formula string, quote record,
--                                contract line or table of contract lines,
--                                table of quote line records,
-- History          : rmunjulu 4300443 Created, This new procedure is more
--                    performant and will be called from main procedure
--                    process_top_rule. The existing procedure process_top_formula
--                    will only be called from get_rule_value.
--                  : rbruno 07-sep-2007 Bug 5380712. Initialized global variable g_compute_qte_fee to True
-- Version                  : 1.0
-- End of comments

PROCEDURE process_top_formula_new (
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                p_formula_name  IN VARCHAR2,
                p_operand       IN VARCHAR2,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                x_formula_total OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_operand_total         NUMBER;
        l_formula_total         NUMBER := 0;
        l_curr_char             VARCHAR2(1);
        l_formula_id            okl_formulae_v.id%TYPE := NULL;
        l_formula_string        okl_formulae_v.formula_string%TYPE := NULL;
        l_temp_string           okl_formulae_v.formula_string%TYPE := NULL;
        l_operand_name          okl_operands_v.name%TYPE;
        l_dummy_value           NUMBER;

        -- Extract evaluation string for a formula
        CURSOR l_formula_csr
                (cp_formula_name IN okl_formulae_v.name%TYPE) IS
                SELECT  f.id, f.formula_string
                FROM    okl_formulae_v f
                WHERE   f.name = cp_formula_name
                AND     f.start_date <= SYSDATE
                AND     NVL (f.end_date, sysdate) >= SYSDATE;

        -- Extract operand name
        CURSOR l_operand_csr (
                cp_formula_id    IN okl_formulae_v.id%TYPE,
                cp_operand_label IN okl_fmla_oprnds_v.label%TYPE) IS
                SELECT  o.name
                FROM    okl_formulae_v  f,
                        okl_fmla_oprnds_v l,
                        okl_operands_v  o
                WHERE   f.id            = cp_formula_id
                AND     l.fma_id        = f.id
                AND     l.label         = cp_operand_label
                AND     o.id            = l.opd_id;

   j NUMBER; --rmunjulu 4300443
   l_asset_tbl asset_tbl_type; --rmunjulu 4300443
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_top_formula_new';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
    -- bug 5380712 rbruno start
    g_compute_qte_fee := TRUE;
    -- bug 5380712 rbruno end



        -- *************************************************
        -- Validate formula and get formula string to disect
        -- *************************************************
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'value of p_formula_name'|| p_formula_name);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'value of p_qtev_rec.khr_id'|| p_qtev_rec.khr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'value of p_cle_id'|| p_cle_id);
END IF;
        -- Make sure Formula Engine can validate the formula
        okl_am_util_pvt.get_formula_value (
                p_formula_name  => p_formula_name,
                p_chr_id        => p_qtev_rec.khr_id,
                p_cle_id        => p_cle_id,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- pass additional parameters quote_effective_from_date and quote_id
        p_additional_parameters => g_add_params,
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++
                x_formula_value => l_dummy_value,
                x_return_status => l_return_status);
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after call to okl_am_util_pvt.get_formula_value :: value of l_return_status'|| l_return_status);
END IF;
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        OPEN    l_formula_csr (p_formula_name);
        FETCH   l_formula_csr INTO l_formula_id, l_formula_string;
        CLOSE   l_formula_csr;

/* -- Similar changes as done by GKADRAKA for bug 4333243
        IF NVL (l_formula_string, G_MISS_CHAR) = G_MISS_CHAR
        OR (    p_operand IS NOT NULL
            AND l_formula_string LIKE '%' || p_operand || '%')
        THEN
                -- First condition ensures non-empty string
                -- Second condition ensures absence of recursive references
                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;
*/
        -- *******************************************************************
        -- The top formula consists of a number of operands separated by PLUS
        -- signs only. Each operand of the formula has a label which directly
        -- corresponds to either
        -- (a) a rule found in rule groups for the selected quote type
        --     (operand-rule combo) or
        -- (b) another formula in the formula engine (executable operand).
        -- *******************************************************************
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'value of l_overall_status'|| l_overall_status);
END IF;
        IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

            -- make sure last operand is processed
            l_formula_string := l_formula_string || '+';

        -- rmunjulu 4300443 Loop thru the asset table only once
        FOR j IN p_asset_tbl.FIRST..p_asset_tbl.LAST LOOP -- rmunjulu 4300443

        l_asset_tbl.DELETE; -- rmunjulu 4300443

        l_asset_tbl(j) := p_asset_tbl(j); -- rmunjulu 4300443

            -- check every character
            FOR i IN 1 .. LENGTH (l_formula_string) LOOP

                l_curr_char := SUBSTR (l_formula_string, i, 1);

                IF l_curr_char IN ('(','+','-','*','/',')') THEN

                    IF l_curr_char <> '+' THEN

                        -- Only PLUS signs are allowed in the top quote
                        -- formula. Other signs are treated as "+"
                        okl_am_util_pvt.set_message (
                             p_app_name  => G_APP_NAME
                            ,p_msg_name  => 'OKL_AM_INVALID_FORMULA_SIGN'
                            ,p_msg_level => OKL_AM_UTIL_PVT.G_DEBUG_LEVEL);

                    END IF;

                    IF l_temp_string IS NOT NULL THEN

                        l_operand_name := NULL;
                        OPEN    l_operand_csr (l_formula_id, l_temp_string);
                        FETCH   l_operand_csr INTO l_operand_name;
                        CLOSE   l_operand_csr;

                        -- ************************
                        -- Get value for an operand
                        -- ************************

                        IF l_operand_name IS NOT NULL THEN

                            process_operand (
                                p_head_rgd_code => p_head_rgd_code,
                                p_line_rgd_code => p_line_rgd_code,
                                p_operand       => l_operand_name,
                                p_qtev_rec      => p_qtev_rec,
                                p_cle_id        => p_cle_id,
                                p_asset_tbl     => l_asset_tbl, -- rmunjulu 4300443
                                p_formula_name  => p_formula_name,
                                p_check_qlt_yn  => TRUE,
                                px_tqlv_tbl     => px_tqlv_tbl,
                                x_operand_total => l_operand_total,
                                x_return_status => l_return_status);

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_operand value of l_return_status'|| l_return_status);
END IF;
                        ELSE
                            -- Should never happen because
                            -- Formula Engine validation above would fail
                            l_return_status := OKL_API.G_RET_STS_ERROR;
       -- invalid id Formula Label Id
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'Formula Label Id');
                        END IF;

                        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                            IF l_overall_status <>
                                OKL_API.G_RET_STS_UNEXP_ERROR THEN
                                    l_overall_status := l_return_status;
                            END IF;
                        END IF;

                        l_formula_total := l_formula_total +
                                           NVL (l_operand_total, 0);
                        l_temp_string   := NULL;

                    END IF;

                ELSE
                    l_temp_string := l_temp_string || l_curr_char;
                END IF;

            END LOOP;

        END LOOP; -- rmunjulu 4300443

        -- rmunjulu 4996136 reset this global variable so that
        --outstanding balance is calculated properly.
        OKL_AM_CALC_QUOTE_STREAM_PVT.G_OUTSTANDING_BAL_DONE :='N';
        OKL_AM_CALC_QUOTE_STREAM_PVT.G_SERVICE_BAL_DONE :='N'; -- rmunjulu  5066471
        --akrangan Bug 5495474 start
        OKL_AM_CALC_QUOTE_STREAM_PVT.G_CONTRACTUAL_FEE_DONE :='N';
        OKL_AM_CALC_QUOTE_STREAM_PVT.G_UNBILLED_RECEIVABLES_DONE :='N';
        --akrangan Bug 5495474 end
        G_PERFORM_CONT_FEE_CALC := TRUE; -- ansethur fix for bug 5579808 - resetting this global variable.

            --sechawla 30-apr-09 7575939 : begin
            G_FIN_FEE_CALC_DONE := FALSE;
	        G_ABS_FEE_CALC_DONE := FALSE;
	        G_EXP_FEE_CALC_DONE := FALSE;
	        G_GEN_FEE_CALC_DONE := FALSE;
	        G_IN_FEE_CALC_DONE  := FALSE;
	        G_MISC_FEE_CALC_DONE := FALSE;
	        G_PASS_FEE_CALC_DONE := FALSE;
            G_ROLL_FEE_CALC_DONE := FALSE;
            --sechawla 30-apr-09 7575939 : end
        ELSE

            l_return_status := OKL_API.G_RET_STS_ERROR;
            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := l_return_status;
        END IF;
            END IF;

        END IF;
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'value of l_formula_total'|| l_formula_total);
END IF;
IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'value of l_overall_status'|| l_overall_status);
END IF;
        x_formula_total := l_formula_total;
        x_return_status := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                IF (l_formula_csr%ISOPEN) THEN
                        CLOSE l_formula_csr;
                END IF;

                IF (l_operand_csr%ISOPEN) THEN
                        CLOSE l_operand_csr;
                END IF;

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END process_top_formula_new;


-- Start of comments
--
-- Procedure Name       : process_top_rule
-- Description          : Process top rule which drives quote calculation
-- Business Rules       :
-- Parameters           : rule group, rule code, quote record,
--                        contract line or table of contract lines,
--                        table of quote line records,
--                        table of default line types
-- Version                  : 1.0
-- History          : rmunjulu 3954846 Added code to not create default quote lines for with purchase
--                    as purchase option still needs to be evaluated, will create default quote lines
--                    finally if even purchase option is not found.
--                  : rmunjulu 4300443 Changed to call the new performant process_top_formula_new
-- End of comments

PROCEDURE process_top_rule (
                p_head_rgd_code IN VARCHAR2,
                p_line_rgd_code IN VARCHAR2,
                p_rdf_code      IN VARCHAR2,
                p_qtev_rec      IN qtev_rec_type,
                p_cle_id        IN NUMBER,
                p_asset_tbl     IN asset_tbl_type,
                px_tqlv_tbl     IN OUT NOCOPY tqlv_tbl_type,
                p_default_tql   IN qlt_tbl_type,
                x_formula_total OUT NOCOPY NUMBER,
                x_return_status OUT NOCOPY VARCHAR2) IS

        l_rulv_rec              rulv_rec_type;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_rgd_code              VARCHAR2(30)    := NULL;
        l_quote_subtotal        NUMBER;
        l_rule_chr_id           NUMBER;

         L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'process_top_rule';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

        -- ******************************************************************
        -- The API derives the top formula from the top rule for a rule group
        -- ******************************************************************
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;


        IF p_head_rgd_code IS NULL AND p_line_rgd_code IS NOT NULL THEN
                l_rgd_code      := p_line_rgd_code;
        ELSIF p_head_rgd_code IS NOT NULL THEN
                l_rgd_code      := p_head_rgd_code;
        END IF;


        IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS
        AND p_qtev_rec.qtp_code NOT LIKE 'TER_MAN%'
        AND l_rgd_code IS NOT NULL
        AND p_rdf_code IS NOT NULL THEN

                l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Value of l_rgd_code'|| l_rgd_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Value of p_rdf_code'|| p_rdf_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Value of l_rule_chr_id'|| l_rule_chr_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Value of p_cle_id'|| p_cle_id);
END IF;
                okl_am_util_pvt.get_rule_record (
                        p_rgd_code      => l_rgd_code,
                        p_rdf_code      => p_rdf_code,
                        p_chr_id        => l_rule_chr_id,
                        p_cle_id        => p_cle_id,
                        x_rulv_rec      => l_rulv_rec,
                        x_return_status => l_return_status,
                        p_message_yn    => TRUE); --FALSE); -- rmunjulu 4741168

IF (is_debug_statement_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to okl_am_util_pvt.get_rule_record from process_top_rule Value of l_return_status'|| l_return_status);
END IF;
        ELSIF l_overall_status = OKL_API.G_RET_STS_SUCCESS
        AND p_qtev_rec.qtp_code LIKE 'TER_MAN%' THEN

                l_rulv_rec.RULE_INFORMATION2 := 'QUOTE_TERMINATION_MANUAL';
                l_return_status := OKL_API.G_RET_STS_SUCCESS;

        ELSE
                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- Uncomment if you want always create default lines
        -- l_overall_status     := OKL_API.G_RET_STS_ERROR;

        -- **************************************
        -- Disect top formula string,
        -- calculate each operand and their total
        -- **************************************

        IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS
        -- AND l_rulv_rec.RULE_INFORMATION1 = 'Y' -- Field is disabled
        AND NVL (l_rulv_rec.RULE_INFORMATION2, G_MISS_CHAR) <> G_MISS_CHAR THEN

                process_top_formula_new ( -- rmunjulu 4300443 Call this new performant procedure
                        p_head_rgd_code => p_head_rgd_code,
                        p_line_rgd_code => p_line_rgd_code,
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_asset_tbl     => p_asset_tbl,
                        p_formula_name  => l_rulv_rec.RULE_INFORMATION2,
                        p_operand       => NULL,
                        px_tqlv_tbl     => px_tqlv_tbl,
                        x_formula_total => l_quote_subtotal,
                        x_return_status => l_return_status);
IF (is_debug_statement_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to process_top_formula_new from process_top_rule Value of l_return_status'|| l_return_status);
END IF;
                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
                        THEN
                                l_overall_status := l_return_status;
                        END IF;
                END IF;

        ELSE
                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- **************************************
        -- Create default lines if no top formula
        -- **************************************

        IF (   l_overall_status <> OKL_API.G_RET_STS_SUCCESS
            OR px_tqlv_tbl.COUNT = 0)
        AND p_qtev_rec.qtp_code NOT LIKE 'TER_MAN%'
    AND p_qtev_rec.qtp_code NOT IN                  -- rmunjulu Added this AND for bug 3954846
                (
                 'TER_PURCHASE',       -- Termination - With Purchase
                 'TER_ROLL_PURCHASE',  -- Termination - Rollover To New Contract With Purchase
                 'TER_RECOURSE'        -- Termination - Recourse With Purchase
                )THEN

                -- Unable to find Quote Formula. LINES default
                -- quote lines are created to be populated manually
                -- +1 is added to count tax line created later
                okl_am_util_pvt.set_message(
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_DEFAULT_QUOTE_LINES');

                create_default_quote_lines (
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => p_cle_id,
                        p_asset_tbl     => p_asset_tbl,
                        px_tqlv_tbl     => px_tqlv_tbl,
                        p_default_tql   => p_default_tql,
                        x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                          'after call to create_default_quote_lines from process_top_rule Value of l_return_status'|| l_return_status);
                END IF;
                -- Overwrite previous errors
                l_overall_status := l_return_status;
                l_quote_subtotal := 0;

        END IF;

        x_formula_total := l_quote_subtotal;
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END process_top_rule;

-- Start of comments
--
-- Procedure Name       : calc_bill_adjust
-- Description          : Calculate Billing Adjustments and store as billing adjustment quote lines
-- Business Rules       :
-- Parameters           :
-- History          : rmunjulu EDAT Created
--                  : rmunjulu 02/09/05 Bug 4161133 Added code to insert billing adjustment date into quote amounts
-- Version                  : 1.0
-- End of comments

PROCEDURE calc_bill_adjust (
                     p_qtev_rec         IN qtev_rec_type,
                     p_asset_tbl        IN asset_tbl_type,
                     px_tqlv_tbl            IN OUT NOCOPY tqlv_tbl_type,
                     x_return_status    OUT NOCOPY VARCHAR2) IS

    l_return_status             VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    l_sub_line_tqlv_tbl tqlv_tbl_type := G_EMPTY_TQLV_TBL;
    l_bill_adjust_value  NUMBER;
    l_kle_id NUMBER;
    l_sty_id NUMBER;
    l_operand_total NUMBER;
    l_prorate_ratio NUMBER;

    l_overall_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    l_api_version        CONSTANT NUMBER := 1;
    l_msg_count NUMBER := OKL_API.G_MISS_NUM;
    l_msg_data  VARCHAR2(2000);

    l_input_tbl OKL_BPD_TERMINATION_ADJ_PVT.input_tbl_type;
    lx_baj_tbl  OKL_BPD_TERMINATION_ADJ_PVT.baj_tbl_type;

    l_due_date DATE; -- rmunjulu Bug 4161133 Added
    l_loan_refund_amount NUMBER; -- rmunjulu LOANS_ENHACEMENTS
     --akrangan  Bug 5655680 start --
             l_orig_kle_id NUMBER;

             --cursor to check if financial asset appears as linked asset
               CURSOR l_lnk_ast_csr (p_link_line_id  OKC_K_LINES_B.ID%TYPE) IS
                 Select    cim.object1_id1 kle_id -- original asset id
                 From   okc_k_lines_b lnk,
                    okc_line_styles_b lnk_lse,
                    okc_statuses_b sts,
                    okc_k_items    cim
                 Where  lnk.id = cim.cle_id
                 and    lnk.dnz_chr_id = cim.dnz_chr_id
                 and    lnk.lse_id = lnk_lse.id
                 and    lnk_lse.lty_code in ('LINK_FEE_ASSET','LINK_SERV_ASSET')
                 and    sts.code = lnk.sts_code
                 and    sts.ste_code not in ('EXPIRED','TERMINATED','CANCELLED')
                 and    cim.jtot_object1_code = 'OKX_COVASST'
                 and    cim.cle_id = to_char(p_link_line_id)
                 and    cim.object1_id2 = '#';
     --akrangan  Bug 5655680 end --
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'calc_bill_adjust';
  is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
  is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
  is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   -- set the input rec for BPD API
   -- If partial termination
   IF nvl(p_qtev_rec.partial_yn, 'N') = 'Y' THEN

      FOR i IN p_asset_tbl.FIRST..p_asset_tbl.LAST LOOP

         l_input_tbl(i).khr_id := p_qtev_rec.khr_id;
         l_input_tbl(i).term_date_from := p_qtev_rec.date_effective_from;
         l_input_tbl(i).kle_id  := p_asset_tbl(i).p_asset_id;

      END LOOP;
   ELSE -- Full termination

      l_input_tbl(1).khr_id := p_qtev_rec.khr_id;
      l_input_tbl(1).term_date_from := p_qtev_rec.date_effective_from;

   END IF;

   -- Call BPD API to get billing from quote_effective_from_date onwards
   OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust(
                        p_api_version     => l_api_version,
                        p_init_msg_list   => OKL_API.G_FALSE,
                        p_input_tbl       => l_input_tbl,
                        x_baj_tbl         => lx_baj_tbl,
                        x_return_status   => l_return_status,
                        x_msg_count       => l_msg_count,
                        x_msg_data        => l_msg_data);


   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'After call to okl_am_util_pvt.get_formula_value :'||l_return_status);
   END IF;

   IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

          -- Error getting the billing adjustments for the contract.
      OKL_API.set_message(
           p_app_name      => 'OKL',
           p_msg_name      => 'OKL_AM_ERROR_BILL_ADJST');

   END IF;

   IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := l_return_status;
          END IF;
   END IF;

   -- For each record returned by BPD, call the append_quote_line to insert the
   -- amount as BILL_ADJST quote line in quote lines table
   IF lx_baj_tbl.COUNT > 0 THEN
      FOR i IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST LOOP

         l_prorate_ratio := 0;

         l_kle_id := lx_baj_tbl(i).kle_id;
         l_sty_id := lx_baj_tbl(i).sty_id;
         l_bill_adjust_value := lx_baj_tbl(i).amount; -- rmunjulu EDAT Added to set amount

                 -- rmunjulu Bug 4161133 Added to get due date for billing adjustment
                 l_due_date := lx_baj_tbl(i).stream_element_date;
                 --akrangan  Bug 5655680 start --
                          FOR l_lnk_ast IN l_lnk_ast_csr(l_kle_id) LOOP
                            l_orig_kle_id := l_lnk_ast.kle_id;
                  END LOOP;
                --akrangan  Bug 5655680 end --
             -- Loop thru the asset tbl to get asset values for current asset
             -- to determine the prorate ratio

             IF  p_asset_tbl.COUNT > 0 THEN
                FOR j IN p_asset_tbl.FIRST..p_asset_tbl.LAST LOOP
             --akrangan  Bug 5655680 start --
                    IF (p_asset_tbl(j).p_asset_id = l_kle_id)  OR (p_asset_tbl(j).p_asset_id = l_orig_kle_id) THEN --akrangan  Bug 5655680
                    --Added or Condition
             --akrangan  Bug 5655680 end --
                  -- determine the prorate ratio
                  l_prorate_ratio := (p_asset_tbl(j).p_quote_qty)/(p_asset_tbl(j).p_asset_qty);

               END IF;
                    END LOOP;
                 END IF;

         -- default the prorate ratio if was not evaluated properly
         IF l_prorate_ratio <= 0
                 OR l_prorate_ratio IS NULL THEN
            l_prorate_ratio := 1;
         END IF;

         -- set into -ve amount and prorate the adjustment amount
         l_bill_adjust_value := 0 - (l_bill_adjust_value * l_prorate_ratio);

         -- Add as BILL_ADJST quote line
         append_quote_line (
                        p_qtev_rec          => p_qtev_rec,
                        p_qlt_code          => 'BILL_ADJST',
                                p_amount            => l_bill_adjust_value,
                                p_kle_id            => l_kle_id,
                        p_formula_name  => NULL,
                        p_success_yn    => l_return_status,
                                p_sub_tqlv_tbl  => l_sub_line_tqlv_tbl,
                                p_sty_id            => l_sty_id,
                        p_defaulted_yn  => 'N',
                        p_due_date      => l_due_date, -- rmunjulu Bug 4161133 Added -- 4161133 Modified
                        px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);

         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                   l_overall_status := l_return_status;
                END IF;
         END IF;

      END LOOP;
   END IF;

   -- rmunjulu LOANS_ENHANCEMENT -- create billing adjustment lines for loans refund
   IF nvl(p_qtev_rec.partial_yn, 'N') = 'N' THEN

     l_loan_refund_amount := OKL_AM_UTIL_PVT.get_excess_loan_payment(
                                     x_return_status    => l_return_status,
                                     p_khr_id           => p_qtev_rec.khr_id);

     IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := l_return_status;
       END IF;
     END IF;

         IF  l_loan_refund_amount <> 0 THEN

        -- get stream type ID
        --Bug 6266134 veramach start
        okl_streams_util.get_dependent_stream_type(
          p_khr_id                     => p_qtev_rec.khr_id,
          p_primary_sty_purpose        => 'RENT',
          p_dependent_sty_purpose      => 'EXCESS_LOAN_PAYMENT_PAID',
          x_return_status              => l_return_status,
          x_dependent_sty_id           => l_sty_id
        );


   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'After call to okl_streams_util.get_dependent_stream_type :'||l_return_status);
   END IF;

        --Bug 6266134 veramach end
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := l_return_status;
          END IF;
        END IF;

        l_loan_refund_amount := l_loan_refund_amount *-1; -- negate the amount

        -- Add as BILL_ADJST quote line
        append_quote_line (
                        p_qtev_rec          => p_qtev_rec,
                        p_qlt_code          => 'BILL_ADJST',
                                p_amount            => l_loan_refund_amount,
                                p_kle_id            => NULL,
                        p_formula_name  => NULL,
                        p_success_yn    => l_return_status,
                                p_sub_tqlv_tbl  => l_sub_line_tqlv_tbl,
                                p_sty_id            => l_sty_id,
                        p_defaulted_yn  => 'N',
                        p_due_date      => NULL,
                        px_tqlv_tbl     => px_tqlv_tbl,
                                px_tbl_total    => l_operand_total);

         IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'After call to append_quote_line :'||l_return_status);
         END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := l_return_status;
          END IF;
        END IF;
     END IF;
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1           => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2           => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END  calc_bill_adjust;


-- Start of comments
--
-- Procedure Name       : calc_anticipated_bill
-- Description          : Calculate Anticipated Billing for future dated quotes
-- Business Rules       :
-- Parameters           :
-- History          : rmunjulu EDAT Created
--                    rmunjulu EDAT Added sel_date
-- Version                  : 1.0
-- End of comments

PROCEDURE calc_anticipated_bill (
                     p_qtev_rec         IN qtev_rec_type,
                     x_return_status    OUT NOCOPY VARCHAR2) IS

        l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_kle_id         NUMBER;
    l_sty_id         NUMBER;
    l_api_version        CONSTANT NUMBER := 1;
    l_msg_count          NUMBER := OKL_API.G_MISS_NUM;
    l_msg_data           VARCHAR2(2000);

        l_overall_status                VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    l_functional_currency_code VARCHAR2(15);
    l_contract_currency_code VARCHAR2(15);
    l_currency_conversion_type VARCHAR2(30);
    l_currency_conversion_rate NUMBER;
    l_currency_conversion_date DATE;
    l_org_id  NUMBER;
    l_converted_amount NUMBER;

    -- Since we do not use the amount or converted amount in TRX_Quotes table
    -- set a hardcoded value for the amount (and pass to to
    -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
    -- conversion values )
    l_hard_coded_amount NUMBER := 100;

    lp_qabv_tbl OKL_TXD_QTE_ANTCPT_BILL_PUB.qabv_tbl_type;
    lx_qabv_tbl OKL_TXD_QTE_ANTCPT_BILL_PUB.qabv_tbl_type;

    l_input_tbl OKL_BPD_TERMINATION_ADJ_PVT.input_tbl_type;
    lx_baj_tbl  OKL_BPD_TERMINATION_ADJ_PVT.baj_tbl_type;

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'calc_anticipated_bill';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   -- if future dated quote
   IF trunc(p_qtev_rec.date_requested) < trunc(p_qtev_rec.date_effective_from) THEN

      -- Call BPD API get all the anticipated billing needed for the contract
      -- set the input rec for BPD API
      l_input_tbl(1).khr_id := p_qtev_rec.khr_id;
      l_input_tbl(1).term_date_from := p_qtev_rec.date_requested;
      l_input_tbl(1).term_date_to := p_qtev_rec.date_effective_from;

      -- Call BPD API to get unbilled amount from quote creation date till quote effective from date
      OKL_BPD_TERMINATION_ADJ_PVT.get_unbilled_recvbl(
                        p_api_version     => l_api_version,
                        p_init_msg_list   => OKL_API.G_FALSE,
                        p_input_tbl       => l_input_tbl,
                        x_baj_tbl         => lx_baj_tbl,
                        x_return_status   => l_return_status,
                        x_msg_count       => l_msg_count,
                        x_msg_data        => l_msg_data);

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_BPD_TERMINATION_ADJ_PVT.get_unbilled_recvbl :'||l_return_status);
      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

         -- Error getting the billing adjustments for the contract.
         OKL_API.set_message(
            p_app_name      => 'OKL',
            p_msg_name      => 'OKL_AM_ERROR_BILL_ADJST');

      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
         IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := l_return_status;
         END IF;
      END IF;

      -- For each record returned by BPD, call the QAB TAPI to insert the
      -- amount as new record in OKL_TXD_QTE_ANTCPT_BILL table
      -- Call the TAPI to insert into new table OKL_TXD_QTE_ANTCPT_BILL
      IF lx_baj_tbl.COUNT > 0 THEN
         FOR i IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST LOOP

            -- set the TAPI tbl type
            lp_qabv_tbl(i).qte_id := p_qtev_rec.id;
            lp_qabv_tbl(i).khr_id := p_qtev_rec.khr_id;
            lp_qabv_tbl(i).kle_id := lx_baj_tbl(i).kle_id;
            lp_qabv_tbl(i).sty_id := lx_baj_tbl(i).sty_id;
            lp_qabv_tbl(i).amount := lx_baj_tbl(i).amount;

                        -- rmunjulu EDAT Added sel_date
            lp_qabv_tbl(i).sel_date := lx_baj_tbl(i).stream_element_date;

            -- Get the functional currency from AM_Util
            OKL_AM_UTIL_PVT.get_func_currency_org(
                                 x_org_id        => l_org_id,
                                 x_currency_code => l_functional_currency_code);

            -- Get the currency conversion details from ACCOUNTING_Util
            OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id                           => p_qtev_rec.khr_id,
                     p_to_currency                  => l_functional_currency_code,
                     p_transaction_date                 => p_qtev_rec.date_effective_from,
                     p_amount                           => l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency            => l_contract_currency_code,
                     x_currency_conversion_type => l_currency_conversion_type,
                     x_currency_conversion_rate => l_currency_conversion_rate,
                     x_currency_conversion_date => l_currency_conversion_date,
                     x_converted_amount         => l_converted_amount);

        IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to OKL_ACCOUNTING_UTIL.convert_to_functional_currency :'||l_return_status);
           END IF;

            -- raise exception if error
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            lp_qabv_tbl(i).currency_code := l_contract_currency_code;
            lp_qabv_tbl(i).currency_conversion_code := l_functional_currency_code;

            -- If the functional currency is different from contract currency then set
            -- currency conversion columns
            IF l_functional_currency_code <> l_contract_currency_code THEN

               -- Set the currency conversion columns
               lp_qabv_tbl(i).currency_conversion_type := l_currency_conversion_type;
               lp_qabv_tbl(i).currency_conversion_rate := l_currency_conversion_rate;
               lp_qabv_tbl(i).currency_conversion_date := l_currency_conversion_date;

            END IF;

         END LOOP;

      END IF;

      -- call TAPI to insert records
      OKL_TXD_QTE_ANTCPT_BILL_PUB.create_txd_qte_ant_bill(
                   p_api_version    => l_api_version,
                   p_init_msg_list  => OKL_API.G_FALSE,
                   x_return_status  => l_return_status,
                   x_msg_count      => l_msg_count,
                   x_msg_data       => l_msg_data,
                   p_qabv_tbl       => lp_qabv_tbl,
                   x_qabv_tbl       => lx_qabv_tbl);

        IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to OKL_TXD_QTE_ANTCPT_BILL_PUB.create_txd_qte_ant_bill:'||l_return_status);
           END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
         IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := l_return_status;
         END IF;
      END IF;

   END IF;

   x_return_status := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN

         IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END  calc_anticipated_bill;


-- Start of comments
--
-- Procedure Name       : repurchase
-- Description          : Calculate repurchase quote
-- Business Rules       :
-- Parameters           : quote header record, list of assets
-- Version                  : 1.0
-- History          : SECHAWLA 20-NOV-02 - Bug 2680542 :
--                    Changed reference p_asset_tbl(l_asset_cnt) to   p_asset_tbl(l_asset_cnt).p_asset_id
-- End of comments

PROCEDURE repurchase (
                p_qtev_rec      IN qtev_rec_type,
                p_asset_tbl     IN asset_tbl_type,
                x_tqlv_tbl      OUT NOCOPY tqlv_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS

        -- Table to store temp results to be copied to x_tqlv_tbl
        l_tqlv_tbl              tqlv_tbl_type;

        -- Rule groups to store repurchase-related rules
        l_repurchase_rule_group  CONSTANT VARCHAR2(30) := 'AMREPQ';

        -- Top rule "Calculate Repurchase Quote"
        l_repurchase_rule_code   CONSTANT VARCHAR2(30) := 'AMARQC';

        -- Default lines to be created if top rule is not found
        l_repurchase_default_tql qlt_tbl_type
                := qlt_tbl_type ('AMBSPR','AMCQFE','AMCQDR');

        l_quote_subtotal        NUMBER := 0;    -- Sum of all quote lines
        l_floor_price           NUMBER := 0;    -- Asset floor price
        l_asset_cnt             NUMBER;         -- Asset counter

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- get the floor price
        CURSOR l_floor_csr (cp_art_id NUMBER, cp_cle_id NUMBER) IS
                SELECT  SUM (NVL (a.floor_price, 0))    floor_price
                FROM    okl_asset_returns_b             a
                WHERE   a.id                            = cp_art_id
                AND     a.kle_id                        = cp_cle_id;

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'repurchase';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    l_asset_cnt := p_asset_tbl.FIRST;
    LOOP  -- All repurchase rules are stored on line level

        -- *******************************************
        -- Calculate values of all quote line elements
        -- *******************************************

        process_top_rule (
                p_head_rgd_code => NULL,
                p_line_rgd_code => l_repurchase_rule_group,
                p_rdf_code      => l_repurchase_rule_code,
                p_qtev_rec      => p_qtev_rec,
      --SECHAWLA - Bug 2680542 : Changed reference p_asset_tbl(l_asset_cnt) to   p_asset_tbl(l_asset_cnt).p_asset_id
                p_cle_id        => p_asset_tbl(l_asset_cnt).p_asset_id,
                p_asset_tbl     => G_EMPTY_ASSET_TBL,
                px_tqlv_tbl     => l_tqlv_tbl,
                p_default_tql   => l_repurchase_default_tql,
                x_formula_total => l_quote_subtotal,
                x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to process_top_rule :'||l_return_status);
           END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- ***************************************
        -- Check Floor Price againt quote subtotal
        -- ***************************************
--SECHAWLA 24-FEB-03 Bug # 2817025 : Do not need to set this message
/*
        l_floor_price := 0;
 -- SECHAWLA - Bug 2680542 : Changed reference p_asset_tbl(l_asset_cnt) to p_asset_tbl(l_asset_cnt).p_asset_id
        OPEN    l_floor_csr (p_qtev_rec.art_id, p_asset_tbl(l_asset_cnt).p_asset_id);
        FETCH   l_floor_csr INTO l_floor_price;
        CLOSE   l_floor_csr;

        IF l_floor_price > l_quote_subtotal THEN

                -- Repurchase Quote amount QUOTE_AMOUNT
                -- is lower than Floor Price FLOOR_PRICE
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_LOW_REP_QUOTE_AMOUNT'
                        ,p_token1       => 'QUOTE_AMOUNT'
                        ,p_token1_value => l_quote_subtotal
                        ,p_token2       => 'FLOOR_PRICE'
                        ,p_token2_value => l_floor_price);

        END IF;
*/


        EXIT WHEN (l_asset_cnt = p_asset_tbl.LAST);
        l_asset_cnt := p_asset_tbl.NEXT(l_asset_cnt);

    END LOOP; -- Every record in Asset table

    x_tqlv_tbl          := l_tqlv_tbl;
    x_return_status     := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                -- close open cursors
                IF l_floor_csr%ISOPEN THEN
                        CLOSE l_floor_csr;
                END IF;


        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END repurchase;


-- Start of comments
--
-- Procedure Name       : repurchase_temp
-- Description          : Calculate repurchase quote on header level
-- Business Rules       :
-- Parameters           : quote header record, list of assets
-- Version              : 1.0
-- End of comments

PROCEDURE repurchase_temp (
                p_qtev_rec      IN qtev_rec_type,
                p_asset_tbl     IN asset_tbl_type,
                x_tqlv_tbl      OUT NOCOPY tqlv_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS

        -- Table to store temp results to be copied to x_tqlv_tbl
        l_tqlv_tbl              tqlv_tbl_type;

        -- Rule groups to store repurchase-related rules
        l_repurchase_rule_group  CONSTANT VARCHAR2(30) := 'AMREPQ';

        -- Top rule "Calculate Repurchase Quote"
        l_repurchase_rule_code   CONSTANT VARCHAR2(30) := 'AMARQC';

        -- Default lines to be created if top rule is not found
        l_repurchase_default_tql qlt_tbl_type
                := qlt_tbl_type ('AMBSPR','AMCQFE','AMCQDR');

        l_quote_subtotal        NUMBER := 0;    -- Sum of all quote lines
        l_floor_price           NUMBER := 0;    -- Asset floor price
        l_asset_cnt             NUMBER;         -- Asset counter

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- get the floor price
        CURSOR l_floor_csr (cp_art_id NUMBER) IS
                SELECT  SUM (NVL (a.floor_price, 0))    floor_price
                FROM    okl_asset_returns_b             a
                WHERE   a.id                            = cp_art_id;

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'repurchase_temp';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

        -- *******************************************
        -- Calculate values of all quote line elements
        -- *******************************************

        process_top_rule (
                p_head_rgd_code => l_repurchase_rule_group,
                p_line_rgd_code => l_repurchase_rule_group,
                p_rdf_code      => l_repurchase_rule_code,
                p_qtev_rec      => p_qtev_rec,
                p_cle_id        => NULL,
                p_asset_tbl     => p_asset_tbl,
                px_tqlv_tbl     => l_tqlv_tbl,
                p_default_tql   => l_repurchase_default_tql,
                x_formula_total => l_quote_subtotal,
                x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to process_top_rule :'||l_return_status);
           END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- ***************************************
        -- Check Floor Price againt quote subtotal
        -- ***************************************

 --SECHAWLA 24-FEB-03 Bug # 2817025 : Do not need to set this message
/*
        l_floor_price := 0;
        OPEN    l_floor_csr (p_qtev_rec.art_id);
        FETCH   l_floor_csr INTO l_floor_price;
        CLOSE   l_floor_csr;

        IF l_floor_price > l_quote_subtotal THEN

                -- Repurchase Quote amount QUOTE_AMOUNT
                -- is lower than Floor Price FLOOR_PRICE
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_LOW_REP_QUOTE_AMOUNT'
                        ,p_token1       => 'QUOTE_AMOUNT'
                        ,p_token1_value => l_quote_subtotal
                        ,p_token2       => 'FLOOR_PRICE'
                        ,p_token2_value => l_floor_price);

        END IF;
*/

        x_tqlv_tbl      := l_tqlv_tbl;
        x_return_status := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                -- close open cursors
                IF l_floor_csr%ISOPEN THEN
                        CLOSE l_floor_csr;
                END IF;

                IF (is_debug_exception_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END repurchase_temp;


-- Start of comments
--
-- Procedure Name       : termination
-- Description          : Calculate termination quote
-- Business Rules       :
-- Parameters           : quote header record, list of assets
-- History          : rmunjulu EDAT Added code to calculate billing adjustments
--                    and anticipated billing
--                  : rmunjulu 3954846 Added code to calculate default quote lines
--                    if no quote line found
-- Version              : 1.0
-- End of comments

PROCEDURE termination (
                p_qtev_rec      IN qtev_rec_type,
                p_asset_tbl     IN asset_tbl_type,
                x_tqlv_tbl      OUT NOCOPY tqlv_tbl_type,
                x_return_status OUT NOCOPY VARCHAR2) IS

        -- Table to store temp results to be copied to x_tqlv_tbl
        l_tqlv_tbl              tqlv_tbl_type;

        -- Rule groups to store termination-related rules
        l_head_termin_rule_group        VARCHAR2(30);
        l_line_termin_rule_group        VARCHAR2(30);
        l_head_pur_opt_rule_group       VARCHAR2(30);
        l_line_pur_opt_rule_group       VARCHAR2(30);

        -- Top rule "Calculate Termination Quote"
        l_termination_rule_code         VARCHAR2(30);

        -- Default lines to be created if top rule is not found
        l_termination_default_tql qlt_tbl_type
                := qlt_tbl_type ('AMBCOC','AMCQDR','AMCMIS');

        -- Sum of all quote lines
        l_quote_subtotal        NUMBER := 0;
        l_pur_opt_total         NUMBER := 0;

        l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
        -- ********************************************************************
        -- Termination quote calculation is split
        -- by three different classifications:
        --  - Early termination or end of term termination (contract maturity).
        --    The Early_Termination_YN in quote header determines the value.
        --  - Termination Quote could be requested from the program (vendor) or
        --    the lease contract (lessee). A quote type indicates where the
        --    request is originated. For vendor quotes, a formula from the
        --    program linked to lease contract is used.
        --  - Termination with purchase or termination without purchase.
        --    A quote type indicates if the quote includes purchase.
        --    If purchase is included, a separate rule group is used to
        --    calculuta purchase option. The program always include purchase.
        --  - Calculate on contract header level (contract) or
        --    calculate on contract line level (asset).
        -- Since conditional rules are not available at this release, these
        -- categories are implemented via 16 rule groups. The API chooses
        -- two of the following generic rule groups (one for contract, one
        -- for asset) and two groups for purchase option (with purchase).
        -- ********************************************************************

        IF p_qtev_rec.qtp_code LIKE 'TER_MAN%' THEN
                l_head_termin_rule_group  := 'MANUAL';
                l_line_termin_rule_group  := 'MANUAL';
        ELSIF p_qtev_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
            IF    p_qtev_rec.early_termination_yn = 'Y' THEN
                l_head_termin_rule_group  := 'AVTEWC';
                l_line_termin_rule_group  := 'AVTEWA';
                l_head_pur_opt_rule_group := 'AVTEOC';
                l_line_pur_opt_rule_group := 'AVTEOA';
            ELSE
                l_head_termin_rule_group  := 'AVTFWC';
                l_line_termin_rule_group  := 'AVTFWA';
                l_head_pur_opt_rule_group := 'AVTFOC';
                l_line_pur_opt_rule_group := 'AVTFOA';
            END IF;
        ELSE
            IF    p_qtev_rec.early_termination_yn = 'Y' THEN
                l_head_termin_rule_group  := 'AMTEWC';
                l_line_termin_rule_group  := 'AMTEWA';
                l_head_pur_opt_rule_group := 'AMTEOC';
                l_line_pur_opt_rule_group := 'AMTEOA';
            ELSE
                l_head_termin_rule_group  := 'AMTFWC';
                l_line_termin_rule_group  := 'AMTFWA';
                l_head_pur_opt_rule_group := 'AMTFOC';
                l_line_pur_opt_rule_group := 'AMTFOA';
            END IF;
        END IF;

        -- **************************************************
        -- The API derives the Termination Quote Formula
        -- from the rule Calculate Termination Quote (AMATQC)
        -- for a selected contract rule group.
        -- **************************************************

        l_termination_rule_code := 'AMATQC';


IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_head_termin_rule_group '|| l_head_termin_rule_group);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_line_termin_rule_group'|| l_line_termin_rule_group);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_head_pur_opt_rule_group'|| l_head_pur_opt_rule_group);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_line_pur_opt_rule_group'|| l_line_pur_opt_rule_group);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_termination_rule_code'|| l_termination_rule_code);

      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of p_asset_tbl.count'|| p_asset_tbl.count);

     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_tqlv_tbl.count'|| l_tqlv_tbl.count);


END IF;
        -- *******************************************
        -- Calculate values of all quote line elements
        -- *******************************************

        process_top_rule (
                p_head_rgd_code => l_head_termin_rule_group,
                p_line_rgd_code => l_line_termin_rule_group,
                p_rdf_code      => l_termination_rule_code,
                p_qtev_rec      => p_qtev_rec,
                p_cle_id        => NULL,
                p_asset_tbl     => p_asset_tbl,
                px_tqlv_tbl     => l_tqlv_tbl,
                p_default_tql   => l_termination_default_tql,
                x_formula_total => l_quote_subtotal,
                x_return_status => l_return_status);

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_top_rule call from trmn Value of l_quote_subtotal '|| l_quote_subtotal);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_top_rule call from trmn Value of l_return_status'|| l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_top_rule call from trmn Value of l_tqlv_tbl.count'|| l_tqlv_tbl.count);

END IF;
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- *****************************************
        -- Calculate values for purchase option only
        -- *****************************************

        IF p_qtev_rec.qtp_code IN ('TER_PURCHASE', 'TER_ROLL_PURCHASE')
        OR p_qtev_rec.qtp_code = 'TER_RECOURSE' THEN


            process_operand (
                p_head_rgd_code => l_head_pur_opt_rule_group,
                p_line_rgd_code => l_line_pur_opt_rule_group,
                p_operand       => 'AMBPOC',
                p_qtev_rec      => p_qtev_rec,
                p_cle_id        => NULL,
                p_asset_tbl     => p_asset_tbl,
                p_formula_name  => 'Purchase Option',
                p_check_qlt_yn  => FALSE,
                px_tqlv_tbl     => l_tqlv_tbl,
                x_operand_total => l_pur_opt_total,
                x_return_status => l_return_status);

  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_operand call from trmn Value of l_pur_opt_total '|| l_quote_subtotal);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_operand call from trmn Value of l_return_status'|| l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after process_operand call from trmn Value of l_tqlv_tbl.count'|| l_tqlv_tbl.count);

END IF;
            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            ELSE
		         l_overall_status := l_return_status; -- sechawla 13-aug-08 bug 7233781
	        END IF;

        END IF;


    -- rmunjulu EDAT Added call to calculate and store billing adjustment quote lines
    calc_bill_adjust (
                     p_qtev_rec         =>  p_qtev_rec,
             p_asset_tbl        =>  p_asset_tbl,
                     px_tqlv_tbl            =>  l_tqlv_tbl,
                     x_return_status    =>  l_return_status);

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after calc_bill_adjust call from trmn Value of l_return_status'|| l_return_status);
    END IF;
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
    END IF;

    -- rmunjulu EDAT Added call to calculate and store anticipated billing
    calc_anticipated_bill (
                     p_qtev_rec         =>  p_qtev_rec,
                     x_return_status    =>  l_return_status);
    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after calc_anticipated_bill call from trmn Value of l_return_status'|| l_return_status);
    END IF;
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
    END IF;

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Value of l_tqlv_tbl.count'|| l_tqlv_tbl.count);
    END IF;
    -- rmunjulu Added for bug 3954846
    -- if no quote lines calculated then create the default quote lines for each asset
    IF l_tqlv_tbl.count = 0 THEN

                -- quote lines are created to be populated manually
                -- +1 is added to count tax line created later
                okl_am_util_pvt.set_message(
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_DEFAULT_QUOTE_LINES');

                create_default_quote_lines (
                        p_qtev_rec      => p_qtev_rec,
                        p_cle_id        => NULL,
                        p_asset_tbl     => p_asset_tbl,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        p_default_tql   => l_termination_default_tql,
                        x_return_status => l_return_status);

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to create_default_quote_lines from termination Value of l_return_status'|| l_return_status);
    END IF;
            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                --IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN -- rmunjulu 4741168 removed
                        l_overall_status := l_return_status;
                --END IF;
                ELSE -- rmunjulu 4741168 added so that the default lines get calculated without error on screen
                     l_overall_status := l_return_status;
            END IF;

    END IF;

        x_tqlv_tbl      := l_tqlv_tbl;
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
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END termination;


-- Start of comments
--
-- Procedure Name       : generate
-- Description          : The main body of the package that controls the flow.
-- Business Rules       :
-- Parameters           : quote header record, list of assets
-- Version                  : 1.0
-- History          : SECHAWLA 24-FEB-03 Bug # 2817025
--                      Added code to get the system date
--                    SECHAWLA 21-APR-03 Bug 2925120
--                      Stored the asset table in a global variable. This is used later by process_stream_type_operand
--                      procedure to get the asset and quote quantities in order to facilitate unit proration for Unbilled
--                      rec, service and Fee lines.
--                  : rmunjulu 3797384 Added code for passing quote_eff_from date
--                    and quote_id to formula engine
--                  : PAGARG Bug# 3925453: Include new quote type in the call to
--                    termination() procedure
--                  : rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
--                  : PAGARG 12-Apr-05 Bug 4300443 Call bulk insert to insert quote lines
-- End of comments

PROCEDURE generate (
                p_api_version   IN  NUMBER,
                p_init_msg_list IN  VARCHAR2, -- DEFAULT OKC_API.G_FALSE in specs
                x_msg_count     OUT NOCOPY NUMBER,
                x_msg_data      OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2,
                p_qtev_rec      IN  qtev_rec_type,
                p_asset_tbl     IN  asset_tbl_type,
                x_tqlv_tbl      OUT NOCOPY tqlv_tbl_type) IS

        l_qtev_rec              qtev_rec_type   := p_qtev_rec;
        l_asset_tbl             asset_tbl_type  := p_asset_tbl;
        l_tqlv_tbl              tqlv_tbl_type;
        lx_tqlv_tbl             tqlv_tbl_type;

        -- cursor to make sure all passed lines exist
        -- and have the correct line style
        CURSOR  l_line_csr (cp_line_id NUMBER) IS
                SELECT  'Y'
                FROM    okc_k_lines_b           l,
                        okc_line_styles_b       s
                WHERE   l.id            = cp_line_id
                AND     s.id            = l.lse_id
                AND     s.lty_code      = G_FIN_ASSET_STYLE;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;

        l_asset_cnt             NUMBER;
        l_invalid_line_yn       BOOLEAN;
        l_temp_result           VARCHAR2(1);
        l_rule_chr_id           NUMBER;

        l_api_name              CONSTANT VARCHAR2(30)   := 'generate';
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'generate';
      is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   --Print Input Variables


   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_api_version :'||p_api_version);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_init_msg_list :'||p_init_msg_list);
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --       'p_qtev_rec :'||p_qtev_rec);
       --OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       --     'p_asset_tbl :'||p_asset_tbl);
   END IF;



        -- ***************************************************************
        -- Check API version, initialize message list and create savepoint
        -- ***************************************************************

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls OKL_API.START_ACTIVITY :'||l_return_status);
END IF;

        l_return_status := OKL_API.START_ACTIVITY (
                l_api_name,
                G_PKG_NAME,
                p_init_msg_list,
                l_api_version,
                p_api_version,
                '_PVT',
                x_return_status);

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls OKL_API.START_ACTIVITY :'||l_return_status);
END IF;

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    -- SECHAWLA 24-FEB-03 Bug # 2817025 : Get sysdate
    SELECT sysdate INTO G_SYSDATE from dual;

    --SECHAWLA 21-APR-03 Bug 2925120 : Store the asset table in a global variable
    G_ASSET_TBL := p_asset_tbl;

        -- ****************************************************************
        -- Make sure all required data is passed
        -- 1. Array of assets is passed to the API in both partial and full
        --    termination cases, which means all contract assets need to be
        --    passed for full termination. It the array is empty, the API
        --    will not generate any quote lines and return an error.
        -- 2. Quote ID is required to store quote elements
        -- 3. Contract ID is required to find contract calculation rules
        -- 4. All array elements must store Financial Asset Line ID to get
        --    line rules and streams.
        -- ****************************************************************

        l_asset_cnt     := l_asset_tbl.FIRST;
        l_invalid_line_yn       := FALSE;

        IF l_asset_tbl.COUNT > 0 THEN

            LOOP

                -- Find invalid lines
                l_temp_result   := 'N';

                OPEN    l_line_csr (l_asset_tbl(l_asset_cnt).p_asset_id);
                FETCH   l_line_csr INTO l_temp_result;
                CLOSE   l_line_csr;

                IF l_temp_result = 'N' THEN
                        l_invalid_line_yn := TRUE;
                END IF;

                EXIT WHEN (l_asset_cnt = l_asset_tbl.LAST
                        OR l_invalid_line_yn);
                l_asset_cnt := l_asset_tbl.NEXT(l_asset_cnt);

            END LOOP;

        END IF;

        l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (l_qtev_rec);

        IF l_asset_tbl.COUNT = 0
        OR NVL (l_qtev_rec.id,     G_MISS_NUM) = G_MISS_NUM
        OR NVL (l_qtev_rec.khr_id, G_MISS_NUM) = G_MISS_NUM
        OR NVL (l_rule_chr_id,     G_MISS_NUM) = G_MISS_NUM
        OR l_invalid_line_yn THEN

                -- Please supply required information
                -- in order to calculate a quote
                okl_am_util_pvt.set_message (
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_NO_PARAMETERS');

                RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

    -- set the operands for formula engine with quote_effective_from date
    g_add_params(1).name := 'quote_effective_from_date';
    g_add_params(1).value := to_char(p_qtev_rec.date_effective_from,'MM/DD/YYYY');  -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

    -- set the operands for formula engine with quote_id
    g_add_params(2).name := 'quote_id';
    g_add_params(2).value := to_char(p_qtev_rec.id);

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End   ++++++++++++++++

        -- *******************************************
        -- Call various procedures based on quote_type
        -- *******************************************

        IF l_qtev_rec.qtp_code IN
                ('TER_PURCHASE', 'TER_ROLL_PURCHASE',
                 'TER_WO_PURCHASE', 'TER_ROLL_WO_PURCHASE',
        --Bug# 3925453: pagarg +++ T and A ++++
        --Include new Quote Type to call termination()
                 'TER_RELEASE_WO_PURCHASE')
        OR l_qtev_rec.qtp_code LIKE 'TER_RECOURSE%'
        OR l_qtev_rec.qtp_code LIKE 'TER_MAN%'
        THEN

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls termination :'||l_return_status);
END IF;

                termination (
                        p_qtev_rec      => l_qtev_rec,
                        p_asset_tbl     => l_asset_tbl,
                        x_tqlv_tbl      => l_tqlv_tbl,
                        x_return_status => l_return_status);

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls termination :'||l_return_status);
END IF;

                l_overall_status := l_return_status;

        ELSIF l_qtev_rec.qtp_code = 'REP_STANDARD' THEN

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls repurchase_temp :'||l_return_status);
END IF;

                repurchase_temp (
                        p_qtev_rec      => l_qtev_rec,
                        p_asset_tbl     => l_asset_tbl,
                        x_tqlv_tbl      => l_tqlv_tbl,
                        x_return_status => l_return_status);

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls repurchase_temp :'||l_return_status);
END IF;

                l_overall_status := l_return_status;

        ELSE

                -- Please select a valid Quote Type
                okl_am_util_pvt.set_message (
                        p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_AM_UNSUPPORTED_QUOTE_TYPE');

                RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;
	-- bug 5480622--start
   	-- ************
	-- Adjust prorated amounts
	-- ************
   IF nvl(p_qtev_rec.partial_yn, 'N') = 'N' then	-- only for full termination
      IF l_tqlv_tbl.COUNT > 0 THEN

		adjust_prorated_amounts (
			p_qtev_rec	=> l_qtev_rec,
			p_asset_tbl	=> l_asset_tbl,
			px_tqlv_tbl	=> l_tqlv_tbl,
			x_return_status	=> l_return_status);

      END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;
   End if;

   -- bug 5480622 -- end
/* rmunjulu SALES_TAX_ENHANCEMENTS move to end after the other quote lines are created
        -- ************
        -- Estimate tax
        -- ************

        IF l_tqlv_tbl.COUNT > 0 THEN

                estimate_tax (
                        p_qtev_rec      => l_qtev_rec,
                        p_asset_tbl     => l_asset_tbl,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        x_return_status => l_return_status);

        END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

*/
        -- *********************************************
        -- Create a line for every asset for performance
        -- *********************************************

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls contract_lines :'||l_return_status);
END IF;

        contract_lines (
                        p_qtev_rec      => l_qtev_rec,
                        p_asset_tbl     => l_asset_tbl,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        x_return_status => l_return_status);

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls contract_lines :'||l_return_status);
END IF;

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
        END IF;

        -- **********************************
        -- Save quote lines into the database
        -- **********************************
    -- rmunjulu Sales_Tax_Enhancements -- Modified to call bulk insert for
    -- termination quotes only.
        IF l_qtev_rec.qtp_code LIKE 'TER_%' THEN
        IF  l_tqlv_tbl.COUNT > 0 THEN

IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls OKL_TQL_PVT.insert_row_bulk :'||l_return_status);
END IF;

        -- PAGARG Bug 4300443 Call bulk insert instead of usual insert
                OKL_TQL_PVT.insert_row_bulk(
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_tqlv_tbl      => l_tqlv_tbl,
                        x_tqlv_tbl      => lx_tqlv_tbl);

IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
     'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls OKL_TQL_PVT.insert_row_bulk :'||l_return_status);
END IF;

                IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

        END IF;
    ELSE -- Non termination quotes use normal insert
        IF  l_tqlv_tbl.COUNT > 0 THEN


    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines :'||l_return_status);
    END IF;

                OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines (
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_tqlv_tbl      => l_tqlv_tbl,
                        x_tqlv_tbl      => lx_tqlv_tbl);

        IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines :'||l_return_status);
    END IF;

                IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

        END IF;
        END IF;

-- rmunjulu SALES_TAX_ENHANCEMENTS moved call to tax calculation to here
-- Tax calculation is not a hard error so proceed with quote creation even if return status is error
        -- ************
        -- Estimate tax
        -- ************

        IF l_tqlv_tbl.COUNT > 0 THEN

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'Before OKL_AM_CALCULATE_QUOTE_PVT.generate calls estimate_tax:'||l_return_status);
    END IF;

                estimate_tax (
                        p_qtev_rec      => l_qtev_rec,
                        p_asset_tbl     => l_asset_tbl,
                        px_tqlv_tbl     => l_tqlv_tbl,
                        x_return_status => l_return_status);

    IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
        'After OKL_AM_CALCULATE_QUOTE_PVT.generate calls estimate_tax:'||l_return_status);
    END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
          END IF;

        END IF;

    -- Tax calculation is not a hard error so proceed with quote creation even if return status is error
    -- So do not set overall status with above l_return_status

        -- **************
        -- Return results
        -- **************

        x_tqlv_tbl      := lx_tqlv_tbl;
        x_return_status := l_overall_status;

        OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);


  IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,'OKL_AM_REMARKET_ASSET_PVT.generate.',
                      'ret status at the end.. '||l_return_status);

   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,'OKL_AM_REMARKET_ASSET_PVT.generate ','End(-)');
   END IF;




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

                IF l_line_csr%ISOPEN THEN
                        CLOSE l_line_csr;
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

END generate;


END OKL_AM_CALCULATE_QUOTE_PVT;

/
