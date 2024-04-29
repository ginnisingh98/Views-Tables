--------------------------------------------------------
--  DDL for Package Body ZX_TDS_RATE_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_RATE_DETM_PKG" AS
/* $Header: zxditxratedtpkgb.pls 120.77.12010000.19 2010/04/09 10:55:37 ssohal ship $ */

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_error                CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
------------------------------------------------------------------------------

PROCEDURE validate_offset_tax (
  p_tax_regime_code        IN   zx_regimes_b.tax_regime_code%TYPE,
  p_tax                    IN   zx_taxes_b.tax%TYPE,
  p_tax_determine_date     IN   DATE,
  p_tax_status_code        IN   zx_status_b.tax_status_code%TYPE,
  p_tax_jurisdiction_code  IN   zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
  p_tax_class              IN   zx_rates_b.tax_class%TYPE,
  p_tax_rate_code          IN   zx_rates_b.tax_rate_code%TYPE,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_error_buffer           OUT NOCOPY  VARCHAR2
);

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_rate
--
--  DESCRIPTION
--  This is the main procedure in this package.This procedure is used to
--  determine the tax rate for all tax lines belonging to a transaction line
--  (indicated by  p_begin_index and p_end_index)
------------------------------------------------------------------------------


PROCEDURE GET_TAX_RATE(
 p_begin_index            IN          NUMBER,
 p_end_index              IN          NUMBER,
 p_event_class_rec        IN          ZX_API_PUB.event_class_rec_type,
 p_structure_name         IN          VARCHAR2,
 p_structure_index        IN          BINARY_INTEGER,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2)
IS

 l_tax_id                  NUMBER;
 l_def_tax_rate_code       zx_rates_b.tax_rate_code%TYPE;
 l_Tax_Rate_Rule_Flag      varchar2(1);
 l_tax                     ZX_TAXES_B.tax%TYPE;
 l_tax_status_code         ZX_STATUS_B.tax_status_code%TYPE;
 l_tax_regime_code         ZX_STATUS_B.tax_regime_code%TYPE;
 l_tax_rate                NUMBER;
 l_tax_rate_id             INTEGER;
 l_def_tax_rate_id         INTEGER;
 l_tax_jurisdiction_code   zx_rates_b.tax_jurisdiction_code%TYPE;
 l_tax_jurisdiction_id     zx_lines.tax_jurisdiction_id%TYPE;
 l_Rate_Type_Code          zx_rates_b.Rate_Type_Code%TYPE;
 l_def_rate_type           zx_rates_b.Rate_Type_Code%TYPE;
 l_percentage_rate         zx_rates_b.percentage_rate%TYPE;
 l_def_percentage_rate     zx_rates_b.percentage_rate%TYPE;
 l_quantity_rate           zx_rates_b.quantity_rate%TYPE;
 l_def_quantity_rate       zx_rates_b.quantity_rate%TYPE;
 l_tax_rate_code           zx_rates_b.tax_rate_code%TYPE;
 l_tax_date                date;
 l_zx_result_rec           zx_process_results%ROWTYPE;
 l_status_index            NUMBER;
 l_effective_from          DATE;
 l_effective_to            DATE;
 l_adhoc_tax_rate_flg      VARCHAR2(1);
 l_uom_code                zx_rates_b.uom_code%TYPE;
 l_offset_tax_rate_code    zx_rates_b.offset_tax_rate_code%TYPE;
 l_offset_status_code      zx_rates_b.offset_status_code%TYPE;
 l_offset_tax              zx_rates_b.offset_tax%TYPE;
 l_offset_tax_appl         VARCHAR2(1);
 l_ptp_id                  NUMBER;
 l_reg_party_type          VARCHAR2(80);
 l_numeric_result          zx_process_results.numeric_result%TYPE;

 l_tax_rate_rec            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 l_exemption_rec           ZX_TCM_GET_EXEMPT_PKG.exemption_rec_type;
 l_exception_rec           ZX_TCM_GET_EXCEPT_PKG.exception_rec_type;
 l_allow_exemptions_flag   zx_rates_b.allow_exemptions_flag%TYPE;
 l_allow_exceptions_flag   zx_rates_b.allow_exceptions_flag%TYPE;

 l_multiple_jurisdictions_flag  VARCHAR2(1);

 l_tax_class               zx_rates_b.tax_class%TYPE;
 l_inventory_org_id        NUMBER;

 TYPE exemption_info_type IS RECORD (
   tax_regime_code             zx_taxes_b.tax_regime_code%TYPE,
   tax                         zx_taxes_b.tax%TYPE,
   exemption_id                NUMBER,
   percent_exempt              NUMBER,
   discount_special_rate       VARCHAR2(30),
   exempt_reason_code          VARCHAR2(30),
   exempt_reason               VARCHAR2(240),
   exempt_certificate_number   VARCHAR2(80)
 );

 TYPE exemption_info_tbl_type IS TABLE OF exemption_info_type
    INDEX by BINARY_INTEGER;

 l_exempt_info_tbl       exemption_info_tbl_type;
 l_ind                   NUMBER;

 CURSOR  get_ptp_cur(c_ptp_id zx_party_tax_profile.party_tax_profile_id%TYPE) IS
  SELECT Allow_Offset_Tax_Flag
    FROM zx_party_tax_profile
   WHERE party_tax_profile_id = c_ptp_id;

 CURSOR  get_numeric_value_csr(c_result_id zx_process_results.result_id%TYPE) IS
  SELECT numeric_result
    FROM zx_process_results
   WHERE result_id = c_result_id;

 -- bug 7208618
 --
 CURSOR  get_ap_supplier_csr(
             c_account_id          ap_supplier_sites_all.vendor_id%TYPE) IS
  SELECT offset_tax_flag
    FROM ap_suppliers
   WHERE vendor_id      = c_account_id ;

 CURSOR  get_ap_supplier_site_csr(
             c_account_id          ap_supplier_sites_all.vendor_id%TYPE,
             c_account_site_id     ap_supplier_sites_all.vendor_site_id%TYPE) IS
  SELECT offset_tax_flag
    FROM ap_supplier_sites_all
   WHERE vendor_id      = c_account_id
     AND vendor_site_id = c_account_site_id;

 l_account_id             hz_cust_accounts.cust_account_id%TYPE;
 l_account_site_id        hz_cust_acct_sites_all.cust_acct_site_id%TYPE;
 l_account_type_code      VARCHAR2(30);
 l_first_party_flag       BOOLEAN;
 --
 -- End Bug 7208618


BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.GET_TAX_RATE.BEGIN',
                   'ZX_TDS_RATE_DETM_PKG: GET_TAX_RATE(+)');
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;

 -- begin to get tax rate name, if available

  IF p_begin_index IS NULL or p_end_index IS NULL THEN
    p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;  -- 8568734
    IF (g_level_error >= g_current_runtime_level ) THEN

       FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                      ' unexpected error:' ||  'p_begin_index or p_end_index IS NULL...');
     END IF;
     RETURN;
  END IF;

  l_exempt_info_tbl.DELETE;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  FOR i in p_begin_index..p_end_index  LOOP


    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate IS NOT NULL AND
       ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.source_event_class_code(p_structure_index) = 'INTERCOMPANY_TRX' THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                     ' Intercompany Transaction : Tax rate : ' || ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate);
      END IF;
    ELSE

      l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id;
      l_tax := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax;
      l_tax_status_code :=
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code;
      l_tax_regime_code :=
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code;

      l_tax_jurisdiction_code :=
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code;
      l_tax_jurisdiction_id :=
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_id;

      --- Bug 7499374
      l_tax_date := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_date,
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date);

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                     ' Tax Date ' || l_tax_date);
      END IF;

      l_multiple_jurisdictions_flag :=
      NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).multiple_jurisdictions_flag, 'N');

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                     'Multiple Jurisdictions Flag : ' || l_multiple_jurisdictions_flag);
      END IF;

      l_offset_tax_appl := NULL;

    -- Do not perform rate det. if rate is already there in g_detail_tax_lines_tbl
    -- or delete_flag on the tax line is Y or tax is calculated by providers
    -- rate will be already available if it is a manual tax line or an override
    -- tax event with last_manual_entry = 'Tax Rate' or 'Tax Amount'

    -- tax rate determination should not be done for offset taxes. However, the
    -- offset tax lines will not be there in detail tax lines structure for
    -- create or override case. Hence logic to exclude offset taxes is not included


    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry =
          'TAX_AMOUNT' AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate IS NULL
    THEN
      p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;  -- 8568734
      p_error_buffer :=
                'Tax Rate must be entered when last manual entry is Tax Amount';
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                       'p_error_buffer: '|| p_error_buffer);
      END IF;
      RETURN;
    END IF;

   CASE
    WHEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX'
       AND
      ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Recalc_Required_Flag IS NULL OR
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Recalc_Required_Flag = 'N'
       )
    THEN

       --  RECALC_REQUIRED_FLAG will be populated by tax lines Determination
       --  table handler when the user overrides one or more tax lines. (When the
       --  line being overridden is inclusive or used to compound other taxes,
       --  then this flag will be set to 'Y' for all the tax lines belonging to
       --  the current transaction line)  If the value of RACALC_REQUIRED_FLAG = 'N'
       --  then skip the process and only perform population of relevant Tax Rate
       --  Determination columns into detail tax lines structure.
       NULL;

    WHEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry in
         ('TAX_RATE', 'TAX_AMOUNT','STATUSTORATE' )  -- and  -- bug fix 5237144
     --  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX'
    THEN
      -- Check the last_manual_entry flag and if it is tax_rate or tax_amount or
      -- status_to_rate, then do not perform this process.
/****************changed code for 6903249***************************/
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'REFERENCE' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag = 'Y' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).freeze_until_overridden_flag ='Y'
      THEN
        NULL;
      ELSE

        --bug#8679714
        l_tax_regime_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code;
        l_tax := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax;
        l_tax_jurisdiction_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code;
        l_tax_status_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_codE;
        l_tax_rate_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code;

        l_tax_rate_rec := NULL;

        -- Added if condition for Bug#9403476
        IF l_multiple_jurisdictions_flag = 'Y' THEN

          ZX_TCM_TAX_RATE_PKG.get_tax_rate(
              p_event_class_rec             => p_event_class_rec,
              p_tax_regime_code             => l_tax_regime_code,
              p_tax_jurisdiction_code       => l_tax_jurisdiction_code,
              p_tax                         => l_tax,
              p_tax_date                    => l_tax_date,
              p_tax_status_code             => l_tax_status_code,
              p_tax_rate_code               => l_tax_rate_code,
              p_place_of_supply_type_code   => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).place_of_supply_type_code,
              p_structure_index             => p_structure_index,
              p_multiple_jurisdictions_flag => l_multiple_jurisdictions_flag,
              x_tax_rate_rec                => l_tax_rate_rec,
              x_return_status               => p_return_status
            );
        ELSE
          ZX_TDS_UTILITIES_PKG.get_tax_rate_info
            ( l_tax_regime_code,
              l_tax,
              l_tax_jurisdiction_code,
              l_tax_status_code,
              l_tax_rate_code,
              l_tax_date,
              l_tax_class,
              l_tax_rate_rec,
              p_return_status,
              p_error_buffer);
        END IF;

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                   'Incorrect return_status after calling get_tax_rate proc.');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                   'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)'||p_return_status);
          END IF;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

          ZX_API_PUB.add_msg(
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

          RETURN;
        END IF;

        l_tax_rate_id := l_tax_rate_rec.tax_rate_id;
        l_tax_rate_code := l_tax_rate_rec.tax_rate_code;
        l_rate_type_code := l_tax_rate_rec.rate_type_code;
        l_percentage_rate := l_tax_rate_rec.percentage_rate;
        l_quantity_rate := l_tax_rate_rec.quantity_rate;
        l_uom_code             := l_tax_rate_rec.uom_code;
        l_offset_tax_rate_code := l_tax_rate_rec.offset_tax_rate_code;
        l_offset_status_code   := l_tax_rate_rec.offset_status_code;
        l_offset_tax           := l_tax_rate_rec.offset_tax;
        l_adhoc_tax_rate_flg   := l_tax_rate_rec.allow_adhoc_tax_rate_flag;
        l_allow_exemptions_flag := l_tax_rate_rec.allow_exemptions_flag;
        l_allow_exceptions_flag := l_tax_rate_rec.allow_exceptions_flag;

        -- Start : Added to fix Bug#9540546
        IF l_tax_rate_rec.tax_jurisdiction_code IS NOT NULL
           AND nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code, 'Z')
           <> l_tax_rate_rec.tax_jurisdiction_code
        THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code
            := l_tax_rate_rec.tax_jurisdiction_code;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_id
            := l_tax_rate_rec.tax_jurisdiction_id;
        END IF;

        l_tax_jurisdiction_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code;
        l_tax_jurisdiction_id   := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_id;
        -- End : Added to fix Bug#9540546

        IF p_event_class_rec.allow_offset_tax_calc_flag = 'Y' THEN

          IF (l_offset_tax_rate_code is NOT NULL) THEN
            validate_offset_tax (
                p_tax_regime_code        => l_tax_regime_code,
                p_tax                    => l_offset_tax,
                p_tax_determine_date     => l_tax_date,
                p_tax_status_code        => l_offset_status_code,
                p_tax_jurisdiction_code  => l_tax_jurisdiction_code,
                p_tax_class              => l_tax_class,
                p_tax_rate_code          => l_offset_tax_rate_code,
                x_return_status          => p_return_status,
                x_error_buffer           => p_error_buffer);
            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                       'Offset tax not found, reset the return status and continue the process');
              END IF;
              p_return_status := FND_API.G_RET_STS_SUCCESS;
            ELSE -- p_return_status = FND_API.G_RET_STS_SUCCESS
              l_reg_party_type:= p_event_class_rec.Offset_Tax_Basis_Code || '_TAX_PROF_ID';
              -- Bug 7208618
              --
              l_account_type_code := p_event_class_rec.sup_cust_acct_type;
              l_first_party_flag := ZX_TDS_RULE_BASE_DETM_PVT.evaluate_if_first_party(l_reg_party_type);
              IF (NOT l_first_party_flag) AND l_account_type_code = 'SUPPLIER'  THEN
                IF SUBSTR(l_reg_party_type, 1, 14) IN ('SHIP_FROM_SITE', 'BILL_FROM_SITE') OR
                   SUBSTR(l_reg_party_type, 1, 12) IN ('SHIP_TO_SITE', 'BILL_TO_SITE')
                THEN
                  -- get l_account_site_id
                  --
                  ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                     p_structure_name,
                     p_structure_index,
                     SUBSTR(l_reg_party_type,1,5) || 'THIRD_PTY_ACCT_SITE_ID',
                     l_account_site_id,
                     p_return_status,
                     p_error_buffer);

                  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'Incorrect return_status after calling ' ||
                             'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'l_account_site_id = ' || l_account_site_id);
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'RETURN_STATUS = ' || p_return_status);
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                             'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
                    END IF;
                    RETURN;
                  END IF;
                  -- get l_account_id
                  --
                  ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                     p_structure_name,
                     p_structure_index,
                     SUBSTR(l_reg_party_type,1,5) || 'THIRD_PTY_ACCT_ID',
                     l_account_id,
                     p_return_status,
                     p_error_buffer);

                  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'Incorrect return_status after calling ' ||
                             'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'l_account_id = ' || l_account_id);
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'RETURN_STATUS = ' || p_return_status);
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                             'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
                    END IF;
                    RETURN;
                  END IF;

                  OPEN  get_ap_supplier_site_csr(l_account_id, l_account_site_id);
                  FETCH get_ap_supplier_site_csr INTO l_offset_tax_appl;
                  CLOSE get_ap_supplier_site_csr;

                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                           'l_account_site_id = '||l_account_site_id);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                           'l_offset_tax_appl = '||l_offset_tax_appl);
                  END IF;

                ELSIF SUBSTR(l_reg_party_type, 1,15) IN ('SHIP_FROM_PARTY', 'BILL_FROM_PARTY') OR
                      SUBSTR(l_reg_party_type, 1,13) IN ('SHIP_TO_PARTY', 'BILL_TO_PARTY')
                THEN
                  -- get l_account_id
                  --
                  ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                     p_structure_name,
                     p_structure_index,
                     SUBSTR(l_reg_party_type,1,5) || 'THIRD_PTY_ACCT_ID',
                     l_account_id,
                     p_return_status,
                     p_error_buffer);

                  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'Incorrect return_status after calling ' ||
                             'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'l_account_id = ' || l_account_id);
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'RETURN_STATUS = ' || p_return_status);
                      FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                             'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
                    END IF;
                    RETURN;
                  END IF;

                  OPEN  get_ap_supplier_csr(l_account_id);
                  FETCH get_ap_supplier_csr INTO l_offset_tax_appl;
                  CLOSE get_ap_supplier_csr;

                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                           'l_account_id = '||l_account_id);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                           'l_offset_tax_appl= '||l_offset_tax_appl);
                  END IF;
                END IF;  -- l_reg_party_type = 'PARTY' OR 'SITE'
              END IF;    -- l_account_type_code = 'SUPPLIER'

              IF l_offset_tax_appl IS NULL THEN

                ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
                    p_structure_name,
                    p_structure_index,
                    l_reg_party_type,
                    l_ptp_id,
                    p_return_status );

                OPEN get_ptp_cur(l_ptp_id);
                FETCH get_ptp_cur into l_offset_tax_appl;
                CLOSE get_ptp_cur;

                IF (g_level_error >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'l_offset_tax_appl(from PTP) = '||l_offset_tax_appl);
                END IF;
              END IF;

              IF nvl(l_offset_tax_appl,'N') = 'Y' THEN
                IF (g_level_procedure >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'Offset tax applicable...');
                END IF;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Offset_Flag := 'Y';
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).offset_tax_rate_code := l_offset_tax_rate_code;
              ELSE
                IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'Offset tax not applicable...');
                END IF;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Offset_Flag := 'N';
              END IF;  -- l_offset_tax_appl
            END IF; --p_return_status <> FND_API.G_RET_STS_SUCCESS
          END IF; --(l_offset_tax_rate_code is NOT NULL)
        END IF; --p_event_class_rec.allow_offset_tax_calc_flag
      END IF; --PO matched Not Applicable tax Line

