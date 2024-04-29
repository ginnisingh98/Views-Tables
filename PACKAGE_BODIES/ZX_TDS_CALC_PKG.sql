--------------------------------------------------------
--  DDL for Package Body ZX_TDS_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_CALC_PKG" AS
/* $Header: zxdicalctaxspkgb.pls 120.33.12010000.5 2010/02/12 11:44:51 msakalab ship $ */

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_event                CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--   GET_TAX_AMOUNT
--
--  DESCRIPTION
--   This is the main procedure in this package.
--   This procedure is used to calculate tax for for all tax lines
--   belonging to a transaction line (indicated by  p_begin_index and p_end_index)
------------------------------------------------------------------------------

PROCEDURE GET_TAX_AMOUNT (
            p_begin_index          IN     number,
            p_end_index            IN     number,
            p_event_class_rec      IN     ZX_API_PUB.event_class_rec_type,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2)

IS

   l_Tax_Calc_Rule_Flag zx_taxes_b.Tax_Calc_Rule_Flag%type;
   l_def_formula  varchar(30);
   l_formula_code           varchar2(30);
   l_formula_id              number;
   l_counter                 number;
   l_line_amt             number;
   l_discount_amt             number;
   i                         number;
   l_sum_basiscoef               number;
   l_sum_constcoef               number;
   l_tax_id                number;
   l_d_tax_id                number;
   l_zx_result_rec           ZX_PROCESS_RESULTS%ROWTYPE;
   l_perc_discount           number;
   l_adjusted_line_amt   number;
   l_compounding_tax       varchar2(30);
   l_compounding_tax_regime_code       varchar2(30);
   l_Compounding_Type_Code       varchar2(30);
   l_compounding_factor      number;
   l_tax_date               date;

   l_tax_determine_date     date;
   l_tax_rec         ZX_TDS_UTILITIES_PKG.ZX_TAX_INFO_CACHE_REC;

 TYPE tax_amt_tbl_type IS TABLE OF ZX_LINES.TAX_amt%TYPE INDEX BY BINARY_INTEGER;

    tax_amt_tbl tax_amt_tbl_type;

cursor getFormulaInfoD(c_formula_id in number ) is
         select compounding_tax,
                compounding_tax_regime_code,
                Compounding_Type_Code
          from zx_formula_details
        where formula_id = c_formula_id;

/* Bug#5395227 -- use cache structure

cursor getTaxId(c_tax varchar2,
                c_tax_regime_code varchar2) is
        select tax_id from ZX_SCO_TAXES
         where tax = c_tax
           and tax_regime_code = c_tax_regime_code;
*/

cursor getFormulaId(c_formula_code varchar2) is
        select formula_id from ZX_SCO_FORMULA
         where formula_code = c_formula_code;


BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT.BEGIN',
                   'ZX_TDS_CALC_PKG: GET_TAX_AMOUNT (+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
            p_structure_index) IS NOT NULL  THEN

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT.END',
                   'ZX_TDS_CALC_PKG.GET_TAX_AMOUNT (-)'||' skip processing adjustment and credit memo');
    END IF;
    RETURN;
  END IF;

  IF p_begin_index IS NULL OR p_end_index IS NULL THEN
    p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_statement >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT.END',
                   'ZX_TDS_CALC_PKG.GET_TAX_AMOUNT (-)'||' begin index or end index is null');
    END IF;
    RETURN;

  END IF;

  FOR i  IN p_begin_index..p_end_index
  LOOP

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'REFERENCE' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag = 'Y' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).freeze_until_overridden_flag ='Y'
    THEN

        NULL;

    ELSE

    l_formula_code:= NULL;
    l_formula_id:= NULL;
    p_return_status:= FND_API.G_RET_STS_SUCCESS;

    l_tax_id :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id;
    l_tax_date :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_date;

    l_tax_determine_date := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date;

    l_Tax_Calc_Rule_Flag:=
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).Tax_Calc_Rule_Flag;
    l_def_formula:=
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).DEF_TAX_CALC_FORMULA;

   --  Do not calculate taxes for those lines which have last_manual_entry =
   --  'TAX_AMOUNT'. Tax on these lines has been overridden by the user and we
   --  should not change the user overridden amts

   --  Do not calculate taxes for those lines where tax_provider_id is not null
   --  Provider services will calculate taxes for these lines

   --  Do not calculate tax for those lines which are copied from reference
   --  document and which also have Freeze_Until_Overridden_Flag = Y. These are
   --  the manual tax lines on reference document not found applicable on the
   --  current document.

   CASE
    WHEN NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry,'N') = 'TAX_AMOUNT'
    THEN
      NULL;

    -- bug 5531168: call rule engine when other_doc_source is 'REFERENCE'
    WHEN NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).COPIED_FROM_OTHER_DOC_FLAG,'N') <> 'Y' OR
         (NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).COPIED_FROM_OTHER_DOC_FLAG,'N') = 'Y' AND
          NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source, 'X') = 'REFERENCE') OR
         (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'APPLIED_FROM' AND
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag = 'R')
    THEN

      -- If the tax uses tax calculation rules, call rule based engine
      -- to determine tax calculation formula.

      IF l_Tax_Calc_Rule_Flag = 'Y'  THEN

         ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
            'CALCULATE_TAX_AMOUNTS',
            p_structure_name,
            p_structure_index,
            p_event_class_rec,
            l_tax_id,
            NULL,
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date,
            NULL,
            NULL,
            l_zx_result_rec,
            p_return_status,
            p_error_buffer);

        -- If rule based engine is not successful,use the default
        -- tax calculation formula for that tax

        if l_zx_result_rec.alphanumeric_result is not null then
           l_formula_code:= l_zx_result_rec.alphanumeric_result;
            IF (g_level_statement >= g_current_runtime_level ) THEN

              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                             'formula code from rule ' || l_formula_code);
	    END IF;
        else
           l_formula_code:= l_def_formula;
            IF (g_level_statement >= g_current_runtime_level ) THEN

              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                             'default formula code ' || l_formula_code);
	    END IF;
        end if;

         l_formula_id:= l_zx_result_rec.numeric_result;
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).calc_result_id:=
                                   l_zx_result_rec.result_id;
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).legal_message_calc:=
              ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_zx_result_rec.result_id,
                                                           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_date);
      ELSIF l_def_formula is not null and l_def_formula <> 'STANDARD_TC' THEN

         l_formula_code:= l_def_formula;
         IF (g_level_statement >= g_current_runtime_level ) THEN

              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                             'default formula code ' || l_formula_code);
	 END IF;

         open getFormulaId(l_formula_code);
         fetch getFormulaId into l_formula_id;
         close getFormulaId;

      ELSE
         -- The tax calculation formula STANDARD_TC is seeded and in this case,
         -- the tax calculation is done as:  Taxablable amt * Tax Rate
         l_formula_code:= 'STANDARD_TC';


      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_calculation_formula:= l_formula_code;

      IF l_formula_code <> 'STANDARD_TC' AND l_formula_id is not NULL THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                          'Get compounding information...');
        END IF;

         open getFormulaInfoD(l_formula_id);
         loop

            fetch getFormulaInfoD into l_compounding_tax,
                                       l_compounding_tax_regime_code,
                  l_Compounding_Type_Code;

            exit when getFormulaInfoD%notfound;

            -- Bug#5395227- use cache structure
            -- open getTaxId(l_compounding_tax,l_compounding_tax_regime_code);
            --    fetch getTaxId into l_d_tax_id;
            -- close getTaxId;

            -- Bug#5395227- replace getTaxId by the code below
            --
            -- init tax record for each new tax regime and tax
            --
            l_tax_rec  := NULL;
            l_d_tax_id := NULL;

            ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        l_compounding_tax_regime_code,
                        l_compounding_tax,
                        l_tax_determine_date,
                        l_tax_rec,
                        p_return_status,
                        p_error_buffer);

            if p_return_status = FND_API.G_RET_STS_SUCCESS  then
              l_d_tax_id := l_tax_rec.tax_id;
            end if;

            if tax_amt_tbl.exists(l_d_tax_id) then

               if nvl(l_Compounding_Type_Code,'ADD') = 'ADD'  then

                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt:=
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt +
                      tax_amt_tbl(l_d_tax_id);

               else
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt:=
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt -
                      tax_amt_tbl(l_d_tax_id);

               end if;

            else

               p_return_status:= FND_API.G_RET_STS_ERROR;

               IF (g_level_statement >= g_current_runtime_level ) THEN

                 FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                                'Tax amount is not calculated for tax_id ' || l_d_tax_id );
               END IF;

               FND_MESSAGE.SET_NAME('ZX','ZX_COMPND_TAX_NOT_FOUND');
               FND_MESSAGE.SET_TOKEN('TAX',l_compounding_tax);
               FND_MESSAGE.SET_TOKEN('FORMULA_CODE',l_formula_code);

               ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

               ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
               EXIT;
            end if;
         end loop;

         close getFormulaInfoD;

      END IF; -- l_formula_id

    WHEN ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).OTHER_DOC_SOURCE = 'APPLIED_FROM' AND
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag = 'P'
    THEN

--    Proration Scenarios:
--    1. XML Invoices with control total (for all taxes within the document):
--       Wrapper/Applicability process calculates tax amount.
--
--    2. Transaction line with Adjusted to/Applied from information:
--       Tax calculation service calculate the tax amount
--       eg. payables credit memo, adjusted to a payables invoice
--           payables invoice, applied from a prepayment

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_amt <> 0 THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt:=
          NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt,
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_tax_amt *
                     ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_amt /
                            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_amt ));

      ELSE   -- other_doc_line_amt = 0 OR IS NULL
        -- copy unrounded_tax_amt from reference document,
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt :=
          NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt,
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_tax_amt);

      END IF;       -- other_doc_line_amt <> 0

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_amt:= NULL;

   ELSE
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                       'ELSE CASE ' );
      END IF;
      NULL;

   END CASE; -- Delete_Flag ...

--  In other cases such as when formula_code is STANDARD_TC, tax is
--  Taxable_amt multiplied by tax rate, which is already populated
--  into ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl during the taxable basis determination
--  process.

   tax_amt_tbl(l_tax_id):=
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt;


   IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                    ' Unrounded Tax amt for tax ' || l_tax_id || ' is '||
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt);
   END IF;

  END IF;

END LOOP;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT.END',
                  'ZX_TDS_CALC_PKG: GET_TAX_AMOUNT (-)');
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_PKG.GET_TAX_AMOUNT',
                      p_error_buffer);
    END IF;

END GET_TAX_AMOUNT;

END ZX_TDS_CALC_PKG;



/
