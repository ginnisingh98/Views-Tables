--------------------------------------------------------
--  DDL for Package Body ZX_TDS_TAXABLE_BASIS_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_TAXABLE_BASIS_DETM_PKG" AS
/* $Header: zxditxbsisdtpkgb.pls 120.80.12010000.18 2010/03/11 08:57:30 ssohal ship $ */

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_level_error                CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;

PROCEDURE populate_inclusive_tax_flag (
    p_tax_line_index    IN         NUMBER,
    p_event_class_rec   IN         ZX_API_PUB.event_class_rec_type,
    p_structure_name    IN         VARCHAR2,
    p_structure_index   IN         BINARY_INTEGER,
    p_return_status     OUT NOCOPY VARCHAR2,
    p_error_buffer      OUT NOCOPY VARCHAR2);


------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--   get_taxable_basis
--
--  DESCRIPTION
--   This is the main procedure in this package.
--   This procedure is used to calculate taxable basis for for all tax lines
--   belonging to a transaction line (indicated by p_begin_index and p_end_index)
------------------------------------------------------------------------------

PROCEDURE Get_taxable_basis (
            p_begin_index          IN       NUMBER,
            p_end_index            IN       NUMBER,
            p_event_class_rec      IN       ZX_API_PUB.event_class_rec_type,
            p_structure_name       IN       VARCHAR2,
            p_structure_index      IN       BINARY_INTEGER,
            p_return_status        OUT   NOCOPY VARCHAR2,
            p_error_buffer         OUT   NOCOPY VARCHAR2)

IS

   l_Taxable_Basis_Rule_Flag    ZX_TAXES_B.Taxable_Basis_Rule_Flag%type;
   l_def_formula               varchar(30);
   l_formula_from_rate         VARCHAR(30);
   l_formula_code              varchar2(30);
   l_formula_id                number;
   l_line_amt                  number;
   l_discount_amt              number;
--   i                         number;
   l_source                    number;
   l_sum_basiscoef             number;
   l_sum_basiscoef_qua         number;
   l_sum_constcoef             number;
   l_tax_id                    number;
   l_tax_rate_id               zx_rates_b.tax_rate_id%TYPE;
   l_compounding_tax_id        number;
   l_zx_result_rec             ZX_PROCESS_RESULTS%ROWTYPE;
   l_perc_discount             number;
   l_common_comp_base         number;
   l_compounding_tax           varchar2(30);
   l_cpdg_tax_regime_code      varchar2(30);
   l_Compounding_Type_Code          varchar2(30);
   l_compounding_factor        number;
   l_tax_date                  date;
   l_Formula_Type_Code              ZX_FORMULA_B.Formula_Type_Code%type;
   l_Taxable_Basis_Type_Code        ZX_FORMULA_B.Taxable_Basis_Type_Code%type;
   l_base_rate_modifier        ZX_FORMULA_B.base_rate_modifier%type;
   l_Cash_Discount_Appl_Flag    ZX_FORMULA_B.Cash_Discount_Appl_Flag%type;
   l_Volume_Discount_Appl_Flag  ZX_FORMULA_B.Volume_Discount_Appl_Flag%type;
   l_Trading_Discount_Appl_Flag ZX_FORMULA_B.Trading_Discount_Appl_Flag%type;
   l_Transfer_Charge_Appl_Flag  ZX_FORMULA_B.Transfer_Charge_Appl_Flag%type;
   l_TRANS_CHRG_APPL_FLG       ZX_FORMULA_B.Transport_Charge_Appl_Flag%type;
   l_Insurance_Charge_Appl_Flag ZX_FORMULA_B.Insurance_Charge_Appl_Flag%type;
   l_Other_Charge_Appl_Flag     ZX_FORMULA_B.Other_Charge_Appl_Flag%type;
   l_enforce_compounding_flag   ZX_FORMULA_DETAILS.ENFORCE_COMPOUNDING_FLAG%TYPE;

   l_allow_adhoc_tax_rate_flag  VARCHAR2(1);
   l_adj_for_adhoc_amt_code     ZX_RATES_B.ADJ_FOR_ADHOC_AMT_CODE%TYPE;

   l_tax_determine_date         date;
   l_tax_rec                    ZX_TDS_UTILITIES_PKG.ZX_TAX_INFO_CACHE_REC;
   l_tax_rate_rec               ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

TYPE parameter_rec IS RECORD (
     tax_id                 number,
     formula_code           varchar(30),
     incl_indicator              number,
     weird_indicator              number,
     composite_incl_indicator              number,
     base_rate_modifier     number,
     discount               number,
     tax_rate               number,
     tax_amt             number,
     taxable_amt         number,
     compounding_flg        varchar(1),
     compounding_dep_flg    varchar(1),
     basiscoef              number,
     constcoef              number,
     Taxable_Basis_Type_Code        ZX_FORMULA_B.Taxable_Basis_Type_Code%type,
     overrideconst          number );

TYPE parameter_tbl_type IS TABLE OF parameter_rec INDEX BY BINARY_INTEGER;

    parameter_tbl parameter_tbl_type;


 cursor getFormulaInfoH(c_formula_code in varchar2,
                        c_tax_date     in date ) is

       select FORMULA_ID,
              Formula_Type_Code,
              Taxable_Basis_Type_Code,
              BASE_RATE_MODIFIER,
              Cash_Discount_Appl_Flag,
              Volume_Discount_Appl_Flag,
              Trading_Discount_Appl_Flag,
              Transfer_Charge_Appl_Flag,
              Transport_Charge_Appl_Flag,
              Insurance_Charge_Appl_Flag,
              Other_Charge_Appl_Flag
         from ZX_SCO_FORMULA
        where formula_code = c_formula_code
          and effective_from <= c_tax_date
          and ( effective_to >= c_tax_date or
                effective_to is null )
          and Enabled_Flag = 'Y';


 cursor getFormulaInfoD(c_formula_id in number ) is
         select compounding_tax,
                compounding_tax_regime_code,
                Compounding_Type_Code,
                enforce_compounding_flag
          from ZX_FORMULA_DETAILS
        where formula_id = c_formula_id;