/**********end of changed code for 6903249 ************************/


    WHEN
      (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).OTHER_DOC_SOURCE = 'ADJUSTED'  OR
        (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'APPLIED_FROM' AND
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag <> 'R')
      )  AND
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code <> 'OVERRIDE_TAX'
    THEN
      -- In case when the tax line is copied from Applied From (applied_amt_handling_flag on
      -- g_tax_rec_tbl(l_tax_id) is NOT 'R' ) or Adjusted Document,
      -- Applicability process will copy Tax Regime, Tax, Status, Rate, Place of Supply,
      -- Reg. Number, Offset tax columns  from original document. So no need to perform
      -- tax rate determination in this case. However, when the user overrides the calcuated
      -- tax line, tax rate determination needs to be performed.

      NULL;

/*   bug 3330127 : Included in the next case
    WHEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Copied_From_Other_Doc_Flag = 'Y' AND
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Manually_Entered_Flag = 'Y'
    THEN
      -- When a manual tax line is copied from reference document, the Tax Regime, Tax, Status, Rate,
      -- and other columns are copied from manual tax line in reference document as well. So
      -- no need to perform tax rate determination in this case.

      NULL;
*/
    WHEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Freeze_Until_Overridden_Flag = 'Y'

/* -- Bug 3330127: When user override tax line information, Freeze_Until_Overridden_Flag will
   -- be set to 'N'
      AND   ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Overridden_Flag <> 'Y'
           OR
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Copied_From_Other_Doc_Flag = 'Y' )
*/
    THEN

      -- When a manual tax line is copied from reference document, the Tax Regime, Tax, Status, Rate,
      -- and other columns are copied from manual tax line in reference document as well. So
      -- no need to perform tax rate determination in this case.

      -- When the transaction is matched to a reference document, and if a tax
      -- that was applicable on the reference document is not found applicable
      -- during applicability process, the tax line from the reference document
      -- is copied, but the tax rate, status, amounts are populated as zero,
      -- until the user views that tax line and overrides it. So skip tax rate determination
      -- in this case.

      NULL;

/*  -- bug 4673667: do not need to check delete_flag
    WHEN
    -- bug 3330127
      -- Tax lines calculated by provider will not be pulled in for processing
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_provider_id is NOT NULL
       OR

      UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Delete_Flag) = 'Y'
    THEN
      -- Do not perform rate determination for tax lines calculated by providers
      -- or for tax lines marked for deletion.

      NULL;
*/
    WHEN
       ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code is  null
/*     -- Bug 3330127: already handled in the above cases
         AND
        nvl(upper(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Delete_Flag),'N') <> 'Y' AND
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_provider_id is NULL
*/
       ) OR
       ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry IN
         ('TAX_STATUS', 'TAX_RATE_CODE') -- AND --bug 5237144
         -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code = 'OVERRIDE_TAX'
       ) OR
       ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'APPLIED_FROM' AND
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).applied_amt_handling_flag = 'R'
       ) OR
	-- Bug 5176149: need to populate tax rate id and tax rate % for matched invoice
       ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).OTHER_DOC_SOURCE = 'REFERENCE'
       ) OR
       ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).direct_rate_result_id IS NOT NULL
       ) OR
       ( p_event_class_rec.template_usage_code = 'TAX_RULES' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code IS NOT NULL
       )
    THEN
      -- This is the normal processing case where rate determination needs to be performed
      -- When tax is not calculated by provider service and rate is not already
      -- available in detail tax lines structure and delete flag is not 'Y'
      -- or an override case with last_manual_entry as 'TAX_STATUS', then determine
      -- the tax rate to be applied to the tax line.

      -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).process_for_recovery_flag:= 'Y';

--      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code IS NOT NULL
--    bug 3330127: if last_manual_entry = 'TAX_STATUS', UI should set tax_rate_code to NULL
--       AND  nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry,'N') <> 'TAX_STATUS'
--      THEN
--
        --   tax rate is already available on tax line. Use this tax rate
--
--        l_tax_rate_code:= ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code;
--
--      ELSE -- get rate code

      -- If tax rate code is available on tax line. Use this tax rate.
      -- Otherwise, need to determine tax rate code
      --
      l_tax_rate_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code;

      IF l_tax_rate_code IS  NULL  THEN

        --   select the tax rate rule flag from tax status cache
        --   get the hash value using tax regime code, tax, tax status code

        l_status_index := ZX_TDS_UTILITIES_PKG.get_tax_status_index(
                      l_tax,
                      l_tax_regime_code,
                      l_tax_status_code);

        IF l_status_index IS NULL THEN

          --  Tax Status Determination must always populate the Tax Status Information
          --  in the cache; Even when the user enters a manual tax line with status info.
          --  the tax status determination will populate the Tax Status cache for that Status
          --  hence if tax status info is not found in the cache, it is an error.

          p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
          p_error_buffer := 'The Tax Status information could not be located in cache.';

          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'Could not locate the status record in cache....');
          END IF;

          --  Set appropriate message and return
          RETURN;
        ELSE

          l_tax_rate_rule_flag :=
            ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).rule_based_rate_flag;
          l_effective_from :=
            ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).effective_from;
          l_effective_to :=
            ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).effective_to;

        END IF;   -- l_status_index is NULL

        IF l_tax_rate_rule_flag = 'Y' THEN
          -- call rule base detm process to determine tax rate;
          --
          ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
               'DET_TAX_RATE',
               p_structure_name,
               p_structure_index,
               p_event_class_rec,
               l_tax_id,
               l_tax_status_code,
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date,
               NULL,
               NULL,
               l_zx_result_rec,
               p_return_status,
               p_error_buffer);

          IF p_return_status IN ( FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR)
          THEN
            --  error is raised in rule based evaluation. Abort processing.
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                            'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                            'Rule Based engine returned error. Aborting... ');
            END IF;
            RETURN;
          END IF;

          l_tax_rate_code:= l_zx_result_rec.alphanumeric_result;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               i).rate_result_id := l_zx_result_rec.result_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               i).legal_message_rate :=
                ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_zx_result_rec.result_id,
                                                             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_date);

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                          'l_tax_rate_code returned by rule base process is '||
                           l_zx_result_rec.alphanumeric_result);

          END IF;
        END IF;      -- l_Tax_Rate_Rule_Flag = 'Y'
      END IF;        -- get rate code

      l_tax_rate_rec := NULL;

      ZX_TCM_TAX_RATE_PKG.get_tax_rate(
          p_event_class_rec             => p_event_class_rec,
          p_tax_regime_code             => l_tax_regime_code,
          p_tax_jurisdiction_code       => l_tax_jurisdiction_code,
          p_tax                         => l_tax,
          p_tax_date                    => l_tax_date,
          p_tax_status_code             => l_tax_status_code,
          p_tax_rate_code               => l_tax_rate_code,
          p_place_of_supply_type_code   => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             i).place_of_supply_type_code,
          p_structure_index             => p_structure_index,
          p_multiple_jurisdictions_flag => l_multiple_jurisdictions_flag,
          x_tax_rate_rec                => l_tax_rate_rec,
          x_return_status               => p_return_status
      );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                 'Incorrect return_status after calling ' ||
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                 'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)'||p_return_status);
        END IF;

        -- in TCM, the error msg already saved on fnd msg stack
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

        ZX_API_PUB.add_msg(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        RETURN;
      END IF;

      l_tax_rate_id          := l_tax_rate_rec.tax_rate_id;
      l_tax_rate_code        := l_tax_rate_rec.tax_rate_code;
      l_rate_type_code       := l_tax_rate_rec.rate_type_code;
      l_percentage_rate      := l_tax_rate_rec.percentage_rate;
      l_quantity_rate        := l_tax_rate_rec.quantity_rate;
      l_uom_code             := l_tax_rate_rec.uom_code;
      l_offset_tax_rate_code := l_tax_rate_rec.offset_tax_rate_code;
      l_offset_status_code   := l_tax_rate_rec.offset_status_code;
      l_offset_tax           := l_tax_rate_rec.offset_tax;
      l_adhoc_tax_rate_flg   := l_tax_rate_rec.allow_adhoc_tax_rate_flag;
      l_allow_exemptions_flag := l_tax_rate_rec.allow_exemptions_flag;
      l_allow_exceptions_flag := l_tax_rate_rec.allow_exceptions_flag;

      -- if the rate found is not for the most inner jurisdiction, which stamped
      -- on the tax line in applicability process, then restamp the
      -- jurisdiction_code and id for which the rate is found on the
      -- tax line. Here the tax_jurisdition_id is got from he jurisdiction gtt.
      -- NOTE: multiple_jurisdictions_flag won't change during override event

      IF l_tax_rate_rec.tax_jurisdiction_code IS NOT NULL
        AND nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code, 'Z')
            <> l_tax_rate_rec.tax_jurisdiction_code
      THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code
          := l_tax_rate_rec.tax_jurisdiction_code;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_id
            := l_tax_rate_rec.tax_jurisdiction_id;

      END IF; --l_tax_rate_rec.tax_jurisdiction_code IS NOT NULL

      l_tax_jurisdiction_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code;
      l_tax_jurisdiction_id   := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_id;

      IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.EXISTS(l_tax_rate_id) THEN
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id) := l_tax_rate_rec;
      END IF;

      IF l_tax_rate_code IS NOT NULL THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code:=
                                                               l_tax_rate_code;
        IF l_Rate_Type_Code = 'SLABBED' THEN

           -- slabbed rate not supported in phase 1a;
           -- UI need to take care of not to allow slabbed tax defined.
           p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;  -- 8568734
           p_error_buffer := 'Slabbed rates are not supported in phase 1a ';
           IF (g_level_error >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                           'p_error_buffer: '|| p_error_buffer);
           END IF;
           RETURN;

        elsif l_Rate_Type_Code = 'PERCENTAGE' THEN

             l_tax_rate:= l_percentage_rate;

        else   -- quantity

             l_tax_rate:= l_quantity_rate;

        --   For quantity based rates, if the UOM_CODE on the transaction does
        --   not match the UOM_CODE on the rate, then raise error.