/* Bug#5395227 -- use cache structure
 cursor getTaxId(c_tax varchar2,
                c_tax_regime_code varchar2) is
        select tax_id from ZX_SCO_TAXES
         where tax = c_tax
           and tax_regime_code = c_tax_regime_code;
*/

 cursor getAdhocInfo( c_tax_rate_id IN NUMBER) is
        select NVL(ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'), NVL(ALLOW_ADHOC_TAX_RATE_FLAG, 'N')
        from zx_rates_b
        where TAX_RATE_ID = c_tax_rate_id;

 CURSOR get_formula_code_from_rate_csr(
        c_tax_rate_id        zx_rates_b.tax_rate_id%TYPE) IS
 SELECT taxable_basis_formula_code
   FROM zx_rates_b
  WHERE tax_rate_id = c_tax_rate_id;

BEGIN

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.BEGIN',
                  'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (+)');
 END IF;

 p_return_status:= FND_API.G_RET_STS_SUCCESS;

 IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
            p_structure_index) IS NOT NULL  THEN

   IF (g_level_procedure >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                  'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)'||' skip processing for credit memo');
   END IF;
   RETURN;
 END IF;

 l_sum_basiscoef:= 1;
 l_sum_basiscoef_qua:= 0;
 l_sum_constcoef:= 0;

 -- Bug#5520167- get line amt from trx line
 --l_line_amt:= ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_begin_index).line_amt;

 l_line_amt:= ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt( p_structure_index);


 IF p_begin_index is null or p_end_index is null THEN

    p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;   -- 8568734
    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                     'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)'||' Error: begin index or end index is null');
    END IF;
    RETURN;

 END IF;

 For i  IN p_begin_index..p_end_index
 Loop

   IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'REFERENCE' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag = 'Y' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).freeze_until_overridden_flag ='Y'
   THEN

     NULL;

   ELSE


    l_tax_id :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id;
    l_tax_rate_id :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_id;


    l_tax_date :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_date;

    l_tax_determine_date := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date;

    l_Taxable_Basis_Rule_Flag:=
       ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).Taxable_Basis_Rule_Flag;
    l_def_formula:=
       ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).def_taxable_basis_formula;

    -- Do not re-determine tax_amt_included_flag if
    -- bug 5391331: tax_amt_included_flag is overridden
    -- bug 5391084: manual tax line
    --
    -- changed the following condition out for bug 5525890 and bug 5525816
    -- Commented the code for Bug 7438875 to populate inclusive flag even if last_manual_entry is set to TAX_AMOUNT
    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     i).orig_tax_amt_included_flag IS NULL AND
       /*(
          NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     i).last_manual_entry, 'X') <> 'TAX_AMOUNT'
          -- bugfix 5619762
          OR
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_hdr_tx_amt(p_structure_index) is not null
          OR
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_line_tx_amt(p_structure_index) is not null
       ) AND*/
       NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     i).manually_entered_flag, 'N') ='N'
    THEN
      -- populate inclusive_tax_flag by calling populate_inclusive_tax_flag
      --
      populate_inclusive_tax_flag (
                         p_tax_line_index    => i,
                         p_event_class_rec   => p_event_class_rec,
                         p_structure_name    => p_structure_name,
                         p_structure_index   => p_structure_index,
                         p_return_status     => p_return_status,
                         p_error_buffer      => p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement>= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                 'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
        END IF;
        RETURN;
      END IF;
    END IF;

    --  Do not calculate taxes for those lines where tax_provider_id is not null
    --  Provider services will calculate taxes for these lines

    --  Do not calculate tax for those lines which are copied from reference
    --  document and which also have Freeze_Until_Overridden_Flag = Y. These are
    --  the manual tax lines on reference document not found applicable on the
    --  current document. Hiwever, if Freeze_Until_Overridden_Flag is 'Y' and the
    --  tax event type is OVERRIDE, then taxable amount should be calculated.

    --   In case of override, only process those tax lines which need
    --   to be recalculated. i.e.in case of inclusive or compounded taxes only,
    --   we should recalculate all taxes, otherwise only recalculate taxes which
    --   have recalculate_tax_flg ='Y'

   CASE
    WHEN (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).recalc_required_flag <> 'Y' AND
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX') OR
         (NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry, 'X') = 'TAX_AMOUNT') OR
          (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'APPLIED_FROM' AND
           ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag = 'P')
    THEN

      --  RECALC_REQUIRED_FLAG will be populated by tax lines Determination
      --  table handler when the user overrides one or more tax lines. (When the
      --  line being overridden is inclusive or used to compound other taxes,
      --  then this flag will be set to 'Y' for all the tax lines belonging to
      --  the current transaction line)  If the value of RACALC_REQUIRED_FLAG = 'N'
      --  then skip the process and only perform population of relevant Tax Rate
      --  Determination columns into detail tax lines structure.

      -- NULL;

      -- Bug 3560223: populate parameter_tbl for compounding tax and
      -- inclusive tax
      --
      parameter_tbl(l_tax_id).tax_id := l_tax_id;
      parameter_tbl(l_tax_id).tax_rate :=
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate;
      parameter_tbl(l_tax_id).formula_code :=
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).taxable_basis_formula;

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_amt_included_flag = 'S'
      THEN
          parameter_tbl(l_tax_id).weird_indicator:= 1;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                  i).tax_amt_included_flag := 'Y';
      ELSE
          parameter_tbl(l_tax_id).weird_indicator:= 0;
      END IF;

      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
                                                p_structure_index) = 'I' OR
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                  i).tax_amt_included_flag = 'Y'
      THEN
          parameter_tbl(l_tax_id).incl_indicator:= 1;
      ELSE
          parameter_tbl(l_tax_id).incl_indicator:= 0;
      END IF;


      parameter_tbl(l_tax_id).composite_incl_indicator :=
                                parameter_tbl(l_tax_id).incl_indicator -
                                        parameter_tbl(l_tax_id).weird_indicator;

      parameter_tbl(l_tax_id).basiscoef:= 0;
      parameter_tbl(l_tax_id).constcoef:= 0;
      parameter_tbl(l_tax_id).overrideconst:=
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt;

      -- l_sum_basiscoef:= l_sum_basiscoef + parameter_tbl(l_tax_id).composite_incl_indicator *
      --                  parameter_tbl(l_tax_id).basiscoef * parameter_tbl(l_tax_id).tax_rate / 100;

      l_sum_constcoef:= l_sum_constcoef + parameter_tbl(l_tax_id).composite_incl_indicator *
                        parameter_tbl(l_tax_id).constcoef * parameter_tbl(l_tax_id).tax_rate /100
                      + parameter_tbl(l_tax_id).composite_incl_indicator *
                        parameter_tbl(l_tax_id).overrideconst;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                       ' sum_basiscoef: ' || l_sum_basiscoef||
                       ' sum_constcoef: ' || l_sum_constcoef);
      END IF;

    WHEN  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_provider_id is NOT NULL OR
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Delete_Flag = 'Y'
    THEN

      -- Do not perform taxable basis determination for provider calculated lines. Taxes
      -- calculated by providers cannot be compounded by taxes calculated by eTax and
      -- vice versa. Also, do not process tax lines which are marked for deletion.

      NULL;

    WHEN
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).OTHER_DOC_SOURCE ='ADJUSTED' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code <> 'OVERRIDE_TAX'
    THEN
       -- In case when the tax line is copied from 'Applied From' or 'Adjusted' Document,
       -- Applicability process will copy Tax Regime, Tax, Status, Rate, Place of Supply,
       -- Reg. Number, Offset tax columns  from original document. in this case,
       -- taxable amount will be a proration and no need to calculate multipliers for
       -- this tax line.

       NULL;

    --WHEN
    --  (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX' AND
    --   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry = 'TAX_AMOUNT')
    --THEN

      --  In case of an override event on tax line, where the user has overridden tax amount,
      --  we need not calculate multiplier for that tax line, the taxable amount will be
      --  computed as tax amount / tax rate in the next loop.

      --NULL;

    WHEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).COPIED_FROM_OTHER_DOC_FLAG = 'Y' AND
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Manually_Entered_Flag = 'Y' AND
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).OTHER_DOC_SOURCE = 'REFERENCE'
    THEN
      -- When a manual tax line is copied from reference document, the Tax Regime, Tax, Status, Rate,
      -- and other columns are copied from manual tax line in reference document as well. in this
      -- case, the taxable amount will be computed as a percentage of taxable amount on reference
      -- document. So no need to calculate multiplier for that tax line.

      -- Condition Other_Doc_Source = 'REFERENCE' added as a fix of bug#6891479

      NULL;
    /* comment out for bug fix 3391186
    WHEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag = 'Y' AND
         ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Overridden_Flag <> 'Y'
           OR
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).COPIED_FROM_OTHER_DOC_FLAG = 'Y' )
    THEN
    */
    WHEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag = 'Y' AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Overridden_Flag <> 'Y'
    THEN
       -- When the transaction is matched to a reference document, and if a tax
       -- that was applicable on the reference document is not found applicable
       -- during applicability process, the tax line from the reference document
       -- is copied, but the tax rate, status, amounts are populated as zero,
       -- until the user views that tax line and overrides it. So skip taxable basis determination
       -- in this case.

       NULL;

   WHEN
     (NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag,'N') <> 'Y' OR
      NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).COPIED_FROM_OTHER_DOC_FLAG,'N') <> 'Y')  OR
      (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'APPLIED_FROM' AND
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag = 'R')                   OR
      (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX' AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Recalc_Required_Flag = 'Y'           AND
       -- bug fix 5525890
       NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry,'X') <> 'TAX_AMOUNT' )
   THEN

    -- Initialize compounding_dep_tax_flag and compounding_tax_miss_flag
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).compounding_dep_tax_flag := 'N';
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).compounding_tax_miss_flag := 'N';

       --   In case of manual tax lines or override with last manual entry
       --   of tax_amount, calculate the taxable amount based on tax amount
       --   and line amount and not using the evaluation loop.

       --   In case of copied from reference document, prorate the taxable
       --   amount based on the other_doc_tax_amt and other_doc_line_amt

       --   hence the above cases are excluded from this loop

     IF nvl(l_Taxable_Basis_Rule_Flag,'N') = 'Y'  THEN

       ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
            'DET_TAXABLE_BASIS',
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

        if l_zx_result_rec.alphanumeric_result is not null then
          l_formula_code:= l_zx_result_rec.alphanumeric_result;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                          'Get Formula code from rule_base_process '|| l_formula_code);
          END IF;

        else
          /* use cache
          OPEN get_formula_code_from_rate_csr(l_tax_rate_id);
          FETCH get_formula_code_from_rate_csr INTO l_formula_from_rate;
          CLOSE get_formula_code_from_rate_csr;
          */

          ZX_TDS_UTILITIES_PKG.get_tax_rate_info (
                         p_tax_rate_id  => l_tax_rate_id,
                         p_tax_rate_rec  => l_tax_rate_rec,
                         p_return_status  => p_return_status,
                         p_error_buffer   => p_error_buffer);

          l_formula_from_rate := l_tax_rate_rec.taxable_basis_formula_code;

          IF l_formula_from_rate IS NOT NULL THEN
            l_formula_code:= l_formula_from_rate;
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                            'Get Formula code from tax rate '||l_formula_code);
            END IF;
          ELSE
            l_formula_code:= l_def_formula;
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                            'Get Default Formula code from tax '||l_formula_code);
            END IF;
          END IF;
        end if;

        l_formula_id:= l_zx_result_rec.numeric_result;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).basis_result_id:= l_zx_result_rec.result_id;

     ELSE

       /* use cache
       OPEN get_formula_code_from_rate_csr(l_tax_rate_id);
       FETCH get_formula_code_from_rate_csr INTO l_formula_from_rate;
       CLOSE get_formula_code_from_rate_csr;
       */

        ZX_TDS_UTILITIES_PKG.get_tax_rate_info (
                         p_tax_rate_id  => l_tax_rate_id,
                         p_tax_rate_rec  => l_tax_rate_rec,
                         p_return_status  => p_return_status,
                         p_error_buffer   => p_error_buffer);

        l_formula_from_rate := l_tax_rate_rec.taxable_basis_formula_code;



       IF l_formula_from_rate IS NOT NULL THEN
         l_formula_code := l_formula_from_rate;
         IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                         'Get Formula code from tax rate '|| l_formula_code);
         END IF;
       ELSE
         l_formula_code:= l_def_formula;
         IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                         'Get Default Formula code from tax '|| l_formula_code);
         END IF;
       END IF;
     END IF;


     --bug8517610
     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'APPLIED_FROM'
     AND l_formula_code IS NULL THEN
        l_formula_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).taxable_basis_formula;
     END IF;

     IF l_formula_code IS NULL THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (g_level_error >= g_current_runtime_level ) THEN

         FND_LOG.STRING(g_level_error ,
                'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)'||' error: can not determine formula code');
       END IF;
       RETURN;
     END IF;

     parameter_tbl(l_tax_id).tax_id:= l_tax_id;
     parameter_tbl(l_tax_id).tax_rate:= ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate;
     parameter_tbl(l_tax_id).formula_code:= l_formula_code;


     --   This is the end of getting formula code

     if  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Tax_Amt_Included_Flag = 'S' then
         parameter_tbl(l_tax_id).weird_indicator:= 1;
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                  i).tax_amt_included_flag := 'Y';
     else
         parameter_tbl(l_tax_id).weird_indicator:= 0;
     end if;

     IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
                                                      p_structure_index) = 'I' OR
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                i).tax_amt_included_flag = 'Y'
     THEN
         parameter_tbl(l_tax_id).incl_indicator:= 1;
     ELSE
         parameter_tbl(l_tax_id).incl_indicator:= 0;
     END IF;

     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                      'parameter_tbl( ' || l_tax_id || ' ).incl_indicator:= ' ||
                       parameter_tbl(l_tax_id).incl_indicator||
                      'weird_indicator:= ' ||
                       parameter_tbl(l_tax_id).weird_indicator);
     END IF;

    parameter_tbl(l_tax_id).composite_incl_indicator:= parameter_tbl(l_tax_id).incl_indicator -
                             parameter_tbl(l_tax_id).weird_indicator;


     parameter_tbl(l_tax_id).basiscoef:= 1;
     parameter_tbl(l_tax_id).constcoef:= 0;
     parameter_tbl(l_tax_id).overrideconst:= 0;

     IF l_formula_code IN ('STANDARD_TB', 'STANDARD_QUANTITY') THEN

       -- When formula code is STANDARD_TB, the rate type should be PERCENT.
       -- When formula code is STANDARD_QUANTITY, the rate type should be QUANTITY. Otherwise
       -- multiplying taxable basis by tax rate will give incorrect result.
       IF ( l_formula_code = 'STANDARD_TB' AND
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_type <> 'PERCENTAGE'  )
         -- add following condition for bug fix 5481559
         OR ( l_formula_code = 'STANDARD_QUANTITY' AND
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_type <> 'QUANTITY' )
       THEN

          p_return_status:= FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('ZX','ZX_RATE_FORMULA_MISMATCH');
          FND_MESSAGE.SET_TOKEN('RATE_TYPE',
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_type);
          FND_MESSAGE.SET_TOKEN('TAX',ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax );
          FND_MESSAGE.SET_TOKEN('TAXABLE_BASIS_TYPE', NVL(l_Taxable_Basis_Type_Code, 'PERCENTAGE') );
          FND_MESSAGE.SET_TOKEN('FORMULA_CODE', l_formula_code );

          -- FND_MSG_PUB.Add;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

          ZX_API_PUB.add_msg(
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

          IF (g_level_error >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_error ,
                      'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                      'Taxable basis type and tax Rate Type do not match ');
               FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                      'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
          END IF;

          RETURN;

       END IF;

       -- When formula code is STANDARD_TB then no discounts or charges are
       -- applicable. Base rate modifier is set to 1
       parameter_tbl(l_tax_id).discount:= 0;
       parameter_tbl(l_tax_id).base_rate_modifier:= 1;

--       if ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry = 'TAX_AMOUNT'
--          and ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX' then
--
--          -- This is a case where user has overridden tax amt on the tax engine
--          -- calculated tax. Hence do not apply taxable basis formula again, but
--          -- only set the overrideconst to overriddne tax amt.
--          parameter_tbl(l_tax_id).basiscoef:= 0;
--          parameter_tbl(l_tax_id).constcoef:= 0;
--          parameter_tbl(l_tax_id).overrideconst:=
--                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt;
--
--       else
--          parameter_tbl(l_tax_id).basiscoef:= 1;
--          parameter_tbl(l_tax_id).constcoef:= 0;
--          parameter_tbl(l_tax_id).overrideconst:= 0;
--       end if;

     ELSIF   l_formula_code <> 'STANDARD_QUANTITY' THEN

       open getFormulaInfoH(l_formula_code,l_tax_date);
       fetch getFormulaInfoH
            into l_FORMULA_ID,
                 l_Formula_Type_Code,
                 l_Taxable_Basis_Type_Code,
                 l_BASE_RATE_MODIFIER,
                 l_Cash_Discount_Appl_Flag,
                 l_Volume_Discount_Appl_Flag,
                 l_Trading_Discount_Appl_Flag,
                 l_Transfer_Charge_Appl_Flag,
                 L_TRANS_CHRG_APPL_FLG,
                 l_Insurance_Charge_Appl_Flag,
                 l_Other_Charge_Appl_Flag;

       if getFormulaInfoH%notfound then

          p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;  -- 8568734
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                           'Formula Info not found for formula code ' || l_formula_code );
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                           'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
          END IF;

       end if;

       close getFormulaInfoH;

       IF (g_level_statement >= g_current_runtime_level ) THEN

         FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                        'Taxable Basis Type: '|| l_Taxable_Basis_Type_Code||' base rate modifier: '||l_BASE_RATE_MODIFIER||
			'Cash_Discount_Appl_Flag: '||l_Cash_Discount_Appl_Flag||' Volume_Discount_Appl_Flag: '||l_Volume_Discount_Appl_Flag||
			' Trading_Discount_Appl_Flag: '||l_Trading_Discount_Appl_Flag||' Transfer_Charge_Appl_Flag: '||
                        l_Transfer_Charge_Appl_Flag||' TRANS_CHRG_APPL_FLG: '||L_TRANS_CHRG_APPL_FLG||
                        ' Insurance_Charge_Appl_Flag: '||l_Insurance_Charge_Appl_Flag||' Other_Charge_Appl_Flag: '||l_Other_Charge_Appl_Flag);
       END IF;


       parameter_tbl(l_tax_id).base_rate_modifier := 1 + nvl(l_BASE_RATE_MODIFIER,0)/100;
       parameter_tbl(l_tax_id).Taxable_Basis_Type_Code := upper(l_Taxable_Basis_Type_Code);

       if parameter_tbl(l_tax_id).Taxable_Basis_Type_Code <> 'ASSESSABLE_VALUE' then

       -- When Taxable Basis Type is not QUANTITY but the rate type is QUANTITY
       -- then error should be raised, otherwise the tax calculation result will be incorrect.
       IF ( parameter_tbl(l_tax_id).Taxable_Basis_Type_Code <> 'QUANTITY' AND
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_type = 'QUANTITY')
           OR
          ( parameter_tbl(l_tax_id).Taxable_Basis_Type_Code = 'QUANTITY' AND
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_type <> 'QUANTITY')
       THEN

          p_return_status:= FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('ZX','ZX_RATE_FORMULA_MISMATCH');
          FND_MESSAGE.SET_TOKEN('RATE_TYPE',
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_type);
          FND_MESSAGE.SET_TOKEN('TAX',ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax );
          FND_MESSAGE.SET_TOKEN('TAXABLE_BASIS_TYPE', parameter_tbl(l_tax_id).Taxable_Basis_Type_Code);
          FND_MESSAGE.SET_TOKEN('FORMULA_CODE', l_formula_code );

          -- FND_MSG_PUB.Add;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

          ZX_API_PUB.add_msg(
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

          IF (g_level_error >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_error ,
                      'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                      'Taxable basis type for Formula Code '||l_formula_code||
                      ' and tax Rate Type QUANTITY do not match ');
               FND_LOG.STRING(g_level_error ,
                      'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                      'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
          END IF;
          RETURN;

       END IF;


       if parameter_tbl(l_tax_id).Taxable_Basis_Type_Code = 'PRIOR_TAX' then

           parameter_tbl(l_tax_id).base_rate_modifier := 0;

       end if;

       l_discount_amt:= 0;


       if  l_Cash_Discount_Appl_Flag  = 'Y' then
           l_discount_amt:= l_discount_amt -
             ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.cash_discount(p_structure_index));

       end if;

       if  l_Volume_Discount_Appl_Flag  = 'Y' then
           l_discount_amt:= l_discount_amt -
              ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.volume_discount(p_structure_index));

       end if;

       if  l_Trading_Discount_Appl_Flag  = 'Y' then
           l_discount_amt:= l_discount_amt -
              ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trading_discount(p_structure_index));

       end if;


       if  l_Transfer_Charge_Appl_Flag  = 'Y' then
           l_discount_amt:= l_discount_amt +
             ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.transfer_charge(p_structure_index));

       end if;


       if  L_TRANS_CHRG_APPL_FLG  = 'Y' then
           l_discount_amt:= l_discount_amt +
             ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.transportation_charge(p_structure_index));

       end if;


       if  l_Insurance_Charge_Appl_Flag  = 'Y' then
           l_discount_amt:= l_discount_amt +
             ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.insurance_charge(p_structure_index));

       end if;

       if  l_Other_Charge_Appl_Flag  = 'Y' then
           l_discount_amt:= l_discount_amt +
             ABS(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.other_charge(p_structure_index));

       end if;

       IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                        'Total discount or charge: '||
                         nvl(l_discount_amt,0));
       END IF;

       parameter_tbl(l_tax_id).discount:= nvl(l_discount_amt,0);