--             IF l_uom_code <> ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).uom_code THEN
               IF l_uom_code <>
                  ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.uom_code(p_structure_index)
               THEN
                   -- Raise error;
                   p_return_status:= FND_API.G_RET_STS_ERROR;
                   p_error_buffer := 'UOM_CODE on the transaction does not match the '||
                                     ' UOM_CODE on the rate ';

                   IF (g_level_error >= g_current_runtime_level ) THEN
                     FND_LOG.STRING(g_level_error,
                                    'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                    'The UOM '||l_uom_code||' for quantity rate '||l_tax_rate_code ||
                                    ' is not the same as the UOM '||
                                     ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.uom_code(
                                                                            p_structure_index)
                                     ||' on the transaction line. Please fix one to match the other.');
                   END IF;

                   FND_MESSAGE.SET_NAME('ZX','ZX_UOM_NOT_MATCH');
                   FND_MESSAGE.SET_TOKEN('UOM_RATE',l_uom_code);
                   FND_MESSAGE.SET_TOKEN('RATE_CODE', l_tax_rate_code );
                   FND_MESSAGE.SET_TOKEN('UOM_TRX',
                     ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.uom_code(p_structure_index) );

                   -- FND_MSG_PUB.Add;
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

                   ZX_API_PUB.add_msg(
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

                   RETURN;
             END IF;

        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'tax rate code: ' ||l_tax_rate_code ||' tax_rate =  ' || l_tax_rate);
        END IF;

      ELSE -- if l_tax_rate_code is NULL
        p_return_status:= FND_API.G_RET_STS_ERROR;     -- error

        IF (g_level_error>= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'Tax_rate_code not found for tax: '|| l_tax ||
                         'tax_status: '||l_tax_status_code);
        END IF;

        FND_MESSAGE.SET_NAME('ZX','ZX_RATE_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('TAX',l_tax);
        FND_MESSAGE.SET_TOKEN('TAX_STATUS',l_tax_status_code);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',l_tax_date);  -- 8568734
        --FND_MSG_PUB.Add;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

        ZX_API_PUB.add_msg(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        RETURN;

      END IF;       -- l_tax_rate_code is NOT NULL

      IF l_tax_rate IS NULL THEN
        -- rate_code found from the zx_rates_b table, but no
        -- rate associated with the rate_code

        p_return_status:= FND_API.G_RET_STS_ERROR;     -- error

        IF (g_level_error>= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         'Tax_rate_code not found for tax: '|| l_tax ||
                         'tax_status: '||l_tax_status_code);
        END IF;

        FND_MESSAGE.SET_NAME('ZX','ZX_RATE_NOT_FOUND');  -- 8568734
        FND_MESSAGE.SET_TOKEN('TAX',l_tax);
        FND_MESSAGE.SET_TOKEN('TAX_STATUS',l_tax_status_code);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',l_tax_date);
        --FND_MSG_PUB.Add;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

        ZX_API_PUB.add_msg(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        p_error_buffer := 'Error: No tax rate found';
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                         p_error_buffer);
        END IF;
        RETURN;
      END IF;

      -- Bug 4277751: for INTERCOMPANY CREATE and
      -- offset_flag = 'Y', populate the offset_tax_rate_code and skip
      -- offset applicability process
      --
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                 p_structure_index) IN ('CREATE', 'UPDATE')
        AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(
                                 p_structure_index) = 'INTERCOMPANY_TRX'
        AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Offset_Flag = 'Y'
      THEN

        -- for intercompany the Offset_Flag on detail tax line marked as 'Y'
        -- only when the offset_tax_rate_code is not null, so no need to check
        -- whether the offset_tax_rate_code is null in this case.

        validate_offset_tax (
          p_tax_regime_code        => l_tax_regime_code,
          p_tax                    => l_offset_tax,
          p_tax_determine_date     => l_tax_date,
          p_tax_status_code        => l_offset_status_code,
          p_tax_jurisdiction_code  => l_tax_jurisdiction_code, --? does offset tax rate has jurisdiction info
          p_tax_class              => l_tax_class,
          p_tax_rate_code          => l_offset_tax_rate_code,
          x_return_status          => p_return_status,
          x_error_buffer           => p_error_buffer
         );

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          p_error_buffer := 'Need to create Offset Tax. But offset tax is not valid'; -- will be replaced with coded message

          IF g_level_error >= g_current_runtime_level THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                    'Need to create Offset Tax. But offset tax is not valid');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                   'RETURN_STATUS = ' || p_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                   'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
          END IF;
          RETURN;
        ELSE
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                i).offset_tax_rate_code := l_offset_tax_rate_code;
        END IF;

      ELSIF p_event_class_rec.allow_offset_tax_calc_flag = 'Y' THEN

        -- Check the value of p_event_class_rec.allow_offset_tax_calc_flag to
        -- determine if it is necessary to perform offset tax applicability process
        --
        -- perform applicability process for offset tax;
        --
        --bug8517610
        IF l_offset_tax_rate_code IS NOT NULL AND
	   NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source,'X') NOT IN ('APPLIED_FROM', 'ADJUSTED') THEN

          validate_offset_tax (
            p_tax_regime_code        => l_tax_regime_code,
            p_tax                    => l_offset_tax,
            p_tax_determine_date     => l_tax_date,
            p_tax_status_code        => l_offset_status_code,
            p_tax_jurisdiction_code  => l_tax_jurisdiction_code,
            p_tax_class              => l_tax_class,
            p_tax_rate_code          => l_offset_tax_rate_code,
            x_return_status          => p_return_status,
            x_error_buffer           => p_error_buffer
           );

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                          'Offset tax not found, reset the return status and continue the process');
            END IF;
            p_return_status := FND_API.G_RET_STS_SUCCESS;

          ELSE -- p_return_status = FND_API.G_RET_STS_SUCCESS

            l_reg_party_type:= p_event_class_rec.Offset_Tax_Basis_Code || '_TAX_PROF_ID';

            -- Bug 7208618
            --
            l_account_type_code := p_event_class_rec.sup_cust_acct_type;
            l_first_party_flag := ZX_TDS_RULE_BASE_DETM_PVT.evaluate_if_first_party(l_reg_party_type);

            IF (NOT l_first_party_flag) AND l_account_type_code = 'SUPPLIER'  THEN

              IF SUBSTR(l_reg_party_type, 1, 14) IN ('SHIP_FROM_SITE', 'BILL_FROM_SITE') OR
                 SUBSTR(l_reg_party_type, 1, 12) IN ('SHIP_TO_SITE', 'BILL_TO_SITE')
              THEN

                -- get l_account_site_id
                --
                ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                     p_structure_name,
                     p_structure_index,
                     SUBSTR(l_reg_party_type,1,5) || 'THIRD_PTY_ACCT_SITE_ID',
                     l_account_site_id,
                     p_return_status,
                     p_error_buffer);

                IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               'Incorrect return_status after calling ' ||
                               'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               'l_account_site_id = ' || l_account_site_id);
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               'RETURN_STATUS = ' || p_return_status);
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                               'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
                  END IF;
                  RETURN;
                END IF;

                -- get l_account_id
                --
                ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                     p_structure_name,
                     p_structure_index,
                     SUBSTR(l_reg_party_type,1,5) || 'THIRD_PTY_ACCT_ID',
                     l_account_id,
                     p_return_status,
                     p_error_buffer);

                 IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF (g_level_error >= g_current_runtime_level ) THEN
                     FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                'Incorrect return_status after calling ' ||
                                'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
                     FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                'l_account_id = ' || l_account_id);
                     FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                'RETURN_STATUS = ' || p_return_status);
                     FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                                'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
                   END IF;
                   RETURN;
                 END IF;


                 OPEN  get_ap_supplier_site_csr(l_account_id, l_account_site_id);
                 FETCH get_ap_supplier_site_csr INTO l_offset_tax_appl;
                 CLOSE get_ap_supplier_site_csr;

                 IF (g_level_error >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'l_account_site_id = '||l_account_site_id);
                   FND_LOG.STRING(g_level_error,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                              'l_offset_tax_appl = '||l_offset_tax_appl);
                 END IF;

              ELSIF SUBSTR(l_reg_party_type, 1,15) IN ('SHIP_FROM_PARTY', 'BILL_FROM_PARTY') OR
                    SUBSTR(l_reg_party_type, 1,13) IN ('SHIP_TO_PARTY', 'BILL_TO_PARTY')
              THEN

                -- get l_account_id
                --
                ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                     p_structure_name,
                     p_structure_index,
                     SUBSTR(l_reg_party_type,1,5) || 'THIRD_PTY_ACCT_ID',
                     l_account_id,
                     p_return_status,
                     p_error_buffer);

                IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               'Incorrect return_status after calling ' ||
                               'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               'l_account_id = ' || l_account_id);
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               'RETURN_STATUS = ' || p_return_status);
                    FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                               'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)');
                  END IF;
                  RETURN;
                END IF;

                OPEN  get_ap_supplier_csr(l_account_id);
                FETCH get_ap_supplier_csr INTO l_offset_tax_appl;
                CLOSE get_ap_supplier_csr;

                IF (g_level_error >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'l_account_id = '||l_account_id);
                   FND_LOG.STRING(g_level_error,
                             'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                             'l_offset_tax_appl= '||l_offset_tax_appl);
                END IF;

              END IF;  -- l_reg_party_type = 'PARTY' OR 'SITE'
            END IF;    -- l_account_type_code = 'SUPPLIER'
            -- Bug 7208618 ends

            IF l_offset_tax_appl IS NULL THEN

              ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
                    p_structure_name,
                    p_structure_index,
                    l_reg_party_type,
                    l_ptp_id,
                    p_return_status );

              OPEN get_ptp_cur(l_ptp_id);
              FETCH get_ptp_cur into l_offset_tax_appl;
              CLOSE get_ptp_cur;

              IF (g_level_error >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                           'l_offset_tax_appl(from PTP) = '||l_offset_tax_appl);
              END IF;

            END IF;

          --ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
          --    'DET_OFFSET_TAX',
          --     p_structure_name,
          --     p_structure_index,
          --     p_event_class_rec,
          --     l_tax_id,
          --     l_tax_status_code,
          --     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date,
          --     l_offset_rule_code,
          --     null,
          --     l_zx_result_rec,
          --     p_return_status,
          --     p_error_buffer);
          --
          --IF p_return_status in (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR)
          --THEN
          --  -- Error is raised in rule based evaluation. Abort processing.
          --  --
          --  IF (g_level_statement >= g_current_runtime_level ) THEN
          --     FND_LOG.STRING(g_level_statement,
          --                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
          --                   'Rule Based engine returned error. Aborting... ');
          --  END IF;
          --  p_return_status:= FND_API.G_RET_STS_ERROR;
          --  p_error_buffer := 'Rule Based engine returned error during offset tax determination ';
          --
          --  IF (g_level_statement >= g_current_runtime_level ) THEN
          --    FND_LOG.STRING(g_level_statement,
          --                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
          --                   'p_error_buffer: '|| p_error_buffer);
          --  END IF;
          --  RETURN;
          --ELSE
          --  l_offset_tax_appl:= l_zx_result_rec.alphanumeric_result;

            IF nvl(l_offset_tax_appl,'N') = 'Y' THEN

              IF (g_level_procedure >= g_current_runtime_level ) THEN

                FND_LOG.STRING(g_level_procedure,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                              'Offset tax applicable...');
              END IF;

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Offset_Flag := 'Y';


              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       i).offset_tax_rate_code := l_offset_tax_rate_code;
            --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            --                                      i).offset_tax_line_number :=
            --              NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_max_tax_line_number,0)+ 1;
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_max_tax_line_number :=
                            NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_max_tax_line_number,0)+ 1;

            --IF (g_level_statement >= g_current_runtime_level ) THEN
            --  FND_LOG.STRING(g_level_statement,
            --                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
            --                'offset_tax_line_number = '||
            --                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            --                                              i).offset_tax_line_number);
            --END IF;
            ELSE
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                              'Offset tax not applicable...');
              END IF;

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Offset_Flag := 'N';
            END IF;  -- l_offset_tax_appl
          --END IF;  -- p_return_status
          END IF;    -- p_return_status after validate_offset_tax
        END IF;      -- l_offset_tax_rate_code
      END IF;        -- p_event_class_rec.allow_offset_tax_calc_flag = 'Y'

       -- When tax_event_type in the Event Class structure is 'OVERRIDE_TAX', tax rate
       -- determination will only be done when last_manual_entry = 'TAX_STATUS'.
       -- After tax rate is determined for the line whose  last_manual_entry =
       -- 'TAX_STATUS',  last_manual_entry will be updated to 'STATUSTORATE'.


       IF  nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry,'N') = 'TAX_STATUS'
       THEN
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry := 'STATUSTORATE';

       END IF;

       -- Bug 3973763: If direc_rate_result_id IS NOT NULL, check if
       -- numeric_result is populated. If yes, check if tax is adhoc. If yes,
       -- populate this value to tax_rate field, if not, check if
       -- l_tax_rate = l_numeric_result. If not, raise error.
       --
       IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).direct_rate_result_id IS NOT NULL
       THEN

         OPEN get_numeric_value_csr(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).direct_rate_result_id);
         FETCH get_numeric_value_csr INTO l_numeric_result;
         CLOSE get_numeric_value_csr;

         IF l_numeric_result IS NOT NULL THEN

           IF l_adhoc_tax_rate_flg = 'Y' THEN

              l_tax_rate := l_numeric_result;

           ELSE
             IF l_tax_rate <> l_numeric_result THEN

               -- Raise error
               --
               p_return_status:= FND_API.G_RET_STS_ERROR;
               p_error_buffer := 'Different Exception rate is specified for non-adhoc tax.';

               -- Bug 8568734: add a new message
               FND_MESSAGE.SET_NAME('ZX','ZX_EXCEPTION_RATE');
               FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE', l_tax_rate_code);

               ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

               ZX_API_PUB.add_msg(
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


               IF (g_level_error >= g_current_runtime_level) THEN
                 FND_LOG.STRING(g_level_error,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                               p_error_buffer);
                 FND_LOG.STRING(g_level_error,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                              'l_tax_rate = ' ||l_tax_rate);
                 FND_LOG.STRING(g_level_error,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                              'l_numeric_result = ' || l_numeric_result);
                 FND_LOG.STRING(g_level_error,
                              'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                              'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-) ');
               END IF;
               RETURN;
             END IF;
           END IF;
         END IF;
       END IF;

       --bug6604498

       IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exception_rate IS NOT NULL THEN
          l_tax_rate := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exception_rate;
       END IF;

       -- Process Tax Exceptions
       IF l_allow_exceptions_flag ='Y' THEN
         IF p_event_class_rec.prod_family_grp_code = 'O2C' AND
            ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_id.EXISTS(p_structure_index) THEN
             l_inventory_org_id := nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_id(p_structure_index),
                                       ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index));
         ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' AND
               ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id.EXISTS(p_structure_index) THEN
             l_inventory_org_id := nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id(p_structure_index),
                                       ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index));
         ELSE
          l_inventory_org_id := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index);
         END IF;

         ZX_TCM_GET_EXCEPT_PKG.get_tax_exceptions(
           p_inventory_item_id         => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id(p_structure_index),
           p_inventory_organization_id => l_inventory_org_id,
           p_product_category          => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_category(p_structure_index),
           p_tax_regime_code           => l_tax_regime_code,
           p_tax                       => l_tax,
           p_tax_status_code           => l_tax_status_code,
           p_tax_rate_code             => l_tax_rate_code,
           p_trx_date                  => l_tax_date,
           p_tax_jurisdiction_id       => l_tax_jurisdiction_id,
           p_multiple_jurisdictions_flag => l_multiple_jurisdictions_flag,
           x_exception_rec             => l_exception_rec,
           x_return_status             => p_return_status
         );

         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_error >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                    'Incorrect return_status after calling ' ||
                    'ZX_TCM_GET_EXCEPT_PKG.get_tax_exceptions');
             FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                    'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)'||p_return_status);
           END IF;

           RETURN;
         END IF;

         IF l_exception_rec.tax_exception_id IS NOT NULL THEN
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).TAX_EXCEPTION_ID := l_exception_rec.tax_exception_id;

           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).EXCEPTION_RATE := l_exception_rec.exception_rate;

           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).TAX_RATE_BEFORE_EXCEPTION := l_tax_rate;

           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).TAX_RATE_NAME_BEFORE_EXCEPTION := l_tax_rate_code;

           IF l_exception_rec.exception_type_code = 'SPECIAL_RATE' THEN
             l_tax_rate := l_exception_rec.exception_rate;
           ELSE -- l_exception_rec.exception_type_code = 'DISCOUNT' THEN
             l_tax_rate := l_tax_rate*(100 - l_exception_rec.exception_rate)/100;
           END IF;
         END IF;

       END IF;

       -- Process Tax Exemptions

        IF p_event_class_rec.allow_exemptions_flag ='Y'
          AND l_allow_exemptions_flag ='Y'
        THEN

          l_exemption_rec := NULL;

          -- Bug 8476876: Commet out the reference to l_exempt_info_tbl per Helen
          -- IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
          --      l_tax_id).tax_exmpt_source_tax IS NOT NULL
          -- THEN
          --   IF (g_level_statement >= g_current_runtime_level ) THEN
          --     FND_LOG.STRING(g_level_statement,
          --            'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
          --            'Current tax has a source tax: ' ||
          --            ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax_exmpt_source_tax);
          --
          --   END IF;
          --
          --
          --   FOR i IN REVERSE NVL(l_exempt_info_tbl.FIRST, 0)..NVL(l_exempt_info_tbl.LAST, -1) LOOP
          --
          --
          --     IF l_exempt_info_tbl(i).tax_regime_code = l_tax_regime_code AND
          --        l_exempt_info_tbl(i).tax = ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
          --                                     l_tax_id).tax_exmpt_source_tax
          --     THEN
          --
          --       l_exemption_rec.exemption_id := l_exempt_info_tbl(i).exemption_id;
          --       l_exemption_rec.percent_exempt := l_exempt_info_tbl(i).percent_exempt;
          --       l_exemption_rec.discount_special_rate := l_exempt_info_tbl(i).discount_special_rate;
          --       l_exemption_rec.exempt_reason_code := l_exempt_info_tbl(i).exempt_reason_code;  -- Bug8206838
          --       l_exemption_rec.exempt_certificate_number := l_exempt_info_tbl(i).exempt_certificate_number; -- Bug8206838
          --       l_exemption_rec.exempt_reason := l_exempt_info_tbl(i).exempt_reason; -- Bug8206838
          --       EXIT;
          --     END IF;
          --   END LOOP;
          -- END IF;

         IF l_exemption_rec.exemption_id IS NULL THEN
           IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                    'There is no source tax or no source tax exemptions info '||
                    'calling TCM exemption API to get exemption info.');
           END IF;

	   /* Bug Number: 6328797 - According to 11i , The exemptions should work at
	        -> Ship_To For Customer Site level.
		-> Bill_to For Customer Level
	      So we need to pass ship_to_site_tax_prof_id for finding the exemptions.
	      But previously we were passing Bill_to_site_tax_prof_id to find the exemptions.
	      So, chaged passing variable to ship_to_site_tax_prof_id.

	      But to avoid the structure changes, we are not changing the Naming Convention.
	      If we change the Structure Chages we need to do in lot of packages.
	      So we are keeping the name as bill_to only but changing the passing value.
	   */

           IF p_event_class_rec.prod_family_grp_code = 'O2C' AND
              ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_id.EXISTS(p_structure_index) THEN
                l_inventory_org_id := nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_id(p_structure_index),
                                          ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index));
           ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' AND
                 ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id.EXISTS(p_structure_index) THEN
                l_inventory_org_id := nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id(p_structure_index),
                                          ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index));
           ELSE
             l_inventory_org_id := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index);
           END IF;

	   ZX_TCM_GET_EXEMPT_PKG.get_tax_exemptions(
             p_bill_to_cust_site_use_id  => NVL(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_cust_acct_site_use_id(p_structure_index),
                                                ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_cust_acct_site_use_id(p_structure_index)), -- 7625597
             p_bill_to_cust_acct_id      => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_third_pty_acct_id(p_structure_index),
             p_bill_to_party_site_ptp_id => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_site_tax_prof_id(p_structure_index),
             p_bill_to_party_ptp_id      => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_tax_prof_id(p_structure_index),
             p_sold_to_party_site_ptp_id => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trading_hq_site_tax_prof_id(p_structure_index),
             p_sold_to_party_ptp_id      => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trading_hq_party_tax_prof_id(p_structure_index),
             p_inventory_org_id          => l_inventory_org_id,
             p_inventory_item_id         => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id(p_structure_index),
             p_exempt_certificate_number  => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_certificate_number(p_structure_index),
             p_reason_code               => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_reason_code(p_structure_index),
             p_exempt_control_flag       => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exemption_control_flag(p_structure_index),
             p_tax_date                  => l_tax_date,
             p_tax_regime_code           => l_tax_regime_code,
             p_tax                       => l_tax,
             p_tax_status_code           => l_tax_status_code,
             p_tax_rate_code             => l_tax_rate_code,
             p_tax_jurisdiction_id       => l_tax_jurisdiction_id,
             p_multiple_jurisdictions_flag => l_multiple_jurisdictions_flag,
             p_event_class_rec           => p_event_class_rec,
             x_return_status             => p_return_status,
             x_exemption_rec             => l_exemption_rec);

           IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF (g_level_error >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                      'Incorrect return_status after calling ' ||
                      ' ZX_TCM_GET_EXEMPT_PKG.get_tax_exemptions');
               FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                      'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-)'||p_return_status);
             END IF;

             -- in TCM, the error msg already saved on fnd msg stack
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

             ZX_API_PUB.add_msg(
                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

             RETURN;
           END IF;

           -- Bug 8476876: comment out reference to l_exempt_info_tbl per Helen
           --
           -- IF l_exemption_rec.apply_to_lower_levels_flag = 'Y' THEN
           --
           --   l_ind := NVL(l_exempt_info_tbl.LAST, 0) + 1;
           --   l_exempt_info_tbl(l_ind).tax_regime_code := l_tax_regime_code;
           --   l_exempt_info_tbl(l_ind).tax := l_tax;
           --   l_exempt_info_tbl(l_ind).exemption_id := l_exemption_rec.exemption_id;
           --   l_exempt_info_tbl(l_ind).percent_exempt := l_exemption_rec.percent_exempt;
           --   l_exempt_info_tbl(l_ind).discount_special_rate := l_exemption_rec.discount_special_rate;
           --   l_exempt_info_tbl(l_ind).exempt_reason_code := l_exemption_rec.exempt_reason_code;
           --   l_exempt_info_tbl(l_ind).exempt_certificate_number := l_exemption_rec.exempt_certificate_number;
           --   l_exempt_info_tbl(l_ind).exempt_reason := l_exemption_rec.exempt_reason;
           -- END IF;

         END IF;

         IF l_exemption_rec.exemption_id IS NOT NULL THEN

           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).tax_exemption_id := l_exemption_rec.exemption_id;

           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).tax_rate_before_exemption := l_tax_rate;

           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             i).tax_rate_name_before_exemption := l_tax_rate_code;

          -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --   i).exempt_certificate_number
          --     := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_certificate_number(
          --          p_structure_index);

          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --     i).exempt_reason
          --   := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_reason(
          --      p_structure_index);

          -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --   i).exempt_reason_code
          --     := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_reason_code(
          --          p_structure_index);
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exempt_certificate_number
          := l_exemption_rec.exempt_certificate_number;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exempt_reason
             := l_exemption_rec.exempt_reason;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exempt_reason_code
          := l_exemption_rec.exempt_reason_code;


           IF l_exemption_rec.discount_special_rate = 'SPECIAL_RATE' THEN

             IF l_tax_rate <> 0 THEN
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exempt_rate_modifier
                   := l_exemption_rec.percent_exempt / l_tax_rate;
               l_tax_rate := l_exemption_rec.percent_exempt;
             ELSE
               IF (g_level_statement >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                        'tax_rate is Zero, no exemption needed. ' );
               END IF;
             END IF;

           ELSE -- l_exemption_rec.discount_special_rate = 'DISCOUNT' THEN
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exempt_rate_modifier
                 := (l_exemption_rec.percent_exempt)/100;   -- Bug8206838

             if nvl(l_exemption_rec.percent_exempt,0)>100 then
                l_tax_rate := l_tax_rate*(l_exemption_rec.percent_exempt)/100;
             else
                l_tax_rate := l_tax_rate*(100 - l_exemption_rec.percent_exempt)/100;
             end if;

           END IF;

         END IF; -- l_exemption_rec.exemption_id IS NOT NULL

       END IF;  --  p_event_class_rec.allow_exemptions_flag ='Y'

       update_tax_rate(-- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl,
                    i,
                    l_tax_rate_code,
                    l_tax_rate,
                    l_tax_rate_id,
                    l_Rate_Type_Code);


   ELSE  -- default case of WHEN statement

       -- ***** If the rate is available through tax group expansion, then
       -- ***** should the validation of rate be done ?

       -- If the rate is available then validate whether the tax rate can be used
       -- for the transaction
       IF      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate is NOT NULL
--           AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_provider_id is NULL
--           AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Delete_Flag <> 'Y'
       THEN
           -- check whether the tax rate is ad-hoc

/* commented out for bug 3420310, the following check should have been done on the UI
            l_status_index := ZX_TDS_UTILITIES_PKG.get_tax_status_index(
                                l_tax,
                                l_tax_regime_code,
                                l_tax_status_code);


            IF l_status_index is NULL THEN

              -- Tax Status Determination must always populate the Tax Status Information
              -- in the cache; Hence if tax status info is not found in the cache,
              -- it is an error.

               p_return_status:= FND_API.G_RET_STS_ERROR;
               p_error_buffer := 'The Tax Status information could not be located in cache.';
               IF (g_level_error >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                'Could not locate the status record in cache....');
               END IF;
              --  Set appropriate message and return
              RETURN;
            ELSE
               -- bug fix 3420310
               -- Allow_Adhoc_Tax_Rate_Flag moved to zx_rates_b table, g_tax_status_info_tbl changed accordingly
               -- l_adhoc_tax_rate_flg :=
               --  ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).Allow_Adhoc_Tax_Rate_Flag;
               l_adhoc_tax_rate_flg :=
                 ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).Allow_Adhoc_Tax_Rate_Flag;

            END IF;   -- l_status_index is NULL

            -- If the tax code is not adhoc then the user cannot specify tax rate on
            -- the tax line. if this was an override case, and if last_manual_entry
            -- is Tax Amount, then the rate should not be available on the Tax Line.

            IF l_adhoc_tax_rate_flg <> 'Y'
            AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_manual_entry = 'TAX_RATE' THEN

               p_return_status:= FND_API.G_RET_STS_ERROR;
               p_error_buffer := 'You cannot specify a rate percentage on a tax which '||
                                 ' is not ad-hoc';
               IF (g_level_error >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                'A tax rate cannot be specified on a tax status which '||
                                'does not allow ad-hoc rates');
               END IF;
               RETURN;

            END IF;
end commented out for bug 3420310 */

            IF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Copied_From_Other_Doc_Flag = 'Y'
            AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Manually_Entered_Flag <> 'Y'
            THEN
             --  The tax was prorated based on reference document; validate that
             --  the tax rate is valid for the transaction date.

                IF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date >=
                   ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).effective_from
                and ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date <=
                   ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_status_index).effective_to
                THEN
                    NULL;

                else
                    p_return_status:= FND_API.G_RET_STS_ERROR;
                    p_error_buffer := 'The rate is not valid for the tax determination date'||
                          to_char(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date);
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate',
                                     'p_error_buffer: '|| p_error_buffer);
                    END IF;

                    -- bug 8568734: use ZX_RATE_NOT_FOUND
                    FND_MESSAGE.SET_NAME('ZX','ZX_RATE_NOT_FOUND');
                    FND_MESSAGE.SET_TOKEN('TAX',
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax);
                    FND_MESSAGE.SET_TOKEN('TAX_STATUS',
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code);
                    FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date);

                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

                    ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

                    RETURN;
                END IF;
            END IF;
       END IF;

   END CASE; -- rate determination

   END IF; -- Intercompany Transaction check

 end loop; -- for tax i.

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.get_tax_rate.END',
                  'ZX_TDS_RATE_DETM_PKG.get_tax_rate(-) ');
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.GET_TAX_RATE',
                      p_error_buffer);
    END IF;