--     end of discount / charge


--       if ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry = 'TAX_AMOUNT'
--          and ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX' then

--          -- This is a case where user has overridden tax amt on the tax engine
--          -- calculated tax. Hence do not apply taxable basis formula again, but
--          -- only set the overrideconst to overridden tax amt.
--          parameter_tbl(l_tax_id).basiscoef:= 0;
--          parameter_tbl(l_tax_id).constcoef:= 0;
--          parameter_tbl(l_tax_id).overrideconst:=
--                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt;

--       else

          parameter_tbl(l_tax_id).basiscoef:=
                parameter_tbl(l_tax_id).base_rate_modifier;

          parameter_tbl(l_tax_id).constcoef:=
                parameter_tbl(l_tax_id).discount;

          parameter_tbl(l_tax_id).overrideconst:= 0;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                           'basiscoef: ' ||parameter_tbl(l_tax_id).basiscoef ||' constcoef: ' ||
                            parameter_tbl(l_tax_id).constcoef);
          END IF;

          if l_formula_id is null then
              p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error ,
                               'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                               'l_formula_id is null ');
                FND_LOG.STRING(g_level_error ,
                               'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                               'p_return_status is ' || p_return_status);
                FND_LOG.STRING(g_level_error ,
                              'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                              'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
              END IF;
              RETURN;
          end if;

          open getFormulaInfoD(l_formula_id);
          fetch getFormulaInfoD into l_compounding_tax,l_cpdg_tax_regime_code,
                                     l_Compounding_Type_Code, l_enforce_compounding_flag;

          while getFormulaInfoD%found loop

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                             ' Compounding tax: ' || l_compounding_tax||
                             ' Compounding tax regime code: ' || l_cpdg_tax_regime_code||
                             ' Compounding tax type: ' || l_Compounding_Type_Code);
            END IF;

            -- set the compounding_dep_tax_flag here
            parameter_tbl(l_tax_id).compounding_dep_flg:= 'Y';

            -- Bug#5395227- use cache structure
            -- open getTaxId(l_compounding_tax, l_cpdg_tax_regime_code);
            -- fetch getTaxId into l_compounding_tax_id;

            -- Bug#5395227- replace getTaxId by the code below
            --
            -- init tax record for each new tax regime and tax
            --
            l_tax_rec            := NULL;
            l_compounding_tax_id := NULL;

            ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        l_cpdg_tax_regime_code,
                        l_compounding_tax,
                        l_tax_determine_date,
                        l_tax_rec,
                        p_return_status,
                        p_error_buffer);

            if p_return_status = FND_API.G_RET_STS_SUCCESS  then
              l_compounding_tax_id := l_tax_rec.tax_id;
            end if;

            -- if getTaxID%notfound then
            if l_compounding_tax_id IS NULL then
               p_return_status:= FND_API.G_RET_STS_ERROR;

               -- bug 8568734
               FND_MESSAGE.SET_NAME('ZX','ZX_COMPND_TAX_NOT_FOUND');
               FND_MESSAGE.SET_TOKEN('TAX',l_compounding_tax);
               FND_MESSAGE.SET_TOKEN('FORMULA_CODE',l_formula_code);
               FND_MESSAGE.SET_TOKEN('TRANSACTION_DATE',
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date);

               ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

               ZX_API_PUB.add_msg(
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


               IF (g_level_error >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_error ,
                                'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                                ' Compounding tax id does not exist');
                 FND_LOG.STRING(g_level_error ,
                                'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                                'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
               END IF;
               RETURN;
            end if;

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                             ' Compounding tax id is ' || l_compounding_tax_id);
            END IF;
            -- close getTaxId;

            IF parameter_tbl.exists(l_compounding_tax_id) THEN

               if l_Compounding_Type_Code = 'ADD'  then
                  l_compounding_factor:= 1;
               else
                  l_compounding_factor:= -1;
               end if;

           /* Bug 8512848 - Adding the following condition for Quantity Based Taxes */
	        IF parameter_tbl(l_compounding_tax_id).formula_code = 'STANDARD_QUANTITY'
          AND l_line_amt <> 0 THEN -- Bug8840197
		         FOR j IN p_begin_index..p_end_index LOOP
			           IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(j).tax_id = to_char(l_compounding_tax_id) THEN
				            l_source := j;
				         EXIT;
			           END IF;
		          END LOOP;

              parameter_tbl(l_tax_id).basiscoef:= parameter_tbl(l_tax_id).basiscoef +
                          parameter_tbl(l_compounding_tax_id).basiscoef *
		              (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_source).trx_line_quantity*
			            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_source).tax_rate / l_line_amt) * l_compounding_factor;

              parameter_tbl(l_tax_id).constcoef:= parameter_tbl(l_tax_id).constcoef +
			                   parameter_tbl(l_compounding_tax_id).constcoef *
			            (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_source).trx_line_quantity*
			            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_source).tax_rate / l_line_amt) * l_compounding_factor +
			            parameter_tbl(l_compounding_tax_id).overrideconst * l_compounding_factor;
               ELSE
  parameter_tbl(l_tax_id).basiscoef:= parameter_tbl(l_tax_id).basiscoef +
	   		        parameter_tbl(l_compounding_tax_id).basiscoef *
			           (parameter_tbl(l_compounding_tax_id).tax_rate /100) * l_compounding_factor;

		         parameter_tbl(l_tax_id).constcoef:= parameter_tbl(l_tax_id).constcoef +
			                                 parameter_tbl(l_compounding_tax_id).constcoef *
			                                 (parameter_tbl(l_compounding_tax_id).tax_rate/100) * l_compounding_factor +
			                                  parameter_tbl(l_compounding_tax_id).overrideconst * l_compounding_factor;
               END IF;
	     /* Bug 8512848 - End of Modification */

      /* Original Code Commented out bug 8512848 */
              /* parameter_tbl(l_tax_id).basiscoef:= parameter_tbl(l_tax_id).basiscoef +
                 parameter_tbl(l_compounding_tax_id).basiscoef *
                 (parameter_tbl(l_compounding_tax_id).tax_rate /100) * l_compounding_factor;

               parameter_tbl(l_tax_id).constcoef:= parameter_tbl(l_tax_id).constcoef +
                 parameter_tbl(l_compounding_tax_id).constcoef *
                 (parameter_tbl(l_compounding_tax_id).tax_rate/100) * l_compounding_factor +
                 parameter_tbl(l_compounding_tax_id).overrideconst * l_compounding_factor; */

               parameter_tbl(l_compounding_tax_id).compounding_flg:= 'Y';

            ELSE  --l_compounding_tax_id not exists

               -- bug fix 3282007: add the following IF condition handling.
               IF l_enforce_compounding_flag = 'Y' THEN

                 p_return_status:= FND_API.G_RET_STS_ERROR;

                 FND_MESSAGE.SET_NAME('ZX','ZX_COMPND_TAX_NOT_FOUND');
                 FND_MESSAGE.SET_TOKEN('TAX',l_compounding_tax);
                 FND_MESSAGE.SET_TOKEN('FORMULA_CODE',l_formula_code);
                 FND_MESSAGE.SET_TOKEN('TRANSACTION_DATE',
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date);
                 -- FND_MSG_PUB.Add;
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

                 ZX_API_PUB.add_msg(
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

                 IF (g_level_error >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_error,
                                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                                  'Either Tax ' || l_compounding_tax_id ||
                                  ' is not applicable or compounding precedence is wrong');
                   FND_LOG.STRING(g_level_error,
                                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis.END',
                                  'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
                 END IF;

                 RETURN;
               ELSE
                 -- bug 3644541: set compounding_tax_miss_flag
                 --
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            i).compounding_tax_miss_flag := 'Y';
               END IF;

            END IF; -- parameter_tbl.exists

            fetch getFormulaInfoD into l_compounding_tax,l_cpdg_tax_regime_code,
                                       l_Compounding_Type_Code, l_enforce_compounding_flag;
         end loop;

         close getFormulaInfoD;

--       end if;   -- last manual entry

       end if;	-- taxable basis type code

     END IF; -- l_formula_code

       IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                        'Composite Indicator: '|| parameter_tbl(l_tax_id).composite_incl_indicator||
                        ' sum_basiscoef: ' || l_sum_basiscoef ||
                        ' sum_basiscoef_qua: ' || l_sum_basiscoef_qua);
       END IF;

       IF parameter_tbl(l_tax_id).formula_code = 'STANDARD_QUANTITY'
          AND l_line_amt <> 0 THEN
          l_sum_basiscoef_qua:= l_sum_basiscoef_qua +
                                  (parameter_tbl(l_tax_id).composite_incl_indicator
                                       * parameter_tbl(l_tax_id).basiscoef
                                       * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_quantity
                                       * parameter_tbl(l_tax_id).tax_rate
                                   );
          l_sum_constcoef:= l_sum_constcoef + parameter_tbl(l_tax_id).composite_incl_indicator *
                         parameter_tbl(l_tax_id).constcoef *
                         (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_quantity
                              * parameter_tbl(l_tax_id).tax_rate / l_line_amt)
                       + parameter_tbl(l_tax_id).composite_incl_indicator *
                         parameter_tbl(l_tax_id).overrideconst;
       ELSE
       	  l_sum_basiscoef:= l_sum_basiscoef + parameter_tbl(l_tax_id).composite_incl_indicator *
                         parameter_tbl(l_tax_id).basiscoef * parameter_tbl(l_tax_id).tax_rate / 100;

          l_sum_constcoef:= l_sum_constcoef + parameter_tbl(l_tax_id).composite_incl_indicator *
                         parameter_tbl(l_tax_id).constcoef * parameter_tbl(l_tax_id).tax_rate /100
                       + parameter_tbl(l_tax_id).composite_incl_indicator *
                         parameter_tbl(l_tax_id).overrideconst;
       END IF;

       IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                        ' sum_basiscoef: ' || l_sum_basiscoef||
                        ' sum_constcoef: ' || l_sum_constcoef);
       END IF;

   ELSE  -- default case

      NULL;

   END CASE;  -- Delete_Flag

   IF p_return_status IN ( FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
       EXIT;
   END IF;
   END IF;

 END LOOP;

 IF (g_level_statement >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                  ' ');
 END IF;

 IF nvl(p_return_status, 'SUCCESS') <> FND_API.G_RET_STS_ERROR THEN
 IF l_line_amt - l_sum_basiscoef_qua <> 0 THEN
   l_common_comp_base := round((l_line_amt - l_sum_constcoef)
                                 / (l_sum_basiscoef *
                                      (1 + l_sum_basiscoef_qua
                                             / (l_line_amt - l_sum_basiscoef_qua)
                                      )
                                   ),20
                            );
 ELSE
   l_common_comp_base := 0;
 END IF;

 IF (g_level_statement >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                  'l_sum_basiscoef is ' || l_sum_basiscoef || 'Qua: '|| l_sum_basiscoef_qua);
   FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                  'l_sum_constcoef is ' || l_sum_constcoef);
   FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                  'l_common_comp_base is ' || l_common_comp_base);

 --This complete the building of multipliers. Now update columns

   FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                  'update columns');
 END IF;

 for i in p_begin_index..p_end_index loop

    l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id;


  -- Update the columns only for those lines which were not marked for
  -- deletion and which were not marked for claculation by providers
  -- and which are not manual tax lines copied from reference document.

  -- Even if Freeze_Until_Overridden_Flag is 'Y', if the tax event type is
  -- OVERRIDE, then taxable amount should be calculated.

  CASE
    WHEN  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_provider_id is NOT NULL OR
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Delete_Flag = 'Y'
    THEN

      NULL;

   WHEN  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).OTHER_DOC_SOURCE = 'APPLIED_FROM' AND
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag = 'P' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code <> 'OVERRIDE_TAX'
   THEN
     --  Proration Scenarios:
     --  In the following cases, taxable basis is not calculated using taxable
     --  basis formula, but proration is done based on reference / applied from
     --  adjusted to docs.

     --  1. XML Invoices with control total (for all taxes within the document):
     --     taxable basis determination prorates the taxable amount.
     --     This case is open and not yet finalized
     --
     --  2. Transaction line with Adjusted to/Applied from information:
     --     Taxable basis Determination proartes the taxable amount
     --     eg. payables credit memo, adjusted to a payables invoice
     --         payables invoice, applied from a prepayment
     --
     --  3. Imported summary tax lines with allocation link structure
     --     Taxable basis determination prorates the taxable amount
     --     (should we have tax event type called IMPORT to identify this ?
     --
     --  4. Tax amount overridden in the summary tax line through the User Interface
     --     Taxable basis determination calcuates the taxable amount as
     --         tax amount / tax rate

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_amt <> 0 THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt:=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_taxable_amt *
                     ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_amt /
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_amt );

      ELSE   -- other_doc_line_amt = 0 OR IS NULL
        -- copy unrounded_taxable_amt from reference document,
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt :=
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_line_taxable_amt;

      END IF;       -- other_doc_line_amt <> 0


   WHEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag = 'Y' AND
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Overridden_Flag <> 'Y'
   THEN
        -- Taxable amounts should have been set to zero in applicability process.
        -- hence no processing required here.

        NULL;
   WHEN nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Delete_Flag,'N') <> 'Y' AND
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_provider_id is NULL    AND
       (nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag,'N') <> 'Y' OR
         nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).COPIED_FROM_OTHER_DOC_FLAG,'N') <> 'Y')  OR
        (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Recalc_Required_Flag = 'Y') THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).taxable_basis_formula:=
                                                                 parameter_tbl(l_tax_id).formula_code;

    IF parameter_tbl(l_tax_id).formula_code = 'STANDARD_QUANTITY'  THEN
    -- For quantity based taxes, the calculation is not performed using
    -- the regular calculation cycle. Hence calculate the taxable amt
    -- and tax amt for quantity based taxes.
    -- For quantity based taxes, taxable amt is set equal to quantity
    -- although the field name indicates it is amt.

      	parameter_tbl(l_tax_id).taxable_amt:=
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_quantity;

        parameter_tbl(l_tax_id).tax_amt:=  parameter_tbl(l_tax_id).taxable_amt *
                         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate;--Bug 5185614

    ELSIF parameter_tbl(l_tax_id).Taxable_Basis_Type_Code = 'ASSESSABLE_VALUE' then
    -- For ASSESSABLE_VALUE formula, the taxable amt is the line assessable value.
      	parameter_tbl(l_tax_id).taxable_amt:=
            nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_assessable_value,
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_amt);

        parameter_tbl(l_tax_id).tax_amt:=  parameter_tbl(l_tax_id).taxable_amt *
                         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate / 100;

    ELSE

      parameter_tbl(l_tax_id).taxable_amt:= l_common_comp_base *
                    parameter_tbl(l_tax_id).basiscoef
                 +  parameter_tbl(l_tax_id).constcoef;


      parameter_tbl(l_tax_id).tax_amt:=  parameter_tbl(l_tax_id).taxable_amt *
                    parameter_tbl(l_tax_id).tax_rate/100
                 +  parameter_tbl(l_tax_id).overrideconst;

    END IF;

    if ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry is null OR
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry <> 'TAX_AMOUNT' then

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt:= parameter_tbl(l_tax_id).taxable_amt;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt:=
                parameter_tbl(l_tax_id).tax_amt;

    elsif ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry = 'TAX_AMOUNT' THEN
      -- bug 5237144:
      --  and ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX' then

       /* use cache
        OPEN getAdhocInfo(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_id);
        FETCH getAdhocInfo into l_adj_for_adhoc_amt_code, l_allow_adhoc_tax_rate_flag;
        IF getAdhocInfo%NOTFOUND THEN
          close getAdhocInfo;
          p_return_status := FND_API.G_RET_STS_ERROR;
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                   'No Data Found for tax_rate_code: '||
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code ||
                   ' tax_rate_id: ' ||
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_id  );
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis.END',
                   'ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis (-)');
          END IF;
          RETURN;
        END IF;
        CLOSE getAdhocInfo;
        */

        ZX_TDS_UTILITIES_PKG.get_tax_rate_info (
                         p_tax_rate_id  => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_id,
                         p_tax_rate_rec  => l_tax_rate_rec,
                         p_return_status  => p_return_status,
                         p_error_buffer   => p_error_buffer);


        -- bug#7344499- return error to user when rate is not found

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- no rate found for the specify tax_rate_id
          RETURN;
        END IF;

		  l_adj_for_adhoc_amt_code := nvl(l_tax_rate_rec.adj_for_adhoc_amt_code,'TAXABLE_BASIS');
          l_allow_adhoc_tax_rate_flag := nvl(l_tax_rate_rec.Allow_Adhoc_Tax_Rate_Flag,'N');

        IF l_allow_adhoc_tax_rate_flag = 'N' OR
           (l_allow_adhoc_tax_rate_flag = 'Y' AND l_adj_for_adhoc_amt_code = 'TAXABLE_BASIS') OR
           NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag, 'N') = 'Y'
        THEN
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate <> 0 THEN
            IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).orig_taxable_amt IS NULL THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).orig_taxable_amt :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).taxable_amt;
            END IF;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt:=
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt /
			           --Start Bug 7310806
				   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate * 100;
                                   --parameter_tbl(l_tax_id).tax_rate * 100;
				   --End Bug 7310806

           -- ensuring that PRORATED_TB is not set for overriden tax lines.
           IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).overridden_flag,'N') = 'N'
              OR NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag,'N') = 'Y' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).taxable_basis_formula:= 'PRORATED_TB';
           END IF;

          ELSE

            -- when tax_rate = 0, unrounded_tax_amt = 0, do nothing.
            -- Error out when Tax_rate = 0, unrounded_tax_amt <> 0.
            -- Condition added for Bug#9436262
            -- skip validation for historical_flag = 'Y', manually_entered_flag = 'Y'
            IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt <> 0
               AND NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).historical_flag,'N') = 'Y'
               AND NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag,'N') = 'Y' THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis',
                       'Tax_Rate = 0, Unrounded_tax_amt <> 0, Historical_Flag = Y, '||
                       'Manually_entered_flag = Y. Skip Validation.');
              END IF;
            ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt <> 0 THEN
              p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;   -- 8568734
              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis',
                       'adj_for_adhoc_amt_code:  ' ||l_adj_for_adhoc_amt_code );
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis',
                       'Tax_rate = 0, unrounded_tax_amt <> 0. ' ||
                       'Cannot calculate taxable basis amount.');
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                       'p_return_status = ' || p_return_status);
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis.END',
                       'ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis (-)');
              END IF;
              RETURN;
            END IF;
          END IF;  -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate

        ELSIF (l_allow_adhoc_tax_rate_flag = 'Y' AND l_adj_for_adhoc_amt_code = 'TAX_RATE')
        THEN
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt <> 0 THEN

              IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).orig_tax_rate IS NULL THEN
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).orig_tax_rate :=
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate;
              END IF;

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate :=
                round(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt/
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt*100, 6);

          ELSE
            -- when Taxable_amt = 0, unrounded_tax_amt = 0, do nothing.
            -- Error out when Taxable_amt = 0, unrounded_tax_amt <> 0.
            IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt <> 0 THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis',
                       'adj_for_adhoc_amt_code:  ' ||l_adj_for_adhoc_amt_code );
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis',
                       'Taxable_amt = 0, unrounded_tax_amt <> 0. ' ||
                       'Cannot calculate tax rate.');
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.Get_taxable_basis',
                       'p_return_status = ' || p_return_status);
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis.END',
                       'ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis (-)');
              END IF;
              RETURN;
            END IF;

          END IF;  -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt
        END IF;

    end if;    -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_base_modifier_rate:=
                       parameter_tbl(l_tax_id).base_rate_modifier;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Compounding_Tax_Flag:=
                       parameter_tbl(l_tax_id).compounding_flg;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Compounding_Dep_Tax_Flag:=
                       parameter_tbl(l_tax_id).compounding_dep_flg;


   WHEN  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag = 'Y' THEN

        NULL;

   ELSE  -- default case

      NULL;

  END CASE; -- Delete_Flag

  -- polpulate tax_amt_included_flag and compounding_tax_flag in
  -- ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl
  --
  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             i).tax_amt_included_flag = 'Y' THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
                                                      p_structure_index) := 'Y';
  END IF;

  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             i).compounding_dep_tax_flag = 'Y' THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
                                                      p_structure_index) := 'Y';
  END IF;

 end loop;