END GET_TAX_RATE;



PROCEDURE UPDATE_TAX_RATE(
--  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl   in out nocopy   zx_api_pub.detail_tax_line_tbl_type,
  p_tax_line_index        in              number,
  p_tax_rate_code         in              zx_lines.tax_rate_code%TYPE,
  p_tax_rate              in              zx_lines.tax_rate%TYPE,
  p_tax_rate_id           in              number,
  p_Rate_Type_Code             in              zx_rates_b.Rate_Type_Code%TYPE) IS

begin

 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.update_tax_rate.BEGIN',
                  'ZX_TDS_RATE_DETM_PKG.update_tax_rate(+) ');
 END IF;

   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).tax_rate_code:= p_tax_rate_code;
   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).tax_rate:= p_tax_rate;
   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).tax_rate_id := p_tax_rate_id ;
   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).tax_rate_type := p_Rate_Type_Code;
   BEGIN
   IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).legal_message_rate IS NULL THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).legal_message_rate := NULL;
   END IF;
   EXCEPTION WHEN OTHERS THEN
     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_tax_line_index).legal_message_rate := NULL;
   END;

 IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.update_tax_rate.END',
                  'ZX_TDS_RATE_DETM_PKG.update_tax_rate(-) ');
 END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.update_tax_rate',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

end  update_tax_rate;
------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  validate_offset_tax
--
--  DESCRIPTION
--  This procedure calls utility pkg to validate the tax, tax_status and tax_rate.
--  If validation succeed, utility pkg will store the tax, status, rate info in
--  the global cache structure.
--
--  Created by lxzhang for bug fix 5118526
------------------------------------------------------------------------------

PROCEDURE validate_offset_tax (
  p_tax_regime_code        IN   zx_regimes_b.tax_regime_code%TYPE,
  p_tax                    IN   zx_taxes_b.tax%TYPE,
  p_tax_determine_date     IN   DATE,
  p_tax_status_code        IN   zx_status_b.tax_status_code%TYPE,
  p_tax_jurisdiction_code  IN   zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
  p_tax_class              IN   zx_rates_b.tax_class%TYPE,
  p_tax_rate_code          IN   zx_rates_b.tax_rate_code%TYPE,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_error_buffer           OUT NOCOPY  VARCHAR2
) IS

 /* Bug#5417753- use cache structure
  CURSOR get_offset_info_csr
    (c_tax_rate_code         ZX_RATES_B.TAX_RATE_CODE%TYPE,
     c_tax                   ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code       ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_status_code       ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_tax_determine_date    ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE)
  IS
    SELECT tax_rate_id
      FROM ZX_SCO_RATES_B_V    -- Bug#5395227
      WHERE tax_rate_code   = c_tax_rate_code         AND
            tax             = c_tax                   AND
            tax_regime_code = c_tax_regime_code       AND
            tax_status_code = c_tax_status_code       AND
            active_flag     = 'Y'                     AND
            c_tax_determine_date >= effective_from    AND
            (c_tax_determine_date <= effective_to     OR
             effective_to IS NULL)
      ORDER BY subscription_level_code;             -- Bug#5395227
  */

  l_tax_rate_id            NUMBER;
  l_offset_tax_rec         ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
  l_offet_tax_status_rec   ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
  l_offset_tax_rate_rec    ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax.BEGIN',
                   'ZX_TDS_RATE_DETM_PKG: validate_offset_tax(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                         p_tax_regime_code,
                         p_tax,
                         p_tax_determine_date,
                         l_offset_tax_rec,
                         x_return_status,
                         x_error_buffer);

  IF NVL(x_return_status, FND_API.G_RET_STS_UNEXP_ERROR) <> FND_API.G_RET_STS_SUCCESS  THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax',
                   'Incorrect return status after calling ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
      FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax.END',
                   'ZX_TDS_RATE_DETM_PKG: validate_offset_tax(-)');
    END IF;
    RETURN;
  END IF;

  ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                         p_tax,
                         p_tax_regime_code,
                         p_tax_status_code,
                         p_tax_determine_date,
                         l_offet_tax_status_rec,
                         x_return_status,
                         x_error_buffer);

  IF NVL(x_return_status, FND_API.G_RET_STS_UNEXP_ERROR) <> FND_API.G_RET_STS_SUCCESS  THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax',
                   'Incorrect return status after calling ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
      FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax.END',
                   'ZX_TDS_RATE_DETM_PKG: validate_offset_tax(-)');
    END IF;
    RETURN;
  END IF;

  /* Bug#5417753- use cache structure
  OPEN get_offset_info_csr(p_tax_rate_code,
                           p_tax,
                           p_tax_regime_code,
                           p_tax_status_code,
                           p_tax_determine_date);

  FETCH get_offset_info_csr INTO l_tax_rate_id;
  IF get_offset_info_csr%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_buffer  := 'No data found for the specified tax rate ';  -- will replace with coded message
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax',
                   'No data found for the specified offset tax rate');
    END IF;
  END IF;
  CLOSE get_offset_info_csr;
  */

  ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                        p_tax_regime_code,
                        p_tax,
                        p_tax_jurisdiction_code,
                        p_tax_status_code,
                        p_tax_rate_code,
                        p_tax_determine_date,
                        p_tax_class,
                        l_offset_tax_rate_rec,
                        x_return_status,
                        x_error_buffer);

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    l_tax_rate_id := l_offset_tax_rate_rec.tax_rate_id;

  ELSE
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax',
                     'Incorrect return status after calling ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax.END',
                     'ZX_TDS_RATE_DETM_PKG: validate_offset_tax(-)');
    END IF;
    RETURN;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax.END',
                   'ZX_TDS_RATE_DETM_PKG: validate_offset_tax(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_RATE_DETM_PKG.validate_offset_tax.END',
                   'ZX_TDS_RATE_DETM_PKG: validate_offset_tax(-)');
    END IF;

END validate_offset_tax;

END ZX_TDS_RATE_DETM_PKG;


/