END IF;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis.END',
                  'ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS (-)');
 END IF;

EXCEPTION
   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.GET_TAXABLE_BASIS',
                      p_error_buffer);
    END IF;

END get_taxable_basis;

PROCEDURE populate_inclusive_tax_flag (
    p_tax_line_index   IN          NUMBER,
    p_event_class_rec  IN          ZX_API_PUB.event_class_rec_type,
    p_structure_name   IN          VARCHAR2,
    p_structure_index  IN          BINARY_INTEGER,
    p_return_status    OUT NOCOPY  VARCHAR2,
    p_error_buffer     OUT NOCOPY  VARCHAR2) IS

 l_inclusive_tax_flag      VARCHAR2(1);
 l_reg_party_type          zx_lines.registration_party_type%TYPE;
 l_ptp_id                  zx_party_tax_profile.party_tax_profile_id%TYPE;
 l_site_ptp_id             zx_party_tax_profile.party_tax_profile_id%TYPE;

 CURSOR get_inclusive_flag_from_rate(
        c_tax_rate_id        zx_rates_b.tax_rate_id%TYPE) IS
 SELECT inclusive_tax_flag
   FROM zx_rates_b
  WHERE tax_rate_id = c_tax_rate_id;

 CURSOR get_inclusive_flag_from_ptp(
        c_ptp_id         zx_party_tax_profile.party_tax_profile_id%TYPE) IS
 SELECT inclusive_tax_flag
   FROM zx_party_tax_profile
  WHERE party_tax_profile_id = c_ptp_id;
  l_tax_rate_rec ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
      'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag.BEGIN',
      'ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag (+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;


  -- IF line_amt_includes_tax_flag is 'A'/'N', tax_amt_included_flag
  -- is 'Y'/'N'. If line_amt_includes_tax_flag IN ('S', 'I'), need to
  -- determine tax_amt_included_flag from tax rate/tax registration/
  -- PTP/Tax.
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
                                                   p_structure_index) = 'A'
  THEN
    --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
    --                        p_tax_line_index).tax_amt_included_flag := 'Y';
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_structure_index) = 200
    AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_structure_index) = 'EXPENSE REPORTS' THEN
      ZX_TDS_UTILITIES_PKG.get_tax_rate_info (
                         p_tax_rate_id  => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                p_tax_line_index).tax_rate_id,
                         p_tax_rate_rec  => l_tax_rate_rec,
                         p_return_status  => p_return_status,
                         p_error_buffer   => p_error_buffer);

      IF NVL(l_tax_rate_rec.inclusive_tax_flag, 'X') <> 'N' THEN
        l_inclusive_tax_flag := l_tax_rate_rec.inclusive_tax_flag;
      ELSE
        l_inclusive_tax_flag := 'Y';
      END IF;

      IF l_inclusive_tax_flag IS NOT NULL THEN
        -- populate inclusive_tax_flag onto detail tax line
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

        IF g_level_statement >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
           'Get Inclusive_tax_flag from Tax Rate: ' || l_inclusive_tax_flag);
        END IF;
      ELSE
        IF NVL(ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_tax_line_index).tax_id).def_inclusive_tax_flag, 'X') <> 'N' THEN
          l_inclusive_tax_flag := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     p_tax_line_index).tax_id).def_inclusive_tax_flag;
        ELSE
          l_inclusive_tax_flag := 'Y';
        END IF;
        IF l_inclusive_tax_flag IS NOT NULL THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

          IF g_level_statement >= g_current_runtime_level THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
               'Get tax_amt_included_flag from tax: ' || l_inclusive_tax_flag);
          END IF;
        ELSE
          -- Bug 4778841: default l_inclusive_tax_flag to 'Y' when it is NULL
          --
          l_inclusive_tax_flag := 'Y';
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

          IF g_level_statement >= g_current_runtime_level THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
               'Inclusive tax flag is defaulted to N. ');
          END IF;
        END IF;   -- tax_amt_included_flag is available from tax
      END IF;     -- tax_amt_included_flag is available from tax rate
    ELSE
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            p_tax_line_index).tax_amt_included_flag := 'Y';
    END IF;       -- check for special inclusive applicability for expense reports only

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
                                                        p_structure_index) = 'N'
  THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_tax_line_index).tax_amt_included_flag := 'N';

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt_includes_tax_flag(
                                               p_structure_index) IN ('S', 'I')
  THEN

    -- Get tax_amt_included_flag from tax rate
    --
    /* use cache
      OPEN  get_inclusive_flag_from_rate(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).tax_rate_id);
      FETCH get_inclusive_flag_from_rate INTO l_inclusive_tax_flag;
      CLOSE get_inclusive_flag_from_rate;
    */

            ZX_TDS_UTILITIES_PKG.get_tax_rate_info (
                         p_tax_rate_id  => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                p_tax_line_index).tax_rate_id,
                         p_tax_rate_rec  => l_tax_rate_rec,
                         p_return_status  => p_return_status,
                         p_error_buffer   => p_error_buffer);

          l_inclusive_tax_flag := l_tax_rate_rec.inclusive_tax_flag;

    IF l_inclusive_tax_flag IS NOT NULL THEN

      -- populate inclusive_tax_flag onto detail tax line
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

      IF g_level_statement >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
           'Get Inclusive_tax_flag from Tax Rate: ' ||
            l_inclusive_tax_flag);
      END IF;
    ELSE
      -- Check inclusive_tax_flag returned from tax registration
      -- process(inclusive_tax_flag has already been stamped onto
      -- detail tax line). If it is not available, get
      -- inclusive_tax_flag from ptp table
      --
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         p_tax_line_index).tax_amt_included_flag IS NOT NULL THEN
        IF g_level_statement >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
             'tax_amt_included_flag available from tax registration. ' ||
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       p_tax_line_index).tax_amt_included_flag);
         END IF;
      ELSE

        -- Bug 5335580: Query inclusive_tax_flag from PTP table with registration
        --     party site level PTP id first. If it is not found, query
        --     inclusive_tax_flag using registration party PTP id.
        --
        -- Get tax inclusive flag with l_site_ptp_id
        --
        l_reg_party_type :=
          REPLACE(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  p_tax_line_index).registration_party_type,
                  'PARTY', 'SITE') || '_' || 'TAX_PROF_ID';

        ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
                 p_structure_name,
                 p_structure_index,
                 l_reg_party_type,
                 l_site_ptp_id,
                 p_return_status );

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error ,
              'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
              'Incorrect return_status after call ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value().');

            FND_LOG.STRING(g_level_error,
              'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
              'return_status: '|| p_return_status);
          END IF;
        END IF;

        OPEN  get_inclusive_flag_from_ptp(l_site_ptp_id);
        FETCH get_inclusive_flag_from_ptp INTO l_inclusive_tax_flag;
        CLOSE get_inclusive_flag_from_ptp;

        IF l_inclusive_tax_flag IS NOT NULL THEN

          -- populate inclusive_tax_flag onto detail tax line
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

          IF g_level_statement >= g_current_runtime_level THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
               'Get tax_amt_included_flag from SITE PTP: ' ||
                l_inclusive_tax_flag);
          END IF;

        ELSE  -- l_inclusive_tax_flag is not found from SITE PTP

          -- Get tax inclusive flag with l_ptp_id
          --
          l_reg_party_type:= ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     p_tax_line_index).registration_party_type || '_TAX_PROF_ID';

          ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
                 p_structure_name,
                 p_structure_index,
                 l_reg_party_type,
                 l_ptp_id,
                 p_return_status );

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement>= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
                'Incorrect return_status after call ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value().');

              FND_LOG.STRING(g_level_statement,
                'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
                'return_status: '|| p_return_status);
            END IF;
          END IF;

          OPEN  get_inclusive_flag_from_ptp(l_ptp_id);
          FETCH get_inclusive_flag_from_ptp INTO l_inclusive_tax_flag;
          CLOSE get_inclusive_flag_from_ptp;

          IF l_inclusive_tax_flag IS NOT NULL THEN

            -- populate inclusive_tax_flag onto detail tax line
            --
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

            IF g_level_statement >= g_current_runtime_level THEN
              FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
                 'Get tax_amt_included_flag from PARTY PTP: ' ||
                  l_inclusive_tax_flag);
            END IF;
          ELSE
            -- Get Get tax inclusive flag from Tax
            --
            l_inclusive_tax_flag := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               p_tax_line_index).tax_id).def_inclusive_tax_flag;

            IF l_inclusive_tax_flag IS NOT NULL THEN

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

              IF g_level_statement >= g_current_runtime_level THEN
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
                   'Get tax_amt_included_flag from tax: ' ||
                    l_inclusive_tax_flag);
              END IF;

            ELSE

              -- Bug 4778841: default l_inclusive_tax_flag to 'N' when it is NULL
              --
              l_inclusive_tax_flag := 'N';
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  p_tax_line_index).tax_amt_included_flag := l_inclusive_tax_flag;

              IF g_level_statement >= g_current_runtime_level THEN
                FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
                   'Inclusive tax flag is defaulted to N. ');
              END IF;

              ---- raise error because l_inclusive_tax_flag is not available
              ----
              --p_return_status := FND_API.G_RET_STS_ERROR;
              --p_error_buffer := 'Inclusive Tax Flag is not available.';
              --
              --FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              --FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',
              --              'populate_inclusive_tax_flag- '|| p_error_buffer);
              --FND_MSG_PUB.Add;
              --IF (g_level_unexpected >= g_current_runtime_level ) THEN
              --   FND_LOG.STRING(g_level_unexpected,
              --          'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
              --           p_error_buffer);
              --   FND_LOG.STRING(g_level_unexpected,
              --          'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
              --          'Exception :ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag (-)');
              --END IF;
              --RETURN;

            END IF;   -- tax_amt_included_flag is avialbale from tax
          END IF;     -- tax_amt_included_flag is avialbale from PARTY PTP
        END IF;       -- tax_amt_included_flag is avialbale from SITE PTP
      END IF;         -- tax_amt_included_flag is avialbale from tax registration
    END IF;           -- tax_amt_included_flag is avialbale from tax rate
  END IF;             -- line_amt_includes_tax_flag

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag.END',
           'ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

   IF (g_level_unexpected >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_unexpected,
            'ZX.PLSQL.ZX_TDS_TAXABLE_BASIS_DETM_PKG.populate_inclusive_tax_flag',
             p_error_buffer);
   END IF;
END populate_inclusive_tax_flag;

END ZX_TDS_TAXABLE_BASIS_DETM_PKG;


/
